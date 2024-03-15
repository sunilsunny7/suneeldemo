trigger SupplierDiscountOpportunityLink on Supplier_Discount_Oppportunity_Link__c (after insert, after update, after delete) {

    SupplierDiscountOppLinkTriggerHandler handler = new SupplierDiscountOppLinkTriggerHandler(Trigger.isExecuting, Trigger.size);

	if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
      
    else if(Trigger.isUpdate && Trigger.isAfter){       
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }

    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
}