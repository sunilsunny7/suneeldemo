/**
About
-----
Description: Test class for Account Aggregation calculations
Create date: May 2015

Update History
--------------
Created March 2015 - T.R.
Updated february 2016 - P.P - to create record of Custom Setting - Excluded Records, failing at class - AccountRollUp
*/

@isTest
public with sharing class Test_AccountAggregation {

    static Id organisationRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Sales_Organisation_Account' LIMIT 1][0].Id;

    @testSetup
    static void initTestData() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        parentAccount.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Sales_Aggregation_Account' LIMIT 1][0].Id;
        insert parentAccount;
    }

    //Test Contacted - insert 1 child account
    static testMethod void testContactedInsertSingle() {
        //Arrange
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];

            Account childAccount = Test_DataFactory.createOneAccount();
            childAccount.RecordTypeId = organisationRTId;
            childAccount.Contacted__c = Date.today();
            childAccount.ParentId = parentAccount.Id;

            //Act
            Test.startTest();
            insert childAccount;
            Test.stopTest();

            //Assert
            Account updatedParent = [SELECT Id, Contacted__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
            System.assertEquals(childAccount.Contacted__c, updatedParent.Contacted__c, 'The contacted date on parent is incorrect.');
        }
    }
    //Test Contacted - remove the only 1 child account
    static testMethod void testContactedRemoveSingleOnly() {
        //Arrange
        /*Changes by PP*/
        ExcludedRecords__c exclRecords = new ExcludedRecords__c();
        exclRecords.Name = 'AcntRollUpExcludedRecords';
        exclRecords.Description__c = 'Test';
        insert exclRecords;
        /*end of changes by PP*/

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];

            Account childAccount = Test_DataFactory.createOneAccount();
            childAccount.RecordTypeId = organisationRTId;
            childAccount.Contacted__c = Date.today();
            childAccount.ParentId = parentAccount.Id;
            insert childAccount;

            Account updatedParent = [SELECT Id, Contacted__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
            System.assertEquals(childAccount.Contacted__c, updatedParent.Contacted__c, 'The contacted date on parent is incorrect.');

            //Act
            Test.startTest();
            delete childAccount;
            Test.stopTest();

            //Assert
            updatedParent = [SELECT Id, Contacted__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
            System.assertEquals(null, updatedParent.Contacted__c, 'The contacted date on parent is incorrect.');
        }
    }
    //Test Contacted - insert a second child account
    static testMethod void testContactedInsertSecond() {
        //Arrange
        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            Account childAccount = Test_DataFactory.createOneAccount();
            childAccount.RecordTypeId = organisationRTId;
            childAccount.Contacted__c = Date.today() - 30;
            childAccount.ParentId = parentAccount.Id;
            insert childAccount;

            //Act
            Test.startTest();
            Account secondAccount = Test_DataFactory.createOneAccount();
            secondAccount.RecordTypeId = organisationRTId;
            secondAccount.Contacted__c = Date.today();
            secondAccount.ParentId = parentAccount.Id;
            insert secondAccount;
            Test.stopTest();

            //Assert
            Account updatedParent = [SELECT Id, Contacted__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
            System.assertEquals(secondAccount.Contacted__c, updatedParent.Contacted__c, 'The contacted date on parent is incorrect.');
        }
    }
    //Test Contacted - update second child account
    static testMethod void testContactedUpdateSecond() {
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            //Arrange
            Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];

            Account childAccount = Test_DataFactory.createOneAccount();
            childAccount.RecordTypeId = organisationRTId;
            childAccount.Contacted__c = Date.today() - 30;
            childAccount.ParentId = parentAccount.Id;
            insert childAccount;

            Account secondAccount = Test_DataFactory.createOneAccount();
            secondAccount.RecordTypeId = organisationRTId;
            secondAccount.Contacted__c = Date.today() - 10;
            secondAccount.ParentId = parentAccount.Id;
            insert secondAccount;

            //Act
            Test.startTest();
            childAccount.Contacted__c = Date.today();
            update childAccount;
            Test.stopTest();

            //Assert
            Account updatedParent = [SELECT Id, Contacted__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
            System.assertEquals(childAccount.Contacted__c, updatedParent.Contacted__c, 'The contacted date on parent is incorrect.');
        }
    }
    //Test Contacted - update second child account (clear value)
    static testMethod void testContactedUpdateSecondClear() {
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            //Arrange
            Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];

            Account childAccount = Test_DataFactory.createOneAccount();
            childAccount.RecordTypeId = organisationRTId;
            childAccount.Contacted__c = Date.today() - 30;
            childAccount.ParentId = parentAccount.Id;
            insert childAccount;

            Account secondAccount = Test_DataFactory.createOneAccount();
            secondAccount.RecordTypeId = organisationRTId;
            secondAccount.Contacted__c = Date.today() - 10;
            secondAccount.ParentId = parentAccount.Id;
            insert secondAccount;

            //Act
            Test.startTest();
            secondAccount.Contacted__c = null;
            update secondAccount;
            Test.stopTest();

            //Assert
            Account updatedParent = [SELECT Id, Contacted__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
            System.assertEquals(childAccount.Contacted__c, updatedParent.Contacted__c, 'The contacted date on parent is incorrect.');
        }
    }
    //Test Contacted - delete the only account
    static testMethod void testContactedSingleAccountDeleted() {
        //Arrange
        /*Changes by PP*/
        ExcludedRecords__c exclRecords = new ExcludedRecords__c();
        exclRecords.Name = 'AcntRollUpExcludedRecords';
        exclRecords.Description__c = 'Test';
        insert exclRecords;
        /*end of changes by PP*/

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];

            Account childAccount = Test_DataFactory.createOneAccount();
            childAccount.RecordTypeId = organisationRTId;
            childAccount.Contacted__c = Date.today() - 30;
            childAccount.ParentId = parentAccount.Id;
            insert childAccount;

            //Act
            Test.startTest();
            delete childAccount;
            Test.stopTest();

            //Assert
            Account updatedParent = [SELECT Id, Contacted__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
            System.assertEquals(null, updatedParent.Contacted__c, 'The contacted date on parent is incorrect.');
        }
    }
    //Test Contacted - delete a second account
    static testMethod void testContactedSecondAccountDeleted() {
        //Arrange
        /*Changes by PP*/
        ExcludedRecords__c exclRecords = new ExcludedRecords__c();
        exclRecords.Name = 'AcntRollUpExcludedRecords';
        exclRecords.Description__c = 'Test';
        insert exclRecords;
        /*end of changes by PP*/

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];

            Account childAccount = Test_DataFactory.createOneAccount();
            childAccount.RecordTypeId = organisationRTId;
            childAccount.Contacted__c = Date.today() - 30;
            childAccount.ParentId = parentAccount.Id;
            insert childAccount;

            Account secondAccount = Test_DataFactory.createOneAccount();
            secondAccount.RecordTypeId = organisationRTId;
            secondAccount.Contacted__c = Date.today() - 10;
            secondAccount.ParentId = parentAccount.Id;
            insert secondAccount;

            //Act
            Test.startTest();
            delete secondAccount;
            Test.stopTest();

            //Assert
            Account updatedParent = [SELECT Id, Contacted__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
            System.assertEquals(childAccount.Contacted__c, updatedParent.Contacted__c, 'The contacted date on parent is incorrect.');
        }
    }
    //Test Contacted - undelete a second account
    static testMethod void testContactedSecondAccountUndeleted() {
        //Arrange
        /*Changes by PP*/
        ExcludedRecords__c exclRecords = new ExcludedRecords__c();
        exclRecords.Name = 'AcntRollUpExcludedRecords';
        exclRecords.Description__c = 'Test';
        insert exclRecords;
        /*end of changes by PP*/

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];

            Account childAccount = Test_DataFactory.createOneAccount();
            childAccount.RecordTypeId = organisationRTId;
            childAccount.Contacted__c = Date.today() - 30;
            childAccount.ParentId = parentAccount.Id;
            insert childAccount;

            Account secondAccount = Test_DataFactory.createOneAccount();
            secondAccount.RecordTypeId = organisationRTId;
            secondAccount.Contacted__c = Date.today() - 10;
            secondAccount.ParentId = parentAccount.Id;
            insert secondAccount;

            delete secondAccount;

            //Act
            Test.startTest();
            undelete secondAccount;
            Test.stopTest();

            //Assert
            Account updatedParent = [SELECT Id, Contacted__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
            System.assertEquals(secondAccount.Contacted__c, updatedParent.Contacted__c, 'The contacted date on parent is incorrect.');
        }
    }
    //Test Current Customer - insert 1 child account as current customer
