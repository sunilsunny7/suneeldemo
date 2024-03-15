@isTest
public class MCONLINE_GetAgreementPDF_V3_Test {
 @testSetup
    static void initTestData() {
        User salesManager;
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID_1234';
        Insert acc;
        
        Account acc1 = new Account();
        acc1.RecordTypeId = '012240000008l9YAAQ';
        acc1.Name='TestAccount';
        acc1.TSCID__c = 'TSCID_5';
        Insert acc1;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.RecordTypeId = '0121p00000114BeAAI';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.Agreement_Nr__c = '6757575';
        contr.ContractTerm=24;
        insert contr;
        contr.Status='Active';
        System.runAs(salesManager){update contr;}
        
        scrive__ScriveDocument__c sc = new scrive__ScriveDocument__c();
        sc.scrive__status__c = 'Signed';
        sc.scrive__Contract__c = contr.id;
        insert sc;
        
    }
     @istest
    static  void agreementPDFTest1() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        options.put('AgreementNumber', '6757575');
        inputMap.put('AgreementNumber', '6757575');
        Test.startTest();
        new MCONLINE_GetAgreementPDF_V3().invokeMethod('contentsize',inputMap,outMap,options);
        Test.stopTest();
    }
}