/**
About
-----
Description: ContactTriggerHandler on Contact
Create date: 19-10-2016

Update History
--------------
Created Oct 2016 - N.G - Created, Methods updateMarketingMailsOptOutOnConInsert and updateManualUpdateAcc are created SAEN-1838
Updated Oct 2016 - A.N - New method setContactTeliaResellerId SAEN 1911/1947
Updated Oct 2016 - A.N - New method createLeadAndBuyInterestOnPardotSync SAEN 1911/1952. (Replaces Process Builder from SAEN-1839)
Updated Mars 2017 - V.M - SAEN-2174 : Deleted N.G code and added processOptOut method
Updated Mar  2017 - S.S - Case 2568 - Created new method updateContactRoleOnAccountContactRelationRecords
Updated June  2017 - P.P - Case 3094 - Created new methods updatePrimaryContact and checkAccessPrimaryContact
Updated June 2017 - S.S - Case 3094 - Created new method preventDuplicateEmail to prevent duplicate email address for customer contact record type
Updated Sept 2017 - P.P - Ticket SALEF- 150 = created new method deleteCampaignMembers to delete Campaign members associated to Customer Contacts which get deactivated
Updated Sept 2017 - S.S - Ticket SALEF- 256 = created new method updateListViewFilter to update the List View filter field on Contact for filtering contact list view
Updated April 2018 - P.P - Ticket SALEF - 833 = edited method deleteCampaignMembers to remove contact from Account as primary contact on deactivation
Updated June 2018 - D.C. - Ticket SALEF-1185 - New Field 'Additional_comments__c' set to capture more details from the Form Handler 'Leads_Konfiguratorn'
SALEF-8392 - As part of Refactoring of ContactTriggerHandler methods, modified the logic in updateContactRoleOnAccountContactRelationRecords() & deleteCampaignMembers() Methods. 
Issues / TODOs
--------------     
*/

public class ContactTriggerHandler{
    
    private static Map<Id, Contact> pardotLeadFormContactUpdateMap;
    private static boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static string CONTACT_SEGMENT_TELIA = 'Telia'; 
    private static string CONTACT_SEGMENT_CYGATE = 'Cygate';
    private static string CONTACT_SEGMENT_MARKETING = 'Marketing';
    private static string CONTACT_SEGMENT_SERVICE_MANAGEMENT = 'Service Management';
    private static string CONTACT_SEGMENT_OTHER = 'Other';
    private static Map<Id,Contact> cygateLeadFormContactUpdateMap;  // V.A
    public static Boolean alreadyCalled = false;
    
