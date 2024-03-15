@isTest
public class Test_OperatingCntrl {
    
    static testMethod void testcontroller() {
        Account Acc = new Account(Name='TestCOMAccount',CM_Final_Traffic_Marketing__c = 'denied',CM_Final_Traffic_Service_Network__c = 'denied',Consent_Updated__c ='2018-02-01 15:10:45');
        insert acc;
        Opportunity oppObj = Test_DataFactory.createLargeOpportunity();
        oppObj.AccountId = acc.Id;
        insert oppObj;
        OperatingController controller = new OperatingController(new ApexPages.StandardController(oppObj));
    }
}