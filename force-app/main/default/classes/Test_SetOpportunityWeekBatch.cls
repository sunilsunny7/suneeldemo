@isTest
private class Test_SetOpportunityWeekBatch{
    
    @isTest static void testBatch(){
      User Byuser;
    
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Byuser = Test_DataFactory.getByPassUser();
            }
        System.runAs(Byuser){    
           List<Opportunity> lopps = new List<Opportunity>();
             Opportunity opp = Test_DataFactory.createOpportunity();
             opp.closedate = Date.Today() - 5;
             System.debug('Opp.Telia_Week__c' + Opp.Telia_Week__c);
             lopps.add(opp);
             
             Opportunity opp2 = Test_DataFactory.createOpportunity();
             opp2.Telia_Week__c = 12;
             System.debug('Opp2.Telia_Week__c' + Opp2.Telia_Week__c);
             lopps.add(opp2);
             
             insert lopps;
             //Resetting Telia_Week__c to null as it is auto updating through trigger as well
             opp.Telia_Week__c = null;
             //opp2.Telia_Week__c = null;
             update opp;
                     
        //String query = 'Select Id, Telia_Week__c, CloseDate from Opportunity WHERE Telia_Week__c = null';
        //System.debug('Test_Query: ' +query);
        }
        Test.startTest();
        Id batchJobId = Database.executeBatch(new SetOpportunityWeekBatch(),50);
        Test.stopTest();
        Opportunity oppt = [SELECT id, Telia_Week__c, CloseDate from Opportunity WHERE Telia_Week__c != null LIMIT 1];
        System.debug('Telia_Week__c : ' +oppt.Telia_Week__c );
        System.assertNotEquals(null, oppt.Telia_Week__c, 'Telia Week has been updated');

   }
}