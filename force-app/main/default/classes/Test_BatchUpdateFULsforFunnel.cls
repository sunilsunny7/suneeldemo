@isTest
private class Test_BatchUpdateFULsforFunnel {
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }
  
    @isTest static void testBatch(){
        
        List<User> largeUserTeam;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
          // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
          largeUserTeam = Test_DataFactory.createLargeUserTeam();
          List<seller__c> largeSellerTeam1 = Test_DataFactory.createLargeSellerTeam(largeUserTeam,Date.today());

            // Returns list of yearly targets
      List<yearly_target__c> largeSellerteamYT1 = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam1);
      }
      
       date toDate = system.today();
      //List<seller__c> sellerList = Test_DataFactory.createLargeSellerTeam(largeUserTeam,toDate);
      /*seller__c seller = Test_DataFactory.createSeller(largeUserTeam[0].Id,null);
      insert seller;
      //yearly_target__c yt = Test_DataFactory.createOneSpecificYearlyTargetSeller(2018, largeUserTeam[0].Id, '01', 100, 100, 100);
      yearly_target__c yt = Test_DataFactory.createOneYearlyTarget(seller);
      yt.Full_Year_New_Sales_Target__c = 100;
      yt.Full_Year_Continuation_Sales_Target__c  = 200;
      yt.Full_Year_Sales_Value_Target__c = 300;
      yt.startweek__c = '01';
      insert yt;
      //largeUserTeam1 = Test_DataFactory.createLargeUserTeam();
*/
      // Returns list of sellers
      /*List<seller__c> largeSellerTeam1 = Test_DataFactory.createLargeSellerTeam(largeUserTeam,Date.today());

            // Returns list of yearly targets
      List<yearly_target__c> largeSellerteamYT1 = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam1);*/
      Account acc = Test_DataFactory.createOneLargeStandardAccount();
                acc.OwnerId = largeUserTeam[0].Id;
                insert acc;

        User salesRep = largeUserTeam[0];
        
        Test_DataFactory.createPriceBooks();
        List<Opportunity> oppList = new List<Opportunity>();
        
        System.runAs(salesRep){
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
           
            //List<Seller__c> largeSellerTeam = Test_DataFactory.createLargeSellerTeam(largeUserTeam,toDate);
            Test.startTest();
            Opportunity opp = Test_DataFactory.createlargeOpportunity();
            //opp.OwnerId = largeuserTeam[0].Id;
            opp.AccountId = acc.Id;
            opp.CloseDate = system.today();
            oppList.add(opp);
            //insert opp;
            
            Opportunity opp2 = Test_dataFactory.createlargeOpportunity();
            opp2.Accountid = acc.Id;
            opp2.CloseDate = system.today().addDays(370);
            oppList.add(opp2);
            insert opplist;
        }
        List<Funnel_Link__c> fulList = [select Included_in_Funnel__c,id,opportunity__C from Funnel_Link__c WHERE Opportunity__c IN: oppList];
        for(Funnel_link__c ful:fulList){
            ful.Included_in_Funnel__c = False;
        }
        update fulList;
        
        Id batchJobId = Database.executeBatch(new BatchUpdateFULsforFunnel());
        Test.stopTest();
        
        //Opportunity opp = [Select  Id, Seller__c, (SELECT Id FROM Forecast_Opportunity_Links__r) from Opportunity][0];        
        //System.assertNotEquals(opp.Forecast_Opportunity_Links__r, null, 'There are no FOl records');
    }
  
}