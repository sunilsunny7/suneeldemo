Global class MC_Batch_SpockPublishResponse Implements Database.batchable<sobject>,Schedulable {
 	String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        set<String> interfaces = new set<String>{'AgreementCreateEvent','AgreementAttributeValueChangeEvent','AgreementStateChangeEvent'};
        query = 'Select id,TeliaSE_TUPP_Interface_Name__c,TeliaSE_TUPP_Interface_Status__c,TeliaSE_TUPP_Interface_Error__c from Contract where TeliaSE_TUPP_Interface_Name__c in : interfaces and TeliaSE_TUPP_Interface_Status__c = \'failure\' and MC_AgreementSyncToSpock__c = false and Contract_Record_Type__c = \'Ramavtal\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Contract> scope) {
        if(scope.size() >0){
            String jsonInput;
            String procedureName = 'Spock_AgreementDetails';
            for(Contract con:scope){
                if(con.TeliaSE_TUPP_Interface_Status__c != 'Successful'){
                    Map <String, Object> ipInput = new Map <String, Object> ();
                    Map <String, Object> ipOptions = new Map <String, Object> ();
                    ipOptions.put('isDebug',true);
                    /* Populating input map for the Integration Procedure*/
                    String ContractId = con.Id; 
                    ipInput.put('ContractId', ContractId);
                    ipInput.put('eventType',con.TeliaSE_TUPP_Interface_Name__c);
                    
                    /* Call the IP via runIntegrationService,runnign the Future invocation of the method (will get no output for this)*/
                    Id batchJob = vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable(procedureName, ipInput, ipOptions);                        
                    }
                }
            }
        }
    
    global void finish(Database.BatchableContext BC) {}
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new MC_Batch_SpockPublishResponse(), 1);
    }
}