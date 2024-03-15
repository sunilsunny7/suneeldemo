/****************************************************************************************************************************
* @author                 Ajay Nagar
* @modifiedBy             Aparajita Banarjee
* @maintainedBy           Aparajita Banarjee
* @version                4.0
* @description            Add to basket 
* @modified               02/5/2022
******************************************************************************************************************************/

global with sharing class MCOnline_AddToBasket_V4 implements vlocity_cmt.VlocityOpenInterface {
    static ProductDetail__mdt FieldsList = [Select MCOnline_Fields_To_Display__c,fields_to_be_mapped__c from ProductDetail__mdt];
    static String FieldsListStr=FieldsList.MCOnline_Fields_To_Display__c;
    static List<String> productFields = FieldsListStr.split(',');
    static Map<String, Object> attribMap = new Map<String, Object>();
    static Map<string,object> fieldsToMap = (Map<string,object>)JSON.deserializeUntyped(string.valueOf(FieldsList.fields_to_be_mapped__c));
    static Trim_GetOfferDetails__mdt finalNodeslist = [Select MCONL_Attributes_to_Remove__c from Trim_GetOfferDetails__mdt];
    static String finalNodeslistStr=finalNodeslist.MCONL_Attributes_to_Remove__c, uniqueParentId = '';
    static List<String> finalNodeslistStrtolist = finalNodeslistStr.split(',');
    static Set<String> finalNodes= new Set<String>(finalNodeslistStrtolist);
    static List<Product2> fieldsToAdd = [select vlocity_cmt__AttributeMetadata__c, ProductCode,Ordering_Flag__c from Product2] ;
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        // an instance of managed flow and change basket to re use code----
        boolean isManagedFlow = false;
        boolean isChangeBasket =false;
        Map<String, String> storeInput = new Map<String, String>();
        //------------------------------------------------
        List<MCOnline_Basket__c> Parameters = new List<MCOnline_Basket__c>();
        List<id> BasketIds = new List<id>();
        List<String> Baskets = new List<String>();
        String parentId = '';
        string TSCID = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
        string AgreementId = String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
        string User = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
        if(((Map<string,object>)inputMap.get('options')).containskey('itemBasketName'))
        {
            string basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('itemBasketName'));           
            Parameters = [select Account__c, MCOnline_ParentBasket__r.Admin__c, MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__r.AgreementId__c  from MCOnline_Basket__c  where Name =: basketName ];
        }
        if(methodName.equals('addtobasket_remotemethod'))
        {  
            Map<String, Object> remotemethodResponse = new Map<String, Object>();
            Map<String, Object> productConfigMap = new Map<String, Object>();
            List<Object> productConfigList = new List<Object>();
            productConfigList = (List<Object>)inputMap.get('productConfig');
            if(string.isBlank(String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID')))|| string.isBlank(String.Valueof(((Map<string,object>)inputMap.get('options')).get('users')))){
                //hasError = true;
                String errorCode = 'INAVALID_USER_TSCID';
                outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, '',Parameters));
                outMap.put('StatusCode', 500);
            } 
            else if(string.isBlank(string.valueOf(inputMap.get('basketLineRelationId'))) || string.isBlank(string.valueOf(inputMap.get('basketLineRelationCount'))) || inputMap.get('basketLineRelationCount')==0){
                //hasError = true;
                String errorCode = 'BASKET_LINE_RELATION_ID_COUNT_ERROR';
                outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, '',Parameters));
                outMap.put('StatusCode', 500);
            }
            else{
                for(Object offers: productConfigList){
                    if(!outMap.containsKey('ErrorResponse')){
                        //Added by Binamra Guha
                        /*-------------------Trimming of request body------------------------*/
                        Map<String, Object> tempMap = (Map<String, Object>)offers;
                        removeItems(tempMap,fieldsToAdd, finalNodes, isManagedFlow, isChangeBasket);
                        productConfigMap = (Map<String, Object>)tempMap;
                        System.debug(JSON.serialize(productConfigMap));
                        /*--------------------------------------------------------------*/
                        string Catalog='';
                        String getCatalogStr = String.valueOf((((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)( (Map<String, Object>)(productConfigMap).get('offerDetails')).get('offer')).get('addtocart')).get('rest')).get('link')));
                        Integer startIndex = getCatalogStr.indexOf('s/')+2;
                        Integer endIndex = getCatalogStr.indexOf('/basket');
                        Catalog = getCatalogStr.substring(startIndex, endIndex);
                        string cartContextKey = String.valueof(inputMap.get('contextKey'));
                        // validate Icc_Number before caling remotemethod
                        if(Catalog.equalsIgnoreCase('SUBSCRIPTIONS') && MCOnline_Utility.containsDuplicateIccNumber(productConfigMap,inputMap,'addToBasket')){
                            String errorCode = 'DUPLICATE_ICC_NUMBER';
                            outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, '',Parameters));
                            outMap.put('StatusCode', 500); 
                        }else{
                            if(((Map<string,object>)inputMap.get('options')).containskey('itemBasketName'))
                            {
                                remotemethodResponse=addtobasket_remotemethod(cartContextKey,JSON.serialize(productConfigMap),String.Valueof(Parameters[0].MCOnline_Catalog__c),isManagedFlow);
                            }
                            else {
                            remotemethodResponse=addtobasket_remotemethod(cartContextKey,JSON.serialize(productConfigMap),Catalog,isManagedFlow);
                            outMap=addToBasket_V3_NormalCallout(inputMap,remotemethodResponse, outMap,options,JSON.serialize(productConfigMap),BasketIds,Catalog,Parameters,isManagedFlow,storeInput,isChangeBasket);
                        }
                        }
                        
                    }            
                }
            }  
        }
        if(storeInput != null && !storeInput.isEmpty()){
            createAsynchBasketsBatch cls = new createAsynchBasketsBatch(storeInput, inputMap,TSCID,AgreementId,User);
            Database.executeBatch(cls, 1);
        }
        
        return true; 
    }
    
    //Below method will remove the bundles and childproducts having quantity 0
    public static void removeItems(Object obj,list<product2> fields,Set<String> Nodes, boolean isManagedFlow, boolean isChangeBasket){
        
        Map<String, Object> tempMap1 = (Map<String, Object>)obj;
        Map<String,Object> offerDetails=(Map<String,Object>)tempMap1.get('offerDetails');
        Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
        if(offer.containsKey('childProducts'))
        {
            List<Object> childProducts=(List<Object>)offer.get('childProducts');
            for(Integer j = childProducts.size() - 1; j >= 0; j--)
            {
                Map<String, Object> tempMap2 = (Map<String, Object>)childProducts.get(j);
                if(tempMap2.containsKey('childProducts')){
                    List<Object> childProducts1=(List<Object>)tempMap2.get('childProducts');
                    for(Integer i = childProducts1.size() - 1; i >= 0; i--){
                        Map<String, Object> tempMap3 = (Map<String, Object>)childProducts1.get(i);
                        if(tempMap3.containsKey('Quantity')){
                            if(Integer.Valueof(tempMap3.get('Quantity'))==0){
                                childProducts1.remove(i);
                            }
                        }
                    }                
                    if(childProducts1.isEmpty()){
                        childProducts.remove(j);
                    }
                }
            }
        }
        Map<String,Object> offer1=(Map<String,Object>)offer;
        addCommitment(offer1,fields, Nodes, isManagedFlow, isChangeBasket);
    }
    
    //below method is for adding the 24 and 36 commitment period if not there 
    //this method will append the required fields for addtobasket
    public static void addCommitment(Object obj, list<product2> fields,Set<String> Nodes, boolean isManagedFlow, boolean isChangeBasket)
    {
        //list<Product2> fieldsToAdd = [select vlocity_cmt__AttributeMetadata__c, Name from Product2 where C2BC_Subcategory__c='voice'] ;
        //Map<string,Object> attributeMeta = new Map<string,Object>();
        Map<String, Object> tempMap = (Map<String, Object>)obj;
        if(tempMap.containsKey('AttributeCategory') && tempMap.get('AttributeCategory') != null){
           addField(tempMap, fields, Nodes, isManagedFlow, isChangeBasket);
        }
        if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
        {
            List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
            for(Object obj3:childProducts)
            {
                addCommitment(obj3, fields, Nodes, isManagedFlow, isChangeBasket);
            }
        }
        if(tempMap.containsKey('AttributeCategory') && tempMap.get('AttributeCategory') != null)
        {
            Map<String,Object> tempMap1=(Map<String,Object>)tempMap.get('AttributeCategory');
            if(tempMap1.containsKey('records') && tempMap1.get('records') != null){
                List<Object> attrRecords=(List<Object>)tempMap1.get('records');
                for(Object obj2:attrRecords)
                {
                    Map<String,Object> tempMap2=(Map<String,Object>)obj2;
                    if(tempMap2.containsKey('productAttributes') && tempMap2.get('productAttributes') != null){
                        Map<String,Object> tempMap3=(Map<String,Object>)tempMap2.get('productAttributes');
                        if(tempMap3.containsKey('records') && tempMap3.get('records') != null){
                            List<Object> prodAttrRecords=(List<Object>)tempMap3.get('records');
                            for(Object obj1:prodAttrRecords)
                            {
                                addCommitment(obj1, fields, Nodes, isManagedFlow, isChangeBasket);
                            }
                        }
                    }
                }
            }
        }

                                
        if(String.valueOf(tempMap.get('code')) == 'TELIA_COMM_PERIOD')
        {            
            if(tempMap.containsKey('values'))
            {
                List<Object> prodAttrRecordsValue1=(List<Object>)tempMap.get('values');
                Integer size = prodAttrRecordsValue1.size();
                Set<String> commitmentValue = new Set<String>();
                for(Integer i = size - 1; i >= 0; i--)
                {
                    Map<String, Object> value1 = (Map<String, Object>)prodAttrRecordsValue1.get(i);
                    commitmentValue.add(String.valueOf(value1.get('value')));
                }
                for(vlocity_cmt__PicklistValue__c pr : [Select id, Name, vlocity_cmt__Value__c,vlocity_cmt__IsDefault__c,  vlocity_cmt__PicklistId__r.vlocity_cmt__Code__c  from vlocity_cmt__PicklistValue__c Where vlocity_cmt__PicklistId__r.vlocity_cmt__Code__c = 'TELIA_COMM_PERIOD'])
                {
                    if(!(commitmentValue.contains(String.valueOf(pr.vlocity_cmt__Value__c))))
                    {
                        Map<String, Object> val = new Map<String, Object>();
                        val.put('label',String.valueOf(pr.Name));
                        val.put('value',String.valueOf(pr.vlocity_cmt__Value__c));
                        val.put('defaultSelected', Boolean.valueOf(pr.vlocity_cmt__IsDefault__c));
                        prodAttrRecordsValue1.add(val);
                    }
                }
            }
        }
    }
    public static void addField(Map<String, Object> obj, list<product2> fields,Set<String> Nodes, boolean isManagedFlow, boolean isChangeBasket){
        if(isManagedFlow == true || isChangeBasket== true){
            fieldsToAdd = fields;
            finalNodes = Nodes;
        }
        Map<String, Object> tempMap = (Map<String, Object>)obj;
        string prodCode = string.valueOf(tempMap.get('ProductCode'));
        string flow = string.valueOf(tempMap.get('Ordering_Flag__c'));
        //string specType = string.valueOf(tempMap.get('vlocity_cmt__SpecificationType__c'));
        //Product2 fieldsToAdd = [select vlocity_cmt__AttributeMetadata__c, ProductCode from Product2 where ProductCode =: prodCode and Ordering_Flag__c=:flow and vlocity_cmt__SpecificationType__c=:specType LIMIT 1] ;
        Map<string,map<string,object>> attributeMeta = new Map<string,map<string,object>>();
        for(Product2 flds : fieldsToAdd){
            if((flds.ProductCode!=null && (string.valueOf(flds.ProductCode)).equalsIgnoreCase(prodCode)) && (flds.Ordering_Flag__c!=null && (string.valueOf(flds.Ordering_Flag__c)).equalsIgnoreCase(flow)) && (flds.vlocity_cmt__AttributeMetadata__c!=null)){
            Map<String,object> fieldMap = (Map<string,object>)JSON.deserializeUntyped(flds.vlocity_cmt__AttributeMetadata__c);
                if((string.valueOf(tempMap.get('ProductCode'))).equalsIgnoreCase(string.valueOf(flds.ProductCode))){
                     List<object> tempList = (List<object>)fieldMap.get('records');
                     for(object ob1: tempList){
                         Map<String,Object> tempMaptemp =(Map<String,Object>)ob1;
                         if(tempMaptemp.containsKey('productAttributes') && tempMaptemp.get('productAttributes') != null){
                            Map<String,Object> tempMaptemp1=(Map<String,Object>)tempMaptemp.get('productAttributes');
                            if(tempMaptemp1.containsKey('records') && tempMaptemp1.get('records') != null){
                              List<Object> tempList2 =(List<Object>)tempMaptemp1.get('records');
                              for(object ob2: tempList2){
                                Map<String,Object> tempMaptemp2 =(Map<String,Object>)ob2;
                                Map<string,object> mapTemp = new map<string,object>();
                                for(string st: tempMaptemp2.keySet()){
                                   mapTemp.put(string.valueOf(st),tempMaptemp2.get(string.valueOf(st)));
                                }
                                attributeMeta.put(string.valueOf(tempMaptemp2.get('code')),mapTemp);
                               }
                            }
                    //attributeMeta = (map<string,objects>)((map<string,object>)((map<string,object>)fieldMap.get('records')).get('productAttributes')).get('records');
                          }
                      }
                  }
    }
    }
            Map<String,Object> tempMap1=(Map<String,Object>)tempMap.get('AttributeCategory');
            if(tempMap1.containsKey('records') && tempMap1.get('records') != null){
                List<Object> attrRecords=(List<Object>)tempMap1.get('records');
                for(Object obj2:attrRecords)
                {
                    Map<String,Object> tempMap2=(Map<String,Object>)obj2;
                    if(tempMap2.containsKey('productAttributes') && tempMap2.get('productAttributes') != null){
                        Map<String,Object> tempMap3=(Map<String,Object>)tempMap2.get('productAttributes');
                        if(tempMap3.containsKey('records') && tempMap3.get('records') != null){
                            List<Object> prodAttrRecords = (List<Object>)tempMap3.get('records');
                            for(Object obj1:prodAttrRecords)
                            {
                                map<string,object> addField = (map<string,object>)obj1;
                                for(string st: attributeMeta.keySet()){
                                 if(string.valueOf(((map<string,object>)obj1).get('code')).equalsIgnoreCase(string.valueOf(st))){
                                   map<string,object> mapTemp1 = (map<string,object>)attributeMeta.get(st);
                                   for(string fld: finalNodes){
                                   if(!fld.equalsIgnoreCase('userValues') && mapTemp1.containsKey(fld)){
                                   ((map<string,object>)obj1).put(fld,mapTemp1.get(fld)); 
                                   //((map<string,object>)obj1).put('required',mapTemp1.get('required'));
                                   //((map<string,object>)obj1).put('readonly',mapTemp1.get('readonly'));
                                   }
                                   }
                                 }
                                }
                            }
                        }
                    }
                }
            }
            
    }
    
    public static Map<String,Object> addtobasket_remotemethod(String cartContextKey,String productConfigMap,string catalogCode,boolean isManagedFlow){
        
        boolean MTS=false;
        Map<String, Object> output = new Map<String, Object>();
        try{
            String orderid='';
            List<MCOnline_Basket__c> basketlst= new List<MCOnline_Basket__c>();
            Map<String, Object> input = new Map<String, Object>();
            Map<String, Object> option = new Map<String, Object>();
            Map<String, Object> offerdetails = new Map<String, Object>();
            //input.put('forceinvalidatecache', TRUE);
            input.put('apiName','basketOperations'); 
            input.put('catalogCode', catalogCode); 
            input.put('productConfig',(Map<String, Object>)JSON.deserializeUntyped(productConfigMap)); 
            input.put('methodName', 'addAfterConfig'); 
            input.put('requestURL', '/v3/catalogs/'+catalogCode+'/basket');
            input.put('price', false);
            input.put('contextKey', cartContextKey);
            if(isManagedFlow==true){
              input.put('validate','false');
            }
            //input.put('returnBasket', false);
            vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
            system.debug('input-> '+input);
            appHandler.invokeMethod('addAfterConfig', input, output, option);
            system.debug('output-> '+output);
        }
        Catch(Exception e){   
            logExceptions(e, output);
        }
        return output; 
    }
    
    public static Map<String,Object> addToBasket_V3_NormalCallout(Map<String,Object> inputMap,Map<String,Object> HA_AddToBasket, Map<String,Object> outMap, Map<String,Object> options,String productConfigMap,List<id> BasketIds,string Catalog1,List<MCOnline_Basket__c>Parameters,boolean isManagedFlow,Map<String, String> storeInput,boolean isChangeBasket){
        //Call addtobasket synchronously via normal callout
        Map<String, Object> productConfigMap1 = (Map<String, Object>)JSON.deserializeUntyped(productConfigMap);
        Map<String, Object> offerObj1 = new Map<String, Object>();
        String AttributeJSON='';               
        Id parentbasket;
        String orderNumber='';
        String tscid='';
        String parentbasketname='';
        String cartContextKey='';
        Boolean ismultiTransactionKey=false;
        String orderid='';
        String Accountid='';
        String admin='';
        String Agreementid='';
        String basketLineRelationId='';
        Integer basketLineRelationCount = 0;
        String Catalog=Catalog1;
        String multiTransactionKey = '';
        //BEGIN error handling
        String stdError;
        String errorCode;
        String message;
        String code;
        Boolean success =  true;
        boolean hasError = false;
        String iccNumber;
        Map<String, Object> ipInputMap = new Map<String, Object>();
        Map<String, Object> ipOutputMap = new Map<String, Object>();
        Map<String,object> addtobasketResponse= new Map<String,object>();
        Map<String,object> errorMap= new Map<String,object>();
        if(!HA_AddToBasket.isEmpty()){
            addtobasketResponse=HA_AddToBasket;
            system.debug('remotemethodResponse'+addtobasketResponse);
        }
        Try{
            //BEGIN error handling
            Map<String, Object> ErrorResponse = new Map<String, Object>();
            if(ismultiTransactionKey==false){
                if(!HA_AddToBasket.isEmpty()){
                    if(HA_AddToBasket.get('nexttransaction')==null){
                        if(!HA_AddToBasket.containskey('cartContextKey')) {
                            hasError = true;
                            if(HA_AddToBasket.containskey('result')){
                                map<String,Object> map1 = (Map<String,Object>)HA_AddToBasket;
                                object obj1 = map1.get('result');
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
                                            ErrorResponse.put('errorCode',offerErrCode);                     
                                            ErrorResponse.put('error',offerError);
                                            ErrorResponse.put('success',false);
                                            outMap.put('ErrorResponse',ErrorResponse);
                                            outMap.put('StatusCode',400);
                                            MCOnline_Utility.logError(offerError, offerErrCode,'MCOnline_AddToBasket_V4','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                                        }
                                    }
                                }
                                else{
                                    vlocity_cmt.JSONResult resulterr1 = (vlocity_cmt.JSONResult)HA_AddToBasket.get('result');
                                    string resultMSgCode = resulterr1.messages[0].code;
                                    string resultMSgMsg = resulterr1.messages[0].message;
                                    ErrorResponse.put('errorCode',resultMSgCode);                     
                                    ErrorResponse.put('error',resultMSgMsg);
                                    ErrorResponse.put('success',false);
                                    outMap.put('ErrorResponse',ErrorResponse);
                                    outMap.put('StatusCode',400);
                                    MCOnline_Utility.logError(resultMSgMsg, resultMSgCode,'MCOnline_AddToBasket_V4','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
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
                                outMap.put('ErrorResponse', MCOnline_Utility.generateError(stdError,errorCode,'standard', 'MultiAddToBasketAndCheckOut'));
                                MCOnline_Utility.logError(stdError, errorCode,'MCOnline_AddToBasket_V4','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                                outMap.put('StatusCode', 400);
                            }
                        }
                        else{  
                            Map<String, Object> compMsg = new Map<String, Object>();
                            Map<String, Object> result = (Map<String, Object>)HA_AddToBasket.get('result');
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
                                        system.debug('compItems'+compItems);
                                    }
                                }
                                ErrorResponse.put('errorCode',errorCode);                     
                                ErrorResponse.put('error',compItems);
                                ErrorResponse.put('success',success);
                                outMap.put('ErrorResponse',ErrorResponse);
                                MCOnline_Utility.logError(compItems, errorCode,'MCOnline_AddToBasket_V4','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                            }
                        }
                    }
                }
                tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));                    
                admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
                List<Object> tscidRec = [SELECT id FROM Account WHERE TSCID__c=:tscid limit 1];                    
                basketLineRelationId=String.Valueof(inputMap.get('basketLineRelationId'));
                basketLineRelationCount = (Integer)inputMap.get('basketLineRelationCount');
                if(HA_AddToBasket.get('nexttransaction')!=null){
                    multiTransactionKey=String.Valueof((String)((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)HA_AddToBasket.get('nexttransaction')).get('rest')).get('params')).get('multiTransactionKey'));
                }
                offerObj1=(Map<String, Object>)((Map<String, Object>)(productConfigMap1).get('offerDetails')).get('offer');
                //===================parse json===========================//
                Map<String,Map<String,String>> ProdcodeVSlabelUservalues= new Map<String,Map<String,String>>();
                List<Object> childProducts2ndLevel = new List<Object>();
                childProducts2ndLevel= (List<Object>)offerObj1.get('childProducts');
                Map<String, Object> rootproductMap2save = new Map<String, Object>();
                List<Object> rootproductList2save = new List<Object>();
                Decimal mrc_price=0;    
                Decimal nrc_price=0;
                //=====================For attribute labels========================================//
                /*list<MCOnline_Product_Labels__mdt> attributeDisplayList = [select AttributeName__c, AttributeNameDisplay__c from MCOnline_Product_Labels__mdt];
Map<String,string> attributeDisplayMap = new Map<String,string>();
for(MCOnline_Product_Labels__mdt attrlabel:attributeDisplayList){
attributeDisplayMap.put(attrlabel.AttributeName__c,attrlabel.AttributeNameDisplay__c);
}
system.debug(attributeDisplayList); */
                //=================================================================================//
                //==================== For 2nd level child product=================================//
                
                if(childProducts2ndLevel!=null && childProducts2ndLevel.size()>0){
                    
                    for(object productGroup : childProducts2ndLevel){
                        
                        Map<String, Object> childProductResultObj2ndLevel = (Map<String, Object>)productGroup;
                        Map<String, Object> attributeCategoryMap2ndLevel = new Map<String, Object>();
                        Map<String, Object> productAttributesMap2ndLevel = new Map<String, Object>();
                        Map<String, Object> productAttributesrecordsMap2ndLevel = new Map<String, Object>();
                        List<Object> attributeCategoryRecordslst2ndLevel = new List<Object>();
                        List<Object> productAttributesrecordslst2ndLevel = new List<Object>();
                        Map<String,String> labelVsUservalues2ndLevel= new Map<String,String>();
                        //Condition Starts for Port In and Transfer Offers
                        if(childProductResultObj2ndLevel.containskey('Quantity') && childProductResultObj2ndLevel.get('Quantity')==1 && childProductResultObj2ndLevel.containskey('AttributeCategory') == true && childProductResultObj2ndLevel.get('AttributeCategory') != null){
                            Map<String, Object> productMap2save2ndLevel = new Map<String, Object>();
                            List<Object> priceResult2ndLevel = (List<Object>)childProductResultObj2ndLevel.get('priceResult');
                            productMap2save2ndLevel.put('productCode',String.Valueof(childProductResultObj2ndLevel.get('ProductCode')));
                            populateProductfields(childProductResultObj2ndLevel,productMap2save2ndLevel);
                            // added to display multiple pricelist------------------------//
                            if(priceResult2ndLevel!=null){
                                Map<String, Object> priceResultMap2ndLevel = new Map<String, Object>();
                                List<Map<string,Object>> PriceListfor2ndLevel = new List<Map<string,Object>>();// added for pricelist
                                for(Object pricelst2ndLevel:priceResult2ndLevel){
                                    Map<String, Object> PriceListMapfor2ndLevel = new Map<String, Object>(); // added for pricelist
                                    
                                    priceResultMap2ndLevel=(Map<String, Object>)pricelst2ndLevel;
                                    if(String.Valueof(priceResultMap2ndLevel.get('ChargeType__c'))=='Recurring'){
                                        if(((productMap2save2ndLevel.get('actionCode'))!=null)&&((string.valueOf(productMap2save2ndLevel.get('actionCode'))).equalsIgnoreCase('delete') || (string.valueOf(productMap2save2ndLevel.get('actionCode'))).equalsIgnoreCase('updateAttr') || (string.valueOf(productMap2save2ndLevel.get('actionCode'))).equalsIgnoreCase('updateChild'))){
                                            mrc_price=mrc_price+0;
                                        }
                                        else if(((productMap2save2ndLevel.get('actionCode'))!=null)&&((string.valueOf(productMap2save2ndLevel.get('actionCode'))).equalsIgnoreCase('Update') || (string.valueOf(productMap2save2ndLevel.get('actionCode'))).equalsIgnoreCase('Add'))){
                                            mrc_price=mrc_price + (Decimal)priceResultMap2ndLevel.get('Amount__c');
                                        }
                                        PriceListMapfor2ndLevel.put('chargeAmount',String.Valueof(priceResultMap2ndLevel.get('chargeamount')));
                                        PriceListMapfor2ndLevel.put('baseAmount',String.Valueof(priceResultMap2ndLevel.get('baseamount')));
                                        PriceListMapfor2ndLevel.put('amount',String.Valueof(priceResultMap2ndLevel.get('Amount__c')));
                                        //PriceListMapfor2ndLevel.put('nrc_amount',String.Valueof(priceResultMap2ndLevel.get('NRC_Amount__c')));
                                        PriceListMapfor2ndLevel.put('recurringFrequency',String.Valueof(priceResultMap2ndLevel.get('RecurringFrequency__c')));
                                        PriceListMapfor2ndLevel.put('chargeType',String.Valueof(priceResultMap2ndLevel.get('ChargeType__c')));
                                        PriceListMapfor2ndLevel.put('displayText',String.Valueof(priceResultMap2ndLevel.get('DisplayText__c')));
                                    }else if(String.Valueof(priceResultMap2ndLevel.get('ChargeType__c'))=='One-time'){
                                        PriceListMapfor2ndLevel.put('chargeAmount',String.Valueof(priceResultMap2ndLevel.get('chargeamount')));
                                        PriceListMapfor2ndLevel.put('baseAmount',String.Valueof(priceResultMap2ndLevel.get('baseamount')));
                                        //PriceListMapfor2ndLevel.put('amount',String.Valueof(priceResultMap2ndLevel.get('Amount__c')));
                                        PriceListMapfor2ndLevel.put('nrc_amount',String.Valueof(priceResultMap2ndLevel.get('Amount__c')));
                                        PriceListMapfor2ndLevel.put('recurringFrequency',String.Valueof(priceResultMap2ndLevel.get('RecurringFrequency__c')));
                                        PriceListMapfor2ndLevel.put('chargeType',String.Valueof(priceResultMap2ndLevel.get('ChargeType__c')));
                                        PriceListMapfor2ndLevel.put('displayText',String.Valueof(priceResultMap2ndLevel.get('DisplayText__c')));  
                                    }
                                    PriceListfor2ndLevel.add(PriceListMapfor2ndLevel);
                                    
                                }
                                productMap2save2ndLevel.put('price',PriceListfor2ndLevel);
                            }
                            // added to display multiple pricelist------------------------//
                            if(childProductResultObj2ndLevel.containskey('AttributeCategory'))
                                attributeCategoryMap2ndLevel=(Map<String, Object>)childProductResultObj2ndLevel.get('AttributeCategory');
                            
                            if(attributeCategoryMap2ndLevel!=null && attributeCategoryMap2ndLevel.size()>0 && attributeCategoryMap2ndLevel.containskey('records')){
                                attributeCategoryRecordslst2ndLevel=(List<Object>)attributeCategoryMap2ndLevel.get('records');
                                productAttributesMap2ndLevel=(Map<String, Object>)attributeCategoryRecordslst2ndLevel[0];
                                productAttributesrecordsMap2ndLevel=(Map<String, Object>)productAttributesMap2ndLevel.get('productAttributes');
                                productAttributesrecordslst2ndLevel=(List<Object>)productAttributesrecordsMap2ndLevel.get('records');
                                Map<String, Object> attr2ndLevel = new Map<String, Object> ();
                                
                                productAttributesrecordslst2ndLevel=(List<Object>)productAttributesrecordsMap2ndLevel.get('records');
                                Map<String, Object> productAttributeObj12ndLevel = new Map<String, Object>();
                                for(Object prodattrobj2ndLevel: productAttributesrecordslst2ndLevel){
                                    Map<String, Object> productAttributeObj2ndLevel = (Map<String, Object>)prodattrobj2ndLevel;
                                    
                                    //productAttributeObj12ndLevel.put(String.ValueOf(attributeDisplayMap.get(string.valueOf(productAttributeObj2ndLevel.get('code')))),String.Valueof(productAttributeObj2ndLevel.get('userValues')));
                                    //system.debug(productAttributeObj12ndLevel);    
                                    productAttributeObj12ndLevel.put(String.Valueof(productAttributeObj2ndLevel.get('label')),String.Valueof(productAttributeObj2ndLevel.get('userValues')));
                                    
                                    
                                }
                                
                                productMap2save2ndLevel.put('attributes',productAttributeObj12ndLevel);                      
                            }
                            rootproductList2save.add(productMap2save2ndLevel);  
                        }
                        
                        
                        List<Object> childproductList = new List<Object>();
                        childproductList= (List<Object>)childProductResultObj2ndLevel.get('childProducts');
                        //==================== For 3rd level child product=================================//
                        if(childproductList!=null && childproductList.size()>0){
                            
                            for(object childProduct: childproductList){
                                
                                Map<String, Object> childProductResultObj = (Map<String, Object>)childProduct;
                                Map<String, Object> attributeCategoryMap = new Map<String, Object>();
                                Map<String, Object> productAttributesMap = new Map<String, Object>();
                                Map<String, Object> productAttributesrecordsMap = new Map<String, Object>();
                                List<Object> attributeCategoryRecordslst = new List<Object>();
                                List<Object> productAttributesrecordslst = new List<Object>();
                                Map<String,String> labelVsUservalues= new Map<String,String>();
                                
                                if(childProductResultObj.containskey('Quantity') && childProductResultObj.get('Quantity')==1){
                                    
                                    Map<String, Object> productMap2save = new Map<String, Object>();
                                    List<Object> priceResult = (List<Object>)childProductResultObj.get('priceResult');
                                    productMap2save.put('productCode',String.Valueof(childProductResultObj.get('ProductCode')));
                                    
                                    populateProductfields(childProductResultObj,productMap2save);
                                    
                                    //added to display multiple pricelist----------------------->
                                    if(priceResult!=null){
                                        Map<String, Object> priceResultMap = new Map<String, Object>();
                                        List<Map<string,Object>> PriceListfor3rdLevel = new List<Map<string,Object>>(); // added for pricelist
                                        //negotiatedPrice=negotiatedPrice + (Decimal)priceResultMap.get('Amount__c');
                                        for(Object pricelst:priceResult){
                                            Map<String, Object> PriceListMapfor3rdLevel = new Map<String, Object>(); // added for pricelist
                                            priceResultMap=(Map<String, Object>)pricelst ; 
                                            if(String.Valueof(priceResultMap.get('ChargeType__c'))=='Recurring'){
                                                if(((productMap2save.get('actionCode'))!=null)&&((string.valueOf(productMap2save.get('actionCode'))).equalsIgnoreCase('delete') || (string.valueOf(productMap2save.get('actionCode'))).equalsIgnoreCase('updateAttr') || (string.valueOf(productMap2save.get('actionCode'))).equalsIgnoreCase('updateChild'))){
                                                    mrc_price=mrc_price+0;
                                                }
                                                else if(((productMap2save.get('actionCode'))!=null)&&((string.valueOf(productMap2save.get('actionCode'))).equalsIgnoreCase('Update') || (string.valueOf(productMap2save.get('actionCode'))).equalsIgnoreCase('Add'))){
                                                    mrc_price=mrc_price + (Decimal)priceResultMap.get('Amount__c');
                                                }
                                                PriceListMapfor3rdLevel.put('chargeAmount',String.Valueof(priceResultMap.get('chargeamount')));
                                                PriceListMapfor3rdLevel.put('baseAmount',String.Valueof(priceResultMap.get('baseamount')));
                                                PriceListMapfor3rdLevel.put('amount',String.Valueof(priceResultMap.get('Amount__c')));
                                                //PriceListMapfor3rdLevel.put('nrc_amount',String.Valueof(priceResultMap.get('NRC_Amount__c')));
                                                PriceListMapfor3rdLevel.put('recurringFrequency',String.Valueof(priceResultMap.get('RecurringFrequency__c')));
                                                PriceListMapfor3rdLevel.put('chargeType',String.Valueof(priceResultMap.get('ChargeType__c')));
                                                PriceListMapfor3rdLevel.put('displayText',String.Valueof(priceResultMap.get('DisplayText__c')));
                                            }else if(String.Valueof(priceResultMap.get('ChargeType__c'))=='One-time'){
                                                nrc_price=nrc_price + (Decimal)priceResultMap.get('Amount__c');
                                                PriceListMapfor3rdLevel.put('chargeAmount',String.Valueof(priceResultMap.get('chargeamount')));
                                                PriceListMapfor3rdLevel.put('baseAmount',String.Valueof(priceResultMap.get('baseamount')));
                                                PriceListMapfor3rdLevel.put('nrc_amount',String.Valueof(priceResultMap.get('Amount__c')));
                                                PriceListMapfor3rdLevel.put('recurringFrequency',String.Valueof(priceResultMap.get('RecurringFrequency__c')));
                                                PriceListMapfor3rdLevel.put('chargeType',String.Valueof(priceResultMap.get('ChargeType__c')));
                                                PriceListMapfor3rdLevel.put('displayText',String.Valueof(priceResultMap.get('DisplayText__c')));                                                            
                                            }
                                            //system.debug(JSON.serialize(PriceListMapfor3rdLevel));
                                            PriceListfor3rdLevel.add(PriceListMapfor3rdLevel);
                                            
                                        }
                                        productMap2save.put('price',PriceListfor3rdLevel);
                                    }
                                    
                                    if(childProductResultObj.containskey('AttributeCategory'))
                                        attributeCategoryMap=(Map<String, Object>)childProductResultObj.get('AttributeCategory');
                                    
                                    if(attributeCategoryMap!=null && attributeCategoryMap.size()>0 && attributeCategoryMap.containskey('records')){
                                        attributeCategoryRecordslst=(List<Object>)attributeCategoryMap.get('records');
                                        productAttributesMap=(Map<String, Object>)attributeCategoryRecordslst[0];
                                        productAttributesrecordsMap=(Map<String, Object>)productAttributesMap.get('productAttributes');
                                        productAttributesrecordslst=(List<Object>)productAttributesrecordsMap.get('records');
                                        Map<String, Object> attr = new Map<String, Object> ();
                                        productAttributesrecordslst=(List<Object>)productAttributesrecordsMap.get('records');
                                        Map<String, Object> productAttributeObj1 = new Map<String, Object>();
                                        for(Object prodattrobj: productAttributesrecordslst){
                                            Map<String, Object> productAttributeObj = (Map<String, Object>)prodattrobj;
                                            
                                            
                                            //productAttributeObj1.put(String.Valueof(attributeDisplayMap.get(String.ValueOf(productAttributeObj.get('code')))),String.Valueof(productAttributeObj.get('userValues')));
                                            //system.debug(productAttributeObj1);
                                            //system.debug(JSON.serialize(productAttributeObj1));    
                                            productAttributeObj1.put(String.Valueof(productAttributeObj.get('label')),String.Valueof(productAttributeObj.get('userValues')));
                                            
                                            
                                        }
                                        //system.debug(JSON.serialize(productAttributeObj1));
                                        productMap2save.put('attributes',productAttributeObj1);
                                        
                                    }
                                    rootproductList2save.add(productMap2save);
                                    
                                    //================================= 4th level child products==================================//
                                    List<Object> childproductList4thlevel = new List<Object>();
                                    childproductList4thlevel= (List<Object>)childProductResultObj.get('childProducts');
                                    if(childproductList4thlevel!=null && childproductList4thlevel.size()>0){
                                        
                                        for(object childProduct4thlevel: childproductList4thlevel){
                                            
                                            Map<String, Object> childProductResultObj4thlevel = (Map<String, Object>)childProduct4thlevel;
                                            Map<String, Object> attributeCategoryMap4thlevel = new Map<String, Object>();
                                            Map<String, Object> productAttributesMap4thlevel = new Map<String, Object>();
                                            Map<String, Object> productAttributesrecordsMap4thlevel = new Map<String, Object>();
                                            List<Object> attributeCategoryRecordslst4thlevel = new List<Object>();
                                            List<Object> productAttributesrecordslst4thlevel = new List<Object>();
                                            Map<String,String> labelVsUservalues4thlevel = new Map<String,String>();
                                            
                                            if(childProductResultObj4thlevel.containskey('Quantity') && childProductResultObj4thlevel.get('Quantity')==1){
                                                
                                                Map<String, Object> productMap2save4thlevel = new Map<String, Object>();
                                                List<Object> priceResult4thlevel = (List<Object>)childProductResultObj4thlevel.get('priceResult');
                                                productMap2save4thlevel.put('productCode',String.Valueof(childProductResultObj4thlevel.get('ProductCode')));
                                                
                                                populateProductfields(childProductResultObj4thlevel,productMap2save4thlevel);
                                                /*if(priceResult4thlevel!=null && priceResult4thlevel.size()>0){
Map<String, Object> priceResultMap4thlevel = new Map<String, Object>();
//priceResultMap4thlevel=(Map<String, Object>)priceResult4thlevel[0] ;  
//negotiatedPrice=negotiatedPrice + (Decimal)priceResultMap4thlevel.get('Amount__c');
for(Object pricelst:priceResult4thlevel){
priceResultMap4thlevel=(Map<String, Object>)pricelst ; 
if(String.Valueof(priceResultMap4thlevel.get('ChargeType__c'))=='Recurring'){
mrc_price=mrc_price + (Decimal)priceResultMap4thlevel.get('Amount__c');
productMap2save4thlevel.put('chargeAmount',String.Valueof(priceResultMap4thlevel.get('chargeamount')));
productMap2save4thlevel.put('baseAmount',String.Valueof(priceResultMap4thlevel.get('baseamount')));
productMap2save4thlevel.put('amount',String.Valueof(priceResultMap4thlevel.get('Amount__c')));
productMap2save4thlevel.put('recurringFrequency',String.Valueof(priceResultMap4thlevel.get('RecurringFrequency__c')));
productMap2save4thlevel.put('chargeType',String.Valueof(priceResultMap4thlevel.get('ChargeType__c')));
productMap2save4thlevel.put('displayText',String.Valueof(priceResultMap4thlevel.get('DisplayText__c')));
}else if(String.Valueof(priceResultMap4thlevel.get('ChargeType__c'))=='One-time'){
productMap2save4thlevel.put('nrc_amount',String.Valueof(priceResultMap4thlevel.get('Amount__c')));
nrc_price=nrc_price + (Decimal)priceResultMap4thlevel.get('Amount__c');
//Temporary Solution For list Price
//productMap2save4thlevel.put('baseAmount',String.Valueof(priceResultMap4thlevel.get('baseamount')));
}
}
} */
                                                // added to display multiple pricelist------------------------//
                                                if(priceResult4thlevel!=null && priceResult4thlevel.size()>0){
                                                    Map<String, Object> priceResultMap4thlevel = new Map<String, Object>();
                                                    List<Map<string,Object>> PriceListfor4thLevel = new List<Map<string,Object>>(); // added for pricelist
                                                    //priceResultMap4thlevel=(Map<String, Object>)priceResult4thlevel[0] ;  
                                                    //negotiatedPrice=negotiatedPrice + (Decimal)priceResultMap4thlevel.get('Amount__c');
                                                    for(Object pricelst:priceResult4thlevel){
                                                        Map<String, Object> PriceListMapfor4thLevel = new Map<String, Object>(); // added for pricelist
                                                        priceResultMap4thlevel=(Map<String, Object>)pricelst ; 
                                                        if(String.Valueof(priceResultMap4thlevel.get('ChargeType__c'))=='Recurring'){
                                                            if(((productMap2save4thlevel.get('actionCode'))!=null)&&((string.valueOf(productMap2save4thlevel.get('actionCode'))).equalsIgnoreCase('delete') || (string.valueOf(productMap2save4thlevel.get('actionCode'))).equalsIgnoreCase('updateAttr') || (string.valueOf(productMap2save4thlevel.get('actionCode'))).equalsIgnoreCase('updateChild'))){
                                                                mrc_price=mrc_price+0;
                                                            }
                                                            else if(((productMap2save4thlevel.get('actionCode'))!=null)&&((string.valueOf(productMap2save4thlevel.get('actionCode'))).equalsIgnoreCase('Update') || (string.valueOf(productMap2save4thlevel.get('actionCode'))).equalsIgnoreCase('Add'))){
                                                                mrc_price=mrc_price + (Decimal)priceResultMap4thlevel.get('Amount__c');
                                                            }
                                                            PriceListMapfor4thLevel.put('chargeAmount',String.Valueof(priceResultMap4thlevel.get('chargeamount')));
                                                            PriceListMapfor4thLevel.put('baseAmount',String.Valueof(priceResultMap4thlevel.get('baseamount')));
                                                            PriceListMapfor4thLevel.put('amount',String.Valueof(priceResultMap4thlevel.get('Amount__c')));
                                                            PriceListMapfor4thLevel.put('recurringFrequency',String.Valueof(priceResultMap4thlevel.get('RecurringFrequency__c')));
                                                            PriceListMapfor4thLevel.put('chargeType',String.Valueof(priceResultMap4thlevel.get('ChargeType__c')));
                                                            PriceListMapfor4thLevel.put('displayText',String.Valueof(priceResultMap4thlevel.get('DisplayText__c')));
                                                        }else if(String.Valueof(priceResultMap4thlevel.get('ChargeType__c'))=='One-time'){
                                                            PriceListMapfor4thLevel.put('nrc_amount',String.Valueof(priceResultMap4thlevel.get('Amount__c')));
                                                            PriceListMapfor4thLevel.put('chargeAmount',String.Valueof(priceResultMap4thlevel.get('chargeamount')));
                                                            PriceListMapfor4thLevel.put('baseAmount',String.Valueof(priceResultMap4thlevel.get('baseamount')));
                                                            nrc_price=nrc_price + (Decimal)priceResultMap4thlevel.get('Amount__c');
                                                            PriceListMapfor4thLevel.put('recurringFrequency',String.Valueof(priceResultMap4thlevel.get('RecurringFrequency__c')));
                                                            PriceListMapfor4thLevel.put('chargeType',String.Valueof(priceResultMap4thlevel.get('ChargeType__c')));
                                                            PriceListMapfor4thLevel.put('displayText',String.Valueof(priceResultMap4thlevel.get('DisplayText__c')));
                                                            //Temporary Solution For list Price
                                                            //productMap2save4thlevel.put('baseAmount',String.Valueof(priceResultMap4thlevel.get('baseamount')));
                                                        }
                                                        //system.debug(JSON.serialize(PriceListMapfor4thLevel));
                                                        PriceListfor4thLevel.add(PriceListMapfor4thLevel);
                                                    }
                                                    productMap2save4thlevel.put('price',PriceListfor4thLevel);
                                                }
                                                // added to display multiple pricelist------------------------//
                                                if(childProductResultObj4thlevel.containskey('AttributeCategory'))
                                                    attributeCategoryMap4thlevel=(Map<String, Object>)childProductResultObj4thlevel.get('AttributeCategory');
                                                if(attributeCategoryMap4thlevel!=null && attributeCategoryMap4thlevel.size()>0 && attributeCategoryMap4thlevel.containskey('records')){
                                                    attributeCategoryRecordslst4thlevel=(List<Object>)attributeCategoryMap4thlevel.get('records');
                                                    productAttributesMap4thlevel=(Map<String, Object>)attributeCategoryRecordslst4thlevel[0];
                                                    productAttributesrecordsMap4thlevel=(Map<String, Object>)productAttributesMap4thlevel.get('productAttributes');
                                                    productAttributesrecordslst4thlevel=(List<Object>)productAttributesrecordsMap4thlevel.get('records');
                                                    Map<String, Object> attr1 = new Map<String, Object> ();
                                                    for(Object prodattrobj4thlevel: productAttributesrecordslst4thlevel){
                                                        attr1.put(String.Valueof(((Map<String, Object>)prodattrobj4thlevel).get('label')),String.Valueof(((Map<String, Object>)prodattrobj4thlevel).get('userValues')));
                                                        
                                                        Map<String, Object> productAttribute4thObj = (Map<String, Object>)prodattrobj4thlevel;
                                                        
                                                        
                                                        //attr1.put(String.Valueof(attributeDisplayMap.get(String.ValueOf(productAttribute4thObj.get('code')))),String.Valueof(productAttribute4thObj.get('userValues')));
                                                        
                                                        //productAttributeObj12ndLevel.put(String.Valueof(productAttribute4thObj.get('AttributeNameDisplay__c')),String.Valueof(productAttribute4thObj.get('userValues')));
                                                        
                                                        
                                                    }
                                                    
                                                    
                                                    //system.debug(JSON.serialize(attr1));
                                                    productMap2save4thlevel.put('attributes',attr1);
                                                }
                                                rootproductList2save.add(productMap2save4thlevel);
                                            }
                                        }
                                    }
                                    //================================= 4th level child products==================================//
                                }
                            }
                        }
                    }
                    rootproductMap2save.put('products',rootproductList2save);
                    System.debug(rootproductMap2save);
                    AttributeJSON=JSON.serialize(rootproductMap2save) ;
                }
                //==================parse json============================//
                
                if(Parameters.size()==0 || Parameters == null)
                {
                    Accountid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Accountid'));
                    //Id accId = [select id from Account where id=: Accountid LIMIT 1 FOR UPDATE]?.id;
                    tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
                    admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
                    Agreementid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
                    //get ICC Number
                    Map<String,Object> productDetails = (Map<String,Object>)JSON.deserializeUntyped(AttributeJSON);
                    iccNumber = processAttribJSON(productDetails);    
                }
                else{
                    Accountid =String.Valueof(Parameters[0].Account__c);
                    tscid = String.Valueof(Parameters[0].TSCID__c);
                    admin = String.Valueof(Parameters[0].MCOnline_ParentBasket__r.Admin__c);
                    Agreementid = String.Valueof(Parameters[0].MCOnline_ParentBasket__r.AgreementId__c);
                    Catalog = String.Valueof(Parameters[0].MCOnline_Catalog__c);
                    //get ICC Number
                    Map<String,Object> productDetails = (Map<String,Object>)JSON.deserializeUntyped(AttributeJSON);
                    iccNumber = processAttribJSON(productDetails);    
                }
                List<MCOnline_ParentBasket__c> parentbas=new List<MCOnline_ParentBasket__c>();
                if(isManagedFlow==false){
                    parentbas=[SELECT id,name,OrderNumber__c FROM MCOnline_ParentBasket__c WHERE AgreementId__c=:Agreementid AND TSCID__c=:tscid AND Admin__c=:admin AND Is_Processed__c =false AND flow__c='SALESFLOW' order by createddate desc limit 1];
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
                        pbas.AgreementId__c= Agreementid;
                        pbas.flow__c = 'SALESFLOW';
                        insert pbas;
                        parentbasket=pbas.id;
                        orderNumber=pbas.OrderNumber__c;
                    }
                }
                else{
                    parentbas=[SELECT id,name,OrderNumber__c FROM MCOnline_ParentBasket__c WHERE AgreementId__c=:Agreementid AND TSCID__c=:tscid AND Admin__c=:admin AND Is_Processed__c =false AND flow__c='MANAGEFLOW' AND Id =: uniqueParentId order by createddate desc limit 1];
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
                        pbas.AgreementId__c= Agreementid;
                        pbas.flow__c = 'MANAGEFLOW';
                        insert pbas;
                        uniqueParentId = pbas.id;
                        parentbasket=pbas.id;
                        orderNumber=pbas.OrderNumber__c;
                    }
                }
                if((addtobasketResponse!=null || !addtobasketResponse.isEmpty())&& addtobasketResponse.containskey('cartContextKey')){
                    cartContextKey=   String.valueof(addtobasketResponse.get('cartContextKey'));
                    orderid= String.valueof(((Map<String,object>)((List<object>)((Map<String,object>)addtobasketResponse.get('result')).get('records'))[0]).get('OrderId'));
                }
                if(ismultiTransactionKey==false ){
                    MCOnline_Basket__c bas=new MCOnline_Basket__c();
                    bas.TSCID__c= tscid;
                    bas.Account__c=Accountid;
                    bas.MCOnline_ParentBasket__c=parentbasket;
                    bas.MCOnline_Catalog__c= Catalog;
                    bas.MCOnline_OfferCode__c=String.valueof(offerObj1.get('ProductCode'));
                    //added by binamra
                    bas.MConline_Offer_ActionCode__c = (offerObj1.get('MConline_Action_Code__c')!=null) ? String.valueOf(offerObj1.get('MConline_Action_Code__c')): 'Add';
                    if(!string.isBlank(cartContextKey) && !string.isBlank(orderid)){
                        bas.MCOnline_Basket_Key__c=cartContextKey;
                        //bas.MCOnline_Order__c= orderid;
                    }
                    bas.MCOnline_AttributeJSON__c= AttributeJSON;
                    //bas.Request_body__c=productConfigMap;
                    bas.MCOnline_MRC_Amount__c= mrc_price; //MCOnline_Negotiated_Amount__c  
                    bas.MCOnline_NRC_Amount__c= nrc_price;
                    bas.Basket_Line_Relation_Id__c = String.Valueof(inputMap.get('basketLineRelationId'));
                    bas.basket_Line_Relation_Count__c =(Decimal)inputMap.get('basketLineRelationCount');
                    bas.MCOnline_ICC_Number__c = iccNumber;
                    insert bas;
                    /*if(((Map<String,Object>)(((Map<String,Object>)(((List<Object>)((Map<string,Object>)JSON.deserializeUntyped(AttributeJSON)).get('products'))[0])).get('attributes'))).get('NumberReservationRequired')!= null && (string.valueOf(((Map<String,Object>)(((Map<String,Object>)(((List<Object>)((Map<string,Object>)JSON.deserializeUntyped(AttributeJSON)).get('products'))[0])).get('attributes'))).get('NumberReservationRequired'))).equalsIgnoreCase('YES')){
MCOnline_Utility.reserveNumber(AttributeJSON, cartContextKey, tscid,'addToBasket');
}*/
                    
                        if(!String.isBlank(AttributeJSON))
                        {
                            String UpdatedAttributeJSON = formatMSISDN(AttributeJSON, isManagedFlow);
                            //System.debug(UpdatedAttributeJSON);
                            MCOnline_Utility.reserveNumber(UpdatedAttributeJSON, cartContextKey, tscid,'addToBasket');
                        }
                    
                    BasketIds.add(bas.id);
                    if(multiTransactionKey != null && !string.isBlank(multiTransactionKey)){
                        storeInput.put(String.valueOf(bas.id), productConfigMap);
                    }
                    outMap.put('itemBasketId',BasketIds);                       
                    outMap.put('parentBasketId', parentbasket);
                    if(!hasError){
                        success=true;
                        outMap.put('success',true);
                    }
                }
                
                
            }
            
            else{  // MTS
                outMap.put('Addtobasket_RA',addtobasketResponse);
            }
        }Catch(Exception e){   
            hasError = true;
            Map<String, Object> ErrorResponse = new Map<String, Object>();
            System.debug('Error Message===>: ' + e.getMessage()); 
            System.debug('Error Line number===>: ' + e.getLineNumber()); 
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
                logErrors(errorCode,final_message,inputMap,outMap,ErrorResponse);           
            }else
            {   outMap.put('ErrorResponse', MCOnline_Utility.generateError(stdError1,errorCode,'custom', 'MultiAddToBasketAndCheckOut'));
             MCOnline_Utility.logError(final_message,'500','MCOnline_AddToBasket_V4','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'',''); 
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
            if(isManagedFlow==false){
               Map<String, Object> attributeMap = (Map<String, Object>)recObj.get('attributes');
               if(attributeMap != null)
               {
                   if(String.valueOf(attributeMap.get('NumberReservationRequired')) != null && String.valueOf(attributeMap.get('NumberReservationRequired')).equalsIgnoreCase('No'))
                   {
                       productList.remove(i);
                   }
               }
            }
            else if(isManagedFlow==true){
                
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
    
    public static Map<String,Object> generateError(string error,string errorCode,string errorType,Map<String,Object> inputMap, String Catalog1,List<MCOnline_Basket__c>Parameters){
        string Accountid;
        string tscid;
        string admin;
        string Agreementid;
        string Catalog= Catalog1;
        if(Parameters.size()==0 || Parameters == null)
        {
            Accountid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Accountid'));
            tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
            admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
            Agreementid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
        }
        else{
            Accountid =String.Valueof(Parameters[0].Account__c);
            tscid = String.Valueof(Parameters[0].TSCID__c);
            admin = String.Valueof(Parameters[0].MCOnline_ParentBasket__r.Admin__c);
            Agreementid = String.Valueof(Parameters[0].MCOnline_ParentBasket__r.AgreementId__c);
            Catalog = String.Valueof(Parameters[0].MCOnline_Catalog__c);
        }
        string urlDetails = '{"Agreementid": "'+Agreementid+'", "tscid":"'+tscid+'", "users":"'+admin+'", "Catalog":"'+Catalog+'", "Accountid":"'+Accountid+'"}'; 
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        ipInputMap.put('functionality', 'AddToBasket');
        ipInputMap.put('error', error);   
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_AddToBasket_V4,MCOnline_AddToBasket_V4.generateError','Integration Procedure, Apex Class', 'Custom Error','STRING_TOO_LONG','','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    
    private static void populateProductfields(Map<String,Object> productMap,Map<String,Object> productMapToReturn)
    {
        //system.debug(productFields);
        for(String field:productFields)
        {
          productMapToReturn.put(string.valueOf(fieldsToMap.get(field)),String.valueOf(productMap.get(field)));
        }
        if(String.isBlank((String)productMap.get('MConline_Action_Code__c')))
            productMapToReturn.put('actionCode','Add');
        else
            productMapToReturn.put('actionCode',String.valueOf(productMap.get('MConline_Action_Code__c')));
    }
    
    private static String processAttribJSON(Map<String,Object> productDetails){
        List<Object> prodList = (List<Object>)productDetails.get('products');
        String iccNumber;
        for(Object item:prodList){
            Map<string,object> prod = (Map<string,object>)item;
            if(prod.containsKey('attributes')){
                Map<string,object> attr = (Map<string,object>)prod.get('attributes');
                system.debug('attr -->'+attr);
                if(attr.containsKey('ICC_number')){
                    iccNumber = String.Valueof(attr.get('ICC_number'));
                    //system.debug('iccNumber -->'+iccNumber);
                    break;
                }
            }
        }
        return iccNumber;
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
    private static void logErrors(String errorCode,String final_message,Map<String,Object> inputMap,Map<String,Object> outMap, Map<String,Object> ErrorResponse){
        if(errorCode == 'UNABLE_TO_LOCK_ROW'){
            string errmsg = 'there is an on going checkout. please hold for a while before proceeding towards the next transaction';
            ErrorResponse.put('errorCode',errorCode);                   
            ErrorResponse.put('error',errmsg);
            ErrorResponse.put('success',false);
            outMap.put('ErrorResponse',ErrorResponse);
            outMap.put('StatusCode',400);
            MCOnline_Utility.logError(final_message, errorCode,'MCOnline_AddToBasket_V5','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');               
        }
        else{               
            outMap.put('ErrorResponse', MCOnline_Utility.generateError('',errorCode,'custom', 'MultiAddToBasketAndCheckOut'));
            MCOnline_Utility.logError(final_message, errorCode,'MCOnline_AddToBasket_V5','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
        }
    }
}