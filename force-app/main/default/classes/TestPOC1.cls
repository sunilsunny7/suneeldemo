global with sharing class TestPOC1 implements vlocity_cmt.VlocityOpenInterface2
{
    global boolean invokeMethod(String methodName,Map<String,Object> input,Map<String,Object> output,Map<String,Object> options){
        if(methodname.equals('reArrangeLineItem')){
            reArrangeLineItem(input,output,options);
        }
        return true;
    }
    
    public static void reArrangeLineItem(Map<String,Object> input,Map<String,Object> output,Map<String,Object> options){
       // system.debug((List<Object>)input.get('SelectedOffers'));
        List<Object> selectedOffers =(List<Object>)input.get('SelectedOffers');
        Set<String> rootIds = new Set<String>();
        for(Object offer:selectedOffers ){
            //Map<String,Object> offerMap =  (Map<String,Object>)offer;
             Object rootProid = ((Map<String, Object>) offer).get('Id');
            	rootIds.add(String.valueOf(rootProid));
        }
        
		system.debug(rootIds);
        List<qli> qliListMap = (List<qli>)JSON.deserialize(JSON.serialize(input.get('QLI')),List<qli>.class);
        List<qliRoot> qliList = new List<qliRoot>();
        Map<String,List<qliRoot>> qliChildMap = new Map<String,List<qliRoot>>();
        for(qli item: qliListMap){
            if(item.parentItemId=='root'){
                qliRoot root = new qliRoot(item.name,item.productCode,item.offerType,item.assetReferenceId,item.parentItemId,item.rootItem, item.BindingTime, item.oneTimeCharge,item.recPrice, item.faQty);
                qliList.add(root);
            }
            else{
                List<qliRoot> childItemList = new List<qliRoot>();
                if(qliChildMap.containsKey(item.parentItemId)){
                    childItemList = qliChildMap.get(item.parentItemId);
                }
                childItemList.add(new qliRoot(item.name,item.productCode,item.offerType,item.assetReferenceId,item.parentItemId,item.rootItem,item.BindingTime, item.oneTimeCharge,item.recPrice, item.faQty));
                qliChildMap.put(item.parentItemId,childItemList);
            }
        }
        for(qliRoot root:qliList){
            recursiveQliStructure(root,qliChildMap);
        }
        system.debug(JSON.serialize(qliList));
        output.put('QLIRestructured',(List<Object>)JSON.deserializeUntyped(JSON.serialize(qliList)));
    }
    
    public static void recursiveQliStructure(qliRoot root,Map<String,List<qliRoot>> qliChildMap){
        try{
            if(qliChildMap.containsKey(root.assetReferenceId)){
                root.childItem =  qliChildMap.get(root.assetReferenceId);
                for(qliRoot qliItem:qliChildMap.get(root.assetReferenceId)){
                    recursiveQliStructure(qliItem,qliChildMap);
                }            
            }
        }
        catch(Exception e){
            system.debug(e);
        }
    }
    
    public class qli{
        String name,assetReferenceId, productCode,offerType,qliId,parentItemId,rootItem,productOffertype,heraReferenceNumber,heraType,prodId,QuoteId,subscription,bindingTime,campaignId,rootProduct,productHierarchyPath,quoteGroupId,quoteMemberId,baseQuantity,objectTypeName;
        decimal recPrice,faQty,initialOrderQty,listPrice,oneTimeCharge,requestedPrice,TargetPrice,effectiveQty,sequencenumber;
        boolean excludeItem;
    }
    
    public class qliRoot{
        String name, productCode,offerType,assetReferenceId,parentItemId,rootItem,bindingTime;
        Decimal oneTimeCharge,recPrice,faQty;
        
        List<qliRoot> childItem;
        qliRoot(String name,String productCode,String offerType,String assetReferenceId,String parentItemId,String rootItem, String bindingTime, Decimal oneTimeCharge,Decimal recPrice, Decimal faQty){
            this.name = name;
            this.oneTimeCharge = oneTimeCharge;
            this.recPrice = recPrice;
            this.bindingTime = bindingTime;
            this.productCode = productCode;
            this.offerType = offerType;
            this.assetReferenceId = assetReferenceId;
            this.parentItemId = parentItemId;
            this.rootItem = rootItem;
            this.faQty = faQty;
        }
    }
}