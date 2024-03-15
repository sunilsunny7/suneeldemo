@isTest
public with sharing class Test_RevenueTriggerHandler {

    public static testmethod void testAddRevenue(){
      Account acc = Test_DataFactory.createOneKundkontoAccount();
      insert acc;
      Account accNoRevenue = [SELECT id, Revenue_YTD_Current_Year__c, Revenue_YTD_record_count__c  FROM Account Limit 1];
      System.assertEquals(accNoRevenue.Revenue_YTD_Current_Year__c, 0);
      System.assertEquals(accNoRevenue.Revenue_YTD_record_count__c, 0);

      Revenue__c rev = Test_DataFactory.createRevenue(acc.Id);
      Decimal revAmount = 1000.0;
      rev.Account__c = acc.Id;
      rev.RevenueAmount__c = revAmount;
      insert rev;

      Account accWithRevenue = [SELECT id, Revenue_YTD_Current_Year__c, Revenue_YTD_record_count__c FROM Account Limit 1];
      System.assertEquals(accWithRevenue.Revenue_YTD_Current_Year__c, revAmount);
      System.assertEquals(accWithRevenue.Revenue_YTD_record_count__c, 1);
    }

    public static testmethod void testCompareRevenues(){
      Account acc = Test_DataFactory.createOneKundkontoAccount();
      insert acc;

      Integer thisYear = System.today().year();
      Integer lastYear = thisYear - 1;
      List<Revenue__c> revLastYearList = Test_DataFactory.createRevenues(acc.Id, lastYear, 1, 12, 100);
      insert revLastYearList;

      List<Revenue__c> revThisYearList = Test_DataFactory.createRevenues(acc.Id, thisYear, 1, 6, 100);
      insert revThisYearList;

      Account accWithRevenue = [SELECT id, Revenue_YTD_Current_Year__c, Revenue_YTD_record_count__c, Revenue_YTD_Previous_Year__c, 
                  Revenue_Previous_Year__c,Revenue_change_last_year__c FROM Account Limit 1];
      System.assertEquals(accWithRevenue.Revenue_YTD_Current_Year__c, 600);
      System.assertEquals(accWithRevenue.Revenue_YTD_record_count__c, 6);
      System.assertEquals(accWithRevenue.Revenue_YTD_Previous_Year__c, 600);
      System.assertEquals(accWithRevenue.Revenue_Previous_Year__c, 1200);
      System.assertEquals(accWithRevenue.Revenue_change_last_year__c, 0);

      Revenue__c revThisYearJuly = Test_DataFactory.createRevenue(acc.Id, thisYear, 7, 200);
      insert revThisYearJuly;

      Account accWithRevenue2 = [SELECT id, Revenue_YTD_Current_Year__c, Revenue_YTD_record_count__c, Revenue_YTD_Previous_Year__c, 
            Revenue_Previous_Year__c,Revenue_change_last_year__c FROM Account Limit 1];
      System.assertEquals(accWithRevenue2.Revenue_YTD_Current_Year__c, 800);
      System.assertEquals(accWithRevenue2.Revenue_YTD_record_count__c, 7);
      System.assertEquals(accWithRevenue2.Revenue_YTD_Previous_Year__c, 700);
      System.assertEquals(accWithRevenue2.Revenue_Previous_Year__c, 1200);
      System.assertEquals(accWithRevenue2.Revenue_change_last_year__c, (800-700)/7);
    }

    // Revenue files are imported monthly with the data loader with a batch size of 200.
    public static testmethod void testMultipleAccountsRevenues(){
      Integer noOfAccs = 10;

      List<Account> accList = new List<Account>();
      for(integer i=0; i<noOfAccs; i++){
            accList.add(Test_DataFactory.createOneKundkontoAccount());
        }
               Test.startTest();
      insert accList;

 
      Integer thisYear = System.today().year();
      Integer lastYear = thisYear - 1;
      List<Revenue__c> revLastYearList = new List<Revenue__c>();
      for(Account acc : accList){
        revLastYearList.add(Test_DataFactory.createRevenue(acc.Id, lastYear, 1, 100));
      }
      insert revLastYearList;

      List<Revenue__c> revThisYearList = new List<Revenue__c>();
      for(Account acc : accList){
        revThisYearList.add(Test_DataFactory.createRevenue(acc.Id, thisYear, 1, 150));
      }
      insert revThisYearList;
        Test.stopTest();

      List<Account> accWithRevenueList = [SELECT id, Revenue_YTD_Current_Year__c, Revenue_YTD_record_count__c, Revenue_YTD_Previous_Year__c, 
                  Revenue_Previous_Year__c,Revenue_change_last_year__c FROM Account Limit 200];
     System.assertEquals(accWithRevenueList[0].Revenue_YTD_Current_Year__c, 150);
     System.assertEquals(accWithRevenueList[0].Revenue_YTD_record_count__c, 1);
     System.assertEquals(accWithRevenueList[0].Revenue_YTD_Previous_Year__c, 100);
     System.assertEquals(accWithRevenueList[0].Revenue_Previous_Year__c, 100);
    System.assertEquals(accWithRevenueList[0].Revenue_change_last_year__c, 50);
    }

    public static testmethod void testUpdateRevenues(){
        Account acc = Test_DataFactory.createOneKundkontoAccount();
        insert acc;

        Integer thisYear = System.today().year();
        Integer lastYear = thisYear - 1;
        
        Revenue__c revLastYear = Test_DataFactory.createRevenue(acc.Id, lastYear, 1, 100);
        insert revLastYear;

        Revenue__c revThisYear = Test_DataFactory.createRevenue(acc.Id, thisYear, 1, 100);
        insert revThisYear;

        Account accWithRevenue = [SELECT id, Revenue_YTD_Current_Year__c, Revenue_YTD_record_count__c, Revenue_YTD_Previous_Year__c, 
                                Revenue_Previous_Year__c,Revenue_change_last_year__c FROM Account Limit 1];
        System.assertEquals(accWithRevenue.Revenue_YTD_Current_Year__c, 100);
        System.assertEquals(accWithRevenue.Revenue_YTD_record_count__c, 1);
        System.assertEquals(accWithRevenue.Revenue_YTD_Previous_Year__c, 100);
        System.assertEquals(accWithRevenue.Revenue_Previous_Year__c, 100);
        System.assertEquals(accWithRevenue.Revenue_change_last_year__c, 0);

        revThisYear.RevenueAmount__c = 150;
        update revThisYear;

        Account accWithRevenue2 = [SELECT id, Revenue_YTD_Current_Year__c, Revenue_YTD_record_count__c, Revenue_YTD_Previous_Year__c, 
                        Revenue_Previous_Year__c,Revenue_change_last_year__c FROM Account Limit 1];
        System.assertEquals(accWithRevenue2.Revenue_YTD_Current_Year__c, 150);
        System.assertEquals(accWithRevenue2.Revenue_YTD_record_count__c, 1);
        System.assertEquals(accWithRevenue2.Revenue_YTD_Previous_Year__c, 100);
        System.assertEquals(accWithRevenue2.Revenue_Previous_Year__c, 100);
        System.assertEquals(accWithRevenue2.Revenue_change_last_year__c, 50);
    }

    public static testmethod void testDeleteRevenues(){
      Account acc = Test_DataFactory.createOneKundkontoAccount();
      insert acc;

      Integer thisYear = System.today().year();
      Integer lastYear = thisYear - 1;
      
      Revenue__c revLastYear = Test_DataFactory.createRevenue(acc.Id, lastYear, 1, 100);
      insert revLastYear;

      Revenue__c revThisYear = Test_DataFactory.createRevenue(acc.Id, thisYear, 1, 100);
      insert revThisYear;

      Account accWithRevenue = [SELECT id, Revenue_YTD_Current_Year__c, Revenue_YTD_record_count__c, Revenue_YTD_Previous_Year__c, 
                  Revenue_Previous_Year__c,Revenue_change_last_year__c FROM Account Limit 1];
      System.assertEquals(accWithRevenue.Revenue_YTD_Current_Year__c, 100);
      System.assertEquals(accWithRevenue.Revenue_YTD_record_count__c, 1);
      System.assertEquals(accWithRevenue.Revenue_YTD_Previous_Year__c, 100);
      System.assertEquals(accWithRevenue.Revenue_Previous_Year__c, 100);
      System.assertEquals(accWithRevenue.Revenue_change_last_year__c, 0);

      delete revLastYear;
      delete revThisYear;

      Account accWithRevenue2 = [SELECT id, Revenue_YTD_Current_Year__c, Revenue_YTD_record_count__c, Revenue_YTD_Previous_Year__c, 
            Revenue_Previous_Year__c,Revenue_change_last_year__c FROM Account Limit 1];
      System.assertEquals(accWithRevenue2.Revenue_YTD_Current_Year__c, 0);
      System.assertEquals(accWithRevenue2.Revenue_YTD_record_count__c, 0);
      System.assertEquals(accWithRevenue2.Revenue_YTD_Previous_Year__c, 0);
      System.assertEquals(accWithRevenue2.Revenue_Previous_Year__c, 0);
      System.assertEquals(accWithRevenue2.Revenue_change_last_year__c, 0);
    }
}