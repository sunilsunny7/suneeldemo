public class TeliaSE_ContractSchedulable implements Schedulable {
    /**
     * @description Executes the scheduled Apex job. 
     * @param sc contains the job ID
     */ 
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new TeliaSE_ContractBatch(), 500);
    }
}