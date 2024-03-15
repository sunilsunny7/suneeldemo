global class LeadAlphaController {
    public static  String Lead_ENDPOINT_URL = 'LEAD GESB URL';
    //Alpha Sync Satus
    public static String LEAD_ALPHA_SYNC_STATUS_OK = 'Lead Interest Sent to Alpha';
    public static String LEAD_ALPHA_CONNECTION_ERROR = 'Connection Error in Alpha';
    public static String LEAD_ALPHA_SYNC_STATUS_ERROR = 'Error,Not Sent to Alpha';
    public static String SOBJECT_NAME = 'LEAD';
    public static String BUY_INTEREST_STATUS ='Avfärdat';
    public static Boolean HasError {get;set;}
    
    //For Salesforce Lightning
    @AuraEnabled
    public static String getRecord(String BuyId){
        system.debug('BuyInterestId:-'+BuyId);
        HasError = false;
        Response wrapper = new response();
        Buy_Interest__c BuyObj =  [SELECT Id,
                                   Name,
                                   Alpha_Status__c,
                                   Status__c,
                                   Alpha_Queue__c,
                                   Form_Source__c,
                                   Lead__r.Account__c,
                                   Lead__r.MobilePhone
                                   FROM Buy_Interest__c 
                                   WHERE Id = :BuyId LIMIT 1];  
        
        if(String.isNotBlank(BuyObj.Alpha_Status__c)){
            HasError = true;
        }
        if(String.isBlank(BuyObj.Lead__r.MobilePhone)){
            HasError = true;
        }
        if(String.isBlank(BuyObj.Alpha_Queue__c)){
            HasError = true;
        }
        if(String.isBlank(BuyObj.Name)){
            HasError = true;
        }
        if(BuyObj.Status__c == BUY_INTEREST_STATUS){
            HasError = true;
        }
        if(HasError){
            wrapper.isSuccess = false;
            wrapper.isBtnActive = false;
        }else{
            wrapper.isSuccess = true;
            wrapper.isBtnActive = true;
        }
        return JSON.serialize(wrapper);
    }
    //For Salesforce Classic
    webservice static string sendtoAlpha(String Id){
       return processRecord(Id);
    }
    //For Salesforce Lightning
    @AuraEnabled
    public static String SendAlpha(String recordId){
        return processRecord(recordId);
    }
    public static String processRecord(String BuyInterestId){
        system.debug('BuyInterestId:-'+BuyInterestId);
        //Response Service Class Initiation
        GesbWsSfdcLeadexpSchema.PublishLeadRequest PayloadRequest = new GesbWsSfdcLeadexpSchema.PublishLeadRequest();
        GesbWsSfdcLeadexpSchema.StatusResponse LeadResponse = new GesbWsSfdcLeadexpSchema.StatusResponse();
        GesbWsSfdcLeadexpService.ServicePortTypeEndpoint servEnd = new GesbWsSfdcLeadexpService.ServicePortTypeEndpoint();
        Response resStatus = new Response();
        HasError = false;
        Buy_Interest__c buyIntObj = new Buy_Interest__c();
        buyIntObj = [Select Id,Name,Alpha_Queue__c,Description__c,Source__c,Number_of_Facilities__c,New_facility__c,
                     Lead__r.Name,
                     Lead__r.MobilePhone,
                     Lead__r.Email,
                     Lead__r.Product_Area__c,
                     Lead__r.Form_Source__c,
                     Lead__r.LeadSource,
                     Lead__r.Telia_Employee_Telia_Id__c,
                     Lead__r.Lead_Submitter_first_name__c,
                     Lead__r.Lead_Submitter_Last_name__c,
                     Lead__r.Lead_Submitter_phone__c,
                     Lead__r.Lead_Submitter_No__c,
                     Lead__r.Lead_Submitter_email__c,
                     Lead__r.Account__r.name,
                     Lead__r.Account__r.Org_nr__c from Buy_Interest__c where Id =:BuyInterestId LIMIT 1];
        
        //Get the Url Value from the custom setting
        GESB_EndPointURL__c endpoint = GESB_EndPointURL__c.getInstance(Lead_ENDPOINT_URL);
        If(string.isNotBlank(endpoint.EndPointURL__c)){
            servEnd.endpoint_x =  endpoint.EndPointURL__c;
        }
        
        //Envelope Header Values
        Blob headerValue = Blob.valueOf(endpoint.Authentication__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        servEnd.inputHttpHeaders_x = new Map<String, String>();
        servEnd.inputHttpHeaders_x.put('authorization', authorizationHeader); 
        servEnd.timeout_x = 1000 * 60 * 2; 
        try{
            //Webservice Callout
            PayloadRequest = generatePayload(buyIntObj);
            LeadResponse = servEnd.publishLead(PayloadRequest);
            system.debug('Response:-'+LeadResponse);
            if(LeadResponse.statusCode ==0 && LeadResponse.statusMessage == NULL){
                buyIntObj.Alpha_Status__c = LEAD_ALPHA_SYNC_STATUS_OK;
                buyIntObj.Status__c = BUY_INTEREST_STATUS;
            }else if(LeadResponse.statusCode ==-1 && LeadResponse.statusMessage.contains('Connection Error')){
                HasError = true;
                buyIntObj.Alpha_Status__c = LEAD_ALPHA_CONNECTION_ERROR;
            }else{
                HasError = true;
                buyIntObj.Alpha_Status__c = LEAD_ALPHA_SYNC_STATUS_ERROR;
            }
            database.update(buyIntObj);
        }catch(Exception ex){
            HasError = true;
            system.debug('Exception:-'+ex.getMessage()+'Line Number:-'+ex.getLinenumber());
        }
        //Check Response Error Message
        if(HasError){
            resStatus.ErrorMsg = 'Error in Processing Request'+': '+Label.AC_Send_Error_Message;
            resStatus.isSuccess = False;
            resStatus.isBtnActive = True;
        }else{
            resStatus.SuccessMsg = Label.AC_Success_Message_LEAD;
            resStatus.isSuccess = True;
            resStatus.isBtnActive = False;
        }
        return JSON.serialize(resStatus);
    }
    
    //Generate Payload 
    public static GesbWsSfdcLeadexpSchema.PublishLeadRequest generatePayload(Buy_Interest__c buyIntObj) {
        String SubmitterName ='';
        //Service Class Initiation
        GesbWsSfdcLeadexpSchema.PublishLeadRequest LeadRequest = new GesbWsSfdcLeadexpSchema.PublishLeadRequest();
        GesbWsSfdcLeadexpSchema.customer_element CustomerRequest = new GesbWsSfdcLeadexpSchema.customer_element();
        GesbWsSfdcLeadexpSchema.contact_element ContactRequest = new GesbWsSfdcLeadexpSchema.contact_element();
        GesbWsSfdcLeadexpSchema.remitter_element RemitterRequest = new GesbWsSfdcLeadexpSchema.remitter_element();
        GesbWsSfdcLeadexpSchema.publishLead_element PublishRequest = new GesbWsSfdcLeadexpSchema.publishLead_element();
        
        //Get Alpha Product Area values
        Map<String, String> InterestAreaValues = new Map<String, String>();
        for (LeadProductInterest__c record : LeadProductInterest__c.getAll().values()){
            InterestAreaValues.put(record.Name.toupperCase(), record.Code__c);
        }
        system.debug('####'+InterestAreaValues.get(buyIntObj.Name.toupperCase()));
        
        //Generate Lead Request
        LeadRequest.objectType =SOBJECT_NAME;
        LeadRequest.srType ='';
        LeadRequest.routingDest = buyIntObj.Alpha_Queue__c !=null ? buyIntObj.Alpha_Queue__c :'';
        LeadRequest.interestArea =InterestAreaValues.get(buyIntObj.Name.toupperCase()) !=null ? InterestAreaValues.get(buyIntObj.Name.toupperCase()):'NOINTERESTAREA';
        LeadRequest.users =buyIntObj.Number_of_Facilities__c !=null ? buyIntObj.Number_of_Facilities__c.intValue(): 0;
        LeadRequest.sites = 0;
        String BuyIntdescription = buyIntObj.Description__c !=null ? buyIntObj.Description__c : '';
        LeadRequest.campaignCode ='';
        //Append new facility in description
        if(String.isNotBlank(buyIntObj.New_facility__c)){
        LeadRequest.description = BuyIntdescription+'.'+' '+'New Facility:-'+buyIntObj.New_facility__c;
        }else
        LeadRequest.description = BuyIntdescription;
        
        //Generate Customer Request
        CustomerRequest.name = buyIntObj.Lead__r.Account__r.name !=null ? buyIntObj.Lead__r.Account__r.name : 'NOACCOUNTASSOCIATED';
        CustomerRequest.orgNr = buyIntObj.Lead__r.Account__r.Org_nr__c !=null ? buyIntObj.Lead__r.Account__r.Org_nr__c : '1111111111';
        //Generate Contact Request
        ContactRequest.name =  buyIntObj.Lead__r.Name !=null ? buyIntObj.Lead__r.Name: '';
        ContactRequest.phone = buyIntObj.Lead__r.MobilePhone !=null ? buyIntObj.Lead__r.MobilePhone:'';
        ContactRequest.email = buyIntObj.Lead__r.Email !=null ? buyIntObj.Lead__r.Email :'';
        if(String.isNotBlank(buyIntObj.Lead__r.Lead_Submitter_first_name__c))
            SubmitterName = SubmitterName + buyIntObj.Lead__r.Lead_Submitter_first_name__c;
        if(String.isNotBlank(buyIntObj.Lead__r.Lead_Submitter_Last_name__c))
            SubmitterName    =SubmitterName+ buyIntObj.Lead__r.Lead_Submitter_Last_name__c;
        
        //Lead Remitter Request
        RemitterRequest.system_x = buyIntObj.Source__c;
        RemitterRequest.teliaId = buyIntObj.Lead__r.Telia_Employee_Telia_Id__c != null ? buyIntObj.Lead__r.Telia_Employee_Telia_Id__c : '';
        RemitterRequest.name = SubmitterName != null ? SubmitterName : '';
        RemitterRequest.phone = buyIntObj.Lead__r.Lead_Submitter_phone__c != null ? buyIntObj.Lead__r.Lead_Submitter_phone__c : '';
        RemitterRequest.group_x = buyIntObj.Id;
        RemitterRequest.retailerNumber= buyIntObj.Lead__r.Lead_Submitter_No__c != null ? buyIntObj.Lead__r.Lead_Submitter_No__c : '';
        
        //Assign WSDL variables
        LeadRequest.remitter = RemitterRequest;
        LeadRequest.customer = CustomerRequest;
        LeadRequest.contact = ContactRequest;
        PublishRequest.request = LeadRequest; 
        return LeadRequest;
    }
    
    //Wrapper for Response Class
    public class response {
        public String ErrorMsg {get;set;}
        public String SuccessMsg{get;set;}
        public boolean isSuccess{get;set;}
        public boolean isBtnActive{get;set;}
    }
    
}