public class UpdateOrderQueuableUAT_V1 implements Queueable {

    private Map<String, Object> inputMap;
    private Map<String, Object> outMap = new Map<String, Object>();

    public UpdateOrderQueuableUAT_V1(Map<String, Object> inputMap) {
        this.inputMap = inputMap;
    }

    public void execute(System.QueueableContext qc) {
        //MCONL_OrderProcessor_UAT_V1.processOrderRouterFuture(JSON.serialize(inputMap), JSON.serialize(outMap));
    }
}