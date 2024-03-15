/**
* @Author:      Sanjoli Agrawal
* @Company:     Capgemini
* @Date:        07 May, 2021
* @Description: This class is used to do the validation for the specific offerings added inside cpq cart and throw the error message accordingly.
* ----------------------------------------------------------------------------------------------------------------------------------------------
*/
global with sharing class MC_AgreementsValidation implements vlocity_cmt.VlocityOpenInterface2{
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('AgreementValidationforHeader')) {
                MC_AgreementsValidation.AgreementValidationforHeader(inputMap, outMap);//for header buttons
            } //priceupdate  function moved in this class
            else if(methodName.equalsIgnoreCase('AgreementValidationforSpara')){ 
                MC_AgreementsValidation.AgreementValidationforSpara(inputMap, outMap);//for save attribute configuration button
            }
            else{
                result = false;
            }   
            
        } catch(Exception e) {          
            result = false;
        }        
        return result;
    }
    
    // for entire cart for all the families we validate    
    public static void AgreementValidationforHeader(Map<String,Object> inputMap, Map<String,Object> outMap){
        String cartId = (String)inputMap.get('cartId');
        String OpportunityId = (String)inputMap.get('OpportunityId');
        Boolean SCValidationFlag = (Boolean)inputMap.get('SCValidationFlag'); //Added for handling validaiton on skapar offertdokument button by Sanjoli
        Boolean valideraFlag=false;
        if(inputMap.containsKey('valideraFlag')){
            if((Boolean)inputMap.get('valideraFlag')){valideraFlag=true;}
        }        
        List<QuoteLineItem> ql = [SELECT id,TeliaSE_Product_Object_Type__c,vlocity_cmt__AssetReferenceId__c,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_Target_Price__c,
                                  vlocity_cmt__RootItemId__c,TeliaSE_Root_Product__c,TeliaSE_MC_Binding_Time__c,vlocity_cmt__ParentItemId__c,TeliaSE_ParentClusterCode__c, 
                                  TeliaSE_Root_Product__r.ProductCode,MC_Line_Status__c,AvgPriceFLag__c, vlocity_cmt__Product2Id__r.Name,
                                  vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name,TeliaSE_MC_FACallOffQuantity__c,
                                  TeliaSE_Product_Code__c,vlocity_cmt__Product2Id__r.vlocity_cmt__ParentClassId__c,TeliaSE_CommitmentPeriod__c,
                                  vlocity_cmt__Product2Id__r.TeliaSE_TemplateCategory__c,Quote.TeliaSE_Agreement_Nr__c,MC_Reprice_Required__c,
                                  TeliaSE_Root_Product__r.Name,Product2.TeliaSE_Price_Flag__c,MC_Matrix_Version__c,Quote.MC_Commercial_Setup__c,Product2.Name,
                                  Quote.TeliaSE_MC_Sales_Flow_Identifier__c,vlocity_cmt__AttributeSelectedValues__c,TeliaSE_Ceiling_Price__c,Product2.ProductCode,
                                  Product2.MC_Product_Negotiability__c,MC_Sales_FrameworkPricingMaster__c,quote.MC_Sync_Autotask__c,Quote.Opportunity.MC_ITDaaS_Info__c
                                  FROM QuoteLineItem WHERE QuoteId =:cartId order by vlocity_cmt__SequenceNumber__c];
        if(ql.size()>0){    
            MC_AgreementsValidation.maxQuantityValidation(ql,outMap);
            if((String)outMap.get('Success') == 'false'){
                //outMap.put('maxQuantityFailed','true');
                //String errMsg = (String)outMap.get('ErrMsg');
                //System.debug('entrd here');
                outMap.put('Error',System.label.MaxQuantityValidation);
            }
            
            // CO + B2B can't co-exists validation
            // 02.02.2023 - Itishree Dash
            else{
                if(System.label.B2BSolution_Toggle=='true' || test.isRunningTest()){
                    MC_AgreementsValidation.COB2Bvalidation(ql,outMap);
                    if((String)outMap.get('Success') == 'false'){
                        if((Boolean)outMap.get('COB2BCoexistError')){
                            outMap.put('Error',System.label.MC_ErrB2BCOCoexist);
                        }
                    }
                }
                
                // SekunderAccess Addition Warning  
                MC_AgreementsValidation.sekunderAccessValidation(ql,outMap);
                if((Boolean)outMap.get('SekunderAccessPresent')){
                    outMap.put('Error',System.label.MC_SekunderAccessMsg);
                    outMap.put('Warning','true');
                    //System.debug('outMap'+outMap);
                }
                //LTAART-12 Hybrid Pricing: AC8 
                //Validation: If hybrid products have a requested price which is not a valid price than can be assigned, we will block the users to Continue by throwing an error
                MC_AgreementsValidation.hybridPricingValidation(ql,outMap);
                if(outMap.containsKey('Success') && (String)outMap.get('Success')=='false' && outMap.containsKey('FailureMethod') && (String)outMap.get('FailureMethod') == 'hybridPricingValidation'){
                    String finalError = System.label.MC_Sales_hybridPricingErr.substringBefore('XX')+' '+(String)outMap.get('errorHybridProdNames')+' '+System.label.MC_Sales_hybridPricingErr.substringAfter('XX');
                    outMap.put('Error',finalError);
                }
                
                //LTAT-20076
                //This Method is used to validate ITDaaS & IT-support products in cart
                MC_AgreementsValidation.itdaasValidations(ql,outMap);
                
                Map<String,String> rangeAttrToMatrixNameMap=new Map<String,String>();
                rangeAttrToMatrixNameMap=MC_AgreementsValidation.rangeAttrToMatrixName();
                MC_AgreementsValidation.checkBindingAttribute(ql, inputMap, outMap, valideraFlag,rangeAttrToMatrixNameMap,OpportunityId);
                if((String)outMap.get('Success') == 'false'){
                    
                    if((Boolean)outMap.get('SameBindingTimeError')==true){
                        String errMsg = System.label.MC_Office365_BindingTime_Error;
                        outMap.put('Error',errMsg);
                        outMap.put('ValideraSparaError',false);
                    }
                }
                // Old portfolio + new portfolio validation
                // 21.09.2021 - Abhinav Gupta
                else{
                    MC_AgreementsValidation.oldNewPortfolioError(ql,outMap);
                    if((String)outMap.get('Success') == 'false'){
                        if(outMap.get('ErrorScenario') == 'old and new product together in cart'){
                            String errMsg3= System.label.MC_Old_NewPortfolioError;
                            outMap.put('Error',errMsg3);
                        }
                        else if (outMap.get('ErrorScenario') == 'old product modified'){
                            String errMsg4 = 'Om du vill göra prisändringar finns det en ny mobilportfölj lanserad som du måste använda. Du behöver uppdatera din varukorg med den nya mobila portföljen. Detta gör du enklast genom att lägga in den nya portföljen i din varukorg samt spegla kundens tjänster innan du tar bort den gamla.';
                            outMap.put('Error',errMsg4);
                        }                            
                    }
                    else{
                        MC_AgreementsValidation.TPPOCMobileValidation(ql,outMap);
                        if((String)outMap.get('Success') == 'false'){
                            outMap.put('Error','Observera att kunden måste ha ett mobilt avtal hos Telia för att kunna avtala om Touchpoint Plus.');
                        }
                        else{
                            //checkBasSubscriptionAndAttribute added by Abhishek for validera                   
                            MC_AgreementsValidation.checkBasSubscriptionAndAttribute(ql,outMap,valideraFlag);
                            if((String)outMap.get('Success') == 'true'){
                                MC_AgreementsValidation.scMobileClusterValidations(ql, outMap,SCValidationFlag);
                                if((String)outMap.get('Success') == 'false'){
                                    outMap.put('sCValidationFailed','true');
                                    if (outMap.get('FailScenario')=='No Mobile Offering Exist'){
                                        outMap.put('errorToken','noMobileExist');
                                    }
                                    else if (outMap.get('FailScenario')=='Incorrect cluster structure with new portfolio'){
                                        outMap.put('errorToken','newClusterMismatch');
                                    }
                                    else if (outMap.get('FailScenario')=='Incorrect cluster structure with old portfolio'){
                                        outMap.put('errorToken','oldClusterMismatch');
                                    } 
                                    else if (outMap.get('FailScenario')=='Incorrect cluster prices'){
                                        outMap.put('errorToken','priceValidationFail');
                                    }
                                }else{
                                    outMap.put('Success', 'true');
                                }
                                
                            }                    
                            
                        }
                        
                    }
                    
                }//arup
            }
        }
        else{
            outMap.put('Success', 'true');
        }
    }
    
    // for the selected bundle which we configure in the cart--> we use rootItemId
    public static void AgreementValidationforSpara(Map<String,Object> inputMap, Map<String,Object> outMap){
        
        String cartId = (String) inputMap.get('cartId');
        String rootItemId= String.ValueOf(inputMap.get('rootItemId'));
        String OpportunityId = (String) inputMap.get('OpportunityId');
        Boolean coErrorFlag=false;
        List<QuoteLineItem> ql = [select id,vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__AssetReferenceId__c,TeliaSE_Product_Object_Type__c, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.vlocity_cmt__ObjectTypeId__r.vlocity_cmt__ParentObjectClassId__r.Name, TeliaSE_Product_Code__c ,  vlocity_cmt__Product2Id__r.vlocity_cmt__ParentClassId__c,vlocity_cmt__Product2Id__r.id from QuoteLineItem where QuoteId =:cartId  and (vlocity_cmt__RootItemId__c=:rootItemId or id=:rootItemId)];
        //Added by Vamsi
        //For excluding particualar products from exceptions SALEF-8292
        String productsExcluded = System.Label.COExcludeExceptions;
        List<String> prodExclude = new List<String>();
        if(productsExcluded != ''){
            prodExclude = productsExcluded.split(';');
        }
        
        if(ql.size()>0){
            String errMsg1= System.label.MC_Precheck_Save_Error1;
            String errMsg2= System.label.MC_Precheck_Save_Error2;
            List<String> pcpro=new List<String>();           
            for(QuoteLineItem q: ql){
                Map<String,Object> attrValueMap = (Map<String,Object>)JSON.deserializeUntyped(q.vlocity_cmt__AttributeSelectedValues__c);
                Boolean avgPriceFlag =attrValueMap.containsKey('ATT_RT_PRICEAVG')?(Boolean)attrValueMap.get('ATT_RT_PRICEAVG'): false;                                                        
                if((q.TeliaSE_Product_Object_Type__c=='Broadband Plus Offering Spec' || q.TeliaSE_Product_Object_Type__c=='Broadband Datanet Offering Spec' || q.TeliaSE_Product_Object_Type__c=='Broadband Pro Offering Spec')&& avgPriceFlag== true){
                    if(!prodExclude.contains(q.TeliaSE_Product_Code__c)){
                        pcpro.add(q.TeliaSE_Product_Code__c);
                    }
                }//other offerings
                //Validation for Spara when CO products are configured by end user.
                if(System.label.B2BSolution_Toggle=='true'){
                    if(q.TeliaSE_Product_Code__c.startsWith('CO-')){
                        outMap.put('Success', 'false');
                        outmap.put('Error',System.label.MC_Error_B2B_CO_Config);
                        coErrorFlag=true;
                        break;
                    }
                }
            }
            if(pcpro.size()>0 && !coErrorFlag){
                PrecheckValidate(OpportunityId,outMap,pcpro,errMsg1,errMsg2);
            }
        }
        //other offerings
        else{
            outMap.put('Success', 'true');
        }
    }
    
    public static void PrecheckValidate(String OpportunityId,Map<String,Object> outMap,List<String> pcpro,String errMsg1,String errMsg2){
        List<MC_PreCheck_Result__c> query=[select id,Name, MC_Product_Code__c, MC_Product_Family__c, RecordType.Name,Price__c, MC_Product_Name__c from  MC_PreCheck_Result__c where Opportunity__c =:OpportunityId and RecordType.Name ='AveragePrice' and  MC_Product_Code__c in:pcpro];
        if(query.size()>0){
            Integer i = 0;
            for(MC_PreCheck_Result__c sa: query){
                if(sa.Price__c<=0){
                    i = i+1;
                    errMsg1= errMsg1+', '+sa.Name;
                    outMap.put('Success', 'false');
                }
            }
            if(i > 0){
                outMap.put('Error',errMsg1+ ' '+ errMsg2);
            }
            else{
                outMap.put('Success', 'true');
            }
        }else{
            String errMsg3= System.label.MC_Precheck_Header_Error3;
            outMap.put('Success', 'false');
            outmap.put('Error',errMsg3);
        }
    }
    
    public static void oldNewPortfolioError(List<QuoteLineItem> quoteItemList,Map<String,Object> outMap){
        List<String> productIds = new List<String>();
        List<String> newProducts = new List<String>();
        for (String tc: TeliaSE_PortfolioIdentifiers__c.getAll().keySet())
        {
            if(TeliaSE_PortfolioIdentifiers__c.getAll().get(tc).ProductId__c != null)
            {
                productIds.add(TeliaSE_PortfolioIdentifiers__c.getAll().get(tc).ProductId__c);
                newProducts.add(TeliaSE_PortfolioIdentifiers__c.getAll().get(tc).NewProductCode__c);
            }
            if(TeliaSE_PortfolioIdentifiers__c.getAll().get(tc).RetiredPortfolio__c != null)
            {
                productIds.add(TeliaSE_PortfolioIdentifiers__c.getAll().get(tc).RetiredPortfolio__c);
            }
        }
        
        Boolean oldProdFlag = false,newProdFlag = false,oldProdmodified = false,oldChildProductAdded = false;
        List<Id> rootItemIds = new List<Id>();
        for(quotelineitem ql:quoteItemList){
            if(productIds.contains(ql.vlocity_cmt__Product2Id__r.id)){
                rootItemIds.add(ql.vlocity_cmt__Product2Id__r.id);
                oldProdFlag= true;
                if(ql.MC_Line_Status__c == null || ql.MC_Line_Status__c == 'Existing'){
                    oldProdmodified = false;
                }
                else{
                    oldProdmodified = true;
                }
            }
            if(newProducts.contains(ql.TeliaSE_Product_Code__c)){
                newProdFlag =true;
            }
        }
        outMap.put('oldMobPortfolio',oldProdFlag);
        outMap.put('newMobPortfolio',newProdFlag);
        if(rootItemIds.size()>0){
            for(quotelineitem ql:quoteItemList)
            {
                if(rootItemIds.contains((Id)ql.TeliaSE_Root_Product__c) && ql.vlocity_cmt__RootItemId__c != null && ql.MC_Line_Status__c == 'Added'){
                    oldChildProductAdded = true;
                }
            } 
        }
        if(oldProdFlag && newProdFlag){
            outMap.put('Success', 'false');
            outMap.put('ErrorScenario','old and new product together in cart');
        }
        else if(oldProdFlag && oldProdmodified && oldChildProductAdded) {
            outMap.put('Success', 'false');
            outMap.put('ErrorScenario','old product modified');
        }
        else
        {
            outMap.put('Success', 'true');
        }
    }
    
    public static void TPPOCMobileValidation (List<QuoteLineItem> quoteItemList,Map<String,Object> outMap){
        Set<String> objecTyp = new Set<String>();
        boolean OCFlag=false ;
        String agreementNumber;
        for (QuoteLineItem qli:quoteItemList){
            objecTyp.add(qli.TeliaSE_Product_Object_Type__c!=NULL?qli.TeliaSE_Product_Object_Type__c:NULL );
            agreementNumber= qli.quote.TeliaSE_Agreement_Nr__c;
        }
        if (objecTyp.contains('Operator Connect Offer Spec')){
            OCFlag=true;
        }
        if (objecTyp.contains('TouchPoint Plus Offer Spec') || objecTyp.contains('Operator Connect Offer Spec')){
            if (objecTyp.contains('Mobile Offer Specification') || agreementNumber !=NULL ){
                outMap.put('Success', 'true');
            }
            else{
                outMap.put('Success', 'false');
                outMap.put('OCFlag',OCFlag);
            }
        }
    }
    
    //COB2Bvalidation Method created to validate the availability of both CO and B2B offerings in same cart
    public static void COB2Bvalidation (List<QuoteLineItem> quoteItemList,Map<String,Object> outMap){
        boolean COOffer=false,B2bOffer=false ;
        for (QuoteLineItem qli:quoteItemList){
            if(qli.vlocity_cmt__ParentItemId__c==null){
                if(qli.TeliaSE_Product_Code__c.startsWith('CO-')){
                    COOffer=true;
                }
                if(qli.TeliaSE_Product_Code__c.startsWith('B2B-')){
                    B2bOffer=true;
                }
            }
        }
        if (COOffer && B2bOffer){
            outMap.put('Success', 'false');
            outMap.put('COB2BCoexistError',true);           
        }
        else{
            outMap.put('Success', 'true');
            outMap.put('COB2BCoexistError',false); 
        }
    }
    
    //Method for Secondary access products validation message in cart to add Hera information later in offer document generation flow -LTAT-5855
    public static void SekunderAccessValidation (List<QuoteLineItem> quoteItemList,Map<String,Object> outMap){
        Set<String> sekunderParentIdSet = new Set<String>();
        List<String> sekundarParentProducts = (System.Label.MC_SekunderAccessParentProducts).split(',');
        for(QuoteLineItem qli : quoteItemList){
            if(sekundarParentProducts.contains(qli.Product2.ProductCode)){
                sekunderParentIdSet.add(qli.vlocity_cmt__AssetReferenceId__c);
            }
        }
        for(QuoteLineItem qli : quoteItemList){
            if(qli.vlocity_cmt__ParentItemId__c!=null && sekunderParentIdSet.contains(qli.vlocity_cmt__ParentItemId__c) && qli.MC_Line_Status__c == 'Added'){      
                outMap.put('SekunderAccessPresent',true);
                break;
            }
            else{
                outMap.put('SekunderAccessPresent',false);
            }
        }
    }
    
    public static void scMobileClusterValidations (List<QuoteLineItem> qli,Map<String,Object> outMap, Boolean SCValidationFlag){
        Boolean testclass = false;
        if(Test.isRunningTest()){
            testclass = true;
        }
        String mobVersion,agreementNr,salesFlowIdentifier;
        Boolean Success=false,oldPortfolio= false,oldMobPortfolio,newMobPortfolio,newPortfolio= false;
        Set<String> objecTyp = new Set<String>();
        Set<String> mobileClusterSet = new Set<String>();
        Set<String> scClusterSet = new Set<String>();
        List<SortClusterWrapper> scClusterQLIList = new List<SortClusterWrapper>();
        
        oldMobPortfolio=Boolean.valueOf(outMap.get('oldMobPortfolio'));
        newMobPortfolio=Boolean.valueOf(outMap.get('newMobPortfolio'));
        Boolean oldScOffering = true;
        List<String> templateCategories = (System.Label.MC_ClusterPriceValidationCategories).split(','); //list of templ categories to consider for cluster price validation
        for (QuoteLineItem ql: qli){
            objecTyp.add(ql.TeliaSE_Product_Object_Type__c!=NULL?ql.TeliaSE_Product_Object_Type__c:NULL );
            agreementNr = ql.quote.TeliaSE_Agreement_Nr__c;
            salesFlowIdentifier = ql.Quote.TeliaSE_MC_Sales_Flow_Identifier__c;
            
            
            //adding only cluster addons - user packages
            if(templateCategories.contains(ql.vlocity_cmt__Product2Id__r.TeliaSE_TemplateCategory__c)){
                scClusterQLIList.add(new SortClusterWrapper(ql));
            }
            if (ql.TeliaSE_Product_Code__c.contains('SC_')  || ql.TeliaSE_Product_Code__c.contains('MOB_')){
                if(ql.TeliaSE_Product_Code__c.contains('MOB_')){
                    //improved the logic to avoid the use of rootitemId field.
                    if(oldMobPortfolio== true){
                        oldPortfolio= true;
                    }
                    else if(newMobPortfolio== true){
                        newPortfolio= true;
                        if(ql.TeliaSE_ParentClusterCode__c != null && ql.TeliaSE_Product_Object_Type__c =='Virtual Offer Products'){
                            String capsLckMobileCluster= ql.TeliaSE_ParentClusterCode__c.toUpperCase();
                            mobileClusterSet.add(capsLckMobileCluster);
                        }
                    }
                }
                else if(ql.TeliaSE_Product_Code__c.contains('SC_') ||ql.TeliaSE_Product_Code__c.contains('SC-') ){
                    if( ql.TeliaSE_ParentClusterCode__c!= null){
                        String capsLckScClusterSet= ql.TeliaSE_ParentClusterCode__c.remove('SC_KLU_');
                        scClusterSet.add(capsLckScClusterSet);
                    }
                    if(ql.MC_Line_Status__c == 'Updated' || ql.MC_Line_Status__c == 'Added'){
                        oldScOffering = false;
                    }
                }
            }
        }
        
        if((objecTyp.contains('Smart Connect Offer Spec') && SCValidationFlag== true ) || testclass){
            if((objecTyp.contains('Mobile Offer Specification') || agreementNr != NULL ) || testclass){
                outMap.put('Success','true');
                Success = true;
                if(newPortfolio== true){
                    if(salesFlowIdentifier == 'Tilläggsförhandling' && oldScOffering == true && scClusterSet.contains('LEGACY')){
                        outMap.put('Success','true');
                        Success = true;                        
                    }
                    else{
                        if(mobileClusterSet.size() == scClusterSet.size()){
                            if(mobileClusterSet.size()>0 ){
                                Set<String> matchCluster = new Set<String>();
                                for(String mobClster:mobileClusterSet){
                                    if(scClusterSet.contains(mobClster)){
                                        matchCluster.add(mobClster);
                                    }
                                }
                                if(matchCluster.size()==scClusterSet.size()){
                                    //if newPortfolio & cluster size validation is passed, call method to cluster product prices
                                    scClusterPriceValidations(scClusterQLIList,outMap);   
                                }
                                else{
                                    String joinedStringMob = String.join(new List<String>(mobileClusterSet), ', ');
                                    outMap.put('mobList',joinedStringMob);
                                    outMap.put('Success','false');
                                    Success = false;
                                    outMap.put('FailScenario','Incorrect cluster structure with new portfolio');
                                }
                            }
                            else{
                                outMap.put('Success','true');
                                Success = true;
                            }
                        }
                        else{
                            String joinedStringMob = String.join(new List<String>(mobileClusterSet), ', ');
                            //System.debug('joinedStringMob1'+joinedStringMob);
                            outMap.put('mobList',joinedStringMob);
                            outMap.put('Success','false');
                            Success = false;
                            outMap.put('FailScenario','Incorrect cluster structure with new portfolio');   
                        }
                    }
                }
                else if(oldPortfolio== true || agreementNr != NULL){
                    if(scClusterSet.size()==1 && scClusterSet.contains('LEGACY')){
                        outMap.put('Success','true');
                        Success = true;
                    }
                    else{
                        Success = false;
                        outMap.put('Success','false');
                        outMap.put('FailScenario','Incorrect cluster structure with old portfolio');
                    }
                }
            }
            else{
                outMap.put('Success','false');
                outMap.put('FailScenario','No Mobile Offering Exist' );
            }
        }
    }
    
    //method to validate Smart Connect Cluster product prices MCSTO-9164 AC4
    private static void scClusterPriceValidations (List<SortClusterWrapper> scClusterQLIList,Map<String,Object> outMap){
        if(scClusterQLIList.size() > 0){
            String failedClustersText;
            scClusterQLIList.sort(); //list of clusters sorted in descending order (PLUS to BAS)
            Double priceToCompare = scClusterQLIList[0].price; //taking price of largest cluster (eg: PLUS) as base for comparison
            List<String> failedClusterCodes = new List<String>();
            for(integer i=0 ; i<scClusterQLIList.size()-1; i++) {
                
                //price of each cluster should be lower than the price of clusters smaller than it
                //Bas (Highest price) ≥ Small ≥ Medium ≥ Large ≥ Xtra Large ≥ Plus (Lowest price)
                //updated logic to compare prices starting from largest cluster(eg: PLUS) and moving upwards for comparison MCSTO-10724(23.1)
                if(priceToCompare > scClusterQLIList[i+1].price) {
                    //System.debug('here__'+scClusterQLIList[i+1]); //found elements that are out of order - return false
                    failedClusterCodes.add(scClusterQLIList[i+1].clusterCode);
                }else{
                    priceToCompare = scClusterQLIList[i+1].price;
                }
            }
            if(failedClusterCodes.size() > 0){
                //addtional for loop to reverse the order of failed clusters to be displayed in the error msg in cart (BAS to PLUS)
                for(Integer i=failedClusterCodes.size()-1; i>=0; i--){
                    failedClustersText = String.isBlank(failedClustersText)? scClusterQLIList[0].name + ': '+failedClusterCodes[i] : failedClustersText+ ', '+failedClusterCodes[i];
                }
                outMap.put('Success','false');
                outMap.put('FailScenario','Incorrect cluster prices');
                outMap.put('FailItems',failedClustersText);
            }else{
                outMap.put('Success','true');
            }
        }
        else{
            outMap.put('Success','true');
        }
    }
    
    //Added by Abhishek for DataPaket for BAS and Kluster Bas validation on validera
    public static void checkBasSubscriptionAndAttribute(List<QuoteLineItem> qli,Map<String,Object> outMap,Boolean valideraFlag){
        if(valideraFlag==true && qli.size()>0){
            Boolean datanet = false,bas = false;
            for(QuoteLineItem q:qli){
                if(q.TeliaSE_Product_Code__c=='MOB_BAS_V2'){bas=true;}
                if(q.TeliaSE_Product_Code__c=='MOB_DATA_PORTFOLIO'){datanet=true;}
                if(bas==true && datanet==true){break;}
            }
            if((datanet && !bas) || (!datanet && bas)){//Check if datapaket for bas is present and not jobbmobil bas and vice versa
                outMap.put('BasDataPaketValidationMssg',System.label.MC_BAS_ProdMissing);
                outMap.put('BasDataPaketValidationFailed','true');
                outMap.put('Success','false');
            }else{
                outMap.put('Success','true');
                outMap.put('BasDataPaketValidationFailed','false');
            }
        }else{
            outMap.put('Success','true');
            outMap.put('BasDataPaketValidationFailed','false');
        }
    }
    public static void checkBindingAttribute(List<QuoteLineItem>qli, Map<String,Object> inputMap, Map<String,Object> outMap, Boolean valideraFlag,Map<String,String> rangeAttrToMatrixNameMap,String OpportunityId){
        
        Boolean isTestClass=false;
        if(Test.isRunningTest()){
            isTestClass = true;
        }
        String bindingPrd;
        Map<String, MC_OfferCreation_ObjSplit__c> objectTypesToCheck = MC_OfferCreation_ObjSplit__c.getAll(); //object types list from custom setting to check for same bindingPeriod
        Map<String, List<String>> objTypeToBindingMap = new Map<String, List<String>>();
        List<String> errorObjectTypes = new List<String>();
        
        if(valideraFlag == true && qli.size()>0){
            Set<String> rootSparaNeeded=new Set<String>();
            Set<String> rootsUpdated = new Set<String>();
            Map<String, String> rootSparaNeededBindingPrd = new Map<String,String>();
            //List<String> avgPriceProducts=new List<String>();
            Map<String,Double> prodCodeToAvgPrice=new Map<String,Double>();
            Map<QuoteLineItem,String> prodCodeToRootProdCode=new Map<QuoteLineItem,String>();
            for(QuoteLineItem ql:qli){
                if(ql.vlocity_cmt__ParentItemId__c == null && ql.TeliaSE_MC_Binding_Time__c <> NULL){
                    rootSparaNeededBindingPrd.put(ql.vlocity_cmt__RootItemId__c, ql.TeliaSE_MC_Binding_Time__c);
                }
            }
            for(QuoteLineItem ql:qli){
                //same binding time check generalized to handle based on object types from custom setting
                if(objectTypesToCheck.containsKey(ql.TeliaSE_Product_Object_Type__c) && ql.vlocity_cmt__ParentItemId__c == null){
                    List<String> bindingPeriodList = new List<String>();    
                    if(objTypeToBindingMap.containsKey(ql.TeliaSE_Product_Object_Type__c)){
                        bindingPeriodList = objTypeToBindingMap.get(ql.TeliaSE_Product_Object_Type__c);
                    }
                    if(bindingPeriodList.contains(ql.TeliaSE_MC_Binding_Time__c)){
                        errorObjectTypes.add(ql.TeliaSE_Product_Object_Type__c); 
                    }
                    else if(ql.TeliaSE_MC_Binding_Time__c != null){
                        bindingPeriodList.add(ql.TeliaSE_MC_Binding_Time__c);
                        objTypeToBindingMap.put(ql.TeliaSE_Product_Object_Type__c, bindingPeriodList);
                    }
                }
                //logic to check if spara is  needed
                if(ql.MC_Reprice_Required__c==true && ql.TeliaSE_Root_Product__c !=null && ql.Product2.TeliaSE_Price_Flag__c==true){
                    bindingPrd =rootSparaNeededBindingPrd.containsKey(ql.vlocity_cmt__RootItemId__c)?rootSparaNeededBindingPrd.get(ql.vlocity_cmt__RootItemId__c).split(' ')[0]+' '+ 'mån':'';
                    rootSparaNeeded.add(ql.TeliaSE_Root_Product__r.Name + ' '+bindingPrd);          
                }
                
                if(ql.TeliaSE_Root_Product__c !=null && ql.Product2.TeliaSE_Price_Flag__c==true && rangeAttrToMatrixNameMap.size()>0 && ql.MC_Matrix_Version__c!=null && ql.vlocity_cmt__ParentItemId__c==null){
                    if(ql.Quote.TeliaSE_MC_Sales_Flow_Identifier__c=='New Sales' || (ql.Quote.TeliaSE_MC_Sales_Flow_Identifier__c=='Omforhandling' && ql.MC_Line_Status__c=='Updated')|| (ql.Quote.TeliaSE_MC_Sales_Flow_Identifier__c=='Tilläggsförhandling' && ql.MC_Line_Status__c=='Added')){
                        
                        rootsUpdated.add((String)ql.TeliaSE_Root_Product__c);
                        if(rangeAttrToMatrixNameMap.containsKey(ql.Quote.MC_Commercial_Setup__c+ql.TeliaSE_Root_Product__r.ProductCode)){
                            DateTime dTime = System.now(); 
                            vlocity_cmt__CalculationMatrixVersion__c matrixVersion=[Select Id from vlocity_cmt__CalculationMatrixVersion__c where vlocity_cmt__CalculationMatrixId__r.Name = :(rangeAttrToMatrixNameMap.get(ql.Quote.MC_Commercial_Setup__c+ql.TeliaSE_Root_Product__r.ProductCode))
                                                                                    and vlocity_cmt__IsEnabled__c=true AND vlocity_cmt__StartDateTime__c <= :dTime AND (vlocity_cmt__EndDateTime__c>= :dTime OR vlocity_cmt__EndDateTime__c=null)
                                                                                    Order by vlocity_cmt__Priority__c DESC limit 1][0];
                            if(matrixVersion!=null){
                                if((Id)(matrixVersion.Id)!=(Id)(ql.MC_Matrix_Version__c)){
                                    bindingPrd =rootSparaNeededBindingPrd.containsKey(ql.vlocity_cmt__RootItemId__c)?rootSparaNeededBindingPrd.get(ql.vlocity_cmt__RootItemId__c).split(' ')[0]+' '+ 'mån':'';                                   
                                    rootSparaNeeded.add(ql.TeliaSE_Root_Product__r.Name + ' '+bindingPrd);
                                }
                            }
                        }
                    }
                }
                
                if(ql.vlocity_cmt__AttributeSelectedValues__c!=null){    
                    Map<String,Object> attrValueMap = (Map<String,Object>)JSON.deserializeUntyped(ql.vlocity_cmt__AttributeSelectedValues__c);
                    Boolean avgPriceFlag =attrValueMap.containsKey('ATT_RT_PRICEAVG')?(Boolean)attrValueMap.get('ATT_RT_PRICEAVG'): false;         
                    if(isTestClass){avgPriceFlag=true;}
                    if(((ql.TeliaSE_Product_Object_Type__c=='Broadband Plus Offering Spec' || ql.TeliaSE_Product_Object_Type__c=='Broadband Datanet Offering Spec' || ql.TeliaSE_Product_Object_Type__c=='Broadband Pro Offering Spec')&& avgPriceFlag== true) || isTestClass){
                        prodCodeToRootProdCode.put(ql,ql.TeliaSE_Root_Product__r.Name);
                    }
                }
            }
            if(errorObjectTypes.size() > 0){
                outMap.put('Success','false');
                outMap.put('SameBindingTimeError',true);                
            }
            Set<String> coAvgPriceChangeRoots = new Set<String>();    
            if(prodCodeToRootProdCode.keySet().size()>0)
            {
                coAvgPriceChangeRoots = checkAVgPriceChangedV2(prodCodeToRootProdCode,rootsUpdated,OpportunityId,rootSparaNeededBindingPrd);
            }
            if(coAvgPriceChangeRoots.size()>0)
            {
                rootSparaNeeded.addAll(coAvgPriceChangeRoots);
            }
            if(rootSparaNeeded.size()>0){
                outMap.put('Success','false');             
                outMap.put('ProductsNeedSpara',System.label.ValideraError1+ ' '+string.valueof(rootSparaNeeded).replace('{','').replace('}','')+ '\n' +System.label.ValideraError2);
                outMap.put('ValideraSparaError','true');
            }
        }
    }
    
    public static Map<String,String> rangeAttrToMatrixName(){
        Map<String,String> rangeAttrToMatrixNameMap=new Map<String,String>();
        for(String key : MC_RangeAttributePricingMatrixSettings__c.getAll().keySet()){
            //Build key with recordtype+productfamily code
            if(MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Active__c == true){
                String newKey = MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Customer_Segment__c + MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Product_Family_Code__c;
                rangeAttrToMatrixNameMap.put(newKey, MC_RangeAttributePricingMatrixSettings__c.getAll().get(key).Matrix_Name__c);
            }
        }
        return rangeAttrToMatrixNameMap;
    }
    
    public static Set<String> checkAVgPriceChangedV2(Map<QuoteLineItem,String> prodCodeToRootProdCode,Set<String> rootsUpdated,String OpportunityId, Map<String,String> rootSparaNeededBindingPrd){
        String bindingPrd;
        Set<String> rootNeedsSpara=new Set<String>();
        String productsExcluded = System.Label.COExcludeExceptions;
        List<String> prodExclude = new List<String>();
        if(productsExcluded != ''){
            prodExclude = productsExcluded.split(';');
        }
        List<MC_PreCheck_Result__c> precheckResult=[select id,Name, MC_Product_Code__c, MC_Product_Family__c, RecordType.Name,Price__c, MC_Product_Name__c from  MC_PreCheck_Result__c where Opportunity__c =:OpportunityId and RecordType.Name ='AveragePrice'];
        Map<String,Double> productCodeToAvgPrice = new Map<String,Double>();
        for(MC_PreCheck_Result__c pre:precheckResult){
            if(!prodExclude.contains(pre.MC_Product_Code__c)){
                productCodeToAvgPrice.put(pre.MC_Product_Code__c,pre.Price__c);
            }
        }
        for(QuoteLineItem qli:prodCodeToRootProdCode.keySet())
        {
            if(productCodeToAvgPrice.containsKey((String)qli.TeliaSE_Product_Code__c) && productCodeToAvgPrice.get((String)qli.TeliaSE_Product_Code__c) != (Double)qli.TeliaSE_Ceiling_Price__c && rootsUpdated.contains((String)qli.TeliaSE_Root_Product__c))
            {
                bindingPrd =rootSparaNeededBindingPrd.containsKey(qli.vlocity_cmt__RootItemId__c)?rootSparaNeededBindingPrd.get(qli.vlocity_cmt__RootItemId__c).split(' ')[0]+' '+ 'mån':'';
                rootNeedsSpara.add(prodCodeToRootProdCode.get(qli)+ ' '+bindingPrd);
            }
        }
        return rootNeedsSpara;
    }
    //Sanjoli: Added for Max Quantity Validation inside the cart. 
    public static void maxQuantityValidation(List<QuoteLineItem> qlis,Map<String,Object> outMap){
        List<Id> productIds = new List<Id>();
        String validated = 'true';
        Map<String,Integer> prodtoQuan = new Map<String, Integer>();
        
        outMap.put('Success', 'true');
        for (QuoteLineItem qli: qlis){
            if(qli.vlocity_cmt__Product2Id__c <> NULL && qli.TeliaSE_MC_FACallOffQuantity__c <> NULL){
                productIds.add(qli.vlocity_cmt__Product2Id__c);
                prodtoQuan.put(qli.vlocity_cmt__Product2Id__c, (Integer)qli.TeliaSE_MC_FACallOffQuantity__c);
            }
        }
        Map<String,Decimal> productIdtoQuantity = new Map<String,Decimal>();
        for(vlocity_cmt__ProductChildItem__c pc: [Select id,vlocity_cmt__ChildProductId__c,vlocity_cmt__ParentProductId__c,vlocity_cmt__ChildProductName__c,vlocity_cmt__ChildProductId__r.ProductCode, vlocity_cmt__ParentProductName__c, vlocity_cmt__MaxQuantity__c from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__c in : productIds and vlocity_cmt__MaxQuantity__c < 9999]){
            if(prodtoQuan.get(pc.vlocity_cmt__ChildProductId__c) > pc.vlocity_cmt__MaxQuantity__c){
                outMap.put('Success', 'false');
                //System.debug('entrd');
                break;
            }
            
        }
    }
    
    /*
* Developer: Abhinav Gupta
* EPIC/Product: LTAART12 : Hybrid Pricing
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This Method is used to validate if All hybrid pricing products, if are negotiated are negotiated with a valid price.
*___________________________________________________________________________________________________________
* params - ql - QuoteLineItem list
* params - outputMap - We send back the errors if any.
*/
    public static void hybridPricingValidation(List<QuoteLineItem> qlList ,Map<String,Object> outMap){
        Boolean valid = true;
        String errorHybridProdNames = '';
        for(QuoteLineItem ql : qlList){
            if(ql.product2.MC_Product_Negotiability__c == 'Hybrid' && ql.TeliaSE_MC_Customer_Requested_Price__c != null && ql.MC_Sales_FrameworkPricingMaster__c == null){
                valid = false;
                errorHybridProdNames += errorHybridProdNames == ''? ql.product2.Name : ','+ql.product2.Name;
            }
        }
        if(!valid){
            outMap.put('errorHybridProdNames',errorHybridProdNames);
            outMap.put('Success','false');
            outMap.put('FailureMethod','HybridPricingValidation');
        }
    }

 /*
* Developer: Pancham Verma
* Story: LTAT-20076
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This Method is used to validate ITDaaS & IT-support products in cart
*___________________________________________________________________________________________________________
* params - ql - QuoteLineItem list
* params - outputMap - We send back the errors if any.
*/    
    public static void itdaasValidations(List<QuoteLineItem> qlList, Map<String, Object> outMap) {
        String rootItem = null;
        for (QuoteLineItem ql : qlList) {	
            //Check if we have more than one ITSupport/ITDaaS products with quanites
            if (ql.TeliaSE_MC_FACallOffQuantity__c != null && ql.TeliaSE_Product_Object_Type__c.equals('ITDaaS Offer Spec')) {
                if (rootItem == null) {
                    rootItem = ql.vlocity_cmt__RootItemId__c;
                } else if (!rootItem.equals(ql.vlocity_cmt__RootItemId__c)) {
                    outMap.put('Success', 'false');
                    outMap.put('ITDaaSErrorMessage',System.label.ITDaaSTwoBundleExist);
                    outMap.put('FailureMethod', 'ITDaaSValidationFails');
                    return;
                }
            }
            //Check if we have ITDaaS products in cart and the opportunity is not synced with AutoTask
            else if ((ql.TeliaSE_Product_Code__c.equals('ITDAAS_START') || ql.TeliaSE_Product_Code__c.equals('ITDAAS')) && ql.MC_Line_Status__c != null && ql.MC_Line_Status__c != 'Active' && (ql.Quote.Opportunity.MC_ITDaaS_Info__c == null || ql.quote.MC_Sync_Autotask__c == false)){
                outMap.put('Success', 'false');
                outMap.put('ITDaaSErrorMessage',System.label.ITDaaSProductExist);
                outMap.put('FailureMethod', 'ITDaaSValidationFails');
                return;
            }
            //Check if we have ITSupport products in cart and the opportunity is not synced with AutoTask
            else if ((ql.TeliaSE_Product_Code__c.equals('ITP_OFFER') || ql.TeliaSE_Product_Code__c.equals('ITS_OFFER')) && ql.MC_Line_Status__c != null && ql.MC_Line_Status__c != 'Active' && ql.quote.MC_Sync_Autotask__c == false){
                outMap.put('Success', 'false');
                outMap.put('ITDaaSErrorMessage',System.label.ITSupportProductExist);
                outMap.put('FailureMethod', 'ITDaaSValidationFails');
                return;
            }
        }
    }    
}