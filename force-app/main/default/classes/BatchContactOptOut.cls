/**
About
-----
Description: BatchAccountOptOut for SAEN-1838 - CLM Marketing Opt Out
Create date: 03.3-2017

Update History
--------------
Created Mars 2017 - Vahraz Mostajir - SAEN-1838. 

Issues / TODOs
--------------     
*/

public class BatchContactOptOut implements Database.Batchable<Contact>, Database.Stateful  {
    
    public Map<Id, Account> parentAccounts;
    
    public BatchContactOptOut(){
        System.debug('ContactOptOut INIT');
        parentAccounts = new Map<Id, Account>([SELECT Id,Marketing_Mails_Opt_Out__c,From_Date__c, To_Date__c,Newsletter_Telia__c, Newsletter_Cygate__c , 
                                               Survey_Telia__c , Survey_Cygate__c , Event_Cygate__c , Event_Telia__c , Campaigns_Telia__c , Campaigns_Cygate__c , SMS_Telia__c , SMS_Cygate__c,
                                               From_Date_Cygate__c , To_Date_Cygate__c, Opt_Out_Stages_Cygate__c,Marketing_Mails_Opt_Out_Cygate__c,
                                               Process_Opt_Out__c  , Process_Opt_Out_Cygate__c,Opt_Out_Timestamp__c 
                                               FROM Account
                                               WHERE (RecordTypeId = :SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE) 
                                                      OR RecordTypeId = :SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME)
                                                   /*   OR RecordTypeId = :SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_CYGATE_SUB)*/)
                                               AND (Process_Opt_Out__c = True  OR Process_Opt_Out_Cygate__c = True)
                                              ]);
                                              
         
        
    }
    
    public List<Contact> start(Database.BatchableContext BC) {   
        return new List<Contact>([SELECT Id, Opt_Out_Manually_Set__c, AccountId,From_Date__c, Man_From_Date__c,To_Date__c, Man_To_Date__c,
                                  Marketing_Mails_Opt_Out_Contact__c, Man_Mails_Opt_Out__c,Newsletter_Telia__c, Newsletter_Cygate__c , 
                                  Survey_Telia__c , Survey_Cygate__c , Event_Cygate__c , Event_Telia__c , Campaigns_Telia__c , Campaigns_Cygate__c ,
                                  SMS_Telia__c , SMS_Cygate__c,Opt_Out_Timestamp__c 
                                  FROM Contact
                                  WHERE AccountId IN :parentAccounts.keySet() 
                                  AND RecordTypeId = :SEUtility.getRecordTypeId(SEUTILITY.CONTACT_RECTYPE_CUSTOMER)
                                 ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope){  
        System.debug('ContactOptOut EXECUTE');     
        
         for(Contact con : scope){

         if(parentAccounts.get(con.AccountId).Process_Opt_Out__c == true && parentAccounts.get(con.AccountId).Process_Opt_Out_Cygate__c == true){
                 con.Newsletter_Telia__c = parentAccounts.get(con.AccountId).Newsletter_Telia__c;
                con.Newsletter_Cygate__c = parentAccounts.get(con.AccountId).Newsletter_Cygate__c;
                con.Survey_Telia__c = parentAccounts.get(con.AccountId).Survey_Telia__c;
                con.Survey_Cygate__c = parentAccounts.get(con.AccountId).Survey_Cygate__c;
                con.Event_Telia__c = parentAccounts.get(con.AccountId).Event_Telia__c;
                con.Event_Cygate__c = parentAccounts.get(con.AccountId).Event_Cygate__c;        
                con.Campaigns_Telia__c = parentAccounts.get(con.AccountId).Campaigns_Telia__c;
                con.Campaigns_Cygate__c = parentAccounts.get(con.AccountId).Campaigns_Cygate__c;
                con.SMS_Telia__c = parentAccounts.get(con.AccountId).SMS_Telia__c;
                con.SMS_Cygate__c = parentAccounts.get(con.AccountId).SMS_Cygate__c;
                con.From_Date__c = parentAccounts.get(con.AccountId).From_Date__c;
                con.To_Date__c = parentAccounts.get(con.AccountId).To_Date__c;
                con.Marketing_Mails_Opt_Out_Contact__c = parentAccounts.get(con.AccountId).Marketing_Mails_Opt_Out__c;
                con.From_Date_Cygate_Contact__c = parentAccounts.get(con.AccountId).From_Date_Cygate__c;
                con.To_Date_Cygate_Contact__c = parentAccounts.get(con.AccountId).To_Date_Cygate__c;
                con.Marketing_Mails_Opt_Out_Cygate_Contact__c = parentAccounts.get(con.AccountId).Marketing_Mails_Opt_Out_Cygate__c;
                con.Opt_Out_Timestamp__c = parentAccounts.get(con.AccountId).Opt_Out_Timestamp__c;
            }
             if(parentAccounts.get(con.AccountId).Process_Opt_Out_Cygate__c == true){
                con.Newsletter_Cygate__c = parentAccounts.get(con.AccountId).Newsletter_Cygate__c;
                con.Survey_Cygate__c = parentAccounts.get(con.AccountId).Survey_Cygate__c;
                con.Event_Cygate__c = parentAccounts.get(con.AccountId).Event_Cygate__c;        
                con.Campaigns_Cygate__c = parentAccounts.get(con.AccountId).Campaigns_Cygate__c;
                con.SMS_Cygate__c = parentAccounts.get(con.AccountId).SMS_Cygate__c;
                con.From_Date_Cygate_Contact__c = parentAccounts.get(con.AccountId).From_Date_Cygate__c;
                con.To_Date_Cygate_Contact__c = parentAccounts.get(con.AccountId).To_Date_Cygate__c;
                con.Marketing_Mails_Opt_Out_Cygate_Contact__c = parentAccounts.get(con.AccountId).Marketing_Mails_Opt_Out_Cygate__c;
            }
             if(parentAccounts.get(con.AccountId).Process_Opt_Out__c == true){
                 con.Newsletter_Telia__c = parentAccounts.get(con.AccountId).Newsletter_Telia__c;
                con.Survey_Telia__c = parentAccounts.get(con.AccountId).Survey_Telia__c;
                con.Event_Telia__c = parentAccounts.get(con.AccountId).Event_Telia__c;
                con.Campaigns_Telia__c = parentAccounts.get(con.AccountId).Campaigns_Telia__c;
                con.SMS_Telia__c = parentAccounts.get(con.AccountId).SMS_Telia__c;
                con.From_Date__c = parentAccounts.get(con.AccountId).From_Date__c;
                con.To_Date__c = parentAccounts.get(con.AccountId).To_Date__c;
                con.Marketing_Mails_Opt_Out_Contact__c = parentAccounts.get(con.AccountId).Marketing_Mails_Opt_Out__c;
                con.Opt_Out_Timestamp__c = parentAccounts.get(con.AccountId).Opt_Out_Timestamp__c;
            }

               
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('ContactOptOut FINNISH');
        
        Database.executeBatch(new BatchOptOutCompleted(), 100);
    }   
}