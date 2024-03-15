// Id batchInstanceId = Database.executeBatch(new UpdateCampaignOnTasksBatch([CampaignId]), 50); // Needs to be ran with batch size 1 for process builder update to work
global class UpdateCampaignOnTasksBatch implements Database.Batchable<sObject> {
    
    String query;
    Id campaignId;
    
    global UpdateCampaignOnTasksBatch(String campId) {
        campaignId = (Id) campId;
        query = 'SELECT Id, Campaign__c FROM Task WHERE Campaign__c = null AND RecordTypeId = \'' + SEUtility.getRecordTypeId(SEUtility.TASK_REC_TYPE_CYGATE) + '\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Task> taskList) {

        for(Task t : taskList){
            t.Campaign__c = campaignId;
        }
        update taskList;
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('UpdateCampaignOnTasksBatch finished');
    }
}