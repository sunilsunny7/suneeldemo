public class MCOnline_RetryCheckout {
    @InvocableMethod(label='Retry Checkout')
    public static List<List<String>> retryCheckout(List<id> parentBasketId){
        List<List<String>> outPutList = new List<List<String>>();
        List<String> responseString = new List<String>();
        String tscid;
        String users;
        String agreementId;
        String requestBody;
        List<MCOnline_ParentBasket__c> pBasketList=[SELECT Id, TSCID__c,AgreementId__c,Admin__c,UpdateOrderRequest__c,OrderNumber__c  FROM MCOnline_ParentBasket__c where id=:parentBasketId.get(0) AND Is_Processed__c=true AND BasketStatus__c IN ('Processing','Failed') limit 1];
        if(!pBasketList.isEmpty()){
            MCOnline_ParentBasket__c pBas = pBasketList.get(0);
            pBas.BasketStatus__c = '';
            update pBas;
            tscid = pBas.TSCID__c;
            users = pBas.Admin__c;
            agreementId = pBas.AgreementId__c;
            requestBody = pBas.UpdateOrderRequest__c;
            String procedureName = 'MCONLINE_CheckoutComposite_V3';
        	Map <String, Object> ipInput = new Map <String, Object> ();
			Map <String, Object> ipOutput = new Map <String, Object> ();
			Map <String, Object> ipOptions = new Map <String, Object> ();
        	Map <String, Object> options = new Map <String, Object> ();
            Map <String, Object> ipInputrequest = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        	//ipInput = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            if(ipInputrequest.containsKey('options')){
                ipInputrequest.remove('options');
            }
            String ipInputrequestString = JSON.serialize(ipInputrequest);
            ipInput = (Map<String, Object>) JSON.deserializeUntyped(ipInputrequestString);
        	ipOptions.put('tscid',tscid);
        	ipOptions.put('users',users);
        	ipOptions.put('agreementId',agreementId);
        	try{
                if (!Test.isRunningTest()){
        			ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
                }else{
                    String res = '{"AccountId":"0013E00001Cnf4OQAR","BasketId":"a9O9E0000000P94UAE","BasketName":"MBAS-0001042","Message":"Order is getting placed.","OrderNumber":["TEST-00001043"],"success":true,"TSCID":"TEST8654"}'; 
                    ipOutput = (Map<String, Object>) JSON.deserializeUntyped(res);	
                }
                string jsonstr = JSON.serialize(ipOutput);
            	responseString.add(jsonstr);
            	outPutList.add(responseString);
            }
        	catch(Exception e){
            	responseString.add(e.getMessage());
            	outPutList.add(responseString);
       		}
        }else{
            responseString.add('Parent basket is not eligible for retry checkout');
            outPutList.add(responseString);
        }
        return outPutList;
        
    }
    
}