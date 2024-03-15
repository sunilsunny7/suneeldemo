//One time batch activity to map account and contract on Utilizer_Contract_Relationship__c Custom Object
public class TeliaSE_CreateUtilizerBatchContract implements Database.Batchable<sObject>, Database.Stateful { 
    
    //Constant Variables
    public final string ACTIVE = 'Aktiv';
    public final string UTILIZER = 'Utilizer';
    public final string VALID = 'Valid';
    public final string NYTT = 'Nyttjarrelationer';
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Query to fetch all account where TeliaSE_Utilzer_Role__c = 'Utilizer' 
        //and contract Status != 'Cancelled' 
        //and contract RecordType.Name = 'Ramavtal'
        
        return Database.getQueryLocator(
                        [SELECT Id, TeliaSE_Utilzer_Role__c, FA_Contract__c, FA_Contract__r.Org_Nr__c, Name FROM Account 
                        WHERE TeliaSE_Utilzer_Role__c = 'Utilizer' 
                        AND FA_Contract__r.Status != 'Cancelled' 
                        AND FA_Contract__r.RecordType.Name = 'Ramavtal']);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> accountList){
       try{
       //utilContractRelationList stores list of Utilizer_Contract_Relationship__c, which needs to be inserted as one time activity
        List<Utilizer_Contract_Relationship__c> utilContractRelationList = new List<Utilizer_Contract_Relationship__c>();
        if(accountList != null && accountList.size() > 0){
            for(Account acc: accountList) {
                
                //Instance of Utilizer_Contract_Relationship__c with name utilContractRelationObj
                Utilizer_Contract_Relationship__c utilContractRelationObj = new Utilizer_Contract_Relationship__c();
                utilContractRelationObj.AccountId__c =acc.Id;
                utilContractRelationObj.ContractNumber__c = acc.FA_Contract__r.Id;
                utilContractRelationObj.Org_Number__c = acc.FA_Contract__r.Org_Nr__c;
                
                //Status is contant as ACTIVE everytime
                utilContractRelationObj.Status__c = ACTIVE;
                
                //Utilizer_Role__c is contant as UTILIZER everytime
                utilContractRelationObj.Utilizer_Role__c = UTILIZER;
                
                //Utilizer_Type__c is contant as VALID everytime
                utilContractRelationObj.Utilizer_Type__c = VALID;
                
                //Name is contant as 'Nyttjarrelationer' everytime
                utilContractRelationObj.Name = NYTT;
                
                //Adding Utilizer_Contract_Relationship__c one by one
                utilContractRelationList.add(utilContractRelationObj);
            }
        }
        
        //Null Check for utilContractRelationList
         if(utilContractRelationList != null && utilContractRelationList.size() > 0)
         {
             //Insert if Utilizer_Contract_Relationship__c si available on utilContractRelationList
             insert utilContractRelationList;
         }
       }catch(Exception e){
           system.debug('Exception on TeliaSE_CreateUtilizerBatchContract: '+e.getStackTraceString());
       }
    }
    
    public void finish(Database.BatchableContext bc){
       
    }  
}