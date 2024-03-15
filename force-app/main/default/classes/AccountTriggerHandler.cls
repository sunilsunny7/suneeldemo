/**
About
-----
Description: AccountTriggerHandler on Account
Create date: 18.09-2015

Update History
--------------
Created Sep 2015 - V.M - Created
Updated Jan 2016 - A.N Changed list oppsToUpdate into a set oppsToUpdateSet to ensure that no opps are added twice to the update list. This behavior caused exceptions.
Updated Sep 2016 - A.N Merged in and refactored functionality from AccountAfter.Trigger, AccountServiceClass and AccountRollUp
Updated Sep 2016 - S.S - Case No 1867 : as we don't have Cygate Account Manager as the picklist value in Account Team Member so we changed it to Cygate - Kontoansvarig
at line 407
Updated Oct 2016 - N.G Created methods updateMarketingMailsOptOut, updateMarketingMailsOptOutOnChildAccInsert , updateManualUpdateAcc and updateDateManuallyUpdated              
Updated Oct 2016 - P.P Case 2090 : SOHO PR need to create Tasks related to KKNR Z101 so restricting Method 'updateParentAccountContactedDate' to work for this Account 
Updated Nov 2016 - D.C Case # 1766 : Update date field "Has_Child_No_Of_Days_Performed__c".
Updated Feb 2017 - A.N Case # 2391 : Updated method setParentAccountCurrentCustomer so that new field Customer_5_Mobile_PP_or_more is updated on KKnr.
Updated Mars 2017 - V.M - SAEN-2174 : Deleted N.G code and added processOptOut method
Updated Apr 2017 - C.M - Case #2894 : Implementing process builder (Account - Update Agreement Situation Owner)funtionality into trigger.
Updated June 2017 - S.S - Case 3445 : If Org account have Cygate Account Manager then they will be added in account team member with read access on opportunity & 
when we remove the cygate account manager then they will get deleted from account team member
Updated March 2018 - P.P - SALEF 668 : Service Manager functionality for Cygate
Updated April 2018 - P.S. - SALEF-858 : Telia Service Managers functionality (updateServiceManager)
Updated April 2018 - Y.K - SALEF-971 : 'Current Customer' field not getting updated correctly
Updated April 2018 - Y.K - SALEF- 977 : 'Customer 5 Mobile PP or more' field not getting updated correctly
Updated May 2018 - P.P - SLAEF-857 - created method updateCaseAccess to enable Owner and Telia SM access to related Cases
Updated Nov 2018 - S.S - SALEF 1615 - updated method updateServiceManager & Telia Service Manager Functionality for giving access to service manager.
Uodated Sept 2019 - P.S - SALEF-2396 - Updated method -setParentAccountCurrentCustomer() to update the logic for field -Customer_5_Mobile_PP_or_more__c.
Updated Jan 2020 - CM - Customer List - Updated method updateAccountRecords() and created new method onAccCreate()
21.01.2022 [Rimgaudas Urbonas] SALEF-5805 - Update parent KKNRs Larmlistan (Convergence) field values upon the same field 
            value updates in their child 'SME/SOHO Organisation' Accounts, usually occurring during Larmlistan Data uploads.
29.12.2022 [Tomass Brazovskis] SALEF-7949 - Modified the updateParentAccountContactedDate() method to determine the latest
            parent Accounts' 'Contacted Quality Meeting' dates.
19.01.2023 [Norbertas Skumbinas] SALEF-7940 - Modified 'updateLarmlistanDataFields' method to include the new Customer_Classification field updates.
SALEF-8200 - As part of SOQL query optimization in AccountTriggerHandler, modified the logic in setCountOfOpenOppOnKknr() & updateServiceManager()

SALEF-8400 - Introduced new field "Parent_Account_Change_date__c" to store the date when account owner is changed.

19.05.2023 [Tomass Brazovskis] LTAT-9938 - Modified 'updateLarmlistanDataFields' method to include the new Number_of_Convergence_areas field updates.
            mapActionNameToSetOfConsideredAccountIds introduced to avoid repeated KKNr updates within a single transaction.

05.06.2023 [Tomass Brazovskis] LTAT-9674 - Validate 'SME/SOHO Organisation' Account 'Customer_Success_Manager' assignments and
            update 'SME/SOHO Organisation' Account parent KKNr 'Customer_Success_Manager', if required.

*/
public class AccountTriggerHandler {

    /* * * * * * * * * * * * * * * * * * * * * */
    /* * AccountTriggerHandler Trigger Calls * */
    /* * * * * * * * * * * * * * * * * * * * * */

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static List<AccountTeamMember> atm;

    public AccountTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    private static boolean acc_isExecuting = false;


    public void OnBeforeUpdate(List < Account > newList, Map < ID, Account > newMap, List < Account > oldList, Map < ID, Account > oldMap) {
        System.debug('AccountTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        processOptOut(newList, oldMap);
        updateOpportunitiesActiveSellers(newMap, oldMap);
        //Populate Website Company domain -- SALEF-264
        populatewebsitedomain(newList);
        updateAccountRecords(newList, oldMap); // Part of Workflow optimization
        if (!System.isBatch()) {
            addTeamMemberOnKKNROwnerChange(newList, oldMap);
        }
        setUpParentKKNrCustomerSuccessMgrUpdate(newList, oldMap); //LTAT-9674
    }

    public void OnAfterInsert(List < Account > newList, Map < ID, Account > newMap) {
        System.debug('AccountTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        updateParentAccountContactedDate(newList, null);
        updateCygateAccountManagerOnKKnr(newList, null);
        checkParentSubAcc(newList);
        setParentHasChildAccounts(newList, null);
        addCygateAccountManagerinATMonOrg(newList, null);
        setCountOfOpenOppOnKknr(newList, null);
        sendEmail(newList, null);
        updateLarmlistanDataFields(newList, null);
        updateParentKKNrCustomerSuccessMgr(newList, null); //LTAT-9674 
    }
    public void OnBeforeInsert(List < Account > newList) {
        //Populate Website Company domain -- SALEF-264
        populatewebsitedomain(newList);
        updateAccountRecords(newList, null); // Part of Workflow optimization
        cygateSubAccountOptOut(newList, null);
        onAccCreate(newList);
        setUpParentKKNrCustomerSuccessMgrUpdate(newList, null); //LTAT-9674
    }

    public void OnAfterUpdate(List < Account > newList, Map < ID, Account > newMap, List < Account > oldList, Map < ID, Account > oldMap) {
        System.debug('AccountTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);

        updateParentAccountContactedDate(newList, oldMap);
        sendEmail(newList, oldMap);
//        setParentAccountCurrentCustomer(newList, oldMap);
        setExistingCustomer(newList, oldMap);
        updateLarmlistanDataFields(newList, oldMap);
        updateSolutionSalesOutcome(newList, oldMap);
        updateCygateAccountManagerOnKKnr(newList, oldMap);
        updateOpportunitySplits(newList, oldMap);
        checkParentSubAcc(newList);
        setParentHasChildAccounts(newList, oldMap);
        //updateAvtalSituationOwner(newList, oldMap); By C.M
        addCygateAccountManagerinATMonOrg(newList, oldMap);
        setCountOfOpenOppOnKknr(newList, oldMap);
        updateNamedSalesCoordinatorOnCases(newList, oldMap);
        updateCaseAccess(newList, oldMap);
        updateServiceManager(newList, oldMap);
        cygateSubAccountOptOut(newList, oldMap);
        if (!System.isBatch()) {
            addTeamMemberOnKKNROwnerChangeafter(newList, oldMap);
        }

        // This method will only run when the Skip_Trigger__c custom setting for AccountRollupTrigger has the PassMethod__c checkbox set to true.
        // It will force a recalculation of the Has_Child_Account__c for all the accounts passed in to the trigger.
        if (Skip_Trigger__c.getValues('AccountRollupTrigger') != null && Skip_Trigger__c.getValues('AccountRollupTrigger').PassMethod__c && !System.isFuture() && !System.isBatch()) {
            updateParentHasChildAccounts(newMap.keySet());
        }
        updateCygateAccountManagerOnLeadContact(newList, oldMap);
        updateParentKKNrCustomerSuccessMgr(newList, oldMap); //LTAT-9674
    }

    public void OnBeforeDelete(List < Account > oldList, Map < ID, Account > oldMap) {
        System.debug('AccountTriggerHandler.OnBeforeDelete starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        DeleteOnlyOMBAccount(oldList);
    }

    public void OnAfterDelete(List < Account > oldList, Map < ID, Account > oldMap) {
        System.debug('AccountTriggerHandler.OnAfterDelete starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);

        updateParentAccountContactedDate(oldList, null);
//        setParentAccountCurrentCustomer(oldList, null);
        setExistingCustomer(null, oldMap);
        updateCygateAccountManagerOnKKnr(null, oldMap);
        unCheckParentSubAcc(oldList);
        setParentHasChildAccounts(oldList, null);
        setCountOfOpenOppOnKknr(oldList, null);
        updateLarmlistanDataFields(oldList, null);
    }

    public void OnAfterUndelete(List < Account > newList, Map < ID, Account > newMap) {
        System.debug('AccountTriggerHandler.OnAfterUndelete starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);

        updateParentAccountContactedDate(newList, null);
//        setParentAccountCurrentCustomer(newList, null);
        setExistingCustomer(newList, null);
        setParentHasChildAccounts(newList, null);
        setCountOfOpenOppOnKknr(newList, null);
        updateLarmlistanDataFields(newList, null);

    }

    /* * * * * * * * * * * * * * * * * * * * * * */
    /* * AccountTriggerHandler Trigger Methods * */
    /* * * * * * * * * * * * * * * * * * * * * * */

    // Business Unit picklist definitions 
    public static final String ACCOUNT_BUSINESS_UNIT_PUBLIC_SECTOR = 'Public Sector';
    public static final String ACCOUNT_BUSINESS_UNIT_COPORORATE_CLIENTS = 'Corporate Clients';

    // LTAT-9938: Map to keep track of Accounts considered in some actions context, in case of trigger
    // recursions or repeated executions when # of triggering-records exceeds the batch size
    @TestVisible
    private static Map <String, Set<Id>> mapActionNameToSetOfConsideredAccountIds = new Map<String, Set<Id>>();

    // LTAT-9674: Populate Before child Customer_Success_Manager assignments and use
    // to update parent KKNr Customer_Success_Manager After valid child CSM assignments 
    @TestVisible
    private static Map <Id,Id> mapKKNrIdsToNewCustomerSuccessManagerIds = new Map<Id,Id>();

    /**
     * @Description:
     * Determine the latest 'Contacted...' dates for the 'SME/SOHO Organisation' Account 
     * parent Accounts upon the 'SME/SOHO Organisation' Account 'Contacted...' field updates.
     * @author V.I.
     * @param newList - List of the new versions of the Account records.
     * @param oldMap - A map of IDs to the old versions of the Account records.
     * @Modifications:
     * 29.12.2022 [TB] SALEF-7949 - Determine the latest parent Accounts' 'Contacted Quality Meeting' dates.
     * 11.2021 [Aurimas Nausutis] SALEF-5324 - Determine the latest parent Account 'SME: Contacted MyBusiness' dates.
     * 09.2016 [A.N.] - Merged from AccountAfter.trigger/AccountServiceClass.
     * 03.2015 [V.I.] - Introduced. Calculate the parent accounts latest contact date for all SME Org Accounts.
     **/
    private static void updateParentAccountContactedDate(List < Account > newList, Map < ID, Account > oldMap) {
        Set < Id > parentAccountIds = new Set < Id > ();
        String accRef = Label.Account_ID_to_Bypass_for_Tasks;

        // Filter: All SME Org Accounts with Parent account and where Contacted__ is changed (or not null if new/deleted/undeleted)
        for (Account acc : newList) {
            if (acc.ParentId != null
                    && !acc.Bearbetas_ej__c
                    && acc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME))
                    && acc.ParentID != accRef
                    && acc.OwnerId != System.Label.IntegrationUser //SALEF-7949
            ){
                // SALEF-7949 - Added 'Contacted Quality Meeting' to the criteria,
                // and adjusted criteria for conciseness
                if( (   oldMap == null
                        && !(   acc.Contacted__c == null
                        && acc.SME_Contacted_MyBusiness__c == null
                        && acc.Contacted_Quality_Meeting__c == null))
                        || (   oldMap != null
                        && !(   acc.Contacted__c == oldMap.get(acc.Id).Contacted__c
                        && acc.SME_Contacted_MyBusiness__c == oldMap.get(acc.Id).SME_Contacted_MyBusiness__c
                        && acc.Contacted_Quality_Meeting__c == oldMap.get(acc.Id).Contacted_Quality_Meeting__c))
                ){
                    parentAccountIds.add(acc.ParentId);
                }
            }
        }

        // Update Contacted__c on Parent accounts
        // SALEF-7949 - Bypass Integration User-owned Accounts, as they have a very large number of
        // child Accounts, causing the SOQL query to hit a governor limit
        if (!parentAccountIds.isEmpty()) {
            Map < Id, Account > parentToUpdate = new Map < Id, Account > ();
            for (AggregateResult ar : [
                    SELECT  ParentId accountId,
                            MAX(Contacted__c) latestDate,
                            MAX(SME_Contacted_MyBusiness__c) latestDateMB,
                            MAX(Contacted_Quality_Meeting__c) latestQualMeetingDate //SALEF-7949
                    FROM Account
                    WHERE ParentId IN: parentAccountIds
                    AND Parent.OwnerId != :System.Label.IntegrationUser //SALEF-7949
                    AND Bearbetas_Ej__c = false
                    AND (   Contacted__c != null
                    OR SME_Contacted_MyBusiness__c != null
                    OR Contacted_Quality_Meeting__c != null)
                    GROUP BY ParentId
            ]) {
                Account account = new Account();
                account.Id = (Id) ar.get('accountId');
                account.Contacted__c = (Date) ar.get('latestDate');
                account.SME_Contacted_MyBusiness__c = (Date) ar.get('latestDateMB');
                account.Contacted_Quality_Meeting__c = (Date) ar.get('latestQualMeetingDate');
                parentToUpdate.put(account.Id, account);
            }

            // If the parentAccount is not in the result list, meaning the last one was deleted,
            // clear the Contacted__c on parent account
            for (Id parentAccountId : parentAccountIds) {
                if (!parentToUpdate.containsKey(parentAccountId)) {
                    parentToUpdate.put(parentAccountId,
                            new Account(Id = parentAccountId,
                                    Contacted__c = null,
                                    SME_Contacted_MyBusiness__c = null,
                                    Contacted_Quality_Meeting__c = null)
                    );
                }
            }
            update parentToUpdate.values();
        }
    }

    public static void sendEmail(List < Account > Accounts, map < id, Account > OldAccounts) {
        //query on template object
        //EmailTemplate et = [Select id from EmailTemplate where name =: 'Cygate Owner Change on Account'];

        Id et = Label.CygateAccOwnerChangeTemplateId;

        //list of emails
        List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage > ();

        //Creating Dummy contact for Using in Target object Id
        //contact conObj = [select id from contact LIMIT 1];
        string conObjid = System.Label.Email_Contact_Id;
        set < Id > AccountIds = new set < Id > ();
        for (Account Acc : Accounts) {
            // if((Acc.Cygate_Account_Manager__c != null && Acc.Send_Email__c != null) || ( OldAccounts != null && Acc.Cygate_Account_Manager__c != OldAccounts.get(Acc.Id).Cygate_Account_Manager__c)){
            boolean run = false;
            if (OldAccounts == null && Acc.Cygate_Account_Manager__c != null) run = true;
            if (OldAccounts != null) {
                if (Acc.Cygate_Account_Manager__c != null && Acc.Cygate_Account_Manager__c != OldAccounts.get(Acc.Id).Cygate_Account_Manager__c || Acc.Send_Email__c != OldAccounts.get(Acc.Id).Send_Email__c)
                    run = true;
            }
            if (run && Acc.Send_Email__c && Acc.Cygate_Account_Manager__c != null) {
                AccountIds.add(Acc.id);
            }
        }
        if (AccountIds.size() > 0) {
            List < Account > AccountList = [select id, Cygate_Account_Manager__c, Cygate_Account_Manager__r.Email from Account where Id IN:AccountIds];
            for (Account Acc : AccountList) {
                //initiallize messaging method
                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[]{
                        Acc.Cygate_Account_Manager__r.Email
                };

                //set To Address
                singleMail.settoaddresses(toAddresses);

                //set object Id 
                singleMail.setTargetObjectId(conObjid);
                //singleMail.setTargetObjectId('0030Q00000pxWLU');

                //set template Id
                //singleMail.setTemplateId(et.Id);
                singleMail.setTemplateId(et);

                singleMail.setwhatId(Acc.id);

                //flag to false to stop inserting activity history
                singleMail.setSaveAsActivity(false);

                //add mail
                emails.add(singleMail);

            }

            //send mail
            Messaging.sendEmail(emails);
        }
    }


    /**
    * @description Method to update Existing_Customer__c custom field value on Kundkonto account when it's set on any of the child org. accounts.
    * @Jira - SALEF-4207
    * @author Edgaras Jasinskij
    * @date 15.02.2020
    **/
    private static void setExistingCustomer(List <Account> newList, Map <Id, Account> oldMap) {
        Set<Id> parentAccountIds = new Set<Id>();
        Map<Id, Account> parentsToUpdate = new Map<Id, Account>();
        List<Boolean> childCustomerStatus = new List<Boolean>();


        if (newList != null) {
            for (Account acc : newList) {
                if (oldMap != null && acc.ParentId != null && acc.Existing_Customer__c == true && oldMap.get(acc.id).Existing_Customer__c == false && acc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME))) {
                    parentAccountIds.add(acc.ParentId);
                } else if (oldMap != null && acc.ParentId != null && acc.Existing_Customer__c == false && oldMap.get(acc.id).Existing_Customer__c == true && acc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME))) {
                    parentAccountIds.add(acc.ParentId);
                } else if (oldMap == null && acc.ParentId != null && acc.Existing_Customer__c == true && acc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME))) {
                    parentAccountIds.add(acc.ParentId);

                }
            }

        } else {
            for (Account deletedAcc : oldMap.values()) {
                if (oldMap != null && deletedAcc.ParentId != null && deletedAcc.Existing_Customer__c == true && deletedAcc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME))) {
                    parentAccountIds.add(deletedAcc.ParentId);

                }
            }
        }
        if (!parentAccountIds.isEmpty()) {
            for (Account parent : [SELECT Id, Existing_Customer__c, (SELECT Id, Existing_Customer__c FROM ChildAccounts) FROM Account WHERE Id IN :parentAccountIds]) {
                if (parent.Existing_Customer__c == false) {
                    parent.Existing_Customer__c = true;
                    parentsToUpdate.put(parent.Id, parent);
                } else if (parent.Existing_Customer__c == true) {
                    for (Account child : parent.ChildAccounts) {
                        childCustomerStatus.add(child.Existing_Customer__c);
                    }

                    if (!childCustomerStatus.contains(true)) {
                        parent.Existing_Customer__c = false;
                        parentsToUpdate.put(parent.Id, parent);
                    }

                }
            }

        }
        if (!parentsToUpdate.isEmpty()) {
            update new List <Account> (parentsToUpdate.values());
        }

    }

    /**
     * @Description:
     * Update parent KKNRs Larmlistan (Convergence) field values upon the same
     * field value updates in their child 'SME/SOHO Organisation' Accounts, usually
     * occurring during Larmlistan Data uploads.
     * @author Rimgaudas Urbonas
     * @param newList - List of the new versions of the Account records.
     * @param oldMap - A map of IDs to the old versions of the Account records.
     * @Modifications:
     * 19.05.2023 [TB] LTAT-9938 - Logic added for the new Number_of_Convergence_areas field updates.
     * 19.01.2023 [NS] SALEF-7940 - Method renamed as 'updateLarmlistanDataFields' and logic added
     *              for the new Customer_Classification field updates. 
     * 21.01.2022 [RU] SALEF-5805 - Introduced. 
     **/
    private static void updateLarmlistanDataFields(List <Account> newList, Map <Id, Account> oldMap) {
        Set<Id> parentAccountIds = new Set<Id>();
        Map<Id, Account> parentsToUpdate = new Map<Id, Account>();
        if (newList != null) {
            for (Account acc : newList) {
                if (acc.ParentId != null
                    && acc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME))
                    && ((   oldMap != null
                            && (acc.Convergence__c != oldMap.get(acc.id).Convergence__c 
                                || acc.Mobile__c != oldMap.get(acc.id).Mobile__c 
                                || acc.Connection__c != oldMap.get(acc.id).Connection__c
                                || acc.Switch__c != oldMap.get(acc.id).Switch__c
                                || acc.IT__c != oldMap.get(acc.id).IT__c
                                || acc.Applications__c != oldMap.get(acc.id).Applications__c 
                                || acc.Customer_Classification__c != oldMap.get(acc.id).Customer_Classification__c
                                || acc.Number_of_Convergence_areas__c != oldMap.get(acc.id).Number_of_Convergence_areas__c))
                        || (oldMap == null
                            && (acc.Convergence__c == true 
                                || acc.Mobile__c == true 
                                || acc.Connection__c == true
                                || acc.Switch__c == true 
                                || acc.IT__c == true 
                                || acc.Applications__c == true 
                                || acc.Customer_Classification__c != null
                                || acc.Number_of_Convergence_areas__c != null)))
                ){
                    parentAccountIds.add(acc.ParentId);
                }
            }
        }

        if (!parentAccountIds.isEmpty()) {
            for (Account parent : [ SELECT  Id, Convergence__c, Mobile__c, Connection__c, 
                                            Switch__c, IT__c, Applications__c, Customer_Classification__c,
                                            Number_of_Convergence_areas__c,
                                            (   SELECT  Id, Mobile__c, Convergence__c, Connection__c,
                                                        Switch__c, IT__c, Applications__c, 
                                                        Customer_Classification__c, Number_of_Convergence_areas__c, LastModifiedDate
                                                FROM ChildAccounts
                                                WHERE RecordTypeId = :SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME)
                                                ORDER BY LastModifiedDate ASC ) // LTAT-9938
                                            FROM Account
                                            WHERE Id IN :parentAccountIds
            ]){
                parent.Mobile__c = false;
                parent.Convergence__c = false;
                parent.Connection__c = false;
                parent.Switch__c = false;
                parent.IT__c = false;
                parent.Applications__c = false;
                parent.Customer_Classification__c = null;
                parent.Number_of_Convergence_areas__c = null;
                parentsToUpdate.put(parent.Id, parent);
                
                for (Account child : parent.ChildAccounts) {
                    // SALEF-5805 - A Parent KKNr Larmlistan checkbox must be checked, as long as
                    // any of its child SME Accounts have their corresponding checkboxes checked
                    if(child.Mobile__c == true) {
                        parent.Mobile__c = true;
                    }
                    if(child.Convergence__c == true) {
                        parent.Convergence__c = true;
                    }
                    if(child.Connection__c == true) {
                        parent.Connection__c = true;
                    }
                    if(child.Switch__c == true) {
                        parent.Switch__c = true;
                    }
                    if(child.IT__c == true) {
                        parent.IT__c = true;
                    }
                    if(child.Applications__c == true) {
                        parent.Applications__c = true;
                    }
                    // SALEF-7940/LTAT-9938 - A Parent KKNr Larmlistan non-checkbox field must be populated
                    // with the value of its most recently updated child SME Account's corresponding field
                    if(child.Customer_Classification__c != null) {
                        parent.Customer_Classification__c = child.Customer_Classification__c;
                    }
                    if(child.Number_of_Convergence_areas__c != null) {
                        parent.Number_of_Convergence_areas__c = child.Number_of_Convergence_areas__c;
                    }
                }
            }
        }
        if (!parentsToUpdate.isEmpty()) {
            update new List <Account> (parentsToUpdate.values());
        }
    }

    //Below has been commented out as per SALEF-4207
    // Merged from AccountAfter.trigger/AccountServiceClass September 2016 A.N
    // If SME Org Accounts with Parent account and where More_Than_10_Postpaid__c = true, set parent account field Current_Customer__c = true
    // If SME Org Accounts with Parent account and where X5_or_more_Mobile_Postpaid_Subscriptions__c = true, set parent account field Customer_5_Mobile_PP_or_more__c = true

