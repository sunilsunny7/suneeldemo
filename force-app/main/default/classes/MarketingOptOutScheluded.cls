global class MarketingOptOutScheluded implements Schedulable {
    global void execute(SchedulableContext sc) {
        database.executebatch(new BatchAccountOptOut(), 20);
    }
}