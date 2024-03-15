global with sharing class MCOnline_ChangeBasket_V3 implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try { 
            if(methodName.equalsIgnoreCase('deleteBasket')){
                deleteBasket(inputMap, outMap);
            }
            else if (methodName.equalsIgnoreCase('Unreserve')){
                Unreserve(inputMap,outMap);
            }
            else if (methodName.equalsIgnoreCase('basketValidity')){
                basketValidity(inputMap,outMap);
            }
            else{
                result = false;
            }
        }
        catch(Exception e) {
            String error_message= e.getMessage() +' '+e.getLineNumber();
            system.debug(e.getStackTraceString());
            outMap.put('Error', e.getStackTraceString());
            outMap.put('StatusCode', 500);
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR', inputMap));
            MCOnline_Utility.logError(error_message,'500','MCONLINE_ChangeBasket_V3,MCOnline_ChangeBasket_V3.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }        
        return result;
    }
    
    public static void Unreserve(Map<String,Object> inputMap, Map<String,Object> outMap){
    }
    
    public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap){
        String basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('basketName'));
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        string urlDetails = '{"basketName":"'+basketName+'"}';
        ipInputMap.put('functionality', 'ChangeBasket');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_ChangeBasket_V3,MCOnline_ChangeBasket_V3.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    
    /*  ********************************************************************************************************
LOGIC TO VALIDATE THE GIVEN BASKET
********************************************************************************************************* */
    public static void basketValidity(Map<String,Object> inputMap, Map<String,Object> outMap){
        string basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('basketName')); // fetching the input basket name
        boolean hasError = false;
        //---- error handling for blank input start---// 
        if(String.isBlank(basketName)){
            hasError = true;
            outMap.put('ErrorResponse', generateError('NO_INPUT_BASKET_NAME', inputMap));
            outMap.put('StatusCode', 400);  
        }
        //---- error handling for blank input stop---//   
        else{  
            List<MCOnline_Basket__c> BsktId = [Select Id from MCOnline_Basket__c where Name=:basketName]; // getting the basket ID of the input basket
            //error handling for invalid basket Name-- start--//
            if(BsktId.size() ==0 || BsktId == null){
                hasError = true;
                outMap.put('ErrorResponse', generateError('INVALID_BASKET_NAME', inputMap));
                outMap.put('StatusCode', 400);
            }
            //error handling for invalid basket Name-- stop--//
            else{
                if(hasError == false){           
                    outMap.put('StatusCode', 200);
                }
            }       
        }
    }
    
    /*  ********************************************************************************************************
LOGIC TO DELETE THE BASKET
********************************************************************************************************* */
    public static void DeleteBasket(Map<String,Object> inputMap, Map<String,Object> outMap){
        string basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('basketName')); // fetching the input basket name
        Response basketResponse = new Response();
        boolean hasError = false;
        List<MCOnline_Basket__c> BsktId = [Select Id from MCOnline_Basket__c where Name=:basketName]; // getting the basket ID of the input basket
        basketResponse.id = BsktId[0].Id;
        delete BsktId;
        if(hasError==false){       
            basketResponse.success = true;
        }
        outMap.put('Result', JSON.serialize(basketResponse));
        outMap.put('StatusCode', 200);  
    }
    public class Response{
        public string id{get;set;}
        public boolean success {get; set;}  
    }
}