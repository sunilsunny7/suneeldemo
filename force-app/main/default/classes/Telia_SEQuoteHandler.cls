/*-----------------------------------------------------------------------------------------------------------
**Name: Telia_SEQuoteHandler 
**Created By:  Suneel G Shivanna
**Sprint: Sprint-2
**User Story:MCSTO-423 and MCSTO-127
**Description:Error message should be presented if deletion is tried when the status is not "Draft" or "ready to present" and if Primary Quote is alread present
-----------------------------------------------------------------------------------------------------------*/
public class Telia_SEQuoteHandler {

    public static void checkDeletion(List<Quote> quotes) {
        for (Quote quote : quotes) {
            if (!(quote.Status == System.Label.TeliaSE_Draft_Status || quote.Status == System.Label.TeliaSE_Ready_to_present)) {
                quote.adderror(System.Label.TeliaSEDeleteQuoteError);
            }
        }
    }
    /*-----------------------------------------------------------------------------------------------------------
**Name: checkPrimaryQuotes
**Created By:  Suneel
**Description: Check for primary quote to unlock record
-----------------------------------------------------------------------------------------------------------*/
    public static void checkPrimaryQuotes(Map<Id, Quote> newMap) {
        Set<Id> ids = new Set<Id>();
        for (Quote quote : newMap.values()) {
            if (quote.TeliaSWE_Primary_Quote__c) {
                ids.add(quote.OpportunityId);
            }
        }
        if (ids.size() > 0) {
            List<Quote> quotesforUpdate = new List<Quote>();
            for (Quote quote : [select id,TeliaSWE_Primary_Quote__c from Quote where opportunityId = :ids]) {
                if (quote.TeliaSWE_Primary_Quote__c && newMap.get(quote.Id) == null) {
                    quote.TeliaSWE_Primary_Quote__c = false;
                    Approval.unlock(quote.Id, false);
                    quotesForUpdate.add(quote);
                }
               // if (quotesForUpdate.size() > 0) {
                   // update quotesForUpdate;
                //}
            }
                if (quotesForUpdate.size() > 0) {
                    update quotesForUpdate;
                }
            }

    }
    /*Commenting Method as we are not using it in trigger
public static void getPrimaryQuoteStatus(List<Quote> quotes)
{
for(Quote quote:quotes)
{
if(quote.TeliaSWE_Primary_Quote__c)
{
Opportunity opportunity= [select id,(select id,TeliaSWE_Primary_Quote__c from Quotes where id !=:quote.id) from Opportunity where id=:quote.OpportunityId][0];
for(Quote opportunityQuote:opportunity.Quotes)
{
if(opportunityQuote.TeliaSWE_Primary_Quote__c)
{

quote.addError(System.Label.TeliaSE_PrimaryQuote);
break;
}
}
}
}

}*/
    /*-----------------------------------------------------------------------------------------------------------
**Name: UpdateApprovePrice
**Created By:  Vaishali Srivastava
**Sprint: Sprint-4
**User Story:MCSTO-566/567
**Description: Update Approval Flag for Quote Approved.
-----------------------------------------------------------------------------------------------------------*/
    public static void UpdateApprovePrice(List<Quote> QtList, Map<Id, Quote> oldMap, Map<Id, Quote> newMap) {
        string recType = QtList != null ? QtList[0].TeliaSE_Record_Type_Name__c : null;
        if (recType != null && QtList != null && QtList.size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.MC, SEUtility.QUOTE, recType)) {
            //Collect Quote id for Quote which is approved via approval Process
            Set<Id> QuoteId = new Set<Id>();
            List<QuoteLineItem> QlList = new List<QuoteLineItem>();
            Map<String, Object> commercialTerms = new Map<String, object>();
            Map<String, Object> campaign = new Map<String, Object>();

            for (Quote qt : QtList) {

                if ((qt.TeliaSE_Approval_Flag__c == True) && (oldMap.get(qt.Id).TeliaSE_Approval_Flag__c == false)) {
                    QuoteId.add(qt.Id);
                }
            }
            if (QuoteId.Size() > 0) {


                QlList = [select id,TeliaSE_Product_Code__c,MC_OCN_Discount__c,vlocity_cmt__ParentItemId__c,MC_Quarantine_Time__c,TeliaSE_Minimum_Value_Commit__c,TeliaSE_Nullify_Check__c,TeliaSE_Approved_Price__c,TeliaSE_Approved__c,TeliaSE_MC_Customer_Requested_Percentage__c,TeliaSE_Flag__c,TeliaSE_MC_Customer_Requested_Price__c, MC_OT_Approved_Price__c,vlocity_cmt__OneTimeCharge__c,TeliaSE_MC_Campaign_Id__c,TeliaSE_MC_Campaign_Id__r.Name,TeliaSE_Product_Object_Type__c,vlocity_cmt__RootItemId__c,vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c,MC_CommercialTermsQli__c,MC_Sales_FrameworkPricingMaster__c from QuoteLineItem where quoteid in:quoteid];


            }
            //Added by Suneel as workaround to Approved price nullification
            List<QuoteLineItem> nullifyList = new List<QuoteLineItem>();
            for (QuoteLineItem item : QlList) {
                if (item.TeliaSE_Nullify_Check__c) {
                    item.TeliaSE_Approved_Price__c = null;
                    item.MC_OT_Approved_Price__c = null;
                    item.TeliaSE_Approved__c = null;
                }
                nullifyList.add(item);
            }
            QlList = nullifyList;
            //System.exit(0) for Suneel
            list<QuoteLineItem> QuoteItemValueList = new list<QuoteLineItem> ();
            QuoteLineItem QuoteItemValue = new QuoteLineItem ();
            for (QuoteLineItem ql : QlList) {
                //Percentage Logic
                if (ql.TeliaSE_Approved__c == null) {
                    IF (ql.TeliaSE_MC_Customer_Requested_Percentage__c != null) {
                        ql.TeliaSE_Approved__c = ql.TeliaSE_MC_Customer_Requested_Percentage__c;
                        ql.TeliaSE_Nullify_Check__c = false;
                        ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                    }
                } 
                else if (ql.TeliaSE_Approved__c < ql.TeliaSE_MC_Customer_Requested_Percentage__c) {
                    IF (ql.TeliaSE_MC_Customer_Requested_Percentage__c != null) {
                        ql.TeliaSE_Approved__c = ql.TeliaSE_MC_Customer_Requested_Percentage__c;
                        ql.TeliaSE_Nullify_Check__c = false;

                        ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                    }
                }

                //Price Logic
                /* Commented code to make generic use of Framework pricing field instead of product Codes LTAT:7054
                if (ql.TeliaSE_Product_Code__c.contains('MOB_SURF') || ql.TeliaSE_Product_Code__c.contains('MOB_CALL_TRAVEL')) {
                    ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                    ql.TeliaSE_Approved_Price__c = ql.TeliaSE_MC_Customer_Requested_Price__c;
                    ql.TeliaSE_Nullify_Check__c = false;
                            }*/
                
                if (ql.TeliaSE_Approved_Price__c == null) {
                            if (ql.TeliaSE_MC_Customer_Requested_Price__c != null) {
                                ql.TeliaSE_Approved_Price__c = ql.TeliaSE_MC_Customer_Requested_Price__c;
                                ql.TeliaSE_Nullify_Check__c = false;
                                ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                            }
                        }
                else if (ql.TeliaSE_Approved_Price__c > ql.TeliaSE_MC_Customer_Requested_Price__c) {
                            if (ql.TeliaSE_MC_Customer_Requested_Price__c != null) {
                                ql.TeliaSE_Approved_Price__c = ql.TeliaSE_MC_Customer_Requested_Price__c;
                                ql.TeliaSE_Nullify_Check__c = false;
                                ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                            }
                        }
                
                try {
                    if(ql.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c == 'Framework' || ql.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c == 'Hybrid') {
                        ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                        ql.TeliaSE_Approved_Price__c = ql.TeliaSE_MC_Customer_Requested_Price__c;
                        ql.TeliaSE_Nullify_Check__c = false;
                        commercialTerms.put('FrameworkPricingMaster', ql.MC_Sales_FrameworkPricingMaster__c);
                        ql.MC_CommercialTermsQli__c = json.serialize(commercialTerms);
                    } 
                } catch (Exception e){
                    System.debug('Exeception :' + e.getStackTraceString() + e.getMessage());
                }
                //MCSTO-10907-Shouvik: if-else ladder added

                if(ql.MC_OT_Approved_Price__c == null){
                    if(ql.vlocity_cmt__OneTimeCharge__c != null){
                        ql.MC_OT_Approved_Price__c = ql.vlocity_cmt__OneTimeCharge__c;
                        ql.TeliaSE_Nullify_Check__c = false;
                        ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                    }
                }
                else if(ql.MC_OT_Approved_Price__c > ql.vlocity_cmt__OneTimeCharge__c){
                    if(ql.vlocity_cmt__OneTimeCharge__c != null){
                        ql.MC_OT_Approved_Price__c = ql.vlocity_cmt__OneTimeCharge__c;
                        ql.TeliaSE_Nullify_Check__c = false;
                        ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                    }
                }
                //commercial term negotiation logic (MCSTO-7265)
                if (ql.vlocity_cmt__ParentItemId__c == null && (ql.TeliaSE_Product_Object_Type__c == 'Mobile Offer Specification' || ql.TeliaSE_Product_Object_Type__c == 'Touch Point Offer Spec' || ql.TeliaSE_Product_Object_Type__c == 'Smart Connect Offer Spec' || ql.TeliaSE_Product_Object_Type__c == 'Operator Connect Offer Spec')) {
                    commercialTerms.put('TimeToReachBaseLevel', ql.MC_Quarantine_Time__c);
                    commercialTerms.put('MinimumCommitment', ql.TeliaSE_Minimum_Value_Commit__c);
                    ql.MC_CommercialTermsQli__c = json.serialize(commercialTerms);
                }
                else if (ql.TeliaSE_MC_Campaign_Id__c != null) {
                    campaign.put('campaignExist', ql.TeliaSE_MC_Campaign_Id__r.Name);
                    ql.MC_CommercialTermsQli__c = json.serialize(campaign);
                }
                //for CO products only
                if (ql.vlocity_cmt__ParentItemId__c == null && (ql.TeliaSE_Product_Object_Type__c == 'Broadband Start Offering Spec' || ql.TeliaSE_Product_Object_Type__c == 'Broadband Plus Offering Spec' || ql.TeliaSE_Product_Object_Type__c == 'Broadband Pro Offering Spec' || ql.TeliaSE_Product_Object_Type__c == 'WIFI/LAN Offering Spec' || ql.TeliaSE_Product_Object_Type__c == 'SD-WAN/Firewall Offering Spec')) {
                    //commercialTerms.put('TimeToReachBaseLevelForCO',ql.MC_Quarantine_Time__c);
                    //commercialTerms.put('MinimumCommitmentForCO',ql.TeliaSE_Minimum_Value_Commit__c);
                    commercialTerms.put('OCNDiscount', ql.MC_OCN_Discount__c);
                    ql.MC_CommercialTermsQli__c = json.serialize(commercialTerms);
                } else if (ql.TeliaSE_MC_Campaign_Id__c != null) {
                    campaign.put('campaignExist', ql.TeliaSE_MC_Campaign_Id__r.Name);
                    ql.MC_CommercialTermsQli__c = json.serialize(campaign);
                }

                // Start-Added for MCSTO-8370 to update root product approval flag - Commented for 21.4
                /*if(ql.Id==ql.vlocity_cmt__RootItemId__c && ql.TeliaSE_Flag__c == label.TeliaSE_SadFace)
                {
                    ql.TeliaSE_Flag__c=label.TeliaSE_HappyFace;
                }*/
                // End-Added for MCSTO-8370 to update root product approval flag
                QuoteItemValuelist.add(ql);
            }

            if (QuoteItemValuelist.size() > 0) {
                try {
                    update QuoteItemValuelist;
                } catch (Exception e) {
                    System.debug('Exeception :' + e);
                }
            }
        }
    }

