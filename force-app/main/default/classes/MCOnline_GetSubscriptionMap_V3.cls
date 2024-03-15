global class MCOnline_GetSubscriptionMap_V3 implements vlocity_cmt.VlocityOpenInterface2{
    static List<Data> finalData=new List<Data>();    
    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        Boolean result = true;
        try {
            if (methodName.equalsIgnoreCase('getSubscriptionCatalog'))
            {
                finalData.clear();
                getSubscriptionCatalog(outMap);
                    
            } 
            else
            {
                result = false;
            }
        } 
        catch (Exception e) {
            result = false;
            String error_message = e.getMessage() + ' ' + e.getLineNumber();
            outMap.put('statusCode', 500);
            outMap.put('Exception', e.getStackTraceString());
            MCOnline_Utility.logError(error_message, '500', 'MCOnline_GetSubscriptionMap_V3,MCOnline_GetSubscriptionMap_V3.invokeMethod', 'Apex Class', 'Exception', JSON.serialize(inputMap), '', '');
        }
        return result;
    }

    private static void getSubscriptionCatalog( Map<String,Object> outMap)
    {
        Map<String,List<String>> virtualMap=new Map<String,List<String>>();
        Map<String,List<String>> virtualMapAddOn=new Map<String,List<String>>();
        Map<String,List<String>> virtualTPAddOn=new Map<String,List<String>>();
        List<String> addOnOffers = new List<String>();
        Map<String,Object> noDuplicate = new Map<String,Object>();
        // fetch virtual offers from Catalog and child offers from vlocity_cmt__ProductChildItem__c
        List<vlocity_cmt__ProductChildItem__c> virtualItems =[SELECT
                                                              vlocity_cmt__ParentProductId__r.ProductCode,
                                                              vlocity_cmt__ChildProductId__c,
                                                              vlocity_cmt__ChildProductId__r.ProductCode,
                                                              vlocity_cmt__ChildProductId__r.vlocity_cmt__SpecificationType__c,
                                                              vlocity_cmt__ChildProductId__r.C2BC_Category__c,
                                                              vlocity_cmt__ParentProductId__r.C2BC_Category__c,
                                                              vlocity_cmt__ParentProductId__r.C2BC_SubCategory__c,
                                                              vlocity_cmt__ChildProductId__r.Feature_Id__c,
                                                              vlocity_cmt__ChildProductId__r.TeliaSE_Product_Service_Code__c
                                                              FROM 
                                                              vlocity_cmt__ProductChildItem__c
                                                              WHERE 
                                                              vlocity_cmt__ParentProductId__c IN (SELECT vlocity_cmt__Product2Id__c FROM vlocity_cmt__CatalogProductRelationship__c WHERE
                                                                                                  (vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c = 'SUBSCRIPTIONS' AND vlocity_cmt__Product2Id__r.C2BC_Category__c = 'offerbundle' AND
                                                                                                   vlocity_cmt__Product2Id__r.Family = 'Online Order' AND vlocity_cmt__Product2Id__r.C2BC_Subcategory__c IN ('mobilevoicesubscription','touchpoint','smartconnect','touchpointplus' ))) AND 
                                                              vlocity_cmt__ChildProductId__c!='' AND
                                                              vlocity_cmt__ChildProductId__r.C2BC_Category__c IN ('subscriptionbundle','mobilebroadbandsubscription','mobilevoicesubscription','addonbundle' ) AND 
                                                              vlocity_cmt__ParentProductId__r.IsActive =true AND
                                                              vlocity_cmt__ChildProductId__r.Family ='Online Order'];
        
        // create Map with key = virtual offer and value = list of offers under the virtual offer 
        for(vlocity_cmt__ProductChildItem__c item:virtualItems)
        {
            if(item.vlocity_cmt__ChildProductId__r.ProductCode.endsWith('_VO'))
            {
                item.vlocity_cmt__ChildProductId__r.ProductCode=item.vlocity_cmt__ChildProductId__r.ProductCode.substring(0,item.vlocity_cmt__ChildProductId__r.ProductCode.length()-3);
            }
            if(item.vlocity_cmt__ParentProductId__r.C2BC_Category__c=='offerbundle' && item.vlocity_cmt__ParentProductId__r.C2BC_Subcategory__c=='mobilevoicesubscription'){
                if(item.vlocity_cmt__ChildProductId__r.C2BC_Category__c == 'addonbundle' ){
                    if(!virtualMapAddOn.containsKey(item.vlocity_cmt__ParentProductId__r.productcode)){
                        virtualMapAddOn.put(item.vlocity_cmt__ParentProductId__r.productcode,new List<String>{item.vlocity_cmt__ChildProductId__r.ProductCode});    
                    }else{
                        virtualMapAddOn.get(item.vlocity_cmt__ParentProductId__r.productcode).add(item.vlocity_cmt__ChildProductId__r.ProductCode);
                    }
                }else if(item.vlocity_cmt__ChildProductId__r.C2BC_Category__c == 'subscriptionbundle'){
                    if(!virtualMap.containsKey(item.vlocity_cmt__ParentProductId__r.productcode)){
                        virtualMap.put(item.vlocity_cmt__ParentProductId__r.productcode,new List<String>{item.vlocity_cmt__ChildProductId__r.ProductCode});    
                    }else {
                        virtualMap.get(item.vlocity_cmt__ParentProductId__r.productcode).add(item.vlocity_cmt__ChildProductId__r.ProductCode);
                    }
                }   
            }else{
                if(!virtualTPAddOn.containsKey(item.vlocity_cmt__ParentProductId__r.productcode)){
                    virtualTPAddOn.put(item.vlocity_cmt__ParentProductId__r.productcode,new List<String>{item.vlocity_cmt__ChildProductId__r.ProductCode});    
                }else{
                    virtualTPAddOn.get(item.vlocity_cmt__ParentProductId__r.productcode).add(item.vlocity_cmt__ChildProductId__r.ProductCode);
                }
            }
        }
        // create JSON nodes for subscription
        getSubscription(virtualMap);
        
        //Create Orchestration addon node
        getOrchestration(virtualMap);
        
        // create JSON nodes for AddOns
        getAddOn(virtualMapAddOn);
        
        // create JSON nodes for TP AddOns
        getTPAddOn(virtualTPAddOn);
            
        // send final response
        for(Data result:finalData){
            noDuplicate.put(result.productCode+result.offer+result.virtualOffer,result);
        }
        //List<Object> noDup = noDuplicate.values();
        String str = JSON.serialize(noDuplicate.values()); 



        outMap.put('subscriptions',JSON.deserializeUntyped(str));
        outMap.put('success',true);
    }
    
    
    private static void getSubscription(Map<String,List<String>> virtualMap){
        // fetch active subscription product,bundle, offers from vlocity_cmt__ProductChildItem__c

        List<vlocity_cmt__ProductChildItem__c> items=[select 
                                                      vlocity_cmt__ChildProductId__r.Feature_Id__c,
                                                      vlocity_cmt__ChildProductId__r.TeliaSE_Product_Service_Code__c,
                                                      vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c,
                                                      vlocity_cmt__ParentProductId__r.ProductCode,
                                                      vlocity_cmt__ParentProductId__r.C2BC_Category__c, 
                                                      vlocity_cmt__ChildProductId__r.ProductCode, 
                                                      vlocity_cmt__ChildProductId__r.C2BC_Category__c 
                                                      from vlocity_cmt__ProductChildItem__c where 
                                                      vlocity_cmt__ChildProductId__r.C2BC_Category__c IN ('subscriptionbundle','mobilebroadbandsubscription','mobilevoicesubscription' ) AND vlocity_cmt__ParentProductId__r.C2BC_Category__c !='addonbundle' AND vlocity_cmt__ParentProductId__r.IsActive =true AND vlocity_cmt__ParentProductId__r.Family ='Online Order'];




        // iterate through all the virtual offers in the virtualMap
        for(String key:virtualMap.keySet()){
            // iterate through all the offers under the virtual offer
            for(String offer:virtualMap.get(key)){
                // iterate through all the child items fetched ( product/bundle/offers)
                for(vlocity_cmt__ProductChildItem__c item:items){
                    //if parent of child item is = offer
                    if(item.vlocity_cmt__ParentProductId__r.productcode == offer){
                        // call method to create JSON structure for the product under the bundle
                        createJSON(key,offer,item.vlocity_cmt__ChildProductId__r.productcode,items);
                    }


                        
                    }
                }
            }
        }

   
