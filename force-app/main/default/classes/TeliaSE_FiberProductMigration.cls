global class TeliaSE_FiberProductMigration implements vlocity_cmt.VlocityOpenInterface{
    global static boolean  invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    Boolean result = true;
    try {
            if(methodName.equalsIgnoreCase('deletionOfOffers')){
                TeliaSE_FiberProductMigration.deletionOfOffers(inputMap,outMap,options);
            }
            /*else if(methodName.equalsIgnoreCase('addDataPaket'))
            {   
                TeliaSE_FiberProductMigration.addDataPaket(inputMap,outMap,options);
            }*/
            else if(methodName.equalsIgnoreCase('customAddToCart')){
                TeliaSE_FiberProductMigration.customAddToCart(inputMap,outMap,options);
            }
            else if(methodName.equalsIgnoreCase('AddToCartPCI')){
                TeliaSE_FiberProductMigration.AddToCartPCI(inputMap,outMap,options);
            }
            else if(methodName.equalsIgnoreCase('mergeCustomFields')){
                TeliaSE_FiberProductMigration.mergeCustomFields(inputMap,outMap,options);
            }
        }
        catch(Exception e)
        {
            system.debug('Exception e --> '+e);
        }
        return result;
    }
    global static void deletionOfOffers(Map<String,Object> inputMap, Map<String,Object> outputMap,Map<String,Object> options){//Here we delete offers and their corresponding child items
        Set<String> offerCode= new Set<String>();
        String quoteId = String.valueOf(inputMap.get('cartId'));
        Set<id> uniqueRootItemId = new Set<id>();
        //Following is list of offers codes to deleted from qli
        //Following handles moving products from MDU to SDU offer scenario
        offerCode.add('Promo_SDU_Fiber_Offer');
        offerCode.add('Promo_SDU_XLAN_Fiber_Offer');
        offerCode.add('Promo_Open_Fiber_LL');
        offerCode.add('Promo_XLAN_LL');
        
        offerCode.add('Property Network Hardware Service Bundle');
        offerCode.add('Halebop Property Network Hardware Service Bundle');
        try{
            QuoteLineItem qli = new QuoteLineItem();
            List<QuoteLineItem> qliList = [Select id,QuoteId, vlocity_cmt__ParentItemId__c,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__RootItemId__c from QuoteLineItem where ( vlocity_cmt__Product2Id__r.ProductCode in: offerCode) and QuoteId =: quoteId];
            if(qliList != null && qliList.size()>0)//This loop creates set of id of offers which is further used to delete root and its child products
            {
                for( QuoteLineItem i: qliList){
                    uniqueRootItemId.add(i.id);
                }
            }
            if(!(uniqueRootItemId.isEmpty())){
                List<QuoteLineItem> qliRootnChildProducts = [Select id,QuoteId, vlocity_cmt__ParentItemId__c,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__RootItemId__c from QuoteLineItem where QuoteId =: quoteId and vlocity_cmt__RootItemId__c in: uniqueRootItemId];            
                delete qliRootnChildProducts;
            }
        }//End of try
        catch(exception e){
            outputMap.put('ErrorApex','DeletionofOffersError');
            outputMap.put('ReasonFailure',e.getStackTraceString());
        }
    }//End of deletionOfOffers method
   /* global static void addDataPaket(Map<String,Object> inputMap, Map<String,Object> outputMap,Map<String,Object> options)
    {
        Set<String> productCode= new Set<String>();
        productCode.add('Promo_MDU_Hardware');
        productCode.add('MDU_CoaxTV_1707');
        productCode.add('MDU_CoaxTVBas_1707');
        PricebookEntry pbe = [select id,name, Product2.ProductCode,Product2Id from PricebookEntry where Product2.ProductCode =: productCode and Pricebook2.Name = 'CRM Fiber PriceBook' limit 1];     
        
        options.put('chainable',true);
        options.put('queueableChainable',true);
        options.put('useQueueableApexRemoting',true);
        Map<String, Object> itemsMap = new Map<String, Object>();
        Map<String, Object> recordsMap = new Map<String, Object>();
        Map<String, Object> obb = new Map<String, Object>();
        List<Object> items = new List<Object>();
        List<Object> records = new List<Object>();
        // Passing Parameters
        Id priceBookEntryId = pbe.id;
        String cartId = String.valueOf(inputMap.get('cartId'));
        /*String parentId = String.valueOf(inputMap.get('parentItemId'));
        String hierarchyPath = String.valueOf(inputMap.get('hierarchy'));
        system.debug('value of Heirarchy Path --> '+hierarchyPath);
        
        recordsMap.put('productHierarchyPath',hierarchyPath);
        recordsMap.put('parentHierarchyPath',hierarchyPath);
        records.add(recordsMap);        
        obb.put('records',records);
        
        itemsMap.put('itemId', priceBookEntryId);
        itemsMap.put('parentId', parentId);
        itemsMap.put('parentRecord', obb);
        items.add(itemsMap);
        Map<String,Object> ApiInputMap = new Map<String,Object>();
        ApiInputMap.put('items', items);
        ApiInputMap.put('cartId', cartId);
        ApiInputMap.put('validate', true); 
        ApiInputMap.put('price', true);
        system.debug('print APIinputMap'+json.serialize(ApiInputMap));       
        try
        {
            vlocity_cmt.CpqAppHandler cpqAppHandlerService = new  vlocity_cmt.CpqAppHandler();
            cpqAppHandlerService.invokeMethod('postCartsItems', ApiInputMap, outputMap, options);            
        }
        catch(Exception e)
        {
            outputMap.put('ErrorApex','AddToCartError');
            outputMap.put('ReasonFailure',e.getStackTraceString());
        }
        finally
        {
        }
        
    }*/
    global static void customAddToCart(Map<String,Object> inputMap, Map<String,Object> outputMap,Map<String,Object> options){
        set<string> offerCodes = new set<string>();
        set<id> offerId = new set<id>();
        set<string> childProductCodes = new set<string>();
        set<id> childPricebookEntry = new set<id>();
        system.debug('datapaketinputmap'+json.serialize(inputMap));
        Map<String,Object> offers = (Map<String,Object>)inputMap.get('Offer');
       
            offerCodes.add(string.valueof(offers.get('RootProductCode')));
            offerId.add((string.valueof(offers.get('RootItemId'))));
            list<object> childs = (list<object>)offers.get('Child');
            
            for(object child : childs){
                map<string,object> i = (map<string,object>)child;
                childProductCodes.add(string.valueof(i.get('ChildProductCode')));
                childPricebookEntry.add((string.valueof(i.get('PricebookEntry'))));
                i.clear();
            }
        //Adding offer
        set<string> newOfferCodes = new set<string>();
        string switchProductCode;
        for(string i: offerCodes){
            switchProductCode = i;
            
            switch on switchProductCode{
                when 'Promo_Property_Net_Hardware'{
                    newOfferCodes.add('Promo_MDU_Hardware');
                }
                when 'Property Network Hardware Service Bundle'{
                    newOfferCodes.add('Promo_MDU_Hardware');
                }
                when 'Promo_VAS_LL'{
                    newOfferCodes.add('Promo_IPTV_LL');
                }
                when 'Promo_COAX_TV'{
                    newOfferCodes.add('Promo_IPTV_LL');
                }
                when 'Promo_BB_B2B_LL'{
                    newOfferCodes.add('Promo_BB_LL');
                }
                when 'Promo_VoIP_LL'{
                    newOfferCodes.add('Promo_BB_LL');
                }
            }//End of Switch statement
        }
       Set<String> productCode= new Set<String>();
        PricebookEntry pbe = [select id,name, Product2.ProductCode,Product2Id from PricebookEntry where Product2.ProductCode in: newOfferCodes and Pricebook2.Name = 'CRM Fiber PriceBook' limit 1];     
        
        options.put('chainable',true);
        options.put('queueableChainable',true);
        options.put('useQueueableApexRemoting',true);
        Map<String, Object> itemsMap = new Map<String, Object>();
        Map<String, Object> recordsMap = new Map<String, Object>();
        Map<String, Object> obb = new Map<String, Object>();
        List<Object> items = new List<Object>();
        List<Object> records = new List<Object>();
        // Passing Parameters
        Id priceBookEntryId = pbe.id;
        String cartId = String.valueOf(inputMap.get('cartId'));
        
        itemsMap.put('itemId', priceBookEntryId);
        
        items.add(itemsMap);
        Map<String,Object> ApiInputMap = new Map<String,Object>();
        ApiInputMap.put('items', items);
        ApiInputMap.put('cartId', cartId);
        ApiInputMap.put('validate', true); 
        ApiInputMap.put('price', true);
        //system.debug('print APIinputMap'+json.serialize(ApiInputMap));       
        try
        {
            vlocity_cmt.CpqAppHandler cpqAppHandlerService = new  vlocity_cmt.CpqAppHandler();
            cpqAppHandlerService.invokeMethod('postCartsItems', ApiInputMap, outputMap, options);            
        }
        catch(Exception e)
        {
            outputMap.put('ErrorApex','AddToCartError');
            outputMap.put('ReasonFailure',e.getStackTraceString());
        }
        finally
        {
        }
    }
    global static void AddToCartPCI(Map<String,Object> inputMap, Map<String,Object> outputMap,Map<String,Object> options){
        set<string> offerCodes = new set<string>();
        set<id> offerId = new set<id>();
        set<string> childProductCodes = new set<string>();
        set<id> childPricebookEntry = new set<id>();
        system.debug('datapaketinputmap'+json.serialize(inputMap));
        Map<String,Object> offers = (Map<String,Object>)inputMap.get('Offer');
        system.debug('Value of offer node'+offers);
       
            offerCodes.add(string.valueof(offers.get('RootProductCode')));
            offerId.add((string.valueof(offers.get('RootItemId'))));
            list<object> childs = (list<object>)offers.get('Child');
            
            for(object child : childs){
                map<string,object> i = (map<string,object>)child;
                childProductCodes.add(string.valueof(i.get('ChildProductCode')));
                if((string.valueof(i.get('ChildProductCode'))) != 'MDU_CoaxTV_EjInstallerad_1840'){//Added this statement as this product is not part of new offer
                	childPricebookEntry.add((string.valueof(i.get('PricebookEntry'))));
                }
                i.clear();
            }
        //Adding offer
        set<string> newOfferCodes = new set<string>();
        string switchProductCode;
        for(string i: offerCodes){
            switchProductCode = i;
            
            switch on switchProductCode{
                when 'Promo_Property_Net_Hardware'{
                    newOfferCodes.add('Promo_MDU_Hardware');
                }
                when 'Property Network Hardware Service Bundle'{
                    newOfferCodes.add('Promo_MDU_Hardware');
                }
                when 'Promo_VAS_LL'{
                    newOfferCodes.add('Promo_IPTV_LL');
                }
                when 'Promo_COAX_TV'{
                    newOfferCodes.add('Promo_IPTV_LL');
                }
                when 'Promo_BB_B2B_LL'{
                    newOfferCodes.add('Promo_BB_LL');
                }
                when 'Promo_VoIP_LL'{
                    newOfferCodes.add('Promo_BB_LL');
                }
            }//End of Switch statement
        }
        
        options.put('chainable',true);
        options.put('queueableChainable',true);
        options.put('useQueueableApexRemoting',true);
        Map<String, Object> itemsMap = new Map<String, Object>();
        Map<String, Object> recordsMap = new Map<String, Object>();
        Map<String, Object> obb = new Map<String, Object>();
        List<Object> items = new List<Object>();
        List<Object> records = new List<Object>();
        // Passing Parameters
        
        String cartId = String.valueOf(inputMap.get('cartId'));
        quotelineitem qli = [select Product2Id,id from quotelineitem where product2.productcode in: newOfferCodes and quoteid =: cartId limit 1];
        string strPBE = null ;
        if( childPricebookEntry != null && !(childPricebookEntry.isEmpty())){
            for(id k: childPricebookEntry){
                if( strPBE == null){
                    strPBE = k;
                }
                else{
                    strPBE = strPBE +','+k;
                }
            }
        }
        String parentId = String.valueOf(qli.id);
        String hierarchyPath = String.valueOf(qli.Product2Id);
        recordsMap.put('productHierarchyPath',hierarchyPath);
        recordsMap.put('parentHierarchyPath',hierarchyPath);
        records.add(recordsMap);        
        obb.put('records',records);
        itemsMap.put('parentId', parentId);
        itemsMap.put('parentRecord', obb);
        itemsMap.put('itemId', strPBE);
        items.add(itemsMap);
        Map<String,Object> ApiInputMap = new Map<String,Object>();
        ApiInputMap.put('items', items);
        ApiInputMap.put('cartId', cartId);
        ApiInputMap.put('validate', true); 
        ApiInputMap.put('price', true);
        system.debug('print APIinputMap'+json.serialize(ApiInputMap));       
        try
        {
            vlocity_cmt.CpqAppHandler cpqAppHandlerService = new  vlocity_cmt.CpqAppHandler();
            cpqAppHandlerService.invokeMethod('postCartsItems', ApiInputMap, outputMap, options);            
        }
        catch(Exception e)
        {
            outputMap.put('ErrorApex','AddToCartError');
            outputMap.put('ReasonFailure',e.getStackTraceString());
        }
        finally
        {
        }
    }
    global static void mergeCustomFields(Map<String,Object> inputMap, Map<String,Object> outputMap,Map<String,Object> options){
        try{
            set<string> offerCodes = new set<string>();
            set<id> offerId = new set<id>();
            set<string> childProductCodes = new set<string>();
            set<id> childPricebookEntry = new set<id>();
            system.debug('datapaketinputmap'+json.serialize(inputMap));
            Map<String,Object> offers = (Map<String,Object>)inputMap.get('Offer');
            system.debug('Value of offer node'+offers);
           
                offerCodes.add(string.valueof(offers.get('RootProductCode')));
                offerId.add((string.valueof(offers.get('RootItemId'))));
                list<object> childs = (list<object>)offers.get('Child');
                
                for(object child : childs){
                    map<string,object> i = (map<string,object>)child;
                    childProductCodes.add(string.valueof(i.get('ChildProductCode')));
                    childPricebookEntry.add((string.valueof(i.get('PricebookEntry'))));
                    i.clear();
                }
            //Adding offer
            set<string> newOfferCodes = new set<string>();
            string switchProductCode;
            for(string i: offerCodes){
                switchProductCode = i;
                
                switch on switchProductCode{
                    when 'Promo_Property_Net_Hardware'{
                        newOfferCodes.add('Promo_MDU_Hardware');
                    }
                    when 'Property Network Hardware Service Bundle'{
                        newOfferCodes.add('Promo_MDU_Hardware');
                    }
                    when 'Promo_VAS_LL'{
                        newOfferCodes.add('Promo_IPTV_LL');
                    }
                    when 'Promo_COAX_TV'{
                        newOfferCodes.add('Promo_IPTV_LL');
                    }
                    when 'Promo_BB_B2B_LL'{
                        newOfferCodes.add('Promo_BB_LL');
                    }
                    when 'Promo_VoIP_LL'{
                        newOfferCodes.add('Promo_BB_LL');
                    }
                }//End of Switch statement
            }
                    
            String cartId = String.valueOf(inputMap.get('cartId'));
            quotelineitem qli = [select Product2Id,id from quotelineitem where product2.productcode in: newOfferCodes and quoteid =: cartId limit 1];
            //creating 2 list old product list and new product list then we will compare new products with old products and overide.
            list<quotelineitem> qliOldOfferCode = [select id,product2.productcode,Quantity,vlocity_cmt__OneTimeCharge__c, vlocity_cmt__RecurringCharge__c, TeliaSE_Fiber_Frame_Agreement__c,Fiber_Customer_Requested_Price__c,TeliaSE_fiber_Rabatt__c,Fiber_Approved_Price__c from quotelineitem where vlocity_cmt__RootItemId__c in: offerId and quoteid =: cartId];
            list<quotelineitem> qliNewOfferCode = [select id,product2.productcode,Quantity,vlocity_cmt__OneTimeCharge__c, vlocity_cmt__RecurringCharge__c, TeliaSE_Fiber_Frame_Agreement__c,Fiber_Customer_Requested_Price__c,TeliaSE_fiber_Rabatt__c,Fiber_Approved_Price__c from quotelineitem where vlocity_cmt__RootItemId__c =: qli.id and quoteid =: cartId];
            list<quotelineitem> toUpdateqli = new list<quotelineitem>();
            for( quotelineitem i : qliNewOfferCode){
                for( quotelineitem j : qliOldOfferCode){
                    if( i.product2.productcode == j.product2.productcode){
                        i.Quantity = j.Quantity;
                        i.vlocity_cmt__OneTimeCharge__c = j.vlocity_cmt__OneTimeCharge__c;
                        i.vlocity_cmt__RecurringCharge__c = j.vlocity_cmt__RecurringCharge__c;
                        i.TeliaSE_Fiber_Frame_Agreement__c = j.TeliaSE_Fiber_Frame_Agreement__c;
                        i.Fiber_Customer_Requested_Price__c = j.Fiber_Customer_Requested_Price__c;
                        i.TeliaSE_fiber_Rabatt__c = j.TeliaSE_fiber_Rabatt__c;
                        i.Fiber_Approved_Price__c = j.Fiber_Approved_Price__c;
                        toUpdateqli.add(i);
                    }
                }
            }
            if(!(toUpdateqli.isempty())){
                update toUpdateqli;
                delete qliOldOfferCode;
            }
        }
        catch(Exception e)
        {
            outputMap.put('ErrorApex','mergeCustomFields');
            outputMap.put('ReasonFailure',e.getStackTraceString());
        }
    }
}