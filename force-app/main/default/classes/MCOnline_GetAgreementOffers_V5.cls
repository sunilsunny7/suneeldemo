/* 
* ******************************************************************************************************
* @author         Ajay Nagar
* @modifiedBy     Binamra Guha, Aparajita Banerjee
* @maintainedBy   All
* @version        1.0
* @created        2020-10-14
* @modified       09-07-2022 ---> Restructuring the class, and RAM/MFA logic included
*
* ******************************************************************************************************
*/
/*
* ******************************************************************************************************
* This class is responsible for GetAgreementOffer API.
* This API exposes both negotiable and non negotiable offers.
* It also shows the contract details along with it's line items.
* ******************************************************************************************************
*/
global with sharing class MCOnline_GetAgreementOffers_V5 implements vlocity_cmt.VlocityOpenInterface 
{    
    private static Set<String> offercodeset=new Set<String>(); 
    private static Map<String,String> prodcodeVsCatalogCode = new Map<String,String>();
    private static Map<String,Integer> sequenceOfferMap= new Map<String,Integer>();
    private static List<String> offerProduct = new List<String>();
    private static Map<String,List<Map<String,String>>> catalogVsOfferMaplst = new Map<String,List<Map<String,String>>>();
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) 
    {    
        if(methodName.equals('getAgreementOffers'))
        {  
            getAgreementOffers(inputMap, outMap, options);
        }
        return true;
    }
    @TestVisible
    private static Map<String,Object> generateError(string errorCode,string errorType, string functionality, Map<String,Object> inputMap){
        String tscid='';
        if(inputMap.containsKey('TSCID')){
            tscid= (string)inputMap.get('TSCID');
        }
        Map<String,Object> ipInputMap = new Map<String,Object>();
        string urlDetails = '{"tscid": "'+tscid+'"}'; 
        ipInputMap.put('functionality', functionality); 
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_GetAgreementOffers_V5,MCOnline_GetAgreementOffers_V5.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    /*
* ************************************************************************************************************
* Overview:-
* getAgreementOffers method is used for fetching the owner account or utilizer account.
* Using TSCID as a input, the active contract get fetched.
* This method also includes the error handling logic.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param options                                  Map containing the query parameter
* ************************************************************************************************************
*/ 
    @TestVisible
    private static void getAgreementOffers(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {        
        List<Account> accountList = new List<Account>(); 
        List<Contract> agreementList = new List<Contract>();
        String tscid, error_message;
        List<Map<String,object>> getNonNegotiableProductsList = new List<Map<String,object>>();
        try{
            if(inputMap != null && inputMap.containsKey('TSCID')){
                tscid= (string)inputMap.get('TSCID');
                if(String.isBlank(tscid)){
                    outMap.put('ErrorResponse', generateError('MISSING_INPUT','custom','GetAgreementOffers', inputMap));
                    outMap.put('StatusCode', 400);
                }else{
                    accountList = [SELECT id, name, TeliaSE_Utilzer_Role__c FROM Account Where tscid__c =: tscid WITH SECURITY_ENFORCED limit 1];
                    if(!accountList.isEmpty()){
                        getCatalogProductRelationships(inputMap, outMap, options);
                        Set<Id> contractIdSet=new Set<Id>();
                        for(Utilizer_Contract_Relationship__c utilizer:[Select ContractNumber__c FROM Utilizer_Contract_Relationship__c WHERE AccountId__c=:accountList[0].id AND Status__c = 'Aktiv' AND ContractNumber__c!=null WITH SECURITY_ENFORCED]){
                            contractidset.add(utilizer.ContractNumber__c);
                        }
                        List<Map<String,object>> getNegotiableProductsList = new List<Map<String,object>>();
                        for(contract contr: [SELECT id,name,Mconline_Status__c,ContractNumber,Agreement_Nr__c,CreatedDate,MC_Owner_Status__c,Contract_Record_Type__c, (SELECT vlocity_cmt__Product2Id__r.ProductCode FROM vlocity_cmt__ContractLineItems__r Where vlocity_cmt__Product2Id__r.ProductCode IN: offerProduct), AccountId,Status,Type_of_Agreement__c FROM contract where MC_Owner_Status__c in('VALID','EXISTS',null) AND (AccountId=:accountList[0].Id OR Id IN: contractidset) And Contract_Record_Type__c IN ('Ramavtal', 'MFA ReadOnly', 'RAM ReadOnly','EMR Readonly') And Status='Active' and Mconline_Status__c in ('Valid','Freezed')  WITH SECURITY_ENFORCED ORDER BY EndDate DESC])
                        {
                            if(!contr.vlocity_cmt__ContractLineItems__r.isEmpty()){
                                agreementList.add(contr);
                            }
                        }
                        if(!agreementList.isEmpty()){
                            getNonNegotiableProductsList = getNonNegotiableProducts(inputMap, outMap, options);
                            getNegotiableProductsList = getNegotiableProducts(inputMap, outMap, options, agreementList, accountList);
                        }else{
                            outMap.put('ErrorResponse', generateError('INVALID_AGREEMENT','custom','GetAgreementOffers', inputMap));
                            outMap.put('StatusCode', 400);
                        }
                        outMap.put('agreement',getNegotiableProductsList);
                    }else{
                        outMap.put('ErrorResponse' , generateError('INVALID_TSCID','custom','GetAgreementOffers', inputMap));
                        outMap.put('StatusCode' , 400);
                    }
                }
            }else{
                getCatalogProductRelationships(inputMap, outMap, options);
                getNonNegotiableProductsList = getNonNegotiableProducts(inputMap, outMap, options);
            }
            outMap.put('catalog',getNonNegotiableProductsList);
        }catch(Exception e){
            error_message = e.getMessage()+' line:'+ e.getLineNumber();
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR','custom','GetAgreementOffers', inputMap));
            outMap.put('StatusCode' , 500);
            MCOnline_Utility.logError(error_message,'500','MCOnline_GetAgreementOffers_V5','Apex Class','Exception',JSON.serialize(inputMap),'','','');
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* getCatalogProductRelationships method is used for getting the offer and catalog relationship.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param options                                  Map containing the query parameter
* ************************************************************************************************************
*/     
    @TestVisible
    private static void getCatalogProductRelationships(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        for(vlocity_cmt__CatalogProductRelationship__c pr:[SELECT id, vlocity_cmt__Product2Id__r.C2BC_Category__c,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__SequenceNumber__c, vlocity_cmt__Product2Id__r.C2BC_Subcategory__c,vlocity_cmt__Product2Id__r.Ordering_Flag__c, vlocity_cmt__CatalogId__r.vlocity_cmt__IsActive__c, vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c, Name FROM vlocity_cmt__CatalogProductRelationship__c WHERE vlocity_cmt__IsActive__c=true AND vlocity_cmt__CatalogId__c!=null WITH SECURITY_ENFORCED]){
            if(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__IsActive__c==true){
                List<Map<String,String>> catalogOfferMaplist = new List<Map<String,String>>();
                Map<String,String> catalogOfferMap = new Map<String,String>();
                sequenceOfferMap.put(pr.vlocity_cmt__Product2Id__r.ProductCode, Integer.valueOf(pr.vlocity_cmt__SequenceNumber__c));
                offercodeset.add(pr.Name);
                offerProduct.add(pr.vlocity_cmt__Product2Id__r.ProductCode);
                prodcodeVsCatalogCode.put(pr.Name,pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c);
                catalogOfferMap.put('name',pr.Name);
                catalogOfferMap.put('ordering_flag',pr.vlocity_cmt__Product2Id__r.Ordering_Flag__c);
                catalogOfferMap.put('product_category',pr.vlocity_cmt__Product2Id__r.C2BC_Category__c);
                catalogOfferMap.put('product_subcategory',pr.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c);
                if(catalogVsOfferMaplst!=null && catalogVsOfferMaplst.containskey(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c)){
                    catalogOfferMaplist=catalogVsOfferMaplst.get(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c);
                    catalogOfferMaplist.add(catalogOfferMap);
                    catalogVsOfferMaplst.put(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c,catalogOfferMaplist);
                }else{
                    catalogOfferMaplist.add(catalogOfferMap);
                    catalogVsOfferMaplst.put(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c,catalogOfferMaplist);
                }
            }
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* getNonNegotiableProducts method is used for getting the offers which are not present in cli.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param options                                  Map containing the query parameter
* ************************************************************************************************************
*/    
    @TestVisible
    private static List<Map<String,object>> getNonNegotiableProducts(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        List<Map<String,object>> cataloglst = new List<Map<String,object>>();
        Map<string,CatalogAgreement__c> filtermap = CatalogAgreement__c.getall();                    
        if(catalogVsOfferMaplst!=null && catalogVsOfferMaplst.size()>0){
            for(String str:catalogVsOfferMaplst.keySet()){
                if(filtermap!=null && filtermap.containskey(str) && filtermap.get(str).Non_Negotiable_Catalog__c==true){
                    Map<String,object> catalogMap = new Map<String,object>();   
                    catalogMap.put('name',str );
                    catalogMap.put('offers',catalogVsOfferMaplst.get(str) );
                    cataloglst.add(catalogMap);
                }
            }
        }
        return cataloglst;
    }
    /*
* ************************************************************************************************************
* Overview:-
* getNegotiableProducts method is used for getting the offers which present in cli.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user* @param outMap                                   Map that contains the output response
* @param options                                  Map containing the query parameter
* @param agreement_lst                            Agreement details
* @param tscid_aclst                              Account details
* ************************************************************************************************************
*/     
    @TestVisible
    private static List<Map<String,object>> getNegotiableProducts(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options, List<contract> agreement_lst, List<Account> tscid_aclst)
    {
        List<Map<String,object>> agreementlst = new List<Map<String,object>>();
        String ramAgreementNumber;
        Map<String,Boolean> ramOffers=new Map<String,Boolean>{'mobilevoicesubscription'=>false,'smartconnect'=>false,'touchpoint'=>false};
        Set<Id> agreementIdset = (new Map<Id,contract>(agreement_lst)).keySet();
        List<vlocity_cmt__ContractLineItem__c> agreementLineItem_lst=[SELECT id,name,vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Agreement_Nr__c,vlocity_cmt__ContractId__r.Contract_Record_Type__c,vlocity_cmt__ProductCode__c,vlocity_cmt__Product2Id__r.Ordering_Flag__c, vlocity_cmt__Product2Id__r.C2BC_Category__c,vlocity_cmt__Product2Id__r.C2BC_Subcategory__c,vlocity_cmt__Product2Id__r.Family,MC_Show_Subscription_In_Channel__c FROM vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c IN: agreementIdset And TeliaSE_ParentItemId__c=null AND vlocity_cmt__ProductCode__c IN:offercodeset and MC_Show_Subscription_In_Channel__c !='N' WITH SECURITY_ENFORCED];
        if(!agreementLineItem_lst.isEmpty()){
            Set<String> virtualofferset= new Set<String>();
            
                for(vlocity_cmt__ContractLineItem__c agrLine: agreementLineItem_lst){
                    if(agrLine.vlocity_cmt__ContractId__r.Contract_Record_Type__c == 'Ramavtal'
                       && agrLine.vlocity_cmt__Product2Id__c != null 
                       && ramOffers.containsKey(agrLine.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c))
                    {
                        ramAgreementNumber=agrLine.vlocity_cmt__ContractId__r.Agreement_Nr__c;
                        ramOffers.put(agrLine.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c,true);
                    }
                }

            for(vlocity_cmt__ContractLineItem__c agrLine: agreementLineItem_lst)
            {
                if((agrLine.vlocity_cmt__ContractId__r.Contract_Record_Type__c == 'Ramavtal' || agrLine.vlocity_cmt__ContractId__r.Contract_Record_Type__c =='EMR Readonly') && agrLine.vlocity_cmt__Product2Id__c!= null)
                {
                    virtualofferset.add(agrLine.vlocity_cmt__ProductCode__c);
                }
                else if(agrLine.vlocity_cmt__Product2Id__r !=null && !ramOffers.get(agrLine.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c) && (ramAgreementNumber == agrLine.vlocity_cmt__ContractId__r.Agreement_Nr__c))
                {
                    virtualofferset.add(agrLine.vlocity_cmt__ProductCode__c);
                }
                else if((ramAgreementNumber != agrLine.vlocity_cmt__ContractId__r.Agreement_Nr__c))
                {
                    virtualofferset.add(agrLine.vlocity_cmt__ProductCode__c);
                }
            }
            Map<String,List<vlocity_cmt__ProductChildItem__c>> offervsSubsbundle=new Map<String,List<vlocity_cmt__ProductChildItem__c>>();
            if(!virtualofferset.isEmpty()){
                for(vlocity_cmt__ProductChildItem__c pr:[SELECT id,vlocity_cmt__ChildLineNumber__c, vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ParentProductId__c,vlocity_cmt__ParentProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.Ordering_Flag__c, vlocity_cmt__ChildProductId__r.C2BC_Category__c, vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c FROM vlocity_cmt__ProductChildItem__c WHERE vlocity_cmt__ParentProductId__r.C2BC_Category__c = 'offerbundle' AND vlocity_cmt__ParentProductId__r.ProductCode IN:virtualofferset AND vlocity_cmt__ParentProductId__r.Family ='Online Order' and vlocity_cmt__ChildProductId__c !=null WITH SECURITY_ENFORCED]){
                    if(pr.vlocity_cmt__ParentProductId__r.ProductCode != null && offervsSubsbundle.get(pr.vlocity_cmt__ParentProductId__r.ProductCode)!=null){
                        offervsSubsbundle.get(pr.vlocity_cmt__ParentProductId__r.ProductCode).add(pr);
                    }else{
                        offervsSubsbundle.put(pr.vlocity_cmt__ParentProductId__r.ProductCode, new List<vlocity_cmt__ProductChildItem__c>{pr});
                    }
                }
            }
            for(contract agr: agreement_lst){
                Boolean hasLineItems=false;
                Map<String,object> agreementMap = new Map<String,object>();
                agreementMap.put('id',agr.id);
                agreementMap.put('ContractNumber',agr.ContractNumber);
                agreementMap.put('madamAgreementStatus',agr.Mconline_Status__c);
                agreementMap.put('contractRecordType',agr.Contract_Record_Type__c);
                agreementMap.put('agreementType',agr.Type_of_Agreement__c);//Agreement Type addition
                agreementMap.put('madamAgreementNumber',agr.Agreement_Nr__c);// Madam Agreement Number
                agreementMap.put('accountid',tscid_aclst[0].Id);   // agr.AccountId
                if(agr.Contract_Record_Type__c=='MFA ReadOnly'){
                agreementMap.put('role','Owner');
                }
                else{
                agreementMap.put('role',tscid_aclst[0].TeliaSE_Utilzer_Role__c); // Role of the Organisation MCONL-12373 
                }
                agreementMap.put('status',agr.Status);
                agreementMap.put('agreementOwnerStatus',agr.MC_Owner_Status__c);
                agreementMap.put('CreatedDate',agr.CreatedDate);//LTAT-10214 (Added by Itishree)
                Set<Map<String,Object>> lineItemlst = new Set<Map<String,Object>>();
                Map<Integer,Map<String,Object>> ItemlstTempMap = new Map<Integer,Map<String,Object>>();
                for(vlocity_cmt__ContractLineItem__c agrLine: agreementLineItem_lst){
                if(agrLine.vlocity_cmt__ContractId__r.Contract_Record_Type__c != 'Ramavtal' && agrLine.vlocity_cmt__ContractId__r.Agreement_Nr__c==ramAgreementNumber && ramOffers.get(agrLine.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c)  )
                {
                    continue;
                }
                    if(agr.id==agrLine.vlocity_cmt__ContractId__c){
                        if(offervsSubsbundle!=null && offervsSubsbundle.containskey(agrLine.vlocity_cmt__ProductCode__c)){
                            List<vlocity_cmt__ProductChildItem__c> subscriptionbundlelst=new List<vlocity_cmt__ProductChildItem__c>();
                            subscriptionbundlelst= offervsSubsbundle.get(agrLine.vlocity_cmt__ProductCode__c);
                            for(vlocity_cmt__ProductChildItem__c str: subscriptionbundlelst)
                            {
                                hasLineItems=true;
                                Map<String,Object> lineItemMap = new Map<String,Object>();
                                if(agrLine.vlocity_cmt__ProductCode__c=='AGR_EMN_OFFER')
                                {
                                    lineItemMap.put('id',agrLine.id);
                                    lineItemMap.put('productcode',agrLine.vlocity_cmt__ProductCode__c);
                                    lineItemMap.put('sequence','1');
                                    lineItemMap.put('ordering_flag',agrLine.vlocity_cmt__Product2Id__r.Ordering_Flag__c);
                                    lineItemMap.put('product_category',agrLine.vlocity_cmt__Product2Id__r.C2BC_Category__c);
                                    lineItemMap.put('product_subcategory',agrLine.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c);
                                    if(prodcodeVsCatalogCode!=null && prodcodeVsCatalogCode.containskey(agrLine.vlocity_cmt__ProductCode__c)){
                                        lineItemMap.put('catalog',prodcodeVsCatalogCode.get(agrLine.vlocity_cmt__ProductCode__c));
                                    }
                                    ItemlstTempMap.put(1,lineItemMap);
                                }
                                else
                                {
                                    String prodCode=str.vlocity_cmt__ChildProductId__r.ProductCode.endsWith('_VO')?str.vlocity_cmt__ChildProductId__r.ProductCode.substring(0,str.vlocity_cmt__ChildProductId__r.ProductCode.length()-3):str.vlocity_cmt__ChildProductId__r.ProductCode;
                                    lineItemMap.put('id',agrLine.id);
                                    lineItemMap.put('productcode',prodCode);
                                    lineItemMap.put('sequence',str.vlocity_cmt__ChildLineNumber__c);
                                    lineItemMap.put('ordering_flag',str.vlocity_cmt__ChildProductId__r.Ordering_Flag__c);
                                    lineItemMap.put('product_category',str.vlocity_cmt__ChildProductId__r.C2BC_Category__c);
                                    lineItemMap.put('product_subcategory',str.vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c);
                                    if(prodcodeVsCatalogCode!=null && prodcodeVsCatalogCode.containskey(agrLine.vlocity_cmt__ProductCode__c)){
                                        lineItemMap.put('catalog',prodcodeVsCatalogCode.get(agrLine.vlocity_cmt__ProductCode__c));
                                    }
                                    ItemlstTempMap.put(Integer.valueof(str.vlocity_cmt__ChildLineNumber__c),lineItemMap);
                                }   
                            }
                            for(Integer i=0;i<ItemlstTempMap.size();i++){
                                lineItemlst.add(ItemlstTempMap.get(i+1));
                            }
                        }
                    }
                }
                agreementMap.put('lineItem',lineItemlst);
                if(hasLineItems){
                    agreementlst.add(agreementMap);
                }
            } 

                
        }else{
            outMap.put('ErrorResponse' , generateError('NO_LINEITEM','custom','GetAgreementOffers', inputMap));
            outMap.put('StatusCode' , 400);
        }
        return agreementlst;
    }
}