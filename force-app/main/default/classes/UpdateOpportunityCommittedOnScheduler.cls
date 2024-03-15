/*
// To reset the batch schedule copy paste these lines into the Execute Anonymous window.
UpdateOpportunityCommittedOnScheduler uocs = new UpdateOpportunityCommittedOnScheduler();
String sch = '0 0 20 ? * FRI *'; // Class runs every Friday at 4 AM.
String jobID = system.schedule('Update Opportunity Committed On Batch Job', sch, uocs);
*/
global class UpdateOpportunityCommittedOnScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		UpdateOpportunityCommittedOnBatch uocb = new UpdateOpportunityCommittedOnBatch();
		database.executebatch(uocb, 100);
	}
}