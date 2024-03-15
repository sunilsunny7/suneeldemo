/******************************************************************************************************
* @author       Pancham Verma
* @Company:     Capgemini
* @Date:        12/12/2023
* @Epic/Story:	LTAART-85
* Decription:   This class calls setUtilizers method for inativating Utilizers in Madam
* *******************************************************************************************
*/
public class MC_DeleteUtilizerQueueable implements Queueable {       
    private String contractId,utilizerInput;
    
    public MC_DeleteUtilizerQueueable(String contractId, String utilizerInput) {
        this.contractId = contractId;
        this.utilizerInput = utilizerInput;
    }
    
    public void execute(System.QueueableContext qc) {
        setUtilizers(contractId,utilizerInput);
    }
    
    @Future(callout=true)
    public static void setUtilizers(String contractId, String utilizerInput){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        TeliaSE_TUPPIntegrationHandler tuppIntHndlr = new TeliaSE_TUPPIntegrationHandler();
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        List<Utilizer_Contract_Relationship__c> ucrList = (List<Utilizer_Contract_Relationship__c>)JSON.deserialize(utilizerInput,List<Utilizer_Contract_Relationship__c>.class);
        inputMap.put('ContractId',contractId);
        String methodName = 'TUPP_setUtilizers';
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
            tuppIntHndlr.updateContractSetUtilizers('setUtilizers', ipresult, contractId,ucrList);
        }catch(Exception e) {
            MCOnline_Utility.logErrorWithoutFuture(e.getMessage(),e.getStackTraceString(),'MC_DeleteUtilizerQueueable','Apex Class','Exception',contractId,contractId,'Contract');
        }
    }
}