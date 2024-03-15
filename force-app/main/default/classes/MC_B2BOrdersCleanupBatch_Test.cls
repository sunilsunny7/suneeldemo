/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_B2BOrdersCleanupBatch_Test
**Created By  :        Shouvik Basu
**Date      :          01 August 2023
**User Story  :        23.10 LTAART-227: See ongoing orders and deliveries in SF - Daily cleanup job (11764)
**Description :        Test class for the Apex class MC_B2BOrdersCleanupBatch.
-----------------------------------------------------------------------------------------------------------*/
@isTest
private class MC_B2BOrdersCleanupBatch_Test {
    
    @testSetup
    private static void testDataSetup(){
        
        MC_B2B_Order__c ord1 = new MC_B2B_Order__c();
        ord1.Name = 'Test1';
        ord1.MC_Order_Number__c = '1001';
        ord1.MC_Orderer_Email__c = 'test1@more.biz';
        insert ord1;
        
        MC_B2B_Order__c ord2 = new MC_B2B_Order__c();
        ord2.Name = 'Test2';
        ord2.MC_Order_Number__c = '1002';
        ord2.MC_Orderer_Email__c = 'test2@more.biz';
        insert ord2;
    }
    
    @isTest
    private static void testB2BOrdersCleanupBatch(){
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?';
        MC_B2BOrdersCleanupBatch obj = new MC_B2BOrdersCleanupBatch();
        Database.executeBatch(obj);
        System.schedule('MC_B2BOrdersCleanupBatch test', CRON_EXP, obj);
        Test.stopTest();
    }
}