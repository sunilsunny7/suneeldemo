public class UpdateOrderQueuable_V2 implements Queueable {

    private Map<String, Object> inputMap;
    private Map<String, Object> outMap = new Map<String, Object>();

    public UpdateOrderQueuable_V2(Map<String, Object> inputMap) {
        this.inputMap = inputMap;
    }

    public void execute(System.QueueableContext qc) {
        MCONL_OrderProcessor_V2.processOrderRouterFuture(JSON.serialize(inputMap), JSON.serialize(outMap));
    }
}