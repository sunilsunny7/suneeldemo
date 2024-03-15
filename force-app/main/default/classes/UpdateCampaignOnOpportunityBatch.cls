// Id batchInstanceId = Database.executeBatch(new UpdateCampaignOnOpportunityBatch([CampaignId]), 50); // Needs to be ran with batch size 1 for process builder update to work
global class UpdateCampaignOnOpportunityBatch implements Database.Batchable<sObject> {
    
    String query;
    Id campaignId;
    
    global UpdateCampaignOnOpportunityBatch(String campId) {
        campaignId = (Id) campId;
        query = 'SELECT Id, CampaignId, (SELECT Id, Campaign__c, Opportunity__c FROM Events), (SELECT Id, Campaign__c, Opportunity__c FROM Tasks) ';
        query += 'FROM Opportunity WHERE CloseDate > 2015-12-31 AND (';
        query += ' RecordTypeId = \'';
        query += SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD);
        query += '\' OR RecordTypeId = \'';
        query += SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT);
        query += '\' OR RecordTypeId = \'';
        query += SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFTERREG);
        query += '\' )';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        List<Event> eventList = new List<Event>();
        List<Task> taskList = new List<Task>();

        for(Opportunity opp : oppList){
            if(opp.CampaignId == null){
                opp.CampaignId = campaignId;
            }
            // Update related actvities and events
            for(Event e : opp.Events){
                e.Campaign__c = opp.CampaignId;
                e.Opportunity__c = opp.Id;
                eventList.add(e);
            }
            // Update related actvities and events
            for(Task t : opp.Tasks){
                t.Campaign__c = opp.CampaignId;
                t.Opportunity__c = opp.Id;  
                taskList.add(t);
            }
        }
        update oppList;
        System.debug('Number of events: ' + eventList.size());
        System.debug('Number of tasks: ' + taskList.size());
        if(!eventList.isEmpty()) update eventList;
        if(!taskList.isEmpty()) update taskList;
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('UpdateCampaignOnOpportunityBatch finished');
        System.debug('Now starting UpdateCampaignOnEventsBatch job');
        Id batchInstanceId = Database.executeBatch(new UpdateCampaignOnEventsBatch(campaignId), 50);
    }
}