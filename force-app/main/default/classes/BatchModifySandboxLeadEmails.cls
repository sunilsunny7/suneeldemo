public class BatchModifySandboxLeadEmails implements Database.Batchable<sObject>{
    Public Database.QueryLocator start(Database.BatchableContext BC){
        //exclude all leads without email and emails that are already modified
        String query = 'select Id,Email,Lead_Submitter_email__c,Lead_Owner_s_Manager_s_Email__c,MobilePhone,Phone,Lead_Submitter_phone__c from Lead where IsConverted = false';
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
        List<Lead> listLead = (List<Lead>)scope;
        List<Lead> ListToUpdate = new List<Lead>();
        double y = Math.random() ; //between 0 and 1
        y = 999999999 * y;
        String index = String.valueOf(math.round(y));
        Integer count;
        if(scope!=null){
            for(Lead l: listLead){
                //l.Email = (l.Email.replace('@', '=')) + '@example.com';
                //l.Email = (l.Email.substring(2,9).replace('@', '=')).reverse() + '@example.com';
                if(l.Email != null)
                {
                    l.Email = (l.Email.replace('@', '=')).reverse() + '@example.com';
                }
                l.FirstName = 'XXXX';
                l.LastNAme = 'XXXXX';
                if(l.Lead_Submitter_email__c != null)
                {
                  //l.Lead_Submitter_email__c = (l.Lead_Submitter_email__c.substring(2,9).replace('@', '=')).reverse() + '@example.com';
                   l.Lead_Submitter_email__c = (l.Lead_Submitter_email__c.replace('@', '=')).reverse() + '@example.com';
                }
                if(l.Lead_Owner_s_Manager_s_Email__c != null)
                {
                  //l.Lead_Owner_s_Manager_s_Email__c = (l.Lead_Owner_s_Manager_s_Email__c.substring(2,9).replace('@', '=')).reverse() + '@example.com';
                   l.Lead_Owner_s_Manager_s_Email__c = (l.Lead_Owner_s_Manager_s_Email__c.replace('@', '=')).reverse() + '@example.com';
                }
                if(l.Phone != null && l.Phone.length()>3)
                {
                    count = l.Phone.length() - 3;
                    l.phone = l.phone.replace(l.Phone.right(count),index.left(count));
                }
                if(l.MobilePhone != null && l.MobilePhone.length()>3)
                {
                    count = l.MobilePhone.length() - 3;
                    l.MobilePhone = l.MobilePhone.replace(l.MobilePhone.right(count),index.left(count));
                }
                if(l.Lead_Submitter_phone__c != null && l.Lead_Submitter_phone__c.length()>3)
                {
                    count = l.Lead_Submitter_phone__c.length() - 3;
                    l.Lead_Submitter_phone__c = l.Lead_Submitter_phone__c.replace(l.Lead_Submitter_phone__c.right(count),index.left(count));
                }
                ListToUpdate.add(l);
            }
        }
        if(ListToUpdate.size()>0){
            //Update all Leads that can be updated
            database.update(ListToUpdate,false);
        }
    }

    Public void finish(Database.BatchableContext BC){
      system.debug('***** BatchModifySandboxLeadEmails is complete.');      
    }
}