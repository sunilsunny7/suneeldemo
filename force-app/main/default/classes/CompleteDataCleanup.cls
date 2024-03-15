public class CompleteDataCleanup {
    public static void executeAll(){
        RemoveContract();
        RemoveQuote();       
        RemovePrecheckUtilizerContact();
        RemoveOppnAcc();        
    }
    
    public static void RemoveQuote(){
        List <QuoteLineItem> qli = [select id from QuoteLineItem];
        if(qli.size()>0) {
            delete qli;
        }
        List <Quote> allQuote = [SELECT Id FROM Quote];
        for(Quote quote : allQuote) {
            quote.status = 'Draft';
        }
        if(allQuote.size()>0) {
            update allQuote;
            delete allQuote;
        }
        
    }
    public static void RemoveContract(){
        try{
        List< vlocity_cmt__ContractLineItem__c> cli = [select Id from vlocity_cmt__ContractLineItem__c];
        if(cli.size()>0) {
            //System.debug('Inside cli');
            delete cli; 
        } 
        
       List<Contract> allContract = [SELECT Id,status FROM Contract];
        for(Contract contract : allContract){
           if(contract.status != 'Cancelled'){
            Contract.Reason_for_Cancellation__c = 'Data Removal';
            Contract.TeliaSE_Reason_for_Cancellation__c = 'Data Removal'; 
            contract.status = 'Cancelled';
            }
        }
        if(allContract.size()>0) {
            update allContract;
            delete allContract;
        }       
    }
        catch(Exception e){
            System.debug('Error'+ e.getLineNumber());
        }
    }
    public static void RemovePrecheckUtilizerContact(){
        List<MC_PreCheck_Result__c> precheck = [SELECT Id FROM MC_PreCheck_Result__c];
        if(precheck.size()>0) {
            delete precheck;
        }
        List<Utilizer_Contract_Relationship__c> utilizer = [SELECT Id FROM Utilizer_Contract_Relationship__c];
        if(utilizer.size()>0){
            delete utilizer;
        }
        List<Contact> contact = [select id from Contact where LastName NOT IN ('Customer_Unique_Terms','CG_FREE_SERVICE_PT_ 3TRAIN_SEAT','CG_FREE_SERVICE_PT_SUPPORT_1ASSIGN','CG_FREE_SERVICE_MS365_TRAIN_1SEAT')];
        if(contact.size()>0){
            delete contact;
        }
    }
    public static void RemoveOppnAcc(){
        List<OpportunityLineItem> oli = [select id from OpportunityLineItem];
        if(oli.size()>0){
            delete oli;
        }
        List<Opportunity> opp = [Select id from Opportunity];
        if(opp.size()>0){
            delete opp;
        }
        List<Account> acc = [Select id FROM Account where Id != '0015r00000ZGwD9'];
        if(acc.size()>0){
            delete acc;
        }
    } 
}