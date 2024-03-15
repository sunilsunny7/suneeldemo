/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_TeliaSE_OfferDocCreation 
**Created By  :        Abhinav Gupta
**Release     :        23.6
**Description :        Apex methods for generation of Offer Document
description  :        added new logic to display SLA C4 available address in grouping and non grouping address table(LTAT-11941)

** SHOULD BE FULLY USED FOR ALL APEX TRANSFORMATIONS USED DURING OFFER DOCUMENT GENERATIONS.
-----------------------------------------------------------------------------------------------------------*/
global with sharing class MC_TeliaSE_OfferDocCreation implements vlocity_cmt.VlocityOpenInterface{
    Public static Boolean isExistSLAC4;
    global boolean invokeMethod(string methodname, Map<String,Object> inputs,Map<String,Object> outputs,Map<String,Object> options)
    {
        if(methodName.equalsIgnoreCase('offerDocgeneration'))
        {
            offerDocGeneration(inputs,outputs);
            return true;
        }
        else if(methodName.equalsIgnoreCase('trimCurrencyPrefix'))
        {
            trimCurrencyPrefix(inputs,outputs);
            return true;
        }
        return true;
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This is the main Driver Method which initiates the offer Doc creation.
* We will initiate the resultMap class which has all the token needed for the offer document template.
* Query all the simplifiedLineItems, SiteInfo , Group information in SOQL queries
* Split the items into different lists so that they can be processes differently based on the requirement.
*___________________________________________________________________________________________________________
*/
    
    public static void offerDocGeneration(Map<String,Object> inputs,Map<String,Object> output)
    {
        try{
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            Id qid=Id.valueOf((String)arguments[0]);
            Id accountId = Id.valueOf((String)arguments[1]);
            String offerNames =(String)arguments[2];
            String status = (String)arguments[3];           
            List<TeliaSE_SimplifiedQuoteLineItem__c> AllData=[SELECT Id,ProductName__c,TeliaSE_BaseQuantity__c,MC_Initial_Order_Quantity__c,TeliaSE_Root_Product__c,TeliaSE_MC_Campaign_Id__r.Name,
                                                              TeliaSE_MC_Campaign_Id__r.MC_Product_Name_Eng__c,Product__r.TeliaSE_OfferTemplateFlag__c,Product__r.TeliaSE_TemplateCategory__c,
                                                              MC_TeliaExcludeQuoteItem__c,TeliaSE_Offer_Type__c,TeliaSE_Parent_ItemId__c,TeliaSE_MC_Binding_Time__c,Product__r.Name,
                                                              Product__r.MC_Product_Name_Eng__c,Quote_Group__c,Quote_Group__r.Name,Quote_Group__r.vlocity_cmt__Description__c,TeliaSE_Aggregated_Quantity__c,
                                                              Product_Code__c,TeliaSE_One_Time_Total__c,TeliaSE_OnetimeCharge__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                                              Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c,
                                                              Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                                                              Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                                              TeliaSE_Recurring_Total__c,TeliaSE_List_Price__c,TeliaSE_Product_Hierarchy__c,ProductType__c,Product__r.id,
                                                              QuoteId__r.vlocity_cmt__ParentQuoteId__c,MC_HeraType__c 
                                                              FROM TeliaSE_SimplifiedQuoteLineItem__c 
                                                              WHERE QuoteId__c =:qid ORDER BY MC_Sequence_Number__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,MC_HeraType__c]; 
            List<vlocity_cmt__QuoteMember__c> siteMemberdetails = [select vlocity_cmt__ServicePointId__r.MC_IS_SLA_C4_Available__c, vlocity_cmt__ServicePointId__c, vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__c,
                                                                   vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                                                                   vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,
                                                                   vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c,
                                                                   vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c ,vlocity_cmt__QuoteGroupId__c,
                                                                   vlocity_cmt__QuoteGroupId__r.vlocity_cmt__Description__c
                                                                   from vlocity_cmt__QuoteMember__c 
                                                                   where vlocity_cmt__QuoteId__c=:qid ORDER BY  vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c];
            
            List<vlocity_cmt__ServicePoint__c> allPrems = [select id,MC_IS_SLA_C4_Available__c,vlocity_cmt__PremisesId__c,vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                                           vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c, vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c
                                                           from vlocity_cmt__ServicePoint__c  
                                                           where vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =:AccountId Order by vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c];
            TeliaSE_SimplifiedQuoteLineItem__c simpl1 = new TeliaSE_SimplifiedQuoteLineItem__c(); 
            if(allData.size()>0){
                simpl1=AllData[0];
            }
            resultMap result= new resultMap();
            List<String> coOfferTypes=new list<String>{'Broadband Start Offering Spec','Broadband Plus Offering Spec','Broadband Pro Offering Spec','Broadband Datanet Offering Spec','WIFI/LAN Offering Spec','SD-WAN/Firewall Offering Spec'};
                List<String> b2bOffers = new list<String>{'B2B-BBF','B2B-BBPRO','B2B-DATANET','B2B-CLOUD-VPN-SD-WAN','B2B-CLOUD-VPN-WIFI'};
                    List<QuoteLineItem> nmpClusterAddOns=new List <QuoteLineItem>();
            List<String> nmpClusterAddOnProducts = new List<String>();
            Map<String, MC_ClusterTablePricing__mdt> mcs = MC_ClusterTablePricing__mdt.getAll();
            List<QuoteLineItem> minuteBasesAddons = new List<QuoteLineItem>();
            MC_ClusterTablePricing__mdt mobileMetadata;
            Boolean isTotalProduct = false;
            for(String name: mcs.keySet())
            {            
                if(name=='Mobile_Offer_Specification')
                {
                    nmpClusterAddOnProducts = mcs.get(name).TableProducts__c.split(';');                                
                    mobileMetadata = mcs.get(name);
                }
            }
            List<QuoteLineItem> faQliList = [SELECT Id,vlocity_cmt__Product2Id__r.Name,TeliaSE_Product_Code__c,vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c, TeliaSE_Product_Object_Type__c,vlocity_cmt__RecurringCharge__c,TeliaSE_Root_Product__r.ProductCode ,TeliaSE_ParentClusterCode__c,vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c,TeliaSE_Approved_Price__c,TeliaSE_MC_Customer_Requested_Price__c,  vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c,TeliaSE_Ceiling_Price__c,vlocity_cmt__OneTimeCharge__c from QuoteLineItem where QuoteId =: simpl1.QuoteId__r.vlocity_cmt__ParentQuoteId__c and ((TeliaSE_Product_Object_Type__c in: coOfferTypes and vlocity_cmt__ParentItemId__c = null) OR vlocity_cmt__Product2Id__r.ProductCode in :nmpClusterAddOnProducts OR vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c = 'Minute_Based')];
            //end code mobile AddOn tables
            if(faQliList.size()>0)
            {
                for(QuoteLineItem qli: faQliList)
                {
                    if(b2bOffers.contains(qli.TeliaSE_Product_Code__c)){
                        result.isB2B = true;
                    }
                    else if(!coOfferTypes.contains(qli.TeliaSE_Product_Object_Type__c) && qli.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c != 'Minute_Based'){
                        nmpClusterAddOns.add(qli);
                        if(qli.TeliaSE_Root_Product__r.ProductCode.contains('TOTAL')){
                            isTotalProduct = true;
                        }
                        else if(qli.TeliaSE_Root_Product__r.ProductCode.contains('PLUS')){
                            isTotalProduct = false;
                        }
                    }
                    else if(qli.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c == 'Minute_Based' && qli.TeliaSE_MC_Customer_Requested_Price__c !=qli.TeliaSE_Ceiling_Price__c ){
                        minuteBasesAddons.add(qli);
                     //   ShowMinuteBasedTable = true;
                    }
                }
            }       
            if((!result.isB2B && System.label.B2BSolution_Toggle == 'true') || result.isB2B){
                result.isB2B = true;
            }
            else{
                result.isB2B = false;
            }
            //NMP Document Token
            if(nmpClusterAddOns.size() > 0){
                if(isTotalProduct){
                    result.isTotalClusterAddons = clusterTableDocument(nmpClusterAddOns,mobileMetadata);    
                }
                else{
                    result.isALLINClusterAddons = clusterTableDocument(nmpClusterAddOns,mobileMetadata);
                }
            }
            //NMP ends
            //minute based class called
            if(minuteBasesAddons.size()>0){
                result.isMinutebased = minutebasedmethod(minuteBasesAddons);
            }
            //AdditonalOfferPopulation - done
            if(String.isNotBlank(offerNames))
            {
                additionOfferPopulate(result,offerNames);
            }
            List<TeliaSE_SimplifiedQuoteLineItem__c> qliList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            List<TeliaSE_SimplifiedQuoteLineItem__c> groupingList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            List<TeliaSE_SimplifiedQuoteLineItem__c> heraList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            List<TeliaSE_SimplifiedQuoteLineItem__c> frameworkAddOnList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            Boolean isGrouping = false,isNonZeroInitialOQty=false,isNonZeroInitialOQtyCO=false;
            Decimal TPPSumCallQuantity = 0,TPPDeductedOTF=0,CONonGroupDeductedOTF=0,TotalDeductedOTF=0;
            
            for(TeliaSE_SimplifiedQuoteLineItem__c qli : AllData){ 
                if(qli.Product_Code__c.contains('SLA-C4')){
                    isExistSLAC4 = true;
                }
                if((qli.ProductType__c != 'Connected Office Offer Spec' && qli.Quote_Group__c !=null && !qli.MC_TeliaExcludeQuoteItem__c) || (qli.ProductType__c == 'Connected Office Offer Spec' && qli.Quote_Group__c !=null && qli.Quote_Group__r.vlocity_cmt__Description__c != 'NO_GROUP')) {                
                    isGrouping = true;
                    groupingList.add(qli);
                }
                else if (qli.ProductType__c == 'Connected Office Offer Spec' && qli.Quote_Group__c !=null && qli.Quote_Group__r.vlocity_cmt__Description__c == 'NO_GROUP'){
                    heraList.add(qli);
                }
                else if(nmpClusterAddOnProducts.contains(qli.Product_Code__c)){
                    frameworkAddOnList.add(qli);
                }
                else{
                    qliList.add(qli);
                }
                //TPP MAA MFF Code
                if(qli.Product_Code__c == 'TPP_PKG_BASE' ||qli.Product_Code__c == 'TPP_PKG_VIRTUAL' ||qli.Product_Code__c == 'TPP_PKG_MOBILE' ||qli.Product_Code__c == 'TPP_PKG_UNIFIED' ){
                    if(qli.MC_TeliaExcludeQuoteItem__c == false){
                        TPPSumCallQuantity = TPPSumCallQuantity + qli.TeliaSE_Aggregated_Quantity__c;
                    }
                }
                //TPP Deducted OTF
                if(qli.ProductType__c=='TouchPoint Plus Offer Spec' && !qli.MC_TeliaExcludeQuoteItem__c){
                    integer initialOrderQuantity = integer.valueof(qli.MC_Initial_Order_Quantity__c)!=null?integer.valueof(qli.MC_Initial_Order_Quantity__c):0;
                    if(initialOrderQuantity >0){
                        isNonZeroInitialOQty = true;
                        Decimal deductedOtf = initialOrderQuantity*qli.TeliaSE_OnetimeCharge__c ; 
                        TPPDeductedOTF = TPPDeductedOTF + deductedOtf;
                    }
                }
                //CO Ungrouped Deducted OTF
                if(coOfferTypes.contains(qli.ProductType__c) && qli.Quote_Group__c ==null && !qli.MC_TeliaExcludeQuoteItem__c){
                    integer initialOrderQuantity = integer.valueof(qli.MC_Initial_Order_Quantity__c)!=null?integer.valueof(qli.MC_Initial_Order_Quantity__c):0;                
                    if(initialOrderQuantity >0){
                        isNonZeroInitialOQtyCO = true;
                        Decimal deductedOtf = initialOrderQuantity*qli.TeliaSE_OnetimeCharge__c ; 
                        CONonGroupDeductedOTF = CONonGroupDeductedOTF + deductedOtf;  
                    }
                }
            }
            if(TPPSumCallQuantity >0){
                result.MAA = Math.round((TPPSumCallQuantity/ 100)+5);
                result.MAF = Math.round((TPPSumCallQuantity/ 100)+3);
            }
            if(isGrouping){
                TotalDeductedOTF = TPPDeductedOTF;
                result.TotalDeductedOTF=math.round(TPPDeductedOTF);
            }else{
                TotalDeductedOTF = TPPDeductedOTF + CONonGroupDeductedOTF;
                result.TotalDeductedOTF=math.round(TotalDeductedOTF);
            }
            if((isGrouping && isNonZeroInitialOQty && TPPDeductedOTF != 0) || 
               (!isGrouping && (isNonZeroInitialOQty || isNonZeroInitialOQtyCO) && TPPDeductedOTF+CONonGroupDeductedOTF != 0)){
                   result.isReNeg=true;
               }
            productsTablePopulate(qliList,result,status,frameworkAddOnList);
            populateFlagsAndTotals(result);
            if(result.TotalOTC>0)
            {
                result.TotalOTC = (result.TotalOTC-result.TotalDeductedOTF > 0) ? result.TotalOTC-result.TotalDeductedOTF : 0;                
            }
            //For only hera sites info populate
            if(heraList.size()>0){
                onlyHeraPopulate(result,heraList);
            }
            //Grouping CASE
            result.GroupExist = isGrouping;
            if(isGrouping)
            {
                populateGroupingInfoTable(result, groupingList,siteMemberdetails);
            }
            //Token for Grouping OTF(LTAT-15472)
            if(result.TotalGRPDeductedCOOTF>0)
            {
                result.isReNegCO=true;
            }
            //For sites populate.
            if(allPrems.size()>0){
                siteInfo(result, allPrems);
                if(isExistSLAC4 == true){
                    result.isSLAExistInCart=true;
                }
            }           
            Map<String,Object> resultItems = (Map<String,Object>)json.deserializeUntyped(json.serialize(result));
            output.put('result',resultItems);
        }Catch(Exception e){
            system.debug(e);
            system.debug(e.getStackTraceString());
            system.debug(e.getLineNumber());
        }
    }
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method will populate the flags for additional offer selected during quote negotiation.
* We will get the string of all offers selected and added in Quote generation, we will populate the flags in the resultMap in this method.
* __________________________________________________________________________________________________________
*/    
    public static void additionOfferPopulate(resultMap result , String offer)
    {
        if(offer.contains('Microsoft 365')){
            result.is365 = true;
        }
        if(offer.contains('Slutanvändarsupport')){
            result.isEUS = true;
        }
        if(offer.contains('Jobbmobil')){
            result.isJobMobile = true;
            result.isJM = true;  
        }  
        if(offer.contains('Smart Connect'))  
        {  
            result.isSC = true;  
        }   
        
        if(Offer.contains('Mobilt')){
            result.isMobile = true;
        }
        if(Offer.contains('Personlig Tekniker')){
            result.isPT = true;
        }
        if(Offer.contains('Smart Säkerhet')){
            result.isSS = true;
        }
        if(Offer.contains('Bredband Plus')){
            result.isTBPL= true;
        }
        if(Offer.contains('Datanet')){
            result.isTDN=true;
        }
        if(Offer.contains('Bredband Pro')){
            result.isTBPR =true;
        }
        if(Offer.contains('Bredband Start') || Offer.contains('Bredband Företag')){
            result.isTBS=true;
        }
        if(Offer.contains('VPN SD-WAN')){
            result.isTCSD=true;
        }
        if(Offer.contains('VPN WIFI')){
            result.isTCWI=true;
        }
        if(Offer.contains('TouchPoint')){
            result.isTP=true;
        }
        if(Offer.contains('Touch Point Plus')){
            result.isTPP=true;
        }
        if(Offer.contains('Operator Connect')){
            result.isOC=true;
        }
        if(Offer.contains('Försäkring')){
            result.isTF=true;
        }
        
        if(Offer.contains('IT-avdelning   ')){
            result.isITDaaS=true;
        }
        if(Offer.contains('IT-avdelning Start')){  
            result.isITDaaSStart=true;
        }
        if(Offer.contains('IT-support Standard')){  
            result.isITSupportStandard=true;
        }
        if(Offer.contains('IT-support Plus')){  
            result.isITSupportPlus=true;
        }
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is used for population of flags for products in the pricing tables in the offerDocument.
* The Idea is to first create a map of all root/parent items with the value - list of all its childs.
* Then we will iterate over the rootItem to create an entry in the Line node in the result Map. 
* Each line node would contain info about each root item, which family it belongs to and which childs are.
* This method also separates methods for special Mobile addOns. 
*___________________________________________________________________________________________________________
* params - qliList - List of all products which need to be included in the pricing tables. (called from offerDocGeneration method)
* params - result - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - status - Status of the contract from the quote
* params - frameworkAddOnList -  List of all Special addOn simplified items.
*/
    public static void productsTablePopulate(List<TeliaSE_SimplifiedQuoteLineItem__c> qliList ,resultMap result,String status,List<TeliaSE_SimplifiedQuoteLineItem__c> frameworkAddOnList)
    {
        Map<String,MC_OfferCreation_ObjSplit__c> objTypes = MC_OfferCreation_ObjSplit__c.getAll();
        List<TeliaSE_SimplifiedQuoteLineItem__c> defaultTableList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
        List<TeliaSE_SimplifiedQuoteLineItem__c> zeroTableList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
        Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>> rootToChildList = new Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>>();
        Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>> rootQli = new Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>>();
        Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>> rootFrQli = new Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>>();
        Set<String> SCClusterProductCodes=new Set<String>();
        MC_ClusterTablePricing__mdt scProductCode = MC_ClusterTablePricing__mdt.getInstance('Smart_Connect_Offer_Spec');
        Map<String,Object> scClusterCodeMap = (Map<String,Object>)json.deserializeUntyped(scProductCode.ProductClusterCodeToClusterCode__c);
        Map<String,String> scCLusterIdToProductCode = new Map<String,String>();
        
        for(TeliaSE_SimplifiedQuoteLineItem__c qli:qliList){            
            if (qli.TeliaSE_Parent_ItemId__c == null && qli.ProductType__c != 'Virtual Offer Products')
            {
                List<TeliaSE_SimplifiedQuoteLineItem__c> rootQliList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
                String rootItemConcat = qli.TeliaSE_Root_Product__c;
                if(qli.ProductType__c!='Mobile Offer Specification' && objtypes.containsKey(qli.ProductType__c) ){
                    rootItemConcat = rootItemConcat + qli.get(objTypes.get(qli.ProductType__c).fieldsToAdd__c);
                }
                if(rootQli.containsKey(rootItemConcat)){
                    rootQliList = rootQli.get(rootItemConcat);  
                }
                rootQliList.add(qli);
                rootQli.put(rootItemConcat,rootQliList);
            }
            if(scClusterCodeMap.containsKey(qli.Product_Code__c))
            {
                scCLusterIdToProductCode.put(qli.TeliaSE_Product_Hierarchy__c,qli.Product_Code__c);
            }
        }
        for(TeliaSE_SimplifiedQuoteLineItem__c qli:qliList){
            if(qli.TeliaSE_Parent_ItemId__c != null)
            {   
                String rootItemConcat = qli.TeliaSE_Root_Product__c;
                if(qli.ProductType__c!='Mobile Offer Specification' && objtypes.containsKey(qli.ProductType__c)){
                    rootItemConcat = rootItemConcat + qli.get(objTypes.get(qli.ProductType__c).fieldsToAdd__c);
                }
                List<TeliaSE_SimplifiedQuoteLineItem__c> childList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
                if(rootToChildList.containsKey(rootItemConcat))
                {
                    childList = rootToChildList.get(rootItemConcat);
                }
                childList.add(qli);
                rootToChildList.put(rootItemConcat,childList);
            }
            
        }
        
        for(TeliaSE_SimplifiedQuoteLineItem__c frqli:frameworkAddOnList){
            
            if (frqli.TeliaSE_Parent_ItemId__c == null && frqli.ProductType__c != 'Virtual Offer Products')
            {
                List<TeliaSE_SimplifiedQuoteLineItem__c> rootQliList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
                String rootItemConcat = frqli.TeliaSE_Root_Product__c;
                if(frqli.ProductType__c!='Mobile Offer Specification' && objtypes.containsKey(frqli.ProductType__c) ){
                    rootItemConcat = rootItemConcat + frqli.get(objTypes.get(frqli.ProductType__c).fieldsToAdd__c);
                }
                if(rootFrQli.containsKey(rootItemConcat)){
                    rootQliList = rootFrQli.get(rootItemConcat);  
                }
                rootQliList.add(frqli);
                rootFrQli.put(rootItemConcat,rootQliList);
            }
            if(frqli.TeliaSE_Parent_ItemId__c != null)
            {   
                String rootItemConcat = frqli.TeliaSE_Root_Product__c;
                if(frqli.ProductType__c!='Mobile Offer Specification' && objtypes.containsKey(frqli.ProductType__c)){
                    rootItemConcat = rootItemConcat + frqli.get(objTypes.get(frqli.ProductType__c).fieldsToAdd__c);
                }
                List<TeliaSE_SimplifiedQuoteLineItem__c> childList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
                if(rootToChildList.containsKey(rootItemConcat))
                {
                    childList = rootToChildList.get(rootItemConcat);
                }
                childList.add(frqli);
                rootToChildList.put(rootItemConcat,childList);
            }
        }
        
        List<cls_Line> lineNode = new List<cls_Line>();
        // Iterating over rootItemList
        for(String rootItem:rootQli.keySet())
        {           
            List<TeliaSE_SimplifiedQuoteLineItem__c> itemList = rootQli.get(rootItem);
            for(TeliaSE_SimplifiedQuoteLineItem__c item: itemList){
                lineNode.add(lineItemPopulate(result, item, scCLusterIdToProductCode, status, rootToChildList, rootItem));
            } 
        }
        
        Map<String,cls_Line> lineNodeMap = new Map<String,cls_Line>();
        for(String rootItemfr : rootfrQli.keySet()){
            List<TeliaSE_SimplifiedQuoteLineItem__c> itemList = rootFrQli.get(rootItemfr);
            for(TeliaSE_SimplifiedQuoteLineItem__c item: itemList){
                cls_line linefr = new cls_line();
                if(lineNodeMap.containsKey(item.Product__c)){
                    linefr = lineNodeMap.get(item.Product__c);
                    lineItemPopulateFr(result, item, scCLusterIdToProductCode, status, rootToChildList, rootItemfr,linefr,true);
                }
                else{
                    linefr = lineItemPopulateFr(result, item, scCLusterIdToProductCode, status, rootToChildList, rootItemfr,null,true);                
                }
                lineNodeMap.put(item.Product__c,linefr);
            }
        }
        //Add to lineNode 
        for(String obj : lineNodeMap.keySet()){
            lineNode.add(lineNodeMap.get(obj));
        }
        result.Line = lineNode;
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Method is invoked for populating Line node for each root Item. 
* The method would return cls_Line node for each root product, populate flags for product level and populate child item information for each.
* This method is specially made for mobile special addOns.
*___________________________________________________________________________________________________________
* params - resultMap -  ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - item - rootItem simplified Item 
* params - scCLusterIdToProductCode - Map of cluster to Sc product Codes.
* params - status - Contract Status
* params - rootToChildList - Map: Key:rootItem , value:List of all child products.
* params - rootItem - rootItem
* params - lineFr - Specially added for special addOns, different roots needs to be clubbed here.
* params - isSpecialAddon - sent as true for special addOns offerings.
*/
    
    public static cls_Line lineItemPopulateFr(resultMap result,TeliaSE_SimplifiedQuoteLineItem__c item,Map<String,String> scCLusterIdToProductCode,string status,Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>> rootToChildList,string rootItem, cls_Line lineFr,Boolean isSpecialAddon){
        cls_Line rootLine = new cls_Line();
        if(lineFr!= null){
            rootLine = lineFr;
        }
        rootLine.ProductCode = item.Product_Code__c;
        rootLine.Type = item.ProductType__c;        
        rootLine.SwedishName = item.ProductName__c;        
        rootLine.EnglishName = item.Product__r.MC_Product_Name_Eng__c;
        rootLine.BindingTime = item.TeliaSE_MC_Binding_Time__c;
        if(status == 'Active'|| status =='Cancelled'){
            rootLine.CampaignName = null;
            rootLine.EnglishCampaignName =null;
        }else{
            rootLine.CampaignName = item.TeliaSE_MC_Campaign_Id__r.Name;
            rootLine.EnglishCampaignName = item.TeliaSE_MC_Campaign_Id__r.MC_Product_Name_Eng__c;
        }
        rootLine.ExcludeItem = item.MC_TeliaExcludeQuoteItem__c;
        if(item.MC_TeliaExcludeQuoteItem__c == false && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering'){
            rootline.isDefaultTable = 1;
            rootline.isZeroTable = 0;
        }
        else if (item.MC_TeliaExcludeQuoteItem__c == true && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering'){
            rootline.isDefaultTable = 0;
            rootline.isZeroTable = 1;
        }
        rootLine = populateLineProductFlags(result,item,rootline,scCLusterIdToProductCode);
        if(item.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering'){
            rootLine.isSub = false;
            if(rootToChildList.containskey(rootItem)){
                List<TeliaSE_SimplifiedQuoteLineItem__c> children = rootToChildList.get(rootItem);
                if(children.size()>0){
                    if(lineFr!=null){
                        rootLine.ChildItem = populateChildItemFr(result,children,lineFr,true);    
                    }
                    else{
                        rootLine.ChildItem = populateChildItemFr(result,children,rootLine,true);    
                    }
                    
                }
            }
        }
        if(lineFr!=null){
            rootLine.Qn = rootLine.isSub ? lineFr.Qn + (Integer)item.TeliaSE_Aggregated_Quantity__c : (Integer)item.TeliaSE_Aggregated_Quantity__c;
            rootLine.RTCSum = lineFr.RTCSum + math.round(item.TeliaSE_Recurring_Total__c);
            rootLine.RTC = lineFr.RTC + math.round(item.TeliaSE_Recurring_Total__c);
            rootLine.OTC = lineFr.OTC + (Integer)item.TeliaSE_One_Time_Total__c;
            rootLine.OneTimeTotal = lineFr.OneTimeTotal + (Integer)item.TeliaSE_One_Time_Total__c;
            rootLine.isDefaultTable = (rootLine.isDefaultTable + lineFr.isDefaultTable) >= 1 ? 1 : 0;
            rootLine.isZeroTable = (rootLine.isZeroTable + lineFr.isZeroTable) >= 1 ? 1 : 0;
        }
        else{
            rootLine.Qn = (Integer)item.TeliaSE_Aggregated_Quantity__c;
            rootLine.RTCSum = math.round(item.TeliaSE_Recurring_Total__c);
            rootLine.RTC = isSpecialAddon ? math.round(item.TeliaSE_Recurring_Total__c) : item.TeliaSE_List_Price__c;
            rootLine.OTC = isSpecialAddon ? (Integer)item.TeliaSE_One_Time_Total__c :(Integer)item.TeliaSE_OnetimeCharge__c;
            rootLine.OneTimeTotal = (Integer)item.TeliaSE_One_Time_Total__c;
        }        
        return rootLine;
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Method is invoked for populating child item node for each root Item. 
* The method would return list<cls_ChildItem> node for each root product, populate flags for each product and sum.
* This method is specially made for mobile special addOns.
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - childList - List of childItems for each root. 
* params - line - Populate line flags as well.
* params - isSpecialAddon - sent as true for special addOns offerings.
*/
    public static list<cls_ChildItem> populateChildItemFr(resultMap result,List<TeliaSE_SimplifiedQuoteLineItem__c> childList,cls_Line line,Boolean isSpecialAddon){
        Integer defaultFlag =0 , zeroFlag=0;
        List<cls_ChildItem> childItemClass = new List<cls_ChildItem>();
        Map<String,cls_ChildItem> childItemMap = new Map<String,cls_ChildItem>();
        if(line!= null && line.childItemMap != null){
            childItemMap = line.childItemMap;
        }
        Boolean existingChild = false;
        Boolean childExists = false;
        for(TeliaSE_SimplifiedQuoteLineItem__c child:childList){
            if(!child.MC_TeliaExcludeQuoteItem__c){
                childExists = true;
                cls_ChildItem childItem = new cls_ChildItem();                  
                if(childItemMap.containsKey((String)child.Product__c)){
                    existingChild = true;
                    childItem = childItemMap.get(child.Product__c);
                }
                else{
                    existingChild = false;
                }            
                childItem.Qn = existingChild ? childItem.Qn + (Integer)child.TeliaSE_Aggregated_Quantity__c : (Integer)child.TeliaSE_Aggregated_Quantity__c;
                childItem.RTCSum = existingChild ? childItem.RTCSum + math.round(child.TeliaSE_Recurring_Total__c) : math.round(child.TeliaSE_Recurring_Total__c);
                childItem.RTC= childItem.RTCSum;
                childItem.SwedishName = child.ProductName__c;
                childItem.OneTimeTotal = existingChild ? childItem.OneTimeTotal + (Integer)child.TeliaSE_One_Time_Total__c :(Integer)child.TeliaSE_One_Time_Total__c;
                childItem.OTC = childItem.OneTimeTotal;
                childItem.EnglishName=child.Product__r.MC_Product_Name_Eng__c;
                childItem.Tmpflg=child.Product__r.TeliaSE_OfferTemplateFlag__c;
                childItem.ExcludeItem=child.MC_TeliaExcludeQuoteItem__c;
                childItem.isDefaultTable=1;
                childItem.isZeroTable=0;
                defaultflag=1;                           
                childItemMap.put(child.Product__c,childItem);
                line.childItemMap = childItemMap;
            }            
        }
        if(childExists){
            line.isZeroTable = zeroflag;
            line.isDefaultTable = defaultflag;
        }        
        childItemClass.addAll(childItemMap.values());
        return childItemClass;
    }        
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Method is invoked for populating Line node for each root Item. 
* The method would return cls_Line node for each root product, populate flags for product level and populate child item information for each.
*___________________________________________________________________________________________________________
* params - resultMap -  ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - item - rootItem simplified Item 
* params - scCLusterIdToProductCode - Map of cluster to Sc product Codes.
* params - status - Contract Status
* params - rootToChildList - Map: Key:rootItem , value:List of all child products.
* params - rootItem - rootItem
*/
    public static cls_Line lineItemPopulate(resultMap result,TeliaSE_SimplifiedQuoteLineItem__c item,Map<String,String> scCLusterIdToProductCode,string status,Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>> rootToChildList,string rootItem){
        cls_Line rootLine = new cls_Line();
        rootLine.ProductCode = item.Product_Code__c;
        rootLine.Type = item.ProductType__c;
        rootLine.Qn = (Integer)item.TeliaSE_Aggregated_Quantity__c;
        rootLine.RTCSum = math.round(item.TeliaSE_Recurring_Total__c);
        rootLine.RTC = item.TeliaSE_List_Price__c;
        rootLine.SwedishName = item.ProductName__c;
        rootLine.OTC = (Integer)item.TeliaSE_OnetimeCharge__c;
        rootLine.OneTimeTotal = (Integer)item.TeliaSE_One_Time_Total__c;
        rootLine.EnglishName = item.Product__r.MC_Product_Name_Eng__c;
        rootLine.BindingTime = item.TeliaSE_MC_Binding_Time__c;
        if(status == 'Active'|| status =='Cancelled'){
            rootLine.CampaignName = null;
            rootLine.EnglishCampaignName =null;
        }else{
            rootLine.CampaignName = item.TeliaSE_MC_Campaign_Id__r.Name;
            rootLine.EnglishCampaignName = item.TeliaSE_MC_Campaign_Id__r.MC_Product_Name_Eng__c;
        }
        rootLine.ExcludeItem = item.MC_TeliaExcludeQuoteItem__c;
        if(item.MC_TeliaExcludeQuoteItem__c == false && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering'){
            rootline.isDefaultTable = 1;
            rootline.isZeroTable = 0;
        }
        else if (item.MC_TeliaExcludeQuoteItem__c == true && item.TeliaSE_Offer_Type__c != 'Non-SubscriptionOffering'){
            rootline.isDefaultTable = 0;
            rootline.isZeroTable = 1;
        }
        rootLine = populateLineProductFlags(result,item,rootline,scCLusterIdToProductCode);
        if(item.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering'){
            rootLine.isSub = false;
            if(rootToChildList.containskey(rootItem)){
                List<TeliaSE_SimplifiedQuoteLineItem__c> children = rootToChildList.get(rootItem);
                if(children.size()>0){
                    rootLine.ChildItem = populateChildItem(result,children,rootLine);
                }
            }
        }
        return rootLine;
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Method is invoked for populating line product flags for each product offering. 
* Method will populate which offer the lineitem is part of by populating particular flags.
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - childList - List of childItems for each root. 
* params - line - Populate line flags as well.
* params - isSpecialAddon - sent as true for special addOns offerings.
* params - scCLusterIdToProductCode - Map of cluster to Sc product Codes.
*/
    public static cls_Line populateLineProductFlags(resultMap result, TeliaSE_SimplifiedQuoteLineItem__c item,cls_Line line,Map<String,String> scCLusterIdToProductCode){        
        if(item.ProductType__c=='Broadband Start Offering Spec'){
            if(item.TeliaSE_MC_Binding_Time__c !=null){
                result.TBSBindingPeriod = item.TeliaSE_MC_Binding_Time__c;
            }
            line.isTBS=true;
            result.isnonITDaaSTable = true;
        }
        else if (item.ProductType__c.contains('ITDaaS Offer Spec')){
            //Logic to display static text based on particular offering present in cart. 
            if(item.Product_Code__c.contains('ITDAAS_START')){  
                result.isITDaaSStart=true;
            }
            else if(item.Product_Code__c.contains('ITS')){  
                result.isITSupportStandard=true;
            }
            else if(item.Product_Code__c.contains('ITP')){
                result.isITSupportPlus=true;
            }
            else{
                result.isITDaaS=true;
            }
            //Logic to read second level products for ITSupport and display tables based on template category both default and zero.
            if(item.MC_TeliaExcludeQuoteItem__c == true){
                if(item.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_Users'){
                    line.isITDaaSUsersZero = true;
                    result.isITDaaSUsersZero = true;
                }else{
                    line.isITDaaSUsersZero = false;
                }
                line.ExcludeItem = item.MC_TeliaExcludeQuoteItem__c;
                line.isDefaultTable = 0;
                line.isZeroTable = 1;
            }
            else{
                if(item.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_Users'){
                    line.isITDaaSUsers=true;
                    result.isITDaaSUsers = true;
                    result.TotalRTCUser = result.TotalRTCUser + item.TeliaSE_Recurring_Total__c;
                    result.RTCUser = result.RTCUser + item.TeliaSE_List_Price__c;
                    result.isITDaaS1=true;
                }else{
                    line.isITDaaSUsers=false;
                }
                line.ExcludeItem=item.MC_TeliaExcludeQuoteItem__c;
                line.isDefaultTable=1;
                line.isZeroTable=0;
                result.TotalSumRTC = result.TotalRTCUser;
                result.TotalITDaaSRTC = result.TotalSumRTC+ result.TotalSumITDaasRTC;
            }
        }       
        else if(item.ProductType__c=='Broadband Plus Offering Spec' ){
            if(item.TeliaSE_MC_Binding_Time__c !=null ){
                result.TBPlusBindingPeriod = item.TeliaSE_MC_Binding_Time__c;
            }
            line.isTBPL=true;
            result.isnonITDaaSTable = true;            
        }
        else if(item.ProductType__c=='Broadband Pro Offering Spec' ){
            if(item.TeliaSE_MC_Binding_Time__c !=null){
                result.TBProBindingPeriod = item.TeliaSE_MC_Binding_Time__c;
            }
            line.isTBPR=true;
            result.isnonITDaaSTable = true;            
        }
        else if(item.ProductType__c=='Broadband Datanet Offering Spec'){
            if(item.TeliaSE_MC_Binding_Time__c !=null){
                result.TDNBindingPeriod = item.TeliaSE_MC_Binding_Time__c;
            }
            line.isTDN=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='WIFI/LAN Offering Spec' ){
            if(item.TeliaSE_MC_Binding_Time__c !=null){
                result.TCWIBindingPeriod = item.TeliaSE_MC_Binding_Time__c;
            }
            line.isTCWI=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='SD-WAN/Firewall Offering Spec' ){
            if(item.TeliaSE_MC_Binding_Time__c !=null){
                result.TCSDBindingPeriod = item.TeliaSE_MC_Binding_Time__c;
            }
            line.isTCSD=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Mobile Offer Specification' ){
            line.isMob=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='OFFICE365 Offer Spec' ){
            line.is12B=true;
            result.isnonITDaaSTable = true;
            line.isO365=true;
            if(item.TeliaSE_MC_Binding_Time__c=='1 month'){
                line.is0B=true;
                line.is12B=true;
                line.is36B=false;                            
            }
            else if(item.TeliaSE_MC_Binding_Time__c=='12 months'){
                line.is0B=false;
                line.is12B=true;
                line.is36B=false;
            }
            else if(item.TeliaSE_MC_Binding_Time__c=='36 months'){
                line.is0B=false;
                line.is12B=true;
                line.is36B=true;
            }            
        }
        else if(item.ProductType__c=='Touch Point Offer Spec'){
            line.isTP=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Smart Offer Spec' ){
            line.isSS=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Insurance Offer Spec' ){
            line.isTF=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Personal Technician Offer Specification'){
            line.isPT=true;
            result.isnonITDaaSTable = true;
        }
        
        else if(item.ProductType__c=='ICT Offer Specification' ){
            line.isEUS=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Hardware Offer Spec' ){
            line.isHW=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Broadband Offer Specification' ){
            line.isBB=true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='TouchPoint Plus Offer Spec' ){
            line.isTPP = true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Operator Connect Offer Spec' && item.Product__r.TeliaSE_TemplateCategory__c == 'UserPackages'){
            line.isOcUserPkg = true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Operator Connect Offer Spec' && item.Product__r.TeliaSE_TemplateCategory__c != 'UserPackages'){
            line.isOcAddons = true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Smart Connect Offer Spec' && item.Product__r.TeliaSE_TemplateCategory__c != 'UserPackages'){  
            line.isScAddons = true;
            result.isnonITDaaSTable = true;
        }
        else if(item.ProductType__c=='Smart Connect Offer Spec' && item.Product__r.TeliaSE_TemplateCategory__c == 'UserPackages'){  
            line.isScUserPkg = true;
            result.isnonITDaaSTable = true;
            Id scKlusterID=Id.valueOf((item.TeliaSE_Product_Hierarchy__c.split('<'))[0]);  
            // added this for SC special table to display cluster names in offer docs   
            if(scCLusterIdToProductCode.get(scKlusterID)!=null){  
                String scClusterCode=scCLusterIdToProductCode.get(scKlusterID);  
                if(scClusterCode=='SC_KLU_BAS'){  
                    line.SCKlusterENG='For Jobbmobil BAS';  
                    line.SCKlusterSWE ='För Jobbmobil BAS';                                   
                }else if(scClusterCode=='SC_KLU_SMALL'){  
                    line.SCKlusterENG='For Jobbmobil 1-7GB';  
                    line.SCKlusterSWE='För Jobbmobil 1-7GB';
                }  
                else if(scClusterCode=='SC_KLU_MEDIUM'){  
                    line.SCKlusterENG='For Jobbmobil 10-25GB';   
                    line.SCKlusterSWE='För Jobbmobil 10-25GB';
                }  
                else if(scClusterCode=='SC_KLU_LARGE'){  
                    line.SCKlusterENG='For Jobbmobil 30-50GB'; 
                    line.SCKlusterSWE='För Jobbmobil 30-50GB';
                }  
                else if(scClusterCode=='SC_KLU_XLARGE'){  
                    line.SCKlusterENG='For Jobbmobil 80-Unlimited'; 
                    line.SCKlusterSWE='För Jobbmobil 80-Obegränsad';
                }  
                else if(scClusterCode=='SC_KLU_PLUS'){  
                    line.SCKlusterENG='For Jobbmobil Unlimited Plus';
                    line.SCKlusterSWE='För Jobbmobil Obegränsad Plus';
                }  
                else if(scClusterCode=='SC_KLU_LEGACY'){  
                    line.SCKlusterENG='';
                    line.SCKlusterSWE='';
                }  
            }
        }
        
        return line;
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Method is invoked for populating child item node for each root Item. 
* The method would return list<cls_ChildItem> node for each root product, populate flags for each product and sum.
* This method is specially made for mobile special addOns.
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - childList - List of childItems for each root. 
* params - line - Populate line flags as well.
* params - isSpecialAddon - sent as true for special addOns offerings.
*/
    public static list<cls_ChildItem> populateChildItem(resultMap result,List<TeliaSE_SimplifiedQuoteLineItem__c> childList,cls_Line line){
        Integer defaultFlag =0 , zeroFlag=0;
        Boolean isITDaaSCmpnyZero = false ,isITDaaSUsersZero=false,isITDaaSAddonsZero=false,isITDaaSCmpny=false,isITDaaSUsers=false;
        List<cls_ChildItem> childItemClass = new List<cls_ChildItem>();
        for(TeliaSE_SimplifiedQuoteLineItem__c child:childList){
            cls_ChildItem childItem = new cls_ChildItem();
            childItem.Qn = (Integer)child.TeliaSE_Aggregated_Quantity__c;
            childItem.RTCSum = math.round(child.TeliaSE_Recurring_Total__c);
            childItem.RTC=child.TeliaSE_List_Price__c;
            childItem.SwedishName = child.ProductName__c;
            childItem.OTC = (Integer)child.TeliaSE_OnetimeCharge__c;
            childItem.OneTimeTotal=(Integer)child.TeliaSE_One_Time_Total__c;
            childItem.EnglishName=child.Product__r.MC_Product_Name_Eng__c;
            childItem.Tmpflg=child.Product__r.TeliaSE_OfferTemplateFlag__c;
            if(child.MC_TeliaExcludeQuoteItem__c == true){
                if(child.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_Company'){
                    childItem.isITDaaSCmpnyZero = true;
                    result.isITDaaSCmpnyZero = true;
                }else{
                    childItem.isITDaaSCmpnyZero = false;
                }
                if(child.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_Users'){
                    childItem.isITDaaSUsersZero = true;
                    result.isITDaaSUsersZero = true;
                }else{
                    childItem.isITDaaSUsersZero = false;
                }
                if(child.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_AddOns'){
                    childItem.isITDaaSAddonsZero = true;
                    result.isITDaaSAddonsZero = true;
                }else{
                    childItem.isITDaaSAddonsZero = false;
                }
                childItem.ExcludeItem = child.MC_TeliaExcludeQuoteItem__c;
                childItem.isDefaultTable = 0;
                childItem.isZeroTable = 1;
                zeroflag=1;
            }else{
                if(child.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_Company'){
                    childItem.isITDaaSCompany=true;
                    result.isITDaaSCmpny =true;
                    result.TotalRTCCompany = result.TotalRTCCompany + child.TeliaSE_Recurring_Total__c;
                }else{
                    childItem.isITDaaSCompany=false;
                }
                if(child.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_Users'){
                    childItem.isITDaaSUsers=true;
                    result.isITDaaSUsers = true;
                    result.TotalRTCUser = result.TotalRTCUser + child.TeliaSE_Recurring_Total__c;
                    result.RTCUser = result.RTCUser + child.TeliaSE_List_Price__c; //Added for SALEF-7084
                }else{
                    childItem.isITDaaSUsers=false;
                }
                if(child.Product__r.TeliaSE_TemplateCategory__c== 'ITDaaS_AddOns'){
                    childItem.isITDaaSAddons=true;
                    result.isITDaaS2= true;
                    result.TotalSumITDaasRTC = result.TotalSumITDaasRTC + child.TeliaSE_Recurring_Total__c;
                }else{
                    childItem.isITDaaSAddons=false;
                }
                childItem.ExcludeItem=child.MC_TeliaExcludeQuoteItem__c;
                childItem.isDefaultTable=1;
                childItem.isZeroTable=0;
                defaultflag=1;
            }
            if(child.Product__r.TeliaSE_TemplateCategory__c== 'Användarpaket'){//Added to display TPP anvandarpaket 1st in table(TPP Improvement)-By Abhishek
                result.isAnvandarpaket=true;
            }
            childItemClass.add(childItem);
        }
        line.isZeroTable = zeroflag;
        line.isDefaultTable = defaultflag;
        if(result.isITDaaSCmpny || result.isITDaaSUsers){
            result.isITDaaS1=true;
        }
        result.TotalSumRTC = result.TotalRTCCompany + result.TotalRTCUser;
        result.TotalITDaaSRTC = result.TotalSumRTC+ result.TotalSumITDaasRTC;
        return childItemClass;
    }        
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is invoked for calculating total for the offerQuote. 
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
*/
    public static void populateFlagsAndTotals(resultMap result){                
        List<cls_Line> lineNode = result.Line;
        for(cls_Line line:lineNode){
            if(line.isZeroTable==1){
                zeroProductFlag(result,line);
                result.isZerotable = true; 
            }
            if(line.isDefaultTable==1){
                defaultProductFlags(result,line);
                populateTotals(result,line);
                result.isDefaultTable = true;                
            }
        }
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method would populates the Zero table tokens for products (Zero table is populated when the item is excluded of price tables). 
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - Line - Line node is sent to populate the zero table flags.
*/
    public static void zeroProductFlag(resultMap result,cls_Line line){        
        if(line.Type.contains('ITDaaS Offer Spec')){  
            if(line.ProductCode.contains('ITDAAS_START')){  
                result.isITDaaSStartZero = true;
            } 
            else if(line.ProductCode.contains('ITS')){
                result.isITSupportStandardZero = true;  
            }
            else if(line.ProductCode.contains('ITP')){
                result.isITSupportPlusZero = true;  
            } 
            else{  
                result.isITDaaSZero= true;
            }  
        }
        if(line.Type=='Broadband Start Offering Spec'){
            result.isTBSZero =true;
        }
        else if(line.Type=='Broadband Plus Offering Spec' ){
            result.isTBPLZero =true;            
        }
        else if(line.Type=='Broadband Pro Offering Spec'){
            result.isTBPRZero =true;
        }
        else if(line.Type=='Broadband Datanet Offering Spec'){
            result.isTDNZero = true;
        }
        else if(line.Type=='WIFI/LAN Offering Spec'){
            result.isTCWIZero = true;
        }
        else if(line.Type=='SD-WAN/Firewall Offering Spec'){
            result.isTCSDZero =true;
        }
        else if(line.Type=='Mobile Offer Specification'){
            result.isJobMobile1Zero=true;
        }
        else if(line.Type=='OFFICE365 Offer Spec'){
            if(line.BindingTime == '1 month')
            {
                result.is3651ZeroB0 = true;
            }
            else if(line.BindingTime == '12 months')
            {
                result.is3651ZeroB12 = true;                                    
            }
            else if (line.BindingTime == '36 months')
            {
                result.is3651ZeroB36 = true;
            }
            result.is3651Zero=true;
        }
        else if(line.Type=='Touch Point Offer Spec'){
            result.isTP1Zero = true;
        }
        else if(line.Type=='TouchPoint Plus Offer Spec'){
            result.isTPP1Zero = true;
        }
        else if(line.Type=='Operator Connect Offer Spec'){
            result.isOC1Zero = true;
        }
        else if(line.Type=='Smart Offer Spec'){
            result.isSS1Zero= true;
        }
        else if(line.Type=='Insurance Offer Spec'){
            result.isFT1Zero = true;
        }
        else if(line.Type=='Personal Technician Offer Specification'){
            result.isPT1Zero = true;
        }
        else if(line.Type=='ICT Offer Specification'){
            result.isEUS1Zero=true;
        }
        else if(line.Type=='Hardware Offer Spec'){
            result.isHWZero = true;
        }
        else if(line.Type=='Broadband Offer Specification'){
            result.isMobile1Zero=true;
        }
        else if(line.Type=='Smart Connect Offer Spec'){
            result.isSmartConnectV31Zero=true;
            /*item.ProductType__c=='Smart Connect Offer Spec' && item.Product__r.TeliaSE_TemplateCategory__c == 'UserPackages'
Line:787 else if condition modified for MCSTO-10268*/
        }
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method would populates the Price table tokens for products (price table is populated when the item is included in price tables).
* This Method would also be used for calculating the offerings total as well.
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - Line - Line node is sent to populate the price table flags.
*/
    public static void defaultProductFlags(resultMap result, cls_Line line){
        if(line.Type.contains('ITDaaS Offer Spec')){  
            if(line.ProductCode.contains('ITDAAS_START')){
                result.isITDaaSStartincart = true;
                result.isITDaaSincart2 = true;
            }
            else if(line.ProductCode.contains('ITS')){
                result.isITSupportStandardincart = true;  
            }
            else if(line.ProductCode.contains('ITP')){
                result.isITSupportStandardPlusincart = true;
            }  
            else{  
                result.isITDaaSincart= true;
                result.isITDaaSincart1 = true;
            }
        }
        if(line.Type != 'ITDaaS Offer Spec'){
            result.isITDaaSincart3 = true;
        }
        if(line.Type=='Broadband Start Offering Spec'){
            result.isTBS1 = true;
            result.isNT = true;
        }
        else if(line.Type=='Broadband Plus Offering Spec'){
            result.isTBPL1 = true;
            result.isNT = true;
        }
        else if(line.Type=='Broadband Pro Offering Spec'){
            result.isTBPR1 = true;
            result.isNT = true;
        }
        else if(line.Type=='Broadband Datanet Offering Spec'){
            result.isTDN1 =true;
            result.isNT = true;
        }
        else if(line.Type=='WIFI/LAN Offering Spec'){
            result.isTCWI1=true;
            result.isNT = true;
        }
        else if(line.Type=='SD-WAN/Firewall Offering Spec'){
            result.isTCSD1=true;
            result.isNT = true;
        }
        else if(line.Type=='Mobile Offer Specification'){
            result.isJobMobile1=true;
        }
        else if(line.Type=='OFFICE365 Offer Spec'){
             result.is3651B12 = true;
            if(line.BindingTime == '1 month')
            {
                result.is3651B0 = true;   
            }
            else if(line.BindingTime == '12 months')
            {
                result.is3651B12 = true;
            }
            else if(line.BindingTime == '36 months')
            {
                result.is3651B36 = true;
            }
            result.is3651 = true;
        }
        else if(line.Type=='Touch Point Offer Spec'){
            result.isTP1 = true;
        }
        else if(line.Type=='Operator Connect Offer Spec'){
            result.isOC1 = true;
        }
        else if(line.Type=='TouchPoint Plus Offer Spec'){
            result.isTPP1 = true;
        }
        else if(line.Type=='Smart Offer Spec'){
            result.isSS1=true;
        }
        else if(line.Type=='Insurance Offer Spec'){
            result.isTF1 = true;
        }
        else if(line.Type=='Personal Technician Offer Specification'){
            result.isPT1 =true;
        }
        else if(line.Type=='ICT Offer Specification'){
            result.isEUS1=true;
        }
        else if(line.Type=='Hardware Offer Spec'){
            result.isHW = true;
        }
        else if(line.Type=='Broadband Offer Specification'){
            result.isMobile1=true;
        }
        else if(line.Type=='Smart Connect Offer Spec') {
            result.isSmartConnectV3=true;
        }        
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method would populates totals for each offer. Each line is sent to calculate totals for every offering type we have.
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - Line - Line node is sent to populate the price table flags.
*/
    public static void populateTotals(resultMap result, cls_Line line){
        if(line.Type!='ITDaaS Offer Spec'){
            result.TotalOTC = result.TotalOTC + line.OneTimeTotal;
            result.TotalRTC = result.TotalRTC + line.RTCSum;
            populateObjectTypeTotals(result,line,line.RTCSum,line.OneTimeTotal);
            if(line.ChildItem!=null && line.ChildItem.size()>0){
                for(cls_ChildItem child : line.ChildItem){
                    if(child.isDefaultTable==1){
                        populateObjectTypeTotals(result,line,child.RTCSum,child.OneTimeTotal);
                        result.TotalOTC = result.TotalOTC + child.OneTimeTotal;
                        result.TotalRTC = result.TotalRTC + child.RTCSum;    
                    }
                    
                }
            }            
        }        
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This sub - method would also be used for calculating the offerings total as well.
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - Line - Line node is sent to populate the price table flags.
* params - rtcTotal - recurring fee sum
* params - otcTotal - oneTime fee sum
*/
    public static void populateObjectTypeTotals(resultMap result,cls_Line line,Integer rtcTotal ,Integer otcTotal){
        if(line.Type=='ICT Offer Specification'){
            result.TotalEUSOTC = result.TotalEUSOTC + otcTotal;
            result.TotalEUSRTC = result.TotalEUSRTC + rtcTotal;
        }
        if(line.Type=='Hardware Offer Spec'){
            result.TotalHWOTC = result.TotalHWOTC + otcTotal; 
            result.TotalHWRTC = result.TotalHWRTC + rtcTotal;
        }
        if(line.Type=='Broadband Offer Specification'){                        
            result.TotalMBBOTC = result.TotalMBBOTC + otcTotal;
            result.TotalMBBRTC = result.TotalMBBRTC + rtcTotal;
        }
        if(line.Type=='Mobile Offer Specification'){
            result.TotalJobbMobilOTC = result.TotalJobbMobilOTC + otcTotal;
            result.TotalJobbMobilRTC = result.TotalJobbMobilRTC + rtcTotal;            
        }
        if(line.Type=='Insurance Offer Spec'){
            result.TotalInsOTC = result.TotalInsOTC + otcTotal;
            result.TotalInsRTC = result.TotalInsRTC + rtcTotal;            
        }
        if(line.Type=='Connected Office Offer Spec'){
            result.TotalHERAOTC = result.TotalHERAOTC + otcTotal;
            result.TotalHERARTC = result.TotalHERARTC + rtcTotal;
        }
        if(line.Type=='Broadband Datanet Offering Spec'){
            result.TotalTDN1OTC = result.TotalTDN1OTC + otcTotal;
            result.TotalTDN1RTC = result.TotalTDN1RTC + rtcTotal;
        }
        if(line.Type=='Broadband Plus Offering Spec'){
            result.TotalTBPL1OTC = result.TotalTBPL1OTC + otcTotal;
            result.TotalTBPL1RTC = result.TotalTBPL1RTC + rtcTotal;
        }
        if(line.Type=='Broadband Pro Offering Spec'){
            result.TotalTBPR1OTC = result.TotalTBPR1OTC + otcTotal;
            result.TotalTBPR1RTC = result.TotalTBPR1RTC + rtcTotal;
        }
        if(line.Type=='Broadband Start Offering Spec'){
            result.TotalTBS1OTC = result.TotalTBS1OTC + otcTotal;
            result.TotalTBS1RTC = result.TotalTBS1RTC + rtcTotal;
        }
        if(line.Type=='SD-WAN/Firewall Offering Spec'){
            result.TotalTCSD1OTC = result.TotalTCSD1OTC + otcTotal;
            result.TotalTCSD1RTC = result.TotalTCSD1RTC + rtcTotal;
        }
        if(line.Type=='WIFI/LAN Offering Spec'){
            result.TotalTCWI1OTC = result.TotalTCWI1OTC + otcTotal;
            result.TotalTCWI1RTC = result.TotalTCWI1RTC + rtcTotal;
        }
        if(line.Type=='Touch Point Offer Spec'){
            result.TotalTouchPointOTC = result.TotalTouchPointOTC + otcTotal;
            result.TotalTouchPointRTC = result.TotalTouchPointRTC + rtcTotal;
        }
        if(line.Type=='TouchPoint Plus Offer Spec'){
            result.TotalTouchPointPlusOTC = result.TotalTouchPointPlusOTC + otcTotal;
            result.TotalTouchPointPlusRTC = result.TotalTouchPointPlusRTC + rtcTotal;
        }
        if(line.Type=='Operator Connect Offer Spec'){
            result.TotalOperatorConnectOTC = result.TotalOperatorConnectOTC + otcTotal;
            result.TotalOperatorConnectRTC = result.TotalOperatorConnectRTC + rtcTotal;
        }
        //Start Added Code for O365 (MCSTO-11111)
        if(line.Type=='OFFICE365 Offer Spec'){            
            if(line.BindingTime == '1 month'){
                result.TotalOffice365B0OTC = result.TotalOffice365B0OTC + otcTotal;
                result.TotalOffice365B0RTC = result.TotalOffice365B0RTC + rtcTotal;
            }
            else if(line.BindingTime == '12 months'){
                result.TotalOffice365B12OTC = result.TotalOffice365B12OTC + otcTotal;
                result.TotalOffice365B12RTC = result.TotalOffice365B12RTC + rtcTotal;        
            }
            else if (line.BindingTime == '36 months'){
                result.TotalOffice365B36OTC = result.TotalOffice365B36OTC + otcTotal;
                result.TotalOffice365B36RTC = result.TotalOffice365B36RTC + rtcTotal;
            }
        }        
        if(line.Type=='Personal Technician Offer Specification'){
            result.TotalPersonalOTC = result.TotalPersonalOTC + otcTotal;
            result.TotalPersonalRTC = result.TotalPersonalRTC + rtcTotal;
        }
        if(line.Type=='Smart Offer Spec'){
            result.TotalSmartSecOTC = result.TotalSmartSecOTC + otcTotal;
            result.TotalSmartSecRTC = result.TotalSmartSecRTC + rtcTotal;
        }
        if(line.Type=='Smart Connect Offer Spec'){
            result.TotalSmartConnectOTC = result.TotalSmartConnectOTC + otcTotal;
            result.TotalSmartConnectRTC = result.TotalSmartConnectRTC + rtcTotal;
        }    
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is used for the scenario when we have No grouping for CO and only Hera ionformation added.
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - heraList - List of only Hera items.
*/
    public static void onlyHeraPopulate(resultMap result, List<TeliaSE_SimplifiedQuoteLineItem__c> heraList){        
        List<cls_heraItems> COItems = new List<cls_heraItems>();
        //Fetching Label values for Heratypes.
        Schema.DescribeFieldResult fieldResult = TeliaSE_SimplifiedQuoteLineItem__c.MC_HeraType__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        Map<String,String> heraTypevalues = new Map<String,String>();
        for(Schema.PicklistEntry v: values){
            heraTypevalues.put(v.getValue(),v.getLabel());
        }
        for(TeliaSE_SimplifiedQuoteLineItem__c item:heraList){
            cls_heraItems hera = new cls_heraItems();
            hera.isHERA=true;
            hera.Qn=item.TeliaSE_Aggregated_Quantity__c;
            hera.RTC=item.TeliaSE_List_Price__c;
            hera.OTC=item.TeliaSE_OnetimeCharge__c;
            hera.HeraType = item.MC_HeraType__c;
            hera.HeraTypeSWE = heraTypevalues.get(item.MC_HeraType__c);
            result.TotalOTC = result.TotalOTC + math.round(item.TeliaSE_OnetimeCharge__c);
            result.TotalRTC = result.TotalRTC + math.round(item.TeliaSE_List_Price__c);            
            result.TotalHERAOTC = result.TotalHERAOTC + math.round(item.TeliaSE_OnetimeCharge__c);
            result.TotalHERARTC = result.TotalHERARTC + math.round(item.TeliaSE_List_Price__c);
            if((item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c!=null) && (item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c!=null) && (item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c!=null)){
                hera.StreetName=String.valueOf(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c).toUpperCase();
                hera.City=' '+String.valueOf(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c).toUpperCase();
                hera.StreetAd=' '+String.valueOf(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c).toUpperCase();
                if((item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                    hera.Lat = '. Lat: '+(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                    hera.Lon = ', Long: '+(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                }}       
            else if((item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                hera.Lat='Lat: '+(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                hera.Lon=', Long: '+(item.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
            }
            COItems.add(hera);
        }
        result.COItems=COItems;
        result.isOnlyHERA = true;
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is used for populating CO site information from servicePoint Object
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - allPrems - List of only servicePoints.
*/
    //===
    /*    public static void siteInfoSlaAdd (resultMap result,list<vlocity_cmt__ServicePoint__c> allPrems){ 
list<cls_SLA> slaList = new List<cls_SLA>();        
for(vlocity_cmt__ServicePoint__c site:AllPrems){           
cls_SLA sl = new cls_SLA();                   
if((site.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c!=null) || (site.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c!=null) || (site.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c!=null)){
sl.StreetName=String.valueOf(site.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c).toUpperCase();
sl.StreetAd=' '+String.valueOf(site.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c).toUpperCase();
sl.City=' '+site.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c.toUpperCase();   
if((site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
sl.Lat = '. Lat: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
sl.Lon = ', Long: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
}
}      
else if((site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
sl.Lat = 'Lat: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
sl.Lon = ', Long: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
}                  
if(site.MC_IS_SLA_C4_Available__c== true){ 
result.SLAtable = true;
sl.isSLAC4 = site.MC_IS_SLA_C4_Available__c?'Ja':'Nej'; 
slaList.add(sl);
}                               
}
result.SLA =slaList;
}    */
    public static void siteInfo (resultMap result,list<vlocity_cmt__ServicePoint__c> allPrems)
    {
        list<cls_ST> stList = new List<cls_ST>();        
        for(vlocity_cmt__ServicePoint__c site:AllPrems){
            if((result.groupedSites!=null && !result.groupedSites.contains(site.id)) || result.groupedSites==null){
                cls_ST st = new cls_ST();
                if((site.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c!=null) || (site.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c!=null) || (site.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c!=null)){
                    st.StreetName=String.valueOf(site.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c).toUpperCase();
                    st.StreetAd=' '+String.valueOf(site.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c).toUpperCase();
                    st.City=' '+site.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c.toUpperCase();
                    if((site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                        st.Lat = '. Lat: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                        st.Lon = ', Long: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                    } 
                }else if((site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                    st.Lat = 'Lat: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                    st.Lon = ', Long: '+(site.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                }     
                if(isExistSLAC4 == true){
                    st.isSLAC4 = site.MC_IS_SLA_C4_Available__c?'Ja':'Nej';
                }       
                stList.add(st);
                result.isAdditionalSites=true;
            }
        }
        result.ST = stList;
    }
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is used for populating CO grouping information.
* The method would create a map which has group info as a key, value holds the list of all simplified lineitems.
* We iterate for each group and create a map for root to childItemList.
* Iterate over each root Item and populate groupLine nodes and subsequently childItems.
* Populate group totals for each group.
* Populate site info for each group.
*___________________________________________________________________________________________________________
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - groupingList - List of only simplifiedItems which are grouped in CO flow.
* params - siteMemberdetails - QuoteMember List.
*/
    public static void populateGroupingInfoTable (resultMap result, List<TeliaSE_SimplifiedQuoteLineItem__c> groupingList,List<vlocity_cmt__QuoteMember__c> siteMemberdetails){
        Set<String> coTypes= new Set<String>{'Broadband Start Offering Spec','Broadband Plus Offering Spec','Broadband Pro Offering Spec','Broadband Datanet Offering Spec','WIFI/LAN Offering Spec','SD-WAN/Firewall Offering Spec'};        
            Map<String,Decimal> initialOrderQuantityMap = new Map<String,Decimal>();
        Map<String,Decimal> aggregateQuantityMap = new Map<String,Decimal>();
        Map<String,Decimal> otfSet = new Map<String,Decimal>();
        Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>> grpProdToChildMap = new Map<String,list<TeliaSE_SimplifiedQuoteLineItem__c>>();
        List<cls_groups> groupList  = new List<cls_groups>();
        Decimal coDeductedOTFGrouping = 0;
        for(TeliaSE_SimplifiedQuoteLineItem__c obj : groupingList)
        {            
            //Assign groups to qlis
            List<TeliaSE_SimplifiedQuoteLineItem__c> childGrpList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            if(grpProdToChildMap.containsKey(String.valueOf(obj.Quote_Group__c))){
                childGrpList = grpProdToChildMap.get(String.valueOf(obj.Quote_Group__c)); 
            }
            childGrpList.add(obj);
            grpProdToChildMap.put(String.valueOf(obj.Quote_Group__c),childGrpList);
            //initialOrderQuantity
            if(obj.MC_Initial_Order_Quantity__c!= null){
                initialOrderQuantityMap.put(obj.Product_Code__c,obj.MC_Initial_Order_Quantity__c);    
            }
            otfSet.put(obj.Product_Code__c,obj.TeliaSE_OnetimeCharge__c);
            //Agreegate quantity
            decimal aggregateQuantity=0;
            if(aggregateQuantityMap.containsKey(obj.Product_Code__c)){
                aggregateQuantity = aggregateQuantityMap.get(obj.Product_Code__c); 
            }
            aggregateQuantity+=obj.TeliaSE_Aggregated_Quantity__c;
            aggregateQuantityMap.put(obj.Product_Code__c,aggregateQuantity);
        }
        
        if(initialOrderQuantityMap.keySet().size()>0){
            for(String prod:initialOrderQuantityMap.keySet()){
                coDeductedOTFGrouping  = coDeductedOTFGrouping + initialOrderQuantityMap.get(prod) * otfSet.get(prod);
            }
        }
        if(coDeductedOTFGrouping>0){
            result.TotalGRPDeductedCOOTF = integer.valueOf(coDeductedOTFGrouping);
        }
        List<Id> servicePointIds = new List<Id>();
        String Description='';
        //Fetching Label values for Heratypes.
        Schema.DescribeFieldResult fieldResult = TeliaSE_SimplifiedQuoteLineItem__c.MC_HeraType__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        Map<String,String> heraTypevalues = new Map<String,String>();
        for(Schema.PicklistEntry v: values){
            heraTypevalues.put(v.getValue(),v.getLabel());
        }
        for(String groupid:grpProdToChildMap.keySet()){
            Map<Id,List<TeliaSE_SimplifiedQuoteLineItem__c>> rootQliGrp = new Map<Id,List<TeliaSE_SimplifiedQuoteLineItem__c>>();
            List<TeliaSE_SimplifiedQuoteLineItem__c> qliList = grpProdToChildMap.get(groupId);
            cls_groups groupInfo = new cls_groups();
            //populate totals and populate group info
            
            for(TeliaSE_SimplifiedQuoteLineItem__c simpl1: qliList){
                List<TeliaSE_SimplifiedQuoteLineItem__c> qliRootGrpList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
                if(simpl1.TeliaSE_Parent_ItemId__c == null){
                    if(rootQliGrp.containsKey(simpl1.TeliaSE_Root_Product__c)){
                        qliRootGrpList = rootQliGrp.get(simpl1.TeliaSE_Root_Product__c);
                    }
                    qliRootGrpList.add(simpl1);
                    rootQliGrp.put(simpl1.TeliaSE_Root_Product__c,qliRootGrpList);
                }
            }
            for(TeliaSE_SimplifiedQuoteLineItem__c obj: qliList){
                List<TeliaSE_SimplifiedQuoteLineItem__c> qliRootGrpList = new List<TeliaSE_SimplifiedQuoteLineItem__c>(); 
                if(obj.TeliaSE_Parent_ItemId__c != null){
                    if(rootQliGrp.containsKey(obj.TeliaSE_Root_Product__c)){
                        qliRootGrpList = rootQliGrp.get(obj.TeliaSE_Root_Product__c);
                    }
                    qliRootGrpList.add(obj);
                    rootQliGrp.put(obj.TeliaSE_Root_Product__c,qliRootGrpList);
                }
                
                //group populate
                groupInfo.GroupName = obj.Quote_Group__r.Name;
                Description = obj.Quote_Group__r.vlocity_cmt__Description__c;
                groupInfo.groupIndex = Integer.valueOf(Description.substringAfter('Group ').replaceAll('[^0-9]', ''));
                groupInfo.TotalGRPALLOTC = groupInfo.TotalGRPALLOTC + obj.TeliaSE_One_Time_Total__c;
                groupInfo.TotalGRPALLRTC = groupInfo.TotalGRPALLRTC + obj.TeliaSE_Recurring_Total__c;
                result.TotalGRPOTC = result.TotalGRPOTC + obj.TeliaSE_One_Time_Total__c;
                result.TotalGRPRTC = result.TotalGRPRTC + obj.TeliaSE_Recurring_Total__c;
                // Totals for each offering and binding period populate
                populateTotalsGrouping(groupInfo,result,obj);
            }
            //populate childItemInfo
            List<cls_groupingItems> coItemslist = new List<cls_groupingItems>(); 
            for(String rootQli:rootQliGrp.keySet()){
                Boolean isHera = false;
                List<TeliaSE_SimplifiedQuoteLineItem__c> objList = rootQliGrp.get(rootQli);
                cls_groupingItems rootItemGrp = new cls_groupingItems();
                for(TeliaSE_SimplifiedQuoteLineItem__c obj:objList){          
                    if(obj.TeliaSE_Parent_ItemId__c == null){
                        if(obj.ProductType__c=='Connected Office Offer Spec'){
                            rootItemGrp = new cls_groupingItems();
                        }
                        rootItemGrp.OTC=obj.TeliaSE_OnetimeCharge__c;
                        rootItemGrp.RTC=obj.TeliaSE_List_Price__c;
                        rootItemGrp.Qn=obj.TeliaSE_Aggregated_Quantity__c;
                        rootItemGrp.ProductCode=obj.Product_Code__c;
                        rootItemGrp.SwedishName=obj.ProductName__c;
                        rootItemGrp.EnglishName=obj.Product__r.MC_Product_Name_Eng__c;
                        rootItemGrp.GroupExist=true;
                        rootItemGrp.GroupUnqIdent=obj.Quote_Group__r.vlocity_cmt__Description__c;
                        if(obj.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering'){
                            rootItemGrp.isSub=false;
                        }
                        if(obj.ProductType__c=='Broadband Start Offering Spec'){
                            rootItemGrp.isTBS=true;
                        }
                        else if(obj.ProductType__c=='Broadband Plus Offering Spec'){                            
                            rootItemGrp.isTBPL=true;
                        }
                        else if(obj.ProductType__c=='Broadband Pro Offering Spec'){
                            rootItemGrp.isTBPR=true;
                        }
                        else if(obj.ProductType__c=='Broadband Datanet Offering Spec'){
                            rootItemGrp.isTDN=true;
                        }
                        else if(obj.ProductType__c=='WIFI/LAN Offering Spec'){
                            rootItemGrp.isTCWI=true;
                        }
                        else if(obj.ProductType__c=='SD-WAN/Firewall Offering Spec'){
                            rootItemGrp.isTCSD=true;
                            //prodDetMap.put('isTCSD',true);
                        }
                        else if(obj.ProductType__c=='Connected Office Offer Spec'){
                            if(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c !=null){
                                rootItemGrp.StreetAd=' '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c.toUpperCase();
                            }
                            if(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c !=null){
                                rootItemGrp.StreetName = obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c.toUpperCase();
                            }
                            if(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c !=null){
                                rootItemGrp.City =' '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c.toUpperCase();
                            }
                            if(result.isSLAExistInCart == true){
                                rootItemGrp.isSLAC4 = obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.MC_IS_SLA_C4_Available__c?'Ja':'Nej';                          
                            }
                            if((obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c !=null)||(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c !=null)){
                                if((obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c!=null)&&(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                                    rootItemGrp.Lat = '. Lat: '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c;
                                    rootItemGrp.Lon = ', Long: '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c;
                                }}else{
                                    if((obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c!=null)&&(obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                                        rootItemGrp.Lat = 'Lat: '+ obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c;
                                        rootItemGrp.Lon = ', Long: '+obj.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c;
                                    }}
                            rootItemGrp.HeraType = obj.MC_HeraType__c;
                            rootItemGrp.HeraTypeSWE = heraTypevalues.get(obj.MC_HeraType__c);
                            rootItemGrp.isHERA=true;
                            isHera = true;
                            coItemslist.add(rootItemGrp);
                        }
                    }
                    else{
                        cls_ChildItem childItem = new cls_ChildItem();
                        childItem.SwedishName=obj.ProductName__c;
                        childItem.EnglishName=obj.Product__r.MC_Product_Name_Eng__c;
                        childItem.OTC=integer.valueOf(obj.TeliaSE_OnetimeCharge__c);
                        childItem.RTC=integer.valueOf(obj.TeliaSE_List_Price__c);
                        childItem.Qn=integer.valueOf(obj.TeliaSE_Aggregated_Quantity__c);
                        rootItemGrp.ChildItem.add(childItem); 
                    }    
                }
                if(!isHera){
                    coItemslist.add(rootItemGrp);    
                }                
            }
            groupInfo.COItems = coItemslist;
            //populate siteInfo
            List<cls_SP> spDetailsList = new List<cls_SP>();            
            for(vlocity_cmt__QuoteMember__c site:siteMemberdetails){
                if(site.vlocity_cmt__QuoteGroupId__c == groupid){
                    cls_SP siteDetails = new cls_SP(); 
                    if((site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c!=null) || (site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c!=null)||(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c!=null)){
                        siteDetails.StreetName =site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c.toUpperCase();
                        siteDetails.City=' '+site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c.toUpperCase();
                        siteDetails.StreetAd=' '+site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c.toUpperCase();
                        if((site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                            siteDetails.Lat = '. Lat: '+(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c);
                            siteDetails.Lon = ', Long: '+(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                        } 
                    }
                    else if((site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c !=null) && (site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c!=null)){
                        siteDetails.Lat ='Lat: '+site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c;
                        siteDetails.Lon = ', Long: '+(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                    }         
                    servicePointIds.add((Id)site.vlocity_cmt__ServicePointId__c);
                    spDetailsList.add(siteDetails);
                }
            }            
            groupInfo.SP = spDetailsList;
            groupList.add(groupInfo);
        }
        result.groupedSites = servicePointIds;        
        List<cls_groups> groupListSorted = groupSorting(groupList);
        result.group1 = groupListSorted;        
        result.TotalGRPOTC = result.TotalGRPOTC - coDeductedOTFGrouping > 0 ? result.TotalGRPOTC - coDeductedOTFGrouping : 0;
    }
    
    //LTA-264-Group Sorting Method- Sorting group on basis of Index
    public static List<cls_groups> groupSorting(List<cls_groups> groupList){
        cls_groups groupTemp = new cls_groups();
        for(Integer i=0;i<=groupList.size()-1;i++){
            for(Integer j=i+1;j<groupList.size();j++){
                cls_groups a = groupList[i];
                cls_groups b = groupList[j];
                if(a.groupIndex > b.groupIndex){
                    groupTemp =a;
                    groupList[i]= b;
                    groupList[j]= groupTemp;
                }
            }
        }
        return groupList;
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: OfferDoc Optimization
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method would populates totals for each offer. Each line is sent to calculate totals for every offering type we have.
*___________________________________________________________________________________________________________
* params - groupInfo - group is sent to populate group totals.
* params - resultMap - ResultMap class which hold all the tokens which are needed for offerDoc generation.
* params - obj - simplifiedLineItem.
*/
    public static void populateTotalsGrouping(cls_groups groupInfo , resultMap result,TeliaSE_SimplifiedQuoteLineItem__c obj){        
        if(obj.ProductType__c=='Broadband Start Offering Spec'){
            if(obj.TeliaSE_MC_Binding_Time__c !=null){
                groupInfo.TBSBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
            }
            groupInfo.istbstartG=true;
            result.isNT = true;
            groupInfo.TotalTBSOTC = groupInfo.TotalTBSOTC + obj.TeliaSE_One_Time_Total__c;
            groupInfo.TotalTBSRTC = groupInfo.TotalTBSRTC + obj.TeliaSE_Recurring_Total__c;
            
        }
        else if(obj.ProductType__c=='Broadband Plus Offering Spec'){
            if(obj.TeliaSE_MC_Binding_Time__c !=null){
                groupInfo.TBPlusBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
            }
            groupInfo.istbplusG=true;
            result.isNT = true;
            groupInfo.TotalTBPLOTC = groupInfo.TotalTBPLOTC + obj.TeliaSE_One_Time_Total__c;
            groupInfo.TotalTBPLRTC = groupInfo.TotalTBPLRTC + obj.TeliaSE_Recurring_Total__c;            
        }
        else if(obj.ProductType__c=='Broadband Pro Offering Spec'){
            if(obj.TeliaSE_MC_Binding_Time__c !=null){
                groupInfo.TBProBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
            }
            groupInfo.istbproG=true;
            result.isNT = true;
            groupInfo.TotalTBPROTC = groupInfo.TotalTBPROTC + obj.TeliaSE_One_Time_Total__c;
            groupInfo.TotalTBPRRTC = groupInfo.TotalTBPRRTC + obj.TeliaSE_Recurring_Total__c;            
        }
        else if(obj.ProductType__c=='Broadband Datanet Offering Spec'){
            if(obj.TeliaSE_MC_Binding_Time__c !=null){
                groupInfo.TDNBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
            }
            groupInfo.istdnG=true;
            result.isNT = true;
            groupInfo.TotalTDNOTC = groupInfo.TotalTDNOTC + obj.TeliaSE_One_Time_Total__c;
            groupInfo.TotalTDNRTC = groupInfo.TotalTDNRTC + obj.TeliaSE_Recurring_Total__c;            
        }
        else if(obj.ProductType__c=='WIFI/LAN Offering Spec'){
            if(obj.TeliaSE_MC_Binding_Time__c !=null){
                groupInfo.TCWIBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
            }
            groupInfo.istcwlG=true;
            result.isNT = true;
            groupInfo.TotalTCWIOTC = groupInfo.TotalTCWIOTC + obj.TeliaSE_One_Time_Total__c;
            groupInfo.TotalTCWIRTC = groupInfo.TotalTCWIRTC + obj.TeliaSE_Recurring_Total__c;             
        }
        else if(obj.ProductType__c=='SD-WAN/Firewall Offering Spec'){
            if(obj.TeliaSE_MC_Binding_Time__c !=null){
                groupInfo.TCSDBindingPeriod = obj.TeliaSE_MC_Binding_Time__c;
            }
            groupInfo.istcsdG=true;
            result.isNT = true;
            groupInfo.TotalTCSDOTC = groupInfo.TotalTCSDOTC + obj.TeliaSE_One_Time_Total__c;
            groupInfo.TotalTCSDRTC = groupInfo.TotalTCSDRTC + obj.TeliaSE_Recurring_Total__c;            
        }
        else if(obj.ProductType__c=='Connected Office Offer Spec'){            
            groupInfo.isHERA1=true;
            groupInfo.TotalHERAOTC = groupInfo.TotalHERAOTC + obj.TeliaSE_One_Time_Total__c;
            groupInfo.TotalHERARTC = groupInfo.TotalHERARTC + obj.TeliaSE_Recurring_Total__c;            
        }
    }
    
    /* Developer: Abhinav Gupta
* Description: Generic Method for Cluster Document Table. (offer Document Generation)
*/
    public static cls_ClusterAddons clusterTableDocument(List <QuoteLineItem> specialAddOnQlis,MC_ClusterTablePricing__mdt  prodMetaData)
    {
        Map<String,Object> clusterCodeToProductCode = (Map<String,Object>)json.deserializeUntyped(prodMetaData.ProductClusterCodeToClusterCode__c);
        Map<String,Object> GroupToAddOnList = new Map<String,Object>();
        if(prodMetaData.GroupClusterToAddOnMap__c != null)
        {
            GroupToAddOnList = (Map<String,Object>)json.deserializeUntyped(prodMetaData.GroupClusterToAddOnMap__c);
        }
        Boolean groupClustering = prodMetaData.GroupClustering__c;
        List<cls_AddOnChilds> addOnChildClasses = new List<cls_AddOnChilds>();
        Map<String,cls_AddOnChilds> addOnChildMap = new Map<String,cls_AddOnChilds>();
        Map<String,Object> uniqueQliCodeToAllQlisMap = new Map<String,Object>();        
        Map<String,String> groupProductIdsToName = new Map<String,String>();
        List<cls_AddOnGroups> addOnGroupsList = new List<cls_AddOnGroups>();
        String ClusterBASNIA='Ej vald i avtalet',ClusterSmallNIA='Ej vald i avtalet',ClusterMediumNIA='Ej vald i avtalet',ClusterLargeNIA='Ej vald i avtalet',Cluster80NIA='Ej vald i avtalet',ClusterUnlimNIA='Ej vald i avtalet',documentTemplateLanguage = 'SWE';
        for(QuoteLineitem specialAddOn:specialAddOnQlis){
            if(specialAddOn.vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c == 'SubscriptionOffering'){
                List < QuoteLineItem > correspondingQlis = new List < QuoteLineItem > ();
                if (uniqueQliCodeToAllQlisMap.get(specialAddOn.TeliaSE_Product_Code__c) == null) {
                    correspondingQlis.add(specialAddOn);
                }else{
                    correspondingQlis = (List<QuoteLineItem>)uniqueQliCodeToAllQlisMap.get(specialAddOn.TeliaSE_Product_Code__c);
                    correspondingQlis.add(specialAddOn);
                }
                uniqueQliCodeToAllQlisMap.put(specialAddOn.TeliaSE_Product_Code__c,correspondingQlis);
            }
            else if(specialAddOn.vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering')
            {                
                if (documentTemplateLanguage == 'SWE') {//if swedish template then add swedish group name
                    groupProductIdsToName.put(specialAddOn.TeliaSE_Product_Code__c, specialAddOn.vlocity_cmt__Product2Id__r.Name);
                } else {//else add english group name
                    if (specialAddOn.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c != null) {
                        groupProductIdsToName.put(specialAddOn.TeliaSE_Product_Code__c, specialAddOn.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c);
                        
                    } else {
                        groupProductIdsToName.put(specialAddOn.TeliaSE_Product_Code__c, '');   
                    }   
                }
            }                
        }
        
        for(String qliCode:uniqueQliCodeToAllQlisMap.keySet())
        {
            List<QuoteLineItem> addOnList = (List<QuoteLineItem>)uniqueQliCodeToAllQlisMap.get(qliCode); 
            cls_AddOnChilds addOnChild = new cls_AddOnChilds();                     
            for(QuoteLineItem qli : addOnList)
            {
                addOnChild.EnglishName = qli.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c;
                addOnChild.SwedishName = qli.vlocity_cmt__Product2Id__r.Name;
                Decimal rtc = qli.TeliaSE_MC_Customer_Requested_Price__c != null ? qli.TeliaSE_MC_Customer_Requested_Price__c : qli.vlocity_cmt__RecurringCharge__c;
                rtc = rtc.setScale(0);
                String cluster = (String)clusterCodeToProductCode.get(qli.TeliaSE_ParentClusterCode__c);
                switch on cluster {
                    when 'bas' {
                        ClusterBASNIA = '';
                        addOnChild.BASRTC = String.valueOf(rtc);                                  
                    }
                    when 'small' {
                        ClusterSmallNIA = '';
                        addOnChild.SMALLRTC = String.valueOf(rtc);                                        
                    }
                    when 'medium' {
                        ClusterMediumNIA = '';
                        addOnChild.MEDIUMRTC = String.valueOf(rtc);                                      
                    }
                    when 'large' {
                        ClusterLargeNIA = '';
                        addOnChild.LARGERTC = String.valueOf(rtc);                                 
                    }
                    when 'xlarge' {
                        Cluster80NIA = '';
                        addOnChild.XLARGERTC = String.valueOf(rtc);                                        
                    }
                    when 'plus' {
                        ClusterUnlimNIA = '';
                        addOnChild.PLUSRTC = String.valueOf(rtc);
                        
                    }    
                    when else  {
                        // nothing to be done
                    }                       
                }
                
                //Added by priya for LTAT-17280
                if(qli.TeliaSE_Product_Code__c == 'MOB_SP_ADDON_ABROAD_MAX' ){
                    addOnChild.PLUSRTC = '0';
                }
            }
            
            addOnChildMap.put(qliCode,addOnChild);
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
    /* to show Table for minute basted in quote document*/
    public static cls_isMinuteBasedAddon minutebasedmethod(List<QuoteLineItem> minuteBasesAddons) {
        cls_isMinuteBasedAddon minutebasedconst = new cls_isMinuteBasedAddon();
        
        if (minuteBasesAddons != null && minuteBasesAddons.size() > 0) {
            for (QuoteLineItem qli : minuteBasesAddons) {
                minutebasedconst.MinuteBasedReqPrice = qli.TeliaSE_MC_Customer_Requested_Price__c != null ? qli.TeliaSE_MC_Customer_Requested_Price__c : 0;
                minutebasedconst.otfPriceMB = qli.vlocity_cmt__OneTimeCharge__c != null ? qli.vlocity_cmt__OneTimeCharge__c : 0;
                minutebasedconst.SwedishNameMB = qli.vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c;
                minutebasedconst.EnglishNameMB = qli.vlocity_cmt__Product2Id__r.Name;
            }
        }
        
        return minutebasedconst;
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: LTAT-11747
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This Method is used to remove SEK currency prefix from all document tokens we have added to convert each currency type.
* This Method is called as custom function from dataraptors to remove the SEK.
*___________________________________________________________________________________________________________
* params - inputMap - It contains arguments, First is the resultMap, second is the document being treated
* params - outputMap - We send the result back to the DR from here.
*/
    public static void trimCurrencyPrefix(Map<String,Object> inputMap , Map<String,Object> outputMap){
        List<Object> arguments = (List<Object>)inputMap.get('arguments');
        Map<String,Object> resultMap = (Map<String,Object>)arguments[0];
        //Converting the resultMap to json string.
        String b,tr,tbr,a = JSON.serialize(resultMap);
        tr = 'OTC'+'\"'+':' +'\"'+'SEK';
        tbr = 'OTC'+'\"'+':'+'\"';
        //Replacing OTC":"SEK string with OTC":" String in the Json to remove SEK keyword.
        b = a.replaceAll(tr,tbr);
        tr = 'RTC'+'\"'+':' +'\"'+'SEK';
        tbr = 'RTC'+'\"'+':'+'\"';
        b = b.replaceAll(tr,tbr);
        tr = 'OTF'+'\"'+':' +'\"'+'SEK';
        tbr = 'OTF'+'\"'+':'+'\"';
        b = b.replaceAll(tr,tbr);          
        tr = 'OneTimeTotal'+'\"'+':' +'\"'+'SEK';
        tbr = 'OneTimeTotal'+'\"'+':'+'\"';
        b = b.replaceAll(tr,tbr);
        tr = 'RTCSum'+'\"'+':' +'\"'+'SEK';
        tbr = 'RTCSum'+'\"'+':'+'\"';
        b = b.replaceAll(tr,tbr);
        Map<String,Object> resultMap2 = (Map<String,Object>)JSON.deserializeUntyped(b);
        
        // Special Tokens which dont fall under the generic scheme.
        /*if(String.valueOf(arguments[1]) == 'OfferDocument'){
//resultMap2.put('TotalOffice365RTCB36',String.ValueOf(resultMap2.get('TotalOffice365RTCB36')).substringAfter('K'));
resultMap2.put('TotalOffice365B12RTC',String.ValueOf(resultMap2.get('TotalOffice365B12RTC')).substringAfter('K'));
resultMap2.put('TotalOffice365B0RTC',String.ValueOf(resultMap2.get('TotalOffice365B0RTC')).substringAfter('K'));
resultMap2.put('TotalOffice365B36OTC',String.ValueOf(resultMap2.get('TotalOffice365B36OTC')).substringAfter('K'));
resultMap2.put('TotalOffice365B12OTC',String.ValueOf(resultMap2.get('TotalOffice365B12OTC')).substringAfter('K'));
resultMap2.put('TotalOffice365B0OTC',String.ValueOf(resultMap2.get('TotalOffice365B0OTC')).substringAfter('K'));
resultMap2.put('TotalRTCUser',String.ValueOf(resultMap2.get('TotalRTCUser')).substringAfter('K'));
resultMap2.put('TotalITDaaSRTC',String.ValueOf(resultMap2.get('TotalITDaaSRTC')).substringAfter('K'));
resultMap2.put('TotalITDaaSRTC',String.ValueOf(resultMap2.get('TotalITDaaSRTC')).substringAfter('K'));
resultMap2.put('TotalRTCSum',String.ValueOf(resultMap2.get('TotalRTCSum')).substringAfter('K'));
resultMap2.put('TotalRTCCompany',String.ValueOf(resultMap2.get('TotalRTCCompany')).substringAfter('K'));       
resultMap2.put('RTCUser',String.ValueOf(resultMap2.get('RTCUser')).substringAfter('K'));
}*/
        
        outputMap.put('result',resultMap2); 
    }
    
    public class resultMap{
        public Boolean isB2B = false,SLAtable =false,isSLAExistInCart=false,GroupExist = false,isAdditionalSites = false,isReNeg =false,is365 = false,isOC= false,isEUS = false,isJobMobile = false,isJM = false,isSC = false,isMobile = false,isPT = false,isOnlyHERA = false,isSS = false , isTBPL = false , isTDN = false , isTBPR=false , isTBS = false , isTCSD = false , isTCWI = false , isTP = false , isTPP = false , isTF = false , isITDaaS = false , isITDaaSStart = false ,isZeroTable = false,isDefaultTable = false,isITDaaSincart2=false,isITDaaSincart1=false,isnonITDaaSTable=false,isITDaaS1=false,isITDaaS2=false,isAnvandarpaket=false,isITDaaSCmpny=false,isITDaaSUsers=false,isITDaaSAddonsZero=false,isITDaaSCmpnyZero=false,isITDaaSUsersZero=false,isITDaaSStartZero=false,isITDaaSZero=false,isTBSZero=false,isTBPLZero=false,isTBPRZero=false,isTDNZero=false,isTCWIZero=false,isTCSDZero=false,isJobMobile1Zero=false,is3651ZeroB0=false,is3651ZeroB12=false,is3651ZeroB36=false,is3651Zero=false,isTP1Zero=false,isOC1Zero=false,isTPP1Zero=false,isSS1Zero=false,isFT1Zero=false,isPT1Zero=false,isEUS1Zero=false,isHWZero=false,isMobile1Zero=false,isSmartConnectV31Zero=false,isITDaaSStartincart=false,isITDaaSincart=false,isITDaaSincart3=false,isTBS1=false,isNT=false,isTBPL1=false,isTBPR1=false,isTDN1=false,isTCWI1=false,isTCSD1=false,isJobMobile1=false,is3651B0=false,is3651B12=false,is3651B36=false,is3651=false,isTP1=false,isOC1=false,isTPP1=false,isSS1=false,isTF1=false,isPT1=false,isEUS1=false,isHW=false,isMobile1=false,isSmartConnectV3=false,isReNegCO=false,isITSupportStandard=false,isITSupportPlus=false,isITSupportStandardincart=false,isITSupportStandardPlusincart=false,isITSupportStandardZero=false,isITSupportPlusZero=false;
        public Decimal TotalRTCCompany=0,TotalRTCUser=0,TotalSumRTC=0,RTCUser=0,TotalSumITDaasRTC=0,TotalITDaaSRTC=0,MAA = 0.0 , MAF = 0.0,TotalGRPOTC=0,TotalGRPRTC=0;        
        public List<cls_Line> Line;
        public List<cls_heraItems> COItems;
        public List<cls_ST> ST;                
        public List<cls_SLA> SLA;         
        public Integer TotalOTC=0,TotalRTC=0,TotalDeductedOTF=0,TotalGRPDeductedCOOTF=0,TotalEUSOTC=0,TotalEUSRTC=0,TotalHWOTC=0,TotalHWRTC=0,TotalMBBOTC=0,TotalMBBRTC=0,TotalJobbMobilOTC=0,TotalJobbMobilRTC=0,TotalInsOTC=0,TotalInsRTC=0,TotalHERAOTC=0,TotalHERARTC=0,TotalTDN1OTC=0,TotalTDN1RTC=0,TotalTBPL1OTC=0,TotalTBPL1RTC=0,TotalTBPR1OTC=0,TotalTBPR1RTC=0,TotalTBS1OTC=0,TotalTBS1RTC=0,TotalTCSD1OTC=0,TotalTCSD1RTC=0,TotalTCWI1OTC=0,TotalTCWI1RTC=0,TotalTouchPointOTC=0,TotalTouchPointRTC=0,TotalTouchPointPlusOTC=0,TotalTouchPointPlusRTC=0,TotalOffice365B0OTC=0,TotalOffice365B0RTC=0,TotalOffice365B12OTC=0,TotalOffice365B12RTC=0,TotalOffice365B36OTC=0,TotalOffice365B36RTC=0,TotalPersonalOTC=0,TotalPersonalRTC=0,TotalSmartSecOTC=0,TotalSmartSecRTC=0,TotalSmartConnectOTC=0,TotalSmartConnectRTC=0,TotalOperatorConnectOTC=0,TotalOperatorConnectRTC=0;
        public String TBSBindingPeriod='',TBPlusBindingPeriod='',TBProBindingPeriod='',TDNBindingPeriod='',TCWIBindingPeriod='',TCSDBindingPeriod='';        
        public List<cls_groups> group1;
        public cls_ClusterAddons isTotalClusterAddons;
        public cls_ClusterAddons isALLINClusterAddons;
        public cls_isMinuteBasedAddon isMinutebased;
        public List<Id> groupedSites;  
      
       
    }
    
    public class cls_Line {
        
        public Boolean isScUserPkg= false,isOcUserPkg= false,isOcAddons= false,isScAddons= false,isTPP= false,isTBS= false,isTBP= false,isTBPR= false,isTDN= false,isTCWI= false,isTBPL=false,isTCSD= false,isMob= false,isO365= false,isTP= false,isSS= false,isTF= false,isPT= false,isEUS= false,isHW= false,isBB= false,isSub=true,is0B= false,is12B= false,is36B= false,isAnvandarpaket= false,ExcludeItem= false,isITDaaSUsers=false,isITDaaSUsersZero=false;        
        
        public Integer isZeroTable = 0,isDefaultTable = 0,OneTimeTotal,OTC,RTCSum,Qn;
        public cls_ChildItem[] ChildItem;
        public Map<String,cls_ChildItem> childItemMap = null;
        public String SCKlusterSWE= '',SCKlusterENG= '',EnglishCampaignName='',CampaignName= null,EnglishName= '',SwedishName='',Type='',ProductCode='',BindingTime ='';
        public Decimal RTC;
        
    }
    
    public class cls_ChildItem {
        public Integer isZeroTable,isDefaultTable,OneTimeTotal,OTC,RTCSum,Qn;        
        public Boolean ExcludeItem=false,isITDaaSAddons=false,isITDaaSUsers=false,isITDaaSCompany=false,Tmpflg=false,isITDaaSAddonsZero=false,isITDaaSUsersZero=false,isITDaaSCmpnyZero=false;
        public String EnglishName='',SwedishName='';
        public Decimal RTC;
        
    }
    
    public class cls_heraItems{
        public String StreetName='',City='',StreetAd='',CampaignName='',EnglishCampaignName='',HeraType='',HeraTypeSWE='',Lat='',Lon='';
        public decimal Qn=0,RTC=0,OTC=0;    
        public Boolean isHERA = false;    
    }
    
    public class cls_ST{
        public string StreetName='',StreetAd='',City='',Lat='',Lon='',isSLAC4='';
        public Boolean isSLAInCart = false;
    }
    public class cls_SLA{
        public string StreetName='',StreetAd='',City='',Lat='',Lon='',isSLAC4='';
    }
    
    public class cls_SP{
        public string StreetName='',StreetAd='',City='',Lat='',Lon='';
    }
    
    public class cls_groupingItems{
        public List<cls_ChildItem> ChildItem = new List<cls_ChildItem>();
        public Decimal OTC=0,RTC=0,Qn=0;
        public String ProductCode='',SwedishName='',EnglishName='',GroupUnqIdent='',StreetAd='',StreetName='',City='',HeraType='',HeraTypeSWE='',Lat='',Lon='',isSLAC4='';
        public Boolean isTBS=false,isTBPL=false,isTBPR=false,isTDN=false,isTCWI=false,isTCSD=false,isHERA=false,GroupExist=false,isSub=true;
    }
    
    Public class cls_groups{
        public Boolean istbstartG=false,istbplusG=false,istbproG=false,istdnG=false,istcwlG=false,istcsdG=false,isHERA1=false;
        public String  TDNBindingPeriod='',TBPlusBindingPeriod='',TBProBindingPeriod='',TBSBindingPeriod='',TCSDBindingPeriod='',TCWIBindingPeriod='',GroupName='',Lat='',Lon='',isSLAC4='';
        public decimal TotalTDNOTC=0,TotalTDNRTC=0,TotalTBPLOTC=0,TotalTBPLRTC=0,TotalTBPROTC=0,TotalTBPRRTC=0,TotalTBSOTC=0,TotalTBSRTC=0,TotalTCSDOTC=0,TotalTCSDRTC=0,TotalTCWIOTC=0,TotalTCWIRTC=0,TotalHERAOTC=0,TotalHERARTC=0,TotalGRPALLOTC=0,TotalGRPALLRTC=0;
        Public Integer groupIndex;
        public List<cls_SP> SP;
        public List<cls_groupingItems> COItems;        
        
    }
    
    public class cls_ClusterAddons {
        public String ClusterBASNIA,ClusterSmallNIA,ClusterMediumNIA,ClusterLargeNIA,Cluster80NIA,ClusterUnlimNIA;  //-
        public cls_AddOnGroups[] AddOnGroups;//list of add on groups
        public cls_AddOnChilds[] AddOnChilds;//list of add onchilds
    }
    
 
    public class cls_AddOnGroups {
        public String EnglishName,SwedishName;  //group1
        public cls_AddOnChilds[] AddOnChilds;//List of add on childs
    }
    public class cls_AddOnChilds {
        public String EnglishName,SwedishName,BASRTC = '-',SMALLRTC = '-',MEDIUMRTC = '-',LARGERTC = '-',XLARGERTC = '-',PLUSRTC = '-',LGCYRTC = '-';     
    }
    
    public class cls_isMinuteBasedAddon {
        public Decimal otfPriceMB = 0, MinuteBasedReqPrice = 0;
        public String  SwedishNameMB = '', EnglishNameMB = '';
        public Boolean ShowMinuteBasedTable = false;
    }
}