Global class DeleteVlocityTrackingEntry Implements Database.batchable<sobject>,Schedulable {
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator('Select Id,vlocity_cmt__TestResult__c  from vlocity_cmt__VlocityTrackingEntry__c where vlocity_cmt__TestResult__c  = '+'\'HardwareQuote\'');
    }
    global  void execute(Database.BatchableContext BC,List<SObject> scope){
        delete scope;
    }
    global void execute(SchedulableContext ctx) {
    	Database.executeBatch(new DeleteVlocityTrackingEntry(), 500);
    }
    global void finish(Database.BatchableContext BC){
    }

 }