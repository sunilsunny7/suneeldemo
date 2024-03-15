//Test Class
@isTest
public class TeliaSE_GetCustomLabels_test {
    
    public static testmethod void testCustomLabel(){
        Map<String,Object> inputMap = new Map<String,Object>();
        TeliaSE_GetCustomLabels tq = new TeliaSE_GetCustomLabels();
        tq.invokeMethod('CustomLabel', inputMap, inputMap, inputMap);        
    }
}