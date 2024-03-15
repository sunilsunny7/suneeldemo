global class TeliaSE_UpdateOfferQuotePrices implements vlocity_cmt.VlocityOpenInterface2{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
   
            if(methodName.equalsIgnoreCase('UpdateQuantity')) {
                updateQuantity(inputMap, outMap);
            }       
        return result;
    }
    
    public static void updateQuantity(Map<String,Object> inputMap , Map<String,Object> outputMap)
    {
        
        /*
        //LTAART-328: Commented this class as we have moved this logic to MC_OfferDocHelper class
        Map<String,Double> onetimeOverride = new Map<String,Double>();
        String offerQuoteId = String.valueOf(inputMap.get('OfferQuoteId'));
        String faQuoteId = String.valueOf(inputMap.get('ContextId'));
        Boolean contractExists = (Boolean)inputMap.get('ContractExists');
        Boolean checkCO = (Boolean)inputMap.get('CheckCO');
        List<Object> coGroupList = new List<Object>();
        List<integer> heraIndex = new List<integer>();
        if(inputMap.containsKey('COGroupMap')){
            coGroupList = (List<Object>)inputMap.get('COGroupMap');
        }
        Map<String,Object> coGroupMap = new Map<String,Object>();
        if(coGroupList.size()>0)
        {
            for(Object obj:coGroupList)
            {
                Map<String,Object> objMap = (Map<String,Object>) obj;
                coGroupMap.put((String)objMap.get('Product2Id'),obj);
            }    
        }
        
        Map<String,MC_OfferCreation_ObjSplit__c> objTypes = MC_OfferCreation_ObjSplit__c.getAll();
        List<Object> bQli = new List<Object>();
        
        //get FA QLI List from DR
        object faQli = (Object)inputMap.get('FAQLI');
        String qliJson = json.serialize(faQli);
        List<faQLI> faQliList = (List<faQLI>)JSON.deserialize(qliJson, List<faQLI>.class);        
        // Get OTC Override products for CO
        if(inputMap.get('BQLI') != null){
            bQli = (List<Object>)inputMap.get('BQLI');
        }
        for(Object binding:bQli){
            Map<String,Object> bind = (Map<String,Object>)binding;
            String productCode = (String)bind.get('ProductCode');
            Double oneTimePrice = (Double)bind.get('oneTimeprice');
            onetimeOverride.put(productCode,oneTimePrice);
        }
        
        // get CO product ObjectType to bidning time Map
        Map<String,String> offerTobindmap = new Map<String,String>();
        if(inputMap.get('offerTypeToBindingPeriodMap') !=null){//Added By Abhishek for CO Binding Time improvement
            Map<String, Object> offerTypeToBindingPeriodMap = (Map<String,Object>)(inputMap.get('offerTypeToBindingPeriodMap'));
            for(String strKey: offerTypeToBindingPeriodMap.keyset())
            {
                offerTobindmap.put(String.valueof(strKey), String.valueof(offerTypeToBindingPeriodMap.get(strKey)));
            }
        }        
        
        DescribeSObjectResult describeResult = QuoteLineItem.getSObjectType().getDescribe();    
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet());  
        fieldNames.add('Product2.Name');
        fieldNames.add('Product2.ProductCode');
        fieldNames.add('Product2.Id');
        fieldNames.add('Product2.TeliaSE_Product_Type__c');
        //fieldNames.add('TeliaSE_ParentClusterCode__c');
        String query =    ' SELECT ' +        String.join( fieldNames, ',' ) +    ' FROM ' +          describeResult.getName()  + ' WHERE ' + ' QuoteId = :offerQuoteId';   
        List<QuoteLineItem> offQliList = Database.query( query );
        List<String> productCodesInOffer = new List<String>();
        Map<String,faQLI> faQLIMap = new Map<String,faQLI>();
        if (FaqliList.size()>0)
        {
            for(faQLI qli:FaqliList)
            {
                faQLIMap.put(qli.ProductCode,qli);
                productCodesInOffer.add((String)qli.ProductCode);
            }
        }
        List<CO_BindingOTC__c> otcSet = [select Id,Name,ProductCode__c, ProductName__c, Code0M__c, Price0M__c, Code12M__c, Price12M__c, Code24M__c, Price24M__c,  Code36M__c, Price36M__c, Group__c from CO_BindingOTC__c where ProductCode__c in: productCodesInOffer];
        //System.debug('line 91: '+otcSet.size());
        //System.debug(otcSet);
        string offQliObjectType,offqliProductCode,prodType;
        Set<String> coObjectTypes = new Set<String>{'Broadband Start Offering Spec','Broadband Pro Offering Spec','Broadband Plus Offering Spec','Broadband Datanet Offering Spec','SD-WAN/Firewall Offering Spec','WIFI/LAN Offering Spec','Connected Office Offer Spec'};
            
        List<QuoteLineItem> qliListUpdated = new List<QuoteLineItem>();
        List<QuoteLineItem> coGroupedItems = new List<QuoteLineitem>();
        Map<String,Integer> alreadyUpdatedItemsIndex = new Map<String,Integer>();
        Integer j=0;
        Boolean isCO = false;
        for(quotelineitem offqli : offQliList)
        {
            offQliObjectType = offqli.TeliaSE_Product_Object_Type__c;
            isCO = coObjectTypes.contains(offQliObjectType);
            offqliProductCode = offqli.product2.productCode;
            prodType=offqli.product2.TeliaSE_Product_Type__c;
            //method to update recurring price for b2b products
            //we pass only b2b product, call is b2b check is true
            //offqli, faqliMap
            //offqli ke corresponding, we find a faqli.
            //get binding period, get list pricing (ceilingprice), get discount percentage (if requested, then requested, if requested is blank, then target percentage) 
            //Now calculate final price on offqli. 
            //send this offqli back to section.
            if(System.label.B2BSolution_Toggle=='true' && prodType=='Percentage'){
                offqli=B2BPriceCalculation(faQLIMap ,offqliProductCode,offerTobindmap,offqli); 
            }
            
            if(objTypes.containsKey(offQliObjectType) && offqli.get(objTypes.get(offQliObjectType).fieldsToAdd__c) != null){
                offqliProductCode = offqliProductCode + offqli.get(objTypes.get(offQliObjectType).fieldsToAdd__c);
            }else{
                offqliProductCode = offqli.TeliaSE_ParentClusterCode__c != null ? offqliProductCode + offqli.TeliaSE_ParentClusterCode__c : offqliProductCode;
            }
            
            if(faQLIMap.containskey(offqliProductCode) && 
               (!isCO || (isCO && coGroupList.size()<=0)  || (isCO && offqli.TeliaSE_Offer_Type__c == 'Non-SubscriptionOffering') || (isCO && (boolean)faQLIMap.get(offqliProductCode).ExcludeItem)))
            {
                //System.debug('line 103: ' + offqli.product2.name + ' productCode: ' +offqli.product2.productCode);
                faQLI faqli2 = faQLIMap.get(offqliProductCode);
                QuoteLineItem offQliUpdated = new QuoteLineItem();
                offQliUpdated.id = offQli.id;
                if(offerTobindmap.containsKey(offqli.TeliaSE_Product_Object_Type__c))
                {
                    offQliUpdated.TeliaSE_MC_Binding_Time__c = offerTobindmap.get(offqli.TeliaSE_Product_Object_Type__c);
                    offQliUpdated = overrideOTC(offQliUpdated,otcSet,onetimeOverride,offqliProductCode);
                }
                offQliUpdated.vlocity_cmt__EffectiveQuantity__c =faqli2.Quantity;
                offQliUpdated.TeliaSE_Base_Quantity__c = faqli2.BaseQuantity;
                offQliUpdated.MC_Initial_Order_Quantity__c = faqli2.InitialOrderQuantity;
                offQliUpdated.vlocity_cmt__SequenceNumber__c = faqli2.SequenceNumber; //Arup
                offQliUpdated.MC_TeliaExcludeQuoteItem__c = faqli2.ExcludeItem;
                offQliUpdated.vlocity_cmt__RecurringCharge__c = offqli.vlocity_cmt__RecurringCharge__c; 
                qliListUpdated.add(offQliUpdated);
                alreadyUpdatedItemsIndex.put(offqliProductCode,qliListUpdated.size()-1);
                
            }
            else if(offQliObjectType == 'Connected Office Offer Spec')
            {
                heraIndex.add(j);
            }
               //System.debug(offqliProductCode+'NMP');
            if(isCO && coGroupList.size()>0 && ((faQLIMap.containsKey(offqliProductCode) && !faQLIMap.get(offqliProductCode).ExcludeItem) || !faQLIMap.containsKey(offqliProductCode)))
            {
                //System.debug('line 126: ' + offqli.product2.name + ' productCode: ' +offqli.product2.productCode);
                coGroupedItems.add(offQli);
            }
            j++;
        }   
        List<QuoteLineItem> clonesNeeded = new List<QuoteLineItem>();
        if(checkCO)
        {
            List<Object> heraPrices= (List<Object>)inputMap.get('HERAPriceUpdate');
            // Update Hera Prices START
            for(Integer hera:heraIndex){                
                for(Object obj:heraPrices){
                    Map<String,Object> capturedMap = (Map<String,Object>)obj;
                    if((capturedMap.get('vlocity_cmt__QuoteMemberId__c')!=null && 
                       (capturedMap.get('vlocity_cmt__QuoteMemberId__c') == offQliList.get(hera).vlocity_cmt__QuoteMemberId__c )) && 
                       (capturedMap.get('MC_HeraReferenceNumber__c') == offQliList.get(hera).MC_HeraReferenceNumber__c) &&
                       (capturedMap.get('MC_HeraType__c') == offQliList.get(hera).MC_HeraType__c)){
                        QuoteLineItem updatedHera = new QuoteLineItem();
                        updatedHera.Id = offQliList.get(hera).Id;
                        updatedHera.vlocity_cmt__OneTimeCharge__c = (Decimal)capturedMap.get('vlocity_cmt__OneTimeCharge__c');
                        updatedHera.vlocity_cmt__RecurringCharge__c = (Decimal)capturedMap.get('vlocity_cmt__RecurringCharge__c');
                       //LTAT-6041 - Secondary Access - Add Hera Type
                           updatedHera.MC_HeraReferenceNumber__c = (String)capturedMap.get('MC_HeraReferenceNumber__c');
                           updatedHera.MC_HeraType__c = (String)capturedMap.get('MC_HeraType__c');
                        qliListUpdated.add(updatedHera);
                    }
                }
            }
            //Update Hera prices END
            //Grouping Scenario starts            
            if(coGroupList.size()>0)
            {
                for(QuoteLineItem qli: coGroupedItems)                    
                {
                    offqliProductCode = qli.product2.productCode;
                    //qli = overrideOTC(qli,otcSet,onetimeOverride,offqliProductCode);
                    //System.debug('line 169: '+offqliProductCode+qli.vlocity_cmt__OneTimeCharge__c);
                    //System.debug('line 166: '+ coGroupMap.containsKey(string.valueOf(qli.product2Id)));
                    //System.debug('product2Id: '+(String)qli.product2Id);
                    ////System.debug('line 168: '+json.serialize(coGroupMap));

                    if(coGroupMap.containsKey((String)qli.product2Id)){
                        Map<String,Object> copdtMap = (Map<String,Object>)coGroupMap.get((String)qli.product2Id);
                        if(copdtMap.containskey('Groups')){
                            List<Object> groupList = (List<Object>)copdtMap.get('Groups');
                            for(Integer i=0;i<groupList.size();i++){
                                Map<String,Object> groupMap = (Map<String,Object>)groupList[i];
                                QuoteLineItem ql = new QuoteLineItem();
                                if(i==0){
                                    ql = mapQuoteLineItems(qli, groupMap, copdtMap, faQLIMap, offerTobindmap, false,otcSet,onetimeOverride);                                                                                                        
                                    if(alreadyUpdatedItemsIndex.containskey(offqliProductCode)){
                                        qliListUpdated.set(alreadyUpdatedItemsIndex.get(offqliProductCode),ql);
                                    }
                                    else{
                                        qliListUpdated.add(ql);    
                                    }  
                                }
                                else{
                                    ql = mapQuoteLineItems(qli, groupMap, copdtMap, faQLIMap, offerTobindmap, true,otcSet,onetimeOverride);
                                    clonesNeeded.add(ql);
                                }
                            }
                        }                    
                    }
                }
            }            
        }
        
        if(qliListUpdated.size()>0)
        {
            try{                
                upsert qliListUpdated;    
            }
            catch(Exception e)
            {
                //System.debug(e.getStackTraceString());
                throw e;
            }            
        }
    if(clonesNeeded.size()>0)
        {
            try{
              insert clonesNeeded;    
            }
            catch(Exception e)
            {
                //System.debug(e.getStackTraceString());
                throw e;
            }
        }
        reparentGroupedItems(offerQuoteId);
        Boolean faQuoteLocked=(Boolean)inputMap.get('isLocked');//Added by Abhishek for quote lock unlock issue            
        //Lock the FA Quote after quote group insertion
        if((faQuoteLocked==true && (!Approval.isLocked(faQuoteId)) && contractExists)){//Retaining initial state of the quote
            Approval.lock(faQuoteId);
        }
*/
    }
    /*
    public static QuoteLineItem overrideOTC (QuoteLineItem qli , List<CO_BindingOTC__c> otcSet,Map<String,Double> onetimeOverride, string productCode)
    {
        for(CO_BindingOTC__c obj : otcSet)
        {
            if(productCode == obj.ProductCode__c)
            {
                if(qli.TeliaSE_MC_Binding_Time__c =='0'){//Changed by Abhishek for CO improvement
                    if(onetimeOverride.get(obj.Code0M__c) == null){
                        qli.vlocity_cmt__OneTimeCharge__c = (obj.Price0M__c !=null ? obj.Price0M__c : 0 ) ;
                    }else{
                        qli.vlocity_cmt__OneTimeCharge__c = onetimeOverride.get(obj.Code0M__c);
                    }
                }else if(qli.TeliaSE_MC_Binding_Time__c =='12'){
                    if(onetimeOverride.get(obj.Code12M__c) == null){
                        qli.vlocity_cmt__OneTimeCharge__c = (obj.Price12M__c !=null ? obj.Price12M__c : 0 );
                    }else{
                        qli.vlocity_cmt__OneTimeCharge__c = onetimeOverride.get(obj.Code12M__c);
                    }
                }else if(qli.TeliaSE_MC_Binding_Time__c =='24'){
                    if(onetimeOverride.get(obj.Code24M__c) == null){
                        qli.vlocity_cmt__OneTimeCharge__c = (obj.Price24M__c !=null ? obj.Price24M__c : 0 );
                    }else{
                        qli.vlocity_cmt__OneTimeCharge__c = onetimeOverride.get(obj.Code24M__c);
                    }
                }else if(qli.TeliaSE_MC_Binding_Time__c =='36'){
                    if(onetimeOverride.get(obj.Code36M__c) == null){
                        qli.vlocity_cmt__OneTimeCharge__c = (obj.Price36M__c !=null ? obj.Price36M__c : 0 );
                    }else{
                        qli.vlocity_cmt__OneTimeCharge__c =onetimeOverride.get(obj.Code36M__c);
                        
                    }
                }
                break;
            }
        }
        return qli;
        
    }
    
    public static void reparentGroupedItems(String offerQuoteId){
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        Map<String,Object> groupQLIItems = new Map<String,Object>();
        for(QuoteLineItem eachQli : [Select Id,Product2.ProductCode,vlocity_cmt__AssetReferenceId__c,vlocity_cmt__QuoteGroupId__c, Quantity,Product2Id, vlocity_cmt__ParentItemId__c,vlocity_cmt__ProductHierarchyPath__c,  vlocity_cmt__RootItemId__c,TeliaSE_Root_Product__c from QuoteLineItem where QuoteId =: offerQuoteId and vlocity_cmt__QuoteGroupId__c != null order by vlocity_cmt__QuoteGroupId__c ] ){
            if(groupQLIItems.get(eachQli.vlocity_cmt__QuoteGroupId__c) != null){
                List<QuoteLineItem> qliList1 = (List<QuoteLineItem>)groupQLIItems.get(eachQli.vlocity_cmt__QuoteGroupId__c);
                qliList1.add(eachQli);
                groupQLIItems.put((String)eachQli.vlocity_cmt__QuoteGroupId__c, qliList1);
            }else{
                List<QuoteLineItem> qliList1 = new List<QuoteLineItem>();
                qliList1.add(eachQli);
                groupQLIItems.put((String)eachQli.vlocity_cmt__QuoteGroupId__c, qliList1);                
            }
        }
        for(String key : groupQLIItems.keyset()){
            Map<String,QuoteLineItem> parentQLIMap = new Map<String,QuoteLineItem>();
            for(QuoteLineItem eachQli : (List<QuoteLineItem>)groupQLIItems.get(key)){
                if(eachQli.vlocity_cmt__ParentItemId__c == null || test.isRunningTest()){
                    parentQLIMap.put((string)eachQli.Product2Id, eachQli);
                    //23.10 <<LTAART-356>> AssetReferenceId change - <<Sanjoli>>                    
                    eachQli.vlocity_cmt__RootItemId__c = eachQli.vlocity_cmt__AssetReferenceId__c;
                    qliList.add(eachQli);                    
                }
            }
            for(QuoteLineItem eachQli : (List<QuoteLineItem>)groupQLIItems.get(key)){
                if(eachQli.vlocity_cmt__ParentItemId__c != null){
                    String parentProductId = eachQli.vlocity_cmt__ProductHierarchyPath__c.split('<',6)[0];
                    QuoteLineItem parentQli = parentQLIMap.get(parentProductId);
                    //23.10 << LTAART-356>> AssetReferenceId change - <<Sanjoli>>
                    eachQli.vlocity_cmt__ParentItemId__c = parentQli.vlocity_cmt__AssetReferenceId__c;
                    eachQli.vlocity_cmt__RootItemId__c = parentQli.vlocity_cmt__AssetReferenceId__c;
                    eachQli.TeliaSE_Root_Product__c = parentQli.Product2Id;
                    qliList.add(eachQli);
                }
            }
        }
        
        if(qliList.size() > 0){
            try{
                update qliList;
            }catch(Exception e){
                //System.debug('Exception on reparenting DML'+e.getStackTraceString());
            }
        }        
    }
    
    public static QuoteLineItem mapQuoteLineItems(QuoteLineItem qli,Map<String,Object> groupMap,Map<String,Object> copdtMap,Map<String,faQLI> faQLIMap,Map<String,String> offerTobindmap,boolean clone,List<CO_BindingOTC__c> otcSet,Map<String,Double> onetimeOverride)
    {
        string offqliProductCode = qli.product2.productCode;
        String prodType=qli.product2.TeliaSE_Product_Type__c;
        if(System.label.B2BSolution_Toggle=='true' && prodType=='Percentage'){
            qli=B2BPriceCalculation(faQLIMap,offqliProductCode,offerTobindmap,qli);
        }
        QuoteLineItem ql = new QuoteLineItem();
        if(clone){
            ql = qli.clone(false,true);
        }
        else{
            ql.Id = qli.Id;
        }        
        ql.Quantity = (Integer)groupMap.get('Quantity');
        ql.vlocity_cmt__OneTimeManualDiscount__c = qli.vlocity_cmt__OneTimeManualDiscount__c;
        ql.vlocity_cmt__RecurringManualDiscount__c= qli.vlocity_cmt__RecurringManualDiscount__c;                                   
        ql.vlocity_cmt__EffectiveQuantity__c = (Integer)groupMap.get('Quantity');
        ql.vlocity_cmt__QuoteGroupId__c = Id.valueOf((String)groupMap.get('GroupId'));
        ql.vlocity_cmt__RecurringCharge__c = qli.vlocity_cmt__RecurringCharge__c;
        //ql.vlocity_cmt__OneTimeCharge__c = qli.vlocity_cmt__OneTimeCharge__c;
        faQLI faqliGrouped = faQLIMap.get(offqliProductCode);
        ql.MC_TeliaExcludeQuoteItem__c = faqliGrouped.ExcludeItem;
        ql.TeliaSE_Base_Quantity__c = faqliGrouped.BaseQuantity;
        ql.MC_Initial_Order_Quantity__c = faqliGrouped.InitialOrderQuantity;
        ql.vlocity_cmt__SequenceNumber__c = faqliGrouped.SequenceNumber;
        if(offerTobindmap.containsKey(qli.TeliaSE_Product_Object_Type__c)){
            ql.TeliaSE_MC_Binding_Time__c  = offerTobindmap.get(qli.TeliaSE_Product_Object_Type__c);    
        }
        if(!test.isRunningTest()){
          ql = overrideOTC(ql, otcSet, onetimeOverride, offqliProductCode);  
        } 
        return ql;
    }
    //This method is used to calculate discount over the B2B products
    public static quotelineitem B2BPriceCalculation(Map<String,faQLI> faQLIMap ,String offqliProductCode,Map<String,String> offerTobindmap,quotelineitem offqli)
    {
        String bindTime;
        Decimal recCharg,finAmt,bindDisc,reqDis;
        List<String> Product=new List<String>{'B2B-BBPRO-100MB','B2B-BBPRO-250MB','B2B-BBPRO-500MB','B2B-BBPRO-1000MB','B2B-BBPRO-2000MB','B2B-BBPRO-5000MB','B2B-BBPRO-10000MB','B2B-BBF-10MB','B2B-BBF-50MB','B2B-BBF-100MB','B2B-BBF-250MB','B2B-BBF-500MB','B2B-BBF-1000MB'};
        faQLI ql=new faQLI(); 
        ql=faQLIMap.get(offqliProductCode); 
        if(ql !=null){
        recCharg=ql.CeilingPrice;
        if(offerTobindmap.containsKey(offqli.TeliaSE_Product_Object_Type__c)){
            bindTime = offerTobindmap.get(offqli.TeliaSE_Product_Object_Type__c);    
        }
        
        if(ql.RequestedPercentage !=null){
            reqDis=ql.RequestedPercentage;   
        }
        else if(ql.TargetPercentage!=null){
            reqDis=ql.TargetPercentage;
        }
        else{
            reqDis=0;  
        }
        if(Product.Contains(offqliProductCode)) {
            if(bindTime=='12'){
                bindDisc=50;
            }
            else if(bindTime=='24'){
                bindDisc=100;
            }
            else if(bindTime=='36'){
                bindDisc=150;
            }
            else{
                bindDisc=0;
            }
            
            if(reqDis !=0){
                finAmt=(recCharg-bindDisc)-(((recCharg-bindDisc)*reqDis)/100);
            }
            else{
                finAmt=(recCharg-bindDisc);
            }
            
        }else if(reqDis !=0){
            finAmt=recCharg-((recCharg*reqDis)/100);
        }
        else{
            finAmt=recCharg;
        } 
        offqli.vlocity_cmt__RecurringCharge__c=finAmt;  
        }       
        return offqli;
    }
    
    public class faQLI {
        public boolean ExcludeItem;
        public Double Quantity;
        public String Name;
        public Double RecurringPrice;
        public Double OneTimePrice;
        public Double ApprovedPrice;
        public Double ApprovedPercentage;
        public Double RequestedPercentage;
        public String Subscription;
        public String ProductType;
        public Double TargetPercentage;
        public Double OneTimeManualDiscount;
        public Double RecurringManualDiscount;
        public String campaignId;
        public string ProductCode;
        public String ProductId;
        public String ProductObjectType;
        public String BaseQuantity;
        public Double InitialOrderQuantity;
        public Double SequenceNumber;
        public Double CeilingPrice; 
    }
*/
}