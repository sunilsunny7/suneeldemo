/**
 * Created by kwn687 on 2022-07-29.
 */

public with sharing class mainProductSceenController {
    public class productWrapper {
        @AuraEnabled
        public String mainProduct { get; set; }
        @AuraEnabled
        public String cygateProduct { get; set; }
        @AuraEnabled
        public String supplier { get; set; }
        @AuraEnabled
        public Integer cygateTG { get; set; }
        @AuraEnabled
        public Integer contractPeriod { get; set; }
        @AuraEnabled
        public String salesType { get; set; }
        @AuraEnabled
        public Integer unitePrice { get; set; }
        @AuraEnabled
        public Integer quantiy { get; set; }
        @AuraEnabled
        public Integer startFee { get; set; }
    }
    @AuraEnabled
    public static void insertProducts(List<productWrapper> allProducts, Id recordId) {
        Map<String, Id> productNameMap = new Map<String, Id>();
        for (Product2 product : [SELECT id, name FROM Product2 WHERE productcode = 'CG']) {
            productNameMap.put(product.name, product.id);
        }
        List<OpportunityLineItem> newOppLineItems = new List<OpportunityLineItem>();
        for (productWrapper newProduct : allProducts) {
            OpportunityLineItem newOppLineItem = new OpportunityLineItem(
                    Supplier__c = newProduct.supplier,
                    Cygate_Margin__c = newProduct.cygateTG,
                    Contact_Duration__c = newProduct.contractPeriod,
                    Product2Id = productNameMap.get(newProduct.mainProduct + ' - ' + newProduct.cygateProduct),
                    OpportunityId = recordId,
                    Sales_Type_Cygate__c = newProduct.salesType,
                    Product_Family__c = 'Cygate',
                    UnitPrice = newProduct.unitePrice,
                    Quantity = newProduct.quantiy,
                    Start_Fee__c = newProduct.startFee
            );
            newOppLineItems.add(newOppLineItem);
        }
        insert newOppLineItems;
    }

}