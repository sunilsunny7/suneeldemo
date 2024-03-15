global class SchBatchUpdateFULsforFunnel implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchUpdateFULsforFunnel b = new BatchUpdateFULsforFunnel();
        database.executebatch(b,200);
    }
}