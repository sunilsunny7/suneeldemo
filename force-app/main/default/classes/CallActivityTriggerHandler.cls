public class CallActivityTriggerHandler {
     private Boolean m_isExecuting = false;
    private Integer BatchSize = 0;

    public CallActivityTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(List<Call_Activity__c> newList, Map<ID, Call_Activity__c> newMap){ 
        System.debug('CallActivityTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
   
    }

    public void OnAfterInsert(List<Call_Activity__c> newList, Map<ID, Call_Activity__c> newMap){
        System.debug('CallActivityTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
    }

    public void OnBeforeUpdate(List<Call_Activity__c> newList, Map<ID, Call_Activity__c> newMap, List<Call_Activity__c> oldList, Map<ID, Call_Activity__c> oldMap){
        System.debug('CallActivityTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
            
    }

    public void OnAfterUpdate(List<Call_Activity__c> newList, Map<ID, Call_Activity__c> newMap, List<Call_Activity__c> oldList, Map<ID, Call_Activity__c> oldMap){
        System.debug('CallActivityTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
         HasCampaignContact(newMap, oldMap);
    }

    public void OnAfterDelete(List<Call_Activity__c> oldList, Map<ID, Call_Activity__c> oldMap){
        System.debug('CallActivityTriggerHandler.OnAfterDelete starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
    }
    
    public void HasCampaignContact(Map<ID, Call_Activity__c> newMap, Map<ID, Call_Activity__c> oldMap){
        //AccountId, Call_Activity__c
        Map<Id, Call_Activity__c> accCAMap = new Map<Id, Call_Activity__c>();
        Set<Id> campaignSet = new Set<Id>();
        
        //Map Account and Call_Activity__c  
        for(Call_Activity__c ca :newMap.values()){
            if(ca.Call_Status__c == TaskTriggerHandler.STATUS_CONTACTED && ca.Campaign__c != null && ca.Account__c != null && 
               (!ca.Is_PR_Not_Interested__c  && oldMap.get(ca.Id).Is_PR_Not_Interested__c == ca.Is_PR_Not_Interested__c)){
                accCAMap.put(ca.Account__c, ca);
                campaignSet.add(ca.Campaign__c);
            }
        }

        if(!accCAMap.isEmpty()){           
            //Get all relevant Contacts
            Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, Name, Email, Phone, AccountId FROM Contact WHERE AccountId IN :accCAMap.keySet()]); 
            
            //Map Account to all Campaign Members
            //AccountId, Contact
            Map<Id, Contact> accConMember = new Map<Id, Contact>();
            for(Contact c :[SELECT Id, AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM CampaignMember WHERE ContactId IN :contacts.keyset() AND CampaignId IN :campaignSet)]){
                accConMember.put(c.AccountId, c);
            }
            
            //Check if the Call Activity Account has a Campaign Member
            for(Id accId : accCAMap.keySet()){
                if(accConMember.get(accId) == null){
                    newMap.get(accCAMap.get(accId).Id).addError(Label.caValidationContacted);
                }
            }
        }
    }
}