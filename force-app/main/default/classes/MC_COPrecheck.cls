global class MC_COPrecheck implements vlocity_cmt.VlocityOpenInterface{
    public class PrecheckException extends Exception{}
    global static boolean isSLAC4 = false;
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('deleteServicepointAndPremises')) {
                //Delete Service point and premises which aree deleted from UI
                deleteServicepointAndPremises(inputMap,outMap);
            }else if(methodName.equalsIgnoreCase('insertPrecheckInfo')) {
                // Insert Precheck Data from Netfraga API
                insertPrecheckInfo(inputMap);
            }
            else if(methodName.equalsIgnoreCase('combineServicepoints')) {
                // To make a List Of GA and LA Address and to process FTTX flag
                combineServicepoints(inputMap,outMap);
            }else if (methodName.equals('responsePreCheckView')){ 
                // Precheck View data preparation
                transformServicepoint(inputMap,outMap);
            }else if (methodName.equals('deletePrecheckData')){ 
                // delete precheck data in Full precheck
                deletePrecheckData(inputMap);
            }else if (methodName.equals('addressValidationCallout')){ 
                // Address validation API Callout.
                // Calling here cause of IP limitation
                addressValidationCallout(inputMap,outMap);
            }else if(methodName.equalsIgnoreCase('PrecheckTransformResponse')) {
                // Process Netfraga API OutPut
                precheckTransformResponse(inputMap,outMap);
            }else if(methodName.equalsIgnoreCase('UpdateTerminationError')) {
                // Process Netfraga API OutPut
                UpdateTerminationError(inputMap,outMap);
            }
            else if(methodName.equalsIgnoreCase('ProductPriceUpdate_Matrix')){
                //Update List Prices for products from matrix for FTTX prices
                matrixCall(inputMap,outMap,options);
            }
            else if(methodName.equalsIgnoreCase('deleteSites')) {
                // Insert Precheck Data from Netfraga API
                deleteSites(inputMap,outMap);
            }
            else {
                result = false;
            } 
        }catch(Exception e) {    
           
          //  outMap.put('Exception' ,e);
          System.debug('Exception'+e.getStackTraceString());
          outMap.put('ErrorMessage',e.getStackTraceString()+e.getMessage());//Added by Abhishek for error handling
            result = false;
        }        
        return result;        
    }    
    
    // calling Http callout here cause of IP limitation
    public static void addressValidationCallout(Map<String,Object> inputMap, Map<String,Object> outMap){
        String endpointURL = (String)inputMap.get('EndpointURL'); //https://api-garden-test.teliacompany.com/v2/api/mef/geographicSiteManagement/se/geographicSite?
        String token = (String)inputMap.get('token'); 
        String aptno = (String)inputMap.get('aptno');
        String city = (String)inputMap.get('city');
        String streetName = (String)inputMap.get('streetName');
        String streetNr = (String)inputMap.get('streetNr');
        String streetNrSuffix = (String)inputMap.get('streetNrSuffix');
        String postcode = (String)inputMap.get('Postcode'); 
        
        String queryurl = endpointURL;
        String keyurl = 'api-garden'; //added by Shouvik for datamasking in address validation.
        
        if(queryurl.contains(keyurl))
        {       
        queryurl += 'searchAllLevels=true&geographicAddress.streetNrSuffix=';
        if(streetNrSuffix != null){
            queryurl +=  EncodingUtil.urlEncode(streetNrSuffix, 'UTF-8');
        }
        queryurl += '&geographicAddress.streetNr=';
        if(streetNr != null){
            queryurl +=  EncodingUtil.urlEncode(streetNr, 'UTF-8');
        }
        queryurl += '&geographicAddress.streetName=';
        if(streetName != null){
            queryurl +=  EncodingUtil.urlEncode(streetName, 'UTF-8');
        }
        queryurl += '&geographicAddress.postcode=';
        if(postcode != null){
            queryurl += EncodingUtil.urlEncode(postcode, 'UTF-8');
        }
        queryurl += '&geographicAddress.city=';
        if(city != null){
            queryurl += EncodingUtil.urlEncode(city, 'UTF-8');
        }
        queryurl += '&geographicAddress.addrLine1=';
        if(aptno != null){
            queryurl += EncodingUtil.urlEncode(aptno, 'UTF-8');
        }
        }
        Http p = new Http();        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(queryurl);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', token);  
        HttpResponse response;
        if(!Test.isRunningTest()){
            response =p.send(request);
        }
        //get response of Http action send it back to IP
        outMap.put('respBody',json.deserializeUntyped(response.getBody()));
    }    
    
     
    //Delete ServicePoint or premises which got deleted from UI
    public Static void deleteServicepointAndPremises(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{
        String ContextId = (String)inputMap.get('ContextId'); // get Opportunity ID
        String AccId = (String)inputMap.get('AccId');
        Opportunity opp = new Opportunity();
        opp.Id = ContextId;
        opp.IsPreChecked__c = false;
        update opp;
		//Added the below logic to pass the productFamily flag to the parent OS based on the B2B Solution toggle system label.
            outMap.put('productFamily','CO');
            if(System.label.B2BSolution_Toggle=='true'){
                outMap.put('productFamily','B2B');
            }        

        // Modified code for defect MCSTO-8800
        if(AccId != null && (boolean)inputMap.get('fullPrecheck')){
            List<vlocity_cmt__ServicePoint__c> servicePointList = new List<vlocity_cmt__ServicePoint__c>();
            List<vlocity_cmt__ServicePoint__c> servicePointList1 = new List<vlocity_cmt__ServicePoint__c>();
            servicePointList = [Select id,PrecheckProcessed__c from vlocity_cmt__ServicePoint__c where vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =: AccId];
            if(servicePointList.size() > 0){
                //If service points which needs to be deleted exists in DB then collect premises Id and delete service points
                for(vlocity_cmt__ServicePoint__c s : servicePointList){
                    vlocity_cmt__ServicePoint__c spoint = new vlocity_cmt__ServicePoint__c();
                    spoint.Id = s.Id;
                    spoint.PrecheckProcessed__c  = false;
                    servicePointList1.add(spoint);
                }
                if(servicePointList1.size() > 0 ){
                    try{
                        update servicePointList1;
                    }catch(Exception e) { 
                        System.debug('Exception'+e);
                    }  
                }                
            }
        }


        List<Object> siteList = (List<Object>)inputMap.get('siteList'); //get Selected Servicepoints
        List<String> SelectedServicePoints = new List<String>();
        List<String> editedPreviousServicePoints = new List<String>();
        List<Object> AddedSelectedServicePoints = new List<Object>();
        List<Object> siteList1 = new List<Object>(); // for collection of all non deleted sites
        List<String> servicePointCollection = new List<String>();
        Set<String> premisesId = new set<String>();
        for(object eachSite : siteList){
            Map<String,Object> siteinfo = (Map<String,Object>)eachSite;
            if(siteinfo.get('isDeleted') != null ){ //check if isDeleted Flag is true 
                if((Boolean)siteinfo.get('isDeleted')){
                    Map<String,Object> serivepointMap = (Map<String,Object>)siteinfo.get('selectedServicePoint');
                    SelectedServicePoints.add(String.valueOf(serivepointMap.get('servicePointId'))); //get service points if is deleted is true
                    
                }else{
                    if(siteinfo.get('isDisabled') != null){
                        if((Boolean)siteinfo.get('isDisabled') == false){
                            AddedSelectedServicePoints.add(siteinfo);
                            siteList1.add(siteinfo);
                        }
                        else{
                            Map<String,Object> serivepointMap = (Map<String,Object>)siteinfo.get('selectedServicePoint');
                            servicePointCollection.add(String.valueOf(serivepointMap.get('servicePointId')));
                            siteList1.add(siteinfo);
                        }
                    }
                }
                
            }else{ 
                if(siteinfo.get('isDisabled') != null){
                    if((Boolean)siteinfo.get('isDisabled') == false){
                        AddedSelectedServicePoints.add(siteinfo);
                        siteList1.add(siteinfo);
                    }else{
                        Map<String,Object> serivepointMap = (Map<String,Object>)siteinfo.get('selectedServicePoint');
                        servicePointCollection.add(String.valueOf(serivepointMap.get('servicePointId')));
                        siteList1.add(siteinfo);
                    }
                }
            }
            if(siteinfo.get('isEdited') != null && (Boolean)siteinfo.get('isEdited')){
                Map<String,Object> serivepointMap = (Map<String,Object>)siteinfo.get('previousServiceId');
                editedPreviousServicePoints.add(String.valueOf(serivepointMap.get('servicePointId')));
            }
        }
        outMap.put('finalSelectedSiteList',AddedSelectedServicePoints);
        outMap.put('siteList',siteList1);
        if(AddedSelectedServicePoints.size() > 0){
            outMap.put('AccId',AccId);
        }
        if(editedPreviousServicePoints.size() > 0){
            try{
                delete [Select id from MC_PreCheck_Result__c where Service_Point__r.vlocity_cmt__ServicePointNumber__c in: editedPreviousServicePoints and Opportunity__c =: ContextId];
				delete [Select id,name,vlocity_cmt__ServicePointNumber__c,vlocity_cmt__PremisesId__c from vlocity_cmt__ServicePoint__c where vlocity_cmt__ServicePointNumber__c in: editedPreviousServicePoints and  vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =: AccId];                
            }catch(Exception e){
                //System.debug('Exception-->'+e.getStackTraceString());
            }
        }   
        if(SelectedServicePoints.size() > 0){

            List<vlocity_cmt__ServicePoint__c> servicePointList = new List<vlocity_cmt__ServicePoint__c>();
            // Query to find whether they exist in Database
            servicePointList = [Select id,name,vlocity_cmt__ServicePointNumber__c,vlocity_cmt__PremisesId__c from vlocity_cmt__ServicePoint__c where vlocity_cmt__ServicePointNumber__c in: SelectedServicePoints and  vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =: AccId];

            if(servicePointList.size() > 0){
                //If service points which needs to be deleted exists in DB then collect premises Id and delete service points
                for(vlocity_cmt__ServicePoint__c s : servicePointList){
                    premisesId.add(s.vlocity_cmt__PremisesId__c);
                }                
            }
            try{

                delete [Select id from MC_PreCheck_Result__c where Service_Point__r.vlocity_cmt__ServicePointNumber__c in: SelectedServicePoints and Opportunity__c =: ContextId];       

                delete servicePointList;
            }catch(Exception e) { 
                System.debug('Exception on deleting servicepoints'+e);
            }  
        }

        if(premisesId.size() > 0){
            Set<String> premisesId2 = new set<String>();
            List<vlocity_cmt__ServicePoint__c> servicePointList = new List<vlocity_cmt__ServicePoint__c>();
            // from the previous premise Id list query and find if any other service point linked to them
            servicePointList = [Select id,name,vlocity_cmt__ServicePointNumber__c,vlocity_cmt__PremisesId__c from vlocity_cmt__ServicePoint__c where vlocity_cmt__PremisesId__c in: premisesId and (vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =: AccId OR vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c = null)];
            for(vlocity_cmt__ServicePoint__c s : servicePointList){
                premisesId2.add(s.vlocity_cmt__PremisesId__c);
            }
            // if service point exists remove it from List
            premisesId.removeAll(premisesId2);
            if(premisesId.size() > 0){
                //delete remaining premises which have no service points linked to it.               
                try{
                    delete [select id from vlocity_cmt__Premises__c where Id in: premisesId and vlocity_cmt__PropertyOwnerAccountId__c =: AccId];
                }catch(Exception e) { 
                    System.debug('Exception'+e);
                } 
            }
        }
    } catch(Exception e)
        {
            throw new PrecheckException(e);
        }
    }
    
    public static void insertPrecheckInfo(Map<String,Object> inputMap){         
        try{
        //---------------------------------- Get DataBase product info -----------------------------------------------------
        Map<String,Object> parentUpdatedMap = new Map<String,Object>();
        Map<String,Object> parentChildNameMap = new Map<String,Object>();
        Map<String,String> nameMap = new Map<String,String>();
        Map<String,String> codeMap = new Map<String,String>();
        Map<String,Object> ProdRespmap = (Map<String,Object>)inputMap.get('ProductExtract'); //from DB             
        List<Object> parentMap = (List<Object>)ProdRespmap.get('Parent');   //parent product    
        // logic to get product bandwidth from Attributes.
        if(parentMap != null && parentMap.size() > 0){
            for(Object parentobj : parentMap){            
                Map<String,Object> eachparentMap = (Map<String,Object>)parentobj;   

                List<Object> childListMap = (List<Object>)eachparentMap.get('Child');

                if(eachparentMap.get('ProductNetfragaName') != null){
                    nameMap.put((String)eachparentMap.get('ProductNetfragaName'),(String)eachparentMap.get('Name'));
                    codeMap.put((String)eachparentMap.get('ProductNetfragaName'),(String)eachparentMap.get('ProductCode'));
                }
                // Collection of products less than 1 GBPS
                List<object> childBWcollection = new List<Object>();
                set<String> childProdName = new set<String>();
                // Collection of Products greater than 1 GBPS
                List<object> childBWcollection1GB = new List<Object>();
                set<String> childProdName1GB = new set<String>(); 
                if(childListMap != null && childListMap.size() > 0){
                    for(Object childobj : childListMap){
                        Map<String,Object> eachChildMap = (Map<String,Object>)childobj;
                        if(eachChildMap.get('JsonAttribute') != null){
                            //String jsonDefaultValues = (String) eachChildMap.get('JsonAttribute');
                            map<string,object> map1 = (map<String,Object>)eachChildMap.get('JsonAttribute');                           
                            integer prodBandWidth;
                            boolean priceAverageFlag = false;
                            boolean preCheckFlag = false;
                            for(String key : map1.keySet()){                               
                                if(key == 'ATT_RT_Bandwidth' && map1.get(key) != null)
                                {
                                    prodBandWidth = integer.valueOf(map1.get(key));
                                }else if(key == 'ATT_RT_PRICEAVG'){
                                    if(map1.get(key) != null){
                                         priceAverageFlag = boolean.valueOf(map1.get(key));
                                    }
                                    else{
                                        priceAverageFlag = false;
                                    }
                                }else if(key == 'ATT_RT_PRECHECK'){
                                     if(map1.get(key) != null){
                                        preCheckFlag = boolean.valueOf(map1.get(key));
                                    }else{
                                        preCheckFlag = false;
                                    } 
                                } 
                            }
                            eachChildMap.put('Bandwidth', prodBandWidth);
                            eachChildMap.put('priceAverageFlag', priceAverageFlag);
                            eachChildMap.put('preCheckFlag', preCheckFlag);
                            eachChildMap.remove('JsonAttribute');//remove jsonattribute
                            if(preCheckFlag) {
                                if(prodBandWidth <= 1000000){
                                    childBWcollection.add(eachChildMap);
                                    childProdName.add((String)eachChildMap.get('Name'));//which all products needed to be added to DB
                                }else{
                                    childBWcollection1GB.add(eachChildMap);
                                    childProdName1GB.add((String)eachChildMap.get('Name'));//which all products needed to be added to DB
                                }
                            }
                        }
                    }
                }
                Map<String,Object> childBWcollectionMap = new Map<String,Object>();
                Map<String,Object> childProdNameMap = new Map<String,Object>();
                childBWcollectionMap.put('lessthan1gbps',childBWcollection);
                childBWcollectionMap.put('greaterthan1gbps',childBWcollection1GB);
                if(childProdName.size() > 0){
                    childProdNameMap.put('lessthan1gbps',childProdName);
                }
                if(childProdName1GB.size() > 0){
                    childProdNameMap.put('greaterthan1gbps',childProdName1GB);
                }
                parentUpdatedMap.put((String)eachparentMap.get('ProductNetfragaName'),childBWcollectionMap);//complete child data
                parentChildNameMap.put((String)eachparentMap.get('ProductNetfragaName'),childProdNameMap);//Child Names
            }
        }
        //-----------------------------------end of logic to get Bandwidth from product json---------------------------------------------------      
        //-----------------------------------Get Adjustments PSTU values-----------------------------------------------------------------------        
        List<Object> adjustmentList = (List<Object>)inputMap.get('Adjustment'); //PSTU
        Map<String,Object> adjustmentMap = new Map<String,Object>();
        for(object adj : adjustmentList){
            if(adj != null){
                Map<String,Object> tempMap = (Map<String,Object>)adj;
                if(tempMap.get('Label') != null){
                    adjustmentMap.put((String)tempMap.get('Label'),tempMap); //map label to object
                }
            }
        }
        //-----------------------------------getErrorCodes----------------------------------------------------------------------------------
        List<Object> errorList = (List<Object>)inputMap.get('ErrorCode');
        Map<String,String> ErrorCodeMap = new Map<String,String>();
        for(object error : errorList){
            if(error != null){
                Map<String,Object> tempMap = (Map<String,Object>)error;
                if(tempMap.get('ErrorCode') != null){
                    ErrorCodeMap.put((String)tempMap.get('ErrorCode'),(String)tempMap.get('Error_Translation__c')); //map label to object
                }
            }
        } 
        
        
        //----------------------------------Custom label where we have all precheck products---------------------------------------------------
        String precheckProducts = System.label.CO_PrecheckProduct;
        set<String> precheckProductSet = new Set<String>();
        precheckProductSet.addAll(precheckProducts.split(','));
        //-----------------------------------Netfraga API--------------------------------------------------------------------------------------        
        Map<String,Object> netfragaResponse = (Map<String,Object>)inputMap.get('PrecheckResponse'); //http response
        String AccId = (String)inputMap.get('AccountId');
        String objId = (String)inputMap.get('Opportunity');
        List<Object> productOfferingList = (List<Object>)netfragaResponse.get('productOffering');

        // String servicePointNumber = String.valueOf(netfragaResponse.get('place'));// get service point Id
        String servicePointNumber = String.valueOf(inputMap.get('SpointNumber')); // MCSTO-10895 : Shouvik
        
        // get record id from servicePoint from database
        vlocity_cmt__ServicePoint__c servicepointobj = new vlocity_cmt__ServicePoint__c();
        servicepointobj = [Select Id,vlocity_cmt__ServicePointNumber__c, vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c,PrecheckProcessed__c  from vlocity_cmt__ServicePoint__c where vlocity_cmt__ServicePointNumber__c =:servicePointNumber and vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =: AccId  limit 1];
        if(servicepointobj.Id != null){
            //filterPrecheckResponse function is called to filter out the CO products based on productFamily//
            if(productOfferingList !=null)
                filterPrecheckResponse(productOfferingList, inputMap.get('productFamily')+'');
            //----------------------------------------------------------------------------------------------//
            //-----insert parent products and get Id's-----------------------------------------------
            insertPrecheckResponse(productOfferingList,(String)servicepointobj.Id,objId,ErrorCodeMap,nameMap); // insert all response from API in precheckresponse recordtype
            
            List<MC_PreCheck_Result__c> premiseInfoList1 = new List<MC_PreCheck_Result__c>();
            List<MC_PreCheck_Result__c> precheckResultList1 = new List<MC_PreCheck_Result__c>();            
            for(object eachOffer : productOfferingList){ //insert parent products
                Map<String,Object> eachproduct = (Map<String,Object>)eachOffer;
                String pname = (String)eachproduct.get('productName');            
                MC_PreCheck_Result__c precheckResult1 = new MC_PreCheck_Result__c();
                precheckResult1.Name = (String)nameMap.get(pname);
                precheckResult1.MC_Product_Code__c   = (String)codeMap.get(pname);
                precheckResult1.Service_Point__c = servicepointobj.Id;
                precheckResult1.Opportunity__c = objId;
                precheckResult1.RecordTypeId = Schema.SObjectType.MC_PreCheck_Result__c.getRecordTypeInfosByName().get('Netfraga Response').getRecordTypeId();
                precheckResultList1.add(precheckResult1);
                precheckProductSet.remove(pname);
            }
            if(precheckProductSet.size() > 0){
                for(String missedProd : precheckProductSet){
                    MC_PreCheck_Result__c precheckResult1 = new MC_PreCheck_Result__c();
                  precheckResult1.Name = (String)nameMap.get(missedProd);            
                  precheckResult1.Service_Point__c = servicepointobj.Id;
                  precheckResult1.Opportunity__c = objId;
                  precheckResult1.RecordTypeId = Schema.SObjectType.MC_PreCheck_Result__c.getRecordTypeInfosByName().get('Netfraga Response').getRecordTypeId();
                    //CO_ErrorBundleMiss
                    precheckResult1.MC_ReturnCode__c = '9998';
                  precheckResultList1.add(precheckResult1);
                }
            }
            try{
                insert precheckResultList1;
            }catch(Exception e) { 
                System.debug('Exception'+e);
            }              
            precheckResultList1.clear();     
            precheckResultList1 = [select Id,MC_Product_Code__c from MC_PreCheck_Result__c where MC_Parent_Info__c = null and Service_Point__r.vlocity_cmt__ServicePointNumber__c =: servicePointNumber and Opportunity__c =: objId];
            Map<String,String> premiseparentMap = new Map<String,String>();
            for(MC_PreCheck_Result__c pinfo: precheckResultList1){
                String key = pinfo.MC_Product_Code__c;
                premiseparentMap.put(key,pinfo.Id);
            }
            //--------------------------Child product insertion-------------------------------           
            List<MC_PreCheck_Result__c> precheckResultList = new List<MC_PreCheck_Result__c>();
            for(object eachOffer : productOfferingList){   // for each family
                Map<String,Object> eachproduct = (Map<String,Object>)eachOffer;
                String pname = (String)eachproduct.get('productName'); // api family name
                String mappedPCode = (String)codeMap.get(pname); // family name from DB

                List<Object> connectionType = (List<Object>)eachproduct.get('deliveryOptions'); // netfraga delivery options for family
                Map<integer,Object> priorityMap = new Map<integer,Object>();
                Map<integer,Object> prioritygreater1gbMap = new Map<integer,Object>();
                Map<integer,Object> errorCodePrioLess1GBMap = new Map<integer,Object>();
                Map<integer,Object> errorCodePrioGreater1GBMap = new Map<integer,Object>();
                for(Object conObj : connectionType){
                    Map<String,Object> conMap = (Map<String,Object>)conObj; 
                    if(conMap.get('returnCode') != '0'){
                        if(conMap.get('priority') != null && conMap.get('maxDownloadSpeed') != null){
                            if(errorCodePrioLess1GBMap.get(Integer.valueOf(conMap.get('priority'))) != null){
                              Map<String,Object> existingConMap = (Map<String,Object>)errorCodePrioLess1GBMap.get(Integer.valueOf(conMap.get('priority')));
                                if(conMap.get('maxDownloadSpeed') != null && Integer.valueOf(conMap.get('maxDownloadSpeed')) > integer.valueOf(existingConMap.get('maxDownloadSpeed'))){
                                    errorCodePrioLess1GBMap.put(Integer.valueOf(conMap.get('priority')),conMap);
                                }else{
                                    errorCodePrioLess1GBMap.put(Integer.valueOf(conMap.get('priority')),existingConMap);
                                }
                            }else{
                                errorCodePrioLess1GBMap.put(Integer.valueOf(conMap.get('priority')),conMap);
                            }
                        }
                        if(conMap.get('bandwidthGreaterThanOneGbps') != null && conMap.get('bandwidthGreaterThanOneGbps') != '' && conMap.get('maxDownloadSpeed') != null){
                            if(errorCodePrioGreater1GBMap.get(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps'))) != null){
                              Map<String,Object> existingConMap = (Map<String,Object>)errorCodePrioGreater1GBMap.get(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps')));
                                if(conMap.get('maxDownloadSpeed') != null && Integer.valueOf(conMap.get('maxDownloadSpeed')) > integer.valueOf(existingConMap.get('maxDownloadSpeed'))){
                                    errorCodePrioGreater1GBMap.put(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps')),conMap);
                                }else{
                                    errorCodePrioGreater1GBMap.put(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps')),existingConMap);
                                }
                            }else{
                                errorCodePrioGreater1GBMap.put(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps')),conMap);
                            }
                            
                        }
                    }else{
                        if(conMap.get('priority') != null && conMap.get('priority') != '' && conMap.get('maxDownloadSpeed') != null){
                            if(priorityMap.get(Integer.valueOf(conMap.get('priority'))) != null){
                              Map<String,Object> existingConMap = (Map<String,Object>)priorityMap.get(Integer.valueOf(conMap.get('priority')));
                                if(conMap.get('maxDownloadSpeed') != null && Integer.valueOf(conMap.get('maxDownloadSpeed')) > integer.valueOf(existingConMap.get('maxDownloadSpeed'))){
                                     priorityMap.put(Integer.valueOf(conMap.get('priority')),conMap);
                                }else{
                                    priorityMap.put(Integer.valueOf(conMap.get('priority')),existingConMap);
                                }
                            }else{
                                 priorityMap.put(Integer.valueOf(conMap.get('priority')),conMap);
                            }                           
                        }
                        if(conMap.get('bandwidthGreaterThanOneGbps') != null && conMap.get('bandwidthGreaterThanOneGbps') != '' && conMap.get('maxDownloadSpeed') != null){
                            if(prioritygreater1gbMap.get(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps'))) != null){
                              Map<String,Object> existingConMap = (Map<String,Object>)prioritygreater1gbMap.get(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps')));
                                if(conMap.get('maxDownloadSpeed') != null && Integer.valueOf(conMap.get('maxDownloadSpeed')) > integer.valueOf(existingConMap.get('maxDownloadSpeed'))){
                                     prioritygreater1gbMap.put(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps')),conMap);
                                }else{
                                    prioritygreater1gbMap.put(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps')),existingConMap);
                                }
                            }else{
                                 prioritygreater1gbMap.put(Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps')),conMap);
                            }
                            
                        }                       
                    }
                }
                
                // prods from DB
                List<Object> eachproductinfo = new List<Object>();
                set<String> childNameSet = new set<String>();
                List<Object> eachproductinfo1GB = new List<Object>();
                set<String> childNameSet1GB = new set<String>();
                if(parentUpdatedMap.get(pname) != null){
                    Map<String,Object> childBWcollectionMap = (Map<String,Object>)parentUpdatedMap.get(pname);
                    if(childBWcollectionMap.get('lessthan1gbps') != null){
                        eachproductinfo =  (List<Object>)childBWcollectionMap.get('lessthan1gbps');
                    }
                    if(childBWcollectionMap.get('greaterthan1gbps') != null){
                        eachproductinfo1GB =  (List<Object>)childBWcollectionMap.get('greaterthan1gbps');
                    }
                    
                    Map<String,Object> childProdNameMap = (Map<String,Object>)parentChildNameMap.get(pname);
                    if(childProdNameMap.get('lessthan1gbps') != null){
                        childNameSet = (set<String>)childProdNameMap.get('lessthan1gbps');
                    }
                    if(childProdNameMap.get('greaterthan1gbps') != null){
                        childNameSet1GB = (set<String>)childProdNameMap.get('greaterthan1gbps');
                    }
                }                
                Map<String,Object> inMap = new Map<String,Object>();
                inMap.put('adjustmentMap',adjustmentMap);
                inMap.put('pname',pname);
                inMap.put('mappedPCode',mappedPCode);
                inMap.put('servicepoint',servicepointobj.Id);
                inMap.put('objId',objId);
                inMap.put('premiseparentMap',premiseparentMap);   
                inMap.put('ErrorCodeMap',ErrorCodeMap);
                // Comparision and Insertion Logic starts
                if(childNameSet != null){
                    // products less than 1gbps
                    //response with no error
                    precheckResultList.addAll(compareBandwidhts(priorityMap,eachproductinfo,childNameSet,inMap));
                    if(childNameSet.size() != 0){
                        
                        //For error code != 0
                        precheckResultList.addAll(compareBandwidhts(errorCodePrioLess1GBMap,eachproductinfo,childNameSet,inMap));                   
                    }
                    if(childNameSet.size() != 0){
                        for(Object Prodobj : eachproductinfo){
                            Map<String,Object> BWmap = (Map<String,Object>)Prodobj; 
                            if(childNameSet.contains((String)BWmap.get('Name'))){ 
                                // insert precheckResult for products which are not found in response
                                precheckResultList.add(preparePrecheckRecord(BWmap,null,null,(String)premiseparentMap.get(mappedPCode),(String)servicepointobj.Id,objId,''));
                            }
                        }
                    }
                }
                // products greater than 1gbps
                //response with no error
                if(childNameSet1GB != null){
                    precheckResultList.addAll(compareBandwidhts(prioritygreater1gbMap,eachproductinfo1GB,childNameSet1GB,inMap));
                    if(childNameSet1GB.size() != 0){
                        //For error code != 0
                        precheckResultList.addAll(compareBandwidhts(errorCodePrioGreater1GBMap,eachproductinfo1GB,childNameSet1GB,inMap));                   
                    }
                    if(childNameSet1GB.size() != 0){
                        for(Object Prodobj : eachproductinfo1GB){
                            Map<String,Object> BWmap = (Map<String,Object>)Prodobj;                         
                            if(childNameSet1GB.contains((String)BWmap.get('Name'))){ 
                                // insert precheckResult for products which are not found in response

                                precheckResultList.add(preparePrecheckRecord(BWmap,null,null,(String)premiseparentMap.get(mappedPCode),(String)servicepointobj.Id,objId,''));
                            }
                        }
                    }
                }
            }
            if(precheckProductSet.size() > 0){
                for(String missedProd : precheckProductSet){
                  String mappedPCode = (String)codeMap.get(missedProd);
                    
                    List<Object> eachproductinfo = new List<Object>();
                  set<String> childNameSet = new set<String>();
                  List<Object> eachproductinfo1GB = new List<Object>();
                  set<String> childNameSet1GB = new set<String>();
                  if(parentUpdatedMap.get(missedProd) != null){
                      Map<String,Object> childBWcollectionMap = (Map<String,Object>)parentUpdatedMap.get(missedProd);
                      if(childBWcollectionMap.get('lessthan1gbps') != null){
                          eachproductinfo =  (List<Object>)childBWcollectionMap.get('lessthan1gbps');
                      }
                      if(childBWcollectionMap.get('greaterthan1gbps') != null){
                          eachproductinfo1GB =  (List<Object>)childBWcollectionMap.get('greaterthan1gbps');
                      }                    
                      Map<String,Object> childProdNameMap = (Map<String,Object>)parentChildNameMap.get(missedProd);
                      if(childProdNameMap.get('lessthan1gbps') != null){
                          childNameSet = (set<String>)childProdNameMap.get('lessthan1gbps');
                      }
                      if(childProdNameMap.get('greaterthan1gbps') != null){
                          childNameSet1GB = (set<String>)childProdNameMap.get('greaterthan1gbps');
                      }
                  }
                    if(childNameSet.size() > 0){
                        for(Object Prodobj : eachproductinfo){
                            Map<String,Object> BWmap = (Map<String,Object>)Prodobj; 
                            BWmap.put('errorCode','9998');
                            if(childNameSet.contains((String)BWmap.get('Name'))){ 
                                // insert precheckResult for products which are not found in response
                                precheckResultList.add(preparePrecheckRecord(BWmap,null,null,(String)premiseparentMap.get(mappedPCode),(String)servicepointobj.Id,objId,''));
                            }
                        }
                    }
                }
            }
            if(precheckResultList.size()>0){
                try{
                    servicepointobj.PrecheckProcessed__c = true; // Update precheckprocessed as true for service points which are processed
                    servicepointobj.MC_IS_SLA_C4_Available__c = isSLAC4;
                    update servicepointobj;
                    insert precheckResultList;
                }catch(Exception e) { 
                    System.debug('Exception'+e);
                }
                
            }
            
        }     
       }catch(Exception e)
        {
            throw new PrecheckException(e);
        }   
    }
    
/* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* This method is for filtering out the CO and B2B product coming from netfraga response.
* The filtering is based on productFamily flag.
* If the productFamily flag return B2B, it will show B2B products else CO
* ___________________________________________________________________________________________________________
* @param productOfferingList                      List of productOffering coming from netfraga
* @param productFamily                            Flag to filter B2B and CO
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
*/
    @TestVisible private static void filterPrecheckResponse(List<Object> productOfferingList, String productFamily)
    {
        try{
            Integer offerSize = productOfferingList.size();
            for(Integer i = offerSize - 1; i >= 0; i--)
            {
                Map<String, Object> objMap = (Map<String, Object>)productOfferingList.get(i);
                if(String.isNotBlank(productFamily) && objMap.get('productCode') != null && !String.valueOf(objMap.get('productCode')).startsWithIgnoreCase(productFamily))
                {
                    productOfferingList.remove(i);
                }
            }
        }
        catch(Exception e)
        {
            throw new PrecheckException(e);
        }
    }
    
    //Bandwidht comparision and Price Calcualtion
    public static List<MC_PreCheck_Result__c> compareBandwidhts(Map<integer,Object> priorityMap,List<Object> eachproductinfo,set<String> childNameSet,Map<String,Object> inMap){
        try{
        Map<String,Object> adjustmentMap = (Map<String,Object>)inMap.get('adjustmentMap');
        String pname = (String)inMap.get('pname');
        String mappedPCode = (String)inMap.get('mappedPCode');
        String servicepoint = (String)inMap.get('servicepoint');
        String objId = (String)inMap.get('objId');
        Map<String,String> premiseparentMap = (Map<String,String>)inMap.get('premiseparentMap');
    Map<String,String> errorMap = (Map<String,String>)inMap.get('ErrorCodeMap');

        
        list<integer> priorityList = new List<Integer>();
        priorityList.addAll(priorityMap.keySet());
        priorityList.sort();
        
        List<MC_PreCheck_Result__c> precheckResultList = new List<MC_PreCheck_Result__c>();        


        if(priorityList.size() > 0){
            for(integer priority : priorityList){
                Map<String,Object> conMap = (Map<String,Object>)priorityMap.get(priority); 
                for(Object Prodobj : eachproductinfo){
                    Map<String,Object> BWmap = (Map<String,Object>)Prodobj;               

                    // if priority one has 400000 kb. we insert all products less than or equat to 400000 kb
                    // if priority two has 800000 kb. we insert all products from more than 400000 and less than or equal to 800000
                    if(conMap.get('maxDownloadSpeed') != null && conMap.get('maxDownloadSpeed') != ''){
                        if((Integer.valueOf(BWmap.get('Bandwidth')) <= (Integer.valueOf(conMap.get('maxDownloadSpeed')) * 1000))  && Integer.valueOf(conMap.get('returnCode'))==0){                                    
                            if(childNameSet.contains((String)BWmap.get('Name'))){                                        
                                //-------------price adjustment start----------------
                                //we do price adjustment only if avg flag is true
                                Decimal priceAdj;
                                //Defect Fix-9555-Fix starting point
                                string fetchTechnologyName= (string)conmap.get('technologyName');
                                string fetchProductCode = (String)BWmap.get('ProductCode');
                                boolean fttxTechnologyName = false;
                                
                                //added for b2b broadband start also
                                if(fetchTechnologyName.contains('FTTX') || fetchProductCode.startsWith('CO-BBSTART') || fetchProductCode.startsWith('B2B-BBF')){
                                fttxTechnologyName = true;
                                }
                                if(fttxTechnologyName == false){
                                    if(conMap.get('weightFactor') != null){
                                        String adjKey = String.valueOf(conMap.get('weightFactor'));
                                        Boolean priceAvgFlag = Boolean.valueOf(BWmap.get('priceAverageFlag'));
                                        if(adjKey != null && priceAvgFlag && adjustmentMap.get(adjKey) != null){
                                            Map<String,Object> tempMap = (Map<String,Object>)adjustmentMap.get(adjKey);
                                            if(Integer.valueOf(tempMap.get(pname)) != null){
                                                priceAdj = Integer.valueOf(BWmap.get('Amount'))+Integer.valueOf(tempMap.get(pname));
                                            }
                                        }
                                    }
                                } else
                                if(fttxTechnologyName == true){
                                    Boolean priceAvgFlag = Boolean.valueOf(BWmap.get('priceAverageFlag'));
                                    if(BWmap.containsKey('FTTXAmount') && priceAvgFlag)
                                    {
                                        priceAdj = Integer.valueOf(BWmap.get('FTTXAmount'));
                                    }
                                    else
                                    {
                                        priceAdj = Integer.valueOf(BWmap.get('Amount'));
                                    }
                                   /*if(priceAvgFlag){
                                      
                                   }
                                    */
                                }//Defect Fix-9555-Fix Ending point                            
                                //-------------price adjustment end------------------
                                String errorMessage;
                                if (conMap.get('returnCode') != null){
                                  errorMessage = errorMap.get(String.valueOf(conMap.get('returnCode')));
                                }
                                MC_PreCheck_Result__c precheckResult = preparePrecheckRecord(BWmap,conMap,priceAdj,(String)premiseparentMap.get(mappedPCode),servicepoint,objId,errorMessage);                                        
                                precheckResultList.add(precheckResult);
                                childNameSet.remove((String)BWmap.get('Name')); // to remove duplicates from insertion
                            }
                        }    
                    }            
                }            
            }
        }
        return precheckResultList;
    } catch(Exception e)
        {
            throw new PrecheckException(e);
        }
    }
    // creating Precheck records
    public static MC_PreCheck_Result__c preparePrecheckRecord(Map<String,Object> BWmap, Map<String,Object> conMap, Decimal priceAdj,String parentId,String servicepoint,String objId, String errorMessage){
        try{
        String adjErrorMsg = System.label.CO_ErrorInAdjustment;
        MC_PreCheck_Result__c precheckResult = new MC_PreCheck_Result__c();
        precheckResult.Name = (String)BWmap.get('Name');        
        precheckResult.MC_PriceAverageFlag__c = Boolean.valueOf(BWmap.get('priceAverageFlag'));                                 
        precheckResult.MC_Product_Code__c = (String)BWmap.get('ProductCode');
        precheckResult.MC_Product_Bandwidth__c = (Integer)BWmap.get('Bandwidth');     
        
        if(conMap != null){
            /*if(priceAdj == null){
                precheckResult.Price__c = (Decimal)BWmap.get('Amount');

            }else*/  
            if(priceAdj < 0 || priceAdj == null){
                precheckResult.Price__c = 0;
            }
            else {
                precheckResult.Price__c = priceAdj;
            }
            
            precheckResult.MC_QoS__c = (String)conMap.get('maxQos');
            if(conMap.get('offerSla') != null){
                precheckResult.MC_Max_SLA__c = (String)conMap.get('offerSla');
            }
            else if(conMap.get('skanovaSla') != null){
                precheckResult.MC_Max_SLA__c = (String)conMap.get('skanovaSla');
            }
            else{
                precheckResult.MC_Max_SLA__c = (String)conMap.get('maxSla');
            }
            precheckResult.MC_PriceParameter__c = conMap.get('weightFactor') != null ? (String)conMap.get('weightFactor') : null;
            precheckResult.MC_Max_Bandwidth__c = conMap.get('maxDownloadSpeed') != null ? (Integer.valueOf(conMap.get('maxDownloadSpeed')) * 1000) : null;
            precheckResult.MC_Max_UploadSpeed__c = conMap.get('maxUploadSpeed') != null ? (Integer.valueOf(conMap.get('maxUploadSpeed')) * 1000) : null;
			//precheckResult.MC_Reference_Number__c = conMap.get('referenceNumber') != null ? (String)conMap.get('referenceNumber') : null;
            precheckResult.MC_Delivery_Time__c = conMap.get('deliveryDaysSkanova') != null ? (String)conMap.get('deliveryDaysSkanova') : null;
			precheckResult.MC_SLA_Availability__c = conMap.get('catalogueSla') != null ? (String)conMap.get('catalogueSla') : null;
            if(!isSLAC4 && (String)conMap.get('catalogueSla') == 'C4h'){
                isSLAC4 = true;
            }
            precheckResult.MC_Delivery_Type__c = conMap.get('ServiceSpecification') != null ? (String)conMap.get('ServiceSpecification') : null;//'contype';
        //    precheckResult.MC_ReturnCodeMessage__c = conMap.get('returnErrorMessage') != null ? (String)conMap.get('returnErrorMessage') : null;
      
            //Defect Fix-9555-Fix Starting point 
            string fetchTechnologyName= (string)conmap.get('technologyName');
            string fetchProductCode = (String)BWmap.get('ProductCode');
            boolean fttxTechnologyName = false;
            //Added for B2B product start
            if(fetchTechnologyName.contains('FTTX') || fetchProductCode!= 'CO-BBSTART' || fetchProductCode!= 'CO-INTERNET-START' ){  
              fttxTechnologyName = true;
            }
            if(fttxTechnologyName == false){
              if(conMap.get('returnCode') != null){
                if(conMap.get('returnCode') == '0' && ((priceAdj < 0 || priceAdj == null) || (conMap.get('weightFactor') == null || conMap.get('weightFactor') == '')) ){
                    precheckResult.MC_ReturnCode__c = '988';
                    precheckResult.MC_ReturnCodeMessage__c = adjErrorMsg;
                }else if(conMap.get('returnCode') != '0' && ((priceAdj < 0 || priceAdj == null) || (conMap.get('weightFactor') == null || conMap.get('weightFactor') == '')) ){
                    precheckResult.MC_ReturnCode__c = (String)conMap.get('returnCode')+', '+'988';
                    precheckResult.MC_ReturnCodeMessage__c = adjErrorMsg;
                }else {
                    precheckResult.MC_ReturnCode__c = (String)conMap.get('returnCode');
                    if(errorMessage != null){
                      precheckResult.MC_ReturnCodeMessage__c = errorMessage;
                    }
                }
              }else{
                precheckResult.MC_ReturnCode__c = '0';
                precheckResult.MC_ReturnCodeMessage__c = 'OK';
              }
            }else
            if(fttxTechnologyName == true){
                precheckResult.MC_ReturnCode__c = '0';
                precheckResult.MC_ReturnCodeMessage__c = 'OK';
            }//Defect Fix-9555-Fix Ending point 
                 
            precheckResult.MC_AccessType_Name__c = (String)conMap.get('accessTypeName');
            precheckResult.MC_AccessType_Id__c = (String)conMap.get('accessTypeId');
            precheckResult.MC_Technology_Name__c = (String)conMap.get('technologyName');
            precheckResult.MC_TechnologyId__c = (String)conMap.get('technologyId');
            if(conMap.get('bandwidthGreaterThanOneGbps') != null && conMap.get('bandwidthGreaterThanOneGbps') != ''){
                precheckResult.MC_Priority_Greater_Than_1GBPS__c = Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps'));
            }
            if(conMap.get('priority') != null && conMap.get('priority') != ''){
                precheckResult.MC_Priority_Less_Than_1GBPS__c = Integer.valueOf(conMap.get('priority'));
            }
            precheckResult.MC_LineType__c = (String)conMap.get('lineType');
            precheckResult.MC_AgreementId__c = (String)conMap.get('agreementId');
            precheckResult.MC_ContractType__c = (String)conMap.get('contractType');
            precheckResult.MC_LanType__c = (String)conMap.get('lanType');
            precheckResult.MC_Fiber_Length_to_Station__c = (String)conMap.get('cableLength');
            precheckResult.MC_Number_Of_Fiber_Pairs__c = (String)conMap.get('freeFibers');
            precheckResult.MC_Fixed_Price_Area__c = (String)conMap.get('fixedPriceArea');
        }
        else if(BWmap.get('errorCode') != null){
            precheckResult.MC_ReturnCode__c = '9998';
            precheckResult.MC_ReturnCodeMessage__c = System.label.CO_ErrorBundleMiss;
        }
        else{
            precheckResult.Price__c = 0;
            precheckResult.MC_ReturnCode__c = '9999';
            precheckResult.MC_ReturnCodeMessage__c = 'Hera förfrågan krävs';
        }
        precheckResult.RecordTypeId = Schema.SObjectType.MC_PreCheck_Result__c.getRecordTypeInfosByName().get('Netfraga Response').getRecordTypeId();
        precheckResult.MC_Parent_Info__c = parentId;
        precheckResult.Service_Point__c = servicepoint;
        precheckResult.Opportunity__c = objId;
        
        return precheckResult;
    } catch(Exception e)
        {
            throw new PrecheckException(e);
        }
    }
    // For Storing netfraga response all Info.
    public static void insertPrecheckResponse(List<Object> productOfferingList,String spointId,String objId, Map<String,String> ErrorCodeMap, Map<String,String> nameMap){
        try{
        List<MC_PreCheck_Result__c> precheckResultList = new List<MC_PreCheck_Result__c>();
        // insert all parents to DB
        for(Object obj : productOfferingList){
            MC_PreCheck_Result__c precheckResult = new MC_PreCheck_Result__c();
            Map<String,Object> eachproduct = (Map<String,Object>)obj; 
            precheckResult.Name = (String)eachproduct.get('productName');
            precheckResult.RecordTypeId = Schema.SObjectType.MC_PreCheck_Result__c.getRecordTypeInfosByName().get('PrecheckResponse').getRecordTypeId();
            precheckResult.Service_Point__c = spointId;
            precheckResult.Opportunity__c = objId;
            precheckResult.MC_Product_Code__c =  (String)eachproduct.get('productCode');
            precheckResult.MC_Product_Name__c =  (String)nameMap.get((String)eachproduct.get('productName'));
            precheckResultList.add(precheckResult);
        }
        if(precheckResultList.size() > 0){
            
            try{
                insert precheckResultList;
            }catch(Exception e) { 
                System.debug('Exception'+e);
            }
        }
        precheckResultList.clear();
        Map<String,String> precheckMap = new Map<String,String>();
        for(MC_PreCheck_Result__c parentprecheck : [select id,Name from MC_PreCheck_Result__c where Opportunity__c=:objId and Service_Point__c=:spointId and RecordType.Name ='PrecheckResponse']){
            precheckMap.put(parentprecheck.Name, parentprecheck.id);
        }
        // insertion of all response from DB using above inserted as parent
        for(Object obj : productOfferingList){
            Map<String,Object> eachproduct = (Map<String,Object>)obj; 
            
            List<Object> connectionType = (List<Object>)eachproduct.get('deliveryOptions');
            for(Object conObj : connectionType){
                Map<String,Object> conMap = (Map<String,Object>)conObj; 
                MC_PreCheck_Result__c precheckResult = new MC_PreCheck_Result__c();
                precheckResult.Name = (String)eachproduct.get('productName');
                precheckResult.MC_QoS__c = (String)conMap.get('maxQos');
                if(conMap.get('offerSla') != null){
                    precheckResult.MC_Max_SLA__c = (String)conMap.get('offerSla');
                }
                else if(conMap.get('skanovaSla') != null){
                    precheckResult.MC_Max_SLA__c = (String)conMap.get('skanovaSla');
                }
                else{
                    precheckResult.MC_Max_SLA__c = (String)conMap.get('maxSla');
                }
                precheckResult.MC_PriceParameter__c = (String)conMap.get('weightFactor');
                if(conMap.get('maxDownloadSpeed') != null && conMap.get('maxDownloadSpeed') != ''){
                    precheckResult.MC_Max_Bandwidth__c = Integer.valueOf(conMap.get('maxDownloadSpeed'));
                }
                if(conMap.get('maxUploadSpeed') != null && conMap.get('maxUploadSpeed') != ''){
                    precheckResult.MC_Max_UploadSpeed__c = Integer.valueOf(conMap.get('maxUploadSpeed'));
                }
                precheckResult.MC_SLA_Availability__c = conMap.get('catalogueSla') != null ? (String)conMap.get('catalogueSla') : null; // added piece of code for SLA c4
                precheckResult.MC_Delivery_Time__c = conMap.get('deliveryDaysSkanova') != null ? (String)conMap.get('deliveryDaysSkanova') : null;

                precheckResult.MC_Delivery_Type__c = conMap.get('ServiceSpecification') != null ? (String)conMap.get('ServiceSpecification') : null;//'contype';
             //   precheckResult.MC_Reference_Number__c = conMap.get('referenceNumber') != null ? (String)conMap.get('referenceNumber') : null;
               // precheckResult.MC_ReturnCodeMessage__c = (String)conMap.get('returnErrorMessage');
                precheckResult.MC_ReturnCodeMessage__c = conMap.get('returnCode') != null ? ErrorCodeMap.get((String)conMap.get('returnCode')) : (String)conMap.get('returnErrorMessage');
                precheckResult.MC_ReturnCode__c = (String)conMap.get('returnCode');
                precheckResult.MC_AccessType_Name__c = (String)conMap.get('accessTypeName');
                precheckResult.MC_AccessType_Id__c = (String)conMap.get('accessTypeId');
                precheckResult.MC_Technology_Name__c = (String)conMap.get('technologyName');
                precheckResult.MC_TechnologyId__c = (String)conMap.get('technologyId');
                if(conMap.get('bandwidthGreaterThanOneGbps') != null && conMap.get('bandwidthGreaterThanOneGbps') != ''){
                    precheckResult.MC_Priority_Greater_Than_1GBPS__c = Integer.valueOf(conMap.get('bandwidthGreaterThanOneGbps'));
                }
                if(conMap.get('priority') != null && conMap.get('priority') != ''){
                    precheckResult.MC_Priority_Less_Than_1GBPS__c = Integer.valueOf(conMap.get('priority'));
                }
                precheckResult.MC_LineType__c = (String)conMap.get('lineType');
                precheckResult.MC_AgreementId__c = (String)conMap.get('agreementId');
                precheckResult.MC_ContractType__c = (String)conMap.get('contractType');
                precheckResult.MC_LanType__c = (String)conMap.get('lanType');
                precheckResult.MC_Fiber_Length_to_Station__c = (String)conMap.get('cableLength');
                precheckResult.MC_Number_Of_Fiber_Pairs__c = (String)conMap.get('freeFibers');
                precheckResult.MC_Fixed_Price_Area__c = (String)conMap.get('fixedPriceArea');
                precheckResult.Service_Point__c = spointId;
                precheckResult.Opportunity__c = objId;
                precheckResult.MC_Parent_Info__c = precheckMap.get((String)eachproduct.get('productName'));
                precheckResult.RecordTypeId = Schema.SObjectType.MC_PreCheck_Result__c.getRecordTypeInfosByName().get('PrecheckResponse').getRecordTypeId();
                precheckResultList.add(precheckResult);
            }
        }
        if(precheckResultList.size() > 0){
            try{
                insert precheckResultList;
            }catch(Exception e) { 
                System.debug('Exception'+e);
            }
            
        }
    } catch(Exception e)
        {
            throw new PrecheckException(e);
        }
    }
    // to merge GA and LA locations
    public static void combineServicepoints(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{
        List<Object> combinedList = new List<Object>();
        List<Object> mainList = new List<Object>();
        List<object> subList = new List<object>();
        List<Map<String,Object>> finalList = new List<Map<String,Object>>();

        List<object> responseList = (List<object>)inputMap.get('ListAction1');   
        // Combine serive points in order GA then LA
        if(responseList.size() > 0){
            for(object resp : responseList){
                Map<String,object> respMap = (Map<String,object>)resp;
                if(respMap.get('main') != null){
                    mainList.add((Object)respMap.get('main'));//GA
                }
                if(respMap.get('subAddress') != null){
                    try{
                        subList.addAll((List<object>)respMap.get('subAddress'));//LA
                    }catch(Exception e){
                        subList.add(respMap.get('subAddress'));

                    }
                }
            }     
        }   
        combinedList.addAll(mainList);
        combinedList.addAll(subList);
        // Checking for FTTX flag
        for(object eachSP : combinedList){
            Map<String,object> respMap = (Map<String,object>)eachSP;       


            if((String)respMap.get('SiteDescription') != null){
                String SiteDescription = (String)respMap.get('SiteDescription');
                Map<String,Object> siteDesMap = new Map<String,Object>();
                siteDesMap = (Map<String, Object>)JSON.deserializeUntyped(SiteDescription);
                if(siteDesMap.get('fttx_flag') == 'Y'){
                    respMap.put('FTTxFlag',true);                    
                }else{
                    respMap.put('FTTxFlag',false);                    
                }
                respMap.remove('SiteDescription');
            }           
            finalList.add(respMap);
        }
        outMap.put('ServicePointsDetail',finalList);
    } catch(Exception e)
        {
            throw new PrecheckException(e);
        }
    }
  // transform servicepoint response
    public Static void transformServicepoint(Map<String,Object> inputMap, Map<String,Object> outMap){
        List<string> slaC4AvailableProductsList = System.label.MC_SLA_C4_available_products.split(',');       
        try{
        Map<String,Object> transformOutput = (Map<String,Object>)inputMap.get('DataRaptorTransformAction2');        
        // Process Header Set from seleted family from Precheck View 
        set<String> headerSet = new set<String>();
        try{
            List<Object> headerList = (List<Object>)inputMap.get('Headers');
            for(object obj : headerList){
                Map<String,Object> headerMap = (Map<String,Object>)obj;
                headerSet.add((String)headerMap.get('productCode'));
            }
        }catch (exception e){
            Map<String,Object> headerMap = (Map<String,Object>)inputMap.get('Headers');    
            headerSet.add((String)headerMap.get('productCode'));
        }
        // Site details, Service point details
        List<Object> siteDetailList = (List<Object>)inputMap.get('Sites');
        Map<String,Object> siteSerivePointIdMap = new Map<String,Object>();
        Map<String,String> servicePointNumberIdMap = new Map<String,String>();
        Map<String,Boolean> precheckProcessedSerivePointIdMap = new Map<String,Boolean>();
        for(Object eachSite : siteDetailList){
            Map<String,Object> siteMap = (Map<String,object>)(eachSite);
            siteSerivePointIdMap.put((string)siteMap.get('Id'),siteMap.get('SiteAddress'));
            servicePointNumberIdMap.put((string)siteMap.get('Id'),(String)siteMap.get('ServicePoint'));
            precheckProcessedSerivePointIdMap.put((string)siteMap.get('Id'),(Boolean)siteMap.get('PrecheckProcessed'));
        }
        //parent info
        List<Object> parentList = (List<Object>)transformOutput.get('parent');
        Map<String,Object> parentSerivePointIdMap = new Map<String,Object>();
        for(Object eachParent : parentList){
            Map<String,Object> eachParentMap = (Map<String,object>)(eachParent);
            String spointId = (String)eachParentMap.get('ServicePointId');
            if(headerSet.contains((String)eachParentMap.get('ProductCode'))){
                if(parentSerivePointIdMap.get(spointId) != null){
                    List<Object> eachParentList = new List<Object>();
                    List<Object> mapParentList = (List<Object>)parentSerivePointIdMap.get(spointId);
                    for(object obj : mapParentList){
                        eachParentList.add(obj);
                    }
                    eachParentList.add(eachParentMap);
                    parentSerivePointIdMap.put(spointId,eachParentList);
                }else{
                    List<Object> eachParentList = new List<Object>();
                    eachParentList.add(eachParentMap);
                    parentSerivePointIdMap.put(spointId,eachParentList);
                }            
            }
        }
        List<Object> productBW2List = (List<Object>)transformOutput.get('productBW2');
        Map<String,Object> productBW2SerivePointIdMap = new Map<String,Object>();
        // process for second bandwidth selected
        for(Object eachprod : productBW2List){
            Map<String,Object> prodMap = (Map<String,Object>)eachprod;
            String parentId = (String)prodMap.get('ParentId');
            String ServicePointId = (String)prodMap.get('ServicePointId');            
            if(productBW2SerivePointIdMap.get(ServicePointId) != null){
                Map<String,Object> parentProdMap = (Map<String,Object>)productBW2SerivePointIdMap.get(ServicePointId);
                if(parentProdMap.get(parentId) != null){
                    List<Object> eachProductList = new List<Object>();
                    eachProductList.add(parentProdMap.get(parentId));
                    if(prodMap != null){
                        Map<String,Object> infoMap = (Map<String,Object>)prodMap.get('info');
                        if(Integer.valueOf(infoMap.get('ReturnCode')) == 9999){
                            infoMap.put('isHera',true);
                            prodMap.put('info',infoMap);                           
                        }
                    }
                    eachProductList.add(prodMap);
                    parentProdMap.put(parentId,eachProductList);
                    productBW2SerivePointIdMap.put(ServicePointId,parentProdMap);
                }
                else{
                    if(prodMap != null){
                        Map<String,Object> infoMap = (Map<String,Object>)prodMap.get('info');
                        // if code returned as empty or 9999 send isemtpy flag
                        if(Integer.valueOf(infoMap.get('ReturnCode')) == 9999){
                            infoMap.put('isHera',true);
                            prodMap.put('info',infoMap);
                        }
                        parentProdMap.put(parentId,prodMap);
                        productBW2SerivePointIdMap.put(ServicePointId,parentProdMap);
                    }
                }
            }else{
                if(prodMap != null){
                    Map<String,Object> infoMap = (Map<String,Object>)prodMap.get('info');
                    if(Integer.valueOf(infoMap.get('ReturnCode')) == 9999){
                        infoMap.put('isHera',true);
                        prodMap.put('info',infoMap);
                    } 
                    Map<String,Object> parentProdMap = new Map<String,Object>();
                    parentProdMap.put(parentId,prodMap);
                    productBW2SerivePointIdMap.put(ServicePointId,parentProdMap);
                }
            }
        }      
        List<Object> productBW1List = (List<Object>)transformOutput.get('productBW1');
        Map<String,Object> productBW1SerivePointIdMap = new Map<String,Object>();
        // Process for bandwidth one selected on UI        
        for(Object eachprod : productBW1List){
            Map<String,Object> prodMap = (Map<String,Object>)eachprod;
            String parentId = (String)prodMap.get('ParentId');
            String ServicePointId = (String)prodMap.get('ServicePointId');            
            if(productBW1SerivePointIdMap.get(ServicePointId) != null){
                Map<String,Object> parentProdMap = (Map<String,Object>)productBW1SerivePointIdMap.get(ServicePointId);
                if(parentProdMap.get(parentId) != null){
                    List<Object> eachProductList = new List<Object>();
                    eachProductList.add(parentProdMap.get(parentId));
                    if(prodMap != null){
                        Map<String,Object> infoMap = (Map<String,Object>)prodMap.get('info');
                        if(Integer.valueOf(infoMap.get('ReturnCode')) == 9999){
                            infoMap.put('isHera',true);
                            prodMap.put('info',infoMap);
                        }
                    }
                    eachProductList.add(prodMap);
                    parentProdMap.put(parentId,eachProductList);
                    productBW1SerivePointIdMap.put(ServicePointId,parentProdMap);
                }
                else{
                    if(prodMap != null){
                        Map<String,Object> infoMap = (Map<String,Object>)prodMap.get('info');
                        if(Integer.valueOf(infoMap.get('ReturnCode')) == 9999){
                            infoMap.put('isHera',true);
                            prodMap.put('info',infoMap);
                        }
                        parentProdMap.put(parentId,prodMap);
                        productBW1SerivePointIdMap.put(ServicePointId,parentProdMap);
                    }
                }
            }else{
                if(prodMap != null){
                    Map<String,Object> infoMap = (Map<String,Object>)prodMap.get('info');
                    if(Integer.valueOf(infoMap.get('ReturnCode')) == 9999){
                        infoMap.put('isHera',true);
                        prodMap.put('info',infoMap);
                    } 
                    Map<String,Object> parentProdMap = new Map<String,Object>();
                    parentProdMap.put(parentId,prodMap);
                    productBW1SerivePointIdMap.put(ServicePointId,parentProdMap);
                }
            }
        }        
        //get Average Prices map then name,amount pairs in Map
        Map<String,Decimal> priceMap = new Map<String,Decimal>();    
        Map<String,Decimal> finalPriceMap = new Map<String,Decimal>();
        List<Object> avgPriceList =new List<Object>();
        if(inputMap.get('AveragePrice') != null && inputMap.get('AveragePrice') != '') {
           avgPriceList = (List<Object>)inputMap.get('AveragePrice');
        }
        if(avgPriceList.size() > 0){
            for(Object obj: avgPriceList){
                Map<String,Object> eachProduct = (Map<String,Object>)obj;
                priceMap.put((String)eachProduct.get('Name'),(Decimal)eachProduct.get('Price__c'));
            }
        }        
        // Combine response to Single one which will go to UI        
        List<Object> precheckResultList = new List<Object>();
        for(String spointId: servicePointNumberIdMap.keyset()){
            Map<String,Object> finalMap = new Map<String,Object>();
            List<Object> parentList1 = (List<Object>)parentSerivePointIdMap.get(spointId);
            Map<String,Object> product1Map = (Map<String,Object>)productBW1SerivePointIdMap.get(spointId);
            Map<String,Object> product2Map = (Map<String,Object>)productBW2SerivePointIdMap.get(spointId);
            Map<String,Object> siteMap = new Map<String,Object>();
            if(siteSerivePointIdMap.get(spointId) != null){
                siteMap =  (Map<String,Object>)siteSerivePointIdMap.get(spointId);
            }            
            List<Object> productList = new List<Object>();          
            if(parentList1 != null){
                for(Object eachparent : parentList1){
                    Map<String,Object> parentProdMap = new Map<String,Object>();
                    Map<String,Object> eachParentMap = (Map<String,Object>)eachparent;
                    String parentKey = (String)eachParentMap.get('Id');
                    String parentName = (String)eachParentMap.get('Name');
                    String parentCode = (String)eachParentMap.get('ProductCode');
                    List<Object> dataList = new List<Object>();
                   
                    try{
                    if(product1Map.get(parentKey) != null){
                        Map<String,Object> dataMap = new Map<String,Object>();
                        Map<String,Object> prod1Map = (Map<String,Object>)product1Map.get(parentKey);
                        Map<String,Object> infoMap = (Map<String,Object>)prod1Map.get('info');
                        //checking the sla products contains some sla value or not if not showing Sla avaialbility as not available
                        if(slaC4AvailableProductsList.contains(parentCode)){
                            if(infoMap.get('SLAAvailability') == null){
                                infoMap.put('SLAAvailability','Not Available');
                            }
                        }else{
                            infoMap.put('SLAAvailability',null);
                        }
                        dataMap.put('info',infoMap);                        
                        if(prod1Map.get('Name') != null){
                            dataMap.put('bandwidth',(String)prod1Map.get('Name'));
                            if(priceMap.get((String)prod1Map.get('Name')) != null){
                                finalPriceMap.put(parentName+'price1',(decimal)priceMap.get((String)prod1Map.get('Name')));
                            }
                        }
                        dataList.add(dataMap);
                    }
                    else{
                        Map<String,Object> infoMap = new Map<String,Object>();
                        Map<String,Object> dataMap = new Map<String,Object>();
                        infoMap.put('isEmpty', true);
                        dataMap.put('info',infoMap);
                        dataList.add(dataMap);
                    }}
                    catch(exception e){
                        Map<String,Object> infoMap = new Map<String,Object>();
                        Map<String,Object> dataMap = new Map<String,Object>();
                        infoMap.put('isEmpty', true);
                        dataMap.put('info',infoMap);
                        dataList.add(dataMap);
                    }
                    try{
                    if(product2Map.get(parentKey) != null){
                        Map<String,Object> dataMap = new Map<String,Object>();
                        Map<String,Object> prod2Map = (Map<String,Object>)product2Map.get(parentKey);
                        Map<String,Object> infoMap = (Map<String,Object>)prod2Map.get('info');
                       //checking the sla products contains some sla value or not if not showing Sla avaialbility as not available  
                        if(slaC4AvailableProductsList.contains(parentCode)){
                            if(infoMap.get('SLAAvailability') == null){
                                infoMap.put('SLAAvailability','Not Available');
                            }
                        }else{
                            infoMap.put('SLAAvailability',null);
                        }
                        dataMap.put('info',infoMap);
                        if(prod2Map.get('Name') != null){
                            dataMap.put('bandwidth',(String)prod2Map.get('Name'));
                            if(priceMap.get((String)prod2Map.get('Name')) != null){
                                finalPriceMap.put(parentName+'price2',(decimal)priceMap.get((String)prod2Map.get('Name')));
                            }
                        }
                        dataList.add(dataMap);
                    }
                    else{
                        Map<String,Object> infoMap = new Map<String,Object>();
                        Map<String,Object> dataMap = new Map<String,Object>();
                        infoMap.put('isEmpty', true);
                        dataMap.put('info',infoMap);
                        dataList.add(dataMap);
                    }
                    }catch(exception e){
                        Map<String,Object> infoMap = new Map<String,Object>();
                        Map<String,Object> dataMap = new Map<String,Object>();
                        System.debug('exception-->'+e.getMessage());
                        System.debug('exception2-->'+e.getStackTraceString());
                        infoMap.put('isEmpty', true);
                        dataMap.put('info',infoMap);
                        dataList.add(dataMap);
                    }
                    parentProdMap.put('Data',dataList);                    
                    parentProdMap.put('productName',parentName);
                    parentProdMap.put('parentCode',parentCode);
                    
                    productList.add(parentProdMap);
                }
            }            
            List<Object> finalProductList = new List<Object>();
            for(String headerProd : headerSet){
                for(Object parentprodObj : productList){
                    Map<String,Object> parentSortMap = (Map<String,Object>)parentprodObj;
                    if(parentSortMap.get('parentCode') == headerProd){
                        finalProductList.add(parentprodObj);
                    }
                }
            }            
            finalMap.put('Products',finalProductList);
            finalMap.put('Id',spointId);
            finalMap.put('ServicePoint',servicePointNumberIdMap.get(spointId));
            finalMap.put('PrecheckProcessed',precheckProcessedSerivePointIdMap.get(spointId));
            finalMap.put('SiteAddress',siteMap);
            finalMap.put('AccountId',inputMap.get('AccountId'));            
            precheckResultList.add(finalMap);
        }
        outMap.put('finalavgprices',finalPriceMap);
        outMap.put('finalMap',precheckResultList);
    } catch(Exception e)
        {
            throw new PrecheckException(e);
        }
    }
    //delete existing precheck data
    public static void deletePrecheckData(Map<String,Object> inputMap){
        try{
        String oppId = (string)inputMap.get('OpportunityId');
        if(inputMap.containskey('fullPrecheck') && (Boolean)inputMap.get('fullPrecheck')== true){ // For full precheck
            delete [Select id,Name from MC_PreCheck_Result__c where Opportunity__c =: oppId]; 

        }else
        if(inputMap.containskey('fullPrecheck') && (Boolean)inputMap.get('fullPrecheck')== false){
            delete [Select id from MC_PreCheck_Result__c where RecordType.Name = 'AveragePrice' and Opportunity__c =:oppId];// Delete AveragePrice Precheck Records When click on Leveranskantroll Nya button for Incremental Precheck

        }
    } catch(Exception e)
        {
            throw new PrecheckException(e);
        }    
    }    
    //transform response from netfraga API
    public Static void precheckTransformResponse(Map<String,Object> inputMap, Map<String,Object> outMap){
        try{
        Map<String,Object> finalMap = new Map<String,Object>();
        Map<String,Object> poqliMap = (Map<String,Object>)inputMap.get('productOfferingQualificationItem');
        Map<String,Object> placeMap = (Map<String,Object>)poqliMap.get('place');      
        finalMap.put('place',(String)placeMap.get('id'));
        finalMap.put('country',(String)placeMap.get('country'));
        List<Object> productOfferingProposalList  = (List<Object>) poqliMap.get('productOfferingProposals');
        Map<String,Object> productProposalMap = new Map<String,Object>();
        Map<String,Object> productInfoMap = new Map<String,Object>();
        if(productOfferingProposalList != null && productOfferingProposalList.size() > 0){
            for(Object pOfferProp : productOfferingProposalList){
                
                Map<String,Object> pOfferPropMap = (Map<String,Object>)pOfferProp;
                List<Object> deliveryOptionsList = new List<Object>();
                List<Object> pOfferQualificationItemList = (List<Object>)pOfferPropMap.get('productOfferingQualificationItems');
                if(pOfferQualificationItemList.size() > 0){
                    for(Object pOfferQual : pOfferQualificationItemList){
                        Map<String,Object> pOfferQualMap = (Map<String,Object>)pOfferQual;
                        List<Object> productOfferingCharacteristicsList = (List<Object>)pOfferQualMap.get('productOfferingCharacteristics');
                        if(productOfferingCharacteristicsList.size() > 0){
                            for(Object pOfferChar : productOfferingCharacteristicsList){
                                Map<String,Object> pOfferCharMap = (Map<String,Object>)pOfferChar;
                                Map<String,Object> pOfferMap = new Map<String,Object>();
                                pOfferMap.put('Id',pOfferCharMap.get('id'));
                                pOfferMap.put('qualificationResult',pOfferCharMap.get('qualificationResult'));
                                if(pOfferCharMap.get('eligibilityUnavailabilityReason') != null){
                                    Map<String,Object> eligibilityUnavailabilityReasonMap = (Map<String,Object>)pOfferCharMap.get('eligibilityUnavailabilityReason');
                                    pOfferMap.put('returnCode',String.valueOf(eligibilityUnavailabilityReasonMap.get('code')));
                                    pOfferMap.put('returnErrorMessage',String.valueOf(eligibilityUnavailabilityReasonMap.get('label')));
                                    
                                }else{
                                    pOfferMap.put('returnCode','0');
                                    pOfferMap.put('returnErrorMessage','OK');
                                }
                                Map<String,Object> prioMap = (Map<String,Object>)pOfferCharMap.get('priority');
                                if(prioMap.get('bandwidthLessThanOneGbps') != null && prioMap.get('bandwidthLessThanOneGbps') != ''){
                                    pOfferMap.put('priority',prioMap.get('bandwidthLessThanOneGbps'));  
                                }
                                if(prioMap.get('bandwidthGreaterThanOneGbps') != null && prioMap.get('bandwidthGreaterThanOneGbps') != ''){
                                    pOfferMap.put('bandwidthGreaterThanOneGbps',prioMap.get('bandwidthGreaterThanOneGbps'));  
                                }
                                if(pOfferCharMap.get('priceAdjustmentValue') != null && pOfferCharMap.get('priceAdjustmentValue') != ''){
                                    pOfferMap.put('priceAdjustment',pOfferCharMap.get('priceAdjustmentValue')); 
                                }                                 
               
                                Map<String,Object> serviceMap = (Map<String,Object>)pOfferCharMap.get('service');
                                List<Object> servCharList = (List<Object>)serviceMap.get('serviceCharacteristics');
                                List<Object> serviceLevelSpecificationList = (List<Object>)serviceMap.get('serviceLevelSpecification');
                                for(Object servChar : serviceLevelSpecificationList){
                                    Map<String,Object> servCharMap = (Map<String,Object>)servChar;
                                    if(servCharMap.get('name') != null && servCharMap.get('value') != null){
                                        pOfferMap.put((String)servCharMap.get('name'),servCharMap.get('value'));
                                    }
                                }
                                for(Object servChar : servCharList){
                                    Map<String,Object> servCharMap = (Map<String,Object>)servChar;
                                    if(servCharMap.get('name') != null && servCharMap.get('value') != null){
                                        pOfferMap.put((String)servCharMap.get('name'),servCharMap.get('value'));
                                    }
                                    //LTAT-25055 : Manual Delivery Error from Netfraga Connected Office Precheck
                                    if(servCharMap.get('name')!= null && servCharMap.get('value') != null && servCharMap.get('name')=='deliveryType' && servCharMap.get('value') == 'MANUAL'){
                                         pOfferMap.put('returnCode','87');
                                    	 pOfferMap.put('returnErrorMessage','HERA case must be created in WOW.');
                                         pOfferMap.put('qualificationResult','unqualified');
                                    }
                                }
                                
                                Map<String,Object> categoryMap = (Map<String,Object>)serviceMap.get('category');                                
                                pOfferMap.put('lineType',categoryMap.get('accessLineType'));
                                Map<String,Object> technologyMap = (Map<String,Object>)categoryMap.get('accessTechnology');
                                pOfferMap.put('technologyId',technologyMap.get('id'));
                                pOfferMap.put('technologyName',technologyMap.get('name'));
                                Map<String,Object> accessTypeMap = (Map<String,Object>)categoryMap.get('accessType');
                                pOfferMap.put('accessTypeId',accessTypeMap.get('id'));
                                pOfferMap.put('accessTypeName',accessTypeMap.get('name'));
                                
                              //to Handle response for not getting max download speed in response and Qualified as true.
                                If((pOfferMap.get('maxDownloadSpeed') == null || pOfferMap.get('maxDownloadSpeed') == '') && pOfferMap.get('qualificationResult') == 'qualified'){
                                    pOfferMap.put('qualificationResult', 'unqualified');
                                }                                
                                
                                Map<String,Object> serviceSpecificationMap = (Map<String,Object>)serviceMap.get('serviceSpecification'); 
                                pOfferMap.put('ServiceSpecification',serviceSpecificationMap.get('name'));
                                deliveryOptionsList.add(pOfferMap);
                            }
                        }
                    }
                }
                if(productProposalMap.get((String)pOfferPropMap.get('productCode')) != null){
                    
                    List<object> deliveryOptionsFinalList = (List<Object>)productProposalMap.get((String)pOfferPropMap.get('productCode'));
                    deliveryOptionsFinalList.addAll(deliveryOptionsList);
                    productProposalMap.put((String)pOfferPropMap.get('productCode'),deliveryOptionsFinalList);
                }else{
                    
                    productProposalMap.put((String)pOfferPropMap.get('productCode'),deliveryOptionsList);
                }
                Map<String,Object> prodinfoMap1 = new Map<String,Object>();
                prodinfoMap1.put('productCode',pOfferPropMap.get('productCode'));
                prodinfoMap1.put('productName',pOfferPropMap.get('productName'));
                prodinfoMap1.put('Id',pOfferPropMap.get('id'));
                prodinfoMap1.put('qualificationResult',pOfferPropMap.get('qualificationResult'));
                productInfoMap.put((String)pOfferPropMap.get('productCode'),prodinfoMap1);
            }
        }
        productOfferingProposalList.clear();
        for(String key : productInfoMap.keySet()){
            Map<String,Object> deliveryOptionsFinalMap = new Map<String,Object>();
            Map<String,Object> prodinfoMap1 = (Map<String,Object>)productInfoMap.get(key);
            deliveryOptionsFinalMap.put('Id',prodinfoMap1.get('Id'));
            deliveryOptionsFinalMap.put('qualificationResult',prodinfoMap1.get('qualificationResult'));
            deliveryOptionsFinalMap.put('productName',prodinfoMap1.get('productName'));
            deliveryOptionsFinalMap.put('productCode',prodinfoMap1.get('productCode'));
            deliveryOptionsFinalMap.put('deliveryOptions',productProposalMap.get(key));
            productOfferingProposalList.add(deliveryOptionsFinalMap);
        }        
        finalMap.put('productOffering',productOfferingProposalList);
        outMap.put('productOfferingQualificationItem',finalMap);
    } catch(Exception e)
        {
            System.debug('e'+e.getStackTraceString());
            System.debug('e1'+e.getLineNumber());
            throw new PrecheckException(e);
        }  
    }    
    // update termination error from API
    public Static void UpdateTerminationError(Map<String,Object> inputMap, Map<String,Object> outMap){
        String accId = String.valueOf(inputMap.get('accId'));
        String servicePointNumber = String.valueOf(inputMap.get('servicePointNumber'));
        vlocity_cmt__ServicePoint__c servicepointobj = new vlocity_cmt__ServicePoint__c();
        servicepointobj = [Select Id,vlocity_cmt__ServicePointNumber__c, vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c,PrecheckProcessed__c  from vlocity_cmt__ServicePoint__c where vlocity_cmt__ServicePointNumber__c =:servicePointNumber and vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =: accId  limit 1];
        servicepointobj.MC_TerminationError_Id__c = String.valueOf(inputMap.get('terminationErrorId'));
        servicepointobj.MC_TerminationError_Value__c = String.valueOf(inputMap.get('terminationErrorValue'));
        servicepointobj.PrecheckProcessed__c  = false;
        try{
          update servicepointobj;
        } catch(Exception e)
        {
            throw new PrecheckException(e);
        }  
    }
    
    //Update ProductJson extracted with FTTX prices for specified products
    public static void matrixCall(map<String,Object> inputMap, map<String,Object> outputMap, map<String,Object> options){
        try{
        decimal priority;
        String matrixName = Boolean.valueOf(System.Label.B2BSolution_Toggle) ? 'PriceMatrix_B2BOrder%':'PriceMatrix_ConnectedOffice%';
        List<vlocity_cmt__CalculationMatrixRow__c> matrixRow = [Select Id, vlocity_cmt__InputData__c, vlocity_cmt__OutputDataLong__c , vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__Priority__c from vlocity_cmt__CalculationMatrixRow__c where vlocity_cmt__CalculationMatrixVersionId__r.name like :matrixName and vlocity_cmt__IsCalculationMatrixVersionEnabled__c =true and vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__EndDateTime__c= null and name != 'header'  order by vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__Priority__c desc];
        Map<String,Object> listPrice = new Map<String,Object>();
        Map<String,Object> FTTXPrice = new Map<String,Object>();
        if(matrixRow.size() > 0)
        {
            priority = matrixRow[0].vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__Priority__c;
        }
        List<vlocity_cmt__CalculationMatrixRow__c> matrixRowProcesses = new List<vlocity_cmt__CalculationMatrixRow__c>();
        for(vlocity_cmt__CalculationMatrixRow__c mrow:matrixRow)
        {
            if(mrow.vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__Priority__c == priority)
            {
                Map<String,Object> inputJson = (Map<String,Object>)json.deserializeUntyped(mrow.vlocity_cmt__InputData__c);
                Map<String,Object> outputJson = (Map<String,Object>)json.deserializeUntyped(mrow.vlocity_cmt__OutputDataLong__c);
                if(inputJson.get('Quantity') == '101-2500')                
                {
                    if(inputJson.get('Characteristic Value') == 'FTTX' )
                    {
                        FTTXPrice.put((String)inputJson.get('Source Product Code'), outputJson.get('MRC'));
                    }
                    else if ( inputJson.get('Characteristic Value') == 'CO')
                    {
                        listPrice.put((String)inputJson.get('Source Product Code'), outputJson.get('MRC'));
                    }                   
                }
            }           
        }
        List<Object> parentList = (List<Object>) inputMap.get('Parent');
        string productCode;
        if(parentList.size()>0)
        {
            for(Object parentObj: parentList)
            {
                Map<String,object> parent  = (Map<String,Object>) parentObj;
                if(parent.containsKey('Child'))
                {
                    List<Object> childProducts = (List<Object>) parent.get('Child');
                    for(Object childObj: childProducts)
                    {
                        Map<String,object> child  = (Map<String,Object>) childObj;
                        if(child.containskey('ProductCode'))
                        {
                            productCode = (String)child.get('ProductCode');
                            if(FTTXPrice.containsKey(productCode))
                            {
                                child.put('FTTXAmount',FTTXPrice.get(productCode));
                            }
                            if(listPrice.containsKey(productCode))
                            {
                                child.put('Amount',listPrice.get(productCode));
                            }
                        }
                    }
                }
            }
        }
        outputMap.put('Parent',parentList);
    }  catch(Exception e)
        {
            System.debug('e'+e.getStackTraceString());
            System.debug('e1'+e.getLineNumber());
            throw new PrecheckException(e);
        }
    }
    
    // To delete failed precheckData  and Site data
   @TestVisible private static void deleteSites(map<String,Object> inputMap, map<String,Object> outputMap){
        Set<String> servicePoints = new Set<String>();
       	String opportunityId = (String)inputMap.get('oppId');
       	String accountId = (String)inputMap.get('accountId');
       	for(object obj : (List<Object>)inputMap.get('servicepoints')){
        	string spoint =  String.valueOf(obj);
            servicePoints.add(spoint);
       	}
        if(servicePoints.size() > 0){
            try{                
                Delete [Select id from MC_PreCheck_Result__c where Service_Point__c in:servicePoints];
                Set<String> premisesId = new set<String>();
                List<vlocity_cmt__ServicePoint__c> servicePointList = new List<vlocity_cmt__ServicePoint__c>();
	            servicePointList = [Select id, PrecheckProcessed__c,vlocity_cmt__PremisesId__c from vlocity_cmt__ServicePoint__c where Id in:servicePoints  ];
	            if(servicePointList.size() > 0){
                	for(vlocity_cmt__ServicePoint__c s : servicePointList){
                    	premisesId.add(s.vlocity_cmt__PremisesId__c);
                	} 
                }
                Delete servicePointList;
                List<vlocity_cmt__ServicePoint__c> servicePointList1 = new List<vlocity_cmt__ServicePoint__c>();
	            servicePointList1 = [Select id, PrecheckProcessed__c,vlocity_cmt__PremisesId__c from vlocity_cmt__ServicePoint__c where vlocity_cmt__PremisesId__c in: premisesId];
                if(servicePointList.size() > 0){
                    for(vlocity_cmt__ServicePoint__c s : servicePointList1){
                    	premisesId.remove(s.vlocity_cmt__PremisesId__c);
                    }
                }
                Delete [Select Id from vlocity_cmt__Premises__c where Id in: premisesId];
                servicePointList.clear(); 
                servicePointList = [Select id from vlocity_cmt__ServicePoint__c where vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =: accountId ];
                if(servicePointList.size() < 1){
                    Delete [Select Id from MC_PreCheck_Result__c where Opportunity__c =: opportunityId];
                    Opportunity opp = new Opportunity();
                    opp.Id = opportunityId;
                    opp.IsPreChecked__c = false;
                    update opp;
                }
                
            }catch(Exception e){
                outputMap.put('Exception', e.getStackTraceString());
            }
        }
    }
}