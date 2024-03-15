/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna
* @version                1.0
* @description            upserts products,price and deletes the product from root offer 
* @modified               16-01-2022
* @modified               01-05-2022 added logic to remove unused bundles from offer
******************************************************************************************************************************/
public class LoadProduct_Handler {
    public static Map<String,String> attributes;
    public static List<String> productCodes;
    public static Id pricelistId;
    public static Map<Id,Load_Product__c> loadProds=new Map<Id,Load_Product__c>();
    public static Map<String,MCOnline_Product_Mappings__mdt> productMappings=new Map<String,MCOnline_Product_Mappings__mdt>();
    public static Map<String,Load_Product__c> noduplicateProds=new Map<String,Load_Product__c>();
    public static void handleTriggerEvents(List<Load_Product__c> oldProds,List<Load_Product__c> newProds,Map<Id,Load_Product__c> oldMap,Map<Id,Load_Product__c> newMap,System.TriggerOperation operation)
    {
        try{
            switch on operation
            {            
                when BEFORE_INSERT
                {                                
                    productActionMapping(newProds);
                    calculateNPrice(newProds);
                }
                when BEFORE_UPDATE
                {
                    productActionMapping(newProds);
                    calculateNPrice(newProds);
                }
            }
        }catch(Exception e)
        {
            sendEmail('Exception at '+e.getLineNumber()+' '+e.getMessage()+' '+JSON.serialize(newProds));                    
        }
    }

    

/****************************************************************************************************************************
* method                  upsertBundle
* params                  Collection of Load_Product__c
* @description            Upserts bundles for mobiledevices and accessories and creates pricing and product relationship
* @created                20-01-2022
* @modified               23-01-2022
******************************************************************************************************************************/
    public static void upsertBundle(List<Load_Product__c> newProds){
        List<Load_Product__c> prods=new List<Load_Product__c>();        
        List<String> phimIds=new List<String>();
        List<vlocity_cmt__ProductChildItem__c> newPCIs=new List<vlocity_cmt__ProductChildItem__c>();
        Set<String> bundleBrand=new Set<String>();
        List<Load_Product__c> products= new List<Load_Product__c>();
        Set<String> sapIds=new Set<String>();
        List<Load_Product__c> bundleProds= new List<Load_Product__c>();
        Set<String> existingPriceEntry=new Set<String>();
        List<vlocity_cmt__PriceListEntry__c> entries=new List<vlocity_cmt__PriceListEntry__c>();
        for(Load_Product__c prod:newProds)
        {
                prods.add(prod);
                phimIds.add(prod.phimId__c);
                //for sales
                bundleProds.add(prod);
        }
        
        if(prods.size()>0)
        {
            //upsert bundle with ProductCode as upsert key
            Map<String,String> existingProductMap=new Map<String,String>();
            for(Product2 existingProduct:[select id,productCode from Product2 where ProductCode in :phimIds WITH SECURITY_ENFORCED])
            {
                existingProductMap.put(existingProduct.productCode,existingProduct.Id);
            }
            List<Product2> bundleProducts=new List<Product2>();
            List<String> offerCodes=new List<String>();
            Set<String> newProductCodes=new Set<String>();
            List<Product2> bundleExistingProducts=new List<Product2>();
            Map<String,Id> offerCodeMap=new Map<String,Id>();
            Product2 bundleProduct;
            String offerCode;
            Id priceListId=getPricelistId('ONL_PRICELIST');
            for(Load_Product__c prod:prods)
            {
                offerCode=getOfferCode(prod.phimId__c,prod.LinesCount__c,prod.C2BC_Subcategory__c);
                offerCodes.add(offerCode);
                prod.offerCode__C=offerCode;
                bundleProduct=new Product2();
                bundleProduct.Name=prod.ProductNameSwe__c;
                bundleProduct.ProductCode=prod.phimId__c;
                bundleProduct.vlocity_cmt__IsOrderable__c=false;
                bundleProduct.vlocity_cmt__Status__c='Active';
                bundleProduct.IsActive=true;
                bundleProduct.Parent_Family__c = 'Mobile Hardware';
                bundleProduct.phimId__c=prod.phimId__c;
                bundleProduct.C2BC_Category__c=prod.C2BC_Category__c;
                bundleProduct.vlocity_cmt__SpecificationType__c='Product';
                bundleProduct.Family='Online Order';
                bundleProduct.vlocity_cmt__ObjectTypeId__c=Id.valueOf(System.Label.TeliaSE_bundleObjectType);
                if(existingProductMap.containsKey(prod.phimId__c))
                {
                    bundleProduct.Id=existingProductMap.get(prod.phimId__c);
                    bundleExistingProducts.add(bundleProduct);
                }
                else 
                {       
                    bundleProducts.add(bundleProduct);
                    newProductCodes.add(prod.phimId__c);
                }
            }
            if(bundleProducts.size()>0){
                insert bundleProducts;
                System.debug('bundleProducts-->'+bundleProducts);
                for(Product2 prod:bundleProducts)
                {
                    entries.add(createPriceListEntry(priceListId,prod.Id,'One Time Std Price',Id.valueOf(System.Label.TeliaSE_zeroPricingElementId),true,'0 SEK'));
                }
                if(entries.size()>0)
                {
                    insert entries;
                }
            }
            entries.clear();
            for(vlocity_cmt__PriceListEntry__c existingEntry:[select vlocity_cmt__ProductId__r.ProductCode from vlocity_cmt__PriceListEntry__c where vlocity_cmt__ProductId__c !=null and vlocity_cmt__ProductId__c =:bundleExistingProducts WITH SECURITY_ENFORCED])
            {
                existingPriceEntry.add(existingEntry.vlocity_cmt__ProductId__r.ProductCode);
            }
            for(Product2 prod:bundleExistingProducts)
            {
                if(!existingPriceEntry.contains(prod.productCode))
                {
                    entries.add(createPriceListEntry(priceListId,prod.Id,'One Time Std Price',Id.valueOf(System.Label.TeliaSE_zeroPricingElementId),true,'0 SEK'));
                }
            }
            if(entries.size()>0)
            {
                insert entries;
            }
            if(bundleExistingProducts.size()>0){
                update bundleExistingProducts;
            }
            for(Product2 prod:[select id,productCode,C2BC_Category__c from Product2 where productCode !=null and (productCode in :offerCodes or productCode in :newProductCodes ) WITH SECURITY_ENFORCED]){
                if(prod.C2BC_Category__c == 'offerbundle'){
                    offerCodeMap.put(prod.productCode,prod.Id);
                }
                else{
                    existingProductMap.put(prod.productCode,prod.Id);
                }
            }
            for(vlocity_cmt__ProductChildItem__c item:[select name,vlocity_cmt__ParentProductId__c, vlocity_cmt__ParentProductId__r.ProductCode, vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.productCode from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__c !=null and vlocity_cmt__ParentProductId__r.productCode in :offerCodes and vlocity_cmt__ChildProductId__r.ProductCode !=null and vlocity_cmt__ChildProductId__r.ProductCode in :existingProductMap.keySet() and name !='Root PCI' WITH SECURITY_ENFORCED])
            {
                if(existingProductMap.containsKey(item.vlocity_cmt__ChildProductId__r.productCode))
                {
                    existingProductMap.remove(item.vlocity_cmt__ChildProductId__r.productCode);
                }
            }
            for(Load_Product__c prod:newProds)
            {
                if(existingProductMap.containsKey(prod.phimId__c))
                {
                    vlocity_cmt__ProductChildItem__c bundleToOfferRelationship=processParentChildRelationship(offerCodeMap.get(prod.offerCode__c),existingProductMap.get(prod.phimId__c),1,'onlinebundle');
                    if(bundleToOfferRelationship == null)
                    {
                        prod.error_description__c+=' child productcode:'+existingProductMap.get(prod.phimId__c)+'  or parent product:'+offerCodeMap.get(prod.offerCode__c)+' is null,'; 
                    }
                    else{
                        newPCIs.add(bundleToOfferRelationship);
                    }
                }
                prod.success__c=true;
            }
            if(newPCIs.size()>0){
                insert newPCIs;
            }
        }
        update prods; 
    }   

/****************************************************************************************************************************
* method                  processProductsFromBatch
* params                  Collection of Load_Product__c
* @description            Upserts products and then creates product child relationship between bundle and product
* @created                20-01-2022
* @modified               23-01-2022
******************************************************************************************************************************/
    public static void processProductsFromBatch(List<Load_Product__c> products)
    {
        Set<String> parentPhimIds=new Set<String>();
        Set<String> sapIds=new Set<String>();
        Map<String,Load_Product__c> parentProductMap=new Map<String,Load_Product__c>();
        List<Load_Product__c> newProds= new List<Load_Product__c>();
        List<Load_Product__c> bundleProds= new List<Load_Product__c>();
        List<vlocity_cmt__ProductChildItem__c> newPCIs=new List<vlocity_cmt__ProductChildItem__c>();
        Set<String> bundleProducts=new Set<String>();
        Map<String,Load_Product__c> prodMap=new Map<String,Load_Product__c>();
        Set<String> bundleBrands=new Set<String>(System.Label.TeliaSE_salesMobileBrands.split(','));
        for(Load_Product__c prod:products)
        {
                prod.Success__c=true;
                parentProductMap.put(prod.sapId__c,prod);
                parentPhimIds.add(prod.ParentPhimId__c);
                newProds.add(prod);
                sapIds.add(prod.sapId__c);
                if(prod.C2BC_Subcategory__c.equals('mobiledevice') && bundleBrands.contains(prod.Brand__c.toUppercase())){
                    bundleProducts.add('HW_VIRTUAL_GP_'+prod.Brand__c.toUppercase());  
                }
                else if(prod.C2BC_Subcategory__c.equals('mobiledevice') && !bundleBrands.contains(prod.Brand__c.toUppercase())){
                    bundleProducts.add('HW_VIRTUAL_GP_OTHER');  
                }

        }
        if(sapIds.size()>0)
        {
            Map<String,Id> phimToParentProductIdMap=new Map<String,Id>();
            Map<String,Product2> phimToProductIdMap=new Map<String,Product2>();
            List<Product2> amandaNewProducts=new List<Product2>();
            List<Product2> amandaExistingProducts=new List<Product2>();
            List<String> offerList = new List<String>();
            List<String> bundleList = new List<String>();
            Map<String,Id> phimToParentProductIdMap_Sales=new Map<String,Id>();
            Map<String,Product2> phimToProductIdMap_Sales=new Map<String,Product2>();
            for(Product2 prod:[select id,productCode from Product2 where productCode in:parentPhimIds and productCode !=null WITH SECURITY_ENFORCED])
            {
                phimToParentProductIdMap.put(prod.productCode, prod.Id);
            }
            for(Product2 prod:[select id,productCode,vlocity_cmt__FulfilmentStartDate__c from Product2 where productCode in:sapIds and productCode !=null WITH SECURITY_ENFORCED]){
                phimToProductIdMap.put(prod.productCode, prod);
            }
            phimToProductIdMap_Sales.putAll(phimToProductIdMap);
            for(Load_Product__c prod:newProds){
                if(phimToProductIdMap.get(prod.sapId__c) !=null){
                    amandaExistingProducts.add(createProduct(prod,phimToProductIdMap.get(prod.sapId__c),'Product'));
                }
                else{
                    amandaNewProducts.add(createProduct(prod,new Product2(),'Product'));
                }
            }
            if(amandaExistingProducts.size()>0){
                //Database.SaveResult[] res=Database.update(amandaExistingProducts,false);
                update amandaExistingProducts;
            }
            if(amandaNewProducts.size()>0){
                //Database.SaveResult[] res=Database.insert(amandaNewProducts,false);  
                insert amandaNewProducts;
            }
            phimToProductIdMap.clear();
            for(Product2 prod:[select id,productCode from Product2 where productCode in:sapIds and productCode !=null WITH SECURITY_ENFORCED]){
                phimToProductIdMap.put(prod.productCode, prod);
            }
            pricing(newProds,phimToProductIdMap);
            for(vlocity_cmt__ProductChildItem__c item:[select name,vlocity_cmt__ParentProductId__c, vlocity_cmt__ParentProductId__r.ProductCode, vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.productCode from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.productCode !=null and vlocity_cmt__ParentProductId__r.productCode in :phimToParentProductIdMap.keySet() and vlocity_cmt__ChildProductId__r.ProductCode !=null and vlocity_cmt__ChildProductId__r.ProductCode in :phimToProductIdMap.keySet() and name !='Root PCI' WITH SECURITY_ENFORCED])
            {
                if(phimToParentProductIdMap.containsKey(item.vlocity_cmt__ParentProductId__r.ProductCode) && phimToProductIdMap.containsKey(item.vlocity_cmt__ChildProductId__r.productCode))
                {
                    phimToProductIdMap.remove(item.vlocity_cmt__ChildProductId__r.productCode);
                }
            }
            for(String productCode:phimToProductIdMap.keySet()){
                vlocity_cmt__ProductChildItem__c prodToBundleRelationship=processParentChildRelationship(phimToParentProductIdMap.get(parentProductMap.get(productCode).ParentPhimId__c),phimToProductIdMap.get(productCode).Id,0,null);
                if(prodToBundleRelationship == null)
                {
                    parentProductMap.get(productCode).error_description__c+=' child productcode:'+productCode+'  or parent product:'+parentProductMap.get(productCode).ParentPhimId__c+' is null,'; 
                    parentProductMap.get(productCode).success__c=false;
                }
                else
                {
                    newPCIs.add(prodToBundleRelationship);
                }
            }
            //parent child relationship for Sales Mobile hardware
            if(bundleProducts.size()>0)
            {
                for(Product2 prod:[select id,Name,productCode from Product2 where productCode in:bundleProducts and productCode !=null WITH SECURITY_ENFORCED])
                {
                    phimToParentProductIdMap_Sales.put(prod.productCode, prod.Id);
                }
                for(vlocity_cmt__ProductChildItem__c item:[select name,vlocity_cmt__ParentProductId__c,vlocity_cmt__ParentProductId__r.Name, vlocity_cmt__ParentProductId__r.ProductCode, vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.productCode from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.productCode !=null and vlocity_cmt__ParentProductId__r.productCode in:bundleProducts and vlocity_cmt__ChildProductId__r.ProductCode !=null and vlocity_cmt__ChildProductId__r.ProductCode in :sapIds and name !='Root PCI' WITH SECURITY_ENFORCED])
                {
                    if(phimToParentProductIdMap_Sales.containsKey(item.vlocity_cmt__ParentProductId__r.productCode) && phimToProductIdMap_Sales.containsKey(item.vlocity_cmt__ChildProductId__r.productCode))
                    {
                        phimToProductIdMap_Sales.remove(item.vlocity_cmt__ChildProductId__r.productCode);
                    }
                }
                for(String productCode:phimToProductIdMap_Sales.keySet()){
                    Id parentId = bundleBrands.contains(parentProductMap.get(productCode).Brand__c.toUppercase())?phimToParentProductIdMap_Sales.get('HW_VIRTUAL_GP_'+parentProductMap.get(productCode).Brand__c.toUppercase()):phimToParentProductIdMap_Sales.get('HW_VIRTUAL_GP_OTHER');
                    vlocity_cmt__ProductChildItem__c prodToBundleRelationshipSales=processParentChildRelationship(parentId,phimToProductIdMap_Sales.get(productCode).Id,0,null);                    
                    if(prodToBundleRelationshipSales == null)
                    {
                        parentProductMap.get(productCode).error_description__c+=' child productcode:'+phimToProductIdMap_Sales.get(productCode).Id+'  or parent product:'+phimToParentProductIdMap_Sales.get('HW_VIRTUAL_GP_'+parentProductMap.get(productCode).Brand__c.toUppercase())+' is null,'; 
                    }
                    else
                    {
                        newPCIs.add(prodToBundleRelationshipSales);
                    }
                }
            }
            if(newPCIs.size()>0){
                insert newPCIs;
            }
        }
        update parentProductMap.values();
    }
    
