global class OrderUpdateScheduableJob implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        
        OrderUpdateBatchJob b = new OrderUpdateBatchJob();
       
        
        database.executebatch(b,100);
    }
   

}