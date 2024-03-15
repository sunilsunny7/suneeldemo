global class SingleCart_QuoteBackup1 implements vlocity_cmt.VlocityOpenInterface2{   
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('level1')) {
                SingleCart_QuoteBackup1.createBackupQuote(inputMap,outMap);
            }
            if(methodName.equalsIgnoreCase('level2')) {
                SingleCart_QuoteBackup1.addlevel(inputMap,outMap);
            }
            if(methodName.equalsIgnoreCase('addon')) {
                SingleCart_QuoteBackup1.addOnBundle(inputMap,outMap);
            }
            if(methodName.equalsIgnoreCase('updateFields')) {
                SingleCart_QuoteBackup1.updateFields(inputMap,outMap);
            }
            if(methodName.equalsIgnoreCase('revertQuote')) {
                revertOriginalQuote(inputMap,outMap);
            }
            else {
                result = false;
            }            
        } catch(Exception e) {  
            outMap.put('quoteException',e);
            result = false;
            
        }        
        return result;
    }
    
    //Create backup quotes
    global static void createBackupQuote(Map<String,Object> inputMap, Map<String,Object> outMap){
        try {
            String quoteId = String.valueOf(inputMap.get('ContextId'));
            Boolean status = Approval.isLocked(quoteId);
            outMap.put('isLocked', status); //checking Locked status
            String query=queryBuilder('Quote');
            query += ' FROM Quote WHERE '+'id=\'' + String.escapeSingleQuotes(quoteId)+'\'';
            List<Quote> data=  Database.query(query);
            Quote oldQuote=data.get(0);
            Quote newQuote=oldQuote.Clone(false,true);
            if(oldQuote.Status == 'Cancelled'){
                outMap.put('QuoteStatus','Cancelled');
            }
            if(oldQuote.Status != 'Cancelled'){
                newQuote.vlocity_cmt__ParentQuoteId__c = quoteId;
                newQuote.Name=oldQuote.Name+'_Backup1'; // rename the Backup Quote
                insert newQuote; // insert backup Quote
                List<QuoteLineItem> qliList= cloneBackupQuoteLines(newQuote, oldQuote); // Calling method which will return items to clone backup Quote
                insert qliList;
                deleteOldQuoteLines(quoteId); // delete the addons
                cloneQuoteLineItemFromMaster(newQuote.Id,quoteId,outMap); //get the addon bundle and send back to OS which will inserted using IP addtocart API
                outMap.put('BackupQuoteId',newQuote.Id); //sending backup QuoteId
            }
        }catch(Exception e) {  
            outMap.put('quoteLevel1Exception',e);
        } 
    }
    //Create backup quote lines
    public static List<QuoteLineItem> cloneBackupQuoteLines(Quote newQuote, Quote oldQuote){
        List<QuoteLineItem> qliList=new List<QuoteLineItem>();
        String qliQuery=queryBuilder('QuoteLineItem');
        qliQuery+=' FROM QuoteLineItem WHERE '+'quoteid=\'' + String.escapeSingleQuotes(oldQuote.Id)+'\'';
        List<QuoteLineItem> itemsData =  Database.query(qliQuery); // get items from original Quote

        For(QuoteLineItem qli:itemsData)
        {
            QuoteLineItem itemCopy = qli.clone(false,true);
            itemCopy.quoteId=newQuote.Id; // change Quote Id to backupQuoteId
            qliList.add(itemCopy);
        }
        return qliList;
    }
    //Delete Items from Original Quote
    public static void deleteOldQuoteLines(String quoteId){
        Set<String> productCode = new Set<String>(); //exception list of items from cart
        productCode.add('MOB_SURF_BAS');
        productCode.add('MOB_SURF_0.5');
        productCode.add('MOB_SURF_1');
        productCode.add('MOB_SURF_5');
        productCode.add('MOB_SURF_20');
        productCode.add('MOB_SURF_50');
        productCode.add('MOB_SURF_100');
        productCode.add('MOB_SURF_BAS_V2');
        productCode.add('MOB_SURF_1_V2');
        productCode.add('MOB_SURF_3_V2');        
        productCode.add('MOB_SURF_5_V2');
        productCode.add('MOB_SURF_15_V2');
        productCode.add('MOB_SURF_25_V2');
        productCode.add('MOB_SURF_40_V2');
        productCode.add('MOB_SURF_120_V2');
        productCode.add('PT_PLUS');
        
        List<QuoteLineItem> qliList = [select id, QuoteId, Product2Id,vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__ProductHierarchyPath__c from QuoteLineItem where QuoteId=:quoteId and vlocity_cmt__Product2Id__r.ProductCode not in: productCode];
        List<QuoteLineItem> qliToBeDeleted = new List<QuoteLineItem>();
        List<String> thirdLevelProdList = new List<String>();
        for(QuoteLineItem qli : qliList){
            if(qli.vlocity_cmt__ProductHierarchyPath__c.split('<').size() > 2){
                qliToBeDeleted.add(qli);
            }
        }
        delete qliToBeDeleted;
    }
  /**
   * Creating a request for Integration procedure which use addtocart API
  **/ 
    public static void cloneQuoteLineItemFromMaster(String newQuoteId, String oldQuote, Map<String,Object> outMap){
        List<QuoteLineItem> qlitobeAdded = new List<QuoteLineitem>();
        Set<String> productId = new Set<String>();
        Set<String> masterIds = new Set<String>();
        Set<String> rootItemId = new Set<String>();
        Map<String,String> rootItemIdMap = new Map<String,String>();
        String masterQuote;
        if(Test.isRunningTest()){
            masterQuote = String.valueof(outMap.get('mquid'));
        }
        if(!Test.isRunningTest()){
            masterQuote = System.Label.TeliaSE_Master_quote;
        }
        String query=queryBuilder('QuoteLineItem');
        query += ' FROM QuoteLineItem WHERE '+'QuoteId=\'' + String.escapeSingleQuotes(newQuoteId)+'\'';
        List<QuoteLineItem> data=  Database.query(query); //get items from BackupQuote which needs to be added to Original Quote
        Boolean insuranse = false; // flag for insurance products
        for(QuoteLineItem qli : data){
            rootItemId.add(qli.vlocity_cmt__RootItemId__c); // getting product family parent id Like allinplus, total, touchpoint
            rootItemIdMap.put(qli.Id,qli.vlocity_cmt__Product2Id__c);
            List<String> hierarchy = qli.vlocity_cmt__ProductHierarchyPath__c.split('<');
            if(qli.TeliaSE_Product_Code__c.contains('INSURANCE')){
                insuranse = true;  // Making flag true when there is a insurance product exists in cart
            }
            if(hierarchy.size() > 2){
                qlitobeAdded.add(qli); // as we see now max heirarchy size is 4 and we are getting product with heirarchy size greater than 2
                productId.add(hierarchy[hierarchy.size()-1]);
            }    
        }
        set<String> parentRootId = new Set<String>();
        for(String s : rootItemId){
            parentRootId.add(rootItemIdMap.get(s)); // setting parent root ID from map to avoid duplicates
        }
        Set<String> masterRootId = new Set<String>();
        Map<String,String> productHierarchy = new Map<String,String>();
        Map<String,String> productitemid = new Map<String,String>();
        Map<String,String> parentprodId = new Map<String,String>();
        List<Map<String,String>> producttoadd = new List<Map<String,String>>();
        // getting items from Master Quote where item parent is in parentRootId which we sent in line 125
        List<QuoteLineItem> getparentrootId = new List<QuoteLineItem>([select id,vlocity_cmt__Product2Id__c from QuoteLineItem where quoteid=: masterQuote and vlocity_cmt__Product2Id__c in: parentRootId]);
        for(QuoteLineItem qli : getparentrootId){
            masterRootId.add(qli.Id); // setting bundle Ids from master Quote
        }
        QuoteLineItem getMasterLines = new QuoteLineItem();
        if(insuranse){
            // Querying for Insurance qliId from master Quote
            getMasterLines = [select Id,vlocity_cmt__Product2Id__c from QuoteLineItem where quoteid=: masterQuote and TeliaSE_Product_Code__c = 'MOB_OTHER_ADDON'];
            masterRootId.add(getMasterLines.Id);
        }
        // Querying the items based on rootitemId which we set previously in masterRootId and productId
        List<QuoteLineItem> qlitofromMaster = new List<QuoteLineitem>([select vlocity_cmt__Product2Id__c,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__ParentItemId__c,PricebookEntryId,vlocity_cmt__RootItemId__c from QuoteLineItem where quoteid=: masterQuote and vlocity_cmt__RootItemId__c in:masterRootId and vlocity_cmt__Product2Id__c in: productId]);
        Set<String> prodIdMaster = new Set<string>();
        if(qlitofromMaster.size() != null){
            
            for(QuoteLineItem qli : qlitofromMaster){
                List<String> hierarchy = qli.vlocity_cmt__ProductHierarchyPath__c.split('<'); //spliting the hierarchy and setting in masterIds
                for(String s : hierarchy){
                    masterIds.add(s);
                }
                Map<String,String> proddetails = new Map<String,String>();
                String actualHierrachy = qli.vlocity_cmt__ProductHierarchyPath__c;
                String hierrachy = actualHierrachy.remove('<'+qli.vlocity_cmt__Product2Id__c); // remove the product id from hiereachy
                productHierarchy.put(qli.vlocity_cmt__Product2Id__c,hierrachy);
                productitemid.put(qli.vlocity_cmt__Product2Id__c,qli.PricebookEntryId);
                parentprodId.put(qli.vlocity_cmt__Product2Id__c, hierrachy.split('<')[hierrachy.split('<').size()-1]);
                proddetails.put('productId',qli.vlocity_cmt__Product2Id__c);
                proddetails.put('hierarchy',hierrachy);
                proddetails.put('itemId',qli.PricebookEntryId);
                proddetails.put('parentproductId', hierrachy.split('<')[hierrachy.split('<').size()-1]);
                producttoadd.add(proddetails);
            }
        }
        masterIds.removeall(productId);
        Set<String> itemtobeadded = new Set<string>();
        List<QuoteLineItem> qliitem = new List<QuoteLineItem>([select Id,vlocity_cmt__Product2Id__c,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__ParentItemId__c,PricebookEntryId from QuoteLineItem where quoteid=: oldQuote and vlocity_cmt__Product2Id__c in: masterIds]);
        Map<String,String> iteminCart = new Map<String,String>();
        for(QuoteLineItem qli :qliitem){
            iteminCart.put(qli.vlocity_cmt__Product2Id__c,qli.id);
        }
        for(String s: masterIds){
            if(iteminCart.get(s) == null){
                itemtobeadded.add(s);
            }
        }
        List<Map<String,Object>> ipinput = new List<Map<String,Object>>();
        //get the parent items which are not added in the orginal quote 
        List<QuoteLineitem> fromMaster = new List<QuoteLineItem>([select vlocity_cmt__Product2Id__c,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__ParentItemId__c,PricebookEntryId from QuoteLineItem where quoteid=: masterQuote and vlocity_cmt__Product2Id__c in: itemtobeadded and  vlocity_cmt__RootItemId__c in:masterRootId]);
        //create a node which will be request for IP
        for(QuoteLineItem qli : fromMaster){
            String hierarchy = qli.vlocity_cmt__ProductHierarchyPath__c.remove('<'+qli.vlocity_cmt__Product2Id__c);
            String parentItemId = iteminCart.get(hierarchy.split('<')[hierarchy.split('<').size()-1]);
            String cartid = oldQuote;
            String itemId = qli.PricebookEntryId;
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> itemsMap = new Map<String, Object>();
            Map<String, Object> recordsMap = new Map<String, Object>();
            Map<String, Object> obb = new Map<String, Object>();
            List<Object> items = new List<Object>();
            List<Object> records = new List<Object>();
            recordsMap.put('productHierarchyPath',hierarchy);
            recordsMap.put('parentHierarchyPath',hierarchy);
            records.add(recordsMap);
            obb.put('records',records);
            itemsMap.put('itemId', itemId);
            itemsMap.put('parentId', parentItemId);
            itemsMap.put('parentRecord', obb);
            items.add(itemsMap);
            inputMap.put('items', items);
            inputMap.put('cartId', cartid);
            inputMap.put('validate', false); 
            inputMap.put('price', true);
            inputMap.put('methodName','postCartsItems');
            ipinput.add(inputMap);  
        }
        outMap.put('SubscriptionAndProductMap',ipinput);
        outMap.put('ProductToAdd',producttoadd); // sending this to OS so we know which all products needed to add to cart
    }   
                
    Public static void addlevel(Map<String,Object> inMap, Map<String,Object> outMap){
        try {
            String oldQuote = String.valueOf(inMap.get('ContextId'));
            Map<String,String> productHierarchy = new Map<String,String>(); 
            Map<String,String> parentprodId = new Map<String,String>(); 
            Map<String,String> productitemid = new Map<String,String>(); 
            List<ProductToAddWrapper> qlitoupdate = (List<ProductToAddWrapper>) System.JSON.deserialize(JSON.serialize(inMap.get('ProductToAdd')), List<ProductToAddWrapper>.class);// getting this from previous method which is sent to OS 
            for(ProductToAddWrapper pw : qlitoupdate){
                productHierarchy.put(pw.productId,pw.hierarchy);
                parentprodId.put(pw.productId,pw.parentproductId);
                productitemid.put(pw.productId,pw.itemId);
            }
            Map<String,String> parentid = new Map<String,String>();      
            List<QuoteLineitem> qliparent = new List<QuoteLineItem>([select Id,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__ParentItemId__c,PricebookEntryId from QuoteLineItem where quoteid=: oldQuote]);
            for(QuoteLineitem qli:qliparent){
                parentid.put(qli.vlocity_cmt__Product2Id__c,qli.Id);
            }
            List<Map<String,Object>> ipinput = new List<Map<String,Object>>();
            // creating a request for addtocart which will happen in IP
            for(String key : productHierarchy.keyset()){
                if(parentid.get(parentprodId.get(key)) != null){
                    String hierarchy = productHierarchy.get(key);
                    String parentItemId = parentid.get(parentprodId.get(key));
                    String cartid = oldQuote;
                    String itemId = productitemid.get(key);
                    Map<String, Object> inputMap = new Map<String, Object>();
                    Map<String, Object> itemsMap = new Map<String, Object>();
                    Map<String, Object> recordsMap = new Map<String, Object>();
                    Map<String, Object> obb = new Map<String, Object>();
                    List<Object> items = new List<Object>();
                    List<Object> records = new List<Object>();
                    recordsMap.put('productHierarchyPath',hierarchy);
                    recordsMap.put('parentHierarchyPath',hierarchy);
                    records.add(recordsMap);
                    obb.put('records',records);
                    itemsMap.put('itemId', itemId);
                    itemsMap.put('parentId', parentItemId);
                    itemsMap.put('parentRecord', obb);
                    items.add(itemsMap);
                    inputMap.put('items', items);
                    inputMap.put('cartId', cartid);
                    inputMap.put('validate', false); 
                    inputMap.put('price', true);
                    inputMap.put('methodName','postCartsItems');
                    ipinput.add(inputMap);  
                }
            }
            outMap.put('singleCartList',ipinput);
        }catch(Exception e) {  
            outMap.put('quoteLevel2Exception',e);
        }
    }
    
    public static void updateFields(Map<String,Object> inMap, Map<String,Object> outMap){
        try{
            String oldQuote = String.valueOf(inMap.get('ContextId'));
            String backupQuote = String.valueOf(inMap.get('BackupQuoteId'));
            Set<String> productId = new Set<String>();
            List<ProductToAddWrapper> qlitoupdate = (List<ProductToAddWrapper>) System.JSON.deserialize(JSON.serialize(inMap.get('ProductToAdd')), List<ProductToAddWrapper>.class); //getting all productId's which we have added before
            for(ProductToAddWrapper pw : qlitoupdate){
                productId.add(pw.productId);
            }
            List<QuoteLineItem> QliUpdate = new List<QuoteLineItem>();
            // get the details from backupQuote and QuoteLineItem Id from orginal Quote and Update details on new QLI id
            List<QuoteLineItem> backUpQLIList = new List<QuoteLineItem>([Select Id,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__Product2Id__r.Name,TeliaSE_Product_Code__c,TeliaSE_MC_SM_Floor_Price__c,TeliaSE_CommitmentPeriod__c,MC_Quarantine_Time__c,TeliaSE_StartDate__c,TeliaSE_EndDate__c,TeliaSE_Approved__c,TeliaSE_Approved_Price__c,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_MC_Customer_Requested_Percentage__c,TeliaSE_Base_Quantity__c,TeliaSE_CM_Mandate_Percentage__c,TeliaSE_AM_Mandate_Percentage__c,TeliaSE_SM_Mandate_Percentage__c,TeliaSE_SD_Mandate_Percentage__c,TeliaSE_Discount_Percentage__c,vlocity_cmt__RecurringDiscountPrice__c,vlocity_cmt__OneTimeDiscountPrice__c,vlocity_cmt__OverageDiscountPrice__c,TeliaSE_Minimum_Value_Commit__c,TeliaSE_SubsidisedVoice__c,TeliaSE_Ceiling_Price__c,vlocity_cmt__RecurringCharge__c,TeliaSE_Target_Price__c,vlocity_cmt__JSONAttribute__c,vlocity_cmt__JSONNode__c,vlocity_cmt__Product2Id__c,vlocity_cmt__RootItemId__c from QuoteLineItem where QuoteId=:backupQuote and vlocity_cmt__Product2Id__c in: productId]);
            List<QuoteLineItem> oldQLIList = new List<QuoteLineItem>([select Id,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__Product2Id__c,TeliaSE_Product_Code__c,vlocity_cmt__RootItemId__c from QuoteLineItem where QuoteId =:oldQuote and vlocity_cmt__Product2Id__c in: productId]);
            Map<String,Object> qliMap = new Map<String,Object>();
           // Map<String,String> rootIdMap = new Map<String,String>();
            
            for(QuoteLineItem qli : backUpQLIList){
                qliMap.put(qli.vlocity_cmt__Product2Id__c,qli);    
            }
            Map<String,String> qliIdMap = new Map<String,String>();
            for(QuoteLineItem oqli : oldQLIList){
                qliIdMap.put(oqli.vlocity_cmt__Product2Id__c, oqli.Id);
           //     rootIdMap.put(oqli.Id,oqli.vlocity_cmt__RootItemId__c);
           //     rootId.add(oqli.vlocity_cmt__RootItemId__c);
            }
        //    List<QuoteLineItem> rootQLIId = new List<QuoteLineItem>([select Id,vlocity_cmt__Product2Id__c from QuoteLineItem where QuoteId =:oldQuote and Id in: rootId]);
        //    Map<String,String> qliMapRootitems = new Map<String,String>();
        //    for(QuoteLineItem root : rootQLIId){
        //        qliMapRootitems.put(root.Id,root.vlocity_cmt__Product2Id__c);
        //    }
            for(String oqli : qliIdMap.keySet()){
                for(String bqli : qliMap.keySet()){
                    if(oqli == bqli){
                        QuoteLineItem updateqli = new QuoteLineItem();
                        updateqli.Id = qliIdMap.get(oqli);
              //          String rootqliIds = qliIdMap.get(oqli);
             //           String rootProductId = rootIdMap.get(rootqliIds);
             //           updateqli.TeliaSE_Root_Product__c = qliMapRootitems.get(rootProductId);
                        QuoteLineItem qli = new QuoteLineItem();
                        qli = (QuoteLineItem)qliMap.get(oqli);
                        
                        updateqli.TeliaSE_CommitmentPeriod__c = qli.TeliaSE_CommitmentPeriod__c;
                        updateqli.MC_Quarantine_Time__c = qli.MC_Quarantine_Time__c;
                        updateqli.TeliaSE_StartDate__c = qli.TeliaSE_StartDate__c;
                        updateqli.TeliaSE_EndDate__c = qli.TeliaSE_EndDate__c;
                        updateqli.TeliaSE_Approved__c = qli.TeliaSE_Approved__c;
                        updateqli.TeliaSE_Approved_Price__c = qli.TeliaSE_Approved_Price__c;
                        updateqli.TeliaSE_MC_Customer_Requested_Price__c= qli.TeliaSE_MC_Customer_Requested_Price__c;
                        updateqli.TeliaSE_MC_Customer_Requested_Percentage__c = qli.TeliaSE_MC_Customer_Requested_Percentage__c;
                        updateqli.TeliaSE_Base_Quantity__c= qli.TeliaSE_Base_Quantity__c;
                        updateqli.TeliaSE_CM_Mandate_Percentage__c = qli.TeliaSE_CM_Mandate_Percentage__c;
                        updateqli.TeliaSE_AM_Mandate_Percentage__c= qli.TeliaSE_AM_Mandate_Percentage__c;
                        updateqli.TeliaSE_SM_Mandate_Percentage__c= qli.TeliaSE_SM_Mandate_Percentage__c;
                        updateqli.TeliaSE_SD_Mandate_Percentage__c= qli.TeliaSE_SD_Mandate_Percentage__c;
                        updateqli.TeliaSE_Discount_Percentage__c= qli.TeliaSE_Discount_Percentage__c;
                        updateqli.vlocity_cmt__RecurringDiscountPrice__c= qli.vlocity_cmt__RecurringDiscountPrice__c;
                        updateqli.vlocity_cmt__OneTimeDiscountPrice__c= qli.vlocity_cmt__OneTimeDiscountPrice__c;
                        updateqli.vlocity_cmt__OverageDiscountPrice__c= qli.vlocity_cmt__OverageDiscountPrice__c;
                        updateqli.TeliaSE_Minimum_Value_Commit__c= qli.TeliaSE_Minimum_Value_Commit__c;
                        updateqli.TeliaSE_SubsidisedVoice__c= qli.TeliaSE_SubsidisedVoice__c;
                        updateqli.TeliaSE_Ceiling_Price__c= qli.TeliaSE_Ceiling_Price__c;
                        updateqli.vlocity_cmt__RecurringCharge__c= qli.vlocity_cmt__RecurringCharge__c;
                        updateqli.TeliaSE_Target_Price__c= qli.TeliaSE_Target_Price__c;
                        updateqli.vlocity_cmt__JSONAttribute__c= qli.vlocity_cmt__JSONAttribute__c;
                        updateqli.vlocity_cmt__JSONNode__c= qli.vlocity_cmt__JSONNode__c;
                        updateqli.vlocity_cmt__OneTimeCharge__c= qli.vlocity_cmt__OneTimeCharge__c;
                        updateqli.vlocity_cmt__OneTimeTotal__c= qli.vlocity_cmt__OneTimeTotal__c;

                        QliUpdate.add(updateqli);
                   }
                }
            }
            if(QliUpdate.size() != null && QliUpdate.size() > 0){
                update QliUpdate;    
            }
            List<QuoteLineItem> rootQLIId = new List<QuoteLineItem>([select Id,vlocity_cmt__Product2Id__c from QuoteLineItem where QuoteId =:oldQuote]);
            Set<Id> rootId = new Set<Id>();
            for(QuoteLineItem root : rootQLIId){
                rootId.add(root.Id);
            }
            TeliaSE_QuoteLineHandler.updateRootProductId(rootId);
            if(inMap.get('isLocked') == true)
            {
                Approval.lock(oldQuote, false);
            }
        }catch(Exception e) {  
            outMap.put('updateFieldsException',e);
        }
    }
    
    public static void addOnBundle(Map<String,Object> inMap, Map<String,Object> outMap){
        String oldQuote = String.valueOf(inMap.get('ContextId'));
        String masterQuote;
        if(Test.isRunningTest()){
            masterQuote = String.valueof(outMap.get('mquid'));
        }
        if(!Test.isRunningTest()){
            masterQuote = System.Label.TeliaSE_Master_quote;   
        }
        //----------------------------------Set for Addon bundle---------------------------
        Set<String> addOnBundle = new Set<String>();
        addOnBundle.add('MOB_OTHER_TARIFF');
        addOnBundle.add('MOB_ADD_ON');
        addOnBundle.add('MOB_BB_TECH_PROD');
        addOnBundle.add('TP-USER-OFFER');
        addOnBundle.add('TP-OPT-CMP');
        addOnBundle.add('C-BUS-PREMIUM');
        addOnBundle.add('TP-USERS-MOBILE');
        List<Product2> addOnBundleProductId = new List<Product2>([select Id from Product2  where ProductCode in: addOnBundle]); 
        Set<String> addOnBundleProdId = new Set<String>();
        for(Product2 addonprod : addOnBundleProductId){
            addOnBundleProdId.add(addonprod.Id);
        }
        //---------------------------------------------------------------------------------
        List<QuoteLineItem> rootItemList = new List<QuoteLineItem>([select Id,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__RootItemId__c,TeliaSE_Root_Product__c from QuoteLineItem where QuoteId =: oldQuote]);
        Set<String> rootItemSet = new Set<String>();
        Map<String,String> addonprodmap = new Map<String,String>();
        for(QuoteLineItem qli : rootItemList){
            rootItemSet.add(qli.TeliaSE_Root_Product__c);
            addonprodmap.put(String.valueof(qli.vlocity_cmt__Product2Id__c),String.valueof(qli.Id));
        }
        List<QuoteLineItem> orginalQuoteAddonList = new List<QuoteLineItem>([select Id,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__RootItemId__c,TeliaSE_Root_Product__c from QuoteLineItem where QuoteId =: oldQuote and vlocity_cmt__Product2Id__c =:addOnBundleProdId and TeliaSE_Root_Product__c =: rootItemSet]);
        Set<String> addOnIdset = new Set<String>();
        for(QuoteLineItem qli : orginalQuoteAddonList){
            addOnIdset.add(qli.vlocity_cmt__Product2Id__c);
        }
        List<QuoteLineItem> masterItemList = new List<QuoteLineItem>([select Id,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__RootItemId__c,TeliaSE_Root_Product__c from QuoteLineItem where QuoteId =: masterQuote and vlocity_cmt__Product2Id__c =:addOnBundleProdId and TeliaSE_Root_Product__c =: rootItemSet]);
        Set<String> masteraddon = new Set<String>();
        for(QuoteLineItem qli : masterItemList){
            masteraddon.add(qli.vlocity_cmt__Product2Id__c);
        }
        masteraddon.removeAll(addOnIdset);
        List<QuoteLineItem> finalQuerymaster = new List<QuoteLineItem>([select Id,vlocity_cmt__Product2Id__c, PricebookEntryId, TeliaSE_Root_Product__c, vlocity_cmt__ProductHierarchyPath__c from QuoteLineItem where QuoteId =: masterQuote and vlocity_cmt__Product2Id__c =:masteraddon and TeliaSE_Root_Product__c =: rootItemSet]);
        List<Map<String,Object>> ipinput = new List<Map<String,Object>>();
        for(QuoteLineItem qli : finalQuerymaster){
            String hierarchy = qli.TeliaSE_Root_Product__c;
            String parentItemId = addonprodmap.get(qli.TeliaSE_Root_Product__c);
            String cartid = oldQuote;
            String itemId = qli.PricebookEntryId;
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> itemsMap = new Map<String, Object>();
            Map<String, Object> recordsMap = new Map<String, Object>();
            Map<String, Object> obb = new Map<String, Object>();
            List<Object> items = new List<Object>();
            List<Object> records = new List<Object>();
            recordsMap.put('productHierarchyPath',hierarchy);
            recordsMap.put('parentHierarchyPath',hierarchy);
            records.add(recordsMap);
            obb.put('records',records);
            itemsMap.put('itemId', itemId);
            itemsMap.put('parentId', parentItemId);
            itemsMap.put('parentRecord', obb);
            items.add(itemsMap);
            inputMap.put('items', items);
            inputMap.put('cartId', cartid);
            inputMap.put('validate', false); 
            inputMap.put('price', true);
            inputMap.put('methodName','postCartsItems');
            ipinput.add(inputMap);
        }
        outMap.put('addondefault',ipinput);
    }
    
   