    // process pricing for products 
    
    private static void pricing(List<Load_Product__c> newProds,Map<String,Product2> productMap){
        Id salesPriceListId=Id.valueOf(System.Label.TeliaSE_salesPriceListId);
        Id onlinePriceListId=Id.valueOf(System.Label.TeliaSE_onlinePriceListId);
        Set<String> codes=new Set<String>();
        Set<String> salesCodes=new Set<String>();
        List<vlocity_cmt__PricingElement__c> elements=new List<vlocity_cmt__PricingElement__c>();
        Map<String,String> pricingVariables=new Map<String,String>{'OT_STD_PRC'=>'','REC_MNTH_STD_PRC'=>'','OT_STD_PRC_N1'=>'','OT_STD_PRC_N2'=>''};
            Map<String,Set<String>> productPleMap=new Map<String,Set<String>>();
        Set<String> productPleSet;
        Map<String,Set<String>> productSalesPleMap=new Map<String,Set<String>>();
        Set<String> productSalesPleSet;
        for(vlocity_cmt__PricingVariable__c pricingVariable:[SELECT id,vlocity_cmt__code__c FROM vlocity_cmt__PricingVariable__c WHERE vlocity_cmt__Code__c in('OT_STD_PRC','REC_MNTH_STD_PRC','OT_STD_PRC_N1','OT_STD_PRC_N2') WITH SECURITY_ENFORCED])
        {
            pricingVariables.put(pricingVariable.vlocity_cmt__code__c,pricingVariable.Id);
        }
        for(Load_Product__c prod:newProds)
        {
            codes.add('OT-'+String.valueOf(prod.nrc__c));
            codes.add('RM-'+String.valueOf(prod.mrc__c));
            codes.add('OTN1-'+String.valueOf(prod.NRCN1__c));
            codes.add('OTN2-'+String.valueOf(prod.NRCN2__c));
            salesCodes.add('OT-'+String.valueOf(prod.nrc__c));
            productPleSet=new Set<String>(codes);
            productPleMap.put(prod.sapId__c,productPleSet);
            productSalesPleSet=new Set<String>(salesCodes);
            productSalesPleMap.put(prod.sapId__c,productSalesPleSet);
        }
        Set<String> clonedCodes=new Set<String>(codes);
        Set<String> clonedSalesCodes=new Set<String>(salesCodes);
        for(vlocity_cmt__PricingElement__c element:[select id,vlocity_cmt__PriceListId__c,vlocity_cmt__Code__c from vlocity_cmt__PricingElement__c  where vlocity_cmt__Code__c !=null and (vlocity_cmt__Code__c in :salesCodes or vlocity_cmt__Code__c in :codes) and vlocity_cmt__PriceListId__c in (:salesPriceListId,:onlinePriceListId) WITH SECURITY_ENFORCED])
        {
            if(element.vlocity_cmt__PriceListId__c == onlinePriceListId &&((element.vlocity_cmt__Code__c.startsWith('OT') && codes.contains(element.vlocity_cmt__Code__c)) || (element.vlocity_cmt__Code__c.startsWith('RM') && codes.contains(element.vlocity_cmt__Code__c))))
            {
                codes.remove(element.vlocity_cmt__Code__c);
            }
            else if((element.vlocity_cmt__PriceListId__c == salesPriceListId &&(element.vlocity_cmt__Code__c.startsWith('OT') && salesCodes.contains(element.vlocity_cmt__Code__c))))
            {
                salesCodes.remove(element.vlocity_cmt__Code__c);
            }
        }
        if(codes.size()>0 || salesCodes.size()>0)
        {
            String var;
            for(String code:codes)
            {
                var=code.startsWith('OTN1')?pricingVariables.get('OT_STD_PRC_N1'):code.startsWith('OTN2')?pricingVariables.get('OT_STD_PRC_N2'):code.startsWith('OT')?pricingVariables.get('OT_STD_PRC'):code.startsWith('RM')?pricingVariables.get('REC_MNTH_STD_PRC'):null;
                elements.add(getPricingElements(Double.valueOf(code.subStringAfter('-')),var,code,onlinePriceListId,code.startsWith('OT')?'One Time Std price':'Recurring Std price'));
            }   
            for(String code:salesCodes)
            {
                var=code.startsWith('OT')?pricingVariables.get('OT_STD_PRC'):null;
                elements.add(getPricingElements(Double.valueOf(code.subStringAfter('-')),var,code,salesPriceListId,'One Time Std price'));
            }
        }
        if(elements.size()>0)
        {
            insert elements;
        }
        Map<String,Id> elementMap=new Map<String,Id>();
        Map<String,Id> elementSalesMap=new Map<String,Id>();
        for(vlocity_cmt__PricingElement__c ele:[select id,vlocity_cmt__PriceListId__c,vlocity_cmt__Code__c from vlocity_cmt__PricingElement__c where (vlocity_cmt__Code__c!=null and (vlocity_cmt__Code__c in :clonedCodes or vlocity_cmt__Code__c in :clonedSalesCodes)) and vlocity_cmt__PriceListId__c in (:salesPriceListId,:onlinePriceListId) WITH SECURITY_ENFORCED])
        {
            if(ele.vlocity_cmt__PriceListId__c == onlinePriceListId){
                elementMap.put(ele.vlocity_cmt__Code__c,ele.Id);
            }
            else if(ele.vlocity_cmt__PriceListId__c == salesPriceListId){
                elementSalesMap.put(ele.vlocity_cmt__Code__c,ele.Id);
            }
        }
        List<vlocity_cmt__PriceListEntry__c> priceListEntries=new List<vlocity_cmt__PriceListEntry__c>();
        //need to handle seperate logic for sales ples
        for(vlocity_cmt__PriceListEntry__c entry:[select id,vlocity_cmt__PriceListId__c,vlocity_cmt__ProductId__c,vlocity_cmt__ProductId__r.productCode,vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c from vlocity_cmt__PriceListEntry__c where  (vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c !=null and (vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c  in :clonedCodes or vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c in :clonedSalesCodes)) and  vlocity_cmt__ProductId__r.productcode!=null and vlocity_cmt__ProductId__r.productcode in :productMap.keySet() and vlocity_cmt__PriceListId__c in (:salesPriceListId,:onlinePriceListId) WITH SECURITY_ENFORCED])
        {
            if(entry.vlocity_cmt__PriceListId__c == onlinePriceListId  && productPleMap.get(entry.vlocity_cmt__ProductId__r.productCode)!=null
               && productPleMap.get(entry.vlocity_cmt__ProductId__r.productCode).contains(entry.vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c) 
               && productMap.get(entry.vlocity_cmt__ProductId__r.productcode)!=null 
               && productMap.get(entry.vlocity_cmt__ProductId__r.productcode).Id==entry.vlocity_cmt__ProductId__c)
            {
                productPleMap.get(entry.vlocity_cmt__ProductId__r.productCode).remove(entry.vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c);
            }
            else if (entry.vlocity_cmt__PriceListId__c == salesPriceListId  && productSalesPleMap.get(entry.vlocity_cmt__ProductId__r.productCode) != null
                     && productSalesPleMap.get(entry.vlocity_cmt__ProductId__r.productCode).contains(entry.vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c) 
                     && productMap.get(entry.vlocity_cmt__ProductId__r.productcode)!=null 
                     && productMap.get(entry.vlocity_cmt__ProductId__r.productcode).Id==entry.vlocity_cmt__ProductId__c)
            {
                productSalesPleMap.get(entry.vlocity_cmt__ProductId__r.productCode).remove(entry.vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c);
            }
        }
        for(Load_Product__c prod:newProds)
        {
            if(productPleMap.get(prod.sapId__c).contains('OT-'+String.valueOf(prod.nrc__c)))
                priceListEntries.add(createPriceListEntry(onlinePriceListId,productMap.get(prod.SAPID__c).Id,'One Time Std Price',elementMap.get('OT-'+String.valueOf(prod.nrc__c)),false,String.valueOf(prod.nrc__c)+' SEK'));
            if(productPleMap.get(prod.sapId__c).contains('OTN1-'+String.valueOf(prod.NRCN1__c)))
                priceListEntries.add(createPriceListEntry(onlinePriceListId,productMap.get(prod.SAPID__c).Id,'One Time Std Price N1',elementMap.get('OTN1-'+String.valueOf(prod.NRCN1__c)),true,'OTN1-'+String.valueOf(prod.NRCN1__c)+' SEK'));
            if(productPleMap.get(prod.sapId__c).contains('OTN2-'+String.valueOf(prod.NRCN2__c)))
                priceListEntries.add(createPriceListEntry(onlinePriceListId,productMap.get(prod.SAPID__c).Id,'One Time Std Price N2',elementMap.get('OTN2-'+String.valueOf(prod.NRCN2__c)),false,'OTN2-'+String.valueOf(prod.NRCN2__c)+' SEK'));
            if(productPleMap.get(prod.sapId__c).contains('RM-'+String.valueOf(prod.mrc__c)))
                priceListEntries.add(createPriceListEntry(onlinePriceListId,productMap.get(prod.SAPID__c).Id,'Recurring Monthly Std Price',elementMap.get('RM-'+String.valueOf(prod.mrc__c)),true,'RM-'+String.valueOf(prod.mrc__c)+' SEK'));
            if(productSalesPleMap.get(prod.sapId__c).contains('OT-'+String.valueOf(prod.nrc__c)))
                priceListEntries.add(createPriceListEntry(salesPriceListId,productMap.get(prod.SAPID__c).Id,'One Time Std Price',elementSalesMap.get('OT-'+String.valueOf(prod.nrc__c)),true,'OT-'+String.valueOf(prod.nrc__c)+' SEK'));
        }
        if(priceListEntries.size()>0 && priceListEntries.size()<100)
        {
            insert priceListEntries;
        }
    }
    //Creates a product  object and returns it to the invoker
    private static Product2 createProduct(Load_Product__c prod,Product2 product,String type){
        product.isActive=prod.Active__c;
        product.phimId__c=prod.phimId__c;
        product.C2BC_Category__c=prod.C2BC_Category__c;
        product.C2BC_Subcategory__c=prod.C2BC_Subcategory__c;
        product.vlocity_cmt__ObjectTypeId__c =prod.C2BC_Subcategory__c == 'mobiledevice'?Id.valueOf(System.Label.TeliaSE_productObjectType):Id.valueOf(System.Label.TeliaSE_accessoryObjectType);
        product.Parent_Family__c = prod.C2BC_Subcategory__c == 'mobiledevice'?'Mobile Hardware':'Mobile Accessory';
        product.Name=prod.ProductNameSwe__c;
        product.vlocity_cmt__IsNotAssetizable__c=prod.non_assetizable__c;
        product.Ordering_Flag__c=type=='Product'?'Salesflow':'';
        product.productCode=prod.sapId__c;
        product.MC_Product_Name_Eng__c=prod.ProductNameEng__c;
        product.vlocity_cmt__SellingStartDate__c =prod.SaleStartDate__c;
        product.vlocity_cmt__IsConfigurable__c=true;
        product.vlocity_cmt__SpecificationType__c='Product';
        product.vlocity_cmt__IsOrderable__c=false;
        product.vlocity_cmt__Status__c='Active';
        product.vlocity_cmt__FulfilmentStartDate__c=(product.vlocity_cmt__FulfilmentStartDate__c !=null && product.vlocity_cmt__FulfilmentStartDate__c <product.vlocity_cmt__SellingStartDate__c ) || product.vlocity_cmt__SellingStartDate__c == null?product.vlocity_cmt__SellingStartDate__c:product.vlocity_cmt__FulfilmentStartDate__c;
        return product;
    }
    
