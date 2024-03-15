public class MC_Sales_ApprovalEmailQLI_Controller {

    public string cartId {get; set;}
    
    public MC_Sales_ApprovalEmailQLI_Controller(){
        system.debug('cartid');
    } 
    
    public Map<String,Object> productInfo{
        get{
            return callIntegrationprocedure(cartId);
             
        }
    }
    
    public Map<String,Object> callIntegrationprocedure(String quoteid)
    {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        inputMap.put('ContextId',quoteid);
        String methodName = 'MassCustomized_QuoteApprovalTable';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
            List<Object> QLIresult = (List<Object>)ipresult.get('QLI');
            if(QLIresult.size()==0)
            {
                ipresult.put('emptyResponse',true);                
            }
            else
            {
                ipresult.put('emptyResponse',false);
            }

            return ipresult;
        }catch(Exception e) {
			return null;
        }
    }
}