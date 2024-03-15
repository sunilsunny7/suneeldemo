global class PriceMatrixAPICall implements vlocity_cmt.VlocityOpenInterface2 {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('updatePrices')){
                PriceMatrixAPICall.UpdateQuoteprices(inputMap,outMap,null);
            }else {
                result = false;
            }   
            
        } catch(Exception e) {          
            result = false;
        }        
        return result;
    }

    public static void UpdateQuoteprices(Map<String,Object> inputMap,Map<String,Object>outMap,Map<String,Decimal> ResponseMapTest){
        
        string prodnameString = System.JSON.Serialize(inputMap.get('QLI'));
        List<QLIWrapper> qlilist = (List<QLIWrapper>)JSON.deserialize(prodnameString, List<QLIWrapper>.class);
        String procedureName = qlilist[0].procedureName;
        Map<String,String> pIdMap = new Map<String,String>();
        List<String> keyList = new List<String>();
        Object[] inputdata = new List<Object> (); 
        List<QuoteLineItem> qlitoUpdate = new List<QuoteLineItem>();
        List<PricematrixRanges__c> ranges = new List<PricematrixRanges__c>([select  High__c,Low__c,Name from PricematrixRanges__c]);
        
        if(qlilist.size() > 0){
            for(QLIWrapper qli : qlilist){
                String priceRange;
                Decimal Quantity = qli.Quantity;
                Decimal efsprice = qli.EFSPris;
                Decimal OneTimeCharge = qli.OneTimeCharge;
                Decimal RecurringCharge= qli.RecurringCharge;
                if(efsprice != null){
                    for(PricematrixRanges__c range : ranges){
                        if (efsprice >= range.Low__c && efsprice <= range.High__c){
                            priceRange = range.Name;
                        }
                    }
                    Map <String, Object> dataMap = new Map<String, Object>();   
                    dataMap.put('Source Product Code', qli.ProductCode);
                    dataMap.put('Characteristic Name', 'HWSAPID');
                    dataMap.put('Characteristic Value', qli.ProductCode);
                    dataMap.put('Quantity',priceRange);   
                    String key =  qli.ProductCode+priceRange;
                    keyList.add(key); 
                    inputdata.add(dataMap);
                    pIdMap.put((String)qli.Id,key);
                    System.debug('pIdMap'+pIdMap);
                }
            }
            if(!Test.isRunningTest()){
            	TeliaSE_HardwarePricesDisplay.invokecalculationprocedure(inputdata,procedureName,outMap);
            }
            for(QLIWrapper qli : qlilist){
                QuoteLineItem updateqli = new QuoteLineItem();
                String pid = qli.Id;
                System.debug('outMap'+outMap);
                Map<String,object> priceMap = (Map<String,object>)outMap.get(pIdMap.get(pid));
                updateqli.Id = qli.Id;
                Decimal Quantity = qli.Quantity;
                Decimal OneTimeCharge = qli.OneTimeCharge;
                Decimal RecurringCharge= qli.RecurringCharge;
                Decimal efsprice = qli.EFSPris;
                if(efsprice != null){
                    if(priceMap != null){
                        Decimal rtc1 = (Decimal)priceMap.get('RTC');
                        Decimal otc1 = (Decimal)priceMap.get('OTC');
                    
                        if(priceMap.get('OTC') != null){
                            updateqli.vlocity_cmt__OneTimeCharge__c = otc1;
                            updateqli.vlocity_cmt__EffectiveOneTimeTotal__c = otc1 * Quantity;
                            updateqli.vlocity_cmt__EffectiveOneTimeCostTotal__c = otc1;
                        }
                        if(priceMap.get('RTC') != null){
                            updateqli.vlocity_cmt__RecurringCharge__c = rtc1;
                            updateqli.vlocity_cmt__EffectiveRecurringTotal__c = rtc1 * Quantity;
                        }
                        qlitoUpdate.add(updateqli);
                    }
                }
                else{
                    updateqli.vlocity_cmt__EffectiveOneTimeTotal__c = OneTimeCharge * Quantity;
                    updateqli.vlocity_cmt__EffectiveRecurringTotal__c =  RecurringCharge * Quantity;
                    qlitoUpdate.add(updateqli);
                }
            }
            if(qlitoUpdate.size() > 0 ){
                update qlitoUpdate;
            }
        }
    }
    public class QLIWrapper {
        public Decimal EFSPris{get; set;}
        public Decimal OneTimeCharge{get; set;}
        public Decimal RecurringCharge{get; set;}     
        public String ProductCode{get; set;}
        public String Brand{get; set;}
        public String Memory{get; set;}
        public String Color{get; set;}
        public String ProdName{get; set;}
        public String Id{get; set;}
        public String procedureName{get; set;}
        public Decimal Quantity{get; set;}
        public String SAPID{get; set;}
	}
}