@isTest
public with sharing class Test_AgreementSituationController{

    
    @isTest static void AgreementSituationtController(){
       
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
       // acc.OwnerId = salesRep.Id;
        insert acc1;

        List<Agreement_Situation__c> insertlistofagreementsituationOnkknr = new List<Agreement_Situation__c>();           
        Agreement_Situation__c agre1 = new Agreement_Situation__c();
        agre1.Agreement_Category__c = 'Networks - Mobile Telephony';
        agre1.Supplier__c = 'Telia';
        agre1.KKnr__c = acc1.id;
        agre1.End_Date__c = system.today();
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
          
        insert insertlistofagreementsituationOnkknr;
        
        PageReference pageRef = Page.AgreementSituation;
        Test.setCurrentPage(pageRef);
        
        Apexpages.StandardController stdController = new Apexpages.StandardController(acc1);
        AgreementSituationController controller = new AgreementSituationController(stdController);
        
        
        controller.EditAgreementSituations();
        controller.cancelAgreementSituation();
        controller.save();
        
      }      
    
}