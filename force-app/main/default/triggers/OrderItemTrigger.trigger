trigger OrderItemTrigger on OrderItem (before insert, before update) {
    Map<String, FeaturesSetting__c> featuresEnabilityMap = FeaturesSetting__c.getAll();
    if(Trigger.isUpdate && Trigger.isAfter){
        OrderItemTriggerHandler.afterUpdate(Trigger.New);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        OrderItemTriggerHandler.afterInsert(Trigger.New);
    }
    if(OrderItemTriggerHandler.isFirstTime){
  
    if(Trigger.isUpdate && Trigger.isBefore && featuresEnabilityMap != null && featuresEnabilityMap.get('PriceOverride') != null && featuresEnabilityMap.get('PriceOverride').flag__c == true){
        OrderItemTriggerHandler.beforeUpdate(Trigger.New);
        OrderItemTriggerHandler.isFirstTime = false;
    }
    }
    if(Trigger.isInsert && Trigger.isBefore && featuresEnabilityMap != null && featuresEnabilityMap.get('PriceOverride') != null && featuresEnabilityMap.get('PriceOverride').flag__c == true){
        OrderItemTriggerHandler.beforeInsert(Trigger.New);
    }
}