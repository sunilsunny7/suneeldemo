global with sharing class CpqNextPricingPlanHelper extends PricingPlanHelper{
    
    private vlocity_cmt.CpqCartDocument cartDocument;
    private Map<String, vlocity_cmt.CpqCartDocumentItem> itemWrapperMap;
    
    global override void initializeParentAndLineItems(Map<String, Object> input)
    {
        cartDocument = (vlocity_cmt.CpqCartDocument) input.get('cartDocument');
        Map<String, Object> outputMap = cartDocument.call('getAllItems', new Map<String, Object>{ 'hierarchyLevel'=>-1});
        itemWrapperMap = (Map<String, vlocity_cmt.CpqCartDocumentItem>) outputMap.get('result');
        if(hasLineItems())
        {
            for(String itemId: itemWrapperMap.keySet())
            {
                vlocity_cmt.CpqCartDocumentItem item = itemWrapperMap.get(itemId);
                Map<String, Object> output = item.call('getItemField', new Map<String, Object>{'field'=>NSP + 'LineNumber__c'});
                String itemLineNumber = (String) output.get('result');
                if(!String.isBlank(itemLineNumber))
                {
                    lineNumberToItem.put(itemLineNumber, item);
                }
                else
                {
                    System.debug(LoggingLevel.ERROR, 'Line Number missing for line item with Id ' + itemId);
                    throw new PricingPlanHelperException('Line Number missing for line item with Id ' + itemId);
                }
            }
        }
    }

    global override boolean hasLineItems()
    {
        return (itemWrapperMap != null && !itemWrapperMap.isEmpty());
    }

    global override void clearExternalPriceFlag()
    {
        cartDocument.call('clearExternalPrice', null);
    }

    global override void populatePathMappings()
    {
        if (hasLineItems())
        {
            Map<String, String> parentLineNums = new Map<String, String>();
            for (String lineNum: lineNumberToItem.keySet())
            {
                Integer index = lineNum.lastIndexOf('.');
                if (index > 0)
                {
                    String parentLineNum = lineNum.substring(0, index);
                    parentLineNums.put(lineNum, parentLineNum);
                }
                else
                {
                    parentLineNums.put(lineNum, '');
                }

                vlocity_cmt.CpqCartDocumentItem item = (vlocity_cmt.CpqCartDocumentItem)lineNumberToItem.get(lineNum);
                Map<String, Object> output = item.call('getItemField', new Map<String, Object>{'field' => 'name'});
                String productName = (String)output.get('result');
                List<String> items = prodNameToItems.get(productName);
                if (items == null)
                {
                    items = new List<String>();
                    prodNameToItems.put(productName, items);
                }
                items.add(lineNum);

            }

            if (!productPathMapping.isEmpty())
            {
                for (String lineNum : lineNumberToItem.keySet())
                {
                    vlocity_cmt.CpqCartDocumentItem item = (vlocity_cmt.CpqCartDocumentItem)lineNumberToItem.get(lineNum);
                    Map<String, Object> output = item.call('getItemField',new Map<String, Object>{'field' => 'name'});

                    String productName = (String) output.get('result');

                    String productPath = productName;

                    String parentLineNum = parentLineNums.get(lineNum);

                    while (String.isNotBlank(parentLineNum))
                    {
                        vlocity_cmt.CpqCartDocumentItem parentItem = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(parentLineNum);
                        output = parentItem.call('getItemField', new Map<String, Object>{'field' => 'name'});
                        productName = (String)output.get('result');
                        productPath = productName + '<' + productPath;
                        parentLineNum = parentLineNums.get(parentLineNum);
                    }
                    String pathKey = (String)productPathMapping.get(productPath);                    
                    if (String.isNotBlank(pathKey))
                    {
                        lineNumberToPathKeyMapping.put(lineNum, pathKey);
                    }
                }
            }
        }
    }

    global override List<Object> prepareInputMap()
    {
        List<Object> result = new List<Object>();
        Set<String> rangeFields = new Set<String>{NSP + 'AssetReferenceId__c', NSP + 'LineNumber__c', 'Quantity', productCodeField, 'name'};
        for(Object productCodeToRangeFields: rangeFieldMapping.values())
        {
            rangeFields.addAll(((Map<String, Object>) productCodeToRangeFields).keySet());
        }
        for (String lineNumber: lineNumberToItem.keySet())
        {
            vlocity_cmt.CpqCartDocumentItem item = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(lineNumber);
            Map<String, Object> output = item.call('getItemFields', new Map<String, Object>{'fields' => rangeFields});

            Map<String, Object> currentRowVals = (Map<String, Object>) output.get('result');

            String productCode = (String)currentRowVals.get(productCodeField);
            // TODO: add a product name field mapping
            String productName = (String)currentRowVals.get('name');
            Object quantity = currentRowVals.get('Quantity');
            
            //If the given Product Code is not present in Matrix, no need to process it.
            if(!productCodeSet.contains(productCode))
            {
                continue;
            }

            if (!lineNumberToPathKeyMapping.isEmpty())
            {
                productName = replaceNameWithPath(productName, lineNumber);
            }

            output = item.call('getItemAttributes',new Map<String, Object>{'flattenedAttributeValues'=>true, 'useDisplayTextForValues'=>useDisplayTextForValues});

            result.addAll(prepareRowDataMap(productCode, productName, currentRowVals, (Map<String, Object>) output.get('result')));
            
        }
        return result;
    }

    global override Map<String, Object> replaceNumberWithId(String targetLineNumber, Map<String, Object> matrixResultRow, Boolean bFirst)
    {
        if(String.isBlank(targetLineNumber))
        {
            if(String.isBlank(targetLineNumber))
            {
                targetLineNumber = (String) matrixResultRow.get('ID');
            }
        }
        vlocity_cmt.CpqCartDocumentItem targetItem = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(targetLineNumber);
        Map<String, Object> output = targetItem.call('getItemField', new Map<String, Object>{'field' => 'vlocity_cmt__AssetReferenceId__c'});
        String targetItemId = (String) output.get('result');
        if(bFirst)
        {
            matrixResultRow.put('ID', targetItemId);
            return matrixResultRow;
        }
        else
        {
            Map<String, Object> clonedRow = matrixResultRow.clone();
            clonedRow.put('ID', targetItemId);
            return clonedRow;
        }
    }


    global override void setExternalPrice(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Map<String, Object> itemFields = new Map<String, Object>();
        List<Object> extPriceData = (List<Object>)input.get('externalPriceData');
        Map<String, String> pricingVariableToFieldMap = (Map<String, String>)input.get('pricingVariableToFieldMap');
        List<Object> timePlanPolicyList = (List<Object>)input.get('timePlanPolicyList');
        String message = (String)input.get('priceDetailMessage');
        Map<String, Id> unitOfMeasureToIdMap = (Map<String, Id>) input.get('unitOfMeasureToIdMap');
        Map<String, String> lineItemIdToUOM = new Map<String, String>();
        List<vlocity_cmt.CpqCartDocumentItem> updatedItemList = new List<vlocity_cmt.CpqCartDocumentItem>();


        if(extPriceData != null)
        {
            for (Object obj : extPriceData)
            {
                if (obj instanceOf Map<String, Object>)
                {
                    Map<String, Object> matrixResultRow = (Map<String, Object>)obj;
                    Map<String, Object> itemFieldDetails = new Map<String, Object>();
                    for (String fld : pricingVariableToFieldMap.keySet())
                    {
                        String itemField = pricingVariableToFieldMap.get(fld);
                        Map<String, Object> fieldVals = new Map<String, Object>();
                        fieldVals.put('value', matrixResultRow.get(fld));
                        fieldVals.put('detail', message);
                        fieldVals.put('source', 'ABP');
                        fieldVals.put('code', fld);
                        itemFieldDetails.put(vlocity_cmt.CpqCartDocumentUtils.getInternalItemField(itemField), fieldVals);
                    }
                    itemFields.put(String.valueOf(matrixResultRow.get('ID')), itemFieldDetails);

                    //only for UOM
                    String uom = String.valueOf(matrixResultRow.get('UOM'));
                    if(String.isNotBlank(uom))
                    {
                        lineItemIdToUOM.put((Id)matrixResultRow.get('ID'), uom);
                    }
                }
            }
            if (isLogging)
            {
                System.debug('itemFields: ' + JSON.serialize(itemFields));
            }
        }
        //TODO: set price from UOM

        if (!itemFields.isEmpty())
        {
            if (itemWrapperMap != null && !itemWrapperMap.isEmpty())
            {
                Map<String, Object> externalPriceArgs = new Map<String, Object>();
                externalPriceArgs.put('pricingVariableToFieldMap', pricingVariableToFieldMap);
                externalPriceArgs.put('itemFieldsInfo', itemFields);
                externalPriceArgs.put('timePlanPolicyList', timePlanPolicyList);
                
                Map<String, Object> priceOutput = cartDocument.call('setExternalPrice', externalPriceArgs);
            }
        }
    }


    global override String getProductName(String lineNumber)
    {
        vlocity_cmt.CpqCartDocumentItem lineItem = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(lineNumber);
        Map<String, Object> output = lineItem.call('getItemField', new Map<String, Object>{'field'=>'name'});
        return (String) output.get('result');
    }

    global override Object getItemField(String lineNumber, String field)
    {
        vlocity_cmt.CpqCartDocumentItem lineItem = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(lineNumber);
        Map<String, Object> output = lineItem.call('getItemField', new Map<String, Object>{'field'=>field});
        return (String) output.get('result');
    }
}