global with sharing class MCOnline_GetAgreementOffers_V3 implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        if(methodName.equals('getAgreementOffers_V3'))
        {  
            getAgreementOffers_V3(inputMap, outMap, options);
        }
        return true;
    }
    
    public static Map<String,Object> generateError(string errorCode,string errorType, string functionality, Map<String,Object> inputMap){
        
        String tscid= (string)inputMap.get('TSCID');
        
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        
        string urlDetails = '{"tscid": "'+tscid+'"}'; 
        ipInputMap.put('functionality', functionality); 
        ipInputMap.put('errorType', errorType);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_getAgreementOffers_V3,MCOnline_GetAgreementOffers_V3.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
        
    }
    
    public static void getAgreementOffers_V3(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        
        Map<String, Object> ipInputMap = new Map<String, Object>();
        Map<String, Object> ipOutputMap = new Map<String, Object>();
        Map<String, Object> agreementOfferMap = new Map<String, Object>();
        Map<String, Object> agrofferObj1 = new Map<String, Object>();
        
        List<Account> tscid_aclst=new List<Account>(); 
        List<contact> tscid_conlst=new List<contact>(); 
        List<contract> agreement_lst=new List<contract>();
        List<vlocity_cmt__ContractLineItem__c> agreementLineItem_lst=new List<vlocity_cmt__ContractLineItem__c>();
        String error_message=' ';
        String errorCode;
        boolean hasError = false; 
        Try{ 
            String tscid;
            tscid= (string)inputMap.get('TSCID');
            if(String.isBlank(tscid)){
                //Blank TSCID
                hasError = true;
                
                outMap.put('ErrorResponse' , generateError('MISSING_INPUT','custom','GetAgreementOffers', inputMap));
                outMap.put('StatusCode' , 400);
            }else{
                tscid_aclst=[SELECT id, name, TeliaSE_Utilzer_Role__c  
                             FROM Account 
                             Where tscid__c =: tscid limit 1];
                
                if(tscid_aclst!=null && tscid_aclst.size()>0){
                    
                    Set<Id> contractidset=new Set<Id>(); 
                    List<Utilizer_Contract_Relationship__c> utilizerlst= new List<Utilizer_Contract_Relationship__c>();
                    utilizerlst =[Select ContractNumber__c  FROM Utilizer_Contract_Relationship__c WHERE AccountId__c=:tscid_aclst[0].Id AND ContractNumber__c!=null];
                    
                    For(Utilizer_Contract_Relationship__c ut:utilizerlst)
                        contractidset.add(ut.ContractNumber__c);
                    
                    agreement_lst=[SELECT id,name,ContractNumber,Agreement_Nr__c,AccountId,Status,Type_of_Agreement__c  
                                   FROM contract 
                                   where (AccountId=:tscid_aclst[0].Id OR Id IN: contractidset) And Contract_Record_Type__c='Ramavtal' And Status='Active' ORDER BY EndDate DESC Limit 1];
                    
                    List<Map<String,object>> agreementlst = new List<Map<String,object>>();
                    Map<String,List<Map<String,String>>> catalogVsOfferMaplst = new Map<String,List<Map<String,String>>>();
                    List<Map<String,object>> cataloglst = new List<Map<String,object>>();
                    System.debug('Agreement List :'+agreement_lst);
                    if(agreement_lst!=null && agreement_lst.size()>0){ 
                        List<vlocity_cmt__CatalogProductRelationship__c> catalogproductrelationshiplst  = new List<vlocity_cmt__CatalogProductRelationship__c>();
                        
                        catalogproductrelationshiplst=[ SELECT id, vlocity_cmt__Product2Id__r.C2BC_Category__c,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__SequenceNumber__c, vlocity_cmt__Product2Id__r.C2BC_Subcategory__c, 
                                                        vlocity_cmt__Product2Id__r.Ordering_Flag__c, vlocity_cmt__CatalogId__r.vlocity_cmt__IsActive__c, vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c, Name FROM vlocity_cmt__CatalogProductRelationship__c 
                                                        WHERE vlocity_cmt__IsActive__c=true AND vlocity_cmt__CatalogId__c!=null];
                        
                        Set<String> offercodeset=new Set<String>(); 
                        Map<String,String> prodcodeVsCatalogCode = new Map<String,String>();
                        Map<String,Integer> sequenceOfferMap= new Map<String,Integer>();
                        if(catalogproductrelationshiplst!=null && catalogproductrelationshiplst.size()>0){
                            for(vlocity_cmt__CatalogProductRelationship__c pr:catalogproductrelationshiplst){
                                if(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__IsActive__c==true){
                                    List<Map<String,String>> catalogOfferMaplst = new List<Map<String,String>>();
                                    Map<String,String> catalogOfferMap = new Map<String,String>();
                                    sequenceOfferMap.put(pr.vlocity_cmt__Product2Id__r.ProductCode, Integer.valueOf(pr.vlocity_cmt__SequenceNumber__c));
                                    offercodeset.add(pr.Name);
                                    prodcodeVsCatalogCode.put(pr.Name,pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c);
                                    catalogOfferMap.put('name',pr.Name);
                                    catalogOfferMap.put('ordering_flag',pr.vlocity_cmt__Product2Id__r.Ordering_Flag__c);
                                    catalogOfferMap.put('product_category',pr.vlocity_cmt__Product2Id__r.C2BC_Category__c);
                                    catalogOfferMap.put('product_subcategory',pr.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c);
                                    if(catalogVsOfferMaplst!=null && catalogVsOfferMaplst.size()>0 && catalogVsOfferMaplst.containskey(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c)){
                                        catalogOfferMaplst=catalogVsOfferMaplst.get(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c);
                                        catalogOfferMaplst.add(catalogOfferMap);
                                        catalogVsOfferMaplst.put(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c,catalogOfferMaplst);
                                    }else{
                                        catalogOfferMaplst.add(catalogOfferMap);
                                        catalogVsOfferMaplst.put(pr.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c,catalogOfferMaplst);
                                    }
                                }
                                
                            }
                            
                        }
                        
                        Map<string,CatalogAgreement__c> filtermap = CatalogAgreement__c.getall();
                        
                        if(catalogVsOfferMaplst!=null && catalogVsOfferMaplst.size()>0){
                            for(String str:catalogVsOfferMaplst.keySet()){
                                System.debug('filterMap :'+filtermap);
                                System.debug('Str Value :'+str);
                                
                                if(filtermap!=null && filtermap.size()>0 && filtermap.containskey(str) && filtermap.get(str).Non_Negotiable_Catalog__c==true){
                                    Map<String,object> catalogMap = new Map<String,object>();   
                                    catalogMap.put('name',str );
                                    catalogMap.put('offers',catalogVsOfferMaplst.get(str) );
                                    cataloglst.add(catalogMap);
                                }
                            }
                        }
                        
                        Set<Id> agreementIdset=new Set<Id>(); 
                        for(contract agr: agreement_lst){
                            agreementIdset.add(agr.Id);
                        }
                        
                        agreementLineItem_lst=[SELECT id,name,vlocity_cmt__ContractId__c,vlocity_cmt__ProductCode__c,vlocity_cmt__Product2Id__r.Ordering_Flag__c, vlocity_cmt__Product2Id__r.C2BC_Category__c,vlocity_cmt__Product2Id__r.C2BC_Subcategory__c,vlocity_cmt__Product2Id__r.Family
                                               FROM vlocity_cmt__ContractLineItem__c 
                                               where vlocity_cmt__ContractId__c IN: agreementIdset And TeliaSE_ParentItemId__c=null AND vlocity_cmt__ProductCode__c IN:offercodeset ];
                        
                        Set<String> virtualofferset= new Set<String>(); 
                        Map<String,List<string>> offervsSubsbundle=new Map<String,List<string>>();
                        List<vlocity_cmt__ProductChildItem__c> prodChildlst=new List<vlocity_cmt__ProductChildItem__c>();
                        
                        for(contract agr: agreement_lst){
                            if(agreementLineItem_lst!=null && agreementLineItem_lst.size()>0){
                                for(vlocity_cmt__ContractLineItem__c agrLine: agreementLineItem_lst){
                                    if(agr.id==agrLine.vlocity_cmt__ContractId__c){
                                        virtualofferset.add(agrLine.vlocity_cmt__ProductCode__c);
                                    }
                                }
                            }
                        }
                        Map<String,String> offerbundleVsSequence=new Map<String,String>();
                        Map<String, String> offerBunleOrderingFlag = new Map<String,String>();                  
                        Map<String, String> offerBunleProdCategory = new Map<String,String>();                  
                        Map<String, String> offerBunleProdSubCategory = new Map<String,String>();                   
                        if(virtualofferset!=null && virtualofferset.size()>0){
                            
                            prodChildlst=[SELECT id,vlocity_cmt__ChildLineNumber__c, vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ParentProductId__c,vlocity_cmt__ParentProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.Ordering_Flag__c, vlocity_cmt__ChildProductId__r.C2BC_Category__c, vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c
                                          FROM vlocity_cmt__ProductChildItem__c
                                          WHERE vlocity_cmt__ParentProductId__r.C2BC_Category__c = 'offerbundle' AND vlocity_cmt__ParentProductId__r.ProductCode IN:virtualofferset AND vlocity_cmt__ParentProductId__r.Family ='Online Order'];
                            
                            for(vlocity_cmt__ProductChildItem__c pr:prodChildlst){
                                
                                if(pr.vlocity_cmt__ChildProductId__c!=null && pr.vlocity_cmt__ParentProductId__r.ProductCode!=null && pr.vlocity_cmt__ParentProductId__r.ProductCode!=''){
                                    offerBunleOrderingFlag.put(pr.vlocity_cmt__ChildProductId__r.ProductCode,pr.vlocity_cmt__ChildProductId__r.Ordering_Flag__c);
                                    offerBunleProdCategory.put(pr.vlocity_cmt__ChildProductId__r.ProductCode,pr.vlocity_cmt__ChildProductId__r.C2BC_Category__c);
                                    offerBunleProdSubCategory.put(pr.vlocity_cmt__ChildProductId__r.ProductCode,pr.vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c);
                                    
                                    offerbundleVsSequence.put(pr.vlocity_cmt__ChildProductId__r.ProductCode,pr.vlocity_cmt__ChildLineNumber__c);
                                    List<string> subslst = new List<string>(); 
                                    if(offervsSubsbundle!=null && offervsSubsbundle.size()>0 && offervsSubsbundle.containskey(pr.vlocity_cmt__ParentProductId__r.ProductCode)){
                                        subslst = offervsSubsbundle.get(pr.vlocity_cmt__ParentProductId__r.ProductCode);
                                    }
                                    subslst.add(pr.vlocity_cmt__ChildProductId__r.ProductCode);
                                    offervsSubsbundle.put(pr.vlocity_cmt__ParentProductId__r.ProductCode,subslst);
                                }
                            }
                        }
                        
                        for(contract agr: agreement_lst){
                            
                            Map<String,object> agreementMap = new Map<String,object>();
                            String OverrideCommitment;
                            agreementMap.put('id',agr.id);
                            agreementMap.put('ContractNumber',agr.ContractNumber);
                            agreementMap.put('madamAgreementNumber',agr.Agreement_Nr__c);// Madam Agreement Number
                            agreementMap.put('agreementType',agr.Type_of_Agreement__c);//Agreement Type addition
                            agreementMap.put('accountid',tscid_aclst[0].Id);   // agr.AccountId
                            agreementMap.put('role',tscid_aclst[0].TeliaSE_Utilzer_Role__c); // Role of the Organisation MCONL-12373 
                            agreementMap.put('status',agr.Status);
                            //outMap.put('StatusCode' , 200);
                            
                            Set<Map<String,Object>> lineItemlst = new Set<Map<String,Object>>();
                            Map<Integer,Map<String,Object>> ItemlstTempMap = new Map<Integer,Map<String,Object>>();
                            if(agreementLineItem_lst!=null && agreementLineItem_lst.size()>0){
                                
                                for(vlocity_cmt__ContractLineItem__c agrLine: agreementLineItem_lst){
                                    
                                    if(agr.id==agrLine.vlocity_cmt__ContractId__c){
                                        if(offervsSubsbundle!=null && offervsSubsbundle.size()>0 && offervsSubsbundle.containskey(agrLine.vlocity_cmt__ProductCode__c))
                                        {   
                                            List<String> subscriptionbundlelst=new List<String>();
                                            subscriptionbundlelst= offervsSubsbundle.get(agrLine.vlocity_cmt__ProductCode__c);
                                            system.debug(subscriptionbundlelst);
                                            for(String str: subscriptionbundlelst){
                                                Map<String,Object> lineItemMap = new Map<String,Object>();
                                                lineItemMap.put('id',agrLine.id);
                                                lineItemMap.put('productcode',str);
                                                lineItemMap.put('sequence',offerbundleVsSequence.get(str));
                                                lineItemMap.put('ordering_flag',offerBunleOrderingFlag.get(str));
                                                lineItemMap.put('product_category',offerBunleProdCategory.get(str));
                                                lineItemMap.put('product_subcategory',offerBunleProdSubCategory.get(str));
                                                //if(offerbundleVsSequence!=null && offerbundleVsSequence.size()>0 && offerbundleVsSequence.containskey(str)){
                                                //    lineItemMap.put('sequence',offerbundleVsSequence.get(str));
                                                //}
                                                if(prodcodeVsCatalogCode!=null && prodcodeVsCatalogCode.size()>0 && prodcodeVsCatalogCode.containskey(agrLine.vlocity_cmt__ProductCode__c)){
                                                    lineItemMap.put('catalog',prodcodeVsCatalogCode.get(agrLine.vlocity_cmt__ProductCode__c));
                                                }
                                                ItemlstTempMap.put(Integer.valueof(offerbundleVsSequence.get(str)),lineItemMap);
                                            }
                                            for(Integer i=0;i<ItemlstTempMap.size();i++){
                                                lineItemlst.add(ItemlstTempMap.get(i+1));
                                            }
                                        }else{
                                            Map<String,Object> lineItemMap = new Map<String,Object>();
                                            lineItemMap.put('id',agrLine.id);
                                            lineItemMap.put('productcode',agrLine.vlocity_cmt__ProductCode__c);
                                            lineItemMap.put('sequence',sequenceOfferMap.get(agrLine.vlocity_cmt__ProductCode__c));
                                            lineItemMap.put('ordering_flag',agrLine.vlocity_cmt__Product2Id__r.Ordering_Flag__c);
                                            lineItemMap.put('product_category',agrLine.vlocity_cmt__Product2Id__r.C2BC_Category__c);
                                            lineItemMap.put('product_subcategory',agrLine.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c);
                                            
                                            if(prodcodeVsCatalogCode!=null && prodcodeVsCatalogCode.size()>0 && prodcodeVsCatalogCode.containskey(agrLine.vlocity_cmt__ProductCode__c)){
                                                lineItemMap.put('catalog',prodcodeVsCatalogCode.get(agrLine.vlocity_cmt__ProductCode__c));
                                            }
                                            lineItemlst.add(lineItemMap);
                                        }
                                    }
                                }
                                
                            }else{
                                // No Line Item found
                                hasError = true;
                                outMap.put('ErrorResponse' , generateError('NO_LINEITEM','custom','GetAgreementOffers', inputMap));
                                outMap.put('StatusCode' , 400);
                            }
                            agreementMap.put('lineItem',lineItemlst);
                            agreementlst.add(agreementMap);
                        }
                    }else{
                        // No Active Agreement
                        hasError = true;
                        outMap.put('ErrorResponse' , generateError('INVALID_AGREEMENT','custom','GetAgreementOffers', inputMap));
                        outMap.put('StatusCode' , 400);
                        
                    }
                    
                    outMap.put('agreement',agreementlst );
                    outMap.put('catalog',cataloglst );
                    //System.debug('mapping'+outMap);
                    system.debug('hasError ->'+hasError);
                    if(!hasError){
                        
                        outMap.put('success', true);
                        
                    }
                    
                }else{
                    outMap.put('ErrorResponse' , generateError('INVALID_TSCID','custom','GetAgreementOffers', inputMap));
                    outMap.put('StatusCode' , 400);
                }
            }
        }catch(Exception e){
            hasError = true;
            error_message = e.getMessage()+' line:'+ e.getLineNumber();
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR','custom','GetAgreementOffers', inputMap));
            outMap.put('StatusCode' , 500);
            MCOnline_Utility.logError(error_message,'500','MCOnline_GetAgreementOffers_V3','Apex Class','Exception',JSON.serialize(inputMap),'','','');
        }     
        
    }
    
}