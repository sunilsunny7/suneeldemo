/*-----------------------------------------------------------------------------------------------------------
**Name        :        Test_MC_ConvergenceAddOnHelper 
**Created By  :        Aditi Goyal
**Date        :        29 November 2021
**Description :        Test class for MC_ConvergenceAddOnHelper

-----------------------------------------------------------------------------------------------------------*/
@isTest
private class Test_MC_ConvergenceAddOnHelper {
    
    @isTest
    private static void testTranformQLIData(){
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        String testData = '[ { "Product2Id": "01t5E000007uQyKQAU", "Quantity": 1, "Name": "Introduktionskurs i MS365 eller säkerhet, 1 timme – 3 utbildningsplatser" }, { "Product2Id": "01t5E000007uQeIQAU", "Quantity": 1, "Name": "Introduktionskurs i MS365 eller säkerhet, 3 timmar – 1 utbildningsplats" } ]';
        inputMap.put('AddOnQLIs',json.deserializeUntyped(testData));
        
        MC_ConvergenceAddOnHelper obj = new MC_ConvergenceAddOnHelper();
        Test.startTest();
        obj.invokeMethod('transformAddQLIs',inputMap,outMap,options);
        Test.stopTest();
    }
}