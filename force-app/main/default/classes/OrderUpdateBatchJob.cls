global class OrderUpdateBatchJob implements Database.Batchable<sObject> {
    decimal count;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([select id, Number_of_orders_last_12_months__c,Has_Orders__c from Account where Number_of_orders_last_12_months__c != null]);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> AccList) {
        
        for(Account acc: AccList){
            list<order> countList = [select id,CreatedDate from order where (Last_12_Months__c = true and accountid =: acc.id) ORDER BY CreatedDate DESC];
            count = countList.size();
             
            acc.Number_of_orders_last_12_months__c = count;
            if(count > 0){
                acc.Has_Orders__c = true;
                DateTime dT = countList[0].CreatedDate;
                acc.Date_for_latest_order__c = date.newinstance(dT.year(), dT.month(), dT.day());
            }
            else {
                acc.Has_Orders__c = false;
                acc.Date_for_latest_order__c = null;
            }
            
        }
        try{
            update AccList;
        }catch(Exception e){
            system.debug('Exception -- >'+ e);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}