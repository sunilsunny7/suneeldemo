/**
About
-----
Description: Test class for BatchRollupLarmlistanToKKnr
Create date: Feb 2017 A.N

*/

@isTest
public with sharing class Test_BatchRollupLarmlistanToKKnr {

    @testSetup
    static void initTestData() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        parentAccount.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        parentAccount.Has_Child_Account__c = TRUE;
        insert parentAccount;
    }
    
    // Test roll up of values from two child accs to Parent
    static testMethod void testTwoLargeChildAccs() {    

        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' AND Has_Child_Account__c = TRUE LIMIT 1][0];
        
        // Creating one Large child account
        Account childAccount = Test_DataFactory.createOneAccount();
        childAccount.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        childAccount.ParentId = parentAccount.Id;
        childAccount.Centrex_Mobile_Subscriptions__c = 1;
        childAccount.Jobb_Mobil_VXL_Subscriptions__c = 2;
        childAccount.Mobile_bindings_exp_within_4_6_months__c = 3;
        insert childAccount;
        
        // Creating second Large child account
        Account secondAccount = Test_DataFactory.createOneAccount();
        secondAccount.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        secondAccount.ParentId = parentAccount.Id;
        secondAccount.Centrex_Mobile_Subscriptions__c = 4;
        secondAccount.Jobb_Mobil_VXL_Subscriptions__c = 5;
        secondAccount.Mobile_bindings_exp_within_4_6_months__c = 6;
        insert secondAccount;
        
        Decimal noOfCentrexMobileSubscriptions = childAccount.Centrex_Mobile_Subscriptions__c + secondAccount.Centrex_Mobile_Subscriptions__c;
        Decimal noOfJobbMobilVXLSubscriptions = childAccount.Jobb_Mobil_VXL_Subscriptions__c + secondAccount.Jobb_Mobil_VXL_Subscriptions__c;
        Decimal noOfMobilebindingsexpwithin46months = childAccount.Mobile_bindings_exp_within_4_6_months__c + secondAccount.Mobile_bindings_exp_within_4_6_months__c;
        
        //Assert before
        Account parentBeforeBatchUpdate = [SELECT Id, KKnr_Centrex_Mobile_Subscriptions__c, KKnr_Jobb_Mobil_VXL_Subscriptions__c, KKnr_Mobile_bindings_exp_within_4_6_mont__c
                                 FROM Account Where Name =: 'Parent' AND Has_Child_Account__c = TRUE LIMIT 1][0];
        System.assertEquals(null, parentBeforeBatchUpdate.KKnr_Centrex_Mobile_Subscriptions__c, 'Value for KKnr_Centrex_Mobile_Subscriptions__c on Parent Account should not have been calculated.');
        System.assertEquals(null, parentBeforeBatchUpdate.KKnr_Jobb_Mobil_VXL_Subscriptions__c, 'Value for KKnr_Jobb_Mobil_VXL_Subscriptions__c on Parent Account should not have been calculated.');
        System.assertEquals(null, parentBeforeBatchUpdate.KKnr_Mobile_bindings_exp_within_4_6_mont__c, 'Value for KKnr_Mobile_bindings_exp_within_4_6_mont__c on Parent Account should not have been calculated.');

        Test.startTest();
        Database.executeBatch(new BatchRollupLarmlistanToKKnr());
        Test.stopTest();    

        //Assert after
        Account parentAfterBatchUpdate = [SELECT Id, KKnr_Centrex_Mobile_Subscriptions__c, KKnr_Jobb_Mobil_VXL_Subscriptions__c, KKnr_Mobile_bindings_exp_within_4_6_mont__c
                                 FROM Account Where Name =: 'Parent' AND Has_Child_Account__c = TRUE LIMIT 1][0];
        System.assertEquals(noOfCentrexMobileSubscriptions, parentAfterBatchUpdate.KKnr_Centrex_Mobile_Subscriptions__c, 'Wrong value calculated for KKnr_Centrex_Mobile_Subscriptions__c on Parent Account.');
        System.assertEquals(noOfJobbMobilVXLSubscriptions, parentAfterBatchUpdate.KKnr_Jobb_Mobil_VXL_Subscriptions__c, 'Wrong value calculated for KKnr_Jobb_Mobil_VXL_Subscriptions__c on Parent Account.');
        System.assertEquals(noOfMobilebindingsexpwithin46months, parentAfterBatchUpdate.KKnr_Mobile_bindings_exp_within_4_6_mont__c, 'Wrong value calculated for KKnr_Mobile_bindings_exp_within_4_6_mont__c on Parent Account.');
    }

    // Test roll up of values to Parent: One SME and one Large Acc. values from Large Acc and SME acc should be rolled up to parent
    static testMethod void testLargeAndSmeChildAccs() {

        Account parentAccount = [SELECT Id FROM Account Where Name =: 'Parent' AND Has_Child_Account__c = TRUE  LIMIT 1][0];
        
        // Creating one Large child account
        Account childAccount = Test_DataFactory.createOneAccount();
        childAccount.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        childAccount.ParentId = parentAccount.Id;
        childAccount.Centrex_Mobile_Subscriptions__c = 1;
        childAccount.Jobb_Mobil_VXL_Subscriptions__c = 2;
        childAccount.Mobile_bindings_exp_within_4_6_months__c = 3;
        insert childAccount;
        
        // Creating second child account, but with SME record type
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        Account secondAccount = Test_DataFactory.createOneAccount();
        secondAccount.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
        secondAccount.ParentId = parentAccount.Id;
        secondAccount.Centrex_Mobile_Subscriptions__c = 4;
        secondAccount.Jobb_Mobil_VXL_Subscriptions__c = 5;
        secondAccount.Mobile_bindings_exp_within_4_6_months__c = 6;
        insert secondAccount;
        
        Decimal noOfCentrexMobileSubscriptions = childAccount.Centrex_Mobile_Subscriptions__c + secondAccount.Centrex_Mobile_Subscriptions__c;
        Decimal noOfJobbMobilVXLSubscriptions = childAccount.Jobb_Mobil_VXL_Subscriptions__c + secondAccount.Jobb_Mobil_VXL_Subscriptions__c;
        Decimal noOfMobilebindingsexpwithin46months = childAccount.Mobile_bindings_exp_within_4_6_months__c + secondAccount.Mobile_bindings_exp_within_4_6_months__c;

        Test.startTest();
        Database.executeBatch(new BatchRollupLarmlistanToKKnr());
        Test.stopTest();

        //Assert
        Account parentAfterBatchUpdate = [SELECT Id, KKnr_Centrex_Mobile_Subscriptions__c, KKnr_Jobb_Mobil_VXL_Subscriptions__c, KKnr_Mobile_bindings_exp_within_4_6_mont__c
                                 FROM Account Where Name =: 'Parent'AND Has_Child_Account__c = TRUE LIMIT 1][0];
        System.assertEquals(noOfCentrexMobileSubscriptions, parentAfterBatchUpdate.KKnr_Centrex_Mobile_Subscriptions__c, 'Wrong value 1 calculated for KKnr_Centrex_Mobile_Subscriptions__c on Parent Account.');
        System.assertEquals(noOfJobbMobilVXLSubscriptions, parentAfterBatchUpdate.KKnr_Jobb_Mobil_VXL_Subscriptions__c, 'Wrong value 1 calculated for KKnr_Jobb_Mobil_VXL_Subscriptions__c on Parent Account.');
        System.assertEquals(noOfMobilebindingsexpwithin46months, parentAfterBatchUpdate.KKnr_Mobile_bindings_exp_within_4_6_mont__c, 'Wrong value 1 calculated for KKnr_Mobile_bindings_exp_within_4_6_mont__c on Parent Account.');
        System.assertNotEquals(childAccount.Centrex_Mobile_Subscriptions__c, parentAfterBatchUpdate.KKnr_Centrex_Mobile_Subscriptions__c, 'Wrong value 2 calculated for KKnr_Centrex_Mobile_Subscriptions__c on Parent Account.');
        System.assertNotEquals(childAccount.Jobb_Mobil_VXL_Subscriptions__c, parentAfterBatchUpdate.KKnr_Jobb_Mobil_VXL_Subscriptions__c, 'Wrong value 2 calculated for KKnr_Jobb_Mobil_VXL_Subscriptions__c on Parent Account.');
        System.assertNotEquals(childAccount.Mobile_bindings_exp_within_4_6_months__c, parentAfterBatchUpdate.KKnr_Mobile_bindings_exp_within_4_6_mont__c, 'Wrong value 2 calculated for KKnr_Mobile_bindings_exp_within_4_6_mont__c on Parent Account.');
    }
}
}