/****************************************************************************************************************************
* @author                 
* @modifiedBy            <shweta.a.hegde@capgemini.com>
* @maintainedBy
* @version                1.0
* @created                
* @modified               2021-09-14  Moved Unreserve number logic from MCOnline_DeleteBasket_V3 to this class
* @modified               2022-03-21  Added the method for ICC nuber validation

******************************************************************************************************************************/
public class MCOnline_Utility{
    
    static Map<String, Object> attribMap = new Map<String, Object>();
    public static void logErrorWithoutFuture(String errorMessage, String errorCode, String source, String sourceType, String errorType,String inputData,String contextId,String objectName){
        
        vlocity_cmt__VlocityErrorLogEntry__c errlog= new vlocity_cmt__VlocityErrorLogEntry__c();
        errlog.vlocity_cmt__ContextId__c   =   contextId   ;
        errlog.vlocity_cmt__ErrorCode__c   =   errorCode ;
        errlog.vlocity_cmt__ErrorMessage__c=   errorMessage  ;
        errlog.vlocity_cmt__ErrorType__c   =   errorType;
        errlog.vlocity_cmt__InputData__c   =   inputData ;
        errlog.vlocity_cmt__ObjectName__c  =   objectName;
        errlog.vlocity_cmt__SourceName__c  =   source;
        errlog.vlocity_cmt__SourceType__c  =   sourceType;
        insert errlog;
    }
    @future()
    public static void logError(String errorMessage, String errorCode, String source, String sourceType, String errorType,String inputData,String contextId,String objectName){
        
        vlocity_cmt__VlocityErrorLogEntry__c errlog= new vlocity_cmt__VlocityErrorLogEntry__c();
        errlog.vlocity_cmt__ContextId__c   =   contextId   ;
        errlog.vlocity_cmt__ErrorCode__c   =   errorCode ;
        errlog.vlocity_cmt__ErrorMessage__c=   errorMessage  ;
        errlog.vlocity_cmt__ErrorType__c   =   errorType;
        errlog.vlocity_cmt__InputData__c   =   inputData ;
        errlog.vlocity_cmt__ObjectName__c  =   objectName;
        errlog.vlocity_cmt__SourceName__c  =   source;
        errlog.vlocity_cmt__SourceType__c  =   sourceType;
        insert errlog;
    }
    
    @future()
    public static void logError(String errorMessage, String errorCode, String source, String sourceType, String errorType,String inputData,String contextId,String objectName, String url){
        Database.DmlOptions options = new Database.DmlOptions();
        options.allowFieldTruncation = true;
        vlocity_cmt__VlocityErrorLogEntry__c errlog= new vlocity_cmt__VlocityErrorLogEntry__c();
        errlog.vlocity_cmt__ContextId__c   =   contextId   ;
        errlog.vlocity_cmt__ErrorCode__c   =   errorCode ;
        errlog.vlocity_cmt__ErrorMessage__c=   errorMessage  ;
        errlog.vlocity_cmt__ErrorType__c   =   errorType;
        errlog.vlocity_cmt__InputData__c   =   inputData ;
        errlog.vlocity_cmt__ObjectName__c  =   objectName;
        errlog.vlocity_cmt__SourceName__c  =   source;
        errlog.vlocity_cmt__SourceType__c  =   sourceType;
        errlog.UrlDetails__c  =   url;
        Database.insert (errlog,options);
    }
    //BEGIN error Handling
    /*
    Parameters description
    Common for both type
    ==========================
    functionality - Refer API_NAME__c field of metadata
    errorType - custom/standard(Used for 2 different SOQL)


    Stanndard Error
    ==========================
    error - Standard_Error__c
    errorCode - Standard_Code__c


    Custom Error
    ==========================
    errorCode - Related_Parameter__c

    */
    public static void getError(Map<String,Object> ipInputMap, Map<String,Object> ipOutputMap){}
    
