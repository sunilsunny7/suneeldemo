/**Created By:  Tridib
**Sprint: Sprint-3
**User Story:MCSTO-1234
**Description: Notify Account Managers when offerings in frame agreement is about to expire
-----------------------------------------------------------------------------------------------------------*/
global class TeliaSE_ContractBatch implements Database.Batchable<SObject>, Database.Stateful {
        
        List<Integer> daysList = new List<Integer>{};
        Map<Id, User> userMap = new Map<Id, User>{};
        Map<Id, vlocity_cmt__ContractLineItem__c> cliMap = new Map<Id, vlocity_cmt__ContractLineItem__c>{};
        Map<String, Expire_Notification__c> customListMap = Expire_Notification__c.getAll();
        
        private final string ACCOUNTNAME = '{AcctName}';
        private final string OFFERNAME = '{OfferFamily}';
        private final string DATALABEL = '{dateLabel}';
        private final string ACCOUNTOWNER = '{AcctOwner}';
        private final string COMMITMENTTIME = '{CommitmentTime}';
        private final string YESNO = '{yesNo}';
        private final string ENDDATE = '{EndDate}';
        private final string MONTHS = 'months';
        private final string ZERO = '00:00:00';
        private final string NA = 'NA';
        
        /**
         * @description gets invoked when the batch job starts
         * @param context contains the job ID
         * @returns the record set as a QueryLocator object that will be batched for execution
         */ 
        global Database.QueryLocator start(Database.BatchableContext context) {
            
            List<String> recordTypeDevList = new List<String>{};
            //Grab all notification custom setting
            Map<String, Expire_Notification__c> customListMap = Expire_Notification__c.getAll();
            for(String val: customListMap.keySet()){
                recordTypeDevList.add(customListMap.get(val).RecordTypeDeveloper__c);
                daysList.add((Integer)customListMap.get(val).Days__c);
            }
            //Fetch records from vlocity_cmt__ContractLineItem__c where Status ='Active and TeliaSE_ParentItemId__c = null
            //AND Account RecordType.DeveloperName IN: recordTypeDevList
            return Database.getQueryLocator([SELECT id, Name, Account_Name__c, Account_Owner__c, TeliaSE_SubsidisedVoice__c,TeliaSE_Subsidised_Translate__c,TeliaSE_End_Date__c, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__c, TeliaSE_ParentItemId__c, TeliaSE_Account_Record_Type__c,
                                             TeliaSE_CommitmentPeriod__c, vlocity_cmt__ContractId__c, vlocity_cmt__ContractId__r.Status, vlocity_cmt__ContractId__r.OwnerId,AccountOwnerEmail__c,vlocity_cmt__ContractId__r.CreatedBy.MC_Skip_notification__c
                                             from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__r.Status ='Active' 
                                             AND TeliaSE_ParentItemId__c = null AND vlocity_cmt__ContractId__r.Account.RecordType.DeveloperName IN: recordTypeDevList]);
        }

        /**
         * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
         * @param context contains the job ID
         * @param scope contains the batch of records to process.
         */ 
        global void execute(Database.BatchableContext context, List<vlocity_cmt__ContractLineItem__c> cliList) {
            try{
           
            Map<Id, Id> contractOwnerMap = new Map<Id, Id>{};
            Map<Id, Id> ownerContractMap = new Map<Id, Id>{};    
            //Iterate over contract line items
            for(vlocity_cmt__ContractLineItem__c cliObj: cliList){                
                if(cliObj.TeliaSE_End_Date__c != null){
                    //Checking the dates between today's date with End date of Offer
                    Integer valiDate = Date.today().daysBetween(cliObj.TeliaSE_End_Date__c);                    
                    if(valiDate == customListMap.get(cliObj.TeliaSE_Account_Record_Type__c).Days__c){  
                        cliMap.put(cliObj.Id, cliObj);
                    }
                }                        
        }
                Set<Id> ownerIds = new Set<Id>();
            for(vlocity_cmt__ContractLineItem__c cliObj1: cliList){
                ownerIds.add(cliObj1.AccountOwnerEmail__c);
            }          
              //Iterate over users & adds to collection
                List<User> use = new List<User> ([Select Id, Name, email, MC_Skip_notification__c from User where Id IN: ownerIds]);
            for(User usr: use ){                           
                userMap.put(usr.id, usr);
            }
        }catch(Exception e){
                system.debug('Exception : '+e.getStackTraceString());
            }
        }
        
        public string prepareSubject(String subject, vlocity_cmt__ContractLineItem__c cli){
            Subject = Subject.replace(ACCOUNTNAME, cli.Account_Name__c);
            Subject = Subject.replace(OFFERNAME, cli.Name);
            Subject = Subject.replace(DATALABEL,String.valueOf((integer)customListMap.get(cli.TeliaSE_Account_Record_Type__c).Months__c));
            return subject;
        }
        
        public string prepareHtmlBody(String htmlbody, vlocity_cmt__ContractLineItem__c cli){
            htmlbody = htmlbody.replace(DATALABEL,String.valueOf((integer)customListMap.get(cli.TeliaSE_Account_Record_Type__c).Months__c));
            htmlbody = htmlbody.replace(ACCOUNTNAME,cli.Account_Name__c);
            htmlbody = htmlbody.replace(OFFERNAME,cli.Name);
            htmlbody = htmlbody.replace(ACCOUNTOWNER,cli.Account_Owner__c);  
            
            string ct = cli.TeliaSE_CommitmentPeriod__c != null ? String.valueOf(cli.TeliaSE_CommitmentPeriod__c).removeEnd(MONTHS) : '';
            htmlbody = htmlbody.replace(COMMITMENTTIME,ct);
            htmlbody = htmlbody.replace(YESNO, cli.TeliaSE_SubsidisedVoice__c == null ? NA : cli.TeliaSE_Subsidised_Translate__c);
            string dt = cli.TeliaSE_End_Date__c != null ? String.valueOfGmt(cli.TeliaSE_End_Date__c).removeEnd(ZERO) : '';
            htmlbody = htmlbody.replace(ENDDATE,dt);    
            return htmlbody;
        }
        
        /**
         * @description gets invoked when the batch job finishes. Place any clean up code in this method.
         * @param context contains the job ID
         */ 
        global void finish(Database.BatchableContext context) {
            try{
            String integrationUserEmail = System.Label.TeliaSE_MC_IntegrationUserEmail;
            List<Messaging.Email> mailsToSend = new List<Messaging.Email>{};
            //Fetch email template
            EmailTemplate template = [SELECT DeveloperName,Folder.Name,HtmlValue,Id,Name,Subject FROM EmailTemplate where DeveloperName='TeliaSE_OfferAgreement'];
            for(vlocity_cmt__ContractLineItem__c cli : cliMap.values()){                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(template.Id);                 
                string htmlbody = prepareHtmlBody(template.HtmlValue, cli);
                string Subject = prepareSubject(template.Subject, cli);
                
                mail.setHtmlBody(htmlbody);
                mail.setSubject(Subject);
                mail.saveAsActivity= false;
                if(userMap != null && cli.AccountOwnerEmail__c != null && userMap.get(cli.AccountOwnerEmail__c).email != null && userMap.get(cli.AccountOwnerEmail__c).MC_Skip_notification__c == false)
                {
                    If(userMap.get(cli.AccountOwnerEmail__c).name == 'Integration User')
                    {
                        mail.setToAddresses(new String[] {integrationUserEmail});
                    }
                    else
                    {
                        mail.setToAddresses(new String[] {userMap.get(cli.AccountOwnerEmail__c).email});
                    }    
                    mailsToSend.add(mail);
                }                
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mailsToSend);
            for(Messaging.SendEmailResult res : results){
                 if (res.success)
                 {
                   System.debug('The email was sent successfully.');
                 } else {
                   System.debug('The email failed to send:' +  res.errors[0].message);
                }
            }
            }catch(Exception e){
                system.debug('Exception on TeliaSE_ContractBatch: '+e.getStackTraceString());
            }
        }
}