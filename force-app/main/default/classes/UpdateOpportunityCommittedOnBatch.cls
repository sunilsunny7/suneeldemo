/**
    About
    -----
    Description: UpdateOpportunityCommittedOnBatch
    Create date: 20.11-2015

    Update History
    --------------
    Created Nov 2015 - A.N - Created
        - This batch will fetch all Committed_Opportunity_Snapshot__c records created this week, and update the Opportunity commited on date
          based on the Committed_Opportunity_Snapshot__c.CreatedDate.
        - The batch runs every Friday. The UpdateOpportunityCommittedOnScheduler can be used to set up a new schedule of the batch job
        - Error/exception handling will send an email to the user running the batch if either an exception is thrown or the update fails for any other reasons.
*/

// To run batch manually:
// Id batchInstanceId = Database.executeBatch(new UpdateOpportunityCommittedOnBatch(), [batchSize]); // If not using default batch size of 200
global class UpdateOpportunityCommittedOnBatch implements Database.Batchable<sObject>{
    private String query;
    private List <Database.SaveResult> srl  = new List<Database.SaveResult>();

    global UpdateOpportunityCommittedOnBatch(){
        query = 'SELECT Id, Opportunity__c, CreatedDate FROM Committed_Opportunity_Snapshot__c WHERE CreatedDate = THIS_WEEK';
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Committed_Opportunity_Snapshot__c> cosList){
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Opportunity> oppsForUpdateMap = new Map<Id,Opportunity>();

        // Collect all opp id's for opps to be updated
        for (Committed_Opportunity_Snapshot__c cos : cosList){
            oppIds.add(cos.Opportunity__c);
        }

        // Iterate over all Commited Opportunity Snapshot records and update the opportunities 'Commited on' datetime
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Opportunity_id__c, Committed_on__c FROM Opportunity WHERE Id in :oppIds]);
        for(Committed_Opportunity_Snapshot__c cos : cosList){
            if(cos.Opportunity__c != null){
                Opportunity opp = oppMap.get(cos.Opportunity__c);
                opp.Committed_on__c = cos.CreatedDate;
                oppsForUpdateMap.put(opp.Id, opp); // Multitple Committed_Opportunity_Snapshot__c might point to the same opp, so need to make sure it's only added once to the update list
            }
        }

        // Update the opps
        if(oppsForUpdateMap.size() > 0){
            try{
                List<Opportunity> oppsForUpdate = oppsForUpdateMap.values();
                srl.addAll(Database.update(oppsForUpdate, false));
                sendNotificationEmailIfUpdateFailures(srl, oppsForUpdate);
            } catch (Exception e) {
                System.debug('Exception while executing the UpdateOpportunityCommittedOnBatch batch job: ' + e);
                System.debug('Opportunity Ids: ' + oppsForUpdateMap.keySet());
                SEUtility.sendExceptionMail('Exception in UpdateOpportunityCommittedOnBatch batch job', e, new List<Id>(oppsForUpdateMap.keySet()));
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish: Debug summary of batch run
        AsyncApexJob a = [
        SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob 
        WHERE Id = :BC.getJobId()
        ];

        system.debug('UpdateOpportunityCommittedOnBatch batch job ' + a.Status);
        system.debug('The batch Apex job processed ' + a.TotalJobItems +
                ' batches with '+ a.NumberOfErrors + ' failures.');
    }

    // If any record update failures, send notification email to the Apex job's submitter
    private void sendNotificationEmailIfUpdateFailures(List<Database.SaveResult> srl, List<Opportunity> oppList) {
        Integer noOfFailedRecords = 0;
        String errorBody = '';
        Integer count = 0;
        for(Database.SaveResult sr : srl){
            if(!sr.isSuccess()){
                noOfFailedRecords++;
                errorBody += '\nUpdate of opportunity ' + oppList[count].Opportunity_id__c + ' - ' + oppList[count].Id + ' failed because of the following errors: \n';
                for(Database.Error err : sr.getErrors()){
                    errorBody += 'Error Message: ' + err.getMessage() + ' \n';
                    errorBody += 'Fields: ' + err.getFields() + ' \n';
                }
            }
            count++;
        }
        
        System.debug('Out of ' + srl.size() + ' total records, there were ' + noOfFailedRecords + ' failing records.');
        if(noOfFailedRecords > 0){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {[Select Email From User where Username = : UserInfo.getUserName() limit 1].Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Update Opportunity Committed On Batch job had failing records');
            mail.setPlainTextBody (
                    'Some of the record updates for the batch Apex job Update Opportunity Committed On Batch failed. \n' +
                    'Out of ' + srl.size() + ' total records, the following ' + noOfFailedRecords + ' records could not be updated:\n' +
                    errorBody
            );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    // Method that sends an email to 
    /*
    private void sendExceptionMail(String subject, Exception e, Set<Id> ids) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {[Select Email From User where Username = : UserInfo.getUserName() limit 1].Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody (
            'Exception: ' + e + '\n\n' +
            'ids: ' + ids
        );      

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }*/
}