/**
* @Author:      Abhinav Gupta
* @Company:     Capgemini
* @Date:        07 May, 2020
* @Description: This class controller is used to handle remove utilizers case and hit integration procedures accordingly.
*
* History
* <Date>           <Authors Name>      <Brief Description of Change>
* -------------------------------------------------------------
*/
Public class UpdateUtiliserStatusCustomController {
    public List<Utilizer_Contract_Relationship__c> SelectedRecords {get;set;}
    private ApexPages.StandardSetController controller;
    PageReference RetPageRef;
    public Integer numberOfSelectedRows {get; set;}
    public Boolean validUtilizers {get; set;}
    public Boolean draftAgreement {get; set;}
    Final Integer Batch = 90;
    
    public UpdateUtiliserStatusCustomController(ApexPages.StandardSetController controller)
    {    
        this.controller = controller;
        SelectedRecords = controller.getSelected();
        numberOfSelectedRows = SelectedRecords != null ? SelectedRecords.size() : 0;
        validUtilizers = true;
        draftAgreement = false;
        If(numberOfSelectedRows!= 0)
        {
            
            List<Utilizer_Contract_Relationship__c> validationRecords = [Select id,status__c,ContractNumber__c from Utilizer_Contract_Relationship__c where id IN: SelectedRecords];
            for(Utilizer_Contract_Relationship__c ucr:validationRecords)
            {
                If(ucr.Status__c == 'PendingActive' || ucr.Status__c == 'PendingInactive' || ucr.Status__c == 'Manual')
                {
                    validUtilizers = false;
                }
            }
        }
    }
    
    public PageReference updateSelectedRecords()
    {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> finalInputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        String contractId;
        List<Utilizer_Contract_Relationship__c> selectedRecordsUpdated = new List<Utilizer_Contract_Relationship__c>();
        If(( SelectedRecords != null && SelectedRecords.size() > 0) && validUtilizers)
        {      
            List<Utilizer_Contract_Relationship__c> selectedRecords = [Select id,status__c,ContractNumber__c from Utilizer_Contract_Relationship__c where id IN: SelectedRecords];
            contractId = selectedRecords[0].ContractNumber__c;  
            inputMap.put('ContractId',contractId);
            
            // Draft Status Check
            Contract con = [Select id,Account.FA_Contract__c,Status from Contract where id =: contractId];
            If(contractId == con.Account.FA_Contract__c)
            {
                If(con.status != 'Active')
                {
                    PageReference retref = redirect(contractId);
                    return retref;
                }
                
                for(Utilizer_Contract_Relationship__c ucr:selectedRecords)
                {
                    If (ucr.Status__c == 'Aktiv' )
                    {
                        selectedRecordsUpdated.add(ucr);
                    }
                }  
                if(selectedRecordsUpdated != null && selectedRecordsUpdated.size()>0)
                {
                    //Updating status of selected activ utilizers to Inacktiv.
                    // REST API call to update status of utilizers. After which integration procedure is called to set utilizers and create case.
                    updateUtilizerRelationship(selectedRecordsUpdated);    
                }
                String METHODNAME_SETUTILIZERSAGREEMENT = 'setUtilizers';
                //  TeliaSE_UpdateContract_TUPP updateContract = new TeliaSE_UpdateContract_TUPP();
                if(inputMap != null)
                { 
                    Map<String,Object> Ipresult = setUtilizers(inputMap, outMap, options,selectedRecordsUpdated);
                }
                PageReference retref = redirect(contractId);
                return retref; 
            }  
            else
            {
                draftAgreement = true;
            }
            
        }
        return null;
    }
    
        
    private PageReference redirect(String contractId)
    {
        String redirectUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/'+contractId+'/related/Utilizer_Contract_Relationships__r/view';
        PageReference retURL = new PageReference(redirectUrl);
        retURL.setRedirect(true);
        return retURL;
    }
    
    
    public static void updateUtilizerRelationship(List<Utilizer_Contract_Relationship__c> relationList){
        RequestBody requestBody = new  RequestBody();
        List<CompositeRequest> requestList = new List<CompositeRequest>();
        try{
            for(Utilizer_Contract_Relationship__c ur : relationList){
                compositeRequest cr = new compositeRequest();
                cr.method = 'PATCH';
                cr.url = '/services/data/v38.0/sobjects/Utilizer_Contract_Relationship__c/'+ur.Id;
                cr.referenceId = String.valueOf(ur.Id);
                Map<String, String> bodyMap = new Map<String, String>();
                bodyMap.put('Status__c', 'PendingInactive');
                cr.body = bodyMap;
                requestList.add(cr);
                requestBody.compositeRequest = requestList;
            }
        
            String requestbodyString = JSON.serialize(requestBody);
            requestbodyString = requestbodyString.replace('\'', '"');
            HttpRequest request = new HttpRequest();
            string baseurl = URL.getSalesforceBaseUrl().toExternalForm();
            request.setEndpoint(baseurl+'/services/data/v48.0/composite');
            request.setBody(requestbodyString);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer '+Userinfo.getSessionId());
            Http http = new Http();
            HttpResponse response = http.send(request);
        }catch(Exception ex){
            system.debug('Exception on updateUtilizerRelationship : '+ex.getStackTraceString());
        }
    }
     public static Map<String,Object> setUtilizers(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options,List<Utilizer_Contract_Relationship__c> relationList){
        String methodName = 'TUPP_setUtilizers';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        TeliaSE_TUPPIntegrationHandler tuppIntHndlr = new TeliaSE_TUPPIntegrationHandler();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
            Map<String,Object> result = (Map<String,Object>)ipresult.get('result');
            Id passedContractId = (string)inputMap.get('ContractId');
            tuppIntHndlr.updateContractSetUtilizers('setUtilizers', ipresult, passedContractId,relationList);
            return ipresult;
        }catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            return null;
        }
        
    }
    
    public class CompositeRequest
    {
        public string method { get; set; }
        public string url { get; set; }
        public string referenceId { get; set; }
        public Map<String, Object> body { get; set; }
    }

    public class RequestBody
    {
        public List<CompositeRequest> compositeRequest { get; set; }
    }  
}