/*-----------------------------------------------------------------------------------------------------------
**Name: UpdateApprovalFlag
**Created By:  Vaishali Srivastava
**Sprint: 7
**User Story:Defect -167
**Description: Update quote flag field to avoid approving record without Approval
-----------------------------------------------------------------------------------------------------------*/
    public static void UpdateApprovalFlag(List<Quote> QtList, Map<Id, Quote> oldMap, Map<Id, Quote> newMap) {
        for (Quote qt : QtList) {
            if (qt.TeliaSE_Approval_Count__c > 0) {
                if ((qt.TeliaSE_Approval_Flag__c == True) &&
                        (oldMap.get(qt.Id).TeliaSE_Approval_Flag__c == newMap.get(qt.Id).TeliaSE_Approval_Flag__c)) {
                    qt.TeliaSE_Approval_Flag__c = False;
                }
            }
        }
    }
    
/*-----------------------------------------------------------------------------------------------------------
**Name: checkMandate
**Created By:  Suneel
**Description: Error Message for line item
-----------------------------------------------------------------------------------------------------------*/
    public static void checkMandate(List<Quote> QtList, Map<Id, Quote> oldMap, Map<Id, Quote> newMap) {
        Set<Id> ids = new Set<Id>();
        boolean isPrematureQuote = false;

        for (Quote quo : QtList) {
            if (oldMap.get(quo.Id).Status == 'Sent for Approval'
                    && newMap.get(quo.Id).status == 'Approved'
                    && newMap.get(quo.Id).TeliaSE_Comments__c != null
                    && newMap.get(quo.Id).TeliaSE_Comments__c.containsIgnoreCase(System.Label.Renegotiation_Approval_Comment)) {
                ids.add(quo.id);
                newMap.get(quo.Id).status = 'Draft';
                isPrematureQuote = true;
            } else if (oldMap.get(quo.Id).Status == 'Sent for Approval' && newMap.get(quo.Id).status == 'Approved') {
                ids.add(quo.id);
            }

        }
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        if (Limits.getQueries() < Limits.getLimitQueries()) {
            qliList = [select id,TeliaSE_ProductType__c,TeliaSE_Approved_Price__c,TeliaSE_Approved__c,MC_OT_Approved_Price__c,quoteId,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_Floor_Price__c,TeliaSE_Floor_Percentage__c,TeliaSE_MC_Customer_Requested_Percentage__c,vlocity_cmt__OneTimeCharge__c,MC_OT_Floor_Price__c,vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c from QuoteLineItem where quoteId = :ids and TeliaSE_Flag__c like '%TeliaSE_Sad_Face%' and (TeliaSE_MC_Customer_Requested_Price__c != null or TeliaSE_MC_Customer_Requested_Percentage__c != null or MC_OT_Floor_Price__c != null)];
        }

        for (QuoteLineItem item : qliList) {
            if ((isPrematureQuote == false) &&
                    (item.TeliaSE_ProductType__c == 'Price' && ((item.TeliaSE_Approved_Price__c != null && item.TeliaSE_MC_Customer_Requested_Price__c > item.TeliaSE_Approved_Price__c && item.TeliaSE_Floor_Price__c > item.TeliaSE_MC_Customer_Requested_Price__c && item.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c !='Framework' ) || (item.TeliaSE_Approved_Price__c == null && item.TeliaSE_Floor_Price__c > item.TeliaSE_MC_Customer_Requested_Price__c && item.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c	!='Framework'))) || //Price products comparison
                    (item.TeliaSE_ProductType__c == 'Percentage' && ((item.TeliaSE_Approved__c != null && item.TeliaSE_MC_Customer_Requested_Percentage__c < item.TeliaSE_Approved__c && item.TeliaSE_Floor_Percentage__c < item.TeliaSE_MC_Customer_Requested_Percentage__c) || (item.TeliaSE_Approved__c == null && item.TeliaSE_Floor_Percentage__c < item.TeliaSE_MC_Customer_Requested_Percentage__c))) || //Percentage products comparison
                    ((item.MC_OT_Approved_Price__c != null && item.MC_OT_Approved_Price__c > item.vlocity_cmt__OneTimeCharge__c && item.MC_OT_Floor_Price__c > item.vlocity_cmt__OneTimeCharge__c) || (item.MC_OT_Approved_Price__c == null && item.MC_OT_Floor_Price__c > item.vlocity_cmt__OneTimeCharge__c))) // Onetime Price Check
            {
                newMap.get(item.quoteId).addError('Det finns priser utanför dina mandat. Vänligen ”Tilldela igen” till ledare eller justera priser i konfigurationen.');
            }
        }
        //MCSTO-2198, 99, MCSTO-2200
        //This for loop will only run once as always we will get approval request for single quote
        if (ids != null && ids.size() > 0 && isPrematureQuote == false) {
            for (Quote quote : newMap.values()) {
                if (!checkForCommercialNegotiation(oldMap, newMap)) {
                    quote.addError('Det finns priser utanför dina mandat. Vänligen ”Tilldela igen” till ledare eller justera priser i konfigurationen.');
                }
            }
        }

        //MCSTO-5294
        //This is for Roaming Add Ons
        if (ids != null && ids.size() > 0 && isPrematureQuote == false) {
            for (Quote quote : newMap.values()) {
               /* if (!checkForRoamingAdOn(oldMap, newMap)) {
                    quote.addError('Det finns priser utanför dina mandat. Vänligen ”Tilldela igen” till ledare eller justera priser i konfigurationen.');
                }*/
                 if (!checkForFrameworkPricing(oldMap, newMap)) {
                    quote.addError('Det finns priser utanför dina mandat. Vänligen ”Tilldela igen” till ledare eller justera priser i konfigurationen.');
                }
            }
        }
    }

    //For Roaming Add Ons | Developer: Ananya Patra
    //MCSTO-5294
   /* public static boolean checkForRoamingAdOn(Map<Id, Quote> oldQuoteMap, Map<Id, Quote> quoteMap) {
        boolean flag = false;

        //Query on metadata for RoamingMandate
        List <TeliaSE_Roaming_Mandate__mdt> roamingMetadata = [
                SELECT AddOnPricePlan__c,
                        ApproverName__c
                FROM TeliaSE_Roaming_Mandate__mdt
        ];

        List<QuoteLineItem> qliList = [select id, QuoteId,PriceBookEntry.Product2.ProductCode,RoamingTillAddOns__c, RoamingResAddOns__c from QuoteLineItem where QuoteId in :quoteMap.keyset() and vlocity_cmt__ParentItemId__c != null and TeliaSE_Flag__c like '%TeliaSE_Sad_Face%'];
        Id CurrentUserId = UserInfo.GetUserId();

        User appApproverUser = [
                Select Id,MassCustomized_Roles__c, Name,TeliaSE_Role_based_Approver__c,TeliaSE_Role_based_Approver__r.Name
                from User
                where Id = :CurrentUserId
                limit 1
        ];
        Map<String, String> mcRoleMap = new Map<String, String>();
        if (qliList != null && qliList.size() > 0) {
            for (QuoteLineItem qli : qliList) {
                if (qli.PriceBookEntry.Product2.ProductCode.contains('MOB_CALL_TRAVEL')) {
                    for (TeliaSE_Roaming_Mandate__mdt roamingData : roamingMetadata) {
                        if (qli.RoamingTillAddOns__c == roamingData.AddOnPricePlan__c || qli.RoamingResAddOns__c == roamingData.AddOnPricePlan__c) {
                            mcRoleMap.put(roamingData.AddOnPricePlan__c, roamingData.ApproverName__c);
                        }

                    }
                }
            }
        }
        if (mcRoleMap != null && mcRoleMap.size() > 0) {
            Decimal heighestRolePrecdence = 0;
            for (String AddOnPricePlan : mcRoleMap.keyset()) {
                if (heighestRolePrecdence < MC_RolePrecedence__c.getAll().get(mcRoleMap.get(AddOnPricePlan)).Precedence__c) {
                    heighestRolePrecdence = MC_RolePrecedence__c.getAll().get(mcRoleMap.get(AddOnPricePlan)).Precedence__c;
                }
            }
            if ((appApproverUser.MassCustomized_Roles__c != null && MC_RolePrecedence__c.getAll().get(appApproverUser.MassCustomized_Roles__c).Precedence__c != null) && heighestRolePrecdence <= MC_RolePrecedence__c.getAll().get(appApproverUser.MassCustomized_Roles__c).Precedence__c) {
                flag = true;
            }
        } else {
            flag = true;
        }
        return flag;

    }*/
    
    public static boolean checkForFrameworkPricing(Map<Id, Quote> oldQuoteMap, Map<Id, Quote> quoteMap) {
        boolean flag = false;
        List<QuoteLineItem> qliList = [select id, QuoteId,PriceBookEntry.Product2.ProductCode, vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c,MC_Sales_FrameworkPricingMaster__c,MC_Sales_FrameworkPricingMaster__r.MC_Sales_Approver_Level__c,TeliaSE_Approved_Flag__c from QuoteLineItem where QuoteId in :quoteMap.keyset() and vlocity_cmt__ParentItemId__c != null and TeliaSE_Flag__c like '%TeliaSE_Sad_Face%'  and MC_Sales_FrameworkPricingMaster__c!=null and vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c='Framework'];
        Id CurrentUserId = UserInfo.GetUserId();

        User appApproverUser = [
                Select Id,MassCustomized_Roles__c, Name,TeliaSE_Role_based_Approver__c,TeliaSE_Role_based_Approver__r.Name
                from User
                where Id = :CurrentUserId
                limit 1
        ];
        if (qliList != null && qliList.size() > 0) {
            Decimal heighestRolePrecdence = 0;
            for (QuoteLineItem qli : qliList) {
                if (heighestRolePrecdence < ((Decimal.valueOf(qli.MC_Sales_FrameworkPricingMaster__r.MC_Sales_Approver_Level__c))-1))  {
                    heighestRolePrecdence = (Decimal.valueOf(qli.MC_Sales_FrameworkPricingMaster__r.MC_Sales_Approver_Level__c))-1;
                }
             
            }
            if ((appApproverUser.MassCustomized_Roles__c != null && MC_RolePrecedence__c.getAll().get(appApproverUser.MassCustomized_Roles__c).Precedence__c != null) && heighestRolePrecdence <= MC_RolePrecedence__c.getAll().get(appApproverUser.MassCustomized_Roles__c).Precedence__c) {
                flag = true;
            }
        } else {
            flag = true;
        }
        return flag;
    }

    //MCSTO-2198, 99, MCSTO-2200
    public static boolean checkForCommercialNegotiation(Map<Id, Quote> oldQuoteMap, Map<Id, Quote> quoteMap) {
        boolean flag = false;
        ProcessInstance[] instances = [
                select Id,TargetObjectId,CreatedById
                from ProcessInstance
                where TargetObjectId in :quoteMap.keyset()
                order by LastmodifiedDate DESC
                LIMIT 1
        ];

        List<QuoteLineItem> qliList = [select id, QuoteId, MC_Quarantine_Time__c,MC_OCN_Discount__c, TeliaSE_Minimum_Value_Commit__c,MC_CommercialTermsQli__c,TeliaSE_Product_Object_Type__c from QuoteLineItem where QuoteId in :quoteMap.keyset() and vlocity_cmt__ParentItemId__c = null];
        Id CurrentUserId = UserInfo.GetUserId();

        User appApproverUser = [
                Select Id,MassCustomized_Roles__c, Name,TeliaSE_Role_based_Approver__c,TeliaSE_Role_based_Approver__r.Name
                from User
                where Id = :CurrentUserId
                limit 1
        ];
        Map<String, String> mcRoleMap = new Map<String, String>();
        Map<String, Object> commercialTermsQli = new Map<String, Object>();
        //How to avoid existing approved values
        for (Quote quote : quoteMap.values()) {
            //List<String> commercialTerms = string.isNotBlank(quote.MC_CommercialTerms__c) ? quote.MC_CommercialTerms__c.split(';') : new List<String>();
            Map<String, Object> commercialTerms = new Map<String, Object>();
            if (String.isNotBlank(quote.MC_CommercialTerms__c)) {
                commercialTerms = (Map<String, Object>) json.deserializeUntyped(quote.MC_CommercialTerms__c);
            }
            for (string cn : MC_CommercialNegotiation__c.getAll().keySet()) {
                if ((cn.equalsIgnoreCase('Payment Terms')) && (quote.MC_Payment_Term__c != null && MC_CommercialNegotiation__c.getAll().get('Payment Terms').Default_Value__c != null) && quote.MC_Payment_Term__c != Decimal.ValueOf(MC_CommercialNegotiation__c.getAll().get('Payment Terms').Default_Value__c) && MC_CommercialNegotiation__c.getAll().get('Payment Terms').Approval_Required__c && (String.isBlank(quote.MC_CommercialTerms__c) || (!String.isBlank(quote.MC_CommercialTerms__c) && commercialTerms.containsKey('Payment Terms') && quote.MC_Payment_Term__c > (Decimal) commercialTerms.get('Payment Terms')))) {
                    mcRoleMap.put(cn, MC_CommercialNegotiation__c.getAll().get('Payment Terms').Approved_By__c);
                } else if ((cn.equalsIgnoreCase('Invoice Fee')) && (quote.TeliaSE_Invoice_Fee__c != null && MC_CommercialNegotiation__c.getAll().get('Invoice Fee').Default_Value__c != null) && !quote.TeliaSE_Invoice_Fee__c.equalsIgnoreCase(MC_CommercialNegotiation__c.getAll().get('Invoice Fee').Default_Value__c) && MC_CommercialNegotiation__c.getAll().get('Invoice Fee').Approval_Required__c && (String.isBlank(quote.MC_CommercialTerms__c) || (!String.isBlank(quote.MC_CommercialTerms__c) && commercialTerms.containsKey('Invoice Fee') && quote.TeliaSE_Invoice_Fee__c != commercialTerms.get('Invoice Fee')))) {
                    mcRoleMap.put(cn, MC_CommercialNegotiation__c.getAll().get('Invoice Fee').Approved_By__c);
                } else if ((cn.equalsIgnoreCase('Benchmarking Agreements')) && (quote.MC_Commercial_Benchmark__c != null && MC_CommercialNegotiation__c.getAll().get('Benchmarking Agreements').Default_Value__c != null) && !quote.MC_Commercial_Benchmark__c.equalsIgnoreCase(MC_CommercialNegotiation__c.getAll().get('Benchmarking Agreements').Default_Value__c) && MC_CommercialNegotiation__c.getAll().get('Benchmarking Agreements').Approval_Required__c && (String.isBlank(quote.MC_CommercialTerms__c) || (!String.isBlank(quote.MC_CommercialTerms__c) && commercialTerms.containsKey('Benchmarking Agreements') && quote.MC_Commercial_Benchmark__c != commercialTerms.get('Benchmarking Agreements')))) {
                    mcRoleMap.put(cn, MC_CommercialNegotiation__c.getAll().get('Benchmarking Agreements').Approved_By__c);
                } else if ((cn.equalsIgnoreCase('IndexationClause')) && (quote.MC_Indexation_Clause__c != null && MC_CommercialNegotiation__c.getAll().get('IndexationClause').Default_Value__c != null) && !quote.MC_Indexation_Clause__c.equalsIgnoreCase(MC_CommercialNegotiation__c.getAll().get('IndexationClause').Default_Value__c) && MC_CommercialNegotiation__c.getAll().get('IndexationClause').Approval_Required__c && (String.isBlank(quote.MC_CommercialTerms__c) || (!String.isBlank(quote.MC_CommercialTerms__c) && commercialTerms.containsKey('IndexationClause') && quote.MC_Indexation_Clause__c!= commercialTerms.get('IndexationClause')))) {
                    mcRoleMap.put(cn, MC_CommercialNegotiation__c.getAll().get('IndexationClause').Approved_By__c);
                }
                //String commercialTerm =  quote.MC_Payment_Term__c  + ';' +  quote.TeliaSE_Invoice_Fee__c + ';' +  quote.MC_Commercial_Benchmark__c;
                //quote.MC_CommercialTerms__c = commercialTerm;
            }
            commercialTerms.put('Payment Terms', quote.MC_Payment_Term__c);
            commercialTerms.put('Invoice Fee', quote.TeliaSE_Invoice_Fee__c);
            commercialTerms.put('Benchmarking Agreements', quote.MC_Commercial_Benchmark__c);
            commercialTerms.put('IndexationClause', quote.MC_Indexation_Clause__c);
            quote.MC_CommercialTerms__c = json.serialize(commercialTerms);
        }
        if (qliList != null && qliList.size() > 0) {
            for (QuoteLineItem qli : qliList) {
                if (String.isNotBlank(qli.MC_CommercialTermsQli__c)) {
                    commercialTermsQli = (Map<String, Object>) json.deserializeUntyped(qli.MC_CommercialTermsQli__c);
                }
                //for non CO products
                if (qli.TeliaSE_Product_Object_Type__c == 'Mobile Offer Specification' || qli.TeliaSE_Product_Object_Type__c == 'Touch Point Offer Spec'|| qli.TeliaSE_Product_Object_Type__c == 'Smart Connect Offer Spec' || qli.TeliaSE_Product_Object_Type__c == 'Operator Connect Offer Spec') {
                    for (string cn : MC_CommercialNegotiation__c.getAll().keySet()) {
                        if ((cn.equalsIgnoreCase('TimeToReachBaseLevel')) && (qli.MC_Quarantine_Time__c != null && MC_CommercialNegotiation__c.getAll().get('TimeToReachBaseLevel').Default_Value__c != null) && qli.MC_Quarantine_Time__c != (MC_CommercialNegotiation__c.getAll().get('TimeToReachBaseLevel').Default_Value__c) && MC_CommercialNegotiation__c.getAll().get('TimeToReachBaseLevel').Approval_Required__c && (String.isBlank(qli.MC_CommercialTermsQli__c) || (!String.isBlank(qli.MC_CommercialTermsQli__c) && commercialTermsQli.containsKey('TimeToReachBaseLevel') && qli.MC_Quarantine_Time__c != commercialTermsQli.get('TimeToReachBaseLevel')))) {
                            mcRoleMap.put(cn, MC_CommercialNegotiation__c.getAll().get('TimeToReachBaseLevel').Approved_By__c);
                        } else if ((cn.equalsIgnoreCase('MinimumCommitment')) && (qli.TeliaSE_Minimum_Value_Commit__c != null && MC_CommercialNegotiation__c.getAll().get('MinimumCommitment').Default_Value__c != null) && !qli.TeliaSE_Minimum_Value_Commit__c.equalsIgnoreCase(MC_CommercialNegotiation__c.getAll().get('MinimumCommitment').Default_Value__c) && MC_CommercialNegotiation__c.getAll().get('MinimumCommitment').Approval_Required__c && (String.isBlank(qli.MC_CommercialTermsQli__c) || (!String.isBlank(qli.MC_CommercialTermsQli__c) && commercialTermsQli.containsKey('MinimumCommitment') && qli.TeliaSE_Minimum_Value_Commit__c != commercialTermsQli.get('MinimumCommitment')))) {
                            mcRoleMap.put(cn, MC_CommercialNegotiation__c.getAll().get('MinimumCommitment').Approved_By__c);
                        }
                    }
                }

                //for CO products only
                if (qli.TeliaSE_Product_Object_Type__c == 'Broadband Start Offering Spec' || qli.TeliaSE_Product_Object_Type__c == 'Broadband Plus Offering Spec' || qli.TeliaSE_Product_Object_Type__c == 'Broadband Pro Offering Spec' || qli.TeliaSE_Product_Object_Type__c == 'WIFI/LAN Offering Spec' || qli.TeliaSE_Product_Object_Type__c == 'SD-WAN/Firewall Offering Spec') {

                    for (string cn : MC_CommercialNegotiation__c.getAll().keySet()) {
                        /*if((cn.equalsIgnoreCase('TimeToReachBaseLevelForCO')) && (qli.MC_Quarantine_Time__c != null && MC_CommercialNegotiation__c.getAll().get('TimeToReachBaseLevelForCO').Default_Value__c != null) && qli.MC_Quarantine_Time__c !=(MC_CommercialNegotiation__c.getAll().get('TimeToReachBaseLevelForCO').Default_Value__c) && MC_CommercialNegotiation__c.getAll().get('TimeToReachBaseLevelForCO').Approval_Required__c && (String.isBlank(qli.MC_CommercialTermsQli__c) || (!String.isBlank(qli.MC_CommercialTermsQli__c) && commercialTermsQli.containsKey('TimeToReachBaseLevelForCO') && qli.MC_Quarantine_Time__c != commercialTermsQli.get('TimeToReachBaseLevelForCO')))){
                             mcRoleMap.put(cn, MC_CommercialNegotiation__c.getAll().get('TimeToReachBaseLevelForCO').Approved_By__c);
                         }else if((cn.equalsIgnoreCase('MinimumCommitmentForCO')) && (qli.TeliaSE_Minimum_Value_Commit__c != null && MC_CommercialNegotiation__c.getAll().get('MinimumCommitmentForCO').Default_Value__c != null) && !qli.TeliaSE_Minimum_Value_Commit__c.equalsIgnoreCase(MC_CommercialNegotiation__c.getAll().get('MinimumCommitmentForCO').Default_Value__c)  && MC_CommercialNegotiation__c.getAll().get('MinimumCommitmentForCO').Approval_Required__c && (String.isBlank(qli.MC_CommercialTermsQli__c) || (!String.isBlank(qli.MC_CommercialTermsQli__c) && commercialTermsQli.containsKey('MinimumCommitmentForCO') && qli.TeliaSE_Minimum_Value_Commit__c != commercialTermsQli.get('MinimumCommitmentForCO')))){
                             mcRoleMap.put(cn, MC_CommercialNegotiation__c.getAll().get('MinimumCommitmentForCO').Approved_By__c);
                         }*/
                        if ((cn.equalsIgnoreCase('OCNDiscount')) && (qli.MC_OCN_Discount__c != null && MC_CommercialNegotiation__c.getAll().get('OCNDiscount').Default_Value__c != null) && qli.MC_OCN_Discount__c != (MC_CommercialNegotiation__c.getAll().get('OCNDiscount').Default_Value__c) && MC_CommercialNegotiation__c.getAll().get('OCNDiscount').Approval_Required__c && (String.isBlank(qli.MC_CommercialTermsQli__c) || (!String.isBlank(qli.MC_CommercialTermsQli__c) && commercialTermsQli.containsKey('OCNDiscount') && qli.MC_OCN_Discount__c != commercialTermsQli.get('OCNDiscount')))) {
                            mcRoleMap.put(cn, MC_CommercialNegotiation__c.getAll().get('OCNDiscount').Approved_By__c);
                        }
                    }
                }
            }
        }
        if (mcRoleMap != null && mcRoleMap.size() > 0) {
            Decimal heighestRolePrecdence = 0;
            for (String CommercialNegotiationName : mcRoleMap.keyset()) {
                if (heighestRolePrecdence < MC_RolePrecedence__c.getAll().get(MC_CommercialNegotiation__c.getAll().get(CommercialNegotiationName).Approved_By__c).Precedence__c) {
                    heighestRolePrecdence = MC_RolePrecedence__c.getAll().get(MC_CommercialNegotiation__c.getAll().get(CommercialNegotiationName).Approved_By__c).Precedence__c;
                }
            }
            if ((appApproverUser.MassCustomized_Roles__c != null && MC_RolePrecedence__c.getAll().get(appApproverUser.MassCustomized_Roles__c).Precedence__c != null) && heighestRolePrecdence <= MC_RolePrecedence__c.getAll().get(appApproverUser.MassCustomized_Roles__c).Precedence__c) {
                flag = true;
            }
        } else {
            flag = true;
        }
        return flag;

    }

    public static void updatePTAttribute(Map<Id, QuoteLineItem> newMap) {
        QuotelineItem qli1 = new QUotelineItem();
        for (Id quotelineItemId : newMap.keySet()) {
            qli1 = newmap.get(quotelineItemId);
        }
        if (newMap.values().size() > 0 && qli1.TeliaSE_Product_Code__c == 'PT_PLUS') {
            HidePTPlusAttributes(newMap.keySet());
        }
    }