    //creates relationship between parent and child product
    private static vlocity_cmt__ProductChildItem__c processParentChildRelationship(Id parentId,Id childId,Integer quantity,String bundleType){
        if(String.isBlank(parentId) || String.isBlank(childId)){
            return null;
        }
        vlocity_cmt__ProductChildItem__c  childItem=new vlocity_cmt__ProductChildItem__c();
        childItem.vlocity_cmt__ParentProductId__c=parentId;
        childItem.vlocity_cmt__ChildProductId__c=childId;
        childItem.vlocity_cmt__ChildLineNumber__c='1';
        childItem.vlocity_cmt__MaxQuantity__c=bundleType==null?99:1;
        childItem.vlocity_cmt__MinQuantity__c=bundleType==null?0:1;
        childItem.vlocity_cmt__Quantity__c=quantity;
        if(String.IsNotBlank(bundleType)){
            childItem.vlocity_cmt__IsVirtualItem__c=bundleType.equals('salesBundle')?true:false;    
        }
        return  childItem;
    }
    
    
    
    public static void addRecommendedProduct(List<Load_Product__c> bundles){
        List<String> recomendedPhimIds=new List<String>();
        List<String> bundlePhimIds=new List<String>();
        Map<String,Product2> phimIdtoProductIdMap=new Map<String,Product2>();
        Set<String> compatibleAccessories=new Set<String>();
        Set<String> recommendedAccessories=new Set<String>();
        Set<String> existingCompatibleAccessories=new Set<String>();
        Set<String> existingRecommendedAccessories=new Set<String>();
        Set<String> addingCompatibleAccessories=new Set<String>();
        Set<String> addingRecommendedAccessories=new Set<String>();
        Set<String> deletingCompatibleAccessories=new Set<String>();
        Set<String> deletingRecommendedAccessories=new Set<String>();
        Set<String> missingAccessorries=new Set<String>();
        Set<String> finaldeletion=new Set<String>();
        List<vlocity_cmt__ProductRelationship__c> relationships=new List<vlocity_cmt__ProductRelationship__c>();
        List<vlocity_cmt__ProductRelationship__c> toBeDeleted=new List<vlocity_cmt__ProductRelationship__c>();
        Map<String,vlocity_cmt__ProductRelationship__c> existingRelationshipsMap=new Map<String,vlocity_cmt__ProductRelationship__c>();
        for(Load_Product__c prod: bundles)
        {
            if(prod.recomendedAccessories__c !=null){
                bundlePhimIds.add(prod.phimId__c);
                List<Product2> bundleProd=[select id,name from Product2 where phimId__c=:bundlePhimIds WITH SECURITY_ENFORCED];
                Map<String,Object> accessoryMap=(Map<String,Object>)JSON.deserializeUntyped(prod.recomendedAccessories__c);                
                for(String key:accessoryMap.keySet())
                {
                    for(Object obj:(List<Object>)accessoryMap.get(key))
                    {
                        processRecommendationsHelper(key,String.valueOf(obj),compatibleAccessories,recommendedAccessories);
                    }
                }
                //Process accessories for sales
                if(compatibleAccessories.size() > 0)
                {
                    processAccessoriesForSales(prod,compatibleAccessories);                    
                }
                if(bundlePhimIds.size() > 0)
                {
                    for(vlocity_cmt__ProductRelationship__c relationship:[select vlocity_cmt__RelatedProductId__r.phimId__c,vlocity_cmt__Product2Id__r.phimId__c,vlocity_cmt__RelationshipType__c from vlocity_cmt__ProductRelationship__c where vlocity_cmt__Product2Id__r.phimId__c =:bundlePhimIds and vlocity_cmt__RelationshipType__c in ('Recommends','Compatible') WITH SECURITY_ENFORCED])
                    {
                        existingRelationshipsMap.put(relationship.vlocity_cmt__RelatedProductId__r.phimId__c,relationship);
                        processRecommendationsHelper(relationship.vlocity_cmt__RelationshipType__c,relationship.vlocity_cmt__RelatedProductId__r.phimId__c,existingCompatibleAccessories,existingRecommendedAccessories);
                    }
                }
                for(Product2 product:[select id,name,phimId__c from Product2 where (phimId__c=:compatibleAccessories  or phimId__c=:recommendedAccessories) and phimId__c!=null WITH SECURITY_ENFORCED])
                {
                    phimIdtoProductIdMap.put(product.phimId__c,product);
                }
                                
                compareAccessories(compatibleAccessories,existingCompatibleAccessories,addingCompatibleAccessories);
                compareAccessories(existingCompatibleAccessories,compatibleAccessories,deletingCompatibleAccessories);
                compareAccessories(recommendedAccessories,existingRecommendedAccessories,addingRecommendedAccessories);
                compareAccessories(existingRecommendedAccessories,recommendedAccessories,deletingRecommendedAccessories);
                
                finaldeletion.addAll(deletingCompatibleAccessories);
                finaldeletion.addAll(deletingRecommendedAccessories);
             
                //I want to do this
                addRelationships('Compatible',bundleProd[0],addingCompatibleAccessories,relationships,missingAccessorries,phimIdtoProductIdMap);
                addRelationships('Recommends',bundleProd[0],addingRecommendedAccessories,relationships,missingAccessorries,phimIdtoProductIdMap);
                
                //but other person ends up doing this 
                deleteRelationships(finaldeletion,existingRelationshipsMap,toBeDeleted);
                
                if(relationships.size() > 0 )
                {
                    Database.saveResult[] result = Database.insert(relationships,false);
                    //process errors
                } 
                if(toBeDeleted.size() > 0)
                {
                    Database.delete(toBeDeleted,false);
                    //process error
                }
                if(missingAccessorries.size() >0)
                {
                    String missingCodesString='';
                    for(String str:missingAccessorries)
                    {
                        missingCodesString+=str+',';
                    }
                    missingCodesString=missingCodesString.removeEnd(',');
                    bundles[0].error_description__c=bundles[0].error_description__c == null ||(bundles[0].error_description__c!=null && bundles[0].error_description__c.contains('Set of accessories are not present in Amanda'))?'Set of accessories are not present in Amanda '+missingCodesString:bundles[0].error_description__c + 'Set of accessories are not present in Amanda '+missingCodesString;
                    update bundles;
                }
            }
        }
    }
    
