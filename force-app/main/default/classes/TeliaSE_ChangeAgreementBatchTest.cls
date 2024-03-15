/**
* @Author:      Surajit Pramanik
* @Company:     Capgemini
* @Date:        02th August, 2019
* @Description: This Class is test class of TeliaSE_TUPPIntegrationHandler
*
* History
* <Date>           <Authors Name>      <Brief Description of Change>
* -------------------------------------------------------------
*/

@isTest
public class TeliaSE_ChangeAgreementBatchTest {
 
    //This method for combi Case
    static testMethod void testMethod1() 
    {
        Test_DataFactory.setUpOrg();
        User salesManager; 
		System.runAs(new User(Id = Userinfo.getUserId()))
        {
            salesManager = Test_DataFactory.createAdminUser();
            salesManager.Bypass_VR__c = true;
            salesManager.FirstName = 'TestRunUser';
            salesManager.IsActive = true;
            insert salesManager;
        }
        
        Account acc;
        
        
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
            qut1.TeliaSE_Type__c='Y';
            insert qut1;
            
            Quote qut2 = new Quote();
            qut2.Name='CallOff';
            qut2.status = 'Draft';
            qut2.opportunityId = opp.id;
            qut2.TeliaSE_Approval_Flag__c = False; 
            qut2.TeliaSE_Type__c='Y';
            insert qut2;
            
            Contract conObj = new Contract();
            conObj.vlocity_cmt__QuoteId__c=qut1.id;
            conObj.TeliaSE_Type__c = 'Y';
            conObj.StartDate = system.today();
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            conObj.TeliaSE_is_combi__c = true;
            conObj.Status = 'Draft';
            insert conObj;
            
            conObj.Status = 'Signed';
            conObj.TeliaSE_TUPP_Interface_Name__c = 'createAgreementCase';
            conObj.CallOff_QuoteId__c = qut2.id;
            Update conObj;
            
            Test.startTest();
            
            TeliaSE_ChangeAgreementBatch obj = new TeliaSE_ChangeAgreementBatch();
            DataBase.executeBatch(obj); 
            
            Test.stopTest();
        }
    }
    
    //This method for non Combi Case
    static testMethod void testMethod2() 
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
            qut1.TeliaSE_Type__c='Y';
            insert qut1;
            
            Quote qut2 = new Quote();
            qut2.Name='CallOff';
            qut2.status = 'Draft';
            qut2.opportunityId = opp.id;
            qut2.TeliaSE_Approval_Flag__c = False; 
            qut2.TeliaSE_Type__c='Y';
            insert qut2;
            
            Contract conObj = new Contract();
            conObj.vlocity_cmt__QuoteId__c=qut1.id;
            conObj.TeliaSE_Type__c = 'Y';
            conObj.StartDate = system.today();
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            conObj.TeliaSE_is_combi__c = false;
            conObj.Status = 'Draft';
            insert conObj;
            
            conObj.Status = 'Signed';
            conObj.TeliaSE_TUPP_Interface_Name__c = 'createAgreementCase';
            Update conObj;
            
            Test.startTest();
            
            TeliaSE_ChangeAgreementBatch obj = new TeliaSE_ChangeAgreementBatch();
            DataBase.executeBatch(obj); 
            
            Test.stopTest();
            conObj.Status='Active';
            update conObj;
            
            /*conObj.Status = 'Signed';
            conObj.TeliaSE_Type__c=null;
            update conObj;*/
            conObj.Status = 'Cancelled';
            conObj.TeliaSE_Reason_for_Cancellation__c = 'Ok';
            update conObj;
        }
    }
    
}