/**
 * Description:
 * LatestVunnenOpportunities Test class. 
 * 
 * Modifications:
 * 26.06.2023 [Tomass Brazovskis] LTAT-10218 - Modified. <>_filterOnRegion() test methods added.
 * 24.03.2023 [Tomass Brazovskis] SALEF-8266 - Modified. retrieveLstOfLatestClosedOppsFiber_testExcludeAccounts() added.
 *              Helper methods introduced to ensure Opportunities are being either retrieved or excluded. 
 * 02.12.2022 [Tomass Brazovskis] SALEF-7566 - Modified. getlistoftopclosedopportunitycygate() modified to retrieve and process
 *              "Like" related information.
 * 17.05.2018 [Shruti Singh] SALEF-1114 - Introduced. 
 **/
@isTest
private class Test_LatestClosedOpportunities {

    public static String SME_SALES = 'SME Sales';  

    public static testmethod void testLatestClosedOpportunities() {
        User salesManager;
        Id pricebookId;


        System.runAs(new User(Id = Userinfo.getUserId())) {
            salesManager = Test_DataFactory.createLargeUser();

            salesManager.Bypass_VR__c = true;

            insert salesManager;
        }
        System.runAs(salesManager) {

            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
            insert acc;
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            insert prod;
            pricebookId = Test.getStandardPricebookId();
            Opportunity opp = Test_DataFactory.createOwnedOpportunities(1, salesManager)[0];
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.Agreement_Signed__c = true;
            opp.Large_Continuation_Sales__c = 2;
            opp.CloseDate = System.today();
            insert opp;
            /* Contact c = Test_DataFactory.createOneContact();
        c.AccountId = acc.Id;
        insert c;*/
            Test.startTest();
            /* OpportunityContactRole ocr = Test_DataFactory.createOpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
        ocr.OpportunityId = opp.Id;
        insert ocr;*/

            PricebookEntry pbe = Test_DataFactory.createPricebookEntry(pricebookId, prod);
            insert pbe;

            PricebookEntry pbe2 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
            insert pbe2;

            OpportunityLineItem oppLi = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe2.Id);
            insert oppLi;

            opp.Main_Product_Area__c = 'Other';
            opp.Number_of_Likes__c = 1;
            opp.Like_Details__c = userinfo.getuserId();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            update opp;

            Test.stopTest();
            LatestClosedOpportunities.getlistoflatestclosedopportunity();
            String s = LatestClosedOpportunities.numberofLikesonOpty(opp.id);
            List<User> ulist = LatestClosedOpportunities.getLikedOppUser(Opp.id);
        }

    }

    /**
     * Description:
     * Ensure correct most valuable Won Cygate-type Opportunities are retrieved
     * based on the value of the User-selected option to filter by region.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Introduced.
     **/
    @isTest
    public static void testGetListOfTopClosedOppsCygate_filterOnRegion(){
        User byPassUser = Test_DataFactory.getByPassUser();
        User opportunityOwnerToFilterBy;
        String USER_ROLE_NAME_CYGATE_NORTH = 'CG_S_ljare_Norr';   

        List<User> lstOpportunityOwners = new List<User>(); 
        List<Opportunity> lstCygateOpportunities = new List<Opportunity>();
        List<UserRole> lstUserRoleToSet = getUserRole(USER_ROLE_NAME_CYGATE_NORTH);

        System.assert(!lstUserRoleToSet.isEmpty(),
            'User Role \'' + USER_ROLE_NAME_CYGATE_NORTH + '\' no longer exists.'
            + ' Please, update the test class with an existing UserRole');

        System.runAs(byPassUser) {
            // Populate lists passed as parameters
            helperSetupTestRetrieveOppsCygate(lstOpportunityOwners, lstCygateOpportunities, byPassUser.TimeZoneSidKey);
            // User Cygate_Sales_Team is a Formula field with return
            // value determined by the User Role
            lstOpportunityOwners[0].UserRoleId = lstUserRoleToSet[0].Id;
            update lstOpportunityOwners[0];
            opportunityOwnerToFilterBy = [  SELECT Id, Cygate_User_Team__c
                                            FROM User
                                            WHERE Id = :lstOpportunityOwners[0].Id];
            // Assign different Opportunity Owners
            lstCygateOpportunities[0].OwnerId = lstOpportunityOwners[0].Id;
            lstCygateOpportunities[1].OwnerId = lstOpportunityOwners[1].Id;
            // Populate Opportunities for them to be retrieved by a query
            // not filtered by User Cygate Sales Team
            for(Opportunity curOpp : lstCygateOpportunities){
                curOpp.StageName = SEConstants.OPPORTUNITY_STAGE_VUNNEN;
                curOpp.CloseDate = Date.today();
            }
            insert lstCygateOpportunities;
        }
        System.runAs(opportunityOwnerToFilterBy){
            Test.startTest();
            Integer numOfTestCygateOpps = lstCygateOpportunities.size();
            // Retrieve a Cygate Opportunity list filtered by the context User's Cygate_Sales_Team
            List<Opportunity> lstOppsFilteredByRegion = LatestClosedOpportunities.getlistoftopclosedopportunitycygate(true);
            System.assertEquals(
                [SELECT COUNT() FROM Opportunity WHERE Cygate_Sales_Team__c = :opportunityOwnerToFilterBy.Cygate_User_Team__c],
                lstOppsFilteredByRegion.size(),
                'Incorrect number of Opportunities returned when filtered by Cygate_User_Team.');
            // Retrieve a Cygate Opportunity list not filtered by the context User's Cygate_Sales_Team
            List<Opportunity> lstOppsNonFiltered = LatestClosedOpportunities.getlistoftopclosedopportunitycygate(false);
            System.assertEquals(numOfTestCygateOpps, lstOppsNonFiltered.size(),
                'Incorrect number of Opportunities returned when filters are not being applied.');
            Test.stopTest();
        }
    }

    /**
     * Description:
     * Ensure correct most valuable open Cygate-type Opportunities are retrieved
     * based on the value of the User-selected option to filter by region.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Introduced.
     **/
    @isTest
    public static void testGetListOfPipelinedOppsCygate_filterOnRegion(){
        User byPassUser = Test_DataFactory.getByPassUser();
        User opportunityOwnerToFilterBy;
        String USER_ROLE_NAME_CYGATE_NORTH = 'CG_S_ljare_Norr';

        List<User> lstOpportunityOwners = new List<User>(); 
        List<Opportunity> lstCygateOpportunities = new List<Opportunity>();
        List<UserRole> lstUserRoleToSet = getUserRole(USER_ROLE_NAME_CYGATE_NORTH);

        System.assert(!lstUserRoleToSet.isEmpty(),
            'User Role \'' + USER_ROLE_NAME_CYGATE_NORTH + '\' no longer exists.'
            + ' Please, update the test class with an existing User Role');

        System.runAs(byPassUser) {
            // Populate lists passed as parameters
            helperSetupTestRetrieveOppsCygate(lstOpportunityOwners, lstCygateOpportunities, byPassUser.TimeZoneSidKey);
            // User Cygate_Sales_Team is a Formula field with return
            // value determined by the User Role
            lstOpportunityOwners[0].UserRoleId = lstUserRoleToSet[0].Id;
            update lstOpportunityOwners[0];
            opportunityOwnerToFilterBy = [  SELECT Id, Cygate_User_Team__c
                                            FROM User
                                            WHERE Id = :lstOpportunityOwners[0].Id];
            // Assign different Opportunity Owners
            lstCygateOpportunities[0].OwnerId = lstOpportunityOwners[0].Id;
            lstCygateOpportunities[1].OwnerId = lstOpportunityOwners[1].Id;
            // Populate Opportunities for them to be retrieved by a query
            // not filtered by User Cygate Sales Team
            for(Opportunity curOpp : lstCygateOpportunities){
                curOpp.StageName = SEConstants.OPPORTUNITY_STAGE_KVALIFICERA;
                curOpp.CloseDate = Date.today();
            }
            insert lstCygateOpportunities;
        }
        System.runAs(opportunityOwnerToFilterBy){
            Test.startTest();
            Integer numOfTestCygateOpps = lstCygateOpportunities.size();
            // Retrieve a Cygate Opportunity list filtered by the context User's Cygate_Sales_Team
            List<Opportunity> lstOppsFilteredByRegion = LatestClosedOpportunities.getlistofpipelinedopportunitycygate(true);
            System.assertEquals(
                [SELECT COUNT() FROM Opportunity WHERE Cygate_Sales_Team__c = :opportunityOwnerToFilterBy.Cygate_User_Team__c],
                lstOppsFilteredByRegion.size(),
                'Incorrect number of Opportunities returned when filtered by Cygate_User_Team.');
            // Retrieve a Cygate Opportunity list not filtered by the context User's Cygate_Sales_Team
            List<Opportunity> lstOppsNonFiltered = LatestClosedOpportunities.getlistofpipelinedopportunitycygate(false);
            System.assertEquals(numOfTestCygateOpps, lstOppsNonFiltered.size(),
                'Incorrect number of Opportunities returned when filters are not being applied.');
            Test.stopTest();
        }
    }

    /**
     * Description:
     * Ensure correct most recently won Cygate-type Opportunities are retrieved
     * based on the value of the User-selected option to filter by region.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Introduced.
     **/
    @isTest
    public static void testGetListOfLatestClosedOppsCygate_filterOnRegion(){
        User byPassUser = Test_DataFactory.getByPassUser();
        User opportunityOwnerToFilterBy;
        String USER_ROLE_NAME_CYGATE_NORTH = 'CG_S_ljare_Norr';
        
        List<User> lstOpportunityOwners = new List<User>(); 
        List<Opportunity> lstCygateOpportunities = new List<Opportunity>();
        List<UserRole> lstUserRoleToSet = getUserRole(USER_ROLE_NAME_CYGATE_NORTH);

        System.assert(!lstUserRoleToSet.isEmpty(),
            'User Role \'' + USER_ROLE_NAME_CYGATE_NORTH + '\' no longer exists.'
            + ' Please, update the test class with an existing UserRole');

        System.runAs(byPassUser) {
            // Populate lists passed as parameters
            helperSetupTestRetrieveOppsCygate(lstOpportunityOwners, lstCygateOpportunities, byPassUser.TimeZoneSidKey);
            // User Cygate_Sales_Team is a Formula field with return
            // value determined by the User Role
            lstOpportunityOwners[0].UserRoleId = lstUserRoleToSet[0].Id;
            update lstOpportunityOwners[0];
            opportunityOwnerToFilterBy = [  SELECT Id, Cygate_User_Team__c
                                            FROM User
                                            WHERE Id = :lstOpportunityOwners[0].Id];
            // Assign different Opportunity Owners
            lstCygateOpportunities[0].OwnerId = lstOpportunityOwners[0].Id;
            lstCygateOpportunities[1].OwnerId = lstOpportunityOwners[1].Id;
            // Populate Opportunities for them to be retrieved by a query
            // not filtered by User Cygate Sales Team
            for(Opportunity curOpp : lstCygateOpportunities){
                curOpp.StageName = SEConstants.OPPORTUNITY_STAGE_VUNNEN;
                curOpp.CloseDate = Date.today();
                curOpp.Vunnen_Time_Stamp__c = Datetime.now();
            }
            insert lstCygateOpportunities;
        }
        System.runAs(opportunityOwnerToFilterBy){
            Test.startTest();
            Integer numOfTestCygateOpps = lstCygateOpportunities.size();
            // Retrieve a Cygate Opportunity list filtered by the context User's Cygate_Sales_Team
            List<Opportunity> lstOppsFilteredByRegion = LatestClosedOpportunities.getlistoflatestclosedopportunitycygate(true);
            System.assertEquals(
                [SELECT COUNT() FROM Opportunity WHERE Cygate_Sales_Team__c = :opportunityOwnerToFilterBy.Cygate_User_Team__c],
                lstOppsFilteredByRegion.size(),
                'Incorrect number of Opportunities returned when filtered by Cygate_User_Team.');
            // Retrieve a Cygate Opportunity list not filtered by the context User's Cygate_Sales_Team
            List<Opportunity> lstOppsNonFiltered = LatestClosedOpportunities.getlistoflatestclosedopportunitycygate(false);
            System.assertEquals(numOfTestCygateOpps, lstOppsNonFiltered.size(),
                'Incorrect number of Opportunities returned when filters are not being applied.');
            Test.stopTest();
        }
    }

    /**
     * @Description:  
     * Helper returning UserRole of the passed DeveloperName
     * NOTE: Performs SOQL query in each invocation 
     * @param userRoleDeveloperName - DeveloperName of the UserRole to retrieve
     * @return List - either empty or containing a UserRole with the passed Developer Name
     * @Modifications:
     * 21.06.2023 [TB] LTAT-10218 - Introduced.
     **/
    private static List<UserRole> getUserRole(String userRoleDeveloperName){
        return [SELECT Id, DeveloperName 
                FROM UserRole
                WHERE DeveloperName = :userRoleDeveloperName];
    }

    /**
     * @Description:  
     * Helper used to set up tests for Latest Closed Opportunities retrieval.
     * Populates the lists passed as parameters with
     * - 2 System Admin Users (with IDs) to be assigned as the Cygate Opportunity Owners
     * - 2 'Cygate_Standard_Opportunity' Opportunities (w/o IDs) related to the same parent KKNr Account
     * @param lstOpportunityOwners - Empty list to store System Admin Users
     * @param lstCygateOpportunities - Empty list to store 'Cygate_Standard_Opportunity' Opportunities
     * @param ownerTimeZoneSidKey - TimeZoneSidKey to Ensure Users have the same time zone
     * @Modifications:
     * 21.06.2023 [TB] LTAT-10218 - Introduced. - Introduced.
     **/
    public static void helperSetupTestRetrieveOppsCygate(   List<User> lstOpportunityOwners, 
                                                            List<Opportunity> lstCygateOpportunities,
                                                            String ownerTimeZoneSidKey 
    ){
        for(Integer idx = 0; idx < 2; idx++){
            User curUser = Test_DataFactory.createAdminUser();
            curUser.TimeZoneSidKey = ownerTimeZoneSidKey;
            lstOpportunityOwners.add(curUser);
        }
        insert lstOpportunityOwners;
        Account oneKundkontoAccount = Test_DataFactory.createOneKundkontoAccount();
        insert oneKundkontoAccount;
        oneKundkontoAccount.Kundkonto_Nr__c = 'Z101';
        Update oneKundkontoAccount;
        for(Integer idx = 0; idx < 2; idx++){
            Opportunity curCygateTestOpportunity = Test_DataFactory.createCygateOpportunity();
            curCygateTestOpportunity.AccountId = oneKundkontoAccount.Id;
            lstCygateOpportunities.add(curCygateTestOpportunity);
        }
    }

    public static testmethod void test_getlistoflatestclosedSMESOHOopp() {
        System.runAs(Test_DataFactory.getByPassUser()) {

            Test.startTest();
            Account acc = Test_DataFactory.createOneAccount ();
            insert acc;

            Opportunity opp = Test_DataFactory.createSmeOpportunity();
            opp.accountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            insert opp;
            User salesManager;
            salesManager = Test_DataFactory.createSMEUser();
            salesManager.Bypass_VR__c = true;
            insert salesManager;
            Seller__c bam = Test_DataFactory.createBusinessAreaManagerSeller(salesManager.id);
            bam.Sales_Team_Name__c = 'SME Sales';
            insert bam;
            opp.ownerid = salesManager.id;
            opp.Seller__c = bam.id;
            update opp;
            Test.stopTest();
            LatestClosedOpportunities.getlistoflatestclosedSMESOHOopportunity();
            LatestClosedOpportunities.getlistoftop10latestclosedSMESOHOopportunity();
        }
    }
    
    @isTest
    public static void getClosedSmeSohoTelesalesOpportunityRank_TestRetrieved() {
        User contextUser;
        User oppOwner;
        Opportunity telesalesOpp;
        String teleSalesOppName = 'TelesalesOpportunity1';
        List<Opportunity> lstRetrievedOpps;
        User bypassUser = Test_DataFactory.getByPassUser();
        System.runAs(bypassUser) {
            List<Opportunity> lstOpportunities = new List<Opportunity>();
            telesalesOpp = Test_DataFactory.createSmeOpportunity();
            telesalesOpp.Name = teleSalesOppName;
            setUpRetrievableOpportunity(telesalesOpp, 'Telesales_RankBySalesOutcome');
            lstOpportunities.add(telesalesOpp);
            List<User> lstUsers = new List<User>();
            oppOwner = Test_DataFactory.createSMEUser();
            oppOwner.Bypass_VR__c = true;
            setOpportunityOwnerProfile(oppOwner, 'Telesales_RankBySalesOutcome');
            lstUsers.add(oppOwner);
            contextUser = Test_DataFactory.createSMEUser();
            contextUser.Bypass_VR__c = true;
            contextUser.TimeZoneSidKey = bypassUser.TimeZoneSidKey;
            contextUser.LocaleSidKey = bypassUser.LocaleSidKey;
            setTargetUserProfile(contextUser, 'Telesales_RankBySalesOutcome');
            lstUsers.add(contextUser);
            insert lstUsers;
            setOpportunitySalesTeam(lstOpportunities, 'Telesales_RankBySalesOutcome', oppOwner);
            insert lstOpportunities;
            Test.startTest();
            System.runAs(contextUser){
                lstRetrievedOpps = LatestClosedOpportunities.getlistoflatestclosedSMESOHOopportunity();
            }
            Test.stopTest();
            System.assert(lstRetrievedOpps.isEmpty(), 'Context User failed to retrieve Opportunity');
        }
    }

    /**
     * Description:
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Modified. Ensure all test Opps are being retrieved.
     **/
    @isTest
    public static void test_ListOfLatestClosedOpportunityFiber() {

        User user1 = Test_DataFactory.createFiberUser();

        insert user1;

        System.runAs(Test_DataFactory.getByPassUser()){

            List<Opportunity> allOpportunities = new List<Opportunity>();
            Opportunity opp1 = Test_DataFactory.createFiberOpportunity();
            opp1.Name = 'Test Opp 1'; opp1.Number_of_Likes__c = 0 ; opp1.Like_Details__c = null ; opp1.Vunnen_Time_Stamp__c = Datetime.newInstance(2023,1,1,0,0,0) ; opp1.OwnerId = user1.Id;
            allOpportunities.add(opp1);
            Opportunity opp2 = Test_DataFactory.createFiberOpportunity();
            opp2.Name = 'Test Opp 2'; opp2.Number_of_Likes__c = 1 ; opp2.Like_Details__c = UserInfo.getUserId(); opp2.Vunnen_Time_Stamp__c = Datetime.newInstance(2022,1,1,0,0,0)  ; opp2.OwnerId = user1.Id;
            allOpportunities.add(opp2);
            Opportunity opp3 = Test_DataFactory.createFiberOpportunity();
            opp3.Name = 'Test Opp 3' ; opp3.Number_of_Likes__c = 1 ; opp3.Like_Details__c = user1.Id ; opp3.Vunnen_Time_Stamp__c = Datetime.newInstance(2021,1,1,0,0,0) ; opp3.OwnerId = user1.Id;
            allOpportunities.add(opp3);
            Opportunity opp4 = Test_DataFactory.createFiberOpportunity();
            opp4.Name = 'Test Opp 4' ; opp4.Number_of_Likes__c = null ; opp4.Like_Details__c = user1.Id ; opp4.Vunnen_Time_Stamp__c = Datetime.newInstance(2020,1,1,0,0,0) ; opp4.OwnerId = user1.Id;
            allOpportunities.add(opp4);
            Opportunity opp5 = Test_DataFactory.createFiberOpportunity();
            opp5.Name = 'Test Opp 5'; opp5.Number_of_Likes__c = 0 ; opp5.Like_Details__c = ''; opp5.Vunnen_Time_Stamp__c = Datetime.newInstance(2019,1,1,0,0,0) ; opp5.OwnerId = user1.Id;
            allOpportunities.add(opp5);

            setOpportunityParentAccountToInclude(allOpportunities, 'Fiber'); //SALEF-8266

            insert allOpportunities;

            Test.startTest();

            List<Opportunity> oppList = LatestClosedOpportunities.getListOfLatestClosedOpportunityFiber();

            Test.stopTest();

            System.assertEquals(5, oppList.size(),'No all opportunities was founded');
            System.assertEquals(false, oppList[0].Like_Status__c, '"opp1" like status is true');
            System.assertEquals(true, oppList[1].Like_Status__c, '"opp2" like status is false');
            System.assertEquals(false, oppList[2].Like_Status__c, '"opp3" like status is true');
            System.assertEquals(false, oppList[3].Like_Status__c, '"opp4" like status is true');
            System.assertEquals(false, oppList[4].Like_Status__c,'"opp5" like status is true');
        }
    }

    /**
     * Description:
     * Ensure Fiber Opps related to Accounts to be excluded in 
     * Latest_Closed_Opportunities_Settings mdt are not being retrieved.
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Introduced.
     **/
    @isTest
    public static void retrieveLstOfLatestClosedOppsFiber_testExcludeAccounts(){
        Integer numOfOppsToCreate = 3;
        Integer numOfOppsToExclude = 2;
        System.assert(numOfOppsToCreate >= numOfOppsToExclude, 'Cannot exclude more Opportunities than created');
        Integer numOfOppsToReturn = numOfOppsToCreate - numOfOppsToExclude;

        User fiberProfileUser = Test_DataFactory.createFiberUser();
        insert fiberProfileUser;

        List<Opportunity> lstAllOpportunities = new List<Opportunity>();
        List<Opportunity> lstOppsToExclude = new List<Opportunity>();
        List<Opportunity> lstOppsToRetrieve = new List<Opportunity>();

        System.runAs(Test_DataFactory.getByPassUser()){
            for(Integer idx = 0; idx < numOfOppsToCreate; idx++){
                Opportunity curOpportunity = Test_DataFactory.createFiberOpportunity();
                curOpportunity.Name = 'TestOpp_' + String.valueOf(idx);
                curOpportunity.Number_of_Likes__c = 1 ; 
                curOpportunity.Like_Details__c = fiberProfileUser.Id; 
                curOpportunity.Vunnen_Time_Stamp__c = Datetime.now().addDays(-1);
                curOpportunity.OwnerId = fiberProfileUser.Id;
                curOpportunity.CloseDate = Date.today();
                lstAllOpportunities.add(curOpportunity);
                if(idx < numOfOppsToExclude){
                    lstOppsToExclude.add(curOpportunity);
                } else{
                    lstOppsToRetrieve.add(curOpportunity);
                }
            }

            setOpportunityParentAccountToExclude(lstOppsToExclude, 'Fiber');
            setOpportunityParentAccountToInclude(lstOppsToRetrieve, 'Fiber');
            insert lstAllOpportunities;
        }

        List<Opportunity> lstRetrievedOps = new List<Opportunity>();
        Test.startTest();
        lstRetrievedOps = LatestClosedOpportunities.getListOfLatestClosedOpportunityFiber();
        Test.stopTest();

        System.assertEquals(numOfOppsToReturn, lstRetrievedOps.size(),
            'Wrong number of "Fiber" Opportunities retrieved.'
            + ' Expected: ' + String.valueOf(numOfOppsToReturn)
            + ' Actual: ' +  String.valueOf(lstRetrievedOps.size()));
    }

    /**
     * Description:
     * Helper method setting Opportunity field values ensuring that
     * the Opportunities are retrieved when 'settingName' is applied.
     * @param oppToSetUp - List of Opps to have their field values set
     * @param settingName - Latest_Closed_Opportunities_Setting Name
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Introduced.
     **/
    public static void setUpRetrievableOpportunity(Opportunity oppToSetUp, String settingName){
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsSettingApplied = Latest_Closed_Opportunities_Setting__mdt.getInstance(settingName);
        if(latestClosedOppsSettingApplied != null){
            oppToSetUp.Vunnen_Time_Stamp__c = Datetime.now();
            oppToSetUp.CloseDate = Date.today();
            setOpportunityParentAccountToInclude(new List<Opportunity>{oppToSetUp}, settingName);
            setOpportunityRecordType(new List<Opportunity>{oppToSetUp}, settingName);
        }
    }

    /**
     * Description:
     * Helper method setting Opportunity parent Account to a record ensuring that
     * the Opportunities are either retrieved or excluded from the returned list.
     * @param lstOpportunities - List of Opps to have their AccountIds set
     * @param settingName - Latest_Closed_Opportunities_Setting Name
     * @param excludeOpps - Boolean determining whether the Opps in the passed list should be excluded
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Introduced.
     **/
    public static void setOpportunityParentAccount(List<Opportunity> lstOpportunities, String settingName, Boolean excludeOpps){
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsSetting = Latest_Closed_Opportunities_Setting__mdt.getInstance(settingName);
        if(latestClosedOppsSetting == null){
            latestClosedOppsSetting = Latest_Closed_Opportunities_Setting__mdt.getInstance('DEFAULT');
        }
        Account parentAccount = Test_DataFactory.createOneAccount();
        List<String> lstAccountNamesToExclude = latestClosedOppsSetting.Accounts_to_Exclude__c != null 
            ? latestClosedOppsSetting.Accounts_to_Exclude__c.split(',')
            : new List<String>();

        if(!lstAccountNamesToExclude.isEmpty()){
            parentAccount.Name = lstAccountNamesToExclude[0].trim();
            // Ensure parent Account Name is different from Account Names to be excluded
            if(!excludeOpps){
                parentAccount.Name = parentAccount.Name + String.valueOf(Datetime.now());
            }
        }
        insert parentAccount;
        for(Opportunity curOpportunity : lstOpportunities){
            curOpportunity.AccountId = parentAccount.Id;
        }
    }

    /**
     * Description:
     * Helper method setting Opportunity RecordTypeId to a value ensuring that
     * the Opportunities are retrieved.
     * @param lstOpportunities - List of Opps to have their RecordTypeIds set
     * @param settingName - Latest_Closed_Opportunities_Setting Name
     * Modifications:
     * 24.03.2023 [TB] SALEF-8396 - Introduced.
     **/
    public static void setOpportunityRecordType(List<Opportunity> lstOpportunities, String settingName){
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsSettingApplied = Latest_Closed_Opportunities_Setting__mdt.getInstance(settingName);
        if(latestClosedOppsSettingApplied == null){
            return;
        }
        List<String> lstOpportunityRecTypeDevNames = LatestClosedOpportunities.helperCommaSeparatedValuesToList(latestClosedOppsSettingApplied.Opportunity_Record_Types__c);
        if(!lstOpportunityRecTypeDevNames.isEmpty()){
            Map<String, Schema.RecordTypeInfo> mapRTDevNamesToRTInfos = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            Id oppRecordTypeId;
            try{
                oppRecordTypeId = mapRTDevNamesToRTInfos.get(lstOpportunityRecTypeDevNames[0]).getRecordTypeId();
            } catch(Exception curException){
                System.assert(false, 'No Opportunity RT with Developer Name \'' + lstOpportunityRecTypeDevNames[0] + '\'.');
            }
            for(Opportunity curOpportunity : lstOpportunities){
                curOpportunity.RecordTypeId = oppRecordTypeId;
            }
        }
    }

    /**
     * Description:
     * Helper method setting Opportunity Seller to a Seller record
     * ensuring that the Opportunities are retrieved. Also, sets the Seller as the Owner
     * @param lstOpportunities - List of Opps to have their Sellers and Owners set
     * @param settingName - Latest_Closed_Opportunities_Setting Name
     * @param salesTeamUser - User to associate with the Seller
     * Modifications:
     * 24.03.2023 [TB] SALEF-8396 - Introduced.
     **/
    public static void setOpportunitySalesTeam(List<Opportunity> lstOpportunities, String settingName, User salesTeamUser){
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsSettingApplied = Latest_Closed_Opportunities_Setting__mdt.getInstance(settingName);
        if(latestClosedOppsSettingApplied == null){
            return;
        }
        if(String.isNotEmpty(latestClosedOppsSettingApplied.Seller_Sales_Team_Name__c)){
            Seller__c curSeller = Test_DataFactory.createBusinessAreaManagerSeller(salesTeamUser.Id);
            // might have to be changed for different Settings
            curSeller.Sales_Team_Name__c = SME_SALES;  
            insert curSeller;
            for(Opportunity curOpportunity : lstOpportunities){
                curOpportunity.Seller__c = curSeller.Id;
                curOpportunity.OwnerId = salesTeamUser.Id;
            }
        }
    }

    /**
     * Description:
     * Helper method setting User ProfileId ensuring that, if the User is set
     * as an Opportunity Owner, the record is retrieved.
     * @param oppOwnerUser - User to have its Profile set (but not updated)
     * @param settingName - Latest_Closed_Opportunities_Setting Name
     * Modifications:
     * 24.03.2023 [TB] SALEF-8396 - Introduced.
     **/
    public static void setOpportunityOwnerProfile(User oppOwnerUser, String settingName){
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsSettingApplied = Latest_Closed_Opportunities_Setting__mdt.getInstance(settingName);
        if(latestClosedOppsSettingApplied == null){
            return;
        }
        List<String> lstOpportunityOwnerProfileNames = LatestClosedOpportunities.helperCommaSeparatedValuesToList(latestClosedOppsSettingApplied.Opportunity_Owner_Profiles__c);
        if(!lstOpportunityOwnerProfileNames.isEmpty()){
            List<Profile> lstUserProfiles = [SELECT Id FROM Profile WHERE Name = :lstOpportunityOwnerProfileNames[0]];
            System.assert(!lstUserProfiles.isEmpty(), 'No Profile with Name \'' + lstOpportunityOwnerProfileNames[0] + '\'.');
            oppOwnerUser.ProfileId = lstUserProfiles[0].Id;
        }
    }

    /**
     * Description:
     * Helper method setting User ProfileId ensuring that, if the User is retrieving
     * the Opportunities, 'settingName' Latest_Closed_Opportunities_Setting criteria
     * will be applied.
     * @param contextUser - User to have its Profile set (but not updated)
     * @param settingName - Latest_Closed_Opportunities_Setting Name
     * Modifications:
     * 24.03.2023 [TB] SALEF-8396 - Introduced.
     **/
    public static void setTargetUserProfile(User contextUser, String settingName){
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsSettingApplied = Latest_Closed_Opportunities_Setting__mdt.getInstance(settingName);
        if(latestClosedOppsSettingApplied == null){
            return;
        }
        List<String> lstTargetProfileNames = LatestClosedOpportunities.helperCommaSeparatedValuesToList(latestClosedOppsSettingApplied.Target_Profiles__c);
        if(!lstTargetProfileNames.isEmpty()){
            List<Profile> lstUserProfiles = [SELECT Id FROM Profile WHERE Name = :lstTargetProfileNames[0]];
            System.assert(!lstUserProfiles.isEmpty(), 'No Profile with Name \'' + lstTargetProfileNames[0] + '\'.');
            contextUser.ProfileId = lstUserProfiles[0].Id;
        }
    }

    /**
     * Description:
     * Helper method setting Opportunity parent Account to a record ensuring that
     * the Opportunities are excluded from the returned list.
     * @param lstOpportunities - List of Opps to have their AccountIds set
     * @param settingName - Latest_Closed_Opportunities_Setting Name
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Introduced.
     **/
    public static void setOpportunityParentAccountToExclude(List<Opportunity> lstOpportunities, String settingName){
        setOpportunityParentAccount(lstOpportunities, settingName, true);
    }

    /**
     * Description:
     * Helper method setting Opportunity parent Account to a record ensuring that
     * the Opportunities are NOT being excluded due to their parent Account.
     * @param lstOpportunities - List of Opps to have their AccountIds set
     * @param settingName - Latest_Closed_Opportunities_Setting Name
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Introduced.
     **/
    public static void setOpportunityParentAccountToInclude(List<Opportunity> lstOpportunities, String settingName){
        setOpportunityParentAccount(lstOpportunities, settingName, false);
    }

    /**
     * Description:
     * Ensure the helperRegExSeparatedValuesToList() converts Strings of values
     * divided by a separator into Lists containing corresponding elements.  
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Introduced.
     **/
    @isTest
    public static void helperRegExSeparatedValuesToList_test(){
        String SEPARATOR_STR = ';';
        Map<String, List<String>> mapInputStringToExpectedValue = new Map<String, List<String>>();
        mapInputStringToExpectedValue.put(null, new List<String>());
        mapInputStringToExpectedValue.put('', new List<String>());
        List<String> lstExpectedStrings = new List<String>{'testStr0','testStr1','testStr2'};
        String inputStringForList = '';
        for(Integer idx = 0; idx < lstExpectedStrings.size(); idx++){
            if(idx == 0){
                inputStringForList += (lstExpectedStrings[idx] + '  ');
            } else if(idx == 1){
                inputStringForList += (SEPARATOR_STR + '  ' + lstExpectedStrings[idx] + '  ');
            } else if(idx == 2){
                inputStringForList += (SEPARATOR_STR + '  ' + lstExpectedStrings[idx]);
            } else{
                inputStringForList += (SEPARATOR_STR + lstExpectedStrings[idx]);
            }
        }
        mapInputStringToExpectedValue.put(inputStringForList, lstExpectedStrings);

        Test.startTest();
        for(String inputString : mapInputStringToExpectedValue.keySet()){
            List<String> lstActualResults = LatestClosedOpportunities.helperRegExSeparatedValuesToList(inputString, SEPARATOR_STR);
            List<String> lstExpectedResults = mapInputStringToExpectedValue.get(inputString);
            System.assertEquals(lstExpectedResults.size(), lstActualResults.size(),
                'Failed to convert a String into a List containing the expected number of elements.');
            if(!lstActualResults.isEmpty()){
                for(Integer idx = 0; idx < lstActualResults.size(); idx++){
                    System.assertEquals(lstExpectedResults[idx], lstActualResults[idx],
                        'An element of a List obtained by splitting a String does not have the expected value.');
                }
            }
        }
        Test.stopTest();
    }

}