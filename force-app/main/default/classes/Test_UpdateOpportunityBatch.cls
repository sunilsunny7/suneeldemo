@isTest
private class Test_UpdateOpportunityBatch{
    
    @isTest static void testBatch(){
      User Byuser;
    
        System.runAs(new User(Id = Userinfo.getUserId())){ 
            Byuser = Test_DataFactory.getByPassUser();
            }
        System.runAs(Byuser){ 
            //Creating Test Opportunity
           List<Opportunity> lopps = new List<Opportunity>();
             Opportunity opp = Test_DataFactory.createOpportunity();
             lopps.add(opp);
             
             insert lopps;
        }
             
        Test.startTest();
        String query = 'SELECT id,name from opportunity';
        Id batchJobId = Database.executeBatch(new UpdateOpportunityBatch(query),50);
        Test.stopTest();
    }
}