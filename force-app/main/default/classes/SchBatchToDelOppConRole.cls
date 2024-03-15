/*
// To reset the batch schedule copy paste these lines into the Execute Anonymous window.
SchBatchToDelOppConRole  p = new SchBatchToDelOppConRole();
String sch = '0 50 11 * * ?'; // Class runs daily at 11:50 AM.
system.schedule('BatchToDeleteAddOppConRolesRecords', sch, p);
*/
global class SchBatchToDelOppConRole implements Schedulable{// this class implements Schedulable.  
  global void execute(SchedulableContext sc) {
      system.debug('excecute batch*****');
      BatchToDeleteAddOppConRolesRecords b = new BatchToDeleteAddOppConRolesRecords('SELECT Id FROM Add_Opportunity_Contact_Role__c');
      database.executebatch(b,200); 
  }
}