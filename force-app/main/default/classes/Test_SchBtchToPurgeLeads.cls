@isTest
public class Test_SchBtchToPurgeLeads {
public static testMethod void testschedule() {

Test.StartTest();
SchBtchToPurgeLeads sh1 = new SchBtchToPurgeLeads ();

String sch = '0 0 23 * * ?'; 
system.schedule('Test Scheduler', sch, sh1); 
Test.stopTest(); 
}
}