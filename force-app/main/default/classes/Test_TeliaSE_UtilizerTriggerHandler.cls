@isTest
public class Test_TeliaSE_UtilizerTriggerHandler{
    public static testmethod void test1(){        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Org_Nr__c = label.Account_Org_N;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
        acc.Telia_Service_Manager__c = userInfo.getUserId();
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='opp1';
        opp.AccountId=acc.Id;
        opp.CloseDate = System.today();
        opp.StageName='Needs Analysis';
        opp.Pricebook2Id=Test.getStandardPricebookId();
        insert opp;
        
        Quote qut1 = new Quote();
        qut1.Name='Test Quote';
        qut1.status = 'Draft';
        qut1.opportunityId = opp.id;
        qut1.TeliaSE_Approval_Flag__c = False; 
        qut1.TeliaSE_Type__c='Renegotiation';
        insert qut1;
        
        Contract conObj = new Contract();
        conObj.vlocity_cmt__QuoteId__c=qut1.id;
        conObj.TeliaSE_Type__c = 'Renegotiation';
        conObj.StartDate = system.today();
        conObj.status = 'Draft';
        conObj.TeliaSE_TUPP_Interface_Status__c = 'Successful';
        conObj.accountId = acc.Id;
        conObj.TeliaSE_Case_Id__c = '12345';
        insert conObj;
        
        Utilizer_Contract_Relationship__c uc = new Utilizer_Contract_Relationship__c();
        //uc.Name = ;
        uc.AccountId__c = acc.Id;
        uc.ContractNumber__c = conObj.Id;
        uc.Status__c = 'Aktiv';
        uc.Org_Number__c = '5876698089';
        //uc.Utilizer_Contract_Name__c = 'abc';
        insert uc;
        
        //uc.Org_Number__c = acc+'1';
        update uc;
        
        delete uc;
        
    }
    public static testmethod void test2(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Org_Nr__c = label.Account_Org_N;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
        acc.Telia_Service_Manager__c = userInfo.getUserId();
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='opp1';
        opp.AccountId=acc.Id;
        opp.CloseDate = System.today();
        opp.StageName='Needs Analysis';
        opp.Pricebook2Id=Test.getStandardPricebookId();
        insert opp;
        
        Quote qut1 = new Quote();
        qut1.Name='Test Quote';
        qut1.status = 'Draft';
        qut1.opportunityId = opp.id;
        qut1.TeliaSE_Approval_Flag__c = False; 
        qut1.TeliaSE_Type__c='Renegotiation';
        insert qut1;
        
        Contract conObj = new Contract();
        conObj.vlocity_cmt__QuoteId__c=qut1.id;
        conObj.TeliaSE_Type__c = 'Renegotiation';
        conObj.StartDate = system.today();
        conObj.status = 'Draft';
        conObj.TeliaSE_TUPP_Interface_Status__c = 'Successful';
        conObj.accountId = acc.Id;
        conObj.TeliaSE_Case_Id__c = '12345';
        insert conObj;
        
        Utilizer_Contract_Relationship__c uc = new Utilizer_Contract_Relationship__c();
        //uc.Name = ;
        uc.AccountId__c = acc.Id;
        uc.ContractNumber__c = conObj.Id;
        uc.Status__c = 'Aktiv';
        uc.Org_Number__c = '5876698089';
        insert uc;
        delete uc;
        
    }
}