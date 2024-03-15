global class MCOnline_BatchToRetrySubmitOrder_V2 implements Database.Batchable<sObject>,Schedulable, Database.AllowsCallouts, Database.Stateful {
    DateTime lastNthDays;
    List<String> errorList = new List<String>();
    global List<Order> start(Database.BatchableContext BC){
        Integer numberOfDays = -3;
        lastNthDays = DateTime.Now().addDays(numberOfDays);
        //system.debug('lastNthDays ==>'+lastNthDays);
        List<Order> orderList = [SELECT id,MCOnline_Number_Of_Retry__c,MCOnline_OrderNumber__c,vlocity_cmt__OrderStatus__c,MCONL_Order_Activation_Status_Code__c,OrderProcessor_Response__c, OrderProcessor_Response_Message__c, OrderProcessor_ResponseStatusCode__c from Order WHERE CreatedDate >= :lastNthDays AND vlocity_cmt__OrderStatus__c!='ACTIVATED'AND MCOnline_OrderNumber__c!=Null AND vlocity_cmt__OrderStatus__c!='Retry Failed'];
        //system.debug('orderListd size==>'+orderList.size());
        return orderList;
   }
    global void execute(Database.BatchableContext BC,List<Order> orderList){
        try{
            if(orderList!=null){
                List<Id> orderNumList = new List<Id>();
                List<Id> orders = new List<Id>();
                for(Order orderRecord : orderList){
                  if(orderRecord.vlocity_cmt__OrderStatus__c!='ACTIVATED'){
                       orderNumList.add(orderRecord.Id);
                  }
              }
                List<MCOnline_ParentBasket__c> pBasketList= [select id,Order__r.id,Order__r.MCOnline_Number_Of_Retry__c,Order__r.vlocity_cmt__OrderStatus__c,UpdateOrderRequest__c from MCOnline_ParentBasket__c where Order__r.id IN: orderNumList];
                List<MCOnline_ParentBasket__c> pBasToUpdate = new List<MCOnline_ParentBasket__c>();
                List<Order> orderToUpdate = new List<Order>();  
                for(MCOnline_ParentBasket__c pBas : pBasketList){
                  //System.debug('pBas == >'+pBas);
                  Integer retryCount = 0;
                  string requestBodyToBeUpdated = pBas.UpdateOrderRequest__c;
                  String ordId = pBas.Order__r.id;
                  if(pBas.Order__r.vlocity_cmt__OrderStatus__c != 'Retry Failed'){
                      if(orderNumList.contains(pBas.Order__r.id)){
                            Order ordUp = new Order();
                            if(pBas.Order__r.MCOnline_Number_Of_Retry__c ==Null){
                                retryCount = 1;
                            }else if((pBas.Order__r.MCOnline_Number_Of_Retry__c).intValue()==3){
                                retryCount = (pBas.Order__r.MCOnline_Number_Of_Retry__c).intValue();
                                ordUp.vlocity_cmt__OrderStatus__c = 'Retry Failed';
                            }else{
                                retryCount = (pBas.Order__r.MCOnline_Number_Of_Retry__c).intValue()+1;  
                            }
                            if(ordUp.vlocity_cmt__OrderStatus__c != 'Retry Failed'){
                                ordUp.vlocity_cmt__OrderStatus__c = 'Retry';
                            }
                            ordUp.id = pBas.Order__r.id;
                            ordUp.MCOnline_Number_Of_Retry__c = (Decimal)(retryCount);
                            orderToUpdate.add(ordUp);
                          
                            //System.debug('ordUp ==>'+ordUp);
                      }

                      //MCONL_ProcessBasket_V2.InvokeUpdateOrder_IntegrationProcedure(ordId,requestBodyToBeUpdated);

                  }
              }  
                Database.update(orderToUpdate);
            }
        }catch(Exception e){
            //system.debug('Exception : '+e.getStackTraceString());
            errorList.add(e.getStackTraceString());
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        Database.executeBatch((new MCOnline_BatchToRetrySubmitOrder_V2()),1);    
    }
}