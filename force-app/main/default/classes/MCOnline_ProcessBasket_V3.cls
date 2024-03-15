//Adding this line for merge conflict
/* ______________________________________________________________________________________________________
*  ******************************************************************************************************
*  This class is the remote class of the checkout API where the remote method SFCombineBasket is called.
*  This class allows the checkout API to process all eligible mini basket present in a parent Basket.
*  ______________________________________________________________________________________________________
*  @author         Binamra Guha <binamra.a.guha@capgemini.com>
*  @modifiedBy     
*  @maintainedBy   
*  @version        2.0
*  @created        2021-06-10
*  @modified
*  ______________________________________________________________________________________________________
*  ******************************************************************************************************
*/
global class MCOnline_ProcessBasket_V3 implements vlocity_cmt.VlocityOpenInterface2 
{
    public static Map<String, String> OrderUpdate = new Map<String, String>();
    public static Map<String, Object> CheckoutUpdate = new Map<String, Object>();
    public static Map<String, Map<String, Object>> inputMapgetOffer = new Map<String, Map<String, Object>>();
    public static Map<Set<String>, Map<String, Object>> inputMapaddtobasket = new Map<Set<String>, Map<String, Object>>();
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) 
    {
        Boolean result = true;
        String error_message = '';
        try 
        { 
            if(methodName.equalsIgnoreCase('SFCombineBasket')) 
            {
                system.debug('inputMap : '+JSON.serialize(inputMap));
                MCOnline_ProcessBasket_V3.checkout(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('ApplyAttributes')) {
                
            }
            else 
            {
                result = false;
            }
        }catch(Exception e) 
        {
            error_message = e.getMessage()+' line:'+ e.getLineNumber();
            system.debug(e.getStackTraceString());
            outMap.put('Error', e.getStackTraceString());
            outMap.put('StatusCode', 500);
            if(!Test.isRunningTest()){outMap.put('ErrorResponse', generateError('InternalServerError', inputMap));}
            
            MCOnline_Utility.logError(error_message,'500','MCONLINE_CheckoutComposite_V3, MCOnline_ProcessBasket_V3.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }
        return result;
    }
    /* _______________________________________________________________________________________________________
     * *******************************************************************************************************
     * This method is used for generating error for the invalid input(Error Handling Implemention 0.2 version).
     * _______________________________________________________________________________________________________
     * @param errorCode                            Passing Custom Error Code
     * @param inputMap                             Map containing the input coming from the user
     * _______________________________________________________________________________________________________
     * *******************************************************************************************************
    */
    public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap)
    {
        string options = JSON.serialize(inputMap.get('options'));
        system.debug('options : '+options);
        Map<String,Object> optionsMap = (Map<String,Object>)JSON.deserializeUntyped(options);
        string tscid = '';
        string userId = '';
        string agreementId = '';
        
        tscid = String.valueOf(optionsMap.get('tscid'));
        userId = String.valueOf(optionsMap.get('users'));
        agreementId = String.valueOf(optionsMap.get('agreementId'));
        if(String.isBlank(tscid) || String.isBlank(userId) || String.isBlank(agreementId))
        {
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
        
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_CheckoutComposite_V3, MCONL_ProcessBasket_V3.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return errorResponse;
    }
    
    //Below Code will not work for release 1 records.
    /* ___________________________________________________________________________________________________________
     * ***********************************************************************************************************
     * This method is used for the validating the input and giving the output.
     * This method also contains the error handling part which will be stored in outMap for displaying as response.
     * It also updates the parent basket fields with related related imformation. 
     * ___________________________________________________________________________________________________________
     * @param inputMap                                 Map containing the input coming from the user
     * @param outMap                                   Map that contains the output response
     * ___________________________________________________________________________________________________________
     * ***********************************************************************************************************
    */
    public static void checkout(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        string options = JSON.serialize(inputMap.get('options'));
        Map<String,Object> optionsMap = (Map<String,Object>)JSON.deserializeUntyped(options);
        string tscid = '';
        string userId = '';
        string agreementId = '';
        String orderId;
        Set<String> orderNumbers=new Set<String>();
        Set<String> basketRelationIdsForTransfer=new Set<String>();
        Map<String,List<MCOnline_Basket__c>> basketToOrderMap=new Map<String,List<MCOnline_Basket__c>>();
        //Getting the configurable Offers from custom setting for Split basket Logic
        Map<String, Checkout_Offer__c> offerMap = Checkout_Offer__c.getAll();
        String portIn = (offerMap.get('PORTIN_PROCESS').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS').OfferCode__c: null;
        String portInData = (offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c: null;
        String transferOffer = (offerMap.get('TRANSFER_PROCESS').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS').OfferCode__c: null;
        String transferOfferData = (offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c: null;
        
        
        Map<string,set<string>> basketRelation = new Map<string,set<string>>();
        Map<string,List<String>> basketsToDisplay = new Map<string,List<string>>();
        // Map<string,List<Basket>> BasketsMap = new Map<string,List<Basket>>();
        List<Integer> basketRelCount = new List<Integer>();
        Set<String> miniBaskets = new Set<String>();
        integer miniBasketCount;
        integer BasketCount;
        List<MCOnline_Basket__c> miniBasketList= new List<MCOnline_Basket__c>();
        List<MCOnline_Basket__c> minibasketlistUpdate = new List<MCOnline_Basket__c>();
        
        tscid = String.valueOf(optionsMap.get('tscid'));
        userId = String.valueOf(optionsMap.get('users'));
        agreementId = String.valueOf(optionsMap.get('agreementId'));
        system.debug('TSCID==>'+tscid+'Users==>'+userId+'AgreementId==>'+agreementId);
        system.debug('String.isBlank(tscid)==>'+String.isBlank(tscid)+'String.isBlank(userId)==>'+String.isBlank(userId)+'String.isBlank(agreementId)==>'+String.isBlank(agreementId));
        
        //Custom Error Handling Logic
        if(String.isBlank(tscid) || String.isBlank(userId) || String.isBlank(agreementId) || !(agreementId.length() == 15 || agreementId.length() == 18))
        {
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
        }else if(!String.isBlank(tscid) && !String.isBlank(userId))
        {
            List<MCOnline_ParentBasket__c> pBasketList=[SELECT Id, Is_Processed__c, Name, TSCID__c, OrderNumber__c, Account__c,(select id,Name,MCOnline_AttributeJSON__c,MCOnline_OfferCode__c,MCOnline_Is_Processed__c,MCOnline_Message__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c from MCOnline_Basket__r) FROM MCOnline_ParentBasket__c where TSCID__c =:tscid and Admin__c =:userId and AgreementId__c=:agreementId and Is_Processed__c=false AND flow__c='SALESFLOW' order by createddate desc limit 1];
            if(pBasketList != null && pBasketList.size() > 0)
            {
                /*
                * Below Logic is for the validation of Basket Count and Basket Relation Id
                * Basket with invalid Basket will not be Processed for Checkout
                */
                orderId=pBasketList[0].OrderNumber__c;
                List<MCOnline_Basket__c> basketList=pBasketList[0].MCOnline_Basket__r;
                for(MCOnline_Basket__c basketSFObj : basketList){
                    if(!basketRelation.containsKey(basketSFObj.Basket_Line_Relation_Id__c))
                    {
                        basketRelation.put(basketSFObj.Basket_Line_Relation_Id__c,new Set<String>{basketSFObj.Name});
                    }
                    else{
                        basketRelation.get(basketSFObj.Basket_Line_Relation_Id__c).add(basketSFObj.Name);
                    }
                }                
                for(string relId : basketRelation.keySet()) //looping over the number of keys of the map, i.e, the basketRelationId
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
                    
                    for(string minibksts : miniBaskets) // looping over number of baskets
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
                                    basketSFObj.MCOnline_Is_Processed__c = false;
                                    basketSFObj.MCOnline_Message__c = 'Invalid_Basket_Count';
                                    minibasketlistUpdate.add(basketSFObj);
                                }
                            }
                        }
                    }
                }
                update minibasketlistUpdate; //Updating the mini basket
                //Split Basket logic starts
                List<MCOnline_Basket__c> basketItems=miniBasketList;
                //Grouping the basket with Basket relation Id having OfferCode TRANSFER_PROCESS or TRANSFER_PROCESS_DATA
                for(MCOnline_Basket__c item:basketItems)
                {
                    if(item.MCOnline_OfferCode__c == transferOffer || item.MCOnline_OfferCode__c == transferOfferData)
                    {
                        basketRelationIdsForTransfer.add(item.Basket_Line_Relation_Id__c);
                    }
                }
                //Grouping the basket with Basket relation Id having OfferCode PORTIN_PROCESS or PORTIN_PROCESS_DATA
                for(MCOnline_Basket__c item:basketItems)
                {
                    if(item.MCOnline_OfferCode__c == portIn ||item.MCOnline_OfferCode__c == portInData)
                    {
                        basketToOrderMap.put(item.Basket_Line_Relation_Id__c+'PORTIN',new List<MCOnline_Basket__c>{item});
                        continue;
                    }
                    if(basketRelationIdsForTransfer.contains(item.Basket_Line_Relation_Id__c))
                    {
                        basketToOrderMap=addItemToBasketToOrder(basketToOrderMap,item,item.Basket_Line_Relation_Id__c+'TRANSFER');
                    }
                    else
                    {
                        basketToOrderMap=addItemToBasketToOrder(basketToOrderMap,item,'MIXED');
                    }
                }
                // The basketToOrderMap will have the minibasket list for each Split Order
                Integer i=0;
                // Incrementing the Order Number in Mini Basket Records
                for(String key:basketToOrderMap.keySet())
                {    
                    //i++;    
                    if(key == 'MIXED'){
                        for(MCOnline_Basket__c item:basketToOrderMap.get(key)){
                            item.order__c=orderId;
                            orderNumbers.add(orderId);
                        }   
                    }
                    else{
                        i++;
                        for(MCOnline_Basket__c item:basketToOrderMap.get(key))
                        {
                            item.order__c=orderId+'-'+i;
                            orderNumbers.add(orderId+'-'+i);
                        }
                    }                   
                    //orderNumbers.add(orderId+'-'+i);    
                }
                update basketItems;// Updating the Mini Basket
                List<String> OrderList = new List<String>(orderNumbers);
                OrderList.sort();
                //orderNumbers.sort();
                if(Label.MaximumBasketItemsAllowed != null )
                {
                    Integer maxNum = Integer.valueOf(Label.MaximumBasketItemsAllowed);
                    if(basketList == null || basketList.size() == 0 || miniBasketList == null || miniBasketList.size() == 0)
                    {
                        outMap.put('ErrorResponse', generateError('NO_ITEMS_IN_BASKET', inputMap));
                        outMap.put('StatusCode', 400);
                    }
                    else if(miniBasketList != null && miniBasketList.size() > maxNum)// Defect MCONL-12602 for invalid basket count
                    {
                        outMap.put('ErrorResponse', generateError('BasketItemsMoreThanExpected', inputMap));
                        outMap.put('StatusCode', 400);
                    }
                    else
                    {
                        CheckoutWrapper cw = new CheckoutWrapper();
                        cw.BasketId = pBasketList[0].Id;
                        pBasketList[0].BasketStatus__c = 'Processing';
                        pBasketList[0].UpdateOrderRequest__c = JSON.serialize(inputMap);
                        cw.success = true;
                        cw.BasketId = pBasketList[0].Id;
                        cw.BasketName = pBasketList[0].Name;
                        cw.TSCID = pBasketList[0].TSCID__c;
                        cw.AccountId = pBasketList[0].Account__c;
                        cw.OrderNumber = OrderList;
                        cw.Message = 'Order is getting placed.';
                        update pBasketList;
                        outMap.put('Response', JSON.serialize(cw));
                        outMap.put('StatusCode', 200);
                        string order = pBasketList[0].OrderNumber__c;
                        String basketOrderMapString= JSON.serialize(basketToOrderMap);
                        string requestBody = JSON.serialize(inputMap);
                        SFCombineBasket(tscid, userId, order, requestBody, agreementId,basketOrderMapString, pBasketList[0].Id);
                    }
                }
            }
            if(pBasketList == null || pBasketList.size() == 0)
            {
                outMap.put('ErrorResponse', generateError('NoActiveBasketFound', inputMap));
                outMap.put('StatusCode', 400);
            }
        }
    }
    
    public static List<String> checkout(Map<String, Object> orderDetails, string OrderTSCID, string OrderAgreementId, string OrderUser)
    {
        string tscid = OrderTSCID;
        string userId = OrderUser;
        string agreementId = OrderAgreementId;
        String orderId;
        Set<String> orderNumbers=new Set<String>();
        List<String> OrderList = new List<String>();
        List<MCOnline_Basket__c> miniBasketList= new List<MCOnline_Basket__c>();
        List<MCOnline_Basket__c> minibasketlistUpdate = new List<MCOnline_Basket__c>();
        Set<String> basketRelationIdsForTransfer=new Set<String>();
        Map<String,List<MCOnline_Basket__c>> basketToOrderMap=new Map<String,List<MCOnline_Basket__c>>();
        //Getting the configurable Offers from custom setting for Split basket Logic
        Map<String, Checkout_Offer__c> offerMap = Checkout_Offer__c.getAll();
        String portIn = (offerMap.get('PORTIN_PROCESS').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS').OfferCode__c: null;
        String portInData = (offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c: null;
        String transferOffer = (offerMap.get('TRANSFER_PROCESS').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS').OfferCode__c: null;
        String transferOfferData = (offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c: null;
        
        
        List<MCOnline_ParentBasket__c> pBasketList=[SELECT Id, Is_Processed__c, Name, TSCID__c, OrderNumber__c, Account__c,(select id,Name,MCOnline_AttributeJSON__c,MCOnline_OfferCode__c,MCOnline_Is_Processed__c,MCOnline_Message__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c from MCOnline_Basket__r) FROM MCOnline_ParentBasket__c where TSCID__c =:tscid and Admin__c =:userId and AgreementId__c=:agreementId and Is_Processed__c=false AND flow__c='MANAGEFLOW' order by createddate desc limit 1];
            if(pBasketList != null && pBasketList.size() > 0){
                orderId=pBasketList[0].OrderNumber__c;
                List<MCOnline_Basket__c> basketList=pBasketList[0].MCOnline_Basket__r;
                for(MCOnline_Basket__c basketSFObj : basketList){
                    basketSFObj.MCOnline_Is_Processed__c = true;
                    basketSFObj.MCOnline_Message__c = null;
                    miniBasketList.add(basketSFObj);
                    minibasketlistUpdate.add(basketSFObj);
                }
                update minibasketlistUpdate; //Updating the mini basket
                //Split Basket logic starts
                List<MCOnline_Basket__c> basketItems=miniBasketList;
                //Grouping the basket with Basket relation Id having OfferCode TRANSFER_PROCESS or TRANSFER_PROCESS_DATA
                for(MCOnline_Basket__c item:basketItems)
                {
                    if(item.MCOnline_OfferCode__c == transferOffer || item.MCOnline_OfferCode__c == transferOfferData)
                    {
                        basketRelationIdsForTransfer.add(item.Basket_Line_Relation_Id__c);
                    }
                }
                //Grouping the basket with Basket relation Id having OfferCode PORTIN_PROCESS or PORTIN_PROCESS_DATA
                for(MCOnline_Basket__c item:basketItems)
                {
                    if(item.MCOnline_OfferCode__c == portIn ||item.MCOnline_OfferCode__c == portInData)
                    {
                        basketToOrderMap.put(item.Basket_Line_Relation_Id__c+'PORTIN',new List<MCOnline_Basket__c>{item});
                        continue;
                    }
                    if(basketRelationIdsForTransfer.contains(item.Basket_Line_Relation_Id__c))
                    {
                        basketToOrderMap=addItemToBasketToOrder(basketToOrderMap,item,item.Basket_Line_Relation_Id__c+'TRANSFER');
                    }
                    else
                    {
                        basketToOrderMap=addItemToBasketToOrder(basketToOrderMap,item,'MIXED');
                    }
                }
                //Adding this line for merge conflict
                //Adding this line for merge conflict
                //Adding this line for merge conflict
                //Adding this line for merge conflict
                //Adding this line for merge conflict
                //Adding this line for merge conflict
                //Adding this line for merge conflict
                // The basketToOrderMap will have the minibasket list for each Split Order
                Integer i=0;
                // Incrementing the Order Number in Mini Basket Records
                for(String key:basketToOrderMap.keySet())
                {    
                    //i++;    
                    if(key == 'MIXED'){
                        for(MCOnline_Basket__c item:basketToOrderMap.get(key)){
                            item.order__c=orderId;
                            orderNumbers.add(orderId);
                        }   
                    }
                    else{
                        i++;
                        for(MCOnline_Basket__c item:basketToOrderMap.get(key))
                        {
                            item.order__c=orderId+'-'+i;
                            orderNumbers.add(orderId+'-'+i);
                        }
                    }
                }
                update basketItems;// Updating the Mini Basket
                OrderList = new List<String>(orderNumbers);
                OrderList.sort();
                if(Label.MaximumBasketItemsAllowed != null ){
                    Integer maxNum = Integer.valueOf(Label.MaximumBasketItemsAllowed);
                    if(basketList == null || basketList.size() == 0){
                        MCOnline_Utility.logErrorWithoutFuture('There are no baskets to process ', 'NO_ITEMS_IN_BASKET','MCONLINE_ModifyBasket_V2,MCONLINE_ModifyBasket_V2.MCOnline_ProcessBasketManagedFlow_V2POC.Checkout','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(orderDetails),'','');
                        } 
                    if(basketList != null && basketList.size() > maxNum){
                        MCOnline_Utility.logErrorWithoutFuture('Basket Items more than '+maxNum+', order cannot be processed ', 'BasketItemsMoreThanExpected','MCONLINE_ModifyBasket_V2,MCONLINE_ModifyBasket_V2.MCOnline_ProcessBasketManagedFlow_V2POC.Checkout','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(orderDetails),'','');
                    }
                    else{
                        pBasketList[0].BasketStatus__c = 'Processing';
                        pBasketList[0].UpdateOrderRequest__c = JSON.serialize(orderDetails);
                        update pBasketList;
                        string order = pBasketList[0].OrderNumber__c;
                        string requestBody = JSON.serialize(orderDetails);
                        String basketOrderMapString= JSON.serialize(basketToOrderMap);
                        SFCombineBasket(tscid, userId, order, requestBody, agreementId, basketOrderMapString, pBasketList[0].Id);
                    }
                }
            }
            if(pBasketList == null || pBasketList.size() == 0){
                MCOnline_Utility.logErrorWithoutFuture('No Corresponding Basket Found. Please Check The Given TSCID and User', 'NoActiveBasketFound','MCONLINE_ModifyBasket_V2,MCONLINE_ModifyBasket_V2.MCOnline_ProcessBasketManagedFlow_V2POC.Checkout','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(orderDetails),'','');  
            }
        return OrderList;
    } 
    
    private static Map<String,List<MCOnline_Basket__c>> addItemToBasketToOrder(Map<String,List<MCOnline_Basket__c>> basketToOrderMap,MCOnline_Basket__c item,String key)
    {
        if(basketToOrderMap.get(key)!= null)
        {
            basketToOrderMap.get(key).add(item);
        }
        else
        {
            basketToOrderMap.put(key,new List<MCOnline_Basket__c>{item});
        }
        return basketToOrderMap;
    }
    
    public class CheckoutWrapper
    {
        public boolean success {get; set;}
        public string BasketId {get; set;}
        public string BasketName {get; set;}
        public string TSCID {get; set;}
        public string AccountId {get; set;}
        public Object OrderNumber {get; set;}
        public string Message {get; set;}
    }
    /* ________________________________________________________________________________________________________
     * ********************************************************************************************************
     * SFCombineBasket is a future method, which is used for combining all the mini basket details associated 
       within a parent basket and create a map of Standard checkout request.
     * ________________________________________________________________________________________________________
     * @param tscid                                  TSCID value from the inputMap
     * @param users                                  User value from the inputMap
     * @param orderNumber                            Order number genarated from the parent basket
     * @param requestBody                            requestBody coming from the inputMap
     * @param agreementId                            Agreement Id value from the inputMap
     * @param basketOrderMapString                   Contains the grouped Basket Details
     * @param basketId                               Parent Basket Id
     * ________________________________________________________________________________________________________
     * ********************************************************************************************************
    */
    @future(callout=true)
    public static void SFCombineBasket(String tscid, string users, string orderNumber, string requestBody, string agreementId,String basketOrderMapString,Id basketId){
        
        String orderId;
        Map<String,Object> basketToOrderMap= (Map<String,Object>)JSON.deserializeUntyped(basketOrderMapString);
        MCOnline_ParentBasket__c parentBasketObj = [select Id, TSCID__c, Is_Processed__c, Account__c, (SELECT Name, MCOnline_AttributeJSON__c, Id, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c,Order__c,MCOnline_Is_Processed__c, MCOnline_Contract__c,Basket_Line_Relation_Id__c,basket_Line_Relation_Count__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c FROM MCOnline_Basket__r) from  MCOnline_ParentBasket__c where Id = :basketId limit 1];
        Map<Id, MCOnline_Basket__c> basketIdMap= new Map<Id, MCOnline_Basket__c>(parentBasketObj.MCOnline_Basket__r);
        Map<String, Object> basket1ResultMapParent = new Map<String, Object>();
        Map<String, Object> basket1ResultMapClone = new Map<String, Object>();
        
        
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
        // Below code is for getting the Attributes details
        Set<String> miniBaskets = new Set<String>();
        integer miniBasketCount;
        List<String> offerSet = new List<String>();
        Map<String, String> offerMapAttribute = new Map<String, String>();
        List<MCOnline_Basket__c> miniBasketList= new List<MCOnline_Basket__c>();
        Map<Id,Map<String, Attribute>> basketMap = new Map<Id,Map<String, Attribute>>();
        for(String key:basketToOrderMap.keySet()){
            List<Object> basketList = (List<Object>)basketToOrderMap.get(key);
            for(Object obj : basketList){
                Map<String, Object> basketSFObj1 = (Map<String, Object>)obj;
                MCOnline_Basket__c basketSFObj = basketIdMap.get(String.valueOf(basketSFObj1.get('Id')));
                if( basketSFObj != null && basketSFObj.MCOnline_AttributeJSON__c != null ){
                    Map<String,Object> itemList = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                    System.debug(String.valueOf(itemList));
                    Map<String, Object> mapOffer = new Map<String, Object>();
                    List<Object> productList = new List<Object>();
                    List<Object> productList1 = new List<Object>();
                    String basketRelId = '';
                    String minibasketName = '';
                    basketRelId = (basketSFObj.Basket_Line_Relation_Id__c != null) ? basketSFObj.Basket_Line_Relation_Id__c : null;
                    minibasketName = (basketSFObj.Name != null) ? basketSFObj.Name : null;
                    productList = (List<Object>)itemList.get('products');
                    mapOffer.put('productCode', String.valueOf(basketSFObj.MCOnline_OfferCode__c));
                    offerSet.add(String.valueOf(basketSFObj.MCOnline_OfferCode__c));
                    productList.add(mapOffer);
                    productList1 = (List<Object>)productList;
                    Map<String, Attribute> productMap = getLineItems(productList1,basketRelId, minibasketName);
                    basketMap.put(basketSFObj.Id, productMap);
                }
                
            }
        }
        for(Product2 prod: [Select id, ProductCode, vlocity_cmt__AttributeMetadata__c, vlocity_cmt__SpecificationType__c from Product2 Where ProductCode IN: offerSet AND vlocity_cmt__SpecificationType__c = 'Offer'])
        {
            if(prod.ProductCode != null && prod.vlocity_cmt__AttributeMetadata__c != null)
            {
                offerMapAttribute.put(prod.ProductCode, prod.vlocity_cmt__AttributeMetadata__c);
            }
        }
        MCOnline_OfferAttribute__mdt prodJSON = [Select id, OfferAttributeJSON__c from MCOnline_OfferAttribute__mdt LIMIT 1];
        System.debug(String.valueOf(basketMap));
        Integer lineNumber = 0003;
        for(String key:basketToOrderMap.keySet()){
            List<Object> basketList = (List<Object>)basketToOrderMap.get(key);
            for(Object obj : basketList){
                Map<String, Object> basketSFObj1 = (Map<String, Object>)obj;
                MCOnline_Basket__c basketSFObj = basketIdMap.get(String.valueOf(basketSFObj1.get('Id')));
                orderId = basketSFObj.Order__c;
                string response = getBasketDetailsResponse(basketSFObj.MCOnline_Catalog__c, basketSFObj.MCOnline_Basket_Key__c, lineNumber, basketSFObj);
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
                                    if(recObj1Map.get('attributeCategories') == null || recObj1Map.containskey('attributeCategories') == false)
                                    {
                                        if(offerMapAttribute != null && offerMapAttribute.containsKey(String.valueOf(recObj1Map.get('ProductCode'))))
                                        {
                                            recObj1Map.put('attributeCategories', (Map<String, Object>)JSON.deserializeUntyped(offerMapAttribute.get(String.valueOf(recObj1Map.get('ProductCode')))));
                                        }
                                        else{
                                            recObj1Map.put('attributeCategories', (Map<String, Object>)JSON.deserializeUntyped(prodJSON.OfferAttributeJSON__c));
                                        }
                                    }
                                    if(recObj1Map.containskey('attributeCategories') == true){
                                        Map<String, Object> attributeCategoriesMap2 = ( Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(recObj1Map.get('attributeCategories')));
                                        if(basketMap != null && recObj1Map != null && attributeCategoriesMap2 != null){
                                            recObj1Map.put('attributeCategories', null);
                                            string productCode = String.valueOf(recObj1Map.get('ProductCode'));
                                            Map<String, Object> modifiedAttributes2 = getAttributeCategories(attributeCategoriesMap2, basketMap, productCode, basketSFObj);
                                            recObj1Map.put('attributeCategories', modifiedAttributes2);
                                            recObj1MapClone = recObj1Map;
                                        }
                                    }
                                    Map<String, Object> lineItemsMap = ( Map<String, Object> )recObj1Map.get('lineItems');
                                    Map<String, Object> lineItemsMapClone = ( Map<String, Object> )recObj1Map.get('lineItems');
                                    List<Object> records2List = (List<Object>)lineItemsMap.get('records');
                                    List<Object> records2ListClone = new List<Object>();
                                    Map<String, Object> recObj2MapClone = new Map<String, Object>();
                                    for(Object recObj2 : records2List){
                                        if(recObj2 != null){
                                            Map<String, Object> recObj2Map = ( Map<String, Object>)recObj2;
                                            recObj2MapClone = ( Map<String, Object>)recObj2;
                                            if(recObj2Map.containskey('attributeCategories') == true){
                                                Map<String, Object> attributeCategoriesMap1 = ( Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(recObj2Map.get('attributeCategories')));
                                                if(basketMap != null && recObj2Map != null && attributeCategoriesMap1 != null){
                                                    recObj2Map.put('attributeCategories', null);
                                                    string productCode = String.valueOf(recObj2Map.get('ProductCode'));
                                                    Map<String, Object> modifiedAttributes1 = getAttributeCategories(attributeCategoriesMap1, basketMap, productCode, basketSFObj);
                                                    recObj2Map.put('attributeCategories', modifiedAttributes1);
                                                    records2ListClone.add(recObj2Map);
                                                }else{
                                                    records2ListClone.add(recObj2MapClone);
                                                }
                                                //lineItemsMapClone.put('records', null);
                                                lineItemsMapClone.put('records', records2ListClone);
                                                recObj1MapClone.put('lineItems', lineItemsMapClone);
                                                //recordLevel2List.add(recObj2MapClone);
                                            }
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
                                                recordLevel2List.add(recObj2Map);
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
            if(basket1ResultMapClone != null){
                basket1ResultMapClone.put('records', null);
                basket1ResultMapClone.put('records', finalList);
                basket1ResultMapParent.put('accountId', parentBasketObj.Account__c);
                basket1ResultMapParent.put('catalogCode', catalogCode);
                basket1ResultMapParent.put('JSONResult', basket1ResultMapClone);
                if(basket1ResultMapParent != null)
                {
                    makeDCCheckout(JSON.serialize(basket1ResultMapParent), users, tscid, orderId, requestBody, agreementId, basketId);
                }
            }
            basket1ResultMapParent.clear();
            finalList.clear();
        }
        //Calling UpdateBasket function for upadting the basket record after DC checkout
        UpdateBasket(OrderUpdate, CheckoutUpdate, requestBody, users, tscid, agreementId, basketId);
    }
    /* ________________________________________________________________________________________________________________________
     * ************************************************************************************************************************
     * This method is for doing the standard Checkout
     * ________________________________________________________________________________________________________________________
     * @param requestBody                                     Request Response for the eligible mini basket
     * @param users                                           User value from the inputMap
     * @param tscid                                           TSCID value from the inputMap
     * @param orderNumber                                     Order number genarated for each basket
     * @param requestBodyToBeUpdated                          requestBody coming from the inputMap
     * @param agreementId                                     AgreementId value from the inputMap
     * @param basketId                                        basketId of the parent Basket
     * ________________________________________________________________________________________________________________________
     * ************************************************************************************************************************
    */
    public static void makeDCCheckout(string requestBody, string users, string tscid, string orderNumber, string requestBodyToBeUpdated, String agreementId, Id basketId)
    {
        System.debug(requestBody);
        HttpRequest req=new HttpRequest();
        req.setMethod('POST');
        req.setBody(requestBody);
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        //req.setEndpoint(System.Label.BaseUrl+'/services/apexrest/vlocity_cmt/v3/carts?price=true&validate=false');
        req.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/vlocity_cmt/v3/carts?price=true&validate=false'); // System.Label.BaseUrl
        HttpResponse response = new HttpResponse();
        string checkoutResponseBody = '';
        if(!Test.isRunningTest())
        {
            response = new Http().send(req);
            if(response != null)
            {
                checkoutResponseBody = response.getBody();
            }
        }
        else
        {
            checkoutResponseBody = BasketDetailsResponse_CalloutGenerator.checkoutResponse;
        }
        System.debug(checkoutResponseBody);        
        Map<String, Object> checkoutResMap = (Map<String, Object>)JSON.deserializeUntyped(checkoutResponseBody);
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(requestBodyToBeUpdated);
        //Map<String, String> OrderUpdate = new Map<String, String>();
        //Map<String, Object> CheckoutUpdate = new Map<String, Object>();
        string orderId = String.valueOf(checkoutResMap.get('orderId'));
        if(orderId != null)
        {
        OrderUpdate.put(orderNumber, orderId);
        }
        CheckoutUpdate.put(orderNumber, checkoutResMap);
    }
    /* ________________________________________________________________________________________________________________________
     * ************************************************************************************************************************
     * This method for updating the parent Basket, Mini Basket and the Orders records.
     * ________________________________________________________________________________________________________________________
     * @param OrderUpdate                                     Map having the OrderNumber and OrderId
     * @param CheckoutUpdate                                  Map having the OrderNumber and Checkout Response
     * @param requestBodyToBeUpdated                          requestBody coming from the inputMap
     * @param users                                           User Value coming from the inputMap
     * @param tscid                                           TSCID Value coming from the inputMap
     * @param agreementId                                     AgreementId value from the inputMap
     * @param basketId                                        basketId of the parent Basket
     * ________________________________________________________________________________________________________________________
     * ************************************************************************************************************************
    */
    public static void UpdateBasket(Map<String, String> OrderUpdate, Map<String, Object> CheckoutUpdate, String requestBodyToBeUpdated, String users, String tscid, String agreementId, Id basketId)
    {
        MCOnline_ParentBasket__c parentBasketObj = [select Id,AgreementId__c, TSCID__c,BasketStatus__c, UpdateOrderRequest__c, CheckoutResponse__c, Order__c, Is_Processed__c, Account__c from  MCOnline_ParentBasket__c where Id=:basketId limit 1];
        parentBasketObj.UpdateOrderRequest__c = requestBodyToBeUpdated;
        parentBasketObj.BasketStatus__c = 'Success';
        if(agreementId != null)
        {
            parentBasketObj.AgreementId__c = Id.valueOf(agreementId);
        }
        Set<String> splitOrderId = new Set<String>();
        Set<String> ordernumberset = new Set<String>();
        List<String> OrderIdList = new List<String>();
        if(OrderUpdate == null && parentBasketObj != null)
        {
            parentBasketObj.BasketStatus__c = 'Failed';
            parentBasketObj.CheckoutResponse__c = 'Checkout failed.';
            update parentBasketObj;
        }
        List<MCOnline_Basket__c> miniBasketUpdate = new List<MCOnline_Basket__c>();
        if(parentBasketObj != null && OrderUpdate != null)
        {
            update parentBasketObj;// Updating parent Basket
            ordernumberset.addAll(new List<String>(OrderUpdate.keyset()));
            List<MCOnline_Basket__c> miniBasket = [Select Id, MCOnline_Orders__c, Order__c,MCOnline_CheckoutResponse__c From MCOnline_Basket__c Where Order__c IN:ordernumberset];
            for(MCOnline_Basket__c miniBaskt : miniBasket)
            {
                miniBaskt.MCOnline_Orders__c= Id.valueOf(OrderUpdate.get(miniBaskt.Order__c));
                miniBaskt.MCOnline_CheckoutResponse__c = String.valueOf(CheckoutUpdate.get(miniBaskt.Order__c));
                miniBasketUpdate.add(miniBaskt);
            }
            Database.update(miniBasketUpdate, false); //Updating Order Id and Checkout Response for each basket.
            for(String ord: ordernumberset)
            {
                splitOrderId.add(OrderUpdate.get(ord));
            }
            Id OrderID;
            String OrderNumber;
            List<Order> upOrder = new List<Order>();
            List<Order> ordObj = [ select id, MCOnline_OrderNumber__c from Order where id IN:splitOrderId ];
            for(Order ordObj1: ordObj)
            {
                for(String ord: ordernumberset)
                {
                    if(ordObj1.id == OrderUpdate.get(ord))
                    {
                        ordObj1.MCOnline_OrderNumber__c= ord;
                        OrderIdList.add(Id.valueOf(OrderUpdate.get(ord)));
                        OrderID= Id.valueOf(OrderUpdate.get(ord));
                        MCOnline_UpdateOrderItemParameter_V3.updateParameter(ord,OrderID);
                        MCOnline_OrderProcessor_V3.populateBND(OrderID);
                        upOrder.add(ordObj1);
                    }
                }
            }
            Database.update(upOrder, false);
            invokeUpdateOrder_IntegrationProcedure(OrderIdList, requestBodyToBeUpdated);
        }
    }
    public static void invokeUpdateOrder_IntegrationProcedure(List<String> OrderIdList, string requestBodyToBeUpdated)
    {
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(requestBodyToBeUpdated);
        string OrderIdSet = string.join(OrderIdList,',');
        inputMap.put('orderId', OrderIdSet);
        System.enqueueJob(new UpdateOrderQueuable_V3(inputMap));
    }
    public static string getBasketDetailsResponse(string catalog, string contextKey, Integer lineNumber, MCOnline_Basket__c basketSFObj){
        HttpRequest req=new HttpRequest();
        req.setMethod('GET');
        req.SetTimeout(120000);
        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        //req.setEndpoint(System.Label.BaseUrl+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalog+'/basket/'+contextKey);
        req.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalog+'/basket/'+contextKey); // System.Label.BaseUrl
        HttpResponse response = new HttpResponse();
        string body = '';
        String body1 = '';
        if(!Test.isRunningTest()){
            response = new Http().send(req);
            if(response != null){
                body = response.getBody();
            }
        }else{
            body = BasketDetailsResponse_CalloutGenerator.body;
        }
        Map<String, Object> getBasketStd = new Map<String, Object>();
        if(body != null)
        {
            getBasketStd = (Map<String, Object>)JSON.deserializeUntyped(body);
        }
        if(response != null && response.getStatusCode() == 200 && getBasketStd != null && getBasketStd.containsKey('errorCode') && String.valueOf(getBasketStd.get('errorCode')) != 'INVOKE-200')
        {
            String output;
            body1 = getOfferDetailsStd(basketSFObj, output);
        }else{
            body1 = body;
        }
        string newLineNumber = '"'+lineNumber;
        body1 = body1 != null ? body1.replaceAll('"0001', newLineNumber) : '';
        system.debug(newLineNumber+'body ======== '+JSON.serialize(body1));
        return body1;
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
                        //For PortIn and Transfer Offers
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Current_MSISDN') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).currentMSISDN != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).currentMSISDN);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Current_owner_Organization') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).currentOwnerOrganization != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).currentOwnerOrganization);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Portin_date') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).portinDate != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).portinDate);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Contact_telephone_number') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).contactTelephoneNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).contactTelephoneNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Current_owner_SSN') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).currentOwnerSSN != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).currentOwnerSSN);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Current_owner_email') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).currentOwnerEmail != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).currentOwnerEmail);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Requested_port_in_date') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).requestedPortInDate!= null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).requestedPortInDate);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Current_owner_org_name') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).currentOwnerOrgName!= null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).currentOwnerOrgName);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Current_owner_first_name') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).currentOwnerFirstName != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).currentOwnerFirstName);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Current_owner_last_name') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).currentOwnerLastName != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).currentOwnerLastName);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Temporary_MSISDN') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).temporaryMSISDN != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).temporaryMSISDN);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Document_id') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).documentId != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).documentId);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('ownerPhoneNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).ownerPhoneNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).ownerPhoneNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('User_email') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).userEmail != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).userEmail);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Relation_Id') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).basketRelationId != null){
                            attributesRecObjMapClone.put('userValues', null);
                            if(basketMap.get(basketSFObj.Id).get(productCode).basketName != null)
                            {
                                attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).basketRelationId+';'+basketMap.get(basketSFObj.Id).get(productCode).basketName);
                            }
                            else
                            {
                                attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).basketRelationId);
                            }
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('Användarnamn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).Anvandarnamn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).Anvandarnamn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('instanceId') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).instanceId != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).instanceId);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('roleCompanyAdmin') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).roleCompanyAdmin != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).roleCompanyAdmin);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('roleUser') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).roleUser != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).roleUser);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('callingLineType') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).callingLineType != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).callingLineType);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList1_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList1_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList1_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList1_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList1_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList1_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList2_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList2_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList2_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList2_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList2_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList2_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList3_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList3_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList3_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList3_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList3_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList3_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList4_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList4_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList4_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList4_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList4_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList4_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList5_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList5_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList5_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList5_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList5_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList5_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList6_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList6_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList6_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList6_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList6_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList6_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList7_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList7_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList7_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList7_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList7_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList7_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList8_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList8_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList8_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList8_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList8_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList8_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList9_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList9_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList9_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList9_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList9_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList9_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList10_cdgIdentifyingNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList10_cdgIdentifyingNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList10_cdgIdentifyingNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('agentList10_cdgAgentLoggedIn') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).agentList10_cdgAgentLoggedIn != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).agentList10_cdgAgentLoggedIn);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('fixedPhoneNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).fixedPhoneNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).fixedPhoneNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        //for MOB_COSTCONTRL_ABROAD
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('costControlAmount') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).costControlAmount != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).costControlAmount);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        //for MOB_INVOICE_SPLIT_A
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('firstName') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).firstName != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).firstName);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('lastName') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).lastName != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).lastName);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('street') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).street != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).street);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('streetNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).streetNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).streetNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('postalCode') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).postalCode != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).postalCode);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('city') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).city != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).city);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('country') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).country != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).country);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('pointid') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).pointid != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).pointid);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('entrance') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).entrance != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).entrance);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('appartmentNumber') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).appartmentNumber != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).appartmentNumber);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
                        else if(String.valueOf(attributesRecObjMap.get('code')).equalsIgnoreCase('careOf') && basketMap != null && basketMap.get(basketSFObj.Id) != null && basketMap.get(basketSFObj.Id).get(productCode) != null && basketMap.get(basketSFObj.Id).get(productCode).careOf != null){
                            attributesRecObjMapClone.put('userValues', null);
                            attributesRecObjMapClone.put('userValues', basketMap.get(basketSFObj.Id).get(productCode).careOf);
                            productAttributesRecordListClone.add(attributesRecObjMapClone);
                        }
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
    public static Map<String, Attribute> getLineItems(List<Object> items, String basketRelId, String minibasketName){
        Map<String, Attribute> productsMap = new Map<String, Attribute>();
        if(items != null){
            for(Object lineItemObj : items){
                Map<String, Object> recObj1Map = ( Map<String, Object>)lineItemObj;
                Map<String, Object> attributesMap = (Map<String, Object>)recObj1Map.get('attributes');
                if(recObj1Map != null){
                    Product itemObj = new Product();
                    Attribute attributesObj = new Attribute();
                    itemObj.ProductCode = String.valueOf(recObj1Map.get('productCode'));
                    attributesObj.basketRelationId = (basketRelId != null) ? basketRelId : null;
                    attributesObj.basketName = (minibasketName != null) ? minibasketName : null;
                    attributesObj.ProductCode = String.valueOf(recObj1Map.get('productCode'));
                    if(attributesMap != null){
                    attributesObj.CommitmentPeriod = (String.valueOf(attributesMap.get('commitmentPeriod')) != null) ? String.valueOf(attributesMap.get('commitmentPeriod')) : String.valueOf(attributesMap.get('Commitment_period'));
                    attributesObj.Email = (String.valueOf(attributesMap.get('email')) != null) ? String.valueOf(attributesMap.get('email')) : String.valueOf(attributesMap.get('Email'));
                    attributesObj.ExternalReference = (String.valueOf(attributesMap.get('externalReference')) != null) ? String.valueOf(attributesMap.get('externalReference')) : String.valueOf(attributesMap.get('External_reference'));
                    attributesObj.ICCNumber = (String.valueOf(attributesMap.get('ICCNumber')) != null) ? String.valueOf(attributesMap.get('ICCNumber')) : String.valueOf(attributesMap.get('ICC_number'));
                    attributesObj.MSISDN = String.valueOf(attributesMap.get('MSISDN'));
                    attributesObj.UserName = (String.valueOf(attributesMap.get('userName')) != null) ? String.valueOf(attributesMap.get('userName')): String.valueOf(attributesMap.get('User_name'));
                    attributesObj.simMethod = (String.valueOf(attributesMap.get('eSIM_Method')) !=null) ? String.valueOf(attributesMap.get('eSIM_Method')) : String.valueOf(attributesMap.get('e-SIM_Method'));
                    attributesObj.simFormat = String.valueOf(attributesMap.get('SIM_Format'));
                    //For PortIn and Transfer offers
                    attributesObj.currentMSISDN = (String.valueOf(attributesMap.get('currentMSISDN')) != null) ? String.valueOf(attributesMap.get('currentMSISDN')) : String.valueOf(attributesMap.get('Current_MSISDN'));
                    attributesObj.currentOwnerOrganization = (String.valueOf(attributesMap.get('currentOwnerOrganization')) != null) ? String.valueOf(attributesMap.get('currentOwnerOrganization')) : String.valueOf(attributesMap.get('Current_owner_Organization'));
                    attributesObj.portinDate = String.valueOf(attributesMap.get('portinDate'));
                    attributesObj.contactTelephoneNumber = (String.valueOf(attributesMap.get('contactTelephoneNumber')) != null) ? String.valueOf(attributesMap.get('contactTelephoneNumber')) : String.valueOf(attributesMap.get('Contact_telephone_number'));
                    attributesObj.currentOwnerSSN = (String.valueOf(attributesMap.get('currentOwnerSSN')) != null) ? String.valueOf(attributesMap.get('currentOwnerSSN')) : String.valueOf(attributesMap.get('Current_owner_SSN'));
                    attributesObj.currentOwnerEmail = (String.valueOf(attributesMap.get('currentOwnerEmail')) !=null) ? String.valueOf(attributesMap.get('currentOwnerEmail')):String.valueOf(attributesMap.get('Current_owner_email'));
                    attributesObj.requestedPortInDate= (String.valueOf(attributesMap.get('requestedPortInDate')) !=null) ? String.valueOf(attributesMap.get('requestedPortInDate')):String.valueOf(attributesMap.get('Requested_port_in_date'));
                    attributesObj.currentOwnerOrgName= (String.valueOf(attributesMap.get('currentOwnerOrgName')) !=null) ? String.valueOf(attributesMap.get('currentOwnerOrgName')):String.valueOf(attributesMap.get('Current_owner_org_name'));
                    attributesObj.currentOwnerFirstName = (String.valueOf(attributesMap.get('currentOwnerFirstName')) != null) ? String.valueOf(attributesMap.get('currentOwnerFirstName')) : String.valueOf(attributesMap.get('Current_owner_first_name'));
                    attributesObj.currentOwnerLastName = (String.valueOf(attributesMap.get('currentOwnerLastName'))!= null) ? String.valueOf(attributesMap.get('currentOwnerLastName')) : String.valueOf(attributesMap.get('Current_owner_last_name'));
                    attributesObj.ownerPhoneNumber = String.valueOf(attributesMap.get('ownerPhoneNumber'));
                    attributesObj.temporaryMSISDN = (String.valueOf(attributesMap.get('temporaryMSISDN')) != null) ? String.valueOf(attributesMap.get('temporaryMSISDN')) : String.valueOf(attributesMap.get('Temporary_MSISDN'));
                    attributesObj.documentId = String.valueOf(attributesMap.get('documentId'));
                    attributesObj.userEmail = String.valueOf(attributesMap.get('userEmail'));
                    //Touchpoint Product Configuration towards Order
                    attributesObj.Anvandarnamn = String.valueOf(attributesMap.get('Användarnamn'));
                    attributesObj.instanceId = String.valueOf(attributesMap.get('instanceId'));
                    attributesObj.roleCompanyAdmin = (String.valueOf(attributesMap.get('roleCompanyAdmin')) != null) ? Boolean.valueOf(String.valueOf(attributesMap.get('roleCompanyAdmin'))) : false;
                    attributesObj.roleUser = (String.valueOf(attributesMap.get('roleUser')) != null) ? Boolean.valueOf(String.valueOf(attributesMap.get('roleUser'))) : true;
                    attributesObj.callingLineType = String.valueOf(attributesMap.get('callingLineType'));
                    attributesObj.agentList1_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList1_cdgIdentifyingNumber'));
                    attributesObj.agentList1_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList1_cdgAgentLoggedIn'));
                    attributesObj.agentList2_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList2_cdgIdentifyingNumber'));
                    attributesObj.agentList2_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList2_cdgAgentLoggedIn'));
                    attributesObj.agentList3_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList3_cdgIdentifyingNumber'));
                    attributesObj.agentList3_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList3_cdgAgentLoggedIn'));
                    attributesObj.agentList4_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList4_cdgIdentifyingNumber'));
                    attributesObj.agentList4_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList4_cdgAgentLoggedIn'));
                    attributesObj.agentList5_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList5_cdgIdentifyingNumber'));
                    attributesObj.agentList5_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList5_cdgAgentLoggedIn'));
                    attributesObj.agentList6_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList6_cdgIdentifyingNumber'));
                    attributesObj.agentList6_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList6_cdgAgentLoggedIn'));
                    attributesObj.agentList7_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList7_cdgIdentifyingNumber'));
                    attributesObj.agentList7_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList7_cdgAgentLoggedIn'));
                    attributesObj.agentList8_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList8_cdgIdentifyingNumber'));
                    attributesObj.agentList8_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList8_cdgAgentLoggedIn'));
                    attributesObj.agentList9_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList9_cdgIdentifyingNumber'));
                    attributesObj.agentList9_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList9_cdgAgentLoggedIn'));
                    attributesObj.agentList10_cdgIdentifyingNumber = String.valueOf(attributesMap.get('agentList10_cdgIdentifyingNumber'));
                    attributesObj.agentList10_cdgAgentLoggedIn = String.valueOf(attributesMap.get('agentList10_cdgAgentLoggedIn'));
                    attributesObj.fixedPhoneNumber = String.valueOf(attributesMap.get('fixedPhoneNumber'));
                    //attributesObj.billingAccount = String.valueOf(attributesMap.get('Billing Account Online'));
                    //for MOB_COSTCONTRL_ABROAD
                    attributesObj.costControlAmount = String.valueOf(attributesMap.get('costControlAmount'));
                    //attribute for MOB_INVOICE_SPLIT_A
                    attributesObj.firstName = String.valueOf(attributesMap.get('firstName'));
                    attributesObj.lastName = String.valueOf(attributesMap.get('lastName'));
                    attributesObj.street = String.valueOf(attributesMap.get('street'));
                    attributesObj.streetNumber = String.valueOf(attributesMap.get('streetNumber'));
                    attributesObj.postalCode = String.valueOf(attributesMap.get('postalCode'));
                    attributesObj.city = String.valueOf(attributesMap.get('city'));
                    attributesObj.country = String.valueOf(attributesMap.get('country'));
                    attributesObj.pointid = String.valueOf(attributesMap.get('pointid'));
                    attributesObj.entrance = String.valueOf(attributesMap.get('entrance'));
                    attributesObj.appartmentNumber = String.valueOf(attributesMap.get('appartmentNumber'));
                    attributesObj.careOf = String.valueOf(attributesMap.get('careOf'));
                    }
                    itemObj.Attributes = attributesObj;
                    productsMap.put(itemObj.ProductCode, attributesObj);
                }
            }
        }
        return productsMap;
    }
    
    public static String getOfferDetailsStd (MCOnline_Basket__c cacherecord, String output)
    {
        Set<String> productCodelist = new Set<String>();
        String cartContextKey = '';
        String addtobasketresponse = '';
        Map<String, Object> remotemethodResponse = new Map<String, Object>();
        MCOnline_Basket__c basketDetails = (MCOnline_Basket__c)cacherecord;
        String catalog = String.valueOf(basketDetails.MCOnline_Catalog__c);
        String OfferCode = String.valueOf(basketDetails.MCOnline_OfferCode__c);
        if(basketDetails != null && basketDetails.MCOnline_AttributeJSON__c != null)
        {
            Map<String,Object> itemList1 = (Map<String,Object>)JSON.deserializeUntyped(basketDetails.MCOnline_AttributeJSON__c);
            List<Object> productList1 = (List<Object>)itemList1.get('products');
            for(Object obj: productList1)
            {
                Map<String, Object> recObj = ( Map<String, Object>)obj;
                if(recObj != null && recObj.containsKey('productCode') && recObj.get('productCode') != null)
                {
                    productCodelist.add(String.valueOf(recObj.get('productCode')));
                }
            }
        }
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> option = new Map<String, Object>();
        Map<String, Object> output2 = new Map<String, Object>();
        input.put('apiName','getOfferDetails');
        input.put('catalogCode',catalog);
        input.put('requestURL', '/v3/catalogs/'+catalog+'/offers/'+OfferCode);
        system.debug(JSON.serialize(input));
        //inputMapgetOffer.put(catalog+'-'+OfferCode, input);
        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
        if(inputMapgetOffer!= null && inputMapgetOffer.containsKey(catalog+'-'+OfferCode)){
            output2 = inputMapgetOffer.get(catalog+'-'+OfferCode);
            inputMapgetOffer.put(catalog+'-'+OfferCode, output2);
        }else{
            if(!Test.isRunningTest()){
                appHandler.invokeMethod('getOfferDetailsByCatalogCode', input, output2, option);
                inputMapgetOffer.put(catalog+'-'+OfferCode, output2);
            }
        }
        
        
        System.debug('Hi getOffer');
        System.debug(JSON.serialize(output2));
        while(output2.containskey('nexttransaction'))
        {
            Map<String, Object> next = (Map<String, Object>)output2.get('nexttransaction');
            Map<String,Object> rest = (Map<String, Object>)next.get('rest');
            Map<String,Object> params = (Map<String, Object>)rest.get('params');
            String multiTransactionKey = (String)params.get('multiTransactionKey');
            input.put('multiTransactionKey',multiTransactionKey);
            if(!Test.isRunningTest())
            {
                appHandler.invokeMethod('getOfferDetailsByCatalogCode', input, output2, option);
                inputMapgetOffer.put(catalog+'-'+OfferCode, output2);
            }
        }
        //system.debug('std getOfferDetails--> '+JSON.serialize(output));   
        
        /*HttpRequest req=new HttpRequest();
        req.setMethod('GET');
        req.SetTimeout(120000);
        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        req.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalog+'/offers/'+OfferCode); // System.Label.BaseUrl
        HttpResponse response = new HttpResponse();
        string body = '';
        if(!Test.isRunningTest())
        {
            response = new Http().send(req);
            if(response != null)
            {
                body = response.getBody();
            }
        }else
        {
            body = output;
        }
        System.debug(body);*/
        Map<String, Object> getOfferDetailsResponse = new Map<String, Object>();
        if(output2 != null && !Test.isRunningTest())
        {
            getOfferDetailsResponse = output2;
        }else{
            getOfferDetailsResponse = (Map<String,Object>)JSON.deserializeUntyped(output);
        }
        if(getOfferDetailsResponse != null)
        {
            Map<String, Object> output1 = new Map<String, Object>();
            string ContextKey = String.valueof(getOfferDetailsResponse.get('contextKey'));
            Map<String, Object> tempMap = (Map<String, Object>)getOfferDetailsResponse.get('result');
            Map<String,Object> offerDetails=(Map<String,Object>)tempMap.get('offerDetails');
            Map<String,Object> offer1=(Map<String,Object>)offerDetails.get('offer');
            makeQuantityZero(offer1);
            Map<String,Object> offer=(Map<String,Object>)offer1;
            //for(String productCode: productCodelist)
            //{
              //  addToBasketStdMap(offer, productCode);
            //}
            addToBasketStdMap(offer, productCodelist);
            Map<String, Object> productConfigMap1 = new Map<String, Object>();
            productConfigMap1 = (Map<String, Object>)tempMap;
            removeItems(productConfigMap1);
            Map<String, Object> productConfigMap = new Map<String, Object>();
            productConfigMap = (Map<String, Object>)productConfigMap1;
            if(inputMapaddtobasket != null && inputMapaddtobasket.containsKey(productCodelist)){
                remotemethodResponse = inputMapaddtobasket.get(productCodelist);
                inputMapaddtobasket.put(productCodelist, remotemethodResponse);
            }else{
                remotemethodResponse=addToBasketStd(ContextKey, JSON.serialize(productConfigMap), catalog);
                inputMapaddtobasket.put(productCodelist, remotemethodResponse);
            }
            addtobasketresponse = JSON.serialize(remotemethodResponse);
        }
        return addtobasketresponse;
    }
    public static void makeQuantityZero(Object offer)
    {
        Map<String,Object> tempMap=(Map<String,Object>)offer;
        if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
        {
            List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
            for(Object obj3:childProducts)
            {
                Map<String,Object> tempMap1=(Map<String,Object>)obj3;
                if(tempMap1 != null && tempMap1.containsKey('ProductCode') && (tempMap1.containsKey('childProducts') == false || tempMap1.get('childProducts') == null))
                {
                    tempMap1.put('Quantity', 0.0);
                }
                if(tempMap1.containsKey('childProducts') && tempMap1.get('childProducts') != null)
                {
                    List<Object> childProducts1=(List<Object>)tempMap1.get('childProducts');
                    for(Object obj4:childProducts1)
                    {
                        Map<String,Object> tempMap2=(Map<String,Object>)obj4;
                        if(tempMap2 != null && tempMap2.containsKey('ProductCode') && (tempMap2.containsKey('childProducts') == false || tempMap2.get('childProducts') == null))
                        {
                            tempMap2.put('Quantity', 0.0);
                        }
                    }
                }
            }
        }               
    }
    public static void addToBasketStdMap(Object offer, Set<String> productCode)
    {
        Map<String,Object> tempMap=(Map<String,Object>)offer;
        if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
        {
            List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
            for(Object obj3:childProducts)
            {
                Map<String,Object> tempMap1=(Map<String,Object>)obj3;
                if(tempMap1 != null && tempMap1.containsKey('ProductCode') && productCode.contains(String.valueOf(tempMap1.get('ProductCode'))) && (tempMap1.containsKey('childProducts') == false || tempMap1.get('childProducts') == null))
                {
                    tempMap1.put('Quantity', 1.0);
                }
                if(tempMap1.containsKey('childProducts') && tempMap1.get('childProducts') != null)
                {
                    List<Object> childProducts1=(List<Object>)tempMap1.get('childProducts');
                    for(Object obj4:childProducts1)
                    {
                        Map<String,Object> tempMap2=(Map<String,Object>)obj4;
                        if(tempMap2 != null && tempMap2.containsKey('ProductCode') && productCode.contains(String.valueOf(tempMap2.get('ProductCode'))) && (tempMap2.containsKey('childProducts') == false || tempMap2.get('childProducts') == null))
                        {
                            tempMap2.put('Quantity', 1.0);
                        }
                    }
                }
            }
        }
    }
    public static Map<String, Object> addToBasketStd(String ContextKey, String productConfigMap, String catalog)
    {
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        String methodName = 'addAfterConfig';
        input.put('apiName','basketOperations');
        input.put('catalogCode', catalog);
        input.put('productConfig', (Map<String, Object>)JSON.deserializeUntyped(productConfigMap));
        input.put('methodName', 'addAfterConfig');
        input.put('requestURL', '/v3/catalogs/'+catalog+'/basket');
        input.put('contextKey', ContextKey);
        //input.put('forceinvalidatecache','true');
        input.put('price', false);

        //remote action invocation
        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
        if(!Test.isRunningTest()){
            appHandler.invokeMethod(methodName, input, output, options);
        }
        
        while(output.containskey('nexttransaction'))
        {
            Map<String, Object> next = (Map<String, Object>)output.get('nexttransaction');
            Map<String,Object> rest = (Map<String, Object>)next.get('rest');
            Map<String,Object> params = (Map<String, Object>)rest.get('params');
            String multiTransactionKey = (String)params.get('multiTransactionKey');
            input.put('multiTransactionKey',multiTransactionKey);
            if(!Test.isRunningTest())
            {
                appHandler.invokeMethod(methodName, input, output, options);
                
            }
        }
        System.debug(JSON.serialize(output));
        return output;
    }
    
    //Below method will remove the bundles and childproducts having quantity 0
    public static void removeItems(Object obj){
        
        Map<String, Object> tempMap1 = (Map<String, Object>)obj;
        Map<String,Object> offerDetails=(Map<String,Object>)tempMap1.get('offerDetails');
        Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
        if(offer.containsKey('childProducts'))
        {
            List<Object> childProducts=(List<Object>)offer.get('childProducts');
            for(Integer j = childProducts.size() - 1; j >= 0; j--)
            {
                Map<String, Object> tempMap2 = (Map<String, Object>)childProducts.get(j);
                if(tempMap2.containsKey('childProducts')){
                    List<Object> childProducts1=(List<Object>)tempMap2.get('childProducts');
                    for(Integer i = childProducts1.size() - 1; i >= 0; i--){
                        Map<String, Object> tempMap3 = (Map<String, Object>)childProducts1.get(i);
                        if(tempMap3.containsKey('Quantity')){
                            if(Integer.Valueof(tempMap3.get('Quantity'))==0){
                                childProducts1.remove(i);
                            }
                        }
                    }                
                    if(childProducts1.isEmpty()){
                        childProducts.remove(j);
                    }
                }
            }
        }
        Map<String,Object> offer1=(Map<String,Object>)offer;
        addCommitment(offer1);
    }
    
    //below method is for adding the 24 and 36 commitment period if not there 
    public static void addCommitment(Object obj)
    {
        Map<String, Object> tempMap = (Map<String, Object>)obj;
        if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
        {
            List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
            for(Object obj3:childProducts)
            {
                addCommitment(obj3);
            }
        }
        if(tempMap.containsKey('AttributeCategory') && tempMap.get('AttributeCategory') != null)
        {
            Map<String,Object> tempMap1=(Map<String,Object>)tempMap.get('AttributeCategory');
            if(tempMap1.containsKey('records') && tempMap1.get('records') != null){
                List<Object> attrRecords=(List<Object>)tempMap1.get('records');
                for(Object obj2:attrRecords)
                {
                    Map<String,Object> tempMap2=(Map<String,Object>)obj2;
                    if(tempMap2.containsKey('productAttributes') && tempMap2.get('productAttributes') != null){
                        Map<String,Object> tempMap3=(Map<String,Object>)tempMap2.get('productAttributes');
                        if(tempMap3.containsKey('records') && tempMap3.get('records') != null){
                            List<Object> prodAttrRecords=(List<Object>)tempMap3.get('records');
                            for(Object obj1:prodAttrRecords)
                            {
                                addCommitment(obj1);
                            }
                        }
                    }
                }
            }
        }
        if(String.valueOf(tempMap.get('code')) == 'TELIA_COMM_PERIOD')
        {            
            if(tempMap.containsKey('values'))
            {
                List<Object> prodAttrRecordsValue1=(List<Object>)tempMap.get('values');
                Integer size = prodAttrRecordsValue1.size();
                Set<String> commitmentValue = new Set<String>();
                for(Integer i = size - 1; i >= 0; i--)
                {
                    Map<String, Object> value1 = (Map<String, Object>)prodAttrRecordsValue1.get(i);
                    commitmentValue.add(String.valueOf(value1.get('value')));
                }
                system.debug(commitmentValue);
                for(vlocity_cmt__PicklistValue__c pr : [Select id, Name, vlocity_cmt__Value__c,vlocity_cmt__IsDefault__c,  vlocity_cmt__PicklistId__r.vlocity_cmt__Code__c  from vlocity_cmt__PicklistValue__c Where vlocity_cmt__PicklistId__r.vlocity_cmt__Code__c = 'TELIA_COMM_PERIOD'])
                {
                    if(!(commitmentValue.contains(String.valueOf(pr.vlocity_cmt__Value__c))))
                    {
                        Map<String, Object> val = new Map<String, Object>();
                        val.put('label',String.valueOf(pr.Name));
                        val.put('value',String.valueOf(pr.vlocity_cmt__Value__c));
                        val.put('defaultSelected', Boolean.valueOf(pr.vlocity_cmt__IsDefault__c));
                        prodAttrRecordsValue1.add(val);
                    }
                }
            }
        }
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
        //for portin and transfer
        public string currentMSISDN {get; set;}
        public string temporaryMSISDN {get; set;}
        public String contactTelephoneNumber {get; set;}
        public string currentOwnerSSN {get; set;}
        public string currentOwnerOrganization {get; set;}
        public string currentOwnerEmail {get; set;}
        public string requestedPortInDate{get; set;}
        public string currentOwnerOrgName{get; set;}
        public string currentOwnerFirstName {get; set;}
        public string currentOwnerLastName {get; set;}
        public string ownerPhoneNumber {get; set;}
        public string portinDate {get; set;}
        public string documentId {get; set;}
        public string userEmail {get; set;} 
        //touchpoint attribute configuration towards order
        public string Anvandarnamn {get; set;}
        public string instanceId {get; set;}
        public boolean roleCompanyAdmin {get; set;}
        public boolean roleUser {get; set;}
        public string callingLineType {get; set;}
        public string agentList1_cdgIdentifyingNumber {get; set;}
        public string agentList1_cdgAgentLoggedIn {get; set;}
        public string agentList2_cdgIdentifyingNumber {get; set;}
        public string agentList2_cdgAgentLoggedIn {get; set;}
        public string agentList3_cdgIdentifyingNumber {get; set;}
        public string agentList3_cdgAgentLoggedIn {get; set;}
        public string fixedPhoneNumber {get; set;}
        public string basketRelationId {get; set;}
        public string basketName {get; set;}
         //New Attributes for TP and SC  
        public string agentList4_cdgIdentifyingNumber {get; set;}
        public string agentList4_cdgAgentLoggedIn {get; set;}
        public string agentList5_cdgIdentifyingNumber {get; set;}
        public string agentList5_cdgAgentLoggedIn {get; set;}
        public string agentList6_cdgIdentifyingNumber {get; set;}
        public string agentList6_cdgAgentLoggedIn {get; set;}
        public string agentList7_cdgIdentifyingNumber {get; set;}
        public string agentList7_cdgAgentLoggedIn {get; set;}
        public string agentList8_cdgIdentifyingNumber {get; set;}
        public string agentList8_cdgAgentLoggedIn {get; set;}
        public string agentList9_cdgIdentifyingNumber {get; set;}
        public string agentList9_cdgAgentLoggedIn {get; set;}
        public string agentList10_cdgIdentifyingNumber {get; set;}
        public string agentList10_cdgAgentLoggedIn {get; set;}
        //public string actionCode{get; set;}
        //for MOB_COSTCONTRL_ABROAD
        public string costControlAmount {get; set;}
        //attribute for MOB_INVOICE_SPLIT_A
        public string firstName {get; set;}
        public string lastName {get; set;}
        public string street {get; set;}
        public string streetNumber {get; set;}
        public string postalCode {get; set;}
        public string city {get; set;}
        public string country {get; set;}
        public string pointid {get; set;}
        public string entrance {get; set;}
        public string appartmentNumber {get; set;}
        public string careOf {get; set;}
        

    } 
}