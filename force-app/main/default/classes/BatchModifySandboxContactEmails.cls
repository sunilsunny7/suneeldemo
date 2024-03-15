public class BatchModifySandboxContactEmails implements Database.Batchable<sObject>{
    Public Database.QueryLocator start(Database.BatchableContext BC){
        //exclude all contacts without email and emails that are already modified
        String query = 'select Id,Email,Lead_Submitter_email__c,MobilePhone,Phone from Contact where (Email != null AND (NOT Email LIKE \'%@example.com\')) OR (Lead_Submitter_email__c != null AND (NOT Lead_Submitter_email__c LIKE \'%@example.com\')) OR (MobilePhone != null) OR (Phone != null)';
        //return results to process only if the current instance is a sandbox or a test is running
        Boolean sandbox;
        for(Organization o:[Select isSandbox from Organization limit 1]){
            sandbox = o.isSandbox;
        }
        if(sandbox == TRUE){
            return Database.getQueryLocator(query);
        } else if (Test.isRunningTest()){
            return Database.getQueryLocator(query + ' limit 1');        
        } else {
            return Database.getQueryLocator(query + ' limit 0');
        }
    }

    Public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Contact> listContact = (List<Contact>)scope;
        List<Contact> ListToUpdate = new List<Contact>();
        double y = Math.random() ; //between 0 and 1
        y = 999999999 * y;
        String index = String.valueOf(math.round(y));
        Integer count;
        if(scope!=null){
            for(Contact c:listContact){
                //c.Email = (c.Email.replace('@', '=')).reverse() + '@example.com';
                //c.Email = (c.Email.substring(2,9).replace('@', '=')).reverse() + '@example.com';
                if(c.Email != null)
                {
                  c.Email = (c.Email.replace('@', '=')).reverse() + '@example.com';
                 }
                c.FirstName = 'XXXX';
                c.LastNAme = 'XXXXX';
               // System.debug('Lenght of Mobile: ' + c.Phone.length());
                //System.debug('Last 3 of Phone: ' + c.Phone.right(3));
                System.debug('Lenght of email: ' + c.Email.length());
                if(c.Lead_Submitter_email__c != null)
                {
                  c.Lead_Submitter_email__c = (c.Lead_Submitter_email__c.replace('@', '=')).reverse() + '@example.com';
                }
                if(c.Phone != null && c.Phone.length()>3)
                {
                    count = c.Phone.length() - 3;
                    c.phone = c.phone.replace(c.Phone.right(count),index.left(count));
                }
                if(c.MobilePhone != null && c.MobilePhone.length()>3)
                {
                    count = c.MobilePhone.length() - 3;
                    c.MobilePhone = c.MobilePhone.replace(c.MobilePhone.right(count),index.right(count));
                }
                
                ListToUpdate.add(c);                    
            }
        }
        if(ListToUpdate.size()>0){
            //Update all Contacts that can be updated
            system.debug('Contacts : ' +ListToUpdate);
            database.update(ListToUpdate,false);
        }
    }

    Public void finish(Database.BatchableContext BC){
        system.debug('***** BatchModifySandboxContactEmails is complete.');    
    }
}