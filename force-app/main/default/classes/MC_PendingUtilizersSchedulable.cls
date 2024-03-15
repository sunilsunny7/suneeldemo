public class MC_PendingUtilizersSchedulable implements Schedulable {
    /**
     * @description Executes the scheduled Apex job. 
     * @param sc contains the job ID
     */ 
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new MC_UtilizerBatch(), 500);
    }
}