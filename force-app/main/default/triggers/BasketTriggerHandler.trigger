trigger BasketTriggerHandler on MCOnline_Basket__c (before insert, before update) {
    if(Trigger.isUpdate && Trigger.isAfter){
        MCOnline_BasketTriggerHandler.afterUpdate(Trigger.New);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        MCOnline_BasketTriggerHandler.afterInsert(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        MCOnline_BasketTriggerHandler.beforeUpdate(Trigger.New);
    }
    if(Trigger.isInsert && Trigger.isBefore){
        MCOnline_BasketTriggerHandler.beforeInsert(Trigger.New);
    }
}