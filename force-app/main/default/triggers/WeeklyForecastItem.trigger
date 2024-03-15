/**
    About
    -----
    Description: After Trigger on WeeklyForecastItem
    Create date: Spring 2015

    Filters:
    -------
    1. None

    Update History
    --------------
    Created Apr 2015 - C.G
    Updated Sep 2015 - V.I Fixed bug for calculating subordinates commit and outcome
    Updated Oct 2015 - N.W Judge and Commit roll-up functionality
    Updated Sep 2016 - A.N Refactored: Functionality merged to WeeklyForecastItemTriggerHandler, so as to follow same standard form as used in the other triggers
    
    Issues / TODOs
    --------------  
    
*/

trigger WeeklyForecastItem on Weekly_Forecast_Item__c (before insert, before update,after update, after insert) {

    WeeklyForecastItemTriggerHandler handler = new WeeklyForecastItemTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }

    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
      
    else if(Trigger.isUpdate && Trigger.isAfter){       
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}