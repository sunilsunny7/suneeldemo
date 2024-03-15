/* Author: Varma Alluri on 04.04.2017                                                                                    
Description: Jira Ticket: SAEN-2252; Trigger populating a custom checkbox field (HasAttachment__c)
on the subcase to TRUE or FALSE depending on content document exists on the subcase or not. 
Updated March 2019- Y.K - SALEF-1806 - Files from case to subcase
Updated by Monika on 23.04.2019
Jira story: MCSTO:728 Document naming convention */
trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert,before delete, before insert) {
    if(trigger.isInsert && trigger.isAfter){
        ContentDocumentLinkTriggerHandler.OnafterInsert(trigger.New);
    }
    
    if(trigger.isInsert && trigger.isBefore)
    {
        system.debug('Line 14: TriggerContentDocoument' + trigger.New);
        List<ContentDocumentLink> quoteDocuments = new List<ContentDocumentLink>();
        For(ContentDocumentLink cdl : trigger.New)
        {
            Schema.sObjectType entityType = cdl.LinkedEntityId.getSObjectType();            
            if(String.valueOf(entityType) == 'Quote')
            {
                quoteDocuments.add(cdl);
            }
        }
        if(quoteDocuments!= Null && quoteDocuments.size()>0)
        {
        	ContentDocumentLinkTriggerHandler.addDocumentToOpportunity(quoteDocuments);    
        }
        
        ContentDocumentLinkTriggerHandler.OnbeforeInsert(trigger.New);
    }
    if (trigger.isBefore && trigger.isDelete) {
        ContentDocumentLinkTriggerHandler.OnbeforeDelete(trigger.old);
    }
}