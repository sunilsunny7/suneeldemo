/* 
* ******************************************************************************************************
* @author         Lokesh Singh
* Maintained by   /Lokesh Singh
* @version        1.0
* @created        2023-08-31
* @modified       2023-0- 31
* Story           LTAT-15927
*
* ******************************/
public class MCOnline_EmailNotificationSender {
    public static void sendSingleEmailMethod(){
        Messaging.reserveSingleEmailCapacity(2);
        List<Madam_Email_Notification__mdt> emailMetadataList= [SELECT MasterLabel, DeveloperName,Email_Notifcation__c FROM Madam_Email_Notification__mdt];
        Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
        List<String> lsttoaddresses = new list<String>();        
        for(Madam_Email_Notification__mdt metadataRecord : emailMetadataList) {
            lsttoaddresses.add(metadataRecord.Email_Notifcation__c);
        }
        mymail.setToAddresses(lsttoaddresses);
        mymail.setSenderDisplayName('Amanda Prisma file error Notification');
        mymail.setSubject('Madam Integration Prisma file Error');
        String body = 'Hello, <br> <br> '; 
        body += 'During bulk data job run some issue is occuring in Agreement plan change file and Prisma plan file. <br><br>'; 
        body += 'Thanks';     
        
        mymail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });
    }
}