global class AccountTeamHandlerScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		AccountTeamHandler act = new AccountTeamHandler('delete');
		database.executebatch(act,20);
	}
}