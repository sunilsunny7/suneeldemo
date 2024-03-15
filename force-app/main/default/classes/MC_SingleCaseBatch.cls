/**
* @Author:      Aditi Goyal
* @Company:     Capgemini
* @Date:        14-11-2022
* @Description: Class to trigger SwitchCase API for switch solutions. Epic- Smart Connect Single Case MCSTO-11229
* -------------------------------------------------------------
*/
global class MC_SingleCaseBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    private static final String TUPP_STATUS = 'Active';
    //private static final String AUTO_TRIGGER = 'Yes';
    private static final String IP_NAME = 'MassCustomized_TouchPoint';
    private static final String INTERFACE_NAME = 'CreateSingleCase';
       
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        //Line no. 18 to 27 changes done for MCSTO-11710 AC1 & AC2 by Shouvik.
        List<vlocity_cmt__ContractLineItem__c> cliList = [SELECT vlocity_cmt__ContractId__c FROM vlocity_cmt__ContractLineItem__c WHERE TeliaSE_ParentItemId__c = null AND TeliaSE_Product_Object_Type__c = 'Smart Connect Offer Spec' AND ((vlocity_cmt__LineStatus__c ='Added' AND (vlocity_cmt__ContractId__r.TeliaSE_MC_sales_flow_identifier__c ='Omforhandling' OR vlocity_cmt__ContractId__r.TeliaSE_MC_sales_flow_identifier__c = 'Tilläggsförhandling')) OR (vlocity_cmt__ContractId__r.TeliaSE_MC_sales_flow_identifier__c ='New Sales'))];
        Set<Id> conIdSet = new Set<Id>();
        for(vlocity_cmt__ContractLineItem__c cli : cliList){
            conIdSet.add(cli.vlocity_cmt__ContractId__c);
        }
        String query = 'SELECT Id FROM Contract WHERE TeliaSE_TUPP_Status__c =:TUPP_STATUS AND TeliaSE_Case_Id__c != null AND MC_SmartConnectCaseId__c = null AND Id In: conIdSet';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contract> contractList){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        for(Contract con : contractList){
            
            inputMap.put('ContractId',con.Id);
            
            inputMap.put('SingleCase',true);
            integProcServ.invokeMethod(IP_NAME, inputMap, outMap, options);
            Map<String,Object> ipResult = (Map<String,Object>)outMap.get('IPResult');
            if(test.isRunningTest()){
                String resp = '{"Response":{"result":"NOTOK"}}';
                ipResult = (Map<String, Object>)JSON.deserializeUntyped(resp);
            }
            
            Map<String,Object> ipResponse = (Map<String,Object>)ipResult.get('Response');
            if(!ipResponse.isEmpty()){
                con.TeliaSE_TUPP_Interface_Name__c = INTERFACE_NAME;
                if(ipResponse.containsKey('result') && ipResponse.get('result') == 'OK' && ipResponse.get('caseId') != null){
                    con.TeliaSE_TUPP_Interface_Status__c = 'Successful';
                    con.TeliaSE_TUPP_Interface_Error__c = String.valueOf(ipResponse.get('resultDesc'));
                    con.MC_SmartConnectCaseId__c = String.valueOf(ipResponse.get('caseId'));
                }
                else if(ipResponse.get('result') != 'OK'){
                    con.TeliaSE_TUPP_Interface_Status__c = 'Error';
                    con.TeliaSE_TUPP_Interface_Error__c = String.valueOf(ipResponse.get('resultDesc'));
                    
                }
            }
        }
        update contractList;
    }
     
    global void finish(Database.BatchableContext bc){
    }   
}