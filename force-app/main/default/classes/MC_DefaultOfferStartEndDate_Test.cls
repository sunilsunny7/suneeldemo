@isTest
public class MC_DefaultOfferStartEndDate_Test {
    testMethod public static void selectProducts(){
        String inputJson = '{"Quote":[{"RootProduct":"01t3H000003DjymQAC","RootItemId":"0QL3H000001zb0EWAQ","Product_ObjectType":"Smart Connect Offer Spec","ProductName":"Operator Connect","ProductCode":"OC_Offer","Product2Id":"01t3H000003DjymQAC","LineStatus":"Added","Id":"0QL3H000001zb0EWAQ","CommitmentPeriod":"24 months"},{"RootItemId":"0QL3H000001zb0OWAQ","Product_ObjectType":"Mobile Offer Specification","ProductName":"Mobilupplägg All-IN+","ProductCode":"MOB_MULTI_ALL_IN_PLUS_V3","Product2Id":"01t5E000007gwAbQAI","LineStatus":"Added","StartDate":"07-08-2023","Id":"0QL3H000001zb0OWAQ","BindingPeriod":"36 months"}]}';
        Map<String,Object> jsoninputMap = (Map<String, Object>)JSON.deserializeUntyped(inputJson);
        List<Object> obj = (List<Object>)jsoninputMap.get('Quote');
        List<Object> objList = new List<Object>();
        for(Object o : obj){
            Map<String,Object> tempMap = (Map<String,Object>)o;
            tempMap.put('StartDate', Date.today()+10);
            objList.add(tempMap);
        }
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('Quote',objList);
        Map<String, Object> outMap = new Map<String, Object>();
        new MC_DefaultOfferStartEndDate().invokeMethod('SelectProducts', inputMap, outMap, outMap);
    }
}