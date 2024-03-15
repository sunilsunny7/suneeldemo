trigger AccountPlanTrigger on Account_Plan1__c (before insert,before update){
    system.debug('^^^^^'+trigger.new);
    AccountPlanValidationHandler handler = new AccountPlanValidationHandler(Trigger.isExecuting, Trigger.size);
    
       if(Trigger.isInsert && Trigger.isBefore){
            handler.OnbeforeInsert(Trigger.new,Trigger.oldmap);
        } else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnbeforeUpdate(Trigger.new,Trigger.oldmap);
    }
}