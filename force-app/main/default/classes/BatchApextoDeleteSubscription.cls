Global class BatchApextoDeleteSubscription Implements Database.batchable<sobject>,Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id from Mobilabonnemang__c]);
    }
    global  void execute(Database.BatchableContext BC,List<Mobilabonnemang__c> scope){
        delete scope;
    }
    global void finish(Database.BatchableContext BC){
    }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchApextoDeleteSubscription(), 500);
    }
}