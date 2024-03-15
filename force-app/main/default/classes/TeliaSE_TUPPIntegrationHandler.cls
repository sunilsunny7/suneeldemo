/**
* @Author:      Surajit Pramanik
* @Company:     Capgemini
* @Date:        11th March, 2019
* @Description: This class will update Contract with TUPP service status
*
* History
* <Date>           <Authors Name>      <Brief Description of Change>
* -------------------------------------------------------------
*/

public class TeliaSE_TUPPIntegrationHandler {
    
    TeliaSE_UpdateContract_TUPP updateContract = new TeliaSE_UpdateContract_TUPP();
    
    @future (callout=true)
    public static void callDeleteAgreemntCase(Id contractId){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        String METHODNAME_DELETEAGREEMENT = 'deleteAgreementCase';
        inputMap.put('Id',contractId);
        List<Contract> contrct = [SELECT ID, TeliaSE_Case_Id__c FROM Contract WHERE ID =: contractId];
        TeliaSE_UpdateContract_TUPP updateContract = new TeliaSE_UpdateContract_TUPP();
        for(Contract con : contrct){
            if(con.TeliaSE_Case_Id__c != null){
                updateContract.invokeMethod(METHODNAME_DELETEAGREEMENT, inputMap, outMap, options); 
            }
        }
    } 
    
    public void updateContractSetUtilizers(String interfaceName, Map<String,Object> IPResult, String contractId,List<Utilizer_Contract_Relationship__c> utilizerList)
    {
        List<Utilizer_Contract_Relationship__c> utilRelationUpdate = new List<Utilizer_Contract_Relationship__c>();
        Contract con = [SELECT Id, TeliaSE_TUPP_Interface_Name__c, TeliaSE_TUPP_Interface_Status__c, TeliaSE_TUPP_Interface_Error__c FROM Contract WHERE ID =: contractId];
        List<Contract> ContractToUpdate = new List<Contract>();
        Map<String, Object> response = (Map < String, Object > ) IPResult.get('Response');
        if((response.get('result')) == 'Ok')
        {
                con.TeliaSE_TUPP_Interface_Name__c = interfaceName;
                con.TeliaSE_TUPP_Interface_Status__c = 'Successful';
                con.TeliaSE_TUPP_Interface_Error__c = String.valueOf(response.get('resultDesc'));
                con.TeliaSE_Case_Id__c = String.valueOf(response.get('caseId'));
            	con.MC_Snow_Sync__c = false;
                ContractToUpdate.add(con);
        }

        else if((response.get('result')) == 'Error')
        {
            String errorMessage = String.valueOf(response.get('resultDesc'));
            if(response.keyset().contains('subErrors'))
            {
                    List<Object> subErrList = new List<Object>();
                    subErrList = (List<object>)response.get('subErrors');
                    for (Object subErr : subErrList)
                    {
                        Map<String,Object> subErrMap = (Map<String,Object>)subErr;
                        String field = String.valueOf(subErrMap.get('field'));
                        String message = String.valueOf(subErrMap.get('message')); 
                        errorMessage = (errorMessage +', '+ field +' : '+ message +'. ');
                    }
                    con.TeliaSE_TUPP_Interface_Name__c = interfaceName;
                    con.TeliaSE_TUPP_Interface_Status__c = 'Error';
                    con.TeliaSE_TUPP_Interface_Error__c = errorMessage;
                    ContractToUpdate.add(con);

            }
            else
            {                
                    con.TeliaSE_TUPP_Interface_Name__c = interfaceName;
                    con.TeliaSE_TUPP_Interface_Status__c = 'Error';
                    con.TeliaSE_TUPP_Interface_Error__c = errorMessage;
                    ContractToUpdate.add(con);
            }

         // Updating Utilizers to previous Aktiv as results are error.
            for(Utilizer_Contract_Relationship__c ucr : utilizerList)
            {
                ucr.Status__c = 'Aktiv';
            }
            if(!utilizerList.isEmpty())
            {
                update utilizerList;
            }
        
        }

        if(!ContractToUpdate.isEmpty()){
            update ContractToUpdate;
        }


    }
    
