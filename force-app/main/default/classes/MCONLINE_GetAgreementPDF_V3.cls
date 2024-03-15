global with sharing class MCONLINE_GetAgreementPDF_V3 implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        if(methodName.equals('contentsize'))
        {  
            contentsize(inputMap, outMap);
        }
        
        
        return true;
    }
    
    /*=========================================================================================================================================    
ContentDocument : List<map<String,Object>> This will hold the agreement Id of the agreements which have the madam number and are active
This is passed in the outmap and will be used as an input in the DR, avoiding the extra query in the DR
===========================================================================================================================================*/   
    private static void contentsize(Map<String,Object> inputMap, Map<String,Object> outMap){
        String madamNumber = (String)inputMap.get('AgreementNumber');
        set<Id> docIds = new set<Id>();
        List<map<String,Object>> ContentDocument = new List<map<string,Object>>();
        decimal contentsize;
        for(scrive__ScriveDocument__c link:[SELECT id,scrive__status__c,scrive__contract__c FROM scrive__ScriveDocument__c where scrive__contract__c in (select id from Contract where Agreement_Nr__c =: madamNumber AND Status = 'Active') AND scrive__status__c = 'Signed']){
            docIds.add(link.id);
            ContentDocument.add(new Map<String, Object> {'Agr_Id'=>link.scrive__contract__c});           
        }
        if(docIds.size() > 0){
            AggregateResult ar = [select sum(BodyLength) size from Attachment where ParentId =: docIds];
            contentsize = (decimal)ar.get('size');
            outMap.put('contentsize',contentsize);
            outMap.put('ContentDocument',ContentDocument);
        }
        else{
            outMap.put('DocError','no valid document');
        }
    }
    
    
}