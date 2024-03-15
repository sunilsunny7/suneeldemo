/********************************************************************************************************
* @description  This is an hook implementation of the open vlocity interface. It acts like a trigger handler
for the vlocity cpq api.
* @group     Vlocity Interface implementations
*********************************************************************************************************/
@TestVisible
global with sharing class CpqAppHandlerHookImplementation  implements vlocity_cmt.VlocityOpenInterface{    
    private static Set<String> itemFields = new Set<String> {'teliase_root_product__c','mc_sales_frameworkpricingmaster__c','product2.mc_product_negotiability__c','teliase_mc_binding_time__c','teliase_parentclustercode__c','product2.vlocity_cmt__specificationtype__c','teliase_fiber_frame_agreement__c','fiber_approved_price__c','teliase_fiber_antal__c','teliase_fiber_engngsavgift__c','teliase_fiber_list_pris__c','fiber_customer_requested_price__c', 'teliase_fiber_rabatt__c','vlocity_cmt__ParentItemId__c','vlocity_cmt__ProductHierarchyPath__c','vlocity_cmt__Product2Id__r.TeliaSE_Price_Flag__c','mc_line_status__c','teliase_target_price__c','teliase_mc_ot_priceplancode__c','teliase_mc_efs_pris__c','vlocity_cmt__billingaccountid__c','vlocity_cmt__serviceaccountid__c','quantity','vlocity_cmt__recurringtotal__c','vlocity_cmt__onetimetotal__c','vlocity_cmt__onetimemanualdiscount__c','vlocity_cmt__recurringmanualdiscount__c','vlocity_cmt__provisioningstatus__c','vlocity_cmt__recurringcharge__c','vlocity_cmt__onetimecharge__c','listprice','vlocity_cmt__parentitemid__c','vlocity_cmt__billingaccountid__r.name','vlocity_cmt__serviceaccountid__r.name','vlocity_cmt__premisesid__r.name','vlocity_cmt__incartquantitymap__c','vlocity_cmt__effectivequantity__c','teliase_ceiling_price__c','teliase_discount_percentage__c','teliase_floor_price__c','teliase_floor_percentage__c','teliase_mc_customer_requested_percentage__c','teliase_mc_customer_requested_price__c','teliase_approved_price__c','teliase_nullify_check__c','teliase_approved__c','teliase_flag__c','teliase_producttype__c','teliase_quote_recordtype__c','teliase_quotetemplateflag__c','teliase_product_service_code__c','quote.mc_mandate_adjustment__c','mc_convergence_quantity__c','quote.teliase_mc_sales_flow_identifier__c','teliase_product_code__c','teliase_offer_type__c',' teliase_pricetypecategory__c','mc_ot_am_mandate_percentage__c','mc_ot_sm_mandate_percentage__c','mc_ot_sd_mandate_percentage__c','mc_ot_cm_mandate_percentage__c','mc_onetimecharge__c','mc_ot_approved_price__c','teliase_comment__c','teliase_product_object_type__c','vlocity_cmt__product2id__r.mc_ot_negotiable_discount_percentage__c','mc_benefit_adjustment__c','mc_tpp_qa__c','product2.mc_tpp_read_only_coquantity__c','vlocity_cmt__onetimecalculatedprice__c','vlocity_cmt__recurringcalculatedprice__c','product2.teliase_product_category__c','teliase_pricetypecategory__c'};
        private static Set<String> priceDetailFields = new Set<String> {'teliase_mc_binding_time__c','mc_sales_frameworkpricingmaster__c','product2.mc_product_negotiability__c','teliase_parentclustercode__c','vlocity_cmt__ParentItemId__c','vlocity_cmt__ProductHierarchyPath__c','vlocity_cmt__Product2Id__r.TeliaSE_Price_Flag__c','mc_line_status__c','teliase_mc_ot_priceplancode__c','mc_ot_approved_price__c','teliase_offer_type__c','teliase_producttype__c','teliase_floor_percentage__c','teliase_sd_mandate_percentage__c','teliase_sm_mandate_percentage__c','teliase_am_mandate_percentage__c','teliase_product_object_type__c','vlocity_cmt__onetimecharge__c','vlocity_cmt__onetimemanualdiscount__c','vlocity_cmt__onetimecalculatedprice__c','vlocity_cmt__onetimetotal__c','vlocity_cmt__recurringcharge__c','vlocity_cmt__recurringcalculatedprice__c','vlocity_cmt__recurringtotal__c','teliase_ceiling_price__c','teliase_discount_percentage__c','teliase_floor_price__c','teliase_mc_customer_requested_price__c','teliase_mc_customer_requested_percentage__c','teliase_approved__c','teliase_approved_price__c','teliase_flag__c','teliase_target_price__c','mc_onetimecharge__c','vlocity_cmt__recurringmanualdiscount__c','listprice','teliase_nullify_check__c','teliase_quotetemplateflag__c','teliase_fiber_frame_agreement__c','teliase_mc_efs_pris__c','teliase_fiber_antal__c','teliase_fiber_engngsavgift__c','teliase_fiber_rabatt__c','mc_convergence_quantity__c','mc_ot_am_mandate_percentage__c','mc_ot_sm_mandate_percentage__c','mc_ot_sd_mandate_percentage__c','mc_ot_cm_mandate_percentage__c'};         
            public sObjectType lineItemTypeForPage;
    public sObjectType parentObjectTypeForPage;
    Boolean success = true;   
    // Invoked any time the CPQ APIs are invoked (e.g. adding something to cart, configuring item, updating price, etc)
    public Boolean InvokeMethod(String methodName, Map <String, Object> input,  Map<String, Object> output, Map <String,Object> options) {  
        try{
            // Catches "putCartsItems" (update attribute or update price), modifies output before returned to front end
            if(methodName.equalsIgnoreCase('putCartsItems.postInvoke')){
                putCartsItems_postInvoke(methodname, input, output, options);
                return true;
            }
            /*levelBasedApproach changes MCOnline - START*/
            if(methodName.equalsIgnoreCase('putCartsItems.preInvoke')){                
                putCartsItems_preInvoke(methodname, input, output, options);
                return true;
            }
            if(methodName.equalsIgnoreCase('postCartsItems.preInvoke')){
                postCartsItems_preInvoke(methodname, input, output, options);
                return true;
            }
            if(methodName.equalsIgnoreCase('getCartsItems.PreInvoke')){  
                String cartIdStr = (String) input.get('cartId');
                Id cartId = Id.valueOf(cartIdStr); 
                if(cartId.getSObjectType() == Quote.SObjectType){                     
                    input.put('fields', String.join(new List < String > (itemFields), ','));
                }
                return true;
            } 
            if(methodname.equalsIgnoreCase('getExpandedItems.PreInvoke')){
                putCartsItems_preInvoke(methodname, input, output, options);
                return true;
            }/*levelBasedApproach changes MCOnline - END*/
            if(methodName.equalsIgnoreCase('addAfterConfig.PreInvoke')){
                addAfterConfig_preInvoke(methodname, input, output, options);
                return true;
            }
            if(methodName.equalsIgnoreCase('addAfterConfig.postInvoke')){
                addAfterConfig_postInvoke(methodname, input, output, options);
                return true;
            }
            if(methodname.equalsIgnoreCase('postCartsItems.postInvoke')){
                postCartsItems_postInvoke(methodname, input, output, options);
                return true;
            }
            if(methodname.equalsIgnoreCase('getExpandedItems.postInvoke')){
                getExpandedItems_postInvoke(methodname, input, output, options);
                return true;
            }
            if(methodname.equalsIgnoreCase('deleteCartsItems.preInvoke')){
                boolean deleteFlag  =  deleteCartsItems_preInvoke(methodname, input, output, options);
                return deleteFlag;
            }
            if(methodname.equalsIgnoreCase('deleteCartsItems.postInvoke')){
                deleteCartsItems_postInvoke(methodname, input, output, options);
                return true;
            }
            if(methodname.equalsIgnoreCase('deleteFromBasket.PostInvoke')){
                deleteFromBasket_postInvoke(methodname, input, output, options);
                return true;
            }
            if(methodName.equalsIgnoreCase('applyAdjustment.preInvoke')){
                removePreviousAdjustments(methodname, input, output, options);                                
                return true;
            }                        
            if(methodName.equalsIgnoreCase('applyAdjustment.postInvoke')){
                addGetCartLineItemPricesAction(input, output, options);
            }
            if(methodname.equalsIgnoreCase('getCartsProducts.postInvoke')){
                Id cartId = (Id)input.get('cartId');
                Quote quote=[SELECT vlocity_cmt__PriceListId__r.name,TeliaSE_Record_Type_Name__c,TeliaSE_Comments__c,RecordType.name from Quote where id=:cartId];
                if(quote.TeliaSE_Record_Type_Name__c == 'Individual_Quote' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote_of_FA' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_FA_Quote' || test.isRunningTest()){
                    sortProducts(input, output,quote.vlocity_cmt__PriceListId__r.name);
                    return true;
                }
            }
            if(methodName == 'getCartLineItemPrices.PreInvoke'){                
                if((string)Input.get('itemId')!= null){
                    Id itemId = Id.valueOf((string)Input.get('itemId'));                    
                    vlocity_cmt.FlowStaticMap.flowMap.put('MC_Sales_AdjustmentID_Filter',new Set<Id> {itemId});
                    Set<String> itemFieldsResult = new Set<String>{'mc_line_status__c','teliase_mc_ot_priceplancode__c','mc_ot_approved_price__c','teliase_root_product__c','teliase_offer_type__c','teliase_producttype__c','teliase_floor_percentage__c','teliase_sd_mandate_percentage__c','teliase_sm_mandate_percentage__c','teliase_am_mandate_percentage__c','teliase_product_object_type__c','vlocity_cmt__onetimecharge__c','vlocity_cmt__onetimemanualdiscount__c','vlocity_cmt__onetimecalculatedprice__c','vlocity_cmt__onetimetotal__c','vlocity_cmt__recurringcharge__c','vlocity_cmt__recurringcalculatedprice__c','vlocity_cmt__recurringtotal__c','teliase_ceiling_price__c','teliase_discount_percentage__c','teliase_floor_price__c','teliase_floor_percentage__c','teliase_mc_customer_requested_price__c','teliase_approved_price__c','teliase_flag__c','teliase_target_price__c','mc_onetimecharge__c','TeliaSE_MC_FACallOffQuantity__c'};
                        input.put('priceDetailsFields', String.join(new List < String > (itemFieldsResult), ','));
                }else{
                    Quote quote=[SELECT vlocity_cmt__PriceListId__r.name,TeliaSE_Record_Type_Name__c,TeliaSE_Comments__c,RecordType.name from Quote where id=: ((Id)input.get('cartId'))];
                    if(quote.TeliaSE_Record_Type_Name__c == 'Individual_Quote' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote_of_FA' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_FA_Quote'){
                        Set<String> itemFieldsResult = new Set<String>{'vlocity_cmt__EffectiveOneTimeTotal__c','Fiber_Customer_Requested_Price__c', 'Fiber_Approved_Price__c', 'TeliaSE_fiber_Rabatt__c','TeliaSE_Flag__c','TeliaSE_Fiber_Frame_Agreement__c'};
                            input.put('priceDetailsFields', String.join(new List < String > (itemFieldsResult), ','));
                    }
                    else{
                        Set<String> itemFieldsResult = new Set<String>{'mc_line_status__c','teliase_mc_ot_priceplancode__c','mc_ot_approved_price__c','teliase_root_product__c','teliase_offer_type__c','teliase_producttype__c','teliase_floor_percentage__c','teliase_sd_mandate_percentage__c','teliase_sm_mandate_percentage__c','teliase_am_mandate_percentage__c','teliase_product_object_type__c','vlocity_cmt__onetimecharge__c','vlocity_cmt__onetimemanualdiscount__c','vlocity_cmt__onetimecalculatedprice__c','vlocity_cmt__onetimetotal__c','vlocity_cmt__recurringcharge__c','vlocity_cmt__recurringcalculatedprice__c','vlocity_cmt__recurringtotal__c','teliase_ceiling_price__c','teliase_discount_percentage__c','teliase_floor_price__c','teliase_floor_percentage__c','teliase_mc_customer_requested_price__c','teliase_approved_price__c','teliase_flag__c','teliase_target_price__c','mc_onetimecharge__c','TeliaSE_MC_FACallOffQuantity__c'};               
                            input.put('priceDetailsFields', String.join(new List < String > (itemFieldsResult), ','));
                    }
                }
                return true;
            }    
            if(methodName.equalsIgnoreCase('priceCart.preInvoke')){
                // List<Object> itemIds =(List<Object>) input.get('items');
                Set<Id> itemIdSet = new Set<Id>();
                for(Object obj: ((List<Object>) input.get('items'))){
                    itemIdSet.add((Id)obj);
                }
                vlocity_cmt.FlowStaticMap.flowMap.put('MC_Sales_AdjustmentID_Filter',itemIdSet);                
            }
            // GEORGII 18-Mar-2019: For Vaishali, we need to also catch api call getExpandedItems which is called when LevelBasedApproach is true and you expand an item
            // we should call another method and htat method should pass in fields/priceDetailsFields with our custom fields, similar to method putCartsItems_postInvoke  
            return false;
        }
        catch(Exception e){
            return false;
        }
    }
    
    private void removePreviousAdjustments(String methodName,Map <String, Object> input,Map<String, Object> output,Map <String,Object> options){
        Id itemId = Id.valueOf((string)Input.get('id'));
        Id cartId = (Id)input.get('cartId');
        vlocity_cmt.FlowStaticMap.flowMap.put('MC_AdjustmentId',itemId);
        QuoteLineItem qtLI=[SELECT TeliaSE_Quote_RecordType__c from QuoteLineItem where id =:itemId];             
        if(cartId.getSObjectType() == Quote.SObjectType &&  qtLI.TeliaSE_Quote_RecordType__c == 'Contract'){
            delete [SELECT id from vlocity_cmt__QuotePricingAdjustment__c where vlocity_cmt__QuoteItemId__c =:itemId];
            //Addition Code 21/12
            String cartIdStr = (String) input.get('cartId');         
            if(String.isNotBlank(cartIdStr)){
                if(!input.containsKey('fields') || !input.containsKey('priceDetailsFields')){                    
                    Set<String> itemFieldsResult = new Set<String> ();
                    Set<String> priceDetailsFieldsResult = new Set<String> ();
                    getItemFieldsForParams(cartIdStr, itemFieldsResult, priceDetailsFieldsResult);
                    if(!input.containsKey('fields') && !itemFieldsResult.isEmpty()){
                        input.put('fields', String.join(new List<String> (itemFieldsResult), ','));
                    }                
                    if(!input.containsKey('priceDetailsFields') && !priceDetailsFieldsResult.isEmpty()){
                        input.put('priceDetailsFields', String.join(new List<String> (priceDetailsFieldsResult), ','));
                    }
                }
            }
        }
    }
    
    @TestVisible
    private void getItemFieldsForParams(String cartIdStr,Set<String> itemFieldsResult,Set<String> priceDetailsFieldsResult){
        Id cartId = Id.valueOf(cartIdStr);
        String cartObjectName = cartId.getSObjectType().getDescribe().getName();
        Schema.SObjectType cartItemSObjectType;
        if(cartObjectName == 'Quote'){
            cartItemSObjectType = QuoteLineItem.sObjectType;
        }else if(cartObjectName == 'Order'){
            cartItemSObjectType = OrderItem.sObjectType;
        }else if (cartObjectName == 'Opportunity'){
            cartItemSObjectType = OpportunityLineItem.sObjectType;
        }
        if(cartItemSObjectType != null){
            Set<String> fieldMapKeys = cartItemSObjectType.getDescribe().fields.getMap().keySet();
            for(String fld: itemFields){
                if(fieldMapKeys.contains(fld.toLowerCase())){
                    itemFieldsResult.add(fld);
                }else{}
            }
            for(String fld: priceDetailFields){
                if(fieldMapKeys.contains(fld.toLowerCase())){
                    priceDetailsFieldsResult.add(fld);
                }
            }
        }
    }
    
    // postCartsItems update to catch "add to cart" event for later use in the pricing plan
    private void postCartsItems_preInvoke(String methodName,Map <String, Object> input, Map<String, Object> output,Map <String,Object> options){
        // to restrict duplicate product addition - added by Dipanwita 27 Feb 2019
        Map<String, Object> itemMap = (Map<String, Object>)((List<Object>)input.get('items'))[0];
        Id itemId = (Id)itemMap.get('itemId');
        Id cartId = (Id)input.get('cartId'); 
        if(cartId==null)return;
        if(cartId.getSobjectType() == Quote.sObjectType){
            input.put('fields', String.join(new List < String > (itemFields), ',')); 
            
            //Additional Check for B2B - prevent addition of CO products to FA cart(NewSales/Reneg) if B2BToggle is on
            Quote quote = [SELECT id,TeliaSE_Record_Type_Name__c,TeliaSE_MC_Sales_Flow_Identifier__c FROM Quote WHERE Id =:cartId LIMIT 1];
            if(quote.TeliaSE_Record_Type_Name__c == 'Contract' && System.label.B2BSolution_Toggle =='true'){
                validationForCOAdd(itemId, input);
            }
            //LTAART:51- check same offerings are not added to the cart for Tilläggsförhandling
            if(!itemMap.containsKey('parentId') && quote.TeliaSE_Record_Type_Name__c == 'Contract' && quote.TeliaSE_MC_Sales_Flow_Identifier__c == 'Tilläggsförhandling'){
                validationForTillaggsforhandling(itemId,cartId,input);
            }
        }
        input.put('addToCart',true);
        output.put('addToCart',true);
        options.put('addToCart',true);
        vlocity_cmt.FlowStaticMap.flowMap.put('CPQAction','postCartsItems');		
    }
    
    //MC SALES 23.3 -Additional Check for B2B - prevent addition of CO products to FA cart(NewSales/Reneg) if B2BToggle is on
    @TestVisible
    private void validationForCOAdd(Id itemId,Map <String, Object> input){
        PricebookEntry pbe = [SELECT id, ProductCode FROM PricebookEntry WHERE Id=:itemId LIMIT 1];
        if(pbe.ProductCode.startsWith('CO-') && pbe.ProductCode!='CO-HERA-ALL'){
            input.put('COAddFails', true);
            input.put('items',null);
            input.put('cartId',null);
        } 
    }
    //@Developer Name: Pancham Verma
    //LTAART-51: check same offerings are not added to the cart for Tilläggsförhandling
    private void validationForTillaggsforhandling(Id itemId,Id cartId,Map<String,Object> input){
        PricebookEntry pbe = [SELECT Product2.TeliaSE_Object_Type_Name__c FROM PricebookEntry WHERE Id=:itemId LIMIT 1];
        String excObjType,incObjType;
        String itemObjectType = pbe.Product2.TeliaSE_Object_Type_Name__c;
        
        //Get the exceptions offerings from custom metaData MC_TillagsforhandlingExceptionList__mdt
        List<MC_TillagsforhandlingExceptionList__mdt> exceptionList = [SELECT ValidScenario__c FROM MC_TillagsforhandlingExceptionList__mdt where label =: itemObjectType];
        if(exceptionList.size()>0){
            if(!exceptionList[0].validScenario__c){
                excObjType = itemObjectType;
            }
            else{
                incObjType = itemObjectType;
            }
        }
        //Query to check the products already present in cart
        Integer qliSize = [SELECT count() FROM QuoteLineItem WHERE (PricebookEntryId =: itemId OR TeliaSE_Product_Object_Type__c =: excObjType) AND TeliaSE_Product_Object_Type__c !=: incObjType AND MC_Line_Status__c = 'Existing' AND vlocity_cmt__ParentItemId__c = null AND QuoteId =: cartId ];
        if(qliSize >0){
            input.put('TillaggsforhandlingError',true);
            input.put('items',null);
            input.put('cartId',null);
        }
    }
    
    //this method gets the parent object type and the lineItem object type of the cart
    public void getObjectType(Id cartId){
        parentObjectTypeForPage = cartId.getSobjectType();        
        if(parentObjectTypeForPage == Quote.sObjectType){
            lineItemTypeForPage = QuoteLineItem.SObjectType; 
        }
    } 
    
    //postCartsItems update to catch "add to Cart" event for later use in the pricing plan
    private void postCartsItems_postInvoke(String methodname,Map<String,Object> input,Map<String, Object> output,Map <String,Object> options){
        if(input.get('COAddFails') != null && (Boolean)input.get('COAddFails')){
            output.remove('result');
            output.put('errorCode', 'INVOKE-500');
            output.put('error',System.label.MC_COChildAddError);
        }
        
        if(input.containsKey('TillaggsforhandlingError') && (Boolean)input.get('TillaggsforhandlingError')){    
            output.remove('result');
            output.put('errorCode', 'INVOKE-500');
            output.put('error',System.label.MC_TillagsforhandlingErrorMessage);
        }
    }
    
    // putCartsItems update to catch "update item" event for later use in the pricing plan
    // Method adds "fields" and "priceDetailsFields" parameters so API returns our custom fields and front-end will show the new values of custom fields
    private void putCartsItems_postInvoke(String methodName,Map <String, Object> input,Map<String, Object> output,Map <String,Object> options){
        Vlocity_cmt.JSONResult res = (Vlocity_cmt.JSONResult) output.get('result');
        vlocity_cmt.JSONAction priceAction = res.actions.get('itempricesupdated');        
        priceAction.remote.params.put('fields', String.join(new List < String > (itemFields), ','));
        priceAction.remote.params.put('priceDetailsFields', String.join(new List < String > (priceDetailFields), ','));        
    }  
    // Method adds "fields" and "priceDetailsFields" parameters so API returns our custom fields and front-end will show the new values of custom fields
    private void putCartsItems_preInvoke(String methodName,Map <String, Object> input,Map<String, Object> output,Map <String,Object> options){
        String cartIdStr = (String) input.get('cartId');
        Id cartId = Id.valueOf(cartIdStr); 
        if(cartId.getSObjectType() == Quote.SObjectType){                               
            input.put('fields',String.join(new List < String > (itemFields), ','));
            input.put('priceDetailsFields', String.join(new List < String > (priceDetailFields), ','));
        }        
    }
    // putCartsItems update to catch "update item" event for later use in the pricing plan
    // Method adds "fields" and "priceDetailsFields" parameters so API returns our custom fields and front-end will show the new values of custom fields
    private void getExpandedItems_postInvoke(String methodName,Map <String, Object> input,Map<String, Object> output,Map <String,Object> options){
        Vlocity_cmt.JSONResult res = (Vlocity_cmt.JSONResult) output.get('result');
        vlocity_cmt.JSONAction priceAction = res.actions.get('itempricesupdated');        
        String cartIdStr = (String) input.get('cartId');
        Id cartId = Id.valueOf(cartIdStr); 
        if(cartId.getSObjectType() == Quote.SObjectType){
            priceAction.remote.params.put('fields', String.join(new List < String > (itemFields), ','));
            priceAction.remote.params.put('priceDetailsFields', String.join(new List < String > (priceDetailFields), ','));
        }
    }
    // deleteCartsItems update to catch "add to cart" event for later use in the pricing plan // to prevent pricingplanmatrix call for delete event
    private boolean deleteCartsItems_preInvoke(String methodName,Map <String, Object> input,Map<String, Object> output,Map <String,Object> options){ 
        // Blocking deletion of items in inforhandling
        Id itemId = (Id)input.get('id');
        Id cartId = (Id)input.get('cartId'); 
        if(cartId==null) { return false; }
        if(cartId.getSobjectType() == Quote.sObjectType){
            //LTAT-22456 Bundle Benefit: Reset extra mandates on delete operation [AC3]
            //Added TeliaSE_Product_Object_Type__c Field for 22456
            QuoteLineItem qlpi=[SELECT TeliaSE_Product_Code__c,TeliaSE_Product_Object_Type__c, vlocity_cmt__ParentItemId__c,quote.TeliaSE_MC_Sales_Flow_Identifier__c, quote.TeliaSE_Record_Type_Name__c from QuoteLineItem where id =:itemId];  
            input.put('qliObjType', qlpi.TeliaSE_Product_Object_Type__c);

            if(qlpi.quote.TeliaSE_Record_Type_Name__c == 'Contract' && qlpi.vlocity_cmt__ParentItemId__c == NULL){
                input.put('callResetMandatesIP', true);
            } else {
                input.put('callResetMandatesIP', false);
            }


            if(qlpi.quote.TeliaSE_Record_Type_Name__c == 'Contract' && qlpi.quote.TeliaSE_MC_Sales_Flow_Identifier__c =='Inforhandling'){                
                input.put('InforhandlingFails', true);
                input.put('items',null);
                input.put('cartId',null);
                return false;
            }            
            else if(System.label.B2BSolution_Toggle=='true' && qlpi.TeliaSE_Product_Code__c.startsWith('CO-') && qlpi.vlocity_cmt__ParentItemId__c != NULL){
                input.put('CoDeleteFails', true);
                input.put('cartId',null);
                return false;
            }else{
                vlocity_cmt.FlowStaticMap.flowMap.put('CPQAction','deleteCartsItems');
                return true; 
            }
        }else{
            vlocity_cmt.FlowStaticMap.flowMap.put('CPQAction','deleteCartsItems');
            return true;
        }
    }
    
    private void addAfterConfig_preInvoke(String methodName,Map <String, Object> input,Map<String, Object> output,Map <String,Object> options){
    }
    //Reserve MSISDN after getting addToBasket response
    private void addAfterConfig_postInvoke(String methodName,Map <String, Object> input,Map<String, Object> output,Map <String,Object> options){        
        //processJSONforMSISDN(JSON.serialize(output));
    }
    private void deleteFromBasket_postInvoke(String methodName,Map <String, Object> input,Map<String, Object> output,Map <String,Object> options){
    }
    // deleteCartsItems update to catch exception
    private void deleteCartsItems_postInvoke(String methodname,Map<String,Object> input,Map<String, Object> output,Map <String,Object> options){
        // uncomment the below if block to restric addition of same product in cart
        if(input.get('InforhandlingFails') != null && (Boolean)input.get('InforhandlingFails')){           
            output.remove('result');
            output.put('errorCode', 'INVOKE-500');
            output.put('error',System.label.MC_InforhandlingDeletionError);
        } 
        if(input.get('CoDeleteFails') != null && (Boolean)input.get('CoDeleteFails')){           
            output.remove('result');
            output.put('errorCode', 'INVOKE-500');
            output.put('error',System.label.MC_COChildDeleteError);
        }
        
        if(input.get('callResetMandatesIP') == true) { 
            //LTAT-22456 Bundle Benefit: Reset extra mandates on delete operation [AC3]
            String procedureName = 'MC_Bundles_ManageBenefits';
            Map < String, Object > ipInput = new Map < String, Object >();
            Map < String, Object > ipOutput = new Map < String, Object >();
            Map < String, Object > ipOptions = new Map < String, Object >();
            /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */

            ipInput.put('qliId', input.get('id'));
            ipInput.put('quoteId', input.get('cartId'));
            ipInput.put('qliObjType',input.get('qliObjType'));
            ipInput.put('action', 'delete');
            
            /* Call the IP via runIntegrationService, and save the output to ipOutput */
            ipOutput = (Map<String,Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
            //Ends //LTAT-22456 Bundle Benefit: Reset extra mandates on delete operation [AC3]
        }
    }
    
    private void addGetCartLineItemPricesAction(Map<String, Object> inputMap,Map<String, Object> outputMap,Map<String, Object> optionsMap){ 
        Id itemId = (Id)vlocity_cmt.FlowStaticMap.flowMap.get('MC_AdjustmentId');
        if(!test.isRunningTest()){
            vlocity_cmt.JSONResult result = (vlocity_cmt.JSONResult) outputMap.get(vlocity_cmt.JSONResult.JSON_KEY_RESULT);
            if (result.actions == null || !result.actions.containsKey('itempricesupdated')){
                Id cartId = (Id) inputMap.get('cartId');
                if (cartId != null){
                    generateRefreshPriceAction(cartId, result, itemId);
                }
            }else if(result.actions != null && itemId !=null ){
                vlocity_cmt.JSONaction refreshPriceAction =  (vlocity_cmt.JSONAction)result.actions.get('itempricesupdated');
                if(refreshPriceAction!=null){
                    refreshPriceAction.remote.params.put('itemId', itemId);
                }
            }
        }
        
        //Change cart reprice flag on overrride price starts(By Abhishek)- Only for MC Sales cart
        Id quoteId = (Id) inputMap.get('cartId');
        if(quoteId !=null){
            String cartRecordType=([SELECT TeliaSE_Record_Type_Name__c from Quote where id= :quoteId])[0].TeliaSE_Record_Type_Name__c;
            if(cartRecordType!='' && cartRecordType=='Contract'){//To check only for MC Sales FA cart
                String procedureName = 'RepriceCart_ValideraPriser';
                Map < String, Object > ipInput = new Map < String, Object >();
                Map < String, Object > ipOutput = new Map < String, Object >();
                Map < String, Object > ipOptions = new Map < String, Object >();
                /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
                ipInput.put('quoteId', quoteId);
                ipInput.put('cartRepricedAfterValidera', true);
                /* Call the IP via runIntegrationService, and save the output to ipOutput */
                ipOutput = (Map<String,Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
            }
        }//Change cart reprice flag on overrride price ends(By Abhishek)- Only for MC Sales cart
    }
    
    public void generateRefreshPriceAction(Id cartId,vlocity_cmt.JSONResult itemsResult,Id itemId){
        vlocity_cmt.JSONAction refreshPriceAction = createJSONAction();
        String repriceCart;
        Boolean priceParam = false;
        if (vlocity_cmt.FlowStaticMap.flowMap != null){
            repriceCart = (String) vlocity_cmt.FlowStaticMap.flowMap.get('Pricing.RepriceCart');
        }
        if((repriceCart != null && repriceCart == 'true')|| test.isRunningTest()){
            priceParam = true; 
        }
        refreshPriceAction.remote.params.put('methodName', 'getCartLineItemPrices');
        refreshPriceAction.remote.params.put('cartId', cartId);
        if(itemId != null){
            refreshPriceAction.remote.params.put('itemId', itemId);
        }
        refreshPriceAction.remote.params.put('price', priceParam);
        refreshPriceAction.rest.method = 'GET';
        if(itemsResult != null){
            refreshPriceAction.rest.link = '/services/apexrest/vlocity_cmt/v2/cpq/carts/' + cartId +
                itemsResult.actions.put('itempricesupdated', refreshPriceAction);
        }
    }    
    
    public static void sortProducts(Map<String,Object> input,Map<String,Object> output,String priceListName)
    {
        List<String> prods;
        Map<String, String> favProductMap=new Map<String,String>();
        for(Fiber_Favorite_Products__mdt fav: ([SELECT Id, Label, FiberFavoriteProduct__c from Fiber_Favorite_Products__mdt])){
            favProductMap.put(fav.Label,fav.FiberFavoriteProduct__c);
        }
        switch on priceListName
        {
            when 'Halebop'{prods =new List<String>(favProductMap.get('FiberFavoriteHalebop').split(','));}
            when 'MDU'{prods =new List<String>(favProductMap.get('FiberFavoriteMDU').split(','));}
            when 'Zitius'{prods =new List<String>(favProductMap.get('FiberFavoriteZitius').split(','));}
            when 'SDU'{prods =new List<String>(favProductMap.get('FiberFavoriteSDU').split(','));}
        }        
        Vlocity_cmt.JSONResult res = (Vlocity_cmt.JSONResult) output.get('result');
        List<Vlocity_cmt.JSONRecord> newRecords=new List<Vlocity_cmt.JSONRecord>();
        List<Vlocity_cmt.JSONRecord> oldRecords=new List<Vlocity_cmt.JSONRecord>();
        List<Vlocity_cmt.JSONRecord> records= new List<Vlocity_cmt.JSONRecord>();
        if(res != null){
            records=(List<Vlocity_cmt.JSONRecord>)res.records;
        }        
        Map<string,object> newrecordmap = new Map<string,object>();        
        for(Vlocity_cmt.JSONRecord obj:records){
            if(prods.contains(String.valueOf(obj.fields.get('name')))){
                newrecordmap.put(String.valueOf(obj.fields.get('name')),obj);
            }else{
                oldRecords.add(obj);
            }
        }
        for(String prodname:prods){
            if(newrecordmap.containskey(prodname)){
                newRecords.add((Vlocity_cmt.JSONRecord)newrecordmap.get(prodname));
            }
        }
        newRecords.addAll(oldRecords);
        if(res!=null){
            res.records=newRecords;
        }
    }    
    
    private vlocity_cmt.JSONAction createJSONAction(){
        vlocity_cmt.VOIInvoker invoker = vlocity_cmt.VOIInvoker.getInstance();
        return (vlocity_cmt.JSONAction) invoker.invoke('vlocity_cmt.JSONAction', 'debugCreate', null, null, null);
    }
    global class CpqHookException extends Exception{}
}