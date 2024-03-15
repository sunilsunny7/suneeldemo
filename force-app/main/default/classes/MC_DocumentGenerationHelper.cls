/**
 *  Created By: Abhinav Gupta
 *  Calling from Omniscript: Document/ContractDocument
 *  MCSTO-7355: Latest initial Order document is deleted after generating
 */

global class MC_DocumentGenerationHelper  implements vlocity_cmt.VlocityOpenInterface2 {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('deleteOldInitialOrderDocuments')) {
                deleteOldInitialOrderDocuments(inputMap, outMap);
            }
            else if (methodName.equalsIgnoreCase('deleteOldTPPExcelDocuments')){
                deleteOldTPPExcelDocuments(inputMap, outMap);
            }
			else if (methodName.equalsIgnoreCase('changeOrderOfDocument'))
            {
                changeOrderDocuments(inputMap,outMap);
            }
            else {
                result = false;
            }  
        }catch(Exception e) {          
            result = false;
        }        
        return result;    
    }
    
    public static void deleteOldInitialOrderDocuments(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        List<Object> listContentDocuments = (list<Object>) inputMap.get('cdl');
        List<String> cdList = new list<String>();
        Map<String,object> dummyMap = new Map<String,Object>();        
        for(Object ob:listContentDocuments)
        {
            dummyMap = (Map<String,Object>)ob;
            cdList.add((String)dummyMap.get('contentdocumentId'));
        }
        if(cdList.size()>0)
        {
            delete[Select id from contentDocument where id in:cdList];
        }       
    }

	public static void deleteOldTPPExcelDocuments(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        List<Object> listContentDocuments = (list<Object>) inputMap.get('CDLTPP');
        List<String> cdList = new list<String>();
        Map<String,object> dummyMap = new Map<String,Object>();        
        for(Object ob:listContentDocuments)
        {
            dummyMap = (Map<String,Object>)ob;
            cdList.add((String)dummyMap.get('contentdocumentId'));
        }
        if(cdList.size()>0)
        {
            delete[Select id from contentDocument where id in:cdList];
        }       
    }
    
     public static void changeOrderDocuments(Map<String,Object> inputMap, Map<String,Object> outMap) {
        String contextId = (String) inputMap.get('ContextId');
        system.debug(contextId);
        List<Object> listContentDocuments = (list<Object>) inputMap.get('cdl');
        Boolean latestInitialOrderDocumentFound = false;
        String InitialOrderDocumentName;
        List<String> contentDocumentId = new List<String>();
		Boolean latestAgreementDocumentFound = false;
        String agreementContentDocumentLinkId; 
        string agreementContentDocumentId;
    	Map<String,object> dummyMap = new Map<String,Object>();        
        for(Object ob:listContentDocuments) {
            dummyMap = (Map<String,Object>)ob;
            string documentName = (String) dummyMap.get('Name');
            if(documentName.startsWithIgnoreCase('Initial beställning för')) {
                If(latestInitialOrderDocumentFound){
                    contentDocumentId.add((String)dummyMap.get('contentdocumentId'));
                    InitialOrderDocumentName = documentName;
                }
                else {
                    latestInitialOrderDocumentFound = true;
                }
            }
            else if(documentName.startsWithIgnoreCase('Avtal RA'))  {
                if(!latestAgreementDocumentFound) {
                    agreementContentDocumentId = (String) dummyMap.get('contentdocumentId');
                    agreementContentDocumentLinkId = (String) dummyMap.get('id');
                    latestAgreementDocumentFound = true;
                }
            }
        } 
        list<ContentDocument> cdList = new List<ContentDocument>();
        if(contentDocumentId.size()>0){
            for(String cdId : contentDocumentId) {
                ContentDocument cd = new ContentDocument();
                cd.id = cdId;
                cd.title =InitialOrderDocumentName.replaceAll(' ','_');
                cdList.add(cd);
            }
            try {
            	update cdList;    
            }
            catch(Exception e) {
                system.debug(e.getStackTraceString());
                system.debug(e);
            }
            
        }
        //boolean failure = false;
        if(agreementContentDocumentId != null)
        {
        	insertContentDocumentLink(agreementContentDocumentId, agreementContentDocumentLinkId, contextId, false);
        }  
    }
    
    public static void insertContentDocumentLink(String contentDocumentId,String agreementContentDocumentLinkId, String linkedEntityId, Boolean failure){
        ContentVersion  cont =[SELECT Checksum,ContentDocumentId,ContentLocation,ContentSize,ContentUrl,Description,FileExtension,FileType,FirstPublishLocationId,Id,IsAssetEnabled,IsDeleted,Origin,OwnerId,PathOnClient,PublishStatus,RatingCount,ReasonForChange,SharingOption,Title,VersionData,VersionNumber FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId];       
        ContentVersion newcont = new ContentVersion();
        newcont.Title  = cont.Title;
        newcont.PathOnClient  = cont.PathOnClient;
        newcont.VersionData = cont.VersionData;
        newcont.FirstPublishLocationId  = cont.FirstPublishLocationId;
        
        try{
            insert newcont;    
        }
        catch(Exception e) {
            system.debug('***********ContentVersion Error*************' + e);
            failure = true;
        }
        if(!failure) {
            ContentVersion  contVersion =[SELECT Checksum,ContentDocumentId,ContentLocation,ContentSize,ContentUrl,Description,FileExtension,FileType,FirstPublishLocationId,Id,IsAssetEnabled,IsDeleted,Origin,OwnerId,PathOnClient,PublishStatus,RatingCount,ReasonForChange,SharingOption,Title,VersionData,VersionNumber FROM ContentVersion WHERE id=: newcont.id];                
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.linkedEntityId = linkedEntityId;
            cdl.contentdocumentid = contVersion.ContentDocumentId;
            cdl.shareType = 'V';
            cdl.Visibility = 'AllUsers';
            
            try {
                insert cdl;
            }
            catch(Exception e)  {
                system.debug('**************CDL Error**************' +e);
                failure = true;
            }                    
        }
        System.debug('failure-->'+failure);
        if(!failure)  {
            ContentDocumentlink cdl = new ContentDocumentlink();
            cdl.id = agreementContentDocumentLinkId;
            delete cdl;
        }
    }
}