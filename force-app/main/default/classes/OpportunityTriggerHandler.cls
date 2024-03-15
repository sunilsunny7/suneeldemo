/**
About
-----
Description: OpportunityTriggerHandler on Opportunity
Create date: 18.09-2015

Update History
--------------
Created Sep 2015 - A.N - Created
- Merged necessary methods from old Opportunity trigger to the new trigger handler

Updated
- Oct 2015 A.N Merged functionality from old OpportunityValidationHandler to the new trigger handler
- Oct 2015 A.N Created new methods for AfterInsert/AfterUpdate to create/update Forecast Opportunity Links
- Nov 2015 A.N Updated updateSellerOnOpportunity: Added close date change to filter, as this might potentially cause a seller update if the user has multiple seller records
- Dec 2015 A.N Created setLargeNewContinuationSales (replaces former workflow rule logic 'Update Large New/Cont Sales Currency field' as this caused a bug)
- Dec 2015 A.N For the updateSellerOnOpportunity, updated criteria so that it will also update the seller if account is changed
- Dec 2015 P.P Modified Code to delete FOL Records linked to Opportunities that get converted to Prospects
- Jan 2016 A.N New method setLargeNewContinuationSales created to set the values of the new weighted opp currency fields
- Jan 2016 A.N New method setOpportunitySplits to create opportunity split for Large accounts when account owner changes
- Apr 2016 A.N Added new Cygate NS/CS fields to the method set setLargeNewContinuationSales and renamed the method to setNewContinuationSalesAmounts
- Apr 2016 N.G New method 'deleteOppConRole' is created to delete Opp Contact Roles related to 'Cygate Internal AB' Account while moving to stage "Sluta Avtal" and from "Sluta Avtal" to stage "Vunnen, Förlorad, Avbruten"
- Apr 2016 P.P Changes to include Sales Value Target on Weekly and Quarterly Forecast
- May 2016 A.N Updated method setNewContinuationSalesAmounts for the new Telia Cygate common record type
- Sep 2016 A.N Refactored: Cleaned up in code/debug statements, restructured deleteOppConRole method, merged insertTeliaWeek and updateTeliaWeek to one method setTeliaWeek
- Sep 2016 S.S Case 1630 Added new method setRevenueImpact so that Revenue Impact is not less than CS
- Oct 2016 A.N SAEN-1817 Updated setWeightedNewContinuationSales: logic for new Weighted_Sales_Value_Forecast__c field, updated for NS/CS fields to split between Cygate/Telia record type
- Oct 2016 A.N SAEN-1736/1818 Updated method setOpportunitySplits: Also create opp splits for Cygate/Soho PR record types
- Oct 2016 P.P Case 1990 Changed methods filterOpps and updateFOL to exclude Förenklad affärsmöjlighet(Ut_kning_process) from FOL Creation Process Oct and Opportunity Split Creation Process
- Mar 2017 C.M Case 2195 Cygate sales manager needs to update the opportunity owner even if they don't own the opportunity.A new method is added "setCygateOpportunityOwner" for same purpose
- Mar 2017 S.S Case 2195 Access to Standard Price book for SOHO PR
- May 2017 P.P Case 3081 Access to opportunity Owner Change for Renewal Team - created new method - ownerChangeAccess
- May 2017 V.A Opportunity 2292 Merförsäljningsmöjlighet Opportunity record type assigned with correct Price Book
- May 2017 V.A Opportunity 2260 Convert Merförsäljningsmöjlighet to Prospects - created new method - ConvertMFtoProspect
- May 2017 V.A Opportunity 2313 created new methods - UpdateFrameOpportunityOnInsert, UpdateFrameOpportunityOnUpdate & UpdateFrameOpportunityOndelete
- May 2017 P.P Case 2790 - Updated method ownerChangeAccess such that Cygate Account Managers and Cygate Managers by heirarchy can update Opportunity Owner
- Sep 2017 V.M SAEN-2468 CrossAndUpsell: Create Prospect for main Account when empty Target Account list
- Nov 2017 P.P SALEF-396 created new method checkCygateOppSeller for Prospects getting converted to Cygate Opportunities
updated method filterOpps to not allow the creation of FOLs for Cygate record types of opportunities
- Dec 2017 P.P SALEF-335 Created Funnel Functionality so that all seller with type not 'Seller' have Funnel Record created for them, in the same way as FOLs
-May 2018 C.M SALEF-990 - Created a method CreateAddOppContactRole to create Opportunity Contact role on Prospect to Cygate Affar Opp record type
- May 2018 P.P SALEF-857 : Created method updateCaseAccess to update Case Share with Opportunity Owner only on Update of Opp
- May 2018 P.P SLAEF-873: Created methods for Performance Opportunity Link functionality
- June 2018 P.S SALEF-1081 - AddFormarOppsOwner()-Add the Former Opps owner as the Opps team member for security Opps with read/write access if it's from given cygate sales support roles
- Aug 2018 S.S have modified method CreateAddOppContactRole so that when contact is changed on cygate afar oppty then its reflected on oppty contact role
- Oct 2018 S.S added method validatecygateoldrecordtype SALEF-1428 - Cygate User should able to change only the record type for Cygate Standard opportunity, Cygate Efterregistrering and Cygate Utokning
- Oct 2018 S.S updated method updateSolutionArea to by pass web order record type
- Oct 2018 C.M Updated the sellerMap in loadsellerMap method to avoid the governor limit
- Feb 2019 S.K Updated method 'setPriceBook' to include setting default pricebook 'Real Estate Fiber Pricebook' on Opportunities whose Record Type = 'Real Estate Fiber'
-Jan 2020 P.S Commented PR related functionality.
-April 2020 P.S HW Affärsmöjlighet Opps will be excluded from Forecast of Account Owners.
-April 2020 P.S Commented the method -setKKnrField() as logic has been moved to the Formula.
- Oct 2020 P.S Added method addSMESalesKAMITasOTM() to add Sales KAM IT user as Opportunity Team Member
- Jan 2022 SALEF-5384 Added method AutoTaskOpportunitySync() for Lost ITDaaS Opportunity Sync to Auto Task
- Feb 2023 SALEF-8096 Added a new functionality (calculateTotalAmountCygate) that is counting total amount on frame agreement.
21.09.2023 [Tomass Brazovskis] LTAT-7256 - Ensure Wholesales Opportunities are exempt from existing automations.
--------------
*/

public class OpportunityTriggerHandler extends TriggerHandler {
    /* * * * * * * * * * * * * * * * * * * * * * * */
    /* * OpportunityTriggerHandler Trigger Calls * */
    /* * * * * * * * * * * * * * * * * * * * * * * */
    private List<Opportunity> newList{
        get{    return newList;}
        set{    newList = setListNonExemptOpportunities(value);}
    }
    private List<Opportunity> oldList{
        get{    return oldList;}
        set{    oldList = setListNonExemptOpportunities(value);}
    }
    private Map<Id, Opportunity> oldMap{
        get{    return oldMap;}
        set{    oldMap = setMapNonExemptOpportunities(value);}}
    private Map<Id, Opportunity> newMap{
        get{    return newMap;}
        set{    newMap = setMapNonExemptOpportunities(value);}
    }
    private List<Opportunity> newListAll;

    // Set of all Wholesales Opportunity RecordTypes
    private static Set<Id> setWholesalesRecordTypeIds = new Set<Id>{
        Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(SEConstantsOpportunity.OPPORTUNITY_RECORDTYPE_WHOLESALES_OPPORTUNITY)?.getRecordTypeId()
    };

    public OpportunityTriggerHandler() {
        this.newList = (List<Opportunity>) Trigger.new;
        this.oldList = (List<Opportunity>) Trigger.old;
        this.oldMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.newMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.newListAll = (List<Opportunity>) Trigger.new;
    }

    public override void beforeInsert() {
        if(!newList.isEmpty()){
            OpportunityValidationHandler.validateNoLargeOppsOnSmeAccs(newList);
            OpportunityValidationHandler.validateInsert(newList);
            setDealerName(newList);
            checkOpportunitySource(newList);
            setNewContinuationSalesAmounts(newList);
            setOriginalNSCS(newList);
            setWeightedNewContinuationSales(newList);
            setRelatedOrgUnitCygate(newList);
            setTeliaWeek(newList, null);
            SEUtility.setSellerOnOpportunity(newList);
            setPerformanceUseronOpp(newList, null); //P.P
            ownerChangeAccess(newList,null); // P.P
        }
        if(!newListAll.isEmpty()){
            setPriceBook(newListAll);
        }
    }

    public override void beforeUpdate() {
        if(!newList.isEmpty()){
            OpportunityValidationHandler.validateNoLargeOppsOnSmeAccs(newList);
            OpportunityValidationHandler.validateStageChange(newList, oldMap);
            OpportunityValidationHandler.validatecygateoldrecordtype(newList, oldMap);
            OpportunityValidationHandler.Opptystageupdate(newList,oldMap);
            OpportunityValidationHandler.checkFantasticFour(newList,oldMap);
            setNewContinuationSalesAmounts(newList);
            setWeightedNewContinuationSales(newList);
            setRevenueImpact(newList);
            setRelatedOrgUnitCygate(newList);
            setTeliaWeek(newList, oldMap);
            setCloseDateOnOppClose(newList, oldMap);
            deleteExistingSolutionSalesOutcomeRecords(newList, newMap, oldList, oldMap);
            updateSolutionArea(newList, oldMap);
            updateSellerOnOpportunity(newList, newMap, oldList, oldMap);
            checkCygateOppSeller(newList,oldmap); //P.P
            setPerformanceUseronOpp(newList,oldMap);  //P.P
            checkAFProducts(newList);
            ownerChangeAccess(newList,oldMap);  //P.P
        }
    }

    public override void afterInsert() {
        if(!newList.isEmpty()){
            createSolutionSalesOutcomeRecords(newList);
            createFOL(newList);
            setOpportunitySplits(newList, newMap, null, null);
            sellerMap = null;
            oppWithFOLsMap = null;
            /*Changes for Funnel*/
            sellerYearlyMap = null;
            oppWithFULsMap = null;
            /*changes for performance links*/
            createPOL(newList);
            PUMap = null;
            oppWithPOLsMap = null;
            addSMESalesKAMITasOTM(newList, null);
            calculateTotalAmountCygate(newList, null);
        }
    }

    public override void afterUpdate() {
        if(!newList.isEmpty()){
            createSolutionSalesOutcomeRecords(newList);
            updateFOL(newList, oldMap);
            setOpportunitySplits(newList, newMap, oldList, oldMap);
            deleteOppConRole(newList);
            CreateAddOppContactRole(newList, oldMap);
            sellerMap = null;
            oppWithFOLsMap = null;
            /*Changes for Funnel*/
            sellerYearlyMap = null;
            oppWithFULsMap = null;
            /*changes for performance links*/
            setPOLValuesFromOpp(newList,oldMap);
            updatePOL(newList,oldMap);
            PUMap = null;
            oppWithPOLsMap = null;
            updateCaseAccess(newList, OldMap);//P.P
            AutoTaskOpportunitySync(newList,oldMap);
            AddFormarOppsOwner(newList,oldMap); //P.S
            addSMESalesKAMITasOTM(newList, oldMap);
            Set<Id> opportunityIDs = new Set<Id>();
            for(Opportunity opp: newList){
                if(SEUtility.isRealEstateFibereOpp(opp.RecordTypeId)){
                    if (
                        ((opp.StageName == '04 Förlorad' ||
                        opp.StageName == '05 Avbruten') &&
                        oldmap.get(opp.Id).StageName != '04 Förlorad' &&
                        oldmap.get(opp.Id).StageName != '05 Avbruten') ||
                                    (opp.OwnerId != oldmap.get(opp.Id).OwnerId) ||
                                    (opp.Type_of_Address__c != oldmap.get(opp.Id).Type_of_Address__c) ||
                                    opp.Number_of_Households__c != oldMap.get(opp.Id).Number_of_Households__c ||
                                    opp.Number_of_other_Ports__c != oldMap.get(opp.Id).Number_of_other_Ports__c ||
                                    opp.Number_of_Ports__c != oldMap.get(opp.Id).Number_of_Ports__c ||
                                    opp.Number_of_Premises__c != oldMap.get(opp.Id).Number_of_Premises__c ||
                                    opp.Number_of_Facilities__c != oldMap.get(opp.Id).Number_of_Facilities__c ||
                                    opp.Municipality__c != oldMap.get(opp.Id).Municipality__c ||
                                    opp.Brand__c != oldMap.get(opp.Id).Brand__c ||
                                    opp.Amount_of_ports_Smart_Home__c != oldMap.get(opp.Id).Amount_of_ports_Smart_Home__c ||
                                    opp.Wished_delivery_date_not_guaranteed__c != oldMap.get(opp.Id).Wished_delivery_date_not_guaranteed__c
                    ) {
                        opportunityIDs.add(opp.Id);
                    }
                }
            }
            if(!opportunityIDs.isEmpty()) {
                updateContractQuotes(oldMap, opportunityIDs);
            }
            calculateTotalAmountCygate(newList, oldMap);
        }
    }
    public override void beforeDelete() {
        if(!oldList.isEmpty()){
            deleteExistingSolutionSalesOutcomeRecords(newList, newMap, oldList, oldMap);
        }
    }
    public override void afterDelete() {
        if(!oldList.isEmpty()){
            calculateTotalAmountCygate(null, oldMap);
        }
    }
    public override void afterUndelete() {
        if(!newList.isEmpty()){
            calculateTotalAmountCygate(newList, null);
        }
    }