//    private static void setParentAccountCurrentCustomer(List < Account > newList, Map < ID, Account > oldMap) {
//        //Set<Id> parentAccountIds = new Set<Id>();
//        Set < Id > parentAccChildMoreThan10Ids = new Set < Id > ();
//        Set < Id > parentAccChild5orMoreIds = new Set < Id > ();
//        //Excluding the records from the CS -'Excluded Records', due to Governer limits
//        ExcludedRecords__c exclRecords = ExcludedRecords__c.getInstance('AcntRollUpExcludedRecords');
//        ExcludedRecords__c exclRecords2 = ExcludedRecords__c.getInstance('actExcludedAccounts');
//        ExcludedRecords__c exclRecords3 = ExcludedRecords__c.getInstance('excludedAccsATMhandler');
//
//        String stringExclRecords = '';
//        If(!Test.isRunningTest()) {
//            stringExclRecords = exclRecords.Excluded_Records_List__c + ',' + exclRecords2.Excluded_Records_List__c + ',' + exclRecords3.Excluded_Records_List__c;
//        }
//        List < Id > exclRecordIds = new List < Id > ();
//        Set < Id > setExclRecordIds = new Set < Id > ();
//        if (stringExclRecords != Null && stringExclRecords.length() > 0 && !Test.isRunningTest()) {
//            exclRecordIds = stringExclRecords.split(',');
//        }
//        for (Id acId: exclRecordIds) {
//            setExclRecordIds.add(acId);
//        }
//
//        // Filter: All SME Org Accounts with Parent account and where More_Than_10_Postpaid__c is changed and/or X5_or_more_Mobile_Postpaid_Subscriptions__c (or true null if deleted/undeleted)
//        for (Account acc: newList) {
//            if (acc.ParentId != null && !acc.Bearbetas_ej__c && acc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME))) {
//                //Current_customer updation for reparenting--SALEF 971
//                /* if ((oldMap != null && acc.ParentId != oldMap.get(acc.id).ParentId) && acc.More_Than_10_Postpaid__c == true)
//parentAccChildMoreThan10Ids.add(acc.ParentId);
//if (oldMap != null && acc.ParentId != oldMap.get(acc.id).ParentId)
//parentAccChildMoreThan10Ids.add(oldMap.get(acc.id).ParentId);
//
//if ((oldMap != null && acc.More_Than_10_Postpaid__c != oldMap.get(acc.Id).More_Than_10_Postpaid__c) || (oldMap == null && acc.More_Than_10_Postpaid__c == true))
//parentAccChildMoreThan10Ids.add(acc.ParentId);*/
//                if ((oldMap != null && acc.ParentId != oldMap.get(acc.id).ParentId))
//                    parentAccChildMoreThan10Ids.add(acc.ParentId);
//
//                if (oldMap != null && acc.ParentId != oldMap.get(acc.id).ParentId)
//                    parentAccChildMoreThan10Ids.add(oldMap.get(acc.id).ParentId);
//
//                if ((oldMap != null && acc.Mobile_Postpaid__c != oldMap.get(acc.Id).Mobile_Postpaid__c && acc.Mobile_Postpaid__c > 0) || (oldMap != null && acc.Mobile_Postpaid__c != oldMap.get(acc.Id).Mobile_Postpaid__c && acc.Mobile_Postpaid__c < 11) || (oldMap == null && acc.Mobile_Postpaid__c > 0))
//                    parentAccChildMoreThan10Ids.add(acc.ParentId);
//
//                //'Customer 5 Mobile PP or more'  updation for reparenting--SALEF 977
//                if ((oldMap != null && acc.ParentId != oldMap.get(acc.id).ParentId) && acc.Mobile_Postpaid__c > 0 && acc.parent.Customer_5_Mobile_PP_or_more__c == false && !setExclRecordIds.contains(acc.ParentId))
//                    parentAccChild5orMoreIds.add(acc.ParentId);
//                if (oldMap != null && acc.ParentId != oldMap.get(acc.id).ParentId && !setExclRecordIds.contains(oldMap.get(acc.id).ParentId))
//                    parentAccChild5orMoreIds.add(oldMap.get(acc.id).ParentId);
//
//                //if((oldMap != null && acc.X5_or_more_Mobile_Postpaid_Subscriptions__c != oldMap.get(acc.Id).X5_or_more_Mobile_Postpaid_Subscriptions__c) || (oldMap == null && acc.X5_or_more_Mobile_Postpaid_Subscriptions__c == true))
//                if ((oldMap != null && acc.Mobile_Postpaid__c != oldMap.get(acc.Id).Mobile_Postpaid__c && acc.Mobile_Postpaid__c > 0 && acc.parent.Customer_5_Mobile_PP_or_more__c == false) || (oldMap != null && acc.Mobile_Postpaid__c != oldMap.get(acc.Id).Mobile_Postpaid__c && acc.Mobile_Postpaid__c < 8) || (oldMap == null && acc.Mobile_Postpaid__c > 0))
//                    parentAccChild5orMoreIds.add(acc.ParentId);
//            }
//        }
//
//        Map < Id, Account > parentToUpdateMap = new Map < Id, Account > ();
//        Map < Id, Decimal > NoOPostpaidMap = new Map < Id, Decimal > ();
//        Decimal noOfMobilePostpaid = 0;
//
//        // Update Current_Customer__c on Parent accounts if child acc More_Than_10_Postpaid__c is changed
//        /*  if (!parentAccChildMoreThan10Ids.isEmpty()) {
//for (Account parent: [SELECT Id, Current_Customer__c,
//(SELECT Id FROM ChildAccounts WHERE More_Than_10_Postpaid__c = true AND Bearbetas_Ej__c = false LIMIT 1)
//FROM Account WHERE Id IN: parentAccChildMoreThan10Ids
//]) {
//// If child list is empty, set parent.Current_Customer__c = false, otherwise true. Only update parent if value has changed.
//if (parent.Current_Customer__c == true && parent.ChildAccounts.isEmpty()) {
//parent.Current_Customer__c = false;
//parentToUpdateMap.put(parent.Id, parent);
//} else if (parent.Current_Customer__c == false && !parent.ChildAccounts.isEmpty()) {
//parent.Current_Customer__c = true;
//parentToUpdateMap.put(parent.Id, parent);
//}
//}
//}*/
//        if (!parentAccChildMoreThan10Ids.isEmpty()) {
//            for (Account parent: [SELECT Id, Current_Customer__c,
//                    (SELECT Id, Mobile_Postpaid__c FROM ChildAccounts WHERE Mobile_Postpaid__c > 0 AND Bearbetas_Ej__c = false limit 15)
//                    FROM Account WHERE Id IN: parentAccChildMoreThan10Ids
//                ]) {
//
//                for (Account child: parent.childaccounts) {
//                    //Getting count for noOfMobilePostpaid
//                    if (NoOPostpaidMap.containsKey(parent.Id)) {
//                        noOfMobilePostpaid = NoOPostpaidMap.get(parent.Id);
//                        noOfMobilePostpaid += (child.Mobile_Postpaid__c == null ? 0 : child.Mobile_Postpaid__c);
//                        NoOPostpaidMap.put(parent.Id, noOfMobilePostpaid);
//                        if (NoOPostpaidMap.get(parent.Id) > 10)
//                            break;
//                    } else {
//                        noOfMobilePostpaid = 0;
//                        noOfMobilePostpaid += (child.Mobile_Postpaid__c == null ? 0 : child.Mobile_Postpaid__c);
//                        NoOPostpaidMap.put(parent.Id, noOfMobilePostpaid);
//                        if (NoOPostpaidMap.get(parent.Id) > 10)
//                            break;
//                    }
//
//                }
//                // If child list is empty, set parent.Current_Customer__c = false, otherwise true if it has more than 7 Postpaid.
//                if (parent.Current_Customer__c == true && parent.ChildAccounts.isEmpty()) {
//                    if (parentToUpdateMap.containsKey(parent.Id))
//                        parent = parentToUpdateMap.get(parent.Id);
//                    parent.Current_Customer__c = false;
//                    parentToUpdateMap.put(parent.Id, parent);
//
//                } else if (parent.Current_Customer__c == false && !parent.ChildAccounts.isEmpty() && NoOPostpaidMap.get(parent.Id) > 9) {
//                    if (parentToUpdateMap.containsKey(parent.Id))
//                        parent = parentToUpdateMap.get(parent.Id);
//                    parent.Current_Customer__c = true;
//                    parentToUpdateMap.put(parent.Id, parent);
//                    //Setting back the noOfMobilePostpaid to 0 for another KKNR in case of Bulk update.
//                    noOfMobilePostpaid = 0;
//                } else if (NoOPostpaidMap.get(parent.Id) < 10 && parent.Current_Customer__c == true) {
//                    if (parentToUpdateMap.containsKey(parent.Id))
//                        parent = parentToUpdateMap.get(parent.Id);
//                    parent.Current_Customer__c = false;
//                    parentToUpdateMap.put(parent.Id, parent);
//                    noOfMobilePostpaid = 0;
//                }
//
//            }
//        }
//
//        // Update Customer_5_Mobile_PP_or_more__c on Parent accounts accordingly if Mobile_Postpaid__c is changed
//        if (!parentAccChild5orMoreIds.isEmpty()) {
//            for (Account parent: [SELECT Id, Customer_5_Mobile_PP_or_more__c,
//                    (SELECT Id, Mobile_Postpaid__c FROM ChildAccounts WHERE Mobile_Postpaid__c > 0 AND Bearbetas_Ej__c = false limit 10)
//                    FROM Account WHERE Id IN: parentAccChild5orMoreIds
//                ]) {
//
//                for (Account child: parent.childaccounts) {
//                    //Getting count for noOfMobilePostpaid
//                    if (NoOPostpaidMap.containsKey(parent.Id)) {
//                        noOfMobilePostpaid = NoOPostpaidMap.get(parent.Id);
//                        noOfMobilePostpaid += (child.Mobile_Postpaid__c == null ? 0 : child.Mobile_Postpaid__c);
//                        NoOPostpaidMap.put(parent.Id, noOfMobilePostpaid);
//                        if (NoOPostpaidMap.get(parent.Id) > 7)
//                            break;
//                    } else {
//                        noOfMobilePostpaid = 0;
//                        noOfMobilePostpaid += (child.Mobile_Postpaid__c == null ? 0 : child.Mobile_Postpaid__c);
//                        NoOPostpaidMap.put(parent.Id, noOfMobilePostpaid);
//                        if (NoOPostpaidMap.get(parent.Id) > 7)
//                            break;
//                    }
//
//                }
//                // If child list is empty, set parent.Customer_5_Mobile_PP_or_more__c = false, otherwise true if it has more than 7 Postpaid.
//                if (parent.Customer_5_Mobile_PP_or_more__c == true && parent.ChildAccounts.isEmpty()) {
//                    if (parentToUpdateMap.containsKey(parent.Id))
//                        parent = parentToUpdateMap.get(parent.Id);
//                    parent.Customer_5_Mobile_PP_or_more__c = false;
//                    parentToUpdateMap.put(parent.Id, parent);
//
//                } else if (parent.Customer_5_Mobile_PP_or_more__c == false && !parent.ChildAccounts.isEmpty() && NoOPostpaidMap.get(parent.Id) > 6) {
//                    if (parentToUpdateMap.containsKey(parent.Id))
//                        parent = parentToUpdateMap.get(parent.Id);
//                    parent.Customer_5_Mobile_PP_or_more__c = true;
//                    parentToUpdateMap.put(parent.Id, parent);
//                    //Setting back the noOfMobilePostpaid to 0 for another KKNR in case of Bulk update.
//                    noOfMobilePostpaid = 0;
//                } else if (NoOPostpaidMap.get(parent.Id) < 7 && parent.Customer_5_Mobile_PP_or_more__c == true) {
//                    if (parentToUpdateMap.containsKey(parent.Id))
//                        parent = parentToUpdateMap.get(parent.Id);
//                    parent.Customer_5_Mobile_PP_or_more__c = false;
//                    parentToUpdateMap.put(parent.Id, parent);
//                    noOfMobilePostpaid = 0;
//                }
//
//            }
//        }
//
//        if (!parentToUpdateMap.isEmpty()) update new List < Account > (parentToUpdateMap.values());
//    }

    // Merged from AccountAfter.trigger/AccountServiceClass September 2016 A.N
    // When account record type is changed from SME to Large or vice versa, create/delete Solution Sales Outcome records respectively
    private static void updateSolutionSalesOutcome(List < Account > newList, Map < Id, Account > oldMap) {
        Set < Id > smeToLargeAccountIds = new Set < Id > ();
        Set < Id > largeToSmeAccountIds = new Set < Id > ();

        // Filter: Accounts where record type is changed from SME to Large or vice versa
        for (Account acc : newList) {
            if (SEUtility.isSmeAccountRecordType(acc.RecordTypeId) && SEUtility.isLargeAccountRecordType(oldMap.get(acc.Id).RecordTypeId)) {
                largeToSmeAccountIds.add(acc.Id);
            } else if (SEUtility.isLargeAccountRecordType(acc.RecordTypeId) && SEUtility.isSmeAccountRecordType(oldMap.get(acc.Id).RecordTypeId)) {
                smeToLargeAccountIds.add(acc.Id);
            }
        }

        // Delete all Sales_Outcome_Solutions__c-records for the opportunities related to the accounts changing from Large to SME
        if (largeToSmeAccountIds.size() > 0) {
            SolutionsSalesOutcomeServiceClass.deleteExistingRecords([SELECT Id FROM Opportunity WHERE AccountId in:largeToSmeAccountIds]);
        }
        // Create Sales_Outcome_Solutions__c-records for the opportunities related to the accounts changing from SME to Large
        if (smeToLargeAccountIds.size() > 0) {
            OpportunityTriggerHandler.createSolutionSalesOutcomeRecords([SELECT Id, IsWon, OwnerId, recordtypeId, CloseDate, AccountId FROM Opportunity WHERE AccountId in:smeToLargeAccountIds]);
        }
    }

    // Merged from AccountAfter.trigger/AccountRollUp September 2016 A.N
    // Updates the checkbox Has_Child_Account__c on the parent record
    private static void setParentHasChildAccounts(List < Account > newList, Map < ID, Account > oldMap) {
        Set < Id > parentAccountIds = new Set < Id > ();

        // Filter: Accounts with parent accounts
        for (Account acc : newList) {
            if (oldMap == null && acc.ParentId != null) {
                parentAccountIds.add(acc.ParentId);
            } else if (oldMap != null && acc.ParentId != oldMap.get(acc.Id).ParentId) {
                parentAccountIds.add(acc.ParentId);
                parentAccountIds.add(oldMap.get(acc.Id).ParentId);
            }
        }

        if (parentAccountIds.size() > 0) {
            if (!System.isFuture() && !System.isBatch()) { // Need to ensure that we are not in future context before calling an @future method.
                try {
                    updateParentHasChildAccounts(parentAccountIds);
                } catch (Exception e) {
                    SEUtility.sendExceptionMail('Exception in Future method setParentHasChildAccounts in AccountTriggerHandler', e, new List < Id > (parentAccountIds));
                }
            }
        }
    }

    // Needs to be run @future, because if both parent/child are in the Trigger.new List, we might update the parent record twice.
    // Same object update is not allowed in one instance and will cause an exception.
    @future
    public static void updateParentHasChildAccounts(Set < Id > parentAccountIds) {
        List < Account > parentToUpdate = new List < Account > ();
        for (Account parent : [
                SELECT Id, Has_Child_Account__c, (SELECT Id FROM ChildAccounts LIMIT 1)
                FROM Account
                WHERE Id IN:parentAccountIds
        ]) {
            // If child list is empty, set parent.Has_Child_Account__c = false, otherwise true. Only update parent if value has changed.
            if (parent.Has_Child_Account__c == true && parent.ChildAccounts.isEmpty()) {
                parent.Has_Child_Account__c = false;
                //parent.Customer_5_Mobile_PP_or_more__c = false;
                // D.C - Update the date file Has_Child_No_Of_Days_Performed to Current date.
                parent.Has_Child_No_Of_Days_Performed__c = system.today();
                parentToUpdate.add(parent);
            } else if (parent.Has_Child_Account__c == false && !parent.ChildAccounts.isEmpty()) {
                parent.Has_Child_Account__c = true;
                //D.C - Update the date file to Null.
                parent.Has_Child_No_Of_Days_Performed__c = NULL;
                parentToUpdate.add(parent);
            }
        }

        if (!parentToUpdate.isEmpty()) {
            if (test.IsRunningTest()) {
                System.runAs(new User(Id = Userinfo.getUserId())) {
                    database.update(parentToUpdate);
                }
            } else {
                database.update(parentToUpdate);
            }
        }
    }

    // Author V.M
    private void updateOpportunitiesActiveSellers(Map < Id, Account > newMap, Map < Id, Account > oldMap) {
        Map < Id, Account > largeAccs = new Map < Id, Account > ();
        Set < Id > ownerIds = new Set < Id > ();
        Set < Id > accIds = new Set < Id > ();

        for (Account acc : newMap.values()) {
            //If it is Large Account and Owner is changed
            if (SEUtility.isLargeAccountRecordType(acc.RecordTypeId) && oldMap.get(acc.Id).OwnerId != acc.OwnerId) {
                ownerIds.add(acc.OwnerId);
                accIds.add(acc.Id);
                largeAccs.put(acc.Id, acc);
            }
        }

        if (largeAccs.size() > 0 && ownerIds.size() > 0) {
            //Get all the Active Account Seller records so we can replace the old Opportunity Seller record.
            Map < Id, Seller__c > activeAccSellers = new Map < Id, Seller__c > ([
                    SELECT Id, User__r.Id, Start_Date__c, End_Date__c
                    FROM Seller__c
                    WHERE User__r.Id IN:ownerIds AND Start_Date__c <= TODAY AND End_Date__c >= TODAY
            ]);

            //Get all Large Opportunities that is connected to all Large Accounts with Account Owner changed.
            List < Opportunity > largeOpps = [
                    SELECT Id, Account.OwnerId, Account.Id, RecordType.Id, Seller__c
                    FROM Opportunity
                    WHERE Account.Id IN:accIds AND isClosed = false AND RecordType.Id IN:SEUtility.getLargeOppRectypeIds()
            ];

            if (largeOpps.size() > 0) {
                //Opportunities we want to update with the Accounts Owners Active Seller record.        
                Set < Opportunity > oppsToUpdateSet = new Set < Opportunity > ();
                for (Opportunity opp : largeOpps) {
                    Id accOwnerId;
                    if (opp.AccountId != null) {
                        accOwnerId = largeAccs.get(opp.AccountId).OwnerId;
                        Boolean hasActive = false;
                        for (Seller__c seller : activeAccSellers.values()) {
                            //Here we change the old Opportunity Seller to the new Active Owner Seller record of the Large Account.                         
                            if (seller.User__c == accOwnerId) {
                                opp.Seller__c = seller.Id;
                                oppsToUpdateSet.add(opp);
                                hasActive = true;
                            }
                        }
                        if (!hasActive && !SEUtility.isBypassValidation()) {
                            newMap.get(opp.AccountId).addError('New Account Owner needs to have a active seller record.');
                        }
                    }
                }

                if (!oppsToUpdateSet.isEmpty()) {
                    List < Opportunity > oppsToUpdate = new List < Opportunity > (oppsToUpdateSet);
                    update oppsToUpdate;
                }
            }
        }
    }

    //Author P.S - To update the Telia_Service_Manager from Parent Account to all its Child Accounts

    public static void updateServiceManager(List < Account > newList, Map < Id, Account > oldMap) {

        //Excluding the records from the CS -'Excluded Records', due to Governer limits
        ExcludedRecords__c exclRecords = ExcludedRecords__c.getInstance('AcntRollUpExcludedRecords');
        ExcludedRecords__c exclRecords2 = ExcludedRecords__c.getInstance('actExcludedAccounts');
        ExcludedRecords__c exclRecords3 = ExcludedRecords__c.getInstance('excludedAccsATMhandler');

        String stringExclRecords = '';
        If (!Test.isRunningTest()) {
            stringExclRecords = exclRecords.Excluded_Records_List__c + ',' + exclRecords2.Excluded_Records_List__c + ',' + exclRecords3.Excluded_Records_List__c;
        }
        List < Id > exclRecordIds = new List < Id > ();
        Set < Id > setExclRecordIds = new Set < Id > ();
        if (stringExclRecords != Null && stringExclRecords.length() > 0 && !Test.isRunningTest()) {
            exclRecordIds = stringExclRecords.split(',');
        }
        for (Id acId : exclRecordIds) {
            setExclRecordIds.add(acId);
        }

        string Large_RECORDTYPEID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        string Large_Sak1_RECORDTYPEID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC1);
        string Large_sak2_RECORDTYPEID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC2);

        Map < Id, Account > updateMapAcc = new Map < Id, Account > ();
        for (Account p : newList) { //S.S removed null check so that if KKNR is null the org acc should be null
            if (OldMap != null && p.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK)) && (oldMap.get(p.Id).Telia_Service_Manager__c != p.Telia_Service_Manager__c || oldMap.get(p.Id).LifeCycle_Manager__c != p.LifeCycle_Manager__c || oldMap.get(p.Id).Change_Manager__c != p.Change_Manager__c) && !setExclRecordIds.contains(p.Id)) {
                // Account pList = [SELECT id,Telia_Service_Manager__c,RecordTypeId from Account WHERE id = : p.Id];
                updateMapAcc.put(p.Id, p);
            }
        }
        List < Account > childToUpdate = new List < Account > ();
        //SALEF-8200 changed the logic for SOQL query optimization
        if (!updateMapAcc.isEmpty()) {
            //S.S - added large account check so that only the large org tagged to kknr should come
            for (Account child : [SELECT id, Telia_Service_Manager__c, ParentId from Account WHERE ParentId = :updateMapAcc.keySet() and (RecordTypeId = :Large_RECORDTYPEID OR RecordTypeId = :Large_Sak1_RECORDTYPEID OR RecordTypeId = :Large_sak2_RECORDTYPEID)]) {
                if (oldMap.get(child.ParentId).Telia_Service_Manager__c != updateMapAcc.get(child.ParentId).Telia_Service_Manager__c) //Updating only if Telia Service Manager is changed on KKNR
                    child.Telia_Service_Manager__c = updateMapAcc.get(child.ParentId).Telia_Service_Manager__c;
                if (oldMap.get(child.ParentId).LifeCycle_Manager__c != updateMapAcc.get(child.ParentId).LifeCycle_Manager__c) //Updating only if LifeCycle Manager is changed on KKNR
                    child.LifeCycle_Manager__c = updateMapAcc.get(child.ParentId).LifeCycle_Manager__c;
                if (oldMap.get(child.ParentId).Change_Manager__c != updateMapAcc.get(child.ParentId).Change_Manager__c) //Updating only if Change Manager is changed on KKNR
                    child.Change_Manager__c = updateMapAcc.get(child.ParentId).Change_Manager__c;

                childToUpdate.add(child);
            }
            if (childToUpdate.size() > 0) {
                database.update(childToUpdate);
            }

        }

    }


    // Author A.N
    // This method will filter out any Large accounts with new account owner
    // It will then create new Opportunity Split records for all Large Opportunities related to these accounts.
    private void updateOpportunitySplits(List < Account > newList, Map < Id, Account > oldMap) {
        Set < Id > accIds = new Set < Id > ();
        for (Account acc : newList) {
            //If it is Large Account and Owner is changed
            if (SEUtility.isLargeAccountRecordType(acc.RecordTypeId) && oldMap.get(acc.Id).OwnerId != acc.OwnerId) {
                accIds.add(acc.Id);
            }
        }

        if (accIds.size() > 0) {
            Set < Id > oppIds = new Map < Id, Opportunity > ([SELECT Id FROM Opportunity WHERE Account.Id IN:accIds AND RecordType.Id IN:SEUtility.getLargeOppRectypeIds()]).keySet();
            if (!oppIds.isEmpty()) {
                SEUtility.createOppSplits(oppIds);
            }
        }
    }

    // Author: Nikhita Gautam
    // This method will update Cygate_Has_Sub_Account__c to True if it has any child Account with recordType Cygate Sub-Account 
    private void checkParentSubAcc(List < Account > newList) {/*
        List < Account > parentToUpdate = new List < Account > ();
        Set < Account > pToUpdate = new Set < Account > ();
        //List<Account> pToUpdate = new List<Account>();

        for (Account acc: newList) {
            if (acc.ParentId != null && acc.RecordtypeID == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_CYGATE_SUB)) {
                //Create an instance for parent account, and update parent Account field 
                Account parentAcc = new Account(Id = acc.ParentId);
                parentAcc.Cygate_Has_Sub_Account__c = true;
                pToUpdate.add(parentAcc);
            }
        }
        parentToUpdate.addall(pToUpdate);
        if (!parentToUpdate.isEmpty()) {
            List < Database.SaveResult > srList = Database.update(parentToUpdate, false);

            // Error handling for parent records if update fails (f.ex. for foreign accounts, this update will fail as we don't allow these accounts to have sub accounts)
            for (Integer i = 0; i < srList.size(); i++) {
                Database.SaveResult sr = srList.get(i);
                if (!sr.isSuccess()) {
                    Id insertFailedParentId = parentToUpdate.get(i).Id;
                    for (Account acc: newList) {
                        if (acc.ParentId == insertFailedParentId) {
                            for (Database.Error err: sr.getErrors()) {
                                acc.addError(Label.Sub_Account_on_Foreign_Account + ': ' + err.getMessage());
                            }
                        }
                    }
                }
            }
        }*/
    }

    // Author: Nikhita Gautam, refactored A.N Sep 2016
    // This method will update Cygate_Has_Sub_Account__c to false if it no longer has any child Account with recordType Cygate Sub-Account 
    private void unCheckParentSubAcc(List < Account > oldList) {/*
        List < Account > parentToUpdate = new List < Account > ();
        Set < Id > parentIds = new Set < Id > ();
        String CYGATE_RECORDTYPEID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_CYGATE_SUB);

        for (Account acc: oldList) {
            if (acc.ParentId != null && acc.RecordtypeID == CYGATE_RECORDTYPEID) {
                parentIds.add(acc.ParentId);
            }
        }

        if (!parentIds.isEmpty()) {
            for (Account parent: [SELECT Id, Cygate_Has_Sub_Account__c,
                    (SELECT Id FROM ChildAccounts WHERE RecordtypeID =: CYGATE_RECORDTYPEID LIMIT 1)
                    FROM Account WHERE Id IN: parentIds
                ]) {

                if (parent.Cygate_Has_Sub_Account__c == true && parent.ChildAccounts.isEmpty()) {
                    parent.Cygate_Has_Sub_Account__c = false;
                    parentToUpdate.add(parent);
                }
            }

            if (!parentToUpdate.isEmpty()) {
                update parentToUpdate;
            }
        }*/
    }

    /* Author A.N.
     * This method will run after insert/update and before delete. The code will do as follows:
     * FILTER:
     *  If insert (oldMap==null), and if account record type is not KundKonto
     *   - if Cygate_Account_Manager__c != null, add to map kknrWithNewCygateAccManager
     *  If update and if account record type is not KundKonto
     *   - if Cygate_Account_Manager__c is changed, add new manager to kknrWithNewCygateAccManager and old manager to kknrWithDeletedCygateAccManager
     *  If delete (newList==null), and if account record type is not KundKonto
     *   - if Cygate_Account_Manager__c != null, add to map kknrWithDeletedCygateAccManager
     * LOAD:
     *  First, all kknr ids in the lists kknrWithNewCygateAccManager and kknrWithDeletedCygateAccManager are put into a set
     *   We then query all org-accounts belonging to the kknr and put in a map with kknr-id as key (kknrIdOrgAccountMap)
     *    In the same map we also query the Existing Account Team Members of type CygateAccManager for that kknr
     *   (If Delete) We also query all sub-accs belonging to the org-accs and put in a map with orgAcc-id as key (orgIdSubAccountsMap)
     * DO:
     *  For each kknr, for each new/deleted manager related to the kknr:
     *   Delete: Check if any org account or sub account has the deleted manager as CygateAccManager
     *    - if yes, do not delete the user AccountTeamMember from the kknr
     *    - if no, find the AccountTeamMember for that user related to the kknr and add to delete list
     *   Insert: Check if the user is already added as Account Team Members of type CygateAccManager for that kknr
     *    - if yes, do nothing
     *    - if no, add the user as AccountTeamMember of type CygateAccManager to the kknr
     */
    /* Case No 1867 : Commented by S.S - as we don't have Cygate Account Manager as the picklist value in Account Team Member, we have Cygate - Kontoansvarig
so applied this check.
public static final String ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER = 'Cygate Account Manager'; */
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER = 'Cygate - Kontoansvarig';
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_SERVICE_MANAGER = 'Cygate - Service Manager';
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_TELIA_SERVICE_MANAGER = 'Service Manager';
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_TELIA_LifeCycle_MANAGER = 'LifeCycle Manager';
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_TELIA_CHANGE_MANAGER = 'Customer Change Manager';

    private static void updateCygateAccountManagerOnKKnr(List < Account > newList, Map < Id, Account > oldMap) {
        Map < Id, Set < Id >> kknrWithDeletedCygateAccManager = new Map < Id, Set < Id >> ();
        Map < Id, Set < Id >> kknrWithNewCygateAccManager = new Map < Id, Set < Id >> ();

        if (newList != null) { // Is insert/update
            // This will filter all accounts that are not Kundkonto where Cygate Account Manager is changed
            for (Account newAcc : newList) {
                if (!SEUtility.isKundKontoAccountRecordType(newAcc.RecordTypeId)) { // Do not run logic if account type is kundkonto
                    if (oldMap == null && newAcc.Cygate_Account_Manager__c != null) { // On insert, check if Cygate_Account_Manager__c is set
                        kknrWithNewCygateAccManager = addToMap(kknrWithNewCygateAccManager, newAcc.Parent_KKnr_Id__c, newAcc.Cygate_Account_Manager__c);
                    } else if (oldMap != null && newAcc.Cygate_Account_Manager__c != oldMap.get(newAcc.Id).Cygate_Account_Manager__c) { // On update, check if Cygate_Account_Manager__c is changed
                        kknrWithNewCygateAccManager = addToMap(kknrWithNewCygateAccManager, newAcc.Parent_KKnr_Id__c, newAcc.Cygate_Account_Manager__c);
                        kknrWithDeletedCygateAccManager = addToMap(kknrWithDeletedCygateAccManager, newAcc.Parent_KKnr_Id__c, oldMap.get(newAcc.Id).Cygate_Account_Manager__c);
                    }
                }
            }
        } else { // Is delete
            for (Account deletedAcc : oldMap.values()) {
                if (deletedAcc.Cygate_Account_Manager__c != null && !SEUtility.isKundKontoAccountRecordType(deletedAcc.RecordTypeId)) { // On delete, if Cygate_Account_Manager__c != null, add to delete list
                    kknrWithDeletedCygateAccManager = addToMap(kknrWithDeletedCygateAccManager, deletedAcc.Parent_KKnr_Id__c, deletedAcc.Cygate_Account_Manager__c);
                }
            }
        }
        updateCygateAccountManagerOnKKnr(kknrWithDeletedCygateAccManager, kknrWithNewCygateAccManager);
    }

    private static void updateCygateAccountManagerOnKKnr(Map < Id, Set < Id >> kknrWithDeletedCygateAccManager, Map < Id, Set < Id >> kknrWithNewCygateAccManager) {
        Set < Id > kknrIds = new Set < Id > ();
        for (Id delId : kknrWithDeletedCygateAccManager.keySet()) kknrIds.add(delId);
        for (Id newId : kknrWithNewCygateAccManager.keySet()) kknrIds.add(newId);

        if (kknrIds.size() > 0) {
            // Collect the complete set of kknr-ids to be updated                   
            Map < Id, Account > kknrIdOrgAccountMap = new Map < Id, Account > ( // Query kknr's with org accounts
            [
                    SELECT Id, (SELECT Id, Cygate_Account_Manager__c FROM ChildAccounts WHERE Cygate_Account_Manager__c != null), (SELECT UserId FROM AccountTeamMembers WHERE TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER)
                    FROM Account
                    WHERE Id in:kknrIds
            ]);

            if (!kknrWithDeletedCygateAccManager.isEmpty()) {
                List < AccountTeamMember > deleteAccountTeamMembers = new List < AccountTeamMember > ();
                Map < Id, Account > orgIdSubAccountsMap = new Map < Id, Account > ( // query any sub accounts to the org accounts
                [
                        SELECT Id, (SELECT Cygate_Account_Manager__c FROM ChildAccounts WHERE Cygate_Account_Manager__c != null)
                        FROM Account
                        WHERE Cygate_Account_Manager__c != null AND ParentId != NULL AND ParentId in:kknrIds
                ]);
                for (Id kknrDelId : kknrWithDeletedCygateAccManager.keySet()) { // Iterate each kknr
                    for (Id cygManagerToDeleteId : kknrWithDeletedCygateAccManager.get(kknrDelId)) { // iterate each manager that has been removed
                        Boolean isCygateManagerOnRelatedAccount = false;
                        for (Account orgAcc : kknrIdOrgAccountMap.get(kknrDelId).ChildAccounts) { // Iterate each of the kknrs org-accounts
                            if (orgAcc.Cygate_Account_Manager__c == cygManagerToDeleteId && !isCygateManagerOnRelatedAccount) {
                                isCygateManagerOnRelatedAccount = true; // The user is CygateAccManager on an org-account and should not be deleted from the kknr AccountTeamMember-list
                                break; // break out of for loop as we don't need to search the rest of the org-accounts
                            } else {
                                for (Account subAcc : orgIdSubAccountsMap.get(orgAcc.Id).ChildAccounts) {
                                    if (subAcc.Cygate_Account_Manager__c == cygManagerToDeleteId) {
                                        isCygateManagerOnRelatedAccount = true; // The user is CygateAccManager on a sub-account and should not be deleted from the kknr AccountTeamMember-list
                                        break; // break out of for loop as we don't need to search the rest of the sub-accounts
                                    }
                                }
                            }
                            if (isCygateManagerOnRelatedAccount) break; // Do not need to iterate rest of Org-accs if manager is found on related account
                        }
                        // if isCygateManagerOnRelatedAccount = false, we must fint the AccountTeamMember related to the kknr and add to the delete list
                        if (!isCygateManagerOnRelatedAccount) {
                            for (AccountTeamMember atm : kknrIdOrgAccountMap.get(kknrDelId).AccountTeamMembers) {
                                if (atm.UserId == cygManagerToDeleteId) deleteAccountTeamMembers.add(atm);
                            }
                        }
                    }
                }
                if (!deleteAccountTeamMembers.isEmpty()) {
                    Database.delete(deleteAccountTeamMembers, false);
                }
            }

            if (!kknrWithNewCygateAccManager.isEmpty()) {
                List < AccountTeamMember > newAccountTeamMembers = new List < AccountTeamMember > ();
                for (Id kknrNewId : kknrWithNewCygateAccManager.keySet()) { // Iterate each kknr
                    for (Id cygManagerToInsertId : kknrWithNewCygateAccManager.get(kknrNewId)) {
                        Boolean isCygateManagerAtmOnKknr = false;
                        for (AccountTeamMember atm : kknrIdOrgAccountMap.get(kknrNewId).AccountTeamMembers) {
                            if (atm.UserId == cygManagerToInsertId) isCygateManagerAtmOnKknr = true;
                        }
                        // If the user is not already cygate manager AccountTeamMember on the kknr, create new AccountTeamMember
                        if (!isCygateManagerAtmOnKknr) {
                            AccountTeamMember newAtm = new AccountTeamMember();
                            newAtm.AccountId = kknrNewId;
                            newAtm.TeamMemberRole = ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER;
                            newAtm.UserId = cygManagerToInsertId;
                            newAccountTeamMembers.add(newAtm);
                        }
                    }
                }
                if (!newAccountTeamMembers.isEmpty()) {
                    Database.insert(newAccountTeamMembers, false);
                }
            }
        }
    }

    // Author A.N. If key exists in map, add value to set. If key does not exist, put key/new set into the map.
    // If input key or value is null, do nothing and return the map input directly.
    private static Map < Id, Set < Id >> addToMap(Map < Id, Set < Id >> idSetIdMap, Id keyId, Id valueId) {
        if (keyId == null || valueId == null) return idSetIdMap; // key should never be null. If value = null no action is needed.
        if (idSetIdMap.containsKey(keyId)) {
            Set < Id > idSet = idSetIdMap.get(keyId);
            idSet.add(valueId);
            idSetIdMap.put(keyId, idSet);
        } else {
            idSetIdMap.put(keyId, new Set < Id >{
                    valueId
            });
        }
        return idSetIdMap;
    }


    //Author V.M If we manually change the marketing fields, we set the Process Opt Out to true so that the batch process only the ones that has been changed.
    //Also we timestamp when the Marketing Opt Out fields get their value changed
    private static void processOptOut(List < Account > newList, Map < Id, Account > oldMap) {
        for (Account acc : newList) {
            if (acc.Marketing_Mails_Opt_Out__c != oldMap.get(acc.Id).Marketing_Mails_Opt_Out__c || acc.From_Date__c != oldMap.get(acc.Id).From_Date__c || acc.To_Date__c != oldMap.get(acc.Id).To_Date__c || acc.Marketing_Mails_Opt_Out_Cygate__c != oldMap.get(acc.Id).Marketing_Mails_Opt_Out_Cygate__c || acc.From_Date_Cygate__c != oldMap.get(acc.Id).From_Date_Cygate__c || acc.To_Date_Cygate__c != oldMap.get(acc.Id).To_Date_Cygate__c) {
                //Check if we are not in batch context
                if (!System.isBatch()) {


                    if ((acc.Marketing_Mails_Opt_Out__c == 'According to agreement' || acc.Marketing_Mails_Opt_Out__c == 'Upon Client request')) {
                        acc.Newsletter_Telia__c = false;


                        acc.Survey_Telia__c = false;


                        acc.Event_Telia__c = false;
                        acc.Campaigns_Telia__c = false;

                        acc.SMS_Telia__c = false;
                        acc.Process_Opt_Out__c = true;


                    }


                    //acc.Process_Opt_Out_Telia__c = true;
                    if ((acc.Marketing_Mails_Opt_Out_Cygate__c == 'According to agreement' || acc.Marketing_Mails_Opt_Out_Cygate__c == 'Upon Client request')) {
                        acc.Newsletter_Cygate__c = false;

                        acc.Survey_Cygate__c = false;
                        acc.Event_Cygate__c = false;


                        acc.Campaigns_Cygate__c = false;
                        acc.SMS_Cygate__c = false;
                        acc.Process_Opt_Out_Cygate__c = true;
                    }


                    if ((acc.Marketing_Mails_Opt_Out__c != oldMap.get(acc.Id).Marketing_Mails_Opt_Out__c && acc.Marketing_Mails_Opt_Out__c == null)) {
                        acc.Newsletter_Telia__c = true;
                        acc.Survey_Telia__c = true;
                        acc.Event_Telia__c = true;
                        acc.Campaigns_Telia__c = true;
                        acc.SMS_Telia__c = true;
                        acc.Process_Opt_Out__c = true;
                    }

                    if ((acc.Marketing_Mails_Opt_Out_Cygate__c != oldMap.get(acc.Id).Marketing_Mails_Opt_Out_Cygate__c && acc.Marketing_Mails_Opt_Out_Cygate__c == null)) {
                        acc.Newsletter_Cygate__c = true;
                        acc.Survey_Cygate__c = true;
                        acc.Event_Cygate__c = true;
                        acc.Campaigns_Cygate__c = true;
                        acc.SMS_Cygate__c = true;
                        acc.Process_Opt_Out_Cygate__c = true;
                    }


                    acc.Opt_Out_Timestamp__c = DateTime.now();
                    //commented as they are not required as per new req
                    /* acc.Man_From_Date__c = acc.From_Date__c;
acc.Man_To_Date__c = acc.To_Date__c;
acc.Man_Mails_Opt_Out__c = acc.Marketing_Mails_Opt_Out__c;

//Set manually set to true if any value have been changed outside batchcontext
if(acc.Marketing_Mails_Opt_Out__c != null || acc.From_Date__c != null || acc.To_Date__c != null){
acc.Opt_Out_Manually_Set__c = true;
}
else if(oldMap.get(acc.Id).Marketing_Mails_Opt_Out__c != null && acc.Marketing_Mails_Opt_Out__c == null)
{
acc.Opt_Out_Manually_Set__c = true;
}
else
{
acc.Opt_Out_Manually_Set__c = false;
}*/
                }
                // acc.Opt_Out_Timestamp__c = DateTime.now();
            }
        }
    }
    //}
    //}        
    // }

    // Author C.M : This method is to change the owner of avtalsituations if the owner of account is changed.
    /* Commented by C.M - Functionality is covered in batch class.
private static void updateAvtalSituationOwner(List<Account> newList, Map<ID, Account> oldMap){  
Set<Id> acctIds = new Set<Id>();
List<Agreement_Situation__c> listToUpdate=new List<Agreement_Situation__c>(); 
List<Account> kundkontoList=new List<Account>(); 
List<Agreement_Situation__c> newlistoupdate=new List<Agreement_Situation__c>();
Set<Agreement_Situation__c> setToUpdate=new Set<Agreement_Situation__c>();
try{
for (Account acct : newList) {
//executes only if the owner of kundkonto account is changed.
if(acct.OwnerId!=oldMap.get(acct.Id).OwnerId && (acct.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK)) || (acct.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1))) || (acct.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2 ))))){
acctIds.add(acct.Id);
kundkontoList.add(acct);
}
}   

List<Agreement_Situation__c> asList = [SELECT OwnerId  FROM Agreement_Situation__c WHERE KKnr__c in :acctIds];
if ( !asList.isEmpty() ) {
for (Account acct : kundkontoList) {
for(Agreement_Situation__c avtal : asList ) {       
if(avtal.OwnerId != acct.OwnerId){
avtal.OwnerId = acct.OwnerID;
setToUpdate.add(avtal);
}
}
}               
}
newlistoupdate.addAll(listToUpdate);
if(!setToUpdate.isEmpty())
{
listToUpdate.clear();
listToUpdate.addall(setToUpdate);
}
if(!listToUpdate.isEmpty())
{
update listToUpdate;
}
}catch(exception e){
System.debug('Exception' +e);
}
}*/
    //Changes done by S.S - case 3445 - whenever the cygate account managers are added on account then they get added in the account team member with READ access on Opportunity
    //P.S Updated to add the fucntionality for Telia LifeCycle and Change Manager.
    private static void addCygateAccountManagerinATMonOrg(List < Account > newList, Map < Id, Account > oldMap) {
        Set < Id > accId = new Set < Id > ();
        Set < Id > cygateAccountManagerId = new Set < Id > ();
        Set < Id > deletecygateAccountManagerId = new Set < Id > ();
        Set < Id > oldCygateAccountMangerId = new Set < Id > ();
        List < AccountTeamMember > addCygateAccountMangerOnOrg = new List < AccountTeamMember > ();
        List < AccountTeamMember > listofATM = new List < AccountTeamMember > ();
        List < AccountTeamMember > deleteATM = new List < AccountTeamMember > ();
        //Telia Service Manager variables
        Set < Id > TeliaServiceManagerId = new Set < Id > ();
        Set < Id > deleteTeliaServiceManagerId = new Set < Id > ();
        Set < Id > oldTeliaServiceMangerId = new Set < Id > ();
        List < AccountTeamMember > addTeliaServiceMangerOnOrg = new List < AccountTeamMember > ();
        //Telia LifeCycle Manager Variables
        Set < Id > TeliaLifeCycleManagerId = new Set < Id > ();
        Set < Id > deleteTeliaLifeCycleManagerId = new Set < Id > ();
        Set < Id > oldTeliaLifeCycleMangerId = new Set < Id > ();
        List < AccountTeamMember > addTeliaLifeCycleMangerOnOrg = new List < AccountTeamMember > ();
        //Telia Change Manager Variables
        Set < Id > TeliaChangeManagerId = new Set < Id > ();
        Set < Id > deleteTeliaChangeManagerId = new Set < Id > ();
        Set < Id > oldTeliaChangeMangerId = new Set < Id > ();
        List < AccountTeamMember > addTeliaChangeMangerOnOrg = new List < AccountTeamMember > ();
        //SM variables
        List < AccountTeamMember > addCygateServiceManageronOrg = new List < AccountTeamMember > ();
        Set < Id > newConIdSet = new Set < Id > ();
        Set < Id > oldConIdSet = new Set < Id > ();
        Set < Id > conIdSet = new Set < Id > ();
        Set < Id > oldCygateServiceManagerId = new Set < Id > ();
        Set < Id > oldCygateServiceManagerUserId = new Set < Id > ();
        Set < Id > cygateServiceManagerId = new Set < Id > ();
        Set < Id > cygateServiceManageruserId = new Set < Id > ();
        Set < Id > deleteCygateServiceManagerId = new Set < Id > ();
        Set < Id > deleteCygateServiceManagerUserId = new Set < Id > ();
        string cygateInternalRecId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CYGATE_USER);
        Set < Id > accSMId = new Set < Id > ();
        Map < Id, AccountTeamMember > conATMMap = new Map < Id, AccountTeamMember > ();
        Set < AccountTeamMember > atmInsertListSM = new Set < AccountTeamMember > ();
        List < AccountTeamMember > atmFinalInsert = new List < AccountTeamMember > ();


        for (Account newAcc : newList) {
            if (SEUtility.isLargeAccountRecordType(newAcc.RecordTypeId) || SEUtility.isSmeAccountRecordType(newAcc.RecordTypeId)) // run logic if account type is large
            {
                if (oldMap == null && newAcc.Cygate_Account_Manager__c != null) {
                    cygateAccountManagerId.add(newAcc.Cygate_Account_Manager__c);
                    addCygateAccountMangerOnOrg = createCygateAccountManagerasAccountTeamMember(addCygateAccountMangerOnOrg, newAcc);
                } else if (oldMap != null && oldMap.get(newAcc.Id).Cygate_Account_Manager__c == null && newAcc.Cygate_Account_Manager__c != oldMap.get(newAcc.Id).Cygate_Account_Manager__c && newAcc.Cygate_Account_Manager__c != null) // On update, check if Cygate_Account_Manager__c is changed
                {
                    addCygateAccountMangerOnOrg = createCygateAccountManagerasAccountTeamMember(addCygateAccountMangerOnOrg, newAcc);
                    cygateAccountManagerId.add(newAcc.Cygate_Account_Manager__c);
                } else if (oldMap != null && oldMap.get(newAcc.Id).Cygate_Account_Manager__c != null && newAcc.Cygate_Account_Manager__c != oldMap.get(newAcc.Id).Cygate_Account_Manager__c && newAcc.Cygate_Account_Manager__c != null) // On update, check if Cygate_Account_Manager__c is changed
                {
                    accId.add(newAcc.Id);
                    oldCygateAccountMangerId.add(oldMap.get(newAcc.Id).Cygate_Account_Manager__c);
                    cygateAccountManagerId.add(newAcc.Cygate_Account_Manager__c);
                    addCygateAccountMangerOnOrg = createCygateAccountManagerasAccountTeamMember(addCygateAccountMangerOnOrg, newAcc);
                } else if (oldMap != null && oldMap.get(newAcc.Id).Cygate_Account_Manager__c != null && newAcc.Cygate_Account_Manager__c == null) {
                    accId.add(newAcc.Id);
                    deletecygateAccountManagerId.add(oldMap.get(newAcc.Id).Cygate_Account_Manager__c);
                }
            }
            //Telia Service Manager Functionality //S.S - Added kknr check
            if (SEUtility.isLargeAccountRecordType(newAcc.RecordTypeId) || newAcc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK))) // run logic if account type is large & KKNR
            {
                if (oldMap == null && newAcc.Telia_Service_Manager__c != null) {
                    TeliaServiceManagerId.add(newAcc.Telia_Service_Manager__c);
                    addTeliaServiceMangerOnOrg = createTeliaServiceManagerasAccountTeamMember(addTeliaServiceMangerOnOrg, newAcc);
                } else if (oldMap != null && oldMap.get(newAcc.Id).Telia_Service_Manager__c == null && newAcc.Telia_Service_Manager__c != oldMap.get(newAcc.Id).Telia_Service_Manager__c && newAcc.Telia_Service_Manager__c != null) {
                    addTeliaServiceMangerOnOrg = createTeliaServiceManagerasAccountTeamMember(addTeliaServiceMangerOnOrg, newAcc);
                    TeliaServiceManagerId.add(newAcc.Telia_Service_Manager__c);
                } else if (oldMap != null && oldMap.get(newAcc.Id).Telia_Service_Manager__c != null && newAcc.Telia_Service_Manager__c != oldMap.get(newAcc.Id).Telia_Service_Manager__c && newAcc.Telia_Service_Manager__c != null) {
                    accId.add(newAcc.Id);
                    oldTeliaServiceMangerId.add(oldMap.get(newAcc.Id).Telia_Service_Manager__c);
                    TeliaServiceManagerId.add(newAcc.Telia_Service_Manager__c);
                    addTeliaServiceMangerOnOrg = createTeliaServiceManagerasAccountTeamMember(addTeliaServiceMangerOnOrg, newAcc);
                } else if (oldMap != null && oldMap.get(newAcc.Id).Telia_Service_Manager__c != null && newAcc.Telia_Service_Manager__c == null) {
                    accId.add(newAcc.Id);
                    deleteTeliaServiceManagerId.add(oldMap.get(newAcc.Id).Telia_Service_Manager__c);
                }
            }

            //Telia LifeCycle Manager Functionality 
            if (SEUtility.isLargeAccountRecordType(newAcc.RecordTypeId) || newAcc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK))) // run logic if account type is large & KKNR
            {
                if (oldMap == null && newAcc.LifeCycle_Manager__c != null) {
                    TeliaLifeCycleManagerId.add(newAcc.LifeCycle_Manager__c);
                    addTeliaLifeCycleMangerOnOrg = createTeliaLifeCycleManagerasAccountTeamMember(addTeliaLifeCycleMangerOnOrg, newAcc);
                } else if (oldMap != null && oldMap.get(newAcc.Id).LifeCycle_Manager__c == null && newAcc.LifeCycle_Manager__c != oldMap.get(newAcc.Id).LifeCycle_Manager__c && newAcc.LifeCycle_Manager__c != null) {
                    addTeliaLifeCycleMangerOnOrg = createTeliaLifeCycleManagerasAccountTeamMember(addTeliaLifeCycleMangerOnOrg, newAcc);
                    TeliaLifeCycleManagerId.add(newAcc.LifeCycle_Manager__c);
                } else if (oldMap != null && oldMap.get(newAcc.Id).LifeCycle_Manager__c != null && newAcc.LifeCycle_Manager__c != oldMap.get(newAcc.Id).LifeCycle_Manager__c && newAcc.LifeCycle_Manager__c != null) {
                    accId.add(newAcc.Id);
                    oldTeliaLifeCycleMangerId.add(oldMap.get(newAcc.Id).LifeCycle_Manager__c);
                    TeliaLifeCycleManagerId.add(newAcc.LifeCycle_Manager__c);
                    addTeliaLifeCycleMangerOnOrg = createTeliaLifeCycleManagerasAccountTeamMember(addTeliaLifeCycleMangerOnOrg, newAcc);
                } else if (oldMap != null && oldMap.get(newAcc.Id).LifeCycle_Manager__c != null && newAcc.LifeCycle_Manager__c == null) {
                    accId.add(newAcc.Id);
                    deleteTeliaLifeCycleManagerId.add(oldMap.get(newAcc.Id).LifeCycle_Manager__c);
                }
            }
            //Telia Change Manager Functionality 
            if (SEUtility.isLargeAccountRecordType(newAcc.RecordTypeId) || newAcc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK))) // run logic if account type is large & KKNR
            {
                if (oldMap == null && newAcc.Change_Manager__c != null) {
                    TeliaChangeManagerId.add(newAcc.Change_Manager__c);
                    addTeliaChangeMangerOnOrg = createTeliaChangeManagerasAccountTeamMember(addTeliaChangeMangerOnOrg, newAcc);
                } else if (oldMap != null && oldMap.get(newAcc.Id).Change_Manager__c == null && newAcc.Change_Manager__c != oldMap.get(newAcc.Id).Change_Manager__c && newAcc.Change_Manager__c != null) {
                    addTeliaChangeMangerOnOrg = createTeliaChangeManagerasAccountTeamMember(addTeliaChangeMangerOnOrg, newAcc);
                    TeliaChangeManagerId.add(newAcc.Change_Manager__c);
                } else if (oldMap != null && oldMap.get(newAcc.Id).Change_Manager__c != null && newAcc.Change_Manager__c != oldMap.get(newAcc.Id).Change_Manager__c && newAcc.Change_Manager__c != null) {
                    accId.add(newAcc.Id);
                    oldTeliaChangeMangerId.add(oldMap.get(newAcc.Id).Change_Manager__c);
                    TeliaChangeManagerId.add(newAcc.Change_Manager__c);
                    addTeliaChangeMangerOnOrg = createTeliaChangeManagerasAccountTeamMember(addTeliaChangeMangerOnOrg, newAcc);
                } else if (oldMap != null && oldMap.get(newAcc.Id).Change_Manager__c != null && newAcc.Change_Manager__c == null) {
                    accId.add(newAcc.Id);
                    deleteTeliaChangeManagerId.add(oldMap.get(newAcc.Id).Change_Manager__c);
                }
            }
            //service manager function
            //add filter of acc rec type
            if (oldMap == Null && newAcc.Cygate_Service_Manager__c != null) {
                newConIdSet.add(newAcc.Cygate_Service_Manager__c);
                conIdSet.add(newAcc.Cygate_Service_Manager__c);
                //addCygateServiceManageronOrg = createCygateServiceManagerasAccountTeamMember(addCygateServiceManagerOnOrg,newAcc,conIdSet);
                cygateServiceManagerId.add(newAcc.Cygate_Service_Manager__c);
                addCygateServiceManageronOrg = createCygateServiceManagerasAccountTeamMember(addCygateServiceManagerOnOrg, newAcc, conATMMap);

            } else if (oldMap != Null && oldMap.get(newAcc.id).Cygate_Service_Manager__c == null && newAcc.Cygate_Service_Manager__c != oldMap.get(newAcc.Id).Cygate_Service_Manager__c && newAcc.Cygate_Service_Manager__c != null) {
                newConIdSet.add(newAcc.Cygate_Service_Manager__c);
                conIdSet.add(newAcc.Cygate_Service_Manager__c);
                //cygateServiceManagerId.add(newAcc.Cygate_Service_Manager__c);
                addCygateServiceManagerOnOrg = createCygateServiceManagerasAccountTeamMember(addCygateServiceManagerOnOrg, newAcc, conATMMap);

            } else if (oldMap != Null && oldMap.get(newAcc.Id).Cygate_Service_Manager__c != Null && newAcc.Cygate_Service_Manager__c != oldMap.get(newAcc.id).Cygate_Service_Manager__c && newAcc.Cygate_Service_Manager__c != null) {
                accId.add(newAcc.Id);
                newConIdSet.add(newAcc.Cygate_Service_Manager__c);
                oldConIdSet.add(oldMap.get(newAcc.Id).Cygate_Service_Manager__c);
                conidSet.add(newAcc.Cygate_Service_Manager__c);
                conIdSet.add(oldMap.get(newAcc.Id).Cygate_Service_Manager__c);
                oldCygateServiceManagerId.add(oldMap.get(newAcc.Id).Cygate_Service_Manager__c);
                cygateServiceManagerId.add(newAcc.Cygate_Service_Manager__c);
                addCygateServiceManagerOnOrg = createCygateServiceManagerasAccountTeamMember(addCygateServiceManagerOnOrg, newAcc, conATMMap);
            } else if (oldMap != Null && oldMap.get(newAcc.Id).Cygate_Service_Manager__c != null && newAcc.Cygate_Service_Manager__c == null) {
                accId.add(newAcc.id);
                newConIdSet.add(newAcc.Cygate_Service_Manager__c);
                oldConIdSet.add(oldMap.get(newAcc.Id).Cygate_Service_Manager__c);
                conidSet.add(newAcc.Cygate_Service_Manager__c);
                conIdSet.add(oldMap.get(newAcc.Id).Cygate_Service_Manager__c);
                deleteCygateServiceManagerId.add(oldMap.get(newAcc.Id).Cygate_Service_Manager__c);
            }
        }
        if (oldConIdSet.size() > 0 || newConIdSet.size() > 0) {
            List < Contact > conList = [SELECT Id, Cygate_User__c FROM Contact WHERE recordTypeId = :cygateInternalRecId and Cygate_User__c != Null AND ID IN:conIdSet];
            if (conList.size() > 0) {
                for (contact con : ConList) {
                    accSMId.add(con.Cygate_User__c); //need to know why accsmid is needed
                    if (newConIdSet.contains(con.Id)) {
                        AccountTeamMember atm = conATMMap.get(con.Id);
                        atm.UserId = con.Cygate_User__c;
                        atmInsertListSM.add(atm);
                        cygateServiceManageruserId.add(con.cygate_User__c);
                    }
                    if (oldConidSet.contains(con.id)) {
                        //AccountTeamMember atm = conATMMap.get(con.Id);
                        //atm.UserId = con.Cygate_User__c;
                        //atmInsertListSM.add(atm);
                        if (deleteCygateServiceManagerId.contains(con.Id)) {
                            deleteCygateServiceManagerUserId.add(con.Cygate_User__c);
                        }
                        if (oldCygateServiceManagerId.contains(con.id)) {
                            oldCygateServiceManagerUserId.add(con.Cygate_User__c);
                        }
                    }
                }
            }
        }

        if (!cygateAccountManagerId.isEmpty() || !oldcygateServiceManagerUserId.isEmpty() || !TeliaServiceManagerId.isEmpty() || !TeliaLifeCycleManagerId.isEmpty() || !TeliaChangeManagerId.isEmpty()) {
            listofATM = [Select id, UserId from AccountTeamMember where((AccountId = :accId and userId = :oldCygateAccountMangerId and TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER) OR (userId = :oldCygateServiceManagerUserId and TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_SERVICE_MANAGER) OR (userId = :oldTeliaServiceMangerId and TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_TELIA_SERVICE_MANAGER) OR (userId = :oldTeliaLifeCycleMangerId and TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_TELIA_LifeCycle_MANAGER) OR (userId = :oldTeliaChangeMangerId and TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_TELIA_CHANGE_MANAGER))];
        } else if (!deletecygateAccountManagerId.isEmpty() || !deleteCygateServiceManagerUserId.isEmpty() || !deleteTeliaServiceManagerId.isEmpty() || !deleteTeliaLifeCycleManagerId.isEmpty() || !deleteTeliaChangeManagerId.isEmpty()) {
            listofATM = [Select id, UserId from AccountTeamMember where((AccountId = :accId and userId = :deletecygateAccountManagerId and TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER) OR (userId = :deleteCygateServiceManagerUserId AND TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_SERVICE_MANAGER) OR (userId = :deleteTeliaServiceManagerId and TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_TELIA_SERVICE_MANAGER) OR (userId = :deleteTeliaLifeCycleManagerId and TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_TELIA_LifeCycle_MANAGER) OR (userId = :deleteTeliaChangeManagerId and TeamMemberRole = :ACCOUNT_TEAM_MEMBER_ROLE_TELIA_CHANGE_MANAGER))];
        }
        if (!listofATM.IsEmpty() && listofATM.size() > 0) {
            deleteATM.addall(listofATM);
            database.delete(deleteATM, false);
        }
        if ((!addCygateAccountMangerOnOrg.IsEmpty() && addCygateAccountMangerOnOrg.size() > 0) || (!atmInsertListSM.IsEmpty() && atmInsertListSM.size() > 0) || addTeliaServiceMangerOnOrg.size() > 0 || addTeliaLifeCycleMangerOnOrg.size() > 0 || addTeliaChangeMangerOnOrg.size() > 0) {
            atmFinalInsert.addAll(addCygateAccountMangerOnOrg);
            atmFinalInsert.addAll(atmInsertListSM);
            atmFinalInsert.addAll(addTeliaServiceMangerOnOrg);
            atmFinalInsert.addAll(addTeliaLifeCycleMangerOnOrg);
            atmFinalInsert.addAll(addTeliaChangeMangerOnOrg);
            try {
                //insert addCygateAccountMangerOnOrg;
                insert atmFinalInsert;
            } catch (Exception e) {
                System.debug('Exception' + e);
            }

        }
    }
    //AUthor S.M has updated the Total_open_opportunities_on_underlied_or__c field - Aug 2017

    private static void setCountOfOpenOppOnKknr(List<Account> newList, Map<Id,Account> oldMap){
        List<Id> parentIds = new List<Id>();
        for (Account acc : newList) {
            //SALEF-8200 Added acc.ParentId != null for SOQL query optimization
            if (acc.ParentId != null && acc.Business_Unit__c != 'SME Mass Market' && acc.OwnerId != System.Label.IntegrationUser) {
                parentIds.add(acc.ParentId);
            }
        }

        List<Account> accountsToUpdate = new List <Account>();
        Decimal sum = 0;
        String KKNR_RECORDTYPEID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        String Large_RECORDTYPEID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        String Large_Sak1_RECORDTYPEID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC1);
        String Large_sak2_RECORDTYPEID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC2);
        String SME_RECORDTYPEID = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
        if (!parentIds.isEmpty()){
            for(Account acc : [SELECT Total_Open_Opportunities_On_Underlin_Org__c, (SELECT Id, Total_open_Opportunities_on_org__c FROM ChildAccounts WHERE Total_open_Opportunities_on_org__c != 0 AND (RecordTypeId = :Large_RECORDTYPEID OR RecordTypeId = :Large_Sak1_RECORDTYPEID OR RecordTypeId = :Large_sak2_RECORDTYPEID OR (RecordTypeId = :SME_RECORDTYPEID AND Business_Unit__c != 'SME Mass Market'))) FROM Account WHERE Id = :parentIds AND RecordTypeId = :KKNR_RECORDTYPEID AND Has_Child_Account__c = true]) {
                sum = 0;
                for(Account childAcc : acc.ChildAccounts) {
                    sum = sum + childAcc.Total_open_Opportunities_on_org__c;
                    acc.Total_Open_Opportunities_On_Underlin_Org__c = sum;
                }
                accountsToUpdate.add(acc);
            }

            try {
                update accountsToUpdate;
            } catch (Exception e) {
                System.debug('Exception :' + e.getMessage());
            }
        }
    }

    private static List < AccountTeamMember > createCygateAccountManagerasAccountTeamMember(List < AccountTeamMember > listofCygateAccountMangerOnOrg, Account newAcc) {
        AccountTeamMember newCygateAccountManger = new AccountTeamMember();
        newCygateAccountManger.AccountId = newAcc.Id;
        newCygateAccountManger.UserId = newAcc.Cygate_Account_Manager__c;
        newCygateAccountManger.OpportunityAccessLevel = 'Read';
        newCygateAccountManger.AccountAccessLevel = 'Read';
        newCygateAccountManger.TeamMemberRole = ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER;
        listofCygateAccountMangerOnOrg.add(newCygateAccountManger);
        if (listofCygateAccountMangerOnOrg.size() > 0) {
            return listofCygateAccountMangerOnOrg;
        } else {
            return null;
        }
    }
    //Telia Sevice Manager Functionality
    private static List < AccountTeamMember > createTeliaServiceManagerasAccountTeamMember(List < AccountTeamMember > listofTeliaServiceMangerOnOrg, Account newAcc) {
        AccountTeamMember newTeliaServiceManger = new AccountTeamMember();
        newTeliaServiceManger.AccountId = newAcc.Id;
        newTeliaServiceManger.UserId = newAcc.Telia_Service_Manager__c;
        newTeliaServiceManger.OpportunityAccessLevel = 'Read';
        newTeliaServiceManger.AccountAccessLevel = 'Edit';
        newTeliaServiceManger.CaseAccessLevel = 'Read';
        newTeliaServiceManger.TeamMemberRole = ACCOUNT_TEAM_MEMBER_ROLE_TELIA_SERVICE_MANAGER;
        listofTeliaServiceMangerOnOrg.add(newTeliaServiceManger);
        if (listofTeliaServiceMangerOnOrg.size() > 0) {
            return listofTeliaServiceMangerOnOrg;
        } else {
            return null;
        }
    }
    //Telia LifeCycle Manager functionality
    private static List < AccountTeamMember > createTeliaLifeCycleManagerasAccountTeamMember(List < AccountTeamMember > listofTeliaLifeCycleMangerOnOrg, Account newAcc) {
        AccountTeamMember newTeliaLifeCycleManger = new AccountTeamMember();
        newTeliaLifeCycleManger.AccountId = newAcc.Id;
        newTeliaLifeCycleManger.UserId = newAcc.LifeCycle_Manager__c;
        newTeliaLifeCycleManger.OpportunityAccessLevel = 'Read';
        newTeliaLifeCycleManger.AccountAccessLevel = 'Edit';
        newTeliaLifeCycleManger.CaseAccessLevel = 'Read';
        newTeliaLifeCycleManger.TeamMemberRole = ACCOUNT_TEAM_MEMBER_ROLE_TELIA_LifeCycle_MANAGER;
        listofTeliaLifeCycleMangerOnOrg.add(newTeliaLifeCycleManger);
        if (listofTeliaLifeCycleMangerOnOrg.size() > 0) {
            return listofTeliaLifeCycleMangerOnOrg;
        } else {
            return null;
        }
    }
    //Telia Change Manager functionality
    private static List < AccountTeamMember > createTeliaChangeManagerasAccountTeamMember(List < AccountTeamMember > listofTeliaChangeMangerOnOrg, Account newAcc) {
        AccountTeamMember newTeliaChangeManger = new AccountTeamMember();
        newTeliaChangeManger.AccountId = newAcc.Id;
        newTeliaChangeManger.UserId = newAcc.Change_Manager__c;
        newTeliaChangeManger.OpportunityAccessLevel = 'Read';
        newTeliaChangeManger.AccountAccessLevel = 'Edit';
        newTeliaChangeManger.CaseAccessLevel = 'Read';
        newTeliaChangeManger.TeamMemberRole = ACCOUNT_TEAM_MEMBER_ROLE_TELIA_CHANGE_MANAGER;
        listofTeliaChangeMangerOnOrg.add(newTeliaChangeManger);
        if (listofTeliaChangeMangerOnOrg.size() > 0) {
            return listofTeliaChangeMangerOnOrg;
        } else {
            return null;
        }
    }
    //SM Functionality for Cygate
    private static List < AccountTeamMember > createCygateServiceManagerasAccountTeamMember(List < AccountTeamMember > listofCygateServiceManagerOnOrg, Account newAcc, Map < Id, AccountTeamMember > conATMMap) {


        //cygateServiceManagerId.add(newAcc.Cygate_Service_Manager__c);
        AccountTeamMember newCygateServiceManager = new AccountTeamMember();
        newCygateServiceManager.AccountId = newAcc.Id;
        //newCygateServiceManager.UserId = //need change here
        newCygateServiceManager.OpportunityAccessLevel = 'None';
        newCygateServiceManager.AccountAccessLevel = 'Read';
        newCygateServiceManager.CaseAccessLevel = 'None';
        newCygateServiceManager.ContactAccessLevel = 'Read';
        newCygateServiceManager.TeamMemberRole = ACCOUNT_TEAM_MEMBER_ROLE_SERVICE_MANAGER;
        listofCygateServiceManagerOnOrg.add(newCygateServiceManager);
        conATMMap.put(newAcc.Cygate_Service_Manager__c, newCygateServiceManager);


        if (listofCygateServiceManagerOnOrg.size() > 0) {
            return listofCygateServiceManagerOnOrg;
        } else {
            return null;
        }
    }
    public void populatewebsitedomain(List < Account > newList) {

        try {
            for (Account a : newList) {
                if (string.isNotblank(a.WebsiteDomain__c)) {
                    a.AccountDomain__c = a.WebsiteDomain__c.mid(0, a.WebsiteDomain__c.indexof('.'));
                }
                If (a.MC_Commercial_Setup__c != 'Forced RA' && a.MC_Commercial_Setup__c != 'Forced BA') {
                    a.MC_Commercial_Setup__c = MC_Commercial_Setup__c.getValues(a.Business_Unit_Code__c) != null ? MC_Commercial_Setup__c.getValues(a.Business_Unit_Code__c).Commercial_Setup__c : '';
                }
            }
        } catch (exception ex) {
            system.debug('Bad data in the website field' + ex.getmessage());
        }
    }
    private static void updateNamedSalesCoordinatorOnCases(List < Account > newList, Map < Id, Account > oldMap) {
        Set < Id > addNSCAccIDSet = new Set < Id > ();
        Set < Id > deleteNSCAccIDSet = new Set < Id > ();
        List < Id > queryAccIdList = new List < Id > ();
        Map < Id, Case > updateCaseMap = new Map < Id, Case > ();
        Map < Id, List < Case >> CaseAccountMap = new Map < Id, List < Case >> ();
        List < Case > caseList = new List < Case > ();
        List < AccountShare > accShareInsertList = new List < AccountShare > ();
        Set < Id > UserIdSet = new Set < Id > ();
        List < AccountShare > accShareQueryList = new List < AccountShare > ();
        List < AccountShare > deleteAccountShareList = new List < AccountShare > ();
        Set < Id > accSetAccShareDel = new Set < Id > ();

        for (Account acc : newList) {
            if (acc.Named_Sales_Coordinator__c != oldMap.get(acc.Id).Named_Sales_Coordinator__c) { // put in rectype check here as well
                if (acc.Named_Sales_Coordinator__c != NULL) {
                    addNSCAccIDSet.add(acc.Id);
                    queryAccIdList.add(Acc.Id);
                    UserIdSet.add(acc.Named_Sales_Coordinator__c);
                    UserIdSet.add(oldMap.get(acc.Id).Named_Sales_Coordinator__c);
                    accSetAccShareDel.add(acc.id);

                } else {
                    deleteNSCAccIDSet.add(acc.Id);
                    queryAccIdList.add(Acc.Id);
                    userIdSet.add(oldMap.get(acc.Id).Named_Sales_Coordinator__c);
                    accSetAccShareDel.add(acc.id);
                }
            }
        }
        if (queryAccIdList.size() > 0) {
            CaseList = [SELECT Id, Subject, Named_Sales_Coordinator__c, AccountId, Account.ParentId, Account.Parent.Named_Sales_Coordinator__c FROM CASE WHERE Account.ParentId IN:queryAccIdList];
            if (CaseList.size() > 0) {
                for (Case c : caseList) {
                    if (addNSCAccIDSet.contains(c.Account.ParentId) && c.Account.Parent.Named_Sales_Coordinator__c != NULL) {
                        c.Named_Sales_Coordinator__c = c.Account.Parent.Named_Sales_Coordinator__c;
                        updateCasemap.put(c.Id, c);
                    } else if (deleteNSCAccIdSet.contains(c.Account.ParentId) && c.Account.Parent.Named_Sales_Coordinator__c == NULL) {
                        c.Named_Sales_Coordinator__c = Null;
                        updateCaseMap.put(c.Id, c);
                    }
                }
            }


            if (userIdSet.size() > 0) {
                accShareQueryList = [Select Id, AccountId, RowCause, userOrGroupid FROM AccountShare WHERE AccountId IN:queryaccIdList AND UserOrGroupId IN:userIdSet];
            }
            for (Account acc : newList) {
                if (addNSCAccIDSet.contains(acc.Id)) {
                    AccountShare accshareIns = new AccountShare(Accountid = acc.Id, AccountAccessLevel = 'Read', UserOrGroupId = acc.Named_Sales_Coordinator__c, RowCause = Schema.AccountShare.RowCause.Manual, OpportunityAccessLevel = 'None');
                    accShareInsertList.add(accShareIns);
                }
            }
            for (AccountShare accShare : accShareQueryList) {
                if (accSetAccShareDel.contains(accshare.AccountId) && oldMap.get(accShare.AccountId).Named_Sales_Coordinator__c == accShare.UserorGroupId && accShare.RowCause == Schema.AccountShare.RowCause.Manual) {
                    deleteAccountShareList.add(accShare);
                }
            }
            try {
                if (accShareInsertList.size() > 0) {
                    insert accShareInsertList;
                }
            } catch (exception e) {
                system.debug(e.getmessage());
            }
            try {
                if (updateCaseMap.size() > 0) {
                    update updateCaseMap.values();
                }
            } catch (exception e) {
                system.debug(e.getmessage());
            }
            try {
                if (deleteAccountShareList.size() > 0) {
                    delete deleteAccountShareList;
                }
            } catch (exception e) {
                system.debug(e.getmessage());
            }
        }
    }
    //SALEF - 857 - only included in update statements since on insert accounts wont have cases attached to it
    private static void updateCaseAccess(List < Account > newList, Map < id, account > oldMap) {
        List < Case > caseList = new List < Case > ();
        Set < id > accidSet = new Set < Id > ();
        Map < Id, Id > accOwnerMap = new Map < Id, Id > ();
        Map < Id, Id > accSMMap = new Map < Id, Id > ();
        Map < Id, Id > removeCSMAccOwnerMap = new Map < Id, Id > ();
        Map < Id, Id > removeCSMAccSMMap = new Map < Id, Id > ();
        Set < Id > removeCSMIdSET = new Set < Id > ();
        List < CaseShare > caseShareInsertList = new List < CaseShare > ();
        Set < CaseShare > deleteCSHSet = new Set < CaseShare > ();
        List < CaseShare > deleteCSHList = new List < CaseShare > ();
        List < CaseShare > CaseShareList = new List < CaseShare > ();

        for (Account acc : newList) {
            if (acc.OwnerId != oldMap.get(acc.id).OwnerId) {
                accidSet.add(acc.id);
                accOwnerMap.put(acc.Id, acc.OwnerId);
                removeCSMIdSET.add(oldMap.get(acc.Id).OwnerId);
                removeCSMAccOwnerMap.put(acc.Id, oldMap.get(acc.Id).OwnerId);
            }
            if (acc.Telia_Service_manager__c != oldMap.get(acc.id).Telia_Service_Manager__c) {
                accidSet.add(acc.Id);
                if (acc.telia_Service_Manager__c != Null) {
                    accSMMap.put(acc.Id, acc.Telia_Service_Manager__c);
                }
                if (oldMap.get(acc.Id).Telia_Service_Manager__c != Null) {
                    removeCSMIdSet.add(OldMap.get(Acc.Id).Telia_Service_Manager__c);
                    removeCSMAccSMMap.put(acc.Id, OldMap.get(Acc.Id).Telia_Service_Manager__c);
                }
            }
        }
        if (accIdSet.size() > 0) {
            caseList = [Select Id, AccountId, Opportunity__r.OwnerId, Account.OwnerId, Account.Telia_Service_Manager__c, CreatedById FROM Case where AccountId IN:accidSet];
            if (caseList.size() > 0) {
                CaseShareList = [
                        SELECT Id, CaseAccessLevel, CaseId, Case.AccountId, UserOrGroupId
                        FROM CaseShare
                        WHERE CaseId IN:caseList AND UserOrGroupId IN:removeCSMIdSet AND RowCause = :'Manual'
                        AND CaseAccessLevel = 'Read'
                ];

                for (Case cs : caseList) {
                    if (accOwnerMap.get(cs.AccountId) != Null) {
                        Caseshare csh = new caseShare();
                        csh.CaseAccessLevel = 'Read';
                        csh.userOrGroupId = accOwnerMap.get(cs.AccountId);
                        csh.CaseId = cs.Id;
                        caseShareInsertList.add(csh);
                    }
                    if (accSMMap.get(cs.AccountId) != Null) {
                        Caseshare csh = new caseShare();
                        csh.CaseAccessLevel = 'Read';
                        csh.userOrGroupId = accSMMap.get(cs.AccountId);
                        csh.CaseId = cs.Id;
                        caseShareInsertList.add(csh);
                    }
                    for (CaseShare csh : caseShareList) {
                        if (csh.CaseId == cs.Id) {
                            if ((csh.UserOrgroupId == removeCSMAccOwnerMap.get(cs.AccountId) || csh.UserOrGroupId == removeCSMAccSMMap.get(cs.accountId)) && (csh.UserOrgroupId != cs.CreatedById) && (csh.UserOrGroupId != cs.Account.OwnerId) && (csh.userOrGroupId != cs.Account.Telia_Service_Manager__c) && (csh.UserOrGroupId != cs.opportunity__r.OwnerId)) {
                                deleteCSHSet.add(csh);
                            }
                        }
                    }
                }
            }
            if (deleteCSHSet.size() > 0) {
                deleteCSHList.addALL(deleteCSHSet);
            }
        }
        if (deleteCSHList.size() > 0) {
            try {
                delete deleteCSHList;
            } catch (exception e) {
                system.debug(e.getmessage());
            }
        }
        if (caseShareInsertList.size() > 0) {
            try {
                insert caseShareInsertList;
            } catch (exception e) {
                system.debug(e.getmessage());
            }
        }
    }

    public void updateAccountRecords(List < Account > newList, Map < id, Account > oldMap) {
        Map < String, String > sni1val = new Map < String, String > ();
        if (SNI_Title_for_Account__c.getAll().values() != NULL) {
            for (SNI_Title_for_Account__c SNI1CS : SNI_Title_for_Account__c.getAll().values()) {
                sni1val.put(SNI1CS.name, SNI1CS.Update_SNI_Avdelning_Text__c);
            }
        }
        Set < Id > accIds = new Set < Id > ();
        for (Account acc : newList) {
            if (oldMap != null && acc.Suggested_Parent__c != oldMap.get(acc.Id).Suggested_Parent__c && acc.Suggested_Parent__c != null) {
                accIds.add(acc.Suggested_Parent__c);
                //accIds.add(acc.ParentId);
            }
        }
        Map < Id, Account > accParentMap = new Map < Id, Account > ();
        if (accIds.size() > 0) {
            accParentMap = new Map < Id, Account > ([Select Id, OwnerId, Business_Area__c, Cust_Business_Unit__c, Business_Sales_Unit__c, Business_Unit_Lvl1__c, Business_Unit_Lvl2__c, Sales_Team__c, Business_Unit__c, DS__c from Account where Id IN:accIds]);
        }
        for (Account accObj : newList) {
            if (string.isNotBlank(accObj.Parent_KKnr__c))
                accObj.Parents_KKnr__c = accObj.Parent_KKnr__c;
            if (string.isNotBlank(accObj.Org_Nr__c))
                accObj.C2B_Org_nr__c = '16' + accObj.Org_Nr__c;
            if (oldMap != null) {
                if (accObj.Recommended_Credit_Amount__c != null && accObj.Recommended_Credit_Amount__c != oldMap.get(accObj.Id).Recommended_Credit_Amount__c) {
                    accObj.Credit_Check_Performed__c = System.today();
                }
                if (accObj.SNI1_Avdelning__c != null && !(sni1val.isEmpty()) && accObj.SNI1_Avdelning__c != oldMap.get(accObj.Id).SNI1_Avdelning__c) {
                    if (sni1val.containsKey(accObj.SNI1_Avdelning__c)) {
                        accObj.SNI1AvdelningTEXT__c = sni1val.get(accObj.SNI1_Avdelning__c);
                    }
                }
                if (accObj.SNI2_Avdelning__c != null && !(sni1val.isEmpty()) && accObj.SNI2_Avdelning__c != oldMap.get(accObj.Id).SNI2_Avdelning__c) {
                    if (sni1val.containsKey(accObj.SNI2_Avdelning__c)) {
                        accObj.SNI2AvdelningTEXT__c = sni1val.get(accObj.SNI2_Avdelning__c);
                    }
                }
                if (accObj.SNI3_Avdelning__c != null && !(sni1val.isEmpty()) && accObj.SNI3_Avdelning__c != oldMap.get(accObj.Id).SNI3_Avdelning__c) {
                    if (sni1val.containsKey(accObj.SNI3_Avdelning__c)) {
                        accObj.SNI3AvdelningTEXT__c = sni1val.get(accObj.SNI3_Avdelning__c);
                    }
                }
                if (accObj.SNI4_Avdelning__c != null && !(sni1val.isEmpty()) && accObj.SNI4_Avdelning__c != oldMap.get(accObj.Id).SNI4_Avdelning__c) {
                    if (sni1val.containsKey(accObj.SNI4_Avdelning__c)) {
                        accObj.SNI4AvdelningTEXT__c = sni1val.get(accObj.SNI4_Avdelning__c);
                    }
                }
                if (accObj.SNI5_Avdelning__c != null && !(sni1val.isEmpty()) && accObj.SNI5_Avdelning__c != oldMap.get(accObj.Id).SNI5_Avdelning__c) {
                    if (sni1val.containsKey(accObj.SNI5_Avdelning__c)) {
                        accObj.SNI5AvdelningTEXT__c = sni1val.get(accObj.SNI5_Avdelning__c);
                    }
                }
                if (oldMap != null && ((accObj.Cust_Business_Unit__c != accObj.Suggested_Business_Unit__c && accObj.Suggested_Business_Unit__c != oldMap.get(accObj.Id).Suggested_Business_Unit__c) ||
                        (accObj.Business_Unit_Lvl1__c != accObj.Suggested_SubBusinessUnitLvl1__c && accObj.Suggested_SubBusinessUnitLvl1__c != oldMap.get(accObj.Id).Suggested_SubBusinessUnitLvl1__c) ||
                        (accObj.Business_Unit_Lvl2__c != accObj.Suggested_SubBusinessUnitLvl2__c && accObj.Suggested_SubBusinessUnitLvl2__c != oldMap.get(accObj.Id).Suggested_SubBusinessUnitLvl2__c) ||
                        (accObj.Business_Sales_Unit__c != accObj.Suggested_Business_Sales_Unit__c && accObj.Suggested_Business_Sales_Unit__c != oldMap.get(accObj.Id).Suggested_Business_Sales_Unit__c) ||
                        (accObj.Sales_Team__c != accObj.Suggested_Sales_Team__c && accObj.Suggested_Sales_Team__c != oldMap.get(accObj.Id).Suggested_Sales_Team__c) ||
                        (accObj.Business_Unit__c != accObj.Suggested_Sales_Unit__c && accObj.Suggested_Sales_Unit__c != oldMap.get(accObj.Id).Suggested_Sales_Unit__c) ||
                        (accObj.DS__c != accObj.Suggested_Delsegment__c && accObj.Suggested_Delsegment__c != oldMap.get(accObj.Id).Suggested_Delsegment__c) ||
                        (accObj.Business_Area__c != accObj.Suggested_Business_Area__c && accObj.Suggested_Business_Area__c != oldMap.get(accObj.Id).Suggested_Business_Area__c) ||
                        (accObj.OwnerId != accObj.Suggested_Owner__c && accObj.Suggested_Owner__c != oldMap.get(accObj.Id).Suggested_Owner__c) ||
                        (accObj.ParentId != accObj.Suggested_Parent__c && accObj.Suggested_Parent__c != oldMap.get(accObj.Id).ParentId)
                )) {
                    accObj.Customer_Information_Changed__c = true; //setting flag to indicate there is a change in customer segmentation
                    accObj.Customer_Information_Changed_Date__c = System.Today();
                }
                if ((OldMap == null || accObj.Approved__c != oldmap.get(accObj.Id).Approved__c) && accObj.Approved__c) {
                    accObj.Approved_By_Time__c = UserInfo.getName() + ' on  ' + System.now();
                }

                if (oldMap != null && accObj.Suggested_Parent__c != oldMap.get(accObj.Id).Suggested_Parent__c && accObj.Suggested_Parent__c != null) {
                    //on reparent update suggested segmentation as per the parent.
                    accObj.Suggested_Business_Area__c = accParentMap.get(accObj.Suggested_Parent__c).Business_Area__c;
                    accObj.Suggested_Business_Unit__c = accParentMap.get(accObj.Suggested_Parent__c).Cust_Business_Unit__c;
                    accObj.Suggested_Business_Sales_Unit__c = accParentMap.get(accObj.Suggested_Parent__c).Business_Sales_Unit__c;
                    accObj.Suggested_SubBusinessUnitLvl1__c = accParentMap.get(accObj.Suggested_Parent__c).Business_Unit_Lvl1__c;
                    accObj.Suggested_SubBusinessUnitLvl2__c = accParentMap.get(accObj.Suggested_Parent__c).Business_Unit_Lvl2__c;
                    accObj.Suggested_Sales_Team__c = accParentMap.get(accObj.Suggested_Parent__c).Sales_Team__c;
                    accObj.Suggested_Sales_Unit__c = accParentMap.get(accObj.Suggested_Parent__c).Business_Unit__c;
                    accObj.Suggested_Delsegment__c = accParentMap.get(accObj.Suggested_Parent__c).DS__c;
                    accObj.Suggested_Owner__c = accParentMap.get(accObj.Suggested_Parent__c).OwnerId;
                }

                //If suggested parent is changed and Approved set flag of reparenting for batch to process
                if (OldMap != null && accObj.Suggested_Parent__c != null && accObj.Suggested_Parent__c != accObj.ParentId && (accObj.Approved__c != oldmap.get(accObj.Id).Approved__c || accObj.Suggested_Parent__c != oldmap.get(accObj.Id).Suggested_Parent__c) && accObj.Approved__c == true && accObj.Org_Nr__c != null) {
                    accObj.Is_Parent_Changed__c = true;
                //SALEF-8400 To store the date for Change of Parent account
                    accObj.Parent_Account_Change_date__c = Datetime.now();
                    accObj.Old_Parent_Id__c= accObj.ParentId;
                }
                if (OldMap != null && (accObj.Approved__c == false || accObj.Suggested_Parent__c == null || accObj.Suggested_Parent__c == accObj.ParentId) && ((accObj.Suggested_Parent__c != oldmap.get(accObj.Id).Suggested_Parent__c || accObj.Approved__c != oldmap.get(accObj.Id).Approved__c) && accObj.Is_Parent_Changed__c == true) && accObj.Org_Nr__c != null) {
                    accObj.Is_Parent_Changed__c = false;
                    accObj.Old_Parent_Id__c=null;
                }


            } else {
                if (accObj.SNI1_Avdelning__c != null && !(sni1val.isEmpty()) && sni1val.containsKey(accObj.SNI1_Avdelning__c))
                    accObj.SNI1AvdelningTEXT__c = sni1val.get(accObj.SNI1_Avdelning__c);
                if (accObj.SNI2_Avdelning__c != null && !(sni1val.isEmpty()) && sni1val.containsKey(accObj.SNI2_Avdelning__c))
                    accObj.SNI2AvdelningTEXT__c = sni1val.get(accObj.SNI2_Avdelning__c);
                if (accObj.SNI3_Avdelning__c != null && !(sni1val.isEmpty()) && sni1val.containsKey(accObj.SNI3_Avdelning__c))
                    accObj.SNI3AvdelningTEXT__c = sni1val.get(accObj.SNI3_Avdelning__c);
                if (accObj.SNI4_Avdelning__c != null && !(sni1val.isEmpty()) && sni1val.containsKey(accObj.SNI4_Avdelning__c))
                    accObj.SNI4AvdelningTEXT__c = sni1val.get(accObj.SNI4_Avdelning__c);
                if (accObj.SNI5_Avdelning__c != null && !(sni1val.isEmpty()) && sni1val.containsKey(accObj.SNI5_Avdelning__c))
                    accObj.SNI5AvdelningTEXT__c = sni1val.get(accObj.SNI5_Avdelning__c);
            }
            if (accObj.Cygate_Should_Have_Account_Plan__c != 'Ja' && (accObj.Cygate_Customer_Category__c == 'A-kund' || accObj.Cygate_Customer_Category__c == 'key-kund'))
                accObj.Cygate_Should_Have_Account_Plan__c = 'Ja';
        }
    }

    private static void cygateSubAccountOptOut(List < Account > newList, Map < Id, Account > oldMap) {/*
        Set < Id > accList = new Set < Id > ();
        Set < Id > parentIds = new Set < Id > ();
        List < Account > accSubList = new List < Account > ();
        String subAccRecType = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_CYGATE_SUB);

        if (!System.isBatch()) {
            for (Account acc: newList) {
                If(acc.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_CYGATE_SUB) && oldMap == null) {
                    if (acc.ParentId != null) {
                        parentIds.add(acc.ParentId);
                        accSubList.add(acc);
                    }

                }
                else if (oldMap != null && (acc.Marketing_Mails_Opt_Out__c != oldMap.get(acc.Id).Marketing_Mails_Opt_Out__c || acc.From_Date__c != oldMap.get(acc.Id).From_Date__c || acc.To_Date__c != oldMap.get(acc.Id).To_Date__c || acc.Marketing_Mails_Opt_Out_Cygate__c != oldMap.get(acc.Id).Marketing_Mails_Opt_Out_Cygate__c || acc.From_Date_Cygate__c != oldMap.get(acc.Id).From_Date_Cygate__c || acc.To_Date_Cygate__c != oldMap.get(acc.Id).To_Date_Cygate__c)) {
                    accList.add(acc.Id);
                }
            }
            Map < Id, Account > accountEntries = new Map < Id, Account > ();

            if (!parentIds.IsEmpty()) {
                accountEntries = new Map < Id, Account > ([SELECT Id, RecordTypeId, Marketing_Mails_Opt_Out__c, From_Date__c, To_Date__c, Newsletter_Telia__c, Newsletter_Cygate__c,
                    Survey_Telia__c, Survey_Cygate__c, Event_Cygate__c, Event_Telia__c, Campaigns_Telia__c, Campaigns_Cygate__c, SMS_Telia__c, SMS_Cygate__c,
                    From_Date_Cygate__c, To_Date_Cygate__c, Opt_Out_Stages_Cygate__c, Marketing_Mails_Opt_Out_Cygate__c,
                    Process_Opt_Out__c, Process_Opt_Out_Cygate__c
                    FROM Account where Id IN: parentIds
                ]);
            }
            if (!accSubList.isEmpty()) {
                for (Account accRec: accSubList) {

                    accRec.From_Date_Cygate__c = accountEntries.get(accRec.ParentId).From_Date_Cygate__c;
                    accRec.To_Date_Cygate__c = accountEntries.get(accRec.ParentId).To_Date_Cygate__c;
                    accRec.Marketing_Mails_Opt_Out_Cygate__c = accountEntries.get(accRec.ParentId).Marketing_Mails_Opt_Out_Cygate__c;
                    accRec.Newsletter_Cygate__c = accountEntries.get(accRec.ParentId).Newsletter_Cygate__c;
                    accRec.Survey_Cygate__c = accountEntries.get(accRec.ParentId).Survey_Cygate__c;
                    accRec.Event_Cygate__c = accountEntries.get(accRec.ParentId).Event_Cygate__c;
                    accRec.Campaigns_Cygate__c = accountEntries.get(accRec.ParentId).Campaigns_Cygate__c;
                    accRec.SMS_Cygate__c = accountEntries.get(accRec.ParentId).SMS_Cygate__c;


                    accRec.From_Date__c = accountEntries.get(accRec.ParentId).From_Date__c;
                    accRec.To_Date__c = accountEntries.get(accRec.ParentId).To_Date__c;
                    accRec.Marketing_Mails_Opt_Out__c = accountEntries.get(accRec.ParentId).Marketing_Mails_Opt_Out__c;
                    accRec.Newsletter_Telia__c = accountEntries.get(accRec.ParentId).Newsletter_Telia__c;
                    accRec.Survey_Telia__c = accountEntries.get(accRec.ParentId).Survey_Telia__c;
                    accRec.Event_Telia__c = accountEntries.get(accRec.ParentId).Event_Telia__c;
                    accRec.Campaigns_Telia__c = accountEntries.get(accRec.ParentId).Campaigns_Telia__c;
                    accRec.SMS_Telia__c = accountEntries.get(accRec.ParentId).SMS_Telia__c;
                }
            }
            List < Account > checkSubAccs = new List < Account > ();

            if (!accList.isEmpty()) {
                checkSubAccs = new List < Account > ([SELECT Id, ParentId, Name, RecordTypeId, RecordType.Name, Parent.Marketing_Mails_Opt_Out__c, Parent.From_Date__c, Parent.To_Date__c, Parent.Newsletter_Telia__c, Parent.Newsletter_Cygate__c,
                    Parent.Survey_Telia__c, Parent.Survey_Cygate__c, Parent.Event_Cygate__c, Parent.Event_Telia__c, Parent.Campaigns_Telia__c, Parent.Campaigns_Cygate__c, Parent.SMS_Telia__c, Parent.SMS_Cygate__c,
                    Parent.From_Date_Cygate__c, Parent.To_Date_Cygate__c, Parent.Opt_Out_Stages_Cygate__c, Parent.Marketing_Mails_Opt_Out_Cygate__c,
                    Parent.Process_Opt_Out__c, Parent.Process_Opt_Out_Cygate__c
                    FROM Account where ParentId IN: accList AND RecordTypeId =: subAccRecType
                ]);
            }
            MAP < Id, Account > updateSubAcc = new MAP < Id, Account > ();

            if (!checkSubAccs.isEmpty()) {

                for (Account subAcc: checkSubAccs) {
                    subAcc.From_Date_Cygate__c = subAcc.Parent.From_Date__c;
                    subAcc.From_Date_Cygate__c = subAcc.Parent.From_Date_Cygate__c;
                    subAcc.To_Date_Cygate__c = subAcc.Parent.To_Date_Cygate__c;
                    subAcc.Marketing_Mails_Opt_Out_Cygate__c = subAcc.Parent.Marketing_Mails_Opt_Out_Cygate__c;
                    subAcc.Newsletter_Cygate__c = subAcc.Parent.Newsletter_Cygate__c;
                    subAcc.Survey_Cygate__c = subAcc.Parent.Survey_Cygate__c;
                    subAcc.Event_Cygate__c = subAcc.Parent.Event_Cygate__c;
                    subAcc.Campaigns_Cygate__c = subAcc.Parent.Campaigns_Cygate__c;
                    subAcc.SMS_Cygate__c = subAcc.Parent.SMS_Cygate__c;

                    subAcc.From_Date__c = subAcc.Parent.From_Date__c;
                    subAcc.To_Date__c = subAcc.Parent.To_Date__c;
                    subAcc.Marketing_Mails_Opt_Out__c = subAcc.Parent.Marketing_Mails_Opt_Out__c;
                    subAcc.Newsletter_Telia__c = subAcc.Parent.Newsletter_Telia__c;
                    subAcc.Survey_Telia__c = subAcc.Parent.Survey_Telia__c;
                    subAcc.Event_Telia__c = subAcc.Parent.Event_Telia__c;
                    subAcc.Campaigns_Telia__c = subAcc.Parent.Campaigns_Telia__c;
                    subAcc.SMS_Telia__c = subAcc.Parent.SMS_Telia__c;

                    updateSubAcc.put(subAcc.Id, subAcc);

                }
            }



            if (updateSubAcc.size() > 0) {
                try {
                    update updateSubAcc.values();
                }
                Catch(Exception e) {
                    System.debug('Exception :' + e.getMessage());
                }
            }

        }*/
    }
    public static void onAccCreate(List < Account > newList) {
        List < Account > toUpdate = new List < Account > ();
        Set < Id > accIds = new Set < Id > ();
        String z103 = String.ValueOf(String.valueOf(Label.Z103));
        String y400 = String.ValueOf(String.valueOf(Label.Y400));
        Set < Id > defaultKKnrs = new Set < Id > ();
        defaultKKnrs.add(z103);
        defaultKKnrs.add(Y400);
        //System.debug(defaultKKnrs);
        List < String> currentKknr = new List < String> ();
        List <String> kknrList = new List <String>();
        for (Account ac : [Select Kundkonto_Nr__c From Account where Kundkonto_Nr__c like 'C%']) {
            kknrList.add(ac.Kundkonto_Nr__c);
        }
        List < Account > orgAccs = new List < Account > ();
        for (Account acc : newlist) {
            if (acc.Org_Nr__c != null && acc.ParentId == null) {
                orgAccs.add(acc);
            }
        }
        Map < Id, Account > accParentMap = new Map < Id, Account > ();
        if (orgAccs.size() > 0) {
            accParentMap = new Map < Id, Account > ([
                    Select Id, OwnerId, Customer_Segment__c, Business_Area__c, Telia_Engaged__c, RecordTypeId, Cust_Business_Unit__c, Business_Sales_Unit__c, Business_Unit_Lvl1__c, Business_Unit_Lvl2__c,
                            Sales_Team__c, Business_Unit__c, Business_Unit_Code__c, DS__c, Industry, Account_Type__c
                    from Account
                    where Id IN:defaultKKnrs
            ]);
        }
        //System.debug(accParentMap);
        for (Account accObj : newList) {
            if ((accObj.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK) || accOBJ.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1) || accOBj.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2))) {
                //For Kundkonto account set Segmentation as Suggested Segmentation on creation
                accObj.Cust_Business_Unit__c = accObj.Suggested_Business_Unit__c;
                accObj.Business_Sales_Unit__c = accObj.Suggested_Business_Sales_Unit__c;
                accObj.Business_Unit_Lvl1__c = accObj.Suggested_SubBusinessUnitLvl1__c;
                accObj.Business_Unit_Lvl2__c = accObj.Suggested_SubBusinessUnitLvl2__c;
                accObj.Business_Unit_Code__c = accObj.Suggested_Business_Unit_Code__c;
                accObj.Sales_Team__c = accObj.Suggested_Sales_Team__c;
                accObj.Business_Unit__c = accObj.Suggested_Sales_Unit__c;
                accObj.DS__c = accObj.Suggested_Delsegment__c;
                accObj.Industry = accObj.Suggested_Industry__c;
                accObj.Account_Type__c = accObj.Suggested_Account_Type__c;
                if (accObj.Approved__c == true) {
                    accObj.Approved_By_Time__c = UserInfo.getName() + ' on  ' + System.now();
                }
                String randomNumberCheck = generateRandomNr();
                currentKknr.add(randomNumberCheck);
                while (kknrList.contains(randomNumberCheck) || currentKknr.contains(randomNumberCheck)) {
                    randomNumberCheck = generateRandomNr();
                }
                accObj.Kundkonto_Nr__c = randomNumberCheck;
                currentKknr.add(randomNumberCheck);
            }
            if (!Test.isRunningTest()) {
                if (!(accObj.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_OMB))) && (accObj.Org_Nr__c != null && accObj.ParentId == null)) {

                    //For Org Accounts Set Parent account based on Telia Engaged field and set its Segmentation as that of Parent.
                    if (accObj.Telia_Engaged__c == true) {
                        accObj.ParentId = String.valueOf(Label.Z103);
                        accObj.Customer_Segment__c = accParentMap.get(z103).Customer_Segment__c;
                        accObj.Business_Area__c = accParentMap.get(z103).Business_Area__c;
                        accObj.Cust_Business_Unit__c = accParentMap.get(z103).Cust_Business_Unit__c;
                        accObj.Business_Sales_Unit__c = accParentMap.get(z103).Business_Sales_Unit__c;
                        accObj.Business_Unit_Lvl1__c = accParentMap.get(z103).Business_Unit_Lvl1__c;
                        accObj.Business_Unit_Lvl2__c = accParentMap.get(z103).Business_Unit_Lvl2__c;
                        accObj.Business_Unit_Code__c = accParentMap.get(z103).Business_Unit_Code__c;
                        accObj.Sales_Team__c = accParentMap.get(z103).Sales_Team__c;
                        accObj.Business_Unit__c = accParentMap.get(z103).Business_Unit__c;
                        accObj.DS__c = accParentMap.get(z103).DS__c;
                        accObj.Industry = accParentMap.get(z103).Industry;
                        accObj.Account_Type__c = accParentMap.get(z103).Account_Type__c;
                        accObj.OwnerId = accParentMap.get(z103).OwnerId;
                        accObj.Gesb_Flag_Org__c = true;

                        if ((accParentMap.get(z103).Cust_Business_Unit__c == 'SME' || accParentMap.get(z103).Cust_Business_Unit__c == 'Enterprise Other') && accObj.Security_Category__c == null)
                            accObj.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
                        if ((accParentMap.get(z103).Cust_Business_Unit__c == 'Large Business' || accParentMap.get(z103).Cust_Business_Unit__c == 'Public & Key') && accObj.Security_Category__c == null)
                            accObj.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
                    } else {
                        accObj.ParentId = String.valueOf(Label.Y400);
                        accObj.Customer_Segment__c = accParentMap.get(y400).Customer_Segment__c;
                        accObj.Business_Area__c = accParentMap.get(y400).Business_Area__c;
                        accObj.Cust_Business_Unit__c = accParentMap.get(y400).Cust_Business_Unit__c;
                        accObj.Business_Sales_Unit__c = accParentMap.get(y400).Business_Sales_Unit__c;
                        accObj.Business_Unit_Lvl1__c = accParentMap.get(y400).Business_Unit_Lvl1__c;
                        accObj.Business_Unit_Lvl2__c = accParentMap.get(y400).Business_Unit_Lvl2__c;
                        accObj.Business_Unit_Code__c = accParentMap.get(y400).Business_Unit_Code__c;
                        accObj.Sales_Team__c = accParentMap.get(y400).Sales_Team__c;
                        accObj.Business_Unit__c = accParentMap.get(y400).Business_Unit__c;
                        accObj.DS__c = accParentMap.get(y400).DS__c;
                        accObj.Industry = accParentMap.get(y400).Industry;
                        accObj.Account_Type__c = accParentMap.get(y400).Account_Type__c;
                        accObj.OwnerId = accParentMap.get(y400).OwnerId;
                        accObj.Gesb_Flag_Org__c = true;

                        if ((accParentMap.get(y400).Cust_Business_Unit__c == 'SME' || accParentMap.get(y400).Cust_Business_Unit__c == 'Enterprise Other') && accObj.Security_Category__c == null)
                            accObj.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
                        if ((accParentMap.get(y400).Cust_Business_Unit__c == 'Large Business' || accParentMap.get(y400).Cust_Business_Unit__c == 'Public & Key') && accObj.Security_Category__c == null)
                            accObj.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
                    }
                }
            }
        }
    }


    public static String generateRandomNr() {
        Integer len = 5;
        String genStr = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = genStr.substring(0, len);
        String appendC = 'C' + randomNumber;
        return appendC;
    }

    public static void DeleteOnlyOMBAccount(List < Account > oldList) {
        for (Account acc : oldList) {

            if (!(acc.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_OMB))) && (SEUtility.isEnterpriseBusinessAdminUser(UserInfo.getProfileId()))) {
                if (oldList != null)
                    acc.addError('You cannot delete the Account');

            }
        }
    }

    public static void addTeamMemberOnKKNROwnerChange(List < Account > newList, Map < Id, Account > oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accnts = new List<Account>();

        for (Account acc : newList) {
            if (SEUtility.isKundKontoAccountRecordType(acc.RecordTypeId) && acc.ownerId != oldMap.get(acc.Id).OwnerId) {
                accIds.add(acc.Id);
            }
        }
        if (!accIds.isEmpty()) {
            atm = [select Id,AccountAccessLevel, AccountId, CaseAccessLevel, ContactAccessLevel, OpportunityAccessLevel, UserId, TeamMemberRole from AccountTeamMember where AccountId IN :accIds AND TeamMemberRole like '%Cygate%'];
        }
    }

    public static void addTeamMemberOnKKNROwnerChangeafter(List < Account > newList, Map < Id, Account > oldMap) {
        Set<Id> accountIds = new Set<Id>();
        List<AccountTeamMember> insertATM = new List<AccountTeamMember>();

        for (Account acc : newList) {
            if (SEUtility.isKundKontoAccountRecordType(acc.RecordTypeId) && acc.ownerId != oldMap.get(acc.Id).OwnerId) {
                accountIds.add(acc.Id);
            }
        }

        if (!accountIds.isEmpty()) {
            if (atm != null) {
                if (atm.size() > 0) {
                    insertATM = createAccountTeamMemberOnKKNR(atm);
                }
            }
        }
        if (!insertATM.isEmpty()) {
            insert insertATM;
            atm.clear();
        }

    }
    public static void updateCygateAccountManagerOnLeadContact (List <Account> newList, Map < Id, Account > oldMap ) {
        // Create a set to store the IDs of the accounts that have been updated
        List<Id> updatedAccountIds = new List<Id>();

        // Iterate through the list of accounts that were updated
        for (Account oneAccount : newList) {
            // Check if the Cygate_Account_Manager__c field was updated
            if (oneAccount.Cygate_Account_Manager__c != oldMap.get(oneAccount.Id).Cygate_Account_Manager__c) {
                // Add the ID of the account to the set
                updatedAccountIds.add(oneAccount.Id);
            }
        }

        // Check if there are any accounts that need to be processed
        if (!updatedAccountIds.isEmpty()) {
            // Create a new instance of the BatchUpdateCygateAccountManager class
            BatchUpdateCygateAccountManager batch = new BatchUpdateCygateAccountManager(updatedAccountIds);
            // Execute the batch job
            Database.executeBatch(batch, 50);
        }
    }
    private static List < AccountTeamMember > createAccountTeamMemberOnKKNR(List < AccountTeamMember > listofATMonKKNR) {
        List<AccountTeamMember> newlistofATMonKKNR = new List<AccountTeamMember>();
        for (AccountTeamMember acctm : listofATMonKKNR) {
            AccountTeamMember newATM = new AccountTeamMember();
            newATM.AccountId = acctm.AccountId;
            newATM.UserId = acctm.UserId;
            newATM.OpportunityAccessLevel = acctm.OpportunityAccessLevel;
            newATM.AccountAccessLevel = acctm.AccountAccessLevel;
            newATM.CaseAccessLevel = acctm.CaseAccessLevel;
            newATM.TeamMemberRole = acctm.TeamMemberRole;
            newlistofATMonKKNR.add(newATM);
        }
        if (newlistofATMonKKNR.size() > 0) {
            return newlistofATMonKKNR;
        } else {
            return null;
        }
    }

    /**
     * @Description:  
     * Ensure 
     *  - 'SME/SOHO Organisation' Account 'Customer_Success_Manager' cannot be updated to
     * a non-empty value different from any of its sibling Account 'Customer_Success_Manager' values
     *  - KKNr retains its 'Customer_Success_Manager' despite the Manager being removed for its child
     * 'SME/SOHO Organisation' Account, if the KKNr has any other child SME Accounts with the same CSM
     * IMPORTANT: Invoked Before DML operation and works in tandem with 
     * updateParentKKNrCustomerSuccessMgr(), invoked After DML operation 
     * @param newList - List of the new versions of the Account records.
     * @param oldMap - A map of IDs to the old versions of the Account records.
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    private static void setUpParentKKNrCustomerSuccessMgrUpdate(List<Account> newList, Map<Id,Account> oldMap){
        Set<Id> setSMEAccsWithCustomerSuccessMgrToUpdate = new Set<Id>();
        Set<Id> setInvalidParentKKNRsUpdateIds = new Set<Id>();
        Map<Id,List<Account>> mapKKNrIdsToLstSMEAccountsWithCSMsToUpdate = new Map<Id,List<Account>>();
        Map<Id,Id> mapCurrentRunKKNrIdsToCustomerSuccessManagerIds = new Map<Id,Id>();
        for(Account curAccount : newList){
            if( isAssignedNewCustomerSuccessManager(curAccount, oldMap != null ? oldMap.get(curAccount.Id) : null) ){
                // It is allowed for a single transaction to clear CSMgr for one of KKNr parent's child Accounts
                // and set a new CSMgr for another child Account of the same KKNr parent,
                // but parent shall be updated to reference the new CSMgr value (granted the transaction is valid)
                if( mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.get(curAccount.ParentId) == null){
                    mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.put(curAccount.ParentId, curAccount.Customer_Success_Manager__c);
                }
                if( mapKKNrIdsToLstSMEAccountsWithCSMsToUpdate.get(curAccount.ParentId) == null){
                    mapKKNrIdsToLstSMEAccountsWithCSMsToUpdate.put(curAccount.ParentId, new List<Account>());
                }
                mapKKNrIdsToLstSMEAccountsWithCSMsToUpdate.get(curAccount.ParentId).add(curAccount);
                // Must not assign different CSMgrs to Accounts with the same parent KKNr
                if( curAccount.Customer_Success_Manager__c != null
                    && mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.get(curAccount.ParentId) != curAccount.Customer_Success_Manager__c
                ){
                    setInvalidParentKKNRsUpdateIds.add(curAccount.ParentId);
                } else if(curAccount.Id != null){
                    // keep track of Accounts being modified in the current transaction
                    setSMEAccsWithCustomerSuccessMgrToUpdate.add(curAccount.Id);
                }
            }
        }

        // Disallow updates attempting to assign different CSMgrs to SME Accounts sharing a parent KKNr
        for(Id curParentKKNRId : setInvalidParentKKNRsUpdateIds){
            List<Account> lstSMEAccountsWithInvalidCSMgrUpdates = mapKKNrIdsToLstSMEAccountsWithCSMsToUpdate.get(curParentKKNRId);
            mapKKNrIdsToLstSMEAccountsWithCSMsToUpdate.remove(curParentKKNRId);
            mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.remove(curParentKKNRId);
            for(Account curSMEAccountWithInvalidCSMUpdate : lstSMEAccountsWithInvalidCSMgrUpdates){
                curSMEAccountWithInvalidCSMUpdate.addError(System.Label.Error_Different_CSManagers_Current_Operation);
            }
        }
        
        // Disallow new Customer_Success_Manager assignment, if other SME Accounts of the same parent KKNr
        // are currently assigned a different Customer_Success_Manager.
        // NOTE: Validation might not work correctly, if the transaction attempts to update more than 200 Accounts  
        if(!mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.isEmpty()){
            for(Account curParentKKNRAccount : [SELECT  Id, Customer_Success_Manager__c,
                                                        (   SELECT Id, Customer_Success_Manager__c
                                                            FROM ChildAccounts 
                                                            WHERE RecordTypeId = :SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME)
                                                            AND ID NOT IN :setSMEAccsWithCustomerSuccessMgrToUpdate
                                                            AND Customer_Success_Manager__c != null)
                                                FROM Account
                                                WHERE Id IN :mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.keySet()
                                                AND OwnerId != :System.Label.IntegrationUser
                                                
            ]){
                if( curParentKKNRAccount.ChildAccounts.size() > 0 ){
                    // Do not clear parent KKNr Customer_Success_Manager, if it has other SME Accounts
                    // with a Customer_Success_Manager assigned
                    if(mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.get(curParentKKNRAccount.Id) == null){
                        mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.remove(curParentKKNRAccount.Id);
                    // Disallow assignments of different CSMgrs for sibling SME Accounts
                    // (trust all other Child Accounts had the same CSM before operation, if assigned at all)
                    } else if(  mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.get(curParentKKNRAccount.Id)
                                != curParentKKNRAccount.ChildAccounts[0].Customer_Success_Manager__c
                    ){
                        List<Account> lstSMEAccountsWithInvalidCSMgrUpdates = mapKKNrIdsToLstSMEAccountsWithCSMsToUpdate.get(curParentKKNRAccount.Id);
                        mapKKNrIdsToLstSMEAccountsWithCSMsToUpdate.remove(curParentKKNRAccount.Id);
                        mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.remove(curParentKKNRAccount.Id);
                        for(Account curSMEAccountWithInvalidCSMUpdate : lstSMEAccountsWithInvalidCSMgrUpdates){
                            curSMEAccountWithInvalidCSMUpdate.addError(
                                System.Label.Error_Different_CSManager_Assigned_To_Sibling
                                + ' '
                                + curParentKKNRAccount.ChildAccounts[0].Id
                                + '.');
                        }
                    // Do not update parent KKNr Customer_Success_Manager unnecessarily  
                    } else if( mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.get(curParentKKNRAccount.Id)
                                == curParentKKNRAccount.Customer_Success_Manager__c
                    ){
                        mapCurrentRunKKNrIdsToCustomerSuccessManagerIds.remove(curParentKKNRAccount.Id);
                    }
                }
            }
            // Store required valid parent KKNr updates in a static map
            // to use in updateParentKKNrCustomerSuccessMgr()
            mapKKNrIdsToNewCustomerSuccessManagerIds.putAll(mapCurrentRunKKNrIdsToCustomerSuccessManagerIds);
        }
    }

    /**
     * @Description:
     * Update parent KKNR 'Customer Success Manager' to the Manager assigned 
     * to its child 'SME/SOHO Organisation' Account.
     * IMPORTANT: Works in tandem with setUpParentKKNrCustomerSuccessMgrUpdate(),
     * invoked Before DML operation
     * @param newList - List of the new versions of the Account records.
     * @param oldMap - A map of IDs to the old versions of the Account records.
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Transferred Flow to trigger.  
     * 20.04.2023 [TB] SALEF-8608 - Introduced as 'Account - Parent KKNR Customer Success Manager Update' Flow. 
     **/
    private static void updateParentKKNrCustomerSuccessMgr(List<Account> newList, Map<Id,Account> oldMap){
        if(mapKKNrIdsToNewCustomerSuccessManagerIds.isEmpty()){
            return;
        }
        List<Account> lstKKNRAccountsWithCSMToUpdate = new List<Account>();
        // Check if an Account got a valid Customer_Success_Manager assigned (or cleared),
        // and whether the Account's or its sibling's CSM assignment should be reflected
        // on their parent KKNr 
        for(Account curAccount : newList){
            if( isAssignedNewCustomerSuccessManager(curAccount, oldMap != null ? oldMap.get(curAccount.Id) : null)
                && mapKKNrIdsToNewCustomerSuccessManagerIds.containsKey(curAccount.ParentId)
            ){
                lstKKNRAccountsWithCSMToUpdate.add( new Account(Id = curAccount.ParentId,
                    Customer_Success_Manager__c = mapKKNrIdsToNewCustomerSuccessManagerIds.get(curAccount.ParentId)));
                mapKKNrIdsToNewCustomerSuccessManagerIds.remove(curAccount.ParentId);
            }
        }
        if(!lstKKNRAccountsWithCSMToUpdate.isEmpty()){
            update lstKKNRAccountsWithCSMToUpdate;
        }
    }

    /**
     * @Description:
     * Helper method determining whether an Account has had its Customer_Success_Manager
     * changed and whether the change might require further actions.
     * @param accNewValues - New versions of an Account record.
     * @param accOldValues - Old versions of an Account record..
     * @Modifications:
     * 05.06.2023 [TB] LTAT-9674 - Introduced.
     **/
    private static Boolean isAssignedNewCustomerSuccessManager(Account accNewValues, Account accOldValues){
        return (accNewValues.ParentId != null
                && accNewValues.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME))
                && ((   accOldValues == null 
                        && accNewValues.Customer_Success_Manager__c != null)
                    ||( accOldValues != null
                        && accNewValues.Customer_Success_Manager__c != accOldValues.Customer_Success_Manager__c)));
    }
}