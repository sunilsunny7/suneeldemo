@isTest
private class Test_CopyOpportunityAmountBatch {
    
    
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

            //Opportunity opp = Test_DataFactory.createSmeWonOpportunityNewSales();
            Opportunity opp = Test_DataFactory.createSmeOpportunity();
            insert opp;
        }
        
        Test.startTest();
        Id batchJobId = Database.executeBatch(new CopyOpportunityAmountBatch(), 50);
       
        Test.stopTest();
        
        Opportunity opp = [Select Id, Large_New_Sales__c, Large_Continuation_Sales__c, Winback_Revenue_12_month__c, Retain_Revenue_12_month__c from Opportunity][0];        
       // System.assertEquals(opp.Large_New_Sales__c , opp.Winback_Revenue_12_month__c, 'Large new sales was not set');
       System.assertEquals(opp.Large_Continuation_Sales__c , opp.Retain_Revenue_12_month__c, 'Large continuation sales was not set');
    }
    
}