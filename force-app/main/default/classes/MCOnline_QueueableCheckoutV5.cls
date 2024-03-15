public class MCOnline_QueueableCheckoutV5 implements Queueable {

    private Map<String,Object> basketToOrderMap;
    private Map<Id, MCOnline_Basket__c> basketIdMap;
    private Map<Id,Map<String, Map<String, Object>>> basketMap;
    private MCOnline_ParentBasket__c parentBasketObj;
    private string tscid;
    private string users;
    private string agreementId;
    private Id basketId;
    private string requestBody;
    private Map<String, String> offerMapAttribute;
    private MCOnline_OfferAttribute__mdt prodJSON;
    private string accountId;
  
    public MCOnline_QueueableCheckoutV5(String accountId, Map<String,Object> basketToOrderMap, Map<Id, MCOnline_Basket__c> basketIdMap, Map<Id,Map<String, Map<String, Object>>> basketMap, MCOnline_ParentBasket__c parentBasketObj, string tscid, string users, string agreementId, Id basketId, string requestBody, Map<String, String> offerMapAttribute, MCOnline_OfferAttribute__mdt prodJSON) {
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
        this.accountId= accountId;
    }

    public void execute(System.QueueableContext qc) 
    {
       MCOnline_futureSplitCheckoutV5 cls = new MCOnline_futureSplitCheckoutV5(accountId, basketToOrderMap, basketIdMap, basketMap, parentBasketObj, tscid, users, agreementId, basketId, requestBody, offerMapAttribute, prodJSON);
        Database.executeBatch(cls, 1);
    }
}