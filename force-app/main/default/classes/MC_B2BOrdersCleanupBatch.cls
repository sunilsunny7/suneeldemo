/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_B2BOrdersCleanupBatch
**Created By  :        Shouvik Basu
**Date      :          01 August 2023
**User Story  :        23.10 LTAART-227: See ongoing orders and deliveries in SF - Daily cleanup job (11764)
**Description :        Apex class to fetch the records of B2B order information stored in object and delete them every day at a scheduled time.
-----------------------------------------------------------------------------------------------------------*/
global class MC_B2BOrdersCleanupBatch implements Database.Batchable<sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String data = 'Select Id from MC_B2B_Order__c';
        return Database.getQueryLocator(data);
    }
    
    global void execute(Database.BatchableContext bc, List<MC_B2B_Order__c> orderData){
        if(orderdata.size()>0) {
            delete orderData;
        }
    }
    
    global void finish(Database.BatchableContext bc) {}
    
    global void execute(SchedulableContext SC) {
        MC_B2BOrdersCleanupBatch obj = new MC_B2BOrdersCleanupBatch();
        Database.executeBatch(obj,10000);
    }
}