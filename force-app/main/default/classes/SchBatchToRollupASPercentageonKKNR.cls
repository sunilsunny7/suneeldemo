global class SchBatchToRollupASPercentageonKKNR implements Schedulable{// this class implements Schedulable.  
  global void execute(SchedulableContext sc) {
      BatchToRollupASPercentageonKKNR b = new BatchToRollupASPercentageonKKNR();
      database.executebatch(b,200); 
  }
}