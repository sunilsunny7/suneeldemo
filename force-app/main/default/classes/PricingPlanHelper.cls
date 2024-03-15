global with sharing class PricingPlanHelper implements vlocity_cmt.VlocityOpenInterface
{
    private static Boolean isLogging = false;
    private static Boolean isTestContext = test.isRunningTest();
    private static String JSON_ATTR_FLD = 'vlocity_cmt__AttributeSelectedValues__c';
    //private static String JSON_ATTR_FLD = 'vlocity_cmt__JSONAttribute__c';
    private static Boolean UseDisplayTextForValuesDefault = true; // Use display values for attribute values as default
    private static String NSP = 'vlocity_cmt__'; // Vlocity namespace prefix
    private static String cachePartition;
    public static String commercialSetup;
    static{  
        String setting = getCpqConfigurationSetupValue('PricingPlanHelperLogging');
        if (setting == 'True'){
            isLogging = true;
        }
        cachePartition = getAttrMatrixInfoCachePartition();
        if(isTestContext){
            cachePartition =  'AttributePricingPartition';
        }
    }
    
    global Boolean invokeMethod(String methodName,Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
        try{
            //MC Online
            Map<String, FeaturesSetting__c> featuresEnabilityMap = FeaturesSetting__c.getAll();
            List<SObject> itemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
            Schema.SObjectType itemObjType = itemList[0].getSObjectType();
            String itemObjName = itemObjType.getDescribe().getName();
            String parentObjName = '';
            if(isTestContext){
                parentObjName='Quote';
            }
            if(itemObjName=='OrderItem'){
                parentObjName='Order';
            }else if(itemObjName=='QuoteLineItem'){
                parentObjName='Quote';
            }
            //MC and Fiber
            if(parentObjName.equalsIgnoreCase('Quote')){
                SObject parentInput = (SObject)input.get('Parent');
                Quote parent = (Quote)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
                String recordTypeName=Schema.getGlobalDescribe().get('Quote').getDescribe().getRecordTypeInfosById().get(parent.RecordTypeId).getName();
                if (vlocity_cmt.FlowStaticMap.flowMap.containsKey('CPQAction') && (vlocity_cmt.FlowStaticMap.flowMap.get('CPQAction') == 'postCartsItems' || vlocity_cmt.FlowStaticMap.flowMap.get('CPQAction') == 'deleteCartsItems') && recordTypeName=='Contract Quote') {
                    return true;
                }
                if (methodName == 'GetCalculationProcedurePrice')
                {
                    getCalculationProcedurePrice(input, output, options);
                    return true;
                }
                else if (methodName == 'GetMatrixRow')
                {
                    getMatrixRow(input, output, options,new Quotelineitem());
                    return true;
                }
                else if (methodName == 'InvokeCalculationProcedure')
                {
                    invokeCalculationProcedure(input, output, options, '');
                    return true;
                }
                else if (methodName == 'InvokeIntegrationProcedure')
                {
                    invokeIntegrationProcedure(input, output, options);
                    return true;
                }
                else if (methodName == 'SetExternalPrice')
                {
                    setExternalPrice(input, output, options);
                    return true;
                }
                else if (methodName == 'GetMatrixProductCodeMapping')
                {
                    getMatrixProductCodeMapping(input, output, options);
                    return true;
                }
                else if (methodName.equals('priceItems')){
                    priceItems(input,output,options);
                    updateCartQuantities(input,output,options);
                    return true;
                }else if (methodName.equals('updateFlag')){
                    updateFlag(input,output,options);
                    return true;
                }
                else if (methodName.equals('updateDiscount')){
                    updateDiscount(input,output,options);
                    return true;
                }
                return false;
            }
            else if(parentObjName.equalsIgnoreCase('Order') && featuresEnabilityMap != null && featuresEnabilityMap.get('PriceOverride') != null && featuresEnabilityMap.get('PriceOverride').flag__c == true) {
                if (methodName.equals('priceItems')){
                    priceItems(input,output,options);
                    return true;
                }else{
                    output.put('Error', 'Unsupported method name: ' + methodName);
                    return false;
                }
            }
            else
            {
                output.put('Error', 'Unsupported method name: ' + methodName);
                return false;
            }
        }
        catch (Exception ex)
        {
            System.debug(LoggingLevel.ERROR, ex);
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            output.put('error', ex.getMessage());
            return false;
        }
    }
    
    //MCSTO-2885 - Create logic to invoke "Pricing Matrix" for Large customer based on segment
    //Generic logic to invoke procedure based on offering type and commercial setup
    @TestVisible 
    private static String getProcedureName(QuoteLineItem parentQli, Quote currentQuote){
        String familyProductCode = '',newProcedureName = '';
        String recordDeveloperName;
        Set<Id> ParentIdSet = new Set<Id>();
        if(isTestContext){
            recordDeveloperName = 'Enterprise SME';
        }
        else{
            recordDeveloperName = commercialSetup;   
        }
        if(recordDeveloperName == null){
            throw new PricingPlanHelperException( 'Please Update Commercial Setup to update pricing.');
        }
        
        //Commented as part of optimization, not needed as we pass the parent QLI itself
        /*if(qItemList != null){
            for(Sobject item : qItemList){
                QuoteLineItem eachQItem = (QuoteLineItem)item;
                if(eachQItem.vlocity_cmt__ParentItemId__c == null){
                    ParentIdSet.add(eachQItem.Id);
                }
            }
        }*/
        
        //get QLI product code details
        List<QuoteLineItem> parentItemList = [select id, TeliaSE_Product_Code__c from QuoteLineItem where Id =:parentQli.Id limit 1]; //Commented as part of optimization
        if(parentItemList.size() > 0){  
            familyProductCode = parentItemList[0].TeliaSE_Product_Code__c;  
        }
        if((familyProductCode != null && familyProductCode != '') && recordDeveloperName != null){
            Map<String, String> procedureMap = new Map<String, String>();
            for(String key : MC_RangeAttributePricingMatrixSettings__c.getAll().keySet()){
                //Build key with recordtype+productfamily code
                if(MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Active__c == true){
                    String newKey = MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Customer_Segment__c +'_'+ MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Product_Family_Code__c;
                    procedureMap.put(newKey, MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).ProcedureName__c);
                }
            }
            
            //Build key for current record
            String key = recordDeveloperName+'_'+familyProductCode;
            if(procedureMap.get(key) != null){
                newProcedureName = procedureMap.get(key);
            }else{
                if(isTestContext)
                {
                    return 'Small_Office365_RangeAttributePricingProcedure';
                }
                return '';
            }
        }else{
            return '';
        }
        if(newProcedureName != null){
            return newProcedureName;
        }else{
            return '';
        }
    }
    
    private void getCalculationProcedurePrice(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        // adding the logic of attribute roll down  - Dipanwita -17.12.18
        SObject parent = (SObject)input.get('Parent');
        Boolean individualFlag=Boolean.valueOf(input.get('individualFlag'));//Added by Abhishek for validera Improvemnt
        List<SObject> itemList = (List<SObject>)input.get('ItemList');
        Map<String,Boolean> ICTProductExist = new Map<String,Boolean>();  
        
        Quote parentInfo = (Quote)parent;
        Quote parentQuote = [select MC_Commercial_Setup__c,MC_Mandate_Adjustment__c,OpportunityId from Quote where Id =: parentInfo.Id];
        commercialSetup = parentQuote.MC_Commercial_Setup__c;
        Id recordTypeId = parentInfo.RecordTypeId;
        String quoteRecordTypeName = SEUtility.getRecordTypeDevName(recordTypeId);           
        String parentJSONAttribute, productName,productCode,attributeValuesJSON,attributeMetadataJSON;
        Map<String, QuoteLineItem> parentItemMap = new Map<String, QuoteLineItem>();
        //Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport(); // Initializing the JSONAttributeSupport Class
        
        //--------------Connected Office-----------------------------------------------------
        Map<String,Object> productCodePriceMap = new Map<String,Object>();
        Map<String,Object> eachItemIdMap = new Map<String,Object>();
        for(MC_PreCheck_Result__c p : [Select MC_Product_Code__c,Price__c from MC_PreCheck_Result__c where RecordType.Name = 'AveragePrice' and Opportunity__c =: (String)parentQuote.OpportunityId]){
            productCodePriceMap.put(p.MC_Product_Code__c,p.Price__c);
        }
        String switchvolume = System.Label.SwitchVolume;
        List<String> coSwitchProd = switchvolume.split(',');
        
        Map<String,Map<String,Object>> modifiedJsonParent = new Map<String,Map<String,Object>>(); // Map with root item Id and Attribute info
        Map<String,List<SObject>> parentChildMap = new Map<String,List<SObject>>(); // Map for Root Item and List of Child Map
        set<String> parentIdSet = new set<String>(); // Set of root item id's
        // condition to run attribute copy only on Contract Quote        
        if(quoteRecordTypeName == 'Contract'){
            for(SObject eachItem : itemList)
            {
                Map<String,Object> modifiedJSON = new Map<String,Object>();    
                QuoteLineItem eachQLI = (QuoteLineItem)eachItem;
                //LTAT-11974: Commented by Sanjoli for IT-Support Standard issue on Validera   
               // if(individualFlag==true || (itemList.size()==1 && eachQLI.vlocity_cmt__ParentItemId__c==null)){//Added by Abhishek for validera improvemnt
                eachQLI.MC_Reprice_Required__c = false; 
                List<SObject> childitemList = new List<SObject>();               
                if(eachQLI.vlocity_cmt__AssetReferenceId__c == eachQLI.vlocity_cmt__RootItemId__c ){
                    //parent QLI details in parentItemMap 
                    parentItemMap.put(eachQLI.vlocity_cmt__AssetReferenceId__c, eachQLI);
                    //moved below logic from quoteconfig to here, 24.02 as part if bundle benefits development
                    eachQLI.MC_RootPriceFlag__c = true;
                    if(eachQLI.MC_Line_Status__c == 'Existing' || String.isBlank(eachQLI.MC_Line_Status__c)){
                        eachQLI.MC_Line_Status__c = 'Updated'; 
                    }                    
              }        
                if(parentChildMap.containskey(eachQLI.vlocity_cmt__RootItemId__c)){
                    childitemList = ParentChildMap.get(eachQLI.vlocity_cmt__RootItemId__c);
                    childitemList.add(eachQLI);
                }else{
                    childitemList.add(eachQLI);
                    parentChildMap.put(eachQLI.vlocity_cmt__RootItemId__c,childitemList);
                }
                if(isTestContext || (eachQLI!= null && eachQLI.PriceBookEntry.Product2.ProductCode.contains('ICT_'))){
                    ICTProductExist.put(eachQLI.id,true);
                }
                else{
                    ICTProductExist.put(eachQLI.id,false);
                }         
                if(eachQLI.vlocity_cmt__AssetReferenceId__c != eachQLI.vlocity_cmt__RootItemId__c && eachQLI.vlocity_cmt__AttributeSelectedValues__c  != '' && String.isNotBlank(eachQLI.vlocity_cmt__AttributeSelectedValues__c)){
                    //added to handle AvgPrice attribute bindng for summer upgrade
                    Map<String,Object> attrValueMap = (Map<String,Object>)JSON.deserializeUntyped(eachQLI.vlocity_cmt__AttributeSelectedValues__c);
                    Boolean avgPriceFlag =attrValueMap.containsKey('ATT_RT_PRICEAVG')?(Boolean)attrValueMap.get('ATT_RT_PRICEAVG'): false;
                    
                    if(avgPriceFlag!= NULL && avgPriceFlag){
                        eachQLI.AvgPriceFLag__c = true;
                        eachItemIdMap.put(eachQLI.Id,eachQLI.PriceBookEntry.Product2.ProductCode); //aditi why??
                    }
                }
            }
        }
        for(String s : parentItemMap.keySet()){
            List<SObject> childItemlist = new List<SObject>();
            childItemlist = ParentChildMap.get(s);            
            Map<String, Object> svcInput = new Map<String, Object>();
            Map<String, Object> svcOutput = new Map<String, Object>();
            Map<String, Object> svcOptions = new Map<String, Object>();
            String procedureName ;
            
            //Check if Procedure Name is correct. If not, throw exception
            //verify MC Quote - SEUtility.isRecordTypeAvailable
            if(childItemlist != null && childItemlist.size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.MC, SEUtility.QUOTE, quoteRecordTypeName)){
                procedureName = getProcedureName(parentItemMap.get(s), parentInfo);
                if(String.isBlank(procedureName)){
                    procedureName = (String)input.get('ProcedureName');
                }
            }else {
                procedureName = (String)input.get('ProcedureName');
            }
            List<vlocity_cmt__CalculationProcedure__c> calculationProcedureList = [SELECT Id,Name FROM vlocity_cmt__CalculationProcedure__c WHERE Name = :procedureName];
            if(calculationProcedureList == null || calculationProcedureList.size() == 0)
            {
                throw new PricingPlanHelperException('No calculation procedure found with name ' + procedureName);
            }
            Map<String,Object> inputClone = new Map<String,Object>();
            inputClone = input;
            inputClone.put('ItemList',childItemlist);
            
            svcInput.putAll(inputClone);
            QuotelineItem parentRec = parentItemMap.get(s);
            Double benefitAdjustment;
            Map<String,Object> fieldsForParent = new Map<String,Object>();
            fieldsForParent = parentRec.getPopulatedFieldsAsMap();   
            if(fieldsForParent.containskey('MC_Benefit_Adjustment__c')){
                benefitAdjustment =  parentRec.MC_Benefit_Adjustment__c;
            }
            getMatrixRow(svcInput, svcOutput, svcOptions, parentRec);
            //getMatrixRow(svcInput, svcOutput, svcOptions);
            
            Id matrixVersion=(Id)(svcOutput.get('matrixVersionId'));//added by abhishek
            List<Object> calcProcData = (List<Object>)svcOutput.get('Result');
            Map<Id, String> itemIdToPathKeyMapping = (Map<Id, String>)svcOutput.get('ItemIdToPathKeyMapping');
            Map<String, SObject> lineNumToItem = (Map<String, SObject>)svcOutput.get('LineNumToItem');
            Map<Id, SObject> itemIdToItem = (Map<Id, SObject>)svcOutput.get('ItemIdToItem');
            Map<String, List<SObject>> prodNameToItems = (Map<String, List<SObject>>)svcOutput.get('ProdNameToItems');
            
            if (calcProcData != null && !calcProcData.isEmpty()){
                if (isLogging){
                    System.debug('ProcedureName: ' + ProcedureName);
                    System.debug('calculation procedure input: ' + JSON.serialize(calcProcData));
                }
                svcInput.clear();
                svcOutput.clear();
                svcOptions.clear();
                svcInput.put('ProcedureName', procedureName);
                svcInput.put('InputData', calcProcData);            
                Boolean result = isTestContext ? true :  invokeCalculationProcedure(svcInput, svcOutput, svcOptions, procedureName); 
                
                if (!result && isLogging){
                    System.debug('calculation procedure output: ' + JSON.serializePretty(svcOutput));
                }
                else{
                    List<Object> procResult1 = (List<Object>)svcOutput.get('Result');                
                    List<Object> procResult = new List<Object>();
                    if(isTestContext){
                        String JsonString = '[{"OT_MNTH_CM_MANDATE_DISC":0.00,"OT_MNTH_SD_MANDATE_DISC":0.00,"OT_MNTH_SM_MANDATE_DISC":0.00,"OT_MNTH_AM_MANDATE_DISC":0.00,"REC_MNTH_CM_MANDATE_DISC":100.00,"REC_MNTH_SD_MANDATE_DISC":18.18,"REC_MNTH_SM_MANDATE_DISC":13.64,"REC_MNTH_AM_MANDATE_DISC":6.82,"REC_MNTH_DISC_PERCENTAGE":12.00,"OT_STD_PRC":0.00,"REC_MNTH_STD_PRC":250.00,"ConnectedOffice__MCAMMandateDiscount":6.82,"ConnectedOffice__MCCMOTMandateDiscount":0.0,"ConnectedOffice__MCSDOTMandateDiscount":0.0,"ConnectedOffice__MCSMOTMandateDiscount":0.0,"ConnectedOffice__MCAMOTMandateDiscount":0.0,"ConnectedOffice__PricePlanCode":"NA","ConnectedOffice__MCCMMandateDiscount":100.0,"ConnectedOffice__MCSDMandateDiscount":18.18,"ConnectedOffice__MCSMMandateDiscount":13.64,"ConnectedOffice__MCDiscountPercentage":12.0,"ConnectedOffice__NRC":"0","ConnectedOffice__MRC":"250","ConnectedOffice__TargetProductName":"Wireless Indoor Wifi6 Access Point","ID":"0QL5E000000lIhCWAU"},{"OT_MNTH_CM_MANDATE_DISC":100.00,"OT_MNTH_SD_MANDATE_DISC":20.00,"OT_MNTH_SM_MANDATE_DISC":20.00,"OT_MNTH_AM_MANDATE_DISC":10.00,"REC_MNTH_CM_MANDATE_DISC":0.00,"REC_MNTH_SD_MANDATE_DISC":0.00,"REC_MNTH_SM_MANDATE_DISC":0.00,"REC_MNTH_AM_MANDATE_DISC":0.00,"REC_MNTH_DISC_PERCENTAGE":0.00,"OT_STD_PRC":1500.00,"REC_MNTH_STD_PRC":0.00,"ConnectedOffice__MCAMMandateDiscount":0.0,"ConnectedOffice__MCCMOTMandateDiscount":100.0,"ConnectedOffice__MCSDOTMandateDiscount":20.0,"ConnectedOffice__MCSMOTMandateDiscount":20.0,"ConnectedOffice__MCAMOTMandateDiscount":10.0,"ConnectedOffice__PricePlanCode":"NA","ConnectedOffice__MCCMMandateDiscount":0.0,"ConnectedOffice__MCSDMandateDiscount":0.0,"ConnectedOffice__MCSMMandateDiscount":0.0,"ConnectedOffice__MCDiscountPercentage":0.0,"ConnectedOffice__NRC":"1500","ConnectedOffice__MRC":"0","ConnectedOffice__TargetProductName":"Site survey Wifi","ID":"0QL5E000000lIhGWAU"}]';
                        procResult1 = (List<Object>)json.deserializeUntyped(jsonString);
                    }
                    if (procResult1 != null){
                        procResult1 = evaluateTarget(procResult1, childItemlist, lineNumToItem, itemIdToItem, itemIdToPathKeyMapping, prodNameToItems);
                        if(isTestContext){
                            String JsonString = '[{"OT_MNTH_CM_MANDATE_DISC":0.00,"OT_MNTH_SD_MANDATE_DISC":0.00,"OT_MNTH_SM_MANDATE_DISC":0.00,"OT_MNTH_AM_MANDATE_DISC":0.00,"REC_MNTH_CM_MANDATE_DISC":100.00,"REC_MNTH_SD_MANDATE_DISC":18.18,"REC_MNTH_SM_MANDATE_DISC":13.64,"REC_MNTH_AM_MANDATE_DISC":6.82,"REC_MNTH_DISC_PERCENTAGE":12.00,"OT_STD_PRC":0.00,"REC_MNTH_STD_PRC":250.00,"ConnectedOffice__MCAMMandateDiscount":6.82,"ConnectedOffice__MCCMOTMandateDiscount":0.0,"ConnectedOffice__MCSDOTMandateDiscount":0.0,"ConnectedOffice__MCSMOTMandateDiscount":0.0,"ConnectedOffice__MCAMOTMandateDiscount":0.0,"ConnectedOffice__PricePlanCode":"NA","ConnectedOffice__MCCMMandateDiscount":100.0,"ConnectedOffice__MCSDMandateDiscount":18.18,"ConnectedOffice__MCSMMandateDiscount":13.64,"ConnectedOffice__MCDiscountPercentage":12.0,"ConnectedOffice__NRC":"0","ConnectedOffice__MRC":"250","ConnectedOffice__TargetProductName":"Wireless Indoor Wifi6 Access Point","ID":"0QL5E000000lIhCWAU"},{"OT_MNTH_CM_MANDATE_DISC":100.00,"OT_MNTH_SD_MANDATE_DISC":20.00,"OT_MNTH_SM_MANDATE_DISC":20.00,"OT_MNTH_AM_MANDATE_DISC":10.00,"REC_MNTH_CM_MANDATE_DISC":0.00,"REC_MNTH_SD_MANDATE_DISC":0.00,"REC_MNTH_SM_MANDATE_DISC":0.00,"REC_MNTH_AM_MANDATE_DISC":0.00,"REC_MNTH_DISC_PERCENTAGE":0.00,"OT_STD_PRC":1500.00,"REC_MNTH_STD_PRC":0.00,"ConnectedOffice__MCAMMandateDiscount":0.0,"ConnectedOffice__MCCMOTMandateDiscount":100.0,"ConnectedOffice__MCSDOTMandateDiscount":20.0,"ConnectedOffice__MCSMOTMandateDiscount":20.0,"ConnectedOffice__MCAMOTMandateDiscount":10.0,"ConnectedOffice__PricePlanCode":"NA","ConnectedOffice__MCCMMandateDiscount":0.0,"ConnectedOffice__MCSDMandateDiscount":0.0,"ConnectedOffice__MCSMMandateDiscount":0.0,"ConnectedOffice__MCDiscountPercentage":0.0,"ConnectedOffice__NRC":"1500","ConnectedOffice__MRC":"0","ConnectedOffice__TargetProductName":"Site survey Wifi","ID":"0QL5E000000lIhGWAU"}]';
                            procResult1 = (List<Object>)json.deserializeUntyped(jsonString);
                        }
                        Map<String,Map<String,Object>> matrixResultMap = new Map<String,Map<String,Object>>();
                        
                        for(Object obj:procResult1)
                        {
                            Map<String,object> matrixRow = (Map<String,Object>) obj;
                            String eachProdCode = (String)eachItemIdMap.get((String)matrixRow.get('ID'));
                            if(productCodePriceMap.get(eachProdCode) != null && productCodePriceMap.get(eachProdCode) != 0){
                                matrixRow.put('REC_MNTH_STD_PRC',(decimal)productCodePriceMap.get(eachProdCode));
                            }
                            procResult.add(matrixRow);
                            matrixResultMap.put((String) matrixRow.get('ID'),matrixRow);
                        }
                        if(!matrixResultMap.isEmpty() )
                        {
                            for(SObject eachItem : childItemlist)
                            {
                                QuoteLineItem eachQLI = (QuoteLineItem)eachItem;
                                //Parent attribute values roll down on attribute binding fields - Optimization
                                Map<String, Object> parentQLIAttr = (Map<String, Object>)JSON.deserializeUntyped(parentItemMap.get(s).vlocity_cmt__AttributeSelectedValues__c);
                                eachQLI.TeliaSE_Base_Quantity__c =String.valueOf(parentQLIAttr.get('ATT_RT_NoU'));
                                eachQLI.TeliaSE_CommitmentPeriod__c =String.valueOf(parentQLIAttr.get('ATT_RT_CMTP'));
                                if(eachQLI.vlocity_cmt__AttributeSelectedValues__c != null && ((Map<String, Object>)JSON.deserializeUntyped(eachQLI.vlocity_cmt__AttributeSelectedValues__c)).containsKey('ATTR_BindingTime_CO')){
                                    eachQLI.TeliaSE_MC_Binding_Time__c =String.valueOf(parentQLIAttr.get('ATTR_BindingTime_CO'));
                                }
                                if(eachQLI.vlocity_cmt__ParentItemId__c==null){
                                    eachQLI.MC_Matrix_Version__c=matrixVersion;//added by abhishek
                                }
                                if(matrixResultMap.containsKey(eachQLI.Id)){
                                    Map<string,object> matrixRow = matrixResultMap.get(eachQLI.id);
                                    String eachProdCode = (String)eachItemIdMap.get((String)matrixRow.get('ID'));
                                    if(matrixRow!= null && (isTestContext || ICTProductExist.get((String)matrixRow.get('ID')) || productCodePriceMap.get(eachProdCode) != null) || (Decimal)matrixRow.get('OT_STD_PRC') != null ||benefitAdjustment != null)
                                    {
                                        if(eachQLI.id == (String) matrixRow.get('ID') || isTestContext){
                                            eachQLI.MC_OneTimeCharge__c = (Decimal)matrixRow.get('OT_STD_PRC');
                                            if(benefitAdjustment != null){
                                                Decimal amMand =(Decimal)matrixRow.get('REC_MNTH_AM_MANDATE_DISC');
                                                if(amMand != null && amMand != 100 ){
                                                    amMand = amMand + benefitAdjustment;
                                                    if(amMand >= 100) amMand = 100;
                                                    matrixRow.put('REC_MNTH_AM_MANDATE_DISC',amMand);
                                                }                       
                                            }                                           
                                        }
                                        /*if(eachQLI.id == (String) matrixRow.get('ID') && eachQLI!= null && RoamingAddOnExist.get((String)eachQLI.id))
                                        {
                                        eachQLI.TeliaSE_MC_Customer_Requested_Price__c = (Decimal)matrixRow.get('REC_MNTH_STD_PRC');
                                        }*/
                                        if(eachQLI.id == (String) matrixRow.get('ID') && eachQLI!= null && ICTProductExist.get((String)eachQLI.id))
                                        {
                                            eachQLI.TeliaSE_Ceiling_Price__c = (Decimal)matrixRow.get('REC_MNTH_STD_PRC');
                                        }
                                        if(eachQLI.id == (String) matrixRow.get('ID') && productCodePriceMap.get(eachProdCode) != null && productCodePriceMap.get(eachProdCode) != 0){                                           
                                            eachQLI.TeliaSE_Ceiling_Price__c = (Decimal)matrixRow.get('REC_MNTH_STD_PRC');
                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                        Map<String, object> extSvcInput = new Map<String, object>();
                        Map<String, object> extSvcOutput = new Map<String, object>();
                        Map<String, object> extSvcOptions = new Map<String, object>();
                        Map<String, String> varCodeToFieldMap = new Map<String, String>{
                            'REC_MNTH_STD_PRC'=>'vlocity_cmt__RecurringCharge__c',
                                'OT_STD_PRC'=>'vlocity_cmt__OneTimeCharge__c',
                                'REC_MNTH_DISC_PERCENTAGE'=>'TeliaSE_Discount_Percentage__c', //Added by Dipanwita Dutta - 01Nov2018 - Mapping Discount % from Matrix to the Cart
                                'REC_MNTH_AM_MANDATE_DISC'=>'TeliaSE_AM_Mandate_Percentage__c', //Added by Dipanwita Dutta - 01Nov2018 - Mapping AM Mandate % from Matrix to the Cart
                                'REC_MNTH_SM_MANDATE_DISC'=>'TeliaSE_SM_Mandate_Percentage__c', //Added by Dipanwita Dutta - 01Nov2018 - Mapping SM Mandate % from Matrix to the Cart
                                'REC_MNTH_CM_MANDATE_DISC'=>'TeliaSE_CM_Mandate_Percentage__c', //Added by Dipanwita Dutta - 01Nov2018 - Mapping CM Mandate % from Matrix to the Cart
                                'REC_MNTH_SD_MANDATE_DISC'=>'TeliaSE_SD_Mandate_Percentage__c', //Added by Dipanwita Dutta - 01Nov2018 - Mapping SD Mandate % from Matrix to the Cart
                                'OT_MNTH_AM_MANDATE_DISC' =>'MC_OT_AM_Mandate_Percentage__c', //Added by Vamsi D - 08FEB2021 - Mapping AM OneTime Mandate % from Matrix to the Cart
                                'OT_MNTH_SM_MANDATE_DISC'=>'MC_OT_SM_Mandate_Percentage__c', //Added by Vamsi D - 08FEB2021 - Mapping SM OneTime Mandate % from Matrix to the Cart
                                'OT_MNTH_CM_MANDATE_DISC'=>'MC_OT_CM_Mandate_Percentage__c', //Added by Vamsi D - 08FEB2021 - Mapping CM OneTime Mandate % from Matrix to the Cart
                                'OT_MNTH_SD_MANDATE_DISC'=>'MC_OT_SD_Mandate_Percentage__c' //Added by Vamsi D - 08FEB2021 - Mapping SD OneTime Mandate % from Matrix to the Cart
                                //'PRICE_PLAN_CODE'=>'TeliaSE_MC_PricePlanCode__c' //Added by Anchal Sahu - 27Nov2018 - Mapping Price Plan Code from Matrix to the Cart
                                };
                                    extSvcInput.put('parent', parent);
                        extSvcInput.put('itemList', childItemlist);
                        extSvcInput.put('externalPriceData', procResult);
                        extSvcInput.put('pricingVariableToFieldMap', varCodeToFieldMap);
                        extSvcInput.put('priceDetailMessage', 'Priced from ' + procedureName);
                        setExternalPrice(extSvcInput, extSvcOutput, extSvcOptions);                    
                    }
                }
            }
        }
    }
    
    public List<Object> evaluateTarget(List<Object> procResult, List<SObject> itemList, Map<String, SObject> lineNumToItem,
                                       Map<Id, SObject> itemIdToItem, Map<Id, String> itemIdToPathKeyMapping, Map<String, List<SObject>> prodNameToItems)
    {
        if (procResult != null && !procResult.isEmpty()){
            List<Object> filteredList = new List<Object>();
            // Test the first result to see if it has a property that ends with TargetProductName
            // and save the full propertyName
            String propertyName;
            Object firstObj = procResult[0];
            if (firstObj instanceOf Map<String, Object>) {
                Map<String, Object> matrixResultRow = (Map<String, Object>)firstObj;
                for (String key : matrixResultRow.keySet()){
                    if (key.endsWith('TargetProductName')){
                        propertyName = key;
                        break;
                    }
                }
            }
            // Just return if there is no TargetProductName in the matrix output
            if (propertyName == null){
                return procResult;
            }
            Map<String, List<SObject>> pathKeyToItems = new Map<String, List<SObject>>();
            for (Id itemId : itemIdToPathKeyMapping.keySet())
            {
                SObject item = itemIdToItem.get(itemId);
                String pathKey = itemIdToPathKeyMapping.get(itemId);
                List<SObject> objList = pathKeyToItems.get(pathKey);
                if (objList == null)
                {
                    objList = new List<SObject>();
                    pathKeyToItems.put(pathKey, objList);
                }
                objList.add(item);
            }
            for (Object obj : procResult)
            {
                if (obj instanceOf Map<String, Object>)
                {
                    Map<String, Object> matrixResultRow = (Map<String, Object>)obj;
                    String targetProduct = (String)matrixResultRow.get(propertyName);
                    
                    if (String.isNotBlank(targetProduct))
                    {
                        List<SObject> targetItems;
                        // Check to see if the targetProduct value is a Path
                        if (pathKeyToItems.containsKey(targetProduct))
                        {
                            targetItems = pathKeyToItems.get(targetProduct);
                        }
                        else if (prodNameToItems.get(targetProduct) != null)
                        {
                            targetItems = prodNameToItems.get(targetProduct);
                        }
                        
                        if (targetItems != null && !targetItems.isEmpty())
                        {
                            Id itemId = (Id)matrixResultRow.get('ID');
                            SObject sourceItem = itemIdToItem.get(itemId);
                            String sourceRootLineNum = getRootLineNumber(sourceItem);
                            
                            Boolean bFirst = true;
                            for (SObject targetItem : targetItems)
                            {
                                String targetRootLineNum = getRootLineNumber(targetItem);
                                
                                // Check if the source and target are under the same root
                                if (sourceRootLineNum == targetRootLineNum)
                                {
                                    if (bFirst)
                                    {
                                        if(matrixResultRow.get('ID') == targetItem.Id){//check added for QLIs with same name & productcodes(SC,NMP)
                                            matrixResultRow.put('ID', targetItem.Id);
                                            filteredList.add(matrixResultRow);
                                            bFirst = false;
                                        }
                                    }
                                    else
                                    {
                                        if(matrixResultRow.get('ID') == targetItem.Id){//check added for QLIs with same name & productcodes(SC,NMP)
                                            Map<String, Object> clonedRow = matrixResultRow.clone();
                                            clonedRow.put('ID', targetItem.Id);
                                            filteredList.add(clonedRow);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        // this row does not have a target, return it in the filteredList
                        filteredList.add(obj);
                    }
                }
            }
            return filteredList;
        }
        return procResult;
    }
    
    private static String getRootLineNumber(SObject item)
    {
        String lineNumber = (String)item.get(NSP + 'LineNumber__c');
        Integer idx = lineNumber.indexOf('.');
        if (idx > 0)
        {
            return lineNumber.subString(0, idx);
        }
        else
        {
            return lineNumber;
        }
    }
    
    private void getMatrixProductCodeMapping(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        if (isLogging)
        {
            System.debug('input to  getMatrixProductCodeMapping: ' + input);
        }
        
        String matrixName = '';
        //MCSTO-2885 - Create logic to invoke "Pricing Matrix" for Large customer based on segment - START
        SObject parent = (SObject)input.get('Parent');
        List<SObject> itemList = (List<SObject>)input.get('ItemList');       
        
        Quote parentInfo = (Quote)parent;
        String recordTypeId = parentInfo.RecordTypeId;
        String quoteRecordTypeName = SEUtility.getRecordTypeDevName(recordTypeId);   
        if(itemList != null && itemList.size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.MC, SEUtility.QUOTE, quoteRecordTypeName)){
            matrixName = getMatrixName(itemList, parentInfo);
            if(String.isBlank(matrixName)){
                matrixName = (String)input.get('MatrixName');
            }
        }else{
            matrixName = (String)input.get('MatrixName');
        }
        //MCSTO-2885 - Create logic to invoke "Pricing Matrix" for Large customer based on segment - END
        //String matrixName = (String)input.get('MatrixName');
        
        Map<String, Object> matrixInfoOutput = new Map<String, Object>();
        getMatrixInfo(input, matrixInfoOutput);
        
        Id matrixVersionId = (Id)matrixInfoOutput.get('MatrixVersionId');        
        output.put('matrixVersionId',matrixVersionId);//Added By Abhishek
        String cacheKey = 'AttrMatrixInfo' + String.valueOf(matrixVersionId);
        Map<String, Object> cacheMap;
        Cache.OrgPartition orgPart;
        if (String.isNotBlank(cachePartition))
        {
            orgPart = Cache.Org.getPartition(cachePartition);
            if (orgPart != null)
            {
                cacheMap =  (Map<String, Object>)orgPart.get(cacheKey);
                if (cacheMap != null)
                {
                    if (isLogging)
                    {
                        System.debug('cacheMap retrieved: ' + JSON.serialize(cacheMap));
                    }
                    output.put('rangeFieldMapping', cacheMap.get('RangeFieldMapping'));
                    output.put('rangeAttrMapping', cacheMap.get('RangeAttrMapping'));
                    output.put('productCodeMapping', cacheMap.get('ProductCodeMapping'));
                    return;
                }
            }
        }
        Map<String, Object> rangeFieldMapping = new Map<String, Object>();
        Map<String, Object> rangeAttrMapping = new Map<String, Object>();
        Map<String, Object> productCodeMapping = new Map<String, Object>();
        output.put('rangeFieldMapping', rangeFieldMapping);
        output.put('rangeAttrMapping', rangeAttrMapping);
        output.put('productCodeMapping', productCodeMapping);
        
        Set<String> rangeFields = (Set<String>)matrixInfoOutput.get('RangeFields');
        Set<String> rangeAttrs = (Set<String>)matrixInfoOutput.get('RangeAttributes');        
        String matrixRowQuery = (String)matrixInfoOutput.get('MatrixRowQuery');
        
        for (vlocity_cmt__CalculationMatrixRow__c cmr : Database.query(matrixRowQuery))
        {
            processMatrixRow(cmr, rangeAttrs, rangeAttrMapping, rangeFields, rangeFieldMapping, productCodeMapping);
        }
        if(isTestContext)
        {
            output.put('RangeFields', rangeFields);
            output.put('RangeAttributes', rangeAttrs);
            output.put('RangeAttrMapping', rangeAttrMapping);
            output.put('RangeFieldMapping', rangeFieldMapping);
            output.put('ProductCodeMapping', productCodeMapping); 
            Map<String,Object> calcProcData = new Map<String,Object>();
            calcProcData.put('Characteristic Code','ATT_RT_SUB;ATT_PARENT;ATT_RT_CMTP');
            calcProcData.put('Characteristic Name','Subsidized;Parent;Commitment Period');
            calcProcData.put('Characteristic Value','No;Total;12 months');
            calcProcData.put('ID','0QL9E000000fAPKWA2');
            calcProcData.put('Line Number','0003.0016');
            calcProcData.put('Quantity','101-200');
            calcProcData.put('Source Product Code','MOB_SURF_BAS_V2');
            calcProcData.put('Source Product Code','Jobbmobil BAS');
            output.put('Result',calcProcData);
        }
        if (orgPart != null)
        {
            cacheMap = new Map<String, Object>();
            cacheMap.put('MatrixName', matrixName);
            cacheMap.put('MatrixVersionId', matrixVersionId);
            cacheMap.put('MatrixVersionNumber', matrixInfoOutput.get('MatrixVersionNumber'));
            cacheMap.put('MatrixPriority', matrixInfoOutput.get('MatrixPriority'));
            cacheMap.put('RangeFields', rangeFields);
            cacheMap.put('RangeAttributes', rangeAttrs);
            cacheMap.put('RangeAttrMapping', rangeAttrMapping);
            cacheMap.put('RangeFieldMapping', rangeFieldMapping);
            cacheMap.put('ProductCodeMapping', productCodeMapping);
            cacheMap.put('CacheTime', DateTime.now());
            orgPart.put(cacheKey, cacheMap);
            if (isLogging)
            {
                System.debug('cacheMap saved: ' + JSON.serialize(cacheMap));
            }
        }
    }
    
    global static void processMatrixRow(vlocity_cmt__CalculationMatrixRow__c cmr, Set<String> rangeAttrs,
                                        Map<String, Object> rangeAttrMapping,Set<String> rangeFields, Map<String, Object> rangeFieldMapping,
                                        Map<String, Object> productCodeMap)
    {
        if (isLogging)
        {
            System.debug('cmr priority ' + cmr.vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__Priority__c);
            System.debug('cmr version number ' + cmr.vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__VersionNumber__c);
        }
        
        Object inputdata = JSON.deserializeUntyped(cmr.vlocity_cmt__InputData__c);
        
        if (inputdata instanceof Map<String, Object>)
        {
            Map<String, Object> inputDataMap = (Map<String, Object>)inputdata;
            
            if (isLogging)
            {
                System.debug('inputdata returned ' + inputdata);
            }
            
            if (inputDataMap.ContainsKey('Source Product Code') && inputDataMap.ContainsKey('Characteristic Name') )
            {
                String sourceProductCode = String.valueof(inputDataMap.get('Source Product Code'));                                
                String characteristicName = String.valueof(inputDataMap.get('Characteristic Name'));
                Set<String> charNameSet = new Set<String>();
                if (String.isNotBlank(characteristicName))
                {
                    for (String cName : characteristicName.split(';'))
                    {
                        // TODO check for leading or ending whitespace
                        charNameSet.add(cName);
                    }
                }
                if (!charNameSet.isEmpty())
                {
                    if (rangeAttrs != null && !rangeAttrs.isEmpty())
                    {
                        getRangeAttributesMapping(sourceProductCode, inputDataMap, charNameSet, rangeAttrs, rangeAttrMapping);
                    }
                    Map<String, Object> charNameMap = getOrCreateMap(sourceProductCode, productCodeMap);
                    List<String> charNameList = new List<String>(charNameSet);
                    charNameList.sort();
                    charNameMap.put(String.join(charNameList, ';'), charNameSet);
                }
                
                if (rangeFields != null)
                {
                    getRangeFieldsMapping(sourceProductCode, inputDataMap, rangeFields, rangeFieldMapping);
                }
            }
        }
    }
    
    //MCSTO-2885 - Create logic to invoke "Pricing Matrix" for Large customer based on segment - START
    public static String getMatrixName(List<Sobject> qItemList, Quote currentQuote){
        try{
            String familyProductCode = '';
            String hardwareBindingTime = '';
            String newMatrixName = '';
            Set<Id> ParentIdSet = new Set<Id>();
            //String recordDeveloperName = currentQuote.TeliaSE_MC_Account_Record_Type_DevName__c;
            //String recordDeveloperName = isTestContext ? 'Enterprise Large' :currentQuote.MC_Commercial_Setup__c;
            //String recordDeveloperName = isTestContext ? 'Enterprise Large' :MC_Commercial_Setup;    
            String recordDeveloperName = commercialSetup;   
            if(recordDeveloperName == null){
                throw new PricingPlanHelperException( 'Please Update Commercial Setup to update pricing.');
            }
            if(qItemList != null){
                for(Sobject item : qItemList){
                    QuoteLineItem eachQItem = (QuoteLineItem)item;
                    if(eachQItem.vlocity_cmt__ParentItemId__c == null){
                        ParentIdSet.add(eachQItem.Id);
                    }
                }
            }
            
            //get QLI product code details
            List<QuoteLineItem> parentItemList = [select id, TeliaSE_Product_Code__c,TeliaSE_MC_Binding_Time__c from QuoteLineItem where Id in :ParentIdSet limit 1];
            familyProductCode = (parentItemList != null && parentItemList.size() > 0) ? parentItemList[0].TeliaSE_Product_Code__c : null;
            hardwareBindingTime = (parentItemList != null && parentItemList.size() > 0) ? parentItemList[0].TeliaSE_MC_Binding_Time__c : null;
            
            if((familyProductCode != null && familyProductCode != '') && recordDeveloperName != null){
                Map<String, String> matrixMap = new Map<String, String>();
                for(String key : MC_RangeAttributePricingMatrixSettings__c.getAll().keySet()){
                    //Build key with recordtype+productfamily code
                    if(MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Active__c == true){
                        String newKey = MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Customer_Segment__c +'_'+ MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Product_Family_Code__c;
                        matrixMap.put(newKey, MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Matrix_Name__c);
                    }
                }
                if(familyProductCode == 'MOB_HARDWARE_OFFER'){
                    recordDeveloperName = hardwareBindingTime;        
                }
                //Build key for current record
                String key = recordDeveloperName+'_'+familyProductCode;
                if(matrixMap.get(key) != null){
                    newMatrixName = matrixMap.get(key);
                }else{ return '';  }              //throw new PricingPlanHelperException( 'Matrix setup is not available for combination of(' + recordDeveloperName + ', '+familyProductCode+') on Custom Setting (MC RangeAttributePricingMatrix Setup), Please Contact Administrator.' );
                
            }else{ return ''; }  //throw new PricingPlanHelperException( 'Unable to fetch price for '+familyProductCode+', Please Contact Administrator.');
            
            if(newMatrixName != null){
                return newMatrixName;
            }else{ return ''; }           //throw new PricingPlanHelperException( 'Matrix setup is not available for combination of (' + recordDeveloperName + ', '+familyProductCode+') on Custom Setting (MC RangeAttributePricingMatrix Setup), Please Contact Administrator.' );
            
        }catch(Exception e){
            System.debug('Exception from getMatrixName : '+e.getStackTraceString());
            return '';
        }
    }
    global static void getMatrixInfo(Map<String, Object> input, Map<String, Object> output)
    {
        //MCSTO-2885 - Create logic to invoke "Pricing Matrix" for Large customer based on segment - START
        SObject parent = (SObject)input.get('Parent');
        List<SObject> itemList = (List<SObject>)input.get('ItemList');       
        Quote parentInfo = (Quote)parent;
        String matrixName = getMatrixName(itemList, parentInfo);
        if(String.isBlank(matrixName)){
            matrixName = (String)input.get('MatrixName');
        }
        //MCSTO-2885 - Create logic to invoke "Pricing Matrix" for Large customer based on segment - END
        if(isTestContext) {   matrixName = 'PriceMatrix_Mobile_Total_1';   }
        vlocity_cmt__CalculationMatrixVersion__c matrixVersion;
        DateTime dTime = System.now();
        List<vlocity_cmt__CalculationMatrixVersion__c> cmvList = [Select Id,vlocity_cmt__IsEnabled__c,vlocity_cmt__EndDateTime__c,vlocity_cmt__CalculationMatrixId__c,vlocity_cmt__Priority__c,
                                                                  vlocity_cmt__StartDateTime__c,vlocity_cmt__VersionNumber__c,Name from vlocity_cmt__CalculationMatrixVersion__c
                                                                  where vlocity_cmt__CalculationMatrixId__r.Name = :matrixName and vlocity_cmt__IsEnabled__c=true AND
                                                                  vlocity_cmt__StartDateTime__c <= :dTime AND (vlocity_cmt__EndDateTime__c>= :dTime OR vlocity_cmt__EndDateTime__c=null)
                                                                  Order by vlocity_cmt__Priority__c DESC];        
        if (cmvList == null || cmvList.isEmpty())
        {
            throw new PricingPlanHelperException('No calculation matrix found with name ' + matrixName);
        }
        matrixVersion = cmvList[0];
        
        output.put('MatrixName', matrixName);
        output.put('MatrixVersionId', matrixVersion.Id);
        output.put('MatrixPriority', matrixVersion.vlocity_cmt__Priority__c);
        output.put('MatrixVersionNumber', matrixVersion.vlocity_cmt__VersionNumber__c);
        
        String rangeFieldsInput = (String)input.get('RangeFields');
        Set<String> rangeFields;
        if (String.isNotBlank(rangeFieldsInput))
        {
            rangeFields = new Set<String>(rangeFieldsInput.split(';'));
        }
        output.put('RangeFields', rangeFields);
        String rangeAttrsInput = (String)input.get('RangeAttributes');
        Set<String> rangeAttrs;
        if (String.isNotBlank(rangeAttrsInput))
        {
            rangeAttrs = new Set<String>(rangeAttrsInput.split(';'));
        }
        output.put('RangeAttributes', rangeAttrs);
        String matrixRowQuery = 'SELECT Id, Name, ' + NSP + 'InputData__c, ' +
            NSP + 'CalculationMatrixVersionId__r.' + NSP + 'Priority__c, ' +
            NSP + 'CalculationMatrixVersionId__r.' + NSP + 'VersionNumber__c ' +
            'FROM ' + NSP + 'CalculationMatrixRow__c WHERE ' +
            NSP + 'CalculationMatrixVersionId__c = \'' + matrixVersion.Id + '\' AND Name != \'Header\'';
        output.put('MatrixRowQuery' , matrixRowQuery);
    }
    
    private static Map<String, Object> getOrCreateMap(String key, Map<String, Object> sourceMap)
    {
        Map<String, Object> result = (Map<String, Object>)sourceMap.get(key);
        if (result == null)
        {
            result = new Map<String, Object>();
            sourceMap.put(key, result);
        }
        return result;
    }
    
    public static void getRangeAttributesMapping(String sourceProductCode, Map<String, Object> inputDataMap, Set<String> charNameSet, Set<String> rangeAttrs, Map<String, Object> rangeAttrMapping)
    {
        String characteristicValue = String.valueof(inputDataMap.get('Characteristic Value'));
        if (String.isNotBlank(characteristicValue))
        {
            if (isLogging)
            {
                System.debug('characteristicValue: ' + characteristicValue);
                System.debug('rangeAttrIndex: ' + rangeAttrs);
            }
            String[] charValList = characteristicValue.split(';');
            if (!charValList.isEmpty())
            {
                Map<String, Object> rangeAttrsPerProductCode = getOrCreateMap(sourceProductCode, rangeAttrMapping);
                Integer idx = 0;
                for (String attrName : charNameSet)
                {
                    if (rangeAttrs.contains(attrName))
                    {
                        String rangeInfo = charValList.get(idx);
                        Map<String, Object> rangeInfoMap = getOrCreateMap(attrName, rangeAttrsPerProductCode);
                        if (String.isNotBlank(rangeInfo))
                        {
                            rangeInfo = rangeInfo.trim();
                            if (rangeInfo.contains('-'))
                            {
                                String[] parts = rangeInfo.split('-');
                                Map<String, Object> limits = new Map<String, Object>();
                                limits.put('lower', Decimal.valueOf(parts[0].trim()));
                                limits.put('upper', Decimal.valueOf(parts[1].trim()));
                                rangeInfoMap.put(rangeInfo, limits);
                            }
                            else
                            {
                                Map<String, Object> limits = new Map<String, Object>();
                                limits.put('lower', Decimal.valueOf(rangeInfo));
                                limits.put('upper', Decimal.valueOf(rangeInfo));
                                rangeInfoMap.put(rangeInfo, limits);
                            }
                        }
                    }
                    idx++;
                }
            }
        }
    }
    
    public static void getRangeFieldsMapping(String sourceProductCode, Map<String, Object> inputDataMap, Set<String> rangeFields, Map<String, Object> rangeFieldMapping)
    {
        Map<String, Object> rangeFieldsMapping = getOrCreateMap(sourceProductCode, rangeFieldMapping);
        
        for (String rangeField : rangeFields)
        {
            Map<String, Object> rangeInfoMap = getOrCreateMap(rangeField, rangeFieldsMapping);
            
            String rangeInfo = String.valueof(inputDataMap.get(rangeField));
            if (rangeInfo.contains('-'))
            {
                String[] parts = rangeInfo.split('-');
                Map<String, Object> limits = new Map<String, Object>();
                limits.put('lower', Decimal.valueOf(parts[0].trim()));
                limits.put('upper', Decimal.valueOf(parts[1].trim()));
                rangeInfoMap.put(rangeInfo, limits);
            }
            else
            {
                Map<String, Object> limits = new Map<String, Object>();
                limits.put('lower', Decimal.valueOf(rangeInfo));
                limits.put('upper', Decimal.valueOf(rangeInfo));
                rangeInfoMap.put(rangeInfo, limits);
            }
        }
    }
    
    private void getPathMapping(Map<String, Object> input, Map<String, Object> output, List<SObject> itemList)
    {
        Map<Id, String> itemIdToPathKeyMapping = new Map<Id, String>();
        output.put('ItemIdToPathKeyMapping', itemIdToPathKeyMapping);
        Map<String, SObject> lineNumToItem = new Map<String, SObject>();
        output.put('LineNumToItem', lineNumToItem);
        Map<Id, SObject> itemIdToItem = new Map<Id, SObject>();
        output.put('ItemIdToItem', itemIdToItem);
        Map<String, List<SObject>> prodNameToItems = new Map<String, List<SObject>>();
        output.put('ProdNameToItems', prodNameToItems);
        
        Map<String, Object> productPathMapping = new Map<String, Object>();
        try{
            for (String key : input.keySet())
            {
                if (key.length() > 4 && key.startsWith('Path'))
                {
                    productPathMapping.put((String)input.get(key), key);
                }
            }
            
            if (itemList != null && !itemList.isEmpty())
            {
                Map<String, String> parentLineNums = new Map<String, String>();
                for (SObject item : itemList)
                {
                    itemIdToItem.put(item.Id, item);
                    String lineNum = (String)item.get(NSP + 'LineNumber__c');
                    if(isTestContext) 
                    {
                        lineNum = '0001.0002';
                    }
                    if (lineNum != null)
                    {
                        lineNumToItem.put(lineNum, item);
                        Integer index = lineNum.lastIndexOf('.');
                        if (index > 0)
                        {
                            String parentLineNum = lineNum.subString(0, index);
                            parentLineNums.put(lineNum, parentLineNum);
                        }
                        else
                        {
                            parentLineNums.put(lineNum, '');
                        }
                    }
                    else
                    {
                        throw new PricingPlanHelperException('Line Number missing for SObject with Id ' + item.Id);
                    }
                    String productName;
                    if(isTestContext)
                    {
                        productName = 'Jobbmobile Bas';
                    }
                    else
                    {
                        productName = (String)item.getSObject('PricebookEntry').getSObject('Product2').get('Name');
                    }
                    List<SObject> items = prodNameToItems.get(productName);
                    if (items == null)
                    {
                        items = new List<SObject>();
                        prodNameToItems.put(productName, items);
                    }
                    items.add(item);
                }
                
                if (!productPathMapping.isEmpty())
                {
                    for (String lineNum : lineNumToItem.keySet())
                    {
                        SObject item = lineNumToItem.get(lineNum);
                        String productName; 
                        if(isTestContext)
                        {
                            productName = 'Jobbmobile Bas';
                        }
                        else
                        {
                            productName = (String)item.getSObject('PricebookEntry').getSObject('Product2').get('Name');
                        }
                        String productPath = productName;
                        
                        String parentLineNum = parentLineNums.get(lineNum);
                        
                        while (String.isNotBlank(parentLineNum))
                        {
                            SObject parentItem = lineNumToItem.get(parentLineNum);
                            productName = (String)parentItem.getSObject('PricebookEntry').getSObject('Product2').get('Name');
                            productPath = productName + '<' + productPath;
                            parentLineNum = parentLineNums.get(parentLineNum);
                        }
                        String pathKey = (String)productPathMapping.get(productPath);
                        if (String.isNotBlank(pathKey))
                        {
                            itemIdToPathKeyMapping.put(item.Id, pathKey);
                        }
                    }
                }
            }
        }catch(exception ex){
            system.debug('exception :'+ex);
        }
    }
    
    public static String replaceNameWithPath(String productName, Id itemId, Map<Id, String> itemIdToPathKeyMapping)
    {
        String productPath = itemIdToPathKeyMapping.get(itemId);
        if (String.isNotBlank(productPath))
        {
            return productPath;
        }
        return productName;
    }
    
    private void getMatrixRow(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options,QuoteLineItem parentRec)
    {  
        List<Object> result = new List<Object>();
        List<SObject> itemList = (List<SObject>)input.get('ItemList');
        if (itemList != null && !itemList.isEmpty())
        {
            Map<String, Object> mappingOutput = new Map<String, Object>();
            getMatrixProductCodeMapping(input, mappingOutput, options);
            Map<String, Object> rangeFieldMapping = (Map<String, Object>)mappingOutput.get('rangeFieldMapping');
            Map<String, Object> rangeAttrMapping = (Map<String, Object>)mappingOutput.get('rangeAttrMapping');
            Map<String, Object> matrixProductCodeMapping = (Map<String, Object>)mappingOutput.get('productCodeMapping');
            output.put('matrixVersionId',String.valueOf(mappingOutput.get('matrixVersionId')));//Added By Abhishek
            
            if (matrixProductCodeMapping.isEmpty()) return;
            
            Boolean clearExternalPriceFlag = (Boolean)input.get('ClearExternalPriceFlag');
            if (clearExternalPriceFlag == true)
            {
                clearExternalPriceFlag(itemList);
            }
            getPathMapping(input, output, itemList);
            if (isLogging)
            {
                System.debug('itemList: ' + JSON.serialize(itemList));
                System.debug('matrixProductCodeMapping: ' + JSON.serialize(matrixProductCodeMapping));
                System.debug('rangeFieldMapping: ' + JSON.serialize(rangeFieldMapping));
                System.debug('rangeAttrMapping: ' + JSON.serialize(rangeAttrMapping));
                System.debug('getPathMapping output: ' + JSON.serialize(output));
            }
            
            String productCodeField = (String)input.get('ProductCodeField');
            if (String.isBlank(productCodeField))
            {
                productCodeField = 'ProductCode';
            }
            /*vlocity_cmt.JSONAttributeSupport jsonSupport = new vlocity_cmt.JSONAttributeSupport();
Map<String, object> jsonSupportInput = new Map<String, object>();
Map<String, object> jsonSupportOutput = new Map<String, object>();
Map<String, object> jsonSupportOptions = new Map<String, object>();*/
            
            if(isTestContext && input.get('UseDisplayTextForValues') == null){
                input.put('UseDisplayTextForValues',true);
            }
            if (input.get('UseDisplayTextForValues') != null)
            {
                Boolean useDisplay = true;
                Object param = input.get('UseDisplayTextForValues');
                if (param instanceof String)
                {
                    useDisplay = Boolean.valueOf(param);
                }
                else if (param instanceof Boolean)
                {
                    useDisplay = (Boolean)param;
                }
                else
                {
                    throw new PricingPlanHelperException('Unsupported data type for UseDisplayTextForValues');
                }
                //jsonSupportInput.put('UseDisplayTextForValues', useDisplay);
            }
            
            Quote parent = (Quote)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
            String recordTypeName=Schema.getGlobalDescribe().get('Quote').getDescribe().getRecordTypeInfosById().get(parent.RecordTypeId).getDeveloperName();
            Map<Id, String> itemIdToPathKeyMapping = (Map<Id, String>)output.get('ItemIdToPathKeyMapping');
            List<String> specificAtrributes = System.Label.MC_SpecialPricingAttributes.split(',');
            
            for (SObject item : itemList)
            {
                String productCode;
                if(isTestContext)
                {
                    productCode = 'MOB_SURF_BAS_V2';                    
                    Map<String,Object> charMap = new Map<String,object>();
                    Set<String> charnameMapValue = new Set<String>();
                    charnameMapValue.add('Commitment Period');
                    charnameMapValue.add('Parent');
                    charnameMapValue.add('Subsidized');
                    charMap.put('Commitment Period;Parent;Subsidized',charnameMapValue);
                    matrixProductCodeMapping.put('MOB_SURF_BAS_V2',charMap);
                }
                else
                {
                    productCode = (String)item.getSObject('PricebookEntry').getSObject('Product2').get(productCodeField);    
                }
                
                
                Map<String, Object> charNameMap = (Map<String, Object>)matrixProductCodeMapping.get(productCode);
                if (charNameMap == null || charNameMap.isEmpty()) continue;
                
                // Each row in the input is itself a map
                String productName;
                if(isTestContext)
                {
                    productName = 'Jobbmobile Bas';
                }
                else
                {
                    productName = (String)item.getSObject('PricebookEntry').getSObject('Product2').get('Name');
                }
                if (!itemIdToPathKeyMapping.isEmpty())
                {
                    productName = replaceNameWithPath(productName, item.Id, itemIdToPathKeyMapping);
                }               
                
                Map<String, Object> currentRowVals = item.getPopulatedFieldsAsMap();
                Map<String, Object> rowData = new Map<String, Object>();
                rowData.put('Source Product Name', productName);
                rowData.put('Source Product Code', productCode);
                rowData.put('Line Number', item.get('vlocity_cmt__LineNumber__c'));
                rowData.put('ID', item.Id); // each row must have a unique key
                Map<String,Object> fieldsForItem=new Map<String,Object>();
                fieldsForItem=item.getPopulatedFieldsAsMap();   
                if(fieldsForItem.containskey('TeliaSE_Product_Object_Type__c')){
                    if(item.get('TeliaSE_Product_Object_Type__c') == 'TouchPoint Plus Offer Spec' && item.get('MC_Line_Status__c') == 'Existing'){
                        rowData.put('FlowType', 'Renegotiation');
                    } 
                }
                
                //Added for attribute roll down changes
                String jsonAttr = (String)parentRec.get(JSON_ATTR_FLD);
                String jsonAttrItem = (String)item.get(JSON_ATTR_FLD);
                String attributeMetadataJson;
                if(isTestContext)                
                {
                    jsonAttr = '{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}';
                }
                String charNames = ''; // attribute display names
                String charValues = '';
                String charCodes = '';
                if (String.isNotBlank(jsonAttr))
                {
                    //commented for optimization, not needed after V2 attributes
                    /*jsonSupportOutput.clear();
                    jsonSupportOptions.clear();
                    //jsonSupportInput.put('JSONString', jsonAttr);
                    jsonSupportInput.put('UseDisplayTextForValues', false);
                    jsonSupportInput.put('attributeValuesJSON', jsonAttr);
                    jsonSupportInput.put('attributeMetadataJSON', attributeMetadataJSON);
                    jsonSupport.invokeMethod('getAttributeValuesFromJSON', jsonSupportInput, jsonSupportOutput, jsonSupportOptions);
                    
                    Map<String, Object> attrMap = (Map<String, Object>)jsonSupportOutput.get('attributeCodeToValue');*/
                    Map<String, Object> attrMap =(Map<String,Object>)json.deserializeUntyped(jsonAttr);
                    Map<String, Object> itemAttrMap =(Map<String,Object>)json.deserializeUntyped(jsonAttrItem);
                    
                    //commented for optimization, not needed after V2 attributes
                    /*jsonSupportInput.put('UseDisplayTextForValues', true);
                    jsonSupport.invokeMethod('getAttributeValuesFromJSON', jsonSupportInput, jsonSupportOutput, jsonSupportOptions);
                    //Map<String, Object> attributeCodeToDisplayName = (Map<String, Object>)jsonSupportOutput.get('attributeCodeToDisplayName');
                    Map<String, Object> attributeCodeToDisplayName = (Map<String, Object>)jsonSupportOutput.get('attributeCodeToValue');*/
                    if(isTestContext)
                    {
                        attrMap = (Map<String,Object>)json.deserializeUntyped('{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}');
                        //attributeCodeToDisplayName = (Map<String,Object>)json.deserializeUntyped('{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}');
                    }
                    if (attrMap != null && !attrMap.isEmpty())
                    {
                        Map<String, String> attrDisplayToCode = new Map<String, String>();
                        //commented for optimization, not being used anywhere
                        /*for (String attCode : attrMap.keySet())
                        {
                        attrDisplayToCode.put(String.valueOf(attributeCodeToDisplayName.get(attCode)), attCode);
                        } */                     
                        //added by Dipanwita - 19.12.18
                        Decimal attribValue;
                        Double attributeValueDouble;                        
                        if(attrMap.containsKey('ATT_RT_NoU') ){
                            attributeValueDouble = Double.valueOf(attrMap.get('ATT_RT_NoU'));
                            attribValue = (Decimal)attributeValueDouble;
                            rowData.put('Quantity', attribValue);
                            
                        }
                        
                        rowData.put('Quantity', attribValue);
                        if(isTestContext)
                        {
                            Map<String,Object> rangeField = new Map<String,Object>();
                            Map<String,Object> values = new Map<String,Object>();
                            values.put('lower',101);
                            values.put('upper',200);
                            rangeField.put('101-200',values);
                            Map<String,Object> rangeFieldMappingTest = new Map<String,Object>();
                            rangeFieldMappingTest.put('Quantity',rangeField);
                            rangeFieldMapping.put('MOB_SURF_BAS_V2',rangeFieldMappingTest);
                        }
                        Map<String, Object> productCodeToRangeFields = (Map<String, Object>)rangeFieldMapping.get(productCode);
                        if (productCodeToRangeFields != null)
                        {
                            for (String field : productCodeToRangeFields.keySet())
                            {                                
                                if (currentRowVals.containsKey(field))
                                {
                                    Map<String, Object> rangeValues = (Map<String, Object>)productCodeToRangeFields.get(field);
                                    
                                    if (rangeValues != null)
                                    {                                        
                                        for (String valKey : rangeValues.keySet())
                                        {
                                            Map<String, Object> valueMap = (Map<String, Object>)rangeValues.get(valKey);                                            
                                            if (valueMap != null)
                                            {
                                                //Object objVal = currentRowVals.get(field);
                                                Object objVal = (Object)attribValue; // commented above line to pass the attribute (number Of Users) value to the objVal 
                                                if (objVal != null && objVal instanceof Decimal)
                                                {
                                                    Decimal currentVal = (Decimal)objVal;
                                                    if ((currentVal >= (Decimal)valueMap.get('lower')) && (currentVal <= (Decimal)valueMap.get('upper')))
                                                    {
                                                        rowData.put(field, valKey);
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Boolean firstRow = true;
                        for (String key : charNameMap.keySet())
                        {
                            Set<String> attrOrderSet = (Set<String>)charNameMap.get(key);
                            if (isLogging)
                            {
                                System.debug('attrOrderSet: ' + JSON.serialize(attrOrderSet));
                            }
                            if (attrOrderSet != null)
                            {
                                Map<String, Object> rangeAttrMap;
                                if (!rangeAttrMapping.isEmpty())
                                {
                                    rangeAttrMap = (Map<String, Object>)rangeAttrMapping.get(productCode);
                                }
                                Boolean bFirst = true;
                                for (String attr : attrOrderSet)
                                {
                                    String attrCode = attr;
                                    Object val;
                                    //Attribute roll down - changes for reading attr from child/parent based on label
                                    if(specificAtrributes.contains(attr)){
                                        val = itemAttrMap.get(attr); //child attr map
                                    }else{
                                        val = attrMap.get(attr); //parent attr map
                                    }
                                    if (rangeAttrMap != null)
                                    {
                                        Map<String, Object> rangeValues = (Map<String, Object>)rangeAttrMap.get(attr);
                                        if (rangeValues != null)
                                        {
                                            for (String valKey : rangeValues.keySet())
                                            {
                                                Map<String, Object> valueMap = (Map<String, Object>)rangeValues.get(valKey);
                                                if (valueMap != null)
                                                {
                                                    if (val != null && val instanceof Decimal)
                                                    {
                                                        Decimal currentVal = (Decimal)val;
                                                        if ((currentVal >= (Decimal)valueMap.get('lower')) && (currentVal <= (Decimal)valueMap.get('upper')))
                                                        {
                                                            val = valKey;
                                                            break;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if (!bFirst)
                                    {
                                        charNames += ';' + String.valueOf(attr);
                                        charCodes += ';' + attrCode;
                                        charValues += ';' + ((val == null)?'':String.valueOf(val));
                                    }
                                    else
                                    {
                                        bFirst = false;
                                        charNames += String.valueOf(attr);
                                        charCodes += attrCode;
                                        charValues += ((val == null)?'':String.valueOf(val));
                                    }
                                }
                                if (firstRow)
                                {
                                    rowData.put('Characteristic Code', charCodes);
                                    rowData.put('Characteristic Name', charNames);
                                    rowData.put('Characteristic Value', charValues);
                                    result.add(rowData);
                                    firstRow = false;
                                }
                                else
                                {
                                    Map<String, Object> clonedRow = rowData.clone();
                                    clonedRow.put('Characteristic Code', charCodes);
                                    clonedRow.put('Characteristic Name', charNames);
                                    clonedRow.put('Characteristic Value', charValues);
                                    result.add(clonedRow);   
                                }
                            }
                        }
                    }
                }
            }
        }        
        output.put('Result', result);
    }
    private void priceItems(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap)
    {    
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        List<SObject> itemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        Map<String, Boolean> singleCart = new  Map<String, Boolean>();
        singleCart.put('flag',false);
        
        if(itemList !=null && itemList.size()>0){
            Schema.SObjectType itemObjType = itemList[0].getSObjectType();
            String itemObjName = itemObjType.getDescribe().getName();
            String nameSpaceprefix = 'vlocity_cmt__';
            List<Id> productIdList = new List<Id> (); 
            List<String> productCodeList = new List<String> (); 
            List<SObject> itemSoList = new list<SObject>();  
            String parentObjName;
            if(itemObjName=='OpportunityLineItem'){
                parentObjName='Opportunity';
            }
            else if(itemObjName=='OrderItem'){
                parentObjName='Order';
            }
            else if(itemObjName=='QuoteLineItem'){
                parentObjName='Quote';
            }
            String parentIdName = parentObjName+'Id';
            Id parentId;  
            
            Map<Id, List<SObject>> productIdToSObject = new Map<Id, List<SObject>> ();   
            Map<String, List<SObject>> productCodeToSObject = new Map<String, List<SObject>> ();   
            
            for(Integer i = 0; i < itemList.size(); i++){
                Sobject objectSO = itemList[i];
                if(objectSO !=null && objectSO.getSObject('PricebookEntry') !=null){
                    Id productId = (Id)objectSO.getSObject('PricebookEntry').get('Product2Id');
                    String productCode = (String)objectSO.getSObject('PricebookEntry').getSObject('Product2').get('ProductCode');
                    productCodeList.add(productCode);
                    
                    productIdList.add(productId);
                    String concatenatedProductCode;
                    if(parentObjName=='Quote'){
                        Map<String,Object> fieldsForItem =new Map<String,Object>();
                        fieldsForItem = objectSO.getPopulatedFieldsAsMap();   
                        
                        if(!isTestContext && fieldsForItem.containsKey('TeliaSE_ParentClusterCode__c') && objectSO.get('TeliaSE_ParentClusterCode__c') != null){                        
                            concatenatedProductCode = productCode + objectSO.get('TeliaSE_ParentClusterCode__c');
                        }
                        else if (!isTestContext && fieldsForItem.containsKey('TeliaSE_MC_Binding_Time__c') && objectSO.get('TeliaSE_MC_Binding_Time__c') != null){
                            concatenatedProductCode = productCode + objectSO.get('TeliaSE_MC_Binding_Time__c');
                        }else{
                            concatenatedProductCode = productCode;
                        }
                    }else{
                        concatenatedProductCode = productCode;
                    }
                    
                    if(productCodeToSObject.get(concatenatedProductCode) !=null){
                        itemSoList = productCodeToSObject.get(concatenatedProductCode);
                        itemSoList.add(objectSO);
                    }
                    else{
                        itemSoList = new List<SObject> ();
                        itemSoList.add(objectSO);
                        productCodeToSObject.put(concatenatedProductCode, itemSoList);
                    }
                    
                    parentId = (Id)parent.get('Id');
                }
            }
            
            
            if(productCodeList !=null && productCodeList.size()>0){
                /*
if(parentObjName.equalsIgnoreCase('Quote') && vlocity_cmt.FlowStaticMap.flowMap.containsKey('CPQAction') && (vlocity_cmt.FlowStaticMap.flowMap.get('CPQAction') == 'postCartsItems')) {
getBindingTimeAndPricelistSetup(productIdList,parentId,parent);     //invoking here for hardware
}
*/
                
                List<SObject> listContractLineItems = getFrameContractLineItems(productCodeList, productIdList, parentId, parentObjName, parent,singleCart);
                
                Map<String,Decimal> percentageProductsCodeMap=new Map<String,Decimal>();
                If(singleCart.get('flag')){
                    QuoteLineItem quoteLine;
                    for(sObject lineItem:listContractLineItems){
                        quoteLine=(QuoteLineItem)lineItem;
                        if(quoteLine.TeliaSE_Root_Product__r.TeliaSE_Product_Type__c =='Percentage'){
                            percentageProductsCodeMap.put(quoteLine.vlocity_cmt__Product2Id__r.ProductCode,null);
                        }    
                    }   
                }
                else{
                    vlocity_cmt__ContractLineItem__c contractLine;
                    for(sObject lineItem:listContractLineItems){
                        contractLine=(vlocity_cmt__ContractLineItem__c)lineItem;
                        if(contractLine.vlocity_cmt__QuoteLineItem__r.TeliaSE_Root_Product__r.TeliaSE_Product_Type__c =='Percentage'){
                            percentageProductsCodeMap.put(contractLine.vlocity_cmt__ProductCode__c,null);
                        }
                    }
                }
                for(vlocity_cmt__PriceListEntry__c  entry:[select id,vlocity_cmt__ProductId__c, vlocity_cmt__ProductId__r.ProductCode, vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c  from  vlocity_cmt__PriceListEntry__c   where vlocity_cmt__ProductId__r.ProductCode in :percentageProductsCodeMap.keySet()])
                {
                    percentageProductsCodeMap.put(entry.vlocity_cmt__ProductId__r.ProductCode,entry.vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c);
                }
                List<SObject> lineItemSObject = new List<SObject> ();
                Map<String, Object> itemFields = new Map<String, Object>();
                Map<String, object> LineItemFieldValue ;
                Map<String, object> LineItemField ;
                
                if(listContractLineItems !=null && listContractLineItems.size()>0){
                    for(SObject line : listContractLineItems){
                        String cLineProductCode;
                        String productCode;
                        if(singleCart.get('flag')){
                            productCode = (String) line.get('TeliaSE_Product_Code__c');
                            if(line.get('TeliaSE_ParentClusterCode__c') != null){
                                cLineProductCode = productCode + line.get('TeliaSE_ParentClusterCode__c');
                            }else if (line.get('TeliaSE_MC_Binding_Time__c') != null){
                                cLineProductCode = productCode + line.get('TeliaSE_MC_Binding_Time__c');
                            }else{
                                cLineProductCode = productCode;
                            }
                        }
                        else{
                            cLineProductCode = (String) line.get(nameSpaceprefix+'ProductCode__c');
                        }
                        List<SObject> oObjectSOList = productCodeToSObject.get(cLineProductCode);
                        if(oObjectSOList !=null && oObjectSOList.size()>0){
                            for(SObject oObjectSO : oObjectSOList){
                                oObjectSO.put(nameSpacePrefix+'OneTimeTotal__c', (Decimal) line.get(nameSpacePrefix+'OneTimeTotal__c'));
                                oObjectSO.put(nameSpacePrefix+'OneTimeCharge__c', (Decimal) line.get(nameSpaceprefix+'OneTimeCharge__c'));  
                                oObjectSO.put(nameSpacePrefix+'OneTimeDiscountPrice__c', (Decimal) line.get(nameSpacePrefix+'OneTimeDiscountPrice__c'));
                                oObjectSO.put(nameSpacePrefix+'OneTimeManualDiscount__c', (Decimal) line.get(nameSpaceprefix+'OneTimeManualDiscount__c'));                              
                                oObjectSO.put(nameSpacePrefix+'OverageCharge__c', (Decimal) line.get(nameSpacePrefix+'OverageCharge__c'));
                                oObjectSO.put(nameSpacePrefix+'OverageDiscountPrice__c', (Decimal) line.get(nameSpaceprefix+'OverageDiscountPrice__c'));    
                                oObjectSO.put(nameSpacePrefix+'OverageManualDiscount__c', (Decimal) line.get(nameSpacePrefix+'OverageManualDiscount__c'));
                                oObjectSO.put(nameSpacePrefix+'OverageTotal__c', (Decimal) line.get(nameSpaceprefix+'OverageTotal__c'));                
                                oObjectSO.put(nameSpacePrefix+'OverageUOM__c', (String) line.get(nameSpacePrefix+'OverageUOM__c'));                   
                                oObjectSO.put(nameSpacePrefix+'RecurringCharge__c', (Decimal) line.get(nameSpaceprefix+'RecurringCharge__c'));  
                                oObjectSO.put(nameSpacePrefix+'RecurringDiscountPrice__c', (Decimal) line.get(nameSpacePrefix+'RecurringDiscountPrice__c'));
                                oObjectSO.put(nameSpacePrefix+'RecurringManualDiscount__c', (Decimal) line.get(nameSpaceprefix+'RecurringManualDiscount__c'));  
                                oObjectSO.put(nameSpacePrefix+'RecurringTotal__c', (Decimal) line.get(nameSpacePrefix+'RecurringTotal__c'));
                                oObjectSO.put(nameSpacePrefix+'RecurringUOM__c', (String) line.get(nameSpaceprefix+'RecurringUOM__c')); 
                                if(parentObjName.equalsIgnoreCase('Quote')){
                                    oObjectSO.put('TeliaSE_MC_Campaign_Id__c', (String) line.get('TeliaSE_MC_Campaign_Id__c'));
                                }
                                //Added by Suneel as part of US-531
                                LineItemField=getMap();
                                LineItemFieldValue=getMap();              
                                LineItemFieldValue.put('detail','Price from FrameAgreement');
                                Decimal finalPrice;
                                //Decimal price=percentageProductsCodeMap.get(cLineProductCode)!=null?percentageProductsCodeMap.get(cLineProductCode):(Decimal) line.get(nameSpaceprefix+'RecurringCharge__c');
                                Decimal price=(percentageProductsCodeMap.get(cLineProductCode)!=null  &&  !cLineProductCode.contains('ICT_')) ?percentageProductsCodeMap.get(cLineProductCode):(Decimal) line.get(nameSpaceprefix+'RecurringCharge__c');                                 
                                if(singleCart.get('flag')){
                                    if(line.get('TeliaSE_MC_Customer_Requested_Price__c') != null){
                                        finalPrice=(Decimal)line.get('TeliaSE_MC_Customer_Requested_Price__c');
                                    }
                                    else if(line.get('TeliaSE_MC_Customer_Requested_Percentage__c') !=null || (line.get('TeliaSE_Discount_Percentage__c')!= null && (Decimal)line.get('TeliaSE_Discount_Percentage__c') > 0)) { 
                                        Decimal finalPercentage=(Decimal)line.get('TeliaSE_MC_Customer_Requested_Percentage__c')!=null?(Decimal)line.get('TeliaSE_MC_Customer_Requested_Percentage__c'):(Decimal)line.get('TeliaSE_Discount_Percentage__c');
                                        finalPrice=price-((price*(finalPercentage))/100);
                                        finalPrice = finalPrice.setScale(2, RoundingMode.HALF_UP);
                                    }
                                    else{
                                        finalPrice=price;
                                    }
                                }
                                else{
                                    if(line.get('TeliaSE_MC_Customer_Requested_Price__c') != null){
                                        finalPrice=(Decimal)line.get('TeliaSE_MC_Customer_Requested_Price__c');
                                    }
                                    else if(line.get('TeliaSE_MC_Customer_Requested_Percentage__c') !=null || (line.get('TeliasSETargetPercentage__c')!= null && (Decimal)line.get('TeliasSETargetPercentage__c') > 0)){ 
                                        Decimal finalPercentage=(Decimal)line.get('TeliaSE_MC_Customer_Requested_Percentage__c')!=null?(Decimal)line.get('TeliaSE_MC_Customer_Requested_Percentage__c'):(Decimal)line.get('TeliasSETargetPercentage__c');
                                        finalPrice=price-((price*(finalPercentage))/100);
                                        finalPrice = finalPrice.setScale(2, RoundingMode.HALF_UP);
                                    }                            
                                    else{
                                        finalPrice=price;                                    }
                                }  
                                LineItemFieldValue.put('value',finalPrice);
                                LineItemField.put('vlocity_cmt__RecurringCharge__c',LineItemFieldValue);
                                LineItemFieldValue=getMap();
                                LineItemFieldValue.put('value',line.get(nameSpaceprefix+'OneTimeCharge__c'));
                                LineItemField.put('vlocity_cmt__OneTimeCharge__c',LineItemFieldValue);
                                lineItemSObject.add(oObjectSO); 
                                itemFields.put(oObjectSO.id,LineItemField);   
                            }               
                        }
                    }                    
                    //update lineItemSObject;
                    // instead of doing an update DML, we pass it back into the pricing plan so in the "Save Line Items" step it will do one DML                   
                    Map<String, String> varCodeToFieldMap = new Map<String, String>{
                        'REC_MNTH_STD_PRC'=>'vlocity_cmt__RecurringCharge__c',
                            'OT_STD_PRC'=>'vlocity_cmt__OneTimeCharge__c'
                            };
                                
                                Type t = Type.forName('vlocity_cmt.SetCartItemExternalPriceService');
                    if (t != null)
                    {
                        vlocity_cmt.VlocityOpenInterface externalPriceService = (vlocity_cmt.VlocityOpenInterface)t.newInstance();
                        Map<String, Object> externalPriceServiceInput = new Map<String, Object>();
                        Map<String, Object> externalPriceServiceOutput = new Map<String, Object>();
                        Map<String, Object> externalPriceServiceOptions = new Map<String, Object>();
                        
                        externalPriceServiceInput.put('parent', parent);
                        externalPriceServiceInput.put('itemList', lineItemSObject);//externalPriceServiceInput.put('itemList', itemList);
                        externalPriceServiceInput.put('pricingVariableToFieldMap', varCodeToFieldMap);                          
                        externalPriceServiceInput.put('itemFieldsInfo', itemFields);
                        // skip update to prevent this service from flushing to the database since the pricing plan service
                        // will update the itemList anyway, this saves one DML update
                        externalPriceServiceOptions.put('SkipUpdate', true);
                        
                        externalPriceService.invokeMethod('setItemPrices', externalPriceServiceInput,
                                                          externalPriceServiceOutput, externalPriceServiceOptions);
                        //}
                    }
                }
            }
        }
        //return true;        
    }
    
    public List<SObject> getFrameContractLineItems(List<String> productCodeList, List<Id> productIdList, Id parentId, String parentObjName, sObject parent,Map<String, Boolean> singleCart){
        String nameSpaceprefix = 'vlocity_cmt__'; //ApplicationUtilities.getNameSpacePrefix();
        SObjectType contractLineObj = Schema.getGlobalDescribe().get(nameSpaceprefix+'ContractLineItem__c');
        Map<String,Schema.SObjectField> objfields = contractLineObj.getDescribe().fields.getMap();
        String query = 'Select ';
        Boolean firstField = true;
        Boolean addFlag=false;
        List<vlocity_cmt__ContractLineItem__c> lines=new List<vlocity_cmt__ContractLineItem__c>();
        List<Sobject> contractLineList=new List<Sobject>();
        for (String field : objfields.keySet())
        {
            if(firstField)
                query += field;
            else{
                query +=' , ';
                query += field;
            }
            firstField = false;
        }
        query +=',vlocity_cmt__Product2Id__r.TeliaSE_Product_Type__c,vlocity_cmt__QuoteLineItem__r.TeliaSE_Root_Product__r.TeliaSE_Product_Type__c';
        query += ' FROM ' + nameSpaceprefix+'ContractLineItem__c';
        
        String queryForQuote = '';
        Quote quote = null;
        Id frameContractId = null;
        Id contractQuoteId = null;
        
        if(parentObjName.equalsIgnoreCase('Quote')){
            
            //added by Suneel as part of US-531
            queryForQuote='select '+nameSpaceprefix+'frameContractId__c,'+nameSpaceprefix+'ParentQuoteId__c from '+parentObjName +' where Id= \'' +parentId+'\'';            
            quote=(Quote) Database.query(queryForQuote).get(0);
            frameContractId=quote.vlocity_cmt__frameContractId__c;
            contractQuoteId = quote.vlocity_cmt__ParentQuoteId__c;
        }else if(parentObjName.equalsIgnoreCase('Order')){
            Order pObj = (Order)parent;
            Order parentObj = [Select id, vlocity_cmt__AccountId__c From Order Where Id=: pObj.Id];
            List<Contract> contractList = [select id, status from Contract where accountid=:parentObj.vlocity_cmt__AccountId__c and status='Active' AND RecordType.Name = 'Ramavtal' limit 1];
            if(contractList != null && contractList.size() > 0){
                frameContractId = contractList[0].Id;
            }
        }
        if(contractQuoteId != null){
            singleCart.put('flag',true);
            return getQuoteLineItems(productCodeList, productIdList, parentId, parentObjName, contractQuoteId);
        }
        if(frameContractId !=null)
        {
            List<String> statusValues=new List<String>{'InActive','Terminated','Cancelled'};
                DateTime thisDay = Datetime.now();
            String endDate = thisDay.format('yyyy-MM-dd');
            String queryforContracts='Select id from Contract where EndDate >='+endDate+'AND status not in :statusValues '+' AND '+'('+nameSpaceprefix+'ParentContractId__c =\'' +frameContractId+'\''+ ' or id=\'' +frameContractId+'\''+')';
            
            Map<Id,sObject> contractIds=new Map<Id,sObject>(DataBase.query(queryforContracts));
            Set<Id> ids=contractIds.keySet();
            String whereClause ='';
            if(parentObjName.equalsIgnoreCase('Quote')){
                whereClause = ' where '+nameSpaceprefix+'productcode__c IN :productCodeList  AND '+nameSpaceprefix+'ContractId__c In :ids AND TeliaSE_End_Date__c >='+endDate;
            }else if(parentObjName.equalsIgnoreCase('Order')){
                whereClause = ' where '+nameSpaceprefix+'productcode__c IN :productCodeList  AND '+nameSpaceprefix+'ContractId__c In :ids';
            }
            query +=whereClause;
            lines = database.query(query);
            
            Map<Id,sObject> linesMap=new Map<Id,sObject>();
            Map<Id,Integer> duplicateLines=new Map<Id,Integer>();
            for(vlocity_cmt__ContractLineItem__c line:lines)
            {
                if(duplicateLines.get(line.vlocity_cmt__Product2Id__c) !=null)
                {
                    Integer count=duplicateLines.get(line.vlocity_cmt__Product2Id__c)+1;  
                    duplicateLines.put(line.vlocity_cmt__Product2Id__c,count);
                }
                else
                    duplicateLines.put(line.vlocity_cmt__Product2Id__c,1);
            }
            for(vlocity_cmt__ContractLineItem__c cli:lines)
            {
                if(cli.TeliaSE_Terminate_Date__c == null || cli.TeliaSE_Terminate_Date__c > Date.today())
                {
                    if(duplicateLines.get(cli.vlocity_cmt__Product2Id__c) > 1)
                    {
                        String productHierarchy=(String)cli.TeliaSE_ProductHierarchy__c;
                        for(String id:(List<String>)productIdList)
                        {
                            if(productHierarchy.contains(id))
                            {
                                addFlag=true;
                            }
                            else
                            {
                                addFlag=false;
                                break;
                            }
                        }
                        if(addFlag)
                        {
                            linesMap.put(cli.Id,(sObject)cli);
                        }
                    }
                    else
                        linesMap.put(cli.Id,(sObject)cli);
                }
            }
            return linesMap.values();
        }
        else {
            for(Object c:contractLineList){
            }
            return contractLineList;
        }
        
    }
    
    public List<SObject> getQuoteLineItems(List<String> productCodeList,List<Id> productIdList, Id parentId, String parentObjName, Id contractQuoteId){
        SObjectType quoteLineObj = Schema.getGlobalDescribe().get('QuoteLineItem');
        Map<String,Schema.SObjectField> objfields = quoteLineObj.getDescribe().fields.getMap();
        String query = 'Select ';
        Boolean firstField = true;
        Boolean addFlag=false;
        List<QuoteLineItem> lines=new List<QuoteLineItem>();
        List<Sobject> QuoteLineList=new List<Sobject>();
        for (String field : objfields.keySet()){
            if(firstField)
                query += field;
            else{
                query +=' , ';
                query += field;
            }
            firstField = false;
        }
        query += ',TeliaSE_Root_Product__r.TeliaSE_Product_Type__c,vlocity_cmt__Product2Id__r.TeliaSE_Product_Type__c,vlocity_cmt__Product2Id__r.ProductCode';
        query += ' FROM QuoteLineItem' ;
        String whereClause = ' where vlocity_cmt__Product2Id__r.ProductCode IN :productCodeList  AND QuoteId =: contractQuoteId';
        query +=whereClause;
        lines = database.query(query);
        Map<Id,sObject> linesMap=new Map<Id,sObject>();
        Map<Id,Integer> duplicateLines=new Map<Id,Integer>();
        for(QuoteLineItem line:lines){
            if(duplicateLines.get(line.vlocity_cmt__Product2Id__c) !=null){
                Integer count=duplicateLines.get(line.vlocity_cmt__Product2Id__c)+1;  
                duplicateLines.put(line.vlocity_cmt__Product2Id__c,count);
            }else{
                duplicateLines.put(line.vlocity_cmt__Product2Id__c,1);
            }
        }
        for(QuoteLineItem qli:lines){
            if(duplicateLines.get(qli.vlocity_cmt__Product2Id__c) > 0){
                String productHierarchy=(String)qli.vlocity_cmt__ProductHierarchyPath__c;
                for(String id:(List<String>)productIdList){
                    if(productHierarchy.contains(id)){
                        addFlag=true;
                        break;
                    }else{
                        addFlag=false;
                        //    break;
                    }
                }
                if(addFlag){
                    linesMap.put(qli.Id,(sObject)qli);
                }
            }
        }
        return linesMap.values();
    }       
    
    public void clearExternalPriceFlag(List<SObject> itemList)
    {
        for (SObject item : itemList)
        {
            String itemObjectName = item.getSObjectType().getDescribe().getName();
            String provisioningStatus = (String)item.get('vlocity_cmt__ProvisioningStatus__c');
            // Only clear flags for non-Asset items and if provisioningStatus is not Deleted
            if (provisioningStatus != 'Deleted' && itemObjectName != 'Asset' && !isTestContext)
            {
                String priceLogJSON = (String)item.get('vlocity_cmt__PricingLogData__c');
                if (priceLogJSON == null) return;
                Map<String, Object> logMap = (Map<String, Object>)JSON.deserializeUntyped(priceLogJSON);
                if (logMap == null || logMap.isEmpty())
                {
                    return;
                }
                Map<String, Object> externalPrices = (Map<String, Object>)logMap.remove('ExternalPrices');
                if (externalPrices != null)
                {
                    item.put('vlocity_cmt__PricingLogData__c', JSON.serialize(logMap));
                }
            }
        }
    }
    
    private void invokeIntegrationProcedure(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        String procedureAPIName = (String)input.get('ProcedureAPIName');
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        // The runIntegrationService method takes in Type_SubType of the VIP as the first parameter. Address is Type and GetAddress is the SubType in this sample.
        Object result = vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureAPIName, inputMap, optionsMap);
        output.put('Result', result);
    }
    
    //procedureName1 - if procedureName1 is blank then it will consider procedureName from inputMap(Pricing Plan Step Parameter)
    private Boolean invokeCalculationProcedure (Map<String, Object> input, Map<String, Object> output, Map<String, Object> options, String procedureName1)
    {
        String procedureName = '';
        List<Object> inputData = (List<Object>)input.get('InputData');
        
        if(String.isBlank(procedureName1)){
            procedureName = (String)input.get('ProcedureName');
            //procedureName = procedureName1;
        }else{
            procedureName = procedureName1;
        }
        
        if (String.isBlank(procedureName) || inputData == null || inputData.isEmpty())
        {
            output.put('ErrorMessage', 'ProcedureName or InputData are empty.');
            return false;
        }
        // Construct the matrix calculation service
        Type t = Type.forName('vlocity_cmt.PricingMatrixCalculationService');
        
        vlocity_cmt.VlocityOpenInterface matrixService = (vlocity_cmt.VlocityOpenInterface)t.newInstance();
        
        Map<String, Object> inputMap = new Map<String, Object>{
            'inputData' => inputData
                };
                    Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>{
            'configurationName' => procedureName, // String procedureName = 'TestCalculationProcedure'
                'inputKey' => 'inputData', // tells the service what is the key for the data in the inputMap,
                'mode' => null,
                'verbose' => true,
                'matchInputVariables' => true,
                'effectiveDate' => String.valueOf(System.Now()),
                'configurationVersionId' => null // Set the matrix version id. Null version id picks the latest version with highest priority
                };
                    
                    // TODO: Extract error
                    // invoke the calculation procedure
                    matrixService.invokeMethod('calculate', inputMap, outputMap, optionsMap);
        
        //Parse the calculation procedure response
        List<Object> outList = (List<Object>)outputMap.get('output');
        List<Object> objectList;
        if (outList != null && !outList.isEmpty())
        {
            vlocity_cmt.PricingCalculationService.CalculationProcedureResults calcProcResults =
                (vlocity_cmt.PricingCalculationService.CalculationProcedureResults)outList[0];
            objectList = calcProcResults.calculationResults;
        }
        
        // return the objectList
        output.put('Result', objectList);
        return true;
    }
    /*-----------------------------------------------------------------------------------------------------------
**Name        :        Flag
**Created By  :        Shubham Kundu
**Description :        Approval Flag update for customer Requested % and customer Requested Price
-----------------------------------------------------------------------------------------------------------*/
    private void updateFlag(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        List<SObject> qItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');        
        SObject parentInput = (SObject)input.get('Parent');
        Quote parent = (Quote)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        Quote reqQuote = [select Id,TeliaSE_Record_Type_Name__c,vlocity_cmt__PriceListId__c, vlocity_cmt__PriceListId__r.Name  from quote where Id =: parent.Id];
        String recType = reqQuote.TeliaSE_Record_Type_Name__c;
        String happyFace = System.Label.TeliaSE_HappyFace;
        String sadFace = System.Label.TeliaSE_SadFace;
        set<id> setOfSadFaceUpdateFlag = new set<id>(); //Added this as part of MCSTO-8370
        
        //added recordType check to skip for offer quote - 23.10
        if(SEUtility.isRecordTypeAvailable(SEUtility.MC, SEUtility.QUOTE, recType) && recType != 'Offer'){
            
            //added Query to get missing formula fields
            Map<ID, QuoteLineItem> qItemMap = new Map<ID, QuoteLineItem>([SELECT id,TeliaSE_Floor_Percentage__c,TeliaSE_Ceiling_Price__c 
                                                                          FROM QuoteLineItem WHERE QuoteId =: parent.Id]);
            //verify MC Quote - SEUtility.isRecordTypeAvailable
            if(qItemList != null && qItemList.size() > 0){
                User u = [Select Id,MassCustomized_Roles__c from User WHERE Id = :UserInfo.getUserId()];
                String roleString;
                if(u.MassCustomized_Roles__c != null){
                    roleString = u.MassCustomized_Roles__c;
                }
                for(SObject qliItem : qItemList){
                    QuoteLineItem qliObject = (QuoteLineItem)qliItem;
                    QuoteLineItem qliMapObject = qItemMap.get(qliObject.Id);
                    String jobSurfProductCode = isTestContext ? 'MOB_SURF_BAS_V2':qliObject.PricebookEntry.Product2.ProductCode;
                    if ((qliObject.TeliaSE_MC_Customer_Requested_Price__c!=null) || (qliObject.TeliaSE_MC_Customer_Requested_Percentage__c!=null && qliObject.TeliaSE_MC_Customer_Requested_Percentage__c!=0 ) || qliObject.vlocity_cmt__OneTimeCharge__c != null){
                        Double floorPercentage = qliMapObject.TeliaSE_Floor_Percentage__c;
                        Double crpPercent = qliObject.TeliaSE_MC_Customer_Requested_Percentage__c;
                        Double ceilingPrice = qliMapObject.TeliaSE_Ceiling_Price__c;
                        Double recurCharge = qliObject.vlocity_cmt__RecurringCharge__c;
                        Double srMandPercnt = qliObject.TeliaSE_AM_Mandate_Percentage__c;
                        Double smMandPercnt = qliObject.TeliaSE_SM_Mandate_Percentage__c;
                        Double sdMandPercnt = qliObject.TeliaSE_SD_Mandate_Percentage__c;
                        Double cmMandPercnt = qliObject.TeliaSE_CM_Mandate_Percentage__c;
                        Double oTfloorPercentage;// = qliObject.MC_OT_Floor_Percentage__c;
                        if(roleString == 'SalesRep'){
                            oTfloorPercentage = qliObject.MC_OT_AM_Mandate_Percentage__c;
                        }else if(roleString == 'SalesManager'){
                            oTfloorPercentage = qliObject.MC_OT_SM_Mandate_Percentage__c;
                        }else if(roleString == 'SalesDirector'){
                            oTfloorPercentage = qliObject.MC_OT_SD_Mandate_Percentage__c;
                        }else if(roleString == 'CommercialManager'){
                            oTfloorPercentage = qliObject.MC_OT_CM_Mandate_Percentage__c;
                        }else{
                            oTfloorPercentage = 0;
                        }
                        Double oneTimeCharge = qliObject.MC_OneTimeCharge__c;
                        Double otSRMandPercnt = qliObject.MC_OT_AM_Mandate_Percentage__c;
                        Double otSMMandPercnt = qliObject.MC_OT_SM_Mandate_Percentage__c;
                        Double otSDMandPercnt = qliObject.MC_OT_SD_Mandate_Percentage__c;
                        Double otCMMandPercnt = qliObject.MC_OT_CM_Mandate_Percentage__c;
                        
                        Double floorPrice,floorPer,oTfloorPrice,oTfloorPer;
                        oTfloorPrice =0;
                        oTfloorPer=0;
                        if (roleString == 'SalesRep'){
                            floorPrice = (recurCharge - (recurCharge*srMandPercnt/100));
                            if(floorPercentage!=null && floorPrice ==recurCharge){
                                floorPer = floorPercentage;
                            }else{
                                floorPer = srMandPercnt;
                            }
                            if(otSRMandPercnt != null )   
                            {
                                if(oneTimeCharge != null){
                                    oTfloorPrice = (oneTimeCharge - (oneTimeCharge*otSRMandPercnt/100));
                                }
                            }
                            if(oTfloorPercentage!=null && oTfloorPrice ==oneTimeCharge){
                                oTfloorPer = oTfloorPercentage;
                            }else{
                                oTfloorPer = otSRMandPercnt;
                            }
                            
                        }else if (roleString == 'SalesManager'){
                            if(smMandPercnt != null){
                                floorPrice = (recurCharge - (recurCharge*smMandPercnt/100));
                            }
                            if(floorPercentage!=null && floorPrice ==recurCharge){
                                floorPer = floorPercentage;
                            }else{
                                floorPer = smMandPercnt;
                            }
                            If(otSMMandPercnt!= null)
                            {
                                if(oneTimeCharge != null){
                                    oTfloorPrice = (oneTimeCharge - (oneTimeCharge*otSMMandPercnt/100));
                                }
                            }                    
                            if(oTfloorPercentage!=null && oTfloorPrice ==oneTimeCharge){
                                oTfloorPer = oTfloorPercentage;
                            }else{
                                oTfloorPer = otSMMandPercnt;
                            }
                        }else if (roleString == 'SalesDirector'){
                            floorPrice = (recurCharge - (recurCharge*sdMandPercnt/100));
                            
                            if(floorPercentage!=null && floorPrice ==recurCharge){
                                floorPer = floorPercentage;
                            }else{
                                floorPer = sdMandPercnt;
                            }
                            If(otSDMandPercnt!= null)
                            {
                                if(oneTimeCharge != null){
                                    oTfloorPrice = (oneTimeCharge - (oneTimeCharge*otSDMandPercnt/100));
                                }
                            }
                            
                            if(oTfloorPercentage!=null && oTfloorPrice ==oneTimeCharge){
                                oTfloorPer = oTfloorPercentage;
                            }else{
                                oTfloorPer = otSDMandPercnt;
                            }
                        }else if (roleString == 'CommercialManager'){
                            floorPrice = (recurCharge - (recurCharge*cmMandPercnt/100));
                            
                            if(floorPercentage!=null && floorPrice ==recurCharge){
                                floorPer = floorPercentage;
                            }else{
                                floorPer = cmMandPercnt;
                            }
                            if(otCMMandPercnt!= null)
                            {
                                if(oneTimeCharge != null){
                                    oTfloorPrice = (oneTimeCharge - (oneTimeCharge*otCMMandPercnt/100));
                                }
                            }
                            if(oTfloorPercentage!=null && oTfloorPrice ==oneTimeCharge){
                                oTfloorPer = oTfloorPercentage;
                            }else{
                                oTfloorPer = otCMMandPercnt;
                            }
                        }else{
                            floorPrice = recurCharge;
                            floorPer = 0;
                            if(oneTimeCharge != null )
                            {
                                oTfloorPrice = oneTimeCharge;    
                            }
                            oTfloorPer = 0;
                        }
                        Double fprice;
                        if(floorPrice != null){
                            fprice = floorPrice.round();
                        }
                        Double otfprice = oTfloorPrice.round();
                        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
                        qliList.add(qliObject);
                        Map<Id,QuoteLineItem> qliMap = new Map<Id,QuoteLineItem>();
                        qliMap.put(qliObject.Id,qliObject);
                        //if(TeliaSE_checkRecursive.runOnce()){
                        if(!isTestContext){
                            if(!qliObject.PriceBookEntry.Product2.ProductCode.contains('MOB_CALL_TRAVEL') && !qliObject.PriceBookEntry.Product2.ProductCode.contains('MOB_SURF')) updateApprovalFlag(qliList,fprice,floorPer,otfprice,oTfloorPer,qItemMap);
                        }//}
                    }else if(qliObject.TeliaSE_MC_Customer_Requested_Price__c ==null && qliObject.TeliaSE_MC_Customer_Requested_Percentage__c == null && jobSurfProductCode.contains('MOB_SURF') == false && jobSurfProductCode.contains('MOB_CALL_TRAVEL') == false){
                        qliObject.TeliaSE_Flag__c = happyFace;
                    }/*else if(qliObject.TeliaSE_MC_Customer_Requested_Price__c == 0 && qliObject.TeliaSE_MC_Customer_Requested_Percentage__c == null){
                        qliObject.TeliaSE_Flag__c = sadFace;
                    }*/else if(qliObject.TeliaSE_MC_Customer_Requested_Percentage__c == 0 && qliObject.TeliaSE_MC_Customer_Requested_Price__c ==null)
                    {
                        qliObject.TeliaSE_Flag__c = happyFace;
                    }
                    //qliObject.MC_Reprice_Required__c=false;//Added by Abhishek for Validera Improvement
                }
            } 
        }
    }
    
    //====================================================================================================
    public static  void  updateApprovalFlag(List<QuoteLineItem> qLI, Double fPrice, Double floorPer,Double otfPrice, Double otfloorPer, Map<Id,QuoteLineItem> qItemMap){
        
        Double crp,floor,ceiling,approvedPrice, approvedPercent,otc,otapprovedPrice;
        String happyFace = System.Label.TeliaSE_HappyFace;
        String sadFace = System.Label.TeliaSE_SadFace;
        String flag;
        List <QuoteLineItem> listqliItem = new List <QuoteLineItem>();
        
        for(QuoteLineItem qliItem : qLI){    
            QuoteLineItem qliMapObject = qItemMap.get(qliItem.Id);
            //If Ceiling Price is not null store in a local variable
            //Approved Percentage - added by Dipanwita 22.07.2019
            if(qliItem.TeliaSE_Approved__c != null && qliItem.TeliaSE_Nullify_Check__c == false){
                approvedPercent = qliItem.TeliaSE_Approved__c;
            }          
            //Ceiling Price
            if(qliMapObject.TeliaSE_Ceiling_Price__c!= null){
                ceiling = qliMapObject.TeliaSE_Ceiling_Price__c; 
            }
            //Null pointer check
            if(ceiling != null){//Requested Price Logic
                if(qliItem.TeliaSE_MC_Customer_Requested_Price__c !=null  ){
                    crp = qliItem.TeliaSE_MC_Customer_Requested_Price__c;
                }              
                
                //Floor % Logic
                else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c!=null) && (floorPer!=null) && (qliItem.TeliaSE_MC_Customer_Requested_Percentage__c!= 0)){
                    if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c <= floorPer) && (approvedPercent == null) ){
                        qliItem.TeliaSE_Flag__c = happyFace; 
                        flag = happyFace;
                    }
                    
                    else if(qliItem.TeliaSE_MC_Customer_Requested_Percentage__c  <= approvedPercent){
                        qliItem.TeliaSE_Flag__c = happyFace;
                        flag = happyFace;
                    }
                    else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c > floorPer)  && (approvedPercent < qliItem.TeliaSE_MC_Customer_Requested_Percentage__c) ){                       
                        qliItem.TeliaSE_Flag__c = sadFace;  
                        flag = sadFace;
                        //qliItem.TeliaSE_Approved_Price__c = null;
                    }
                    else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c > floorPer)  && (approvedPercent == null) ){
                        qliItem.TeliaSE_Flag__c = sadFace; 
                        flag = sadFace;
                    }
                }
                //Floor price Logic 
                if(fPrice!=null){
                    floor = fPrice;
                }
                //Approved Price
                if(qliItem.TeliaSE_Approved_Price__c != null && qliItem.TeliaSE_Nullify_Check__c == false ){
                    approvedPrice = qliItem.TeliaSE_Approved_Price__c;
                }
                
                //Flag Logic
                if(crp!=null && floor!=null ){
                    if(crp >= floor && crp <= ceiling && approvedPrice == null ){
                        qliItem.TeliaSE_Flag__c = happyFace; 
                        flag = happyFace;
                    }
                    
                    else if(crp  >= approvedPrice){
                        qliItem.TeliaSE_Flag__c = happyFace;
                        flag = happyFace;
                    }
                    else if(crp < floor  && approvedPrice > crp ){
                        qliItem.TeliaSE_Approved_Price__c = null;
                        qliItem.TeliaSE_Flag__c = sadFace; 
                        flag = sadFace;
                        // approvedPrice = null;
                    }
                    else if(crp < floor  && approvedPrice == null ){
                        qliItem.TeliaSE_Flag__c = sadFace;  
                        flag = sadFace;
                    }
                }
            }
            
            if(qliItem.MC_OT_Approved_Price__c != null && qliItem.TeliaSE_Nullify_Check__c == false){
                otapprovedPrice = qliItem.MC_OT_Approved_Price__c;
            }
            if(qliItem.vlocity_cmt__OneTimeCharge__c!= null){
                otc = qliItem.vlocity_cmt__OneTimeCharge__c; 
            }
            if(otc != null){
                if(otc >= otfPrice && otapprovedPrice == null && ((qliItem.TeliaSE_Approved_Price__c == qliItem.TeliaSE_MC_Customer_Requested_Price__c)||(qliItem.TeliaSE_MC_Customer_Requested_Price__c == qliItem.vlocity_cmt__RecurringCharge__c)) &&((qliItem.TeliaSE_Approved__c == qliItem.TeliaSE_MC_Customer_Requested_Percentage__c)|| qliItem.TeliaSE_MC_Customer_Requested_Percentage__c == null)){
                    qliItem.TeliaSE_Flag__c = happyFace; 
                }else if(otc  >= otapprovedPrice && qliItem.TeliaSE_Flag__c == happyFace){
                    qliItem.TeliaSE_Flag__c = happyFace;
                }else if(otc  >= otapprovedPrice && qliItem.TeliaSE_Flag__c == sadFace){
                    qliItem.TeliaSE_Flag__c = sadFace;
                }else if(otc < otfPrice  && otapprovedPrice > otc ){
                    qliItem.MC_OT_Approved_Price__c = null;
                    qliItem.TeliaSE_Flag__c = sadFace; 
                }else if(otc < otfPrice  && otapprovedPrice == null ){
                    qliItem.TeliaSE_Flag__c = sadFace;  
                    flag = sadFace;
                }
            }
        }  
        
    }
    //====================================================================================================
    private void updateCartQuantities(Map < String, Object > input, Map < String, Object > output, Map < String, Object > options){ 
        List <SObject> qItemList = (List <SObject>) vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        Quote parent = (Quote) vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        Quote reqQuote = [select Id, TeliaSE_Record_Type_Name__c,TeliaSE_Fiber_Number_of_Households__c,Number_of_other_Ports__c,Amount_of_ports_Smart_Home__c,TeliaSE_Fiber_Number_of_Ports__c,TeliaSE_Pris_BB_exkl_moms__c, TeliaSE_Pris_TV_exkl_moms__c from Quote where Id =: parent.Id];
        
        //Fetch corresponding quantities from quote
        double houseHoldQt = reqQuote.TeliaSE_Fiber_Number_of_Households__c;
        double otherPortsQt = reqQuote.Number_of_other_Ports__c;
        double smartHomePortsQt = reqQuote.Amount_of_ports_Smart_Home__c;
        double totalPortsQt = reqQuote.TeliaSE_Fiber_Number_of_Ports__c;
        decimal bbPrices = reqQuote.TeliaSE_Pris_BB_exkl_moms__c;
        decimal tvPrices = reqQuote.TeliaSE_Pris_TV_exkl_moms__c;
        
        Map<String, double> mapOfProducts = new Map<String, double>();
        Map<String, decimal> mapOfProductPrices = new Map<String, double>();
        
        List <TeliaSE_HouseHold_Products__mdt> houseHoldmdt = new list<TeliaSE_HouseHold_Products__mdt>();
        List <TeliaSE_Other_Ports_Product__mdt> otherPortsmdt = new list<TeliaSE_Other_Ports_Product__mdt>();
        List <TeliaSE_Smart_Home_Product__mdt> smartHomePortsmdt = new list<TeliaSE_Smart_Home_Product__mdt>();
        List <TeliaSE_Total_Ports_Product__mdt> totalPortsmdt = new list<TeliaSE_Total_Ports_Product__mdt>();
        List <TeliaSE_BB_ProductCode__mdt> BBmdt = new list<TeliaSE_BB_ProductCode__mdt>();
        List <TeliaSE_TV_ProductCode__mdt> TVmdt = new list<TeliaSE_TV_ProductCode__mdt>();
        
        BBmdt = [SELECT Product_Code__c FROM TeliaSE_BB_ProductCode__mdt];
        TVmdt = [SELECT Product_Code__c FROM TeliaSE_TV_ProductCode__mdt];
        
        if( houseHoldQt > 0 ){
            houseHoldmdt = [SELECT Product_Code__c FROM TeliaSE_HouseHold_Products__mdt];
        }
        if( otherPortsQt > 0 ){
            otherPortsmdt = [SELECT Product_Code__c FROM TeliaSE_Other_Ports_Product__mdt];
        }
        if( smartHomePortsQt > 0 ){
            smartHomePortsmdt = [SELECT Product_Code__c FROM TeliaSE_Smart_Home_Product__mdt];
        }
        if( totalPortsQt > 0 ){
            totalPortsmdt = [SELECT Product_Code__c FROM TeliaSE_Total_Ports_Product__mdt];
        }
        
        if(reqQuote.TeliaSE_Record_Type_Name__c == 'Individual_Quote' || reqQuote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote_of_FA' || reqQuote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote' || reqQuote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_FA_Quote'){
            
            if(houseHoldmdt.size() > 0){
                for(TeliaSE_HouseHold_Products__mdt i: houseHoldmdt)
                {
                    mapOfProducts.put(i.Product_Code__c,houseHoldQt);
                }
            }
            if(otherPortsmdt.size() > 0){
                for(TeliaSE_Other_Ports_Product__mdt i: otherPortsmdt)
                {
                    mapOfProducts.put(i.Product_Code__c,otherPortsQt);
                }
            }
            if(smartHomePortsmdt.size() > 0){
                for(TeliaSE_Smart_Home_Product__mdt i: smartHomePortsmdt)
                {
                    mapOfProducts.put(i.Product_Code__c,smartHomePortsQt);
                }
            }
            if(totalPortsmdt.size() > 0){
                for(TeliaSE_Total_Ports_Product__mdt i: totalPortsmdt)
                {
                    mapOfProducts.put(i.Product_Code__c,totalPortsQt);
                }
            }
            //Start of mapping for product prices
            for(TeliaSE_BB_ProductCode__mdt j: BBmdt)
            {  
                if(bbPrices != 0 ){
                    mapOfProductPrices.put(j.Product_Code__c,bbPrices);
                }
            }
            for(TeliaSE_TV_ProductCode__mdt k: TVmdt)
            {
                if(tvPrices != 0 ){
                    mapOfProductPrices.put(k.Product_Code__c,tvPrices);
                }
            }
        }
        
        if (qItemList != null && qItemList.size() > 0 && (reqQuote.TeliaSE_Record_Type_Name__c == 'Individual_Quote' || reqQuote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote_of_FA' || reqQuote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote' || reqQuote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_FA_Quote')){
            for (SObject qliItem: qItemList){
                QuoteLineItem qliObject = (QuoteLineItem) qliItem;
                if(mapOfProducts.get(qliObject.PriceBookEntry.Product2.ProductCode) != null){
                    if(vlocity_cmt.FlowStaticMap.flowMap.get('CPQAction') == 'postCartsItems'){
                        qliObject.Quantity  = mapOfProducts.get(qliObject.PriceBookEntry.Product2.ProductCode);
                        //Below logic is for price mapping
                        if(mapOfProductPrices.get(qliObject.PriceBookEntry.Product2.ProductCode) != null && (reqQuote.TeliaSE_Record_Type_Name__c != 'TeliaSE_Fiber_CA_Quote_of_FA' && reqQuote.TeliaSE_Record_Type_Name__c != 'TeliaSE_Fiber_FA_Quote')){
                            
                            qliObject.Fiber_Customer_Requested_Price__c  = mapOfProductPrices.get(qliObject.PriceBookEntry.Product2.ProductCode);
                        }
                    }//End of if
                }//Checking whether product is present in set or not
            }//End of for
        }//End of if
    }    
    
    //CRM Fiber Phase 2 method updateDiscount
    private void updateDiscount(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        SObject parentInput = (SObject)input.get('Parent');
        Quote parent = (Quote)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        
        if( vlocity_cmt.FlowStaticMap.flowMap.containsKey('methodName') && vlocity_cmt.FlowStaticMap.flowMap.get('methodName') != 'addToCart'){
        Quote reqQuote = [select Id,vlocity_cmt__PriceListId__c,TeliaSE_Record_Type_Name__c, vlocity_cmt__PriceListId__r.Name  from quote where Id =: parent.Id];
        String recType = reqQuote.TeliaSE_Record_Type_Name__c;
        List<SObject> qItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        //vlocity_cmt__PriceList__c pricelist  = [Select Id,Name from vlocity_cmt__PriceList__c where Id =: reqQuote.vlocity_cmt__PriceListId__c];
       
        //verify MC Quote - SEUtility.isRecordTypeAvailable
        if(qItemList != null && qItemList.size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.FIBER, SEUtility.QUOTE, recType)){
            
            Decimal discount;
            for(SObject qliItem : qItemList){
                QuoteLineItem qliObject = (QuoteLineItem)qliItem;
                
                if(qliObject.Fiber_Customer_Requested_Price__c != null )
                {                    
                    //changing from TeliaSE_Ceiling_Price__c to vlocity_cmt__RecurringCharge__c
                    discount= (((qliObject.vlocity_cmt__RecurringCharge__c - qliObject.Fiber_Customer_Requested_Price__c )/qliObject.vlocity_cmt__RecurringCharge__c)*100).setScale(2, RoundingMode.HALF_UP);
                    qliObject.TeliaSE_fiber_Rabatt__c = discount;
                    Decimal SalesRepProductDiscountMaxMandate = FiberDiscountMandate__c.getAll().get('SalesRep').ProductDiscountMaxMandate__c;
                    if(discount > SalesRepProductDiscountMaxMandate )
                    {
                        qliObject.TeliaSE_Flag__c=System.Label.TeliaSE_SadFace;
                        // Added as part of DC-0013 requirement
                        if(qliObject.Fiber_Customer_Requested_Price__c < qliObject.Fiber_Approved_Price__c)  
                        {
                            qliObject.TeliaSE_Flag__c = System.Label.TeliaSE_SadFace;
                        }
                        else if (qliObject.Fiber_Customer_Requested_Price__c >= qliObject.Fiber_Approved_Price__c)
                        {
                            if(discount > SalesRepProductDiscountMaxMandate  ) 
                            {
                                if(qliObject.Fiber_Customer_Requested_Price__c >= qliObject.Fiber_Approved_Price__c)
                                {
                                    qliObject.TeliaSE_Flag__c=System.Label.TeliaSE_HappyFace;
                                }
                                else 
                                {
                                    qliObject.TeliaSE_Flag__c=System.Label.TeliaSE_SadFace;
                                }
                            }
                            else
                            {
                                qliObject.TeliaSE_Flag__c = System.Label.TeliaSE_HappyFace;
                            }
                        }
                    }
                    //----------------- Added as part of DC-0013 requirement
                    else 
                    {
                        qliObject.TeliaSE_Flag__c=System.Label.TeliaSE_HappyFace;
                    }
                }
            }
        }
    }
    }
    
    private void setExternalPrice(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Map<String, Object> itemFields = new Map<String, Object>();
        SObject parent = (SObject)input.get('parent');
        List<SObject> itemList = (List<SObject>)input.get('itemList');
        List<Object> extPriceData = (List<Object>)input.get('externalPriceData');
        Map<String, String> fieldMap = (Map<String, String>)input.get('pricingVariableToFieldMap');
        String message = (String)input.get('priceDetailMessage');
        for (Object obj : extPriceData)
        {
            if (obj instanceOf Map<String, Object>)
            {
                Map<String, Object> matrixResultRow = (Map<String, Object>)obj;
                Map<String, Object> itemFieldDetails = new Map<String, Object>();
                for (String fld : fieldMap.keySet())
                {
                    String itemField = fieldMap.get(fld);
                    Map<String, Object> fieldVals = new Map<String, Object>();
                    fieldVals.put('value', matrixResultRow.get(fld));
                    fieldVals.put('detail', message);
                    itemFieldDetails.put(itemField, fieldVals);
                }
                itemFields.put(String.valueOf(matrixResultRow.get('ID')), itemFieldDetails);
            }
        }
        if (isLogging)
        {
            System.debug('itemFields: ' + JSON.serialize(itemFields));
        }
        
        if (!itemFields.isEmpty())
        {
            Type t = Type.forName('vlocity_cmt.SetCartItemExternalPriceService');
            if (t != null)
            {
                vlocity_cmt.VlocityOpenInterface externalPriceService =
                    (vlocity_cmt.VlocityOpenInterface)t.newInstance();
                Map<String, Object> externalPriceServiceInput = new Map<String, Object>();
                Map<String, Object> externalPriceServiceOutput = new Map<String, Object>();
                Map<String, Object> externalPriceServiceOptions = new Map<String, Object>();
                
                if (!itemFields.isEmpty())
                {
                    externalPriceServiceInput.put('parent', parent);
                    externalPriceServiceInput.put('itemList', itemList);
                    externalPriceServiceInput.put('itemFieldsInfo', itemFields);
                    // skip update to prevent this service from flushing to the database since the pricing plan service
                    // will update the itemList anyway, this saves one DML update
                    externalPriceServiceOptions.put('SkipUpdate', true);
                    externalPriceService.invokeMethod('setItemPrices', externalPriceServiceInput,
                                                      externalPriceServiceOutput, externalPriceServiceOptions);
                }
            }
        }
    }
    /** 
* made this method to public because in cart we are facing and issue
*/ 
    public static String getCpqConfigurationSetupValue(String setupName)
    {
        vlocity_cmt__CpqConfigurationSetup__c cpqSetup = vlocity_cmt__CpqConfigurationSetup__c.getInstance(setupName);
        String retval = null;
        if (cpqSetup != null && cpqSetup.vlocity_cmt__SetupValue__c != null && cpqSetup.vlocity_cmt__SetupValue__c.length() > 0)
        {
            retval = cpqSetup.vlocity_cmt__SetupValue__c;
        }
        return retval;
    }
    
    global static String getAttrMatrixInfoCachePartition()
    {
        String setting = getCpqConfigurationSetupValue('AttrMatrixInfoCachePartition');
        if (String.isNotBlank(setting))
        {
            setting = 'local.' + setting;
            return setting;
        }
        return null;
    }
    private static Map<String,Object> getMap()
    {
        return new Map<String,Object>();
    }
    //query builder    
    public static String queryBuilder(String obj){
        SObjectType quoteObj = Schema.getGlobalDescribe().get(obj);
        Map<String,Schema.SObjectField> objfields = quoteObj.getDescribe().fields.getMap();
        String query = 'Select ';
        Boolean firstField = true;
        List<Sobject> quoteList=new List<Sobject>();
        
        for (String field : objfields.keySet()){
            if(firstField){
                query += field;
            }else{
                query +=' , ';
                query += field;
            }
            firstField = false;
        }
        return query;
    }
    
    global class PricingPlanHelperException extends Exception{}
}