//    static testMethod void testCurrentCustomerInsertSingle() {
//
//        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
//        //Arrange
//        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];
//
//        Account childAccount = Test_DataFactory.createOneAccount();
//        childAccount.RecordTypeId = organisationRTId;
//        childAccount.Contacted__c = Date.today();
//        childAccount.ParentId = parentAccount.Id;
//        insert childAccount;
//
//        //Act
//        Test.startTest();
//        List<Mobile_Subscription__c> mobSubs = getMobSubs(11, childAccount.Id);
//        insert mobSubs;
//        Test.stopTest();
//
//        //Assert
//        Account updatedParent = [SELECT Id, Current_Customer__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
//        System.assertEquals(true, updatedParent.Current_Customer__c, 'Current customer field on the parent account has got an incorrect value.');
//    }
//    }
    //Test Current Customer - remove the only 1 child account as current customer
//    static testMethod void testCurrentCustomerRemoveSingleOnly() {
//
//        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
//        //Arrange
//        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];
//
//        Account childAccount = Test_DataFactory.createOneAccount();
//        childAccount.RecordTypeId = organisationRTId;
//        childAccount.ParentId = parentAccount.Id;
//        insert childAccount;
//
//        List<Mobile_Subscription__c> mobSubs = getMobSubs(11, childAccount.Id);
//        insert mobSubs;
//
//        Account updatedParent = [SELECT Id, Current_Customer__c, Customer_5_Mobile_PP_or_more__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
//        System.assertEquals(true, updatedParent.Current_Customer__c, 'Current customer on parent is incorrect.');
//        System.assertEquals(true, updatedParent.Customer_5_Mobile_PP_or_more__c, 'Customer_5_Mobile_PP_or_more__c on parent is incorrect.');
//
//        //Act
//        Test.startTest();
//        delete mobSubs;
//        Test.stopTest();
//
//        //Assert
//        updatedParent = [SELECT Id, Current_Customer__c, Customer_5_Mobile_PP_or_more__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
//        System.assertEquals(false, updatedParent.Current_Customer__c, 'Current customer field on the parent account has got an incorrect value.');
//        System.assertEquals(false, updatedParent.Customer_5_Mobile_PP_or_more__c, 'Customer_5_Mobile_PP_or_more__c field on the parent account has got an incorrect value.');
//    }
//    }
    //Test Current Customer - insert a second current customer child account
