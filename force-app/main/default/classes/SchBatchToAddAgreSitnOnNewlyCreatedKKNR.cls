/*
// To reset the batch schedule copy paste these lines into the Execute Anonymous window.
SchBatchToAddAgreSitnOnNewlyCreatedKKNR p = new SchBatchToAddAgreSitnOnNewlyCreatedKKNR();
String sch = '0 50 12 * * ?';  // Class runs daily at 12:50 PM.
system.schedule('SchBatchToAddAgreSitnOnNewlyCreatedKKNR', sch, p);
*/

global class SchBatchToAddAgreSitnOnNewlyCreatedKKNR implements Schedulable{// this class implements Schedulable.  
  global void execute(SchedulableContext sc) {
      BatchToAddAgreSitnOnNewlyCreatedKKNR b = new BatchToAddAgreSitnOnNewlyCreatedKKNR ();
      database.executebatch(b,200); 
  }
}