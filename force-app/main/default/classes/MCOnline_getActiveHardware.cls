global with sharing class MCOnline_getActiveHardware implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        if(methodName.equals('getActiveHardware'))
        {  
            getActiveHardware(inputMap, outMap, options);
        }
        return true;
    }
    public static void getActiveHardware(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        
        
    }

}