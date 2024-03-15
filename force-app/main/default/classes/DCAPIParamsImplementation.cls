global class DCAPIParamsImplementation implements vlocity_cmt.VlocityOpenInterface {
    public static Map < String, String > overiddenParamMap = new Map < String, String > {};
    static {
        
        //Field should have their own string here for getofferdetails api
        overiddenParamMap.put('GetOfferDetails', '{"batchSize":1,"productFields":["AO__c","TeliaSE_Product_Service_Code__c","Ordering_Flag__c","Ordering_System__c","C2BC_Category__c","C2BC_Subcategory__c","CID__c","TeliaSE_Product_Category__c","TeliaSE_Subscription_Type__c","Downstream_CategoryData__c","MConline_Action_Code__c","MC_Product_Name_Eng__c","Feature_Id__c"]}');
        
    }
    global DCAPIParamsImplementation() {}

    global static Boolean invokeMethod(String methodName, Map < String, Object > inputs, Map < String, Object > outputs, Map < String, Object > options) {
        if (methodName == 'fetchAPIParamsOverride') {
            return fetchAPIParamsOverride(inputs, outputs, options);
        }
        return false;
    }

    /*
    Inputs :
        1) key : apiName, type : String
        2) key : params, type : String
    Outputs : 
        1) key : result, type : String
    */
    public static Boolean fetchAPIParamsOverride(Map < String, Object > inputs, Map < String, Object > outputs, Map < String, Object > options) {
        String apiName = (String) inputs.get('apiName');
        String overiddenParam = overiddenParamMap.get(apiName) == null ? ((String) inputs.get('params')) : overiddenParamMap.get(apiName);
        outputs.put('result', overiddenParam);
        return true;
    }
}