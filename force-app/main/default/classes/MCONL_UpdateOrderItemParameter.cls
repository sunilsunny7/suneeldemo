global class MCONL_UpdateOrderItemParameter{
    
    global static void updateParameter(String requestBody, String orderNumber, String orderNumberBasket){
    
        MCOnline_ParentBasket__c parentBasketObj = [select Id, TSCID__c, Is_Processed__c, Account__c, (SELECT  MCOnline_AttributeJSON__c, Id,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c, MCOnline_Contract__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c FROM MCOnline_Basket__r) from  MCOnline_ParentBasket__c where OrderNumber__c =:orderNumberBasket];
        Map<Id,Map<String, Attribute>> basketMap = new Map<Id,Map<String, Attribute>>();
        Map<Id,Map<String, Attribute>> ProductMap1 = new Map<Id,Map<String, Attribute>>();
        Map<String,Map<Id,Map<String, Attribute>>> ProductCombine = new Map<String,Map<Id,Map<String, Attribute>>>();

        Map<String, String> msisdnn = new Map<String, String>();
        Map<String, String> BasRelId = new Map<String, String>();
        for(MCOnline_Basket__c basketSFObj : parentBasketObj.MCOnline_Basket__r){
            if(basketSFObj != null && basketSFObj.MCOnline_AttributeJSON__c != null ){
                Map<String,Object> itemList = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                String RelationId = basketSFObj.Basket_Line_Relation_Id__c;
                List<Object> productList = new List<Object>();
                productList = (List<Object>)itemList.get('products');
                
                Map<String, Attribute> productMap = getItems(productList, RelationId);
                
                basketMap.put(basketSFObj.Id, productMap);
                ProductMap1.put(basketSFObj.Id, productMap);
                ProductCombine.put(basketSFObj.Basket_Line_Relation_Id__c,ProductMap1);
                
            }
        }
        
        // Below code will not work for release 1 records

        List<OrderItem> ordprod = [Select Id,OrderId,vlocity_cmt__OneTimeTotal__c,MCOnline_Basket_Relation_Id__c,vlocity_cmt__JSONAttribute__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__Product2Id__r.C2BC_Subcategory__c, vlocity_cmt__RecurringTotal__c,vlocity_cmt__RecurringCharge__c,MConline_List_Price__c,MCOnline_MSISDN__c, MCONL_Action_Code__c,MCOnline_UserName__c,vlocity_cmt__Product2Id__r.ProductCode, MCONL_multiSubscriptionAssetIdentifier__c from OrderItem where Order.Id =:orderNumber order by id];

        List<OrderItem> ordlist= new List<OrderItem>();
        List<vlocity_cmt__PricingVariable__c> pricingVarables=[select id,name from vlocity_cmt__PricingVariable__c where name in ('Recurring Monthly Std Price','One Time Std Price') limit 2];
        Id NRC_PRV=pricingVarables[0]!=null && pricingVarables[1]!=null && pricingVarables[0].name == 'One Time Std Price'?pricingVarables[0].id:pricingVarables[1].Id;
        Id MRC_PRV=pricingVarables[0]!=null && pricingVarables[1]!=null && pricingVarables[0].name == 'Recurring Monthly Std Price'?pricingVarables[0].id:pricingVarables[1].Id;
        List<vlocity_cmt__OrderPriceAdjustment__c> adjustments=new List<vlocity_cmt__OrderPriceAdjustment__c>();
        vlocity_cmt__OrderPriceAdjustment__c adjust;
        vlocity_cmt__OrderPriceAdjustment__c adjust1;
        List<Id> itemIds=new List<Id>();
        String orderIdAdjustment;
        String orderId=ordprod[0]?.Id;
        Map<String,Object> reqBody = null;
        for(MCOnline_Basket__c basketSFObj : parentBasketObj.MCOnline_Basket__r){
            if(basketMap != null){
                                                            for(Id basketID : basketMap.keyset()){
                                                                
                                                                for(String prodt : basketMap.get(basketID).keyset()){
                                                                    
                                                                    String prodcode = String.valueOf(basketMap.get(basketID).get(prodt).ProductCode);
                                                                    String MSISDNNumber = String.valueOf(basketMap.get(basketID).get(prodt).MSISDN);
                                                                    String UserName = String.valueOf(basketMap.get(basketID).get(prodt).userName);
                                                                    String BasketRelationID1 = String.valueOf(basketMap.get(basketID).get(prodt).basketRelationId);
                                                                    String Actionc = getProductParameter(basketMap, prodcode, basketID, BasketRelationID1);


                                                                    decimal nrc_amount= 0; 
                                                                    decimal mrc_amount=0;
                                                                    
                                                                    //Converted integer to decimal
                                                                    Map<String,decimal> amountMap=new Map<String,decimal>(); 
                                                                    amountMap=getAmount(basketMap, prodcode, basketID, MSISDNNumber);
                                                                    if(amountMap!=null && amountMap.size()>0){
                                                                        if(amountMap.containskey('nrc_amount'))
                                                                           nrc_amount=amountMap.get('nrc_amount');
                                                                        if(amountMap.containskey('amount'))
                                                                           mrc_amount=amountMap.get('amount');
                                                                    }
                                                                    
                                                                    if(ordprod != null){
                                                                        
                                                                        for(OrderItem ordprod1: ordprod)
                                                                        {
                                                                            String MSISDNNumber1 = ordprod1.MCOnline_MSISDN__c;
                                                                            String BasketrelationId = ordprod1.MCOnline_Basket_Relation_Id__c;
                                                                            if(BasketrelationId != null)
                                                                            {
                                                                                BasRelId.put('relation', BasketrelationId);
                                                                            }
                                                                            //UserName added
                                                                            if(ordprod1.vlocity_cmt__Product2Id__r.ProductCode ==prodcode && ordprod1.MCOnline_UserName__c==UserName){
                                                                                if(nrc_amount !=0)
                                                                                {
                                                                                    adjust=new vlocity_cmt__OrderPriceAdjustment__c();
                                                                                    adjust.vlocity_cmt__Amount__c=nrc_amount;
                                                                                    adjust.vlocity_cmt__PricingVariableId__c=NRC_PRV;
                                                                                    adjust.vlocity_cmt__OrderId__c=ordprod1.OrderId;
                                                                                    adjust.vlocity_cmt__OrderItemId__c=ordprod1.Id;
                                                                                    adjust.vlocity_cmt__Action__c='Add';
                                                                                    adjust.vlocity_cmt__AdjustmentValue__c=null;
                                                                                    adjust.vlocity_cmt__Source__c='Agent';
                                                                                    
                                                                                    adjustments.add(adjust);
                                                                                }
                                                                                if(mrc_amount !=0)
                                                                                {
                                                                                    adjust1=new vlocity_cmt__OrderPriceAdjustment__c(); 
                                                                                    adjust1.vlocity_cmt__Amount__c=mrc_amount;
                                                                                    adjust1.vlocity_cmt__PricingVariableId__c=MRC_PRV;
                                                                                    adjust1.vlocity_cmt__OrderId__c=ordprod1.OrderId;
                                                                                    adjust1.vlocity_cmt__OrderItemId__c=ordprod1.Id;
                                                                                    adjust1.vlocity_cmt__Action__c='Add';
                                                                                    adjust1.vlocity_cmt__AdjustmentValue__c=null;
                                                                                    adjust1.vlocity_cmt__Source__c='Agent';
                                            
                                                                                    adjustments.add(adjust1);
                                                                                }
                                                                               ordprod1.vlocity_cmt__OneTimeCharge__c = nrc_amount;
                                                                               ordprod1.vlocity_cmt__OneTimeTotal__c=nrc_amount;
                                                                               ordprod1.vlocity_cmt__RecurringCharge__c = mrc_amount;
                                                                               ordprod1.vlocity_cmt__RecurringTotal__c=mrc_amount;
                                                                            }

                                                                            if(ordprod1.vlocity_cmt__Product2Id__r.ProductCode ==prodcode && ordprod1.MCONL_Action_Code__c==null && BasRelId.get('relation')==BasketRelationID1)
                                                                            {
                                                                                ordprod1.MCONL_Action_Code__c = Actionc;   
                                                                            }
                                                                            ordlist.add(ordprod1);
                                                                        }
                                                                        // update ordlist;
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
            

        
        Map<Id,SObject> orderpro = new Map<Id,SObject>();
        orderpro.putall(ordlist);
        update orderpro.values();
        if(adjustments.size()>0)
        {
            //insert the adjustment to hold the values of recuring and one time charges in cart
            insert adjustments;
        }
        //Reprice the cart to evaluate recurring and one time totals
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
                    
        inputMap.put('items', itemIds);
        inputMap.put('cartId', orderId);
        inputMap.put('methodName', 'priceCart');
        
        vlocity_cmt.CpqAppHandler cpqAppHandlerService = new  vlocity_cmt.CpqAppHandler();
        try{
            cpqAppHandlerService.invokeMethod('priceCart', inputMap, outputMap, optionsMap);
        }Catch(Exception e)
        {}       
        updateAssetIdentifier(basketMap,orderNumber, orderNumberBasket);
    }
    

    public static Map<String,decimal> getAmount(Map<Id,Map<String, Attribute>> basketMap, String prodcode, Id basketID, String MSISDNNumber1){
        
        Map<String,decimal> amountMap=new Map<String,decimal>();

        if(basketMap != null && basketMap.get(basketID) != null){
            for(String prodtt : basketMap.get(basketID).keyset()){
                if(prodtt == prodcode){
                    if(basketMap.get(basketID).get(prodtt).nrc_amount!=null)


                       amountMap.put('nrc_amount', decimal.valueOf(basketMap.get(basketID).get(prodtt).nrc_amount));
                    if(basketMap.get(basketID).get(prodtt).mrc_amount!=null)
                       amountMap.put('amount', decimal.valueOf(basketMap.get(basketID).get(prodtt).mrc_amount));



                }
            }
        }
        return amountMap;
    }




    public static String getProductParameter(Map<Id,Map<String, Attribute>> basketMap, String prodcode, Id basketID, String BasketRelationID1){

        if(basketMap != null && basketMap.get(basketID) != null){
            for(String prodtt : basketMap.get(basketID).keyset()){
                if(prodtt == prodcode){
                    if(String.valueOf(basketMap.get(basketID).get(prodtt).basketRelationId)==BasketRelationID1){
                        String prodParameter = String.valueOf(basketMap.get(basketID).get(prodtt).actionCode);
                        return prodParameter;
                    }
                }
            }
        }


        return null;
    }
    
    public static Map<String, Attribute> getItems(List<Object> items, String RelationId){
        Map<String, Attribute> productsMap = new Map<String, Attribute>();

        Map<String, String> msisdnaddon = new Map<String, String>();

        if(items != null){
            for(Object lineItemObj : items){
                Map<String, Object> recObj1Map = ( Map<String, Object>)lineItemObj;
                Map<String, Object> attributesMap = (Map<String, Object>)recObj1Map.get('attributes');
                if(recObj1Map != null){
                    Product itemObj = new Product();
                    Attribute attributesObj = new Attribute();
                    itemObj.ProductCode = String.valueOf(recObj1Map.get('productCode'));
                    attributesObj.ProductCode = String.valueOf(recObj1Map.get('productCode'));
                    attributesObj.actionCode = String.valueOf(recObj1Map.get('actionCode'));
                    attributesObj.basketRelationId = RelationId;


                    if(recObj1Map.containskey('C2BC_Category')){
                        attributesObj.C2BCCategory = String.valueOf(recObj1Map.get('C2BC_Category'));
                    }
                    if(recObj1Map.containskey('C2BC_Subcategory')){
                        attributesObj.C2BCSubCategory = String.valueOf(recObj1Map.get('C2BC_Subcategory'));
                    }






                    if(recObj1Map.containskey('nrc_amount')){
                       attributesObj.nrc_amount= String.valueOf(recObj1Map.get('nrc_amount'));
                    }
                    if(recObj1Map.containskey('amount')){
                      attributesObj.mrc_amount = String.valueOf(recObj1Map.get('amount'));
                    }



                    if(attributesMap != null){
                        attributesObj.MSISDN = String.valueOf(attributesMap.get('MSISDN'));

                        attributesObj.commitmentPeriod = String.valueOf(attributesMap.get('commitmentPeriod'));

                        attributesObj.userName = String.valueOf(attributesMap.get('userName'));



						   if(attributesMap != null && attributesObj.MSISDN!=null && attributesObj.userName !=null){
                        		msisdnaddon.put('msisdn',attributesObj.MSISDN);
                           }
                    }
                    if(attributesMap != null && String.valueOf(recObj1Map.get('C2BC_Subcategory')) == 'mdsecondary'){
                        attributesObj.MSISDN = msisdnaddon.get('msisdn');
                    }
                    if(attributesMap == null){
                        attributesObj.MSISDN = msisdnaddon.get('msisdn');
                    }
                    //attributesObj.billingAccount = String.valueOf(attributesMap.get('Billing Account Online'));
                    itemObj.Attributes = attributesObj;
                    productsMap.put(itemObj.ProductCode, attributesObj);
                }
            }
        }
        return productsMap;
    }
    

    
    global static void updateAssetIdentifier(Map<Id,Map<String, Attribute>> basketMap, String orderNumber, String orderNumberBasket){
        MCOnline_ParentBasket__c parentBasketObject = [select Id, Name,TSCID__c, Is_Processed__c, Account__c, (SELECT  MCOnline_AttributeJSON__c,Name, Id,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c, MCOnline_Contract__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c FROM MCOnline_Basket__r) from  MCOnline_ParentBasket__c where OrderNumber__c =:orderNumberBasket];
        List<OrderItem> ordproduct = [Select Id,vlocity_cmt__Product2Id__r.ProductCode,MCOnline_Basket_Relation_Id__c,MCOnline_CommitmentPeriod__c, MCOnline_UserName__c,MCOnline_MSISDN__c, MCONL_multiSubscriptionAssetIdentifier__c,vlocity_cmt__RootItemId__c from OrderItem where Order.Id =:orderNumber order by id];
        Map<String, String> msisdnaddon1 = new Map<String, String>();
        Map<String, String> commitmentaddon = new Map<String, String>();

        Map<String,String> rootitemIdVSMSISDN=new Map<String,String>();
        Map<String,String> rootitemIdVSCommitment=new Map<String,String>();

        for(MCOnline_Basket__c basketSFObj : parentBasketObject.MCOnline_Basket__r)
        {
            if(basketSFObj != null && basketSFObj.MCOnline_AttributeJSON__c != null )
            {
                Map<String,Object> itemList1 = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                String RelationId1 = basketSFObj.Basket_Line_Relation_Id__c;
                List<Object> productList1 = (List<Object>)itemList1.get('products');
                for(Object obj: productList1)
                {
                    Map<String, Object> recObj = ( Map<String, Object>)obj;
                    Map<String, Object> attributeMap = (Map<String, Object>)recObj.get('attributes');
                    if(attributeMap != null)
                    {
                        if(String.valueOf(recObj.get('C2BC_Subcategory')) == 'voice' && String.valueOf(attributeMap.get('MSISDN')) != null && RelationId1 !=null)
                        {
                            msisdnaddon1.put(RelationId1, String.valueOf(attributeMap.get('MSISDN')));
                        }
                        if(String.valueOf(recObj.get('C2BC_Subcategory')) == 'voice' && String.valueOf(attributeMap.get('commitmentPeriod')) != null && RelationId1 !=null)
                        {
                            commitmentaddon.put(RelationId1, String.valueOf(attributeMap.get('commitmentPeriod')));
                        }
                    }
                }
            }
        }
        List<OrderItem> ordlist= new List<OrderItem>();
        List<OrderItem> ordlist1= new List<OrderItem>();
        for(OrderItem ordproduct1 : ordproduct){
            if(ordproduct1.MCONL_multiSubscriptionAssetIdentifier__c == null &&  ordproduct1.MCOnline_Basket_Relation_Id__c !=null && msisdnaddon1 != null)
            {
                ordproduct1.MCONL_multiSubscriptionAssetIdentifier__c = msisdnaddon1.get(ordproduct1.MCOnline_Basket_Relation_Id__c);
                if(ordproduct1.vlocity_cmt__RootItemId__c!=null && ordproduct1.MCONL_multiSubscriptionAssetIdentifier__c != null)
                {
                    rootitemIdVSMSISDN.put(ordproduct1.vlocity_cmt__RootItemId__c, ordproduct1.MCONL_multiSubscriptionAssetIdentifier__c);
                }
            }
            if(ordproduct1.MCOnline_MSISDN__c == null && ordproduct1.MCOnline_Basket_Relation_Id__c !=null && msisdnaddon1 != null)
            {
                ordproduct1.MCOnline_MSISDN__c = msisdnaddon1.get(ordproduct1.MCOnline_Basket_Relation_Id__c);
            }
            if(ordproduct1.MCOnline_CommitmentPeriod__c == null && ordproduct1.MCOnline_Basket_Relation_Id__c !=null && commitmentaddon != null)
            {
                ordproduct1.MCOnline_CommitmentPeriod__c = commitmentaddon.get(ordproduct1.MCOnline_Basket_Relation_Id__c);
                if(ordproduct1.vlocity_cmt__RootItemId__c!=null && ordproduct1.MCOnline_CommitmentPeriod__c != null)
                {
                    rootitemIdVSCommitment.put(ordproduct1.vlocity_cmt__RootItemId__c, ordproduct1.MCOnline_CommitmentPeriod__c);
                }
            }
            ordlist.add(ordproduct1);
        }
        Map<Id,SObject> orderi = new Map<Id,SObject>();
        orderi.putall(ordlist);
        update orderi.values();
        
        for(OrderItem oItem : ordproduct)
        {
            if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.vlocity_cmt__RootItemId__c!='' && oItem != null && (oItem.MCOnline_MSISDN__c == null || oItem.MCONL_multiSubscriptionAssetIdentifier__c == null || oItem.MCOnline_CommitmentPeriod__c == null)){
                //if(rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c)){
                if(oItem.MCOnline_MSISDN__c == null && rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c) && rootitemIdVSMSISDN != null){
                    oItem.MCOnline_MSISDN__c = rootitemIdVSMSISDN.get(oItem.vlocity_cmt__RootItemId__c);
                }
                if(oItem.MCONL_multiSubscriptionAssetIdentifier__c == null && rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c) && rootitemIdVSMSISDN != null){
                    oItem.MCONL_multiSubscriptionAssetIdentifier__c = rootitemIdVSMSISDN.get(oItem.vlocity_cmt__RootItemId__c);
                }
                if(oItem.MCOnline_CommitmentPeriod__c == null && rootitemIdVSCommitment!=null && rootitemIdVSCommitment.containskey(oItem.vlocity_cmt__RootItemId__c)){
                    oItem.MCOnline_CommitmentPeriod__c = rootitemIdVSCommitment.get(oItem.vlocity_cmt__RootItemId__c);
                }
                ordlist1.add(oItem);
                //}
            }
        }
        Map<Id,SObject> orderii = new Map<Id,SObject>();
        orderii.putall(ordlist1);
        update orderii.values();
    }
    
    public class Product{
        public Attribute Attributes{get; set;}
        public string ProductCode{get; set;}
    }
    public class Attribute{
        public string ProductCode{get; set;}
        public string MSISDN{get; set;}
        public string actionCode{get; set;}
        public string basketRelationId {get; set;}
        public string userName {get; set;}
        public string nrc_amount {get; set;}
        public string mrc_amount {get; set;}



        public String C2BCCategory {get; set;}
        public String C2BCSubCategory {get; set;}
        public String commitmentPeriod {get; set;}




    }
}