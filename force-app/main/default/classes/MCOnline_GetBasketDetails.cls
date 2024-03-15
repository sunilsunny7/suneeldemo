/* ______________________________________________________________________________________________________
* ******************************************************************************************************
* This class is the remote class of the GetOfferDetails API where the remote method getOffersDetails
and trim is called.
* This class is custom class for the standard GetOfferDetails.
* In this class, logic for Error Handling, Agreement Controller Services is present along with Triming 
of output response coming from Standard getOfferdetails response.
* The output will have the mapped values of the products in the item basket, which we pass an an input along with all the products details present in the contract line items. 
* ______________________________________________________________________________________________________
* @author         Aparajita Banerjee <aparajita.a.banerjee@capgemini.com>
* @modifiedBy     Aparajita Banerjee <aparajita.a.banerjee@capgemini.com>
* @maintainedBy   Aparajita Banerjee <aparajita.a.banerjee@capgemini.com>
* @created        2021-09-17
* @modified       2021-11-30
* ______________________________________________________________________________________________________
* ******************************************************************************************************
*/
    //Added by Aparajita Banerjee
    /* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
* Overview:-
* This is used for calling the getOfferDetails, get agreement Controll service and trimming the output.
* This calls the methods namely agreementUpdate, removeItems1 and removeItems from the class MCOnline_GetAgreementControlServiceV3.
* * ___________________________________________________________________________________________________________
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param IP                                       Map contains the input for the MCOnline_GetAgreementControlServiceV3.agreementUpdate() method.
* ___________________________________________________________________________________________________________
* ***********************************************************************************************************
*/
global with sharing class MCOnline_GetBasketDetails implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        if(methodName.equals('getbasketDetails'))
        {
            String str='';  
            map<string,object> OP = new map<string,object>();
            map<string,object> IP = new map<string,object>();
            OP= getbasketDetails(inputMap, outMap, options, str);
            if(!OP.containsKey('ErrorResponse')){
                string ProductName = String.valueOf(outMap.get('ProductName'));
                IP.put('ProductCode',ProductName);
                IP.put('Agreementid',outMap.get('ContractId'));
                MCOnline_GetAgreementControlServiceV3.agreementUpdate(IP, outMap);
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
            //String ContractId=inputMap.get('Agreementid')+'';
            String ContractId = String.valueOf(outMap.get('ContractId')+'');
            string ProductCode = String.valueOf(outMap.get('ProductName')+'');
            vlocity_cmt__ContractLineItem__c agreeList = new vlocity_cmt__ContractLineItem__c();
            agreeList = [Select id, TeliaSE_SubsidisedVoice__c from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =:ContractId AND vlocity_cmt__ProductCode__c IN:offercodeset LIMIT 1];
            system.debug('blablabla '+(JSON.serialize(outMap)));
            system.debug('blablabla2 '+(JSON.serialize((Map<String,Object>)outMap.get('getOfferDetailOutput'))));
            Map<String,Object> rootData=(Map<String,Object>)outMap.get('getOfferDetailOutput');
            Map<String,Object> result=(Map<String,Object>)rootData.get('result');
            system.debug(JSON.serialize(result));
            Map<String,Object> offerDetails=(Map<String,Object>)result.get('offerDetails');
            Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
            
            /*--------------Calling the removeNodes method-----------*/
            removeNodes(offer,finalNodes,agreeList);
            Map<String,Object> result1=(Map<String,Object>)result;
            if((String.valueOf(outMap.get('Catalog'))).equalsIgnoreCase('SUBSCRIPTIONS')){
                if(ProductCode == null || ProductCode == ''){           
                   MCOnline_GetAgreementControlServiceV3.removeItems1(result1);
                }
                else{
                   MCOnline_GetAgreementControlServiceV3.removeItems(result1);
                }
            }           
            outMap.put('getOfferDetailOutput',rootData);
        }catch(Exception e){
            outMap.put('d',e.getMessage()+e.getLineNumber());
            system.debug(e.getMessage()+e.getLineNumber());
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
        
        string basketName = String.Valueof(inputMap.get('basketName'));
        string urlDetails = '{"basketName ": "'+basketName +'"}'; 
        
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        ipInputMap.put('functionality', 'GetOffersDetails');
        ipInputMap.put('error', error);   
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_GetBasketDetails.generateError','Apex Class', 'Custom Error','STRING_TOO_LONG','','',urlDetails);
        
        return MCOnline_Utility.getError(ipInputMap);
    }
    /*   //Added by Aparajita Banerjee
________________________________________________________________________________________________________
* ********************************************************************************************************
* This method is used for Mapping the products configuration present in the item basket.
* We do not map the MSISDN and Icc number of Datasim offer
* ________________________________________________________________________________________________________ */
    
    public static void mapAttributes(Object obj, Object item, String copyOrderflag){  
        Map<String, Object> recordMap1 = (Map<String, Object>)item; //product in basket
        
        Map<String, Object> attributestore = (Map<String, Object>)recordMap1.get('attributes'); // extracting attributes of the product in basket
        Map<String, Object> tempMap= (Map<String, Object>)obj;
        if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null){
            List<Object> ChildprodList = (List<Object>)tempMap.get('childProducts');
            for(Object childpro: ChildprodList){
                Map<String, Object> tempMap1 = (Map<String, Object>)childpro; // each child product
                mapAttributes(tempMap1, recordMap1, copyOrderflag);
                /*if(recordMap1!=null && attributestore!= null){  
                  if(String.valueOf(tempMap1.get('ProductCode')) == String.valueOf(recordMap1.get('productCode'))){
                  tempMap1.put('Quantity',1);
                  tempMap1.put('MConline_Action_Code__c',String.valueOf(recordMap1.get('actionCode')));
                  mapAttributes(tempMap1, recordMap1, copyOrderflag);
                    }
                  }*/
            }
        }
        
        //system.debug(tempMap);
        if(tempMap.containsKey('priceResult')){
            if(String.valueOf(tempMap.get('ProductCode')) == String.valueOf(recordMap1.get('productCode'))){
                List<Object> PriceList = (List<Object>)tempMap.get('priceResult');
                if(recordMap1 !=null && recordMap1.containsKey('price')){
                    List<Object> priceList1 = (List<Object>)recordMap1.get('price');
                    for(Object objj: priceList1){
                        Map<String, Object> priceMap = (Map<String, Object>)objj;
                
                        for(Integer i=0;i<PriceList.size();i++){
                            Map<String, Object> price = (Map<String, Object>)PriceList[i];
                            if(price.get('ChargeType__c') == priceMap.get('chargeType')){
                                

                                if(copyOrderflag == 'copyorder' && String.valueOf(tempMap.get('TeliaSE_Subscription_Type__c'))!=null){

                                    if(price.get('ChargeType__c') == 'One-Time' ){
                                        price.put('Amount__c',null);
                                    }
                                    else if(price.get('ChargeType__c')== 'Recurring'){
                                    price.put('Amount__c',null);
                                }
                            }
                            if(price.containsKey('Amount__c') && String.valueOf(priceMap.get('amount')) != null){
                                    price.put('Amount__c',Decimal.valueOf(String.valueOf(priceMap.get('amount'))));
                                }
                            if(price.containsKey('baseamount') && String.valueOf(priceMap.get('baseAmount')) != null){
                        price.put('baseamount',Decimal.valueOf(String.valueOf(priceMap.get('baseAmount'))));
                }
                if(price.containsKey('chargeamount') && String.valueOf(priceMap.get('baseAmount')) != null){
                    price.put('chargeamount',Decimal.valueOf(String.valueOf(priceMap.get('chargeAmount'))));
                }
                if(price.containsKey('RecurringFrequency__c')){
                    price.put('RecurringFrequency__c',string.valueOf(priceMap.get('recurringFrequency')));
                }
                if(price.containsKey('ChargeType__c')){
                    price.put('ChargeType__c',string.valueOf(priceMap.get('chargeType')));
                }
                if(price.containsKey('DisplayText__c')){
                    price.put('DisplayText__c',string.valueOf(priceMap.get('displayText')));
                }
                    }
                    
                }
            }
                }
            }
            
        }
        if(tempMap.containskey('Quantity') && tempMap.containskey('MConline_Action_Code__c')){
            if(String.valueOf(tempMap.get('ProductCode')) == String.valueOf(recordMap1.get('productCode'))){
                tempMap.put('Quantity',1);
                tempMap.put('MConline_Action_Code__c',String.valueOf(recordMap1.get('actionCode')));
            }
        }
        if(tempMap.containsKey('AttributeCategory')){
            if(String.valueOf(tempMap.get('ProductCode')) == String.valueOf(recordMap1.get('productCode'))){
                List<Object> recordattrList= (List<Object>)((Map<String, Object>)((Map<String, Object>)(((List<Object>)((Map<String, Object>)tempMap.get('AttributeCategory')).get('records'))[0])).get('productAttributes')).get('records');
                if(attributestore!=null){
                    for(object rcrd:recordattrList){
                        Map<string,object> attr = (Map<string,object>)rcrd;
                        if(copyOrderflag != 'copyorder'){
                        if(string.ValueOf(tempMap.get('ProductCode'))=='MOB_MULTI_DATASIM_OFFER'){
                            if(attr.get('label')!='MSISDN' && (attr.get('label')!='ICC_number' && attr.get('label')!='ICCNumber')){
                                string label = string.valueOf(attr.get('label'));
                                attr.put('userValues',string.valueOf(attributestore.get(label)));
                            }
                        }
                        else{
                            string label = string.valueOf(attr.get('label'));
                            attr.put('userValues',string.valueOf(attributestore.get(label)));
                        }
                        }
                        
                        if(copyOrderflag == 'copyorder'){
                            if(attr.get('label')!='MSISDN' && attr.get('label')!='ICC_number' && attr.get('label')!='External_reference' && attr.get('label')!='User_name' && attr.get('label')!='SIM_Format'){
                                string label = string.valueOf(attr.get('label'));
                                attr.put('userValues',string.valueOf(attributestore.get(label)));
                            }
                        }
                        
                    }
                }
            }
        }
        
        
    }
    
    
    public static Map<String,object> getbasketDetails(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options, String copyOrderflag){
        
        Map<String, Object> offerdetailsMap = new Map<String, Object>();
        Map<String, Object> offerObj1 = new Map<String, Object>();
        String basketLineRelationId;
        Integer basketLineRelationCount;
        String TSCID;
        //List<Object> agreementLineItems = new List<Object>();
        List<vlocity_cmt__ContractLineItem__c> agreementLineItems= new List<vlocity_cmt__ContractLineItem__c>();
        List<MCOnline_Basket__c> BasketProductInfo= new List<MCOnline_Basket__c>();
        Map<String, Object> ipInputMap = new Map<String, Object>();
        Map<String, Object> ipOutputMap = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> option = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        String stdError;
        String errorCode;
        boolean hasError = false;
        String catalog='';
        String offerCode = '';
        Try{
            string basketName = string.valueOf(inputMap.get('basketName'));
            if(string.isBlank(basketName)){
                outMap.put('ErrorResponse', generateError('','BLANK_BASKET_NAME','custom',inputMap));
                outMap.put('StatusCode', 400);
            }
            else{           
                BasketProductInfo = [select MCOnline_Catalog__c,MCOnline_ParentBasket__r.TSCID__c,Basket_Line_Relation_Id__c,basket_Line_Relation_Count__c,MCOnline_OfferCode__c,MCOnline_Basket_Key__c,MCOnline_Contract__c,MCOnline_AttributeJSON__c,MCOnline_ParentBasket__r.AgreementId__r.Id from MCOnline_Basket__c where Name=: basketName];
                if(BasketProductInfo==null || BasketProductInfo.size()==0){
                    outMap.put('ErrorResponse', generateError('','INVALID_BASKET_NAME','custom',inputMap));
                    outMap.put('StatusCode', 400);
                }
                else{
                    String cartContextKey = '';
                    catalog=string.valueOf(BasketProductInfo[0].MCOnline_Catalog__c);
                    TSCID=string.valueOf(BasketProductInfo[0].MCOnline_ParentBasket__r.TSCID__c);
                    offerCode= String.ValueOf(BasketProductInfo[0].MCOnline_OfferCode__c);
                    CartContextKey= String.ValueOf(BasketProductInfo[0].MCOnline_Basket_Key__c);
                    basketLineRelationId= string.valueOf(BasketProductInfo[0].Basket_Line_Relation_Id__c);
                    basketLineRelationCount = integer.ValueOf(BasketProductInfo[0].basket_Line_Relation_Count__c);
                    Map<String,Object> productAttribute = (Map<String,Object>)JSON.deserializeUntyped(BasketProductInfo[0].MCOnline_AttributeJSON__c);
                    List<Object> productList = (List<Object>)productAttribute.get('products');
                    String productName = String.valueOf(((Map<String,object>)(productList[0])).get('productCode'));
                    String ContractId;
                    if(BasketProductInfo[0].MCOnline_ParentBasket__r.AgreementId__r.Id!=null){
                             ContractId= Id.valueof(BasketProductInfo[0].MCOnline_ParentBasket__r.AgreementId__r.Id);
                    }else{
                             ContractId= BasketProductInfo[0].MCOnline_Contract__c;                    
                    }
                    if(copyOrderflag=='copyorder'){
                      agreementLineItems = [ Select id,MCOnline_Agreement_controlled_service__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__ContractId__c,TeliaSE_Approved_Price__c,TeliaSE_MC_Customer_Requested_Price__c,
                                          TeliaSE_Start_Date__c,TeliaSE_End_Date__c,vlocity_cmt__ProductCode__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__RecurringTotal__c
                                          FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ContractId__r.Account.TSCID__c=:TSCID AND vlocity_cmt__ContractId__r.Status='Active' AND vlocity_cmt__ContractId__r.Contract_Record_Type__c='Ramavtal' ]; 
                    }
                    else{ 
                    agreementLineItems = [ Select id,MCOnline_Agreement_controlled_service__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__ContractId__c,TeliaSE_Approved_Price__c,TeliaSE_MC_Customer_Requested_Price__c,
                                         TeliaSE_Start_Date__c,TeliaSE_End_Date__c,vlocity_cmt__ProductCode__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__RecurringTotal__c 
                                          FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ContractId__c =:ContractId  ]; 
                        
                    }
                    system.debug(JSON.serialize(agreementLineItems));
                    
                    if(Test.isRunningTest()) {
                        offerdetailsMap=outMap;
                    }
                    else
                    {
                        input.put('apiName','getOfferDetails');
                        input.put('catalogCode',catalog);
                        input.put('requestURL', '/v3/catalogs/'+catalog+'/offers/'+offerCode);
                        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
                        appHandler.invokeMethod('getOfferDetailsByCatalogCode', input, output, option);  
                        offerdetailsMap=output;
                    }
                    
                    if(((Map<String, Object>)offerdetailsMap.get('result')!=null) && (((Map<String, Object>)offerdetailsMap.get('result')).containskey('offerDetails')==true)){
                        
                        offerObj1=(Map<String, Object>)( (Map<String, Object>)( (Map<String, Object>)offerdetailsMap.get('result')).get('offerDetails')).get('offer') ;
                        //agreementLineItems = (List<Object>)((Map<String, Object>)inputMap.get('DR_ExtractAgreementLineItems')).get('AgreementLineItem');
                        List<Object> priceResult = (List<Object>)offerObj1.get('priceResult');
                        offerdetailsMap.put('basketAction','AddAfterConfig');
                        
                        CatalogAgreement__c filter = CatalogAgreement__c.getInstance(catalog);
                        Boolean show_Only_Negotiated_Products=false;
                        if(filter!=null && filter.OnlyMappedproductAgreement__c==true)
                            show_Only_Negotiated_Products=true;  
                        
                        //==========For root Product code or offer level====================// 
                        Boolean isNonSelectableRootlevel=false;
                        Boolean isMandatoryRootlevel=false;
                        Boolean isPreSelected=false;
                        Boolean isOptional=false;
                        

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
                                        
                                            
                                        
                                        
                                        if(lineItemObj2thlevel.MCOnline_Agreement_controlled_service__c=='Non-selectable')
                                        {   isNonSelectable2ndlevel=true; 
                                        }
                                        else if(lineItemObj2thlevel.MCOnline_Agreement_controlled_service__c=='Mandatory' || lineItemObj2thlevel.MCOnline_Agreement_controlled_service__c=='Pre-selected'){
                                            isMandatory2ndlevel=true;
                                            productGroupspriceResultObj.put('Quantity',1);
                                            
                                            if(lineItemObj2thlevel.MCOnline_Agreement_controlled_service__c=='Mandatory')
                                                productGroupspriceResultObj.put('minQuantity',1);
                                            
                                        }else if(lineItemObj2thlevel.MCOnline_Agreement_controlled_service__c=='Optional'){
                                            if(productGroupspriceResultObj.get('minQuantity')==0)
                                                productGroupspriceResultObj.put('Quantity',0);
                                        }
                                        
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
                                            // For Grand Child product node 3rd level
                                            system.debug(JSON.serialize(childProductspriceResult)+'-----'+(String.valueOf(childProductResultObj.get('ProductCode'))+'=='+lineItemObj.vlocity_cmt__ProductCode__c));
                                            if(childProductspriceResult!= null && (String.valueOf(childProductResultObj.get('ProductCode')).equalsIgnoreCase(lineItemObj.vlocity_cmt__ProductCode__c))){
                                                Map<String, Object> grand_childProductagreeObj = new Map<String, Object>();
                                                for(Integer j=0; j < productGroupspriceResult.size();j++){
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
                                                //    orderable_flag_4thlevel_hide=true;
                                                
                                                for(vlocity_cmt__ContractLineItem__c lineItemObj4thlevel: agreementLineItems){
                                                    //Map<String, Object> lineItemObj4thlevel = (Map<String, Object>)agreementLineObj4thlevel;            
                                                    
                                                    if(childProductspriceResult4thlevel!= null && (String.valueOf(childProductResultObj4thlevel.get('ProductCode')).equalsIgnoreCase(lineItemObj4thlevel.vlocity_cmt__ProductCode__c))){
                                                        Map<String, Object> grand_childProductagreeObj4thlevel = new Map<String, Object>();
                                                        for(Integer z=0; z < productGroupspriceResult.size();z++){
                                                        grand_childProductagreeObj4thlevel=(Map<String, Object>)childProductspriceResult4thlevel[z] ;                                                                 
                                                        
                                                        /*if(lineItemObj4thlevel.MCOnline_Agreement_controlled_service__c=='Non-selectable')
                                                        {   isNonSelectable4thlevel=true; 
                                                        }
                                                        else if(lineItemObj4thlevel.MCOnline_Agreement_controlled_service__c=='Mandatory' || lineItemObj4thlevel.MCOnline_Agreement_controlled_service__c=='Pre-selected'){
                                                            isMandatory4thlevel=true;
                                                            childProductResultObj4thlevel.put('Quantity',1); 
                                                            
                                                            if(lineItemObj4thlevel.MCOnline_Agreement_controlled_service__c=='Mandatory')
                                                                childProductResultObj4thlevel.put('minQuantity',1);
                                                            
                                                        }else if(lineItemObj4thlevel.MCOnline_Agreement_controlled_service__c=='Optional'){
                                                            if(childProductResultObj4thlevel.get('minQuantity')==0)
                                                                childProductResultObj4thlevel.put('Quantity',0);
                                                        }*/
                                                        
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
                                                        childProductspriceResult4thlevel[z]=(Object)grand_childProductagreeObj4thlevel;
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
                        Map<String, Object> result = (Map<String, Object>)offerdetailsMap.get('result');
                        Map<String, Object> offerDetails = (Map<String, Object>)result.get('offerDetails');
                        Map<String, Object> offer = (Map<String, Object>)offerDetails.get('offer');
                        for(Object obj: productList){
                            mapAttributes(offer,obj,copyOrderflag);
                        }
                                      
                        
                        offerdetailsMap.put('basketLineRelationId',basketLineRelationId);
                        offerdetailsMap.put('basketLineRelationCount',basketLineRelationCount);
                        outMap.put('getOfferDetailOutput', offerdetailsMap);
                        outMap.put('ContractId',ContractId);
                        outMap.put('ProductName',productName);
                        outMap.put('Catalog',catalog);
                        
                        
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
            if(Test.isRunningTest()) {
                offerdetailsMap=outMap;
            }
            else
            {
                input.put('apiName','getOfferDetails');
                input.put('catalogCode',catalog);
                input.put('requestURL', '/v3/catalogs/'+catalog+'/offers/'+offerCode);
                vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
                appHandler.invokeMethod('getOfferDetailsByCatalogCode', input, output, option);
                //system.debug('std getOfferDetails--> '+JSON.serialize(output));   
                offerdetailsMap=output;  
            }
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
                MCOnline_Utility.logError(final_message,errorCode,'MCOnline_GetBasketDetails','Apex Class','Exception',inputData,'',''); 
                
            }
            else{
                outMap.put('ErrorResponse',MCOnline_Utility.generateError(error_message,errorCode,'custom','GetOffersDetails'));
                MCOnline_Utility.logError(final_message,'500','MCOnline_GetBasketDetails','Apex Class','Exception',inputData,'',''); 
                
            }
            outMap.put('StatusCode', 500);
            
        }   
        return outMap;
    }
    
}