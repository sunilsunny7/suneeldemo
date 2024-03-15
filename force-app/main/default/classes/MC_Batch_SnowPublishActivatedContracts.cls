Global class MC_Batch_SnowPublishActivatedContracts Implements Database.batchable<sobject>{
    String query;
    global Database.QueryLocator start(Database.BatchableContext BC){  
        query = 'Select id,TeliaSE_TUPP_Interface_Name__c,TeliaSE_TUPP_Interface_Status__c,TeliaSE_TUPP_Interface_Error__c from Contract where TeliaSE_TUPP_Interface_Name__c!=\'AgreementCreateEvent\' and status = \'Active\' and MC_Snow_Sync__c = false and Contract_Record_Type__c = \'Ramavtal\'';
        return Database.getQueryLocator(query);
    }
    global  void execute(Database.BatchableContext BC,List<Contract> scope){
        if(scope.size() >0){
            String procedureName = 'SNow_ESDAfterMarket';
            for(Contract con:scope){                
                Map <String, Object> ipInput = new Map <String, Object> ();
                Map <String, Object> ipOutput = new Map <String, Object> ();
                Map <String, Object> ipOptions = new Map <String, Object> ();
                /* Populating input map for the Integration Procedure*/
                String ContractId = con.Id; 
                ipInput.put('ContractId', ContractId);
                ipInput.put('eventType','AgreementCreateEvent');
                /* Call the IP via runIntegrationService,runnign the Future invocation of the method (will get no output for this)*/
                MC_RunIntegrationProcedure.runQueueableIp(procedureName, ipInput, ipOptions);                        
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){}
}