/**
 * Added this method to revert the changes to Quote if process fails somewhere in flow
 * here we are deleting all the items from the original Quote and adding the items from backupQuote
 */  
    public static void revertOriginalQuote(Map<String,Object> inMap, Map<String,Object> outMap){
        try{
            String oldQuote = String.valueOf(inMap.get('ContextId'));
            String backupQuote = String.valueOf(inMap.get('BackupQuoteId'));
            Quote oldQut = new Quote(Id =oldQuote);
            Quote newQut = new Quote(Id =backupQuote);
            deleteQuoteItems(oldQuote); // deleting all the items from Quote
            List<QuoteLineItem> qliList = cloneBackupQuoteLines(oldQut,newQut); // getting items from backup and inserted to old Quote
            insert qliList;
        }catch(Exception e) {  
            outMap.put('revertQuoteException',e);
        }
    }
    public static void deleteQuoteItems(String quoteId){
        List<QuoteLineItem> qliList = [select id, QuoteId, Product2Id, Product2.ProductCode, vlocity_cmt__ProductHierarchyPath__c from QuoteLineItem where QuoteId=:quoteId];
        List<QuoteLineItem> qliToBeDeleted = new List<QuoteLineItem>();
        List<String> thirdLevelProdList = new List<String>();
        for(QuoteLineItem qli : qliList){
            qliToBeDeleted.add(qli); // adding to list to delete
        }
        delete qliToBeDeleted;
    }
    
    //return dynamic query for the Object
    private static String queryBuilder(String obj) {
        SObjectType quoteObj = Schema.getGlobalDescribe().get(obj);
        Map<String,Schema.SObjectField> objfields = quoteObj.getDescribe().fields.getMap();
        String query = 'Select ';
        Boolean firstField = true;
        List<Sobject> quoteList=new List<Sobject>();   
        for (String field : objfields.keySet()) {
            if(firstField)
                query += field;
            else{
                query +=' , ';
                query += field;
            }
            firstField = false;
        }
        return query;
    }
    
    public class ProductToAddWrapper {
        public String parentproductId;
        public String itemId;
        public String hierarchy;
        public String productId;
    }
}