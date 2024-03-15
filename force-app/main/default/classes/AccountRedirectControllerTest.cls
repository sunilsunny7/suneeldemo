/**
 * Created by kwn687 on 2021-09-27.
 */
@isTest
public with sharing class AccountRedirectControllerTest {
    @TestSetup
    public static void testSetup() {
        //Retrieving Record Type
        string childAccRecordTypeId = [select id,developername from recordtype where developername = 'Business' LIMIT 1].id;
        //Inserting Parent account
        Account acc1 = Test_DataFactory.createOneKundkontoAccount();
        acc1.Existing_Customer__c = false;
        insert acc1;
        //Inserting Child accounts
        Account acc = new Account(name = 'TEST1', recordTypeId = childAccRecordTypeId, ParentId = acc1.Id, Existing_Customer__c = false, Org_Nr__c = '1111111111');
        System.runAs(Test_DataFactory.getByPassUser()) {
            insert acc;
        }
    }
    @isTest
    public static void testRedirectIfIdisGood() {
        Account newAccount = [SELECT id, Org_Nr__c FROM Account WHERE name = 'TEST1' LIMIT 1];
        Test.StartTest();
        PageReference pageRef = Page.ContractAftermarketTab;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(newAccount);
        accountRedirectController controller = new accountRedirectController(sc);
        pageRef.getParameters().put('orgNr', String.valueOf(newAccount.Org_Nr__c));
        Test.StopTest();
        System.assertEquals('System.PageReference[/' + String.valueOf(newAccount.id) + ']', String.valueOf(controller
                .redirect()), 'Can\'t redirect to Account!');
    }
    @isTest
    public static void testRedirectIfIdisNull() {
        Account newAccount = [SELECT id, Org_Nr__c FROM Account WHERE name = 'TEST1' LIMIT 1];
        Test.StartTest();
        PageReference pageRef = Page.ContractAftermarketTab;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(newAccount);
        accountRedirectController controller = new accountRedirectController(sc);
        controller.redirect();
        Test.StopTest();
        System.assertEquals('System.PageReference[/lightning/app/06m1p0000011OTxAAM]', String.valueOf(controller
                .redirect()), 'Can\'t redirect to Real Estate Fiber!');
    }
    @isTest
    public static void testRedirectIfIdisWrong() {
        Account newAccount = [SELECT id, Org_Nr__c FROM Account WHERE name = 'TEST1' LIMIT 1];
        Test.StartTest();
        PageReference pageRef = Page.ContractAftermarketTab;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(newAccount);
        accountRedirectController controller = new accountRedirectController(sc);
        pageRef.getParameters().put('orgNr', String.valueOf(1111));
        controller.redirect();
        Test.StopTest();
        System.assertEquals('System.PageReference[/c/SearchApp.app?search=1111]', String.valueOf(controller
                .redirect()), 'Can\'t redirect to Global search!');
    }
}