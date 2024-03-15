/**
About
-----
Description: TriggerHandler for the User object
Create date: April 2016

Update History
--------------
Created Apr 2016 - A.N
Updated Sep 2016 - A.N Removed hardcoded references to Org Nr Ids. Refactored method for filtering Telia users, as it recursively did SOQL-queries.
Refactored createCygateContacts and createTeliaContacts to avoid doing unneccesary SOQL-queries
Updated Sep 2016 - A.N Updated methods createCygateContacts/createTeliaContacts so that the Telia Id is populated on the contacts. SAEN-1932
Updated Dec 2016 - A.N SAEN-2117 updated method filterTeliaUsers. Instead of hard coded values, define the role names in a custom setting. (Also SOHO:Chef was added to the list)
Updated Jun 2018 - Y.K SALEF-1126 Add/Revmove users from Leaderboard (Resultat & Poäng)
Updated Oct 2018 - D.C. SALEF- 1496 For All cygate Users Chatter notification option set to "every post"
Updated Feb 2019 - C.M SALEF-1910 - Populated few fields of contact on user creation. Created a method to deactivate the Cygate SF user contact on user deactivation.
Updated July 2022 - L.S SALEF-7203 - Removed SOQL query out of for loop and optimise code. 

*/

public class UserTriggerHandler {

    // To reduce SOQL limit issues when running tests, in most cases we do not need to create Telia/Cygate contacts.
    // Unless testCreateContacts is set to true in the test class, the createTeliaContacts/createCygateContacts wil not run.
    @TestVisible private static Boolean testCreateContacts = false;

    public static boolean avoidRecursion = false;
    public static boolean avoidRecursionCPerfor = false;
    public static boolean avoidRecursionchatter = false;
    public static boolean avoidRecursionchatterFiber = false;
    private boolean m_isExecuting;
    private integer BatchSize = 0;

