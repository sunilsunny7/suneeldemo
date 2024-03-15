global class Study implements vlocity_cmt.VlocityOpenInterface2{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        try
{
if(methodName.equalsIgnoreCase('studytable'))
{
Study.studytable(inputMap,outMap,options);
}
}
catch(Exception e)
{
}
        return true;
    }
    public static void studytable(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        String picklistAttributeName=String.valueOf(inputMap.get('attributeName'));
        list<vlocity_cmt__PicklistValue__c> commitmentPeriodValue=[Select id, Name, vlocity_cmt__Value__c,vlocity_cmt__IsDefault__c, vlocity_cmt__PicklistId__r.vlocity_cmt__Code__c from vlocity_cmt__PicklistValue__c Where vlocity_cmt__PicklistId__r.vlocity_cmt__Code__c = :picklistAttributeName];
        list<String> values=new list<String>();
        Map<String,String> valueblue=new Map<String,String>();
        integer count=1;
        for(vlocity_cmt__PicklistValue__c ab:commitmentPeriodValue){
            valueblue.put('Value'+count,ab.vlocity_cmt__Value__c);
            count++;
      //values.add(ab.vlocity_cmt__Value__c);
        }
        outMap.put('message','झुकेगा नहीं साला');
        outMap.put('commitmentperiodvalue',valueblue);
    }
}