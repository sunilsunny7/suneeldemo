/**
    About
    -----
    Description: Test Class to test creation of Yearly Target records.
        - Test that Sales Target values are set correctly
        - 
    Create date: March 2015
   
    Update History
    --------------
    Created March 2015 - V.I
    Updated March 2015 - V.I - Added new assertions
    Updated September 2015 - V.I - Added seller records to yearly targets
    Updated February 2016 - A.N - Added tests for updating Yearly Target target values
    Updated April 2016 - P.P - Added change for Sales Value Target
    Updates Apr 2018 - Y.K - Changes for SALEF-919 Change phasing of New Sales targets for SOHO Sales
    
    Issues / TODOs
    --------------  
*/

@isTest
public class Test_SetSalesTarget {
    
    @isTest static void newYearlyTargetTest(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;

        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = createYearlyTargetsSellerTeam(smeSellerTeam);
        }
        
        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];

        Yearly_Target__c yt = smeSellerteamYT[2];
        List<Quarterly_Forecast_Item__c> quarters = [Select Id from Quarterly_Forecast_Item__c where Yearly_Target__c = :yt.Id];
        List<Weekly_Forecast_Item__c> weeks = [Select Name, Quarterly_Forecast_Item__r.Name from Weekly_Forecast_Item__c where Quarterly_Forecast_Item__c in :quarters];
        
        //Assert
        System.assertEquals(4, quarters.size()); //Check that 4 quarters has been created
        System.assert(weeks.size() > 0); // Test that weeks has been created
    }


    @isTest static void duplicateTest(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = createYearlyTargetsSellerTeam(smeSellerTeam);
        }
        
        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        
        //Perform Test
        Yearly_Target__c yt2 = Test_DataFactory.createOneYearlyTarget(smeSellerTeam[0]);
        try {
            insert yt2;
        }
        catch(Exception e){
            System.debug('@@ message: ' + e.getMessage());
            System.assert(e.getMessage().contains('The year already exist for this seller'));
        }
    } 
         
    
    @isTest static void manyNewYearlyTargetTest(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;
        List<Yearly_Target__c> yt;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = createYearlyTargetsSellerTeam(smeSellerTeam);

        
            User smeManager = smeUserTeam[0];
            User salesManager = smeUserTeam[1];
            User salesRep = smeUserTeam[2];
            
            // Create four new users with seller records of type 'seller', and create yearly targets
            List<User> ul = new List<User>();
            for(integer i=0; i<4; i++){
                ul.add(Test_DataFactory.createSMEUser());
            }
            insert ul;

            List<Seller__c> sellerList = new List<Seller__c>();
            for(User u : ul){
                sellerList.add(Test_DataFactory.createSeller(u.Id, smeSellerTeam[1].id));
            }
            insert sellerList;

            yt = new List<Yearly_Target__c>();
            for(Seller__c s : sellerList){
                yt.add(Test_DataFactory.createOneYearlyTarget(s));
            }
        }
        //Perform Test
        Test.startTest();
        insert yt;
        Test.stopTest();   
        
        List<Quarterly_Forecast_Item__c> quarters = [Select Id from Quarterly_Forecast_Item__c where Yearly_Target__c in :yt];
        List<Weekly_Forecast_Item__c> weeks = [Select Name, Quarterly_Forecast_Item__r.Name from Weekly_Forecast_Item__c where Quarterly_Forecast_Item__c in :quarters];
        
        //Assert
        System.assertEquals(16, quarters.size()); //Check that 4*4 quarters has been created
        System.assert(weeks.size()>0); //Check that weeks has been created
    }
    
    @isTest 
    static void nameTest(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }
        
        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        
        Yearly_Target__c yt = Test_DataFactory.createOneYearlyTarget(smeSellerTeam[0]);
        yt.Name = 'ABCD';    
        
        //Perform Test
        try {
            insert yt;
        }
        catch(Exception e){
            System.debug('@@ message: ' + e.getMessage());
            System.assert(e.getMessage().contains('A year must be a number and in the format of YYYY e.g. 2015'));
        }
    }
    
    @isTest 
    static void yearInPastTest(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }
        
        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];
        
        Yearly_Target__c yt = Test_DataFactory.createOneYearlyTarget(smeSellerTeam[0]);
        yt.Name = String.valueOf(Date.today().year() - 10);
        
        //Perform Test
        try {
            insert yt;
        }
        catch(Exception e){
            System.debug('@@ message: ' + e.getMessage());
            System.assert(e.getMessage().contains('A target can only be created for the current year or for future years'));
        }
    }

    @isTest 
    static void startWeekMiddleOfYear(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }
        
        Yearly_Target__c yt = Test_DataFactory.createOneYearlyTarget(smeSellerTeam[0]);
        yt.Startweek__c = '50';
        yt.Full_Year_New_Sales_Target__c = 500000;
        /*added by PP for Sales Value Target*/
        yt.Full_Year_Sales_Value_Target__c = 100000;
        
        Test.startTest();
        insert yt;
        Test.stopTest();   
        
        List<Quarterly_Forecast_Item__c> quarters = [Select Id from Quarterly_Forecast_Item__c where Yearly_Target__c =: yt.Id];
        List<Weekly_Forecast_Item__c> weekNotIncluded = [Select Name, New_Sales_Target__c from Weekly_Forecast_Item__c where Quarterly_Forecast_Item__c in :quarters and Name='49'];
        List<Weekly_Forecast_Item__c> weekIncluded = [Select Name, New_Sales_Target__c from Weekly_Forecast_Item__c where Quarterly_Forecast_Item__c in :quarters and Name='51'];
        
        //Assert
        System.assertEquals(0,weekNotIncluded[0].New_Sales_Target__c); //Weeks before week 50 should have 0 as target
        System.assert(weekIncluded[0].New_Sales_Target__c > 0); //Weeks after week 50 should have a target greater than 0       
    }
    
    //This method tests that all years between 2015 and 2029 (included) receive a proper start and end date
    @isTest
    static void testAllYears(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;

        //Test Data Setup
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }

        Map<Integer, Map<Date,Date>> yearStartEndDateMap = new Map<Integer, Map<Date,Date>>();
        
        yearStartEndDateMap.put(2015, new Map<Date,Date>{Date.parse('2014-12-29')=>Date.parse('2016-01-03')});
        yearStartEndDateMap.put(2016, new Map<Date,Date>{Date.parse('2016-01-04')=>Date.parse('2017-01-01')});
        yearStartEndDateMap.put(2017, new Map<Date,Date>{Date.parse('2017-01-02')=>Date.parse('2017-12-31')});
        yearStartEndDateMap.put(2018, new Map<Date,Date>{Date.parse('2018-01-01')=>Date.parse('2018-12-30')});
        yearStartEndDateMap.put(2019, new Map<Date,Date>{Date.parse('2018-12-31')=>Date.parse('2019-12-29')});
        yearStartEndDateMap.put(2020, new Map<Date,Date>{Date.parse('2019-12-30')=>Date.parse('2021-01-03')});
        
        yearStartEndDateMap.put(2021, new Map<Date,Date>{Date.parse('2021-01-04')=>Date.parse('2022-01-02')});
        yearStartEndDateMap.put(2022, new Map<Date,Date>{Date.parse('2022-01-03')=>Date.parse('2023-01-01')});
        yearStartEndDateMap.put(2023, new Map<Date,Date>{Date.parse('2023-01-02')=>Date.parse('2023-12-31')});
        yearStartEndDateMap.put(2024, new Map<Date,Date>{Date.parse('2024-01-01')=>Date.parse('2024-12-29')});
        yearStartEndDateMap.put(2025, new Map<Date,Date>{Date.parse('2024-12-30')=>Date.parse('2025-12-28')});
        
        yearStartEndDateMap.put(2026, new Map<Date,Date>{Date.parse('2025-12-29')=>Date.parse('2027-01-03')});
        yearStartEndDateMap.put(2027, new Map<Date,Date>{Date.parse('2027-01-04')=>Date.parse('2028-01-02')});
        yearStartEndDateMap.put(2028, new Map<Date,Date>{Date.parse('2028-01-03')=>Date.parse('2028-12-31')});
        yearStartEndDateMap.put(2029, new Map<Date,Date>{Date.parse('2029-01-01')=>Date.parse('2029-12-30')});
        
        Integer startyear = Date.today().year();
        List<Yearly_Target__c> yts = new List<Yearly_Target__c>();
        // Note that we will only create YT's for years equal or after this year, as no YT's can be created for past years (validation rules)
        for(Integer i = startyear; i < 2030 ; i++){
            Yearly_Target__c yt = Test_DataFactory.createOneYearlyTarget(smeSellerTeam[0]);
            yt.Name = string.valueof(i);
            yts.add(yt);
        }

        Test.startTest();

        for(Yearly_Target__c yt : yts){
            yt.Full_Year_New_Sales_Target__c = 1000000.0;
            yt.Full_Year_Continuation_Sales_Target__c = 1000000.0;
            yt.Full_Year_Sales_Value_Target__c = 1000000.0;
        }
        insert yts;
        
        List<Quarterly_Forecast_Item__c> qfiList = [SELECT Id, Name, Start_Date__c, End_Date__c,Yearly_Target__c FROM Quarterly_Forecast_Item__c WHERE Yearly_Target__c IN : yts];
        List<Weekly_Forecast_Item__c> wfiList = [SELECT Name,Start_Date__c, End_Date__c,Quarterly_Forecast_Item__c FROM Weekly_Forecast_Item__c WHERE Quarterly_Forecast_Item__c IN :qfiList];
        
        // List of quarters for yearId
        Map<Id,List<Quarterly_Forecast_Item__c>> yearToQuarterListMap = new Map<Id,List<Quarterly_Forecast_Item__c>>();
        // List of weeks for quarterId
        Map<Id,List<Weekly_Forecast_Item__c>> quarterToWeekListMap = new Map<Id, List<Weekly_Forecast_Item__c>>();
        
        // Startdate and enddate for year number
        Map<Integer,Map<Date,Date>> resultingYearStartEndDateMap = new Map<Integer, Map<Date,Date>>();
        
        for(Yearly_Target__c yt : yts){
            for(Quarterly_Forecast_Item__c qfi : qfiList){
                if(yt.Id == qfi.Yearly_Target__c){
                    if(yearToQuarterListMap.containsKey(yt.Id)){
                        yearToQuarterListMap.get(yt.Id).add(qfi);
                    }
                    else{
                        yearToQuarterListMap.put(yt.id, new List<Quarterly_Forecast_Item__c>{qfi});
                    }
                }                
            }
        }
        
        Date dynamicStartDate;
        Date dynamicEndDate;
        for(Yearly_Target__c yt : yts){
            for(Quarterly_Forecast_Item__c qfi : yearToQuarterListMap.get(yt.Id)){
                if(Integer.valueOf(qfi.Name) == 1){
                    dynamicStartDate = qfi.Start_Date__c;
                }
                else if(Integer.valueOf(qfi.Name) == 4){
                    dynamicEndDate = qfi.End_Date__c;
                }
            }
            resultingYearStartEndDateMap.put(Integer.valueOf(yt.Name),new Map<Date,Date>{dynamicStartDate=>dynamicEndDate});
        }
        
        // START - Check start and end dates on YEARS
        // Note that we will only check for years equal or after this year, as no YT's can be created for past years
        Date expectedStartDate;
        Date expectedEndDate;
        Date realStartDate;
        Date realEndDate;
        for(Integer year : yearStartEndDateMap.keySet()){
            if(year >= startyear){
                // Will only return 1 date
                for(Date d : yearStartEndDateMap.get(year).keySet()){
                    expectedStartDate = d;
                    expectedEndDate = yearStartEndDateMap.get(year).get(d);
                }
                
                //Will only return 1 date
                for(Date d : resultingYearStartEndDateMap.get(year).keySet()){
                    realStartDate = d;
                    realEndDate = resultingYearStartEndDateMap.get(year).get(d);
                }
                
                // Compare start and end dates
                System.assertEquals(expectedStartDate, realStartDate, 'The start dates of the year does not match');
                System.assertEquals(expectedEndDate, realEndDate, 'The end dates of the year does not match');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testNrOfWeeksPerQuarter(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;

        //Test Data Setup
        Test_DataFactory.setUpOrg();

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }
        
        Map<Integer,Map<Integer,Integer>> yearQuarterNrOfWeeksMap = new Map<Integer, Map<Integer,Integer>>();
        yearQuarterNrOfWeeksMap.put(2015, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>14});
        yearQuarterNrOfWeeksMap.put(2016, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2017, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2018, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2019, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2020, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>14});
        yearQuarterNrOfWeeksMap.put(2021, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2022, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2023, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2024, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2025, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2026, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>14});
        yearQuarterNrOfWeeksMap.put(2027, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2028, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        yearQuarterNrOfWeeksMap.put(2029, new Map<Integer,Integer>{1=>13,2=>13,3=>13,4=>13});
        
        
        Test.startTest();
        //Create Year
        Integer startyear = Date.today().year();
        List<Yearly_Target__c> yts = new List<Yearly_Target__c>();
        for(Integer i = startyear; i < 2030 ; i++){
            Yearly_Target__c yt = Test_DataFactory.createOneYearlyTarget(smeSellerTeam[0]);
            yt.Name = String.valueOf(i);
            yt.Full_Year_New_Sales_Target__c = 1000000.0;
            yt.Full_Year_Continuation_Sales_Target__c = 1000000.0;
            yt.Full_Year_Sales_Value_Target__c = 1000000.0;
            yts.add(yt);
        }
        
        insert yts;
        
        List<Quarterly_Forecast_Item__c> qfiList = [SELECT Id, Name,Yearly_Target__c, Yearly_Target__r.Name FROM Quarterly_Forecast_Item__c WHERE Yearly_Target__c IN : yts];
        List<Weekly_Forecast_Item__c> wfiList = [SELECT Id,Name,Quarterly_Forecast_Item__c FROM Weekly_Forecast_Item__c WHERE Quarterly_Forecast_Item__c IN :qfiList];
        
        Map<Id, List<Quarterly_Forecast_Item__c>> yearToQfiMap = new Map<Id, List<Quarterly_Forecast_Item__c>>();
        Map<Id, List<Weekly_Forecast_Item__c>> qfiToWfiMap = new Map<Id,List<Weekly_Forecast_Item__c>>();
    
        for(Yearly_Target__c yt : yts){
            for(Quarterly_Forecast_Item__c qfi : qfiList){
                if(qfi.Yearly_Target__c == yt.Id){
                    if(!yearToQfiMap.containsKey(yt.Id)){
                        yearToQfiMap.put(yt.Id, new List<Quarterly_Forecast_Item__c>{qfi});
                    }
                    else{
                        yearToQfiMap.get(yt.Id).add(qfi);
                    }
                }
            }
        }
        
        for(Quarterly_Forecast_Item__c qfi : qfiList){
            for(Weekly_Forecast_Item__c wfi : wfiList){
                if(wfi.Quarterly_Forecast_Item__c == qfi.id){
                    if(!qfiToWfiMap.containsKey(qfi.Id)){
                        qfiToWfiMap.put(qfi.Id, new List<Weekly_Forecast_Item__c>{wfi});
                    }
                    else{
                        qfiToWfiMap.get(qfi.Id).add(wfi);
                    }
                }   
            }
        }
        
        Map<Integer,Map<Integer,Integer>> realYearQuarterNrOfWeeksMap = new Map<Integer,Map<Integer,Integer>>();
        
        for(Yearly_Target__c yt : yts){
            for(Quarterly_Forecast_Item__c qfi : yearToQfiMap.get(yt.Id)){
                if(!realYearQuarterNrOfWeeksMap.containsKey(Integer.valueOf(yt.Name))){
                    realYearQuarterNrOfWeeksMap.put(Integer.valueOf(yt.Name), new Map<Integer,Integer>{Integer.valueOf(qfi.Name) => qfiToWfiMap.get(qfi.Id).size()});
                }
                else{
                    realYearQuarterNrOfWeeksMap.get(Integer.valueOf(yt.Name)).put(Integer.valueOf(qfi.Name),qfiToWfiMap.get(qfi.Id).size());
                }           
            }          
        }
        for(Integer year : yearQuarterNrOfWeeksMap.keySet()){
            if(year >= startyear){
                for(Integer quarter : yearQuarterNrOfWeeksMap.get(year).keySet()){
                    System.assertEquals(yearQuarterNrOfWeeksMap.get(year).get(quarter), realYearQuarterNrOfWeeksMap.get(year).get(quarter), 'The quarter Q'+quarter+' in year '+year+' contains '+realYearQuarterNrOfWeeksMap.get(year).get(quarter)+' which is not expected'); 
                }
            }
        }
        Test.stopTest();
    }

    @isTest static void updateYearlyTargetTest(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;

        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = createYearlyTargetsSellerTeam(smeSellerTeam);
           
        }
        
        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];

        Yearly_Target__c yt = smeSellerteamYT[2];
        yt.Full_Year_New_Sales_Target__c = 1000000;
        yt.Full_Year_Continuation_Sales_Target__c = 1000000; 
        yt.Full_Year_Sales_Value_Target__c = 1000000; 
        update yt;

        List<Quarterly_Forecast_Item__c> quarters = [Select Id, New_Sales_Target__c, Continuation_Sales_Target__c from Quarterly_Forecast_Item__c where Yearly_Target__c = :yt.Id];
        List<Weekly_Forecast_Item__c> weeks = [Select Name, New_Sales_Target__c, Continuation_Sales_Target__c, Quarterly_Forecast_Item__r.Name from Weekly_Forecast_Item__c where Quarterly_Forecast_Item__c in :quarters];        

        //Yearly_Target__c oldYt = [Select Id, Full_Year_New_Sales_Target__c, Full_Year_Continuation_Sales_Target__c from Yearly_Target__c where Id = :yt.Id];
        Quarterly_Forecast_Item__c oldQuarter = quarters[0];
        Weekly_Forecast_Item__c oldWeek = weeks[0];

        yt.Full_Year_New_Sales_Target__c = 2000000;
        yt.Full_Year_Continuation_Sales_Target__c = 3000000;
        yt.Full_Year_Sales_Value_Target__c = 3000000;
        update yt;

        Yearly_Target__c newYt = [Select Id, Full_Year_New_Sales_Target__c, Full_Year_Continuation_Sales_Target__c, Full_Year_Sales_Value_Target__c, New_Sales_Target__c, Continuation_Sales_Target__c from Yearly_Target__c where Id = :yt.Id];
        Quarterly_Forecast_Item__c newQuarter = [Select Id, New_Sales_Target__c, Continuation_Sales_Target__c from Quarterly_Forecast_Item__c where Id = :oldQuarter.Id];
        Weekly_Forecast_Item__c newWeek = [Select Id, Name, New_Sales_Target__c, Continuation_Sales_Target__c, Quarterly_Forecast_Item__r.Name from Weekly_Forecast_Item__c where Id = :oldWeek.Id];

        System.assertEquals(Math.round(newYt.Full_Year_New_Sales_Target__c), Math.round(newYt.New_Sales_Target__c), 'The yearly new sales target should be the same as the full year target since start week is 1.');
        System.assertEquals(Math.round(newYt.Full_Year_Continuation_Sales_Target__c), Math.round(newYt.Continuation_Sales_Target__c), 'The yearly cont sales target should be the same as the full year target since start week is 1.');
        System.assertEquals(Math.round(newQuarter.New_Sales_Target__c), Math.round(oldQuarter.New_Sales_Target__c*2), 'The quarterly new sales should have been doubled when yearly target is doubled.');
        System.assertEquals(Math.round(newQuarter.Continuation_Sales_Target__c), Math.round(oldQuarter.Continuation_Sales_Target__c*3), 'The quarterly cont sales should have been tripled when yearly target is tripled.');
        System.assertEquals(Math.round(newWeek.New_Sales_Target__c), Math.round(oldWeek.New_Sales_Target__c*2), 'The weekly new sales should have been doubled when yearly target is doubled.');
        System.assertEquals(Math.round(newWeek.Continuation_Sales_Target__c), Math.round(oldWeek.Continuation_Sales_Target__c*3), 'The weekly cont sales should have been tripled when yearly target is tripled.');
    }

    @isTest static void updateYearlyTargetStartWeek(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;

        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = createYearlyTargetsSellerTeam(smeSellerTeam);
        }
        
        User smeManager = smeUserTeam[0];
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];

        Yearly_Target__c yt = smeSellerteamYT[2];
        
        yt.Full_Year_New_Sales_Target__c = 1000000;
        yt.Full_Year_Continuation_Sales_Target__c = 1000000; 
        yt.Full_Year_Sales_Value_Target__c = 1000000;
        update yt; 
        
        
        yt.Startweek__c = '10';
        update yt;

        List<Quarterly_Forecast_Item__c> quarters = [Select Id, New_Sales_Target__c, Continuation_Sales_Target__c from Quarterly_Forecast_Item__c where Yearly_Target__c = :yt.Id];
        List<Weekly_Forecast_Item__c> weeks = [Select Name, New_Sales_Target__c, Continuation_Sales_Target__c, Quarterly_Forecast_Item__r.Name from Weekly_Forecast_Item__c where Quarterly_Forecast_Item__c in :quarters];  

        Yearly_Target__c newYt = [Select Id, Full_Year_New_Sales_Target__c, Full_Year_Continuation_Sales_Target__c, New_Sales_Target__c, Continuation_Sales_Target__c from Yearly_Target__c where Id = :yt.Id];        
        System.assertNotEquals(0, Math.round(newYt.New_Sales_Target__c), 'The yearly new sales target should not be 0.');
        System.assertNotEquals(0, Math.round(newYt.Continuation_Sales_Target__c), 'The yearly cont sales target should not be 0.');
        System.assertNotEquals(Math.round(newYt.Full_Year_New_Sales_Target__c), Math.round(newYt.New_Sales_Target__c), 'The yearly new sales target should not be the same as the full year target since start week is 10.');
        System.assertNotEquals(Math.round(newYt.Full_Year_Continuation_Sales_Target__c), Math.round(newYt.Continuation_Sales_Target__c), 'The yearly cont sales target should not be the same as the full year target since start week is 10.');
        
        for(Weekly_Forecast_Item__c week : weeks){
            if(Integer.valueOf(week.Name) < Integer.valueOf(yt.Startweek__c)){
                System.assertEquals(week.New_Sales_Target__c, 0, 'The weekly new sales should have been 0 for week with name ' + week.Name + ' because the week number ' + Integer.valueOf(week.Name) + ' is less than the YT start week ' + Integer.valueOf(yt.Startweek__c));        
            } else {
                System.assertNotEquals(week.New_Sales_Target__c, 0, 'The weekly new sales should not have been 0 for week number ' + week.Name);    
            }
            
        }       
    }

    @isTest
    static void testWeekNumber(){
        Date dynamicDate = Date.parse('2014-12-29');
        Date endDate = Date.parse('2029-12-30');
        Integer dayCounter = 1; 
        Integer weekNumberCounter = 1;
         
        while(dynamicDate <= endDate ){
            if(dayCounter > 7){
                dayCounter = 1;
                weekNumberCounter++;
                if(weekNumberCounter == 53 && (dynamicDate.year() == 2015 || dynamicDate.year() == 2020 || dynamicDate.year() ==2026)){
                    
                }else if(weekNumberCounter == 53 || weekNumberCounter == 54){
                    weekNumberCounter = 1;
                }
            }
            System.assertEquals(weekNumberCounter, SEUtility.getWeekNumber(dynamicDate),'The returned weeknumber does not match what is expected for the date '+dynamicDate);
            dynamicDate = dynamicDate.addDays(1);
            dayCounter++;
        }
    }
    
    
    @isTest
    static void testSampleWeekNumber(){
        
        Date testDate = Date.parse('2015-08-17');
        System.assertEquals(34, SEUtility.getWeekNumber(testDate),'The returned weeknumber does not match what is expected for the date ' + testDate);
        
        testDate = Date.parse('2021-01-03');
        System.assertEquals(53, SEUtility.getWeekNumber(testDate),'The returned weeknumber does not match what is expected for the date ' + testDate);
        
        testDate = Date.parse('2021-12-27');
        System.assertEquals(52, SEUtility.getWeekNumber(testDate),'The returned weeknumber does not match what is expected for the date ' + testDate);
        
        testDate = Date.parse('2019-12-31');
        System.assertEquals(1, SEUtility.getWeekNumber(testDate),'The returned weeknumber does not match what is expected for the date ' + testDate);
        
        testDate = Date.parse('2021-12-27');
        System.assertEquals(52, SEUtility.getWeekNumber(testDate),'The returned weeknumber does not match what is expected for the date ' + testDate);
        
        testDate = Date.parse('2016-01-04');
        System.assertEquals(1, SEUtility.getWeekNumber(testDate),'The returned weeknumber does not match what is expected for the date ' + testDate);
        
        testDate = Date.parse('2019-04-17');
        System.assertEquals(16, SEUtility.getWeekNumber(testDate),'The returned weeknumber does not match what is expected for the date ' + testDate);
        
    }

    // Returns a yearly target for each seller in the input list
    private static List<Yearly_Target__c> createYearlyTargetsSellerTeam(List<Seller__c> sl){
        List<Yearly_Target__c> ytl = new List<Yearly_Target__c>();
        for(Seller__c s : sl){
            Yearly_Target__c yt = Test_DataFactory.createOneYearlyTarget(s);
            yt.Name = String.valueOf(System.today().year());
            insert yt;
            ytl.add(yt);
        }
        return ytl;
    }
    
    //Y.K - SALEF-919
    @isTest 
    static void TestSOHOYTargets(){
        YearlyTargetTriggerHandler.testyearlyTargetValidation = true;
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();

        List<User> SOHOUserTeam;
        List<Seller__c> SOHOSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            SOHOUserTeam = Test_DataFactory.createSOHOUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            SOHOSellerTeam = Test_DataFactory.createSOHOSellerTeam(SOHOUserTeam);
        }
        
        Yearly_Target__c yt = Test_DataFactory.createOneYearlyTarget(SOHOSellerTeam[0]);
        yt.Startweek__c = '50';
        yt.Full_Year_New_Sales_Target__c = 500000;
        /*added by PP for Sales Value Target*/
        yt.Full_Year_Sales_Value_Target__c = 100000;
        
        Test.startTest();
        insert yt;
        Test.stopTest();   
        
        List<Quarterly_Forecast_Item__c> quarters = [Select Id from Quarterly_Forecast_Item__c where Yearly_Target__c =: yt.Id];
        List<Weekly_Forecast_Item__c> weekNotIncluded = [Select Name, New_Sales_Target__c from Weekly_Forecast_Item__c where Quarterly_Forecast_Item__c in :quarters and Name='49'];
        List<Weekly_Forecast_Item__c> weekIncluded = [Select Name, New_Sales_Target__c from Weekly_Forecast_Item__c where Quarterly_Forecast_Item__c in :quarters and Name='51'];
        
        //Assert
        System.assertEquals(0,weekNotIncluded[0].New_Sales_Target__c); //Weeks before week 50 should have 0 as target
        System.assert(weekIncluded[0].New_Sales_Target__c > 0); //Weeks after week 50 should have a target greater than 0       
    }
}