    public ContactTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(List<Contact> newList){  
        system.debug('inside before handeler');
        //Case 2662: Phone and Mobile Number Field Format
        Map<ID, Contact> oldMap = new Map<ID, Contact>();
          updatePhoneNumber(newList,oldMap);
        updateMarketingMailsOptOutOnConInsert(newList);      
        checkAccessPrimaryContact(newList,null);
        updatePrimaryContact(newList);
        updateListViewFilter(newlist,null);
        //preventDuplicateEmail(newList,null);
    }
    public void OnBeforeUpdate(List<Contact> newList, Map<ID, Contact> newMap, List<Contact> oldList, Map<ID, Contact> oldMap){
        System.debug('ContactTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        //      updateManualUpdateAcc(newList,oldMap);    
        //Case 2662: Phone and Mobile Number Field Format
        If(!alreadyCalled)
        {
            updatePhoneNumber(newList,oldMap);
        }

        system.debug('oldbfrupdate'+oldlist[0].Cygate_Sync__c+'newbfrupdate'+newList[0].Cygate_Sync__c);
        checkAccessPrimaryContact(newList,oldMap);
        processOptOut(newList, oldMap);
        pardotSyncResetNamePhoneFields(newList, oldMap);
        cygateSyncResetNamePhoneFields(newList, oldMap);  // V.A
         updateListViewFilter(newlist,oldMap);
        // preventDuplicateEmail(newList,oldMap);
        
    }
    
    public void OnAfterInsert(List<Contact> newList, Map<ID, Contact> newMap){
        System.debug('ContactTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        checkContractITRole(newList);
    }
    public void OnAfterDelete(List<Contact> oldList){
        checkContractITRole(oldList);
    }
    
    public void OnAfterUpdate(List<Contact> newList, Map<ID, Contact> newMap, List<Contact> oldList, Map<ID, Contact> oldMap){
        System.debug('ContactTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        createLeadAndBuyInterestOnPardotSync(newList,oldMap);
        System.debug('@@@'+newList[0].Cygate_Sync__c+'###'+oldList[0].Cygate_Sync__c);
        createLeadAndBuyInterestOnCygateSync(newList,oldMap);  // V.A
        updateContactRoleOnAccountContactRelationRecords(newlist, oldMap);
        deleteCampaignMembers(newList, oldMap);  //P.P
        checkContractITRole(newList);
    }
    
    // Author A.N
    // As several trigger methods depends on whether this is defined as a Pardot Sync update a seperate method is created for this.
    // This is as to only define the criteria once and to ensure that if the criteria is changed then no functionality will break
    private Boolean isPardotSync(Contact newCon, Contact oldCon){
        if(newCon.Pardot_Sync__c != null && oldCon != null && newCon.Pardot_Sync__c != oldCon.Pardot_Sync__c){
            return true;
        }
        return false;
    }
    private void checkContractITRole (List<Contact> newList)
    {
        List<String> roleValues = new List<String>{'IT-ansvarig','IT-Arkitekt','IT-chef/CTO','IT-Direktör/CIO','IT-Säkerhetschef','IT-Strateg'};
        List<String> addRoleValues = new List<String>{'IT-ansvarig','IT-Arkitekt','IT-chef/CTO','IT-Direktör/CIO','IT-Säkerhetschef','IT-Strateg'};
        Set<Id> childAccountIDs = new Set<Id>();
        Map<Id,Boolean> parentAccountIDsMap = new Map<Id,Boolean>();
        List<Account> parentAccsUpdate = new List<Account>();
        for(Contact oneContact : newList) {
                childAccountIDs.add(oneContact.AccountId);
        }
        try{
            List<Account> childAccounts = [SELECT Id, Parent.Contacts_with_IT_role__c, ParentId ,(SELECT Id FROM Contacts WHERE Role__c IN : roleValues OR Additional_role__c IN : addRoleValues LIMIT 1) FROM Account WHERE Id IN : childAccountIDs AND Parent.RecordType.DeveloperName = 'Sales_Aggregation_Account'];
            for(Account oneAccount : childAccounts) {
                if(oneAccount.Parent.Contacts_with_IT_role__c == false && !oneAccount.Contacts.isEmpty()){
                    parentAccountIDsMap.put(oneAccount.ParentId, true);
                }
                else if(oneAccount.Parent.Contacts_with_IT_role__c == true && oneAccount.Contacts.isEmpty()){
                    parentAccountIDsMap.put(oneAccount.ParentId, false);
                }
            }
            for(id parentAccountId : parentAccountIDsMap.keySet()){
                Account updateAccount =new Account(Id = parentAccountId, Contacts_with_IT_role__c = parentAccountIDsMap.get(parentAccountId));
                parentAccsUpdate.add(updateAccount);
            }
            if(!parentAccsUpdate.isEmpty()) {
                update parentAccsUpdate;
            }
        }
        catch(Exception ex){
            system.debug('Error Cause '+ex.getCause()+' Line Number'+ex.getLineNumber());
        }
    
    }
    private void updateContactRoleOnAccountContactRelationRecords(List<Contact> newList, Map<Id, Contact> oldMap)
    {
        Set<Id> ContactId = new Set<Id>();
        List<AccountContactRelation> listofAccountContactRelationship = new List<AccountContactRelation>();
        Map<Id,AccountContactRelation> updateMapofAccountContactRelationship = new Map<Id,AccountContactRelation>();
        
        for(Contact newCon : newList)
        {
            if(oldMap != null && oldMap.get(newCon.Id).Role__c != newCon.Role__c)
            {
                ContactId.add(newCon.Id);
            }
        }
       //SALEF-8392 changed the logic for SOQL query optimization, enclosed the query with "if(!ContactID.isEmpty())""
       if (!contactId.isEmpty()) {  
           listofAccountContactRelationship = [Select Id, Apex_Updated__c ,Role__c, IsDirect, ContactId from AccountContactRelation where ContactId =: ContactId];
        for(Contact newCon : newList)
        {
            for(AccountContactRelation accConlist : listofAccountContactRelationship)
            {
                if(accConlist.IsDirect == True)
                {
                    accConlist.Role__c = newCon.Role__c;
                    accConlist.Apex_Updated__c = (accConlist.Apex_Updated__c == null ? 1 : accConlist.Apex_Updated__c + 1 );
                    updateMapofAccountContactRelationship.put(accConList.id,accConList);
                }
            }   
        }
        if(updateMapofAccountContactRelationship != Null && updateMapofAccountContactRelationship.size()>0){
            update updateMapofAccountContactRelationship.values();
        }
       }  
    }
    // Author A.N
    // When a new Contact is submitted or updated from Pardot (isPardotSync true)
    // Fields FirstName, LastName, Phone should be reset to original values
    private void pardotSyncResetNamePhoneFields(List<Contact> newList, Map<Id, Contact> oldMap){
        for(Contact newCon : newList){
            // For all Contacts where Pardot Sync is true, reset FirstName, LastName, Phone fields to original values
            if(oldMap != null && isPardotSync(newCon ,oldMap.get(newCon.Id))){
                if(pardotLeadFormContactUpdateMap == null) pardotLeadFormContactUpdateMap = new Map<Id, Contact>(); 
                // Add Original FirstName, LastName, Phone values to pardotLeadFormContactUpdateMap in a new Contact
                pardotLeadFormContactUpdateMap.put(newCon.Id, new Contact(FirstName = newCon.FirstName, LastName = newCon.LastName, Phone = newCon.Phone));
                // Reset FirstName, LastName, Phone field values on new contacts
                Contact oldCon = oldMap.get(newCon.Id);
                newCon.FirstName = oldCon.FirstName;
                newCon.LastName = oldCon.LastName;
                newCon.Phone = oldCon.Phone;
            }
        }
    }
    
    //Author N.G : SAEN-1838 , When a new contact is created it should take the value in the field Marketing_Mails_Opt_Out_Contact__c from its parent account.
    public static void updateMarketingMailsOptOutOnConInsert(List<Contact> newList){
        list<Contact> newConList = new list<Contact>();
        list<Contact> finalUpdateConList = new list<Contact>();
        map<string,string> conAccountMap = new map<string,string>();
        list<string> accIDs = new list<string>();
        map<string,Account> accMap = new map<string,Account>();
        list<account> newAccList = new list<account>();
        
        for(Contact con : newList){
            if(con.AccountId != null)
            {
                accIDs.add(con.accountId);
            }
        }
        if(accIDs != null)
        {
            newAccList = [select id,SMS_Cygate__c,SMS_Telia__c,Campaigns_Cygate__c,Campaigns_Telia__c,Newsletter_Telia__c,Newsletter_Cygate__c,Survey_Telia__c,Survey_Cygate__c,Event_Cygate__c,Event_Telia__c,RecordTypeId,Marketing_Mails_Opt_Out__c,From_date__c,To_Date__c from account where id in : accIDs];
        }
        if(newAccList != null)
        {
            for(Account acc : newAccList)
            {
                accMap.put(acc.id,acc);
            }
        }
        for(contact con : newList){
            if(!accMap.isEmpty() && (accMap.get(con.accountID).RecordTypeId ==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE) || accMap.get(con.accountID).RecordTypeId ==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC1) ||
            accMap.get(con.accountID).RecordTypeId ==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC2) || accMap.get(con.accountID).RecordTypeId ==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME) /*|| accMap.get(con.accountID).RecordTypeId ==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_CYGATE_SUB)*/))
            {
                con.Marketing_Mails_Opt_Out_Contact__c = accMap.get(con.accountID).Marketing_Mails_Opt_Out__c;  
                con.Newsletter_Telia__c = accMap.get(con.accountID).Newsletter_Telia__c;
                con.Newsletter_Cygate__c = accMap.get(con.accountID).Newsletter_Cygate__c;
                con.Survey_Telia__c = accMap.get(con.accountID).Survey_Telia__c;
                con.Survey_Cygate__c = accMap.get(con.accountID).Survey_Cygate__c;
                con.Event_Cygate__c = accMap.get(con.accountID).Event_Cygate__c;
                con.Event_Telia__c = accMap.get(con.accountID).Event_Telia__c;
                con.Campaigns_Telia__c = accMap.get(con.accountID).Campaigns_Telia__c;
                con.Campaigns_Cygate__c = accMap.get(con.accountID).Campaigns_Cygate__c;
                con.SMS_Telia__c = accMap.get(con.accountID).SMS_Telia__c;
                con.SMS_Cygate__c = accMap.get(con.accountID).SMS_Cygate__c;   
            }
        }
    }
    
    //Author N.G : This method sets Manual_Update_Contact__c to true when field Marketing_Mails_Opt_Out_Contact__c is updated manually.
    public static void updateManualUpdateAcc(List<contact> newList, Map<ID, contact> oldMap){
        for(contact con : newList){
            if(oldMap != null && con.Marketing_Mails_Opt_Out_Contact__c != oldMap.get(con.Id).Marketing_Mails_Opt_Out_Contact__c){
                con.Manual_Update_Contact__c = true;  
            }
        }
    }
    
    // Author A.N
    // When a new Contact is submitted or updated from Pardot (isPardotSync true)
    // create a new Lead/Buy Interest record. Note: this trigger will only create new Leads, the LeadTriggerHandler
    // will automatically create the related Buy Interests
    private void createLeadAndBuyInterestOnPardotSync(List<Contact> newList, Map<Id, Contact> oldMap){
    System.debug(UserInfo.getUserId());
    System.debug(Label.Pardot_Integration_User_Id);
    if(UserInfo.getUserId()==Label.Pardot_Integration_User_Id || UserInfo.getProfileId()==Label.System_Admin_Profile){
        List<Contact> pardotUpdatedContacts = new List<Contact>();
        Set<Id> accIds = new Set<Id>();
        system.debug('PardotSync:-'+oldMap.get(newList[0].Id).Cygate_Sync__c+'NewPardotValues:-'+newList[0].Cygate_Sync__c);
        for(Contact c : newList){
            system.debug('PardotSync:-'+isPardotSync(c ,oldMap.get(c.Id)));
            // For all Contacts where Pardot Sync is true, add to List
            if(oldMap != null && isPardotSync(c ,oldMap.get(c.Id))){
                pardotUpdatedContacts.add(c);
                accIds.add(c.AccountId);
            }
        } 
        system.debug('Line184:-'+pardotUpdatedContacts.isEmpty());
        if(pardotUpdatedContacts.isEmpty()) return;
        
        // Get all accounts related to pardotUpdatedContacts
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name, RecordTypeId FROM Account WHERE Id in :accIds]);
        
        // Create one Buy Interest for each Pardot updated contact
        List<Lead> newLeads = new List<Lead>();
        for(Contact c : pardotUpdatedContacts){
            // Create Buy Interests. Set status new and copy fields from Contact and Account
            Lead lead = createLeadFromContact(c, accMap.get(c.AccountId));
                       newLeads.add(lead);
        }
        system.debug('Line197:-'+newLeads);
        
        insert newLeads;
        
        Map<Id, Id> conIdLeadIdMap = new Map<Id, Id>();
        for(Lead l : newLeads){
            conIdLeadIdMap.put(l.Contact__c, l.Id);
        }
        
        // We need to update any existing Buy Interest resords with lookup to the newly created leads
        List<Buy_Interest__c> biUpdateList = new List<Buy_Interest__c>();
        for(Buy_Interest__c bi : [SELECT Id, Contact__c, Lead__c FROM Buy_Interest__c WHERE Contact__c IN :conIdLeadIdMap.keySet()]){
            if(bi.Lead__c != conIdLeadIdMap.get(bi.Contact__c)){
                bi.Lead__c = conIdLeadIdMap.get(bi.Contact__c);
                biUpdateList.add(bi);
            }
        }
        system.debug('Line213:-'+biUpdateList);
        if(!biUpdateList.isEmpty()) update biUpdateList;
        }
    }
    
    private static Lead createLeadFromContact(Contact con, Account acc){
        Lead newLead = new Lead();
        
        // To make the Lead Assignment rule run for the newly created lead
        newLead.setOptions(getLeadAssignementRuleOption());  
        
        // Set Status and sync fields
        newLead.Status = LeadTriggerHandler.LEAD_STATUS_NEW;
        newLead.Pardot_Sync__c = 1;
        newLead.Created_From_Contact__c = true;
        
        // Standard fields mapping
        newLead.Company = (acc != null && acc.Name != null) ? acc.Name : 'Kontonamn saknas';
        newLead.Org_nr__c = con.Org_nr__c;
        newLead.City = con.MailingCity;
        newLead.Country = con.MailingCountry;
        newLead.Street = con.MailingStreet;
        newLead.PostalCode = con.MailingPostalCode;
        newLead.State = con.MailingState;
        newLead.Description = con.Description;
        newLead.Email = con.Email;
        newLead.HasOptedOutOfEmail = con.HasOptedOutOfEmail;
        newLead.Fax = con.Fax;
        newLead.LeadSource = con.LeadSource;
        newLead.MobilePhone = con.MobilePhone;
        newLead.Title = con.Title;
        // Mapping for fields that will be reset on Contact for all Pardot Sync. We need to fetch the originally submitted values from the Lead form,
        // stored in pardotLeadFormContactUpdateMap. Note, if the record can't be found we will use the values from the con-record
        Contact pardotContact = pardotLeadFormContactUpdateMap.get(con.Id);
        newLead.Phone = (pardotContact == null ? con.Phone : pardotContact.Phone);
        newLead.FirstName = (pardotContact == null ? con.FirstName : pardotContact.FirstName);
        newLead.LastName = (pardotContact == null ? con.LastName : pardotContact.LastName);
        // Custom Fields Mapping
        newLead.Contact__c = con.Id;
        newLead.Description_Pardot__c = con.Description_Pardot__c;
        newLead.Additional_comments__c = con.Additional_comments__c;  // D.C New field for Form Handler.
        newLead.Form_Source__c = con.Form_Source__c;
        newLead.Form_Source_URL__c = con.Form_Source_URL__c;
        newLead.Product_Area__c = con.Product_Area__c;
        // The lead.Account__c lookup filter only allows Large/SME accounts, so will only set the lookup if true
        if(SEUtility.isLargeAccountRecordType(acc.RecordTypeId) || SEUtility.isSmeAccountRecordType(acc.RecordTypeId)){
            newLead.Account__c = con.AccountId;
        }
        // Submitter fields mapping
        newLead.Lead_Submitter_email__c = con.Lead_Submitter_email__c;
        newLead.Lead_Submitter_first_name__c = con.Lead_Submitter_first_name__c;
        newLead.Lead_Submitter_ID__c = con.Lead_Submitter_ID__c;
        newLead.Lead_Submitter_Last_name__c = con.Lead_Submitter_Last_name__c;
        newLead.Lead_Submitter_No__c = con.Lead_Submitter_No__c;
        newLead.Lead_Submitter_phone__c = con.Lead_Submitter_phone__c;
        
        return newLead;
    }
    
    // Author A.N
    // This code creates a lead DML option, to ensure that lead assignment rules run for leads created in Apex
    // Orginal code: http://www.thephani.com/enable-assignment-rules-from-apex/
    private static Database.DMLOptions leadDMLOptions;
    private static Database.DMLOptions getLeadAssignementRuleOption(){
        if(leadDMLOptions == null){
            //Fetching the assignment rule on lead
            List<AssignmentRule> leadAssignmentRules = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = true limit 1];
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            leadDMLOptions = new Database.DMLOptions();  
            if(leadAssignmentRules.size()>0){
                leadDMLOptions.assignmentRuleHeader.assignmentRuleId = leadAssignmentRules[0].id;
            }                
        }
        return leadDMLOptions;
    }
    
    //Author V.M If we manually change the marketing fields, we set the Process Opt Out to true so that the batch process only the ones that has been changed.
    //Also we timestamp when the Marketing Opt Out fields get their value changed
    private static void processOptOut(List<Contact> newList, Map<Id, Contact> oldMap){
        System.debug('inside processOptOut');
        
        for(Contact con : newList){
            if(con.Marketing_Mails_Opt_Out_Contact__c != oldMap.get(con.Id).Marketing_Mails_Opt_Out_Contact__c || con.From_Date__c != oldMap.get(con.Id).From_Date__c || con.To_Date__c != oldMap.get(con.Id).To_Date__c || con.Marketing_Mails_Opt_Out_Cygate_Contact__c != oldMap.get(con.Id).Marketing_Mails_Opt_Out_Cygate_Contact__c || con.From_Date_Cygate_Contact__c != oldMap.get(con.Id).From_Date_Cygate_Contact__c || con.To_Date_Cygate_Contact__c != oldMap.get(con.Id).To_Date_Cygate_Contact__c)
            {
               //Check if we are in not in batch context
               if(!System.isBatch())
               {  
                    if(con.Marketing_Mails_Opt_Out_Contact__c != oldMap.get(con.Id).Marketing_Mails_Opt_Out_Contact__c && (con.Marketing_Mails_Opt_Out_Contact__c == 'According to agreement' || con.Marketing_Mails_Opt_Out_Contact__c == 'Upon Client request'))
                     {
                        con.Newsletter_Telia__c = false;

                        con.Survey_Telia__c = false;


                        con.Event_Telia__c = false;
                        con.Campaigns_Telia__c = false;

                        con.SMS_Telia__c = false;
                    }
                    if(con.Marketing_Mails_Opt_Out_Cygate_Contact__c != oldMap.get(con.Id).Marketing_Mails_Opt_Out_Cygate_Contact__c && (con.Marketing_Mails_Opt_Out_Cygate_Contact__c == 'According to agreement' || con.Marketing_Mails_Opt_Out_Cygate_Contact__c == 'Upon Client request'))
                    {
                        con.Newsletter_Cygate__c = false;
                        con.Survey_Cygate__c = false;
                        con.Event_Cygate__c = false;
                        con.Campaigns_Cygate__c = false;
                        con.SMS_Cygate__c = false;              
                    }
                    //commented as not required as per new requirements                     
                   /* con.Man_From_Date__c = con.From_Date__c;
                    con.Man_To_Date__c = con.To_Date__c;
                    con.Man_Mails_Opt_Out__c = con.Marketing_Mails_Opt_Out_Contact__c;
                   
                    //Set manually set to true if any value have been changed outside batchcontext
                    if(con.Marketing_Mails_Opt_Out_Contact__c != null || con.From_Date__c != null || con.To_Date__c != null)
                    {
                        con.Opt_Out_Manually_Set__c = true;
                    }
                    else if(oldMap.get(con.Id).Marketing_Mails_Opt_Out_Contact__c != null && con.Marketing_Mails_Opt_Out_Contact__c == null)
                    {
                        con.Opt_Out_Manually_Set__c = true;
                    }
                    else{
                       con.Opt_Out_Manually_Set__c = false;
                    }*/
                }
            }
        }
    }

    //Case 2662: Salesforce Contact Mobile and Phone Validation for users
    public void  updatePhoneNumber(List<contact> newList,Map<Id, Contact> oldMap){
        alreadyCalled = true;
        String regex= '[+]{1}[1-9]{1}([^\\w]|[\\w]){6,50}|[+46]{3}';
        boolean isPhoneValid = false;
        boolean isCellPhoneValid = false;
        try{
            for(Contact con : newList){
                // Get the customer record Type
                if(SEUtility.getRecordTypeDevName(con.RecordTypeId) == 'Customer_Contact'){
                    if(String.isNotBlank(con.MobilePhone)){
                        con.MobilePhone ='+'+con.MobilePhone.replaceAll('[^0-9]', '');
                        isCellPhoneValid = Pattern.matches(regex,con.MobilePhone);
                        if(oldMap.isEmpty()){
                            if(!isCellPhoneValid){
                                con.adderror(Label.Contact_PhoneValidation);
                            }else{
                                if(con.MobilePhone.length()>3){
                                    if(con.MobilePhone.substring(0,3) =='+46'){
                                        While(con.MobilePhone.indexOf('0')==3){
                                            con.MobilePhone = con.MobilePhone.substring(0,3)+con.MobilePhone.substring(4,con.MobilePhone.length());
                                        }
                                    }
                                }
                            }
                        }else if (oldMap !=null && con.Cygate_account_manager__c ==oldMap.get(con.Id).Cygate_account_manager__c){
                            if(!isCellPhoneValid){
                                con.adderror(Label.Contact_PhoneValidation);
                            }else{
                                //  con.MobilePhone ='+'+con.MobilePhone.replaceAll('[^0-9]', '');
                                if(con.MobilePhone.length()>3){
                                    if(con.MobilePhone.substring(0,3) =='+46'){
                                        While(con.MobilePhone.indexOf('0')==3){
                                            con.MobilePhone = con.MobilePhone.substring(0,3)+con.MobilePhone.substring(4,con.MobilePhone.length());
                                        }
                                    }
                                }
                            }
                        }
                        if(con.MobilePhone.length() < 8 && con.MobilePhone != '+46' && con.Cygate_account_manager__c ==oldMap.get(con.Id).Cygate_account_manager__c) {
                            con.adderror(Label.Contact_PhoneValidation);
                        }
                    }
                    if(String.isNotBlank(con.Phone)){

                        con.Phone = '+'+con.Phone.replaceAll('[^0-9]', '');
                        isPhoneValid = Pattern.matches(regex,con.Phone);
                        if(oldMap.isEmpty()){
                            if(!isPhoneValid){
                                con.adderror(Label.Contact_TelePhoneValidation);
                            }else{
                                // con.Phone = '+'+con.Phone.replaceAll('[^0-9]', '');
                                if(con.Phone.length()>3){
                                    if(con.Phone.substring(0,3) =='+46'){
                                        While(con.Phone.indexOf('0')==3){
                                            con.Phone = con.Phone.substring(0,3)+con.Phone.substring(4,con.Phone.length());
                                        }
                                    }
                                }
                            }
                        }else if (oldMap !=null && con.Cygate_account_manager__c ==oldMap.get(con.Id).Cygate_account_manager__c){
                            if(!isPhoneValid){
                                con.adderror(Label.Contact_TelePhoneValidation);
                            }else{
                                // con.Phone ='+'+con.Phone.replaceAll('[^0-9]', '');
                                if(con.Phone.length()>3){
                                    if(con.Phone.substring(0,3) =='+46'){
                                        While(con.Phone.indexOf('0')==3){
                                            con.Phone = con.Phone.substring(0,3)+con.Phone.substring(4,con.Phone.length());
                                        }
                                    }
                                }
                            }
                        }
                        if(con.Phone.length() < 8 && con.Phone != '+46' && con.Cygate_account_manager__c ==oldMap.get(con.Id).Cygate_account_manager__c) {
                            con.adderror(Label.Contact_TelePhoneValidation);
                        }
                    }
                }
            }
        }catch(Exception ex){
            system.debug('Error Cause'+ex.getCause()+'Line Number'+ex.getLineNumber());
        }
    }
    
    //To update primary contact on Contact on creation
    public static void updatePrimaryContact(List<Contact> newList){
        
        Map<Id,String> roleSegmentMap = new Map<Id,String>();    
        for(Contact_Management_Role_Set__c cmrs:Contact_Management_Role_Set__c.getAll().values()){
            roleSegmentMap.put(cmrs.Role_Id__c,cmrs.Segment__c);
        }
        string userRoleId = '';
        string userSegment = '';
        
        for(contact con : newList){
            if(!(SEUtility.isSystemAdmin(UserInfo.getProfileId())) && !(SEUtility.isEnterpriseBusinessAdminUser(UserInfo.getProfileId())))
            {
                //this functionality should work only for Customer Contacts
                if(con.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CUSTOMER)){
                    userRoleId = UserInfo.getUserRoleId();
                    userSegment = roleSegmentMap.get(userRoleId);
                    
                    if(userSegment == CONTACT_SEGMENT_SERVICE_MANAGEMENT){
                        con.Service_Management_Primary_Contact__c  = TRUE;
                    }
                    else if(userSegment == CONTACT_SEGMENT_TELIA){
                        con.Telia_Primary_Contact__c = TRUE;           
                    }
                    else if(userSegment == CONTACT_SEGMENT_CYGATE){
                        con.Cygate_Primary_Contact__c = TRUE;            
                    }
                    else if(userSegment == CONTACT_SEGMENT_MARKETING){
                        con.Marketing_Primary_Contact__c = TRUE;
                    }
                    else if(userSegment == CONTACT_SEGMENT_OTHER){
                        con.Other_Primary_Contact__c = TRUE;
                    }
                }
            }
        }
    }
    
    public static void checkAccessPrimaryContact(List<Contact> newList,Map<Id,Contact> oldMap){
        Map<Id,String> roleSegmentMap = new Map<Id,String>();    
        for(Contact_Management_Role_Set__c cmrs:Contact_Management_Role_Set__c.getAll().values()){
            roleSegmentMap.put(cmrs.Role_Id__c,cmrs.Segment__c);
        }
        string userRoleId = '';
        
        
        string userSegment = '';
        for(contact con:newList){
            if(con.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CUSTOMER)){
                if(!(SEUtility.isSystemAdmin(UserInfo.getProfileId())) && !(SEUtility.isEnterpriseBusinessAdminUser(UserInfo.getProfileId())))
                {
                    userRoleId = UserInfo.getUserRoleId();
                    userSegment = roleSegmentMap.get(userRoleId);
                    
                    if(oldMap == NULL){
                        if((con.Telia_Primary_Contact__c == TRUE) && (userSegment != CONTACT_SEGMENT_TELIA)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }
                        else if((con.Cygate_Primary_Contact__c == TRUE) && (userSegment != CONTACT_SEGMENT_CYGATE)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }    
                        else if((con.Service_Management_Primary_Contact__c == TRUE) && (userSegment != CONTACT_SEGMENT_SERVICE_MANAGEMENT)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }
                        else if((con.Marketing_Primary_Contact__c == TRUE) && (userSegment != CONTACT_SEGMENT_MARKETING)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }
                        else if((con.Other_Primary_Contact__c == TRUE) && (usersegment != CONTACT_SEGMENT_OTHER)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }
                    }
                    
                    else {
                        if((oldMap.get(con.id).Telia_Primary_Contact__c != con.Telia_Primary_Contact__c) && (userSegment != CONTACT_SEGMENT_TELIA)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }
                        else if((oldMap.get(con.id).Cygate_Primary_Contact__c != con.Cygate_Primary_Contact__c) && (userSegment != CONTACT_SEGMENT_CYGATE)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }    
                        else if((oldMap.get(con.id).Service_Management_Primary_Contact__c != con.Service_Management_Primary_Contact__c) && (userSegment != CONTACT_SEGMENT_SERVICE_MANAGEMENT)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }
                        else if((oldMap.get(con.id).Marketing_Primary_Contact__c != con.Marketing_Primary_Contact__c) && (userSegment != CONTACT_SEGMENT_MARKETING)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }
                        else if((oldMap.get(con.Id).Other_Primary_Contact__c != con.Other_Primary_Contact__c) && (userSegment != CONTACT_SEGMENT_OTHER)){
                            con.addError(Label.Contact_Management_Error_Message);
                        }
                    }
                }
            }
        }
    }
    
    //Update the list view filter field for filtering the contact list view on basis of the List_View_Filter__c field.  
    public static void updateListViewFilter(List<Contact> newList,Map<Id,Contact> oldMap){
       
        for(contact con:newList)
        {   
            boolean TeliaContact, CygateContact, SMContact, MarketingContact, OtherContact;
            TeliaContact = false;
            CygateContact = false;
            SMContact = false;
            MarketingContact = false;
            OtherContact = false;
            if(con.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CUSTOMER))
            {
                if(con.Telia_Primary_Contact__c == true || con.Telia_Activities__c == true)
                {
                    TeliaContact = true;
                }
                if(con.Cygate_Primary_Contact__c || con.Cygate_Activities__c == true)
                {
                    CygateContact = true;
                }
                if(con.Marketing_Primary_Contact__c == true || con.Marketing_Activities__c == true)
                {
                    MarketingContact = true;
                }
                if(con.Service_Management_Primary_Contact__c == true || con.Service_Management_Activities__c == true)
                {
                    SMContact = true;
                }
                if(con.Other_Primary_Contact__c == true || con.Other_Activities__c == true)
                {
                    OtherContact = true;
                }
            }
                if(TeliaContact == true && CygateContact == true && MarketingContact == true && SMContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'TCMSO';
                }
                else if(TeliaContact == true && CygateContact == true && MarketingContact == true && SMContact == true)
                {
                    con.List_View_Filter__c = 'TCMS';
                }
                else if(TeliaContact == true && CygateContact == true && MarketingContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'TCMO';
                }
                else if(TeliaContact == true && MarketingContact == true && SMContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'TMSO';
                }
                else if(CygateContact == true && MarketingContact == true && SMContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'CMSO';
                }
                else if(TeliaContact == true && CygateContact == true && MarketingContact == true)
                {
                    con.List_View_Filter__c = 'TCM';
                }
                else if(TeliaContact == true && CygateContact == true && SMContact == true)
                {
                    con.List_View_Filter__c = 'TCS';
                }
                else if(TeliaContact == true && CygateContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'TCO';
                }
                else if(TeliaContact == true && MarketingContact == true && SMContact == true)
                {
                    con.List_View_Filter__c = 'TMS';
                }
                else if(TeliaContact == true && MarketingContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'TMO';
                }
                else if(TeliaContact == true && SMContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'TSO';
                }
                else if(CygateContact == true && MarketingContact == true && SMContact == true)
                {
                    con.List_View_Filter__c = 'CMS';
                }
                else if(CygateContact == true && MarketingContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'CMO';
                }
                else if(CygateContact == true && SMContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'CSO';
                }
                else if(MarketingContact == true && SMContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'MSO';
                }
                else if(TeliaContact == true && CygateContact == true)
                {
                    con.List_View_Filter__c = 'TC';
                }
                else if(TeliaContact == true && MarketingContact == true)
                {
                    con.List_View_Filter__c = 'TM';
                }
                else if(TeliaContact == true && SMContact == true)
                {
                    con.List_View_Filter__c = 'TS';
                }
                else if(TeliaContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'TO';
                }
                else if(CygateContact == true && MarketingContact == true)
                {
                    con.List_View_Filter__c = 'CM';
                }
                else if(CygateContact == true && SMContact == true)
                {
                    con.List_View_Filter__c = 'CS';
                }
                else if(CygateContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'CO';
                }
                else if(MarketingContact == true && SMContact == true)
                {
                    con.List_View_Filter__c = 'MS';
                }
                else if(MarketingContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'MO';
                }
                else if(SMContact == true && OtherContact == true)
                {
                    con.List_View_Filter__c = 'SO';
                }
                else if(TeliaContact == true)
                {
                    con.List_View_Filter__c = 'T';
                }
                else if(CygateContact == true)
                {
                    con.List_View_Filter__c = 'C';
                }
                else if(MarketingContact == true)
                {
                    con.List_View_Filter__c = 'M';
                }
                else if(SMContact == true)
                {
                    con.List_View_Filter__c = 'S';
                }
                else if(OtherContact == true)
                {
                    con.List_View_Filter__c = 'O';
                }
                else
                {
                    con.List_View_Filter__c = 'NA';
                }
                
        }               
    }
    
    
    /* Author: Varma Alluri on 14/06/2017; SAEN-2411, When a new Contact is submitted or updated from Pardot (isCygateSync true)
create a new Lead/Buy Interest record. Note: this trigger will only create new Leads, the LeadTriggerHandler will automatically create the related Buy Interests  */
    private void createLeadAndBuyInterestOnCygateSync(List<Contact> newList, Map<Id,Contact> oldMap){  // V.A
        List<Contact> cygateUpdatedContacts = new List<Contact>();
        Set<Id> accIds = new Set<Id>();
        for(Contact c : newList){ 
            system.debug('Line537:-'+c+'syn:-'+isCygateSync(c, oldMap.get(c.Id))+'old:-'+oldMap); 
            // For all Contacts where Cygate Sync is true, add to List
            if(oldMap != Null && isCygateSync(c, oldMap.get(c.Id))){
                cygateUpdatedContacts.add(c);
                accIds.add(c.AccountId);
            }
        }
        system.debug('Line543:-'+cygateUpdatedContacts.isEmpty());
        if(cygateUpdatedContacts.isEmpty()) return;
        
        // Get all accounts related to cygateUpdatedContacts
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name, RecordTypeId FROM Account WHERE Id in :accIds]);
        
        // Create one Buy Interest for each Cygate updated contact
        List<Lead> newCygateLeads = new List<Lead>();
         system.debug('Line551:-'+accMap);
        if(!accMap.isEmpty()){
            for(Contact c : cygateUpdatedContacts){
                // Create Buy Interests. Set status new and copy fields from Contact and Account
                Lead cygatelead = createCygateLeadFromContact(c, accMap.get(c.AccountId));
                newCygateLeads.add(cygatelead);
            }
        }
        system.debug('Line558:-'+newCygateLeads);
        if(newCygateLeads.size()>0){
            insert newCygateLeads;
        }
        system.debug('newCygateLeads creatde'+newCygateLeads);
        Map<Id, Id> conIdLeadIdMap = new Map<Id, Id>();
        for(Lead cygateLead1 : newCygateLeads){
            conIdLeadIdMap.put(cygateLead1.Contact__c, cygateLead1.Id);
        }
        
        // We need to update any existing Buy Interest records with lookup to the newly created leads
        List<Buy_Interest__c> buyInterestUpdateList = new List<Buy_Interest__c>();
        for(Buy_Interest__c cygateBuyInterest : [SELECT Id, Contact__c, Lead__c FROM Buy_Interest__c WHERE Contact__c IN :conIdLeadIdMap.keySet()]){
            if(cygateBuyInterest.Lead__c != conIdLeadIdMap.get(cygateBuyInterest.Contact__c)){
                cygateBuyInterest.Lead__c = conIdLeadIdMap.get(cygateBuyInterest.Contact__c);
                buyInterestUpdateList.add(cygateBuyInterest);
            }
        }
        system.debug('buyInterestUpdateList=='+buyInterestUpdateList.size());
        if(!buyInterestUpdateList.isEmpty()) update buyInterestUpdateList;
    }
    
    // Author: Varma Alluri on 16.06.2017; SAEN-2411, As several trigger methods depends on whether this is defined as a Cygate Sync update a seperate method is created for this.
    // This is as to only define the criteria once and to ensure that if the criteria is changed then no functionality will break
    private Boolean isCygateSync(Contact newCon, Contact oldCon){  // V.A
        system.debug('new:-'+newCon.Cygate_Sync__c+'Old:-'+oldCon.Cygate_Sync__c);
        if(newCon.Cygate_Sync__c != null && oldCon != null && newCon.Cygate_Sync__c != oldCon.Cygate_Sync__c){
            return true;
        }
        return false;
    }
    
    private static Lead createCygateLeadFromContact(Contact con, Account acc){  // V.A
        Lead newLead = new Lead();
        system.debug('Line592'+con+'***'+acc);
        // To make the Lead Assignment rule run for the newly created lead
      //  newLead.setOptions(getLeadAssignementRuleOption());  
        
        // Set Status and sync fields
        newLead.Status = LeadTriggerHandler.LEAD_STATUS_NEW;
        newLead.Cygate_Sync__c = 1;
        newLead.Created_From_Contact__c = true;
        
        // Standard fields mapping
        newLead.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_CYGATE);
        newLead.Company = (acc != null && acc.Name != null) ? acc.Name : 'Kontonamn saknas';
        newLead.Org_nr__c = con.Org_nr__c;
        newLead.City = con.MailingCity;
        newLead.Country = con.MailingCountry;
        newLead.Street = con.MailingStreet;
        newLead.PostalCode = con.MailingPostalCode;
        newLead.State = con.MailingState;
        newLead.Description = con.Description;
        newLead.Email = con.Email;
        newLead.HasOptedOutOfEmail = con.HasOptedOutOfEmail;
        newLead.Fax = con.Fax;
        newLead.LeadSource = con.LeadSource;
        newLead.MobilePhone = con.MobilePhone;
        newLead.Title = con.Title;
        // Mapping for fields that will be reset on Contact for all Cygate Sync. We need to fetch the originally submitted values from the Lead form,
        // stored in cygateLeadFormContactUpdateMap. Note, if the record can't be found we will use the values from the con-record
        Contact cygateContact = cygateLeadFormContactUpdateMap.get(con.Id);
        newLead.Phone = (cygateContact == null ? con.Phone : cygateContact.Phone);
        newLead.FirstName = (cygateContact == null ? con.FirstName : cygateContact.FirstName);
        newLead.LastName = (cygateContact == null ? con.LastName : cygateContact.LastName);
        // Custom Fields Mapping
        newLead.Contact__c = con.Id;
        newLead.Description_Pardot__c = con.Description_Pardot__c;
        newLead.Additional_comments__c = con.Additional_comments__c;  // D.C New field for Form Handler.
        newLead.Form_Source__c = con.Form_Source__c;
        newLead.Form_Source_URL__c = con.Form_Source_URL__c;
        newLead.Product_Area__c = con.Product_Area__c;
        // The lead.Account__c lookup filter only allows Large/SME accounts, so will only set the lookup if true
        if(SEUtility.isLargeAccountRecordType(acc.RecordTypeId) || SEUtility.isSmeAccountRecordType(acc.RecordTypeId)){
            newLead.Account__c = con.AccountId;
        }
        // Submitter fields mapping
        newLead.Lead_Submitter_email__c = con.Lead_Submitter_email__c;
        newLead.Lead_Submitter_first_name__c = con.Lead_Submitter_first_name__c;
        newLead.Lead_Submitter_ID__c = con.Lead_Submitter_ID__c;
        newLead.Lead_Submitter_Last_name__c = con.Lead_Submitter_Last_name__c;
        newLead.Lead_Submitter_No__c = con.Lead_Submitter_No__c;
        newLead.Lead_Submitter_phone__c = con.Lead_Submitter_phone__c;
        system.debug('Line639:-'+newLead);
        return newLead;
    }
    
    // Author: Varma Alluri on 16.06.2017; SAEN-2411, When a new Contact is submitted or updated from Pardot (isCygateSync true)
    // Fields FirstName, LastName, Phone should be reset to original values
    private void cygateSyncResetNamePhoneFields(List<Contact> newList, Map<Id,Contact> oldMap){
        for(Contact newCon : newList){
            // For all Contacts where Pardot Sync is true, reset FirstName, LastName, Phone fields to original values
            if(oldMap != null && isCygateSync(newCon, oldMap.get(newCon.Id))){
                if(cygateLeadFormContactUpdateMap == null) cygateLeadFormContactUpdateMap = new Map<Id,Contact>(); 
                // Add Original FirstName, LastName, Phone values to cygateLeadFormContactUpdateMap in a new Contact
                cygateLeadFormContactUpdateMap.put(newCon.Id, new Contact(FirstName = newCon.FirstName, LastName = newCon.LastName, Phone = newCon.Phone));
                // Reset FirstName, LastName, Phone field values on new contacts
                Contact oldCon = oldMap.get(newCon.Id);
                newCon.FirstName = oldCon.FirstName;
                newCon.LastName = oldCon.LastName;
                newCon.Phone = oldCon.Phone;
            }
        } 
    }    
 
     private void deleteCampaignMembers(List<Contact> newList, Map<Id,Contact> oldMap){  // P.P
    
        List<Contact> conDeacList = new List<Contact>();
        SET<Id> conDeacIdSet = new SET<Id>();
        SET<CampaignMember> delCMSet = new SET<CampaignMember>();
        Map<Id,CampaignMember> delCMMap = new Map<Id,CampaignMember>();
         List<Account> accUpdateList = new List<Account>();
         
        for(Contact newcon:newList){
            // works only for customer contacts
            if(newCon.recordTypeId == SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CUSTOMER)){
                if(newcon.Deactivation_Date__c != NULL && (oldMap!= Null && oldMap.get(newCon.id).Deactivation_Date__c != newCon.Deactivation_Date__c))
                {
                    system.debug('inside the condn------->');
                    conDeacList.add(newCon);
                    conDeacIdSet.add(newCon.Id);
                    
                    //addition of changes for removing Contact as primary contact from related Account
                    if(newCon.Is_Primary_Contact__c == True){
                        id accId = newCon.AccountId;
                        Account acc = new Account(Id = accId);
                        acc.Primary_Contact__c = Null;
                        accUpdateList.add(acc);
                        
                    }
                }
            }
            
        }
        //SALEF-8392 changed the logic for SOQL query optimization,enclosed the whole logic starting from the query in a if block with "!conDeacIdSet.isEmpty()" 
        if (!conDeacIdSet.isEmpty()) {
         LIST<CampaignMember> CMList = [SELECT Id,CampaignId,Campaign.Status,ContactId FROM CampaignMember WHERE ContactId IN: conDeacIdSet];
        
        for(CampaignMember cm: CMList){
            if(cm.Campaign.Status != 'Completed' && cm.Campaign.Status != 'Aborted'){ 
                delCMSet.add(cm);
                delCMMap.put(cm.id,cm);
            }
        }
        if(delCMSet.size() > 0){
            delete delCMMap.values();
         }
        }
        if(accUpdateList.size()>0){
            update accUpdateList;
        }
    }
}