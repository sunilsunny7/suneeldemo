global with sharing class MC_PostAgreementDetails implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod (String methodName,Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
        try{
            if(methodName == 'transformAgreementItems'){
                Map<String,Object> agreementItemsDRNode = new Map<String,Object>();
                List<Object> arguments = (List<Object>)input.get('arguments');
                Map<string,Object> contractLineItem = new Map<String,Object>();
                Map<string,Object> temp1 = new Map<String,Object>();                
                Map<string,String> rootOCNMapping = new Map<String,String>();
                
                List<AgreementItem> agreementItems = new List<AgreementItem>();
                for(Object o1: arguments){
                    temp1 = (Map<String,Object>) o1;
                    rootOCNMapping.put((String)temp1.get('assetRefId'),(String)temp1.get('ocnDiscountAmount'));
                }
                for(Object o:arguments){
                    contractLineItem = (Map<String,Object>) o;
                    agreementItems.add(agreementLineItem(contractLineItem,rootOCNMapping));
                }
                agreementItemsDRNode.put('agreementItems',(Object)agreementItems);
                output.put('result', Json.serializePretty(agreementItemsDRNode));
            }
            if(methodName == 'convertMapToNameValue'){
                Map<String,Object> agreementItemsDRNode = new Map<String,Object>();
                List<Object> arguments = (List<Object>)input.get('arguments');
                Map<String,Object> mapString = new Map<String,Object>();
                for(Object o:arguments){
                    Map<String,Object> tempMap = (Map<String,Object>)o;
                    mapString.putAll(tempMap);
                }
                system.debug(mapString);
                List<Map<String,Object>> mapStringList = converstionToNameValue(mapString);
                system.debug(json.serialize(mapStringList));
                output.put('result', json.serialize(mapStringList));
            }
        }
        catch(Exception e)
        {
            system.debug('Error: '+e.getStackTraceString());
            system.debug('Error Message: '+e.getMessage());
        }
        return true;
    }
    
    private AgreementItem agreementLineItem(Map<String,Object> agreementItem,Map<String,String> rootOCNMapping)
    {
         Map<String,Object> productOfferings = new Map<String,Object>();
        productOfferings.put('id',(String)agreementItem.get('id'));
        productOfferings.put('name',(String)agreementItem.get('productName'));
        productOfferings.put('@type',(String)agreementItem.get('@type'));
        productOfferings.put('@referredType',(String)agreementItem.get('@referredType'));
        //po.id = (String)contractLineItem.get('id');
        //po.name = (String)contractLineItem.get('productName');
        //po.type = (String)contractLineItem.get('@type');
        //po.referredType = (String)contractLineItem.get('@referredType');
        List<Map<String,Object>> poList =new List<Map<String,Object>>();
        poList.add(productOfferings);
        
        TermOrCondition tc = new TermOrCondition();
        tc.description = '';
        ValidFor vf = new ValidFor();
        vf.startDateTime = (String)agreementItem.get('startDate');
        vf.endDateTime = (String)agreementItem.get('endDate');
        tc.validFor = vf;
        
        List<TermOrCondition> tcList = new List<TermOrCondition>();
        tcList.add(tc);
        Map<String,Object> agreementItemChars = new Map<String,Object>();
        AgreementItem agreementItemTransformed = new AgreementItem();
        
        if(agreementItem.containsKey('recordType')){
            agreementItemChars.put('quantity',agreementItem.containsKey('quantity')!=null ? agreementItem.get('quantity'):'');
			agreementItemChars.put('recurringFee', agreementItem.containsKey('recurringFee')!=null ? agreementItem.get('recurringFee'):'');
			agreementItemChars.put('oneTimeFee', agreementItem.containsKey('oneTimeFee')!=null ? agreementItem.get('oneTimeFee'):'');
			agreementItemChars.put('customerRequestedPrice',agreementItem.containsKey('customerRequestedPrice')!=null ? agreementItem.get('customerRequestedPrice'):'');
			agreementItemChars.put('activationType',agreementItem.containsKey('activationType')!=null ? agreementItem.get('activationType'):'');
        }
        else{
            agreementItemChars.put('baseQuantity',agreementItem.containsKey('baseQuantity') && agreementItem.get('baseQuantity')!=0? agreementItem.get('baseQuantity'):'');
            agreementItemChars.put('commitmentPeriod', agreementItem.containsKey('commitmentPeriod') ? (String)agreementItem.get('commitmentPeriod'):'');
            agreementItemChars.put('subsidizedVoice', agreementItem.containsKey('subsidizedVoice') ? (String)agreementItem.get('subsidizedVoice'):'');
            agreementItemChars.put('recurringFee', agreementItem.containsKey('recurringFee') ? agreementItem.get('recurringFee'):'');
            agreementItemChars.put('oneTimeFee', agreementItem.containsKey('oneTimeFee') ? agreementItem.get('oneTimeFee'):'');
            agreementItemChars.put('level',agreementItem.containsKey('Level') ? agreementItem.get('Level'):'');
            agreementItemChars.put('family',agreementItem.containsKey('family') ? agreementItem.get('family'):'');        
            agreementItemChars.put('itemInfo',agreementItem.containsKey('itemInfo') ? agreementItem.get('itemInfo'):'');
            agreementItemChars.put('bindingTime',agreementItem.containsKey('bindingTime') ? agreementItem.get('bindingTime'):'');
            agreementItemChars.put('percentageDiscountMRC',agreementItem.containsKey('percentageDiscountMRC') ? agreementItem.get('percentageDiscountMRC'):'');
            agreementItemChars.put('terminationDate',agreementItem.containsKey('terminationDate') ? agreementItem.get('terminationDate'):'');
            agreementItemChars.put('ocnDiscountAmount',rootOCNMapping.get((String)agreementItem.get('rootItemId')));
            agreementItemChars.put('lineStatus',agreementItem.containsKey('lineStatus') ? agreementItem.get('lineStatus'):''); //Added in 23.12
            //Adding below section here as its not required for Fiber
            agreementItemTransformed.termOrCondition = tcList;
        }
        agreementItemTransformed.productOffering = poList;
        agreementItemTransformed.agreementItemCharacteristics = converstionToNameValue(agreementItemChars);
        return agreementItemTransformed;
    }
    
    public static List<Map<String,Object>> converstionToNameValue(Map<String,Object> mapString){
        List<Map<String,Object>> returnMapList = new List<Map<String,Object>>();
        for(String key: mapString.keySet()){
            Map<String,Object> newMap = new Map<String,Object>();
            if(String.valueof(mapString.get(key)) != null && String.valueof(mapString.get(key)) != ''){
                newMap.put('name',key);
                newMap.put('value',mapString.get(key));
                returnMapList.add(newMap);    
            }            
        }
        return returnMapList;
    }
    
    
    public class TermOrCondition {
        public String description;
        public ValidFor validFor;
    }    
    public class ValidFor {
        public String startDateTime,endDateTime;
    }
    
    public class AgreementItem {
        public List<Map<String,Object>> productOffering;
        public List<TermOrCondition> termOrCondition;
        public List<Map<String,Object>> agreementItemCharacteristics;
    }
    
    public class ProductOffering {
        public String id,name,type,referredType;
        Map<String,Object> productOffering;
    }
    
}