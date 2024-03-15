/****************************************************************************************************************************
* @author                 Aparajita Banerjee
* @created                19/1/2022
* @modifiedBy             Aparajita Banarjee
* @maintainedBy           Aparajita Banarjee
* @version                4.0
* @description            Multi Add to basket with synchronous checkout for Managed FLow 
* @modified               19/1/2022
******************************************************************************************************************************/
global with sharing class MCOnline_MultiAddToBasketAndCheckOut_V4 implements vlocity_cmt.VlocityOpenInterface {
    static ProductDetail__mdt FieldsList = [Select MCOnline_Fields_To_Display__c,fields_to_be_mapped__c from ProductDetail__mdt];
    static String FieldsListStr=FieldsList.MCOnline_Fields_To_Display__c;
    static List<String> productFields = FieldsListStr.split(',');
    static Map<string,object> fieldsToMap = (Map<string,object>)JSON.deserializeUntyped(string.valueOf(FieldsList.fields_to_be_mapped__c));
    static Trim_GetOfferDetails__mdt finalNodeslist = [Select MCONL_Attributes_to_Remove__c from Trim_GetOfferDetails__mdt];
    static String finalNodeslistStr=finalNodeslist.MCONL_Attributes_to_Remove__c;
    static List<String> finalNodeslistStrtolist = finalNodeslistStr.split(',');
    static Set<String> finalNodes= new Set<String>(finalNodeslistStrtolist);
    static List<Product2> fieldsToAdd = [select vlocity_cmt__AttributeMetadata__c, ProductCode,Ordering_Flag__c from Product2] ;
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        // an instance of addtobasket and changeBasket, need to declare so re use the code----
        List<MCOnline_Basket__c> Parameters = new List<MCOnline_Basket__c>();
        boolean isManagedFlow = true;
        boolean isChangeBasket = false;
        Map<String, String> storeInput = new Map<String, String>();
        //-------------------------------------------------------------------
        List<id> BasketIds = new List<id>();
        List<String> Baskets = new List<String>();
        String parentId = '';
        if(methodName.equals('addtobasket_remotemethod'))
        {  
            Map<String, Object> remotemethodResponse = new Map<String, Object>();
            Map<String, Object> productConfigMap = new Map<String, Object>();
            List<Object> productConfigList = new List<Object>();
            productConfigList = (List<Object>)inputMap.get('productConfig');
            if(string.isBlank(String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID')))|| string.isBlank(String.Valueof(((Map<string,object>)inputMap.get('options')).get('users')))){
                //hasError = true;
                String errorCode = 'INAVALID_USER_TSCID';
                outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, ''));
                outMap.put('StatusCode', 500);
            } 
            else if(string.isBlank(string.valueOf(inputMap.get('basketLineRelationId'))) || string.isBlank(string.valueOf(inputMap.get('basketLineRelationCount'))) || inputMap.get('basketLineRelationCount')==0){
                //hasError = true;
                String errorCode = 'BASKET_LINE_RELATION_ID_COUNT_ERROR';
                outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, ''));
                outMap.put('StatusCode', 500);
            }
            else{
                if(productConfigList.size()!= inputMap.get('basketLineRelationCount')){
                    //hasError = true;
                    String errorCode = 'BASKET_LINE_RELATION_COUNT_MISMATCH';
                    outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, ''));
                    outMap.put('StatusCode', 500);
                }
                else{
                    for(Object offers: productConfigList){
                        if(!outMap.containsKey('ErrorResponse')){
                            //Added by Binamra Guha
                            /*-------------------Trimming of request body------------------------*/
                            Map<String, Object> tempMap = (Map<String, Object>)offers;
                            MCOnline_AddToBasket_V4.removeItems(tempMap,fieldsToAdd, finalNodes, isManagedFlow, isChangeBasket);
                            productConfigMap = (Map<String, Object>)tempMap;
                            /*--------------------------------------------------------------*/
                            string Catalog='';
                            //Added to make the catalog more dynamic
                            /*------------------------------------------------------------------*/
                            String getCatalogStr = String.valueOf((((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)( (Map<String, Object>)(productConfigMap).get('offerDetails')).get('offer')).get('addtocart')).get('rest')).get('link')));
                            Integer startIndex = getCatalogStr.indexOf('s/')+2;
                            Integer endIndex = getCatalogStr.indexOf('/basket');
                            Catalog = getCatalogStr.substring(startIndex, endIndex);
                            /*-------------------------------------------------------------------*/
                            string cartContextKey = String.valueof(inputMap.get('contextKey'));
                            //validate ICC Number
                            if(MCOnline_Utility.containsDuplicateIccNumber(productConfigMap,inputMap,'multiadd')){
                                String errorCode = 'DUPLICATE_ICC_NUMBER';
                                outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, Catalog));
                                outMap.put('StatusCode', 500); 
                            }
                            else{

                            remotemethodResponse=MCOnline_AddToBasket_V4.addtobasket_remotemethod(cartContextKey,JSON.serialize(productConfigMap),Catalog,isManagedFlow);

                            outMap=MCOnline_AddToBasket_V4.addToBasket_V3_NormalCallout(inputMap,remotemethodResponse, outMap,options,JSON.serialize(productConfigMap),BasketIds,Catalog,Parameters,isManagedFlow,storeInput,isChangeBasket);
                           } 
                        }            
                    }
                }
            }  
        }
        //Added by Aparajita Banerjee on 20/7/2021
        //Last modified on 26/7/2021
        /*____________________________________________________________________________________________________________________
*20/7/2021
*This piece of code fetches the input of the baskets to be modified and then proceeds towards an asynchronous checkout
*ModifyBasket_V2_Checkout = checkout Method
*____________________________________________________________________________________________________________________       
*26/7/2021
*This piece of code displays the list of basket Name of the baskets created 
*____________________________________________________________________________________________________________________
*/
        system.debug(JSON.serialize(outmap));
        if(outmap.containsKey('parentBasketId')){
            parentId = String.valueOf(outMap.get('parentBasketId'));
        }
        if(outmap.containsKey('ErrorResponse')){
            Map<string,object> ErrorResponse = new Map<string,object>();
            ErrorResponse = (Map<string,object>)outmap.get('ErrorResponse');
            outmap.clear();
            outmap.put('ErrorResponse',ErrorResponse);
            outMap.put('StatusCode',400);
            if(!string.isEmpty(parentId) && (BasketIds!=null || BasketIds.size()>0)){
                deleteBasket(BasketIds,parentId);
            }
        } 
        else{
            list<MCOnline_ParentBasket__c> Names = new list<MCOnline_ParentBasket__c>();
            Names = [select id, (select Name from MCOnline_Basket__r) from MCOnline_ParentBasket__c where Id=:parentId];
            for(MCOnline_Basket__c o: Names[0].MCOnline_Basket__r)
            {
                Baskets.add(o.Name);
            }
            outMap.put('itemBasket',Baskets);
            List<String> orderNumber = new List<String>();
            string TSCID = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
            string AgreementId = String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
            string User = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
            if(storeInput != null && !storeInput.isEmpty()){
                orderNumber=splitLogicOrder(parentId);
                outMap.put('orderNumber', orderNumber);
                createAsynchBasketsBatch cls = new createAsynchBasketsBatch(storeInput, inputMap, (Map<String, Object>)inputMap.get('orderDetails'),TSCID,AgreementId,User,isManagedFlow);
                Database.executeBatch(cls, 1);
                
            }
            else{
                orderNumber=MultiAddToBasketAndCheckOut_V4_Checkout(JSON.serialize((Map<String, Object>)inputMap.get('orderDetails')),TSCID,AgreementId,User);
                outMap.put('orderNumber', orderNumber);
            }
        }
        system.debug(outmap);
        return true;
        
    }
  
