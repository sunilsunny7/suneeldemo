global class UserUnsubscribeBatchProcess implements Database.Batchable<sObject>,Database.Stateful {
    global List<User> useRec = new List<User>();
    public string SITENAME = 'Unsubscribe';
    public string secureUrl = '';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String UsrQuery='';  
        Site siteUrl= [select Id from Site where Name =:SITENAME LIMIT 1];
        SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :siteUrl.Id];
        secureUrl = mySiteDetail.SecureURL;
        UsrQuery = Test.isRunningTest() ? 'SELECT Id,Name,Username,isActive,Manager.Name,Manager.Email,LastLoginDate,Email,ManagerId FROM USER WHERE isActive = true LIMIT 100':'SELECT Id,username,Name,isActive,Send_Notification_Email__c,LastLoginDate,Email,Manager.Name,Manager.Email FROM USER WHERE isActive = true AND LastLoginDate !=null AND IsDeactivationRequested__c =false AND VIP_anv_ndare__c =false';
        return Database.getQueryLocator(UsrQuery);
    } 
    
    global void execute(Database.BatchableContext BC, List<user> usrRecords) {
        List<User> localuseRec = new List<User>();
        String EMAILTEMPLATE='UserEmailNotify';
        String EmailFolderName ='UserDeactivation';
        Map<String,EmailTemplate> mapofEmailTemplate = new Map<String,EmailTemplate>();
        List<Messaging.SingleEmailMessage> listofemail  = new List<Messaging.SingleEmailMessage>();
        try{
            List<EmailTemplate> EmlTmplt = [SELECT DeveloperName,Folder.Name,HtmlValue,Id,Name,Subject FROM EmailTemplate where folder.Name=:EmailFolderName];
            //Get the deactivation email templates in local Map
            for (EmailTemplate e : EmlTmplt){
                mapofEmailTemplate.put(e.DeveloperName,e);
            }
            // Start the Processing
            if(usrRecords.size()>0){
                for (User u : usrRecords){
                    if(System.now() > u.LastLoginDate.addDays(90) || test.isRunningTest()){
                        Messaging.SingleEmailMessage mail = createSingleEmail(u,mapofEmailTemplate.get(EMAILTEMPLATE),'DEFAULT');
                        listofemail.add(mail);
                        u.Send_Notification_Email__c = system.now();
                        localuseRec.add(u);
                    }
                }  
            } 
            Messaging.SendEmailResult[] emaillist= Messaging.sendEmail(listofemail);
            system.debug('!!!'+localuseRec.size()+'%%%'+listofemail); 
            Database.SaveResult[] results = Database.update(localuseRec,false);
            /*if(localuseRec.size()>0){
useRec.addall(localuseRec);
}
system.debug('User Records:-'+useRec.size()); */
        }catch(Exception ex){
            System.debug(ex.getLineNumber()+'$$$'+ex.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
    
    @testvisible   private Messaging.SingleEmailMessage createSingleEmail(User usr, EmailTemplate templateId,String param){
        String AESKey = generateAESEncryptedKey(usr.Username);
        String urlEncodedStringKey = EncodingUtil.urlEncode(AESKey,'UTF-8');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templateId.Id);
        mail.setTargetObjectId(usr.id);
        String hyperlink  = '<a href="'+secureUrl+'?uniqueId='+urlEncodedStringKey+'">Säga upp min licens</a>';
        system.debug('hyperlink:-'+hyperlink); 
        String udpateLink = templateId.HtmlValue.replace('{!User.Alias}',hyperlink);
        String htmlbdy = udpateLink.replace('{!Receiving_User.Name}',usr.Name);
        mail.setHtmlBody(htmlbdy);
        mail.setSubject('Din Salesforce licens');
        mail.setToAddresses(new String[] {usr.Email});
        /*if(usr.manager.email !=null)
            mail.setCcAddresses(new String[] {usr.manager.email}); */
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setSaveAsActivity (false);
        return mail;
    }
    @testvisible private String generateAESEncryptedKey(String username){
        String getSecurityKey = Label.AESSecurityKey;
        If(String.isNotBlank(getSecurityKey)){
            Blob CryptoKey = EncodingUtil.base64Decode(getSecurityKey);
            System.debug('Key Data:-'+CryptoKey.size());
            Blob data = Blob.valueOf(username);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES256', CryptoKey, data);
            system.debug('Encrypt Data:-'+EncodingUtil.base64Encode(encryptedData));
            return EncodingUtil.base64Encode(encryptedData);
        } 
        return null;
    }
}