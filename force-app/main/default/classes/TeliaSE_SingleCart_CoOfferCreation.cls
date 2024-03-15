/*-----------------------------------------------------------------------------------------------------------
**Name        :        TeliaSE_SingleCart_CoOfferCreation 
**Created By  :        Agraj Naman Mishra
**Sprint      :        Sprint ****
**User Story  :        MCSTO- ******
**Description :        Contains methods used by Connected Office Call of Quote Creation.

-----------------------------------------------------------------------------------------------------------*/
global without sharing class TeliaSE_SingleCart_CoOfferCreation implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result = true;
        try{
            /*LTAART-328: Commented these Methods to disable the Grouping scenario
if(methodName.equals('prepareRequestAddtoCart')){
prepareRequestAddtoCart(inputMap,outMap);
}
else if(methodName.equals('updateQuoteType')){
updateQuoteType(inputMap,outMap);
}
else if(methodName.equals('PdtReorder')){
PdtReorder(inputMap,outMap);
}
else if(methodName.equals('getGroups')){
getGroups(inputMap,outMap);
}
else if(methodName.equals('storeGroups')){
storeGroups(inputMap,outMap);
}*/
            if(methodName.equals('AddPremiseLineItems')){
                AddPremiseLineItems(inputMap,outMap);
            }
            else if(methodName.equals('CheckCO')){
                checkCO(inputMap,outMap);
            }
            else{
                result = false;
            }
            return result;              
        } 
        catch(Exception e){return false;}
    }
    /*LTAART-328: Commented this Method to disable the Grouping scenario    
public Static void storeGroups(Map<String,Object> inputMap,Map<string,Object> outMap){
//Unlock FA Quote to insert quote group.
Id Context = Id.valueof((String)inputMap.get('ContextId'));
if(Approval.isLocked(Context)){
Approval.unlock(Context);
}
Id OfferCartId = Id.valueof((String)inputMap.get('OfferCartId'));
//Delete The Group Maping in any case and UPSERT members in the Members.
list<vlocity_cmt__QuoteGroup__c> existGrp = [select id from vlocity_cmt__QuoteGroup__c where vlocity_cmt__QuoteId__c =:Context OR vlocity_cmt__QuoteId__c =:OfferCartId];
if(existGrp.size()>0){
delete existGrp;
}
}       
*/
    //Method Starts To check the Occurence of CO products with greater than 0 quantity in the FAQuote.
    public Static void checkCO(Map<String,Object> inputMap,Map<String,Object> outMap){  
        String quoteId = (String)inputMap.get('ContextId');
        List<String> coObjectTypes = new List<String>{'Broadband Start Offering Spec','Broadband Plus Offering Spec','Broadband Pro Offering Spec','Broadband Datanet Offering Spec','WIFI/LAN Offering Spec','SD-WAN/Firewall Offering Spec'};        
            List<QuoteLineItem> qliList = [SELECT Id, TeliaSE_MC_FACallOffQuantity__c,vlocity_cmt__ParentItemId__c,TeliaSE_Product_Object_Type__c,TeliaSE_MC_Binding_Time__c  FROM QuoteLineItem WHERE QuoteId =:quoteId AND TeliaSE_Product_Object_Type__c IN:coObjectTypes AND ((Quote.TeliaSE_MC_Sales_Flow_Identifier__c != 'Tilläggsförhandling') OR (Quote.TeliaSE_MC_Sales_Flow_Identifier__c = 'Tilläggsförhandling' AND MC_Line_Status__c != 'Existing'))];
        
        if(qliList.size() > 0){
            Boolean checkCO = false;
            Map<String,String> offerTypeToBindingPeriodMap=new Map<String,String>();
            for(QuoteLineItem qli:qliList){
                if(qli.vlocity_cmt__ParentItemId__c==null){//Added By Abhishek for CO Binding Period Improvement
                    if(qli.TeliaSE_MC_Binding_Time__c !=null){
                        offerTypeToBindingPeriodMap.put(qli.TeliaSE_Product_Object_Type__c,(String)(qli.TeliaSE_MC_Binding_Time__c));
                    }
                }
                if(qli.TeliaSE_MC_FACallOffQuantity__c > 0 && !checkCO && !Boolean.valueOf(System.label.MC_QuantityCapture)){
                    checkCO = true;
                }
            }
            outMap.put('CheckCO',checkCO);
            if(offerTypeToBindingPeriodMap.size()>0){
                outMap.put('offerTypeToBindingPeriodMap',offerTypeToBindingPeriodMap);
            }
        }else{
            outMap.put('CheckCO',false);
        }
    }
    /*LTAART-328: Commented this Method to disable the Grouping scenario
//Creating Processed Groups As per the request format of treeGrid in LWC.
public Static void getGroups(Map<String,Object> inputMap,Map<String,Object> outMap){
Map<String,Object> GetDataraw = (Map<String,Object> )inputMap.get('DRE1');
List<Object> GetData = new List<Object>();
if(GetDataraw.get('Grouped') != ''){
GetData = (List<Object>)GetDataraw.get('Grouped');
}       
List<Object> allPrem = (List<Object>)GetDataraw.get('AccountExtracts');
Map<String,Boolean> attend= new Map<String,Boolean>();//using Map 'attend' to reduce the re-iteration of Sites if found duplicate in all premise List.
List<Object> ProcessedGroups = new List<object>();
Map<String,List<Object>> checkMap= new Map<String,List<Object>>();
Map<String,Map<String,Object>> checkIds= new Map<String,Map<String,Object>>();
Map<String,Integer> attendance = new Map<String,Integer>();
List<string> groups = new List<string>();
if(GetData!=null){ //GetData contains all the sites which are belonging to a group already in the previous maping.
for(Object o:GetData){
Map<String,Object> obj = (Map<String,Object>)o;
String siten = (String)obj.get('SiteName');
attend.put(siten,true);
String grId = (String)obj.get('GroupId');
if(obj.get('PostalCode') != null || obj.get('Latitude')!= null ){
//if(obj.get('PostalCode') != null){
if((checkMap.get(grId)) == null){
List<Object> temp = new List<Object>();
temp.add(o);
checkMap.put(grId,temp);
}else{
List<Object> temp2 = new List<Object>();
temp2 = (List<Object>)checkMap.get(grId);
temp2.add(o);
checkMap.put(grId,temp2);
}
}
if(attendance.get(grId) == null){
if(checkIds.get(grId) == null){
groups.add(grId);
Map<String,Object> newList = new Map<String,Object>();
newList.put('GroupId',(String)obj.get('GroupId'));
newList.put('GroupName',(String)obj.get('GroupName'));
//ProcessedGroups.add(newList);
checkIds.put((String)obj.get('GroupId'),newList);
}
attendance.put((String)obj.get('GroupId') , 1);
}
}
if(groups.size()>0){
for(String st:groups){
if(checkMap.get(st) != null){
Map<String,Object> tempMap = new Map<String,Object>();
tempMap = checkIds.get(st);
tempMap.put('_children',checkMap.get(st));
ProcessedGroups.add(tempMap);
}
}
}
}
//AllPrem is containing all the premises which are directly related to account. Both Grouped or ungrouped
List<Object> allPremFinal = new List<Object>();
List<Object> serviceList =new List<Object>();
List<Map<String,Object>> listForUpdate = new List<Map<String,Object>>();        
for(Object oo:allPrem){
Map<String,Object> oobj = (Map<String,Object>)oo;
String st = (string)oobj.get('SiteName');
if(attend.get(st) == null){
if(oobj.get('ServicePoints') != '' && oobj.get('ServicePoints') != null){
serviceList = (List<Object>)oobj.get('ServicePoints');
oobj.remove('ServicePoints');
for(Object ser:serviceList){
Map<String,Object> tempvar = new Map<String,Object>();
Map<String,Object> serMap = (Map<String,Object>)ser;
String str = (String)serMap.get('ServicePointId');
tempvar.put('ServicePointId',str);
tempvar.putAll(oobj);
allPremFinal.add(tempvar);
}
}
}
}
if(allPremFinal.size()>0){
Map<String,Object> allEntry = new Map<String,Object>();
allEntry.put('GroupName','Ej grupperade adresser');
allEntry.put('GroupId','Ej grupperade adresser');
allEntry.put('_children',allPremFinal);
ProcessedGroups.add(allEntry);
}
for(Object obj:ProcessedGroups){
Map<String,Object> oo = (Map<String,Object>)obj;
String st = (String)oo.get('GroupName');
}
outMap.put('processedGroups' , ProcessedGroups);//Passing the Final ProcessedGroup in the list below. 
}
*/  
    /*LTAART-328: Commented this Method to disable the Grouping scenario
Method to Restructure the QOL in the defined order as we want to show in the heirarchy in LWC.
public Static void PdtReorder(Map<String,Object> inputMap, Map<String,Object> outMap){
Map<String,Object> DrOutput = (Map<String,Object>)inputMap.get('DataRaptorExtractAction1');
List<Object> QOList = (List<Object>)DrOutput.get('QuoteLineItem ');
List<Object> ProcessedQOL0 = new List<Object>();
List<Object> StandaloneMap = new List<Object>();
List<Object> SubBundleMap = new List<Object>();
List<Object> LeafProductMap = new List<Object>();
for(Object ql:QOList){
Map<String,Object> QOL = (Map<String,Object>)ql;
String OffType = (String)QOL.get('ProductObjectType');
if(OffType == 'Broadband Start Offering Spec' || OffType == 'Broadband Pro Offering Spec' || OffType == 'Broadband Plus Offering Spec' || OffType == 'Broadband Datanet Offering Spec' || OffType == 'SD-WAN/Firewall Offering Spec' || OffType == 'WIFI/LAN Offering Spec'){
if((Integer)QOL.get('Level') == 0){
Integer Level=0;
String ObjType = (String)QOL.get('ProductObjectType');
String str = (String)QOL.get('Product2Id');
if(checkIfSubBundle(str , inputMap,Level,ObjType)){//Check If anyProducts inside this root product is having quantity greater than 0
QOL.put('IsRoot',1);
ProcessedQOL0.add(QOL);}
}
else if((String)QOL.get('OfferType') =='SubscriptionOffering'){
Integer Level=(Integer)QOL.get('Level');
String ObjType = (String)QOL.get('ProductObjectType');
//String str = (String)QOL.get('ImParentProduct');
if((double)QOL.get('FACallOffQuantity') != 0){
////System.debug('FACALLOffQ' +QOL.get('FACallOffQuantity'));
QOL.put('IsStand',1);
StandaloneMap.add(QOL);
}
}else{                  
Integer Level=(Integer)QOL.get('Level');
String ObjType = (String)QOL.get('ProductObjectType');
String str = (String)QOL.get('Product2Id');
if(checkIfSubBundle(str , inputMap,Level,ObjType) && ((Integer)QOL.get('Level') >0)){
QOL.put('IsSub',1);
SubBundleMap.add(QOL);
}
else{  
if((double)QOL.get('FACallOffQuantity') != 0){
QOL.put('IsLeaf',1);
QOL.put('InFlag',1);
LeafProductMap.add(QOL);
}                   
}
}
}
}
List<Object> Result= ArrangePdt(ProcessedQOL0,StandaloneMap,SubBundleMap,LeafProductMap);
outMap.put('GetProcessedPdt',Result);        
}

public Static List<Object> ArrangePdt(List<Object> root,List<Object> stand,List<Object> sub,List<Object> leaf){
List<Object> Result = new List<Object>();
For(Object o:root){
Map<String,Object> pdts =(Map<String,Object>)o;
Result.add(o);
for(Object s:stand){
Map<String,Object> st = (Map<String,Object>)s;
if((String)st.get('ImParentProduct') == (String)pdts.get('Product2Id')){
Result.add(s);
}
}
for(Object su:sub){
Map<String,Object> ss = (Map<String,Object>)su;
if((String)ss.get('ImParentProduct') == (String)pdts.get('Product2Id')){
Result.add(su);
for(Object l:leaf){
Map<String,Object> ll = (Map<String,Object>)l;
if((String)ll.get('ImParentProduct') == (String)ss.get('Product2Id')){
Result.add(l);
}
}
}
}
}
return Result;
}

//Check if given 'str' quoteLineItem is a subBundle with any of its child with greater than 0 quantity.
public Static Boolean checkIfSubBundle(String str,Map<String,Object> inputMap, Integer Level,String ObjType){
Map<String,Object> DrOutput = (Map<String,Object>)inputMap.get('DataRaptorExtractAction1');
List<Object> QOList = (List<Object>)DrOutput.get('QuoteLineItem ');
Boolean result = false;
for(Object ql:QOList){
Map<String,Object> QOL = (Map<String,Object>)ql;
String productid = (String)QOL.get('Product2Id');
if(Level ==0){
if((double)QOL.get('FACallOffQuantity')!=null && (String)QOL.get('ProductObjectType') == ObjType){
if((double)QOL.get('FACallOffQuantity') > 0){
result = true;
return result;
}
}
}else if((double)QOL.get('FACallOffQuantity')!=null || ((String)QOL.get('ImParentProduct') == str)){
if((String)QOL.get('ImParentProduct') == str && (double)QOL.get('FACallOffQuantity') > 0){
result = true;
return result;
}
}           
}
return result;
}
*/
    //Method to handle HERA. Creating the list in format of postcartItem call out. Later merged and used for QOL creation.
    public Static void AddPremiseLineItems(Map<String,Object> inputMap, Map<String,Object> outMap){
        Id cartId = Id.valueOf((String)inputMap.get('OfferCartId'));
        List<Object> PremiseProductDetails = (List<Object>)inputMap.get('UpdatedPremiseData');
        List<Map<String, Object>> inMapList = new List<Map<String, Object>>();
        List<Map<String, Object>> HeraUpdateList = new List<Map<String, Object>>();
        Map<String,Object> DRresponse = (Map<String,Object>)inputMap.get('DR_ExtAct_getInstallationProductDetails');
        Map<String,Object> InstallationProduct = (Map<String,Object>)DRresponse.get('InstallationProduct');
        Id priceBookEntryId = Id.valueOf((String)InstallationProduct.get('PriceBookEntryId'));
        for(Object obj:PremiseProductDetails){
            Map<String,Object> PremiseData =(Map<String,Object>)obj;
            Map<String,Object> PremiseSpecPrice = (Map<String,Object>)PremiseData.get('Input');
            Integer otc = PremiseSpecPrice.get('otc')!='' ? Integer.valueOf(PremiseSpecPrice.get('otc')) : 0;
            Integer rc = PremiseSpecPrice.get('rc')!='' ? Integer.valueOf(PremiseSpecPrice.get('rc')) : 0;
            String heraNumber = PremiseSpecPrice.get('heraNumber')!='' ? (String)PremiseSpecPrice.get('heraNumber') : '';
            String heraType = PremiseData.get('selectedHeraType')!='' ? (String)PremiseData.get('selectedHeraType') : '';
            
            //LTAT-6041 - Secondary Access - Add Hera Type
            if(heraType == '1'){
                heraType = 'Primary Access';
            }else if(heraType == '2'){
                heraType = 'Secondary Access';
            }
            Id groupId, memberId;
            if(PremiseData.get('QuoteGroupId')!=null && PremiseData.get('QuoteGroupId')!=''){
                groupId = Id.valueOf((String)PremiseData.get('QuoteGroupId'));
            }
            if(PremiseData.get('QuoteMemberId')!=null && PremiseData.get('QuoteMemberId')!=''){
                memberId = Id.valueOf((String)PremiseData.get('QuoteMemberId'));
            } //check if input is given corresponding to the site. else skip
            If((otc+rc) != 0){
                Map<String, Object> inMap = new Map<String, Object>();                    
                Map<String, Object> itemsMap = new Map<String, Object>();
                Map<String, Object> UpdateList = new Map<String,Object>();
                List<Object> items = new List<Object>();                    
                itemsMap.put('itemId', priceBookEntryId);
                Map<String,Object> fieldUpdates = new Map<String,Object>();
                Integer quan = 1;
                UpdateList.put('vlocity_cmt__OneTimeCharge__c',otc);
                UpdateList.put('vlocity_cmt__RecurringCharge__c',rc);
                UpdateList.put('PriceBookEntryId',priceBookEntryId);
                UpdateList.put('vlocity_cmt__QuoteMemberId__c',memberId);
                //LTAT-6041 - Secondary Access - Add Hera Type
                UpdateList.put('MC_HeraType__c',heraType);
                UpdateList.put('MC_HeraReferenceNumber__c',heraNumber);
                UpdateList.put('vlocity_cmt__EffectiveQuantity__c',1);
                UpdateList.put('Quantity',quan);
                UpdateList.put('vlocity_cmt__QuoteGroupId__c',groupId);
                
                fieldUpdates.put('vlocity_cmt__QuoteMemberId__c',memberId);
                fieldUpdates.put('vlocity_cmt__QuoteGroupId__c',groupId);
                fieldUpdates.put('vlocity_cmt__EffectiveQuantity__c',1);
                fieldUpdates.put('Quantity',quan);
                //LTAT-6041 - Secondary Access - Add Hera Type
                fieldUpdates.put('MC_HeraType__c',heraType);
                fieldUpdates.put('MC_HeraReferenceNumber__c',heraNumber);
                HeraUpdateList.add(UpdateList);
                itemsMap.put('fieldsToUpdate',fieldUpdates);
                items.add(itemsMap);
                inMap.put('items', items);
                inMap.put('cartId', cartId);
                inMap.put('validate', false); 
                inMap.put('price', false);
                inMapList.add(inMap);}
        }
        outMap.put('HERAwrapList',inMapList);
        outMap.put('HeraWrapListSize',inMapList.size());
        outMap.put('HERAPriceUpdate',HeraUpdateList);
    }
    /*LTAART-328: Commented this Method to disable the Grouping scenario
public Static void prepareRequestAddtoCart(Map<String,Object> inputMap, Map<String,Object> outMap){
List<Map<String, Object>> inMapList = new List<Map<String, Object>>();
Map<String,Integer> productToindexmap = new Map<String,Integer>();
List<Integer> subIndexes= new List<Integer>();
List<Object> productDetails = (List<Object>)inputMap.get('ProductGroupQuantity');
Integer i=0;
for(Object obj: productDetails){
Map<String,Object> proMap = (Map<String,Object>)obj;
Integer isSub = (Integer)proMap.get('IsSub') !=null ? (Integer)proMap.get('IsSub') : 0;
if(isSub == 1){
productToindexmap.put((String)proMap.get('Product2Id'),i);
subIndexes.add(i);
}
i++;
}
Map<String,List<Object>> subGroupmap = new Map<String,List<Object>>(); 
for(Object obj : productDetails){
Map<String,Object> prodInfo = (Map<String,Object>)obj;
Map<String,Object> finalProInfo = new Map<String,Object>();
finalProInfo.put('Product2Id',(String)prodInfo.get('Product2Id'));
finalProInfo.put('ImParent',(String)prodInfo.get('ImParentProduct'));
finalProInfo.put('ApprovedPercentage',prodInfo.get('ApprovedPercentage'));
finalProInfo.put('RequestedPercentage',prodInfo.get('RequestedPercentage'));
finalProInfo.put('ApprovedPrice',prodInfo.get('ApprovedPrice'));
finalProInfo.put('OneTimePrice',prodInfo.get('OneTimePrice'));
finalProInfo.put('ProductType',(String)prodInfo.get('ProductType'));
finalProInfo.put('RecurringPrice',prodInfo.get('RecurringPrice'));
finalProInfo.put('TargetPercentage',prodInfo.get('TargetPercentage'));
finalProInfo.put('Product2Name',prodInfo.get('Product2Name'));
finalProInfo.put('ProductObjectType',prodInfo.get('ProductObjectType'));
finalProInfo.put('ProductCode',(String)prodInfo.get('ProductCode'));
finalProInfo.put('IsSub',prodInfo.get('IsSub'));
finalProInfo.put('IsStand',prodInfo.get('IsStand'));
finalProInfo.put('IsLeaf',prodInfo.get('IsLeaf'));
List<object> GroupList = (List<object>)prodInfo.get('Groups');
List<Object> GroupQuantity = new List<Object>();
for(object g:GroupList){
Map<String,Object> QliGroupInfo = (Map<String,Object>)g;
if(QliGroupInfo.get('Quantity')!=null && QliGroupInfo.get('Quantity')!=''){
Map<String,Object> grpInfo = new Map<String,Object>();
Id GrpId = Id.valueOf((String)QliGroupInfo.get('GroupId'));
String GrpName = (String)QliGroupInfo.get('GroupName');
Integer quan = (Integer)QliGroupInfo.get('Quantity');
grpInfo.put('GroupId',GrpId);
grpInfo.put('GroupName',GrpName);
grpInfo.put('Quantity',quan);
GroupQuantity.add(grpInfo);
}
}
if(GroupQuantity.size() > 0){
Integer isLeaf = (Integer)prodInfo.get('IsLeaf') !=null ? (Integer)prodInfo.get('IsLeaf') : 0;
if(isLeaf == 1){
String subProductid = (String)prodInfo.get('ImParentProduct');
if(subGroupmap.get(subProductid) != null){
List<Object> storedList = subGroupmap.get(subProductid);
List<Object> resultList = new List<Object>();
List<Object> differenceList = new List<Object>();
for(Object store:storedList){
Map<String,Object> storeMap = (Map<String,Object>)store;
Boolean foundFlag = false;
for(Object Grps:GroupQuantity){
Map<String,Object> GrpsMap = (Map<String,Object>)Grps;
if(GrpsMap.get('GroupId') ==storeMap.get('GroupId') ){
foundFlag = true;
}
}if(foundFlag == false){
differenceList.add(storeMap);
}
}
if(differenceList.size()>0){
resultList.addall(GroupQuantity);
resultList.addall(differenceList);
subGroupmap.put(subProductid,resultList);
}else{
subGroupmap.put(subProductid,GroupQuantity);
}
}else{
subGroupmap.put(subProductid,GroupQuantity);
}
}
finalProInfo.put('Groups',GroupQuantity);
}
inMapList.add(finalProInfo);
}
Integer calcIndex=0;
for(Map<String,Object> subRecord:inMapList){
for(Integer index: subIndexes){
if(calcIndex == index){
String ProductId = (String)subRecord.get('Product2Id');
List<Object> GroupList = subGroupmap.get(ProductId);
subRecord.put('Groups',GroupList);
}
} calcIndex++;
}
outMap.put('COGroupMap',inMapList);}
*/
}