//Added by Aparajita
/* ___________________________________________________________________________________________________________
* This deleteBasket method is used to delete the baskets that were created inspite an unsuccesfull 
* creation of baskets   
* ___________________________________________________________________________________________________________   
*/
    @future(callout=true)
    public static void deleteBasket(List<id> BasketIds, string parentId){
        list<MCOnline_ParentBasket__c> InvalidBasketIds = [select (select id from MCOnline_Basket__r) from MCOnline_ParentBasket__c where id=: parentId];
        for(MCOnline_Basket__c bsktId : InvalidBasketIds[0].MCOnline_Basket__r){
            for(id ids: BasketIds){
                if(bsktId.id == ids)
                    delete bsktId;
            }
        }
    }       
    public static Map<String,Object> generateError(string error,string errorCode,string errorType,Map<String,Object> inputMap, String Catalog1){
        string Accountid;
        string tscid;
        string admin;
        string Agreementid;
        string Catalog= Catalog1;
        Accountid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Accountid'));
        tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
        admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
        Agreementid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
        string urlDetails = '{"Agreementid": "'+Agreementid+'", "tscid":"'+tscid+'", "users":"'+admin+'", "Catalog":"'+Catalog+'", "Accountid":"'+Accountid+'"}'; 
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        ipInputMap.put('functionality', 'MultiAddToBasketAndCheckOut');
        ipInputMap.put('error', error);   
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_MultiAddToBasketAndCheckOut_V4,MCOnline_MultiAddToBasketAndCheckOut_V4.generateError','Integration Procedure, Apex Class', 'Custom Error','STRING_TOO_LONG','','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    
    //************************************************************************************************************
    //                                 synchronous checkout --> Asynchronous checkout
    //____________________________________________________________________________________________________________
    //This calls the checkout method synchronously in the class MCOnline_ProcessBasketManagedFlow_V2
    //The further methods in the checkout are asynchronous
    //____________________________________________________________________________________________________________  
    //************************************************************************************************************
    
    public static List<String> MultiAddToBasketAndCheckOut_V4_Checkout(string order, string TSCID, string AgreementId, string User){
        List<String> OrderNumber = new List<String>();
        Map<String,Object> orderDetails = (Map<String,Object>)JSON.deserializeUntyped(order);
        OrderNumber=MCOnline_ProcessBasket_V4.checkout(orderDetails,TSCID,AgreementId,User);
        //MCOnline_ProcessBasketManagedFlow_V2POC.checkout(orderDetails,TSCID,AgreementId,User);
        return OrderNumber;
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
    public static List<String> splitLogicOrder(String parentId)
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
        Map<String, Checkout_Offer__c> offerMap = Checkout_Offer__c.getAll();
        String portIn = (offerMap.get('PORTIN_PROCESS').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS').OfferCode__c: null;
        String portInData = (offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c: null;
        String transferOffer = (offerMap.get('TRANSFER_PROCESS').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS').OfferCode__c: null;
        String transferOfferData = (offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c: null;
        List<MCOnline_ParentBasket__c> pBasketList=[SELECT Id, Is_Processed__c, Name, TSCID__c, OrderNumber__c, Account__c,(select id,Name,MCOnline_AttributeJSON__c,MCOnline_OfferCode__c,MCOnline_Is_Processed__c,MCOnline_Message__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c from MCOnline_Basket__r) FROM MCOnline_ParentBasket__c where Id=:parentId and Is_Processed__c=false AND flow__c='MANAGEFLOW' order by createddate desc limit 1];
        if(pBasketList != null && pBasketList.size() > 0){
            orderId=pBasketList[0].OrderNumber__c;
            List<MCOnline_Basket__c> basketList=pBasketList[0].MCOnline_Basket__r;
            //Updating the mini basket
            //Split Basket logic starts
            List<MCOnline_Basket__c> basketItems=basketList;
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
            Integer i=0;
            // Incrementing the Order Number in Mini Basket Records
            for(String key:basketToOrderMap.keySet())
            {    
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
            }// Updating the Mini Basket
            OrderList = new List<String>(orderNumbers);
            OrderList.sort();
        }
        return OrderList;
    }       
}