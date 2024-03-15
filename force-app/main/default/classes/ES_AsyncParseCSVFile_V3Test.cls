@isTest
private class ES_AsyncParseCSVFile_V3Test {
    @isTest 
    static void parseCSV_SingleBatch_Test() {

        String contentString = 'OFFER,PRODUCT;OFFERCODE,PROD1;PROD2\nOFFERCODE,PROD3;PROD4\nOFFERCODE,PROD1\nOFFERCODE,PROD4;PROD2';
        Integer batchNumber = 1;

        WarmupCacheConfiguration__c wcc = new WarmupCacheConfiguration__c();
        wcc.CatalogCode__c = 'Catalog_Test';
        wcc.ProductCode__c = 'Product_Test';
        wcc.JSONPayload__c = '{"token1":"%PROD1%","token2":"%PROD2%","token3":"%PROD3%","token4":"%PROD4%" }';
        insert wcc;

        System.enqueueJob(new ES_AsyncParseCSVFile_V3('Product_Test', 'Catalog_Test', contentString, batchNumber));
    }

    @isTest 
    static void parseCSV_MultiBatch_Test() {

        String contentString = 'OFFER,PRODUCT;OFFERCODE,PROD1;PROD2\nOFFERCODE,PROD3;PROD4\nOFFERCODE,PROD1\nOFFERCODE,PROD4;PROD2';
        Integer batchNumber = 3;

        WarmupCacheConfiguration__c wcc = new WarmupCacheConfiguration__c();
        wcc.CatalogCode__c = 'Catalog_Test';
        wcc.ProductCode__c = 'Product_Test';
        wcc.JSONPayload__c = '{"token1":"%PROD1%","token2":"%PROD2%","token3":"%PROD3%","token4":"%PROD4%" }';
        insert wcc;

        System.enqueueJob(new ES_AsyncParseCSVFile_V3('Product_Test', 'Catalog_Test', contentString, batchNumber));
    }
}