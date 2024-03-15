/** About
 * -----
 * Description: Data Factory for test classes
 *
 * Modifications:
 * 05.06.2023 [Tomass Brazovskis] LTAT-9674 - Added tests for setUpParentKKNrCustomerSuccessMgrUpdate() and
 *              updateParentKKNrCustomerSuccessMgr() methods. 
 * 19.05.2023 [Tomass Brazovskis] LTAT-9938 - Updated existing Larmlistan test methods.
 * 05.01.2023 [Tomass Brazovskis] SALEF-7949 - Added an updateParentAccountContactedDate() test method.
 * 12.08.2022 [LS] - To optimise this class removed hardocode id's of Case, account record type and passed two method code coverage.
 **/
@isTest
public class Test_AccountTriggerHandler {    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
        }
    @isTest static void addOneCygateAccManagerToOrgAccount(){        
        List<User> cygateUsers = createCygateUsers(3);
        Account kundKonto;
        List<Account> orgAccounts;        
        System.runAs(new User(Id = Userinfo.getUserId())){
            insert cygateUsers;
            kundKonto = Test_DataFactory.createOneKundkontoAccount();
            insert kundKonto;
            //(Id cygateAccountOwnerId, Id cygManagerId, Id kundkontoId, Integer n)
            orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, null, kundKonto.Id,1);
            for(Account a : orgAccounts) a.OwnerId = cygateUsers[1].Id;
            insert orgAccounts;

        }
        
        // cygateUsers[0] is CygateChefUser
        System.runAs(cygateUsers[1]){
            orgAccounts[0].Cygate_Account_Manager__c = cygateUsers[2].Id;
            update orgAccounts[0];
        }        
        Account kundKontoAfter = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
                                  (SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
                                  FROM Account WHERE Id = :kundKonto.Id];
        System.assertEquals(kundKontoAfter.AccountTeamMembers.size(), 1, 'Exactly One Account Team Member record should have been created for the Cygate Account manager added to the org account.');
        System.assertEquals(kundKontoAfter.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'No Account Team Member has been created for the Cygate Account manager added to the org account.');
    }    
    /* @isTest static void addOneCygateAccManagerToSubAccount(){

List<User> cygateUsers = createCygateUsers(3);              
Account kundKonto;
List<Account> orgAccounts;
test.starttest();
System.runAs(new User(Id = Userinfo.getUserId())){
insert cygateUsers;
kundKonto = Test_DataFactory.createOneKundkontoAccount(); 
insert kundKonto;
orgAccounts = createCygateOrgAccounts(cygateUsers[0].Id, null, kundKonto.Id,1);
insert orgAccounts;
List<Account> subAccounts = createCygateSubAccounts(cygateUsers[0].Id, cygateUsers[2].Id, orgAccounts[0].Id,1);
insert subAccounts;
}
test.stoptest();
Account kundKontoAfter = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
(SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
FROM Account WHERE Id = :kundKonto.Id];
System.assertEquals(kundKontoAfter.AccountTeamMembers.size(), 1, 'Exactly One Account Team Member record should have been created for the Cygate Account manager added to the org account.');
System.assertEquals(kundKontoAfter.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'No Account Team Member has been created for the Cygate Account manager added to the sub account.');
}*/   
    @isTest static void addTwoCygateAccManagersToOrgAccount(){       
        List<User> cygateUsers = createCygateUsers(4);
        Account kundKonto;
        List<Account> orgAccounts;        
        System.runAs(new User(Id = Userinfo.getUserId())){
            insert cygateUsers;
            kundKonto = Test_DataFactory.createOneKundkontoAccount();
            insert kundKonto;
            orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, null, kundKonto.Id, 2);
            insert orgAccounts;
        }        
        System.runAs(cygateUsers[1]){
            orgAccounts[0].Cygate_Account_Manager__c = cygateUsers[2].Id;
            orgAccounts[1].Cygate_Account_Manager__c = cygateUsers[3].Id;
            update orgAccounts;
        }        
        Account kundKontoAfter = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
                                  (SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
                                  FROM Account WHERE Id = :kundKonto.Id];
        System.assertEquals(kundKontoAfter.AccountTeamMembers.size(), 2, 'Exactly Two Account Team Member records should have been created for the Cygate Account managers added to the org accounts.');
    }    
    @isTest static void addTheSameCygateAccManagersToTwoOrgAccounts(){        
        List<User> cygateUsers = createCygateUsers(4);
        Account kundKonto;
        List<Account> orgAccounts;        
        System.runAs(new User(Id = Userinfo.getUserId())){
            insert cygateUsers;
            kundKonto = Test_DataFactory.createOneKundkontoAccount();
            insert kundKonto;
            orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, null, kundKonto.Id, 2);
            insert orgAccounts;
        }
        
        System.runAs(cygateUsers[1]){
            orgAccounts[0].Cygate_Account_Manager__c = cygateUsers[2].Id;
            orgAccounts[1].Cygate_Account_Manager__c = cygateUsers[2].Id;
            update orgAccounts[0];
        }        
        Account kundKontoAfter = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
                                  (SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
                                  FROM Account WHERE Id = :kundKonto.Id];
        System.assertEquals(kundKontoAfter.AccountTeamMembers.size(), 1, 'Exactly one Account Team Member record should have been created for the Cygate Account managers added to the org accounts.');
        System.assertEquals(kundKontoAfter.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'No Account Team Member has been created for the Cygate Account manager added to the org account.');
    }    
    @isTest static void replaceCygateAccManagersOnOrgAccount(){
        
        List<User> cygateUsers = createCygateUsers(4);
        Account kundKonto;
        List<Account> orgAccounts;
        test.starttest();
        System.runAs(new User(Id = Userinfo.getUserId())){
            insert cygateUsers;
            kundKonto = Test_DataFactory.createOneKundkontoAccount();
            insert kundKonto;
            orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, null, kundKonto.Id,1);
            insert orgAccounts;
        }
        
        System.runAs(cygateUsers[1]){
            orgAccounts[0].Cygate_Account_Manager__c = cygateUsers[2].Id;
            update orgAccounts[0];
        }
        
        Account kundKontoAfter1 = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
                                   (SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
                                   FROM Account WHERE Id = :kundKonto.Id];
        System.assertEquals(kundKontoAfter1.AccountTeamMembers.size(), 1, 'Exactly One Account Team Member record should have been created for the Cygate Account manager added to the org account.');
        System.assertEquals(kundKontoAfter1.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'Not correct Account Team Member has been created for the Cygate Account manager added to the sub account.');
        
        System.runAs(cygateUsers[1]){
            orgAccounts[0].Cygate_Account_Manager__c = cygateUsers[3].Id;
            update orgAccounts[0];
        }
        test.stoptest();
        Account kundKontoAfter2 = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
                                   (SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
                                   FROM Account WHERE Id = :kundKonto.Id];
        System.assertEquals(kundKontoAfter2.AccountTeamMembers.size(), 1, 'Exactly One Account Team Member record should have been created for the Cygate Account manager added to the org account.');
        System.assertEquals(kundKontoAfter2.AccountTeamMembers[0].UserId, cygateUsers[3].Id, 'Not correct Account Team Member has been created for the Cygate Account manager replaced on the sub account.');
    }
    
    /* @isTest static void replaceCygateAccManagersOnSubAccount(){
List<User> cygateUsers = createCygateUsers(4);
Account kundKonto;
List<Account> orgAccounts;
List<Account> subAccounts;
System.runAs(new User(Id = Userinfo.getUserId())){
test.startTest();
insert cygateUsers;
kundKonto = Test_DataFactory.createOneKundkontoAccount();
insert kundKonto;
orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, null, kundKonto.Id,1);
insert orgAccounts;
subAccounts = createCygateSubAccounts(cygateUsers[1].Id, cygateUsers[2].Id, orgAccounts[0].Id,1);
insert subAccounts;
}

Account kundKontoAfter1 = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
(SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
FROM Account WHERE Id = :kundKonto.Id];
System.assertEquals(kundKontoAfter1.AccountTeamMembers.size(), 1, 'Exactly One Account Team Member record should have been created for the Cygate Account manager added to the sub account.');
System.assertEquals(kundKontoAfter1.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'Not correct Account Team Member has been created for the Cygate Account manager added to the sub account.');
test.stoptest();
System.runAs(cygateUsers[1]){
subAccounts[0].Cygate_Account_Manager__c = cygateUsers[3].Id;
update subAccounts[0];
}

Account kundKontoAfter2 = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
(SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
FROM Account WHERE Id = :kundKonto.Id];
System.assertEquals(kundKontoAfter2.AccountTeamMembers.size(), 1, 'Exactly One Account Team Member record should have been created for the Cygate Account manager added to the sub account.');
System.assertEquals(kundKontoAfter2.AccountTeamMembers[0].UserId, cygateUsers[3].Id, 'Not correct Account Team Member has been created for the Cygate Account manager replaced on the sub account.');
}*/
    
    @isTest static void deleteOrgAccountWithCygateAccManager() {
        
        List<User> cygateUsers = createCygateUsers(4);
        Account kundKonto;
        List<Account> orgAccounts;
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            insert cygateUsers;
            kundKonto = Test_DataFactory.createOneKundkontoAccount();
            insert kundKonto;
            orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, null, kundKonto.Id, 2);
            insert orgAccounts;
        }
        
        System.runAs(cygateUsers[1]){
            orgAccounts[0].Cygate_Account_Manager__c = cygateUsers[2].Id;
            orgAccounts[1].Cygate_Account_Manager__c = cygateUsers[3].Id;
            update orgAccounts;
        }
        
        Account kundKontoAfter = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
                                  (SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
                                  FROM Account WHERE Id = :kundKonto.Id];
        System.assertEquals(kundKontoAfter.AccountTeamMembers.size(), 2, 'Exactly Two Account Team Member records should have been created for the Cygate Account managers added to the org accounts.');
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            delete orgAccounts[1];
        }
        
        Account kundKontoAfterDel = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
                                     (SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
                                     FROM Account WHERE Id = :kundKonto.Id];
        System.assertEquals(kundKontoAfterDel.AccountTeamMembers.size(), 1, 'Exactly One Account Team Member record should have been created after the org account 2 was deleted.');
        System.assertEquals(kundKontoAfterDel.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'The Account Team Member should correspond with org account 1 Cygate Account Manager.');
    }
    
    /*
@isTest static void deleteSubAccountWithCygateAccManager(){
List<User> cygateUsers = createCygateUsers(4);              
Account kundKonto;
List<Account> orgAccounts;
List<Account> subAccounts;
System.runAs(new User(Id = Userinfo.getUserId())){
insert cygateUsers;
kundKonto = Test_DataFactory.createOneKundkontoAccount(); 
insert kundKonto;
orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, cygateUsers[2].Id, kundKonto.Id, 1);
insert orgAccounts;
test.startTest();
subAccounts = createCygateSubAccounts(cygateUsers[0].Id, cygateUsers[3].Id, orgAccounts[0].Id,1);
insert subAccounts;
}

Account kundKontoAfter = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
(SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
FROM Account WHERE Id = :kundKonto.Id];
System.assertEquals(kundKontoAfter.AccountTeamMembers.size(), 2, 'Exactly Two Account Team Member records should have been created for the Cygate Account managers added to the org accounts.');

System.runAs(new User(Id = Userinfo.getUserId())){
delete subAccounts;
}
test.StopTest();
Account kundKontoAfterDel = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
(SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
FROM Account WHERE Id = :kundKonto.Id];
System.assertEquals(kundKontoAfterDel.AccountTeamMembers.size(), 1, 'Exactly One Account Team Member record should have been created after the sub account was deleted.');
System.assertEquals(kundKontoAfterDel.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'The Account Team Member should correspond with org account Cygate Account Manager.');       
}

@isTest static void deleteCygateAccManagerFromOneOfTwoOrgAccounts(){

List<User> cygateUsers = createCygateUsers(4);              
Account kundKonto;
List<Account> orgAccounts;

System.runAs(new User(Id = Userinfo.getUserId())){
insert cygateUsers;
kundKonto = Test_DataFactory.createOneKundkontoAccount(); 
insert kundKonto;
orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, null, kundKonto.Id,2);
insert orgAccounts;
}

System.runAs(cygateUsers[1]){
orgAccounts[0].Cygate_Account_Manager__c = cygateUsers[2].Id;
orgAccounts[1].Cygate_Account_Manager__c = cygateUsers[2].Id;
update orgAccounts;
}

Account kundKontoAfter = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
(SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
FROM Account WHERE Id = :kundKonto.Id];
System.assertEquals(kundKontoAfter.AccountTeamMembers.size(), 1, 'Exactly one Account Team Member record should have been created for the Cygate Account managers added to the org accounts.');
System.assertEquals(kundKontoAfter.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'No Account Team Member has been created for the Cygate Account manager added to the org accounts.');

System.runAs(new User(Id = Userinfo.getUserId())){
delete orgAccounts[1];
}

// The AccountTeamMember should not have been deleted
Account kundKontoAfterDel = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
(SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
FROM Account WHERE Id = :kundKonto.Id];
System.assertEquals(kundKontoAfterDel.AccountTeamMembers.size(), 1, 'Exactly one Account Team Member record should have been created for the Cygate Account managers added to the org accounts.');
System.assertEquals(kundKontoAfterDel.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'No Account Team Member has been created for the Cygate Account manager added to the org accounts.');
}*/
    @isTest static void testOpportunitySplits() {        
        User bypassVRAdminUser;
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        User salesRep;
        User teamLeader;
        Account acc;
        Opportunity opp;
        
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            bypassVRAdminUser = Test_DataFactory.createAdminUser();
            bypassVRAdminUser.Bypass_VR__c = true;
            insert bypassVRAdminUser;
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            
            salesRep = largeUserTeam[2];
            teamLeader = largeUserTeam[1];
            
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        Test.startTest();
        
        System.runAs(salesRep){
            opp = Test_DataFactory.createLargeOpportunity();
            opp.AccountId = acc.Id;
            opp.Large_New_Sales__c = 100;
            opp.Large_Continuation_Sales__c = 100;
            insert opp;
        }
        
        List<Id> oppSplitIds = SEUtility.getActiveOppSplitIds();        
        List<OpportunitySplit> oppSplits = [SELECT Id, OpportunityId, SplitTypeId, SplitOwnerId, SplitPercentage FROM OpportunitySplit WHERE OpportunityId = :opp.Id AND SplitTypeId in :oppSplitIds];
        System.assertEquals(oppSplits.size(), 3, 'There should have been created 3 opp split records.');
        System.assertEquals(oppSplits[0].SplitOwnerId, salesRep.Id, 'Wrong user as split owner.');
        System.assertEquals(oppSplits[0].SplitPercentage, 100, 'The split percentage should be 100.');
        System.assert(oppSplits[0].SplitTypeId != oppSplits[1].SplitTypeId, 'The two opp splits should have different split types.');      
        System.runAs(bypassVRAdminUser){
            acc.OwnerId = teamLeader.Id;
            update acc;
        }
        
        List<OpportunitySplit> oppSplitsAfterNewAccOwner = [SELECT Id, OpportunityId, SplitTypeId, SplitOwnerId, SplitPercentage FROM OpportunitySplit WHERE OpportunityId = :opp.id AND SplitTypeId in :oppSplitIds];
        System.assertEquals(oppSplitsAfterNewAccOwner.size(), 3, 'There should still be 3 opp split records.');
        System.assertEquals(oppSplitsAfterNewAccOwner[0].SplitOwnerId, teamLeader.Id, 'Team Leader should be split owner.');
        System.assertEquals(oppSplitsAfterNewAccOwner[0].SplitPercentage, 100, 'The split percentage should be 100.');     
        Test.stopTest();
    }
    
    @isTest static void addOygateAccManagerToOrgAccount(){
        
        List<User> cygateUsers = createCygateUsers(3);
        Account OrgAccount;
        List<Account> orgAccounts;
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            test.StartTest();
            insert cygateUsers;
            OrgAccount = Test_DataFactory.createOneLargeStandardAccount();
            insert OrgAccount;
            orgAccount.Cygate_Account_Manager__c = cygateUsers[2].Id;
            update OrgAccount;
            
            //(Id cygateAccountOwnerId, Id cygManagerId, Id kundkontoId, Integer n)
            orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, null, OrgAccount.Id,1);
            for(Account a : orgAccounts)
                insert orgAccounts;           
            orgAccount.Cygate_Account_Manager__c = cygateUsers[1].Id;
            update OrgAccount;
        }
        
        // cygateUsers[0] is CygateChefUser
        System.runAs(cygateUsers[1]){
            orgAccounts[0].Cygate_Account_Manager__c = cygateUsers[2].Id;
            update orgAccounts[0];
        }        
        Account largeaccountAfter = [SELECT Id,(SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
                                     FROM Account WHERE Id = :orgAccount.Id];
        
        System.assertEquals(largeaccountAfter.AccountTeamMembers[0].UserId, cygateUsers[1].Id, 'No Account Team Member has been created for the Cygate Account manager added to the org account.');
        orgAccount.Cygate_Account_Manager__c = Null;
        update OrgAccount;
        test.StopTest();
    }
    /* The first user returned has a role of type Sales Support ("Chef"), as validation only allows Sales Support to create Accounts.
*  The second user returned has a role of type Manager ("Chef"), as validation only allows managers to Update Cygate Account Managers.
*/
    private static List<User> createCygateUsers(Integer n){
        List<User> ul = new List<User>();
        for(Integer i = 0; i < n; i++){
            if(i == 0) ul.add(Test_DataFactory.createCygateSalesSupportUser());
            else if(i == 1) ul.add(Test_DataFactory.createCygateChefUser());
            else ul.add(Test_DataFactory.createCygateUser());
        }
        return ul;
    }
    
    private static List<Account> createCygateOrgAccounts(Id cygateAccountOwnerId, Id cygManagerId, Id kundkontoId, Integer n){
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < n; i++){
            Account a = Test_DataFactory.createOneCygateAccount(cygateAccountOwnerId, kundkontoId);
            a.Cygate_Account_Manager__c = cygManagerId;
            accList.add(a);
        }
        return acclist;
    }
    
    /* private static List<Account> createCygateSubAccounts(Id cygateAccountOwnerId, Id cygManagerId, Id orgAccountId, Integer n){
List<Account> accList = new List<Account>();
for(Integer i = 0; i < n; i++){
Account a = Test_DataFactory.createOneCygateSubAccount(cygateAccountOwnerId, orgAccountId);
a.Cygate_Account_Manager__c = cygManagerId;
accList.add(a);
}
return acclist;
}*/
    /*
public static testmethod void testAvtalSituationOwner(){
System.debug('@@Test testAvtalSituationOwner Starts');
User salesRep;
User testUser;
Account kundKonto;

System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
salesRep = Test_DataFactory.createAdminUser();
insert salesRep;
}

System.runAs(salesRep){
Test.startTest();
testUser = Test_DataFactory.createLargeUser();
insert testUser;
kundKonto = Test_DataFactory.createOneKundkontoAccount(); 
insert kundKonto;

Agreement_Situation__c avtal = new Agreement_Situation__c(Agreement_Category__c='UC/Mobil',KKnr__c=kundKonto.Id);
insert avtal;           

kundKonto.OwnerId=testUser.Id;
update kundKonto;     

Agreement_Situation__c updatedOwner = [SELECT OwnerId FROM Agreement_Situation__c WHERE KKnr__c =: kundKonto.Id];
System.assertEquals(updatedOwner.OwnerId, kundKonto.OwnerId);
Test.stopTest();
} 
}*/
    static testMethod void testUpdateNamedSalesCoordinatoronCase(){
        
        User salesRep = new User();
        Account Kundkonto = new Account();
        User testUser = new User();
        Account orgNr = new Account();
        Case csNMC = new Case();
        Account otherOrgNr = New Account();
        List<Account> insertAccountList = new List<Account>();
        
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createAdminUser();
            insert salesRep;
        }
        
        System.runAs(salesRep){
            Test.startTest();
            testUser = Test_DataFactory.createLargeUser();
            insert testUser;
            kundKonto = Test_DataFactory.createOneKundkontoAccount();
            insert kundKonto;
            kundKonto.Named_Sales_Coordinator__c = testUser.Id;
            update kundkonto;
            Account acc1 = Test_DataFactory.createOneLargeStandardAccount();
            acc1.ParentId = kundkonto.Id;
            insertAccountList.add(acc1);
            Account acc2 = Test_DataFactory.createOneLargeStandardAccount();
            acc2.Parentid = Kundkonto.Id;
            insertAccountList.add(acc2);
            insert insertAccountList;
            orgNr = insertAccountList[0];
            otherOrgNr = insertAccountList[1];
            csNMC = new Case(recordtypeId = SEUtility.getrecordtypeid('Enterprise'),accountId = orgNR.Id);
            insert csNMC;
            LIST<Case> csTest1 = [SELECT Id,Named_Sales_Coordinator__c,AccountId,Account.ParentId,Account.Parent.Named_Sales_Coordinator__c FROM CASE WHERE Id =: csNMC.Id LIMIT 1];
            system.debug('case test'+ csTest1[0]);
            system.debug('case test 1' + csTest1[0].Named_Sales_Coordinator__c);
            system.debug('case test 2' + csTest1[0].Account.ParentId);
            system.debug('case test 3' + csTest1[0].Account.Parent.Named_Sales_Coordinator__c);
            system.assertequals(csTest1[0].Named_Sales_Coordinator__c,testUser.Id);
            Kundkonto.Named_Sales_Coordinator__c = NULL;
            update Kundkonto;
            LIST<Case> csTest2 = [SELECT Id,Named_Sales_Coordinator__c FROM CASE WHERE Id =: csNMC.Id LIMIT 1];
            system.assertequals(csTest2[0].Named_Sales_Coordinator__c,NULL);
            Kundkonto.Named_Sales_Coordinator__c = testUser.Id;
            update Kundkonto;
            LIST<Case> csTest3 = [SELECT Id,Named_Sales_Coordinator__c FROM CASE WHERE Id =: csNMC.Id LIMIT 1];
            system.assertequals(csTest3[0].Named_Sales_Coordinator__c,testUser.Id);
            csNMC.AccountId = NULL;
            update csNMC;
            csNMC.AccountId = otherOrgNr.Id;
            update csNMC;
            Test.StopTest();
        }
    }
    @isTest static void addOneCygateServiceManagerToOrgAccount(){
        
        List<User> cygateUsers = createCygateUsers(3);
        Account kundKonto;
        List<Account> orgAccounts;
        contact c = new contact();
        System.runAs(new User(Id = Userinfo.getUserId())){
            insert cygateUsers;
            user SMu = cygateusers[0];
            
            kundKonto = Test_DataFactory.createOneKundkontoAccount();
            insert kundKonto;
            //(Id cygateAccountOwnerId, Id cygManagerId, Id kundkontoId, Integer n)
            orgAccounts = createCygateOrgAccounts(cygateUsers[1].Id, null, kundKonto.Id,2);
            for(Account a : orgAccounts) a.OwnerId = cygateUsers[1].Id;
            insert orgAccounts;
            Account orgAcc1 = orgAccounts[0];
            string conrectype = SEUtility.CONTACT_RECTYPE_CYGATE_USER;
            
            List<account> acclist = [SELECT Id,Org_Nr__C FROM Account WHERE Org_Nr__c = '5565498952'];                     
            c = Test_DataFactory.createOneContact();
            c.AccountId = accList[0].Id;
            c.recordTypeId = SEUtility.getRecordTypeId(conrectype);
            c.Cygate_User__c = SMu.Id;
            c.Title = 'Service Manager';
            insert c;
            
            orgAcc1.Cygate_Service_Manager__c = c.Id;
            update orgAcc1;
        }
        
        // cygateUsers[0] is CygateChefUser
        System.runAs(cygateUsers[1]){
            orgAccounts[0].Cygate_Service_Manager__c = c.Id;
            update orgAccounts[0];
        }
        
        Account kundKontoAfter = [SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts),
                                  (SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :AccountTriggerHandler.ACCOUNT_TEAM_MEMBER_ROLE_SERVICE_MANAGER)
                                  FROM Account WHERE Id = :kundKonto.Id];
        // System.assertEquals(kundKontoAfter.AccountTeamMembers.size(), 1, 'Exactly One Account Team Member record should have been created for the Cygate Service manager added to the org account.');
        // System.assertEquals(kundKontoAfter.AccountTeamMembers[0].UserId, cygateUsers[2].Id, 'No Account Team Member has been created for the Cygate Service manager added to the org account.');
    }
    
    /*
//N.G - SAEN- 1838, 1826
static testMethod void testupdateMarketingMailsOptOut(){
string accChildRecTypeID    =  [select id,developername from recordtype where developername = 'Large_Sales_Organisation_Account'].id;
string accParentRecTypeID    = [select id,developername from recordtype where developername = 'Kundkonto_S_k_2'].id;
system.debug('*****accParentRecTypeID*******'+accParentRecTypeID);
BypassAccValidation__c tempSkipValidation = BypassAccValidation__c.getInstance();
if(tempSkipValidation == null) {
tempSkipValidation = new BypassAccValidation__c();
}
tempSkipValidation.BypassValidation__c  = true;
upsert tempSkipValidation ;

BypassConValidation__c tempSkipConValidation = BypassConValidation__c.getInstance();
if(tempSkipConValidation == null) {
tempSkipConValidation = new BypassConValidation__c();
}
tempSkipConValidation.BypassValidationContact__c  = true;
upsert tempSkipConValidation ;
//Create Parent Account
Account acc = Test_DataFactory.createOneAccount();
acc.recordtypeID =  accParentRecTypeID;
acc.Marketing_Mails_Opt_Out__c = 'Upon Client request';
//Test_DataFactory.autoNumber += 1;
acc.Kundkonto_Nr__c = 'abc' + '0';
insert acc;
//Create child Account
Account childAcc = Test_DataFactory.createOneAccount();
childAcc.recordtypeID = accChildRecTypeID;
childAcc.parentID = acc.ID;
childAcc.Marketing_Mails_Opt_Out__c  = null;
insert childAcc;
//Create child Contact
Contact con = Test_DataFactory.createOneContact();
con.AccountId  = childAcc.id;
con.Marketing_Mails_Opt_Out_Contact__c = null;
insert con;
acc.Marketing_Mails_Opt_Out__c = 'According to agreement';
update acc;
string childAccMoof = [SELECT Marketing_Mails_Opt_Out__c from ACCOUNT where id =: childAcc.id].Marketing_Mails_Opt_Out__c;
system.assertEquals('According to agreement',childAccMoof);
string childConMoof = [SELECT Marketing_Mails_Opt_Out_Contact__c from CONTACT where id =: con.id].Marketing_Mails_Opt_Out_Contact__c;
system.assertEquals('According to agreement',childConMoof);
tempSkipValidation.BypassValidation__c  = false;
update tempSkipValidation;  
tempSkipConValidation.BypassValidationContact__c  = false;
upsert tempSkipConValidation ;
}
static testMethod void testupdateMarketingMailsOptOut1(){
string accChildRecTypeID    =  [select id,developername from recordtype where developername = 'Large_Sales_Organisation_Account'].id;
string accParentRecTypeID    = [select id,developername from recordtype where developername = 'Kundkonto_S_k_2'].id;
system.debug('*****accParentRecTypeID*******'+accParentRecTypeID);
BypassAccValidation__c tempSkipValidation = BypassAccValidation__c.getInstance();
if(tempSkipValidation == null) {
tempSkipValidation = new BypassAccValidation__c();
}
tempSkipValidation.BypassValidation__c  = true;
upsert tempSkipValidation ;

BypassConValidation__c tempSkipConValidation = BypassConValidation__c.getInstance();
if(tempSkipConValidation == null) {
tempSkipConValidation = new BypassConValidation__c();
}
tempSkipConValidation.BypassValidationContact__c  = true;
upsert tempSkipConValidation ;
//Create Parent Account
Account acc = Test_DataFactory.createOneAccount();
acc.recordtypeID =  accParentRecTypeID;
acc.Marketing_Mails_Opt_Out__c = 'Upon Client request';
//Test_DataFactory.autoNumber += 1;
acc.Kundkonto_Nr__c = 'abc' + '0';
insert acc;

//Create child Account
Account childAcc = Test_DataFactory.createOneAccount();
childAcc.recordtypeID = accChildRecTypeID;
childAcc.parentID = acc.ID;
childAcc.Manual_Update__c = true;
childAcc.Marketing_Mails_Opt_Out__c  = 'Upon Client request';
insert childAcc;

//Create child Contact
Contact con = Test_DataFactory.createOneContact();
con.AccountId  = childAcc.id;
con.Manual_Update_Contact__c = true;
con.Marketing_Mails_Opt_Out_Contact__c = null;
insert con;

acc.Marketing_Mails_Opt_Out__c = 'According to agreement';
update acc;

string childAccMoof = [SELECT Marketing_Mails_Opt_Out__c from ACCOUNT where id =: childAcc.id].Marketing_Mails_Opt_Out__c;
system.assertEquals('According to agreement',childAccMoof);

string childConMoof = [SELECT Marketing_Mails_Opt_Out_Contact__c from CONTACT where id =: con.id].Marketing_Mails_Opt_Out_Contact__c;
system.assertEquals('According to agreement',childConMoof);

tempSkipValidation.BypassValidation__c  = false;
update tempSkipValidation;  
tempSkipConValidation.BypassValidationContact__c  = false;
upsert tempSkipConValidation ;
}
static testMethod void testupdateMarketingMailsOptOut2(){
string accChildRecTypeID    =  [select id,developername from recordtype where developername = 'Large_Sales_Organisation_Account'].id;
string accParentRecTypeID    = [select id,developername from recordtype where developername = 'Kundkonto_S_k_2'].id;
system.debug('*****accParentRecTypeID*******'+accParentRecTypeID);
BypassAccValidation__c tempSkipValidation = BypassAccValidation__c.getInstance();
if(tempSkipValidation == null) {
tempSkipValidation = new BypassAccValidation__c();
}
tempSkipValidation.BypassValidation__c  = true;
upsert tempSkipValidation ;
BypassConValidation__c tempSkipConValidation = BypassConValidation__c.getInstance();
if(tempSkipConValidation == null) {
tempSkipConValidation = new BypassConValidation__c();
}
tempSkipConValidation.BypassValidationContact__c  = true;
upsert tempSkipConValidation ;

//Create Parent Account
Account acc = Test_DataFactory.createOneAccount();
acc.recordtypeID =  accParentRecTypeID;
acc.Marketing_Mails_Opt_Out__c = 'Upon Client request';
//Test_DataFactory.autoNumber += 1;
acc.Kundkonto_Nr__c = 'abc' + '0';
insert acc;

//Create child Account
Account childAcc = Test_DataFactory.createOneAccount();
childAcc.recordtypeID = accChildRecTypeID;
childAcc.parentID = acc.ID;
childAcc.Date_Manually_Updated__c = true;
childAcc.Marketing_Mails_Opt_Out__c  = 'Upon Client request';
insert childAcc;

//Create child Contact
Contact con = Test_DataFactory.createOneContact();
con.AccountId  = childAcc.id;
con.Marketing_Mails_Opt_Out_Contact__c = null;
insert con;

acc.Marketing_Mails_Opt_Out__c = 'According to agreement';
acc.From_date__c = date.today();
acc.To_date__c = date.today().addDays(4);
update acc;

string childAccMoof = [SELECT Marketing_Mails_Opt_Out__c from ACCOUNT where id =: childAcc.id].Marketing_Mails_Opt_Out__c;
system.assertEquals('According to agreement',childAccMoof);

string childConMoof = [SELECT Marketing_Mails_Opt_Out_Contact__c from CONTACT where id =: con.id].Marketing_Mails_Opt_Out_Contact__c;
system.assertEquals('According to agreement',childConMoof);

tempSkipValidation.BypassValidation__c  = false;
update tempSkipValidation;  
tempSkipConValidation.BypassValidationContact__c  = false;
upsert tempSkipConValidation ;

}
static testMethod void testupdateMarketingMailsOptOut3(){
string accChildRecTypeID    =  [select id,developername from recordtype where developername = 'Large_Sales_Organisation_Account'].id;
string accParentRecTypeID    = [select id,developername from recordtype where developername = 'Kundkonto_S_k_2'].id;
system.debug('*****accParentRecTypeID*******'+accParentRecTypeID);
BypassAccValidation__c tempSkipValidation = BypassAccValidation__c.getInstance();
if(tempSkipValidation == null) {
tempSkipValidation = new BypassAccValidation__c();
}
tempSkipValidation.BypassValidation__c  = true;
upsert tempSkipValidation ;

BypassConValidation__c tempSkipConValidation = BypassConValidation__c.getInstance();
if(tempSkipConValidation == null) {
tempSkipConValidation = new BypassConValidation__c();
}
tempSkipConValidation.BypassValidationContact__c  = true;
upsert tempSkipConValidation ;
//Create Parent Account
Account acc = Test_DataFactory.createOneAccount();
acc.recordtypeID =  accParentRecTypeID;
acc.Marketing_Mails_Opt_Out__c = 'Upon Client request';
//Test_DataFactory.autoNumber += 1;
acc.Kundkonto_Nr__c = 'abc' + '0';
insert acc;
//Create child Account
Account childAcc = Test_DataFactory.createOneAccount();
childAcc.recordtypeID = accChildRecTypeID;
childAcc.parentID = acc.ID;
insert childAcc;
system.debug('*****childAcc***test***'+childAcc);
//Create child Contact
Contact con = Test_DataFactory.createOneContact();
con.AccountId  = childAcc.id;
con.Marketing_Mails_Opt_Out_Contact__c = null;
insert con;
acc.Marketing_Mails_Opt_Out__c = 'According to agreement';
acc.From_date__c = date.today();
acc.To_date__c = date.today().addDays(4);
update acc;
string childAccMoof = [SELECT Marketing_Mails_Opt_Out__c from ACCOUNT where id =: childAcc.id].Marketing_Mails_Opt_Out__c;
system.assertEquals('According to agreement',childAccMoof);
string childConMoof = [SELECT Marketing_Mails_Opt_Out_Contact__c from CONTACT where id =: con.id].Marketing_Mails_Opt_Out_Contact__c;
system.assertEquals('According to agreement',childConMoof);
tempSkipValidation.BypassValidation__c  = false;
update tempSkipValidation;  
tempSkipConValidation.BypassValidationContact__c  = false;
upsert tempSkipConValidation ;
} */
    @IsTest
    private static void setExistingCustomer_True_Test() {
        //Retrieving Record Type
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Sales_Organisation_Account'].id;
        //Inserting Parent account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        acc1.Existing_Customer__c = false;
        insert acc1;
        //Inserting Child accounts
        List<Account> acc = Test_DataFactory.createAccounts(2);
        acc[0].recordTypeId = childAccRecordTypeId;
        acc[1].recordTypeId = childAccRecordTypeId;
        acc[0].ParentId = acc1.Id;
        acc[1].ParentId = acc1.Id;
        acc[0].Existing_Customer__c = false;
        acc[1].Existing_Customer__c = false;
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
        }
        
        Test.startTest();
        acc[0].Existing_Customer__c = true;
        update acc;
        List<Account> parentAccount = [SELECT Id, Existing_Customer__c FROM Account WHERE Id =: acc1.Id LIMIT 1];
        Test.stopTest();        
        System.assertEquals(true, parentAccount[0].Existing_Customer__c);
    }
    @IsTest
    private static void setExistingCustomer_False_Test() {
        //Retrieving Record Type
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Sales_Organisation_Account'].id;
        //Inserting Parent Account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        acc1.Existing_Customer__c = true;
        insert acc1;
        //Inserting Child accounts
        List<Account> acc = Test_DataFactory.createAccounts(2);
        acc[0].recordTypeId = childAccRecordTypeId;
        acc[1].recordTypeId = childAccRecordTypeId;
        acc[0].ParentId = acc1.Id;
        acc[1].ParentId = acc1.Id;
        acc[0].Existing_Customer__c = true;
        acc[1].Existing_Customer__c = false;
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
        }
        
        Test.startTest();
        acc[0].Existing_Customer__c = false;
        update acc;
        List<Account> parentAccount = [SELECT Id, Existing_Customer__c FROM Account WHERE Id =: acc1.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals(false, parentAccount[0].Existing_Customer__c);
    }
    @IsTest
    private static void setExistingCustomer_AccDeleted_Test() {
        //Retrieving Record Types
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Sales_Organisation_Account'].id;
        //Inserting Parent Account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        acc1.Existing_Customer__c = true;
        insert acc1;
        //Inserting Child accounts
        List<Account> acc = Test_DataFactory.createAccounts(2);
        acc[0].recordTypeId = childAccRecordTypeId;
        acc[1].recordTypeId = childAccRecordTypeId;
        acc[0].ParentId = acc1.Id;
        acc[1].ParentId = acc1.Id;
        acc[0].Existing_Customer__c = true;
        acc[1].Existing_Customer__c = false;
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
        }
        
        Test.startTest();
        delete acc[0];
        List<Account> parentAccount = [SELECT Id, Existing_Customer__c FROM Account WHERE Id =: acc1.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals(false, parentAccount[0].Existing_Customer__c);
    }
    @IsTest
    private static void setExistingCustomer_AccUndeleted_Test() {
        //Retrieving Record Types
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Sales_Organisation_Account'].id;
        //Inserting Parent Account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        insert acc1;
        //Inserting Child accounts
        List<Account> acc = Test_DataFactory.createAccounts(2);
        acc[0].recordTypeId = childAccRecordTypeId;
        acc[1].recordTypeId = childAccRecordTypeId;
        acc[0].ParentId = acc1.Id;
        acc[1].ParentId = acc1.Id;
        acc[0].Existing_Customer__c = true;
        acc[1].Existing_Customer__c = false;
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
            delete acc[0];
        }
        
        Test.startTest();
        undelete acc[0];
        List<Account> parentAccount = [SELECT Id, Existing_Customer__c FROM Account WHERE Id =: acc1.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals(true, parentAccount[0].Existing_Customer__c);
    }

    /**
     * @Description:
     * Test updateLarmlistanDataFields() parent KKNRs Larmlistan (Convergence) fields'
     * updates during child SME Account insertions.
     * @author Rimgaudas Urbonas
     * @Modifications:
     * 19.05.2023 [TB] LTAT-9938 - Number_of_Convergence_areas field added.
     * 19.01.2023 [NS] SALEF-7940 - Customer_Classification field added. 
     * 21.01.2022 [RU] SALEF-5805 - Introduced. 
     **/
    @IsTest
    private static void updateLarmlistanDataFieldsInsertTest() {
        Integer NUM_OF_CONVERGENCE_AREAS_VAL = 2;  
        //Retrieving Record Types
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Sales_Organisation_Account'].id;
        //Inserting Parent Account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        insert acc1;
        Test.startTest();
        //Inserting Child accounts
        List<Account> acc = Test_DataFactory.createAccounts(1);
        acc[0].recordTypeId = childAccRecordTypeId;
        acc[0].ParentId = acc1.Id;
        acc[0].Mobile__c = true;
        acc[0].Connection__c = true;
        acc[0].Switch__c = true;
        acc[0].IT__c = true;
        acc[0].Applications__c = true;
        acc[0].Customer_Classification__c = 'A-Customer';
        acc[0].Number_of_Convergence_areas__c = NUM_OF_CONVERGENCE_AREAS_VAL;
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
        }
        Test.stopTest();
        Account parentAccount = [SELECT Mobile__c,Connection__c,Switch__c,IT__c,Applications__c, Customer_Classification__c, Number_of_Convergence_areas__c FROM Account WHERE Id =: acc1.Id LIMIT 1];
        System.assertEquals(true, parentAccount.Mobile__c);
        System.assertEquals(true, parentAccount.Connection__c);
        System.assertEquals(true, parentAccount.Switch__c);
        System.assertEquals(true, parentAccount.IT__c);
        System.assertEquals(true, parentAccount.Applications__c);
        System.assertEquals('A-Customer', parentAccount.Customer_Classification__c);
        System.assertEquals(NUM_OF_CONVERGENCE_AREAS_VAL, parentAccount.Number_of_Convergence_areas__c);
    }

    /**
     * @Description:
     * Test updateLarmlistanDataFields() parent KKNRs Larmlistan (Convergence) fields'
     * updates during child SME Account deletions.
     * @author Rimgaudas Urbonas
     * @Modifications:
     * 19.05.2023 [TB] LTAT-9938 - Number_of_Convergence_areas field added.
     * 19.01.2023 [NS] SALEF-7940 - Customer_Classification field added. 
     * 21.01.2022 [RU] SALEF-5805 - Introduced. 
     **/
    @IsTest
    private static void updateLarmlistanDataFieldsDeleteTest() {
        Integer NUM_OF_CONVERGENCE_AREAS_VAL = 2;
        //Retrieving Record Types
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Sales_Organisation_Account'].id;
        //Inserting Parent Account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        insert acc1;
        Test.startTest();
        //Inserting Child accounts
        List<Account> acc = Test_DataFactory.createAccounts(1);
        acc[0].recordTypeId = childAccRecordTypeId;
        acc[0].ParentId = acc1.Id;
        acc[0].Mobile__c = true;
        acc[0].Connection__c = true;
        acc[0].Switch__c = true;
        acc[0].IT__c = true;
        acc[0].Applications__c = true;
        acc[0].Customer_Classification__c = 'A-Customer';
        acc[0].Number_of_Convergence_areas__c = NUM_OF_CONVERGENCE_AREAS_VAL;
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
            delete acc;
        }
        Test.stopTest();
        Account parentAccount = [SELECT Mobile__c,Connection__c,Switch__c,IT__c,Applications__c, Customer_Classification__c, Number_of_Convergence_areas__c FROM Account WHERE Id =: acc1.Id LIMIT 1];
        System.assertEquals(false, parentAccount.Mobile__c);
        System.assertEquals(false, parentAccount.Connection__c);
        System.assertEquals(false, parentAccount.Switch__c);
        System.assertEquals(false, parentAccount.IT__c);
        System.assertEquals(false, parentAccount.Applications__c);
        System.assertEquals(null, parentAccount.Customer_Classification__c);
        System.assertEquals(null, parentAccount.Number_of_Convergence_areas__c);
    }

    /**
     * @Description:
     * Test updateLarmlistanDataFields() parent KKNRs Larmlistan (Convergence) fields'
     * updates during child SME Account undeletions.
     * @author Rimgaudas Urbonas
     * @Modifications:
     * 19.05.2023 [TB] LTAT-9938 - Number_of_Convergence_areas field added.
     * 19.01.2023 [NS] SALEF-7940 - Customer_Classification field added. 
     * 21.01.2022 [RU] SALEF-5805 - Introduced. 
     **/
    @IsTest
    private static void updateLarmlistanDataFieldsUndeleteTest() {
        Integer NUM_OF_CONVERGENCE_AREAS_VAL = 2;
        //Retrieving Record Types
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Sales_Organisation_Account'].id;
        //Inserting Parent Account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        insert acc1;
        Test.startTest();
        //Inserting Child accounts
        List<Account> acc = Test_DataFactory.createAccounts(1);
        acc[0].recordTypeId = childAccRecordTypeId;
        acc[0].ParentId = acc1.Id;
        acc[0].Mobile__c = true;
        acc[0].Connection__c = true;
        acc[0].Switch__c = true;
        acc[0].IT__c = true;
        acc[0].Applications__c = true;
        acc[0].Customer_Classification__c = 'A-Customer';
        acc[0].Number_of_Convergence_areas__c = NUM_OF_CONVERGENCE_AREAS_VAL;
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
            delete acc;
            undelete acc;
        }
        Test.stopTest();
        Account parentAccount = [SELECT Mobile__c,Connection__c,Switch__c,IT__c,Applications__c, Customer_Classification__c, Number_of_Convergence_areas__c FROM Account WHERE Id =: acc1.Id LIMIT 1];
        System.assertEquals(true, parentAccount.Mobile__c);
        System.assertEquals(true, parentAccount.Connection__c);
        System.assertEquals(true, parentAccount.Switch__c);
        System.assertEquals(true, parentAccount.IT__c);
        System.assertEquals(true, parentAccount.Applications__c);
        System.assertEquals('A-Customer', parentAccount.Customer_Classification__c);
        System.assertEquals(NUM_OF_CONVERGENCE_AREAS_VAL, parentAccount.Number_of_Convergence_areas__c);
    }

    /**
     * @Description:
     * Test updateLarmlistanDataFields() parent KKNRs Larmlistan (Convergence) fields'
     * updates during child SME Account updates.
     * @author Rimgaudas Urbonas
     * @Modifications:
     * 19.05.2023 [TB] LTAT-9938 - Number_of_Convergence_areas field added.
     * 19.01.2023 [NS] SALEF-7940 - Customer_Classification field added. 
     * 21.01.2022 [RU] SALEF-5805 - Introduced. 
     **/
    @IsTest
    private static void updateLarmlistanDataFieldsUpdateTest() {
        Integer NUM_OF_CONVERGENCE_AREAS_VAL = 2;
        //Retrieving Record Types
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Sales_Organisation_Account'].id;
        //Inserting Parent Account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        insert acc1;
        
        //Inserting Child accounts
        List<Account> acc = Test_DataFactory.createAccounts(1);
        acc[0].recordTypeId = childAccRecordTypeId;
        acc[0].ParentId = acc1.Id;
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
        }
        Test.startTest();
        Account childAccount = [SELECT Mobile__c,Connection__c,Switch__c,IT__c,Applications__c, Customer_Classification__c, Number_of_Convergence_areas__c FROM Account WHERE ParentId =: acc1.Id LIMIT 1];
        childAccount.Mobile__c = true;
        childAccount.Connection__c = true;
        childAccount.Switch__c = true;
        childAccount.IT__c = true;
        childAccount.Applications__c = true;
        childAccount.Customer_Classification__c = 'A-Customer';
        childAccount.Number_of_Convergence_areas__c = NUM_OF_CONVERGENCE_AREAS_VAL;
        update childAccount;
        Test.stopTest();
        Account parentAccount = [SELECT Mobile__c,Connection__c,Switch__c,IT__c,Applications__c, Customer_Classification__c, Number_of_Convergence_areas__c FROM Account WHERE Id =: acc1.Id LIMIT 1];
        System.assertEquals(true, parentAccount.Mobile__c);
        System.assertEquals(true, parentAccount.Connection__c);
        System.assertEquals(true, parentAccount.Switch__c);
        System.assertEquals(true, parentAccount.IT__c);
        System.assertEquals(true, parentAccount.Applications__c);
        System.assertEquals('A-Customer', parentAccount.Customer_Classification__c);
        System.assertEquals(NUM_OF_CONVERGENCE_AREAS_VAL, parentAccount.Number_of_Convergence_areas__c);
    }

    // Bellow has been commented out as per SALEF-4207
    //    static testMethod void testSetParentAccountCurrentCustomer(){
    //
    //        System.runAs(new User(Id = Userinfo.getUserId())){
    //            string accChildRecTypeID    =  [select id,developername from recordtype where developername = 'Sales_Aggregation_Account'].id;
    //            string accParentRecTypeID    = [select id,developername from recordtype where developername = 'Sales_Organisation_Account'].id;
    //            system.debug('*****accParentRecTypeID*******'+accParentRecTypeID);
    //
    //
    ////Create Parent Account
    //            Account acc1 = Test_DataFactory.createOneAccount();
    //            acc1.recordtypeID =  accParentRecTypeID;
    //            insert acc1;
    //
    //
    ////Create Parent Account
    //            Account acc2 = Test_DataFactory.createOneAccount();
    //            acc2.recordtypeID =  accParentRecTypeID;
    //            insert acc2;
    //
    //            List<Account> acc = Test_DataFactory.createAccounts(2);
    //            acc[0].recordtypeID =  accParentRecTypeID;
    //            acc[1].recordtypeID =  accParentRecTypeID;
    //            insert acc;
    //
    //            Map<id,Account> oldMap = new Map<id,Account>();
    //            oldMap.put(acc[0].id,acc[0]);
    //            oldMap.put(acc[1].id,acc[1]);
    //            test.starttest();
    ////Create child Account
    //            Account childAcc = Test_DataFactory.createOneAccount();
    //            childAcc.recordtypeID = accChildRecTypeID;
    //            childAcc.parentID = acc[0].ID;
    //            childAcc.Bearbetas_ej__c = true;
    //            insert childAcc;
    //            system.debug('*****childAcc***test***'+childAcc);
    //
    ////Create child Account
    //            Account childAcc2 = Test_DataFactory.createOneAccount();
    //            childAcc2.recordtypeID = accChildRecTypeID;
    //            childAcc2.parentID = acc[1].ID;
    //            childAcc2.Bearbetas_ej__c = true;
    //            insert childAcc2;
    //            system.debug('*****childAcc2***test***'+childAcc);
    //
    ////Create Mobile Subscriptions
    //            List<Mobile_Subscription__c> sub = Test_DataFactory.createMobileSubscriptions(12);
    //            for(integer i=0; i<12; i++)
    //                sub[i].Account__c= childAcc.id;
    //
    ////Create Mobile Subscriptions
    //            List<Mobile_Subscription__c> sub2 = Test_DataFactory.createMobileSubscriptions(1);
    //            sub2[0].Account__c = childAcc2.id;
    //
    ////Create Parent Account with no child account recpords
    //            Account acc3 = Test_DataFactory.createOneAccount();
    //            acc3.recordtypeID =  accParentRecTypeID;
    //            insert acc3;
    //
    ////AccountTriggerHandler.setParentAccountCurrentCustomer(acc,oldMap);
    //            test.stoptest();
    //        }
    //    }
    @isTest public static void CaseAccessAccOwnerMethod(){
        //This method also covers the functionality of method- updateServiceManager()
       Id caseEntrepriseRCtype = Schema.SObjectType.case.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();

        Account kundkonto;
        
        account acc;
        List<User> largeUserTeam = new List<User>();
        Opportunity opp;
        case c = new case();
         c.recordTypeId = caseEntrepriseRCtype;
        seller__c seller = new Seller__c();
        seller__c seller1 = new Seller__c();
        List<Seller__c> sellerList = new list<Seller__c>();
        largeUserTeam = Test_DataFactory.createLargeUserTeam(4);
        user largeUser = largeUserteam[0];
        user largeuser1 = largeuserteam[1];
        user largeuser2 = largeUserteam[2];
        user largeuser3 = largeUserteam[3];
         Id accKundokRct = Schema.SObjectType.account.getRecordTypeInfosByName().get('Kundkonto').getRecordTypeId();

        test.starttest();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Account parent;
            kundKonto = Test_DataFactory.createOneKundkontoAccount();
            kundKonto.Telia_Service_Manager__c = largeUser3.Id;
            kundKonto.LifeCycle_Manager__c = largeUser2.Id;
            kundKonto.Change_Manager__c = largeUser1.Id;
            
            insert kundKonto;
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = largeUser.Id;
            acc.parentID = kundKonto.Id;
            acc.Telia_Service_Manager__c = largeUser1.Id;
            acc.LifeCycle_Manager__c = largeUser2.Id;
            acc.Change_Manager__c = largeUser3.Id;
           
             acc.RecordTypeId =accKundokRct;
            insert acc;
            
             List<AccountTeamMember> atms_child = new List<AccountTeamMember>();
            AccountTeamMember atm_a1c = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Specialist Cygate Sales', UserId =largeUser1.Id);
            atms_child.add(atm_a1c);
            insert atms_child;
            
            seller = Test_DataFactory.createSeller(largeuser.Id, null);
            seller1 = Test_DataFactory.createSeller(largeuser2.Id, null);
            sellerList.add(seller);
            sellerList.add(seller1);
            insert sellerList;
            c.subject = 'test subject case';
            c.Accountid = acc.id;            
            insert c;            
            // system.runAs(largeuser){
            kundKonto.Telia_Service_Manager__c = largeUser.Id;
            kundKonto.LifeCycle_Manager__c = largeUser1.Id;
            kundKonto.Change_Manager__c = null;            
            update kundKonto;
            acc.ownerId = largeUser2.Id;
            acc.Telia_Service_Manager__c = largeUser2.Id;
            acc.LifeCycle_Manager__c = largeUser1.Id;
            update acc;            
            test.stoptest();
        }                
    }    
    
    @isTest public static void CustomerSegmentMethod(){      
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            test.starttest();
            List<Account> AccountPList = new List<Account>();
            List<Account> AccountList = new List<Account>();
            Account acc1 = Test_DataFactory.SegmentedKKnrAccount();
            acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);            
            Account acc2 = Test_DataFactory.SegmentedKKnrAccount();
            acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);            
            Account acc3 = Test_DataFactory.SegmentedKKnrAccount();
            acc3.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
            AccountPList.add(acc1);
            AccountPList.add(acc2);
            AccountPList.add(acc3);
            insert AccountPList;
            
            acc1.Suggested_Business_Sales_Unit__c = 'Enterprise Large';
            acc1.Suggested_Sales_Unit__c = 'Regional Account';
            acc1.Suggested_Sales_Team__c ='Large RA Large';
            acc1.Approved__c=true;
            
            update acc1;
            Account accCh1 = Test_DataFactory.createOneAccount();
            accCh1.Org_Nr__c='5565656565';
            AccountList.add(accCh1);
            Account accCh2 = Test_DataFactory.createOneAccount();
            accCh2.Org_Nr__c='5565656445';
            //accCh2.Marketing_Mails_Opt_Out_Cygate__c='According to agreement';
            accCh2.Telia_Engaged__c=true;
            AccountList.add(accCh2);
            Id accSmeSohoRCtype = Schema.SObjectType.account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
            Account accCh4 = Test_DataFactory.createOneAccount();
            accCh4.RecordTypeId= accSmeSohoRCtype;//'012240000008l9Y';
            accCh4.Org_Nr__c='5565656511';
            accCh4.Contacted__c = System.today();
            accCh4.SME_Contacted_MyBusiness__c = System.today();
            accCh4.ParentId=acc1.Id;
            AccountList.add(accCh4);        
            insert AccountList;           
            accCh2.Marketing_Mails_Opt_Out_Cygate__c='According to agreement';
            accCh2.Marketing_Mails_Opt_Out__c='According to agreement';
            update accCh2;            
            accCh2.Marketing_Mails_Opt_Out_Cygate__c=null;
            accCh2.Marketing_Mails_Opt_Out__c=null;
            update accCh2;            
            delete accCh4;
            undelete accCh4;
            List<Account> updateAccount = new List<Account>();
            accCh1.Suggested_Parent__c= acc2.Id;
            accCh1.Approved__c=true;
            updateAccount.add(accCh1);
            update updateAccount;
            test.stoptest();
        }
    }
    /**
    * @Description:
    * Test updateParentAccountContactedDate() method.
    * Verify that the 'SME/SOHO Organisation' Account parent Account's 'Contacted...' dates get
    * updated correctly upon the 'SME/SOHO Organisation' Account 'Contacted...' field updates.
    * @Modifications:
    * 05.01.2023 [TB] SALEF-7949 - Introduced.
    **/
    @isTest
    public static void updateParentAccountContactedDateTest(){
        User byPassUser = Test_DataFactory.getByPassUser();
        System.runAs(byPassUser) {
            Account oneKundkontoAccount = Test_DataFactory.createOneKundkontoAccount();
            insert oneKundkontoAccount;
            oneKundkontoAccount.Kundkonto_Nr__c = 'Z101';
            Update oneKundkontoAccount;
            Account smeAccountTest = Test_DataFactory.createOneSMEAccount();
            smeAccountTest.ParentId = oneKundkontoAccount.Id;
            insert smeAccountTest;
            // Update 'SME/SOHO Organisation' Account 'Contacted...' fields
            Test.startTest();
            smeAccountTest.Contacted__c = System.today();
            smeAccountTest.SME_Contacted_MyBusiness__c = System.today();
            smeAccountTest.Contacted_Quality_Meeting__c = System.today();
            update smeAccountTest;
            Test.stopTest();

            // Verify that the parent Account of the 'SME/SOHO Organisation' Account has had
            // its 'Contacted...' fields updated, as the parent neither has any other child Account nor
            // does it have a 'Contacted...' field value previously set to a more recent date
            List<Account> lstParentAccounts = [ SELECT Id, Contacted__c, SME_Contacted_MyBusiness__c, Contacted_Quality_Meeting__c
            FROM Account
            WHERE ID = :smeAccountTest.ParentId];
            System.assertEquals(smeAccountTest.Contacted__c, lstParentAccounts[0].Contacted__c,
                    '\'SME/SOHO Organisation\' Account parent Account \'Contacted\' date should have been updated.');
            System.assertEquals(smeAccountTest.Contacted_Quality_Meeting__c, lstParentAccounts[0].Contacted_Quality_Meeting__c,
                    '\'SME/SOHO Organisation\' Account parent Account \'Contacted Quality Meeting\' date should have been updated.');
        }
    }

    @IsTest
    Public static void testUpdateCygateAccountManagerOnLeadContact() {
        User user2;
        System.runAs(Test_DataFactory.createAdminUser()) {
            User user1 = Test_DataFactory.createCygateUser();
            user1.FirstName = 'Testcygate1';
            user1.LastName = 'User';
            user1.username = 'theusertesting.cygate12@test.test';
            insert user1;
            user2 = Test_DataFactory.createCygateUser();
            user2.FirstName = 'Fakeusercygate2';
            user2.LastName = 'Test';
            user2.Username = 'usertesting.cygate1@test.test.test';
            insert user2;

            Account account1 = Test_DataFactory.createOneCygateAccount();
            account1.Cygate_Account_Manager__c = user1.Id;
            account1.Name = 'testCygateAccount';
            insert account1;

            Contact contact1 = Test_DataFactory.createOneContact();
            contact1.AccountId = account1.Id;
            insert contact1;

            Lead lead1 = Test_DataFactory.createCygateLead();
            lead1.Account__c = account1.Id;
            insert lead1;
        }

        Account account1 = [SELECT Id, Cygate_Account_Manager__c FROM Account WHERE Name = 'testCygateAccount'];

        account1.Cygate_Account_Manager__c = user2.Id;

        Test.startTest();
        update account1;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Cygate_account_manager__c, AccountId FROM Contact WHERE Cygate_account_manager__c = 'Fakeusercygate2 Test'];
        Lead updatedLead = [SELECT Id, Cygate_account_manager__c, Account__c FROM Lead WHERE Cygate_account_manager__c = 'Fakeusercygate2 Test'];

        String cygateAccountManagerName = user2.FirstName + ' ' + user2.LastName;

        System.assertEquals(cygateAccountManagerName, updatedLead.Cygate_account_manager__c, 'Cygate account manager have not been updated for Lead');
        System.assertEquals(cygateAccountManagerName, updatedContact.Cygate_account_manager__c, 'Cygate account manager have not been updated for Contact');
    }

    /**
     * @Description:  
     * Test setUpParentKKNrCustomerSuccessMgrUpdate() method.
     * Verify that the 'Customer_Success_Manager' assignments are prevented when the same 
     * parent KKNr's child 'SME/SOHO Organisation' Accounts are being assigned different
     * CSMs in a single insert operation. 
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    @isTest
    public static void testUpdateParentKKNrCSMgr_ErrorAssignDifferentCSMgrsDuringInsert(){
        User byPassUser = Test_DataFactory.getByPassUser();
        List<User> lstCustomerSuccessMgrs = new List<User>();
        List<Account> lstChildSMEAccounts = new List<Account>();
        System.runAs(byPassUser) {
            // Create two 'SME/SOHO Organisation' Accounts (not inserted) related to the same 
            // parent KKNr and two System Admin Users (inserted)
            helperSetupTestUpdateParentKKNrCSMgr(lstCustomerSuccessMgrs, lstChildSMEAccounts);
            lstChildSMEAccounts[0].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            lstChildSMEAccounts[1].Customer_Success_Manager__c = lstCustomerSuccessMgrs[1].id;
            Test.startTest();
            try{
                insert lstChildSMEAccounts;
                System.assert(false, 
                    'Insertions attempting to assign different Customer_Success_Manager\'s to \'SME/SOHO Organisation\''
                    + ' Accounts sharing a parent KKNr Account should have been disallowed.');
            } catch (Exception e){
                System.assertEquals( StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0),
                    'Expected DML Exception Type: ' + StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
            }
            Test.stopTest();
        }
    }

    /**
     * @Description:  
     * Test setUpParentKKNrCustomerSuccessMgrUpdate() method.
     * Verify that the 'Customer_Success_Manager' assignments are prevented when the same 
     * parent KKNr's child 'SME/SOHO Organisation' Accounts are being assigned different
     * CSMs in a single update operation. 
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    @isTest
    public static void testUpdateParentKKNrCSMgr_ErrorAssignDifferentCSMgrsDuringUpdate(){
        User byPassUser = Test_DataFactory.getByPassUser();
        List<User> lstCustomerSuccessMgrs = new List<User>();
        List<Account> lstChildSMEAccounts = new List<Account>();
        System.runAs(byPassUser) {
            // Create two 'SME/SOHO Organisation' Accounts (not inserted) related to the same 
            // parent KKNr and two System Admin Users (inserted)
            helperSetupTestUpdateParentKKNrCSMgr(lstCustomerSuccessMgrs, lstChildSMEAccounts);
            Test.startTest();
            insert lstChildSMEAccounts;
            try{
                lstChildSMEAccounts[0].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
                lstChildSMEAccounts[1].Customer_Success_Manager__c = lstCustomerSuccessMgrs[1].id;
                update lstChildSMEAccounts;
                System.assert(false, 
                    'Updates attempting to assign different Customer_Success_Manager\'s to \'SME/SOHO Organisation\''
                    + ' Accounts sharing a parent KKNr Account should have been disallowed.');
            } catch (Exception e){
                System.assertEquals( StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0),
                    'Expected DML Exception Type: ' + StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
            }
            Test.stopTest();
        }
    }

    /**
     * @Description:  
     * Test setUpParentKKNrCustomerSuccessMgrUpdate() and
     * updateParentKKNrCustomerSuccessMgr() methods.
     * Verify that a parent KKNr is assigned 'Customer_Success_Manager' when its child
     * 'SME/SOHO Organisation' Accounts are being assigned the same CSM in a single insert
     * operation. 
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    @isTest
    public static void testUpdateParentKKNrCSMgr_SuccessAssignSameCSMgrDuringInsert(){
        User byPassUser = Test_DataFactory.getByPassUser();
        List<User> lstCustomerSuccessMgrs = new List<User>();
        List<Account> lstChildSMEAccounts = new List<Account>();
        System.runAs(byPassUser) {
            // Create two 'SME/SOHO Organisation' Accounts (not inserted) related to the same 
            // parent KKNr and two System Admin Users (inserted)
            helperSetupTestUpdateParentKKNrCSMgr(lstCustomerSuccessMgrs, lstChildSMEAccounts);
            lstChildSMEAccounts[0].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            lstChildSMEAccounts[1].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            Test.startTest();
            try{
                insert lstChildSMEAccounts;
            } catch (Exception e){
                System.assert(false, 
                    'Insertions attempting to assign same Customer_Success_Manager\'s to \'SME/SOHO Organisation\''
                    + ' Accounts sharing a parent KKNr Account should be successful.');
            }
            Test.stopTest();
            List<Account> lstParentKKNr = [ SELECT Id, Customer_Success_Manager__c 
                                            FROM Account
                                            WHERE ID = :lstChildSMEAccounts[0].ParentId];
            System.assertEquals(lstChildSMEAccounts[0].Customer_Success_Manager__c,
                lstParentKKNr[0].Customer_Success_Manager__c,
                'Parent KKNr should have been assigned its child \'SME/SOHO Organisation\''
                + ' Account\'s Customer_Success_Manager upon the latter\'s insertion.');
        }
    }

    /**
     * @Description:  
     * Test setUpParentKKNrCustomerSuccessMgrUpdate() and
     * updateParentKKNrCustomerSuccessMgr() methods.
     * Verify that a parent KKNr is assigned 'Customer_Success_Manager' when its child
     * 'SME/SOHO Organisation' Accounts are being assigned the same CSM in a single update
     * operation. 
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    @isTest
    public static void testUpdateParentKKNrCSMgr_SuccessAssignSameCSMgrDuringUpdate(){
        User byPassUser = Test_DataFactory.getByPassUser();
        List<User> lstCustomerSuccessMgrs = new List<User>();
        List<Account> lstChildSMEAccounts = new List<Account>();
        System.runAs(byPassUser) {
            // Create two 'SME/SOHO Organisation' Accounts (not inserted) related to the same 
            // parent KKNr and two System Admin Users (inserted)
            helperSetupTestUpdateParentKKNrCSMgr(lstCustomerSuccessMgrs, lstChildSMEAccounts);
            Test.startTest();
            insert lstChildSMEAccounts;
            try{
                lstChildSMEAccounts[0].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
                lstChildSMEAccounts[1].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
                update lstChildSMEAccounts;
            } catch (Exception e){
                System.assert(false, 
                    'Updates attempting to assign same Customer_Success_Manager\'s to \'SME/SOHO Organisation\''
                    + ' Accounts sharing a parent KKNr Account should be successful.');
            }
            Test.stopTest();
            List<Account> lstParentKKNr = [ SELECT Id, Customer_Success_Manager__c 
                                            FROM Account
                                            WHERE ID = :lstChildSMEAccounts[0].ParentId];
            System.assertEquals(lstChildSMEAccounts[0].Customer_Success_Manager__c,
                lstParentKKNr[0].Customer_Success_Manager__c,
                'Parent KKNr should have been assigned its child \'SME/SOHO Organisation\''
                + ' Account\'s Customer_Success_Manager upon the latter\'s corresponding field update.');
        }
    }

    /**
     * @Description:  
     * Test setUpParentKKNrCustomerSuccessMgrUpdate() method.
     * Verify that the 'Customer_Success_Manager' assignments are prevented when an
     * 'SME/SOHO Organisation' Account is being assigned a CSM different from the CSM 
     * already assigned to another 'SME/SOHO Organisation' Account related to the same
     * parent KKNr.
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    @isTest
    public static void testUpdateParentKKNrCSMgr_ErrorDifferentCSMgrExistsDuringUpdate(){
        User byPassUser = Test_DataFactory.getByPassUser();
        List<User> lstCustomerSuccessMgrs = new List<User>();
        List<Account> lstChildSMEAccounts = new List<Account>();
        System.runAs(byPassUser) {
            // Create two 'SME/SOHO Organisation' Accounts (not inserted) related to the same 
            // parent KKNr and two System Admin Users (inserted)
            helperSetupTestUpdateParentKKNrCSMgr(lstCustomerSuccessMgrs, lstChildSMEAccounts);
            Test.startTest();
            lstChildSMEAccounts[0].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            lstChildSMEAccounts[1].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            insert lstChildSMEAccounts;
            try{
                lstChildSMEAccounts[1].Customer_Success_Manager__c = lstCustomerSuccessMgrs[1].id;
                update lstChildSMEAccounts[1];
                System.assert(false, 
                    'Updates attempting to assign a \'SME/SOHO Organisation\' Account a Customer_Success_Manager'
                    + ' different from the one already assigned to its sibling Account should have been disallowed.');
            } catch (Exception e){
                System.assertEquals( StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0),
                    'Expected DML Exception Type: ' + StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
            }
            Test.stopTest();
        }
    }

    /**
     * @Description:  
     * Test setUpParentKKNrCustomerSuccessMgrUpdate() and
     * updateParentKKNrCustomerSuccessMgr() methods.
     * Verify that the 'Customer_Success_Manager' assignments are allowed when an
     * 'SME/SOHO Organisation' Account is being assigned a CSM that has already
     * been assigned to another 'SME/SOHO Organisation' Account related to the same
     * parent KKNr.
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    @isTest
    public static void testUpdateParentKKNrCSMgr_SuccessSiblingWithSameCSMgrExistsDuringUpdate(){
        User byPassUser = Test_DataFactory.getByPassUser();
        List<User> lstCustomerSuccessMgrs = new List<User>();
        List<Account> lstChildSMEAccounts = new List<Account>();
        System.runAs(byPassUser) {
            // Create two 'SME/SOHO Organisation' Accounts (not inserted) related to the same 
            // parent KKNr and two System Admin Users (inserted)
            helperSetupTestUpdateParentKKNrCSMgr(lstCustomerSuccessMgrs, lstChildSMEAccounts);
            Test.startTest();
            lstChildSMEAccounts[0].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            insert lstChildSMEAccounts;
            try{
                lstChildSMEAccounts[1].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
                update lstChildSMEAccounts[1];
            } catch (Exception e){
                System.assert(false, 
                    'Updates attempting to assign an \'SME/SOHO Organisation\' Account a Customer_Success_Manager'
                    + ' that has already been assigned to its sibling Account should be successful.');
            }
            Test.stopTest();
        }
    }

    /**
     * @Description:  
     * Test setUpParentKKNrCustomerSuccessMgrUpdate() and
     * updateParentKKNrCustomerSuccessMgr() methods.
     * Verify that a parent KKNr is retaining 'Customer_Success_Manager' as long as any of
     * its child 'SME/SOHO Organisation' Accounts has been assigned this CSM.
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    @isTest
    public static void testUpdateParentKKNrCSMgr_RetainCSMgrAsLongAnyChildHasOne(){
        User byPassUser = Test_DataFactory.getByPassUser();
        List<User> lstCustomerSuccessMgrs = new List<User>();
        List<Account> lstChildSMEAccounts = new List<Account>();
        System.runAs(byPassUser) {
            // Create two 'SME/SOHO Organisation' Accounts (not inserted) related to the same 
            // parent KKNr and two System Admin Users (inserted)
            helperSetupTestUpdateParentKKNrCSMgr(lstCustomerSuccessMgrs, lstChildSMEAccounts);
            Test.startTest();
            lstChildSMEAccounts[0].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            lstChildSMEAccounts[1].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            insert lstChildSMEAccounts;
            try{
                lstChildSMEAccounts[1].Customer_Success_Manager__c = null;
                update lstChildSMEAccounts[1];
            } catch (Exception e){
                System.assert(false, 
                    'Updates attempting to clear an \'SME/SOHO Organisation\' Account\'s'
                    + ' Customer_Success_Manager should be successful.');
            }
            Test.stopTest();
            List<Account> lstParentKKNr = [ SELECT Id, Customer_Success_Manager__c 
                                            FROM Account
                                            WHERE ID = :lstChildSMEAccounts[0].ParentId];
            System.assertEquals(lstChildSMEAccounts[0].Customer_Success_Manager__c,
                lstParentKKNr[0].Customer_Success_Manager__c,
                'Parent KKNr should have retained its Customer_Success_Manager despite the assignment'
                + ' having been removed for one of its child \'SME/SOHO Organisation\' Accounts,'
                + ' as long as there is another child \'SME/SOHO Organisation\' Account retaining its'
                + ' Customer_Success_Manager value.');
        }
    }

    /**
     * @Description:  
     * Test setUpParentKKNrCustomerSuccessMgrUpdate() and
     * updateParentKKNrCustomerSuccessMgr() methods.
     * Verify that a parent KKNr has its 'Customer_Success_Manager' cleared, if
     * the CSM has been removed for all of its child 'SME/SOHO Organisation' Accounts.
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    @isTest
    public static void testUpdateParentKKNrCSMgr_ClearCSMgrWhenClearedForAllChildren(){
        User byPassUser = Test_DataFactory.getByPassUser();
        List<User> lstCustomerSuccessMgrs = new List<User>();
        List<Account> lstChildSMEAccounts = new List<Account>();
        System.runAs(byPassUser) {
            // Create two 'SME/SOHO Organisation' Accounts (not inserted) related to the same 
            // parent KKNr and two System Admin Users (inserted)
            helperSetupTestUpdateParentKKNrCSMgr(lstCustomerSuccessMgrs, lstChildSMEAccounts);
            Test.startTest();
            lstChildSMEAccounts[0].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            lstChildSMEAccounts[1].Customer_Success_Manager__c = lstCustomerSuccessMgrs[0].id;
            insert lstChildSMEAccounts;
            try{
                lstChildSMEAccounts[0].Customer_Success_Manager__c = null;
                lstChildSMEAccounts[1].Customer_Success_Manager__c = null;
                update lstChildSMEAccounts;
            } catch (Exception e){
                System.assert(false, 
                    'Updates attempting to clear an \'SME/SOHO Organisation\' Account\'s'
                    + ' Customer_Success_Manager should be successful.');
            }
            Test.stopTest();
            List<Account> lstParentKKNr = [ SELECT Id, Customer_Success_Manager__c 
                                            FROM Account
                                            WHERE ID = :lstChildSMEAccounts[0].ParentId];
            System.assertEquals(null, lstParentKKNr[0].Customer_Success_Manager__c,
                'Parent KKNr should have had its Customer_Success_Manager cleared,'
                + ' if all its child \'SME/SOHO Organisation\' Accounts have had their'
                + ' Customer_Success_Manager\'s removed.');
        }
    }

    /**
     * @Description:  
     * Helper used to set up tests for 'Customer_Success_Manager' assignment.
     * Populates the lists passed as parameters with
     * - 2 System Admin Users (with IDs) to be assigned as Customer_Success_Managers
     * - 2 'SME/SOHO Organisation' Accounts (w/o IDs) related to the same parent KKNr Account
     * @param lstCustomerSuccessMgrs - Empty list to store System Admin Users
     * @param lstChildSMEAccounts - Empty list to store 'SME/SOHO Organisation' Accounts
     * @Modifications:
     * 08.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    public static void helperSetupTestUpdateParentKKNrCSMgr(List<User> lstCustomerSuccessMgrs, 
                                                            List<Account> lstChildSMEAccounts
    ){
        for(Integer idx = 0; idx < 2; idx++){
            lstCustomerSuccessMgrs.add(Test_DataFactory.createAdminUser());
        }
        insert lstCustomerSuccessMgrs;
        Account oneKundkontoAccount = Test_DataFactory.createOneKundkontoAccount();
        insert oneKundkontoAccount;
        oneKundkontoAccount.Kundkonto_Nr__c = 'Z101';
        Update oneKundkontoAccount;
        for(Integer idx = 0; idx < 2; idx++){
            Account curSMETestAccount = Test_DataFactory.createOneSMEAccount();
            curSMETestAccount.ParentId = oneKundkontoAccount.Id;
            lstChildSMEAccounts.add(curSMETestAccount);
        }
    }
}