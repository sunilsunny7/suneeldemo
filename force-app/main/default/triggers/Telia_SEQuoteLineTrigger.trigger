/*-----------------------------------------------------------------------------------------------------------
**Name        :        Telia_SEQuoteLineTrigger
**Created By  :        Vaishali Srivastava
**Sprint      :        Sprint-4
**User Story  :        MCSTO-566 MCSTO-567
**Description :        Approval Flag update for customer Requested % and customer Requested Price 
**                     And update ceiling price from recurring charge
-----------------------------------------------------------------------------------------------------------*/
Trigger Telia_SEQuoteLineTrigger on QuoteLineItem (before insert, before update, after update,after insert, after delete) {
    ByPassTrigger__c byPassAcc = ByPassTrigger__c.getInstance(UserInfo.getUserId());
        
    if(!byPassAcc.QuoteLineItemTrigger__c){
          
    if(Trigger.isInsert && Trigger.isAfter){
        if(TeliaSE_checkRecursive.runOnceInsert()){
          TeliaSE_QuoteLineHandler.updateApprover(trigger.oldMap,trigger.newMap);
          TeliaSE_QuoteLineHandler.updateRootItem(Trigger.newMap);
          TeliaSE_QuoteLineHandler.updateFiberTotalRecurringCharge(trigger.new);
          TeliaSE_QuoteLineHandler.updatePTAttribute(trigger.newMap);   
        }
    } else if(Trigger.isInsert && Trigger.isBefore){
        TeliaSE_QuoteLineHandler.updateFiberFAPrice(trigger.new);   
    }
    else if(Trigger.isUpdate && Trigger.isBefore )
    {
        TeliaSE_QuoteLineHandler.deleteAdjustments(trigger.new,trigger.old);
        TeliaSE_QuoteLineHandler.updateCeilingPrice(trigger.new);
        //FIBE-1117 Child agreement quote using the frame agreement prices.(CA With FA)
        TeliaSE_QuoteLineHandler.updateFiberFAPrice(trigger.new);
        
        //TeliaSE_QuoteLineHandler.roamingFlagMethod(trigger.new, trigger.oldMap, trigger.newMap);
        
        //TeliaSE_QuoteLineHandler.updateChargeType(trigger.new,Trigger.newMap);
        
    }  
    else if(Trigger.isupdate && Trigger.isAfter )
    {        
        if(TeliaSE_checkRecursive.runOnce()){
            TeliaSE_QuoteLineHandler.updateApprover(trigger.oldMap,trigger.newMap);
            TeliaSE_QuoteLineHandler.checkCT(trigger.oldMap,trigger.newMap);

            //TeliaSE_QuoteLineHandler.updateFiberTotalRecurringCharge(trigger.new); 

        }
        //Do not keep the below trigger inside recursive check for this trigger event
        TeliaSE_QuoteLineHandler.updateFiberTotalRecurringCharge(trigger.new); 
    } 
    else if(Trigger.isdelete && Trigger.isAfter )
    {
        TeliaSE_QuoteLineHandler.updateFiberTotalRecurringCharge(trigger.old);
    }  
}
}