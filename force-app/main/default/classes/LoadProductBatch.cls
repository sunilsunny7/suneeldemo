/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna
* @version                1.0
* @description            upserts products,price from staging object 
* @modified               19-05-2022   added logic to skip running attribute jobs on SUNDAY
******************************************************************************************************************************/

global class LoadProductBatch implements Database.Batchable<sObject>,Database.Stateful {
    List<String> sapIds;
    Set<Id> existingSapIds;
    String query='select ';
    String type=null;
    Set<String> bundleKeysForRecommendations;
    global LoadProductBatch(String type,Set<String> bundleKeysForRecommendations)
    {
        this.type=type;
        this.bundleKeysForRecommendations=bundleKeysForRecommendations;
        sapIds=new List<String>();
        existingSapIds=new Set<Id>();
        Map<String, Schema.SObjectField> productFields=Schema.SObjectType.Load_product__c.fields.getMap();
        for(String field:productFields.keySet())
        {
            query+=field+',';
        }  
        query=query.removeEnd(',');
        if(type !='recommendedAccessory')
            query= query + ' from Load_Product__c where Status__c in (\'Aktuell\',\'Slutförsäljning\',\'Utgått\',\'Avslutad och stängd\',\'Trade Utökat\') and type__c =:type and Action__c = \'import\' and Success__c =false';
        else
            query= query + ' from Load_Product__c where phimId__c =:bundleKeysForRecommendations';
    }
    
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Load_Product__c> prods)
    {
        List<Load_Product__c> upsertProds=new List<Load_Product__c>();
        List<Load_Product__c> deleteProds=new List<Load_Product__c>();
        try{
            //process recommendedAccessories for sales and online 
            if(type == 'recommendedAccessory')
            {
                LoadProduct_Handler.addRecommendedProduct(prods);
            }
            else{           
                for(Load_Product__c prod:prods)
                {
                    //delete products from bundle with bellow status
                    if(prod.Status__c=='Utgått' || prod.Status__c=='Avslutad och stängd' || prod.Status__c=='Trade Utökat' || prod.Status__c=='Slutförsäljning'|| !prod.IsMyBProduct__c)
                    {
                        deleteProds.add(prod);
                    }
                    else if(prod.Status__c=='Aktuell' ) {
                        if(type == 'Bundle'){
                            bundleKeysForRecommendations.add(prod.phimId__c);
                        }
                        upsertProds.add(prod);
                    }
                }
                if(deleteProds.size() > 0){
                    LoadProduct_Handler.removeProducts(deleteProds);
                }
            
                if(type == 'Bundle' && upsertProds.size()>0)
                {
                    LoadProduct_Handler.validateDateAndAttributes(prods);
                    LoadProduct_Handler.upsertBundle(prods);                    
                }
                else if(type == 'Product' && upsertProds.size()>0) {
                    Set<Id> ids=new Set<Id>();
                    Set<String> existingIds=new Set<String>();
                    Map<String,Load_Product__c> loadProductMap=new Map<String,Load_Product__c>();
                    
                    for(Load_Product__c prod:prods)
                    {
                        existingIds.add(prod.SAPID__c);
                        sapIds.add(prod.SAPID__c);
                        ids.add(prod.Id);
                        loadProductMap.put(prod.SAPID__c,prod);
                    }
                    //skips refreshing attributes for existing products from super load on sundays (the condition checks for MONDAY and starts batch at 1 in the morning)
                    if(((DateTime)System.today()).format('EEEE').toUpperCase() == 'MONDAY')
                    {
                        Map<Id,Product2> existingProds=new Map<Id,Product2>([select id,productcode from Product2 where productcode != null and productcode in:existingIds]);
                        for(Product2 prod:existingProds.values())
                        {
                            loadProductMap.get(prod.productcode).isAttributeLoaded__c=true;
                        }
                        update new List<Load_Product__c>(loadProductMap.values());
                        existingSapIds.addAll(existingProds.keySet());
                    }
                    LoadProduct_Handler.validateDateAndAttributes(prods);
                    LoadProduct_Handler.processProductsFromBatch(prods);           
                }
            }
        }catch(Exception e)
        {
            LoadProduct_Handler.sendEmail('Exception occurred at '+e.getLineNumber()+' ' +e.getMessage()+' '+e.getStackTraceString()+JSON.serialize(prods));
        }
    }
    //Chains the batch for product processing and recommened accessory processing 
    global void finish(Database.BatchableContext bc)
    {
        if(type == 'Bundle')
        {
            Database.executeBatch(new LoadProductBatch('Product',bundleKeysForRecommendations),1);
        }
        else if(type == 'Product')
        {
            if(sapIds.size()>0)
            {
                //populates JSONAttribute for new products(doesn't fetch values as there will be no attribute assignments)
                Map<Id,Product2> products=new Map<Id,Product2>([select id from Product2 where productCode != null and productCode in:sapIds and id not in :existingSapIds]);
                if(products.size()>0)
                {
                    Database.executeBatch(new vlocity_cmt.EPCProductAttribJSONBatchJob(new List<Id>(products.keySet())),2);
                }
            }
            //remove orphan bundles and recalculates number of childitems at offer level
            LoadProduct_Handler.removeunusedBundles();
            LoadProduct_Handler.processNumberOfChildItemsAtOfferLevel();
            Database.executeBatch(new LoadProductBatch('recommendedAccessory',bundleKeysForRecommendations),1);
        }
    }
    
}