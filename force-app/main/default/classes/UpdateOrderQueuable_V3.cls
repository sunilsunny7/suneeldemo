public class UpdateOrderQueuable_V3 implements Queueable {

    private Map<String, Object> inputMap;
    private Map<String, Object> outMap = new Map<String, Object>();

    public UpdateOrderQueuable_V3(Map<String, Object> inputMap) {
        this.inputMap = inputMap;
    }

    public void execute(System.QueueableContext qc) {
        MCOnline_OrderProcessor_V3.processOrderRouterFuture(JSON.serialize(inputMap), JSON.serialize(outMap));
    }
}