/*
 * Adding this code to hide the Attributes of PT Plus Product in Offer Quote Cart
  */
    public static void HidePTPlusAttributes(Set<Id> Ids) {
        try {
            QuoteLineItem ptList = [select Id,vlocity_cmt__JSONAttribute__c from QuoteLineItem where Quote.RecordType.DeveloperName = 'Offer' and Id = :Ids];
            if (ptList != null) {
                Map<String, Object> rawObj = (Map<String, Object>) JSON.deserializeUntyped(ptList.vlocity_cmt__JSONAttribute__c);
                List<Object> o1 = (List<Object>) rawObj.get('ATT_CODE_TELIAMOBAGGR');
                List<Object> o3 = new List<Object>();
                Map<String, Object> lsstr = new Map<String, Object>();
                Boolean attributeStatus;
                Boolean flag = false;
                for (Object o2 : o1) {
                    lsstr = (Map<String, Object>) o2;
                    attributeStatus = (Boolean) lsstr.get('ishidden__c');
                    if (attributeStatus == false) {
                        lsstr.put('ishidden__c', true);
                        flag = true;
                    }
                    o3.add(lsstr);
                }
                if (flag == true) {
                    Map<String, Object> newMap = new Map<String, Object>();
                    newMap.put('ATT_CODE_TELIAMOBAGGR', o3);
                    String jsonMap = JSON.serialize(newMap);
                    ptList.vlocity_cmt__JSONAttribute__c = jsonMap;
                    update ptList;
                }
            }
        } catch (Exception e) {
            system.debug('Exception ' + e.getMessage());
        }
    }


    /*-----------------------------------------------------------------------------------------------------------
**Name: postFeedOnApproveReject
**Created By:  Tridib
**User Story:MCSTO-1222
**Description: Creates chatter feed upon apporval or rejection of Quote prices
------------------------------------------------------------------------------------------------------*/
    public static void postFeedOnApproveReject(List<Quote> QtList, Map<Id, Quote>MapOldQuotes, Map<Id, Quote>MapNewQuotes) {
        List<FeedItem> feedsTobeCreated = New List <FeedItem>();
        Map<Id, Quote> quoteIdsMap = new Map<Id, Quote>{
        };
        Map<Id, Quote> quoteProcessIdsMap = new Map<Id, Quote>{
        };
        Map<Id, ProcessInstance> processInstanceMap = new Map<Id, ProcessInstance>{
        };
        Set<Id> createdByIds = new Set<Id>{
        };
        Map<Id, Quote> quoteMap = new Map<Id, Quote>{
        };
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String ApproverComments = '';
        String QuoteStatus = '';
        String QuoteName = '';
        String QuoteNumber = '';
        String AccountName = '';
        String QuoteId = '';
        String AccountOwner = '';
        String fileLink = '';

        for (Quote q : QtList) {
            //If the quote gets rejected, seller should be able to reconfigure the same quote with different price and resend for approval
            if (q.status != 'Sent For Approval' && MapOldQuotes.get(q.Id).status != MapNewQuotes.get(q.Id).status) {
                quoteIdsMap.put(q.Id, q);
            }
        }
        for (Quote quo : [select Id, Name, Account.Name, Account.Type,Account.Owner.Name, QuoteNumber,TeliaSE_MC_ApprovalFileLink__c from Quote where Id IN:quoteIdsMap.keyset()]) {
            quoteMap.put(quo.Id, quo);
        }

        ProcessInstance[] instances = [
                select Id,TargetObjectId,CreatedById, CreatedBy.UserName, LastActorId, Status, (SELECT comments,OriginalActorId,TargetObjectId,ActorId from StepsAndWorkitems), (
                        select Comments,OriginalActorId,ActorId,ProcessInstanceId,StepStatus
                        from
                                Steps
                        ORDER BY SystemModstamp DESC
                )
                from ProcessInstance
                where TargetObjectId in :quoteMap.keyset()
                order by LastmodifiedDate DESC
                LIMIT 1
        ];

        for (ProcessInstance instance : instances) {
            createdByIds.add(instance.CreatedById);
            quoteProcessIdsMap.put(instance.id, quoteMap.get(instance.TargetObjectId));
        }
        Map<Id, String> MapLstMangervsUser = new Map<Id, String>();
        Id CurrentUserId = UserInfo.GetUserId();
        Set<Id> IdReportees = new Set<Id>();
        Map<String, String> MAPEngvsSwedish = new Map<String, String>{
                'Approved' => 'godkänts',
                'Rejected' => 'nekats'
        };
        List<User> lstUser = [
                Select Id,Name,TeliaSE_Role_based_Approver__c,TeliaSE_Role_based_Approver__r.Name
                from User
                where TeliaSE_Role_based_Approver__c = :CurrentUserId OR TeliaSE_Role_based_Approver__r.TeliaSE_Role_based_Approver__c = :CurrentUserId OR TeliaSE_Role_based_Approver__r.TeliaSE_Role_based_Approver__r.TeliaSE_Role_based_Approver__c = :CurrentUserId
        ];
        for (User objuser : lstUser) {
            IdReportees.add(objuser.Id);
        }

        Set<Id> FinalUsersInProcess = new Set<Id>();
        for (ProcessInstance instance : instances) {
            //Quote variable
            Quote currentQuote = quoteProcessIdsMap.get(instance.id);

            for (ProcessInstanceStep step : instance.Steps) {
                for (String userId : IdReportees) {
                    if (userId == step.OriginalActorId || userId == step.ActorId || instance.LastActorId == step.OriginalActorId || instance.LastActorId == step.ActorId) {
                        if (step.StepStatus == 'Approved' || step.StepStatus == 'Rejected') {
                            ApproverComments = step.Comments;
                            QuoteStatus = step.StepStatus;
                            QuoteNumber = currentQuote.QuoteNumber;
                            AccountName = currentQuote.Account.Name;
                            QuoteName = currentQuote.Name;
                            QuoteId = currentQuote.Id;
                            fileLink = currentQuote.TeliaSE_MC_ApprovalFileLink__c;
                            AccountOwner = currentQuote.Account.Owner.Name;
                        }


                        FinalUsersInProcess.add(step.OriginalActorId);
                        FinalUsersInProcess.add(step.ActorId);
                    }
                }
            }
        }

        //Creates chatter post
        if (FinalUsersInProcess.size() > 0) {
            for (Id ObjUserNotifiedId : FinalUsersInProcess) {
                if (ObjUserNotifiedId != UserInfo.getUserId()) {
                    feedsTobeCreated.add(new FeedItem(ParentId = Id.ValueOf(ObjUserNotifiedId), Body = 'Hej,' + '\n' + AccountName + ' \'' + 's' + ' offert ' + QuoteNumber + ' har ' + MAPEngvsSwedish.get(QuoteStatus) + '\n' + 'Kommentar : ' + ApproverComments + ' bilagor:' + fileLink + '\n' + 'Säljare: ' + AccountOwner
                            + '\n', Title = QuoteName + '  ' + QuoteNumber, LinkURL = baseUrl + '/' + QuoteId));
                }
            }
            if (String.IsNotBlank(QuoteId)) {
                feedsTobeCreated.add(new FeedItem(ParentId = QuoteId, Body = 'Hej,' + '\n' + AccountName + ' \'' + 's' + ' offert ' + QuoteNumber + ' har ' + MAPEngvsSwedish.get(QuoteStatus) + '\n' + 'Kommentar : ' + ApproverComments + ' bilagor:' + '\n' + 'Säljare: ' + AccountOwner +
                        '\n', Title = QuoteName + '  ' + QuoteNumber, LinkURL = baseUrl + '/' + QuoteId));
            }
        }
        if (feedsTobeCreated.size() > 0) {
            Database.insert(feedsTobeCreated, false);
        }
    }
    /*-----------------------------------------------------------------------------------------------------------
**Name: setFlagField
**Created By:  Monika Verma
**Sprint: CI
**User Story:MCSTO-914
**Description: Trigger Code on Quote for SHaring Rule implementation on Opportunity for MC Users
-----------------------------------------------------------------------------------------------------------*/
    public static void setFlagField(Map<Id, Quote> newMap) {
        Set<Id> ids = new Set<Id>();
        Opportunity valFlag = new Opportunity();
        for (Quote quote : newMap.values()) {
            if (quote.TeliaSE_Record_Type_Name__c == 'Contract' || quote.TeliaSE_Record_Type_Name__c == 'Offer') {
                ids.add(quote.OpportunityId);
            }
        }
        if (ids.size() > 0) {
            valFlag = [Select TeliaSE_SharingSetting_Flag__c from Opportunity where id = :ids];
            if (valFlag.TeliaSE_SharingSetting_Flag__c == false) {
                valFlag.TeliaSE_SharingSetting_Flag__c = true;
            }
            update valFlag;
        }
    }


