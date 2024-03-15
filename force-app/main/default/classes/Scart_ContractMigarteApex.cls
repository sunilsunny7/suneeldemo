global class Scart_ContractMigarteApex
{    
    global static contract createBackupContract(string contractid)
    {
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
        System.debug('New Contract is created : '+ newContract.id);
        List<vlocity_cmt__ContractLineItem__c > cliList= cloneBackupContractLines(newContract, oldContract);
        insert cliList;
        //deleteOldQuoteLines(quoteId);
        //cloneQuoteLineItemFromMaster(newQuote.Id,quoteId,outMap);
        return newContract;
    }
    
    global static List<vlocity_cmt__ContractLineItem__c> cloneBackupContractLines(Contract newContract, Contract oldContract)
    {
        System.debug('Enter Method of copying line items');
        List<vlocity_cmt__ContractLineItem__c> qliList=new List<vlocity_cmt__ContractLineItem__c>();
        String qliQuery=queryBuilder('vlocity_cmt__ContractLineItem__c');
        qliQuery+=' FROM vlocity_cmt__ContractLineItem__c WHERE '+'vlocity_cmt__ContractId__c =\'' + String.escapeSingleQuotes(oldContract.Id)+'\'';
        List<vlocity_cmt__ContractLineItem__c> itemsData =  Database.query(qliQuery);
        system.debug('Size contractlineItems to be copied:expected '+ itemsData.size());
        
        For(vlocity_cmt__ContractLineItem__c qli:itemsData)
        {
            vlocity_cmt__ContractLineItem__c itemCopy = qli.clone(false,true);
            itemCopy.vlocity_cmt__ContractId__c=newContract.Id;
            qliList.add(itemCopy);
        }
        try
        {
            delete itemsData;
        }
        catch(Exception e)
        {
            System.debug('error while deleting');
            system.debug(e.getStackTraceString());
        }
        
        system.debug('Size contractlineItems to be copied:actual '+ qliList.size());
        return qliList;
    }
    
    global static void contractLinesMigrate(Contract oldContract)
    {
        system.debug('StartContractLines');
        List<Id> idsRN=new List<Id>();
        Map<Id,Map<String,Object>> itemsMap=new Map<Id,Map<String,Object>>();
        
        String FAquoteId = oldContract.vlocity_cmt__QuoteId__c;
        Map<Id,Quote> quotes=new Map<Id,Quote>([select Id,TeliaSE_Parent_Agreement__c,MC_Payment_Term__c,MC_Commercial_Benchmark__c,TeliaSE_Invoice_Fee__c,TeliaSE_Agreement_Nr__c,TeliaSE_RevisedAgreement__c,TeliaSE_Type__c,TeliaSE_RenegotiatedAgreement__c,TeliaSE_MC_Sales_Flow_Identifier__c,accountId,Opportunity.OwnerId,opportunityId from Quote where id=:FAquoteId]);
        String quoteType = (quotes.get(FAquoteId)).TeliaSE_Type__c;
        string renegotiatedContract = (quotes.get(FAquoteId)).TeliaSE_RenegotiatedAgreement__c;
        List<Quotelineitem> parentOffers = [Select id,Product2Id,TeliaSE_StartDate__c,TeliaSE_EndDate__c from QuoteLineItem where QuoteId =: FAquoteId and vlocity_cmt__ParentItemId__c = Null];
        
        for(QuotelineItem qli : parentOffers)
        {
            Map<String,Object> item = new Map<String,Object>();
            item.put('done','false');
            item.put('endDate',(Date)qli.TeliaSE_EndDate__c);
            item.put('startDate',(Date)qli.TeliaSE_StartDate__c);
            item.put('id',qli.id);
            itemsMap.put(qli.Product2Id,item);
            idsRN.add(qli.Id);            
        }
        system.debug('itemsMap: '+ itemsMap);
        try{
            putlines(quotes.get(FAquoteId),idsRN,oldContract.Id,quoteType,itemsMap,renegotiatedContract);    
        }
        catch(Exception e)
        {
            system.debug('Error in Putting lines');
            system.debug(e.getStackTraceString());
            
        }
        
    }
    
    global static void putLines(Quote currentQuote, List<Id> ids,Id frameAgreementId,String quoteType,Map<Id,Map<String,Object>> itemsMap,String renegotiatedAgreement)
    {
        List<vlocity_cmt__ContractLineItem__c> contractLines=new List<vlocity_cmt__ContractLineItem__c>();
        Map<Id,QuoteLineItem> quoteLineItemMap=new Map<Id,QuoteLineItem>();
        Map<String, Boolean> qlicalloffflagmap = new Map<String, Boolean>();
        List<QuoteLineItem> quoteLineItems=[SELECT Id,vlocity_cmt__Product2Id__r.TeliaSE_MC_isCallOff_Flag__c,TeliaSE_Root_Product__c,TeliaSE_Product_Code__c,TeliaSE_ProductType__c,TeliaSE_StartDate__c,MC_Quarantine_Time__c,TeliaSE_MC_Mobile_WarningActive__c,TeliaSE_MC_Mobile_WarningPercentage__c,TeliaSE_MC_Mobile_AgreedPercentage__c,TeliaSE_MC_Mobile_FunctionActive__c,TeliaSE_MC_TP_WarningPercentage__c,TeliaSE_MC_TP_WarningActive__c,TeliaSE_MC_TP_AgreedPercentage__c,TeliaSE_MC_TP_FunctionActive__c,TeliaSE_Discount_Percentage__c,vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c,TeliaSE_CommitmentPeriod__c,TeliaSE_Minimum_Value_Commit__c,TeliaSE_Base_Quantity__c,TeliaSE_Approved_Price__c,TeliaSE_Approved__c,QuoteId,Quantity,TotalPrice,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_MC_Customer_Requested_Percentage__c,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__Product2Id__r.name,vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringManualDiscount__c,vlocity_cmt__RecurringDiscountPrice__c,vlocity_cmt__OneTimeManualDiscount__c,vlocity_cmt__OneTimeDiscountPrice__c,vlocity_cmt__OneTimeTotal__c ,vlocity_cmt__RecurringTotal__c,vlocity_cmt__JSONAttribute__c,Subtotal,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__c,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c,TeliaSE_Comment__c,TeliaSE_Invoice_Fee__c,TeliaSE_Abroad_Call_Discount__c, TeliaSE_Product_Object_Type__c, TeliaSE_SubsidisedVoice__c, TeliaSE_MC_Campaign_Id__c FROM QuoteLineItem where vlocity_cmt__RootItemId__c in :ids];
        for(QuoteLineItem quoteLineItem:quoteLineItems)
        {
            qlicalloffflagmap.put(quoteLineItem.Id,quoteLineItem.vlocity_cmt__Product2Id__r.TeliaSE_MC_isCallOff_Flag__c);
            quoteLineItemMap.put(quoteLineItem.vlocity_cmt__Product2Id__c, quoteLineItem);
        }
        List<String> hierarchies=new List<String>();
        List<vlocity_cmt__ContractLineItem__c> lines=Scart_ContractMigarteApex.contractLines(quoteLineItems,frameAgreementId,itemsMap,false,qlicalloffflagmap);
        contractLines.addAll(lines);
        for(vlocity_cmt__ContractLineItem__c cli:lines)
        {
            hierarchies.add(cli.TeliaSE_ProductHierarchy__c);
        }
        Map<Id,vlocity_cmt__ContractLineItem__c> contractLineItemMap=new Map<Id,vlocity_cmt__ContractLineItem__c>();
        vlocity_cmt__ContractLineItem__c contractLine; 
        Boolean itemExist=false;
        List<QuoteLineItem> masterLineItems=[SELECT Id,TeliaSE_Root_Product__c,TeliaSE_ProductType__c,TeliaSE_Product_Code__c,TeliaSE_StartDate__c,vlocity_cmt__Product2Id__r.ProductCode,TeliaSE_Discount_Percentage__c,vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c,TeliaSE_CommitmentPeriod__c,TeliaSE_Minimum_Value_Commit__c,MC_Quarantine_Time__c,TeliaSE_MC_Mobile_WarningActive__c,TeliaSE_MC_Mobile_WarningPercentage__c,TeliaSE_MC_Mobile_AgreedPercentage__c,TeliaSE_MC_Mobile_FunctionActive__c,TeliaSE_MC_TP_WarningPercentage__c,TeliaSE_MC_TP_WarningActive__c,TeliaSE_MC_TP_AgreedPercentage__c,TeliaSE_MC_TP_FunctionActive__c,TeliaSE_Base_Quantity__c,TeliaSE_Approved_Price__c,TeliaSE_Approved__c,QuoteId,Quantity,TotalPrice,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_MC_Customer_Requested_Percentage__c,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__Product2Id__r.name,vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringManualDiscount__c,vlocity_cmt__RecurringDiscountPrice__c,vlocity_cmt__OneTimeManualDiscount__c,vlocity_cmt__OneTimeDiscountPrice__c,vlocity_cmt__OneTimeTotal__c ,vlocity_cmt__RecurringTotal__c,vlocity_cmt__JSONAttribute__c,Subtotal,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__c,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c,TeliaSE_Comment__c,TeliaSE_Invoice_Fee__c,TeliaSE_Abroad_Call_Discount__c,TeliaSE_Product_Object_Type__c, TeliaSE_SubsidisedVoice__c, TeliaSE_MC_Campaign_Id__c FROM QuoteLineItem where TeliaSE_Root_Product__c =: itemsMap.keyset() and quoteId=:System.Label.TeliaSE_Master_quote and vlocity_cmt__ProductHierarchyPath__c NOT IN :hierarchies];
        
        For (QuoteLineItem qt : masterLineItems)
        {
            System.debug('Line 253:  >>>>> MasterlInes' + qt);
        }
        
        List<QuoteLineItem> newMasterLineItems=new List<QuoteLineItem>();
        for(QuoteLineItem item:masterLineItems)
        {
            for(String hierarchy:hierarchies)
            {
                if(item.vlocity_cmt__ProductHierarchyPath__c.contains(hierarchy) && hierarchy.length() >20)
                {
                    newMasterLineItems.add(item);
                    break;
                }
            }
        }
        masterLineItems=newMasterLineItems; 
        
        List<vlocity_cmt__ContractLineItem__c> masterlines=Scart_ContractMigarteApex.contractLines(masterLineItems,frameAgreementId,itemsMap,true,qlicalloffflagmap);
        contractLines.addAll(masterlines);
        if(quoteType == 'Renegotiation')
        {
            masterLineItems.addAll(quoteLineItems);
            List<vlocity_cmt__ContractLineItem__c> contractLinesRenegotiation=new List<vlocity_cmt__ContractLineItem__c>();
            Map<Id,vlocity_cmt__ContractLineItem__c> contractItemsMapRN=new Map<Id,vlocity_cmt__ContractLineItem__c>();
            for(vlocity_cmt__ContractLineItem__c contractItem:contractLines)
            {
                if(contractItemsMapRN.get(contractItem.vlocity_cmt__Product2Id__c)!=null){
                    contractLinesRenegotiation.add(contractItem);
                }else
                    contractItemsMapRN.put(contractItem.vlocity_cmt__Product2Id__c, contractItem);
            }
            //Copy the Utilizers from old contract to new contract while re-negotiating.
            //String UtilizerMessages = updateutilizerAccounts(renegotiatedAgreement,frameAgreementId);
            //Map<Id,Contract> contractRN=new Map<Id,Contract>([select id from Contract where id=:renegotiatedAgreement and Status='Active']);
            Map<Id,Contract> contractRN=new Map<Id,Contract>([select id from Contract where id=:renegotiatedAgreement]);
            List<vlocity_cmt__ContractLineItem__c> lineItemsRN=[select id , vlocity_cmt__ContractId__c ,TeliaSE_Start_Date__c, vlocity_cmt__LineStatus__c , TeliaSE_Minimum_Value_Commit__c , TeliaSE_Approved__c , MC_Quarantine_Time__c,TeliaSE_Approved_Price__c,TeliaSE_MasterQuote__c,vlocity_cmt__RecurringCharge__c,TeliasSETargetPercentage__c,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_MC_Customer_Requested_Percentage__c,vlocity_cmt__Product2Id__c,name from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =: contractRN.keySet()];
            Contract renegotiatedContract = new Contract();
            
            List<Contract> conList = [SELECT Id, TeliaSE_Invoice_Fee__c, MC_Payment_Term__c from Contract where id in :contractRN.keySet()];
            if(conList != null && conList.size() > 0){
                renegotiatedContract = conList[0];
                system.debug('contractRN line 280: '+contractRN);
            }
            
            for(vlocity_cmt__ContractLineItem__c item :lineItemsRN )
            {
                contractLineItemMap.put(item.vlocity_cmt__Product2Id__c,item);
            }
            for(QuoteLineItem qliItem:masterLineItems)
            {
                QuoteLineItem quoteItem=quoteLineItemMap.get(qliItem.vlocity_cmt__Product2Id__c)!=null?quoteLineItemMap.get(qliItem.vlocity_cmt__Product2Id__c):qliItem;
                vlocity_cmt__ContractLineItem__c contractLineRN=contractLineItemMap.get(quoteItem.vlocity_cmt__Product2Id__c);
                if(contractLineRN != null)
                {
                    
                    //MCSTO-4170 START- Updating the line item for offers when only date is modified
                    //System.debug('QLI: ' + qliItem.TeliaSE_Product_Code__c );
                    //System.debug('Line 374 ... Offer Updation');
                    //System.debug('LineStatus of Offer: '+ contractLineRN.vlocity_cmt__LineStatus__c);
                    //System.debug('contractLineRN.TeliaSE_Start_Date__c : '+ contractLineRN.TeliaSE_Start_Date__c);
                    //System.debug('qliItem.TeliaSE_StartDate__c : '+ qliItem.TeliaSE_StartDate__c);
                    //System.debug('qliItem.vlocity_cmt__ParentItemId__c' + qliItem.vlocity_cmt__ParentItemId__c);
                    if(contractLineRN.TeliaSE_Start_Date__c != quoteItem.TeliaSE_StartDate__c && quoteItem.vlocity_cmt__ParentItemId__c==NULL)
                    {
                        System.debug('Line 378..Dates are updated');
                        contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c).vlocity_cmt__LineStatus__c='Updated';
                    }
                    
                    //MCSTO-4170 END
                    
                    // System.debug('Line 318 ... After Code Updation');
                    if(contractLineRN.TeliaSE_MasterQuote__c && quoteLineItemMap.get(qliItem.vlocity_cmt__Product2Id__c)!=null)
                    {
                        contractItemsMapRN.get(quoteItem.vlocity_cmt__Product2Id__c).vlocity_cmt__LineStatus__c='Added';
                        if(contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c) != null  && quoteItem.vlocity_cmt__ParentItemId__c != null)
                        {
                            contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c).vlocity_cmt__LineStatus__c='Updated';
                        }
                    }
                    else if(quoteItem.TeliaSE_ProductType__c == 'Price')
                    {
                        //System.debug('Line 329 ... Price');
                        if((quoteItem.TeliaSE_MC_Customer_Requested_Price__c != null &&  quoteItem.TeliaSE_MC_Customer_Requested_Price__c !=contractLineRN.TeliaSE_MC_Customer_Requested_Price__c) || 
                            (quoteItem.TeliaSE_Minimum_Value_Commit__c !=null && quoteItem.TeliaSE_Minimum_Value_Commit__c !=contractLineRN.TeliaSE_Minimum_Value_Commit__c) ||
                            (quoteItem.MC_Quarantine_Time__c != null && quoteItem.MC_Quarantine_Time__c !=contractLineRN.MC_Quarantine_Time__c) ||
                            (renegotiatedContract != null && renegotiatedContract.TeliaSE_Invoice_Fee__c!=null && currentQuote.TeliaSE_Invoice_Fee__c !=renegotiatedContract.TeliaSE_Invoice_Fee__c) ||
                            (renegotiatedContract != null && renegotiatedContract.MC_Payment_Term__c !=null && currentQuote.MC_Payment_Term__c !=renegotiatedContract.MC_Payment_Term__c))
                        {
                            System.debug('Line 337 ... Updating Line Item');
                            contractItemsMapRN.get(contractLineRN.vlocity_cmt__Product2Id__c).vlocity_cmt__LineStatus__c='Updated';
                            if(contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c) != null)
                            {
                                contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c).vlocity_cmt__LineStatus__c='Updated';
                            }
                        }
                        else if(quoteItem.vlocity_cmt__RecurringCharge__c != null && quoteItem.vlocity_cmt__RecurringCharge__c != contractLineRN.vlocity_cmt__RecurringCharge__c) 
                        {
                            contractItemsMapRN.get(contractLineRN.vlocity_cmt__Product2Id__c).vlocity_cmt__LineStatus__c='Updated';
                            if(contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c) != null)
                            {
                                contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c).vlocity_cmt__LineStatus__c='Updated';
                            }
                        }
                    }
                    else
                    {
                        if((quoteItem.TeliaSE_MC_Customer_Requested_Percentage__c != null && quoteItem.TeliaSE_MC_Customer_Requested_Percentage__c != contractLineRN.TeliaSE_MC_Customer_Requested_Percentage__c)||
                            (quoteItem.TeliaSE_Minimum_Value_Commit__c !=null && quoteItem.TeliaSE_Minimum_Value_Commit__c !=contractLineRN.TeliaSE_Minimum_Value_Commit__c) ||
                            (quoteItem.MC_Quarantine_Time__c != null && quoteItem.MC_Quarantine_Time__c !=contractLineRN.MC_Quarantine_Time__c) ||
                            (renegotiatedContract != null && renegotiatedContract.TeliaSE_Invoice_Fee__c!=null && currentQuote.TeliaSE_Invoice_Fee__c !=renegotiatedContract.TeliaSE_Invoice_Fee__c) ||
                            (renegotiatedContract != null && renegotiatedContract.MC_Payment_Term__c !=null && currentQuote.MC_Payment_Term__c !=renegotiatedContract.MC_Payment_Term__c))
                        {
                            contractItemsMapRN.get(contractLineRN.vlocity_cmt__Product2Id__c).vlocity_cmt__LineStatus__c='Updated';
                            if(contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c) != null)
                            {
                                contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c).vlocity_cmt__LineStatus__c='Updated';
                            }
                        }
                        else if(quoteItem.TeliaSE_Discount_Percentage__c !=null && quoteItem.TeliaSE_Discount_Percentage__c != contractLineRN.TeliasSETargetPercentage__c )
                        {
                            contractItemsMapRN.get(contractLineRN.vlocity_cmt__Product2Id__c).vlocity_cmt__LineStatus__c='Updated';
                            if(contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c) != null)
                            {
                                contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c).vlocity_cmt__LineStatus__c='Updated';
                            }
                        }
                    }
                }
                else
                {
                    System.debug('Line 381 ... Updating Line Item');
                    contractItemsMapRN.get(quoteItem.vlocity_cmt__Product2Id__c).vlocity_cmt__LineStatus__c='Added';
                    
                    // Updating product offer for any addition to below offer
                    If(contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c) != null  && quoteItem.vlocity_cmt__ParentItemId__c != null )
                    {
                        contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c).vlocity_cmt__LineStatus__c='Updated';
                    }
                    
                }
                
            }
            //inserting Renegotiating Service Agreement contract lines
            if(contractItemsMapRN.size() > 0)
            {
                contractLinesRenegotiation.addAll(contractItemsMapRN.values());
                insert contractLinesRenegotiation;
            }
        }
        //inserting normal Service Agreement Contract lines
        if(contractLines.size()>0 && String.isEmpty(quoteType))
        {
            insert contractLines;
        }
        
    }
    
    global static List<vlocity_cmt__ContractLineItem__c> contractLines(List<QuoteLineItem> quoteLineItems, ID frameAgreementId,Map<Id,Map<String,Object>> itemsMap,Boolean isMasterQuote , Map<String, Boolean> qlicalloffflagmap)
    {
              
        List<vlocity_cmt__ContractLineItem__c> contractLines=new List<vlocity_cmt__ContractLineItem__c>();
        vlocity_cmt__ContractLineItem__c  contractLine;
        for(QuoteLineItem qli:quoteLineItems)
        {
            // Added below condition to differentiate products which needs to be added to Contract.
            if ((isMasterQuote) || (isMasterQuote == false && qlicalloffflagmap.containskey(qli.vlocity_cmt__RootItemId__c) && qlicalloffflagmap.get(qli.vlocity_cmt__RootItemId__c) == false))
            {        
            Map<string,Object> itemData = itemsMap.get(qli.TeliaSE_Root_Product__c);
            system.debug('itemData: '+ itemData);
            contractLine=new vlocity_cmt__ContractLineItem__c();
            contractLine.TeliasSETargetPercentage__c=qli.TeliaSE_Discount_Percentage__c;
            contractLine.TeliaSE_Product_Version__c=qli.vlocity_cmt__Product2Id__c !=null ?qli.vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c:null;
            contractLine.TeliaSE_CommitmentPeriod__c=qli.TeliaSE_CommitmentPeriod__c;
            contractLine.TeliaSE_Base_Quantity__c=qli.TeliaSE_Base_Quantity__c; 
        
            // #Defect- 3848, Json is updated and the temporary fix implemented is also taken away
            contractLine.MC_Quarantine_Time__c=qli.MC_Quarantine_Time__c;    
            contractLine.TeliaSE_Minimum_Value_Commit__c=qli.TeliaSE_Minimum_Value_Commit__c;
            contractLine.TeliaSE_Approved_Price__c=qli.TeliaSE_Approved_Price__c;
            contractLine.TeliaSE_Approved__c=qli.TeliaSE_Approved__c;
            contractLine.TeliaSE_ProductHierarchy__c=qli.vlocity_cmt__ProductHierarchyPath__c;
            contractLine.TeliaSE_ParentItemId__c=qli.vlocity_cmt__ParentItemId__c;
            contractLine.TeliaSE_RootItemId__c=qli.vlocity_cmt__RootItemId__c;
            contractLine.TeliaSE_QuoteItemId__c=qli.Id;
            contractLine.vlocity_cmt__ContractId__c=frameAgreementId;
            contractLine.Name=qli.vlocity_cmt__Product2Id__c != null?qli.vlocity_cmt__Product2Id__r.name:null;
            contractLine.vlocity_cmt__AttributesData__c=qli.vlocity_cmt__JSONAttribute__c;
            contractLine.vlocity_cmt__Product2Id__c=qli.vlocity_cmt__Product2Id__c;
            contractLine.vlocity_cmt__Quantity__c=qli.Quantity;
            contractLine.vlocity_cmt__OneTimeCharge__c=qli.vlocity_cmt__OneTimeCharge__c;
            contractLine.vlocity_cmt__OneTimeTotal__c=qli.vlocity_cmt__OneTimeTotal__c;
            contractLine.vlocity_cmt__OneTimeDiscountPrice__c=qli.vlocity_cmt__OneTimeDiscountPrice__c;
            contractLine.vlocity_cmt__OneTimeManualDiscount__c=qli.vlocity_cmt__OneTimeManualDiscount__c;
            contractLine.vlocity_cmt__RecurringTotal__c=qli.vlocity_cmt__RecurringTotal__c;
            contractLine.vlocity_cmt__RecurringCharge__c=qli.vlocity_cmt__RecurringCharge__c;
            contractLine.vlocity_cmt__RecurringDiscountPrice__c=qli.vlocity_cmt__RecurringDiscountPrice__c;
            contractLine.vlocity_cmt__RecurringManualDiscount__c=qli.vlocity_cmt__RecurringManualDiscount__c;
            contractLine.vlocity_cmt__OneTimeTotal__c=qli.vlocity_cmt__OneTimeTotal__c ;
            contractLine.TeliaSE_MC_Customer_Requested_Percentage__c=qli.TeliaSE_MC_Customer_Requested_Percentage__c;
            contractLine.TeliaSE_MC_Customer_Requested_Price__c=qli.TeliaSE_MC_Customer_Requested_Price__c;
            
            contractLine.TeliaSE_Start_Date__c= (Date)itemData.get('startDate');
            contractLine.TeliaSE_End_Date__c= (Date)itemData.get('endDate');
            contractLine.TeliaSE_MasterQuote__c=isMasterQuote;
            contractLine.TeliaSE_Contract_Line_Notes__c = qli.TeliaSE_Comment__c;
            contractLine.TeliaSE_Abroad_Call_Discount__c = qli.TeliaSE_Abroad_Call_Discount__c; 
            contractLine.TeliaSE_Invoice_Fee__c = qli.TeliaSE_Invoice_Fee__c;
            contractLine.TeliaSE_Root_Product__c=qli.TeliaSE_Root_Product__c;
            contractLine.TeliaSE_Product_Object_Type__c = qli.TeliaSE_Product_Object_Type__c;
            contractLine.TeliaSE_SubsidisedVoice__c = qli.TeliaSE_SubsidisedVoice__c;
            contractLine.TeliaSE_MC_Campaign_Id__c = qli.TeliaSE_MC_Campaign_Id__c;  
            
            contractLine.TeliaSE_MC_Mobile_WarningActive__c = qli.TeliaSE_MC_Mobile_WarningActive__c;
            contractLine.TeliaSE_MC_Mobile_WarningPercentage__c = qli.TeliaSE_MC_Mobile_WarningPercentage__c;
            contractLine.TeliaSE_MC_Mobile_AgreedPercentage__c = qli.TeliaSE_MC_Mobile_AgreedPercentage__c;
            contractLine.TeliaSE_MC_Mobile_FunctionActive__c = qli.TeliaSE_MC_Mobile_FunctionActive__c;
            contractLine.TeliaSE_MC_TP_WarningPercentage__c = qli.TeliaSE_MC_TP_WarningPercentage__c;
            contractLine.TeliaSE_MC_TP_WarningActive__c = qli.TeliaSE_MC_TP_WarningActive__c;
            contractLine.TeliaSE_MC_TP_AgreedPercentage__c = qli.TeliaSE_MC_TP_AgreedPercentage__c;
            contractLine.TeliaSE_MC_TP_FunctionActive__c = qli.TeliaSE_MC_TP_FunctionActive__c;
            
            contractLines.add(contractLine);
        }
}
        return contractLines;
    }
    
    global static void mergeStatusContractLines(Contract backupContract, Contract originalContract)
    {
        List<vlocity_cmt__ContractLineItem__c> contractLines = new List<vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> updateContractLines = new List<vlocity_cmt__ContractLineItem__c>();
        contractlines = [select id, vlocity_cmt__Product2Id__c,vlocity_cmt__ContractId__c, vlocity_cmt__LineStatus__c,TeliaSE_Start_Date__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =: backupContract.id OR  vlocity_cmt__ContractId__c =: originalContract.id];
        Map<id,string> backupContractlines = new Map<id,string>();
        Map<id,Date> backupStartDate = new Map<id,Date>();
        
        for(vlocity_cmt__ContractLineItem__c cli : contractlines)
        {
            if(cli.vlocity_cmt__ContractId__c == backupContract.id)
            {
                backupContractlines.put(cli.vlocity_cmt__Product2Id__c,cli.vlocity_cmt__LineStatus__c);
                backupStartDate.put(cli.vlocity_cmt__Product2Id__c,cli.TeliaSE_Start_Date__c);
            }
        }
        
        for(vlocity_cmt__ContractLineItem__c cli : contractlines)
        {
            if(cli.vlocity_cmt__ContractId__c == originalContract.id)
            {
                if(backupContractlines.get(cli.vlocity_cmt__Product2Id__c) != null)
                {
                    cli.vlocity_cmt__LineStatus__c = backupContractlines.get(cli.vlocity_cmt__Product2Id__c); 
                    cli.TeliaSE_Start_Date__c = backupStartDate.get(cli.vlocity_cmt__Product2Id__c);
                    updateContractLines.add(cli);
                }
            }
        }
        try
        {
            if(updateContractLines!= null && updateContractLines.size()>0)
            {
                update updateContractLines;
            }
        }
        catch(Exception e)
        {
            system.debug('updating line status for contract lines');
            system.debug(e.getStackTraceString());
        }
        
    }
    
    global static void revertChange (Contract backupContract,Contract originalContract)
    {
        system.debug('Enter revert change scenarios');
        List<vlocity_cmt__ContractLineItem__c> qliList=new List<vlocity_cmt__ContractLineItem__c>();
        String qliQuery=queryBuilder('vlocity_cmt__ContractLineItem__c');
        qliQuery+=' FROM vlocity_cmt__ContractLineItem__c WHERE '+'vlocity_cmt__ContractId__c =\'' + String.escapeSingleQuotes(backupContract.Id)+'\'';
        List<vlocity_cmt__ContractLineItem__c> itemsData =  Database.query(qliQuery);
        system.debug('Size contractlineItems to be copied:expected '+ itemsData.size());
        
        For(vlocity_cmt__ContractLineItem__c qli:itemsData)
        {
            vlocity_cmt__ContractLineItem__c itemCopy = qli.clone(false,true);
            itemCopy.vlocity_cmt__ContractId__c=originalContract.Id;
            qliList.add(itemCopy);
        }
        List<vlocity_cmt__ContractLineItem__c> cliListMigrated = [Select id from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =: originalContract.id];             
        system.debug('Size contractlineItems to be copied:actual '+ cliListMigrated.size());
        delete cliListMigrated;  
        if(qliList!= Null)
        {
            try{
                insert qliList;
            }
            catch(Exception e)
            {
                system.debug('error in insert');
            }
        }
    }
    
    global static void repricingTP(String migratedQuoteid)
    {
        try
        {
            
            Quote backupQuote = [select id,name from quote where vlocity_cmt__ParentQuoteId__c =: migratedQuoteId and Name like '%_backup1%' ORDER BY CreatedDate DESC LIMIT 1];
            List<QuoteLineItem> qliList = [Select id,quoteId,Quote.Name,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__Product2Id__r.ProductCode,TeliaSE_MC_SM_Floor_Price__c,TeliaSE_MC_Customer_Requested_Price__c,
                                           TeliaSE_MC_Customer_Requested_Percentage__c,TeliaSE_CM_Mandate_Percentage__c,TeliaSE_AM_Mandate_Percentage__c,TeliaSE_SM_Mandate_Percentage__c,
                                           TeliaSE_SD_Mandate_Percentage__c,TeliaSE_Discount_Percentage__c,vlocity_cmt__RecurringDiscountPrice__c,vlocity_cmt__OneTimeDiscountPrice__c,
                                           vlocity_cmt__OverageDiscountPrice__c,TeliaSE_Flag__c, TeliaSE_Ceiling_Price__c,vlocity_cmt__RecurringCharge__c,TeliaSE_Target_Price__c 
                                           from Quotelineitem where product2.TeliaSE_Object_Type_Name__c ='Touch Point Offer Spec' AND (QuoteId=:migratedQuoteid OR QuoteId=: backupQuote.id)];
            List<QuotelineItem> migratedQuoteLineItems = new List<QuotelineItem>();
            Map<String,QuoteLineItem> backupQuoteLineItems = new Map<String,QuoteLineItem>();
            If(qliList != null && qliList.size()>0)
            {
                for(QuotelineItem qli : qliList)
                {
                    if(String.valueOf(qli.quoteId) == migratedQuoteid)
                    {
                        migratedQuoteLineItems.add(qli);
                    }
                    else
                    {
                        backupQuoteLineItems.put(qli.vlocity_cmt__Product2Id__r.ProductCode , qli);
                    }
                }    
            }
            List<QuoteLineItem> qliUpdate = new list<QuoteLineItem>();
            If(migratedQuoteLineItems!= null && migratedQuoteLineItems.size()>0)
            {
                for(QuoteLineItem updateqli : migratedQuoteLineItems)
                {
                    if(backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode) != null)
                    {
                        updateqli.TeliaSE_CM_Mandate_Percentage__c = backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_CM_Mandate_Percentage__c;
                        updateqli.TeliaSE_AM_Mandate_Percentage__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_AM_Mandate_Percentage__c;
                        updateqli.TeliaSE_SM_Mandate_Percentage__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_SM_Mandate_Percentage__c;
                        updateqli.TeliaSE_SD_Mandate_Percentage__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_SD_Mandate_Percentage__c;
                        updateqli.TeliaSE_Discount_Percentage__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_Discount_Percentage__c;
                        updateqli.vlocity_cmt__RecurringDiscountPrice__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).vlocity_cmt__RecurringDiscountPrice__c;
                        updateqli.TeliaSE_MC_Customer_Requested_Price__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_MC_Customer_Requested_Price__c;
                        updateqli.TeliaSE_MC_Customer_Requested_Percentage__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_MC_Customer_Requested_Percentage__c;
                        updateqli.vlocity_cmt__OneTimeDiscountPrice__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).vlocity_cmt__OneTimeDiscountPrice__c;
                        updateqli.vlocity_cmt__OverageDiscountPrice__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).vlocity_cmt__OverageDiscountPrice__c;
                        updateqli.TeliaSE_Flag__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_Flag__c;
                        updateqli.TeliaSE_Ceiling_Price__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_Ceiling_Price__c;
                        updateqli.vlocity_cmt__RecurringCharge__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).vlocity_cmt__RecurringCharge__c;
                        updateqli.TeliaSE_Target_Price__c= backupQuoteLineItems.get(updateqli.vlocity_cmt__Product2Id__r.ProductCode).TeliaSE_Target_Price__c; 
                        qliUpdate.add(updateqli);
                    } 
                }    
            }
            if(qliUpdate.size() >0 && qliUpdate!= Null )
            {
                update qliUpdate;
                Quote migratedquote = new Quote();
                migratedquote.id = migratedQuoteid;
                migratedquote.billingName = 'TPMigrationSuccessful';
                update migratedquote;
            } 
            
        }
        catch(Exception e)
        {
            system.debug('Exceptione is caught');
            Quote migratedquote = new Quote();
            migratedquote.id = migratedQuoteid;
            migratedquote.billingName = 'Failed-TPMigration';
            update migratedquote;
        }
    }
    
    
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