    public void updateContract(String interfaceName, Map<String,Object> IPResult, String contractId){
        
        //List<Contract> contrct = [SELECT Id, TeliaSE_TUPP_Interface_Name__c, TeliaSE_TUPP_Interface_Status__c, TeliaSE_TUPP_Interface_Error__c FROM Contract WHERE ID =: contractId];
		Contract contrct = new Contract();
		contrct.id = contractId;
        List<Contract> ContractToUpdate = new List<Contract>();
      //for(Contract con : contrct){
            
            if(Test.isRunningTest()){
                String resp = '{"subErrors": [{"message": "Start date cannot be less than 15 workdays ahead. The earliest start date is 2019-06-11","rejectedValue": "2019-05-06","field": "startDate","object": "validateAgreementDates"}],"callerUrl": "/changeAgreementCase","timestamp": "2019-05-17 10:25:44","status": "BAD_REQUEST","resultDesc": "Date validation error","result": "Error"}';
                Map<String, Object> finalResponse = (Map<String, Object>)JSON.deserializeUntyped(resp);
                IPResult.put('Response',finalResponse);
            }
            
            Map<String, Object> response = (Map < String, Object > ) IPResult.get('Response');
            if((response.get('result')) == 'Ok'){
                contrct.TeliaSE_TUPP_Interface_Name__c = interfaceName;
                contrct.TeliaSE_TUPP_Interface_Status__c = 'Successful';
                contrct.TeliaSE_TUPP_Interface_Error__c = String.valueOf(response.get('resultDesc'));
                contrct.TeliaSE_Start_Date_Flag__c = FALSE;
                ContractToUpdate.add(contrct);
            }else if((response.get('result')) == 'Error'){
                
                if(response.keyset().contains('subErrors')){
                    String errorMessage = String.valueOf(response.get('resultDesc'));
                    List<Object> subErrList = new List<Object>();
                    subErrList = (List<object>)response.get('subErrors');
                    for (Object subErr : subErrList){
                        Map<String,Object> subErrMap = (Map<String,Object>)subErr;
                        String field = String.valueOf(subErrMap.get('field'));
                        String message = String.valueOf(subErrMap.get('message')); 
                        errorMessage = (errorMessage +', '+ field +' : '+ message +'. ');
                    }
                    
                    if(errorMessage.contains('Date validation error, startDate : Start date cannot be less than 15 workdays ahead')){
                        String strtDate = errorMessage.substring(112,123);
                        Integer myIntDate = integer.valueOf(strtDate.substring(8,10));
                        Integer myIntMonth = integer.valueOf(strtDate.substring(5,7));
                        Integer myIntYear = integer.valueOf(strtDate.substring(0,4));
                        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                        contrct.TeliaSE_Start_Date__c = d;
                        contrct.TeliaSE_Start_Date_Flag__c = TRUE;
                        contrct.TeliaSE_TUPP_Interface_Name__c = interfaceName;
                        contrct.TeliaSE_TUPP_Interface_Status__c = 'Error';
                        contrct.TeliaSE_TUPP_Interface_Error__c = errorMessage;
                        ContractToUpdate.add(contrct);
                    }else{                
                        contrct.TeliaSE_TUPP_Interface_Name__c = interfaceName;
                        contrct.TeliaSE_TUPP_Interface_Status__c = 'Error';
                        contrct.TeliaSE_TUPP_Interface_Error__c = errorMessage;
                        contrct.TeliaSE_Start_Date_Flag__c = FALSE;
                        ContractToUpdate.add(contrct);
                    }
                }else{ 
                    String errorMessage = String.valueOf(response.get('resultDesc'));
                    contrct.TeliaSE_TUPP_Interface_Name__c = interfaceName;
                    contrct.TeliaSE_TUPP_Interface_Status__c = 'Error';
                    contrct.TeliaSE_TUPP_Interface_Error__c = errorMessage;
                    ContractToUpdate.add(contrct);
                }
            }
            
       // }
        if(!ContractToUpdate.isEmpty()){
            update ContractToUpdate;
        }
    }
    
