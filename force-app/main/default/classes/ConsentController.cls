global class ConsentController {
    
    public ConsentController() {
        //Constructor
    }
    
    // Get the Account details from SF
    @AuraEnabled
    public static Account getAccount(String Id) {
        system.debug('AccId:-'+Id);
        return [select Id,OwnerId,Customer_Role__c,Org_Nr__c,Telia_Service_Manager__c,Consent_Provided_by_Customer__c,Consent_Updated_By__c,Consent_Updated__c,Name from Account WHERE ID =:Id Limit 1];
    }
    
    // Update the Account details in salesforce
    @AuraEnabled
    public static Account updateconsent(String Id,String CustName,String CustRole) {
        
        // Update the account details based on the successful response
        system.debug('AccId:-'+Id+'ContactId:-'+CustName);
        Account accObj = new Account();
        if(Id !=null){
            accObj.Id = Id;
            accObj.Customer_Role__c = CustRole;
            accObj.Consent_Provided_by_Customer__c = CustName;
            accObj.Consent_Updated__c = string.valueOf(system.now());
            accObj.Consent_Updated_By__c = userinfo.getName();
          //  update accObj;
        }
        return accObj;
    }
    
    // Get the C2B consent data from API Market callout
    @AuraEnabled
    public static ApexDataContainer getc2bData(String recId) {
        String API_ENDPOINT = label.GetAPIEndPOINT;
        try{
            //Get the Account details
            Account accRec = [select Id,Org_Nr__c from ACCOUNT where Id =:recId LIMIT 1];
            
            system.debug('###'+accRec.Org_Nr__c);
            if(accRec.Org_Nr__c != null){
                
                // Get the token response
                TokenJson accessTokenJSON = (TokenJson)JSON.deserializeStrict(getApiAccessToken(),TokenJson.class);
                system.debug('###'+accessTokenJSON.access_token);
                
                // Check Token validity and initiate Get Call out
                if(accessTokenJSON.access_token !='' && accessTokenJSON.access_token !=null){
                    http httpReq = new Http();
                    HttpRequest requestdata = new HttpRequest();
                    HttpResponse apiresponse = new HttpResponse();
                    String apiendpoint = API_ENDPOINT+'getCustomerPermissions?customerIdentificationNumber='+accRec.Org_Nr__c;
                    requestdata.setEndpoint(apiendpoint);
                    requestdata.setMethod('GET');
                    requestdata.setHeader('Authorization', 'Bearer '+accessTokenJSON.access_token);
                    system.debug('requestdata:-'+requestdata);
                    if(!test.isRunningTest()){
                        apiresponse = httpReq.send(requestdata);
                    }else{
                        apiresponse = MockHttpResponseGeneratorCls.testgetdata();  
                    }
                    if(apiresponse.getBody() !=null && apiresponse.getStatusCode()==200){
                        ApexDataContainer container = (ApexDataContainer)JSON.deserializeStrict(apiresponse.getBody(),ApexDataContainer.class);
                        system.debug('container:-'+container);
                        return container;
                    }else{
                        return null;
                    }
                }  
                return null;
            }else{
                return null;
            }
        }catch(Exception ex){
            return null;
        }
    }
    
    // SET consent data to API Market set callout
    @AuraEnabled
    public static String setConsenttoC2b(String container,String oldcontainer,String CustomerProxy,String CustomerRole,String OrgId) {
        try{
            system.debug('ContainerFromSF:-'+container);
            ApexDataContainer reqcontainer = new ApexDataContainer();
            String API_ENDPOINT = label.GetAPIEndPOINT;
            String COLLECTION_METHOD = 'Salesforce';
            RequestClassWrapper reqWrapper = new RequestClassWrapper();
            List<RequestClassWrapper.purposes> purposeList = new List <RequestClassWrapper.purposes>();
            ResponseData resdata = new ResponseData();
            
            //Deserialize the container reponse
            reqcontainer = (ApexDataContainer)JSON.deserializeStrict(container,ApexDataContainer.class);
            system.debug('ContainerFromSFParse:-'+reqcontainer.purposes);
            ApexDataContainer oldcontainerWrapper = (ApexDataContainer)JSON.deserializeStrict(oldcontainer,ApexDataContainer.class);
            system.debug('OldContainerFromSFParse:-'+oldcontainerWrapper);
            
            // Get the TCAD Id of the logged in user
            User usrRec = [select Id,Telia_Id__c from USER where Id =: userinfo.getUserId() LIMIT 1];
            
            // Check the Metadata for new and old JSON values
            for (ApexDataContainer.Purposes obj: reqcontainer.purposes){
                obj.fromSourceSystem  = 'SF';
                for (ApexDataContainer.Purposes objOld: oldcontainerWrapper.purposes){
                    objOld.fromSourceSystem  = 'SF'; 
                    if(obj.purpose == objOld.purpose){
                        if(obj.status != objOld.status){
                            system.debug('insideLoop:-'+obj+'111'+objOld);
                            RequestClassWrapper.purposes purposeObj = new RequestClassWrapper.purposes();
                            purposeObj.purpose = obj.purpose;
                            purposeObj.status = obj.status;
                            purposeObj.version = obj.version;
                            purposeList.add(purposeObj); 
                        } 
                    } 
                }
            }
            system.debug('purposeList:-'+purposeList);
            
            // Set the container value in the callout
            if(reqcontainer !=null){
                reqWrapper.customerIdentificationNumber = OrgId; //194610135779
                reqWrapper.collectionMethod = COLLECTION_METHOD;
                reqWrapper.requested = system.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                reqWrapper.language = 'sv-SE'; // for time being as the API Get and Set structure is different for language
                reqWrapper.customerRepresentative = usrRec.Telia_Id__c !=null ?usrRec.Telia_Id__c:'';
                reqWrapper.customerProxy = CustomerProxy +','+CustomerRole;
                reqWrapper.purposes = purposeList;
            }
            system.debug('reqWrapper:-'+reqWrapper);
            
            //Initiate HTTP SET Callout
            TokenJson accessTokenres = (TokenJson)JSON.deserializeStrict(getApiAccessToken(),TokenJson.class);
            system.debug('222:-'+accessTokenres.access_token);
            if(accessTokenres.access_token !='' && accessTokenres.access_token !=null){
                http httpsetReq = new Http();
                HttpRequest requestsetdata = new HttpRequest();
                HttpResponse apiresponse = new HttpResponse();
                String apisetendpoint = API_ENDPOINT+'setCustomerPermissions';
                requestsetdata.setEndpoint(apisetendpoint);
                requestsetdata.setMethod('POST'); 
                requestsetdata.setHeader('Content-Type', 'application/json');
                requestsetdata.setHeader('Authorization', 'Bearer '+accessTokenres.access_token);
                requestsetdata.setBody(JSON.serialize(reqWrapper));
                system.debug('requestsetdata:-'+requestsetdata);
                if(!test.isRunningTest()){
                    apiresponse = httpsetReq.send(requestsetdata);
                }else{
                    apiresponse = MockHttpResponseGeneratorCls.setTestdata();
                }
                system.debug('apiresponse:-'+apiresponse.getBody());
                if(apiresponse.getStatusCode() == 200){
                    resdata = (ResponseData)JSON.deserializeStrict(apiresponse.getBody(),ResponseData.class);
                    return JSON.serialize(resdata);
                }else{
                    resdata.statusDescription = 'Error';
                    resdata.status = '400';
                    return JSON.serialize(resdata);
                }
            }else
                return null;
        }catch(Exception Ex){
            system.debug('Cause:-'+Ex.getCause()+'No:-'+Ex.getLineNumber()+'Msg:-'+Ex.getMessage());
            return null;
        }
    }
    
    //Generate Token Class
    public static String getApiAccessToken(){
        
        //Get the integration oAuth details
        String CLIENT_KEY = Label.CLIENTKEY_API;
        String CLIENT_SECRET = Label.CLIENT_SECRET_API;
        String TOKENAPI_ENDPOINT = label.CLIENT_ENDPOINT;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String endpoint = TOKENAPI_ENDPOINT+'grant_type=client_credentials&client_id='+CLIENT_KEY+'&client_secret='+CLIENT_SECRET;
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        //request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        if(!test.isRunningTest()){
            response = http.send(request);
        }else{
            response = MockHttpResponseGeneratorCls.testApiresponse();
        }
        return response.getBody();
    } 
    
    // Get the Account details from Opportunity Record
    @AuraEnabled
    public static Opportunity getId(String Id) {
        system.debug('AccId:-'+Id);
        return [select Id,Account.Name,AccountId,Name from Opportunity WHERE ID =:Id Limit 1];
    }
    
    //HTTP Response Class
    global class ResponseData {
        public String status;
        public String statusDescription;
        public String transactionId;
    }
    
    //Token Response Class
    global class TokenJson {
        public String access_token;
        public String scope;
        public String token_type;
        public String expires_in;
    }
}