trigger Contact on Contact (before insert, before update, after insert, after update, after delete, after undelete) {
    
    ByPassTrigger__c byPassAcc = ByPassTrigger__c.getInstance(UserInfo.getUserId());
        
    if(!byPassAcc.ContactTrigger__c){
    ContactTriggerHandler handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);

     if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
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
        handler.OnAfterDelete(Trigger.old);
    }
    }
}