    private static void productActionMapping(List<Load_Product__c> newProds){
        for(MCOnline_Product_Mappings__mdt mapping:[select id,Action__c,HWItemCategory_SV__c,SuperCategory__c,HWItemCategory_EN__c,PhimProductGroup__c from MCOnline_Product_Mappings__mdt WITH SECURITY_ENFORCED])
        {
            productMappings.put(mapping.PhimProductGroup__c,mapping);
        }
        for(Load_Product__c prod:newProds)
        {   
            if(productMappings.get(prod.PhimProductGroup__c)!= null)
            {
                prod.action__C=productMappings.get(prod.PhimProductGroup__c).Action__c; 
                prod.HWItemCategory__c=productMappings.get(prod.PhimProductGroup__c).HWItemCategory_SV__c;

                prod.HWItemCategory_EN__c=productMappings.get(prod.PhimProductGroup__c).HWItemCategory_EN__c;

                switch on productMappings.get(prod.PhimProductGroup__c).HWItemCategory_EN__c
                {
                    when 'Mobile Phones'
                    {
                        prod.C2BC_Category__c=prod.type__c == 'Bundle'?'HW bundle':'goods';
                        prod.C2BC_Subcategory__c='mobiledevice';
                    }
                    when 'Tablets'
                    {
                        prod.C2BC_Category__c=prod.type__c == 'Bundle'?'HW bundle':'goods';
                        prod.C2BC_Subcategory__c='tablets';
                    }
                    when else {
                        prod.C2BC_Category__c=prod.type__c == 'Bundle'?'HW bundle':'goods';
                        prod.C2BC_Subcategory__c='accessories';
                    }
                }
            }
        }
    }
    private static void calculateNPrice(List<Load_Product__c> newProds){
        Map<String,PriceCalculation__c> pricingEntries=new Map<String,PriceCalculation__c>();
        for(PriceCalculation__c pricingRow:PriceCalculation__c.getAll().values())
        {
            pricingEntries.put(pricingRow.Brand__c+pricingRow.Category__c,pricingRow);
        }
        for(Load_Product__c prod:newProds)
        {
            prod.MRC__c=0;
            if(prod.type__c!='Bundle')
            {
                PriceCalculation__c entry=pricingEntries.get((prod.Brand__c=='Apple'?'Apple':'Not apple')+productMappings.get(prod.PhimProductGroup__c)?.SuperCategory__c);
                if(entry == null){
                    continue;
                }
                prod.NRCN1__c=entry!=null?entry.CalculationRule__c =='Mark up'?((prod.Cost_Price__c+((entry.N1__c * prod.Cost_Price__c)/100))>prod.NRC__c)|| prod.Cost_Price__c == 0?prod.NRC__c:prod.Cost_Price__c+((entry.N1__c * prod.Cost_Price__c)/100):entry.CalculationRule__c =='discount'?prod.NRC__c-((entry.N1__c * prod.NRC__c)/100):0:prod.NRC__c;
                prod.NRCN2__c=entry!=null?entry.CalculationRule__c =='Mark up'?((prod.Cost_Price__c+((entry.N2__c * prod.Cost_Price__c)/100))>prod.NRC__c)|| prod.Cost_Price__c == 0?prod.NRC__c:prod.Cost_Price__c+((entry.N2__c * prod.Cost_Price__c)/100):entry.CalculationRule__c =='discount'?prod.NRC__c-((entry.N2__c * prod.NRC__c)/100):0:prod.NRC__c;
                prod.NRCN1__c=prod.NRCN1__c.setScale(2);
                prod.NRCN2__c=prod.NRCN2__c.setScale(2);
                
            }
        }
    }
    public static void validateDateAndAttributes(List<Load_Product__c> newProds){
        String message ='';
        for(Load_Product__c prod:newProds)
        {
            if(prod.SalesStart__c !=null)
            {
                try{
                    String[] dateData=prod.SalesStart__c.split('T')[0].split('-');
                    String[] timeData=prod.SalesStart__c.split('T')[1].split(':');
                    if(dateData[0] !='0001')
                    {
                        DateTime newDate=DateTime.newInstanceGMT(Integer.valueOf(dateData[0]), Integer.valueOf(dateData[1]), Integer.valueOf(dateData[2]),Integer.valueOf(timeData[0]), Integer.valueOf(timeData[1]), Integer.valueOf(timeData[2]));
                        prod.SaleStartDate__c=newDate;
                    }
                }
                catch(Exception e){
                    message+=e.getMessage()+'\n';
                }
            }
            String memory=String.isNotBlank(prod.Memory__c) && prod.Memory__c.isNumeric()?prod.Memory__c+'GB':prod.Memory__c;
            attributes=new Map<String,String>();
            attributes.put('ATT_HW_SAP_ID', prod.SAPID__c);
            attributes.put('ATT_HW_COLOR', prod.Color__c);
            attributes.put('ATT_HW_BRAND', prod.Brand__c);
            attributes.put('ATT_HW_MEMORY', memory);

            attributes.put('ATT_HW_CATEGORY',prod.HWItemCategory_EN__c);

            attributes.put('ATT_HW_CATEGORY_SV',prod.HWItemCategory__c);
            prod.Attribute__c=JSON.serialize(attributes);
            if(((String.isBlank(prod.SAPID__c)||String.isBlank(prod.Color__c)|| String.isBlank(prod.Brand__c)||String.isBlank(prod.HWItemCategory__c))||(String.isBlank(memory) && prod.C2BC_Subcategory__c == 'mobiledevice')) && prod.type__c !='Bundle')
            {
                message+='Some attributes are missing for the product \n';   
                LoadProduct_Handler.sendEmail('Some attributes are missing for the product '+prod.phimId__c);
            }
            prod.error_description__c=message;
        }
        update newProds;    
    }
    