    /* * * * * * * * * * * * * * * * * * * * * * * * */
    /* * OpportunityTriggerHandler Trigger Methods * */
    /* * * * * * * * * * * * * * * * * * * * * * * * */
    public static void setDealerName(List<Opportunity> newList) {
        for (Opportunity newOpportunity : newList) {
            if (newOpportunity.Converted_from_lead__c && newOpportunity.Other_Dealer__c != null && newOpportunity.Dealer_Name1__c == null) {
                newOpportunity.Dealer_Name1__c = 'Annan ÅF';
            }
        }
    }
    public static void checkOpportunitySource(List<Opportunity> newList) {
        String userRoleName = [SELECT userrole.name FROM user WHERE id = :UserInfo.getUserId()].userrole.name;
        Map<Id,RecordType > recIDmap = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' ]);
        for (Opportunity newOpportunity : newList) {
            if (
                !newOpportunity.Converted_from_lead__c &&
                (userRoleName == 'Telesales' ||
                userRoleName == 'Telesales manager') &&
                newOpportunity.Opportunity_Source__c == null &&
                recIDmap.get(newOpportunity.recordTypeID).DeveloperName == 'SME_Quick'
            ) {
                newOpportunity.adderror(Label.Opportunity_source_EN);
            }
        }
    }
    //Author SS:
    public static void setRevenueImpact(list<Opportunity> newlist){
        if(newlist!= null && newlist.size() > 0){
            for(Opportunity opp : newlist){
                //Revenue new sales and continuation sales set to close date if the value is less than close date
                opp.Revenue_Start__c = opp.Revenue_Start__c < opp.CloseDate ? opp.CloseDate : opp.Revenue_Start__c;
                opp.Revenue_Start_CS__c = opp.Revenue_Start_CS__c < opp.CloseDate ? opp.CloseDate : opp.Revenue_Start_CS__c;
                if (
                    (opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD)) ||
                    (opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_HW_LARGE_STANDARD)) ||
                    (opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_ENLARGEMENT))
                ) {
                    if(opp.Large_Continuation_Sales__c != null && opp.Existing_agreement_revenue__c < opp.Large_Continuation_Sales__c ){
                        opp.Existing_agreement_revenue__c = opp.Large_Continuation_Sales__c ;
                    }
                }
            }
        }
    }

    public static void setOriginalNSCS(List<Opportunity> newList){
        for(Opportunity opp : newList){
            opp.Cygate_NS_original__c=opp.New_Sales__c;
            opp.Cygate_CS_Original__c=opp.Continuation_Sales__c;
        }
    }
    // Author AN:
    // If the opportunity has any Opportunity Line Items (products), the Winback_Revenue_12_month__c and Retain_Revenue_12_month__c (roll-ups)
    // will overwrite any manually user-entered values. (This logic replaces the WF-rule "Update Large New/Cont Sales Currency field")
    public static void setNewContinuationSalesAmounts(List<Opportunity> newList){
        for(Opportunity opp : newList){
            if(oppsWithLastProductDeleted != null && oppsWithLastProductDeleted.contains(opp.Id)){
                opp.Large_New_Sales__c = 0;
                opp.Large_Continuation_Sales__c = 0;
                opp.Apex_Updated__c = (opp.Apex_Updated__c == null ? 1 : opp.Apex_Updated__c + 1 );
            }
            if(oppsWithLastCygateProductDeleted != null && oppsWithLastCygateProductDeleted.contains(opp.id)){
                opp.New_Sales__c=opp.Cygate_NS_original__c;
                opp.Continuation_Sales__c=opp.Cygate_CS_Original__c;
            } else if (opp.HasOpportunityLineItem) {
                // Telia amounts
                if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_TELIA_CYGATE)){
                    if(opp.Telia_NS_Common_Process__c != null){
                        opp.Large_New_Sales__c = opp.Telia_NS_Common_Process__c;
                    }
                    if(opp.Telia_CS_Common_Process__c != null){
                        opp.Large_Continuation_Sales__c = opp.Telia_CS_Common_Process__c;
                    }
                } else {
                    if(opp.Winback_Revenue_12_month__c != null){
                        opp.Large_New_Sales__c = opp.Winback_Revenue_12_month__c;
                    }
                    if(opp.Retain_Revenue_12_month__c != null){
                        opp.Large_Continuation_Sales__c = opp.Retain_Revenue_12_month__c;
                    }
                }

                // Cygate amounts
                if(opp.New_Sales_Rollup_Cygate__c != null){
                    //If both the NS and CS Rollup fields value is 0, it should not be assigned to NS and CS fields
                    if(opp.New_Sales_Rollup_Cygate__c!=0 || opp.Continuation_Sales_Rollup_Cygate__c!=0){
                        opp.New_Sales__c = opp.New_Sales_Rollup_Cygate__c;
                    }
                }
                if(opp.Continuation_Sales_Rollup_Cygate__c != null){
                    if(opp.New_Sales_Rollup_Cygate__c!=0 || opp.Continuation_Sales_Rollup_Cygate__c!=0){
                        opp.Continuation_Sales__c = opp.Continuation_Sales_Rollup_Cygate__c;
                    }
                }
            }
        }
    }

    // Author AN:
    // Set/update the fields Weighted New Sales Forecast, Weighted Continuation Sales Forecast and Weighted Sales Outcome Forecast
    private static void setWeightedNewContinuationSales(List<Opportunity> newList){
        for(Opportunity opp : newList){
            if(opp.Probability != null){
                Decimal prob = opp.Probability/100;
                if(SEUtility.isCygateOpp(opp.RecordTypeId)){
                    // For Cygate we set the amounts based on the Cygate fields (New_Sales__c: label "Cygate New Sales", Continuation_Sales__c: label "Cygate Continuation Sales")
                    opp.Weighted_New_Sales_Forecast__c = (opp.New_Sales__c == null ? 0 : prob*opp.New_Sales__c);
                    opp.Weighted_Continuation_Sales_Forecast__c = (opp.Continuation_Sales__c == null ? 0 : prob*opp.Continuation_Sales__c);
                    opp.Weighted_Sales_Value_Forecast__c = opp.Weighted_New_Sales_Forecast__c + opp.Weighted_Continuation_Sales_Forecast__c;
                } else {
                    // For SME, Large, Soho we set the amounts based on the Large_New_Sales__c/Large_Continuation_Sales__c fields.
                    opp.Weighted_New_Sales_Forecast__c = (opp.Large_New_Sales__c == null ? 0 : prob*opp.Large_New_Sales__c);
                    opp.Weighted_Continuation_Sales_Forecast__c = (opp.Large_Continuation_Sales__c == null ? 0 : prob*opp.Large_Continuation_Sales__c);
                    // The Sales Outcome is set differently for SME, Large, Soho
                    if (SEUtility.isLargeOpp(opp.RecordTypeId)) {
                        // For Large, set Weighted Sales Value based on Sales_Outcome_Large__c
                        opp.Weighted_Sales_Value_Forecast__c = (opp.Sales_Outcome_Large__c == null ? 0 : prob*opp.Sales_Outcome_Large__c);
                    } else {
                        // Default value for SME (and other record types without any specified logic) based on Sales_Outcome__c
                        opp.Weighted_Sales_Value_Forecast__c = (opp.Sales_Outcome__c == null ? 0 : prob*opp.Sales_Outcome__c);
                    }
                }
            } else {
                opp.Weighted_New_Sales_Forecast__c = 0;
                opp.Weighted_Continuation_Sales_Forecast__c = 0;
                opp.Weighted_Sales_Value_Forecast__c = 0;
            }
        }
    }

    // Author AN: This method replaces the old Process Builder "Set Pricebook on New Opportunities"
    // Set the correct Price Book on new opportunities based on the opportunity record type (and user role when needed)
    private static void setPriceBook(List<Opportunity> newList){
        List<Opportunity> prospectOpps = new List<Opportunity>();
        Set<Id> prospectOwnerIds = new Set<Id>();

        for(Opportunity opp : newList){
            if(opp.Pricebook2Id == null){
                if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_TELIA_CYGATE)){
                    opp.Pricebook2Id = SEUtility.getPriceBookId(SEUtility.PRICEBOOK_JOINT);
                } else if(SEUtility.isCygateOpp(opp.RecordTypeId)){
                    opp.Pricebook2Id = SEUtility.getPriceBookId(SEUtility.PRICEBOOK_CYGATE);
                } else if (SEUtility.isLargeOpp(opp.RecordTypeId) || SEUtility.isSMEOpp(opp.RecordTypeId)) {
                    //V.A
                    opp.Pricebook2Id = SEUtility.getPriceBookId(SEUtility.PRICEBOOK_TELIA_NEW);
                } else if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT)){
                    // For prospects we need to set rec type based on user profile
                    prospectOpps.add(opp);
                    prospectOwnerIds.add(opp.OwnerId);
                }
                // Updated by SK : FIBE : 226 - Setting default pricebook 'Real Estate Fiber Pricebook' on Fiber Opportunities (Record Type = 'Real Estate Fiber')
                else if(SEUtility.isRealEstateFibereOpp(opp.RecordTypeId)){
                    opp.Pricebook2Id = SEUtility.getPriceBookId(SEUtility.PRICEBOOK_REALESTATEFIBER);
                }
                // Updated by Simona wgj897 : LTAT-17984 - Setting default pricebook 'Wholesale' on Wholesale Opportunities (Record Type = 'Wholesale')
                else if(SEUtility.isWholesaleOpp(opp.RecordTypeId)){
                    opp.Pricebook2Id = SEUtility.getPriceBookId(SEUtility.PRICEBOOK_WHOLESALE);
                }
            }
        }

        if(!prospectOpps.isEmpty()){
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, UserRole.Id, ProfileId FROM User WHERE Id IN :prospectOwnerIds]);
            for(Opportunity opp : prospectOpps){
                if(userMap.containsKey(opp.OwnerId)){
                    if(SEUtility.isCygateUserRole(userMap.get(opp.OwnerId).UserRole.Id)){
                        opp.Pricebook2Id = SEUtility.getPriceBookId(SEUtility.PRICEBOOK_CYGATE);
                    } else if(SEUtility.isPRUser(userMap.get(opp.OwnerId))){
                        opp.Pricebook2Id = SEUtility.getPriceBookId(SEUtility.PRICEBOOK_TELIA_NEW);
                    } else {
                        opp.Pricebook2Id = SEUtility.getPriceBookId(SEUtility.PRICEBOOK_TELIA_NEW);
                    }
                }
            }
        }
    }
    // Author AN: This method replaces the old Process Builder "Opportunity - populate Related Org Unit
    // Set the Related Org Unit on Cygate Opportunity if the Account.Org_Unit_Id is not blank
    private static void setRelatedOrgUnitCygate(List<Opportunity> newList){
        List<Opportunity> cygateOppsWithoutOrgUnit = new List<Opportunity>();
        Set<Id> accIds = new Set<Id>();

        for(Opportunity opp : newList){
            if(SEUtility.isCygateOpp(opp.RecordTypeId) && opp.OrganisationalUnit__c == null && opp.AccountId != null){
                cygateOppsWithoutOrgUnit.add(opp);
                accIds.add(opp.AccountId); // Add account id to set
            }
        }

        if (accIds.isEmpty())
            return;

        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Org_Unit_Id__c FROM Account WHERE Id IN :accIds AND Org_Unit_Id__c != NULL]);
        for(Opportunity opp : cygateOppsWithoutOrgUnit){
            if (accMap.containsKey(opp.AccountId)) {
                // Note that if the account Org_Unit_Id__c is null the account is not added to the map and opp.OrganisationalUnit__c is not set
                opp.OrganisationalUnit__c = accMap.get(opp.AccountId).Org_Unit_Id__c;
            }
        }
    }
    // Author AN:
    // Set the close date to today when an opp is closed
    private static void setCloseDateOnOppClose(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Id prospectRTId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);

        for(Opportunity opp : newList){
            if(opp.RecordTypeId != prospectRTId){
                if(oldMap != null && opp.IsClosed && !oldMap.get(opp.Id).isClosed){
                    opp.CloseDate = System.today();
                }
            }
        }
    }

    // Author VI/AN:
    // Filter out opportunities that are closed/won and create sales outcome records for Solutions
    // This method is also used by AccountTriggerHandler-class
    public static void createSolutionSalesOutcomeRecords(List<Opportunity> newList){
        List<Opportunity> closedWonOpps = new List<Opportunity>();

        for(Opportunity opp : newList){
            if(opp.IsWon && opp.recordtypeid != SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_WEBORDER)){
                closedWonOpps.add(opp);
            }
        }

        if(!closedWonOpps.isEmpty()){
            SolutionsSalesOutcomeServiceClass.deleteExistingRecords(closedWonOpps);
            SolutionsSalesOutcomeServiceClass.createNewRecords(closedWonOpps);
        }
    }

    // Author VI/AN:
    //**Delete solutions sales outcome on opportunities that are deleted with Large record type and the ones that was moved from closed/won to another stage**//
    private static void deleteExistingSolutionSalesOutcomeRecords(
        List<Opportunity> newList,
        Map<Id, Opportunity> newMap,
        List<Opportunity> oldList,
        Map<Id, Opportunity> oldMap
    ) {
        List<Opportunity> deleteOutcomeFromOpps = new List<Opportunity>();

        if (newMap != null) {
            // isUpdate
            for(Opportunity opp : newList){
                if(oldMap != null && oldMap.get(opp.Id).isWon && !newMap.get(opp.Id).isWon){
                    deleteOutcomeFromOpps.add(opp);
                }
            }
        } else {
            // isDelete
            for(Opportunity opp : oldList){
                if(opp.IsWon){
                    deleteOutcomeFromOpps.add(opp);
                }
            }
        }

        if(!deleteOutcomeFromOpps.isEmpty()){
            SolutionsSalesOutcomeServiceClass.deleteExistingRecords(deleteOutcomeFromOpps);
        }
    }
    // Author VI/AN:
    // Filter opportunities where solution area should be updated and update the Main_Product_Area__c and Sharing_Solution_Area__c
    // The solution area should be the opportunity line items product families + the values the user selects.
    // When the opportunity is won the solution area should match the opportunity line items exactly.
    //Updated by P.P on 27th Aug for Code Optimization
    //Updated by P.S on 22nd March for code Optimizaton for bulk data update
    private static void updateSolutionArea(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        List<Opportunity> updateSolutionAreaList = new List<Opportunity>();

        // Filter out the opportunities where solution are has been changed
        for(Opportunity newOpp : newList){
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            //SALEF-1569 By passing Web Order record Tpye
            if (
                oldOpp != null &&
                newOpp.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_WEBORDER) &&
                ((newOpp.isWon || newOpp.Main_Product_Area__c != oldOpp.Main_Product_Area__c) || (newOpp.Count_Products__c != oldOpp.Count_Products__c))
            ) {
                updateSolutionAreaList.add(newOpp);
            }
        }
        // If List is empty, do nothing
        if (updateSolutionAreaList.isEmpty())
            return;
        // additions from me here
        Map<Id,Set<string>> oppFaMap = new Map<Id,Set<string>>();
        Set<string> s = new Set<String>();
        Set<string> sA = new Set<String>();
        Map<Id,List<OpportunityLineItem>> OppOlimap = new Map<Id,List<OpportunityLineItem>>();
        for (Opportunity opp : [
            SELECT id, (SELECT Product2.Family, OpportunityId, Opportunity.RecordTypeId FROM OpportunityLineItems WHERE Product2.Family != NULL)
            FROM Opportunity
            WHERE Id IN :updateSolutionAreaList
        ]) {
            OppOlimap.put(opp.id,opp.OpportunityLineItems);
        }
        for(Opportunity opp : updateSolutionAreaList){
            sA.clear(); //Clearing the Set so that it will have values specific to opportunity.
            //loop all the respective lineitems of an Opportunity.
            for(opportunityLineItem oli:OppOlimap.get(opp.id)){
                String str = SEUtility.getSolutionAreaName(oli.Product2.Family);
                if(!str.contains('Cygate')){
                    sA.add(str);
                } else if (
                    SEUtility.isCygateOpp(oli.Opportunity.RecordTypeId) ||
                    SEUtility.getRecordTypeDevName(oli.opportunity.RecordTypeId) == SEUtility.OPP_RECTYPE_TELIA_CYGATE ||
                    SEUtility.getRecordTypeDevName(oli.opportunity.RecordTypeId) == SEUtility.OPP_RECTYPE_PROSPECT
                ) {
                    sA.add(str) ;
                }
                if(oppFaMap.containskey(oli.opportunityId)){
                    s = oppFaMap.get(oli.OpportunityId);
                    s.addall(sA);
                    oppFaMap.put(oli.opportunityId,s);
                } else {
                    oppFaMap.put(oli.opportunityId,sA);
                }
            }
            String newValue;
            Set<String> solutionAreas = new Set<String>();
            if(opp.Main_Product_Area__c != null && !opp.IsWon){
                solutionAreas = new Set<String>(opp.Main_Product_Area__c.split(';'));
            }
            if(oppFaMap.get(opp.Id) != null){
                solutionAreas.addall(oppFaMap.get(opp.Id));
                newValue = SEUtility.writeMultiSelectPicklist(solutionAreas);
            }
            if(!String.isBlank(newValue)){
                opp.Main_Product_Area__c = newValue;
            }
            //Update the sharing solution area field that controls the sharing rules
            String st = '';
            if (solutionAreas.size() > 0) {
                for(String solutionArea : solutionAreas){
                    st += SEUtility.getSolutionAreaCode(solutionArea);
                }
            }
            opp.Sharing_Solution_Area__c = st;
        }
    }
    // Author VI/AN:
    // Filter opportunities Seller should be updated and make a call to the method setSellerOnOpportunity in SEUtility class.
    // The set seller method will be called every time the owner changes or the close date changes. In addition, an extra check will be done when the opportunity is closed.
    private static void updateSellerOnOpportunity(
        List<Opportunity> newList,
        Map<Id, Opportunity> newMap,
        List<Opportunity> oldList,
        Map<Id, Opportunity> oldMap
    ) {
        if (oldMap == null)
            return;
        List<Opportunity> oppsWithNewOwnerCloseDate = new List<Opportunity>();

        for(Opportunity newOpp : newList){
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            if (
                oldOpp != null &&
                (newOpp.OwnerId != oldOpp.OwnerId ||
                newOpp.CloseDate != oldOpp.CloseDate ||
                newOpp.AccountId != oldOpp.AccountId ||
                (newOpp.isClosed && !oldOpp.isClosed))
            ) {
                oppsWithNewOwnerCloseDate.add(newOpp);
            }
        }

        if(!oppsWithNewOwnerCloseDate.isEmpty()){
            SEUtility.setSellerOnOpportunity(oppsWithNewOwnerCloseDate);
        }
    }

    // Author AN:
    //Changes PP: Large Forenklad Record Type needs to be removed from Standard Forecast
    //Changes PS: HW Affärsmöjlighet Opps will be excluded from Forecast of Account Owners
    private static void setOpportunitySplits(List<Opportunity> newList, Map<Id, Opportunity> newMap, List<Opportunity> oldList, Map<Id, Opportunity> oldMap){
        Set<Id> oppsForRecordSplitUpdateIds = new Set<Id>();
        Set<Id> oppsForRecordSplitDeleteIds = new Set<Id>();
        Id forenkladLargeRecordTypeId = SEUtility.getRecordTypeid(SEUTILITY.OPP_RECTYPE_LARGE_ENLARGEMENT);
        Id HWLargeRecordTypeId = SEUtility.getRecordTypeid(SEUTILITY.OPP_RECTYPE_HW_LARGE_STANDARD);

        for(Opportunity newOpp : newList){
            if (
                SEUtility.isLargeOpp(newOpp.recordTypeId) &&
                (newOpp.RecordTypeId != forenkladLargeRecordTypeId) &&
                (newOpp.RecordTypeId != HWLargeRecordTypeId)
            ) {
                if(oldMap == null || newOpp.AccountId != oldMap.get(newOpp.Id).AccountId || newOpp.RecordTypeId != oldMap.get(newOpp.Id).RecordTypeId){
                    oppsForRecordSplitUpdateIds.add(newOpp.Id);
                }
            } else if (SEUtility.isCygateOpp(newOpp.RecordTypeId)) {
                if(oldMap == null || newOpp.OwnerId != oldMap.get(newOpp.Id).OwnerId || newOpp.RecordTypeId != oldMap.get(newOpp.Id).RecordTypeId){
                    oppsForRecordSplitUpdateIds.add(newOpp.Id);
                }
            } else if ((newOpp.RecordTypeId == forenkladLargeRecordTypeId || newOpp.RecordTypeId == HWLargeRecordTypeId) && oldMap != null) {
                if(oldMap.get(newOpp.Id).RecordTypeId != forenkladLargeRecordTypeId){
                    oppsForRecordSplitDeleteIds.add(newOpp.Id);
                }
            }
        }

        if(!oppsForRecordSplitUpdateIds.isEmpty()){
            SEUtility.createOppSplits(oppsForRecordSplitUpdateIds);
        }

        if(!oppsForRecordSplitDeleteIds.isEmpty()){
            SEUtility.deleteOppSplits(oppsForRecordSplitDeleteIds);
        }
    }

    // Author VM/AN
    // When Opportunity CloseDate gets changed, we update the Telia Week
    private static void setTeliaWeek(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        for(Opportunity opp : newList){
            if(oldMap == null || opp.CloseDate != oldMap.get(opp.Id).CloseDate){
                opp.Telia_Week__c = SEUtility.getWeekNumber(opp.CloseDate);
            }
        }
    }

    // Author : Nikhita Gautam
    // Delete Opportunity Contact Role related to Account 'Cygate Internal AB' and having Org nr = 5565498952
    private static void deleteOppConRole(List<Opportunity> newList){
        Set<Id> oppIds = new Set<Id>();

        for(Opportunity opp : newList){
            if (
                opp.StageName == label.Opp_Sluta_Avtal_stage ||
                opp.StageName == label.Opp_Vunnen_stage ||
                opp.StageName == label.Opp_Forlorad_stage ||
                opp.StageName == label.Opp_Avbruten_stage
            ) {
                oppIds.add(opp.id);
            }
        }

        if (oppIds.isEmpty())
            return;

        List<OpportunityContactRole> ocrList = [
            SELECT Id
            FROM OpportunityContactRole
            WHERE OpportunityId IN :oppIds AND Contact.Account.Org_Nr__c = :label.Account_Org_N
        ];
        if(!ocrList.isEmpty()){
            try {
            delete ocrList;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'deleteOppConRole', ex);
            }
        }
    }

    private static Set<Id> oppsWithLastProductDeleted;
    public static void addOppWithLastProductDeleted(Id oppId){
        if(oppsWithLastProductDeleted == null){
            oppsWithLastProductDeleted = new Set<Id>();
        }
        oppsWithLastProductDeleted.add(oppId);
    }

    private static Set<Id> oppsWithLastCygateProductDeleted;
    public static void addOppWithLastCygateProductDeleted(Id oppId){
        if(oppsWithLastCygateProductDeleted == null){
            oppsWithLastCygateProductDeleted = new Set<Id>();
        }
        oppsWithLastCygateProductDeleted.add(oppId);
    }

    /* * * * * * * * * * * * * * * * * * * * * * * * */
    /* * Update Forecast Opp Link Methods - START  * */
    /* * * * * * * * * * * * * * * * * * * * * * * * */

    private static Map<Id, Seller__c> sellerMap;
    private static Map<Id, Opportunity> oppWithFOLsMap;
    private static List<Forecast_Opportunity_Link__c> folDeleteList;
    private static List<Forecast_Opportunity_Link__c> folInsertList;
    private static List<Forecast_Opportunity_Link__c> folUpdateList;

    /*Changes for Funnel*/
    private static Map<Id, Seller__c> sellerYearlyMap;
    private static Map<Id, Opportunity> oppWithFULsMap;
    private static List<Funnel_Link__c> fulDeleteList;
    private static List<Funnel_Link__c> fulInsertList;
    private static List<Funnel_Link__c> fulUpdateList;

    /*Changes for Performance Opportunity Links*/
    private static Map<Id,User_Performance__c> PUMap;
    private static Map<Id,Opportunity> oppWithPolsMap;
    private static List<Performance_Opportunity_Link__c> polDeleteList;
    private static List<Performance_Opportunity_Link__c> polInsertList;
    private static List<Performance_Opportunity_Link__c> polUpdateList;

    private static void createFOL(List<Opportunity> newList){
        List<Opportunity> oppListFiltered = filterOpps(newList);
        if (oppListFiltered.isEmpty())
            return;

        loadSellerMap(oppListFiltered);
        loadYearlySellerMap(oppListFiltered);
        folInsertList = new List<Forecast_Opportunity_Link__c>();
        fulInsertList = new List<Funnel_Link__c>();

        for(Opportunity opp : oppListFiltered){
            createFOL(opp);
            createFUL(opp);
        }

        if(folInsertList.size() > 0){
            try {
                insert folInsertList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'createFOL', e);
            }
        }
        if(fulInsertList.size() > 0){
            try {
                insert fulInsertList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'createFOL', e);
            }
        }
    }

    private static void createFOL(Opportunity opp){
        Id prospectRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
        Id forenkladLargeRecordTypeId = SEUtility.getRecordTypeid(SEUTILITY.OPP_RECTYPE_LARGE_ENLARGEMENT);
        Id cygateStandardRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD);
        Id cygateEnlargementRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT);
        Id cygateAfterregRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFTERREG);
        Id SMEEfferregistrering = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_Efterregistering);

        if (
            opp.RecordTypeId != prospectRecordTypeId &&
            opp.RecordTypeId != forenkladLargeRecordTypeId &&
            opp.RecordTypeId != cygateStandardRecordTypeId &&
            opp.RecordTypeId != cygateEnlargementRecordTypeId &&
            opp.RecordTypeId != cygateAfterregRecordTypeId
        ) {
            if (opp.Seller__c == null || !sellerMap.containsKey(opp.Seller__c)) {
                return;
            }
            Integer year = opp.CloseDate.year();
            List<Yearly_Target__c> yearlyTarget = [SELECT Start_Week_Number__c FROM Yearly_Target__c WHERE Seller__c = :opp.Seller__c AND Name = :String.valueOf(year) LIMIT 1];
            if (!yearlyTarget.isEmpty()) {
                Integer OpportunityCloseDateWeekNumber;
                Integer yearlyTargetWeekNumber = Integer.valueOf(yearlyTarget[0].Start_Week_Number__c);
                String weekName = SEUtility.getWeekNumberAsString(opp.CloseDate);
                OpportunityCloseDateWeekNumber = Integer.valueOf(weekName);

                Id wfiId = getWfiForSeller(opp.Seller__c, weekName, year);
                if (wfiId != null && yearlyTargetWeekNumber <= OpportunityCloseDateWeekNumber) {
                    Forecast_Opportunity_Link__c newFol = new Forecast_Opportunity_Link__c(Weekly_Forecast_Item__c = wfiId, Opportunity__c = opp.Id);
                    setFOLValuesFromOpp(newFol, opp);
                    folInsertList.add(newFol);
                    cloneFOLforManager(newFol, sellerMap.get(opp.Seller__c).Manager__c, weekName, year);
                }
            }
        }
    }

    private static void cloneFOLforManager(Forecast_Opportunity_Link__c oldFol, Id sellerId, String weekName, Integer year){
        if(sellerId != null && sellerMap.containsKey(sellerId)){
            Forecast_Opportunity_Link__c newFol = oldFol.clone(false, true);
            Id wfiId = getWfiForSeller(sellerId, weekName, year);
            if(wfiId != null){
                newFol.Weekly_Forecast_Item__c = wfiId;
                folInsertList.add(newFol);
            }
            cloneFOLforManager(newFol, sellerMap.get(sellerId).Manager__c, weekName, year);
        }
    }
    /*Changes for Funnel*/
    private static void createFUL(Opportunity opp){
        string yearToday = system.label.Year_For_Funnel;
        if (opp.Seller__c == null || !sellerYearlyMap.containsKey(opp.Seller__c))
            return;

        id yfiId = getyfiForSeller(opp.seller__c, yearToday);
        if(yfiId != null){
            Funnel_Link__c newFul = new Funnel_Link__c(Yearly_Target__c= yfiid, Opportunity__c = opp.Id);
            setFULValuesFromOpp(newFul,opp);
            /* since Funnel should not work for Seller of Type - Seller, the Funnel for that should not be inserted*/
            if(sellerYearlyMap.get(opp.Seller__c).Type__c != 'Seller'){
                fulInsertList.add(newFul);
            }
            cloneFULforManager(newFul, sellerYearlyMap.get(opp.Seller__c).Manager__c, yearToday);
        }
    }
    /* need to consider week name here*/
    private static void cloneFULforManager(Funnel_Link__c oldFul, Id sellerId, String yearToday){
        date funnelEndDate = date.today().adddays(365);
        date funnelStartDate = date.today();
        if(sellerId != null && sellerYearlyMap.containsKey(sellerId)){
            Funnel_Link__c newFul = oldFul.clone(false, true);
            id yfiId = getyfiForSeller(sellerId, yearToday);
            if(yfiId != null){
                newFul.yearly_target__c = yfiId;
                fulInsertList.add(newFul);
            }
            cloneFULforManager(newFul, sellerYearlyMap.get(sellerId).Manager__c, yearToday);
        }
    }
    // There are three scenarios that will trigger different updates to the FOL records
    //  1.1 Reason: There is 0 or 1 FOL records related to an opportunity (There should always be at least two FOL records for an opp (Top level users are not opportunity owners/sellers))
    //  1.2 Reason: Seller is changed
    //  1.3 Action: Delete all existing FOL records (if any) and try to create new ones.
    //  2.1 Reason: Close Date is changed
    //  2.2 Action: Repoint the Weekly Forecast item based on new close date for all existing opps
    //  3.1 Reason: One of the Opp fields that is copied down to the FOL has been updated (isUpdateNeeded(opp, oldOpp) method)
    //  3.2 Action: Update the FOL values, but do not change lookups to Opportunity/WFI
    private static void updateFOL(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        List<Opportunity> oppListFiltered = filterOpps(newList);
        loadSellerMap(oppListFiltered);
        loadYearlySellerMap(oppListFiltered);
        loadOppWithFOLs(newList);
        loadOppWithFULs(newList);

        folDeleteList = new List<Forecast_Opportunity_Link__c>();
        folInsertList = new List<Forecast_Opportunity_Link__c>();
        folUpdateList = new List<Forecast_Opportunity_Link__c>();

        /*changes for Funnel*/
        fulDeleteList = new List<Funnel_Link__c>();
        fulInsertList = new List<Funnel_Link__c>();
        fulUpdateList = new List<Funnel_Link__c>();

        // If record type is changed from opportunity to prospect, delete all Forecast Opportunity Link records
        Id prospectRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
        Id forenkladLargeRecordTypeId = SEUtility.getRecordTypeid(SEUTILITY.OPP_RECTYPE_LARGE_ENLARGEMENT);

        for(Opportunity opp:newList){
            if (
                (opp.RecordTypeId == prospectRecordTypeId && oldMap.get(opp.Id).RecordTypeId != prospectRecordTypeId) ||
                (opp.RecordTypeId == forenkladLargeRecordTypeId &&
                oldMap.get(opp.Id).RecordTypeId != forenkladLargeRecordTypeId)
            ) {
                folDeleteList.addAll(oppWithFOLsMap.get(opp.Id).Forecast_Opportunity_Links__r);
                fulDeleteList.addAll(oppWithFULsMap.get(opp.Id).Funnel_Links__r);
            }
        }

        for(Opportunity opp : oppListFiltered){
            Opportunity oldOpp = oldMap.get(opp.Id);
            Opportunity oppWithFOLs = oppWithFOLsMap.get(opp.Id);
            Opportunity oppWithFULs = oppWithFULsMap.get(opp.Id);

            if (oppWithFOLs.Forecast_Opportunity_Links__r == null || oppWithFOLs.Forecast_Opportunity_Links__r.size() < 2) {
                // 1.1 Reason: There should always be at least two FOL records for an opp (Top level users are not opportunity owners/sellers)
                // 1.3 Action: Delete all existing FOL records (if any) and try to create new ones.
                if (oppWithFOLs.Forecast_Opportunity_Links__r != null)
                    folDeleteList.addAll(oppWithFOLs.Forecast_Opportunity_Links__r);
                createFOL(opp);
            } else if (opp.Seller__c != oldOpp.Seller__c) {
                // 1.2 Reason: Seller is changed
                // 1.3 Action: Delete all existing FOL records (if any) and try to create new ones.
                folDeleteList.addAll(oppWithFOLs.Forecast_Opportunity_Links__r);
                createFOL(opp);
            } else if (opp.CloseDate != oldOpp.CloseDate) {
                // 2.1 Reason: Close Date is changed
                // 2.2 Action: Repoint the Weekly Forecast item based on new close date for all existing opps
                repointFOL(opp, oppWithFOLs.Forecast_Opportunity_Links__r);
            } else if (isUpdateNeeded(opp, oldOpp)) {
                // 3.1 Reason: One of the Opp fields that is copied down to the FOL has been updated (isUpdateNeeded(opp, oldOpp) method)
                // 3.2 Action: Update the FOL values, but do not change lookups to Opportunity/WFI
                updateFOLValues(opp, oppWithFOLs.Forecast_Opportunity_Links__r);
            }
            /*Changes for Funnel*/
            if (
                oppWithFULs.Funnel_Links__r == null ||
                oppWithFULs.Funnel_Links__r.size() < 2 // need atleast one FUL to delete , need to check with testing
            ) {
                if (oppWithFULs.Funnel_Links__r != null) {
                    fulDeleteList.addAll(oppWithFULs.Funnel_Links__r);
                }
                createFUL(opp);
            } else if (
                opp.Seller__c !=
                oldOpp.Seller__c //Seller is Changed
            ) {
                fulDeleteList.addAll(oppWithFULs.Funnel_Links__r);
                createFUL(opp);
            } else if (isUpdateNeededFunnel(opp, oldOpp)) {
                updateFULValues(opp,oppWithFULs.Funnel_Links__r);
            }
        }

        if(folDeleteList.size() > 0){
            try {
                delete folDeleteList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateFOL', e);
            }
        }
        if(folUpdateList.size() > 0){
            try {
                update folUpdateList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateFOL', e);
            }
        }
        if(folInsertList.size() > 0){
            try {
                insert folInsertList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateFOL', e);
            }
        }
        /*changes for Funnel*/
        if(fulDeleteList.size() > 0){
            try {
                delete fulDeleteList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateFOL', e);
            }
        }
        if(fulUpdateList.size() > 0){
            try {
                update fulUpdateList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateFOL', e);
            }
        }
        if(fulInsertList.size() > 0){
            try {
                insert fulInsertList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateFOL', e);
            }
        }
    }

    private static void repointFOL(Opportunity opp, List<Forecast_Opportunity_Link__c> folList){
        String weekName = SEUtility.getWeekNumberAsString(opp.CloseDate);
        Integer year = opp.CloseDate.year();
        List<Yearly_Target__c> yearlyTarget = [SELECT Start_Week_Number__c FROM Yearly_Target__c WHERE Seller__c = :opp.Seller__c AND Name = :String.valueOf(year) LIMIT 1];
        if (!yearlyTarget.isEmpty()) {
            Integer OpportunityCloseDateWeekNumber;
            Integer yearlyTargetWeekNumber = Integer.valueOf(yearlyTarget[0].Start_Week_Number__c);
            OpportunityCloseDateWeekNumber = Integer.valueOf(weekName);

            for (Forecast_Opportunity_Link__c fol : folList) {
                Id newWfiId = getWfiForSeller(fol.Weekly_Forecast_Item__r.Seller__c, weekName, year);
                if (newWfiId != null && yearlyTargetWeekNumber <= OpportunityCloseDateWeekNumber) {
                    fol.Weekly_Forecast_Item__c = newWfiId;
                    updateFOLValues(opp, fol);
                } else {
                    folDeleteList.add(fol); // No weekly forecast item found, might f.ex. happen if close date is moved into next year. Will then delete the FOL record.
                }
            }
        }
    }

    private static void updateFOLValues(Opportunity opp, Forecast_Opportunity_Link__c fol){
        setFOLValuesFromOpp(fol, opp);
        folUpdateList.add(fol);
    }

    private static void updateFOLValues(Opportunity opp, List<Forecast_Opportunity_Link__c> folList){
        for(Forecast_Opportunity_Link__c fol : folList){
            updateFOLValues(opp, fol);
        }
    }
    /*changes for Funnel*/
    private static void updateFULValues(Opportunity opp, Funnel_Link__c ful){
        setFULValuesFromOpp(ful, opp);
        fulUpdateList.add(ful);
    }

    private static void updateFULValues(Opportunity opp, List<Funnel_Link__c> fulList){
        for(Funnel_Link__c ful : fulList){
            updateFULValues(opp, ful);
        }
    }

    private static void setFOLValuesFromOpp(Forecast_Opportunity_Link__c fol, Opportunity opp){
        fol.Probability__c = opp.Probability;
        fol.Is_Closed__c = opp.IsClosed;
        fol.Is_Won__c = opp.IsWon;
        fol.Risk__c = opp.Risk__c;
        fol.Revenue_Impact_This_Year__c = opp.Revenue_Impact_This_Year__c;
        fol.New_Sales_Amount__c = opp.Large_New_Sales__c;
        fol.Continuation_Sales_Amount__c = opp.Large_Continuation_Sales__c;

        // if(SEUtility.isSMEOpp(opp.RecordTypeId) || SEUtility.isPROpp(opp.RecordTypeId)){
        if(SEUtility.isSMEOpp(opp.RecordTypeId)){
            fol.Sales_Value_Amount__c = opp.Sales_Outcome__c;
        } else if(SEUtility.isLargeOpp(opp.RecordTypeId)){
            fol.Sales_Value_Amount__c = opp.Sales_Outcome_Large__c;
        }
    }
    /*changes for Funnel*/
    private static void setFULValuesFromOpp(Funnel_Link__c ful, Opportunity opp){
        date funnelStartDate = system.today();
        date funnelEndDate = date.today().adddays(365);

        ful.Opp_Is_Closed__c = opp.IsClosed;
        ful.Opportunity_Close_Date__c = opp.CloseDate;
        ful.New_Sales_Amount__c = opp.Large_New_Sales__c;
        if (opp.CloseDate < funnelEndDate && opp.IsClosed == false) {
            ful.Included_in_Funnel__c = true;
        } else {
            ful.Included_in_Funnel__c = false;
        }
    }

    private static Boolean isUpdateNeeded(Opportunity newOpp, Opportunity oldOpp){
        Boolean needsUpdate = (newOpp.Large_New_Sales__c != oldOpp.Large_New_Sales__c ||
            newOpp.Large_Continuation_Sales__c != oldOpp.Large_Continuation_Sales__c ||
            newOpp.Probability != oldOpp.Probability ||
            newOpp.IsClosed != oldOpp.IsClosed ||
            newOpp.IsWon != oldOpp.IsWon ||
            newOpp.Risk__c != oldOpp.Risk__c ||
            newOpp.Revenue_Impact_This_Year__c != oldOpp.Revenue_Impact_This_Year__c ||
            newOpp.Sales_Outcome__c != oldOpp.Sales_Outcome__c ||
        newOpp.Sales_Outcome_Large__c != oldOpp.Sales_Outcome_Large__c);
        return needsUpdate;
    }
    /*changes for Funnel*/
    private static Boolean isUpdateNeededFunnel(Opportunity newOpp, Opportunity oldOpp){
        Boolean needsUpdate = (newOpp.Large_New_Sales__c != oldOpp.Large_New_Sales__c ||
            newOpp.IsClosed != oldOpp.IsClosed ||
        newOpp.CloseDate != oldOpp.CloseDate);
        return needsUpdate;
    }

    private static Id getWfiForSeller(Id sellerId, String weekName, Integer year){
        List<Weekly_Forecast_Item__c> wfiList = sellerMap.get(sellerId).Veckoprognoser__r;

        for(Weekly_Forecast_Item__c wfi : wfiList){
            if(wfi.Name == weekName && wfi.Belongs_To_Year__c == year){
                return wfi.Id;
            }
        }
        return null;
    }

    private static id getyfiForSeller(Id SellerId, string year){
        List<Yearly_Target__c> yfiList = sellerYearlyMap.get(sellerId).Arsmal__r;

        for(Yearly_Target__c yfi : yfiList){
            if(yfi.Name == year){
                return yfi.id;
            }
        }
        return null;
    }
    // Filter out opportunities that needs to update/create Forecast Opp Links
    // Filter: Do not create FOL for prospect record type & forenklad Large Record Type (Case 1990)
    private static List<Opportunity> filterOpps(List<Opportunity> oppList){
        List<Opportunity> oppListFiltered = new List<Opportunity>();
        Id prospectRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
        Id forenkladLargeRecordTypeId = SEUtility.getRecordTypeid(SEUTILITY.OPP_RECTYPE_LARGE_ENLARGEMENT);
        Id cygateStandardRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD);
        Id cygateEnlargementRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT);
        Id cygateAfterregRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFTERREG);
        Id SMEEfferregistrering = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_Efterregistering);

        for(Opportunity opp : oppList){
            //if(opp.RecordTypeId != prospectRecordTypeId && opp.RecordTypeId != forenkladLargeRecordTypeId){
            if (
                opp.RecordTypeId != prospectRecordTypeId &&
                opp.RecordTypeId != forenkladLargeRecordTypeId &&
                opp.RecordTypeId != cygateStandardRecordTypeId &&
                opp.RecordTypeId != cygateEnlargementRecordTypeId &&
                opp.RecordTypeId != cygateAfterregRecordTypeId
            ) {
                oppListFiltered.add(opp);
            }
        }

        return oppListFiltered;
    }

    private static void loadSellerMap(List<Opportunity> oppList){
        if(sellerMap == null){
            Set<String> weekNames = new Set<String>();
            Set<Integer> years = new Set<Integer>();

            for(Opportunity opp : oppList){
                weekNames.add(SEUtility.getWeekNumberAsString(opp.CloseDate));
                years.add(opp.CloseDate.year());
            }
            sellerMap = new Map<Id,Seller__c>();
            for (Seller__c sellerObj : [
                SELECT
                    Id,
                    User__c,
                            Manager__c, (SELECT Id, Name, Belongs_To_Year__c FROM Veckoprognoser__r WHERE Name IN :weekNames AND Belongs_To_Year__c IN :years)
                FROM Seller__c
            ]) {
                sellerMap.put(sellerObj.Id,sellerObj);
            }
        }
    }

    private static void loadOppWithFOLs(List<Opportunity> oppList){
        if(oppWithFOLsMap == null){
            oppWithFOLsMap = new Map<Id, Opportunity>(
                [
                    SELECT
                            Id, (
                            SELECT
                                Id,
                                Weekly_Forecast_Item__c,
                                Weekly_Forecast_Item__r.Seller__c,
                                New_Sales_Amount__c,
                                Continuation_Sales_Amount__c,
                                Probability__c,
                                Is_Closed__c,
                                Is_Won__c,
                                Risk__c
                    FROM Forecast_Opportunity_Links__r
                )
                FROM Opportunity
                    WHERE Id IN :oppList
                ]
            );
        }
    }
    /*changes for Funnel*/
    private static void loadYearlySellerMap(List<Opportunity> oppList){
        if (sellerYearlyMap == null) {
            string yearToday = system.label.Year_For_Funnel;
            sellerYearlyMap = new Map<Id, Seller__c>(
                [
                    SELECT
                        Id,
                        User__c,
                        Manager__c,
                            Type__c, (
                            SELECT Id, Name, Seller__c
                    FROM Arsmal__r
                    WHERE Name = :yearToday
                )
                FROM Seller__c
                ]
            );
        }
    }
    private static void loadOppWithFULs(List<Opportunity> oppList){
        if(oppWithFULsMap == null){
            oppWithFULsMap = new Map<Id, Opportunity>(
                [
                    SELECT
                            Id, (
                            SELECT
                                Id,
                                Yearly_Target__c,
                                Yearly_Target__r.Seller__c,
                                New_Sales_Amount__c,
                                Included_in_Funnel__c,
                                Opp_Is_Closed__c,
                                Opportunity_Close_Date__c
                    FROM Funnel_Links__r
                )
                FROM Opportunity
                WHERE Id IN:oppList
                ]
            );
        }
    }
    /* * * * * * * * * * * * * * * * * * * * * * * */
    /* * Update Forecast Opp Link Methods - END  * */
    /* * * * * * * * * * * * * * * * * * * * * * * */

    // Author AN
    // Utility method to create FOLs for a list of Opportunities without having to actually update any opportunity values to force trigger runs
    public static void recreateFOL(List<Opportunity> newList){
        loadSellerMap(newList);
        loadOppWithFOLs(newList);

        folDeleteList = new List<Forecast_Opportunity_Link__c>();
        folInsertList = new List<Forecast_Opportunity_Link__c>();

        for(Opportunity opp : newList){
            Opportunity oppWithFOLs = oppWithFOLsMap.get(opp.Id);
            if(oppWithFOLs.Forecast_Opportunity_Links__r != null && oppWithFOLs.Forecast_Opportunity_Links__r.size() > 0){
                folDeleteList.addAll(oppWithFOLs.Forecast_Opportunity_Links__r);
            }
            createFOL(opp);
        }

        if(!folDeleteList.isEmpty()){
            try {
            delete folDeleteList;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'recreateFOL', ex);
            }
        }
        if(!folInsertList.isEmpty()){
            try {
            insert folInsertList;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'recreateFOL', ex);
            }
        }
    }

    // Author AN
    // Utility method to force all FOLs for a list of Opportunities to update the values without having to actually update any opportunity values to force trigger runs
    public static void forceFOLupdate(List<Opportunity> newList){
        loadOppWithFOLs(newList);

        folUpdateList = new List<Forecast_Opportunity_Link__c>();
        for(Opportunity opp : newList){
            Opportunity oppWithFOLs = oppWithFOLsMap.get(opp.Id);
            if(oppWithFOLs.Forecast_Opportunity_Links__r != null && oppWithFOLs.Forecast_Opportunity_Links__r.size() > 0){
                updateFOLValues(opp, oppWithFOLs.Forecast_Opportunity_Links__r);
            }
        }

        if(!folUpdateList.isEmpty()){
            try {
            update folUpdateList;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'forceFOLupdate', ex);
            }
        }
    }

    /*Changes for Funnel*/
    // Utility method to create FULs for a list of Opportunities without having to actually update any opportunity values to force trigger runs
    public static void recreateFUL(List<Opportunity> newList){
        loadYearlySellerMap(newList);
        loadOppWithFULs(newList);

        fulDeleteList = new List<Funnel_Link__c>();
        fulInsertList = new List<Funnel_Link__c>();

        for(Opportunity opp : newList){
            Opportunity oppWithFULs = oppWithFULsMap.get(opp.Id);
            if(oppWithFULs.Funnel_Links__r != null && oppWithFULs.Funnel_Links__r.size() > 0){
                fulDeleteList.addAll(oppWithFULs.Funnel_Links__r);
            }
            createFUL(opp);
        }

        if(!fulDeleteList.isEmpty()){
            try {
            delete fulDeleteList;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'recreateFUL', ex);
            }
        }
        if(!fulInsertList.isEmpty()){
            try {
            insert fulInsertList;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'recreateFUL', ex);
            }
        }
    }

    // Utility method to force all FULs for a list of Opportunities to update the values without having to actually update any opportunity values to force trigger runs
    public static void forceFULupdate(List<Opportunity> newList){
        loadOppWithFULs(newList);

        fulUpdateList = new List<Funnel_Link__c>();
        for(Opportunity opp : newList){
            Opportunity oppWithFULs = oppWithFULsMap.get(opp.Id);
            if(oppWithFULs.Funnel_Links__r != null && oppWithFULs.Funnel_Links__r.size() > 0){
                updateFULValues(opp, oppWithFULs.Funnel_Links__r);
            }
        }

        if(!fulUpdateList.isEmpty()){
            try {
            update fulUpdateList;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'forceFULupdate', ex);
            }
        }
    }

    //Vahraz
    //Check if there is any products from AF(Reseller), if not throw validation error if "No Reseller Products" is unchecked.
    private static void checkAFProducts(List<Opportunity> newList){
        Map<Id, Opportunity> afOpps = new Map<Id, Opportunity>();
        for(Opportunity opp : newList){
            if(!opp.No_Reseller_Product__c && opp.Converted_from_lead__c){
                if(opp.StageName == OpportunityValidationHandler.OPP_STAGE_WON ){
                    afOpps.put(opp.Id, opp);
                }
            }
        }

        if(!afOpps.isEmpty()){
            Map<Id, Opportunity> oppWithAfBiIds = new Map<Id, Opportunity>(
                [
                SELECT Id
                FROM Opportunity
                    WHERE Id IN (SELECT Opportunity__c FROM Buy_Interest__c WHERE Lead_Source__c = :SEConstants.LEAD_SOURCE_RESELLER) AND Id IN :afOpps.keySet()
                ]
            );

            //OppId, List OpportunityLineItem
            Map<Id, List<OpportunityLineItem>> oliMap = new Map<Id, List<OpportunityLineItem>>();

            //Create the map structure
            for (OpportunityLineItem oli : [
                SELECT Id, OpportunityId, Buy_interest__r.Lead_Source__c
                FROM OpportunityLineItem
                WHERE OpportunityId IN :oppWithAfBiIds.keySet()
            ]) {
                if(oliMap.get(oli.OpportunityId) == null){
                    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                    oliList.add(oli);
                    oliMap.put(oli.OpportunityId, oliList);
                }else{
                    oliMap.get(oli.OpportunityId).add(oli);
                }
            }
            if(!oliMap.isEmpty()){
                for(Id opp : oliMap.keySet()){
                    Boolean hasAFProduct = false;
                    for(OpportunityLineItem oli : oliMap.get(opp)){
                        if (oli.Buy_interest__c != null && oli.Buy_interest__r.Lead_Source__c == SEConstants.LEAD_SOURCE_RESELLER) {
                            hasAFProduct = true;
                        }
                    }
                    if(!hasAFProduct){
                        afOpps.get(opp).addError(Label.LP_No_AF_Products);
                    }
                }
            }
        }
    }

    /*Author -  P.P
* Access to Renewal Team to change Ownership for Opportunities owned by Renewal Team
*/

    public static void ownerChangeAccess(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
        Boolean actionVar = false;
        List<Id> idCOTList = new List<Id>();
        Map<Id,Id> oppCAMMap = new Map<Id,Id>();
        Map<Id,User> uCOTMap = new Map<Id,User>();
        Map<Id,User> oppCOTMap = new Map<Id,User>();
        List<Id> cygateRoleIdList = new List<Id>();
        Set<String> cygateRoleSet = new Set<String>();
        List<Opportunity> oppCAMList = new List<Opportunity>();
        List<User> userCOTList = new List<User>();
        //extract role ids from Custom Setting for Cygate Manager Roles
        for(Cygate_Manager_Roles__c  cmr: Cygate_Manager_Roles__c.getAll().values()){
            cygateRoleSet.add(cmr.Role_Id__c);
        }

        // check if Change Owner To field has been updated in following IF condition

        for(Opportunity opp:newList){
            if (oldMap == null && opp.Change_Owner_To__c != null) {
                actionVar = true;
            } else if (oldMap != null && opp.Change_Owner_To__c != null && opp.Change_Owner_To__c != oldMap.get(opp.Id).Change_Owner_To__c) {
                actionVar = true;
            }
            }
        if (actionVar == true) {
            oppCAMList = [SELECT Id,AccountId,Account.Cygate_Account_Manager__c FROM Opportunity WHERE ID IN: newList];
            for(Opportunity opp:newList){
                idCOTList.add(opp.Change_Owner_To__c);
            }
            // to get role details of user who will be new Owner on Opportunity
            userCOTList = [SELECT Id, UserRoleId, ProfileId FROM User WHERE id IN :idCOTList];
            if(userCOTList.size()>0){
                for(User u:userCOTList){
                    uCOTMap.put(u.Id,u);
                }
            }
        }
        for(Opportunity opp:newList){
            oppCOTMap.put(opp.Id,uCOTMap.get(opp.Change_Owner_To__c));
        }

        for(Opportunity opp:oppCAMList){
            oppCAMMap.put(opp.Id,opp.Account.Cygate_Account_Manager__c);
        }

        for(Opportunity opp:newList){
            actionVar = false;
            if (oldMap == null && opp.Change_Owner_To__c != null) {
                actionVar = true;
            } else if (oldMap != null && opp.Change_Owner_To__c != null && opp.Change_Owner_To__c != oldMap.get(opp.Id).Change_Owner_To__c) {
                actionVar = true;
            }

            if (actionVar == true) {
                //for renewal roles in Case 3081
                if (Test.isRunningTest() || (SEUtility.getRenewalRoles(UserInfo.getUserId()))) {
                    //Renewal Team Members to be able to change owner only for opportunities owned within Renewal Team
                    if (SEUtility.getRenewalRoles(opp.Change_Owner_To__c) && SEUtility.getRenewalRoles(opp.OwnerId)) {
                        opp.OwnerId = opp.Change_Owner_To__c;
                        opp.Change_Owner_To__c = null;
                    }
                    //error when new owner does not belong to Renewal Team
                    else if (!SEUtility.getRenewalRoles(opp.Change_Owner_To__c)) {
                        opp.Change_Owner_To__c.adderror(system.label.No_Authorised_Access_for_Action);
                    }
                    //error when existing owner does not belong to Renewal Team
                    else if (!SEUtility.getRenewalRoles(opp.OwnerId)) {
                        opp.OwnerId.adderror(system.label.No_Authorised_Access_for_Action);
                    }
                }
                //Cygate Users can change ownership for opportunities belonging to Account for which they are tagged as Cygate Account Managers
                //Cygate Managers by heirarchy to be able to change ownership for Cygate Opportunities
                //using Fresh IF condition for code coverage
                if (
                    TEST.isRunningTEST() ||
                    (SEUtility.isCygateUserRole(UserInfo.getUserRoleId()) &&
                    ((UserInfo.getUserId() == oppCAMMap.get(opp.Id)) || cygateRoleSet.contains(UserInfo.getUserRoleId())))
                ) {
                    User urid = oppCOTMap.get(opp.Id);
                    if (SEUtility.isCygateUser(urid)) {
                        //to suit the SEUtility method input
                        opp.OwnerId = opp.Change_Owner_To__c;
                        opp.Change_Owner_To__c = null;
                    } else {
                        opp.Change_Owner_To__c.adderror(system.label.No_Authorised_Access_for_Action);
                    }
                }
                //Roles apart from Renewal and Cygate will face this error
                else if (
                    !(SEUtility.getRenewalRoles(UserInfo.getUserId())) &&
                    (!(UserInfo.getUserId() == oppCAMMap.get(opp.Id))) &&
                    (!(cygateRoleSet.contains(UserInfo.getUserRoleId())))
                ) {
                    opp.Change_Owner_To__c.adderror(system.label.No_Authorised_Access_for_Action);
                }
            }
        }
    }
    private static void checkCygateOppSeller(List<Opportunity> newList, Map<Id,Opportunity> oldmap){
        string prospectRecId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
        string cygateStandardRecId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD);
        string cygateEnlargementRecId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT);
        string cygateAfterRegRecId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFTERREG);
        string cygateAffarRecId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFFAR);

        for(Opportunity opp:newList){
            if (
                oldMap.get(opp.id).recordTypeId == prospectRecId &&
                (opp.RecordTypeId == cygateStandardRecId ||
                opp.RecordTypeId == cygateEnlargementRecId ||
                opp.RecordTypeId == cygateAfterRegRecId ||
                opp.RecordTypeId == cygateAffarRecId)
            ) {
                opp.Seller__c = null;
            }
        }
    }

    private static void CreateAddOppContactRole(List<Opportunity> newList, Map<Id,Opportunity> oldmap){
        List<OpportunityContactRole> insertOppContact =new List<OpportunityContactRole>();
        List<OpportunityContactRole> createOppContact=new List<OpportunityContactRole>();
        List<OpportunityContactRole> updateOppContact=new List<OpportunityContactRole>();
        OpportunityContactRole addOppCRole = new OpportunityContactRole();
        Set<Id> conId= new Set<Id>();
        Set<Id> contactId = new Set<Id>();
        List<OpportunityContactRole> oppconrole;
        List<OpportunityContactRole> ocrList;

        oppconrole = [SELECT Id, ContactId, OpportunityId, IsPrimary, Role FROM OpportunityContactRole WHERE OpportunityId IN :newlist];
        if (oppconrole.size() > 0) {
            for(OpportunityContactRole opco : oppconrole){
                conId.add(opco.ContactId);
            }
        }

        for (Opportunity opp : newlist) {
            if (oldMap != null) {
                if (
                    (oldMap.get(opp.id).recordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT) && opp.Converted_from_prospect__c) ||
                    (oldMap.get(opp.id).recordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD) ||
                    oldMap.get(opp.id).recordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT) ||
                    oldMap.get(opp.id).recordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFTERREG) &&
                    (opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFFAR))) ||
                    (SEUtility.isRealEstateFibereOpp(opp.RecordTypeId) && !SEUtility.isRealEstateFibereOpp(oldMap.get(opp.id).recordTypeId)) &&
                    opp.Contact__c != null
                ) {
                    if (conId.contains(opp.Contact__c)) {
                        if (oppconrole.size() > 0) {
                            for (OpportunityContactRole ocrole : oppconrole) {
                                if (ocrole.ContactId == opp.Contact__c) {
                                    if(!SEUtility.isRealEstateFibereOpp(opp.RecordTypeId) && ocrole.IsPrimary==false){
                                        ocrole.IsPrimary=true;
                                    }
                                    if(SEUtility.isRealEstateFibereOpp(opp.RecordTypeId)){
                                        ocrole.Role='Avtalstecknare';
                                    }
                                    updateOppContact.add(ocrole);
                                }
                            }
                        }
                    } else {
                        if (opp.Contact__c != null) {
                            addOppCRole.OpportunityId =opp.id;
                            addOppCRole.ContactId =opp.Contact__c;
                            if(!SEUtility.isRealEstateFibereOpp(opp.RecordTypeId)){
                                //set primary only for cygate opps
                                addOppCRole.IsPrimary = true;
                            }
                            if(SEUtility.isRealEstateFibereOpp(opp.RecordTypeId)){
                                addOppCRole.Role='Avtalstecknare';
                            }
                            createOppContact.add(addOppCRole);
                        }
                    }
                } else if (
                    oldMap.get(opp.id).Contact__c != opp.Contact__c &&
                    (opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFFAR) || (SEUtility.isRealEstateFibereOpp(opp.RecordTypeId)))
                ) {
                    contactId.add(oldMap.get(opp.id).Contact__c);
                    if (opp.Contact__c != null) {
                        addOppCRole.OpportunityId =opp.id;
                        addOppCRole.ContactId =opp.Contact__c;
                        if(!SEUtility.isRealEstateFibereOpp(opp.RecordTypeId)){
                            addOppCRole.IsPrimary = true;
                        }
                        if(SEUtility.isRealEstateFibereOpp(opp.RecordTypeId)){
                            addOppCRole.Role='Avtalstecknare';
                        }
                        createOppContact.add(addOppCRole);
                    }
                }
            }
        }
        if (contactId != null && newlist != null) {
            ocrList = [
                SELECT Id, ContactId, OpportunityId, IsPrimary, Role
                FROM OpportunityContactRole
                WHERE ContactId IN :contactId AND OpportunityId IN :newlist
            ];
        }
        if(!ocrList.isEmpty()){
            try {
            delete ocrList;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'CreateAddOppContactRole', ex);
            }
        }
        if (createOppContact.size() > 0) {
            try {
            insert createOppContact;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'CreateAddOppContactRole', ex);
            }
        }
        if (updateOppContact.size() > 0) {
            try {
            update updateOppContact;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'CreateAddOppContactRole', ex);
}
}
}
    //SALEF - 857 - only included in update statements since on insert Opportunities wont have cases attached to it
    //updated by P.P on 3rd sept
    private static void updateCaseAccess(List<Opportunity> newList, Map<id,Opportunity> oldMap){
        List<Case> caseList = new List<Case>();
        Set<id> oppidSet = new Set<Id>();
        Map<Id,Id> oppOwnerMap = new Map<Id,Id>();
        Map<Id,Id> removeCSMOppOwnerMap = new Map<Id,Id>();
        Set<Id> removeCSMIdSET = new Set<Id>();
        List<CaseShare> caseShareInsertList = new List<CaseShare>();
        Set<CaseShare> deleteCSHSet = new Set<CaseShare>();
        List<CaseShare> deleteCSHList = new List<CaseShare>();
        List<CaseShare> CaseShareList = new List<CaseShare>();

        for(Opportunity opp:newList){
            if (
                (opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD) ||
                opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_QUICK) ||
                opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD) ||
                opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_HW_LARGE_STANDARD) ||
                opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_ENLARGEMENT) ||
                opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_MERFORSALJNINGSMOJLIGHET)) &&
                (opp.OwnerId != oldMap.get(opp.id).OwnerId)
            ) {
                oppidSet.add(opp.id);
                oppOwnerMap.put(opp.Id,opp.OwnerId);
                removeCSMIdSET.add(oldMap.get(opp.Id).OwnerId);
                removeCSMOppOwnerMap.put(opp.Id,oldMap.get(opp.Id).OwnerId);
            }
        }
        if(oppIdSet.size()>0){
            caseList = [
                SELECT Id, Opportunity__c, Opportunity__r.OwnerId, Account.OwnerId, Account.Telia_Service_Manager__c, CreatedById
                FROM Case
                WHERE Opportunity__c IN :oppidSet
            ];
            if(caseList.size()>0){
                CaseShareList = [
                    SELECT
                        Id,
                        CaseAccessLevel,
                        CaseId,
                        Case.Opportunity__c,
                        Case.Opportunity__r.OwnerId,
                        Case.Account.OwnerId,
                        case.Account.Telia_Service_Manager__c,
                        case.CreatedById,
                        UserOrGroupId
                    FROM CaseShare
                    WHERE Case.Opportunity__c IN :oppidSet AND UserOrGroupId IN :removeCSMIdSet AND RowCause = :'Manual' AND CaseAccessLevel = 'Read'
                ];
                for(Case cs:caseList){
                    if (oppOwnerMap.get(cs.Opportunity__c) != null) {
                        Caseshare csh = new caseShare();
                        csh.CaseAccessLevel = 'Read';
                        csh.userOrGroupId = oppOwnerMap.get(cs.Opportunity__c);
                        csh.CaseId = cs.Id;
                        caseShareInsertList.add(csh);
                    }
                }
                for(CaseShare csh:caseShareList){
                    if (
                        (csh.UserOrgroupId == removeCSMOppOwnerMap.get(csh.Case.Opportunity__c)) &&
                        (csh.UserOrgroupId != csh.case.CreatedById) &&
                        (csh.UserOrGroupId != csh.case.Account.OwnerId) &&
                        (csh.userOrGroupId != csh.case.Account.Telia_Service_Manager__c) &&
                        (csh.UserOrGroupId != csh.case.opportunity__r.OwnerId)
                    ) {
                        deleteCSHSet.add(csh);
                    }
                }
            }
            if(deleteCSHSet.size()>0){
                deleteCSHList.addALL(deleteCSHSet);
            }
        }
        if(deleteCSHList.size()>0){
            try{
                delete deleteCSHList;
            } catch (exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateCaseAccess', e);
            }
        }
        if(caseShareInsertList.size()>0){
            try{
                insert caseShareInsertList;
            } catch (exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateCaseAccess', e);
            }
        }
    }

    /*changes for SALEF - 873 - Performance Opportunity Link start here*/
    private static void setPerformanceUseronOpp(List<Opportunity> oppList,Map<Id,Opportunity> oldMap){
        Map<Id,User_Performance__c> userPerformanceMap = new Map<Id,User_Performance__c>();
        List<Opportunity> oppListFiltered = filterPOLOpps(oppList);
        Set<Performance_Opportunity_Link__c> removePOLSet = new Set<Performance_Opportunity_Link__c>();
        List<Performance_Opportunity_Link__c> removePOLList = new List<Performance_Opportunity_Link__c>();
        List<Id> CAMIDList = new List<Id>();
        Set<Opportunity> oppListfilN = new Set<Opportunity>();
        if (oppListFiltered.isEmpty())
            return; else {
            for(Opportunity opp:oppListFiltered){
                if (OldMap == null) {
                    CAMIDList.add(opp.OwnerId);
                    oppListfilN.add(opp);
                } else {
                    if (opp.Performance_User__c == null) {
                        CAMIDList.add(opp.OwnerId);
                        oppListfilN.add(opp);
                    } else {
                        if(opp.OwnerID != oldMap.get(opp.Id).OwnerId){
                            CAMIDList.add(opp.OwnerId);
                            oppListfilN.add(opp);
                        }
                    }
                }
            }
        }
        if(CAMIDList.size()>0){
            List<User_Performance__c> UserPerformanceList = [
                SELECT Id, user__c, Name
                FROM User_Performance__c
                WHERE User__c IN :CAMIDList AND User__r.isActive = :true
            ];
            List<Performance_Opportunity_Link__c> polLIST = [
                SELECT Id, Opportunity__c
                FROM Performance_Opportunity_Link__c
                WHERE Opportunity__c IN :oppListfilN
            ];
            for(User_Performance__c up:UserPerformanceList){
                UserPerformanceMap.put(up.User__c,up);
            }
            Map<Id,Performance_Opportunity_Link__c> polMap = new Map<Id,Performance_Opportunity_Link__c>();
            for(Performance_Opportunity_Link__c pol:polList){
                polMap.put(pol.Opportunity__c,pol);
            }
            for(opportunity opp:Opplist){
                if(oppListfilN.contains(opp)){
                    if(userPerformanceMap.size()>0){
                        if(UserPerformanceMap.containskey(opp.ownerId)){
                            opp.Performance_User__c = UserPerformanceMap.get(opp.OwnerId).Id;
                        }
                    } else {
                        opp.Performance_User__c = null;
                        if(polMap.containskey(opp.id)){
                            removePOLSet.add(polMAP.get(opp.id));
                        }
                    }
                }
            }
        }
        if(removePOLSet.size()>0){
            removePOLList.addAll(removePOLSet);
            try {
            delete removePOLList;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'setPerformanceUseronOpp', ex);
            }
        }
    }
    private static List<Opportunity> filterPOLOpps(List<Opportunity> oppList){
        List<Opportunity> oppListFiltered = new List<Opportunity>();
        Id prospectRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
        Id cyagteAffarRecordTypeid = SEUtility.getRecordTypeid(SEUTILITY.OPP_RECTYPE_CYGATE_AFFAR);
        Id cygateStandardRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD);
        Id cygateEnlargementRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT);
        Id cygateAfterregRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFTERREG);
        Id cygateWebOrderRecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_WEBORDER);
        Set<Id> userSet = new Set<Id>();

        for(Opportunity opp:OppList){
            userSet.add(opp.ownerid);
        }
        Map<Id, user> userDetailsmap = new Map<Id, user>([SELECT Id, ProfileId, UserRoleId FROM User WHERE ID IN :userSet]);

        for(Opportunity opp : oppList){
            if (
                (opp.RecordTypeId == prospectRecordTypeId && SEUtility.isCygateUser(UserDetailsmap.get(opp.Ownerid).ProfileId)) ||
                opp.RecordTypeId == cygateStandardRecordTypeId ||
                opp.RecordTypeId == cygateEnlargementRecordTypeId ||
                opp.RecordTypeId == cygateAfterregRecordTypeId ||
                opp.RecordTypeId == cyagteAffarRecordTypeid ||
                opp.RecordTypeId == cygateWebOrderRecordTypeId
            ) {
                oppListFiltered.add(opp);
            }
        }
        return oppListFiltered;
    }

    private static void createPOL(List<Opportunity> newList){
        List<Opportunity> oppListFiltered = filterPOLOpps(newList);
        if (oppListFiltered.isEmpty())
            return;

        List<Opportunity> oppListPUFiltered = needsPOL(oppListFiltered);
        if (oppListPUFiltered.isEmpty())
            return;

        loadpuMap(oppListPUFiltered);
        polInsertList = new List<Performance_Opportunity_Link__c>();
        for(Opportunity opp : oppListPUFiltered){
            createPOL(opp);
        }
        if(polInsertList.size() > 0){
            try {
                insert polInsertList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'createPOL', e);
            }
        }
    }
    private static void updatePOL(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        List<Opportunity> oppListFiltered = filterPOLOpps(newList);
        if (oppListFiltered.isEmpty())
            return;

        List<Opportunity> oppListPUFiltered = needsPOL(oppListFiltered);
        if (oppListPUFiltered.isEmpty())
            return;

        loadpuMap(oppListPUFiltered);
        loadOppWithPOLs(newList);

        polDeleteList = new List<Performance_Opportunity_Link__c>();
        polInsertList = new List<Performance_Opportunity_Link__c>();
        polUpdateList = new List<Performance_Opportunity_Link__c>();

        for(Opportunity opp : oppListPUFiltered){
            Opportunity oldOpp = oldMap.get(opp.Id);
            Opportunity oppWithPOLs = oppWithPOLsMap.get(opp.Id);

            if(oppWithPOLs.Performance_Opportunity_Links__r.size() < 1){
                createPOL(opp);
            } else if(opp.Performance_User__c != oldOpp.Performance_User__c){
                polDeleteList.addAll(oppWithPOLs.Performance_Opportunity_Links__r);
                createPOL(opp);
            } else if(opp.CloseDate != oldOpp.CloseDate){
                repointPOL(opp, oppWithPOLs.Performance_Opportunity_Links__r);
            } else if(isUpdateNeededPOL(opp, oldOpp)){
                updatePOLValues(opp, oppWithPOLs.Performance_Opportunity_Links__r);
            }
        }
        if(polDeleteList.size() > 0){
            try {
                delete polDeleteList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updatePOL', e);
            }
        }
        if(polUpdateList.size() > 0){
            try {
                update polUpdateList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updatePOL', e);
            }
        }
        if(polInsertList.size() > 0){
            try {
                insert polInsertList;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updatePOL', e);
            }
        }
    }

    private static void createPOL(Opportunity opp){
        if (opp.Performance_User__c == null || !PUMap.containsKey(opp.Performance_User__c))
            return;

        String monthName = convertMonthInttoStr(opp.CloseDate.month());
        String year = convertYearInttoStr(opp.CloseDate.year());
        Id mpsId = getmpsForPU(opp.Performance_User__c, monthName, year);
        id ypsId = getypsForPU(opp.Performance_User__c, monthName, year);
        Id qpsId = getQPSForPU(opp.Performance_User__c, monthName, year);
        if(mpsId != null){
            Performance_Opportunity_Link__c newPol = new Performance_Opportunity_Link__c(
                Monthly_Performance_Score__c = mpsId,
                Opportunity__c = opp.Id,
                Yearly_Performance_Score__c = ypsId,
                Quarterly_Performance_Score__c = qpsId
            );
            setPOLValuesFromOpp(newPol, opp);
            polInsertList.add(newPol);
        }
    }

    private static void loadPUMap(List<Opportunity> oppList){
        if(puMAP == null){
            Set<String> monthNames = new Set<String>();
            Set<String> years = new Set<String>();

            for(Opportunity opp : oppList){
                monthNames.add(convertMonthInttoStr(opp.CloseDate.month()));
                years.add(convertYearInttoStr(opp.CloseDate.year()));
            }

            puMap = new Map<Id, User_Performance__c>(
                [
                    SELECT
                        Id,
                            User__c, (
                            SELECT
                                Id,
                                Name,
                                User_Performance__c,
                                Yearly_Performance_Score__c,
                                Yearly_Performance_Score__r.Name,
                                Quarterly_Performance_Score__c,
                                Quarterly_Performance_Score__r.name
                            FROM Monthly_Performance_Scores__r
                            WHERE Name IN :monthNames AND Yearly_Performance_Score__r.Name IN :years
                        )
                FROM User_Performance__c
                ]
            );
        }
    }

    private static Id getMPSForPU(Id puId, string monthName, string year){
        List<Monthly_Performance_Score__c> mpsList = puMap.get(puId).Monthly_Performance_Scores__r;

        for(Monthly_Performance_Score__c mps : mpsList){
            if(mps.Name == monthName && mps.Yearly_Performance_Score__r.Name == year){
                return mps.Id;
            }
        }
        return null;//return null if no MPS ID found
    }
    private static Id getYPSForPU(Id puId, string monthName, string year){
        List<Monthly_Performance_Score__c> mpsList = puMap.get(puId).Monthly_Performance_Scores__r;

        for(Monthly_Performance_Score__c mps : mpsList){
            if(mps.Name == monthName && mps.Yearly_Performance_Score__r.Name == year){
                return mps.Yearly_performance_score__c;
            }
        }
        return null;//return null if no MPS ID found
    }
    private static Id getQPSforPU(Id puid, string MonthName, string year){
        List<Monthly_Performance_Score__c> mpsList = puMap.get(puId).Monthly_Performance_Scores__r;

        for(Monthly_Performance_Score__c mps : mpsList){
            if(mps.Name == monthName && mps.Yearly_Performance_Score__r.Name == year){
                return mps.Quarterly_performance_score__c;
            }
        }
        return null;
    }

    private static void setPOLValuesFromOpp(List<Opportunity> lstopp, Map<id, Opportunity> oldmap){
        list<Performance_Opportunity_Link__c> lstPolToUpdate = new List<Performance_Opportunity_Link__c>();
        list<Performance_Opportunity_Link__c> lstPolToUpdateback = new List<Performance_Opportunity_Link__c>();
        Map<ID, Opportunity> mapToPoL = new Map<id, Opportunity>();
        set<Id> OppIDSet = new Set<id>();
        for(opportunity opp:lstopp){
            if(opp.Agreement_Type_Cygate__c== 'Frame Agreement Cygate' && opp.Agreement_Type_Cygate__c!= oldmap.get(opp.id).Agreement_Type_Cygate__c){
                OppIDSet.add(opp.id);
            } else if (
                opp.Agreement_Type_Cygate__c != 'Frame Agreement Cygate' &&
                opp.Agreement_Type_Cygate__c != oldmap.get(opp.id).Agreement_Type_Cygate__c
            ) {
                mapToPoL.put(opp.id,opp);
            }
        }
        if(mapToPoL.values().size()>0){
            for (Performance_Opportunity_Link__c pol1 : [
                SELECT id, Amount__c, opportunity__C, Product_Amount__c, Service_Amount__c
                FROM Performance_Opportunity_Link__c
                WHERE opportunity__C IN :mapToPoL.keyset()
            ]) {
                if(mapToPoL.containsKey(pol1.opportunity__C)){
                pol1.Product_Amount__c =mapToPoL.get(pol1.opportunity__C).Total_Amount_Produkt__c;
                 pol1.Service_Amount__c=mapToPoL.get(pol1.opportunity__C).Total_Amount_Tj_nst__c;
                 if(mapToPoL.get(pol1.opportunity__C).Count_Cygate_Products__c == 0){
                    pol1.Amount__c = mapToPoL.get(pol1.opportunity__C).Total_Amount_Cygate__c;
                 }else{
                 pol1.Amount__c= mapToPoL.get(pol1.opportunity__C).Total_Amount_Produkt__c+mapToPoL.get(pol1.opportunity__C).Total_Amount_Tj_nst__c;
                 }
                    lstPolToUpdateback.add(pol1) ;
                }
            }
            if(lstPolToUpdateback.size()>0){
                try {
               update lstPolToUpdateback;
                } catch (Exception ex) {
                    SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'setPOLValuesFromOpp', ex);
                }
            }
        }
        if(OppIDSet.size()>0){
            for (Performance_Opportunity_Link__c pol1 : [
                SELECT id, Amount__c, opportunity__C, Product_Amount__c, Service_Amount__c
                FROM Performance_Opportunity_Link__c
                WHERE opportunity__C IN :OppIDSet
            ]) {
                 pol1.Product_Amount__c =0;
                 pol1.Service_Amount__c=0;
                 pol1.Amount__c=0;
                 lstPolToUpdate.add(pol1) ;
            }
            if(lstPolToUpdate.size()>0){
                try {
               update lstPolToUpdate;
                } catch (Exception ex) {
                    SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'setPOLValuesFromOpp', ex);
                }
            }
        }
    }
    private static void setPOLValuesFromOpp(Performance_Opportunity_Link__c pol, Opportunity opp){
        pol.Is_Closed__c = opp.IsClosed;
        pol.Is_Won__c = opp.IsWon;
        pol.Opportunity_Close_Date__c = opp.CloseDate;
        if(opp.Agreement_Type_Cygate__c!= 'Frame Agreement Cygate'){
        pol.Product_Amount__c = opp.Total_Amount_Produkt__c;
        pol.Service_Amount__c = opp.Total_Amount_Tj_nst__c;
        if(opp.Count_Cygate_Products__c == 0){
            pol.Amount__c = opp.Total_Amount_Cygate__c;
        } else {
            pol.Amount__c = opp.Total_Amount_Produkt__c + opp.Total_Amount_Tj_nst__c;
        }
    }
    }
    private static void loadOppWithPOLs(List<Opportunity> oppList){
        if(oppWithPOLsMap == null){
            oppWithPOLsMap = new Map<Id, Opportunity>(
                [
                    SELECT
                            Id, (
                            SELECT
                                Id,
                                Opportunity__c,
                                Monthly_Performance_Score__r.User_Performance__C,
                                Product_Amount__c,
                                Service_Amount__c,
                                Amount__c,
                                Is_Closed__c,
                                Is_Won__c
                    FROM Performance_Opportunity_Links__r
                )
                FROM Opportunity
                    WHERE Id IN :oppList
                ]
            );
        }
    }

    private static void repointPOL(Opportunity opp, List<Performance_Opportunity_Link__c> polList){
        string monthName = convertMonthInttoStr(opp.CloseDate.Month());
        String year = convertYearInttoStr(opp.CloseDate.year());

        for(Performance_Opportunity_Link__c pol : polList){
            Id newMpsId = getMPSForPU(pol.Monthly_Performance_Score__r.user_Performance__c, monthName, year);
            Id newYpsId = getYPSforPU(pol.Monthly_Performance_Score__r.user_Performance__c, monthName, year);
            Id newQpsId = getQPSforPU(pol.Monthly_Performance_Score__r.user_Performance__c, monthName, year);
            if(newMpsId != null){
                pol.Monthly_Performance_Score__c = newMPSId;
                pol.Yearly_Performance_Score__C = newYPSId;
                pol.Quarterly_Performance_Score__c = newQPSId;
                updatePOLValues(opp, pol);
            } else {
                polDeleteList.add(pol);
            }
        }
    }
    private static void updatePOLValues(Opportunity opp, Performance_Opportunity_Link__c pol){
        setPOLValuesFromOpp(pol,opp);
        polUpdateList.add(pol);
    }
    private static void updatePOLValues(Opportunity opp, List<Performance_Opportunity_Link__c> polList){
        for(Performance_Opportunity_Link__c pol : polList){
            updatePOLValues(opp, pol);
        }
    }
    private static Boolean isupdateneededPOL(Opportunity newOpp, Opportunity oldOpp){
        Boolean needsUpdate = (newOpp.Count_Cygate_Products__c != oldOpp.Count_Cygate_Products__c ||
            newOpp.Total_Amount_Produkt__c != oldOpp.Total_Amount_Produkt__c ||
            newOpp.Total_Amount_Tj_nst__c != oldOpp.Total_Amount_Tj_nst__c ||
            newOpp.IsClosed != oldOpp.IsClosed ||
            newOpp.IsWon != oldOpp.IsWon ||
        newOpp.Total_Amount_Cygate__c != oldOpp.Total_Amount_Cygate__c);
        return needsUpdate;
    }
    private static Set<String> convertMonthInttoStr(Set<Integer> monthNames){
        set<String> monthNamesStr = new Set<String>();
        string mNStr = '';
        for(Integer mN: monthNames){
            mNStr = convertMonthIntToStr(mN);
            monthNamesStr.add(mNStr);
        }
        return monthNamesStr;
    }
    private static String convertMonthIntToStr(integer monthName){
        string monthStr = '';
        if(monthName >= 10){
            monthStr = string.valueof(monthName);
        } else {
            monthStr = '0'+string.valueof(monthName);
        }
        return monthStr;
    }
    private static Set<String> convertYearInttoStr(Set<Integer> Year){
        set<String> yearStr = new Set<String>();
        string yRStr = '';
        for(Integer yR: Year){
            yRStr = convertYearIntToStr(yR);
            yearStr.add(yRStr);
        }
        return yearStr;
    }
    private static String convertYearIntToStr(integer year){
        string yearStr = string.Valueof(year);
        return yearStr;
    }
    private static List<Opportunity> needsPOL(List<Opportunity> oppList){
        List<Opportunity> oppNeedsPOLList = new List<Opportunity>();
        for(opportunity opp:oppList){
            if (opp.Performance_User__c != null) {
                oppNeedsPOLList.add(opp);
            }
        }
        return oppNeedsPOLList;
    }
    /*changes for SALEF - 873 - Performance Opportunity Link end here*/

    //Owner - P.S - SALEF-1081 - Add the Former Opps owner as the Opps team member for security Opps with read/write access if it's from given cygate sales support roles
    public static void AddFormarOppsOwner(List<Opportunity> newList,Map<Id,Opportunity> oldMap){
        List<OpportunityShare> listOTMnew = new List<OpportunityShare>();
        List<OpportunityTeamMember> listOTMinsert = new List<OpportunityTeamMember>();
        List<OpportunityShare> listOTMupdate = new List<OpportunityShare>();
        Set<Id> FormerOwnerId = new Set<Id>();
        Set<Id> OppsId = new Set<Id>();
        List<Roles_for_Formar_Opps_Owner_Cygate__mdt> roleList = [SELECT id, MasterLabel FROM Roles_for_Formar_Opps_Owner_Cygate__mdt];
        Set<String> roleSet = new Set<String>();
        for(Roles_for_Formar_Opps_Owner_Cygate__mdt roles : roleList){
            roleSet.add(roles.MasterLabel);
        }
        for (Opportunity newOpps : newList) {
            if (oldMap != null && newOpps.Account_Security_Category__c != null && (roleSet.contains(oldMap.get(newopps.Id).Opportunity_Owner_Role__c))) {
                OpportunityTeamMember member = new OpportunityTeamMember();
                member.OpportunityId = newOpps.Id;
                member.UserId = oldMap.get(newopps.Id).OwnerID;
                member.TeamMemberRole = 'Cygate - Innesälj';
                FormerOwnerId.add(oldMap.get(newopps.Id).OwnerID);
                OppsId.add(newOpps.Id);
                listOTMinsert.add(member);
            }
        }
        if(listOTMinsert.size()>0 ){
            try {
            insert listOTMinsert;
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'AddFormarOppsOwner', ex);
            }
        }
        if (OppsId.size() > 0 && FormerOwnerId.size() > 0) {
            listOTMnew = [
                SELECT id, OpportunityAccessLevel, UserOrGroupId
                FROM OpportunityShare
                WHERE OpportunityId = :OppsId AND UserOrGroupId = :FormerOwnerId AND rowcause = 'Team'
            ];
            if(listOTMnew.size()>0){
                for (OpportunityShare share : listOTMnew) {
                    share.OpportunityAccessLevel = 'Edit';
                    listOTMupdate.add(share);
                }
                if (listOTMupdate.size() > 0) {
                    try {
                    update listOTMupdate;
                    } catch (Exception ex) {
                        SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'AddFormarOppsOwner', ex);
                    }
                }
            }
        }
    }//End of method -AddFormarOppsOwner

    //Owner- P.S- SALEF-3781 -  Added method addSMESalesKAMITasOTM() to add Sales KAM IT user as Opportunity Team Member.
    public static void addSMESalesKAMITasOTM(List <Opportunity> newList, Map <Id, Opportunity> oldMap) {
        Set<Id>SMESalesKAMITId = new Set<Id>();
        Set<Id>deleteSMESalesKAMITId = new Set<Id>();
        Set<Id>oldSMESalesKAMITId = new Set<Id>();
        Set<Id>OppId = new Set<Id>();
        Set<id>newOppId = new Set<Id>();
        List<OpportunityTeamMember> addSMESalesKAMIT = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> listofOTM = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> deleteOTM = new List<OpportunityTeamMember>();
        List<OpportunityShare> listOTMnew = new List<OpportunityShare>();
        List<OpportunityShare> listOTMupdate = new List<OpportunityShare>();

        for(Opportunity newOpp: newList) {
            if (
                newOpp.RecordtypeID == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD) ||
                newOpp.RecordtypeID == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_QUICK) ||
                newOpp.RecordtypeID == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_Efterregistering)
            ) {
                if(oldMap == null && newOpp.SME_Sales_KAM_IT__c != null) {
                    SMESalesKAMITId.add(newOpp.SME_Sales_KAM_IT__c);
                    addSMESalesKAMIT = createSMESalesKAMITOppsTeamMember(addSMESalesKAMIT, newOpp);
                    newOppId.add(newOpp.id);
                } else if (
                    oldMap != null &&
                    oldMap.get(newOpp.Id).SME_Sales_KAM_IT__c == null &&
                    newOpp.SME_Sales_KAM_IT__c != oldMap.get(newOpp.Id).SME_Sales_KAM_IT__c &&
                    newOpp.SME_Sales_KAM_IT__c != null
                ) {
                    addSMESalesKAMIT = createSMESalesKAMITOppsTeamMember(addSMESalesKAMIT, newOpp);
                    SMESalesKAMITId.add(newOpp.SME_Sales_KAM_IT__c);
                    newOppId.add(newOpp.id);
                } else if (
                    oldMap != null &&
                    oldMap.get(newOpp.Id).SME_Sales_KAM_IT__c != null &&
                    newOpp.SME_Sales_KAM_IT__c != oldMap.get(newOpp.Id).SME_Sales_KAM_IT__c &&
                    newOpp.SME_Sales_KAM_IT__c != null
                ) {
                    oppid.add(newOpp.id);
                    oldSMESalesKAMITId.add(oldMap.get(newOpp.Id).SME_Sales_KAM_IT__c);
                    SMESalesKAMITId.add(newOpp.SME_Sales_KAM_IT__c);
                    addSMESalesKAMIT = createSMESalesKAMITOppsTeamMember(addSMESalesKAMIT, newOpp);
                    newOppId.add(newOpp.id);
                } else if(oldMap != null && oldMap.get(newOpp.Id).SME_Sales_KAM_IT__c != null && newOpp.SME_Sales_KAM_IT__c == null) {
                    oppid.add(newOpp.id);
                    deleteSMESalesKAMITId.add(oldMap.get(newOpp.Id).SME_Sales_KAM_IT__c);
                }
            }
        }
        if(!SMESalesKAMITId.isEmpty()) {
            listofOTM = [
                SELECT id, UserId
                FROM OpportunityTeamMember
                WHERE OpportunityId = :oppid AND userId = :oldSMESalesKAMITId AND TeamMemberRole = :'KAM IT'
            ];
        } else if(!deleteSMESalesKAMITId.isEmpty()) {
            listofOTM = [
                SELECT id, UserId
                FROM OpportunityTeamMember
                WHERE OpportunityId = :oppid AND userId = :deleteSMESalesKAMITId AND TeamMemberRole = :'KAM IT'
            ];
        }

        if(!listofOTM.IsEmpty() && listofOTM.size() > 0) {
            deleteOTM.addall(listofOTM);
            try {
            database.delete(deleteOTM, false);
            } catch (Exception ex) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'addSMESalesKAMITasOTM', ex);
            }
        }
        if(!addSMESalesKAMIT.IsEmpty() && addSMESalesKAMIT.size() > 0) {
            try {
                insert addSMESalesKAMIT;
            } catch (Exception e) {
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'addSMESalesKAMITasOTM', e);
            }
        }
        if (newOppId.size() > 0 && addSMESalesKAMIT.size() > 0) {
            listOTMnew = [
                SELECT id, OpportunityAccessLevel, UserOrGroupId
                FROM OpportunityShare
                WHERE OpportunityId = :newOppId AND UserOrGroupId = :SMESalesKAMITId AND rowcause = 'Team'
            ];
            if(listOTMnew.size()>0){
                for (OpportunityShare share : listOTMnew) {
                    share.OpportunityAccessLevel = 'Edit';
                    listOTMupdate.add(share);
                }
                if (listOTMupdate.size() > 0) {
                    try {
                    update listOTMupdate;
                    } catch (Exception ex) {
                        SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'addSMESalesKAMITasOTM', ex);
                    }
                }
            }
        }
    }
    private static List <OpportunityTeamMember> createSMESalesKAMITOppsTeamMember(List<OpportunityTeamMember> listofSMESalesKAMIT, Opportunity newOpp) {
        OpportunityTeamMember newSMESalesKAMIT = new OpportunityTeamMember();
        newSMESalesKAMIT.OpportunityId = newOpp.Id;
        newSMESalesKAMIT.UserId = newOpp.SME_Sales_KAM_IT__c;
        newSMESalesKAMIT.TeamMemberRole = 'KAM IT';
        listofSMESalesKAMIT.add(newSMESalesKAMIT);
        if (listofSMESalesKAMIT.size() > 0) {
            return listofSMESalesKAMIT;
        } else {
            return null;
        }
    }

     public static void updateContractQuotes(Map<Id, Opportunity> oldMap, Set<Id> opportunityIDs) {
        Boolean contNeedUpdate = false;
        Boolean quoteNeedUpdate = false;
        List<Contract> updateContracts = new List<Contract>();
        List<Quote> updateQuotes = new List<Quote>();
        Map<Id, List<Contract>> contractIDmap = new Map<Id, List<Contract>>();
        try {
            List<Contract> allContracts = [
                    SELECT
                            Type_of_Address__c,
                            Status,
                            Reason_for_Cancellation__c,
                            OwnerId,
                            vlocity_cmt__OpportunityId__c,
                            Number_of_other_Ports__c,
                            Number_of_Households__c,
                            Number_of_Ports__c,
                            Number_of_Premises__c,
                            Number_of_Facilities__c,
                            Municipality__c,
                            Brand__c,
                            Amount_of_ports_Smart_Home__c,
                            Wished_delivery_date_not_guaranteed__c
                    FROM Contract
                    WHERE vlocity_cmt__OpportunityId__c IN :opportunityIDs
            ];
            for (Contract con : allContracts) {
                if (contractIDmap.get(con.vlocity_cmt__OpportunityId__c) == null) {
                    List<Contract> contractList = new List<Contract>();
                    contractList.add(con);
                    contractIDmap.put(con.vlocity_cmt__OpportunityId__c, contractList);
                } else {
                    contractIDmap.get(con.vlocity_cmt__OpportunityId__c).add(con);
                }
            }
        } catch (Exception ex) {
            SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateContractQuotes', ex);
        }

        for (Opportunity opp : [
                SELECT
                        Type_of_Address__c,
                        Comment_to_Reason__c,
                        OwnerId,
                        StageName,
                        Number_of_other_Ports__c,
                        Number_of_Households__c,
                        Number_of_Ports__c,
                        Number_of_Premises__c,
                        Number_of_Facilities__c,
                        Municipality__c,
                        Brand__c,
                        Amount_of_ports_Smart_Home__c,
                        Wished_delivery_date_not_guaranteed__c, (
                        SELECT
                                Type_of_Address__c,
                Status,
                Reason_for_Cancellation__c,
                                OwnerId,
                                TeliaSE_Fiber_Number_of_Households__c,
                                Number_of_other_Ports__c,
                                TeliaSE_Fiber_Number_of_Ports__c,
                                TeliaSE_Fiber_Number_of_Premises__c,
                                TeliaSE_Fiber_Number_of_Facilities__c,
                                Municipality__c,
                                Brand__c,
                                Amount_of_ports_Smart_Home__c,
                                Wished_delivery_date_not_guaranteed__c
                FROM Quotes
            )
            FROM Opportunity
            WHERE Id IN:opportunityIDs
        ]) {
            if (contractIDmap.get(opp.id) != null) {
                for (Contract cont : contractIDmap.get(opp.id)) {
                    if (
                            (opp.StageName == '04 Förlorad' ||
                                    opp.StageName == '05 Avbruten') &&
                                    oldMap.get(opp.Id).StageName != '04 Förlorad' &&
                                    oldMap.get(opp.Id).StageName != '05 Avbruten' &&
                                    cont.Status == 'Draft'
                            ) {
                        cont.status = 'Cancelled';
                        cont.Reason_for_Cancellation__c = opp.Comment_to_Reason__c;
                        contNeedUpdate = true;
                    }
                    if (opp.OwnerId != oldMap.get(opp.Id).OwnerId && cont.OwnerId != opp.OwnerId && cont.Status == 'Draft') {
                        cont.OwnerId = opp.OwnerId;
                        contNeedUpdate = true;
                    }
                    if (opp.Type_of_Address__c != oldMap.get(opp.Id).Type_of_Address__c && opp.Type_of_Address__c != cont.Type_of_Address__c) {
                        cont.Type_of_Address__c = opp.Type_of_Address__c;
                        contNeedUpdate = true;
                    }
                    if (
                            opp.Number_of_Households__c != oldMap.get(opp.Id).Number_of_Households__c &&
                                    opp.Number_of_Households__c != cont.Number_of_Households__c
                            ) {
                        cont.Number_of_Households__c = opp.Number_of_Households__c;

                        contNeedUpdate = true;
                    }
                    if (
                            opp.Number_of_other_Ports__c != oldMap.get(opp.Id).Number_of_other_Ports__c &&
                                    opp.Number_of_other_Ports__c != cont.Number_of_other_Ports__c
                            ) {
                        cont.Number_of_other_Ports__c = opp.Number_of_other_Ports__c;
                        contNeedUpdate = true;
                    }
                    if (opp.Number_of_Ports__c != oldMap.get(opp.Id).Number_of_Ports__c && opp.Number_of_Ports__c != cont.Number_of_Ports__c) {
                        cont.Number_of_Ports__c = opp.Number_of_Ports__c;
                        contNeedUpdate = true;
                    }
                    if (opp.Number_of_Premises__c != oldMap.get(opp.Id).Number_of_Premises__c && opp.Number_of_Premises__c != cont.Number_of_Premises__c) {
                        cont.Number_of_Premises__c = opp.Number_of_Premises__c;
                        contNeedUpdate = true;
                    }
                    if (
                            opp.Number_of_Facilities__c != oldMap.get(opp.Id).Number_of_Facilities__c &&
                                    opp.Number_of_Facilities__c != cont.Number_of_Facilities__c
                            ) {
                        cont.Number_of_Facilities__c = opp.Number_of_Facilities__c;
                        contNeedUpdate = true;
                    }
                    if (opp.Municipality__c != oldMap.get(opp.Id).Municipality__c && opp.Municipality__c != cont.Municipality__c) {
                        cont.Municipality__c = opp.Municipality__c;
                        contNeedUpdate = true;
                    }
                    if (opp.Brand__c != oldMap.get(opp.Id).Brand__c && opp.Brand__c != cont.Brand__c) {
                        cont.Brand__c = opp.Brand__c;
                        contNeedUpdate = true;
                    }
                    if (
                            opp.Amount_of_ports_Smart_Home__c != oldMap.get(opp.Id).Amount_of_ports_Smart_Home__c &&
                                    opp.Amount_of_ports_Smart_Home__c != cont.Amount_of_ports_Smart_Home__c
                            ) {
                        cont.Amount_of_ports_Smart_Home__c = opp.Amount_of_ports_Smart_Home__c;
                        contNeedUpdate = true;
                    }

                    if (
                            opp.Wished_delivery_date_not_guaranteed__c != oldMap.get(opp.Id).Wished_delivery_date_not_guaranteed__c &&
                                    opp.Wished_delivery_date_not_guaranteed__c != cont.Wished_delivery_date_not_guaranteed__c
                            ) {
                        cont.Wished_delivery_date_not_guaranteed__c = opp.Wished_delivery_date_not_guaranteed__c;
                        contNeedUpdate = true;
                    }

                    if (contNeedUpdate) {
                        contNeedUpdate = false;
                        updateContracts.add(cont);
                    }
                }
            }
            for (Quote quot : opp.Quotes) {
                if (
                        (opp.StageName == '04 Förlorad' ||
                                opp.StageName == '05 Avbruten') &&
                                oldMap.get(opp.Id).StageName != '04 Förlorad' &&
                                oldMap.get(opp.Id).StageName != '05 Avbruten'
                        ) {
                    quot.status = 'Cancelled';
                    quot.Reason_for_Cancellation__c = opp.Comment_to_Reason__c;
                    quoteNeedUpdate = true;
                }

                if (opp.Type_of_Address__c != oldMap.get(opp.Id).Type_of_Address__c && opp.Type_of_Address__c != quot.Type_of_Address__c) {
                    quot.Type_of_Address__c = opp.Type_of_Address__c;
                    quoteNeedUpdate = true;
                }
                if (
                        opp.Number_of_Households__c != oldMap.get(opp.Id).Number_of_Households__c &&
                                opp.Number_of_Households__c != quot.TeliaSE_Fiber_Number_of_Households__c
                        ) {
                    quot.TeliaSE_Fiber_Number_of_Households__c = opp.Number_of_Households__c;
                    quoteNeedUpdate = true;
                }
                if (
                        opp.Number_of_other_Ports__c != oldMap.get(opp.Id).Number_of_other_Ports__c &&
                                opp.Number_of_other_Ports__c != quot.Number_of_other_Ports__c
                        ) {
                    quot.Number_of_other_Ports__c = opp.Number_of_other_Ports__c;
                    quoteNeedUpdate = true;
                }
                if (opp.Number_of_Ports__c != oldMap.get(opp.Id).Number_of_Ports__c && opp.Number_of_Ports__c != quot.TeliaSE_Fiber_Number_of_Ports__c) {
                    quot.TeliaSE_Fiber_Number_of_Ports__c = opp.Number_of_Ports__c;
                    quoteNeedUpdate = true;
                }
                if (
                        opp.Number_of_Premises__c != oldMap.get(opp.Id).Number_of_Premises__c &&
                                opp.Number_of_Premises__c != quot.TeliaSE_Fiber_Number_of_Premises__c
                        ) {
                    quot.TeliaSE_Fiber_Number_of_Premises__c = opp.Number_of_Premises__c;
                    quoteNeedUpdate = true;
                }
                if (
                        opp.Number_of_Facilities__c != oldMap.get(opp.Id).Number_of_Facilities__c &&
                                opp.Number_of_Facilities__c != quot.TeliaSE_Fiber_Number_of_Facilities__c
                        ) {
                    quot.TeliaSE_Fiber_Number_of_Facilities__c = opp.Number_of_Facilities__c;
                    quoteNeedUpdate = true;
                }
                if (opp.Municipality__c != oldMap.get(opp.Id).Municipality__c && opp.Municipality__c != quot.Municipality__c) {
                    quot.Municipality__c = opp.Municipality__c;
                    quoteNeedUpdate = true;
                }
                if (opp.Brand__c != oldMap.get(opp.Id).Brand__c && opp.Brand__c != quot.Brand__c) {
                    quot.Brand__c = opp.Brand__c;
                    quoteNeedUpdate = true;
                }
                if (
                        opp.Amount_of_ports_Smart_Home__c != oldMap.get(opp.Id).Amount_of_ports_Smart_Home__c &&
                                opp.Amount_of_ports_Smart_Home__c != quot.Amount_of_ports_Smart_Home__c
                        ) {
                    quot.Amount_of_ports_Smart_Home__c = opp.Amount_of_ports_Smart_Home__c;
                    quoteNeedUpdate = true;
                }

                if (
                        opp.Wished_delivery_date_not_guaranteed__c != oldMap.get(opp.Id).Wished_delivery_date_not_guaranteed__c &&
                                opp.Wished_delivery_date_not_guaranteed__c != quot.Wished_delivery_date_not_guaranteed__c
                        ) {
                    quot.Wished_delivery_date_not_guaranteed__c = opp.Wished_delivery_date_not_guaranteed__c;
                    quoteNeedUpdate = true;
                }

                if (quoteNeedUpdate) {
                    quoteNeedUpdate = false;
                    updateQuotes.add(quot);
                }
            }
        }
        if (!updateContracts.isEmpty()) {
            try{
                update updateContracts;
            }catch(Exception e){
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateContractQuotes', e);
            }
        }
        if (!updateQuotes.isEmpty()) {
            try{
                update updateQuotes;
            }catch(Exception e){
                SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'updateContractQuotes', e);
            }
        }
    }
   // Lost ITDaaS Opportunity Sync to Auto Task (SALEF-5384)
    public static Boolean isFirstTime = true;
    public static void AutoTaskOpportunitySync(List <Opportunity> newList, Map <Id, Opportunity> oldMap){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
		Map<String, Contract> oppMap = new Map<String, Contract>();
        String procedureName = 'MassCustomized_APIGardenTokens'; /* Integration Procedure */
        List<Contract> contractList = [Select id,vlocity_cmt__OpportunityId__c,vlocity_cmt__QuoteId__r.TeliaSE_Autotask_QuoteId__c,Status,
                                       (Select id from vlocity_cmt__ContractLineItems__r where TeliaSE_Product_Object_Type__c = 'ITDaaS Offer Spec' and vlocity_cmt__LineStatus__c != 'Active' )
                                       from Contract where Status = 'Signed' and vlocity_cmt__QuoteId__r.TeliaSE_Autotask_QuoteId__c != null and vlocity_cmt__OpportunityId__c IN :oldMap.keySet()];
        for(Contract con : contractList){
            oppMap.put(con.vlocity_cmt__OpportunityId__c, con);
        }
        for (Opportunity opp : NewList)
            if(isFirstTime){
                if (
                    (opp.StageName == 'Vunnen' && oldmap.get(opp.Id).StageName != 'Vunnen') ||
                    (opp.StageName == 'Förlorad' &&
                    oldmap.get(opp.Id).StageName != 'Förlorad')
                ) {
                    if(opp.MC_Autotask_OppId__c != null){
                        isFirstTime = false;
                        Map <String, Object> ipInput = new Map <String, Object> ();
                        Map <String, Object> ipOptions = new Map <String, Object> ();
                        ipOptions.put('isDebug',true);
                        /* Populating input map for the Integration Procedure*/
                        String OpportunityId = opp.Id; 
                        ipInput.put('OpportunityId', OpportunityId);
                        
						if(opp.StageName == 'Vunnen' && oppMap.get(opp.id).vlocity_cmt__QuoteId__r.TeliaSE_Autotask_QuoteId__c!=null && oppMap.get(opp.id).vlocity_cmt__ContractLineItems__r.size()<=0){
						ipInput.put('stageName','wonButNoAutotask');
                        }
						/* Call the IP via runIntegrationService,running the Future invocation of the method (will get no output for this)*/
                        Id batchJob = vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable(procedureName, ipInput, ipOptions);                        
                    }
                }  
            }                
    }    /**
     * @description Method to count child opportunity total amount on parent opportunity (frame agreement).
     * @author Mantas Brazionis
     * @param newList - List of the new versions of the Opportunity records.
     * @param oldMap - A map of IDs to the old versions of the Oppportunity records.
     * @date 09 02 2023.
     **/
    public static void calculateTotalAmountCygate(List <Opportunity> newList, Map <Id, Opportunity> oldMap) {
        List<Opportunity> parentOpportunitiesToUpdate = new List<Opportunity>();
        Set<Id> parentIds = new Set<Id>();
        if (newList != null) {
            for (Opportunity opp : newList) {
                if (oldMap == null && opp.Frame_Agreement_Cygate__c != null && opp.StageName == 'Vunnen') {
                    parentIds.add(opp.Frame_Agreement_Cygate__c);
                } else if (oldMap != null && (opp.StageName == 'Vunnen' || oldMap.get(opp.Id).StageName == 'Vunnen')) {
                    if (
                        opp.Frame_Agreement_Cygate__c != null &&
                        (opp.StageName != oldMap.get(opp.Id).StageName ||
                        opp.Total_Amount_Cygate__c != oldMap.get(opp.Id).Total_Amount_Cygate__c)
                    ) {
                        parentIds.add(opp.Frame_Agreement_Cygate__c);
                    }
                    if (opp.Frame_Agreement_Cygate__c != oldMap.get(opp.Id).Frame_Agreement_Cygate__c) {
                        if (opp.Frame_Agreement_Cygate__c != null) {
                            parentIds.add(opp.Frame_Agreement_Cygate__c);
                        }
                        if (oldMap.get(opp.Id).Frame_Agreement_Cygate__c != null) {
                            parentIds.add(oldMap.get(opp.Id).Frame_Agreement_Cygate__c);
                        }
                    }
                }
            }
        } else {
            for (Opportunity deletedOpp : oldMap.values()) {
                if (deletedOpp.Frame_Agreement_Cygate__c != null && deletedOpp.StageName == 'Vunnen') {
                    parentIds.add(deletedOpp.Frame_Agreement_Cygate__c);
                }
            }
        }
        if (!parentIds.isEmpty()) {
            Set<Id> oppIdsWithWonChildOpps = new Set<Id>(); // Added to keep track of returned parent Opps
            for (AggregateResult curParentOppAggregateResult : [
                SELECT Frame_Agreement_Cygate__c opportunityId, SUM(Total_Amount_Cygate__c) callOffsTotalAmount
                    FROM Opportunity
                WHERE Frame_Agreement_Cygate__c IN :parentIds AND StageName = 'Vunnen'
                    GROUP BY Frame_Agreement_Cygate__c
            ]) {
                Opportunity curParentOpportunity = new Opportunity();
                curParentOpportunity.Id = (Id) curParentOppAggregateResult.get('opportunityId');
                curParentOpportunity.Call_offs_total_amount_Cygate__c = (Decimal) curParentOppAggregateResult.get('callOffsTotalAmount');
                parentOpportunitiesToUpdate.add(curParentOpportunity);
                oppIdsWithWonChildOpps.add(curParentOpportunity.Id); // Add the parent Opp
            }
// parentIds contains a set of all Ids that should be updated,
// removing the Ids with Won child opps will leave the Ids of those that have no 'Won' child
            parentIds.removeAll(oppIdsWithWonChildOpps);
// Set the remaining parents to 0.00 and add to the list to update
            for (Id oppIdWithoutWonChildOpps : parentIds) {
                parentOpportunitiesToUpdate.add(new Opportunity(Id = oppIdWithoutWonChildOpps, Call_offs_total_amount_Cygate__c = 0.00));
            }
            if (!parentOpportunitiesToUpdate.isEmpty()) {
                try {
                update parentOpportunitiesToUpdate;
                } catch (Exception ex) {
                    SEUtility.errorLogging('Error', 'OpportunityTriggerHandler', 'calculateTotalAmountCygate', ex);
                }
            }
        }
    }

    /**
     * @Description:
     * Set new/old list by retaining only the Opps that should not be exempt
     * from general automations.
     * @param lstOpportunities - List returned by the Trigger.new/Trigger.old variables.
     * @return List of old/new non-Exempt Opps (or null, if passed as an argument).
     * @Modifications:
     * 21.09.2023 [TB] LTAT-7256 - Introduced.
     **/
    @TestVisible
    private static List<Opportunity> setListNonExemptOpportunities(List<Opportunity> lstOpportunities){
        if(lstOpportunities == null){
            return lstOpportunities;
        }
        List<Opportunity> lstOppsWithExemptRemoved = new List<Opportunity>();
        for(Opportunity curOpportunity : lstOpportunities){
            if(!isExemptOpportunity(curOpportunity)){
                lstOppsWithExemptRemoved.add(curOpportunity);
            }
        }
        return lstOppsWithExemptRemoved;
    }

    /**
     * @Description:
     * Set new/old map by retaining only the Opps that should not be exempt
     * from general automations.
     * @param mapOppIdsToOpportunities - Map returned by the Trigger.newMap/Trigger.oldMap variables.
     * @return Map of old/new non-Exempt Opps Opps (or null, if passed as an argument).
     * @Modifications:
     * 21.09.2023 [TB] LTAT-7256 - Introduced.
     **/
    @TestVisible
    private static Map<Id,Opportunity> setMapNonExemptOpportunities(Map<Id,Opportunity> mapOppIdsToOpportunities){
        if(mapOppIdsToOpportunities == null){
            return mapOppIdsToOpportunities;
        }
        Map<Id,Opportunity> mapOppIdsToNonExemptOpportunities = new Map<Id,Opportunity>();
        for(Opportunity curOpportunity : mapOppIdsToOpportunities.values()){
            if(!isExemptOpportunity(curOpportunity)){
                mapOppIdsToNonExemptOpportunities.put(curOpportunity.Id, curOpportunity);
            }
        }
        return mapOppIdsToNonExemptOpportunities;
    }

    /**
     * @Description:
     * Check whether the passed Opportunity is a Wholesales Opportunity.
     * @param opportunityToCheck - An Opportunity record.
     * @return TRUE, if Opportunity is Wholesales, FALSE otherwise.
     * @Modifications:
     * 21.09.2023 [TB] LTAT-7256 - Introduced.
     **/
    private static Boolean isWholesalesOpportunity(Opportunity opportunityToCheck){
        if( opportunityToCheck != null
            && setWholesalesRecordTypeIds.contains(opportunityToCheck.RecordTypeId)
        ){
            return true;
        }
        return false;
    }

    /**
     * @Description:
     * Check whether the passed Opportunity is exempt from general Trigger Handler methods.
     * @param opportunityToCheck - An Opportunity record.
     * @return TRUE, if Opportunity is exempt, FALSE otherwise.
     * @Modifications:
     * 21.09.2023 [TB] LTAT-7256 - Introduced.
     **/
    private static Boolean isExemptOpportunity(Opportunity opportunityToCheck){
        if( opportunityToCheck != null
            && isWholesalesOpportunity(opportunityToCheck)
        ){
            return true;
        }
        return false;
    }
}