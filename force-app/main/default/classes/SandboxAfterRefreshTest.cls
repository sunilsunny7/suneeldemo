@isTest
class SandboxAfterRefreshTest {
    
    @isTest
    static void testSandboxAfterRefresh()   {
        
        Account testAccount = new Account(name = 'Test Account',website = 'http://www.example.com');
        insert testAccount;
        Contact testContact = new Contact(firstname = 'John',lastname = 'Smith',email = 'john@smith.com', accountId = testAccount.Id, phone = '+46704567890', mobilephone = '+46704567890');
        insert testContact;
        Lead testLead = new Lead(firstname = 'Jane',lastname = 'Doe',email = 'jane@doe.com',MobilePhone = '1234567890',phone = '1234567890', company = 'Test Company',status = 'Open',LeadSource = 'Prospecting');
        insert testLead;
        Mobile_Subscription__c testMobSub = new Mobile_Subscription__c(name = '1234567890', Account__c = testAccount.Id);
        insert testMobSub;
        Campaign cam = new Campaign();
        cam.name = 'Testing';
        cam.type = 'SMS';
        insert cam;
        Call_Activity__c callAct = Test_DataFactory.createCallActivity(cam.Id,testAccount.Id);
        callAct.Contact_Mobile__c = '1234567890';
        insert callAct;
        
        Case case1 = new Case();            
            case1.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case1.Subject = 'this should 1234567890 work';
            case1.SuppliedEmail = 'jane@doe.com';
            case1.SuppliedPhone = '1236789012';
            case1.Enterprise_Case_Notification_Email__c = 'jane123@doe.com';
            insert case1;
        
        List<Organization> org = ([select id from Organization limit 1]);
                
        Test.startTest();
            Test.testSandboxPostCopyScript(new SandboxAfterRefresh(), org[0].Id, org[0].Id, 'TestSandbox');
        Test.stopTest();
        
        Contact c = [Select email from Contact limit 1];
        Lead l = [Select email from Lead limit 1];
       
        //System.assert(c.Email.endsWith('@example.com'));
       //System.assert(l.Email.endsWith('@example.com'));
       
    }
}