    public static Map<String,Object> generateError(string error,string errorCode,string errorType, string functionality ){
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        ipInputMap.put('functionality', functionality);
        ipInputMap.put('error', error);   
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        return MCOnline_Utility.getError(ipInputMap);
    }
    
/*=======================================================================================================================================
 This method is a common method for generating the error in all APIs   
========================================================================================================================================*/   
    public static Map<String,Object> generateError(string error,string errorCode,string errorType,Map<String,Object> inputMap, String Catalog1,List<MCOnline_Basket__c>parameters,String APIFunctunality ){
        string offer = String.Valueof(inputMap.get('offer'));
        String AgreementId = String.valueOf(inputMap.get('AgreementId'));
        string Catalog= String.Valueof(inputMap.get('Catalog'));
        string ProductCode= String.Valueof(inputMap.get('ProductCode'));
        string Accountid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Accountid'));
        string tscid= String.valueOf(inputMap.get('tscid'));
        string admin=String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
        string userId = String.valueOf(inputMap.get('users'));
        String basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('basketName'));
        String parentBasketId = String.valueOf(inputMap.get('parentBasketId'));
        String tcwssid = String.valueOf(inputMap.get('users'));
        String fromOrder= String.valueOf(inputMap.get('fromOrder'));
        String users = String.valueOf(inputMap.get('users'));
        String offerBundleCode = String.valueOf(inputMap.get('offerBundleCode'));
        String offerCode = String.valueOf(inputMap.get('offerCode'));
        String commitmentDuration = String.valueOf(inputMap.get('CommitmentDuration'));
        
