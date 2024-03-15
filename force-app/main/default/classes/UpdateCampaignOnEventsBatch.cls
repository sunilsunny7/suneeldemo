// Id batchInstanceId = Database.executeBatch(new UpdateCampaignOnEventsBatch([CampaignId]), 50); // Needs to be ran with batch size 1 for process builder update to work
global class UpdateCampaignOnEventsBatch implements Database.Batchable<sObject> {
    
    String query;
    Id campaignId;
    
    global UpdateCampaignOnEventsBatch(String campId) {
        campaignId = (Id) campId;
        query = 'SELECT Id, Campaign__c FROM Event WHERE Campaign__c = null AND IsPrivate = false AND RecordTypeId = \'' + SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE) + '\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Event> eventList) {

        for(Event e : eventList){
            e.Campaign__c = campaignId;
        }
        update eventList;
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('UpdateCampaignOnEventsBatch finished');
        System.debug('Now starting UpdateCampaignOnTasksBatch job');
        Id batchInstanceId = Database.executeBatch(new UpdateCampaignOnTasksBatch(campaignId), 50);
    }
}