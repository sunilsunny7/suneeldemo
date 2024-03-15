global class MCOnline_GetBasketContent_V2 implements vlocity_cmt.VlocityOpenInterface2 {
    public static boolean SUCCESS_VALUE = true;
    public static string GET_ITEMS = 'GetItems';
    public static string ERROR = 'Error';
    public static string STATUSCODE = 'StatusCode';
    public static string ERROR_RESPONSE = 'ErrorResponse';
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try { 
            if(methodName.equalsIgnoreCase(GET_ITEMS)) {
                GetBasketItems(inputMap, outMap);
            }
            else {
                result = false;
            }
        }catch(Exception e) {
            String error_message= e.getMessage() +' '+e.getLineNumber();
            system.debug(e.getStackTraceString());
            outMap.put(ERROR, e.getStackTraceString());
            outMap.put(STATUSCODE, 500);
            outMap.put(ERROR_RESPONSE, generateError('UNKNOWN_ERROR', inputMap));
            MCOnline_Utility.logError(error_message,'500','MCONLINE_getBasketContent_V2,MCOnline_GetBasketContent_V2.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }        
        return result;
    }
    public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap){
        String tscid= String.valueOf(inputMap.get('tscid'));
        String tcwssid = String.valueOf(inputMap.get('users'));
        String AgreementId = String.valueOf(inputMap.get('AgreementId'));
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        string urlDetails = '{"Agreementid": "'+AgreementId+'", "tscid":"'+tscid+'", "users":"'+tcwssid+'"}';
        ipInputMap.put('functionality', 'GetBasketContent');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_getBasketContent_V2,MCOnline_GetBasketContent_V2.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    public static void GetBasketItems(Map<String,Object> inputMap, Map<String,Object> outMap){
        String tscid= String.valueOf(inputMap.get('tscid'));
        String tcwssid = String.valueOf(inputMap.get('users'));
        String AgreementId = String.valueOf(inputMap.get('AgreementId'));
        boolean hasError = false;
        boolean basketCountError = false;
        decimal totalMRC=0;
        decimal totalNRC=0;
        //error handling--------- start
        if(String.isBlank(tscid) || String.isBlank(tcwssid) || String.isBlank(AgreementId)){
            hasError = true;
            if(String.isBlank(tscid)){
                outMap.put('ErrorResponse', generateError('InvalidOrBlankTSCID', inputMap));
                outMap.put('StatusCode', 400);
            }
            else if(String.isBlank(tcwssid)){
                outMap.put('ErrorResponse', generateError('InvalidOrBlankUser', inputMap));
                outMap.put('StatusCode', 400);
            }
            else if(String.isBlank(AgreementId)){
                outMap.put('ErrorResponse', generateError('InvalidOrBlankAgreementId', inputMap));
                outMap.put('StatusCode', 400);
            }
        }
        else if(!(AgreementId.length() == 15 || AgreementId.length() == 18)){
            hasError = true;
            outMap.put('ErrorResponse', generateError('InvalidAgreementId', inputMap));
            outMap.put('StatusCode', 400);
        } 
        else{
            //billing Account
            List<MCOnline_ParentBasket__c> parentBasketList = [select Id, Name, TSCID__c, Account__c, Account__r.Name,CreatedDate,AgreementId__r.ContractNumber,Admin__c,(SELECT Id,Name, CreatedDate, MCOnline_MRC_Amount__c, MCOnline_NRC_Amount__c, MCOnline_Admin__c, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c, MCOnline_Contract__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c,MCOnline_AttributeJSON__c,basket_Line_Relation_Count__c, Basket_Line_Relation_Id__c,MCOnline_Billing_Account__c FROM MCOnline_Basket__r order by createddate desc) from  MCOnline_ParentBasket__c where TSCID__c = :tscid AND Admin__c=:tcwssid AND AgreementId__c=:AgreementId AND Is_Processed__c= false order by createddate desc limit 1];
            List<MCOnline_Basket__c> MiniBasketsList = new List<MCOnline_Basket__c>();
            List<MCOnline_Basket__c> Release1Bskts = new List<MCOnline_Basket__c>();
            List<MCOnline_Basket__c> Release2Bskts = new List<MCOnline_Basket__c>();
            if(parentBasketList == null || parentBasketList.size()==0){
                hasError = true;
                List<Account> accTSCID = [select Id from Account where TSCID__c=:tscid limit 1];
                if(accTSCID==null || accTSCID.size()==0){
                    outMap.put('StatusCode', 400);
                    outMap.put('ErrorResponse', generateError('InvalidTSCID1', inputMap));
                }
                else{
                    outMap.put('ErrorResponse', generateError('NoActiveBasket', inputMap));
                    outMap.put('StatusCode', 400);
                }
            } 
            else if(parentBasketList != null || parentBasketList.size()>0){ 
                ParentBasket pBasketObj = new ParentBasket();
                pBasketObj.MCOnlineParentBasketName = parentBasketList[0].Name;
                pBasketObj.AccountId = parentBasketList[0].Account__c;
                pBasketObj.agreementNumber= parentBasketList[0].AgreementId__r.ContractNumber;
                pBasketObj.AccountName = parentBasketList[0].Account__r.Name;
                pBasketObj.tcwssid= parentBasketList[0].Admin__c;
                pBasketObj.DateCreated = String.valueOf(parentBasketList[0].CreatedDate);
                pBasketObj.TSCID = parentBasketList[0].TSCID__c;
                //pBasketObj.basketCount=(parentBasketList[0].MCOnline_Basket__r).size(); 
                Set<String> basketSet = new Set<String>();
                for(MCOnline_Basket__c basketSFObj : parentBasketList[0].MCOnline_Basket__r){
                    basketSet.add(basketSFObj.Id);
                }
                List<Basket> basketItems = new List<Basket>();
                List<MCOnline_Basket__c> basketsToBeUpdated = new List<MCOnline_Basket__c>();
                string basketIdForException = '';
                string basketLineRelationIdForException = '';
                try{
                    Map<string,set<string>> basketRelation = new Map<string,set<string>>();
                    Map<string,List<Basket>> BasketsMap = new Map<string,List<Basket>>();
                    integer BasketCount;
                    //checking if data is of release 1 or release 2 -- start
                    for(MCOnline_Basket__c basketSFObj : parentBasketList[0].MCOnline_Basket__r){
                        if(basketSFObj.Basket_Line_Relation_Id__c==null && basketSFObj.basket_Line_Relation_Count__c==null){
                            Release1Bskts.add(basketSFObj);
                        }
                        else
                            Release2Bskts.add(basketSFObj);
                    } 
                    //checking if data is of release 1 or release 2 -- stop
                    // error handling for mismatch of relation line count on baskets---- start
                    if(Release2Bskts != null || Release2Bskts.size()>0){
                        for(MCOnline_Basket__c basketSFObj : Release2Bskts){    // loop to populate the Map basketRelation <String, set>
                            if(!basketRelation.containsKey(basketSFObj.Basket_Line_Relation_Id__c)){
                                basketRelation.put(basketSFObj.Basket_Line_Relation_Id__c,new Set<String>{basketSFObj.Name});
                            }
                            else{
                                basketRelation.get(basketSFObj.Basket_Line_Relation_Id__c).add(basketSFObj.Name);
                            }
                        } 
                        for(string relId : basketRelation.keySet()){ //looping over the number of keys of the map, i.e, the basketRelationId
                            BasketCount=0;  // this integer will hold the greatest basketRelationCount value of the baskets having the same relation id
                            Set<String> miniBaskets = basketRelation.get(relId); // fetching the basket names corresponding to the relation id
                            integer miniBasketCount = miniBaskets.size();
/* ------------------------------------------------------------------------------------------------------------------------ 
code added on 7/7/2021
By: Aparajita Banerjee
Implementation : Display the baskets only if the greatest basketLineCount value matches with the total number of baskets 
having the same basketrelationId (Implemented for ChangeBasket API) 
-------------------------------------------------------------------------------------------------------------------------*/                         
                            //---------------- -->  
                            for(string minibksts : miniBaskets){
                                for(MCOnline_Basket__c Obj : parentBasketList[0].MCOnline_Basket__r){
                                    if(Obj.Name == minibksts){
                                        if(Obj.basket_Line_Relation_Count__c>BasketCount){ 
                                            BasketCount = Integer.ValueOf(Obj.basket_Line_Relation_Count__c); // logic to set the greatest basketRelationCont value, out of the ones having the same relationId
                                        }
                                    }                           
                                }
                            }
                            //--------------- -->   
                            if(BasketCount==miniBasketCount){
                                for(string minibksts : miniBaskets){ // looping over number of baskets
                                    for(MCOnline_Basket__c Obj : parentBasketList[0].MCOnline_Basket__r){ // for each basket, looping over the mini baskets
                                        if(Obj.Name == minibksts){ // checking if their names match , if match only then enter
                                            MiniBasketsList.add(obj);
                                        }   
                                    }
                                }
                            }                           
                        }
                    }
                    if(Release1Bskts != null || Release1Bskts.size()>0){
                        for(MCOnline_Basket__c basketSFObj : Release1Bskts){
                            MiniBasketsList.add(basketSFObj);
                        }        
                    }
                    if(MiniBasketsList!= null || MiniBasketsList.size()>0){
                        pBasketObj.basketCount=(MiniBasketsList).size();
                        for(MCOnline_Basket__c basketSFObj : MiniBasketsList){
                            basketIdForException = basketSFObj.Name+' ('+basketSFObj.Id+')';
                            Basket basketObj = new Basket();
                            basketObj.BasketName=basketSFObj.Name;
                            if(basketSFObj.basket_Line_Relation_Count__c!=null && basketSFObj.Basket_Line_Relation_Id__c!=null){
                                basketObj.basketLineRelationCount = Integer.valueOf(basketSFObj.basket_Line_Relation_Count__c);
                                basketObj.basketLineRelationId = String.valueOf(basketSFObj.Basket_Line_Relation_Id__c);
                            }
                            basketObj.DateCreated = String.valueOf(basketSFObj.CreatedDate);
                            basketObj.Catalog = basketSFObj.MCOnline_Catalog__c;
                            basketObj.Contract = basketSFObj.MCOnline_Contract__c;
                            basketObj.MCOnlineCartContextKey = basketSFObj.MCOnline_Basket_Key__c;
                            basketObj.MCOnlineOfferCode = basketSFObj.MCOnline_OfferCode__c;
                            basketObj.MCOnlineParentBasket = basketSFObj.MCOnline_ParentBasket__c;
                            basketObj.Order = basketSFObj.MCOnline_Order__c;
                            // billing Account
                            basketObj.billingAccount = basketSFObj.MCOnline_Billing_Account__c;
                            if(basketSFObj.MCOnline_MRC_Amount__c!=null){
                              totalMRC = totalMRC + basketSFObj.MCOnline_MRC_Amount__c;
                            }
                            if(basketSFObj.MCOnline_NRC_Amount__c!=null){
                              totalNRC = totalNRC + basketSFObj.MCOnline_NRC_Amount__c;
                            }
                            Map<String,Object> itemList = new Map<String,Object>();
                            // error handling for incorrect json ------------------- start
                            if(basketSFObj.MCOnline_AttributeJSON__c != null){
                                itemList = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                                List<Object> productList = new List<Object>();
                                productList = (List<Object>)itemList.get('products');
                                Map<String,Object> products = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                                
                                List<Object> prodList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(products.get('products')));
                                basketObj.products = prodList;
                            }
                            basketItems.add(basketObj);
                        }
                        pBasketObj.MRC_Total= totalMRC;
                        pBasketObj.NRC_Total= totalNRC;
                        if(basketItems.size()==0 || basketItems==null ){
                            hasError = true;
                            outMap.put('StatusCode', 400);
                            outMap.put('ErrorResponse', generateError('NoMiniBaskets', inputMap));
                        }
                        else{
                            //pBasketObj.basketItems = basketItems;
                            pBasketObj.basketItems = basketItems;  
                            if(!hasError){
                                pBasketObj.success = true;
                            }
                            outMap.put('Result', JSON.serialize(pBasketObj));
                            outMap.put('StatusCode', 200);          
                        }
                    }
                    else if(MiniBasketsList== null || MiniBasketsList.size()==0){
                        hasError = true;
                        outMap.put('StatusCode', 400);
                        outMap.put('ErrorResponse', generateError('NoMiniBaskets', inputMap));
                    }
                }
                catch(JSONException e){
                    hasError = true;
                    Map<String,Object> errorMap = generateError('JsonException', inputMap);
                    string message = (string)errorMap.get('error');
                    message = message+', for basket '+basketIdForException;
                    errorMap.put('error', message);
                    outMap.put('ErrorResponse', errorMap);
                    outMap.put('StatusCode', 400);
                }
                // error handling for incorrect json---- stop
            }
        }
    }
    public class ParentBasket {
        public Decimal MRC_Total{get; set;}
        public Decimal NRC_Total{get;set;}
        public integer basketCount{get; set;}
        public string MCOnlineParentBasketName{get; set;}
        public string accountId{get; set;}
        public string tcwssid{get; set;}
        public string accountName{get; set;}
        public string dateCreated{get; set;}
        public string agreementNumber{get; set;}
        public string TSCID{get; set;}
        public boolean success {get; set;}
        public List<Basket> basketItems{get; set;} 
    }
    
    public class Basket{
        public integer basketLineRelationCount{get; set;}
        public string basketLineRelationId{get; set;}
        public string basketName{get; set;}
        // billing Account
        public string billingAccount{get; set;}
        public string dateCreated{get; set;}
        public string catalog{get; set;}
        public string contract{get; set;}
        public string MCOnlineCartContextKey{get; set;}
        public string MCOnlineOfferCode{get; set;}
        public string MCOnlineParentBasket{get; set;}
        public string order{get; set;}
        public string productAttributes{get; set;}
        List<Object> products = new List<Object>();
    }
}