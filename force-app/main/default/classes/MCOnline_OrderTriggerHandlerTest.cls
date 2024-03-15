@isTest
public with sharing class MCOnline_OrderTriggerHandlerTest {
    

    @TestSetup
    static void makeData(){
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;

        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Active';
        //contr.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
        contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        

        Id stdPriceBookRecId = Test.getStandardPricebookId();

        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        order.Pricebook2Id =  stdPriceBookRecId;
        
        insert order;
        

    }

    @isTest
    public static void testEvents(){
        Order ord=[select id from Order limit 1];
        ord.OrderProcessor_Request__c='{"test":"yes"}';
        Test.startTest();
        update ord;
        Test.stopTest();
    }
}