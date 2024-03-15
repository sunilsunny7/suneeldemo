public class TestCalloutSample {
    @future (callout=true)
    public static void callPostAgreementDetailsSpock(Id contractId){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        inputMap.put('ContractId',ContractId);
        inputMap.put('eventType','spock_agreementCreateEvent');
        inputMap.put('outboundWS','Spock');
        //LTAART-397 Rahul Commented this as part of API upgrade
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap1.put('ContractId',ContractId);
        inputMap1.put('eventType','AgreementCreateEvent');
        inputMap1.put('outboundWS','TNow');
        String methodName = 'PostAgreementDetails_Spock';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
            outMap.clear();
            options.clear();
            integProcServ.invokeMethod(methodName, inputMap1, outMap, options);
            Map<String,Object> ipresult1 = (Map<String,Object>)outMap.get('IPResult');
        }
        catch(Exception e) {
        }
    }
}