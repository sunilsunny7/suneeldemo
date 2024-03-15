public class BatchModifySandboxCallActivity implements Database.Batchable<sObject>{
    Public Database.QueryLocator start(Database.BatchableContext BC){
        //exclude all Call Activities without numbers if any
        String query = 'select Id,Contact_Mobile__c,Contact_Phone_1__c,Contact_Phone_2__c from Call_Activity__c where (Contact_Mobile__c != null) OR (Contact_Phone_1__c != null) OR (Contact_Phone_2__c != null)';
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
        List<Call_Activity__c> listCallAct= (List<Call_Activity__c>)scope;
        List<Call_Activity__c> ListToUpdate = new List<Call_Activity__c>();
        double y = Math.random() ; //between 0 and 1
        y = 999999999 * y;
        String index = String.valueOf(math.round(y));
        Integer count;
        if(scope!=null){
            for(Call_Activity__c m:listCallAct){
               
                if(m.Contact_Mobile__c != null && m.Contact_Mobile__c.length()>3)
                {
                    count = m.Contact_Mobile__c.length() - 3;
                    m.Contact_Mobile__c = m.Contact_Mobile__c.replace(m.Contact_Mobile__c.right(count),index.left(count));
                }
                 if(m.Contact_Phone_1__c != null && m.Contact_Phone_1__c.length()>3)
                {
                    count = m.Contact_Phone_1__c.length() - 3;
                    m.Contact_Phone_1__c = m.Contact_Phone_1__c.replace(m.Contact_Phone_1__c.right(count),index.left(count));
                }
                if(m.Contact_Phone_2__c != null && m.Contact_Phone_2__c.length()>3)
                {
                    count = m.Contact_Phone_2__c.length() - 3;
                    m.Contact_Phone_2__c = m.Contact_Phone_2__c.replace(m.Contact_Phone_2__c.right(count),index.left(count));
                }
                
                ListToUpdate.add(m);                    
            }
        }
        if(ListToUpdate.size()>0){
            //Update all Call Activities that can be updated
            system.debug('Call Activities : ' +ListToUpdate);
            database.update(ListToUpdate,false);
        }
    }

    Public void finish(Database.BatchableContext BC){
        system.debug('***** BatchModifySandboxMobileSubscrptions is complete.');    
    }
}