public class EFSCheckCallOfQuote {    
	public static void getSubscriptionsPrices(Map<String,Object> inputMap, Map<String,Object> outMap){
    	String QId;
        Boolean fromoffer = false;
        	QId = (String)inputMap.get('OfferQuoteId');
        if(QId == null || QId == ''){
        	QId = (String)inputMap.get('ContextId');
            fromoffer = true;
        }
        // Getting Subscription Name from QLI mapped with HW Products
        List<QuoteLineItem> Qli = new List<QuoteLineItem>([select id,Subscription__c,Product2.Name from QuoteLineItem where QuoteId =:QId and Subscription__c != null]);
        Map<String,String> qliefspris = new Map<String,String>();
        List<String>subs = new List<String>();
        for(QuoteLineItem q: Qli){
            qliefspris.put(q.id,q.Subscription__c);
            subs.add(q.Subscription__c);
        }
        //Getting Subscription type from Product object to compare it with EFS Response
        List<Product2> prodList = new List<Product2>([select Name,TeliaSE_Subscription_Type__c  from Product2  where Name in: subs and TeliaSE_Object_Type_Name__c = 'Mobile Offer Specification']);
        Map<String,String> subsmap = new Map<String,String>();
        for(Product2 prod : prodList){
            subsmap.put(prod.Name,prod.TeliaSE_Subscription_Type__c);
        }
        Object EFSResponse = (Object)inputMap.get('EFS');   
        string EFSResponseJSON = JSON.serialize(EFSResponse);
        // Wrapping EFS Response coming from Omniscript
        List<EFSWrapper> EFSWrappperList = (List<EFSWrapper>)JSON.deserialize(EFSResponseJSON, List<EFSWrapper>.class);
        //Creating a map with Subscription and price coming from EFS 
        Map<String, String> subsPriceMap = new  Map<String, String>();
        for(EFSWrapper efsObj : EFSWrappperList){
            subsPriceMap.put(efsObj.Subscriptions, efsObj.pricePlanFee);
        } 
        Object subsresponse = (Object)inputMap.get('Subscription');   
        string subsresponseJSON = JSON.serialize(subsresponse);
        // Response coming from Omniscript
        // collecting Contract Line items details(Subscripton Name and Price) to match the subscriptions from QLI
        List<subswrapper> subsList = (List<subswrapper>)JSON.deserialize(subsresponseJSON, List<subswrapper>.class);
        Map<String, String> contractSubsPriceMap = new  Map<String, String>();
        for(subswrapper subscription : subsList){
            contractSubsPriceMap.put(subscription.Name, subscription.Price);
        }  
        Map<String,String> pricesMap = new Map<String,String>();
        //Comparing QLImap and EFSmap
        for(String key : subsmap.keyset()){
            for(String key1 : subsPriceMap.keyset()){
                if(subsmap.get(key) == key1){
                    pricesMap.put(key,subsPriceMap.get(key));
                    
                }
                //if EFS Subscriptons are not matching then taking Price from CLI
                else{
                    for(String key2 : contractSubsPriceMap.keyset()){
                        if(key == key2){
                            pricesMap.put(key,contractSubsPriceMap.get(key2));
                        }
                    }
                }
            }
        }
        List<QuoteLineItem> qliListToUpdate = new List<QuoteLineItem>();
        for(String key : qliefspris.keyset()){
            for(string key1 : pricesMap.keyset()){
                if(qliefspris.get(key) == key1){
                    QuoteLineItem qliItem = new QuoteLineItem();
                    qliItem.id = key;
                    qliItem.TeliaSE_MC_EFS_Pris__c = pricesMap.get(qliefspris.get(key));
                    qliListToUpdate.add(qliItem);
                }
            }
        }
        update qliListToUpdate;
        if(fromoffer){
        	updateCartPrice(QId);
        }
    }
    public static void updateSubscriptionsPrices(Map<String,Object> inputMap, Map<String,Object> outMap){
        String QId = (String)inputMap.get('ContextId');
        // Getting Subscription Name from QLI mapped with HW Products
        List<QuoteLineItem> Qli = new List<QuoteLineItem>([select id,Subscription__c,Product2.Name from QuoteLineItem where QuoteId =:QId and Subscription__c != null]);
        Map<String,String> qliefspris = new Map<String,String>();
        List<String>subs = new List<String>();
        for(QuoteLineItem q: Qli){
            qliefspris.put(q.id,q.Subscription__c);
            subs.add(q.Subscription__c);
        }
        //Getting Subscription type from Product object to compare it with EFS Response
        List<Product2> prodList = new List<Product2>([select Name,TeliaSE_Subscription_Type__c  from Product2  where Name in: subs and TeliaSE_Object_Type_Name__c = 'Mobile Offer Specification']);
        Map<String,String> subsmap = new Map<String,String>();
        for(Product2 prod : prodList){
            subsmap.put(prod.Name,prod.TeliaSE_Subscription_Type__c);
        }
      
        Object subsresponse = (Object)inputMap.get('Subscription');   
        string subsresponseJSON = JSON.serialize(subsresponse);
        // Response coming from Omniscript
        // collecting Contract Line items details(Subscripton Name and Price) to match the subscriptions from QLI
        List<subswrapper> subsList = (List<subswrapper>)JSON.deserialize(subsresponseJSON, List<subswrapper>.class);
        Map<String, String> contractSubsPriceMap = new  Map<String, String>();
        for(subswrapper subscription : subsList){
            contractSubsPriceMap.put(subscription.Name, subscription.Price);
        }  
        Map<String,String> pricesMap = new Map<String,String>();
        //Comparing QLImap and EFSmap
        for(String key : subsmap.keyset()){           
                //if EFS Subscriptons are not matching then taking Price from CLI
                    for(String key2 : contractSubsPriceMap.keyset()){
                        if(key == key2){
                            pricesMap.put(key,contractSubsPriceMap.get(key2));
                        }
                    }
                
            
        }
        List<QuoteLineItem> qliListToUpdate = new List<QuoteLineItem>();
        for(String key : qliefspris.keyset()){
            for(string key1 : pricesMap.keyset()){
                if(qliefspris.get(key) == key1){
                    QuoteLineItem qliItem = new QuoteLineItem();
                    qliItem.id = key;
                    qliItem.TeliaSE_MC_EFS_Pris__c = pricesMap.get(qliefspris.get(key));
                    qliListToUpdate.add(qliItem);
                }
            }
        }
        update qliListToUpdate;
        updateCartPrice(QId);
    }
    //Referesh Pricing of Cart
    public static void updateCartPrice(Id QuoteId){
        Map<string, object> input = new Map<string, object>();
        input.put('cartId', String.valueOf(QuoteId));
        if(!Test.isRunningTest()){
            new vlocity_cmt.CpqAppHandler().invokeMethod('priceCart', input, input, input);
        }
    }
    public class EFSWrapper{
        public String Subscriptions { get; set; }
        public String pricePlanFee { get; set; }   
    }
    public class subswrapper{
        public string Name { get; set; }
        public string Price { get; set; }
    }
}