global class FiberSchedulingClass implements Schedulable {
    
    global void execute(SchedulableContext ctx)
    {
      Fiber_Automatic_Extension_Contracts fiberbatchjob=new Fiber_Automatic_Extension_Contracts();
        Database.executeBatch(fiberbatchjob);
        
    }
    
    
}