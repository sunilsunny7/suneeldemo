/**
About
-----
Description: Test Class to test Opportunity custom functionality
Create date: April 2015

Update History
--------------
Created April 2015 - T.R.
Updated May 2015 - V.I New validation rules on opportunity that needs to pass: contact role, products and agreement signed.
Updated Aug 2015 - V.I Added tests for repointing of Opportunity when close date is changed
Updated Aug 2015 - C.G Added Sales_Unit__c,Sales_Team__c and Seller record creation for every time users are created. 
Updated Sep 2015 - V.I Added yearly targets for managers in each test method
Updated Jun 2015 - A.N In test nr03, reduced the number of opp created in test class from 100 to 20 due to long execution time
Updated Aug 2016 - A.N Fixed test nr04. The getSingleOpportunitiesWithSingleOli method is not optimal wrt to # of SOQL's, so replaced this to reduce SOQL's.
Updated Aug 2016 - A.N Old test nr07, nr08 and nr10 have been deleted. These basically tested the exact same thing as test no04. Test classes have been renumbered.
02.11.2022 [Tomass Brazovskis] AM 22.18 Release - Introduced updateUserToBypassValidationRules() method and applied to Test Users to allow them to
            bypass OpportunityValidationHandler validation rules, thus, reducing the # of SOQL queries.

Issues / TODOs
--------------  
*/

