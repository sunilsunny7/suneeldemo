global with sharing class TeliaSE_FileAttachment implements vlocity_cmt.VlocityOpenInterface{
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        if(methodname == 'copyContentVersionApprovalFlow'){
            /*try{
                Map<String,Object> step1 = (Map<String,Object>)inputs.get('Approval');
                List<Object> files =(List<Object>) step1.get('Input_File');
                Map<String,Object> file1 = (Map<String,Object>) files[0];
                string contentId = (String) file1.get('data');
                string contextId = (String)inputs.get('ContextId');
                
                List<ContentDocumentLink> cdlExist = [Select id from ContentDocumentLink where contentdocumentid=:contentId AND linkedEntityId=:contextId];
                if(cdlExist.size()>0){
                    return true;
                }
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.linkedEntityId = contextId;
                cdl.contentdocumentid = contentId;
                cdl.shareType = 'V';
                cdl.Visibility = 'AllUsers'; 
                insert cdl;
            }catch(Exception e){
                system.debug(e);
                return true;
            }*/
            return true;           
        }
        else if(methodname == 'copyContentVersionUtilizerFlow'){
           /* try{
                Map<String,Object> step1 = (Map<String,Object>)inputs.get('AddUtilizerAccount');
                List<Object> files =(List<Object>) step1.get('File');
                Map<String,Object> file1 = (Map<String,Object>) files[0];
                string contentId = (String) file1.get('data');
                string contextId = (String)inputs.get('ContextId');  
                List<ContentDocumentLink> cdlExist = [Select id from ContentDocumentLink where contentdocumentid=:contentId AND linkedEntityId=:contextId];
                if(cdlExist.size()>0){
                    return true;
                }
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.linkedEntityId = contextId;
                cdl.contentdocumentid = contentId;
                cdl.shareType = 'V';
                cdl.Visibility = 'AllUsers'; 
                insert cdl;
            }catch(Exception e){
                system.debug(e);
                return true;
            }*/
            return true;           
        }
        return false;
    }
}