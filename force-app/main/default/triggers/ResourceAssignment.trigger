/**
About
-----
Description: ResourceAssignment on ResourceAssignment 
Create date: 15.09-2017

Update History
--------------
Created Oct 2016 - V.M - SAEN-2446 Created RP: add/update opportunity team from assignment role



**/

trigger ResourceAssignment on ResourceHeroApp__Resource_Assignment__c (before insert, before delete, before update, after insert, after update, after delete, after undelete) {
    
    ResourceAssignmentTriggerHandler handler = new ResourceAssignmentTriggerHandler(Trigger.isExecuting, Trigger.size);
    
//    ResourceHeroApp.RHA_TriggerDispatcher.entry(new ResourceHeroApp.RHA_TriggerDispatcher.TriggerParameters(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.isExecuting, Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap));
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isUpdate){
            handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
        else if(Trigger.isDelete){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
        }
        else if(Trigger.isUndelete){

        }
        
    }else if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        }       
        else if(Trigger.isUpdate){       
            handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }       
        else if(Trigger.isDelete){
            handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        }
        else if(Trigger.isUndelete){
            handler.OnAfterUndelete(Trigger.new, Trigger.newMap);
        }
    } 
}