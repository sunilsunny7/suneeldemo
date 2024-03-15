/* ______________________________________________________________________________________________________
 * ******************************************************************************************************
 * This class is the remote class of the GetOfferDetails API where the remote method getOffersDetails_V2
   and trim is called.
 * This class is custom class for the standard GetOfferDetails.
 * In this class, logic for Error Handling, Agreement Controller Services is present along with Triming 
   of output response coming from Standard getOfferdetails response.
 * The Output response will give all the products details present in the contract line items. 
 * ______________________________________________________________________________________________________
 * @author         Binamra Guha <binamra.a.guha@capgemini.com>
 * @modifiedBy     
 * @maintainedBy   
 * @version        2.0
 * @created        2021-07-13
 * @modified
 * ______________________________________________________________________________________________________
 * ******************************************************************************************************
*/
global with sharing class MCOnline_GetOffersDetails_V2 implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        if(methodName.equals('getOffersDetails_V2'))
        {  
            //getOffersDetails_V2(inputMap, outMap, options);
            //trim(inputMap, outMap);
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
    /*
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
            String ContractId=inputMap.get('Agreementid')+'';
            vlocity_cmt__ContractLineItem__c agreeList = [Select id, TeliaSE_SubsidisedVoice__c from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =:ContractId AND vlocity_cmt__ProductCode__c IN:offercodeset];
            Map<String,Object> rootData=(Map<String,Object>)outMap.get('HA_GetOffersFromDgCommerce');
            Map<String,Object> result=(Map<String,Object>)rootData.get('result');
            Map<String,Object> offerDetails=(Map<String,Object>)result.get('offerDetails');
            Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
            
    
            removeNodes(offer,finalNodes,agreeList);
            outMap.put('HA_GetOffersFromDgCommerce',rootData);
        }catch(Exception e){
            outMap.put('d',e.getMessage()+e.getLineNumber());
            errorList.add(e.getStackTraceString());
        }
    }
    //Added by Binamra Guha
    
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
                }
            }
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
    
    public static Map<String,Object> generateError(string error,string errorCode,string errorType,Map<String,Object> inputMap){
        
        string offer = String.Valueof(inputMap.get('offer'));
        String AgreementId = String.valueOf(inputMap.get('AgreementId'));
        string Catalog= String.Valueof(inputMap.get('Catalog'));
        
        string urlDetails = '{"Agreementid": "'+AgreementId+'", "catalog":"'+Catalog+'", "offer":"'+offer+'"}'; 
        
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        ipInputMap.put('functionality', 'GetOffersDetails');
        ipInputMap.put('error', error);   
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_GetOffersDetails_V2.generateError','Apex Class', 'Custom Error','STRING_TOO_LONG','','',urlDetails);
        
        return MCOnline_Utility.getError(ipInputMap);
    }
    
    public static void getOffersDetails_V2(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        
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
            String ContractId= Id.valueof((string)inputMap.get('Agreementid'));
            
            agreementLineItems = [ Select id,MCOnline_Agreement_controlled_service__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__ContractId__c,TeliaSE_Approved_Price__c,TeliaSE_MC_Customer_Requested_Price__c,
                                  TeliaSE_Start_Date__c,TeliaSE_End_Date__c,vlocity_cmt__ProductCode__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__RecurringTotal__c 
                                  FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ContractId__c =:ContractId  ];
            
            offerdetailsMap=(Map<String, Object>)inputMap.get('HA_GetOffersFromDgCommerce');
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
                
                for(vlocity_cmt__ContractLineItem__c lineItemObj: agreementLineItems){
                    //system.debug('--agreementLineObj--'+agreementLineObj);
                    //Map<String, Object> lineItemObj = (Map<String, Object>)agreementLineObj;
                    System.debug('Price result : '+priceResult);
                    System.debug('OfferOBj ProdCode : '+offerObj1.get('ProductCode'));
                    System.debug('OfferOBj ProdCode equalsIg : '+lineItemObj.vlocity_cmt__ProductCode__c);
                    if(priceResult!= null && (String.valueOf(offerObj1.get('ProductCode')).equalsIgnoreCase(lineItemObj.vlocity_cmt__ProductCode__c))){
                        Map<String, Object> agreeObj = new Map<String, Object>();
                        
                        if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Non-selectable')
                        {    //isNonSelectableRootlevel=true;
                        }
                        else if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Mandatory ')
                            isMandatoryRootlevel=true;
                        
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
                }
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
                                
                                if(childProductResultObj.containskey('Ordering_Flag__c') && String.valueOf(childProductResultObj.get('Ordering_Flag__c'))=='Hide')
                                    orderable_flag_3rdlevel_hide=true;
                                
                                List<Object> childproductList4thlevel = new List<Object>();
                                childproductList4thlevel= (List<Object>)childProductResultObj.get('childProducts');                       
                                List<Object> childproductList4thlevel_temp = new List<Object>();
                                
                                for(vlocity_cmt__ContractLineItem__c lineItemObj: agreementLineItems){
                                    
                                    //Map<String, Object> lineItemObj = (Map<String, Object>)agreementLineObj;            
                                    // For Parent Node(child Product) 2nd level
                                    
                                    if((isProductGroupCodeMapped==false) && productGroupspriceResult!= null && (String.valueOf(productGroupspriceResultObj.get('ProductCode')).equalsIgnoreCase(lineItemObj.vlocity_cmt__ProductCode__c))){
                                        isProductGroupCodeMapped=true;
                                        childProducts2ndLevel_negotiated=true;
                                        
                                        if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Non-selectable')
                                        {   isNonSelectable2ndlevel=true; 
                                        }
                                        else if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Mandatory' || lineItemObj.MCOnline_Agreement_controlled_service__c=='Pre-selected'){
                                            isMandatory2ndlevel=true;
                                            productGroupspriceResultObj.put('Quantity',1);
                                            
                                            if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Mandatory')
                                                productGroupspriceResultObj.put('minQuantity',1);
                                            
                                        }else if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Optional'){
                                            if(productGroupspriceResultObj.get('minQuantity')==0)
                                                productGroupspriceResultObj.put('Quantity',0);
                                        }
                                        
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
                                    } 
                                    
                                    // For Grand Child product node 3rd level
                                    if(childProductspriceResult!= null && (String.valueOf(childProductResultObj.get('ProductCode')).equalsIgnoreCase(lineItemObj.vlocity_cmt__ProductCode__c))){
                                        Map<String, Object> grand_childProductagreeObj = new Map<String, Object>();
                                        grand_childProductagreeObj=(Map<String, Object>)childProductspriceResult[0] ;
                                        
                                        if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Non-selectable')
                                        {  isNonSelectable3rdlevel=true; 
                                        }
                                        else if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Mandatory' || lineItemObj.MCOnline_Agreement_controlled_service__c=='Pre-selected'){
                                            isMandatory3rdlevel=true;
                                            childProductResultObj.put('Quantity',1);
                                            
                                            if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Mandatory')
                                                childProductResultObj.put('minQuantity',1);
                                            
                                        }else if(lineItemObj.MCOnline_Agreement_controlled_service__c=='Optional'){
                                            if(childProductResultObj.get('minQuantity')==0)
                                                childProductResultObj.put('Quantity',0);
                                        }
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
                                        childProductspriceResult[0]=(Object)grand_childProductagreeObj ;
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
                                        
                                        if(childProductResultObj4thlevel.containskey('Ordering_Flag__c') && String.valueOf(childProductResultObj4thlevel.get('Ordering_Flag__c'))=='Hide')
                                            orderable_flag_4thlevel_hide=true;
                                        
                                        for(vlocity_cmt__ContractLineItem__c lineItemObj4thlevel: agreementLineItems){
                                            //Map<String, Object> lineItemObj4thlevel = (Map<String, Object>)agreementLineObj4thlevel;            
                                            
                                            if(childProductspriceResult4thlevel!= null && (String.valueOf(childProductResultObj4thlevel.get('ProductCode')).equalsIgnoreCase(lineItemObj4thlevel.vlocity_cmt__ProductCode__c))){
                                                Map<String, Object> grand_childProductagreeObj4thlevel = new Map<String, Object>();
                                                grand_childProductagreeObj4thlevel=(Map<String, Object>)childProductspriceResult4thlevel[0] ;                                                                 
                                                
                                                if(lineItemObj4thlevel.MCOnline_Agreement_controlled_service__c=='Non-selectable')
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
                                                }
                                                
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
                                                childProductspriceResult4thlevel[0]=(Object)grand_childProductagreeObj4thlevel  ;
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
                
                
                outMap.put('HA_GetOffersFromDgCommerce', offerdetailsMap);
                
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
            offerdetailsMap=(Map<String, Object>)inputMap.get('HA_GetOffersFromDgCommerce');
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
                MCOnline_Utility.logError(final_message,errorCode,'MCOnline_GetOffersDetails_V2','Apex Class','Exception',inputData,'',''); 
                
            }
            else{
                outMap.put('ErrorResponse',MCOnline_Utility.generateError(error_message,errorCode,'custom','GetOffersDetails'));
                MCOnline_Utility.logError(final_message,'500','MCOnline_GetOffersDetails_V2','Apex Class','Exception',inputData,'',''); 
                
            }
            outMap.put('StatusCode', 500);
            
        }   
        
    }
 */   
}