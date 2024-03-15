global class MCOnline_DeleteBasket_V2_Update implements vlocity_cmt.VlocityOpenInterface2 {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try { 
            if(methodName.equalsIgnoreCase('DeleteBasketGroup')) {
                DeleteBasketGroup(inputMap, outMap);
            }
            else {
                result = false;
            }
        }catch(Exception e) {
            String error_message= e.getMessage() +' '+e.getLineNumber();
            system.debug(e.getStackTraceString());
            outMap.put('Error', e.getStackTraceString());
            outMap.put('StatusCode', 500);
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR', inputMap));
            MCOnline_Utility.logError(error_message,'500','MCONLINE_deleteBasket_V2,MCOnline_DeleteBasket_V2.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }        
        return result;
    }
    
    
    public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap){
        String basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('basketName'));
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        string urlDetails = '{"basketName":"'+basketName+'"}';
        ipInputMap.put('functionality', 'DeleteBasket');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_deleteBasket_V2,MCOnline_DeleteBasket_V2.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    
    public static void DeleteBasketGroup(Map<String,Object> inputMap, Map<String,Object> outMap){
        string basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('basketName')); // fetching the input basket name
        boolean hasError = false;
        //---- error handling for blank input start---// 
        if(String.isBlank(basketName)){
            hasError = true;
            outMap.put('ErrorResponse', generateError('NO_INPUT_BASKET_NAME', inputMap));
            outMap.put('StatusCode', 400);  
        }
        //---- error handling for blank input stop---//   
        else{  
            List<MCOnline_Basket__c> BsktId = [Select Id, Basket_Line_Relation_Id__c from MCOnline_Basket__c where Name=:basketName]; // getting the basket relation ID of the input basket
            //error handling for invalid basket Name-- start--//
            if( BsktId == null || BsktId.size() ==0){
                hasError = true;
                outMap.put('ErrorResponse', generateError('INVALID_BASKET_NAME', inputMap));
                outMap.put('StatusCode', 400);
            }
            //error handling for invalid basket Name-- stop--//
            else {
                List<MCOnline_Basket__c> ParentBasket = [SELECT Id, MCOnline_ParentBasket__r.Name, MCOnline_ParentBasket__r.Id from MCOnline_Basket__c where Name =: basketName]; // fetching parent basket corresponding to the input basket
                String parentBasketId = ParentBasket[0].MCOnline_ParentBasket__c; // storing the parent basket Id in a string
                List<MCOnline_ParentBasket__c> MiniBasketList = [select Id, (SELECT Id,Name, MCOnline_ParentBasket__c, Basket_Line_Relation_Id__c, TSCID__c, MCOnline_AttributeJSON__c FROM MCOnline_Basket__r order by createddate desc) from  MCOnline_ParentBasket__c where Id=:parentBasketId order by createddate desc limit 1]; // fetching all the mini baskets corresponding to the parent basket
                String BasktID = BsktId[0].Basket_Line_Relation_Id__c; // storing the basket rel Id in a string 
                string Id = string.valueOf(ParentBasket[0].Id);
                // checking for release 1 data.. If basketRelationId is null, that means it is a release1 data -- start
                if(BsktId[0].Basket_Line_Relation_Id__c==null){
                    Basket basketToForResponse = new Basket(); // creating an instance of wrapper class 
                    delete BsktId;
                    basketToForResponse.id = Id;
                    if(hasError==false){       
                        basketToForResponse.success = true;
                    }
                    outMap.put('Result', JSON.serialize(basketToForResponse));
                    outMap.put('StatusCode', 200);
                }// checking for release 1 data.. If basketRelationId is null, that means it is a release1 data -- stop
                else{
                     /*  ********************************************************************************************************
                                           LOGIC TO DELETE THE BASKETS HAVING THE SAME BASKET RELATION ID
                      ********************************************************************************************************* */
                    List<Id> basketIDs = new List<Id>(); // List to store the IDs
                    Map<String,Map<string,set<string>>> MiniBasketUnreserve = new Map<String,Map<string,set<string>>>();
                    if(MiniBasketList != null && MiniBasketList.size() > 0){
                        // iterating through the number of mini baskets on the parent basket
                        for(MCOnline_Basket__c basketSFObj : MiniBasketList[0].MCOnline_Basket__r){
                            if(basketSFObj.Basket_Line_Relation_Id__c == BasktID){ // condition to choose the baskets having the same relation Id
                                Map<string,set<string>> MiniBasketMap = new Map<string,set<string>>();
                                Map<String,Object> productsMap = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c); // map to store the attributesJson of that basket
                                Set<string> tscid = new set<string>{basketSFObj.TSCID__c};  // storing the TSCID of the basket
                                    Set<String> msisdnSet = new Set<String>(); // Set to hold the number of msisdns of the basket
                                List<Object> prodList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(productsMap.get('products'))); // List to hold the products from the attribute JSON
                                for(Object productObj : prodList){ // iterating through the number of products
                                    Map<String,Object> productMap = (Map<String,Object>)productObj; 
                                    Map<String,Object> attributeMap = (Map<String,Object>)productMap.get('attributes');  // map to store the attributes of the product
                                    if(attributeMap != null && attributeMap.get('MSISDN') != null){ // fetching the MSISDN of the product 
                                        string msisdn = String.valueOf(attributeMap.get('MSISDN'));
                                        msisdnSet.add(msisdn);  //adding the MSISDNs in the set 
                                    }
                                }
                                MiniBasketMap.put('MSISDN',msisdnSet);
                                MiniBasketMap.put('tscid',tscid);
                                MiniBasketUnreserve.put(string.valueOf(basketSFObj.Name),MiniBasketMap);
                                basketIDs.add(basketSFObj.Id);
                            }  
                        }
                        if(Limits.getCallouts() < Limits.getLimitCallouts())
                        {
                            unreserveMSISDN(JSON.serialize(MiniBasketUnreserve));
                        }  
                    }
                    if(basketIDs != null || basketIDs.size()>0){
                        DeleteBasket(MiniBasketList,BasktID,Id,hasError,outMap);
                    }
                }
            }
        }    
    }
    public static void DeleteBasket(List<MCOnline_ParentBasket__c> MiniBasketList, String BasktID, String Id, boolean hasError, Map<String,Object> outMap){
        Basket basketToForResponse = new Basket(); // creating an instance of wrapper class     
        for(MCOnline_Basket__c basketSFObj : MiniBasketList[0].MCOnline_Basket__r){
            if(basketSFObj.Basket_Line_Relation_Id__c == BasktID) {
                delete basketSfObj;
            }
        }
        basketToForResponse.id = Id;
        if(hasError==false){       
            basketToForResponse.success = true;
        }
        outMap.put('Result', JSON.serialize(basketToForResponse));
        outMap.put('StatusCode', 200);  
    }
    public static void msisdnUpdate(Map<String, List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>> msisdnsToUpdate, List<MCONL_MSISDN__c> MSISDNList1){
        for(string s: msisdnsToUpdate.keyset()){
            list<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper> response1 = msisdnsToUpdate.get(s);
            MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper response2 = response1[0];
            for(MCONL_MSISDN__c m : MSISDNList1){
                List<MCONL_MSISDN__c> MSISDNListToBeUpdated = new List<MCONL_MSISDN__c>();
                if(m.Number__c == s){
                    if(response1.size()>0 || response1!=null){
                        if(response2.status == 202){
                            string body = response2.response;
                            if(body.contains('"returnCode":"0"')){
                                m.Status__c = 'Un Reserve';
                            }
                            else{
                                m.Status__c = 'Failed to UnReserve';
                            }
                            m.Unreservation_Endpoint__c = response2.endpoint;
                            m.Unreservation_Request__c = response2.requestBody;
                            m.Unreservation_Response__c = response2.response;
                            MSISDNListToBeUpdated.add(m);
                        } 
                    } 
                }
                if(MSISDNListToBeUpdated != null && MSISDNListToBeUpdated.size() > 0){
                    update MSISDNListToBeUpdated;
                }
            }
        }
    }
