//Test Class
@isTest
public class Test_TeliaSE_CustomLabel {
    
    public static testmethod void testCustomLabel(){
        Map<String,Object> inputMap = new Map<String,Object>();
        TeliaSE_CustomLabel tq = new TeliaSE_CustomLabel();
        tq.invokeMethod('CustomLabel', inputMap, inputMap, inputMap);        
    }
}