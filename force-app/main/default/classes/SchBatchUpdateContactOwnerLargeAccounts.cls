/*
// To reset the batch schedule copy paste these lines into the Execute Anonymous window.
SchBatchUpdateContactOwnerLargeAccounts  schBatch = new SchBatchUpdateContactOwnerLargeAccounts();
String CRON_EXP = '0 0 2 ? * MON-FRI';  // Class runs Monday through Friday at 2 AM.
system.schedule('Scheduled Batch: Update Contact Owner on Large Accounts', CRON_EXP, schBatch);
*/

global class SchBatchUpdateContactOwnerLargeAccounts implements Schedulable{
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new UpdateContactOwnerOnLargeAccountsBatch());
	}
}