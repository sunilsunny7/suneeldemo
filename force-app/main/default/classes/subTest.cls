global class subTest implements vlocity_cmt.VlocityOpenInterface2{
    static List<Data> finalData=new List<Data>();
    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        Boolean result = true;
        try {
            if (methodName.equalsIgnoreCase('getSubscriptionCatalog')) {
                getSubscriptionCatalog(outMap);
            } else {
                result = false;
            }
        } catch (Exception e) {
            result = false;
            String error_message = e.getMessage() + ' ' + e.getLineNumber();
            outMap.put('statusCode', 500);
            outMap.put('Exception', e.getStackTraceString());
            MCOnline_Utility.logError(error_message, '500', 'subscriptionMap_POC,subscriptionMap_POC.invokeMethod', 'Apex Class', 'Exception', JSON.serialize(inputMap), '', '');
        }
        return result;
    }
    private static void getSubscriptionCatalog( Map<String,Object> outMap)
    {
        Map<String,List<String>> virtualMap=new Map<String,List<String>>();
        Map<String,List<String>> virtualMapAddOn=new Map<String,List<String>>();
        List<String> addOnOffers = new List<String>();
        // fetch virtual offers from Catalog and child offers from vlocity_cmt__ProductChildItem__c
        List<vlocity_cmt__ProductChildItem__c> virtualItems =[SELECT vlocity_cmt__ParentProductId__c,vlocity_cmt__ParentProductId__r.ProductCode,vlocity_cmt__ChildProductId__c,
                                                              vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.vlocity_cmt__SpecificationType__c,vlocity_cmt__ChildProductId__r.C2BC_Category__c FROM vlocity_cmt__ProductChildItem__c
                                                              WHERE vlocity_cmt__ParentProductId__c IN (SELECT vlocity_cmt__Product2Id__c FROM vlocity_cmt__CatalogProductRelationship__c WHERE
                                                                                                        (vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c = 'SUBSCRIPTIONS' AND vlocity_cmt__Product2Id__r.C2BC_Category__c = 'offerbundle' AND vlocity_cmt__Product2Id__r.C2BC_Subcategory__c  = 'mobilevoicesubscription' AND
                                                                                                         vlocity_cmt__Product2Id__r.Family = 'Online Order')) AND vlocity_cmt__ChildProductId__c!=''AND
                                                              vlocity_cmt__ChildProductId__r.C2BC_Category__c IN ('subscriptionbundle','mobilebroadbandsubscription','mobilevoicesubscription','addonbundle' )AND vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c !='insurance' AND vlocity_cmt__ParentProductId__r.IsActive =true AND vlocity_cmt__ChildProductId__r.Family ='Online Order'];
        
        // fetch active subscription product,bundle, offers from vlocity_cmt__ProductChildItem__c
        List<vlocity_cmt__ProductChildItem__c> items=[select vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c,vlocity_cmt__ParentProductId__r.ProductCode,vlocity_cmt__ParentProductId__r.C2BC_Category__c, vlocity_cmt__ChildProductId__r.ProductCode, vlocity_cmt__ChildProductId__r.C2BC_Category__c from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__r.C2BC_Category__c IN ('subscriptionbundle','mobilebroadbandsubscription','mobilevoicesubscription' ) AND vlocity_cmt__ParentProductId__r.C2BC_Category__c !='addonbundle' AND vlocity_cmt__ParentProductId__r.IsActive =true AND vlocity_cmt__ChildProductId__r.Family ='Online Order'];
        
        // create Map with key = virtual offer and value = list of offers under the virtual offer 
        for(vlocity_cmt__ProductChildItem__c item:virtualItems)
        {
            if(item.vlocity_cmt__ChildProductId__r.C2BC_Category__c == 'addonbundle'){
                if(!virtualMapAddOn.containsKey(item.vlocity_cmt__ParentProductId__r.productcode))
                {
                    virtualMapAddOn.put(item.vlocity_cmt__ParentProductId__r.productcode,new List<String>{item.vlocity_cmt__ChildProductId__r.ProductCode});    
                }
                else {
                    virtualMapAddOn.get(item.vlocity_cmt__ParentProductId__r.productcode).add(item.vlocity_cmt__ChildProductId__r.ProductCode);
                }
            }else{
                if(!virtualMap.containsKey(item.vlocity_cmt__ParentProductId__r.productcode))
                {
                    virtualMap.put(item.vlocity_cmt__ParentProductId__r.productcode,new List<String>{item.vlocity_cmt__ChildProductId__r.ProductCode});    
                }
                else {
                    virtualMap.get(item.vlocity_cmt__ParentProductId__r.productcode).add(item.vlocity_cmt__ChildProductId__r.ProductCode);
                }
            }
        }
        /*----------- Processing Subscriptions Strats ---------------------*/
        // iterate through all the virtual offers in the virtualMap
        for(String key:virtualMap.keySet()){
            system.debug('virtual offer'+':'+key);
            // iterate through all the offers under the virtual offer
            for(String offer:virtualMap.get(key))
            {
                system.debug('offers under the virtual offer'+':'+offer);
                // iterate through all the child items fetched ( product/bundle/offers)
                for(vlocity_cmt__ProductChildItem__c item:items)
                {
                    
                    //if parent of child item is = offer
                    if(item.vlocity_cmt__ParentProductId__r.productcode == offer)
                    {
                        system.debug('child under the offer'+':'+item.vlocity_cmt__ChildProductId__r.productcode);
                        // call method to create JSON structure for the product under the bundle
                        createJSON(key,offer,item.vlocity_cmt__ChildProductId__r.productcode,items);
                        
                    }
                }
            }
        }
        /*----------- Processing Subscriptions Ends ----------------------*/
        // create JSON nodes for AddOns
        getAddOn(virtualMapAddOn);
        // send final response
        String str = JSON.serialize(finalData); 
        outMap.put('subscriptions',JSON.deserializeUntyped(str));
        outMap.put('success',true);
    }
    private static void createJSON(String virtualOffer,String offer,String bundleCode,List<vlocity_cmt__ProductChildItem__c> items){
        Data data;
        // iterate through the list of child items
        for(vlocity_cmt__ProductChildItem__c item:items){
            // if parent of the item = bundle then create the JSON structure with the following info
            if(item.vlocity_cmt__ParentProductId__r.productCode == bundleCode && (!String.isBlank(String.valueOf(item.vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c))))
            {
                data=new Data();
                data.catalog='SUBSCRIPTIONS';
                data.virtualOffer=virtualOffer;
                data.offer=offer;
                data.productCode=item.vlocity_cmt__ChildProductId__r.ProductCode;
                data.legacySubscriptionType=item.vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c;
                system.debug('JSON Node'+':'+data.virtualOffer+'->'+data.offer+'->'+data.productCode);
                finalData.add(data);
            }
        }
    }
    /*----------- Processing Other device Addon Strats --------------*/
    private static void getAddOn(Map<String,List<String>> virtualMapAddOn){
        Set<String> virtualAddOnSet = new Set<String>();
        List<String> virtualAddOnList = new List<String>();
        // create the list containing all the children and parent codes
        for(String key:virtualMapAddOn.keySet()){
            virtualAddOnSet.add(key);
            for(String addOnofferItem:virtualMapAddOn.get(key)){
                virtualAddOnSet.add(addOnofferItem);
            }
        }
        virtualAddOnList.addAll(virtualAddOnSet);
        // Fetch records for the above parent and children from the object
        List<vlocity_cmt__ProductChildItem__c> addOnItems=[select vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c,vlocity_cmt__ParentProductId__r.ProductCode,vlocity_cmt__ParentProductId__r.C2BC_Category__c, vlocity_cmt__ChildProductId__r.ProductCode, vlocity_cmt__ChildProductId__r.C2BC_Category__c,vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c, vlocity_cmt__ParentProductId__r.C2BC_Subcategory__c from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__c !='' AND vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c IN ( 'datasim','mdsecondary','mobilevoicesubscription')  AND vlocity_cmt__ChildProductId__r.C2BC_Category__c IN( 'mobilevoicesubscription','mobilebroadbandsubscription','addonbundle' )AND vlocity_cmt__ParentProductId__r.IsActive =true AND vlocity_cmt__ChildProductId__r.Family ='Online Order'AND vlocity_cmt__ParentProductId__r.ProductCode IN :virtualAddOnList Order By vlocity_cmt__ChildProductId__r.ProductCode];
        // iterate through all the virtual  offers in the virtualMap with addOn
        // Create set of AddOnRecord and assign it the return from a function which removes duplicates
        Set<AddOnRecord> addOns = removeDuplicate(addOnItems);
        for(String key:virtualMapAddOn.keySet()){
            system.debug('virtual offer'+':'+key);
            // iterate through all the addOn offers under the virtual offer
            for(String addOnoffer:virtualMapAddOn.get(key))
            {
                system.debug('addOn offers under the virtual offer'+':'+addOnoffer);
                createAddOnNode(key,addOnoffer,addOnoffer,addOns);
            }   
        }
        
    }
    //----------- Processing Other devices Addon Ends ---------------------
    private static void createAddOnNode(String virtualOffer,String offer,String bundleCode,Set<AddOnRecord> addOns){
        Data data;
        // iterate through the list of child items
        for(AddOnRecord item:addOns){
            // if parent of the item = bundle then create the JSON structure with the following info
            if(item.parentProductCode == bundleCode && (!String.isBlank(String.valueOf(item.legacySubscriptionType))))
            {
                data=new Data();
                data.catalog='SUBSCRIPTIONS';
                data.virtualOffer=virtualOffer;
                data.offer=offer;
                data.productCode=item.productCode;
                data.legacySubscriptionType=item.legacySubscriptionType;
                system.debug('JSON Node'+':'+data.virtualOffer+'->'+data.offer+'->'+data.productCode);
                finalData.add(data);
            }
        }
    }
    private static Set<AddOnRecord> removeDuplicate(List<vlocity_cmt__ProductChildItem__c> addOnList){
        AddOnRecord addOnRecord;
        Set<AddOnRecord> addOns = new Set<AddOnRecord>();
        for(vlocity_cmt__ProductChildItem__c addOn:addOnList){
            addOnRecord=new AddOnRecord();
            addOnRecord.catalog='SUBSCRIPTIONS';
            addOnRecord.offer=addOn.vlocity_cmt__ParentProductId__r.ProductCode;
            addOnRecord.productCode=addOn.vlocity_cmt__ChildProductId__r.ProductCode;
            addOnRecord.legacySubscriptionType=addOn.vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c;
            addOnRecord.parentProductCode = addOn.vlocity_cmt__ParentProductId__r.ProductCode;
            addOns.add(addOnRecord); 
        }
        return addOns;   
    }
    //wrapper class for the response format
    private Class Data
    {
        String catalog;
        String virtualOffer;
        String offer;
        String productCode;
        String legacySubscriptionType;
    }
    // wrapper class with implementation of the method 'equals' to remove duplicates
    private Class AddOnRecord
    {
        String catalog;
        String virtualOffer;
        String offer;
        String productCode;
        String legacySubscriptionType;
        String parentProductCode;
        
        public Boolean equals(Object obj) {
            if (obj instanceof AddOnRecord) {
                AddOnRecord newObj = (AddOnRecord)obj;
                if(newObj.parentProductCode != null && newObj.productCode != null){
                    if (parentProductCode.equals(newObj.parentProductCode) &&
                        productCode.equals(newObj.productCode)) {
                            return true;
                        }
                }
            }
            return false;
        }
    }
    
    
}