global with sharing class CustomPricingPlanStepImpl implements vlocity_cmt.VlocityOpenInterface {
    
    private static String nsp = 'vlocity_cmt__',recordTypeDeveloperName = '';
    global Boolean invokeMethod (String methodName,Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
       
        try{
            SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');  
            if(parent.getSObjectType() == Quote.sObjectType){
                recordTypeDeveloperName = (String)Schema.SObjectType.Quote.getRecordTypeInfosById().get((String)parent.get('RecordTypeId')).getDevelopername();
            }//this is add to cart, skip ABP and exit method
            if(vlocity_cmt.FlowStaticMap.flowMap.containsKey('methodName') && //changed to methodName after assetRefId implementation
               (vlocity_cmt.FlowStaticMap.flowMap.get('methodName') == 'addToCart' || vlocity_cmt.FlowStaticMap.flowMap.get('CPQAction') == 'ErrorRequest' ||  
               (vlocity_cmt.FlowStaticMap.flowMap.get('CPQAction') == 'deleteCartsItems' && parent.getSObjectType() == Quote.sObjectType 
                && String.isNotBlank(recordTypeDeveloperName) && recordTypeDeveloperName == 'Contract'))){ // Restrict pricing for DeleteCart items in FA cart
                    //system.debug(LoggingLevel.ERROR, 'this is add to cart, skip ABP and exit method');
                    return true;
                }
            if (methodName == 'GetMatrixPrice'){
                getMatrixPrice(input, output, options);
            }        
            return true;
        }
        catch (Exception ex){
            //System.debug(LoggingLevel.ERROR, ex);
            //System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            output.put('error', ex.getMessage());
            return false;
        }
    }
    
    private void getMatrixPrice(Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        List<SObject> itemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        Set<String> rootItemId = new Set<String>();
        Map<Id,String> rootItemObjectTypeMap = new Map<Id,String>();
        Boolean individualFlag = false;
        List<SObject> itemListFiltered = new List<Sobject>();
        Set<Integer> hierarchyPathList = new set<Integer>();
        if(itemList.size()> 0 && parent.getSObjectType() == Quote.sObjectType){
            for(sObject item: itemList){                
                QuoteLineItem qItem = (QuoteLineitem)item;               
                rootItemId.add((String)qItem.vlocity_cmt__RootItemId__c);
                if((String)qItem.vlocity_cmt__AssetReferenceId__c ==(String)qItem.vlocity_cmt__RootItemId__c){
                    itemListFiltered.add(item);                   
                }
                if(!test.isRunningTest()){
                    Integer hierarchySize = qItem.vlocity_cmt__ProductHierarchyPath__c.split('<').size();
                    if(hierarchyPathList.contains(hierarchySize)){
                        individualFlag = true;
                    }
                    else{
                        hierarchyPathList.add(hierarchySize);
                    }
                }
            }
            if(individualFlag){
                itemList = itemListFiltered;
            }
        }
        //If Asset or if there are no items, then return
        if(parent == null || itemList == null || itemList.isEmpty()) return;
       
        String sourceTargetABP = 'false';
        String strDelta = PricingPlanHelper.getCpqConfigurationSetupValue('DeltaPrice');
        if(test.isRunningTest()){
            individualFlag = true;
        }
        //CMT-3332 : If Delta Price is TRUE and if source target attribute based pricing is being done, then load all the line items
        if(individualFlag || hierarchyPathList.size() == 1)
        {
            // If UOWMode is TRUE then changes in lineitems are not committed and re-querying the lineitems will result in
            // loss of those changes, so overwriting the queried lineitems with lineitems present in Pricing Context
            List<SObject> allItemList = getAllLineItems(parent, parent.getSObjectType(), itemList[0].getSObjectType(),rootItemId,rootItemObjectTypeMap);
            Map<String, SObject> allItemIdToItemMap = new Map<String, SObject> (allItemList);
            allItemIdToItemMap.putAll(itemList);
            itemList = allItemIdToItemMap.values();
            vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',itemList);
        }
        // If this is the first getMatrixPrice step, clear the external price flag
        Boolean clearExternalPriceFlag = (Boolean)vlocity_cmt.PricingPlanService.getFromPricingContext('ClearExternalPriceFlag');
        if (clearExternalPriceFlag == null)
        {
            clearExternalPriceFlag = true;
            // Do not clear the external price flag for subsequent calls to getMatrixPrice
            vlocity_cmt.PricingPlanService.putInPricingContext('ClearExternalPriceFlag', false);
        }
        
        Map<String, object> priceHelperInput = new Map<String, object>();
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        priceHelperInput.put('Parent', parent);
        priceHelperInput.put('ItemList', itemList);
        priceHelperInput.put('ClearExternalPriceFlag', clearExternalPriceFlag);
        priceHelperInput.put('individualFlag', individualFlag);//Added by Abhishek for validera improvemnt
        priceHelperInput.putAll(input);
        // create the matrix input rows from the itemList
        PricingPlanHelper priceHelper = new PricingPlanHelper();
        priceHelper.invokeMethod('GetCalculationProcedurePrice', priceHelperInput, priceHelperOutput, priceHelperOptions);
        
        if (priceHelperOutput.get('error') != null){
            output.put('error', priceHelperOutput.get('error'));
        }
    }
    
    private List<SObject> getAllLineItems(SObject parent, SobjectType parentObjectTypeForPage, SObjectType lineItemTypeForPage,Set<String> rootItemId,Map<Id,String> rootItemObjectTypeMap)
    {
        Id parentId = (Id)parent.get('Id');
        Set<String> defaultLineItemFields = new set<String>{'pricebookentry.product2.name', 'pricebookentry.product2.productcode',
            'pricebookentry.product2.id', 'pricebookentry.product2.' + nsp + 'type__c',
            'pricebookentry.product2.' + nsp + 'globalgroupkey__c',
            'pricebookentry.product2.' + nsp + 'isconfigurable__c', 'pricebookentryid', 'pricebookentry.pricebook2id'};
                if (parentObjectTypeForPage == Order.sObjectType){
                    SObjectType quoteObj = Schema.getGlobalDescribe().get('OrderItem');
                    Map<String,Schema.SObjectField> objfields = quoteObj.getDescribe().fields.getMap();
                    defaultLineItemFields.addAll(objfields.keySet());
                    defaultLineItemFields.addAll(new Set<String>
                                                 {
                                                     nsp + 'ischangesallowed__c', nsp + 'supplementalaction__c',
                                                         nsp + 'supersededorderitemid__c',nsp + 'firstversionorderitemid__c',
                                                         nsp + 'fulfilmentstatus__c'
                                                         });
                }
        else{
            SObjectType quoteObj = Schema.getGlobalDescribe().get('QuoteLineItem');
            Map<String,Schema.SObjectField> objfields = quoteObj.getDescribe().fields.getMap();
            defaultLineItemFields.addAll(objfields.keySet());
        }
        
        Boolean useAttributeV2Model = false;
        try {
            useAttributeV2Model = vlocity_cmt.VlocityFeatureService.getFeatureValue('EnableV2AttributeModel');
        }
        catch(Exception e){
            //System.debug(e.getStackTraceString());
        }
        
        if(useAttributeV2Model){
            defaultLineItemFields.addAll(new Set<String>{
                nsp + 'attributeselectedvalues__c',
                    nsp + 'attributemetadatachanges__c',
                    'pricebookentry.product2.' + nsp + 'attributedefaultvalues__c',
                    'pricebookentry.product2.' + nsp + 'attributemetadata__c'
                    });
        } 
        else{
            defaultLineItemFields.addAll(new Set<String>{
                nsp + 'jsonattribute__c',
                    'pricebookentry.product2.' + nsp + 'jsonattribute__c'
                    });
        }
        
        List<String> finalfieldList = new List<String>();
        finalfieldList.addAll(defaultLineItemFields);
        String extractQuery = 'SELECT ' + String.join(finalfieldList, ',') +
            ' FROM ' + String.escapeSingleQuotes(String.valueOf(lineItemTypeForPage)) + ' WHERE ' + String.escapeSingleQuotes(String.valueOf(parentObjectTypeForPage)) + 'Id = :parentId';
        
        if(rootItemId.size() > 0){
            extractQuery = extractQuery + ' and '+ 'vlocity_cmt__RootItemId__c IN: rootItemId';
        } 
        if(parentObjectTypeForPage == Quote.sObjectType && recordTypeDeveloperName != 'Offer'){
            extractQuery = extractQuery + ' and '+ 'vlocity_cmt__Product2Id__r.TeliaSE_Price_Flag__c = true';
        }
        List<SObject> sobjectExtract = Database.query(extractQuery);
        return sobjectExtract;
    }
}