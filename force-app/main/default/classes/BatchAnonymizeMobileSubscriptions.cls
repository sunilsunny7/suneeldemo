global class BatchAnonymizeMobileSubscriptions implements Database.Batchable<sObject>, Database.Stateful  {
    
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        System.debug('BatchAnonymizeMobileSubscriptions START');
        
        List<Account> accs =new List<Account>([SELECT Id, Name, CM_Final_Traffic_Marketing__c
                                               FROM Account
                                               WHERE CM_Final_Traffic_Marketing__c = 'Denied' AND Total_Mobile_Subscriptions__c > 0]); 
        
        query='SELECT Id, Name, Account__c from Mobile_Subscription__c where Account__c IN :accs AND Name !=\'XXXXXXXXX\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Mobile_Subscription__c> scope){  
       List<Mobile_Subscription__c> updateMs= new List<Mobile_Subscription__c>();
              // System.debug('scope: '+scope.size());
        For(Mobile_Subscription__c ms: scope){
            ms.Name='XXXXXXXXX';                     
            updateMs.add(ms);
        }
       System.debug('updateMs: '+updateMs);
         try{     
             if(!updateMs.isEmpty())  {                                                      
             update updateMs;
             }
         }
       catch(Exception e)
       {
          System.debug('Exception' + e);
        }
       
    }
    
    global void finish(Database.BatchableContext BC){
    AsyncApexJob a = 
    [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
     TotalJobItems, CreatedBy.Email
     FROM AsyncApexJob WHERE Id =
     :BC.getJobId()];

// Send an email to the Apex job's submitter 
//   notifying of job completion. 
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {a.CreatedBy.Email};
    mail.setToAddresses(toAddresses);
    mail.setSubject('Mobile Subscription Update Status ' + a.Status);
    mail.setPlainTextBody
    ('The batch Apex job processed ' + a.TotalJobItems +
     ' batches with '+ a.NumberOfErrors + ' failures.');
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        //System.debug('BatchDeleteMobileSubscriptions FINNISH');
       
    }   
}