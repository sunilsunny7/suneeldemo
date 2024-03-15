global with sharing class TeliaSE_QuoteConfig implements vlocity_cmt.VlocityOpenInterface2{
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try{
            if(methodName.equalsIgnoreCase('modifyQuote')){
                TeliaSE_QuoteConfig.modifyQuote(inputMap, outMap);
            } 
            else if(methodName.equalsIgnoreCase('updateCampaign')){
                TeliaSE_QuoteConfig.updateCampaign(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('searchCampaigns')){
                TeliaSE_QuoteConfig.searchCampaigns(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('updateHardwareProductDetails')){
                TeliaSE_QuoteConfig.updateHardwareProductDetails(inputMap, outMap);
            }
         /*   else if(methodName.equalsIgnoreCase('clearSingleCartFAQuantity')){
                TeliaSE_QuoteConfig.clearSingleCartFAQuantity(inputMap, outMap);
            }*/
            else if(methodName.equalsIgnoreCase('updateCartPrice')){
                TeliaSE_QuoteConfig.updateCartPrice(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('saveQuantity')){
                TeliaSE_QuoteConfig.savingQuantity(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('mcAddRootProduct')){
                TeliaSE_QuoteConfig.mcAddRootProduct(inputMap, outMap, options);
            }
            else if(methodName.equalsIgnoreCase('updatePriceFlag')){
                TeliaSE_QuoteConfig.updatePriceFlag(inputMap, outMap, options);
            }
            else if(methodName.equalsIgnoreCase('AutoTaskQuoteSync')){
                TeliaSE_QuoteConfig.AutoTaskQuoteSync(inputMap, outMap, options);
            }
            else if(methodName.equalsIgnoreCase('checkBasSubscriptionAndAttribute')){   
                if(inputMap.containsKey('templateFlag')){ 
                    if(String.valueOf(inputMap.get('salesFlowIdentifier')) != 'Inforhandling' && String.valueOf(inputMap.get('category')) == 'F5FAX/DATA'){
                        checkBasSubscriptionAndAttribute(inputMap, outMap);
                    } }                
                else{                    
                    if(String.valueOf(inputMap.get('prodCode')).contains('MOB_MULTI_TOTAL') && String.valueOf(inputMap.get('salesFlowIdentifier')) != 'Inforhandling'){
                        checkBasSubscriptionAndAttribute(inputMap, outMap);
                    }
                }
            }      
            else if (methodName.equals('updateFiberFields')){
                updateFiberFields(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('priceCart')){
                TeliaSE_QuoteConfig.priceCart(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('checkBenefitEligibility')){
                TeliaSE_QuoteConfig.checkBenefitEligibility(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('lockUnlockQuote')){
                TeliaSE_QuoteConfig.lockUnlockQuote(inputMap,outMap,options);
            }
            /* else if(methodName.equalsIgnoreCase('saveBulkAntal'))
            {
            TeliaSE_QuoteConfig.saveBulkAntal(inputMap, outMap);
            } */
            else{  result = false;              
                }   
            
        } catch(Exception e){          
            result = false;
        }        
        return result;
    }  
    
/*    public static void clearSingleCartFAQuantity(Map<String,Object> inputMap, Map<String,Object> outMap){
        String quoteId = (String)inputMap.get('quoteId');
        List<QuoteLineItem> qliList = [select id,QuoteId,TeliaSE_MC_FACallOffQuantity__c from QuoteLineItem where QuoteId =:quoteId and TeliaSE_MC_FACallOffQuantity__c >= 0];
        List<QuoteLineItem> updateQliList = new List<QuoteLineItem>();
        if(qliList.size() >0){
            for(QuoteLineItem ql: qliList){
                ql.TeliaSE_MC_FACallOffQuantity__c = null;
                ql.Id = ql.Id;
                updateQliList.add(ql);
            }
        }
        if(updateQliList.size() >0) update updateQliList;
    }*/
    
    public static void lockUnlockQuote(Map<String,Object> inputMap , Map<String,Object> outMap , Map<String,Object> options){
        String quoteId = (String) inputMap.get('QuoteId');
        String lockUnlockSetting = (String) options.get('lockUnlockSetting');
        Boolean lockedStatus = Approval.isLocked(quoteId);
        if(lockedStatus && lockUnlockSetting == 'Unlock'){
            Approval.unlock(quoteId,false);
            outMap.put('unlockedQuote',true);
        }
        else if(!lockedStatus && lockUnlockSetting == 'Lock'){
            Approval.lock(quoteId,false);
        }
    }
    
    public static void updateCampaign(Map<String,Object> inputMap, Map<String,Object> outMap){
        string quoteId = String.ValueOf(inputMap.get('quoteId')),productName = String.ValueOf(inputMap.get('productName')),promoName = String.ValueOf(inputMap.get('promoName')),promoId = String.ValueOf(inputMap.get('promoId')),rootItemId = String.ValueOf(inputMap.get('rootItemId'));        
        try{
            if(promoId != null){
                QuoteLineItem qtLineItem = new QuoteLineItem();
                qtLineItem.Id = rootItemId;
                qtLineItem.TeliaSE_MC_Campaign_Id__c = promoId;
                update qtLineItem;
            } else{
                outMap.put('noPromoUpdate', 'noPromoUpdate');
            }
        } catch(Exception e){
            outMap.put('ErrorMessage', 'Error while updating Campaign');    
        }
    }
    
    //MC-1189 - Return Campaigns (promotions) for particular subscription item from contract quote.
    public static void searchCampaigns(Map<String,Object> inputMap,Map<String,Object> outMap){
        String quoteId = String.ValueOf(inputMap.get('quoteId')),rootItemId = String.ValueOf(inputMap.get('rootItemId'));
        if (quoteId != null ){
            String contractType,prodObjType;            
            QuoteLineItem qlt = [select Id,TeliaSE_Product_Code__c,vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c, Quote.TeliaSE_Type__c,TeliaSE_Offer_Type__c, TeliaSE_Product_Object_Type__c  from QuoteLineItem where Id =:rootItemId];
            List<TeliaSE_MC_Product_Object_Type__c> custValues = TeliaSE_MC_Product_Object_Type__c.getAll().values();
            for(TeliaSE_MC_Product_Object_Type__c objTypeVal:custValues){
                if(objTypeVal.Product_Object_Type__c == qlt.TeliaSE_Product_Object_Type__c){
                    prodObjType = objTypeVal.Object_Type_Value__c;
                }
            }            
            String lineItemType = qlt.TeliaSE_Offer_Type__c;
            contractType = qlt.Quote.TeliaSE_Type__c;
            contractType=contractType==null?'New':'Renegotiation';
            if(lineItemType == System.label.TeliaSE_MC_Subscription_Offering && qlt.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c != null && !qlt.TeliaSE_Product_Code__c.contains('MOB_BAS_V2')){
                List<vlocity_cmt__Promotion__c> promoList = [SELECT id, Name, MC_Product_Name_Eng__c, TeliaSE_MC_Campaign_Type__c, vlocity_cmt__Description__c,vlocity_cmt__DurationTimePlanId__r.Name, vlocity_cmt__DiscountType__c,vlocity_cmt__Duration__c, vlocity_cmt__DurationTimePlanId__r.vlocity_cmt__Description__c FROM vlocity_cmt__Promotion__c WHERE RecordType.Name =: 'Discount' AND vlocity_cmt__Code__c LIKE :prodObjType and TeliaSE_MC_Campaign_Type__c =:contractType];                                                              
                outMap.put('promoRes', promoList);
            }
        }
    }
    
    public static void updateHardwareProductDetails(Map<String,Object> inputMap, Map<String,Object> outMap){
        String quoteId = String.ValueOf(inputMap.get('quoteId')),qliId = String.ValueOf(inputMap.get('qliId')),largerStatus = String.ValueOf(inputMap.get('largerStatus')),pricelistSetup = String.ValueOf(inputMap.get('pricelistSetup'));
        String qliAssetId = String.ValueOf(inputMap.get('qliAssetId'));
        String subscription = String.ValueOf(inputMap.get('subscription')),bindingTime = String.ValueOf(inputMap.get('BindingTime')),salesType= String.ValueOf(inputMap.get('salesTypeSetup'));        
        QuoteLineItem qItem = [SELECT Id,Lagerstatus__c,Price_List_Setup__c,TeliaSE_MC_Sales_Type__c, Subscription__c,TeliaSE_MC_Binding_Time__c FROM QuoteLineItem WHERE QuoteId=:quoteId AND Id =:qliId LIMIT 1];        
        try{
            //for( QuoteLineItem qItem : qLineitems ){
            if (qItem != null && (largerStatus != null || pricelistSetup != null || subscription != null || bindingTime != null)){
                qItem.Lagerstatus__c = largerStatus;
                qItem.Price_List_Setup__c = pricelistSetup;
                qItem.Subscription__c = subscription;
                qItem.TeliaSE_MC_Binding_Time__c = bindingTime;
                qItem.Id = qliId;
                if(salesType!= null ){
                    qItem.TeliaSE_MC_Sales_Type__c = salesType;
                }
                update qItem;
            } else if(qItem != null && salesType != null){
                qItem.TeliaSE_MC_Sales_Type__c = salesType;
                qItem.Id = qliId;
                update qItem;
            }            
            List<QuoteLineItem> qlList = [SELECT Id, TeliaSE_MC_Sales_Type__c FROM QuoteLineItem WHERE vlocity_cmt__ParentItemId__c=:qliAssetId];            
            List<QuoteLineItem> updateChild = new List<QuoteLineItem>();            
            if(qlList.size() > 0 && salesType != null){
                for(QuoteLineItem ql:qlList){
                    QuoteLineItem q = new QuoteLineItem();
                    q.Id = ql.Id;
                    q.TeliaSE_MC_Sales_Type__c = salesType;
                    updateChild.add(q);
                }
            }
            
            if(updateChild.size() > 0) update updateChild;
            //}  
        } catch(Exception e){
            outMap.put('ErrorMessage', 'Error while updating HardwareField');    
        }
    } 
    
    public static void modifyQuote(Map<String,Object> inputMap, Map<String,Object> outMap){        
        String quoteId = String.ValueOf(inputMap.get('quoteId')),rootItemId= String.ValueOf(inputMap.get('rootItemId')),salesType= String.ValueOf(inputMap.get('salesTypeSetup'));
        String strRTItme =String.ValueOf(inputMap.get('rootItemBindingTime'));
        List<QuoteLineItem> qLineitemstoBeupdated = new List<QuoteLineItem>();
        for( QuoteLineItem qItem : [SELECT Id, TeliaSE_Approved__c, TeliaSE_MC_Binding_Time__c,TeliaSE_MC_Sales_Type__c, TeliaSE_Approved_Price__c, TeliaSE_Nullify_Check__c,MC_OT_Approved_Price__c   FROM QuoteLineItem where QuoteId=:quoteId and vlocity_cmt__RootItemId__c =:rootItemId]){
            if(qItem.TeliaSE_Approved_Price__c != null){
                qItem.TeliaSE_Approved_Price__c  = null;
                qItem.TeliaSE_MC_Binding_Time__c = strRTItme;
                qItem.TeliaSE_Nullify_Check__c = true;
                qItem.TeliaSE_MC_Sales_Type__c = salesType;
                qLineitemstoBeupdated.add(qItem);
            }
            if(qItem.TeliaSE_Approved__c != null){
                qItem.TeliaSE_Approved__c = null;
                qItem.TeliaSE_Nullify_Check__c = true;
                qItem.TeliaSE_MC_Binding_Time__c = strRTItme;
                qItem.TeliaSE_MC_Sales_Type__c = salesType;
                qLineitemstoBeupdated.add(qItem);
            }            
            if(qItem.MC_OT_Approved_Price__c   != null){
                qItem.MC_OT_Approved_Price__c   = null;
                qItem.TeliaSE_Nullify_Check__c = true;
                qItem.TeliaSE_MC_Binding_Time__c = strRTItme;
                qItem.TeliaSE_MC_Sales_Type__c = salesType;
                qLineitemstoBeupdated.add(qItem);
            }
        }
        //update qLineitemstoBeupdated;
        Database.SaveResult[] srList = Database.update(qLineitemstoBeupdated, false);
        Boolean flag = false;
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList){
            if (sr.isSuccess()){
                flag = true;
            }
            else{
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()){
                    flag = false;
                }
            }
        }
        if(flag){
            outMap.put('result', 'Success');
            
        }else{
            
            outMap.put('result', 'Error');
        }
    }
    
    public static void savingQuantity(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{        
            Map<String,Object> input = (Map<String,Object>)inputMap.get('obj');
            Map<String,Object> inputKey = new Map<String,Object>();
            Map<String,Object> saveQli = new Map<String,Object>();
            List<String> keysList=new List<String>();
            keysList.add('Id');
           // keysList.add('TeliaSE_MC_FACallOffQuantity__c');
            keysList.add('TeliaSE_MC_Customer_Requested_Percentage__c');
            keysList.add('TeliaSE_MC_Customer_Requested_Price__c');
            keysList.add('vlocity_cmt__RootItemId__c');
           // keysList.add('MC_Initial_Order_Quantity__c');
          //  keysList.add('MC_Convergence_Quantity__c');           
            
            Boolean invalidPrice = (Boolean)inputMap.get('invalidPrice');
            if(invalidPrice==null){  
                invalidPrice=true;  
            }
            Id pricingMasterID = (Id)inputMap.get('pricePlanId');
            
            String fieldName = (String)inputMap.get('fieldName');
            for(String key : input.keySet()){                 
                if(keysList.contains(key)){
                    inputKey = (Map<String,Object>) input.get(key);
                    saveQli.put(key,inputKey.get('value'));
                }
            }
            saveQlimethod(saveQli,fieldName,invalidPrice,pricingMasterID);
            outMap.put('Success',true);
        }
        catch(Exception e){
            outMap.put('Success',false); outMap.put('errorMessage',e.getMessage());          
        }
    }
    
    public static void saveQlimethod(Map<String,Object> input, String fieldName, Boolean invalidPrice, Id pricingMasterID){
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        QuotelineItem qli = new QuotelineItem();        
        String qliId = (String)input.get('Id'),rootItemId = (String)input.get('vlocity_cmt__RootItemId__c'),rootItemBindingTime = (Id)input.get('TeliaSE_MC_Binding_Time__c')!= NULL? (Id)input.get('TeliaSE_MC_Binding_Time__c'): NULL;  
        qli = [SELECT Id,TeliaSE_MC_Customer_Requested_Percentage__c,MC_Sales_FrameworkPricingMaster__c,MC_Line_Status__c,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_MC_Binding_Time__c,MC_Initial_Order_Quantity__c,MC_Convergence_Quantity__c,QuoteId,Quote.MC_CartRepriceRequired__c FROM quotelineItem WHERE id=:qliId];
        qli.TeliaSE_MC_FACallOffQuantity__c = (Decimal)input.get('TeliaSE_MC_FACallOffQuantity__c');
        qli.MC_Initial_Order_Quantity__c = (Decimal)input.get('MC_Initial_Order_Quantity__c');
        qli.MC_Convergence_Quantity__c= (Decimal)input.get('MC_Convergence_Quantity__c');
        Boolean repriceRequired=false;
        Id quoteId;
        if(((Decimal)input.get('TeliaSE_MC_Customer_Requested_Percentage__c') != null && qli.TeliaSE_MC_Customer_Requested_Percentage__c != (Decimal)input.get('TeliaSE_MC_Customer_Requested_Percentage__c')) ||((Decimal)input.get('TeliaSE_MC_Customer_Requested_Percentage__c') == null && qli.TeliaSE_MC_Customer_Requested_Percentage__c != null) ||((Decimal)input.get('TeliaSE_MC_Customer_Requested_Price__c') != null && qli.TeliaSE_MC_Customer_Requested_Price__c != (Decimal)input.get('TeliaSE_MC_Customer_Requested_Price__c')) ||((Decimal)input.get('TeliaSE_MC_Customer_Requested_Price__c') == null && qli.TeliaSE_MC_Customer_Requested_Price__c != null)){ 
            qli.TeliaSE_MC_Customer_Requested_Percentage__c = (Decimal)input.get('TeliaSE_MC_Customer_Requested_Percentage__c');       
            if(fieldName == 'TeliaSE_MC_Customer_Requested_Price__c'){
                qli.TeliaSE_MC_Customer_Requested_Price__c =(Decimal)input.get('TeliaSE_MC_Customer_Requested_Price__c');     
                qli.MC_Sales_FrameworkPricingMaster__c = invalidPrice || (!invalidPrice && (Decimal)input.get('TeliaSE_MC_Customer_Requested_Price__c') == NULL) ? NULL:pricingMasterID;//added checks to handle null pricePlanID when requested price is made blank.
            }
            
            QuoteLineItem qliRootProduct = [SELECT Id, MC_Line_Status__c,QuoteId,Quote.MC_CartRepriceRequired__c FROM QuoteLineItem WHERE vlocity_cmt__AssetReferenceId__c =:rootItemId];          
            if(qliRootProduct.id != qli.id){
                // qli(not root) being updated
                qliRootProduct.MC_RootPriceFlag__c = true;
                if(qliRootProduct.MC_Line_Status__c == 'Existing' || String.isBlank(qliRootProduct.MC_Line_Status__c)){
                    qliRootProduct.MC_Line_Status__c = 'Updated';
                }                
                qliList.add(qliRootProduct);
            }
            else{
                //Root item being updated
                qli.MC_RootPriceFlag__c =true;
                if(qli.MC_Line_Status__c == 'Existing' || String.isBlank(qli.MC_Line_Status__c)){
                    qli.MC_Line_Status__c = 'Updated';
                }
            }
            repriceRequired=true;
            quoteId=qli.QuoteId;
        }
        qliList.add(qli);
        if(qliList!= null && qliList.size()>0) update qliList;
        
        if(repriceRequired){           
            //Code to modify cart reprice required flag for Validera Priser Improvement(By Abhishek)
            /* Initialize variables */
            String procedureName = 'RepriceCart_ValideraPriser';
            Map<String,Object> ipInput = new Map<String,Object>();
            Map<String,Object> ipOutput = new Map<String,Object>();
            Map<String,Object> ipOptions = new Map<String,Object>();
            
            /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
            ipInput.put('quoteId',quoteId);
            ipInput.put('cartRepricedAfterValidera',true);
            
            /* Call the IP via runIntegrationService, and save the output to ipOutput */
            ipOutput = (Map<String,Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
            
        }
    } 
    
    public static void updateCartPrice(Map<String,Object> inputMap, Map<String,Object> outMap){
        
        String cartId = (String)inputMap.get('cartId'),quotetype = (String)inputMap.get('type');
        //String quotetype = (String)inputMap.get('type');
        
        if(quoteType != 'New Sales'){
            List<QuoteLineItem> qliItem = [Select id,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c,MC_RootPriceFlag__c from quoteLineItem where Quoteid=: cartId];
            List<String> parentItemId = new List<String>();
            List<Id> pricingItemIds = new List<Id>();
            boolean allUpdated = true;
            for(QuoteLineItem qli:qliItem){
                if(qli.vlocity_cmt__ParentItemId__c == null && qli.MC_RootPriceFlag__c == true){
                    parentItemId.add(qli.vlocity_cmt__RootItemId__c);
                }
                else if(qli.vlocity_cmt__ParentItemId__c == null && qli.MC_RootPriceFlag__c == false){
                    allUpdated = false;
                }
            }
            if(parentItemId != null && parentItemId.size()>0 && allUpdated == false){
                for(QuoteLineItem qliChild : qliItem){
                    if(parentItemId.contains(qliChild.vlocity_cmt__RootItemId__c)){
                        pricingItemIds.add(qliChild.id);
                    }
                }
                inputMap.put('items',pricingItemIds);
            }
        }        
        if(!Test.isRunningTest()){            
            new vlocity_cmt.CpqAppHandler().invokeMethod('priceCart', inputMap, outMap, outMap);
        }
    }
    
    public static void mcAddRootProduct(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        String contextId = (String)options.get('cartId');           
        List<QuoteLineItem> qliItems = [Select id,Quote.vlocity_cmt__ParentQuoteId__c from QuoteLineItem where QuoteId =:contextId];
        Set<Id> qliIdSet = new Set<Id>();
        if(qliItems.size()>0){
            for(QuoteLineItem qli:qliItems){
                qliIdSet.add(qli.Id);
                if(!outMap.containsKey('parentQuote') && qli.Quote.vlocity_cmt__ParentQuoteId__c!=null){
                    outMap.put('parentQuote', qli.Quote.vlocity_cmt__ParentQuoteId__c);
                }
            }
            if(!test.isRunningTest()) updateRootProductId(qliIdSet);
        }
    }
    
    public static void updateRootProductId(Set<Id> ids){
        
        Id rootItemId;
        id rootItemBindingTime;
        Boolean noRoot;
        String salesType,salesTypeLineItem;
        //String salesTypeLineItem;
        //23.10 <<feature no>> AssetReferenceId change - Aditi
        Set<String> rootIds=new Set<String>();
        Map<String,Id> rootItemsMap=new Map<String,Id>();
        Map<String,String> salesTypeMap=new Map<String,String>();
        List<QuoteLineItem> updateItems=new List<QuoteLineItem>();
        
        List<QuoteLineItem> items=[SELECT id,TeliaSE_MC_Sales_Type__c, vlocity_cmt__RootItemId__c FROM QuoteLineItem WHERE id=:ids FOR UPDATE];
        List<QuoteLineItem> rootItems=[select id, TeliaSE_MC_Sales_Type__c, vlocity_cmt__Product2Id__c,vlocity_cmt__RootItemId__c from QuoteLineItem where id =:ids and vlocity_cmt__ParentItemId__c= null ];
        if(rootItems.size()<1){
            for(QuoteLineItem item:items){
                rootIds.add(item.vlocity_cmt__RootItemId__c);
            }
            List<QuoteLineItem> roots=[select id, TeliaSE_MC_Sales_Type__c,vlocity_cmt__Product2Id__c,vlocity_cmt__RootItemId__c from QuoteLineItem where vlocity_cmt__AssetReferenceId__c =:rootIds];                                       
            for(QuoteLineItem rootItem:roots){   
                salesType = rootItem.TeliaSE_MC_Sales_Type__c;
                rootItemsMap.put(rootItem.vlocity_cmt__RootItemId__c,rootItem.vlocity_cmt__Product2Id__c);
                if(salesType != null && salesType != '') salesTypeMap.put(rootItem.vlocity_cmt__RootItemId__c,salesType);
            }
            for(QuoteLineItem item:items){
                salesTypeLineItem = salesTypeMap.get(item.vlocity_cmt__RootItemId__c);
                item.TeliaSE_Root_Product__c=rootItemsMap.get(item.vlocity_cmt__RootItemId__c);
                if(salesTypeLineItem != null && salesTypeLineItem != '') item.TeliaSE_MC_Sales_Type__c=salesTypeLineItem;
                updateItems.add(item);
            }
            
        }
        else{    
            for(QuoteLineItem rootItem:rootItems){
                salesType = rootItem.TeliaSE_MC_Sales_Type__c;                
                rootItemsMap.put(rootItem.vlocity_cmt__RootItemId__c,rootItem.vlocity_cmt__Product2Id__c);
                if(salesType != null && salesType != '') salesTypeMap.put(rootItem.vlocity_cmt__RootItemId__c,salesType);
            }
            for(QuoteLineItem item:items){   
                salesTypeLineItem = salesTypeMap.get(item.vlocity_cmt__RootItemId__c);
                item.TeliaSE_Root_Product__c=rootItemsMap.get(item.vlocity_cmt__RootItemId__c);
                if(salesTypeLineItem != null && salesTypeLineItem != '') item.TeliaSE_MC_Sales_Type__c=salesTypeLineItem;
                updateItems.add(item);
            }
        }
        if(updateItems.size()>0) update updateItems;
    }
    
    
    public static void updatePriceFlag(Map<String,Object> inputMap,Map<String,Object> outputMap,Map<String,Object> options){
        
        String rootItemId = (String)inputMap.get('rootItemId'),quoteId = (String)inputMap.get('quoteId'),qliId= (String)inputMap.get('qliId');
        QuoteLineItem qliRootItem = [SELECT Id, MC_Line_Status__c FROM QuoteLineItem WHERE vlocity_cmt__AssetReferenceId__c =:rootItemId];
        if(rootItemId != null){
            qliRootItem.MC_RootPriceFlag__c = true;
            if(qliRootItem.MC_Line_Status__c == 'Existing' || String.isBlank(qliRootItem.MC_Line_Status__c)) qliRootItem.MC_Line_Status__c = 'Updated';
            update qliRootItem;
        }
    }
    /* public static void saveBulkAntal (Map<String,Object> inputMap, Map<String,Object> outMap){
string quotelineId = String.ValueOf(inputMap.get('quotelineId'));
Integer BulkAntal= integer.ValueOf(inputMap.get('BulkAntal'));
List<QuoteLineItem> qlist = [select id,Quantity from QuoteLineItem where vlocity_cmt__RootItemId__c =:quotelineId];
QuoteLineItem parentqli = [Select id,TeliaSE_Fiber_Bulk_Antal__c from QuoteLineItem where id =:quotelineId];
try{        
if(BulkAntal !=null || BulkAntal != 0){
for(QuoteLineItem qline: qlist){
qline.Quantity = BulkAntal;
update qline;
}
parentqli.TeliaSE_Fiber_Bulk_Antal__c = BulkAntal;
update parentqli;
}
}
catch(Exception e)
{
outMap.put('Success',false);
outMap.put('errorMessage',e.getMessage());
} 
} */
    public static void AutoTaskQuoteSync(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {    
        if(!Test.isRunningTest()){
            new vlocity_cmt.CpqAppHandler().invokeMethod('priceCart', inputMap, outMap, outMap);
        }
        String ContextId = (String)inputMap.get('quoteId');
        List<QuoteLineItem> qliList = [select id, QuoteId,TeliaSE_Product_Object_Type__c from QuoteLineItem where QuoteId =:ContextId and TeliaSE_Product_Object_Type__c = 'ITDaaS Offer Spec'];
        if(qliList.size()>0){
            String procedureName = 'MassCustomized_APIGardenSync';
            /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
            inputMap.put('ContextId', ContextId);            
            /* Call the IP via runIntegrationService, and save the output to ipOutput */
            outMap = (Map<String,Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, inputMap, options);
        }
    }
    /*
* SALEF-5868
* Check for TOTAL Bas Product and attribute
*/ 
    public static void checkBasSubscriptionAndAttribute(Map<String,Object> inputMap, Map<String,Object> outMap){
        
        String quoteId = (String)inputMap.get('cartId'),qliId = (String)inputMap.get('qliId'); //,jsonAttribue;
        Boolean datanet = false,bas = false;
        Map<String,Object> modifiedJSON = new Map<String,Object>(); 
        
        List<QuoteLineItem> qliList = [Select Id,Product2.ProductCode,Product2.Name,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c,TeliaSE_Root_Product__c,TeliaSE_Root_Product__r.ProductCode from QuoteLineItem where (QuoteId =: quoteId) and (vlocity_cmt__RootItemId__c =:qliId) and (TeliaSE_Root_Product__r.ProductCode LIKE '%MOB_MULTI_TOTAL%' or TeliaSE_Root_Product__r.ProductCode LIKE '%MOB_DATA_PORTFOLIO%' or TeliaSE_Root_Product__r.ProductCode LIKE '%MOB_BAS%') order By vlocity_cmt__ParentItemId__c];
        if(qliList.size() > 0){     
            if(qliList[0].TeliaSE_Root_Product__r.ProductCode.contains('MOB_MULTI_TOTAL')){
                for(QuoteLineItem eachQli : qliList){
                    if(eachQli != null && eachQli.Product2.ProductCode.contains('MOB_DATA_PORTFOLIO')){
                        datanet = true;
                    }
                    if(eachQli != null && eachQli.Product2.ProductCode.contains('MOB_BAS')){
                        bas = true;
                    } 
                }       
            }     
        }
        //Commented since now datapaket bas atribute is hidden bcoz of framework pricing(By Abhishek)
        if((datanet && !bas) || (!datanet && bas)){
            outMap.put('Error',System.label.MC_BAS_ProdMissing);outMap.put('Success',false);            
        }else{
            outMap.put('Success',true);
        }
    }
    
    public static void priceCart(Map<String,Object> inputMap, Map<String,Object> outMap){
        new vlocity_cmt.CpqAppHandler().invokeMethod('priceCart', inputMap, outMap, outMap);
    }
    
    private static void updateFiberFields(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        try{
            Map<String,Object> input=(Map<String,Object>)inputMap.get('input');
            Id itemId = (Id)((Map<String,Object>)input.get('Id')).get('value');
            QuoteLineItem item = [SELECT Id FROM QuoteLineItem WHERE Id=:itemId];
            item.Fiber_Customer_Requested_Price__c = Double.valueOf(((Map<String,Object>)input.get('Fiber_Customer_Requested_Price__c')).get('value'));
            item.Quantity = Double.valueOf(((Map<String,Object>)input.get('Quantity')).get('value'));
            update item;
        }catch(Exception e){
            outMap.put('result',e.getMessage()); outMap.put('Success',false);          
            return;
        }
        outMap.put('Success',true);
    }
    
    public static void checkBenefitEligibility(Map<String, Object> inputs, Map<String, Object> output)
    {
        String objType = (String)inputs.get('qliObjType');
        String quoteId = (String)inputs.get('quoteId');
        String qliId = (String)inputs.get('qliId');
        String searchStr = '%'+objType+'%';
        Set<String> quoteObjTypes = new Set<String>();
        List<MC_Bundle_Benefits__mdt> bundlesList = [SELECT Id,MC_Object_Types__c,MC_Benefit__c
                                                     FROM MC_Bundle_Benefits__mdt 
                                                     WHERE MC_Object_Types__c LIKE :searchStr
                                                     AND MC_Active__c = true];
        if(bundlesList.isEmpty()){
            output.put('BenefitEligibility',false);
        }else{
            List<String> obTypes = bundlesList[0].MC_Object_Types__c.split(',');
            Set<Object> rootItems = new Set<Object>();
            List<Object> rootItemsList = new List<Object>();
            List<QuoteLineItem> qliList = [SELECT Id,vlocity_cmt__RootItemId__c,MC_Line_Status__c,TeliaSE_Product_Object_Type__c,MC_Benefit_Adjustment__c
                                           FROM QuoteLineItem
                                           WHERE TeliaSE_Product_Object_Type__c IN:obTypes 
                                           AND vlocity_cmt__ParentItemId__c = null
                                           AND QuoteId =: quoteId];
            Boolean reset = false;
            for(QuoteLineItem qli : qliList){
                quoteObjTypes.add(qli.TeliaSE_Product_Object_Type__c);
                if(qli.MC_Line_Status__c != 'Existing' || qli.Id == qliId){
                    rootItems.add(new Map<String,String>{'RootItemId'=>qli.vlocity_cmt__RootItemId__c});
                }
                if(qli.MC_Benefit_Adjustment__c != null && (qli.MC_Line_Status__c != 'Existing' || qli.Id == qliId)){
                    reset = true;
                    rootItems.add(new Map<String,String>{'RootItemId'=>qli.vlocity_cmt__RootItemId__c});
                }
            }
            rootItemsList.addAll(rootItems);
            if(quoteObjTypes.size() == obTypes.size()){
                output.put('Reset',false);
                output.put('RootItems',rootItemsList);
                output.put('Benefit',bundlesList[0].MC_Benefit__c);
            } else if(reset){
                output.put('Reset',true);
                output.put('RootItems',rootItemsList);
            } else{
                output.put('BenefitEligibility',false);
            }
        }
    }
}