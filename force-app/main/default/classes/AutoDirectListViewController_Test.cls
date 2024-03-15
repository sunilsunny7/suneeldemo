/**
 * Created by kwn687 on 2021-11-08.
 */
@isTest
public with sharing class AutoDirectListViewController_Test {
    @TestSetup
    public static void testSetup() {
        Test_DataFactory.setUpOrg();
        System.runAs(Test_DataFactory.getByPassUser()) { // V.A  Bypassing User
            Account acc;
            acc = Test_DataFactory.createOneAccount();
            acc.Org_Nr__c = '0123456789';
            acc.Name = 'xyz';
            insert acc;
            Lead lead;
            lead = Test_DataFactory.createLead();
            lead.Org_nr__c = '0123456789';
            lead.Company = 'abc';
            lead.Account__c = acc.id;
            insert lead;

        }

    }
    @isTest
    public static void testRedirectToAura() {
        List <Lead> newLead = [SELECT id FROM Lead WHERE Org_nr__c = '0123456789' LIMIT 1];
        Test.StartTest();
        PageReference pageRef = Page.AutoDirectListView;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(newLead);
        AutoDirectListViewController controller = new AutoDirectListViewController(sc);
        Test.StopTest();
        System.assertEquals('System.PageReference[/lightning/cmp/c__AutoDirectAction?c__listOfLeads=]', String.valueOf(controller
                .redirectToLC()), 'Can\'t open Auto Direct!');

    }
}