@istest
public class Test_FiberSchedulingClass {
    
    public static testmethod void testschedule()
    {
        Test.startTest();
        FiberSchedulingClass testsche = new FiberSchedulingClass();
        String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
        
    }
}