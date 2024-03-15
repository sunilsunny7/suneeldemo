/**
 * Created by uly8476 on 2021-09-29.
 */

@IsTest
private class ReturnLcComponentControllerTest {
    @IsTest
    static void getLCQueueId_Test() {
        Test.startTest();
            Id LCQueueId = ReturnLcComponentController.getLCQueueId();
        Test.stopTest();
        
        System.assertNotEquals(null,LCQueueId);
    }
}