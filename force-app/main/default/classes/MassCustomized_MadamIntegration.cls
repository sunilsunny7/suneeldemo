/* 
* ******************************************************************************************************
* @author         Binamra Guha/Aditi Goyal
* @modifiedBy     Itishree Dash
* @maintainedBy   Itishree Dash/Lokesh Singh
* @version        1.0
* @created        2022-02-14
* @modified       2023-06-27
*
* ******************************************************************************************************
*/
/*
* ******************************************************************************************************
* This class is responsible for the CUSIN event trigger to AMANDA via GESB.
* API will support a set of operation on different information levels.
* This API will support the insert operations
* ******************************************************************************************************
*/
global with sharing class MassCustomized_MadamIntegration implements vlocity_cmt.VlocityOpenInterface 
{
    private static Boolean utilizerCheckFlag = false;
    private static Id OfferCli, offerProdId;
    private static Date contractStartDate, contractEndDate;
    private static Integer contractTerm;
    private static String agreementDetails, ownerStatus;
    private static Map<String, MC_RAMMFA_Settings__c> RAMMFAMap = MC_RAMMFA_Settings__c.getAll();
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) 
    {
        Map<String, Object> errorLogMap = new Map<String, Object>();
        String error_message = '';
        Map<String, Object> overallOutMap = new Map<String, Object>();
        try 
        {
            if(methodName.equals('manageMadamRequest'))
            {     
                manageMadamRequest(inputMap, outMap, options, errorLogMap);
                if(utilizerCheckFlag){
                    errorLog(errorLogMap);
                }
                if(outMap.get('errorCode') == 'INVOKE-200')
                {
                    outMap.put('errorMessage', 'OK');
                    outMap.put('success', true);
                    MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), String.valueOf(outMap.get('errorCode')),'MassCustomized_MadamIntegration','Apex Class', 'Success',JSON.serialize(inputMap),agreementDetails,'','');
                }
                if(!utilizerCheckFlag){
                    errorLog(errorLogMap);
                }
                outMap.remove('error');
            }
            else if(methodName.equals('underavtalAgreementRequest'))
            {
                underavtalAgreementRequest(inputMap, outMap, options, errorLogMap);
                if(outMap.get('errorCode') == 'INVOKE-200')
                {
                    outMap.put('errorMessage', 'OK');
                    outMap.put('success', true);
                    MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), String.valueOf(outMap.get('errorCode')),'MassCustomized_MadamIntegration','Apex Class', 'Success',JSON.serialize(inputMap),String.valueOf(options.get('superiorAgreementNumber')),'','');
                }
                if(errorLogMap != null){
                    errorLog(errorLogMap);
                }
                outMap.remove('error');
            }
            else if(methodName.equals('logError'))
            {     
                logError(inputMap, outMap, options);
            }
            else if(methodName.equals('logErrorWithoutFuture'))
            {     
                logErrorWithoutFuture(inputMap, outMap, options);
            }
            else if(methodName.equals('generateCustomError'))
            {   
                String errorName = String.valueOf(inputMap.get('ErrorScenario'));
                Boolean successFlag = false;
                generateCustomError(errorName, inputMap, outMap, successFlag);
            }
            else if(methodName.equals('getSessionInfo'))
            {   //info used for Bulk Data Load Jobs Status Check
                outMap.put('baseUrl',URl.getOrgDomainUrl().toExternalForm());
                outMap.put('token',UserInfo.getSessionId());
            }
        }catch(Exception e) 
        {
            error_message = e.getMessage()+' line:'+ e.getLineNumber();
            generateCustomError('TECH_ERROR_FROM_AMANDA', inputMap, outMap, false);
            overallOutMap.putAll(outMap);
            overallOutMap.put('exceptionError', String.valueOf(e.getMessage()+', Exception Trace:'+ e.getStackTraceString()));
            MCOnline_Utility.logError(JSON.serialize(overallOutMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Exception',JSON.serialize(inputMap),String.valueOf(options.get('serviceContractNumber')),'','');
            return false;
        }
        return true;
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for the mapping and validation of the request from input.
* This Method will also give custom error message depending upon the input.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param options                                  Map containing the query parameter
* @param errorLogMap                              Map containing the error response
* ************************************************************************************************************
*/  
    public static void manageMadamRequest(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options, Map<String,Object> errorLogMap)
    {
        Map<String, Object> inputRequest =(Map<String, Object>)inputMap;
        Map<String, Object> agreementNode= new Map<String, Object>();
        List<Contract> updatecontractList = new List<Contract>();
        String contractId= String.valueOf(options.get('contractId'));
        String contractNumber = String.valueOf(options.get('serviceContractNumber'));
        String OfferId;
        Boolean utilizerflag = true;
        Contract contractDetails = new Contract(); 
        if(inputRequest != null)
        {
            agreementNode = (Map<String, Object>)inputRequest.get('agreement');
        }
        if(contractId != null && !String.isBlank(contractId))
        {
            contractDetails= [Select id,ContractNumber,Account.Org_Nr__c,StartDate,EndDate,ContractTerm, Contract_Record_Type__c,Account.Id, MC_Agreed_Amount_Mobile__c,Status,Mconline_Status__c, MC_Agreed_Amount_TP__c, MC_Minideb_Alarm_Type__c, MC_Mobile_MiniDebWarning_Percentage__c, MC_Mobile_MiniDeb_WarningActive_Flag__c, MC_Number_Of_Subscriptions_Mobile__c, MC_Number_Of_Subscriptions_TP__c, MC_TP_MiniDebWarning_Percentage__c, MC_TP_MiniDeb_WarningActive_Flag__c,TeliaSE_TUPP_Status__c  from Contract Where Id =: contractId WITH SECURITY_ENFORCED Order By LastModifiedDate DESC Limit 1];
        }
        //Skip processing RAM readonly agreements
        else if(RAMMFAMap.get(String.valueOf(agreementNode.get('agreementType'))) == null)
        {
            outMap.put('errorCode','INVOKE-200');
            return;
        }
        
        if(contractDetails.ContractNumber != null){
            agreementDetails = String.valueOf(agreementNode.get('agreementNumber'))+'-'+contractDetails.ContractNumber;
        }else{
            agreementDetails = String.valueOf(agreementNode.get('agreementNumber'));
        }
        Set<String> tscidSet = new Set<String>();
        for(Account acc: [Select id, TSCID__c, Org_Nr__c, C2B_Org_nr__c from Account Where C2B_Org_nr__c =: checkNull(agreementNode.get('accountId'))]){
            if(acc.TSCID__c != null){
                tscidSet.add(acc.C2B_Org_nr__c);
            }
        }
        List<MC_Function_Agreement__c> functionAgreement = new List<MC_Function_Agreement__c>();
        if(tscidSet!= null && tscidSet.size() > 0){
            functionAgreement = [Select id, MC_Agreement_Number__c, MC_Agreement_technical_OrgNo__c, MC_TSCID__c,MC_Customer_Identification_Number__c  from MC_Function_Agreement__c Where MC_Customer_Identification_Number__c IN:tscidSet LIMIT 1];
        }
        //This If block is applicable when AMANDA already have the agreement present in the system (For Updates)
        if(inputRequest.get('operation') != null && !String.isBlank(contractId))
        {
            /*
            Here the logic for updation over non active RAMAVTAL agreement
            Validating the record type =Ramavtal If not Active 
            Agreement status V comes from Madam which represents the activation in MADAM and signals to make the chanegs in AMANDA */
            if(contractDetails.Contract_Record_Type__c.equalsIgnoreCase('Ramavtal') && contractDetails.status != null && !(contractDetails.status.equalsIgnoreCase('Active')) && String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('V'))
            {
                if((contractDetails.status.equalsIgnoreCase('Signed') || (contractDetails.Mconline_Status__c !='Valid' && (contractDetails.Mconline_Status__c!='' && contractDetails.Mconline_Status__c.equalsIgnoreCase('Freezed')))) && contractDetails.StartDate <= Date.Today() && (contractDetails.TeliaSE_TUPP_Status__c !=null && contractDetails.TeliaSE_TUPP_Status__c.equalsIgnoreCase('Active')))
                {
                    contractDetails.status = 'Active';
                    contractDetails.Mconline_Status__c= 'Valid';
                }
                else
                {
                    generateCustomError('AGR_STATUS_NOT_SIGNED', inputMap, outMap, false);
                    MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Validation',JSON.serialize(inputMap),agreementDetails,'','');
                    return;
                }  
            }
            //The Else If starts for Ramavtal/RAMMFA agreement cancellation . 
            /*
                if Status !=null and !cancelled 
                if agreementStatus =N represents cancellation in MADAM or Operation=delete 
                We are not cancelling the Contract in AMANDA But will not be available for MyB as Mconline_Status__c will be updated 
            */
            else if(contractDetails.status != null && !contractDetails.status.equalsIgnoreCase('Cancelled') && (String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('N') || String.valueOf(inputRequest.get('operation')).equalsIgnoreCase('Delete')))
            {
                if(contractDetails.status.equalsIgnoreCase('Active') || (contractDetails.Mconline_Status__c != 'Valid' && contractDetails.Mconline_Status__c.equalsIgnoreCase('Freezed')) || RAMMFAMap.get(String.valueOf(agreementNode.get('agreementType'))).Type_Name__c.equalsIgnoreCase(contractDetails.Contract_Record_Type__c))
                {
                    contractDetails.TeliaSE_Reason_for_Cancellation__c = 'Cancelled in MADAM';
                    contractDetails.Mconline_Status__c= 'Cancelled';
                }
                else
                {
                    generateCustomError('AGR_STATUS_NOT_ACTIVE', inputMap, outMap, false);
                    MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Validation',JSON.serialize(inputMap),agreementDetails,'','');
                    return;
                }
            }
            //else if we are validating if Status !=freezed and we have received the agreementStatus='E' represents Freezedin MADAM 
            else if(contractDetails.status != null && !contractDetails.status.equalsIgnoreCase('Freezed') && (String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('E')))
            {
                if(contractDetails.status.equalsIgnoreCase('Active') || (contractDetails.Mconline_Status__c != 'Valid' && !contractDetails.Mconline_Status__c.equalsIgnoreCase('Freezed')) || String.valueOf(RAMMFAMap.get(String.valueOf(agreementNode.get('agreementType'))).Type_Name__c).equalsIgnoreCase(contractDetails.Contract_Record_Type__c))
                {
                    contractDetails.Mconline_Status__c= 'Freezed';
                }
                else
                {
                    generateCustomError('AGR_STATUS_NOT_ACTIVE_FREEZED', inputMap, outMap, false);
                    MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Validation',JSON.serialize(inputMap),agreementDetails,'','');
                    return;
                }
            }
            contractDetails.MC_Agreed_Amount_Mobile__c = (!String.isBlank(checkNull(agreementNode.get('agreedAmountMobile')))) ? Decimal.valueOf(checkNull(agreementNode.get('agreedAmountMobile'))) : null;
            contractDetails.MC_Agreed_Amount_TP__c = (!String.isBlank(checkNull(agreementNode.get('agreedAmountTP')))) ? Decimal.valueOf(checkNull(agreementNode.get('agreedAmountTP'))) : null;
            contractDetails.MC_Minideb_Alarm_Type__c = checkNull(agreementNode.get('miniDebAlertType'));
            contractDetails.MC_Mobile_MiniDebWarning_Percentage__c = (!String.isBlank(checkNull(agreementNode.get('mobileMiniDebWarningPercentage')))) ? Decimal.valueOf(checkNull(agreementNode.get('mobileMiniDebWarningPercentage'))) : null;
            contractDetails.MC_Mobile_MiniDeb_WarningActive_Flag__c = checkNull(agreementNode.get('mobileMiniWarningActiveFlag'));
            contractDetails.MC_Number_Of_Subscriptions_Mobile__c = (!String.isBlank(checkNull(agreementNode.get('numberOfSubscriptionsMobile')))) ? Decimal.valueOf(checkNull(agreementNode.get('numberOfSubscriptionsMobile'))): null;
            contractDetails.MC_Number_Of_Subscriptions_TP__c = (!String.isBlank(checkNull(agreementNode.get('numberOfSubscriptionsTP')))) ? Decimal.valueOf(checkNull(agreementNode.get('numberOfSubscriptionsTP'))) :null;
            contractDetails.MC_TP_MiniDebWarning_Percentage__c = (!String.isBlank(checkNull(agreementNode.get('tpMiniDebWarningPercentage')))) ? Decimal.valueOf(checkNull(agreementNode.get('tpMiniDebWarningPercentage'))) : null;
            contractDetails.MC_TP_MiniDeb_WarningActive_Flag__c = checkNull(agreementNode.get('tpMiniWarningActiveFlag'));
            contractDetails.MC_Owner_Status__c = String.valueOf(agreementNode.get('ownerStatusDescr'));
            utilizerflag = agreementUtilizerMethod(inputMap, outMap, agreementNode, contractDetails.Id, contractDetails.Account.Org_Nr__c, contractDetails.Account.Id,contractNumber, errorLogMap);
            
            //The If starting from here is considered only for RAMMFA agreements incase of upsert || Update
            if(RAMMFAMap.get(String.valueOf(agreementNode.get('agreementType'))) != null && String.valueOf(agreementNode.get('agreementType')) != null && contractDetails.Contract_Record_Type__c != null && (contractDetails.Contract_Record_Type__c.equalsIgnoreCase(String.valueOf(RAMMFAMap.get(String.valueOf(agreementNode.get('agreementType'))).Type_Name__c))))
            {
                String agreementCategory = (String.valueOf(agreementNode.get('agreementType')) == 'EMR') ? '%EMN%' : ('%' + checkNull(agreementNode.get('agreementCategory')) + '%');
                    OfferId = [Select Id, ProductCode, Name, TeliaSE_Subscription_Type__c from Product2 Where ProductCode LIKE :agreementCategory AND Family = 'Mobility Management' AND C2BC_Category__c = 'offerbundle' AND IsActive= true AND vlocity_cmt__Status__c= 'Active' LIMIT 1]?.Id;
                if(String.IsBlank(OfferId))
                {
                    generateCustomError('INVALID_AGREEMENT_CATEGORY', inputMap, outMap, false);
                    MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Validation',JSON.serialize(inputMap),agreementDetails,'','');
                    return;
                }
                if(agreementNode.get('agreementStartDate') != null){
                    contractStartDate = Date.valueOf(String.valueOf(agreementNode.get('agreementStartDate')));
                }
                if(agreementNode.get('agreementEndDate') != null){
                    contractEndDate = Date.valueOf(String.valueOf(agreementNode.get('agreementEndDate')));
                }
                if(contractStartDate != null && contractEndDate != null){
                    contractTerm = contractStartDate.monthsBetween(contractEndDate);
                }
                contractDetails.StartDate = contractStartDate;
                contractDetails.MC_Agreement_Category__c = checkNull(agreementNode.get('agreementCategory'));
                contractDetails.EndDate = contractEndDate;
                contractDetails.ContractTerm = contractTerm;
                if(contractDetails.Mconline_Status__c != 'Cancelled')
                {
                    insertContractLine(JSON.serialize(agreementNode), contractId, JSON.serialize(inputRequest), JSON.serialize(outMap), JSON.serialize(options), JSON.serialize(errorLogMap));
                }
            }
            if(utilizerflag)
            {
                agreementControllerServices(inputMap, outMap, inputRequest, contractDetails.Id, errorLogMap);
                if(contractDetails != null)
                {
                    Database.update(contractDetails, false);
                }
            }
        }
        // This else is used to create new agreement
        else
        {
            if(functionAgreement.isEmpty()){
                insertAgreement(inputRequest, outMap, options, errorLogMap,OfferId);
            }
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for the mapping and validation of the request from input.
* This Method will also give custom error message depending upon the input.
* In this method, we deals with UNDERAVTAL agreement coming from MADAM.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param options                                  Map containing the query parameter
* @param errorLogMap                              Map containing the error response
* ************************************************************************************************************
*/    
    public static void underavtalAgreementRequest(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options, Map<String,Object> errorLogMap){
        Map<String, Object> agreementNode= new Map<String, Object>();
        if(inputMap != null)
        {
            agreementNode = (Map<String, Object>)inputMap.get('agreement');
        }
        List<Account> accId = [Select Id, C2B_Org_nr__c, Org_Nr__c, Name from Account Where C2B_Org_nr__c =: String.valueOf(agreementNode.get('accountId')) LIMIT 1];
        List<Contract> conList = [Select Id from Contract Where Agreement_Nr__c =: String.valueOf(agreementNode.get('superiorAgreementNumber'))];
        if(accId.isEmpty())
        {
            generateCustomError('ACCOUNT_NOT_FOUND', inputMap, outMap, false);
            MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Validation',JSON.serialize(inputMap),String.valueOf(agreementNode.get('superiorAgreementNumber')),'','');
            return;
        }
        else if(conList.isEmpty())
        {
            generateCustomError('AGREEMENT_NOT_FOUND', inputMap, outMap, false);
            MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Validation',JSON.serialize(inputMap),String.valueOf(agreementNode.get('superiorAgreementNumber')),'','');
            return;
        }
        else
        {
            Utilizer_Contract_Relationship__c uti1;
            List<Utilizer_Contract_Relationship__c> updateUtilizerList =new List<Utilizer_Contract_Relationship__c>();
            List<Utilizer_Contract_Relationship__c> insertUtilizerList =new List<Utilizer_Contract_Relationship__c>();
            Set<Id> conIdSet = (new map<id,Contract>(conList)).keySet();
            List<Utilizer_Contract_Relationship__c> utilizerList = [Select id, MC_Underavtal_Flag__c , ContractNumber__c, AccountId__c, Status__c, Name, AccountId__r.Org_Nr__c,AccountId__r.C2B_Org_nr__c, Org_Number__c from Utilizer_Contract_Relationship__c Where ContractNumber__c IN: conIdSet AND AccountId__c =: accId[0].Id];
            if(utilizerList != null && utilizerList.size()>0){
                for(Utilizer_Contract_Relationship__c uti:utilizerList){
                    if(agreementNode.get('agreementStatus') != null && (String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('V') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('VALID')))
                    {
                        uti.Status__c = 'Aktiv';
                    }
                    else if(agreementNode.get('agreementStatus') != null && (String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('E') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('EXISTS') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('EXIST')))
                    {
                        uti.Status__c = 'Freezed';
                    }
                    else if(agreementNode.get('agreementStatus') != null && (String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('N') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('NOT VALID') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('NOT_VALID')))
                    {
                        uti.Status__c = 'Inaktiv';
                    }
                    uti.MC_Underavtal_Flag__c = true;
                    updateUtilizerList.add(uti);
                }
            }
            else
            {
                for(Id conId: conIdSet){
                    uti1 = new Utilizer_Contract_Relationship__c();
                    uti1.Name = accId[0].Name;
                    uti1.Org_Number__c = accId[0].Org_Nr__c;
                    uti1.ContractNumber__c = conId;
                    uti1.AccountId__c = accId[0].Id;
                    if(agreementNode.get('agreementStatus') != null && (String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('V') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('VALID')))
                    {
                        uti1.Status__c = 'Aktiv';
                    }
                    else if(agreementNode.get('agreementStatus') != null && (String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('E') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('EXISTS') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('EXIST')))
                    {
                        uti1.Status__c = 'Freezed';
                    }
                    else if(agreementNode.get('agreementStatus') != null && (String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('N') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('NOT VALID') || String.valueOf(agreementNode.get('agreementStatus')).equalsIgnoreCase('NOT_VALID')))
                    {
                        uti1.Status__c = 'Inaktiv';
                    }
                    uti1.MC_Underavtal_Flag__c = true;
                    insertUtilizerList.add(uti1);
                }
            }
            if(!updateUtilizerList.isEmpty())
            {
                Database.update(updateUtilizerList, false);
            }
            if(!insertUtilizerList.isEmpty())
            {
                Database.insert(insertUtilizerList, false);
            }
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for the updating and inserting of the utilizer from input.
* For invalid org Number we are storing the value in a custom object for future retry.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param obj1                                     Object containing only the agreement Node
* @param contractId                               contract id as per the input
* @param orgNo                                    Organization Number as per the input
* @param accountId                                account id as per the input
* @param contractNumber                           Contract Number as per the input
* @param errorLogMap                              Map containing the error response
* ************************************************************************************************************
*/  
    public static Boolean agreementUtilizerMethod(Map<String, Object> inputMap, Map<String, Object> outMap, Object obj1, String contractId, String orgNo, String accountId,String contractNumber, Map<String,Object> errorLogMap)
    {
        Map<String, Object> requestMap = (Map<String, Object>)obj1;
        List<Utilizer_Contract_Relationship__c> utilizerList = [Select id, MC_Underavtal_Flag__c, ContractNumber__c, AccountId__c, ContractNumber__r.Id, Status__c, Name, AccountId__r.Org_Nr__c,AccountId__r.C2B_Org_nr__c, Org_Number__c from Utilizer_Contract_Relationship__c Where ContractNumber__r.Id =: contractId];
        List<Object> requestedUtilizerList = (List<Object>)requestMap.get('utilizer');
        Map<String, Utilizer_Contract_Relationship__c> utilizerMap = new Map<String, Utilizer_Contract_Relationship__c>();
        Set<String> organisationNumberList = new Set<String>();
        if(requestedUtilizerList!= null && requestedUtilizerList.size()>0)
        {
            for(Object utiLst: requestedUtilizerList)
            {
                Map<String, Object> utiMap1 = (Map<String, Object>)utiLst;
                organisationNumberList.add(String.valueOf(utiMap1.get('organizationNumber')));
            }
        }
        Map<Id, Contract> ContractMap = new Map<Id,Contract>([SELECT id, AccountId, Contract_Record_Type__c FROM Contract WHERE Id =: contractId]);
        Set<String> accOrg = new Set<String>();
        Map<String, Account> accOrgId = new Map<String, Account>();
        if( organisationNumberList!=null && organisationNumberList.size()>0){
            for(Account acc: [Select id, C2B_Org_nr__c, Org_Nr__c from Account Where C2B_Org_nr__c IN: organisationNumberList]){
                accOrg.add(acc.C2B_Org_nr__c);
                accOrgId.put(acc.C2B_Org_nr__c, acc);
            }
        }
        List<Utilizer_Contract_Relationship__c> updateUtilizerList =new List<Utilizer_Contract_Relationship__c>();
        List<Utilizer_Contract_Relationship__c> insertUtilizerList =new List<Utilizer_Contract_Relationship__c>();
        List<Account> accountUpdateList = new List <Account>();
        if(utilizerList!= null && utilizerList.size()>0){
            for(Utilizer_Contract_Relationship__c uti: utilizerList){
                utilizerMap.put(uti.AccountId__r.C2B_Org_nr__c, uti);
                //added for utilizer 'not valid' in MADAM scenario, as it won't be sent in the request
                if((uti.Status__c == 'Aktiv' || uti.Status__c == 'Freezed')  && !accOrg.contains(uti.AccountId__r.C2B_Org_nr__c)){
                    uti.Status__c = 'Inaktiv';
                    updateUtilizerList.add(uti);
                }
            }
        }
        Map<String, List<Object>> invalidOrgUtilizer = new Map<String, List<Object>>();
        if(requestedUtilizerList!= null && requestedUtilizerList.size()>0){
            for(Object uti: requestedUtilizerList){
                Map<String, Object> utiMap = (Map<String, Object>)uti;
                if(accOrg != null && accOrg.contains(String.valueOf(utiMap.get('organizationNumber')))){
                    if(String.valueOf(utiMap.get('organizationNumber')) != null && utilizerMap.containsKey(String.valueOf(utiMap.get('organizationNumber')))){
                        Utilizer_Contract_Relationship__c uti2 = utilizerMap.get(String.valueOf(utiMap.get('organizationNumber')));
                        if(String.valueOf(utiMap.get('status')) != null && (String.valueOf(utiMap.get('status')).equalsIgnoreCase('V') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('VALID'))){
                            uti2.Status__c = 'Aktiv';
                            if(contractMap.get(contractId).Contract_Record_Type__c == 'Ramavtal'){
                                Account a = new Account();
                                a.Id = Id.valueOf(accOrgId.get(String.valueOf(utiMap.get('organizationNumber'))).Id);
                                a.FA_Contract__c = contractId;
                                if(a.Id == contractMap.get(contractId).AccountId){
                                    a.TeliaSE_Utilzer_Role__c = 'Owner'; 
                                }   
                                else{
                                    a.TeliaSE_Utilzer_Role__c = 'Utilizer';
                                }
                                accountUpdateList.add(a);   
                            }
                        }
                        else if(String.valueOf(utiMap.get('status')) != null && (String.valueOf(utiMap.get('status')).equalsIgnoreCase('E') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('EXISTS') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('EXIST')))
                        {
                            uti2.Status__c = 'Freezed';
                        }
                        else if(String.valueOf(utiMap.get('status')) != null && (String.valueOf(utiMap.get('status')).equalsIgnoreCase('N') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('NOT VALID') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('NOT_VALID')))
                        {
                            uti2.Status__c = 'Inaktiv';
                        }
                        uti2.Name = checkNull(String.valueOf(utiMap.get('name')));
                        updateUtilizerList.add(uti2);
                    }
                    else
                    {
                        Utilizer_Contract_Relationship__c uti3 = new Utilizer_Contract_Relationship__c();
                        uti3.Name = String.valueOf(utiMap.get('name'));
                        uti3.Org_Number__c = String.valueOf(accOrgId.get(String.valueOf(utiMap.get('organizationNumber'))).Org_Nr__c);
                        uti3.ContractNumber__c = Id.valueOf(contractId);
                        uti3.AccountId__c = Id.valueOf(accOrgId.get(String.valueOf(utiMap.get('organizationNumber'))).Id);
                        if(String.valueOf(utiMap.get('status')) != null && (String.valueOf(utiMap.get('status')).equalsIgnoreCase('V') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('VALID')))
                        {
                            uti3.Status__c = 'Aktiv';
                            if(contractMap.get(contractId).Contract_Record_Type__c == 'Ramavtal')
                            {
                                Account a = new Account();
                                a.Id = Id.valueOf(accOrgId.get(String.valueOf(utiMap.get('organizationNumber'))).Id);
                                a.FA_Contract__c = contractId;
                                if(a.Id == contractMap.get(contractId).AccountId){
                                    a.TeliaSE_Utilzer_Role__c = 'Owner'; 
                                }
                                else {
                                    a.TeliaSE_Utilzer_Role__c = 'Utilizer';
                                }
                                accountUpdateList.add(a);
                                
                            }
                        }
                        else if(String.valueOf(utiMap.get('status')) != null && (String.valueOf(utiMap.get('status')).equalsIgnoreCase('E') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('EXISTS') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('EXIST')))
                        {
                            uti3.Status__c = 'Freezed';
                        }
                        else if(String.valueOf(utiMap.get('status')) != null && (String.valueOf(utiMap.get('status')).equalsIgnoreCase('N') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('NOT VALID') || String.valueOf(utiMap.get('status')).equalsIgnoreCase('NOT_VALID')))
                        {
                            uti3.Status__c = 'Inaktiv';
                        }
                        insertUtilizerList.add(uti3);
                    }
                }else
                {
                    utilizerCheckFlag = true;
                    if(invalidOrgUtilizer.get('utilizer')!=null)
                    {
                        invalidOrgUtilizer.get('utilizer').add(utiMap);
                    }else
                    {
                        invalidOrgUtilizer.put('utilizer', new List<Object>{utiMap});
                    }
                }
            }
            if(invalidOrgUtilizer != null && utilizerCheckFlag){
                MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(invalidOrgUtilizer), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Mismatch',JSON.serialize(inputMap),agreementDetails,'','');
            }
            if(updateUtilizerList.size()>0){
                Database.update(updateUtilizerList, false);
            }
            if(insertUtilizerList.size()>0){
                Database.insert(insertUtilizerList, false);
            }
            if(accountUpdateList.size()>0){
                Database.update(accountUpdateList, false);
            }
        }
        return true;
    }
    
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for the updating and inserting of the services from input for agreementContoller.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param obj1                                     Object containing the input
* @param contractId                               contract id as per the input
* @param errorLogMap                              Map containing the error response
* ************************************************************************************************************
*/    
    public static void agreementControllerServices(Map<String, Object> inputMap, Map<String, Object> outMap, Object obj1, String contractId, Map<String,Object> errorLogMap)
    {
        Map<String, Object> tempMap = (Map<String, Object>)obj1;
        Map<String, Object> agreement = new Map<String, Object>();
        String action,agreementNumber;
        if(tempMap != null){
            agreement= (Map<String, Object>)tempMap.get('agreement');
            action = checkNull(tempMap.get('operation'));
        }
        List<Object> servicesList = new List<Object>();
        Set<String> storeAgrDetails = new Set<String>();
        if(agreement != null){
            servicesList = (List<Object>)agreement.get('services');
            agreementNumber = checkNull(agreement.get('agreementNumber'));  
        }
        if(servicesList!= null && servicesList.size()>0){
            for(Object obj: servicesList){
                Map<String, Object> services = (Map<String,Object>)obj;
                if(services != null){
                    String agreementServiceCode = checkNull(services.get('serviceCode'));
                    String agreementServiceType = checkNull(services.get('serviceType'));
                    String agreementSubscriptionType = checkNull(services.get('subscriptionType'));
                    storeAgrDetails.add(agreementNumber+''+agreementServiceCode+''+agreementServiceType+''+agreementSubscriptionType);
                }
            }
        }
        List<MCOnline_Agreement_Services_Temp_data__c> agrList = new List<MCOnline_Agreement_Services_Temp_data__c>();
        if(servicesList!= null && storeAgrDetails.size() > 0){
            agrList = [Select id from MCOnline_Agreement_Services_Temp_data__c Where MCOnline_UniqueAgreementIdentifier__c IN :storeAgrDetails];
        }
        if(agrList!= null && agrList.size() > 0){
            Database.delete(agrList, false);
        }
        if(!action.equalsIgnoreCase('delete')){
            List<MCOnline_Agreement_Services_Temp_data__c> tempDataList = new List<MCOnline_Agreement_Services_Temp_data__c>();
            if(servicesList!= null && servicesList.size() > 0){
                for(Object obj: servicesList){
                    Map<String, Object> services = (Map<String,Object>)obj;
                    MCOnline_Agreement_Services_Temp_data__c agree = new MCOnline_Agreement_Services_Temp_data__c();
                    if(services != null){
                        agree.MCOnline_Agreement_number__c = checkNull(agreementNumber);
                        agree.MCOnline_Agreement_Status__c = checkNull(agreement.get('agreementStatus'));
                        agree.MCOnline_Service_availability__c = checkNull(services.get('serviceAvailable'));
                        agree.MCOnline_Service_code__c = checkNull(services.get('serviceCode'));
                        agree.MCOnline_Service_Contract_ID__c = checkNull(agreement.get('serviceContractNumber'));
                        agree.MCOnline_Service_status__c = checkNull(services.get('serviceStatus'));
                        agree.MCOnline_Service_type__c = checkNull(services.get('serviceType'));
                        agree.MCOnline_Contract__c = checkNull(contractId);
                        agree.MCOnline_Subscription_type_code__c = checkNull(services.get('subscriptionType'));
                        agree.MCOnline_Subscription_type_Status__c = checkNull(services.get('subscriptionTypeStatus'));
                        tempDataList.add(agree);
                    }
                }
            }
            if(tempDataList.size() > 0){
                Database.insert(tempDataList, false);
            }
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is called when the operation is 'insert'.
* This method allows us to insert contract and contract line Items.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param options                                  Map containing the query parameter
* @param errorLogMap                              Map containing the error response
* ************************************************************************************************************
*/  
    //@future(callout=true)
    public static void insertAgreement(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options, Map<String,Object> errorLogMap,String OfferId)
    {
        String operation = '', recordType = '';
        Map<String, Object> agreement = new Map<String, Object>();
        if(inputMap !=  null){
            operation = checkNull(inputMap.get('operation'));
            agreement = (Map<String, Object>)inputMap.get('agreement');
        }
        String agreementCategory = (String.valueOf(agreement.get('agreementType')) == 'EMR') ? '%EMN%' : ('%' + checkNull(agreement.get('agreementCategory')) + '%');
            String contractNumber = String.valueOf(agreement.get('serviceContractNumber'));
        Id accId = [Select id, Org_Nr__c,C2B_Org_nr__c from Account Where C2B_Org_nr__c =: checkNull(agreement.get('accountId')) LIMIT 1 FOR UPDATE]?.Id;
        OfferId = [Select Id, ProductCode, Name, TeliaSE_Subscription_Type__c from Product2 Where ProductCode LIKE :agreementCategory AND Family = 'Mobility Management' AND C2BC_Category__c = 'offerbundle' AND IsActive= true AND vlocity_cmt__Status__c= 'Active' LIMIT 1]?.Id;
        if(accId == null){
            generateCustomError('ACCOUNT_NOT_FOUND', inputMap, outMap, false);
            MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Validation',JSON.serialize(inputMap),agreementDetails,'','');
            return;
        }
        else if(String.IsBlank(OfferId)){
            generateCustomError('INVALID_AGREEMENT_CATEGORY', inputMap, outMap, false);
            MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Validation',JSON.serialize(inputMap),agreementDetails,'','');
            return;
        }
        else{
            List<Object> agreementItems = (List<Object>)agreement.get('agreementItem');
            Map<String, Object> contractHeaderInfo = new Map<String, Object>();
            If(agreement.get('ownerStatusDescr') != null){
                ownerStatus = checkNull(agreement.get('ownerStatusDescr'));
            }
            if(agreement.get('agreementStartDate') != null){
                contractStartDate = Date.valueOf(checkNull(agreement.get('agreementStartDate')));
            }
            if(agreement.get('agreementEndDate') != null){
                contractEndDate = Date.valueOf(checkNull(agreement.get('agreementEndDate')));
            }
            if(contractStartDate != null && contractEndDate != null){
                contractTerm = contractStartDate.monthsBetween(contractEndDate);
            }
            if(String.valueOf(agreement.get('agreementType')) != null && (String.valueOf(agreement.get('agreementType')).equalsIgnoreCase('STO')))
            {
                recordType = RAMMFAMap.get(String.valueOf(agreement.get('agreementType'))).Type_Name__c;
            }else if(String.valueOf(agreement.get('agreementType')) != null && (String.valueOf(agreement.get('agreementType')).equalsIgnoreCase('SME'))){
                recordType = RAMMFAMap.get(String.valueOf(agreement.get('agreementType'))).Type_Name__c;
            }else if(String.valueOf(agreement.get('agreementType')) != null && (String.valueOf(agreement.get('agreementType')).equalsIgnoreCase('EMR'))){
                recordType = RAMMFAMap.get(String.valueOf(agreement.get('agreementType'))).Type_Name__c;
            }
            Id rt1 = [Select id,name, DeveloperName from RecordType where Name=:recordType LIMIT 1]?.Id;
            Contract con = new Contract();
            if(rt1 == null)
            {
                generateCustomError('AGR_LEVEL_MISMATCH', inputMap, outMap, false);
                MassCustomized_MadamIntegration.getErrorLog(errorLogMap, JSON.serialize(outMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Data Validation',JSON.serialize(inputMap),agreementDetails,'','');
                return;
            }
            else
            {
                con.RecordTypeId = rt1;
                con.AccountId = accId;
                con.Status = 'Draft';
                con.Type_of_Agreement__c = checkNull(agreement.get('agreementType'));
                con.StartDate = contractStartDate;
                con.EndDate = contractEndDate;
                con.MC_Owner_Status__c = String.valueOf(agreement.get('ownerStatusDescr'));
                con.MC_Agreement_Category__c = checkNull(agreement.get('agreementCategory'));
                con.Agreement_Nr__c = checkNull(agreement.get('agreementNumber'));
                if(contractTerm>0){
                    con.ContractTerm = contractTerm;
                }
                insert con;
            }
            agreementControllerServices(inputMap, outMap, inputMap, con.Id, errorLogMap);
            if(con.Id != null)
            {
                String contractNo = [Select ContractNumber from Contract Where Id =: con.Id LIMIT 1]?.ContractNumber;
                if(contractNo != null){
                    agreementDetails = String.valueOf(agreement.get('agreementNumber'))+'-'+String.valueOf(contractNo);
                }else{
                    agreementDetails = String.valueOf(agreement.get('agreementNumber'));
                }
                if(options.get('agreementList')!=null && ((List<Object>)options.get('agreementList')).size()>0)
                {
                    Contract oldContract=new Contract();
                    oldContract.Id=Id.valueOf(((List<Object>)options.get('agreementList'))[0]+'');
                    oldContract.status='Cancelled';
                    oldContract.Mconline_Status__c='Cancelled';
                    oldContract.Reason_for_Cancellation__c='agreement type change';
                    update oldContract; 
                }
                insertContractLine(JSON.serialize(agreement), con.Id, JSON.serialize(inputMap), JSON.serialize(outMap), JSON.serialize(options), JSON.serialize(errorLogMap));
            }
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is called when the operation is 'insert' and 'update'.
* This method allows us to insert contract line Items.
* ************************************************************************************************************
* @param agreementNode                            Serialize Json containing agreement node
* @param contractId                               Containing contract id
* @param inputMapString                           Serialize Map containing the input coming from the user
* @param outMapString                             Serialize Map that contains the output response
* @param optionsString                            Serialize Map containing the query parameter
* @param errorLogMapString                        Serialize Map containing the error response
* ************************************************************************************************************
*/  
    @future(callout=true)
    public static void insertContractLine(String agreementNode, Id contractId, String inputMapString, String outMapString, String optionsString, String errorLogMapString)
    {
        String error_message = '';
        Map<String,String> defaultOffersMap=new Map<String,String>();
        Map<String,String> pciMap=new Map<String,String>();
        List<String> defaultOffers=RAMMFAMap.get('DefaultOffers').Type_Name__c.split(',');
        
        Map<String, Object> overallOutMap = new Map<String, Object>();
        Map<String,Object> inputMap = (Map<String,Object>)JSON.deserializeUntyped(inputMapString);
        Map<String,Object> outMap = (Map<String,Object>)JSON.deserializeUntyped(outMapString);
        Map<String,Object> options = (Map<String,Object>)JSON.deserializeUntyped(optionsString);
        Map<String,Object> errorLogMap = (Map<String,Object>)JSON.deserializeUntyped(errorLogMapString);
        try{            
            Map<String,Object> agreement = (Map<String,Object>)JSON.deserializeUntyped(agreementNode);
            Contract conStr = [Select ContractNumber, id from Contract Where Id =: contractId WITH SECURITY_ENFORCED LIMIT 1 FOR UPDATE];
            if(conStr.ContractNumber != null){
                agreementDetails = String.valueOf(agreement.get('agreementNumber'))+'-'+String.valueOf(conStr.ContractNumber);
            }else{
                agreementDetails = String.valueOf(agreement.get('agreementNumber'));
            }
            List<Object> agreementItems = (List<Object>)agreement.get('agreementItem');
            List<String> unAvailableSubs=new List<String>(); 
            String agrCode = checkNull(agreement.get('agreementNumber'));
            Set<String> subscriptionTypeSet = new Set<String>();
            List<String> notValidSubscriptionTypeList = new List<String>();
            List<String> existsSubsList = new List<String>();
            Map<String, String> subsStatus=new Map<String, String>();
            String isSubsidized =agreement.get('agrBnd')!=null && String.valueOf(agreement.get('agrBnd')).equalsIgnoreCase('Y')?'YES':'NO';
            String agreementCategory =  (String.valueOf(agreement.get('agreementType')) == 'EMR') ? '%EMN%' : ('%' + checkNull(agreement.get('agreementCategory')) + '%');
            if(agreementItems != null && agreementItems.size()>0)
            {
                unAvailableSubs= storeSubTypes(agreementItems,agreementCategory,false);
                for(Object agr: agreementItems)
                {
                    Map<String, Object> agrMap = (Map<String, Object>)agr;
                    subscriptionTypeSet.add(String.valueOf(agrMap.get('subscriptionType')));
                    subscriptionTypeSet.add('KÖ-'+String.valueOf(agrMap.get('subscriptionType')));
                    subscriptionTypeSet.add(String.valueOf(agrMap.get('subscriptionType'))+'-KÖ');
                    subsStatus.put(agrMap.get('subscriptionType')+'',agrMap.get('subscriptionTypeStatus')+'');
                    if(String.valueOf(agrMap.get('subscriptionTypeStatus')).equalsIgnoreCase('Not Valid'))
                    {
                        notValidSubscriptionTypeList.add(String.valueOf(agrMap.get('subscriptionType')));
                        notValidSubscriptionTypeList.add('KÖ-'+String.valueOf(agrMap.get('subscriptionType')));
                        notValidSubscriptionTypeList.add(String.valueOf(agrMap.get('subscriptionType'))+'-KÖ');
                    }
                    else if((String.valueOf(agrMap.get('subscriptionTypeStatus')).equalsIgnoreCase('EXISTS')))
                    {
                        existsSubsList.add(String.valueOf(agrMap.get('subscriptionType')));
                        existsSubsList.add('KÖ-'+String.valueOf(agrMap.get('subscriptionType')));
                        existsSubsList.add(String.valueOf(agrMap.get('subscriptionType'))+'-KÖ');
                    }
                }
            }
            List<String> avilableSubs=storeSubTypes(agreementItems,agreementCategory,true);
            for(vlocity_cmt__ProductChildItem__c childPCI:[select vlocity_cmt__ChildProductId__r.productcode,vlocity_cmt__ParentProductId__r.productcode from vlocity_cmt__ProductChildItem__c where (vlocity_cmt__ParentProductId__r.productcode in :defaultOffers or vlocity_cmt__ParentProductId__r.productcode like :agreementCategory) and name!='Root PCI' and vlocity_cmt__ParentProductId__r.Family='Mobility Management' WITH SECURITY_ENFORCED])
            {
                if(defaultOffers.contains(childPCI.vlocity_cmt__ParentProductId__r.productcode))
                {
                    defaultOffersMap.put(childPCI.vlocity_cmt__ChildProductId__r.productcode,childPCI.vlocity_cmt__ParentProductId__r.productcode);
                }
                pciMap.put(childPCI.vlocity_cmt__ChildProductId__r.productcode,childPCI.vlocity_cmt__ParentProductId__r.productcode);
            }
            Map<String,String> tempMapRemove=new Map<String,String>(defaultOffersMap);
            for(String childCode:tempMapRemove.keySet())
            {
                if(pciMap.containsKey(childCode))
                {
                    defaultOffersMap.remove(childCode);
                }
            }
            
            Map<String, Product2> offerMap = new Map<String, Product2>();
            for(Product2 pr: [Select Id, ProductCode, Name, TeliaSE_Subscription_Type__c, Family from Product2 Where (ProductCode LIKE :agreementCategory or productcode in :defaultOffers) AND Family = 'Mobility Management' AND C2BC_Category__c = 'offerbundle' AND IsActive= true AND vlocity_cmt__Status__c= 'Active' WITH SECURITY_ENFORCED]){
                offerMap.put(pr.ProductCode, pr);
            }
            Set<String> createDefaultOffers=new Set<String>();
            for(String str:avilableSubs)
            {
                if(defaultOffersMap.containsKey('AGR_'+str))
                {
                    createDefaultOffers.add(defaultOffersMap.get('AGR_'+str));
                }
            }
            
            Map<String,Product2> productMap=new Map<String,Product2>();
            for(Product2 pr: [Select Id, ProductCode, Name, TeliaSE_Subscription_Type__c from Product2 Where ProductCode LIKE '%AGR%' AND Family = 'Online Order' AND TeliaSE_Subscription_Type__c IN: subscriptionTypeSet AND IsActive= true AND vlocity_cmt__Status__c= 'Active' WITH SECURITY_ENFORCED]){
                productMap.put(pr.ProductCode, pr);
            }
            Map<String, vlocity_cmt__ContractLineItem__c> cCliMap = new Map<String, vlocity_cmt__ContractLineItem__c>();
            Map<String, vlocity_cmt__ContractLineItem__c> nonSubClis = new Map<String, vlocity_cmt__ContractLineItem__c>();
            Map<String, String> cliSubTypeMap= new Map<String, String>();
            Map<String, String> extCliSubMap= new Map<String, String>();
            Boolean prodFlag = false;
            List<vlocity_cmt__ContractLineItem__c> befDeleteCliList = new List<vlocity_cmt__ContractLineItem__c>();
            String offerFlag;
            for(vlocity_cmt__ContractLineItem__c cCli : [Select id,name, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c,MC_lineItem_Status__c from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =: contractId WITH SECURITY_ENFORCED])
            {
                if(cCli.vlocity_cmt__Product2Id__c != null)
                {
                    offerFlag =offerMap.keySet().contains(cCli.vlocity_cmt__Product2Id__r.ProductCode) && cCli.vlocity_cmt__Product2Id__r.ProductCode.contains(agreement.get('agreementCategory')+'')?cCli.Id:offerFlag;
                    cCliMap.put(cCli.vlocity_cmt__Product2Id__c, cCli);
                    cliSubTypeMap.put(cCli.vlocity_cmt__Product2Id__c, cCli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c);
                    extCliSubMap.put(cCli.vlocity_cmt__Product2Id__c,cCli.MC_lineItem_Status__c);
                    prodFlag = true;
                    befDeleteCliList.add(cCli);
                }
                else
                {
                    nonSubClis.put(cCli.name,cCli);
                }
            }
            if(prodFlag && String.IsBlank(offerFlag)){
                Database.delete(befDeleteCliList, false);
            }
            List<vlocity_cmt__ContractLineItem__c> updateCliList = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c> insertCliOfferList = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c> insertCliList = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c> deleteCliList = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c> unAvailCLIList= new List<vlocity_cmt__ContractLineItem__c>();
            String agrBnd = (String.valueOf(agreement.get('agrBnd')) != null && String.valueOf(agreement.get('agrBnd')).equalsIgnoreCase('Y')) ? 'Yes' : 'No';
            
            insertOffer(insertCliOfferList, updateCliList, offerMap, agrBnd, cCliMap, contractId,createDefaultOffers);
            if(insertCliOfferList.size()>0)
            {
                Database.insert(insertCliOfferList, false);
            }
            Map<String,vlocity_cmt__ContractLineItem__c> rootMap=new Map<String,vlocity_cmt__ContractLineItem__c>();
            for(vlocity_cmt__ContractLineItem__c cli:[select id,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__Product2Id__c from vlocity_cmt__ContractLineItem__c  where id =:insertCliOfferList WITH SECURITY_ENFORCED]){
                rootMap.put(cli.vlocity_cmt__Product2Id__r.ProductCode,cli);
            }
            OfferCli = (insertCliOfferList.size()>0 && insertCliOfferList[0].Id!=null) ? insertCliOfferList[0].Id: OfferCli;
            offerProdId = (insertCliOfferList.size()>0 && insertCliOfferList[0].vlocity_cmt__Product2Id__c!=null) ? insertCliOfferList[0].vlocity_cmt__Product2Id__c: offerProdId;
            Map<String,Object> channelFlags=new Map<String,Object>();
            Map<String,Object> channelFlagsLst=new Map<String,Object>();
            if(channelFlags.get('agreementItem')!=null)
                channelFlags=(Map<String,Object>)JSON.deserializeUntyped(agreementNode);
            channelFlagsLst=(Map<String,Object>)channelFlags.get('agreementItem');
            for(String key: productMap.keySet())
            {
                Product2 prod = productMap.get(key);
                if(cCliMap.containsKey(prod.Id)){
                    vlocity_cmt__ContractLineItem__c contr = cCliMap.get(prod.Id);
                    if(notValidSubscriptionTypeList != null && cliSubTypeMap!= null && notValidSubscriptionTypeList.contains(cliSubTypeMap.get(prod.Id))){
                        deleteCliList.add(contr);
                    }
                    else if((existsSubsList.size()>0 && existsSubsList.contains(cliSubTypeMap.get(prod.Id))) &&((extCliSubMap.get(prod.Id) !=null) && (extCliSubMap.get(prod.Id).equalsIgnoreCase('Exists'))) )
                    {
                        continue;
                    }
                    else
                    {
                        contr.TeliaSE_SubsidisedVoice__c = agrBnd;
                        contr.TeliaSE_Start_Date__c = contractStartDate;
                        contr.TeliaSE_End_Date__c = contractEndDate;
                        contr.MC_lineItem_Status__c= cliSubTypeMap.get(prod.Id)!=null && cliSubTypeMap.get(prod.Id).startsWith('KÖ-')?subsStatus.get('SF'):cliSubTypeMap.get(prod.Id)!=null && cliSubTypeMap.get(prod.Id).endsWith('-KÖ')?subsStatus.get('KÄ'):subsStatus.get(cliSubTypeMap.get(prod.Id));
                        if(channelFlagsLst !=null)
                        {
                            contr.MC_Show_Subscription_In_Channel__c=String.valueOf(channelFlagsLst.get('channelFlag'));
                        }
                        else
                        {
                            contr.MC_Show_Subscription_In_Channel__c='Y';
                        }
                        updateCliList.add(contr);
                    }
                }
                else if((!notValidSubscriptionTypeList.contains(prod.TeliaSE_Subscription_Type__c)) || ((existsSubsList.contains(prod.TeliaSE_Subscription_Type__c))&& !(existsSubsList.contains(String.valueOf(cliSubTypeMap.get(prod.Id))))))
                {   
                    vlocity_cmt__ContractLineItem__c contr = new vlocity_cmt__ContractLineItem__c();
                    contr.Name = checkNull(prod.Name);
                    contr.vlocity_cmt__Product2Id__c = checkNull(prod.Id);
                    contr.TeliaSE_RootItemId__c = rootMap.get(pciMap.get(prod.productCode))!=null?rootMap.get(pciMap.get(prod.productCode)).Id:null;
                    contr.TeliaSE_Root_Product__c = rootMap.get(pciMap.get(prod.productCode))!=null?rootMap.get(pciMap.get(prod.productCode)).vlocity_cmt__Product2Id__c:null;
                    contr.vlocity_cmt__ContractId__c = contractId;
                    contr.vlocity_cmt__Quantity__c = 1;
                    contr.TeliaSE_SubsidisedVoice__c = agrBnd;
                    contr.TeliaSE_Start_Date__c = contractStartDate;
                    contr.TeliaSE_End_Date__c = contractEndDate;
                    contr.MC_lineItem_Status__c=cliSubTypeMap.get(prod.Id)!=null && cliSubTypeMap.get(prod.Id).startsWith('KÖ-')?subsStatus.get('SF'):cliSubTypeMap.get(prod.Id)!=null &&cliSubTypeMap.get(prod.Id).endsWith('-KÖ')?subsStatus.get('KÄ'):subsStatus.get(cliSubTypeMap.get(prod.Id));
                    if(channelFlagsLst !=null){
                        contr.MC_Show_Subscription_In_Channel__c=String.valueOf(channelFlagsLst.get('channelFlag'));
                    }
                    else
                    {
                        contr.MC_Show_Subscription_In_Channel__c='Y';
                    }
                    contr.vlocity_cmt__OneTimeCharge__c = 0;
                    contr.vlocity_cmt__OneTimeTotal__c = 0;
                    contr.vlocity_cmt__RecurringTotal__c = 0;
                    contr.vlocity_cmt__RecurringCharge__c = 0;
                    insertCliList.add(contr);
                }
            }
            //To Store Unavailable products in AMANDA CLI    
            if(unAvailableSubs!= null && unAvailableSubs.size()>0){
                for(String sub:unAvailableSubs ){
                    if(!nonSubClis.containsKey(sub)){
                        vlocity_cmt__ContractLineItem__c unContr = new vlocity_cmt__ContractLineItem__c();
                        unContr.Name = sub;
                        unContr.vlocity_cmt__ContractId__c = contractId;
                        unAvailCLIList.add(unContr);
                    }
                }
            }
            Boolean insertSuccess = false;
            if(unAvailCLIList!= null && unAvailCLIList.size()>0){
                Database.insert(unAvailCLIList, false);
                insertSuccess = true;
            }
            if(insertCliList.size()>0){
                Database.insert(insertCliList, false);
                insertSuccess = true;
            }
            if(updateCliList.size()>0){
                Database.update(updateCliList, false);
                insertSuccess = true;
            }
            if(deleteCliList.size()>0){
                Database.delete(deleteCliList, false);
            }
            if(insertSuccess){
                updateCliPrice(agrCode, subscriptionTypeSet, contractId);
            }
        }
        catch(Exception e) {
            error_message = e.getMessage()+' line:'+ e.getLineNumber();
            system.debug(e.getStackTraceString()); 
            generateCustomError('TECH_ERROR_FROM_AMANDA', inputMap, outMap, false);
            overallOutMap.putAll(outMap);
            overallOutMap.put('exceptionError', String.valueOf(e.getMessage()+', Exception Trace:'+ e.getStackTraceString()));
            MCOnline_Utility.logErrorWithoutFuture(JSON.serialize(overallOutMap), 'ERR-501','MassCustomized_MadamIntegration','Apex Class', 'Exception',JSON.serialize(inputMap),agreementDetails,'');
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method used to update price on each cli.
* ************************************************************************************************************
* @param agrCode                                  Madam Agreement Number
* @param subscriptionTypeSet                     Containing subscription type coming from the input
* @param contractId                               Containing contract id
* ************************************************************************************************************
*/  
    public static void updateCliPrice(String agrCode, Set<String> subscriptionTypeSet, Id contractId)
    {
        Contract agr = [Select id, Status,StartDate, EndDate, Mconline_Status__c, MC_SetServiceContractFlag__c,ContractNumber, MC_Agreement_Category__c, Account.Org_Nr__c, Account.C2B_Org_nr__c, Account.TSCID__c,Contract_Record_Type__c  from Contract Where Id =: contractId LIMIT 1];
        if(agr.Contract_Record_Type__c =='Ramavtal')
        {
            updateIndexedPrice(agrCode,subscriptionTypeSet,contractId);
        }
        else
        {
            Set<String> agrPricePlanSet = new Set<String>();
            Map<String, String> agrPricePlanMap = new Map<String, String>();
            Boolean cliFlag = false, subFlag= false;
            String agreementCatagoryValue;
            Set<String> subscriptionSet = new Set<String>(); 
            handleAddons(agrCode, subscriptionTypeSet, contractId);
            String agreementCategory =  '%'+agr.MC_Agreement_Category__c+'%';
            agreementCatagoryValue = agr.MC_Agreement_Category__c;
            String agrString = String.valueOf(Label.MC_MFA_Agreement_Category);
            List<MC_Function_Agreement__c> functionAgreement = [Select id, MC_Agreement_Number__c, MC_Agreement_technical_OrgNo__c, MC_TSCID__c from MC_Function_Agreement__c Where MC_TSCID__c =:agr.Account.TSCID__c LIMIT 1];
            List<String> agreementCategoryList = agrString.split(',');
            for(vlocity_cmt__ProductChildItem__c prChild: [Select id, vlocity_cmt__ParentProductId__r.ProductCode, vlocity_cmt__ChildProductId__r.ProductCode, vlocity_cmt__ChildProductId__r.Family from vlocity_cmt__ProductChildItem__c Where vlocity_cmt__ParentProductId__r.ProductCode LIKE :agreementCategory AND vlocity_cmt__ChildProductId__r.Family = 'Online Order' AND vlocity_cmt__ChildProductId__r.TeliaSE_Subscription_Type__c != null AND vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c NOT IN ('mdsecondary','datasim')]){
                subscriptionSet.add(prChild.vlocity_cmt__ChildProductId__r.ProductCode);
            }
            List<vlocity_cmt__ContractLineItem__c> updateCliList = new List<vlocity_cmt__ContractLineItem__c>();
            for(MC_AgreementPlanChange__c agr1: [Select id, MC_AgreementNumber__c, MC_PricePlan__c, MC_DateFrom__c, MC_DateTo__c, MC_PricePlanCategory__c, MC_PricePlanType__c, MC_SubscriptionType__c from MC_AgreementPlanChange__c Where MC_AgreementNumber__c =:agrCode  AND MC_SubscriptionType__c IN: subscriptionTypeSet AND MC_PricePlanCategory__c =: String.valueOf(RAMMFAMap.get('PricePlanCategory').Type_Name__c)]){
                if(agr1.MC_PricePlan__c != null && agr1.MC_SubscriptionType__c != null){
                    if(String.isNotBlank(agr1.MC_DateFrom__c) && Date.valueOf(agr1.MC_DateFrom__c) <= Date.Today() && String.isBlank(agr1.MC_DateTo__c)){
                        agrPricePlanSet.add(agr1.MC_PricePlan__c);
                        agrPricePlanMap.put(agr1.MC_SubscriptionType__c, agr1.MC_PricePlan__c);
                        agrPricePlanMap.put('KÖ-'+agr1.MC_SubscriptionType__c, agr1.MC_PricePlan__c);
                        agrPricePlanMap.put(agr1.MC_SubscriptionType__c+'-KÖ', agr1.MC_PricePlan__c);
                    }
                    else if(String.isNotBlank(agr1.MC_DateTo__c) && (Date.valueOf(agr1.MC_DateTo__c) >= Date.Today()) && agrPricePlanMap != null && !agrPricePlanMap.containsKey(agr1.MC_SubscriptionType__c)){
                        agrPricePlanSet.add(agr1.MC_PricePlan__c);
                        agrPricePlanMap.put(agr1.MC_SubscriptionType__c, agr1.MC_PricePlan__c);
                        agrPricePlanMap.put('KÖ-'+agr1.MC_SubscriptionType__c, agr1.MC_PricePlan__c);
                        agrPricePlanMap.put(agr1.MC_SubscriptionType__c+'-KÖ', agr1.MC_PricePlan__c);
                    }
                }
            }
            if(agrPricePlanSet!= null && agrPricePlanSet.size()>0){
                Map<String, MC_PrismaPlan__c> prismaPrice = new Map<String, MC_PrismaPlan__c>();
                for(MC_PrismaPlan__c pr: [Select id, MC_Agreement_MRC_Price__c, MC_Agreement_NRC_Price__c, MC_Amendment_Number__c, MC_Description__c, MC_Final_Date__c, MC_Opening_Fee__c, MC_Price_Plan__c, MC_Price_Plan_Category__c, MC_ServiceCode__c, MC_ServiceValue__c, MC_Start_Date__c, MC_SubType__c, MC_Transfer_Fee__c   from MC_PrismaPlan__c Where MC_Price_Plan__c IN: agrPricePlanSet AND MC_Price_Plan_Category__c =: String.valueOf(RAMMFAMap.get('PricePlanCategory').Type_Name__c) AND MC_ServiceCode__c =: String.valueOf(RAMMFAMap.get('SubscriptionCode').Type_Name__c)]){
                    if(pr.MC_Price_Plan__c != null){
                        prismaPrice.put(pr.MC_Price_Plan__c, pr);
                    }
                }
                for(vlocity_cmt__ContractLineItem__c cli : [Select id, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c,  vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__RecurringCharge__c,MC_OriginalPrice__c,MC_PreviousPrice__c,TeliaSE_MC_Customer_Requested_Price__c  from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =: contractId]){
                    if(cli.vlocity_cmt__Product2Id__c !=null){ 
                        MC_PrismaPlan__c pri = null;
                        if(agrPricePlanMap != null && prismaPrice != null){
                            if(cli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c != null && !agrPricePlanMap.containsKey(cli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c) && subscriptionSet != null && subscriptionSet.contains(cli.vlocity_cmt__Product2Id__r.ProductCode)){
                                cliFlag = true; 
                            }else{
                                pri = prismaPrice.get(agrPricePlanMap.get(cli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c));
                            }
                            if(pri != null){
                                if(pri.MC_Agreement_MRC_Price__c != null && Integer.valueOf(pri.MC_Agreement_MRC_Price__c) != 0 && !subFlag){
                                    subFlag = true;
                                }
                                cli=indexMFAAgr(cli,cli.vlocity_cmt__RecurringCharge__c);
                                cli.vlocity_cmt__OneTimeCharge__c = (pri.MC_Agreement_NRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_NRC_Price__c)).setScale(2) : 0;
                                cli.vlocity_cmt__OneTimeTotal__c = (pri.MC_Agreement_NRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_NRC_Price__c)).setScale(2) : 0;
                                cli.vlocity_cmt__RecurringTotal__c = (pri.MC_Agreement_MRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_MRC_Price__c)/3).setScale(2) : 0;
                                cli.vlocity_cmt__RecurringCharge__c = (pri.MC_Agreement_MRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_MRC_Price__c)/3).setScale(2) : 0;
                                updateCliList.add(cli);
                            }
                        }else{
                            cliFlag = true;
                        }
                    }
                }
            }
            if(cliFlag || !subFlag){
                agr.Status = 'Negotiating';
            }else{
                if(updateCliList.size()>0){
                    Database.update(updateCliList, false);
                    if(Label.MC_AgreementActivationFlag != null && Label.MC_AgreementActivationFlag.equalsIgnoreCase('Yes')){
                        if(agr.Mconline_Status__c != 'Freezed' && agr.StartDate <= Date.Today() && agreementCategoryList != null && agreementCatagoryValue != null && !agreementCategoryList.contains(agreementCatagoryValue)){
                            if(functionAgreement.isEmpty() && !agr.MC_SetServiceContractFlag__c){
                                System.enqueueJob(new MC_MadamIntegrationQueueable(agr.ContractNumber, agrCode, agr.Id, agr.Account.Org_Nr__c));
                            }
                            agr.Status = 'Active';
                            agr.Mconline_Status__c = 'Valid';
                        }else if(agr.Mconline_Status__c != 'Freezed' && agr.StartDate <= Date.Today()){
                            agr.Status = 'Active';
                            agr.Mconline_Status__c = 'Valid';
                        }
                    }
                }
            }
            if(agr.Mconline_Status__c != 'Freezed'){
                Database.update(agr, false);
            }
            if(agr.Status == 'Active')
            {
                Approval.lock(contractId, false);
            }
        }
        
    }
    /*
* ************************************************************************************************************
* Overview:-
* This future method used to update service contract id towards MADAM.
* ************************************************************************************************************
* @param serviceContractNumber                    String containing service contract number.
* @param agreementNumber                          String containing madam agreement number.
* @param contractId                               Containing contract id
* ************************************************************************************************************
*/
    @Future(callout=true)
    public static void signalMadam(String serviceContractNumber, String agreementNumber, String contractId, String accountId){
        String endpointName, ProcedureName = 'MassCustomized_SetServiceContractId';
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        inputMap.put('agreementNumber', agreementNumber);
        inputMap.put('contractNumber', serviceContractNumber);
        inputMap.put('companyCode', accountId);
        inputMap.put('Id', contractId);
        inputMap.put('endpoint', 'TeliaSE_CustomerFrameAgreement_AT');
        Map<String, Object> result = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(ProcedureName, inputMap, optionsMap);
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method used to insert and update addons.
* ************************************************************************************************************
* @param agrCode                                  Madam Agreement Number
* @param subscriptionTypeSet                     Containing subscription type coming from the input
* @param contractId                               Containing contract id
* ************************************************************************************************************
*/ 
    public static void handleAddons(String agrCode, Set<String> subscriptionTypeSet, Id contractId)
    {
        Set<Id> addonList = new Set<Id>();
        Map<String, Product2> offerMap = new Map<String, Product2>();
        Map<String, MC_PrismaPlan__c> priceplanMap = new Map<String, MC_PrismaPlan__c>();
        Map<String, Product2> productMap = new Map<String, Product2>();
        Map<String, vlocity_cmt__ContractLineItem__c> cCliMap = new Map<String, vlocity_cmt__ContractLineItem__c>();
        Map<String, String> cliSubTypeMap= new Map<String, String>();
        Map<String, String> subPricePlanMap = new Map<String, String>();
        for(MC_AgreementPlanChange__c agr: [Select id, MC_AgreementNumber__c,MC_DateFrom__c, MC_DateTo__c, MC_PricePlan__c, MC_PricePlanCategory__c, MC_PricePlanType__c, MC_SubscriptionType__c from MC_AgreementPlanChange__c Where MC_AgreementNumber__c =:agrCode  AND MC_SubscriptionType__c IN: subscriptionTypeSet])
        {
            if(agr.MC_PricePlan__c != null && agr.MC_SubscriptionType__c != null)
            {
                if(String.isNotBlank(agr.MC_DateFrom__c) && Date.valueOf(agr.MC_DateFrom__c) <= Date.Today() && String.isBlank(agr.MC_DateTo__c))
                {
                    subPricePlanMap.put(agr.MC_SubscriptionType__c+'-'+agr.MC_PricePlan__c, agr.MC_PricePlan__c);
                }
                else if(String.isNotBlank(agr.MC_DateTo__c) && Date.valueOf(agr.MC_DateTo__c) >= Date.Today())
                {
                    if(subPricePlanMap != null && !subPricePlanMap.containsKey(agr.MC_SubscriptionType__c))
                    {
                        subPricePlanMap.put(agr.MC_SubscriptionType__c+'-'+agr.MC_PricePlan__c, agr.MC_PricePlan__c);
                    }
                }
            }
        }
        for(MC_PrismaPlan__c pr: [Select id, MC_Agreement_MRC_Price__c, MC_Agreement_NRC_Price__c, MC_Amendment_Number__c, MC_Description__c, MC_Final_Date__c, MC_Opening_Fee__c, MC_Price_Plan__c, MC_Price_Plan_Category__c, MC_ServiceCode__c, MC_ServiceValue__c, MC_Start_Date__c, MC_SubType__c, MC_Transfer_Fee__c  from MC_PrismaPlan__c Where MC_Price_Plan__c IN: subPricePlanMap.values() Order By CreatedDate ASC])
        {
            if(pr.MC_ServiceCode__c != null && pr.MC_ServiceValue__c != null){
                priceplanMap.put(pr.MC_ServiceCode__c+'-'+pr.MC_ServiceValue__c, pr);
            }else{
                priceplanMap.put(pr.MC_ServiceCode__c, pr);
            }
        }
        for(Product2 prod: [Select Id, ProductCode, Name, TeliaSE_Subscription_Type__c, TeliaSE_Product_Service_Code__c from Product2 Where ProductCode LIKE '%AGR%' AND Family = 'Online Order' AND TeliaSE_Product_Service_Code__c IN: priceplanMap.Keyset() AND IsActive= true AND vlocity_cmt__Status__c= 'Active']){
            addonList.add(prod.Id);
            productMap.put(prod.ProductCode, prod);
        }
        //insertSwitchOffer
        Map<String, String> offerChildMap = new Map<String, String>();
        getSwitchOffer(addonList, offerMap, offerChildMap);
        String agrBnd;
        Contract contractRecord ;
        List<Contract> contractInfo = [Select id,StartDate, EndDate, MC_Agreement_Category__c,(Select id,TeliaSE_SubsidisedVoice__c,MC_Show_Subscription_In_Channel__c, TeliaSE_Start_Date__c, TeliaSE_End_Date__c, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c,vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c,vlocity_cmt__Product2Id__r.Family, vlocity_cmt__Product2Id__r.C2BC_Category__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__RecurringCharge__c from vlocity_cmt__ContractLineItems__r ) from  Contract Where Id =: contractId LIMIT 1];
        if(contractInfo.size()>0){
            contractRecord = contractInfo[0];
        }
        for(vlocity_cmt__ContractLineItem__c cCli :contractRecord.vlocity_cmt__ContractLineItems__r)
        {
            if(cCli != null && cCli.vlocity_cmt__Product2Id__c != null)
            {
                agrBnd = cCli.TeliaSE_SubsidisedVoice__c != null ? cCli.TeliaSE_SubsidisedVoice__c:'';
                cCliMap.put(cCli.vlocity_cmt__Product2Id__c, cCli);
                cliSubTypeMap.put(cCli.vlocity_cmt__Product2Id__c, cCli.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c);
            }
        }
        List<vlocity_cmt__ContractLineItem__c> updateCliList = new List<vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> insertCliOfferList = new List<vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> insertCliList = new List<vlocity_cmt__ContractLineItem__c>();
        insertOffer(insertCliOfferList, updateCliList, offerMap, agrBnd, cCliMap, contractId,new Set<String>());
        if(insertCliOfferList.size()>0){
            Database.insert(insertCliOfferList, false);
        }
        Map<String, String> offerCliMap = new Map<String, String>();
        for(vlocity_cmt__ContractLineItem__c cliList: insertCliOfferList){
            if(cliList.vlocity_cmt__Product2Id__c != null){
                offerCliMap.put(cliList.vlocity_cmt__Product2Id__c, cliList.Id);
            }
        }
        for(String key: productMap.keySet())
        {
            Product2 prod = productMap.get(key);
            MC_PrismaPlan__c pri = priceplanMap.get(prod.TeliaSE_Product_Service_Code__c);
            //for the product with service code 'CALLSPEC' allowed 'F80014' priceplan
            if(pri.MC_Price_Plan__c == 'F80014' && prod.TeliaSE_Product_Service_Code__c != null && prod.TeliaSE_Product_Service_Code__c.contains('CALLSPEC')){
                pri.MC_Agreement_MRC_Price__c = (pri.MC_Agreement_MRC_Price__c != null) ? String.valueOf(Decimal.valueOf(pri.MC_Agreement_MRC_Price__c)*3) : pri.MC_Agreement_MRC_Price__c;
            }
            //To update existing line items
            if(cCliMap != null && cCliMap.containsKey(prod.Id)){
                vlocity_cmt__ContractLineItem__c contr = cCliMap.get(prod.Id);
                contr.TeliaSE_Start_Date__c = contractInfo[0].StartDate;
                contr.TeliaSE_End_Date__c = contractInfo[0].EndDate;
                contr=indexMFAAgr(contr,contr.vlocity_cmt__RecurringCharge__c);
                contr.vlocity_cmt__OneTimeCharge__c = (pri.MC_Agreement_NRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_NRC_Price__c)).setScale(2) : 0;
                contr.vlocity_cmt__OneTimeTotal__c = (pri.MC_Agreement_NRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_NRC_Price__c)).setScale(2) : 0;
                contr.vlocity_cmt__RecurringTotal__c = (pri.MC_Agreement_MRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_MRC_Price__c)/3).setScale(2) : 0;
                contr.vlocity_cmt__RecurringCharge__c = (pri.MC_Agreement_MRC_Price__c!= null) ? (Decimal.valueOf(pri.MC_Agreement_MRC_Price__c)/3).setScale(2) : 0;
                updateCliList.add(contr);
            }else{
                //This else block handles the new CLI creation
                vlocity_cmt__ContractLineItem__c contr = new vlocity_cmt__ContractLineItem__c();
                contr.Name = checkNull(prod.Name);
                contr.vlocity_cmt__Product2Id__c = checkNull(prod.Id);
                contr.TeliaSE_RootItemId__c = (offerChildMap.get(prod.Id) != null)? offerChildMap.get(prod.Id) : null;
                contr.TeliaSE_Root_Product__c = (offerChildMap.get(prod.Id) != null && offerCliMap != null && offerCliMap.get(offerChildMap.get(prod.Id)) != null) ? offerCliMap.get(offerChildMap.get(prod.Id)) : null;
                contr.vlocity_cmt__ContractId__c = contractId;
                contr.vlocity_cmt__Quantity__c = 1;
                contr.TeliaSE_Start_Date__c = contractInfo[0].StartDate;
                contr.TeliaSE_End_Date__c = contractInfo[0].EndDate;
                contr=indexMFAAgr(contr,contr.vlocity_cmt__RecurringCharge__c);
                contr.vlocity_cmt__OneTimeCharge__c = (pri.MC_Agreement_NRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_NRC_Price__c)).setScale(2) : 0;
                contr.vlocity_cmt__OneTimeTotal__c = (pri.MC_Agreement_NRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_NRC_Price__c)).setScale(2) : 0;
                contr.vlocity_cmt__RecurringTotal__c = (pri.MC_Agreement_MRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_MRC_Price__c)/3).setScale(2) : 0;
                contr.vlocity_cmt__RecurringCharge__c = (pri.MC_Agreement_MRC_Price__c!= null) ? (Decimal.valueOf(pri.MC_Agreement_MRC_Price__c)/3).setScale(2) : 0;
                insertCliList.add(contr);
            }
        }
        if(insertCliList.size()>0){
            Database.insert(insertCliList, false);
        }
        if(updateCliList.size()>0){
            Database.update(updateCliList, false);
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method used to insert virtual Offers.
* ************************************************************************************************************
* @param insertCliOfferList                       List of offers to be inserted
* @param updateCliList                            List of offers to be updated
* @param offerMap                                 Map containing the products details
* @param agrBnd                                   Store the subsidised voice value
* @param cCliMap                                  containing the existing line items
* @param contractId                               Current contract id
* ************************************************************************************************************
*/  
    public static void insertOffer(List<vlocity_cmt__ContractLineItem__c> insertCliOfferList, List<vlocity_cmt__ContractLineItem__c> updateCliList, Map<String, Product2> offerMap, String agrBnd, Map<String, vlocity_cmt__ContractLineItem__c> cCliMap, Id contractId,Set<String> defaultOffers)
    {
        List<String> offerlist=RAMMFAMap.get('DefaultOffers').Type_Name__c.split(',');
        for(String key : offerMap.keySet())
        {
            Product2 prod = offerMap.get(key);
            if(cCliMap != null && cCliMap.containsKey(prod.Id)){
                
                vlocity_cmt__ContractLineItem__c contr = cCliMap.get(prod.Id);
                contr.TeliaSE_SubsidisedVoice__c = agrBnd;
                contr.TeliaSE_Start_Date__c = contractStartDate;
                contr.TeliaSE_End_Date__c = contractEndDate;
                OfferCli = contr.Id;
                offerProdId = contr.vlocity_cmt__Product2Id__c;
                updateCliList.add(contr);
            }
            else if(defaultOffers.contains(prod.ProductCode) || !offerlist.contains(prod.ProductCode)) {
                vlocity_cmt__ContractLineItem__c contr = new vlocity_cmt__ContractLineItem__c();
                contr.Name = checkNull(prod.Name);
                contr.vlocity_cmt__Product2Id__c = checkNull(prod.Id);
                contr.vlocity_cmt__ContractId__c = contractId;
                contr.vlocity_cmt__Quantity__c = 1;
                contr.TeliaSE_SubsidisedVoice__c = agrBnd;
                contr.TeliaSE_Start_Date__c = contractStartDate;
                contr.TeliaSE_End_Date__c = contractEndDate;
                contr.vlocity_cmt__OneTimeCharge__c = 0;
                contr.vlocity_cmt__OneTimeTotal__c = 0;
                contr.vlocity_cmt__RecurringTotal__c = 0;
                contr.vlocity_cmt__RecurringCharge__c = 0;
                insertCliOfferList.add(contr);
            }
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method used to fetch the switch offers.
* ************************************************************************************************************
* @param addonList                                List of addons present
* @param offerMap                                 Map containing the products details
* @param contractId                               Containing contract id
* ************************************************************************************************************
*/
    public static void getSwitchOffer(Set<Id> addonList, Map<String, Product2> offerMap, Map<String, String> offerChildMap)
    {
        for(vlocity_cmt__ProductChildItem__c pr:[Select Id, vlocity_cmt__ParentProductId__c, vlocity_cmt__ChildProductId__c from vlocity_cmt__ProductChildItem__c Where vlocity_cmt__ChildProductId__c IN: addonList AND vlocity_cmt__ParentProductId__r.C2BC_Category__c = 'offerbundle' AND vlocity_cmt__ChildProductId__r.C2BC_Category__c NOT IN ('mobilevoicesubscription','mobilebroadbandsubscription') AND vlocity_cmt__ParentProductId__r.Family = 'Mobility Management']){
            offerChildMap.put(pr.vlocity_cmt__ChildProductId__c, pr.vlocity_cmt__ParentProductId__c);
        }
        for(Product2 pr: [Select Id, ProductCode, Name, TeliaSE_Subscription_Type__c, Family from Product2 Where Id IN:offerChildMap.values() AND Family = 'Mobility Management' AND C2BC_Category__c = 'offerbundle' AND IsActive= true AND vlocity_cmt__Status__c= 'Active']){
            offerMap.put(pr.ProductCode, pr);   
        }
    }  
    /*
* ************************************************************************************************************
* Overview:-
* This method used to Store the unavailable CLIs for Future reference
* ************************************************************************************************************
* @param agreementItems                           List of agreementItems from Input
* @param unAvailableSubs                          List of SubTypes unavailable in AMANDA
* ************************************************************************************************************
*/
    public static List<String> storeSubTypes(List<Object> agreementItems,String agreementCategory,Boolean isAvailable){
        List<String> subTypes=new List<String>();
        List<String> availableSubTypes=new List<String>();
        List<String> unAvailableSubs=new List<String>();
        List<String> aviSub=new List<String>();
        for(Object agr: agreementItems)
        {
            Map<String, Object> agrMap = (Map<String, Object>)agr;
            subTypes.add(String.valueOf(agrMap.get('subscriptionType')));
        }
        List<Product2> pr=[select TeliaSE_Subscription_Type__c from product2 where TeliaSE_Subscription_Type__c !=null and family='Online Order' and ProductCode like'%AGR_%' AND IsActive= true AND vlocity_cmt__Status__c= 'Active' WITH SECURITY_ENFORCED];
        for(Product2 pro:pr)
        {
            aviSub.add(pro.TeliaSE_Subscription_Type__c);
        }  
        for(String p:subTypes) 
        { 
            if(!aviSub.contains(p))
            {
                unAvailableSubs.add(p);  
            }
            else 
            {
                availableSubTypes.add(p);
            }
        } 
        if(isAvailable)
            return availableSubTypes;
        else
            return unAvailableSubs;
    }
    
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for log the error scenarios in a tracking object.
* ************************************************************************************************************
* @param errorLogMap                              Map containing the overall error Map.
* ************************************************************************************************************
*/
    public static void errorLog(Map<String, Object> errorLogMap)
    {
        MCOnline_Utility.logError(String.valueOf(errorLogMap.get('errorMessage')), String.valueOf(errorLogMap.get('errorCode')),String.valueOf(errorLogMap.get('source')),String.valueOf(errorLogMap.get('sourceType')), String.valueOf(errorLogMap.get('errorType')),String.valueOf(errorLogMap.get('inputData')),String.valueOf(errorLogMap.get('contextId')),String.valueOf(errorLogMap.get('objectName')),String.valueOf(errorLogMap.get('url')));
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for string blank check.
* ************************************************************************************************************
* @param obj                                 Obj containing the string values
* ************************************************************************************************************
*/      
    public static String checkNull(object obj)
    {
        if(String.isBlank(String.valueOf(obj)))
        {
            return '';
        }
        else
        {
            return String.valueOf(obj);
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for log the error scenarios in a tracking object.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param options                                  Map containing the query parameter
* ************************************************************************************************************
*/  
    public static void logError(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        MCOnline_Utility.logError(JSON.serialize(inputMap.get('ErrorResponse')), 'ERR-501','MassCustomized_MadamIntegration','Integration Procedure', String.valueOf(inputMap.get('ErrorType')),JSON.serialize(inputMap.get('InputRequest')),String.valueOf(inputMap.get('ContextId')),'','');
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for log the error scenarios in a tracking object without future method.
* ************************************************************************************************************
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param options                                  Map containing the query parameter
* ************************************************************************************************************
*/ 
    public static void logErrorWithoutFuture(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        MCOnline_Utility.logErrorWithoutFuture(JSON.serialize(inputMap.get('ErrorResponse')), 'ERR-501','MassCustomized_MadamIntegration','Integration Procedure', String.valueOf(inputMap.get('ErrorType')),JSON.serialize(inputMap.get('InputRequest')),String.valueOf(inputMap.get('ContextId')),'');
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for generating the custom error scenarios from custom metadata.
* ************************************************************************************************************
* @param errorName                                Custom Error Name to get value from metadata
* @param inputMap                                 Map containing the input coming from the user
* @param outMap                                   Map that contains the output response
* @param success                                  success flag
* ************************************************************************************************************
*/     
    public static void generateCustomError(String errorName, Map<String, Object> inputMap, Map<String, Object> outMap, Boolean success)
    {
        List<MC_MadamIntegrationErrorHandling__mdt> customError = [Select id,DeveloperName, Error_Code__c, Error_Message__c from MC_MadamIntegrationErrorHandling__mdt Where DeveloperName =: errorName LIMIT 1];
        if(customError != null && customError.size()>0)
        {
            outMap.put('errorCode', String.valueOf(customError[0].Error_Code__c));
            outMap.put('errorMessage', String.valueOf(customError[0].Error_Message__c));
            outMap.put('success', success);
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is used for consolidating the error response in single map.
* This method will simplify the errorLog and insert it in error log entry tracking object
* ************************************************************************************************************
* @param errorLogMap                              Map containing the error response
* @param errorMessage                             String containing custom error message
* @param errorCode                                error code
* @param source                                   Class Name or Source Name
* @param sourceType                               Apex Class or Source Type
* @param errorType                                Error Type
* @param inputData                                Contains the input Data
* @param contextId                                Context Id
* @param objectName                               Containing object Name
* @param url                                      Full request endpoints
* ************************************************************************************************************
*/  
    public static void getErrorLog(Map<String,Object> errorLogMap, String errorMessage, String errorCode, String source, String sourceType, String errorType,String inputData,String contextId,String objectName, String url)
    {
        errorLogMap.put('errorMessage', errorMessage);
        errorLogMap.put('errorCode', errorCode);
        errorLogMap.put('source', source);
        errorLogMap.put('sourceType', sourceType);
        errorLogMap.put('errorType', errorType);
        errorLogMap.put('inputData', inputData);
        errorLogMap.put('contextId', contextId);
        errorLogMap.put('objectName', objectName);
        errorLogMap.put('url', url);
    }
    
    /*
* ************************************************************************************************************
* Overview:-
* This method used to update price on Ramavtal Agreemnet.
* ************************************************************************************************************
* @param agrCode                                  Madam Agreement Number
* @param subscriptionTypeSet                      Containing subscription type coming from the input
* @param contractId                               Containing contract id
* ************************************************************************************************************
*/
    public static void updateIndexedPrice(String agrCode, Set<String> subscriptionTypeSet, Id contractId)
    {
        Map<String, MC_PrismaPlan__c> priceplanMap = new Map<String, MC_PrismaPlan__c>();
        Map<String, String> agrPricePlanMap = new Map<String, String>();
        Map<String, String> cliSubTypeMap= new Map<String, String>();
        List<vlocity_cmt__ContractLineItem__c> updateCliList = new List<vlocity_cmt__ContractLineItem__c>();
        for(MC_AgreementPlanChange__c agr: [Select id, MC_AgreementNumber__c, MC_PricePlan__c, MC_SubscriptionType__c from MC_AgreementPlanChange__c Where MC_AgreementNumber__c =:agrCode and LastModifiedDate =today and MC_PricePlanCategory__c='F1GRUNDAVG'and MC_Action__c='I' and MC_SubscriptionType__c IN: subscriptionTypeSet ])
        {
            if(agr.MC_PricePlan__c != null && agr.MC_SubscriptionType__c !=null)
            {
                agrPricePlanMap.put(agr.MC_SubscriptionType__c,agr.MC_PricePlan__c);
            }
        }
        for(MC_PrismaPlan__c pr: [Select id, MC_Agreement_MRC_Price__c, MC_Price_Plan__c from MC_PrismaPlan__c Where MC_Price_Plan__c IN: agrPricePlanMap.values() and MC_Price_Plan_Category__c='F1GRUNDAVG' Order By CreatedDate ASC])
        {
            if(pr.MC_Price_Plan__c != null){
                priceplanMap.put(pr.MC_Price_Plan__c, pr);
            }
        }
        List<QuoteLineItem> qlis=new List<QuoteLineItem>();
        for(vlocity_cmt__ContractLineItem__c cli : [Select id, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c, vlocity_cmt__RecurringCharge__c,TeliaSE_MC_Customer_Requested_Price__c,MC_OriginalPrice__c,vlocity_cmt__QuoteLineItem__c from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =: contractId and (TeliaSE_ParentItemId__c =null Or vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c IN :subscriptionTypeSet) and TeliaSE_Product_Service_Code__c=null]){
            MC_PrismaPlan__c pri = null;
            if(priceplanMap.size()>0){
                if(agrPricePlanMap.containsKey(cli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c)){
                    pri = priceplanMap.get(agrPricePlanMap.get(cli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c));
                }
                if(pri != null){
                    if(cli.MC_OriginalPrice__c==null){
                        cli.MC_OriginalPrice__c=getUpdatedPrice(cli.TeliaSE_MC_Customer_Requested_Price__c,cli.vlocity_cmt__RecurringCharge__c);
                    }
                    cli.MC_PreviousPrice__c=getUpdatedPrice(cli.TeliaSE_MC_Customer_Requested_Price__c,cli.vlocity_cmt__RecurringCharge__c);
                    cli.MC_IndexedDate__c=System.Today();
                    cli.MC_PriceUpdateType__c='Manual price update';
                    cli.TeliaSE_MC_Customer_Requested_Price__c= (pri.MC_Agreement_MRC_Price__c != null) ? (Decimal.valueOf(pri.MC_Agreement_MRC_Price__c)/3).setScale(2) : 0;
                    if(String.ValueOf(cli.TeliaSE_MC_Customer_Requested_Price__c) != String.ValueOf(cli.MC_PreviousPrice__c)){
                    updateCliList.add(cli);
                    if(cli.vlocity_cmt__QuoteLineItem__c != null){
                        QuoteLineItem qli =new QuoteLineItem(Id=cli.vlocity_cmt__QuoteLineItem__c,TeliaSE_MC_Customer_Requested_Price__c=cli.TeliaSE_MC_Customer_Requested_Price__c);
                        qlis.add(qli);
                    }
                    }
                }
                if(qlis.size()>0){
                    database.update(qlis,false);
                }
            }
        }
        if(updateCliList.size()>0){
            database.update(updateCliList,false);
        }
    }
    public static string getUpdatedPrice(Decimal reqPrice, Decimal recPrice){ 
        return (reqPrice != null) ? String.valueOf(reqPrice) : String.valueOf(recPrice);
    }
    public static vlocity_cmt__ContractLineItem__c indexMFAAgr(vlocity_cmt__ContractLineItem__c  cli,Decimal reqPrice){ 
        if(cli.MC_PreviousPrice__c !=null && cli.vlocity_cmt__RecurringCharge__c !=null){
              cli.MC_PreviousPrice__c=String.valueOf(reqPrice);
                                }
        cli.MC_IndexedDate__c=System.Today();
        cli.MC_PriceUpdateType__c='Manual price update';
        if(cli.MC_OriginalPrice__c==null){
          cli.MC_OriginalPrice__c=String.ValueOf(reqPrice);
          cli.MC_PreviousPrice__c=cli.MC_OriginalPrice__c;
                                } 
        return cli ;                                            
    }
}