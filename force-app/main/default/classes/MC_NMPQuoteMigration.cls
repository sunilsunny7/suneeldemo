/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_NMPQuoteMigration 
**Created By  :        Aditi Goyal
**Date      :          10 April 2023
**User Story  :        LTAT-5899 R_23.4
**Description :        Apex class to for building request for NMP quote migration. To be deleted once migration is completed successfully
-----------------------------------------------------------------------------------------------------------*/
global class MC_NMPQuoteMigration implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result = true;
        try{
            if (methodName.equals('buildRequestMap')){
                buildRequestMap(inputMap,outMap);
            }
        }
        catch(Exception e){
            System.debug('Exception : '+e.getStackTraceString());
            System.debug('Exception : '+e.getMessage());
            outMap.put('errorStackTarce',e.getStackTraceString());
            outMap.put('error',e.getMessage());
            return false;  
        }   
        return result;
    }
    
    public static void buildRequestMap(Map<String,Object> inputMap, Map<String,Object> outMap) {
        String quoteId = (String)inputMap.get('QuoteId');
        List<QuoteLineItem> qliList = [Select id,QuoteId,TeliaSE_Root_Product__c, Product2Id,Product2.Name, vlocity_cmt__ParentItemId__c,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__RootItemId__c 
                                       from QuoteLineItem where QuoteId =:quoteId  and TeliaSE_Product_Code__c ='MOB_SP_ADDON_ABROAD' 
                                       and TeliaSE_Product_Object_Type__c ='Mobile Offer Specification' and 
                                       (TeliaSE_ParentClusterCode__c <> NULL and TeliaSE_ParentClusterCode__c <> 'plus')];   
        PriceBookentry pbe = [select id,Product2.Name from PricebookEntry where Product2.ProductCode = 'MOB_SP_ADDON_ABROAD_MAX' and Product2.Family <> 'Online Order'];
        
        
        List<SingleCartRequestWrapper> wrapList = new List<SingleCartRequestWrapper>();
        String itemIds,itemName;
        for(QuotelineItem eachQLI :qliList){
            SingleCartRequestWrapper singlewrap= new SingleCartRequestWrapper();
            List<ItemsWrap> itemwrapList  = new List<ItemsWrap>();
            ItemsWrap itemwrap  = new ItemsWrap();
            ParentRecordWrap pwrap = new ParentRecordWrap();
            List<RecordsWrap> rslist = new List<RecordsWrap>();
            RecordsWrap rs = new RecordsWrap();
            
            itemwrap.itemName = pbe.Product2.Name;
            itemwrap.itemId = pbe.Id;
            itemwrap.quantity = 1;
            itemwrap.parentId = eachQLI.Id;
            rs.productHierarchyPath = eachQLI.vlocity_cmt__ProductHierarchyPath__c;
            rs.parentHierarchyPath = eachQLI.vlocity_cmt__ProductHierarchyPath__c;
            rslist.add(rs);
            pwrap.records = rslist;
            itemwrap.parentRecord = pwrap;
            itemwrapList.add(itemwrap);
            singlewrap.items = itemwrapList; 
            singlewrap.parentName = eachQLI.Product2.Name; 
            singlewrap.cartId =eachQLI.QuoteId;
            singlewrap.noResponseNeeded = true;
            singlewrap.validate = true;
            singlewrap.price = true;
            wrapList.add(singlewrap);
        }
        String requestString = JSON.serialize(wrapList);
        outMap.put('addToCartRequestList',JSON.deserializeUntyped(requestString));
    }
    //wrapper classes for building CPQ API request structure
    private class SingleCartRequestWrapper {
        public String cartId {get; set;}        
        public String parentName {get; set;}
        public List<ItemsWrap> items{get;set;}
        public Boolean validate{get;set;}
        public Boolean price{get;set;}
        public Boolean noResponseNeeded{get;set;}
    }
    
    private class ParentRecordWrap {
        public List<RecordsWrap> records{get; set;}
    }
    
    private class ItemsWrap {
        public String itemName {get; set;}
        public String itemId{get; set;}
        public String parentId {get; set;}
        public Integer quantity {get; set;}
        public Map<String,Object> fieldsToUpdate {get; set;}
        public ParentRecordWrap parentRecord{get; set;}
    }
    
    private class RecordsWrap {
        public String productHierarchyPath{get; set;}
        public String parentHierarchyPath{get; set;}
    }    
}