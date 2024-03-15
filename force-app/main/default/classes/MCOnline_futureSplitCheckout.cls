global class MCOnline_futureSplitCheckout implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts
{
    private Map<String,Object> basketToOrderMap;
    private Map<Id, MCOnline_Basket__c> basketIdMap;
    private Map<Id,Map<String, MCOnline_ProcessBasket_V4.Attribute>> basketMap;
    private MCOnline_ParentBasket__c parentBasketObj;
    private string tscid;
    private string users;
    private string agreementId;
    private Id basketId;
    private string requestBody;
    private Map<String, String> offerMapAttribute;
    private MCOnline_OfferAttribute__mdt prodJSON;
    
    global MCOnline_futureSplitCheckout(Map<String,Object> basketToOrderMap, Map<Id, MCOnline_Basket__c> basketIdMap, Map<Id,Map<String, MCOnline_ProcessBasket_V4.Attribute>> basketMap, MCOnline_ParentBasket__c parentBasketObj, string tscid, string users, string agreementId, Id basketId, string requestBody, Map<String, String> offerMapAttribute, MCOnline_OfferAttribute__mdt prodJSON){
        this.basketToOrderMap = basketToOrderMap;
        this.basketIdMap = basketIdMap;
        this.basketMap = basketMap;
        this.parentBasketObj = parentBasketObj;
        this.tscid = tscid;
        this.users = users;
        this.agreementId = agreementId;
        this.basketId = basketId;
        this.requestBody = requestBody;
        this.offerMapAttribute = offerMapAttribute;
        this.prodJSON = prodJSON;
    }
    
    global List<String> start(Database.BatchableContext BC)
    {
        List<String> keyList = new List<String>();
        for(String key:basketToOrderMap.keySet())
        {
            keyList.add(key);
        }
        keyList.sort();    
        return keyList;
    }
    global void execute(Database.BatchableContext BC,List<String> Keys)
    {
        String key = Keys[0];
        Integer lineNumber = 0003;
        List<Object> basketList = (List<Object>)basketToOrderMap.get(key);
        if(basketList != null)
        {
             MCOnline_ProcessBasket_V4.combineBasket(basketIdMap, basketList, basketMap, users, tscid, requestBody, agreementId, basketId, parentBasketObj, lineNumber, offerMapAttribute, prodJSON);
        }
        MCOnline_ProcessBasket_V4.UpdateBasket(MCOnline_ProcessBasket_V4.OrderUpdate, MCOnline_ProcessBasket_V4.CheckoutUpdate, requestBody, users, tscid, agreementId, basketId);
    }
    global void finish(Database.BatchableContext BC)
    {
        System.debug('Success');
    }
}