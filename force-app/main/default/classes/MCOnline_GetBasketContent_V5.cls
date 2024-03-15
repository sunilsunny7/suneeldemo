global class MCOnline_GetBasketContent_V5 implements vlocity_cmt.VlocityOpenInterface {
    public static string GET_ITEMS = 'GetItems',ERROR = 'Error',STATUSCODE = 'StatusCode',ERROR_RESPONSE = 'ErrorResponse',APIFUNCTIONALITY='GetBasketContent';
    public static string error_message,tscid,tcwssid,parentBasketId,basketIdForException,basketLineRelationIdForException,message ;
    public static decimal totalMRC=0,totalNRC=0;
    public static integer BasketCount=0,miniBasketCount;
    public static Boolean result = true,hasError = false;
    public static Set<String> basketSet = new Set<String>();
    public static List<MCOnline_Basket__c> parameters=new List<MCOnline_Basket__c>();// for the utility generate error method parameter
    public static List<Basket> basketItems = new List<Basket>();
    public static List<MCOnline_Basket__c> MiniBasketsList = new List<MCOnline_Basket__c>();
    public static List<MCOnline_ParentBasket__c> parentBasketList = new List<MCOnline_ParentBasket__c>();
    public static Map<string,set<string>> basketRelation = new Map<string,set<string>>();
    public static Map<string,List<Basket>> BasketsMap = new Map<string,List<Basket>>();
    public static Map<String,Object> itemList = new Map<String,Object>();
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        try { 
            if(methodName.equalsIgnoreCase(GET_ITEMS)) {
                GetBasketItems(inputMap, outMap);
            }
            else {
                result = false;
            }
        }catch(Exception e) {
            error_message= e.getMessage() +' '+e.getLineNumber();
            outMap.put(ERROR, e.getStackTraceString());
            outMap.put(STATUSCODE, 500);
            outMap.put(ERROR_RESPONSE, MCOnline_Utility.generateError('','UNKNOWN_ERROR','custom', inputMap,'',parameters,APIFUNCTIONALITY));
            MCOnline_Utility.logError(error_message,'500','MCOnline_GetBasketContent_V5,MCOnline_GetBasketContent_V5.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }        
        return result;
    }
    
    public static void GetBasketItems(Map<String,Object> inputMap, Map<String,Object> outMap){
        tscid= String.valueOf(inputMap.get('tscid'));
        tcwssid = String.valueOf(inputMap.get('users'));
        parentBasketId = String.valueOf(inputMap.get('parentBasketId'));
        //error handling--------- start
        if(String.isBlank(tscid) || String.isBlank(tcwssid) || (inputMap.containsKey('parentBasketId')&& (String.isBlank(parentBasketId) || !(parentBasketId.length() == 15 || parentBasketId.length() == 18)))){
            hasError = true;
            if(String.isBlank(tscid)){
                outMap.put('ErrorResponse', MCOnline_Utility.generateError('','InvalidOrBlankTSCID','custom', inputMap,'',parameters,APIFUNCTIONALITY));
                outMap.put('StatusCode', 400);
            }
            else if(String.isBlank(tcwssid)){
                outMap.put('ErrorResponse', MCOnline_Utility.generateError('','InvalidOrBlankUser','custom', inputMap,'',parameters,APIFUNCTIONALITY));
                outMap.put('StatusCode', 400);
            }
            else if (inputMap.containsKey('parentBasketId')&& (String.isBlank(parentBasketId) || !(parentBasketId.length() == 15 || parentBasketId.length() == 18))){
                outMap.put('ErrorResponse', MCOnline_Utility.generateError('','InvalidParenttId','custom', inputMap,'',parameters,APIFUNCTIONALITY));
                outMap.put('StatusCode', 400);
            }
            
        }
        else{
            if(inputMap.containsKey('parentBasketId')){
                parentBasketList = [select Id, Name, TSCID__c, Account__c, Account__r.Name,CreatedDate,AgreementId__r.ContractNumber,Admin__c,(SELECT Id,Name, CreatedDate, MCOnline_MRC_Amount__c, MCOnline_NRC_Amount__c, MCOnline_Admin__c, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c, MCOnline_Contract__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c,MCOnline_AttributeJSON__c,basket_Line_Relation_Count__c, Basket_Line_Relation_Id__c,MCOnline_Billing_Account__c FROM MCOnline_Basket__r order by createddate desc) from  MCOnline_ParentBasket__c where TSCID__c = :tscid AND Admin__c=:tcwssid AND id = :parentBasketId AND Is_Processed__c= false WITH SECURITY_ENFORCED order by createddate desc limit 1];
            }           
            else
            {
                parentBasketList = [select Id, Name, TSCID__c, Account__c, Account__r.Name,CreatedDate,AgreementId__r.ContractNumber,Admin__c,(SELECT Id,Name, CreatedDate, MCOnline_MRC_Amount__c, MCOnline_NRC_Amount__c, MCOnline_Admin__c, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c, MCOnline_Contract__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c,MCOnline_AttributeJSON__c,basket_Line_Relation_Count__c, Basket_Line_Relation_Id__c,MCOnline_Billing_Account__c FROM MCOnline_Basket__r order by createddate desc) from  MCOnline_ParentBasket__c where TSCID__c = :tscid AND Admin__c=:tcwssid AND Is_Processed__c= false WITH SECURITY_ENFORCED order by Name asc];
            }
            if(parentBasketList.size()==0){
                hasError = true;
                List<Account> accTSCID = [select Id from Account where TSCID__c=:tscid limit 1];
                if(accTSCID==null){
                    outMap.put('StatusCode', 400);
                    outMap.put('ErrorResponse', MCOnline_Utility.generateError('','InvalidTSCID1','custom', inputMap,'',parameters,APIFUNCTIONALITY));
                }
                else{
                    outMap.put('ErrorResponse', MCOnline_Utility.generateError('','NoActiveBasket','custom', inputMap,'',parameters,APIFUNCTIONALITY));
                    outMap.put('StatusCode', 400);
                }
            }
            else if (parentBasketList.size()>1)
            {
                //This block covers the scenario of duplicate basket creation during add to basket of multiple products with same relationId
                List<MCOnline_Basket__c> childBaskets=new List<MCOnline_Basket__c>();
                List<MCOnline_Basket__c> upatedChildBaskets=new List<MCOnline_Basket__c>();
                Map<String,String> basketRelationMap=new Map<String,String>();
                String parentBasketId;
                Map<Id,MCOnline_ParentBasket__c> parentMap=new Map<Id,MCOnline_ParentBasket__c>(parentBasketList);
                List<MCOnline_ParentBasket__c> basketsToDelete=new List<MCOnline_ParentBasket__c>();
                for(MCOnline_ParentBasket__c parent:parentBasketList)
                {
                    childBaskets.addAll(parent.MCOnline_Basket__r);
                }
                for(MCOnline_Basket__c basket:childBaskets)
                {
                    if(basketRelationMap.containsKey(basket.Basket_Line_Relation_Id__c))
                    {
                        if(basket.MCOnline_ParentBasket__c !=parentBasketId)
                        {
                            basketsToDelete.add(parentMap.get(basket.MCOnline_ParentBasket__c));
                        }
                        basket.MCOnline_ParentBasket__c=basketRelationMap.get(basket.Basket_Line_Relation_Id__c);
                        upatedChildBaskets.add(basket);
                    }
                    else{
                        basketRelationMap.put(basket.Basket_Line_Relation_Id__c,basket.MCOnline_ParentBasket__c);
                        parentBasketId=basket.MCOnline_ParentBasket__c;
                    }
                }
                if(upatedChildBaskets.size()>0)
                {
                    Database.update(upatedChildBaskets,false);
                }
                if(basketsToDelete.size()>0)
                {
                    Database.delete(basketsToDelete,false);
                }
                parentBasketList = [select Id, Name, TSCID__c, Account__c, Account__r.Name,CreatedDate,AgreementId__r.ContractNumber,Admin__c,(SELECT Id,Name, CreatedDate, MCOnline_MRC_Amount__c, MCOnline_NRC_Amount__c, MCOnline_Admin__c, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c, MCOnline_Contract__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c,MCOnline_AttributeJSON__c,basket_Line_Relation_Count__c, Basket_Line_Relation_Id__c,MCOnline_Billing_Account__c FROM MCOnline_Basket__r order by createddate desc) from  MCOnline_ParentBasket__c where Id=:parentBasketId limit 1];
            }
            if(parentBasketList.size()>0){ 
                ParentBasket pBasketObj = new ParentBasket();
                pBasketObj.MCOnlineParentBasketName = parentBasketList[0].Name;
                pBasketObj.AccountId = parentBasketList[0].Account__c;
                pBasketObj.AccountName = parentBasketList[0].Account__r.Name;
                pBasketObj.tcwssid= parentBasketList[0].Admin__c;
                pBasketObj.DateCreated = String.valueOf(parentBasketList[0].CreatedDate);
                pBasketObj.TSCID = parentBasketList[0].TSCID__c;
                for(MCOnline_Basket__c basketSFObj : parentBasketList[0].MCOnline_Basket__r){
                    basketSet.add(basketSFObj.Id);
                }
                try{
                    // error handling for mismatch of relation line count on baskets---- start
                    if(parentBasketList[0].MCOnline_Basket__r != null){
                        for(MCOnline_Basket__c basketSFObj : parentBasketList[0].MCOnline_Basket__r){    
                        // loop to populate the Map basketRelation <String, set>
                            if(!basketRelation.containsKey(basketSFObj.Basket_Line_Relation_Id__c)){
                                basketRelation.put(basketSFObj.Basket_Line_Relation_Id__c,new Set<String>{basketSFObj.Name});
                            }
                            else{
                                basketRelation.get(basketSFObj.Basket_Line_Relation_Id__c).add(basketSFObj.Name);
                            }
                        } 
                        for(string relId : basketRelation.keySet()){ //looping over the number of keys of the map, i.e, the basketRelationId
                            //BasketCount integer will hold the greatest basketRelationCount value of the baskets having the same relation id
                            Set<String> miniBaskets = basketRelation.get(relId); // fetching the basket names corresponding to the relation id\
                            miniBasketCount = miniBaskets.size();
                            for(string minibksts : miniBaskets){
                                for(MCOnline_Basket__c Obj : parentBasketList[0].MCOnline_Basket__r){
                                    if(Obj.Name == minibksts){
                                            BasketCount = Integer.ValueOf(Obj.basket_Line_Relation_Count__c); // logic to set the greatest basketRelationCont value, out of the ones having the same relationId
                                    }                           
                                }
                            } 
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
                    if(MiniBasketsList.size()>0){
                        pBasketObj.itemBasketCount=(MiniBasketsList).size();
                        for(MCOnline_Basket__c basketSFObj : MiniBasketsList){
                            basketIdForException = basketSFObj.Name+' ('+basketSFObj.Id+')';
                            Basket basketObj = new Basket();
                            basketObj.itemBasketName=basketSFObj.Name;
                            if(basketSFObj.basket_Line_Relation_Count__c!=null && basketSFObj.Basket_Line_Relation_Id__c!=null){
                                basketObj.basketLineRelationCount = Integer.valueOf(basketSFObj.basket_Line_Relation_Count__c);
                                basketObj.basketLineRelationId = String.valueOf(basketSFObj.Basket_Line_Relation_Id__c);
                            }
                            basketObj.DateCreated = String.valueOf(basketSFObj.CreatedDate);
                            basketObj.Catalog = basketSFObj.MCOnline_Catalog__c;
                            basketObj.contract = basketSFObj.MCOnline_Contract__c;
                            basketObj.MCOnlineCartContextKey = basketSFObj.MCOnline_Basket_Key__c;
                            basketObj.MCOnlineOfferCode = basketSFObj.MCOnline_OfferCode__c;
                            basketObj.MCOnlineParentBasket = basketSFObj.MCOnline_ParentBasket__c;
                            //basketObj.Order = basketSFObj.MCOnline_Order__c;
                            // billing Account
                            basketObj.billingAccount = basketSFObj.MCOnline_Billing_Account__c;
                            if(basketSFObj.MCOnline_MRC_Amount__c!=null){
                              totalMRC = totalMRC + basketSFObj.MCOnline_MRC_Amount__c;
                            }
                            if(basketSFObj.MCOnline_NRC_Amount__c!=null){
                              totalNRC = totalNRC + basketSFObj.MCOnline_NRC_Amount__c;
                            }
                            if(basketSFObj.MCOnline_AttributeJSON__c != null){
                                itemList = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                                List<Object> productList = (List<Object>)itemList.get('products');
                                Map<String,Object> products = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                                
                                List<Object> prodList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(products.get('products')));
                                basketObj.products = prodList;
                            }
                            basketItems.add(basketObj);
                        }
                        pBasketObj.MRC_Total= totalMRC;
                        pBasketObj.NRC_Total= totalNRC;
                        if(basketItems==null ){
                            hasError = true;
                            outMap.put('StatusCode', 400);
                            outMap.put('ErrorResponse', MCOnline_Utility.generateError('','NoMiniBaskets','custom', inputMap,'',parameters,APIFUNCTIONALITY));
                        }
                        else{
                            pBasketObj.basketItems = basketItems;  
                            if(!hasError){
                                pBasketObj.success = true;
                            }
                            outMap.put('Result', JSON.serialize(pBasketObj));
                            outMap.put('StatusCode', 200);          
                        }
                    }
                    else{
                        hasError = true;
                        outMap.put('StatusCode', 400);
                        outMap.put('ErrorResponse', MCOnline_Utility.generateError('','NoMiniBaskets','custom', inputMap,'',parameters,APIFUNCTIONALITY));
                    }
                }
                catch(JSONException e){
                    hasError = true;
                    Map<String,Object> errorMap = MCOnline_Utility.generateError('','JsonException','custom', inputMap,'',parameters,APIFUNCTIONALITY);
                    message = (string)errorMap.get('error');
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
        public integer itemBasketCount{get; set;}
        public string MCOnlineParentBasketName{get; set;}
        public string accountId{get; set;}
        public string tcwssid{get; set;}
        public string accountName{get; set;}
        public string dateCreated{get; set;}
        public string TSCID{get; set;}
        public boolean success {get; set;}
        public List<Basket> basketItems{get; set;} 
    }
    public class Basket{
        public integer basketLineRelationCount{get; set;}
        public string basketLineRelationId{get; set;}
        public string itemBasketName{get; set;}
        public string billingAccount{get; set;}
        public string dateCreated{get; set;}
        public string catalog{get; set;}
        public string contract{get; set;}
        public string MCOnlineCartContextKey{get; set;}
        public string MCOnlineOfferCode{get; set;}
        public string MCOnlineParentBasket{get; set;}
        public string order{get; set;}
        List<Object> products = new List<Object>();
    }
}