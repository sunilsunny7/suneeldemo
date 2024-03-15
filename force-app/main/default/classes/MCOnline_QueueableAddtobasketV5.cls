public class MCOnline_QueueableAddtobasketV5 implements Queueable {

    private Map<String, String> inputMap = new Map<String, String>();
    private Map<String, Object> inputMap1 = new Map<String, Object>();
    private Map<String, Object> orderDetails = new Map<String, Object>();
    private string OrderTSCID;
    private string OrderAgreementId;
    private string OrderUser;
    private string parentBasketId;
    private boolean isManagedFlow;


    public MCOnline_QueueableAddtobasketV5(Map<String, String> inputMap, Map<String,Object> inputMap1, Map<String, Object> orderDetails, string OrderTSCID, string OrderAgreementId, string OrderUser, String parentBasketId) {
        this.inputMap = inputMap;
        this.inputMap1 = inputMap1;
        this.orderDetails = orderDetails;
        this.OrderTSCID = OrderTSCID;
        this.OrderAgreementId = OrderAgreementId;
        this.OrderUser = OrderUser;
        this.parentBasketId = parentBasketId;
       }


    public MCOnline_QueueableAddtobasketV5(Map<String, String> inputMap, Map<String,Object> inputMap1, Map<String, Object> orderDetails, string OrderTSCID, string OrderAgreementId, string OrderUser,boolean isManagedFlow, String parentBasketId) {
        this.inputMap = inputMap;
        this.inputMap1 = inputMap1;
        this.orderDetails = orderDetails;
        this.OrderTSCID = OrderTSCID;
        this.OrderAgreementId = OrderAgreementId;
        this.OrderUser = OrderUser;
        this.isManagedFlow = isManagedFlow;
        this.parentBasketId = parentBasketId;
       }   

    public void execute(System.QueueableContext qc) 
    {
        if(isManagedFlow==true){
            MCOnline_MultiAddToBasketAndCheckOut_V5.MultiAddToBasketAndCheckOut_V5_Checkout(JSON.serialize(orderDetails),OrderTSCID,OrderAgreementId,OrderUser, parentBasketId);
        }


    }
}