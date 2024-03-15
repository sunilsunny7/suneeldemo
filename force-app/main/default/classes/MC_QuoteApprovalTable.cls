global class MC_QuoteApprovalTable implements vlocity_cmt.VlocityOpenInterface2{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('responseWrapper')) {
                MC_QuoteApprovalTable.Responsewrapper(inputMap, outMap);
            }else {
                result = false;
            }   
        } catch(Exception e) {          
            result = false;
        }        
        return result;
    }  
    @AuraEnabled
    public Static Map<String, Object> approvalInfo(String pId){
        String qid;
        if(pId != null || pId != ''){
          ProcessInstanceWorkitem[] ProcessInstanceWorkitemObj = [select id,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where id=:pId];
            if(ProcessInstanceWorkitemObj.size() > 0){
                qid = ProcessInstanceWorkitemObj[0].ProcessInstance.TargetObjectId;
            }else{
                ProcessInstanceStep[] ProcessInstanceStepObj = [select id,ProcessInstance.TargetObjectId from ProcessInstanceStep where id =: pId];
                qid = ProcessInstanceStepObj[0].ProcessInstance.TargetObjectId;
            }
        }
        Map<String, Object> ipInput = new Map<String, Object>();
        Map<String, Object> ipOutput = new Map<String, Object>();        
        Map<String, Object> ipOptions = new Map<String, Object>();
        Map<String, Object> drOutPut = new Map<String, Object>();




        if(qid != null){       
            Quote qut = [select id,Product_Details__c from Quote where id =:qid];



			
            String JsonResponse = qut.Product_Details__c;
            ipOutput = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
            /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
            //ipInput.put('ContextId', qid);
            //System.debug('qid'+qid);
            //String procedureName = 'MassCustomized_QuoteApprovalTable';
          /* Call the IP via runIntegrationService, and save the output to ipOutput */
          //ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
            //ipOutput = (Map <String, Object>)invokeIP(ipInput); 
            //System.debug('ipOutput'+json.serialize(ipOutput));
        }  
        
        if(ipOutput != null){            
            drOutPut = (Map<String, Object>)ipOutput.get('response');
        }
        return ipOutput;
    }
    
    public static void Responsewrapper(Map<String,Object> inputMap, Map<String,Object> outMap){
        System.debug('inputMap'+json.serialize(inputMap));
        Map<String,Object> itemMap1 = new Map<String,Object>();
        Map<String,Object> itemMap2 = new Map<String,Object>();
        if(inputMap.get('RA_QuoteInfo') != null){
          itemMap1 = (Map<String,Object>)inputMap.get('RA_QuoteInfo');
        }
        if(inputMap.get('DR_QuoteInfoCampign') != null){
          itemMap2 = (Map<String,Object>)inputMap.get('DR_QuoteInfoCampign');
        }
        System.debug('itemMap1'+json.serialize(itemMap1));
        System.debug('itemMap2'+json.serialize(itemMap2));
        Map<String,Object> itemParentChildMap1 = new Map<String,Object>();
        Map<String,Object> itemParentChildMap2 = new Map<String,Object>();
        Map<String,Object> itemParentSiteMap = new Map<String,Object>();
        Map<String,Object> itemParentSiteMap1 = new Map<String,Object>();
        Map<String,Object> itemParentSiteMap2 = new Map<String,Object>();
        List<Object> itemMap1QLI = (List<Object>)itemMap1.get('QLI');
        List<Object> itemMap2QLI = (List<Object>)itemMap2.get('QLI');
        Set<String> setkey = new set<String>();
        Set<String> itemParentChildSet = new set<String>();
        if(itemMap1QLI != null && itemMap1QLI.size() > 0){
            for(Object obj : itemMap1QLI){
                Map<String,Object> objMap = (Map<String,Object>)obj;
                if(objMap.keyset().size() > 0){
                itemParentChildMap1.put((String)objMap.get('Id'),objMap.get('Child'));
                itemParentSiteMap1.put((String)objMap.get('Id'), objMap);
            }
                System.debug('itemParentChildMap1'+json.serialize(itemParentChildMap1));


            }
        }
        setkey.addAll(itemParentChildMap1.keyset());
        if(itemParentSiteMap1.keyset().size() > 0){
        itemParentSiteMap.putAll(itemParentSiteMap1);
        }
        if(itemMap2QLI != null && itemMap2QLI.size() > 0){
            for(Object obj : itemMap2QLI){
                Map<String,Object> objMap = (Map<String,Object>)obj;
                if(objMap.keyset().size() > 0){
                    itemParentChildMap2.put((String)objMap.get('Id'),objMap.get('Child'));
                    itemParentSiteMap2.put((String)objMap.get('Id'), objMap);
            }
        }
        }
        if(itemParentSiteMap2.keyset().size() > 0){
        itemParentSiteMap.putAll(itemParentSiteMap2);
        }
        System.debug('itemParentSiteMap'+json.serialize(itemParentSiteMap));
        System.debug('itemParentChildMap2'+json.serialize(itemParentChildMap2));
        System.debug('itemParentChildMap1'+json.serialize(itemParentChildMap1));
        setkey.addAll(itemParentChildMap2.keyset());
        Map<String,Object> finalMap = new Map<String,Object>();
        Map<String,Object> finalMap11 = new Map<String,Object>();
        for(String s : setkey){
            List<Object> objList = new List<Object>();
            if(itemParentChildMap1.get(s) != null){
              objList.addAll((List<Object>)itemParentChildMap1.get(s));
            }
            if(itemParentChildMap2.get(s) != null){
              objList.addAll((List<Object>)itemParentChildMap2.get(s));
            }
            finalMap.put(s,objList);
        }
        for(String s : finalMap.keyset()){
            if(finalMap.get(s) != null){
              List<Object> objList = (List<Object>)finalMap.get(s);
                List<Object> objFinalList = new List<Object>();
                Set<String> itemList = new set<String>();
                Map<String,Object> itemApproverMap = new Map<String,Object>();
                Map<String,Object> itemUniqueMap = new Map<String,Object>();
                if(objList.size() > 0){
                  for(Object obj: objList){
                        Map<String,Object> itemMap = (Map<String,Object>)obj;
                      if(itemList.contains((String)itemMap.get('Code'))){
                            //found duplicate
                        }
                        else{
                            itemList.add((String)itemMap.get('Code'));
                        }
                        itemUniqueMap.put((String)itemMap.get('Code'),itemMap);
                  }
                }
                
                for(String ss: itemUniqueMap.keyset()){
                    objFinalList.add(itemUniqueMap.get(ss));
                }
                System.debug('objFinalList'+json.serialize(objFinalList));
                finalMap11.put(s,objFinalList);
            }
        }








        List<Object> finalListobj = new List<Object>();
        for(String s: itemParentSiteMap.keyset()){
            Map<String,Object> objMap = new Map<String,Object>();
            objMap = (Map<String,Object>)itemParentSiteMap.get(s);
            objMap.put('Child',finalMap11.get(s));
            finalListobj.add(objMap);
        }
        outMap.put('QLI',finalListobj);
        
    }
    
    public class QuoteWrapper {
    public String PaymentTerm;
    public String Invoice;
    public String Benchmark;
  }
  
    public class responseWrapper{
    public List<QLI> QLI;
    public QuoteWrapper quote;
    }

  public class Child {
    public String CommercialManagerMandate;
    public String SalesDirectorMandate;
    public String SalesManagerMandate;
    public String SalesRepMandate;





        public String SalesRepMandatePercent;
        public String SalesManagerMandatePercent;
        public String SalesDirectorMandatePercent;
        public String CommercialManagerMandatePercent;
        public String OTDefault;
        public String isPercentProduct;





    public String OTFloorPrice;
    public String QuarantineTime;
    public String BaseQuantity;
    public String CommitmentPeriod;
    public String RCFloorPrice;
    public String Campaign;
    public String RequestedPercentage;
    public String RequestedPrice;
    public String Minideb;
    public String SubsidisedVoice;
    public String OTC;
    public String Name;
    public String Code;
        public String OTSalesRepMandate;
        public String OTSalesManagerMandate;
        public String OTSalesDirectorMandate;
        public String OTCommercialManagerMandate;
  }

  public class QLI {
    public List<Child> Child;
        public String CommercialManagerMandate;
        public String SalesDirectorMandate;
        public String SalesManagerMandate;
        public String SalesRepMandate;
        public String isPercentProduct;
    public String OTDefault;
    public String OTFloorPrice;
    public String QuarantineTime;
    public String BaseQuantity;
    public String CommitmentPeriod;
    public String RCFloorPrice;
    public String Campaign;
    public String RequestedPercentage;
    public String RequestedPrice;
    public String Minideb;
    public String SubsidisedVoice;
    public String OTC;
    public String Name;
    public String Code;
    public String Id;  
        public String OTSalesRepMandate;
        public String OTSalesManagerMandate;
        public String OTSalesDirectorMandate;
        public String OTCommercialManagerMandate;
  }
}