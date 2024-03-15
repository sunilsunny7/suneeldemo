/**
About
-----
Description: SchBatchToCloseSignOfTask schedule to BatchToCloseSignOfTask class 
Create date: 14.07.2022*/
Global class SchBatchToCloseSignOfTask implements Schedulable{  
  global void execute(SchedulableContext sc) {
      BatchToCloseSignOfTask batch = new BatchToCloseSignOfTask();
      database.executebatch(batch); 
  }
}