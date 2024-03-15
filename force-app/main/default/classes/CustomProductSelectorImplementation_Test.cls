@isTest
private class CustomProductSelectorImplementation_Test {
    
    @isTest
    private static void testProductSelector(){
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        CustomProductSelectorImplementation obj=new CustomProductSelectorImplementation();
        obj.invokeMethod('getAllProducts', inputMap, output, options);
        TEST.startTest();
        Product2 prod1 = new Product2();
            prod1.name = 'Access Basic Wireless 4G Backup';
            prod1.productCode = 'CO-DATANET-ACCESS-BASIC-4G';
            prod1.MC_Product_Sequence__c=30;
        insert prod1;
        
        Product2 prod2 = new Product2();
            prod2.name = 'Office 365 E3';
            prod2.productCode = 'C-ENT-E3-OFFER';
            prod2.MC_Product_Sequence__c=560;
        insert prod2;
        TEST.stopTest();
    }
}