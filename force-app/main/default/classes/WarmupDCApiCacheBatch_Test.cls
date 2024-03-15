@isTest
private class WarmupDCApiCacheBatch_Test {
    @isTest 
    static void logApiCallResult_test() {
        Map<String,String> configMap = new Map<String,String>();
        WarmupDCApiCacheBatch batchInstance = new WarmupDCApiCacheBatch('Code1','Code2',null);

        batchInstance.logApiCallResult('MISS', '29328492389423', configMap, 1231);
    }

    @isTest
    static void buildConfigString_test(){
        Map<String,String> configMap = new Map<String,String>();
        
        WarmupCacheConfiguration__c wcc = new WarmupCacheConfiguration__c();
        wcc.CatalogCode__c = 'Catalog_Test';
        wcc.ProductCode__c = 'Product_Test';
        wcc.JSONPayload__c = '{"test":"%token1%"}';
        insert wcc;
        
        configMap.put('configId', '12xf234');
        configMap.put('token1', 'value1');


        WarmupDCApiCacheBatch batchInstance = new WarmupDCApiCacheBatch('Catalog_Test','Product_Test',null);
        batchInstance.buildConfigString(configMap);
    }


    @isTest
    static void executeBatcg_test(){
        List<Map<String,String>> configList = new List<Map<String,String>>();
        Map<String,String> configMap = new Map<String,String>();
        
        WarmupCacheConfiguration__c wcc = new WarmupCacheConfiguration__c();
        wcc.CatalogCode__c = 'Catalog_Test';
        wcc.ProductCode__c = 'Product_Test';
        wcc.JSONPayload__c = '{"test":"%token1%"}';
        insert wcc;
        
        configMap.put('configId', '12xf234');
        configMap.put('token1', '1');
        configList.add(configMap);

        Database.executeBatch(new WarmupDCApiCacheBatch('Catalog_Test','Product_Test',configList),1);
    }
}