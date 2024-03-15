public class SubscriptionEFSServices{   
    public static void GenerateButtonForProducts(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{
            string prodnameString = System.JSON.Serialize(inputMap.get('ProductNames'));
            List<Object> productList = (List<Object>)inputMap.get('Product');
            List<Object> productFinalList = uniqueProducts(productList);
            List<ProcuctNameWrapper> procuctNameList = (List<ProcuctNameWrapper>)JSON.deserialize(prodnameString, List<ProcuctNameWrapper>.class);
            List<String> pNameList = new List<String>();
            for(ProcuctNameWrapper pname : procuctNameList){
                pNameList.add(pname.Name);
            }
            outMap.put('ProductButtons', getButtonNames(pNameList));
            outMap.put('productFinalList', productFinalList);
        }catch(Exception e){
            outMap.put('Button  Exception', e.getStackTraceString());
        }
    }
    
     public static void GenerateButtonForAccessories(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{
            string prodnameString = System.JSON.Serialize(inputMap.get('NewAccessories'));
            List<ProcuctNameWrapper> procuctNameList = (List<ProcuctNameWrapper>)JSON.deserialize(prodnameString, List<ProcuctNameWrapper>.class);
            List<String> pNameList = new List<String>();
            for(ProcuctNameWrapper pname : procuctNameList){
                pNameList.add(pname.Name);
            }
            outMap.put('AccessoriesButtons', getButtonNames(pNameList));
        }catch(Exception e){
            outMap.put('Button  Exception', e.getStackTraceString());
        }
    }
    
    public static List<ButtonWrapper> getButtonNames(List<String> fullList){
        List<String> buttonList = new List<String>();
        Map<string, String> uniqeProductMap = new Map<string, String>();
        Map<string, Integer> btnMap = new Map<string, Integer>();
        Map<string, Integer> btnFinalMap = new Map<string, Integer>();
        Map<string, String> btnNumMap = new Map<string, String>();
        Set<string> btnNumSet = new Set<string>();
        Map<String, List<String>> brandTagMap = new Map<String, List<String>>();
        for(string productName : fullList){
            for(string key : TeliaSE_MC_SubscriptionBrand__c.getAll().keySet()){
                if(key != null && TeliaSE_MC_SubscriptionBrand__c.getAll().get(key) != null){
                    List<String> tagList = TeliaSE_MC_SubscriptionBrand__c.getAll().get(key).Brand_Tag__c.split(';');
                    if(tagList != null && tagList.size() > 0){
                        for(string tag : tagList){
                                if(productName.containsIgnoreCase(tag) &&  (uniqeProductMap == null || uniqeProductMap.get(productName) == null)){
                                    uniqeProductMap.put(productName, productName);
                                    if(btnMap.get(key) != null){
                                        Integer numberOfOcc = btnMap.get(key) + 1;
                                        btnMap.put(key, numberOfOcc);
                                        //btnNumMap.put(key, numberOfOcc);
                                    }else{
                                        btnMap.put(key, 1);
                                        //btnNumMap.put(key, 1);
                                    }
                                }
                        }
                    }
                }
            }
        }
        List<ButtonWrapper> ButtonWrapperList = new List<ButtonWrapper>();
        for(String key:btnMap.keySet()){
            ButtonWrapper bw = new ButtonWrapper();
            bw.Brand = key;
            bw.Occurence = btnMap.get(key);
            ButtonWrapperList.add(bw);
        }
        return ButtonWrapperList;
    }
    
    public static void getSubscriptions(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{
            Object AgreementNumber = (Object)inputMap.get('Madam');
            String AgreementJson = JSON.serialize(AgreementNumber);
            MadamAgreement MadamAgreement = (MadamAgreement)JSON.deserialize(AgreementJson, MadamAgreement.class);
            String Agreement = MadamAgreement.AgreementId;
            String sfagreement = MadamAgreement.sfAgreement;
            Set<String> allowedSubscriptions = new Set<String>();
            List<SubscriptionFilter__c> subscriptionFilter = new List<SubscriptionFilter__c>([select Name from SubscriptionFilter__c]); 
            for(SubscriptionFilter__c subfilter : subscriptionFilter){
                allowedSubscriptions.add(subfilter.Name);
            }
            List<vlocity_cmt__ContractLineItem__c> cli = new List<vlocity_cmt__ContractLineItem__c>([select Id,Name,vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c,TeliaSE_Approved_Price__c,vlocity_cmt__RecurringCharge__c,TeliaSE_Product_Object_Type__c from vlocity_cmt__ContractLineItem__c where (vlocity_cmt__ContractId__c in (Select id from contract where Agreement_Nr__c =: Agreement) AND TeliaSE_Product_Object_Type__c Like '%Mobile Offer Specification%' And vlocity_cmt__Product2Id__r.Name in :allowedSubscriptions  )]);
            Map<String, Decimal> sfprices = new Map<String, Decimal>();
            
            for(vlocity_cmt__ContractLineItem__c cliobj : cli){
                if(cliobj.TeliaSE_Approved_Price__c != null){
                    sfprices.put(cliobj.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c, cliobj.TeliaSE_Approved_Price__c);
                }else{
                    sfprices.put(cliobj.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c, cliobj.vlocity_cmt__RecurringCharge__c);
                }
            }
            
            object listPrices = (Object)inputMap.get('product');
            String listPricesJson = JSON.serialize(ListPrices);
            List<ListPriceWrapper> priceList = (List<ListPriceWrapper>)JSON.deserialize(ListPricesJson, List<ListPriceWrapper>.class);
            Map<String, String> priceListMap = new  Map<String, String>();
            for(ListPriceWrapper prices : priceList){
                priceListMap.put(prices.Subscription, prices.Listprice);
            }
            //Get EFS Node
            Object EFSResponse = (Object)inputMap.get('EFS');
            //Convert EFS Object to string
            string EFSResponseJSON = JSON.serialize(EFSResponse);
            //Convert EFS Object to string for JSOn conversion
            List<EFSWrapper> EFSWrappperList = (List<EFSWrapper>)JSON.deserialize(EFSResponseJSON, List<EFSWrapper>.class);
            
            //Set<String> subsSet = new  Set<String>();
            Map<String, String> subsPriceMap = new  Map<String, String>();
            
            //Build map of subscription type and respective price
            for(EFSWrapper efsObj : EFSWrappperList){
                subsPriceMap.put(efsObj.Subscriptions, efsObj.pricePlanFee);
            }            
            //Query on product2 where subscription type is related to madam response subscription type
            List<Product2> prodList = [SELECT Id, Productcode, Name, TeliaSE_Subscription_Type__c FROM Product2 WHERE TeliaSE_Subscription_Type__c in : subsPriceMap.keySet() AND TeliaSE_Object_Type_Name__c = 'Mobile Offer Specification' And Name in :allowedSubscriptions];
            System.debug('prodList-->'+prodList);
            List<String> keysavail = new List<String>();
            for(String key : subsPriceMap.keySet()) {
                for(Product2 p : prodList){
                    if(key == p.TeliaSE_Subscription_Type__c){
                        keysavail.add(key);
                    }
                }
            }
            
            
            for(String subsavail : keysavail){
                if(sfagreement == 'Y'){
                if(subsPriceMap.get(subsavail) == '' || subsPriceMap.get(subsavail) == null){
                    if(subsPriceMap.get(subsavail) == null){
                         subsPriceMap.put(subsavail, priceListMap.get(subsavail));
                    }
                    else{
                        String price = String.valueOf(sfprices.get(subsavail).format());
                        if(price.contains(',')) {
                            price = price.replace(',', '.');
                        }
                        subsPriceMap.put(subsavail, price);
                    } 
                }
                System.debug('efssubs in for-->'+subsavail+' value '+subsPriceMap.get(subsavail));
                }
                else{
                    subsPriceMap.put(subsavail, priceListMap.get(subsavail));
                }
            }
                            
            List<SubscriptionWrappper> subsWrappperList = new List<SubscriptionWrappper>(); 
            //Prepare response to show subscription on Omniscript
            for(Product2 prod : prodList){
                SubscriptionWrappper sw = new SubscriptionWrappper();
                sw.Subscriptioncode = prod.Productcode;
                sw.SubscriptionId = prod.Id;
                sw.SubscriptionName = prod.Name;
                sw.SubscriptionPrice = subsPriceMap.get(prod.TeliaSE_Subscription_Type__c);
                subsWrappperList.add(sw);
            }
            //Sending TotalNumberOfSubscription to OS
            outMap.put('TotalNumberOfSubscription', subsWrappperList.size());
            
            //Send subsWrappperList to Omniscript
            outMap.put('Subscription', subsWrappperList);
            
            System.debug('outMap-->'+outMap);
            
        }catch(Exception e){
            //if there is any exception, TotalNumberOfSubscription  will be sent as 0(Zero)
            outMap.put('TotalNumberOfSubscription', 0);
            outMap.put('ErrorFromSubscription', e.getMessage());
            system.debug('Exception at SubscriptionEFSServices.getSubscriptions : '+e.getStackTraceString());
        }
    }   

    public static List<Object> uniqueProducts(List<Object> productList){
        List<Object> productFinalList = new List<Object>();
        Map<String,Object> prodMap = new Map<String,Object>();
        for(Object obj : productList){
            Map<String,Object> eachProduct = (Map<String,Object>)obj;
            String productName = (String)eachProduct.get('Name');
            String trunName;
            if(productName.contains('MB')){
                trunName =  productName.substring(0, (productName.indexOf('MB')+2));
            }
            else if(productName.contains('GB')){
                trunName =  productName.substring(0, (productName.indexOf('GB')+2));
            }
            else if(productName.contains('TB')){
                trunName =  productName.substring(0, (productName.indexOf('TB')+2));
            }

            if(prodMap.get(trunName) == null){
                prodMap.put(trunName,eachProduct);
                eachProduct.put('Name', trunName);
                productFinalList.add(eachProduct);
            }
        }
        return productFinalList;
    }    
    
    //EFSWrapper for Madam request
    public class EFSWrapper
    {
        public String Subscriptions { get; set; }
        public String pricePlanFee { get; set; }
    }
    public class ListPriceWrapper
    {
        public String Subscription { get; set; }
        public String Listprice { get; set; }
    }
    public class MadamAgreement
    {
        public String AgreementId { get; set; }
        public String sfAgreement { get; set; }
    }
    //SubscriptionWrappper is for response to OS which contains combination of EFS Integration and SF subscription
    public class SubscriptionWrappper
    {
        public String Subscriptioncode { get; set; }
        public String SubscriptionName { get; set; }
        public String SubscriptionId { get; set; }
        public String SubscriptionPrice { get; set; }
    }
    public class ProcuctNameWrapper{
        public string Name{get; set;}
    }
    public class ButtonWrapper{
        public String Brand{get; set;}
        public Integer Occurence{get; set;}
    }
}