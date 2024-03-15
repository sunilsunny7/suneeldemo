global class MCOnline_UpdateCancelledProducts implements Schedulable {
	global void execute(SchedulableContext sc) { 
        Services_cancelled_in_MyBusiness__c cp = null;
        string str = '';
      List<Services_cancelled_in_MyBusiness__c> cproducts = new List<Services_cancelled_in_MyBusiness__c>();
      List<OrderItem> oitem = [select id,MCONL_Action_Code__c ,Order.OrderNumber,OrderId,  Product2.Name, CreatedDate,Quantity, Order.AccountId,Order.MCOnline_FirstName__c, order.MCOnline_LastName__c from OrderItem where MCONL_Action_Code__c = 'Delete'];
		if(!oitem.isEmpty()){
            for(OrderItem pr:oitem){
                cp = new Services_cancelled_in_MyBusiness__c();
                cp.Quantity__c = pr.Quantity;
                cp.Cancelled_Date__c = pr.CreatedDate;
                cp.Order__c = pr.OrderId;
                cp.Product__c = pr.Product2Id;
                cp.Account__c = pr.Order.AccountId;
                str = pr.Order.MCOnline_FirstName__c+' '+pr.order.MCOnline_LastName__c;
                cp.User__c = str;
                cproducts.add(cp);
            }
            insert cproducts;
		}
   }   
}