/****************************************************************************************************************************
* method                  getOrchestration
* params                  Map of virtual items 
* @description            updates the Orchestration addon products under the API 
* @created                13-09-2022
* @modified               13-09-2022
******************************************************************************************************************************/
private static void getOrchestration(Map<String,List<String>> virtualMap){
        Set<String> addonBundles=new Set<String>();
        List<String> subscriptionChildProducts=new List<String>();
        Map<String,String> childToParentMap=new Map<String,String>();
        List<vlocity_cmt__ProductChildItem__c> items=[select 
                                                      vlocity_cmt__ChildProductId__r.Feature_Id__c,
                                                      vlocity_cmt__ChildProductId__r.TeliaSE_Product_Service_Code__c,
                                                      vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c,
                                                      vlocity_cmt__ParentProductId__r.ProductCode,
                                                      vlocity_cmt__ParentProductId__r.C2BC_Category__c, 
                                                      vlocity_cmt__ChildProductId__r.ProductCode, 
                                                      vlocity_cmt__ChildProductId__r.C2BC_Category__c 
                                                      from vlocity_cmt__ProductChildItem__c where 
                                                      vlocity_cmt__ChildProductId__r.Ordering_Flag__c IN ('Hide') AND vlocity_cmt__ParentProductId__r.C2BC_Category__c ='addonbundle' AND vlocity_cmt__ParentProductId__r.IsActive =true AND vlocity_cmt__ChildProductId__r.Family ='Online Order' and vlocity_cmt__ChildProductId__r.C2BC_Category__c =null];
        
        
        for(vlocity_cmt__ProductChildItem__c addOnBundle:[select id,vlocity_cmt__ParentProductId__r.ProductCode from vlocity_cmt__ProductChildItem__c  where vlocity_cmt__ChildProductId__r.ProductCode ='MOB_MISC' ])
        {
            addonBundles.add(addOnBundle.vlocity_cmt__ParentProductId__r.ProductCode);
        }
        
        for(String key:virtualMap.keySet()){    
            subscriptionChildProducts.addAll(virtualMap.get(key));
            for(String value:virtualMap.get(key))
            {
                childToParentMap.put(value, key);
            }
        }
        for(String splitOffer:subscriptionChildProducts){
            if(addonBundles.contains(splitOffer))
            {
                for(vlocity_cmt__ProductChildItem__c childItem:items)
                {
                    createJSON(childToParentMap.get(splitOffer),splitOffer,childItem.vlocity_cmt__ChildProductId__r.productcode,items);
                }
            }
        }
    }   
    
        

    private static void getAddOn(Map<String,List<String>> virtualMapAddOn){
        Map<String,Object> noDuplicate = new Map<String,Object>();
        List<vlocity_cmt__ProductChildItem__c> addOns = new List<vlocity_cmt__ProductChildItem__c>();
        Set<String> virtualAddOnSet = new Set<String>(virtualMapAddOn.keySet());
        // create the list containing all the children and parent codes
        for(String key:virtualMapAddOn.keySet()){
            virtualAddOnSet.addAll(virtualMapAddOn.get(key));
        }
        // Fetch records for the above parent and children from the object
        List<vlocity_cmt__ProductChildItem__c> addOnItems=[select vlocity_cmt__ChildProductId__r.Feature_Id__c,
                                                           vlocity_cmt__ChildProductId__r.TeliaSE_Product_Service_Code__c,vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c,vlocity_cmt__ParentProductId__r.ProductCode,vlocity_cmt__ParentProductId__r.C2BC_Category__c, vlocity_cmt__ChildProductId__r.ProductCode, vlocity_cmt__ChildProductId__r.C2BC_Category__c,vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c, vlocity_cmt__ParentProductId__r.C2BC_Subcategory__c from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__c !='' AND vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c IN ( 'datasim','mdsecondary','mobilevoicesubscription')  AND vlocity_cmt__ChildProductId__r.C2BC_Category__c IN( 'mobilevoicesubscription','mobilebroadbandsubscription','addonbundle' )AND vlocity_cmt__ParentProductId__r.IsActive =true AND vlocity_cmt__ChildProductId__r.Family ='Online Order'AND vlocity_cmt__ParentProductId__r.ProductCode IN :virtualAddOnSet Order By vlocity_cmt__ChildProductId__r.ProductCode];
        // Create set of AddOnRecord and assign it the return from a function which removes duplicates
        for(vlocity_cmt__ProductChildItem__c result:addOnItems){
            noDuplicate.put(result.vlocity_cmt__ChildProductId__r.ProductCode+result.vlocity_cmt__ParentProductId__r.ProductCode,result);
        }
        List<Object> noDupObj = noDuplicate.values();
        for(Object obj:noDupObj){
            addOns.add((vlocity_cmt__ProductChildItem__c)obj);
        }
        // iterate through all the virtual  offers in the virtualMap with addOn
        for(String key:virtualMapAddOn.keySet()){
            // iterate through all the addOn offers under the virtual offer
            for(String addOnoffer:virtualMapAddOn.get(key)){
                createJSON(key,addOnoffer,addOnoffer,addOns);
            }   
        }
    }
    
    private static void createJSON(String virtualOffer,String offer,String bundleCode,List<vlocity_cmt__ProductChildItem__c> items){
        // iterate through the list of child items
        for(vlocity_cmt__ProductChildItem__c item:items){
            // if parent of the item = bundle then create the JSON structure with the following info
            if(item.vlocity_cmt__ParentProductId__r.productCode == bundleCode && (!String.isBlank(String.valueOf(item.vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c)))){
                Data data=new Data();
                data.catalog='SUBSCRIPTIONS';
                data.virtualOffer=virtualOffer;
                data.offer=offer;
                data.productCode=item.vlocity_cmt__ChildProductId__r.ProductCode;
                data.legacySubscriptionType=item.vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c;
                data.featureId = item.vlocity_cmt__ChildProductId__r.Feature_Id__c;
                data.productServiceCode = item.vlocity_cmt__ChildProductId__r.TeliaSE_Product_Service_Code__c;
                finalData.add(data);
            }
            else if((item.vlocity_cmt__ChildProductId__r.C2BC_Category__c ==null && item.vlocity_cmt__ParentProductId__r.ProductCode=='MOB_MISC')){
                Data data=new Data();
                data.catalog='SUBSCRIPTIONS';
                data.virtualOffer=virtualOffer;
                data.offer=offer;
                data.productCode=item.vlocity_cmt__ChildProductId__r.ProductCode;
                data.legacySubscriptionType=item.vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c;
                data.featureId = item.vlocity_cmt__ChildProductId__r.Feature_Id__c;
                data.productServiceCode = item.vlocity_cmt__ChildProductId__r.TeliaSE_Product_Service_Code__c;
                finalData.add(data);
            }
        }
    }
    
    private static void getTPAddOn(Map<String,List<String>> virtualTPAddOn){
        List<vlocity_cmt__ProductChildItem__c> tpAddOnItems=[select



                                                             vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c,
                                                             vlocity_cmt__ParentProductId__r.ProductCode,
                                                             vlocity_cmt__ParentProductId__r.C2BC_Category__c, 
                                                             vlocity_cmt__ChildProductId__r.ProductCode, 
                                                             vlocity_cmt__ChildProductId__r.C2BC_Category__c,
                                                             vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c,
                                                             vlocity_cmt__ParentProductId__r.C2BC_Subcategory__c,
                                                             vlocity_cmt__ChildProductId__r.Feature_Id__c,
                                                             vlocity_cmt__ChildProductId__r.TeliaSE_Product_Service_Code__c
                                                             from 
                                                             vlocity_cmt__ProductChildItem__c
                                                             where 
                                                             vlocity_cmt__ChildProductId__c !=''  AND 
                                                             (
                                                                 (vlocity_cmt__ChildProductId__r.C2BC_Category__c ='addonbundle' AND vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c IN('mobilevoicesubscription','switchboardextension','ucsswitchboards')) OR
                                                                 (vlocity_cmt__ChildProductId__r.C2BC_Category__c ='switchboardextension' OR vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c ='autofulfilment' ) OR
                                                                 (vlocity_cmt__ChildProductId__r.C2BC_Category__c ='ucsswitchboards' OR vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c ='ucinstance' )OR
                                                                 (vlocity_cmt__ChildProductId__r.C2BC_Category__c ='subscriptionbundle' AND vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c ='ucsswitchboards' )
                                                             ) AND
                                                             (
                                                                 vlocity_cmt__ParentProductId__r.C2BC_Category__c ='offerbundle' OR
                                                                 (vlocity_cmt__ParentProductId__r.C2BC_Category__c ='subscriptionbundle' AND  vlocity_cmt__ParentProductId__r.C2BC_SubCategory__c = 'ucsswitchboards') OR
                                                                 (vlocity_cmt__ParentProductId__r.C2BC_Category__c ='addonbundle' AND  vlocity_cmt__ParentProductId__r.C2BC_SubCategory__c IN( 'ucsswitchboards','mobilevoicesubscription','switchboardextension'))
                                                             )AND
                                                             
                                                             vlocity_cmt__ParentProductId__r.IsActive =true AND 
                                                             vlocity_cmt__ChildProductId__r.Family ='Online Order' Order By vlocity_cmt__ChildProductId__r.ProductCode
                                                            ]; 
        for(String key:virtualTPAddOn.keySet()){
            // iterate through all the offers under the virtual offer



            for(String offer:virtualTPAddOn.get(key)){
                // iterate through all the child items fetched ( product/bundle/offers)
                for(vlocity_cmt__ProductChildItem__c item:tpAddOnItems){
                    //if parent of child item is = offer
                    if(item.vlocity_cmt__ParentProductId__r.productcode == offer)
                    {
                        Boolean isBundle = item.vlocity_cmt__ChildProductId__r.C2BC_Category__c=='addonbundle'?true:false;
                        // call method to create JSON structure for the product under the bundle
                        createTPJSON(key,offer,item.vlocity_cmt__ChildProductId__r.productcode,tpAddOnItems,item,isBundle);
                    }
                }
            }
        }
    }



    private static void createTPJSON(String virtualOffer,String offer,String bundleCode,List<vlocity_cmt__ProductChildItem__c> items,vlocity_cmt__ProductChildItem__c item,Boolean isBundle){
        if(isBundle){
            // iterate through the list of child items
            for(vlocity_cmt__ProductChildItem__c listItem:items){
                // if parent of the item = bundle then create the JSON structure with the following info
                // if(item.vlocity_cmt__ParentProductId__r.productCode == bundleCode && (!String.isBlank(String.valueOf(item.vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c))))


                if(listItem.vlocity_cmt__ParentProductId__r.productCode == bundleCode ){
                    Data data=new Data();


                    data.catalog='SUBSCRIPTIONS';
                    data.virtualOffer=virtualOffer;
                    data.offer=offer;
                    data.productCode=listItem.vlocity_cmt__ChildProductId__r.ProductCode;
                    data.legacySubscriptionType=listItem.vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c;
                    data.featureId = listItem.vlocity_cmt__ChildProductId__r.Feature_Id__c;
                    data.productServiceCode = listItem.vlocity_cmt__ChildProductId__r.TeliaSE_Product_Service_Code__c;
                    finalData.add(data);

                }
            }

        }else{
            Data data=new Data();

            data.catalog='SUBSCRIPTIONS';
            data.virtualOffer=virtualOffer;
            data.offer=offer;
            data.productCode=item.vlocity_cmt__ChildProductId__r.ProductCode;
            data.legacySubscriptionType=item.vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c;
            data.featureId = item.vlocity_cmt__ChildProductId__r.Feature_Id__c;
            data.productServiceCode = item.vlocity_cmt__ChildProductId__r.TeliaSE_Product_Service_Code__c;
            finalData.add(data);
        }
        
    }
    //wrapper class for the response format
    private Class Data
    {
        String catalog;
        String virtualOffer;
        String offer;
        String productCode;
        String legacySubscriptionType;
        String featureId;
       String productServiceCode;    
    }

}