global class BatchUpdateFULsforFunnel implements Database.batchable<sObject>{
    string query;
     date oneYearFromToday = date.today().adddays(364);
    
    global database.QueryLocator start(Database.BatchableContext BC){
         //string nullValueforSeller = '';
        
            
            //query = 'SELECT Id,OwnerId, CloseDate,IsClosed,Large_New_Sales__c,Seller__c,RecordTypeId FROM Opportunity WHERE Seller__c NOT =: nullValueforSeller AND CloseDate =: oneYearFromToday;
            query = 'SELECT Id,Included_in_Funnel__c,Opp_Is_Closed__c,Opportunity__c,Opportunity_Close_Date__c  FROM Funnel_Link__c WHERE Opportunity_Close_Date__c <= :oneYearFromToday';
            return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<Funnel_Link__c> listOfFUL){
    
        //List<Opportunity> listofOppRelatedFunnelforUpdate = new List<Opportunity>();
        //List<Funnel_Link__c> listofFunnelforUpdate = new List<Funnel_Link__c>();
        List<Funnel_Link__c> listFULforUpdate = new List<Funnel_Link__c>();
        
        //listofFunnelforUpdate = [SELECT Id,Included_in_Funnel__c,Opp_Is_Closed__c,Opportunity__c,Opportunity_Close_Date__c  FROM Funnel_Link__c WHERE Opportunity__C IN: listOfOpps];
        for(Funnel_Link__c ful:listofFUL){
            if(ful.Opportunity_Close_Date__c <= oneYearFromToday){
                if(ful.Included_in_Funnel__c != True){
                    ful.Included_in_Funnel__c = True;
                    listFULforUpdate.add(ful);
                }
            }
        }
        if(listFULforUpdate.size() >0 ){
            try{
                update listFULforUpdate;
            }
            catch(exception e){
                system.debug('Exception Caught' + e.getmessage());
            }
        }
    }

    global void finish(Database.BatchableContext BC){
    
    }
}