/**
 * @Author:      Surajit Pramanik
 * @Company:     Capgemini
 * @Date:        17th May, 2019
 * @Description: This Class is test class of TeliaSE_ChangeAgreementRetriggerBatch
 *
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------
*/

@isTest 
public class Test_ChangeAgreementRetriggerBatch {
    static testMethod void testMethod1() 
    {
        Test_DataFactory.setUpOrg();        
        Account acc;
		
		User salesManager; 
		System.runAs(new User(Id = Userinfo.getUserId()))
        {
            salesManager = Test_DataFactory.createAdminUser();
            salesManager.Bypass_VR__c = true;
            salesManager.FirstName = 'TestRunUser';
            salesManager.IsActive = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            
            Quote qut1 = new Quote();
            qut1.Name='Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False; 
            qut1.TeliaSE_Type__c='Renegotiation';
            insert qut1;
            
            Contract conObj = new Contract();
            conObj.vlocity_cmt__QuoteId__c=qut1.id;
            conObj.TeliaSE_Type__c = 'Renegotiation';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            insert conObj;
            
            conObj.TeliaSE_Start_Date_Flag__c  = true;
            conObj.TeliaSE_Start_Date__c = system.today();
            conObj.Status = 'Signed';
            update conObj;
        
        Test.startTest();

            TeliaSE_ChangeAgreementRetriggerBatch obj = new TeliaSE_ChangeAgreementRetriggerBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}
}