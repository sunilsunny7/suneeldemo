/**
About
-----
Description: AgreementStatusUpdate on scrive__ScriveDocument__c

Update History 
--------------
Updated Jun 2022 - Srikanya - added class ScriveDocumentTriggerHandler to insert and update scrive document
*/

trigger AgreementStatusUpdate on scrive__ScriveDocument__c (after insert ,after update) {
    if(Trigger.isAfter)
    { 
        if(Trigger.isInsert)
        {
            TeliaSE_ContractStatusUpdateHandler.updateContractStatusforInsert(Trigger.new);
        }
        else if(Trigger.isUpdate)
        {
            TeliaSE_ContractStatusUpdateHandler.updateContractStatusforUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
        }
        
    }
 
    ScriveDocumentTriggerHandler Sd = new ScriveDocumentTriggerHandler();
    if(Trigger.isAfter){
    
        if(trigger.isInsert || trigger.isUpdate){
            if(ScriveDocumentTriggerHandler.toStopRec){
            sd.scriveDocumentadd(Trigger.new);
            }
        }
        
    }
}