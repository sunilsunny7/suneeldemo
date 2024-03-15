@isTest
private class Test_UpdateWeeklyForecastScheduled {
	
	@isTest static void testScheduledBatch(){
		Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
	        // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
	        smeUserTeam = Test_DataFactory.createSmeUserTeam();
	        smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
	        // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller} with weekly forecast items
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);
	    }
	    Date lastWeekDate = system.today().addDays(-7);
	    List<Weekly_Forecast_Item__c> wfiList = [SELECT Id, isWeekInPast__c, End_Date__c
												FROM Weekly_Forecast_Item__c 
												WHERE End_Date__c < :lastWeekDate limit 1];
		// Note that if run the first week of the year this test might fail as the newly created yearly targets does not contain any weekly forecasts in the last week.
		// Verifying that at least one wfi is found:
		if(wfiList != null && wfiList.size() > 0){
			Weekly_Forecast_Item__c wfi = wfiList[0];
			wfi.isWeekInPast__c = false;
			update wfi;						
	        
	        Test.startTest();
		        String CRON_EXP = '0 0 3 ? * SUN *';
		    	Id scheduledJobId = System.schedule('UpdateWeeklyForecastWeekInPastScheduled', CRON_EXP, new UpdateWeeklyForecastWeekInPastScheduled());
				System.debug(scheduledJobId);
				// Because this is a test, job executes
				// immediately after Test.stopTest().
	        Test.stopTest();
	        
	        List<Weekly_Forecast_Item__c> wfiListAfter = [SELECT Id, isWeekInPast__c, End_Date__c
													FROM Weekly_Forecast_Item__c 
													WHERE id = :wfi.Id limit 1];       
	        System.assertEquals(wfiListAfter[0].isWeekInPast__c, true, 'There are no FOl records');
    	}
    }
	
}