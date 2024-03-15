/**
    About
    -----
    Description: SupplierDiscountOppLinkTriggerHandler on Supplier_Discount_Oppportunity_Link__c
    Create date: 21.06-2016

    Update History
    --------------
    Created June 2016 - A.N - Created  
    Updated 14th Feb 2017 - S.S , updated method setOppNumberOnDealreg to include oppty name along with oppty number in Dealreg object  

    Naming Conventions
    ------------------
    dealregEffect   - Supplier_Discount_Oppportunity_Link__c custom object
    dealreg         - SupplierDiscount__c custom object
    
    
*/

public class SupplierDiscountOppLinkTriggerHandler {

    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    /* * SupplierDiscountOppLinkTriggerHandler Trigger Calls * */
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public SupplierDiscountOppLinkTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(List<Supplier_Discount_Oppportunity_Link__c> newList, Map<ID, Supplier_Discount_Oppportunity_Link__c> newMap){
        System.debug('SupplierDiscountOppLinkTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        setOppNumberOnDealreg(newList);
    }

    public void OnAfterUpdate(List<Supplier_Discount_Oppportunity_Link__c> newList, Map<ID, Supplier_Discount_Oppportunity_Link__c> newMap, List<Supplier_Discount_Oppportunity_Link__c> oldList, Map<ID, Supplier_Discount_Oppportunity_Link__c> oldMap){
        System.debug('SupplierDiscountOppLinkTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        setOppNumberOnDealreg(newList);
    }

    public void OnAfterDelete(List<Supplier_Discount_Oppportunity_Link__c> oldList, Map<ID, Supplier_Discount_Oppportunity_Link__c> oldMap){
        System.debug('SupplierDiscountOppLinkTriggerHandler.OnAfterDelete starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        setOppNumberOnDealreg(oldList);
    }

    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    /* * SupplierDiscountOppLinkTriggerHandler Trigger Methods * */
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    private static void setOppNumberOnDealreg(List<Supplier_Discount_Oppportunity_Link__c> newList){
        Set<Id> dealregIds = new Set<Id>();
        for(Supplier_Discount_Oppportunity_Link__c dealregEffect : newList){
            if(dealregEffect.Supplier_Discount_Deal__c != null){
                dealregIds.add(dealregEffect.Supplier_Discount_Deal__c);
            }
        }

        if(!dealregIds.isEmpty()){
            List<SupplierDiscount__c> dealregsList = [SELECT Id, Opportunity_Numbers__c, 
                (SELECT Id, Opportunity__r.Opportunity_id__c, Opportunity__r.Name FROM DealregEffect__r) 
                FROM SupplierDiscount__c WHERE Id in :dealregIds];
            if(dealregsList.size() > 0){
                for(SupplierDiscount__c dealreg : dealregsList){
                    dealreg.Opportunity_Numbers__c = '';
                    for(Supplier_Discount_Oppportunity_Link__c dealregEffect : dealreg.DealregEffect__r){
                        dealreg.Opportunity_Numbers__c += dealregEffect.Opportunity__r.Opportunity_id__c + ' - ' + dealregEffect.Opportunity__r.Name + '\r\n';
                    }
                }
                update dealregsList;
            }
        }
    }
}