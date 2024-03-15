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
global with sharing class MCOnline_ProcessBasket_V5 implements vlocity_cmt.VlocityOpenInterface2 
{
    public static Map<String, String> OrderUpdate = new Map<String, String>();
    public static Map<String, Object> CheckoutUpdate = new Map<String, Object>();
    public static String portIn, portInData, transferOffer, transferOfferData;
    public static Map<String, Map<String, Object>> inputMapgetOffer = new Map<String, Map<String, Object>>();
    public static Map<Set<String>, Map<String, Object>> inputMapaddtobasket = new Map<Set<String>, Map<String, Object>>();
    public static String APIFunctunality = 'Checkout';
    public static List<MCOnline_Basket__c> parameters=new List<MCOnline_Basket__c>();

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) 
    {
        Boolean result = true;
        String errorMessage = '';
        try 
        { 
            if(methodName.equalsIgnoreCase('SFCombineBasket')){
                checkout(inputMap, outMap);
            }else{
                result = false;
            }
        }catch(Exception e){
            errorMessage = e.getMessage()+' line:'+ e.getLineNumber();
            outMap.put('Error', e.getStackTraceString());
            outMap.put('StatusCode', 500);
            if(!Test.isRunningTest()){outMap.put('ErrorResponse', MCOnline_Utility.generateError('','InternalServerError','', inputMap,'',parameters,APIFunctunality));}
            MCOnline_Utility.logError(errorMessage,'500','MCONLINE_CheckoutComposite_V5, MCOnline_ProcessBasket_V5.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }
        return result;
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
        string options = JSON.serialize(inputMap.get('options')), tscid, userId, agreementId, orderId, parentBasketId;
        Map<String,Object> optionsMap = (Map<String,Object>)JSON.deserializeUntyped(options);
        Integer eligibleBasketCount, BasketCount, miniBasketCount;
        Set<String> orderNumbers=new Set<String>();
        Set<String> basketRelationIdsForTransfer=new Set<String>();
        Map<String,List<MCOnline_Basket__c>> basketToOrderMap=new Map<String,List<MCOnline_Basket__c>>();
        //Getting the configurable Offers from custom setting for Split basket Logic
        getPortinofferMap();
        Map<string,set<string>> basketRelation = new Map<string,set<string>>();
        Map<string,List<String>> basketsToDisplay = new Map<string,List<string>>();
        List<Integer> basketRelCount = new List<Integer>();
        Set<String> miniBaskets = new Set<String>();
        List<MCOnline_Basket__c> miniBasketList= new List<MCOnline_Basket__c>();
        List<MCOnline_Basket__c> minibasketlistUpdate = new List<MCOnline_Basket__c>();
        if(String.valueOf(optionsMap.get('tscid')) != null){
            tscid = String.valueOf(optionsMap.get('tscid'));
        }else{
            tscid = String.valueOf(inputMap.get('tscid'));
        }
        if(String.valueOf(optionsMap.get('users')) != null){
            userId = String.valueOf(optionsMap.get('users'));
        }else{
            userId = String.valueOf(inputMap.get('users'));
        }
        agreementId = String.valueOf(optionsMap.get('agreementId'));
        List<MCOnline_ParentBasket__c> pBasketList = new List<MCOnline_ParentBasket__c>();
        //Custom Error Handling Logic
        if(String.isBlank(tscid) || String.isBlank(userId)){
            if(String.isBlank(tscid)){
                outMap.put('ErrorResponse', MCOnline_Utility.generateError('','InvalidOrBlankTSCID','', inputMap,'',parameters,APIFunctunality));
                outMap.put('StatusCode', 400);
            }
            else if(String.isBlank(userId)){
                outMap.put('ErrorResponse', MCOnline_Utility.generateError('','InvalidOrBlankUser','', inputMap,'',parameters,APIFunctunality));
                outMap.put('StatusCode', 400);
            }
        }
        else{
            if(optionsMap.get('parentBasketId') != null || inputMap.get('parentBasketId') != null){
                parentBasketId = (String.valueOf(optionsMap.get('parentBasketId')) != null) ? String.valueOf(optionsMap.get('parentBasketId')): String.valueOf(inputMap.get('parentBasketId'));
                if(!(Schema.MCOnline_ParentBasket__c.SObjectType == Id.valueOf(parentBasketId).getSObjectType())){
                    outMap.put('ErrorResponse', MCOnline_Utility.generateError('','InvalidParentId','', inputMap,'',parameters,APIFunctunality));
                    outMap.put('StatusCode', 400);
                    return;
                }else{
                    pBasketList=[SELECT Id, Is_Processed__c, Name, TSCID__c, OrderNumber__c, Account__c,(select id,Name,MCOnline_AttributeJSON__c,MCOnline_OfferCode__c,MCOnline_Is_Processed__c,MCOnline_Message__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c from MCOnline_Basket__r) FROM MCOnline_ParentBasket__c where Id =:parentBasketId AND Is_Processed__c=false AND flow__c= 'SALESFLOW' WITH SECURITY_ENFORCED order by createddate desc limit 1 ];
                }
            }else{
                pBasketList=[SELECT Id, Is_Processed__c, Name, TSCID__c, OrderNumber__c, Account__c,(select id,Name,MCOnline_AttributeJSON__c,MCOnline_OfferCode__c,MCOnline_Is_Processed__c,MCOnline_Message__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c from MCOnline_Basket__r) FROM MCOnline_ParentBasket__c where TSCID__c =:tscid and Admin__c =:userId AND Is_Processed__c=false AND flow__c= 'SALESFLOW' WITH SECURITY_ENFORCED order by createddate desc limit 1];
            }
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
                eligibleBasketCount = Integer.valueOf(miniBasketList.size());
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
                if(basketToOrderMap.get('MIXED') != null && basketToOrderMap.get('MIXED').size()>Integer.valueOf(Label.MaximumBasketItemPerOrder))
                {
                    splitBasketToOrder(basketToOrderMap);   
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
                    }else if(key == 'MIXED0')
                    {
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
                        outMap.put('ErrorResponse',MCOnline_Utility.generateError('','NO_ITEMS_IN_BASKET','', inputMap,'',parameters,APIFunctunality));
                        outMap.put('StatusCode', 400);
                    }
                    else if(miniBasketList != null && miniBasketList.size() > maxNum)// Defect MCONL-12602 for invalid basket count
                    {
                        outMap.put('ErrorResponse', MCOnline_Utility.generateError('','BasketItemsMoreThanExpected','', inputMap,'',parameters,APIFunctunality));
                        outMap.put('StatusCode', 400);
                    }
                    else
                    {
                        CheckoutWrapper cw = new CheckoutWrapper();
                        cw.parentBasketId = pBasketList[0].Id;
                        pBasketList[0].BasketStatus__c = 'Processing';
                        pBasketList[0].UpdateOrderRequest__c = JSON.serialize(inputMap);
                        cw.success = true;
                        cw.parentBasketId = pBasketList[0].Id;
                        cw.parentBasketName = pBasketList[0].Name;
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
                        SFCombineBasket(tscid, userId, order, requestBody, agreementId,basketOrderMapString, pBasketList[0].Id, eligibleBasketCount);
                    }
                }
            }
            if(pBasketList == null || pBasketList.size() == 0)
            {
                outMap.put('ErrorResponse', MCOnline_Utility.generateError('','NoActiveBasketFound','', inputMap,'',parameters,APIFunctunality));
                outMap.put('StatusCode', 400);
            }
        }
    }
    private static void getPortinofferMap(){
        Map<String, Checkout_Offer__c> offerMap = Checkout_Offer__c.getAll();
        portIn = (offerMap.get('PORTIN_PROCESS').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS').OfferCode__c: null;
        portInData = (offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c: null;
        transferOffer = (offerMap.get('TRANSFER_PROCESS').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS').OfferCode__c: null;
        transferOfferData = (offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c: null;
    }
    public static List<String> checkout(Map<String, Object> orderDetails, string tscid, string agreementId, string userId, String parentBasketId)
    {
        String orderId;
        Integer eligibleBasketCount;
        Set<String> orderNumbers=new Set<String>();
        List<String> OrderList = new List<String>();
        List<MCOnline_Basket__c> miniBasketList= new List<MCOnline_Basket__c>();
        List<MCOnline_Basket__c> minibasketlistUpdate = new List<MCOnline_Basket__c>();
        Set<String> basketRelationIdsForTransfer=new Set<String>();
        Map<String,List<MCOnline_Basket__c>> basketToOrderMap=new Map<String,List<MCOnline_Basket__c>>();
        //Getting the configurable Offers from custom setting for Split basket Logic
        getPortinofferMap();
        List<MCOnline_ParentBasket__c> pBasketList=[SELECT Id, Is_Processed__c, Name, TSCID__c, OrderNumber__c, Account__c,(select id,Name,MCOnline_AttributeJSON__c,MCOnline_OfferCode__c,MCOnline_Is_Processed__c,MCOnline_Message__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c from MCOnline_Basket__r) FROM MCOnline_ParentBasket__c where Id =:parentBasketId and Is_Processed__c=false AND flow__c = 'MANAGEFLOW' WITH SECURITY_ENFORCED order by createddate desc limit 1];
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
            eligibleBasketCount = Integer.valueOf(miniBasketList.size());
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
            if(basketToOrderMap.get('MIXED') != null && basketToOrderMap.get('MIXED').size()>Integer.valueOf(Label.MaximumBasketItemPerOrder))
            {
                splitBasketToOrder(basketToOrderMap);   
            }
            Integer i=0;
            for(String key:basketToOrderMap.keySet())
            {    
                if(key == 'MIXED'){
                    for(MCOnline_Basket__c item:basketToOrderMap.get(key)){
                        item.order__c=orderId;
                        orderNumbers.add(orderId);
                    }   
                }else if(key == 'MIXED0')
                {
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
                    SFCombineBasket(tscid, userId, order, requestBody, agreementId, basketOrderMapString, pBasketList[0].Id, eligibleBasketCount);
                }
            }
        }
        if(pBasketList == null || pBasketList.size() == 0){
            MCOnline_Utility.logErrorWithoutFuture('No Corresponding Basket Found. Please Check The Given TSCID and User', 'NoActiveBasketFound','MCONLINE_ModifyBasket_V2,MCONLINE_ModifyBasket_V2.MCOnline_ProcessBasketManagedFlow_V2POC.Checkout','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(orderDetails),'','');  
        }
        return OrderList;
    } 
    
    public static void splitBasketToOrder(Map<String,List<MCOnline_Basket__c>> basketToOrderMap)
    {
        List<MCOnline_Basket__c> basketList =  basketToOrderMap.get('MIXED');
        Integer z=0;
        for(MCOnline_Basket__c bas:basketList)
        {
            List<Integer> indexes= new List<Integer>();
            List<MCOnline_Basket__c> storeCommonBasket= new List<MCOnline_Basket__c>();
            if(basketToOrderMap.get('MIXED'+z)!=null)
            {
                basketToOrderMap.get('MIXED'+z).add(bas);
            }
            else
            {
                basketToOrderMap.put('MIXED'+z, new List<MCOnline_Basket__c>{bas});
            }
            if(basketToOrderMap.get('MIXED'+z) != null && basketToOrderMap.get('MIXED'+z).size() > Integer.valueOf(Label.MaximumBasketItemPerOrder))
            {
                for(Integer x=0; x<basketToOrderMap.get('MIXED'+z).size(); x++)
                {
                    if(basketToOrderMap.get('MIXED'+z)[x].Basket_Line_Relation_Id__c==bas.Basket_Line_Relation_Id__c)
                    {
                        Integer id = Integer.valueOf(x);
                        indexes.add(id);
                        storeCommonBasket.add(basketToOrderMap.get('MIXED'+z).get(id));
                    }   
                }
                for(Integer k=indexes.size()-1; k>=0; k--)
                {
                    basketToOrderMap.get('MIXED'+z).remove(indexes[k]);
                }
                z++;
                if(storeCommonBasket !=null)
                {
                    basketToOrderMap.put('MIXED'+z, storeCommonBasket);
                }
            }
        }
        basketToOrderMap.remove('MIXED');
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
        public string parentBasketId {get; set;}
        public string parentBasketName {get; set;}
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
    public static void SFCombineBasket(String tscid, string users, string orderNumber, string requestBody, string agreementId,String basketOrderMapString,Id basketId, Integer eligibleBasketCount){
        
        String orderId;
        Map<String,Object> basketToOrderMap= (Map<String,Object>)JSON.deserializeUntyped(basketOrderMapString);
        MCOnline_ParentBasket__c parentBasketObj = [select Id, TSCID__c, Is_Processed__c, Account__c, (SELECT Name, MCOnline_AttributeJSON__c, Id, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c,Order__c,MCOnline_Is_Processed__c, MCOnline_Contract__c,Basket_Line_Relation_Id__c,basket_Line_Relation_Count__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c FROM MCOnline_Basket__r) from  MCOnline_ParentBasket__c where Id = :basketId WITH SECURITY_ENFORCED limit 1];
        Map<Id, MCOnline_Basket__c> basketIdMap= new Map<Id, MCOnline_Basket__c>(parentBasketObj.MCOnline_Basket__r);
        Map<String, Object> basket1ResultMapParent = new Map<String, Object>();
        Map<String, Object> basket1ResultMapClone = new Map<String, Object>();
        
        List<Object> finalList = new List<Object>();
        
        String catalogCode = null;
        Set<Id> basketIdSet = new  Set<Id>();
        for(MCOnline_Basket__c basketSFObj : parentBasketObj.MCOnline_Basket__r){
            basketIdSet.add(basketSFObj.Id);
        }
        Integer BasketCount;
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
        Map<Id,Map<String, Map<String, Object>>> basketMap = new Map<Id,Map<String, Map<String, Object>>>();
        for(String key:basketToOrderMap.keySet()){
            List<Object> basketList = (List<Object>)basketToOrderMap.get(key);
            for(Object obj : basketList){
                Map<String, Object> basketSFObj1 = (Map<String, Object>)obj;
                MCOnline_Basket__c basketSFObj = basketIdMap.get(String.valueOf(basketSFObj1.get('Id')));
                if( basketSFObj != null && basketSFObj.MCOnline_AttributeJSON__c != null ){
                    Map<String,Object> itemList = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c); 
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
                    Map<String, Map<String, Object>> productMap = getLineItems(productList1,basketRelId,minibasketName);
                    basketMap.put(basketSFObj.Id, productMap);
                }       
            }
        }
        for(Product2 prod: [Select id, ProductCode, vlocity_cmt__AttributeMetadata__c, vlocity_cmt__SpecificationType__c from Product2 Where ProductCode IN: offerSet AND vlocity_cmt__SpecificationType__c = 'Offer' WITH SECURITY_ENFORCED])
        {
            if(prod.ProductCode != null && prod.vlocity_cmt__AttributeMetadata__c != null)
            {
                offerMapAttribute.put(prod.ProductCode, prod.vlocity_cmt__AttributeMetadata__c);
            }
        }
        MCOnline_OfferAttribute__mdt prodJSON = [Select id, OfferAttributeJSON__c from MCOnline_OfferAttribute__mdt WITH SECURITY_ENFORCED LIMIT 1];
        Integer lineNumber = 0003;
        //if(eligibleBasketCount > Integer.valueOf(Label.MaximumBasketItemPerOrder))
        if(!Test.isRunningTest())
        {
            System.enqueueJob(new MCOnline_QueueableCheckoutV5(parentBasketObj.account__c,basketToOrderMap, basketIdMap, basketMap, parentBasketObj, tscid, users, agreementId, basketId, requestBody, offerMapAttribute, prodJSON));
        }
        else
        {
            for(String key:basketToOrderMap.keySet())
            {
                List<Object> basketList = (List<Object>)basketToOrderMap.get(key);
                combineBasket(parentBasketObj.account__c,basketIdMap, basketList, basketMap, users, tscid, requestBody, agreementId, basketId, parentBasketObj, lineNumber, offerMapAttribute, prodJSON);
            }
            //Calling UpdateBasket function for upadting the basket record after DC checkout
            UpdateBasket(OrderUpdate, CheckoutUpdate, requestBody, users, tscid, agreementId, basketId);
        }
    }
    
    public static void combineBasket(String accountId,Map<Id, MCOnline_Basket__c> basketIdMap, List<Object> basketList, Map<Id,Map<String, Map<String, Object>>> basketMap, string users, string tscid, string requestBody, String agreementId, Id basketId, MCOnline_ParentBasket__c parentBasketObj, Integer lineNumber, Map<String, String> offerMapAttribute, MCOnline_OfferAttribute__mdt prodJSON)
    {
        try{
            String orderId;
            Map<String,Map<String,Object>> items=new Map<String,Map<String,Object>>();
            Map<String,Object> prodToAttribute;
            for(Object bskobj:basketList)
            {
                Map<String, Object> basketSFObj1 = (Map<String, Object>)bskobj;
                MCOnline_Basket__c basket = basketIdMap.get(String.valueOf(basketSFObj1.get('Id')));
                orderId=basket.Order__c;
                prodToAttribute=new Map<String,Object>();
                Map<String,Object> attributeMap=(Map<String,Object>)JSON.deserializeUntyped(basket.MCOnline_AttributeJSON__c);
                for(Object obj:(List<Object>)attributeMap.get('products'))
                {
                    Map<String,Object> tempMap=(Map<String,Object>)obj;
                    prodToAttribute.put(tempMap.get('productCode')+'',tempMap);
                }
                items.put(basket.Id,prodToAttribute);
            }
    
            Map<String,Object> offerMap=new Map<String,Object>();
            List<Object> prodConfigs=new List<Object>();
            Map<String, Object> input;
            Map<String, Object> output;
            Map<String, Object> options;
            for(String offer:items.keySet())
            {
                output=getOfferDetails(basketIdMap.get(offer).MCOnline_Catalog__c,basketIdMap.get(offer).MCOnline_OfferCode__c);
                offerMap.put(offer,output.get('result'));   
            }
                
            for(String offer:offerMap.keySet())
            {
                Map<String,Object> offerdetailsMap=(Map<String,Object>)((Map<String,Object>)((Map<String,Object>)offerMap.get(offer)).get('offerDetails')).get('offer');
                addDetails(offerdetailsMap,items.get(offer),basketIdMap.get(offer)); 
            }
            for(String offer:offerMap.keySet())
            {
                prodConfigs.add(offerMap.get(offer));
            }
            Map<String, Object> output1 = new Map<String, Object>();
            Map<String, Object> input1 = new Map<String, Object>();
            Map<String, Object> options1 = new Map<String, Object>();
            input1.put('apiName','basketOperations');
            input1.put('catalogCode', 'SUBSCRIPTIONS');
            input1.put('responseFormat', 'trimResponse');
            input1.put('productConfig', prodConfigs);
            input1.put('methodName', 'addAfterConfig');
            
                input1.put('requestURL', '/v3/catalogs/SUBSCRIPTIONS/basket');
            
            input1.put('contextKey', '99914b932bd37a50b983c5e7c90ae93b');
            input1.put('validate','false');
            input1.put('price', false);
            if(!Test.isRunningTest())
            {
                new vlocity_cmt.CpqAppHandler().invokeMethod('addAfterConfig', input1, output1, options1);
            }
            else{
                output1.put('result',new Map<String,object> {'cartContextKey'=>'ydtf78we8yr'});
            }            
            Map<String,Object> data=(Map<String,Object>)JSON.deserializeUntyped(output1.get('result')+'');
            if(data.containsKey('cartContextKey'))
            {
                String contextKey=data.get('cartContextKey')+'';
                checkout(accountId,contextKey,orderId);
            }
            }catch(Exception e)
            {
                sendEmail('Failed Order Creation: '+e.getMessage()+e.getLineNumber());
            }
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
        Map<String,String> basCatalog = new Map<String,String>();
        if(parentBasketObj != null && OrderUpdate != null)
        {
            update parentBasketObj;// Updating parent Basket
            ordernumberset.addAll(new List<String>(OrderUpdate.keyset()));
            Map<String,List<MCOnline_Basket__c>> orderBasketMap = new Map<String,List<MCOnline_Basket__c>>();
            Map<String,String> basRelationIdCount = new Map<String,String>();
            Map<String,MCOnline_Basket__c> basDetail = new Map<String,MCOnline_Basket__c>();
            List<MCOnline_Basket__c> miniBasket = [Select Id, MCOnline_Orders__c,MCOnline_Catalog__c,Basket_Line_Relation_Id__c,basket_Line_Relation_Count__c, Order__c,MCOnline_CheckoutResponse__c,Name,MCOnline_AttributeJSON__c From MCOnline_Basket__c Where Order__c IN:ordernumberset];
            List<Holiday> holidayList = [SELECT activitydate FROM Holiday];
            for(MCOnline_Basket__c miniBaskt : miniBasket)
            {
                // MCONL-14772  (12838BF) Checkout: Manage several due dates and order split for port-in orders
                basDetail.put(miniBaskt.id,miniBaskt);
                if(orderBasketMap.keySet().contains(String.valueOf(miniBaskt.Order__c))){
                    List<MCOnline_Basket__c> updateList = orderBasketMap.get(String.valueOf(miniBaskt.Order__c));
                    updateList.add(miniBaskt);
                    orderBasketMap.put(miniBaskt.Order__c,updateList);
                }else{
                    orderBasketMap.put(miniBaskt.Order__c,new List<MCOnline_Basket__c>{miniBaskt});
                }
                basCatalog.put(miniBaskt.id,miniBaskt.MCOnline_Catalog__c);
                basRelationIdCount.put(miniBaskt.Id,miniBaskt.basket_Line_Relation_Count__c+miniBaskt.Basket_Line_Relation_Id__c);
                // 
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
                        //// MCONL-14772  (12838BF) Checkout: Manage several due dates and order split for port-in orders
                        // due date getting from Requested_Portin_Date attribute from line number 1832 populateDueDate method 
                        ordObj1.MCOnline_Order_Due_Date__c=populateDueDate(orderBasketMap,basDetail,basCatalog,basRelationIdCount,ordObj1,holidayList);
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
    public static Map<String, Map<String, Object>> getLineItems(List<Object> items, String basketRelId, String minibasketName){
        Map<String, Map<String, Object>> productsMap = new Map<String, Map<String, Object>>();
        if(items != null){
            for(Object lineItemObj : items){
                Map<String, Object> recObj1Map = ( Map<String, Object>)lineItemObj;
                Map<String, Object> attributesMap = (Map<String, Object>)recObj1Map.get('attributes');
                if(recObj1Map != null){
                    Map<String, Object> attributesObj = new Map<String, Object>();
                    attributesObj.put('basketRelationId', (basketRelId != null) ? basketRelId : null);
                    attributesObj.put('basketName', (minibasketName != null) ? minibasketName : null);
                    attributesObj.put('ProductCode', String.valueOf(recObj1Map.get('productCode')));
                    if(attributesMap != null){
                        for(String attObj: attributesMap.keySet()){
                            Object attrName;
                            if(attributesMap.get(attObj) != null){
                                if(String.valueOf(attributesMap.get(attObj)).equalsIgnoreCase('true') || String.valueOf(attributesMap.get(attObj)).equalsIgnoreCase('false')){
                                    attrName = Boolean.valueOf(String.valueOf(attributesMap.get(attObj)));
                                }else{
                                    attrName = String.valueOf(attributesMap.get(attObj));
                                }
                            }
                            attributesObj.put(attObj, attrName);
                        }
                    }
                    productsMap.put(String.valueOf(recObj1Map.get('productCode')), attributesObj);
                }
            }
        }
        return productsMap;
    }
    
    public static Date populateDueDate(Map<String,List<MCOnline_Basket__c>> orderBasketMap,Map<String,MCOnline_Basket__c> basDetail,Map<String,String> basCatalog,Map<String,String> basRelationIdCount,Order orderObj,List<Holiday> holidayList){
        /* deside the date based on the below conditions and update it on order level
        1) Orders with the port-in request must use the due date coming from MyBusiness
        2) Orders with subscription and HW related to the port-in request must get the (port-in due date – 5 working days) as due date
        3) Orders with products not related to the port-in must get todays date as due date.*/
        //iterate through all the item baskets in the Order
        DateTime dueDate,processDueDate;
        String procesRelation,processMsisdn,processBasket;
        if(orderBasketMap.containsKey(orderObj.MCOnline_OrderNumber__c)){
            if(!((basCatalog.values()).contains('PROCESS'))){
                dueDate = system.today();       
            }else{
                //check if current order contains basket with the the offer =  PROCESS
                for(MCOnline_Basket__c cBas :orderBasketMap.get(orderObj.MCOnline_OrderNumber__c)){
                    if(cBas.MCOnline_Catalog__c =='PROCESS'){
                        Map<String,Object> procDueDate = getPortinDueDate(cBas);
                        if((procDueDate.get('Requested_port_in_date')) !=null){
                        dueDate = (DateTime)(procDueDate.get('Requested_port_in_date'));
                        }
                        else{
                            dueDate = system.today(); 
                        }
                        break;
                    }
                }//if due date is not set from previous step then it means
                // Order is associated with the process but current order is not the Process.
                // hence identify the associated PROCESS order for the current order and get the due date.
                if(dueDate==null){
                    //check subscription is associated with PROCESS
                    for(String order :orderBasketMap.keySet()){
                        if(order != orderObj.MCOnline_OrderNumber__c){
                            for(MCOnline_Basket__c chBas: orderBasketMap.get(order)){
                                //check if basket has the offer = PROCESS
                                if(basCatalog.get(chBas.id) == 'PROCESS'){
                                    procesRelation = chBas.basket_Line_Relation_Count__c+chBas.Basket_Line_Relation_Id__c;
                                    //basket details for process basket from line 1909 
                                    Map<String,Object> process = getPortinDueDate(chBas);
                                    processMsisdn = String.valueOf(process.get('portinMSISDN'));
                                    String dt=String.valueOf(process.get('Requested_port_in_date'));
                                    if(dt !=null){
                                    processDueDate =Datetime.valueOf(dt);
                                    }
                                    else{
                                    processDueDate= system.today(); 
                                    }   
                                }
                            } 
                        }    
                    }
                    Map<String,Object> subMap = new Map<String,Object>();
                    Boolean isRelated = false; 
                    DateTime portInDate;
                    //validating subscribtion related port-in using MSISDN ,relation id and relation count  
                    for(MCOnline_Basket__c childBas :orderBasketMap.get(orderObj.MCOnline_OrderNumber__c)){
                        String basRelation = childBas.basket_Line_Relation_Count__c+childBas.Basket_Line_Relation_Id__c;
                        Map<String,Object> jsonAttrMap = (Map<String,Object>)JSON.deserializeUntyped(childBas.MCOnline_AttributeJSON__c);
                        String msisdnStr = '\"MSISDN\":\"'+processMsisdn+'\"';
                        
                        if((childBas.MCOnline_AttributeJSON__c).contains(msisdnStr) && (childBas.basket_Line_Relation_Count__c+childBas.Basket_Line_Relation_Id__c)==procesRelation){
                            isRelated = true;
                        }
                        if(isRelated) {
                            portInDate = processDueDate; 
                            Integer count =0;
                            List<Datetime> dateList = new List<Datetime>();
                            //Eliminating holidays from line 1930 isHoliday method from Holiday object
                            for(Holiday holiday:holidayList){
                                dateList.add(holiday.activitydate);
                            }
                            while(count<6) {
                                if(!isHoliday(portInDate,dateList)){
                                    count++;
                                }
                                portInDate= portInDate-1;
                            }
                            dueDate =  portInDate;
                        } else{
                            dueDate = system.today(); 
                        }     
                        
                    } 
                }
            }
        }
        return (dueDate.date());
    }
    // getting process basket attribute details
    public static Map<String,Object> getPortinDueDate(MCOnline_Basket__c chBas){
        DateTime portInDate;
        Map<String,Object> processMap = new Map<String,Object>();
        Map<String,Object> attrMap = (Map<String,Object>)JSON.deserializeUntyped(chBas.MCOnline_AttributeJSON__c);
        List<Object> prodList = (List<Object>)attrMap.get('products');
        for(Object obj: prodList)
        {
            Map<String, Object> recObj = ( Map<String, Object>)obj;
            Map<String,Object> attr = (Map<String,Object>)recObj.get('attributes');
            if(attr.containsKey('Requested_port_in_date')){
                String ReqDate=String.valueOf(attr.get('Requested_port_in_date'));
                if(ReqDate != null){
                    processMap.put('Requested_port_in_date',((Datetime)JSON.deserialize('"' + ReqDate + '"', DateTime.class)));
                }
            }
            if(attr.containsKey('Current_MSISDN')){
                processMap.put('portinMSISDN',String.valueOf(attr.get('Current_MSISDN')));
            }
        }
        return processMap;
    }
    
    public static boolean isHoliday(DateTime portDate,List<Datetime> dateList){
        datetime castDate = portDate;
        String day = castDate.format('EEEE');
        return day=='Saturday' || day== 'Sunday' || dateList.contains(portDate)?true:false;
    }

    @TestVisible
    private static void sendEmail(String body)
    {
        String emailId=System.Label.TeliaSE_AMEmailId;
        String[] emailIds=emailId.Split(';');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailIds;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Exception in order creation';
        message.plainTextBody = body;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }

    //fethes offer details for particular offer
    @TestVisible
    private static Map<String,Object> getOfferDetails(String catalog,String offerCode)
    {
        HttpRequest req=new HttpRequest();
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setEndpoint(URL.getOrgDomainURL().toExternalForm()+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalog+'/offers/'+offerCode);
        req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());  
        HttpResponse res=new Http().send(req);
        Map<String,Object> response=(Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        return response;
    }

    @TestVisible
    private static void addDetails(Map<String,Object> offerDetailsMap,Map<String,Object> productMap,MCOnline_Basket__c basket)
    { 
        if(offerDetailsMap.get('vlocity_cmt__SpecificationType__c')+'' == 'Offer')
        {
            if(offerDetailsMap.containsKey('AttributeCategory')){
                Map<String,Object> atts=(Map<String,Object>)((List<Object>)((Map<String,Object>)offerDetailsMap.get('AttributeCategory')).get('records'))[0];
                Map<String,Object> prodAttributes=(Map<String,Object>)atts.get('productAttributes');
                for(Object obj:(List<Object>)prodAttributes.get('records'))
                {
                    Map<String,Object> tempMap=(Map<String,Object>)obj;
                    if(tempMap.get('label')+'' == 'Relation_Id')
                    {
                        tempMap.put('userValues',basket.Basket_Line_Relation_Id__c+';'+basket.Name);
                    }
                }
            }
        }
        if(productMap.containsKey(offerDetailsMap.get('ProductCode')+''))
        {
            offerDetailsMap.put('Quantity',1);
            processAttributes(offerDetailsMap,(Map<String,Object>)productMap.get(offerDetailsMap.get('ProductCode')+''));
        }
        if(offerDetailsMap.get('childProducts') !=null)
        {
            for(Object obj:(List<Object>)offerDetailsMap.get('childProducts'))
            {
                addDetails((Map<String,Object>)obj,productMap,basket);
            }
        }
    }
    @TestVisible
    private static Map<String,Object> checkout(String accountId,String cartContextKey,String orderNumber)
    {
        Map<String,Object> input=new Map<String,Object>();
        Map<String, Object> output = new Map<String, Object>();
        input.put('apiName','createEcomCart');
        input.put('methodName','createEcomCart');
        input.put('catalogCode', 'SUBSCRIPTIONS');
        input.put('requestURL', '/v3/carts');
        input.put('price',true);
        input.put('cartContextKey', cartContextKey);//Use the cart context key
        input.put('context','{"accountId":"'+accountId+'"}');
        //remote action invocation
        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
        if(!Test.isRunningTest()){
           appHandler.invokeMethod('createEcomCart', input, output, null); 
        }
        else{
            output.put('orderId',[select id from order limit 1]?.id);
        }
        String orderId=output.get('orderId')+'';
        if(orderId != null)
        {
            List<OrderItem> items=[select id from OrderItem where orderId=:orderId];
            if(items.size() == 0)
            {
                sendEmail('Checkout has failed with error for contextKey: '+cartContextKey+' Checkout output :'+Json.serialize(output));
                OrderUpdate=null;
            }
            else{
                OrderUpdate.put(orderNumber, orderId);
            }
            
        }
        CheckoutUpdate.put(orderNumber, output);
        return output;
    }
    @TestVisible
    private static void processAttributes(Map<String,Object> offerDetailsMap,Map<String,Object> productMap)
    {
        Map<String,Object> attribute=(Map<String,Object>)productMap.get('attributes');
        if(offerDetailsMap.containsKey('AttributeCategory')){
            Map<String,Object> atts=(Map<String,Object>)((List<Object>)((Map<String,Object>)offerDetailsMap.get('AttributeCategory')).get('records'))[0];
            Map<String,Object> prodAttributes=(Map<String,Object>)atts.get('productAttributes');
            for(Object obj:(List<Object>)prodAttributes.get('records'))
            {
                Map<String,Object> tempMap=(Map<String,Object>)obj;
                if(attribute.containsKey(tempMap.get('label')+''))
                {
                    tempMap.put('userValues',attribute.get(tempMap.get('label')+''));
                }
            }
        }
    }
}