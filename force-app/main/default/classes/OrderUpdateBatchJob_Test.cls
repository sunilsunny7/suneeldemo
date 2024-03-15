@isTest
public with sharing class OrderUpdateBatchJob_Test {
@isTest
    public static void testmethod2(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            
            
            //Creating account
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced RA';
            acc.Org_Nr__c  = '5564110665';
            acc.Name = 'R21.4_Test_CO_Acc_Grouping';
            acc.Has_Orders__c = true;
            insert acc;
    }
        OrderUpdateBatchJob jobInst = new OrderUpdateBatchJob();
        Database.executeBatch(jobInst);
    }
}