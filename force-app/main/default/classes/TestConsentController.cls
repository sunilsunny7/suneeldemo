@isTest
public class TestConsentController {
    
    @testSetup static void setup() {
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i,Consent_Updated__c ='2018-02-01 15:10:45',Org_Nr__c='123456789'+i));
        }
        insert testAccts;        
    }
    static testMethod void testcontroller() {
        Account Acc = new Account(Name='TestCOMAccount',Consent_Updated__c ='2018-02-01 15:10:45');
        insert Acc;
        ConsentController con = new ConsentController();
        ConsentController.getAccount(acc.Id);
        ConsentController.updateconsent(acc.Id,'TestName','TestRole');
    }
    static testMethod void testOpptyData() {
        Account AccRec = new Account(Name='TestRecordAccount',Org_Nr__c = '123466690',Consent_Updated__c ='2018-02-01 15:10:45');
        insert AccRec;
        List <Opportunity> oppty = Test_DataFactory.createOpportunitiesFromAccount(2,AccRec.Id);
        insert oppty;
        ConsentController.getId(oppty[0].Id);
    }
    
    static testMethod void testCalloutMethod() { 
        Account acct = [SELECT Id FROM Account LIMIT 1];
        system.debug('(((('+acct);
        ApexDataContainer testcontainer = ConsentController.getc2bData(acct.Id);
    }
    
    static testMethod void settestCalloutMethod() { 
        String condata1 = TestWrapperClassConsent.testApxContainer();
        system.debug('condata1:-'+condata1);
        String condata2 = TestWrapperClassConsent.testApxContainer2();
        ConsentController.setConsenttoC2b(condata1,condata2,'testProxy','testRole','1234789');
    }
    
    static testMethod void responseclswrapper() { 
        TestWrapperClassConsent.testReqClsWrapper();
    }
}