public class MCOnline_QueueableAddtobasket implements Queueable {

    private Map<String, String> inputMap = new Map<String, String>();
    private Map<String, Object> inputMap1 = new Map<String, Object>();
    private Map<String, Object> orderDetails = new Map<String, Object>();
    private string OrderTSCID;
    private string OrderAgreementId;
    private string OrderUser;

    private boolean isManagedFlow;
 
    //private Map<String, Object> output = new Map<String, Object>();
    //private Map<String, Object> option = new Map<String, Object>();
    //private id BasketId;
    
    public MCOnline_QueueableAddtobasket(Map<String, String> inputMap, Map<String,Object> inputMap1, Map<String, Object> orderDetails, string OrderTSCID, string OrderAgreementId, string OrderUser) {
        this.inputMap = inputMap;
        this.inputMap1 = inputMap1;
        this.orderDetails = orderDetails;
        this.OrderTSCID = OrderTSCID;
        this.OrderAgreementId = OrderAgreementId;
        this.OrderUser = OrderUser;
       }


    public MCOnline_QueueableAddtobasket(Map<String, String> inputMap, Map<String,Object> inputMap1, Map<String, Object> orderDetails, string OrderTSCID, string OrderAgreementId, string OrderUser,boolean isManagedFlow) {
        this.inputMap = inputMap;
        this.inputMap1 = inputMap1;
        this.orderDetails = orderDetails;
        this.OrderTSCID = OrderTSCID;
        this.OrderAgreementId = OrderAgreementId;
        this.OrderUser = OrderUser;
        this.isManagedFlow = isManagedFlow;
       }   

    public void execute(System.QueueableContext qc) 
    {
        if(isManagedFlow==true){
            MCOnline_MultiAddToBasketAndCheckOut_V4.MultiAddToBasketAndCheckOut_V4_Checkout(JSON.serialize(orderDetails),OrderTSCID,OrderAgreementId,OrderUser);
        }
        
    }
}