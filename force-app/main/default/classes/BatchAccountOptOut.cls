/**
About
-----
Description: BatchAccountOptOut for  CLM Marketing Opt Out
Create date: 03.3-2017

Update History
--------------
Created Mars 2017 - Vahraz Mostajir - SAEN-1838.
Updated July 2019 - DeepakRoy 

Issues / TODOs
--------------     
*/

public class BatchAccountOptOut implements Database.Batchable<Account>, Database.Stateful  {
    
    public Map<Id, Account> parentAccounts;
    public Map<Id, Account> parentAccountsTelia;
    public Map<Id, Account> parentAccountsCygate;
    
    public BatchAccountOptOut(){
        System.debug('AccountOptOut INIT');      
        parentAccounts = new Map<Id, Account>([SELECT Id, Marketing_Mails_Opt_Out__c,From_Date__c, To_Date__c,Newsletter_Telia__c, Newsletter_Cygate__c , 
                                               Survey_Telia__c , Survey_Cygate__c , Event_Cygate__c , Event_Telia__c , Campaigns_Telia__c , Campaigns_Cygate__c , 
                                               SMS_Telia__c , SMS_Cygate__c, From_Date_Cygate__c , To_Date_Cygate__c, Opt_Out_Stages_Cygate__c,Marketing_Mails_Opt_Out_Cygate__c,
                                               Process_Opt_Out__c  , Process_Opt_Out_Cygate__c,Opt_Out_Timestamp__c 
                                               FROM Account
                                               WHERE (Process_Opt_Out__c = True   OR Process_Opt_Out_Cygate__c = True)
                                               AND (RecordTypeId = :SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK) 
                                                    OR RecordTypeId = :SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1)
                                                    OR RecordTypeId = :SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2))]);
                                                    
                                                    
                                    
                                                    
        
        
    }
    
    public List<Account> start(Database.BatchableContext BC) { 
        System.debug('AccountOptOut START');
        
                
        return new List<Account>([SELECT Id,Parent.ParentId, RecordTypeId,Process_Opt_Out__c,Process_Opt_Out_Cygate__c, Opt_Out_Manually_Set__c, Parent.Id,From_Date__c, Man_From_Date__c,
                                  To_Date__c, Man_To_Date__c,Marketing_Mails_Opt_Out__c, Man_Mails_Opt_Out__c,
                                  Newsletter_Telia__c, Newsletter_Cygate__c ,Survey_Telia__c , Survey_Cygate__c , 
                                  Event_Cygate__c , Event_Telia__c , Campaigns_Telia__c , Campaigns_Cygate__c , 
                                  SMS_Telia__c , SMS_Cygate__c ,From_Date_Cygate__c , To_Date_Cygate__c, Opt_Out_Stages_Cygate__c,Marketing_Mails_Opt_Out_Cygate__c,Opt_Out_Timestamp__c 
                                  FROM Account
                                  WHERE ParentId IN :parentAccounts.keySet() OR Parent.ParentId IN :parentAccounts.keySet()
                                  ]);
                                  
        
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){  
        System.debug('AccountOptOut EXECUTE');             


         
         for(Account acc : scope){
         
        /* if(acc.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_CYGATE_SUB)){
                acc.Process_Opt_Out_Cygate__c = true;
                acc.From_Date_Cygate__c = parentAccounts.get(acc.Parent.ParentId).From_Date_Cygate__c;
                acc.To_Date_Cygate__c = parentAccounts.get(acc.Parent.ParentId).To_Date_Cygate__c;
                acc.Marketing_Mails_Opt_Out_Cygate__c = parentAccounts.get(acc.Parent.ParentId).Marketing_Mails_Opt_Out_Cygate__c;
                
                acc.Process_Opt_Out__c = true;
                acc.From_Date__c = parentAccounts.get(acc.Parent.ParentId).From_Date__c;
                acc.To_Date__c = parentAccounts.get(acc.Parent.ParentId).To_Date__c;
                acc.Marketing_Mails_Opt_Out__c = parentAccounts.get(acc.Parent.ParentId).Marketing_Mails_Opt_Out__c;
                
                
                acc.Newsletter_Cygate__c = parentAccounts.get(acc.Parent.ParentId).Newsletter_Cygate__c;
                acc.Survey_Cygate__c = parentAccounts.get(acc.Parent.ParentId).Survey_Cygate__c;
                acc.Event_Cygate__c = parentAccounts.get(acc.Parent.ParentId).Event_Cygate__c;
                acc.Campaigns_Cygate__c = parentAccounts.get(acc.Parent.ParentId).Campaigns_Cygate__c;
                acc.SMS_Cygate__c = parentAccounts.get(acc.Parent.ParentId).SMS_Cygate__c;
                
                acc.Newsletter_Telia__c = parentAccounts.get(acc.Parent.ParentId).Newsletter_Telia__c;
                acc.Survey_Telia__c = parentAccounts.get(acc.Parent.ParentId).Survey_Telia__c;
                acc.Event_Telia__c = parentAccounts.get(acc.Parent.ParentId).Event_Telia__c;
                acc.Campaigns_Telia__c = parentAccounts.get(acc.Parent.ParentId).Campaigns_Telia__c;
                acc.SMS_Telia__c = parentAccounts.get(acc.Parent.ParentId).SMS_Telia__c;
                
         }
         else{*/
             if(parentAccounts.get(acc.ParentId).Process_Opt_Out__c == true && parentAccounts.get(acc.ParentId).Process_Opt_Out_Cygate__c == true)             
             {
              System.debug('Total Run');
                acc.Process_Opt_Out__c = true;
                acc.Process_Opt_Out_Cygate__c = true;
                acc.From_Date_Cygate__c = parentAccounts.get(acc.ParentId).From_Date_Cygate__c;
                acc.To_Date_Cygate__c = parentAccounts.get(acc.ParentId).To_Date_Cygate__c;
                acc.From_Date__c = parentAccounts.get(acc.ParentId).From_Date__c;
                acc.To_Date__c = parentAccounts.get(acc.ParentId).To_Date__c;
                acc.Marketing_Mails_Opt_Out__c = parentAccounts.get(acc.ParentId).Marketing_Mails_Opt_Out__c;
                acc.Newsletter_Telia__c = parentAccounts.get(acc.ParentId).Newsletter_Telia__c;
                acc.Newsletter_Cygate__c = parentAccounts.get(acc.ParentId).Newsletter_Cygate__c;
                acc.Survey_Telia__c = parentAccounts.get(acc.ParentId).Survey_Telia__c;
                acc.Survey_Cygate__c = parentAccounts.get(acc.ParentId).Survey_Cygate__c;
                acc.Event_Cygate__c = parentAccounts.get(acc.ParentId).Event_Cygate__c;
                acc.Event_Telia__c = parentAccounts.get(acc.ParentId).Event_Telia__c;
                acc.Campaigns_Telia__c = parentAccounts.get(acc.ParentId).Campaigns_Telia__c;
                acc.Campaigns_Cygate__c = parentAccounts.get(acc.ParentId).Campaigns_Cygate__c;
                acc.SMS_Telia__c = parentAccounts.get(acc.ParentId).SMS_Telia__c;
                acc.SMS_Cygate__c = parentAccounts.get(acc.ParentId).SMS_Cygate__c;  
                acc.Opt_Out_Timestamp__c = parentAccounts.get(acc.ParentId).Opt_Out_Timestamp__c;
                 
             }
              if( parentAccounts.get(acc.ParentId).Process_Opt_Out__c == true){
               System.debug('Telia Run');
                    acc.Process_Opt_Out__c = true;
                    acc.From_Date__c = parentAccounts.get(acc.ParentId).From_Date__c;
                    acc.To_Date__c = parentAccounts.get(acc.ParentId).To_Date__c;
                    acc.Marketing_Mails_Opt_Out__c = parentAccounts.get(acc.ParentId).Marketing_Mails_Opt_Out__c;
                    acc.Newsletter_Telia__c = parentAccounts.get(acc.ParentId).Newsletter_Telia__c;
                    acc.Survey_Telia__c = parentAccounts.get(acc.ParentId).Survey_Telia__c;
                    acc.Event_Telia__c = parentAccounts.get(acc.ParentId).Event_Telia__c;
                    acc.Campaigns_Telia__c = parentAccounts.get(acc.ParentId).Campaigns_Telia__c;
                    acc.SMS_Telia__c = parentAccounts.get(acc.ParentId).SMS_Telia__c;
                    acc.Opt_Out_Timestamp__c = parentAccounts.get(acc.ParentId).Opt_Out_Timestamp__c;

              }
               if( parentAccounts.get(acc.ParentId).Process_Opt_Out_Cygate__c == true){
                System.debug('Cygate Run');
                acc.Process_Opt_Out_Cygate__c = true;
                acc.From_Date_Cygate__c = parentAccounts.get(acc.ParentId).From_Date_Cygate__c;
                acc.To_Date_Cygate__c = parentAccounts.get(acc.ParentId).To_Date_Cygate__c;
                acc.Marketing_Mails_Opt_Out_Cygate__c = parentAccounts.get(acc.ParentId).Marketing_Mails_Opt_Out_Cygate__c;
                acc.Newsletter_Cygate__c = parentAccounts.get(acc.ParentId).Newsletter_Cygate__c;
                acc.Survey_Cygate__c = parentAccounts.get(acc.ParentId).Survey_Cygate__c;
                acc.Event_Cygate__c = parentAccounts.get(acc.ParentId).Event_Cygate__c;
                acc.Campaigns_Cygate__c = parentAccounts.get(acc.ParentId).Campaigns_Cygate__c;
                acc.SMS_Cygate__c = parentAccounts.get(acc.ParentId).SMS_Cygate__c;  
            }
            }
       //  }
        update scope;
    }
    
    
    public void finish(Database.BatchableContext BC){
        System.debug('AccountOptOut FINNISH');
        Database.executeBatch(new BatchContactOptOut(), 100);
    }   
}