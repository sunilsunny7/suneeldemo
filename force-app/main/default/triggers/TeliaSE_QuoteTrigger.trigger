/*-----------------------------------------------------------------------------------------------------------
**Name: TeliaSE_QuoteTrigger 
**Created By: Vaishali Srivastava
**Sprint: Sprint-2
**User Story:MCSTO-423,MCSTO-566/MCSTO-567
**Description:Error message should be presented if deletion is tried when the status is not "Draft" or "ready to present".
**            And update quote line item flag for approved quote
-----------------------------------------------------------------------------------------------------------*/
Trigger TeliaSE_QuoteTrigger on Quote(before delete, before update, after Update, after insert, before insert) {
    ByPassTrigger__c byPassAcc = ByPassTrigger__c.getInstance(UserInfo.getUserId());

    if (!byPassAcc.QuoteTrigger__c) {
        if (Trigger.isInsert && Trigger.isAfter) {
            Telia_SEQuoteHandler.setFlagField(Trigger.newMap);
            Telia_SEQuoteHandler.checkPrimaryQuotes(Trigger.newMap);

            Telia_SEQuoteHandler.matchNumberFields(Trigger.new, null);
            //Added below class to handle SALEF-5514
        	Telia_SEQuoteHandler.SetBlaKalkylFieldVaues(Trigger.newMap);

        }
        if (Trigger.isupdate && Trigger.isBefore) {
            Telia_SEQuoteHandler.UpdateApprovalFlag(Trigger.new, Trigger.oldMap, Trigger.newMap);
            Telia_SEQuoteHandler.checkMandate(Trigger.new, Trigger.oldMap, Trigger.newMap);
            //if(TeliaSE_checkRecursive.runOnce())
            Telia_SEQuoteHandler.checkMandateforFiber(Trigger.new, Trigger.oldMap, Trigger.newMap);
            TeliaSE_QuoteRetentionHandler.checkServiceUpgrade(Trigger.new);

        }

        if (Trigger.isupdate && Trigger.isAfter) {
            if (TeliaSE_checkRecursive.runOnce()) {
                Telia_SEQuoteHandler.UpdateApprovePrice(Trigger.new, Trigger.oldMap, Trigger.newMap);
                //Post chatter on approval or rejection of the quote
                Telia_SEQuoteHandler.postFeedOnApproveReject(Trigger.new, Trigger.oldMap, Trigger.newMap);
                Telia_SEQuoteHandler.FiberUpdateApprovedPrice(Trigger.new, Trigger.oldMap, Trigger.newMap);
                Telia_SEQuoteHandler.matchNumberFields(Trigger.new, Trigger.oldMap);
                //Telia_SEQuoteHandler.postFeed(Trigger.new);
                
                //Added below class to handle SALEF-5514
        		Telia_SEQuoteHandler.SetBlaKalkylFieldVaues(Trigger.newMap);
            }
        }

        if (Trigger.isBefore && Trigger.isDelete) {
            Telia_SEQuoteHandler.checkDeletion(Trigger.old);
        }
        if (Trigger.isBefore && Trigger.isInsert) {
            Telia_SEQuoteHandler.checkTypeOfAddress(Trigger.new);
        }
    }
}