/******************************************************************************************************
* @author         Lokesh Singh
* Maintained by   /Lokesh Singh
* @version        1.0
* @created        2023-08-31
* @modified       2023-0- 31
* Story           LTAT-15927
* ***********************************/
global class MCOnline_EmailNotifiBatch_schedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        MCOnline_EmailNotificationPrsimaBatch batchObj = new MCOnline_EmailNotificationPrsimaBatch();
        database.executeBatch(batchObj);
    }    
}