/**
 * @Author:      Surajit Pramanik
 * @Company:     Capgemini
 * @Date:        11th March, 2019
 * @Description: Class to invoke changeAgreementCase and deleteAgreementCase service
 * @testClass :  Test_TeliaSE_TUPPIntegrationHandler
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------
*/

global class TeliaSE_UpdateContract_TUPP implements vlocity_cmt.VlocityOpenInterface {
    
    String METHODNAME_CHANGEAGREEMENT = 'changeAgreementCase';
    String METHODNAME_DELETEAGREEMENT = 'deleteAgreementCase';
    string METHODNAME_REGISTERCASE = 'RegisterCase';
    String METHODNAME_SUBMIT_CALLOFF = 'callOffSubmit';    
    public TeliaSE_UpdateContract_TUPP(){
    }
    
    public Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object>outMap, Map<String,Object>options) {
        
        Boolean result = true;
        Map<String,Object> outResult = new Map<String,Object>();
        
        try {
            if (methodName.equals(METHODNAME_CHANGEAGREEMENT)){
                outResult = changeAgreementCase(inputMap, outMap, options); 
            }
            else if (methodName.equals(METHODNAME_DELETEAGREEMENT)){
                outResult = deleteAgreementCase(inputMap, outMap, options);
            }
            else if (methodName.equals(METHODNAME_REGISTERCASE)){
                outResult = RegisterCase(inputMap, outMap, options);
            }
            else if (methodName.equals(METHODNAME_SUBMIT_CALLOFF)){
                outResult = callOffSubmit(inputMap, outMap, options);
            }
            
        } catch(Exception e) {
            System.debug('Error: '+ e.getMessage());
            throw e;
        }
        return result;
        
    }
    public static void sendEmail(string Email, Id ContractId){
        String baseUrl= system.URL.getSalesforceBaseUrl().toExternalForm();
        //Send email method will be invoked
             
            EmailTemplate template = [SELECT  DeveloperName,Folder.Name,Body,Id,Name,Subject FROM EmailTemplate where DeveloperName='TUPPActivationMail'];
            
            string htmlbody = template.Body;
            Contract ctrct = [SELECT Id,ContractNumber, Account.Name, CustomerSignedDate, ActivatedDate, TeliaSE_Start_Date__c, StartDate FROM Contract where id = :ContractId];
            string Subject = template.Subject;
                    Subject = Subject.replace('{AccountDetails}',  ctrct.Account.Name);
                    Subject = Subject.replace('{ContractNumberDetails}',ctrct.ContractNumber );
                    
             htmlbody = htmlbody.replace('{AccountRecord}',system.label.BaseURL+''+ctrct.Account.Id);
             htmlbody = htmlbody.replace('{AccountName}',ctrct.Account.Name);
             htmlbody = htmlbody.replace('{ContractRecord}',system.label.BaseURL+''+ctrct.Id);
             htmlbody = htmlbody.replace('{ContractNumberDetails}',ctrct.ContractNumber);             
             htmlbody = htmlbody.replace('{CustomerSignedDate}',String.ValueOf(ctrct.CustomerSignedDate));
             htmlbody = htmlbody.replace('{StartDate}',String.ValueOf(ctrct.TeliaSE_Start_Date__c == null ? ctrct.StartDate : ctrct.TeliaSE_Start_Date__c));
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.saveAsActivity= false;
            mail.setHtmlBody(htmlbody);
            mail.setSubject(Subject);
            mail.setToAddresses(new String[]{Email});     
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

             if (results[0].success) 
             {
               System.debug('The email was sent successfully.');
             } else {
               System.debug('The email failed to send: ' +  results[0].errors[0].message);
             }
    }
    public static Map<String,Object> changeAgreementCase(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        String methodName = 'TUPP_ChangeAgreementCase';
        List<Messaging.Email> mailsToSend = new List<Messaging.Email>{};
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        TeliaSE_TUPPIntegrationHandler tuppIntHndlr = new TeliaSE_TUPPIntegrationHandler();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            
            Map<String,Object> ipresult1 = (Map<String,Object>)outMap.get('IPResult');
            Map<String,Object> ipresult = (Map<String,Object>)ipresult1.get('Response');
            Id passedContractId = (string)inputMap.get('Id');
            //Use the ContractIDEmail to get the ContractOwner.Email and pass to the method.
            List<Contract> fetchedRecord = [SELECT Id, TeliaSE_TUPP_Interface_Status__c, Account.Owner.Email, Owner.Email, TeliaSE_TUPP_Interface_Error__c,TeliaSE_Start_Date__c,TeliaSE_Start_Date_Flag__c 
                                            FROM Contract WHERE Id=: passedContractId];
            
           if(ipresult != null && ipresult.get('result') != null && (ipresult.get('result')) == 'Ok'){
               //This method process only 1 contract at a time
               If(fetchedRecord != null && fetchedRecord.size() > 0)
               {
                   sendEmail(fetchedRecord[0].Account.Owner.Email, passedContractId);
               }
            }
            //else if(ipresult != null && ipresult.get('result') != null && (ipresult.get('result')) == 'Error'){
               //do nothing for error
            //}
            tuppIntHndlr.updateContract('ChangeAgreementCase', ipresult1, String.valueOf(inputMap.get('Id')));
            return ipresult;
        }catch(Exception e) {
            System.debug('Error: ' + e.getStackTraceString());
            return null;
        }
        
    }
    public static Map<String,Object> RegisterCase(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        String methodName = 'TUPP_RegisterCase';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        TeliaSE_TUPPIntegrationHandler tuppIntHndlr = new TeliaSE_TUPPIntegrationHandler();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult1 = (Map<String,Object>)outMap.get('IPResult');
            Map<String,Object> ipresult = (Map<String,Object>)ipresult1.get('Response');
            Id passedContractId = (string)inputMap.get('ContractId');
            //Use the ContractIDEmail to get the ContractOwner.Email and pass to the method.
            //List<Contract> fetchedRecord = [SELECT Id, TeliaSE_TUPP_Interface_Name__c,TeliaSE_TUPP_Interface_Status__c, TeliaSE_TUPP_Interface_Error__c FROM Contract WHERE Id=: passedContractId];
            
           if(ipresult != null && ipresult.get('result') != null)
           {
               tuppIntHndlr.RegisterCaseupdateContract('RegisterCase', ipresult1, String.valueOf(inputMap.get('ContractId')));
           }     
           return ipresult;
        }catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            return null;
        }
        
    }
    
    public static Map<String,Object> deleteAgreementCase(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        String methodName = 'TUPP_DeleteCaseAgreement';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        TeliaSE_TUPPIntegrationHandler tuppIntHndlr = new TeliaSE_TUPPIntegrationHandler();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
            tuppIntHndlr.updateContract('DeleteAgreementCase', ipresult, String.valueOf(inputMap.get('Id')));
            return ipresult;
        }catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }
    public static Map<String,Object> callOffSubmit(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        String methodName = 'MassCustomized_TouchPoint';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        TeliaSE_TUPPIntegrationHandler tuppIntHndlr = new TeliaSE_TUPPIntegrationHandler();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
            tuppIntHndlr.updateCallOffStatus(ipresult, String.valueOf(inputMap.get('QuoteId')));
            return ipresult;
        }catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }
    
    
}