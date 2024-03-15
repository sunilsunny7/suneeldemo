global class UpdateLineItems implements vlocity_cmt.VlocityOpenInterface2
{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) 
    {
        Boolean result = true ;
        String error_message = '';
        try{
            if(methodName.equalsIgnoreCase('changeProduct'))
            {
                changeProduct(inputMap, outMap);
            }
        }
        catch(Exception e) 
        {
            error_message = e.getMessage()+' line:'+ e.getLineNumber();
            system.debug(e.getStackTraceString());
            outMap.put('Error', e.getStackTraceString());
        }
        return result;
    }
    private void changeProduct(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        String oldProductCode = (string)inputMap.get('oldProductCode');
        String newProductCode = (string)inputMap.get('newProductCode');
        Boolean quoteFlag = false;
        Boolean contractFlag = false;
        Set<String> qitemId = new Set<String>();
        Set<String> citemId = new Set<String>();
        Map<String, Object> ErrorResponse = new Map<String, Object>();
        List<vlocity_cmt__ContractLineItem__c> citems = new List<vlocity_cmt__ContractLineItem__c>();
        List<QuoteLineItem> qitems = new List<QuoteLineItem>();
        List<SObject> totalList = new List<SObject>();
        PricebookEntry[] pricebooknew = [Select id, Name, Product2.vlocity_cmt__IsOrderable__c from PricebookEntry Where Product2.ProductCode =: newProductCode AND Product2.vlocity_cmt__IsOrderable__c = true LIMIT 1];
        Product2[] newid = [select id, Name from Product2 where ProductCode =: newProductCode and vlocity_cmt__Status__c = 'Active' and IsActive = true and vlocity_cmt__IsOrderable__c = true LIMIT 1];
        Product2[] oldid = [select id, Name,vlocity_cmt__IsOrderable__c,vlocity_cmt__Status__c,IsActive from Product2 where ProductCode =: oldProductCode and vlocity_cmt__Status__c = 'Active' and IsActive = true and vlocity_cmt__IsOrderable__c = true LIMIT 1];
        system.debug('OldProductList ->'+oldid);
        system.debug('NewProductList ->'+newid);
        
        if(newid.size() == 0)
        {
            ErrorResponse.put('errorCode','INVALID_NEW_PRODUCTCODE');                     
            ErrorResponse.put('error','Incorrect newProductCode or product is not active');
            ErrorResponse.put('success',false);
            
            outMap.put('ErrorResponse',ErrorResponse);
        }
        else if(oldid.size() == 0){
            ErrorResponse.put('errorCode','INVALID_OLD_PRODUCTCODE');                     
            ErrorResponse.put('error','Incorrect oldProductCode or product is not active');
            ErrorResponse.put('success',false);
            outMap.put('ErrorResponse',ErrorResponse);
        }
        else{
            system.debug('OldProductList ->'+oldid);
            system.debug('NewProductList ->'+newid);
            for(QuoteLineItem items : [select id,vlocity_cmt__Product2Id__c,vlocity_cmt__InCartQuantityMap__c,vlocity_cmt__ProductHierarchyPath__c   from QuoteLineItem where vlocity_cmt__Product2Id__r.ProductCode  =: oldProductCode])
            {
                system.debug(items);
                if(String.valueOf(items.vlocity_cmt__ProductHierarchyPath__c) != null && String.valueOf(items.vlocity_cmt__ProductHierarchyPath__c).Contains(items.vlocity_cmt__Product2Id__c)){
                    items.vlocity_cmt__ProductHierarchyPath__c = String.valueOf(items.vlocity_cmt__ProductHierarchyPath__c).replace(items.vlocity_cmt__Product2Id__c,  newid[0].id);                    
                }
                if(String.valueOf(items.vlocity_cmt__InCartQuantityMap__c) != null && String.valueOf(items.vlocity_cmt__InCartQuantityMap__c).Contains(items.vlocity_cmt__Product2Id__c)){
                    items.vlocity_cmt__InCartQuantityMap__c = String.valueOf(items.vlocity_cmt__InCartQuantityMap__c).replace(items.vlocity_cmt__Product2Id__c,  newid[0].id);                        
                }
            
                items.vlocity_cmt__Product2Id__c= newid[0].id;
                items.Product2Id= newid[0].id;
                qitems.add(items);
                totalList.add(items);
            }
            if(qitems.size() > 0)
            {
                //totalList.add(qitems);
                quoteFlag = true;
                //Database.executeBatch(new QuoteLineItemUpdate_Batch(qitems, quoteFlag));
                //Database.Update(qitems, false);
            }
        
            for(vlocity_cmt__ContractLineItem__c cr: [select id,vlocity_cmt__Product2Id__c,vlocity_cmt__PricingLogData__c, vlocity_cmt__ProductName__c, Name, TeliaSE_ProductHierarchy__c  from vlocity_cmt__ContractLineItem__c where vlocity_cmt__Product2Id__r.ProductCode  =: oldProductCode])
            {
                if(String.valueOf(cr.TeliaSE_ProductHierarchy__c) !=null && String.valueOf(cr.TeliaSE_ProductHierarchy__c).Contains(cr.vlocity_cmt__Product2Id__c)){
                    
                    cr.TeliaSE_ProductHierarchy__c = String.valueOf(cr.TeliaSE_ProductHierarchy__c).replace(cr.vlocity_cmt__Product2Id__c,  newid[0].id);
                    
                }
                if(String.valueOf(cr.vlocity_cmt__PricingLogData__c) !=null && String.valueOf(cr.vlocity_cmt__PricingLogData__c).Contains(cr.vlocity_cmt__Product2Id__c)){
                    
                    cr.vlocity_cmt__PricingLogData__c = String.valueOf(cr.vlocity_cmt__PricingLogData__c).replace(cr.vlocity_cmt__Product2Id__c,  newid[0].id);
                    
                }
            
                cr.vlocity_cmt__Product2Id__c = newid[0].id;
                cr.Name = newid[0].Name;
                citems.add(cr);
                totalList.add(cr);
            }
            if(citems.size() > 0)
            {
                //totalList.add(citems);
                contractFlag = true;
                //Database.executeBatch(new ContractLineItemUpdate_Batch(citems, contractFlag, oldid.id));
                //Database.Update(citems, false);
            }
            if(quoteFlag){
               for(QuoteLineItem items : qitems){
                qitemId.add(items.Id);
                } 
                outMap.put('QuoteLineItemId',qitemId);
            }
            if(contractFlag){
                for(vlocity_cmt__ContractLineItem__c items : citems){
                citemId.add(items.Id);
                }
                outMap.put('ContractLineItemId',citemId);
            }  
            if(totalList.size() > 0){
                Database.executeBatch(new ContractLineItemUpdate_Batch(totalList, contractFlag, oldid[0].id));
            }
            //deActivateProduct(oldid.id);

        }
        
       outMap.put('success',true); 
        
    }
    
}