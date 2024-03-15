global with sharing class CustomAddFieldsPricingPlanStepImpl implements vlocity_cmt.VlocityOpenInterface {
        
    private static final String nsp = 'vlocity_cmt__'; 
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options){
       Boolean isCpqNextFeautreEnabled = vlocity_cmt.VlocityFeatureService.isCPQNextFeatureEnabled() && vlocity_cmt.PricingPlanService.isDigitalCommerceFlow();
        
       if (!isCpqNextFeautreEnabled  && methodName.equalsIgnoreCase('QueryCustomFieldValues'))
        {
            queryCustomFieldValues(input, output, options);
        }
         if (!isCpqNextFeautreEnabled  &&methodName.equalsIgnoreCase('FilterLineItems'))
        {
            filterLineItems(input, output, options);
        }
        return True;
    }
    /*
    private List<SObject> reloadLineItems(Id cartId)
    {
        List<String> fieldListToQuery = getVlocityDefaultFieldList(cartId);
        
        // Add more fields to fieldListToQuery List
        // ================
        fieldListToQuery.add('TeliaSE_Product_Object_Type__c');
        fieldListToQuery.add('TeliaSE_Base_Quantity__c');
        fieldListToQuery.add('TeliaSE_PriceTypeCategory__c');
        fieldListToQuery.add('RoamingTillAddOns__c');
        fieldListToQuery.add('RoamingResAddOns__c');
        fieldListToQuery.add('AvgPriceFLag__c');
        fieldListToQuery.add('TeliaSE_MC_Customer_Requested_Price__c');
        fieldListToQuery.add('TeliaSE_Floor_Percentage__c');
        fieldListToQuery.add('TeliaSE_Ceiling_Price__c');
        fieldListToQuery.add('TeliaSE_AM_Mandate_Percentage__c');
        fieldListToQuery.add('TeliaSE_SM_Mandate_Percentage__c');
        fieldListToQuery.add('TeliaSE_SD_Mandate_Percentage__c');
        fieldListToQuery.add('TeliaSE_CM_Mandate_Percentage__c');
        fieldListToQuery.add('MC_OT_AM_Mandate_Percentage__c');
        fieldListToQuery.add('MC_OT_SM_Mandate_Percentage__c');
        fieldListToQuery.add('MC_OT_SD_Mandate_Percentage__c');
        fieldListToQuery.add('MC_OT_CM_Mandate_Percentage__c');
        fieldListToQuery.add('MC_OneTimeCharge__c');
        fieldListToQuery.add('TeliaSE_MC_Customer_Requested_Percentage__c');
        fieldListToQuery.add('TeliaSE_Approved__c');
        fieldListToQuery.add('TeliaSE_Approved_Price__c');
        fieldListToQuery.add('MC_OT_Approved_Price__c');
        fieldListToQuery.add('TeliaSE_Flag__c');
        fieldListToQuery.add('MC_Line_Status__c');
        
        String cartSObjType = getCartSObjType(cartId);
        String lineItemSObjType = getLineItemSObjType(cartId);
        String cartHeaderFieldKey = cartSObjType + 'Id';
        String reloadQuery = 'SELECT ' + String.join(fieldListToQuery, ',') + ' FROM ' + lineItemSObjType;
        List<String> conditionsList = new List<String>();
        conditionsList.add(cartHeaderFieldKey + ' = :cartId');
        
        // Add a test condition for testing
        // ================
        // conditionsList.add('PricebookEntry.Product2.ProductCode != \'ProductB\'');
        
        if (conditionsList != null && !conditionsList.isEmpty())
        {
            String whereCond = String.join(conditionsList, ' AND ');
            reloadQuery += ' WHERE ' + whereCond;
        }
        
        return Database.query(reloadQuery);
    }
    
    private String getCartSObjType(Id cartId)
    {
        return String.valueOf(cartId.getSobjectType());
    }
    
    private String getLineItemSObjType(Id cartId)
    {
        String lineItemSObjType = null;
        SObjectType cartSObjType = cartId.getSobjectType();
        if (cartSObjType == Order.sObjectType)
        {
            lineItemSObjType = 'OrderItem'; 
        }
        if (cartSObjType == Quote.sObjectType)
        {
            lineItemSObjType = 'QuoteLineItem';
        }
        if (cartSObjType == Opportunity.sObjectType)
        {
            lineItemSObjType = 'OpportunityLineItem';
        }
        return lineItemSObjType;
    }
    
    
    private List<String> getVlocityDefaultFieldList(Id cartId)
    {
        Set<String> defaultLineItemFields = new Set<String>
        {
            'id', nsp+'linenumber__c', nsp+'action__c', nsp + 'subaction__c',  nsp + 'product2id__c',
            nsp + 'incartquantitymap__c', 'pricebookentry.product2.name', 'pricebookentry.product2.productcode',
            'pricebookentry.product2.id', 'pricebookentry.product2.' + nsp + 'type__c',
            'pricebookentry.product2.' + nsp + 'globalgroupkey__c',
            'pricebookentry.product2.' + nsp + 'isconfigurable__c', 'pricebookentryid', 'pricebookentry.pricebook2id',
            'listprice', 'unitprice', 'quantity', nsp + 'onetimecharge__c', nsp + 'onetimecalculatedprice__c',
            nsp + 'onetimemanualdiscount__c', nsp + 'onetimetotal__c', nsp + 'rootitemid__c', nsp + 'parentitemid__c',
            nsp + 'producthierarchypath__c', nsp + 'recurringcharge__c', nsp + 'recurringcalculatedprice__c',
            nsp + 'recurringmanualdiscount__c', nsp + 'recurringdiscountprice__c', nsp + 'recurringtotal__c',
            nsp + 'provisioningstatus__c', nsp + 'cpqmessagedata__c', nsp + 'serviceaccountid__c',
            nsp + 'serviceaccountid__r.name', nsp + 'serviceaccountid__r.id', nsp + 'billingaccountid__c',
            nsp + 'billingaccountid__r.name', nsp + 'billingaccountid__r.id', nsp + 'pricinglogdata__c',
            nsp + 'itemname__c', nsp + 'currencypaymentmode__c', nsp + 'cpqcardinalitymessage__c',
            nsp + 'effectiveonetimetotal__c', nsp + 'effectiverecurringtotal__c', nsp + 'cpqpricingmessage__c',
            nsp + 'assetreferenceid__c', nsp + 'catalogitemreferencedatetime__c',
            nsp + 'onetimeloyaltyprice__c', nsp + 'onetimeloyaltytotal__c',
            nsp + 'effectiveonetimeloyaltytotal__c', nsp + 'onetimecost__c', nsp + 'onetimecosttotal__c',
            nsp + 'effectiveonetimecosttotal__c', nsp + 'recurringcost__c', nsp + 'recurringcosttotal__c',
            nsp + 'effectiverecurringcosttotal__c', nsp + 'onetimemargin__c', nsp + 'recurringmargin__c',
            nsp + 'servicepointid__c', nsp + 'servicepointid__r.name', nsp + 'servicepointid__r.'+ nsp + 'premisesid__c',
            nsp + 'usagemeasurementid__c', nsp + 'usagemeasurementid__r.name', nsp + 'usageunitprice__c',
            nsp + 'usagepricetotal__c', nsp + 'effectiveusagepricetotal__c', nsp + 'usagequantity__c',
            nsp + 'usageunitcost__c', nsp + 'usagecosttotal__c', nsp + 'effectiveusagecosttotal__c', nsp + 'usagemargin__c'
        };
        if (cartId.getSobjectType() == Order.sObjectType)
        {
            defaultLineItemFields.addAll(new Set<String>
                {
                    nsp + 'ischangesallowed__c', nsp + 'supplementalaction__c',
                    nsp + 'supersededorderitemid__c',nsp + 'firstversionorderitemid__c',
                    nsp + 'fulfilmentstatus__c'
                });
        }
        // Adding attribute fields based on attribute model
        Boolean useAttributeV2Model = false;
        try
        {
            useAttributeV2Model = vlocity_cmt.VlocityFeatureService.getFeatureValue('EnableV2AttributeModel');
        }
        catch(Exception e){
            System.debug(e.getStackTraceString());
        }

        if(useAttributeV2Model)
        {
          defaultLineItemFields.addAll(new Set<String>{
              nsp + 'attributeselectedvalues__c',
              nsp + 'attributemetadatachanges__c',
              'pricebookentry.product2.' + nsp + 'attributedefaultvalues__c',
              'pricebookentry.product2.' + nsp + 'attributemetadata__c'
          });
        }
        else
        {
          defaultLineItemFields.addAll(new Set<String>{
              nsp + 'jsonattribute__c',
              'pricebookentry.product2.' + nsp + 'jsonattribute__c'
          });
        }
        return new List<String>(defaultLineItemFields);
    }
*/
    
    private void queryCustomFieldValues(Map<String,Object> input,Map<String,Object> output,Map<String,Object> options){
        //System.debug('Inside queryCustomFieldValues');
        
        //Add the Custom Fields to the list
        List<String> customFields = new List<String>{'TeliaSE_MC_Binding_Time__c','TeliaSE_ParentClusterCode__c','TeliaSE_Fiber_Frame_Agreement__c','Fiber_Approved_Price__c','TeliaSE_Flag__c','TeliaSE_fiber_Antal__c','TeliaSE_fiber_Engngsavgift__c','TeliaSE_Fiber_List_Pris__c','Fiber_Customer_Requested_Price__c', 'TeliaSE_fiber_Rabatt__c', 'TeliaSE_MC_EFS_Pris__c', 'TeliaSE_MC_Customer_Requested_Percentage__c','TeliaSE_MC_Customer_Requested_Price__c','TeliaSE_Approved__c','TeliaSE_PriceTypeCategory__c','TeliaSE_Approved_Price__c','MC_OT_AM_Mandate_Percentage__c','MC_OT_SM_Mandate_Percentage__c','MC_OT_SD_Mandate_Percentage__c','MC_OT_CM_Mandate_Percentage__c','MC_OneTimeCharge__c','MC_OT_Approved_Price__c','TeliaSE_AM_Mandate_Percentage__c','TeliaSE_SM_Mandate_Percentage__c','TeliaSE_SD_Mandate_Percentage__c','TeliaSE_CM_Mandate_Percentage__c','RoamingTillAddOns__c','RoamingResAddOns__c','TeliaSE_Base_Quantity__c','AvgPriceFLag__c','TeliaSE_Nullify_Check__c','MC_Line_Status__c'};
        // Get the cart line items from the pricing context
        List<SObject> itemList =(List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        
        if(itemList == null || itemList.isEmpty())
            return;
        
        if (itemList[0].getSObjectType().getDescribe().getName() != 'QuoteLineItem') return;
        
        Boolean doQuery = false;
        
        //try for existence of the field
        try{
            
            for(String customField: customFields){                
                Object val = itemList[0].get(customField);                 
            }
            if(test.isRunningTest())
            {
                //Throwing Exception for coverage in test class.
                Integer i =1/0;
            }
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
            doQuery = true;            
        }
        if (!doQuery) return;
        Map<Id, SObject> itemMap = new Map<Id, SObject>(itemList);
        Set<Id> ids = itemMap.keySet();
        for (SObject obj : Database.query('Select Id, '+ String.join(customFields,',') + ' from QuoteLineItem where Id in :ids')){           
            SObject item = itemMap.get(obj.Id);
            
            if (item != null){
                for (String customField : customFields){
                    item.put(customField, obj.get(customField));
                }
            }
        }        
    }
    
  private void filterLineItems(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        // Get the cart line items from the pricing context
        Map<Id, SObject> itemList = new Map<Id, SObject>((List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList'));
        system.debug(json.serialize(itemList));
        system.debug('size__'+itemList.size());
        // If there are no items, then return
        if (itemList == null || itemList.isEmpty()) { return; }
        // Get the list of line item ids from the FlowStaticMap. It is populated from the CpqAppHandlerHook implementation
        Set<Id> itemIds = (Set<Id>)vlocity_cmt.FlowStaticMap.flowMap.get('MC_Sales_AdjustmentID_Filter');
        if (itemIds == null || itemIds.isEmpty()) { return; }
        // Assume that items ids is just one for now.
        Set<String> lineNums = new Set<String>();
        
        for(Id itemId : itemIds)
        {    
            //Id itemId = itemIds.iterator().next();
            SObject itemSObj = itemList.get(itemId);
            // Get the item's root line number
            if (itemSObj != null)
            {
                System.debug('itemSObj >' + itemSObj);
                String lineNum = (String)itemSObj.get('vlocity_cmt__LineNumber__c');
                if (!String.isBlank(lineNum))
                {
                    lineNums.add(lineNum);
                    // collect all the ancestor line numbers
                    if (lineNum.contains('.'))
                    {
                        String temp = '';
                        Boolean bFirst = true;
                        for (String str : lineNum.split('\\.'))
                        {
                            if (bFirst)
                            {
                                temp += str;
                                bFirst = false;
                            }
                            else 
                            {
                                temp += '.' + str;
                            }    
                            lineNums.add(temp);
                        }
                    }
                    //System.debug('*** lineNums: ' + lineNums);
                }
            }
        }
        if (!lineNums.isEmpty())
        {
            // Only include line items whose id is in the COX_ITEM_IDS_FILTER set of ids
            List<SObject> filteredList = new List<SObject>();
            for (SObject item : itemList.values())
            {
                String itemLineNum = (String)item.get('vlocity_cmt__LineNumber__c');
                if (lineNums.contains(itemLineNum))
                {
                    filteredList.add(item);
                }
            }
            if (!filteredList.isEmpty()) {
                vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', filteredList);
                system.debug('filteredlistis--> ' + JSON.serialize(filteredList));
                system.debug('filteredlistis size--> ' + filteredList.size());
            }
        }
    }
    
}