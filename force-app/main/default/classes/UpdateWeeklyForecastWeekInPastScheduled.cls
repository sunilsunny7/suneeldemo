/**
    About
    -----
    Description: UpdateWeeklyForecastWeekInPastScheduled
    Create date: 06.10-2015

    Update History
    --------------
    Created Sep 2015 - A.N - Created
        - This scheduled method will run every Sunday at 3:00 AM. It will mark all Weekly Forecast items for this week as isWeekInPast=true

*/


/* To Reschedule this job in any environment, simply copy paste the below two lines into the Execute anonymous window of the Developer Console and click Run
Id scheduledJobId = UpdateWeeklyForecastWeekInPastScheduled.start();
System.debug(scheduledJobId);
*/

global class UpdateWeeklyForecastWeekInPastScheduled implements Schedulable {

	public static String CRON_EXP = '0 0 3 ? * SUN *'; // Every Sunday at 3:00am for all years

	global void execute(SchedulableContext sc) {
		Date nextWeekDate = system.today().addDays(+2); // Using a date two days in the future to ensure that no time zone difference causes issues.
		List<Weekly_Forecast_Item__c> wfiList = [SELECT Id, isWeekInPast__c, End_Date__c
												FROM Weekly_Forecast_Item__c 
												WHERE End_Date__c < :nextWeekDate AND isWeekInPast__c = false];
		for(Weekly_Forecast_Item__c wfi : wfiList){
            wfi.isWeekInPast__c = true;
        }
        update wfiList;
	}

	public static Id start(){
		UpdateWeeklyForecastWeekInPastScheduled updateWFI = new UpdateWeeklyForecastWeekInPastScheduled();
        return System.schedule('Update Weekly Forecast Week In Past: Scheduled every Sunday at 3:00am', CRON_EXP, updateWFI);
    }
}