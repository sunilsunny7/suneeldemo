Global class MC_Batch_AutotaskPublishContractResponse Implements Database.batchable<sobject>,Schedulable{
    String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        //set<String> interfaces = new set<String>{'AgreementCreateEvent','AgreementAttributeValueChangeEvent','AgreementStateChangeEvent'};
        query = 'Select id,vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.MC_AutoTask_ContractId__c, TeliaSE_Product_Object_Type__c, vlocity_cmt__ContractId__r.Status, vlocity_cmt__ContractId__r.MC_Sync_AutoTask__c from vlocity_cmt__ContractLineItem__c where TeliaSE_Product_Object_Type__c =\'ITDaaS Offer Spec\'and (vlocity_cmt__ContractId__r.Status= \'Active\' or vlocity_cmt__ContractId__r.Status=\'Signed\') and vlocity_cmt__ContractId__r.MC_Sync_AutoTask__c= false';
        return Database.getQueryLocator(query);
    }
    global  void execute(Database.BatchableContext BC,List<vlocity_cmt__ContractLineItem__c> scope){
        System.debug('In Execute'+ scope.size());
        if(scope.size() >0){
            String jsonInput;
            String procedureName = 'MassCustomized_PostAgreementSync';
            for(vlocity_cmt__ContractLineItem__c con:scope){
               
                    Map <String, Object> ipInput = new Map <String, Object> ();
                    Map <String, Object> ipOptions = new Map <String, Object> ();
                    //ipOptions.put('isDebug',true);
                    /* Populating input map for the Integration Procedure*/
                    String ContractId = con.vlocity_cmt__ContractId__c; 
                    ipInput.put('ContractId', ContractId);
                    //ipInput.put('eventType',con.TeliaSE_TUPP_Interface_Name__c);
                    
                    /* Call the IP via runIntegrationService,runnign the Future invocation of the method (will get no output for this)*/
                    Id batchJob = vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable(procedureName, ipInput, ipOptions);                        
                    System.debug('Ended Execute'+ batchJob);
                }
            }
        }
    
    global void finish(Database.BatchableContext BC){}
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new MC_Batch_AutotaskPublishContractResponse(), 1);
    }
}