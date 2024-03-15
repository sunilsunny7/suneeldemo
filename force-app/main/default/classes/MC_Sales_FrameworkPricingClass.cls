global without sharing class MC_Sales_FrameworkPricingClass implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        boolean result = true;
        try {
            if (methodName.equalsIgnoreCase('processPricePlanExtract')) {
                processPricePlanExtract(inputMap, outMap);
            }
            else if (methodName.equalsIgnoreCase('savePricesAndFlags')) {
                savePricesAndFlags(inputMap, outMap);
            }
            /*else if (methodName.equalsIgnoreCase('saveDefaultPricePlan')) {
            saveDefaultPricePlan(inputMap, outMap);
            }*/
            else if(methodName.equalsIgnoreCase('sparaCallFrameworkPrice')){
                sparaCallFrameworkPrice(inputMap,outMap);
            }
            else  if (methodName.equalsIgnoreCase('transformSummaryResponse')){
              transformSummaryResponse(inputMap,outMap);
          }
            else if(methodName.equalsIgnoreCase('resetPricePlans')){
                resetPricePlans(inputMap,outMap);
            }
            else {
                result = false;
            }
        } catch (Exception e) {
            result = false;
            outMap.put('ErrorAgreement', 'Error');
            outMap.put('ErrorMessage', e.getMessage());
        }
        return result;
    }
    
    /*Operation being done
1. Identification of products not added in the cluster (in groupItems node, we get product names/product code of product added in quote)
2. Removal of prices in the same indexes (product is not added at index 2 , remove prices from the pricepolans at index 2) 
3. cleanup of data
*/ 
    public static void processPricePlanExtract(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try
        {
            Id qliId = (Id) inputMap.get('qliId');
            Id quoteid=(Id) inputMap.get('quoteId');  
            String productCodesAvaiable;  
            List<String> prodCodesToCompare = new List<String> ();  
            List<String> productCodesToDisplay = new List<String> ();  
            List<Map<String,Object>> productCodesAvailableInFA = (List<Map<String,Object>>) inputMap.get('PricePlans');  
            List<Map<String,Object>> productCodesAvailableInFANew = new List<Map<String,Object>>();  
            String clusterCode =(String)inputMap.get('clusterSelected');  

            if(productCodesAvailableInFA.size()>0)
            {
                Map<String,Object> productCodesMap = productCodesAvailableInFA[0];
                productCodesAvaiable = (String)productCodesMap.get('ProductCodesAvailable');
                
                List<String> productCodeAll =  productCodesAvaiable.split(';');
                List<Map<String,Object>> productCodesCurrentlyInFA =  (List<Map<String,Object>>) inputMap.get('GroupItems');
                List<String> productsInFA = new List<String>();
                List<String> productsInFANames = new List<String>();
                List<String> productsInFAId = new List<String>();
                List<String> standardPricesInFA = new List<String>();
                List<String> standardPricesInFADisplay = new List<String>();
                
                Map<String,Object> commercialTermsQliMap = new Map<String,Object>(); //MCSTO-10907-Shouvik
                String approvedPriceId = '';
                
                if(productCodesCurrentlyInFA.size()>0)
                {
                    for(integer i = 0;i<productCodesCurrentlyInFA.size();i++)
                    {
                        Map<String,Object> productCodeInFAMap = (Map<String,Object>)productCodesCurrentlyInFA[i];
                        productsInFA.add((String)productCodeInFAMap.get('ProductCode'));
                        productsInFANames.add((String)productCodeInFAMap.get('ProductName'));
                        productsInFAId.add((String)productCodeInFAMap.get('Id'));
                        standardPricesInFA.add(string.valueof(productCodeInFAMap.get('StandardPrice')));
                        
                        if(productCodeInFAMap.containsKey('MC_CommercialTermsQli__c'))
                        {
                            commercialTermsQliMap = (Map<String,Object>)json.deserializeUntyped((String)productCodeInFAMap.get('MC_CommercialTermsQli__c'));
                            approvedPriceId = (String)commercialTermsQliMap.get('FrameworkPricingMaster');
                        }
                        //MCSTO-10907-Shouvik: if-else ladder added
                    }
                }
                else 
                {
                    outMap.put('error','No products added in cart');
                }
                //pooja
                //POC Code added here (Abhinav)  
                Map<String,Double> clusterToSelectedPricePlanSequence = new Map<String,Double>();  
                for(QuoteLineItem qli : [Select id,TeliaSE_ParentClusterCode__c,TeliaSE_Product_Code__c,MC_Sales_FrameworkPricingMaster__c,MC_Sales_FrameworkPricingMaster__r.MC_Sales_FrameworkPricePlanMaster__r.Sequence__c from QuoteLineItem where quoteid=:quoteid and MC_Sales_FrameworkPricingMaster__c != null and TeliaSE_Product_Code__c IN: productsInFA and TeliaSE_ParentClusterCode__c != null])  
                {  
                    clusterToSelectedPricePlanSequence.put(qli.TeliaSE_ParentClusterCode__c.toUpperCase(),(Double)qli.MC_Sales_FrameworkPricingMaster__r.MC_Sales_FrameworkPricePlanMaster__r.Sequence__c);  
                }  
                if(clusterToSelectedPricePlanSequence.keySet().size()>0){  
                    productCodesAvailableInFA  = filterPricePlans(productCodesAvailableInFA,clusterToSelectedPricePlanSequence,clusterCode);      
                }
                List<Integer> missingIndexes = missingIndexes(productCodeAll,productsInFA); 
                
                //removing the prices at these indexes if found.
                if(missingIndexes.size()>0)
                {
                    for(Integer i=0;i<productCodesAvailableInFA.size();i++)
                    {
                        Map<String,Object> pricePlan = (Map<String,Object>) productCodesAvailableInFA[i];
                        String prices = (String)pricePlan.get('Prices');
                        //remove in array of products
                        List<String> pricesArray = prices.split(',');
                        string updatedPrices;
                        List<String> pricesArrayUpdated = new List<String>();
                        for(integer j=0;j<pricesArray.size();j++)
                        {
                            if(!missingIndexes.contains(j))
                            {
                                pricesArrayUpdated.add(pricesArray[j]);
                            }
                        }
                        updatedPrices = string.join(pricesArrayUpdated,',');
                        pricePlan.put('Prices',updatedPrices);
                    }
                }
                // Logic for setting a node for selected price plan / default price plan
                Boolean selectedPricePlanFound = false;
                if(inputMap.containsKey('selectedPricePlan'))
                {
                    for(Integer i=0;i<productCodesAvailableInFA.size();i++)
                    {
                        Map<String,Object> pricePlan = (Map<String,Object>) productCodesAvailableInFA[i]; 
                        string pricePlanid = (String) pricePlan.get('PricePlanId');
                        if(pricePlanid == inputMap.get('selectedPricePlan'))
                        {
                            selectedPricePlanFound = true;
                            pricePlan.put('selectedPricePlan',true);                            
                        }
                        else
                        {
                            pricePlan.put('selectedPricePlan',false);
                        }
                    }                       
                }
                if(selectedPricePlanFound == false)
                {
                    for(Integer i=0;i<productCodesAvailableInFA.size();i++)
                    {
                        Map<String,Object> pricePlan = (Map<String,Object>) productCodesAvailableInFA[i]; 
                        pricePlan.put('selectedPricePlan',(boolean)pricePlan.get('isDefaultPricePlan'));
                    } 
                }
                
                //Color updation logic
                boolean footerShown = false;
                footerShown = colorProducts(productCodesAvailableInFA,footerShown);
                //logic for setting selectedPricePlan ends
                outmap.put('footerShown',footerShown);
                outmap.put('groupItemsStandardPrices',string.join(standardPricesInFA,','));
                outmap.put('pricePlans',productCodesAvailableInFA);
                outmap.put('groupItems',string.join(productsInFANames,','));
                outmap.put('groupItemsId',string.join(productsInFAId,','));
                outmap.put('approvedPriceId',approvedPriceId); //MCSTO-10907-Shouvik
                
            }
        }catch(Exception e)
        {
            system.debug('Framework Pricing: Error happened:'+e.getStackTraceString());
            system.debug('Framework Pricing: Error Message:'+e.getMessage());
            outmap.put('Error',e.getStackTraceString());
            outmap.put('Error',e.getMessage());
            outmap.put('Errortype',e);
            
        } 
    }
    
    //Code to find missing product
    public static list<Integer> missingIndexes(List<String> productCodeAll,List<String> productsInFA)
    {
        List<Integer> missingindexes = new List<Integer>();
        for(integer i=0;i<productCodeAll.size();i++){
            if(!productsInFA.contains((String)productCodeAll[i])){
                missingIndexes.add(i);
            }
        }
        return missingindexes;
    }
    
    public static void savePricesAndFlags(Map<String, Object> inputMap, Map<String, Object> outMap) {
        Boolean testContext=Test.isRunningTest();
        Id pricePlanIdSelected = (Id) inputMap.get('pricePlanIdSelected');       
        String faceFlag,approver = (String) inputMap.get('approver');
        string pricesString = (String)inputMap.get('prices');
        List<String> prices = new List<String> ();
        prices = pricesString.split(','); 
        string productsinFAString = (String)inputMap.get('productsInFA');
        string qliNegotiability = (String)inputMap.get('qliNegotiability');
        List<String> productsinFA =  productsinFAString.split(',');
        User loggedInUser = [select id, MassCustomized_Roles__c from user where id =: UserInfo.getUserId()];
        if (((loggedInUser.MassCustomized_Roles__c == 'SalesRep' || loggedInUser.MassCustomized_Roles__c == '') && approver != 'AM') ||
            (loggedInUser.MassCustomized_Roles__c == 'SalesManager' && approver != 'AM' && approver != 'SM') ||
            (loggedInUser.MassCustomized_Roles__c == 'SalesDirector' && approver != 'AM' && approver != 'SM' && approver != 'SD')) {
                faceFlag = System.Label.TeliaSE_SadFace;
            } else {
                faceFlag = System.Label.TeliaSE_HappyFace;
            }
        if (approver == 'SM') {
            approver = 'Säljchef';
        }
        else if (approver == 'SD') {
            approver = 'Säljdirektör';
        }
        else if (approver == 'CM') {
            approver = 'Commercial Management';
        }
        else{
            approver = 'Säljare';
        }
        List<String> productCodesListInCart = new List<String> ();
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        for (Integer i = 0; i<productsinFA.size(); i++) 
        {
            Integer priceToUpdate = Integer.valueOf(prices[i]);
            QuotelineItem qli = new QuoteLineItem();
            qli.id=(Id)productsinFA[i];
            qli.TeliaSE_MC_Customer_Requested_Price__c = priceToUpdate;
            qli.MC_Sales_FrameworkPricingMaster__c = pricePlanIdSelected;            
            //qli.TeliaSE_Ceiling_Price__c = priceToUpdate;            
            if(qliNegotiability != 'Hybrid'){
                qli.vlocity_cmt__RecurringCharge__c = priceToUpdate;
                qli.vlocity_cmt__EffectiveRecurringTotal__c = priceToUpdate;
                qli.MC_Approver__c = approver;
                qli.TeliaSE_AM_Mandate_Percentage__c = 0;
                qli.TeliaSE_SD_Mandate_Percentage__c = 0;
                qli.TeliaSE_CM_Mandate_Percentage__c = 0;
                qli.TeliaSE_SM_Mandate_Percentage__c = 0;
                
            }
            if(((String)(inputMap.get('approvedPriceId'))!= '') && (((String)(pricePlanIdSelected)) == ((String) inputMap.get('approvedPriceId')))) {
                qli.TeliaSE_Flag__c = System.Label.TeliaSE_HappyFace;               
            }
            else{
                qli.TeliaSE_Flag__c = faceFlag;
            } //MCSTO-10907-Shouvik: if-else ladder added
            qliList.add(qli);
        }
        
        //Update Line Status of root item when doing renegotiation for framework pricing products. 
        if(inputMap.containsKey('rootId') && inputMap.containsKey('rootLineStatus') && inputMap.containsKey('salesFlowIdentifier')){
            if((String)inputMap.get('salesFlowIdentifier') != 'New Sales'){
                if((string)inputMap.get('rootLineStatus') == 'Existing' ){
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.id = String.valueOf(inputMap.get('rootId'));
                    qli.MC_Line_Status__c = 'Updated';
                    qliList.add(qli);
                }
            }
        }
        
        if(!testContext){
            update qliList;
        }
        
    }
    
    public static void sparaCallFrameworkPrice(Map<String, Object> inputMap, Map<String, Object> outMap){
        String quoteid=(String) inputMap.get('quoteId');
        string baseQuan='',cmtPeriod='',rootItemId='',quantity='';
        //FrameWork pricing For Spara
        List< Object> attrJSON= (List< Object>)inputMap.get('attr');
        for (Object attr:attrJSON){
            Map<String, Object> attrVal = (Map<String, Object>)attr;
            if(attrVal.get('code')== 'ATT_RT_NoU'){
                quantity = String.valueOf(attrVal.get('userValues'));                    
            } else if (attrVal.get('code')=='ATT_RT_CMTP'){
                cmtPeriod = (String)attrVal.get('userValues');
            }
        }
        rootItemId= String.ValueOf(inputMap.get('rootItemId'));
        Boolean baseQtyChanged=false,nullPricePlan = false, baseQtyOrCmtChanged= false;
        String productNegotiability;
        list<quotelineitem> qliList = [SELECT id,product2.name,product2.productcode,TeliaSE_Base_Quantity__c,vlocity_cmt__RootItemId__c,
                                       TeliaSE_Ceiling_Price__c,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_Flag__c,TeliaSE_CommitmentPeriod__c,
                                       MC_Sales_FrameworkPricingMaster__c,TeliaSE_ParentClusterCode__c,Quote.MC_Commercial_Setup__c,vlocity_cmt__AssetReferenceId__c,
                                       Product2.TeliaSE_Product_Category__c,TeliaSE_Product_Object_Type__c,vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c
                                       FROM quotelineitem 
                                       WHERE quoteid=: quoteId AND ((vlocity_cmt__AssetReferenceId__c=:rootItemId )
                                                                    OR((vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c = 'Framework' OR vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c = 'Hybrid') AND vlocity_cmt__RootItemId__c=:rootItemId ))];
         
        Set<Quotelineitem> qliListDefaultPP = new Set<QuoteLineItem>();
        Set<Quotelineitem> qliListPPCheck = new Set<QuoteLineItem>();
        QuotelineItem rootQli = new QuoteLineItem();
        for(QuoteLineItem qli : qliList){ 
            productNegotiability = qli.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c;
            if(qli.vlocity_cmt__AssetReferenceId__c == qli.vlocity_cmt__RootItemId__c){
                rootQli=qli;
                if(qli.TeliaSE_Base_Quantity__c != String.valueOf(quantity)){
                    baseQtyChanged = true; //for framework products, only base qty change needs to be considered
                }
                if(qli.TeliaSE_Base_Quantity__c != String.valueOf(quantity)|| qli.TeliaSE_CommitmentPeriod__c != String.valueOf(cmtPeriod)){
                    baseQtyOrCmtChanged = true; //for hybrid products, either of the 2 attributes change needs to be considered
                }
            }
            /*if(qli.Id == qli.vlocity_cmt__RootItemId__c && (qli.TeliaSE_Base_Quantity__c != String.valueOf(quantity)|| qli.TeliaSE_CommitmentPeriod__c != String.valueOf(cmtPeriod))){
                allAttributesChanged = true;
                //rootQli=qli;
                if(qli.Id == qli.vlocity_cmt__RootItemId__c && (qli.TeliaSE_Base_Quantity__c != String.valueOf(quantity))){
                    baseQtyChanged = true;
                 }
            }*/
            if((baseQtyOrCmtChanged || baseQtyChanged) && (productNegotiability =='Hybrid' || productNegotiability == 'Framework')){
                    break;
            }
            else if(qli.vlocity_cmt__AssetReferenceId__c != qli.vlocity_cmt__RootItemId__c && qli.MC_Sales_FrameworkPricingMaster__c == null && qli.TeliaSE_ParentClusterCode__c == null && productNegotiability=='Framework'){ // && (!attributesChanged && !allAttributesChanged)
                nullPricePlan = true;
                qliListDefaultPP.add(qli);
            }
            /*else if (qli.Id == qli.vlocity_cmt__RootItemId__c && productNegotiability =='Framework' && (!baseQtyChanged && !baseQtyOrCmtChanged)){
               // rootQli=qli;
            }*/
        }
        List<Quotelineitem> qliListUpdated = new List<QuoteLineItem>();  
        List<Quotelineitem> qliListClustered = new List<QuoteLineItem>(); 

    //Making the list of Hybrid enabled quotelineitems for validating their Requested Price on click of Spara if either of the 2 attrs are updated
        if(baseQtyOrCmtChanged && productNegotiability == 'Hybrid'){
            for(quotelineitem qli: qliList){
                if(qli.Id != qli.vlocity_cmt__RootItemId__c && qli.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c == 'Hybrid' && qli.TeliaSE_MC_Customer_Requested_Price__c <>NULL){
                    qliListPPCheck.add(qli);
                }
            }
        } 
        
        if(baseQtyChanged && productNegotiability == 'Framework')
        {
            for(quotelineitem qli: qliList)
            {   
                if(qli.vlocity_cmt__AssetReferenceId__c != qli.vlocity_cmt__RootItemId__c && qli.TeliaSE_ParentClusterCode__c != null && rootQli.TeliaSE_Base_Quantity__c != null){ 
                    //Assign a default list price for clustered addons only if base qty attribute has been CHANGED, not if we do spara first time (base qty =null)
                    Quotelineitem qliNew = new QuoteLineItem();
                    qliNew.id = qli.id;
                    qliNew = resetPrice(qli);
                    qliListUpdated.add(qli);
                } else if(qli.vlocity_cmt__AssetReferenceId__c != qli.vlocity_cmt__RootItemId__c  && qli.TeliaSE_ParentClusterCode__c == null){ 
                    //Assign default price plans for non-clustered addons if base qty attribute has been CHANGED/null
                    //add to this list to assign default price plan
                    qliListDefaultPP.add(qli);
                }
            }
        }
        if(nullPricePlan || qliListDefaultPP.size()>0 ){
            //call assignDefaultPricePlan method to assign default price plan to non-clustered addons
            qliListUpdated.addAll(assignDefaultPricePlan(qliListDefaultPP,rootQli,cmtPeriod,quantity));
        }
        if(qliListPPCheck.size()>0 && baseQtyOrCmtChanged && productNegotiability == 'Hybrid'){
            qliListUpdated.addAll(validateRequestedPrice(qliListPPCheck,rootQli,cmtPeriod,Integer.valueOf(quantity)));
        }
        if(qliListUpdated.size()>0)
        {
            update qliListUpdated;
        }
    }
    
    
 /*************************************************************************************************************
  * Developer: Sanjoli Agrawal
  * EPIC/Product: Spara functionality for Hybrid
  * ___________________________________________________________________________________________________________
  * ***********************************************************************************************************
  * This method is used to validate the requested price with new prices on attribute change for Hybrid products.
  * Returns list of Qli for update.
  * Method is invoked from MC_CartRepricing
  *___________________________________________________________________________________________________________
  * @param inputMap                                Id - for QuoteId
  * @param outMap
  * ___________________________________________________________________________________________________________
  * ***********************************************************************************************************
  */
    @testVisible
    private static Set<QuotelineITem> validateRequestedPrice(Set<Quotelineitem> qliList,QuoteLineItem rootQLI, String cmtPeriod, Integer quantity){
        String segment, productType = (String)rootQLI.TeliaSE_Product_Object_Type__c,salesParent= (String)rootQLI.Product2.ProductCode;
        if(rootQLI.Quote.MC_Commercial_Setup__c != null){
            segment = (String)rootQLI.Quote.MC_Commercial_Setup__c == 'Enterprise SME' || (String)rootQLI.Quote.MC_Commercial_Setup__c == 'Forced BA'? 'SME' : 'LARGE';
        }
        
        List<MC_Sales_FrameworkPricingMaster__c> pricingMasterList =  [SELECT Id,MC_Sales_FrameworkProductCategoryMaster__r.MC_Sales_Product_Codes__c,
                                                                       MC_Sales_FrameworkPricePlanMaster__r.Name,MC_Sales_FrameworkProductCategoryMaster__r.name,
                                                                       MC_Sales_FrameworkPricePlanMaster__r.MC_PricePlanType__c
                                                                       FROM MC_Sales_FrameworkPricingMaster__c 
                                                                       WHERE MC_Sales_FrameworkPricePlanMaster__r.MC_Sales_EndDate__c= NULL 
                                                                       AND MC_Sales_FrameworkPricePlanMaster__r.MC_Sales_StartDate__c <=: System.today()
                                                                       AND MC_Sales_High_Base_Quantity__c >=:quantity AND MC_Sales_Low_Base_Quantity__c <=:quantity
                                                                       AND MC_Sales_Object_Type__c =: productType AND MC_Sales_Parent__c =: salesParent
                                                                       AND (MC_Sales_Customer_segment__c='ALL' OR MC_Sales_Customer_segment__c =:segment) 
                                                                       AND (MC_Sales_Commitment_Period__c='ALL' OR MC_Sales_Commitment_Period__c =:cmtPeriod)
                                                                       AND MC_Sales_PricePlan_EndDate__c = null ];
        
        if(pricingMasterList.size()>0){
            Map<String,List<MC_Sales_FrameworkPricingMaster__c>> productToPricePlans = new Map<String,List<MC_Sales_FrameworkPricingMaster__c>>();
            for(MC_Sales_FrameworkPricingMaster__c pp :pricingMasterList ){
                List<MC_Sales_FrameworkPricingMaster__c> pricePlan = new List<MC_Sales_FrameworkPricingMaster__c>();
                if(productToPricePlans.get(pp.MC_Sales_FrameworkProductCategoryMaster__r.name) != NULL){
                    productToPricePlans.get(pp.MC_Sales_FrameworkProductCategoryMaster__r.name).add(pp);
                }
                else{
                    pricePlan.add(pp);
                    productToPricePlans.put(pp.MC_Sales_FrameworkProductCategoryMaster__r.name,pricePlan);
                }
            }
           
            for(QuotelineItem qli:qliList){
                if(productToPricePlans.containsKey(qli.Product2.TeliaSE_Product_Category__c) && productToPricePlans.get(qli.Product2.TeliaSE_Product_Category__c).size()>0){
                    for(MC_Sales_FrameworkPricingMaster__c pp:productToPricePlans.get(qli.Product2.TeliaSE_Product_Category__c)) {
                        
                        if(Integer.valueOf(pp.MC_Sales_FrameworkPricePlanMaster__r.Name) ==qli.TeliaSE_MC_Customer_Requested_Price__c){
                            qli.MC_Sales_FrameworkPricingMaster__c =pp.Id;
                            
                            break;
                        }
                        else if(pp.MC_Sales_FrameworkPricePlanMaster__r.MC_PricePlanType__c != NULL && pp.MC_Sales_FrameworkPricePlanMaster__r.MC_PricePlanType__c == 'Continuous'){
                            Integer index = pp.MC_Sales_FrameworkPricePlanMaster__r.Name.indexOf('-');
                            Integer lowvalue =  Integer.valueOf(pp.MC_Sales_FrameworkPricePlanMaster__r.Name.substring(index+1));
                            Integer highvalue = Integer.valueOf(pp.MC_Sales_FrameworkPricePlanMaster__r.Name.substring(0,index));
                            if((qli.TeliaSE_MC_Customer_Requested_Price__c >= lowvalue || qli.TeliaSE_MC_Customer_Requested_Price__c <= highvalue)){
                                qli.MC_Sales_FrameworkPricingMaster__c = pp.Id;
                                break;
                            }
                        }
                        else{
                            qli.MC_Sales_FrameworkPricingMaster__c = NULL;
                        }
                    }
                }
            }
        }
        
        return qliList;
    }
     

    //method to assign a default price plan to the Mobile addons based on parameters like segemnt, number of users, commitment period etc. Returns list of QLI
    public static Set<Quotelineitem> assignDefaultPricePlan(Set<Quotelineitem> qliList,QuoteLineItem rootQLI,String cmtPeriod, String quantity)
    {
         if(qliList.size()>0){
            String mobVersion=(String)rootQLI.Product2.ProductCode;
            String segment;
            if(String.valueOf(rootQLI.Quote.MC_Commercial_Setup__c) != null){
                segment = (String)rootQLI.Quote.MC_Commercial_Setup__c == 'Enterprise SME' || (String)rootQLI.Quote.MC_Commercial_Setup__c == 'Forced BA'? 'SME' : 'LARGE';
            }
             
            Decimal queryQuantity = rootQLI.TeliaSE_Base_Quantity__c != null? Decimal.valueOf(rootQLI.TeliaSE_Base_Quantity__c) : Decimal.valueOf(quantity);
            String queryCMTPeriod = rootQLI.TeliaSE_CommitmentPeriod__c != null? String.valueOf(rootQLI.TeliaSE_CommitmentPeriod__c) : String.valueOf(cmtPeriod);
                 List<MC_Sales_FrameworkPricingMaster__c> pricingMasterList= [SELECT Id,MC_Sales_Cluster__c,MC_Sales_FrameworkProductCategoryMaster__r.MC_Sales_Product_Codes__c,
                                                                          MC_Sales_FrameworkPricePlanMaster__r.Name,MC_Sales_FrameworkProductCategoryMaster__r.name
                                                                         FROM MC_Sales_FrameworkPricingMaster__c 
                                                                         WHERE MC_Sales_Default_Price_Plan__c = true AND MC_Sales_Parent__c=:mobVersion 
                                                                         AND MC_Sales_High_Base_Quantity__c >=:queryQuantity AND MC_Sales_Low_Base_Quantity__c <=:queryQuantity
                                                                         AND (MC_Sales_Customer_segment__c='ALL' OR MC_Sales_Customer_segment__c =:segment) 
                                                                         AND (MC_Sales_Commitment_Period__c='ALL' OR MC_Sales_Commitment_Period__c =:queryCMTPeriod)
                                                                         AND MC_Sales_PricePlan_EndDate__c = null];
            if(pricingMasterList.size()>0){
                Map<String, MC_Sales_FrameworkPricingMaster__c> prices= new  Map<String, MC_Sales_FrameworkPricingMaster__c>();
                for (MC_Sales_FrameworkPricingMaster__c pm : pricingMasterList){
                    String clusterCategory= pm.MC_Sales_Cluster__c != 'ALL' ? pm.MC_Sales_FrameworkProductCategoryMaster__r.Name + pm.MC_Sales_Cluster__c : pm.MC_Sales_FrameworkProductCategoryMaster__r.Name ;
                    prices.put(clusterCategory,pm );
                }
                for(QuoteLineItem q:qliList){
                    String qlClusterCategory= q.TeliaSE_ParentClusterCode__c != NULL ? q.Product2.TeliaSE_Product_Category__c +q.TeliaSE_ParentClusterCode__c.toUpperCase() : q.Product2.TeliaSE_Product_Category__c ;
                    Integer count=0,index= -1;
                    if(prices.containsKey(qlClusterCategory)){
                        MC_Sales_FrameworkPricingMaster__c pricePlan = prices.get(qlClusterCategory);
                        Id pricePlanId = pricePlan.Id;
                        List<String> prices1 =(pricePlan.MC_Sales_FrameworkPricePlanMaster__r.Name).split(',');
                        List<String> codes = (pricePlan.MC_Sales_FrameworkProductCategoryMaster__r.MC_Sales_Product_Codes__c).split(';');
                        for (String i: codes){
                            if(q.Product2.ProductCode==i ){
                                index = count;
                                break;
                            }
                            count ++;
                        }       
                        Integer p;
                        if(index>=0){
                            p= Integer.valueOf(prices1[index]);
                            q.TeliaSE_MC_Customer_Requested_Price__c = p;
                            q.MC_Sales_FrameworkPricingMaster__c = pricePlanId;
                            q.vlocity_cmt__RecurringCharge__c = p;
                            //q.TeliaSE_Ceiling_Price__c = p;
                            q.MC_Approver__c = 'AccountManager';
                            q.vlocity_cmt__EffectiveRecurringTotal__c = p;
                            q.TeliaSE_AM_Mandate_Percentage__c = 0;
                            q.TeliaSE_SD_Mandate_Percentage__c = 0;
                            q.TeliaSE_CM_Mandate_Percentage__c = 0;
                            q.TeliaSE_SM_Mandate_Percentage__c = 0;
                            q.TeliaSE_Flag__c = System.Label.TeliaSE_HappyFace;
                        }
                    }                    
                }
                /*update qliList;
        outMap.put('Success', 'true');*/
            }
         }
        return qliList;
    }
    
    
     /*
    * Developer: Abhinav Gupta
    * EPIC/Product: NMP3 (Special AddOns): LTAART-176
    * ___________________________________________________________________________________________________________
  * ***********************************************************************************************************
  * This method is used to put price on clustered framework addOn Products based on selection in other clusters.
  * Returns list of Qli for update.
  * Method is invoked from MC_CartRepricing
  *___________________________________________________________________________________________________________
  * @param inputMap                                Id - for QuoteId
  * @param outMap
  * ___________________________________________________________________________________________________________
  * ***********************************************************************************************************
  */
    public static List<QuoteLineitem> valideraCallFrameworkPrice(Map<String,Object> inputMap, Map<String,Object> outMap){
        String quoteId = (String)inputMap.get('Id');
        List<quotelineitem> qItemList=new List<quotelineitem>();
        Map<String,Map<String,String >> clusterPopulatedMap = new Map<String,Map<String,String>>();
        List<quoteLineItem> qliUpdated = new list<quotelineItem>();
        QuoteLineItem qliParent = new QuoteLineItem();
        Map<String,QuoteLineitem> qliParentMap = new Map<String,Quotelineitem>();
        Map<String,List<Quotelineitem>> qliListParentMap = new Map<String,List<Quotelineitem>>();
        // QLILIST FETCHED FROM THE QUOTE
        // Either Clustered Framework Special AddOns OR Root Offerings 
        qItemList=[Select id,quote.TeliaSE_MC_Sales_Flow_Identifier__c,vlocity_cmt__RootItemId__c,MC_Line_Status__c,TeliaSE_ParentClusterCode__c,vlocity_cmt__ParentItemId__c,MC_Sales_FrameworkPricingMaster__c,MC_Sales_FrameworkPricingMaster__r.MC_Sales_FrameworkPricePlanMaster__c,Product2.TeliaSE_Product_Category__c,TeliaSE_Base_Quantity__c,quote.account.MC_Commercial_Setup__c,TeliaSE_Product_Code__c,TeliaSE_CommitmentPeriod__c 
                   from quotelineitem where quoteid =:quoteId and
                   ((TeliaSE_ParentClusterCode__c!= null and (vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c = 'Framework' OR vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c ='Hybrid')) OR 
                    (vlocity_cmt__ParentItemId__c=null))];
         //Iterate over the qlilist to sort the list into 3 categories
         //1. Root offerings - All are put into the qliParentMap 
        //2. Clustered addOns where framework price is available - they are put into a clusterPopulatedMap ({productCategory: {[selectedCluster: PricePlanMasterId]}})  
        //3. Clustered addOns where framework price is not available - All are put into qliListClustered , added to a qliListParentMap as well {QLiRootId,List of qli}        
        for(QuoteLineItem qli:qItemList)
        {
            if(qli.vlocity_cmt__ParentItemId__c==null){
                qliParentMap.put(qli.vlocity_cmt__RootItemId__c,qli);
            }
            else if(qli.TeliaSE_ParentClusterCode__c !=null && qli.MC_Sales_FrameworkPricingMaster__c!=null){
                Map<String,String> newMap = new map<String,String>();
                if(clusterPopulatedMap.containsKey(qli.Product2.TeliaSE_Product_Category__c)){
                    newMap = clusterPopulatedMap.get(qli.Product2.TeliaSE_Product_Category__c);
                }                   
                newMap.put(qli.TeliaSE_ParentClusterCode__c,qli.MC_Sales_FrameworkPricingMaster__r.MC_Sales_FrameworkPricePlanMaster__c);
                clusterPopulatedMap.put(qli.Product2.TeliaSE_Product_Category__c,newMap);
            }
            else if(qli.TeliaSE_ParentClusterCode__c !=null && qli.MC_Sales_FrameworkPricingMaster__c==null && (qli.quote.TeliaSE_MC_Sales_Flow_Identifier__c != 'Inforhandling' || (qli.quote.TeliaSE_MC_Sales_Flow_Identifier__c == 'Inforhandling' && qli.MC_Line_Status__c !='Existing'))){ //In Inforhandling, only add added offerings.
                List<Quotelineitem> qliListClustered = new List<QuoteLineitem>(); 
                if(qliListParentMap.containsKey(qli.vlocity_cmt__RootItemId__c)){
                    qliListClustered = qliListParentMap.get(qli.vlocity_cmt__RootItemId__c);
                }
                qliListClustered.add(qli);                
                qliListParentMap.put(qli.vlocity_cmt__RootItemId__c,qliListClustered);
            }
        }
    
        if(qliListParentMap.keySet().size()>0){
            for(String key : qliListParentMap.keySet()){
                // Maximum expected times of execution is 2.
                List<quoteLineItem> qliListClustered = new list<quotelineItem>();
                if(qliParentMap.containsKey(key)){
                    qliParent = qliParentMap.get(key);
                }
                qliListClustered = qliListParentMap.get(key);
                if((qliParent.quote.TeliaSE_MC_Sales_Flow_Identifier__c != 'New Sales' && qliParent.MC_Line_Status__c != 'Existing') || qliParent.quote.TeliaSE_MC_Sales_Flow_Identifier__c == 'New Sales'){
                    //If New Sales Quote, invoke the method
                    //If Renegotiation , invoke the method if the parent is updated.
                    qliUpdated.addAll(clusteredDefaultPricePlans(qliListClustered,clusterPopulatedMap,qliParent));
                }
            }    
        }

        if(qliUpdated.size()>0){
            return qliUpdated;
        }
        else{
            return null;
        }
    }
    
    
    /*
    * Developer: Abhinav Gupta
    * EPIC/Product: NMP3 (Special AddOns) : LTAART-176
    * ___________________________________________________________________________________________________________
  * ***********************************************************************************************************
  * Method will be called iteratively for each rootItem
  * Method will get a list of QLIList on which the framework price needs to be updates 
  * We get the clusterMap which hold the details of all addOns which are already priced. 
  * ClusterMap structure: ({productCategory: {SelectedCluster:PriceplanId}})
  * Method return the list of qliItems which needs to be updated.
  *___________________________________________________________________________________________________________
  * @param qliItems                                list of qliItems- where framework price is not selected
  * @param clusteredMap                  ClusterMap structure: ({productCategory: {SelectedCluster:PriceplanId}})  
  * @param qliParent                  root parent for the addOns  
  * @output qliList
  * ___________________________________________________________________________________________________________
  * ***********************************************************************************************************
  */
    public static List<Quotelineitem> clusteredDefaultPricePlans(List<quotelineitem> qliItems,Map<String,Map<String,String>> clusteredMap,QuoteLineItem qliparent){
        //Cluster ranking
        Map<String,Integer> ClusterMapping = new Map<String,Integer>{'bas'=>1,'small'=>2,'medium'=>3,'large'=>4,'xlarge'=>5,'plus'=>6};
        String segment ='ALL';
        if(qliparent.quote.account.MC_Commercial_Setup__c == 'Enterprise SME' || qliparent.quote.account.MC_Commercial_Setup__c == 'Forced BA'){
            segment = 'SME';
        }
        else{
            segment = 'LARGE';
        }
        //Building a dynamic query to fetch frameworkMaster records for each qli.
        String query = 'SELECT Id,MC_Sales_Cluster__c, MC_Sales_FrameworkPricePlanMaster__r.name,MC_Sales_Approver_Level__c,MC_Sales_FrameworkProductCategoryMaster__r.Name from MC_Sales_FrameworkPricingMaster__c where ' ;
        //Conditions added for parent,segment,volume.
        String conditions = 'MC_Sales_Parent__c = \'' + String.escapeSingleQuotes(qliparent.TeliaSE_Product_Code__c)+'\'' + ' and ( MC_Sales_Customer_Segment__c = \'' + String.escapeSingleQuotes(segment)+ '\'' + ' or MC_Sales_Customer_Segment__c = \'ALL\') ' + ' and MC_Sales_High_Base_Quantity__c >=' + integer.valueOf(qliparent.TeliaSE_Base_Quantity__c) + ' and MC_Sales_Low_Base_Quantity__c  <=' + integer.valueOf(qliparent.TeliaSE_Base_Quantity__c);
        query += conditions;
        String clusterCondtions = '';
        //We iterate over each qliItem where pricePlan is not selected.
        /* Requirement and Scenarios mentioned in :LTAART-176: MCSTO-9081-AC12 */
        /* LOGIC: 
         * Iterate over each line item, 
         * Check if addOn is priced in any other cluster 
         *   if yes, iterate over selected clusters
         *       if the cluster rank is greater than the selected cluster, populate the difference and the priceplanid. (continue till we get the least difference)
         *       if the cluster rank is less than the selected cluster, we should populate the default pricePlan
         *   if no , populate the default pricePlan.
         * Add condition string to the existing query to fetch precise results.
         */
        for(quotelineitem qli:qliItems){ // where priceplan is not selected
            Integer difference = 0;
            String pricePlanId = '';            
            if(clusteredMap.containsKey(qli.Product2.TeliaSE_Product_Category__c)){
                Map<String,String> mapClusterSelected = clusteredMap.get(qli.Product2.TeliaSE_Product_Category__c);
                String str = qli.TeliaSE_ParentClusterCode__c;
                Integer clusterCode = (Integer)ClusterMapping.get(str);
                for(String key:mapClusterSelected.keySet()){                            
                    if(ClusterMapping.get(key) < clusterCode && (difference==0 || (difference!=0 && ((clusterCode-ClusterMapping.get(key)) < difference)))){
                        difference = clusterCode-ClusterMapping.get(key);
                        pricePlanId = (String)mapClusterSelected.get(key);
                    } 
                }
            }
            if(String.isBlank(pricePlanId)){
                if(String.isBlank(clusterCondtions)){
                    clusterCondtions = 'and (' + '(MC_Sales_Cluster__c = \'' + String.escapeSingleQuotes(qli.TeliaSE_ParentClusterCode__c.toUpperCase()) +'\'' + ' and MC_Sales_Default_Price_Plan__c = TRUE  and MC_Sales_FrameworkProductCategoryMaster__r.Name = \'' + string.escapeSingleQuotes(qli.Product2.TeliaSE_Product_Category__c) + '\'' + ')'; 
                }
                else{
           clusterCondtions += 'OR' + '(MC_Sales_Cluster__c = \'' + String.escapeSingleQuotes(qli.TeliaSE_ParentClusterCode__c.toUpperCase()) +'\'' + 'and MC_Sales_Default_Price_Plan__c = TRUE  and MC_Sales_FrameworkProductCategoryMaster__r.Name = \'' + string.escapeSingleQuotes(qli.Product2.TeliaSE_Product_Category__c) + '\'' + ')';                   
                }                
            }
            else if(String.isNotBlank(pricePlanId)){
                if(String.isBlank(clusterCondtions)){
                    clusterCondtions = 'and (' + '(MC_Sales_Cluster__c = \'' + String.escapeSingleQuotes(qli.TeliaSE_ParentClusterCode__c.toUpperCase()) + '\'' + '  and MC_Sales_FrameworkProductCategoryMaster__r.Name = \'' + string.escapeSingleQuotes(qli.Product2.TeliaSE_Product_Category__c) + '\'' + ' and MC_Sales_FrameworkPricePlanMaster__c = \'' + string.escapeSingleQuotes(pricePlanId) + '\'' + ')';
                }
                else{
                   clusterCondtions += 'OR' + '(MC_Sales_Cluster__c = \'' + String.escapeSingleQuotes(qli.TeliaSE_ParentClusterCode__c.toUpperCase()) + '\'' + ' and MC_Sales_FrameworkProductCategoryMaster__r.Name = \'' + string.escapeSingleQuotes(qli.Product2.TeliaSE_Product_Category__c) + '\'' + ' and MC_Sales_FrameworkPricePlanMaster__c = \'' + string.escapeSingleQuotes(pricePlanId) + '\'' + ')'; 
                }
            }
        }
        if(string.isNotEmpty(clusterCondtions)){
            clusterCondtions += ')';
        }
   
    query += clusterCondtions;
    //Execute the dynamic query to find framework masters for each qli 
        List<MC_Sales_FrameworkPricingMaster__c> data=  Database.query(query);
        Map<String,MC_Sales_FrameworkPricingMaster__c> frameworkExtract = new Map<String,MC_Sales_FrameworkPricingMaster__c>();  
        //Populate unique key for each framework master.
        for(MC_Sales_FrameworkPricingMaster__c master: data){
            frameworkExtract.put(master.MC_Sales_FrameworkProductCategoryMaster__r.Name + '_' + master.MC_Sales_Cluster__c.toLowerCase() , master);
        }
        List<QuotelineItem> qliupdated = new List<QuotelineItem>();
        //populate each qli item with framework master and price.
        for(quotelineitem qli:qliItems){
            QuoteLineitem qli2 = new QuoteLineItem();
            qli2.id = qli.id;
            if(frameworkExtract.containsKey(qli.Product2.TeliaSE_Product_Category__c + '_' + qli.TeliaSE_ParentClusterCode__c)){
                MC_Sales_FrameworkPricingMaster__c master = frameworkExtract.get(qli.Product2.TeliaSE_Product_Category__c + '_' + qli.TeliaSE_ParentClusterCode__c);
                qli2.MC_Sales_FrameworkPricingMaster__c = master.id;
                qli2.TeliaSE_MC_Customer_Requested_Price__c = decimal.valueOf(master.MC_Sales_FrameworkPricePlanMaster__r.name);
                qli2.vlocity_cmt__RecurringCharge__c = decimal.valueOf(master.MC_Sales_FrameworkPricePlanMaster__r.name);
                //If inforhandling, no need of flag update.
                if(qli.quote.TeliaSE_MC_Sales_Flow_Identifier__c != 'Inforhandling'){ 
                    if(integer.valueOf(master.MC_Sales_Approver_Level__c) != 1){
                        qli2.TeliaSE_Flag__c = system.label.TeliaSE_SadFace;
                    }
                    else{
                        qli2.TeliaSE_Flag__c = system.label.TeliaSE_HappyFace;
                    }               
                    if(integer.valueOf(master.MC_Sales_Approver_Level__c) == 2){
                        qli2.MC_Approver__c = 'Säljchef';
                    }             
                    else if (integer.valueOf(master.MC_Sales_Approver_Level__c) == 3) {
                        qli2.MC_Approver__c = 'Säljdirektör';
                    }
                    else if (integer.valueOf(master.MC_Sales_Approver_Level__c) == 4) {
                        qli2.MC_Approver__c = 'Commercial Management';
                    }
                    else{
                        qli2.MC_Approver__c = 'Säljare';
                    }
                }
                else{
                     qli2.TeliaSE_Flag__c = system.label.TeliaSE_HappyFace;
                     qli2.MC_Approver__c = 'Säljare';
                }
                
                
                qli2.TeliaSE_AM_Mandate_Percentage__c = 0;
                qli2.TeliaSE_SD_Mandate_Percentage__c = 0;
                qli2.TeliaSE_CM_Mandate_Percentage__c = 0;
                qli2.TeliaSE_SM_Mandate_Percentage__c = 0;
                qliupdated.add(qli2);
            }
        }
        if(qliupdated.size()>0)
        {
            return qliupdated; 
        }
        return null;
    }
    
    public static boolean colorProducts (List<Map<String,Object>> productCodesAvailableInFA,boolean footerShow)
    {
        for(integer i = 0;i < productCodesAvailableInFA.size();i++)
        {
            Map<String,Object> pricePlan = (Map<String,Object>) productCodesAvailableInFA[i];            
            String prices = (String)pricePlan.get('Prices');
            List<Map<String,Object>> priceMap = new List<Map<String,Object>>();
            String priceMapMerged;
            List<String> priceList = prices.split(',');
            String controlServices = (String)pricePlan.get('AgreementControlServices');
            if(String.isBlank(controlServices))
            {
                for(integer j = 0 ;j<priceList.size();j++)
                {
                    Map<String,Object> priceNew = new Map<String,Object>();
                    priceNew.put('Price',priceList[j]);
                    priceNew.put('color',false);
                    priceMap.add(priceNew);
                }
            }
            else
            {
                List<String> controlServicesList = controlServices.split(';');
                for(integer j = 0 ;j<priceList.size();j++)
                {
                    Map<String,Object> priceNew = new Map<String,Object>();
                    priceNew.put('Price',priceList[j]);
                    if(controlServicesList[j] != null && controlServicesList[j] == 'mandatory')
                    {
                        footerShow = true;
                        priceNew.put('color',true);
                    }
                    else
                    {
                        priceNew.put('color',false);
                    }
                    priceMap.add(priceNew);
                }
                
            }
            pricePlan.put('PricesModified',priceMap);
        }
        return footerShow;
    }  
    
    /*
    * Developer: Abhinav Gupta
    * EPIC/Product: NMP3 (Special AddOns)
    * ___________________________________________________________________________________________________________
  * ***********************************************************************************************************
  * This methid is used to filter out pricePlans for other cluster based on user selection in the remaining clusters
  * Based on the sequence of the priceplans they are filtered out for the remaining clusters
  *___________________________________________________________________________________________________________
  * @param pricePlans                            List of pricePlans extract for the particular Item in a cluster for selected attributes
  * @param clusterToSelectedPricePlan               For the selected pricePlans in other cluster, this map is populated
  * @param selectedClusterLower            Selected Cluster
  * ___________________________________________________________________________________________________________
  * ***********************************************************************************************************
  */
    public static List<Map<String,Object>> filterPricePlans (List<Map<String,Object>> pricePlans , Map<String,Double> clusterToSelectedPricePlan , String selectedClusterLower)
    {
        Map<String,Double> ClusterMapping = new Map<String,Double>{'BAS'=>1,'SMALL'=>2,'MEDIUM'=>3,'LARGE'=>4,'XLARGE'=>5,'PLUS'=>6};
        String selectedCluster = selectedClusterLower.toUpperCase();
        Set<Map<String,Object>> newList = new Set<Map<String,Object>>();
        Boolean flag = false;
        for(Integer i = 0;i<pricePlans.size();i++)
        {
            Map<String,Object> productCodeInFAMap = (Map<String,Object>)pricePlans[i];          
            flag = true;
            for(String key: clusterToSelectedPricePlan.keySet())
            {
                if(ClusterMapping.get(selectedCluster) > ClusterMapping.get(key))
                {
                    if((Double)productCodeInFAMap.get('SequenceNo') < (Double)clusterToSelectedPricePlan.get(key)){
                        flag = false ;
                        productCodeInFAMap.put('showRadio',False);
                    }
                }
                else if(ClusterMapping.get(selectedCluster) < ClusterMapping.get(key)){
                     if((Double)productCodeInFAMap.get('SequenceNo') > (Double)clusterToSelectedPricePlan.get(key)){
                        flag = false ;
                        productCodeInFAMap.put('showRadio',False);
                    }
                }
            }
            if(flag)
            {
                productCodeInFAMap.put('showRadio',true);
                newList.add(productCodeInFAMap);
            }
        }
        List<Map<String,Object>> newList2 = new List<Map<String,Object>>();
        for(Map<String,Object> newMap2 : newList){
            newList2.add(newMap2);
        }
        return newList2;
    }
    
    //Method called from the Reset button in summary modal, to reset special addon prices to default list price
    //UpdateRootItem lineStatus and PriceFlag based on Reset:LTAT-21684
    public static void resetPricePlans (Map<String, Object> inputMap, Map<String, Object> outMap)
    {
        String rootItemId = (String)inputMap.get('rootItemId');
        List<Quotelineitem> qliList = [SELECT Id,TeliaSE_Ceiling_Price__c,MC_Line_Status__c,vlocity_cmt__AssetReferenceId__c
                                       FROM Quotelineitem WHERE (vlocity_cmt__RootItemId__c =:rootItemId AND
                                       TeliaSE_ParentClusterCode__c!= null AND vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c = 'Framework') OR vlocity_cmt__AssetReferenceId__c=:rootItemId];
        for(QuoteLineItem qli: qliList){
            if(qli.vlocity_cmt__AssetReferenceId__c==rootItemId && qli.MC_Line_Status__c == 'Existing'){
                qli.MC_Line_Status__c = 'Updated';
                qli.MC_RootPriceFlag__c = true;
            }
            else{
                qli = resetPrice(qli);
            }
        }
        update qliList;
    }
    
    //Method to reset special addon prices to default list price
    public static Quotelineitem resetPrice(Quotelineitem qli){
        if(qli != null){
                qli.MC_Sales_FrameworkPricingMaster__c = null;
                qli.TeliaSE_MC_Customer_Requested_Price__c = null; //resetting the requested price to null
                qli.TeliaSE_Flag__c = System.Label.TeliaSE_HappyFace;
                qli.vlocity_cmt__RecurringCharge__c = qli.TeliaSE_Ceiling_Price__c;
        }
        return qli;
    }
    
     //Method to transform price plan summary DR response to be read in the template, called from the Price Plan Summary IP
    public static void transformSummaryResponse(Map<String,Object> inputMap , Map<String,Object> outMap){
        List<Map<String,Object>> qliList = (List<Map<String,Object>>) inputMap.get('qli');
        Map<String,AddOnSummary> qliMap = new Map<String,AddOnSummary>();
        for(Map<String,Object> qli: qliList){
            AddOnSummary summary = new AddOnSummary();
            if(qliMap.containsKey((String)qli.get('ProductCode'))){
                summary = qliMap.get((String)qli.get('ProductCode'));
            }
            summary.Name = (String)qli.get('Name');
            switch on (String)qli.get('Cluster') {
                when 'bas' {
                    summary.bas = qli.containsKey('Price') ? (String) qli.get('Price') : '-';
                }  
                when 'small' {
                    summary.small = qli.containsKey('Price') ? (String) qli.get('Price') : '-';
                }
                when 'medium' {
                    summary.medium = qli.containsKey('Price') ? (String) qli.get('Price') : '-';
                }
                when 'large' {
                    summary.large = qli.containsKey('Price') ? (String) qli.get('Price') : '-';
                }
                when 'xlarge' {
                    summary.xlarge = qli.containsKey('Price') ? (String) qli.get('Price') : '-';
                }
                when 'plus' {
                    summary.plus = qli.containsKey('Price') ? (String) qli.get('Price') : '-';
                }
                when else {}
            }
            qliMap.put((String)qli.get('ProductCode'),summary);
        }
        String str = (String)json.serialize(qliMap);
        Map<String,Object> finalResultmap = (Map<String,Object>) json.deserializeUntyped(str);
        outMap.put('result',finalResultmap.values());
    }
    
    private class AddOnSummary{
        private String bas ='-',small='-',medium='-',large='-',xlarge='-',plus='-';
        private String Name;
    }
}