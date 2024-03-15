@isTest
public with sharing class Test_BatchToRollupASPercentageonKKNR{

@isTest static void BatchToRollupASPercentageonKKNR(){
    
        List<Account> listofaccount = new List<Account>();
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
       // acc.OwnerId = salesRep.Id;
        listofaccount.add(acc1);
        
       Account acc2 = new Account(Name='TestAccount 123');
        acc2.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
       
        acc2.Kundkonto_Nr__c = 'abc' + 00;
        acc2.Business_Unit__c = 'SOHO';
        listofaccount.add(acc2);
        insert listofaccount; 
        List<Agreement_Situation__c> insertlistofagreementsituationOnkknr = new List<Agreement_Situation__c>();
        
          
        Agreement_Situation__c agre1 = new Agreement_Situation__c();
        agre1.Agreement_Category__c = 'Networks - Mobile Telephony';
        agre1.Supplier__c = 'Telia';
        agre1.KKnr__c = acc1.id;
        agre1.End_Date__c = system.today() - 1;
        insertlistofagreementsituationOnkknr.add(agre1);
        Agreement_Situation__c agre2 = new Agreement_Situation__c();
        agre2.Agreement_Category__c = 'Networks - Fixed Telephony';
        agre2.Supplier__c = 'Telenor';
        agre2.KKnr__c = acc1.id;
        agre2.End_Date__c = system.today();
        insertlistofagreementsituationOnkknr.add(agre2);
        Agreement_Situation__c agre3 = new Agreement_Situation__c();
        agre3.Agreement_Category__c = 'Collaboration&UC-Cloud Com Solutions';
        agre3.KKnr__c = acc1.id;
        agre3.Supplier__c = 'Tele2';
        agre3.End_Date__c = system.today();
        insertlistofagreementsituationOnkknr.add(agre3);
        Agreement_Situation__c agre4 = new Agreement_Situation__c();
        agre4.Agreement_Category__c = 'Networks - Broadband';
        agre4.Supplier__c = 'Telavox';
        agre4.KKnr__c = acc1.id;
        agre4.End_Date__c = system.today();
        insertlistofagreementsituationOnkknr.add(agre4);
        Agreement_Situation__c agre5 = new Agreement_Situation__c();
        agre5.Agreement_Category__c = 'Customer Meeting (Contact Center)';
        agre5.Supplier__c = 'Cisco';
        agre5.KKnr__c = acc1.id;
        agre5.End_Date__c = system.today();
        insertlistofagreementsituationOnkknr.add(agre5);
        Agreement_Situation__c agre6 = new Agreement_Situation__c();
        agre6.Agreement_Category__c = 'Equipment';
        agre6.Supplier__c = 'Cisco';
        agre6.KKnr__c = acc2.id;
        agre6.End_Date__c = system.today();
        insertlistofagreementsituationOnkknr.add(agre6);
        Agreement_Situation__c agre7 = new Agreement_Situation__c();
        agre7.Agreement_Category__c = 'Collaboration&UC - Meeting Services';
        agre7.Supplier__c = 'Telia';
        agre7.KKnr__c = acc2.id;
        agre7.End_Date__c = system.today();
        insertlistofagreementsituationOnkknr.add(agre7);
        Agreement_Situation__c agre8 = new Agreement_Situation__c();
        agre8.Agreement_Category__c = 'Services';
        agre8.Supplier__c = 'Tele2';
        agre8.KKnr__c = acc2.id;
        agre8.End_Date__c = system.today() - 1;
        insertlistofagreementsituationOnkknr.add(agre8);
        Agreement_Situation__c agre9 = new Agreement_Situation__c();
        agre9.Agreement_Category__c = 'IT-Service (Cygate) Service';
        agre9.Supplier__c = 'Not applicable for the customer';
        agre9.KKnr__c = acc2.id;
        insertlistofagreementsituationOnkknr.add(agre9);    
        insert  insertlistofagreementsituationOnkknr;
        
        Test.startTest();
        BatchToRollupASPercentageonKKNR  obj = new BatchToRollupASPercentageonKKNR();
        DataBase.executeBatch(obj);             
        Test.stopTest();  
    }
}