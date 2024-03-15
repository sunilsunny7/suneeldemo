global without sharing class TeliaSE_SingleCart_OfferCreation implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try
        {
            if (methodName.equals('createSingleCartOffer'))
            {
                createSingleCartOffer(inputMap,outMap);
            }
            else if (methodName.equals('createSecondLevelProduct'))
            {
                createSecondLevelProduct(inputMap,outMap);
            }
            else if (methodName.equals('createThirdLevelProduct'))
            {
                createThirdLevelProduct(inputMap,outMap);
            }
            else if (methodName.equals('createFourthLevelProduct'))
            {
                createFourthLevelProduct(inputMap,outMap);
            }
            else if (methodName.equals('createFifthLevelProduct'))
            {
                createFifthLevelProduct(inputMap,outMap);
            }
            
            else 
            {
                result = false;
            }
            return result;              
        } 
        catch(Exception e){
            System.debug('Exception : '+e.getStackTraceString());
            return false;
        }
    }
    
    
    global static void createSingleCartOffer(Map<String,Object> inputMap, Map<String,Object> outMap){
        
        String quoteId = (String)inputMap.get('ContextId');
        String oppId;
        String accId;
        Map<String, Object> offMap = ( Map<String, Object>)inputMap.get('SV_SetOfferQuoteId');
        String offQt = (String)offMap.get('OfferQuoteId');
        //String offQt = (String)inputMap.get('OfferQuoteId');//(String)offMap.get('OfferQuoteId');        
        List<QuoteLineItem> qliList = [select id, QuoteId,Quote.OpportunityId,TeliaSE_Offer_Type__c, vlocity_cmt__ParentItemId__c, Quote.AccountId, Product2Id,TeliaSE_MC_FACallOffQuantity__c, 
                                       PricebookEntry.Name, PricebookEntryId, PricebookEntry.Pricebook2Id,TeliaSE_Product_Object_Type__c,
                                       Product2.Name, Product2.ProductCode, vlocity_cmt__ProductHierarchyPath__c from QuoteLineItem where QuoteId =:quoteId 
                                       AND TeliaSE_MC_FACallOffQuantity__c != null AND TeliaSE_MC_FACallOffQuantity__c >= 0];
        
        //Lists and maps to hold the different levels of products and other relevent information.
        List<Map<String, String>> firstLevelProdList    = new List<Map<String, String>>();
        List<Map<String, String>> secondLevelProdList   = new List<Map<String, String>>();
        List<Map<String, String>> thirdLevelProdList    = new List<Map<String, String>>();
        List<Map<String, String>> rootLevelProdList     = new List<Map<String, String>>();
        List<Map<String, String>> fourthLevelProdList   = new List<Map<String, String>>();
        List<Map<String, String>> fifthLevelProdList    = new List<Map<String, String>>();
        
        Set<String> firstLevelProdSet   = new Set<String>();
        Set<String> secondLevelProdSet  = new Set<String>();
        Set<String> thirdLevelProdSet   = new Set<String>();
        Set<String> rootLevelProdSet    = new Set<String>();
        Set<String> fourthLevelProdSet  = new Set<String>();
        Set<String> fifthLevelProdSet   = new Set<String>();
        
        Map<String, String> firstLevelHierachyMap   = new Map<String, String>();
        Map<String, String> secondLevelHierachyMap  = new Map<String, String>();
        Map<String, String> thirdLevelHierachyMap   = new Map<String, String>();
        Map<String, String> rootLevelHierachyMap    = new Map<String, String>();
        Map<String, String> fourthLevelHierachyMap  = new Map<String, String>();
        Map<String, String> fifthLevelHierachyMap   = new Map<String, String>();
       
        //Need differnet sets to store the PT products, PT products will have more level in product hierarchy, upto 6 levels.
        //Other product families have only 2 levels, for PT, we need to get all the products details from hierarchy map, hence
        //spliting the products and adding it in different sets, it will be merged with actual list at the end.
        // '01t1p0000081yNIAAY<01t1p0000081yMcAAI<01t1p0000081yMVAAY<01t1p0000082hnxAAA<01t1p0000082hnsAAA'
        Set<String> firstLevelProdSetPT     = new Set<String>();
        Set<String> secondLevelProdSetPT    = new Set<String>();
        Set<String> thirdLevelProdSetPT     = new Set<String>();
        Set<String> rootLevelProdSetPT      = new Set<String>();
        Set<String> fourthLevelProdSetPT    = new Set<String>();
        Set<String> fifthLevelProdSetPT     = new Set<String>();
        
        
        Integer hpathSize = 0;
        String prodIdToBeAdded;
        Map<String, String> firstLevelIdMap = new Map<String, String>();

        //Loop over the QLI and add the products to respestive lists.
        for(QuoteLineItem qli : qliList){
            oppId = qli.Quote.OpportunityId;
            accId = qli.Quote.AccountId;
            
            //from the hierarchy path, based on '<' sign, split the products
            hpathSize = qli.vlocity_cmt__ProductHierarchyPath__c.split('<').size();
            
            //Since PT has 5 levels of child product and virtual products are dynamic, split the products and add it to respective sets.
            //Also, this requires to be added from root level, unlike other mobile products. 
            if(qli.TeliaSE_Product_Object_Type__c == 'Personal Technician Offer Specification' || qli.TeliaSE_Product_Object_Type__c =='Insurance Offer Spec') {
                String[] ptProducts = qli.vlocity_cmt__ProductHierarchyPath__c.split('<',6);
                for(Integer i=0; i < ptProducts.size(); i++) {
                    prodIdToBeAdded = ptProducts[i];
                    if(i==0) { 
                        firstLevelProdSet.add(prodIdToBeAdded); 
                        firstLevelIdMap.put(qli.Product2Id, qli.PricebookEntryId);
                    }
                    if(i==1) secondLevelProdSetPT.add(prodIdToBeAdded);
                    if(i==2) thirdLevelProdSetPT.add(prodIdToBeAdded);
                    if(i==3) fourthLevelProdSetPT.add(prodIdToBeAdded);
                    if(i==4) fifthLevelProdSetPT.add(prodIdToBeAdded);
                }
            }
            //For hardware products, only 2 levels and the virtual products needs to be exclued. Also, the root and 2nd level product needs
            //considerd to be in the cart.
                else if(qli.TeliaSE_Product_Object_Type__c == 'Mobile Handset Product Specification' || qli.TeliaSE_Product_Object_Type__c == 'Mobile Accessory Product Specification' ) {
                    
                    String[] ptProducts = qli.vlocity_cmt__ProductHierarchyPath__c.split('<',6);
                    for(Integer i=0; i < ptProducts.size(); i++) {
                        prodIdToBeAdded = ptProducts[i];
                        if(i==0) { 
                            firstLevelProdSet.add(prodIdToBeAdded); 
                            firstLevelIdMap.put(qli.Product2Id, qli.PricebookEntryId);
                        }
                        else if(i==1 && ptProducts.size() == 2) secondLevelProdSet.add(prodIdToBeAdded);
                        else if(i==2 && ptProducts.size() == 3) secondLevelProdSet.add(prodIdToBeAdded);
                    }
                } 


                else if(qli.TeliaSE_Product_Object_Type__c =='Hardware Offer Spec') {
                    
                    String[] ptProducts = qli.vlocity_cmt__ProductHierarchyPath__c.split('<',6);
                    for(Integer i=0; i < ptProducts.size(); i++) {
                        prodIdToBeAdded = ptProducts[i];
                        if(i==0 && ptProducts.size() == 1) { 
                            firstLevelProdSet.add(prodIdToBeAdded); 
                            firstLevelIdMap.put(qli.Product2Id, qli.PricebookEntryId);
                        }
                        else if(i==1 && ptProducts.size() == 2) {                            
                            firstLevelProdSet.add(prodIdToBeAdded); 
                            //firstLevelIdMap.put(qli.Product2Id, qli.PricebookEntryId);
						}
                    }
                }             
            else {
                if(hpathSize == 1){
                    prodIdToBeAdded = qli.vlocity_cmt__ProductHierarchyPath__c;
                    rootLevelProdSet.add(qli.Product2Id);
                    rootLevelHierachyMap    = new Map<String, String>();
                    rootLevelHierachyMap = addValuesToMap(qli,rootLevelHierachyMap, prodIdToBeAdded);                    
                    rootLevelProdList.add(rootLevelHierachyMap);
                }
                
                else if(hpathSize == 2){
                    prodIdToBeAdded = qli.vlocity_cmt__ProductHierarchyPath__c.split('<')[hpathSize-1];
                    firstLevelProdSet.add(qli.Product2Id);
                    firstLevelIdMap.put(qli.Product2Id, qli.PricebookEntryId);
                    firstLevelHierachyMap   = new Map<String, String>();
                    firstLevelHierachyMap = addValuesToMap(qli,firstLevelHierachyMap, prodIdToBeAdded);                    
                    firstLevelProdList.add(firstLevelHierachyMap);
                }
                
                else if(hpathSize == 3){
                    prodIdToBeAdded = qli.vlocity_cmt__ProductHierarchyPath__c.split('<')[hpathSize-1];
                    firstLevelProdSet.add(qli.vlocity_cmt__ProductHierarchyPath__c.split('<')[hpathSize-2]);
                    firstLevelIdMap.put(qli.Product2Id, qli.PricebookEntryId);
                    secondLevelProdSet.add(qli.PricebookEntryId);
                    secondLevelHierachyMap  = new Map<String, String>();
                    secondLevelHierachyMap = addValuesToMap(qli,secondLevelHierachyMap, prodIdToBeAdded);                    
                    secondLevelProdList.add(secondLevelHierachyMap);
                }
                
                else if(hpathSize == 4){
                    //For Jobbsurf products, 2 levels of virtual products available in product hierarchy
                    //'parentProdt<virtualPrd1<VirtualProd2<ActualProd'
                   /* if(qli.Product2.Name.contains('Jobbsurf')) {
                        prodIdToBeAdded = qli.vlocity_cmt__ProductHierarchyPath__c.split('<')[hpathSize-3];
                        firstLevelProdSet.add(prodIdToBeAdded);
                        firstLevelIdMap.put(qli.Product2Id, qli.PricebookEntryId);
                    } */

                    prodIdToBeAdded = qli.vlocity_cmt__ProductHierarchyPath__c.split('<')[hpathSize-1];
                    thirdLevelProdSet.add(qli.PricebookEntryId);
                    thirdLevelHierachyMap   = new Map<String, String>();
                    thirdLevelHierachyMap = addValuesToMap(qli,thirdLevelHierachyMap, prodIdToBeAdded);                    
                    thirdLevelProdList.add(thirdLevelHierachyMap);
                }
            }
        }

        //Only very few products need to be added at root level, such as PT standalone product, those will be combined and added to cart.
        if(rootLevelProdSet.size() >0) firstLevelProdSet.addAll(rootLevelProdSet);
        
        //Extrct the pricebook entry
        List<PricebookEntry> pricebookListIds = [select id, Product2Id from PricebookEntry where Product2Id in:firstLevelProdSet and  
                                                 Pricebook2.Name = 'Standard Price Book'];
        for(PricebookEntry pbe:pricebookListIds) {
            firstLevelIdMap.put(pbe.Product2Id, pbe.Id);
        }

        SingleCartListWrapper wrapList = new SingleCartListWrapper();
        List<SingleCartRequestWrapper> singleWrapList = new List<SingleCartRequestWrapper>();
        SingleCartRequestWrapper singlewrap;
        List<ItemsWrap> itemwrapList;
        List<inputFieldsWrap> inputWrapList;
        
        ItemsWrap itemwrap;
        inputFieldsWrap inputWrap;
        
        //Build the wrapper for CPQ API call.
        try{
            Integer flvlCount = 0;
            for(String idVal:firstLevelProdSet) {
                singlewrap = new SingleCartRequestWrapper();
                itemwrapList = new List<ItemsWrap>();
                inputWrapList = new List<inputFieldsWrap>();
                itemwrap = new ItemsWrap();
                inputWrap = new inputFieldsWrap();
                if(firstLevelHierachyMap.get(idVal+'CallOffQty') != null){
                    itemwrap.quantity = Integer.valueOf(firstLevelHierachyMap.get(idVal+'CallOffQty'));
                }else{
                    itemwrap.quantity = 1; 
                }

                itemwrap.itemId = firstLevelIdMap.get(idVal);
                itemwrapList.add(itemwrap);
                inputWrapList.add(inputWrap);
                singlewrap.items = itemwrapList; 
                singlewrap.inputFields = inputWrapList;
                singlewrap.methodName = 'postCartsItems';
                singlewrap.cartId =offQt;
                singlewrap.validate = false;
                singlewrap.price = true;
                singleWrapList.add(singlewrap);
            }
            
            String s = JSON.serialize(singleWrapList);
            outMap.put('singleWrapList',singleWrapList);

            //For PT products, the product related details such as pricebook entry and other required parameters, this will not come in the
            //initial quiery as the next level of product infromation will not available. In case if its virtual product, there will not be 
            //any QLI returned.
            if(secondLevelProdSetPT.size() > 0){
                List<QuoteLineItem> ptQLIlist = addPTProductsToMap(secondLevelProdSetPT, QuoteId);
                for(QuoteLineItem ptQli:ptQLIlist) {
                    prodIdToBeAdded = ptQli.Product2Id;
                    secondLevelProdSet.add(ptQli.PricebookEntryId);
                    secondLevelHierachyMap  = new Map<String, String>();
                    secondLevelHierachyMap = addValuesToMap(ptQli,secondLevelHierachyMap, prodIdToBeAdded);                    
                    secondLevelProdList.add(secondLevelHierachyMap);
                }
            }

            if(thirdLevelProdSetPT.size() > 0){
                List<QuoteLineItem> ptQLIlist = addPTProductsToMap(thirdLevelProdSetPT, QuoteId);
                for(QuoteLineItem ptQli:ptQLIlist) {
                    prodIdToBeAdded = ptQli.Product2Id;
                    thirdLevelProdSet.add(ptQli.PricebookEntryId);
                    thirdLevelHierachyMap   = new Map<String, String>();
                    thirdLevelHierachyMap = addValuesToMap(ptQli,thirdLevelHierachyMap, prodIdToBeAdded);                    
                    thirdLevelProdList.add(thirdLevelHierachyMap);
                }
            }            
            
            if(fourthLevelProdSetPT.size() >0 ){
                List<QuoteLineItem> ptQLIlist = addPTProductsToMap(fourthLevelProdSetPT, QuoteId);
                for(QuoteLineItem ptQli:ptQLIlist) {
                    prodIdToBeAdded = ptQli.Product2Id;
                    fourthLevelProdSet.add(ptQli.PricebookEntryId);
                    fourthLevelHierachyMap  = new Map<String, String>();
                    fourthLevelHierachyMap = addValuesToMap(ptQli,fourthLevelHierachyMap, prodIdToBeAdded);                    
                    fourthLevelProdList.add(fourthLevelHierachyMap);
                }
            }            
            
            if(fifthLevelProdSetPT.size() >0 ){
                List<QuoteLineItem> ptQLIlist = addPTProductsToMap(fifthLevelProdSetPT, QuoteId);
                for(QuoteLineItem ptQli:ptQLIlist) {
                    prodIdToBeAdded = ptQli.Product2Id;
                    fifthLevelProdSet.add(ptQli.PricebookEntryId);
                    fifthLevelHierachyMap   = new Map<String, String>();
                    fifthLevelHierachyMap = addValuesToMap(ptQli,fifthLevelHierachyMap, prodIdToBeAdded);                    
                    fifthLevelProdList.add(fifthLevelHierachyMap);
                }
            }            

            //Set all the values in out map for future looping
            outMap.put('secondLevelProdSet',secondLevelProdSet);
            outMap.put('secondLevelProdList',secondLevelProdList);
            outMap.put('thirdLevelProdSet',thirdLevelProdSet);
            outMap.put('thirdLevelProdList',thirdLevelProdList);
            outMap.put('fourthLevelProdSet',fourthLevelProdSet);
            outMap.put('fourthLevelProdList',fourthLevelProdList);
            outMap.put('fifthLevelProdSet',fifthLevelProdSet);
            outMap.put('fifthLevelProdList',fifthLevelProdList);
        }
        catch(Exception e){
            System.debug('e-->'+e);
        }
    }
    
    private static void createSecondLevelProduct(Map<String,Object> inputMap, Map<String,Object> outMap){
        String quoteId = (String)inputMap.get('OfferQuoteId');
        String idValue;
        String hierarchyVal;
        String parentId;
        String parentProdId;
        String prodId;
        String parentHieracrchyPath;    
        String prodPriceEntry;
        
        //This query identified the parent product, these infromation available only after the CPQ API creates the cart and add the 
        //first level or parent products. 
        List<QuoteLineItem> qtlList = [SELECT id,quoteid,TeliaSE_Product_Object_Type__c, vlocity_cmt__parentitemid__c,product2id,vlocity_cmt__product2id__r.name 
                                       FROM QuoteLineItem WHERE QuoteId =: quoteId AND vlocity_cmt__ParentItemId__c = null];
        List<Object> secondLevelHierarchyList = (List<Object>)inputMap.get('secondLevelProdList');
        List<SingleCartRequestWrapper> secondLevelProducts = new List<SingleCartRequestWrapper>();
        SingleCartRequestWrapper singlewrap;
        List<RecordsWrap> rslist;
        ParentRecordWrap pwrap;
        List<ItemsWrap> itemwrapList;
        ItemsWrap itemwrap;
        RecordsWrap rs;
        Map<String, Object> parentMap1;
        Map<String, Object> secLevelMap;
        String qtParentId;
        String newHrchy;

        for(Object secLevelMap1:secondLevelHierarchyList){
            //for(Object secLevelMap1:ms1){
            secLevelMap = (Map<String, Object>)secLevelMap1;
            prodId = (String)secLevelMap.get('prodIdToBeAdded');
            prodPriceEntry = (String)secLevelMap.get('priceBookEntryIdToBeAdded');
            hierarchyVal = (String)secLevelMap.get('productHierarchyPath');            
            for(QuoteLineItem qtl:qtlList){
                qtParentId = qtl.product2id;
                newHrchy = qtParentId+'<'+prodId;
                //if(hierarchyVal.endsWith('<'+prodId) && hierarchyVal.startsWith(newHrchy)){
                //For 2 level products, 'ParentProd<ChildProdt', verify if it the hierarchy map is matching, and the matching ID is parent QLI Id.
                if(hierarchyVal.contains(newHrchy) || (hierarchyVal.contains(qtParentId) && hierarchyVal.contains(prodId))){
                    singlewrap = new SingleCartRequestWrapper();
                    itemwrapList = new List<ItemsWrap>();
                    pwrap = new ParentRecordWrap();                    
                    itemwrap = new ItemsWrap();
                    rslist = new List<RecordsWrap>();
                    rs = new RecordsWrap();
                    //For Hardware, we need to exclude the actual product and add the virtual product in hierarchy path.
                    if(qtl.TeliaSE_Product_Object_Type__c =='Hardware Offer Spec' ||qtl.TeliaSE_Product_Object_Type__c == 'Mobile Handset Product Specification' || qtl.TeliaSE_Product_Object_Type__c == 'Mobile Accessory Product Specification' ) {
                        if(hierarchyVal.split('<').size() == 3)
                            rs.productHierarchyPath =hierarchyVal.split('<')[hierarchyVal.split('<').size()-3]+'<'+hierarchyVal.split('<')[hierarchyVal.split('<').size()-2] ;
                        rs.parentHierarchyPath = hierarchyVal.split('<')[hierarchyVal.split('<').size()-3]+'<'+hierarchyVal.split('<')[hierarchyVal.split('<').size()-2] ;

                    } /*else if(qtl.TeliaSE_Product_Object_Type__c == 'Personal Technician Offer Specification') {
                        rs.productHierarchyPath = qtParentId;
                        rs.parentHierarchyPath = qtParentId;
                    }*/
                    else {
                        rs.productHierarchyPath = qtParentId;
                        rs.parentHierarchyPath = qtParentId;
                    }
                    rslist.add(rs);
                    pwrap.records = rslist;
                    itemwrap.itemId = prodPriceEntry;
                    singlewrap.items = itemwrapList;  
                    singlewrap.methodName = 'postCartsItems';
                    singlewrap.cartId =quoteId;
                    singlewrap.validate = false;
                    singlewrap.price = true;
                    if(secLevelMap.get(prodId+'CallOffQty') != null){
                    	itemwrap.quantity = Integer.valueOf(secLevelMap.get(prodId+'CallOffQty'));
                	}else{
                    	itemwrap.quantity = 1; 
                	}
                    itemwrap.parentRecord = pwrap;
                    itemwrap.parentId = qtl.Id;
                    itemwrapList.add(itemwrap);
                    if(!checkProductAvailabilityInCart(quoteId, hierarchyVal, prodId, qtl.Id)) secondLevelProducts.add(singlewrap);
                    qtParentId ='';
                    parentProdId='';
                    break;
                }
            }
        }
        outMap.put('secondLevelProducts',secondLevelProducts);
    }
    
    //Method for 3rd level wrapper build for CPQ API request, will be input for IP for looping the products.
    private static void createThirdLevelProduct(Map<String,Object> inputMap, Map<String,Object> outMap){
        String quoteId = (String)inputMap.get('OfferQuoteId');
        List<Object> thirdLevelHierarchyList = (List<Object>)inputMap.get('thirdLevelProdList');
        List<SingleCartRequestWrapper> thirdLevelProducts = buildLevelProducts(quoteId, thirdLevelHierarchyList);
        outMap.put('thirdLevelProducts',thirdLevelProducts);
    }
    
    //Method for 4th level wrapper build for CPQ API request, will be input for IP for looping the products.
    private static void createFourthLevelProduct(Map<String,Object> inputMap, Map<String,Object> outMap){
        String quoteId = (String)inputMap.get('OfferQuoteId');
        List<Object> fourthLevelHierarchyList = (List<Object>)inputMap.get('fourthLevelProdList');
        List<SingleCartRequestWrapper> fourthLevelProducts = buildLevelProducts(quoteId, fourthLevelHierarchyList);
        outMap.put('fourthLevelProducts',fourthLevelProducts);
    }

    //Method for 5th level wrapper build for CPQ API request, will be input for IP for looping the products.
    private static void createFifthLevelProduct(Map<String,Object> inputMap, Map<String,Object> outMap){
        String quoteId = (String)inputMap.get('OfferQuoteId');
        List<Object> fifthLevelHierarchyList = (List<Object>)inputMap.get('fifthLevelProdList');
        List<SingleCartRequestWrapper> fifthLevelProducts = buildLevelProducts(quoteId, fifthLevelHierarchyList);
        outMap.put('fifthLevelProducts',fifthLevelProducts);
    }
    
    
    public static List<QuoteLineItem> addPTProductsToMap(Set<String> productIdsSet, String qtId){
        List<QuoteLineItem> ptQLIlist = [select QuoteId,Quote.OpportunityId,TeliaSE_Offer_Type__c, vlocity_cmt__ParentItemId__c, Quote.AccountId, Product2Id,TeliaSE_MC_FACallOffQuantity__c, 
                                         PricebookEntry.Name, PricebookEntryId, PricebookEntry.Pricebook2Id,TeliaSE_Product_Object_Type__c,
                                         Product2.Name, Product2.ProductCode,  vlocity_cmt__ProductHierarchyPath__c from QuoteLineItem where Product2Id in:productIdsSet
                                         and QuoteId =: qtId];
        return ptQLIlist;
    }
    
    //Add values to Maps from QLI
    public static Map<String, String> addValuesToMap(QuoteLineItem qli, Map<String, String> mapToUpdate, String prodIdToBeAdded){
        mapToUpdate.put('prodIdToBeAdded', prodIdToBeAdded);
        mapToUpdate.put('priceBookEntryIdToBeAdded', qli.PricebookEntryId);
        if(qli.TeliaSE_MC_FACallOffQuantity__c == 0)
        {
            mapToUpdate.put(prodIdToBeAdded+'CallOffQty', String.valueOf(1));
        }
        else
        {
            mapToUpdate.put(prodIdToBeAdded+'CallOffQty', String.valueOf(qli.TeliaSE_MC_FACallOffQuantity__c));
        }
        

        if(qli.Product2.ProductCode.contains('MOB_SURF_') && qli.vlocity_cmt__ProductHierarchyPath__c != null) {
            mapToUpdate.put('productHierarchyPath', qli.vlocity_cmt__ProductHierarchyPath__c.substringAfter('<'));
            mapToUpdate.put(qli.PricebookEntryId, qli.vlocity_cmt__ProductHierarchyPath__c.substringAfter('<'));

        } else {
        	mapToUpdate.put('productHierarchyPath', qli.vlocity_cmt__ProductHierarchyPath__c);    
        	mapToUpdate.put(qli.PricebookEntryId, qli.vlocity_cmt__ProductHierarchyPath__c);
		}
        
        mapToUpdate.put('productName', qli.Product2.Name);
        if(qli.TeliaSE_MC_FACallOffQuantity__c != null) 
        {
            if(qli.TeliaSE_MC_FACallOffQuantity__c == 0)
            {
                mapToUpdate.put('Quantity',  String.valueOf(1));
            }
            else
            {
                mapToUpdate.put('Quantity',  String.valueOf(qli.TeliaSE_MC_FACallOffQuantity__c));
            }
        }
        return mapToUpdate;
    }
    
    //Method to build the CPQ API wrapper for more than 2 level products.
    public static List<SingleCartRequestWrapper> buildLevelProducts(String quoteId, List<Object> levelHierarchyList) {
        String hierarchyVal;
        String parentId;
        String parentProdId;
        String prodId;
        String parentHieracrchyPath;    
        String prodPriceEntry;
        
        List<QuoteLineItem> qtlList = [SELECT id,quoteid,vlocity_cmt__parentitemid__c,product2id,vlocity_cmt__product2id__r.name, 
                                       vlocity_cmt__ProductHierarchyPath__c  FROM QuoteLineItem WHERE QuoteId =: quoteId];
        
        List<SingleCartRequestWrapper> levelProducts = new List<SingleCartRequestWrapper>();
        SingleCartRequestWrapper singlewrap; 
        List<RecordsWrap> rslist;
        ParentRecordWrap pwrap;
        List<ItemsWrap> itemwrapList;
        ItemsWrap itemwrap;
        RecordsWrap rs;
        Map<String, Object> levelMap;
        String qtParentId;
        String newHrchy;
        
        for(Object rawLevelMap:levelHierarchyList){
            levelMap = (Map<String, Object>)rawLevelMap;
            prodId = (String)levelMap.get('prodIdToBeAdded');
            prodPriceEntry = (String)levelMap.get('priceBookEntryIdToBeAdded');
            hierarchyVal = (String)levelMap.get('productHierarchyPath');
            String quantityCallOff = (String)levelMap.get(prodId+'CallOffQty');
            
            for(QuoteLineItem qtl:qtlList){
                //qtParentId = qtl.product2id;
                newHrchy = qtl.vlocity_cmt__ProductHierarchyPath__c;
                if(hierarchyVal.endsWith('<'+prodId) && hierarchyVal.startsWith(newHrchy)){
                    singlewrap = new SingleCartRequestWrapper();
                    itemwrapList = new List<ItemsWrap>();
                    pwrap = new ParentRecordWrap();                    
                    itemwrap = new ItemsWrap();
                    rslist = new List<RecordsWrap>();
                    rs = new RecordsWrap();

                    //Remove the actual product ID from hierarchy path
                    rs.productHierarchyPath = hierarchyVal.remove('<'+prodId);
                    rs.parentHierarchyPath = hierarchyVal.remove('<'+prodId);
                    rslist.add(rs);
                    pwrap.records = rslist;
                    itemwrap.itemId = prodPriceEntry;
                    singlewrap.items = itemwrapList;  
                    singlewrap.methodName = 'postCartsItems';
                    singlewrap.cartId =quoteId;
                    singlewrap.validate = false;
                    singlewrap.price = true;
                    if(quantityCallOff != null){
                    	itemwrap.quantity = Integer.valueOf(quantityCallOff);
                	}else{
                    	itemwrap.quantity = 1; 
                	}
                    itemwrap.parentRecord = pwrap;
                    itemwrap.parentId = qtl.Id;
                    
                    if(!checkProductAvailabilityInCart(quoteId, hierarchyVal, prodId, qtl.Id)) { 
                        itemwrapList.add(itemwrap);
                        levelProducts.add(singlewrap);
                    }
                    qtParentId =null;
                    break;
                }
            }
        }
        return levelProducts;
    }
 
    private static Boolean checkProductAvailabilityInCart(String quoteId, String hPath, String prodId, String parentId) {
        Boolean isProdAlreadyadded = false;
		List<QuoteLineItem> qliList = [select id, PricebookEntryId,  vlocity_cmt__ParentItemId__c, vlocity_cmt__ProductHierarchyPath__c, 
                                       Product2.Name from QuoteLineItem where QuoteId =:quoteId and vlocity_cmt__ProductHierarchyPath__c =:hPath 
                                       and Product2Id =:prodId  and vlocity_cmt__ParentItemId__c =:parentId];        
        if(qliList.size() > 0 ) isProdAlreadyadded = true;
        
        return isProdAlreadyadded;
    }
    
    
    
    //Wrapper classes for building CPQ API requests.
    
    public class SingleCartRequestWrapper {
        public String methodName {get; set;}
        public String cartId {get; set;}
        public List<ItemsWrap> items{get;set;}
        public List<inputFieldsWrap> inputFields{get;set;}
        public Boolean validate{get;set;}
        public Boolean price{get;set;}
    }
    
    public class SingleCartListWrapper {
        public String methodName {get; set;}
        public String cartId {get; set;}
        public List<SingleCartRequestWrapper> itemsList{get;set;}
        public Boolean validate{get;set;}
        public Boolean price{get;set;}
    }
    
    public class ParentRecordWrap {
        public List<RecordsWrap> records{get; set;}
    }
    
    public class ItemsWrap {
        public String itemId{get; set;}
        public String parentId{get; set;}
        public Integer quantity{get; set;}
        public ParentRecordWrap parentRecord{get; set;}
    }
    public class inputFieldsWrap{
        public String ecurringCalculatedPrice{get; set;}
        public String oneTimeCalculatedPrice{get; set;}
        public String TeliaSE_MC_FACallOffQuantity{get; set;}
    }
    
    public class RecordsWrap {
        public String productHierarchyPath{get; set;}
        public String parentHierarchyPath{get; set;}
    }    
}