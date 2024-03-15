/******************************************************************************************************
* @author         Lokesh Singh
* Maintained by   /Lokesh Singh
* @version        1.0
* @created        2023-08-31
* @modified       2023-0- 31
* Story           LTAT-15927
*/ 
@isTest
public class MCOnline_EmailNotificationTest {
    @isTest
    public static void MCOnline_PrsimaBatchMethod() {
        List<MC_AgreementPlanChange__c> testRecords = new List<MC_AgreementPlanChange__c>();         
        MC_AgreementPlanChange__c agr = new MC_AgreementPlanChange__c();
        agr.MC_AgreementNumber__c = '113868';
        agr.MC_PricePlan__c = null;
        agr.MC_PricePlanCategory__c = null;
        agr.MC_PricePlanType__c = 'MOBILL';
        agr.MC_AgreementNumber__c=null;
        agr.MC_DateFrom__c = '2022-03-12 00:00:00';
        agr.MC_SubscriptionType__c = 'XÖ';
        agr.createddate= system.today()-1;
        testRecords.add(agr);
        insert testRecords;        
        Test.startTest();
        MCOnline_EmailNotificationPrsimaBatch batchObj = new MCOnline_EmailNotificationPrsimaBatch();
        Database.executeBatch(batchObj);
        Test.stopTest();       
    }   
    @isTest
    public static void MCOnline_PrsimaBatchMethod1() {
        List<MC_AgreementPlanChange__c> testRecords = new List<MC_AgreementPlanChange__c>();
        list<MC_PrismaPlan__c> lstPrisPlan= new list<MC_PrismaPlan__c>();
        MC_AgreementPlanChange__c agr1 = new MC_AgreementPlanChange__c();
        agr1.MC_AgreementNumber__c = '113868';
        agr1.MC_PricePlan__c = 'ij89';
        agr1.MC_PricePlanCategory__c = '898';
        agr1.MC_PricePlanType__c = 'MOBILL';
        agr1.MC_AgreementNumber__c='3823';
        agr1.MC_DateFrom__c = '2022-03-12 00:00:00';
        agr1.MC_SubscriptionType__c = 'XÖ';
        agr1.createddate= system.today()-1;
        testRecords.add(agr1);
        insert testRecords;
        
        MC_PrismaPlan__c prisPlanObj = new MC_PrismaPlan__c();      
        prisPlanObj.MC_Agreement_MRC_Price__c = '264.00';
        prisPlanObj.MC_Agreement_NRC_Price__c = '0.00';
        prisPlanObj.MC_ServiceCode__c = 'TJ';
        prisPlanObj.MC_ServiceValue__c = '';
        lstPrisPlan.add(prisPlanObj);
        insert lstPrisPlan;       
        test.setCreatedDate(prisPlanObj.id, date.today().Adddays(-1));    
        Test.startTest();
        MCOnline_EmailNotificationPrsimaBatch batchObj = new MCOnline_EmailNotificationPrsimaBatch();
        Database.executeBatch(batchObj);
        MCOnline_EmailNotifiBatch_schedule sh1 = new MCOnline_EmailNotifiBatch_schedule();
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }   
}