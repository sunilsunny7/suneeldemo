/**Created By:  Abhinav Gupta
**Sprint: DROP-3.2 
**User Story:MCSTO-6214
**Description: Notify Opportunity owner when utilizer is in pendingActive, pendingDeletion state for 4 days.
-----------------------------------------------------------------------------------------------------------*/
global class MC_UtilizerBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    string pendingActiveStatus = 'pendingActive';
    string pendingDeletionStatus = 'pendingInactive';
    string contractStatus = 'Active';
    Integer days = -4;
    
    global Database.QueryLocator start(Database.BatchableContext context) 
    {
        If(!Test.isRunningTest())
        {
            DateTime dateTime4DaysAgo = DateTime.now().addDays(days);
        }
        else
        {
            DateTime dateTime4DaysAgo = DateTime.now();
        }
        
        String query = 'Select id,AccountId__c, ContractNumber__c, ContractNumber__r.ContractNumber, ContractNumber__r.vlocity_cmt__OpportunityId__r.Owner.Email, ContractNumber__r.Status from Utilizer_Contract_Relationship__c where ContractNumber__r.status =:contractStatus and (Status__c =:pendingActiveStatus Or Status__c =:pendingDeletionStatus) and LastModifiedDate <=: dateTime4DaysAgo';
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext context, List<Utilizer_Contract_Relationship__c> utilList) 
    {
        Map<String,String> contractIdOpportunityEmailMap = new Map<String,String>();
        List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
        If(utilList.size()>0)
        {
            for(Utilizer_Contract_Relationship__c uc : utilList)
            {
                Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(uc.ContractNumber__r.vlocity_cmt__OpportunityId__r.Owner.Email);
                mail.setToAddresses(sendTo);
                String subject = 'Fördröjd ärendehantering för nyttjare (avtal '+uc.ContractNumber__r.ContractNumber+')';
                mail.setSubject(subject);
                String body = 'Din nyttjarförfrågan för avtal '+uc.ContractNumber__r.ContractNumber+' har inte gått igenom än.  Kontakta avtalshandläggare om du har några frågor.';
                mail.setHtmlBody(body);
                mails.add(mail);                
            }
        }
        if(mails.size()>0)
        {
            Messaging.sendEmail(mails);
            
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }  
    
}