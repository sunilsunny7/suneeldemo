global with sharing class ContractLineItemUpdate_Batch implements Database.Batchable<sObject>{

    private String query='';
    private List<SObject> items;
    private Boolean updateJSONAttributes = false;
    private String prodId='';

    global ContractLineItemUpdate_Batch(List<SObject> items, Boolean updateJSONAttributes,String prodId)
    {
        this(items);
        this.updateJSONAttributes = updateJSONAttributes;
        this.prodId = prodId;
    }
    global ContractLineItemUpdate_Batch(List<SObject> items)
    {
        this.items = items;
    }
    global List<SObject> start(Database.BatchableContext BC)
    {
        return items;
    }
    global void execute(Database.BatchableContext context, List<SObject> scope)
    {
        List<SObject> qli = (List<SObject>)scope;
        if(qli.size() > 0)
        {
            Database.Update(qli, false);
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        System.debug('Success');
        List<Product2> oldpr = new List<Product2>();
        List<Product2> oldidlist = [select id, Name,vlocity_cmt__IsOrderable__c,vlocity_cmt__Status__c,IsActive from Product2 where Id =: prodId and vlocity_cmt__Status__c = 'Active' and IsActive = true and vlocity_cmt__IsOrderable__c = true LIMIT 1]; 
        if(oldidlist.size() > 0){
            for(Product2 pr : oldidlist){
                pr.vlocity_cmt__IsOrderable__c = false;
                pr.vlocity_cmt__Status__c = 'Draft';
                pr.IsActive = false;
                oldpr.add(pr);
            }
        }
        if(oldpr.size() > 0){
            update oldpr;
        }
    }

}