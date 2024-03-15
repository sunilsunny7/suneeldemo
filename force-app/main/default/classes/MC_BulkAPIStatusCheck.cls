/* @author         Binamra Guha
 * @modifiedBy     
 * @maintainedBy   
 * @version        1.0
 * @created        2022-11-29********
 * Discription:    This class is responsible to invoke to Prisma files check in Amanda*/
global class MC_BulkAPIStatusCheck implements Schedulable{
    @future(callout=true)
    public static void callBulkIP(){
        String procedureName = 'MC_RAMMFA_BulkAPIStatus', procedureName1 = 'MC_RAMMFA_InvokePrismaJob';
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, inputMap, optionsMap);
        Map<String, Object> result1 = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName1, inputMap, optionsMap);
    }
    global void execute(SchedulableContext Sc){
        MC_BulkAPIStatusCheck.callBulkIP();
    }
}