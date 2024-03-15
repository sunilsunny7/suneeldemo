trigger TaskTrigger on Task (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    TaskTriggerHandler handler = new TaskTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
      
    else if(Trigger.isUpdate && Trigger.isAfter){       
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }    
    else if(Trigger.isDelete && Trigger.isAfter){       
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }      
}