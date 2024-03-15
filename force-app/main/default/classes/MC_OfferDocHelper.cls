/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_OfferDocHelper 
**Created By  :        Pancham Verma
**User Story  :        LTAART-328
**Release     :        24.01
**Updated By  : 	   Sanjoli Agrawal for sending restructured JSON to flexcard in Quantity Capture flow.
**Description :        This class is used to create SimplifiedLineItems used for Offer document generation.
-----------------------------------------------------------------------------------------------------------*/
global with sharing class MC_OfferDocHelper implements vlocity_cmt.VlocityOpenInterface2
{
    global boolean invokeMethod(String methodName,Map<String,Object> input,Map<String,Object> output,Map<String,Object> options){
        if(methodName.equals('offerDocumentLineItems')){
            offerDocumentLineItems(input,output);
        }else if(methodName.equals('simplifiedLineItems')){
            simplifiedLineItems(input,output);
        }else if(methodName.equals('coUpdateHera')){
            coUpdateHera(input,output);
        }
        else if(methodname.equals('reArrangeLineItem')){
            reArrangeLineItem(input,output,options);
        }
        else if(methodname.equals('saveQuantitiesOnFA')){
            saveQuantitiesOnFA(input,output,options);
        }
        return true;
    }    
    /*______________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is used to create a list of FA cart lineItems which will be shown in the Offer document.
*___________________________________________________________________________________________________________
* params - input  -  list of FA cart lineItems from the DataRaptor 
* params - output - list of filtered lineItems to be shown in the document
*/ 
    public static void offerDocumentLineItems(Map<String,Object> input,Map<String,Object> output){
        try{
            List<qli> qliListMap = (List<qli>)JSON.deserialize(JSON.serialize(input.get('QLI')),List<qli>.class);
            List<String> selectedIds =input.get('selectedOffer')<> NULL ? String.valueOf(input.get('selectedOffer')).split(','): NULL ;
            Boolean quantityCaptureToggle = Boolean.valueOf(input.get('quantityCaptureToggle'));
            List<qli> qliListToBeAdded = new List<qli>();
            Map<String,qli> qliMap = new Map<String,qli>();
            Map<String,String> offerTypeToBindingPeriodMap=new Map<String,String>();
            Map<String,Decimal> oneTimeOverrideMap = new Map<String,Decimal>();
            Set<qli> qliListToBeAdded2 = new Set<qli>();
            for(qli item:qliListMap){
            if(!quantityCaptureToggle ||(quantityCaptureToggle && selectedIds.size()>0 && selectedIds.contains(item.rootItem))){
                if(item.parentItemId != 'root'){
                    qliMap.put(item.assetReferenceId,item);
               }
                    if(item.faQty >=0){
                        if(item.salesFlowIdentifier != 'Tilläggsförhandling'){
                        qliListToBeAdded.add(item);    
                    }
                    else if(item.salesFlowIdentifier == 'Tilläggsförhandling' && item.lineStatus != 'Existing'){
                        qliListToBeAdded.add(item);
                    }
                }
                if(item.parentItemId=='root' && item.bindingTime !=null && item.objectTypeName != 'OFFICE365 Offer Spec'){
                    offerTypeToBindingPeriodMap.put(item.objectTypeName,(String)(item.bindingTime));      
                } 
                if(item.objectTypeName=='Binding OTC Offering Spec'){
                    oneTimeOverrideMap.put(item.productCode,(Decimal)(item.oneTimeCharge));  
                } 
            }}
            for(qli item1:qliListToBeAdded){
                qliListToBeAdded2.add(item1);
                qli addedQli = item1;
                while(qliMap.containsKey(addedQli.parentItemId)){
                    qliListToBeAdded2.add(qliMap.get(addedQli.parentItemId));
                    addedQli = qliMap.get(addedQli.parentItemId);
                }
            }
            output.put('offerTypeToBindingPeriodMap',(Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(offerTypeToBindingPeriodMap)));
            output.put('oneTimeOverrideMap',(Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(oneTimeOverrideMap)));
            output.put('FinalAdded',(List<Object>)JSON.deserializeUntyped(JSON.serialize(qliListToBeAdded2))); 
        }catch(Exception e){
            System.debug('Exception: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            output.put('offerQuoteError',true);
        }
    }
    /*__________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is used to create simplifiedLineItems from the FA cart quoteLineItems
*___________________________________________________________________________________________________________
* params - input - list of filtered lineItems passed from offerDocumentLineItems method
*/ 
    public static void simplifiedLineItems(Map<String,Object> input,Map<String,Object> output){    
        try{
            Decimal finalPrice;
            TeliaSE_SimplifiedQuoteLineItem__c simplifiedItem;
            String offerQuote = (String)input.get('OfferQuoteId');
            //Delete existing simplified lineItems        
            delete [SELECT id FROM TeliaSE_SimplifiedQuoteLineItem__c WHERE QuoteId__c =:offerQuote AND ProductName__c != 'HERA XYZ'];
            
            Map<String,Object> otcMap = new Map<String,Object>();
            Map<String,Object> offerTypeToBindingPeriodMap = (Map<String,object>)input.get('offerTypeToBindingPeriodMap');
            Map<String,Object> oneTimeOverrideMap = (Map<String,Object>)input.get('oneTimeOverrideMap');
            List<qli> qliListMap = (List<qli>)JSON.deserialize(JSON.serialize(input.get('FinalAdded')),List<qli>.class);
            List<TeliaSE_SimplifiedQuoteLineItem__c> simplifiedItems=new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            List<String> productCodesInOffer = new List<String>();
            List<String> excludedObjectTypes = new List<String>();
            Set<Object> parentItemIds = new Set<Object>();   
            MC_ExclusionInclusionList__c excluded= MC_ExclusionInclusionList__c.getAll().get('RemoveOneTimePricingForICT');
            if(excluded != null && excluded.Scenario__c == 'OneTimeFeeNotCalculatedForSimplifiedLineItem' && excluded.Exclude__c){
                excludedObjectTypes.add(excluded.ObjectType__c);   
            } 
            for (qli item:qliListMap){
                if(item.objectTypeName != 'Virtual Offer Products'){
                    parentItemIds.add(item.assetReferenceId);    
                }
                if(offerTypeToBindingPeriodMap.containsKey(item.objectTypeName)){
                    productCodesInOffer.add((String)item.ProductCode);
                }
            }
            List<CO_BindingOTC__c> otcSet = [SELECT Id,Name,ProductCode__c, ProductName__c, Code0M__c, Price0M__c, Code12M__c, Price12M__c, Code24M__c, Price24M__c,  Code36M__c, Price36M__c, Group__c FROM CO_BindingOTC__c WHERE ProductCode__c IN: productCodesInOffer];
            for(CO_BindingOTC__c otc :otcSet){
                otcMap.put(otc.ProductCode__c,otc);    
            }
            for(qli item:qliListMap){
                if(offerTypeToBindingPeriodMap.containsKey(item.objectTypeName)){
                    item.bindingTime = ((string)offerTypeToBindingPeriodMap.get(item.objectTypeName));
                    coUpdateOTC(item, otcMap, oneTimeOverrideMap);
                }
                if (item.discountPercentage != null && item.productType =='Percentage'){
                    finalPrice=item.recPrice-((item.recPrice*(item.discountPercentage))/100);
                    finalPrice = finalPrice.setScale(2, RoundingMode.HALF_UP);
                }
                else{
                    finalPrice = item.recPrice;
                }
                if(System.label.B2BSolution_Toggle=='true'&& item.productType =='Percentage' && offerTypeToBindingPeriodMap.containsKey(item.objectTypeName)){
                    priceCalculationB2B(item); 
                }
                simplifiedItem=new TeliaSE_SimplifiedQuoteLineItem__c();
                simplifiedItem.Product__c=item.prodId;
                simplifiedItem.QuoteId__c=offerQuote;
                simplifiedItem.MC_Sequence_Number__c = item.sequencenumber;
                simplifiedItem.Quote_Member__c=item.quoteMemberId;
                simplifiedItem.TeliaSE_BaseQuantity__c = item.baseQuantity;
                simplifiedItem.Quote_Group__c=item.quoteGroupId;            
                simplifiedItem.TeliaSE_MC_Campaign_Id__c = item.campaignId;           
                simplifiedItem.TeliaSE_Offer_Type__c = item.offerType;
                simplifiedItem.MC_HeraReferenceNumber__c = item.heraReferenceNumber;
                simplifiedItem.MC_HeraType__c = item.heraType;
                simplifiedItem.TeliaSE_OnetimeCharge__c=excludedObjectTypes.contains(item.objectTypeName) ? item.oneTimeCharge / item.faQty : Math.roundToLong(item.oneTimeCharge);
                simplifiedItem.TeliaSE_List_Price__c= excludedObjectTypes.contains(item.objectTypeName) ? finalPrice: Math.roundToLong(finalPrice);
                simplifiedItem.TeliaSE_Aggregated_Quantity__c=(item.faQty == null || item.faQty == 0) ? 1: item.faQty;
                simplifiedItem.MC_Initial_Order_Quantity__c =item.initialOrderQty;
                simplifiedItem.TeliaSE_Product_Hierarchy__c=excludedObjectTypes.contains(item.objectTypeName) ? item.productHierarchyPath: item.productHierarchyPath.substring(19);
                simplifiedItem.TeliaSE_Root_Product__c=excludedObjectTypes.contains(item.objectTypeName) ? item.productHierarchyPath: item.productHierarchyPath.substring(19,37);
                simplifiedItem.TeliaSE_MC_Binding_Time__c=item.bindingTime;
                simplifiedItem.Subscription__c=item.subscription;
                simplifiedItem.MC_TeliaExcludeQuoteItem__c= item.faQty == 0 ? true: false;
                simplifiedItem.TeliaSE_Parent_ItemId__c= parentItemIds.contains(item.parentItemId) ? item.parentItemId:null;
                simplifiedItems.add(simplifiedItem);
            }
            if(simplifiedItems.size()>0){
                insert simplifiedItems;
            }  
        }catch(Exception e){
            System.debug('DML Exception: ' + e.getMessage());
            System.debug('DML Exception Stack Trace: ' + e.getStackTraceString());
            output.put('offerQuoteError',true);
        }   
    }
    /*________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is used to create simplifiedLineItems for Hera products.
*___________________________________________________________________________________________________________
* params - input - "HERAPriceUpdate" list passed from the OS that contains Hera information
*/
    public static void coUpdateHera(Map<String,Object> input,Map<String,Object> output){
        try{
            String productId = '';
            string priceBookEntryId = '';
            String offerQuote = (String)input.get('OfferQuoteId');
            TeliaSE_SimplifiedQuoteLineItem__c simplifiedItem;
            List<Object> heraUpdateList = new list<Object>();
            List<TeliaSE_SimplifiedQuoteLineItem__c> heraSimplifiedItems=new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            if(input.get('HERAPriceUpdate') != null && input.get('HERAPriceUpdate') != ''){
                heraUpdateList = (List<Object>)input.get('HERAPriceUpdate');
            }
            if(heraUpdateList.size()>0){ 
                for (Object sli :heraUpdateList){
                    Map<String, Object> sliMap = (Map<String, Object>)sli;
                    priceBookEntryId = Id.valueof((String)sliMap.get('PriceBookEntryId'));
                }
                list<PricebookEntry> pbList= [SELECT id, Product2Id FROM PricebookEntry WHERE Id =:priceBookEntryId];
                if(pbList.size()>0){
                    productId = pbList[0].Product2Id;    
                }
                for (Object sli :heraUpdateList){
                    Map<String, Object> sliMap = (Map<String, Object>)sli;
                    simplifiedItem=new TeliaSE_SimplifiedQuoteLineItem__c();
                    simplifiedItem.QuoteId__c=offerQuote;
                    simplifiedItem.MC_HeraReferenceNumber__c = ((String)sliMap.get('MC_HeraReferenceNumber__c'));
                    simplifiedItem.MC_HeraType__c = ((String)sliMap.get('MC_HeraType__c'));
                    simplifiedItem.TeliaSE_List_Price__c = ((decimal)sliMap.get('vlocity_cmt__RecurringCharge__c'));
                    simplifiedItem.TeliaSE_OnetimeCharge__c = ((decimal)sliMap.get('vlocity_cmt__OneTimeCharge__c'));
                    simplifiedItem.Quote_Member__c = ((String)sliMap.get('vlocity_cmt__QuoteMemberId__c'));
                    simplifiedItem.Quote_Group__c=((String)sliMap.get('vlocity_cmt__QuoteGroupId__c'));
                    simplifiedItem.TeliaSE_Aggregated_Quantity__c=((decimal)sliMap.get('Quantity'));
                    simplifiedItem.TeliaSE_Product_Hierarchy__c=productId;
                    simplifiedItem.TeliaSE_Root_Product__c=productId;
                    simplifiedItem.Product__c = productId;
                    heraSimplifiedItems.add(simplifiedItem);
                }   
            }
            if(heraSimplifiedItems.size()>0){
                insert heraSimplifiedItems;
            }   
        }catch(Exception e){
            System.debug('DML Exception: ' + e.getMessage());
            System.debug('DML Exception Stack Trace: ' + e.getStackTraceString());
            output.put('offerQuoteError',true);
        }
    }
    /*_________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is used to apply One Time Charge override to CO products based on binding period
*___________________________________________________________________________________________________________
*/
    public static qli coUpdateOTC(qli item, Map<String,Object>otcMap, Map<String,Object>oneTimeOverrideMap){
        CO_BindingOTC__c otc= new CO_BindingOTC__c();
        if(otcMap.containsKey(item.productCode))
        {  
            otc = (CO_BindingOTC__c)otcMap.get(item.productCode);
            if(item.bindingTime =='0'){
                item.oneTimeCharge = (oneTimeOverrideMap.containsKey(otc.Code0M__c)? (Decimal)oneTimeOverrideMap.get(otc.Code0M__c): (otc.Price0M__c !=null? otc.Price0M__c: item.oneTimeCharge));  
            }else if(item.bindingTime =='12'){
                item.oneTimeCharge = (oneTimeOverrideMap.containsKey(otc.Code12M__c)? (Decimal)oneTimeOverrideMap.get(otc.Code12M__c): (otc.Price12M__c !=null? otc.Price12M__c: item.oneTimeCharge));   
            }else if(item.bindingTime =='24'){
                item.oneTimeCharge = (oneTimeOverrideMap.containsKey(otc.Code24M__c)? (Decimal)oneTimeOverrideMap.get(otc.Code24M__c): (otc.Price24M__c !=null? otc.Price24M__c: item.oneTimeCharge));  
            }else if(item.bindingTime =='36'){
                item.oneTimeCharge = (oneTimeOverrideMap.containsKey(otc.Code36M__c)? (Decimal)oneTimeOverrideMap.get(otc.Code36M__c): (otc.Price36M__c !=null? otc.Price36M__c: item.oneTimeCharge));  
            } 
        }return item;
    }
    /*________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is used to apply discount on B2B products based on binding period
*___________________________________________________________________________________________________________
*/    
    public static qli priceCalculationB2B(qli item){  
        Decimal bindDisc;
        List<String> product=new List<String>{'B2B-BBPRO-100MB','B2B-BBPRO-250MB','B2B-BBPRO-500MB','B2B-BBPRO-1000MB','B2B-BBPRO-2000MB','B2B-BBPRO-5000MB','B2B-BBPRO-10000MB','B2B-BBF-10MB','B2B-BBF-50MB','B2B-BBF-100MB','B2B-BBF-250MB','B2B-BBF-500MB','B2B-BBF-1000MB'};
            if(product.contains(item.productCode)) {
                if(item.bindingTime=='12'){
                    bindDisc=50;
                }else if(item.bindingTime=='24'){
                    bindDisc=100;
                }else if(item.bindingTime=='36'){
                    bindDisc=150;
                }else{
                    bindDisc=0;
                }
                if(item.discountPercentage!=0){
                    item.recPrice=(item.recPrice-bindDisc)-(((item.recPrice-bindDisc)*item.discountPercentage)/100);
                }else{
                    item.recPrice= item.recPrice-bindDisc;
                } 
            }return item;
    }
    
/*__________________________________________________________________________________________________________
* ***********************************************************************************************************
* Developer: Sanjoli Agrawal
* Feature: LTAART-40
* This method restructures QLI JSON in the QuantityCapture Flow.
*___________________________________________________________________________________________________________
*/     
    
    public static void reArrangeLineItem(Map<String,Object> input,Map<String,Object> output,Map<String,Object> options){
        
        Boolean checkCO = false;
        List<qliRoot> qliList = new List<qliRoot>();
        Map<String,List<qliRoot>> qliChildMap = new Map<String,List<qliRoot>>();
        
        List<String> selectedIds = String.valueOf(input.get('selectedOffer')).split(',');
        List<qli> qliListMap = (List<qli>)JSON.deserialize(JSON.serialize(input.get('QLI')),List<qli>.class);
        
        if(qliListMap <> NULL && selectedIds <> NULL ){
            for(qli item: qliListMap){
                
                if(item.parentItemId=='root' && selectedIds.contains(item.assetReferenceId)){
                    qliRoot root = new qliRoot(item.name,item.productCode,item.offerType,item.assetReferenceId,item.parentItemId,item.rootItem, item.fmtdBindTime, item.oneTimeCharge,item.finalCharge, item.faQty,true, false, item.level, item.qliId, item.maxQuantity, item.existingQuantity, false, item.disableCallOff,item.disbaleExistingQty, item.objectTypeName, item.rootPriceFlag, item.ptObjectName, item.faQty, item.existingQuantity);
                    qliList.add(root);
                }
                else if(item.parentItemId <> 'root' && selectedIds.contains(item.rootItem)){
                    if (item.ptObjectName =='Connected Office Offer Spec' && item.faQty <> NULL){
                        checkCO = Decimal.valueOf(String.valueOf(item.faQty))>0 ? true: false;
                    }
                    if(qliChildMap.containsKey(item.parentItemId)){
                       
                        qliChildMap.get(item.parentItemId).add(new qliRoot(item.name,item.productCode,item.offerType,item.assetReferenceId,item.parentItemId,item.rootItem,item.fmtdBindTime, item.oneTimeCharge,item.finalCharge, item.faQty,true, false,item.level, item.qliId, item.maxQuantity, item.existingQuantity,false, item.disableCallOff,item.disbaleExistingQty,item.objectTypeName, item.rootPriceFlag, item.ptObjectName, item.faQty, item.existingQuantity));
                    }
                    else{
                        qliChildMap.put(item.parentItemId,new List<qliRoot>{new qliRoot(item.name,item.productCode,item.offerType,item.assetReferenceId,item.parentItemId,item.rootItem,item.fmtdBindTime, item.oneTimeCharge,item.finalCharge, item.faQty,true, false,item.level, item.qliId, item.maxQuantity, item.existingQuantity,false, item.disableCallOff,item.disbaleExistingQty,item.objectTypeName,item.rootPriceFlag,item.ptObjectName, item.faQty, item.existingQuantity)} );
                    }
                }
            }
            
            for(qliRoot root:qliList){
                recursiveQliStructure(root,qliChildMap);
            }
            
            output.put('QLIRestructured',(List<Object>)JSON.deserializeUntyped(JSON.serialize(qliList)));
            output.put('CheckCO', checkCO);
        }
    }
    
/*______________________________________________________________________________________________________________
* **************************************************************************************************************
* Developer: Sanjoli Agrawal
* Feature: LTAART-40
* This method is recursively invoked by the reArrangeLineItem method to organize the JSON hierarchy for each parent.
*_________________________________________________________________________________________________________________
*/     
    
    public static void recursiveQliStructure(qliRoot root,Map<String,List<qliRoot>> qliChildMap){
        try{
            if(qliChildMap.containsKey(root.assetReferenceId)){
                root.hasChildren = true;
                root.hideInputs = true; //for parent products to hide the fields
                root.childItem =  qliChildMap.get(root.assetReferenceId);
                
                for(Integer i=root.childItem.size()-1; i>=0; i--){
                    qliRoot qliItem = (qliRoot)root.childItem[i];
                    if(qliItem.offerType == 'Non-SubscriptionOffering' && !qliChildMap.containsKey(qliItem.assetReferenceId)){
                       root.childItem.remove(i);
                    }
                    else{
                        recursiveQliStructure(qliItem,qliChildMap);
                    }
                }        
            }
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
/*______________________________________________________________________________________________________________
* **************************************************************************************************************
* Developer: Sanjoli Agrawal
* Feature: LTAART-40
* This method is invoked to save the Quantities for each product on FA Quote.
*_________________________________________________________________________________________________________________
*/
    
    public static void saveQuantitiesOnFA (Map<String,Object> input,Map<String,Object> output,Map<String,Object> options){
        
        QuotelineItem qli;
        String salesFlow = (String)input.get('salesFlow');
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        Boolean syncToAutoTask = false,isITDaaSSelected=false,isCO = Boolean.valueOf(input.get('CheckCO'));
        Set<String> updatedQLIId = ((Map<String,Object>)input.get('updatedQLIJson')).keySet();
        
        for(String qliId:updatedQLIId){
            
            Map<String,Object> qliJson = (Map<String,Object>)((Map<String,Object>)((Map<String,Object>)input.get('updatedQLIJson')).get(qliId)).get('record');
            
            //Added Checks to Handle Autotask Sync and Hera page based on the quantities for selected products.
            if(qliJson.get('faQty') <> NULL && !String.isBlank(String.valueOf(qliJson.get('faQty')))){
                if(Decimal.valueOf(String.valueOf(qliJson.get('faQty')))>0 && qliJson.get('ptObjectName') <> NULL && (String)qliJson.get('ptObjectName') == 'Connected Office Offer Spec') isCO = true;
                
                if(qliJson.get('objectType') == 'ITDaaS Offer Spec' && ((Decimal.valueOf(String.valueOf(qliJson.get('faQty')))>0 &&  salesFlow == 'New Sales') || ((salesFlow == 'Omforhandling' || salesFlow == 'Tilläggsförhandling') && qliJson.get('parentItemId') == NULL && (Boolean)qliJson.get('rootPriceFlag') == true ))){
                    syncToAutoTask = true;
                    if(((String)qliJson.get('productCode')).startsWith('ITDAAS')) {
    					isITDaaSSelected = true;
					}
                }
            }
            
            qli = new QuotelineItem();
            qli.Id = (Id)qliJson.get('qliId');
            qli.MC_Initial_Order_Quantity__c = qliJson.get('existingQuantity') <> NULL && !String.isBlank(String.valueOf(qliJson.get('existingQuantity')))? Decimal.valueOf(String.valueOf(qliJson.get('existingQuantity'))):NULL ;
            qli.TeliaSE_MC_FACallOffQuantity__c =qliJson.get('faQty') <> NULL && !String.isBlank(String.valueOf(qliJson.get('faQty')))? Decimal.valueOf(String.valueOf(qliJson.get('faQty'))): NULL;
            qliList.add(qli);
        }
        
        output.put('isITDaaSSelected',isITDaaSSelected);
        output.put('syncToAutoTask',syncToAutoTask);
        output.put('CheckCO',isCO);
        
        if(qliList.size()>0){
            update qliList;
        }
    }
    
    public class qli{
        String name,assetReferenceId, productCode,offerType,qliId,parentItemId,rootItem,heraReferenceNumber,heraType,prodId,QuoteId,subscription,BindingTime,campaignId,rootProduct,productHierarchyPath,quoteGroupId,quoteMemberId,baseQuantity,objectTypeName,productType,salesFlowIdentifier,lineStatus,fmtdBindTime,ptObjectName;
        decimal recPrice,faQty,initialOrderQty,oneTimeCharge,sequencenumber,discountPercentage,finalCharge,level,maxQuantity,existingQuantity;
        boolean excludeItem,disableCallOff,disbaleExistingQty,rootPriceFlag;
    }
    
    public class qliRoot{
        String name, productCode,offerType,assetReferenceId,parentItemId,rootItem,bindingTime,objectType,ptObjectName;
        Id qliId;
        Decimal oneTimeCharge,recPrice,faQty,level,maxQuantity,existingQuantity,offerQty,existingQty;
        Boolean collapseChild,hasChildren,hideInputs,disableCallOff,disbaleExistingQty,rootPriceFlag;
        List<qliRoot> childItem;
        
        qliRoot(String name,String productCode,String offerType,String assetReferenceId,String parentItemId,String rootItem, String bindingTime, Decimal oneTimeCharge,Decimal recPrice, Decimal faQty, Boolean collapseChild,Boolean hasChildren, Decimal level, Id qliId,Decimal maxQuantity, Decimal existingQuantity,Boolean hideInputs, Boolean disableCallOff,Boolean disbaleExistingQty, String objectType, Boolean rootPriceFlag,String ptObjectName,Decimal offerQty,Decimal existingQty){
            this.name = name;
            this.oneTimeCharge = oneTimeCharge;
            this.recPrice = recPrice;
            this.bindingTime = bindingTime;
            this.productCode = productCode;
            this.offerType = offerType;
            this.assetReferenceId = assetReferenceId;
            this.parentItemId = parentItemId;
            this.rootItem = rootItem;
            this.collapseChild =true;
            this.hasChildren=false;
            this.faQty = faQty;
            this.level = level;
            this.qliId = qliId;
            this.maxQuantity = maxQuantity;
            this.existingQuantity = existingQuantity;
            this.hideInputs = false;
            this.disableCallOff=disableCallOff;
            this.disbaleExistingQty=disbaleExistingQty;
            this.objectType=objectType;
            this.rootPriceFlag = rootPriceFlag;
            this.ptObjectName = ptObjectName;
            this.offerQty = offerQty;
            this.existingQty = existingQty;
        }
    }
}