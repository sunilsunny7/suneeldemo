public class OnLoadController{
    
    @AuraEnabled
    public static Map<String,String> deleteFiles(Id caseIds){
    Id caseId;
    Map<String,String> resultMap = new Map<String,String>();
    List<ContentDocumentLink> cdl=new List<ContentDocumentLink>();
    Set<Id> contentDocIds = new Set<Id>();
    Set<Id> docIdsToDelete= new Set<Id>();
    List<ContentVersion> contentVersions = new List<ContentVersion>();
    Case caseCheck =[Select Id,Account.CM_Final_Traffic_Marketing__c,Parent.Account.CM_Final_Traffic_Marketing__c,Account.CM_Final_Traffic_Service_Network__c,Parent.Account.CM_Final_Traffic_Service_Network__c,RecordTypeId from Case where Id =: caseIds];
    //System.debug('caseCheck' +caseCheck + 'caseCheck.Account.CM_Final_Traffic_Marketing__c' +caseCheck.Account.CM_Final_Traffic_Marketing__c);
    
    if(caseCheck.RecordTypeId == SEUTility.getRecordTypeId('Enterprise_Subcase') || caseCheck.RecordTypeId  == SEUTility.getRecordTypeId('Enterprise')){
    if(caseCheck.Account.CM_Final_Traffic_Marketing__c=='Denied' || caseCheck.Parent.Account.CM_Final_Traffic_Marketing__c=='Denied' || caseCheck.Account.CM_Final_Traffic_Service_Network__c=='Denied' || caseCheck.Parent.Account.CM_Final_Traffic_Service_Network__c=='Denied' || Test.isRunningTest())
    {
    caseId = caseCheck.Id;
    }
    }
    
    //System.debug('caseId' +caseId);
    
    if(caseId!=null){
    cdl= [SELECT ContentDocumentId,LinkedEntityId,LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId =: caseId];
    }
    //System.debug('cdl' +cdl);
    
    if(cdl.size()>0){
    for(ContentDocumentLink contentDocLink : cdl) {
    contentDocIds.add(contentDocLink.ContentDocumentId);
    }
    }
   // System.debug('ContentDocIds' +contentDocIds);
    
    if(contentDocIds.size()>0){
    contentVersions = [SELECT Id,ContentUrl,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocIds  AND Traffic_Personal_Data__c  = True];    
    }
    
    //System.debug('ContentVersion' +contentVersions);
    
    if(contentVersions.size()>0){
    for(ContentVersion cv: contentVersions){
    docIdsToDelete.add(cv.ContentDocumentId); 
    }
    }
    List<ContentDocumentLink> docDelete=new List<ContentDocumentLink>();
    //System.debug('Content Document Ids to delete' +docIdsToDelete);
    if(docIdsToDelete.size()>0){
    docDelete= [SELECT ContentDocumentId,LinkedEntityId,LinkedEntity.Type FROM ContentDocumentLink where ContentDocumentId =: docIdsToDelete AND LinkedEntityId =: caseId];
    }
   // System.debug('Final Docs' +docDelete);
    
    Set<Id> ids =new Set<Id>();
    
    for(ContentDocumentLink cdl1 : docDelete){
    ids.add(cdl1.ContentDocumentId);
    }
    List<ContentDocument> cd=[Select Id from ContentDocument where Id IN : ids];
    try {
    if(docDelete.size()>0 || cd.size()>0){
    
    delete docDelete;
    delete cd;
    resultMap.put('status', 'success');
    }
    
    }
    
    catch(Exception e) {
    // Setting the error status and message in resultMap
    resultMap.put('status', 'error');
    resultMap.put('message',e.getMessage());
    }
    // Returning the result string map
    return resultMap;            
    
    }
    
    }