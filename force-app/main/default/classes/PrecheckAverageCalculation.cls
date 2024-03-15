global class PrecheckAverageCalculation implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, map<String,Object> inputMap, map<String,Object> outputMap, map<String,Object> options){
        Boolean result = true;
        try{
            if(methodName.equalsIgnoreCase('calculateAverage')) {
                // If prechecnotprocessed flag is false then dont average
                // thats mean not all servicepoints processed. So dont calculate avg price.
                Boolean precheckNotProcessed = (Boolean)inputMap.get('PrecheckNotProcessedFlag');
                if(precheckNotProcessed != null && precheckNotProcessed == false ){
                    calculateAverage(inputMap,outputMap);
                    return result;
                }else{
                    result = false;
                    outputMap.put('ErrorMessage','Precheck not processed');
                    outputMap.put('Result',result);
                    return result;
                
                }
            }
            else{
                result = false;
                outputMap.put('ErrorMessage','Method not found for average calculation');
                outputMap.put('Result',result);
                return result;
            }
                
        }
        catch(exception ex){
            outputMap.put('Errorlinenumber',ex.getLineNumber());
            outputMap.put('ErrorMessage',ex.getmessage());
            result = false;
            outputMap.put('Result',result);
            return result;
        }
 
    }
    public static map<String,Object> calculateAverage(Map<String, Object> inputMap,Map<String,Object> outputMap){
        String accId = (String)inputMap.get('AccId'); // Get from IP PreCheck_loop
        String objId = (String)inputMap.get('oppId'); // Get from IP PreCheck_loop
        map<String,Decimal> prodAddProd = new map<String,Decimal>();// This map will have non zero  prices of all bandwidth products
        map<String,Integer> prodAddProd1 = new map<String,Integer>(); // This map will have non zero  prices of all bandwidth products
        map<String,Integer> priceCountMap = new map<String,Integer>(); // This map will have count of all sites for a product
        map<String,String>  lineMap = new map<String,String>(); // This map will have the line types of a product
        map<String,String>  nameMap = new map<String,String>(); // This map will have the productnames and will be used when insert average prices record
        map<String,Boolean> blMap = new map<String,Boolean>(); // This map will have Boolean value for linetypes like Fttx, Fibre
        map<String,Boolean> mP = new map<String,Boolean>();
        Map<String,Decimal> finalAvgPrices = new Map<String,Decimal>(); //This map will have have the average prices of all bandwidth products

        List<Object> siteList = (List<Object>)inputMap.get('FullSiteProductList'); // Get from DR_Extract_PrecheckData in IP PreCheck_loop
        Integer stSize = siteList.size();
        if(siteList!=null && siteList.size()>0){
            for(Object obj : siteList){
                map<String,Object> firstMap = (map<String,Object>)obj;
                map<String,Object> prodDataInfo = new map<String,Object>();
                List<Object> firstList = (List<Object>)firstMap.get('Products'); 
                Integer ip = 1;
                if(firstList!=null && firstList.size()>0){
                    for(Object  obj1 : firstList){
                    Map<String,Object> prodMap = (Map<String,Object>)obj1;
                    prodDataInfo.put(string.valueOf(prodMap.get('ProductName')),prodMap.get('Data')); // Map productname with what we get from prodMap and put in proddatainfo map
                    String pName = String.valueOf(prodMap.get('ProductName'));
                    List<Object> op = (List<Object>)prodDataInfo.get(pname);
                    if(op!=null && op.size()>0){
                        for(Object obj2 : op){
                            map<String,Object> secMap = (map<String,Object>)obj2;  
                            String pCode = (String)secMap.get('ProductCode'); // Get ProductCode
                            String lnType = (String)secMap.get('TechnologyName'); // Get technology name
                            String prodName = (String)secMap.get('Name'); // Get ProductName
                       // Put a null check on price and check for boolean PriceAvgFlag flag and Price is not 0 then only proceed
                            if(secMap.get('Price')!= null && secMap.get('PriceAvgFlag') == true && secMap.get('Price')!= 0){ 
                                Decimal productPrice = (Decimal)secMap.get('Price');
                                Integer count = 1;
                                if(prodAddProd.get(pCode)!= null){   //This will execute if in last iteration key value was added prodAddProd map
                                    productPrice= productPrice + (Decimal)prodAddProd.get(pCode);
                                    count = count + (Integer)priceCountMap.get(pCode);
                                }
                                prodAddProd.put(pCode,productPrice); // To have price of the respective bandwidth product
                                priceCountMap.put(pCode, count);// To have a count of sites
                                lineMap.put(pCode,lnType); // Will have line type against the product code
                                nameMap.put(pCode,prodName); // will have product name against the product code
                            }else
                      // This is for those products which will Price average Flag true but Price as 0
                            if(secMap.get('Price')!= null && secMap.get('PriceAvgFlag') == true && secMap.get('Price')== 0){
                                Integer newCount=1;
                                if(prodAddProd1.get(pCode)!=null){
                                    newCount= newCount + (Integer)prodAddProd1.get(pCode);
                                }
                                prodAddProd1.put(pCode,newCount);
                                nameMap.put(pCode,prodName);
                             }
                            for(String lnmp : lineMap.keySet()){
                                String tempvar = String.valueOf(lineMap.get(lnmp));
                                if(tempvar.containsIgnoreCase('fttx')){
                                    if(blMap.get(lnmp) != null){ // This will execute if blmap is not null
                                        if(blMap.get(lnmp) == true){
                                            blMap.put(lnmp,true);
                                        }else{
                                        blMap.put(lnmp,false);
                                        }
                                    }else{
                                        blMap.put(lnmp,true);
                                    }
                                }else{
                                    blMap.put(lnmp,false);
                                }
                            }
                            lineMap.clear();
                        }
                    }
                }
            }
        }
    }
           if(prodAddProd!=null){
                for(String priceKey1 : prodAddProd.keySet()){
                    if(prodAddProd.get(priceKey1) != null){
                        Decimal calculatedAvgPrice = (Decimal)prodAddProd.get(priceKey1)/(Integer)priceCountMap.get(priceKey1);// Sum of amount of product of all sites divided by no of sites
                        Decimal roundDecimalValue;
                        if((calculatedAvgPrice- calculatedAvgPrice.intValue())>=0.5){
                            roundDecimalValue=calculatedAvgPrice.round(System.RoundingMode.HALF_UP);// If average is having decimal value greater or equal to 0.5 like 500.5, we will make average as 501.0
                        }else
                        if((calculatedAvgPrice- calculatedAvgPrice.intvalue())<0.5){
                            roundDecimalValue=calculatedAvgPrice.round(System.RoundingMode.HALF_DOWN); //If average is having decimal value lees than 0.5 like 500.4, we will make average as 500.0
                        }
                        finalAvgPrices.put(priceKey1,roundDecimalValue);
                    }
                }
           }
           if(prodAddProd1!=null){
                for(String priceKey2:prodAddProd1.keyset()){ // Here we are put the average as 0 for the products having o price for all sites
                    if(prodAddProd1.get(priceKey2)==stSize){
                        finalAvgPrices.put(priceKey2,0); 
                    }        
                }
           }
           if(blMap!=null){
                for(String key1: blMap.keySet()){ // Here we are putting the average as 0 for the products having Linetype as Fttx for all sites
                    if(blMap.get(key1)==true){
                        finalAvgPrices.put(key1,0);        
                    }
                } 
           }
           if(finalAvgPrices!=null){
                List<MC_PreCheck_Result__c> precheckAvgPrices1 = new List<MC_PreCheck_Result__c>();
                Delete [Select id,MC_Product_Code__c,Price__c from MC_PreCheck_Result__c where RecordType.Name = 'AveragePrice' and Opportunity__c =:objId];
                for(String s : finalAvgPrices.keySet()){
                    if(s != null && finalAvgPrices.get(s) != null){
                        MC_PreCheck_Result__c preCheck1 = new MC_PreCheck_Result__c();
                        preCheck1.Name = nameMap.get(s);
                        preCheck1.Price__c = (decimal)finalAvgPrices.get(s);
                        preCheck1.MC_Product_Code__c = s;
                        preCheck1.RecordTypeId = Schema.SObjectType.MC_PreCheck_Result__c.getRecordTypeInfosByName().get('AveragePrice').getRecordTypeId();
                        preCheck1.Opportunity__c = objId;
                        precheckAvgPrices1.add(preCheck1);
                    }
                } 
                Insert precheckAvgPrices1;
                outputMap.put('Result','true');
                return outputMap;
            }else{
            outputMap.put('ErrorMessage','No average prices found');
            outputMap.put('Result','false');
            return outputMap;
            }
     }
        
}