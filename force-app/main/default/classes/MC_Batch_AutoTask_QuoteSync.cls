global class MC_Batch_AutoTask_QuoteSync Implements Database.batchable<sobject>,Schedulable{
    String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        

        query = 'select id from Quote where (MC_Sync_Autotask__c = true and TeliaSE_Autotask_QuoteId__c = null and Status != \'Cancelled\')';

        return Database.getQueryLocator(query);
    }
    global  void execute(Database.BatchableContext BC,List<quote> scope){
        System.debug('In Execute'+ scope.size());
        if(scope.size() >0){            
            String procedureName = 'MassCustomized_APIGardenSync';
            for(quote con:scope){                
                Map <String, Object> ipInput = new Map <String, Object> ();
                Map <String, Object> ipOptions = new Map <String, Object> ();                
                /* Populating input map for the Integration Procedure*/
                String ContextId = con.id; 
                ipInput.put('ContextId', ContextId);               
                /* Call the IP via runIntegrationService,runnign the Future invocation of the method (will get no output for this)*/
                Id batchJob = vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable(procedureName, ipInput, ipOptions);                                        
            }
        }
    }
    global void finish(Database.BatchableContext BC){}
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new MC_Batch_AutoTask_QuoteSync(),1);
    }
}