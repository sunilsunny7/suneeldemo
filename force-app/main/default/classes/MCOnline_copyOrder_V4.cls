global with sharing class MCOnline_copyOrder_V4 implements vlocity_cmt.VlocityOpenInterface {
    static Map<String,String> labelMap= new Map<String,String>();
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        if(methodName.equals('copyFromOrder')){
            copyFromOrder(inputMap,outMap,options);    
        }
        return true;
    }
    
    private static Map<String,Object> copyFromOrder(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options){
        List<Map<String,Object>> productConfig = new List<Map<String,Object>>();
        List<Map<String,Object>> offerDetails = new List<Map<String,Object>>();
        Map<String,Object> offer = new Map<String,Object>();
        List<String> productList = new List<String>();
        String orderNum = String.valueOf(inputMap.get('fromOrder'));
        String tscId = String.valueOf(inputMap.get('TSCID'));
        String user = String.valueOf(inputMap.get('users'));
        List<String> childprods = new List<String>();
        List<Map<String,Object>> addToBasketRequest = new List<Map<String,Object>>();
        Map<String,Object> multiAddToBasketRequest = new Map<String,Object>();
        Map<String,Object> basketDetail = new Map<String,Object>();
        Map<String,Object> addToBasketParam = new Map<String,Object>();
        Map<String,List<String>> parentChildMap = new Map<String,List<String>>();
        List<String> basName = new List<String>();
        boolean validOrder = isValidOrder(orderNum,tscId,user);
        if(validOrder){
            //fetch parent basket and its child baskets
            /*MCOnline_ParentBasket__c itemBasList = [SELECT Id,Name,UpdateOrderRequest__c,Account__r.id,AgreementId__r.id,AgreementId__r.Status,
(SELECT Id,Name,Order__c,MCOnline_Order__c,MCOnline_Contract__c,MCOnline_Catalog__c,TSCID__c,MCOnline_ParentBasket__c,MCOnline_OfferCode__c,MCOnline_AttributeJSON__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c
FROM MCOnline_Basket__r WHERE MCOnline_Orders__r.OrderNumber=:orderNum Order by createddate desc) 
FROM MCOnline_ParentBasket__c WHERE Is_Processed__c=true AND TSCID__c=:tscId AND Admin__c=:user Order by createddate desc limit 1];*/
            /*MCOnline_ParentBasket__c itemBasList = [SELECT Id,(SELECT Id,Name,Order__c,MCOnline_Order__c,MCOnline_Contract__c,MCOnline_Catalog__c,TSCID__c,MCOnline_ParentBasket__c,MCOnline_OfferCode__c,MCOnline_AttributeJSON__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c
                                                     FROM MCOnline_Basket__r WHERE MCOnline_Orders__r.OrderNumber=:orderNum Order by createddate desc) 
                                                    FROM MCOnline_ParentBasket__c WHERE Is_Processed__c=true AND TSCID__c=:tscId  Order by createddate desc limit 1];
*/   
// getting item basket list
            List<MCOnline_Basket__c> itemBasList = [SELECT Id,MCOnline_ParentBasket__r.Name,Name,Order__c,MCOnline_Order__c,MCOnline_Contract__c,MCOnline_Catalog__c,TSCID__c,MCOnline_ParentBasket__c,MCOnline_OfferCode__c,MCOnline_AttributeJSON__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c
                                                     FROM MCOnline_Basket__c WHERE MCOnline_ParentBasket__r.Is_Processed__c=true AND MCOnline_Orders__r.OrderNumber=:orderNum AND MCOnline_ParentBasket__r.TSCID__c=:tscId AND MCOnline_Catalog__c!='PROCESS' Order by createddate desc];
            
            //system.debug(JSON.serialize(itemBasList));
            if(verifyBasketItems(itemBasList,tscId)){
                outMap.put('ErrorResponse', generateError('INVALID_BASKET_ITEM', inputMap));
                outMap.put('StatusCode', 400);
            }
            //------------------------Code Added-------------------
            //Cli Validation with Basket
            /*List<String> cliList = new List<String>();
            for(vlocity_cmt__ContractLineItem__c cli: [select id,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.C2BC_Category__c, vlocity_cmt__Product2Id__r.C2BC_Subcategory__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__r.Status ='Active' AND vlocity_cmt__ContractId__r.Account.TSCID__c=:tscId])
            {
                cliList.add(cli.vlocity_cmt__Product2Id__r.ProductCode);
            }
            system.debug(cliList);
            Boolean prodFlag = false;
            
            for(MCOnline_Basket__c bas : itemBasList.MCOnline_Basket__r)
            {
                if( bas != null && bas.MCOnline_AttributeJSON__c != null )
                {
                    Map<String,Object> itemList = (Map<String,Object>)JSON.deserializeUntyped(bas.MCOnline_AttributeJSON__c);
                    List<Object> productList1 = (List<Object>)itemList.get('products');
                    
                    
                    for(Object obj: productList1)
                    {
                        Map<String, Object> recObj = ( Map<String, Object>)obj;
                        if(cliList != null && !cliList.contains(String.valueOf(recObj.get('productCode'))) && String.valueOf(bas.MCOnline_Catalog__c) != null && String.valueOf(bas.MCOnline_Catalog__c).equalsIgnoreCase('SUBSCRIPTIONS') && recObj.get('TeliaSE_Subscription_Type') != null)
                        {
                            prodFlag = true;
                            break;
                        }
                        
                    }
                    
                }
                
            }
            if(prodFlag)
            {
                outMap.put('ErrorResponse', generateError('INVALID_BASKET_ITEM', inputMap));
                outMap.put('StatusCode', 400);
            }*/
            else{
                //validate basket items against Catalog 
                if(validateProductCatalog(itemBasList)){
                    outMap.put('ErrorResponse', generateError('INVALID_BASKET_ITEM', inputMap));
                    outMap.put('StatusCode', 400);
                }else{
                    String copyOrderflag = 'copyorder';
                    // get offer details for the basket
                    System.debug(itemBasList);
                    for(MCOnline_Basket__c bas: itemBasList){
                        Map<String,Object> itemBasName = new Map<String,Object>();
                        Map<String,Object> result = new Map<String,Object>();
                        Map<String,Object> prodConf = new Map<String,Object>();
                        itemBasName.put('basketName',bas.Name);
                        MCOnline_GetBasketDetails.getbasketDetails(itemBasName,result,options,'copyorder');
                        prodConf =(Map<String,Object>)((Map<String,Object>)result.get('getOfferDetailOutput')).get('result');
                        System.debug(JSON.serialize(prodConf));
                        addToBasketRequest.add(prodConf);
                        basketDetail.put('basketLineRelationCount',Integer.valueOf(((Map<String,Object>)result.get('getOfferDetailOutput')).get('basketLineRelationCount')));
                        basketDetail.put('basketLineRelationId',String.valueOf(((Map<String,Object>)result.get('getOfferDetailOutput')).get('basketLineRelationId')));
                        basketDetail.put('contextKey',String.valueOf(((Map<String,Object>)result.get('getOfferDetailOutput')).get('contextKey')));
                        system.debug(addToBasketRequest);
                    }
                    // build structure as multiAddToBasket request
                    multiAddToBasketStructure(addToBasketRequest,basketDetail,outMap,copyOrderflag);
                    outMap.put('success',true);
                }
            }
            
        }else{
            outMap.put('ErrorResponse', generateError('INVALID_ORDER_NUMBER', inputMap));
            outMap.put('success',false);
        }
        return outMap;     
    }
    
    //verify basket items 
    private static boolean verifyBasketItems(List<MCOnline_Basket__c> itemBasList,String tscid){
        //System.debug(itemBasList);
        Boolean invalidItem = false;
        Map<String,Object> basProductMap = new Map<String,Object>();
        if(itemBasList.isEmpty()){
            invalidItem = true;
        }
        else{
        
       // Map<String,Object> prodCategory = new Map<String,Object>();
        List<String> splitOfferList = new  List<String>();
        for(MCOnline_Basket__c bas : itemBasList){
        Map<String,Object> prodCategory = new Map<String,Object>();
            if( bas != null && bas.MCOnline_AttributeJSON__c != null ){
                system.debug('offer-->'+bas.MCOnline_OfferCode__c);
                prodCategory.put('offer',bas.MCOnline_OfferCode__c);
                splitOfferList.add(bas.MCOnline_OfferCode__c);
                Map<String,Object> itemList = (Map<String,Object>)JSON.deserializeUntyped(bas.MCOnline_AttributeJSON__c);
                List<Object> prodList = (List<Object>)itemList.get('products');
                List<String> subscriptionList = new List<String>();
                List<String> addOnList = new List<String>();
                List<String> hwList = new List<String>();
               //System.debug(JSON.serialize(prodList));
                //System.debug(splitOfferList);
                for(Object obj: prodList){
                    Map<String, Object> recObj = ( Map<String, Object>)obj;
                    System.debug(String.valueOf(bas.MCOnline_Catalog__c));
                    //System.debug(recObj.get('C2BC_Category'));
                    //System.debug(recObj.get('C2BC_Subcategory'));
                    if(String.valueOf(bas.MCOnline_Catalog__c).equalsIgnoreCase('SUBSCRIPTIONS') ){
                        if(recObj.get('TeliaSE_Subscription_Type') != null){
                            subscriptionList.add(String.valueOf(recObj.get('productCode')));
                            system.debug('subscriptionList-->'+subscriptionList);
                            prodCategory.put('subscriptions',subscriptionList);
                        }else if(recObj.get('TeliaSE_Subscription_Type') == null){
                            addOnList.add(String.valueOf(recObj.get('productCode')));
                            system.debug('addOns-->'+addOnList);
                            prodCategory.put('addOns',addOnList);
                        }    
                    }else if(String.valueOf(bas.MCOnline_Catalog__c).equalsIgnoreCase('MOBILEDEVICE') && recObj.get('C2BC_Category') =='goods' && recObj.get('C2BC_Subcategory') =='mobiledevice' ){ 
                        hwList.add(String.valueOf(recObj.get('productCode')));
                        system.debug('hardware-->'+hwList);
                        prodCategory.put('hardware',hwList);
                    }
                    
                }
                 //System.debug(JSON.serialize(basProductMap));
                basProductMap.put(bas.Name,prodCategory);  
               //System.debug(JSON.serialize(basProductMap));
            }
           //System.debug(JSON.serialize(basProductMap));
        }
        //System.debug(JSON.serialize(basProductMap));
        List<String> subscriptionList = new List<String>();
        for(String childBas:basProductMap.keySet()){
            Map<String,Object> nodeList= (Map<String,Object>)basProductMap.get(childBas);
            if(String.valueOf(nodeList.keySet()).contains('subscriptions')){
               subscriptionList.addAll((List<String>)((Map<String,Object>)basProductMap.get(childBas)).get('subscriptions'));
                }
        }
        List<String> agrprodList = new List<String>();
        for(vlocity_cmt__ContractLineItem__c agrProd: [select id,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.C2BC_Category__c, vlocity_cmt__Product2Id__r.C2BC_Subcategory__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__r.Status ='Active' AND vlocity_cmt__ContractId__r.Account.TSCID__c=:tscId AND vlocity_cmt__Product2Id__r.ProductCode IN:subscriptionList])
        {
            agrprodList.add(agrProd.vlocity_cmt__Product2Id__r.ProductCode);
        }
        System.debug('agrprodList-->'+agrprodList);
        //verify basket subscription item against contract line items
        for(String item:subscriptionList){
            if(!agrprodList.contains(item)){
                invalidItem = true;
                break;
            }
        }
        }
        if(invalidItem){
            return invalidItem;      
        }else{
            //verify basket addOn items 
            return validateAddOnHW(basProductMap);
            
        }
        
        
        
    }
    
    // verify addOns/HW
    private static boolean validateAddOnHW(Map<String,Object> basProductMap){
        List<String> splitOfferList = new  List<String>();
        List<String> addOnList = new List<String>();
        List<String> hwList = new List<String>();
        Boolean invalidItem = false;
        //System.debug(JSON.serialize(basProductMap));
        for(String childBas:basProductMap.keySet()){
             Map<String,Object> nodeList= (Map<String,Object>)basProductMap.get(childBas);
             if(String.valueOf(nodeList.keySet()).contains('addOns')){
                addOnList.addAll((List<String>)((Map<String,Object>)basProductMap.get(childBas)).get('addOns'));
             }else if(String.valueOf(nodeList.keySet()).contains('hardware')){
                 hwList.addAll((List<String>)((Map<String,Object>)basProductMap.get(childBas)).get('hardware'));
             }
             splitOfferList.add(String.valueOf(((Map<String,Object>)basProductMap.get(childBas)).get('offer')));
        }
        System.debug('addOnList-->'+addOnList);
        System.debug('splitOfferList--->'+splitOfferList);
       
        List<vlocity_cmt__ProductChildItem__c> pci = [select id,vlocity_cmt__ParentProductId__r.ProductCode, vlocity_cmt__ChildProductId__r.ProductCode from vlocity_cmt__ProductChildItem__c where (vlocity_cmt__ChildProductId__r.ProductCode IN:addOnList AND vlocity_cmt__ChildProductId__c!=null and vlocity_cmt__ParentProductId__r.Family ='Online Order') OR (vlocity_cmt__ParentProductId__r.ProductCode IN:splitOfferList AND vlocity_cmt__ChildProductId__c!=null and vlocity_cmt__ParentProductId__r.Family ='Online Order') OR (vlocity_cmt__ChildProductId__r.ProductCode IN:hwList AND vlocity_cmt__ChildProductId__c!=null)];
        System.debug('pci-->'+pci);
        Map<String,List<String>> pChildMap = new Map<String,List<String>>();
        List<String> childList= new List<String>();
        for(vlocity_cmt__ProductChildItem__c parentChild: pci){
            If(!pChildMap.containsKey(parentChild.vlocity_cmt__ParentProductId__r.ProductCode)){
                pChildMap.put(parentChild.vlocity_cmt__ParentProductId__r.ProductCode,new List<String>{parentChild.vlocity_cmt__ChildProductId__r.ProductCode});        
            }else{
                pChildMap.get(parentChild.vlocity_cmt__ParentProductId__r.ProductCode).add(parentChild.vlocity_cmt__ChildProductId__r.ProductCode);
            }
        }
        System.debug('pChildMap-->'+pChildMap);
        
        for(String cBas:basProductMap.keySet()){
            List<String> basAddOnList = (List<String>)((Map<String,Object>)basProductMap.get(cBas)).get('addOns');
            List<String> hardwareList = (List<String>)((Map<String,Object>)basProductMap.get(cBas)).get('hardware');
            //List<String> addOnHardware = new List<String>();
            //addOnHardware.addAll((List<String>)((Map<String,Object>)basProductMap.get(cBas)).get('addOns'));
            //addOnHardware.addAll((List<String>)((Map<String,Object>)basProductMap.get(cBas)).get('hardware'));
            String basOffer = String.ValueOf(((Map<String,Object>)basProductMap.get(cBas)).get('offer'));
            List<String> pcrAddonHw = new List<String>(); 
            //List<String> pcrHw= new List<String>();
            for(String bundle:pChildMap.get(basOffer)){
                if(bundle != null && pChildMap.keySet() != null && pChildMap.keySet().contains(bundle)){
                    pcrAddonHw.addAll(pChildMap.get(bundle));
                }
                //if(pChildMap.keySet().contains(bundle)){
                    //pcrHw.addAll(pChildMap.get(bundle));
                //}
            } 
            System.debug(pcrAddonHw);
            if(basAddOnList != null){
            for(String basAddOn:basAddOnList){
                System.debug(basAddOn);
                if(!pcrAddonHw.contains(basAddOn)){
                    invalidItem = true;
                    break; 
                }
            } 
            }
            if(hardwareList != null){
            for(String basHw:hardwareList){
                System.debug(basHw);
                if(!pcrAddonHw.contains(basHw)){
                    invalidItem = true;
                    break; 
                }
            } 
            }
            
            //System.debug(hardwareList);
            //for(String basHW:hardwareList){
              //  System.debug(basHW);
                //if(!pcrHw.contains(basHW)){
                  //  invalidItem = true;
                    //break; 
                //}
            //}
            if(invalidItem == true)
                break;
        }
        System.debug('invalidItem'+invalidItem);
        return invalidItem;
        
    }
    
    // verify basket items against Catalog
    @TestVisible
    private static boolean validateProductCatalog(List<MCOnline_Basket__c> itemBasList){
        Set<String> offerCodeList = new Set<String>();
        List<String> basName = new List<String>();
        List<String> productList = new List<String>();
        Set<String> parentSet = new Set<String>();
        Boolean invalidProductCatalog = false;
        for(MCOnline_Basket__c bas: itemBasList){
            Map<String,Object> basItems = new Map<String,Object>();
            offerCodeList.add(bas.MCOnline_OfferCode__c);
            basName.add(bas.Name);
            System.debug(basName);
            //iterate through all the mini baskets and traverse AttributeJSON. if TeliaSE_Subscription_Type!=null
            // then add productCode to one list
            basItems = (Map<String,Object>)JSON.deserializeUntyped(bas.MCOnline_AttributeJSON__c);
            for(Object item:(List<Object>)basItems.get('products')){
                Map<String,Object> itemValue = (Map<String,Object>)item;
                if(String.valueOf(itemValue.get('TeliaSE_Subscription_Type'))!=null){
                    productList.add(String.valueOf(itemValue.get('productCode')));    
                }  
                if(String.valueOf(bas.MCOnline_Catalog__c) != null && String.valueOf(bas.MCOnline_Catalog__c).equalsIgnoreCase('MOBILEDEVICE')){
                    productList.add(String.valueOf(itemValue.get('productCode')));
                    }    
            }
         }
         // fetch records from parentchild table and catalogRelationship for the offers 
         List<vlocity_cmt__ProductChildItem__c> catalogProd = [SELECT vlocity_cmt__ParentProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.ProductCode FROM vlocity_cmt__ProductChildItem__c WHERE 
                                                                      vlocity_cmt__ParentProductId__c IN (SELECT vlocity_cmt__Product2Id__c FROM vlocity_cmt__CatalogProductRelationship__c where vlocity_cmt__Product2Id__c!=null AND vlocity_cmt__IsActive__c =  true AND vlocity_cmt__Product2Id__r.ProductCode IN :offerCodeList ) AND vlocity_cmt__ParentProductId__r.IsActive =true AND vlocity_cmt__ChildProductId__c !=null];
        system.debug(catalogProd); 
        for(vlocity_cmt__ProductChildItem__c parent:catalogProd){
            parentSet.add(parent.vlocity_cmt__ParentProductId__r.ProductCode);
         }  
            if(parentSet!=Null && !parentSet.containsAll(offerCodeList)){
            invalidProductCatalog = true;
         }
         return invalidProductCatalog;
    }
    
    // verify if any un processed baskets associated with the passed in Order
    @TestVisible
    private static boolean isValidOrder(String orderNum,String tscId,String user){
        //List<Order> ordNum = [select id ,(select id,Name from MCOnline_Basket__r WHERE MCOnline_Orders__r.OrderNumber=:orderNum AND MCOnline_ParentBasket__r.TSCID__c=:tscId AND MCOnline_ParentBasket__r.Admin__c =:user AND MCOnline_ParentBasket__r.Is_Processed__c=true) from Order where OrderNumber = :orderNum];
        //List<Order> ordNum = [select id,Name from MCOnline_Basket__c WHERE MCOnline_Orders__c.OrderNumber=:orderNum AND MCOnline_ParentBasket__c.TSCID__c=:tscId AND MCOnline_ParentBasket__c.Admin__c =:user AND MCOnline_ParentBasket__c.Is_Processed__c=true];
        List<Order> ordNum = [select id ,(select id,Name from MCOnline_Basket__r WHERE MCOnline_Orders__r.OrderNumber=:orderNum AND MCOnline_ParentBasket__r.TSCID__c=:tscId AND MCOnline_ParentBasket__r.Is_Processed__c=true) from Order where OrderNumber = :orderNum];
        if(ordNum.size()==0){
            return false;    
        }else{
            return true;
        }
        
    }
    
    // multiAddToBasket structure
    @TestVisible
    private static void multiAddToBasketStructure(List<Map<String,Object>> addToBasketRequest,Map<String,Object> basketDetail,Map<String,Object> outMap,String copyOrderflag ){
        Map<String,Object> multiAddToBasketRequest = new   Map<String,Object>();
        List<Map<String,Object>> prodConfig = new List<Map<String,Object>>();
        outMap.put('basketLineRelationCount',Integer.valueOf(basketDetail.get('basketLineRelationCount')));
        outMap.put('basketLineRelationId',String.valueOf(basketDetail.get('basketLineRelationId')));
        outMap.put('basketAction','AddAfterConfig');
        outMap.put('contextKey',String.valueOf(basketDetail.get('contextKey')));
        for(Map<String,Object> result: addToBasketRequest){
            
            prodConfig.add(result);
        }
        outMap.put('productConfig',prodConfig);
        
    }
    
    // Method to Generate Error 
    public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap){
        
        String fromOrder= String.valueOf(inputMap.get('fromOrder'));
        String tscid = String.valueOf(inputMap.get('TSCID'));
        String users = String.valueOf(inputMap.get('users'));
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        string urlDetails = '{"fromOrder": "'+fromOrder+'", "TSCID":"'+tscid+'", "users":"'+users+'"}';
        ipInputMap.put('functionality', 'CopyOrder');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_copyOrder_V4,MCOnline_copyOrder_V4.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    
    
}