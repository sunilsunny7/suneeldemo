@isTest
public class Test_ExtractandSendPriceAdjvalues {
   
      testMethod public static void test_sendtransformedJson(){
        String JsonResponse = '{"productOffering":[{"Service":"Internet Access","Technology Name":"B2C_FWA","Product Code":"CO-BBSTART","Line Type":"Wireless","Access Type":"5G NSA ?","Product Name":"BredbandStart","AccessCode":604},{"Service":"Internet Access","Technology Name":"FA_WS_FIBER","Priority BW Greater 1Gbps":"1","Product Code":"CO-BBPRO","Priority":"2","Line Type":"Fiber","Access Type":"FIBER SINGEL USER","Product Name":"BredbandPro","AccessCode":20},{"Service":"Internet Access","Technology Name":"FA_FTTX","Product Code":"CO-BBPLUS","Priority":"1","Line Type":"FTTx","Access Type":"KO 3.1","Product Name":"BredbandPlus","AccessCode":200},{"Service":"L3VPN Access","Technology Name":"L3VPN_FTTX","Product Code":"CO-DATANET","Priority":"1","Line Type":"FTTx","Access Type":"GAI 4.1","Product Name":"Datanet","AccessCode":300}]}';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = new Map<String, Object>();  
        Map<String, Object> optionsMap = new Map<String, Object>();  
        ExtractandSendPriceAdjvalues l1 = new ExtractandSendPriceAdjvalues();
        l1.invokeMethod('sendtransformedJson',inputMap,outMap,optionsMap);
    }
    
    testMethod public static void test_extractValues(){
        String JsonResponse = '{"adjPrices1":[{"Telia Bredband Pro":-6000,"Telia Bredband Plus":-6000,"weightFactor":"P1","Datanet":-1200},{"Telia Bredband Pro":-3000,"Telia Bredband Plus":-3000,"weightFactor":"P5","Datanet":0}],"productOfferingCode":[{"productOfferingCode":"Telia Bredband Plus","weightFactor":"P1"},{"productOfferingCode":"Telia Bredband Plus","weightFactor":"P5"},{"productOfferingCode":"Datanet","weightFactor":"P5"},{"productOfferingCode":"Datanet","weightFactor":"P110"}]}';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = new Map<String, Object>();  
        Map<String, Object> optionsMap = new Map<String, Object>();  
        ExtractandSendPriceAdjvalues l2 = new ExtractandSendPriceAdjvalues();
        l2.invokeMethod('extractValues',inputMap,outMap,optionsMap);
    }
    testMethod public static void test_transformedProductJson(){
        String JsonResponse = '{"productOffering":[{"Service":"Internet Access","Technology Name":"B2C_FWA","Product Code":"CO-BBSTART","Line Type":"Wireless","Access Type":"5G NSA ?","Product Name":"BredbandStart","AccessCode":604},{"Service":"Internet Access","Technology Name":"FA_WS_FIBER","Priority BW Greater 1Gbps":"1","Product Code":"CO-BBPRO","Priority":"2","Line Type":"Fiber","Access Type":"FIBER SINGEL USER","Product Name":"BredbandPro","AccessCode":20},{"Service":"Internet Access","Technology Name":"FA_FTTX","Product Code":"CO-BBPLUS","Priority":"1","Line Type":"FTTx","Access Type":"KO 3.1","Product Name":"BredbandPlus","AccessCode":200},{"Service":"L3VPN Access","Technology Name":"L3VPN_FTTX","Product Code":"CO-DATANET","Priority":"1","Line Type":"FTTx","Access Type":"GAI 4.1","Product Name":"Datanet","AccessCode":300}]}';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = new Map<String, Object>();  
        Map<String, Object> optionsMap = new Map<String, Object>();  
        ExtractandSendPriceAdjvalues l3 = new ExtractandSendPriceAdjvalues();
        l3.invokeMethod('transformedProductJson',inputMap,outMap,optionsMap);
    }
    
    

}