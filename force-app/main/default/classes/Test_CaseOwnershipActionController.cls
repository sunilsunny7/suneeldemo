@isTest
public class Test_CaseOwnershipActionController {
    
    
    @isTest static void testwrapperbethod(){
        CaseOwnershipActionController.ActionStatus lc = new CaseOwnershipActionController.ActionStatus();
        lc.ErrorMessages = 'Test Error Log';
        lc.IsSuccess = true;
        lc.SuccessMessage = 'SUCCESS MSG';
    }
    
    @isTest static void testprocessRecord(){
        Test.startTest();
        CASE case1;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, Telia_Id__c ='ZZZ123',
                          TimeZoneSidKey='America/Los_Angeles', UserName='Yestest12121212@testorg.com');
        
        System.runAs(u) {
            case1 = new CASE ();            
            case1.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case1.Subject = 'this should 1234567890 work';
            insert case1;
        }
        String result = CaseOwnershipActionController.getResult(case1.Id);
        test.stoptest();
    }
    
    @isTest static void testRecord(){
        Test.startTest();
        CASE case1;
        case1 = new CASE ();            
        case1.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
        case1.Subject = 'test description Work';
        insert case1;
        String result = CaseOwnershipActionController.getResult(case1.Id);
        test.stoptest();
    }
}