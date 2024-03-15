global without sharing  class RevokeApproval implements vlocity_cmt.VlocityOpenInterface{
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     Boolean result = true;
      try
        {
     if(methodname.equals('revokeapprovals'))
            {
                revokeapprovals(inputMap,outMap);
            }
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {
            System.debug('exception: '+e);
            result = false;
        }
        return result;
    }
    /*// Constructor
    public ManageButton(ApexPages.StandardController stdController) 
    {
    }*/
        /**
     * method used by the Get Approval Process button
     */   
    //public static PageReference documentCustomGetApprovalProcess()
     public static void revokeapprovals(Map<String, Object> inputMap, Map<String, Object> outMap)
     { 
        //string docId = ApexPages.currentPage().getParameters().get('id');
                String quoteId='';

        
        quoteId= (String)inputMap.get('ContextId'); 
        Quote quote = [SELECT Id,Status from quote where id =: quoteId];
        /*ProcessInstanceWorkitem[] workItems = [
             SELECT Id
               FROM ProcessInstanceWorkitem 
              WHERE ProcessInstance.TargetObjectId = :docId
                AND ProcessInstance.Status = 'Pending'];*/
         List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :quoteId AND ProcessInstance.Status = 'Pending']; 
         List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem wi : workItems ){
        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
        pwr.setAction('Removed');
        pwr.setWorkItemId(wi.id);
        lstWorkItemRequest.add(pwr);

        //Approval.ProcessResult result = Approval.process(pwr);
       }
       if(lstWorkItemRequest.size() > 0){
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest,FALSE);//process method is used for approving/rejecting records depending on setAction attribute
        quote.status = 'Draft';
        update quote;
        }
        // Redirect the user back to the original page
       /* PageReference pageRef = new PageReference('/' + docId);
        pageRef.setRedirect(true);
        return pageRef;*/
    }
}