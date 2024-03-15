trigger Account on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   /* User u=[Select Bypass_Trigger__c
                       from User
                       where id=:UserInfo.getUserId()] ;
    // Check if the current user is allowed to bypass the trigger 
    
    if(!u.Bypass_Trigger__c){*/

    ByPassTrigger__c byPassAcc = ByPassTrigger__c.getInstance(UserInfo.getUserId());
        
    if(!byPassAcc.AccountTrigger__c){
    AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);

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
    
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }

    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }

    else if(Trigger.isUndelete && Trigger.isAfter){
        handler.OnAfterUndelete(Trigger.new, Trigger.newMap);
    }
    }
}