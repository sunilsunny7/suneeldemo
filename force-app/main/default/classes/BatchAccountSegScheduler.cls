global class BatchAccountSegScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    Integer size= Integer.ValueOf(Label.bsReparent);

    //testing ho
    BatchAccountSegmention act= new BatchAccountSegmention('reparent');
    database.executebatch(act,size);
  }
}