//    static testMethod void testCurrentCustomerInsertSecond() {
//        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
//        //Arrange
//        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];
//
//        Account childAccount = Test_DataFactory.createOneAccount();
//        childAccount.RecordTypeId = organisationRTId;
//        childAccount.Contacted__c = Date.today() - 30;
//        childAccount.ParentId = parentAccount.Id;
//        insert childAccount;
//
//        List<Mobile_Subscription__c> mobSubs1 = getMobSubs(11, childAccount.Id);
//        insert mobSubs1;
//
//        //Act
//        Test.startTest();
//        Account secondAccount = Test_DataFactory.createOneAccount();
//        secondAccount.RecordTypeId = organisationRTId;
//        secondAccount.Contacted__c = Date.today();
//        secondAccount.ParentId = parentAccount.Id;
//        insert secondAccount;
//
//        List<Mobile_Subscription__c> mobSubs2 = getMobSubs(11, secondAccount.Id);
//        insert mobSubs2;
//        Test.stopTest();
//
//        //Assert
//        Account updatedParent = [SELECT Id, Current_Customer__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
//        System.assertEquals(true, updatedParent.Current_Customer__c, 'Current customer field on the parent account has got an incorrect value.');
//    }
//    }
    //Test Current Customer - remove second child as current customer
//    static testMethod void testCurrentCustomerUpdateSecondClear() {
//        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
//        //Arrange
//        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];
//
//        Account childAccount = Test_DataFactory.createOneAccount();
//        childAccount.RecordTypeId = organisationRTId;
//        childAccount.Contacted__c = Date.today() - 30;
//        childAccount.ParentId = parentAccount.Id;
//        insert childAccount;
//
//        List<Mobile_Subscription__c> mobSubs1 = getMobSubs(11, childAccount.Id);
//        insert mobSubs1;
//
//        Account secondAccount = Test_DataFactory.createOneAccount();
//        secondAccount.RecordTypeId = organisationRTId;
//        secondAccount.Contacted__c = Date.today() - 10;
//        secondAccount.ParentId = parentAccount.Id;
//        insert secondAccount;
//
//        List<Mobile_Subscription__c> mobSubs2 = getMobSubs(11, secondAccount.Id);
//        insert mobSubs2;
//
//        //Act
//        Test.startTest();
//        delete mobSubs2;
//        Test.stopTest();
//
//        //Assert
//        Account updatedParent = [SELECT Id, Current_Customer__c, Customer_5_Mobile_PP_or_more__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
//        System.assertEquals(true, updatedParent.Current_Customer__c, 'Current customer field on the parent account has got an incorrect value.');
//        System.assertEquals(true, updatedParent.Customer_5_Mobile_PP_or_more__c, 'Customer_5_Mobile_PP_or_more__c field on the parent account has got an incorrect value.');
//    }
//    }
    //Test Current Customer - delete the only current customer account
