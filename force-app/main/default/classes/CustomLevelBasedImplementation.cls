global class CustomLevelBasedImplementation implements vlocity_cmt.VlocityOpenInterface {
    
    public Boolean invokeMethod(String methodName, Map<String,Object> inputs,  Map<String,Object> output, Map<String,Object> options) {
        
        if (methodName.equals('getLevelBasedApproach')){
            return getLevelBasedApproach (inputs,output,options);
        }
        return true;
    }
    
    private static Boolean getLevelBasedApproach(Map<String,Object> inputs, Map<String,Object> output, Map<String,Object> options) {
        
        Id myId = Id.ValueOf((String)inputs.get('cartId'));
        //Defect - MCSTO-6594 for OT bundle collapse issue fix and Hardware need 2 - MCSTO-6601
        String sObjName = myId.getSObjectType().getDescribe().getName();
        //Flag set to false for MC Online
        Boolean isLevelBasedApproach = false;
        //Based on object type, flag will be set to True for MC Sales
        if(sObjName == 'Quote') isLevelBasedApproach = true;
        output.put('isLevelBasedApproachOn', isLevelBasedApproach);
        return true;
    }
}