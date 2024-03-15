trigger SellerTrigger on Seller__c (after update, before update){ //,after delete, after insert, after undelete, before delete, before insert, before update) 
      
        SellerTriggerHandler handler = new SellerTriggerHandler(Trigger.isExecuting, Trigger.size);
        
        if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }

        else if(Trigger.isUpdate && Trigger.isAfter){            
            handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);        
        }
         
}