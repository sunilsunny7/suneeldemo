public class BatchModifySandboxMobileSubscrptions implements Database.Batchable<sObject>{
    Public Database.QueryLocator start(Database.BatchableContext BC){
        //exclude all Mobile subscriptions without numbers if any
        String query = 'select Id,Name from Mobile_Subscription__c where Name != null';
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
        List<Mobile_Subscription__c> listMobSub = (List<Mobile_Subscription__c>)scope;
        List<Mobile_Subscription__c> ListToUpdate = new List<Mobile_Subscription__c>();
        double y = Math.random() ; //between 0 and 1
        y = 999999999 * y;
        String index = String.valueOf(math.round(y));
        Integer count;
        if(scope!=null){
            for(Mobile_Subscription__c m:listMobSub){
               
                if(m.Name != null && m.Name.length()>3)
                {
                    count = m.Name.length() - 3;
                    m.Name = m.Name.replace(m.Name.right(count),index.left(count));
                }
                ListToUpdate.add(m);                    
            }
        }
        if(ListToUpdate.size()>0){
            //Update all Mobile Subscritions that can be updated
            system.debug('Mobile Subscriptions : ' +ListToUpdate);
            database.update(ListToUpdate,false);
        }
    }

    Public void finish(Database.BatchableContext BC){
        system.debug('***** BatchModifySandboxMobileSubscrptions is complete.');    
    }
}