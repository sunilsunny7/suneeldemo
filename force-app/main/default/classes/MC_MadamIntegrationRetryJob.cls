/* ******************************************************************************************************
* @author         Binamra Guha/Aditi Goyal
* @modifiedBy     Itishree Dash
* @maintainedBy   Itishree Dash/Lokesh Singh
* @version        1.0
* @modified       2023-07-21(code ptimization to improve performance)
*
* ******************************************************************************************************/
global class MC_MadamIntegrationRetryJob Implements Database.batchable<sobject>,Schedulable, Database.Stateful, Database.AllowsCallouts{
    private String query='';
    private List<String> errorList = new List<String>();
    private Set<String> agreementNumberSet = new Set<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String className= '%MassCustomized_MadamIntegration%', errorCodeName = 'INVOKE-200';
        String fields = 'Id, vlocity_cmt__Action__c, MC_RetryStatus__c, vlocity_cmt__ContextId__c, vlocity_cmt__ErrorCode__c, vlocity_cmt__ErrorMessage__c, vlocity_cmt__ErrorTime__c, vlocity_cmt__ErrorType__c, vlocity_cmt__InputData__c, vlocity_cmt__ObjectName__c, vlocity_cmt__SourceName__c, vlocity_cmt__SourceType__c';
        query = 'select '+fields+' from vlocity_cmt__VlocityErrorLogEntry__c where MC_RetryStatus__c = false AND vlocity_cmt__ErrorCode__c != \''+errorCodeName+'\' AND vlocity_cmt__SourceName__c LIKE \''+className+'\' Order By CreatedDate DESC';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext context, List<SObject> scope){
        
        String error_message = '';
        try
        {
            Map<String, vlocity_cmt__VlocityErrorLogEntry__c> inputMapwithId = new Map<String, vlocity_cmt__VlocityErrorLogEntry__c>();
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            Set<String> contractNumberSet = new Set<String>();
            Set<String> agreementNumberSet = new Set<String>();
            Map<String, Object> inputAgreement;
            String agr;
            for(vlocity_cmt__VlocityErrorLogEntry__c err: (List<vlocity_cmt__VlocityErrorLogEntry__c>)scope)
            {
                inputMapwithId.put(String.valueOf(err.Id), err);
                List<String> agrNum = (err.vlocity_cmt__ContextId__c != null) ? err.vlocity_cmt__ContextId__c.split('-'): null;
                String madamAgreementNum = (agrNum != null && agrNum.size() > 0 ? agrNum[0] : null);
                String  serviceConNum =    (agrNum != null && agrNum.size() > 1 ? agrNum[1] : null);
                contractNumberSet.add(serviceConNum);
                agr = '%'+madamAgreementNum+'%';
            }
            List<vlocity_cmt__VlocityErrorLogEntry__c> errorLst = [Select id, vlocity_cmt__ErrorCode__c from vlocity_cmt__VlocityErrorLogEntry__c Where vlocity_cmt__ContextId__c LIKE :agr Order by CreatedDate DESC LIMIT 1];
            List<vlocity_cmt__VlocityErrorLogEntry__c> errorlogUpdate = new List<vlocity_cmt__VlocityErrorLogEntry__c>();
            
            if(errorLst.size()>0 && errorLst[0].vlocity_cmt__ErrorCode__c != 'INVOKE-200'){                 
                for(Contract contractId:[Select id from Contract Where ContractNumber IN: contractNumberSet Order By LastModifiedDate DESC Limit 1]){
                    options.put('contractId', String.valueOf(contractId.Id)); 
                    
                    
                    for(String errId: inputMapwithId.KeySet())
                    {
                        if(inputMapwithId.get(errId) != null && options != null)
                        {
                            vlocity_cmt__VlocityErrorLogEntry__c errlog = inputMapwithId.get(errId);
                            inputMap = (Map<String, Object>)JSON.deserializeUntyped(errlog.vlocity_cmt__InputData__c);
                            if(inputMap != null){
                                inputAgreement = (Map<String, Object>)inputMap.get('agreement');
                            }
                            String agreementNumber = (inputAgreement != null) ? String.valueOf(inputAgreement.get('agreementNumber')) : null;
                            if(agreementNumberSet != null && agreementNumber!= null && !agreementNumberSet.contains(agreementNumber)){
                                agreementNumberSet.add(agreementNumber);
                                System.enqueueJob(new MC_MadamIntegrationQueueable('manageMadamRequest',inputMap,outputMap,options));
                            }
                            errlog.MC_RetryStatus__c = true;
                            errorlogUpdate.add(errlog);
                        }
                    }
                }
                if(errorlogUpdate.size()>0)
                {
                    Database.update(errorlogUpdate, false);
                }
            }
        }
        catch(Exception e) {        
            error_message = e.getMessage() + ', Exception Trace: ' + e.getStackTraceString() + ', Line Number: ' + e.getLineNumber();
            errorList.add(error_message);
        }
    }
    global void finish(Database.BatchableContext BC){   
    }
    global void execute(SchedulableContext sc) {   
        Database.executeBatch(new MC_MadamIntegrationRetryJob(), 1);
    }
}