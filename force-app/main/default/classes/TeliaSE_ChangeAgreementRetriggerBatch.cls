/**
 * @Author:      Surajit Pramanik
 * @Company:     Capgemini
 * @Date:        31th March, 2019
 * @Description: This Class will retrigger changeAgreementCase service
 *
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------
*/

global class TeliaSE_ChangeAgreementRetriggerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    String query;
    
    global TeliaSE_ChangeAgreementRetriggerBatch(){
       // query = 'SELECT Id, TeliaSE_TUPP_Interface_Name__c, TeliaSE_TUPP_Interface_Status__c, TeliaSE_TUPP_Interface_Error__c,TeliaSE_Start_Date__c,TeliaSE_Start_Date_Flag__c FROM Contract WHERE TeliaSE_Start_Date_Flag__c = True AND TeliaSE_Start_Date__c != null';
	   query = 'SELECT Id FROM Contract WHERE TeliaSE_Start_Date_Flag__c = True AND TeliaSE_Start_Date__c != null';
        System.debug('query->'+query);
    }    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('coming here');
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contract> contractList){
        System.debug('contractList'+contractList);
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        for(Contract cont : contractList){
            inputMap.put('Id', cont.id);
            System.debug('Id---->'+inputMap);
        }
        String METHODNAME_CHANGEAGREEMENT = 'changeAgreementCase';
        TeliaSE_UpdateContract_TUPP updateContract = new TeliaSE_UpdateContract_TUPP();
        updateContract.invokeMethod(METHODNAME_CHANGEAGREEMENT, inputMap, outMap, options);
    }    
    global void finish(Database.BatchableContext bc){
    }    
}