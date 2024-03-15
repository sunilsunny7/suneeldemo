/**
 * @Author:      Shubham Kundu
 * @Company:     Capgemini
 * @Date:        4th Feb 2019
 * @Description: TeliaSE_MadamAuthentication is a Rest Class which callout to API market and Fetch Auth Token, This class is called from Remote Action
                 class named TeliaSE_MadamRemoteAction.
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------------
*/
public class TeliaSE_MadamAuthentication {
    public static String makePostCallout() {
        
        WebService__c data = [SELECT Name,password__c,Authorization__c,Content_Type__c,EndpointURL__c,Timeout__c ,username__c FROM WebService__c WHERE Name='TeliaSE_MadamAuthenticationWS'];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(data.EndpointURL__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', data.Content_Type__c);
        request.setHeader('Authorization', data.Authorization__c);
        String payLoad = 'grant_type=client_credentials' 
                        + '&username=' + EncodingUtil.urlEncode(data.username__c,'UTF-8') 
                        + '&password=' + EncodingUtil.urlEncode(data.password__c, 'UTF-8');
        
        request.setBody(payLoad);
        
        String responseBody;
        if (!Test.isRunningTest()) {    
            // Parse the JSON response
            HttpResponse response = http.send(request);
            responseBody = response.getBody(); 
        }
         return responseBody;
    }
    
    public static String makeApiGardenCallOut(String apiToken){
        WebService__c data = [SELECT Name,password__c,Authorization__c,Content_Type__c,EndpointURL__c,Timeout__c ,username__c FROM WebService__c WHERE Name=: apiToken];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(data.EndpointURL__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', data.Content_Type__c);
        request.setHeader('Authorization', data.Authorization__c);
        String payLoad = 'grant_type=client_credentials'; 
        if(data.username__c != null){
            payLoad += '&client_id=' + EncodingUtil.urlEncode(data.username__c,'UTF-8');
        }
        if(data.password__c != null){
            payLoad += '&client_secret=' + EncodingUtil.urlEncode(data.password__c, 'UTF-8');
        }            
        request.setBody(payLoad);
        String responseBody;
        if (!Test.isRunningTest()) {    
            // Parse the JSON response
            HttpResponse response = http.send(request);
            responseBody = response.getBody(); 
        }
        
        Map<String,Object> responseMap = test.isRunningTest() ? null : (Map<String,Object>)Json.deserializeUntyped(responseBody); 
        String accessToken = test.isRunningTest() ? 'abc' : (String)responseMap.get('access_token');
        return accessToken;
    }
    
    
}