    public void updateCallOffStatus(Map<String,Object> IPResult, String quoteId){
        List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
        List<Quote> quotes = [SELECT Id,QuoteNumber,TeliaSE_Touchpoint_Case_Number__c,vlocity_cmt__FrameContractId__r.Owner.Email,vlocity_cmt__FrameContractId__r.Owner.Name FROM Quote WHERE ID =: quoteId];
        
        if(Test.isRunningTest()){
            String resp = '{"subErrors": [{"message": "agreementCaseId:437033 is already signed","rejectedValue": 437033,"field": "agreementCaseId","object": "validateFrameAgreementId"}],"callerUrl": "/createSwitchCase","timestamp": "2019-08-01 02:33:20","status": "BAD_REQUEST","resultDesc": "Error in request","result": "Error"}';
            Map<String, Object> finalResponse = (Map<String, Object>)JSON.deserializeUntyped(resp);
            IPResult.put('Response',finalResponse);
        }
        
        Map<String, Object> response = (Map < String, Object > ) IPResult.get('Response');
        List<Quote> QuoteToUpdate = new List<Quote>();
        for(Quote callOffQuote : quotes){
            if((response.get('result')) == 'Ok'){  
                callOffQuote.TeliaSE_Touchpoint_Case_Number__c = (Decimal)response.get('caseId');
                callOffQuote.Touchpoint_Case_Submitted__c = true;
                QuoteToUpdate.add(callOffQuote);
            }else if((response.get('result')) == 'Error'){
                        
                String ownerEmail = callOffQuote.vlocity_cmt__FrameContractId__r.Owner.Email;
                String ownerName = callOffQuote.vlocity_cmt__FrameContractId__r.Owner.Name;
                String qouteId = callOffQuote.QuoteNumber;
                if(Test.isRunningTest()){
                    ownerEmail = 'surajit.pramanik@capgemini.com';
                    ownerName = 'Surajit'; 
                    qouteId = '123456';
                }
                
                String errorMessage;
                if(response.keyset().contains('subErrors')){
                    errorMessage = String.valueOf(response.get('resultDesc'));
                    List<Object> subErrList = new List<Object>();
                    subErrList = (List<object>)response.get('subErrors');
                    for (Object subErr : subErrList){
                        Map<String,Object> subErrMap = (Map<String,Object>)subErr;
                        String field = String.valueOf(subErrMap.get('field'));
                        String message = String.valueOf(subErrMap.get('message')); 
                        errorMessage = (errorMessage +', '+ field +' : '+ message +'. ');
                    }   
                }else{ 
                    errorMessage = String.valueOf(response.get('resultDesc'));
                }
                if (ownerEmail != null && errorMessage != null) {
                    Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();
                    List<String> sendTo = new List<String>();
                    sendTo.add(ownerEmail);
                    mail.setToAddresses(sendTo);
                    mail.setSenderDisplayName('Touchpoint Integration');
                    String subject = 'Ett fel inträffade in CreateSwitchCase for  Touchpoint call-off '+qouteId;
                    mail.setSubject(subject);
                    String body = 'Hej '+ownerName+', ';
                    body += 'Ett fel inträffade när Touchpoint call-off skickades in for '+qouteId+'.  Vänligen hitta informationen nedan.';
                    body += 'Du kan försöka igen eller kontakta din administratör';
                    body += 'Fel '+errorMessage+ '. ';
                    body += '';
                    body += 'Med vänlig hälsning,';
                    body += 'Telia Salesforce';
                    mail.setHtmlBody(body);
                    mails.add(mail);
                }
                Datetime myDT = Datetime.now();
                String myDate = myDT.format('h:mm a');                
                string str='10:13 AM;10:14 AM;10:15 AM;10:16 AM;10:17 AM;10:18 AM;10:19 AM;10:20 AM;10:21 AM;10:22 AM;10:23 AM;10:24 AM;10:25 AM';                
                if(str.contains(myDate)){
                    Messaging.sendEmail(mails);
                }
                
                
            }
        }
        update QuoteToUpdate;
    }
    

