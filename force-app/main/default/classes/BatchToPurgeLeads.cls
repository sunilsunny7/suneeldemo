//Created 2019 : Retention And Purging

global class BatchToPurgeLeads implements Database.Batchable<sObject>{
    String query;
    Integer OpenLeads;
    Integer ConvertedLeads;
    Integer RejectedLeads;
   
    global BatchToPurgeLeads(){
        query = 'SELECT Id,CreatedDate,Status,IsConverted From Lead';
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
             return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        OpenLeads= Integer.ValueOf(Label.OpenLeads);
        ConvertedLeads= Integer.ValueOf(Label.ConvertedLeads);
        RejectedLeads= Integer.ValueOf(Label.RejectedLeads);
        
        Set<Id> leadIds=new Set<Id>();
        List<Lead> leadsToDelete = new List<Lead>();
           for(Lead ld : scope)
            {  
                if((ld.Status!='Avfärdat' && ld.Status!='Returnerad' && ld.Status!='Konverterat') && (ld.CreatedDate< (Date.Today()-OpenLeads)))
                   {
                       leadsToDelete.add(ld);
                    }
                if((ld.Status=='Konverterat'&& ld.CreatedDate < (Date.Today()-ConvertedLeads)))
                   {
                       leadsToDelete.add(ld);
                    }
                if(((ld.Status=='Avfärdat' || ld.Status=='Returnerad') && ld.CreatedDate< (Date.Today()-RejectedLeads)))
                   {
                       leadsToDelete.add(ld);
                    }
            }
        for(Lead l : leadsToDelete){
        leadIds.add(l.Id);
        }
            
        List<Buy_Interest__c> biToDelete = new List<Buy_Interest__c>([Select Id from Buy_Interest__c where Lead__c IN : leadIds]);    
        
        if(leadsToDelete.size() > 0)
        {
           try
            {
                delete leadsToDelete;
            }
            catch(Exception e)
            { 
                system.debug('Exception Caught:'+e.getmessage());
            }                  
        }
        
        
         if(biToDelete.size() > 0)
        {
           try
            {
                delete biToDelete;
            }
            catch(Exception e)
            { 
                system.debug('Exception Caught:'+e.getmessage());
            }                  
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =: BC.getJobId()
        ];

        // Send an email to the Apex job's submitter 
        //   notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {
            a.CreatedBy.Email
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Leads Purge Job  ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
         
    }
         
    
}