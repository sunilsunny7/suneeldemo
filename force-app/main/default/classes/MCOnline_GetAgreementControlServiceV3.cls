/* ______________________________________________________________________________________________________
 * ******************************************************************************************************
 * This class is the remote class of the getAgreementControlService API where the remote method 
   GetAgreementControlServiceV3 and trim is called.
 * This class is custom class for the standard GetOfferDetails.
 * In this class, logic for Error Handling, Agreement Controller Services is present along with Triming 
   of output response coming from Standard getOfferdetails response.
 * The Output response will give all the products details present in the contract line items. 
 * ______________________________________________________________________________________________________
 * @author         Binamra Guha <binamra.a.guha@capgemini.com>
 * @modifiedBy     
 * @maintainedBy   
 * @version        3.0
 * @created        2021-10-06
 * @modified
 * ______________________________________________________________________________________________________
 * ******************************************************************************************************
*/
global with sharing class MCOnline_GetAgreementControlServiceV3 implements vlocity_cmt.VlocityOpenInterface {
    
    public static Set<String> productFilter = new Set<String>();
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        if(methodName.equals('GetAgreementControlServiceV3'))
        {
            Map<string,object> output = new Map<string,object>();
            output = GetAgreementControlServiceV3(inputMap, outMap, options);
            if(!output.containsKey('ErrorResponse'))
            {
                agreementUpdate(inputMap, outMap);
                trim(inputMap, outMap);
            }
        }
        return true;
    }
    //Added by Binamra Guha
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
        String trimMode=inputMap.get('TrimMode')+'';
        if(trimMode!=null && trimMode.equalsIgnoreCase('No'))
        {
            return;    
        }
        List<String> errorList = new List<String>();
        try{
            Trim_GetOfferDetails__mdt finalNodeslist = [Select MCONL_Attributes_to_Remove__c from Trim_GetOfferDetails__mdt];
            String finalNodeslistStr=finalNodeslist.MCONL_Attributes_to_Remove__c;
            List<String> finalNodeslistStrtolist = finalNodeslistStr.split(',');
            Set<String> finalNodes= new Set<String>(finalNodeslistStrtolist);
            Set<String> offercodeset=new Set<String>();
            List<vlocity_cmt__CatalogProductRelationship__c> catalogproductrelationshiplst  = new List<vlocity_cmt__CatalogProductRelationship__c>();                 
            catalogproductrelationshiplst=[ SELECT id,vlocity_cmt__CatalogId__r.vlocity_cmt__IsActive__c,vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c,Name FROM vlocity_cmt__CatalogProductRelationship__c WHERE vlocity_cmt__IsActive__c=true AND vlocity_cmt__CatalogId__c!=null];
            for(vlocity_cmt__CatalogProductRelationship__c pr: catalogproductrelationshiplst)
            {
                offercodeset.add(pr.Name);
            }
            List<Product2> productstore = [Select id, ProductCode, TeliaSE_Subscription_Type__c, Family from Product2 Where C2BC_Category__c = 'addonbundle' AND C2BC_Subcategory__c IN ('mobilevoicesubscription','mobilebroadbandsubscription','datavolumes') AND TeliaSE_Object_Type_Name__c = 'Bundle' AND Family = 'Online Order'];
            if(productstore.size()>0){
                for(Product2 pp : productstore){
                    productFilter.add(pp.ProductCode);
                }
            }
            
            String ContractId=inputMap.get('Agreementid')+'';
            String ProductCode = inputMap.get('ProductCode')+'';
            String CatalogCode = inputMap.get('Catalog')+'';
            system.debug(ProductCode);
            vlocity_cmt__ContractLineItem__c agreeList = [Select id, TeliaSE_SubsidisedVoice__c from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =:ContractId AND vlocity_cmt__ProductCode__c IN:offercodeset LIMIT 1];
            Map<String,Object> rootData=(Map<String,Object>)outMap.get('HA_GetOffersFromDgCommerce1');
            Map<String,Object> result=(Map<String,Object>)rootData.get('result');
            Map<String,Object> offerDetails=(Map<String,Object>)result.get('offerDetails');
            Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
            
            /*--------------Calling the removeNodes method-----------*/
            removeNodes(offer,finalNodes,agreeList);
            Map<String,Object> result1=(Map<String,Object>)result;
            if(CatalogCode.equalsIgnoreCase('SUBSCRIPTIONS'))
            {
                if(inputMap.get('ProductCode') == null || inputMap.get('ProductCode') == '')
                {
                    removeItems1(result1);
                }else
                {
                    removeItems(result1);
                }
            }
            outMap.put('HA_GetOffersFromDgCommerce1',rootData);
        }catch(Exception e){
            outMap.put('d',e.getMessage()+e.getLineNumber());
            errorList.add(e.getStackTraceString());
        }
    }
    //Added by Binamra Guha
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
            if(String.valueOf(tempMap.get('label')) == 'Commitment_period')
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
                    if(String.valueOf(records1.get('code')) == 'Relation_Id')
                    {//replace ICC_number with Relation_Id
                        prodAttrRecordsdel.remove(j); // removing the attribute Relation_Id
                        Integer tsize = totalsize - 1;
                        tempMap.put('totalSize', tsize);
                    }
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
            system.debug('Exception : '+e.getStackTraceString());
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
            String ContractId = inputMap.get('Agreementid')+'';
            String ProductCode = inputMap.get('ProductCode')+'';
            contract contr = [Select id, Agreement_Nr__c from Contract Where id =: ContractId AND Status = 'Active' LIMIT 1];
            List<vlocity_cmt__ContractLineItem__c> contractlineItem = [Select id, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =:ContractId AND vlocity_cmt__Product2Id__r.ProductCode =:ProductCode];
            if(contractlineItem.size() == 0 || contractlineItem == null)
            {
                return;
            }
            Map<String, String> mapSubProduct =new Map<String, String>();
            for(vlocity_cmt__ContractLineItem__c ar : contractlineItem)
            {
                if(ar != null && ar.vlocity_cmt__Product2Id__r.ProductCode != null)
                {
                    mapSubProduct.put(ar.vlocity_cmt__Product2Id__r.ProductCode, ar.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c);
                }
            }
            String SubType = mapSubProduct.get(ProductCode);
            List<MCOnline_Agreement_Services_Temp_data__c> agrContrList = [Select id, MCOnline_Agreement_number__c,MCOnline_Agreement_Status__c,MCOnline_Service_availability__c,MCOnline_Service_code__c,MCOnline_Service_Contract_ID__c,MCOnline_Service_status__c, MCOnline_Service_type__c,MCOnline_Subscription_type_code__c, MCOnline_Subscription_type_Status__c from MCOnline_Agreement_Services_Temp_data__c Where MCOnline_Agreement_number__c =: contr.Agreement_Nr__c AND MCOnline_Subscription_type_code__c =: SubType order by CreatedDate asc];
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
            system.debug('Exception : '+e.getStackTraceString());
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
    public static Map<String,Object> generateError(string error,string errorCode,string errorType,Map<String,Object> inputMap){
        
        string offer = String.Valueof(inputMap.get('offer'));
        String AgreementId = String.valueOf(inputMap.get('AgreementId'));
        string Catalog= String.Valueof(inputMap.get('Catalog'));
        string ProductCode= String.Valueof(inputMap.get('ProductCode'));
        
        string urlDetails = '{"Agreementid": "'+AgreementId+'", "catalog":"'+Catalog+'", "offer":"'+offer+'", "ProductCode":"'+ProductCode+'"}'; 
        
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        ipInputMap.put('functionality', 'GetOffersDetails');
        ipInputMap.put('error', error);   
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_GetAgreementControlServiceV3.generateError','Apex Class', 'Custom Error','STRING_TOO_LONG','','',urlDetails);
        
        return MCOnline_Utility.getError(ipInputMap);
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
    
    /*public static void makeQuantityZero(Object offer)
    {
        Map<String,Object> tempMap=(Map<String,Object>)offer;
        if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
        {
            List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
            for(Object obj3:childProducts)
            {
                makeQuantityZero(obj3);
            }
        }
        if(tempMap != null && tempMap.containsKey('ProductCode') && (tempMap.containsKey('childProducts') == false || tempMap.get('childProducts') == null))
        {
            tempMap.put('Quantity', 0.0);
        }   
    }*/
    
    public static Map<String, Object> GetAgreementControlServiceV3(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        
        Map<String, Object> offerdetailsMap = new Map<String, Object>();
        Map<String, Object> offerObj1 = new Map<String, Object>();
        //List<Object> agreementLineItems = new List<Object>();
        List<vlocity_cmt__ContractLineItem__c> agreementLineItems= new List<vlocity_cmt__ContractLineItem__c>();
        Map<String, Object> ipInputMap = new Map<String, Object>();
        Map<String, Object> ipOutputMap = new Map<String, Object>();
        String stdError;
        String errorCode;
        boolean hasError = false;
        Try{
            String ProductCode = inputMap.get('ProductCode')+'';
            String CatalogCode = inputMap.get('Catalog')+'';
            String ContractId= Id.valueof((string)inputMap.get('Agreementid'));
            List<vlocity_cmt__ContractLineItem__c> contractlineItem = [Select id, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =:ContractId AND vlocity_cmt__Product2Id__r.ProductCode =:ProductCode];
            if(contractlineItem.size()==0 && inputMap.get('ProductCode') != null && ProductCode != '' && CatalogCode.equalsIgnoreCase('SUBSCRIPTIONS')){
                outMap.put('ErrorResponse', generateError('','INVALID_SUBSCRIPTION_CODE','custom',inputMap));
                outMap.put('StatusCode', 400);
            }
            else{
            agreementLineItems = [ Select id,vlocity_cmt__RecurringCharge__c,vlocity_cmt__ContractId__c,TeliaSE_Approved_Price__c,TeliaSE_MC_Customer_Requested_Price__c,
                                  TeliaSE_Start_Date__c,TeliaSE_End_Date__c,vlocity_cmt__ProductCode__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__RecurringTotal__c 
                                  FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ContractId__c =:ContractId  ];
            
            offerdetailsMap=(Map<String, Object>)inputMap.get('HA_GetOffersFromDgCommerce1');
            if(((Map<String, Object>)offerdetailsMap.get('result')!=null) && (((Map<String, Object>)offerdetailsMap.get('result')).containskey('offerDetails')==true)){
                
                offerObj1=(Map<String, Object>)( (Map<String, Object>)( (Map<String, Object>)offerdetailsMap.get('result')).get('offerDetails')).get('offer') ;
                //agreementLineItems = (List<Object>)((Map<String, Object>)inputMap.get('DR_ExtractAgreementLineItems')).get('AgreementLineItem');
                List<Object> priceResult = (List<Object>)offerObj1.get('priceResult');
                offerdetailsMap.put('basketAction','AddAfterConfig');
                
                String catalog='';
                catalog=(string)inputMap.get('Catalog');
                CatalogAgreement__c filter = CatalogAgreement__c.getInstance(catalog);
                Boolean show_Only_Negotiated_Products=false;
                if(filter!=null && filter.OnlyMappedproductAgreement__c==true)
                    show_Only_Negotiated_Products=true;  
                
                //==========For root Product code or offer level====================// 
                Boolean isNonSelectableRootlevel=false;
                Boolean isMandatoryRootlevel=false;
                Boolean isPreSelected=false;
                Boolean isOptional=false;
 /*
 ---------------------------------------------------------------------------              
 // line 246 - 283
 // not applicable for root offer. 
 // but will keep the code for future needs 
 ----------------------------------------------------------------------------
 */
              /* for(vlocity_cmt__ContractLineItem__c lineItemObj: agreementLineItems){
                    //system.debug('--agreementLineObj--'+agreementLineObj);
                    //Map<String, Object> lineItemObj = (Map<String, Object>)agreementLineObj;
                    System.debug('Price result : '+priceResult);
                    System.debug('OfferOBj ProdCode : '+offerObj1.get('ProductCode'));
                    System.debug('OfferOBj ProdCode equalsIg : '+lineItemObj.vlocity_cmt__ProductCode__c);
                    if(priceResult!= null && (String.valueOf(offerObj1.get('ProductCode')).equalsIgnoreCase(lineItemObj.vlocity_cmt__ProductCode__c))){
                        Map<String, Object> agreeObj = new Map<String, Object>();
                        
                        agreeObj=(Map<String, Object>)priceResult[0] ;
                        Decimal RequestedPrice;
                        Decimal ApprovedPrice;
                        RequestedPrice=lineItemObj.TeliaSE_MC_Customer_Requested_Price__c;
                        ApprovedPrice=lineItemObj.TeliaSE_Approved_Price__c;
                        if(agreeObj.get('ChargeType__c')=='Recurring'){  
                            if(RequestedPrice!=null && RequestedPrice!=0){
                                agreeObj.put('Amount__c', lineItemObj.TeliaSE_MC_Customer_Requested_Price__c);
                            }else{
                                if(lineItemObj.vlocity_cmt__RecurringCharge__c!=null && lineItemObj.vlocity_cmt__RecurringCharge__c!=0)
                                    agreeObj.put('Amount__c', lineItemObj.vlocity_cmt__RecurringCharge__c); //recurringcharge
                            }                        
                        }else{
                            agreeObj.put('Amount__c', lineItemObj.vlocity_cmt__OneTimeTotal__c); //oneTimeTotal
                        }                   
                        agreeObj.put('effectivefromdatespec', lineItemObj.TeliaSE_Start_Date__c);
                        agreeObj.put('effectiveuntildatespec', lineItemObj.TeliaSE_End_Date__c);  
                        
                        priceResult[0]=(Object)agreeObj;
                        offerObj1.put('priceResult', priceResult);
                    }
                } */
                //==========For root Product code or offer level====================//             
                //==========For "childproduct" hierarchy offer level start====================//
                List<Object> childProducts2ndLevel = new List<Object>();
                childProducts2ndLevel= (List<Object>)offerObj1.get('childProducts');
                
                List<Object> childProducts2ndLevel_temp = new List<Object>();
                
                if(childProducts2ndLevel!=null && childProducts2ndLevel.size()>0){
                    
                    for(object productGroup : childProducts2ndLevel){
                        
                        Boolean childProducts2ndLevel_negotiated=false;
                        Boolean isSubscriptionProduct2ndlevel=false;
                        
                        Boolean isNonSelectable2ndlevel=false;
                        Boolean isMandatory2ndlevel=false;
                        Boolean isPreSelected2ndlevel=false;
                        Boolean isOptional2ndlevel=false;
                        
                        Map<String, Object> tempproductmap= new Map<String, Object>();
                        
                        Map<String, Object> productGroupspriceResultObj = (Map<String, Object>)productGroup;
                        List<Object> productGroupspriceResult = (List<Object>)productGroupspriceResultObj.get('priceResult');                    
                        Boolean isProductGroupCodeMapped=false;
                        
                        if(productGroupspriceResultObj.containskey('C2BC_Category__c') && String.valueOf(productGroupspriceResultObj.get('C2BC_Category__c'))=='subscriptionbundle')
                            isSubscriptionProduct2ndlevel=true;
                        
                        for(vlocity_cmt__ContractLineItem__c lineItemObj2thlevel: agreementLineItems){
                        if((isProductGroupCodeMapped==false) && productGroupspriceResult!= null && (String.valueOf(productGroupspriceResultObj.get('ProductCode')).equalsIgnoreCase(lineItemObj2thlevel.vlocity_cmt__ProductCode__c))){
                                        isProductGroupCodeMapped=true;
                                        childProducts2ndLevel_negotiated=true;
                                        Map<String, Object> childagreeObj = new Map<String, Object>();
                                        for(Integer i=0; i < productGroupspriceResult.size();i++){
                                        childagreeObj=(Map<String, Object>)productGroupspriceResult[i] ;
                                        Decimal RequestedPrice;
                                        Decimal ApprovedPrice;
                                        RequestedPrice=lineItemObj2thlevel.TeliaSE_MC_Customer_Requested_Price__c;
                                        ApprovedPrice=lineItemObj2thlevel.TeliaSE_Approved_Price__c;
                                        if(childagreeObj.get('ChargeType__c')=='Recurring'){
                                            if(RequestedPrice!=null && RequestedPrice!=0){
                                                childagreeObj.put('Amount__c', lineItemObj2thlevel.TeliaSE_MC_Customer_Requested_Price__c);
                                            }else{
                                                if(lineItemObj2thlevel.vlocity_cmt__RecurringCharge__c!=null && lineItemObj2thlevel.vlocity_cmt__RecurringCharge__c!=0)
                                                    childagreeObj.put('Amount__c', lineItemObj2thlevel.vlocity_cmt__RecurringCharge__c); //recurringcharge
                                            }                        
                                        }else{
                                            childagreeObj.put('Amount__c', lineItemObj2thlevel.vlocity_cmt__OneTimeTotal__c); //oneTimeTotal
                                        } 
                                        childagreeObj.put('effectivefromdatespec', lineItemObj2thlevel.TeliaSE_Start_Date__c);
                                        childagreeObj.put('effectiveuntildatespec', lineItemObj2thlevel.TeliaSE_End_Date__c);                               
                                        productGroupspriceResult[i]=(Object)childagreeObj;
                                        }
                                        productGroupspriceResultObj.put('priceResult', productGroupspriceResult);                                 
                                        childProducts2ndLevel_temp.add(productGroup);
                        }   
                        
                        }
                        List<Object> childproductList = new List<Object>();
                        childproductList= (List<Object>)productGroupspriceResultObj.get('childProducts');
                        
                        List<Object> childproductList3rdlevel_temp = new List<Object>();
                        set<string> productcode_not_negotiated_3rdlevelset=new set<string>();
                        //==================== For 3rd level child product=================================//
                        if(childproductList!=null && childproductList.size()>0){
                            for(object childProduct: childproductList){
                                Boolean childProducts3rdLevel_negotiated=false;
                                Boolean childProducts3rdLevel_addon=false;
                                Boolean orderable_flag_3rdlevel_hide=false;
                                Boolean isSubscriptionProduct3rdlevel=false;
                                
                                Boolean isNonSelectable3rdlevel=false;
                                Boolean isMandatory3rdlevel=false;
                                Boolean isPreSelected3rdlevel=false;
                                Boolean isOptional3rdlevel=false;
                                
                                Map<String, Object> childProductResultObj = (Map<String, Object>)childProduct;
                                List<Object> childProductspriceResult = (List<Object>)childProductResultObj.get('priceResult');
                                
                                if(isSubscriptionProduct2ndlevel==false)
                                    childProducts3rdLevel_addon=true;
                                
                                if(childProductResultObj.containskey('C2BC_Category__c') && String.valueOf(childProductResultObj.get('C2BC_Category__c'))=='subscriptionbundle')
                                    isSubscriptionProduct3rdlevel=true;
                                // Removing filter based on ordering flag in getOfferdetails as this will be done in MYB
                                //if(childProductResultObj.containskey('Ordering_Flag__c') && String.valueOf(childProductResultObj.get('Ordering_Flag__c'))=='Hide')
                                //    orderable_flag_3rdlevel_hide=true;
                                
                                List<Object> childproductList4thlevel = new List<Object>();
                                childproductList4thlevel= (List<Object>)childProductResultObj.get('childProducts');                       
                                List<Object> childproductList4thlevel_temp = new List<Object>();
                                
                                for(vlocity_cmt__ContractLineItem__c lineItemObj: agreementLineItems){
                                    
                                    //Map<String, Object> lineItemObj = (Map<String, Object>)agreementLineObj;            
                                    // For Parent Node(child Product) 2nd level
                                    
                                    /*if((isProductGroupCodeMapped==false) && productGroupspriceResult!= null && (String.valueOf(productGroupspriceResultObj.get('ProductCode')).equalsIgnoreCase(lineItemObj.vlocity_cmt__ProductCode__c))){
                                        isProductGroupCodeMapped=true;
                                        childProducts2ndLevel_negotiated=true;
                                        Map<String, Object> childagreeObj = new Map<String, Object>();
                                        childagreeObj=(Map<String, Object>)productGroupspriceResult[0] ;
                                        Decimal RequestedPrice;
                                        Decimal ApprovedPrice;
                                        RequestedPrice=lineItemObj.TeliaSE_MC_Customer_Requested_Price__c;
                                        ApprovedPrice=lineItemObj.TeliaSE_Approved_Price__c;
                                        if(childagreeObj.get('ChargeType__c')=='Recurring'){
                                            if(RequestedPrice!=null && RequestedPrice!=0){
                                                childagreeObj.put('Amount__c', lineItemObj.TeliaSE_MC_Customer_Requested_Price__c);
                                            }else{
                                                if(lineItemObj.vlocity_cmt__RecurringCharge__c!=null && lineItemObj.vlocity_cmt__RecurringCharge__c!=0)
                                                    childagreeObj.put('Amount__c', lineItemObj.vlocity_cmt__RecurringCharge__c); //recurringcharge
                                            }                        
                                        }else{
                                            childagreeObj.put('Amount__c', lineItemObj.vlocity_cmt__OneTimeTotal__c); //oneTimeTotal
                                        } 
                                        childagreeObj.put('effectivefromdatespec', lineItemObj.TeliaSE_Start_Date__c);
                                        childagreeObj.put('effectiveuntildatespec', lineItemObj.TeliaSE_End_Date__c);                               
                                        productGroupspriceResult[0]=(Object)childagreeObj;
                                        productGroupspriceResultObj.put('priceResult', productGroupspriceResult);                                 
                                        childProducts2ndLevel_temp.add(productGroup);
                                    } */
                                    
                                    // For Grand Child product node 3rd level
                                    if(childProductspriceResult!= null && (String.valueOf(childProductResultObj.get('ProductCode')).equalsIgnoreCase(lineItemObj.vlocity_cmt__ProductCode__c))){
                                        Map<String, Object> grand_childProductagreeObj = new Map<String, Object>();
                                        for(Integer j=0; j<childProductspriceResult.size();j++){
                                        grand_childProductagreeObj=(Map<String, Object>)childProductspriceResult[j] ;
                                        
                                        Decimal RequestedPrice3rd;
                                        Decimal ApprovedPrice3rd;
                                        RequestedPrice3rd=lineItemObj.TeliaSE_MC_Customer_Requested_Price__c;
                                        ApprovedPrice3rd=lineItemObj.TeliaSE_Approved_Price__c;
                                        if(grand_childProductagreeObj.get('ChargeType__c')=='Recurring'){
                                            if(RequestedPrice3rd!=null && RequestedPrice3rd!=0){
                                                grand_childProductagreeObj.put('Amount__c', lineItemObj.TeliaSE_MC_Customer_Requested_Price__c);
                                            }else{
                                                if(lineItemObj.vlocity_cmt__RecurringCharge__c!=null && lineItemObj.vlocity_cmt__RecurringCharge__c!=0)
                                                    grand_childProductagreeObj.put('Amount__c', lineItemObj.vlocity_cmt__RecurringCharge__c); //recurringcharge
                                            }                       
                                        }else{
                                            grand_childProductagreeObj.put('Amount__c', lineItemObj.vlocity_cmt__OneTimeTotal__c); //oneTimeTotal
                                        }
                                        grand_childProductagreeObj.put('effectivefromdatespec', lineItemObj.TeliaSE_Start_Date__c);
                                        grand_childProductagreeObj.put('effectiveuntildatespec', lineItemObj.TeliaSE_End_Date__c);
                                        childProductspriceResult[j]=(Object)grand_childProductagreeObj ;
                                        }
                                        childProductResultObj.put('priceResult', childProductspriceResult);
                                        childProducts3rdLevel_negotiated=true;
                                    }
                                }
                                
                                isProductGroupCodeMapped=true;
                                
                                //==================== For 4th level child product=================================//
                                if(childproductList4thlevel!=null && childproductList4thlevel.size()>0){
                                    
                                    set<string> productcode_not_negotiated_4thlevelset=new set<string>();
                                    for(object childProduct4thlevel: childproductList4thlevel){
                                        Boolean childProducts4thLevel_negotiated=false;
                                        
                                        Boolean isNonSelectable4thlevel=false;
                                        Boolean isMandatory4thlevel=false;
                                        Boolean isPreSelected4thlevel=false;
                                        Boolean isOptional4thlevel=false;
                                        
                                        Map<String, Object> childProductResultObj4thlevel = (Map<String, Object>)childProduct4thlevel;
                                        List<Object> childProductspriceResult4thlevel = (List<Object>)childProductResultObj4thlevel.get('priceResult');
                                        Boolean orderable_flag_4thlevel_hide=false;
                                        // Removing filter based on ordering flag in getOfferdetails as this will be done in MYB
                                        //if(childProductResultObj4thlevel.containskey('Ordering_Flag__c') && String.valueOf(childProductResultObj4thlevel.get('Ordering_Flag__c'))=='Hide')
                                         //   orderable_flag_4thlevel_hide=true;
                                        
                                        for(vlocity_cmt__ContractLineItem__c lineItemObj4thlevel: agreementLineItems){
                                            //Map<String, Object> lineItemObj4thlevel = (Map<String, Object>)agreementLineObj4thlevel;            
                                            
                                            if(childProductspriceResult4thlevel!= null && (String.valueOf(childProductResultObj4thlevel.get('ProductCode')).equalsIgnoreCase(lineItemObj4thlevel.vlocity_cmt__ProductCode__c))){
                                                Map<String, Object> grand_childProductagreeObj4thlevel = new Map<String, Object>();
                                                for(Integer z=0; z<childProductspriceResult4thlevel.size(); z++){
                                                grand_childProductagreeObj4thlevel=(Map<String, Object>)childProductspriceResult4thlevel[z] ;                                                                 
                                                
                                                Decimal RequestedPrice4th;
                                                Decimal ApprovedPrice4th;
                                                RequestedPrice4th=lineItemObj4thlevel.TeliaSE_MC_Customer_Requested_Price__c;
                                                ApprovedPrice4th=lineItemObj4thlevel.TeliaSE_Approved_Price__c;
                                                if(grand_childProductagreeObj4thlevel.get('ChargeType__c')=='Recurring'){  
                                                    if(RequestedPrice4th!=null && RequestedPrice4th!=0){
                                                        grand_childProductagreeObj4thlevel.put('Amount__c', lineItemObj4thlevel.TeliaSE_MC_Customer_Requested_Price__c);
                                                    }else{
                                                        if(lineItemObj4thlevel.vlocity_cmt__RecurringCharge__c!=null && lineItemObj4thlevel.vlocity_cmt__RecurringCharge__c!=0)
                                                            grand_childProductagreeObj4thlevel.put('Amount__c', lineItemObj4thlevel.vlocity_cmt__RecurringCharge__c); //recurringcharge
                                                    }                       
                                                }else{
                                                    grand_childProductagreeObj4thlevel.put('Amount__c', lineItemObj4thlevel.vlocity_cmt__OneTimeTotal__c); //oneTimeTotal
                                                }
                                                grand_childProductagreeObj4thlevel.put('effectivefromdatespec', lineItemObj4thlevel.TeliaSE_Start_Date__c);
                                                grand_childProductagreeObj4thlevel.put('effectiveuntildatespec', lineItemObj4thlevel.TeliaSE_End_Date__c);                                     
                                                childProductspriceResult4thlevel[z]=(Object)grand_childProductagreeObj4thlevel  ;
                                                }
                                                childProductResultObj4thlevel.put('priceResult', childProductspriceResult4thlevel);                                      
                                                childProducts4thLevel_negotiated=true;
                                            }
                                        }
                                        if(orderable_flag_4thlevel_hide==false && isNonSelectable4thlevel==false){                                                                       
                                            if(show_Only_Negotiated_Products==true){
                                                if(childProducts4thLevel_negotiated==true || isSubscriptionProduct3rdlevel==false)
                                                    childproductList4thlevel_temp.add(childProduct4thlevel); 
                                            }else{
                                                childproductList4thlevel_temp.add(childProduct4thlevel); 
                                            } 
                                        }
                                    }
                                    childproductList4thlevel.clear();
                                    if(childproductList4thlevel_temp.size()>0){
                                        childproductList4thlevel.addAll(childproductList4thlevel_temp);  
                                    }
                                }
                                //==================== For 4th level child product=================================//
                                if(orderable_flag_3rdlevel_hide==false && isNonSelectable3rdlevel==false){                            
                                    if(show_Only_Negotiated_Products==true){
                                        if(childProducts3rdLevel_negotiated==true || childProducts3rdLevel_addon==true){
                                            childproductList3rdlevel_temp.add(childProduct);
                                        }   
                                    }else{
                                        childproductList3rdlevel_temp.add(childProduct);
                                    }
                                }
                            }
                            childproductList.clear();
                        }
                        
                        if(childproductList3rdlevel_temp.size()>0){
                            // override 3rd level product list 
                            childproductList.addAll(childproductList3rdlevel_temp);
                        }
                    }
                }
                
                
                outMap.put('HA_GetOffersFromDgCommerce1', offerdetailsMap);
                
                if(!hasError){
                    offerdetailsMap.put('success', true);
                }
                
            }else{
                //BEGIN error handling
                hasError = true;
                stdError = (string)offerdetailsMap.get('error');
                errorCode = (string)offerdetailsMap.get('errorCode');
                system.debug('errorCode==>'+errorCode);
                outMap.put('ErrorResponse', generateError(stdError,errorCode,'standard',inputMap));
                outMap.put('StatusCode', 400);
                //END error handling
            }
            }
        }Catch(Exception e){   
            hasError = true;
            System.debug('Error Message===>: ' + e.getMessage()); 
            System.debug('Error Line number===>: ' + e.getLineNumber()); 
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
            String dc_message = String.valueOf(offerdetailsMap);
            String final_message = error_message+' '+dc_message;
            String inputData = JSON.serialize(inputMap);
            integer fieldLength = Schema.SObjectType.vlocity_cmt__VlocityErrorLogEntry__c.fields.vlocity_cmt__ErrorMessage__c.getLength();
            Integer inputdataLength = Schema.SObjectType.vlocity_cmt__VlocityErrorLogEntry__c.fields.vlocity_cmt__InputData__c.getLength();
            if(final_message.length() > fieldLength ){
                final_message = final_message.substring(0, fieldLength);
            }
            if(inputData.length() > inputdataLength ){
                inputData = inputData.substring(0, fieldLength);
            }
            if(errorCode != 'UNKNOWN_ERROR')
            {
                system.debug('Enter here');
                outMap.put('ErrorResponse',MCOnline_Utility.generateError('',errorCode,'custom','GetOffersDetails'));
                system.debug('ErrorResponse'+outMap);
                MCOnline_Utility.logError(final_message,errorCode,'MCOnline_GetAgreementControlServiceV3','Apex Class','Exception',inputData,'',''); 
                
            }
            else{
                outMap.put('ErrorResponse',MCOnline_Utility.generateError(error_message,errorCode,'custom','GetOffersDetails'));
                MCOnline_Utility.logError(final_message,'500','MCOnline_GetAgreementControlServiceV3','Apex Class','Exception',inputData,'',''); 
                
            }
            outMap.put('StatusCode', 500);
            
        }   
        return outMap;
    }
    
}