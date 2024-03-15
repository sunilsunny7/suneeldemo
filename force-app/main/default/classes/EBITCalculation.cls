global class EBITCalculation implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        Boolean result = true;
        if(methodName.equals('updateEBITValues')){
            EBITCalculation.updateEBITValues(inputMap, outMap);
        }
        else if(methodName.equals('repriceCart'))
        {
            repriceCart(inputMap, outMap);
        }
        /*else if(methodName.equals('retriveEBITValues')){
            EBITCalculation.retriveEBITValues(inputMap, outMap);
        }*/
        else if(methodName.equals('updateFiberDiscount')){
            EBITCalculation.updateFiberDiscount(inputMap, outMap);
        }
        else{
            result = false; 
        }
        return result;          
    } 
     private static void repriceCart(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
    
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        List<String> idList = new List<String>();
        //Added below additional input parameter due to new upgrade issues
        List<QuoteLineitem> qliOfferList = [Select id,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c from quotelineitem where quoteid=:(String)inputMap.get('quoteId') and vlocity_cmt__ParentItemId__c  = null];
        try{
            if(!(qliOfferList.isEmpty())){
                for(quotelineitem i:qliOfferList){
                    if( i.vlocity_cmt__RootItemId__c == i.id){
                        //Query all PCI and invoke repricecart
                        List<QuoteLineitem> qliPCIList = [Select id,vlocity_cmt__ParentItemId__c from quotelineitem where quoteid=:(String)inputMap.get('quoteId') and vlocity_cmt__ParentItemId__c =: i.id];
                        for(Quotelineitem j:qliPCIList){
                            idList.add(j.id);
                        }//End of for
                        input.put('items',idList);
                        input.put('cartId', (String)inputMap.get('quoteId'));
                        input.put('methodName', 'priceCart');
                        vlocity_cmt.CpqAppHandler cpqAppHandlerService = new  vlocity_cmt.CpqAppHandler();
                        cpqAppHandlerService.invokeMethod('priceCart', input, outputMap, optionsMap);
                        idList.clear();
                        qliPCIList.clear();
                        input.clear();
                    }//End if
                }//End for
            }//End if
        }//End try 
        catch(Exception e)
        {
            outMap.put('error',e.getMessage());
            outMap.put('Success',false);
            return;
        }
        outMap.put('Success',true);
    } 
    /*
    public static void retriveEBITValues(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{
            string QuoteId = String.ValueOf(inputMap.get('quoteid'));
            List<quote> quotes = [select id, TeliaSE_Fiber_One_time_Property_Owner__c,TeliaSE_Fiber_Customer_Placed_Equipment__c,TeliaSE_Fiber_Capex_Infra__c,TeliaSE_Fiber_Payback_Y__c,TeliaSE_Fiber_Depreciation__c,TeliaSE_Fiber_OPEX__c,TeliaSE_Fiber_Return_Of_Investement__c,TeliaSE_Fiber_Upsell__c,TeliaSE_Fiber_Revenues__c,TeliaSE_Fiber_EBIT_Percentage__c,TeliaSE_Fiber_ACK_DCF__c,TeliaSE_Fiber_Contract_Term_Y__c from quote where id=:QuoteId];
            if(quotes.size()>0 && quotes[0].TeliaSE_Fiber_EBIT_Percentage__c > 0){
                outMap.put('AvailableQuotes', true);
                outMap.put('result', quotes);
            }
            
        }catch(Exception e){
            outMap.put('AvailableQuotes', false);
            outMap.put('result', 'Error');
            outMap.put('ErrorMessage : ', e.getMessage());
        }
    }*/
    public static void updateEBITValues(Map<String,Object> inputMap, Map<String,Object> outMap){
    try{
        string QuoteId = String.ValueOf(inputMap.get('quoteid'));
        string EBITVal = String.ValueOf(inputMap.get('EBITVal'));
        string RecurringTotal = String.ValueOf(inputMap.get('RecurringTotal'));
        string ContractTerm = String.ValueOf(inputMap.get('ContractTerm'));  
        string Revenues = String.ValueOf(inputMap.get('Revenues'));  
        string Opex = String.ValueOf(inputMap.get('Opex'));  
        string Infra = String.ValueOf(inputMap.get('Infra'));  
        string Upsell = String.ValueOf(inputMap.get('Upsell'));  
        string Depreciation = String.ValueOf(inputMap.get('Depreciation'));  
        string Kundplacerad = String.ValueOf(inputMap.get('Kundplacerad'));  
        string dcf = String.ValueOf(inputMap.get('dcf'));  
        string Investement = String.ValueOf(inputMap.get('Investement'));  
        string Payback = String.ValueOf(inputMap.get('Payback'));  
        string Engang = String.ValueOf(inputMap.get('Engang'));
        string PrisBB = String.ValueOf(inputMap.get('PrisBB'));
        string PrisTV = String.ValueOf(inputMap.get('PrisTV'));
        
        if(!String.isBlank(QuoteId)){
            List<quote> quotes = [select id, TeliaSE_Fiber_One_time_Property_Owner__c,TeliaSE_Fiber_Customer_Placed_Equipment__c,TeliaSE_Fiber_Capex_Infra__c,TeliaSE_Fiber_Payback_Y__c,TeliaSE_Fiber_Depreciation__c,TeliaSE_Fiber_OPEX__c,TeliaSE_Fiber_Return_Of_Investement__c,TeliaSE_Fiber_Upsell__c,TeliaSE_Fiber_Revenues__c,TeliaSE_Fiber_EBIT_Percentage__c,TeliaSE_Fiber_ACK_DCF__c,TeliaSE_Fiber_Contract_Term_Y__c,TeliaSE_Pris_TV_exkl_moms__c,TeliaSE_Pris_BB_exkl_moms__c from quote where id=:QuoteId];
            
            outMap.put('quoteSize', quotes.size());
            
            if(quotes.size()>0)
            {
                quotes[0].TeliaSE_Fiber_One_time_Property_Owner__c = Decimal.valueOf(Engang);
                quotes[0].TeliaSE_Fiber_Customer_Placed_Equipment__c = Decimal.valueOf(Kundplacerad);
                quotes[0].TeliaSE_Fiber_Capex_Infra__c = Decimal.valueOf(Infra);
                quotes[0].TeliaSE_Fiber_Payback_Y__c = Decimal.valueOf(Payback);
                quotes[0].TeliaSE_Fiber_Depreciation__c = Decimal.valueOf(Depreciation);
                quotes[0].TeliaSE_Fiber_OPEX__c = Decimal.valueOf(Opex);
                quotes[0].TeliaSE_Fiber_Return_Of_Investement__c = Decimal.valueOf(Investement);
                quotes[0].TeliaSE_Fiber_Upsell__c = Decimal.valueOf(Upsell);
                quotes[0].TeliaSE_Fiber_Revenues__c = Decimal.valueOf(Revenues);
                quotes[0].TeliaSE_Fiber_EBIT_Percentage__c = Decimal.valueOf(EBITVal);
                quotes[0].TeliaSE_Fiber_ACK_DCF__c = Decimal.valueOf(dcf);
                quotes[0].TeliaSE_Fiber_Contract_Term_Y__c = Decimal.valueOf(ContractTerm);
                quotes[0].TeliaSE_Pris_BB_exkl_moms__c = Decimal.valueOf(PrisBB);
                quotes[0].TeliaSE_Pris_TV_exkl_moms__c = Decimal.valueOf(PrisTV);
                update quotes;
            }
        }
        }
        catch(Exception e){
            outMap.put('msg', e.getMessage());
            outMap.put('MethodStatus','Fail');
            outMap.put('error',e.getMessage());
            outMap.put('errorCode','Fail');
        }
    }
    public static void updateFiberDiscount(Map < String, Object > inputMap, Map < String, Object > outMap) {
        try{
            String quoteId = (String) inputMap.get('quoteid');
            List < SObject > qItemList = new List < SObject > ();
            List < QuoteLineItem > qlisToUpdate = new List < QuoteLineItem > ();
            QuoteLineItem qliObject = new QuoteLineItem();
            qItemList = [SELECT vlocity_cmt__RecurringCharge__c, Fiber_Customer_Requested_Price__c, TeliaSE_fiber_Rabatt__c, TeliaSE_Flag__c, Fiber_Approved_Price__c, Quote.TeliaSE_Record_Type_Name__c FROM QuoteLineItem where quoteid =: quoteId];
            if (qItemList != null && qItemList.size() > 0) {
                Decimal discount;
                for (SObject qliItem: qItemList) {
                    qliObject = (QuoteLineItem) qliItem;
    
                    if (qliObject.Fiber_Customer_Requested_Price__c != null) {
                        //changing from TeliaSE_Ceiling_Price__c to vlocity_cmt__RecurringCharge__c
                        discount = (((qliObject.vlocity_cmt__RecurringCharge__c - qliObject.Fiber_Customer_Requested_Price__c) / qliObject.vlocity_cmt__RecurringCharge__c) * 100).setScale(2, RoundingMode.HALF_UP);
                        qliObject.TeliaSE_fiber_Rabatt__c = discount;
                        Decimal SalesRepProductDiscountMaxMandate = FiberDiscountMandate__c.getAll().get('SalesRep').ProductDiscountMaxMandate__c;
    
                        if (discount > SalesRepProductDiscountMaxMandate) {
                            qliObject.TeliaSE_Flag__c = System.Label.TeliaSE_SadFace;
                            // Added as part of DC-0013 requirement
                            if (qliObject.Fiber_Customer_Requested_Price__c < qliObject.Fiber_Approved_Price__c) {
                                qliObject.TeliaSE_Flag__c = System.Label.TeliaSE_SadFace;
                            } else if (qliObject.Fiber_Customer_Requested_Price__c >= qliObject.Fiber_Approved_Price__c) {
                                if (discount > SalesRepProductDiscountMaxMandate) {
                                    if (qliObject.Fiber_Customer_Requested_Price__c >= qliObject.Fiber_Approved_Price__c) {
                                        qliObject.TeliaSE_Flag__c = System.Label.TeliaSE_HappyFace;
                                    } else {
                                        qliObject.TeliaSE_Flag__c = System.Label.TeliaSE_SadFace;
                                    }
                                } else {
                                    qliObject.TeliaSE_Flag__c = System.Label.TeliaSE_HappyFace;
                                }
                            }
                        }
                        //----------------- Added as part of DC-0013 requirement
                        else {
                            qliObject.TeliaSE_Flag__c = System.Label.TeliaSE_HappyFace;
                        }
                    }
                    qlisToUpdate.add(qliObject);
                }
            }
            if (qlisToUpdate.size() > 0) {
                update qlisToUpdate;
            }
        }
        catch (Exception e) {
            outMap.put('error',e.getMessage());
            outMap.put('errorCode','Fail');
        }
    }
}