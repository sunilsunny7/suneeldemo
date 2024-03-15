global class Fiber_ConntractServices implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        if(methodName.equals('createQuoteFromContract')){
            Fiber_ConntractServices.createQuoteLineItemFromContract(inputMap, outMap);
        }else if(methodName.equals('createContractLineItemFromQuote')){
            Fiber_ConntractServices.createContractLineItemFromQuote(inputMap, outMap);
        }
        else{
            result = false; 
        }
        return result;          
    }
    public static Quote getNewQuote(string oppName, string ctype, string contractId, string OppId){
        Map<string, string> quoteRType = new Map<string, string>();
        quoteRType.put('Individual Agreement', 'Individual Quote');
        quoteRType.put('Frame Agreement', 'FA Quote');
        quoteRType.put('CAwoFA', 'CA Quote');
        quoteRType.put('CAwithFA', 'CA Quote of FA');
        
        string rname = quoteRType.get(ctype);
        system.debug('record type name : '+rname);
        Id devRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(rname).getRecordTypeId();
        system.debug('record type devRecordTypeId : '+devRecordTypeId);
        List<Contract> cntr = [SELECT Id,Org_Nr__c,Agreement_KO_nr__c,Frame_Agreement_ID__c,ContractNumber,TeliaSE_Fiber_Base_Contract_Number__c, TeliaSE_Fiber_BaseContractId__c,Pricebook2Id,vlocity_cmt__OriginalContractId__c,TeliaSE_Previous_Contract_Number__c, Fiber_Contract_Type__c, TeliaSE_Fiber_Brand__c, TeliaSE_Fiber_Upsell__c, TeliaSE_Fiber_Revenues__c, TeliaSE_Fiber_Return_Of_Investement__c, TeliaSE_Fiber_Payback_Y__c, TeliaSE_Fiber_One_time_Property_Owner__c, TeliaSE_Fiber_OPEX__c, TeliaSE_Fiber_EBIT_Percentage__c, TeliaSE_Fiber_Depreciation__c, TeliaSE_Fiber_Customer_Placed_Equipment__c, TeliaSE_Fiber_Contract_Term_Y__c, TeliaSE_Fiber_Capex_Infra__c, TeliaSE_Fiber_ACK_DCF__c, vlocity_cmt__TotalOneTimeDiscount__c, vlocity_cmt__TotalMonthlyDiscount__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__OpportunityId__c, vlocity_cmt__PriceListId__c, AccountId, Name FROM Contract where id=:contractId];
        
        system.debug('cntr size : '+cntr.size());
        
        Quote q = new Quote();
        if(cntr != null && cntr.size() > 0){
            system.debug('inside if');
            q.Name = oppName;
            q.RecordTypeId = devRecordTypeId;
            q.Pricebook2Id  = cntr[0].Pricebook2Id;
            //q.RecordTypeId = devRecordTypeId;
            //q.Brand__c = cntr.TeliaSE_Fiber_Brand__c;
            q.TeliaSE_Fiber_Upsell__c = cntr[0].TeliaSE_Fiber_Upsell__c;
            q.TeliaSE_Fiber_Base_Contract_Number__c = cntr[0].TeliaSE_Fiber_Base_Contract_Number__c;
            q.TeliaSE_Previous_Contract_Number__c = cntr[0].ContractNumber; 
            q.TeliaSE_Fiber_Previous_ContractId__c = contractId;
            q.TeliaSE_Fiber_Base_COntractID__c = cntr[0].TeliaSE_Fiber_BaseContractId__c != null ? cntr[0].TeliaSE_Fiber_BaseContractId__c : null;
            
            q.TeliaSE_Fiber_Revenues__c = cntr[0].TeliaSE_Fiber_Revenues__c;
            q.TeliaSE_Fiber_Return_Of_Investement__c = cntr[0].TeliaSE_Fiber_Return_Of_Investement__c;
            q.TeliaSE_Fiber_Payback_Y__c = cntr[0].TeliaSE_Fiber_Payback_Y__c;
            q.TeliaSE_Fiber_One_time_Property_Owner__c = cntr[0].TeliaSE_Fiber_One_time_Property_Owner__c;
            q.TeliaSE_Fiber_OPEX__c = cntr[0].TeliaSE_Fiber_OPEX__c;
            q.TeliaSE_Fiber_EBIT_Percentage__c = cntr[0].TeliaSE_Fiber_EBIT_Percentage__c;
            q.TeliaSE_Fiber_Depreciation__c = cntr[0].TeliaSE_Fiber_Depreciation__c;
            q.TeliaSE_Fiber_Customer_Placed_Equipment__c = cntr[0].TeliaSE_Fiber_Customer_Placed_Equipment__c;
            q.TeliaSE_Fiber_Contract_Term_Y__c = cntr[0].TeliaSE_Fiber_Contract_Term_Y__c;
            q.TeliaSE_Fiber_Capex_Infra__c = cntr[0].TeliaSE_Fiber_Capex_Infra__c;
            q.TeliaSE_Fiber_ACK_DCF__c = cntr[0].TeliaSE_Fiber_ACK_DCF__c;
            //Added as part of LTAT-8369
            if(cntr[0].vlocity_cmt__PriceListId__c != null){
                q.vlocity_cmt__PriceListId__c = cntr[0].vlocity_cmt__PriceListId__c;
            }
            else{
               q.vlocity_cmt__PriceListId__c = [Select Id from vlocity_cmt__PriceList__c where Name = 'MDU'].Id; 
            }
            q.vlocity_cmt__FrameContractId__c = cntr[0].Frame_Agreement_ID__c;
            q.Fiber_Agreement_KO_nr__c = cntr[0].Agreement_KO_nr__c;
            q.Org_Nr__c = cntr[0].Org_Nr__c;
            q.TeliaSE_Retention_Quote__c = true;
            q.TeliaSE_Locked__c = false;
            q.opportunityid = OppId;
            insert q;
        }       
        return q;
    }
    /*
public static void updateContract(Id contractId){
system.debug('inside updateContract, contractId = '+contractId);
Contract contr = new Contract();
if(contractId != null){
contr = [select Id, TeliaSE_Fiber_Previous_ContractId__c, ContractNumber from Contract where id = :contractId limit 1];
if(contr != null && contr.TeliaSE_Fiber_Previous_ContractId__c == null){
contr.TeliaSE_Fiber_BaseContractId__c = contr.Id;
contr.TeliaSE_Fiber_Base_Contract_Number__c = contr.ContractNumber;
system.debug('inside updateContract, contr = '+contr);
update contr;
}
}
*/
     
    public static void updateContract(Id contractId){
        system.debug('inside updateContract, contractId = '+contractId);
        Contract contr = new Contract();
        if(contractId != null){
            contr = [select Id, TeliaSE_Previous_Contract_Number__c, ContractNumber from Contract where id = :contractId limit 1];
            if(contr != null && contr.TeliaSE_Previous_Contract_Number__c  == null){
                contr.TeliaSE_Fiber_BaseContractId__c = contr.Id;
                contr.TeliaSE_Fiber_Base_Contract_Number__c = contr.ContractNumber;
                system.debug('inside updateContract, contr = '+contr);
                update contr;
            }
     }
    }
     public static void updateContractPreviousandBaseId(Id contractId){
        system.debug('inside updateContract, contractId = '+contractId);
        Contract contr = new Contract();
        if(contractId != null){
            contr = [select Id, TeliaSE_Previous_Contract_Number__c,TeliaSE_Fiber_Base_Contract_Number__c from Contract where id = :contractId limit 1];
            String pConNumber = contr.TeliaSE_Previous_Contract_Number__c;
            String bConNumber = contr.TeliaSE_Fiber_Base_Contract_Number__c;
            System.debug('pconNUmber'+pConNumber);
            System.debug('bConNumber'+bConNumber);
            if(contr != null){
                Contract contrprev = new Contract();
                COntract contrbase = new Contract();
                if(pConNumber!=null){
                   contrprev = [select id from contract where ContractNumber=:pConNumber];   
                }
                contrbase = [select id from contract where ContractNumber=:bConNumber];                
                contr.TeliaSE_Fiber_Previous_ContractId__c = contrprev.Id;
                contr.TeliaSE_Fiber_BaseContractId__c = contrbase.Id;
                System.debug('TeliaSE_Fiber_Previous_ContractId__c'+contr.TeliaSE_Fiber_Previous_ContractId__c);
                System.debug('TeliaSE_Fiber_BaseContractId__c'+contr.TeliaSE_Fiber_BaseContractId__c);
                system.debug('inside updateContract, contr = '+contr);
                update contr;
            }
        }
     }
     
        
        /*else{
contr.TeliaSE_Fiber_BaseContractId__c = BaseContractId != null ? BaseContractId : null;
contr.TeliaSE_Fiber_Previous_ContractId__c = PreviousContractId != null ? PreviousContractId : null;
update contr;
}*/
    
    public static void createQuoteLineItemFromContract(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{
            string contractId = String.ValueOf(inputMap.get('contractId'));
            
            string oppName = String.ValueOf(inputMap.get('OpportunityName'));
            string contractType = String.ValueOf(inputMap.get('cType'));
            string OppId = String.ValueOf(inputMap.get('OpportunityId'));
            
            Quote newQuote = getNewQuote(oppName, contractType, contractId, OppId);
            
            
            /*START New*/
            List<Contract> qList = [select vlocity_cmt__QuoteId__c from Contract where id=:contractId];
            If(qList != null && qList.size()>0){
                List<QuoteLineItem> qLines = [SELECT QuoteId, LineNumber, PricebookEntryId, OpportunityLineItemId, Quantity, UnitPrice, Discount, HasRevenueSchedule, HasQuantitySchedule, Description, Product2Id, SortOrder, HasSchedule, ListPrice, Subtotal, TotalPrice, vlocity_cmt__Action__c, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ConnectDate__c, vlocity_cmt__CpqCardinalityMessage__c, vlocity_cmt__CpqMessageData__c, vlocity_cmt__CurrencyPaymentMode__c, vlocity_cmt__DisconnectDate__c, vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c, vlocity_cmt__EffectiveOneTimeTotal__c, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__Filter__c, vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__ItemName__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__JSONNode__c, vlocity_cmt__LineNumber__c, vlocity_cmt__Modification__c, vlocity_cmt__OneTimeCalculatedPrice__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeDiscountPrice__c, vlocity_cmt__OneTimeLoyaltyPrice__c, vlocity_cmt__OneTimeLoyaltyTotal__c, vlocity_cmt__OneTimeManualDiscount__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__OverageCalculatedPrice__c, vlocity_cmt__OverageCharge__c, vlocity_cmt__OverageDiscountPrice__c, vlocity_cmt__OverageManualDiscount__c, vlocity_cmt__OverageTotal__c, vlocity_cmt__OverageUOM__c, vlocity_cmt__ParentItemId__c, vlocity_cmt__PremisesId__c, vlocity_cmt__PricingLogData__c, vlocity_cmt__Product2Id__c, vlocity_cmt__ProductAttribXN__c, vlocity_cmt__ProductHierarchyPath__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__Query__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__RecurringDiscountPrice__c, vlocity_cmt__RecurringManualDiscount__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__RecurringUOM__c, vlocity_cmt__Recurring_UOM__c, vlocity_cmt__RelationshipType__c, vlocity_cmt__RootItemId__c, vlocity_cmt__SequenceNumber__c, vlocity_cmt__SerialNumber__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceDate__c, vlocity_cmt__SubAction__c, vlocity_cmt__AttributeMetadataChanges__c, vlocity_cmt__SubscriptionId__c, TeliaSE_AM_Mandate_Percentage__c, TeliaSE_Approved_Flag__c, TeliaSE_Approved_Price__c, TeliaSE_Approved__c, 
                //TeliaSE_Base_Quantity__c, 
                TeliaSE_CM_Mandate_Percentage__c, TeliaSE_Ceiling_Price__c, TeliaSE_CommitmentPeriod__c, TeliaSE_Discount_Percentage__c, TeliaSE_EndDate__c, TeliaSE_Flag_Check__c, TeliaSE_Flag__c, TeliaSE_MC_Customer_Requested_Percentage__c, TeliaSE_MC_Customer_Requested_Price__c, TeliaSE_Minimum_Value_Commit__c, TeliaSE_Root_Product__c, TeliaSE_SD_Mandate_Percentage__c, TeliaSE_SM_Mandate_Percentage__c, TeliaSE_StartDate__c, TeliaSE_SubsidisedVoice__c, TeliaSE_Target_Price__c, TeliaSE_Abroad_Call_Discount__c, TeliaSE_Comment__c, TeliaSE_Invoice_Fee__c, TeliaSE_PriceTypeCategory__c, TeliaSE_Nullify_Check__c, vlocity_cmt__CpqPricingMessage__c, vlocity_cmt__EffectiveOneTimeCostTotal__c, vlocity_cmt__EffectiveRecurringCostTotal__c, vlocity_cmt__OneTimeCostTotal__c, vlocity_cmt__OneTimeCost__c, vlocity_cmt__OneTimeMargin__c, vlocity_cmt__RecurringCostTotal__c, vlocity_cmt__RecurringCost__c, vlocity_cmt__RecurringMargin__c, vlocity_cmt__ServicePointId__c, TeliaSE_Fiber_Customer_Requested_Price__c, TeliaSE_fiber_Antal__c, TeliaSE_fiber_Engngsavgift__c, TeliaSE_Fiber_Frame_Agreement__c, TeliaSE_fiber_Rabatt__c, Fiber_Approved_Price__c, Fiber_Customer_Requested_Price__c FROM quotelineitem where QuoteId = :qList[0].vlocity_cmt__QuoteId__c];
                List<quotelineitem> qLineItemsToBeInserted = new List<quotelineitem>();
                if(qLines != null && qLines.size() > 0){
                    system.debug('qLines======'+qLines);
                    for(quotelineitem qItem : qLines){
                        quotelineitem qli = new quotelineitem();
                        
                        qli.quoteId = newQuote.Id;
                        //qli.LineNumber  = qItem.LineNumber;
                        qli.PricebookEntryId  = qItem.PricebookEntryId;
                        qli.OpportunityLineItemId= qItem.OpportunityLineItemId;
                        qli.Quantity = qItem.Quantity;
                        qli.UnitPrice= qItem.UnitPrice;
                        qli.Discount = qItem.Discount;
                        //qli.HasRevenueSchedule= qItem.HasRevenueSchedule;
                        //qli.HasQuantitySchedule  = qItem.HasQuantitySchedule;
                        qli.Description = qItem.Description;
                        qli.Product2Id  = qItem.Product2Id;
                        qli.SortOrder= qItem.SortOrder;
                        //qli.HasSchedule = qItem.HasSchedule;
                        //qli.ListPrice= qItem.ListPrice;
                        //qli.Subtotal = qItem.Subtotal;
                        //qli.TotalPrice  = qItem.TotalPrice;
                        qli.vlocity_cmt__Action__c  = qItem.vlocity_cmt__Action__c;
                        qli.vlocity_cmt__AssetReferenceId__c = qItem.vlocity_cmt__AssetReferenceId__c;
                        qli.vlocity_cmt__AttributeSelectedValues__c= qItem.vlocity_cmt__AttributeSelectedValues__c;
                        qli.vlocity_cmt__BillingAccountId__c = qItem.vlocity_cmt__BillingAccountId__c;
                        qli.vlocity_cmt__ConnectDate__c= qItem.vlocity_cmt__ConnectDate__c;
                        qli.vlocity_cmt__CpqCardinalityMessage__c  = qItem.vlocity_cmt__CpqCardinalityMessage__c;
                        qli.vlocity_cmt__CpqMessageData__c= qItem.vlocity_cmt__CpqMessageData__c;
                        qli.vlocity_cmt__CurrencyPaymentMode__c = qItem.vlocity_cmt__CurrencyPaymentMode__c;
                        qli.vlocity_cmt__DisconnectDate__c= qItem.vlocity_cmt__DisconnectDate__c;
                        qli.vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c = qItem.vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c;
                        qli.vlocity_cmt__EffectiveOneTimeTotal__c  = qItem.vlocity_cmt__EffectiveOneTimeTotal__c;
                        qli.vlocity_cmt__EffectiveQuantity__c= qItem.vlocity_cmt__EffectiveQuantity__c;
                        qli.vlocity_cmt__EffectiveRecurringTotal__c= qItem.vlocity_cmt__EffectiveRecurringTotal__c;
                        qli.vlocity_cmt__Filter__c  = qItem.vlocity_cmt__Filter__c;
                        qli.vlocity_cmt__InCartQuantityMap__c= qItem.vlocity_cmt__InCartQuantityMap__c;
                        qli.vlocity_cmt__ItemName__c= qItem.vlocity_cmt__ItemName__c;
                        qli.vlocity_cmt__JSONAttribute__c = qItem.vlocity_cmt__JSONAttribute__c;
                        qli.vlocity_cmt__JSONNode__c= qItem.vlocity_cmt__JSONNode__c;
                        qli.vlocity_cmt__LineNumber__c = qItem.vlocity_cmt__LineNumber__c;
                        qli.vlocity_cmt__Modification__c  = qItem.vlocity_cmt__Modification__c;
                        qli.vlocity_cmt__OneTimeCalculatedPrice__c = qItem.vlocity_cmt__OneTimeCalculatedPrice__c;
                        qli.vlocity_cmt__OneTimeCharge__c = qItem.vlocity_cmt__OneTimeCharge__c;
                        qli.vlocity_cmt__OneTimeDiscountPrice__c= qItem.vlocity_cmt__OneTimeDiscountPrice__c;
                        qli.vlocity_cmt__OneTimeLoyaltyPrice__c = qItem.vlocity_cmt__OneTimeLoyaltyPrice__c;
                        qli.vlocity_cmt__OneTimeLoyaltyTotal__c = qItem.vlocity_cmt__OneTimeLoyaltyTotal__c;
                        qli.vlocity_cmt__OneTimeManualDiscount__c  = qItem.vlocity_cmt__OneTimeManualDiscount__c;
                        qli.vlocity_cmt__OneTimeTotal__c  = qItem.vlocity_cmt__OneTimeTotal__c;
                        qli.vlocity_cmt__OverageCalculatedPrice__c = qItem.vlocity_cmt__OverageCalculatedPrice__c;
                        qli.vlocity_cmt__OverageCharge__c = qItem.vlocity_cmt__OverageCharge__c;
                        qli.vlocity_cmt__OverageDiscountPrice__c= qItem.vlocity_cmt__OverageDiscountPrice__c;
                        qli.vlocity_cmt__OverageManualDiscount__c  = qItem.vlocity_cmt__OverageManualDiscount__c;
                        qli.vlocity_cmt__OverageTotal__c  = qItem.vlocity_cmt__OverageTotal__c;
                        qli.vlocity_cmt__OverageUOM__c = qItem.vlocity_cmt__OverageUOM__c;
                        qli.vlocity_cmt__ParentItemId__c  = qItem.vlocity_cmt__ParentItemId__c;
                        qli.vlocity_cmt__PremisesId__c = qItem.vlocity_cmt__PremisesId__c;
                        qli.vlocity_cmt__PricingLogData__c= qItem.vlocity_cmt__PricingLogData__c;
                        qli.vlocity_cmt__Product2Id__c = qItem.vlocity_cmt__Product2Id__c;
                        qli.vlocity_cmt__ProductAttribXN__c  = qItem.vlocity_cmt__ProductAttribXN__c;
                        qli.vlocity_cmt__ProductHierarchyPath__c= qItem.vlocity_cmt__ProductHierarchyPath__c;
                        qli.vlocity_cmt__ProvisioningStatus__c  = qItem.vlocity_cmt__ProvisioningStatus__c;
                        qli.vlocity_cmt__Query__c= qItem.vlocity_cmt__Query__c;
                        qli.vlocity_cmt__RecurringCalculatedPrice__c  = qItem.vlocity_cmt__RecurringCalculatedPrice__c;
                        qli.vlocity_cmt__RecurringCharge__c  = qItem.vlocity_cmt__RecurringCharge__c;
                        qli.vlocity_cmt__RecurringDiscountPrice__c = qItem.vlocity_cmt__RecurringDiscountPrice__c;
                        qli.vlocity_cmt__RecurringManualDiscount__c= qItem.vlocity_cmt__RecurringManualDiscount__c;
                        qli.vlocity_cmt__RecurringTotal__c= qItem.vlocity_cmt__RecurringTotal__c;
                        qli.vlocity_cmt__RecurringUOM__c  = qItem.vlocity_cmt__RecurringUOM__c;
                        qli.vlocity_cmt__Recurring_UOM__c = qItem.vlocity_cmt__Recurring_UOM__c;
                        qli.vlocity_cmt__RelationshipType__c = qItem.vlocity_cmt__RelationshipType__c;
                        qli.vlocity_cmt__RootItemId__c = qItem.vlocity_cmt__RootItemId__c;
                        qli.vlocity_cmt__SequenceNumber__c= qItem.vlocity_cmt__SequenceNumber__c;
                        qli.vlocity_cmt__SerialNumber__c  = qItem.vlocity_cmt__SerialNumber__c;
                        qli.vlocity_cmt__ServiceAccountId__c = qItem.vlocity_cmt__ServiceAccountId__c;
                        qli.vlocity_cmt__ServiceDate__c= qItem.vlocity_cmt__ServiceDate__c;
                        qli.vlocity_cmt__SubAction__c  = qItem.vlocity_cmt__SubAction__c;
                        qli.vlocity_cmt__AttributeMetadataChanges__c  = qItem.vlocity_cmt__AttributeMetadataChanges__c;
                        qli.vlocity_cmt__SubscriptionId__c= qItem.vlocity_cmt__SubscriptionId__c;
                        qli.TeliaSE_AM_Mandate_Percentage__c = qItem.TeliaSE_AM_Mandate_Percentage__c;
                        qli.TeliaSE_Approved_Flag__c= qItem.TeliaSE_Approved_Flag__c;
                        qli.TeliaSE_Approved_Price__c  = qItem.TeliaSE_Approved_Price__c;
                        qli.TeliaSE_Approved__c  = qItem.TeliaSE_Approved__c;
                        //qli.TeliaSE_Base_Quantity__c= qItem.TeliaSE_Base_Quantity__c;
                        qli.TeliaSE_CM_Mandate_Percentage__c = qItem.TeliaSE_CM_Mandate_Percentage__c;
                        qli.TeliaSE_Ceiling_Price__c= qItem.TeliaSE_Ceiling_Price__c;
                        qli.TeliaSE_CommitmentPeriod__c= qItem.TeliaSE_CommitmentPeriod__c;
                        qli.TeliaSE_Discount_Percentage__c= qItem.TeliaSE_Discount_Percentage__c;
                        qli.TeliaSE_EndDate__c= qItem.TeliaSE_EndDate__c;
                        qli.TeliaSE_Flag_Check__c= qItem.TeliaSE_Flag_Check__c;
                        qli.TeliaSE_Flag__c= qItem.TeliaSE_Flag__c;
                        qli.TeliaSE_MC_Customer_Requested_Percentage__c  = qItem.TeliaSE_MC_Customer_Requested_Percentage__c;
                        qli.TeliaSE_MC_Customer_Requested_Price__c = qItem.TeliaSE_MC_Customer_Requested_Price__c;
                        qli.TeliaSE_Minimum_Value_Commit__c  = qItem.TeliaSE_Minimum_Value_Commit__c;
                        qli.TeliaSE_Root_Product__c = qItem.TeliaSE_Root_Product__c;
                        qli.TeliaSE_SD_Mandate_Percentage__c = qItem.TeliaSE_SD_Mandate_Percentage__c;
                        qli.TeliaSE_SM_Mandate_Percentage__c = qItem.TeliaSE_SM_Mandate_Percentage__c;
                        qli.TeliaSE_StartDate__c = qItem.TeliaSE_StartDate__c;
                        qli.TeliaSE_SubsidisedVoice__c = qItem.TeliaSE_SubsidisedVoice__c;
                        qli.TeliaSE_Target_Price__c = qItem.TeliaSE_Target_Price__c;
                        qli.TeliaSE_Abroad_Call_Discount__c  = qItem.TeliaSE_Abroad_Call_Discount__c;
                        qli.TeliaSE_Comment__c= qItem.TeliaSE_Comment__c;
                        qli.TeliaSE_Invoice_Fee__c  = qItem.TeliaSE_Invoice_Fee__c;
                        qli.TeliaSE_PriceTypeCategory__c  = qItem.TeliaSE_PriceTypeCategory__c;
                        qli.TeliaSE_Nullify_Check__c= qItem.TeliaSE_Nullify_Check__c;
                        qli.vlocity_cmt__CpqPricingMessage__c= qItem.vlocity_cmt__CpqPricingMessage__c;
                        qli.vlocity_cmt__EffectiveOneTimeCostTotal__c = qItem.vlocity_cmt__EffectiveOneTimeCostTotal__c;
                        qli.vlocity_cmt__EffectiveRecurringCostTotal__c  = qItem.vlocity_cmt__EffectiveRecurringCostTotal__c;
                        qli.vlocity_cmt__OneTimeCostTotal__c = qItem.vlocity_cmt__OneTimeCostTotal__c;
                        qli.vlocity_cmt__OneTimeCost__c= qItem.vlocity_cmt__OneTimeCost__c;
                        qli.vlocity_cmt__OneTimeMargin__c = qItem.vlocity_cmt__OneTimeMargin__c;
                        qli.vlocity_cmt__RecurringCostTotal__c  = qItem.vlocity_cmt__RecurringCostTotal__c;
                        qli.vlocity_cmt__RecurringCost__c = qItem.vlocity_cmt__RecurringCost__c;
                        qli.vlocity_cmt__RecurringMargin__c  = qItem.vlocity_cmt__RecurringMargin__c;
                        qli.vlocity_cmt__ServicePointId__c= qItem.vlocity_cmt__ServicePointId__c;
                        qli.TeliaSE_Fiber_Customer_Requested_Price__c = qItem.TeliaSE_Fiber_Customer_Requested_Price__c;
                        qli.TeliaSE_fiber_Antal__c  = qItem.TeliaSE_fiber_Antal__c;
                        qli.TeliaSE_fiber_Engngsavgift__c = qItem.TeliaSE_fiber_Engngsavgift__c;
                        qli.TeliaSE_Fiber_Frame_Agreement__c = qItem.TeliaSE_Fiber_Frame_Agreement__c;
                        qli.TeliaSE_fiber_Rabatt__c = qItem.TeliaSE_fiber_Rabatt__c;
                        qli.Fiber_Approved_Price__c = qItem.Fiber_Approved_Price__c;
                        qli.Fiber_Customer_Requested_Price__c= qItem.Fiber_Customer_Requested_Price__c;
                        
                        qLineItemsToBeInserted.add(qli);
                    }
                }
                system.debug('qLineItemsToBeInserted =- =-= -='+qLineItemsToBeInserted);
                insert qLineItemsToBeInserted;
            }
            outMap.put('quoteid', newQuote.Id);
            /*END*/
            
            /*
List<vlocity_cmt__ContractLineItem__c> cli = [select id, Fiber_Customer_Requested_Price__c,TeliaSE_fiber_Rabatt__c,vlocity_cmt__PricebookEntryId__c, Fiber_Approved_Price__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__Quantity__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__RecurringUOM__c, vlocity_cmt__RecurringManualDiscount__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringDiscountPrice__c, TeliaSE_Root_Product__c, TeliaSE_Abroad_Call_Discount__c, TeliaSE_Product_Object_Type__c, TeliaSE_ParentItemId__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeTotal__c, TeliaSE_RootItemId__c, vlocity_cmt__UnitPrice__c, vlocity_cmt__Product2Id__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c = :contractId];



//system.debug('qliRecordTypeId = = = '+qliRecordTypeId);
List<quotelineitem> qlines = new List<quotelineitem>();
system.debug('cli size : '+cli.size());
if(cli != null && cli.size() > 0){ 

for(vlocity_cmt__ContractLineItem__c cl : cli){
system.debug('cl = '+cl);
system.debug('cl.vlocity_cmt__PricebookEntryId__c : '+cl.vlocity_cmt__PricebookEntryId__c);
quotelineitem ql = new quotelineitem();
ql.PricebookEntryId = cl.vlocity_cmt__PricebookEntryId__c;
ql.vlocity_cmt__Product2Id__c= cl.vlocity_cmt__Product2Id__c;
ql.Product2Id = cl.vlocity_cmt__Product2Id__c;
ql.Quantity = cl.vlocity_cmt__Quantity__c;
ql.UnitPrice = cl.vlocity_cmt__UnitPrice__c;
ql.Fiber_Customer_Requested_Price__c = cl.Fiber_Customer_Requested_Price__c;
ql.TeliaSE_fiber_Rabatt__c = cl.TeliaSE_fiber_Rabatt__c;
ql.vlocity_cmt__RecurringCharge__c = cl.vlocity_cmt__RecurringCharge__c;
system.debug('newQuote.Id = = = '+newQuote.Id);
ql.quoteId = newQuote.Id;
ql.TeliaSE_Ceiling_Price__c = cl.vlocity_cmt__UnitPrice__c;

ql.vlocity_cmt__RecurringTotal__c = cl.vlocity_cmt__RecurringTotal__c;
ql.vlocity_cmt__RecurringUOM__c = cl.vlocity_cmt__RecurringUOM__c;
ql.vlocity_cmt__RecurringManualDiscount__c = cl.vlocity_cmt__RecurringManualDiscount__c;
ql.vlocity_cmt__RecurringCalculatedPrice__c = cl.vlocity_cmt__RecurringCalculatedPrice__c;
ql.vlocity_cmt__RecurringDiscountPrice__c = cl.vlocity_cmt__RecurringDiscountPrice__c;
ql.TeliaSE_Root_Product__c = cl.TeliaSE_Root_Product__c;
ql.TeliaSE_Abroad_Call_Discount__c = cl.TeliaSE_Abroad_Call_Discount__c;
//ql.TeliaSE_Product_Object_Type__c = cl.TeliaSE_Product_Object_Type__c;
ql.vlocity_cmt__ParentItemId__c = cl.TeliaSE_ParentItemId__c;
ql.vlocity_cmt__OneTimeCharge__c = cl.vlocity_cmt__OneTimeCharge__c;
ql.PricebookEntryId = cl.vlocity_cmt__PricebookEntryId__c;
ql.vlocity_cmt__OneTimeTotal__c = cl.vlocity_cmt__OneTimeTotal__c;
ql.vlocity_cmt__RootItemId__c = cl.TeliaSE_RootItemId__c;
ql.UnitPrice = cl.vlocity_cmt__UnitPrice__c;



qlines.add(ql);
}

insert qlines;
outMap.put('quoteid', newQuote.Id);
}*/
        }
        catch(Exception e){
            outMap.put('errMessage', e.getMessage());
        }
    }
    public static void createContractContactRole(Map<String,Object> inputMap){
        //string OpportunityId = String.ValueOf(inputMap.get('Opportunity'));
        string ContractId = String.ValueOf(inputMap.get('DRId_Contract'));
        List<contract> contractList = [select vlocity_cmt__OpportunityId__c from contract where id=:ContractId];
        if(contractList != null && contractList.size()>0){
            string OpportunityId = contractList[0].vlocity_cmt__OpportunityId__c;
            List<OpportunityContactRole> optyContactRoleList = [SELECT Id, OpportunityId, ContactId, Role FROM OpportunityContactRole where role='Avtalstecknare' and OpportunityId=:OpportunityId];
            
            system.debug('=-=--=-=-=-OpportunityId : '+OpportunityId);
            system.debug('=-=--=-=-=-optyContactRoleList : '+optyContactRoleList);
            
            List<ContractContactRole> crList = new List<ContractContactRole>();
            for(OpportunityContactRole oc : optyContactRoleList){
                ContractContactRole cr = new  ContractContactRole();
                cr.ContractId = ContractId;
                cr.ContactId = oc.ContactId;
                cr.Role = oc.Role;
                crList.add(cr);
            }
            system.debug('=-=--=-=-=-crList : '+crList);
            insert crList;
        }
        
    }
    public static void createContractLineItemFromQuote(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{
            system.debug('inside createContractLineItemFromQuote');
            string quoteId = String.ValueOf(inputMap.get('ContextId'));
            string PreviousContractId = String.ValueOf(inputMap.get('PreviousContractId'));
            string BaseContractId = String.ValueOf(inputMap.get('BaseContractId'));
            string ContractId = String.ValueOf(inputMap.get('DRId_Contract'));
            
            system.debug('ContractId = '+ContractId);
            //updateContract(ContractId);
            
            List<QuoteLineItem> qli = [select id,UnitPrice, TeliaSE_Product_Code__c, vlocity_cmt__OneTimeTotal__c, Description, vlocity_cmt__ParentItemId__c, Product2.Telia_Fiber_External_Name__c, TeliaSE_fiber_Rabatt__c, Fiber_Approved_Price__c, Quantity, ListPrice, Fiber_Customer_Requested_Price__c, vlocity_cmt__RecurringUOM__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__Product2Id__c,TeliaSE_Abroad_Call_Discount__c, TeliaSE_Root_Product__c,vlocity_cmt__RecurringDiscountPrice__c,vlocity_cmt__RecurringCharge__c,TeliaSE_Product_Object_Type__c,vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__OneTimeCharge__c,vlocity_cmt__RootItemId__c ,vlocity_cmt__AssetReferenceId__c,vlocity_cmt__RecurringManualDiscount__c,PricebookEntryId,TeliaSE_Fiber_Frame_Agreement__c from quotelineitem where quoteid = :quoteId];
            List<Id> Plist = new List<Id>();
            for(QuoteLineItem qlItem : qli){
                Plist.add(qlItem.vlocity_cmt__Product2Id__c);
            }
            System.debug('qli---'+qli);
            //Added the below code as part of Orderunderlag Release
            List<vlocity_cmt__PriceListEntry__c> ple =[SELECT id,vlocity_cmt__productid__c,vlocity_cmt__pricingelementid__r.vlocity_cmt__code__c,name,vlocity_cmt__ProductId__r.name,vlocity_cmt__PriceListId__r.Name  FROM vlocity_cmt__PriceListEntry__c WHERE vlocity_cmt__ProductId__c IN: Plist];
            Map<Id,String> PleMap = new Map<Id,String>();
            for(vlocity_cmt__PriceListEntry__c ple1:ple ){
                      PleMap.put(ple1.vlocity_cmt__ProductId__c,ple1.vlocity_cmt__pricingelementid__r.vlocity_cmt__code__c);        
            }
            List<vlocity_cmt__ContractLineItem__c> clines = new List<vlocity_cmt__ContractLineItem__c>();
            
            for(QuoteLineItem ql : qli){
                vlocity_cmt__ContractLineItem__c cl = new vlocity_cmt__ContractLineItem__c();
                cl.Name  = ql.TeliaSE_Product_Code__c;
                cl.vlocity_cmt__Product2Id__c= ql.vlocity_cmt__Product2Id__c;
                cl.vlocity_cmt__Quantity__c = ql.Quantity;
                cl.vlocity_cmt__RecurringCharge__c = ql.vlocity_cmt__RecurringCharge__c;
                cl.vlocity_cmt__ContractId__c = ContractId;
                cl.Fiber_Customer_Requested_Price__c = ql.Fiber_Customer_Requested_Price__c;
                cl.Fiber_Approved_Price__c = ql.Fiber_Approved_Price__c;
                cl.TeliaSE_fiber_Rabatt__c = ql.TeliaSE_fiber_Rabatt__c;
                cl.vlocity_cmt__RecurringTotal__c = ql.vlocity_cmt__RecurringTotal__c;
                //Added the below code as part of Orderunderlag Release
                if(PleMap.get(ql.vlocity_cmt__Product2Id__c) != null && PleMap.get(ql.vlocity_cmt__Product2Id__c).contains ('RC')){
                   cl.Fiber_PriceListEntry__c ='Monthly';
                }
                else{
                     cl.Fiber_PriceListEntry__c ='Yearly'; 
                }
                cl.vlocity_cmt__RecurringUOM__c = ql.vlocity_cmt__RecurringUOM__c;
                cl.vlocity_cmt__RecurringManualDiscount__c = ql.vlocity_cmt__RecurringManualDiscount__c;
                cl.vlocity_cmt__RecurringCalculatedPrice__c = ql.vlocity_cmt__RecurringCalculatedPrice__c;
                cl.vlocity_cmt__RecurringDiscountPrice__c = ql.vlocity_cmt__RecurringDiscountPrice__c;
                cl.TeliaSE_Root_Product__c = ql.TeliaSE_Root_Product__c;
                cl.TeliaSE_Abroad_Call_Discount__c = ql.TeliaSE_Abroad_Call_Discount__c;
                cl.TeliaSE_Product_Object_Type__c = ql.TeliaSE_Product_Object_Type__c;
                cl.TeliaSE_ParentItemId__c = ql.vlocity_cmt__ParentItemId__c;
                cl.vlocity_cmt__OneTimeCharge__c = ql.vlocity_cmt__OneTimeCharge__c;
                cl.vlocity_cmt__PricebookEntryId__c = ql.PricebookEntryId;
                cl.TeliaSE_Fiber_Product_Description__c = ql.Product2.Telia_Fiber_External_Name__c;
                cl.vlocity_cmt__OneTimeTotal__c = ql.vlocity_cmt__OneTimeTotal__c;
                cl.TeliaSE_RootItemId__c = ql.vlocity_cmt__RootItemId__c;
                cl.vlocity_cmt__UnitPrice__c = ql.UnitPrice;
                cl.TeliaSE_Fiber_Frame_Agreement__c = ql.TeliaSE_Fiber_Frame_Agreement__c;
                cl.vlocity_cmt__AssetReferenceId__c = ql.vlocity_cmt__AssetReferenceId__c;
                clines.add(cl);
                system.debug('cli---'+clines);
            }
            insert clines;
            updateContract(ContractId);
            createContractContactRole(inputMap);
            updateContractPreviousandBaseId(ContractId);
        }
        catch(Exception e){
            outMap.put('errMessage', e.getMessage());
        }
    }
}