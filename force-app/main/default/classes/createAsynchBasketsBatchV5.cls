global class createAsynchBasketsBatchV5 implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
    
    private Map<String, String> inputMap = new Map<String, String>();
    private Map<String, Object> inputMap1 = new Map<String, Object>();
    private Map<String, Object> orderDetails = new Map<String, Object>();
    private string OrderTSCID;
    private string OrderAgreementId;
    private string OrderUser;
    private string parentBasketId;
    private boolean isManagedFlow;
    private boolean V4;


    global createAsynchBasketsBatchV5(Map<String, String> inputMap, Map<String,Object> inputMap1, Map<String, Object> orderDetails, string OrderTSCID, string OrderAgreementId, string OrderUser, String parentBasketId) {
        this.inputMap = inputMap;
        this.inputMap1 = inputMap1;
        this.orderDetails = orderDetails;
        this.OrderTSCID = OrderTSCID;
        this.OrderAgreementId = OrderAgreementId;
        this.OrderUser = OrderUser;
        this.isManagedFlow= true;
        this.parentBasketId = parentBasketId;
    }
    
    global createAsynchBasketsBatchV5(Map<String, String> inputMap, Map<String,Object> inputMap1, Map<String, Object> orderDetails, string OrderTSCID, string OrderAgreementId, string OrderUser,boolean isManagedFlow, String parentBasketId) {
        this.inputMap = inputMap;
        this.inputMap1 = inputMap1;
        this.orderDetails = orderDetails;
        this.OrderTSCID = OrderTSCID;
        this.OrderAgreementId = OrderAgreementId;
        this.OrderUser = OrderUser;
        this.isManagedFlow = isManagedFlow;
        this.V4= true;
        this.parentBasketId = parentBasketId;
    }
    global createAsynchBasketsBatchV5(Map<String, String> inputMap, Map<String,Object> inputMap1, string OrderTSCID, string OrderAgreementId, string OrderUser, String parentBasketId) {
        this.inputMap = inputMap;
        this.inputMap1 = inputMap1;
        //this.orderDetails = orderDetails;
        this.OrderTSCID = OrderTSCID;
        this.OrderAgreementId = OrderAgreementId;
        this.OrderUser = OrderUser;
        this.isManagedFlow = false;
        this.V4= true;
        this.parentBasketId = parentBasketId;
    }
    
    
    global List<String> start(Database.BatchableContext BC)
    {
        List<String> keyList = new List<String>();
        for(String key:inputMap.keySet())
        {
            keyList.add(key);
        }
        keyList.sort();    
        return keyList;
    }
    
    global void execute(Database.BatchableContext BC,List<String> Keys)
    {
        Map<String, Object> productConfigMap = new Map<String, Object>();
        productConfigMap = (Map<String, Object>)JSON.deserializeUntyped(inputMap.get(Keys[0]));

        Map<String, Object> output = new Map<String, Object>();

        string Catalog='';
        //Added to make the catalog more dynamic
        /*------------------------------------------------------------------*/
        String getCatalogStr = String.valueOf((((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)( (Map<String, Object>)(productConfigMap).get('offerDetails')).get('offer')).get('addtocart')).get('rest')).get('link')));
        Integer startIndex = getCatalogStr.indexOf('s/')+2;
        Integer endIndex = getCatalogStr.indexOf('/basket');
        Catalog = getCatalogStr.substring(startIndex, endIndex);
        string ContextKey = String.valueof(inputMap1.get('contextKey'));

        output=MCOnline_utility.addToBasket_remote_Asynch(ContextKey,productConfigMap,Catalog,isManagedFlow);

        MCOnline_Basket__c basketToUpdate = [select MCOnline_Basket_Key__c, MCOnline_Order__c from MCOnline_Basket__c where Id=:Keys[0] LIMIT 1];
        basketToUpdate.MCOnline_Basket_Key__c = String.valueof(output.get('cartContextKey'));
        
        if(!Test.isRunningTest()){
            basketToUpdate.MCOnline_Order__c = String.valueof(((Map<String,object>)((List<object>)((Map<String,object>)output.get('result')).get('records'))[0]).get('OrderId'));
        }
        
        Database.update(basketToUpdate, false);
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.debug('Success');
        
        if(V4 == true){
            if(isManagedFlow==true){
                if(!Test.isRunningTest()){
                    System.enqueueJob(new MCOnline_QueueableAddtobasketV5(inputMap, inputMap1, orderDetails, OrderTSCID, OrderAgreementId, OrderUser,isManagedFlow,parentBasketId));
                }
                
            }
            else{
                if(!Test.isRunningTest()){

                    MCOnline_Utility.logErrorWithoutFuture('The process was a success','200','MCOnline_AddToBasket','Apex Class','Standard Error','Success','','');
                }
            }
        }

        
    }
    
    
    
}