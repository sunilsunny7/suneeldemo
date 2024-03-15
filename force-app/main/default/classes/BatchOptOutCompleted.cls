/**
About
-----
Description: BatchAccountOptOut for SAEN-1838 - CLM Marketing Opt Out
Create date: 03.3-2017

Update History
--------------
Created Mars 2017 - Vahraz Mostajir - SAEN-1838. 

Issues / TODOs
--------------     
*/

public class BatchOptOutCompleted implements Database.Batchable<Account>, Database.Stateful  {
    
    public BatchOptOutCompleted(){
        System.debug('OptOutCompleted INIT');
    }
    
    public List<Account> start(Database.BatchableContext BC) { 
        System.debug('OptOutCompleted START');
        return new List<Account>([SELECT Id FROM Account WHERE (Process_Opt_Out__c = TRUE OR Process_Opt_Out_Cygate__c = True) LIMIT 1000000
]);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){  
        System.debug('OptOutCompleted EXECUTE');
        System.debug('scope: ');
        System.debug(scope);            
        
        for(Account acc : scope){
            acc.Process_Opt_Out__c = false;            

            acc.Process_Opt_Out_Cygate__c = false;
        }
        
        update scope;
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('OptOutCompleted FINNISH');
    }   
}