    private static vlocity_cmt__PricingElement__c getPricingElements(Double amount,String variableId,String code,Id priceListId,String helpText){
        vlocity_cmt__PricingElement__c   element=new vlocity_cmt__PricingElement__c ();
        element.vlocity_cmt__Amount__c=amount;
        element.vlocity_cmt__ObjectTypeId__c=Id.valueOf(System.Label.TeliaSE_chargeObjectType);
        element.vlocity_cmt__PricingVariableId__c=variableId;
        element.vlocity_cmt__Code__c=code;
        element.Name=amount+' SEK';
        element.vlocity_cmt__DisplayText__c=amount+' SEK';
        element.vlocity_cmt__PriceListId__c=priceListId;
        element.vlocity_cmt__IsReusable__c=true;
        element.vlocity_cmt__IsActive__c=true;
        element.vlocity_cmt__HelpText__c=helpText;
        element.vlocity_cmt__CurrencyCode__c='Kr';
        element.vlocity_cmt__CalculationType__c='Simple';
        return element;
    }
    
    
    public static void removeProducts(List<Load_Product__c> prods){
        Set<String> idsForDeletion=new Set<String>();
        for(Load_Product__c prod:prods)
        {
            if(prod.type__c == 'Bundle')
            {
                idsForDeletion.add(prod.phimId__c);
            }
            else if(prod.type__c == 'Product')
            {
                idsForDeletion.add(prod.sapId__c);                
            }
        }
        if(idsForDeletion.size()>0)
        {
            List<vlocity_cmt__ProductChildItem__c> itemsForDeletion=[select id,vlocity_cmt__ParentProductId__r.productcode from vlocity_cmt__ProductChildItem__c  where vlocity_cmt__ChildProductId__r.productcode =:idsForDeletion and name !='Root PCI' WITH SECURITY_ENFORCED limit 9999 ];
            Database.delete(itemsForDeletion, false);
            //update the products to inactive
            List<Product2> products=[select id from Product2 where productcode=:idsForDeletion WITH SECURITY_ENFORCED];
            for(Product2 prod:products){
                prod.IsActive=false;
            }
            Database.update(products, false);
            for(Load_Product__c prod:prods)
            {
                prod.success__c=true;
            }
            update prods;
        }
    }


