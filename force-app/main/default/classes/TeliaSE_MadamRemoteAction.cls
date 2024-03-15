/**
 * @Author:      Shubham Kundu
 * @Company:     Capgemini
 * @Date:        4th Feb 2019
 * @Description: TeliaSE_MadamRemoteAction is a RemoteAction Class for API-MARKET Authentication. This returns token returned from API Market
 *
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------------
*/
global class TeliaSE_MadamRemoteAction implements vlocity_cmt.VlocityOpenInterface {  
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        outMap.put('EnvCheck',Boolean.valueOf(System.label.MC_EnvironmentCheck));
        if(methodName.equals('authMethod')){
            String authResponse = authMethod();
            outMap.put('AuthResponse',authResponse);
        }
        if(methodName.equals('authMethod_AT')){
            String authResponse = authMethod_AT();
            outMap.put('AuthResponse',authResponse);
        }
        if(methodName.equals('authMethod_APIGarden'))
        {
            String authResponse = authMethod_APIGarden(inputMap);
            outMap.put('AuthResponse',authResponse);
        }  
        else{
            result = false; 
        }  
        return result;          
    } 
    global String authMethod(){
        String authString = TeliaSE_MadamAuthentication.makePostCallout();
        return authString;
    }
    global String authMethod_AT(){
        String authString = TeliaSE_MadamAuthenticationWS_UAT.makePostCallout();
        System.debug('Authtoken hardware='+ authString);
        return authString;
    }
    
     global String authMethod_APIGarden(Map<String,Object> inputMap){
        
        Map<String,Object> endpointMap = (Map<String,Object>)inputMap.get('SetEndPoint');
        String apiToken = (String)endpointMap.get('APIToken');
         
        String authString = TeliaSE_MadamAuthentication.makeApiGardenCallOut(apiToken);
        return authString;
    }
       
}