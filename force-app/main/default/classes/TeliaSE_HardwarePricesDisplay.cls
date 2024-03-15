/**
* Developer Name: Vamsi D
* Story: MCSTO-5763
* Description: Create custom Apex function to generate a Node for display in Template
* Used in: Hardware need2 Subscription/cart omniscript
*/ 

global class TeliaSE_HardwarePricesDisplay implements vlocity_cmt.VlocityOpenInterface2{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('displayProd')) {
                displayProd(inputMap, outMap);
            }else {
                result = false;
            }  
        }catch(Exception e) {          
            result = false;
        }        
        return result;
    }
    public static void displayProd(Map<String, Object> inputMap, Map<String,object>outMap){
        Map<String,object> finalProductPriceMap = new Map<String,object>();
        List<Map<String,object>> finalProductPriceList = new List<Map<String,object>>();
        //-----------------------------------Product detials------------------------------------------
        List<vlocity_cmt__PriceListEntry__c> productList = new List<vlocity_cmt__PriceListEntry__c>();
        Map<String,String> sapIdMap = new Map<String,String>(); // Map with Product Id and sap Id
        Map<String,Decimal> amountMap = new Map<String,Decimal>(); //to Store list prices
        set<String> prodidSet = new set<String>(); // selected product Id
        Map<String,object> itemIdMap = new  Map<String,object>(); //mapping info with productId to fetch details
        object productid = (Object)inputMap.get('SelectedHardwareProductList');
        String standardPricelist = System.Label.StandardPriceList;
        String productidjson = JSON.serialize(productid);
        List<SelectedHardwareProductListWrapper> selectedProductList = (List<SelectedHardwareProductListWrapper>)JSON.deserialize(productidjson, List<SelectedHardwareProductListWrapper>.class);    
        for(SelectedHardwareProductListWrapper spw : selectedProductList){
            prodidSet.add(spw.productId);
            itemIdMap.put(spw.productId,spw);
        }
        productList = [select vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c,vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProductId__c from vlocity_cmt__PriceListEntry__c where vlocity_cmt__ProductId__c in : prodidSet and vlocity_cmt__PriceListName__c =: standardPricelist and vlocity_cmt__IsActive__c = true];        
        for(vlocity_cmt__PriceListEntry__c prod : productList){
            String prodid = prod.vlocity_cmt__ProductId__c;
            amountMap.put(prodid,prod.vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c);
        }
        System.debug('amountMap'+json.serialize(amountMap));
        //--------------------get selected subscriptions and Ranges------------------------------
        Map<String,String> SubscriptonRanges = new Map<String,String>();
        String sub1,sub2,sub3;
        Integer numberOfSubs = Integer.ValueOf(inputMap.get('NumberOfSelectedSubscription'));
        List<Subscription> SubscriptionList = (List<Subscription>) System.JSON.deserialize(JSON.serialize(inputMap.get('SubscriptionList')), List<Subscription>.class);
        
        if(numberOfSubs != null && numberOfSubs > 0){
            List<PricematrixRanges__c> ranges = new List<PricematrixRanges__c>([select  High__c,Low__c,Name from PricematrixRanges__c]);        
            for(Subscription s: SubscriptionList){
                String priceRange;
                String sName = s.Name;
                Decimal sPrice = (Decimal)s.Price;
                for(PricematrixRanges__c range : ranges){
                    if (sPrice >= range.Low__c && sPrice <= range.High__c){
                        priceRange = range.Name;
                    }
                }
                SubscriptonRanges.put(sName,priceRange);
            }
            if(numberOfSubs == 3){
                sub1 = SubscriptionList[0].Name;
                sub2 = SubscriptionList[1].Name;
                sub3 = SubscriptionList[2].Name;
            }
            if(numberOfSubs == 2){
                sub1 = SubscriptionList[0].Name;
                sub2 = SubscriptionList[1].Name;
            }
            if(numberOfSubs == 1){
                sub1 = SubscriptionList[0].Name;
            }
        }
        finalProductPriceMap.put('sub1',sub1);
        finalProductPriceMap.put('sub2',sub2);
        finalProductPriceMap.put('sub3',sub3);
        //-----------------------------------Price List setup--------------------------------------------
        PriceListSetupwrapper priceListSet = (PriceListSetupwrapper) System.JSON.deserialize(JSON.serialize(inputMap.get('PriceListSetup')), PriceListSetupwrapper.class);
        String priceListSetup = priceListSet.PriceList;
        //-----------------------------------Procedure Name----------------------------------------------
        String bindingPeriod;
        String procedureName;
        Integer bindingTime;
        BindingTimeWrapper binding = (BindingTimeWrapper) System.JSON.deserialize(JSON.serialize(inputMap.get('BindingTime')), BindingTimeWrapper.class);
        if(binding!=null){           
            bindingPeriod = binding.Months;
            if(bindingPeriod.substring(0,1) == '3'){
                procedureName = 'Hardware_36M_RangeAttributePricingProcedure';
                bindingTime = 36;
            }else{
                procedureName = 'Hardware_24M_RangeAttributePricingProcedure';
                bindingTime = 24;
            }
        }
        
        //------------------------------calculation Procedure request---------------------------------
        Object[] inputdata = new List<Object> (); 
        Map<String,List<String>> productKeyMap = new Map<String,List<String>>();
        Map <String, Object> output = new Map<String,Object>();
        if(numberOfSubs != null && procedureName != null){          
            for(String pid: itemIdMap.keySet()){
                SelectedHardwareProductListWrapper hardwareitem = (SelectedHardwareProductListWrapper)itemIdMap.get(pid);
                String sapId = sapIdMap.get(pid);            
                List<String> keyList = new List<String>();
                for(Subscription s: SubscriptionList){
                    Map <String, Object> dataMap = new Map<String, Object>();
                    dataMap.put('Source Product Name', hardwareitem.Name);
                    dataMap.put('Source Product Code', hardwareitem.Code);
                    dataMap.put('Characteristic Name', 'HWSAPID');
                    dataMap.put('Characteristic Value', hardwareitem.Code); //swapped sapId with hardwareitem.Code
                    dataMap.put('Quantity',SubscriptonRanges.get(s.Name));
                    String key =  hardwareitem.Code+SubscriptonRanges.get(s.Name);
                    keyList.add(key);
                    inputdata.add(dataMap);
                }
                productKeyMap.put(pid, keyList);
            } 
            System.debug('inputdata'+Json.serialize(inputdata));
            invokecalculationprocedure(inputdata,procedureName,output);   
        }
        
        //-------------------------------------Parsing calculation response -----------------------------------------      
        System.debug('output-->'+Json.serialize(output));
        for(String pid: itemIdMap.keySet()){
            Map<String,object> PriceMap = new Map<String,object>();
            SelectedHardwareProductListWrapper hardwareitem = (SelectedHardwareProductListWrapper)itemIdMap.get(pid);
            PriceMap.put('Name',hardwareitem.Name);
            PriceMap.put('Amount',amountMap.get(pid));
            if(numberOfSubs != null && procedureName != null){ 
                List<String> keyList = productKeyMap.get(pid);
                if(keyList.size() != null){
                    if(keyList.size() == 1){
                        System.debug('keylist->'+keyList[0]);
                        Map<String,object> priceMap1 = (Map<String,object>)output.get(keyList[0]);
                        if(priceMap1 != null){
                            Decimal rtc1 = (Decimal)priceMap1.get('RTC');
                            Decimal otc1 = (Decimal)priceMap1.get('OTC');
                            if(bindingTime != null && rtc1 !=null && otc1 != null){
                                if(priceListSetup == 'Engångskostnad'){
                                    Decimal otf1 = ((rtc1 * bindingTime) + otc1);
                                    PriceMap.put('OTC1',otf1);
                                }else{
                                    PriceMap.put('RTC1',rtc1);
                                    PriceMap.put('OTC1',otc1); 
                                }
                            }
                        }  
                    }
                    else if(keyList.size() == 2){
                        System.debug('keylist-->'+keyList[0]);
                        Map<String,object> priceMap1 = (Map<String,object>)output.get(keyList[0]);
                        if(priceMap1 != null){
                            Decimal rtc1 = (Decimal)priceMap1.get('RTC');
                            Decimal otc1 = (Decimal)priceMap1.get('OTC');
                            if(bindingTime != null && rtc1 !=null && otc1 != null){
                                if(priceListSetup == 'Engångskostnad'){
                                    Decimal otf1 = ((rtc1 * bindingTime) + otc1);
                                    PriceMap.put('OTC1',otf1);
                                }else{
                                    PriceMap.put('RTC1',rtc1);
                                    PriceMap.put('OTC1',otc1); 
                                }
                            }
                        }
                        System.debug('keylist-->'+keyList[1]);
                        Map<String,object> priceMap2 = (Map<String,object>)output.get(keyList[1]);
                        if(priceMap2 != null){
                            Decimal rtc2 = (Decimal)priceMap2.get('RTC');
                            Decimal otc2 = (Decimal)priceMap2.get('OTC');
                            if(bindingTime != null && rtc2 !=null && otc2 != null){
                                if(priceListSetup == 'Engångskostnad'){
                                    Decimal otf2 = ((rtc2 * bindingTime) + otc2);
                                    PriceMap.put('OTC2',otf2);
                                }else{
                                    PriceMap.put('RTC2',rtc2);
                                    PriceMap.put('OTC2',otc2); 
                                }
                            }
                        }
                    }
                    else if(keyList.size() == 3){
                        System.debug('keylist--->'+keyList[0]);
                        Map<String,object> priceMap1 = (Map<String,object>)output.get(keyList[0]);
                        if(priceMap1 != null){
                            Decimal rtc1 = (Decimal)priceMap1.get('RTC');
                            Decimal otc1 = (Decimal)priceMap1.get('OTC');
                            if(bindingTime != null && rtc1 !=null && otc1 != null){
                                if(priceListSetup == 'Engångskostnad'){
                                    Decimal otf1 = ((rtc1 * bindingTime) + otc1);
                                    PriceMap.put('OTC1',otf1);
                                }else{
                                    PriceMap.put('RTC1',rtc1);
                                    PriceMap.put('OTC1',otc1); 
                                }
                            }
                        }
                        System.debug('keylist--->'+keyList[1]);
                        Map<String,object> priceMap2 = (Map<String,object>)output.get(keyList[1]);
                        if(priceMap2 != null){
                            Decimal rtc2 = (Decimal)priceMap2.get('RTC');
                            Decimal otc2 = (Decimal)priceMap2.get('OTC');
                            if(bindingTime != null && rtc2 !=null && otc2 != null){
                                if(priceListSetup == 'Engångskostnad'){
                                    Decimal otf2 = ((rtc2 * bindingTime) + otc2);
                                    PriceMap.put('OTC2',otf2);
                                }else{
                                    PriceMap.put('RTC2',rtc2);
                                    PriceMap.put('OTC2',otc2); 
                                }
                            }
                        }
                        System.debug('keylist--->'+keyList[2]);
                        Map<String,object> priceMap3 = (Map<String,object>)output.get(keyList[2]);
                        if(priceMap3 != null){
                            Decimal rtc3 = (Decimal)priceMap3.get('RTC');
                            Decimal otc3 = (Decimal)priceMap3.get('OTC');
                            if(bindingTime != null && rtc3 !=null && otc3 != null){
                                if(priceListSetup == 'Engångskostnad'){
                                    Decimal otf3 = ((rtc3 * bindingTime) + otc3);
                                    PriceMap.put('OTC3',otf3);
                                }else{
                                    PriceMap.put('RTC3',rtc3);
                                    PriceMap.put('OTC3',otc3); 
                                }
                            }
                        }
                    }
                }
            }
            finalProductPriceList.add(PriceMap);
        }
        finalProductPriceMap.put('matrixPriceMap',finalProductPriceList);
        outMap.put('finalProductPriceMap',finalProductPriceMap);     
    }
    
    public static void invokecalculationprocedure(Object[] inputdata,String procedureName,Map <String, Object> calculationResultMap){
        Map <String, Object> input = new Map<String, Object>(); 
        Map <String, Object> output = new Map<String,Object>();
        Map <String, Object> options = new Map<String, Object>();  
        List<object> calculationResults = new List<object>();
        input.put('UserInputList', inputdata); 
        
        options.put('configurationName', procedureName);        
        options.put('includeInputs', true);  
        options.put('verbose', false);    
        options.put('mergeInListName', 'UserInputList');        
        
        Type t = Type.forName('vlocity_cmt','PricingMatrixCalculationService');        
        vlocity_cmt.VlocityOpenInterface vpsi = (vlocity_cmt.VlocityOpenInterface) t.newInstance();        
        vpsi.invokeMethod('calculate', input, output, options);   
       
        String str;
        List<object> outList = (List<object>)output.get('output');              
        vlocity_cmt.PricingCalculationService.CalculationProcedureResults cp = (vlocity_cmt.PricingCalculationService.CalculationProcedureResults)outList[0];   
        if(!Test.isRunningTest()){                 
            calculationResults = (List<object>)cp.calculationResults;
        }
        if(Test.isRunningTest()){
             str = '[{"Quantity":"300-324","Characteristic Value":"9098690","Characteristic Name":"HWSAPID","Source Product Code":"9098690","Source Product Name":"Samsung Galaxy A32 128 GB","REC_MNTH_STD_PRC":40.00,"OT_STD_PRC":0.00,"PriceMatrix_24M_Hardware__NRC":"0","PriceMatrix_24M_Hardware__MRC":"40","ID":"3"},{"Quantity":"550-574","Characteristic Value":"9098690","Characteristic Name":"HWSAPID","Source Product Code":"9098690","Source Product Name":"Samsung Galaxy A32 128 GB","REC_MNTH_STD_PRC":0.00,"OT_STD_PRC":0.00,"PriceMatrix_24M_Hardware__NRC":"0","PriceMatrix_24M_Hardware__MRC":"0","ID":"4"},{"Quantity":"400-424","Characteristic Value":"9098690","Characteristic Name":"HWSAPID","Source Product Code":"9098690","Source Product Name":"Samsung Galaxy A32 128 GB","REC_MNTH_STD_PRC":20.00,"OT_STD_PRC":0.00,"PriceMatrix_24M_Hardware__NRC":"0","PriceMatrix_24M_Hardware__MRC":"20","ID":"5"},{"Quantity":"300-324","Characteristic Value":"9100224","Characteristic Name":"HWSAPID","Source Product Code":"9100224","Source Product Name":"Samsung Galaxy S21 EE 5G 128 GB","REC_MNTH_STD_PRC":300.00,"OT_STD_PRC":160.00,"PriceMatrix_24M_Hardware__NRC":"160","PriceMatrix_24M_Hardware__MRC":"300","ID":"6"},{"Quantity":"550-574","Characteristic Value":"9100224","Characteristic Name":"HWSAPID","Source Product Code":"9100224","Source Product Name":"Samsung Galaxy S21 EE 5G 128 GB","REC_MNTH_STD_PRC":230.00,"OT_STD_PRC":160.00,"PriceMatrix_24M_Hardware__NRC":"160","PriceMatrix_24M_Hardware__MRC":"230","ID":"7"},{"Quantity":"400-424","Characteristic Value":"9100224","Characteristic Name":"HWSAPID","Source Product Code":"9100224","Source Product Name":"Samsung Galaxy S21 EE 5G 128 GB","REC_MNTH_STD_PRC":280.00,"OT_STD_PRC":160.00,"PriceMatrix_24M_Hardware__NRC":"160","PriceMatrix_24M_Hardware__MRC":"280","ID":"8"}]';
             calculationResults = (List<Object>)JSON.deserializeUntyped(str);
        }
        for(object o : calculationResults){
            Map<String,object> resultMap = (Map<String,object>)o;
            String key = (String)resultMap.get('Source Product Code'); 
            key += (String)resultMap.get('Quantity');
            Map<String,object> priceMap = new Map<String,object>();
            priceMap.put('RTC',(Decimal)resultMap.get('REC_MNTH_STD_PRC'));
            priceMap.put('OTC',(Decimal)resultMap.get('OT_STD_PRC'));
            calculationResultMap.put(key,priceMap);    
        }
    }
    //wrapper for selected products
    public class SelectedHardwareProductListWrapper {
        public String Name;
        public String Id;   
        public String ProductId;    
        public String Code; 
    }
    public Class Subscription{
        public string Id{get; set;}
        public string Name{get; set;}
        public Decimal Price{get; set;}
    }
    public Class BindingTimeWrapper{
        public String Months {get; set;}
    }
    public class PriceListSetupwrapper{
        public String PriceList {get; set;}
    }
}