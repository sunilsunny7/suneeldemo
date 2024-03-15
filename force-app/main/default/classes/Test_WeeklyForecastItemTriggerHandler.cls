@isTest
private class Test_WeeklyForecastItemTriggerHandler {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }

    @isTest static void runPositivePath_Judge_OneManagerLine() {

        List<User> largeUserTeam1;
        List<Seller__c> largeSellerTeam1;
        List<Yearly_Target__c> largeSellerteamYT1;
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            // Returns list of users
            largeUserTeam1 = Test_DataFactory.createLargeUserTeam();

            // Returns list of sellers
            largeSellerTeam1 = Test_DataFactory.createLargeSellerTeam(largeUserTeam1,Date.today());

            // Returns list of yearly targets
            largeSellerteamYT1 = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam1);
        }

        User businessAreaManager1 = largeUserTeam1[0];
        User businessUnitManager1 = largeUserTeam1[1];
        User salesUnitDirector1 = largeUserTeam1[2];
        User salesTeamManager1 = largeUserTeam1[3];

        String week = SEUtility.getWeekNumberAsString(Date.today());

        // Weekly Forecast Items for the current week
        List<Weekly_Forecast_Item__c> wfis = 
            [SELECT Seller__c,Seller__r.Manager__c,Name,Judge_CS__c,Judge_NS__c,Seller__r.Type__c,Roll_up_Judge_NS__c,Roll_up_Judge_CS__c
            FROM Weekly_Forecast_Item__c
            WHERE Name = :week];

        Map<Id,Weekly_Forecast_Item__c> sellerwfi = new Map<Id,Weekly_Forecast_Item__c>();
        for (Weekly_Forecast_Item__c wfi : wfis) {
            sellerwfi.put(wfi.Seller__c, wfi);
        }

        System.assertEquals(week,wfis[0].Name); 
        System.assertNotEquals(0,wfis.size());
        Seller__c stm1 = [SELECT Id,Manager__c FROM Seller__c WHERE Id = :largeSellerTeam1[3].Id limit 1][0];
        System.assertEquals(stm1.Manager__c,largeSellerTeam1[2].Id);

        Test.startTest();

        System.runAs(salesTeamManager1) {
            Weekly_Forecast_Item__c wfiSTM1 = sellerwfi.get(largeSellerTeam1[3].Id);
            wfiSTM1.Judge_CS__c = 10.0;
            update wfiSTM1;
        }

        Weekly_Forecast_Item__c wfiSTM11 = [SELECT id,Judge_CS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[3].Id and Name = :week limit 1][0];
        System.assertEquals(10.0, wfiSTM11.Judge_CS__c);

        Weekly_Forecast_Item__c wfiSUD1 = [SELECT id, Judge_CS__c, Roll_up_Judge_CS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[2].Id and Name = :week limit 1][0];
        System.assertEquals(wfiSTM11.Judge_CS__c, wfiSUD1.Roll_up_Judge_CS__c);

        Weekly_Forecast_Item__c wfiBUM1 = [SELECT id, Judge_CS__c, Roll_up_Judge_CS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[1].Id and Name = :week limit 1][0];
        System.assertEquals(wfiSUD1.Judge_CS__c + wfiSUD1.Roll_up_Judge_CS__c, wfiBUM1.Roll_up_Judge_CS__c);

        Weekly_Forecast_Item__c wfiBAM1 = [SELECT id, Judge_CS__c, Roll_up_Judge_CS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[0].Id and Name = :week limit 1][0];
        System.assertEquals(wfiBUM1.Judge_CS__c + wfiBUM1.Roll_up_Judge_CS__c, wfiBAM1.Roll_up_Judge_CS__c);
        
        Test.stopTest();

    }
    
    @isTest static void runPositivePath_Judge_TwoManagerLines() {
        
        List<User> largeUserTeam1;
        List<Seller__c> largeSellerTeam1;
        List<Yearly_Target__c> largeSellerteamYT1;
        List<User> largeUserTeam2;
        List<Seller__c> largeSellerTeam2;
        List<Yearly_Target__c> largeSellerteamYT2;

        System.runAs(new User(Id = Userinfo.getUserId())){
            // Returns list of users
            List<User> largeUsers = Test_DataFactory.createLargeUserTeam(10);
            largeUserTeam1 = new List<User>();
            for(Integer i = 0; i < 5; i++) {
                largeUserTeam1.add(largeUsers[i]);
            }
            largeUserTeam2 = new List<User>();
            for(Integer j = 5; j < 10; j++) {
                largeUserTeam2.add(largeUsers[j]);
            }
            
            // Returns list of sellers
            largeSellerTeam1 = Test_DataFactory.createLargeSellerTeam(largeUserTeam1,Date.today());
            largeSellerTeam2 = Test_DataFactory.createLargeSellerTeam(largeUserTeam2,Date.today());
        }

        System.debug('SOQLs so far 1: '+Limits.getQueries());
        Test.startTest();

        System.runAs(new User(Id = Userinfo.getUserId())){
            // Returns list of yearly targets
            largeSellerteamYT1 = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam1);
            largeSellerteamYT2 = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam2);
        }
        
        /*
        Seller hierarchy:
        STM1 -> SUD1 -> BUM1 -> BAM1
        STM2 -> SUD2 -> BUM1 -> BAM1        
        */

        User businessAreaManager1 = largeUserTeam1[0];
        User businessUnitManager1 = largeUserTeam1[1];
        User salesUnitDirector1 = largeUserTeam1[2];
        User salesTeamManager1 = largeUserTeam1[3];

        User businessAreaManager2 = largeUserTeam2[0];
        User businessUnitManager2 = largeUserTeam2[1];
        User salesUnitDirector2 = largeUserTeam2[2];
        User salesTeamManager2 = largeUserTeam2[3];

        // Change manager
        largeSellerTeam2[2].Manager__c = largeSellerTeam1[1].Id;
        update largeSellerTeam2[2];

        String week = SEUtility.getWeekNumberAsString(Date.today());

        // Weekly Forecast Items for the current week
        List<Weekly_Forecast_Item__c> wfis = 
            [SELECT Seller__c,Seller__r.Manager__c,Name,Judge_CS__c,Judge_NS__c,Seller__r.Type__c,Roll_up_Judge_NS__c,Roll_up_Judge_CS__c
            FROM Weekly_Forecast_Item__c
            WHERE Name = :week];

        Map<Id,Weekly_Forecast_Item__c> sellerwfi = new Map<Id,Weekly_Forecast_Item__c>();
        for (Weekly_Forecast_Item__c wfi : wfis) {
            sellerwfi.put(wfi.Seller__c, wfi);
        }

        System.assertEquals(week,wfis[0].Name); 
        System.assertNotEquals(0,wfis.size());
        Seller__c stm1 = [SELECT Id,Manager__c FROM Seller__c WHERE Id = :largeSellerTeam1[3].Id limit 1][0];
        System.assertEquals(stm1.Manager__c,largeSellerTeam1[2].Id);
        System.debug('SOQLs so far 2: '+Limits.getQueries());

        //Test.startTest();
        List<Weekly_Forecast_Item__c> wfisToUpdate = new List<Weekly_Forecast_Item__c>();
        Weekly_Forecast_Item__c wfiSTM13 = sellerwfi.get(largeSellerTeam1[3].Id);
        wfiSTM13.Judge_CS__c = 10.0;
        wfiSTM13.Judge_NS__c = 20.0;        
        wfisToUpdate.add(wfiSTM13);

        Weekly_Forecast_Item__c wfiSTM23 = sellerwfi.get(largeSellerTeam2[3].Id);
        wfiSTM23.Judge_CS__c = 30.0;
        wfiSTM23.Judge_NS__c = 40.0;            
        wfisToUpdate.add(wfiSTM23);

        Weekly_Forecast_Item__c wfiSTM22 = sellerwfi.get(largeSellerTeam2[2].Id);
        wfiSTM22.Judge_CS__c = 50.0;
        wfiSTM22.Judge_NS__c = 60.0;            
        wfisToUpdate.add(wfiSTM22);

        update wfisToUpdate;
        System.debug('SOQLs so far 3: '+Limits.getQueries());

        Weekly_Forecast_Item__c wfiSTM1 = [SELECT id,Judge_CS__c, Judge_NS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[3].Id and Name = :week limit 1][0];
        System.assertEquals(10.0, wfiSTM1.Judge_CS__c);
        System.assertEquals(20.0, wfiSTM1.Judge_NS__c);

        Weekly_Forecast_Item__c wfiSTM2 = [SELECT id,Judge_CS__c, Judge_NS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam2[3].Id and Name = :week limit 1][0];
        System.assertEquals(30.0, wfiSTM2.Judge_CS__c);
        System.assertEquals(40.0, wfiSTM2.Judge_NS__c);

        Weekly_Forecast_Item__c wfiSUD1 = [SELECT id, Judge_CS__c, Judge_NS__c, Roll_up_Judge_CS__c, Roll_up_Judge_NS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[2].Id and Name = :week limit 1][0];
        System.assertEquals(wfiSTM1.Judge_CS__c, wfiSUD1.Roll_up_Judge_CS__c);
        System.assertEquals(wfiSTM1.Judge_NS__c, wfiSUD1.Roll_up_Judge_NS__c);

        Weekly_Forecast_Item__c wfiSUD2 = [SELECT id, Judge_CS__c, Judge_NS__c, Roll_up_Judge_CS__c, Roll_up_Judge_NS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam2[2].Id and Name = :week limit 1][0];
        System.assertEquals(wfiSTM2.Judge_CS__c, wfiSUD2.Roll_up_Judge_CS__c);
        System.assertEquals(wfiSTM2.Judge_NS__c, wfiSUD2.Roll_up_Judge_NS__c);
        System.debug('SOQLs so far 4: '+Limits.getQueries());

        Weekly_Forecast_Item__c wfiBUM1 = [SELECT id, Judge_CS__c, Judge_NS__c, Roll_up_Judge_CS__c, Roll_up_Judge_NS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[1].Id and Name = :week limit 1][0];
        System.assertEquals(wfiSUD1.Judge_CS__c + wfiSUD1.Roll_up_Judge_CS__c + wfiSUD2.Judge_CS__c + wfiSUD2.Roll_up_Judge_CS__c, wfiBUM1.Roll_up_Judge_CS__c);
        System.assertEquals(wfiSUD1.Judge_NS__c + wfiSUD1.Roll_up_Judge_NS__c + wfiSUD2.Judge_NS__c + wfiSUD2.Roll_up_Judge_NS__c, wfiBUM1.Roll_up_Judge_NS__c);

        Weekly_Forecast_Item__c wfiBAM1 = [SELECT id, Judge_CS__c, Judge_NS__c, Roll_up_Judge_CS__c, Roll_up_Judge_NS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[0].Id and Name = :week limit 1][0];
        System.assertEquals(wfiBUM1.Judge_CS__c + wfiBUM1.Roll_up_Judge_CS__c, wfiBAM1.Roll_up_Judge_CS__c);
        System.assertEquals(wfiBUM1.Judge_NS__c + wfiBUM1.Roll_up_Judge_NS__c, wfiBAM1.Roll_up_Judge_NS__c);

        Test.stopTest();
    }
    
    @isTest static void runPositivePath_Commit_OneManagerLine() {
        List<User> largeUserTeam1;
        List<Seller__c> largeSellerTeam1;
        List<Yearly_Target__c> largeSellerteamYT1;
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            // Returns list of users
            largeUserTeam1 = Test_DataFactory.createLargeUserTeam();

            // Returns list of sellers
            largeSellerTeam1 = Test_DataFactory.createLargeSellerTeam(largeUserTeam1,Date.today());

            // Returns list of yearly targets
            largeSellerteamYT1 = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam1);
        }

        /*
        Seller hierarchy:
        SEL1 -> STM1 -> SUD1 -> BUM1 -> BAM1
        */

        User businessAreaManager1 = largeUserTeam1[0];
        User businessUnitManager1 = largeUserTeam1[1];
        User salesUnitDirector1 = largeUserTeam1[2];
        User salesTeamManager1 = largeUserTeam1[3];
        User seller = largeUserTeam1[4];        

        String week = SEUtility.getWeekNumberAsString(Date.today());

        // Weekly Forecast Items for the current week
        List<Weekly_Forecast_Item__c> wfis = 
            [SELECT Seller__c,Seller__r.Manager__c,Name, Continuation_Sales_Commit__c,New_Sales_Commit__c,
            Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c
            FROM Weekly_Forecast_Item__c
            WHERE Name = :week];

        Map<Id,Weekly_Forecast_Item__c> sellerwfi = new Map<Id,Weekly_Forecast_Item__c>();
        for (Weekly_Forecast_Item__c wfi : wfis) {
            sellerwfi.put(wfi.Seller__c, wfi);
        }

        System.assertEquals(week,wfis[0].Name); 
        System.assertNotEquals(0,wfis.size());
        Seller__c stm1 = [SELECT Id,Manager__c FROM Seller__c WHERE Id = :largeSellerTeam1[3].Id limit 1][0];
        System.assertEquals(stm1.Manager__c,largeSellerTeam1[2].Id);

        //Test.startTest();

        System.runAs(seller) {
            List<Weekly_Forecast_Item__c> wfisToUpdate = new List<Weekly_Forecast_Item__c>();
            Weekly_Forecast_Item__c wfiSEL1 = sellerwfi.get(largeSellerTeam1[4].Id);
            wfiSEL1.New_Sales_Commit__c = 23561.0;
            wfiSEL1.Continuation_Sales_Commit__c = 45672.0; 
            wfisToUpdate.add(wfiSEL1);

            Weekly_Forecast_Item__c wfiSTM1 = sellerwfi.get(largeSellerTeam1[3].Id);
            wfiSTM1.New_Sales_Commit__c = 1000.0;
            wfiSTM1.Continuation_Sales_Commit__c = 2000.0; 
            wfisToUpdate.add(wfiSTM1);
            Test.startTest();
            update wfisToUpdate;
            
            Test.stopTest();
        }

        Weekly_Forecast_Item__c wfiSEL1_1 = 
        [SELECT id,New_Sales_Commit__c,Continuation_Sales_Commit__c 
        FROM Weekly_Forecast_Item__c 
        WHERE Seller__c = :largeSellerTeam1[4].Id and Name = :week limit 1][0];
        System.assertEquals(23561.0, wfiSEL1_1.New_Sales_Commit__c);
        System.assertEquals(45672.0, wfiSEL1_1.Continuation_Sales_Commit__c);        

        Weekly_Forecast_Item__c wfiSTM1 = 
        [SELECT id, New_Sales_Commit__c,Continuation_Sales_Commit__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c 
        FROM Weekly_Forecast_Item__c 
        WHERE Seller__c = :largeSellerTeam1[3].Id and Name = :week limit 1][0];
        System.assertEquals(wfiSEL1_1.New_Sales_Commit__c, wfiSTM1.Subordinates_Commit_New_Sales__c);
        System.assertEquals(wfiSEL1_1.Continuation_Sales_Commit__c, wfiSTM1.Subordinates_Commit_Continuation_Sales__c);

        Weekly_Forecast_Item__c wfiSUD1 = 
        [SELECT id, New_Sales_Commit__c,Continuation_Sales_Commit__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c 
        FROM Weekly_Forecast_Item__c 
        WHERE Seller__c = :largeSellerTeam1[2].Id and Name = :week limit 1][0];
        System.assertEquals(wfiSTM1.New_Sales_Commit__c + wfiSTM1.Subordinates_Commit_New_Sales__c, wfiSUD1.Subordinates_Commit_New_Sales__c);
        System.assertEquals(wfiSTM1.Continuation_Sales_Commit__c + wfiSTM1.Subordinates_Commit_Continuation_Sales__c, wfiSUD1.Subordinates_Commit_Continuation_Sales__c);

        Weekly_Forecast_Item__c wfiBUM1 = 
        [SELECT id, New_Sales_Commit__c,Continuation_Sales_Commit__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c 
        FROM Weekly_Forecast_Item__c 
        WHERE Seller__c = :largeSellerTeam1[1].Id and Name = :week limit 1][0];
        System.assertEquals(wfiSUD1.New_Sales_Commit__c + wfiSUD1.Subordinates_Commit_New_Sales__c, wfiBUM1.Subordinates_Commit_New_Sales__c);
        System.assertEquals(wfiSUD1.Continuation_Sales_Commit__c + wfiSUD1.Subordinates_Commit_Continuation_Sales__c, wfiBUM1.Subordinates_Commit_Continuation_Sales__c);        

        Weekly_Forecast_Item__c wfiBAM1 = 
        [SELECT id, New_Sales_Commit__c,Continuation_Sales_Commit__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c 
        FROM Weekly_Forecast_Item__c 
        WHERE Seller__c = :largeSellerTeam1[0].Id and Name = :week limit 1][0];
        System.assertEquals(wfiBUM1.New_Sales_Commit__c + wfiBUM1.Subordinates_Commit_New_Sales__c, wfiBAM1.Subordinates_Commit_New_Sales__c);
        System.assertEquals(wfiBUM1.Continuation_Sales_Commit__c + wfiBUM1.Subordinates_Commit_Continuation_Sales__c, wfiBAM1.Subordinates_Commit_Continuation_Sales__c);

       // Test.stopTest();

    }

    @isTest static void runPositivePath_Judge_YearlyTeargetsThisAndNextYear() {

        List<User> largeUserTeam1;
        List<Seller__c> largeSellerTeam1;
        List<Yearly_Target__c> largeSellerteamYT1;
        List<Yearly_Target__c> largeSellerteamYT2;
        Decimal thisYear = System.today().year();
        Decimal nextYear = System.today().year() + 1.0;
        String thisYearString = String.valueOf(System.today().year());
        String nextYearString = String.valueOf(System.today().year() + 1);

        System.runAs(new User(Id = Userinfo.getUserId())){
            // Returns list of users
            largeUserTeam1 = Test_DataFactory.createLargeUserTeam();

            // Returns list of sellers
            largeSellerTeam1 = Test_DataFactory.createLargeSellerTeam(largeUserTeam1,Date.today());

            // Returns list of yearly targets

            largeSellerteamYT1 = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam1, thisYearString);
            largeSellerteamYT2 = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam1, nextYearString);
        }

        User businessAreaManager1 = largeUserTeam1[0];
        User businessUnitManager1 = largeUserTeam1[1];
        User salesUnitDirector1 = largeUserTeam1[2];
        User salesTeamManager1 = largeUserTeam1[3];

        String week = SEUtility.getWeekNumberAsString(Date.today());

        // Weekly Forecast Items for the current week
        List<Weekly_Forecast_Item__c> wfis = 
            [SELECT Seller__c,Seller__r.Manager__c,Name,Judge_CS__c,Judge_NS__c,Seller__r.Type__c,Roll_up_Judge_NS__c,Roll_up_Judge_CS__c, Belongs_To_Year__c
            FROM Weekly_Forecast_Item__c
            WHERE Name = :week AND Belongs_To_Year__c = :thisYear];

        Map<Id,Weekly_Forecast_Item__c> sellerwfi = new Map<Id,Weekly_Forecast_Item__c>();
        for (Weekly_Forecast_Item__c wfi : wfis) {
            sellerwfi.put(wfi.Seller__c, wfi);
        }

       // Test.startTest();

        System.runAs(salesTeamManager1) {
            Weekly_Forecast_Item__c wfiSTM1 = sellerwfi.get(largeSellerTeam1[3].Id);
            wfiSTM1.Judge_CS__c = 10.0;
            Test.startTest();
            update wfiSTM1;
            Test.stopTest();
        }

        Weekly_Forecast_Item__c wfiSTM11 = [SELECT id, Judge_CS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[3].Id AND Name = :week AND Belongs_To_Year__c = :thisYear limit 1][0];
        System.assertEquals(10.0, wfiSTM11.Judge_CS__c);

        Weekly_Forecast_Item__c wfiSUD1 = [SELECT id, Judge_CS__c, Roll_up_Judge_CS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[2].Id and Name = :week AND Belongs_To_Year__c = :thisYear limit 1][0];
        System.assertEquals(wfiSTM11.Judge_CS__c, wfiSUD1.Roll_up_Judge_CS__c);

        Weekly_Forecast_Item__c wfiBUM1 = [SELECT id, Judge_CS__c, Roll_up_Judge_CS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[1].Id and Name = :week AND Belongs_To_Year__c = :thisYear limit 1][0];
        System.assertEquals(wfiSUD1.Judge_CS__c + wfiSUD1.Roll_up_Judge_CS__c, wfiBUM1.Roll_up_Judge_CS__c);

        Weekly_Forecast_Item__c wfiBAM1 = [SELECT id, Judge_CS__c, Roll_up_Judge_CS__c FROM Weekly_Forecast_Item__c WHERE Seller__c = :largeSellerTeam1[0].Id and Name = :week AND Belongs_To_Year__c = :thisYear limit 1][0];
        System.assertEquals(wfiBUM1.Judge_CS__c + wfiBUM1.Roll_up_Judge_CS__c, wfiBAM1.Roll_up_Judge_CS__c);
        
        //Test.stopTest();

    }
}