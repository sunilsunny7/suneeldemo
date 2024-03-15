public class MCOnline_QueueableWarmUp implements Queueable {
    private Map<string, string> productListHW;
    private boolean phim;
    
    public MCOnline_QueueableWarmUp(Map<string, string> productListHW,boolean PHIM){
        this.productListHW=productListHW;
        this.phim=PHIM;
        set<string> catalog = new set<string>();
        set<string> ProductCode = new set<String>();
        for(string prodCode: productListHW.keySet()){
            //ProductCode.add(prodCode);
            //catalog.add(productListHW.get(prodCode));
            Database.executeBatch(new WarmupDCApiCacheBatch_V3(productListHW.get(prodCode),prodCode),1);
        }
        /*list<WarmupCacheConfiguration__c> fetchPayload = [select CatalogCode__c, JSONPayload__c, ProductCode__c from WarmupCacheConfiguration__c 
                                             where CatalogCode__c IN :catalog AND ProductCode__c IN :ProductCode]; */
        /*for(WarmupCacheConfiguration__c payload : fetchPayload){
             Database.executeBatch(new WarmupDCApiCacheBatch_V3(payload.catalogCode__c,payload.ProductCode__c, payload.JSONPayload__c),1);
        }*/                                    
    }
    public void execute(System.QueueableContext qc) 
    {
       system.debug('warmup initiated succesfully');
    }
}