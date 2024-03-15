global class TeliaSE_GetCustomLabels implements vlocity_cmt.VlocityOpenInterface2{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    
    Boolean result = true;
    if(methodName.equals('CustomLabel')){
        TeliaSE_GetCustomLabels.CustomLabel();
        Map<String, Object> CL = CustomLabel();
        outMap.put('CL',CL);
    }
    else{
        result = false;
    }
    return result;
    }
    global static Map<String, Object> CustomLabel()
    {
        
        Map<String,object> CustomlabelMap = new Map<String,object>();        
        CustomlabelMap.put('TeliaSE_Ren',System.label.TeliaSE_Ren);
        CustomlabelMap.put('TeliaSE_SFAgreement',System.label.TeliaSE_SFAgreement);
        CustomlabelMap.put('TeliaSE_MADAMAgree',System.label.TeliaSE_MADAMAgree);
        CustomlabelMap.put('TeliaSE_Agreement_duration',System.label.TeliaSE_Agreement_duration);
        CustomlabelMap.put('TeliaSE_end',System.label.TeliaSE_end);
        CustomlabelMap.put('TeliaSE_Switching_solution',System.label.TeliaSE_Switching_solution);
        CustomlabelMap.put('TeliaSE_Owner',System.label.TeliaSE_Owner);
        CustomlabelMap.put('TeliaSE_LEVEL',System.label.TeliaSE_LEVEL);
        CustomlabelMap.put('TeliasSE_Type',System.label.TeliasSE_Type);
        CustomlabelMap.put('TeliaSE_Start',System.label.TeliaSE_Start);
        CustomlabelMap.put('TeliaSE_Valid_Switching_Solu',System.label.TeliaSE_Valid_Switching_Solu);
        CustomlabelMap.put('TeliaSE_Agreement_status_MADAM',System.label.TeliaSE_Agreement_status_MADAM);
        CustomlabelMap.put('TeliaSE_Utiliser_counts',System.label.TeliaSE_Utiliser_counts);
        CustomlabelMap.put('TeliaSE_Sub_agreements_exists',System.label.TeliaSE_Sub_agreements_exists);
        CustomlabelMap.put('TeliaSE_Priceplan0',System.label.TeliaSE_Priceplan0);
        CustomlabelMap.put('TeliaSE_MC_MiniDeb_Mobile',System.label.TeliaSE_MC_MiniDeb_Mobile);
        CustomlabelMap.put('TeliaSE_MC_MiniDeb_Touchpoint',System.label.TeliaSE_MC_MiniDeb_Touchpoint);        
        
        return CustomlabelMap;
        
    }
}

/*Adding This line for Deployment Purpose*/