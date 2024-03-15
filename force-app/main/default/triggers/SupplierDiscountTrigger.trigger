trigger SupplierDiscountTrigger on SupplierDiscount__c (before delete) {

    SupplierDiscountTriggerHandler handler = new SupplierDiscountTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
}