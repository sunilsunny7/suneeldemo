@isTest
public class MC_AccessRequestTriggerHandlerTest {
    
    @isTest
    private static void updateRecordTypeTest(){
        
        //Creating Sample Data
        List<MC_Access_Request__c> newAccessRequest = new List<MC_Access_Request__c>();
        
        for(integer i=0; i<2; i++){
            MC_Access_Request__c accessRequest = new MC_Access_Request__c();
            accessRequest.MC_Reason_for_request__c = 'Test';
            accessRequest.MC_Stream__c = 'MC Sales';
            accessRequest.MC_Approver__c = 'Mihir Joshi';
            newAccessRequest.add(accessRequest);
        }
        
        //Inserting Data
        Test.startTest();
        insert newAccessRequest;
        Test.stopTest();
        
        //Assertion
        ID rId = [SELECT ID FROM RecordType WHERE Name = 'MC_Access_Request_Final'].id;
        List<MC_Access_Request__c> updatedAccessRequest = [SELECT Id,RecordTypeId FROM MC_Access_Request__c WHERE Id =: newAccessRequest[0].id];
        
        System.assertEquals(rId,updatedAccessRequest[0].RecordTypeId);
    }
}