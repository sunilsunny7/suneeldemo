global class MCOnline_BillingAccounts_V2 implements vlocity_cmt.VlocityOpenInterface2{
    
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
            outMap.put('StatusCode', 500);
        }        
        return result;
    }
    
    public static void updateBillingAccount(Map<String,Object> inputMap, Map<String,Object> outMap){
        
        String tscid= String.valueOf(((Map<String,Object>)inputMap.get('options')).get('tscid'));
        String user = String.valueOf(((Map<String,Object>)inputMap.get('options')).get('users'));
        Map<String,Object> basketAccountMap = new Map<String,Object>();
        List<Object> basketList = (List<Object>)inputMap.get('request');
        List<MCOnline_Basket__c> basketToUpdate = new List<MCOnline_Basket__c>();
        id AgreementId;
        Contract con = new Contract();
        //create map of basket name and its billing account
        for(Object basketObj :basketList){
            Map<String,Object> basketAccount = (Map<String,Object>)basketObj;
            basketAccountMap.put(String.valueOf(basketAccount.get('basketName')),String.valueOf(basketAccount.get('billingAccount')));
        }
        //get TSCID and Contract
        id accTSCID = [select Id from Account where TSCID__c=:tscid limit 1]?.id;
        con = [SELECT id, ContractNumber, Status FROM Contract where AccountId=:accTSCID AND Status='Active' ORDER BY EndDate DESC Limit 1];
        AgreementId = con.id;
        //get parent basket for the above tscid, account and contract
        List<MCOnline_ParentBasket__c> parentBasketList = [select Id,Name,TSCID__c,Account__c,Admin__c,(SELECT Id,Name, MCOnline_Admin__c,MCOnline_Billing_Account__c, MCOnline_ParentBasket__c FROM MCOnline_Basket__r order by createddate desc) from  MCOnline_ParentBasket__c where TSCID__c = :tscid AND Admin__c=:user AND AgreementId__c=:AgreementId AND Is_Processed__c= false order by createddate desc limit 1];
        if(parentBasketList!= null && parentBasketList.size()>0)
        {
            Map<STring,Object> result = new Map<String,Object>();
            List<Map<String,Object>> basketItemList = new List<Map<String,Object>>();
            result.put('parentBasket',parentBasketList[0]?.Name);
            Set<String> basketSet = new Set<String>();
            //for each child basket under the parent basket check the child basket name is passed in request body and  
            //process the record if pased in the request
            for(MCOnline_Basket__c childbasket : parentBasketList[0].MCOnline_Basket__r){
                if(basketAccountMap.containsKey(childbasket.Name)){
                    Map<String,Object> basket = new Map<String,Object>();
                    basket.put('basketItem',childbasket.Name);
                    basket.put('billingAccount',basketAccountMap.get(childbasket.Name));
                    basketItemList.add(basket);
                    MCOnline_Basket__c bas = new MCOnline_Basket__c();
                    bas.id = childbasket.id;
                    bas.MCOnline_Billing_Account__c = String.valueOf(basketAccountMap.get(childbasket.Name));
                    basketToUpdate.add(bas);
                 }
            }
            //update the billing account
            update basketToUpdate;
            result.put('basketItems',basketItemList);
            outMap.put('Result',result);
            outMap.put('success',true);
            
        }
    }
}