@isTest
public class Test_LeadConvertController {
    @isTest
    static void testWrapperMethod() {
        Database.LeadConvertResult dbrslt;
        LeadConvertController.ActionStatus lc = new LeadConvertController.ActionStatus();
        lc.ErrorMessage = 'Test Error Log';
        lc.IsSuccess = true;
        lc.ReturnData = dbrslt;
    }
    @isTest
    static void testConvertLead() {
        System.runAs(Test_DataFactory.getByPassUser()) {
            Lead testLead = Test_DataFactory.createLead();
            Account AccObj = Test_DataFactory.createOneAccount();
            insert AccObj;
            testLead.Account__c = AccObj.Id;
            insert testLead;
            Buy_Interest__c buyObj = new Buy_Interest__c();
            buyObj.Name = 'TestBuyInterestName';
            buyObj.Lead__c = testLead.Id;
            buyObj.Lead_Source__c = 'ÅF';
            buyObj.Status__c = 'Nytt';
            insert buyObj;
            Contact testContact = Test_DataFactory.createOneContactWithAccount();
            insert testContact;

            Test.startTest();
            String result = LeadConvertController.convertLead(testLead.Id, AccObj.Id, 'testoppName', buyObj.Id, 'recordType', testContact.Id, true);
            LeadConvertController.getLead(testLead.Id);
            LeadConvertController.getDuplicateContacts('test@dummy.com');
            LeadConvertController.getBuyInterests (testLead.Id);
            LeadConvertController.getOpportunityRecordTypes();
            Test.stopTest();

            System.assertNotEquals(null, result);
        }
    }

    @isTest
    static void testConvertLeadNegativeTest() {
        System.runAs(Test_DataFactory.getByPassUser()) {
            Lead testLead = Test_DataFactory.createLead();
            Account AccObj = Test_DataFactory.createOneAccount();
            insert AccObj;
            testLead.Account__c = AccObj.Id;
            insert testLead;
            Buy_Interest__c buyObj = new Buy_Interest__c();
            buyObj.Name = 'TestBuyInterestName';
            buyObj.Lead__c = testLead.Id;
            buyObj.Lead_Source__c = 'ÅF';
            buyObj.Status__c = 'Nytt';
            insert buyObj;
            Contact testContact = Test_DataFactory.createOneContactWithAccount();
            insert testContact;

            Test.startTest();
            String result = LeadConvertController.convertLead(testLead.Id, testContact.Id, '', buyObj.Id, 'recordType', testContact.Id, true);
            Test.stopTest();

            System.assertNotEquals(null, result);
        }
    }

    @isTest
    static void testBlockLead() {
        System.runAs(Test_DataFactory.getByPassUser()) {
            Lead testLead = Test_DataFactory.createLead();
            Account AccObj = Test_DataFactory.createOneAccount();
            insert AccObj;
            testLead.Account__c = AccObj.Id;
            insert testLead;
            Contact testContact = Test_DataFactory.createOneContactWithAccount();
            testContact.recordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_TELIA_USER);
            insert testContact;
            Buy_Interest__c buyObj = new Buy_Interest__c();
            buyObj.Name = 'TestBuyInterestName';
            buyObj.Lead__c = testLead.Id;
            buyObj.Lead_Source__c = 'ÅF';
            buyObj.Status__c = 'Nytt';
            buyObj.Buy_Interest_Submitter__c = testContact.Id;
            insert buyObj;

            Test.startTest();
            String result = LeadConvertController.convertLead(testLead.Id, AccObj.Id, '', buyObj.Id, 'recordType', testContact.Id, true);
            Test.stopTest();

            System.assertNotEquals(null, result);
        }
    }

    @isTest
    static void testConvertFiberLead() {
        System.runAs(Test_DataFactory.getByPassUser()) {
            Lead testLead = Test_DataFactory.createLead();
            Account AccObj = Test_DataFactory.createOneSMEAccount();
            insert AccObj;
            testLead.Account__c = AccObj.Id;
            insert testLead;
            Buy_Interest__c buyObj = new Buy_Interest__c();
            buyObj.Name = 'TestBuyInterestName';
            buyObj.Lead__c = testLead.Id;
            buyObj.Lead_Source__c = 'ÅF';
            buyObj.Status__c = 'Nytt';
            buyObj.Number_of_Facilities__c = 100;
            buyObj.Number_of_Ports__c = 100;
            buyObj.Number_of_Premises__c = 100;
            buyObj.Number_of_Households__c = 100;
            insert buyObj;
            Contact testContact = Test_DataFactory.createOneContactWithAccount();
            insert testContact;

            Test.startTest();
            LeadConvertController.isFiberProfile();
            String result = LeadConvertController.convertFiberLead(testLead.Id, AccObj.Id, 'testOppName', buyObj.Id, 'recordType', testContact.Id, true);
            List<ID> convertedLeadIds = new List<ID>();
            convertedLeadIds.add(testLead.id);
            LeadConvertController.transferLeadValues(convertedLeadIds);

            LeadConvertController.getLead(testLead.Id);
            LeadConvertController.getDuplicateContacts('test@dummy.com');
            LeadConvertController.getBuyInterests (testLead.Id);
            LeadConvertController.getOpportunityRecordTypes();
            Test.stopTest();

            System.assertNotEquals(null, result);
        }
    }

}