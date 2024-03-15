@isTest
public class Test_SchBtchToPurgeContacts  {
public static testMethod void testschedule() {

Test.StartTest();
SchBtchToPurgeContacts sh1 = new SchBtchToPurgeContacts();

String sch = '0 0 23 * * ?'; 
system.schedule('Test Scheduler', sch, sh1); 
Test.stopTest(); 
}
}