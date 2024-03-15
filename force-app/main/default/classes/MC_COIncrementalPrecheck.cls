global class MC_COIncrementalPrecheck implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {

            if(methodName.equalsIgnoreCase('transformSiteList')) {
                transformSiteList(inputMap,outMap);
                outMap.put('Result',result);  
                return result;  
            }else if(methodName.equalsIgnoreCase('recalculateListPriceAllSites')) {
                recalculateListPriceAllSites(inputMap,outMap);
                return result;  
            }else if(methodName.equalsIgnoreCase('deletePrecheckData')){
                deletePrecheckData(inputMap,outMap);
                return result;
            
            
            }else{
                result = false;
                outMap.put('ErrorMessage','Method not found for average calculation');
                outMap.put('Result',result);  
                return result;  
            } 
        }catch(Exception ex) {          
            result = false;
            outMap.put('ErrorCoIncrementalPrecheck','Error');
            outMap.put('Errorlinenumber',ex.getLineNumber());
            outMap.put('ErrorMessage',ex.getmessage());
            outMap.put('Result',result);
            return result;  
        } 
              
    }
    public static void transformSiteList(Map<String,Object> inputMap, Map<String,Object> outMap){
        List<Object> siteList = (List<Object>)inputMap.get('siteList');// Get list of sites
        List<Object> newSiteList = new List<Object>();
        if(siteList!=null && siteList.size()>0){   //Check if List is Empty
            for(Object stlist: siteList){
                Map<String,Object> siteInfo = (Map<String,Object>)stlist;
                if(siteInfo.get('isDisabled')!=null && (Boolean)siteInfo.get('isDisabled')==false){ // Check isDisabled flag to add sites in newSiteList
                    newSiteList.add(siteInfo);
                }
            }
            outMap.put('newsiteList',newSiteList);
        }
    }
    
    public static map<String,Object> recalculateListPriceAllSites(Map<String, Object> inputMap,Map<String, Object> outputMap){
        
        String objId = (String)inputMap.get('Opportunity');// Get input from IP ListPrice_Recalculate
        List<MC_PreCheck_Result__c> addUpdatedListPrice = new List<MC_PreCheck_Result__c>(); 
        Map<String,Object> adjustmentMap = new Map<String,Object>();
        List<MC_PreCheck_Result__c> queryPrecheck = new List<MC_PreCheck_Result__c>();

        queryPrecheck = [select id, Name, MC_Product_Code__c,Price__c, MC_PriceParameter__c,MC_PriceAverageFlag__c from MC_PreCheck_Result__c where Opportunity__c =:objId and RecordType.Name='Netfraga Response' and mc_product_code__c<>null and MC_PriceParameter__c<>null];
        
        List<Object> adjustmentList = (List<Object>)inputMap.get('Adjustment'); //Get the Price adjustment values from the DR_ExtractPSTU 
        if(adjustmentList!=null && adjustmentList.size()>0){
         for(Object adj : adjustmentList){
            Map<String,Object> tempMap = (Map<String,Object>)adj;
            adjustmentMap.put((String)tempMap.get('Label'),tempMap); //map label to the Adjustment key value pair and put it in the adjsutmentMap
         } 
        }
        Map<String,Object> prodExtMap = (Map<String,Object>)inputMap.get('ProductExtract'); // Get from DR_ExtractCOProducts  
        List<Object> parentMap = (List<Object>)prodExtMap.get('Parent');   //parent product     
           if(queryPrecheck!=null && queryPrecheck.size()>0){
            for(MC_PreCheck_Result__c price : queryPrecheck){
                 MC_PreCheck_Result__c result1 = new MC_PreCheck_Result__c();
                 String adjKey = price.MC_PriceParameter__c; // Price Parameter
                 String pCode = price.MC_Product_Code__c; //Product Code
                 result1.Id = price.Id;
                 Boolean priceAvgFlag = price.MC_PriceAverageFlag__c; // Price Average Flag
                 if(adjKey != null && priceAvgFlag && adjustmentMap.get(adjKey) != null){
                    for(Object parentObj : parentMap){
                        Map<String,Object> eachParentMap = (Map<String,Object>)parentObj; 
                        if(eachParentMap.containskey('ProductNetfragaName')){
                            String pnetFragaName = String.valueof(eachParentMap.get('ProductNetfragaName')); // Get value of ProductNetfragaName from eachParentMap
                            List<Object> childListMap = (List<Object>)eachParentMap.get('Child');// Child Product
            
                          for(Object childObj : childListMap){
                            Map<string, Object> eachChildMap = (Map<String, object>)childObj;
                        
                                if(eachChildMap.containskey('ProductCode')!= null && eachChildMap.get('ProductCode')== pCode){
                                    Decimal pricekey = Integer.valueof(eachChildMap.get('Amount')); // Take the amount value and put in priceKey
                                    Map<String,Object> tempMap = (Map<String,Object>)adjustmentMap.get(adjKey);// Use the Price Parameter value(adjKey) from the adjustmentMap to get Key value matching with it
                                    if(Integer.valueOf(tempMap.get(pnetFragaName)) != null){
                                        Decimal priceAdj = pricekey + Integer.valueOf(tempMap.get(pnetFragaName));//Add product price with price adjsutment value
                                        result1.Price__c = priceAdj != null ? priceAdj : pricekey; 
                                        addUpdatedListPrice.add(result1);
                                    }

                            }
                        }
                    }
                }
            }
        }
      }
      //create a map that will hold the values of the list

      map<Id,MC_PreCheck_Result__c> finalPrecheckMap = new map<Id,MC_PreCheck_Result__c>();
      //put all the values from the list to map
      if(addUpdatedListPrice.size()>0){
          finalPrecheckMap.putall(addUpdatedListPrice);
          if(finalPrecheckMap.size()>0){
            Update finalPrecheckMap.values();
            outputMap.put('Result','true');
            return outputMap;
          }else{
           outputMap.put('ErrorMessage','No change in the list price');
           outputMap.put('Result','false');
           return outputMap;
          }
      }else{
           outputMap.put('ErrorMessage','No change in the list price');
           outputMap.put('Result','false');
           return outputMap;

        }
    }  
    //Below method will get invoked from TeliaSE_ContractQuote when seller does not want CO in qualify services
     public static void deletePrecheckData(Map<String,Object> inputMap, Map<String,Object> outMap){
         try{
        String ContextId = (String)inputMap.get('ContextId'); // get Opportunity ID
        String AccId = (String)inputMap.get('AccountId');
        Opportunity opp = new Opportunity();
        opp.Id = ContextId;
        opp.IsPreChecked__c = false;
        opp.PrecheckDate__c = null;
        update opp;
        //Commented below lines as part of defect fix MCSTO-9643
        //List<vlocity_cmt__Premises__c> premiseIdList = new List<vlocity_cmt__Premises__c>();
        //premiseIdList = [select id from vlocity_cmt__Premises__c where vlocity_cmt__PropertyOwnerAccountId__c=:AccId];
        delete [Select id from MC_PreCheck_Result__c where  Opportunity__c =:ContextId];       
        //delete premiseIdList;
         }
         Catch(Exception e)
        {
            
            throw new COIncrementalPrecheckException(e.getMessage()+e.getLineNumber()+e.getStackTraceString());
        }
     }
    public class COIncrementalPrecheckException extends Exception{}
    }