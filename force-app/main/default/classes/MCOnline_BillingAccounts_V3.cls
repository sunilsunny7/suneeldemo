global class MCOnline_BillingAccounts_V3 implements vlocity_cmt.VlocityOpenInterface2{
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        Boolean result = true;
        try { 
            if(methodName.equalsIgnoreCase('updateBillingAccount')) {
                updateBillingAccount(inputMap, outMap);
            }
            else {
                result = false;
            }
        }catch(Exception e) {
            String error_message= e.getMessage() +' '+e.getLineNumber();
            system.debug(e.getStackTraceString());
            outMap.put('error', e.getStackTraceString());
            outMap.put('Exception', e.getStackTraceString());
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR', inputMap));
            MCOnline_Utility.logError(error_message, '500', 'MCOnline_BillingAccounts_V3,MCOnline_BillingAccounts_V3.invokeMethod', 'Apex Class', 'Exception', JSON.serialize(inputMap), '', '');
            result = false;
        }        
        return result;
    }
    
    // Method to Generate Error 
    private static Map < String, Object > generateError(string errorCode, Map < String, Object > inputMap) {
        
        String tscid = String.valueOf(inputMap.get('tscid'));
        String users = String.valueOf(inputMap.get('users'));
        Map < String, Object > ipInputMap = new Map < String, Object > ();
        string urlDetails = '{"tscid": "' + tscid + '", "users":"' + users + '"}';
        ipInputMap.put('functionality', 'Billing Account');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map < String, Object > errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode, 'MCOnline_BillingAccounts_V3,MCOnline_BillingAccounts_V3.generateError', 'Integration Procedure, Apex Class', 'Custom Error', JSON.serialize(inputMap), '', '', urlDetails);
        return errorResponse;
    }
    
    private static void updateBillingAccount(Map<String,Object> inputMap, Map<String,Object> outMap){
        
        String errorCode;
        Boolean hasError = false;
        String tscid= String.valueOf(((Map<String,Object>)inputMap.get('options')).get('tscid'));
        String user = String.valueOf(((Map<String,Object>)inputMap.get('options')).get('users'));
        Map<STring,Object> result = new Map<String,Object>();
        List<MCOnline_Basket__c> basketToUpdate = new List<MCOnline_Basket__c>();
        List<Map<String,Object>> basketItemList = new List<Map<String,Object>>();
        Map<String,Object> basketMap = new Map<String,Object>();
        if(String.isBlank(user)||String.isBlank(tscid)){
            errorCode = 'INAVALID_USER_TSCID';
            hasError = true;
        }else{
            //get TSCID
            String accTSCID = [SELECT id, name  
                             FROM Account 
                             Where tscid__c =: tscid limit 1]?.id;
            if(String.isBlank(accTSCID)){
                errorCode = 'INAVALID_USER_TSCID';
                hasError = true;
            }else{
                Map<String,Object> basketAccountMap = new Map<String,Object>();
                List<Object> basketList = (List<Object>)inputMap.get('request');
                id AgreementId;
                String con;
                //create map of basket name and its billing account
                for(Object basketObj :basketList){
                    Map<String,Object> basketAccount = (Map<String,Object>)basketObj;
                    basketAccountMap.put(String.valueOf(basketAccount.get('basketName')),String.valueOf(basketAccount.get('billingAccount')));
                }
                //Utilizer Account Logic Added 
                Set<Id> contractidset=new Set<Id>(); 
                for(Utilizer_Contract_Relationship__c ut:[Select ContractNumber__c  FROM Utilizer_Contract_Relationship__c WHERE AccountId__c=:accTSCID AND ContractNumber__c!=null])
                        contractidset.add(ut.ContractNumber__c);
                AgreementId=[SELECT id,name,ContractNumber,Agreement_Nr__c,AccountId,Status  
                                   FROM contract 
                                   where (AccountId=:accTSCID OR Id IN: contractidset) And Contract_Record_Type__c='Ramavtal' And Status='Active' ORDER BY EndDate DESC Limit 1]?.id;
                //get parent basket for the above tscid, account and contract
                List<MCOnline_ParentBasket__c> parentBasketList = [select Id,Name,TSCID__c,Account__c,Admin__c,(SELECT Id,Name, MCOnline_Admin__c,MCOnline_Billing_Account__c, MCOnline_ParentBasket__c FROM MCOnline_Basket__r order by createddate desc) from  MCOnline_ParentBasket__c where TSCID__c = :tscid AND Admin__c=:user AND AgreementId__c=:AgreementId AND Is_Processed__c= false order by createddate desc limit 1];
                if(parentBasketList!= null && parentBasketList.size()>0)
                {
                    result.put('parentBasket',parentBasketList[0]?.Name);
                    for(MCOnline_Basket__c childbasket : parentBasketList[0].MCOnline_Basket__r){
                        basketMap.put(childbasket.Name,childbasket.id);
                    }
                    //for each child basket under the parent basket check the child basket name is passed in request body and  
                    //process the record if pased in the request
                    for(String basName: basketAccountMap.keySet()){
                        if(basketMap.containsKey(basName)){
                            Map<String,Object> basket = new Map<String,Object>();
                            basket.put('basketItem',basName);
                            basket.put('billingAccount',basketAccountMap.get(basName));
                            basketItemList.add(basket);
                            MCOnline_Basket__c bas = new MCOnline_Basket__c();
                            bas.id = String.valueOf(basketMap.get(basName));
                            bas.MCOnline_Billing_Account__c = String.valueOf(basketAccountMap.get(basName));
                            basketToUpdate.add(bas);
                        }else{
                            errorCode = 'INAVALID_BASKET_NAME';
                            hasError = true;
                            break;
                        }
                    }    
                }else{
                    errorCode = 'NO_BASKET_FOUND';
                    hasError = true;
                }
            }
        }
        //update the billing account
        if(hasError){
            outMap.put('ErrorResponse', generateError(errorCode, inputMap));
            outMap.put('success',false);
        }else{
            update basketToUpdate;
            result.put('basketItems',basketItemList);
            outMap.put('Result',result);
            outMap.put('success',true); 
        }
    }
}