/*-----------------------------------------------------------------------------------------------------------
**Name: FiberUpdateApprovedPrice
**Created By:  Adarsh Singh
**Sprint: Sprint-2
**User Story:FIBE-1074
**Description: Update Approval Flag for Quote Approved.
Defect 382 'CRMfiber || Phase2 || ST || Approved price and flag is not updating after approved by manager
-----------------------------------------------------------------------------------------------------------*/
    public static void FiberUpdateApprovedPrice(List<Quote> QtList, Map<Id, Quote> oldMap, Map<Id, Quote> newMap) {
        try {
            //Collect Quote id for Quote which is approved via approval Process
            string recType = QtList != null ? QtList[0].TeliaSE_Record_Type_Name__c : null;
            if (recType != null && QtList != null && QtList.size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.FIBER, SEUtility.QUOTE, recType)) {
                Set<Id> QuoteId = new Set<Id>();
                List<QuoteLineItem> QlList = new List<QuoteLineItem>();
                for (Quote qt : QtList) {
                    if ((qt.status.equalsIgnoreCase('Price Approved')) && (oldMap.get(qt.Id).status.equalsIgnoreCase('Sent For Approval'))) {
                        QuoteId.add(qt.Id);
                    }
                }
                if (QuoteId.Size() > 0) {
                    QlList = [select id,Fiber_Approved_Price__c,Fiber_Customer_Requested_Price__c,TeliaSE_Flag__c from QuoteLineItem where (TeliaSE_Quote_RecordType__c = 'Individual_Quote' OR TeliaSE_Quote_RecordType__c = 'TeliaSE_Fiber_CA_Quote') AND quoteid in:quoteid];
                }
                list<QuoteLineItem> QuoteItemValueList = new list<QuoteLineItem> ();
                QuoteLineItem QuoteItemValue = new QuoteLineItem ();
                for (QuoteLineItem ql : QlList) {

                    if (ql.Fiber_Approved_Price__c == null) {
                        IF (ql.Fiber_Customer_Requested_Price__c != null && ql.Fiber_Customer_Requested_Price__c >= 0) {
                            ql.Fiber_Approved_Price__c = ql.Fiber_Customer_Requested_Price__c;
                            ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                            QuoteItemValuelist.add(ql);
                        }
                    } else if (ql.Fiber_Approved_Price__c > ql.Fiber_Customer_Requested_Price__c) {
                        IF (ql.Fiber_Customer_Requested_Price__c != null) {
                            ql.Fiber_Approved_Price__c = ql.Fiber_Customer_Requested_Price__c;
                            ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                            QuoteItemValuelist.add(ql);
                        }
                    } else if (ql.Fiber_Customer_Requested_Price__c > ql.Fiber_Approved_Price__c) {
                        IF (ql.Fiber_Customer_Requested_Price__c != null) {
                            ql.Fiber_Approved_Price__c = ql.Fiber_Customer_Requested_Price__c;
                            ql.TeliaSE_Flag__c = label.TeliaSE_HappyFace;
                            QuoteItemValuelist.add(ql);
                        }
                    }
                }
                if (QuoteItemValuelist.size() > 0) {
                    update QuoteItemValuelist;
                }
            }
        } catch (Exception e) {
            system.debug('Error : ' + e.getMessage());
        }
    }
    /*-----------------------------------------------------------------------------------------------------------
**Name: UpdateApprovalFlag
**Created By:  Vaishali Srivastava
**Sprint: 7
**User Story:Defect -167
**Description: Update quote flag field to avoid approving record without Approval
-----------------------------------------------------------------------------------------------------------*/
    /*public static void FiberUpdateApprovalFlag(List<Quote> QtList,Map<Id,Quote> oldMap,Map<Id,Quote> newMap)
    {

        for (Quote qt : QtList) {
            if(qt.TeliaSE_Approval_Count__c >0)
            {
                if((qt.TeliaSE_Approval_Flag__c == True) &&
                   (oldMap.get(qt.Id).TeliaSE_Approval_Flag__c == newMap.get(qt.Id).TeliaSE_Approval_Flag__c))
                {
                    qt.TeliaSE_Approval_Flag__c = False;
                }
            }
        }


    }*/

