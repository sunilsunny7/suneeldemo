/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_ConvergenceAddOnHelper 
**Created By  :        Aditi Goyal
**Date        :        29 November 2021
**Description :        Helper method to transform Convergence Free Service QLIs JSON

-----------------------------------------------------------------------------------------------------------*/
global with sharing class MC_ConvergenceAddOnHelper implements vlocity_cmt.VlocityOpenInterface2   {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('transformAddQLIs')) {
                transformAddQLIs(inputMap, outMap);
            }             
            else {
                result = false;
            }   
            
        } catch(Exception e) {          
            result = false;
        }        
        return result;
    }
    
    public static void transformAddQLIs(Map<String,Object> inputMap, Map<String,Object> outMap){
        if(inputMap.containsKey('AddOnQLIs') && ((List<Object>)inputMap.get('AddOnQLIs')).size()>0){
            List<Object> addOnsList = (List<Object>)inputMap.get('AddOnQLIs');
            List<Map<String,Object>> updatedAddOnList = new List<Map<String,Object>>();
            
            System.debug('addonsList_'+addOnsList);
            for(Object addOn:addOnsList){
                Map<String,Object> addOnMap = (Map<String,Object>)addOn;
                for(Integer i=0;i<Integer.valueOf(addOnMap.get('Quantity'));i++){
                    updatedAddOnList.add(addOnMap.clone());
                }
            }
            System.debug('updatedAddOnList_'+updatedAddOnList);
            outMap.put('AddOnQLIs',updatedAddOnList);
        }       
    }    
}