global without sharing class ContractUIVFController {
    public Boolean showError { get; set; }
    public CustomUISettings__c customSettings { get; set; }
    public String errorMessage { get; set; }
    public Integer size { get; set; }
    public final Account acc { get; set; }
    public List<Contract> contracts { get; set; }
    
    public ContractUIVFController(ApexPages.StandardController controller){
        acc = (Account)controller.getRecord();
        contracts = getContracts(acc);
        size = contracts.size();
        
        //Set visibility of the option Buttons
        customSettings = CustomUISettings__c.getInstance(UserInfo.getProfileId());
    }    
    
    public class ActionStatus{
        public String ReturnData {get; set;}
        public Boolean IsSuccess {get; set;}
    }
    
    public void refresh(){
        contracts = getContracts(acc);
    }
    
    public void setError(){
        showError = true;
        errorMessage = Apexpages.currentPage().getParameters().get('pErrorMessage'); 
    }
    
    public static List<Contract> getContracts (Account acc){
        List<Contract> contracts = [SELECT Id, EndDate,ContractNumber,Agreement_Nr__c,Cygate_Agreement_Nr__c, StartDate, ContractTerm,Solution_Area__c, Type_of_Agreement__c, RecordType.Name FROM Contract WHERE AccountId = :acc.Id];                               
        return contracts;
    }
    
    public static void deleteContract (String contractId){
        Contract contract = [SELECT Id FROM Contract WHERE Id = :contractId]; 
        delete contract;
    }
    
    /* A.D: Updated the Page logic via sforce methods
    @RemoteAction 
    global static String createProspect (String contractId, String pricebookId){
        CustomUISettings__c cs = CustomUISettings__c.getInstance(UserInfo.getProfileId());
        Contract contract = [SELECT Id, AccountId, EndDate, ContractNumber, KKnr__c, Type_of_Agreement__c, Solution_Area__c FROM Contract WHERE Id = :contractId]; 
        
        Opportunity opp = new Opportunity();
        opp.AccountId = contract.AccountId;
        opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
        opp.ContractId = contract.Id;
        opp.Agreement_Start__c = contract.EndDate;
        opp.Name = contract.ContractNumber;
        opp.Pricebook2ID = pricebookId;
        opp.KKnr__c = contract.KKnr__c;
        opp.Main_Product_Area__c = contract.Solution_Area__c;
        opp.CloseDate = Date.valueOf(contract.EndDate).addDays(1);
        opp.Is_Contract_Prospect_Opportunity__c = true;
        
        if(opp.CloseDate < Date.today().addMonths(3)){
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_ACTIVE_PROSPECT;
        }else{
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_RESTING_PROSPECT;
        }       
        
        ActionStatus actionStatus = new ActionStatus();
        try{
            insert opp;
            actionStatus.IsSuccess = true;
            actionStatus.ReturnData = opp.Id;
        }catch(exception ex){
            actionStatus.IsSuccess = false;
            actionStatus.ReturnData = ex.getMessage();
        }
        return JSON.serialize(actionStatus);
        
    }
    */
    @RemoteAction 
    global static String createContract (String AccId){
        
        Contract conObj = new Contract();
        conObj.StartDate = system.today();
        conObj.status = 'Draft';
        conObj.accountId = AccId;
        
        ActionStatus actionStatus = new ActionStatus();
        try{
            insert conObj;
            actionStatus.IsSuccess = true;
            actionStatus.ReturnData = conObj.Id;
        }catch(exception ex){
            actionStatus.IsSuccess = false;
            actionStatus.ReturnData = ex.getMessage();
        }
        return JSON.serializePretty(actionStatus);
    }  
    
    
    /* A.D: Updated the Page logic via sforce methods
    @RemoteAction 
    global static String createCygateOpportunity (String contractId, String pricebookId){
        system.debug('$$$$$'+contractId+'$$$$'+pricebookId);
        
        CustomUISettings__c cs = CustomUISettings__c.getInstance(UserInfo.getProfileId());
        Contract contract = [SELECT Id, AccountId, EndDate, ContractNumber, KKnr__c, Type_of_Agreement__c, Solution_Area__c FROM Contract WHERE Id = :contractId]; 
        
        Opportunity opp = new Opportunity();
        opp.AccountId = contract.AccountId;
        opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFFAR);
        opp.ContractId = contract.Id;
        opp.Agreement_Start__c = contract.EndDate;
        opp.Name = contract.ContractNumber;
        opp.Pricebook2ID = pricebookId;
        opp.KKnr__c = contract.KKnr__c;
        opp.Main_Product_Area__c = contract.Solution_Area__c;
        opp.CloseDate = Date.valueOf(contract.EndDate).addDays(1);
        opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
        opp.Is_Contract_Prospect_Opportunity__c  = True;
        ActionStatus actionStatus = new ActionStatus();
        try{
            insert opp;
            actionStatus.IsSuccess = true;
            actionStatus.ReturnData = opp.Id;
        }catch(exception ex){
            system.debug('!!!'+ex.getMessage());
            actionStatus.IsSuccess = false;
            actionStatus.ReturnData = ex.getMessage();
        }
        system.debug('%%%'+JSON.serializePretty(actionStatus));
        return JSON.serializePretty(actionStatus);
    }  
    */
    @RemoteAction 
    global static String createSmeOpportunity (String contractId){
        Contract contract = [SELECT Id, AccountId, EndDate, ContractNumber, Type_of_Agreement__c, Solution_Area__c FROM Contract WHERE Id = :contractId]; 
        
        Opportunity opp = new Opportunity();
        opp.AccountId = contract.AccountId;
        opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
        opp.ContractId = contract.Id;
        opp.Agreement_Start__c = contract.EndDate;
        opp.Name = contract.Solution_Area__c + ' ' + contract.ContractNumber;
        //opp.KKnr__c = contract.KKnr__c;
        opp.Main_Product_Area__c = contract.Solution_Area__c;
        opp.CloseDate = Date.valueOf(contract.EndDate).addDays(1);
        opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
        opp.Is_Contract_Prospect_Opportunity__c = true;
        
        ActionStatus actionStatus = new ActionStatus();
        try{
            insert opp;
            actionStatus.IsSuccess = true;
            actionStatus.ReturnData = opp.Id;
        }catch(exception ex){
            actionStatus.IsSuccess = false;
            actionStatus.ReturnData = ex.getMessage();
        }
        
        return JSON.serializePretty(actionStatus);
    }
    
    @RemoteAction 
    global static String createSmeQuickOpportunity (String contractId){
        Contract contract = [SELECT Id, AccountId, EndDate, ContractNumber, Type_of_Agreement__c, Solution_Area__c FROM Contract WHERE Id = :contractId]; 
        
        Opportunity opp = new Opportunity();
        opp.AccountId = contract.AccountId;
        opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_QUICK);
        opp.ContractId = contract.Id;
        opp.Agreement_Start__c = contract.EndDate;
        opp.Name = contract.Solution_Area__c + ' ' + contract.ContractNumber;
        //opp.KKnr__c = contract.KKnr__c;
        opp.Main_Product_Area__c = contract.Solution_Area__c;
        opp.CloseDate = Date.valueOf(contract.EndDate).addDays(1);
        opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
        opp.Is_Contract_Prospect_Opportunity__c = true;
        
        ActionStatus actionStatus = new ActionStatus();
        try{
            insert opp;
            actionStatus.IsSuccess = true;
            actionStatus.ReturnData = opp.Id;
        }catch(exception ex){
            actionStatus.IsSuccess = false;
            actionStatus.ReturnData = ex.getMessage();
        }
        
        return JSON.serializePretty(actionStatus);
    }
}