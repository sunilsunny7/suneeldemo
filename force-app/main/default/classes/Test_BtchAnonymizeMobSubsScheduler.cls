@isTest
public class Test_BtchAnonymizeMobSubsScheduler {
public static testMethod void testschedule() {

Test.StartTest();
BtchAnonymizeMobSubsScheduler sh1 = new BtchAnonymizeMobSubsScheduler();

String sch = '0 0 23 * * ?'; 
system.schedule('Test Scheduler', sch, sh1); 
Test.stopTest(); 
}
}