/*
// To reset the batch schedule copy paste these lines into the Execute Anonymous window.
SchBatchToCountEmpOfChildAccount  p = new SchBatchToCountEmpOfChildAccount();
String sch = '0 50 11 * * ?';  // Class runs daily at 11:50 AM.
system.schedule('BatchToCountEmpOfChildAccount', sch, p);
*/

global class SchBatchToCountEmpOfChildAccount  implements Schedulable{// this class implements Schedulable.  
  global void execute(SchedulableContext sc) {
      //system.debug('excecute batch*****');
      string kknrAccRecID = [select id from recordtype where name = 'Kundkonto'].id;
      string kknrSak1AccRecID = [select id from recordtype where name = 'Kundkonto Säk 1'].id;
      string kknrSak2AccRecID = [select id from recordtype where name = 'Kundkonto Säk 2'].id;
      BatchToCountEmpOfChildAccount b = new BatchToCountEmpOfChildAccount('SELECT Id, Employees_KKnr__c FROM account where recordtypeID =\''+kknrAccRecID+ '\' or recordtypeID =\'' +kknrSak1AccRecID+ '\' or recordtypeID =\'' +kknrSak2AccRecID+ '\'');
      database.executebatch(b,100); 
  }
}