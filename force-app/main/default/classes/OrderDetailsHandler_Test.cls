/**
 * Created by wgj897 on 2023-08-22.
 */
@IsTest

public with sharing class OrderDetailsHandler_Test {
    @TestSetup
    public static void initialTestDate() {
        Account accountForOrders = Test_DataFactory.createOneSMEAccount();
        insert accountForOrders;


    Contract contr = new Contract();
             contr.Name = 'Test';
             contr.AccountId = accountForOrders.Id;
             contr.Status= 'Draft';
             contr.Solution_Area__c='Vxl';
             contr.StartDate=Date.today();
             contr.ContractTerm=24;
             contr.recordtypeId = SEUtility.getRecordTypeId(SEConstants.Contract_TELIA_Avtal);
             insert contr;

        Order Ord = new Order();
        Ord.AccountId = accountForOrders.Id;
        Ord.EffectiveDate = system.today()-12;
        Ord.Status = 'Draft';
        Ord.Contract = contr;
        insert Ord;

}
@IsTest
    public static void changeNumberOfOrdersAfterInsert(){
    Account oneAccount = [SELECT Id , Name FROM Account LIMIT 1];

    Contract oneContract = [SELECT Id FROM Contract LIMIT 1];
    Order ordr = new Order();
    ordr.AccountId = oneAccount.Id;
    ordr.EffectiveDate = system.today()-12;
    ordr.Status = 'Draft';
    ordr.Contract = oneContract;

    Test.startTest();
    insert ordr;
    Test.stopTest();
    Account accAfterOrderInsert = [SELECT Id , Number_of_orders_last_12_months__c , Date_for_latest_order__c FROM Account LIMIT 1];
    Assert.areEqual(2, accAfterOrderInsert.Number_of_orders_last_12_months__c, 'Number of orders are not updated');
    Assert.areEqual(system.today(), accAfterOrderInsert.Date_for_latest_order__c, 'Date for latest orders is not updated');
}
    @IsTest
    public static void changeNumberOfOrdersAfterDelete(){
        List<Order> orders = [SELECT Id FROM Order];
        Test.startTest();
        delete orders;
        Test.stopTest();

        Account accAfterOrderDelete = [SELECT Id , Number_of_orders_last_12_months__c , Date_for_latest_order__c FROM Account LIMIT 1];
        assert.areEqual(0, accAfterOrderDelete.Number_of_orders_last_12_months__c, 'Number of orders are not updated');
        assert.areEqual(system.today(), accAfterOrderDelete.Date_for_latest_order__c, 'Date for latest orders is not updated');
    }
    @IsTest
    public static void changeNumberToOneOfOrdersAfterDelete(){
        Account oneAccount = [SELECT Id , Name FROM Account LIMIT 1];
        List<Order> orders = [SELECT Id FROM Order];

        Contract oneContract = [SELECT Id FROM Contract LIMIT 1];
        Order ordr = new Order();
        ordr.AccountId = oneAccount.Id;
        ordr.EffectiveDate = system.today()-12;
        ordr.Status = 'Draft';
        ordr.Contract = oneContract;

        Test.startTest();
        insert ordr;
        delete orders;
        Test.stopTest();
        Account accAfterOrderInsert = [SELECT Id , Number_of_orders_last_12_months__c , Date_for_latest_order__c FROM Account LIMIT 1];
        Assert.areEqual(1, accAfterOrderInsert.Number_of_orders_last_12_months__c, 'Number of orders are not updated');
    }
}