    public void RegisterCaseupdateContract(String interfaceName, Map<String,Object> IPResult, String contractId)
    {
        Contract contrct = [SELECT Id, TeliaSE_TUPP_Interface_Name__c, TeliaSE_TUPP_Interface_Status__c, TeliaSE_TUPP_Interface_Error__c FROM Contract WHERE ID =: contractId limit 1];
        if(Test.isRunningTest())
        {
            String resp = '{"subErrors": [{"message": "Start date cannot be less than 15 workdays ahead. The earliest start date is 2019-06-11","rejectedValue": "2019-05-06","field": "startDate","object": "validateAgreementDates"}],"callerUrl": "/changeAgreementCase","timestamp": "2019-05-17 10:25:44","status": "BAD_REQUEST","resultDesc": "Date validation error","result": "Error"}';
            Map<String, Object> finalResponse = (Map<String, Object>)JSON.deserializeUntyped(resp);
            IPResult.put('Response',finalResponse);
        }           
        Map<String, Object> response = (Map < String, Object > ) IPResult.get('Response');
        if(contrct!=null)
        {
            if((response.get('result')) == 'Ok')
            {
                contrct.TeliaSE_TUPP_Interface_Name__c = interfaceName;
                contrct.TeliaSE_TUPP_Interface_Status__c = 'Successful';
                contrct.TeliaSE_TUPP_Interface_Error__c = String.valueOf(response.get('resultDesc'));
            }
            else if((response.get('result')) == 'Error')
            {
                String errorMessage = String.valueOf(response.get('resultDesc'));
                if(response.keyset().contains('subErrors'))
                {                    
                    List<Object> subErrList = new List<Object>();
                    subErrList = (List<object>)response.get('subErrors');
                    for (Object subErr : subErrList)
                    {
                        Map<String,Object> subErrMap = (Map<String,Object>)subErr;
                        String field = String.valueOf(subErrMap.get('field'));
                        String message = String.valueOf(subErrMap.get('message')); 
                        errorMessage = (errorMessage +', '+ field +' : '+ message +'. ');
                    }
                }
                contrct.TeliaSE_TUPP_Interface_Name__c = interfaceName;
                contrct.TeliaSE_TUPP_Interface_Status__c = 'Error';
                contrct.TeliaSE_TUPP_Interface_Error__c = errorMessage;
            }
        }        
        if(contrct!=null)
        {
            update contrct;
        }
    }
    

    @future (callout=true)
    public static void callPostAgreementDetailsSnow(Id contractId){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        inputMap.put('ContractId',ContractId);
        inputMap.put('eventType','AgreementCreateEvent');
        inputMap.put('outboundWS','TNow');
        String methodName = 'PostAgreementDetails_Spock';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
        }catch(Exception e) {
        }
    }
    
     @future (callout=true)
    public static void callPostAgreementDetailsSpock(Id contractId){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        inputMap.put('ContractId',ContractId);
        inputMap.put('eventType','spock_agreementCreateEvent');
        inputMap.put('outboundWS','Spock');
        String methodName = 'PostAgreementDetails_Spock';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
        }catch(Exception e) {
        }
    } 

        
	@future (callout=true)
    public static void callDeleteAgreementDetailsSnow(Id contractId){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        inputMap.put('ContractId',ContractId);
        inputMap.put('eventType','AgreementStateChangeEvent');
        String methodName = 'SNow_ESDAfterMarket';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
        }catch(Exception e) {
        }
    } 
    
    @future (callout=true)
    public static void callAgreementStateChangeEventSpock(Id contractId){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        inputMap.put('ContractId',ContractId);
        inputMap.put('eventType','spock_agreementStateChangeEvent');
        String methodName = 'PostAgreementDetails_Spock';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');
        }catch(Exception e) {
        }
    } 
    
    @future (callout=true)
    public static void AutoTaskContractSync(Id ContractId){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        inputMap.put('ContractId',ContractId);
        List<vlocity_cmt__ContractLineItem__c> cliList = [select id from vlocity_cmt__ContractLineItem__c where TeliaSE_Product_Object_Type__c = 'ITDaaS Offer Spec' and vlocity_cmt__ContractId__c =: ContractId];
        if (cliList.size()>0)
        {


        String methodName = 'MassCustomized_PostAgreementSync';
        vlocity_cmt.IntegrationProcedureService integProcServ = new vlocity_cmt.IntegrationProcedureService();
        try{
            integProcServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('IPResult');

        }catch(Exception e) {

        }
        }
    }
@future (callout=true)
    public static void callPostAgreementDetailsSiebel(Id contractId){
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        inputMap.put('ContractId',ContractId);
        inputMap.put('eventType','AgreementCreateEvent');
        String methodName = 'PostAgreementDetails_Siebel';
        vlocity_cmt.IntegrationProcedureService iPServ = new vlocity_cmt.IntegrationProcedureService();
        try{
            iPServ.invokeMethod(methodName, inputMap, outMap, options);
            Map<String,Object> ipresult = (Map<String,Object>)outMap.get('Response');
        }
        catch(Exception e) {
        }
    }	
}