/************************************************************************************
UNRESEVE MSISDN
************************************************************************************* */      
    @Future(callout=true)   
    public static void unreserveMSISDN(string Minibaskets){  
        List<MCONL_MSISDN__c> MSISDNList1 = [select id, Status__c, LineItemKey__c, CartContextKey__c, Number__c from MCONL_MSISDN__c WHERE Status__c=:'Reserve'];
        Map<String,Map<string,set<string>>> MiniBasketUnreserve = (Map<String,Map<string,set<string>>>)JSON.deserialize(Minibaskets,Map<String,Map<string,set<string>>>.class);
        Map<String, List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>> UpdateMsisdn = new Map<String, List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>>();
        String invalidMSISDN = '';
        integer count;
        for(string b : MiniBasketUnreserve.keySet()){ //looping over for the baskets   
            List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper> responseList = new List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>();
            String tscid;
            String msisdnStr;
            Map<string,set<string>> basketTSCIDandMSISDN = MiniBasketUnreserve.get(b);
            count=0;
            if(basketTSCIDandMSISDN.containskey('tscid')){
                set<String> tscid1 = basketTSCIDandMSISDN.get('tscid');
                tscid = new List<string>(tscid1)[0];
            }
            set<String> MSISDN = basketTSCIDandMSISDN.get('MSISDN');
            if(MSISDN.size() > 0 || MSISDN != null){
                for(string s: MSISDN){ 
                    Set<String> msisdnSet1 = new Set<String>();
                    msisdnSet1.add(s);
                    msisdnStr = new List<String>(msisdnSet1)[0];
                    for(MCONL_MSISDN__c m : MSISDNList1){
                        if(m.Number__c == s){
                            MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper response = MCOnline_NumberUnReservation_V2.UnreserveMsisdn(msisdnSet1, tscid);
                            responseList.add(response);
                        }
                    }
                    if(responseList==null || responseList.size()==0){
                        MCOnline_Utility.logErrorWithoutFuture('attempting to unreserve an invalid MSISDN', 'INAVALID_MSISDN','MCONLINE_deleteBasket_V2,MCONLINE_deleteBasket_V2.unreserveMSISDN','Integration Procedure, Apex Class', 'Custom Error',msisdnStr,'','');
                        invalidMSISDN= invalidMSISDN + msisdnStr+' ' ;
                    }
                    else{
                        if(!UpdateMsisdn.containskey(msisdnStr)){
                            UpdateMsisdn.put(msisdnStr,new List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>{responseList[Count]});   
                        }
                        else{
                            UpdateMsisdn.get(msisdnStr).add(responseList[count]);  
                        }
                        count ++;  
                    }               
                }
            }
        }
        if(!UpdateMsisdn.isEmpty()){
            msisdnUpdate(UpdateMsisdn, MSISDNList1);
        }
        else{
            MCOnline_Utility.logErrorWithoutFuture('attempting to unreserve invalid MSISDN(s)', 'INAVALID_MSISDN','MCONLINE_deleteBasket_V2,MCONLINE_deleteBasket_V2.unreserveMSISDN','Integration Procedure, Apex Class', 'Custom Error',invalidMSISDN,'','');
        }
    }
    public class Basket{
        public string id{get;set;}
        public boolean success {get; set;}  
        //public List<Id> basketId{get; set;}
    }
}