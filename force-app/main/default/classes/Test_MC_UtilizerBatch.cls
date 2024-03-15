/**
* @Author:      Abhinav Gupta
* @Company:     Capgemini
* @Date:        3rd March, 2021
* @Description: This Class is test class of MC_UtilizerBatch
*
* History
* <Date>           <Authors Name>      <Brief Description of Change>
* -------------------------------------------------------------
*/

@isTest
public class Test_MC_UtilizerBatch 
{
    static testMethod void testMethod1() 
    {
        Test_DataFactory.setUpOrg();
        
        Account acc;
        System.runAs(new User(Id = Userinfo.getUserId())){
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
            List<User> users = Test_DataFactory.createSalesRepUsers(1);
            User Salesrep = users[0];
            insert Salesrep;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.OwnerId = Salesrep.Id;
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
            
            
            Contract conObj = new Contract();
            conObj.vlocity_cmt__QuoteId__c=qut1.id;
            conObj.vlocity_cmt__OpportunityId__c = opp.Id;
            conObj.TeliaSE_Type__c = 'Y';
            conObj.StartDate = system.today();
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            conObj.TeliaSE_is_combi__c = true;
            conObj.Status = 'Draft';
            insert conObj;
            
            conObj.Status = 'Active';
            conObj.TeliaSE_TUPP_Interface_Name__c = 'createAgreementCase';
            Update conObj;
            
            Utilizer_Contract_Relationship__c uc = new Utilizer_Contract_Relationship__c();
            uc.ContractNumber__c = conObj.Id;
            uc.AccountId__c = acc.Id;
            uc.Status__c = 'pendingActive';
            insert uc;
            
            Test.startTest();
            
            MC_UtilizerBatch obj = new MC_UtilizerBatch();
            DataBase.executeBatch(obj); 
            
            Test.stopTest();
        }
    }
    
    static testMethod void myTestMethod2() {        
        test.starttest();
        MC_PendingUtilizersSchedulable myClass = new MC_PendingUtilizersSchedulable ();   
        String chron = '0 0 * * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}