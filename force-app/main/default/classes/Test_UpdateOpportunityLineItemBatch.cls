@isTest
private class Test_UpdateOpportunityLineItemBatch{
    
    @isTest static void testBatch(){
      User Byuser;
    
        System.runAs(new User(Id = Userinfo.getUserId())){ 
            Byuser = Test_DataFactory.getByPassUser();
            }
        System.runAs(Byuser){ 
            //Creating Test Opportunity
           List<OpportunityLineItem > lopps = new List<OpportunityLineItem >();
             Opportunity opp = Test_DataFactory.createOpportunity();
             insert opp;
             //Adding OpportunityLineItem without linking it to Buy Interest
            OpportunityLineItem oli = Test_DataFactory.createProductAndOpportunityLineItem(opp.id);
             lopps.add(oli);
         //   insert oli;
             insert lopps;
        }
             
        Test.startTest();
        String query = 'SELECT id, Product_Family__c from OpportunityLineItem WHERE Product_Family__c = null';
        Id batchJobId = Database.executeBatch(new UpdateOpportunityLineItemBatch(query),50);
        Test.stopTest();
    }
}