    public UserTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    //D.C.
    public void OnBeforeInsert(List<User> newList, Map<ID, User> newMap){
        System.debug('UserTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        setChatterFrequency(newList);
        updateuserrecord(newList,newMap,null);
    }
    //D.C.  

    public void OnAfterInsert(List<User> newList, Map<ID, User> newMap){
        System.debug('UserTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        FiberUsersChatterInsert(newList,null);
        createUserPerformance(newList);
        createCygateContacts(newList);
        createTeliaContacts(newList);
        AddToGroup(newList);

    }

    public void OnAfterUpdate(List<User> newList, Map<ID, User> newMap, List<User> oldList, Map<ID, User> oldMap){
        System.debug('UserTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        createCygateContacts(newList);
        createTeliaContacts(newList);
        deactivateCygateContact(newList, oldMap);
        FiberUsersChatterInsert(newList,oldMap);

    }

    public void OnBeforeUpdate(List<User> newList, Map<ID, User> newMap, List<User> oldList, Map<ID, User> oldMap){
        System.debug('UserTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        updateuserrecord(newList,newMap,oldMap);
        userDeactivationValidate(newList, oldMap);
    }

    public void updateuserrecord(List < User > newList, Map < ID, User > newMap, Map < ID, User > oldMap) {
    //system.debug('updateuserrecord'+newList);
    avoidRecursionchatterFiber = true;
    Map < User, Id > userstoProcessRA = new Map < User, Id > ();
    Map < id, String > Rbasedname = new Map < id, String > ();
    for (User usrObj: newList) {
        usrObj.Telia_Id__c = usrObj.Telia_Id__c.toLowercase();
        if (oldMap == null || usrObj.TeliaSE_Role_based_Approver__c != oldMap.get(usrObj.id).TeliaSE_Role_based_Approver__c) {
            //usrObj.Role_Based_Approver_Name__c = usrObj.TeliaSE_Role_based_Approver__c;
            userstoProcessRA.put(usrObj, usrObj.TeliaSE_Role_based_Approver__c);
        }
    }
    if (userstoProcessRA.size() > 0) {

        for (User u: [select id, name from user where id in: userstoProcessRA.values()]) {
            Rbasedname.put(u.id, u.name);
        }
        for (User ur: userstoProcessRA.keySet()) {
            ur.Role_Based_Approver_Name__c = Rbasedname.get(ur.TeliaSE_Role_based_Approver__c);
        }
     }
   }

    // Filter out the Cygate users, and call future method to create contact records
    private static void createCygateContacts(List<User> newList){
        // To avoid SOQL limit issues, do not create contacts when running in test mode unless specified.
        if(Test.isRunningTest() && testCreateContacts == false) return;

        List<User> cygateUsers = filterCygateUsers(newList);

        if(cygateUsers.size() > 0 && avoidRecursion == false){
            avoidRecursion = true;

            if(!System.isFuture()) {
                List<Contact> newCygateContacts = new List<Contact>();
                Set<Id> userIdsWithCygateContacts = loadExistingCygateContacts(cygateUsers);

                for(User u : cygateUsers){
                    if(!userIdsWithCygateContacts.contains(u.Id) && (u.Temporary_Deactivation_Status__c != 'Automatically Deactivated Salesforce and Vlocity'
                            || u.Temporary_Deactivation_Status__c != 'Automatically Deactivated Salesforce') && u.IsActive != false) {
                        Contact c = new Contact();
                        c.Is_Cygate_User_Contact__c = true;
                        c.Cygate_User__c = u.Id;
                        c.AccountId = getCygateAccountId();
                        c.FirstName = u.FirstName;
                        c.LastName = u.LastName;
                        c.Email= u.Email;
                        c.Telia_Id__c = u.Telia_Id__c;
                        c.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CYGATE_USER);
                        c.Title=u.Title;
                        c.MobilePhone=u.MobilePhone;
                        c.Phone=u.Phone;
                        c.Federation_Id__c=u.FederationIdentifier;
                        //c.MailingAddress =u.Address;
                        c.MailingCity=u.City;
                        c.MailingStreet =u.Street;
                        c.MailingPostalCode=u.PostalCode;
                        c.MailingState =u.State;
                        c.Office_Location__c=u.City;
                        c.Department=u.Department;
                        c.MailingCountry= u.Country;
                        newCygateContacts.add(c);
                        System.debug('***contact'+newCygateContacts);
                    }
                }

                if(newCygateContacts.size() > 0) {
                    String insertNewContactList = JSON.serialize(newCygateContacts);
                    if(insertNewContactList != null){
                        insertNewCygateContacts(insertNewContactList);
                    }
                }
            }
        }
    }

    // Author S.S
    // To avoid Mixed DML operation error when both a User and Contact object is changed    
    @future private static void insertNewCygateContacts(string insertNewContactList){
        List<Contact> newCygateContacts = (List<Contact>)JSON.deserialize(insertNewContactList,List<Contact>.class);
        if(newCygateContacts.size() > 0) {
            insert newCygateContacts;
        }
    }

    // The criteria for identifying Cygate users must be revised when Cygate Chatter Plus users are added to the system.
    private static List<User> filterCygateUsers(List<User> newList){
        Set<Id> cygateRoleIds = new Map<Id,UserRole>([SELECT Id FROM UserRole WHERE Name LIKE 'CG%']).keySet();
        List<User> cygateUsers = new List<User>();
        for(User u : newList){
            if(cygateRoleIds.contains(u.UserRoleId) && !SEUtility.isSystemAdmin(u)){
                cygateUsers.add(u);
            }
        }
        return cygateUsers;
    }

    private static Set<Id> loadExistingCygateContacts(List<User> cygateUsers){
        Set<Id> userIds = new Set<Id>();
        for(Contact c : [SELECT Id, Cygate_User__c FROM Contact WHERE Cygate_User__c in :cygateUsers]){
            userIds.add(c.Cygate_User__c);
        }
        return userIds;
    }

    private static Id cygateAccountId;
    private static Id getCygateAccountId(){
        if(cygateAccountId == null){
            List<Account> accList = [SELECT Id FROM Account WHERE Org_Nr__c = :label.Account_Org_N LIMIT 1];
            if(accList.size() != 0){ // Note: Account should always exist in production
                cygateAccountId = accList[0].Id;
            } else {
                Account acc = new Account();
                acc.Name = 'Cygate Internal AB';
                acc.Org_Nr__c = label.Account_Org_N;
                acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
                insert acc;
                cygateAccountId = acc.Id;
            }
        }
        return cygateAccountId;
    }

    //Author: N.G
    // Filter out the Telia users, and call future method to create contact records
    private static void createTeliaContacts(List<User> newList){
        // To avoid SOQL limit issues, do not create contacts when running in test mode unless specified.
        if(Test.isRunningTest() && testCreateContacts == false) return;

        List<User> teliaUsers = filterTeliaUsers(newList);

        if(teliaUsers.size() > 0 && avoidRecursion == false){
            avoidRecursion = true;

            if(!System.isFuture()){
                List<Contact> newTeliaContacts = new List<Contact>();
                Set<Id> userIdsWithTeliaContacts = loadExistingTeliaContacts(teliaUsers);

                for(User u : teliaUsers){
                    if(!userIdsWithTeliaContacts.contains(u.Id) && (u.Temporary_Deactivation_Status__c != 'Automatically Deactivated Salesforce and Vlocity'
                            || u.Temporary_Deactivation_Status__c != 'Automatically Deactivated Salesforce') && u.IsActive != false){
                        Contact c = new Contact();
                        c.Is_Telia_User_Contact__c = true;
                        c.Telia_User__c = u.Id;
                        c.AccountId = getTeliaAccountId();
                        c.FirstName = u.FirstName;
                        c.LastName = u.LastName;
                        c.Telia_Id__c = u.Telia_Id__c;
                        c.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_TELIA_USER);
                        newTeliaContacts.add(c);
                    }
                }

                if(newTeliaContacts.size() > 0){
                    String insertNewContacts = JSON.serialize(newTeliaContacts);
                    if(insertNewContacts != null){
                        insertNewTeliaContacts(insertNewContacts);
                    }
                }
            }
        }
    }

    // Author S.S
    // To avoid Mixed DML operation error when both a User and Contact object is changed    
    @future private static void insertNewTeliaContacts(string insertNewContacts){
        List<Contact> newTeliaContacts = (List<Contact>)JSON.deserialize(insertNewContacts,List<Contact>.class);
        if(newTeliaContacts.size() > 0) {
            insert newTeliaContacts;
        }
    }

    private static List<User> filterTeliaUsers(List<User> newList){
        Set<Id> teliaRoleIds = new Set<Id>();

        Set<String> topLevelUserRoles = new Set<String>();
        for(Telia_SF_User_Contact_Roles__c role : Telia_SF_User_Contact_Roles__c.getall().values()){
            topLevelUserRoles.add(role.Name);
        }

        // Add top level Telia roles
        for(UserRole ur : getAllUserRoles()){
            if(topLevelUserRoles.contains(ur.Name))
                teliaRoleIds.add(ur.id);
        }
        // Get all subordinate roles to the top level Telia roles
        teliaRoleIds = addSubRoleIds(teliaRoleIds);

        List<User> teliaUsers = new List<User>();
        for(User u : newList){
            if(teliaRoleIds.contains(u.UserRoleId) && !SEUtility.isSystemAdmin(u))
                teliaUsers.add(u);
        }
        return teliaUsers;
    }

    // Author A.N
    // returns a set with the original role ids plus all subordinate role ids. Will call itself recursively until it has reached the bottom of the role hierarchy
    private static Set<Id> addSubRoleIds(Set<Id> roleIds) {
        Set<Id> subRoleIds = new Set<Id>();

        for (Id parentId : roleIds){
            for (UserRole ur : getAllUserRoles()){
                if(ur.ParentRoleId == parentId) subRoleIds.add(ur.Id);
            }
        }
        // Recursive call
        if (!subRoleIds.isEmpty()) subRoleIds.addAll(addSubRoleIds(subRoleIds));

        roleIds.addAll(subRoleIds);
        return roleIds;
    }

    private static List<UserRole> userRoles;
    private static List<UserRole> getAllUserRoles(){
        if(userRoles == null) userRoles = [SELECT Id, Name, ParentRoleId FROM UserRole];
        return userRoles;
    }

    private static Set<Id> loadExistingTeliaContacts(List<User> teliaUsers){
        Set<Id> userIds = new Set<Id>();
        for(Contact c : [SELECT Id, Telia_User__c FROM Contact WHERE Telia_User__c in :teliaUsers]){
            userIds.add(c.Telia_User__c);
        }
        return userIds;
    }

    // TODO: This method is also used by LeadTriggerHandler and should be moved tp SEUtility-class
    private static Id teliaAccountId;
    public static Id getTeliaAccountId(){
        if(teliaAccountId == null){
            List<Account> accList = [SELECT Id FROM Account WHERE Org_Nr__c = :label.Account_Org_Nr_Telia LIMIT 1];
            if(accList.size() != 0){ // Note: Account should always exist in production
                teliaAccountId = accList[0].Id;
            } else {
                Account acc = new Account();
                acc.Name = 'Telia';
                acc.Org_Nr__c = label.Account_Org_Nr_Telia;
                acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
                insert acc;
                teliaAccountId = acc.Id;
            }
        }
        return teliaAccountId;
    }

    //Author YK
    // For Leader board automation
    //SALEF-1126 Add/Revmove users from Leaderboard (Resultat & Poäng)
    // The criteria for identifying Cygate users with Cygate_Performance_User__c as true 
    @TestVisible private static List<User> cygatePerformanceUsers(List<User> newList){
        Set<Id> cygateRoleIds = new Map<Id,UserRole>([SELECT Id FROM UserRole WHERE Name LIKE 'CG%']).keySet();
        List<User> cygatePerformanceUsersList = new List<User>();
        for(User u : newList){
            if(cygateRoleIds.contains(u.UserRoleId) && !SEUtility.isSystemAdmin(u) && u.Cygate_Performance_User__c == true){
                cygatePerformanceUsersList.add(u);
            }
        }
        return cygatePerformanceUsersList;
    }

    //Author YK
    // For Leader board automation
    //SALEF-1126 Add/Revmove users from Leaderboard (Resultat & Poäng)
    @TestVisible private static Set<Id> loadExistingCygateYearlyPerformanceScore(List<User> cygateUsers){
        Set<Id> YearlyPerformanceScoreIds = new Set<Id>();
        for(Yearly_Performance_Score__c ys : [SELECT Id, User_Performance__c FROM Yearly_Performance_Score__c WHERE User_Performance__r.user__c in :cygateUsers  AND  User_Performance__r.User__r.Cygate_Performance_User__c = true]){
            YearlyPerformanceScoreIds.add(ys.id);
        }
        return YearlyPerformanceScoreIds;
    }

    //Author YK
    // For Leader board automation
    //SALEF-1126 Add/Revmove users from Leaderboard (Resultat & Poäng)
    @TestVisible private static Set<Id> loadExistingCygateUserPerformance(List<User> cygateUsers){
        Set<Id> UserPerformanceIds = new Set<Id>();
        for(User_Performance__c up : [SELECT Id, Name FROM User_Performance__c WHERE User__c in :cygateUsers  AND User__r.Cygate_Performance_User__c = true]){
            UserPerformanceIds.add(up.id);
        }
        return UserPerformanceIds;
    }



    //Author YK
    // For Leader board automation
    //SALEF-1126 Add/Revmove users from Leaderboard (Resultat & Poäng)
    @TestVisible @future private static void insertNewUserPerformance(string insertNewUP){
        List<User_Performance__c> newUPList = (List<User_Performance__c>)JSON.deserialize(insertNewUP,List<User_Performance__c>.class);
        if(newUPList.size() > 0) {
            insert newUPList ;
            List<Yearly_Performance_Score__c> newYearlyPerformanceScore = new List<Yearly_Performance_Score__c>();
            for(User_Performance__c usrPer : newUPList ){
                //if(!YearlyPerformanceScoreIdsWithCygateUsers.contains(u.Id)){
                Yearly_Performance_Score__c ys = new Yearly_Performance_Score__c();
                //ys.Name = (Date.Today().Year()).format();
                ys.Name = String.ValueOf(Date.Today().Year());
                ys.Sales_Revenue_Target__c = 0;
                ys.Competence_Score__c = 0;
                ys.Result__c = 0;
                system.debug('####userPer.id'+ usrPer.id);
                ys.User_Performance__c = usrPer.id;

                newYearlyPerformanceScore.add(ys);
                //}
            }
            insert newYearlyPerformanceScore;
        }
    }

    //Author YK
    // For Leader board automation
    //SALEF-1126 Add/Revmove users from Leaderboard (Resultat & Poäng)
    @TestVisible private static void createUserPerformance(List<User> newList){
        // To avoid SOQL limit issues, do not create contacts when running in test mode unless specified.
        //if(Test.isRunningTest() && testCreateContacts == false) return;

        System.debug('$$$In YeralyPerformance Method');

        //List<User> cygateUsers = filterCygateUsers(newList);
        List<User> cygateUsersWithCygatePerformance = cygatePerformanceUsers(newList);

        if(cygateUsersWithCygatePerformance.size() > 0 && avoidRecursionCPerfor == false){
            avoidRecursionCPerfor = true;

            if(!System.isFuture()) {

                List<User_Performance__c > newUserPerformance = new List<User_Performance__c>();
                Set<Id> UserPerformanceIdsWithCygateUsers = loadExistingCygateUserPerformance(cygateUsersWithCygatePerformance);
                //List<Yearly_Performance_Score__c> newYearlyPerformanceScore = new List<Yearly_Performance_Score__c>();
                //Set<Id> YearlyPerformanceScoreIdsWithCygateUsers = loadExistingCygateYearlyPerformanceScore(cygateUsers);

                for(User u : cygateUsersWithCygatePerformance){
                    if(!UserPerformanceIdsWithCygateUsers.contains(u.Id)){
                        User_Performance__c up = new User_Performance__c ();
                        up.Name = u.FirstName +' '+u.LastName;
                        up.User__c = u.id;
                        up.OwnerId = u.id;
                        newUserPerformance.add(up);

                    }
                }

                if(newUserPerformance.size() > 0) {
                    String insertNewUserPerformanceList = JSON.serialize(newUserPerformance);
                    if(insertNewUserPerformanceList != null){
                        insertNewUserPerformance(insertNewUserPerformanceList);
                        // createYearlyPerformanceScore(newUserPerformance);
                    }
                }

            }
        }
    }
    //Author D.C.
    //SALEF- 1496    This method will update the DefaultGroupNotificationFrequency = Email every Post and DigestFrequency= Daily. Before a User record is inserted.
    // Thus all Cygate record will have Chatter notification for all every-post.
    @TestVisible private static void setChatterFrequency(List<User> newList){
        List<User> cygateUsers = filterCygateUsers(newList);
        for(User u: cygateUsers){
            u.DefaultGroupNotificationFrequency = 'P';
            u.DigestFrequency = 'D';
            System.debug('$$$In setChatterFrequency Method user - ' + cygateUsers);
        }

    }

    //Author D.C.
    //SALEF- 1496  For any new Cygate User the cyagte chatter group ''Cygate - Användarsupport''  will be tag.
    @TestVisible private static void AddToGroup(List<User> newList){
        List<User> cygateUsers = filterCygateUsers(newList);

        if(cygateUsers.size() > 0 && avoidRecursionchatter == false){
            avoidRecursionchatter = true;

            if(!System.isFuture()) {
                Set<Id> UserWithCygateUsers = loadExistingCygateUser(cygateUsers);
                List<CollaborationGroupMember>listGroupMember =new List<CollaborationGroupMember>();
                List<CollaborationGroup> g=[select Id, name from CollaborationGroup Where Name='Cygate - Användarsupport'];
                if(g.size()>0){
                for(User u : cygateUsers){
                    if(!UserWithCygateUsers.contains(u.id) && (!Test.isRunningTest())){
                        CollaborationGroupMember gm= new CollaborationGroupMember();

                            gm.CollaborationGroupId=g[0].id;
                        gm.MemberId = u.id;
                        listGroupMember.add(gm);

                    }
                }



                if(!listGroupMember.isEmpty()) {
                    String updatecygateUser = JSON.serialize(listGroupMember);
                    if(updatecygateUser != null){
                        UpdateCyagteUserNow(updatecygateUser);
                    }
                }
            }
        }
        }



    }

    @future private static void UpdateCyagteUserNow(string Updateuser){

        List<CollaborationGroupMember> newIDList = (List<CollaborationGroupMember>)JSON.deserialize(Updateuser,List<CollaborationGroupMember>.class);
        if(newIDList.size() > 0) {
            insert newIDList ;
        }


    }

    @TestVisible private static Set<Id> loadExistingCygateUser(List<User> cygateUsers){
        Set<Id> cygateuserIds = new Set<Id>();
        If(!Test.isRunningTest()){
            for(CollaborationGroupMember up : [SELECT MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId IN (SELECT ID FROM CollaborationGroup WHERE Name = 'Cygate - Användarsupport')]){
                cygateuserIds.add(up.MemberId);
            }
        }
        return cygateuserIds;

    }

    //D.C. 




    //C.M
    //deactivate Cygate SF user contact on deactivation of user
    private static void deactivateCygateContact(List<User> newlist, Map<Id, User> oldMap)
    {
        System.debug('in method');
        List<String> userEmail=new List<String>();

        for(User u: newlist){
            if((u.isActive==false && oldmap.get(u.Id).isActive==true && u.Temporary_Deactivation_Status__c != 'Automatically Deactivated Salesforce and Vlocity' && u.Temporary_Deactivation_Status__c != 'Automatically Deactivated Salesforce') || (u.isActive==false && u.Temporary_Deactivation_Status__c == 'Manually Deactivated Salesforce' && oldmap.get(u.Id).Temporary_Deactivation_Status__c != 'Manually Deactivated Salesforce')){
                userEmail.add(u.Email);

            }
        }

        List<Contact> getContact = [Select Id, RecordTypeId From Contact where Email IN : userEmail AND RecordTypeId = : SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CYGATE_USER )];


        List<Contact> updateContact=new List<Contact>();

        if(getContact.size() > 0){
            for(Contact c : getContact)
            {
                c.Deactivation_Date__c= System.today();
                updateContact.add(c);
            }
        }

        if(updateContact.size() > 0) {
            String updateContactList= JSON.serialize(updateContact);
            if(updateContactList!= null){
                updateCygateContact(updateContactList);
            }
        }
    }

    // To avoid Mixed DML operation error when both a User and Contact object is changed    
    @future private static void updateCygateContact(string updateContactList){
        List<Contact> deactivateCygateContacts = (List<Contact>)JSON.deserialize(updateContactList,List<Contact>.class);
        if(deactivateCygateContacts.size() > 0) {
            update deactivateCygateContacts;
        }
    }



     private static void FiberUsersChatterInsert(List < User > newList, Map < ID, User > oldMap) {

        Set < Id > collabId = new Set < Id > ();
        Set < Id > collabIdToUpdate = new Set < Id > ();
        for (User u: newList) {
            //List to insert user into Group
            if ((oldMap != NULL && u.isActive == true && u.profileId == SEUtility.getProfileId('Fiber Base Profile') && u.profileId != oldMap.get(u.id).profileId) || (oldMap != NULL && u.isActive == true && u.profileId == SEUtility.getProfileId('Fiber Base Profile') && !oldMap.get(u.id).isActive) || (oldmap == null && u.isActive == true && u.profileId == SEUtility.getProfileId('Fiber Base Profile'))) {
                collabId.add(u.Id);
            }

            //List to delete user from Group        
            if (oldMap != NULL && u.profileId != SEUtility.getProfileId('Fiber Base Profile') && oldMap.get(u.id).profileId == SEUtility.getProfileId('Fiber Base Profile')) {
                    collabIdToUpdate.add(u.id);
                }

            }
            If(collabIdToUpdate.size() > 0 || collabId.size() > 0) {
                AddFiberUserToChatterGroup(collabId, collabIdToUpdate);
            }
        }
        @future public static void AddFiberUserToChatterGroup(Set < Id > InsertuserIds, Set < Id > RemoveuserIds) {
            //Query Chatter Group
            Id cgID;
            CollaborationGroup[] cg = [Select Id FROM CollaborationGroup WHERE Name = 'Real Estate Fiber' LIMIT 1];
            if(cg.size()>0)
            cgID = cg[0].id;
            if (InsertuserIds.size() > 0 && cgID != null) {
                try {
                    List < CollaborationGroupMember > cgm = new List < CollaborationGroupMember > ();

                    for (ID uId: InsertuserIds) {
                        cgm.add(new CollaborationGroupMember(CollaborationGroupId = cgID, MemberId = uId));
                    }
                    //Add user to Chatter group
                    if (cgm.size() > 0) {
                        insert cgm;
                    }
                } catch (QueryException qe) {
                    System.debug('QueryException in AsyncApex.AddUserToGroup is :' + qe);
                }
            }
            if (RemoveuserIds.size() > 0) {
                List < CollaborationGroupMember > ListGM = [Select Id from CollaborationGroupMember where MemberId in: RemoveuserIds and CollaborationGroupId =: cgID];
                try {
                    //Delete user from Chatter Group
                    if (ListGM.size() > 0) {
                        delete ListGM;
                    }
                } catch (QueryException qe) {
                    System.debug('QueryException in AsyncApex.DeteleFromGroups is :' + qe);
                }
            }

        }

    public static void userDeactivationValidate(List < User > newList, Map < ID, User > oldMap) {
        Set < Id > usrToValidate = new Set < Id > ();
        Set < Id > usrToAddError = new Set < Id > ();
        for (User usr: newlist) {
            if (oldmap.get(usr.Id).IsActive == true && usr.Isactive == false && (usr.Temporary_Deactivation_Status__c == 'None' || usr.Temporary_Deactivation_Status__c == 'Manually Deactivated Salesforce' || usr.Temporary_Deactivation_Status__c == null)) {
                usrToValidate.add(usr.Id);
            }
        }
        if (!usrToValidate.isEmpty()) {
            usrToAddError = validateDeactivation(usrToValidate);
        }
        if (usrToAddError!=null) {
            for (User userRec: newlist) {
                if (usrToAddError.contains(userRec.Id)) {
                    userRec.addError(Label.UserDeactivationError);
                }
            }
        }
    }

    public static Set < Id > validateDeactivation(Set < Id > usrIds) {
        List < Account > checkAccountOwner = [Select Id, OwnerId, Cygate_Account_Manager__c from Account where OwnerId IN: usrIds OR Cygate_Account_Manager__c IN: usrIds];
        // List<Account> checkCygateAccountOwner = [Select Id,Cygate_Account_Manager__c from Account where Cygate_Account_Manager__c IN usrIds];
        List < Opportunity > checkOppOwner = [Select Id, OwnerId from Opportunity where OwnerId IN: usrIds AND IsClosed=FALSE];
        List < Contract > checkContractOwner = [Select Id, OwnerId from Contract where OwnerId IN: usrIds AND (Status='Draft' OR Status='Sent for Signing' OR Status='Signed' OR Status='Active' OR Status='Activated')];
        List < Seller__c > checkSeller = [Select Id, User__c from Seller__c where User__c IN: usrIds AND End_Date__c > Today];
        List < Task > checkTask = [Select Id, OwnerId From Task where OwnerId IN: usrIds AND Status !='Stängd'];
        Set < Id > validationFailedRecs = new Set < Id > ();

        if (!checkAccountOwner.IsEmpty()) {
            for (Account a: checkAccountOwner) {
                if (usrIds.contains(a.OwnerId)) {
                    validationFailedRecs.add(a.OwnerId);
                }
                if (usrIds.contains(a.Cygate_Account_Manager__c)) {
                    validationFailedRecs.add(a.Cygate_Account_Manager__c);
                }
            }
        }
        if (!checkOppOwner.IsEmpty()) {
            for (Opportunity o: checkOppOwner) {
                if (usrIds.contains(o.OwnerId)) {
                    validationFailedRecs.add(o.OwnerId);
                }
            }
        }

        if (!checkSeller.IsEmpty()) {
            for (Seller__c s: checkSeller) {
                if (usrIds.contains(s.User__c)) {
                    validationFailedRecs.add(s.User__c);
                }
            }
        }

        if (!checkContractOwner.IsEmpty()) {
            for (Contract c: checkContractOwner) {
                if (usrIds.contains(c.OwnerId)) {
                    validationFailedRecs.add(c.OwnerId);
                }
            }
        }
        if (!checkTask.IsEmpty()) {
            for (Task t: checkTask) {
                if (usrIds.contains(t.OwnerId)) {
                    validationFailedRecs.add(t.OwnerId);
                }
            }
        }
        if (!validationFailedRecs.IsEmpty()) {
            return validationFailedRecs;
        } else {
            return null;
        }
    }

 }