@isTest
public with sharing class Test_CalculateOutcome {

    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }

    // One SalesRep - One closed opportunity
     static testMethod void nr01_testSelfForecastingCalculationSalesRepOpportunityClosed() {
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = smeUserTeam[2].Id;
            insert acc;
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        updateUserToBypassValidationRules(salesRep);

        System.runAs(salesRep) {
            Contact con = Test_DataFactory.createOneContact();
            con.AccountId = acc.Id;
            insert con;
            
            OpportunityContactRole cr = Test_DataFactory.createOpportunityContactRole();
            cr.ContactId = con.Id;
            cr.Role = 'Avtalstecknare';

            Test.startTest();
            Opportunity opp = getSingleOpportunitiesWithSingleOli(1, acc.Id)[0];
            //system.debug(opp);
            cr.OpportunityId = opp.Id;
            insert cr;
            opp.Agreement_Signed__c = true;
            opp.Main_Product_Area__c = 'Services';
            
            //Act
            
            opp.StageName = 'Vunnen';
            update opp;
            Test.stopTest();
        }
        
        //Assert
        Opportunity insertedOpp = [SELECT Id, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c FROM Opportunity]; 
        System.assertNotEquals(insertedOpp.Large_Continuation_Sales__c, null, 'The opportunity continuation sales amount is null.');
        System.assertNotEquals(insertedOpp.Large_New_Sales__c, null, 'The opportunity new sales amount is null.');

        String weekNumber = SEUtility.getWeekNumberAsString(Date.today());
        String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(Date.today()));
        String yearNumber = String.valueOf(insertedOpp.CloseDate.year());
        
        Weekly_Forecast_Item__c wfi = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber AND User__c =: salesRep.Id];
        Quarterly_Forecast_Item__c qfi = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber AND User__c =: salesRep.Id];    
        Yearly_Target__c yfi = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Yearly_Target__c WHERE Name =: yearNumber AND User__c =: salesRep.Id];
        
        System.assertEquals(insertedOpp.Large_Continuation_Sales__c, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome.');
        System.assertEquals(insertedOpp.Large_New_Sales__c, wfi.Accumulated_New_Sales_Outcome_X__c, 'Incorrect value on the weekly new sales outcome.');
        System.assertEquals(insertedOpp.Large_Continuation_Sales__c, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome.');
        System.assertEquals(insertedOpp.Large_New_Sales__c, qfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the quarterly new sales outcome.');
        System.assertEquals(insertedOpp.Large_Continuation_Sales__c, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome.');
        System.assertEquals(insertedOpp.Large_New_Sales__c, yfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the yearly new sales outcome.');
    }
    
    // One BAM, One Manager and one Sales Rep.
    static testMethod void nr02_testManagersForecastingCalculationSalesRepOpportunityClosed() {
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = smeUserTeam[2].Id;
            insert acc;
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        updateUserToBypassValidationRules(salesRep);

        System.runAs(salesRep) {
            Contact con = Test_DataFactory.createOneContact();
            con.AccountId = acc.Id;
            insert con;
            
            OpportunityContactRole cr = Test_DataFactory.createOpportunityContactRole();
            cr.ContactId = con.Id;
            cr.Role = 'Avtalstecknare';
            
            Test.startTest();
            Opportunity opp = getSingleOpportunitiesWithSingleOli(1, acc.Id)[0];
            cr.OpportunityId = opp.Id;
            insert cr;
            opp.Agreement_Signed__c = true;  
            opp.Main_Product_Area__c = 'Services';
            
            //Act
            //Test.startTest();
            opp.StageName = 'Vunnen';
            update opp;
            //Test.stopTest();
        }
        
        //Assert
        //Opportunity insertedOpp = [SELECT Id, CloseDate, Retain_Revenue_12_month__c, Winback_Revenue_12_month__c FROM Opportunity];
        /*Opportunity insertedOpp = [SELECT Id, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c FROM Opportunity];
        System.assertNotEquals(insertedOpp.Large_Continuation_Sales__c, null, 'The opportunity continuation sales amount is null.');
        System.assertNotEquals(insertedOpp.Large_New_Sales__c, null, 'The opportunity new sales amount is null.');
        
        String weekNumber = SEUtility.getWeekNumberAsString(Date.today());
        String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(Date.today()));
        String yearNumber = String.valueOf(insertedOpp.CloseDate.year());
        
        //List<Weekly_Forecast_Item__c> wfis = [SELECT Id, Continuation_Sales_Outcome__c, New_Sales_Outcome__c, User__r.Name,Superior_User__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber];
        List<Weekly_Forecast_Item__c> wfis = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c, User__r.Name,Superior_User__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber];
        //List<Quarterly_Forecast_Item__c> qfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales__c, Accumulated_Outcome_New_Sales__c, User__r.Name FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber];
        List<Quarterly_Forecast_Item__c> qfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c, User__r.Name FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber];
        //List<Yearly_Target__c> yfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales__c, Accumulated_Outcome_New_Sales__c,User__c,User__r.Name FROM Yearly_Target__c WHERE Name =: yearNumber];
        List<Yearly_Target__c> yfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c,User__c,User__r.Name FROM Yearly_Target__c WHERE Name =: yearNumber];
        System.assertEquals(3, wfis.size(), 'There should be 3 wfis, one for each user.');
        System.assertEquals(3, qfis.size(), 'There should be 3 qfis, one for each user.');
        System.assertEquals(3, yfis.size(), 'There should be 3 yfis, one for each user.');

        for (Quarterly_Forecast_Item__c qfi : qfis) {
            //System.debug('@@ qfi.Accumulated_Outcome_Continuation_Sales_X__c: ' + qfi.Accumulated_Outcome_Continuation_Sales_X__c);
            //System.debug('@@ qfi.Accumulated_Outcome_New_Sales_X__c: ' + qfi.Accumulated_Outcome_New_Sales_X__c);
            System.assertEquals(insertedOpp.Large_Continuation_Sales__c, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome.');
            System.assertEquals(insertedOpp.Large_New_Sales__c, qfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the quarterly new sales outcome.');
        }
        
        for (Yearly_Target__c yfi : yfis) {
            //System.debug('@@ yfi.Accumulated_Outcome_Continuation_Sales_X__c: ' + yfi.Accumulated_Outcome_Continuation_Sales_X__c);
            //System.debug('@@ yfi.Accumulated_Outcome_New_Sales_X__c: ' + yfi.Accumulated_Outcome_New_Sales_X__c);
            System.assertEquals(insertedOpp.Large_Continuation_Sales__c, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome.');
            System.assertEquals(insertedOpp.Large_New_Sales__c, yfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the yearly new sales outcome.');
        }
         */
        Test.stopTest();
    }

    // This test method has got extra debugging around SOQL queries is good to determine which DMLs use a lot of SOQLs
    // Comment AN June 2016: Reduced the number of opps from 100 to 20, as Salesforce gives a "Long Running Test" warning for this test method.
    /*static testMethod void nr03_testManagersForecastingCalculationSalesRepOpportunityClosedBulk() {
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = smeUserTeam[2].Id;
            insert acc;
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];

       
        System.runAs(salesRep) {
            
            //List<Opportunity> opps = getSingleOpportunitiesWithSingleOli(100);
            //List<Opportunity> opps = getSingleOpportunitiesWithSingleOli(20, acc.Id);reduced for 101 queries
            List<Opportunity> opps = getSingleOpportunitiesWithSingleOli(10, acc.Id);
            Contact con = Test_DataFactory.createOneContact();
            con.AccountId = acc.Id;
            insert con; 
            //System.debug(LoggingLevel.ERROR, '@@ Single contact inserted. SOQLs: ' + Limits.getQueries());
            //Test.startTest(); commented on 22nd aug 2018
 
            //List<OpportunityContactRole> crs = Test_DataFactory.createOpportunityContactRoles(100);
            //List<OpportunityContactRole> crs = Test_DataFactory.createOpportunityContactRoles(20);
            Test.startTest();
            List<OpportunityContactRole> crs = Test_DataFactory.createOpportunityContactRoles(5);
            for (Integer i = 0; i < crs.size(); i++) {
                crs[i].ContactId = con.Id;
                crs[i].OpportunityId = opps[i].Id;
                crs[i].Role = 'Avtalstecknare';
            }
            insert crs;
            Test.stopTest();

            //System.debug(LoggingLevel.ERROR, '@@ Contact roles inserted. SOQLs: ' + Limits.getQueries());
             //Test.stopTest();commented on 22nd aug 2018

            for (Opportunity opp: opps) {
                opp.Agreement_Signed__c = true;
                opp.Main_Product_Area__c = 'Services';
                opp.StageName = 'Vunnen';
            }
            update opps;
           
            //System.debug(LoggingLevel.ERROR, '@@ Opportunities updated. SOQLs: ' + Limits.getQueries());
        }
        
        
        AggregateResult opportunitySums = [SELECT SUM(Large_Continuation_Sales__c) retainSum, SUM(Large_New_Sales__c) winbackSum FROM Opportunity]; 
        Decimal retainSum = (Decimal) opportunitySums.get('retainSum');
        Decimal winbackSum = (Decimal) opportunitySums.get('winbackSum');
        //System.debug('@@ retainSum: ' + retainSum);
        //System.debug('@@ winbackSum: ' + winbackSum);

        String weekNumber = SEUtility.getWeekNumberAsString(Date.today());
        String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(Date.today()));
        String yearNumber = String.valueOf(Date.today().year());
        
        List<Weekly_Forecast_Item__c> wfis = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c 
                                              FROM Weekly_Forecast_Item__c 
                                              WHERE Name =: weekNumber AND User__c IN: smeUserTeam];
        List<Quarterly_Forecast_Item__c> qfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c 
                                                 FROM Quarterly_Forecast_Item__c 
                                                 WHERE Name =: quarterNumber AND User__c IN: smeUserTeam];
        List<Yearly_Target__c> yfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c 
                                       FROM Yearly_Target__c 
                                       WHERE Name =: yearNumber AND User__c IN: smeUserTeam];
        System.assertEquals(3, wfis.size(), 'There should be 3 wfis, one for each user.');
        System.assertEquals(3, qfis.size(), 'There should be 3 qfis, one for each user.');
        System.assertEquals(3, yfis.size(), 'There should be 3 yfis, one for each user.');
        
        //System.debug('@@ wfis: ' + wfis);
        //System.debug('@@ qfis: ' + qfis);
        //System.debug('@@ yfis: ' + yfis);
        
        for (Weekly_Forecast_Item__c wfi : wfis) {
            System.assertEquals(retainSum, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome.');
            System.assertEquals(winbackSum, wfi.Accumulated_New_Sales_Outcome_X__c, 'Incorrect value on the weekly new sales outcome.');
        }
        
        for (Quarterly_Forecast_Item__c qfi : qfis) {
            System.assertEquals(retainSum, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome.');
            System.assertEquals(winbackSum, qfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the quarterly new sales outcome.');
        }
        
        for (Yearly_Target__c yfi : yfis) {
            System.assertEquals(retainSum, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome.');
            System.assertEquals(winbackSum, yfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the yearly new sales outcome.');
        }
    }
*/
    static testMethod void nr04_testManagersForecastingCalculationSalesRepAndManagerOpportunityClosed() {
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
           
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = smeUserTeam[2].Id;
            insert acc;
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        updateUserToBypassValidationRules(salesRep);

        Contact con;
        List<Opportunity> opps = new List<Opportunity>();
 
        // Create test account and contact
        System.runAs(smeUserTeam[2]) {
            con = Test_DataFactory.createOneContact();
            con.AccountId = acc.Id;
            insert con;
        }
   
        // Create opp for sales rep user
        System.runAs(smeUserTeam[2]) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            insert opp;
            opps.add(opp);
        }
         Test.startTest();
        // Create opp for sales mgr user
        System.runAs(smeUserTeam[1]) {                       
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            insert opp;
            opps.add(opp);
        }

        

        // add opp contact roles, line items and close opps
        System.runAs(new User(Id = Userinfo.getUserId())){
            addOlisToOpportunities(opps);
           
            List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
            for(Opportunity opp : opps){
                OpportunityContactRole ocr = Test_DataFactory.createOpportunityContactRole();
                ocr.ContactId = con.Id;
                ocr.Role = 'Avtalstecknare';
                ocr.OpportunityId = opp.Id;
                ocrs.add(ocr);                

                opp.Agreement_Signed__c = true;
                opp.Main_Product_Area__c = 'Services';
                opp.StageName = 'Vunnen';                
            }
            insert ocrs;
            update opps;
        }

        

        //Assert
        AggregateResult opportunitySums = [SELECT SUM(Large_Continuation_Sales__c) retainSum, SUM(Large_New_Sales__c) winbackSum FROM Opportunity]; 
        Decimal retainSum = (Decimal) opportunitySums.get('retainSum');
        Decimal winbackSum = (Decimal) opportunitySums.get('winbackSum');
        //System.debug('@@ retainSum: ' + retainSum);
        //System.debug('@@ winbackSum: ' + winbackSum);
        Test.stopTest();
        String weekNumber = SEUtility.getWeekNumberAsString(Date.today());
        String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(Date.today()));
        String yearNumber = String.valueOf(Date.today().year());
        //System.debug('Number of SOQLs used so far in test nr 4 '+Limits.getQueries());
        List<Weekly_Forecast_Item__c> wfis = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c 
                                              FROM Weekly_Forecast_Item__c 
                                              WHERE Name =: weekNumber AND (User__c =: salesManager.Id OR User__c =: smeManager.Id)];
        List<Quarterly_Forecast_Item__c> qfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c 
                                                 FROM Quarterly_Forecast_Item__c 
                                                 WHERE Name =: quarterNumber AND (User__c =: salesManager.Id OR User__c =: smeManager.Id)];
        List<Yearly_Target__c> yfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c 
                                       FROM Yearly_Target__c 
                                       WHERE Name =: yearNumber AND (User__c =: salesManager.Id OR User__c =: smeManager.Id)];
        //Test.stopTest();
        System.assertEquals(2, wfis.size(), 'There should be 2 wfis, one for each manager.');
        System.assertEquals(2, qfis.size(), 'There should be 2 qfis, one for each manager.');
        System.assertEquals(2, yfis.size(), 'There should be 2 yfis, one for each manager.');
        
        //System.debug('@@ wfis: ' + wfis);
        //System.debug('@@ qfis: ' + qfis);
        //System.debug('@@ yfis: ' + yfis);
        
        for (Weekly_Forecast_Item__c wfi : wfis) {
            System.assertEquals(retainSum, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome.');
            System.assertEquals(winbackSum, wfi.Accumulated_New_Sales_Outcome_X__c, 'Incorrect value on the weekly new sales outcome.');
        }
        
        for (Quarterly_Forecast_Item__c qfi : qfis) {
            System.assertEquals(retainSum, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome.');
            System.assertEquals(winbackSum, qfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the quarterly new sales outcome.');
        }
        
        for (Yearly_Target__c yfi : yfis) {
            System.assertEquals(retainSum, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome.');
            System.assertEquals(winbackSum, yfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the yearly new sales outcome.');
        } 
    }
    
    static testMethod void nr05_testManagersForecastingCalculationSalesRepOpportunityDeleted() {
        //System.debug('Running testManagersForecastingCalculationSalesRepOpportunityDeleted()');
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        Account acc;
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = smeUserTeam[2].Id;
            insert acc;
            System.debug('2.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        updateUserToBypassValidationRules(salesRep);

        System.runAs(salesRep) {
            
            Contact con = Test_DataFactory.createOneContact();
            con.AccountId = acc.Id;
            Test.startTest();
            insert con;
            System.debug('3.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            List<OpportunityContactRole> contactRoles = Test_DataFactory.createOpportunityContactRoles(2);
            //System.debug('SOQLs so far 1: '+Limits.getQueries());
            List<Opportunity> opps = getSingleOpportunitiesWithSingleOli(2, acc.Id); // 1 run of WFI trigger X3 - DELETE THIS COMMENT
            
            //Test.startTest();
            for(Integer i =  0; i < opps.size(); i++){
                contactRoles[i].Role = 'Avtalstecknare';
                contactRoles[i].OpportunityId = opps[i].Id;
                contactRoles[i].ContactId = con.Id;
                opps[i].Agreement_Signed__c = true;
                opps[i].Main_Product_Area__c = 'Cloud Networking';
                //opps[i].StageName = 'Vunnen';
            }
            insert contactRoles;
            System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            update opps; 
            //Test.stopTest();
            //Delete one opportunity
            System.debug('5.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            delete opps[1]; 
            System.debug('6.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            Test.stopTest();
          
            
        }
        /*
        //Assert
        List<Opportunity> insertedOpps = [SELECT Id, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c FROM Opportunity]; 
        System.assertEquals(1, insertedOpps.size(), 'Incorrect number of opportunities.');
        Opportunity insertedOpp = insertedOpps[0];
        
        String weekNumber = SEUtility.getWeekNumberAsString(Date.today());
        String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(Date.today()));
        String yearNumber = String.valueOf(insertedOpp.CloseDate.year());
        
        List<Weekly_Forecast_Item__c> wfis = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c,User__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber];
        List<Quarterly_Forecast_Item__c> qfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber];
        List<Yearly_Target__c> yfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Yearly_Target__c WHERE Name =: yearNumber];
        System.assertEquals(3, wfis.size(), 'There should be 3 wfis, one for each user.');
        System.assertEquals(3, qfis.size(), 'There should be 3 qfis, one for each user.');
        System.assertEquals(3, yfis.size(), 'There should be 3 yfis, one for each user.');
        
        //System.debug('@@ insertedOpp.Large_Continuation_Sales__c: ' + insertedOpp.Large_Continuation_Sales__c);
        //System.debug('@@ insertedOpp.Large_New_Sales__c: ' + insertedOpp.Large_New_Sales__c);
        //Test.stopTest();

        
        for (Weekly_Forecast_Item__c wfi : wfis) {
            
            //System.debug('@@ wfi.Accumulated_Continuation_Sales_Outcome_X__c: ' + wfi.Accumulated_Continuation_Sales_Outcome_X__c);
            //System.debug('@@ wfi.Accumulated_New_Sales_Outcome_X__c: ' + wfi.Accumulated_New_Sales_Outcome_X__c);
            System.assertEquals(insertedOpp.Large_Continuation_Sales__c, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome.');
            System.assertEquals(insertedOpp.Large_New_Sales__c, wfi.Accumulated_New_Sales_Outcome_X__c, 'Incorrect value on the weekly new sales outcome.');
           
        }
        
        for (Quarterly_Forecast_Item__c qfi : qfis) {
            //System.debug('@@ qfi.Accumulated_Outcome_Continuation_Sales_X__c: ' + qfi.Accumulated_Outcome_Continuation_Sales_X__c);
            //System.debug('@@ qfi.Accumulated_Outcome_New_Sales_X__c: ' + qfi.Accumulated_Outcome_New_Sales_X__c);
            System.assertEquals(insertedOpp.Large_Continuation_Sales__c, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome.');
            System.assertEquals(insertedOpp.Large_New_Sales__c, qfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the quarterly new sales outcome.');
        }
        
        for (Yearly_Target__c yfi : yfis) {
            //System.debug('@@ yfi.Accumulated_Outcome_Continuation_Sales_X__c: ' + yfi.Accumulated_Outcome_Continuation_Sales_X__c);
            //System.debug('@@ yfi.Accumulated_Outcome_New_Sales_X__c: ' + yfi.Accumulated_Outcome_New_Sales_X__c);
            System.assertEquals(insertedOpp.Large_Continuation_Sales__c, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome.');
            System.assertEquals(insertedOpp.Large_New_Sales__c, yfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the yearly new sales outcome.');
        }
        //Test.stopTest();*/
    }
    
    static testMethod void nr06_testManagersForecastingCalculationSalesRepOpportunityUndeleted() {
        //System.debug('Running testManagersForecastingCalculationSalesRepOpportunityUndeleted()');
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = smeUserTeam[2].Id;
            insert acc;
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        updateUserToBypassValidationRules(salesRep);

        System.runAs(salesRep) {
            Contact con = Test_DataFactory.createOneContact();
            con.AccountId = acc.Id;
            insert con;
            
            OpportunityContactRole cr = Test_DataFactory.createOpportunityContactRole();
            cr.ContactId = con.Id;
            cr.Role = 'Avtalstecknare';
            Test.startTest();
            Opportunity opp = getSingleOpportunitiesWithSingleOli(1, acc.Id)[0];
            cr.OpportunityId = opp.Id;
            insert cr;

           
            opp.Agreement_Signed__c = true;
            opp.Main_Product_Area__c = 'Services';
            opp.StageName = 'Vunnen';
            update opp;
            Test.stopTest();
            
            delete opp;
            System.assertEquals(0, [SELECT Id FROM Opportunity].size(), 'There should be 0 opportunitites.');
            //Act
            //Undelete one opportunity
            undelete opp;
            //Test.stopTest();
        }
        
        //Assert
        List<Opportunity> insertedOpps = [SELECT Id, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c FROM Opportunity]; 
        System.assertEquals(1, insertedOpps.size(), 'Incorrect number of opportunities.');
        Opportunity insertedOpp = insertedOpps[0];
        
        String weekNumber = SEUtility.getWeekNumberAsString(Date.today());
        String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(Date.today()));
        String yearNumber = String.valueOf(insertedOpp.CloseDate.year());
        //Test.stopTest();
        List<Weekly_Forecast_Item__c> wfis = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber];
        List<Quarterly_Forecast_Item__c> qfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber];
        List<Yearly_Target__c> yfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Yearly_Target__c WHERE Name =: yearNumber];
        System.assertEquals(3, wfis.size(), 'There should be 3 wfis, one for each user.');
        System.assertEquals(3, qfis.size(), 'There should be 3 qfis, one for each user.');
        System.assertEquals(3, yfis.size(), 'There should be 3 yfis, one for each user.');
        
        //System.debug('@@ insertedOpp.Large_Continuation_Sales__c: ' + insertedOpp.Large_Continuation_Sales__c);
        //System.debug('@@ insertedOpp.Large_New_Sales__c: ' + insertedOpp.Large_New_Sales__c);
        
        for (Weekly_Forecast_Item__c wfi : wfis) {
            //System.debug('@@ wfi.Accumulated_Continuation_Sales_Outcome_X__c: ' + wfi.Accumulated_Continuation_Sales_Outcome_X__c);
            //System.debug('@@ wfi.Accumulated_New_Sales_Outcome_X__c: ' + wfi.Accumulated_New_Sales_Outcome_X__c);
            System.assertEquals(insertedOpp.Large_Continuation_Sales__c, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome.');
            System.assertEquals(insertedOpp.Large_New_Sales__c, wfi.Accumulated_New_Sales_Outcome_X__c, 'Incorrect value on the weekly new sales outcome.');
        }
        
        for (Quarterly_Forecast_Item__c qfi : qfis) {
            //System.debug('@@ qfi.Accumulated_Outcome_Continuation_Sales_X__c: ' + qfi.Accumulated_Outcome_Continuation_Sales_X__c);
            //System.debug('@@ qfi.Accumulated_Outcome_New_Sales_X__c: ' + qfi.Accumulated_Outcome_New_Sales_X__c);
            System.assertEquals(insertedOpp.Large_Continuation_Sales__c, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome.');
            System.assertEquals(insertedOpp.Large_New_Sales__c, qfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the quarterly new sales outcome.');
        }
        
        for (Yearly_Target__c yfi : yfis) {
            //System.debug('@@ yfi.Accumulated_Outcome_Continuation_Sales_X__c: ' + yfi.Accumulated_Outcome_Continuation_Sales_X__c);
            //System.debug('@@ yfi.Accumulated_Outcome_New_Sales_X__c: ' + yfi.Accumulated_Outcome_New_Sales_X__c);
            System.assertEquals(insertedOpp.Large_Continuation_Sales__c, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome.');
            System.assertEquals(insertedOpp.Large_New_Sales__c, yfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the yearly new sales outcome.');
        }
        
    }

    static testMethod void nr07_testManagersWeeklyForecaseCommitSingleSalesRep() {
        //System.debug('Running testManagersWeeklyForecaseCommitSingleSalesRep()');
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);
        }       

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        updateUserToBypassValidationRules(salesRep);  
        
        String weekNumber = SEUtility.getWeekNumberAsString(Date.today());
        Weekly_Forecast_Item__c salesRepWfi = [SELECT Id FROM Weekly_Forecast_Item__c WHERE User__c =: salesRep.Id AND Name =: weekNumber][0];
        Integer newSalesCommit = 100;
        Integer continuationSalesCommit = 200;
        
        System.runAs(salesRep) {
            //Act
            Test.startTest();
            salesRepWfi.New_Sales_Commit__c = newSalesCommit;
            salesRepWfi.Continuation_Sales_Commit__c = continuationSalesCommit;
            update salesRepWfi;
            Test.stopTest();
        }
        
        //Assert
        List<Weekly_Forecast_Item__c> wfis = [SELECT Id, Subordinates_Commit_New_Sales__c, Subordinates_Commit_Continuation_Sales__c FROM Weekly_Forecast_Item__c 
                                              WHERE Name =: weekNumber AND User__c =: salesManager.Id];
        System.assertEquals(1, wfis.size(), 'There should be 1 wfis, one for each user.');
        System.assertEquals(newSalesCommit, wfis[0].Subordinates_Commit_New_Sales__c, 'Incorrect value on the weekly continuation sales outcome.');
        System.assertEquals(continuationSalesCommit, wfis[0].Subordinates_Commit_Continuation_Sales__c, 'Incorrect value on the weekly new sales outcome.');
    }
    
    static testMethod void nr08_testRepointOpportunityOnCloseDateChange() {
        //System.debug('Running testRepointOpportunityOnCloseDateChange()');
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        Account acc;
        Contact con;
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam, System.today().addDays(-20));
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = smeUserTeam[2].Id;
            insert acc;

            con = Test_DataFactory.createOneContact();
            con.AccountId = acc.Id;
            
            insert con;
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        updateUserToBypassValidationRules(salesRep);

        System.runAs(salesRep) {
            
            Test.startTest();
            OpportunityContactRole cr = Test_DataFactory.createOpportunityContactRole();
            cr.ContactId = con.Id;
            cr.Role = 'Avtalstecknare';
            
            Opportunity opp = getSingleOpportunitiesWithSingleOli(1, acc.Id)[0];
            cr.OpportunityId = opp.Id;
            insert cr;
            
            opp.Agreement_Signed__c = true;
            opp.Main_Product_Area__c = 'Services';
            opp.StageName = 'Vunnen';
            update opp;
        

            //Act
            //Change close date on opportunity
            Date d = opp.CloseDate;
            opp.CloseDate = d.addDays(-10);
            Test.stopTest();
            //System.debug('@@@ Date d: ' + d + ' Close date: ' + opp.CloseDate);
            update opp;
        }
        //Test.stopTest();

        // The Assertion logic will only pass if the new insertedOpp.closeDate is in the same Telia year as today.
        if(System.today().addDays(-10) > SEUtility.getFirstDayOfTeliaYear(System.today().year())){
            List<Opportunity> insertedOpps = [SELECT Id, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c FROM Opportunity]; 
            Opportunity insertedOpp = insertedOpps[0];
                
            Date d = insertedOpp.CloseDate;
            
            String weekNumber = SEUtility.getWeekNumberAsString(insertedOpp.CloseDate);
            String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(insertedOpp.CloseDate));
            String yearNumber = String.valueOf(insertedOpp.CloseDate.year());
                
            String oldWeekNumber = SEUtility.getWeekNumberAsString(d.addDays(10));          
                
            
            List<Weekly_Forecast_Item__c> wfis = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c, Quarterly_Forecast_Item__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber];
            List<Id> quarterIds = new List<Id>();
            for (Weekly_Forecast_Item__c wfi : wfis) {
                quarterIds.add(wfi.Quarterly_Forecast_Item__c);
            }
            List<Quarterly_Forecast_Item__c> qfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Quarterly_Forecast_Item__c WHERE Id in :quarterIds];
            List<Yearly_Target__c> yfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Yearly_Target__c WHERE Name =: yearNumber];
                     
            List<Weekly_Forecast_Item__c> oldWfis = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c FROM Weekly_Forecast_Item__c WHERE Name =: oldWeekNumber];
           //Test.stopTest();     
            
            //System.debug('@@ insertedOpp.Large_Continuation_Sales__c: ' + insertedOpp.Large_Continuation_Sales__c);
            //System.debug('@@ insertedOpp.Large_New_Sales__c: ' + insertedOpp.Large_New_Sales__c);
            
            for (Weekly_Forecast_Item__c wfi : wfis) {
                //System.debug('@@ wfi.Accumulated_Continuation_Sales_Outcome_X__c: ' + wfi.Accumulated_Continuation_Sales_Outcome_X__c);
                //System.debug('@@ wfi.Accumulated_New_Sales_Outcome_X__c: ' + wfi.Accumulated_New_Sales_Outcome_X__c);
                System.assertEquals(insertedOpp.Large_Continuation_Sales__c, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome.');
                System.assertEquals(insertedOpp.Large_New_Sales__c, wfi.Accumulated_New_Sales_Outcome_X__c, 'Incorrect value on the weekly new sales outcome.');
            }
            
            for (Quarterly_Forecast_Item__c qfi : qfis) {
                //System.debug('@@ qfi.Accumulated_Outcome_Continuation_Sales_X__c: ' + qfi.Accumulated_Outcome_Continuation_Sales_X__c);
                //System.debug('@@ qfi.Accumulated_Outcome_New_Sales_X__c: ' + qfi.Accumulated_Outcome_New_Sales_X__c);
                System.assertEquals(insertedOpp.Large_Continuation_Sales__c, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome.');
                System.assertEquals(insertedOpp.Large_New_Sales__c, qfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the quarterly new sales outcome.');
            }
            
            for (Yearly_Target__c yfi : yfis) {
                //System.debug('@@ yfi.Accumulated_Outcome_Continuation_Sales_X__c: ' + yfi.Accumulated_Outcome_Continuation_Sales_X__c);
                //System.debug('@@ yfi.Accumulated_Outcome_New_Sales_X__c: ' + yfi.Accumulated_Outcome_New_Sales_X__c);
                System.assertEquals(insertedOpp.Large_Continuation_Sales__c, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome.');
                System.assertEquals(insertedOpp.Large_New_Sales__c, yfi.Accumulated_Outcome_New_Sales_X__c, 'Incorrect value on the yearly new sales outcome.');
            }
            
            //OLD WEEK
            for (Weekly_Forecast_Item__c wfi : oldWfis) {
                //System.debug('@@ old wfi.Accumulated_Continuation_Sales_Outcome_X__c: ' + wfi.Accumulated_Continuation_Sales_Outcome_X__c);
                //System.debug('@@ old wfi.Accumulated_New_Sales_Outcome_X__c: ' + wfi.Accumulated_New_Sales_Outcome_X__c);
                System.assertEquals(0, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the old weekly continuation sales outcome.');
                System.assertEquals(0, wfi.Accumulated_New_Sales_Outcome_X__c, 'Incorrect value on the old weekly new sales outcome.');
            }           
        }    
    }
    
    static testMethod void nr09_testRepointOpportunityOnCloseDateChangeSalesManager() {
        //System.debug('Running testRepointOpportunityOnCloseDateChangeSalesManager()');
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam, System.today().addDays(-20));
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = smeUserTeam[1].Id;
            insert acc;
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        updateUserToBypassValidationRules(salesManager);

        System.runAs(salesManager) {
            
            Contact con = Test_DataFactory.createOneContact();
            con.AccountId = acc.Id;
            insert con;
            Test.startTest();
            OpportunityContactRole cr = Test_DataFactory.createOpportunityContactRole();
            cr.ContactId = con.Id;
            cr.Role = 'Avtalstecknare';
            Opportunity opp = getSingleOpportunitiesWithSingleOli(1, acc.Id)[0];
            cr.OpportunityId = opp.Id;
            insert cr;

            

            opp.Agreement_Signed__c = true;
            opp.Main_Product_Area__c = 'Services';
            opp.StageName = 'Vunnen';
            update opp;
            //Change close date on opportunity
             Test.stopTest();    
            Date d = opp.CloseDate;
            opp.CloseDate = d.addDays(-10);
            update opp;

            //Test.stopTest();
        }
        
        //Assert
        List<Opportunity> insertedOpps = [SELECT Id, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c FROM Opportunity]; 
        Opportunity insertedOpp = insertedOpps[0];
            
        Date d = insertedOpp.CloseDate;
        
        String weekNumber = SEUtility.getWeekNumberAsString(insertedOpp.CloseDate);
        String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(insertedOpp.CloseDate));
        String yearNumber = String.valueOf(insertedOpp.CloseDate.year());
            
        String oldWeekNumber = SEUtility.getWeekNumberAsString(d.addDays(10));          
            
        
        List<Weekly_Forecast_Item__c> wfis = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber];
        List<Quarterly_Forecast_Item__c> qfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber];
        List<Yearly_Target__c> yfis = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Yearly_Target__c WHERE Name =: yearNumber];
       
        List<Weekly_Forecast_Item__c> oldWfis = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c FROM Weekly_Forecast_Item__c WHERE Name =: oldWeekNumber];
        //Test.stopTest();
        //OLD WEEK
        for (Weekly_Forecast_Item__c wfi : oldWfis) {
            //System.debug('@@ old wfi.Accumulated_Continuation_Sales_Outcome_X__c: ' + wfi.Accumulated_Continuation_Sales_Outcome_X__c);
            //System.debug('@@ old wfi.Accumulated_New_Sales_Outcome_X__c: ' + wfi.Accumulated_New_Sales_Outcome_X__c);
            System.assertEquals(0, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the old weekly continuation sales outcome.');
            System.assertEquals(0, wfi.Accumulated_New_Sales_Outcome_X__c, 'Incorrect value on the old weekly new sales outcome.');
        }           
    }


    @isTest
    static void nr10_testRecreateYearlyTargetWithOppsSMEuser(){
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = smeUserTeam[2].Id;
            insert acc;
        }

        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        updateUserToBypassValidationRules(salesRep);

        System.runAs(salesRep) {
            Contact con = Test_DataFactory.createOneContact();
            con.AccountId = acc.Id;
            insert con;
            Test.startTest();
            OpportunityContactRole cr = Test_DataFactory.createOpportunityContactRole();
            cr.ContactId = con.Id;
            cr.Role = 'Avtalstecknare';

            Opportunity opp = getSingleOpportunitiesWithSingleOli(1, acc.Id)[0];
            cr.OpportunityId = opp.Id;
            insert cr;

            //Test.startTest();
            opp.Agreement_Signed__c = true;
            opp.Main_Product_Area__c = 'Services';
            
            opp.StageName = 'Vunnen';
            update opp;
        }
        
        //Verify values
        /*Opportunity insertedOpp = [SELECT Id, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c FROM Opportunity];
        System.assertNotEquals(insertedOpp.Large_Continuation_Sales__c, null, 'The opportunity continuation sales amount is null.');
        System.assertNotEquals(insertedOpp.Large_New_Sales__c, null, 'The opportunity new sales amount is null.');

        String weekNumber = SEUtility.getWeekNumberAsString(Date.today());
        String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(Date.today()));
        String yearNumber = String.valueOf(insertedOpp.CloseDate.year());
        
        Weekly_Forecast_Item__c wfi = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber AND User__c =: salesRep.Id];
        Quarterly_Forecast_Item__c qfi = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber AND User__c =: salesRep.Id];    
        Yearly_Target__c yfi = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Yearly_Target__c WHERE Name =: yearNumber AND User__c =: salesRep.Id];
        
        System.assertEquals(insertedOpp.Large_Continuation_Sales__c, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome for the old weekly target.');
        System.assertEquals(insertedOpp.Large_Continuation_Sales__c, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome for the old quarterly target.');
        System.assertEquals(insertedOpp.Large_Continuation_Sales__c, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome for the old yearly target.');
        Test.stopTest();
        // Deleting the sellers target record, saving old values before deleting
        delete yfi;

        // Creating new yearly target
        Yearly_Target__c ytNew = Test_DataFactory.createOneYearlyTarget(smeSellerTeam[2]);
        insert ytNew;

        

        Weekly_Forecast_Item__c wfiNew = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber AND User__c =: salesRep.Id];
        Quarterly_Forecast_Item__c qfiNew = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber AND User__c =: salesRep.Id];    
        Yearly_Target__c yfiNew = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Yearly_Target__c WHERE Name =: yearNumber AND User__c =: salesRep.Id];
        //Test.stopTest();
        // The opportunity should be automatically linked to new YT after recreation, 
        System.assertEquals(insertedOpp.Large_Continuation_Sales__c, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome for the new weekly target.');
        System.assertEquals(insertedOpp.Large_Continuation_Sales__c, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome for the new quarterly target.');
        System.assertEquals(insertedOpp.Large_Continuation_Sales__c, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome for the new yearly target.');

         */
    }

    @isTest
    static void nr11_testRecreateYearlyTargetWithOppsLargeUser(){    
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        List<Yearly_Target__c> largeSellerteamYT;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            largeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam);
            
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
            acc.OwnerId = largeUserTeam[2].Id;
            insert acc;
            System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        }

        User salesRep = largeUserTeam[2];

        System.runAs(salesRep){  
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id;
            opp.Seller__c = largeSellerTeam[2].Id; // Should be set automatically, but setting manually as this is not the functionality to verify in this test            
            
            insert opp;
             System.debug('2.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            Product2 p = Test_DataFactory.createProduct('Test');
            p.IsActive = true;
            insert p;
            
            Id pbId = Test.getStandardPricebookId();
            PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, p);
            pbe.UnitPrice = 1000;
            pbe.IsActive = true;
            insert pbe;
            
            PriceBookEntry pbe1 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p);
            pbe1.UnitPrice = 1000;
            pbe1.IsActive = true;
            insert pbe1;
            
            
            System.debug('3.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe1.Id);
            Test.startTest();
            insert oli;
                     
            List<Contact> conList = Test_DataFactory.createContacts(3);
            for(Contact con : conList){
                con.AccountId = acc.Id;
            }
            insert conList;
            System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            OpportunityContactRole ocr1 = Test_DataFactory.createOpportunityContactRole();
            ocr1.ContactId = conList[0].Id;
            ocr1.Role = OpportunityValidationHandler.OPP_CR_DECISION_MAKER;
            ocr1.OpportunityId = opp.Id;
            ocrList.add(ocr1);
            OpportunityContactRole ocr2 = Test_DataFactory.createOpportunityContactRole();
            ocr2.ContactId = conList[1].Id;
            ocr2.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr2.OpportunityId = opp.Id;
            ocrList.add(ocr2);
            
            insert ocrList;
            System.debug('5.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            Event e = Test_DataFactory.createOneCompletedEvent();
            e.WhoId = conList[0].Id;
            e.WhatId = opp.Id;
            insert e;
            System.debug('6.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            //Perform Test, set to won without closed activities
            opp.Deviations_from_General_Terms_Conditions__c = 'Nej';
            opp.Contract_start_date__c=System.today();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            opp.Agreement_Signed__c = true;
            opp.Category__c = 'Kategori 1';
            opp.Why_Change__c = 'Test';
            opp.Why_Now__c = 'Test';
            opp.Why_Telia__c = 'Test';
            opp.Current_Supplier__c = 'Test';
            //opp.Customer_ratings_pointing_to_Telia__c = 'Test';
            opp.Competitors__c = 'Test';
            opp.Revenue_Start__c = System.today();
            opp.Revenue_Start_CS__c = System.today();
            opp.Existing_agreement_revenue__c = 10000;
            // The sales amount values should be set automatically, but for some reason they are null.
            // Adding hard coded values as it is not the purpose of this test to verify the Sales amount fields on opportunities.
            opp.Large_Continuation_Sales__c = 1000;
            opp.Risk_Analysis_Done_and_Uploaded__c = 'Ja';
            opp.CCLM_Reference_Number__c = '87';
            opp.Competitor__c = 'Ingen huvudkonkurrent';
            opp.Comment_to_Reason__c = 'testcomment';
            opp.Reason__c = 'Pris';
            opp.Large_New_Sales__c = 1000;
            System.debug('6.Number of Queries used in this apex code so far: ' + Limits.getQueries());

            update opp;
            Test.stopTest();
            System.debug('7.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_WON);
        }
        System.debug('8.Number of Queries used in this apex code so far: ' + Limits.getQueries());

        //Verify values
        //Opportunity insertedOpp = [SELECT Id, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c FROM Opportunity];
        //System.assertNotEquals(insertedOpp.Large_Continuation_Sales__c, null, 'The opportunity continuation sales amount is null.');
        //System.assertNotEquals(insertedOpp.Large_New_Sales__c, null, 'The opportunity new sales amount is null.');

        //String weekNumber = SEUtility.getWeekNumberAsString(Date.today());
        //String quarterNumber = String.valueOf(SEUtility.getPeriodNumber(Date.today()));
        //String yearNumber = String.valueOf(insertedOpp.CloseDate.year());
        
        //Weekly_Forecast_Item__c wfi = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber AND User__c =: salesRep.Id];
        //Quarterly_Forecast_Item__c qfi = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber AND User__c =: salesRep.Id];    
       // Yearly_Target__c yfi = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Yearly_Target__c WHERE Name =: yearNumber AND User__c =: salesRep.Id];
        
        //System.assertEquals(insertedOpp.Large_Continuation_Sales__c, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome for the old weekly target.');
        //System.assertEquals(insertedOpp.Large_Continuation_Sales__c, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome for the old quarterly target.');
        //System.assertEquals(insertedOpp.Large_Continuation_Sales__c, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome for the old yearly target.');

        // Deleting the sellers target record, saving old values before deleting
        //delete yfi;

        // Creating new yearly target
        //Yearly_Target__c ytNew = Test_DataFactory.createOneYearlyTarget(largeSellerTeam[2]);
        //insert ytNew;

        //Weekly_Forecast_Item__c wfiNew = [SELECT Id, Accumulated_Continuation_Sales_Outcome_X__c, Accumulated_New_Sales_Outcome_X__c FROM Weekly_Forecast_Item__c WHERE Name =: weekNumber AND User__c =: salesRep.Id];
        //Quarterly_Forecast_Item__c qfiNew = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Quarterly_Forecast_Item__c WHERE Name =: quarterNumber AND User__c =: salesRep.Id];    
        //Yearly_Target__c yfiNew = [SELECT Id, Accumulated_Outcome_Continuation_Sales_X__c, Accumulated_Outcome_New_Sales_X__c FROM Yearly_Target__c WHERE Name =: yearNumber AND User__c =: salesRep.Id];

        // The opportunity should be automatically linked to new YT after recreation, 
        //System.assertEquals(insertedOpp.Large_Continuation_Sales__c, wfi.Accumulated_Continuation_Sales_Outcome_X__c, 'Incorrect value on the weekly continuation sales outcome for the new weekly target.');
        //System.assertEquals(insertedOpp.Large_Continuation_Sales__c, qfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the quarterly continuation sales outcome for the new quarterly target.');
        //System.assertEquals(insertedOpp.Large_Continuation_Sales__c, yfi.Accumulated_Outcome_Continuation_Sales_X__c, 'Incorrect value on the yearly continuation sales outcome for the new yearly target.');        
    }

    private static List<Opportunity> getSingleOpportunitiesWithSingleOli(Integer n, Id accountId) {
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 product = new Product2();
        product.Name = 'Laptop X200';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pricebookId;
        pbe.Product2Id = product.Id;
        pbe.UnitPrice = 10000; 
        pbe.IsActive = true;
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = SEUtility.PRICEBOOK_TELIA_NEWID;
        pbe2.Product2Id = product.Id;
        pbe2.UnitPrice = 10000; 
        pbe2.IsActive = true;
        insert pbe2;
        
        
        List<Opportunity> opportunities = Test_DataFactory.createOpportunitiesFromAccount(n, accountId);
        insert opportunities;
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        List<OpportunityLineItem> newOlis = Test_DataFactory.createOpportunityLineItems(n);// N=2
        for (Integer i = 0; i < newOlis.size(); i++) {
            newOlis[i].OpportunityId = opportunities[i].Id;
            newOlis[i].PricebookEntryId = pbe2.Id;
            newOlis[i].TotalPrice = 500;
            newOlis[i].Start_Fee__c = 100;
            newOlis[i].Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_NEW_SALES;
            olis.add(newOlis[i]);
        }
        
        List<OpportunityLineItem> oldOlis = Test_DataFactory.createOpportunityLineItems(n);
        for (Integer i = 0; i < oldOlis.size(); i++) {
            oldOlis[i].OpportunityId = opportunities[i].Id;
            oldOlis[i].PricebookEntryId = pbe2.Id;
            oldOlis[i].TotalPrice = 20;
            oldOlis[i].Start_Fee__c = 200;
            oldOlis[i].Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_CONT_SALES;
            olis.add(oldOlis[i]);
        }    
        insert olis;
        
        return opportunities;
    }

    private static void addOlisToOpportunities(List<Opportunity> opportunities) {
        Id pricebookId = Test.getStandardPricebookId();
        
        
        Product2 product = new Product2();
        product.Name = 'Laptop X200';
        insert product;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pricebookId;
        pbe.Product2Id = product.Id;
        pbe.UnitPrice = 10000; 
        pbe.IsActive = true;
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = SEUtility.PRICEBOOK_TELIA_NEWID;
        pbe2.Product2Id = product.Id;
        pbe2.UnitPrice = 10000; 
        pbe2.IsActive = true;
        insert pbe2;
              
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for(Opportunity opp : opportunities) {
            OpportunityLineItem oliNS = Test_DataFactory.createOpportunityLineItem();           
            oliNS.OpportunityId = opp.Id;
            oliNS.PricebookEntryId = pbe2.Id;
            oliNS.TotalPrice = 500;
            oliNS.Start_Fee__c = 100;
            oliNS.Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_NEW_SALES;
            olis.add(oliNS);

            OpportunityLineItem oliCS = Test_DataFactory.createOpportunityLineItem();
            oliCS.OpportunityId = opp.Id;
            oliCS.PricebookEntryId = pbe2.Id;
            oliCS.TotalPrice = 20;
            oliCS.Start_Fee__c = 200;
            oliCS.Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_CONT_SALES;
            olis.add(oliCS);
        }    
        insert olis;
    }

    /**@Description:
     * Helper method updating a User to allow bypassing of the validation rules implemented
     * in the OpportunityValidationHandler. Introduced to be applied on the test ctxt User
     * to reduce the # of SOQL queries performed during Opportunity record modifications.
     * @param userToUpdate - Test ctxt User to be set to bypass the validation rules.
     * Modifications:
     * 02.11.2022 [TB] AM 22.18 Release - Introduced. 
     **/
    public static void updateUserToBypassValidationRules(User userToUpdate){
        userToUpdate.Bypass_VR__c = true;
        update userToUpdate;
    }
}