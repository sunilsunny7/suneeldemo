//******************************************************************************************************************************
// Name             : Test_ManageTwoTeamHandler.cls         
// Created By       : S.S
// Description      : Covers the code coverage of 'ManageTwoTeamHandler' Class & 'NewCommitViewControllerLarge'
// *****************************************************************************************************************************

@isTest
public with sharing class Test_ManageTwoTeamHandler {

    @testSetup
    static void initTestData() 
    {
        Test_DataFactory.setUpOrg();
    }
    
    @isTest static void ManageTwoTeamHandler(){
    
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);
        
        List<User> largeuserTeam;
        List<Seller__c> largesellerteam;
        Id DirectorId,ManagerId,SellerId,sellerUser,managerUser,salesDirectorUser;
      
        List<Id> listofseller = new List<Id>();

        System.runAs(new User(Id = Userinfo.getUserId())){ 
            
            largeuserTeam = Test_DataFactory.createLargeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largesellerteam = Test_DataFactory.createLargeSellerTeam(largeuserTeam,startdate);
            
        }
       
        for(Seller__c s :largesellerteam)
        {
            if(s.Type__c == 'Sales Unit Director')
            {
                DirectorId = s.Id;
                salesDirectorUser = s.User__c;
            }
            else if(s.Type__c == 'Sales Team Manager')
            {
                ManagerId = s.Id;
                managerUser = s.User__c;
            }
            else if(s.Type__c == 'Seller')
            {
                SellerId = s.Id;
                sellerUser = s.User__c;
            }
        }
        
          
       test.starttest();  
       Seller__c seller = new Seller__c();
        seller.id = ManagerId;
        seller.Sales_Team_Name__c = 'Large Enterprise North';
        Update seller;
          /*     
        Seller__c seller5 = new Seller__c();
        seller5.id = ManagerId;
        seller5.Type__c = 'Seller';
        seller5.Start_Date__c = startDate;
        seller5.User__c = Userinfo.getUserId();
        Update seller5;
         */
        Seller__c seller1 = new Seller__c();
        seller1.id = DirectorId;
        seller1.Sales_Team_Name__c = 'Large Enterprise South';
        Update seller1;
        
        Seller__c seller2 = new Seller__c();
        seller2.Manager__c = DirectorId;
        seller2.Type__c = 'Seller';
        seller2.Start_Date__c = startDate;
        seller2.User__c = Userinfo.getUserId();
        insert seller2;
        
         /*       
        Seller__c seller3 = new Seller__c();
        seller3.Manager__c = DirectorId;
        seller3.Type__c = 'Seller';
        seller3.Start_Date__c = startDate;
        seller3.User__c = sellerUser;
        insert seller3;
         */ 
        Account acc1 = Test_DataFactory.createOneLargeStandardAccount();
       // acc.OwnerId = salesRep.Id;
        insert acc1;
        
        Opportunity opp = Test_DataFactory.createLargeOpportunity();
        opp.AccountId = acc1.Id;
        opp.Seller__c = seller2.id;
        insert opp;
    /*
        Account acc = Test_DataFactory.createOneLargeStandardAccount();
        //acc.OwnerId = salesRep1.Id;
        insert acc;
        
        Opportunity opp1 = Test_DataFactory.createLargeOpportunity();
        opp1.AccountId = acc.Id;
        opp1.Seller__c = seller3.id;
        insert opp1;
       */
       
        
        Seller__c seller6 = new Seller__c();
        //seller6.Manager__c = SellerId;
        seller6.Type__c = 'Sales Team Manager';
        seller6.Sales_Team_Name__c = 'Large Enterprise South';
        seller6.Start_Date__c = startDate;
        seller6.User__c = sellerUser;
        insert seller6;
         
         
         test.stoptest();
        Seller__c updatesalesteammanager = new Seller__c();
        updatesalesteammanager.Manage_Other_Team__c = 'Large Enterprise South';
        updatesalesteammanager.id = seller.id;
        update updatesalesteammanager;
           
        
         
        System.runAs(new User(Id = Userinfo.getUserId())){  
       
            NewCommitViewControllerLarge controller = new NewCommitViewControllerLarge();
            controller.saveJudge();
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved');
            controller.radioValue = 'SecondaryUserView';
            controller.getWeekInstances();
            
            controller.saveJudge();
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved');
        }
        
        Seller__c updatesalesteammanager1 = new Seller__c();
        updatesalesteammanager1.Manage_Other_Team__c = null;
        updatesalesteammanager1.id = seller.id;
        update updatesalesteammanager1;
        
  
    }
}