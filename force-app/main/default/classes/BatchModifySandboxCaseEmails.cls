public class BatchModifySandboxCaseEmails implements Database.Batchable<sObject>{
    Public Database.QueryLocator start(Database.BatchableContext BC){
        //exclude all Cases without email and emails that are already modified
        String query = 'select Id,SuppliedEmail,SuppliedPhone,Enterprise_Case_Notification_Email__c from case where (SuppliedEmail != null AND (NOT SuppliedEmail LIKE \'%@example.com\')) OR (Enterprise_Case_Notification_Email__c != null AND (NOT Enterprise_Case_Notification_Email__c LIKE \'%@example.com\')) OR (SuppliedPhone != null)';
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
        List<case> listCase = (List<case>)scope;
        List<case> ListToUpdate = new List<case>();
        double y = Math.random() ; //between 0 and 1
        y = 999999999 * y;
        String index = String.valueOf(math.round(y));
        Integer count;
        if(scope!=null){
            for(Case c:listCase){
               
                if(c.SuppliedEmail != null)
                {
                  c.SuppliedEmail = (c.SuppliedEmail.replace('@', '=')).reverse() + '@example.com';
                }
                if(c.Enterprise_Case_Notification_Email__c != null)
                {
                  c.Enterprise_Case_Notification_Email__c = (c.Enterprise_Case_Notification_Email__c.replace('@', '=')).reverse() + '@example.com';
                }
                /*if(c.ContactEmail != null)
                {
                  c.ContactEmail = (c.ContactEmail.replace('@', '=')).reverse() + '@example.com';
                }*/
                
                if(c.SuppliedPhone != null && c.SuppliedPhone.length()>3)
                {
                    count = c.SuppliedPhone.length() - 3;
                    c.SuppliedPhone = c.SuppliedPhone.replace(c.SuppliedPhone.right(count),index.left(count));
                }
                /*if(c.ContactPhone != null && c.ContactPhone.length()>3)
                {
                    count = c.ContactPhone.length() - 3;
                    c.ContactPhone = c.ContactPhone.replace(c.ContactPhone.right(count),index.right(count));
                }*/
               /* if(c.ContactMobile != null && c.ContactMobile.length()>3)
                {
                    count = c.ContactMobile.length() - 3;
                    c.ContactMobile = c.ContactMobile.replace(c.ContactMobile.right(count),index.right(count));
                }
                */
                ListToUpdate.add(c);                    
            }
        }
        if(ListToUpdate.size()>0){
            //Update all Cases that can be updated
            system.debug('Cases : ' +ListToUpdate);
            database.update(ListToUpdate,false);
        }
    }

    Public void finish(Database.BatchableContext BC){
        system.debug('***** BatchModifySandboxCaseEmails is complete.');    
    }
}