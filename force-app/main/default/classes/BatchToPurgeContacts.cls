global class BatchToPurgeContacts implements Database.Batchable<sObject>{
        String query;
        Integer ContactsWORelation;
        Integer ContactWithRelations;
        
    global BatchToPurgeContacts(){
        query = 'SELECT Id,CreatedDate,Deactivation_date__C From Contact where Inaktiv__c=true AND Deactivation_date__c!=null';
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
      
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        Set<Id> conIds = new Set<Id>();
        ContactsWORelation= Integer.ValueOf(Label.ContactsWORelation);
        ContactWithRelations= Integer.ValueOf(Label.ContactWithRelations);
        
        List<Contact> contactsToDelete = new List<Contact>();
        for(Contact contc: Scope){
            conIds.add(contc.Id);            
        }
        List<Task> checkTask = new List<Task>([Select WhoId From Task where WhoId IN : conIds]);
        List<Event> checkEvent = new List<Event>([Select WhoId From Event where WhoId IN : conIds]); 
        List<Opportunity> checkOpp=new List<Opportunity>([Select Contact__c From Opportunity where Contact__c IN : conIds]);
        List<CampaignMember> checkCM=new List<CampaignMember>([SELECT ContactId FROM CampaignMember where ContactId IN : conIds]);
        List<Case> checkCase=new List<Case>([SELECT ContactId FROM Case where ContactId IN : conIds]);
        List<Contract> checkContract=new List<Contract>([SELECT CustomerSignedId FROM Contract where CustomerSignedId IN : conIds]);
        List<OpportunityContactRole> checkOCR=new List<OpportunityContactRole>([SELECT ContactId FROM OpportunityContactRole where ContactId IN : conIds]);
        List<Order> checkOrder=new List<Order>([SELECT CustomerAuthorizedById FROM Order where CustomerAuthorizedById  IN : conIds]);
        List<Quote> checkQuote=new List<Quote>([SELECT ContactId FROM Quote where ContactId IN : conIds]);

        
       
        Set<Id> relContactId=new Set<Id>();
        if(!checkTask.isEmpty()){
            for(Task tsk : checkTask){
            relContactId.add(tsk.WhoId);
            }
        }
        if(!checkEvent.isEmpty()){
            for(Event eve : checkEvent){
            relContactId.add(eve.WhoId);
            }
        }
        if(!checkOpp.isEmpty()){
            for(Opportunity opp : checkOpp){
            relContactId.add(opp.Contact__c);
            }
        }
        if(!checkCM.isEmpty()){
            for(CampaignMember cm : checkCM){
            relContactId.add(cm.ContactId);
            }
        }
        if(!checkCase.isEmpty()){
            for(Case cas : checkCase){
            relContactId.add(cas.ContactId);
            }
        }
        
        if(!checkContract.isEmpty()){
            for(Contract contr : checkContract){
            relContactId.add(contr.CustomerSignedId);
            }
        }
        if(!checkOCR.isEmpty()){
            for(OpportunityContactRole ocr : checkOCR){
            relContactId.add(ocr.ContactId);
            }
        }
        if(!checkOrder.isEmpty()){
            for(Order ord : checkOrder){
            relContactId.add(ord.CustomerAuthorizedById);
            }
        }
        if(!checkQuote.isEmpty()){
            for(Quote quo : checkQuote){
            relContactId.add(quo.ContactId);
            }
        }
           for(Contact cont : scope)
            {  
                if(relContactId.contains(cont.Id))
                   {
                       if(cont.Deactivation_date__c < (Date.Today()-ContactWithRelations)){
                       contactsToDelete.add(cont);
                       }
                    }
               else
                          {
                              if(cont.Deactivation_date__c < (Date.Today()-ContactsWORelation)){
                              contactsToDelete.add(cont);
                          }
                          }
                   

            }
        if(contactsToDelete.size() > 0)
        {
           try
            {
                delete contactsToDelete;
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
        mail.setSubject('Contacts Purge Job  ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
         
    }

}