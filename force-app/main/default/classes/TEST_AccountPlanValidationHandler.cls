@isTest
private class TEST_AccountPlanValidationHandler {

    @isTest private static void testcheckForAccountPlanYear() {
        //This test method validates the functionality of AccountPlanValidationHandler
        //Create KKNR Account
        Account acc = Test_DataFactory.createOneKundkontoAccount();
        insert acc;
        //Insert AccountPlan
        Account_Plan1__c accplan = new Account_Plan1__c();
        accplan.Account_name__c = acc.Id;
        accplan.Status__c = 'Draft';
        accplan.IT_Spend__c = 100;
        insert accplan;
        
        //Extract the AccountPlan to update
        Account_Plan1__c accplan2 = [SELECT id,Status__c from Account_Plan1__c WHERE Account_name__c =: acc.Id];
        accplan2.Status__c = 'Ready for analysis';
        update accplan2;

    }

}