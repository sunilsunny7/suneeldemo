global without Sharing class Fiber_NewPriceQuote implements vlocity_cmt.VlocityOpenInterface{
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    Boolean result = true;
        try
        {
            if (methodName.equals('validateFiberRevisedContract'))
            {   
                validateFiberRevisedContract(inputMap,outMap,options);
            }
        }
     catch(Exception e)
        {
            System.debug('exception: '+e);
            result = false;
        }
        return result;
    }
    
    public static void validateFiberRevisedContract(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        string contextId = (String)inputMap.get('ContextId');
         outMap.put('Warning','Är du säker på att du vill gå vidare?');
}
}