global class MCOnline_ProcessBasketManagedFlow_V2 {
  /*global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    Boolean result = true;
      String error_message = '';
        try { 
             if(methodName.equalsIgnoreCase('SFCombineBasket')) {
                system.debug('inputMap : '+JSON.serialize(inputMap));
                MCONL_ProcessBasketManagedFlow_V2.checkout(inputMap, outMap);
            }else if(methodName.equalsIgnoreCase('ApplyAttributes')) {
                
            }
            else {
                result = false;
            }
            }catch(Exception e) {
                error_message = e.getMessage()+' line:'+ e.getLineNumber();
                system.debug(e.getStackTraceString());
                outMap.put('Error', e.getStackTraceString());
                outMap.put('StatusCode', 500);
                if(!Test.isRunningTest()){outMap.put('ErrorResponse', generateError('InternalServerError', inputMap));}
                
                 MCOnline_Utility.logError(error_message,'500','MCONLINE_CheckoutCompositeV0.3, MCONL_ProcessBasketManagedFlow_V2.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
            }
        return result;
    } */
    /* public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap){
        
        string options = JSON.serialize(inputMap.get('options'));
        system.debug('options : '+options);
        Map<String,Object> optionsMap = (Map<String,Object>)JSON.deserializeUntyped(options);
        string tscid = '';
        string userId = '';
        string agreementId = '';
        
        tscid = String.valueOf(optionsMap.get('tscid'));
        userId = String.valueOf(optionsMap.get('users'));
        agreementId = String.valueOf(optionsMap.get('agreementId'));
        if(String.isBlank(tscid) || String.isBlank(userId) || String.isBlank(agreementId)){
            tscid = String.valueOf(inputMap.get('tscid'));
            userId = String.valueOf(inputMap.get('users'));
            agreementId = String.valueOf(inputMap.get('agreementId'));
        }
         
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        string urlDetails = '{"Agreementid": "'+agreementId+'", "tscid":"'+tscid+'", "users":"'+userId+'"}';
        ipInputMap.put('functionality', 'Checkout');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        
        string str = String.valueOf(errorResponse.get('error'));
        str = str.replace('{number}', Label.MaximumBasketItemsAllowed);
        errorResponse.put('error', str);
        
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_CheckoutCompositeV0.3, MCONL_ProcessBasketV03.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return errorResponse;
    } */

    //Below Code will not work for release 1 records.
    public static void checkout (Map<String, Object> orderDetails, string OrderTSCID, string OrderAgreementId, string OrderUser){
    //public static void checkout(Map<String,Object> inputMap, Map<String,Object> outMap){
        //system.debug('inputMap.get("tscid")'+inputMap.get('tscid'));
        //string options = JSON.serialize(inputMap.get('options'));
        //system.debug('options : '+options);
        //Map<String,Object> optionsMap = (Map<String,Object>)JSON.deserializeUntyped(options);
        string tscid = OrderTSCID;
        string userId = OrderUser;
        string agreementId = OrderAgreementId;
        

        Map<string,set<string>> basketRelation = new Map<string,set<string>>();
        Map<string,List<String>> basketsToDisplay = new Map<string,List<string>>();
        // Map<string,List<Basket>> BasketsMap = new Map<string,List<Basket>>();
        List<Integer> basketRelCount = new List<Integer>();
        Set<String> miniBaskets = new Set<String>();
        //integer miniBasketCount;
        //integer BasketCount;
        //List<MCOnline_Basket__c> miniBasketList= new List<MCOnline_Basket__c>();
        //List<MCOnline_Basket__c> minibasketlistUpdate = new List<MCOnline_Basket__c>();

        //system.debug('TSCID==>'+tscid+'Users==>'+userId+'AgreementId==>'+agreementId);
        //system.debug('String.isBlank(tscid)==>'+String.isBlank(tscid)+'String.isBlank(userId)==>'+String.isBlank(userId)+'String.isBlank(agreementId)==>'+String.isBlank(agreementId));


        /*if(String.isBlank(tscid) || String.isBlank(userId) || String.isBlank(agreementId) || !(agreementId.length() == 15 || agreementId.length() == 18)){
            if(String.isBlank(tscid))
            {
                outMap.put('ErrorResponse', generateError('InvalidOrBlankTSCID', inputMap));
                outMap.put('StatusCode', 400);
            }
            else if(String.isBlank(userId))
            {
                outMap.put('ErrorResponse', generateError('InvalidOrBlankUser', inputMap));
                outMap.put('StatusCode', 400);
            }
            else if(String.isBlank(agreementId) || !(agreementId.length() == 15 || agreementId.length() == 18))
            {
                outMap.put('ErrorResponse', generateError('InvalidOrBlankAgreementId', inputMap));
                outMap.put('StatusCode', 400);
            }
            else
            {
            outMap.put('ErrorResponse', generateError('TSCIDandUserAreRequired', inputMap));
            outMap.put('StatusCode', 400);
            }
        } */
        //else if(!String.isBlank(tscid) && !String.isBlank(userId)){
            string query = 'SELECT Id, Is_Processed__c, Name, TSCID__c, OrderNumber__c, Account__c FROM MCOnline_ParentBasket__c where TSCID__c = \''+tscid+'\' and AgreementId__c = \''+agreementId+'\' AND Admin__c = \''+userId+'\' AND Is_Processed__c=false limit 1';
            List<MCOnline_ParentBasket__c> pBasketList = Database.query(query);
            //system.debug('tscid==>'+ tscid +'agreementId==>'+agreementId+'Admin==>'+userId);
            system.debug('query==>'+ pBasketList);
            if(pBasketList != null && pBasketList.size() > 0){

                List<MCOnline_Basket__c> basketList = [select id, Name,basket_Line_Relation_Count__c, Basket_Line_Relation_Id__c, MCOnline_Is_Processed__c,MCOnline_Message__c from MCOnline_Basket__c where MCOnline_ParentBasket__r.Id = :pBasketList[0].Id ];
            /*------Below Logic is for the validation of Basket Count and Basket Relation Id------*/
            /*------Basket with invalid Basket will not be Processed for Checkout-----------------*/
                /*for(MCOnline_Basket__c basketSFObj : basketList){
                    if(!basketRelation.containsKey(basketSFObj.Basket_Line_Relation_Id__c))
                    {
                        basketRelation.put(basketSFObj.Basket_Line_Relation_Id__c,new Set<String>{basketSFObj.Name});
                    }
                    else{
                        basketRelation.get(basketSFObj.Basket_Line_Relation_Id__c).add(basketSFObj.Name);
                    }
                } */               
                /*for(string relId : basketRelation.keySet()) //looping over the number of keys of the map, i.e, the basketRelationId
                {
                    miniBaskets = basketRelation.get(relId); // fetching the basket names corresponding to the relation id
                    miniBasketCount = miniBaskets.size();
                    BasketCount=0;
                    
                    for(string minibksts : miniBaskets){
                        for(MCOnline_Basket__c Obj : basketList){
                            if(Obj.Name == minibksts){
                                if(Obj.basket_Line_Relation_Count__c>BasketCount){ 
                                    BasketCount = Integer.ValueOf(Obj.basket_Line_Relation_Count__c); // logic to set the greatest basketRelationCont value, out of the ones having the same relationId
                                }
                            }                           
                        }
                    }
                    
                   /* for(string minibksts : miniBaskets) // looping over number of baskets
                    {
                        for(MCOnline_Basket__c basketSFObj : basketList){
                            if(basketSFObj.Name == minibksts) // checking if their names match , if match only then enter
                            {
                                if(BasketCount == miniBasketCount) // checking if the basketRelationCount on the basket matches the total basket count having the same basketRelation Id
                                {
                                    basketSFObj.MCOnline_Is_Processed__c = true;
                                    basketSFObj.MCOnline_Message__c = null;
                                    miniBasketList.add(basketSFObj);
                                    minibasketlistUpdate.add(basketSFObj);
                                }
                                else{
                                    basketSFObj.MCOnline_Message__c = 'Invalid_Basket_Count';
                                    minibasketlistUpdate.add(basketSFObj);
                                }
                            }
                        }
                    } 
                } */
                
                //update minibasketlistUpdate;
               /*-------------------------------------------------------------------------------------------*/
                if(Label.MaximumBasketItemsAllowed != null ){
                    Integer maxNum = Integer.valueOf(Label.MaximumBasketItemsAllowed);
                    if(basketList == null || basketList.size() == 0){

                        //outMap.put('ErrorResponse', generateError('NO_ITEMS_IN_BASKET', orderDetails));
                        MCOnline_Utility.logErrorWithoutFuture('There are no baskets to process ', 'NO_ITEMS_IN_BASKET','MCONLINE_ModifyBasket_V2,MCONLINE_ModifyBasket_V2.MCOnline_ProcessBasketManagedFlow_V2.Checkout','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(orderDetails),'','');
                        //outMap.put('StatusCode', 400);
                    } 
                    if(basketList != null && basketList.size() > maxNum){
                        //outMap.put('ErrorResponse', generateError('BasketItemsMoreThanExpected', orderDetails));
                        MCOnline_Utility.logErrorWithoutFuture('Basket Items more than '+maxNum+', order cannot be processed ', 'BasketItemsMoreThanExpected','MCONLINE_ModifyBasket_V2,MCONLINE_ModifyBasket_V2.MCOnline_ProcessBasketManagedFlow_V2.Checkout','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(orderDetails),'','');
                        //outMap.put('StatusCode', 400);
                    }else{
                        CheckoutWrapper cw = new CheckoutWrapper();
                        cw.BasketId = pBasketList[0].Id;
                        pBasketList[0].BasketStatus__c = 'Processing';
                        pBasketList[0].UpdateOrderRequest__c = JSON.serialize(orderDetails);
                        //cw.success = true;
                        //cw.BasketId = pBasketList[0].Id;
                        //cw.BasketName = pBasketList[0].Name;
                        //cw.TSCID = pBasketList[0].TSCID__c;
                        //cw.AccountId = pBasketList[0].Account__c;
                        //cw.OrderNumber = pBasketList[0].OrderNumber__c;
                        //cw.Message = 'Order is getting placed.';
                        update pBasketList;
                        //outMap.put('Response', JSON.serialize(cw));
                        //outMap.put('StatusCode', 200);
                        string order = pBasketList[0].OrderNumber__c;
                        string requestBody = JSON.serialize(orderDetails);
                        system.debug('requestBody--> '+requestBody);
                        SFCombineBasket(tscid, userId, order, requestBody, agreementId, pBasketList[0].Id);
                    }
                }
            }
            if(pBasketList == null || pBasketList.size() == 0){
                MCOnline_Utility.logErrorWithoutFuture('No Corresponding Basket Found. Please Check The Given TSCID and User', 'NoActiveBasketFound','MCONLINE_ModifyBasket_V2,MCONLINE_ModifyBasket_V2.MCOnline_ProcessBasketManagedFlow_V2.Checkout','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(orderDetails),'','');
                //outMap.put('ErrorResponse', generateError('NoActiveBasketFound', orderDetails));
                //outMap.put('StatusCode', 400);
            }
       // }
    }
    
    public class CheckoutWrapper{
        public boolean success {get; set;}
        public string BasketId {get; set;}
        public string BasketName {get; set;}
        public string TSCID {get; set;}
        public string AccountId {get; set;}
        public string OrderNumber {get; set;}
        public string Message {get; set;}
    }
    
    @future(callout=true)
    public static void SFCombineBasket(String tscid, string users, string orderNumber, string requestBody, string agreementId, Id basketId){

        MCOnline_ParentBasket__c parentBasketObj = [select Id, TSCID__c, Is_Processed__c, Account__c, (SELECT Name, MCOnline_AttributeJSON__c, Id, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c,MCOnline_Is_Processed__c, MCOnline_Contract__c,Basket_Line_Relation_Id__c,basket_Line_Relation_Count__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c FROM MCOnline_Basket__r) from  MCOnline_ParentBasket__c where Id = :basketId limit 1];
        
        Map<String, Object> basket1ResultMapParent = new Map<String, Object>();
        Map<String, Object> basket1ResultMapClone = new Map<String, Object>();
        List<MCOnline_Basket__c> release1minibasket = new List<MCOnline_Basket__c>();
        List<MCOnline_Basket__c> release2minibasket = new List<MCOnline_Basket__c>();
        

        List<Object> finalList = new List<Object>();
        
        string catalogCode = null;
        Set<Id> basketIdSet = new  Set<Id>();
        
        for(MCOnline_Basket__c basketSFObj : parentBasketObj.MCOnline_Basket__r){
            basketIdSet.add(basketSFObj.Id);
        }
        integer BasketCount;
        //Basket Relation Id Logic added directly, It might not work for release 1 records.(Need Testing)
        Map<string,set<string>> basketRelation = new Map<string,set<string>>();
        Map<string,List<String>> basketsToDisplay = new Map<string,List<string>>();
        // Map<string,List<Basket>> BasketsMap = new Map<string,List<Basket>>();
        List<Integer> basketRelCount = new List<Integer>();
        // error handling for mismatch of relation line count on baskets---- start
        for(MCOnline_Basket__c basketSFObj : parentBasketObj.MCOnline_Basket__r){    // loop to populate the Map basketRelation <String, set>
            if(!basketRelation.containsKey(basketSFObj.Basket_Line_Relation_Id__c))
            {
                basketRelation.put(basketSFObj.Basket_Line_Relation_Id__c,new Set<String>{basketSFObj.Name});
            }
            else{
                basketRelation.get(basketSFObj.Basket_Line_Relation_Id__c).add(basketSFObj.Name);
            }
        }
        
        Set<String> miniBaskets = new Set<String>();
        integer miniBasketCount;
        List<MCOnline_Basket__c> miniBasketList= new List<MCOnline_Basket__c>();
        Map<Id,Map<String, Attribute>> basketMap = new Map<Id,Map<String, Attribute>>();
        for(string relId : basketRelation.keySet()) //looping over the number of keys of the map, i.e, the basketRelationId
        {
            BasketCount=0;
            miniBaskets = basketRelation.get(relId); // fetching the basket names corresponding to the relation id
            miniBasketCount = miniBaskets.size();
            
            for(string minibksts : miniBaskets){
                for(MCOnline_Basket__c Obj : parentBasketObj.MCOnline_Basket__r){
                    if(Obj.Name == minibksts){
                        if(Obj.basket_Line_Relation_Count__c>BasketCount){ 
                            BasketCount = Integer.ValueOf(Obj.basket_Line_Relation_Count__c); // logic to set the greatest basketRelationCont value, out of the ones having the same relationId
                        }
                    }                           
                }
            }
            if(BasketCount==miniBasketCount){
            for(string minibksts : miniBaskets) // looping over number of baskets
            {
                for(MCOnline_Basket__c basketSFObj : parentBasketObj.MCOnline_Basket__r){
                    if(basketSFObj.Name == minibksts) // checking if their names match , if match only then enter
                    {
                        
                            if( basketSFObj != null && basketSFObj.MCOnline_AttributeJSON__c != null ){
                                
                                Map<String,Object> itemList = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                                List<Object> productList = new List<Object>();
                                productList = (List<Object>)itemList.get('products');
                                Map<String, Attribute> productMap = getLineItems(productList);
                                basketMap.put(basketSFObj.Id, productMap);
                                system.debug('basketMap==>'+basketMap);

                                miniBasketList.add(basketSFObj);
                                
                            }
                        }
                    }
                }
            }
            
        }
        if(miniBasketList!=null && miniBasketList.size()>0){
            Integer lineNumber = 0003;
            for(MCOnline_Basket__c basketSFObj : miniBasketList){
                

            string response = getBasketDetailsResponse(basketSFObj.MCOnline_Catalog__c, basketSFObj.MCOnline_Basket_Key__c, lineNumber);
            system.debug('line 135, response === '+response);
            lineNumber = lineNumber + 1;//SFCombineBasket
            Map<String, Object> basket1ResponseMap = null;
            if(response != null){
                basket1ResponseMap = ( Map<String, Object>)JSON.deserializeUntyped(response);
            }
            system.debug('line 144, basket1ResponseMap === '+basket1ResponseMap);
            if(basketSFObj.MCOnline_Catalog__c != null){
                catalogCode = basketSFObj.MCOnline_Catalog__c;
            }
            if(basket1ResponseMap != null){
                Map<String, Object> basket1ResultMap = ( Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(basket1ResponseMap.get('result')));
                if(basket1ResultMap != null){
                    List<Object> records1List = (List<Object>)basket1ResultMap.get('records');
                    if(records1List != null){
                        basket1ResultMapClone = ( Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(basket1ResponseMap.get('result')));
                        for(Object recObj1 : records1List){
                            List<Object> recordLevel2List = new List<Object>();
                            if(recObj1 != null){
                                Map<String, Object> recObj1Map = ( Map<String, Object>)recObj1;
                                Map<String, Object> recObj1MapClone = ( Map<String, Object>)recObj1;
                                Map<String, Object> lineItemsMap = ( Map<String, Object> )recObj1Map.get('lineItems');
                                Map<String, Object> lineItemsMapClone = ( Map<String, Object> )recObj1Map.get('lineItems');
                                List<Object> records2List = (List<Object>)lineItemsMap.get('records');
                                Map<String, Object> recObj2MapClone = new Map<String, Object>();
                                for(Object recObj2 : records2List){
                                    if(recObj2 != null){
                                        Map<String, Object> recObj2Map = ( Map<String, Object>)recObj2;
                                        recObj2MapClone = ( Map<String, Object>)recObj2;
                                        Map<String, Object> lineItems2Map = ( Map<String, Object> )recObj2Map.get('lineItems');
                                        Map<String, Object> lineItems2MapClone = ( Map<String, Object> )recObj2Map.get('lineItems');
                                        if(lineItems2Map != null){
                                        List<Object> recordLevel3List = new List<Object>();//lineItems2Map.get('records');
                                        List<Object> records3List = (List<Object>)lineItems2Map.get('records');
                                            List<Object> records3ListClone = new List<Object>();
                                            if(records3List != null){
                                                for(Object recObj3 : records3List){
                                                    if(recObj3 != null){
                                                        Map<String, Object> recObj3Map = ( Map<String, Object>)recObj3;
                                                        Map<String, Object> recObjClone3Map = ( Map<String, Object>)recObj3;
                                                        Map<String, Object> attributeCategoriesMap = ( Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(recObj3Map.get('attributeCategories')));
                                                        system.debug('basketMap==>'+basketMap);
                                                        system.debug('recObj3Map==>'+recObj3Map);
                                                        system.debug('attributeCategoriesMap==>'+attributeCategoriesMap);
                                                        if(basketMap != null && recObj3Map != null && attributeCategoriesMap != null){
                                                            recObj3Map.put('attributeCategories', null);
                                                            string productCode = String.valueOf(recObj3Map.get('ProductCode'));
                                                            Map<String, Object> modifiedAttributes = getAttributeCategories(attributeCategoriesMap, basketMap, productCode, basketSFObj);
                                                            recObj3Map.put('attributeCategories', modifiedAttributes);
                                                            System.debug('Addextraatt'+recObj3Map);
                                                            records3ListClone.add(recObj3Map);
                                                        }else{
                                                            records3ListClone.add(recObjClone3Map);
                                                        }
                                                    }
                                                }
                                            }
                                            lineItems2MapClone.put('records', null);
                                            lineItems2MapClone.put('records', records3ListClone);
                                            recObj2MapClone.put('lineItems', lineItems2MapClone);
                                            recordLevel2List.add(recObj2MapClone);
                                        }else{
                                            recordLevel2List.add(recObj2);
                                        }
                                    }
                                }
                                lineItemsMapClone.put('records', recordLevel2List);
                                recObj1MapClone.put('lineItems', lineItemsMapClone);
                                finalList.add(recObj1MapClone);
                            }
                        }
                    }
                }
            }
        }

        }

        if(basket1ResultMapClone != null){
            basket1ResultMapClone.put('records', null);
            basket1ResultMapClone.put('records', finalList);
            basket1ResultMapParent.put('accountId', parentBasketObj.Account__c);
            basket1ResultMapParent.put('catalogCode', catalogCode);
            basket1ResultMapParent.put('JSONResult', basket1ResultMapClone);
            if(basket1ResultMapParent != null){
                makeDCCheckout(JSON.serialize(basket1ResultMapParent), users, tscid, orderNumber, requestBody, agreementId, basketId);
            }
        }
    }
    public static void makeDCCheckout(string requestBody, string users, string tscid, string orderNumber, string requestBodyToBeUpdated, String agreementId, Id basketId){
        HttpRequest req=new HttpRequest();
        req.setMethod('POST');
        req.setBody(requestBody);
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        req.setEndpoint(System.Label.BaseUrl+'/services/apexrest/vlocity_cmt/v3/carts?price=true&validate=false');
        HttpResponse response = new HttpResponse();
        string checkoutResponseBody = '';
        if(!Test.isRunningTest()){
            response = new Http().send(req);
            if(response != null){
                checkoutResponseBody = response.getBody();
            }
        }else{
            checkoutResponseBody = BasketDetailsResponse_CalloutGenerator.checkoutResponse;
        }
        
        
        MCOnline_ParentBasket__c parentBasketObj = [select Id, TSCID__c, UpdateOrderRequest__c, CheckoutResponse__c, Order__c, Is_Processed__c, Account__c from  MCOnline_ParentBasket__c where Id=:basketId limit 1];
        Map<String, Object> checkoutResMap = null;
        if(checkoutResponseBody != null){
            checkoutResMap = (Map<String, Object>)JSON.deserializeUntyped(checkoutResponseBody);
            parentBasketObj.CheckoutResponse__c = checkoutResponseBody;
            parentBasketObj.BasketStatus__c = 'Success';
        }
        
        parentBasketObj.UpdateOrderRequest__c = requestBodyToBeUpdated;
        if(agreementId != null){
            parentBasketObj.AgreementId__c = Id.valueOf(agreementId);
        }
        //if(Limits.getHeapSize() < Limits.getLimitHeapSize()){
            //parentBasketObj.CheckoutRequest__c = requestBody;
        //}else{
            //parentBasketObj.CheckoutRequest__c = 'String is too long to show here.';
        //}
        string orderId = checkoutResMap != null ? String.valueOf(checkoutResMap.get('orderId')) : null;
        
        if(orderId == null && parentBasketObj != null){
            parentBasketObj.BasketStatus__c = 'Failed';
            parentBasketObj.CheckoutResponse__c = 'Checkout failed.';
            update parentBasketObj;
        }
        
        if(parentBasketObj != null && orderId != null && !Test.isRunningTest()){
            parentBasketObj.Order__c = orderId;
            update parentBasketObj;
            Order ordObj = [ select id, MCOnline_OrderNumber__c from Order where id=:orderId ];
            if(ordObj != null){
                ordObj.MCOnline_OrderNumber__c = orderNumber;
                update ordObj;
                //Userstory 7891
                MCONL_UpdateOrderItemParameter.updateParameter(requestBody, orderNumber);
                MCONL_OrderProcessor_V2.populateBND(ordObj.Id);
                invokeUpdateOrder_IntegrationProcedure(ordObj.Id, requestBodyToBeUpdated);
                
            }
        }
        
    }
    public static void invokeUpdateOrder_IntegrationProcedure(Id orderId, string requestBodyToBeUpdated){
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(requestBodyToBeUpdated);
        inputMap.put('orderId', orderId);
        System.enqueueJob(new UpdateOrderQueuable_V2(inputMap));
        /*
        if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
            System.enqueueJob(new UpdateOrderQueuableUAT(inputMap));
        }else{
            System.enqueueJob(new UpdateOrderQueuable(inputMap));
        }
        */
    }
    public static string getBasketDetailsResponse(string catalog, string contextKey, Integer lineNumber){
        HttpRequest req=new HttpRequest();
        req.setMethod('GET');
        req.SetTimeout(120000);
        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        req.setEndpoint(System.Label.BaseUrl+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalog+'/basket/'+contextKey);
        HttpResponse response = new HttpResponse();
        string body = '';
        if(!Test.isRunningTest()){
            response = new Http().send(req);
            if(response != null){
                body = response.getBody();
            }
        }else{
            body = BasketDetailsResponse_CalloutGenerator.body;
        }
        string newLineNumber = '"'+lineNumber;
        body = body != null ? body.replaceAll('"0001', newLineNumber) : '';
        system.debug(newLineNumber+'body ======== '+JSON.serialize(body));
        return body;
    }
    
    public static Map<String, Object> getAttributeCategories(Map<String, Object> attributeCategoriesMap, Map<Id,Map<String, Attribute>> basketMap, string productCode, MCOnline_Basket__c basketSFObj){
        if(attributeCategoriesMap != null){
            List<Object> attRecordList = (List<Object>)attributeCategoriesMap.get('records');
            Map<String, Object> attributeCategoriesMapClone = attributeCategoriesMap;
            List<Object> attRecordListClone = new List<Object>();
            for(Object recObj : attRecordList){
                if(recObj != null){
                Map<String, Object> recObjMap = ( Map<String, Object>)recObj;
                Map<String, Object> recObjMapClone = ( Map<String, Object>)recObj;
                Map<String, Object> productAttributesMap = ( Map<String, Object>)recObjMap.get('productAttributes');
                Map<String, Object> productAttributesMapClone = ( Map<String, Object>)recObjMap.get('productAttributes');
                List<Object> productAttributesRecordList = (List<Object>)productAttributesMap.get('records');
                List<Object> productAttributesRecordListClone = new List<Object>();
                for(Object productAttributesRecObj : productAttributesRecordList){
                    Map<String, Object> attributesRecObjMap = ( Map<String, Object>)productAttributesRecObj;
                    Map<String, Object> attributesRecObjMapClone = ( Map<String, Object>)productAttributesRecObj;
                    if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('MSISDN') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).MSISDN != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).MSISDN);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }
                    else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('User_name') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).UserName != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).UserName);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('TELIA_COMM_PERIOD')  && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).CommitmentPeriod != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).CommitmentPeriod);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('EXT_REF_ONLINE') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).ExternalReference != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).ExternalReference);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('ICC_number') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).ICCNumber != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).ICCNumber);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Email') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).Email != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).Email);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }
                    
                    else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('SIM_Format') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).simFormat != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).simFormat);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }
                    else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('BILLING_ACCOUNT') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).billingAccount != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).billingAccount);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }
                    else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('e-SIM_Method') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).simMethod != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).simMethod);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }
                    /*else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('MConline_Action_Code__c') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).actionCode != null){
                        attributesRecObjMapClone.put('userValues', null);
                        attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).actionCode);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }*/
                    else{
                        attributesRecObjMapClone.put('userValues', null);
                        productAttributesRecordListClone.add(attributesRecObjMapClone);
                    }
                }
                productAttributesMapClone.put('records', null);
                productAttributesMapClone.put('records', productAttributesRecordListClone);
                
                recObjMapClone.put('productAttributes', null);
                recObjMapClone.put('productAttributes', productAttributesMapClone);
                
                attRecordListClone.add(recObjMapClone);
            }
            }
            attributeCategoriesMapClone.put('records', null);
            attributeCategoriesMapClone.put('records', attRecordListClone);
            return attributeCategoriesMapClone;
        }else{
            return null;
        }
    }
     public static Map<String, Attribute> getLineItems(List<Object> items){
        Map<String, Attribute> productsMap = new Map<String, Attribute>();
        if(items != null){
            for(Object lineItemObj : items){
                Map<String, Object> recObj1Map = ( Map<String, Object>)lineItemObj;
                Map<String, Object> attributesMap = (Map<String, Object>)recObj1Map.get('attributes');
                if(attributesMap != null){
                    Product itemObj = new Product();
                    Attribute attributesObj = new Attribute();
                    itemObj.ProductCode = String.valueOf(recObj1Map.get('productCode'));
                    attributesObj.CommitmentPeriod = String.valueOf(attributesMap.get('commitmentPeriod'));
                    attributesObj.Email = String.valueOf(attributesMap.get('email'));
                    attributesObj.ExternalReference = String.valueOf(attributesMap.get('externalReference'));
                    attributesObj.ICCNumber = String.valueOf(attributesMap.get('ICCNumber'));
                    attributesObj.MSISDN = String.valueOf(attributesMap.get('MSISDN'));
                    attributesObj.ProductCode = String.valueOf(recObj1Map.get('productCode'));
                    //attributesObj.actionCode = String.valueOf(recObj1Map.get('Action_Code'));
                    attributesObj.UserName = String.valueOf(attributesMap.get('userName'));
                    attributesObj.simMethod = String.valueOf(attributesMap.get('eSIM_Method'));
                    attributesObj.simFormat = String.valueOf(attributesMap.get('SIM_Format'));
                    //attributesObj.billingAccount = String.valueOf(attributesMap.get('Billing Account Online'));
                    itemObj.Attributes = attributesObj;
                    productsMap.put(itemObj.ProductCode, attributesObj);
                }
            }
        }
        return productsMap;
     }
    
    public class Product{
        public Attribute Attributes{get; set;}
        public string ProductCode{get; set;}
    }
    
    public class Attribute{
        public string MCOnlineBasketLineItemName{get; set;}
        public string BasketId{get; set;}
        public string CommitmentPeriod{get; set;}
        public string Email{get; set;}
        public string ExternalReference{get; set;}
        public string ICCNumber{get; set;}
        public string MCOnline_lineItemKey{get; set;}
        public string MSISDN{get; set;}
        public string ProductCode{get; set;}
        public string UserName{get; set;}
        public string simMethod{get; set;}
        public string simFormat{get; set;}
        public string billingAccount{get; set;}
        //public string actionCode{get; set;}
     } 
}