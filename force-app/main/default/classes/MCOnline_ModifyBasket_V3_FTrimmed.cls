global with sharing class MCOnline_ModifyBasket_V3_FTrimmed implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        List<id> BasketIds = new List<id>();
        List<String> Baskets = new List<String>();
        if(methodName.equals('addtobasket_remotemethod'))
        {  
            Map<String, Object> remotemethodResponse = new Map<String, Object>();
            Map<String, Object> productConfigMap = new Map<String, Object>();
            List<Object> productConfigList = new List<Object>();
            productConfigList = (List<Object>)inputMap.get('productConfig');
            system.debug('productConfigMap--> '+productConfigList);
            system.debug('productConfigMapSIZE--> '+productConfigList.size());
            for(Object offers: productConfigList){
                //Added by Binamra Guha
                /*-------------------Trimming of request body------------------------*/
                /*Map<String, Object> tempMap = (Map<String, Object>)offers;
                removeItems(tempMap);
                productConfigMap = (Map<String, Object>)tempMap;*/
                /*--------------------------------------------------------------*/
                productConfigMap = (Map<String, Object>)offers;
                system.debug('productConfigMap--> '+productConfigMap);
                string Catalog='';
                if(String.valueOf((((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)( (Map<String, Object>)(productConfigMap).get('offerDetails')).get('offer')).get('addtocart')).get('rest')).get('link'))).Contains('SUBSCRIPTIONS')){
                    Catalog = 'SUBSCRIPTIONS';
                }
                else{
                    Catalog = 'MOBILEDEVICE';
                }
                string cartContextKey = String.valueof(inputMap.get('contextKey'));
                remotemethodResponse=addtobasket_remotemethod(cartContextKey,JSON.serialize(productConfigMap),Catalog);
                outMap=addToBasket_V2_NormalCallout(inputMap,remotemethodResponse, outMap,options,JSON.serialize(productConfigMap),BasketIds,Catalog);
                
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
        String parentId = String.valueOf(outMap.get('parentbasket'));
        if(outmap.containsKey('ErrorResponse')){
            Map<string,object> ErrorResponse = new Map<string,object>();
            ErrorResponse = (Map<string,object>)outmap.get('ErrorResponse');
            outmap.clear();
            outmap.put('ErrorResponse',ErrorResponse);
            outMap.put('StatusCode',400);
            deleteBasket(BasketIds,parentId);
        } 
        else{
            list<MCOnline_ParentBasket__c> Names = new list<MCOnline_ParentBasket__c>();
            system.debug('parentBasketId'+parentId);    
            Names = [select id, (select Name from MCOnline_Basket__r) from MCOnline_ParentBasket__c where Id=:parentId];
            for(MCOnline_Basket__c o: Names[0].MCOnline_Basket__r)
            {
                Baskets.add(o.Name);
            }
            outMap.put('basket',Baskets);
            
            string TSCID = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
            string AgreementId = String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
            string User = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
            ModifyBasket_V2_Checkout(JSON.serialize((Map<String, Object>)inputMap.get('orderDetails')),TSCID,AgreementId,User);
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
   /* private static void removeItems(Object obj){
        
        Map<String, Object> tempMap1 = (Map<String, Object>)obj;
        Map<String,Object> offerDetails=(Map<String,Object>)tempMap1.get('offerDetails');
        Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
        if(offer.containsKey('childProducts'))
        {
            List<Object> childProducts=(List<Object>)offer.get('childProducts');
            for(Integer j = childProducts.size() - 1; j >= 0; j--)
            {
                Map<String, Object> tempMap2 = (Map<String, Object>)childProducts.get(j);
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
    } */
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
    public static Map<String,Object> addtobasket_remotemethod(String cartContextKey,String productConfigMap,string catalogCode){
        
        boolean MTS=false;
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> output1 = new Map<String, Object>();
        Map<String, Object> output2 = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        try{
            String orderid='';
            
            List<MCOnline_Basket__c> basketlst= new List<MCOnline_Basket__c>();
            Map<String, Object> input = new Map<String, Object>();
            Map<String, Object> option = new Map<String, Object>();
            Map<String, Object> offerdetails = new Map<String, Object>();
            input.put('apiName','basketOperations'); 
            input.put('catalogCode', catalogCode); 
            input.put('productConfig',(Map<String, Object>)JSON.deserializeUntyped(productConfigMap)); 
            input.put('methodName', 'addAfterConfig'); 
            input.put('requestURL', '/v3/catalogs/'+catalogCode+'/basket');
            input.put('price', false);
            input.put('cartcontextKey', cartContextKey);
            vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
            appHandler.invokeMethod('addAfterConfig', input, output, option);
            if(output.containskey('nexttransaction')){
                output1= output;
                while(output1.containskey('nexttransaction') && !output1.containskey('result'))
                {
                    MTS=true; 
                    string multiTransactionKey='';
                    multiTransactionKey=String.Valueof((String)((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)output1.get('nexttransaction')).get('rest')).get('params')).get('multiTransactionKey'));
                    input.put('multiTransactionKey',multiTransactionKey);
                    vlocity_cmt.CpqAppHandler appHandler2 = new vlocity_cmt.CpqAppHandler();
                    appHandler2.invokeMethod('addAfterConfig', input, output2, option);
                    system.debug('output2-> '+output2);
                    output1=output2;
                }
                if(output2.containskey('cartContextKey')){
                }
            }else{}
            System.debug('===Addtobasket output===>: ' + output);
            System.debug('===Addtobasket output2===>: ' + output2);
            
        }Catch(Exception e){   
            String error_message= e.getMessage() +' '+e.getLineNumber();
            system.debug('error message'+error_message);
            string stdError;
            if(error_message.contains('Invalid Context Info')){
                stdError = 'Invalid Context Info';                
                output.put('error',stdError);
                output.put('errorCode','INVOKE-500');
                output.put('success','false');
                system.debug('output catch==>'+output);
            }
        }
        
        if(MTS==false){
            return  output;
        }else{          
            return output2; 
        }
    }
    public static Map<String,Object> addToBasket_V2_NormalCallout(Map<String,Object> inputMap,Map<String,Object> HA_AddToBasket, Map<String,Object> outMap, Map<String,Object> options,String productConfigMap,List<id> BasketIds,string Catalog1){
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
        //BEGIN error handling
        String stdError;
        String errorCode;
        String message;
        String code;
        boolean hasError = false;
        Map<String, Object> ipInputMap = new Map<String, Object>();
        Map<String, Object> ipOutputMap = new Map<String, Object>();
        Map<String,object> addtobasketResponse= new Map<String,object>();
        Map<String,object> errorMap= new Map<String,object>();
        addtobasketResponse=HA_AddToBasket;
        system.debug('remotemethodResponse'+addtobasketResponse);
        Try{
            //BEGIN error handling
            Map<String, Object> ErrorResponse = new Map<String, Object>();
            if(ismultiTransactionKey==false){
                
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
                        else{
                            vlocity_cmt.JSONResult resulterr1 = (vlocity_cmt.JSONResult)HA_AddToBasket.get('result');
                            system.debug('resulterr1--> '+resulterr1);
                            string resultMSgCode = resulterr1.messages[0].code;
                            string resultMSgMsg = resulterr1.messages[0].message;
                            ErrorResponse.put('errorCode',resultMSgCode);                     
                            ErrorResponse.put('error',resultMSgMsg);
                            ErrorResponse.put('success',false);
                            outMap.put('ErrorResponse',ErrorResponse);
                            outMap.put('StatusCode',400);
                            MCOnline_Utility.logError(resultMSgMsg, resultMSgCode,'MCOnline_AddToBasket_V2','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
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
                        outMap.put('ErrorResponse', MCOnline_Utility.generateError(stdError,errorCode,'standard', 'AddToBasket'));
                        MCOnline_Utility.logError(stdError, errorCode,'MCOnline_AddToBasket_V2','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                        outMap.put('StatusCode', 400);
                    }
                }else{  
                    Map<String, Object> compMsg = new Map<String, Object>();
                    Map<String, Object> result = (Map<String, Object>)HA_AddToBasket.get('result');
                    system.debug('');
                    String compItems= '';
                    Boolean success;
                    List<Object> resultMessage = (List<Object>)result.get('messages');  
                    tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));                    
                    admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
                    List<Object> tscidRec = [SELECT id FROM Account WHERE TSCID__c=:tscid limit 1];                    
                    basketLineRelationId=String.Valueof(inputMap.get('basketLineRelationId'));
                    basketLineRelationCount = (Integer)inputMap.get('basketLineRelationCount');
                    if(resultMessage!=null && !resultMessage.isEmpty()){
                        boolean isErrorCollected = false;
                        for(Object msg:resultMessage){
                            compMsg = (Map<String, Object>)msg;
                            if(String.valueOf(compMsg.get('code'))=='208'){
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
                        MCOnline_Utility.logError(compItems, errorCode,'MCOnline_AddToBasket_V2','Apex Class','Standard Error',JSON.serialize((Map<string,object>)inputMap.get('options')),'','');
                    }else{
                        if(String.isBlank(basketLineRelationId) || String.isBlank(String.Valueof(basketLineRelationCount)) || basketLineRelationCount ==0 ){
                            hasError = true;
                            errorCode = 'BASKET_LINE_RELATION_ID_COUNT_ERROR';
                            outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, Catalog));
                            outMap.put('StatusCode', 500);                            
                        }else if(String.isEmpty(admin)||tscidRec.isEmpty()){
                            hasError = true;
                            errorCode = 'INAVALID_USER_TSCID';
                            outMap.put('ErrorResponse', generateError('',errorCode,'custom', inputMap, Catalog));
                            outMap.put('StatusCode', 500);
                        }else{ 
                            offerObj1=(Map<String, Object>)( (Map<String, Object>)(productConfigMap1).get('offerDetails')).get('offer') ;
                            //===================parse json===========================//
                            List<Object> childProducts2ndLevel = new List<Object>();
                            childProducts2ndLevel= (List<Object>)offerObj1.get('childProducts');
                            Map<String, Object> rootproductMap2save = new Map<String, Object>();
                            List<Object> rootproductList2save = new List<Object>();
                            Decimal negotiatedPrice=0;
                            
                            if(childProducts2ndLevel!=null && childProducts2ndLevel.size()>0){
                                
                                for(object productGroup : childProducts2ndLevel){
                                    
                                    Map<String, Object> productGroupspriceResultObj = (Map<String, Object>)productGroup;
                                    List<Object> childproductList = new List<Object>();
                                    childproductList= (List<Object>)productGroupspriceResultObj.get('childProducts');
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
                                                if(childProductResultObj.containskey('MConline_Action_Code__c'))
                                                    if(String.Valueof(childProductResultObj.get('MConline_Action_Code__c'))!=null){
                                                        productMap2save.put('actionCode',String.Valueof(childProductResultObj.get('MConline_Action_Code__c')));
                                                    }
                                                else{
                                                    productMap2save.put('actionCode','Add');
                                                }
                                                productMap2save.put('name',String.Valueof(childProductResultObj.get('Name')));
                                                if(priceResult!=null){
                                                    Map<String, Object> priceResultMap = new Map<String, Object>();
                                                    //negotiatedPrice=negotiatedPrice + (Decimal)priceResultMap.get('Amount__c');
                                                    for(Object pricelst:priceResult){
                                                        priceResultMap=(Map<String, Object>)pricelst ; 
                                                        if(String.Valueof(priceResultMap.get('ChargeType__c'))=='Recurring'){
                                                            
                                                            productMap2save.put('chargeAmount',String.Valueof(priceResultMap.get('chargeamount')));
                                                            productMap2save.put('baseAmount',String.Valueof(priceResultMap.get('baseamount')));
                                                            productMap2save.put('amount',String.Valueof(priceResultMap.get('Amount__c')));
                                                            //productMap2save.put('nrc_amount',String.Valueof(priceResultMap.get('NRC_Amount__c')));
                                                            productMap2save.put('recurringFrequency',String.Valueof(priceResultMap.get('RecurringFrequency__c')));
                                                            productMap2save.put('chargeType',String.Valueof(priceResultMap.get('ChargeType__c')));
                                                            productMap2save.put('displayText',String.Valueof(priceResultMap.get('DisplayText__c')));
                                                        }else if(String.Valueof(priceResultMap.get('ChargeType__c'))=='One-time'){
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
                                                        productAttributeObj1.put(String.Valueof(productAttributeObj.get('label')),String.Valueof(productAttributeObj.get('userValues')));
                                                    }
                                                    if(productAttributeObj1 != null){
                                                        if(productAttributeObj1.containskey('Billing Account Online')) 
                                                            attr.put('billingAccountOnline',String.Valueof(productAttributeObj1.get('Billing Account Online')));
                                                        if(productAttributeObj1.containskey('Commitment_period')) 
                                                            attr.put('commitmentPeriod',String.Valueof(productAttributeObj1.get('Commitment_period')));
                                                        if(productAttributeObj1.containskey('e-SIM_Method')) 
                                                            attr.put('eSIM_Method',String.Valueof(productAttributeObj1.get('e-SIM_Method')));
                                                        if(productAttributeObj1.containskey('Email')) 
                                                            attr.put('email',String.Valueof(productAttributeObj1.get('Email')));
                                                        if(productAttributeObj1.containskey('External_reference')) 
                                                            attr.put('externalReference',String.Valueof(productAttributeObj1.get('External_reference')));
                                                        if(productAttributeObj1.containskey('ICC_number')) 
                                                            attr.put('ICCNumber',String.Valueof(productAttributeObj1.get('ICC_number')));
                                                        if(productAttributeObj1.containskey('MSISDN')) 
                                                            attr.put('MSISDN',String.Valueof(productAttributeObj1.get('MSISDN')));
                                                        if(productAttributeObj1.containskey('SIM_Format')) 
                                                            attr.put('SIM_Format',String.Valueof(productAttributeObj1.get('SIM_Format')));
                                                        if(productAttributeObj1.containskey('User_name')) 
                                                            attr.put('userName',String.Valueof(productAttributeObj1.get('User_name')));
                                                        /* for hardware products -------------------------------- */
                                                        if(productAttributeObj1.containskey('HWItemCategory')) 
                                                            attr.put('HWItemCategory',String.Valueof(productAttributeObj1.get('HWItemCategory')));
                                                        if(productAttributeObj1.containskey('HWItemCnetBrandColor')) 
                                                            attr.put('HWItemCnetBrandColor',String.Valueof(productAttributeObj1.get('HWItemCnetBrandColor')));
                                                        if(productAttributeObj1.containskey('HWItemCnetMemory')) 
                                                            attr.put('HWItemCnetMemory',String.Valueof(productAttributeObj1.get('HWItemCnetMemory')));
                                                        if(productAttributeObj1.containskey('HWItemPromisID')) 
                                                            attr.put('HWItemPromisID',String.Valueof(productAttributeObj1.get('HWItemPromisID')));
                                                        if(productAttributeObj1.containskey('HWItemTeliaSku')) 
                                                            attr.put('HWItemTeliaSku',String.Valueof(productAttributeObj1.get('HWItemTeliaSku')));
                                                        if(productAttributeObj1.containskey('HWProductBrand')) 
                                                            attr.put('HWProductBrand',String.Valueof(productAttributeObj1.get('HWProductBrand')));
                                                        if(productAttributeObj1.containskey('HWSAPID')) 
                                                            attr.put('HWSAPID',String.Valueof(productAttributeObj1.get('HWSAPID')));
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
                                                            
                                                            productMap2save4thlevel.put('name',String.Valueof(childProductResultObj4thlevel.get('Name')));
                                                            if(priceResult4thlevel!=null && priceResult4thlevel.size()>0){
                                                                Map<String, Object> priceResultMap4thlevel = new Map<String, Object>();
                                                                //priceResultMap4thlevel=(Map<String, Object>)priceResult4thlevel[0] ;  
                                                                //negotiatedPrice=negotiatedPrice + (Decimal)priceResultMap4thlevel.get('Amount__c');
                                                                for(Object pricelst:priceResult4thlevel){
                                                                    priceResultMap4thlevel=(Map<String, Object>)pricelst ; 
                                                                    if(String.Valueof(priceResultMap4thlevel.get('ChargeType__c'))=='Recurring'){
                                                                        productMap2save4thlevel.put('chargeAmount',String.Valueof(priceResultMap4thlevel.get('chargeamount')));
                                                                        productMap2save4thlevel.put('baseAmount',String.Valueof(priceResultMap4thlevel.get('baseamount')));
                                                                        productMap2save4thlevel.put('amount',String.Valueof(priceResultMap4thlevel.get('Amount__c')));
                                                                        productMap2save4thlevel.put('recurringFrequency',String.Valueof(priceResultMap4thlevel.get('RecurringFrequency__c')));
                                                                        productMap2save4thlevel.put('chargeType',String.Valueof(priceResultMap4thlevel.get('ChargeType__c')));
                                                                        productMap2save4thlevel.put('displayText',String.Valueof(priceResultMap4thlevel.get('DisplayText__c')));
                                                                    }else if(String.Valueof(priceResultMap4thlevel.get('ChargeType__c'))=='One-time'){
                                                                        productMap2save4thlevel.put('nrc_amount',String.Valueof(priceResultMap4thlevel.get('Amount__c')));
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
                                                                    if(productAttributeObj4thlevel.containskey('Commitment_period')) 
                                                                        attr1.put('commitmentPeriod',String.Valueof(productAttributeObj4thlevel.get('Commitment_period')));
                                                                    if(productAttributeObj4thlevel.containskey('e-SIM_Method')) 
                                                                        attr1.put('eSIM_Method',String.Valueof(productAttributeObj4thlevel.get('e-SIM_Method')));
                                                                    if(productAttributeObj4thlevel.containskey('Email')) 
                                                                        attr1.put('email',String.Valueof(productAttributeObj4thlevel.get('Email')));
                                                                    if(productAttributeObj4thlevel.containskey('External_reference')) 
                                                                        attr1.put('externalReference',String.Valueof(productAttributeObj4thlevel.get('External_reference')));
                                                                    if(productAttributeObj4thlevel.containskey('ICC_number')) 
                                                                        attr1.put('ICCNumber',String.Valueof(productAttributeObj4thlevel.get('ICC_number')));
                                                                    if(productAttributeObj4thlevel.containskey('MSISDN')) 
                                                                        attr1.put('MSISDN',String.Valueof(productAttributeObj4thlevel.get('MSISDN')));
                                                                    if(productAttributeObj4thlevel.containskey('SIM_Format')) 
                                                                        attr1.put('SIM_Format',String.Valueof(productAttributeObj4thlevel.get('SIM_Format')));
                                                                    if(productAttributeObj4thlevel.containskey('User_name')) 
                                                                        attr1.put('userName',String.Valueof(productAttributeObj4thlevel.get('User_name')));
                                                                    /* for hardware products -------------------------------- */
                                                                    if(productAttributeObj4thlevel.containskey('HWItemCategory')) 
                                                                        attr1.put('HWItemCategory',String.Valueof(productAttributeObj4thlevel.get('HWItemCategory')));
                                                                    if(productAttributeObj4thlevel.containskey('HWItemCnetBrandColor')) 
                                                                        attr1.put('HWItemCnetBrandColor',String.Valueof(productAttributeObj4thlevel.get('HWItemCnetBrandColor')));
                                                                    if(productAttributeObj4thlevel.containskey('HWItemCnetMemory')) 
                                                                        attr1.put('HWItemCnetMemory',String.Valueof(productAttributeObj4thlevel.get('HWItemCnetMemory')));
                                                                    if(productAttributeObj4thlevel.containskey('HWItemPromisID')) 
                                                                        attr1.put('HWItemPromisID',String.Valueof(productAttributeObj4thlevel.get('HWItemPromisID')));
                                                                    if(productAttributeObj4thlevel.containskey('HWItemTeliaSku')) 
                                                                        attr1.put('HWItemTeliaSku',String.Valueof(productAttributeObj4thlevel.get('HWItemTeliaSku')));
                                                                    if(productAttributeObj4thlevel.containskey('HWProductBrand')) 
                                                                        attr1.put('HWProductBrand',String.Valueof(productAttributeObj4thlevel.get('HWProductBrand')));
                                                                    if(productAttributeObj4thlevel.containskey('HWSAPID')) 
                                                                        attr1.put('HWSAPID',String.Valueof(productAttributeObj4thlevel.get('HWSAPID')));
                                                                    
                                                                    /*labelVsUservalues4thlevel.put(String.Valueof(productAttributeObj4thlevel.get('label')),String.Valueof(productAttributeObj4thlevel.get('userValues')));
                                                                      productAttributeObj4thlevel.put('userValues', null);*/ 
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
                            tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
                            admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
                            Agreementid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
                            List<MCOnline_ParentBasket__c> parentbas=new List<MCOnline_ParentBasket__c>();
                            parentbas=[SELECT id,name,OrderNumber__c FROM MCOnline_ParentBasket__c WHERE AgreementId__c=:Agreementid AND TSCID__c=:tscid AND Admin__c=:admin AND Is_Processed__c =false];
                            if(parentbas!=null && parentbas.size()>0){
                                system.debug('Name-> '+parentbas[0].Name);
                                system.debug('OrderNumber-> '+parentbas[0].OrderNumber__c);
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
                                insert pbas;
                                system.debug('Name-> '+pbas.Name);
                                system.debug('OrderNumber-> '+pbas.OrderNumber__c);
                                parentbasket=pbas.id;
                                orderNumber=pbas.OrderNumber__c;
                            }
                            if(addtobasketResponse.containskey('cartContextKey')){
                                cartContextKey=   String.valueof(addtobasketResponse.get('cartContextKey'));
                                orderid= String.valueof(((Map<String,object>)((List<object>)((Map<String,object>)addtobasketResponse.get('result')).get('records'))[0]).get('OrderId'));
                            }
                            if(ismultiTransactionKey==false && cartContextKey!=''){
                                MCOnline_Basket__c bas=new MCOnline_Basket__c();
                                bas.TSCID__c= tscid;
                                bas.Account__c=Accountid;
                                bas.MCOnline_ParentBasket__c=parentbasket;
                                bas.MCOnline_Catalog__c= Catalog;
                                bas.MCOnline_OfferCode__c=String.valueof(offerObj1.get('ProductCode'));
                                bas.MCOnline_Basket_Key__c=cartContextKey;
                                bas.MCOnline_AttributeJSON__c= AttributeJSON;
                                bas.Request_body__c=productConfigMap;
                                bas.MCOnline_Order__c= orderid;
                                bas.MCOnline_Negotiated_Amount__c= negotiatedPrice;
                                bas.Basket_Line_Relation_Id__c = String.Valueof(inputMap.get('basketLineRelationId'));
                                bas.basket_Line_Relation_Count__c =(Decimal)inputMap.get('basketLineRelationCount');
                                insert bas;
                                system.debug('Name-> '+bas.Name);
                                BasketIds.add(bas.id);
                                outMap.put('basketId',BasketIds);                       
                                outMap.put('parentbasket', parentbasket);
                                outMap.put('orderNumber',orderNumber);
                                if(!hasError){
                                    success=true;
                                    outMap.put('success',true);
                                }
                            }
                        }
                    }
                }
            }else{  // MTS
                outMap.put('Addtobasket_RA',addtobasketResponse);
            }
        }Catch(Exception e){   
            hasError = true;
            System.debug('Error Message===>: ' + e.getMessage()); 
            System.debug('Error Line number===>: ' + e.getLineNumber()); 
            String error_message= e.getMessage() +' '+e.getLineNumber();
            //BEGIN error handling
            If(error_message.contains('REQUIRED_FIELD_MISSING')){
                errorCode = 'REQUIRED_FIELD_MISSING';
            }else If(error_message.contains('Invalid id')){
                errorCode = 'INVALID_ID';
            }else{
                errorCode = 'UNKNOWN_ERROR';
            }
            string stdError1 = 'Invalid Account Id or Agreement Id';
            String dc_message = String.valueOf(addtobasketResponse);
            String final_message = error_message+' '+dc_message;
            if(errorCode != 'UNKNOWN_ERROR')
            {   outMap.put('ErrorResponse', MCOnline_Utility.generateError('',errorCode,'custom', 'AddToBasket'));
             MCOnline_Utility.logError(final_message, errorCode,'MCOnline_ModifyBasket_V3_FTrimmed','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'',''); 
            }else
            {   outMap.put('ErrorResponse', MCOnline_Utility.generateError(stdError1,errorCode,'custom', 'AddToBasket'));
             MCOnline_Utility.logError(final_message,'500','MCOnline_ModifyBasket_V3_FTrimmed','Apex Class','Exception',JSON.serialize((Map<string,object>)inputMap.get('options')),'',''); 
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
        ipInputMap.put('functionality', 'AddToBasket');
        ipInputMap.put('error', error);   
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_ModifyBasket_V3_FTrimmed,MCOnline_ModifyBasket_V3_FTrimmed.generateError','Integration Procedure, Apex Class', 'Custom Error','STRING_TOO_LONG','','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    
    //************************************************************************************************************
    //                                 synchronous checkout --> Asynchronous checkout
    //____________________________________________________________________________________________________________
    //This calls the checkout method synchronously in the class MCOnline_ProcessBasketManagedFlow_V2
    //The further methods in the checkout are asynchronous
    //____________________________________________________________________________________________________________  
    //************************************************************************************************************
    
    public static void ModifyBasket_V2_Checkout(string order, string TSCID, string AgreementId, string User){
        Map<String,Object> orderDetails = (Map<String,Object>)JSON.deserializeUntyped(order);
        MCOnline_ProcessBasket_V3.checkout(orderDetails,TSCID,AgreementId,User);
        //MCOnline_ProcessBasketManagedFlow_V2POC.checkout(orderDetails,TSCID,AgreementId,User);
    }    
}