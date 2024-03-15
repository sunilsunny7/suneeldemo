/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_SingleCartOfferCreation 
**Created By  :        Aditi Goyal
**Date      :          10 March 2022
**User Story  :        MCSTO-9879,9880 - R_22.4
**Description :        Apex class to support multi-add for Offer Cart generation
-----------------------------------------------------------------------------------------------------------*/

global class MC_SingleCartOfferCreation implements vlocity_cmt.VlocityOpenInterface{
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result = true;
            if (methodName.equals('createSingleCartOffer')){
                createSingleCartOffer(inputMap,outMap);
            }             
            else if (methodName.equals('updateAddToCartRequestList')){
                updateAddToCartRequestList(inputMap,outMap);
            }
            return result;              
        
        }
    
        
    private static void createSingleCartOffer(Map<String,Object> inputMap, Map<String,Object> outMap){
        //LTAART-328: Commented this Method as we are now using Simplified Line Items only to create the Offer Document
        /*
        String quoteId = (String)inputMap.get('ContextId');
        String offQt = (String)inputMap.get('OfferQuoteId');
        List<String> objectTypesList = System.label.MC_OfferCartObjectTypes.split(',');
        Map<String,MC_OfferCreation_ObjSplit__c> objTypes = MC_OfferCreation_ObjSplit__c.getAll();
        String fieldsToAdd = '';
        Map<String, QuoteLineItem> productPBEMap = new Map<String, QuoteLineItem>();     
        List<QuoteLineItem> qliList = [SELECT id, QuoteId,Quote.OpportunityId,TeliaSE_Offer_Type__c, vlocity_cmt__ParentItemId__c, Quote.AccountId, Product2Id,TeliaSE_MC_FACallOffQuantity__c, 
                                       PricebookEntry.Name, PricebookEntryId, PricebookEntry.Pricebook2Id,TeliaSE_Product_Object_Type__c,TeliaSE_ParentClusterCode__c,
                                       Product2.Name, Product2.ProductCode, vlocity_cmt__ProductHierarchyPath__c,TeliaSE_MC_Binding_Time__c, vlocity_cmt__AssetReferenceId__c 
                                       FROM QuoteLineItem 
                                       WHERE QuoteId =:quoteId];  //AND TeliaSE_MC_FACallOffQuantity__c >= 0]; 
        //Virtual Offer Offers
        Set<String> virtualOffers = new set<String>();        
        for(QuoteLineItem qli :qliList){
            if(objTypes.containskey(qli.TeliaSE_Product_Object_Type__c) && (String)qli.get(objTypes.get(qli.TeliaSE_Product_Object_Type__c).fieldsToAdd__c) != null){ 
                productPBEMap.put(qli.Product2Id + (String)qli.get(objTypes.get(qli.TeliaSE_Product_Object_Type__c).fieldsToAdd__c),qli);    
            }
            else{
                productPBEMap.put(qli.Product2Id,qli);
            }
            if(qli.TeliaSE_Product_Object_Type__c == 'Virtual Offer Products'){
                virtualOffers.add(qli.Product2Id);
            }
        }
        Set<QuoteLineItem> firstLevelProdSet   = new Set<QuoteLineItem>();
        Set<QuoteLineItem> secondLevelProdSet  = new Set<QuoteLineItem>();
        Set<QuoteLineItem> thirdLevelProdSet   = new Set<QuoteLineItem>();
        Set<QuoteLineItem> rootLevelProdSet    = new Set<QuoteLineItem>();
        Set<QuoteLineItem> fourthLevelProdSet  = new Set<QuoteLineItem>();
        Set<QuoteLineItem> fifthLevelProdSet   = new Set<QuoteLineItem>();
        Set<QuoteLineItem> parentBundleProdSet   = new Set<QuoteLineItem>();
        Integer hpathSize = 0;
        
        for(QuoteLineItem qli: qliList){
            if(qli.TeliaSE_MC_FACallOffQuantity__c >= 0 ){ 
                //list of all productIds in the hierarchy
                List<String> hPathList = qli.vlocity_cmt__ProductHierarchyPath__c.split('<');
                hpathSize = hPathList.size();
                Boolean isPTorInsurance = objectTypesList.contains(qli.TeliaSE_Product_Object_Type__c);
        Boolean isSpecialScenario = objTypes.containskey(qli.TeliaSE_Product_Object_Type__c);
                String uniqueKeyParam = isSpecialScenario && (String)qli.get(objTypes.get(qli.TeliaSE_Product_Object_Type__c).fieldsToAdd__c) != null? (String)qli.get(objTypes.get(qli.TeliaSE_Product_Object_Type__c).fieldsToAdd__c) : '';
                //based on the hierarchy path size, build diff sets of QLIs for each hierarchy level
                //adding the QLI(>=0 Qty) & its immediate parent, root parent qlis in diff sets based on the hierarchy levels
                if(hpathSize == 1){
                    firstLevelProdSet.add(qli);
                }
                else if(hpathSize == 2){
                    if(isPTorInsurance){ //for PT & Insurance, the root bundle also needs to be added
                        firstLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-2]));  //add the immediate parent (root in this case)
                        secondLevelProdSet.add(qli);                       
                    }else{
                        firstLevelProdSet.add(qli);   
                    }
                }
                else if(hpathSize == 3){
                    if(isPTorInsurance){
                        firstLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-3]));  //add the root parent
                        secondLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-2])); //add the immediate parent
                        thirdLevelProdSet.add(qli); 
                    }
                   // else if(isOffice){ 
                   else if(objTypes.containskey(qli.TeliaSE_Product_Object_Type__c){
                        firstLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-2] + qli.get(objTypes.get(qli.TeliaSE_Product_Object_Type__c).fieldsToAdd__c)); //add the immediate parent
                        secondLevelProdSet.add(qli);                                                  
                    }else{
                        string firstLevel='';
                        if(virtualOffers.contains(hPathList[hpathSize-2])){
                            firstLevel = hPathList[hpathSize-2];
                        }
                        else{
                            firstLevel = hPathList[hpathSize-2] + uniqueKeyParam;
                        }
                        firstLevelProdSet.add(productPBEMap.get(firstLevel)); //add first level parent like KLUSTERS in Mobile
                        //firstLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-2])); //add the immediate parent
                        secondLevelProdSet.add(qli);  
                    }
                }
                else if(hpathSize == 4){
                    if(isPTorInsurance){
                        firstLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-4]));  
                        secondLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-3])); 
                        thirdLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-2]));                         
                        fourthLevelProdSet.add(qli); 
                    }else{
                        string firstLevel='';
                        if(virtualOffers.contains(hPathList[hpathSize-3])){
                            firstLevel = hPathList[hpathSize-3];
                        }
                        else{
                            firstLevel = hPathList[hpathSize-3] + uniqueKeyParam;
                        }
                        string secondLevel='';
                        if(virtualOffers.contains(hPathList[hpathSize-2])){
                            secondLevel = hPathList[hpathSize-2];
                        }
                        else{
                            secondLevel = hPathList[hpathSize-2] + uniqueKeyParam;
                        }
                        //System.debug('Qli:' + qli.Product2Id + ' Parent: '+ secondLevel + ' Cluster: '+ firstLevel);
                        firstLevelProdSet.add(productPBEMap.get(firstLevel)); //add first level parent like KLUSTERS in Mobile
                        secondLevelProdSet.add(productPBEMap.get(secondLevel)); //add the immediate parent like Group1,Group2 in Mobile
                        thirdLevelProdSet.add(qli); //add the QLI product itself like addon1,addon2
                    }
                    else if(objTypes.containskey(qli.TeliaSE_Product_Object_Type__c){
                        firstLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-3]+ qli.get(objTypes.get(qli.TeliaSE_Product_Object_Type__c).fieldsToAdd__c))); //add first level parent like KLUSTERS in Mobile
                        secondLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-2]+ qli.get(objTypes.get(qli.TeliaSE_Product_Object_Type__c).fieldsToAdd__c))); //add the immediate parent like Group1,Group2 in Mobile
                        thirdLevelProdSet.add(qli);                                                
                    }else{          
                        firstLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-3])); //add first level parent like KLUSTERS in Mobile
                        secondLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-2])); //add the immediate parent like Group1,Group2 in Mobile
                        thirdLevelProdSet.add(qli); //add the QLI product itself like addon1,addon2
                    }                     
                }
                else if(hpathSize == 5){ //this level of hierarchy is currently only in PT
                    if(isPTorInsurance){
                        firstLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-5]));  
                        secondLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-4])); 
                        thirdLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-3]));                         
                        fourthLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-2])); 
                        fifthLevelProdSet.add(qli);
                    }else{
                        firstLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-4]));
                        secondLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-3]));
                        thirdLevelProdSet.add(productPBEMap.get(hPathList[hpathSize-2]));
                        fourthLevelProdSet.add(qli); 
                    }
                }
            }
        }
        
        //building request maps for each level of products
        if(firstLevelProdSet.size()>0){
            //System.debug(' firstLevelProdSet__'+ firstLevelProdSet);            
            String requestString = JSON.serialize(buildRequestMap(firstLevelProdSet,null,offQt,true));
            parentBundleProdSet.addAll(firstLevelProdSet);
            outMap.put('singleWrapList',JSON.deserializeUntyped(requestString));
        }
        if(secondLevelProdSet.size()>0){
            //System.debug(' secondLevelProdSet size_'+ secondLevelProdSet.size());     
            String requestString = JSON.serialize(buildRequestMap(secondLevelProdSet,parentBundleProdSet,offQt,false));
            parentBundleProdSet.addAll(secondLevelProdSet);
            outMap.put('secondLevelProdList',JSON.deserializeUntyped(requestString));
        }
        if(thirdLevelProdSet.size()>0){
            String requestString = JSON.serialize(buildRequestMap(thirdLevelProdSet,parentBundleProdSet,offQt,false));
            parentBundleProdSet.addAll(thirdLevelProdSet);
            outMap.put('thirdLevelProdList',JSON.deserializeUntyped(requestString));
        }
        if(fourthLevelProdSet.size()>0){
            String requestString = JSON.serialize(buildRequestMap(fourthLevelProdSet,parentBundleProdSet,offQt,false));
            parentBundleProdSet.addAll(fourthLevelProdSet);
            outMap.put('fourthLevelProdList',JSON.deserializeUntyped(requestString));
        }
        if(fifthLevelProdSet.size()>0){
            String requestString = JSON.serialize(buildRequestMap(fifthLevelProdSet,parentBundleProdSet,offQt,false));
            outMap.put('fifthLevelProdList',JSON.deserializeUntyped(requestString));
        }
        //System.debug('outMap__'+outMap);
*/    
}
    
    //method to create request map as per CPQ API request structure using wrapper classes
    /*
    private static List<SingleCartRequestWrapper> buildRequestMap( Set<QuotelineItem> eachLevelProdSet,Set<QuotelineItem> parentProdSet,Id cartId, Boolean isFirstLevel){
        Map<String, String> levelHierachyMap   = new Map<String, String>();
        Map<String, String> priceBookEntryMap   = new Map<String, String>();
        List<SingleCartRequestWrapper> wrapList = new List<SingleCartRequestWrapper>();
        SingleCartRequestWrapper singlewrap= new SingleCartRequestWrapper() ;
        List<ItemsWrap> itemwrapList  = new List<ItemsWrap>();        
        ItemsWrap itemwrap  = new ItemsWrap();
        Boolean priceFlag = true;
        Map<String,MC_OfferCreation_ObjSplit__c> objTypes = MC_OfferCreation_ObjSplit__c.getAll();
        List<QuoteLineItem> repeatedItemList  = new List<QuoteLineItem>();
        
        if(isFirstLevel){
            Integer count = 1;
            String key = '';
            Map<String,List<QuoteLineitem>>  repeatedItemListMap = new Map<String,List<QuoteLineitem>>();
            Integer splitSize = Integer.valueOf(System.Label.MC_OfferCartSplitValue);
            List<QuotelineItem> itemsList = new  List<QuotelineItem>();
            List<Map<String,List<QuotelineItem>>> itemListAfterSplit = new list<Map<String,List<QuotelineItem>>>();   
            //System.debug('seachLevelProdSetSize__'+eachLevelProdSet.size());
            //splitting the first level list into multiple requests based on the splitSize(25) to avoid timeouts while inserting more number of items in one request
            for(QuotelineItem eachProduct :eachLevelProdSet){
                //added Code
                if(objTypes.keySet().contains(eachProduct.TeliaSE_Product_Object_Type__c)){
                    repeatedItemList.add(eachProduct);
                }
                else{                    
                    itemsList.add(eachProduct);
                    if(count < splitSize){
                        count ++;
                    }
                    else if (count == splitSize){
                        Map<String,List<QuotelineItem>> tempMap = new Map<String,List<QuotelineItem>>();
                        List<QuotelineItem> qliClone = itemsList.clone();
                        tempMap.put('RequestList',qliClone);
                        itemListAfterSplit.add(tempMap);
                        itemsList.clear();
                        count=1;
                    }
                }
                
            }
            if(itemsList.size()>0){
                Map<String,List<QuotelineItem>> tempMap = new Map<String,List<QuotelineItem>>();
                tempMap.put('RequestList',itemsList);
                itemListAfterSplit.add(tempMap);
            }
            //System.debug('singleWrapListSize_'+itemListAfterSplit.size());
            for(Map<String,List<QuotelineItem>> qliMap : itemListAfterSplit){
                List<QuotelineItem> qliList = qliMap.get('RequestList');
                String itemIds,itemName;
                itemwrap  = new ItemsWrap();
                singlewrap= new SingleCartRequestWrapper() ;
                itemwrapList  = new List<ItemsWrap>();
                //concatenating all first level itemIds for multi-add
                for(QuotelineItem eachQLI :qliList){
                    itemName = (itemName == null? eachQLI.Product2.Name  : itemName+';'+eachQLI.Product2.Name );
                    itemIds = (itemIds == null? (String)eachQLI.PricebookEntryId : itemIds+','+(String)eachQLI.PricebookEntryId);
                }
                itemwrap.itemName = itemName;
                itemwrap.itemId = itemIds;
                itemwrap.quantity = 1;
                itemwrapList.add(itemwrap);
                singlewrap.noResponseNeeded = true;
                singlewrap.items = itemwrapList; 
                singlewrap.cartId =cartId;
                singlewrap.validate = false;
                singlewrap.price = priceFlag;
                wrapList.add(singlewrap);
            }
            
            if(repeatedItemList.size()>0)
            {
                for(QuoteLineItem qli:repeatedItemList)
                {
                    MC_OfferCreation_ObjSplit__c obj = objTypes.get(qli.TeliaSE_Product_Object_Type__c);
                    key = obj.fieldsToAdd__c;
                    
                    if(repeatedItemListMap.containsKey((String)qli.get(key)))
                    {
                        List<quotelineitem> qliList = repeatedItemListMap.get((String)qli.get(key));
                        qliList.add(qli);
                        repeatedItemListMap.put((String)qli.get(key),qliList);
                    }
                    else
                    {
                        List<quotelineitem> qliList = new List<QuoteLineItem>();
                        qliList.add(qli);
                        repeatedItemListMap.put((String)qli.get(key),qliList);                        
                    }                    
                }
                ////System.debug(json.serialize(repeatedItemListMap));
                
                for(String repeatingVar : repeatedItemListMap.keySet())
                {
                    List<QuoteLineItem> qliList = (List<QuoteLineItem>)repeatedItemListMap.get(repeatingVar);
                    String itemIds,itemName;
                    Map<String,Object> fieldsToUpdate = new Map<String,Object>();
                    itemwrap  = new ItemsWrap();
                    singlewrap= new SingleCartRequestWrapper() ;
                    itemwrapList  = new List<ItemsWrap>();
                    //concatenating all first level itemIds for multi-add
                    for(QuotelineItem eachQLI :qliList){
                        itemName = (itemName == null? eachQLI.Product2.Name  : itemName+';'+eachQLI.Product2.Name );
                        itemIds = (itemIds == null? (String)eachQLI.PricebookEntryId : itemIds+','+(String)eachQLI.PricebookEntryId);
                        fieldsToUpdate.put(objTypes.get(eachQLI.TeliaSE_Product_Object_Type__c).fieldsToAdd__c,eachQLI.get(objTypes.get(eachQLI.TeliaSE_Product_Object_Type__c).fieldsToAdd__c));                        
                    }
                    itemwrap.itemName = itemName;
                    itemwrap.itemId = itemIds;
                    itemwrap.quantity = 1;
                    itemwrap.fieldsToUpdate = fieldsToUpdate;
                    itemwrapList.add(itemwrap);
                    singlewrap.noResponseNeeded = true;
                    singlewrap.items = itemwrapList; 
                    singlewrap.cartId =cartId;
                    singlewrap.validate = false;
                    singlewrap.price = priceFlag;
                    wrapList.add(singlewrap);
                }
            }
        }
        else{
            for(QuotelineItem parentBundle : parentProdSet){
                //System.debug('parentBundle__'+parentBundle);
                if(parentBundle != null){
                    String itemIds,itemName;
                    itemwrap  = new ItemsWrap();
                    singlewrap= new SingleCartRequestWrapper() ;
                    Map<String,Object> fieldsToAdd = new Map<String,Object>();
                    itemwrapList  = new List<ItemsWrap>();
                    
                    //concatenating all child level itemIds for multi-add,grouped by parentIds
                    for(QuotelineItem eachProduct :eachLevelProdSet){
                        if(eachProduct != null){
                            //23.10 <<LTAART-356>> AssetReferenceId change - <<Sanjoli>>
                            if(parentBundle.vlocity_cmt__AssetReferenceId__c == eachProduct.vlocity_cmt__ParentItemId__c){
                                //added ItemName just for ease of understanding in OS, not actually needed for API request
                                itemName = (itemName == null? eachProduct.Product2.Name  : itemName+';'+eachProduct.Product2.Name );
                                itemIds = (itemIds == null? (String)eachProduct.Pricebookentryid  : itemIds+','+(String)eachProduct.Pricebookentryid );
                                if(objTypes.containsKey(eachProduct.TeliaSE_Product_Object_Type__c)){
                                    fieldsToAdd.put(objTypes.get(eachProduct.TeliaSE_Product_Object_Type__c).fieldsToAdd__c,eachProduct.get(objTypes.get(eachProduct.TeliaSE_Product_Object_Type__c).fieldsToAdd__c));
                                }
                                                            
                            } 
                        }                   
                    }
                    //added for NMP3
                    Boolean isSpecialScenario = objTypes.containskey(parentBundle.TeliaSE_Product_Object_Type__c);
                String uniqueKeyParam = isSpecialScenario && (String)parentBundle.get(objTypes.get(parentBundle.TeliaSE_Product_Object_Type__c).fieldsToAdd__c)!= null ? (String)parentBundle.get(objTypes.get(parentBundle.TeliaSE_Product_Object_Type__c).fieldsToAdd__c) : '';
          
                    //System.debug('itemIds_'+itemIds);
                    if(String.isNotBlank(itemIds)){
                        itemwrap.itemId = itemIds;
                        itemwrap.itemName = itemName;
                        itemwrap.quantity = 1;
                        if(fieldsToAdd!= null && parentBundle.TeliaSE_Product_Object_Type__c == 'OFFICE365 Offer Spec')
                        {
                            itemwrap.fieldsToUpdate = fieldsToAdd;
                        }
                        if(uniqueKeyParam!=null){
                            itemwrap.parentId = parentBundle.Product2Id + uniqueKeyParam;
                        }
                        else{
                            itemwrap.parentId = parentBundle.Product2Id;
                        }
                        //itemwrap.parentId = parentBundle.Product2Id + parentBundle.TeliaSE_MC_Binding_Time__c; //+ClusterProductCode or hierarchyPath or parent's parentId(like kluster productId) maybe for special addons & sc standard;c
                        itemwrapList.add(itemwrap);
                        singlewrap.noResponseNeeded = true;
                        singlewrap.items = itemwrapList; 
                        singlewrap.cartId =cartId;
                        singlewrap.parentName =parentBundle.Product2.Name;
                        singlewrap.validate = false;
                        singlewrap.price = priceFlag;
                        wrapList.add(singlewrap);    
                    }
                }
            }
        }
        //System.debug('wrapList__'+wrapList);
        return wrapList;
    }
    */
    //Method for each level request to add parent QLI details, will be input for IP for looping the products   
    private static void updateAddToCartRequestList(Map<String,Object> inputMap, Map<String,Object> outMap){
        //LTAART-328: Commented this Method as we are now using Simplified Line Items only to create the Offer Document
        /*
        String offerQuoteId = (String)inputMap.get('OfferQuoteId');
        List<Object> addToCartProductList = (List<Object>)inputMap.get('requestProductList');
        List<Object> updatedAddToCartProductList = addParentRecordDetails(offerQuoteId, addToCartProductList);
        outMap.put('addToCartProductList',updatedAddToCartProductList);
        outMap.put('addToCartProductListSize',updatedAddToCartProductList.size());
*/    
}
    /*
    //method to update the inserted parent QLI details in request map to enable child products addition under the parent
    private static List<Object> addParentRecordDetails(String quoteId, List<Object> levelHierarchyList){
        List<Object> finalLevelHierarchyList = new List<Object>();
        Set<Id> pbeSet = new Set<Id>();
        //Added for NMP3
        Map<String,MC_OfferCreation_ObjSplit__c> objTypes = MC_OfferCreation_ObjSplit__c.getAll();
        List<QuoteLineItem> qtlList = [SELECT id,quoteid,
                                       vlocity_cmt__parentitemid__c,TeliaSE_MC_Binding_Time__c,product2id,vlocity_cmt__product2id__r.name, 
                                       vlocity_cmt__ProductHierarchyPath__c,PricebookEntryId,TeliaSE_Product_Object_Type__c,TeliaSE_ParentClusterCode__c  
                                       FROM QuoteLineItem
                                       WHERE QuoteId =: quoteId];
        //System.debug('qtlList__'+qtlList.size());
        Map<String,QuoteLineItem> productQLIMap = new Map<String,QuoteLineItem>();
        for(QuoteLineItem qtl:qtlList){
            Boolean isSpecialScenario = objTypes.containskey(qtl.TeliaSE_Product_Object_Type__c);
            String uniqueKeyParam = isSpecialScenario? (String)qtl.get(objTypes.get(qtl.TeliaSE_Product_Object_Type__c).fieldsToAdd__c) : null;
          pbeSet.add(qtl.PricebookEntryId);
            //productQLIMap.put(qtl.Product2Id,qtl);
            if(uniqueKeyParam!=null){
                productQLIMap.put(qtl.Product2Id+uniqueKeyParam,qtl);
            }
            else{
                productQLIMap.put(qtl.Product2Id,qtl);
            }
            //productQLIMap.put(qtl.Product2Id+qtl.TeliaSE_MC_Binding_Time__c,qtl); //Added for Office 365
        }
        
        List<ItemsWrap> itemwrapList;
        ////System.debug('productQLIMap__'+productQLIMap);
        for(Object rawLevelMap:levelHierarchyList){
            ////System.debug('rawLevelMap__'+rawLevelMap);
            List<String> finalItemIdList = new List<String>();
            ParentRecordWrap pwrap = new ParentRecordWrap();
            List<RecordsWrap> rslist = new List<RecordsWrap>();
            RecordsWrap rs = new RecordsWrap();
            Map<String, Object> levelMap = (Map<String, Object>)rawLevelMap;
            ////System.debug('items'+levelMap.get('items'));
            List<Object> itemsList = (List<Object>)levelMap.get('items');
            Map<String,Object> itemMap = (Map<String,Object>)itemsList[0];
            String itemParentId =(String)itemMap.get('parentId');
            String itemIds = (String)itemMap.get('itemId');
            List<String> itemIdsList = itemIds.split(',');
            String finalItemIdString;
            
            //check and remove any item that has already been added due to default cardinalities like Jobbsurf BAS
            for(String itemId:itemIdsList){
                //if(!productExistsInCart(quoteId,itemId,itemParentId)){ //send(itemId,qtParentId,parenthierarchypath or clusterCode) for NMP
                if(!pbeSet.contains(itemId)){
                  finalItemIdString = (finalItemIdString == null? itemId: finalItemIdString+','+itemId);
                }
            }
            //System.debug('finalItemIdString_'+finalItemIdString); 
            if(String.isNotblank(finalItemIdString)){
                 itemMap.put('itemId',finalItemIdString);
                //updating parentQLI Id and hierarchy path
                if(productQLIMap.containsKey(itemParentId)){
                    itemMap.put('parentId',productQLIMap.get(itemParentId).Id);
                    rs.Id = productQLIMap.get(itemParentId).Id;
                    rs.productHierarchyPath = (productQLIMap.get(itemParentId)).vlocity_cmt__ProductHierarchyPath__c;
                    rs.parentHierarchyPath = (productQLIMap.get(itemParentId)).vlocity_cmt__ProductHierarchyPath__c;
                    rslist.add(rs);
                    pwrap.records = rslist;
                }
                itemMap.put('parentRecord',JSON.deserializeUntyped(JSON.serialize(pwrap)));  
                finalLevelHierarchyList.add(rawLevelMap);
           }                
        }
        return finalLevelHierarchyList;
    }

  //method to check if the product has already been added to the cart     
    private static Boolean productExistsInCart(String quoteId, String priceBookEntryId, String parentId) {
        Boolean isProdAlreadyadded = false;
        List<QuoteLineItem> qliList = [select id//,PricebookEntryId,  vlocity_cmt__ParentItemId__c, vlocity_cmt__ProductHierarchyPath__c,Product2.Name
                                       from QuoteLineItem
                                       where QuoteId =:quoteId 
                                       and PriceBookEntryId =:priceBookEntryId];
        //and vlocity_cmt__ParentItemId__c =:parentId and vlocity_cmt__ProductHierarchyPath__c =:hPath - for NMP & SC   
        if(qliList.size()>0){
            isProdAlreadyadded = true;
        } 
        return isProdAlreadyadded;
    }
    
    //wrapper classes for building CPQ API request structure
    private class SingleCartRequestWrapper {
        public String cartId {get; set;}        
        public String parentName {get; set;}
        public List<ItemsWrap> items{get;set;}
        public Boolean validate{get;set;}
        public Boolean price{get;set;}
        public Boolean noResponseNeeded{get;set;}
    }
    
    private class ParentRecordWrap {
        public List<RecordsWrap> records{get; set;}
    }
    
    private class ItemsWrap {
        public String itemName {get; set;}
        public String itemId{get; set;}
        public String parentId {get; set;}
        public Integer quantity {get; set;}
        public Map<String,Object> fieldsToUpdate {get; set;}
        public ParentRecordWrap parentRecord{get; set;}
    }
    
    private class RecordsWrap {
        public String Id{get; set;}
        public String productHierarchyPath{get; set;}
        public String parentHierarchyPath{get; set;}
    }
*/
}