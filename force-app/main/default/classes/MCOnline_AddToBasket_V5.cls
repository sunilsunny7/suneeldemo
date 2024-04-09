/****************************************************************************************************************************
* @author                 Ajay Nagar
* @modifiedBy             Aparajita Banarjee
* @maintainedBy           Aparajita Banarjee
* @version                5.0
* @description            Add to basket 
* @modified               02/5/2022
******************************************************************************************************************************/

global with sharing class MCOnline_AddToBasket_V5 implements vlocity_cmt.VlocityOpenInterface {
     static String apiFunctionality='AddToBasket';
     static String uniqueParentId = '',cartContextKey='';
     static Decimal mrcPrice=0;
     static Decimal nrcPrice=0;
     static Boolean isAsync=vlocity_cmt__GeneralSettings__c.getInstance('isAsync')!=null &&vlocity_cmt__GeneralSettings__c.getInstance('isAsync').vlocity_cmt__Value__c =='true'?true:false;
     static ProductDetail__mdt prodDetails = [Select MCOnline_Fields_To_Display__c,fields_to_be_mapped__c from ProductDetail__mdt];
     static List<String> productFields = prodDetails.MCOnline_Fields_To_Display__c.split(',');    
     static Map<String, Object> attribMap = new Map<String, Object>();
     static Map<string,object> fieldsToMap = (Map<string,object>)JSON.deserializeUntyped(prodDetails.fields_to_be_mapped__c);
     static Set<String> finalNodes= new Set<String>([select MCONL_Attributes_to_Remove__c from Trim_GetOfferDetails__mdt]?.MCONL_Attributes_to_Remove__c.split(','));
     
     global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {  
         if(methodName.equals('addtobasket_remotemethod'))
         {
             addtoBasket(inputMap,outMap,options);
         }
         return true; 
     }
     
     private static void addtoBasket(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
     {
         boolean isManagedFlow = false,isChangeBasket = false;
         Map<String, String> storeInput = new Map<String, String>();
         List<MCOnline_Basket__c> parameters = new List<MCOnline_Basket__c>();
         List<id> BasketIds = new List<id>();
         List<String> Baskets = new List<String>();
         String parentId = '';
         string TSCID = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
         string AgreementId = String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
         string User = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
         if(((Map<string,object>)inputMap.get('options')).containskey('itemBasketName'))
         {
             string basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('itemBasketName'));           
             parameters = [select Account__c, MCOnline_ParentBasket__r.Admin__c, MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__r.AgreementId__c  from MCOnline_Basket__c  where Name =: basketName WITH SECURITY_ENFORCED];
         }
             Map<String, Object> remotemethodResponse = new Map<String, Object>();
             Map<String, Object> productConfigMap = new Map<String, Object>();
             List<Object> productConfigList = new List<Object>();
             productConfigList = (List<Object>)inputMap.get('productConfig');
             if(string.isBlank(String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID')))|| string.isBlank(String.Valueof(((Map<string,object>)inputMap.get('options')).get('users')))){
                 //hasError = true;
                 String errorCode = 'INAVALID_USER_TSCID';
                 outMap.put('errorResponse', MCOnline_Utility.generateError('',errorCode,'custom', inputMap, '',parameters,apiFunctionality));
                 outMap.put('StatusCode', 500);
             } 
             else if(string.isBlank(string.valueOf(inputMap.get('basketLineRelationId'))) || string.isBlank(string.valueOf(inputMap.get('basketLineRelationCount'))) || inputMap.get('basketLineRelationCount')==0){
                 //hasError = true;
                 String errorCode = 'BASKET_LINE_RELATION_ID_COUNT_ERROR';
                 outMap.put('errorResponse', MCOnline_Utility.generateError('',errorCode,'custom', inputMap, '',parameters,apiFunctionality));
                 outMap.put('StatusCode', 500);
             }
             else{
                 for(Object offers: productConfigList)
                 {
                         
                  	Map<String, Object> tempMap = (Map<String, Object>)offers;
                    productConfigMap = tempMap;
                    String getCatalogStr = String.valueOf((((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)( (Map<String, Object>)(productConfigMap).get('offerDetails')).get('offer')).get('addtocart')).get('rest')).get('link')));
                    String catalog = getCatalogStr.split('/')[2];
                    outMap.clear();
                     if(catalog.equalsIgnoreCase('SUBSCRIPTIONS')){
                       reserveNumber(productConfigMap,outMap,TSCID);
                       if(vlocity_cmt__GeneralSettings__c.getInstance('SkipNHFError').vlocity_cmt__Value__c=='True')
                       {
                       		if(outMap.get('errorResults')!=null)
                            {
                                outMap.put('errorCode','Invoke-500');
                                outMap.put('success',false);
                                return;
                             }
                         }   
                     }
                                                 
                 }
                 for(Object offers: productConfigList){
                     if(!outMap.containsKey('errorResponse')){
                         Map<String, Object> tempMap = (Map<String, Object>)offers;
                         productConfigMap = (Map<String, Object>)tempMap;
                         String getCatalogStr = String.valueOf((((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)( (Map<String, Object>)(productConfigMap).get('offerDetails')).get('offer')).get('addtocart')).get('rest')).get('link')));
                         String catalog = getCatalogStr.split('/')[2];
                         string cartContextKey = String.valueof(inputMap.get('contextKey'));
                         // validate Icc_Number before caling remotemethod
                         if(Catalog.equalsIgnoreCase('SUBSCRIPTIONS') && MCOnline_Utility.containsDuplicateIccNumber(productConfigMap,inputMap,'addToBasket')){
                             String errorCode = 'DUPLICATE_ICC_NUMBER';
                             outMap.put('errorResponse', MCOnline_Utility.generateError('',errorCode,'custom', inputMap,'',parameters,apiFunctionality));
                             outMap.put('StatusCode', 500); 
                         }else{
                             if(((Map<string,object>)inputMap.get('options')).containskey('itemBasketName'))
                             {
                                 remotemethodResponse=addtobasket_remotemethod(cartContextKey,JSON.serialize(productConfigMap),String.Valueof(parameters[0].MCOnline_Catalog__c),isManagedFlow);
                             }
                             else 
                             {
                                if(isAsync) 
                                {

                                    addtobasket_remotemethod(cartContextKey,JSON.serialize(productConfigMap),Catalog,isManagedFlow,TSCID,AgreementId,User);
                                }
                                else 
                                {
                                    remotemethodResponse=addtobasket_remotemethod(cartContextKey,JSON.serialize(productConfigMap),Catalog,isManagedFlow);
                                }
                                outMap=addToBasket_V3_NormalCallout(inputMap,remotemethodResponse, outMap,options,JSON.serialize(productConfigMap),BasketIds,catalog,parameters,isManagedFlow,storeInput,isChangeBasket);
                             }
                         }
                         
                     }            
                 }
             }  
     }
 
    @future
    public static void addtobasket_remotemethod(String ContextKey,String productConfigMap,string Catalog,boolean isManagedFlow,String tscId,String agreementId,String user){
         Map<String, Object> output = new Map<String, Object>();
         try
         {
            output=MCOnline_utility.addToBasket_remote(ContextKey,(Map<String, Object>)JSON.deserializeUntyped(productConfigMap),Catalog,isManagedFlow);
         }catch(Exception e){   
             logExceptions(e, output);
         }
         
     }
     public static Map<String,Object> addtobasket_remotemethod(String ContextKey,String productConfigMap,string Catalog,boolean isManagedFlow){
         Map<String, Object> output = new Map<String, Object>();
         try{
             String orderid='';
             List<MCOnline_Basket__c> basketlst= new List<MCOnline_Basket__c>();
             Map<String, Object> offerdetails = new Map<String, Object>();
             output=MCOnline_utility.addToBasket_remote(ContextKey,(Map<String, Object>)JSON.deserializeUntyped(productConfigMap),Catalog,isManagedFlow);
         }catch(Exception e){   
             logExceptions(e, output);
         }
         return output; 
     }
     
     public static Map<String,Object> addToBasket_V3_NormalCallout(Map<String,Object> inputMap,Map<String,Object> HA_AddToBasket, Map<String,Object> outMap, Map<String,Object> options,String productConfigMap,List<id> basketIds,string catalog1,List<MCOnline_Basket__c> parameters,boolean isManagedFlow,Map<String, String> storeInput,boolean isChangeBasket){
         Map<String, Object> productConfigMap1 = (Map<String, Object>)JSON.deserializeUntyped(productConfigMap);
         Map<String, Object> offerObj1 = new Map<String, Object>();
         Id parentbasket;
         String attributeJSON='', orderNumber='', tscid='', parentbasketname='', cartContextKey='', orderid='', accountid='', admin='', agreementid='', basketLineRelationId='', multiTransactionKey='';
         Boolean hasError=false;
         Integer basketLineRelationCount = 0;
         String catalog=catalog1;
         //BEGIN error handling
         String stdError, errorCode, message, code, iccNumber;
         boolean success =  true;
         Map<String, Object> ipInputMap = new Map<String, Object>();
         Map<String, Object> ipOutputMap = new Map<String, Object>();
         Map<String,object> addtobasketResponse= new Map<String,object>();
         Map<String,object> errorMap= new Map<String,object>();
         if(!HA_AddToBasket.isEmpty()){
             addtobasketResponse=HA_AddToBasket;
         }
         try
         {
            Map<String, Object> errorResponse = new Map<String, Object>();
            if(!isAsync && !HA_AddToBasket.isEmpty())
            {
                 if(HA_AddToBasket.get('success')!=null && !Boolean.valueOf(HA_AddToBasket.get('success')))
                 {
                     Map<String,Object> error = (Map<String,Object>)HA_AddToBasket.get('result');
                     outMap.put('success',false);
                     outMap.put('errorCode','INVOKE-500');
                     outMap.put('errorMessage',error.get('messages')+'');
                     MCOnline_Utility.logError(error.get('messages')+'', 'INVOKE-500','MCOnline_AddToBasket_V5','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                     return null;
                 }
                 Map<String,Object> resultMap=(Map<String,Object>)JSON.deserializeUntyped(HA_AddToBasket.get('result')+'');
                 if(!resultMap.containsKey('cartContextKey')) 
                 {
                             hasError = true;
                             if(HA_AddToBasket.containskey('result'))
                             {
                                 Map<String,Object> map1 = (Map<String,Object>)HA_AddToBasket;
                                 if(String.valueOf(HA_AddToBasket.get('result')).contains('offerDetails'))
                                 {
                                     Map<String,Object> resulterr = (Map<String,Object>)HA_AddToBasket.get('result');
                                     if(resulterr.containsKey('offerDetails')){
                                         Map<String,Object> getofferDetals = (Map<String,Object>)resulterr.get('offerDetails');                            
                                         if(getofferDetals != null){
                                             string offerError = string.valueOf(getofferDetals.get('messages'));
                                             string offerErrCode = string.valueOf(getofferDetals.get('StatusCode'));
                                             if(offerErrCode == '142'){
                                                 offerErrCode = 'MAXGROUP_CARDINALITY_ERROR';
                                             }
                                             errorResponse.put('errorCode',offerErrCode);                     
                                             errorResponse.put('error',offerError);
                                             errorResponse.put('success',false);
                                             outMap.put('errorResponse',errorResponse);
                                             outMap.put('StatusCode',400);
                                             MCOnline_Utility.logError(offerError, offerErrCode,'MCOnline_AddToBasket_V5','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                                         }
                                     }
                                 }
                                 else
                                 {
                                     vlocity_cmt.JSONResult resulterr1 = (vlocity_cmt.JSONResult)HA_AddToBasket.get('result');
                                     string resultMSgCode = resulterr1.messages[0].code;
                                     string resultMSgMsg = resulterr1.messages[0].message;
                                     errorResponse.put('errorCode',resultMSgCode);                     
                                     errorResponse.put('error',resultMSgMsg);
                                     errorResponse.put('success',false);
                                     outMap.put('errorResponse',errorResponse);
                                     outMap.put('StatusCode',400);
                                     MCOnline_Utility.logError(resultMSgMsg, resultMSgCode,'MCOnline_AddToBasket_V5','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                                 }
                             }else{
                                 stdError = (string)(HA_AddToBasket.get('error'));
                                 errorCode = (string)HA_AddToBasket.get('errorCode');
                                 if(errorCode =='NOT_FOUND' || errorCode =='BAD_REQUEST'){
                                     stdError = String.valueOf(HA_AddToBasket.get('message'));
                                 }else if(stdError!=null && stdError.contains('Invalid Basket Action')){
                                     stdError = 'Invalid Basket Action';
                                 }else if(stdError!=null && stdError.contains('Invalid context input')){
                                     stdError = 'Invalid context input';
                                 }else{
                                     stdError = (string)HA_AddToBasket.get('error'); 
                                 } 
                                 outMap.put('errorResponse', MCOnline_Utility.generateError(stdError,errorCode,'standard', 'MultiAddToBasketAndCheckOut'));
                                 MCOnline_Utility.logError(stdError, errorCode,'MCOnline_AddToBasket_V5','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                                 outMap.put('StatusCode', 400);
                             }
                 }
                 else
                 {
                            cartContextKey=resultMap.get('cartContextKey')+'';
                             Map<String, Object> compMsg = new Map<String, Object>();
                             Map<String, Object> result = (Map<String,Object>)JSON.deserializeUntyped(HA_AddToBasket.get('result')+'');
                             String compItems= '';
                             List<Object> resultMessage = (List<Object>)result.get('messages');  
                             if(resultMessage!=null && !resultMessage.isEmpty()){
                                 boolean isErrorCollected = false;
                                 for(Object msg:resultMessage){
                                     compMsg = (Map<String, Object>)msg;
                                     if(String.valueOf(compMsg.get('code'))=='208'||String.valueOf(compMsg.get('code'))=='207'){
                                         if(!isErrorCollected) {
                                             errorCode = 'PRODUCT_COMPATIBILITY_ERROR';
                                             success = false;
                                             outMap.put('StatusCode', 400);
                                             isErrorCollected = true;
                                         }
                                         compItems = compItems+String.valueOf(compMsg.get('message'));
                                     }
                                     if(String.valueOf(compMsg.get('code'))=='204'){
                                         if(!isErrorCollected) {
                                             errorCode = 'REQUIRED_ATTRIBUTE_MISSING';
                                             success = false;
                                             outMap.put('StatusCode', 400);
                                             isErrorCollected = true;
                                         }
                                         compItems = compItems+String.valueOf(compMsg.get('message'));
                                     }
                                     if(String.valueOf(compMsg.get('code'))=='101'){
                                         if(!isErrorCollected) {
                                             errorCode = 'BASKET_OPERATION_FAIL';
                                             success = false;
                                             outMap.put('StatusCode', 400);
                                             isErrorCollected = true;
                                         }
                                         compItems = compItems+String.valueOf(compMsg.get('message'));
                                     }
                                 }
                                 errorResponse.put('errorCode',errorCode);                     
                                 errorResponse.put('error',compItems);
                                 errorResponse.put('success',success);
                                 outMap.put('errorResponse',errorResponse);
                                 MCOnline_Utility.logError(compItems, errorCode,'MCOnline_AddToBasket_V5','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                             }
                         }
                     
                 }
                 tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));                    
                 admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
                 basketLineRelationId=String.Valueof(inputMap.get('basketLineRelationId'));
                 basketLineRelationCount = (Integer)inputMap.get('basketLineRelationCount');
                 
                 offerObj1=(Map<String, Object>)((Map<String, Object>)(productConfigMap1).get('offerDetails')).get('offer');
                 agreementid = String.valueOf(((Map<String, Object>)(productConfigMap1).get('offerDetails')).get('agreementId'));
    
                 List<Object> childProducts2ndLevel = new List<Object>();
                 Map<String, Object> rootproductMap2save = new Map<String, Object>();
                 List<Object> rootproductList2save = new List<Object>();
                 Integer count = 0;
                 fetchData(offerObj1,rootproductList2save,count);
                 rootproductMap2save.put('products',rootproductList2save);
                 attributeJSON=JSON.serialize(rootproductMap2save) ;
                 if(parameters == null || parameters.size()==0  )
                 {
                     accountid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Accountid'));
                     tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
                     admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
                     //get ICC Number
                     Map<String,Object> productDetails = (Map<String,Object>)JSON.deserializeUntyped(attributeJSON);
                     iccNumber = processAttribJSON(productDetails);    
                 }
                 else{
                     Accountid =String.Valueof(parameters[0].Account__c);
                     tscid = String.Valueof(parameters[0].TSCID__c);
                     admin = String.Valueof(parameters[0].MCOnline_ParentBasket__r.Admin__c);
                     Catalog = String.Valueof(parameters[0].MCOnline_Catalog__c);
                     //get ICC Number
                     Map<String,Object> productDetails = (Map<String,Object>)JSON.deserializeUntyped(AttributeJSON);
                     iccNumber = processAttribJSON(productDetails);    
                 }
                 List<MCOnline_ParentBasket__c> parentbas=new List<MCOnline_ParentBasket__c>();
                 if(!isManagedFlow){
                     //Removing agreement Id filter from the query as RAM/MFA implementation
                     parentbas=[SELECT id,name,OrderNumber__c FROM MCOnline_ParentBasket__c WHERE TSCID__c=:tscid AND Admin__c=:admin AND Is_Processed__c =false AND flow__c='SALESFLOW' WITH SECURITY_ENFORCED order by createddate desc limit 1];
                     if(parentbas!=null && parentbas.size()>0){
                         parentbasket=parentbas[0].id;
                         parentbasketname=parentbas[0].name;
                         orderNumber = parentbas[0].OrderNumber__c;
                     }
                     else{
                         MCOnline_ParentBasket__c pbas=new MCOnline_ParentBasket__c();
                         pbas.TSCID__c= tscid;
                         pbas.Account__c= Accountid;
                         pbas.Admin__c =  admin;
                         pbas.flow__c = 'SALESFLOW';
                         if(Schema.sObjectType.MCOnline_ParentBasket__c.isCreateable())
                         {
                             insert pbas;
                         }
                         parentbasket=pbas.id;
                         orderNumber=pbas.OrderNumber__c;
                     }
                 }
                 else{
                     parentbas=[SELECT id,name,OrderNumber__c FROM MCOnline_ParentBasket__c WHERE TSCID__c=:tscid AND Admin__c=:admin AND Is_Processed__c =false AND flow__c='MANAGEFLOW' AND Id =: uniqueParentId WITH SECURITY_ENFORCED order by createddate desc limit 1];
                     if(parentbas!=null && parentbas.size()>0){
                         parentbasket=parentbas[0].id;
                         parentbasketname=parentbas[0].name;
                         orderNumber = parentbas[0].OrderNumber__c;
                     }
                     else
                     {
                         MCOnline_ParentBasket__c pbas=new MCOnline_ParentBasket__c();
                         pbas.TSCID__c= tscid;
                         pbas.Account__c= Accountid;
                         pbas.Admin__c =  admin;
                         pbas.flow__c = 'MANAGEFLOW';
                         if(Schema.sObjectType.MCOnline_Basket__c.isCreateable())
                         {
                             insert pbas;
                         }
                         uniqueParentId = pbas.id;
                         parentbasket=pbas.id;
                         orderNumber=pbas.OrderNumber__c;
                     }
                 }
                 
                     MCOnline_Basket__c bas=new MCOnline_Basket__c();
                     bas.TSCID__c= tscid;
                     bas.Account__c=Accountid;
                     bas.MCOnline_ParentBasket__c=parentbasket;
                     bas.MCOnline_Catalog__c= Catalog;
                     bas.MCOnline_OfferCode__c=String.valueof(offerObj1.get('ProductCode'));
                     bas.MConline_Offer_ActionCode__c = (offerObj1.get('MConline_Action_Code__c')!=null) ? String.valueOf(offerObj1.get('MConline_Action_Code__c')): 'Add';
                     if(!String.isBlank(cartContextKey)){
                         bas.MCOnline_Basket_Key__c=cartContextKey;
                     }
                     bas.MCOnline_AttributeJSON__c= AttributeJSON;
                     bas.MCOnline_MRC_Amount__c= mrcPrice; //MCOnline_Negotiated_Amount__c  
                     bas.MCOnline_NRC_Amount__c= nrcPrice;
                     bas.MCOnline_Contract__c = Agreementid;
                     bas.Basket_Line_Relation_Id__c = String.Valueof(inputMap.get('basketLineRelationId'));
                     bas.basket_Line_Relation_Count__c =(Decimal)inputMap.get('basketLineRelationCount');
                     bas.MCOnline_ICC_Number__c = iccNumber;
                     insert bas;
                    
                     
                     basketIds.add(bas.id);
                     outMap.put('itemBasketId',basketIds);                       
                     outMap.put('parentBasketId', parentbasket);
                     if(!hasError){
                         success=true;
                         outMap.put('success',true);
                     }
                   
         }catch(Exception e){   
             hasError = true;
             Map<String, Object> errorResponse = new Map<String, Object>();
             String error_message= e.getMessage() +' '+e.getLineNumber();
             //BEGIN error handling
             if(error_message.contains('REQUIRED_FIELD_MISSING')){
                 errorCode = 'REQUIRED_FIELD_MISSING';
             }
             else if(error_message.contains('Invalid id')){
                 errorCode = 'INVALID_ID';
             }else if(error_message.contains('UNABLE_TO_LOCK_ROW')){
                 errorCode = 'UNABLE_TO_LOCK_ROW';
             }
             else{
                 errorCode = 'UNKNOWN_ERROR';
             }
             string stdError1 = 'Invalid Account Id or Agreement Id';
             String dc_message = String.valueOf(addtobasketResponse);
             String final_message = error_message+' '+dc_message;
             if(errorCode != 'UNKNOWN_ERROR')
             {
                  logErrors(errorCode,final_message,inputMap,outMap,errorResponse);
             }
             else
             {   outMap.put('errorResponse', MCOnline_Utility.generateError(stdError1,errorCode,'custom', 'MultiAddToBasketAndCheckOut'));
                 MCOnline_Utility.logError(final_message,'500','MCOnline_AddToBasket_V5','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'',''); 
             }
             outMap.put('StatusCode', 500);
             //END error handling
         }       
         return outMap;
     }
     
     
     
     
    public static String formatMSISDN(String UpdatedAttributeJSON, boolean isManagedFlow)
     {
         Map<String,Object> productDetails = (Map<String,Object>)JSON.deserializeUntyped(UpdatedAttributeJSON);
         List<Object> productList = (List<Object>)productDetails.get('products');
         Integer size = productList.size();
         for(Integer i = size - 1; i >= 0; i--)
         {
             Map<String, Object> recObj = ( Map<String, Object>)productList.get(i);
             if(!isManagedFlow){
                 Map<String, Object> attributeMap = (Map<String, Object>)recObj.get('attributes');
                 if(attributeMap != null)
                 {
                     if(String.valueOf(attributeMap.get('NumberReservationRequired')) != null && String.valueOf(attributeMap.get('NumberReservationRequired')).equalsIgnoreCase('No'))
                     {
                         productList.remove(i);
                     }
                 }
             }
             else if(isManagedFlow){
                 if(string.valueOf(recObj.get('C2BC_Subcategory')) != null && !((string.valueOf(recObj.get('C2BC_Subcategory'))).equalsIgnoreCase('datasim'))){
                     productList.remove(i);
                 }
                 else if(string.valueOf(recObj.get('C2BC_Subcategory')) != null && (string.valueOf(recObj.get('C2BC_Subcategory'))).equalsIgnoreCase('datasim')){
                     if((recObj.containsKey('actionCode'))&& (!((string.valueOf(recObj.get('actionCode'))).equalsIgnoreCase('Add')))){
                         productList.remove(i);
                     }
                 }
             }
         }
         String updateStr = JSON.serialize(productDetails);
         return updateStr;
     }
     
     private static void populateProductfields(Map<String,Object> productMap,Map<String,Object> productMapToReturn)
     {
         for(String field:productFields)
         {
             productMapToReturn.put(string.valueOf(fieldsToMap.get(field)),String.valueOf(productMap.get(field)));
         }
         if(String.isBlank((String)productMap.get('MConline_Action_Code__c')))
         {
             productMapToReturn.put('actionCode','Add');
         }
         else
         {       
             productMapToReturn.put('actionCode',String.valueOf(productMap.get('MConline_Action_Code__c')));
         }
     }
     
     private static String processAttribJSON(Map<String,Object> productDetails){
         List<Object> prodList = (List<Object>)productDetails.get('products');
         String iccNumber;
         for(Object item:prodList){
             Map<string,object> prod = (Map<string,object>)item;
             if(prod.containsKey('attributes')){
                 Map<string,object> attr = (Map<string,object>)prod.get('attributes');
                 if(attr.containsKey('ICC_number')){
                     iccNumber = String.Valueof(attr.get('ICC_number'));
                     break;
                 }
             }
         }
         return iccNumber;
     }
     
     public static void fetchData(Map<String, Object> offerObj,List<Object> ListToSaveProductInfo,integer count){
         if(offerObj.containsKey('childProducts')){
             count++;
             List<Object> childProduct = (List<Object>)offerObj.get('childProducts');
             if(childProduct!=null && childProduct.size()>0){
                 for(object child : childProduct){
                     Map<String, Object> childProductMap = (Map<String, Object>)child;
                     Map<String, Object> attributeCategoryMap = new Map<String, Object>();
                     if(childProductMap.containskey('Quantity') && (childProductMap.get('Quantity')!= null && Integer.valueOf(childProductMap.get('Quantity'))>=1) && childProductMap.containskey('C2BC_Category__c') && !((string.valueOf(childProductMap.get('C2BC_Category__c'))).contains('bundle'))){    
                         Map<String, Object> productMapToSave = new Map<String, Object>();
                         List<Object> priceResult = (List<Object>)childProductMap.get('priceResult');
                         productMapToSave.put('Quantity',Integer.valueOf(childProductMap.get('Quantity')));
                         productMapToSave.put('productCode',String.Valueof(childProductMap.get('ProductCode')));
                         populateProductfields(childProductMap,productMapToSave);
                         // added to display multiple pricelist------------------------//
                         if(priceResult!=null){
                             Map<String, Object> PriceListMap;
                             List<Map<string,Object>> PriceList = new List<Map<string,Object>>();// added for pricelist
                             for(Object pricelst:priceResult){
                                 PriceListMap = new Map<String, Object>(); // added for pricelist
                                 Map<String, Object> priceResultMap=(Map<String, Object>)pricelst;
                                 if((String.Valueof(priceResultMap.get('ChargeType__c'))).equalsIgnoreCase('Recurring')){
                                     if(((productMapToSave.get('actionCode'))!=null)&&((string.valueOf(productMapToSave.get('actionCode'))).equalsIgnoreCase('delete') || (string.valueOf(productMapToSave.get('actionCode'))).equalsIgnoreCase('updateAttr') || (string.valueOf(productMapToSave.get('actionCode'))).equalsIgnoreCase('updateChild'))){
                                         mrcPrice+=0;
                                     }
                                     else if(((productMapToSave.get('actionCode'))!=null) && ((string.valueOf(productMapToSave.get('actionCode'))).equalsIgnoreCase('Update') || (string.valueOf(productMapToSave.get('actionCode'))).equalsIgnoreCase('Add'))){
                                         mrcPrice+= (Decimal)priceResultMap.get('Amount__c');
                                     }
                                     PriceListMap.put('chargeAmount',String.Valueof(priceResultMap.get('chargeamount')));
                                     PriceListMap.put('baseAmount',String.Valueof(priceResultMap.get('baseamount')));
                                     PriceListMap.put('amount',String.Valueof(priceResultMap.get('Amount__c')));
                                     //PriceListMap.put('nrc_amount',String.Valueof(priceResultMap.get('NRC_Amount__c')));
                                     PriceListMap.put('recurringFrequency',String.Valueof(priceResultMap.get('RecurringFrequency__c')));
                                     PriceListMap.put('chargeType',String.Valueof(priceResultMap.get('ChargeType__c')));
                                     PriceListMap.put('displayText',String.Valueof(priceResultMap.get('DisplayText__c')));
                                 }else if(String.Valueof(priceResultMap.get('ChargeType__c'))=='One-time'){
                                     PriceListMap.put('chargeAmount',String.Valueof(priceResultMap.get('chargeamount')));
                                     PriceListMap.put('baseAmount',String.Valueof(priceResultMap.get('baseamount')));
                                     //PriceListMap.put('amount',String.Valueof(priceResultMap.get('Amount__c')));
                                     PriceListMap.put('nrc_amount',String.Valueof(priceResultMap.get('Amount__c')));
                                     PriceListMap.put('recurringFrequency',String.Valueof(priceResultMap.get('RecurringFrequency__c')));
                                     PriceListMap.put('chargeType',String.Valueof(priceResultMap.get('ChargeType__c')));
                                     PriceListMap.put('displayText',String.Valueof(priceResultMap.get('DisplayText__c')));  
                                     if(((productMapToSave.get('actionCode'))!=null) && ((string.valueOf(productMapToSave.get('actionCode'))).equalsIgnoreCase('Update') || (string.valueOf(productMapToSave.get('actionCode'))).equalsIgnoreCase('Add'))){
                                         nrcPrice+= (Decimal)priceResultMap.get('Amount__c');
                                     }
                                 }
                                 PriceList.add(PriceListMap);
                                 
                             }
                             productMapToSave.put('price',PriceList);
                         }
                         // added to display multiple pricelist------------------------//
                         if(childProductMap.containskey('AttributeCategory') && childProductMap.get('AttributeCategory') != null)
                             attributeCategoryMap=(Map<String, Object>)childProductMap.get('AttributeCategory');
                         
                         if(attributeCategoryMap!=null && attributeCategoryMap.size()>0 && attributeCategoryMap.containskey('records')){
                             List<Object> attributeCategoryRecordslst=(List<Object>)attributeCategoryMap.get('records');
                             Map<String, Object> productAttributesMap=(Map<String, Object>)attributeCategoryRecordslst[0];
                             Map<String, Object> productAttributesrecordsMap=(Map<String, Object>)productAttributesMap.get('productAttributes');
                             List<Object> productAttributesrecordslst=(List<Object>)productAttributesrecordsMap.get('records');
                             Map<String, Object> productAttributeObject = new Map<String, Object>();
                             for(Object prodattrobj: productAttributesrecordslst){
                                 Map<String, Object> productAttributeObjectForEachLevel = (Map<String, Object>)prodattrobj;
                                 productAttributeObject.put(String.Valueof(productAttributeObjectForEachLevel.get('label')),String.Valueof(productAttributeObjectForEachLevel.get('userValues')));
                             }
                             productMapToSave.put('attributes',productAttributeObject);                      
                         }
                         ListToSaveProductInfo.add(productMapToSave);
                     }
                     if(childProductMap.containsKey('childProducts')){
                         fetchData(childProductMap,ListToSaveProductInfo,count);
                     }
                 }
             }
         }
         
     }
     public static void reserveNumber(Map<String,Object> productConfigMap1,Map<String,Object> outMap,String tscid)
     {
         Map<String, Object> offerObj1=(Map<String, Object>)((Map<String, Object>)(productConfigMap1).get('offerDetails')).get('offer');
         Map<String, Object> rootproductMap2save = new Map<String, Object>();
         List<Object> rootproductList2save = new List<Object>();
         Integer count = 0;
         Boolean numberReserved = false;
         fetchData(offerObj1,rootproductList2save,count);
         mrcPrice=0;
         nrcPrice=0;
         rootproductMap2save.put('products',rootproductList2save);
         for(Object obj:rootproductList2save){
            Map<String,Object> attMap = (Map<String,Object>)obj;
             attMap = (Map<String,Object>)attMap.get('attributes');
             if(attMap!= null && attMap.containsKey('Reserved_MSISDN')){
                numberReserved = Boolean.valueOf(attMap.get('Reserved_MSISDN'));
             }
         }
         String attributeJSON=JSON.serialize(rootproductMap2save);         
         if(!numberReserved){
            String updatedAttributeJSON = formatMSISDN(AttributeJSON, false);
            Map<String, Object> response= MCOnline_Utility.reserveNumber(updatedAttributeJSON, null, tscid,'addToBasket');
         	if(response!= null){
                 MCOnline_NumberReservation_V2.ReservationResponseWrapper res=(MCOnline_NumberReservation_V2.ReservationResponseWrapper)((List<Object>)response.get('success'))[0];
                 Map<String,Object> resData=(Map<String,Object>)((Map<String,Object>)((Map<String,Object>)JSON.deserializeUntyped(res.response)).get('message')).get('srp');
                 if(resData.get('returnCode')+'' != '0')
                 {
                     List<Object> msisdn=(List<Object>)(((Map<String,Object>)resData.get('listOfMSISDN')).get('msisdn'));
                     outMap.put('errorResults',new List<Object>{new Map<String,String>{'offer'=>offerObj1.get('ProductCode')+'','msisdn'=>msisdn[0]+'','msisdntype'=>resData.get('msisdntype')+'', 'reservationReturnCode'=>resData.get('returnCode')+'', 'ErrorCode'=>'UNABLE_TO_RESERVE_THE_NUMBER'+''}});
                     //MCOnline_Utility.logErrorWithoutFuture('unable to reserve the number', 'NUMBER_NOT_RESERVED','MCONLINE_AddToBasket_V5,MCONLINE_AddToBasket_V5.reserveNumber','Apex Class', 'Custom Error',attributeJSON,'','');
                 }else
                 {
                     outMap.put('reservationStatus',resData.get('returnCode')+'');
                 }
         } 
         }
         
     }
     @testvisible
     private static void logExceptions(Exception e, Map<String, Object> output){
         String error_message= e.getMessage() +' '+e.getLineNumber();
             string stdError;
             if(error_message.contains('Invalid Context Info')){
                 stdError = 'Invalid Context Info';                
                 output.put('error',stdError);
                 output.put('errorCode','INVOKE-500');
                 output.put('success','false');
             }
     }
     
     
     @testvisible
     private static void logErrors(String errorCode,String final_message,Map<String,Object> inputMap,Map<String,Object> outMap, Map<String,Object> errorResponse){
         if(errorCode == 'UNABLE_TO_LOCK_ROW'){
             string errmsg = 'there is an on going checkout. please hold for a while before proceeding towards the next transaction';
             errorResponse.put('errorCode',errorCode);                   
             errorResponse.put('error',errmsg);
             errorResponse.put('success',false);
             outMap.put('errorResponse',errorResponse);
             outMap.put('StatusCode',400);
             MCOnline_Utility.logError(final_message, errorCode,'MCOnline_AddToBasket_V5','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');               
         }
         else{               
             outMap.put('errorResponse', MCOnline_Utility.generateError('',errorCode,'custom', 'MultiAddToBasketAndCheckOut'));
             MCOnline_Utility.logError(final_message, errorCode,'MCOnline_AddToBasket_V5','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
         }
     }
 }