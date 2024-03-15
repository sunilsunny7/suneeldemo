global with sharing class MCOnline_GetAccountManagement_V2 implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
       
        if(methodName.equals('getAccountManagementDetails_V2'))
        {  
            getAccountManagementDetails_V2(inputMap, outMap, options);
        }
        return true;
    }
   
    
         public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap){
        
        String tscid= (string)inputMap.get('TSCID');
 
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        
        string urlDetails = '{"tscid": "'+tscid+'"}'; 
        ipInputMap.put('functionality', 'GetAccountManagementDetails');        
         ipInputMap.put('success', false);
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_GetAccountManagementDetails_V2,MCOnline_GetAccountManagement_V2.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
        
    }
    
    public static void getAccountManagementDetails_V2(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
  
        Map<String, Object> agreementMap = new Map<String, Object>();
        Map<String, Object> ipInputMap = new Map<String, Object>();
        String error_message=' ';
        boolean hasError=false;
        
        Try{
            String tscid;
            tscid= (string)inputMap.get('TSCID');
            system.debug('testmap' +inputmap);
            List<Account>tscid_aclst=[SELECT id  
                                      FROM Account 
                                      Where tscid__c =: tscid limit 1];
            if(String.isBlank(tscid)){
                error_message= 'NO_INPUT';
                hasError=true;
            }
            else If(String.isnotBlank(tscid) && tscid_aclst.size()==0){
                error_message= 'INCORRECT_TSCID';
                hasError=true;
            }else{
                // errmessage=
                agreementMap= (Map<String, Object>)inputmap.get('DR_AccountManagementDetails');         
                if(agreementMap.containskey('partyAccount')==false){
                    error_message= 'PARTYACCOUNT_MISSING';
                    hasError=true;
                }            
                else if(agreementMap.containskey('agreement')==false){
                    error_message= 'AGREEMENT_MISSING';
                    hasError=true;
                }else if((((List<Map<String,Object>>)agreementMap.get('agreement'))[0].containskey('lineItem'))==false){
                        error_message= 'LINEITEM_MISSING';
                        hasError=true;              
                }
            }
            
            if(hasError==true){
                outMap.put('DR_AccountManagementDetails',generateError(error_message, inputMap));
                outMap.put('StatusCode', 400);
                
                //MCOnline_Utility.logError(error_message,'INVOKE-400','GetAccountManagementAPI','Integration Procedure','','','',''); 
            }else{
                
                Set<String> virtualofferset= new Set<String>(); 
                Map<String,List<string>> offervsSubsbundle=new Map<String,List<string>>();
                List<vlocity_cmt__ProductChildItem__c> prodChildlst=new List<vlocity_cmt__ProductChildItem__c>();
                
                if((((List<Map<String,Object>>)agreementMap.get('agreement'))[0].containskey('lineItem'))==true){
                    List<Map<String,Object>> lineItemlst=new List<Map<String,Object>>();
                    lineItemlst=(List<Map<String,Object>>)((List<Map<String,Object>>)agreementMap.get('agreement'))[0].get('lineItem');
                    if(lineItemlst!=null && lineItemlst.size()>0){
                        for(Map<String,Object> lineItemMap: lineItemlst){
                            if(lineItemMap.containskey('productcode')){
                                virtualofferset.add(String.valueof(lineItemMap.get('productcode')));
                            }
                        }
                        
                        if(virtualofferset!=null && virtualofferset.size()>0){
                    
                            prodChildlst=[SELECT id, vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ParentProductId__c,vlocity_cmt__ParentProductId__r.ProductCode
                                          FROM vlocity_cmt__ProductChildItem__c
                                          WHERE vlocity_cmt__ParentProductId__r.C2BC_Category__c = 'offerbundle' AND vlocity_cmt__ParentProductId__r.ProductCode IN:virtualofferset AND vlocity_cmt__ParentProductId__r.Family ='Online Order'];
                            
                            for(vlocity_cmt__ProductChildItem__c pr:prodChildlst){
                                if(pr.vlocity_cmt__ChildProductId__c!=null && pr.vlocity_cmt__ParentProductId__r.ProductCode!=null && pr.vlocity_cmt__ParentProductId__r.ProductCode!=''){
                                    List<string> subslst = new List<string>(); 
                                    if(offervsSubsbundle!=null && offervsSubsbundle.size()>0 && offervsSubsbundle.containskey(pr.vlocity_cmt__ParentProductId__r.ProductCode)){
                                        subslst = offervsSubsbundle.get(pr.vlocity_cmt__ParentProductId__r.ProductCode);
                                    }
                                    subslst.add(pr.vlocity_cmt__ChildProductId__r.ProductCode);
                                    offervsSubsbundle.put(pr.vlocity_cmt__ParentProductId__r.ProductCode,subslst);
                                }
                            }
                            
                        }
                        if(offervsSubsbundle!=null && offervsSubsbundle.size()>0){
                            List<Map<String,Object>> lineItemMaptemp = new List<Map<String,Object>>();
                            
                            for(Map<String,Object> lineItemMap: lineItemlst){
                                
                                if(offervsSubsbundle.containskey(String.valueof(lineItemMap.get('productcode')))){
                                    List<string> subslst = new List<string>(); 
                                    subslst=offervsSubsbundle.get(String.valueof(lineItemMap.get('productcode')));
                                    
                                    for(string str: subslst){
                                        Map<String,object> newlineItemMap = new Map<String,object>();
                                        newlineItemMap.put('id',String.valueof(lineItemMap.get('id')));
                                        newlineItemMap.put('catalog',String.valueof(lineItemMap.get('catalog')));
                                        newlineItemMap.put('validFor',lineItemMap.get('validFor'));
                                        newlineItemMap.put('productcode',str);
                                        lineItemMaptemp.add(newlineItemMap);
                                    }
                                }
                            }
                            
                            if(lineItemMaptemp!=null && lineItemMaptemp.size()>0){
                                lineItemlst.clear();
                                lineItemlst.addall(lineItemMaptemp);
                            }
                        }
                    }
                }               
            
                outMap.put('DR_AccountManagementDetails',agreementMap);
                outMap.put('StatusCode', 200);
                if(!hasError){

                    agreementMap.put('success', true);

                }
            }
            
        }catch(Exception e){
            error_message = e.getMessage()+' line:'+ e.getLineNumber();
            outMap.put('ErrorResponse', generateError('unhandlederror', inputMap));
            outMap.put('StatusCode', 500);
            MCOnline_Utility.logError(error_message,'500','MCOnline_GetAccountManagement_V0_2','Apex Class','Exception',JSON.serialize(inputMap),'','');
        }
        
    }
    
}