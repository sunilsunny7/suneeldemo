trigger QuarterlyForecastItem on Quarterly_Forecast_Item__c (after delete, after insert, after update) {

    QuarterlyForecastTriggerHandler handler = new QuarterlyForecastTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
      
    else if(Trigger.isUpdate && Trigger.isAfter){       
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}