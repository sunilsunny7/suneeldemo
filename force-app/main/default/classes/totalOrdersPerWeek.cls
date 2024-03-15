public class totalOrdersPerWeek {   
    public void countOrders(){
        DateTime lastNthDays;
        lastNthDays = DateTime.Now().addDays(-7);
        List<Order> inactiveOrders = [select id, OrderNumber,vlocity_cmt__OrderStatus__c,CreatedDate, Account.Name from Order where vlocity_cmt__OrderStatus__c != 'Activated' and CreatedDate >=: lastNthDays];
    }
}