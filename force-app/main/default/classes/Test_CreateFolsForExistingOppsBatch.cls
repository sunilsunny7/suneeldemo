@isTest
private class Test_CreateFolsForExistingOppsBatch {
	
    /*
	@isTest static void testBatch(){
        
        List<User> smeUserTeam;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
	        // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
	        smeUserTeam = Test_DataFactory.createSmeUserTeam();
	    }

        User salesRep = smeUserTeam[2];
        
        System.runAs(salesRep){
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            List<Seller__c> smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);

            Opportunity opp = Test_DataFactory.createSmeWonOpportunityNewSales();
        }
        
        Test.startTest();
    	Id batchJobId = Database.executeBatch(new CreateFolsForExistingOppsBatch(true, false));
        Test.stopTest();
        
        Opportunity opp = [Select  Id, Seller__c, (SELECT Id FROM Forecast_Opportunity_Links__r) from Opportunity][0];        
        System.assertNotEquals(opp.Forecast_Opportunity_Links__r, null, 'There are no FOl records');
    }
	*/
}