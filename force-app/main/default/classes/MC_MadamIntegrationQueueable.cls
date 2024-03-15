/******************************************************************************************************
* @author         Binamra Guha/Aditi Goyal
* @modifiedBy     Itishree Dash
* @maintainedBy   Itishree Dash/Lokesh Singh
* @version        1.0
* @modified       2023-07-21(code ptimization to improve performance)
* Decription      This class run signalMadam method for setting service contract id in madam system 
*
* *******************************************************************************************/
public class MC_MadamIntegrationQueueable implements Queueable {    
    private String methodName, serviceContractNumber, agreementNumber, contractId, accountId;
    private Map<String, Object> inputMap = new Map<String, Object>();
    private Map<String, Object> outputMap = new Map<String, Object>();
    private Map<String, Object> options = new Map<String, Object>();
    
    public MC_MadamIntegrationQueueable(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        this.methodName = methodName;
        this.inputMap = inputMap;
        this.outputMap = outputMap;
        this.options = options;
    }
    public MC_MadamIntegrationQueueable(String serviceContractNumber, String agreementNumber, String contractId, String accountId) {
        this.agreementNumber = agreementNumber;
        this.serviceContractNumber = serviceContractNumber;
        this.contractId = contractId;
        this.accountId = accountId;
    }
    
    public void execute(System.QueueableContext qc) {
        //This method invoke for first constructor run
        if(String.isNotBlank(methodName)){
            new MassCustomized_MadamIntegration().invokeMethod(methodName,inputMap,outputMap,options);
        } //if second cosnstructor run then this method invoke to set Service contract Id to Madam    
        else if(String.isNotBlank(serviceContractNumber) && String.isNotBlank(agreementNumber)){
            MassCustomized_MadamIntegration.signalMadam(serviceContractNumber, agreementNumber, contractId,accountId);
        }
    }
}