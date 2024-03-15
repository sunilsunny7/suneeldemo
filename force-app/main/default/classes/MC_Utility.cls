public class MC_Utility {
    
    public static WebService__c getEndpointInfo(String wsName){
        List<WebService__c> data = [SELECT Name,password__c,Authorization__c,Content_Type__c,EndpointURL__c,Timeout__c ,username__c FROM WebService__c WHERE Name=:wsName];
        return data.size() > 0 ? data[0]:null;
    }
    
    public static String getMadamAuthToken(){
        String authToken='';
        Map<String,Object> outMap = new Map<String,Object>();
        TeliaSE_MadamRemoteAction madamAuth = new TeliaSE_MadamRemoteAction();
        madamAuth.invokeMethod('authMethod', new Map<String,Object>(), outMap, new Map<String,Object>());
        if(outMap.containsKey('AuthResponse') && outMap.get('AuthResponse') != null && !Test.isRunningTest()){
            Map<String,Object> authMap = (Map<String,Object>)JSON.deserializeUntyped(String.valueOf(outMap.get('AuthResponse')));
            authToken = 'Bearer '+String.valueOf(authMap.get('access_token'));
        }
        return authToken;
    }
    
    public static HttpRequest buildHttpRequest(String method, String endpoint,String contentType,String authToken,String reqBody){
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', contentType);
        request.setHeader('Authorization', authToken);
        if(reqBody != null){
            request.setBody(reqbody);
        }
        //add for timeout
        return request;
    }
    
    public static void generateLog(String level,String method,String className,String refId,Integer code,String request,String response,String endpoint,Exception exp){
        Application_Logs__c newLog = new Application_Logs__c();
        newLog.Debug_Level__c = level;
        newLog.Source__c = className;
        newLog.Source_Function__c = method;
        newLog.Reference_Id__c = refId;
        newLog.Log_Code__c = String.valueOf(code);
        newLog.Integration_Payload__c = request;
        if(response != null){
            Integer fieldLength = Schema.SObjectType.Application_Logs__c.fields.Integration_Response__c.getLength();
            newLog.Integration_Response__c = response.length() > fieldLength? response.substring(0,fieldLength):response;
        }
        newLog.Endpoint__c = endpoint;
        newLog.Message__c = exp != null? exp.getMessage():null;
        newLog.Stack_Trace__c = exp!= null? exp.getStackTraceString():null;
        insert newLog;
    }
    
    public static String getCustomLabel(String namespace,String labelName,String language){
        if(String.isBlank(language)){
            language = '';
        }
        return System.Label.get(namespace,labelName,language); //get(namespace, label, language)
    }
}