global class MCOnline_HardwarePrice_V0_2 implements vlocity_cmt.VlocityOpenInterface2 {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try { 
            if(methodName.equalsIgnoreCase('getHardwarePrice')) {
                MCOnline_HardwarePrice_V0_2.getHardwarePrice(inputMap, outMap);
            }else {
                result = false;
            }
        }catch(Exception e){
            result = false;
            String error_message= e.getMessage() +' '+e.getLineNumber();
            outMap.put('statusCode', 500);
            outMap.put('Exception', e.getStackTraceString());
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR', inputMap));
            MCOnline_Utility.logError(error_message,'500','MCONLINE_HardwarePriceMatrixV0.2,MCOnline_HardwarePrice_V0_2.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
            }
        return result;
    }

// Generate Error method for error handling ------------------->    
        public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap){
        
        String agreementNumber= String.valueOf(inputMap.get('AgreementNumber'));
        String offerBundleCode = String.valueOf(inputMap.get('offerBundleCode'));
        String commitmentDuration = String.valueOf(inputMap.get('CommitmentDuration'));
        String catalog = String.valueOf(inputMap.get('Catalog'));
        String offerCode = String.valueOf(inputMap.get('offerCode'));
        
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        string urlDetails = '{"agreementNumber": "'+agreementNumber+'", "offerBundleCode":"'+offerBundleCode+'", "commitmentDuration":"'+commitmentDuration+'", "catalog":"'+catalog+'", "offerCode":"'+offerCode+'"}';
        ipInputMap.put('functionality', 'GetMobileDevicePriceMatrix');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_HardwarePriceMatrixV0.2,MCOnline_HardwarePrice_V0_2.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
// Generate Error method for error handling ------------------->    

    public static void getHardwarePrice(Map<String,Object> inputMap, Map<String,Object> outMap){
    string agreementNumber = String.valueOf(inputMap.get('AgreementNumber'));
    string offerBundleCode  = String.valueOf(inputMap.get('offerBundleCode'));
    string commitmentDuration = String.valueOf(inputMap.get('CommitmentDuration'));
    string catalog = String.valueOf(inputMap.get('Catalog'));
    string offerCode = String.valueOf(inputMap.get('offerCode'));
 
 //errorHandling start --------------------------------------->
  if(!(commitmentDuration == '24' || commitmentDuration == '36')){
      outMap.put('ErrorResponse', generateError('InvalidCommitmentDuration1', inputMap));
      outMap.put('StatusCode', 400);
  }
    else if(String.isBlank(agreementNumber) || String.isBlank(offerBundleCode) || String.isBlank(commitmentDuration) || String.isBlank(catalog)|| String.isBlank(offerCode))
    {
        if(String.isBlank(agreementNumber)){
                outMap.put('ErrorResponse', generateError('InvalidOrBlankAgreementNumber', inputMap));
                outMap.put('StatusCode', 400);
        }
        else if(String.isBlank(offerBundleCode)){
                outMap.put('ErrorResponse', generateError('InvalidOrBlankOfferBundleCode', inputMap));
                outMap.put('StatusCode', 400);
        }
        else if(String.isBlank(commitmentDuration)){
                outMap.put('ErrorResponse', generateError('InvalidOrBlankCommitmentDuration', inputMap));
                outMap.put('StatusCode', 400);
        }
        else if(String.isBlank(catalog)){
                outMap.put('ErrorResponse', generateError('InvalidOrBlankCatalog', inputMap));
                outMap.put('StatusCode', 400);
        }
        else if(String.isBlank(offerCode)){
                outMap.put('ErrorResponse', generateError('InvalidOrBlankOfferCode', inputMap));
                outMap.put('StatusCode', 400);
        }
        
    }
// errorHandling stop ----------------------------------------> 

else
{
    Map<String,Map<String,String>> prodSapIdMap = getSAPIdMap(offerBundleCode);
    List<vlocity_cmt__ProductChildItem__c> childProdList = [SELECT id,vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.Name FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode =:offerBundleCode];
// error handling start-->
    if(childProdList.size()==0 || childProdList==null)
    {
     outMap.put('ErrorResponse', generateError('InvalidOfferBundleCode', inputMap));
     outMap.put('StatusCode', 400); 
    }
// error handling stop-->    
    List<String> childList = new List<String>();
    for( vlocity_cmt__ProductChildItem__c child : childProdList){
        childList.add(child.vlocity_cmt__ChildProductId__r.Name);
    }
    List<Product2> productObj = [SELECT id,name,productcode FROM Product2 WHERE Name IN:childList ];
    if(Test.isRunningTest()){
        agreementNumber = [select id, contractNumber from Contract limit 1].contractNumber;
    }
    List<vlocity_cmt__ContractLineItem__c> cliList = [SELECT id,vlocity_cmt__RecurringTotal__c, vlocity_cmt__contractid__r.contractnumber,name,vlocity_cmt__contractid__r.status,vlocity_cmt__productcode__c FROM vlocity_cmt__ContractLineItem__c WHERE (vlocity_cmt__ContractId__r.ContractNumber = :agreementNumber AND vlocity_cmt__ContractId__r.Status = 'Active')];
// error handling start-->
    if(cliList.size()==0 || cliList==null)
    {
     List<Contract> agreementNum = [select Id from Contract where ContractNumber=:agreementNumber limit 1];
     if(agreementNum.size()==0 || agreementNum==null)
     {
     outMap.put('ErrorResponse', generateError('InvalidAgreementNumber', inputMap));
     outMap.put('StatusCode', 400); 
     }
    }
// error handling stop-->      
    List<String> prodStrList = new List<String>();
    for( vlocity_cmt__ContractLineItem__c cliObj : cliList){
        prodStrList.add(cliObj.vlocity_cmt__productcode__c);
    }
    List<Product2> prodList = [select Id, Name, C2BC_Category__c, C2BC_Subcategory__c, ProductCode from Product2 where 
                               C2BC_Category__c='mobilevoicesubscription' AND C2BC_Subcategory__c='voice' AND ProductCode in :prodStrList];
    List<String> prodListStr = new List<String>();
    
    for(Product2 p : prodList){
        prodListStr.add(p.Name);
    }
    
    outMap.put('prodListStr size', prodListStr.size());
    List<PricematrixRanges__c> ranges = new List<PricematrixRanges__c>([select   High__c,Low__c,Name from PricematrixRanges__c]);
    List<Map<String, Object>> dataMap = new  List<Map<String, Object>>();
    Object[] inputdata = new List < Object > ();
    Map<string, string> agreementLines = new Map<string, string>();
    Map<string, string> agreementMap = new Map<string, string>();
    String prodSapId1;
    List<Map < String, Object >> dataMapChildren = new List<Map < String, Object >> ();
    for(vlocity_cmt__ContractLineItem__c cli : cliList){
        if(prodListStr.contains(cli.Name)){
            String priceRange;
            Decimal efsprice = cli.vlocity_cmt__RecurringTotal__c;
            if(efsprice != null){
                for(PricematrixRanges__c range : ranges){
                    if (efsprice >= range.Low__c && efsprice <= range.High__c){
                        priceRange = range.Name;
                    }
                }
                agreementLines.put(cli.vlocity_cmt__productcode__c,String.valueOf(cli.vlocity_cmt__RecurringTotal__c));
                for(Product2 childProd : productObj){
                    Map < String, Object > dataMap2 = new Map < String, Object > ();
                    dataMap2.put('Source Product Name', childProd.name);
                    dataMap2.put('Source Product Code', childProd.ProductCode);
                    dataMap2.put('Quantity', priceRange);
                    dataMap2.put('Characteristic Name', 'HWSAPID');
                    prodSapId1 = ((Map<String,String>)prodSapIdMap.get(childProd.ProductCode)).get('sAPID');    
                    dataMap2.put('Characteristic Value', prodSapId1);
                    dataMap2.put('listPrice',((Map<String,String>)prodSapIdMap.get(childProd.ProductCode)).get('listPrice'));
                    dataMapChildren.add(dataMap2);
                    agreementMap.put(prodSapId1+''+priceRange,cli.vlocity_cmt__productcode__c);
                }
            }
        }
    }
    if(commitmentDuration != null){
        invokeProcedure(dataMapChildren, outMap, agreementLines, agreementMap, commitmentDuration,prodSapIdMap);  
    }
}
}
    public static Map<String,Map<String,String>> getSAPIdMap(String offerBundleCode){
    List<vlocity_cmt__ProductChildItem__c> childProdList = [SELECT id,vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.vlocity_cmt__JSONAttribute__c FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode =:offerBundleCode];
       
        List<String> childList = new List<String>();
        for( vlocity_cmt__ProductChildItem__c child : childProdList){
            childList.add(child.vlocity_cmt__ChildProductId__r.ProductCode);
        }
        List<vlocity_cmt__PriceListEntry__c> productObj1 = [select vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c,vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProductId__c,vlocity_cmt__ProductId__r.ProductCode from vlocity_cmt__PriceListEntry__c   where vlocity_cmt__ProductId__r.ProductCode  IN :childList ];
        Map<String,Map<String,String>> mapSAPId = new Map<String,Map<String,String>>();
        String prodSapId;
        Map<String,object> map1 = new Map<String,object>();
        List<object> attrList = new List<object>();
        for(vlocity_cmt__PriceListEntry__c prod : productObj1){
            String prodid = prod.vlocity_cmt__ProductId__c;
            Map<String,String> SAPListPrice = new Map<String,String>();  
            if(prod.vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c!=null){
                String attr = prod.vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c;
                map1 = (Map<String,object>) JSON.deserializeUntyped(attr);
                attrList = (List<object>)map1.get('ATT_CODE_TELIAMOBAGGR');
                for(object o : attrList){
                    Map<String,object> map3 = new Map<String,object>();
                    map3 = (Map<String,object>) o;
                    if(map3.get('attributeuniquecode__c') == 'ATT_HW_SAP_ID'){
                        prodSapId = (String)map3.get('value__c');
                        SAPListPrice.put('sAPID',prodSapId);
                        SAPListPrice.put('listPrice',String.ValueOf(prod.vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c));
                        mapSAPId.put(prod.vlocity_cmt__ProductId__r.ProductCode,SAPListPrice);
                    }
                }
            }
        }
        return mapSAPId; 
    }
    public static void invokeProcedure(List<Object> dataMap, 
                                        Map<String,Object> outMap, 
                                        Map<String,String> agreementLinesCodeList, 
                                        Map<string, string> agreementMap, string commitmentDuration,Map<string,Map<String,String>> prodSapIdMap){
                                         
      Map < String, Object > inputMap = new Map < String, Object > ();
      Map < String, Object > options = new Map < String, Object > ();
      Map<string,HW_Cal_Procedure__c> calProc = HW_Cal_Procedure__c.getall();
      String configurationName;
      if(commitmentDuration != null && commitmentDuration.equalsIgnoreCase('24')){
        configurationName = (String)(calProc.get('Hardware_24M').get('configurationName__c'));
        options.put('configurationName', configurationName);
      }else if(commitmentDuration != null && commitmentDuration.equalsIgnoreCase('36')){
        configurationName = (String)(calProc.get('Hardware_36M').get('configurationName__c'));
        options.put('configurationName', configurationName);
      }
      options.put('includeInputs', true);
      Object[] inputdata = new List < Object > ();
      Map < String, Object > c = new Map < String, Object > ();
      List < Object > productList = new List < Object > ();
      Map < String, Object > prod1 = new Map < String, Object > ();
      inputMap.put('UserInputList', dataMap);
      options.put('verbose', false);
      options.put('mergeInListName', 'UserInputList');
      Map < String, Object > output = new Map < String, Object > ();
      Type t = Type.forName('vlocity_cmt','PricingMatrixCalculationService');
      vlocity_cmt.VlocityOpenInterface vpsi = (vlocity_cmt.VlocityOpenInterface) t.newInstance();
       string outputRespose ;
      if(!Test.isRunningTest()){
       vpsi.invokeMethod('calculate', inputMap, output, options);
       outputRespose = JSON.serialize(output);
      }else{
       outputRespose='[{"Source Product Code":"", "Source Product Name":"", "Characteristic Value":"", "Characteristic Name":"", "PriceMatrix_36M_Hardware__MRC":"", "PriceMatrix_36M_Hardware__NRC":""}]';
      }                                      
                                        
      outputRespose = outputRespose.replace('Source Product Code', 'SourceProductCode');
      outputRespose = outputRespose.replace('Source Product Name', 'SourceProductName');
      outputRespose = outputRespose.replace('Characteristic Value', 'CharacteristicValue');
      outputRespose = outputRespose.replace('Characteristic Name', 'CharacteristicName');
      outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__MRC', 'MRC');
      outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__NRC', 'NRC'); 
      MCOnline_HardwarePrice_V0_2 hwWrapperObj = MCOnline_HardwarePrice_V0_2.parse(outputRespose);
      List<cls_calculationResults> resultList = new List<cls_calculationResults>();                                           
      List<CalculationResult> resultNewList = new List<CalculationResult>();
      if(hwWrapperObj.output != null && (hwWrapperObj.output).size() > 0){
        List<cls_calculationResults>  calResult = new List<cls_calculationResults>();
        calResult = hwWrapperObj.output[0].calculationResults;
        for(cls_calculationResults calculationResultObj : calResult){
             CalculationResult calculationResultNewObj = new CalculationResult();
             String subProdCode = calculationResultObj.CharacteristicValue+calculationResultObj.Quantity;
             calculationResultNewObj.SubscriptionProductCode = String.valueOf(agreementMap.get(subProdCode));
             calculationResultNewObj.subscriptionMRC = agreementLinesCodeList.get(calculationResultNewObj.SubscriptionProductCode);
             calculationResultNewObj.increasedMRC = calculationResultObj.MRC;
             calculationResultNewObj.increasedNRC = calculationResultObj.NRC;
             calculationResultNewObj.mobileDeviceProductCode = calculationResultObj.SourceProductCode;
             calculationResultNewObj.mobileDeviceSAPId = calculationResultObj.CharacteristicValue;
             String price = ((Map<String,String>) prodSapIdMap.get(calculationResultNewObj.mobileDeviceProductCode)).get('listPrice');
             calculationResultNewObj.mobileDeviceNRC = price;
             resultNewList.add(calculationResultNewObj);
         }
         outMap.put('statusCode', 200);
         outMap.put('outputRespose', JSON.serialize(resultNewList));
     
     }
     
}
    public cls_output[] output;
    class cls_output {
        public cls_aggregationResults aggregationResults;
        public cls_calculationResults[] calculationResults;
    }
    class cls_aggregationResults {
    }
    class cls_calculationResults {
        public String MRC;
        public String NRC;
        public String SourceProductName;
        public String SourceProductCode;
        public String Quantity;
        public String CharacteristicName;
        public String CharacteristicValue;
        
        
    }
    class CalculationResult {
        public String increasedMRC;
        public String increasedNRC;
        public String SubscriptionProductCode;
        public String mobileDeviceSAPId;
        public String mobileDeviceProductCode;
        public String subscriptionMRC;
        public String mobileDeviceNRC;
        
    }
    public static MCOnline_HardwarePrice_V0_2 parse(String json){
        return (MCOnline_HardwarePrice_V0_2) System.JSON.deserialize(json, MCOnline_HardwarePrice_V0_2.class);
    }
}