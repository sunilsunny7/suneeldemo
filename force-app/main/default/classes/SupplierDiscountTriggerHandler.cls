/**
    About
    -----
    Description: SupplierDiscountTriggerHandler on SupplierDiscount__c
    Create date: 18.08-2016

    Update History
    --------------
    Created Aug 2016 - A.N
    
*/

public class SupplierDiscountTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public SupplierDiscountTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeDelete(List<SupplierDiscount__c> oldList, Map<ID, SupplierDiscount__c> oldMap){
        System.debug('SupplierDiscountTriggerHandler.OnBeforeDelete starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        hasRelatedSupplierDiscountOppLinks(oldList, oldMap);
    }

    private static void hasRelatedSupplierDiscountOppLinks(List<SupplierDiscount__c> oldList, Map<ID, SupplierDiscount__c> oldMap){
    	if(SEUtility.isBypassValidation()){ return; } // If user has bypass validation permission, allow deletion of Supplier Discounts with 
    	
    	for(SupplierDiscount__c sup : [SELECT Id, (SELECT Id FROM DealregEffect__r) FROM SupplierDiscount__c WHERE Id IN :oldList]){
    		if(!sup.DealregEffect__r.isEmpty()){
    			oldMap.get(sup.Id).addError(System.Label.DealReg_Validation_Msg_No_Delete_If_Linked_Opps);
    		}
    	}
    }

}