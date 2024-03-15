global class schduleBatchNotifyCustomer implements Schedulable {

   global void execute(SchedulableContext ctx) {
      BatchEmailNotifyCustomer  btchCls = new BatchEmailNotifyCustomer ();
        database.executeBatch(btchCls);
   }   
}