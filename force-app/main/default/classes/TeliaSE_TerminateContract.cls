global without Sharing class TeliaSE_TerminateContract implements vlocity_cmt.VlocityOpenInterface{
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     Boolean result = true;
        try
        {
            if (methodName.equals('getStatus'))
            {   
                getStatus((String)inputMap.get('ContextId'));
            }
            else if (methodName.equals('validateStatus'))
            {   
                validateStatus(inputMap,outMap,options);
            }
            else if (methodName.equals('cancelScriveDocument'))
            {   
                cancelScriveDocument(inputMap,outMap,options);
            }
            else if (methodName.equals('viewScriveDocument'))
            {   
                viewScriveDocument(inputMap,outMap,options);
            }
            else if (methodName.equals('validateRevisedContract'))
            {   
                validateRevisedContract(inputMap,outMap,options);
            }
            else if (methodName.equals('unlockContract'))
            {   
                unlockContract(inputMap);
            }
            else if (methodName.equals('validateEsign'))
            {
                validateEsign(inputMap,outMap);
            }
            else if(methodName.equals('confirmationReset')){
                confirmationReset(inputMap,outMap);
            }
            else if(methodName.equals('resetCommercialTerms')){
                String contractId = (String)inputMap.get('contextId');
                resetCommercialTerms(contractId);
            }
            

            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {
            System.debug('exception: '+e.getStackTraceString());
            result = false;
        }
        return result;
    }

    
    public static void validateRevisedContract(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Id contextId = (String)inputMap.get('contextId');
        String sobjectType = contextId.getSObjectType().getDescribe().getName();
        if(sobjectType == 'Contract'){
            string oldPortfolio_ModificationErrorMessage = System.label.TeliaSE_OldPortfolio_ModificationErrorMessage;
            if(contextId == null) contextId = (String)inputMap.get('contextId');
            Contract qut = [Select id, Status from Contract where id=: contextId ];
            Boolean retiredPortofolioExist = retiredPortfolioExist(contextId);
            if(qut.status == 'Approved' || qut.status == 'Draft' || qut.status == 'Sent for Signing' || qut.status == 'Rejected') {            
                outMap.put('TerminateContractType','AndraPrisforhandling_TerminateTUPP');
                outMap.put('Warning','Är du säker på att du vill ändra prisförhandlingen?Tryck på Continue för att komma tillbaka till varukorgen.');
                if(retiredPortofolioExist == true && qut.status!='Rejected'){
                    outMap.put('Warning',oldPortfolio_ModificationErrorMessage);
                }
            }
            else if(qut.status == 'Sent for Approval') {
                outMap.put('TerminateContractType','AndraPrisforhandling_SentForApproval');
                outMap.put('Warning','Du måste dra tillbaka godkännande innan du kan ändra status till "utkast".');     
            }         
            else if( qut.status == 'Signed') {
                outMap.put('TerminateContractType','AndraPrisforhandling_Signed');
                outMap.put('Warning','Om du vill ändra status från "Signed" genom att ändra prisförhandling, måste ärendet i TUPP raderas. Kontakta avtalshandläggare genom att skicka ett meddelande i TUPP-ärendet innan du ändrar i prisförhandlingen');
            }
        }else if(sobjectType == 'Quote'){
            List<Contract> con = [Select id, Status from Contract where vlocity_cmt__QuoteId__c =: contextId and Status != 'Cancelled' limit 1];
            if(con.size() > 0){
                Contract qut = con[0];
                if(qut.status == 'Approved' || qut.status == 'Draft' || qut.status == 'Sent for Signing' || qut.status == 'Rejected') {            
                    outMap.put('TerminateContractType','AndraPrisforhandling_TerminateTUPP');
                    outMap.put('Warning','Är du säker på att du vill ändra prisförhandlingen?Tryck på Continue för att komma tillbaka till varukorgen.');
                }else if(qut.status == 'Sent for Approval') {
                    outMap.put('TerminateContractType','AndraPrisforhandling_SentForApproval');
                    outMap.put('Warning','Du måste dra tillbaka godkännande innan du kan ändra status till "utkast".');     
                }else if( qut.status == 'Signed') {
                    outMap.put('TerminateContractType','AndraPrisforhandling_Signed');
                    outMap.put('Warning','Om du vill ändra status från "Signed" genom att ändra prisförhandling, måste ärendet i TUPP raderas. Kontakta avtalshandläggare genom att skicka ett meddelande i TUPP-ärendet innan du ändrar i prisförhandlingen');
                }else if( qut.status == 'Active') {
                    outMap.put('Error','Avtalet är aktivt så det går ej att göra förändringar i varukorgen');
                }
            }
            else{
                outMap.put('Warning','Är du säker på att du vill ändra prisförhandlingen?Tryck på Continue för att komma tillbaka till varukorgen.');
            }            
        }     
    }
    
    public static void viewScriveDocument(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        string contextId = (String)inputMap.get('ContextId');
        if(contextId == null) contextId = (String)inputMap.get('contextId');
        
        if(contextId != null) {
            List<scrive__ScriveDocument__c> scDocList = [select id from scrive__ScriveDocument__c where scrive__Contract__c =: contextId 
                                                         order by LastModifiedDate];
            if(scDocList != null) {
                scrive__ScriveDocument__c scDoc = scDocList[0];
                outMap.put('scriveId',scDoc.Id);
            } else outMap.put('Warning','No Scrive Document to view');
        }
    }
    
    
    public static void validateStatus(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        string contextId = (String)inputMap.get('ContextId');
        if(contextId == null) contextId = (String)inputMap.get('contextId');
        Contract qut = [Select id, Status from Contract where id=: contextId ];
        if(qut.status == 'Approved' || qut.status == 'Rejected' || qut.status == 'Active' || qut.status == 'Draft' || qut.status == 'Sent for Approval' || qut.status == 'Sent for Signing' || qut.status == 'Cancelled') {
            outMap.put('Warning','Är du säker på att du avbryta avtalet? Avtalet kommer att ändra status till "Avslutad". Tryck på Continue för att avbryta avtalet.');
        }
        else if( qut.status == 'Signed') {
            outMap.put('Warning','Om du vill ändra status från "Signed" genom att avbryta avtalet, måste ärendet i TUPP raderas. Kontakta avtalshandläggare genom att skcika ett meddelande i TUPP-ärendet.');
        }        
        
    }

    public static String getStatus(String contractId) {
        Contract contract = [select status from contract where id =: contractId]; 
        return contract.status;
    }    
    


    public static void cancelScriveDocument(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        string contextId = (String)inputMap.get('contextId');
        if(contextId == null) contextId = (String)inputMap.get('ContextId');

        Contract qut = [Select id, Status from Contract where id=: contextId ];
        List<scrive__ScriveDocument__c> scDocList = [select scrive__status__c,id from scrive__ScriveDocument__c where scrive__Contract__c =: contextId 

                                           order by LastModifiedDate DESC];

        if(scDocList != null) {
            scrive__ScriveDocument__c scDoc = scDocList[0];
            
            if(scDoc.scrive__status__c != 'Withdrawn') {
                Scrive.ScriveGlobal.ScriveDocumentResult result = scrive.ScriveGlobal.withdraw(scDoc.Id);


                
                if(!result.isSuccess){
                     outMap.put('Warning','Not Cancelled....');
                } else {
                    outMap.put('Warning','.... Cancelled....');
                }
            }
        }
    }



    public static void unlockContract(Map<String,Object> inputMap){
        Id conId = Id.valueOf((String)inputMap.get('ContextId'));
        if(Approval.isLocked(conId)){
            Approval.unlock(conId);
        }
    }

    
    //Mobile portfolio v3
    public static boolean retiredPortfolioExist(id contractId)
    {
        List<String> productIds = new List<String>();
        for (String tc: TeliaSE_PortfolioIdentifiers__c.getAll().keySet())
        {
            if(TeliaSE_PortfolioIdentifiers__c.getAll().get(tc).ProductId__c != null)
            {
                productIds.add(TeliaSE_PortfolioIdentifiers__c.getAll().get(tc).ProductId__c);
            }
        }
        //ProductIds include retired productIds updated in portfolio identifiers
        List<vlocity_cmt__ContractLineItem__c> cliItemList = [Select id from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =: contractId and vlocity_cmt__Product2Id__c IN: productIds]; 
        if(cliItemList.size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public static void validateEsign(Map<String,Object> inputMap, Map<String,Object> outputMap)
    {
        string contextId = (String)inputMap.get('ContextId');
        if(contextId == null) contextId = (String)inputMap.get('contextId');
        Boolean retiredPortofolioExist = retiredPortfolioExist(contextId); 
        if(retiredPortofolioExist)
        {
            outputMap.put('Error','Ny portfölj lanserad, du måste börja om med ny offert.');
        }
        else
        {
            outputMap.put('Warning',System.label.TeliaSE_Sales_ConfirmationMessage);
        }
    }
    private void confirmationReset(Map<String,Object> inputMap, Map<String,Object> outputMap){
        outputMap.put('Warning',System.label.resetCommercialTerms);
    }    
    private void resetCommercialTerms(String contractId){
        Contract con = new Contract();
        con.Id = contractId;
        con.Customer_unique_terms_Approved__c = false;
        update con;
         Approval.unlock(con, false);
       
    }
}