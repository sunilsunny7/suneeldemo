@isTest
public class Test_MC_OpportunityCustomButtonPopop {
	 @testSetup static void setup() {
        User salesManager1;
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager1 = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager1.Bypass_VR__c = true;
            insert salesManager1;
        }
        System.runAs(salesManager1){
            Account acc = Test_DataFactory.createOneAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Kvalificera';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            opp.AccountId = acc.Id;
            insert opp; 
        }
     }
    testMethod public static void test_fetchAccount(){
        Opportunity opp = [select id from Opportunity limit 1];
        String accId = MC_OpportunityCustomButtonPopup.getAccountId((String)opp.Id);
    }
    
}