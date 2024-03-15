public class LoadBundle_Product_Helper {

    public static Map<string,object> loadBundle(List<Load_Product__c> newProds,Id parentObjectType,Id childObjectType){
        Map<String,Object> inputMap;
        List<Product2> Bundlelist = new list<Product2>();
        If(newProds.size() > 0 && !inputMap.isEmpty() && parentObjectType != null && childObjectType != null){
            For(Load_Product__c prod: newProds){
                Product2 bundle = new Product2();
                bundle.vlocity_cmt__ObjectTypeId__c = parentObjectType;
                bundle.Name = prod.ParentProductCode__c;
                bundle.ProductCode = prod.ParentProductCode__c;
                bundle.vlocity_cmt__IsOrderable__c = false;
                bundle.vlocity_cmt__Status__c = 'Active';
                bundle.IsActive = true;
                bundle.vlocity_cmt__SpecificationType__c = 'Product';
                Bundlelist.add(bundle);
                
                Product2 product = new Product2();
                product.IsActive = prod.Active__c;
                product.C2BC_Category__c = prod.C2BC_Category__c;
                product.C2BC_Subcategory__c = prod.C2BC_Subcategory__c;
                product.vlocity_cmt__ObjectTypeId__c = childObjectType;
                product.Name = prod.Name__c;
                product.vlocity_cmt__IsNotAssetizable__c = prod.non_assetizable__c;
                Product.Ordering_Flag__c = prod.Ordering_Flag__c;
                product.ProductCode = prod.ProductCode__c;
                product.MC_Product_Name_Eng__c = prod.ProductNameEng__c;
                product.vlocity_cmt__SellingStartDate__c = prod.SaleStartDate__c;
                product.SAPID__c = prod.SAPID__c;
                product.vlocity_cmt__IsConfigurable__c = true;
                product.vlocity_cmt__SpecificationType__c = 'Product';
                product.vlocity_cmt__Status__c = 'Active';
                product.vlocity_cmt__IsOrderable__c = false;
                Bundlelist.add(product);
                    
            }
            If(Bundlelist.size()> 0){
                Upsert Bundlelist;
            }
        }
        return inputMap;
    }
    
}