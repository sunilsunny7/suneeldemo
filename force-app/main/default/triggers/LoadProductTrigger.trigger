trigger LoadProductTrigger on Load_Product__c   (before insert,before update) {

    LoadProduct_Handler.handleTriggerEvents(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap,Trigger.operationType);
}