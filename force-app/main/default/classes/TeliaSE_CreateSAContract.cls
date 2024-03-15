/**
About
-----
Description: TeliaSA_CreateSAContract on Contract Object

Update History:
MC Drop 1: MCSTO 272 : PP : Updated Class to add default value on Date 'Create_Opportunity_On__c' while SA creation
MC Drop 1: Click Stream : Updated logic to create single FA and eliminating SA creation.
MC Drop 1: Click Stream : Master quote Logic
MC Drop 2: Updating Salesflow Identifier from Quote, Updating Root Product Offers in Quote for displaying Subscriptions in Offer Quote,Update LineStatus Updation logic on changing customer terms.
MC Drop 4: Updated logic to create contract line items for quote items where QuoteItem.RootItem.TeliaSE_MC_isCallOff_Flag = false
--------------
*/

global without sharing class TeliaSE_CreateSAContract  implements vlocity_cmt.VlocityOpenInterface{
    
    public class ContractException extends Exception{}
    private static Map<String, Boolean> qlicalloffflagmap = new Map<String, Boolean>();
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        
        try{           
            if (methodName.equals(SEUtility.CREATESA))
            {
                createSA(inputMap,outMap);
            }
            else if(methodName.equals('UpdateRootProductOffer'))
            {
                String quoteId = (String) inputMap.get('ContextId');
                String OfferProd = UpdateRootProductOffer(quoteId);                
            }  
            else if(methodName.equals('utilizerFlag'))  
            {  
                utilizerFlag(inputMap,outMap);                
            }
            else if(methodName.equals('saveContractDates')){
                saveContractDates(inputMap);
            }
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {
            result = false;
            outMap.put('ErrorAgreement','Error');
            outMap.put('ErrorMessage',e.getMessage());
        }
        return result;
    }
    public class Item
    {
        public String id;
        public Date startDate;
        public Date endDate;
        public Boolean done=false;
    }
    
    @TestVisible
    private void createSA(Map<String, Object> inputMap, Map<String, Object> outMap)
    {
        Map<Id,Item> itemsMap=new Map<Id,Item>();
        Map<Id,Item> datesMap=new Map<Id,Item>();
        //String agreementExternal;
        String quoteId= (String)inputMap.get('ContextId');
        String quoteType=(String)inputMap.get('Type');
        String agreementId=(String)inputMap.get('FrameAgreementId');
        String salesIdentifier = (String) inputMap.get('TeliaSE_Sales_Identifier');
        /*if(String.isEmpty(agreementId))
        {
        agreementExternal=(String)inputMap.get('Agreement_Nr__c');
        }*/
        Map<String,Object> quote=(Map<String,Object>)inputMap.get('Quote');
        List<Item> items=new List<Item>();
        Item item;
        Date startDate;
        Date endDate;
        Date startDateforFA;
        Date endDateforFA;
        List<Id> ids=new List<Id>();
        String tempStartDate=null;
        String tempEndDate=null;
        String offerProds;  
        
        //MCSTO: 4043 Start
        //=========================================================================
        try
        {
            offerProds=UpdateRootProductOffer(quoteId);
        } 
        catch(Exception e)
        {
            throw new ContractException(e.getStackTraceString());
        }
        outMap.put('offerProds',offerProds); //returing all the Agreement Offering parents which will be used for Utilizer filter  
        
        //=========================================================================
        //MCSTO: 4043 END
        for(Object obj:(List<Object>)quote.get('Line'))
        {
            item=new Item();
            Map<String,Object> data=(Map<String,Object>)obj;
            item.id=String.valueOf(data.get('RootProduct'));
            tempStartDate=String.valueOf(data.get('startDate'));
            tempEndDate=String.valueOf(data.get('endDate'));
            if(tempStartDate == null || String.isEmpty(tempStartDate))
            {
                throw new ContractException('Start date can not be empty');
            }
            else if(tempStartDate.length() > 10 )
            {
                Date temp=Date.valueOf(tempStartDate);
                item.startDate=temp.addDays(1);
            }
            else
            {
                item.startDate=Date.valueOf(tempStartDate);    
            }
            if(tempEndDate == null || String.isEmpty(tempEndDate))
            {
                throw new ContractException('End date can not be empty');
            }
            else if(tempEndDate.length() > 10 )
            {
                Date temp=Date.valueOf(tempEndDate);
                item.endDate=temp.addDays(1);
            }
            else
            {
                item.endDate=Date.valueOf(tempEndDate);
            }
            
            itemsMap.put((Id)data.get('RootProduct'),item);
            datesMap.put((Id)data.get('Id'),item);
            items.add(item);
        }
        
        updateDates(Json.serialize(datesMap));
        startDateforFA=items[0].startDate;
        endDateForFA=items[0].endDate;
        for(Integer i=0;i<items.size();i++)
        {
            if(startDateforFA >items[i].startDate)
            {
                startDateforFA=items[i].startDate;
            }
            if(endDateForFA< items[i].endDate)
            {
                endDateforFA=items[i].endDate;
            }
        }
        
        Map<Id,Quote> quotes=new Map<Id,Quote>([select Id,TeliaSE_Parent_Agreement__c,MC_Payment_Term__c,MC_Commercial_Benchmark__c,TeliaSE_Invoice_Fee__c,TeliaSE_Agreement_Nr__c,TeliaSE_RevisedAgreement__c,TeliaSE_RenegotiatedAgreement__c,TeliaSE_MC_Sales_Flow_Identifier__c,accountId,Opportunity.OwnerId,opportunityId from Quote where id=:quoteId]);
        SavePoint parentSp=Database.setSavepoint();
        try
        {
            Id frameAgreementId=checkFrameAgreement(quoteId,startDateforFA,endDateforFA,quoteType,quotes);
            List<Id> idsRN=new List<Id>();
            for(Integer i=0;i<items.size();i++)
            {
                idsRN.add(items[i].id);    
            }
            putLines(quotes.get(quoteId), idsRN,startDateforFA,endDateForFA,frameAgreementId,quoteType,itemsMap,quotes.get(quoteId).TeliaSE_RenegotiatedAgreement__c);
            lockQuote(quoteId,quoteType); 
            
            // Revise Contract is Id of modified contract
            //TeliaSE_RenegotiatedAgreement__c is id of renegotiated agreement.
            if(String.isNOtEmpty(quotes.get(quoteId).TeliaSE_RevisedAgreement__c) || String.isNOtEmpty(quotes.get(quoteId).TeliaSE_RenegotiatedAgreement__c))
            {   
                String negotiatedFAId = '';
                Boolean revisedContract = false;
                // Checking revised contract if not null. It Will be null for renegotiated quote. If contract is modified, Id of modified is available here.
                if(String.isNOtEmpty(quotes.get(quoteId).TeliaSE_RevisedAgreement__c))
                {
                    negotiatedFAId = quotes.get(quoteId).TeliaSE_RevisedAgreement__c;
                    if(negotiatedFAId != null) revisedContract = true;                    
                }
                else
                {
                    negotiatedFAId = quotes.get(quoteId).TeliaSE_RenegotiatedAgreement__c;
                    revisedContract = false;
                }
                String resultUtilizer = updateutilizerAccounts(negotiatedFAId,frameAgreementId, revisedContract,salesIdentifier);
                if (resultUtilizer=='RevisedShowUtilizers') {
                    outMap.put('NoError', 'NoError');
                    outMap.put('UtilizerFileName', '');
                }
                outMap.put('RevisedShowUtilizers', resultUtilizer);
                //} else outMap.put('ShowUtilizers', 'DontShowUtilizers');ShowUtilizers
            }
            outMap.put('options',frameAgreementId); 
            outMap.put('ErrorAgreement','OK');
        }Catch(Exception e)
        {
            DataBase.rollback(parentSp);
            throw new ContractException(e.getMessage()+e.getLineNumber()+e.getStackTraceString());
        }
    }
    
    private static Id checkFrameAgreement(String quoteId,Date startDate,Date endDate,String type,Map<Id,Quote> quotes )
    {
        Quote quote=quotes.get(quoteId);
        Id recordTypeId=Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get(SEUtility.FRAMEAGREEMENT).getRecordTypeId();
        Contract faContract=new Contract();
        faContract.AccountId=quote.accountId;
        faContract.ownerId=quote.Opportunity.OwnerId;
        faContract.vlocity_cmt__OpportunityId__c=quote.opportunityId;
        faContract.vlocity_cmt__QuoteId__c=quote.Id;
        faContract.MC_Payment_Term__c=quote.MC_Payment_Term__c;
        faContract.MC_Commercial_Benchmark__c=quote.MC_Commercial_Benchmark__c;
        faContract.TeliaSE_Invoice_Fee__c=quote.TeliaSE_Invoice_Fee__c;
        faContract.RecordTypeId=recordTypeId;
        faContract.StartDate=startDate;
        faContract.Status=System.Label.TeliaSE_Draft;
        faContract.EndDate=endDate;
        faContract.TeliaSE_Parent_Agreement__c=quote.TeliaSE_Parent_Agreement__c;
        faContract.Agreement_Nr__c=quote.TeliaSE_Agreement_Nr__c;
        faContract.TeliaSE_Type__c=type=='Renegotiation'?'Y':'N';
        faContract.TeliaSE_MC_Sales_Flow_Identifier__c = quote.TeliaSE_MC_Sales_Flow_Identifier__c;
        
        try{
            insert faContract;
            addContactRole(faContract.Id,quote.opportunityId,quote.TeliaSE_Parent_Agreement__c);
        }
        Catch(Exception e)
        {
            throw new ContractException('Error occured while creating the Agreement'+e.getMessage());
        }
        return  faContract.Id;
    }
    
    private static void putLines(Quote currentQuote, List<Id> ids,Date startDate,Date endDate,Id frameAgreementId,String quoteType,Map<Id,Item> itemsMap,String renegotiatedAgreement){
        /*Integer Quan;    
String cmtPeriod;    
String  MobVersion;    
String Segment;    
String Segment1;    
Map<String, String> FAquote = new Map<String, String>();*///Commented for NMP special addons(Do not delete)
        List<vlocity_cmt__ContractLineItem__c> contractLines=new List<vlocity_cmt__ContractLineItem__c>();  
        QuoteLineItem dummyItem;
        Map<Object,QuoteLineItem> quoteLineItemMap=new Map<Object,QuoteLineItem>();  
        String key2;
        Map<String, Object> priorQLIIdMap = new Map<String, Object>();
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>(); 
        List<QuoteLineItem> qliExtract=[SELECT Id,MC_Line_Status__c,quote.TeliaSE_MC_Sales_Flow_Identifier__c,vlocity_cmt__Product2Id__r.TeliaSE_MC_isCallOff_Flag__c,TeliaSE_Root_Product__c,
                                            TeliaSE_Product_Code__c,TeliaSE_ProductType__c,TeliaSE_StartDate__c,MC_Quarantine_Time__c,
                                            TeliaSE_MC_Mobile_WarningActive__c,TeliaSE_MC_Mobile_WarningPercentage__c,
                                            TeliaSE_MC_Mobile_AgreedPercentage__c,TeliaSE_MC_Mobile_FunctionActive__c,
                                            TeliaSE_MC_TP_WarningPercentage__c,TeliaSE_MC_TP_WarningActive__c,TeliaSE_MC_TP_AgreedPercentage__c,
                                            TeliaSE_MC_TP_FunctionActive__c,TeliaSE_Discount_Percentage__c,
                                            vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c,TeliaSE_CommitmentPeriod__c,
                                            TeliaSE_Minimum_Value_Commit__c,TeliaSE_Base_Quantity__c,TeliaSE_Approved_Price__c,
                                            TeliaSE_Approved__c,QuoteId,Quantity,TotalPrice,TeliaSE_MC_Customer_Requested_Price__c,
                                            TeliaSE_MC_Customer_Requested_Percentage__c,vlocity_cmt__ProductHierarchyPath__c,
                                            vlocity_cmt__Product2Id__r.name,vlocity_cmt__RecurringCharge__c,TeliaSE_Target_Price__c,
                                            vlocity_cmt__RecurringManualDiscount__c,vlocity_cmt__RecurringDiscountPrice__c, vlocity_cmt__PriorQuoteLineItemId__c,
                                            vlocity_cmt__OneTimeManualDiscount__c,vlocity_cmt__OneTimeDiscountPrice__c,TeliaSE_ParentClusterCode__c,
                                            vlocity_cmt__OneTimeTotal__c ,vlocity_cmt__RecurringTotal__c,vlocity_cmt__JSONAttribute__c,Subtotal,
                                            vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__c,vlocity_cmt__ParentItemId__c,
                                            vlocity_cmt__RootItemId__c,vlocity_cmt__AssetReferenceId__c,TeliaSE_Comment__c,TeliaSE_Invoice_Fee__c,TeliaSE_Abroad_Call_Discount__c,
                                            TeliaSE_Product_Object_Type__c, TeliaSE_SubsidisedVoice__c, TeliaSE_MC_Campaign_Id__c,TeliaSE_MC_FACallOffQuantity__c,MC_Initial_Order_Quantity__c,MC_Sales_FrameworkPricingMaster__c,vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c
                                            FROM QuoteLineItem where TeliaSE_Root_Product__c in :ids and quoteid=: currentQuote.id];
        
        Map<String,QuoteLineItem> addedClusterSpecialAddOn = new Map<String,QuoteLineItem>();
        Set<String> addedClusters = new Set<String>();
        for(QuoteLineItem quoteLineItem:qliExtract)
        {
            key2 = quoteLineItem.vlocity_cmt__PriorQuoteLineItemId__c != NULL? quoteLineItem.vlocity_cmt__PriorQuoteLineItemId__c  : quoteLineItem.id; 
            qlicalloffflagmap.put(quoteLineItem.vlocity_cmt__AssetReferenceId__c,quoteLineItem.vlocity_cmt__Product2Id__r.TeliaSE_MC_isCallOff_Flag__c);
            priorQLIIdMap.put(quoteLineItem.vlocity_cmt__AssetReferenceId__c, key2);  //We need this map to get the priorQuoteLineItemIds of teh corresposing QLI, as we cannot use lookup fields until and unless they are inserted into DB.
            if(quoteLineItem.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c == 'Framework' && quoteLineItem.MC_Sales_FrameworkPricingMaster__c != null && quotelineitem.TeliaSE_ParentClusterCode__c!= null){
                quoteLineItems.add(quoteLineItem);
                addedClusters.add(quoteLineItem.TeliaSE_ParentClusterCode__c);
            }
            else if (quoteLineItem.TeliaSE_Product_Code__c == 'MOB_SP_ADDON_ABROAD'){
                addedClusterSpecialAddOn.put(quotelineitem.TeliaSE_ParentClusterCode__c,quoteLineItem);
            }           
            else if (quoteLineItem.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c != 'Framework' || (quoteLineItem.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c == 'Framework' && quotelineitem.TeliaSE_ParentClusterCode__c==null)){
                quoteLineItems.add(quoteLineItem);
            }
        }
        for(String cluster:addedClusters){
            quoteLineItems.add(addedClusterSpecialAddOn.get(cluster));
        }
        /*Segment = Segment1 == 'Enterprise SME' || Segment1 == 'Forced BA'? 'SME' : 'LARGE';*///Commented for NMP special addons(Do not delete)

        List<String> hierarchies=new List<String>();
       // system.debug(  frameAgreementId +''+ itemsMap);
        List<vlocity_cmt__ContractLineItem__c> lines=contractLines(quoteLineItems,frameAgreementId,itemsMap,false);
     contractLines.addAll(lines);
        /*List<vlocity_cmt__ContractLineItem__c> lines=contractLines(quoteLineItems,frameAgreementId,itemsMap,false, Quan, FAQuote, cmtPeriod, MobVersion,Segment);*///Commented for NMP special addons.Comment above statement and uncomment this(Do not delete)
        for(vlocity_cmt__ContractLineItem__c cli:lines)
        {
            hierarchies.add(cli.TeliaSE_ProductHierarchy__c);
        }
        Map<Object,vlocity_cmt__ContractLineItem__c> oldLineItemsMap=new Map<Object,vlocity_cmt__ContractLineItem__c>();
        vlocity_cmt__ContractLineItem__c contractLine; 
        Boolean itemExist=false;
        List<String> mqIdList = System.Label.TeliaSE_Master_quote.split(',');
        List<QuoteLineItem> masterLineItems=[SELECT Id,TeliaSE_ParentClusterCode__c,vlocity_cmt__PriorQuoteLineItemId__c,Quote.MC_Commercial_Setup__c,
                                             Product2.TeliaSE_Product_Category__c ,vlocity_cmt__JSONAttribute__c,TeliaSE_Root_Product__r.ProductCode,
                                             TeliaSE_Root_Product__c,MC_Initial_Order_Quantity__c,TeliaSE_ProductType__c,TeliaSE_Target_Price__c,TeliaSE_Product_Code__c,
                                             TeliaSE_StartDate__c,vlocity_cmt__Product2Id__r.ProductCode,TeliaSE_Discount_Percentage__c,vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c,
                                             TeliaSE_CommitmentPeriod__c,TeliaSE_Minimum_Value_Commit__c,MC_Quarantine_Time__c,TeliaSE_MC_Mobile_WarningActive__c,TeliaSE_MC_Mobile_WarningPercentage__c,
                                             TeliaSE_MC_Mobile_AgreedPercentage__c,TeliaSE_MC_Mobile_FunctionActive__c,TeliaSE_MC_TP_WarningPercentage__c,TeliaSE_MC_TP_WarningActive__c,TeliaSE_MC_TP_AgreedPercentage__c,
                                             TeliaSE_MC_TP_FunctionActive__c,TeliaSE_Base_Quantity__c,TeliaSE_Approved_Price__c,TeliaSE_Approved__c,QuoteId,Quantity,TotalPrice,TeliaSE_MC_Customer_Requested_Price__c,
                                             TeliaSE_MC_Customer_Requested_Percentage__c,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__Product2Id__r.name,vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringManualDiscount__c,
                                             vlocity_cmt__RecurringDiscountPrice__c,vlocity_cmt__OneTimeManualDiscount__c,vlocity_cmt__OneTimeDiscountPrice__c,vlocity_cmt__OneTimeTotal__c ,vlocity_cmt__RecurringTotal__c,
                                             vlocity_cmt__AttributeSelectedValues__c,Subtotal,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__c,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c,
                                             TeliaSE_Comment__c,TeliaSE_Invoice_Fee__c,TeliaSE_Abroad_Call_Discount__c,TeliaSE_Product_Object_Type__c,Product2.Name, TeliaSE_SubsidisedVoice__c, TeliaSE_MC_Campaign_Id__c,
                                             MC_Sales_FrameworkPricingMaster__c,vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c,vlocity_cmt__AssetReferenceId__c   FROM QuoteLineItem 
                                             where TeliaSE_Root_Product__c =: itemsMap.keyset() and quoteId IN :mqIdList and vlocity_cmt__ProductHierarchyPath__c NOT IN :hierarchies];
        
        List<QuoteLineItem> newMasterLineItems=new List<QuoteLineItem>();
        
        for(QuoteLineItem item:masterLineItems)
        {
            //quoteLineItemMap.put(item.vlocity_cmt__Product2Id__c+key2, item);
            //system.debug('key3'+key3 + ' '+ item.id);
            priorQLIIdMap.put(item.vlocity_cmt__AssetReferenceId__c, item.id); 
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
        
        List<vlocity_cmt__ContractLineItem__c> masterlines=contractLines(masterLineItems,frameAgreementId,itemsMap,true);
        /*List<vlocity_cmt__ContractLineItem__c> masterlines=contractLines(masterLineItems,frameAgreementId,itemsMap,true, Quan, FAQuote, cmtPeriod, MobVersion,Segment);*///Commented for NMP special addons.Comment above code and uncomment this(Do not delete)
        contractLines.addAll(masterlines);
        if(quoteType == 'Renegotiation')
        {
            
            //masterLineItems.addAll(quoteLineItems);
            //system.debug('sizeOf masterLineItems: '+masterLineItems);
            //masterLineItems = reArrangeQuoteLineItem(masterLineItems);
            List<vlocity_cmt__ContractLineItem__c> duplicatecontractLinesReneg=new List<vlocity_cmt__ContractLineItem__c>();
            Map<Object,vlocity_cmt__ContractLineItem__c> contractItemsMapRN=new Map<Object,vlocity_cmt__ContractLineItem__c>();
            String priorQLIId;
            
            for(vlocity_cmt__ContractLineItem__c contractItem:contractLines)
            {
                priorQLIId= String.valueOf(priorQLIIdMap.get(contractItem.vlocity_cmt__AssetReferenceId__c));
                if(contractItemsMapRN.get(priorQLIId)!=null ){
                    duplicatecontractLinesReneg.add(contractItem);
                }else{
                    contractItemsMapRN.put(priorQLIId, contractItem);
                }
            }
            // Map<Id,Contract> contractRN=new Map<Id,Contract>([select id from Contract where id=:renegotiatedAgreement]); 
            
            List<vlocity_cmt__ContractLineItem__c> oldLineItems=[select id ,vlocity_cmt__ContractId__r.TeliaSE_Invoice_Fee__c,vlocity_cmt__ContractId__r.MC_Payment_Term__c, TeliaSE_RootItemId__c,TeliaSE_ParentClusterCode__c,vlocity_cmt__QuoteLineItem__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__ContractId__c ,TeliaSE_Start_Date__c, vlocity_cmt__LineStatus__c , TeliaSE_Minimum_Value_Commit__c , TeliaSE_Approved__c , MC_Quarantine_Time__c,TeliaSE_Approved_Price__c,TeliaSE_MasterQuote__c,vlocity_cmt__RecurringCharge__c,TeliasSETargetPercentage__c,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_MC_Customer_Requested_Percentage__c,vlocity_cmt__Product2Id__c,name,vlocity_cmt__AttributeSelectedValues__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =:renegotiatedAgreement];
            
            //Contract pastContract = new Contract();
            
            //Contract oldActiveContract = [SELECT Id, TeliaSE_Invoice_Fee__c, MC_Payment_Term__c from Contract where id =:renegotiatedAgreement];
            /*if(conList != null && conList.size() > 0){
renegotiatedContract = conList[0];

}*/
            Set<Id> oldProdId = new Set<Id>();
            for(vlocity_cmt__ContractLineItem__c oldLineItem :oldLineItems)
            {
                oldProdId.add(oldLineItem.vlocity_cmt__Product2Id__c);
                oldLineItemsMap.put(oldLineItem.vlocity_cmt__QuoteLineItem__c,oldLineItem);                
            }
            
            for(vlocity_cmt__ContractLineItem__c renegCli :contractLines){
                String key3= String.valueOf(priorQLIIdMap.get(renegCli.vlocity_cmt__AssetReferenceId__c));
                String parentPrioQLIId= String.valueOf(priorQLIIdMap.get(renegCli.TeliaSE_RootItemId__c));
                vlocity_cmt__ContractLineItem__c oldItemRecord = oldLineItemsMap.get(key3);
                
                if(oldItemRecord !=NULL){
                    if(oldItemRecord.TeliaSE_Start_Date__c != renegCli.TeliaSE_Start_Date__c && renegCli.TeliaSE_ParentItemId__c==NULL)
                    {
                        contractItemsMapRN.get(parentPrioQLIId).vlocity_cmt__LineStatus__c='Updated';
                    }
                    else if((renegCli.TeliaSE_MC_Customer_Requested_Price__c != null &&  renegCli.TeliaSE_MC_Customer_Requested_Price__c !=oldItemRecord.TeliaSE_MC_Customer_Requested_Price__c) || 
                            (renegCli.TeliaSE_MC_Customer_Requested_Percentage__c != null && renegCli.TeliaSE_MC_Customer_Requested_Percentage__c != oldItemRecord.TeliaSE_MC_Customer_Requested_Percentage__c)||
                            (renegCli.vlocity_cmt__OneTimeCharge__c!= null && renegCli.vlocity_cmt__OneTimeCharge__c!= oldItemRecord.vlocity_cmt__OneTimeCharge__c) ||
                            (renegCli.TeliaSE_Minimum_Value_Commit__c !=null && renegCli.TeliaSE_Minimum_Value_Commit__c !=oldItemRecord.TeliaSE_Minimum_Value_Commit__c) ||
                            (renegCli.MC_Quarantine_Time__c != null && renegCli.MC_Quarantine_Time__c !=oldItemRecord.MC_Quarantine_Time__c) ||
                            (oldItemRecord.vlocity_cmt__ContractId__r.TeliaSE_Invoice_Fee__c != null && oldItemRecord.vlocity_cmt__ContractId__r.TeliaSE_Invoice_Fee__c != null && currentQuote.TeliaSE_Invoice_Fee__c != oldItemRecord.vlocity_cmt__ContractId__r.TeliaSE_Invoice_Fee__c) ||
                            (oldItemRecord.vlocity_cmt__ContractId__r.MC_Payment_Term__c != null && oldItemRecord.vlocity_cmt__ContractId__r.MC_Payment_Term__c !=null && currentQuote.MC_Payment_Term__c != oldItemRecord.vlocity_cmt__ContractId__r.MC_Payment_Term__c))
                    {
                        renegCli.vlocity_cmt__LineStatus__c='Updated';
                        if(contractItemsMapRN.get(parentPrioQLIId) != null && contractItemsMapRN.get(parentPrioQLIId).vlocity_cmt__LineStatus__c !='Added')
                        {
                            contractItemsMapRN.get(parentPrioQLIId).vlocity_cmt__LineStatus__c='Updated';
                        }
                    }
                    else if((renegCli.vlocity_cmt__RecurringCharge__c != null && renegCli.vlocity_cmt__RecurringCharge__c != oldItemRecord.vlocity_cmt__RecurringCharge__c) ||
                            (renegCli.TeliasSETargetPercentage__c !=null && renegCli.TeliasSETargetPercentage__c != oldItemRecord.TeliasSETargetPercentage__c))
                    {
                        renegCli.vlocity_cmt__LineStatus__c ='Updated';
                        if(contractItemsMapRN.get(parentPrioQLIId) != null && contractItemsMapRN.get(parentPrioQLIId).vlocity_cmt__LineStatus__c != 'Added')
                        {
                            contractItemsMapRN.get(parentPrioQLIId).vlocity_cmt__LineStatus__c='Updated';
                        }
                    }
                    
                }
                else{
                    //system.debug('Entrd else 416'+priorQLIIdkey2+' '+quoteItem.vlocity_cmt__Product2Id__c);
                    if((renegCLI.TeliaSE_MasterQuote__c &&  !oldProdId.contains(renegCLI.vlocity_cmt__Product2Id__c))||(!renegCLI.TeliaSE_MasterQuote__c)){
                        renegCli.vlocity_cmt__LineStatus__c='Added';
                    }
                    // Updating product offer for any addition to below offer                    
                    If(contractItemsMapRN.get(parentPrioQLIId) != null  && renegCli.TeliaSE_ParentItemId__c != null && contractItemsMapRN.get(parentPrioQLIId).vlocity_cmt__LineStatus__c !='Added')
                    {
                        //system.debug('Entered last else'+contractItemsMapRN.get(quoteItem.TeliaSE_Root_Product__c+parentPrioQLIId).name);
                        contractItemsMapRN.get(parentPrioQLIId).vlocity_cmt__LineStatus__c='Updated';
                    }
                }                
            }
            //inserting Renegotiating Service Agreement contract lines
            if(contractItemsMapRN.size() > 0)
            {
                duplicatecontractLinesReneg.addAll(contractItemsMapRN.values());
                insert duplicatecontractLinesReneg;
            }
        }
        //inserting normal Service Agreement Contract lines
        if(contractLines.size()>0 && String.isEmpty(quoteType))
        {
            insert contractLines;
        }
        
    }
    
    //@future
    private static void addContactRole(Id frameId,Id oppId,string agrtNumber) 
    {
        ContractContactRole contractRole;
        List<ContractContactRole> contractContactRoles=new List<ContractContactRole>();
        List<OpportunityContactRole> oppContractRoles=[SELECT ContactId,Id,IsDeleted,OpportunityId,IsPrimary, Role FROM OpportunityContactRole where OpportunityId=:oppId];
        for(OpportunityContactRole oppRole:oppContractRoles)
        {
            contractRole=new ContractContactRole();
            contractRole.IsPrimary= oppRole.IsPrimary;
            contractRole.ContactId=oppRole.ContactId;
            contractRole.ContractId=frameId;
            contractRole.Role=oppRole.Role;
            
            contractContactRoles.add(contractRole);
        }
        if(contractContactRoles.size()>0)
        {
            insert contractContactRoles;
        }
        //Moved below code in future method as part of performance improvement
        if(agrtNumber== null){
            Contract faCon=[select id,contractNumber,TeliaSE_Parent_Agreement__c from Contract where id=:frameId];
            faCon.TeliaSE_Parent_Agreement__c='RA-'+faCon.contractNumber;
            update faCon;
        }
        
    }
    
    @future
    private static void lockQuote(Id quoteId,String quoteType)
    {
        List<Quote> quoteList=new List<Quote>();
        Opportunity opp=[select id,(select id,status,TeliaSWE_Primary_Quote__c,TeliaSE_locked__c,Type_of_Quote__c from Quotes) from Opportunity where Id in( select OpportunityId from Quote where id=:quoteId)];
        for(Quote quote:opp.quotes)
        {
            if(quote.Id == quoteId )
            {
                quote.TeliaSE_locked__c =true;
                if(String.isEmpty(quoteType))    
                {
                    quote.TeliaSWE_Primary_Quote__c=true;
                }
            }
            else
            {
                if(!quote.TeliaSWE_Primary_Quote__c && quote.Type_of_Quote__c != 'Offer Quote')
                {
                    quote.status='Cancelled';
                }
            }
            quoteList.add(quote);
        }
        if(TeliaSE_checkRecursive.runOnce())
        {
            update quoteList;
        }
        Approval.lock(quoteId, false);
        
    }
    
    private static void updateDates(String item)
    {
        List<QuoteLineItem> quoteItems=new List<QuoteLineItem>();
        Map<Id,Item> items=(Map<Id,Item>)Json.deserialize(item, Map<id,Item>.class);
        for(QuoteLineItem lineItem:[select id,TeliaSE_StartDate__C,TeliaSE_EndDate__C from QuoteLineItem where id =:items.keyset()])
        {
            lineItem.TeliaSE_StartDate__c=items.get(lineItem.id).startDate;
            lineItem.TeliaSE_EndDate__c=items.get(lineItem.id).endDate;
            quoteItems.add(lineItem);
        }
        if(quoteItems.size()>0)
        {
            update quoteItems;
            
        }
    }
    
    private static String updateutilizerAccounts(String revisedcontractId,Id frameContractId, Boolean revisedContract,String salesIdentifier)
    {
        List<Account> accounts=new List<Account>();
        String resultMessage;
        Contract con;
        List<Contract> conList=[select id,status,TeliaSE_MC_sales_flow_identifier__c from Contract where id=:revisedcontractId];
        if(conList.size()>0) {
            con = conList[0];
        }
        
        //Adding for update the utilizers details for new contract in Junction object
        List<Utilizer_Contract_Relationship__c> newUList=new List<Utilizer_Contract_Relationship__c>();
        List<Utilizer_Contract_Relationship__c> oldUList=new List<Utilizer_Contract_Relationship__c>();
        List<Utilizer_Contract_Relationship__c> utilizerList;
        
        if(!revisedContract)  {
            utilizerList = [SELECT Id,Org_Number__c,AccountId__c, ContractNumber__c, Utilizer_Role__c, 
                            Status__c  FROM Utilizer_Contract_Relationship__c 
                            where ContractNumber__c =:revisedcontractId and (Status__c  = 'Aktiv' or Status__c  = 'Draft' or Status__c  = 'PendingActive' or Status__c  = 'Manual')];
        }
        else { utilizerList = [SELECT Id,Org_Number__c,AccountId__c, ContractNumber__c, Utilizer_Role__c, 
                               Status__c  FROM Utilizer_Contract_Relationship__c 
                               where ContractNumber__c =:revisedcontractId ];
             }
        Utilizer_Contract_Relationship__c newUtilizer;
        Utilizer_Contract_Relationship__c oldUtilizer;
        
        if(utilizerList.size() > 0){  
            
            // String salesIdentifier1 = parentCLI[0].vlocity_cmt__ContractId__r.TeliaSE_MC_sales_flow_identifier__c;  
            
            for(Utilizer_Contract_Relationship__c ul:utilizerList) {
                newUtilizer = new Utilizer_Contract_Relationship__c();
                newUtilizer.ContractNumber__c = frameContractId;
                newUtilizer.Org_Number__c = ul.Org_Number__c;
                newUtilizer.AccountId__c = ul.AccountId__c;
                newUtilizer.Utilizer_Role__c = ul.Utilizer_Role__c;
                //Updated as part of LTAART-85
                newUtilizer.Status__c = (ul.Status__c == 'PendingActive'? 'Aktiv': ul.Status__c);
                newUtilizer.Name = 'Nyttjarrelationer';
                newUList.add(newUtilizer);
                
                //Update the old contract's status
                oldUtilizer = new Utilizer_Contract_Relationship__c();
                oldUtilizer.Id = ul.Id;
                oldUtilizer.Status__c = 'Inaktiv';
                oldUList.add(oldUtilizer);
            } 
        }
        if(newUList.size()>0 )//&& oldUList.size()>0)
        {
            insert newUList;
            
            resultMessage = 'RevisedShowUtilizers';
            
            //update oldUList;
        } else resultMessage = 'RevisedDontShowUtilizers';
        
        //////// Ends here ///////////        
        
        // Commenting to add the ultilizers from Junction Object.
        /*     
for(Account acc:[select id,FA_Contract__c from Account where FA_Contract__c=:revisedcontractId])
{
acc.FA_Contract__c=frameContractId;
accounts.add(acc);
}
if(accounts.size()>0)
{
update accounts;
}
/**/    
        if(con != null && revisedContract) {
            con.status='Cancelled';
            con.TeliaSE_Reason_for_Cancellation__c = 'Revised';
            update con;
        }
        return resultMessage;
    }
    /*private static List<vlocity_cmt__ContractLineItem__c> contractLines(List<QuoteLineItem> quoteLineItems, ID frameAgreementId,Map<Id,Item> itemsMap,Boolean isMasterQuote, Integer Quan, Map<String, String> FAQuote, String cmtPeriod,  String MobVersion,String Segment)*///Commented for NMP special addoncode.Comment below and uncomment this (Do not delete)
    private static List<vlocity_cmt__ContractLineItem__c> contractLines(List<QuoteLineItem> quoteLineItems, ID frameAgreementId,Map<Id,Item> itemsMap,Boolean isMasterQuote)
    {
        /*Map<String, MC_Sales_FrameworkPricingMaster__c> prices= new  Map<String, MC_Sales_FrameworkPricingMaster__c>();
Map<Id, MC_Sales_FrameworkPricingMaster__c> faPrices= new  Map<Id, MC_Sales_FrameworkPricingMaster__c>();
Boolean isExistinginFA= false;
List<MC_Sales_FrameworkPricingMaster__c> pricingmaster1= [ select id,MC_Sales_Default_Price_Plan__c ,MC_Sales_Cluster__c,
MC_Sales_Customer_Segment__c,MC_Sales_FrameworkProductCategoryMaster__r.MC_Sales_Product_Codes__c , 
MC_Sales_Commitment_Period__c, MC_Sales_High_Base_Quantity__c,MC_Sales_Low_Base_Quantity__c,
MC_Sales_Object_Type__c,MC_Sales_FrameworkPricePlanMaster__c, MC_Sales_FrameworkPricePlanMaster__r.Name,MC_Sales_Parent__c,
MC_Sales_FrameworkPricePlanMaster__r.MC_Sales_EndDate__c, MC_Sales_FrameworkProductCategoryMaster__c,
MC_Sales_FrameworkProductCategoryMaster__r.name  from MC_Sales_FrameworkPricingMaster__c];

for(MC_Sales_FrameworkPricingMaster__c pm : pricingmaster1){
faPrices.put(pm.Id,pm);
if (pm.MC_Sales_Default_Price_Plan__c == true &&  pm.MC_Sales_High_Base_Quantity__c >= Quan && pm.MC_Sales_Low_Base_Quantity__c <=Quan  && pm.MC_Sales_Parent__c == MobVersion && (pm.MC_Sales_Customer_Segment__c=='ALL' || pm.MC_Sales_Customer_Segment__c ==Segment)&& (pm.MC_Sales_Commitment_Period__c=='ALL' || pm.MC_Sales_Commitment_Period__c ==cmtPeriod)){
String clusterCategory= pm.MC_Sales_Cluster__c != 'ALL' ? pm.MC_Sales_FrameworkProductCategoryMaster__r.Name + pm.MC_Sales_Cluster__c :  pm.MC_Sales_FrameworkProductCategoryMaster__r.Name ;
prices.put(clusterCategory,pm );                                             
}
} 
*///Commented for NMP special addon Code(Do not delete)
        List<vlocity_cmt__ContractLineItem__c> contractLines=new List<vlocity_cmt__ContractLineItem__c>();
        vlocity_cmt__ContractLineItem__c  contractLine;
        
        for(QuoteLineItem qli:quoteLineItems)
        {
            // Added below condition to differentiate products which needs to be added to Contract.
            
            if ((isMasterQuote) || (isMasterQuote == false && qlicalloffflagmap.containskey(qli.vlocity_cmt__RootItemId__c) && qlicalloffflagmap.get(qli.vlocity_cmt__RootItemId__c) == false)){
                /*    if((isMasterQuote)  && qli.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c   == 'Framework'){
String qlClusterCategory2 = qli.TeliaSE_ParentClusterCode__c != NULL ? qli.Product2.TeliaSE_Product_Category__c +qli.TeliaSE_ParentClusterCode__c.toUpperCase() : qli.Product2.TeliaSE_Product_Category__c ;
Id pricePlanId = FAquote.get(qlClusterCategory2);
//String cmtPeriod= ql.TeliaSE_CommitmentPeriod__c;
if(pricePlanId != NULL ){
isExistinginFA = true;
}
else{
isExistinginFA = false;
}
try{
TargetPrice= saveDefaultPricePlan(qli, MobVersion,Segment,cmtPeriod,Quan, pricePlanId, prices, faPrices, isExistinginFA);
}
Catch(Exception e){
System.debug('Sanjoli Exception'+ e.getMessage());
}
} */  //Commented for NMP Special addon(Do not delete)
                
                contractLine=new vlocity_cmt__ContractLineItem__c();
                contractLine.TeliasSETargetPercentage__c=qli.TeliaSE_Discount_Percentage__c;
                contractLine.TeliaSE_Product_Version__c=qli.vlocity_cmt__Product2Id__c !=null ?qli.vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c:null;
                contractLine.TeliaSE_CommitmentPeriod__c=qli.TeliaSE_CommitmentPeriod__c;
                //Start--Code added for US-MCSTO-9037
                if(qli.TeliaSE_Product_Object_Type__c=='TouchPoint Plus Offer Spec' || qli.TeliaSE_Product_Object_Type__c=='Broadband Start Offering Spec'|| qli.TeliaSE_Product_Object_Type__c=='Broadband Pro Offering Spec' || qli.TeliaSE_Product_Object_Type__c=='Broadband Plus Offering Spec' || qli.TeliaSE_Product_Object_Type__c=='Broadband Datanet Offering Spec' || qli.TeliaSE_Product_Object_Type__c=='WIFI/LAN Offering Spec' || qli.TeliaSE_Product_Object_Type__c=='SD-WAN/Firewall Offering Spec'){
                    contractLine.TeliaSE_Base_Quantity__c=double.valueOf(qli.TeliaSE_Base_Quantity__c!= null ? qli.TeliaSE_Base_Quantity__c:'0'); //End--Code added for US-MCSTO-9037
                    contractLine.MC_Initial_Order_Quantity__c = qli.MC_Initial_Order_Quantity__c;
                }else{
                    contractLine.TeliaSE_Base_Quantity__c=double.valueOf(qli.TeliaSE_Base_Quantity__c!= null ? qli.TeliaSE_Base_Quantity__c:'0'); 
                }
                /* if( TargetPrice== NULL && qli.TeliaSE_Target_Price__c != NULL ){
TargetPrice =qli.TeliaSE_Target_Price__c;
}*///Commented for NMP Special Addon(Do not delete)
                contractLine.vlocity_cmt__QuoteLineItem__c = qli.Id;
                
                // #Defect- 3848, Json is updated and the temporary fix implemented is also taken away
                contractLine.MC_Quarantine_Time__c=qli.MC_Quarantine_Time__c;    
                contractLine.TeliaSE_Minimum_Value_Commit__c=qli.TeliaSE_Minimum_Value_Commit__c;
                contractLine.TeliaSE_Approved_Price__c=qli.TeliaSE_Approved_Price__c;
                contractLine.TeliaSE_Approved__c=qli.TeliaSE_Approved__c;
                contractLine.TeliaSE_ProductHierarchy__c=qli.vlocity_cmt__ProductHierarchyPath__c;
                contractLine.TeliaSE_ParentItemId__c=qli.vlocity_cmt__ParentItemId__c;
                contractLine.vlocity_cmt__AssetReferenceId__c=qli.vlocity_cmt__AssetReferenceId__c;
                contractLine.TeliaSE_RootItemId__c=qli.vlocity_cmt__RootItemId__c;
                contractLine.TeliaSE_QuoteItemId__c=qli.Id;
                contractLine.vlocity_cmt__ContractId__c=frameAgreementId;
                contractLine.Name=qli.vlocity_cmt__Product2Id__c != null?qli.vlocity_cmt__Product2Id__r.name:null;
                // contractLine.vlocity_cmt__AttributesData__c=qli.vlocity_cmt__JSONAttribute__c;
                contractLine.vlocity_cmt__AttributesData__c=qli.vlocity_cmt__AttributeSelectedValues__c;
                contractLine.vlocity_cmt__AttributeSelectedValues__c=qli.vlocity_cmt__AttributeSelectedValues__c;
                contractLine.vlocity_cmt__Product2Id__c=qli.vlocity_cmt__Product2Id__c;
                contractLine.vlocity_cmt__Quantity__c=qli.Quantity;
                contractLine.vlocity_cmt__OneTimeCharge__c=qli.vlocity_cmt__OneTimeCharge__c;
                contractLine.vlocity_cmt__OneTimeTotal__c=qli.vlocity_cmt__OneTimeTotal__c;
                contractLine.vlocity_cmt__OneTimeDiscountPrice__c=qli.vlocity_cmt__OneTimeDiscountPrice__c;
                contractLine.vlocity_cmt__OneTimeManualDiscount__c=qli.vlocity_cmt__OneTimeManualDiscount__c;
                contractLine.vlocity_cmt__RecurringTotal__c=qli.vlocity_cmt__RecurringTotal__c;
                contractLine.vlocity_cmt__RecurringCharge__c=qli.TeliaSE_Target_Price__c;
                contractLine.vlocity_cmt__RecurringDiscountPrice__c=qli.vlocity_cmt__RecurringDiscountPrice__c;
                contractLine.vlocity_cmt__RecurringManualDiscount__c=qli.vlocity_cmt__RecurringManualDiscount__c;
                contractLine.vlocity_cmt__OneTimeTotal__c=qli.vlocity_cmt__OneTimeTotal__c ;
                contractLine.TeliaSE_MC_Customer_Requested_Percentage__c=qli.TeliaSE_MC_Customer_Requested_Percentage__c;
                contractLine.TeliaSE_MC_Customer_Requested_Price__c=qli.TeliaSE_MC_Customer_Requested_Price__c;
                contractLine.TeliaSE_Start_Date__c=itemsMap.get(qli.TeliaSE_Root_Product__c)!=null?itemsMap.get(qli.TeliaSE_Root_Product__c).startDate:null;
                contractLine.TeliaSE_End_Date__c=itemsMap.get(qli.TeliaSE_Root_Product__c)!=null?itemsMap.get(qli.TeliaSE_Root_Product__c).endDate:null;
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
                if(qli.TeliaSE_ParentClusterCode__c !=null){
                    contractLine.TeliaSE_ParentClusterCode__c=qli.TeliaSE_ParentClusterCode__c;
                }
                if(qli.MC_Sales_FrameworkPricingMaster__c != null){  
                    MC_Sales_FrameworkPricingMaster__c priceMaster=new MC_Sales_FrameworkPricingMaster__c();
                    priceMaster= [select id,MC_Sales_FrameworkPricePlanMaster__r.MC_Agreement_Control_Service__c from MC_Sales_FrameworkPricingMaster__c where id=:qli.MC_Sales_FrameworkPricingMaster__c];
                    if(priceMaster.MC_Sales_FrameworkPricePlanMaster__r.MC_Agreement_Control_Service__c != null){
                        String a=priceMaster.MC_Sales_FrameworkPricePlanMaster__r.MC_Agreement_Control_Service__c;
                        List<String> agreementcontrol=a.split(';');
                        if (agreementcontrol.size()>0){
                            if(qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_EUROPE'){
                                contractLine.MC_Agreement_Control_Service__c = agreementcontrol[0];
                            }
                            if(qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_OTHER'){
                                contractLine.MC_Agreement_Control_Service__c = agreementcontrol[1];
                            }
                            if(qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_OVERSEAS'){
                                contractLine.MC_Agreement_Control_Service__c = agreementcontrol[2];
                            }
                            if(qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_SOUTH'){
                                contractLine.MC_Agreement_Control_Service__c = agreementcontrol[0];
                            }
                            if(qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_EAST'){
                                contractLine.MC_Agreement_Control_Service__c = agreementcontrol[1];
                            }
                            if(qli.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_WEST'){
                                contractLine.MC_Agreement_Control_Service__c = agreementcontrol[2];
                            }
                        }    
                    }
                } 
                
                
                contractLines.add(contractLine);
            }
        }
        return contractLines;
    }
    //Commented for NMP Special Addon(Do not Delete)
    /* public static Integer saveDefaultPricePlan(QuoteLineItem q, String MobVersion, String Segment1,String cmtPeriod, Integer Quantity, Id ppid,  Map<String, MC_Sales_FrameworkPricingMaster__c> prices,  Map<Id, MC_Sales_FrameworkPricingMaster__c> faPrices, Boolean isExistinginFA){
Double quan = 12; 
String Segment;
String baseQuan;
Integer TargetPrice;
Segment = Segment1 == 'Enterprise SME' || Segment1 == 'Forced BA'? 'SME' : 'LARGE';

//List<MC_Sales_FrameworkPricingMaster__c> pricingmaster1= [ select id,MC_Sales_Default_Price_Plan__c ,MC_Sales_Cluster__c,MC_Sales_Customer_Segment__c,MC_Sales_FrameworkProductCategoryMaster__r.MC_Sales_Product_Codes__c    , MC_Sales_Commitment_Period__c, MC_Sales_High_Base_Quantity__c,MC_Sales_Low_Base_Quantity__c   ,MC_Sales_Object_Type__c,MC_Sales_FrameworkPricePlanMaster__c, MC_Sales_FrameworkPricePlanMaster__r.Name,  MC_Sales_FrameworkPricePlanMaster__r.MC_Sales_EndDate__c, MC_Sales_FrameworkProductCategoryMaster__c,MC_Sales_FrameworkProductCategoryMaster__r.name  from   MC_Sales_FrameworkPricingMaster__c where( MC_Sales_Default_Price_Plan__c = true and  MC_Sales_High_Base_Quantity__c >=:Quantity and MC_Sales_Low_Base_Quantity__c <=:Quantity  and MC_Sales_Parent__c=:MobVersion and (MC_Sales_Customer_Segment__c='ALL' or MC_Sales_Customer_Segment__c =:Segment)and (MC_Sales_Commitment_Period__c='ALL' or MC_Sales_Commitment_Period__c =:cmtPeriod) and id !=: id) or (id != '' and  id=: id)];
if(prices.size()>0 && isExistinginFA == false){  
if( q != NULL){ 
String qlClusterCategory= q.TeliaSE_ParentClusterCode__c != NULL ? q.Product2.TeliaSE_Product_Category__c +q.TeliaSE_ParentClusterCode__c.toUpperCase() : q.Product2.TeliaSE_Product_Category__c ;
MC_Sales_FrameworkPricingMaster__c pricePlan = prices.get(qlClusterCategory);
Id pricePlanId = pricePlan.Id;
List<String> prices1 =(pricePlan.MC_Sales_FrameworkPricePlanMaster__r.Name).split(',');
List<String> codes = (pricePlan.MC_Sales_FrameworkProductCategoryMaster__r.MC_Sales_Product_Codes__c).split(';');
Integer count=0;
Integer index= -1;
for(String i: codes){
if(q.TeliaSE_Product_Code__c==i ){
index = count;    
break;    
}
count ++;
}
Integer p;
if( index>=0){
p= Integer.valueOf(prices1[index]);    
TargetPrice = p;   
}
}
}
if(faprices.size()>0 && isExistinginFA == true && (ppid!=NULL) ){                 
if( q != NULL){   
MC_Sales_FrameworkPricingMaster__c pricePlan = faPrices.get(ppid);
//String pricePlanId1 = Stirng.valueOf(pricePlan.Id);
List<String> prices1 =(pricePlan.MC_Sales_FrameworkPricePlanMaster__r.Name).split(',');
List<String> codes = (pricePlan.MC_Sales_FrameworkProductCategoryMaster__r.MC_Sales_Product_Codes__c).split(';');
Integer count=0;
Integer index= -1;
for (String i: codes){
if(q.TeliaSE_Product_Code__c==i ){
index = count;    
break;    
}
count ++;    
}
Integer p;
if( index>=0){
p= Integer.valueOf(prices1[index]);    
TargetPrice = p;   
}
}
}
return TargetPrice ; 
}
*/
    
    /*-----------------------------------------------------------------------------------------------------------
**Name        :        UpdateRootProductOffer & Format(String)
**Created By  :        Abhinav Gupta
**Sprint      :        Sprint 13
**User Story  :        MCSTO- 4043
**Description :        Update Parent-Level Code to multi picklist for updating offer cart items based on type of portoflio in cart.
-----------------------------------------------------------------------------------------------------------*/
    public static String UpdateRootProductOffer (String quoteId)
    {
        //Validating Inputs       
        String offerProducts;
        Try 
        {
            //Declaring Variables
            Boolean isMobile = false;
            Boolean mobileExist = false;            
            List<String> parentList = new List<String>();
            List<String> offerList = new List<String>();
            
            //Extracting Data From Objects
            List<QuoteLineItem> qliList = [Select id,TeliaSE_Product_Code__c from QuoteLineItem where vlocity_cmt__ParentItemId__c = Null AND QuoteId =: quoteId];
            
            // Logic for adding Parent Offers productCode to parentList
            for(QuoteLineItem qli:qliList)
            {
                parentList.add((String)qli.TeliaSE_Product_Code__c);
            }     
            //Code to include New Offer codes for those which are not available in FA quote.
            
            List<TeliaSE_PortfolioIdentifiers__c> ProdIdList  = TeliaSE_PortfolioIdentifiers__c.getAll().Values();
            for (TeliaSE_PortfolioIdentifiers__c product : ProdIdList)
            {   
                if(product.Name.Contains('Mobile'))
                {
                    isMobile = true;
                }
                else
                {
                    isMobile = false;
                }
                
                for(String parent : parentList)
                {                                       
                    if(parent == product.OldProductCode__c && product.OldProductCode__c != Null )
                    {       
                        offerList.add(product.OldProductCode__c);
                        
                        if(isMobile)
                        {
                            mobileExist = true;
                        }
                    }
                    else if (parent == product.NewProductCode__c && product.NewProductCode__c != Null && isMobile)
                    {                         
                        
                        offerList.add(product.NewProductCode__c);
                        mobileExist = true;
                        
                    }
                }
                
                If(!isMobile)
                {
                    offerList.add(product.NewProductCode__c);
                }
            }
            
            If(mobileExist== false)
            {
                for(TeliaSE_PortfolioIdentifiers__c product : ProdIdList)
                {
                    if(product.Name.Contains('Mobile'))
                    {
                        offerList.add(product.NewProductCode__c);
                    }
                }
            }
            // Updating the parentList to quoteLevel   
            Quote q1 = new Quote();
            q1.Id = quoteId;
            q1.TeliaSE_MC_OfferProductCodes__c = format(offerList);
            update q1;
        }
        catch (Exception e)
        {         
            System.debug('Exception'+e);  
        }
        return offerProducts;  
        
    } 
    
    public static String format(List<String> values) 
    {
        if (values == null) 
            return null;
        return String.join(values, ';');
    }
    
    /*public static List<quoteLineItem> reArrangeQuoteLineItem (List<QuoteLineItem> masterQuoteLines)
{
List<QuoteLineItem> qliListArranged = new List<QuotelineItem>();
List<QuoteLineItem> qliListParent = new List<QuotelineItem>();
List<QuoteLineItem> qliListChild = new List<QuotelineItem>();
for(QuoteLineItem qli: masterQuoteLines)
{
if(test.isRunningTest() || qli.vlocity_cmt__ParentItemId__c != null)
{
qliListChild.add(qli);    
}
else
{
qliListParent.add(qli);
}
}
If(qliListParent!= null && qliListParent.size()>0)
{
qliListArranged.addAll(qliListParent);    
}
If(qliListChild!= null && qliListChild.size()>0)
{
qliListArranged.addAll(qliListChild);    
}
return qliListArranged;
}*/
    
    /*  public static void updateOfferQuote(Map<String, Object> inputMap, Map<String, Object> outMap){
String oppId = String.valueOf(inputMap.get('oppId'));
String ContractId = String.valueOf(inputMap.get('ContractId'));

List<Quote> quote = new List<Quote>([select Id,vlocity_cmt__FrameContractId__c,RecordType.DeveloperName from Quote where RecordType.DeveloperName ='Offer' and OpportunityId =:oppId and Status ='Draft']);
List<Quote> quotetoupdate = new List<Quote>();
if(quote.size()>0){ 
for(Quote qut : quote){
Quote q = new Quote();
q.id = qut.Id;
q.vlocity_cmt__FrameContractId__c = ContractId;
quotetoupdate.add(q);
}
update quotetoupdate;
}
}*/
    
    /*  
* Author: Vamsi D  
* Description: Allow addition of utilizers addition for standalone offers.  
*/  
    public static void utilizerFlag(Map<String, Object> inputMap, Map<String, Object> outMap){  
        String restrictedObjectTypes = System.Label.mcRestrictedUtilizerAddition_StandAloneOffers;  
        List<String> restrictedObjSet = restrictedObjectTypes.split(';');  
        List<Object> cliParentList = (List<Object>)inputMap.get('CLIParent');  
        String madamAgreementNo = inputMap.containsKey('MadamAgreementNr') ?(String)inputMap.get('MadamAgreementNr'):null;
        //Changed as part of MCSTO-10165
        Set<String> parentCLI = new Set<String>();  
        for(Object eachCLI : cliParentList){  
            Map<String,Object> tempMap = (Map<String,Object>)eachCLI;  
            parentCLI.add((String)tempMap.get('ObjectType')); 
        }    
        parentCLI.removeAll(restrictedObjSet);  
                    /*if(parentObjecttype.contains('Mobile Offer Specification')){  
            if(salesIdentifier == 'Omforhandling' && parentCLI.get('Mobile Offer Specification') != 'Active'){
            isMobileChanged = true;  
            }else{  
            outMap.put('isMobileExists',true);  
            }
            }
            outMap.put('isMobileChanged',isMobileChanged);*/
        if(parentCLI.size() == 0 && String.isBlank(madamAgreementNo)){  //Changed as part of MCSTO-10165 - skip utilizer addition if only ITdaas & no mobile(in amanda or legacy)
            outMap.put('skipUtilizerImport',true);
        }else{  
            outMap.put('skipUtilizerImport',false);  
        }
    }
    
    //LTAT-17187
    //Developer: Abhinav Gupta
    //Description: As a seller, We can modify start/EndDates for offerings in a contract
    //We capture the updates, Modify the start/EndDate of the contract line item, Quotelineitem and contract.
    public static void saveContractDates(Map<String, Object> inputs){
        try{
            Date startDate,endDate;
            String contextId = String.valueOf(inputs.get('ContextId'));
            Map<String,Object> quoteLinesFiltered = (Map<String,Object>) inputs.get('SI_FilteredLines');
            List<Object> quoteLines = (List<Object>)  quoteLinesFiltered.get('Line');
            Map<string,Map<String,Date>> rootToDatesMap = new Map<String,Map<String,Date>>();
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            for(Object obj:quoteLines){
                Map<String,Object> quoteline = (Map<String,Object>) obj;
                if(startDate==null || (startDate!=null && startDate > Date.valueOf(String.valueOf(quoteline.get('startDate'))))){
                    startDate = Date.valueOf(String.valueOf(quoteline.get('startDate')));
                }
                if(endDate==null || (endDate!=null && endDate < Date.valueOf(String.valueOf(quoteline.get('endDate'))))){
                    endDate = Date.valueOf(String.valueOf(quoteline.get('endDate')));
                }
                if(!(Boolean)quoteline.get('disableDate')){                    
                    Map<String,Date> dateMap = new Map<String,Date>();
                    dateMap.put('StartDate',Date.valueOf(String.valueOf(quoteline.get('startDate'))));
                    dateMap.put('EndDate',Date.valueOf(String.valueOf(quoteline.get('endDate'))));
                    rootToDatesMap.put(String.valueOf(quoteline.get('RootProduct')),dateMap);
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.id = String.valueOf(quoteline.get('quoteLineItemId'));
                    qli.TeliaSE_EndDate__c = Date.valueOf(String.valueOf(quoteline.get('endDate')));
                    qli.TeliaSE_StartDate__c = Date.valueOf(String.valueOf(quoteline.get('startDate')));
                    qliList.add(qli);
                }
            }           
            //Update Max/Min Dates on contract 
            Contract con = new Contract();
            con.id = contextId;
            con.StartDate = startDate;
            con.EndDate = endDate;          
            try{
                update con;  
            }catch(Exception e){
                system.debug(e);
            }
            
            //Update Dates on corresponding quoteLineItems  
            try{
                update qliList;
            }catch(Exception e){
                system.debug(e);
            }
            
            //Query contractLines updated and update dates
            List<vlocity_cmt__ContractLineItem__c> cliList = new List<vlocity_cmt__ContractLineItem__c>();
            for(vlocity_cmt__ContractLineItem__c cli : [Select id,TeliaSE_Root_Product__c from vlocity_cmt__ContractLineItem__c where TeliaSE_Root_Product__c in: rootToDatesMap.keySet() and vlocity_cmt__ContractId__c =:  contextId]){
                vlocity_cmt__ContractLineItem__c cliNew =  new vlocity_cmt__ContractLineItem__c();
                cliNew.id = cli.id;
                cliNew.TeliaSE_Start_Date__c = rootToDatesMap.get(cli.TeliaSE_Root_Product__c).get('StartDate');
                cliNew.TeliaSE_End_Date__c = rootToDatesMap.get(cli.TeliaSE_Root_Product__c).get('EndDate');
                cliList.add(cliNew);
            }
            try{
                database.update(cliList,false);                
            }catch(Exception e){
                system.debug(e);
            }
        }catch(Exception e2){
            system.debug(e2);
        }
    }
  
}