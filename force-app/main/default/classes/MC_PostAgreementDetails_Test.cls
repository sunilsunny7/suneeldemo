@isTest
public with sharing class MC_PostAgreementDetails_Test 
{
    
    //function test: transformAgreementItems
    @isTest
    public static void transformAgreementItems(){
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        String input ='{"agreementItem":[{"@agreementCharacteristics":"TeliaAgreementItemCharacteristics","@type":"ProductOffering","@referredType":"ProductOffering","family":"Mobile Offer Specification","Level":0,"warningActive":"N","subsidizedVoice":"Yes","startDate":"2020-07-30T00:00:00 +0000","recurringFee":0,"quarantineTime":"3","productName":"Mobilupplägg All-IN+","productCode":"MOB_MULTI_ALL_IN_PLUS_V2","oneTimeFee":0,"minimumCommit":"75","id":"MOB_MULTI_ALL_IN_PLUS_V2","functionActive":"N","endDate":"2022-07-30T00:00:00 +0000","commitmentPeriod":"24 months","baseQuantity":22,"assetrefId":"265577f7-aa1c-4f7c-eae5-5dd5480c9f04","rootItemId": "265577f7-aa1c-4f7c-eae5-5dd5480c9f04","ocnDiscount":"50"},{"@agreementCharacteristics":"TeliaAgreementItemCharacteristics","@type":"ProductOffering","@referredType":"ProductOffering","family":"Mobile Offer Specification","Level":1,"startDate":"2020-07-30T00:00:00 +0000","recurringFee":529,"quarantineTime":"3","productName":"Jobbmobil 15 GB","productCode":"MOB_MULTI_15_V2","oneTimeFee":0,"offeringCode":"94","id":"MOB_MULTI_15_V2","endDate":"2022-07-30T00:00:00 +0000","assetrefId":"265577f7-aa1c-4f7c-eae5-5dd5480c9f54","rootItemId": "265577f7-aa1c-4f7c-eae5-5dd5480c9f04"}]}';
        Map<String,Object> contractLineItem = (Map<String,Object>)json.deserializeUntyped(input);
        List<Object> contractLineItems =(List<Object>) contractLineItem.get('agreementItem');        
        List<Map<String,Object>> inputLineItems = new List<Map<String,Object>>();
        for(Object obj1 : contractLineItems)
        {
            Map<String,Object> cli = (Map<String,Object>) obj1;
            inputLineItems.add(cli);
        }
        
        List<Object> arguments = new List<Object>();
        arguments.addAll(inputLineItems);
        inputs.put('arguments',arguments);
        MC_PostAgreementDetails obj=new MC_PostAgreementDetails();
        Boolean flag = obj.invokeMethod('transformAgreementItems', inputs, output, options);
        
    }
    
     @isTest
    public static void convertMapToNameValue(){
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        String input ='{"autotaskOpportunityId": "12345","autotaskContractId": "123456"}';
        Map<String,Object> contractLineItem = (Map<String,Object>)json.deserializeUntyped(input);
        List<Map<String,Object>> inputLineItems = new List<Map<String,Object>>();
        for(String obj1 : contractLineItem.keySet())
        {
            Map<String,Object> cli = new Map<String,Object>();
            cli.put(obj1,contractLineItem.get('obj1'));
            inputLineItems.add(cli);
        }
        
        List<Object> arguments = new List<Object>();
        arguments.addAll(inputLineItems);
        inputs.put('arguments',arguments);
        MC_PostAgreementDetails obj=new MC_PostAgreementDetails();
        Boolean flag = obj.invokeMethod('convertMapToNameValue', inputs, output, options);        
    }
    
    @isTest
    public static void methodNoName(){
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        MC_PostAgreementDetails obj=new MC_PostAgreementDetails();
        Boolean flag = obj.invokeMethod('convertMapToNameValue', inputs, output, options);
        Boolean flag2 = obj.invokeMethod('',inputs, output, options);
    }

}