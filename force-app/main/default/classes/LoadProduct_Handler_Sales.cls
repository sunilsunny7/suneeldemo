public class LoadProduct_Handler_Sales {
    
    /****************************************************************************************************************************
* method                  processProductsFromBatch
* params                  Collection of Load_Product__c
* @description            Upserts products and then creates product child relationship between bundle and product
* @created                20-01-2022
* @modified               23-01-2022
******************************************************************************************************************************/
    public static Map<String,Load_Product__c> noduplicateProds=new Map<String,Load_Product__c>();
    public static Map<String,MCONL_ProductMapping__c> productMappings=new Map<String,MCONL_ProductMapping__c>();
    public static Map<String,String> attributes;
    public static void processProductsFromBatch(List<Load_Product__c> newProds)
    {
        List<vlocity_cmt__ProductChildItem__c> bundlePCIs=new List<vlocity_cmt__ProductChildItem__c>();
        
        try{
            // remove duplicate records from staging table
            for(Load_Product__c prod:newProds){
                noduplicateProds.put(prod.PhimId__c,prod);
                System.debug(noduplicateProds.size());
            }
            newProds=noduplicateProds.values();
            //assign dates and attributes to products
            validateDate(newProds);
            //set C2Bc category and sub category
            productActionMapping(newProds);
            //price calculation
            calculateNPrice(newProds);
            // usert bundle
            upsertBundle(newProds);
        }Catch(Exception e){
            String error_message = e.getMessage() + '-> ' + e.getLineNumber();
            System.debug(error_message+e.getStackTraceString());
        }
        
    }
    
    //set dates for products
    private static void validateDate(List<Load_Product__c> newProds){
        for(Load_Product__c prod:newProds)
        {
            prod.SAPID__c=String.isNotBlank(prod.TeliaSE_Product_Service_Code__c)?prod.TeliaSE_Product_Service_Code__c:prod.SAPID__c;
            prod.Name__c=prod.ProductNameSwe__c;
            if(prod.SalesStart__c !=null)
            {
                String[] a=prod.SalesStart__c.split('T')[0].split('-');
                DateTime newDate=DateTime.newInstance(Integer.valueOf(a[0]), Integer.valueOf(a[1]), Integer.valueOf(a[2]));
                prod.SaleStartDate__c=newDate;
            }
            String memory=String.isNotBlank(prod.Memory__c) && prod.Memory__c.isNumeric()?prod.Memory__c+'GB':prod.Memory__c;
            attributes=new Map<String,String>();
            attributes.put('ATT_HW_SAP_ID', prod.SAPID__c);
            attributes.put('ATT_HW_COLOR', prod.Color__c);
            attributes.put('ATT_HW_BRAND', prod.Brand__c);
            attributes.put('ATT_HW_MEMORY', memory);
            attributes.put('ATT_HW_CATEGORY',prod.HWItemCategory__c);
            prod.Attribute__c=JSON.serialize(attributes);
        }
    }
    
    //set C2BC Category and subCategory
    private static void productActionMapping(List<Load_Product__c> newProds){
        for(MCONL_ProductMapping__c mapping:MCONL_ProductMapping__c.getAll().values())
        {
            productMappings.put(mapping.PhimProductGroup__c,mapping);
        }
        for(Load_Product__c prod:newProds)
        {
            if(productMappings.get(prod.PhimProductGroup__c)!= null)
            {
                prod.action__C=productMappings.get(prod.PhimProductGroup__c).Action__c; 
                prod.HWItemCategory__c=productMappings.get(prod.PhimProductGroup__c).HWItemCategory_SV__c;
                switch on productMappings.get(prod.PhimProductGroup__c).HWItemCategory_EN__c
                {
                    when 'Mobile Phones'
                    {
                        prod.C2BC_Category__c='goods';
                        prod.C2BC_Subcategory__c='mobiledevice';
                    }
                    when else {
                        prod.C2BC_Category__c='goods';
                        prod.C2BC_Subcategory__c='accessories';
                    }
                }
            }
        }
    }
    
    //calculate price
    private static void calculateNPrice(List<Load_Product__c> newProds){
    Map<String,PriceCalculation__c> pricingEntries=new Map<String,PriceCalculation__c>();
    for(PriceCalculation__c pricingRow:PriceCalculation__c.getAll().values())
    {
        pricingEntries.put(pricingRow.Brand__c+pricingRow.Category__c,pricingRow);
    }
    for(Load_Product__c prod:newProds)
    {
        prod.MRC__c=0;
        if(prod.Cost_Price__c !=null && prod.type__c!='Bundle')
        {
            PriceCalculation__c entry=pricingEntries.get((prod.Brand__c=='Apple'?'Apple':'Not apple')+productMappings.get(prod.PhimProductGroup__c)?.SuperCategory__c);
            prod.NRCN1__c=entry!=null?entry.CalculationRule__c =='Mark up'?(prod.Cost_Price__c+((entry.N1__c * prod.Cost_Price__c)/100))>prod.NRC__c?prod.NRC__c:prod.Cost_Price__c+((entry.N1__c * prod.Cost_Price__c)/100):entry.CalculationRule__c =='discount'?prod.Cost_Price__c-((entry.N1__c * prod.Cost_Price__c)/100):0:prod.NRC__c;
            prod.NRCN2__c=entry!=null?entry.CalculationRule__c =='Mark up'?(prod.Cost_Price__c+((entry.N2__c * prod.Cost_Price__c)/100))>prod.NRC__c?prod.NRC__c:prod.Cost_Price__c+((entry.N2__c * prod.Cost_Price__c)/100):entry.CalculationRule__c =='discount'?prod.Cost_Price__c-((entry.N2__c * prod.Cost_Price__c)/100):0:prod.NRC__c;
        }
    }
}
    
    //bundle creation sales
    private static void upsertBundle(List<Load_Product__c> newProds){
        Set<String> bundleBrand=new Set<String>();
        List<Load_Product__c> products= new List<Load_Product__c>();
        Set<String> sapIds=new Set<String>();
        List<Load_Product__c> bundleProds= new List<Load_Product__c>();
        Map<String,Load_Product__c> parentProductMap=new Map<String,Load_Product__c>();
        List<vlocity_cmt__ProductChildItem__c> newPCIs=new List<vlocity_cmt__ProductChildItem__c>();
        
        //place all products and Bundles in two different  list
        for(Load_Product__c prod:newProds){
            System.debug('Type+Brand'+prod.Type__c+'->'+prod.Brand__c);
            if(prod.Type__c == 'Product'){
                bundleBrand.add(prod.Brand__c);
                products.add(prod);
                sapIds.add(prod.sapId__c);
                prod.Success__c=true;
            }else if(prod.Type__c == 'Bundle' && !String.isEmpty(prod.Brand__c)){
                bundleProds.add(prod);
            }
            parentProductMap.put(prod.sapId__c,prod);
            System.debug('parentProductMap'+prod.sapId__c+'-->'+prod);
        }
        
        System.debug('bundles'+bundleProds.size());
        // Consider the bundles from staging table and create bundles if they does not exist in the system.
        if(bundleProds.size()>0){
            System.debug('bundle will be created');
            List<String> bundleList = createNewBundle(bundleProds);
            System.debug('bundle created'+bundleList);
            List<String> offerList = new List<String>();
            offerList.add('MOB_HARDWARE_OFFER');
            offerList.add('MOB_ACCESSORY_OFFER');
            List<Product2> bundleId = [Select id,productCode from Product2 where productCode IN:bundleList OR productCode IN:offerList];
            // consider products from staging table and add the products to the system if they do not exist.Update the products if they exist in the system.
            if(sapIds.size()>0){
                Map<String,Id> phimToParentProductIdMap=new Map<String,Id>();
                Map<String,Product2> phimToProductIdMap=new Map<String,Product2>();
                List<Product2> amandaNewProducts=new List<Product2>();
                List<Product2> amandaExistingProducts=new List<Product2>();
                //fetch bundles with name = brand in staging tgable ( brand name is name of existing bundles) from Product2 object
                // create map of parent ( bundles )
                for(Product2 prod:[select id,productCode,Name from Product2 where Name in:bundleBrand and productCode !=null]){
                    phimToParentProductIdMap.put(prod.Name, prod.Id);
                    system.debug('phimToParentProductIdMap'+prod.productCode+'-->'+prod.Id);
                }
                // fetch products with SapId= SapIds in staging table. create map of products
                for(Product2 prod:[select id,productCode from Product2 where productCode in:sapIds and productCode !=null]){
                    phimToProductIdMap.put(prod.productCode, prod);
                }
                // for each records in staging table 
                // check if existing product map created above contains value for the SapId of current product
                // then set the values for updation and add to existing productList
                // Else add the values for new product and add to new product list
                for(Load_Product__c prod:noduplicateProds.values()){
                    if(phimToProductIdMap.get(prod.sapId__c) !=null){
                        amandaExistingProducts.add(createProduct(prod,phimToProductIdMap.get(prod.sapId__c)));
                    }
                    else{
                        amandaNewProducts.add(createProduct(prod,new Product2()));
                    }
                }
                if(amandaExistingProducts.size()>0){
                    for(Product2 existing:amandaExistingProducts){
                        System.debug('existing products--'+existing); 
                    }
                    
                    update amandaExistingProducts;
                    System.debug('updated products--');
                }
                if(amandaNewProducts.size()>0){
                    System.debug('need to insert new products--');
                    insert amandaNewProducts;  
                }
                phimToProductIdMap.clear();
                for(Product2 prod:[select id,productCode from Product2 where productCode in:sapIds and productCode !=null]){
                    system.debug('phimToProductIdMap'+prod.productCode+'-->'+prod);
                    phimToProductIdMap.put(prod.productCode, prod);
                }
                pricing(products,phimToProductIdMap);
                for(vlocity_cmt__ProductChildItem__c item:[select name,vlocity_cmt__ParentProductId__c, vlocity_cmt__ParentProductId__r.ProductCode, vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.productCode from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.productCode !=null and vlocity_cmt__ParentProductId__r.Name in :phimToParentProductIdMap.keySet() and vlocity_cmt__ChildProductId__r.ProductCode !=null and vlocity_cmt__ChildProductId__r.ProductCode in :phimToProductIdMap.keySet() and name !='Root PCI']){
                    if(phimToParentProductIdMap.containsKey(item.vlocity_cmt__ParentProductId__r.Name) && phimToProductIdMap.containsKey(item.vlocity_cmt__ChildProductId__r.productCode)){
                        phimToProductIdMap.remove(item.vlocity_cmt__ChildProductId__r.productCode);
                    }
                }
                for(String productCode:phimToProductIdMap.keySet()){
                    System.debug('productCode--'+productCode);
                    System.debug('parentId--'+phimToParentProductIdMap.get(parentProductMap.get(productCode).Brand__c));
                    System.debug('child Id--'+phimToProductIdMap.get(productCode).Id);
                    newPCIs.add(processParentChildRelationship(phimToParentProductIdMap.get(parentProductMap.get(productCode).Brand__c),phimToProductIdMap.get(productCode).Id,0));
                }
                if(newPCIs.size()>0){
                    insert newPCIs;
                }
                if(bundleProds.size()>0){
                    addRecomendedProduct(bundleProds);
                }
            }
        }
    }
    
    //create sales bundle if it does not exist
    private static List<String> createNewBundle(List<Load_Product__c> bundleProds){
        List<Load_Product__c> prods=new List<Load_Product__c>();
        Map<String,String> brand =new Map<String,String>();
        String offerCode;
        List<String> bundleProd = new List<String>();
        List<vlocity_cmt__ProductChildItem__c> offerBundlePCI =  new List<vlocity_cmt__ProductChildItem__c>();
        for(Load_Product__c prod:bundleProds){
            prods.add(prod);
            brand.put(prod.Brand__c,prod.C2BC_Subcategory__c);
        }
        system.debug('prods-->'+prods);
        system.debug('brand-->'+brand);
        if(prods.size()>0){
            Map<String,String> existingBundleMap=new Map<String,String>();
            List<Product2> newBundleList = new List<Product2>();
            //fetch id/product code of bundle from above and iterate through each records
            for(Product2 existingBundle:[select id,Name,productCode,C2BC_Subcategory__c from Product2 where Name in :brand.keySet() AND IsActive =true]){
                if(existingBundle!=Null){
                    existingBundleMap.put(existingBundle.Name,existingBundle.C2BC_Subcategory__c);
                }
            }
            for(Load_Product__c prod:prods){
                Product2 bundleProduct = new Product2();
                if(existingBundleMap.size()>0){
                    if(!(existingBundleMap.containsKey(prod.Brand__c))){
                        bundleProduct = setFieldValues(prod);
                    }    
                }else{
                    bundleProduct = setFieldValues(prod);
                }
                newBundleList.add(bundleProduct);
                bundleProd.add(bundleProduct.ProductCode);    
            }
            if(newBundleList.size()>0){
                insert  newBundleList;
                // price list entry for bundles
                List<vlocity_cmt__PriceListEntry__c> entries=new List<vlocity_cmt__PriceListEntry__c>();
                for(Product2 prod:newBundleList){
                    //need to create label for Sales
                    entries.add(createPriceListEntry(Id.valueOf(System.Label.TeliaSE_onlinePriceListId),prod.Id,'One Time Std Price',Id.valueOf(System.Label.TeliaSE_zeroPricingElementId),true));
                }
                if(entries.size()>0){
                    insert entries;
                }
            }
        }
        if(bundleProd.size()>0){
            Map<String,Id> OfferMap = new Map<String,Id>();
            List<product2> mobileBundle = new List<product2>();
            List<product2> accessoryBundle = new List<product2>();
            Map<String,List<Product2>> offerBundleMap = new Map<String,List<Product2>>();
            Map<String,List<Product2>> accessoryMap = new Map<String,List<Product2>>();
            for(Product2 prodItem :[select id, ProductCode,C2BC_Subcategory__c from Product2 where ProductCode IN( 'MOB_HARDWARE_OFFER','MOB_ACCESSORY_OFFER') OR ProductCode IN:bundleProd] ){
                if((prodItem.ProductCode).equals('MOB_HARDWARE_OFFER')){
                    OfferMap.put('MOB_HARDWARE_OFFER',prodItem.id);
                }else{
                    if((prodItem.ProductCode).equals('MOB_ACCESSORY_OFFER')){
                        OfferMap.put('MOB_ACCESSORY_OFFER',prodItem.id);
                    }else{
                        if((prodItem.C2BC_Subcategory__c).equals('mobiledevice')){
                            mobileBundle.add(prodItem);                      
                        }else if((prodItem.C2BC_Subcategory__c).equals('accessories')){
                            accessoryBundle.add(prodItem);
                        }
                    }
                } 
            }
            offerBundleMap.put(OfferMap.get('MOB_HARDWARE_OFFER'),mobileBundle);
            offerBundleMap.put(OfferMap.get('MOB_ACCESSORY_OFFER'),accessoryBundle);
            for(Id offerId:offerBundleMap.keySet()){
                for(product2 bundle:offerBundleMap.get(offerId)){
                    offerBundlePCI.add(processParentChildRelationship(offerId,bundle.Id,1));
                }
            }
            if(offerBundlePCI.size()>0){
                insert offerBundlePCI;
            }
        }
        return bundleProd;
        
    }
    
    //set field values for new sales bundle
    private static Product2 setFieldValues(Load_Product__c prod){
        Product2 bundleProduct = new Product2();
        bundleProduct.Name=prod.Brand__c;
        if(prod.C2BC_Subcategory__c.equals('mobiledevice')){
            bundleProduct.ProductCode='HW_VIRTUAL_GP_'+prod.Brand__c;
        }else if(prod.C2BC_Subcategory__c.equals('accessories')){
            bundleProduct.ProductCode='HW_VIRTUAL_GP_'+prod.Brand__c+'_OFFER';
        }
        bundleProduct.vlocity_cmt__IsOrderable__c=false;
        bundleProduct.vlocity_cmt__Status__c='Active';
        bundleProduct.IsActive=true;
        bundleProduct.C2BC_Category__c=prod.C2BC_Category__c;
        bundleProduct.C2BC_Subcategory__c=prod.C2BC_Subcategory__c;
        bundleProduct.vlocity_cmt__SpecificationType__c='Product';
        bundleProduct.vlocity_cmt__ObjectTypeId__c=Id.valueOf(System.Label.TeliaSE_bundleObjectType);// create new label for sales
        return bundleProduct; 
    }
    
    //Creates product 
    private static Product2 createProduct(Load_Product__c prod,Product2 product){
        product.isActive=prod.Active__c;
        product.C2BC_Category__c=prod.C2BC_Category__c;
        product.C2BC_Subcategory__c=prod.C2BC_Subcategory__c;
        product.vlocity_cmt__ObjectTypeId__c = Id.valueOf(System.Label.TeliaSE_productObjectType);
        product.Name=prod.Name__c;
        product.vlocity_cmt__IsNotAssetizable__c=prod.non_assetizable__c;
        product.Ordering_Flag__c='true';
        product.productCode=prod.sapId__c;
        product.MC_Product_Name_Eng__c=prod.ProductNameEng__c;
        product.vlocity_cmt__SellingStartDate__c =prod.SaleStartDate__c;
        product.vlocity_cmt__IsConfigurable__c=true;
        product.vlocity_cmt__SpecificationType__c='Product';
        product.vlocity_cmt__IsOrderable__c=false;
        product.vlocity_cmt__Status__c='Active';
        return product;
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
        for(vlocity_cmt__PricingVariable__c pricingVariable:[SELECT id,vlocity_cmt__code__c FROM vlocity_cmt__PricingVariable__c WHERE vlocity_cmt__Code__c in( 'OT_STD_PRC','REC_MNTH_STD_PRC','OT_STD_PRC_N1','OT_STD_PRC_N2')])
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
        for(vlocity_cmt__PricingElement__c element:[select id,vlocity_cmt__PriceListId__c,vlocity_cmt__Code__c from vlocity_cmt__PricingElement__c  where vlocity_cmt__Code__c !=null and (vlocity_cmt__Code__c in :salesCodes or vlocity_cmt__Code__c in :codes) and vlocity_cmt__PriceListId__c in (:salesPriceListId,:onlinePriceListId)])
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
                system.debug('code-->'+code);
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
        for(vlocity_cmt__PricingElement__c ele:[select id,vlocity_cmt__PriceListId__c,vlocity_cmt__Code__c from vlocity_cmt__PricingElement__c where (vlocity_cmt__Code__c!=null and (vlocity_cmt__Code__c in :clonedCodes or vlocity_cmt__Code__c in :clonedSalesCodes)) and vlocity_cmt__PriceListId__c in (:salesPriceListId,:onlinePriceListId)])
        {
            if(ele.vlocity_cmt__PriceListId__c == onlinePriceListId)
                elementMap.put(ele.vlocity_cmt__Code__c,ele.Id);
            else if(ele.vlocity_cmt__PriceListId__c == salesPriceListId)
                elementSalesMap.put(ele.vlocity_cmt__Code__c,ele.Id);
        }
        List<vlocity_cmt__PriceListEntry__c> priceListEntries=new List<vlocity_cmt__PriceListEntry__c>();
        
        //need to handle seperate logic for sales ples
        for(vlocity_cmt__PriceListEntry__c entry:[select id,vlocity_cmt__PriceListId__c,vlocity_cmt__ProductId__c,vlocity_cmt__ProductId__r.productCode,vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c from vlocity_cmt__PriceListEntry__c where  (vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c !=null and (vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c  in :clonedCodes or vlocity_cmt__PricingElementId__r.vlocity_cmt__Code__c in :clonedSalesCodes)) and  vlocity_cmt__ProductId__r.productcode!=null and vlocity_cmt__ProductId__r.productcode in :productMap.keySet() and vlocity_cmt__PriceListId__c in (:salesPriceListId,:onlinePriceListId)])
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
                priceListEntries.add(createPriceListEntry(onlinePriceListId,productMap.get(prod.SAPID__c).Id,'One Time Std Price',elementMap.get('OT-'+String.valueOf(prod.nrc__c)),false));
            if(productPleMap.get(prod.sapId__c).contains('OTN1-'+String.valueOf(prod.NRCN1__c)))
                priceListEntries.add(createPriceListEntry(onlinePriceListId,productMap.get(prod.SAPID__c).Id,'One Time Std Price N1',elementMap.get('OTN1-'+String.valueOf(prod.NRCN1__c)),true));
            if(productPleMap.get(prod.sapId__c).contains('OTN2-'+String.valueOf(prod.NRCN2__c)))
                priceListEntries.add(createPriceListEntry(onlinePriceListId,productMap.get(prod.SAPID__c).Id,'One Time Std Price N2',elementMap.get('OTN2-'+String.valueOf(prod.NRCN2__c)),false));
            if(productPleMap.get(prod.sapId__c).contains('RM-'+String.valueOf(prod.mrc__c)))
                priceListEntries.add(createPriceListEntry(onlinePriceListId,productMap.get(prod.SAPID__c).Id,'Recurring Monthly Std Price',elementMap.get('RM-'+String.valueOf(prod.mrc__c)),true));
            if(productSalesPleMap.get(prod.sapId__c).contains('OT-'+String.valueOf(prod.nrc__c)))
                priceListEntries.add(createPriceListEntry(salesPriceListId,productMap.get(prod.SAPID__c).Id,'One Time Std Price',elementSalesMap.get('OT-'+String.valueOf(prod.nrc__c)),true));
        }
        if(priceListEntries.size()>0 && priceListEntries.size()<100)
        {
            insert priceListEntries;
        }
    }
    
    //creates relationship between parent and child product
    private static vlocity_cmt__ProductChildItem__c processParentChildRelationship(Id parentId,Id childId,Integer quantity){
        vlocity_cmt__ProductChildItem__c  childItem=new vlocity_cmt__ProductChildItem__c();
        childItem.vlocity_cmt__ParentProductId__c=parentId;
        childItem.vlocity_cmt__ChildProductId__c=childId;
        childItem.vlocity_cmt__ChildLineNumber__c='1';
        childItem.vlocity_cmt__MaxQuantity__c=99;
        childItem.vlocity_cmt__MinQuantity__c=quantity;
        childItem.vlocity_cmt__Quantity__c=quantity;
        return  childItem;
    }
    
    private static void addRecomendedProduct(List<Load_Product__c> bundles){
        List<String> recomendedPhimIds=new List<String>();
        List<String> bundlePhimIds=new List<String>();
        Map<String,String> phimIdBundleMap=new Map<String,String>();
        for(Load_Product__c prod: bundles)
        {
            if(prod.recomendedAccessories__c !=null){
                bundlePhimIds.add(prod.phimId__c);
                List<Object> recs=(List<Object>)JSON.deserializeUntyped(prod.recomendedAccessories__c);
                for(Object obj:(List<Object>)JSON.deserializeUntyped(prod.recomendedAccessories__c))
                {
                    recomendedPhimIds.add(String.valueOf(obj));
                    phimIdBundleMap.put(String.valueOf(obj),prod.phimId__c);
                }
            }
        }
        if(recomendedPhimIds.size() > 0) {
            Map<String,Id> phimToProductMap=new Map<String,Id>();
            for(Product2 bundleProd:[select id,productCode from Product2 where productCode in :bundlePhimIds])
            {
                phimToProductMap.put(bundleProd.productCode,bundleProd.id);
            }
            List<vlocity_cmt__ProductRelationship__c> relationships=new List<vlocity_cmt__ProductRelationship__c>();
            vlocity_cmt__ProductRelationship__c relationship;
            for(Product2 prod:[select id,productCode from Product2 where productCode in :recomendedPhimIds])
            {
                relationship.vlocity_cmt__Product2Id__c=phimToProductMap.get(prod.productCode);
                relationship.vlocity_cmt__RelatedProductId__c=prod.id;
                relationship.vlocity_cmt__RelationshipType__c='Recommends';
                relationship.name=relationship.vlocity_cmt__Product2Id__c+' '+relationship.vlocity_cmt__RelationshipType__c+' '+relationship.vlocity_cmt__RelatedProductId__c;
                relationships.add(relationship);
                recomendedPhimIds.remove(recomendedPhimIds.indexOf(prod.productCode));
            }
            if(relationships.size()>0)
            {
                insert relationships;
            }
            if(recomendedPhimIds.size()>0)
            {
                sendEmail('The follwing accessories are not present in amanda '+recomendedPhimIds.toString());
            }
        }
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
    
    private static vlocity_cmt__PriceListEntry__c createPriceListEntry(Id priceListId,Id productId,String name,Id pricingElementId,Boolean isActive){
        vlocity_cmt__PriceListEntry__c  entry=new vlocity_cmt__PriceListEntry__c();
        entry.vlocity_cmt__PricingElementId__c=pricingElementId;
        entry.vlocity_cmt__PriceListId__c=priceListId;
        entry.vlocity_cmt__IsActive__c=isActive;
        entry.vlocity_cmt__IsBasePrice__c=true;
        entry.Name=name;
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
}