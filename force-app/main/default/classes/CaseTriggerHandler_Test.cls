/**
 * Description:
 * CaseTriggerHandler test class.
 * 
 * Modifications:
 * 03.11.2023 [Tomass Brazovskis] LTAT-11634 - Introduced. Replaces the original Test_CaseTriggerHandler class.
 **/
@isTest
public with sharing class CaseTriggerHandler_Test {

    public static final String NAME_TEST_ACCOUNT = 'largeTestAccount';
    public static final String NAME_TEST_CUSTOMER_ACCOUNT = 'customerTestAccount';
    public static final String NAME_TEST_OPPORTUNITY = 'largeTestOpportunity';
    public static final String USERNAME_BYPASS_USER = 'bypassUser' + Datetime.now().format('yyyyMMdd') + '@telia.com';

    /**
     * @Description:
     * Set up a Bypass User, Test Accounts and Opportunity.
     * Modifications:
     * 03.11.2023 [TB] LTAT-11634 - Introduced.
     **/
    @TestSetup
    static void makeData(){
        //Test_DataFactory.setUpOrg();
        User userBypass = Test_DataFactory.getByPassUser();
        userBypass.Username = USERNAME_BYPASS_USER;
        userBypass.CommunityNickname = 'bypassUser' + Datetime.now().format('yyyyMMdd');
        update userBypass;
        System.runAs(userBypass){
            List<User> lstLargeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            Account customerAccount = Test_DataFactory.createOneKundkontoAccount();
            customerAccount.Name = NAME_TEST_CUSTOMER_ACCOUNT;
            insert customerAccount;
            Account largeAccount = Test_DataFactory.createOneLargeStandardAccount();
            largeAccount.Name = NAME_TEST_ACCOUNT;
            largeAccount.Telia_Service_Manager__c = lstLargeUserTeam[0].Id;
            largeAccount.ParentId = customerAccount.Id;
            insert largeAccount;

            Opportunity largeOpportunity = Test_DataFactory.createLargeOpportunity();
            largeOpportunity.AccountId = largeAccount.Id;
            largeOpportunity.Name = NAME_TEST_OPPORTUNITY;
            insert largeOpportunity;
        }
    }
    
    /**
     * @Description:
     * Test setAccountFromSubject()
     * Modifications:
     * 03.11.2023 [TB] LTAT-11634 - Introduced.
     **/
    @isTest
    public static void testSetAccountFromSubject(){
        List<User> lstBypassUsers = [SELECT Id FROM User WHERE Username = :USERNAME_BYPASS_USER]; 
        System.runAs(lstBypassUsers[0]){
            List<Account> lstTestAccounts = [SELECT Id FROM Account WHERE Name = :NAME_TEST_ACCOUNT LIMIT 1];
            lstTestAccounts[0].Org_Nr__c = '1234567890';
            update lstTestAccounts;
            List<Case> lstTestCases = new List<Case>();
            List<String> lstCaseSubjectsWithMatchingOrgNrs = new List<String>{
                'this should 1234567890 work',
                '123456-7890',
                '123456-7890 this should also work',
                'this should also work 123456-7890'
            };
            for(String subjectWithAMatchingOrgNr : lstCaseSubjectsWithMatchingOrgNrs){
                lstTestCases.add(new Case(
                    RecordTypeId = SEUtility.getRecordTypeId(SEConstantsCase.CASE_RECTYPE_ENTERPRISE),
                    Subject = subjectWithAMatchingOrgNr));
            }
            Test.startTest();
            insert lstTestCases;
            Test.stopTest();

            Map<Id, Case> mapCaseIdsToCases = new Map<Id,Case>([SELECT Id, AccountId FROM Case]);
            for(Case curTestCase : lstTestCases){
                System.assertEquals(lstTestAccounts[0].Id, mapCaseIdsToCases.get(curTestCase.Id).AccountId,
                    'Case Account should have been set, as the Case Subject contained the Account Org Number.');
            }
        }
    }

    /**
     * @Description:
     * Test createManualCaseSharingForCaseCreator()
     * Modifications:
     * 03.11.2023 [TB] LTAT-11634 - Introduced.
     **/
    @isTest
    public static void testManualCaseSharing_ParentRecordOwners(){
        List<User> lstBypassUsers = [SELECT Id FROM User WHERE Username = :USERNAME_BYPASS_USER]; 
        System.runAs(lstBypassUsers[0]){
            List<Account> lstTestAccounts = [SELECT Id FROM Account WHERE Name = :NAME_TEST_ACCOUNT LIMIT 1];
            List<Opportunity> lstTestOpportunity = [SELECT Id FROM Opportunity WHERE Name = :NAME_TEST_OPPORTUNITY LIMIT 1];
            List<User> lstLargeUserTeam = new List<User>();
            for(Integer idx = 0; idx < 6; idx++){
                User curUser = Test_DataFactory.createLargeUser();
                curUser.Username += ('cth' + String.valueOf(idx));
                curUser.Telia_Id__c += ('cth' + String.valueOf(idx));
                lstLargeUserTeam.add(curUser);
            }
            insert lstLargeUserTeam;
            lstTestAccounts[0].OwnerId = lstLargeUserTeam[0].Id;
            lstTestAccounts[0].Telia_Service_Manager__c = lstLargeUserTeam[1].Id;
            lstTestOpportunity[0].OwnerId = lstLargeUserTeam[2].Id;
            update lstTestAccounts;
            update lstTestOpportunity;
            List<Case> lstTestCases = new List<Case>();
            Map<Id, Set<Id>> mapCaseIdsToSetIdsUsersWithAccess = new Map<Id, Set<Id>>();
            for(Integer idx = 0; idx < 2; idx++){
                lstTestCases.add(new Case(
                    RecordTypeId = SEUtility.getRecordTypeId(SEConstantsCase.CASE_RECTYPE_ENTERPRISE),
                    AccountId = lstTestAccounts[0].Id,
                    Opportunity__c = lstTestOpportunity[0].Id));
            }

            Test.startTest();
            insert lstTestCases;
            List<Case> lstTestCasesPostInsertion = [SELECT Id, OwnerId, CreatedById, Opportunity__c, AccountId,
                                                            Opportunity__r.OwnerId,
                                                            Account.OwnerId, Account.Telia_Service_Manager__c,
                                                            (   SELECT Id, UserOrGroupId, CaseID
                                                                FROM Shares
                                                                WHERE RowCause = 'Manual'
                                                                AND CaseAccessLevel = 'Read')
                                                    FROM Case
                                                    WHERE Id IN :lstTestCases];
            for(Case curCase : lstTestCasesPostInsertion){
                Set<Id> setIdsUsersWithAccess = new Set<Id>();
                for(CaseShare curCaseShare : curCase.Shares){
                    setIdsUsersWithAccess.add(curCaseShare.UserOrGroupId);
                }
                mapCaseIdsToSetIdsUsersWithAccess.put(curCase.Id, setIdsUsersWithAccess);
                System.assert(  setIdsUsersWithAccess.contains(curCase.Account.OwnerId),
                                'Case is not being shared with its parent Account Owner upon insertion.');
                System.assert(  setIdsUsersWithAccess.contains(curCase.Account.Telia_Service_Manager__c),
                                'Case is not being shared with its parent Account \'Telia Service Manager\' upon insertion.');
                System.assert(  setIdsUsersWithAccess.contains(curCase.Opportunity__r.OwnerId),
                                'Case is not being shared with its parent Opportunity Owner upon insertion.');          
            }

            // Create new Account and Opportunity to set as parents for one of the Cases
            Account newCaseParentAccount = Test_DataFactory.createOneLargeStandardAccount();
            newCaseParentAccount.Name = NAME_TEST_ACCOUNT + 'v2';
            newCaseParentAccount.OwnerId = lstLargeUserTeam[3].Id;
            newCaseParentAccount.Telia_Service_Manager__c = lstLargeUserTeam[4].Id;
            insert newCaseParentAccount;

            Opportunity newCaseParentOpportunity = Test_DataFactory.createLargeOpportunity();
            newCaseParentOpportunity.AccountId = newCaseParentAccount.Id;
            newCaseParentOpportunity.Name = NAME_TEST_OPPORTUNITY + 'v2';
            newCaseParentOpportunity.OwnerId = lstLargeUserTeam[5].Id;
            insert newCaseParentOpportunity;

            // Keep track of Users that should no longer have access to a Case after the update
            Map<Id, Set<Id>> mapCaseIdsToSetIdsUsersWithoutAccess = new Map<Id, Set<Id>>();
            // Previous Case parent record Owners should have their access revoked 
            Set<Id> setIdsUsersWithAccessToRevoke = new Set<Id>();
            setIdsUsersWithAccessToRevoke.add(lstTestCasesPostInsertion[0].Account.OwnerId);
            setIdsUsersWithAccessToRevoke.add(lstTestCasesPostInsertion[0].Account.Telia_Service_Manager__c);
            setIdsUsersWithAccessToRevoke.add(lstTestCasesPostInsertion[0].Opportunity__r.OwnerId);
            mapCaseIdsToSetIdsUsersWithoutAccess.put(lstTestCasesPostInsertion[0].Id, setIdsUsersWithAccessToRevoke);

            lstTestCasesPostInsertion[0].AccountId = newCaseParentAccount.Id;
            lstTestCasesPostInsertion[0].Opportunity__c = newCaseParentOpportunity.Id;

            // Ensure the other Case involved in update is not incorrectly
            // shared with the former's new parent Record Owners
            mapCaseIdsToSetIdsUsersWithoutAccess.put(lstTestCasesPostInsertion[1].Id, new Set<Id>{
                newCaseParentAccount.OwnerId,
                newCaseParentAccount.Telia_Service_Manager__c,
                newCaseParentOpportunity.OwnerId
            });
            update lstTestCasesPostInsertion;

            // Verify Case Sharing After Update
            for(Case curCaseAfterUpdate : [ SELECT Id, OwnerId, CreatedById, Opportunity__c, AccountId,
                                                    Opportunity__r.OwnerId,
                                                    Account.OwnerId, Account.Telia_Service_Manager__c,
                                                    (   SELECT Id, UserOrGroupId, CaseID
                                                        FROM Shares
                                                        WHERE RowCause = 'Manual'
                                                        AND CaseAccessLevel = 'Read')
                                            FROM Case
                                            WHERE Id IN :lstTestCases
            ]){
                Set<Id> setIdsUsersWithAccess = new Set<Id>();
                for(CaseShare curCaseShare : curCaseAfterUpdate.Shares){
                    setIdsUsersWithAccess.add(curCaseShare.UserOrGroupId);
                }
                System.assert(  setIdsUsersWithAccess.contains(curCaseAfterUpdate.Account.OwnerId),
                    'Case is not being shared with its parent Account Owner upon update.');
                System.assert(  setIdsUsersWithAccess.contains(curCaseAfterUpdate.Account.Telia_Service_Manager__c),
                    'Case is not being shared with its parent Account \'Telia Service Manager\' upon update.');
                System.assert(  setIdsUsersWithAccess.contains(curCaseAfterUpdate.Opportunity__r.OwnerId),
                    'Case is not being shared with its parent Opportunity Owner upon update.');
                // Ensure access has been correctly revoked or has not been assigned mistakenly
                for(Id curIdUserWithoutAccess : mapCaseIdsToSetIdsUsersWithoutAccess.get(curCaseAfterUpdate.Id)){
                    System.assert(  !setIdsUsersWithAccess.contains(curIdUserWithoutAccess),
                        'Case incorrectly shared with a User.');
                }
            }
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Test createManualOpportunitySharingForCaseCreator()
     * Modifications:
     * 03.11.2023 [TB] LTAT-11634 - Introduced.
     **/
    @isTest
    public static void testManualOpportunitySharing_RelatedCaseOwners(){
        List<User> lstBypassUsers = [SELECT Id FROM User WHERE Username = :USERNAME_BYPASS_USER]; 
        System.runAs(lstBypassUsers[0]){
            List<Opportunity> lstTestOpportunity = [SELECT Id FROM Opportunity WHERE Name = :NAME_TEST_OPPORTUNITY LIMIT 1];
            List<User> lstLargeUserTeam = new List<User>();
            // Ensure Opportunity and Cases have different Owners
            for(Integer idx = 0; idx < 2; idx++){
                User curUser = Test_DataFactory.createLargeUser();
                curUser.Username += ('cth' + String.valueOf(idx));
                curUser.Telia_Id__c += ('cth' + String.valueOf(idx));
                lstLargeUserTeam.add(curUser);
            }
            insert lstLargeUserTeam;
            // Create Cases related to the test Opportunity
            List<Case> lstTestCases = new List<Case>();
            for(Integer idx = 0; idx < 2; idx++){
                lstTestCases.add(new Case(
                    RecordTypeId = SEUtility.getRecordTypeId(SEConstantsCase.CASE_RECTYPE_ENTERPRISE),
                    Opportunity__c = lstTestOpportunity[0].Id,
                    OwnerId = lstLargeUserTeam[0].Id));
            }
            Test.startTest();
            insert lstTestCases;
            // Ensure Case Owner has been granted 'Edit' access to the Case parent Opportunity.
            List<OpportunityShare> lstOpportunitySharePostCaseInsert = [SELECT Id
                                                                        FROM OpportunityShare
                                                                        WHERE OpportunityId = :lstTestOpportunity[0].Id
                                                                        AND UserOrGroupId = :lstLargeUserTeam[0].Id
                                                                        AND OpportunityAccessLevel = 'Edit'];
            System.assert(  !lstOpportunitySharePostCaseInsert.isEmpty(),
                            'Case Owner is not being granted \'Edit\' access to the Case parent Opportunity.');
            // Change Owner of the Opportunity related Cases
            for(Case curCase : lstTestCases){
                curCase.OwnerId = lstLargeUserTeam[1].Id;
            }
            update lstTestCases;

            // Ensure a User's 'Edit' access to the Opportunity has been revoked when the User is no longer 
            // an Owner of an Opportunity related Case. 
            List<OpportunityShare> lstOpportunitySharePostCaseOwnerChange = [   SELECT Id
                                                                                FROM OpportunityShare
                                                                                WHERE OpportunityId = :lstTestOpportunity[0].Id
                                                                                AND UserOrGroupId = :lstLargeUserTeam[0].Id
                                                                                AND OpportunityAccessLevel = 'Edit'];
            System.assert(  lstOpportunitySharePostCaseOwnerChange.isEmpty(),
                            'User \'Edit\' access to Opportunity was not revoked upon the User being removed as'
                            + ' the Opportunity related Case Owner.');
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Test setNamedSalesCoordinatorFromKKNR()
     * Modifications:
     * 03.11.2023 [TB] LTAT-11634 - Introduced.
     **/
    @isTest
    public static void testSetNamedSalesCoordinatorFromKKNR(){
        List<User> lstBypassUsers = [SELECT Id FROM User WHERE Username = :USERNAME_BYPASS_USER]; 
        System.runAs(lstBypassUsers[0]){
            List<Account> lstCustomerAccounts = [   SELECT Id, (SELECT Id FROM ChildAccounts)
                                                    FROM Account WHERE Name = :NAME_TEST_CUSTOMER_ACCOUNT LIMIT 1];
            List<User> lstUsersSalesCoordinator = new List<User>();
            for(Integer idx = 0; idx < 1; idx++){
                User curUser = Test_DataFactory.createLargeUser();
                curUser.Username += ('cth' + String.valueOf(idx));
                curUser.Telia_Id__c += ('cth' + String.valueOf(idx));
                lstUsersSalesCoordinator.add(curUser);
            }
            insert lstUsersSalesCoordinator;
            List<Account> lstTestCustomerAccounts = [   SELECT Id, (SELECT Id FROM ChildAccounts)
                                                        FROM Account WHERE Name = :NAME_TEST_CUSTOMER_ACCOUNT LIMIT 1];
            // Create a Cases related to the customer Account's child Account
            List<Case> lstTestCases = new List<Case>();
            for(Integer idx = 0; idx < 2; idx++){
                lstTestCases.add(new Case(
                    RecordTypeId = SEUtility.getRecordTypeId(SEConstantsCase.CASE_RECTYPE_ENTERPRISE),
                    Accountid = lstCustomerAccounts[0].ChildAccounts[0].Id));
            }
            Test.startTest();
            insert lstTestCases;
            // Remove test Case parent Account
            lstTestCases[0].AccountId = null;
            update lstTestCases;
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Test setFieldsInSubCase()
     * Modifications:
     * 03.11.2023 [TB] LTAT-11634 - Introduced.
     **/
    @isTest
    public static void testSetFieldsInSubCase(){
        List<User> lstBypassUsers = [SELECT Id FROM User WHERE Username = :USERNAME_BYPASS_USER]; 
        System.runAs(lstBypassUsers[0]){
            String SUBJECT_PARENT_CASE = 'parent case';
            String SUBJECT_SUB_CASE = 'Test sub case';
            // Establish mappings among dependent picklist values
            List<String> lstNamesOfCaseGroupsToTest = new List<String>{
                SEConstantsCase.CASE_GROUP_PRESALE_DATACOM,
                SEConstantsCase.CASE_GROUP_PRESALE_VOICE
            };
            Map<String,String> mapCaseGroupsToCategories = new Map<String,String>{
                SEConstantsCase.CASE_GROUP_PRESALE_DATACOM => SEConstantsCase.CASE_CATEGORY_KAP,
                SEConstantsCase.CASE_GROUP_PRESALE_VOICE => SEConstantsCase.CASE_CATEGORY_OCC
            };
            Map<String,String> mapCaseGroupsToProductAreas = new Map<String,String>{
                SEConstantsCase.CASE_GROUP_PRESALE_DATACOM => SEConstantsCase.CASE_PRODUCT_AREA_DATAKOM,
                SEConstantsCase.CASE_GROUP_PRESALE_VOICE => SEConstantsCase.CASE_PRODUCT_AREA_MFN
            };

            // Set up Parent Cases
            List<Case> lstParentCases = new List<Case>();
            for(String curCaseGroup : lstNamesOfCaseGroupsToTest){
                lstParentCases.add(new Case(
                    RecordTypeId = SEUtility.getRecordTypeId(SEConstantsCase.CASE_RECTYPE_ENTERPRISE),
                    Subject = SUBJECT_PARENT_CASE,
                    Origin = SEConstantsCase.CASE_ORIGIN_SALESFORCE,
                    Case_Group__c = curCaseGroup,
                    Category__c = mapCaseGroupsToCategories.get(curCaseGroup),
                    Product_Area__c = mapCaseGroupsToProductAreas.get(curCaseGroup),
                    Status = SEConstantsCase.CASE_STATUS_NEW
                ));
            }
            insert lstParentCases;

            // Set Parent Case related Enterprise_Subcase Cases
            List<Case> lstSubCases = new List<Case>();
            for(Case curParentCase : lstParentCases){
                lstSubCases.add(new Case(
                    RecordTypeId = SEUtility.getrecordtypeid(SEConstantsCase.CASE_RECTYPE_ENTERPRISE_SUBCASE),
                    ParentId = curParentCase.Id,
                    Status = SEConstantsCase.CASE_STATUS_NEW,
                    Subject = SUBJECT_SUB_CASE
                ));
            }
            // Ensure Enterprise_Subcase Case inherits the required set of fields from its parent upon creation.
            Test.startTest();
            insert lstSubCases;
            for(Case curParentCase : [  SELECT Id, Case_Group__c, Category__c, Product_Area__c,
                                            (   SELECT Id, Case_Group__c, Category__c, Product_Area__c
                                                FROM Cases)
                                        FROM Case
                                        WHERE Id IN :lstParentCases
            ]){
                for(Case curSubcase : curParentCase.Cases){
                    System.assertEquals( curParentCase.Case_Group__c, curSubcase.Case_Group__c,
                        'An Enterprise_Subcase should have inherited its Parent Case Case_Group__c upon insertion.');
                    System.assertEquals( curParentCase.Category__c, curSubcase.Category__c,
                        'An Enterprise_Subcase should have inherited its Parent Case Category__c upon insertion.');
                    System.assertEquals( curParentCase.Product_Area__c, curSubcase.Product_Area__c,
                        'An Enterprise_Subcase should have inherited its Parent Product_Area__c upon insertion.');
                }
            }
            Test.stopTest();
        }
    }
}