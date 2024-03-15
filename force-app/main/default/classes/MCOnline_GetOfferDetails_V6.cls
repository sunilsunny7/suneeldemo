/* ______________________________________________________________________________________________________
* ******************************************************************************************************
* This class is the remote class of the getAgreementControlService API where the remote method 
GetAgreementControlServiceV3 and trim is called.
* This class is custom class for the standard GetOfferDetails.
* In this class, logic for Error Handling, Agreement Controller Services is present along with Triming 
of output response coming from Standard getOfferdetails response.
* The Output response will give all the products details present in the contract line items. 
* ______________________________________________________________________________________________________
* @author         Aparajita Banerjee
* @modifiedBy     
* @maintainedBy   
* @version        6.0
* @created        2022-04-07
* @modified
* ______________________________________________________________________________________________________
* ******************************************************************************************************
*/
global with sharing class MCOnline_GetOfferDetails_V6 implements vlocity_cmt.VlocityOpenInterface {
    
    public static Set<String> productFilter = new Set<String>();
    public static Map<String, String> OsubSubscriptionMap = new Map<String, String>();
    public static Map<String, String> OsubDiscountMap = new Map<String, String>();
    public static Final String APIFUNCTIONALITY= 'GetOffersDetails';
    public static List<MCOnline_Basket__c> parameters=new List<MCOnline_Basket__c>();
    public static String orderingFlag,trimMode,ContractId,ProductCode,CatalogCode,stdError,errorCode,catalog ;
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        if(methodName.equals('GetAgreementControlServiceV3')){ 
            Map<string,object> output = new Map<string,object>();
            if(inputMap.containsKey('Agreementid')){
                output = GetAgreementControlServiceV3(inputMap, outMap, options);
                if(!output.containsKey('ErrorResponse')){
                    agreementUpdate(inputMap, outMap);
                    if(inputMap.containskey('orderingFlag')){
                        orderingFlag = inputMap.get('orderingFlag')+'';
                        if(!string.isBlank(orderingFlag)){
                            Map<String,Object>result =(Map<String,Object>)(((Map<String,Object>)outMap.get('HA_GetOffersFromDgCommerce1')).get('result')); 
                            OrderingFlagFilter(result, orderingFlag);
                        }
                    }
                    trim(inputMap, outMap);          
                }
            }
            else{
                Map<String, Object> stdResponse = (Map<String, Object>)inputMap.get('HA_GetOffersFromDgCommerce1');
                Map<String,Object> result=(Map<String,Object>)stdResponse.get('result');
                if(inputMap.containskey('orderingFlag')){
                    orderingFlag = inputMap.get('orderingFlag')+'';
                    if(!string.isBlank(orderingFlag))
                        OrderingFlagFilter(result, orderingFlag);
                }
                stdResponse.put('success', true);
                stdResponse.put('basketAction','AddAfterConfig');
                outMap.put('HA_GetOffersFromDgCommerce1',stdResponse);
                trim(inputMap, outMap);
            }
            Map<String,Object> rootData=(Map<String,Object>)outMap.get('HA_GetOffersFromDgCommerce1');
            Map<String,Object> result= new Map<String,Object>();
            Map<String,Object> offerDetails= new Map<String,Object>();
            if(rootData != null){
                result=(Map<String,Object>)rootData.get('result');
                offerDetails=(Map<String,Object>)result.get('offerDetails');
            }
            if(inputMap != null && inputMap.containsKey('Agreementid')){
                offerDetails.put('agreementId', String.valueOf(inputMap.get('Agreementid')));
            }else{
                offerDetails.put('agreementId', null);
            }
            outMap.put('HA_GetOffersFromDgCommerce1',rootData);
        }
        return true;
    }
    /* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Overview:-
* This method is used for the trimming the output coming from Custom GetOfferDetails.
* This Method with reduce the number of line comming in the Json response in output.
* ___________________________________________________________________________________________________________
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************   
*/
    public static void trim(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        trimMode=inputMap.get('TrimMode')+'';
        if(trimMode!=null && trimMode.equalsIgnoreCase('No'))
        {
            return;    
        }
        List<String> errorList = new List<String>();
        try{
            String finalNodeslistStr=Label.MCONL_nodestoremove;
            List<String> finalNodeslistStrtolist = finalNodeslistStr.split(',');
            Set<String> finalNodes= new Set<String>(finalNodeslistStrtolist);
            Set<String> offercodeset=new Set<String>();
            vlocity_cmt__ContractLineItem__c agreeList;
            List<vlocity_cmt__CatalogProductRelationship__c> catalogproductrelationshiplst  = new List<vlocity_cmt__CatalogProductRelationship__c>();                 
            Map<String,Object> rootData=(Map<String,Object>)outMap.get('HA_GetOffersFromDgCommerce1');
            Map<String,Object> result=(Map<String,Object>)rootData.get('result');
            Map<String,Object> offerDetails=(Map<String,Object>)result.get('offerDetails');
            Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
            
            if(inputMap.containsKey('Agreementid')){
                catalogproductrelationshiplst=[ SELECT id,vlocity_cmt__CatalogId__r.vlocity_cmt__IsActive__c,vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c,Name FROM vlocity_cmt__CatalogProductRelationship__c WHERE vlocity_cmt__IsActive__c=true AND vlocity_cmt__CatalogId__c!=null WITH SECURITY_ENFORCED];
                for(vlocity_cmt__CatalogProductRelationship__c pr: catalogproductrelationshiplst)
                {
                    offercodeset.add(pr.Name);
                }
                List<Product2> productstore = [Select id, ProductCode, TeliaSE_Subscription_Type__c, Family from Product2 Where C2BC_Category__c in ('addonbundle','subscriptionbundle') AND C2BC_Subcategory__c IN ('mobilevoicesubscription','mobilebroadbandsubscription','datavolumes') AND TeliaSE_Object_Type_Name__c = 'Bundle' AND Family = 'Online Order' WITH SECURITY_ENFORCED];
                if(productstore.size()>0){
                    for(Product2 pp : productstore){
                        productFilter.add(pp.ProductCode);
                    }
                }
                
                ContractId=inputMap.get('Agreementid')+'';
                ProductCode = inputMap.get('ProductCode')+'';
                CatalogCode = inputMap.get('Catalog')+'';
                
                agreeList = [Select id, TeliaSE_SubsidisedVoice__c from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =:ContractId AND vlocity_cmt__ProductCode__c IN:offercodeset WITH SECURITY_ENFORCED LIMIT 1];
                removeNodes(offer,finalNodes,agreeList);
                if(OsubSubscriptionMap != null && OsubDiscountMap != null){
                    osubPriceMap(offer,finalNodes,agreeList, outMap, inputMap);
                }
                Map<String,Object> result1=(Map<String,Object>)result;
                if(CatalogCode.equalsIgnoreCase('SUBSCRIPTIONS'))
                {
                    if(inputMap.get('ProductCode') == null)
                    {
                        removeItems1(result1);
                    }else
                    {
                        removeItems(result1);
                    }
                }
                
            }
            else{
                removeNodes(offer,finalNodes,agreeList);
                if(OsubSubscriptionMap != null && OsubDiscountMap != null){
                    osubPriceMap(offer,finalNodes,agreeList, outMap, inputMap);
                }
            }
            
            outMap.put('HA_GetOffersFromDgCommerce1',rootData);
        }catch(Exception e){
            outMap.put('d',e.getMessage()+e.getLineNumber());
            errorList.add(e.getStackTraceString());
        }
    }
    /* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Overview:-
* This method is getting called in Trim Method.
* This is the method were the actual trimming is happening.
* ___________________________________________________________________________________________________________
* @param obj                           This object will contain offer node coming from inputMap.
* @param finalNodes                    Set of keys which are to be removed.
* @param agreeList                     This will contain the record for parent offer from contract line Items. 
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************   
*/
    public static void removeNodes(Object obj,Set<String> finalNodes, vlocity_cmt__ContractLineItem__c agreeList)
    {
        List<String> errorList = new List<String>();
        try{
            Map<String,Object> tempMap=(Map<String,Object>)obj;
            if(tempMap.containsKey('childProducts'))
            {
                List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
                for(Object obj3:childProducts)
                {
                    removeNodes(obj3,finalNodes,agreeList);
                }
            }
            if(tempMap.containsKey('AttributeCategory'))
            {
                Map<String,Object> tempMap1=(Map<String,Object>)tempMap.get('AttributeCategory');
                List<Object> attrRecords=(List<Object>)tempMap1.get('records');
                for(Object obj2:attrRecords)
                {
                    Map<String,Object> tempMap2=(Map<String,Object>)obj2;
                    Map<String,Object> tempMap3=(Map<String,Object>)tempMap2.get('productAttributes');
                    List<Object> prodAttrRecords=(List<Object>)tempMap3.get('records');
                    for(Object obj1:prodAttrRecords)
                    {
                        removeNodes(obj1,finalNodes,agreeList);
                        Map<String,Object> tempMap4=(Map<String,Object>)obj1;
                        if(tempMap4.containsKey('values')){
                            List<Object> prodAttrRecordsValue=(List<Object>)tempMap4.get('values');
                            for(Object obj12:prodAttrRecordsValue){
                                removeNodes(obj12,finalNodes,agreeList);
                            }
                        }
                        if(tempMap4.containsKey('userValues')){
                            if(String.valueOf(tempMap4.get('code')).equalsIgnoreCase('OsubSubscription')){
                                OsubSubscriptionMap.put(String.valueOf(tempMap.get('ProductCode')), String.valueOf(tempMap4.get('userValues')));
                            }else if(String.valueOf(tempMap4.get('code')).equalsIgnoreCase('OsubDiscount')){
                                OsubDiscountMap.put(String.valueOf(tempMap.get('ProductCode')), String.valueOf(tempMap4.get('userValues')));
                            }
                        }
                    }
                    removeNodes(tempMap3,finalNodes,agreeList);
                    if(prodAttrRecords.isEmpty()){
                        //tempMap.remove('AttributeCategory');
                    }
                }
            }
            /*____________________________________________________________________________________________________*/
            /* ************************************************************************************************** */
            /* MCONL-8910:- if the field TeliaSE_SubsidisedVoice__c in contractlineItem is No.
* Then it will display only zero value in Commitment_period attributes in getOfferDetails response.*/
            /* ************************************************************************************************** */
            
            if(agreeList!=null && String.valueOf(tempMap.get('label')) == 'Commitment_period')
            {
                if(tempMap.containsKey('values'))
                {
                    List<Object> prodAttrRecordsValue1=(List<Object>)tempMap.get('values');
                    Integer size = prodAttrRecordsValue1.size();
                    if(agreeList.TeliaSE_SubsidisedVoice__c == 'No')
                    {
                        for(Integer i = size - 1; i >= 0; i--)
                        {
                            Map<String, Object> value1 = (Map<String, Object>)prodAttrRecordsValue1.get(i);
                            if(String.valueOf(value1.get('label')) != '0'){
                                prodAttrRecordsValue1.remove(i);
                            }
                        }
                    }
                }
            }
            /* ************************************************************************************************ */
            /*------------End of logic required in MCONL-8910---------------------*/
            /* ************************************************************************************************ */
            /*__________________________________________________________________________________________________*/
            // tempMap will have the details of productAttributes node
            if(tempMap.containsKey('records'))
            {
                Integer totalsize=0;
                if(tempMap.containsKey('totalSize'))
                {
                    totalsize = Integer.valueOf(tempMap.get('totalSize'));
                }
                List<Object> prodAttrRecordsdel=(List<Object>)tempMap.get('records');
                Integer size1 = prodAttrRecordsdel.size();
                //Looping through each record present in records node of productAttributes
                for(Integer j = size1 - 1; j >= 0; j--)
                {
                    Map<String, Object> records1 = (Map<String, Object>)prodAttrRecordsdel.get(j);
                }
            }
            if(tempMap.containsKey('priceResult'))
            {
                List<Object> priceResult=(List<Object>)tempMap.get('priceResult');
                for(Object obj1:priceResult)
                {
                    removeNodes(obj1,finalNodes,agreeList);
                }
            }
            for(String key:tempMap.keySet())
            {
                if(finalNodes.contains(key))
                {
                    tempMap.remove(key);
                }
            }
        }catch(Exception e){
            errorList.add(e.getStackTraceString());
        }
    }
    //Added by Binamra Guha
    /* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Overview:-
* This method is used for the Agreement Controller Service.
* This Method will replace Quantity, MinQuantity and MaxQuantity based on Sevice availability.
* ___________________________________________________________________________________________________________
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************   
*/
    public static void agreementUpdate(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        List<String> errorList = new List<String>();
        try{
            ContractId = inputMap.get('Agreementid')+'';
            ProductCode = inputMap.get('ProductCode')+'';
            contract contr = [Select id, Agreement_Nr__c,(Select id, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c,MC_Show_Subscription_In_Channel__c  from vlocity_cmt__ContractLineItems__r Where vlocity_cmt__ContractId__c =:ContractId AND vlocity_cmt__Product2Id__r.ProductCode =:ProductCode and MC_Show_Subscription_In_Channel__c !='N') from Contract Where id =: ContractId AND Status = 'Active' WITH SECURITY_ENFORCED LIMIT 1];
            if(contr.vlocity_cmt__ContractLineItems__r.size() == 0)
            {
                return;
            }
            Map<String, String> mapSubProduct =new Map<String, String>();
            for(vlocity_cmt__ContractLineItem__c ar : contr.vlocity_cmt__ContractLineItems__r)
            {
                if(ar != null && ar.vlocity_cmt__Product2Id__r.ProductCode != null)
                {
                    mapSubProduct.put(ar.vlocity_cmt__Product2Id__r.ProductCode, ar.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c);
                }
            }
            String SubType = mapSubProduct.get(ProductCode);
            List<MCOnline_Agreement_Services_Temp_data__c> agrContrList = [Select id, MCOnline_Agreement_number__c,MCOnline_Agreement_Status__c,MCOnline_Service_availability__c,MCOnline_Service_code__c,MCOnline_Service_Contract_ID__c,MCOnline_Service_status__c, MCOnline_Service_type__c,MCOnline_Subscription_type_code__c, MCOnline_Subscription_type_Status__c from MCOnline_Agreement_Services_Temp_data__c Where MCOnline_Agreement_number__c =: contr.Agreement_Nr__c AND MCOnline_Subscription_type_code__c =: SubType WITH SECURITY_ENFORCED order by CreatedDate asc];
            Map<String,Object> rootData = new Map<String,Object>();
            if(outMap.containsKey('getOfferDetailOutput') && outMap.get('getOfferDetailOutput')!=null){
                rootData=(Map<String,Object>)outMap.get('getOfferDetailOutput');
            }
            else{
                rootData=(Map<String,Object>)outMap.get('HA_GetOffersFromDgCommerce1'); 
            }
            Map<String,Object> result=(Map<String,Object>)rootData.get('result');
            Map<String,Object> offerDetails=(Map<String,Object>)result.get('offerDetails');
            Map<String,Object> offer1=(Map<String,Object>)offerDetails.get('offer');
            //makeQuantityZero(offer1);
            Map<String,Object> offer=(Map<String,Object>)offer1;
            if(offer.containsKey('childProducts'))
            {
                List<Object> childProducts=(List<Object>)offer.get('childProducts');
                for(Integer j = childProducts.size() - 1; j >= 0; j--){
                   Map<String,Object> cprod1=(Map<String, Object>)childProducts.get(j);
                   if(cprod1.containsKey('groupMaxQuantity') && cprod1.get('groupMaxQuantity')==2){
                       cprod1.put('groupMaxQuantity',1);
                   }
                }
            }
            if(agrContrList.size() != 0)
            {
                for(MCOnline_Agreement_Services_Temp_data__c arg: agrContrList)
                {
                    updateQuantity(offer, arg, ProductCode);
                }
            }
            else
            {
                MCOnline_Agreement_Services_Temp_data__c arg1 = new MCOnline_Agreement_Services_Temp_data__c();
                updateQuantity(offer, arg1, ProductCode);
            }
            if(outMap.containsKey('getOfferDetailOutput') && outMap.get('getOfferDetailOutput')!=null){
                outMap.put('getOfferDetailOutput',rootData);
            }
            else{
                outMap.put('HA_GetOffersFromDgCommerce1',rootData);
            }
        }
        catch(Exception e)
        {
            outMap.put('d',e.getMessage()+e.getLineNumber());
            errorList.add(e.getStackTraceString());
        }
    }
    //Added by Binamra Guha
    /* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Overview:-
* This method is used for Updating the Quantity, MinQuantity and MaxQuantity based on Service availablility  .
* This Method will replace Quantity, MinQuantity and MaxQuantity based on Sevice availability.
* ___________________________________________________________________________________________________________
* Logic:-
* If MCOnline_Service_availability__c is DEF --> Quantity:- 1, MinQuantity:- nochange, MaxQuantity:- nochange
* If MCOnline_Service_availability__c is OBL --> Quantity:- 1, MinQuantity:- 1, MaxQuantity:- nochange
* If MCOnline_Service_availability__c is VAL --> Quantity:- 0, for MinQuantity:- 0, MaxQuantity:- nochange
* If MCOnline_Service_status__c is N or E, remove the product.  
* ___________________________________________________________________________________________________________
* @param obj                                 Map containing the offer node coming from GetOfferDetails
* @param arg                                 MCOnline_Agreement_Services_Temp_data__c object record
* @param ProductCode                         Subscription product coming from input Map
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************   
*/
    public static void updateQuantity(Object obj, MCOnline_Agreement_Services_Temp_data__c arg, String ProductCode)
    {
        
        List<String> errorList = new List<String>();
        try{
            Map<String,Object> tempMap=(Map<String,Object>)obj;
            if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
            {
                List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
                for(Object obj3:childProducts)
                {
                    updateQuantity(obj3,arg,ProductCode);
                }
            }
            if(tempMap.containsKey('ProductCode') && tempMap.get('ProductCode') == ProductCode)
            {
                tempMap.put('Quantity', 1);
            }
            if(arg != null && arg.MCOnline_Service_status__c != null){
                if(arg.MCOnline_Service_status__c.equalsIgnoreCase('N') || arg.MCOnline_Service_status__c.equalsIgnoreCase('E'))
                {
                    if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
                    {
                        List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
                        Integer size1 = childProducts.size();
                        for(Integer j = size1 - 1; j >= 0; j--)
                        {
                            Map<String, Object> records1 = (Map<String, Object>)childProducts.get(j);
                            if(records1.get('TeliaSE_Product_Service_Code__c') == String.valueOf(arg.MCOnline_Service_code__c+'-'+arg.MCOnline_Service_type__c) || records1.get('TeliaSE_Product_Service_Code__c') == String.valueOf(arg.MCOnline_Service_code__c) || String.valueOf(records1.get('TeliaSE_Product_Service_Code__c')).replace('-','') == String.valueOf(arg.MCOnline_Service_code__c))
                            {
                                childProducts.remove(j);
                            }
                        }
                    }
                }
            }
            if(tempMap.containskey('TeliaSE_Product_Service_Code__c') && arg != null && arg.MCOnline_Service_availability__c != null)
            {
                if((tempMap.get('TeliaSE_Product_Service_Code__c') == String.valueOf(arg.MCOnline_Service_code__c+'-'+arg.MCOnline_Service_type__c) || tempMap.get('TeliaSE_Product_Service_Code__c') == String.valueOf(arg.MCOnline_Service_code__c) || String.valueOf(tempMap.get('TeliaSE_Product_Service_Code__c')).replace('-','') == String.valueOf(arg.MCOnline_Service_code__c)) && arg.MCOnline_Service_status__c == 'V')
                {
                    if(arg.MCOnline_Service_availability__c.equalsIgnoreCase('DEF') || arg.MCOnline_Service_availability__c.equalsIgnoreCase('OBL'))
                    {
                        tempMap.put('Quantity', 1);
                        if(arg.MCOnline_Service_availability__c.equalsIgnoreCase('OBL'))
                        {
                            tempMap.put('minQuantity', 1);
                        }
                    }
                    else if(arg.MCOnline_Service_availability__c.equalsIgnoreCase('VAL'))
                    {
                        if(tempMap.get('minQuantity') == 0)
                        {
                            tempMap.put('Quantity', 0);
                        }
                    }
                }
            }
        }
        catch(Exception e)
        {
            errorList.add(e.getStackTraceString());
        }
    }
    
    /* ________________________________________________________________________________________________________
* ********************************************************************************************************
* This method is used for generating error for the invalid input(Error Handling Implemention 0.2 version).
* ________________________________________________________________________________________________________
* @param errorCode                            Passing Custom Error Code
* @param inputMap                             Map containing the input coming from the user
* @param error                                passing Custom error
* @param errorType                            passing custom error type
* ________________________________________________________________________________________________________
* ********************************************************************************************************
*/
    
    public static void osubPriceMap(Object obj, Set<String> finalNodes, vlocity_cmt__ContractLineItem__c agreeList, Map<String,Object> outMap, Map<String,Object> inputMap){
        Map<String,Object> tempMap=(Map<String,Object>)obj;
        if(tempMap.containsKey('childProducts'))
        {
            List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
            for(Object obj3:childProducts)
            {
                osubPriceMap(obj3,finalNodes,agreeList,outMap, inputMap);
            }
        }
        if(tempMap.containsKey('priceResult') && !tempMap.containsKey('childProducts'))
        {
            List<Object> priceResult=(List<Object>)tempMap.get('priceResult');
            List<Object> priceResultMap= new List<Object>();
            for(Object obj1:priceResult)
            {
                Map<String,Object> tempMap1=(Map<String,Object>)obj1;
                if(OsubDiscountMap.containsKey(String.valueOf(tempMap.get('ProductCode'))) && OsubSubscriptionMap.containsKey(String.valueOf(tempMap.get('ProductCode')))){
                    if(String.valueOf(tempMap1.get('ChargeType__c')).equalsIgnoreCase('Recurring') && String.valueOf(OsubSubscriptionMap.get(String.valueOf(tempMap.get('ProductCode')))).equalsIgnoreCase('Yes')){
                        Decimal updatedAmount = Decimal.valueOf(String.valueOf(tempMap1.get('Amount__c'))) - Decimal.valueOf(OsubDiscountMap.get(String.valueOf(tempMap.get('ProductCode'))));
                        if(updatedAmount <= 0){
                            outMap.put('ErrorResponse', MCOnline_Utility.generateError('','INVALID_PRODUCT_PRICE','custom',inputMap,'',parameters,APIFUNCTIONALITY));
                            outMap.put('StatusCode', 400);
                            return;
                        }
                        tempMap1.put('Amount__c', updatedAmount);
                    }
                }
                priceResultMap.add(tempMap1);
            }
            tempMap.put('priceResult', priceResultMap);
        }
    }
    
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
                            if(Integer.Valueof(tempMap3.get('Quantity'))==0 && tempMap3.get('TeliaSE_Subscription_Type__c') != null && tempMap3.get('C2BC_Subcategory__c') != 'datasim' && tempMap3.get('C2BC_Subcategory__c') != 'mdsecondary'){
                                childProducts1.remove(i);
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void removeItems1(Object obj){
        
        Map<String, Object> tempMap1 = (Map<String, Object>)obj;
        Map<String,Object> offerDetails=(Map<String,Object>)tempMap1.get('offerDetails');
        Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
        if(offer.containsKey('childProducts'))
        {
            List<Object> childProducts=(List<Object>)offer.get('childProducts');
            for(Integer j = childProducts.size() - 1; j >= 0; j--)
            {
                Map<String, Object> tempMap2 = (Map<String, Object>)childProducts.get(j);
                if(tempMap2.containsKey('childProducts') && productFilter.contains(String.valueOf(tempMap2.get('ProductCode')))){
                    List<Object> childProducts1=(List<Object>)tempMap2.get('childProducts');
                    for(Integer i = childProducts1.size() - 1; i >= 0; i--){
                        Map<String, Object> tempMap3 = (Map<String, Object>)childProducts1.get(i);
                        if(tempMap3.containsKey('Quantity')){
                            if(tempMap3.get('TeliaSE_Subscription_Type__c') == null || tempMap3.get('C2BC_Subcategory__c') == 'datasim' || tempMap3.get('C2BC_Subcategory__c') == 'mdsecondary'){
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
    }
    
    public static void OrderingFlagFilter(Object obj, String orderingFlag){
        
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
                            
                            //if(tempMap3.get('TeliaSE_Subscription_Type__c') == null && tempMap3.get('Ordering_Flag__c') !=null && !String.valueOf(tempMap3.get('Ordering_Flag__c')).equalsIgnoreCase('Hide') && !String.isBlank(orderingFlag) && !String.valueOf(tempMap3.get('Ordering_Flag__c')).equalsIgnoreCase(orderingFlag)){
                                //childProducts1.remove(i);
                            //}                       
                        }
                    }
                    if(childProducts1.isEmpty()){
                        childProducts.remove(j);
                    }
                }
            }
        } 
    }
    
    
    public static Map<String, Object> GetAgreementControlServiceV3(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        
        Map<String, Object> offerdetailsMap = new Map<String, Object>();
        Map<String, Object> offerObj1 = new Map<String, Object>();
        Map<String,vlocity_cmt__ContractLineItem__c> agreementProducts=new Map<String,vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> agreementLineItems= new List<vlocity_cmt__ContractLineItem__c>();
        Map<String,Boolean> spAddons=new map<String,Boolean>{'SC_STANDARD'=>false,'MOB_SP_ADDON_ABROAD_CALL'=>false,'MOB_SP_ADDON_ABROAD_MAX'=>false};
        boolean hasError = false;
        String parentProductCode;
        Try{
            ProductCode = String.valueOf(inputMap.get('ProductCode'));
            CatalogCode = inputMap.get('Catalog')+'';
            ContractId= Id.valueof((string)inputMap.get('Agreementid'));
            agreementLineItems = [Select id,TeliaSE_ProductHierarchy__c,TeliaSE_ParentClusterCode__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__ContractId__c,TeliaSE_Approved_Price__c,TeliaSE_MC_Customer_Requested_Price__c,TeliaSE_Start_Date__c,TeliaSE_End_Date__c,vlocity_cmt__ProductCode__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__RecurringTotal__c , vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__Product2Id__r.Ordering_Flag__c, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c,MC_Show_Subscription_In_Channel__c,MC_LineItem_Status__c  from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =:ContractId and MC_Show_Subscription_In_Channel__c !='N' WITH SECURITY_ENFORCED];
            Boolean invalidSubFlag = false;
            Boolean notInCluster=false;
            for(vlocity_cmt__ContractLineItem__c con: agreementLineItems){ 
                agreementProducts.put(con.vlocity_cmt__Product2Id__r.ProductCode,con);
                if(con.vlocity_cmt__Product2Id__c!=null &&con.vlocity_cmt__Product2Id__r.ProductCode.equalsIgnoreCase(ProductCode)){
                    invalidSubFlag = true;
                }
                if(con.vlocity_cmt__Product2Id__r.ProductCode == ProductCode && con.TeliaSE_ProductHierarchy__c!=null)
                {
                    String[] codes=con.TeliaSE_ProductHierarchy__c.split('<');
                    parentProductCode=codes[codes.size()-2];
                }
            }
            if(parentProductCode !=null)
            {
                parentProductCode=[select productcode from Product2 where id=:parentProductCode]?.ProductCode;
                if(ProductCode!= null && agreementProducts.get(parentProductCode)!=null)
                {
                    String cluster=agreementProducts.get(parentProductCode).TeliaSE_ParentClusterCode__c!=null?agreementProducts.get(parentProductCode).TeliaSE_ParentClusterCode__c.toUppercase():null;
                    if(cluster!=null)
                    {
                        for(vlocity_cmt__ContractLineItem__c con: agreementLineItems){  
                            if(spAddons.ContainsKey(con.vlocity_cmt__Product2Id__r.ProductCode) && (con.TeliaSE_ParentClusterCode__c.equalsignorecase(cluster) || (con.TeliaSE_ParentClusterCode__c.contains('_') && con.TeliaSE_ParentClusterCode__c.split('_')[2] == cluster)))
                            {
                                agreementProducts.put(con.vlocity_cmt__Product2Id__r.ProductCode,con);
                                spAddons.put(con.vlocity_cmt__Product2Id__r.ProductCode,True);
                            }
                            else if(con.vlocity_cmt__Product2Id__r.ProductCode=='MOB_SP_ADDON_ABROAD_MAX' && cluster.equalsIgnoreCase('plus'))
                            {
                                con.vlocity_cmt__Product2Id__r.Ordering_Flag__c='Hide';
                                agreementProducts.put(con.vlocity_cmt__Product2Id__r.ProductCode,con);
                                spAddons.put(con.vlocity_cmt__Product2Id__r.ProductCode,True);
                            }
                            else if(con.vlocity_cmt__Product2Id__r.ProductCode=='SC_STANDARD' && con.TeliaSE_ParentClusterCode__c.equalsignorecase('SC_KLU_LEGACY') && !(spAddons.get(con.vlocity_cmt__Product2Id__r.ProductCode)))
                            {
                                agreementProducts.put(con.vlocity_cmt__Product2Id__r.ProductCode,con);
                                spAddons.put(con.vlocity_cmt__Product2Id__r.ProductCode,True);
                            }
                        }
                    }
                }
            }
            for(String spAddon: spAddons.keyset())
            {
                if(!spAddons.get(spAddon) && agreementProducts.containsKey(spAddon)){
                    agreementProducts.remove(spAddon);
                }
            }
            
            if(agreementLineItems.size()==0 && !invalidSubFlag && inputMap.get('ProductCode') != null && CatalogCode.equalsIgnoreCase('SUBSCRIPTIONS')){
                outMap.put('ErrorResponse', MCOnline_Utility.generateError('','INVALID_SUBSCRIPTION_CODE','custom',inputMap,'',parameters,APIFUNCTIONALITY));
                outMap.put('StatusCode', 400);
            }
            else{
                offerdetailsMap=(Map<String, Object>)inputMap.get('HA_GetOffersFromDgCommerce1');
                list<string> toremove = new list<string>();
                if(((Map<String, Object>)offerdetailsMap.get('result')!=null) && (((Map<String, Object>)offerdetailsMap.get('result')).containskey('offerDetails'))){
                    offerObj1=(Map<String, Object>)( (Map<String, Object>)( (Map<String, Object>)offerdetailsMap.get('result')).get('offerDetails')).get('offer') ;
                    List<Object> priceResult = (List<Object>)offerObj1.get('priceResult');
                    offerdetailsMap.put('basketAction','AddAfterConfig');
                    catalog=(string)inputMap.get('Catalog');
                    CatalogAgreement__c filter = CatalogAgreement__c.getInstance(catalog);
                    Boolean show_Only_Negotiated_Products=false;
                    if(filter!=null && filter.OnlyMappedproductAgreement__c){
                        show_Only_Negotiated_Products=true;  
                    }
                    List<String> offersToSkip=System.Label.MC_getOffer_Switch.split(',');
                    //recursively remvove non agreement products under subscription bundle
                    GetAgreementProducts(offerObj1,agreementProducts,offersToSkip);
                    ((Map<String, Object>)((Map<String, Object>)offerdetailsMap.get('result')).get('offerDetails')).put('offer',offerObj1);
                    outMap.put('HA_GetOffersFromDgCommerce1', offerdetailsMap);
                    
                    if(!hasError){
                        offerdetailsMap.put('success', true);
                    }
                    
                }else{
                    //BEGIN error handling
                    hasError = true;
                    stdError = (string)offerdetailsMap.get('error');
                    errorCode = (string)offerdetailsMap.get('errorCode');
                    outMap.put('ErrorResponse', MCOnline_Utility.generateError(stdError,errorCode,'standard',inputMap,'',parameters,APIFUNCTIONALITY));
                    outMap.put('StatusCode', 400);
                    //END error handling
                }
            }
        }Catch(Exception e){   
            hasError = true;
            String error_message= e.getMessage() +' '+e.getLineNumber();
            //BEGIN error handling
            LIST<String> errList =  error_message.split('\\:');
            If(errList.get(0)=='Invalid id'){
                errorCode = 'INVALID_AGREEMENT';
            }else if(error_message.contains('Argument cannot be null')){
                errorCode = 'NULL_ARGUMENT';
            }else{
                errorCode = 'UNKNOWN_ERROR';
            }
            offerdetailsMap=(Map<String, Object>)inputMap.get('HA_GetOffersFromDgCommerce1');
            String dc_message = String.valueOf(offerdetailsMap), final_message = error_message+' '+dc_message, inputData = JSON.serialize(inputMap);
            integer fieldLength = Schema.SObjectType.vlocity_cmt__VlocityErrorLogEntry__c.fields.vlocity_cmt__ErrorMessage__c.getLength(), inputdataLength = Schema.SObjectType.vlocity_cmt__VlocityErrorLogEntry__c.fields.vlocity_cmt__InputData__c.getLength();
            
            if(final_message.length() > fieldLength ){
                final_message = final_message.substring(0, fieldLength);
            }
            if(inputData.length() > inputdataLength ){
                inputData = inputData.substring(0, fieldLength);
            }
            if(errorCode != 'UNKNOWN_ERROR')
            {
                outMap.put('ErrorResponse',MCOnline_Utility.generateError('',errorCode,'custom',inputMap,'',parameters,APIFUNCTIONALITY));
                MCOnline_Utility.logError(final_message,errorCode,'MCOnline_GetAgreementControlServiceV3','Apex Class','Exception',inputData,'',''); 
                
            }
            else{
                outMap.put('ErrorResponse',MCOnline_Utility.generateError(error_message,errorCode,'custom',inputMap,'',parameters,APIFUNCTIONALITY));
                MCOnline_Utility.logError(final_message,'500','MCOnline_GetAgreementControlServiceV3','Apex Class','Exception',inputData,'','');   
            }
            outMap.put('StatusCode', 500); 
        }   
        return outMap;
    }


    
    public static void GetAgreementProducts(Object offerObj1,Map<String,vlocity_cmt__ContractLineItem__c> agreementProducts,List<String> offersToSkip){
        Map<String,Object> tempMap=(Map<String,Object>)offerObj1;
        if(tempMap.containsKey('childProducts')){
            if((tempMap.get('C2BC_Category__c')+'' == 'subscriptionbundle' && tempMap.get('vlocity_cmt__SpecificationType__c')+'' !='Offer')||(tempMap.get('C2BC_Category__c')+'' == 'addonbundle' && !offersToSkip.contains(tempMap.get('ProductCode')+''))){
                List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
                List<Object> agreementChildProducts=new List<Object>();
                for(Integer i=0;i<childProducts.size();i++)
                {
                    Map<String,Object> childProduct=(Map<String,Object>)childProducts[i];
                    if(childProduct.containskey('C2BC_Category__c')
                    && (childProduct.get('C2BC_Category__c')+''=='mobilevoicesubscription' || childProduct.get('C2BC_Category__c')+''=='mobilebroadbandsubscription' || childProduct.get('C2BC_Category__c')+'' == 'ucsswitchboards' || childProduct.get('C2BC_Category__c')+'' == 'switchboardextension') 
                    &&  String.valueOf(childProduct.get('vlocity_cmt__SpecificationType__c')) != null 
                    &&  String.valueOf(childProduct.get('vlocity_cmt__SpecificationType__c')).equalsIgnoreCase('Product'))
                    {
                        if(agreementProducts.containsKey(String.valueOf(childProduct.get('ProductCode'))))
                        {
                            readAgreementPrice(childProduct,agreementProducts);
                            agreementChildProducts.add(childProducts[i]);
                        }
                        else if(tempMap.get('C2BC_Category__c')+'' == 'addonbundle')
                        {
                            agreementChildProducts.add(childProducts[i]);
                        }
                    }
                    else if(tempMap.get('C2BC_Category__c')+'' == 'addonbundle')
                    {
                            agreementChildProducts.add(childProducts[i]);
                    }
                }
                tempMap.put('childProducts',agreementChildProducts);
            }
            else{
                for(Object child:(List<Object>)tempMap.get('childProducts')){
                    GetAgreementProducts(child,agreementProducts,offersToSkip); 
                }
            }
        }
        else if(tempMap.get('vlocity_cmt__SpecificationType__c')+'' !='Offer'){
            if(agreementProducts.containsKey(String.valueOf(tempMap.get('ProductCode')))){
                readAgreementPrice(tempMap,agreementProducts);
            }
        }
    }


    private static void readAgreementPrice(Map<String,Object> childProduct,Map<String,vlocity_cmt__ContractLineItem__c> agreementProducts)
    {
        for(Object priceObj:(List<Object>)childProduct.get('priceResult'))
        {
            Map<String,Object> price=(Map<String,Object>)priceObj;
            if(price.get('ChargeType__c')+'' == 'Recurring')
            {    
                if(agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).TeliaSE_MC_Customer_Requested_Price__c !=null)
                {
                    price.put('Amount__c', agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).TeliaSE_MC_Customer_Requested_Price__c);
                }
                else if(agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).vlocity_cmt__RecurringCharge__c!=null && agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).vlocity_cmt__RecurringCharge__c!=0)
                {
                    price.put('Amount__c', agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).vlocity_cmt__RecurringCharge__c); 
                }
            }
            else
            {
                price.put('Amount__c', agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).vlocity_cmt__OneTimeTotal__c); //oneTimeTotal
            } 
        }
        if(agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).MC_LineItem_Status__c !=null)
        {
            childProduct.put('subscriptionTypeStatus',agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).MC_LineItem_Status__c);
        }
        else
        {
            childProduct.put('subscriptionTypeStatus','Valid');      
        }
        if(String.ValueOf(childProduct.get('subscriptionTypeStatus')).equalsIgnoreCase('Exists') ){
            childProduct.Put('Ordering_Flag__c','ManageFlow');
        }
        if(agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).vlocity_cmt__Product2Id__r.Ordering_Flag__c !=null){
            childProduct.Put('Ordering_Flag__c',agreementProducts.get(String.valueOf(childProduct.get('ProductCode'))).vlocity_cmt__Product2Id__r.Ordering_Flag__c);
        }
    }
     
}