@isTest
public class Test_OrderUpdateScheduableJob {
public static testMethod void testschedule() {

Test.StartTest();
OrderUpdateScheduableJob sh1 = new OrderUpdateScheduableJob();

String sch = '0 0 23 * * ?'; 
system.schedule('Test Scheduler', sch, sh1); 
Test.stopTest(); 
}
}