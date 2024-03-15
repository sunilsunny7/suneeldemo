global class TeliaSE_updateTerminationDate implements vlocity_cmt.VlocityOpenInterface{
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     Boolean result = true;
        try
        {
            if (methodName.equals('updateTerminationDt'))
            {
                updateTerminationDt(inputMap,outMap);
            }
               
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {
            System.debug('exception: '+e);
            result = false;
            outMap.put('ErrorAgreement','Error');
            outMap.put('ErrorMessage',e.getMessage());
        }
        return result;
    }
 private static void updateTerminationDt(Map<String,Object> inputMap,Map<String,Object> outMap)
 {
  
  Set<Id> ids=new Set<Id>();
  Map<String,Date> dateMap=new Map<String,Date>();
  Map<String,Object> contract=(Map<String,Object>)inputMap.get('Contract');   
  String contractId=(String)contract.get('Id');
  Map<String,Object> con=(Map<String,Object>)inputMap.get('TerminationDetails');
  String terminationReason=(String)con.get('TerminateReason');
  
   for(Object obj:(List<Object>)contract.get('Item'))
   {
      Map<String,Object> data=(Map<String,Object>)obj;
      System.debug('data==='+ data);
      ids.add((Id)data.get('RootProduct'));   
      Date dt=Date.valueOf(String.valueOf(data.get('CLIEndDate')));
      dateMap.put((Id)data.get('RootProduct'),dt);
   }
   List<vlocity_cmt__ContractLineItem__c> lines=new List<vlocity_cmt__ContractLineItem__c>();
  
   for(vlocity_cmt__ContractLineItem__c item:[select id,TeliaSE_Root_product__c from vlocity_cmt__ContractLineItem__c  where vlocity_cmt__ContractId__c=:contractId and TeliaSE_Root_product__c =:ids])
   {
      item.TeliaSE_Terminate_Date__c=dateMap.get(item.TeliaSE_Root_product__c);
      item.TeliaSE_Termination_Reason__c=terminationReason;
      //item.TeliaSE_flag__c= 1;
      lines.add(item);
  } 
  
  if(lines.size()> 0)
  {
      update lines;
  }
 }
}