trigger AccountContactRelation on AccountContactRelation (before insert) {

    AccountContactRelationTriggerHandler handler = new AccountContactRelationTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }
}