global class MCOnline_PHIM_CacheWarmup implements Schedulable{
    
    global void execute(SchedulableContext SC){
       delete[select id from WarmupCacheConfiguration__c where CatalogCode__c IN ('MOBILEDEVICE','ACCESSORY')];
       List<Product2> OfferList = [select ProductCode from Product2 where vlocity_cmt__SpecificationType__c='offer' AND (productcode like 'HW_MOB%' OR productcode like 'HW_ACC%') AND C2BC_Category__c ='offerbundle' limit 5];
       Map<string, string> productListHWAcc = new Map<string, string>();
       Map<string,List<String>> CatalogOfferMap = new Map<string,List<String>>();
       boolean PHIM = true;
       try{
            for(Product2 str : OfferList)
            {
                if((string.valueOf(str.ProductCode)).contains('MOBILEDEVICES')){
                   productListHWAcc.put(string.valueOf(str.ProductCode),'MOBILEDEVICE');
                }
                else if((string.valueOf(str.ProductCode)).contains('ACCESSORIES')){
                   productListHWAcc.put(string.valueOf(str.ProductCode), 'ACCESSORY'); 
                }
                
            }
            if(productListHWAcc != null)
            {
                Database.executeBatch(new JsonPayloadUpdate(productListHWAcc,PHIM));
            }
        }
       catch(Exception e){
           system.debug('Error: '+e);
        }
    
    }  
    
}