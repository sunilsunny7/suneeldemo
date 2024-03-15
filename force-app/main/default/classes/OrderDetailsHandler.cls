/**
 * Created by wgj897 on 2023-08-17.
 */
public with sharing class OrderDetailsHandler extends TriggerHandler {
    @TestVisible
    String triggerCheck = Test.isRunningTest() ? 'false' :System.label.OrderTriggerFlagCheck;

    private List<Order> newList;
    private List<Order> oldList;

    public OrderDetailsHandler() {
        this.newList = (List<Order>) Trigger.new;
        this.oldList = (List<Order>) Trigger.old;
    }
    public override void afterInsert() {
        if (triggerCheck != 'true') {
            accountUpdateNumberOfOrders(newList , null);
        }
    }
    public override void afterDelete() {
        if (triggerCheck != 'true') {
            accountUpdateNumberOfOrders(null , oldList);
        }
    }
    public static void accountUpdateNumberOfOrders(List<Order > newList , List<Order > oldList) {

        Set<Id> ordAccsList = new Set<Id>();

        if(newList != null) {
            for (Order ord : newList) {
                ordAccsList.add(ord.AccountId);
            }
        }
        else if(oldList != null){
            for (Order oldOrd : oldList) {
                ordAccsList.add(oldOrd.AccountId);
            }
        }

        if (!ordAccsList.isEmpty()) {

            List<Account> accountsToUpdate = [SELECT Id , Number_of_orders_last_12_months__c , Date_for_latest_order__c, Has_Orders__c FROM Account WHERE Id IN: ordAccsList];

            for (Account acc : accountsToUpdate) {

                if (Trigger.isInsert) {
                    if(acc.Number_of_orders_last_12_months__c == null)
                    {
                      acc.Number_of_orders_last_12_months__c = 1;
                      acc.Has_Orders__c = true;
                    }
                    else{
                      acc.Number_of_orders_last_12_months__c = acc.Number_of_orders_last_12_months__c + 1;
                      acc.Has_Orders__c = true;
                    }
                    
                }

                if (Trigger.isDelete) {
                    if (acc.Number_of_orders_last_12_months__c == null) {
                        acc.Number_of_orders_last_12_months__c = 0;
                        acc.Has_Orders__c = false;

                    } else if (acc.Number_of_orders_last_12_months__c > 0) {
                        acc.Number_of_orders_last_12_months__c = acc.Number_of_orders_last_12_months__c - 1;
                        if(acc.Number_of_orders_last_12_months__c > 0){
                           acc.Has_Orders__c = true; 
                      }
                        else{
                            acc.Has_Orders__c = false; 
                        }
                    }
                }

                acc.Date_for_latest_order__c = system.today();

            }
            try {
                if (!accountsToUpdate.isEmpty()) {
                    update accountsToUpdate;
                }
            } catch (Exception ex) {
                SEUtility.errorLogging('Error' , 'OrderDetailsHandler' , 'accountUpdateNumberOfOrders' , ex);
            }
        }
    }
}