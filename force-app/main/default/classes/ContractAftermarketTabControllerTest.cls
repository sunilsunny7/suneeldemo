/**
 * Created by kwn687 on 2021-09-23.
 */
@isTest
public with sharing class ContractAftermarketTabControllerTest {
    @TestSetup
    public static void testSetup() {
        //Retrieving Record Type
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Business' LIMIT 1].id;
        //Inserting Parent account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        acc1.Existing_Customer__c = false;
        insert acc1;
        //Inserting Child accounts
        Account acc = new Account(name = 'TEST1', recordTypeId = childAccRecordTypeId, ParentId = acc1.Id, Existing_Customer__c = false);
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
        }
        Id recTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Teliaavtal').getRecordTypeId();
        Contract contractNew = new Contract(RecordTypeId = recTypeId, StartDate = system.today(), ContractTerm = 4, AccountId = acc.id);
        insert contractNew;
    }
    @isTest
    public static void testMyController() {
        Contract newContract = [SELECT id FROM Contract WHERE Account.name = 'TEST1' LIMIT 1];
        Test.StartTest();
        PageReference pageRef = Page.ContractAftermarketTab;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(newContract.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(newContract);
        ContractAftermarketTabController controller = new ContractAftermarketTabController(sc);
        controller.commentary(); // Test if commentary action is working
        System.assertEquals('Block', controller.commentaryVarInput, 'Commentary input field failed to show!');
        System.assertEquals('none', controller.commentaryVarOutput, 'Commentary output field failed to hidden!');
        System.assertEquals(true, controller.saveCancelButton, 'Save and Cancel buttons failed to show!');
        controller.cancel();// Test if cancel action is working
        System.assertEquals('none', controller.commentaryVarInput, 'Commentary input field failed to hide!');
        System.assertEquals('Block', controller.commentaryVarOutput, 'Commentary output field failed to show!');
        System.assertEquals(false, controller.saveCancelButton, 'Save and Cancel buttons failed to hide!');
        controller.save(); // Test if save action is working
        System.assertEquals('none', controller.commentaryVarInput, 'Commentary input field failed to hide!');
        System.assertEquals('Block', controller.commentaryVarOutput, 'Commentary output field failed to show!');
        System.assertEquals(false, controller.saveCancelButton, 'Save and Cancel buttons failed to hide!');
        Test.StopTest();
    }
}