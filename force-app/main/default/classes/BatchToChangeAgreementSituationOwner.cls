global class BatchToChangeAgreementSituationOwner implements Database.Batchable<sObject>{
    String query;
    Date todaysdate = system.today();
    String securitycategoryklass1 = 'Klass 1';
    String Securitycategoryklass2 = 'Klass 2';
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> kknrRecTypeIds = new Set<Id>{SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK)};
       query = 'SELECT Id, OwnerId FROM Account WHERE Is_Owner_Changed__c = :todaysdate and Business_Unit__c != NULL and RecordTypeId IN :kknrRecTypeIds and (Security_Category__c != :securitycategoryklass1 OR Security_Category__c != :Securitycategoryklass2)';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> Listofkknr) {
        
        List<Account> listofkknrforaggregation = new List<Account>();
        List<Agreement_Situation__c> listofagreementsituation = [SELECT Id, OwnerId,KKnr__c FROM Agreement_Situation__c WHERE KKnr__c IN :Listofkknr];
        Map<Id,Agreement_Situation__c> agreementsituationMap = new Map<Id,Agreement_Situation__c>();
       
        if(Listofkknr.size() > 0)
        {
            for(Account acc : Listofkknr)
            {                
                for(Agreement_Situation__c agreecat :  listofagreementsituation)
                {   
                    if(acc.id == agreecat.kknr__c)
                    {
                        if(acc.OwnerId != agreecat.OwnerId)
                        {                       
                           agreecat.OwnerId = acc.OwnerId;
                           agreementsituationMap.put(agreecat.Id,agreecat); 
                        } 
                    }
                } 
            }
        }
        if(agreementsituationMap.size() > 0)
        {
           try
            {
                update agreementsituationMap.values();
            }
            catch(Exception e)
            { 
                system.debug('Exception Caught:'+e.getmessage());
            }                  
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
         
    }
}