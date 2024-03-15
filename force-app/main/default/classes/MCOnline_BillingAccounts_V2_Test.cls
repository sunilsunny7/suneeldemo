@isTest
public class MCOnline_BillingAccounts_V2_Test {
    @testSetup
    static void initTestData() { 
        //create account record
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        
        //create contract record
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Active';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        
        //create parent basket record
        MCOnline_ParentBasket__c pBas = new MCOnline_ParentBasket__c();
        pBas.TSCID__c ='TSCID9808';
        pBas.Account__c =acc.id;
        pBas.Admin__c = 'testUser';
        pBas.AgreementId__c = contr.id;
        Insert pBas;
        
        //create child basket records
        List<MCOnline_Basket__c> cBas = new List<MCOnline_Basket__c>();
        MCOnline_Basket__c cBas1 = new MCOnline_Basket__c();
        MCOnline_Basket__c cBas2 = new MCOnline_Basket__c();
        cBas1.MCOnline_Admin__c ='testUser';
        cBas1.MCOnline_Billing_Account__c = ' ';
        cBas1.MCOnline_ParentBasket__c=pBas.id;
        cBas1.Account__c =acc.id;
        cBas.add(cBas1);
        cBas2.Account__c =acc.id;
        cBas2.MCOnline_Admin__c ='testUser';
        cBas2.MCOnline_Billing_Account__c = ' ';
        cBas2.MCOnline_ParentBasket__c=pBas.id;
        cBas.add(cBas2);
        insert cBas;
   		
        
       //input params and request body
        
        
    }
    @isTest
    static void updateBillingAccountTest(){
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Map<String,Object> tscid = new Map<String,Object>();
        Map<String,Object> bas1 = new Map<String,Object>();
        Map<String,Object> bas2 = new Map<String,Object>();
        Map<String,Object> request = new Map<String,Object>();
        List<Map<String,Object>> basketList = new List<Map<String,Object>>();
        String pBas = [Select id From MCOnline_ParentBasket__c]?.id;
        List<MCOnline_Basket__c> cBasName = [Select Name from MCOnline_Basket__c Where MCOnline_ParentBasket__c=:pBas];
        options.put('tscid','TSCID9808');
        options.put('users','testUser');
        inputMap.put('options',options);
        bas1.put('basketName',(cBasName.get(0)).get('Name'));
        bas1.put('billingAccount','MC123');
        basketList.add(bas1);
        bas2.put('basketName',(cBasName.get(1)).get('Name'));
        bas2.put('billingAccount','MC123');
        basketList.add(bas2);
        inputMap.put('request',basketList); 
        system.debug('request==>'+inputMap.get('request'));
        MCOnline_BillingAccounts_V2 billAcc = new MCOnline_BillingAccounts_V2();
        billAcc.invokeMethod('updateBillingAccount',inputMap,outMap,options);
        List<MCOnline_Basket__c> updatedBasket = [select Name,MCOnline_Billing_Account__c from MCOnline_Basket__c Where MCOnline_ParentBasket__c=:pBas];
        String bas1Acc = updatedBasket.get(0).MCOnline_Billing_Account__c;
        String bas2Acc =updatedBasket.get(1).MCOnline_Billing_Account__c;
        System.assertEquals('MC123',bas1Acc);
        System.assertEquals('MC123',bas1Acc);
    }
}