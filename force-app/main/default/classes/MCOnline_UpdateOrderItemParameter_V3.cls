/****************************************************************************************************************************
* @author                 Binamra
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>, Aparajita Banerjee <aparajita.a.banerjee@capgemini.com>
* @maintainedBy           Binamra
* @version                3.0
* @modified               2021-08-12 => Added adjustment logic for hardware pricing
                          2022-04-13 => Added hardware price validation post checkout
******************************************************************************************************************************/
global class MCOnline_UpdateOrderItemParameter_V3
{
    public static Map<String, String> updatedAttributeJSON = new Map<String, String>();
    public static Map<String, String> basketIdSet = new Map<String, String>();
    global static void updateParameter(String orderNumber, Id OrderID)
    {
        List<MCOnline_Basket__c> parentBasketObj = [SELECT  Name, MCOnline_AttributeJSON__c, MCOnline_Price_Validation_Message__c,Id,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c, MCOnline_Contract__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c,MConline_Offer_ActionCode__c FROM MCOnline_Basket__c where Order__c = :orderNumber];
        checkPriceMatrix(parentBasketObj);
        List<MCOnline_Basket__c> updateBasketList = new List<MCOnline_Basket__c>();
        if(basketIdSet !=null)
        {
            for(MCOnline_Basket__c bas: parentBasketObj)
            {
                if(bas !=null && basketIdSet.containsKey(bas.Id))
                {
                    bas.MCOnline_Price_Validation_Message__c = String.valueOf(basketIdSet.get(bas.Id));
                    updateBasketList.add(bas);
                }else{
                    bas.MCOnline_Price_Validation_Message__c = '';
                    updateBasketList.add(bas);
                }
            }
            if(updateBasketList.size() > 0)
            {
                update updateBasketList;
            }
        }
        Map<Id,Map<String, Attribute>> basketMap = new Map<Id,Map<String, Attribute>>();
        Map<Id,Map<String, Attribute>> ProductMap1 = new Map<Id,Map<String, Attribute>>();
        Map<String, Object> mapOffer = new Map<String, Object>();
        Map<String,Map<Id,Map<String, Attribute>>> ProductCombine = new Map<String,Map<Id,Map<String, Attribute>>>();
        Map<String, String> msisdnn = new Map<String, String>();
        Map<String, String> BasRelId = new Map<String, String>();
        updateOrderLine(OrderID);
        for(MCOnline_Basket__c basketSFObj : parentBasketObj)
        {
            if(basketSFObj != null && basketSFObj.MCOnline_AttributeJSON__c != null )
            {
                Map<String,Object> itemList = new Map<String,Object>();
                if(updatedAttributeJSON !=null && updatedAttributeJSON.containsKey(basketSFObj.Id))
                {
                    itemList = (Map<String,Object>)JSON.deserializeUntyped(updatedAttributeJSON.get(basketSFObj.Id));
                }else
                {
                    itemList = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                }
                String RelationId = basketSFObj.Basket_Line_Relation_Id__c;
                String minibasketName = '';
                minibasketName = (basketSFObj.Name != null) ? basketSFObj.Name : null;
                List<Object> productList = new List<Object>();
                List<Object> productList1 = new List<Object>();
                productList = (List<Object>)itemList.get('products');
                mapOffer.put('productCode', String.valueOf(basketSFObj.MCOnline_OfferCode__c));
                mapOffer.put('actionCode', String.valueOf(basketSFObj.MConline_Offer_ActionCode__c));
                productList.add(mapOffer);
                productList1 = (List<Object>)productList;
                Map<String, Attribute> productMap = getItems(productList1, RelationId, minibasketName);
                basketMap.put(basketSFObj.Id, productMap);
                ProductMap1.put(basketSFObj.Id, productMap);
                ProductCombine.put(basketSFObj.Basket_Line_Relation_Id__c,ProductMap1);    
            }
        }
        
        // Below code will not work for release 1 records
        List<OrderItem> ordprod = [Select Id,OrderId,MCOnline_RelationWithBasket__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__JSONAttribute__c,vlocity_cmt__OneTimeCharge__c,MCOnline_Basket_Relation_Id__c,vlocity_cmt__Product2Id__r.C2BC_Category__c, vlocity_cmt__Product2Id__r.C2BC_Subcategory__c, vlocity_cmt__RecurringTotal__c,vlocity_cmt__RecurringCharge__c,MConline_List_Price__c,MCOnline_MSISDN__c, MCONL_Action_Code__c,MCOnline_UserName__c,vlocity_cmt__Product2Id__r.ProductCode, MCONL_multiSubscriptionAssetIdentifier__c from OrderItem where Order.Id =:OrderID];
        List<OrderItem> ordlist= new List<OrderItem>();
        Boolean isHardware = false;
        List<vlocity_cmt__PricingVariable__c> pricingVarables=[select id,name from vlocity_cmt__PricingVariable__c where name in ('Recurring Monthly Std Price','One Time Std Price') limit 2];
        Id NRC_PRV=pricingVarables[0]!=null && pricingVarables[1]!=null && pricingVarables[0].name == 'One Time Std Price'?pricingVarables[0].id:pricingVarables[1].Id;
        Id MRC_PRV=pricingVarables[0]!=null && pricingVarables[1]!=null && pricingVarables[0].name == 'Recurring Monthly Std Price'?pricingVarables[0].id:pricingVarables[1].Id;
        List<vlocity_cmt__OrderPriceAdjustment__c> adjustments=new List<vlocity_cmt__OrderPriceAdjustment__c>();
        vlocity_cmt__OrderPriceAdjustment__c adjust;
        vlocity_cmt__OrderPriceAdjustment__c adjust1;
        Set<Id> itemIds=new Set<Id>();
        String orderIdAdjustment;
        for(MCOnline_Basket__c basketSFObj : parentBasketObj)
        {
            Map<String,Object> reqBody = null;
            if(basketMap != null)
            {
                for(Id basketID : basketMap.keyset())
                {
                    for(String prodt : basketMap.get(basketID).keyset())
                    {
                        String prodcode = String.valueOf(basketMap.get(basketID).get(prodt).ProductCode);
                        String MSISDNNumber = String.valueOf(basketMap.get(basketID).get(prodt).MSISDN);
                        String UserName = String.valueOf(basketMap.get(basketID).get(prodt).userName);
                        String BasketRelationID1 = String.valueOf(basketMap.get(basketID).get(prodt).basketRelationId);
                        String BasketName = String.valueOf(basketMap.get(basketID).get(prodt).basketName);
                        String Actionc = getProductParameter(basketMap, prodcode, basketID, BasketRelationID1+';'+BasketName);
                        if(String.isBlank(Actionc) || Actionc == null)
                        {
                            Actionc = 'Add';
                        }
                        decimal nrc_amount= 0; 
                        decimal mrc_amount=0;
                        //Converted integer to decimal
                        Map<String,decimal> amountMap=new Map<String,decimal>(); 
                        amountMap=getAmount(basketMap, prodcode, basketID, MSISDNNumber, BasketRelationID1+';'+BasketName);
                        if(amountMap!=null && amountMap.size()>0)
                        {
                            if(amountMap.containskey('nrc_amount'))
                                nrc_amount=amountMap.get('nrc_amount');
                            if(amountMap.containskey('amount'))
                                mrc_amount=amountMap.get('amount');
                        }
                        if(ordprod != null)
                        {
                            for(OrderItem ordprod1: ordprod)
                            {
                                if(ordprod1.vlocity_cmt__Product2Id__r.C2BC_Category__c == 'goods')
                                {
                                    isHardware = true;
                                }
                                itemIds.add(ordprod1.Id);
                                //String MSISDNNumber1 = MCOnline_OrderProcessorSplitBasket_V2.getAttribute('MSISDN', ordprod1.vlocity_cmt__AttributeSelectedValues__c);
                                String MSISDNNumber1 = ordprod1.MCOnline_MSISDN__c;
                                String BasketrelationId = ordprod1.MCOnline_Basket_Relation_Id__c;
                                String UniqueBasketRelationId = ordprod1.MCOnline_RelationWithBasket__c;
                                //UserName added
                                if(ordprod1.vlocity_cmt__Product2Id__r.ProductCode ==prodcode && UniqueBasketRelationId==BasketRelationID1+';'+BasketName)//ordprod1.MCOnline_UserName__c==UserName
                                {
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
                                    if(mrc_amount !=0 && Actionc != null && !String.isBlank(Actionc) && (Actionc.equalsIgnoreCase('Add') || Actionc.equalsIgnoreCase('Update')))
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
                                    }else if(Actionc != null && !String.isBlank(Actionc) && !(Actionc.equalsIgnoreCase('Add') || Actionc.equalsIgnoreCase('Update')))
                                    {
                                        adjust1=new vlocity_cmt__OrderPriceAdjustment__c(); 
                                        adjust1.vlocity_cmt__Amount__c=0;
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
                                    //changes as per Manageflow
                                    if(Actionc != null && !String.isBlank(Actionc) && !(Actionc.equalsIgnoreCase('Add') || Actionc.equalsIgnoreCase('Update')))
                                    {
                                        ordprod1.vlocity_cmt__RecurringCharge__c = 0;
                                        ordprod1.vlocity_cmt__RecurringTotal__c=0;
                                    }else{
                                        ordprod1.vlocity_cmt__RecurringCharge__c = mrc_amount;
                                        ordprod1.vlocity_cmt__RecurringTotal__c=mrc_amount;
                                    }
                                }
                                if(ordprod1.vlocity_cmt__Product2Id__r.ProductCode ==prodcode && ordprod1.MCONL_Action_Code__c==null && UniqueBasketRelationId==BasketRelationID1+';'+BasketName)
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
                    
        inputMap.put('items', new List<Id>(itemIds));
        inputMap.put('cartId', OrderID);
        inputMap.put('methodName', 'priceCart');
        
        vlocity_cmt.CpqAppHandler cpqAppHandlerService = new  vlocity_cmt.CpqAppHandler();
        try{
        //if(isHardware)
        //{
            cpqAppHandlerService.invokeMethod('priceCart', inputMap, outputMap, optionsMap);
        //}
        }catch(Exception e)
        {
            
        }
        
        updateAssetIdentifier(basketMap,OrderID,orderNumber);
      
    }
    //This method is for double protection for updating OrderItem 
    public static void updateOrderLine(Id OrderID)
    {
        Map<String, Checkout_Offer__c> offerMap = Checkout_Offer__c.getAll();
        String portIn = (offerMap.get('PORTIN_PROCESS').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS').OfferCode__c: null;
        String portInData = (offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c: null;
        String transferOffer = (offerMap.get('TRANSFER_PROCESS').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS').OfferCode__c: null;
        String transferOfferData = (offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c: null;
        Map<String,String> rootitemIdVSMSISDN=new Map<String,String>();
        Map<String,String> rootitemIdVSMSISDN1=new Map<String,String>();
        List<OrderItem> oItemUpdateList = new List<OrderItem>();
        Map<String,String> rootitemIdVSCommitment=new Map<String,String>();
        Map<String,String> rootitemIdVSRelation= new Map<String,String>();
        Map<String,String> rootitemIdVSRelationBasket= new Map<String,String>();
        List<OrderItem> oItemList = new List<OrderItem>();
        oItemList = [Select id,vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__Product2Id__r.C2BC_Subcategory__c,vlocity_cmt__Product2Id__r.ProductCode, TeliaSE_BillingAccountOnline__c,MCOnline_RelationWithBasket__c,MCOnline_Basket_Relation_Id__c, MCOnline_MSISDN__c, MCOnline_CommitmentPeriod__c, MCOnline_CommitmentUnit__c, MCOnline_UserName__c, vlocity_cmt__RootItemId__c, MCONL_multiSubscriptionAssetIdentifier__c From OrderItem where Order.Id =:OrderID];
        Set<String> orderItems = new Set<String>();
        for(OrderItem item1 : oItemList){
            orderItems.add(item1.vlocity_cmt__Product2Id__r.ProductCode);
        }
        for(OrderItem oItem : oItemList)
        {
            string msisdn = null;
            string msisdn1 = null;
            if(oItem != null)
            {
                string jsonAttribute = oItem.vlocity_cmt__AttributeSelectedValues__c, jsonOfferAttribute =oItem.vlocity_cmt__JSONAttribute__c;
                if(jsonAttribute != null || jsonOfferAttribute != null)
                {
                    if(MCOnline_OrderProcessor_V3.getAttribute('BILLING_ACCOUNT', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                    {
                        oItem.TeliaSE_BillingAccountOnline__c = MCOnline_OrderProcessor_V3.getAttribute('BILLING_ACCOUNT', oItem.vlocity_cmt__AttributeSelectedValues__c);
                    }
                    else if(MCOnline_OrderProcessor_V3.getJsonAttribute('BILLING_ACCOUNT', oItem.vlocity_cmt__JSONAttribute__c) != null)
                    {
                        oItem.TeliaSE_BillingAccountOnline__c = MCOnline_OrderProcessor_V3.getJsonAttribute('BILLING_ACCOUNT', oItem.vlocity_cmt__JSONAttribute__c);
                    }
                    if(MCOnline_OrderProcessor_V3.getAttribute('Current_MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c) != null || MCOnline_OrderProcessor_V3.getAttribute('MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                    {
                        if(MCOnline_OrderProcessor_V3.getAttribute('Current_MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c) != null && ((orderItems.contains(portIn) && orderItems.contains(portInData)) || (oItem.vlocity_cmt__Product2Id__r.ProductCode == transferOfferData)))
                        {
                            oItem.MCOnline_MSISDN__c = MCOnline_OrderProcessor_V3.getAttribute('Current_MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c);
                        }
                        else if(MCOnline_OrderProcessor_V3.getAttribute('MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                        {
                            oItem.MCOnline_MSISDN__c = MCOnline_OrderProcessor_V3.getAttribute('MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c);
                        }
                    }
                    else if(MCOnline_OrderProcessor_V3.getJsonAttribute('Current_MSISDN', oItem.vlocity_cmt__JSONAttribute__c) != null || MCOnline_OrderProcessor_V3.getJsonAttribute('MSISDN', oItem.vlocity_cmt__JSONAttribute__c) != null)
                    {
                        if(MCOnline_OrderProcessor_V3.getJsonAttribute('Current_MSISDN', oItem.vlocity_cmt__JSONAttribute__c) != null && ((orderItems.contains(portIn) && orderItems.contains(portInData)) || (oItem.vlocity_cmt__Product2Id__r.ProductCode == transferOfferData)))
                        {
                            oItem.MCOnline_MSISDN__c = MCOnline_OrderProcessor_V3.getJsonAttribute('Current_MSISDN', oItem.vlocity_cmt__JSONAttribute__c);
                        }
                        else if(MCOnline_OrderProcessor_V3.getJsonAttribute('MSISDN', oItem.vlocity_cmt__JSONAttribute__c) != null)
                        {
                            oItem.MCOnline_MSISDN__c = MCOnline_OrderProcessor_V3.getJsonAttribute('MSISDN', oItem.vlocity_cmt__JSONAttribute__c);
                        }
                    }
                    
                    if(MCOnline_OrderProcessor_V3.getAttribute('Relation_Id', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                    {
                        oItem.MCOnline_RelationWithBasket__c = MCOnline_OrderProcessor_V3.getAttribute('Relation_Id', oItem.vlocity_cmt__AttributeSelectedValues__c);
                        if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.MCOnline_RelationWithBasket__c !=null){
                            rootitemIdVSRelationBasket.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_RelationWithBasket__c);
                        }
                        List<String> RelationId = MCOnline_OrderProcessor_V3.getAttribute('Relation_Id', oItem.vlocity_cmt__AttributeSelectedValues__c).split(';');
                        oItem.MCOnline_Basket_Relation_Id__c = (RelationId != null && RelationId.size() > 0) ? RelationId[0] : null;
                        if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.MCOnline_Basket_Relation_Id__c !=null)
                        {
                            rootitemIdVSRelation.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_Basket_Relation_Id__c);
                        }
                    }else if(MCOnline_OrderProcessor_V3.getJsonAttribute('Relation_Id', oItem.vlocity_cmt__JSONAttribute__c) != null)
                    {
                        oItem.MCOnline_RelationWithBasket__c = MCOnline_OrderProcessor_V3.getJsonAttribute('Relation_Id', oItem.vlocity_cmt__JSONAttribute__c);
                        if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.MCOnline_RelationWithBasket__c !=null){
                            rootitemIdVSRelationBasket.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_RelationWithBasket__c);
                        }
                        List<String> RelationId = MCOnline_OrderProcessor_V3.getJsonAttribute('Relation_Id', oItem.vlocity_cmt__JSONAttribute__c).split(';');
                        oItem.MCOnline_Basket_Relation_Id__c = (RelationId != null && RelationId.size() > 0) ? RelationId[0] : null;
                        if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.MCOnline_Basket_Relation_Id__c !=null)
                        {
                            rootitemIdVSRelation.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_Basket_Relation_Id__c);
                        }
                    }
                    if(MCOnline_OrderProcessor_V3.getAttribute('TELIA_COMM_PERIOD', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                    {
                        oItem.MCOnline_CommitmentPeriod__c = MCOnline_OrderProcessor_V3.getAttribute('TELIA_COMM_PERIOD', oItem.vlocity_cmt__AttributeSelectedValues__c);
                    }
                    else if(MCOnline_OrderProcessor_V3.getJsonAttribute('TELIA_COMM_PERIOD', oItem.vlocity_cmt__JSONAttribute__c) != null)
                    {
                        oItem.MCOnline_CommitmentPeriod__c = MCOnline_OrderProcessor_V3.getJsonAttribute('TELIA_COMM_PERIOD', oItem.vlocity_cmt__JSONAttribute__c);
                    }
                    if(MCOnline_OrderProcessor_V3.getAttribute('TELIA_COMM_UNIT', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                    {
                        oItem.MCOnline_CommitmentUnit__c = MCOnline_OrderProcessor_V3.getAttribute('TELIA_COMM_UNIT', oItem.vlocity_cmt__AttributeSelectedValues__c);
                    }
                    else if(MCOnline_OrderProcessor_V3.getJsonAttribute('TELIA_COMM_UNIT', oItem.vlocity_cmt__JSONAttribute__c) != null)
                    {
                        oItem.MCOnline_CommitmentUnit__c = MCOnline_OrderProcessor_V3.getJsonAttribute('TELIA_COMM_UNIT', oItem.vlocity_cmt__JSONAttribute__c);
                    }
                    if(MCOnline_OrderProcessor_V3.getAttribute('User_name', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                    {
                        oItem.MCOnline_UserName__c = MCOnline_OrderProcessor_V3.getAttribute('User_name', oItem.vlocity_cmt__AttributeSelectedValues__c);
                    }
                    else if(MCOnline_OrderProcessor_V3.getJsonAttribute('User_name', oItem.vlocity_cmt__JSONAttribute__c) != null)
                    {
                        oItem.MCOnline_UserName__c = MCOnline_OrderProcessor_V3.getJsonAttribute('User_name', oItem.vlocity_cmt__JSONAttribute__c);
                    }
                    if(oItem.MCOnline_MSISDN__c!='' && oItem.MCOnline_MSISDN__c != null && oItem.vlocity_cmt__RootItemId__c!=null && oItem.vlocity_cmt__RootItemId__c!='' && oItem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c != 'datasim' && oItem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c != 'mdsecondary')
                    {
                        if(orderItems.contains(portIn) && orderItems.contains(portInData)){
                            if(MCOnline_OrderProcessor_V3.getAttribute('Temporary_MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                            {
                                oItem.MCONL_multiSubscriptionAssetIdentifier__c = MCOnline_OrderProcessor_V3.getAttribute('Temporary_MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c);
                            }
                            else if(MCOnline_OrderProcessor_V3.getJsonAttribute('Temporary_MSISDN', oItem.vlocity_cmt__JSONAttribute__c) != null)
                            {
                                oItem.MCONL_multiSubscriptionAssetIdentifier__c = MCOnline_OrderProcessor_V3.getJsonAttribute('Temporary_MSISDN', oItem.vlocity_cmt__JSONAttribute__c);
                            }
                            msisdn1 = oItem.MCONL_multiSubscriptionAssetIdentifier__c;
                            rootitemIdVSMSISDN1.put(oItem.vlocity_cmt__RootItemId__c,msisdn1);
                            msisdn = oItem.MCOnline_MSISDN__c;
                        }else{
                            oItem.MCONL_multiSubscriptionAssetIdentifier__c = oItem.MCOnline_MSISDN__c;
                            msisdn = oItem.MCOnline_MSISDN__c;
                        }
                        rootitemIdVSMSISDN.put(oItem.vlocity_cmt__RootItemId__c,msisdn);
                        if(oItem.MCOnline_CommitmentPeriod__c != null){
                            rootitemIdVSCommitment.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_CommitmentPeriod__c);
                        }
                    }
                }
                oItemUpdateList.add(oItem);
            }
        }
        Map<Id,SObject> orderpro = new Map<Id,SObject>();
        orderpro.putall(oItemUpdateList);
        update orderpro.values();
        oItemUpdateList.clear();
        for(OrderItem oItem : oItemList){
            if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.vlocity_cmt__RootItemId__c!='' && oItem != null && (oItem.MCOnline_MSISDN__c == null || oItem.MCONL_multiSubscriptionAssetIdentifier__c == null || oItem.MCOnline_CommitmentPeriod__c == null || oItem.MCOnline_Basket_Relation_Id__c == null)){
                //if(rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c)){
                   if(oItem.MCOnline_MSISDN__c == null && rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c) && rootitemIdVSMSISDN != null){
                        oItem.MCOnline_MSISDN__c = rootitemIdVSMSISDN.get(oItem.vlocity_cmt__RootItemId__c);
                   }
                   if(oItem.MCONL_multiSubscriptionAssetIdentifier__c == null)
                   {
                       if(orderItems.contains(portIn) && orderItems.contains(portInData) && rootitemIdVSMSISDN1.containskey(oItem.vlocity_cmt__RootItemId__c) && rootitemIdVSMSISDN1 != null){
                           oItem.MCONL_multiSubscriptionAssetIdentifier__c = rootitemIdVSMSISDN1.get(oItem.vlocity_cmt__RootItemId__c);
                       }else if(rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c) && rootitemIdVSMSISDN != null){
                           oItem.MCONL_multiSubscriptionAssetIdentifier__c = rootitemIdVSMSISDN.get(oItem.vlocity_cmt__RootItemId__c);
                       }
                   }
                   if(oItem.MCOnline_CommitmentPeriod__c == null && rootitemIdVSCommitment.containskey(oItem.vlocity_cmt__RootItemId__c) && rootitemIdVSCommitment != null){
                        oItem.MCOnline_CommitmentPeriod__c = rootitemIdVSCommitment.get(oItem.vlocity_cmt__RootItemId__c);
                   }
                   if(oItem.MCOnline_Basket_Relation_Id__c == null && rootitemIdVSRelation != null && rootitemIdVSRelation.containskey(oItem.vlocity_cmt__RootItemId__c)){
                      oItem.MCOnline_Basket_Relation_Id__c = rootitemIdVSRelation.get(oItem.vlocity_cmt__RootItemId__c);
                   }
                   if(oItem.MCOnline_RelationWithBasket__c == null && rootitemIdVSRelationBasket != null && rootitemIdVSRelationBasket.containskey(oItem.vlocity_cmt__RootItemId__c)){
                      oItem.MCOnline_RelationWithBasket__c = rootitemIdVSRelationBasket.get(oItem.vlocity_cmt__RootItemId__c);
                   }
                //}
                oItemUpdateList.add(oItem);
            }
        }
        Map<Id,SObject> orderpro1 = new Map<Id,SObject>();
        orderpro1.putall(oItemUpdateList);
        update orderpro1.values();
        oItemUpdateList.clear();
    }
    public static Map<String,decimal> getAmount(Map<Id,Map<String, Attribute>> basketMap, String prodcode, Id basketID, String MSISDNNumber1, String BasketRelationID1)
    {
        Map<String,decimal> amountMap=new Map<String,decimal>();
        if(basketMap != null && basketMap.get(basketID) != null)
        {
            for(String prodtt : basketMap.get(basketID).keyset())
            {
                if(prodtt == prodcode && String.valueOf(basketMap.get(basketID).get(prodtt).basketRelationId+';'+basketMap.get(basketID).get(prodtt).basketName)==BasketRelationID1)
                {
                    if(basketMap.get(basketID).get(prodtt).nrc_amount!=null)
                        amountMap.put('nrc_amount', decimal.valueOf(basketMap.get(basketID).get(prodtt).nrc_amount));
                    if(basketMap.get(basketID).get(prodtt).mrc_amount!=null)
                        amountMap.put('amount', decimal.valueOf(basketMap.get(basketID).get(prodtt).mrc_amount));
                }
            }
        }
        return amountMap;
    }
    
    public static String getProductParameter(Map<Id,Map<String, Attribute>> basketMap, String prodcode, Id basketID, String BasketRelationID1)
    {
        if(basketMap != null && basketMap.get(basketID) != null)
        {
            for(String prodtt : basketMap.get(basketID).keyset())
            {
                if(prodtt == prodcode)
                {
                    if(String.valueOf(basketMap.get(basketID).get(prodtt).basketRelationId+';'+basketMap.get(basketID).get(prodtt).basketName)==BasketRelationID1)
                    {
                        String prodParameter = String.valueOf(basketMap.get(basketID).get(prodtt).actionCode);
                        return prodParameter;
                    }
                }
            }
        }
        return null;
    }
    
    public static Map<String, Attribute> getItems(List<Object> items, String RelationId, String minibasketName)
    {
        Map<String, Attribute> productsMap = new Map<String, Attribute>();
        Map<String, String> msisdnaddon = new Map<String, String>();
        if(items != null)
        {
            for(Object lineItemObj : items)
            {
                Map<String, Object> recObj1Map = ( Map<String, Object>)lineItemObj;
                Map<String, Object> attributesMap = (Map<String, Object>)recObj1Map.get('attributes');
                List<Object> priceMap = (List<Object>)recObj1Map.get('price');
                if(recObj1Map != null)
                {
                    Product itemObj = new Product();
                    Attribute attributesObj = new Attribute();
                    itemObj.ProductCode = String.valueOf(recObj1Map.get('productCode'));
                    attributesObj.ProductCode = String.valueOf(recObj1Map.get('productCode'));
                    attributesObj.actionCode = String.valueOf(recObj1Map.get('actionCode'));
                    attributesObj.basketRelationId = RelationId;
                    attributesObj.basketName = minibasketName;
                    if(recObj1Map.containskey('C2BC_Category'))
                    {
                        attributesObj.C2BCCategory = String.valueOf(recObj1Map.get('C2BC_Category'));
                    }
                    if(recObj1Map.containskey('C2BC_Subcategory'))
                    {
                        attributesObj.C2BCSubCategory = String.valueOf(recObj1Map.get('C2BC_Subcategory'));
                    }
                    if(recObj1Map.containskey('nrc_amount'))
                    {
                        attributesObj.nrc_amount= String.valueOf(recObj1Map.get('nrc_amount'));
                    }
                    if(recObj1Map.containskey('amount'))
                    {
                        attributesObj.mrc_amount = String.valueOf(recObj1Map.get('amount'));
                    }
                    // to support new price change in getbasketContent
                    Integer pricelistsize;
                    if(priceMap != null)
                    {
                        pricelistsize = priceMap.size();
                    }
                    if(pricelistsize > 0)
                    {
                        for(Object pr : priceMap)
                        {
                            Map<String, Object> priceMap1 = ( Map<String, Object>)pr;
                            if(priceMap1 != null)
                            {
                                if(priceMap1.containskey('nrc_amount'))
                                {
                                    attributesObj.nrc_amount= String.valueOf(priceMap1.get('nrc_amount'));
                                }
                                if(priceMap1.containskey('amount'))
                                {
                                    attributesObj.mrc_amount = String.valueOf(priceMap1.get('amount'));
                                }
                            }
                        }
                    }
                    if(attributesMap != null)
                    {
                        attributesObj.MSISDN = String.valueOf(attributesMap.get('MSISDN'));
                        attributesObj.commitmentPeriod = (String.valueOf(attributesMap.get('commitmentPeriod')) != null) ? String.valueOf(attributesMap.get('commitmentPeriod')) : String.valueOf(attributesMap.get('Commitment_period'));
                        attributesObj.userName = (String.valueOf(attributesMap.get('userName')) != null) ? String.valueOf(attributesMap.get('userName')): String.valueOf(attributesMap.get('User_name'));
                        if(attributesMap != null && attributesObj.MSISDN!=null && attributesObj.userName !=null)
                        {
                            msisdnaddon.put('msisdn',attributesObj.MSISDN);
                        }
                    }
                    if(attributesMap != null && String.valueOf(recObj1Map.get('C2BC_Subcategory')) == 'mdsecondary')
                    {
                        attributesObj.MSISDN = msisdnaddon.get('msisdn');
                    }
                    if(attributesMap == null)
                    {
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
    
    global static void updateAssetIdentifier(Map<Id,Map<String, Attribute>> basketMap, Id orderNumber, String orderNumberBasket)
    {
        List<MCOnline_Basket__c> parentBasketObject = [SELECT  MCOnline_AttributeJSON__c, Id,MCOnline_Billing_Account__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c, MCOnline_Basket_Key__c, Account__c, MCOnline_Order__c, MCOnline_Contract__c,MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__c, MCOnline_OfferCode__c,MConline_Offer_ActionCode__c FROM MCOnline_Basket__c where Order__c = :orderNumberBasket];
        List<OrderItem> ordproduct = [Select Id,vlocity_cmt__Product2Id__r.ProductCode,MCOnline_Billing_Account__c,MCOnline_Basket_Relation_Id__c,MCOnline_CommitmentPeriod__c, MCOnline_UserName__c,MCOnline_MSISDN__c, MCONL_multiSubscriptionAssetIdentifier__c,vlocity_cmt__RootItemId__c from OrderItem where Order.Id =:orderNumber order by id];
        Map<String, String> msisdnaddon1 = new Map<String, String>();
        Map<String, String> commitmentaddon = new Map<String, String>();
        Map<String,String> rootitemIdVSMSISDN=new Map<String,String>();
        Map<String,String> rootitemIdVSCommitment=new Map<String,String>();
        Map<String,String> BillingAccountMap=new Map<String,String>();
        Map<String,String> actionCodeMap=new Map<String,String>();
        for(MCOnline_Basket__c basketSFObj : parentBasketObject)
        {
            //testsdgdsf
            if(basketSFObj != null && basketSFObj.MCOnline_AttributeJSON__c != null )
            {   
                Map<String,Object> itemList1 = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);
                String RelationId1 = basketSFObj.Basket_Line_Relation_Id__c;
                List<Object> productList1 = (List<Object>)itemList1.get('products');
                for(Object obj: productList1)
                {
                    Map<String, Object> recObj = ( Map<String, Object>)obj;
                    if(recObj.get('productCode')!=null && recObj.get('actionCode')!=null)
                    {
                        actionCodeMap.put(recObj.get('productCode')+'',recObj.get('actionCode')+'');
                    }
                    Map<String, Object> attributeMap = (Map<String, Object>)recObj.get('attributes');
                    if(attributeMap != null)
                    {
                        if(String.valueOf(recObj.get('C2BC_Subcategory')) == 'voice' && String.valueOf(attributeMap.get('MSISDN')) != null && RelationId1 !=null)
                        {
                            msisdnaddon1.put(RelationId1, String.valueOf(attributeMap.get('MSISDN')));
                        }
                        if(String.valueOf(recObj.get('C2BC_Subcategory')) == 'voice' && String.valueOf(attributeMap.get('commitmentPeriod')) != null && RelationId1 !=null){
                            commitmentaddon.put(RelationId1, String.valueOf(attributeMap.get('commitmentPeriod')));
                        }
                        if(String.valueOf(recObj.get('C2BC_Subcategory')) == 'voice' && String.valueOf(attributeMap.get('Commitment_period')) != null && RelationId1 !=null){
                            commitmentaddon.put(RelationId1, String.valueOf(attributeMap.get('Commitment_period')));
                        }
                    }
                }
                BillingAccountMap.put(RelationId1, basketSFObj.MCOnline_Billing_Account__c);
            }
        }
        List<OrderItem> ordlist= new List<OrderItem>();
        List<OrderItem> ordlist1= new List<OrderItem>();
        for(OrderItem ordproduct1 : ordproduct)
        {
            if(actionCodeMap.containsKey(ordproduct1.vlocity_cmt__Product2Id__r.ProductCode))
            {
                ordproduct1.MCONL_Action_Code__c=actionCodeMap.get(ordproduct1.vlocity_cmt__Product2Id__r.ProductCode);
            }
            if(ordproduct1.MCOnline_Billing_Account__c == null &&  ordproduct1.MCOnline_Basket_Relation_Id__c !=null && BillingAccountMap != null)
            {
                ordproduct1.MCOnline_Billing_Account__c = BillingAccountMap.get(ordproduct1.MCOnline_Basket_Relation_Id__c);
            }
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
            if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.vlocity_cmt__RootItemId__c!='' && oItem != null && (oItem.MCOnline_MSISDN__c == null || oItem.MCONL_multiSubscriptionAssetIdentifier__c == null || oItem.MCOnline_CommitmentPeriod__c == null))
            {
                if(oItem.MCOnline_MSISDN__c == null && rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c) && rootitemIdVSMSISDN != null)
                {
                    oItem.MCOnline_MSISDN__c = rootitemIdVSMSISDN.get(oItem.vlocity_cmt__RootItemId__c);
                }
                if(oItem.MCONL_multiSubscriptionAssetIdentifier__c == null && rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c) && rootitemIdVSMSISDN != null){
                    oItem.MCONL_multiSubscriptionAssetIdentifier__c = rootitemIdVSMSISDN.get(oItem.vlocity_cmt__RootItemId__c);
                }
                if(oItem.MCOnline_CommitmentPeriod__c == null && rootitemIdVSCommitment!=null && rootitemIdVSCommitment.containskey(oItem.vlocity_cmt__RootItemId__c)){
                    oItem.MCOnline_CommitmentPeriod__c = rootitemIdVSCommitment.get(oItem.vlocity_cmt__RootItemId__c);
                }
                ordlist1.add(oItem);
            }
        }
        Map<Id,SObject> orderii = new Map<Id,SObject>();
        orderii.putall(ordlist1);
        update orderii.values();
    }
    
    public static void checkPriceMatrix(List<MCOnline_Basket__c> basketObj)
    {
        Map<String, List<MCOnline_Basket__c>> basketMapPrice = new Map<String, List<MCOnline_Basket__c>>();
        for(MCOnline_Basket__c bas : basketObj)
        {
            if(!basketMapPrice.containsKey(bas.Basket_Line_Relation_Id__c))
            {
                basketMapPrice.put(bas.Basket_Line_Relation_Id__c,new List<MCOnline_Basket__c>{bas});
            }
            else
            {
                basketMapPrice.get(bas.Basket_Line_Relation_Id__c).add(bas);
            }
        }
        for(String relId : basketMapPrice.keyset())
        {
            String commitmentValue;
            String priceRange;
            List<MCOnline_Basket__c> validBasket = new List<MCOnline_Basket__c>();
            List < PricematrixRanges__c > ranges = PricematrixRanges__c.getall().values();
            Map < String, Object > dataMap2 = new  Map < String, Object > ();
            List < Map < String, Object >> dataMapChildren = new List < Map < String, Object >> ();
            List<MCOnline_Basket__c> getBasket = basketMapPrice.get(relId);
            if(getBasket != null)
            {
                for(MCOnline_Basket__c bas : getBasket)
                {
                    
                    if(bas != null && bas.MCOnline_AttributeJSON__c != null )
                    {
                        Map<String,Object> itemList1 = (Map<String,Object>)JSON.deserializeUntyped(bas.MCOnline_AttributeJSON__c);
                        List<Object> productList1 = (List<Object>)itemList1.get('products');
                        for(Object obj: productList1)
                        {
                            Map<String, Object> recObj = (Map<String, Object>)obj;
                            String price;
                            Decimal efsprice = 0;
                            Map<String, Object> attributeMap = (Map<String, Object>)recObj.get('attributes');
                            if(attributeMap != null && String.valueOf(recObj.get('C2BC_Subcategory')) == 'voice')
                            {
                                if(String.valueOf(attributeMap.get('commitmentPeriod')) != null){
                                   commitmentValue = String.valueOf(attributeMap.get('commitmentPeriod'));
                                }
                                else if(String.valueOf(attributeMap.get('Commitment_period')) !=null){
                                   commitmentValue = String.valueOf(attributeMap.get('Commitment_period'));
                                }
                            }
                            if(recObj.containsKey('price'))
                            {
                                List<Object> HWPrice = (List<Object>)recObj.get('price');
                                for(Object priceList : HWPrice)
                                {
                                    Map<String, Object> priceListMap = (Map<String, Object>)priceList;
                                    if(attributeMap != null && priceListMap != null && String.valueOf(recObj.get('C2BC_Subcategory')) == 'voice' && string.ValueOf(priceListMap.get('chargeType'))=='Recurring' && string.valueOf(priceListMap.get('amount')) != null)
                                    {
                                        price = String.valueOf(priceListMap.get('amount'));
                                        efsprice = decimal.valueOf(price);
                                    }
                                }
                            }
                            else if(attributeMap != null && String.valueOf(recObj.get('C2BC_Subcategory')) == 'voice' && String.valueOf(recObj.get('amount')) != null)
                            {
                                price = String.valueOf(recObj.get('amount'));
                                efsprice = decimal.valueOf(price);
                            }
                            for (PricematrixRanges__c range: ranges) 
                            {
                                if (efsprice >= range.Low__c && efsprice <= range.High__c) 
                                {
                                    priceRange = range.Name;
                                    break;
                                }
                            }
                        }
                    }
                }
                for(MCOnline_Basket__c bas : getBasket)
                {
                    if(bas != null && bas.MCOnline_AttributeJSON__c != null )
                    {
                        Map<String,Object> itemList1 = (Map<String,Object>)JSON.deserializeUntyped(bas.MCOnline_AttributeJSON__c);
                        List<Object> productList1 = (List<Object>)itemList1.get('products');
                        for(Object obj: productList1)
                        {
                            Map<String, Object> recObj = ( Map<String, Object>)obj;
                            Map<String, Object> attributeMap = (Map<String, Object>)recObj.get('attributes');
                            if(attributeMap != null && String.valueOf(recObj.get('C2BC_Category')) == 'goods' && String.valueOf(attributeMap.get('HWSAPID')) != null && String.valueOf(attributeMap.get('HWUpfrontPayment')) != null && String.valueOf(attributeMap.get('HWUpfrontPayment')).equalsIgnoreCase('false'))
                            {
                                    dataMap2.put('Source Product Name', String.valueOf(recObj.get('name')));
                                    dataMap2.put('Source Product Code', String.valueOf(recObj.get('productCode')));
                                    dataMap2.put('Quantity', priceRange);
                                    dataMap2.put('Characteristic Name', 'HWSAPID');
                                    dataMap2.put('Characteristic Value', String.valueOf(attributeMap.get('HWSAPID')));
                                    dataMapChildren.add(dataMap2);
                                    validBasket.add(bas);
                            }
                        }
                    }
                }
                if(commitmentValue != null && commitmentValue != '0' && dataMapChildren != null && dataMapChildren.size() > 0)
                {
                    List<Object> storeHardwarePriceList = invokeProcedure(dataMapChildren, commitmentValue);
                    if(storeHardwarePriceList != null && storeHardwarePriceList.size() > 0 && validBasket.size() > 0 && validBasket != null)
                    {
                        updateBasketPriceMatrix(storeHardwarePriceList, validBasket); 
                    }
                    if(storeHardwarePriceList != null)
                    {
                        storeHardwarePriceList.clear();
                    }
                }
            }
            if(validBasket != null)
            {
                validBasket.clear();
            }
        }
    }
    public static List<Object> invokeProcedure(List < Object > dataMap, String commitmentValue)
    {
        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > options = new Map < String, Object > ();
        List<Object> hardwareMatrixList = new List<Object>();
        Map < String, Object > outMapMatrixCal = new Map < String, Object > ();
        Map < String, List<Map<String, Object>> > outMapMatrix = new Map < String, List<Map<String, Object>> > ();
        System.debug(String.valueOf(dataMap));
        Map < string, HW_Cal_Procedure__c > calProc = HW_Cal_Procedure__c.getall();
        String configurationName;
        string outputRespose;
        string outforCompare;
        List < String > noPriceProd = new List < String > ();
        List < Map < String, Object >> noPriceDataMap = new List < Map < String, Object >> ();
        if (commitmentValue?.equalsIgnoreCase('24')) 
        {
            configurationName = (String)(calProc.get('Hardware_24M').get('configurationName__c'));
            options.put('configurationName', configurationName);
        } 
        else if (commitmentValue?.equalsIgnoreCase('36')) 
        {
            configurationName = (String)(calProc.get('Hardware_36M').get('configurationName__c'));
            options.put('configurationName', configurationName);
        } 
        else if (commitmentValue == '0') 
        {
            configurationName = 'No_Calculation_Procedure';
        }
        options.put('includeInputs', true);
        Object[] inputdata = new List < Object > ();
        Map < String, Object > c = new Map < String, Object > ();
        List < Object > productList = new List < Object > ();
        Map < String, Object > prod1 = new Map < String, Object > ();
        List<Map<String, Object>> outList = new List<Map<String, Object>>();
        inputMap.put('UserInputList', dataMap);
        options.put('verbose', false);
        options.put('mergeInListName', 'UserInputList');
        Map < String, Object > output = new Map < String, Object > ();
        Type t = Type.forName('vlocity_cmt', 'PricingMatrixCalculationService');
        vlocity_cmt.VlocityOpenInterface vpsi = (vlocity_cmt.VlocityOpenInterface) t.newInstance();
        if (!Test.isRunningTest()) {
            vpsi.invokeMethod('calculate', inputMap, output, options);
            for(Object obj:(List<Object>)output.get('output'))
            {
                vlocity_cmt.PricingCalculationService.CalculationProcedureResults item=(vlocity_cmt.PricingCalculationService.CalculationProcedureResults)obj;
                for(Object obj1:(List<Object>)item.calculationResults)
                {
                    hardwareMatrixList.add(obj1);
                }
                if(hardwareMatrixList != null  && hardwareMatrixList.size() > 0){
                    outMapMatrixCal.put('calculationResults', hardwareMatrixList);
                }
                if(outMapMatrixCal != null){
                    outList.add(outMapMatrixCal);
                }
            }
            outMapMatrix.put('output',  outList);
            outputRespose = JSON.serialize(outMapMatrix);
        } else {
            outputRespose = '{"output":[{"calculationResults":[{"PriceMatrix_24M_Hardware__MRC":"200","PriceMatrix_24M_Hardware__NRC":"0","SourceProductCode":"HW_IPHONE_12_64_BLUE","ID":"49"}],"aggregationResults":null}]}';
        }
        outputRespose = outputRespose.replace('Source Product Code', 'SourceProductCode');
        outputRespose = outputRespose.replace('Source Product Name', 'SourceProductName');
        outputRespose = outputRespose.replace('Characteristic Value', 'CharacteristicValue');
        outputRespose = outputRespose.replace('Characteristic Name', 'CharacteristicName');
        if (commitmentValue != null && commitmentValue.equalsIgnoreCase('36')) {
            outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__MRC', 'MRC');
            outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__NRC', 'NRC');
            outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__TargetProductName', 'TargetProductName');
        } else if (commitmentValue != null && commitmentValue.equalsIgnoreCase('24')) {
            outputRespose = outputRespose.replace('PriceMatrix_24M_Hardware__MRC', 'MRC');
            outputRespose = outputRespose.replace('PriceMatrix_24M_Hardware__NRC', 'NRC');
            outputRespose = outputRespose.replace('PriceMatrix_24M_Hardware__TargetProductName', 'TargetProductName');
        }
        Map<String, Object> outMap = (Map<String, Object>)JSON.deserializeUntyped(outputRespose);
        List<Object> hardwareList;
        List<Object> hardwarePriceList;
        if(outMap != null)
        {
            hardwareList = (List<Object>)outMap.get('output');
        }
        if(hardwareList !=null && hardwareList.size() > 0)
        {
            System.debug(String.valueOf(hardwareList));
            Map<String, Object> objMap = (Map<String, Object>)hardwareList[0];
            if(objMap != null && objMap.containsKey('calculationResults'))
            {
                hardwarePriceList = (List<Object>)objMap.get('calculationResults');
            }
        }
        return hardwarePriceList;
    }
    public static void updateBasketPriceMatrix(List<Object> storeHardwarePriceList, List<MCOnline_Basket__c> validBasket)
    {
        for(MCOnline_Basket__c bas: validBasket)
        {
            if(bas != null && bas.MCOnline_AttributeJSON__c != null )
            {
                Map<String,Object> itemList1 = (Map<String,Object>)JSON.deserializeUntyped(bas.MCOnline_AttributeJSON__c);
                for(Object sr : storeHardwarePriceList)
                {
                    Map<String, Object> storeList = (Map<String, Object>)sr;
                    List<Object> productList1 = (List<Object>)itemList1.get('products');
                    for(Object obj: productList1)
                    {
                        Map<String, Object> recObj = ( Map<String, Object>)obj;
                        Map<String, Object> attributeMap = (Map<String, Object>)recObj.get('attributes');
                        List<Object> HWPrice2 = null;
                        if(recObj.containsKey('price')){
                            HWPrice2 = (List<Object>)recObj.get('price');
                        }
                        if(attributeMap != null)
                        {
                            if(storeList != null && String.valueOf(recObj.get('productCode')) == String.valueOf(storeList.get('SourceProductCode')) && String.valueOf(recObj.get('C2BC_Category')) == 'goods' && String.valueOf(attributeMap.get('HWSAPID')) != null && String.valueOf(attributeMap.get('HWUpfrontPayment')) != null && String.valueOf(attributeMap.get('HWUpfrontPayment')).equalsIgnoreCase('false'))
                            {
                                if(HWPrice2!=null)
                                {
                                    for(Object priceList3 : HWPrice2)
                                    {
                                        Map<String, Object> priceList2 = (Map<String, Object>)priceList3;
                                        if(string.valueOf(priceList2.get('chargeType'))=='Recurring' && priceList2.containsKey('amount') && String.valueOf(priceList2.get('amount'))!=null && String.valueOf(storeList.get('MRC'))!=null && Decimal.valueOf(String.valueOf(priceList2.get('amount'))) != Decimal.valueOf(String.valueOf(storeList.get('MRC'))))
                                        {
                                            if(basketIdSet != null && basketIdSet.containsKey(bas.Id))
                                            {
                                                basketIdSet.put(bas.Id, (basketIdSet.get(bas.Id)+ ' For Product ' +String.valueOf(recObj.get('name'))+' the amount changed from '+String.valueOf(priceList2.get('amount'))+' to '+String.valueOf(storeList.get('MRC'))+'.'));
                                            }else
                                            {
                                                basketIdSet.put(bas.Id, (' For Product ' +String.valueOf(recObj.get('name'))+' the amount changed from '+String.valueOf(priceList2.get('amount'))+' to '+String.valueOf(storeList.get('MRC'))+'.'));
                                            }
                                            priceList2.put('amount', String.valueOf(storeList.get('MRC')));
                                        }
                                        if(string.valueOf(priceList2.get('chargeType'))=='One-time' && priceList2.containsKey('nrc_amount') && String.valueOf(priceList2.get('nrc_amount'))!=null && String.valueOf(storeList.get('NRC')) !=null && Decimal.valueOf(String.valueOf(priceList2.get('nrc_amount'))) != Decimal.valueOf(String.valueOf(storeList.get('NRC'))))
                                        {
                                            if(basketIdSet != null && basketIdSet.containsKey(bas.Id))
                                            {
                                                basketIdSet.put(bas.Id, (basketIdSet.get(bas.Id)+ ' For Product' +String.valueOf(recObj.get('name'))+' the nrc_amount changed from '+String.valueOf(priceList2.get('nrc_amount'))+' to '+String.valueOf(storeList.get('NRC'))+'.'));
                                            }else
                                            {
                                                basketIdSet.put(bas.Id, (' For Product ' +String.valueOf(recObj.get('name'))+' the nrc_amount changed from '+String.valueOf(priceList2.get('nrc_amount'))+' to '+String.valueOf(storeList.get('NRC'))+'.'));
                                            }
                                            priceList2.put('nrc_amount', String.valueOf(storeList.get('NRC')));
                                        }
                                    }
                                }else
                                {
                                    if(recObj.containsKey('amount') && String.valueOf(recObj.get('amount'))!=null && String.valueOf(storeList.get('MRC'))!=null && Decimal.valueOf(String.valueOf(recObj.get('amount'))) != Decimal.valueOf(String.valueOf(storeList.get('MRC'))))
                                    {
                                        if(basketIdSet != null && basketIdSet.containsKey(bas.Id))
                                        {
                                            basketIdSet.put(bas.Id, (basketIdSet.get(bas.Id)+ ' For Product ' +String.valueOf(recObj.get('name'))+' the amount changed from '+String.valueOf(recObj.get('amount'))+' to '+String.valueOf(storeList.get('MRC'))+'.'));
                                        }else
                                        {
                                            basketIdSet.put(bas.Id, (' For Product ' +String.valueOf(recObj.get('name'))+' the amount changed from '+String.valueOf(recObj.get('amount'))+' to '+String.valueOf(storeList.get('MRC'))+'.'));
                                        }
                                        recObj.put('amount', String.valueOf(storeList.get('MRC')));
                                    }
                                    if(recObj.containsKey('nrc_amount') && String.valueOf(recObj.get('nrc_amount'))!=null && String.valueOf(storeList.get('NRC')) !=null && Decimal.valueOf(String.valueOf(recObj.get('nrc_amount'))) != Decimal.valueOf(String.valueOf(storeList.get('NRC'))))
                                    {
                                        if(basketIdSet != null && basketIdSet.containsKey(bas.Id))
                                        {
                                            basketIdSet.put(bas.Id, (basketIdSet.get(bas.Id)+ ' For Product' +String.valueOf(recObj.get('name'))+' the nrc_amount changed from '+String.valueOf(recObj.get('nrc_amount'))+' to '+String.valueOf(storeList.get('NRC'))+'.'));
                                        }else
                                        {
                                            basketIdSet.put(bas.Id, (' For Product ' +String.valueOf(recObj.get('name'))+' the nrc_amount changed from '+String.valueOf(recObj.get('nrc_amount'))+' to '+String.valueOf(storeList.get('NRC'))+'.'));
                                        }
                                        recObj.put('nrc_amount', String.valueOf(storeList.get('NRC')));
                                    }
                                }
                            }
                        }
                    }
                }
                Map<String,Object> itemList = (Map<String,Object>)itemList1;
                String SerializableString = JSON.serialize(itemList);
                updatedAttributeJSON.put(bas.Id, SerializableString);
            }
        }
    }
    
    public class Product
    {
        public Attribute Attributes{get; set;}
        public string ProductCode{get; set;}
    }
    public class Attribute
    {
        public string ProductCode{get; set;}
        public string MSISDN{get; set;}
        public string actionCode{get; set;}
        public string basketRelationId {get; set;}
        public string basketName {get; set;}
        public string userName {get; set;}
        public string nrc_amount {get; set;}
        public string mrc_amount {get; set;}
        public String C2BCCategory {get; set;}
        public String C2BCSubCategory {get; set;}
        public String commitmentPeriod {get; set;}
        
    }
}