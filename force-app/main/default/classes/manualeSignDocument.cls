public class manualeSignDocument {
    
    @AuraEnabled
    public static Id updateContract(Id contractId, date rcvddate, date signdate){
        
        system.debug('contractIDMC'+contractId);
        contract con = new contract(id = contractId);
        con.Manual_check__c = True;
        con.status ='Sent for Signing';
        con.TeliaSE_Agreement_Received_Date__c = rcvddate ;
        con.CustomerSignedDate = signdate ;
        system.debug('convalueMC'+con);
        update con;
        DocumentTitle(contractId);
        system.debug('convalueMC Updated'+con);
        return con.Id;
    }
    public static void DocumentTitle(id contractId){
       list<ContentVersion> documentId = [select id, title,ContentDocumentId from contentversion where (FirstPublishLocationId =: contractId AND FileExtension = 'pdf') ORDER BY createddate desc limit 1];
        if(documentId.size() > 0){
            string newTitle = (string)documentId[0].get('title')+'_Manual';
            id docId = id.valueof((string)documentId[0].get('id'));
            ContentVersion updateContentVerTitle = new ContentVersion(id = docId );
            updateContentVerTitle.Title = newTitle;
            update updateContentVerTitle;
        }//End of if
    }
}