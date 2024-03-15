/**
* @Author:      Abhinav Gupta
* @Company:     Capgemini
* @Date:        23th December, 2020
* @Description: This Class will attach documents from quotes(Offer and Hardware to related Opportunity)
*
* History
* <Date>           <Authors Name>      <Brief Description of Change>
* -------------------------------------------------------------
*/
global class TeliaSE_MC_QuoteDocumentLinkBatch implements Database.Batchable<sObject> 
{
    String query;
    String quoteType1 = 'Offer';
    String quoteType2 = 'Hardware';
    String invalidStatus = 'Cancelled';
    global TeliaSE_MC_QuoteDocumentLinkBatch()
    {
        query = 'select id,OpportunityId from quote where status!=: invalidStatus and (RecordType.DeveloperName =: quoteType1 or RecordType.DeveloperName =: quoteType2)';
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Quote> quoteList)
    {
        List<Id> idList = new List<Id>();
        List<Id> oppIdList = new List<Id>();
        Map<Id,Id> quoteOppIdMap = new Map<Id,Id>();
        Map<Id,Id> oppQuoteIdMap = new Map<Id,Id>();
        List<ContentDocumentLink> newContentDocumentLink = new List<ContentDocumentLink>();
        List<Id> contentDocumentIds = new List<Id>();
        List<Id> quotesAlreadyAttached = new List<Id>();
        for (Quote q : quoteList)
        {
            quoteOppIdMap.put(q.id,q.OpportunityId);
            idList.add(q.id);
            oppIdList.add(q.OpportunityId);
            oppQuoteIdMap.put(q.OpportunityId,q.Id);
        }
        List<ContentDocumentLink> cdlList = [select id,ContentDocumentId, LinkedEntityId ,LinkedEntity.Name  from ContentDocumentLink where LinkedEntityId  IN : idList];       
        for(ContentDocumentLink cdl : cdlList)
        {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
        List<ContentDocumentLink> cdlListOpp = [select id,ContentDocumentId, LinkedEntityId ,LinkedEntity.Name  from ContentDocumentLink where LinkedEntityId  IN : oppIdList And ContentDocumentId IN: contentDocumentIds];               
        for(ContentDocumentLink cdl : cdlListOpp)
        {
            quotesAlreadyAttached.add(oppQuoteIdMap.get(cdl.LinkedEntityId));
        }
        for(ContentDocumentLink cdl : cdlList)
        {
            if(!quotesAlreadyAttached.contains(cdl.LinkedEntityId))
            {
                ContentDocumentLink cdlnew = cdl.clone(false,true);
            	cdlnew.LinkedEntityId = quoteOppIdMap.get(cdl.LinkedEntityId);
            	newContentDocumentLink.add(cdlnew);
            }			
        }
        if(newContentDocumentLink!= null && newContentDocumentLink.size()>0)
        {
            insert newContentDocumentLink;
        }
    }
 
    global void finish(Database.BatchableContext bc)
    {
    } 
}