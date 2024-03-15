/**
About
-----
Description: After trigger on Opportunity Product object
Create date: June 2015, original name OpportunityProductAfter

Filters:
-------
1. Filters out all the opportunities that are related to opportunity products where sales outcome is not equal to null
2. Filters out all the opportunitites that are related to opportunity products that are deleted
3. Filters out all the products that belongs to a closed/won opportunity

Update History
--------------
Created Jun 2015 - V.I
Updated Oct 2015 - V.I
Updated Sep 2016 - A.N Renamed class from OpportunityProductAfter.trigger to OpportunityLineItem.trigger
Updated Sep 2016 - A.N Moved logic from the trigger into the new OpportunityLineItemTriggerHandler class
Updated Sep 2016 - A.N Removed logic for the event after undelete, as the OpportunityLineItem-sObject is not undeleteable

Issues / TODOs
--------------  

*/

trigger OpportunityLineItem on OpportunityLineItem (before delete, before insert, before update, after delete, after insert, after update,after undelete) {
        
    ByPassTrigger__c byPassOppLineItem = ByPassTrigger__c.getInstance(UserInfo.getUserId());

    if(!byPassOppLineItem.OpportunityLineItemTrigger__c){
    
    OpportunityLineItemTriggerHandler handler = new OpportunityLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    
    if(Trigger.isInsert && Trigger.isBefore){      
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    } 
    
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){       
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap);
    }
    
    else if(Trigger.isUpdate && Trigger.isAfter){       
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    }
}