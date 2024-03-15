@isTest
public with sharing class Test_IntaktController{

    
    @isTest static void IntaktcuController(){
        Integer currentYear, lastyear;
        currentYear = System.Today().year();
        lastyear = system.today().year()-1;
        
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
       // acc.OwnerId = salesRep.Id;
        insert acc1;

        List<Revenue__c> insertlistrevenueOnkknr = new List<Revenue__c>();           
        Revenue__c rev = new Revenue__c();
        rev.RevenueAmount__c = 123;
        rev.Name = currentYear + '-' + '03';
        rev.Account__c = acc1.id;
        rev.Date__c = system.today();
        insertlistrevenueOnkknr.add(rev);
        
        Revenue__c rev1 = new Revenue__c();
        rev1.RevenueAmount__c = 123;
        rev1.Name = lastyear + '-' + '01';
        rev1.Account__c = acc1.id;
        rev1.Date__c = system.today()-180;
        insertlistrevenueOnkknr.add(rev1);
        
        Revenue__c rev2 = new Revenue__c();
        rev2.RevenueAmount__c = 123;
        rev2.Name = currentyear + '-' + '02';
        rev2.Account__c = acc1.id;
        rev2.Date__c = system.today()-30;
        insertlistrevenueOnkknr.add(rev2);
        
        Revenue__c rev3 = new Revenue__c();
        rev3.RevenueAmount__c = 123;
        rev3.Name = lastyear + '-' + '01';
        rev3.Account__c = acc1.id;
        rev3.Date__c = system.today()-210;
        insertlistrevenueOnkknr.add(rev3);
        
        Revenue__c rev4 = new Revenue__c();
        rev4.RevenueAmount__c = 123;
        rev4.Name = lastyear + '-' + '01';
        rev4.Account__c = acc1.id;
        rev4.Date__c = system.today()-240;
        insertlistrevenueOnkknr.add(rev4);
        
        Revenue__c rev5 = new Revenue__c();
        rev5.RevenueAmount__c = 123;
        rev5.Name = lastyear + '-' + '01';
        rev5.Account__c = acc1.id;
        rev5.Date__c = system.today()-270;
        insertlistrevenueOnkknr.add(rev5);
        
        Revenue__c rev6 = new Revenue__c();
        rev6.RevenueAmount__c = 123;
        rev6.Name = lastyear + '-' + '01';
        rev6.Account__c = acc1.id;
        rev6.Date__c = system.today()-300;
        insertlistrevenueOnkknr.add(rev6);
        
        Revenue__c rev7 = new Revenue__c();
        rev7.RevenueAmount__c = 123;
        rev7.Name = lastyear + '-' + '01';
        rev7.Account__c = acc1.id;
        rev7.Date__c = system.today()-60;
        insertlistrevenueOnkknr.add(rev7);
        
        Revenue__c rev8 = new Revenue__c();
        rev8.RevenueAmount__c = 123;
        rev8.Name = lastyear + '-' + '01';
        rev8.Account__c = acc1.id;
        rev8.Date__c = system.today()-90;
        insertlistrevenueOnkknr.add(rev8);
        
        Revenue__c rev9 = new Revenue__c();
        rev9.RevenueAmount__c = 123;
        rev9.Name = lastyear + '-' + '01';
        rev9.Account__c = acc1.id;
        rev9.Date__c = system.today()-120;
        insertlistrevenueOnkknr.add(rev9);
        
        Revenue__c rev10 = new Revenue__c();
        rev10.RevenueAmount__c = 123;
        rev10.Name = lastyear + '-' + '01';
        rev10.Account__c = acc1.id;
        rev10.Date__c = system.today()-150;
        insertlistrevenueOnkknr.add(rev10);
        
        insert insertlistrevenueOnkknr;
        
        Apexpages.StandardController controller = new Apexpages.StandardController(acc1);
        ApexPages.currentPage().getParameters().put('ID',acc1.id);

        IntaktController controller1 = new IntaktController(controller);
        controller1.getcurrentyrJanRevenue();
        controller1.getcurrentyrFebRevenue();
        controller1.getcurrentyrMarRevenue();
        controller1.getcurrentyrAprRevenue();
        controller1.getcurrentyrMayRevenue();
        controller1.getcurrentyrJunRevenue();
        controller1.getcurrentyrJulRevenue();
        controller1.getcurrentyrAugRevenue();
        controller1.getcurrentyrSepRevenue();
        controller1.getcurrentyrOctRevenue();
        controller1.getcurrentyrNovRevenue();
        controller1.getcurrentyrDecRevenue();
        controller1.getlastyrJanRevenue();
        controller1.getlastyrFebRevenue();
        controller1.getlastyrMarRevenue();
        controller1.getlastyrAprRevenue();
        controller1.getlastyrMayRevenue();
        controller1.getlastyrJunRevenue();
        controller1.getlastyrJulRevenue();
        controller1.getlastyrAugRevenue();
        controller1.getlastyrSepRevenue();
        controller1.getlastyrOctRevenue();
        controller1.getlastyrNovRevenue();
        controller1.getlastyrDecRevenue();
        controller1.getdiffJanRevenue();
        controller1.getdiffFebRevenue();
        controller1.getdiffMarRevenue();
        controller1.getdiffAprRevenue();
        controller1.getdiffMayRevenue();
        controller1.getdiffJunRevenue();
        controller1.getdiffJulRevenue();
        controller1.getdiffAugRevenue();
        controller1.getdiffSeptRevenue();
        controller1.getdiffOctRevenue();
        controller1.getdiffNovRevenue();
        controller1.getdiffDecRevenue();
        
    }
}