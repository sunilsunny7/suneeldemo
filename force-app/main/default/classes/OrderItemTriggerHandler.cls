public class OrderItemTriggerHandler{
    public static Boolean isFirstTime = true;
    
    public static void afterUpdate(List<OrderItem> oItemList){
        
    }
    public static void afterInsert(List<OrderItem> oItemList){
        
    }
    public static void beforeUpdate(List<OrderItem> oItemList){
        updateMsisdn(oItemList);
    }
    public static void beforeInsert(List<OrderItem> oItemList){
        updateMsisdn(oItemList);
    }
    public static void updateMsisdn(List<OrderItem> oItemList){
    
        Map<String,String> rootitemIdVSMSISDN=new Map<String,String>(); 
        Map<String,String> rootitemIdVSCommitment=new Map<String,String>();
        Map<String,String> rootitemIdVSRelation= new Map<String,String>();
        Map<String,String> rootitemIdVSRelationBasket= new Map<String,String>();
        for(OrderItem oItem : oItemList){
            string msisdn = null;
            if(oItem != null){
                string jsonAttribute = oItem.vlocity_cmt__AttributeSelectedValues__c, jsonOfferAttribute =oItem.vlocity_cmt__JSONAttribute__c;
                
                if(jsonAttribute != null || jsonOfferAttribute != null){

                    if(MCOnline_OrderProcessor_V3.getAttribute('BILLING_ACCOUNT', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                    {
                        oItem.TeliaSE_BillingAccountOnline__c = MCOnline_OrderProcessor_V3.getAttribute('BILLING_ACCOUNT', oItem.vlocity_cmt__AttributeSelectedValues__c);
                    }
                    else if(MCOnline_OrderProcessor_V3.getJsonAttribute('BILLING_ACCOUNT', oItem.vlocity_cmt__JSONAttribute__c) != null)
                    {
                        oItem.TeliaSE_BillingAccountOnline__c = MCOnline_OrderProcessor_V3.getJsonAttribute('BILLING_ACCOUNT', oItem.vlocity_cmt__JSONAttribute__c);
                    }
                    if(MCOnline_OrderProcessor_V3.getAttribute('MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c) != null){
                        oItem.MCOnline_MSISDN__c = MCOnline_OrderProcessor_V3.getAttribute('MSISDN', oItem.vlocity_cmt__AttributeSelectedValues__c);
                    }
                    else if(MCOnline_OrderProcessor_V3.getJsonAttribute('MSISDN', oItem.vlocity_cmt__JSONAttribute__c) != null)
                    {
                        oItem.MCOnline_MSISDN__c = MCOnline_OrderProcessor_V3.getJsonAttribute('MSISDN', oItem.vlocity_cmt__JSONAttribute__c);
                    }
                    if(MCOnline_OrderProcessor_V3.getAttribute('TELIA_COMM_PERIOD', oItem.vlocity_cmt__AttributeSelectedValues__c) != null)
                    {
                        oItem.MCOnline_CommitmentPeriod__c = MCOnline_OrderProcessor_V3.getAttribute('TELIA_COMM_PERIOD', oItem.vlocity_cmt__AttributeSelectedValues__c);
                    }
                    else if(MCOnline_OrderProcessor_V3.getJsonAttribute('TELIA_COMM_PERIOD', oItem.vlocity_cmt__JSONAttribute__c) != null)
                    {
                        oItem.MCOnline_CommitmentPeriod__c = MCOnline_OrderProcessor_V3.getJsonAttribute('TELIA_COMM_PERIOD', oItem.vlocity_cmt__JSONAttribute__c);
                    }
                    if(MCOnline_OrderProcessor_V3.getAttribute('Relation_Id', oItem.vlocity_cmt__AttributeSelectedValues__c) != null){
                        oItem.MCOnline_RelationWithBasket__c = MCOnline_OrderProcessor_V3.getAttribute('Relation_Id', oItem.vlocity_cmt__AttributeSelectedValues__c);
                        if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.MCOnline_RelationWithBasket__c !=null){
                            rootitemIdVSRelationBasket.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_RelationWithBasket__c);
                        }
                        List<String> RelationId = MCOnline_OrderProcessor_V3.getAttribute('Relation_Id', oItem.vlocity_cmt__AttributeSelectedValues__c).split(';');
                        oItem.MCOnline_Basket_Relation_Id__c = (RelationId != null && RelationId.size() > 0) ? RelationId[0] : null;
                        if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.MCOnline_Basket_Relation_Id__c !=null){
                            rootitemIdVSRelation.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_Basket_Relation_Id__c);
                        }
                    }else if(MCOnline_OrderProcessor_V3.getJsonAttribute('Relation_Id', oItem.vlocity_cmt__JSONAttribute__c) != null){
                        oItem.MCOnline_RelationWithBasket__c = MCOnline_OrderProcessor_V3.getJsonAttribute('Relation_Id', oItem.vlocity_cmt__JSONAttribute__c);
                        if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.MCOnline_RelationWithBasket__c !=null){
                            rootitemIdVSRelationBasket.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_RelationWithBasket__c);
                        }
                        List<String> RelationId = MCOnline_OrderProcessor_V3.getJsonAttribute('Relation_Id', oItem.vlocity_cmt__JSONAttribute__c).split(';');
                        oItem.MCOnline_Basket_Relation_Id__c = (RelationId != null && RelationId.size() > 0) ? RelationId[0] : null;
                        if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.MCOnline_Basket_Relation_Id__c !=null){
                            rootitemIdVSRelation.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_Basket_Relation_Id__c);
                        }
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

                    //oItem.MCONL_multiSubscriptionAssetIdentifier__c = oItem.MCOnline_MSISDN__c;
                    /*if(oItem.MCOnline_MSISDN__c!='' && oItem.MCOnline_MSISDN__c != null && oItem.vlocity_cmt__RootItemId__c!=null && oItem.vlocity_cmt__RootItemId__c!='' && oItem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c != 'datasim'){
                        //oItem.MCONL_multiSubscriptionAssetIdentifier__c = oItem.MCOnline_MSISDN__c;
                        msisdn = oItem.MCOnline_MSISDN__c;
                        rootitemIdVSMSISDN.put(oItem.vlocity_cmt__RootItemId__c,msisdn);
                        if(oItem.MCOnline_CommitmentPeriod__c != null){
                            rootitemIdVSCommitment.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_CommitmentPeriod__c);
                        }
                    }*/
                    if(oItem.MCOnline_CommitmentPeriod__c != null && oItem.vlocity_cmt__RootItemId__c!=null && oItem.vlocity_cmt__RootItemId__c!=''){
                            rootitemIdVSCommitment.put(oItem.vlocity_cmt__RootItemId__c, oItem.MCOnline_CommitmentPeriod__c);
                    }
                }
            }
        }
        
        for(OrderItem oItem : oItemList){


            if(oItem.vlocity_cmt__RootItemId__c!=null && oItem.vlocity_cmt__RootItemId__c!='' && oItem != null && (oItem.MCOnline_MSISDN__c == null || oItem.MCONL_multiSubscriptionAssetIdentifier__c == null || oItem.MCOnline_CommitmentPeriod__c == null || oItem.MCOnline_Basket_Relation_Id__c == null)){
                //if(rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c)){
                   /*if(oItem.MCOnline_MSISDN__c == null && rootitemIdVSMSISDN != null && rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c)){


                      oItem.MCOnline_MSISDN__c = rootitemIdVSMSISDN.get(oItem.vlocity_cmt__RootItemId__c);
                   }*/
                   /*if(oItem.MCONL_multiSubscriptionAssetIdentifier__c == null && rootitemIdVSMSISDN != null && rootitemIdVSMSISDN.containskey(oItem.vlocity_cmt__RootItemId__c)){
                      oItem.MCONL_multiSubscriptionAssetIdentifier__c = rootitemIdVSMSISDN.get(oItem.vlocity_cmt__RootItemId__c);
                   }*/
                   if(oItem.MCOnline_CommitmentPeriod__c == null && rootitemIdVSCommitment!=null && rootitemIdVSCommitment.containskey(oItem.vlocity_cmt__RootItemId__c)){
                      oItem.MCOnline_CommitmentPeriod__c = rootitemIdVSCommitment.get(oItem.vlocity_cmt__RootItemId__c);
                   }
                   if(oItem.MCOnline_Basket_Relation_Id__c == null && rootitemIdVSRelation != null && rootitemIdVSRelation.containskey(oItem.vlocity_cmt__RootItemId__c)){
                      oItem.MCOnline_Basket_Relation_Id__c = rootitemIdVSRelation.get(oItem.vlocity_cmt__RootItemId__c);
                   }
                   if(oItem.MCOnline_RelationWithBasket__c == null && rootitemIdVSRelationBasket != null && rootitemIdVSRelationBasket.containskey(oItem.vlocity_cmt__RootItemId__c)){
                      oItem.MCOnline_RelationWithBasket__c = rootitemIdVSRelationBasket.get(oItem.vlocity_cmt__RootItemId__c);
                   }
                //}
            }
        }
    }
}