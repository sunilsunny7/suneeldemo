global without Sharing class TeliaSE_Offerhelper implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try{
            if (methodName.equals(SEUtility.INCLUDED)){//called from QuoteDocument(Document/QuoteDocument) OS
                getIncludedOffers(inputMap,outMap);
            }
            if (methodName.equals('commercialTermsChangeCheck')){// Called from Final Configuration(MassCustomized/Approval) OS
                // IsDefaultValueChanged(inputMap,outMap); //old method commented after optimization
                commercialTermsChangeCheck(inputMap,outMap);
            }
            else if (methodName.equals(SEUtility.SELECTED)){//called from QuoteDocument(Document/QuoteDocument) OS
                putSelectedOffers(inputMap,outMap);
            } 
            else if(methodname.equals('Approval')){
                approval(inputMap,outMap);
            }
            else if(methodname.equals('FiberApproval')){
                fiberApproval(inputMap,outMap);
            }
            else if(methodname.equals('ReCalculate')){
                recalculate(inputMap,outMap);
            }/*
//LTAART-328: Commented this Method as we are now creating Simplified Line Items from MC_OfferDocHelper Class
else if (methodname.equals('SimplifiedItems')){//called from QuoteDocument(Document/QuoteDocument) OS
simplifiedQuoteLines(inputMap,outMap);
}*/
            else if(methodname.equals('isRecordLocked')){// Called from Final Configuration(MassCustomized/Approval) OS
                isRecordLocked(inputMap,outMap);
            }
            else if(methodname.equals('getCampaignDetails')){// Called from Final Configuration(MassCustomized/Approval) OS
                getCampaignDetails(inputMap,outMap);
            }
            else if(methodname.equals('updateOpportunityProducts')){// Called from Final Configuration(MassCustomized/Approval) OS
                //updateOpportunityProducts(inputMap,outMap); //Commented as OppSync functionality has been disabled from AM side
            }
            else if(methodname.equals('validateOfferData')){// Called from Final Configuration(MassCustomized/Approval) OS
                //validateOfferData(inputMap,outMap); //Commented as OppSync functionality has been disabled from AM side
            }  //getOppoSync  
            else if(methodname.equals('getOppoSyncProdDetails')){// Called from Final Configuration(MassCustomized/Approval) OS
                //getOppoSyncProdDetails(inputMap,outMap); //Commented as OppSync functionality has been disabled from AM side
            }
            else if(methodname.equals('discount')){
                discount(inputMap,outMap);
            }
            else if(methodname.equals('WithdrawQuote')){
                WithdrawQuote(inputMap,outMap);  
            }
            else if(methodname.equals('updateRootApprovalFlag')){
                updateQuoteLineBundle(inputMap,outMap);                
            }
            else if(methodname.equals('getProductsList')){
                getProductsList(inputMap,outMap,options);                
            }
            else{
                result = false;
            }
        }
        catch(Exception e){
            System.debug('OfferHelper Exception: '+e + e.getStackTraceString());
            outMap.put(methodName+' Exception: ',e.getMessage() + e.getStackTraceString());
            result = false;
        }
        return result;
    }
    
    private void discount(Map<String, Object> inputMap, Map<String, Object> outMap)
    {
        String quoteId=(String)inputMap.get('ContextId');
        
        Boolean discountFlag=false;
        Decimal SalesRepEbitMaxMandate = FiberDiscountMandate__c.getAll().get('SalesRep').EBIT_Max_Mandate__c;
        Decimal SalesRepProductDiscountMaxMandate = FiberDiscountMandate__c.getAll().get('SalesRep').ProductDiscountMaxMandate__c;
        Decimal maxProductLineItemDiscount = SalesRepProductDiscountMaxMandate;
        for(QuoteLineItem item:[select id ,TeliaSE_fiber_Rabatt__c, Fiber_Customer_Requested_Price__c, Fiber_Approved_Price__c from QuoteLineItem where quoteId=:quoteId and TeliaSE_fiber_Rabatt__c !=null])
        {
            if(item.TeliaSE_fiber_Rabatt__c!=null  && item.TeliaSE_fiber_Rabatt__c > SalesRepProductDiscountMaxMandate)
            {
                if (item.Fiber_Approved_Price__c!=null && item.Fiber_Customer_Requested_Price__c >= item.Fiber_Approved_Price__c)
                {
                    //maxProductLineItemDiscount=item.TeliaSE_fiber_Rabatt__c;
                    //Added as part SALEF-8109
                }else{
                    maxProductLineItemDiscount=item.TeliaSE_fiber_Rabatt__c;
                    break;
                }
            }
        }
        Quote  quote=[select TeliaSE_Fiber_EBIT_Percentage__c from Quote where id=:quoteId];
        if(quote.TeliaSE_Fiber_EBIT_Percentage__c > SalesRepEbitMaxMandate && maxProductLineItemDiscount <= SalesRepProductDiscountMaxMandate)
        {
            discountFlag=true;
        }
        outMap.put('discountFlag',discountFlag);
        outMap.put('isFiberFlow',true);
    }
    @TestVisible
    private void WithdrawQuote(Map<String,Object> inputMap,Map<String,Object> outMap)
    {
        Id quoteId=(Id)inputMap.get('ContextId');
        Approval.unlock(quoteId,false);
        Quote q1 = new Quote();
        q1.TeliaSE_Locked__c=false;
        q1.status='Draft';
        q1.id =quoteId;
        update q1;
    }
    
    private void getCampaignDetails(Map<String, Object> inputMap, Map<String, Object> outMap){
        try{
            List<Object> qliList = new List<Object>();
            if(inputMap.get('CampaignQLIs') != null && inputMap.get('CampaignQLIs') != ''){
                qliList = (List<Object>)inputMap.get('CampaignQLIs');
            }
            Integer countApprovedCampaign = 0;
            //approvalCount = (Integer)inputMap.get('ApprovalCount');
            Set<String> campaignRootQLISet = new Set<String>();
            if(qliList.size()>0){
                String campaignString='';
                Map<String,Object> commercialTerms = new Map<String,Object>();
                for(Object qli : qliList){
                    Map<String, Object> qliMap = (Map<String, Object>)qli;
                    campaignString += qliMap.get('ProductName')+' : '+qliMap.get('CampaignName')+'</br>';
                    //MCSTO-7265
                    if(qliMap.containsKey('CommercialTerms')){
                        commercialTerms = (Map<String,Object>)qliMap.get('CommercialTerms');
                        if(commercialTerms.containsKey('campaignExist')){ //already approved camgpaign qli
                            countApprovedCampaign ++;
                        }else{
                            campaignRootQLISet.add((String)qliMap.get('RootItemId'));
                        }  
                    }else{
                        campaignRootQLISet.add((String)qliMap.get('RootItemId'));
                    }             
                }
                if(countApprovedCampaign != qliList.size()){ //if there are any unapproved campaign qlis                
                    outMap.put('CampaignDetails',campaignString);
                    outMap.put('CampaignApprovalCount',qliList.size());
                    outMap.put('CampaignRootItemsSet',campaignRootQLISet);
                }
            }
            else{
                outMap.put('CampaignResponse','No campaigns');
            }
        }catch(Exception e){
            system.debug('Exception : '+e.getStackTraceString());
        } 
    }
    
    //isRecordLocked
    private void isRecordLocked(Map<String, Object> inputMap, Map<String, Object> outMap){
        try{
            String quoteId = String.valueOf(inputMap.get('ContextId'));
            if(quoteId != null){
                Id id = Id.valueOf(quoteId);
                Boolean status = Approval.isLocked(quoteId);
                outMap.put('isLocked', status);
            }else{
                outMap.put('isLocked', false);
            }
        }catch(Exception e){
            outMap.put('isLocked', false);
            system.debug('Exception : '+e.getStackTraceString());
        }
    }
    
    private void commercialTermsChangeCheck(Map<String, Object> inputMap, Map<String, Object> outMap){
        try{
            Boolean commercialTermsIsChanged = false;
            Map<String,Object> quoteMap = (Map<String,Object>)inputMap.get('Quote');
            List<Object> qliList = new List<Object>();
            if(inputMap.get('CommercialTermsQLIs') != null && inputMap.get('CommercialTermsQLIs') != ''){
                qliList = (List<Object>)inputMap.get('CommercialTermsQLIs');
            }
            
            Map<String,Object> commercialTerms = new Map<String,Object>();
            Map<String,Object> commercialTermsQli = new Map<String,Object>();
            if(quoteMap.containsKey('CommericalTerms')){
                commercialTerms = (Map<String,Object>)quoteMap.get('CommericalTerms');
            }
            Map<String,MC_CommercialNegotiation__c> commSettingMap = MC_CommercialNegotiation__c.getAll();
            if(quoteMap != null){
                if(Integer.valueOf(commSettingMap.get('Payment Terms').Default_Value__c) != Integer.valueOf(inputMap.get('PaymentTerms')) && commSettingMap.get('Payment Terms').Approval_Required__c == true && (commercialTerms.isEmpty() || (!commercialTerms.isEmpty() && commercialTerms.containsKey('Payment Terms') && Integer.valueOf(inputMap.get('PaymentTerms')) > Integer.valueOf(commercialTerms.get('Payment Terms'))))){
                    commercialTermsIsChanged = true;
                }else if(commSettingMap.get('Invoice Fee').Default_Value__c != inputMap.get('InvoiceFee') && commSettingMap.get('Invoice Fee').Approval_Required__c == true && (commercialTerms.isEmpty() || (!commercialTerms.isEmpty() && commercialTerms.containsKey('Invoice Fee') && inputMap.get('InvoiceFee') != commercialTerms.get('Invoice Fee')))){
                    commercialTermsIsChanged = true;
                }else if(commSettingMap.get('Benchmarking Agreements').Default_Value__c != inputMap.get('Benchmark') && commSettingMap.get('Benchmarking Agreements').Approval_Required__c == true && (commercialTerms.isEmpty() || (!commercialTerms.isEmpty() && commercialTerms.containsKey('Benchmarking Agreements') && inputMap.get('Benchmark') != commercialTerms.get('Benchmarking Agreements')))){
                    commercialTermsIsChanged = true;
                }else if(commSettingMap.get('IndexationClause').Default_Value__c != inputMap.get('IndexationClause') && commSettingMap.get('IndexationClause').Approval_Required__c == true && (commercialTerms.isEmpty() || (!commercialTerms.isEmpty() && commercialTerms.containsKey('IndexationClause') && inputMap.get('IndexationClause') != commercialTerms.get('IndexationClause')))){
                    commercialTermsIsChanged = true;
                }
            }  
            
            if(qliList.size()>0){
                Set<String> rootItemsSet = new Set<String>();
                for(Object qli : qliList){
                    Map<String, Object> qliMap = (Map<String, Object>)qli;
                    if(qliMap.containsKey('CommercialTerms')){
                        commercialTermsQli = (Map<String,Object>)qliMap.get('CommercialTerms');
                    }
                    if(qliMap.get('ObjectType') == 'Mobile Offer Specification' || qliMap.get('ObjectType') == 'Touch Point Offer Spec'|| qliMap.get('ObjectType') =='Smart Connect Offer Spec' || qliMap.get('ObjectType') =='Operator Connect Offer Spec' ){                  
                        if(commSettingMap.get('TimeToReachBaseLevel').Default_Value__c != qliMap.get('QuarantineTime') && commSettingMap.get('TimeToReachBaseLevel').Approval_Required__c == true && (commercialTermsQli.isEmpty() || (!commercialTermsQli.isEmpty() && commercialTermsQli.containsKey('TimeToReachBaseLevel') && qliMap.get('QuarantineTime') != commercialTermsQli.get('TimeToReachBaseLevel')))){
                            commercialTermsIsChanged = true;                            
                        }
                        if(commSettingMap.get('MinimumCommitment').Default_Value__c != qliMap.get('MinimumCommit') && commSettingMap.get('MinimumCommitment').Approval_Required__c == true && (commercialTermsQli.isEmpty() || (!commercialTermsQli.isEmpty() && commercialTermsQli.containsKey('MinimumCommitment') && qliMap.get('MinimumCommit') != commercialTermsQli.get('MinimumCommitment')))){
                            commercialTermsIsChanged = true;
                            rootItemsSet.add((String)qliMap.get('RootItemId'));
                        }
                    }
                    else if(qliMap.get('ObjectType') =='Broadband Start Offering Spec' ){
                        if(qliMap.containsKey('OCNDiscount') && Integer.valueOf(commSettingMap.get('OCNDiscount').Default_Value__c) !=  Integer.valueOf(qliMap.get('OCNDiscount')) && commSettingMap.get('OCNDiscount').Approval_Required__c == true  && (commercialTermsQli.isEmpty() || (!commercialTermsQli.isEmpty() && commercialTermsQli.containsKey('OCNDiscount') &&Integer.valueOf(qliMap.get('OCNDiscount')) > Integer.valueOf(commercialTermsQli.get('OCNDiscount'))))){
                            commercialTermsIsChanged = true;
                        }
                    }
                }
                outMap.put('commercialTermsRootsSet', rootItemsSet);
            }
            outMap.put('commercialTermsIsChanged', commercialTermsIsChanged);
        }catch(Exception e){
            outMap.put('Exception:', e.getMessage());
            outMap.put('ExceptionStackTrace:', e.getStackTraceString());  
        }
    }
    
    private void getIncludedOffers(Map<String, Object> inputMap, Map<String, Object> outMap)
    {     
        String OpportunityId=(String)inputMap.get('OpportunityId');
        Map<String,Map<String,String>> offerMap=new Map<String,Map<String,String>>();
        Id parentQuote=(String)inputMap.get('parentQuote');
        List<String> coOffers=new list<String>{'CO-BBPLUS','CO-BBPRO','CO-BBSTART','CO-DATANET'};
            List<String> b2bOffers = new list<String>{'B2B-DATANET','B2B-BBF','B2B-BBPRO'};
                List<QuoteLineItem> faQliList = [SELECT Id,TeliaSE_Product_Code__c 
                                                 from QuoteLineItem 
                                                 where QuoteId =: parentQuote 
                                                 AND (TeliaSE_Product_Code__c In:b2bOffers OR TeliaSE_Product_Code__c In:coOffers) ];
        String orderType = 'B2B';
        if(faQliList.size()>0){
            for(QuoteLineItem qli: faQliList){
                if(b2bOffers.contains(qli.TeliaSE_Product_Code__c)){
                    orderType = 'B2B';
                    break;
                }
                else if(coOffers.contains(qli.TeliaSE_Product_Code__c)){
                    orderType = 'CO';
                    break;
                }
                
            } 
        }
        else if(System.Label.B2BSolution_Toggle == 'true'){
            orderType = 'B2B';
        }else{
            orderType = 'CO';
        }
        
        offerMap.put('Jobbmobil',putvalue('Jobbmobil'));
        offerMap.put('Microsoft 365',putvalue('Microsoft 365'));
        offerMap.put('TouchPoint',putvalue('TouchPoint'));
        offerMap.put('Smart Säkerhet',putvalue('Smart Säkerhet'));
        offerMap.put('Försäkring',putvalue('Försäkring'));
        //offerMap.put('Personlig Tekniker',putvalue('Personlig Tekniker'));
        offerMap.put('Slutanvändarsupport',putvalue('Slutanvändarsupport'));
        offerMap.put('IT-avdelning   ',putvalue('IT-avdelning   ')); //Added space for LTAT-20584
        offerMap.put('IT-avdelning Start',putvalue('IT-avdelning Start'));
        offerMap.put('IT-support Standard',putvalue('IT-support Standard'));	
        offerMap.put('IT-support Plus',putvalue('IT-support Plus'));
        offerMap.put('Cloud VPN WIFI/LAN',putvalue('Cloud VPN WIFI/LAN'));
        offerMap.put('Cloud VPN SD-WAN/Firewall',putvalue('Cloud VPN SD-WAN/Firewall'));
        offerMap.put('TouchPoint Plus',putvalue('Touch Point Plus'));
        offerMap.put('Smart Connect',putvalue('Smart Connect'));
        offerMap.put('Operator Connect',putvalue('Operator Connect'));
        
        if(orderType != null && orderType == 'B2B' ) {
            offerMap.put('Datanet',putvalue('Datanet'));
            offerMap.put('Bredband Företag',putvalue('Bredband Företag'));
            offerMap.put('Bredband Pro Företag',putvalue('Bredband Pro Företag'));
        }else if(orderType != null && orderType == 'CO' ) {
            offerMap.put('Bredband Start',putvalue('Bredband Start'));
            offerMap.put('Bredband Pro',putvalue('Bredband Pro'));
            offerMap.put('Bredband Plus',putvalue('Bredband Plus'));
            offerMap.put('Datanet',putvalue('Datanet'));
        }
        String value='',quoteId = (String)inputMap.get('OfferQuoteId'),oldOfferQuoteId=(String)inputMap.get('OldOfferQuote');        
        Boolean oldQuoteFlag = (Boolean)inputMap.get('OfferQuoteExists') , FAQuoteFlagUpdated = (Boolean)inputMap.get('FAQuoteFlagUpdated');       
        if(FAQuoteFlagUpdated != null && FAQuoteFlagUpdated == true && oldOfferQuoteId != null) {
            if(quoteId == null) quoteId = oldOfferQuoteId;
        }
        Set<String> virtualItemIds = new Set<String>();
        
        if(quoteId == null || quoteId == ''){
            quoteId= (String)inputMap.get('ContextId');
        }
        
        //LTAT- : Logic to get included Offer from Simplified Line Items
        List<TeliaSE_SimplifiedQuoteLineItem__c> simplifiedList=[select id,name,TeliaSE_Parent_ItemId__c,ProductType__c,Product_Code__c,QuoteId__r.MC_Commercial_Setup__c FROM TeliaSE_SimplifiedQuoteLineItem__c where QuoteId__c =:quoteId and TeliaSE_Parent_ItemId__c = null];
        if(simplifiedList.size()>0){
            for(TeliaSE_SimplifiedQuoteLineItem__c slItem: simplifiedList)
            {	
                String itemName=(String)slItem.ProductType__c;
                String productCode = (String)slItem.Product_Code__c;
                String accountType = (String)slItem.QuoteId__r.MC_Commercial_Setup__c;
                //Broadband Datanet Offering Spec for Datanet
                if(itemName.equals('Mobile Offer Specification')){
                    if(!value.contains('Jobbmobil')){
                        value= value!=''?value+';Jobbmobil':value+'Jobbmobil ';
                        offerMap.remove('Jobbmobil');
                    }
                }
                else if(itemName.equals('Smart Offer Spec')){ 
                    if(!value.contains('Smart Säkerhet')){
                        value= value!=''?value+';Smart Säkerhet':value+'Smart Säkerhet';
                        offerMap.remove('Smart Säkerhet');
                    }
                }
                else if(itemName.equals('Touch Point Offer Spec')){
                    if(!value.contains('TouchPoint')){
                        value= value!=''?value+';TouchPoint':value+'TouchPoint';
                        offerMap.remove('TouchPoint');
                    }
                }
                else if(itemName.equals('Personal Technician Offer Specification')){
                    if(!value.contains('Personlig')){
                        value= value!=''?value+';Personlig Tekniker':value+'Personlig Tekniker';
                        offerMap.remove('Personlig Tekniker');
                    }
                }
                else if(itemName.equals('Insurance Offer Spec')){
                    if(!value.contains('Försäkring')){
                        value= value!=''?value+';Försäkring Mobiltelefon':value+'Försäkring Mobiltelefon';
                        offerMap.remove('Försäkring');
                    }
                }
                else if(itemName.equals('ICT Offer Specification')){
                    if(!value.contains('Slutanvändarsupport')){
                        value= value!=''?value+';Slutanvändarsupport':value+'Slutanvändarsupport';
                        offerMap.remove('Slutanvändarsupport');
                    }
                }
                else if(itemName.equals('ITDaaS Offer Spec')){
                    if(!value.contains('IT-avdelning Start') && ProductCode.contains('ITDAAS_START')){	
                        value= value!=''? value+';IT-avdelning Start' :value+'IT-avdelning Start';	
                        offerMap.remove('IT-avdelning Start');
                    } 	 
                    else if(!value.contains('IT-support Standard') && ProductCode.contains('ITS')){	
                        value= value!=''? value+';IT-support Standard' :value+'IT-support Standard';	
                        offerMap.remove('IT-support Standard');  	
                    }	
                    else if(!value.contains('IT-support Plus') && ProductCode.contains('ITP')){	
                        value= value!=''? value+';IT-support Plus' :value+'IT-support Plus';	
                        offerMap.remove('IT-support Plus');    	
                    }                
                    else if(!value.contains('IT-avdelning   ') && ProductCode.contains('ITDAAS') && (!value.contains('IT-avdelning Start'))){	
                        value= value!=''? value+';IT-avdelning   ' :value+'IT-avdelning   ';	
                        offerMap.remove('IT-avdelning   ');
                    }
                }    
                else if(itemName.equals('OFFICE365 Offer Spec')){
                    if(!value.contains('Microsoft 365')){
                        value= value!=''?value+';Microsoft 365':value+'Microsoft 365';
                        offerMap.remove('Microsoft 365');
                    }
                }
                else if(itemName.equals('WIFI/LAN Offering Spec')){
                    if(!value.contains('Cloud VPN WIFI/LAN')){
                        value= value!=''?value+';Cloud VPN WIFI/LAN':value+'Cloud VPN WIFI/LAN';                    
                        offerMap.remove('Cloud VPN WIFI/LAN');
                    }
                }
                else if(itemName.equals('SD-WAN/Firewall Offering Spec')){               
                    if(!value.contains('Cloud VPN SD-WAN/Firewall')){
                        value= value!=''?value+';Cloud VPN SD-WAN/Firewall':value+'Cloud VPN SD-WAN/Firewall';                    
                        offerMap.remove('Cloud VPN SD-WAN/Firewall');
                    }
                }
                else if(itemName.equals('Broadband Start Offering Spec')){            
                    if(!value.contains('Bredband Start')){
                        value= value!=''?value+';Bredband Start':value+'Bredband Start';
                        if(orderType == 'CO'){
                            offerMap.remove('Bredband Start');
                        }if(orderType == 'B2B'){
                            offerMap.remove('Bredband Företag');                       
                        }
                    }
                }
                else if(itemName.equals('Broadband Pro Offering Spec')){                
                    if(!value.contains('Bredband Pro')){
                        value= value!=''?value+';Bredband Pro':value+'Bredband Pro';
                        if(orderType == 'CO'){
                            offerMap.remove('Bredband Pro');
                        }if(orderType == 'B2B'){
                            offerMap.remove('Bredband Pro Företag');                        
                        }
                    }
                }
                else if(itemName.equals('Broadband Plus Offering Spec')){
                    if(!value.contains('Bredband Plus')){
                        value= value!=''?value+';Bredband Plus':value+'Bredband Plus';
                        offerMap.remove('Bredband Plus');
                    }
                }
                else if(itemName.equals('Broadband Datanet Offering Spec')){
                    if(!value.contains('Datanet')){
                        value= value!=''?value+';Datanet':value+'Datanet';
                        if(orderType == 'CO'){
                            offerMap.remove('Datanet');
                        }if(orderType == 'B2B'){
                            offerMap.remove('Datanet');                      
                        }
                    }
                }
                else if(itemName.equals('TouchPoint Plus Offer Spec')){
                    if(!value.contains('Touch Point Plus')){
                        value= value!=''?value+';Touch Point Plus':value+'Touch Point Plus';
                        offerMap.remove('TouchPoint Plus');
                    }
                }  
                else if(itemName.equals('Smart Connect Offer Spec')){
                    if(!value.contains('Smart Connect')){
                        value= value!=''?value+';Smart Connect':value+'Smart Connect';
                        offerMap.remove('Smart Connect');
                    }
                }
                else if(itemName.equals('Operator Connect Offer Spec')){
                    if(!value.contains('Operator Connect')){
                        value= value!=''?value+';Operator Connect':value+'Operator Connect';
                        offerMap.remove('Operator Connect');
                    }
                }
                if(accountType == 'Enterprise Large'|| accountType == 'Forced RA'){
                    offerMap.remove('IT-support Standard');  
                    offerMap.remove('IT-support Plus'); 
                    offerMap.remove('IT-avdelning Start');
                    offerMap.remove('IT-avdelning   ');
                    offerMap.remove('Smart Säkerhet');
                    
                }
                
            }
        }
        
        //-------------------------------------------------------------------------------------------------------
        Quote q1 = new Quote();
        q1.id = quoteId;
        q1.TeliaSE_Offer__c=value;
        update q1;
        
        outMap.put('products',offerMap.values());
        outMap.put('virtualItemIds',virtualItemIds);
    }
    private void getProductsList(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String,Object> options)
    {
        String accountType=(String)options.get('AccountType');
        if(accountType == 'Enterprise SME' || accountType == 'Forced BA')
        {
            String excludedProducts = System.Label.MC_ProductExcludeForLarge;        
            List<String> excludedProductsList = excludedProducts.split(',');
            String includedProducts = System.Label.MC_ProductsIncludeForLarge;        
            List<String> includedProductsList = includedProducts.split(',');
            excludedProductsList.addAll(includedProductsList);
            excludedProductsList.sort();  
            outMap.put('productList',excludedProductsList);
        }
        else if(accountType == 'Forced RA' || accountType == 'Enterprise Large')
        {
            String includedProducts = System.Label.MC_ProductsIncludeForLarge;        
            List<String> includedProductsList = includedProducts.split(',');
            includedProductsList.sort();  
            outMap.put('productList',includedProductsList);
        }
        
    }
    private void putSelectedOffers(Map<String, Object> inputMap, Map<String, Object> outMap){
        String quoteId;
        quoteId = (String)inputMap.get('OfferQuoteId');
        if(quoteId == null || quoteId == ''){
            quoteId = (String)inputMap.get('ContextId');
        }
        Quote quote=[select id,TeliaSE_Offer__c from Quote where id=:quoteId FOR UPDATE];
        String value=quote.TeliaSE_Offer__c;
        Map<String,Object> offer=(Map<String,Object>)inputMap.get('Offer');
        for(Object obj:(List<Object>)offer.get('Line')){
            Map<String,Object> data=(Map<String,Object>)obj;
            value=value!=null?value+';'+String.valueOf(data.get('Name')):String.valueOf(data.get('Name'));
        }
        quote.TeliaSE_Offer__c=value;
        update quote;
    }
    /*
//LTAART-328: Commented this Method as we are now creating Simplified Line Items from MC_OfferDocHelper Class
private void simplifiedQuoteLines(Map<String, Object> inputMap, Map<String, Object> outMap){

List<QuoteLineItem> finalList=new List<QuoteLineItem>();
String quoteId =(String)inputMap.get('OfferQuoteId') ,  OffType=''; 
if(quoteId == null || quoteId == ''){
quoteId = (String)inputMap.get('ContextId');
}
TeliaSE_SimplifiedQuoteLineItem__c simplifiedItem;

List<TeliaSE_SimplifiedQuoteLineItem__c> simplifiedItems=new List<TeliaSE_SimplifiedQuoteLineItem__c>();
//Map<Id,QuoteLineItem> lineItemMap=new Map<Id,QuoteLineItem>();
Map<String,Boolean> dupliateParents=new Map<String,Boolean>();
//List<QuoteLineItem> duplicateItems=new List<QuoteLineItem>();
//Set<Id> duplicateids=new Set<Id>(); //commented by Sanjoli for OP
List<Id> duplicateids= new List<Id>(); 
Set<Id> rootProductIdSet = new Set<Id>();
Map<String, List<QuoteLineItem>> qliRoot = new Map<String, List<QuoteLineItem>>();
// MCSTO- 6901 - Removing Calculation of OnetimeFee for ICT products.
List<MC_ExclusionInclusionList__c> excludeItemCalc = [Select Exclude__c,ObjectType__c from MC_ExclusionInclusionList__c where Scenario__c = 'OneTimeFeeNotCalculatedForSimplifiedLineItem' and Exclude__c = true];
List<String> excludedObjectTypes = new List<String>();
if(excludeItemCalc!= null && excludeItemCalc.size()>0){
for(MC_ExclusionInclusionList__c excluded:excludeItemCalc){
excludedObjectTypes.add(excluded.ObjectType__c);
}
}

List<String> excludedObjectTypes = new List<String>();
//for(MC_ExclusionInclusionList__c excluded: (List<MC_ExclusionInclusionList__c>)((Map<String, MC_ExclusionInclusionList__c>)MC_ExclusionInclusionList__c.getAll()).values()){
MC_ExclusionInclusionList__c excluded= MC_ExclusionInclusionList__c.getAll().get('RemoveOneTimePricingForICT');
if(excluded != null && excluded.Scenario__c == 'OneTimeFeeNotCalculatedForSimplifiedLineItem' && excluded.Exclude__c)
excludedObjectTypes.add(excluded.ObjectType__c);
//Adding for Office 365 EPIC (MCSTO-11111)
Map<String,MC_OfferCreation_ObjSplit__c> objTypes = MC_OfferCreation_ObjSplit__c.getAll(); 

List<TeliaSE_SimplifiedQuoteLineItem__c> oldItems=[select id from TeliaSE_SimplifiedQuoteLineItem__c where quoteId__c=:quoteId];
if(oldItems.size()>0){
delete oldItems;
}
List<QuoteLineItem> quoteLineItems=[select id,vlocity_cmt__QuoteMemberId__c,TeliaSE_Base_Quantity__c,TeliaSE_ParentClusterCode__c,MC_Initial_Order_Quantity__c,TeliaSE_Offer_Type__c,vlocity_cmt__QuoteGroupId__c,TeliaSE_Product_Object_Type__c,MC_TeliaExcludeQuoteItem__c,vlocity_cmt__OneTimeCharge__c,TeliaSE_MC_Campaign_Id__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__ParentItemId__c,quoteid,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.name,vlocity_cmt__ProductHierarchyPath__c,TeliaSE_Root_Product__c,vlocity_cmt__EffectiveQuantity__c,TeliaSE_MC_Binding_Time__c,Subscription__c,vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c,vlocity_cmt__SequenceNumber__c,MC_HeraType__c,MC_HeraReferenceNumber__c from QuoteLineItem where quoteId=:quoteId]; //added by Arup for sorting
//24:08:2021 MobilePortfolio: Removing virtual cluster level products
List<Object> virtualItemIds = new List<Object>();
virtualItemIds = (List<Object>)inputMap.get('virtualItemIds');
for(QuoteLineItem qli:quoteLineItems){
if(qli.vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c == 'Virtual Offer Products'){
virtualItemIds.add(qli.id);
}
}
Set<String> coOfferingtypes = new Set<String>{'Broadband Start Offering Spec','Broadband Pro Offering Spec','Broadband Plus Offering Spec','Broadband Datanet Offering Spec','SD-WAN/Firewall Offering Spec','WIFI/LAN Offering Spec','Connected Office Offer Spec'};         
for(QuoteLineItem  item:quoteLineItems){
OffType = (String)item.TeliaSE_Product_Object_Type__c;
//rootProductIdSet.add(item.TeliaSE_Root_Product__c);
//if((OffType != 'Broadband Start Offering Spec' && OffType != 'Broadband Pro Offering Spec' && OffType != 'Broadband Plus Offering Spec' && OffType != 'Broadband Datanet Offering Spec' && OffType != 'SD-WAN/Firewall Offering Spec' && OffType != 'WIFI/LAN Offering Spec' && OffType != 'Connected Office Offer Spec' )){
if(!coOfferingtypes.contains(offtype)){ 

if(!qliRoot.containsKey(item.TeliaSE_Root_Product__c)){
qliRoot.put(item.TeliaSE_Root_Product__c, new List<QuoteLineItem>{item});
}else{
//qliRoot.put(item.TeliaSE_Root_Product__c, (List<QuoteLineItem>)
qliRoot.get(item.TeliaSE_Root_Product__c).add(item);
}
rootProductIdSet.add(item.TeliaSE_Root_Product__c);
String duplicateParentKey = objTypes.containsKey(OffType) ?  (String)item.TeliaSE_Root_Product__c + (String)item.get(objTypes.get(OffType).fieldsToAdd__c) : (String)item.TeliaSE_Root_Product__c;
if(item.vlocity_cmt__ParentItemId__c == null){
if(dupliateParents.get(duplicateParentKey) == null){  
dupliateParents.put(duplicateParentKey,true);
}
else
duplicateids.add(item.TeliaSE_Root_Product__c);
}
}
}
if(duplicateids.size()>0){
List<QuoteLineItem> itemList;
Map<Id,List<QuoteLineItem>> itemMap=new Map<Id,List<QuoteLineItem>>();
Map<Id,QuoteLineItem> dupliateEliminationMap=new Map<Id,QuoteLineItem>();
for(Id id:duplicateids){
itemList=new List<QuoteLineItem>();
for(QuoteLineItem item:quoteLineItems){
if(item.TeliaSE_Root_Product__c == id){
itemList.add(item);
}
} //commented by Sanjoli for OP
itemMap.put(id,qliRoot.get(id)); 
}
for(List<QuoteLineItem> items: itemMap.values()){
for(QuoteLineItem item:items){
if(dupliateEliminationMap.get(item.vlocity_cmt__Product2Id__c) == null){
dupliateEliminationMap.put(item.vlocity_cmt__Product2Id__c,item);
}
else{
dupliateEliminationMap.get(item.vlocity_cmt__Product2Id__c).vlocity_cmt__EffectiveQuantity__c=dupliateEliminationMap.get(item.vlocity_cmt__Product2Id__c).vlocity_cmt__EffectiveQuantity__c + item.vlocity_cmt__EffectiveQuantity__c;
}                    
}
finalList.addAll(dupliateEliminationMap.values());
dupliateEliminationMap.clear();
}
//commented by Sanjoli for OP List<QuoteLineItem> originalItems=[select id,vlocity_cmt__QuoteMemberId__c,TeliaSE_Base_Quantity__c,MC_Initial_Order_Quantity__c,TeliaSE_Offer_Type__c,vlocity_cmt__QuoteGroupId__c,TeliaSE_Product_Object_Type__c,MC_TeliaExcludeQuoteItem__c,vlocity_cmt__OneTimeCharge__c,TeliaSE_MC_Campaign_Id__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__ParentItemId__c,quoteid,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.name,vlocity_cmt__ProductHierarchyPath__c,TeliaSE_Root_Product__c,vlocity_cmt__EffectiveQuantity__c,TeliaSE_MC_Binding_Time__c,Subscription__c,vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c,vlocity_cmt__SequenceNumber__c from QuoteLineItem where TeliaSE_Root_Product__c !=:duplicateids and quoteId=:quoteId]; //added by Arup for Sortin        
List<QuoteLineItem> originalItems = new List<QuoteLineItem>();
for (id rootId : rootProductIdSet){
if(!duplicateids.contains(rootId)){
originalItems.addAll(qliRoot.get(rootId));
}
}
finalList.addAll(originalItems);
}
else{            
finalList.addAll(quoteLineItems);
}      
for(QuoteLineItem item:finalList){
simplifiedItem=new TeliaSE_SimplifiedQuoteLineItem__c();
simplifiedItem.Product__c=item.vlocity_cmt__Product2Id__c;
simplifiedItem.QuoteId__c=item.QuoteId;
simplifiedItem.MC_Sequence_Number__c = item.vlocity_cmt__SequenceNumber__c; // added by Arup for Sorting
//simplifiedItem.QuoteLineItemId__c = item.id;
simplifiedItem.Quote_Member__c=item.vlocity_cmt__QuoteMemberId__c;
simplifiedItem.TeliaSE_BaseQuantity__c = item.TeliaSE_Base_Quantity__c;
simplifiedItem.Quote_Group__c=item.vlocity_cmt__QuoteGroupId__c;            
simplifiedItem.TeliaSE_MC_Campaign_Id__c = item.TeliaSE_MC_Campaign_Id__c;           
simplifiedItem.TeliaSE_Offer_Type__c = item.TeliaSE_Offer_Type__c;
//LTAT-6041 - Quote Generation process
simplifiedItem.MC_HeraReferenceNumber__c = item.MC_HeraReferenceNumber__c;
simplifiedItem.MC_HeraType__c = item.MC_HeraType__c;
//simplifiedItem.TeliaSE_List_Price__c=item.vlocity_cmt__RecurringCharge__c;
simplifiedItem.TeliaSE_OnetimeCharge__c=excludedObjectTypes.contains(item.vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c) ? item.vlocity_cmt__OneTimeCharge__c / item.vlocity_cmt__EffectiveQuantity__c : Math.roundToLong(item.vlocity_cmt__OneTimeCharge__c);
simplifiedItem.TeliaSE_List_Price__c= excludedObjectTypes.contains(item.vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c) ? item.vlocity_cmt__RecurringCharge__c: Math.roundToLong(item.vlocity_cmt__RecurringCharge__c);
//simplifiedItem.TeliaSE_OnetimeCharge__c= Math.roundToLong(item.vlocity_cmt__OneTimeCharge__c);
simplifiedItem.TeliaSE_Aggregated_Quantity__c=item.vlocity_cmt__EffectiveQuantity__c;
simplifiedItem.MC_Initial_Order_Quantity__c =item.MC_Initial_Order_Quantity__c; // Added for defect 9475
simplifiedItem.TeliaSE_Product_Hierarchy__c=item.vlocity_cmt__ProductHierarchyPath__c;
simplifiedItem.TeliaSE_Root_Product__c=item.TeliaSE_Root_Product__c;
simplifiedItem.TeliaSE_MC_Binding_Time__c=item.TeliaSE_MC_Binding_Time__c;
simplifiedItem.Subscription__c=item.Subscription__c;
simplifiedItem.MC_TeliaExcludeQuoteItem__c=item.MC_TeliaExcludeQuoteItem__c;
//24:08:2021 - mobile portfolio: removing parentId reference of virtual cluster products.
simplifiedItem.TeliaSE_Parent_ItemId__c= virtualItemIds.contains(item.vlocity_cmt__ParentItemId__c) ? null:item.vlocity_cmt__ParentItemId__c; 
simplifiedItems.add(simplifiedItem);
}
if(simplifiedItems.size()>0){
insert simplifiedItems;
}

}
*/
    private void recalculate(Map<String, Object> inputMap, Map<String, Object> outMap)
    {
        String quoteId=(String)inputMap.get('ContextId');
        List<QuoteLineItem> items=new List<QuoteLineItem>();
        for(QuoteLineItem  item:[select id,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_Floor_Price__c,TeliaSE_Flag__c from QuoteLineItem where TeliaSE_MC_Customer_Requested_Price__c != null and quoteId=:quoteId]){
            if(item.TeliaSE_Floor_Price__c > item.TeliaSE_MC_Customer_Requested_Price__c){
                item.TeliaSE_Flag__c=System.Label.TeliaSE_SadFace;
                items.add(item);
            }
            else if(item.TeliaSE_Floor_Price__c < item.TeliaSE_MC_Customer_Requested_Price__c){
                item.TeliaSE_Flag__c=System.Label.TeliaSE_HappyFace;
                items.add(item);
            }
        }
        if(items.size() > 0){
            update items;
        }
    }
    
    private void approval(Map<String, Object> inputMap, Map<String, Object> outMap){ 
        try{
            Map<String,Object> approvalData;
            Map<String,Object> approvalData2;
            String quoteId='',approvalData3,approvalData4, comments='', emailcomments='',Fieldcomments='',productname,productAddOnComments='',productCode,fieldname,filler;
            //String baseUrl= URL.getSalesforceBaseUrl().toExternalForm();
            
            String type=(String)inputMap.get('RenegotiationIdentifier');
            map<String,Object> prodMap = new Map<String,Object>();
            prodMap.put('quote',inputMap.get('quote'));
            prodMap.put('QLI',inputMap.get('QLI'));
            String lwcProdString = json.serialize(prodMap);
            if(type == null)
            {            
                quoteId= (String)inputMap.get('ContextId'); 
                Quote q1 = [Select id,TeliaSE_MC_ApprovalFileLink__c from Quote where id=:quoteId];
                // Fetching the data from Omniscript element 'FinalComment' which has combined comment and file link
                approvalData4=(String)inputMap.get('FinalComment');
                q1.TeliaSE_MC_ApprovalFileLink__c  = '#N/A';
                //String contentId =(String)inputMap.get('ContentDocumentId');
                String fileExist = (String)inputMap.get('fileExist');
                List<ContentDocumentLink> contentLinkList = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId=:quoteId];
                if(contentLinkList != null && contentLinkList.size() > 0)
                {
                    approvalData3= approvalData4+'.'+'\n';
                    //+'FileAttachment:'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+contentId;//Kommentarer
                    //  +'Bilaga: '+System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/'+quoteId+'/related/CombinedAttachments/view';
                    q1.TeliaSE_MC_ApprovalFileLink__c =System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/'+quoteId+'/related/CombinedAttachments/view';
                }
                update q1;
                
                comments = ' Comments: ';
                if(approvalData3 != null) {
                    comments = approvalData3;
                    emailcomments= 'Kommentarer: ' + approvalData3;
                } 
                else { 
                    comments = approvalData4;
                    emailcomments= 'Kommentarer: ' + approvalData4;
                }
                outMap.put('FinalComment',comments);
            }
            else{
                quoteId=(String)inputMap.get('options')!=null?(String)inputMap.get('options'):(String)inputMap.get('DRId_Quote');
                approvalData3=(String)inputMap.get('FinalComment');
                productname=(String)inputMap.get('ProductName');
                
                if(approvalData3 != null)
                {
                    //comments= approvalData3;
                    //outMap.put('FinalComment', productname+', Comments: '+comments);
                    comments= approvalData3;
                }
                if(approvalData3 != null && productname!=null)
                {
                    //comments= approvalData3;
                    //outMap.put('FinalComment', productname+', Comments: '+comments);
                    comments= productname +', Comments: '+ approvalData3;
                }
                approvalData=(Map<String,Object>)inputMap.get('Approval1');
                if(approvalData != null)
                {
                    if(approvalData.get('Comment1') != null)                
                    {
                        comments=(String)approvalData.get('Comment1');
                    }
                }
                approvalData=(Map<String,Object>)inputMap.get('Approval2');
                if(approvalData != null)
                {
                    if(approvalData.get('Comment2') != null)
                    {
                        comments=(String)approvalData.get('Comment2');
                    }
                }
            }
            
            List<Id> ids=new List<Id>();
            /*FIBER START*/
            Boolean fiberFlag=false;
            Quote quote=[select TeliaSE_Record_Type_Name__c,TeliaSE_Comments__c,RecordType.name,owner.id from Quote where id=:quoteId];
            
            if(quote != null){
                ids.add(quote.id);
            }
            
            if( quote.TeliaSE_Record_Type_Name__c == 'Individual_Quote' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote_of_FA' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote' )
            { 
                approvalData=(Map<String,Object>)inputMap.get('Approval1');
                if(approvalData.get('Comment1') != null)
                {
                    comments=(String)approvalData.get('Comment1');
                }
                quote.TeliaSE_Comments__c= comments;
            }else{
                quote.TeliaSE_Comments__c=emailcomments;
            }
            /*FIBER END*/
            
            Integer fieldLength = Schema.SObjectType.Quote.fields.Product_Details__c.getLength();
            if(lwcProdString.length()<=fieldLength){
                quote.Product_Details__c =lwcProdString; // made change by VamsiD update for LWC scripts
            }
            if(type != null){
                quote.TeliaSE_RenegotiationApproval__c =true;
            }
            if(type != null){
                quote.TeliaSE_RenegotiationApproval__c =true;
                quote.TeliaSE_isPrematureRenegotiationApprov__c = true;
                quote.TeliaSE_Comments__c = 'Kommentarer: ' + System.Label.Renegotiation_Approval_Comment + '\n' + comments;
                comments = System.Label.Renegotiation_Approval_Comment + '\n' + comments;
            }
            update quote;
            string newComments= 'Kommentarer: '+comments;
            invokeApprovalProcess(quoteId,newComments,ids);
            
            outMap.put('options','Done');
        }
        catch(Exception e){
            outMap.put('options','Error');
            system.debug('Exception : '+e.getStackTraceString());
        }     
    }
    
    // fiber approval
    private void fiberApproval(Map<String, Object> inputMap, Map<String, Object> outMap){
        
        String quoteId='';
        Map<String,Object> approvalData;
        Map<String,Object> approvalData1;
        Map<String,Object> approvalData2;
        String comments;
        String type=(String)inputMap.get('RenegotiationIdentifier');
        
        if(type == null)
        {
            quoteId= (String)inputMap.get('ContextId'); 
            approvalData=(Map<String,Object>)inputMap.get('Approval');
            if(approvalData != null)
                comments=(String)approvalData.get('Comment');
        }else 
        {
            quoteId=(String)inputMap.get('options')!=null?(String)inputMap.get('options'):(String)inputMap.get('DRId_Quote');
            approvalData=(Map<String,Object>)inputMap.get('Approval');
            if(approvalData != null)
            {
                if(approvalData.get('Comment') != null)
                {
                    comments=(String)approvalData.get('Comment');
                }
            }
            approvalData=(Map<String,Object>)inputMap.get('Approval1');
            if(approvalData != null)
            {
                
                if(approvalData.get('Comment1') != null)
                {
                    comments=(String)approvalData.get('Comment1');
                }
                
            }
            approvalData=(Map<String,Object>)inputMap.get('Approval2');
            if(approvalData != null)
            {
                if(approvalData.get('Comment2') != null)
                {
                    comments=(String)approvalData.get('Comment2');
                }
                
            }
        }
        
        List<Id> ids=new List<Id>();
        Boolean fiberFlag=false;
        Quote quote=[select TeliaSE_Record_Type_Name__c,TeliaSE_Comments__c,RecordType.name from Quote where id=:quoteId];
        if( quote.TeliaSE_Record_Type_Name__c == 'Individual_Quote' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote_of_FA' || quote.TeliaSE_Record_Type_Name__c == 'TeliaSE_Fiber_CA_Quote' )
        {
            approvalData=(Map<String,Object>)inputMap.get('Approval1');
            if(approvalData.get('Comment1') != null)
            {
                comments=(String)approvalData.get('Comment1');
            }
            
        }
        quote.TeliaSE_Comments__c=comments;
        if(type != null){
            quote.TeliaSE_RenegotiationApproval__c =true;
        }
        
        try
        {
            update quote;
            invokeApprovalProcess(quoteId,comments,ids);
            outMap.put('options','Done');
        }
        catch(Exception e)
        {
            outMap.put('options','Error');
            
        }     
    }    
    
    //Identifies whether the object is a collection or not
    //Returns boolean based on the object passed
    @TestVisible
    private static Boolean isItObject(Object obj){
        Boolean isObject = true;
        try{
            if(JSON.serialize(obj).startsWith('[')){
                isObject = false;
            }else{
                isObject = true;
            }
            return isObject;
        }catch(Exception ex){
            return isObject;
        }
    }
    
    //@future
    private static void invokeApprovalProcess(String quoteId,String comments,List<Id> ids){
        try{
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments(comments);
            req.setObjectId(quoteId);
            req.setNextApproverIds(ids);
            
            Approval.ProcessResult result = Approval.process(req);
        }catch(Exception e){
            System.debug('Error in Approval Process: '+e.getMessage());
        }
    }
    
    private Map<String,String> putvalue(String value){
        Map<String,String> valueMap=new Map<String,String>();
        valueMap.put('name', value);
        return valueMap;       
    }
    
    //Commented below method as OppSync functionality has been disabled from AM side
    /* private void updateOpportunityProducts(Map<String, Object> inputMap, Map<String, Object> outMap){
String quoteId=(String)inputMap.get('ContextId'),OpportunityId=(String)inputMap.get('OpportunityId'),contractId,prodName,sfdcProdName,prodId,productType,miniDeb,miniCommit,newSalesTypeName,contiSalesTypeName,avtalstid,bindingtime,salesType;
//String OpportunityId=(String)inputMap.get('OpportunityId');
Integer NewSalesAngesnittmanadsavgift,NewSalesAntal,contiSalesAngesnittmanadsavgift,newSalesOneTimeCharge,contiSalesAntal,basniva;
//Delete existing opportunity products 
List<OpportunityLineItem> deleteOpplist = [select id from OpportunityLineItem where TeliaSE_MC_CallOff_QuoteId__c != null and OpportunityId =:OpportunityId];
if(deleteOpplist.size() > 0) delete deleteOpplist;
List<Object> productList = (List<Object>)inputMap.get('FamilyOfferingQLIlist');
List<String> productNames = new List<String>();
List<OpportunityLineItem> oppProdList = new List<OpportunityLineItem>();

//This loop is to extract the product names to extract the price book entry
for(Object o: productList){
Map<String, Object> prodMap = (Map<String, Object>)o;
prodName = (String)prodMap.get('Name');
sfdcProdName = (String)prodMap.get('SFDCProductName');
newSalesTypeName = (String)prodMap.get('NewSalesType');
contiSalesTypeName =(String) prodMap.get('ContinuousSalesType');

if((newSalesTypeName != null && newSalesTypeName!='Inga')&& sfdcProdName == System.Label.Telia_MC_Sales_Type_NewSales) {
productNames.add(System.Label.Telia_MC_Sales_Type_NewSales);
productNames.add(System.Label.Telia_MC_Sales_Type_ContiSales);
}

if((contiSalesTypeName != null && contiSalesTypeName != 'Inga') && sfdcProdName == System.Label.Telia_MC_Sales_Type_NewSales){
productNames.add(System.Label.Telia_MC_Sales_Type_ContiSales);
productNames.add(System.Label.Telia_MC_Sales_Type_NewSales);
}

productNames.add(sfdcProdName);
} 
List<PriceBookEntry> pbeList = [select Name, Product2.Id, Product2.Name, Product2.TeliaSE_MC_Mapped_SE_Product__c from PricebookEntry  where Pricebook2.Name ='Telia Price Book' and Product2.vlocity_cmt__ObjectTypeId__c = null and IsActive =true and Product2.Name IN:productNames];   
Map<String, Id> sfdcPrdMap = new Map<String, String>();
Map<String, Id> prListMap = new Map<String, Id>();

//Maps to have the product name and pricebook entry for Opportunity products (Telia price book)
List<String> bindingtimecheck = new List<String>();
MC_ExclusionInclusionList__c exclusionRecord = MC_ExclusionInclusionList__c.getAll().get('OppSyncBindingPeriodCheck');
if(exclusionRecord != null && exclusionRecord.ObjectType__c != null){
bindingtimecheck = (List<String>)exclusionRecord.ObjectType__c.split(',');
}
for(PriceBookEntry p: pbeList){
sfdcPrdMap.put(p.Product2.Name, p.Product2.Id);
prListMap.put(p.Product2.Name, p.Id);
}
for(Object o: productList){             
Map<String, Object> prodMap = (Map<String, Object>)o;        
//prodName = (String)prodMap.get('Name');
sfdcProdName = (String)prodMap.get('SFDCProductName');
if(prListMap.containskey(sfdcProdName)){
newSalesTypeName = (String)prodMap.get('NewSalesType');
contiSalesTypeName =(String) prodMap.get('ContinuousSalesType');
basniva = (Integer)prodMap.get('Basniva');
productType =(String) prodMap.get('ProductObjectType');
if(!bindingtimecheck.contains(productType)){
avtalstid = (String)prodMap.get('Avtalstid');
}
else{
avtalstid = (String)prodMap.get('BindingTime');
}
prodId =(String) prodMap.get('ProductId');                
miniCommit =(String) prodMap.get('MinCommit');            
if(productType == 'Mobile Offer Specification' || productType =='Touch Point Offer Spec'){
if(miniCommit == null || miniCommit == '0' || miniCommit == '') 
miniDeb = 'No';
else miniDeb = 'Yes';
} else miniDeb = 'No';

//based on sales type, two line items created for one line item in UI
if(newSalesTypeName != null && newSalesTypeName!='Inga') {
OpportunityLineItem olItem = new OpportunityLineItem();
OpportunityLineItem olItem1 = new OpportunityLineItem();
NewSalesAngesnittmanadsavgift = (Integer)prodMap.get('NewSalesAngesnittmanadsavgift');
NewSalesAntal = (Integer)prodMap.get('NewSalesAntal');
newSalesOneTimeCharge = (Integer)prodMap.get('NewSalesEngangsavgift');

// for recurring price
olItem1.TeliaSE_MC_Sales_Type__c = newSalesTypeName;
olItem1.TeliaSE_MC_CallOff_QuoteId__c = quoteId;
//olItem1.Product_Name__c = ( sfdcProdName == System.Label.Telia_MC_Sales_Type_NewSales ) ?   System.Label.Telia_MC_Sales_Type_NewSales: sfdcProdName;
if( sfdcProdName == System.Label.Telia_MC_Sales_Type_NewSales ||  sfdcProdName == System.Label.Telia_MC_Sales_Type_ContiSales ) {
sfdcProdName = System.Label.Telia_MC_Sales_Type_ContiSales;                     
}
olItem1.Product_Name__c = sfdcProdName;
olItem1.Start_Fee__c = ( newSalesOneTimeCharge != 0) ?   newSalesOneTimeCharge : 0;
olItem1.UnitPrice = ( NewSalesAngesnittmanadsavgift != 0) ?   NewSalesAngesnittmanadsavgift : 0;
olItem1.Product2Id = sfdcPrdMap.get(sfdcProdName);
olItem1.vlocity_cmt__Product2Id__c = prodId;
//olItem1.Contact_Duration__c = (avtalstid != null && (!(avtalstid.equalsIgnoreCase('undefined')) && !(avtalstid.equalsIgnoreCase('Uncommitted'))))? Double.valueOf(avtalstid.substring(0,2)):0;
olItem1.Contact_Duration__c = (avtalstid != null && (!(avtalstid.equalsIgnoreCase('undefined')) && !(avtalstid.equalsIgnoreCase('Uncommitted'))))?Double.valueOf(avtalstid.substring(0,2)):0;
olItem1.OpportunityId=OpportunityId;
olItem1.Quantity = (NewSalesAntal != null)? Decimal.valueOf(NewSalesAntal):0;               
olItem1.PricebookEntryId =prListMap.get(sfdcProdName) ;
olItem1.TeliaSE_MC_Sales_Type__c = newSalesTypeName;
olItem1.Minimideb__c = miniDeb;
olItem1.Sales_purpose__c =  newSalesTypeName;
oppProdList.add(olItem1);
}
if(contiSalesTypeName != null && contiSalesTypeName != 'Inga'){
OpportunityLineItem olItem = new OpportunityLineItem();
contiSalesAngesnittmanadsavgift = (Integer)prodMap.get('ContinuousSalesAngesnittmanadsavgift');
contiSalesAntal =(Integer) prodMap.get('ContinuousSalesAntal');
//if(sfdcProdName == System.Label.Telia_MC_Sales_Type_NewSales) sfdcProdName = System.Label.Telia_MC_Sales_Type_ContiSales;
if(sfdcProdName == System.Label.Telia_MC_Sales_Type_NewSales) sfdcProdName = System.Label.Telia_MC_Sales_Type_NewSales;
olItem.TeliaSE_MC_Sales_Type__c = contiSalesTypeName;
olItem.TeliaSE_MC_CallOff_QuoteId__c = quoteId;
//olItem.Product_Name__c = ( sfdcProdName == System.Label.Telia_MC_Sales_Type_ContiSales ) ?   System.Label.Telia_MC_Sales_Type_ContiSales: sfdcProdName;
if( sfdcProdName == System.Label.Telia_MC_Sales_Type_NewSales ||  sfdcProdName == System.Label.Telia_MC_Sales_Type_ContiSales ) {
sfdcProdName = System.Label.Telia_MC_Sales_Type_NewSales;                     
}
olItem.Product_Name__c = sfdcProdName;
olItem.Product2Id = sfdcPrdMap.get(sfdcProdName);
olItem.vlocity_cmt__Product2Id__c = prodId;
olItem.Contact_Duration__c = (avtalstid != null && (!(avtalstid.equalsIgnoreCase('undefined')) && !(avtalstid.equalsIgnoreCase('Uncommitted'))))?Double.valueOf(avtalstid.substring(0,2)):0;
olItem.OpportunityId=OpportunityId;
olItem.Start_Fee__c = 0;
olItem.UnitPrice = ( contiSalesAngesnittmanadsavgift != 0) ?   contiSalesAngesnittmanadsavgift : 0;
olItem.Quantity = (contiSalesAntal != null)? Decimal.valueOf(contiSalesAntal):0;
olItem.PricebookEntryId = prListMap.get(sfdcProdName);
olItem.TeliaSE_MC_Sales_Type__c = contiSalesTypeName;
olItem.Sales_purpose__c =  contiSalesTypeName;
olItem.Minimideb__c = miniDeb;
oppProdList.add(olItem);
}
}     
}
if(oppProdList.size() > 0 ) {
insert oppProdList;
}
}*/
    
    /*
* Developer: Vamsi D
* Description: Validates data that we give in approval is partially filled or not 
*/ 
    //Commented below method as OppSync functionality has been disabled from AM side
    /*private void validateOfferData(Map<String, Object> inputMap, Map<String, Object> outMap){
Boolean partialfilled = false;
Boolean notFilled = false;
Boolean newsales = false;
Boolean contsales = false;
Boolean quantityZero = false;
List<String> ProductName = new List<String>();
List<FamilyOfferingQLIlist> familyoffering = (List<FamilyOfferingQLIlist>) System.JSON.deserialize(JSON.serialize(inputMap.get('FamilyOfferingQLIlist')), List<FamilyOfferingQLIlist>.class);
for(FamilyOfferingQLIlist f : familyoffering){
if((f.NewSalesAntal == null) && (f.NewSalesType == null || f.NewSalesType == 'Inga') && f.NewSalesAngesnittmanadsavgift == null && f.NewSalesEngangsavgift == null){
newsales = false;
}else if(f.NewSalesAntal != null && (f.NewSalesType != null && f.NewSalesType != 'Inga') && f.NewSalesAngesnittmanadsavgift != null && f.NewSalesEngangsavgift != null){
newsales = false;
}else{
newsales = true;
break;
}
}
for(FamilyOfferingQLIlist f : familyoffering){
if(f.NewSalesAntal == 0 || f.ContinuousSalesAntal == 0){
quantityZero = true;
break;
}
}
for(FamilyOfferingQLIlist f : familyoffering){
if(f.ContinuousSalesAntal == null && (f.ContinuousSalesType == null || f.ContinuousSalesType == 'Inga') && f.ContinuousSalesAngesnittmanadsavgift == null){
contsales = false;
}else if(f.ContinuousSalesAntal != null && (f.ContinuousSalesType != null && f.ContinuousSalesType != 'Inga') && f.ContinuousSalesAngesnittmanadsavgift != null){
contsales = false;
}else{
contsales = true;
break;
}
}
for(FamilyOfferingQLIlist f : familyoffering){
if((f.NewSalesAntal != null && f.NewSalesType != null && f.NewSalesAngesnittmanadsavgift != null && f.NewSalesEngangsavgift != null) || (f.ContinuousSalesAntal != null && f.ContinuousSalesType != null && f.ContinuousSalesAngesnittmanadsavgift != null)){
notFilled = true;
break;
}
}
if(contsales || newsales || quantityZero){
partialfilled = true;
}    
outMap.put('partialfilled',partialfilled);
outMap.put('notFilled',notFilled);
}*/
    
    /**
* Developer:Vamsi D
* Story No: MCSTO-5742
* Description: In the opportunity sync page old quantity, price entered should be visible when navigating to opportunity sync page again
(If seller sync products and goes back trough single cart and adds new products and choses to sync the additional product it deletes previous synced products).
For this in below class we are getting info from Opportunity Line Items and QuoteLineItems and comparing then via Productid(vlocity_cmt__Product2Id__c in oli).
**/  
    //Commented below method as OppSync functionality has been disabled from AM side
    /* public static void getOppoSyncProdDetails(Map<String, Object> inputMap, Map<String, Object> outMap){

//Get Opportunity line item info and separate new and continious product in separate maps and use productId as key
String oppId = (String)inputMap.get('OpportunityId');
List<OpportunityLineItem> oppLineList = new List<OpportunityLineItem>();
oppLineList = [select Id,Name,TeliaSE_MC_CallOff_QuoteId__c,Product_Name__c,vlocity_cmt__Product2Id__c,Start_Fee__c,UnitPrice,Contact_Duration__c,OpportunityId,Quantity,PricebookEntryId,TeliaSE_MC_Sales_Type__c,Sales_purpose__c from OpportunityLineItem where TeliaSE_MC_CallOff_QuoteId__c != null and OpportunityId =:oppId];
Set<String> productIdset = new Set<String>();
Map<String,object> newsalesMap = new Map<String,object>(); // to store new sales prod
Map<String,object> contisalesMap = new Map<String,object>(); // to store continious prod
if (oppLineList != null){
for(OpportunityLineItem eacholi:oppLineList){
productIdset.add(eacholi.vlocity_cmt__Product2Id__c);
String salestype = eacholi.TeliaSE_MC_Sales_Type__c; // Storing sales type (New or continous)
if(salestype.contains('New')){
Map<String,object> salesMap = new Map<String,object>();
salesMap.put('NewSalesEngangsavgift',eacholi.Start_Fee__c);
salesMap.put('NewSalesType',eacholi.TeliaSE_MC_Sales_Type__c);
salesMap.put('NewSalesAngesnittmanadsavgift',eacholi.UnitPrice);
salesMap.put('NewSalesAntal',eacholi.Quantity);
newsalesMap.put(eacholi.vlocity_cmt__Product2Id__c,salesMap); // add the newsales type product info to Map with vlocity productid as key
}
if(salestype.contains('Continuation')){
Map<String,object> salesMap = new Map<String,object>();
salesMap.put('ContinuousSalesType',eacholi.TeliaSE_MC_Sales_Type__c);
salesMap.put('ContinuousSalesAngesnittmanadsavgift',eacholi.UnitPrice);
salesMap.put('ContinuousSalesAntal',eacholi.Quantity);
contisalesMap.put(eacholi.vlocity_cmt__Product2Id__c,salesMap); // add the continoussales type product info to Map with vlocity productid as key
}
} 
}   

//Get Quote Line items info and  create a List<Map> and sent it back to OS which we will use to show the info
List<ParentQLI> familyoffering = (List<ParentQLI>) System.JSON.deserialize(JSON.serialize(inputMap.get('Pqli')), List<ParentQLI>.class);//info from DR of omniscript
List<Map<String,object>> finalList = new List<Map<String,object>>(); // to store final result
for(ParentQLI pqli:familyoffering){
Map<String,object> salesMap = new Map<String,object>();
salesMap.put('PriceEntryID',pqli.PriceEntryID);
salesMap.put('ProductId',pqli.ProductId);
salesMap.put('ProductObjectType',pqli.ProductObjectType);
salesMap.put('MinCommit',pqli.MinCommit);
salesMap.put('Basniva',pqli.Basniva);
salesMap.put('Avtalstid',pqli.Avtalstid);
salesMap.put('BindingTime',pqli.BindingTime);
salesMap.put('Name',pqli.Name);
salesMap.put('SFDCProductName',pqli.SFDCProductName);
if(newsalesMap.get(pqli.ProductId) != null){ // check if with productid in new sales map any data exist. If yes, map that data to respective fields.
Map<String,object> salesMap1 = (Map<String,object>)newsalesMap.get(pqli.ProductId); // get the info with  prod id
salesMap.put('NewSalesEngangsavgift',salesMap1.get('NewSalesEngangsavgift'));
salesMap.put('NewSalesAngesnittmanadsavgift',salesMap1.get('NewSalesAngesnittmanadsavgift'));
salesMap.put('NewSalesAntal',salesMap1.get('NewSalesAntal'));
salesMap.put('NewSalesType',salesMap1.get('NewSalesType'));
}
if(contisalesMap.get(pqli.ProductId)!=null){ // check if with productid in Continous sales map any data exist. If yes, map that data to respective fields.
Map<String,object> salesMap1 = (Map<String,object>)contisalesMap.get(pqli.ProductId);
salesMap.put('ContinuousSalesAngesnittmanadsavgift',salesMap1.get('ContinuousSalesAngesnittmanadsavgift'));
salesMap.put('ContinuousSalesAntal',salesMap1.get('ContinuousSalesAntal'));
salesMap.put('ContinuousSalesType',salesMap1.get('ContinuousSalesType'));                
}
finalList.add(salesMap); // add the complete data to list. if there is no data found from opporunity prods, this output will be same as input from Quote
}
outMap.put('FamilyOfferingQLIlist',finalList); // sent to omniscript with 'FamilyOfferingQLIlist' which we are using in vlocity template.
}*/
    
    
    /*Developer:Abhinav Gupta
* Story No: MCSTO-7082
* Description: Imporove Approvals
Improve Method to update rootApproval flag for the root Item bsed on the conditions(CT, Flag or campaign)
Using the RootApproval Flag to extract the items that require approval and display on LWC templates, Email templates
*/
    /*public static void updateQuoteLineBundle_Old(Map<String, Object> inputMap){
String quoteId = (String)inputMap.get('ContextId'); 
Set<String> rootNeedingApprovalSet = new Set<String>();
Set<String> rootAllIdset = new Set<String>();
String sadface = '/resource/1555137213000/TeliaSE_Sad_Face';
List<QuoteLineItem> qliList = new List<QuoteLineItem>();
qliList = [select Id,TeliaSE_Offer_Type__c,vlocity_cmt__RootItemId__c,TeliaSE_Flag__c,TeliaSE_Minimum_Value_Commit__c,vlocity_cmt__ParentItemId__c,MC_CommercialTermsQli__c,TeliaSE_Product_Object_Type__c,TeliaSE_MC_Campaign_Id__c  from QuoteLineItem where QuoteId =: quoteId and (TeliaSE_Root_Product__r.TeliaSE_Offer_Type__c = 'AgreementOffering' or TeliaSE_Root_Product__r.TeliaSE_Offer_Type__c ='SimpleAgreementOffering')];
List<String> includedObjectTypes = (List<String>) MC_ExclusionInclusionList__c.getAll().get('ApprovalCTCheckMinimumCommit').ObjectType__c.split(',');   // Get Object types for MinimumCommitCheck.

boolean istestClass= false;     
if(qliList.size()>0){
for(QuoteLineItem qli: qliList){
Map<String,Object> commercialTermsQli = new Map<String,Object>();
if(String.isNotBlank(qli.MC_CommercialTermsQli__c)){
commercialTermsQli = (Map<String,Object>)json.deserializeUntyped(qli.MC_CommercialTermsQli__c);
}
if(qli.vlocity_cmt__ParentItemId__c == null){
rootAllIdset.add(qli.vlocity_cmt__RootItemId__c);                    
//Commercial term(minimum Commit) Check for parent
if((includedObjectTypes.contains(qli.TeliaSE_Product_Object_Type__c) && qli.TeliaSE_Minimum_Value_Commit__c != null && !qli.TeliaSE_Minimum_Value_Commit__c.equalsIgnoreCase(MC_CommercialNegotiation__c.getAll().get('MinimumCommitment').Default_Value__c)) && //ObjectType check and null/default value check check  
((String.isBlank(qli.MC_CommercialTermsQli__c)) || // If no Approved Value
(!String.isBlank(qli.MC_CommercialTermsQli__c) && ((commercialTermsQli.containskey('MinimumCommitment') && qli.TeliaSE_Minimum_Value_Commit__c != commercialTermsQli.get('MinimumCommitment')) || !commercialTermsQli.containsKey('MinimumCommitment'))))){ //If Approved Value in not blank, null check and value check with approved value 
rootNeedingApprovalSet.add(qli.vlocity_cmt__RootItemId__c);             
}
if(qli.TeliaSE_Offer_Type__c =='SimpleAgreementOffering' && qli.TeliaSE_Flag__c == sadface){
rootNeedingApprovalSet.add(qli.vlocity_cmt__RootItemId__c);
}
}

// Check for child item with sad Flag or without an approved campaign .                 
else if((qli.vlocity_cmt__ParentItemId__c != null && qli.TeliaSE_Flag__c == sadface) ||  
(qli.vlocity_cmt__ParentItemId__c != null && qli.TeliaSE_MC_Campaign_Id__c != null && String.isBlank(qli.MC_CommercialTermsQli__c))){
rootNeedingApprovalSet.add(qli.vlocity_cmt__RootItemId__c);
}
}       
}
List<QuoteLineItem> qliBundleList = new List<QuoteLineItem>();
if(rootNeedingApprovalSet.size() > 0){
for(String qid : rootNeedingApprovalSet){
QuoteLineItem qliitem = new QuoteLineItem();
qliitem.Id = qid;
qliitem.MC_Root_Approval_Flag__c = true;
rootAllIdset.remove(qid);
qliBundleList.add(qliitem);
}
}
if(rootAllIdset.size() > 0){
for(String qid : rootAllIdset){
QuoteLineItem qliitem = new QuoteLineItem();
qliitem.Id = qid;
qliitem.MC_Root_Approval_Flag__c = false;
qliBundleList.add(qliitem);
}
}
if(!test.isRunningTest() && qliBundleList!= null && qliBundleList.size()>0){
update qliBundleList;    
}
}*/
    
    private static void updateQuoteLineBundle(Map<String, Object> inputMap,Map<String, Object> outputMap){
        Set<String> rootAllIdset = new Set<String>();
        Set<String> rootNeedingApprovalSet = new Set<String>();
        String sadFace = '/resource/1555137213000/TeliaSE_Sad_Face';
        Map<String,Id> qliAssetRefMap = new Map<String,Id>();
        
        if(inputMap.containsKey('CampaignRootItemsSet') && inputMap.get('CampaignRootItemsSet') != null && inputMap.get('CampaignRootItemsSet') != ''){
            rootNeedingApprovalSet.addAll((Set<String>)inputMap.get('CampaignRootItemsSet'));
        }
        if(inputMap.containsKey('commercialTermsRootsSet') && inputMap.get('commercialTermsRootsSet') != null && inputMap.get('commercialTermsRootsSet') != ''){
            rootNeedingApprovalSet.addAll((Set<String>)inputMap.get('commercialTermsRootsSet'));
        }
        if(inputMap.containsKey('QuoteLineItems') && inputMap.get('QuoteLineItems') != null && inputMap.get('QuoteLineItems') != ''){
            List<Object> qliList = (List<Object>)inputMap.get('QuoteLineItems');
            for(Object qli : qliList){
                Map<String, Object> qliMap = (Map<String, Object>)qli;
                qliAssetRefMap.put((String)qliMap.get('AssetRefId'),(Id)qliMap.get('Id')); //23.10 <<LTAART-356>> AssetReferenceId change - <<Aditi>>
                rootAllIdset.add((String)qliMap.get('RootItemId'));
                if((String)qliMap.get('ApprovalFlag') == sadFace){
                    rootNeedingApprovalSet.add((String)qliMap.get('RootItemId'));
                }
            }
        }
        List<QuoteLineItem> qliBundleList = new List<QuoteLineItem>();
        if(rootNeedingApprovalSet.size() > 0){
            for(String assestRefId : rootNeedingApprovalSet){
                QuoteLineItem qliItem = new QuoteLineItem();
                qliItem.Id = String.valueOf(qliAssetRefMap.get(assestRefId)); //23.10 <<LTAART-356>> AssetReferenceId change - <<Aditi>>
                qliItem.MC_Root_Approval_Flag__c = true;
                rootAllIdset.remove(String.valueOf(assestRefId));
                qliBundleList.add(qliItem);
            }
        }
        if(rootAllIdset.size() > 0){
            for(String assestRefId : rootAllIdset){
                QuoteLineItem qliItem = new QuoteLineItem();
                qliItem.Id = String.valueOf(qliAssetRefMap.get(assestRefId)); //23.10 <<LTAART-356>> AssetReferenceId change - <<Aditi>>
                qliItem.MC_Root_Approval_Flag__c = false;
                qliBundleList.add(qliItem);
            }
        }
        if(!test.isRunningTest() && qliBundleList!= null && qliBundleList.size()>0){
            update qliBundleList;
            outputMap.put('Update','Successful');
        }
    }
    
    public class FamilyOfferingQLIlist{
        public String Name,NewSalesType,ContinuousSalesType;
        public Integer NewSalesAntal,NewSalesAngesnittmanadsavgift,NewSalesEngangsavgift,ContinuousSalesAntal,ContinuousSalesAngesnittmanadsavgift;
    }
    public class ParentQLI{
        public String Avtalstid,MinCommit,Name,PriceEntryID,ProductId,ProductObjectType,SFDCProductName,ProductType,BindingTime;
        public Integer Basniva;  
    }
    
    public class QuoteParams{
        public String Avtalstid,MinCommit,Name,PriceEntryID,ProductId,ProductObjectType,SFDCProductName,ProductType,BindingTime;
        public Integer Basniva;  
    }
}