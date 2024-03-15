/****************************************************************************************************************************
* @author                 Aparajita Banerjee
* @modifiedBy             Aparajita Banerjee
* @maintainedBy           Aparajita Banerjee
* @version                3.0
* @description            Multi add to basket for manage flow
* @modified               9/3/2022
******************************************************************************************************************************/
global with sharing class MCOnline_MultiAddToBasketAndCheckOut_V3 implements vlocity_cmt.VlocityOpenInterface {
    static Map<String,Object> AsynchBasketCreationMap = new Map<String,Object>();
    static Map<String, Object> inputAsynch = new Map<String, Object>();
    public static Map<String, String> storeInput = new Map<String, String>();
    static Trim_GetOfferDetails__mdt finalNodeslist = [Select MCONL_Attributes_to_Remove__c from Trim_GetOfferDetails__mdt];
    static String finalNodeslistStr=finalNodeslist.MCONL_Attributes_to_Remove__c;
    static List<String> finalNodeslistStrtolist = finalNodeslistStr.split(',');
    static Set<String> finalNodes= new Set<String>(finalNodeslistStrtolist);
    static List<Product2> fieldsToAdd = [select vlocity_cmt__AttributeMetadata__c, ProductCode,Ordering_Flag__c from Product2] ;
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Id parentbasket;
        string parentId;
        integer count1=0;
        List<id> BasketIds = new List<id>();
        List<String> Baskets = new List<String>();
        List<String> orderNumber = new List<String>();
        boolean AsynchronousProcessExists = false;
        Map<String, Object> outputAsynch = new Map<String, Object>();
        Map<String, Object> optionAsynch = new Map<String, Object>();
        string TSCID = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
        string AgreementId = String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
        string User = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
        if(methodName.equals('addtobasket_remotemethod'))
        {  
            Map<String, Object> remotemethodResponse = new Map<String, Object>();
            Map<String, Object> productConfigMap = new Map<String, Object>();
            List<Object> productConfigList = new List<Object>();
            productConfigList = (List<Object>)inputMap.get('productConfig');
            if(string.isBlank(String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID')))|| string.isBlank(String.Valueof(((Map<string,object>)inputMap.get('options')).get('users')))){
                //hasError = true;
                String errorCode = 'INAVALID_USER_TSCID';
                outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, ''));
                outMap.put('StatusCode', 500);
            } 
            else if(string.isBlank(string.valueOf(inputMap.get('basketLineRelationId'))) || string.isBlank(string.valueOf(inputMap.get('basketLineRelationCount'))) || inputMap.get('basketLineRelationCount')==0){
                //hasError = true;
                String errorCode = 'BASKET_LINE_RELATION_ID_COUNT_ERROR';
                outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, ''));
                outMap.put('StatusCode', 500);
            }
            else{
                if(productConfigList.size()!= inputMap.get('basketLineRelationCount')){
                    //hasError = true;
                    String errorCode = 'BASKET_LINE_RELATION_COUNT_MISMATCH';
                    outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, ''));
                    outMap.put('StatusCode', 500);
                }
                else{
                    for(Object offers: productConfigList){
                        count1++;
                        if(!outMap.containsKey('ErrorResponse')){
                            //Added by Binamra Guha
                            /*-------------------Trimming of request body------------------------*/
                            Map<String, Object> tempMap = (Map<String, Object>)offers;
                            removeItems(tempMap);
                            productConfigMap = (Map<String, Object>)tempMap;
                            /*--------------------------------------------------------------*/
                            //productConfigMap = (Map<String, Object>)offers;
                            string Catalog='';
                            //Added to make the catalog more dynamic
                            /*------------------------------------------------------------------*/
                            String getCatalogStr = String.valueOf((((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)( (Map<String, Object>)(productConfigMap).get('offerDetails')).get('offer')).get('addtocart')).get('rest')).get('link')));
                            Integer startIndex = getCatalogStr.indexOf('s/')+2;
                            Integer endIndex = getCatalogStr.indexOf('/basket');
                            Catalog = getCatalogStr.substring(startIndex, endIndex);
                            /*-------------------------------------------------------------------*/
                            string cartContextKey = String.valueof(inputMap.get('contextKey'));
                            remotemethodResponse=addtobasket_remotemethod(cartContextKey,JSON.serialize(productConfigMap),Catalog);
                            outMap=addToBasket_V2_NormalCallout(inputMap,remotemethodResponse, outMap,options,JSON.serialize(productConfigMap),BasketIds,Catalog,parentbasket);
                            
                        }            
                    }
                }
            }  
        }
        //Added by Aparajita Banerjee on 20/7/2021
        //Last modified on 26/7/2021
        /*____________________________________________________________________________________________________________________
*20/7/2021
*This piece of code fetches the input of the baskets to be modified and then proceeds towards an asynchronous checkout
*ModifyBasket_V2_Checkout = checkout Method
*____________________________________________________________________________________________________________________       
*26/7/2021
*This piece of code displays the list of basket Name of the baskets created 
*____________________________________________________________________________________________________________________
*/
        if(outmap.containsKey('parentbasket')){
            parentId = String.valueOf(outMap.get('parentbasket'));
        }
        if(outmap.containsKey('ErrorResponse')){
            Map<string,object> ErrorResponse = new Map<string,object>();
            ErrorResponse = (Map<string,object>)outmap.get('ErrorResponse');
            outmap.clear();
            outmap.put('ErrorResponse',ErrorResponse);
            outMap.put('StatusCode',400);
            if(!string.isEmpty(parentId) && (BasketIds!=null || BasketIds.size()>0)){
                deleteBasket(BasketIds,parentId);
            }
        } 
        else{
            list<MCOnline_ParentBasket__c> Names = new list<MCOnline_ParentBasket__c>();
            Names = [select id, (select Name from MCOnline_Basket__r) from MCOnline_ParentBasket__c where Id=:parentId order by createdDate asc];
            for(MCOnline_Basket__c o: Names[0].MCOnline_Basket__r)
            {
                Baskets.add(o.Name);
            }
            outMap.put('basket',Baskets);
            if(storeInput != null && !storeInput.isEmpty())
            {
                orderNumber=splitLogicOrder(parentId);
                outMap.put('orderNumber', orderNumber);
                createAsynchBasketsBatch cls = new createAsynchBasketsBatch(storeInput, inputMap, (Map<String, Object>)inputMap.get('orderDetails'),TSCID,AgreementId,User);
                Database.executeBatch(cls, 1);
                
            }else{
                orderNumber=MultiAddToBasketAndCheckOut_V3_Checkout(JSON.serialize((Map<String, Object>)inputMap.get('orderDetails')),TSCID,AgreementId,User);
                outMap.put('orderNumber', orderNumber);
            }
        }
        system.debug(outmap);
        return true;
        
    }
    //Added by Binamra Guha
    /* ___________________________________________________________________________________________________________
* This removeItems method is used for the trimming the productConfig node from the inputMap.
* This Method with reduce the number of Product node with Quantiy zero.
* ___________________________________________________________________________________________________________
* @param obj                                 This will have the list of Offers
* ___________________________________________________________________________________________________________   
*/
    public static void removeItems(Object obj){
        
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
        addCommitment(offer1);           
    }
    //Added by Aparajita
    /* ___________________________________________________________________________________________________________
* This method is for adding the 24 and 36 commitment period if not there  
* creation of baskets   
* ___________________________________________________________________________________________________________   
*/    
    public static void addCommitment(Object obj)
    {
        Map<String, Object> tempMap = (Map<String, Object>)obj;
        if(tempMap.containsKey('AttributeCategory') && tempMap.get('AttributeCategory') != null){
           addField(tempMap);
        }
        if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
        {
            List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
            for(Object obj3:childProducts)
            {
                addCommitment(obj3);
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
                                addCommitment(obj1);
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
                system.debug(commitmentValue);
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
    public static void addField(Map<String, Object> obj){
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
    
    //Added by Aparajita
    /* ___________________________________________________________________________________________________________
* This deleteBasket method is used to delete the baskets that were created inspite an unsuccesfull 
* creation of baskets   
* ___________________________________________________________________________________________________________   
*/
    @future(callout=true)
    public static void deleteBasket(List<id> BasketIds, string parentId){
        list<MCOnline_ParentBasket__c> InvalidBasketIds = [select (select id from MCOnline_Basket__r) from MCOnline_ParentBasket__c where id=: parentId];
        for(MCOnline_Basket__c bsktId : InvalidBasketIds[0].MCOnline_Basket__r){
            for(id ids: BasketIds){
                if(bsktId.id == ids)
                    delete bsktId;
            }
        }
    }
    
    //Modified by Aparajita
    /*_________________________________________________________________________________________________________________________
* This method will now return the output irrespective of the an MTS encounter. 
* In case of an MTS, that particular transaction will become asynchronous
*__________________________________________________________________________________________________________________________
*/  
    public static Map<String,Object> addtobasket_remotemethod(String cartContextKey,String productConfigMap,string catalogCode){
        
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
            input.put('validate','false');
            vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
            system.debug('input-> '+input);
            appHandler.invokeMethod('addAfterConfig', input, output, option);
            System.debug('===MultiAddToBasketAndCheckOut output===>: ' + output);
        }
        Catch(Exception e){   
            String error_message= e.getMessage() +' '+e.getLineNumber();
            system.debug('error message'+error_message);
            string stdError;
            if(error_message.contains('Invalid Context')){
                stdError = 'Invalid Context Info';                
                output.put('error',stdError);
                output.put('errorCode','INVOKE-500');
                output.put('success','false');
                system.debug('output catch==>'+output);
            }
        }
        return output; 
    }
    public static Map<String,Object> addToBasket_V2_NormalCallout(Map<String,Object> inputMap,Map<String,Object> HA_AddToBasket, Map<String,Object> outMap, Map<String,Object> options,String productConfigMap,List<id> BasketIds,string Catalog1,id parentbasket){
        //Call addtobasket synchronously via normal callout
        Map<String, Object> productConfigMap1 = (Map<String, Object>)JSON.deserializeUntyped(productConfigMap);
        Map<String, Object> offerObj1 = new Map<String, Object>();
        String AttributeJSON='';               
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
                                            MCOnline_Utility.logError(offerError, offerErrCode,'MCOnline_AddToBasket_V2','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                                        }
                                    }
                                }
                            }
                            else{
                                stdError = (string)(HA_AddToBasket.get('error'));
                                errorCode = (string)HA_AddToBasket.get('errorCode');
                                if(errorCode =='NOT_FOUND' || errorCode =='BAD_REQUEST'){
                                    stdError = String.valueOf(HA_AddToBasket.get('message'));
                                }
                                else if(stdError!=null && stdError.contains('Invalid Basket Action')){
                                    stdError = 'Invalid Basket Action';
                                }
                                else if(stdError!=null && stdError.contains('Invalid context input')){
                                    stdError = 'Invalid context input';
                                }
                                else{
                                    stdError = (string)HA_AddToBasket.get('error'); 
                                } 
                                outMap.put('ErrorResponse', MCOnline_Utility.generateError(stdError,errorCode,'standard', 'MultiAddToBasketAndCheckOut'));
                                MCOnline_Utility.logError(stdError, errorCode,'MCOnline_AddToBasket_V2','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                                outMap.put('StatusCode', 400);
                            }
                        }
                        else{
                            Map<String, Object> compMsg = new Map<String, Object>();
                            String compItems= '';
                            Map<String, Object> result = (Map<String, Object>)HA_AddToBasket.get('result');
                            List<Object> resultMessage = (List<Object>)result.get('messages');
                            if(resultMessage!=null && !resultMessage.isEmpty()){
                                boolean isErrorCollected = false;
                                for(Object msg:resultMessage){
                                    compMsg = (Map<String, Object>)msg;
                                    if((String.valueOf(compMsg.get('code'))=='208') || (String.valueOf(compMsg.get('code'))=='207')){
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
                                MCOnline_Utility.logError(compItems, errorCode,'MCOnline_AddToBasket_V3','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
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
                            
                            if(childProductResultObj2ndLevel.containskey('AO__c'))
                                productMap2save2ndLevel.put('AO',String.Valueof(childProductResultObj2ndLevel.get('AO__c')));
                            if(childProductResultObj2ndLevel.containskey('TeliaSE_Product_Service_Code__c'))
                                productMap2save2ndLevel.put('TeliaSE_Product_Service_Code',String.Valueof(childProductResultObj2ndLevel.get('TeliaSE_Product_Service_Code__c')));
                            if(childProductResultObj2ndLevel.containskey('Ordering_Flag__c'))
                                productMap2save2ndLevel.put('ordering_Flag',String.Valueof(childProductResultObj2ndLevel.get('Ordering_Flag__c')));
                            if(childProductResultObj2ndLevel.containskey('Ordering_System__c'))
                                productMap2save2ndLevel.put('ordering_System',String.Valueof(childProductResultObj2ndLevel.get('Ordering_System__c')));
                            if(childProductResultObj2ndLevel.containskey('C2BC_Category__c'))
                                productMap2save2ndLevel.put('C2BC_Category',String.Valueof(childProductResultObj2ndLevel.get('C2BC_Category__c')));
                            if(childProductResultObj2ndLevel.containskey('C2BC_Subcategory__c'))
                                productMap2save2ndLevel.put('C2BC_Subcategory',String.Valueof(childProductResultObj2ndLevel.get('C2BC_Subcategory__c')));
                            if(childProductResultObj2ndLevel.containskey('CID__c'))
                                productMap2save2ndLevel.put('CID',String.Valueof(childProductResultObj2ndLevel.get('CID__c')));
                            if(childProductResultObj2ndLevel.containskey('TeliaSE_Product_Category__c'))
                                productMap2save2ndLevel.put('TeliaSE_Product_Category',String.Valueof(childProductResultObj2ndLevel.get('TeliaSE_Product_Category__c')));
                            if(childProductResultObj2ndLevel.containskey('TeliaSE_Subscription_Type__c'))
                                productMap2save2ndLevel.put('TeliaSE_Subscription_Type',String.Valueof(childProductResultObj2ndLevel.get('TeliaSE_Subscription_Type__c')));
                            if(childProductResultObj2ndLevel.containskey('Downstream_CategoryData__c'))
                                productMap2save2ndLevel.put('downstream_CategoryData',String.Valueof(childProductResultObj2ndLevel.get('Downstream_CategoryData__c')));
                            if(childProductResultObj2ndLevel.containskey('lineNumber'))
                                productMap2save2ndLevel.put('lineNumber',String.Valueof(childProductResultObj2ndLevel.get('lineNumber')));
                            if(childProductResultObj2ndLevel.containskey('MConline_Action_Code__c')){
                                if(String.Valueof(childProductResultObj2ndLevel.get('MConline_Action_Code__c'))!=null){
                                    productMap2save2ndLevel.put('actionCode',String.Valueof(childProductResultObj2ndLevel.get('MConline_Action_Code__c')));
                                }
                                else{
                                    productMap2save2ndLevel.put('actionCode','Add');
                                }
                            }
                            if(childProductResultObj2ndLevel.containskey('MC_Product_Name_Eng__c')) 
                                productMap2save2ndLevel.put('englishName',String.Valueof(childProductResultObj2ndLevel.get('MC_Product_Name_Eng__c')));
                            productMap2save2ndLevel.put('name',String.Valueof(childProductResultObj2ndLevel.get('Name')));
                            if(priceResult2ndLevel!=null){
                                Map<String, Object> priceResultMap2ndLevel = new Map<String, Object>();
                                for(Object pricelst2ndLevel:priceResult2ndLevel){
                                    priceResultMap2ndLevel=(Map<String, Object>)pricelst2ndLevel;
                                    if(String.Valueof(priceResultMap2ndLevel.get('ChargeType__c'))=='Recurring'){
                                        if(((productMap2save2ndLevel.get('actionCode'))!=null) && ((string.valueOf(productMap2save2ndLevel.get('actionCode'))).equalsIgnoreCase('delete') || (string.valueOf(productMap2save2ndLevel.get('actionCode'))).equalsIgnoreCase('update')))
                                        {
                                            mrc_price=0;
                                        }
                                        else{
                                            mrc_price=mrc_price + (Decimal)priceResultMap2ndLevel.get('Amount__c');
                                        }
                                        productMap2save2ndLevel.put('chargeAmount',String.Valueof(priceResultMap2ndLevel.get('chargeamount')));
                                        productMap2save2ndLevel.put('baseAmount',String.Valueof(priceResultMap2ndLevel.get('baseamount')));
                                        productMap2save2ndLevel.put('amount',String.Valueof(priceResultMap2ndLevel.get('Amount__c')));
                                        //productMap2save2ndLevel.put('nrc_amount',String.Valueof(priceResultMap2ndLevel.get('NRC_Amount__c')));
                                        productMap2save2ndLevel.put('recurringFrequency',String.Valueof(priceResultMap2ndLevel.get('RecurringFrequency__c')));
                                        productMap2save2ndLevel.put('chargeType',String.Valueof(priceResultMap2ndLevel.get('ChargeType__c')));
                                        productMap2save2ndLevel.put('displayText',String.Valueof(priceResultMap2ndLevel.get('DisplayText__c')));
                                    }
                                    else if(String.Valueof(priceResultMap2ndLevel.get('ChargeType__c'))=='One-time'){
                                        productMap2save2ndLevel.put('chargeAmount',String.Valueof(priceResultMap2ndLevel.get('chargeamount')));
                                        productMap2save2ndLevel.put('baseAmount',String.Valueof(priceResultMap2ndLevel.get('baseamount')));
                                        //productMap2save2ndLevel.put('amount',String.Valueof(priceResultMap2ndLevel.get('Amount__c')));
                                        productMap2save2ndLevel.put('nrc_amount',String.Valueof(priceResultMap2ndLevel.get('Amount__c')));
                                        productMap2save2ndLevel.put('recurringFrequency',String.Valueof(priceResultMap2ndLevel.get('RecurringFrequency__c')));
                                        productMap2save2ndLevel.put('chargeType',String.Valueof(priceResultMap2ndLevel.get('ChargeType__c')));
                                        productMap2save2ndLevel.put('displayText',String.Valueof(priceResultMap2ndLevel.get('DisplayText__c')));  
                                    }
                                }
                            }
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
                                    productAttributeObj12ndLevel.put(String.Valueof(productAttributeObj2ndLevel.get('code')),String.Valueof(productAttributeObj2ndLevel.get('userValues')));
                                }
                                if(productAttributeObj12ndLevel != null){
                                    if(productAttributeObj12ndLevel.containskey('Billing Account Online')) 
                                        attr2ndLevel.put('billingAccountOnline',String.Valueof(productAttributeObj12ndLevel.get('Billing Account Online')));
                                    if(productAttributeObj12ndLevel.containskey('TELIA_COMM_PERIOD')) 
                                        attr2ndLevel.put('commitmentPeriod',String.Valueof(productAttributeObj12ndLevel.get('TELIA_COMM_PERIOD')));
                                    if(productAttributeObj12ndLevel.containskey('e-SIM_Method')) 
                                        attr2ndLevel.put('eSIM_Method',String.Valueof(productAttributeObj12ndLevel.get('e-SIM_Method')));
                                    if(productAttributeObj12ndLevel.containskey('Email')) 
                                        attr2ndLevel.put('email',String.Valueof(productAttributeObj12ndLevel.get('Email')));
                                    if(productAttributeObj12ndLevel.containskey('EXT_REF_ONLINE')) 
                                        attr2ndLevel.put('externalReference',String.Valueof(productAttributeObj12ndLevel.get('EXT_REF_ONLINE')));
                                    if(productAttributeObj12ndLevel.containskey('ICC_number')) 
                                        attr2ndLevel.put('ICCNumber',String.Valueof(productAttributeObj12ndLevel.get('ICC_number')));
                                    if(productAttributeObj12ndLevel.containskey('MSISDN')) 
                                        attr2ndLevel.put('MSISDN',String.Valueof(productAttributeObj12ndLevel.get('MSISDN')));
                                    if(productAttributeObj12ndLevel.containskey('SIM_Format')) 
                                        attr2ndLevel.put('SIM_Format',String.Valueof(productAttributeObj12ndLevel.get('SIM_Format')));
                                    if(productAttributeObj12ndLevel.containskey('User_name')) 
                                        attr2ndLevel.put('userName',String.Valueof(productAttributeObj12ndLevel.get('User_name')));
                                    if(productAttributeObj12ndLevel.containskey('NumberReservationRequired'))
                                        attr2ndLevel.put('NumberReservationRequired',String.Valueof(productAttributeObj12ndLevel.get('NumberReservationRequired')));
                                    /* for hardware products -------------------------------- */
                                    if(productAttributeObj12ndLevel.containskey('ATT_HW_CATEGORY')) 
                                        attr2ndLevel.put('HWItemCategory',String.Valueof(productAttributeObj12ndLevel.get('ATT_HW_CATEGORY')));
                                    if(productAttributeObj12ndLevel.containskey('ATT_HW_COLOR')) 
                                        attr2ndLevel.put('HWItemCnetBrandColor',String.Valueof(productAttributeObj12ndLevel.get('ATT_HW_COLOR')));
                                    if(productAttributeObj12ndLevel.containskey('ATT_HW_MEMORY')) 
                                        attr2ndLevel.put('HWItemCnetMemory',String.Valueof(productAttributeObj12ndLevel.get('ATT_HW_MEMORY')));
                                    if(productAttributeObj12ndLevel.containskey('ATT_HW_PROMISE_ID')) 
                                        attr2ndLevel.put('HWItemPromisID',String.Valueof(productAttributeObj12ndLevel.get('ATT_HW_PROMISE_ID')));
                                    if(productAttributeObj12ndLevel.containskey('ATT_HW_SKU_ID')) 
                                        attr2ndLevel.put('HWItemTeliaSku',String.Valueof(productAttributeObj12ndLevel.get('ATT_HW_SKU_ID')));
                                    if(productAttributeObj12ndLevel.containskey('ATT_HW_BRAND')) 
                                        attr2ndLevel.put('HWProductBrand',String.Valueof(productAttributeObj12ndLevel.get('ATT_HW_BRAND')));
                                    if(productAttributeObj12ndLevel.containskey('ATT_HW_SAP_ID')) 
                                        attr2ndLevel.put('HWSAPID',String.Valueof(productAttributeObj12ndLevel.get('ATT_HW_SAP_ID')));
                                    if(productAttributeObj12ndLevel.containskey('HWUpfrontPayment')) 
                                        attr2ndLevel.put('HWUpfrontPayment',String.Valueof(productAttributeObj12ndLevel.get('HWUpfrontPayment')));    
                                    //For Portin and Transfer Offers
                                    if(productAttributeObj12ndLevel.containskey('Current_MSISDN'))
                                        attr2ndLevel.put('currentMSISDN',String.Valueof(productAttributeObj12ndLevel.get('Current_MSISDN')));
                                    if(productAttributeObj12ndLevel.containskey('Temporary_MSISDN'))
                                        attr2ndLevel.put('temporaryMSISDN',String.Valueof(productAttributeObj12ndLevel.get('Temporary_MSISDN')));
                                    if(productAttributeObj12ndLevel.containskey('Contact_telephone_number'))
                                        attr2ndLevel.put('contactTelephoneNumber',String.Valueof(productAttributeObj12ndLevel.get('Contact_telephone_number')));
                                    if(productAttributeObj12ndLevel.containskey('Current_owner_SSN'))
                                        attr2ndLevel.put('currentOwnerSSN',String.Valueof(productAttributeObj12ndLevel.get('Current_owner_SSN')));
                                    if(productAttributeObj12ndLevel.containskey('Current_owner_Organization'))
                                        attr2ndLevel.put('currentOwnerOrganization',String.Valueof(productAttributeObj12ndLevel.get('Current_owner_Organization')));
                                    if(productAttributeObj12ndLevel.containskey('Current_owner_email'))
                                        attr2ndLevel.put('currentOwnerEmail',String.Valueof(productAttributeObj12ndLevel.get('Current_owner_email')));
                                    if(productAttributeObj12ndLevel.containskey('Current_owner_first_name'))
                                        attr2ndLevel.put('currentOwnerFirstName',String.Valueof(productAttributeObj12ndLevel.get('Current_owner_first_name')));
                                    if(productAttributeObj12ndLevel.containskey('Current_owner_last_name'))
                                        attr2ndLevel.put('currentOwnerLastName',String.Valueof(productAttributeObj12ndLevel.get('Current_owner_last_name')));
                                    if(productAttributeObj12ndLevel.containskey('Portin_date'))
                                        attr2ndLevel.put('portinDate',String.Valueof(productAttributeObj12ndLevel.get('Portin_date')));
                                    if(productAttributeObj12ndLevel.containskey('Document_id'))
                                        attr2ndLevel.put('documentId',String.Valueof(productAttributeObj12ndLevel.get('Document_id')));
                                    if(productAttributeObj12ndLevel.containskey('User_email'))
                                        attr2ndLevel.put('userEmail',String.Valueof(productAttributeObj12ndLevel.get('User_email')));
                                    if(productAttributeObj12ndLevel.containskey('ownerPhoneNumber'))
                                        attr2ndLevel.put('ownerPhoneNumber',String.Valueof(productAttributeObj12ndLevel.get('ownerPhoneNumber'))); 
                                    //For MOB_COSTCONTRL_ABROAD
                                    if(productAttributeObj12ndLevel.containskey('costControlAmount'))
                                        attr2ndLevel.put('costControlAmount',String.Valueof(productAttributeObj12ndLevel.get('costControlAmount')));
                                    //For MOB_INVOICE_SPLIT_A
                                    if(productAttributeObj12ndLevel.containskey('firstName'))
                                        attr2ndLevel.put('firstName',String.Valueof(productAttributeObj12ndLevel.get('firstName')));
                                    if(productAttributeObj12ndLevel.containskey('lastName'))
                                        attr2ndLevel.put('lastName',String.Valueof(productAttributeObj12ndLevel.get('lastName')));
                                    if(productAttributeObj12ndLevel.containskey('street'))
                                        attr2ndLevel.put('street',String.Valueof(productAttributeObj12ndLevel.get('street')));
                                    if(productAttributeObj12ndLevel.containskey('streetNumber'))
                                        attr2ndLevel.put('streetNumber',String.Valueof(productAttributeObj12ndLevel.get('streetNumber')));
                                    if(productAttributeObj12ndLevel.containskey('postalCode'))
                                        attr2ndLevel.put('postalCode',String.Valueof(productAttributeObj12ndLevel.get('postalCode')));
                                    if(productAttributeObj12ndLevel.containskey('city'))
                                        attr2ndLevel.put('city',String.Valueof(productAttributeObj12ndLevel.get('city')));
                                    if(productAttributeObj12ndLevel.containskey('country'))
                                        attr2ndLevel.put('country',String.Valueof(productAttributeObj12ndLevel.get('country')));
                                    if(productAttributeObj12ndLevel.containskey('pointid'))
                                        attr2ndLevel.put('pointid',String.Valueof(productAttributeObj12ndLevel.get('pointid')));
                                    if(productAttributeObj12ndLevel.containskey('entrance'))
                                        attr2ndLevel.put('entrance',String.Valueof(productAttributeObj12ndLevel.get('entrance')));
                                    if(productAttributeObj12ndLevel.containskey('appartmentNumber'))
                                        attr2ndLevel.put('appartmentNumber',String.Valueof(productAttributeObj12ndLevel.get('appartmentNumber')));
                                    if(productAttributeObj12ndLevel.containskey('careOf'))
                                        attr2ndLevel.put('careOf',String.Valueof(productAttributeObj12ndLevel.get('careOf')));
                                    //-----------------for touchpoint products------------------------------
                                    if(productAttributeObj12ndLevel.containskey('Användarnamn'))
                                        attr2ndLevel.put('Användarnamn',String.Valueof(productAttributeObj12ndLevel.get('Användarnamn')));
                                    if(productAttributeObj12ndLevel.containskey('agentList1_cdgAgentLoggedIn'))
                                        attr2ndLevel.put('agentList1_cdgAgentLoggedIn',String.Valueof(productAttributeObj12ndLevel.get('agentList1_cdgAgentLoggedIn')));
                                    if(productAttributeObj12ndLevel.containskey('agentList1_cdgIdentifyingNumber'))
                                        attr2ndLevel.put('agentList1_cdgIdentifyingNumber',String.Valueof(productAttributeObj12ndLevel.get('agentList1_cdgIdentifyingNumber')));
                                    if(productAttributeObj12ndLevel.containskey('agentList2_cdgAgentLoggedIn'))
                                        attr2ndLevel.put('agentList2_cdgAgentLoggedIn',String.Valueof(productAttributeObj12ndLevel.get('agentList2_cdgAgentLoggedIn')));
                                    if(productAttributeObj12ndLevel.containskey('agentList2_cdgIdentifyingNumber'))
                                        attr2ndLevel.put('agentList2_cdgIdentifyingNumber',String.Valueof(productAttributeObj12ndLevel.get('agentList2_cdgIdentifyingNumber')));
                                    if(productAttributeObj12ndLevel.containskey('agentList3_cdgAgentLoggedIn'))
                                        attr2ndLevel.put('agentList3_cdgAgentLoggedIn',String.Valueof(productAttributeObj12ndLevel.get('agentList3_cdgAgentLoggedIn')));
                                    if(productAttributeObj12ndLevel.containskey('agentList3_cdgIdentifyingNumber'))
                                        attr2ndLevel.put('agentList3_cdgIdentifyingNumber',String.Valueof(productAttributeObj12ndLevel.get('agentList3_cdgIdentifyingNumber')));
                                    if(productAttributeObj12ndLevel.containskey('callingLineType'))
                                        attr2ndLevel.put('callingLineType',String.Valueof(productAttributeObj12ndLevel.get('callingLineType')));
                                    if(productAttributeObj12ndLevel.containskey('instanceId'))
                                        attr2ndLevel.put('instanceId',String.Valueof(productAttributeObj12ndLevel.get('instanceId')));
                                    if(productAttributeObj12ndLevel.containskey('roleCompanyAdmin'))
                                        attr2ndLevel.put('roleCompanyAdmin',String.Valueof(productAttributeObj12ndLevel.get('roleCompanyAdmin')));
                                    if(productAttributeObj12ndLevel.containskey('roleUser'))
                                        attr2ndLevel.put('roleUser',String.Valueof(productAttributeObj12ndLevel.get('roleUser')));
                                    if(productAttributeObj12ndLevel.containskey('fixedPhoneNumber'))
                                        attr2ndLevel.put('fixedPhoneNumber',String.Valueof(productAttributeObj12ndLevel.get('fixedPhoneNumber')));
                                }
                                productMap2save2ndLevel.put('attributes',attr2ndLevel);                      
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
                                    
                                    if(childProductResultObj.containskey('AO__c'))
                                        productMap2save.put('AO',String.Valueof(childProductResultObj.get('AO__c')));
                                    if(childProductResultObj.containskey('TeliaSE_Product_Service_Code__c'))
                                        productMap2save.put('TeliaSE_Product_Service_Code',String.Valueof(childProductResultObj.get('TeliaSE_Product_Service_Code__c')));
                                    if(childProductResultObj.containskey('Ordering_Flag__c'))
                                        productMap2save.put('ordering_Flag',String.Valueof(childProductResultObj.get('Ordering_Flag__c')));
                                    if(childProductResultObj.containskey('Ordering_System__c'))
                                        productMap2save.put('ordering_System',String.Valueof(childProductResultObj.get('Ordering_System__c')));
                                    if(childProductResultObj.containskey('C2BC_Category__c'))
                                        productMap2save.put('C2BC_Category',String.Valueof(childProductResultObj.get('C2BC_Category__c')));
                                    if(childProductResultObj.containskey('C2BC_Subcategory__c'))
                                        productMap2save.put('C2BC_Subcategory',String.Valueof(childProductResultObj.get('C2BC_Subcategory__c')));
                                    if(childProductResultObj.containskey('CID__c'))
                                        productMap2save.put('CID',String.Valueof(childProductResultObj.get('CID__c')));
                                    if(childProductResultObj.containskey('TeliaSE_Product_Category__c'))
                                        productMap2save.put('TeliaSE_Product_Category',String.Valueof(childProductResultObj.get('TeliaSE_Product_Category__c')));
                                    if(childProductResultObj.containskey('TeliaSE_Subscription_Type__c'))
                                        productMap2save.put('TeliaSE_Subscription_Type',String.Valueof(childProductResultObj.get('TeliaSE_Subscription_Type__c')));
                                    if(childProductResultObj.containskey('Downstream_CategoryData__c'))
                                        productMap2save.put('downstream_CategoryData',String.Valueof(childProductResultObj.get('Downstream_CategoryData__c')));
                                    if(childProductResultObj.containskey('lineNumber'))
                                        productMap2save.put('lineNumber',String.Valueof(childProductResultObj.get('lineNumber')));
                                    if(childProductResultObj.containskey('MConline_Action_Code__c')){
                                        if(String.Valueof(childProductResultObj.get('MConline_Action_Code__c'))!=null){
                                            productMap2save.put('actionCode',String.Valueof(childProductResultObj.get('MConline_Action_Code__c')));
                                        }
                                        else{
                                            productMap2save.put('actionCode','Add');
                                        }
                                    }
                                    if(childProductResultObj.containskey('MC_Product_Name_Eng__c'))
                                        productMap2save.put('englishName',String.Valueof(childProductResultObj.get('MC_Product_Name_Eng__c')));
                                    productMap2save.put('name',String.Valueof(childProductResultObj.get('Name')));
                                    if(priceResult!=null){
                                        Map<String, Object> priceResultMap = new Map<String, Object>();
                                        //negotiatedPrice=negotiatedPrice + (Decimal)priceResultMap.get('Amount__c');
                                        for(Object pricelst:priceResult){
                                            priceResultMap=(Map<String, Object>)pricelst ; 
                                            if(String.Valueof(priceResultMap.get('ChargeType__c'))=='Recurring'){
                                                if(((productMap2save.get('actionCode'))!=null)&&((string.valueOf(productMap2save.get('actionCode'))).equalsIgnoreCase('delete') || (string.valueOf(productMap2save.get('actionCode'))).equalsIgnoreCase('update')))
                                                {
                                                    mrc_price=0;
                                                }
                                                else{
                                                    mrc_price=mrc_price + (Decimal)priceResultMap.get('Amount__c');
                                                }
                                                productMap2save.put('chargeAmount',String.Valueof(priceResultMap.get('chargeamount')));
                                                productMap2save.put('baseAmount',String.Valueof(priceResultMap.get('baseamount')));
                                                productMap2save.put('amount',String.Valueof(priceResultMap.get('Amount__c')));
                                                //productMap2save.put('nrc_amount',String.Valueof(priceResultMap.get('NRC_Amount__c')));
                                                productMap2save.put('recurringFrequency',String.Valueof(priceResultMap.get('RecurringFrequency__c')));
                                                productMap2save.put('chargeType',String.Valueof(priceResultMap.get('ChargeType__c')));
                                                productMap2save.put('displayText',String.Valueof(priceResultMap.get('DisplayText__c')));
                                            }
                                            else if(String.Valueof(priceResultMap.get('ChargeType__c'))=='One-time'){
                                                nrc_price=nrc_price + (Decimal)priceResultMap.get('Amount__c');
                                                productMap2save.put('nrc_amount',String.Valueof(priceResultMap.get('Amount__c')));   
                                            }  
                                        }
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
                                            productAttributeObj1.put(String.Valueof(productAttributeObj.get('code')),String.Valueof(productAttributeObj.get('userValues')));
                                        }
                                        if(productAttributeObj1 != null){
                                            if(productAttributeObj1.containskey('Billing Account Online')) 
                                                attr.put('billingAccountOnline',String.Valueof(productAttributeObj1.get('Billing Account Online')));
                                            if(productAttributeObj1.containskey('TELIA_COMM_PERIOD')) 
                                                attr.put('commitmentPeriod',String.Valueof(productAttributeObj1.get('TELIA_COMM_PERIOD')));
                                            if(productAttributeObj1.containskey('e-SIM_Method')) 
                                                attr.put('eSIM_Method',String.Valueof(productAttributeObj1.get('e-SIM_Method')));
                                            if(productAttributeObj1.containskey('Email')) 
                                                attr.put('email',String.Valueof(productAttributeObj1.get('Email')));
                                            if(productAttributeObj1.containskey('EXT_REF_ONLINE')) 
                                                attr.put('externalReference',String.Valueof(productAttributeObj1.get('EXT_REF_ONLINE')));
                                            if(productAttributeObj1.containskey('ICC_number')) 
                                                attr.put('ICCNumber',String.Valueof(productAttributeObj1.get('ICC_number')));
                                            if(productAttributeObj1.containskey('MSISDN')) 
                                                attr.put('MSISDN',String.Valueof(productAttributeObj1.get('MSISDN')));
                                            if(productAttributeObj1.containskey('SIM_Format')) 
                                                attr.put('SIM_Format',String.Valueof(productAttributeObj1.get('SIM_Format')));
                                            if(productAttributeObj1.containskey('User_name')) 
                                                attr.put('userName',String.Valueof(productAttributeObj1.get('User_name')));
                                            if(productAttributeObj1.containskey('NumberReservationRequired'))
                                                attr.put('NumberReservationRequired',String.Valueof(productAttributeObj1.get('NumberReservationRequired')));
                                            /* for hardware products -------------------------------- */
                                            if(productAttributeObj1.containskey('ATT_HW_CATEGORY')) 
                                                attr.put('HWItemCategory',String.Valueof(productAttributeObj1.get('ATT_HW_CATEGORY')));
                                            if(productAttributeObj1.containskey('ATT_HW_COLOR')) 
                                                attr.put('HWItemCnetBrandColor',String.Valueof(productAttributeObj1.get('ATT_HW_COLOR')));
                                            if(productAttributeObj1.containskey('ATT_HW_MEMORY')) 
                                                attr.put('HWItemCnetMemory',String.Valueof(productAttributeObj1.get('ATT_HW_MEMORY')));
                                            if(productAttributeObj1.containskey('ATT_HW_PROMISE_ID')) 
                                                attr.put('HWItemPromisID',String.Valueof(productAttributeObj1.get('ATT_HW_PROMISE_ID')));
                                            if(productAttributeObj1.containskey('ATT_HW_SKU_ID')) 
                                                attr.put('HWItemTeliaSku',String.Valueof(productAttributeObj1.get('ATT_HW_SKU_ID')));
                                            if(productAttributeObj1.containskey('ATT_HW_BRAND')) 
                                                attr.put('HWProductBrand',String.Valueof(productAttributeObj1.get('ATT_HW_BRAND')));
                                            if(productAttributeObj1.containskey('ATT_HW_SAP_ID')) 
                                                attr.put('HWSAPID',String.Valueof(productAttributeObj1.get('ATT_HW_SAP_ID')));
                                            if(productAttributeObj1.containskey('HWUpfrontPayment')) 
                                                attr.put('HWUpfrontPayment',String.Valueof(productAttributeObj1.get('HWUpfrontPayment')));    
                                            //For Portin and Transfer Offers
                                            if(productAttributeObj1.containskey('Current_MSISDN'))
                                                attr.put('currentMSISDN',String.Valueof(productAttributeObj1.get('Current_MSISDN')));
                                            if(productAttributeObj1.containskey('Temporary_MSISDN'))
                                                attr.put('temporaryMSISDN',String.Valueof(productAttributeObj1.get('Temporary_MSISDN')));
                                            if(productAttributeObj1.containskey('Contact_telephone_number'))
                                                attr.put('contactTelephoneNumber',String.Valueof(productAttributeObj1.get('Contact_telephone_number')));
                                            if(productAttributeObj1.containskey('Current_owner_SSN'))
                                                attr.put('currentOwnerSSN',String.Valueof(productAttributeObj1.get('Current_owner_SSN')));
                                            if(productAttributeObj1.containskey('Current_owner_Organization'))
                                                attr.put('currentOwnerOrganization',String.Valueof(productAttributeObj1.get('Current_owner_Organization')));
                                            if(productAttributeObj1.containskey('Current_owner_email'))
                                                attr.put('currentOwnerEmail',String.Valueof(productAttributeObj1.get('Current_owner_email')));
                                            if(productAttributeObj1.containskey('Current_owner_first_name'))
                                                attr.put('currentOwnerFirstName',String.Valueof(productAttributeObj1.get('Current_owner_first_name')));
                                            if(productAttributeObj1.containskey('Current_owner_last_name'))
                                                attr.put('currentOwnerLastName',String.Valueof(productAttributeObj1.get('Current_owner_last_name')));
                                            if(productAttributeObj1.containskey('Portin_date'))
                                                attr.put('portinDate',String.Valueof(productAttributeObj1.get('Portin_date')));
                                            if(productAttributeObj1.containskey('Document_id'))
                                                attr.put('documentId',String.Valueof(productAttributeObj1.get('Document_id')));
                                            if(productAttributeObj1.containskey('User_email'))
                                                attr.put('userEmail',String.Valueof(productAttributeObj1.get('User_email')));
                                            if(productAttributeObj1.containskey('ownerPhoneNumber'))
                                                attr.put('ownerPhoneNumber',String.Valueof(productAttributeObj1.get('ownerPhoneNumber'))); 
                                            //For MOB_COSTCONTRL_ABROAD
                                            if(productAttributeObj1.containskey('costControlAmount'))
                                                attr.put('costControlAmount',String.Valueof(productAttributeObj1.get('costControlAmount')));
                                            //For MOB_INVOICE_SPLIT_A
                                            if(productAttributeObj1.containskey('firstName'))
                                                attr.put('firstName',String.Valueof(productAttributeObj1.get('firstName')));
                                            if(productAttributeObj1.containskey('lastName'))
                                                attr.put('lastName',String.Valueof(productAttributeObj1.get('lastName')));
                                            if(productAttributeObj1.containskey('street'))
                                                attr.put('street',String.Valueof(productAttributeObj1.get('street')));
                                            if(productAttributeObj1.containskey('streetNumber'))
                                                attr.put('streetNumber',String.Valueof(productAttributeObj1.get('streetNumber')));
                                            if(productAttributeObj1.containskey('postalCode'))
                                                attr.put('postalCode',String.Valueof(productAttributeObj1.get('postalCode')));
                                            if(productAttributeObj1.containskey('city'))
                                                attr.put('city',String.Valueof(productAttributeObj1.get('city')));
                                            if(productAttributeObj1.containskey('country'))
                                                attr.put('country',String.Valueof(productAttributeObj1.get('country')));
                                            if(productAttributeObj1.containskey('pointid'))
                                                attr.put('pointid',String.Valueof(productAttributeObj1.get('pointid')));
                                            if(productAttributeObj1.containskey('entrance'))
                                                attr.put('entrance',String.Valueof(productAttributeObj1.get('entrance')));
                                            if(productAttributeObj1.containskey('appartmentNumber'))
                                                attr.put('appartmentNumber',String.Valueof(productAttributeObj1.get('appartmentNumber')));
                                            if(productAttributeObj1.containskey('careOf'))
                                                attr.put('careOf',String.Valueof(productAttributeObj1.get('careOf')));
                                            //-----------------for touchpoint products------------------------------
                                            if(productAttributeObj1.containskey('Användarnamn'))
                                                attr.put('Användarnamn',String.Valueof(productAttributeObj1.get('Användarnamn')));
                                            if(productAttributeObj1.containskey('agentList1_cdgAgentLoggedIn'))
                                                attr.put('agentList1_cdgAgentLoggedIn',String.Valueof(productAttributeObj1.get('agentList1_cdgAgentLoggedIn')));
                                            if(productAttributeObj1.containskey('agentList1_cdgIdentifyingNumber'))
                                                attr.put('agentList1_cdgIdentifyingNumber',String.Valueof(productAttributeObj1.get('agentList1_cdgIdentifyingNumber')));
                                            if(productAttributeObj1.containskey('agentList2_cdgAgentLoggedIn'))
                                                attr.put('agentList2_cdgAgentLoggedIn',String.Valueof(productAttributeObj1.get('agentList2_cdgAgentLoggedIn')));
                                            if(productAttributeObj1.containskey('agentList2_cdgIdentifyingNumber'))
                                                attr.put('agentList2_cdgIdentifyingNumber',String.Valueof(productAttributeObj1.get('agentList2_cdgIdentifyingNumber')));
                                            if(productAttributeObj1.containskey('agentList3_cdgAgentLoggedIn'))
                                                attr.put('agentList3_cdgAgentLoggedIn',String.Valueof(productAttributeObj1.get('agentList3_cdgAgentLoggedIn')));
                                            if(productAttributeObj1.containskey('agentList3_cdgIdentifyingNumber'))
                                                attr.put('agentList3_cdgIdentifyingNumber',String.Valueof(productAttributeObj1.get('agentList3_cdgIdentifyingNumber')));
                                            if(productAttributeObj1.containskey('callingLineType'))
                                                attr.put('callingLineType',String.Valueof(productAttributeObj1.get('callingLineType')));
                                            if(productAttributeObj1.containskey('instanceId'))
                                                attr.put('instanceId',String.Valueof(productAttributeObj1.get('instanceId')));
                                            if(productAttributeObj1.containskey('roleCompanyAdmin'))
                                                attr.put('roleCompanyAdmin',String.Valueof(productAttributeObj1.get('roleCompanyAdmin')));
                                            if(productAttributeObj1.containskey('roleUser'))
                                                attr.put('roleUser',String.Valueof(productAttributeObj1.get('roleUser')));
                                            if(productAttributeObj1.containskey('fixedPhoneNumber'))
                                                attr.put('fixedPhoneNumber',String.Valueof(productAttributeObj1.get('fixedPhoneNumber')));
                                        }
                                        productMap2save.put('attributes',attr);
                                        
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
                                                
                                                if(childProductResultObj4thlevel.containskey('AO__c'))
                                                    productMap2save4thlevel.put('AO',String.Valueof(childProductResultObj4thlevel.get('AO__c')));
                                                if(childProductResultObj4thlevel.containskey('TeliaSE_Product_Service_Code__c'))
                                                    productMap2save4thlevel.put('TeliaSE_Product_Service_Code',String.Valueof(childProductResultObj4thlevel.get('TeliaSE_Product_Service_Code__c')));
                                                if(childProductResultObj4thlevel.containskey('Ordering_Flag__c'))
                                                    productMap2save4thlevel.put('ordering_Flag',String.Valueof(childProductResultObj4thlevel.get('Ordering_Flag__c')));
                                                if(childProductResultObj4thlevel.containskey('Ordering_System__c'))
                                                    productMap2save4thlevel.put('ordering_System',String.Valueof(childProductResultObj4thlevel.get('Ordering_System__c')));
                                                if(childProductResultObj4thlevel.containskey('C2BC_Category__c'))
                                                    productMap2save4thlevel.put('C2BC_Category',String.Valueof(childProductResultObj4thlevel.get('C2BC_Category__c')));
                                                if(childProductResultObj4thlevel.containskey('C2BC_Subcategory__c'))
                                                    productMap2save4thlevel.put('C2BC_Subcategory',String.Valueof(childProductResultObj4thlevel.get('C2BC_Subcategory__c')));
                                                if(childProductResultObj4thlevel.containskey('CID__c'))
                                                    productMap2save4thlevel.put('CID',String.Valueof(childProductResultObj4thlevel.get('CID__c')));
                                                if(childProductResultObj4thlevel.containskey('TeliaSE_Product_Category__c'))
                                                    productMap2save4thlevel.put('TeliaSE_Product_Category',String.Valueof(childProductResultObj4thlevel.get('TeliaSE_Product_Category__c')));
                                                if(childProductResultObj4thlevel.containskey('TeliaSE_Subscription_Type__c'))
                                                    productMap2save4thlevel.put('TeliaSE_Subscription_Type',String.Valueof(childProductResultObj4thlevel.get('TeliaSE_Subscription_Type__c')));
                                                if(childProductResultObj4thlevel.containskey('Downstream_CategoryData__c'))
                                                    productMap2save4thlevel.put('downstream_CategoryData',String.Valueof(childProductResultObj4thlevel.get('Downstream_CategoryData__c')));
                                                if(childProductResultObj4thlevel.containskey('lineNumber'))
                                                    productMap2save4thlevel.put('lineNumber',String.Valueof(childProductResultObj4thlevel.get('lineNumber')));
                                                if(childProductResultObj4thlevel.containskey('MC_Product_Name_Eng__c')) 
                                                    productMap2save4thlevel.put('englishName',String.Valueof(childProductResultObj4thlevel.get('MC_Product_Name_Eng__c')));
                                                productMap2save4thlevel.put('name',String.Valueof(childProductResultObj4thlevel.get('Name')));
                                                if(childProductResultObj4thlevel.containskey('MConline_Action_Code__c')){
                                                    if(String.Valueof(childProductResultObj4thlevel.get('MConline_Action_Code__c'))!=null){
                                                        productMap2save4thlevel.put('actionCode',String.Valueof(childProductResultObj4thlevel.get('MConline_Action_Code__c')));
                                                    }
                                                    else{
                                                        productMap2save4thlevel.put('actionCode','Add');
                                                    }
                                                }
                                                if(priceResult4thlevel!=null && priceResult4thlevel.size()>0){
                                                    Map<String, Object> priceResultMap4thlevel = new Map<String, Object>();
                                                    //priceResultMap4thlevel=(Map<String, Object>)priceResult4thlevel[0] ;  
                                                    //negotiatedPrice=negotiatedPrice + (Decimal)priceResultMap4thlevel.get('Amount__c');
                                                    for(Object pricelst:priceResult4thlevel){
                                                        priceResultMap4thlevel=(Map<String, Object>)pricelst ; 
                                                        if(String.Valueof(priceResultMap4thlevel.get('ChargeType__c'))=='Recurring'){
                                                            if(((productMap2save4thlevel.get('actionCode'))!=null)&&((string.valueOf(productMap2save4thlevel.get('actionCode'))).equalsIgnoreCase('delete') || (string.valueOf(productMap2save4thlevel.get('actionCode'))).equalsIgnoreCase('update')))
                                                            {
                                                                mrc_price=0;
                                                            }
                                                            else{
                                                                mrc_price=mrc_price + (Decimal)priceResultMap4thlevel.get('Amount__c');
                                                            }
                                                            productMap2save4thlevel.put('chargeAmount',String.Valueof(priceResultMap4thlevel.get('chargeamount')));
                                                            productMap2save4thlevel.put('baseAmount',String.Valueof(priceResultMap4thlevel.get('baseamount')));
                                                            productMap2save4thlevel.put('amount',String.Valueof(priceResultMap4thlevel.get('Amount__c')));
                                                            productMap2save4thlevel.put('recurringFrequency',String.Valueof(priceResultMap4thlevel.get('RecurringFrequency__c')));
                                                            productMap2save4thlevel.put('chargeType',String.Valueof(priceResultMap4thlevel.get('ChargeType__c')));
                                                            productMap2save4thlevel.put('displayText',String.Valueof(priceResultMap4thlevel.get('DisplayText__c')));
                                                        }
                                                        else if(String.Valueof(priceResultMap4thlevel.get('ChargeType__c'))=='One-time'){
                                                            productMap2save4thlevel.put('nrc_amount',String.Valueof(priceResultMap4thlevel.get('Amount__c')));
                                                            nrc_price=nrc_price + (Decimal)priceResultMap4thlevel.get('Amount__c');
                                                            //Temporary Solution For list Price
                                                            //productMap2save4thlevel.put('baseAmount',String.Valueof(priceResultMap4thlevel.get('baseamount')));
                                                        }
                                                    }
                                                }
                                                if(childProductResultObj4thlevel.containskey('AttributeCategory'))
                                                    attributeCategoryMap4thlevel=(Map<String, Object>)childProductResultObj4thlevel.get('AttributeCategory');
                                                if(attributeCategoryMap4thlevel!=null && attributeCategoryMap4thlevel.size()>0 && attributeCategoryMap4thlevel.containskey('records')){
                                                    attributeCategoryRecordslst4thlevel=(List<Object>)attributeCategoryMap4thlevel.get('records');
                                                    productAttributesMap4thlevel=(Map<String, Object>)attributeCategoryRecordslst4thlevel[0];
                                                    productAttributesrecordsMap4thlevel=(Map<String, Object>)productAttributesMap4thlevel.get('productAttributes');
                                                    productAttributesrecordslst4thlevel=(List<Object>)productAttributesrecordsMap4thlevel.get('records');
                                                    Map<String, Object> attr1 = new Map<String, Object> ();
                                                    for(Object prodattrobj4thlevel: productAttributesrecordslst4thlevel){
                                                        Map<String, Object> productAttributeObj4thlevel = (Map<String, Object>)prodattrobj4thlevel;
                                                        if(productAttributeObj4thlevel.containskey('Billing Account Online')) 
                                                            attr1.put('billingAccountOnline',String.Valueof(productAttributeObj4thlevel.get('Billing Account Online')));
                                                        if(productAttributeObj4thlevel.containskey('TELIA_COMM_PERIOD')) 
                                                            attr1.put('commitmentPeriod',String.Valueof(productAttributeObj4thlevel.get('TELIA_COMM_PERIOD')));
                                                        if(productAttributeObj4thlevel.containskey('e-SIM_Method')) 
                                                            attr1.put('eSIM_Method',String.Valueof(productAttributeObj4thlevel.get('e-SIM_Method')));
                                                        if(productAttributeObj4thlevel.containskey('Email')) 
                                                            attr1.put('email',String.Valueof(productAttributeObj4thlevel.get('Email')));
                                                        if(productAttributeObj4thlevel.containskey('EXT_REF_ONLINE')) 
                                                            attr1.put('externalReference',String.Valueof(productAttributeObj4thlevel.get('EXT_REF_ONLINE')));
                                                        if(productAttributeObj4thlevel.containskey('ICC_number')) 
                                                            attr1.put('ICCNumber',String.Valueof(productAttributeObj4thlevel.get('ICC_number')));
                                                        if(productAttributeObj4thlevel.containskey('MSISDN')) 
                                                            attr1.put('MSISDN',String.Valueof(productAttributeObj4thlevel.get('MSISDN')));
                                                        if(productAttributeObj4thlevel.containskey('SIM_Format')) 
                                                            attr1.put('SIM_Format',String.Valueof(productAttributeObj4thlevel.get('SIM_Format')));
                                                        if(productAttributeObj4thlevel.containskey('User_name')) 
                                                            attr1.put('userName',String.Valueof(productAttributeObj4thlevel.get('User_name')));
                                                        if(productAttributeObj4thlevel.containskey('NumberReservationRequired'))
                                                            attr1.put('NumberReservationRequired',String.Valueof(productAttributeObj4thlevel.get('NumberReservationRequired')));
                                                        /* for hardware products -------------------------------- */
                                                        if(productAttributeObj4thlevel.containskey('ATT_HW_CATEGORY')) 
                                                            attr1.put('HWItemCategory',String.Valueof(productAttributeObj4thlevel.get('ATT_HW_CATEGORY')));
                                                        if(productAttributeObj4thlevel.containskey('ATT_HW_COLOR')) 
                                                            attr1.put('HWItemCnetBrandColor',String.Valueof(productAttributeObj4thlevel.get('ATT_HW_COLOR')));
                                                        if(productAttributeObj4thlevel.containskey('ATT_HW_MEMORY')) 
                                                            attr1.put('HWItemCnetMemory',String.Valueof(productAttributeObj4thlevel.get('ATT_HW_MEMORY')));
                                                        if(productAttributeObj4thlevel.containskey('ATT_HW_PROMISE_ID')) 
                                                            attr1.put('HWItemPromisID',String.Valueof(productAttributeObj4thlevel.get('ATT_HW_PROMISE_ID')));
                                                        if(productAttributeObj4thlevel.containskey('ATT_HW_SKU_ID')) 
                                                            attr1.put('HWItemTeliaSku',String.Valueof(productAttributeObj4thlevel.get('ATT_HW_SKU_ID')));
                                                        if(productAttributeObj4thlevel.containskey('ATT_HW_BRAND')) 
                                                            attr1.put('HWProductBrand',String.Valueof(productAttributeObj4thlevel.get('ATT_HW_BRAND')));
                                                        if(productAttributeObj4thlevel.containskey('ATT_HW_SAP_ID')) 
                                                            attr1.put('HWSAPID',String.Valueof(productAttributeObj4thlevel.get('ATT_HW_SAP_ID')));
                                                        if(productAttributeObj4thlevel.containskey('HWUpfrontPayment'))     
                                                            attr1.put('HWUpfrontPayment',String.Valueof(productAttributeObj4thlevel.get('HWUpfrontPayment')));
                                                        
                                                        /*labelVsUservalues4thlevel.put(String.Valueof(productAttributeObj4thlevel.get('label')),String.Valueof(productAttributeObj4thlevel.get('userValues')));
productAttributeObj4thlevel.put('userValues', null);*/ 
                                                        //For MOB_COSTCONTRL_ABROAD
                                                        if(productAttributeObj4thlevel.containskey('costControlAmount'))     
                                                            attr1.put('costControlAmount',String.Valueof(productAttributeObj4thlevel.get('costControlAmount')));
                                                        //For MOB_INVOICE_SPLIT_A
                                                        if(productAttributeObj4thlevel.containskey('firstName'))     
                                                            attr1.put('firstName',String.Valueof(productAttributeObj4thlevel.get('firstName')));
                                                        if(productAttributeObj4thlevel.containskey('lastName'))     
                                                            attr1.put('lastName',String.Valueof(productAttributeObj4thlevel.get('lastName')));
                                                        if(productAttributeObj4thlevel.containskey('street'))     
                                                            attr1.put('street',String.Valueof(productAttributeObj4thlevel.get('street')));
                                                        if(productAttributeObj4thlevel.containskey('streetNumber'))     
                                                            attr1.put('streetNumber',String.Valueof(productAttributeObj4thlevel.get('streetNumber')));
                                                        if(productAttributeObj4thlevel.containskey('postalCode'))     
                                                            attr1.put('postalCode',String.Valueof(productAttributeObj4thlevel.get('postalCode')));
                                                        if(productAttributeObj4thlevel.containskey('city'))     
                                                            attr1.put('city',String.Valueof(productAttributeObj4thlevel.get('city')));
                                                        if(productAttributeObj4thlevel.containskey('country'))     
                                                            attr1.put('country',String.Valueof(productAttributeObj4thlevel.get('country')));
                                                        if(productAttributeObj4thlevel.containskey('pointid'))     
                                                            attr1.put('pointid',String.Valueof(productAttributeObj4thlevel.get('pointid')));
                                                        if(productAttributeObj4thlevel.containskey('entrance'))     
                                                            attr1.put('entrance',String.Valueof(productAttributeObj4thlevel.get('entrance')));
                                                        if(productAttributeObj4thlevel.containskey('appartmentNumber'))     
                                                            attr1.put('appartmentNumber',String.Valueof(productAttributeObj4thlevel.get('appartmentNumber')));
                                                        if(productAttributeObj4thlevel.containskey('careOf'))     
                                                            attr1.put('careOf',String.Valueof(productAttributeObj4thlevel.get('careOf')));
                                                        //-----------------for touchpoint products------------------------------
                                                        if(productAttributeObj4thlevel.containskey('Användarnamn'))
                                                            attr1.put('Användarnamn',String.Valueof(productAttributeObj4thlevel.get('Användarnamn')));
                                                        if(productAttributeObj4thlevel.containskey('agentList1_cdgAgentLoggedIn'))
                                                            attr1.put('agentList1_cdgAgentLoggedIn',String.Valueof(productAttributeObj4thlevel.get('agentList1_cdgAgentLoggedIn')));
                                                        if(productAttributeObj4thlevel.containskey('agentList1_cdgIdentifyingNumber'))
                                                            attr1.put('agentList1_cdgIdentifyingNumber',String.Valueof(productAttributeObj4thlevel.get('agentList1_cdgIdentifyingNumber')));
                                                        if(productAttributeObj4thlevel.containskey('agentList2_cdgAgentLoggedIn'))
                                                            attr1.put('agentList2_cdgAgentLoggedIn',String.Valueof(productAttributeObj4thlevel.get('agentList2_cdgAgentLoggedIn')));
                                                        if(productAttributeObj4thlevel.containskey('agentList2_cdgIdentifyingNumber'))
                                                            attr1.put('agentList2_cdgIdentifyingNumber',String.Valueof(productAttributeObj4thlevel.get('agentList2_cdgIdentifyingNumber')));
                                                        if(productAttributeObj4thlevel.containskey('agentList3_cdgAgentLoggedIn'))
                                                            attr1.put('agentList3_cdgAgentLoggedIn',String.Valueof(productAttributeObj4thlevel.get('agentList3_cdgAgentLoggedIn')));
                                                        if(productAttributeObj4thlevel.containskey('agentList3_cdgIdentifyingNumber'))
                                                            attr1.put('agentList3_cdgIdentifyingNumber',String.Valueof(productAttributeObj4thlevel.get('agentList3_cdgIdentifyingNumber')));
                                                        if(productAttributeObj4thlevel.containskey('callingLineType'))
                                                            attr1.put('callingLineType',String.Valueof(productAttributeObj4thlevel.get('callingLineType')));
                                                        if(productAttributeObj4thlevel.containskey('instanceId'))
                                                            attr1.put('instanceId',String.Valueof(productAttributeObj4thlevel.get('instanceId')));
                                                        if(productAttributeObj4thlevel.containskey('roleCompanyAdmin'))
                                                            attr1.put('roleCompanyAdmin',String.Valueof(productAttributeObj4thlevel.get('roleCompanyAdmin')));
                                                        if(productAttributeObj4thlevel.containskey('roleUser'))
                                                            attr1.put('roleUser',String.Valueof(productAttributeObj4thlevel.get('roleUser')));
                                                        if(productAttributeObj4thlevel.containskey('fixedPhoneNumber'))
                                                            attr1.put('fixedPhoneNumber',String.Valueof(productAttributeObj4thlevel.get('fixedPhoneNumber')));
                                                        
                                                    }
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
                    AttributeJSON=JSON.serialize(rootproductMap2save) ;
                }
                //==================parse json============================//
                
                Accountid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Accountid'));
                //Id accId = [select id from Account where id=: Accountid LIMIT 1 FOR UPDATE]?.id;
                tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
                admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
                Agreementid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
                List<MCOnline_ParentBasket__c> parentbas=new List<MCOnline_ParentBasket__c>();
                parentbas=[SELECT id,name,OrderNumber__c FROM MCOnline_ParentBasket__c WHERE AgreementId__c=:Agreementid AND TSCID__c=:tscid AND Admin__c=:admin AND Is_Processed__c =false AND flow__c='MANAGEFLOW' order by createddate desc limit 1];
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
                    parentbasket=pbas.id;
                    orderNumber=pbas.OrderNumber__c;
                }
                if((addtobasketResponse!=null || !addtobasketResponse.isEmpty())&& addtobasketResponse.containskey('cartContextKey')){
                    cartContextKey=   String.valueof(addtobasketResponse.get('cartContextKey'));
                    orderid= String.valueof(((Map<String,object>)((List<object>)((Map<String,object>)addtobasketResponse.get('result')).get('records'))[0]).get('OrderId'));
                }
                if(ismultiTransactionKey==false){
                    MCOnline_Basket__c bas=new MCOnline_Basket__c();
                    bas.TSCID__c= tscid;
                    bas.Account__c=Accountid;
                    bas.MCOnline_ParentBasket__c=parentbasket;
                    bas.MCOnline_Catalog__c= Catalog;
                    bas.MCOnline_OfferCode__c=String.valueof(offerObj1.get('ProductCode'));
                    //added by binamra
                    bas.MConline_Offer_ActionCode__c = (offerObj1.get('MConline_Action_Code__c')!=null) ? String.valueOf(offerObj1.get('MConline_Action_Code__c')): 'Add';
                    //logic for asynchrous basket
                    if(!string.isBlank(cartContextKey) && !string.isBlank(orderid)){
                        bas.MCOnline_Basket_Key__c=cartContextKey;
                        bas.MCOnline_Order__c= orderid;
                    }
                    /*else{
bas.MCOnline_Basket_Key__c="";
bas.MCOnline_Order__c= "";  
}*/
                    bas.MCOnline_AttributeJSON__c= AttributeJSON;
                    bas.MCOnline_MRC_Amount__c= mrc_price; //MCOnline_Negotiated_Amount__c  
                    bas.MCOnline_NRC_Amount__c= nrc_price;
                    bas.Basket_Line_Relation_Id__c = String.Valueof(inputMap.get('basketLineRelationId'));
                    bas.basket_Line_Relation_Count__c =(Decimal)inputMap.get('basketLineRelationCount');
                    insert bas;
                    if(!String.isBlank(AttributeJSON))
                    {
                        String UpdatedAttributeJSON = formatMSISDN(AttributeJSON);
                        //System.debug(UpdatedAttributeJSON);
                        MCOnline_Utility.reserveNumber(UpdatedAttributeJSON, cartContextKey, tscid,'addToBasket');
                    }
                    BasketIds.add(bas.id);
                    if(multiTransactionKey != null && !string.isBlank(multiTransactionKey))
                    {
                        storeInput.put(String.valueOf(bas.id), productConfigMap);
                    }
                    outMap.put('basketId',BasketIds);                       
                    outMap.put('parentbasket', parentbasket);
                    //outMap.put('orderNumber',orderNumber);
                    if(!hasError){
                        success=true;
                        outMap.put('success',true);
                    }
                }
                
                
                
                //}
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
                if(errorCode == 'UNABLE_TO_LOCK_ROW'){
                    string errmsg = 'there is an on going checkout. please hold for a while before proceeding towards the next transaction';
                    ErrorResponse.put('errorCode',errorCode);                   
                    ErrorResponse.put('error',errmsg);
                    ErrorResponse.put('success',false);
                    outMap.put('ErrorResponse',ErrorResponse);
                    outMap.put('StatusCode',400);
                    MCOnline_Utility.logError(final_message, errorCode,'MCOnline_MultiAddToBasketAndCheckOut_V3','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');               
                }
                else{               
                    outMap.put('ErrorResponse', MCOnline_Utility.generateError('',errorCode,'custom', 'MultiAddToBasketAndCheckOut'));
                    MCOnline_Utility.logError(final_message, errorCode,'MCOnline_MultiAddToBasketAndCheckOut_V3','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                }           
            }else
            {   outMap.put('ErrorResponse', MCOnline_Utility.generateError(stdError1,errorCode,'custom', 'MultiAddToBasketAndCheckOut'));
             MCOnline_Utility.logError(final_message,'500','MCOnline_MultiAddToBasketAndCheckOut_V3','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'',''); 
            }
            outMap.put('StatusCode', 500);
            //END error handling
        }       
        return outMap;
    }
    
    public static Map<String,Object> generateError(string error,string errorCode,string errorType,Map<String,Object> inputMap, String Catalog1){
        string Accountid;
        string tscid;
        string admin;
        string Agreementid;
        string Catalog= Catalog1;
        Accountid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Accountid'));
        tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
        admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
        Agreementid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
        string urlDetails = '{"Agreementid": "'+Agreementid+'", "tscid":"'+tscid+'", "users":"'+admin+'", "Catalog":"'+Catalog+'", "Accountid":"'+Accountid+'"}'; 
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        ipInputMap.put('functionality', 'MultiAddToBasketAndCheckOut');
        ipInputMap.put('error', error);   
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_MultiAddToBasketAndCheckOut_V3,MCOnline_MultiAddToBasketAndCheckOut_V3.generateError','Integration Procedure, Apex Class', 'Custom Error','STRING_TOO_LONG','','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    
    public static String formatMSISDN(String UpdatedAttributeJSON)
    {
        Map<String,Object> productDetails = (Map<String,Object>)JSON.deserializeUntyped(UpdatedAttributeJSON);
        List<Object> productList = (List<Object>)productDetails.get('products');
        Integer size = productList.size();
        for(Integer i = size - 1; i >= 0; i--)
        {
            Map<String, Object> recObj = ( Map<String, Object>)productList.get(i);
            //system.debug(JSON.serialize(recObj));
            if((recObj.containsKey('actionCode'))&&((string.valueOf(recObj.get('actionCode'))).equalsIgnoreCase('Add'))){
                if(!((string.valueOf(recObj.get('productCode'))).equalsIgnoreCase('MOB_MULTI_DATASIM_OFFER'))){
                    productList.remove(i);
                }
            }
            
        }
        String updateStr = JSON.serialize(productDetails);
        return updateStr;
    }
    
    //************************************************************************************************************
    //                                 synchronous checkout --> Asynchronous checkout
    //____________________________________________________________________________________________________________
    //This calls the checkout method synchronously in the class MCOnline_ProcessBasketManagedFlow_V2
    //The further methods in the checkout are asynchronous
    //____________________________________________________________________________________________________________  
    //************************************************************************************************************
    
    public static List<String> MultiAddToBasketAndCheckOut_V3_Checkout(string order, string TSCID, string AgreementId, string User){
        List<String> OrderNumber = new List<String>();
        Map<String,Object> orderDetails = (Map<String,Object>)JSON.deserializeUntyped(order);
        if(!Test.isRunningTest()){
            OrderNumber=MCOnline_ProcessBasket_V3.checkout(orderDetails,TSCID,AgreementId,User);
        }
        //MCOnline_ProcessBasketManagedFlow_V2POC.checkout(orderDetails,TSCID,AgreementId,User);
        return OrderNumber;
    }
    private static Map<String,List<MCOnline_Basket__c>> addItemToBasketToOrder(Map<String,List<MCOnline_Basket__c>> basketToOrderMap,MCOnline_Basket__c item,String key)
    {
        if(basketToOrderMap.get(key)!= null)
        {
            basketToOrderMap.get(key).add(item);
        }
        else
        {
            basketToOrderMap.put(key,new List<MCOnline_Basket__c>{item});
        }
        return basketToOrderMap;
    }
    public static List<String> splitLogicOrder(String parentId)
    {
        
        String orderId;
        Integer eligibleBasketCount;
        Set<String> orderNumbers=new Set<String>();
        List<String> OrderList = new List<String>();
        List<MCOnline_Basket__c> miniBasketList= new List<MCOnline_Basket__c>();
        List<MCOnline_Basket__c> minibasketlistUpdate = new List<MCOnline_Basket__c>();
        Set<String> basketRelationIdsForTransfer=new Set<String>();
        Map<String,List<MCOnline_Basket__c>> basketToOrderMap=new Map<String,List<MCOnline_Basket__c>>();
        //Getting the configurable Offers from custom setting for Split basket Logic
        Map<String, Checkout_Offer__c> offerMap = Checkout_Offer__c.getAll();
        String portIn = (offerMap.get('PORTIN_PROCESS').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS').OfferCode__c: null;
        String portInData = (offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c: null;
        String transferOffer = (offerMap.get('TRANSFER_PROCESS').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS').OfferCode__c: null;
        String transferOfferData = (offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c: null;
        
        
        List<MCOnline_ParentBasket__c> pBasketList=[SELECT Id, Is_Processed__c, Name, TSCID__c, OrderNumber__c, Account__c,(select id,Name,MCOnline_AttributeJSON__c,MCOnline_OfferCode__c,MCOnline_Is_Processed__c,MCOnline_Message__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c from MCOnline_Basket__r) FROM MCOnline_ParentBasket__c where Id=:parentId and Is_Processed__c=false AND flow__c='MANAGEFLOW' order by createddate desc limit 1];
        if(pBasketList != null && pBasketList.size() > 0){
            orderId=pBasketList[0].OrderNumber__c;
            List<MCOnline_Basket__c> basketList=pBasketList[0].MCOnline_Basket__r;
            //Updating the mini basket
            //Split Basket logic starts
            List<MCOnline_Basket__c> basketItems=basketList;
            eligibleBasketCount = Integer.valueOf(miniBasketList.size());
            //Grouping the basket with Basket relation Id having OfferCode TRANSFER_PROCESS or TRANSFER_PROCESS_DATA
            for(MCOnline_Basket__c item:basketItems)
            {
                if(item.MCOnline_OfferCode__c == transferOffer || item.MCOnline_OfferCode__c == transferOfferData)
                {
                    basketRelationIdsForTransfer.add(item.Basket_Line_Relation_Id__c);
                }
            }
            //Grouping the basket with Basket relation Id having OfferCode PORTIN_PROCESS or PORTIN_PROCESS_DATA
            for(MCOnline_Basket__c item:basketItems)
            {
                if(item.MCOnline_OfferCode__c == portIn ||item.MCOnline_OfferCode__c == portInData)
                {
                    basketToOrderMap.put(item.Basket_Line_Relation_Id__c+'PORTIN',new List<MCOnline_Basket__c>{item});
                    continue;
                }
                if(basketRelationIdsForTransfer.contains(item.Basket_Line_Relation_Id__c))
                {
                    basketToOrderMap=addItemToBasketToOrder(basketToOrderMap,item,item.Basket_Line_Relation_Id__c+'TRANSFER');
                }
                else
                {
                    basketToOrderMap=addItemToBasketToOrder(basketToOrderMap,item,'MIXED');
                }
            }
            Integer i=0;
            // Incrementing the Order Number in Mini Basket Records
            for(String key:basketToOrderMap.keySet())
            {    
                
                if(key == 'MIXED'){
                    for(MCOnline_Basket__c item:basketToOrderMap.get(key)){
                        item.order__c=orderId;
                        orderNumbers.add(orderId);
                    }   
                }
                else{
                    i++;
                    for(MCOnline_Basket__c item:basketToOrderMap.get(key))
                    {
                        item.order__c=orderId+'-'+i;
                        orderNumbers.add(orderId+'-'+i);
                    }
                }
            }// Updating the Mini Basket
            OrderList = new List<String>(orderNumbers);
            OrderList.sort();
            
        }
        
        return OrderList;
    }   
}