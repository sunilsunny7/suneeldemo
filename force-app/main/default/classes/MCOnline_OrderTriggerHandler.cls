/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @version                1.0
* @created                2021-08-20
* @modified               2021-08-20
******************************************************************************************************************************/

public without sharing class MCOnline_OrderTriggerHandler {
    public static void handerMethod(List<Order> oldList,List<Order> newList,Map<Id,Order> oldMap,Map<Id,Order> newMap,System.TriggerOperation operation)
    {
        switch on operation {
            when AFTER_UPDATE {
                publishEvent(newList,oldMap,newMap);
            }
        }
    }


    private static void publishEvent(List<Order> newList,Map<Id,Order> oldMap,Map<Id,Order> newMap)
    {
        List<Id> orderIds=new List<Id>();
        List<MCOnline_OrderData__e> publishEvents = new List<MCOnline_OrderData__e>();
        for(Order order:newList)
        {
            if(order.OrderProcessor_Request__c!='' && oldMap.get(order.Id).OrderProcessor_Request__c!=newMap.get(order.Id).OrderProcessor_Request__c)
            {  
                orderIds.add(order.Id);
            }
        }
        if(orderIds.size()>0)
        {
            Map<Id,String> basketMap=new Map<Id,String>();
            List<MCOnline_Basket__c> baskets=[select id,MCOnline_Orders__c,MCOnline_Checkout_Received_Time__c from MCOnline_Basket__c  where MCOnline_Orders__c =:orderIds];
            for(MCOnline_Basket__c basket:baskets)
            {
                basketMap.put(basket.MCOnline_Orders__c,String.valueOf(basket.MCOnline_Checkout_Received_Time__c));
            } 
            for(Id id:orderIds)
            {
                if(newMap.get(id).OrderProcessor_Request__c !=null)
                {
                    MCOnline_OrderData__e event=new MCOnline_OrderData__e();
                    Map<String,Object> jsonData=(Map<String,Object>)JSON.deserializeUntyped(newMap.get(id).OrderProcessor_Request__c);
                    jsonData.put('createDate',basketMap.get(id)+'');
                    jsonData.put('SubmittedToOmDate',String.valueOf(DateTime.now()));
                    
                    event.MCOnline_Payload__c =JSON.serialize(jsonData);
                    publishEvents.add(event);
                }
                
            }      
            if(publishEvents.size()>0){
                List<Database.SaveResult> results=EventBus.publish(publishEvents);
                
            }
        }
    }
}