//    static testMethod void testCurrentCustomerSingleAccountDeleted() {
//        //Arrange
//        /*Changes by PP*/
//        ExcludedRecords__c exclRecords = new ExcludedRecords__c();
//        exclRecords.Name = 'AcntRollUpExcludedRecords';
//        exclRecords.Description__c = 'Test';
//        insert exclRecords;
//        /*end of changes by PP*/
//        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
//        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];
//
//        Account childAccount = Test_DataFactory.createOneAccount();
//        childAccount.RecordTypeId = organisationRTId;
//        childAccount.Contacted__c = Date.today() - 30;
//        childAccount.ParentId = parentAccount.Id;
//        insert childAccount;
//
//        List<Mobile_Subscription__c> mobSubs = getMobSubs(11, childAccount.Id);
//        insert mobSubs;
//
//        //Act
//        Test.startTest();
//        delete childAccount;
//        Test.stopTest();
//
//        //Assert
//        Account updatedParent = [SELECT Id, Current_Customer__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
//        System.assertEquals(false, updatedParent.Current_Customer__c, 'Current customer field on the parent account has got an incorrect value.');
//    }
//    }
//    //Test Current Customer - delete a second account that is the only current customer
//    static testMethod void testCurrentCustomerSecondAccountDeleted() {
//        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
//        //Arrange
//        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];
//
//        Account childAccount = Test_DataFactory.createOneAccount();
//        childAccount.RecordTypeId = organisationRTId;
//        childAccount.ParentId = parentAccount.Id;
//        insert childAccount;
//
//        Account secondAccount = Test_DataFactory.createOneAccount();
//        secondAccount.RecordTypeId = organisationRTId;
//        secondAccount.ParentId = parentAccount.Id;
//        insert secondAccount;
//
//        List<Mobile_Subscription__c> mobSubs = getMobSubs(11, secondAccount.Id);
//        insert mobSubs;
//
//        //Act
//        Test.startTest();
//        delete mobSubs;
//        Test.stopTest();
//
//        //Assert
//        Account updatedParent = [SELECT Id, Current_Customer__c, Customer_5_Mobile_PP_or_more__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
//        System.assertEquals(false, updatedParent.Current_Customer__c, 'Current customer field on the parent account has got an incorrect value.');
//        System.assertEquals(false, updatedParent.Customer_5_Mobile_PP_or_more__c, 'Customer_5_Mobile_PP_or_more__c field on the parent account has got an incorrect value.');
//    }
//    }
    //Test CurrentCustomer - undelete a second account that is the current customer
