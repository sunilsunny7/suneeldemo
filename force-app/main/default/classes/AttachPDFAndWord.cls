global without sharing class AttachPDFAndWord implements vlocity_cmt.VlocityOpenInterface{
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     Boolean result = true;
        try
        {
            if (methodName.equals('attachPdf'))
            {
                attachPdf(inputMap,outMap);
            }
               
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {
            System.debug('exception: '+e);
            result = false;
            outMap.put('ErrorAgreement','Error');
            outMap.put('ErrorMessage',e.getMessage());
        }
        return result;
    }
    
private static void attachPdf(Map<String,Object> inputMap,Map<String,Object> outMap)
{
    String agreementId=(String)inputMap.get('ContextId');
    Contract con=[select Account.Name,ContractNumber from Contract where id=:agreementId];
    String num=con.ContractNumber;
    String cusName=con.Account.name;
    String createdDate = String.valueOf(dateTime.now());
    ContentDocumentLink link=[SELECT Id, ContentDocument.Title, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:agreementId order by systemModStamp desc limit 1]; 
    
    HttpRequest req=new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        req.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v45.0/connect/files/'+link.ContentDocumentId+'/rendition?type=PDF');
    HttpResponse response = new Http().send(req);
    
    ContentVersion conVer = new ContentVersion();
    
              String var = link.ContentDocument.Title;
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient ='Avtal '+num+'_Telia_'+cusName+'_'+createdDate+'.pdf'; 
            conVer.Title = var.substringBefore('.docx') + '.pdf';              // edited/added by Monika
            conVer.VersionData = response.getBodyAsBlob(); 
    insert conVer;
            
    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            
    ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = agreementId; 
            cDe.ShareType = 'I'; 
    insert cDe; 
   // delete link;
   ContentDocumentLink cDe1 = new ContentDocumentLink();
    cDe1.ContentDocumentId = link.ContentDocumentId;
    cDe1.LinkedEntityId = agreementId;
    insert cDe1;
}
}