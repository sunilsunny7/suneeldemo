/**
* @Author:      Pancham Verma
* @Company:     Capgemini
* @Date:        12/12/2023
* @Epic/Story:	LTAART-85
* @Description: Class to inactive Utilizers that broke out from agreements and created their own agreement.
* --------------------------------------------------------------------------------------------------------------
*/
global class MC_InactiveUtilizerBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Schedulable{
    String exceptionInUpdate = null, exceptionTrace = null, inputData =null;
    private static final String utilizerStatus = 'Aktiv';
    private static final String contractStatus = 'Active';
    
    //This method returns the Database.QueryLocator object that contains Utilizer_Contract_Relationship__c records passed to the job.
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        //List of Ramavtal contracts activated 2 days ago.
        List<Contract> activeContractList = [SELECT id, AccountId FROM Contract WHERE Status = 'Active' AND Contract_Record_Type__c = 'Ramavtal' AND (StartDate = N_DAYS_AGO:2 OR TeliaSE_Start_Date__c = N_DAYS_AGO:2)];
        Set<Id> accIdSet = new Set<Id>();
        for(Contract cr : activeContractList){
            accIdSet.add(cr.AccountId);
        }
        String query = 'SELECT id,ContractNumber__c,ContractNumber__r.Agreement_Nr__c from Utilizer_Contract_Relationship__c WHERE AccountId__c in: accIdSet AND Status__c =: utilizerStatus AND ContractNumber__r.status =: contractStatus';
        return Database.getQueryLocator(query);
    }
    //This method updates the Utilziers' status and calls SetUtilizers IP in a queueable class.
    global void execute(Database.BatchableContext bc, List<Utilizer_Contract_Relationship__c> ucrList){
        Set<Id> conIdSet = new Set<Id>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        List<Utilizer_Contract_Relationship__c> utilizerUpdateList = new List<Utilizer_Contract_Relationship__c>();
        Map<Id,List<Utilizer_Contract_Relationship__c>> contractUtilizerMap= new Map<Id,List<Utilizer_Contract_Relationship__c>>();
        for (Utilizer_Contract_Relationship__c ucr: ucrList){
            if(ucr.ContractNumber__r.Agreement_Nr__c != null){
                ucr.Status__c = 'PendingInactive';
                conIdSet.add(ucr.ContractNumber__c);
                utilizerUpdateList.add(ucr);
                contractUtilizerMap.put(ucr.ContractNumber__c,new List<Utilizer_Contract_Relationship__c>());
                contractUtilizerMap.get(ucr.ContractNumber__c).add(ucr);
            }
            else{
                ucr.Status__c = 'Inaktiv';
                utilizerUpdateList.add(ucr); 
            }
        }
        try{
            update utilizerUpdateList;  
        }
        catch(Exception e){
            exceptionInUpdate = e.getMessage();
            exceptionTrace = e.getStackTraceString();
            inputData = json.serialize(utilizerUpdateList);
        }
        
        for(id cid : conIdSet){
            String contractId = cid;
            List<Utilizer_Contract_Relationship__c> UtilizerList = contractUtilizerMap.get(cid);
            String utilizerInput = json.serialize(UtilizerList);
            System.enqueueJob(new MC_InactiveUtilizerQueueable(contractId,utilizerInput));
        }
    }
    
    //This method is used for error logging if the Utilizer_Contract_Relationship__c record update fails.
    global void finish(Database.BatchableContext bc){
        if(exceptionInUpdate != null){
            MCOnline_Utility.logErrorWithoutFuture(exceptionInUpdate,exceptionTrace,'MC_InactiveUtilizerBatch','Apex Class','Exception',inputData,'','Utilizer_Contract_Relationship__c');
        }
    }
    
    //This method is used to schedule the batch class.
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new MC_InactiveUtilizerBatch(), 1);
    }
}