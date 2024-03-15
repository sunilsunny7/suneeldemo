trigger User on User (before delete, before insert, before update, after delete, after insert, after update,after undelete) {
    
    UserTriggerHandler handler = new UserTriggerHandler(Trigger.isExecuting, Trigger.size);
    String getTriggerValue = Label.STOPUSERTRIGGER;
    if(getTriggerValue =='TRUE'){
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new,Trigger.newMap );
        }
        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        }
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
        else if(Trigger.isUpdate && Trigger.isAfter){       
            handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
}