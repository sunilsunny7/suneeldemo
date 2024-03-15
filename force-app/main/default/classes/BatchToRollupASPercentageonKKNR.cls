global class BatchToRollupASPercentageonKKNR implements Database.Batchable<sObject>{
    String query;
    String securitycategoryklass1 = 'Klass 1';
    String Securitycategoryklass2 = 'Klass 2';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> kknrRecTypeIds = new Set<Id>{SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK)}; //SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1)
        query = 'SELECT Id, OwnerId,Uppfyllnadsgrad_Avtalssituation__c FROM Account WHERE RecordTypeId IN :kknrRecTypeIds and Business_Unit__c != NULL and (Security_Category__c != :securitycategoryklass1 OR Security_Category__c != :Securitycategoryklass2)';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> Listofkknr) {
        List<Account> listofkknrforaggregation = new List<Account>();
        List<Agreement_Situation__c> insertagreementsituationwithkknr = new List<Agreement_Situation__c>();
        date todaysdate = system.today() - 1;
        List<Agreement_Situation__c> listofagreementsituation = [SELECT Id, Agreement_Category__c,KKnr__c,Supplier__c,End_Date__c FROM Agreement_Situation__c WHERE KKnr__c IN :Listofkknr and End_Date__c = :todaysdate and End_Date__c != null] ;
        Set<Id> setofKKNR = new Set<Id>();
        for(Agreement_Situation__c ass : listofagreementsituation)
        {
            setofKKNR.add(ass.KKnr__c);
        }
        List<Agreement_Situation__c> agreementsituationlist = [SELECT Id, Agreement_Category__c,KKnr__c,Supplier__c,End_Date__c FROM Agreement_Situation__c WHERE KKnr__c IN :setofKKNR] ;
        for(Id acc : setofKKNR)
        {   
            decimal sumofsupplieronKKNR = 0.00;
            for(Agreement_Situation__c agreesituation : agreementsituationlist)
            {    if(acc == agreesituation.KKnr__c)
                {
                    if((agreesituation.End_Date__c >= System.Today() && agreesituation.Supplier__c != null && agreesituation.End_Date__c != null) || ((agreesituation.Supplier__c =='Not applicable for the customer')) || (agreesituation.Supplier__c != null && agreesituation.End_Date__c >= System.Today()))  
                    {
                        sumofsupplieronKKNR = 0.1+ sumofsupplieronKKNR;
                    }            
                }                     
            }
            sumofsupplieronKKNR = (sumofsupplieronKKNR/13)*1000;  
            Account acct = new Account();
            acct.Uppfyllnadsgrad_Avtalssituation__c = sumofsupplieronKKNR.setscale(2);
            acct.id = acc;
            listofkknrforaggregation.add(acct);   
        } 
       
        if(listofkknrforaggregation.size() > 0)
        {
            try
            {
                update listofkknrforaggregation;
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