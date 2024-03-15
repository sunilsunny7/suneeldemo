global class MCOnline_PdfSizeBatch  implements  Database.Batchable<sObject>,Database.Stateful {
    
    public  List<String> contractIds;
    String query;
    global MCOnline_PdfSizeBatch()
    {
        query='select id,ContentDocumentId from ContentVersion where ContentSize >5000000 and FileType =\'PDF\'';
        contractIds=new List<String>();
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<ContentVersion> versions)
    {
        getContentDocumentLinks(versions);
    }
    
    @TestVisible
    private  void getContentDocumentLinks(List<ContentVersion> versions)
    {
        List<Id> documentIds=new List<Id>();
        for(ContentVersion ver:versions)
        {
            documentIds.add(ver.ContentDocumentId);
        }
       
        for(ContentDocumentLink  link :[select id,LinkedEntityId from ContentDocumentLink  where ContentDocumentId in :documentIds])
        {
            if(String.valueOf(link.LinkedEntityId.getsobjectType())=='Contract')
            {
                contractIds.add(link.LinkedEntityId);
            }
        }
    }
    
    
    
    global void finish(Database.BatchableContext conext)
    {
        sendEmail(JSON.serialize(contractIds));
    }
    
    
    @TestVisible
    private static void sendEmail(String body)
    {
        
        String emailId=System.Label.AMEmailId;
        String[] emailIds=emailId.split(';');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailIds;
        message.optOutPolicy = 'FILTER';
        message.subject = 'Contracts with big PDF document';
        message.plainTextBody = body;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }

}