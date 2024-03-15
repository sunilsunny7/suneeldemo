public class MCOnline_QueueableCheckout implements Queueable {

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
  
    public MCOnline_QueueableCheckout(Map<String,Object> basketToOrderMap, Map<Id, MCOnline_Basket__c> basketIdMap, Map<Id,Map<String, MCOnline_ProcessBasket_V4.Attribute>> basketMap, MCOnline_ParentBasket__c parentBasketObj, string tscid, string users, string agreementId, Id basketId, string requestBody, Map<String, String> offerMapAttribute, MCOnline_OfferAttribute__mdt prodJSON) {
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

    public void execute(System.QueueableContext qc) 
    {
        MCOnline_futureSplitCheckout cls = new MCOnline_futureSplitCheckout(basketToOrderMap, basketIdMap, basketMap, parentBasketObj, tscid, users, agreementId, basketId, requestBody, offerMapAttribute, prodJSON);
        Database.executeBatch(cls, 1);
    }
}