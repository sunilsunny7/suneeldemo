global  class MassDeleteRecords implements Database.Batchable<sObject>,Schedulable{
    String query;
    String jobType;   

    public MassDeleteRecords() {
        
    }
    //constructor to schedule diff objects at diff time
    public MassDeleteRecords(String jobType,Boolean val) {
        this.jobType=jobType;             
    }       
    //constructor takes dynamic query to delete whatever we want
    public MassDeleteRecords(String query) {
        this.query=query;
    }

    public Database.queryLocator start(Database.BatchableContext bc) {  
        return Database.getQueryLocator(query);
    }

    public void execute( Database.BatchableContext bc, List<sObject> listRecords) {  
        Database.delete(listRecords,false);
    }

    public void finish( Database.BatchableContext bc ){
         AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];         
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses=new List<String>{UserInfo.getUserEmail()};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Generic Batch To Delete Records ' + a.Status);
            mail.setPlainTextBody('records processed ' + a.TotalJobItems +
           'with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public void execute(SchedulableContext SC){
       
        switch on jobType
        {
            when 'Order'{
                purgeOrders();    
            }
            when 'MCOnline_ParentBasket__c'
            {
                purgeBaskets();
            }
            when 'vlocity_cmt__VlocityErrorLogEntry__c'
            {
                deleteLogs();
            }
            when 'prismaPlan'
            {
                deletePrismaPlans();
            }
            when 'agreementPlanChange'
            {
                deletePriceplanChanges();
            }
        }
    }

    private static void purgeOrders()
    {
        Map<String, MC_RAMMFA_Settings__c> RAMMFAMap = MC_RAMMFA_Settings__c.getAll();
        Integer days = Integer.valueOf(RAMMFAMap.get('Order').Type__c);
        String query='select id from Order where CreatedDate < LAST_N_DAYS:'+days;
        MassDeleteRecords purgeOrderObject=new MassDeleteRecords(query);
        Database.executeBatch(purgeOrderObject,20);
    }

    private static void purgeBaskets()
    {
        Map<String, MC_RAMMFA_Settings__c> RAMMFAMap = MC_RAMMFA_Settings__c.getAll();
        Integer days = Integer.valueOf(RAMMFAMap.get('ParentBasket').Type__c);
        String query='select id from MCOnline_ParentBasket__c  where CreatedDate <LAST_N_DAYS:'+days;
        MassDeleteRecords purgeBasketObject=new MassDeleteRecords(query);
        Database.executeBatch(purgeBasketObject,10);

    }
    private static void deleteLogs(){
        Map<String, MC_RAMMFA_Settings__c> RAMMFAMap = MC_RAMMFA_Settings__c.getAll();
        Integer days = Integer.valueOf(RAMMFAMap.get('ErrorLogEntry').Type__c);
        String query='select id from vlocity_cmt__VlocityErrorLogEntry__c where vlocity_cmt__SourceName__c =\'MassCustomized_MadamIntegration\' and CreatedDate < LAST_N_DAYS:'+days;
        MassDeleteRecords purgeObject=new MassDeleteRecords(query);
        Database.executeBatch(purgeObject,10);
    }
    
    private static void deletePrismaPlans()
    {
        if([select id from MC_PrismaPlan__c where MC_Delete_Record__c =false].size()>0)
        {
            String query='select id from MC_PrismaPlan__c where MC_Delete_Record__c = true order by createdDate asc' ;
            MassDeleteRecords purgeObject=new MassDeleteRecords(query);
            Database.executeBatch(purgeObject,2000);
        }
    }

    private static void deletePriceplanChanges()
    {
        Set<String> agreementNumbers=new Set<String>();
        for(ContractHistory conHistory:[select Contract.Agreement_Nr__c, NewValue from ContractHistory where contract.Contract_Record_Type__c in ('RAM Readonly','MFA Readonly') and Contract.Status='Active' and createdDate=TODAY])
        {
            if(conHistory.NewValue =='Active')
            {
                agreementNumbers.add(conHistory.Contract.Agreement_Nr__c);
            }
        }
        if(agreementNumbers.size()>0)
        {
            String query='select id from MC_AgreementPlanChange__c where MC_AgreementNumber__c =:agreementNumbers' ;
            MassDeleteRecords purgeObject=new MassDeleteRecords(query);
            Database.executeBatch(purgeObject,2000);
        }
    }

}