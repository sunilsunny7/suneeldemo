@RestResource(urlMapping='/postrequestSFApi/')
global class RESTservice {
    @HttpPost
    global static ResponseData resultsDisplay(){
        ResponseData resp = new ResponseData();
        try{
            // Get the Request Body of Helix system
            RestRequest req = RestContext.request;
            system.debug('Request Received:-'+req.requestBody.toString());
            if(req.requestBody.size() >0){
                RequestClassWrapper JSONreqbody = (RequestClassWrapper)JSON.deserialize(req.requestBody.toString(), RequestClassWrapper.class);
                system.debug('2222'+JSONreqbody.purposes);
                RESTservice.parseResponse(JSONreqbody);
                if(JSONreqbody.customerIdentificationNumber !='' && JSONreqbody.customerIdentificationNumber !=null){
                    resp.status = '200';
                    resp.statusDescription = 'Request Body Received';
                    resp.transactionId= RESTservice.NewGUID();
                    return resp;
                }else{
                    resp.status = '500';
                    resp.statusDescription = 'Customer Identification Number is Empty';
                    resp.transactionId= RESTservice.NewGUID();
                    return resp;
                }
            }else{
                resp.status = '300';
                resp.statusDescription = 'Request Body is Blank';
                resp.transactionId= RESTservice.NewGUID();
                return resp;
            }
        }catch(exception e){
            system.debug('$$$$'+e.getMessage());
            resp.status = '400';
            resp.statusDescription = 'Error Occured in processing the request';
            resp.transactionId= RESTservice.NewGUID();
            return resp;
        }
    }
    //To generate Response Transaction Id
    public static String NewGUID() {
        Blob aes = Crypto.generateAesKey(128);
        String hex = EncodingUtil.convertToHex(aes);
        return hex.substring(0,8) + '-' + hex.substring(8,12) + '-' + hex.substring(12,16) + '-' + hex.substring(16,20) + '-' + hex.substring(20,32);
    }
    // Parse the received Json string from Helix system
    public static void parseResponse(RequestClassWrapper responseWrapper){
        system.debug('%%%%%'+responseWrapper);
        String receivedOrgNr;
        MAP<String,String>mapofitemAndAnswers = new MAP<String,String>();
        Account AccObj = new Account();
        If(responseWrapper!= null){
            receivedOrgNr = responseWrapper.customerIdentificationNumber;
        }
        // Map the purpose response with status
        for(RequestClassWrapper.purposes singleItem : responseWrapper.purposes){
            mapofitemAndAnswers.put(singleItem.purpose,singleItem.status);
        }
        if(String.isNotBlank(receivedOrgNr)){
            AccObj = [select Id,Consent_Updated__c,CM_Collection_Method__c,CM_Final_Traffic_Marketing__c,CM_Final_Traffic_Service_Network__c,CM_Final_DataSharing__c from ACCOUNT where Org_Nr__c = :receivedOrgNr LIMIT 1];
            system.debug('Account Found:-'+AccObj);
            
            
            //  if(mapofitemAndAnswers.containsKey('b2b-consent-data-sharing'))
            //      AccObj.CM_Final_DataSharing__c = mapofitemAndAnswers.get('b2b-consent-data-sharing');
            // Get the map with the purpose key of Helix
            if(mapofitemAndAnswers.containsKey('b2b-consent-td-marketing'))
                AccObj.CM_Final_Traffic_Marketing__c = mapofitemAndAnswers.get('b2b-consent-td-marketing');
            if(mapofitemAndAnswers.containsKey('b2b-consent-td-service-improvement'))
                AccObj.CM_Final_Traffic_Service_Network__c = mapofitemAndAnswers.get('b2b-consent-td-service-improvement');
            // The collection Method Implict or Others
            if(String.isNotBlank(responseWrapper.collectionMethod))
                AccObj.CM_Collection_Method__c = responseWrapper.collectionMethod;
            // The consent Time stamp
            if(String.isNotBlank(responseWrapper.requested))
                AccObj.Consent_Updated__c = responseWrapper.requested;
            
            system.debug('Update record:-'+AccObj);
            // Perform DML update operation to salesforce for the received Org Nr
            database.SaveResult dsr = database.update(AccObj);
            system.debug('Update status:-'+dsr);
        }
    }    
    
    // Create a Response JSON Class
    global class ResponseData {
        public String status;
        public String statusDescription;
        public String transactionId;
        
    }
}