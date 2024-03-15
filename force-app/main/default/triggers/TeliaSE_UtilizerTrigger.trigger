trigger TeliaSE_UtilizerTrigger on Utilizer_Contract_Relationship__c (before insert,before update, before delete, after update) {
    String triggerCheck = System.label.contractUtilizerTriggerFlag;
    if(triggerCheck != 'true'){
        if(Trigger.isUpdate && Trigger.isBefore)
        { 
            TeliaSE_UtilizerTriggerHandler.beforeUpdate(Trigger.New,Trigger.Old);
        }
        if(Trigger.isBefore && Trigger.isDelete ){
            TeliaSE_UtilizerTriggerHandler.beforeDelete(Trigger.Old);
        }
        if(Trigger.isUpdate && Trigger.isAfter)
        { 
            TeliaSE_UtilizerTriggerHandler.afterUpdate(Trigger.New);
        }
        
    }
}