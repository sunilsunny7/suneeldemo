/*
// To reset the batch schedule copy paste these lines into the Execute Anonymous window.
SchBatchOptOut p = new SchBatchOptOut();
String sch = '0 0,60 * * * *';  // Class runs every hour
system.schedule('SchBatchOptOut', sch, p);
*/

global class SchBatchOptOut implements Schedulable{  
  global void execute(SchedulableContext sc) {
      BatchAccountOptOut b = new BatchAccountOptOut ();
      database.executebatch(b, 20); 
  }
}