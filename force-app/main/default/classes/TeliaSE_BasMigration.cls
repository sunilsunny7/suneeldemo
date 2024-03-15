global class TeliaSE_BasMigration implements vlocity_cmt.VlocityOpenInterface{
    
    global static boolean  invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('createBackUp')) {
                TeliaSE_BasMigration.createBackupQuote(inputMap,outMap);
            }
            else if(methodName.equalsIgnoreCase('deleteJobSurf'))
            {
                TeliaSE_BasMigration.deleteJobSurf(inputMap,outMap,options);
            }
            else if(methodName.equalsIgnoreCase('addDataPaket'))
            {
                TeliaSE_BasMigration.addDataPaket(inputMap,outMap,options);
            }
            else if(methodName.equalsIgnoreCase('mergeFromBackup'))
            {
                TeliaSE_BasMigration.mergeFromBackup(inputMap,outMap,options);
            }
            else if(methodName.equalsIgnoreCase('createBackupContract'))
            {
                TeliaSE_BasMigration.createBackupContract(inputMap,outMap,options);
            }
            else if(methodName.equalsIgnoreCase('mergeFromBackupContract'))
            {
                TeliaSE_BasMigration.mergeFromBackupContract(inputMap,outMap,options);
            }
        }
        catch(Exception e)
        {
            system.debug('Exception e');
        }
        return result;
    }
    
    //Create backup quotes
    global static void createBackupQuote(Map<String,Object> inputMap, Map<String,Object> outMap){
        try {
            String quoteId = String.valueOf(inputMap.get('QuoteId'));
            Boolean status = Approval.isLocked(quoteId);
            outMap.put('isLocked', status); //checking Locked status
            String query=queryBuilder('Quote');
            query += ' FROM Quote WHERE '+'id=\'' + String.escapeSingleQuotes(quoteId)+'\'';
            List<Quote> data=  Database.query(query);
            Quote oldQuote=data.get(0);
            Quote newQuote=oldQuote.Clone(false,true);
            if(oldQuote.Status != 'Cancelled'){
                newQuote.vlocity_cmt__ParentQuoteId__c = quoteId;
                newQuote.Name=oldQuote.Name+'_Backup1'; // rename the Backup Quote
                insert newQuote; // insert backup Quote
                newQuote.status= 'Cancelled';
                update newQuote;
                List<QuoteLineItem> qliList= cloneBackupQuoteLines(newQuote, oldQuote); // Calling method which will return items to clone backup Quote
                insert qliList;
                outMap.put('BackupQuoteId',newQuote.Id); //sending backup QuoteId
            }
        }catch(Exception e) {  
            outMap.put('ErrorApex','BackupQuote');
            outMap.put('ReasonFailure',e.getStackTraceString());
        } 
    }
    //Create backup quote lines
    global static List<QuoteLineItem> cloneBackupQuoteLines(Quote newQuote, Quote oldQuote){
        List<QuoteLineItem> qliList=new List<QuoteLineItem>();
        String qliQuery=queryBuilder('QuoteLineItem');
        qliQuery+=' FROM QuoteLineItem WHERE '+'quoteid=\'' + String.escapeSingleQuotes(oldQuote.Id)+'\'';
        List<QuoteLineItem> itemsData =  Database.query(qliQuery); // get items from original Quote
        
        For(QuoteLineItem qli:itemsData)
        {
            QuoteLineItem itemCopy = qli.clone(false,true);
            itemCopy.quoteId=newQuote.Id; // change Quote Id to backupQuoteId
            qliList.add(itemCopy);
        }
        return qliList;
    }
    
    global static void deleteJobSurf(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options)
    {
        Set<String> productCodeNew = new Set<String>(); //list of items from cart to be deleted.
        Set<String> productCodeOld = new Set<String>(); //list of items from cart to be deleted.
        productCodeOld.add('MOB_SURF_BAS');
        productCodeOld.add('MOB_SURF_0.5');
        productCodeOld.add('MOB_SURF_1');
        productCodeOld.add('MOB_SURF_5');
        productCodeOld.add('MOB_SURF_20');
        productCodeOld.add('MOB_SURF_50');
        productCodeOld.add('MOB_SURF_100');
        productCodeNew.add('MOB_SURF_BAS_V2');
        productCodeNew.add('MOB_SURF_1_V2');
        productCodeNew.add('MOB_SURF_3_V2');        
        productCodeNew.add('MOB_SURF_5_V2');
        productCodeNew.add('MOB_SURF_15_V2');
        productCodeNew.add('MOB_SURF_25_V2');
        productCodeNew.add('MOB_SURF_40_V2');
        productCodeNew.add('MOB_SURF_120_V2');
        String quoteId = String.valueOf(inputMap.get('QuoteId'));
        try
        {
            QuoteLineItem qli = new QuoteLineItem();
            List<QuoteLineItem> qliList = [Select id,QuoteId,TeliaSE_Root_Product__c, Product2Id,vlocity_cmt__Product2Id__r.Name, vlocity_cmt__ParentItemId__c,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__RootItemId__c from QuoteLineItem where QuoteId=:quoteId and (vlocity_cmt__Product2Id__r.ProductCode in: productCodeNew OR vlocity_cmt__Product2Id__r.ProductCode in: productCodeOld)];            
            If(qliList != null && qliList.size()>0)
            {
                qli = qliList[0];
                outMap.put('parentItemId',qli.vlocity_cmt__RootItemId__c);
                outMap.put('cartId',qli.QuoteId);
                outMap.put('hierarchy',qli.TeliaSE_Root_Product__c);
                if(productCodeNew.contains((String)qli.vlocity_cmt__Product2Id__r.ProductCode))
                {
                    outMap.put('NewTotal',true);
                }
                else
                {
                    outMap.put('NewTotal',false);
                }
                delete qliList;    
            }
        }
        catch(Exception e)
        {
            outMap.put('ErrorApex','DeletionOfProduct');
            outMap.put('ReasonFailure',e.getStackTraceString());
        }
    }
    
    global static void addDataPaket(Map<String,Object> inputMap, Map<String,Object> outputMap,Map<String,Object> options)
    {
        String productCode;
        If(inputMap.get('NewTotal')!= false)
        {
            productCode = 'MOB_DATA_PORTFOLIO';
        }
        else
        {
            productCode = 'MOB_DATA';
        }
        PricebookEntry pbe = [select id,name, Product2.ProductCode from PricebookEntry where Product2.ProductCode =: productCode LIMIT 1];     
        options.put('useQueueableApexRemoting',true);
        Map<String, Object> itemsMap = new Map<String, Object>();
        Map<String, Object> recordsMap = new Map<String, Object>();
        Map<String, Object> obb = new Map<String, Object>();
        List<Object> items = new List<Object>();
        List<Object> records = new List<Object>();
        // Passing Parameters
        Id priceBookEntryId = pbe.id;
        String cartId = String.valueOf(inputMap.get('cartId'));
        String parentId = String.valueOf(inputMap.get('parentItemId'));
        String hierarchyPath = String.valueOf(inputMap.get('hierarchy'));
        recordsMap.put('productHierarchyPath',hierarchyPath);
        recordsMap.put('parentHierarchyPath',hierarchyPath);
        records.add(recordsMap);
        obb.put('records',records);
        itemsMap.put('itemId', priceBookEntryId);
        itemsMap.put('parentId', parentId);
        itemsMap.put('parentRecord', obb);
        items.add(itemsMap);
        Map<String,Object> ApiInputMap = new Map<String,Object>();
        ApiInputMap.put('items', items);
        ApiInputMap.put('cartId', cartId);
        ApiInputMap.put('validate', false); 
        ApiInputMap.put('price', false);
        try
        {
            vlocity_cmt.CpqAppHandler cpqAppHandlerService = new  vlocity_cmt.CpqAppHandler();
            cpqAppHandlerService.invokeMethod('postCartsItems', ApiInputMap, outputMap, options);            
        }
        catch(Exception e)
        {
            outputMap.put('ErrorApex','AddToCartError');
            outputMap.put('ReasonFailure',e.getStackTraceString());
        }
        finally
        {
            //  TeliaSE_BasMigration.
        }
        
    }
    
    global static void mergeFromBackup (Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        try
        {
            Set<String> productCodeNew = new Set<String>(); //list of items from cart to be deleted.
            Set<String> productCodeOld = new Set<String>(); //list of items from cart to be deleted.
            productCodeOld.add('MOB_SURF_BAS');
            productCodeOld.add('MOB_SURF_0.5');
            productCodeOld.add('MOB_SURF_1');
            productCodeOld.add('MOB_SURF_5');
            productCodeOld.add('MOB_SURF_20');
            productCodeOld.add('MOB_SURF_50');
            productCodeOld.add('MOB_SURF_100');
            productCodeNew.add('MOB_SURF_BAS_V2');
            productCodeNew.add('MOB_SURF_1_V2');
            productCodeNew.add('MOB_SURF_3_V2');        
            productCodeNew.add('MOB_SURF_5_V2');
            productCodeNew.add('MOB_SURF_15_V2');
            productCodeNew.add('MOB_SURF_25_V2');
            productCodeNew.add('MOB_SURF_40_V2');
            productCodeNew.add('MOB_SURF_120_V2');
            String backupQuoteId = String.valueOf(options.get('BackupQuoteId'));
            String migratedQuoteId = String.valueOf(options.get('QuoteId'));
            List<QuoteLineItem> qliItems = [select id,QuoteId,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__Product2Id__r.productCode,vlocity_cmt__OneTimeCharge__c,TeliaSE_Root_Product__c,
                                            vlocity_cmt__OneTimeTotal__c, vlocity_cmt__EffectiveOneTimeTotal__c, TeliaSE_MC_CM_Floor_Price__c, TeliaSE_CM_Mandate_Percentage__c, 
                                            TeliaSE_AM_Mandate_Percentage__c, TeliaSE_MC_AM_Discount_Floor_Price__c, TeliaSE_MC_SD_Floor_Price__c, TeliaSE_SD_Mandate_Percentage__c, 
                                            TeliaSE_MC_SM_Floor_Price__c, TeliaSE_SM_Mandate_Percentage__c,   vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, 
                                            vlocity_cmt__RecurringTotal__c, TeliaSE_StartDate__c, TeliaSE_EndDate__c, TeliaSE_Flag__c, TeliaSE_MC_Customer_Requested_Price__c,
                                            TeliaSE_Ceiling_Price__c,vlocity_cmt__JSONAttribute__c,TeliaSE_SubsidisedVoice__c,vlocity_cmt__PricingLogData__c, TeliaSE_Floor_Price__c,
                                            TeliaSE_MC_FACallOffQuantity__c,TeliaSE_Approved_Price__c,TeliaSE_Base_Quantity__c, TeliaSE_CommitmentPeriod__c,TeliaSE_PriceTypeCategory__c from QuoteLineItem 
                                            where (QuoteId =: backupQuoteId Or QuoteId=:migratedQuoteId) and (vlocity_cmt__Product2Id__r.ProductCode in: productCodeNew OR vlocity_cmt__Product2Id__r.ProductCode in: productCodeOld)]; 
            Map<String,QuoteLineItem> QliMapBackup = new Map<String,QuoteLineItem>();
            Map<String,Object> QliMapMigrated = new Map<String,Object>();
            List<QuoteLineItem> QliMigrated = new List<QuoteLineItem>();
            for(QuoteLineItem qli: qliItems)
            {
                If(String.valueOf(qli.QuoteId) == backupQuoteId)
                {
                    QliMapBackup.put(qli.vlocity_cmt__Product2Id__r.productCode,qli);
                }
                else
                {
                    QliMigrated.add(qli);
                    QliMapMigrated.put(qli.vlocity_cmt__Product2Id__r.productCode,qli);
                }
            }
            List<QuoteLineItem> qliListMigrated = new List<QuoteLineItem>();
            for(QuoteLineItem qli1:QliMigrated)
            {
                qli1.vlocity_cmt__OneTimeCharge__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__OneTimeCharge__c != null ? QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__OneTimeCharge__c:null;
                qli1.vlocity_cmt__OneTimeTotal__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__OneTimeTotal__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__OneTimeTotal__c:null;
                qli1.vlocity_cmt__EffectiveOneTimeTotal__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__EffectiveOneTimeTotal__c!=null? QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__EffectiveOneTimeTotal__c:null;
                // qli1.TeliaSE_MC_CM_Floor_Price__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_MC_CM_Floor_Price__c;
                qli1.TeliaSE_CM_Mandate_Percentage__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_CM_Mandate_Percentage__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_CM_Mandate_Percentage__c:null;
                qli1.TeliaSE_AM_Mandate_Percentage__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_AM_Mandate_Percentage__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_AM_Mandate_Percentage__c:null;
                // qli1.TeliaSE_MC_AM_Discount_Floor_Price__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_MC_AM_Discount_Floor_Price__c;
                //qli1.TeliaSE_MC_SD_Floor_Price__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_MC_SD_Floor_Price__c;
                qli1.TeliaSE_SD_Mandate_Percentage__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_SD_Mandate_Percentage__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_SD_Mandate_Percentage__c:null;
                qli1.TeliaSE_SM_Mandate_Percentage__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_SM_Mandate_Percentage__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_SM_Mandate_Percentage__c:null;
                //qli1.TeliaSE_MC_SM_Floor_Price__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_MC_SM_Floor_Price__c;
                qli1.vlocity_cmt__RecurringCharge__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__RecurringCharge__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__RecurringCharge__c:null;
                qli1.vlocity_cmt__EffectiveRecurringTotal__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__EffectiveRecurringTotal__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__EffectiveRecurringTotal__c:null;
                qli1.TeliaSE_StartDate__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_StartDate__c !=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_StartDate__c:null;
                qli1.TeliaSE_EndDate__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_EndDate__c!=null? QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_EndDate__c:null;
                qli1.TeliaSE_Flag__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Flag__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Flag__c:null;
                qli1.TeliaSE_MC_Customer_Requested_Price__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_MC_Customer_Requested_Price__c!=null? QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_MC_Customer_Requested_Price__c:null;
                qli1.TeliaSE_Ceiling_Price__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Ceiling_Price__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Ceiling_Price__c:null;
                //qli1.TeliaSE_Floor_Price__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Floor_Price__c;
                qli1.TeliaSE_MC_FACallOffQuantity__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_MC_FACallOffQuantity__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_MC_FACallOffQuantity__c:null;
                qli1.TeliaSE_Approved_Price__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Approved_Price__c!=null? QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Approved_Price__c:null;
                qli1.TeliaSE_Base_Quantity__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Base_Quantity__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Base_Quantity__c:null;
                qli1.TeliaSE_CommitmentPeriod__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_CommitmentPeriod__c!=null? QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_CommitmentPeriod__c:null;
                qli1.TeliaSE_PriceTypeCategory__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_PriceTypeCategory__c!=null? QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_PriceTypeCategory__c:null;
                qli1.TeliaSE_Root_Product__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Root_Product__c!=null? QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_Root_Product__c:null;
                qli1.vlocity_cmt__JSONAttribute__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__JSONAttribute__c!=null? QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__JSONAttribute__c:null;
                qli1.TeliaSE_SubsidisedVoice__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_SubsidisedVoice__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).TeliaSE_SubsidisedVoice__c:null;
                qli1.vlocity_cmt__PricingLogData__c = QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__PricingLogData__c!=null?QliMapBackup.get((String.valueOf(qli1.vlocity_cmt__Product2Id__r.productCode))).vlocity_cmt__PricingLogData__c:null;
                qliListMigrated.add(qli1);
            }
            
            If(qliListMigrated!=null && qliListMigrated.size()>0)
            {
                update qliListMigrated;
            }
            if(options.get('isLocked') == true)
            {    
                Approval.lock(migratedQuoteId, false);
            }
            
        }
        catch(Exception e)
        {
            outMap.put('ErrorApex','MergeBackUp');
            outMap.put('ReasonFailure',e.getStackTraceString());
        }    
    }
    
    global static void createBackupContract(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        String contractId= String.valueOf(options.get('Contractid'));
        String query=queryBuilder('contract');
        query += ' FROM contract WHERE '+'id=\'' + String.escapeSingleQuotes(contractId)+'\'';
        List<Contract> data=  Database.query(query);
        Contract oldContract=data.get(0);
        Contract newContract=oldContract.Clone(false,true); 
        //cloning of contract
        newContract.vlocity_cmt__ParentContractId__c = contractId;
        newContract.Name=oldContract.Name+'_Backup1';
        newContract.status= 'Draft';
        //inserting contract
        insert newContract;
        newContract.TeliaSE_Reason_for_Cancellation__c = 'BackUpContract';
        newContract.status = 'Cancelled';
        update newContract;
        List<vlocity_cmt__ContractLineItem__c > cliList= cloneBackupContractLines(newContract, oldContract);
        insert cliList;
        //deleteOldQuoteLines(quoteId);
        //cloneQuoteLineItemFromMaster(newQuote.Id,quoteId,outMap);
        outMap.put('backupContractId',newContract.id);
    }
    
    global static List<vlocity_cmt__ContractLineItem__c> cloneBackupContractLines(Contract newContract, Contract oldContract)
    {
        List<vlocity_cmt__ContractLineItem__c> cliList=new List<vlocity_cmt__ContractLineItem__c>();
        String qliQuery=queryBuilder('vlocity_cmt__ContractLineItem__c');
        qliQuery+=' FROM vlocity_cmt__ContractLineItem__c WHERE '+'vlocity_cmt__ContractId__c =\'' + String.escapeSingleQuotes(oldContract.Id)+'\'';
        List<vlocity_cmt__ContractLineItem__c> itemsData =  Database.query(qliQuery);        
        For(vlocity_cmt__ContractLineItem__c qli:itemsData)
        {
            vlocity_cmt__ContractLineItem__c itemCopy = qli.clone(false,true);
            itemCopy.vlocity_cmt__ContractId__c=newContract.Id;
            cliList.add(itemCopy);
        }
        return cliList;
    }     
    
    
    global static void mergeFromBackupContract(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {        
        //Inputs needed:
        //ContractId - optionsMap.Contractid
        //QuoteId - options.cartId
        //NewTotal - options.NewTotal
        try{
            String productCode;
            String basProductCode;    
            If(options.get('NewTotal')!= false)
            {
                basProductCode = 'MOB_BAS_V2';
                productCode = 'MOB_DATA_PORTFOLIO';
            }
            else
            {
                basProductCode = 'MOB_BAS';
                productCode = 'MOB_DATA';
            }
            Set<String> productCodeNew = new Set<String>(); //list of items from cart to be deleted.
            Set<String> productCodeOld = new Set<String>(); //list of items from cart to be deleted.
            productCodeOld.add('MOB_SURF_BAS');
            productCodeOld.add('MOB_SURF_0.5');
            productCodeOld.add('MOB_SURF_1');
            productCodeOld.add('MOB_SURF_5');
            productCodeOld.add('MOB_SURF_20');
            productCodeOld.add('MOB_SURF_50');
            productCodeOld.add('MOB_SURF_100');
            productCodeNew.add('MOB_SURF_BAS_V2');
            productCodeNew.add('MOB_SURF_1_V2');
            productCodeNew.add('MOB_SURF_3_V2');        
            productCodeNew.add('MOB_SURF_5_V2');
            productCodeNew.add('MOB_SURF_15_V2');
            productCodeNew.add('MOB_SURF_25_V2');
            productCodeNew.add('MOB_SURF_40_V2');
            productCodeNew.add('MOB_SURF_120_V2');
            String contractId= String.valueOf(options.get('Contractid'));
            String quoteId = String.valueOf(options.get('QuoteId'));
            String rootProduct,parentItemId,rootItemId; 
            Date startDate,endDate;
            Map<String,QuoteLineItem> qliMap = new Map<String,QuoteLineItem>();
            vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
            List<vlocity_cmt__ContractLineItem__c> cliList = [Select id,TeliaSE_RootItemId__c,TeliaSE_Start_Date__c,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__Product2Id__r.Name,TeliaSE_End_Date__c ,TeliaSE_Root_Product__c,TeliaSE_ParentItemId__c, TeliaSE_ProductHierarchy__c,TeliaSE_QuoteItemId__c,vlocity_cmt__ContractId__c  from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =:contractId AND (vlocity_cmt__Product2Id__r.ProductCode in: productCodeNew OR vlocity_cmt__Product2Id__r.ProductCode in: productCodeOld OR vlocity_cmt__Product2Id__r.ProductCode=: basProductCode)];
            if(cliList != Null && cliList.size()>0)
            {
                cli = cliList[0];
                rootProduct = cli.TeliaSE_Root_Product__c;
                rootItemId = cli.TeliaSE_RootItemId__c;
                startDate = cli.TeliaSE_Start_Date__c;
                endDate = cli.TeliaSE_End_Date__c;
            }
            vlocity_cmt__ContractLineItem__c addOnContractLine = new vlocity_cmt__ContractLineItem__c();       
            List<QuoteLineItem> qliList = [Select id,vlocity_cmt__Product2Id__c,  vlocity_cmt__Product2Id__r.name,TeliaSE_Product_Object_Type__c,vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c, vlocity_cmt__Product2Id__r.productCode,vlocity_cmt__ProductHierarchyPath__c from QuoteLineItem where quoteId =: QuoteId and (vlocity_cmt__Product2Id__r.ProductCode in: productCodeNew OR vlocity_cmt__Product2Id__r.ProductCode in: productCodeOld OR vlocity_cmt__Product2Id__r.ProductCode =:productCode)];
            for(QuoteLineItem qli : qliList)
            {
                If((String)qli.vlocity_cmt__Product2Id__r.ProductCode == productCode)
                {
                    addOnContractLine.TeliaSE_Root_Product__c = rootProduct;
                    addOnContractLine.Name = qli.vlocity_cmt__Product2Id__c != null?qli.vlocity_cmt__Product2Id__r.name:null;
                    addOnContractLine.TeliaSE_Product_Object_Type__c = qli.TeliaSE_Product_Object_Type__c;
                    addOnContractLine.vlocity_cmt__ContractId__c = contractId;
                    addOnContractLine.TeliaSE_ParentItemId__c = rootItemId;
                    addOnContractLine.TeliaSE_Start_Date__c = startDate;
                    addOnContractLine.TeliaSE_End_Date__c = endDate;
                    addOnContractLine.TeliaSE_Product_Version__c = qli.vlocity_cmt__Product2Id__c !=null ?qli.vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c:null;
                    addOnContractLine.vlocity_cmt__Product2Id__c = qli.vlocity_cmt__Product2Id__c;
                    addOnContractLine.TeliaSE_QuoteItemId__c = qli.id;
                    addOnContractLine.TeliaSE_RootItemId__c = rootItemId;
                    addOnContractLine.TeliaSE_ProductHierarchy__c = qli.vlocity_cmt__ProductHierarchyPath__c;
                    insert addOnContractLine;
                }
                else
                {
                    qliMap.put(String.valueOf(qli.vlocity_cmt__Product2Id__r.ProductCode),qli);    
                }
                
            }
            
            List<vlocity_cmt__ContractLineItem__c> cliListUpdate = new List<vlocity_cmt__ContractLineItem__c>();
            for(vlocity_cmt__ContractLineItem__c contractLine: cliList)
            {
                if((String)contractLine.vlocity_cmt__Product2Id__r.ProductCode == basProductCode)
                {
                    contractLine.Name = contractLine.vlocity_cmt__Product2Id__r.Name;
                }
                else
                {                   
                    contractLine.TeliaSE_ParentItemId__c = addOnContractLine.TeliaSE_QuoteItemId__c;
                    contractLine.TeliaSE_ProductHierarchy__c = qliMap.get(String.valueOf(contractLine.vlocity_cmt__Product2Id__r.ProductCode)).vlocity_cmt__ProductHierarchyPath__c;
                    contractLine.TeliaSE_QuoteItemId__c = qliMap.get(String.valueOf(contractLine.vlocity_cmt__Product2Id__r.ProductCode)).id;
                    
                }
                cliListUpdate.add(contractLine);
            }
            
            Update cliListUpdate;
        }
        catch(Exception e)
        {
            outMap.put('ErrorFromApex','failed');
        }
    }
    
    //return dynamic query for the Object
    private static String queryBuilder(String obj) {
        SObjectType quoteObj = Schema.getGlobalDescribe().get(obj);
        Map<String,Schema.SObjectField> objfields = quoteObj.getDescribe().fields.getMap();
        String query = 'Select ';
        Boolean firstField = true;
        List<Sobject> quoteList=new List<Sobject>();   
        for (String field : objfields.keySet()) {
            if(firstField)
                query += field;
            else{
                query +=' , ';
                query += field;
            }
            firstField = false;
        }
        return query;
    }
    
}