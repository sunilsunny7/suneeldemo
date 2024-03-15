/**
About
-----
Description: Controller for Alpha Case Lightning action compononents.
Create date: 01.05.2017

Update History 
--------------
Created May 2017 - Created by Vahraz Mostajir
*/

global class CaseAlphaController{
    
    //Case Satus
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_IN_PROGRESS = 'In Progress';
    
    //Alpha Sync Satus
    public static final String CASE_ALPHA_SYNC_STATUS_OK = 'OK, Case sent to Alpha';
    public static final String CASE_ALPHA_SYNC_STATUS_WARNING = 'Warning: Attachments not sent to Alpha';
    public static final String CASE_ALPHA_SYNC_STATUS_ERROR = 'Error, Case not sent to Alpha';
    public static final String CASE_ENDPOINT_URL = 'GESB URL';
    
    //Alpha Error Codes
    public static final String ALPHA_ATTACHMENT_ERROR_CODE = 'Bilagefel';
    
    private static Boolean HasError { get; set; }
    private static List<String> ErrorMsgs { get; set; }
    
    public class ActionStatus{
        public String ErrorMessages {get; set;}
        public String SuccessMessage {get; set;}
        public Boolean IsSuccess {get; set;}
        public Boolean EnableSend {get; set;}
        public Boolean EnableRefresh {get; set;}
        public String FieldValidations {get; set;}
    }
    
    // For Lightning
    @AuraEnabled
    public static String sendToAlphaL(String caseId){    
        return sendCaseToAlpha(caseId);      
    }
    
    // For Lightning
    @AuraEnabled
    public static String refreshFromAlphaL(String caseId){
        return refreshCaseFromAlpha(caseId);    
    }
    
    @AuraEnabled
    public static String getCase(String caseId){
        
        String fields = '';
        
        Case caseRecord =  [SELECT Id,
                            Subject,
                            Organisation_Number__c,
                            Case_Group__c,
                            Description,
                            Alpha_Id__c
                            FROM Case 
                            WHERE Id = :caseId  
                            LIMIT 1];  
        
        if(String.isBlank(caseRecord.Subject)){
            fields += 'Subject ';
        }
        if(String.isBlank(caseRecord.Organisation_Number__c)){
            fields += 'Organisation Number ';
        }
        if(String.isBlank(caseRecord.Case_Group__c)){
            fields += 'Case Group ';
        }
        if(String.isBlank(caseRecord.Description)){
            fields += 'Description ';
        }
        
        ActionStatus actionStatus = new ActionStatus();
        
        if(fields != '' || caseRecord.Alpha_Id__c != Null){
            actionStatus.EnableSend = False;
            actionStatus.FieldValidations += fields;
        }else{
              actionStatus.EnableSend = True;
        }
        
        if(caseRecord.Alpha_Id__c == Null){
            actionStatus.EnableRefresh = False;
        }else{
            actionStatus.EnableRefresh = True;
        }
        
        system.debug('JSON Value: '+ JSON.serialize(actionStatus));
        return JSON.serialize(actionStatus);
        
    }
    
    
    // SAEN-2251: Create Case To Alpha; Send a webservice request to GESB
    // when the user press 'Send to Alpha' in subcase with data from Alpha  
    public static String sendCaseToAlpha(string caseId){
        Case caseRecord = [SELECT Id,
                           Account.Name,
                           Product_Area__C, 
                           Subject,
                           Current_Alpha_Queue__c,
                           Organisation_Number__c,
                           Case_Group__c,
                           Alpha_Id__c,
                           Customer_Name__c,
                           TCID__c,
                           Description,
                           To_Alpha_Queue__c,
                           Origin,
                           HasAttachment__c,
                           CaseNumber,
                           Category__c FROM Case 
                           WHERE Id = :caseId  
                           LIMIT 1];
        
        //Classes are generated from the WSDL
        GESBCaseService.ServicePortTypeEndpoint createCaseCallout = new GESBCaseService.ServicePortTypeEndpoint();
        GESBCaseService.CreateCaseRequest caseRequest = new GESBCaseService.CreateCaseRequest();
        GESBCaseService.CreateCaseResponse caseResponse = new GESBCaseService.CreateCaseResponse();
        
        //Get the AlphaQueue values
        Map<String, Decimal> queueValues = new Map<String, Decimal>();
        for (EnterpriseSubcaseQueue__c queue : EnterpriseSubcaseQueue__c.getAll().values()){
            queueValues.put(queue.Alpha_Queue__c, queue.Alpha_Queue_Id__c);
        }
        
        //Get the Url Value from the custom setting
        GESB_EndPointURL__c endpoint = GESB_EndPointURL__c.getInstance(CASE_ENDPOINT_URL);
        If(string.isNotBlank(endpoint.EndPointURL__c)){
            createCaseCallout.endpoint_x =  endpoint.EndPointURL__c;
        }

        Blob headerValue = Blob.valueOf(endpoint.Authentication__c);

		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        createCaseCallout.inputHttpHeaders_x = new Map<String, String>();
        createCaseCallout.inputHttpHeaders_x.put('authorization', authorizationHeader); 
        createCAseCallout.timeout_x = 1000 * 60 * 2;
        
        //The request we send to GESB
        caseRequest.caseId = caseRecord.Id;
        caseRequest.caseNumber = caseRecord.CaseNumber;
        caseRequest.organizationNumber = caseRecord.Organisation_Number__c;
        caseRequest.customerName = caseRecord.Account.Name;
        caseRequest.tcid = caseRecord.TCID__c;
        caseRequest.problemSummary = caseRecord.Subject;
        caseRequest.groupName = caseRecord.To_Alpha_Queue__c;
        caseRequest.hasAttachment = caseRecord.HasAttachment__c;
        caseRequest.note = 'Skapad av: ' 
            + caseRecord.Case_Group__c 
            + '\n'    
            + 'Kategori: ' 
            + caseRecord.Category__c
            + ', Produkt område: '
            + caseRecord.Product_Area__C 
            + ', Salesforce ärende: '
            + caseRecord.CaseNumber
            +'\n-----------------\n'  
            + caseRecord.Description;
        
        if(String.isNotEmpty(caseRecord.To_Alpha_Queue__c)){
            caseRequest.groupId = queueValues.get(caseRecord.To_Alpha_Queue__c).intValue();
        }
        
        ErrorMsgs = new List<String>();
        HasError = false;
        
        //JSON object we return to the Lightning Component
        ActionStatus actionStatus = new ActionStatus();
        
        try {
            caseResponse = createCaseCallout.createCase(caseRequest);
            System.debug(caseResponse);
            
            //GESB Success code           
            if(caseResponse.statusCode == 0){
                caseRecord.Alpha_Id__c = caseResponse.alphaCaseId;
                
                if(caseResponse.statusMessage == null){
                    caseRecord.Alpha_Sync_Status__c = CASE_ALPHA_SYNC_STATUS_OK;
                    actionStatus.SuccessMessage = CASE_ALPHA_SYNC_STATUS_OK;
                }else{
                    caseRecord.Alpha_Sync_Status__c = CASE_ALPHA_SYNC_STATUS_WARNING;
                    actionStatus.SuccessMessage = CASE_ALPHA_SYNC_STATUS_WARNING;
                }
            }
            else{
                HasError = true;
                caseRecord.Alpha_Sync_Status__c = CASE_ALPHA_SYNC_STATUS_ERROR;               
                
                ErrorMsgs.add(caseResponse.statusMessage);
            }
            
            update caseRecord; 
            
        } catch(Exception e) {
            System.debug('Callout error: '+ e.getMessage());
            HasError = True;
            ErrorMsgs.add(e.getMessage());
        }
        
        If(HasError){
            actionStatus.IsSuccess = False;
            actionStatus.ErrorMessages = Label.AC_Send_Error_Message; // string.join(ErrorMsgs,'\n');
            actionStatus.EnableSend = True;
            actionStatus.EnableRefresh = False;
        }else{
            actionStatus.IsSuccess = True;
            actionStatus.EnableSend = False;
            actionStatus.EnableRefresh = True;
            actionStatus.SuccessMessage = Label.AC_Send_Success_Message + CaseRecord.Alpha_Id__c;
        }
        
        system.debug('JSON Value: '+ JSON.serialize(actionStatus));
        return JSON.serialize(actionStatus);
    }     
    
    // SAEN-2296: For refreshCaseAlpha; Send a webservice request to GESB
    // when the user press 'Refresh Alpha' button in subcase with data from Alpha     
    public static String refreshCaseFromAlpha(String caseId){
        
        Case caseRecord = [SELECT Id, 
                           Alpha_Id__c,
                           CaseNumber,
                           Category__c 
                           FROM Case
                           WHERE Id = :caseId  
                           LIMIT 1];
        
        //Classes are generated from the WSDL
        GESBCaseService.ServicePortTypeEndpoint refreshCaseCallout = new GESBCaseService.ServicePortTypeEndpoint();
        GESBCaseService.RefreshCaseRequest caseRequest = new GESBCaseService.RefreshCaseRequest();
        GESBCaseService.RefreshCaseResponse caseResponse = new GESBCaseService.RefreshCaseResponse();
        
        //Get the Url Value from the custom setting
        GESB_EndPointURL__c endpoint = GESB_EndPointURL__c.getInstance(CASE_ENDPOINT_URL);
        If(string.isNotBlank(endpoint.EndPointURL__c)){
            refreshCaseCallout.endpoint_x =  endpoint.EndPointURL__c;
        }

        Blob headerValue = Blob.valueOf(endpoint.Authentication__c);

		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        refreshCaseCallout.inputHttpHeaders_x = new Map<String, String>();
        refreshCaseCallout.inputHttpHeaders_x.put('authorization', authorizationHeader); 
        
        caseRequest.alphaCaseId = caseRecord.Alpha_Id__c;
        caseRequest.sfdcCaseId = caseRecord.Id;
        caseRequest.sfdcNumber = caseRecord.CaseNumber;
        
        ErrorMsgs = new List<String>();
        HasError = false;
        try {
            caseResponse = refreshCaseCallout.refreshCase(caseRequest);
            GESBCaseService.ServiceRequestDetails serviceRequestDetails = caseResponse.ServiceRequestDetails;
            
            //GESB Success code           
            if(caseResponse.statusCode == 0){
                caseRecord.Last_update_from_Alpha__c = DateTime.now();
                caseRecord.Last_update_in_Alpha__c = serviceRequestDetails.lastUpdatedDate;
                
                String alphaCaseStatusCode = serviceRequestDetails.status; //.substring(0,2);
                
                //Status codes in ALPHA mapped to Case Status in Salesforce
                System.debug(alphaCaseStatusCode);
                if(alphaCaseStatusCode == 'New'){
                    caseRecord.Status = CASE_STATUS_NEW;
                }else if(alphaCaseStatusCode == 'Closed'){
                    caseRecord.Status = CASE_STATUS_CLOSED;
                }else{
                    caseRecord.Status = CASE_STATUS_IN_PROGRESS;
                }
                
                caseRecord.Current_Alpha_Queue__c = serviceRequestDetails.groupName;
                caseRecord.Description = serviceRequestDetails.notes;
                
                update caseRecord; 
            }
            else{
                HasError = true;
                ErrorMsgs.add(caseResponse.statusMessage);
            }
        } catch(System.CalloutException e) {
            HasError = True;
            ErrorMsgs.add(e.getMessage());
        }
               
        //JSON object we return to the Lightning Component
        ActionStatus actionStatus = new ActionStatus();
        
        If(HasError){
            actionStatus.IsSuccess = False;
            actionStatus.ErrorMessages =  string.join(ErrorMsgs,'\n');
        }else{
            actionStatus.IsSuccess = True;
            actionStatus.SuccessMessage = Label.AC_Refresh_Succes_Message;
        }
        
        system.debug('JSON Value: '+ JSON.serialize(actionStatus));
        return JSON.serialize(actionStatus);
    }    
}