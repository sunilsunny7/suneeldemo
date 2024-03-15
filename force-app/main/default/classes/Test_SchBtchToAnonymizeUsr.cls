@isTest
public class Test_SchBtchToAnonymizeUsr  {
public static testMethod void testschedule() {

Test.StartTest();
SchBtchAnonymiseInactiveUsers sh1 = new  SchBtchAnonymiseInactiveUsers();

String sch = '0 0 23 * * ?'; 
system.schedule('Test Scheduler', sch, sh1); 
Test.stopTest(); 
}
}