/**
About
-----
Description: TriggerHandler on AccountContactRelation
Create date: 10.12.2016

Update History
--------------
    Created Dec 2016 - A.N. SAEN-2116 added method setRoleFromContact

*/

public class AccountContactRelationTriggerHandler {

    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    /* * AccountContactRelationTriggerHandler Trigger Calls  * */
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    private Boolean m_isExecuting = false;
    private Integer batchSize = 0;

    public AccountContactRelationTriggerHandler(Boolean isExecuting, Integer size){
        m_isExecuting = isExecuting;
        batchSize = size;
    }

    public void OnBeforeInsert(List<AccountContactRelation> newList, Map<Id, AccountContactRelation> newMap){
        System.debug('AccountContactRelationTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        setRoleFromContact(newList);
    }

    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    /* * AccountContactRelationTriggerHandler Trigger Methods  * */
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    // Author A.N
    // When a new AccountContactRelationTriggerHandler is created and this is the primary relationship,
    // copy the Role from Contact to the AccountContactRelation
    private static void setRoleFromContact(List<AccountContactRelation> newList){
    	Set<Id> conIds = new Set<Id>();
    	for(AccountContactRelation acr : newList) conIds.add(acr.ContactId);

    	Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id, Role__c FROM Contact WHERE Id in :conIds]);
    	for(AccountContactRelation acr : newList){
    		if(acr.IsDirect && conMap.containsKey(acr.ContactId)){
    			acr.Role__c = conMap.get(acr.ContactId).Role__c;
    		}
    	}
    }
}