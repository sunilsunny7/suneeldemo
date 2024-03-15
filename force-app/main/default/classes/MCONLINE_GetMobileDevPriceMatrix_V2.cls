global with sharing class MCONLINE_GetMobileDevPriceMatrix_V2 implements vlocity_cmt.VlocityOpenInterface2 {
    
    public cls_output[] output;
    public static List<cls_calculationResults> extractedItems=new List<cls_calculationResults>();
    
    public MCONLINE_GetMobileDevPriceMatrix_V2()
    {}
    public MCONLINE_GetMobileDevPriceMatrix_V2(List<cls_calculationResults> calculatedItems)
    {
       
        cls_output ouputObject= new cls_output();
        ouputObject.calculationResults=calculatedItems;
         cls_output[] output1= new cls_output[]{ouputObject};
        this.output =output1;
    }
    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        Boolean result = true;
        try {
            if (methodName.equalsIgnoreCase('getHardwarePrice')) {
                MCONLINE_GetMobileDevPriceMatrix_V2.getHardwarePrice(inputMap, outMap);
            }else {
                result = false;
            }
        }catch(Exception e){
            result = false;
            String error_message= e.getMessage() +' '+e.getLineNumber();
            outMap.put('statusCode', 500);
            outMap.put('Exception', e.getMessage()+e.getLineNumber());
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR', inputMap));
            MCOnline_Utility.logError(error_message,'500','MCONLINE_GetMobileDevPriceMatrix_V2,MCONLINE_GetMobileDevPriceMatrix_V2.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }
        return result;
    }
    
    // Method to Generate Error 
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
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_GetMobileDevPriceMatrix_V2,MCONLINE_GetMobileDevPriceMatrix_V2.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    
    //Method to get hardware price from matrix
    public static void getHardwarePrice(Map<String,Object> inputMap, Map<String,Object> outMap){
        
        string errorCode,agreementNumber = inputMap.get('AgreementNumber')+'',offerBundleCode  = inputMap.get('offerBundleCode')+'',commitmentDuration = inputMap.get('CommitmentDuration')+'',catalog = inputMap.get('Catalog')+'',offerCode = inputMap.get('offerCode')+'';
        Boolean validParams = commitmentDuration != '24' && commitmentDuration != '36' && commitmentDuration != '0';
        List < String > prodName = new List < String > ();
        prodName.add(offerCode);
        prodName.add(offerBundleCode);
        //validate OfferCode , Catalog and commitment duration. 
        Map < ID, vlocity_cmt__ProductChildItem__c > childProdList = new Map < ID, vlocity_cmt__ProductChildItem__c > ([SELECT id, vlocity_cmt__ChildProductId__c, vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.vlocity_cmt__JSONAttribute__c,vlocity_cmt__ParentProductId__r.ProductCode FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode IN: prodName AND (vlocity_cmt__ParentProductId__r.ProductCode =: offerBundleCode OR vlocity_cmt__ChildProductId__r.ProductCode =:offerBundleCode) WITH SECURITY_ENFORCED]);
        Set<String> parentProd = new Set<String>();
        Map < ID, vlocity_cmt__ProductChildItem__c > tempChildProdList = childProdList;
        if(childProdList !=null && !childProdList.isEmpty()){
           for (ID idKey: tempChildProdList.keyset()) {
            vlocity_cmt__ProductChildItem__c child = tempChildProdList.get(idKey);
            parentProd.add(child.vlocity_cmt__ParentProductId__r.ProductCode);
              if(child.vlocity_cmt__ParentProductId__r.ProductCode == offerCode){
                  childProdList.remove(idKey);
              }
          } 
        }
        //if (validParams || catalog != 'MOBILEDEVICE' || !(parentProd?.contains(offerCode)) || childProdList?.isEmpty()) {
        if (validParams || !catalog.contains('MOBILEDEVICE') || !(parentProd?.contains(offerCode)) || childProdList?.isEmpty()) {    
            //errorCode =  validParams ? 'InvalidCommitmentDuration1' : (catalog != 'MOBILEDEVICE') ? 'InvalidOrBlankCatalog' : (childProdList?.isEmpty()) ? 'InvalidOrBlankOfferBundleCode': !(parentProd?.contains(offerCode)) ? 'InvalidOrBlankOfferCode' : null;
            errorCode =  validParams ? 'InvalidCommitmentDuration1' : (!catalog.contains('MOBILEDEVICE')) ? 'InvalidOrBlankCatalog' : (childProdList?.isEmpty()) ? 'InvalidOrBlankOfferBundleCode': !(parentProd?.contains(offerCode)) ? 'InvalidOrBlankOfferCode' : null;
            outMap.put('ErrorResponse', generateError(errorCode, inputMap));
            outMap.put('StatusCode', 400);
        }else if(String.isBlank(agreementNumber) || String.isBlank(offerBundleCode) || String.isBlank(offerCode)){
            //check if blank value passed for agreementNumber , offerBundleCode and offerCode.
            if(String.isBlank(agreementNumber)){
                errorCode = 'InvalidOrBlankAgreementNumber';
            }else if(String.isBlank(offerBundleCode)){
                errorCode = 'InvalidOrBlankOfferBundleCode';
            }else if(String.isBlank(offerCode)){
                errorCode = 'InvalidOrBlankOfferCode';
            }
            outMap.put('ErrorResponse', generateError(errorCode, inputMap));
            outMap.put('StatusCode', 400);
        }else{
            Map < String, Map < String, String >> prodSapIdMap = getSAPIdMap(offerBundleCode, childProdList);
            if(prodSapIdMap.isEmpty()){
                //if no SAPid found then send empty list.  
                outMap.put('statusCode', 200);
                List<Object> nullResponse = new List<Object>();
                outMap.put('outputRespose',nullResponse);
            }else{
               if (Test.isRunningTest()) {
                agreementNumber = [select id, contractNumber from Contract where Status = 'Active'
                    limit 1
                ]?.contractNumber;
                }
            List < vlocity_cmt__ContractLineItem__c > cliList = [SELECT id, vlocity_cmt__RecurringTotal__c, TeliaSE_MC_Customer_Requested_Price__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__contractid__r.contractnumber, name, vlocity_cmt__contractid__r.status, vlocity_cmt__productcode__c FROM vlocity_cmt__ContractLineItem__c WHERE(vlocity_cmt__ContractId__r.ContractNumber =: agreementNumber AND vlocity_cmt__ContractId__r.Status = 'Active'
                AND vlocity_cmt__Product2Id__r.C2BC_Category__c = 'mobilevoicesubscription'

                AND vlocity_cmt__Product2Id__r.C2BC_Subcategory__c = 'voice') WITH SECURITY_ENFORCED];

            // check if agreement is active and has contract line items
            if (cliList == null || cliList.isEmpty()) {
                outMap.put('ErrorResponse', generateError('InvalidAgreementNumber', inputMap));
                outMap.put('StatusCode', 400);
            } else {
                
                // fetch the products with Object type = MBV-SUBS-OSUB from product2 where product code is present in the contract line item list
                List<String> contractProducts = new List<String>();
                List<String> onlineOSUBProd = new List<String>();
                List< vlocity_cmt__ContractLineItem__c> cliCopy = new List< vlocity_cmt__ContractLineItem__c>();
                cliCopy.addAll(cliList);
                for(vlocity_cmt__ContractLineItem__c lineItem : cliList)
                    contractProducts.add(lineItem.vlocity_cmt__ProductCode__c);
                for(Product2 onlineProd : [select id,ProductCode from Product2 where ProductCode in:contractProducts AND Family ='Online Order' AND vlocity_cmt__ObjectTypeName__c= 'MBV-SUBS-OSUB' WITH SECURITY_ENFORCED])
                    onlineOSUBProd.add(onlineProd.ProductCode);
                for(vlocity_cmt__ContractLineItem__c contractItem:cliCopy){
                    if(onlineOSUBProd.contains(contractItem.vlocity_cmt__productcode__c)){
                        Integer ind = cliList.indexOf(contractItem);
                        cliList.remove(ind);
                    }
                }
                
                //fetch available price ranges
                List < PricematrixRanges__c > ranges = PricematrixRanges__c.getall().values();
                    List<Map<String, Object>> dataMap = new  List<Map<String, Object>>();
                    Object[] inputdata = new List < Object > ();
                    Map<string, string> agreementLines = new Map<string, string>();
                    Map<string, string> agreementMap = new Map<string, string>();
                    String prodSapId1;
                    List<Map < String, Object >> dataMapChildren = new List<Map < String, Object >> ();
                    //for each contract Line item check find out the price range.customer requested price is considered
                    //if it is not null else Recurring price is considered.
                    for(vlocity_cmt__ContractLineItem__c cli : cliList){
                        String priceRange;
                        Decimal efsprice;
                        if(cli.TeliaSE_MC_Customer_Requested_Price__c!=null){
                            efsprice = cli.TeliaSE_MC_Customer_Requested_Price__c;
                        }else if(cli.vlocity_cmt__RecurringCharge__c!=null){
                            efsprice = cli.vlocity_cmt__RecurringCharge__c;
                        }
                        //assign the price range depending on the price of the subscription.                      
                        if(efsprice != null){
                            for (PricematrixRanges__c range: ranges) {
                                if (efsprice >= range.Low__c && efsprice <= range.High__c){
                                    priceRange = range.Name;
                                    break;
                                }
                            }
                            agreementLines.put(cli.vlocity_cmt__productcode__c, String.valueOf(efsprice));
                            for (ID idKey: childProdList.keyset()) {
                                vlocity_cmt__ProductChildItem__c child = childProdList.get(idKey);
                                Product2 childProd = child.vlocity_cmt__ChildProductId__r;
                                if(childProd!=null && prodSapIdMap.containsKey(childProd.ProductCode)){
                                    Map < String, Object > dataMap2 = new Map < String, Object > ();
                                    //dataMap2.put('Source Product Name', childProd.name);
                                    dataMap2.put('Source Product Code', childProd.ProductCode);
                                    dataMap2.put('Quantity', priceRange);
                                    dataMap2.put('Characteristic Name', 'HWSAPID');
                                    prodSapId1 = ((Map<String,String>)prodSapIdMap.get(childProd.ProductCode)).get('sAPID');
                                    dataMap2.put('Characteristic Value', prodSapId1);
                                    dataMap2.put('listPrice',((Map<String,String>)prodSapIdMap.get(childProd.ProductCode)).get('listPrice'));
                                    dataMap2.put('SubscriptionProductCode',cli.vlocity_cmt__productcode__c);
                                    dataMap2.put('SubscriptionMRC',String.valueOf(efsprice));
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
            
        }
    }
    
    //method to get SAP ID of HW
    public static Map < String, Map < String, String >> getSAPIdMap(String offerBundleCode, Map < ID, vlocity_cmt__ProductChildItem__c > childProdList) {

        List < String > childList = new List < String > ();
        for (ID idKey: childProdList.keyset()) {
            vlocity_cmt__ProductChildItem__c child = childProdList.get(idKey);
            if(child.vlocity_cmt__ChildProductId__r.ProductCode!=null)
                childList.add(child.vlocity_cmt__ChildProductId__r.ProductCode);
        }
        //Fetch list price of the HW under the input offerBundleCode.
        List < vlocity_cmt__PriceListEntry__c > productObj1 = [select vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c, vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProductId__c, vlocity_cmt__ProductId__r.ProductCode from vlocity_cmt__PriceListEntry__c where vlocity_cmt__ProductId__r.ProductCode IN: childList AND vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c = 'One-time'
            AND vlocity_cmt__PriceListName__c = 'Online Pricelist'
            AND vlocity_cmt__IsActive__c = true AND vlocity_cmt__ProductId__r.TeliaSE_MatrixPriceFlag__c =true WITH SECURITY_ENFORCED
        ];
        Map<String,Map<String,String>> mapSAPId = new Map<String,Map<String,String>>();
        String prodSapId;
        Map<String,object> map1 = new Map<String,object>();
        List<object> attrList = new List<object>();
        for(vlocity_cmt__PriceListEntry__c prod : productObj1){
            String prodid = prod.vlocity_cmt__ProductId__c;
            Map<String,String> SAPListPrice = new Map<String,String>();
            //get the SAPID of the HW.
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
                        break;
                    }
                }
            }
        }
        return mapSAPId; 
    }
  
    //method to invoke calculation procedure
    public static void invokeProcedure(List<Object> dataMap,Map<String,Object> outMap,Map<String,String> agreementLinesCodeList,Map<string, string> agreementMap, string commitmentDuration,Map<string,Map<String,String>> prodSapIdMap){
        MCONLINE_GetMobileDevPriceMatrix_V2 hwWrapperObj;
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > options = new Map < String, Object > ();
        Map<string,HW_Cal_Procedure__c> calProc = HW_Cal_Procedure__c.getall();
        String configurationName,outputRespose,outforCompare;
        List<CalculationResult> finalList = new List<CalculationResult>();
        List<String> noPriceProd = new List<String>();
        List<Map < String, Object >> noPriceDataMap = new List<Map < String, Object >> ();
        if (commitmentDuration?.equalsIgnoreCase('24')) {
            configurationName = (String)(calProc.get('Hardware_24M').get('configurationName__c'));
            options.put('configurationName', configurationName);
        }else if (commitmentDuration?.equalsIgnoreCase('36')) {
            configurationName = (String)(calProc.get('Hardware_36M').get('configurationName__c'));
            options.put('configurationName', configurationName);
        }else if(commitmentDuration == '0'){
            configurationName = 'No_Calculation_Procedure';
        }
        if(configurationName == 'No_Calculation_Procedure'){
            outputRespose = getListPriceResponse(dataMap);
            hwWrapperObj = MCONLINE_GetMobileDevPriceMatrix_V2.parse(outputRespose);
        }else{
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
            if(!Test.isRunningTest()){
                vpsi.invokeMethod('calculate', inputMap, output, options);
                
                
                cls_calculationResults extractedItem;
                for(Object obj:(List<Object>)output.get('output'))
                {
                    vlocity_cmt.PricingCalculationService.CalculationProcedureResults item=(vlocity_cmt.PricingCalculationService.CalculationProcedureResults)obj;
                    for(Object obj1:(List<Object>)item.calculationResults)
                    {
                        extractedItem=new cls_calculationResults();
                        Map<String,Object> data=(Map<String,Object>)obj1;
                        extractedItem.SourceProductCode=String.valueOf(data.get('Source Product Code'));
                        extractedItem.Quantity=String.valueOf(data.get('Quantity'));
                        extractedItem.CharacteristicName=String.valueOf(data.get('Characteristic Name'));
                        extractedItem.CharacteristicValue=String.valueOf(data.get('Characteristic Value'));
                        extractedItem.SubscriptionProductCode=String.valueOf(data.get('SubscriptionProductCode'));
                        extractedItem.MRC=data.containsKey('PriceMatrix_36M_Hardware__MRC')?String.valueOf(data.get('PriceMatrix_36M_Hardware__MRC')):String.valueOf(data.get('PriceMatrix_24M_Hardware__MRC'));    
                        extractedItem.NRC=data.containsKey('PriceMatrix_36M_Hardware__NRC')?String.valueOf(data.get('PriceMatrix_36M_Hardware__NRC')):String.valueOf(data.get('PriceMatrix_24M_Hardware__NRC'));    
                        extractedItem.SubscriptionMRC=String.valueOf(data.get('SubscriptionMRC'));
                        extractedItem.SubscriptionProductCode=String.valueOf(data.get('SubscriptionProductCode'));
                        
                        extractedItems.add(extractedItem);
                    }
                                        
                }

                //outputRespose = JSON.serialize(output);
            }else{
                cls_calculationResults extractedItem=new cls_calculationResults();
                Map<String,Object> data=new Map<String,Object>();
                data.put('Source Product Code','');
                data.put('Quantity','');
                data.put('Characteristic Name','');
                data.put('Characteristic Value','');
                data.put('SubscriptionProductCode','');
                data.put('PriceMatrix_36M_Hardware__MRC','');
                data.put('PriceMatrix_36M_Hardware__NRC','');
                data.put('SubscriptionMRC','');
                data.put('SubscriptionProductCode','');
                extractedItem.SourceProductCode=String.valueOf(data.get('Source Product Code'));
                extractedItem.Quantity=String.valueOf(data.get('Quantity'));
                extractedItem.CharacteristicName=String.valueOf(data.get('Characteristic Name'));
                extractedItem.CharacteristicValue=String.valueOf(data.get('Characteristic Value'));
                extractedItem.SubscriptionProductCode=String.valueOf(data.get('SubscriptionProductCode'));
                extractedItem.MRC=data.containsKey('PriceMatrix_36M_Hardware__MRC')?String.valueOf(data.get('PriceMatrix_36M_Hardware__MRC')):String.valueOf(data.get('PriceMatrix_24M_Hardware__MRC'));    
                extractedItem.NRC=data.containsKey('PriceMatrix_36M_Hardware__NRC')?String.valueOf(data.get('PriceMatrix_36M_Hardware__NRC')):String.valueOf(data.get('PriceMatrix_24M_Hardware__NRC'));    
                extractedItem.SubscriptionMRC=String.valueOf(data.get('SubscriptionMRC'));
                extractedItem.SubscriptionProductCode=String.valueOf(data.get('SubscriptionProductCode'));
                extractedItems.add(extractedItem);
                //outputRespose='[{"Source Product Code":"","Characteristic Value":"", "Characteristic Name":"", "PriceMatrix_36M_Hardware__MRC":"", "PriceMatrix_36M_Hardware__NRC":""}]';
            }
            /*
            outputRespose = outputRespose.replace('Source Product Code', 'SourceProductCode');
            //outputRespose = outputRespose.replace('Source Product Name', 'SourceProductName');
            outputRespose = outputRespose.replace('Characteristic Value', 'CharacteristicValue');
            outputRespose = outputRespose.replace('Characteristic Name', 'CharacteristicName');
            if(commitmentDuration != null && commitmentDuration.equalsIgnoreCase('36')){
                outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__MRC', 'MRC');
                outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__NRC', 'NRC');
            }else if(commitmentDuration != null && commitmentDuration.equalsIgnoreCase('24')){
                outputRespose = outputRespose.replace('PriceMatrix_24M_Hardware__MRC', 'MRC');
                outputRespose = outputRespose.replace('PriceMatrix_24M_Hardware__NRC', 'NRC');
            }*/
        }
        if(configurationName != 'No_Calculation_Procedure'){
            hwWrapperObj = new MCONLINE_GetMobileDevPriceMatrix_V2(extractedItems);
        }
        List<cls_calculationResults> resultList = new List<cls_calculationResults>();                                           
        List<CalculationResult> resultNewList = new List<CalculationResult>();
        //if price matrix response contains data then process.                                      
        if ((hwWrapperObj.output)?.size() > 0) {
            //format the response 
            System.debug('came here '+hwWrapperObj.output.size()); 
            resultNewList = formatResponse(hwWrapperObj,agreementMap,agreementLinesCodeList,prodSapIdMap,commitmentDuration);
            outMap.put('statusCode', 200);
            outMap.put('outputRespose', JSON.serialize(resultNewList));
        }else{
            //if no data in price matrix response then send empty list.  
            outMap.put('statusCode', 200);
            List<Object> nullResponse = new List<Object>();
            outMap.put('outputRespose',nullResponse);
        }                                     
    }
    
    //wrapper class for output
    class cls_output {
        
        public cls_aggregationResults aggregationResults;
        public cls_calculationResults[] calculationResults;
    }
    


    class cls_aggregationResults {}

    class cls_calculationResults {
        
        public String MRC;
        public String NRC;
        public String SourceProductName;
        public String SourceProductCode;
        public String Quantity;
        public String CharacteristicName;
        public String CharacteristicValue;
        //added SubscriptionProductCode,subscriptionMRC to retain value when parsed( MCONL-8516)
        public String SubscriptionProductCode;
        public String subscriptionMRC;
        public String upfrontPaymentNRC;
        
        
    }
    class CalculationResult {
        
        public String increasedMRC;
        public String increasedNRC;
        public String subscriptionProductCode;
        public String mobileDeviceSAPId;
        public String mobileDeviceProductCode;
        public String subscriptionMRC;
        public String mobileDeviceNRC;
        public String upfrontPaymentNRC;
        
    }
    
    //method to parse JSON string
    public static MCONLINE_GetMobileDevPriceMatrix_V2 parse(String json){
        
        return (MCONLINE_GetMobileDevPriceMatrix_V2) System.JSON.deserialize(json, MCONLINE_GetMobileDevPriceMatrix_V2.class);
    }
    
    //Get list price of HW
    public static string getListPriceResponse(List<Object> dataMap){
        
        Map<String,Object> output1 = new Map<String,Object>();
        List<Map<String,Object>> CalculationResults  = new List<Map<String,Object>>();
        Map<String,List<Object>> CalculationResults1 = new Map<String,List<Object>>();
        List<Object> output = new List<Object>();
        string outputRespose;
        for(Object data : dataMap){
            Map<String,Object> res = (Map<String,Object>)data;
            res.put('MRC','0');
            res.put('NRC','0');
            CalculationResults.add(res);
        }
        CalculationResults1.put('CalculationResults',CalculationResults);
        CalculationResults1.put('aggregationResults',null);
        output.add(CalculationResults1);
        output1.put('output',output);
        outputRespose = JSON.serialize(output1);
        outputRespose = outputRespose.replace('Source Product Code', 'SourceProductCode');
        outputRespose = outputRespose.replace('Source Product Name', 'SourceProductName');
        outputRespose = outputRespose.replace('Characteristic Value', 'CharacteristicValue');
        outputRespose = outputRespose.replace('Characteristic Name', 'CharacteristicName');
        return outputRespose;
    }
    
    //Method to format the response
    public static List<CalculationResult> formatResponse(MCONLINE_GetMobileDevPriceMatrix_V2 hwWrapperObj,Map<string, string> agreementMap,Map<String,String> agreementLinesCodeList,Map<string,Map<String,String>> prodSapIdMap,string commitmentDuration){
        
        List<cls_calculationResults>  calResult = new List<cls_calculationResults>();
        calResult = hwWrapperObj.output[0].calculationResults;
        List<CalculationResult> resultNewList = new List<CalculationResult>();
        for(cls_calculationResults calculationResultObj : calResult){
            CalculationResult calculationResultNewObj = new CalculationResult();
            calculationResultNewObj.subscriptionProductCode = calculationResultObj.SubscriptionProductCode;
            calculationResultNewObj.subscriptionMRC = calculationResultObj.subscriptionMRC;
            calculationResultNewObj.increasedMRC = calculationResultObj.MRC;
            calculationResultNewObj.increasedNRC = calculationResultObj.NRC;
            calculationResultNewObj.mobileDeviceProductCode = calculationResultObj.SourceProductCode;
            calculationResultNewObj.mobileDeviceSAPId = calculationResultObj.CharacteristicValue;
            String price = ((Map<String,String>) prodSapIdMap.get(calculationResultNewObj.mobileDeviceProductCode)).get('listPrice');
            calculationResultNewObj.mobileDeviceNRC = price;
            // upfront amount is calculated and assigned
            // Calculation is based on matrix = Matrix MRC* commitment duration + matrix NRC
            Decimal upFront = (Double)integer.valueof(commitmentDuration)*(Decimal.valueOf(calculationResultObj.MRC))+Decimal.valueOf(calculationResultObj.NRC);
            calculationResultNewObj.upfrontPaymentNRC = String.valueOf(upFront);   
            resultNewList.add(calculationResultNewObj);
        }
        return resultNewList;
    }
    
    
}