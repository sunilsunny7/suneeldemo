/*Batch to create avtalsituation, change owner of org as per kknr and set GESB flag on org when related Kundkonto name is changed.
History:
Apr 2020: Customer list changes to update owner on Org.
Aug 2020: Added exception handling logic.
*/

global class BatchToAddAgreSitnOnNewlyCreatedKKNR implements Database.Batchable<sObject>{
    String query;
    Date todaysdate = system.today();
    Datetime todayDateTime = todaysdate; 
    String securitycategoryklass1 = 'Klass 1';
    String Securitycategoryklass2 = 'Klass 2';

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        Set<Id> OrgRecTypeIds = new Set<Id>{SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE),SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME),SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC1),SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC2) };
        Set<Id> kknrRecTypeIds = new Set<Id>{SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK),SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1),SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2)};
        Set<Id> parentIds=new Set<Id>();
        //Get all Kundkontos where the name is changed today
        List < AccountHistory > nameChanged = new list < AccountHistory > ([select Id, IsDeleted, CreatedDate, AccountId, OldValue, Newvalue, Field From AccountHistory where Field = 'TextName' AND CreatedDate>= YESTERDAY AND Account.RecordTypeId IN :kknrRecTypeIds]);
        for (AccountHistory accHist: nameChanged) {
           parentIds.add(accHist.AccountId);                 
        }
        //Get all kundkontos which are created today. 
        //Get all Org accounts where KKNR's owner is changed.
        //Get all Orgs accounts where KKNR name is changed
        query = 'SELECT Id,Org_Nr__c,RecordTypeId,Parent.OwnerId,ParentId,Suggested_Owner__c,GESB_Flag_Org__c,OwnerId,Is_Owner_Changed__c,Parent.Is_Owner_Changed__c,CreatedDate FROM Account WHERE (RecordTypeId IN :kknrRecTypeIds and CreatedDate >= :todaysdate and Business_Unit__c != NULL and (Security_Category__c != :securitycategoryklass1 OR Security_Category__c != :Securitycategoryklass2)) OR (RecordTypeId IN : OrgRecTypeIds AND ((Parent.Is_Owner_Changed__c >= YESTERDAY) OR (ParentId IN : parentIds)))';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> ListofAcc) {
        
        List<Agreement_Categories__c> listofagreementcategories = Agreement_Categories__c.getall().values();
        List<Agreement_Situation__c> insertlistofagreementsituationOnkknr = new List<Agreement_Situation__c>();
        List<Account> accstoUpdate= new List<Account>();
        Set<Id> accParentId = new Set<Id>();
        Date YesterdayDate= Date.today().addDays(-1);
        List<vlocity_cmt__VlocityErrorLogEntry__c> exceptions = new List<vlocity_cmt__VlocityErrorLogEntry__c>();
        //Exceptions from the DMLs are stored in this Object
        if(ListofAcc.size() > 0)
        {
            for(Account acc : ListofAcc)
            if(acc.ParentId!=null){
            accParentId.add(acc.ParentId);
            }
         }
         

        List < AccountHistory > nameChangedList = new list < AccountHistory > ([select Id, IsDeleted, CreatedDate, AccountId,Account.ParentId, OldValue, Newvalue, Field From AccountHistory where Field = 'TextName' AND AccountId IN :accParentId AND CreatedDate >= YESTERDAY]);

        Set<Id> parentId=new Set<Id>();
        
        for (AccountHistory accHist: nameChangedList) {
           parentId.add(accHist.AccountId);                 
        }
        

        if(ListofAcc.size() > 0)
        {
            for(Account acc : ListofAcc)
            {
            //Create new agreement situation records for newly created KKNR
             if((acc.RecordTypeId==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK) || acc.RecordTypeId==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1) || acc.RecordTypeId==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2 )) && acc.CreatedDate >= todaysdate){
                for(Agreement_Categories__c agreecat : listofagreementcategories)
                {   
                    Agreement_Situation__c agrementsituation = new Agreement_Situation__c();
                    agrementsituation.Agreement_Category__c = agreecat.Name;
                    agrementsituation.KKnr__c = acc.id;
                    agrementsituation.OwnerId = acc.OwnerId;
                    /*agrementsituation.Start_Date__c = System.today();
                    agrementsituation.End_Date__c = System.today() + 1;
                    agrementsituation.Supplier__c = 'Telia';*/
                    insertlistofagreementsituationOnkknr.add(agrementsituation);                        
                }  
            }
            if(acc.RecordTypeId ==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE) || acc.RecordTypeId ==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME)  || acc.RecordTypeId ==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC1)  || acc.RecordTypeId ==SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC2) && acc.Org_Nr__c!=null){
            if(acc.Parent.Is_Owner_Changed__c >= YesterdayDate){
            if(acc.OwnerId!=acc.Parent.OwnerId){
            acc.OwnerId=acc.Parent.OwnerId;
            acc.Is_Owner_Changed__c=System.today(); 
            }   
            }//assign new owner as per KKNR owner
            if(parentId.contains(acc.ParentId))
            {
            acc.GESB_Flag_Org__c=true;           
            }//set flag if related KKNR name is changed so these records flows down to GESB/Alpha
            accstoUpdate.add(acc);
           
            }
            }
          }
            if(insertlistofagreementsituationOnkknr.size() > 0)
            {
                
                try
                {
                    insert insertlistofagreementsituationOnkknr;
                }
                catch(Exception e)
                { 
                    system.debug('Exception Caught:'+e.getmessage());                 
                    vlocity_cmt__VlocityErrorLogEntry__c v1= new vlocity_cmt__VlocityErrorLogEntry__c();
                    v1.vlocity_cmt__ErrorType__c='Exception';
                    v1.vlocity_cmt__ErrorMessage__c=String.valueOf(e.getmessage());
                    v1.vlocity_cmt__SourceName__c='BatchToAddAgreSitnOnNewlyCreatedKKNR';
                    v1.vlocity_cmt__ObjectName__c='Account';
                    exceptions.add(v1); 
                                      
                }                                  
        }
        

        
        if(accstoUpdate.size() > 0){
        try
                {
                    update accstoUpdate;
                }
                catch(Exception e)
                { 
                    system.debug('Exception Caught:'+e.getmessage());                    
                    vlocity_cmt__VlocityErrorLogEntry__c v2= new vlocity_cmt__VlocityErrorLogEntry__c();
                    v2.vlocity_cmt__ErrorType__c='Exception';
                    v2.vlocity_cmt__ErrorMessage__c=String.valueOf(e.getmessage());
                    v2.vlocity_cmt__SourceName__c='BatchToAddAgreSitnOnNewlyCreatedKKNR';
                    v2.vlocity_cmt__ObjectName__c='Account';
                    exceptions.add(v2);    
                     } 
        }
                if(exceptions.size()>0){
                try
                {
                    insert exceptions;
                }
                catch(Exception e)
                { 
                system.debug('Exception Caught:'+e.getmessage());       
                }               
                
                
    }   
    }
    
    global void finish(Database.BatchableContext BC) {
    
         AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =: BC.getJobId()
        ];
        List<String> mailToAddresses = new List<String>();
        List<Id> idList=new List<Id>();
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = '2nd Line Support Group'];
        for (GroupMember gm : g.groupMembers) {
        idList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :idList];
        for(User u : usr) {
        mailToAddresses.add(u.email);
        }
        List<vlocity_cmt__VlocityErrorLogEntry__c> exceptionsCheck = [Select Id from vlocity_cmt__VlocityErrorLogEntry__c where CreatedDate>=:System.today() AND vlocity_cmt__SourceName__c='BatchToAddAgreSitnOnNewlyCreatedKKNR'];
        if(exceptionsCheck.size()>0){
        //   notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(mailToAddresses);
        mail.setSubject('Failures in Customer List Daily Job');
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures ' + exceptionsCheck.size() +' Exceptions.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });}
        
        else
        {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(mailToAddresses);
        mail.setSubject('Customer List Daily Job ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
        }
        BatchToChangeAgreementSituationOwner b = new BatchToChangeAgreementSituationOwner();
        database.executeBatch(b,200);
    }
}