        if(APIFunctunality =='AddToBasket'){
        if(parameters.size()==0 || parameters == null)
        {
            Accountid=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Accountid'));
            tscid = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
            admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
        }
        else{
            Accountid =String.Valueof(parameters[0].Account__c);
            tscid = String.Valueof(parameters[0].TSCID__c);
            admin = String.Valueof(parameters[0].MCOnline_ParentBasket__r.Admin__c);
            Catalog = String.Valueof(parameters[0].MCOnline_Catalog__c);
        }
        }
        string urlDetails = '{"basketName":"'+basketName+',"Agreementid": "'+AgreementId +',"catalog": "'+Catalog+', "offer": "'+offer +',"ProductCode": "'+ProductCode +',"tscid": "'+tscid+',"users": "'+users+',"Accountid": "'+Accountid+',"basketName": "'+basketName+',"parentBasketId": "'+parentBasketId+',"fromOrder": "'+fromOrder+',"offerBundleCode": "'+offerBundleCode+',"commitmentDuration": "'+commitmentDuration+',"offerCode": "'+offerCode+'"}';
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        ipInputMap.put('functionality', APIFunctunality);
        ipInputMap.put('error', error);   
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_Utility,MCOnline_Utility.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
/*=======================================================================================================================
This method is a common method for doing an http callout towards std addtobasket in a Synchronous call    
=========================================================================================================================*/    
    public static Map<String,Object> addToBasket_remote(String ContextKey,Map<String, Object> productConfigMap,string Catalog,boolean isManagedFlow){
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        input.put('apiName','basketOperations');
        input.put('catalogCode', Catalog);
        input.put('responseFormat', 'trimResponse');
        input.put('productConfig', productConfigMap);
        input.put('methodName', 'addAfterConfig');
        input.put('requestURL', '/v3/catalogs/'+Catalog+'/basket');
        input.put('contextKey', ContextKey);
        if(isManagedFlow){    
            input.put('validate','false');
        }
        input.put('price', false);
        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
        if(!Test.isRunningTest()){
            appHandler.invokeMethod('addAfterConfig', input, output, options);
                
        }
        return output;
    }
/*=======================================================================================================================================
 This method is a common method for doing an http callout towards std addtobasket in an Asynchronous call   
========================================================================================================================================*/    
    public static Map<String,Object> addToBasket_remote_Asynch(String ContextKey,Map<String, Object> productConfigMap,string Catalog,boolean isManagedFlow){
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        input.put('apiName','basketOperations');
        input.put('catalogCode', Catalog);
        input.put('productConfig', productConfigMap);
        input.put('responseFormat', 'trimResponse');
        input.put('methodName', 'addAfterConfig');
        input.put('requestURL', '/v3/catalogs/'+Catalog+'/basket');
        input.put('contextKey', ContextKey);
        if(isManagedFlow){    
            input.put('validate','false');
        }
        input.put('price', false);
        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
        if(!Test.isRunningTest()){
            appHandler.invokeMethod('addAfterConfig', input, output, options);
                
        }
        if(output.containskey('nexttransaction')){
          String multiTransactionKey =(String)((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)output.get('nexttransaction')).get('rest')).get('params')).get('multiTransactionKey');
          input.put('multiTransactionKey',multiTransactionKey);
          if(!Test.isRunningTest()){
             appHandler.invokeMethod('addAfterConfig', input, output, options);
          }
        }
        return output;
    }   
    
    public static Map<String,Object> getError(Map<String,Object> ipInputMap){
        Map<String,Object> ipOutputMap = new Map<String,Object>();
        string functionality,errorType,error,code;
        functionality = (String)ipInputMap.get('functionality');//API Name
        errorType = (String)ipInputMap.get('errorType'); //(custom/standard)
        error = String.valueOf(ipInputMap.get('error'));
        code = String.valueOf(ipInputMap.get('errorCode'));
        
        List<MCOnline_Error__mdt> mdtList = new List<MCOnline_Error__mdt>();
        //Standard Error message
        if((errorType != null && errorType.equalsIgnoreCase('standard')) && ( error!=null && code!=null )){
            mdtList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Additional_Parameters__c,MCONL_Error_Code__c, MCONL_Error_Message__c,CustomError__c,Standard_Error__c, Standard_Error_Code__c, LANGUAGE__c, VERSION__c, API_NAME__c FROM MCOnline_Error__mdt WHERE Standard_Error_Code__c=:code AND Standard_Error__c=:error AND Status__c = true AND API_NAME__c=:functionality limit 1];
        }
        
        //Custom Error message
        else if((errorType != null && errorType.equalsIgnoreCase('custom')) && ( code!=null )){
            mdtList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Additional_Parameters__c,MCONL_Error_Code__c, MCONL_Error_Message__c, Standard_Error__c, Standard_Error_Code__c, LANGUAGE__c, VERSION__c, API_NAME__c FROM MCOnline_Error__mdt WHERE CustomError__c=:code AND Status__c = true AND API_NAME__c=:functionality limit 1];
        }
        if(mdtList!=null && mdtList.size() > 0){
            ipOutputMap.put('errorCode',mdtList[0].MCONL_Error_Code__c); 
            ipOutputMap.put('error',mdtList[0].MCONL_Error_Message__c);
            ipOutputMap.put('success',false);
            
        }else{
            system.debug('You dont have IP output, This error message is not documented in metadata.'); 
            ipOutputMap.put('errorCode','INCOMPLETE_TRANSACTION');//This error message is not documented in metadata
            ipOutputMap.put('error','Could not complete the processing. Please contact system Admin');
            ipOutputMap.put('success',false);
        }
        return ipOutputMap;
    }
    
     //validate Icc_Number     
    public static Boolean containsDuplicateIccNumber( Map<String,Object> productConfigMap,Map<String,Object> inputMap, String callerClass){
        Map<String, Object> offerObj = new Map<String, Object>();
        Map<String, Object> attribMap = new Map<String, Object>();
        String ICC_number,admin,tscId,agrId;
        Boolean isDuplicate = false;
        offerObj=(Map<String, Object>)((Map<String, Object>)(productConfigMap).get('offerDetails')).get('offer');
        admin = String.Valueof(((Map<string,object>)inputMap.get('options')).get('users'));
        tscId = String.Valueof(((Map<string,object>)inputMap.get('options')).get('TSCID'));
        agrId=String.Valueof(((Map<string,object>)inputMap.get('options')).get('Agreementid'));
        if(offerObj.containskey('Quantity') && offerObj.get('Quantity')==1){
            attribMap = getChildAttribute(offerObj);
            ICC_number = String.valueOf(attribMap.get('ICC_number'));
        }
        String itemBasket='';
        if(!String.isBlank(ICC_number)){
            itemBasket = [select id,Name,MCOnline_ICC_Number__c from MCOnline_Basket__c where MCOnline_ParentBasket__r.TSCID__c =:tscId AND   MCOnline_ParentBasket__r.Admin__c =:admin AND MCOnline_ParentBasket__r.AgreementId__c=:agrId AND MCOnline_ParentBasket__r.Is_Processed__c=false AND MCOnline_ICC_Number__c=:ICC_number LIMIT 1]?.Name;
        }
        
        if(!String.isBlank(itemBasket)){
            if(callerClass == 'multiadd' || callerClass =='addToBasket'){
                isDuplicate = true;
            }else if(callerClass == 'changeBasket'){
                if((String.Valueof(((Map<string,object>)inputMap.get('options')).get('itemBasketName'))).equals(itemBasket)){
                    isDuplicate = true;  
                }else{
                    isDuplicate = false; 
                }
           }
           return  isDuplicate;
        }else{
          return false;  
        }
            
    }
    // process input request body for attribute 
    public static Map<String, Object> getChildAttribute(Object parent){
        String ICC_number;  
        Map<String, Object> tempParent = (Map<String, Object>)parent;   
        if(tempParent.containskey('Quantity') && tempParent.get('Quantity')==1){
            if(tempParent.containskey('childProducts')){
                List<Object> childrenObj = (List<Object>)tempParent.get('childProducts');
                if(childrenObj!=null && childrenObj.size()>0){
                    for(object childObj :childrenObj){
                        if(childObj!=null){
                            Map<String, Object> child = (Map<String, Object>)childObj;
                            if(child!=null && child.containskey('Quantity') && child.get('Quantity')==1){
                                getChildAttribute(child);
                            } 
                        }    
                    }
                }
            }else{ 
                if(tempParent.containsKey('AttributeCategory') && tempParent.get('AttributeCategory')!=null){
                    List<Object> recordObject =   (List<Object>)((Map<String, Object>)tempParent.get('AttributeCategory')).get('records');    
                    for(object record:recordObject){
                        Map<String, Object> rec = (Map<String, Object>)record;
                        if(rec.containskey('productAttributes')){
                            if(((Map<String, Object>)rec.get('productAttributes')).containskey('records')){
                                List<object> attrList = (List<object>)((Map<String, Object>)rec.get('productAttributes')).get('records');
                                for(object attrObj:attrList){
                                    Map<String, Object> attr = (Map<String, Object>)attrObj;
                                    if(attr.get('code')=='ICC_number'){
                                        ICC_number = String.valueOf(attr.get('userValues'));
                                        attribMap.put('ICC_number',ICC_number);
                                        break;
                                    }
                                }
                            }
                        }
                    }                  
                    
                }
                
            } 
        }
        return attribMap;
    }
    
    //END error Handling
    public static Map<String, Object> invokeIntegrationProcedure(string ProcedureName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        String str,jsonstr;
        try{
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> optionsMap = new Map<String, Object>();
            Object result = vlocity_cmt.IntegrationProcedureService.runIntegrationService(ProcedureName, input, optionsMap);
            output.put('Result', result);
            str = String.valueOf(result);
            jsonstr = JSON.serialize(result);
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonstr);
            return m;
        }
        catch(Exception e){
            system.debug(e);
            return null;
        }
    }
    
    // common code for number reservation
    public static Map<String,Object> reserveNumber(String attributeJSON, string cartContextKey, string tscid,String caller){
        List<String> MList = new List<String>();
        List<MCONL_MSISDN__c> msisdnList = new List<MCONL_MSISDN__c>();
        string productCategory,msisdn;
        Map<String,Object> itemList = new Map<String,Object>();
        itemList = (Map<String,Object>)JSON.deserializeUntyped(attributeJSON);
        Set<String> msisdnSet = new Set<String>();
        Set<String> productCategorySet = new Set<String>();
        List<Object> items = new List<Object>();
        items = (List<Object>)itemList.get('products');
        //Loop through each products in the basket
        for(Object lineItemObj : items){
            if(lineItemObj != null){
                Map<String, Object> recObj1Map = (Map<String, Object>)lineItemObj;
                if(recObj1Map != null){
                    productCategory = (string)recObj1Map.get('C2BC_Category');
                    Map<String, Object> attributesMap = (Map<String, Object>)recObj1Map.get('attributes');
                    // fetch the MSISDN from the attribute
                    if(attributesMap != null){
                        msisdn = (string)attributesMap.get('MSISDN');
                        // prepare MSISDN record that will be inserted
                        if(!String.isBlank(msisdn) || msisdn!=null){
                            msisdnSet.add(msisdn);
                            MCONL_MSISDN__c msisdnObj = new MCONL_MSISDN__c();
                            msisdnObj.TSCID__c = tscid;
                            msisdnObj.Status__c = 'Failed to Reserve';
                            msisdnObj.number__c = msisdn;
                            msisdnObj.CartContextKey__c = cartContextKey;
                            msisdnList.add(msisdnObj);
                            productCategorySet.add(productCategory);
                        }
                    }
                } 
            }
        }

        if((msisdnSet != null && msisdnSet.size() > 0) && (msisdnList != null)){
            // if this method is called from addToBasket then call future method to reserve msisdn
            if(caller.equals('addToBasket')){
                return addToBasket_reserveNumber(msisdnSet, tscid, productCategory, productCategorySet);
                // insert msisdn record at this point and this record will be updated once the future method execute and provide response
                //insert msisdnList;
                // if this method is called from Retry number reservation then call non future method to reserve msisdn    
            }else if(caller.equals('reTryNumberReservation')){
                retry_reserveNumber(msisdnSet, tscid, productCategory, productCategorySet);
            }
            
        }
        return null;
    }
    
    //reserveMSISDN for addToBasket
    //@future(callout=true)
    public static Map<String,Object> addToBasket_reserveNumber(Set<string> msisdnSet, string tscid, string productCategory, set<string> productCategorySet){
         return reserveMsisdn(msisdnSet, tscid, productCategory, productCategorySet);
    }
    
    //reserveMSISDN for retry number reservation
    public static void retry_reserveNumber(Set<string> msisdnSet, string tscid, string productCategory, set<string> productCategorySet){
        reserveMsisdn(msisdnSet, tscid, productCategory, productCategorySet);
    }
    
    // method to reserve msisdn by NHF
    public static Map<String,Object> reserveMsisdn(Set<string> msisdnSet, string tscid, string productCategory, set<string> productCategorySet){
        Map<String,Object> statusMap=new Map<String,Object>();
        if(msisdnSet.size()== productCategorySet.size()){
            List<MCOnline_NumberReservation_V2.ReservationResponseWrapper> responseList = new List<MCOnline_NumberReservation_V2.ReservationResponseWrapper>();
            Set<MCOnline_NumberReservation_V2.ReservationResponseWrapper> responseSet1 = new set<MCOnline_NumberReservation_V2.ReservationResponseWrapper>();
            List<MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper> statusResponseList = new List<MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper>();
            Set<MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper> statusResponseSet1 = new set<MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper>();
            List<String> msisdnListstr = new List<String>(msisdnSet);
            List<String> ProductCategoryListstr = new List<String>(productCategorySet);
            // iterate through each msisdn
            for(integer i=0; i<msisdnSet.size(); i++) {
                
                Set<String> msisdnSet1 = new Set<String>();
                msisdnSet1.add(msisdnListstr[i]);
                // check availibility of msisdn
                //MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper statusresponse = MCOnline_NumberReservationStatus_V2.checkMSISDN_Availability(msisdnSet1, tscid);
                List<MCONL_MSISDN__c> listToBeUpdated = new List<MCONL_MSISDN__c>();
                List<MCONL_MSISDN__c> msisdnList = new List<MCONL_MSISDN__c>();
                /*if(statusresponse != null && statusresponse.response != null && !(statusresponse.response.contains('"returnCode":"1"')) ){
                    statusResponseList.add(statusresponse);
                } */
                //else{
                    // if return code of the availability check is 1 then call the method to reserve msisdn
                    //if(statusresponse != null && statusresponse.response != null && (statusresponse.response.contains('"returnCode":"1"')) ){
                        MCOnline_NumberReservation_V2.ReservationResponseWrapper response = MCOnline_NumberReservation_V2.reserveMsisdn(msisdnSet1, tscid, ProductCategoryListstr[i]);
                        responseList.add(response); 
                    //}           
                //}
            }
            updateReserveNumber(responseSet1, statusResponseSet1);   
            statusMap.put('success',responseList);  
            statusMap.put('failure',statusResponseList);    
            return statusMap;
            /*
            responseSet1.addAll(responseList);
            statusResponseSet1.addAll(statusResponseList);
            */
            // update the msisdn record
             

        }
        return null;
    }
    
    public static void updateReserveNumber(set<MCOnline_NumberReservation_V2.ReservationResponseWrapper> ResponseSet, Set<MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper> statusResponseSet1)
    {
        List<MCONL_MSISDN__c> listToBeUpdated = new List<MCONL_MSISDN__c>();
        List<MCONL_MSISDN__c> msisdnList = new List<MCONL_MSISDN__c>();
        List<MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper> statusResponseListstr = new List<MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper>(statusResponseSet1);
        List<MCOnline_NumberReservation_V2.ReservationResponseWrapper> responseListstr = new List<MCOnline_NumberReservation_V2.ReservationResponseWrapper>(ResponseSet);
        msisdnList=[SELECT id, number__c, HttpRequest__c, HttpResponse__c, Endpoint__c, Status__c from MCONL_MSISDN__c order by CreatedDate];
        //if the status check response is not null or ResponseSet = null then assign corresponding values to the record
        if(statusResponseSet1!=null || statusResponseSet1.size()>0 || ResponseSet==null || ResponseSet.size()==0)
        {
            for(MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper statusres : statusResponseListstr){
                string str = new List<string>(statusres.msisdnSet)[0];
                for(MCONL_MSISDN__c msisdnObj : msisdnList){
                    if(msisdnObj.number__c == str)
                    {
                        // assign the status and response to the record
                        msisdnObj.HttpRequest__c = statusres.requestBody;
                        msisdnObj.HttpResponse__c = statusres.response;
                        msisdnObj.Endpoint__c = statusres.endpoint;
                        listToBeUpdated.add(msisdnObj);
                    }
                }
                if(listToBeUpdated != null && listToBeUpdated.size() > 0){
                    //update the record
                    update listToBeUpdated;  
                } 
            }
        }
        //if the status check response is null or ResponseSet not null then assign corresponding values to the record
        if(ResponseSet!=null || ResponseSet.size()>0 || statusResponseSet1==null || statusResponseSet1.size()==0){ 
            
            for(MCOnline_NumberReservation_V2.ReservationResponseWrapper res : responseListstr){
                if(res != null){
                    string str = new List<string>(res.msisdnSet)[0];
                    for(MCONL_MSISDN__c msisdnObj : msisdnList){
                        if(msisdnObj.number__c == str)
                        {
                            msisdnObj.HttpRequest__c = res.requestBody;
                            msisdnObj.HttpResponse__c = res.response;
                            msisdnObj.Endpoint__c = res.endpoint;
                            if(res != null && res.response != null && res.response.contains('"returnCode":"0"')){
                                msisdnObj.Status__c = 'Reserve';
                            }else{
                                msisdnObj.Status__c = 'Failed to Reserve';
                            }
                            listToBeUpdated.add(msisdnObj);
                        }       
                    }
                    if(listToBeUpdated != null && listToBeUpdated.size() > 0){
                        //update the record
                        update listToBeUpdated;
                    }
                } 
            }
        }
        
    }
    
    // common code for number Un reservation
    // 
    // UnreserveMSISDN for deleteBasket
    @future(callout=true)
    public static void deleteBasket_UnreserveNumber(string Minibaskets){
        unreserveMSISDN(Minibaskets);
    }
    // UnreserveMSISDN for retry number Unreservation
    public static void retry_UnreserveNumber(string Minibaskets){
        unreserveMSISDN(Minibaskets);
    }
    //method to Unreserve msisdn by NHF
    public static void unreserveMSISDN(string Minibaskets){  
        List<MCONL_MSISDN__c> MSISDNList1 = [select id, Status__c, LineItemKey__c, CartContextKey__c, Number__c from MCONL_MSISDN__c WHERE Status__c=:'Reserve'];
        Map<String,Map<string,set<string>>> MiniBasketUnreserve = (Map<String,Map<string,set<string>>>)JSON.deserialize(Minibaskets,Map<String,Map<string,set<string>>>.class);
        Map<String, List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>> UpdateMsisdn = new Map<String, List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>>();
        String invalidMSISDN = '';
        integer count;
        for(string b : MiniBasketUnreserve.keySet()){ //looping over for the baskets   
            List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper> responseList = new List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>();
            String tscid;
            String msisdnStr;
            Map<string,set<string>> basketTSCIDandMSISDN = MiniBasketUnreserve.get(b);
            count=0;
            if(basketTSCIDandMSISDN.containskey('tscid')){
                set<String> tscid1 = basketTSCIDandMSISDN.get('tscid');
                tscid = new List<string>(tscid1)[0];
            }
            set<String> MSISDN = basketTSCIDandMSISDN.get('MSISDN');
            system.debug('MSISDN==>'+MSISDN);
            if(MSISDN.size() > 0 || MSISDN != null){
                for(string s: MSISDN){ 
                    Set<String> msisdnSet1 = new Set<String>();
                    msisdnSet1.add(s);
                    msisdnStr = new List<String>(msisdnSet1)[0];
                    for(MCONL_MSISDN__c m : MSISDNList1){
                        if(m.Number__c == s){
                            MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper response = MCOnline_NumberUnReservation_V2.UnreserveMsisdn(msisdnSet1, tscid);
                            responseList.add(response);
                        }
                    }
                    if(responseList==null || responseList.size()==0){
                        MCOnline_Utility.logErrorWithoutFuture('attempting to unreserve an invalid MSISDN', 'INAVALID_MSISDN','MCONLINE_deleteBasket_V2,MCONLINE_deleteBasket_V2.unreserveMSISDN','Integration Procedure, Apex Class', 'Custom Error',msisdnStr,'','');
                        invalidMSISDN= invalidMSISDN + msisdnStr+' ' ;
                    }
                    else{
                        if(!UpdateMsisdn.containskey(msisdnStr)){
                            UpdateMsisdn.put(msisdnStr,new List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>{responseList[Count]});     
                        }
                        else{
                            UpdateMsisdn.get(msisdnStr).add(responseList[count]);  
                        }
                        count ++;  
                    }               
                }
            }
        }
        if(!UpdateMsisdn.isEmpty()){
            msisdnUpdate(UpdateMsisdn, MSISDNList1);
        }
        else{
            MCOnline_Utility.logErrorWithoutFuture('attempting to unreserve invalid MSISDN(s)', 'INAVALID_MSISDN','MCONLINE_deleteBasket_V2,MCONLINE_deleteBasket_V2.unreserveMSISDN','Integration Procedure, Apex Class', 'Custom Error',invalidMSISDN,'','');
        }
    }
    public static void msisdnUpdate(Map<String, List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>> msisdnsToUpdate, List<MCONL_MSISDN__c> MSISDNList1){
        for(string s: msisdnsToUpdate.keyset()){
            list<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper> response1 = msisdnsToUpdate.get(s);
            MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper response2 = response1[0];
            for(MCONL_MSISDN__c m : MSISDNList1){
                List<MCONL_MSISDN__c> MSISDNListToBeUpdated = new List<MCONL_MSISDN__c>();
                if(m.Number__c == s){
                    if(response1.size()>0 || response1!=null){
                        if(response2.status == 202){
                            string body = response2.response;
                            if(body.contains('"returnCode":"0"')){
                                m.Status__c = 'Un Reserve';
                            }
                            else{
                                m.Status__c = 'Failed to UnReserve';
                            }
                            m.Unreservation_Endpoint__c = response2.endpoint;
                            m.Unreservation_Request__c = response2.requestBody;
                            m.Unreservation_Response__c = response2.response;
                            MSISDNListToBeUpdated.add(m);
                        } 
                    } 
                }
                system.debug('MSISDNListToBeUpdated'+MSISDNListToBeUpdated);
                if(MSISDNListToBeUpdated != null && MSISDNListToBeUpdated.size() > 0){
                    update MSISDNListToBeUpdated;
                }
            }
        }
    }    
    
}