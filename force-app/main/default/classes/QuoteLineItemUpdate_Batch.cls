global with sharing class QuoteLineItemUpdate_Batch implements Database.Batchable<sObject>{

    private String query='';
    private List<QuoteLineItem> quoteLineItem;
    private Boolean updateJSONAttributes = false;

    global QuoteLineItemUpdate_Batch(List<QuoteLineItem> quoteLineItem, Boolean updateJSONAttributes)
    {
        this(quoteLineItem);
        this.updateJSONAttributes = updateJSONAttributes;
        
    }
    global QuoteLineItemUpdate_Batch(List<QuoteLineItem> quoteLineItem)
    {
        this.quoteLineItem = quoteLineItem;
    }
    global List<QuoteLineItem> start(Database.BatchableContext BC)
    {
        return quoteLineItem;
    }
    global void execute(Database.BatchableContext context, List<QuoteLineItem> scope)
    {
        List<QuoteLineItem> qli = (List<QuoteLineItem>)scope;
        if(qli.size() > 0)
        {
            Database.Update(qli, false);
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        System.debug('Success');
    }

 

}