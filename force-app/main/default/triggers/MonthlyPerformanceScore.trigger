trigger MonthlyPerformanceScore on Monthly_Performance_Score__c  (after insert, after update, before insert, before update) {

    MonthlyPerformanceScoreTriggerHandler handler = new MonthlyPerformanceScoreTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
      
    else if(Trigger.isUpdate && Trigger.isAfter){       
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isInsert && Trigger.isBefore){
        handler.onBeforeInsert(Trigger.new);
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.onBeforeUpdate(Trigger.New, Trigger.newMap, Trigger.Old, Trigger.oldMap);
    }
}