//    static testMethod void testCurrentCustomerSecondAccountUndeleted() {
//        //Arrange
//        /*Changes by PP*/
//        ExcludedRecords__c exclRecords = new ExcludedRecords__c();
//        exclRecords.Name = 'AcntRollUpExcludedRecords';
//        exclRecords.Description__c = 'Test';
//        insert exclRecords;
//        /*end of changes by PP*/
//        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
//         Test.startTest();
//        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];
//
//        Account childAccount = Test_DataFactory.createOneAccount();
//        childAccount.RecordTypeId = organisationRTId;
//        childAccount.Contacted__c = Date.today() - 30;
//        childAccount.ParentId = parentAccount.Id;
//        insert childAccount;
//
//        Account secondAccount = Test_DataFactory.createOneAccount();
//        secondAccount.RecordTypeId = organisationRTId;
//        secondAccount.Contacted__c = Date.today() - 10;
//        secondAccount.ParentId = parentAccount.Id;
//        insert secondAccount;
//
//        List<Mobile_Subscription__c> mobSubs = getMobSubs(11, secondAccount.Id);
//        insert mobSubs;
//
//        delete secondAccount;
//
//        //Act
//
//        undelete secondAccount;
//        Test.stopTest();
//
//        //Assert
//        Account updatedParent = [SELECT Id, Current_Customer__c, Customer_5_Mobile_PP_or_more__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
//        System.assertEquals(true, updatedParent.Current_Customer__c, 'Current customer field on the parent account has got an incorrect value.');
//        System.assertEquals(true, updatedParent.Customer_5_Mobile_PP_or_more__c, 'Customer_5_Mobile_PP_or_more__c field on the parent account has got an incorrect value.');
//    }
//    }
//    //Test Customer_5_Mobile_PP_or_more__c and Current Customer - insert 1 child account as current customer with 7 mobSubs
//    static testMethod void testCustomer5orMoreMobileInsertSingle() {
//        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
//        //Arrange
//        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' LIMIT 1][0];
//
//        Account childAccount = Test_DataFactory.createOneAccount();
//        childAccount.RecordTypeId = organisationRTId;
//        childAccount.Contacted__c = Date.today();
//        childAccount.ParentId = parentAccount.Id;
//        insert childAccount;
//
//        //Act
//        Test.startTest();
//        List<Mobile_Subscription__c> mobSubs = getMobSubs(7, childAccount.Id);
//        insert mobSubs;
//        Test.stopTest();
//
//        //Assert
//        Account updatedParent = [SELECT Id, Current_Customer__c, Customer_5_Mobile_PP_or_more__c FROM Account Where Name =: 'Parent' LIMIT 1][0];
//        System.assertEquals(false, updatedParent.Current_Customer__c, 'Current customer field on the parent account has got an incorrect value.');
//        System.assertEquals(true, updatedParent.Customer_5_Mobile_PP_or_more__c, 'Current customer field on the parent account has got an incorrect value.');
//    }
//    }
    private static List<Mobile_Subscription__c> getMobSubs(Integer n, Id accountId) {
        List<Mobile_Subscription__c> mobSubs = new List<Mobile_Subscription__c>();
        for (Integer i = 0; i < n; i++) {
            Mobile_Subscription__c mobSub = new Mobile_Subscription__c();
            mobSub.Account__c = accountId;
            mobSub.Category__c = 'POSTPAID';
            mobSub.Name = '1234' + i;
            mobSubs.add(mobSub);
        }
        return mobSubs;
    }
}