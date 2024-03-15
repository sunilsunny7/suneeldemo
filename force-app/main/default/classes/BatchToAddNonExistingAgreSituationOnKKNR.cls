global class BatchToAddNonExistingAgreSituationOnKKNR implements Database.Batchable<sObject>{
    String query;
    String securitycategoryklass1 = 'Klass 1';
    String Securitycategoryklass2 = 'Klass 2';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> kknrRecTypeIds = new Set<Id>{SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK)}; //SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1)
        query = 'SELECT Id, OwnerId FROM Account WHERE RecordTypeId IN :kknrRecTypeIds and (Security_Category__c != :securitycategoryklass1 OR Security_Category__c != :Securitycategoryklass2)';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> Listofkknr) {
        
        
        List<Agreement_Situation__c> agreementsituationlist = [SELECT Id, Agreement_Category__c,KKnr__c,Supplier__c,End_Date__c FROM Agreement_Situation__c WHERE KKnr__c IN :Listofkknr ORDER BY Agreement_Category__c ASC];
        List<Agreement_Categories__c> listofagreementcategories = Agreement_Categories__c.getall().values();
        Map<String,Agreement_Situation__c> mapkknrwithalltypeofagreementsituation = new Map<String,Agreement_Situation__c>();
       
        for(Account acc : Listofkknr)
        {
            for(Agreement_Categories__c allagreementcat : listofagreementcategories)
            {
                mapkknrwithalltypeofagreementsituation.put((acc.id + allagreementcat.Name), new Agreement_Situation__c(KKnr__c = acc.id,Agreement_Category__c = allagreementcat.Name, OwnerId = acc.OwnerId));
            }
        }
        
        for(Agreement_Situation__c existingagreementsituation : agreementsituationlist)
        {
            mapkknrwithalltypeofagreementsituation.remove(existingagreementsituation.KKnr__c +existingagreementsituation.Agreement_Category__c);
            
        }
        if(mapkknrwithalltypeofagreementsituation.size() > 0)
        {
            try
            {
                insert mapkknrwithalltypeofagreementsituation.values();
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