    public static void removeunusedBundles()
    {
        try{
            Set<String> bundleCodes=new Set<String>();
            Set<String> bundleCodesWithProducts=new Set<String>();
            Map<String,vlocity_cmt__ProductChildItem__c> itemsToBeDeleted=new Map<String,vlocity_cmt__ProductChildItem__c>();
            List<vlocity_cmt__ProductChildItem__c> offerToBundlePCIs=[select id,vlocity_cmt__ChildProductId__r.productcode from vlocity_cmt__ProductChildItem__c  where (vlocity_cmt__ParentProductId__r.productcode like 'HW_ACCESSORIES%' or vlocity_cmt__ParentProductId__r.productcode like 'HW_MOBILEDEVICES%' or vlocity_cmt__ParentProductId__r.productcode like 'HW_TABLETS%') and name !='Root PCI' WITH SECURITY_ENFORCED];
            for(vlocity_cmt__ProductChildItem__c item:offerToBundlePCIs){
                bundleCodes.add(item.vlocity_cmt__ChildProductId__r.productcode);
            }
            for(AggregateResult result:[select vlocity_cmt__ParentProductId__r.productcode code from vlocity_cmt__ProductChildItem__c  where vlocity_cmt__ParentProductId__r.productcode =:bundleCodes and vlocity_cmt__ParentProductId__r.productcode!=null  and name != 'Root PCI' WITH SECURITY_ENFORCED group by  vlocity_cmt__ParentProductId__r.productcode having count(id)>0 ])
            {
                bundleCodesWithProducts.add(String.valueOf(result.get('code')));
            }
            for(vlocity_cmt__ProductChildItem__c item:offerToBundlePCIs)
            {
                if(!bundleCodesWithProducts.contains(item.vlocity_cmt__ChildProductId__r.productcode))
                {
                    itemsToBeDeleted.put(item.vlocity_cmt__ChildProductId__r.productcode,item);
                }
            }
            if(itemsToBeDeleted.size() > 0)
            {
                Database.delete(itemsToBeDeleted.values(),false);
                List<Product2> bundlesTobeInactivated=[select id from Product2 where productcode =:itemsToBeDeleted.keySet() WITH SECURITY_ENFORCED];
                for(Product2 prod:bundlesTobeInactivated)
                {
                    prod.IsActive=false;
                }
                Database.update(bundlesTobeInactivated,false);
            }
        }catch(Exception e){
            sendEmail('Exception occurred at '+e.getLineNumber()+' ' +e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    @TestVisible
    private static String getOfferCode(String bundlePhimId,Decimal count,String c2bcsubcategory)
    {
        List<Id> bundleIds=new List<Id>();
        String existingOfferCode=[select id,vlocity_cmt__ParentProductId__r.productCode from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__r.ProductCode=:bundlePhimId WITH SECURITY_ENFORCED limit 1]?.vlocity_cmt__ParentProductId__r.productCode;
        String offerCode;
        if(existingOfferCode !=null)
            return existingOfferCode;
        return getOnlineBundle(count,c2bcsubcategory);
    }
    @TestVisible
    private static String createNewOffer(String offerCode,Decimal count)
    {
        String parentfamily = 'Mobile Hardware';
        if(offerCode.contains('HW_MOBILEDEVICES')){
            offerCode=offercode == 'HW_MOBILEDEVICES'?'HW_MOBILEDEVICES1':'HW_MOBILEDEVICES'+(Integer.valueOf(offerCode.subStringAfter('HW_MOBILEDEVICES'))+1);    
            parentfamily = 'Mobile Hardware';
        }else if(offerCode.contains('HW_ACCESSORIES')){
            offerCode=offercode == 'HW_ACCESSORIES'?'HW_ACCESSORIES1':'HW_ACCESSORIES'+(Integer.valueOf(offerCode.subStringAfter('HW_ACCESSORIES'))+1);   
            parentfamily = 'Mobile Accessory';
        }else if(offerCode.contains('HW_TABLETS')){
            offerCode=offercode == 'HW_TABLETS'?'HW_TABLETS1':'HW_TABLETS'+(Integer.valueOf(offerCode.subStringAfter('HW_TABLETS'))+1);    
            parentfamily = 'Other Hardware';
        }
        Product2 offerProduct=new Product2();
        offerProduct.Name=offerCode.subStringAfter('HW_');
        offerProduct.TeliaSE_ItemsCount__c=count;
        offerProduct.productCode=offerCode;
        offerProduct.isActive=true;
        offerProduct.Parent_Family__c = parentfamily;
        offerProduct.vlocity_cmt__Status__c='Active';
        offerProduct.vlocity_cmt__SpecificationType__c='Offer';
        offerProduct.vlocity_cmt__IsOrderable__c=true;
        offerProduct.C2BC_Category__c='offerbundle';
        offerProduct.Family='Online Order';
        offerProduct.vlocity_cmt__ObjectTypeId__c=Id.valueOf(System.Label.TeliaSE_offerObjectType);
        insert offerProduct;
        Id priceListId=[select id from vlocity_cmt__PriceList__c where vlocity_cmt__Code__c ='ONL_PRICELIST' WITH SECURITY_ENFORCED FOR UPDATE ]?.Id;
        insert new List<sObject>{createPriceListEntry(priceListId,offerProduct.Id,'One Time Std Price',Id.valueOf(System.Label.TeliaSE_zeroPricingElementId),true,'0 SEK'),createCatalogRelationShip(offerProduct.Id,offerCode)};
            return offerCode;
    }
    
    private static vlocity_cmt__CatalogProductRelationship__c createCatalogRelationShip(Id productId,String name)
    {
        String accessoryCode=System.Label.TeliaSE_AccessoryCatalogCode;
        String mobiledeviceCode=System.Label.TeliaSE_MobileCatalogCode;
        String catalogCode=name.contains('HW_MOBILEDEVICES')?mobiledeviceCode:name.contains('HW_ACCESSORIES')?accessoryCode:'TABLET';
        vlocity_cmt__CatalogProductRelationship__c  relation=new vlocity_cmt__CatalogProductRelationship__c();
        relation.vlocity_cmt__Product2Id__c=productId;
        relation.vlocity_cmt__IsActive__c=true;
        relation.vlocity_cmt__EffectiveDate__c=Date.today();
        relation.Name=name;
        relation.vlocity_cmt__CatalogId__c=[select id from vlocity_cmt__Catalog__c  where vlocity_cmt__CatalogCode__c  =:catalogCode limit 1]?.Id;
        return relation;
    }
    private static vlocity_cmt__PriceListEntry__c createPriceListEntry(Id priceListId,Id productId,String name,Id pricingElementId,Boolean isActive,String displayText){
        vlocity_cmt__PriceListEntry__c  entry=new vlocity_cmt__PriceListEntry__c();
        entry.vlocity_cmt__PricingElementId__c=pricingElementId;
        entry.vlocity_cmt__PriceListId__c=priceListId;
        entry.vlocity_cmt__IsActive__c=isActive;
        entry.vlocity_cmt__IsBasePrice__c=true;
        entry.Name=name;
        entry.vlocity_cmt__DisplayText__c=displayText;
        entry.vlocity_cmt__ProductId__c=productId;
        return entry;
    }
    
    public static void sendEmail(String body)
    {
        
        String emailId=System.Label.TeliaSE_AMEmailId;
        String[] emailIds=emailId.Split(';');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailIds;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Exception in product import';
        message.plainTextBody = body;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }




    //Calculats number of grand child products available at offer level
    public static void processNumberOfChildItemsAtOfferLevel(){
    try{
        Set<Id> productIdsToBeremovedFromCatalog=new Set<Id>();
        Map<String,String> offerToBundle=new Map<String,String>();
        Map<String,Integer> bundleChildCount=new Map<String,Integer>();
        Set<String> bundleCodes=new Set<String>();
        Map<String,Integer> offerChildCount=new Map<String,Integer>();
        List<vlocity_cmt__ProductChildItem__c> itemsForprocessing;
        List<Product2> prods;
        String catalogSwitch=System.Label.TeliaSE_catalogSwitch;
        if(catalogSwitch.equalsIgnoreCase('ON')){
            itemsForprocessing=[select vlocity_cmt__ParentProductId__r.productCode,vlocity_cmt__ChildProductId__r.productcode from vlocity_cmt__ProductChildItem__c where (vlocity_cmt__ParentProductId__r.productcode like 'HW_ACCESSORIES%') and (NOT vlocity_cmt__ParentProductId__r.ProductCode like '%OLD')  and name !='Root PCI' WITH SECURITY_ENFORCED];
        }
        else
        { 
            itemsForprocessing=[select vlocity_cmt__ParentProductId__r.productCode,vlocity_cmt__ChildProductId__r.productcode from vlocity_cmt__ProductChildItem__c where (vlocity_cmt__ParentProductId__r.productcode like 'HW_MOBILEDEVICE%' or vlocity_cmt__ParentProductId__r.productcode like 'HW_ACCESSORIES%') and (NOT vlocity_cmt__ParentProductId__r.ProductCode like '%OLD')  and name !='Root PCI' WITH SECURITY_ENFORCED];
        }
        for(vlocity_cmt__ProductChildItem__c item:itemsForprocessing)
        {
            bundleCodes.add(item.vlocity_cmt__ChildProductId__r.productcode);
            offerToBundle.put(item.vlocity_cmt__ChildProductId__r.productcode,item.vlocity_cmt__ParentProductId__r.productCode);
        }
        for(AggregateResult res:[select count(id) childCount,vlocity_cmt__ParentProductId__r.productCode code  from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.productcode =:bundleCodes  and name !='Root PCI' WITH SECURITY_ENFORCED group by vlocity_cmt__ParentProductId__r.productCode])
        {
            bundleChildCount.put(String.valueOf(res.get('code')),Integer.valueOf(res.get('childCount')));
        }
        for(String code:offerToBundle.keySet())
        {
            if(offerChildCount.get(offerToBundle.get(code)) == null)
            {
                offerChildCount.put(offerToBundle.get(code),bundleChildCount.get(code));
            }
            else
            {
                Integer newVal=offerChildCount.get(offerToBundle.get(code))+bundleChildCount.get(code);
                offerChildCount.put(offerToBundle.get(code),newVal);
            }
        }
        if(catalogSwitch.equalsIgnoreCase('ON')){
            prods=[select id,ProductCode,TeliaSE_ItemsCount__c from Product2 where (productcode like 'HW_ACCESSORIES%') and (NOT ProductCode like '%OLD') and vlocity_cmt__ObjectTypeId__r.Name ='Offer' WITH SECURITY_ENFORCED];
        }
        else{
            prods=[select id,ProductCode,TeliaSE_ItemsCount__c from Product2 where (productcode like 'HW_MOBILEDEVICE%' or productcode like 'HW_ACCESSORIES%') and (NOT ProductCode like '%OLD') and vlocity_cmt__ObjectTypeId__r.Name ='Offer' WITH SECURITY_ENFORCED];                            
        }
        for(Product2 prod:prods)
        {
            prod.TeliaSE_ItemsCount__c=offerChildCount.get(prod.productcode)!=null?offerChildCount.get(prod.productcode):0;
            if(prod.TeliaSE_ItemsCount__c==0)
            {
                productIdsToBeremovedFromCatalog.add(prod.Id);
            }
        }
        update prods;
        //deletes the offer which doesn't have any child items 
        if(productIdsToBeremovedFromCatalog.size() > 0){
            List<vlocity_cmt__CatalogProductRelationship__c> items=[select id from vlocity_cmt__CatalogProductRelationship__c where vlocity_cmt__Product2Id__c=:productIdsToBeremovedFromCatalog WITH SECURITY_ENFORCED];
            Database.DeleteResult[] result=Database.delete(items,false);
            //processErrors
        }
    }catch(Exception e){
        sendEmail('Exception occurred at '+e.getLineNumber()+' ' +e.getMessage()+' '+e.getStackTraceString());
    }
    }

    
    //create MCOnline bundle
    private static String getOnlineBundle(Decimal count,String c2bcsubcategory){
        String offerCode;
        Integer max=0;
        List<Id> bundleIds=new List<Id>();
        String itemType;
        String subStr;
        Product2 product;
        Boolean existingOfferFound=false;
        if(c2bcsubcategory == 'mobiledevice'){
            itemType = 'HW_MOBILEDEVICES%';
            subStr = 'HW_MOBILEDEVICES';
        }else if(c2bcsubcategory == 'accessories') {
            itemType = 'HW_ACCESSORIES%';
            subStr = 'HW_ACCESSORIES';
        }else if(c2bcsubcategory == 'tablets') {
            itemType = 'HW_TABLETS%';
            subStr = 'HW_TABLETS';
        }
        
        List<Product2> offerProducts=[select id,ProductCode,TeliaSE_ItemsCount__c from Product2 where ProductCode like :itemType and (NOT ProductCode like '%OLD') and vlocity_cmt__ObjectTypeId__r.Name ='Offer' WITH SECURITY_ENFORCED];
        if(offerProducts.size() == 0){
            return createNewOffer(subStr,count);
        }
        for(Product2 prod:offerProducts)
        {
            if (prod.TeliaSE_ItemsCount__c + count<20)
            {
                existingOfferFound=true;
                product=prod;
                break;
            }
            if(Integer.valueOf(prod.ProductCode.subStringAfter(subStr))>max)
            {
                max=Integer.valueOf(prod.ProductCode.subStringAfter(subStr));
                offerCode=prod.ProductCode;
            }
        }
        if(existingOfferFound)
        {
            product.TeliaSE_ItemsCount__c+=count;
            update product;
            return product.productCode;
        }
        else{ 
            return createNewOffer(offerCode,count);
        }
    }

    private static void processRecommendationsHelper(String key,String value,Set<String> compatibleAccessories,Set<String> recommendedAccessories){
        if(key =='Compatible')
        {
            compatibleAccessories.add(value);
        }
        else if(key =='Recommends')
        {
            recommendedAccessories.add(value);
        }
    }

    private static void compareAccessories(Set<String> iteratedList,Set<String> comparedList,Set<String> result){
        for(String acc:iteratedList)
        {
            if(!comparedList.contains(acc))
            {
                result.add(acc);
            }
        }
    }

    private static void addRelationships(String type,Product2 product,Set<String> inputList,List<vlocity_cmt__ProductRelationship__c> outputList,Set<String> missingList,Map<String,Product2> phimToProductIdMap)
    {
        vlocity_cmt__ProductRelationship__c relationship;
        for(String key:inputList)
        {
            if(phimToProductIdMap.get(key)!=null)
            {
                relationship=new vlocity_cmt__ProductRelationship__c();
                relationship.vlocity_cmt__Product2Id__c=product.Id;
                relationship.vlocity_cmt__RelatedProductId__c=phimToProductIdMap.get(key).Id;
                relationship.vlocity_cmt__RelationshipType__c=type;
                relationship.vlocity_cmt__DefaultQuantity__c =1;
                relationship.vlocity_cmt__MinQuantity__c=0;
                relationship.vlocity_cmt__MaxQuantity__c=1;
                relationship.vlocity_cmt__IsConditional__c=true;
                relationship.vlocity_cmt__Family__c ='Online';
                relationship.name=product.name+' '+relationship.vlocity_cmt__RelationshipType__c+' '+phimToProductIdMap.get(key).Name;
                relationship.name=relationship.name.length()>80?relationship.name.subString(0,79):relationship.name;
                outputList.add(relationship);
            }
            else 
            {
                missingList.add(key);
            }
        }
    }

    private static void processAccessoriesForSales(Load_Product__c loadProd,Set<String> accessories)
    {
        try{
            Set<String> bundleBrands=new Set<String>(System.Label.TeliaSE_salesAccessoriesBrands.split(',')); 
            Map<String,Id> productCodetoId=new Map<String,Id>();
            String brandCode=loadProd.brand__c !=null && bundleBrands.contains(loadProd.brand__c.toUppercase())?'HW_VIRTUAL_GP_'+loadProd.brand__c.toUppercase()+'_OFFER':'HW_VIRTUAL_GP_OTHER_OFFER';
            Set<String> productCodes=new Set<String>();
            List<vlocity_cmt__ProductChildItem__c> newPCIs=new List<vlocity_cmt__ProductChildItem__c>();
            for(vlocity_cmt__ProductChildItem__c item:[select vlocity_cmt__ChildProductId__r.productcode from vlocity_cmt__ProductChildItem__c  where vlocity_cmt__ChildProductId__r.TeliaSE_Object_Type_Name__c !='Mobile Handset Product Specification' and vlocity_cmt__ParentProductId__r.productcode =:accessories and name !='Root PCI' WITH SECURITY_ENFORCED])
            {
                productCodes.add(item.vlocity_cmt__ChildProductId__r.productcode);
            }
            if(productCodes.size()>0)
            {
                for(vlocity_cmt__ProductChildItem__c item:[select vlocity_cmt__ChildProductId__r.productcode from vlocity_cmt__ProductChildItem__c  where vlocity_cmt__ParentProductId__r.productcode =:brandCode and vlocity_cmt__ChildProductId__r.productcode =:productCodes and  vlocity_cmt__ChildProductId__r.productcode!=null and name !='Root PCI' WITH SECURITY_ENFORCED])
                {
                    if(productCodes.contains(item.vlocity_cmt__ChildProductId__r.productcode))
                    {
                        productCodes.remove(item.vlocity_cmt__ChildProductId__r.productcode);
                    }
                }
                if(productCodes.size() > 0)
                {
                    for(Product2 prod:[select id,productcode from Product2  where productcode=:productCodes or productcode=:brandCode WITH SECURITY_ENFORCED])
                    {
                        productCodetoId.put(prod.productcode,prod.id);
                    }
                }
                for(String productCode:productCodes){
                    vlocity_cmt__ProductChildItem__c childToParentRelationShip=processParentChildRelationship(productCodetoId.get(brandCode),productCodetoId.get(productCode),0,null);
                    if(childToParentRelationShip == null)
                    {
                        loadProd.error_description__c+=' child productcode:'+productCode+'  or parent product:'+brandCode+' is null,'; 
                    }
                    else{
                        newPCIs.add(childToParentRelationShip);
                    }
                }
                if(newPCIs.size()>0)
                {
                    Database.SaveResult[] result=Database.insert(newPCIs,false);
                    //process errors here
                }
            }
        }catch(Exception e){
            loadProd.error_description__c+='Exception occurred at '+e.getLineNumber()+' ' +e.getMessage()+' '+e.getStackTraceString();
        }
    }


    private static void deleteRelationships(Set<String> itemsToDelete,Map<String,vlocity_cmt__ProductRelationship__c> phimIdtoRelationMap,List<vlocity_cmt__ProductRelationship__c> toBeDeleted)
    {
        for(String key:itemsToDelete)
        {
            toBeDeleted.add(phimIdtoRelationMap.get(key));
        }
    }

    private static Id getPricelistId(String code){
            return [select id from vlocity_cmt__PriceList__c where vlocity_cmt__Code__c =:code FOR UPDATE ]?.Id;       
    }
}