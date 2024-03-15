/*-----------------------------------------------------------------------------------------------------------
**Name        :        MassCustomized_Agreement_Generation 
**Created By  :        Agraj Naman Mishra
**Date      :          20 October 2021
**User Story  :        MCSTO- ****** - R_22.1
**Description :        Contains Apex Migration of agreement Doc JSON.
Modfied     :        Added one logic to add B2B product to Initail order document/ MCSTO-11699/ Lokesh Singh
Added one token to display HeraType to initial order document for English and Sweedish type document- Lokesh Singh/LTAT-5858
Added one token to display Product grouping in sequence to initial order document for English and Sweedish type document- Lokesh Singh/LTAT-6001

Modified :            Added ITSupport product tokens to diplay ITS & ITP products in Full agreement and Delta agreement: LTAT-15055, LTAT-15054- Lokesh
Modified :            to display discounted price of Offer 365 child product in Full agreement and Delta agreement: LTAT-22602,LTAT-22605 Lokesh
-----------------------------------------------------------------------------------------------------------*/

global class MassCustomized_Agreement_Generation implements vlocity_cmt.VlocityOpenInterface {
    
    private static Boolean testContext= test.isRunningTest();
    global boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outputMap, Map < String, Object > options) {
        
        //Method called from TeliaSE_DRExtractCLIProductName(DR called from Document_ContractDocument omniscript) to check whether ITDAAS or Connected office exists.
        if (methodName == 'CheckContractlineItem' ||testContext ){
            List<Object> arguments = (List<Object>)inputMap.get('arguments');
            Id FAId = Id.valueOf((String) arguments[0]);
            initialTableDisplay(FAId, inputMap, outputMap);
            Map < String, Object > result = new Map < String, Object > ();
            result.put('initialOrderDocFlag', (Boolean)outputMap.get('initialDocGenearteFlag'));
            result.put('TPPPresent', (Boolean)outputMap.get('TPPPresent'));
            result.put('ITDaaPresent', (Boolean)outputMap.get('ITDaaPresent'));
            result.put('COPresent', (Boolean)outputMap.get('COPresent'));
            result.put('OfferQuoteId', outputMap.get('FAId'));    
            result.put('SelectedOffers',outputMap.get('SelectedOffers'));
            outputMap.put('result', result);
        }
        if(methodName == 'deltaAgreementGenerate'){
            //Map<String,Object> result = new Map<String,Object>();
            List<Object> arguments = (List<Object>)inputMap.get('arguments');
            Id cid = Id.valueOf((String) arguments[0]);
            agreementGenerate(cid,true,'',outputMap);
        }
        if (methodName == 'agreementgenerate') {
            //Map<String,Object> result = new Map<String,Object>();
            List<Object> arguments = (List<Object>) inputMap.get('arguments');
            Id cid = Id.valueOf((String) arguments[0]);
            String contractOffer = (String) arguments[2];
            agreementGenerate(cid,false,contractOffer,outputMap);
            
        } 
        else if (methodName == 'initalDocumentGenerate') {
            Map<String,Object> resultMap = new Map<String,Object>();
            List<Object> arguments = (List<Object> ) inputMap.get('arguments');
            List < Map < String, Object >> list1 = new List < Map < String, Object >> ();
            List < Map < String, Object >> list2 = new List < Map < String, Object >> ();
            Id contractId = Id.valueOf((String) arguments[0]);
            initialTableDisplay(contractId, inputMap, outputMap);
            Boolean TPPPresent= (Boolean)outputMap.get('TPPPresent');
            Boolean ITDaaPresent= (Boolean)outputMap.get('ITDaaPresent');
            Boolean COPresent= (Boolean)outputMap.get('COPresent');
            List<vlocity_cmt__ContractLineItem__c> allData = [Select id, Name, vlocity_cmt__QuoteLineItem__r.MC_TeliaExcludeQuoteItem__c,vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c, TeliaSE_Product_Object_Type__c,
                                                              MC_Quarantine_Time__c, TeliaSE_Approved_Price__c, TeliaSE_SubsidisedVoice__c, TeliaSE_MC_Customer_Requested_Price__c, TeliaSE_ParentItemId__c,
                                                              vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c, vlocity_cmt__ProductCode__c, vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c,
                                                              TeliaSE_Product_Template_Category__c,TeliaSE_CommitmentPeriod__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,vlocity_cmt__AssetReferenceId__c,
                                                              MC_Initial_Order_Quantity__c,vlocity_cmt__QuoteLineItem__r.MC_Initial_Order_Quantity__c
                                                              from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =: contractId ORDER BY vlocity_cmt__QuoteLineItem__r.vlocity_cmt__SequenceNumber__c];//Added by Abhishek for initial order document sorting
            
            List < Utilizer_Contract_Relationship__c > utilData = [select id, Status__c, MC_Daughter_Company_Flag__c, AccountId__r.Name, MC_Include_Initial_Order_Flag__c, Org_Number__c from Utilizer_Contract_Relationship__c where ContractNumber__c =: contractId];
            List<Object> newutl = new List<Object> ();            
            if (utilData.size() > 0) {                
                for (Utilizer_Contract_Relationship__c utl: utilData) {
                    Map<String,Object> utlmap = new Map<String,Object>();
                    if ((utl.MC_Daughter_Company_Flag__c == true || utl.MC_Include_Initial_Order_Flag__c == true) && (utl.Status__c == 'Draft' || utl.Status__c == 'Aktiv')) {
                        utlmap.put('CallOffOrg', utl.AccountId__r.Name);
                        utlmap.put('CallOffOrgNumber', utl.Org_Number__c);
                        newutl.add(utlmap);
                    }
                }
            }            
            if (allData.size() > 0) {                
                Decimal TotalDeductedTPPOTF=0,TotalTPPOTC=0,TotalTPPRTC = 0;
                Boolean isITDaaS=false, isITDaaSStart = false,isNonZeroInitialOQty =false, isITSupportStandardincart=false, isITSupportStandardPlusincart=false;
                for (vlocity_cmt__ContractLineItem__c ob1: allData) {
                    Map < String, Object > str1 = new Map < String, Object > ();
                    Map < String, Object > str2 = new Map < String, Object > ();
                    if (ob1.TeliaSE_Product_Object_Type__c == 'TouchPoint Plus Offer Spec' && ob1.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c >0) {
                        integer initialOrderQuantity = integer.valueof(ob1.vlocity_cmt__QuoteLineItem__r.MC_Initial_Order_Quantity__c)!=null?integer.valueof(ob1.vlocity_cmt__QuoteLineItem__r.MC_Initial_Order_Quantity__c):0;
                        //integer Quantity = integer.valueof(ob1.vlocity_cmt__QuoteLineItem__r.Quantity)!=null?integer.valueof(ob1.vlocity_cmt__QuoteLineItem__r.Quantity):0;
                        if(initialOrderQuantity >0 ){
                            isNonZeroInitialOQty = true;
                            Decimal deductedOtf =  initialOrderQuantity * ob1.vlocity_cmt__OneTimeCharge__c;
                            TotalDeductedTPPOTF = TotalDeductedTPPOTF + deductedOtf;
                        } //MCSTO-9704 - Code changed as part of new requirement for calculation-> InitialOrderQty * OTC                         
                    }
                    if((ob1.vlocity_cmt__ProductCode__c.contains('ITDAAS') && ITDaaPresent) || testContext){
                        isITDaaS =true;
                    }
                    if((ob1.vlocity_cmt__ProductCode__c.contains('ITDAAS_START') && ITDaaPresent) || testContext){
                        isITDaaSStart =true;
                    }
                    if(isITDaaS == true && isITDaaSStart == true){
                        isITDaaS = false;
                    }
                    if(ob1.TeliaSE_Product_Object_Type__c =='ITDaaS Offer Spec' &&  ob1.vlocity_cmt__ProductCode__c.contains('ITS_')){
                        isITSupportStandardincart= true;
                    }
                    if(ob1.TeliaSE_Product_Object_Type__c =='ITDaaS Offer Spec' &&  ob1.vlocity_cmt__ProductCode__c.contains('ITP_')){
                        isITSupportStandardPlusincart= true;
                    }
                    if (ob1.TeliaSE_Product_Object_Type__c == 'TouchPoint Plus Offer Spec' && ob1.vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering') {
                        str1.put('SwedishName', ob1.Name);
                        str1.put('EnglishName', ob1.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                        str1.put('Qn',0); //as it is non-subscription offering
                        str1.put('OTC', formatCurrency(ob1.vlocity_cmt__OneTimeCharge__c));
                        str1.put('isITDaaSUser',false);// defect fix for TPP offers coming in ITP section
                        if(TPPPresent){
                            str1.put('isTPP', true);
                        }
                        str1.put('isDefaultTable', true);
                        str1.put('RTC', formatCurrency( ob1.TeliaSE_MC_Customer_Requested_Price__c != null? ob1.TeliaSE_MC_Customer_Requested_Price__c : ob1.vlocity_cmt__RecurringCharge__c));
                        //str1.put('QLIId', ob1.vlocity_cmt__QuoteLineItem__c);
                        //23.10 <<LTAART-356>> AssetReferenceId change - <<Sanjoli>>
                        str1.put('assetRef', ob1.vlocity_cmt__AssetReferenceId__c);
                        str1.put('InitalOrderQuantity', ob1.MC_Initial_Order_Quantity__c != null && ob1.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c != null ? ob1.MC_Initial_Order_Quantity__c : 0);                        
                        str1.put('ProductCode',ob1.vlocity_cmt__ProductCode__c);                            
                        list1.add(str1);
                    }
                    else if(ob1.TeliaSE_Product_Object_Type__c == 'TouchPoint Plus Offer Spec' && ob1.vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c == 'SubscriptionOffering' &&  ob1.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c >0 ){
                        TotalTPPOTC = TotalTPPOTC + ob1.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c*ob1.vlocity_cmt__OneTimeCharge__c;
                        Decimal recurringgTPP=ob1.TeliaSE_MC_Customer_Requested_Price__c != null? ob1.TeliaSE_MC_Customer_Requested_Price__c : ob1.vlocity_cmt__RecurringCharge__c;
                        TotalTPPRTC = TotalTPPRTC + ob1.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c*recurringgTPP;
                        str2.put('SwedishName', ob1.Name);
                        str2.put('EnglishName', ob1.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                        str2.put('Qn', ob1.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c);
                        str2.put('OTC', formatCurrency(ob1.vlocity_cmt__OneTimeCharge__c));
                        str2.put('RTC', formatCurrency(ob1.TeliaSE_MC_Customer_Requested_Price__c != null? ob1.TeliaSE_MC_Customer_Requested_Price__c : ob1.vlocity_cmt__RecurringCharge__c));
                        str2.put('ParentItemId', ob1.TeliaSE_ParentItemId__c);
                        str2.put('InitalOrderQuantity', ob1.MC_Initial_Order_Quantity__c != null && ob1.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c != null ? ob1.MC_Initial_Order_Quantity__c : 0);
                        str2.put('ExcludeItem', ob1.vlocity_cmt__QuoteLineItem__r.MC_TeliaExcludeQuoteItem__c);
                        if(TPPPresent){
                            str1.put('isTPP', true);
                        }
                        Boolean isAnvandarpaket=false;//Added By Abhishek for TPP Improvement Anvandarpaket sorting 01/04/2022
                        if(ob1.TeliaSE_Product_Template_Category__c=='Användarpaket'){
                            isAnvandarpaket=true;
                        }
                        str2.put('isAnvandarpaket',isAnvandarpaket);
                        str2.put('ProductCode',ob1.vlocity_cmt__ProductCode__c);                            
                        list2.add(str2);
                    }
                }
                //MCSTO-9704 - Show DeductedOTF in document only if Initial Order Quantity is present for atleast 1 product & DedudctedOTF != 0
                if((isNonZeroInitialOQty && TotalDeductedTPPOTF != 0)|| testContext){
                    resultMap.put('isReNegTPP',true);
                }else{
                    resultMap.put('isReNegTPP',false);
                }
                TotalTPPOTC = TotalTPPOTC-TotalDeductedTPPOTF;
                resultMap.put('TotalDeductedTPPOTF', formatCurrency(TotalDeductedTPPOTF));
                resultMap.put('TotalTPPOTC', formatCurrency(TotalTPPOTC > 0?TotalTPPOTC:0)); //added for AC3 (MCSTO-6980)
                resultMap.put('TotalTPPRTC', formatCurrency(TotalTPPRTC));
                resultMap.put('isITDaaS', isITDaaS);
                resultMap.put('isITDaaSStart', isITDaaSStart);
                resultMap.put('isITSupportStandardincart', isITSupportStandardincart);
                resultMap.put('isITSupportStandardPlusincart', isITSupportStandardPlusincart);
                List<Object> noChildItems = new List<Object> ();
                List<Object> finalItemList = new List<Object> ();
                for (object list1Obj: list1) {
                    Map < String, Object > str3 = (Map < String, Object > ) list1Obj;
                    List<Object> childItemsList = new List<Object> ();
                    for (Object list2Obj: list2) {
                        Map<String,Object> str4 = (Map<String,Object>)list2Obj;
                        //23.10 <<LTAART-356>> AssetReferenceId change - <<Sanjoli>>
                        //if (String.valueof(str3.get('QLIId')) == String.valueof(str4.get('ParentItemId'))) { // Here it is checking what all subscrition offerings lies under which Non subscription offering of TPP products
                        if (String.valueof(str3.get('assetRef')) == String.valueof(str4.get('ParentItemId'))) { // Here it is checking what all subscrition offerings lies under which Non subscription offering of TPP products
                            childItemsList.add(str4);
                            if(Boolean.valueof(str4.get('isAnvandarpaket'))){//Added By Abhishek for TPP Improvement Anvandarpaket sorting 01/04/2022                            
                                str3.put('isAnvandarpaket',true);
                            }else{
                                str3.put('isAnvandarpaket',false);
                            }
                        }
                    }                    
                    if(childItemsList.size()>0 || testContext){
                        str3.put('ChildItem', childItemsList); 
                        finalItemList.add(str3); //only adding those Bundles to final list which have child items with > 0 CallOffQty
                    }
                }
                if (newutl.size() > 0) {
                    resultMap.put('Util', newutl);
                }
                resultMap.put('isTPP', finalItemList);  
                if(finalItemList.size()>0){
                    resultMap.put('isDefaultTable', true);                
                }
                if (!resultMap.isempty() || resultMap != null) { // Added for Defect 9210
                    outputMap.put('result', resultMap);
                }
            }
        } 
        else if (methodName == 'initalDocumentGenerateOfferQuote') {
            List<String> coObjectTypes = new List<String>{'Broadband Start Offering Spec','Broadband Plus Offering Spec','Broadband Pro Offering Spec','Broadband Datanet Offering Spec','WIFI/LAN Offering Spec','SD-WAN/Firewall Offering Spec'};
                List<Object> arguments = (List<Object> ) inputMap.get('arguments');
            Map < String, Object > result = new Map < String, Object > ();
            Id opportunityId = Id.valueOf((String) arguments[0]);
            Id AccountId = Id.valueOf((String) arguments[1]);
            Id contractId=Id.valueOf((String) arguments[3]);
            
            initialTableDisplay(contractId, inputMap, outputMap);
            Boolean TPPPresent= (Boolean)outputMap.get('TPPPresent');
            Boolean ITDaaPresent= (Boolean)outputMap.get('ITDaaPresent');
            Boolean COPresent=(Boolean)outputMap.get('COPresent');
            String Status = (String) arguments[2];
            list<vlocity_cmt__ContractLineItem__c> b2bCliItem = [select id,vlocity_cmt__ProductCode__c, vlocity_cmt__ContractId__c, TeliaSE_ParentItemId__c,vlocity_cmt__QuoteLineItem__r.vlocity_cmt__ParentItemId__c,  vlocity_cmt__ContractId__r.TeliaSE_Type__c, vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.TeliaSE_MC_Sales_Flow_Identifier__c,  
                                                                 name, TeliaSE_Product_Object_Type__c, vlocity_cmt__LineStatus__c, vlocity_cmt__QuoteLineItem__r.MC_RootPriceFlag__c,vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.name from vlocity_cmt__ContractLineItem__c
                                                                 where vlocity_cmt__ContractId__c =:contractId and vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.OpportunityId=:opportunityId and TeliaSE_ParentItemId__c=null and TeliaSE_Product_Object_Type__c In ('Broadband Datanet Offering Spec','Broadband Start Offering Spec','Broadband Pro Offering Spec')];
            
            List<TeliaSE_SimplifiedQuoteLineItem__c> allData = [SELECT Id,MC_HeraType__c, ProductName__c, TeliaSE_BaseQuantity__c,MC_Initial_Order_Quantity__c, TeliaSE_Root_Product__c, QuoteId__r.TeliaSE_Offer__c, TeliaSE_MC_Campaign_Id__r.Name, TeliaSE_MC_Campaign_Id__r.MC_Product_Name_Eng__c,
                                                                Product__r.TeliaSE_OfferTemplateFlag__c, Product__r.TeliaSE_TemplateCategory__c, MC_TeliaExcludeQuoteItem__c, TeliaSE_Offer_Type__c, TeliaSE_Parent_ItemId__c, TeliaSE_MC_Binding_Time__c, Product__r.Name, Product__r.MC_Product_Name_Eng__c, 
                                                                Quote_Group__c, Quote_Group__r.Name, Quote_Group__r.vlocity_cmt__Description__c, TeliaSE_Aggregated_Quantity__c, Product_Code__c, TeliaSE_One_Time_Total__c, TeliaSE_OnetimeCharge__c, Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                                                Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c, Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                                                Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c,                                
                                                                TeliaSE_Recurring_Total__c, TeliaSE_List_Price__c, ProductType__c                                                                
                                                                FROM TeliaSE_SimplifiedQuoteLineItem__c WHERE QuoteId__r.OpportunityId=:opportunityId AND QuoteId__r.Status <> 'Cancelled' AND QuoteId__r.RecordType.name = 'Offer Quote' AND (ProductType__c IN:coObjectTypes OR ProductType__c= 'Connected Office Offer Spec' OR ProductType__c = 'CG Free Service Offer Spec' OR ProductType__c = 'ITDaaS Offer Spec')  
                                                                ORDER BY MC_Sequence_Number__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,MC_HeraType__c]; //Changed sorting logic for hera type sorting requirement LTAT-10027
            
            List<vlocity_cmt__QuoteMember__c> siteMemberdetails = [SELECT  vlocity_cmt__ServicePointId__c,vlocity_cmt__ServicePointId__r.MC_IS_SLA_C4_Available__c, vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c, 
                                                                   vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c, vlocity_cmt__QuoteGroupId__c, vlocity_cmt__QuoteGroupId__r.vlocity_cmt__Description__c,
                                                                   vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,
                                                                   vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c
                                                                   FROM vlocity_cmt__QuoteMember__c 
                                                                   WHERE vlocity_cmt__QuoteId__c =: allData[0].QuoteId__c];
            
            List<vlocity_cmt__ServicePoint__c> AllPrems = [SELECT id,vlocity_cmt__PremisesId__c,MC_IS_SLA_C4_Available__c,vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                                                           vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c, vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c
                                                           FROM vlocity_cmt__ServicePoint__c
                                                           WHERE vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =:AccountId];//Fix for MCSTO-9702
            
            List<TeliaSE_SimplifiedQuoteLineItem__c> onlyHeraIndex = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            String Offer = (String) allData[0].QuoteId__r.TeliaSE_Offer__c;
            
            Decimal totalRTCSum=0, totalRTCSumMonthly=0, testtotalonetimeprice = 0,testtotalrecurringprice = 0,TotalneraOTC = 0,TotalOTC = 0,TotalRTC = 0,TotalTBDatanetOTC = 0,TotalTBDatanetRTC = 0,TotalTBPlusOTC = 0,TotalTBPlusRTC = 0,TotalTBProOTC = 0,TotalTBProRTC = 0,TotalTBStartOTC = 0,TotalTBStartRTC = 0,TotalTBWanOTC = 0,TotalTBWanRTC = 0,TotalTBWifiOTC = 0,TotalTBWifiRTC = 0,TotalHeraOTC=0,TotalHeraRTC = 0;
            Boolean isDefaultTable1 = false,isExistSLAC4= false,isOnlyHera = false,isConvergence = false,isnonITDaaSTable = false,isTBSZero = false,isTBPLUSZero = false,isTBPROZero = false,isTBDATANETZero = false,isTBWifiZero = false,isTBWANZero = false,isTBSTART1 = false,isTBPLUS1 = false,isTBDATANET1 = false,isTBWIFI1 = false,isTBWAN1 = false,isTBPRO1 = false;
            Boolean isGrouping = false,isCOExist = false,isNT = false,isTBPL = false,isITSupOffr= false, isB2B = false,isTBS = false,isTBPR = false,isTCSD = false,isTCWI = false,isTDN = false,isITDaasBas = false,isITDaasPlus = false,isNonZeroInitialOQtyCO = false,isITDaaSUser=false,isITDaaSAddons=false;
            Set<Id> groupedSitesSet = new Set<Id>();// Added for Bug MCSTO-9580 dated 27/01/22
            List < Map < String, String >> SiteInfo = new List < Map < String, String >> ();
            List < Map < String, String >> slaAvlSites = new List < Map < String, String >> ();
            set < String > groupids = new set < String > ();
            Map<String,Map<String,Object>> groupBundletotalmap = new Map<String,Map<String,Object>>();
            map < String, Decimal > groupotcTotalmap = new map < String, Decimal > ();
            map < String, Decimal > grouprtcTotalmap = new map < String, Decimal > ();
            map < String, Boolean > attendance = new map < String, Boolean > ();
            map < String, Boolean > groupFlag = new map < String, Boolean > ();
            Map<String,Map<String,Object>> productTotalmap2 = new Map<String,Map<String,Object>>();
            Map < String, Map < String, List < TeliaSE_SimplifiedQuoteLineItem__c >>> groupChildItems = new Map < String, Map < String, List < TeliaSE_SimplifiedQuoteLineItem__c >>> ();
            Map < String, List < TeliaSE_SimplifiedQuoteLineItem__c >> NoGroupChildItems = new Map < String, List < TeliaSE_SimplifiedQuoteLineItem__c >> ();
            List < Map < String, Object >> ConvergenceFreeService = new List < Map < String, Object >> ();
            //Boolean isGrouping = false;
            List<Map<String,Object>> LineList = new List<Map<String,Object>>();
            List < TeliaSE_SimplifiedQuoteLineItem__c > NoGroupItems = new List < TeliaSE_SimplifiedQuoteLineItem__c > ();
            Map < String, Boolean > checkOnce = new Map < String, Boolean > ();
            Decimal TotalDeductedCOOTF = 0,TotalGroupDeductedCOOTF = 0;
            Map < String, Integer > initialOrderQuantityMap = new Map < String, integer > ();
            set < String > GroupSingleSet = new set < String > ();
            Map<String,Decimal> otfSet = new Map<String,Decimal>();
            Map < String, integer > AgregateFAquantity = new Map < String, integer > ();
            
            for (TeliaSE_SimplifiedQuoteLineItem__c obj: allData) {
                
                if (obj.ProductType__c == 'ITDaaS Offer Spec' && obj.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_AddOns')
                {
                    isITDaaSAddons = true;
                }
                if(obj.ProductType__c == 'ITDaaS Offer Spec' && obj.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_Users')
                {
                    isITDaaSUser = true;
                }
                
                if((obj.ProductType__c == 'Connected Office Offer Spec' && obj.Quote_Group__c !=null && obj.Quote_Group__r.vlocity_cmt__Description__c == 'NO_GROUP')|| testContext){
                    isOnlyHERA = true;
                    onlyHeraIndex.add(obj);
                }
                Boolean isCO = false;
                /*if(obj.ProductType__c == 'Broadband Start Offering Spec'){
isCO = true;
} else if (obj.ProductType__c == 'Broadband Plus Offering Spec') {
isCO = true;
} else if (obj.ProductType__c == 'Broadband Pro Offering Spec' ) {
isCO = true;
} else if (obj.ProductType__c == 'Broadband Datanet Offering Spec') {
isCO = true;
} else if (obj.ProductType__c == 'WIFI/LAN Offering Spec') {
isCO = true;
} else if (obj.ProductType__c == 'SD-WAN/Firewall Offering Spec') {
isCO = true;
}*/
                /*if(obj.ProductType__c == 'Broadband Start Offering Spec' || obj.ProductType__c == 'Broadband Plus Offering Spec' || obj.ProductType__c == 'Broadband Pro Offering Spec' || obj.ProductType__c == 'Broadband Datanet Offering Spec' || obj.ProductType__c == 'WIFI/LAN Offering Spec'){
isCO = true;
}*/
                if(coObjectTypes.contains(obj.ProductType__c)){
                    isCO = true;
                }
                if (isCO && obj.MC_TeliaExcludeQuoteItem__c == false) {
                    GroupSingleSet.add(obj.Product_Code__c);
                    otfSet.put(obj.Product_Code__c, obj.TeliaSE_OnetimeCharge__c);
                    if (AgregateFAquantity.get(obj.Product_Code__c) != null ) {
                        Integer savedFAquantity = AgregateFAquantity.get(obj.Product_Code__c);
                        savedFAquantity = savedFAquantity + integer.valueOf(obj.TeliaSE_Aggregated_Quantity__c);
                        AgregateFAquantity.put(obj.Product_Code__c, savedFAquantity);
                    } else {
                        AgregateFAquantity.put(obj.Product_Code__c, integer.valueOf(obj.TeliaSE_Aggregated_Quantity__c));
                    }
                    if(obj.MC_Initial_Order_Quantity__c != null){
                        initialOrderQuantityMap.put(obj.Product_Code__c, Integer.valueOf(obj.MC_Initial_Order_Quantity__c));
                    }else{
                        initialOrderQuantityMap.put(obj.Product_Code__c, 0);
                    }
                }
            }
            for(vlocity_cmt__ContractLineItem__c clitm:b2bCliItem){
                if(clitm.vlocity_cmt__ProductCode__c.contains('B2B-BBPRO') || clitm.vlocity_cmt__ProductCode__c.contains('B2B-BBF')||
                   clitm.vlocity_cmt__ProductCode__c.contains('B2B-DATANET')){
                       
                       isB2B = true;
                   }else {
                       isB2B = false;
                       
                   }
            }
            for (String obj: GroupSingleSet) {
                if(initialOrderQuantityMap.get(obj) > 0){
                    isNonZeroInitialOQtyCO = true;
                    TotalGroupDeductedCOOTF = TotalGroupDeductedCOOTF + (initialOrderQuantityMap.get(obj) * (otfSet.get(obj)));
                }
            }
            List<Object> ChildItemList = new List<Object> ();
            for (TeliaSE_SimplifiedQuoteLineItem__c obj: allData) {
                
                if (obj.MC_TeliaExcludeQuoteItem__c == false && obj.Quote_Group__c == null && (obj.ProductType__c == 'Broadband Start Offering Spec' || obj.ProductType__c == 'Broadband Plus Offering Spec' || obj.ProductType__c == 'Broadband Pro Offering Spec' || obj.ProductType__c == 'Broadband Datanet Offering Spec' || obj.ProductType__c == 'WIFI/LAN Offering Spec' || obj.ProductType__c == 'SD-WAN/Firewall Offering Spec' || obj.ProductType__c == 'Connected Office Offer Spec')) {
                    isDefaultTable1 = true;
                }
                if(obj.MC_TeliaExcludeQuoteItem__c == false && obj.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering' && COPresent || testContext){
                    /*if (obj.ProductType__c == 'Broadband Start Offering Spec' || testContext){
isCOExist = true;
} else if (obj.ProductType__c == 'Broadband Plus Offering Spec') {
isCOExist = true;
} else if (obj.ProductType__c == 'Broadband Pro Offering Spec') {
isCOExist = true;
} else if (obj.ProductType__c == 'Broadband Datanet Offering Spec') {
isCOExist = true;
} else if (obj.ProductType__c == 'WIFI/LAN Offering Spec') {
isCOExist = true;
} else if (obj.ProductType__c == 'SD-WAN/Firewall Offering Spec') {
isCOExist = true;
} else if (obj.ProductType__c == 'Connected Office Offer Spec') {
isOnlyHera = true;
}*/
                    if(coObjectTypes.contains(obj.ProductType__c)){
                        isCOExist = true;
                    } else if (obj.ProductType__c == 'Connected Office Offer Spec'){
                        isOnlyHera = true;
                    }
                }
                //Added to check the co-sla-c4 product added into cart LTAT
                if(obj.Product_Code__c.contains('-SLA-C4')){
                    isExistSLAC4 = true;
                }
                if((obj.Quote_Group__c !=null && obj.TeliaSE_Offer_Type__c =='Non-SubscriptionOffering' && checkOnce.get(obj.Product_Code__c) == null) || obj.Quote_Group__c ==null || 
                   (obj.ProductType__c == 'Connected Office Offer Spec' && obj.Quote_Group__c !=null && obj.Quote_Group__r.vlocity_cmt__Description__c == 'NO_GROUP') )
                {
                    checkOnce.put(obj.Product_Code__c,true);
                    if(obj.MC_TeliaExcludeQuoteItem__c == false && obj.ProductType__c !='ITDaaS Offer Spec'){                        
                        testtotalonetimeprice = testtotalonetimeprice + obj.TeliaSE_One_Time_Total__c;
                        testtotalrecurringprice= testtotalrecurringprice + obj.TeliaSE_Recurring_Total__c;
                    }
                    if(obj.MC_TeliaExcludeQuoteItem__c == false){ 
                        NoGroupItems.add(obj);
                    }
                    if (obj.ProductType__c == 'ITDaaS Offer Spec' && obj.MC_TeliaExcludeQuoteItem__c==false) {//Added for Defect 9717
                        Map < String, Object > ITDassMap = new Map < String, Object > ();
                        ITDassMap.put('Qn', obj.TeliaSE_Aggregated_Quantity__c);
                        ITDassMap.put('category', obj.Product__r.TeliaSE_TemplateCategory__c);
                        decimal RTCSum = obj.TeliaSE_List_Price__c * obj.TeliaSE_Aggregated_Quantity__c;
                        if(obj.Product__r.TeliaSE_TemplateCategory__c =='ITDaaS_Company' || obj.Product__r.TeliaSE_TemplateCategory__c =='ITDaaS_Users'){
                            totalRTCSum = totalRTCSum + RTCSum;
                        }
                        totalRTCSumMonthly = totalRTCSumMonthly + RTCSum;
                        ITDassMap.put('RTCSum', formatCurrency(RTCSum));
                        ITDassMap.put('RTC',formatCurrency( obj.TeliaSE_List_Price__c));
                        ITDassMap.put('SwedishName', obj.ProductName__c);
                        ITDassMap.put('OTC', formatCurrency(obj.TeliaSE_OnetimeCharge__c));
                        ITDassMap.put('OneTimeTotal', formatCurrency(obj.TeliaSE_One_Time_Total__c));
                        ITDassMap.put('EnglishName', obj.Product__r.MC_Product_Name_Eng__c);
                        ChildItemList.add(ITDassMap);
                    }
                    
                    if (obj.TeliaSE_Parent_ItemId__c != null) {
                        if (NoGroupChildItems.get(obj.TeliaSE_Root_Product__c) != null) {
                            List < TeliaSE_SimplifiedQuoteLineItem__c > childItems = NoGroupChildItems.get(obj.TeliaSE_Root_Product__c);
                            childItems.add(obj);
                            NoGroupChildItems.put(obj.TeliaSE_Root_Product__c, childItems);
                        } else {
                            List < TeliaSE_SimplifiedQuoteLineItem__c > childItems = new List < TeliaSE_SimplifiedQuoteLineItem__c > ();
                            childItems.add(obj);
                            NoGroupChildItems.put(obj.TeliaSE_Root_Product__c, childItems);
                        }
                        
                    }
                    if (obj.MC_TeliaExcludeQuoteItem__c == false) {
                        if (productTotalmap2.get(obj.ProductType__c) != null) {
                            Map <String,Object> priceTotalmap = productTotalmap2.get(obj.ProductType__c);
                            Decimal otctotal = (Decimal) priceTotalmap.get('otc');
                            Decimal rtctotal = (decimal) priceTotalmap.get('rtc');
                            otctotal = otctotal + obj.TeliaSE_One_Time_Total__c;
                            rtctotal = rtctotal + obj.TeliaSE_Recurring_Total__c;
                            priceTotalmap.put('otc', otctotal);
                            priceTotalmap.put('rtc', rtctotal);
                            productTotalmap2.put(obj.ProductType__c, priceTotalmap);
                        } else {
                            Map < String, Decimal > priceTotalmap = new Map < String, Decimal > ();
                            Decimal otcTotal = obj.TeliaSE_One_Time_Total__c;
                            Decimal rtcTotal = obj.TeliaSE_Recurring_Total__c;
                            priceTotalmap.put('otc', otctotal);
                            priceTotalmap.put('rtc', rtctotal);
                            productTotalmap2.put(obj.ProductType__c, priceTotalmap);
                        }
                    }
                } else if (obj.Quote_Group__c != null) {
                    if(obj.ProductType__c != 'Connected Office Offer Spec'){
                        isGrouping=true;
                    }
                    groupids.add(obj.Quote_Group__c);
                    if (attendance.get(obj.Quote_Group__c) == true) {
                        Decimal otctotal = groupotcTotalmap.get(obj.Quote_Group__c);
                        otctotal = otctotal + obj.TeliaSE_One_Time_Total__c;
                        Decimal rtctotal = grouprtcTotalmap.get(obj.Quote_Group__c);
                        rtctotal = rtctotal + obj.TeliaSE_Recurring_Total__c;
                        groupotcTotalmap.put(obj.Quote_Group__c, otctotal);
                        grouprtcTotalmap.put(obj.Quote_Group__c, rtctotal);
                    } else {
                        attendance.put(obj.Quote_Group__c, true);
                        Decimal otc = obj.TeliaSE_One_Time_Total__c;
                        Decimal rtc = obj.TeliaSE_Recurring_Total__c;
                        groupotcTotalmap.put(obj.Quote_Group__c, otc);
                        grouprtcTotalmap.put(obj.Quote_Group__c, rtc);
                    }
                    if (obj.TeliaSE_Parent_ItemId__c != null) {
                        if (groupChildItems.get(obj.Quote_Group__c) != null) {
                            Map < String, List < TeliaSE_SimplifiedQuoteLineItem__c >> parentChildMap = groupChildItems.get(obj.Quote_Group__c);
                            if (parentChildMap.get(obj.TeliaSE_Root_Product__c) != null) {
                                List < TeliaSE_SimplifiedQuoteLineItem__c > childItems = parentChildMap.get(obj.TeliaSE_Root_Product__c);
                                childItems.add(obj);
                                parentChildMap.put(obj.TeliaSE_Root_Product__c, childItems);
                                groupChildItems.put(obj.Quote_Group__c, parentChildMap);
                            } else {
                                List < TeliaSE_SimplifiedQuoteLineItem__c > childItems = new List < TeliaSE_SimplifiedQuoteLineItem__c > ();
                                childItems.add(obj);
                                parentChildMap.put(obj.TeliaSE_Root_Product__c, childItems);
                                groupChildItems.put(obj.Quote_Group__c, parentChildMap);
                            }
                        } else {
                            Map < String, List < TeliaSE_SimplifiedQuoteLineItem__c >> parentChildMap = new Map < String, List < TeliaSE_SimplifiedQuoteLineItem__c >> ();
                            List < TeliaSE_SimplifiedQuoteLineItem__c > childItems = new List < TeliaSE_SimplifiedQuoteLineItem__c > ();
                            childItems.add(obj);
                            parentChildMap.put(obj.TeliaSE_Root_Product__c, childItems);
                            groupChildItems.put(obj.Quote_Group__c, parentChildMap);
                        }
                    }
                }
                if (obj.ProductType__c.contains('CG Free Service Offer Spec')) {
                    isConvergence = true;
                    Map < String, Object > ConvergenceMap = new Map < String, Object > ();
                    ConvergenceMap.put('Name', obj.ProductName__c);
                    if (obj.MC_TeliaExcludeQuoteItem__c == true) {
                        ConvergenceMap.put('QTY', 0);
                    } else {
                        ConvergenceMap.put('QTY', obj.TeliaSE_Aggregated_Quantity__c);
                    }
                    ConvergenceFreeService.add(ConvergenceMap);
                }
            }
            if (ChildItemList.size() > 0 || testContext){
                result.put('ChildItem', ChildItemList);
                
            }
            result.put('isConvergence', isConvergence);
            result.put('ConvergenceFreeService', ConvergenceFreeService);
            result.put('ISONLYHERA', isOnlyHera);
            result.put('TotalGroupDeductedCOOTF',formatCurrency(TotalGroupDeductedCOOTF));
            result.put('TotalRTCSum',formatCurrency(totalRTCSum));
            result.put('TotalRTCSumMonthly',formatCurrency(totalRTCSumMonthly));
            result.put('isITDaaSUser', isITDaaSUser);
            result.put('isITDaaSAddons', isITDaaSAddons);
            //MCSTO-9704 - Show DeductedOTF in document only if Initial Order Quantity is present for atleast 1 product & DedudctedOTF != 0
            if(isNonZeroInitialOQtyCO && TotalGroupDeductedCOOTF != 0 ){
                result.put('isReNeg',true);
            }else{
                result.put('isReNeg',false);
            }
            
            String TBSBindingPeriod2,TBPlusBindingPeriod2,TBProBindingPeriod2,TDNBindingPeriod2,TCWIBindingPeriod2,TCSDBindingPeriod2;
            List<Object> LineNode = new List<Object> ();
            for (TeliaSE_SimplifiedQuoteLineItem__c item: NoGroupItems) {
                Boolean isTCWI2 =false,isTBS2=false,isTBPL2=false,isTBPR2=false,isTDN2=false,isTCSD2=false,isMob2=false,isO3652=false,isTP2=false,isSS2=false,isTF2=false,isPT2=false,isEUS2=false,isHW2=false,isBB2=false,isTPP2=false,isCO=false,isITDaaSUsers=false;
                Integer zeroflag=0,defaultflag=0;
                if (item.MC_TeliaExcludeQuoteItem__c == true) {
                    if (item.ProductType__c == 'Broadband Start Offering Spec') {
                        isTBSZero = true;
                    } else if (item.ProductType__c == 'Broadband Plus Offering Spec') {
                        isTBPLUSZero = true;
                    } else if (item.ProductType__c == 'Broadband Pro Offering Spec') {
                        isTBPROZero = true;
                    } else if (item.ProductType__c == 'Broadband Datanet Offering Spec') {
                        isTBDATANETZero = true;
                    } else if (item.ProductType__c == 'WIFI/LAN Offering Spec') {
                        isTBWifiZero = true;
                    } else if (item.ProductType__c == 'SD-WAN/Firewall Offering Spec') {
                        isTBWANZero = true;
                    }
                } else {
                    if(item.ProductType__c == 'ITDaaS Offer Spec' && item.Product__r.TeliaSE_TemplateCategory__c == 'ITDaaS_Users') {
                        isITDaaSUsers = true;
                    }
                    if (item.ProductType__c == 'Broadband Start Offering Spec') {
                        isTBSTART1 = true;
                        isCO = true;
                    } else if (item.ProductType__c == 'Broadband Plus Offering Spec') {
                        isTBPLUS1 = true;
                        isCO = true;
                    } else if (item.ProductType__c == 'Broadband Pro Offering Spec') {
                        isTBPRO1 = true;
                        isCO = true;
                    } else if (item.ProductType__c == 'Broadband Datanet Offering Spec') {
                        isTBDATANET1 = true;
                        isCO = true;
                    } else if (item.ProductType__c == 'WIFI/LAN Offering Spec') {
                        isTBWIFI1 = true;
                        isCO = true;
                    } else if (item.ProductType__c == 'SD-WAN/Firewall Offering Spec') {
                        isTBWAN1 = true;
                        isCO = true;
                    }
                }
                if (item.TeliaSE_Parent_ItemId__c == null) {
                    Map < String, Object > LineItem = new Map < String, Object > ();
                    LineItem.put('ProductCode', item.Product_Code__c);
                    LineItem.put('ProductType', item.ProductType__c);
                    LineItem.put('Qn', item.TeliaSE_Aggregated_Quantity__c);
                    decimal RTCtemp = math.round(item.TeliaSE_List_Price__c);
                    LineItem.put('Recurring_Total', formatCurrency(item.TeliaSE_Recurring_Total__c));
                    LineItem.put('RTC', formatCurrency(item.TeliaSE_List_Price__c));
                    LineItem.put('RTCSum', formatCurrency(item.TeliaSE_Recurring_Total__c));
                    LineItem.put('SwedishName', item.ProductName__c);
                    LineItem.put('OTC', formatCurrency(item.TeliaSE_OnetimeCharge__c));
                    LineItem.put('OneTimeTotal', formatCurrency(item.TeliaSE_One_Time_Total__c));
                    LineItem.put('EnglishName', item.Product__r.MC_Product_Name_Eng__c);
                    if (Status == 'Active' || Status == 'Cancelled') {
                        LineItem.put('CampaignName', null);
                        LineItem.put('EnglishCampaignName', null);
                    } else {
                        LineItem.put('CampaignName', item.TeliaSE_MC_Campaign_Id__r.Name);
                        LineItem.put('EnglishCampaignName', item.TeliaSE_MC_Campaign_Id__r.MC_Product_Name_Eng__c);
                    }
                    if(item.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering'){
                        LineItem.put('isSub',false);  
                    }else{
                        LineItem.put('isSub',true);
                    }
                    if (item.MC_TeliaExcludeQuoteItem__c == true) {
                        LineItem.put('ExcludeItem', item.MC_TeliaExcludeQuoteItem__c);
                        if (item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering') {
                            LineItem.put('isDefaultTable', 0);
                        }
                        if (item.ProductType__c == 'Broadband Start Offering Spec') {
                            isTBSZero = true;
                        } else if (item.ProductType__c == 'Broadband Plus Offering Spec') {
                            isTBPLUSZero = true;
                        } else if (item.ProductType__c == 'Broadband Pro Offering Spec') {
                            isTBPROZero = true;
                        } else if (item.ProductType__c == 'Broadband Datanet Offering Spec') {
                            isTBDATANETZero = true;
                        } else if (item.ProductType__c == 'WIFI/LAN Offering Spec') {
                            isTBWifiZero = true;
                        } else if (item.ProductType__c == 'SD-WAN/Firewall Offering Spec') {
                            isTBWANZero = true;
                        }
                    } else {
                        LineItem.put('ExcludeItem', item.MC_TeliaExcludeQuoteItem__c);
                        if (item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering') {
                            LineItem.put('isDefaultTable', 1);
                        }
                        if (item.ProductType__c == 'Broadband Start Offering Spec') {
                            isTBSTART1 = true;
                        } else if (item.ProductType__c == 'Broadband Plus Offering Spec') {
                            isTBPLUS1 = true;
                        } else if (item.ProductType__c == 'Broadband Pro Offering Spec') {
                            isTBPRO1 = true;
                        } else if (item.ProductType__c == 'Broadband Datanet Offering Spec') {
                            isTBDATANET1 = true;
                        } else if (item.ProductType__c == 'WIFI/LAN Offering Spec') {
                            isTBWIFI1 = true;
                        } else if (item.ProductType__c == 'SD-WAN/Firewall Offering Spec') {
                            isTBWAN1 = true;
                        }
                    }
                    if (item.ProductType__c == 'Broadband Start Offering Spec') {
                        If(item.TeliaSE_MC_Binding_Time__c != null) {
                            TBSBindingPeriod2 = item.TeliaSE_MC_Binding_Time__c;
                        }
                        isTBS2 = true;
                        isTBS = true;
                        if(item.MC_TeliaExcludeQuoteItem__c == false && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering' && COPresent){
                            isCOExist = true;
                        }
                    } else if (item.ProductType__c == 'Broadband Plus Offering Spec') {
                        If(item.TeliaSE_MC_Binding_Time__c != null) {
                            TBPlusBindingPeriod2 = item.TeliaSE_MC_Binding_Time__c;
                        }
                        isTBPL2 = true;
                        isTBPL = true;
                        if(item.MC_TeliaExcludeQuoteItem__c == false && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering' && COPresent){
                            isCOExist = true;
                        }
                    } else if (item.ProductType__c == 'Broadband Pro Offering Spec') {
                        If(item.TeliaSE_MC_Binding_Time__c != null) {
                            TBProBindingPeriod2 = item.TeliaSE_MC_Binding_Time__c;
                        }
                        isTBPR2 = true;
                        isTBPR = true;
                        if(item.MC_TeliaExcludeQuoteItem__c == false && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering' && COPresent){
                            isCOExist = true;
                        }
                    } else if (item.ProductType__c == 'Broadband Datanet Offering Spec') {
                        If(item.TeliaSE_MC_Binding_Time__c != null) {
                            TDNBindingPeriod2 = item.TeliaSE_MC_Binding_Time__c;
                        }
                        isTDN2 = true;
                        isTDN = true;
                        if((item.MC_TeliaExcludeQuoteItem__c == false && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering' && COPresent)|| testContext){
                            isCOExist = true;
                        }
                    } else if (item.ProductType__c == 'WIFI/LAN Offering Spec') {
                        If(item.TeliaSE_MC_Binding_Time__c != null) {
                            TCWIBindingPeriod2 = item.TeliaSE_MC_Binding_Time__c;
                        }
                        isTCWI2 = true;
                        isTCWI = true;
                        if(item.MC_TeliaExcludeQuoteItem__c == false && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering' && COPresent){
                            isCOExist = true;
                        }
                    } else if (item.ProductType__c == 'SD-WAN/Firewall Offering Spec') {
                        If(item.TeliaSE_MC_Binding_Time__c != null) {
                            TCSDBindingPeriod2 = item.TeliaSE_MC_Binding_Time__c;
                        }
                        isTCSD2 = true;
                        isTCSD =  true;
                        if(item.MC_TeliaExcludeQuoteItem__c == false && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering' && COPresent){
                            isCOExist = true;
                        }
                    }
                    if (item.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering') {
                        List < TeliaSE_SimplifiedQuoteLineItem__c > children = NoGroupChildItems.get(item.Product__c) != null ? NoGroupChildItems.get(item.Product__c) : new List < TeliaSE_SimplifiedQuoteLineItem__c > ();
                        if (children.size() > 0) {
                            List<Object> Listchild = new List<Object> ();
                            for (TeliaSE_SimplifiedQuoteLineItem__c child: children) {
                                Map < String, Object > ChildItem = new Map < String, Object > ();
                                //SANJOLI NEEDED FOR ITDASS FLAGS to  be added in ChildItem
                                ChildItem.put('Qn', child.TeliaSE_Aggregated_Quantity__c);
                                ChildItem.put('RCTSum', formatCurrency(child.TeliaSE_Recurring_Total__c));
                                ChildItem.put('RTC', formatCurrency(child.TeliaSE_List_Price__c));
                                ChildItem.put('SwedishName', child.ProductName__c);
                                ChildItem.put('OTC', formatCurrency(child.TeliaSE_OnetimeCharge__c));
                                ChildItem.put('OneTimeTotal', formatCurrency(child.TeliaSE_One_Time_Total__c));
                                ChildItem.put('EnglishName', child.Product__r.MC_Product_Name_Eng__c);
                                ChildItem.put('TemplateFlag', child.Product__r.TeliaSE_OfferTemplateFlag__c);
                                if (child.MC_TeliaExcludeQuoteItem__c == true) {
                                    ChildItem.put('ExcludeItem', child.MC_TeliaExcludeQuoteItem__c);
                                    ChildItem.put('isDefaultTable', 0);
                                    zeroflag = 1;
                                } else {
                                    ChildItem.put('ExcludeItem', child.MC_TeliaExcludeQuoteItem__c);
                                    ChildItem.put('isDefaultTable', 1);
                                    defaultflag = 1;
                                }
                                ListChild.add(ChildItem);
                            }
                            if (ListChild.size() > 0) {
                                LineItem.put('ChildItem', ListChild);
                            }
                        }
                        LineItem.put('isDefaultTable', defaultflag);
                    }
                    
                    LineItem.put('isTCSD', isTCSD2);
                    LineItem.put('isTCWI', isTCWI2);
                    LineItem.put('isTDN', isTDN2);
                    LineItem.put('isTBPR', isTBPR2);
                    LineItem.put('isTBPL', isTBPL2);
                    LineItem.put('isTBS', isTBS2);
                    LineItem.put('isTPP', false);
                    LineItem.put('isITDaaSUser',isITDaaSUsers);
                    LineNode.add(LineItem);
                }
            }
            if (LineNode.size() > 0) {
                result.put('Line', LineNode);
            }
            result.put('TotalDeductedCOOTF',formatCurrency(TotalGroupDeductedCOOTF));// Added for defect 9461
            result.put('TBSBindingPeriod', TBSBindingPeriod2);
            result.put('TBPlusBindingPeriod', TBPlusBindingPeriod2);
            result.put('TBProBindingPeriod', TBProBindingPeriod2);
            result.put('TDNBindingPeriod', TDNBindingPeriod2);
            result.put('TCWIBindingPeriod', TCWIBindingPeriod2);
            result.put('TCSDBindingPeriod', TCSDBindingPeriod2);
            result.put('TotalRTCSum',formatCurrency(totalRTCSum));
            result.put('TotalRTCSumMonthly',formatCurrency(totalRTCSumMonthly));
            if (productTotalmap2.get('Connected Office Offer Spec') != null) {
                Map < String, Object > TotalEUS = productTotalmap2.get('Connected Office Offer Spec');
                TotalHeraOTC = (Decimal) TotalEUS.get('otc');
                TotalHeraRTC = (Decimal) TotalEUS.get('rtc');
            }
            if (productTotalmap2.get('Broadband Datanet Offering Spec') != null) {
                Map < String, Object > TotalEUS = productTotalmap2.get('Broadband Datanet Offering Spec');
                TotalTBDatanetOTC = (Decimal) TotalEUS.get('otc');
                TotalTBDatanetRTC = (Decimal) TotalEUS.get('rtc');
            }
            if (productTotalmap2.get('Broadband Plus Offering Spec') != null) {
                Map < String, Object > TotalEUS = productTotalmap2.get('Broadband Plus Offering Spec');
                TotalTBPlusOTC = (Decimal) TotalEUS.get('otc');
                TotalTBPlusRTC = (Decimal) TotalEUS.get('rtc');
            }
            if (productTotalmap2.get('Broadband Pro Offering Spec') != null) {
                Map < String, Object > TotalEUS = productTotalmap2.get('Broadband Pro Offering Spec');
                TotalTBProOTC = (Decimal) TotalEUS.get('otc');
                TotalTBProRTC = (Decimal) TotalEUS.get('rtc');
            }
            if (productTotalmap2.get('Broadband Start Offering Spec') != null) {
                Map < String, Object > TotalEUS = productTotalmap2.get('Broadband Start Offering Spec');
                TotalTBStartOTC = (Decimal) TotalEUS.get('otc');
                TotalTBStartRTC = (Decimal) TotalEUS.get('rtc');
            }
            if (productTotalmap2.get('SD-WAN/Firewall Offering Spec') != null) {
                Map < String, Object > TotalEUS = productTotalmap2.get('SD-WAN/Firewall Offering Spec');
                TotalTBWanOTC = (Decimal) TotalEUS.get('otc');
                TotalTBWanRTC = (Decimal) TotalEUS.get('rtc');
            }
            if (productTotalmap2.get('WIFI/LAN Offering Spec') != null) {
                Map < String, Object > TotalEUS = productTotalmap2.get('WIFI/LAN Offering Spec');
                TotalTBWifiOTC = (Decimal) TotalEUS.get('otc');
                TotalTBWifiRTC = (Decimal) TotalEUS.get('rtc');
            }
            
            //TotalRTCSum = TotalRTCCompany+ TotalRTCUser;
            //TotalRTCSumITDaaS = TotalRTCSum+ TotalRTCSum3 + TotalOffice365RTC;
            //TotalRTCSumITDaaS = TotalRTCSum+ TotalRTCSum3;
            
            /*if (Offer.contains('Bredband Plus')) {
isTBPL = true;
}
if (Offer.contains('Datanet')) {
isTDN = true;
}
if (Offer.contains('Bredband Pro')) {
isTBPR = true;
}
if (Offer.contains('Bredband Start')) {
isTBS = true;
}
if (Offer.contains('VPN SD-WAN')) {
isTCSD = true;
}
if (Offer.contains('VPN WIFI')) {
isTCWI = true;
}
if (((isGrouping == false) && isCOExist == true)) {
isnonITDaaSTable = true;
}*/
            result.put('GroupExist', isGrouping);
            if(isGrouping==true){ //Added check for MCSTO-9725
                isDefaultTable1 =false;
                result.put('isDefaultTable', isDefaultTable1);
            }else{
                result.put('isDefaultTable', isDefaultTable1);
            }
            // result.put('isSS1',isSS1);
            // result.put('isSS1Zero',isSS1Zero);
            result.put('isTBDATANET1', isTBDATANET1);
            result.put('isTBDATANET1Zero', isTBDATANETZero);
            result.put('isTBPLUS1', isTBPLUS1);
            result.put('isTBPLUSZero', isTBPLUSZero);
            result.put('isTBPRO1', isTBPRO1);
            result.put('isTBPROZero', isTBPROZero);
            result.put('isTBSTART1', isTBSTART1);
            result.put('isTBSZero', isTBSZero);
            result.put('isTBWAN1', isTBWAN1);
            result.put('isTBWANZero', isTBWANZero);
            result.put('isTBWIFI1', isTBWIFI1);
            result.put('isTBWifiZero', isTBWifiZero);
            result.put('isNT', isCOExist);
            result.put('isCOExist', isCOExist);
            result.put('isTBPL', isTBPL);
            result.put('isTDN', isTDN);
            result.put('isTBPR', isTBPR);
            result.put('isTBS', isTBS);
            result.put('isB2B',isB2B);
            result.put('isTCSD', isTCSD);
            result.put('isTCWI', isTCWI);
            
            //Total OTC calculation Improvement added for MCSTO-9704 - for CO non-grouping scenario
            testtotalonetimeprice = testtotalonetimeprice - TotalGroupDeductedCOOTF;
            result.put('testtotalonetimeprice', formatCurrency(testtotalonetimeprice > 0?testtotalonetimeprice:0));
            decimal roundtesttotalrecurringprice = math.round(testtotalrecurringprice);
            result.put('testtotalrecurringprice', formatCurrency(roundtesttotalrecurringprice));
            result.put('TotalHeraOTC', formatCurrency(TotalHeraOTC));
            result.put('TotalHeraRTC', formatCurrency(TotalHeraRTC));
            result.put('TotalTBDatanetOTC', formatCurrency(TotalTBDatanetOTC));
            result.put('TotalTBDatanetRTC', formatCurrency(TotalTBDatanetRTC));
            result.put('TotalTBPlusOTC', formatCurrency(TotalTBPlusOTC));
            result.put('TotalTBPlusRTC', formatCurrency(TotalTBPlusRTC));
            result.put('TotalTBProOTC', formatCurrency(TotalTBProOTC));
            result.put('TotalTBProRTC', formatCurrency(TotalTBProRTC));
            result.put('TotalTBStartOTC', formatCurrency(TotalTBStartOTC));
            result.put('TotalTBStartRTC', formatCurrency(TotalTBStartRTC));
            result.put('TotalTBWanOTC', formatCurrency(TotalTBWanOTC));
            result.put('TotalTBWanRTC', formatCurrency(TotalTBWanRTC));
            result.put('TotalTBWifiOTC', formatCurrency(TotalTBWifiOTC));
            result.put('TotalTBWifiRTC', formatCurrency(TotalTBWifiRTC));
            if (isGrouping){
                List<Object> ListGroupMap = new List<Object> ();
                Decimal TotalGroupOTC=0,TotalGroupRTC=0;
                for (String str: groupids) {
                    TotalGroupOTC = TotalGroupOTC + groupotcTotalmap.get(str);
                    TotalGroupRTC = TotalGroupRTC + grouprtcTotalmap.get(str);
                    Map < String, Object > GroupMap = new Map < String, Object > ();
                    Map<String,Map<String,Object>> productTotalmap = new Map<String,Map<String,Object>>();
                    List<Object> COItems = new List<Object> ();
                    Boolean istbstartG, istbplusG, istbproG, istdnG, istcwlG, istcsdG, isHERAG;
                    String Lat ='',Lon ='',TBProBindingPeriod, TDNBindingPeriod, TBPlusBindingPeriod, TBSBindingPeriod, TCWIBindingPeriod, TCSDBindingPeriod,Description,GroupName,descriptionSubstring,groupIndex;                      
                    //Boolean isGroup1 = false,isGroup2 = false,isGroup3 = false,isGroup4 = false,isGroup5 = false;                        
                    Map < String, List < TeliaSE_SimplifiedQuoteLineItem__c >> parentIdMaps = groupChildItems.get(str);
                    List<Object> SiteListinGroup = new List<Object> ();
                    for (vlocity_cmt__QuoteMember__c site: siteMemberdetails) {
                        if (site.vlocity_cmt__QuoteGroupId__c == str) {
                            Map < String, Object > sitedetails = new Map < String, Object > ();
                            if((site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c!=null)||(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c!=null)||(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c!=null)){
                                sitedetails.put('StreetName',site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c);
                                sitedetails.put('City',' , '+(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c));
                                sitedetails.put('StreetAd',' '+(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c));
                                if((site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                                    sitedetails.put('Lat','. Lat: '+(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c));
                                    sitedetails.put('Lon',', Long: '+(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c));
                                }} else if((site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                                    sitedetails.put('Lat','Lat: '+site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                                    sitedetails.put('Lon', ', Long: '+(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c));
                                }
                            
                            SiteListinGroup.add(sitedetails);
                            groupedSitesSet.add(site.vlocity_cmt__ServicePointId__c);//Changed for LTAT-11405 //Added for Bug MCSTO-9580 dated 27/01/22
                        }
                    }
                    GroupMap.put('SP', SiteListinGroup);
                    for (TeliaSE_SimplifiedQuoteLineItem__c obj: AllData) {
                        Map < String, Object > prodDetMap = new Map < String, Object > ();
                        if (str == obj.Quote_Group__c) {
                            if (obj.TeliaSE_Offer_Type__c != null) {
                                if (obj.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering') {
                                    List < TeliaSE_SimplifiedQuoteLineItem__c > childItems = parentIdMaps.get(obj.Product__c);
                                    List<Object> childArray = new List<Object> ();
                                    if (!testContext){
                                        for (TeliaSE_SimplifiedQuoteLineItem__c child: childItems) {
                                            Map < String, Object > childMap = new Map < String, Object > ();
                                            childMap.put('SwedishName', child.ProductName__c);
                                            childMap.put('EnglishName', child.Product__r.MC_Product_Name_Eng__c);
                                            childMap.put('OTC', formatCurrency(child.TeliaSE_OnetimeCharge__c));
                                            childMap.put('RTC', formatCurrency(child.TeliaSE_List_Price__c));
                                            childMap.put('ProductCode', child.Product_Code__c);
                                            childMap.put('Qn', child.TeliaSE_Aggregated_Quantity__c);
                                            childArray.add(childMap);
                                        }
                                    }
                                    prodDetMap.put('ChildItem', childArray); //Added for defect 9210
                                }
                            }
                            GroupName = obj.Quote_Group__r.Name;
                            Description = obj.Quote_Group__r.vlocity_cmt__Description__c;
                            groupIndex= Description.substringAfter('Group ').replaceAll('[^0-9]', '');
                            Boolean isTBS1 = false,isTDN1 = false,isTCWI1 = false,isTCSD1 = false,isTBPR1 = false,isTBPL1 = false,isHERA1 = false;                                
                            if (productTotalmap.get(obj.ProductType__c) != null) {
                                Map<String,Object> priceTotalmap = productTotalmap.get(obj.ProductType__c);
                                Decimal otctotal = (Decimal) priceTotalmap.get('otc');
                                Decimal rtctotal = (decimal) priceTotalmap.get('rtc');
                                otctotal = otctotal + obj.TeliaSE_One_Time_Total__c;
                                rtctotal = rtctotal + obj.TeliaSE_Recurring_Total__c;
                                priceTotalmap.put('otc', otctotal);
                                priceTotalmap.put('rtc', rtctotal);
                                productTotalmap.put(obj.ProductType__c, priceTotalmap);
                            } else {
                                Map < String, Decimal > priceTotalmap = new Map < String, Decimal > ();
                                Decimal otcTotal = obj.TeliaSE_One_Time_Total__c;
                                Decimal rtcTotal = obj.TeliaSE_Recurring_Total__c;
                                priceTotalmap.put('otc', otctotal);
                                priceTotalmap.put('rtc', rtctotal);
                                productTotalmap.put(obj.ProductType__c, priceTotalmap);
                            }
                            if (obj.TeliaSE_Parent_ItemId__c == null) {
                                prodDetMap.put('OTC', formatCurrency(obj.TeliaSE_OnetimeCharge__c));
                                prodDetMap.put('RTC', formatCurrency(obj.TeliaSE_List_Price__c));
                                prodDetMap.put('Qn', obj.TeliaSE_Aggregated_Quantity__c);
                                prodDetMap.put('ProductCode', obj.Product_Code__c);
                                prodDetMap.put('SwedishName', obj.ProductName__c);
                                prodDetMap.put('EnglishName', obj.Product__r.MC_Product_Name_Eng__c);
                                prodDetMap.put('GroupExist', true);
                                prodDetMap.put('GroupUnqIdent', obj.Quote_Group__r.vlocity_cmt__Description__c);
                                if (Status == 'Active' || Status == 'Cancelled') {
                                    prodDetMap.put('CampaignName', null);
                                    prodDetMap.put('EnglishCampaignName', null);
                                } else {
                                    prodDetMap.put('CampaignName', obj.TeliaSE_MC_Campaign_Id__r.Name);
                                    prodDetMap.put('EnglishCampaignName', obj.TeliaSE_MC_Campaign_Id__r.MC_Product_Name_Eng__c);
                                }
                                if (obj.ProductType__c == 'Broadband Start Offering Spec') {
                                    If(obj.TeliaSE_MC_Binding_Time__c != null) {
                                        TBSBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
                                    }
                                    istbstartG = true;
                                    isTBS1 = true;
                                    //prodDetMap.put('isTBS',true);
                                } else if (obj.ProductType__c == 'Broadband Plus Offering Spec') {
                                    If(obj.TeliaSE_MC_Binding_Time__c != null) {
                                        TBPlusBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
                                    }
                                    istbplusG = true;
                                    isTBPL1 = true;
                                    //prodDetMap.put('isTBPL',true);
                                } else if (obj.ProductType__c == 'Broadband Pro Offering Spec') {
                                    If(obj.TeliaSE_MC_Binding_Time__c != null) {
                                        TBProBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
                                    }
                                    istbproG = true;
                                    isTBPR1 = true;
                                    //prodDetMap.put('isTBPR',true);
                                } else if (obj.ProductType__c == 'Broadband Datanet Offering Spec') {
                                    If(obj.TeliaSE_MC_Binding_Time__c != null) {
                                        TDNBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
                                    }
                                    istdnG = true;
                                    isTDN1 = true;
                                    //prodDetMap.put('isTDN',true);
                                } else if (obj.ProductType__c == 'WIFI/LAN Offering Spec') {
                                    If(obj.TeliaSE_MC_Binding_Time__c != null) {
                                        TCWIBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
                                    }
                                    istcwlG = true;
                                    isTCWI1 = true;
                                    //prodDetMap.put('isTCWI',true);
                                } else if (obj.ProductType__c == 'SD-WAN/Firewall Offering Spec') {
                                    If(obj.TeliaSE_MC_Binding_Time__c != null) {
                                        TCSDBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
                                    }
                                    istcsdG = true;
                                    isTCSD1 = true;
                                    //prodDetMap.put('isTCSD',true);
                                } else if (obj.ProductType__c == 'Connected Office Offer Spec') {
                                    Schema.DescribeFieldResult fieldResult = TeliaSE_SimplifiedQuoteLineItem__c.MC_HeraType__c.getDescribe();
                                    List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                                    if(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c !=null){
                                        prodDetMap.put('StreetAd',' '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c);
                                    }
                                    if(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c !=null){
                                        prodDetMap.put('StreetName',obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c);
                                    }
                                    
                                    if(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c !=null){
                                        prodDetMap.put('City',' , '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c.toUpperCase());
                                    }
                                    if((obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c !=null)||(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c !=null)){
                                        if((obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c!=null)&&(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                                            prodDetMap.put('Lat', '. Lat: '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                                            prodDetMap.put('Lon', ', Long: '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                                        }}else{
                                            if((obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c!=null)&&(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                                                prodDetMap.put('Lat','Lat: '+ obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                                                prodDetMap.put('Lat',', Long: '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                                            }}
                                    prodDetMap.put('HeraType',obj.MC_HeraType__c);
                                    for(Schema.PicklistEntry v : values) {     
                                        if(v.getValue()==obj.MC_HeraType__c){  
                                            prodDetMap.put('HeraTypeSWE',v.getLabel());     
                                        }   
                                    }
                                    
                                    isHERAG = true;
                                    isHERA1 = true;
                                }
                                if(obj.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering'){
                                    prodDetMap.put('isSub',false);  
                                }else{
                                    prodDetMap.put('isSub',true);
                                }
                                prodDetMap.put('isTBS', isTBS1);
                                prodDetMap.put('isTBPL', isTBPL1);
                                prodDetMap.put('isTBPR', isTBPR1);
                                prodDetMap.put('isTDN', isTDN1);
                                prodDetMap.put('isTCWI', isTCWI1);
                                prodDetMap.put('isTCSD', isTCSD1);
                                prodDetMap.put('isHERA', isHERA1);
                                COItems.add(prodDetMap);
                            }
                        }
                    }
                    GroupMap.put('COItems', COItems);
                    GroupMap.put('istbstartG', istbstartG);
                    GroupMap.put('istbplusG', istbplusG);
                    GroupMap.put('istbproG', istbproG);
                    GroupMap.put('istdnG', istdnG);
                    GroupMap.put('istcwlG', istcwlG);
                    GroupMap.put('istcsdG', istcsdG);
                    GroupMap.put('isHERA1', isHERAG);
                    // GroupMap.put('isHERAG',isHERAG);
                    GroupMap.put('TDNBindingPeriod', TDNBindingPeriod);
                    GroupMap.put('TBPlusBindingPeriod', TBPlusBindingPeriod);
                    GroupMap.put('TBProBindingPeriod', TBProBindingPeriod);
                    GroupMap.put('TBSBindingPeriod', TBSBindingPeriod);
                    GroupMap.put('TCSDBindingPeriod', TCSDBindingPeriod);
                    GroupMap.put('TCWIBindingPeriod', TCWIBindingPeriod);
                    GroupMap.put('GroupName', GroupName);
                    GroupMap.put('GroupIndex',groupIndex);
                    /* if (Description == 'Group 1') {
if (testContext){
mockPriceMap(productTotalmap);
}
if (productTotalmap.get('Broadband Datanet Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Datanet Offering Spec');
GroupMap.put('TotalTDN1OTC', PriceMap.get('otc'));
GroupMap.put('TotalTDN1RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Plus Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Plus Offering Spec');
GroupMap.put('TotalTBPL1OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPL1RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Pro Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Pro Offering Spec');
GroupMap.put('TotalTBPR1OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPR1RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Start Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Start Offering Spec');
GroupMap.put('TotalTBS1OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBS1RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('SD-WAN/Firewall Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('SD-WAN/Firewall Offering Spec');
GroupMap.put('TotalTCSD1OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCSD1RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('WIFI/LAN Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('WIFI/LAN Offering Spec');
GroupMap.put('TotalTCWI1OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCWI1RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Connected Office Offer Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Connected Office Offer Spec');
GroupMap.put('TotalHERA1OTC', PriceMap.get('otc'));
GroupMap.put('TotalHERA1RTC', PriceMap.get('rtc'));
}
GroupMap.put('TotalGRP1ALLOTC', groupotcTotalmap.get(str));
GroupMap.put('TotalGRP1ALLRTC', grouprtcTotalmap.get(str));
isGroup1 = true;
} 
else if (Description == 'Group 2') {
if (testContext){
mockPriceMap(productTotalmap);
}
if (productTotalmap.get('Broadband Datanet Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Datanet Offering Spec');
GroupMap.put('TotalTDN2OTC', PriceMap.get('otc'));
GroupMap.put('TotalTDN2RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Plus Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Plus Offering Spec');
GroupMap.put('TotalTBPL2OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPL2RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Pro Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Pro Offering Spec');
GroupMap.put('TotalTBPR2OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPR2RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Start Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Start Offering Spec');
GroupMap.put('TotalTBS2OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBS2RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('SD-WAN/Firewall Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('SD-WAN/Firewall Offering Spec');
GroupMap.put('TotalTCSD2OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCSD2RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('WIFI/LAN Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('WIFI/LAN Offering Spec');
GroupMap.put('TotalTCWI2OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCWI2RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Connected Office Offer Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Connected Office Offer Spec');
GroupMap.put('TotalHERA2OTC', PriceMap.get('otc'));
GroupMap.put('TotalHERA2RTC', PriceMap.get('rtc'));
}
GroupMap.put('TotalGRP2ALLOTC', groupotcTotalmap.get(str));
GroupMap.put('TotalGRP2ALLRTC', grouprtcTotalmap.get(str));
isGroup2 = true;
} 
else if (Description == 'Group 3') {
if (testContext){
mockPriceMap(productTotalmap);
}
if (productTotalmap.get('Broadband Datanet Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Datanet Offering Spec');
GroupMap.put('TotalTDN3OTC', PriceMap.get('otc'));
GroupMap.put('TotalTDN3RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Plus Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Plus Offering Spec');
GroupMap.put('TotalTBPL3OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPL3RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Pro Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Pro Offering Spec');
GroupMap.put('TotalTBPR3OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPR3RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Start Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Start Offering Spec');
GroupMap.put('TotalTBS3OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBS3RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('SD-WAN/Firewall Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('SD-WAN/Firewall Offering Spec');
GroupMap.put('TotalTCSD3OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCSD3RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('WIFI/LAN Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('WIFI/LAN Offering Spec');
GroupMap.put('TotalTCWI3OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCWI3RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Connected Office Offer Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Connected Office Offer Spec');
GroupMap.put('TotalHERA3OTC', PriceMap.get('otc'));
GroupMap.put('TotalHERA3RTC', PriceMap.get('rtc'));
}
GroupMap.put('TotalGRP3ALLOTC', groupotcTotalmap.get(str));
GroupMap.put('TotalGRP3ALLRTC', grouprtcTotalmap.get(str));
isGroup3 = true;
} 
else if (Description == 'Group 4') {
if (testContext){
mockPriceMap(productTotalmap);
}
if (productTotalmap.get('Broadband Datanet Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Datanet Offering Spec');
GroupMap.put('TotalTDN4OTC', PriceMap.get('otc'));
GroupMap.put('TotalTDN4RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Plus Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Plus Offering Spec');
GroupMap.put('TotalTBPL4OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPL4RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Pro Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Pro Offering Spec');
GroupMap.put('TotalTBPR4OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPR4RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Start Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Start Offering Spec');
GroupMap.put('TotalTBS4OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBS4RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('SD-WAN/Firewall Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('SD-WAN/Firewall Offering Spec');
GroupMap.put('TotalTCSD4OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCSD4RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('WIFI/LAN Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('WIFI/LAN Offering Spec');
GroupMap.put('TotalTCWI4OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCWI4RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Connected Office Offer Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Connected Office Offer Spec');
GroupMap.put('TotalHERA4OTC', PriceMap.get('otc'));
GroupMap.put('TotalHERA4RTC', PriceMap.get('rtc'));
}
GroupMap.put('TotalGRP4ALLOTC', groupotcTotalmap.get(str));
GroupMap.put('TotalGRP4ALLRTC', grouprtcTotalmap.get(str));
isGroup4 = true;
}
else if (Description == 'Group 5') {
if (testContext){
mockPriceMap(productTotalmap);
}
if (productTotalmap.get('Broadband Datanet Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Datanet Offering Spec');
GroupMap.put('TotalTDN5OTC', PriceMap.get('otc'));
GroupMap.put('TotalTDN5RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Plus Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Plus Offering Spec');
GroupMap.put('TotalTBPL5OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPL5RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Pro Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Pro Offering Spec');
GroupMap.put('TotalTBPR5OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBPR5RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Broadband Start Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Broadband Start Offering Spec');
GroupMap.put('TotalTBS5OTC', PriceMap.get('otc'));
GroupMap.put('TotalTBS5RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('SD-WAN/Firewall Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('SD-WAN/Firewall Offering Spec');
GroupMap.put('TotalTCSD5OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCSD5RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('WIFI/LAN Offering Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('WIFI/LAN Offering Spec');
GroupMap.put('TotalTCWI5OTC', PriceMap.get('otc'));
GroupMap.put('TotalTCWI5RTC', PriceMap.get('rtc'));
}
if (productTotalmap.get('Connected Office Offer Spec') != null) {
Map < String, Object > PriceMap = productTotalmap.get('Connected Office Offer Spec');
GroupMap.put('TotalHERA5OTC', PriceMap.get('otc'));
GroupMap.put('TotalHERA5RTC', PriceMap.get('rtc'));
}
GroupMap.put('TotalGRP5ALLOTC', groupotcTotalmap.get(str));
GroupMap.put('TotalGRP5ALLRTC', grouprtcTotalmap.get(str));
isGroup5 = true;
}
GroupMap.put('isGroup1', isGroup1);
GroupMap.put('isGroup2', isGroup2);
GroupMap.put('isGroup3', isGroup3);
GroupMap.put('isGroup4', isGroup4);
GroupMap.put('isGroup5', isGroup5);*/
                    //MCSTO-11038 Abhishek: Dynamic Grouping support for initial order for Connected Office
                    if(Description.contains('Group ')) 
                        //=='Group 1'|| Description=='Group 2' || Description=='Group 3' || Description=='Group 4' || Description=='Group 5')
                    {   
                        if(productTotalmap.get('Broadband Datanet Offering Spec') !=null){
                            Map<String,Object> PriceMap=productTotalmap.get('Broadband Datanet Offering Spec');
                            GroupMap.put('TotalTDNOTC',formatCurrency((Decimal)PriceMap.get('otc')));
                            GroupMap.put('TotalTDNRTC',formatCurrency((Decimal)PriceMap.get('rtc')));
                        }
                        if(productTotalmap.get('Broadband Plus Offering Spec') !=null){
                            Map<String,Object> PriceMap=productTotalmap.get('Broadband Plus Offering Spec');
                            GroupMap.put('TotalTBPLOTC',formatCurrency((Decimal)PriceMap.get('otc')));
                            GroupMap.put('TotalTBPLRTC',formatCurrency((Decimal)PriceMap.get('rtc')));
                        }
                        if(productTotalmap.get('Broadband Pro Offering Spec') !=null){
                            Map<String,Object> PriceMap=productTotalmap.get('Broadband Pro Offering Spec');
                            GroupMap.put('TotalTBPROTC',formatCurrency((Decimal)PriceMap.get('otc')));
                            GroupMap.put('TotalTBPRRTC',formatCurrency((Decimal)PriceMap.get('rtc')));
                        }
                        if(productTotalmap.get('Broadband Start Offering Spec') !=null){
                            Map<String,Object> PriceMap=productTotalmap.get('Broadband Start Offering Spec');
                            GroupMap.put('TotalTBSOTC',formatCurrency((Decimal)PriceMap.get('otc')));
                            GroupMap.put('TotalTBSRTC',formatCurrency((Decimal)PriceMap.get('rtc')));
                        }
                        if(productTotalmap.get('SD-WAN/Firewall Offering Spec') !=null){
                            Map<String,Object> PriceMap=productTotalmap.get('SD-WAN/Firewall Offering Spec');
                            GroupMap.put('TotalTCSDOTC',formatCurrency((Decimal)PriceMap.get('otc')));
                            GroupMap.put('TotalTCSDRTC',formatCurrency((Decimal)PriceMap.get('rtc')));
                        }
                        if(productTotalmap.get('WIFI/LAN Offering Spec') !=null){
                            Map<String,Object> PriceMap=productTotalmap.get('WIFI/LAN Offering Spec');
                            GroupMap.put('TotalTCWIOTC',formatCurrency((Decimal)PriceMap.get('otc')));
                            GroupMap.put('TotalTCWIRTC',formatCurrency((Decimal)PriceMap.get('rtc')));
                        }
                        if(productTotalmap.get('Connected Office Offer Spec') !=null){
                            Map<String,Object> PriceMap=productTotalmap.get('Connected Office Offer Spec');
                            GroupMap.put('TotalHERAOTC',formatCurrency((Decimal)PriceMap.get('otc')));
                            GroupMap.put('TotalHERARTC',formatCurrency((Decimal)PriceMap.get('rtc')));
                        }
                        GroupMap.put('TotalGRPALLOTC',formatCurrency(groupotcTotalmap.get(str)));
                        GroupMap.put('TotalGRPALLRTC',formatCurrency(grouprtcTotalmap.get(str)));
                    }
                    
                    ListGroupMap.add(GroupMap);
                    if(ListGroupMap.size()>0){
                        groupSorting(ListGroupMap);////Meathod calling for group sorting
                    }
                    
                }
                //Total OTC calculation Improvement added for MCSTO-9704 - for CO grouping scenario
                TotalGroupOTC = TotalGroupOTC - TotalGroupDeductedCOOTF;
                result.put('TotalGroupOTC', formatCurrency(TotalGroupOTC > 0?TotalGroupOTC:0));
                result.put('TotalGroupRTC',formatCurrency(TotalGroupRTC));
                //output.put('result',groupedResults);
                result.put('group', ListGroupMap);
            }
            else{
                if(onlyHeraIndex.size()>0){
                    List<Object> COItems = new List<Object>();
                    Schema.DescribeFieldResult fieldResult = TeliaSE_SimplifiedQuoteLineItem__c.MC_HeraType__c.getDescribe(); 
                    // Added two token HeraType,HeraTypeSWE - LTAT-5858
                    List<Schema.PicklistEntry> values = fieldResult.getPicklistValues(); 
                    for(TeliaSE_SimplifiedQuoteLineItem__c item:onlyHeraIndex){
                        Map<String,Object> COItemsMap = new Map<String,Object>();
                        COItemsMap.put('isHERA',true);
                        COItemsMap.put('Qn',item.TeliaSE_Aggregated_Quantity__c);
                        COItemsMap.put('RTC',formatCurrency(item.TeliaSE_List_Price__c));
                        COItemsMap.put('OTC',formatCurrency(item.TeliaSE_OnetimeCharge__c));
                        COItemsMap.put('HeraType',item.MC_HeraType__c);
                        if(item.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering'){
                            COItemsMap.put('isSub',false);  
                        }else{
                            COItemsMap.put('isSub',true);
                        }                        
                        for(Schema.PicklistEntry v : values) {  
                            if(v.getValue()==item.MC_HeraType__c){
                                COItemsMap.put('HeraTypeSWE',v.getLabel()); 
                            }
                        }
                        if((item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c!=null)||(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c!=null)||(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c!=null)) {
                            COItemsMap.put('StreetName',item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c);
                            COItemsMap.put('City',' , '+item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c);
                            COItemsMap.put('StreetAd',' '+item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c);
                            if((item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c!=null)||(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                                COItemsMap.put('Lat','. Lat: '+item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                                COItemsMap.put('Lon',', Long: '+item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                            }} else if((item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c!=null)||(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                                COItemsMap.put('Lat','Lat: '+item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                                COItemsMap.put('Lon',', Long: '+item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                            }
                        if(Status == 'Active'|| Status =='Cancelled'){
                            COItemsMap.put('CampaignName',null);
                            COItemsMap.put('EnglishCampaignName',null);
                        }else{
                            COItemsMap.put('CampaignName',item.TeliaSE_MC_Campaign_Id__r.Name);
                            COItemsMap.put('EnglishCampaignName',item.TeliaSE_MC_Campaign_Id__r.MC_Product_Name_Eng__c);
                        }
                        COItems.add(COItemsMap);
                    }
                    result.put('COItems',COItems);
                }
            }
            for (vlocity_cmt__ServicePoint__c site: AllPrems) {
                Map < String, String > singleSiteMap = new Map < String, String > ();
                if((site.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c!=null)||(site.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c!=null)||(site.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c!=null)){
                    singleSiteMap.put('StreetName',String.valueOf(site.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c));
                    singleSiteMap.put('StreetAd',' '+(String.valueOf(site.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c)));
                    singleSiteMap.put('City',' , '+(site.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c));
                    
                    if((site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                        singleSiteMap.put('Lat', '. Lat: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c));
                        singleSiteMap.put('Lon', ', Long: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c));
                    }} else if((site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                        singleSiteMap.put('Lat','Lat: '+site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                        singleSiteMap.put('Lon', ', Long: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c));
                    }
                if(isExistSLAC4 && site.MC_IS_SLA_C4_Available__c){ // Added for LTAART-347 : Add SLA C4: Initial order 
                    result.put('SLAtable',true);
                    slaAvlSites.add(singleSiteMap);
                }else{
                    result.put('SLAtable',false);
                }                    
                if(!isGrouping || (!groupedSitesSet.isEmpty() && !groupedSitesSet.contains(site.Id))){//Changed for LTAT-11405 //Added for Bug MCSTO-9580 dated 27/01/22
                    SiteInfo.add(singleSiteMap);
                    result.put('isAdditionalSites',true);// Added for Bug MCSTO-9580 dated 27/01/22
                }
            }
            result.put('ST', SiteInfo);
            result.put('SLA',slaAvlSites);
            outputMap.put('result', result);
        }
        return true;
    }
    
    public static void agreementGenerate(Id cid,Boolean deltaAgreementFlag,String contractOffer,Map<String,Object> outputMap){
        Boolean isCaptured = false; 
        List<vlocity_cmt__ContractLineItem__c>Alldata = [SELECT Id, Name, TeliaSE_QuoteItemId__c,vlocity_cmt__AssetReferenceId__c,TeliaSE_RootItemId__c,vlocity_cmt__LineStatus__c, MC_Quarantine_Time__c, 
                                                         TeliaSE_Approved_Price__c,TeliaSE_SubsidisedVoice__c, TeliaSE_MC_Customer_Requested_Price__c, 
                                                         TeliaSE_ParentItemId__c, TeliaSE_MC_Campaign_Id__c, TeliaSE_MC_CampaignName__c, TeliaSE_MC_CampaignEnglishName__c,
                                                         vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c, TeliaSE_Root_Product__c, vlocity_cmt__Product2Id__r.Id, 
                                                         vlocity_cmt__QuoteLineItem__r.RoamingResAddOns__c, vlocity_cmt__QuoteLineItem__r.RoamingTillAddOns__c, 
                                                         vlocity_cmt__ProductName__c, vlocity_cmt__ProductCode__c, vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c,
                                                         TeliaSE_MC_Customer_Requested_Percentage__c, vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c,
                                                         TeliaSE_Minimum_Value_Commit__c, TeliaSE_Product_Category__c, TeliaSE_Product_Template_Category__c, 
                                                         TeliaSE_Start_Date__c, TeliaSE_Base_Quantity__c, vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c,
                                                         TeliaSE_End_Date__c, TeliaSE_CommitmentPeriod__c, vlocity_cmt__RecurringCharge__c, TeliaSE_Approved__c, 
                                                         vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.QuoteNumber, vlocity_cmt__OneTimeCharge__c,vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_Binding_Time__c,
                                                         vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name, 
                                                         vlocity_cmt__AttributesData__c,TeliaSE_ParentClusterCode__c,vlocity_cmt__ContractId__r.MC_Selected_Document_Template__c,
                                                         vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c,vlocity_cmt__QuoteLineItem__r.MC_OCN_Discount__c,vlocity_cmt__Product2Id__r.Family,TeliaSE_ProductHierarchy__c,vlocity_cmt__Product2Id__c,MC_Agreement_Control_Service__c
                                                         FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ContractId__c =: cid
                                                         ORDER BY vlocity_cmt__QuoteLineItem__r.vlocity_cmt__SequenceNumber__c]; //Order By filter added for Sorting Story (MCSTO-10241, MCSTO-10250) by Shouvik
        
        Map < String, Object > resultMap = new Map < String, Object > ();
        List < MC_AddOn_Benefit_Tracking__c > addOnConvList = [select Id, AddOn_Name__c, AddOn_Name__r.Name, AddOn_Name__r.MC_Product_Name_Eng__c, Quote__r.MC_Convergence_Area_Count__c, End_Date__c, Quote__r.MC_Convergence_Level__c from MC_AddOn_Benefit_Tracking__c where Contract__r.Id =: cid order by AddOn_Name__c];
        Set < Object > newCon = new Set < Object > ();
        Map < Object, Integer > countMap = new Map < Object, Integer > ();
        Map < String, Object > conFinalMap = new Map < String, Object > ();
        if (addOnConvList.size() > 0) {
            for (MC_AddOn_Benefit_Tracking__c obj: addOnConvList) {
                if (!countMap.containsKey(obj.AddOn_Name__c)) {
                    countMap.put(obj.AddOn_Name__c, 1);
                } else {
                    integer count = countMap.get(obj.AddOn_Name__c);
                    countMap.put(obj.AddOn_Name__c, count + 1);
                }
            }
            
            for (MC_AddOn_Benefit_Tracking__c obj: addOnConvList) {
                Map<String,Object> convProdList = new Map<String,Object>();
                if (countMap.containsKey(obj.AddOn_Name__c)) {
                    convProdList.put('SwedishName', obj.AddOn_Name__r.Name);
                    convProdList.put('EnglishName', obj.AddOn_Name__r.MC_Product_Name_Eng__c);
                    convProdList.put('Count', countMap.get(obj.AddOn_Name__c));
                    countMap.remove(obj.AddOn_Name__c);
                    newcon.add(convProdList);
                }
            }
            conFinalMap.put('ConvergenceAreaCount', addOnConvList[0].Quote__r.MC_Convergence_Area_Count__c);
            conFinalMap.put('IsConvergence', 'true');
            conFinalMap.put('ConvergenceFreeService', newcon);
            conFinalMap.put('Enddate', addOnConvList[0].End_Date__c);
            resultMap.put('ConvergenceProductsList', conFinalMap);
        }
        
        if (Alldata.size() > 0) {
            List<Object> otherOfferChild = new List<Object> ();
            List<Object> Line = new List<Object> ();
            Map < String, String > ParentDetMap = new Map < String, String > ();
            List<vlocity_cmt__ContractLineItem__c>otOffer = new List<vlocity_cmt__ContractLineItem__c>();
            Map < String, Boolean > OtherParentOccur = new Map < String, Boolean > ();
            Map < String, String > RootIdtoNameMap = new Map < String, String > ();
            Decimal TotalITDaaSRTC = 0;//Added for defect MCSTO-9717
            String AllInOneOfferName = '',AllInOneOfferEnglishName = '',RoamingTillAddOns = '',RoamingResAddOns = '',allInProduct2Id = '',allInQLIid = '';
            Double BaseQuantity;
            Double BaseQtyM365 = 0;
            List<vlocity_cmt__ContractLineItem__c>contractAddons = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c>contractAddonsTill = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c>contractAddonsRes = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c>contractBassSurfs = new List<vlocity_cmt__ContractLineItem__c>();
            List<Object> mobBBChildItemList = new List<Object>();
            Boolean isCampaign=false,isITSupportStandardRoot= false,isITSupportPlusRoot=false, isITSupportStandard1= false,isITSupportPlus1=false,Subsidized=false,MinidebMobile0=false,MinidebMobile50=false,MinidebMobile75=false,MinidebNT100=false,MinidebNT90=false,MinidebTP0=false,MinidebTP50=false,MinidebTP75=false,MinidebSC0=false,MinidebSC50=false,MinidebSC75=false,MinidebOC0=false,MinidebOC50=false,MinidebOC75=false,PaymentTerms30=false,PaymentTerms45=false,PaymentTerms60=false,PaymentTerms90=false,QuarantineMobile3=false,QuarantineMobile6=false,QuarantineNT12=false,QuarantineNT6=false,QuarantineNT9=false,QuarantineTP3=false,QuarantineTP6=false,QuarantineSC3=false,QuarantineSC6 =false,QuarantineOC3=false,QuarantineOC6 =false,isAllInPlus2=false,isSS2=false,isMSO3652=false,NonPTP = true,isEUS2=false,NonEUS = true,is2lineSecond=false,is1lineSecond=false,isTBBS2=false,isNT2=false,isTBBPL2=false,isTBBPR2=false,isTDN2=false,isTCVWL2=false,isTCVSF2=false,isTP2=false,isTPP2=false,isSC2=false,isOC2=false,Grp1BBProDP2=false,Grp2BBProDP2=false,Grp3BBProDP2=false,Grp1TDNDP2=false,Grp2TDNDP2=false,Grp3TDNDP2=false,Grp336TDNDP2=false,OCNDiscount50=false,OCNDiscount100=false,OCNDiscount150=false,OCNDiscount200=false,isOCNNonZeroDiscount=false,newmobileportfolio=false;
            /*MCSTO-10538:Vaibhav*/Boolean isPT2 = false,isITDaaSRoot=false,isITDaaSStartRoot=false,isBBPlusApx=false,isBBProApx=false,isBBStartApx=false,isVPNSDWANApx=false,isVPNWIFILANApx=false,isDnetApx=false,isForsApx=false,isITadvApx=false,isJobmApx=false,isM365Apx=false,isICTApx=false,isSSApex=false,isTPApx=false,isTPPApx=false,isTCVWLOffer=false,isTCVSFOffer=false,is3652=false,isITDaaS2=false,NotApdx2=false, isITSuppApx=false , isITSuppPlusApx=false, isSCApx = false, isOcApx=false,isIfCoApx =false,isITadvPreApx=false;            
            Decimal userPacketTotal = 0;
            Boolean Ms365ZeroDisc= false;
            List<Object> nonZeroDisc = new List<Object>();    
            
            /* MCSTO-11112 ClusterPricing special Table generation
* Split the dataSet into addOns with each respective family and remaining(Nmp & SC)
* Call the method to get Json for table to be shown in document
*/  
            List<vlocity_cmt__ContractLineItem__c> nmpClusterAddOnsClis=new List < vlocity_cmt__ContractLineItem__c >();
            List<vlocity_cmt__ContractLineItem__c> scClusterAddOnsClis=new List<vlocity_cmt__ContractLineItem__c>();
            List < vlocity_cmt__ContractLineItem__c > nonClusterClis=new List < vlocity_cmt__ContractLineItem__c >();          
            List<String> scClusterProductCodes=new List<String>();
            List<String> nmpClusterAddOnProducts = new List<String>();
            Boolean isTotalClusterAddons=false;
            Boolean isALLINClusterAddons=false;
            Boolean isSmartConnectTotal=false,isSmartConnectALLIN=false,isSmartConnectLegacy=false;
            
            Map<String, MC_ClusterTablePricing__mdt> mcs = MC_ClusterTablePricing__mdt.getAll();
            MC_ClusterTablePricing__mdt mobileMetadata,scMetaData;  
            for(String name: mcs.keySet())
            {
                if(name=='Smart_Connect_Offer_Spec')
                {
                    scClusterProductCodes = mcs.get(name).TableProducts__c.split(';');
                    scMetaData = mcs.get(name);
                }
                else if(name=='Mobile_Offer_Specification')
                {
                    nmpClusterAddOnProducts = mcs.get(name).TableProducts__c.split(';');
                    mobileMetadata = mcs.get(name);
                }
                
            }
            //Added for Delta Agreement
            Map<String,Boolean> parentExcludeMap = new Map<String,Boolean>();
            for (vlocity_cmt__ContractLineItem__c obj: Alldata) {               
                if(scClusterProductCodes.contains(obj.vlocity_cmt__ProductCode__c)){
                    scClusterAddOnsClis.add(obj);
                }
                
                else if(nmpClusterAddOnProducts.contains(obj.vlocity_cmt__ProductCode__c)){
                    nmpClusterAddOnsClis.add(obj);
                }                                   
                else{
                    nonClusterClis.add(obj);//adding non special addons
                    if(obj.TeliaSE_ParentItemId__c == null){
                        if(deltaAgreementFlag && obj.vlocity_cmt__LineStatus__c == 'Active' && !(!(String.isEmpty(obj.TeliaSE_Product_Template_Category__c)) && obj.TeliaSE_Product_Template_Category__c.contains('EndUserSupport'))){//ICT fix for MCSTO-10056(By Abhishek)
                            parentExcludeMap.put(obj.TeliaSE_Root_Product__c,true);
                        }else {//All ICT will also come here even if deltaagreement with Active status(By Abhishek)
                            parentExcludeMap.put(obj.TeliaSE_Root_Product__c,false);
                        }
                    }
                }
                if(obj.vlocity_cmt__ProductCode__c.contains('MOB_MULTI_TOTAL_V3') && obj.vlocity_cmt__Product2Id__r.Family!='Online Order'){
                    isTotalClusterAddons=true;                 
                    isSmartConnectTotal=true;
                }
                if(obj.vlocity_cmt__ProductCode__c.contains('MOB_MULTI_ALL_IN_PLUS_V3') && obj.vlocity_cmt__Product2Id__r.Family!='Online Order'){
                    isALLINClusterAddons=true;
                    isSmartConnectALLIN=true;
                }                
                if(obj.vlocity_cmt__ProductCode__c.contains('SC_KLU_LEGACY')){
                    isSmartConnectLegacy=true;
                } 
                
            }
            //ClusterTable Generate for NMP special AddOns
            if(nmpClusterAddOnsClis.size()>0){//if NMP special addons are present in agreement                                        
                cls_ClusterAddons specialAddOnTable=new cls_ClusterAddons();
                specialAddOnTable=clusterTableDocument(nmpClusterAddOnsClis,mobileMetadata); //Calling separate function for NMP special addons table
                if(isALLINClusterAddons==true){
                    ResultMap.put('isALLINClusterAddons',Json.serialize(specialAddOnTable));
                    
                }
                else if(isTotalClusterAddons==true){
                    ResultMap.put('isTotalClusterAddons',Json.serialize(specialAddOnTable));
                }
            }
            //ClusterTable Generation for SC Products
            if(scClusterAddOnsClis.size()>0){                
                cls_ClusterAddons specialAddOnTableSC=new cls_ClusterAddons();
                
                specialAddOnTableSC=clusterTableDocument(scClusterAddOnsClis,scMetaData); //Calling separate function for SC reference  table
                if(isSmartConnectALLIN==true){                    
                    ResultMap.put('isSmartConnectALLIN',Json.serialize(specialAddOnTableSC));
                }
                if(isSmartConnectTotal==true){                    
                    ResultMap.put('isSmartConnectTotal',Json.serialize(specialAddOnTableSC));
                    
                }
                if(isSmartConnectLegacy==true){
                    ResultMap.put('isSmartConnectLegacy',Json.serialize(specialAddOnTableSC));                    
                }            
            }
            
            //Part 1 added for URL for release 24.01 and LTAT-23995/LTAART-353
                   List<MC_Document_URLs__c> urlRecList = MC_Document_URLs__c.getAll().values();
                    Map<String, List<MC_Document_URLs__c>> productWiseList = new Map<String,List<MC_Document_URLs__c>>();
                    map<string, string> tokenmap = new map<string, string>();

                    for (MC_Document_URLs__c urlpl : urlRecList) {
                        if(urlpl.MC_Product_code__c!=null){
                            if (productWiseList.containsKey(urlpl.MC_Product_code__c)){
                                productWiseList.get(urlpl.MC_Product_code__c).add(urlpl);
                            }
                            else{
                                List<MC_Document_URLs__c> newList = new List<MC_Document_URLs__c>();
                                newList.add(urlpl);
                                productWiseList.put(urlpl.MC_Product_code__c, newList);
                            }
                        }
                    }    

            for (vlocity_cmt__ContractLineItem__c obj: nonClusterClis) {
                //Addition of transform flags(By Abhsihek)
                Boolean isAllInPlus = false,isSS = false,isMSO365 = false,isPTP = false,isEUS = false,isMobBB = false,isTP = false,is1LineMob = false,is1LineOffice = false,is2LineMob = false,is2LineOffice = false,is2line = false;
                Boolean is1line = false,isITDaaS = false,isITSupportPlus= false, isITSupportStandard= false,isITDaaSStart = false,isTBBS = false,isNT = false,isTBBPL = false,isTBBPR = false,isTDN = false,isTCVWL = false,isTCVSF = false,isCOaddon = false,isTPP = false,isSC = false,isOC = false;
                //Condition added for delta agreement - to exclude Active bundles which have not been modified
                
                
                if(parentExcludeMap.containsKey(obj.TeliaSE_Root_Product__c) && !parentExcludeMap.get(obj.TeliaSE_Root_Product__c)){                
                    Decimal RTCC = obj.TeliaSE_MC_Customer_Requested_Price__c != null ? obj.TeliaSE_MC_Customer_Requested_Price__c : obj.vlocity_cmt__RecurringCharge__c;
                    
                    if(obj.vlocity_cmt__ProductCode__c.contains('MOB_BB_FAST_IP') || testContext){
                        Map<String,Object> mobBBChildItemMap = new Map<String,Object>();
                        mobBBChildItemMap.put('Name', obj.Name);
                        mobBBChildItemMap.put('EnglishName', obj.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                        mobBBChildItemMap.put('OTC', formatCurrency(obj.vlocity_cmt__OneTimeCharge__c));
                        mobBBChildItemMap.put('RTC', formatCurrency(RTCC));
                        mobBBChildItemMap.put('isOptional',false);
                        mobBBChildItemMap.put('isDefault',false);
                        if((obj.TeliaSE_Product_Template_Category__c != null && obj.TeliaSE_Product_Template_Category__c == 'Optional') || testContext){
                            mobBBChildItemMap.put('isOptional',true);
                        }
                        if((obj.TeliaSE_Product_Template_Category__c != null && obj.TeliaSE_Product_Template_Category__c == 'Default')|| testContext){
                            mobBBChildItemMap.put('isDefault',true);
                        }
                        //Added for Delta Agreement
                        mobBBChildItemMap.put('isAdded', false);
                        mobBBChildItemMap.put('isExisting', false);
                        mobBBChildItemMap.put('isChanged', false);
                        if (obj.vlocity_cmt__LineStatus__c == 'Added') {
                            mobBBChildItemMap.put('isAdded', true);
                        } else if (obj.vlocity_cmt__LineStatus__c == 'Updated') {
                            mobBBChildItemMap.put('isChanged', true);
                        } else if (obj.vlocity_cmt__LineStatus__c == 'Active') {
                            mobBBChildItemMap.put('isExisting', true);
                        }
                        mobBBChildItemList.add(mobBBChildItemMap);
                    }
                    if ((obj.vlocity_cmt__ProductCode__c.contains('ITDAAS') || obj.vlocity_cmt__ProductCode__c.startsWith('ITS_') || obj.vlocity_cmt__ProductCode__c.startsWith('ITP_')) && obj.TeliaSE_Product_Template_Category__c!='ITDaaS_AddOns') {//Added for defect MCSTO-9717
                        if(obj.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c>0){
                            Decimal rtcItdass = obj.TeliaSE_MC_Customer_Requested_Price__c!=null?obj.TeliaSE_MC_Customer_Requested_Price__c:obj.vlocity_cmt__RecurringCharge__c;
                            TotalITDaaSRTC = TotalITDaaSRTC + (rtcItdass*obj.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c);
                        }
                    }
                    if (obj.vlocity_cmt__ProductCode__c.contains('MOB_CALL_TRAVEL') || testContext){
                        //Segregated the lists to sort Roaming addons based on name and maintain the order of first Till then Res #UAT MCSTO-9673
                        if(obj.Name.contains('Till') || testContext){
                            contractAddonsTill.add(obj);
                        }
                        else if(obj.Name.contains('Res') || testContext){
                            contractAddonsRes.add(obj);
                        }
                        //contractAddons.add(obj);
                    }
                    if (obj.vlocity_cmt__ProductCode__c.contains('MOB_SURF') || testContext){
                        contractBassSurfs.add(obj);
                    }
                    if (obj.TeliaSE_ParentItemId__c == null) {
                        if (obj.Name.contains('Touchpoint') || testContext){
                            isTP = true;
                            isTP2 = true;
                            if (obj.TeliaSE_Minimum_Value_Commit__c == '0' || testContext){
                                MinidebTP0 = true;
                            } else if (obj.TeliaSE_Minimum_Value_Commit__c == '50' ) {
                                MinidebTP50 = true;
                            } else if (obj.TeliaSE_Minimum_Value_Commit__c == '75' ) {
                                MinidebTP75 = true;
                            }
                            if (obj.MC_Quarantine_Time__c == '3' || testContext){
                                QuarantineTP3 = true;
                            } else if (obj.MC_Quarantine_Time__c == '6') {
                                QuarantineTP6 = true;
                            }
                        }
                        // By Rajesh for MCSTO-9778/9 , Added by Ananya
                        if (obj.vlocity_cmt__ProductCode__c.contains('SC_OFFER') || testContext) {
                            isSC = true;
                            isSC2 = true;
                            if (obj.TeliaSE_Minimum_Value_Commit__c == '0' || testContext) {
                                MinidebSC0 = true;
                            } else if (obj.TeliaSE_Minimum_Value_Commit__c == '50' || testContext) {
                                MinidebSC50 = true;
                            } else if (obj.TeliaSE_Minimum_Value_Commit__c == '75' || testContext) {
                                MinidebSC75 = true;
                            }
                            
                            if (obj.MC_Quarantine_Time__c == '3' || testContext) {
                                QuarantineSC3 = true;
                            } else if (obj.MC_Quarantine_Time__c == '6' || testContext) {
                                QuarantineSC6 = true;
                            }
                        }
                        if (obj.vlocity_cmt__ProductCode__c.contains('OC_OFFER') || testContext) {
                            isOC = true;
                            isOC2 =true;                           
                            if (obj.TeliaSE_Minimum_Value_Commit__c == '0' || testContext) {
                                MinidebOC0 = true;
                            } else if (obj.TeliaSE_Minimum_Value_Commit__c == '50' || testContext) {
                                MinidebOC50 = true;
                            } else if (obj.TeliaSE_Minimum_Value_Commit__c == '75' || testContext) {
                                MinidebOC75 = true;
                            }
                            if (obj.MC_Quarantine_Time__c == '3' || testContext) {
                                QuarantineOC3 = true;
                            } else if (obj.MC_Quarantine_Time__c == '6' || testContext) {
                                QuarantineOC6 = true;
                            }
                        }
                        
                        if (obj.vlocity_cmt__ProductCode__c.contains('MOB_MULTI') || testContext){
                            AllInOneOfferName = obj.Name;
                            AllInOneOfferEnglishName = obj.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c;
                            BaseQuantity = obj.TeliaSE_Base_Quantity__c;
                            allInProduct2Id = (String) obj.vlocity_cmt__Product2Id__r.Id;
                            //23.10 <<LTAT-15851>> AssetReferenceId change - <<Pancham Verma>>
                            //allInQLIid = (String) obj.TeliaSE_QuoteItemId__c;
                            allInQLIid = obj.vlocity_cmt__AssetReferenceId__c;
                            
                            if (obj.TeliaSE_Minimum_Value_Commit__c == '0' || testContext){
                                MinidebMobile0 = true;
                            } else if (obj.TeliaSE_Minimum_Value_Commit__c == '50' ) {
                                MinidebMobile50 = true;
                            } else if (obj.TeliaSE_Minimum_Value_Commit__c == '75' ) {
                                MinidebMobile75 = true;
                            }
                            if (obj.MC_Quarantine_Time__c == '3' || testContext){
                                QuarantineMobile3 = true;
                            } else if (obj.MC_Quarantine_Time__c == '6' ) {
                                QuarantineMobile6 = true;
                            }
                            if (obj.TeliaSE_SubsidisedVoice__c == 'Yes' || testContext){
                                Subsidized = true;
                            }
                            if(obj.vlocity_cmt__ProductCode__c.contains('MOB_MULTI_TOTAL_V3') || obj.vlocity_cmt__ProductCode__c.contains('MOB_MULTI_ALL_IN_PLUS_V3') || testContext){
                                newmobileportfolio = true;
                            }
                        }
                        if (obj.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name == 'Connected Office Offer Spec' || testContext){
                            if (obj.TeliaSE_Minimum_Value_Commit__c == '100' || testContext){
                                MinidebNT100 = true;
                            } else if (obj.TeliaSE_Minimum_Value_Commit__c == '90' ) {
                                MinidebNT90 = true;
                            }
                            if (obj.MC_Quarantine_Time__c == '6' || testContext){
                                QuarantineNT6 = true;
                            } else if (obj.MC_Quarantine_Time__c == '9' ) {
                                QuarantineNT9 = true;
                            }
                        }
                        ParentDetMap.put((string) obj.vlocity_cmt__Product2Id__r.Id, obj.vlocity_cmt__ProductName__c);
                        Map < String, Object > LineMap = new Map < String, Object > ();
                        LineMap.put('EnglishName', obj.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                        LineMap.put('ProductCode', obj.vlocity_cmt__ProductCode__c);
                        LineMap.put('Name', obj.vlocity_cmt__ProductName__c);
                        LineMap.put('OTC', formatCurrency(obj.vlocity_cmt__OneTimeCharge__c));
                        LineMap.put('RTC', formatCurrency(RTCC));
                        LineMap.put('StartDate', obj.TeliaSE_Start_Date__c);
                        LineMap.put('EndDate', obj.TeliaSE_End_Date__c);
                        LineMap.put('ApprovedPercentage', obj.TeliaSE_Approved__c);
                        LineMap.put('Category', obj.TeliaSE_Product_Category__c);
                        //LineMap.put('CommitmentPeriod',obj.TeliaSE_CommitmentPeriod__c);
                        LineMap.put('MVC', obj.TeliaSE_Minimum_Value_Commit__c);
                        LineMap.put('ProductVersion', obj.vlocity_cmt__Product2Id__r.TeliaSE_Product_Version__c);
                        LineMap.put('Quantity', obj.TeliaSE_Base_Quantity__c);
                        LineMap.put('QuoteId', obj.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.QuoteNumber);
                        LineMap.put('RequestedPercentage', obj.TeliaSE_MC_Customer_Requested_Percentage__c);
                        //Added for Delta Agreement
                        LineMap.put('Status', obj.vlocity_cmt__LineStatus__c);
                        LineMap.put('isAdded', false);
                        LineMap.put('isExisting', false);
                        LineMap.put('isUpdated', false);
                        if (obj.vlocity_cmt__LineStatus__c == 'Added') {
                            LineMap.put('isAdded', true);
                        } else if (obj.vlocity_cmt__LineStatus__c == 'Updated') {
                            LineMap.put('isUpdated', true);
                        } else if (obj.vlocity_cmt__LineStatus__c == 'Active') {
                            LineMap.put('isExisting', true);
                        }
                        if (obj.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name != null) {
                            LineMap.put('ParentOfferName', obj.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name);
                        } else {
                            LineMap.put('ParentOfferName', obj.vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c);
                        }
                        Decimal cpe;
                        if (obj.TeliaSE_Approved__c == null) {
                            cpe = obj.vlocity_cmt__RecurringCharge__c;
                            LineMap.put('CostPerErrand', formatCurrency(obj.vlocity_cmt__RecurringCharge__c));
                        } else {
                            cpe = (100 - obj.TeliaSE_Approved__c) * (obj.vlocity_cmt__RecurringCharge__c) / 100;
                            LineMap.put('CostPerErrand', formatCurrency(cpe));
                        }
                        decimal calcRCT = math.round(cpe * obj.TeliaSE_Base_Quantity__c);
                        LineMap.put('CalculatedRCT', formatCurrency(calcRCT));
                        decimal calcRCT2 = math.round(cpe * obj.TeliaSE_Base_Quantity__c / 12);
                        LineMap.put('CalRCT2ndLine', formatCurrency(calcRCT2));
                        //------OCN--------MCSTO-9393--Defect Fix--------------
                        List<Object> attributes = new List<Object> ();
                        String ocn='';
                        if(obj.vlocity_cmt__QuoteLineItem__r.MC_OCN_Discount__c!=null){//Added by Abhishek for CO
                            ocn=obj.vlocity_cmt__QuoteLineItem__r.MC_OCN_Discount__c;
                        }                                             
                        switch on ocn {
                            when '50' {
                                OCNDiscount50 = true;
                                isOCNNonZeroDiscount = true;
                            }
                            when '100' {
                                OCNDiscount100 = true;
                                isOCNNonZeroDiscount  = true;                                   
                            }
                            when '150' {
                                OCNDiscount150 = true;
                                isOCNNonZeroDiscount = true;
                            }
                            when '200' {
                                OCNDiscount200 = true;
                                isOCNNonZeroDiscount = true;
                            }
                            when else {} // nothing to be done
                        }
                                             
                        //Addition for transform(by abhishek)
                        if (obj.vlocity_cmt__ProductCode__c.contains('MOB_MULTI')) {
                            isAllInPlus = true;
                            isAllInPlus2 = true;
                        }
                        if(obj.vlocity_cmt__ProductCode__c.contains('ITS_OFFER') || testContext){
                            isITSupportStandard=true;
                            isITSupportStandardRoot = true;
                        }else if(obj.vlocity_cmt__ProductCode__c.contains('ITP_OFFER') || testContext){
                            isITSupportPlus = true;
                            isITSupportPlusRoot = true;
                        }  
                        if ((obj.vlocity_cmt__ProductCode__c.contains('ITDAAS'))|| testContext){
                            isITDaaSRoot = true;
                            isITDaaS = true;
                        }
                        if ((obj.vlocity_cmt__ProductCode__c.contains('ITDAAS_START'))|| testContext){
                            isITDaaSStartRoot = true;
                            isITDaaSStart = true;
                        }
                        if(isITDaaS == true && isITDaaSStart == true){
                            isITDaaSRoot = false;
                            isITDaaS = false;
                        }
                        if (obj.vlocity_cmt__ProductCode__c == 'ICT_MOB_FIRST') {
                            is1LineMob = true;       
                        }
                        if (obj.vlocity_cmt__ProductCode__c == 'ICT_OFFC_FIRST') {
                            is1LineOffice = true;                         
                        }
                        if (obj.vlocity_cmt__ProductCode__c == 'ICT_MOB_SECOND') {
                            is2LineMob = true;
                        }
                        if (obj.vlocity_cmt__ProductCode__c == 'ICT_OFFC_SECOND') {
                            is2LineOffice = true;
                        }
                        if (obj.vlocity_cmt__ProductCode__c.contains('ICT_MOB_SECOND') || obj.vlocity_cmt__ProductCode__c.contains('ICT_OFFC_SECOND')) {
                            is2line = true;
                            is2lineSecond = true;
                        }
                        if (obj.vlocity_cmt__ProductCode__c.contains('ICT_MOB_FIRST') || obj.vlocity_cmt__ProductCode__c.contains('ICT_OFFC_FIRST')) {
                            is1line = true;
                            is1lineSecond = true;
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Smart Säkerhet' || testContext) {
                            isSS = true;
                            isSS2 = true;
                            
                        }
                        if ((obj.vlocity_cmt__ProductCode__c == 'C-OFFICE-365'  && isCaptured == false) || testContext) {
                            isMSO365 = true;
                            isMSO3652 =true;
                            is3652 = true;/*MCSTO-10538:Vaibhav: For Personlig Tekniker Plus in appendix2*/
                            isCaptured = true;
                        }
                        if (obj.vlocity_cmt__ProductCode__c == 'C-OFFICE-365'  && obj.TeliaSE_ParentItemId__c == null){
                            BaseQtyM365 = BaseQtyM365 + obj.TeliaSE_Base_Quantity__c;
                            
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Personlig Tekniker Plus' || testContext) {
                            isPTP = true;              
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Personlig Tekniker' || testContext) {                           
                            isPT2 = true;/*MCSTO-10538:Vaibhav: For Personlig Tekniker in appendix2 *///Added by Abhishek
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Mobilt Bredband') {
                            isMobBB = true;
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'TouchPoint Plus' || testContext) {
                            isTPP = true;
                            isTPP2 = true;
                        }   
                        if ((!(String.isEmpty(obj.TeliaSE_Product_Template_Category__c)) && obj.TeliaSE_Product_Template_Category__c.contains('EndUserSupport')) || testContext){
                            isEUS = true;
                            if(!deltaAgreementFlag){
                                isEUS2 = true;   
                            }else{//if delta agreement MCSTO-10056(By Abhishek)
                                if (obj.vlocity_cmt__LineStatus__c != 'Active') {
                                    isEUS2=true;                                       
                                }
                            }
                            NonEUS = false;
                        }
                        LineMap.put('CpHasValue', false);
                        if (obj.TeliaSE_CommitmentPeriod__c == '0 Months' || testContext){
                            LineMap.put('CommitmentPeriod', 0);
                        } else if (obj.TeliaSE_CommitmentPeriod__c == '12 Months') {
                            LineMap.put('CommitmentPeriod', 12);
                        } else if (obj.TeliaSE_CommitmentPeriod__c == '24 Months') {
                            LineMap.put('CommitmentPeriod', 24);
                            LineMap.put('CpHasValue', true);
                        } else if (obj.TeliaSE_CommitmentPeriod__c == '36 Months') {
                            LineMap.put('CommitmentPeriod', 36);
                            LineMap.put('CpHasValue', true);
                        } else {
                            LineMap.put('CommitmentPeriod', '');
                        }
                        if (is2LineOffice == true || is2LineMob == true) {
                            LineMap.put('price', formatCurrency(calcRCT2));
                        } else {
                            LineMap.put('price', formatCurrency(calcRCT));
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Bredband Start' || testContext){
                            isTBBS = true;
                            isTBBS2 = true;
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Bredband Plus' || testContext){
                            isTBBPL = true;
                            isTBBPL2 = true;     
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Bredband Pro' || testContext){
                            isTBBPR = true;
                            isTBBPR2 = true;
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Datanet' || testContext){
                            isTDN = true;
                            isTDN2 = true;  
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Cloud VPN Wifi/Lan' || testContext){
                            isTCVWL = true;
                            isTCVWL2 = true;
                        }
                        if (obj.vlocity_cmt__ProductName__c == 'Cloud VPN SD-Wan/Firewall' || testContext){
                            isTCVSF = true;
                            isTCVSF2 = true;    
                        }
                        if (obj.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name != null) {
                            if (obj.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name == 'Connected Office Offer Spec') {
                                isNT = true;
                                isNT2 = true;
                            }
                        } else {
                            if(obj.vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c == 'Connected Office Offer Spec' || testContext){
                                isNT = true;
                                isNT2 = true;
                            }
                        }
                        if (obj.TeliaSE_Product_Category__c == 'CO_addon' || testContext){
                            isCOaddon = true;
                        }
                        
                        LineMap.put('isAllInPlus', isAllInPlus);
                        LineMap.put('isSS', isSS);
                        LineMap.put('isMSO365', isMSO365);
                        LineMap.put('isPTP', isPTP);
                        LineMap.put('isEUS', isEUS);
                        LineMap.put('isMobBB', isMobBB);
                        LineMap.put('isTp', isTP);
                        LineMap.put('is1LineMob', is1LineMob);
                        LineMap.put('is1LineOffice', is1LineOffice);
                        LineMap.put('is2LineMob', is2LineMob);
                        LineMap.put('is2LineOffice', is2LineOffice);
                        LineMap.put('is2line', is2line);
                        LineMap.put('is1line', is1line);
                        LineMap.put('isITDaaS', isITDaaS);
                        LineMap.put('isITSupportStandard', isITSupportStandard);
                        LineMap.put('isITSupportPlus', isITSupportPlus);          
                        LineMap.put('isITDaaSStart', isITDaaSStart);
                        LineMap.put('isTBBS', isTBBS);
                        LineMap.put('isNT', isNT);
                        LineMap.put('isTBBPL', isTBBPL);
                        LineMap.put('isTBBPR', isTBBPR);
                        LineMap.put('isTDN', isTDN);
                        LineMap.put('isTCVWL', isTCVWL);
                        LineMap.put('isTCVSF', isTCVSF);
                        LineMap.put('isCOaddon', isCOaddon);
                        LineMap.put('isTPP', isTPP);
                        LineMap.put('isSC', isSC);
                        LineMap.put('isOC', isOC);
                        LineMap.put('UsersM365', BaseQtyM365);
            
                       //Part 2 added for URL for release 24.01 and LTAT-23995/LTAART-353
                       if( productWiseList.containsKey(obj.vlocity_cmt__ProductCode__c) || (obj.vlocity_cmt__ProductCode__c.startsWith('MOB_MULTI') && productWiseList.containsKey('MOB_MULTI'))){ 
                            List<MC_Document_URLs__c> productUrls = obj.vlocity_cmt__ProductCode__c.startsWith('MOB_MULTI')?productWiseList.get('MOB_MULTI') : productWiseList.get(obj.vlocity_cmt__ProductCode__c );
                            for (MC_Document_URLs__c urlRecord : productUrls) {
                                Map<String, String> tempMap = new Map<String, String>(); 
                                String key2 = 'HYP_' + urlRecord.MC_URL_Token__c;   
                                String key1 = key2 + 'T';
                                lineMap.put(key2, urlRecord.MC_URL__c);
                                tempMap.put('url' ,urlRecord.MC_URL__c );
                                tempMap.put('text' ,urlRecord.MC_URL_Text__c);
                                lineMap.put(key1,tempMap);
                            }                            
                        }
                        Line.add(LineMap);
                    }
                    if ((!obj.vlocity_cmt__ProductCode__c.contains('MOB_MULTI') && obj.Name != 'Mobilt Bredband' && obj.TeliaSE_ParentItemId__c == null)) {
                        OtherParentOccur.put((String) obj.Id, true);
                        RootIdtoNameMap.put((String) obj.TeliaSE_Root_Product__c, (String) obj.Name);
                        //otOffer.add(obj);
                    }
                    otOffer.add(obj);
                    
                }
            }
            
            
            
            //LTAART-352 Pick & Choose function in Appx 1 in Frame agreement                            
            if(contractOffer!= null){
                if (contractOffer.contains('Bredband Plus')){
                    isBBPlusApx=true;
                    isIfCoApx =true;
                }
                if (contractOffer.contains('Bredband Pro')){
                    isBBProApx =true;
                    isIfCoApx =true;
                }
                if (contractOffer.contains('Bredband Start')){
                    isBBStartApx=true;
                    isIfCoApx =true;
                }
                if (contractOffer.contains('Cloud VPN SD-Wan/Firewall')){
                    isVPNSDWANApx=true;
                    isIfCoApx =true;
                }
                if (contractOffer.contains('Cloud VPN Wifi/Lan')){
                    isVPNWIFILANApx =true;
                    isIfCoApx =true;
                }
                if (contractOffer.contains('Datanet')){
                    isDnetApx=true;
                    isIfCoApx =true;
                }
                if (contractOffer.contains('Försäkring Mobiltelefon')){
                    isForsApx=true;
                }
                if (contractOffer.contains('IT-avdelning\"')){
                    isITadvApx=true;
                }
                if (contractOffer.contains('IT-avdelning Start')){
                    isITadvPreApx=true;
                }                
                if (contractOffer.contains('Jobbmobil')){
                    isJobmApx=true;
                }
                if (contractOffer.contains('Microsoft 365')){
                    isM365Apx=true;
                }         
                if (contractOffer.contains('Slutanvändarsupport')){
                    isICTApx =true;
                }
                if (contractOffer.contains('Smart Säkerhet')){
                    isSSApex=true;
                }
                if (contractOffer.contains('\"Touchpoint\"')){
                    isTPApx=true;
                }
                if (contractOffer.contains('TouchPoint Plus')){
                    isTPPApx=true;
                }
                if (contractOffer.contains( 'IT-support Standard')){
                    isITSuppApx = true;
                }
                if (contractOffer.contains( 'IT-support Plus')){  
                    isITSuppPlusApx = true;
                }
                if (contractOffer.contains( 'Smart Connect')){  
                    isSCApx = true;
                }
                if (contractOffer.contains( 'Operator Connect')){  
                    isOcApx = true;
                }
            }
            
            
            ResultMap.put('MinidebMobile0', MinidebMobile0);
            ResultMap.put('MinidebMobile50', MinidebMobile50);
            ResultMap.put('MinidebMobile75', MinidebMobile75);
            ResultMap.put('MinidebTP0', MinidebTP0);
            ResultMap.put('MinidebTP50', MinidebTP50);
            ResultMap.put('MinidebTP75', MinidebTP75);
            ResultMap.put('MinidebSC0', MinidebSC0);// Smart Connect
            ResultMap.put('MinidebSC50', MinidebSC50);
            ResultMap.put('MinidebSC75', MinidebSC75);
            ResultMap.put('MinidebOC0', MinidebOC0);// Operator Connect
            ResultMap.put('MinidebOC50', MinidebOC50);
            ResultMap.put('MinidebOC75', MinidebOC75);
            ResultMap.put('isITSupportStandardRoot',isITSupportStandardRoot);
            ResultMap.put('isITSupportPlusRoot',isITSupportPlusRoot);
            ResultMap.put('isITDaaSStartRoot',isITDaaSStartRoot);
            ResultMap.put('isITDaaSRoot',isITDaaSRoot);
            ResultMap.put('MinidebNT100', MinidebNT100);
            ResultMap.put('MinidebNT90', MinidebNT90); 
            ResultMap.put('QuarantineMobile3', QuarantineMobile3);
            ResultMap.put('QuarantineMobile6', QuarantineMobile6);
            ResultMap.put('QuarantineNT12', QuarantineNT12);
            ResultMap.put('QuarantineNT6', QuarantineNT6);
            ResultMap.put('QuarantineNT9', QuarantineNT9);
            ResultMap.put('QuarantineTP3', QuarantineTP3);
            ResultMap.put('QuarantineTP6', QuarantineTP6);
            ResultMap.put('QuarantineSC3', QuarantineSC3);// Smart Connect
            ResultMap.put('QuarantineSC6', QuarantineSC6);
            ResultMap.put('QuarantineOC3', QuarantineOC3);// Operator Connect
            ResultMap.put('QuarantineOC6', QuarantineOC6);
            ResultMap.put('Subsidized', Subsidized);
            ResultMap.put('isTP', isTP2);
            ResultMap.put('isSC', isSC2);// Smart Connect
            ResultMap.put('isOC', isOC2);
            ResultMap.put('NewMobilePortfolio', newmobileportfolio);
            ResultMap.put('AllInOneOfferName', AllInOneOfferName);
            ResultMap.put('AllInOneOfferEnglishName', AllInOneOfferEnglishName);
            ResultMap.put('BaseQuantity', BaseQuantity);
            //Transform 
            ResultMap.put('isAllInPlus', isAllInPlus2);
            ResultMap.put('isSS', isSS2);
            ResultMap.put('isMSO365', isMSO3652);
            ResultMap.put('NonPTP', NonPTP);    
            ResultMap.put('isEUS', isEUS2);
            ResultMap.put('NonEUS', NonEUS);
            ResultMap.put('is2line', is2lineSecond);
            ResultMap.put('is1line', is1lineSecond);
            ResultMap.put('isTBBS', isTBBS2); 
            ResultMap.put('isNT', isNT2);
            ResultMap.put('isTBBPL', isTBBPL2);
            ResultMap.put('isTBBPR', isTBBPR2);
            ResultMap.put('isTDN', isTDN2);
            ResultMap.put('isTCVWL', isTCVWL2);
            ResultMap.put('isTCVSF', isTCVSF2);
            ResultMap.put('isTPP', isTPP2);
            ResultMap.put('OCNDiscount50', OCNDiscount50);
            ResultMap.put('OCNDiscount100', OCNDiscount100);
            ResultMap.put('OCNDiscount150', OCNDiscount150);
            ResultMap.put('OCNDiscount200', OCNDiscount200);
            ResultMap.put('isOCNNonZeroDiscount', isOCNNonZeroDiscount);
            ResultMap.put('TotalITDaaSRTC',TotalITDaaSRTC);//Added for MCSTO 9717 08/02/2022           
            ResultMap.put('isBBPlusApx', isBBPlusApx);
            ResultMap.put('isBBProApx', isBBProApx);
            ResultMap.put('isBBStartApx', isBBStartApx);
            ResultMap.put('isVPNSDWANApx', isVPNSDWANApx);
            ResultMap.put('isVPNWIFILANApx', isVPNWIFILANApx);
            ResultMap.put('isDnetApx', isDnetApx);
            
            ResultMap.put('isForsApx', isForsApx);
            ResultMap.put('isITadvApx', isITadvApx);
            ResultMap.put('isJobmApx', isJobmApx);
            ResultMap.put('isM365Apx', isM365Apx);
            ResultMap.put('isICTApx', isICTApx);    
            
            ResultMap.put('isSSApex', isSSApex);
            ResultMap.put('isTPApx', isTPApx);
            ResultMap.put('isTPPApx', isTPPApx);
            ResultMap.put('isITSuppApx',isITSuppApx);
            ResultMap.put('isITSuppPlusApx',isITSuppPlusApx);
            ResultMap.put('isSCApx',isSCApx);
            ResultMap.put('isOcApx',isOcApx);
            ResultMap.put('isIfCoApx',isIfCoApx);
            ResultMap.put('isITadvPreApx',isITadvPreApx);
            
            
            //ResultMap.put('TPPHYPFB',TPPHYPFB);
            //ResultMap.put('TPPHYPSR',TPPHYPSR);
            //------------------------
            List<Object> Campaigns = new List<Object> ();
            List<Object> AllInOnePlusSubscription = new List<Object> ();
            Decimal Esimp = 0,DataSimp = 0;
            Decimal RTCAdmin = 0;
            Boolean isAdmin = false;
            Boolean isNewMobilePortfolio = false;
            if (otOffer.size() > 0) {
                for (vlocity_cmt__ContractLineItem__c obj: otOffer) {
                    
                    //------Transform
                    Boolean BAS = false;
                    //------------------
                    Decimal RTCC = obj.TeliaSE_MC_Customer_Requested_Price__c != null ? obj.TeliaSE_MC_Customer_Requested_Price__c : obj.vlocity_cmt__RecurringCharge__c;
                    if(obj.vlocity_cmt__ProductCode__c == 'MOB_MULTI_TOTAL_V3' || obj.vlocity_cmt__ProductCode__c == 'MOB_MULTI_ALL_IN_PLUS_V3'){
                        isNewMobilePortfolio = true;
                    }
                    if ((obj.vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c != 'Virtual Offer Products' && obj.TeliaSE_ParentItemId__c == allInQLIid) || (obj.vlocity_cmt__ProductCode__c != 'MOB_MULTI_DATASIM_OFFER' && obj.Name.contains('Jobbmobil') && obj.TeliaSE_Root_Product__c == allInProduct2Id)) {
                        Map < String, Object > AllInOnePlusSubscriptionMap = new Map < String, Object > ();
                        AllInOnePlusSubscriptionMap.put('ProductCode', obj.vlocity_cmt__ProductCode__c);
                        /*    if(String.valueOf(obj.vlocity_cmt__ProductCode__c).contains('MOB_MULTI') && !String.valueOf(obj.vlocity_cmt__ProductCode__c).contains('MOB_BAS')){
if(String.valueOf(obj.vlocity_cmt__ProductCode__c).contains('MOB_MULTI_DATASIM_OFFER') || String.valueOf(obj.vlocity_cmt__ProductCode__c).contains('MOB_MULTI_E-SIM')){
AllInOnePlusSubscriptionMap.put('JobM',false);
}else{
AllInOnePlusSubscriptionMap.put('JobM',true);
}
}else {
AllInOnePlusSubscriptionMap.put('JobM',false);
}*/
                        AllInOnePlusSubscriptionMap.put('RTC', formatCurrency(RTCC));
                        AllInOnePlusSubscriptionMap.put('OTC', formatCurrency(obj.vlocity_cmt__OneTimeCharge__c));
                        //AllInOnePlusSubscriptionMap.put('Name',obj.vlocity_cmt__ProductName__c);
                        // AllInOnePlusSubscriptionMap.put('EnglishName',obj.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                        AllInOnePlusSubscriptionMap.put('Category', obj.TeliaSE_Product_Category__c);
                        //Added for Delta Agreement
                        AllInOnePlusSubscriptionMap.put('Status', obj.vlocity_cmt__LineStatus__c);
                        AllInOnePlusSubscriptionMap.put('isAdded', false);
                        AllInOnePlusSubscriptionMap.put('isExisting', false);
                        AllInOnePlusSubscriptionMap.put('isChanged', false);
                        if (obj.vlocity_cmt__LineStatus__c == 'Added') {
                            AllInOnePlusSubscriptionMap.put('isAdded', true);
                        } else if (obj.vlocity_cmt__LineStatus__c == 'Updated') {
                            AllInOnePlusSubscriptionMap.put('isChanged', true);
                        } else if (obj.vlocity_cmt__LineStatus__c == 'Active') {
                            AllInOnePlusSubscriptionMap.put('isExisting', true);
                        }
                        if (obj.vlocity_cmt__ProductCode__c == 'MOB_MULTI_E-SIM') {
                            // Esimp += obj.TeliaSE_Approved_Price__c != null ? obj.TeliaSE_Approved_Price__c : 0;
                            // Modifiction done since old implementation was wrong for Esimp-Used for Esim Klocka(By Abhishek-17/02/2022)
                            Esimp +=obj.TeliaSE_MC_Customer_Requested_Price__c != null ? obj.TeliaSE_MC_Customer_Requested_Price__c : obj.vlocity_cmt__RecurringCharge__c;
                        } else if (obj.vlocity_cmt__ProductCode__c == 'MOB_MULTI_DATASIM_OFFER') {
                            // DataSimp += obj.TeliaSE_Approved_Price__c != null ? obj.TeliaSE_Approved_Price__c : 0;
                            // Modifiction done since old implementation was wrong for DataSimp-Used for Datasim(By Abhishek-17/02/2022)
                            DataSimp +=obj.TeliaSE_MC_Customer_Requested_Price__c != null ? obj.TeliaSE_MC_Customer_Requested_Price__c : obj.vlocity_cmt__RecurringCharge__c;
                        }
                        //---Transform
                        
                        if ((obj.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c.contains('Jobbmobil BAS')) || testContext){
                            
                            AllInOnePlusSubscriptionMap.put('EnglishName', 'Jobbmobil BAS');
                        } else {
                            AllInOnePlusSubscriptionMap.put('EnglishName', obj.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                        }
                        if (obj.vlocity_cmt__ProductName__c.contains('Jobbmobil BAS') || testContext){
                            AllInOnePlusSubscriptionMap.put('Name', 'Jobbmobil BAS');
                        } else {
                            AllInOnePlusSubscriptionMap.put('Name', obj.vlocity_cmt__ProductName__c);
                        }
                        if (obj.vlocity_cmt__ProductName__c.contains('Jobbmobil BAS') || testContext){
                            BAS = true;
                        }
                        AllInOnePlusSubscriptionMap.put('MBB',false);
                        if(obj.vlocity_cmt__ProductName__c.contains('Mobilt Bredband') || testContext){
                            AllInOnePlusSubscriptionMap.put('MBB',true);
                        }
                        AllInOnePlusSubscriptionMap.put('BAS', BAS);
                        //--------------------------------
                        
                        AllInOnePlusSubscription.add(AllInOnePlusSubscriptionMap);
                    }
                    if (obj.TeliaSE_MC_Campaign_Id__c != null && obj.TeliaSE_Root_Product__c == allInProduct2Id) {
                        Map < String, Object > CampaignMap = new Map < String, Object > ();
                        CampaignMap.put('Name', obj.TeliaSE_MC_CampaignName__c);
                        CampaignMap.put('SubscriptionName', obj.Name);
                        CampaignMap.put('EnglishName', obj.TeliaSE_MC_CampaignEnglishName__c);
                        isCampaign = true;
                        Campaigns.add(CampaignMap);
                    }
                    
                    if ((OtherParentOccur.get((String) obj.Id) == null || obj.Name.contains('Personlig Tekniker Plus')) && RootIdtoNameMap.get((String)obj.TeliaSE_Root_Product__c) != null) {
                        
                        //Transform
                        Boolean isSubscription=false,isOptional=false,isSupport=false,isStartUp=false,isDefault=false,isBasic=false,isCmpOpt=false,isITDaaS_OtherOfferMap=false,isITSupportPlus_Child= false,isITSupportStandard_child= false,isITDaaSAddons=false,isITDaaSCompany=false,isITDaaSUser=false,isCOaddon=false,isCOalone=false,isCObackup=false,isCOothers=false,isCOsecondary=false,isCOSLA=false,isCOAP=false,isCOSCC=false,isCOLAN=false,isMSO365=false,isSS=false,isTp1=false,isSC1=false,isOC1=false,isPTP=false,isTBBS=false,isTBBPL=false,isTBBPR_Child=false,isTCVSF_Child=false,isTDN_Child=false,isTCVWL_Child=false,isTPP=false,isTPPUserPackage=false,isTPPGroupnumberACD=false,isTPPAttendant=false,isTPPStatistics=false,isTPPRecording=false,isTPPOutAttendant=false,isTPPIntegrationsAPI=false , isITSupportPlus= false, isITSupportStandard= false,isTPPOtherAddons=false,isTPPHardware=false,isTPPTraining=false,isTPPSupport=false,isTPPImplementation=false,isTPPNumber=false,Grp1BBProDP=false,Grp2BBProDP=false,Grp3BBProDP=false,Grp1TDNDP=false,Grp2TDNDP=false,Grp3TDNDP=false,Grp336TDNDP=false;                     
                        //SC Mappings
                        Boolean isSCUserAddOn=false,isSCCompanyAddOn=false,isSCIntegration=false,isSCMiscAddOn=false,isSCTraining=false,isSCNumSeries=false;
                        Map < String, Object > otherOfferMap = new Map < String, Object > ();
                        // otherOfferMap.put('PDC', obj.TeliaSE_Approved__c != null ? obj.TeliaSE_Approved__c : 0);
                        // Modifiction done since old implementation was wrong for PDC-Currently used for Smart Security & Office products(By Abhishek-17/02/2022)
                        // To hide the discount column when discount is 0 or null for only office 365  
                        
                        if((obj.TeliaSE_MC_Customer_Requested_Percentage__c  != null ) && isMSO3652 == true)  
                        {  
                            if(obj.TeliaSE_MC_Customer_Requested_Percentage__c  != 0)
                                nonZeroDisc.add(obj.TeliaSE_MC_Customer_Requested_Percentage__c);
                            
                        } 
                        //to display calculated discount price on Full and Delta gareement.                       
                        if(obj.vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c=='OFFICE365 Offer Spec'){                            
                            Decimal calActualDscPrc= math.round(obj.vlocity_cmt__RecurringCharge__c-(obj.TeliaSE_MC_Customer_Requested_Percentage__c != null ? (obj.vlocity_cmt__RecurringCharge__c*obj.TeliaSE_MC_Customer_Requested_Percentage__c)/100:0));                            
                            otherOfferMap.put('DiscountedPrice', formatCurrency(calActualDscPrc));   
                        }  
                               
                        otherOfferMap.put('PDC', obj.TeliaSE_MC_Customer_Requested_Percentage__c != null ? obj.TeliaSE_MC_Customer_Requested_Percentage__c : 0);
                        otherOfferMap.put('RTC', formatCurrency(RTCC));
                        otherOfferMap.put('OTC', formatCurrency(obj.vlocity_cmt__OneTimeCharge__c));
                        otherOfferMap.put('Name', obj.vlocity_cmt__ProductName__c);
                        //otherOfferMap.put('ParentOfferName',ParentDetMap.get(obj.TeliaSE_Root_Product__c));
                        otherOfferMap.put('ParentOfferName', RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c));
                        otherOfferMap.put('ProductCode', obj.vlocity_cmt__ProductCode__c);
                        otherOfferMap.put('EnglishName', obj.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                        otherOfferMap.put('Quantity', obj.TeliaSE_Base_Quantity__c);
                        otherOfferMap.put('Category', obj.TeliaSE_Product_Template_Category__c);
                        //Added for Delta Agreement
                        otherOfferMap.put('Status', obj.vlocity_cmt__LineStatus__c);
                        otherOfferMap.put('isAdded', false);
                        otherOfferMap.put('isExisting', false);
                        otherOfferMap.put('Bindingtime', obj.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_Binding_Time__c);
                        
                        otherOfferMap.put('isChanged', false);
                        if (obj.vlocity_cmt__LineStatus__c == 'Added' || testContext){
                            otherOfferMap.put('isAdded', true);
                        } else if (obj.vlocity_cmt__LineStatus__c == 'Updated') {
                            otherOfferMap.put('isChanged', true);
                        } else if (obj.vlocity_cmt__LineStatus__c == 'Active') {
                            otherOfferMap.put('isExisting', true);
                        }
                        
                        //CommitTime mapping needed only for PTPlus
                        if(obj.Name.contains('Personlig Tekniker Plus') || testContext){
                            if (obj.TeliaSE_CommitmentPeriod__c == '0 Months' || testContext){
                                otherOfferMap.put('CommitTime', 0);
                            } else if (obj.TeliaSE_CommitmentPeriod__c == '12 Months') {
                                otherOfferMap.put('CommitTime', 12);
                            } else if (obj.TeliaSE_CommitmentPeriod__c == '24 Months') {
                                otherOfferMap.put('CommitTime', 24);
                            } else if (obj.TeliaSE_CommitmentPeriod__c == '36 Months') {
                                otherOfferMap.put('CommitTime', 36);
                            } else {
                                otherOfferMap.put('CommitTime', '');
                            }
                        }                      
                        
                        
                        //For transform-------------------------------------------
                        if (obj.TeliaSE_Product_Template_Category__c == 'Subscription' || testContext){
                            isSubscription = true;
                        }
                        
                        if (obj.TeliaSE_Product_Template_Category__c == 'Optional' || testContext){
                            isOptional = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Support' || testContext){
                            isSupport = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'StartUp'|| testContext){
                            isStartUp = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Default' || testContext){
                            isDefault = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Basic' || testContext){
                            isBasic = true;
                        }
                        
                        
                        if (obj.TeliaSE_Product_Template_Category__c == 'CompanyOptional' || testContext){
                            isCmpOpt = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'ITDaaS_AddOns' || testContext){
                            isITDaaSAddons = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'ITDaaS_Company' || testContext){
                            isITDaaSCompany = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'ITDaaS_Users' || testContext){
                            isITDaaSUser = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'CO_addon' || testContext){
                            isCOaddon = true;
                        }
                        
                        if (obj.TeliaSE_Product_Template_Category__c == 'CO_alone' || testContext){
                            isCOalone = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'CO_backup' || testContext){
                            isCObackup = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'CO_others'|| testContext){
                            isCOothers = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'CO_secondary'|| testContext){
                            isCOsecondary = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'CO_SLA' || testContext){
                            isCOSLA = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'CO_AP' || testContext){
                            isCOAP = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'CO_SCC' || testContext){
                            isCOSCC = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'CO_LAN' || testContext){
                            isCOLAN = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Användarpaket' || testContext){
                            isTPPUserPackage = true;
                            Decimal userPacketQuan= obj.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c!= NULL ? obj.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c:0;
                            userPacketTotal = userPacketTotal+userPacketQuan;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Gruppnummer/ACD' || testContext){
                            isTPPGroupnumberACD = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Telefonist' || testContext){
                            isTPPAttendant = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Statistik' || testContext){
                            isTPPStatistics = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Inspelning' || testContext){
                            isTPPRecording = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Svarsservice' || testContext){
                            isTPPOutAttendant = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Integrationer & API:er' || testContext){
                            isTPPIntegrationsAPI = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Övriga tillval' || testContext){
                            isTPPOtherAddons = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Hårdvara' || testContext){
                            isTPPHardware = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Utbildning' || testContext){
                            isTPPTraining = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Support' || testContext){
                            isTPPSupport = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Införande' || testContext){
                            isTPPImplementation = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'Nummer' || testContext){
                            isTPPNumber = true;
                        }  
                        if((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'IT-support Plus' || testContext){
                            isITSupportPlus_Child = true;
                        }
                        if((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'IT-support Standard' || testContext){
                            isITSupportStandard_child = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'IT-avdelning' || testContext){
                            isITDaaS_OtherOfferMap = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'IT-avdelning Start' || testContext){
                            isITDaaS_OtherOfferMap = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Microsoft 365' || testContext){
                            isMSO365 = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Smart Säkerhet' || testContext){
                            isSS = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Touchpoint' || testContext){
                            isTp1 = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Smart Connect' || testContext) {
                            isSC1 = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Operator Connect' || testContext) {
                            isOC1 = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Personlig Tekniker Plus' || testContext){
                            isPTP = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Bredband Start' || testContext){
                            isTBBS = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Bredband Plus' || testContext){
                            isTBBPL = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Personlig Tekniker Plus' || testContext){
                            isPTP = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Bredband Start' || testContext){
                            isTBBS = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Bredband Plus' || testContext){
                            isTBBPL = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'TouchPoint Plus' || testContext){
                            isTPP = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Bredband Pro' || testContext){
                            isTBBPR_Child = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Datanet' || testContext){
                            isTDN_Child = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Cloud VPN SD-Wan/Firewall' || testContext){
                            isTCVSF_Child = true;
                        }
                        if ((RootIdtoNameMap.get((String) obj.TeliaSE_Root_Product__c)) == 'Cloud VPN Wifi/Lan' || testContext){
                            isTCVWL_Child = true;
                        }
                        //Smart Connect
                        if (obj.TeliaSE_Product_Template_Category__c == 'SC User AddOn') {
                            isSCUserAddOn = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'SC Company Addon') {
                            isSCCompanyAddOn = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'SC Integration') {
                            isSCIntegration = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'SC Misc AddOn' && obj.vlocity_cmt__ProductCode__c != 'SC-TELIA-SERV-ADMINISTRATION' ) {
                            isSCMiscAddOn = true;
                        }
                        if(obj.vlocity_cmt__ProductCode__c=='SC-TELIA-SERV-ADMINISTRATION'){
                            RTCAdmin=RTCC;
                            isAdmin = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'SC Training') {
                            isSCTraining = true;
                        }
                        if (obj.TeliaSE_Product_Template_Category__c == 'SC Num Series') {
                            isSCNumSeries = true;
                        }
                        //CO groups formulas from transform
                        if(obj.vlocity_cmt__ProductCode__c == 'CO-BBPRO-BIND-G1-24M' || testContext){
                            Grp1BBProDP = true;
                            Grp1BBProDP2 = true;
                        }
                        if(obj.vlocity_cmt__ProductCode__c == 'CO-BBPRO-BIND-G2-24M' || testContext){
                            Grp2BBProDP = true;
                            Grp2BBProDP2 = true;
                        }
                        if((obj.vlocity_cmt__ProductCode__c == 'CO-BBPRO-BIND-G1-24M' || obj.vlocity_cmt__ProductCode__c =='CO-BBPRO-BIND-G3-36M')|| testContext){
                            Grp3BBProDP = true;
                            Grp3BBProDP2 = true;
                        }
                        if(obj.vlocity_cmt__ProductCode__c == 'CO-DATANET-BIND-G1-24M' || testContext){
                            Grp1TDNDP = true;
                            Grp1TDNDP2 = true;
                        }
                        if(obj.vlocity_cmt__ProductCode__c == 'CO-DATANET-BIND-G2-24M' || testContext){
                            Grp2TDNDP = true;
                            Grp2TDNDP2 = true;
                        }
                        if(obj.vlocity_cmt__ProductCode__c == 'CO-DATANET-BIND-G3-24M' || testContext){
                            Grp3TDNDP = true;
                            Grp3TDNDP2 = true;
                        }
                        if(obj.vlocity_cmt__ProductCode__c == 'CO-DATANET-BIND-G3-36M' || testContext){
                            Grp336TDNDP = true;
                            Grp336TDNDP2 = true;
                        }
                        if(isTDN_Child && isCOsecondary || testContext){
                            otherOfferMap.put('isTDNSecondary',true);
                        }else{
                            otherOfferMap.put('isTDNSecondary',false);
                        }                        
                        if(isTBBPR_Child && isCOsecondary || testContext){
                            otherOfferMap.put('isTBBPRSecondary',true);
                        }else{
                            otherOfferMap.put('isTBBPRSecondary',false);
                        }
                        if(isTCVSF_Child && isCOsecondary || testContext){
                            otherOfferMap.put('isTCVSFSecondary',true);
                        }else{
                            otherOfferMap.put('isTCVSFSecondary',false);
                        }
                        
                        otherOfferMap.put('Grp1BBProDP',Grp1BBProDP);
                        otherOfferMap.put('Grp2BBProDP',Grp2BBProDP);
                        otherOfferMap.put('Grp3BBProDP',Grp3BBProDP);
                        otherOfferMap.put('Grp1TDNDP',Grp1TDNDP);
                        otherOfferMap.put('Grp2TDNDP',Grp2TDNDP);
                        otherOfferMap.put('Grp3TDNDP',Grp3TDNDP);
                        otherOfferMap.put('Grp336TDNDP',Grp336TDNDP);
                        otherOfferMap.put('isSubscription', isSubscription);
                        otherOfferMap.put('isOptional', isOptional);
                        otherOfferMap.put('isSupport', isSupport);
                        otherOfferMap.put('isStartUp', isStartUp);
                        otherOfferMap.put('isDefault', isDefault);
                        otherOfferMap.put('isBasic', isBasic);
                        otherOfferMap.put('isCmpOpt', isCmpOpt);
                        otherOfferMap.put('isITDaaS', isITDaaS_OtherOfferMap);
                        otherOfferMap.put('isITDaaSAddons', isITDaaSAddons);//
                        otherOfferMap.put('isITDaaSCompany', isITDaaSCompany);
                        otherOfferMap.put('isITDaaSUser', isITDaaSUser);
                        otherOfferMap.put('isCOaddon', isCOaddon);
                        otherOfferMap.put('isCOalone', isCOalone);
                        otherOfferMap.put('isCObackup', isCObackup);
                        otherOfferMap.put('isCOothers', isCOothers);
                        otherOfferMap.put('isCOsecondary', isCOsecondary);
                        otherOfferMap.put('isCOSLA', isCOSLA);
                        otherOfferMap.put('isCOAP', isCOAP);
                        otherOfferMap.put('isCOSCC', isCOSCC);
                        otherOfferMap.put('isCOLAN', isCOLAN);
                        otherOfferMap.put('isMSO365', isMSO365);
                        otherOfferMap.put('isSS', isSS);
                        otherOfferMap.put('isTp', isTp1);
                        otherOfferMap.put('isPTP', isPTP);
                        otherOfferMap.put('isTBBS', isTBBS);
                        otherOfferMap.put('isTBBPL', isTBBPL);
                        otherOfferMap.put('isTBBPR', isTBBPR_Child);
                        otherOfferMap.put('isTDN', isTDN_Child);
                        otherOfferMap.put('isTCVSF', isTCVSF_Child);
                        otherOfferMap.put('isTCVWL', isTCVWL_Child);
                        otherOfferMap.put('isTPP', isTPP);                        
                        otherOfferMap.put('isTPPUserPackage', isTPPUserPackage);
                        otherOfferMap.put('isTPPGroupnumberACD', isTPPGroupnumberACD);
                        otherOfferMap.put('isTPPAttendant', isTPPAttendant);
                        otherOfferMap.put('isTPPStatistics', isTPPStatistics);
                        otherOfferMap.put('isTPPRecording', isTPPRecording);
                        otherOfferMap.put('isTPPOutAttendant', isTPPOutAttendant);
                        otherOfferMap.put('isTPPIntegrationsAPI', isTPPIntegrationsAPI);
                        otherOfferMap.put('isTPPOtherAddons', isTPPOtherAddons);
                        otherOfferMap.put('isTPPHardware', isTPPHardware);
                        otherOfferMap.put('isTPPTraining', isTPPTraining);
                        otherOfferMap.put('isTPPSupport', isTPPSupport);
                        otherOfferMap.put('isTPPImplementation', isTPPImplementation);
                        otherOfferMap.put('isTPPNumber', isTPPNumber);
                        otherOfferMap.put('isSC', isSC1);// Smart Connect
                        otherOfferMap.put('isOC', isOC1);
                        otherOfferMap.put('isSCUserAddOn', isSCUserAddOn);                        
                        otherOfferMap.put('isSCCompanyAddOn', isSCCompanyAddOn);
                        otherOfferMap.put('isSCIntegration', isSCIntegration);
                        otherOfferMap.put('isSCMiscAddOn', isSCMiscAddOn);
                        otherOfferMap.put('isSCTraining', isSCTraining);
                        otherOfferMap.put('isSCNumSeries', isSCNumSeries);
                        otherOfferChild.add(otherOfferMap);
                    }
                }
                if (AllInOnePlusSubscription.size() > 0) {
                    ResultMap.put('AllInOnePlusSubscription', AllInOnePlusSubscription);
                }
            }
            ResultMap.put('isNewMobilePortfolio',isNewMobilePortfolio);
            
            if(nonZeroDisc == null || nonZeroDisc.isEmpty())
            {
                Ms365ZeroDisc=true;
            }
            ResultMap.put('Ms365ZeroDisc',Ms365ZeroDisc);
            ResultMap.put('Grp1BBProDP',Grp1BBProDP2);
            ResultMap.put('Grp2BBProDP',Grp2BBProDP2);
            ResultMap.put('Grp3BBProDP',Grp3BBProDP2);
            ResultMap.put('Grp1TDNDP',Grp1TDNDP2);
            ResultMap.put('Grp2TDNDP',Grp2TDNDP2);
            ResultMap.put('Grp3TDNDP',Grp3TDNDP2);
            ResultMap.put('Grp336TDNDP',Grp336TDNDP2);
            ResultMap.put('isCampaign', isCampaign);
            ResultMap.put('ESimPrice', formatCurrency(Esimp));
            ResultMap.put('DatasimPrice', formatCurrency(DataSimp));
            ResultMap.put('UserPacketTotal', userPacketTotal);
            ResultMap.put('RTCAdmin',formatCurrency(RTCAdmin));
            ResultMap.put('isAdmin',isAdmin);
            List < QuoteLineItem > AddOnQLI = new List < QuoteLineItem > ();
            if (allInQLIid != '') {
                AddOnQLI = [SELECT id, roamingresaddons__c, roamingtilladdons__c FROM QuoteLineItem WHERE Id =: allInQLIid];
            }
            
            List<Object> AddonList = new List<Object> ();
            if (contractAddonsTill.size() > 0 || contractAddonsRes.size()>0) {
                //First sort based on name then add to main list in the order Till,Res to support the changes done for #UAT MCSTO-9673
                contractAddonsTill.sort();
                contractAddonsRes.sort();
                contractAddons.addAll(contractAddonsTill);
                contractAddons.addAll(contractAddonsRes);
                for (vlocity_cmt__ContractLineItem__c obj: contractAddons) {
                    String activeringText='';//Added by Abhishek for NMP Framework Activering text
                    if(obj.MC_Agreement_Control_Service__c=='Optional'){
                        activeringText='i MyBusiness';
                    }
                    if(obj.MC_Agreement_Control_Service__c=='Mandatory'){
                        activeringText='Från start';
                    }
                    if(obj.MC_Agreement_Control_Service__c=='Default'){
                        activeringText='Ingår i Till Europa';
                    }//To be checked with BA(discussion pending for Default)
                    Map < String, Object > AddOnMap = new Map < String, Object > ();
                    //AddOnMap.put('ActiveringInfo', activeryingInfoMap.get(obj.vlocity_cmt__ProductCode__c));
                    AddOnMap.put('ActiveringInfo',activeringText);//Added by Abhishek for NMP Framework Activering text
                    AddOnMap.put('RecurringCharge', formatCurrency(obj.TeliaSE_MC_Customer_Requested_Price__c != null ? obj.TeliaSE_MC_Customer_Requested_Price__c : obj.vlocity_cmt__RecurringCharge__c));
                    AddOnMap.put('isResOrTill', Obj.Name.contains('Res') ? 'Res' : 'Till');
                    AddOnMap.put('IsRes', obj.Name.contains('Res') ? true : false);
                    AddOnMap.put('IsTill', obj.Name.contains('Till') ? true : false);
                    AddOnMap.put('Name', Obj.Name);
                    //Added for Delta Agreement
                    AddOnMap.put('Status', obj.vlocity_cmt__LineStatus__c);
                    AddOnMap.put('isAdded', false);
                    AddOnMap.put('isExisting', false);
                    AddOnMap.put('isUpdated', false);
                    if (obj.vlocity_cmt__LineStatus__c == 'Added') {
                        AddOnMap.put('isAdded', true);
                    } else if (obj.vlocity_cmt__LineStatus__c == 'Updated') {
                        AddOnMap.put('isUpdated', true);
                    } else if (obj.vlocity_cmt__LineStatus__c == 'Active') {
                        AddOnMap.put('isExisting', true);
                    }
                    AddonList.add(AddOnMap);
                }
            }
            List<Object> BassSurfList = new List<Object> ();
            if (contractBassSurfs.size() > 0) {
                for (vlocity_cmt__ContractLineItem__c obj: contractBassSurfs) {
                    Decimal RTCC = obj.TeliaSE_MC_Customer_Requested_Price__c != null ? obj.TeliaSE_MC_Customer_Requested_Price__c : obj.vlocity_cmt__RecurringCharge__c;
                    Map < String, Object > BassSurfMap = new Map < String, Object > ();
                    BassSurfMap.put('Name', obj.Name);
                    BassSurfMap.put('EnglishName', obj.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                    BassSurfMap.put('OTC', formatCurrency(obj.vlocity_cmt__OneTimeCharge__c));
                    BassSurfMap.put('RTC', formatCurrency(RTCC));
                    //Added for Delta Agreement
                    BassSurfMap.put('Status', obj.vlocity_cmt__LineStatus__c);
                    BassSurfMap.put('isAdded', false);
                    BassSurfMap.put('isExisting', false);
                    BassSurfMap.put('isChanged', false);
                    if (obj.vlocity_cmt__LineStatus__c == 'Added') {
                        BassSurfMap.put('isAdded', true);
                    } else if (obj.vlocity_cmt__LineStatus__c == 'Updated') {
                        BassSurfMap.put('isChanged', true);
                    } else if (obj.vlocity_cmt__LineStatus__c == 'Active') {
                        BassSurfMap.put('isExisting', true);
                    }
                    //Transform Formulas
                    if(obj.Name.contains('Jobbsurf Bas') || testContext){
                        BassSurfMap.put('Bas', true);
                    }else{
                        BassSurfMap.put('Bas', false);
                    }
                    if(obj.Name != 'Jobbsurf Bas' || testContext){
                        BassSurfMap.put('NBas', true);
                    }else{
                        BassSurfMap.put('NBas', false);
                    }
                    BassSurfList.add(BassSurfMap);
                }
            }
            Map < String, Object > ContractMap = new Map < String, Object > ();
            ContractMap.put('Campaign', Campaigns);
            ContractMap.put('AddOn', AddonList);
            ContractMap.put('BASSurf', BassSurfList);
            ResultMap.put('MobBBChildItem', mobBBChildItemList);
            ResultMap.put('Contract', ContractMap);
            
            if (Line.size() > 0) {
                ResultMap.put('Line', Line);
            }
            if (otherOfferChild.size() > 0) {
                ResultMap.put('OtherOfferChild', otherOfferChild);
            }          
        }    
        outputMap.put('result', ResultMap);
    }  
    
    public static void initialTableDisplay(ID conId,Map<String,Object> inputMap,Map<String,Object> outputMap){
        List<vlocity_cmt__ContractLineItem__c> cliList = new List<vlocity_cmt__ContractLineItem__c>();
        set<String> newobjSet= new Set<String>();
        set<String> modifiedobjSet= new Set<String>();
        String salesFlow;
        String assetrefId = '';
        Map<String,Object> selectedOffers = new Map<String,Object>();
        Boolean initialDocGenearteFlag,TPPPresent,ITDaaPresent,COPresent;
        cliList=[select id, vlocity_cmt__QuoteLineItem__r.vlocity_cmt__AssetReferenceId__c, vlocity_cmt__ContractId__c, TeliaSE_ParentItemId__c,vlocity_cmt__QuoteLineItem__r.vlocity_cmt__ParentItemId__c,  vlocity_cmt__ContractId__r.TeliaSE_Type__c, vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.TeliaSE_MC_Sales_Flow_Identifier__c,  
                 name, TeliaSE_Product_Object_Type__c, vlocity_cmt__LineStatus__c, vlocity_cmt__QuoteLineItem__r.MC_RootPriceFlag__c,vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.name from vlocity_cmt__ContractLineItem__c
                 where (TeliaSE_Product_Object_Type__c ='Touchpoint Plus Offer Spec' or TeliaSE_Product_Object_Type__c='ITDaaS Offer Spec' or vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.name='Connected Office Offer Spec') 
                 and vlocity_cmt__ContractId__c=:conId];
        if(cliList.size()>0)
        {
            for(vlocity_cmt__ContractLineItem__c cli : cliList){
                String newObj= cli.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.name != NULL?cli.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.name:cli.TeliaSE_Product_Object_Type__c;
                newobjSet.add(newObj); 
                salesFlow=cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.TeliaSE_MC_Sales_Flow_Identifier__c;
                //if(cli.vlocity_cmt__LineStatus__c=='Added' || cli.vlocity_cmt__LineStatus__c=='Updated'){
                if(cli.vlocity_cmt__QuoteLineItem__r.MC_RootPriceFlag__c== true && cli.vlocity_cmt__QuoteLineItem__r.vlocity_cmt__ParentItemId__c== NULL ){
                    String modifiedObj= cli.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.name != NULL?cli.vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.name:cli.TeliaSE_Product_Object_Type__c;
                    modifiedobjSet.add(modifiedObj);   
                    if(String.IsEmpty(assetrefId)){    
                        assetrefId = cli.vlocity_cmt__QuoteLineItem__r.vlocity_cmt__AssetReferenceId__c;    
                    }
                    else{
                        assetrefId = assetrefId + ',' + cli.vlocity_cmt__QuoteLineItem__r.vlocity_cmt__AssetReferenceId__c;
                    }
                }
            }
            if(salesFlow=='New Sales'){
                
                initialDocGenearteFlag= true;
                TPPPresent= newobjSet.contains('TouchPoint Plus Offer Spec');
                ITDaaPresent=newobjSet.contains('ITDaaS Offer Spec');
                COPresent=newobjSet.contains('Connected Office Offer Spec');
            }
            else  if(salesFlow!='New Sales' && modifiedobjSet.size()>0 ){
                
                initialDocGenearteFlag= true;
                TPPPresent= modifiedobjSet.contains('TouchPoint Plus Offer Spec');
                ITDaaPresent=modifiedobjSet.contains('ITDaaS Offer Spec');
                COPresent=modifiedobjSet.contains('Connected Office Offer Spec');
            }
            selectedOffers.put('Id',assetrefId);
        }
        List<Map<String,Object>> selectedOfferList = new List<Map<String,Object>>();  
        selectedOfferList.add(selectedOffers);    
        outputMap.put('SelectedOffers',selectedOfferList);
        outputMap.put('initialDocGenearteFlag',initialDocGenearteFlag);
        outputMap.put('TPPPresent',TPPPresent);
        outputMap.put('ITDaaPresent',ITDaaPresent);
        outputMap.put('COPresent',COPresent);
    }
    @TestVisible
    private static void mockPriceMap(Map<String,Object> productTotalmap){
        Map<String,Object> PriceMap = new Map<String,Object>();
        Decimal otc = 2,rtc = 3;
        PriceMap.put('otc', otc);
        PriceMap.put('rtc', rtc);
        productTotalmap.put('Broadband Plus Offering Spec', PriceMap);
        productTotalmap.put('Broadband Pro Offering Spec', PriceMap);
        productTotalmap.put('Broadband Start Offering Spec', PriceMap);
        productTotalmap.put('SD-WAN/Firewall Offering Spec', PriceMap);
        productTotalmap.put('WIFI/LAN Offering Spec', PriceMap);
        productTotalmap.put('Connected Office Offer Spec', PriceMap);
        productTotalmap.put('Broadband Datanet Offering Spec', PriceMap);
    }

    /* Developer: Abhinav Gupta
* Description: Generic Method for Cluster Document Table. (MCSTO-11112)
*/
    public static cls_ClusterAddons clusterTableDocument(List < vlocity_cmt__ContractLineItem__c > specialAddOnClis,MC_ClusterTablePricing__mdt  prodMetaData)
    {
        
        //Getting MetaData info and initializing variables
        Map<String,Object> clusterCodeToProductCode = (Map<String,Object>)json.deserializeUntyped(prodMetaData.ProductClusterCodeToClusterCode__c);
        Map<String,Object> GroupToAddOnList = new Map<String,Object>();
        if(prodMetaData.GroupClusterToAddOnMap__c != null)
        {
            GroupToAddOnList = (Map<String,Object>)json.deserializeUntyped(prodMetaData.GroupClusterToAddOnMap__c);
        }
        Boolean groupClustering = prodMetaData.GroupClustering__c;
        List<cls_AddOnChilds> addOnChildClasses = new List<cls_AddOnChilds>();
        Map<String,cls_AddOnChilds> addOnChildMap = new Map<String,cls_AddOnChilds>();
        Map<String,Object> uniqueCliCodeToAllClisMap = new Map<String,Object>();        
        Map<String,String> groupProductIdsToName = new Map<String,String>();
        List<cls_AddOnGroups> addOnGroupsList = new List<cls_AddOnGroups>();
        
        String ClusterBASNIA='Ej vald i avtalet',ClusterSmallNIA='Ej vald i avtalet',ClusterMediumNIA='Ej vald i avtalet',ClusterLargeNIA='Ej vald i avtalet',Cluster80NIA='Ej vald i avtalet',ClusterUnlimNIA='Ej vald i avtalet',documentTemplateLanguage = 'SWE';
        if (specialAddOnClis[0].vlocity_cmt__ContractId__r.MC_Selected_Document_Template__c != null) {
            documentTemplateLanguage = ((specialAddOnClis[0].vlocity_cmt__ContractId__r.MC_Selected_Document_Template__c).split('_'))[1];
            
        }
        if(documentTemplateLanguage != 'SWE' || test.isRunningTest()){
            ClusterBASNIA='Not Selected';
            ClusterSmallNIA='Not Selected';
            ClusterMediumNIA='Not Selected';
            ClusterLargeNIA='Not Selected';
            Cluster80NIA='Not Selected';
            ClusterUnlimNIA='Not Selected';
        }
        
        for (vlocity_cmt__ContractLineItem__c specialAddOn: specialAddOnClis) 
        {       
            if(specialAddOn.vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c == 'SubscriptionOffering')
            {
                List < vlocity_cmt__ContractLineItem__c > correspondingClis = new List < vlocity_cmt__ContractLineItem__c > ();
                if (uniqueCliCodeToAllClisMap.get(specialAddOn.vlocity_cmt__ProductCode__c) == null) {
                    correspondingClis.add(specialAddOn);
                }else{
                    correspondingClis = (List<vlocity_cmt__ContractLineItem__c>)uniqueCliCodeToAllClisMap.get(specialAddOn.vlocity_cmt__ProductCode__c);
                    correspondingClis.add(specialAddOn);
                }
                uniqueCliCodeToAllClisMap.put(specialAddOn.vlocity_cmt__ProductCode__c, correspondingClis);
            }
            else if(specialAddOn.vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering')
            {                
                if (documentTemplateLanguage == 'SWE') {//if swedish template then add swedish group name
                    groupProductIdsToName.put(specialAddOn.vlocity_cmt__ProductCode__c, specialAddOn.Name);
                } else {//else add english group name
                    if (specialAddOn.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c != null) {
                        groupProductIdsToName.put(specialAddOn.vlocity_cmt__ProductCode__c, specialAddOn.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                        
                    } else {
                        groupProductIdsToName.put(specialAddOn.vlocity_cmt__ProductCode__c, '');
                        
                    }
                    
                }
            }
        }
        
        
        for(String cliCode:uniqueCliCodeToAllClisMap.keySet())
        {
            List<vlocity_cmt__ContractLineItem__c> addOnList = (List<vlocity_cmt__ContractLineItem__c>)uniqueCliCodeToAllClisMap.get(cliCode); 
            cls_AddOnChilds addOnChild = new cls_AddOnChilds();                     
            for(vlocity_cmt__ContractLineItem__c cli : addOnList)
            {
                addOnChild.EnglishName = cli.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c;
                addOnChild.Name = cli.Name;
                Decimal rtc = cli.TeliaSE_MC_Customer_Requested_Price__c != null ? cli.TeliaSE_MC_Customer_Requested_Price__c : cli.vlocity_cmt__RecurringCharge__c;
                rtc = rtc.setScale(0);
                String cluster = (String)clusterCodeToProductCode.get(cli.TeliaSE_ParentClusterCode__c);
                switch on cluster {
                    when 'bas' {
                        ClusterBASNIA = '';
                        addOnChild.RTCBAS = String.valueOf(rtc);
                        if(cli.vlocity_cmt__LineStatus__c == 'Added'){
                            addOnChild.IsAddedB = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Updated'){
                            addOnChild.IsUpdatedB = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Active'){
                            addOnChild.IsExistingB = true;
                        }                        
                    }
                    when 'small' {
                        ClusterSmallNIA = '';
                        addOnChild.RTCSMALL = String.valueOf(rtc);
                        if(cli.vlocity_cmt__LineStatus__c == 'Added'){
                            addOnChild.IsAddedS = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Updated'){
                            addOnChild.IsUpdatedS = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Active'){
                            addOnChild.IsExistingS = true;
                        }                        
                    }
                    when 'medium' {
                        ClusterMediumNIA = '';
                        addOnChild.RTCMEDIUM = String.valueOf(rtc);
                        if(cli.vlocity_cmt__LineStatus__c == 'Added'){
                            addOnChild.IsAddedM = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Updated'){
                            addOnChild.IsUpdatedM = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Active'){
                            addOnChild.IsExistingM = true;
                        }                        
                    }
                    when 'large' {
                        ClusterLargeNIA = '';
                        addOnChild.RTCLARGE = String.valueOf(rtc);
                        if(cli.vlocity_cmt__LineStatus__c == 'Added'){
                            addOnChild.IsAddedL = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Updated'){
                            addOnChild.IsUpdatedL = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Active'){
                            addOnChild.IsExistingL = true;
                        }                        
                    }
                    when 'xlarge' {
                        Cluster80NIA = '';
                        addOnChild.RTCXLARGE = String.valueOf(rtc);
                        if(cli.vlocity_cmt__LineStatus__c == 'Added'){
                            addOnChild.IsAddedXL = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Updated'){
                            addOnChild.IsUpdatedXL = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Active'){
                            addOnChild.IsExistingXL = true;
                        }                        
                    }
                    when 'plus' {
                        ClusterUnlimNIA = '';
                        addOnChild.RTCPLUS = String.valueOf(rtc);
                        if(cli.vlocity_cmt__LineStatus__c == 'Added'){
                            addOnChild.IsAddedP = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Updated'){
                            addOnChild.IsUpdatedP = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Active'){
                            addOnChild.IsExistingP = true;
                        }                        
                    }
                    when 'legacy' {
                        ClusterUnlimNIA = '';
                        addOnChild.RTCLGCY = String.valueOf(rtc);
                        if(cli.vlocity_cmt__LineStatus__c == 'Added'){
                            addOnChild.IsAdded = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Updated'){
                            addOnChild.IsUpdated = true;
                        }
                        else if(cli.vlocity_cmt__LineStatus__c == 'Active'){
                            addOnChild.IsExisting = true;
                        }                        
                    }
                    when else  {
                        // nothing to be done
                    }                       
                }
                //Added by priya for LTAT-17280 
                if(cli.vlocity_cmt__ProductCode__c == 'MOB_SP_ADDON_ABROAD_MAX' ){
                    addOnChild.RTCPLUS  = '0';
                }              
            }
            addOnChildMap.put(cliCode,addOnChild);
            addOnChildClasses.add(addOnChild);
        }
        
        
        If(groupClustering)
        {
            for(String groupCode:GroupToAddOnList.keySet())
            {
                cls_AddOnGroups addOnGroup = new cls_AddOnGroups();
                addOnGroup.EnglishName = groupProductIdsToName.get(groupCode);
                addOnGroup.SwedishName = groupProductIdsToName.get(groupCode);
                List<Object> groupAddOnCode = (List<Object>) GroupToAddOnList.get(groupCode);
                List<cls_AddOnChilds> addOnGroupChilds = new List<cls_AddOnChilds>();
                for(Object strCode : groupAddOnCode)
                {
                    cls_AddOnChilds clsAddOn = addOnChildMap.get((String)strCode);
                    if(clsAddOn==null){ //Added for LTAT-23596
                        continue;
                    }
                    addOnGroupChilds.add(clsAddOn);
                }
                addOnGroup.AddOnChilds = addOnGroupChilds;
                addOnGroupsList.add(addOnGroup);
            }
        }
        
        cls_ClusterAddons clusterAddOn = new cls_ClusterAddons();
        clusterAddOn.ClusterBASNIA = ClusterBASNIA;
        clusterAddOn.ClusterSmallNIA = ClusterSmallNIA;
        clusterAddOn.ClusterMediumNIA = ClusterMediumNIA;
        clusterAddOn.ClusterLargeNIA = ClusterLargeNIA;
        clusterAddOn.Cluster80NIA = Cluster80NIA;
        clusterAddOn.ClusterUnlimNIA = ClusterUnlimNIA;
        if(groupClustering)
        {
            clusterAddOn.AddOnGroups = addOnGroupsList;
        }
        else{
            clusterAddOn.AddOnChilds = addOnChildClasses;    
        }       
        return clusterAddOn; 
    }
    
    public static String formatCurrency(Decimal d){
        if(d != null){
            list<String> args = new String[]{'0','number'};
                String s = String.format(d.format(), args);
            if(s.contains(',')){
                s = s.substringBefore(',');
            }
            return s;
        }
        else{
            return null;
        }
    }
    
    //Classes for json structure of NMp special add products(By Abhishek)
    public class cls_ClusterAddons {
        public String ClusterBASNIA;  //-
        public String ClusterSmallNIA;  //-
        public String ClusterMediumNIA;  //-
        public String ClusterLargeNIA;  //-
        public String Cluster80NIA;  //-
        public String ClusterUnlimNIA;  //-
        public cls_AddOnGroups[] AddOnGroups;//list of add on groups
        public cls_AddOnChilds[] AddOnChilds;//list of add onchilds
    }
    public class cls_AddOnGroups {
        public String EnglishName;  //group1
        public String SwedishName;  //group1
        public cls_AddOnChilds[] AddOnChilds;//List of add on childs
    }
    public class cls_AddOnChilds {
        public String EnglishName;
        //public String SwedishName;//Subs1
        public String Name;  //Subs1
        public String RTCBAS = '-';  //50
        public String RTCSMALL = '-';  //50
        public String RTCMEDIUM = '-';  //50
        public String RTCLARGE = '-';  //50
        public String RTCXLARGE = '-';  //50
        public String RTCPLUS = '-';  //50
        public String RTCLGCY = '-'; 
        public Boolean isExisting = false;//for legacy
        public Boolean isAdded = false;//for legacy
        public Boolean isUpdated = false;//for legacy
        public Boolean IsExistingB = false;
        public Boolean IsAddedB = false;
        public Boolean IsUpdatedB = false;
        public Boolean IsExistingS = false;
        public Boolean IsAddedS = false;
        public Boolean IsUpdatedS = false;
        public Boolean IsExistingM = false;
        public Boolean IsAddedM = false;
        public Boolean IsUpdatedM = false;
        public Boolean IsExistingL = false;
        public Boolean IsAddedL = false;
        public Boolean IsUpdatedL = false;
        public Boolean IsExistingXL = false;
        public Boolean IsAddedXL = false;
        public Boolean IsUpdatedXL = false;
        public Boolean IsExistingP = false;
        public Boolean IsAddedP = false;
        public Boolean IsUpdatedP = false;
        
    }       
    //23.6packege_Group Sorting Method- sorting group on bases of index
    public list<Object> groupSorting(list<Object> listGroupMap){
        Map<String,Object> groupTempMap = new Map<String,Object>();       
        for(Integer i =0; i<listGroupMap.size()-1; i++){
            for(Integer j=i+1;j<listGroupMap.size();j++){
                Map<String,Object>  a = (Map<String,Object>)listGroupMap[i];
                Map<String,Object> b = (Map<String,Object>)listGroupMap[j];              
                if(Integer.valueOf(a.get('GroupIndex'))>Integer.valueOf(b.get('GroupIndex'))){
                    groupTempMap =a;
                    listGroupMap[i]= b;
                    listGroupMap[j]= groupTempMap;
                }               
            }
        }
        return listGroupMap;
    }       
    
}