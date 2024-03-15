/**
About
-----
Description: ContentVersionHandler on ContentVersion 
Create date: 22.11-2017

Update History
--------------
Created Nov 2017 - A.D - Created
*/

public class ContentVersionHandler {
    
    public void OnAfterInsert(List<ContentVersion> newList){
        updatedocumenttimestamp(newList);
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * */
    /* * ContentVersionHandler Trigger Methods * */
    /* * * * * * * * * * * * * * * * * * * * * * */
    
    public static void updatedocumenttimestamp(List<ContentVersion> newList){
        MAP<Id,DATETIME> MapOfTimeStamp= new MAP<Id,DATETIME>();
        MAP<Id,String> MapofContentRecords= new MAP<Id,String>();
        SET<Id>ids = new SET<Id>();
        List<Related_Documents__c> updateDocList= new List<Related_Documents__c>();
        
        
        //Get the contentDocId and Timestamp
        for (ContentVersion  c: newList){
            MapOfTimeStamp.put(c.contentDocumentId,c.SystemModstamp);
            MapofContentRecords.put(c.contentDocumentId,c.ReasonForChange);
        }
        ids = MapOfTimeStamp.keyset();
        
        //Get the content link and related ids for the uploaded files
        for(ContentDocumentLink clink:[SELECT ContentDocumentId,LinkedEntityId,LinkedEntity.Type FROM ContentDocumentLink where ContentDocumentId IN:ids]){
            system.debug('LinkedTYpe:-'+clink.LinkedEntity.Type);
            if(clink.LinkedEntity.Type == 'Related_Documents__c'){
                system.debug('VersionRecords'+clink);
                Related_Documents__c retdoc= new Related_Documents__c();
                retdoc.id = clink.LinkedEntityId;
                retdoc.Last_Document_Updated__c = MapOfTimeStamp.get(clink.ContentDocumentId);
                retdoc.File_Comments__c = MapofContentRecords.get(clink.ContentDocumentId) !=null? MapofContentRecords.get(clink.ContentDocumentId): 'No version comment available';
                updateDocList.add(retdoc);
                system.debug('UpdatedList:-'+updateDocList);
                break;
            }
        }
        // Update the related document for the chatter file
        if(updateDocList.size()>0){
            database.update(updateDocList);
        }
    }
}