/*-----------------------------------------------------------------------------------------------------------
**Name: checkMandateforFiber
**Created By:  Pavan
**Description: Error Message for Sales Manager Mandate(US Sprint-4 CRMFiber)
-----------------------------------------------------------------------------------------------------------*/
    public static void checkMandateforFiber(List<Quote> QtList, Map<Id, Quote> oldMap, Map<Id, Quote> newMap) {
        string recType = QtList != null ? QtList[0].TeliaSE_Record_Type_Name__c : null;
        if (recType != null && QtList != null && QtList.size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.FIBER, SEUtility.QUOTE, recType)) {
            List<String> fiberRecordTypes = new List<String>();
            fiberRecordTypes.add('Individual_Quote');
            fiberRecordTypes.add('TeliaSE_Fiber_FA_Quote');
            fiberRecordTypes.add('TeliaSE_Fiber_CA_Quote_of_FA');
            fiberRecordTypes.add('TeliaSE_Fiber_CA_Quote');
            Set<Id> ids = new Set<Id>();
            Map<Id, Id> processMap = new Map<Id, Id>();
            for (Quote quo : QtList) {
                if (fiberRecordTypes.contains(oldMap.get(quo.Id).TeliaSE_Record_Type_Name__c) && oldMap.get(quo.Id).Status == 'Sent for Approval' && newMap.get(quo.Id).status == 'Approved'
                        || (oldMap.get(quo.Id).Status == 'Sent for Approval' && newMap.get(quo.Id).status == 'Price Approved')
                        ) {
                    ids.add(quo.id);
                }
            }

            Set<Id> requesterIds = new Set<Id>();
            if (ids != null && ids.size() > 0) {
                for (ProcessInstanceWorkitem item : [SELECT Id, createdById, ProcessInstance.TargetObjectId, OriginalActorId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :ids]) {
                    requesterIds.add(item.createdById);
                    processMap.put(item.ProcessInstance.TargetObjectId, item.OriginalActorId);
                }
            }
            Quote quoteValue = QtList.get(0);
            Id quoteId = quoteValue.id;
            Quote quote = [select TeliaSE_Fiber_EBIT_Percentage__c from Quote where id = :quoteId];
            Decimal MaxDiscount;

            //List<User> requesterUserList = [Select id, ManagerId from User where id in :requesterIds or id = ManagerId];

            List<User> requesterUserList = [Select id, ManagerId,Manager.DelegatedApproverId from User where id in :requesterIds];
            Map<Id, User> salesRepManagerMap = new Map<Id, User>();
            Set<Id> managerIds = new Set<Id>();

            for (User user : requesterUserList) {
                //salesRepManagerMap.put(user.Id, user.ManagerId);
                managerIds.add(user.ManagerId);
            }
            List<User> managerDirectorList = [Select id, ManagerId,Manager.DelegatedApproverId,DelegatedApproverId from User where id in :managerIds];
            Map<Id, User> managerDirectorMap = new Map<Id, User>();

            for (User user : managerDirectorList) {
                managerDirectorMap.put(user.Id, user);
            }


            Decimal managerMinMandate = FiberDiscountMandate__c.getAll().get('Manager').ProductDiscountMinMandate__c;
            Decimal managerMaxMandate = FiberDiscountMandate__c.getAll().get('Manager').ProductDiscountMaxMandate__c;
            Decimal directorMinMandate = FiberDiscountMandate__c.getAll().get('Director').ProductDiscountMinMandate__c;
            Decimal managerEBITMinMandate = FiberDiscountMandate__c.getAll().get('Manager').EBIT_Min_Mandate__c;
            Decimal managerEBITMaxMandate = FiberDiscountMandate__c.getAll().get('Manager').EBIT_Max_Mandate__c;
            Decimal directorEBITMinMandate = FiberDiscountMandate__c.getAll().get('Director').EBIT_Min_Mandate__c;

            for (QuoteLineItem item : [select id,createdById,quoteId,TeliaSE_fiber_Rabatt__c from QuoteLineItem where quoteId in :ids]) {

                if (item.TeliaSE_fiber_Rabatt__c != null) {
                    for (User usr : requesterUserList) {
                        MaxDiscount = item.TeliaSE_fiber_Rabatt__c;
                        if (((usr.ManagerId != null && usr.ManagerId == UserInfo.getUserId()) || (usr.Manager.DelegatedApproverId != null && usr.Manager.DelegatedApproverId == UserInfo.getUserId())) &&

                                (MaxDiscount <= managerMaxMandate) &&
                                (Quote.TeliaSE_Fiber_EBIT_Percentage__c >= managerEBITMinMandate)
                                ) {
                        }
                        //else if(( usr.DelegatedApproverId != null && usr.DelegatedApproverId == UserInfo.getUserId() ) && MaxDiscount > 20 && Quote.TeliaSE_Fiber_EBIT_Percentage__c < 25 )
                        else if ((managerDirectorMap != null && (managerDirectorMap.get(usr.ManagerId).ManagerId == UserInfo.getUserId() || managerDirectorMap.get(usr.ManagerId).Manager.DelegatedApproverId == UserInfo.getUserId()))) {
                        } else {
                            if (!Test.isRunningTest()) {
                                //newMap.get(item.quoteId).addError('Det finns priser utanför dina mandat. Vänligen ”Tilldela igen” till ledare eller justera priser i konfigurationen.');
                                newMap.get(item.quoteId).addError(System.Label.Error_Message_for_Sales_Manager);
                            }
                        }
                    }
                } else {
                    for (User usr : requesterUserList) {

                        if ((usr.ManagerId != null && usr.ManagerId == UserInfo.getUserId() || (usr.Manager.DelegatedApproverId != null && usr.Manager.DelegatedApproverId == UserInfo.getUserId())) &&
                                ((Quote.TeliaSE_Fiber_EBIT_Percentage__c >= managerEBITMinMandate))
                                ) {
                        }
                        //else if(( usr.DelegatedApproverId != null && usr.DelegatedApproverId == UserInfo.getUserId() ) && MaxDiscount > 20 && Quote.TeliaSE_Fiber_EBIT_Percentage__c < 25 )
                        else if ((managerDirectorMap != null && (managerDirectorMap.get(usr.ManagerId).ManagerId == UserInfo.getUserId() || managerDirectorMap.get(usr.ManagerId).Manager.DelegatedApproverId == UserInfo.getUserId()))) {
                        } else {
                            if (!Test.isRunningTest()) {
                                //newMap.get(item.quoteId).addError('Det finns priser utanför dina mandat. Vänligen ”Tilldela igen” till ledare eller justera priser i konfigurationen.');
                                newMap.get(item.quoteId).addError(System.Label.Error_Message_for_Sales_Manager);
                            }
                        }
                    }
                }
            }
        }
    }
    public static void checkTypeOfAddress(List<Quote> newQuotes) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Quote quote : newQuotes) {
            if (quote.OpportunityId != null) {
                opportunityIds.add(quote.OpportunityId);
            }
        }
        if (opportunityIds.size() != 0) {
            Map<ID, Opportunity> mapOpportunities = new Map<ID, Opportunity>([SELECT Id, Type_of_Address__c from Opportunity WHERE id in:opportunityIds AND RecordType.DeveloperName = 'Real_Estate_Fiber']);
            for (Quote quote : newQuotes) {
                if (mapOpportunities.get(quote.OpportunityId) != null) {
                    quote.Type_of_Address__c = mapOpportunities.get(quote.OpportunityId).Type_of_Address__c;
                }
            }
        }
    }



