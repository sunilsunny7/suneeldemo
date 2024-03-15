public class Hardware_ProductHierarchyPath {
    public static void hierarachyPathProducts(Map<String, Object> inputMap, Map<String,object>outMap){ 
        String Selectedproducts = 'SelectedHardwareProductList';
        String BundleAndCart = 'BundleAndCart';
        List<SubscriptionAndProductMapResponseWrap> subsandprodMap = getFinalNode(inputMap,Selectedproducts,BundleAndCart);
        outMap.put('SubscriptionAndProductMap',subsandprodMap);
    }
    public static void hierarachyPathAccessory(Map<String, Object> inputMap, Map<String,object>outMap){ 
        String SelectedHardwareProductList = 'AccessoriesList';
        String BundleAndCart = 'AccessoryBundleAndCart';
        List<SubscriptionAndProductMapResponseWrap> subsandprodMap = getFinalNode(inputMap,SelectedHardwareProductList,BundleAndCart);
        outMap.put('AccessoriesMap',subsandprodMap);
    }    
    public static List<SubscriptionAndProductMapResponseWrap> getFinalNode(Map<String, Object> inputMap, String productSelect, String cartIdandBundleId){ 
        //preparing Hierarchy path for the selected products 
        object productid = (Object)inputMap.get(productSelect);
        String productidjson = JSON.serialize(productid);
        System.debug('productidjson'+productidjson);
        List<SelectedHardwareProductListWrapper> productList = (List<SelectedHardwareProductListWrapper>)JSON.deserialize(productidjson, List<SelectedHardwareProductListWrapper>.class);    
        System.debug('productList#-->'+productList);
        List<String> prodidList = new List<String>();
        Map<String,String> itemIdMap = new  Map<String,String>();
        for(SelectedHardwareProductListWrapper spw : productList){
            prodidList.add(spw.productId);
            itemIdMap.put(spw.productId,spw.Id);
        }
        System.debug('prodidList###'+prodidList);
        System.debug('itemIdMap###'+itemIdMap);

        List<heirarchypathwrapper> path =  hierarachyPath(prodidList);
        Map<String,String> parentIdMap = new Map<String,String>();
        Map<String,String> pathMap = new Map<String,String>();
        
        for(heirarchypathwrapper hpw : path){
            parentIdMap.put(hpw.prodId, hpw.parentId);
            pathMap.put(hpw.prodId, hpw.path);
        }
        System.debug('path###'+path);
        System.debug('parentIdMap###'+parentIdMap);
        System.debug('pathMap###'+pathMap);
        
        // getting Cart and BundleId
        object bundleIdobje = (Object)inputMap.get(cartIdandBundleId);
        String bundleJson = JSON.serialize(bundleIdobje);
        BundleAndCart bundleresult = (BundleAndCart)JSON.deserialize(bundleJson, BundleAndCart.class);
        String bundleId = String.valueOf(bundleresult.BundleId);
        String cartId = String.valueOf(bundleresult.QuoteId);
        System.debug('bundleId**>'+bundleId);
        System.debug('cartId**>'+cartId); 
        
        // preparing Complete node for postcartitems method.
        List<SubscriptionAndProductMapResponseWrap> subsandprodMap = new List<SubscriptionAndProductMapResponseWrap>();
        
        for(String key: pathMap.keySet()){
            System.debug('key###'+key);
            
            List<Recordswrap> rwlist = new List<Recordswrap>();
            Recordswrap rwrap = new Recordswrap();
            rwrap.productHierarchyPath = pathMap.get(key);
            rwrap.parentHierarchyPath = pathMap.get(key);
            rwlist.add(rwrap);
            System.debug('rwrap###'+rwrap);
            System.debug('rwlist###'+rwlist);
            ParentRecordwrap parentrecord = new ParentRecordwrap();
            parentrecord.records = rwlist;
            List<Itemswrap> itemwrapList = new List<Itemswrap>();
            Itemswrap itemw = new Itemswrap();
            itemw.itemId = itemIdMap.get(key);
            itemw.parentId = bundleId;//parentIdMap.get(key);
            itemw.parentRecord = parentrecord;
            itemwrapList.add(itemw);
            System.debug('parentrecord###'+parentrecord);
            System.debug('itemw###'+itemw);
            System.debug('itemwrapList###'+itemwrapList);
            SubscriptionAndProductMapResponseWrap subsandprod = new SubscriptionAndProductMapResponseWrap();
            subsandprod.methodName = 'postCartsItems';
            subsandprod.cartId = cartId;
            subsandprod.items = itemwrapList;
            subsandprod.validate = false;
            subsandprod.price = false;
            subsandprodMap.add(subsandprod);
            System.debug('subsandprod###'+subsandprod);
            
        } 
        System.debug('subsandprodMap###'+subsandprodMap);
        return subsandprodMap;
    }
    
    public static List<heirarchypathwrapper> hierarachyPath(List<String> prodidList){
        System.debug('prodidList#-->'+prodidList);
        Map<String,String> parentidMap = new Map<String,String>();
        List<vlocity_cmt__ProductChildItem__c> ProductChildItemList = [SELECT Id, vlocity_cmt__ParentProductId__r.Id, vlocity_cmt__ParentProductId__r.name, vlocity_cmt__ChildProductId__c FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__r.Id in :prodidList and (vlocity_cmt__ParentProductId__r.TeliaSE_Object_Type_Name__c = 'Mobile Handset Product Specification' OR vlocity_cmt__ParentProductId__r.TeliaSE_Object_Type_Name__c = 'Mobile Accessory Product Specification')];
        List<String> parentidlevel2 = new List<String>();
        for(vlocity_cmt__ProductChildItem__c pci : ProductChildItemList){
            parentidMap.put(pci.vlocity_cmt__ChildProductId__c, pci.vlocity_cmt__ParentProductId__c);
            parentidlevel2.add(pci.vlocity_cmt__ParentProductId__c);
            System.debug('parentidMapinsidemap#-->'+parentidMap);
        }
        System.debug('parentidlevel2####'+parentidlevel2);
        System.debug('ProductChildItemList#-->'+ProductChildItemList);
        System.debug('parentidMap#-->'+parentidMap);
        List<vlocity_cmt__ProductChildItem__c> ProductChildItemForRootList = [SELECT Id, vlocity_cmt__ParentProductId__r.Id, vlocity_cmt__ParentProductId__r.name, vlocity_cmt__ChildProductId__r.Id, vlocity_cmt__ChildProductId__r.Name FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__r.Id in :parentidlevel2];
        Map<String,String> pathMap = new Map<String,String>();
        for(vlocity_cmt__ProductChildItem__c pcir : ProductChildItemForRootList){
            String parentid = String.ValueOf(pcir.vlocity_cmt__ParentProductId__c);
            String childid = String.ValueOf(pcir.vlocity_cmt__ChildProductId__c);
            String path = parentid+'<'+childid;
            pathMap.put(pcir.vlocity_cmt__ChildProductId__c, path);
        }
        System.debug('ProductChildItemForRootList#-->'+ProductChildItemForRootList);
        System.debug('pathMap#-->'+pathMap);
        List<heirarchypathwrapper> heirarchypath = new List<heirarchypathwrapper>();
        
        for(String key : parentidMap.keySet()){
            for(String key1 : pathMap.keySet()){
                if(parentidMap.get(key) == key1){
                    heirarchypathwrapper hpath = new heirarchypathwrapper();
                    hpath.path = pathMap.get(key1);
                    hpath.prodId = key;
                    hpath.parentId = parentidMap.get(key);
                    heirarchypath.add(hpath);
                    System.debug('pathMap.get(key)#-->'+pathMap.get(key));
                    System.debug('parentidMap.get(key)#-->'+parentidMap.get(key));
                    System.debug('key#-->'+key);                   
                }
            }
        }
        return heirarchypath;
    }   
    
    Public class SubscriptionAndProductMapWrapper {
        public String productId{get; set;}
    }
    public class heirarchypathwrapper{
        public String prodId{get; set;}
        public String parentId{get; set;}
        public String path{get; set;}
    }
    public class SubscriptionAndProductMapwrap {
        public String methodName {get; set;}
        public String productId {get; set;}
        public String cartId {get; set;}
        public List<Itemswrap> items{get;set;}
        public Boolean validate{get;set;}
        public Boolean price{get;set;}
    }
    
    public class SubscriptionAndProductMapResponseWrap {
        public String methodName {get; set;}
        //public String productId {get; set;}
        public String cartId {get; set;}
        public List<Itemswrap> items{get;set;}
        public Boolean validate{get;set;}
        public Boolean price{get;set;}
    }
    
    public class ParentRecordwrap {
        public List<Recordswrap> records{get; set;}
    }
    
    public class Itemswrap {
        public String itemId{get; set;}
        public String parentId{get; set;}
        public ParentRecordwrap parentRecord{get; set;}
    }
    
    public class Recordswrap {
        public String productHierarchyPath{get; set;}
        public String parentHierarchyPath{get; set;}
    }
    public class BundleAndCart{
        public String QuoteId{get; set;}
        public String BundleId{get; set;}
    }
    public class SelectedHardwareProductListWrapper {
        public String Name;
        public String Id;   
        public String ProductId;    
        public String Code; 
    }
    
}