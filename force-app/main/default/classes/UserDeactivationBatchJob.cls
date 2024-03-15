global class UserDeactivationBatchJob implements Database.Batchable<sObject>,Database.Stateful {
   // global List<User> useRec = new List<User>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
      /*  String UsrQuery='';  
        UsrQuery = 'SELECT Id,Name,isActive,Notification_email_Sent__c,LastLoginDate,Email,ManagerId,Manager.Name,Manager.Email FROM USER WHERE isActive = true AND LastLoginDate !=null AND VIP_anv_ndare__c =false';
        return Database.getQueryLocator(UsrQuery);
        */
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<user> usrRecords) {
        /*
        List<User> localuseRec = new List<User>();
        Set<Id>listofUsrId = new Set<Id>();
        //To be removed later
        List<testcs__c>testrecord = new List<testcs__c>();
        String EMAILTEMPLATEWITHNOACCOUNT='InitialUserNotification_NoAcc';
        String EMAILTEMPLATEWITHACCOUNT='InitialUserNotification_withAcc';
        String FINALEMAILTEMPLATEWITHACCOUNT= 'SecondUserNotification_withAcc';
        String FINALEMAILTEMPLATEWITHNOACCOUNT='SecondUserNotification_withNoAcc';
        String EmailFolderName ='Deactivation Email Template';
        Map<Id, Account> ownerToAccountMap = new Map<Id, Account>();
        Map<String,EmailTemplate> mapofEmailTemplate = new Map<String,EmailTemplate>();
        boolean isAccFound;
        List<Messaging.SingleEmailMessage> listofemail  = new List<Messaging.SingleEmailMessage>();
        try{
            List<EmailTemplate> EmlTmplt = [SELECT DeveloperName,Folder.Name,HtmlValue,Id,Name,Subject FROM EmailTemplate where folder.Name=:EmailFolderName];
            //Get the deactivation email templates in local Map
            for (EmailTemplate e : EmlTmplt){
                mapofEmailTemplate.put(e.DeveloperName,e);
            }
            //Get the list of user ids against the scope
            for(User usr : usrRecords){
                listofUsrId.add(usr.id);    
            } 
            system.debug('%%%'+listofUsrId.size());
            // Get the Account Owner based on the scope user records
            for(Account a : [Select Id,ownerId,Cygate_Account_Manager__c,Personal_Advisor__c from Account where ownerId IN :listofUsrId OR Cygate_Account_Manager__c IN :listofUsrId OR Personal_Advisor__c IN :listofUsrId])
            {
                if(!ownerToAccountMap.containsKey(a.OwnerId))
                    ownerToAccountMap.put(a.OwnerId, a);
                if(a.Cygate_Account_Manager__c !=null && !ownerToAccountMap.containsKey(a.Cygate_Account_Manager__c))
                    ownerToAccountMap.put(a.Cygate_Account_Manager__c, a);
                if(a.Personal_Advisor__c !=null && !ownerToAccountMap.containsKey(a.Personal_Advisor__c))
                    ownerToAccountMap.put(a.Personal_Advisor__c, a);
            }
            system.debug('FullMap:-'+ownerToAccountMap);
            // Start the Processing
            if(usrRecords.size()>0){
                for (User u : usrRecords){
                    isAccFound = false;
                    if(System.now() > u.LastLoginDate.addDays(60)){
                        system.debug('Map1:-'+ownerToAccountMap.containsKey(u.Id)+'User1'+u.Id);
                        system.debug('Map2:-'+ownerToAccountMap.containsKey(u.Id)+'User2'+u.Id);
                        system.debug('Map3:-'+ownerToAccountMap.containsKey(u.Id)+'User3'+u.Id);
                        if(ownerToAccountMap.containsKey(u.Id)){
                            // For login date less than 90 days
                            isAccFound = true;
                            if(System.now() < u.LastLoginDate.addDays(90)){
                                Messaging.SingleEmailMessage mail = createSingleEmail(u,'Salesforce-Licens',mapofEmailTemplate.get(EMAILTEMPLATEWITHACCOUNT),'DEFAULT');
                                listofemail.add(mail);
                                //To be removed
                                testcs__c c1 = new testcs__c();
                                c1.name = u.id;
                                c1.Scenario__c = 'NOTIFICATION A';
                                testrecord.add(c1);
                            }
                            // For login date greater than 90 days
                            else if(u.Notification_email_Sent__c ==null && system.now() > u.LastLoginDate.addDays(90)){
                                isAccFound = true;
                                Messaging.SingleEmailMessage mail = createSingleEmail(u,'Salesforce-Licens',mapofEmailTemplate.get(FINALEMAILTEMPLATEWITHACCOUNT),'UPDATE');
                                listofemail.add(mail);
                                u.Notification_email_Sent__c = system.today();
                                //To be removed
                                testcs__c c2 = new testcs__c();
                                c2.name = u.id;
                                c2.Scenario__c = 'NOTIFICATION B';
                                testrecord.add(c2);
                            } 
                            //Email wait period of 10 days
                            else if (u.Notification_email_Sent__c !=null && system.today() == u.Notification_email_Sent__c.adddays(10)){ 
                                isAccFound = true;
                                system.debug('10 days deactivation');
                                Messaging.SingleEmailMessage mail = createSingleEmail(u,'Salesforce-Licens',mapofEmailTemplate.get(FINALEMAILTEMPLATEWITHACCOUNT),'UPDATE');
                                u.Notification_email_Sent__c = system.today();
                                listofemail.add(mail);
                                //To be removed
                                testcs__c c3 = new testcs__c();
                                c3.name = u.id;
                                c3.Scenario__c = 'NOTIFICATION B';
                                testrecord.add(c3);
                            }
                        }
                        system.debug('####'+isAccFound);
                        //No accounts look up 
                        if(isAccFound ==false){
                            if(System.now() < u.LastLoginDate.addDays(75)){
                                Messaging.SingleEmailMessage mail = createSingleEmail(u,'Salesforce-Licens',mapofEmailTemplate.get(EMAILTEMPLATEWITHNOACCOUNT),'DEFAULT');
                                listofemail.add(mail);
                                //To be removed
                                testcs__c c4 = new testcs__c();
                                c4.name = u.id;
                                c4.Scenario__c = 'NOTIFICATION C';
                                testrecord.add(c4);
                            }
                            // greater than 75 days
                            else { 
                                Messaging.SingleEmailMessage mail = createSingleEmail(u,'Salesforce-Licens',mapofEmailTemplate.get(FINALEMAILTEMPLATEWITHNOACCOUNT),'DEACTIVATE');
                                listofemail.add(mail);
                                u.isActive = false;
                                //To be removed
                                testcs__c c5 = new testcs__c();
                                c5.name = u.id;
                                c5.Scenario__c = 'NOTIFICATION D';
                                testrecord.add(c5);
                            }
                        }
                        localuseRec.add(u);
                    }
                }
            }
            //   Messaging.SendEmailResult[] r5 = Messaging.sendEmail(listofemail);
            system.debug('!!!'+localuseRec.size()+'%%%'+listofemail); 
            if(Label.BatchJobSwitch == 'TRUE'){
                system.debug('BatchJobRun');
                //   Database.SaveResult[] results = Database.update(localuseRec,false);
            }
            if(localuseRec.size()>0){
            useRec.addall(localuseRec);}
            system.debug('User Records:-'+useRec.size());
            //To be removed
            if(testrecord.size()>0){
            database.insert(testrecord);}
        }catch(Exception ex){
            System.debug(ex.getLineNumber()+'$$$'+ex.getMessage());
        }
        */
    }
    global void finish(Database.BatchableContext BC) {
        /* system.debug('All User Records'+useRec.size());
        List<testcs1__c>total = new List<testcs1__c>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'abhik.dey@teliacompany.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('User De-activate Status');
        mail.setPlainTextBody('The batch Apex job processed '+useRec.size());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //To be removed latter
        for (User f : useRec){
            testcs1__c  g1 = new testcs1__c ();
            g1.name = f.id;
            g1.acive__c = f.isactive;
            g1.Notification__c = f.Notification_email_Sent__c;
            total.add(g1);
        }
        database.insert(total);
        */
    }
    /*
    private Messaging.SingleEmailMessage createSingleEmail(User usr, String Notification, EmailTemplate templateId,String param){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templateId.Id);
        mail.setTargetObjectId(usr.id);
        if(param == 'DEFAULT'){
            mail.setCcAddresses(new String[] {usr.Manager.email});
            mail.setToAddresses(new String[] {usr.email}); 
        }else if (param == 'UPDATE'){
            String htmlbdy = templateId.HtmlValue.replace('{!User.Name}',usr.name);
            mail.setHtmlBody(htmlbdy);
            mail.setSubject('User De-Activation Notification Reminder Email');
            mail.setToAddresses(new String[] {usr.Manager.email});
            mail.setTreatTargetObjectAsRecipient(false);
        }
        else{
            mail.setToAddresses(new String[] {usr.Manager.email});
            mail.setTreatTargetObjectAsRecipient(false);
        }
        mail.setSenderDisplayName(Notification);
        mail.setSaveAsActivity (false);
        return mail;
    }
    */
}