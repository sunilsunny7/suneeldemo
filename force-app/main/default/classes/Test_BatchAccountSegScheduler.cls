@isTest
public class Test_BatchAccountSegScheduler {
public static testMethod void testschedule() {

Test.StartTest();
BatchAccountSegScheduler sh1 = new BatchAccountSegScheduler();

String sch = '0 0 23 * * ?'; 
system.schedule('Test Scheduler', sch, sh1); 
Test.stopTest(); 
}
}