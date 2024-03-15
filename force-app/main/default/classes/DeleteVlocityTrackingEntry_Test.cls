@isTest
public class DeleteVlocityTrackingEntry_Test {
	@testSetup
    static void initTestData(){
        vlocity_cmt__VlocityTrackingEntry__c vte = new vlocity_cmt__VlocityTrackingEntry__c();
        vte.vlocity_cmt__TestResult__c = 'HardwareQuote';
        insert vte;
    }
    @istest
    public static void test1(){
        test.startTest();
        Database.executeBatch(new DeleteVlocityTrackingEntry());
        System.schedule('SampleBatchScheduler', '0 0 * * * ?', new DeleteVlocityTrackingEntry());
        test.stopTest();
    }
}