/*
 * @Author:      Rahul Kadam
 * @Company:     Capgemini
 * @Date:        28th Dec 2021
 * @Description: This function is invoked from trigger. It fetches the value from desciption field of the quote and populated corresponding BlaKalkyl fields accordingly.
 * @Epic:        SALEF-5514. This class is invoked from trigger based on Quote.
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------------*/
    public static void SetBlaKalkylFieldVaues(Map<Id,Quote> newMap){
            try
            {
                for(Quote quote:newMap.values())
                {
                    if(quote.BlaKalkyl_Description__c!= null && quote.BlaKalkyl_Description__c!= '')
                    {
                        //Write logic for split and update fields
                        UpdateFieldsMethod(quote.BlaKalkyl_Description__c,quote.id);
                    }
                }
            }
            catch(Exception e)
            {
                system.debug('Error : '+e.getMessage());
            }
     }
    public static void UpdateFieldsMethod( string s, id quoteId ){
        try{
            List < String > vals = new List < String > ();
            List < String > keys = new List < String > {
                    'EBIT %',
                    'Revenue contract',
                    'Revenue contract årligen',
                    'OPEX',
                    'Capex Infra',
                    'Avtalstid',
                    'Upsell/Singeltjänster',
                    'Depr',
                    'Kundplacerad utrustning',
                    'ACK DCF',
                    'ACK DCF årligen',
                    'Return of Investment',
                    'PayBack WACC',
                    'Engång Fastighetsägare',
                    'Kollektiva intäkter',
                    'Pris 3Play exkl moms',
                    'Pris BB exkl. moms',
                    'Pris TV exkl moms',
                    'As is avtalstid kvar',
                    'Rev As is kvarvarande tid',
                    'Rev As is kvarv. tid årligen',
                    'As is ACK DCF',
                    'As is ACK DCF årligen',
                    '3Play Pris As is exkl moms',
                    'Pris BB exkl. moms As is case',
                    'Pris TV exkl moms As is case',
                    'Revenue B2C',
                    'Revenue B2B',
                    'External Revenue INFRA',
                    'Rev. Smart Building Services',
                    'Fastighets IT ',
                    'Rev. WiFi i Allmänna utr.',
                    'Rev. Telia Smart Home',
                    'Rev. Mobile X-sell',
                    'Byggnader med Fastighets-IT',
                    'Accespunkter WiFi',
                    'Förändring intäkt nytt avtal'
                    };
                      
          list<Quote> quoteToUpdate = [SELECT BlaKalkyl_Description__c,TeliaSE_Fiber_Revenues__c, TeliaSE_Fiber_OPEX__c, TeliaSE_Fiber_Capex_Infra__c, TeliaSE_Fiber_Contract_Term_Y__c, TeliaSE_Fiber_Upsell__c, TeliaSE_Fiber_Depreciation__c, TeliaSE_Fiber_Customer_Placed_Equipment__c, TeliaSE_Fiber_ACK_DCF__c, TeliaSE_Fiber_Return_Of_Investement__c, TeliaSE_Fiber_Payback_Y__c, TeliaSE_Fiber_One_time_Property_Owner__c, TeliaSE_Kollektiva_inakter__c, TeliaSE_Pris_BB_exkl_moms__c, TeliaSE_Pris_TV_exkl_moms__c, TeliaSE_Revenue_B2C__c, TeliaSE_Revenue_B2B__c, TeliaSE_External_Revenue_INFRA__c, TeliaSE_Smart_Building_Services__c, TeliaSE_Fastighets_IT__c, TeliaSE_WiFi_i_Allm_nna_utrymmen__c, TeliaSE_Telia_Smart_Home__c, TeliaSE_Mobile_X_sell__c,TeliaSE_Byggnader_med_Fastighets_IT__c,TeliaSE_Accespunkter_WiFi__c,TeliaSE_Revenue_contract_rligen__c,TeliaSE_ACK_DCF_rligen__c,TeliaSE_Pris_3Play_exkl_moms__c,TeliaSE_As_is_avtalstid_kvar__c,TeliaSE_Rev_As_is_kvarvarande_tid__c,TeliaSE_Rev_As_is_kvarv_tid_rligen__c,TeliaSE_As_is_ACK_DCF__c,TeliaSE_As_is_ACK_DCF_rligen__c,TeliaSE_Pris_BB_exkl_moms_As_is_case__c,TeliaSE_Pris_TV_exkl_moms_As_is_case__c,TeliaSE_3Play_Pris_exkl_moms__c,Change_income_new_agreement__c FROM QUOTE WHERE id =: quoteId];
                    s = (string)(quoteToUpdate[0].get('BlaKalkyl_Description__c'));
            string[] splitDescription = s.split('\n');
            list<string> Values = new list<String>();
            string temp = null;
            for(integer i = 0; i < splitDescription.size() ; i++){
                temp = splitDescription[i];
                Values.add(((temp.substringAfter(keys.get(i))).trim().replaceAll(',','.')));
            }
            
            //To update fields accordingly
            quoteToUpdate[0].TeliaSE_Fiber_EBIT_Percentage__c = Decimal.valueOf(Values[0]);
            quoteToUpdate[0].TeliaSE_Fiber_Revenues__c = double.valueOf(Values[1]);
            quoteToUpdate[0].TeliaSE_Revenue_contract_rligen__c = double.valueOf(Values[2]);
            quoteToUpdate[0].TeliaSE_Fiber_OPEX__c = double.valueOf(Values[3]);
            quoteToUpdate[0].TeliaSE_Fiber_Capex_Infra__c = double.valueOf(Values[4]);
            quoteToUpdate[0].TeliaSE_Fiber_Contract_Term_Y__c = double.valueOf(Values[5]);
            quoteToUpdate[0].TeliaSE_Fiber_Upsell__c = Decimal.valueOf(Values[6]);
            quoteToUpdate[0].TeliaSE_Fiber_Depreciation__c = double.valueOf(Values[7]);
            quoteToUpdate[0].TeliaSE_Fiber_Customer_Placed_Equipment__c = double.valueOf(Values[8]);
            quoteToUpdate[0].TeliaSE_Fiber_ACK_DCF__c = double.valueOf(Values[9]);
            quoteToUpdate[0].TeliaSE_ACK_DCF_rligen__c = double.valueOf(Values[10]);
            quoteToUpdate[0].TeliaSE_Fiber_Return_Of_Investement__c = Decimal.valueOf(Values[11]);
            quoteToUpdate[0].TeliaSE_Fiber_Payback_Y__c = double.valueOf(Values[12]);
            quoteToUpdate[0].TeliaSE_Fiber_One_time_Property_Owner__c = double.valueOf(Values[13]);
            quoteToUpdate[0].TeliaSE_Kollektiva_inakter__c = double.valueOf(Values[14]); 
            quoteToUpdate[0].TeliaSE_Pris_3Play_exkl_moms__c= double.valueOf(Values[15]);
            quoteToUpdate[0].TeliaSE_Pris_BB_exkl_moms__c= Decimal.valueOf(Values[16]);
            quoteToUpdate[0].TeliaSE_Pris_TV_exkl_moms__c= Decimal.valueOf(Values[17]);
            quoteToUpdate[0].TeliaSE_As_is_avtalstid_kvar__c= Decimal.valueOf(Values[18]);
            quoteToUpdate[0].TeliaSE_Rev_As_is_kvarvarande_tid__c= Decimal.valueOf(Values[19]);
            quoteToUpdate[0].TeliaSE_Rev_As_is_kvarv_tid_rligen__c= Decimal.valueOf(Values[20]);
            quoteToUpdate[0].TeliaSE_As_is_ACK_DCF__c= Decimal.valueOf(Values[21]);
            quoteToUpdate[0].TeliaSE_As_is_ACK_DCF_rligen__c= Decimal.valueOf(Values[22]);
            quoteToUpdate[0].TeliaSE_3Play_Pris_exkl_moms__c= Decimal.valueOf(Values[23]);
            quoteToUpdate[0].TeliaSE_Pris_BB_exkl_moms_As_is_case__c= Decimal.valueOf(Values[24]);
            quoteToUpdate[0].TeliaSE_Pris_TV_exkl_moms_As_is_case__c= Decimal.valueOf(Values[25]);
            quoteToUpdate[0].TeliaSE_Revenue_B2C__c= double.valueOf(Values[26]);
            quoteToUpdate[0].TeliaSE_Revenue_B2B__c= double.valueOf(Values[27]);
            quoteToUpdate[0].TeliaSE_External_Revenue_INFRA__c= double.valueOf(Values[28]);
            quoteToUpdate[0].TeliaSE_Smart_Building_Services__c= double.valueOf(Values[29]);
            quoteToUpdate[0].TeliaSE_Fastighets_IT__c= double.valueOf(Values[30]);
            quoteToUpdate[0].TeliaSE_WiFi_i_Allm_nna_utrymmen__c= double.valueOf(Values[31]);
            quoteToUpdate[0].TeliaSE_Telia_Smart_Home__c= double.valueOf(Values[32]);
            quoteToUpdate[0].TeliaSE_Mobile_X_sell__c= double.valueOf(Values[33]);
            quoteToUpdate[0].TeliaSE_Byggnader_med_Fastighets_IT__c= double.valueOf(Values[34]);
            quoteToUpdate[0].TeliaSE_Accespunkter_WiFi__c= double.valueOf(Values[35]);
            quoteToUpdate[0].Change_income_new_agreement__c= double.valueOf(Values[36]);
            quoteToUpdate[0].BlaKalkyl_Description__c= '';
            update quoteToUpdate;
        }
        catch(Exception e)
        {
            system.debug('Error : '+e.getMessage());

        }
    }


  public static void matchNumberFields(List<Quote> newList, Map<Id, Quote> oldMap) {
        Set<Id> opportunityIds = new Set<Id>();
        for (Quote quoteObj : newList) {
            if (Trigger.isInsert && quoteObj.OpportunityId != null) {
                opportunityIds.add(quoteObj.OpportunityId);
            } else if (
                quoteObj.TeliaSE_Fiber_Number_of_Households__c !=
                oldMap.get(quoteObj.Id).TeliaSE_Fiber_Number_of_Households__c ||
                quoteObj.Number_of_other_Ports__c != oldMap.get(quoteObj.Id).Number_of_other_Ports__c ||
                quoteObj.TeliaSE_Fiber_Number_of_Ports__c != oldMap.get(quoteObj.Id).TeliaSE_Fiber_Number_of_Ports__c ||
                quoteObj.TeliaSE_Fiber_Number_of_Facilities__c != oldMap.get(quoteObj.Id).TeliaSE_Fiber_Number_of_Facilities__c ||
                quoteObj.TeliaSE_Fiber_Number_of_Premises__c != oldMap.get(quoteObj.Id).TeliaSE_Fiber_Number_of_Premises__c ||
                quoteObj.Wished_delivery_date_not_guaranteed__c != oldMap.get(quoteObj.Id).Wished_delivery_date_not_guaranteed__c
            ) {
                opportunityIds.add(quoteObj.OpportunityId);
            }
        }
        if (opportunityIds.size() != 0) {
            Map<ID, Opportunity> mapOpportunities = new Map<ID, Opportunity>(
                [
                    SELECT Number_of_other_Ports__c, Number_of_Households__c, Number_of_Ports__c, Number_of_Premises__c,Wished_delivery_date_not_guaranteed__c,Number_of_Facilities__c
                    FROM Opportunity
                    WHERE Id IN :opportunityIds AND RecordType.DeveloperName = 'Real_Estate_Fiber'
                ]
            );

            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for (Quote quoteObj : newList) {
                if (Trigger.isUpdate) {
                    Opportunity opp = updatedOppOnUpdate(quoteObj, mapOpportunities, oldMap);
                    if(opp != null) {
                        oppsToUpdate.add(opp);
                    }
                } else if (Trigger.isInsert) {
                    Opportunity opp = updatedOppOnInsert(quoteObj, mapOpportunities);
                    if(opp != null) {
                        oppsToUpdate.add(opp);
                    }
                }
            }
            if (!oppsToUpdate.isEmpty()) {
                try {
                    update oppsToUpdate;
                } catch (Exception ex) {
                    insert errorHandling(ex, 'Exception', 'ContractTriggerHandler', 'Contract');
                }
            }
        }
    }
    public static vlocity_cmt__VlocityErrorLogEntry__c errorHandling(
        Exception ex,
        String errorType,
        String sourceName,
        String objectName
    ) {
        vlocity_cmt__VlocityErrorLogEntry__c errlog = new vlocity_cmt__VlocityErrorLogEntry__c(
            vlocity_cmt__ErrorType__c = errorType,
            vlocity_cmt__ErrorMessage__c = String.valueOf(ex.getmessage()),
            vlocity_cmt__SourceName__c = sourceName,
            vlocity_cmt__ObjectName__c = objectName
        );
        return errlog;
    }
    public static Opportunity updatedOppOnUpdate(
        Quote quoteObj,
        Map<Id, Opportunity> mapOpportunities,
        Map<Id, Quote> oldMap
    ) {
        Boolean needToUpdateOpp = false;
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.TeliaSE_Fiber_Number_of_Households__c !=
            oldMap.get(quoteObj.Id).TeliaSE_Fiber_Number_of_Households__c &&
            quoteObj.TeliaSE_Fiber_Number_of_Households__c !=
            mapOpportunities.get(quoteObj.OpportunityId).Number_of_Households__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId)
                .Number_of_Households__c = quoteObj.TeliaSE_Fiber_Number_of_Households__c;
            needToUpdateOpp = true;
        }
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.Number_of_other_Ports__c != oldMap.get(quoteObj.Id).Number_of_other_Ports__c &&
            quoteObj.Number_of_other_Ports__c != mapOpportunities.get(quoteObj.OpportunityId).Number_of_other_Ports__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId).Number_of_other_Ports__c = quoteObj.Number_of_other_Ports__c;
            needToUpdateOpp = true;
        }
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.TeliaSE_Fiber_Number_of_Ports__c != oldMap.get(quoteObj.Id).TeliaSE_Fiber_Number_of_Ports__c &&
            quoteObj.TeliaSE_Fiber_Number_of_Ports__c != mapOpportunities.get(quoteObj.OpportunityId).Number_of_Ports__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId).Number_of_Ports__c = quoteObj.TeliaSE_Fiber_Number_of_Ports__c;
            needToUpdateOpp = true;
        }
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.TeliaSE_Fiber_Number_of_Premises__c !=
            oldMap.get(quoteObj.Id).TeliaSE_Fiber_Number_of_Premises__c &&
            quoteObj.TeliaSE_Fiber_Number_of_Premises__c !=
            mapOpportunities.get(quoteObj.OpportunityId).Number_of_Premises__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId)
                .Number_of_Premises__c = quoteObj.TeliaSE_Fiber_Number_of_Premises__c;
            needToUpdateOpp = true;
        }
        if (
                mapOpportunities.get(quoteObj.OpportunityId) != null &&
                        quoteObj.TeliaSE_Fiber_Number_of_Facilities__c !=
                                oldMap.get(quoteObj.Id).TeliaSE_Fiber_Number_of_Facilities__c &&
                        quoteObj.TeliaSE_Fiber_Number_of_Facilities__c !=
                                mapOpportunities.get(quoteObj.OpportunityId).Number_of_Facilities__c
                ) {
            mapOpportunities.get(quoteObj.OpportunityId)
                    .Number_of_Facilities__c = quoteObj.TeliaSE_Fiber_Number_of_Facilities__c;
            needToUpdateOpp = true;
        }
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.Wished_delivery_date_not_guaranteed__c !=
            oldMap.get(quoteObj.Id).Wished_delivery_date_not_guaranteed__c &&
            quoteObj.Wished_delivery_date_not_guaranteed__c !=
            mapOpportunities.get(quoteObj.OpportunityId).Wished_delivery_date_not_guaranteed__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId)
                .Wished_delivery_date_not_guaranteed__c = quoteObj.Wished_delivery_date_not_guaranteed__c;
            needToUpdateOpp = true;
        }
        if (needToUpdateOpp) {
            return mapOpportunities.get(quoteObj.OpportunityId);
        } else {
            return null;
        }
    }
    public static Opportunity updatedOppOnInsert(Quote quoteObj, Map<Id, Opportunity> mapOpportunities) {
        Boolean needToUpdateOpp = false;
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.TeliaSE_Fiber_Number_of_Households__c !=
            mapOpportunities.get(quoteObj.OpportunityId).Number_of_Households__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId)
                .Number_of_Households__c = quoteObj.TeliaSE_Fiber_Number_of_Households__c;
            needToUpdateOpp = true;
        }
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.Number_of_other_Ports__c != mapOpportunities.get(quoteObj.OpportunityId).Number_of_other_Ports__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId).Number_of_other_Ports__c = quoteObj.Number_of_other_Ports__c;
            needToUpdateOpp = true;
        }
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.TeliaSE_Fiber_Number_of_Ports__c != mapOpportunities.get(quoteObj.OpportunityId).Number_of_Ports__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId).Number_of_Ports__c = quoteObj.TeliaSE_Fiber_Number_of_Ports__c;
            needToUpdateOpp = true;
        }
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.TeliaSE_Fiber_Number_of_Premises__c !=
            mapOpportunities.get(quoteObj.OpportunityId).Number_of_Premises__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId)
                .Number_of_Premises__c = quoteObj.TeliaSE_Fiber_Number_of_Premises__c;
            needToUpdateOpp = true;
        }
        if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.TeliaSE_Fiber_Number_of_Facilities__c !=
            mapOpportunities.get(quoteObj.OpportunityId).Number_of_Facilities__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId)
                .Number_of_Facilities__c = quoteObj.TeliaSE_Fiber_Number_of_Facilities__c;
            needToUpdateOpp = true;
        }
         if (
            mapOpportunities.get(quoteObj.OpportunityId) != null &&
            quoteObj.Wished_delivery_date_not_guaranteed__c !=
            mapOpportunities.get(quoteObj.OpportunityId).Wished_delivery_date_not_guaranteed__c
        ) {
            mapOpportunities.get(quoteObj.OpportunityId)
                .Wished_delivery_date_not_guaranteed__c = quoteObj.Wished_delivery_date_not_guaranteed__c;
            needToUpdateOpp = true;
        }
        if (needToUpdateOpp) {
            return mapOpportunities.get(quoteObj.OpportunityId);
        } else {
            return null;
        }
    }
}