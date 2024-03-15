@isTest
public class Test_BatchMCcontractTermination {
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
            
            Id contractRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
            
            Contract conObj = new Contract();
            conObj.RecordTypeId = contractRecTypeId;
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
            conObj.vlocity_cmt__TerminateDate__c = date.today();
            conObj.vlocity_cmt__TerminationReason__c = 'Customer Not Compliance';
            conObj.vlocity_cmt__TerminationType__c = 'With Cause';
            Update conObj;
            
			Contract conObj1 = new Contract();
            conObj1.RecordTypeId = contractRecTypeId;
            conObj1.vlocity_cmt__QuoteId__c=qut1.id;
            conObj1.vlocity_cmt__OpportunityId__c = opp.Id;
            conObj1.TeliaSE_Type__c = 'Y';
            conObj1.StartDate = system.today();
            conObj1.accountId = acc.Id;
            conObj1.TeliaSE_Case_Id__c = '12345';
            conObj1.TeliaSE_is_combi__c = true;
            conObj1.Status = 'Draft';
            conObj1.vlocity_cmt__TerminateDate__c = date.today();
            conObj1.vlocity_cmt__TerminationType__c = 'With Cause';
            insert conObj1;
            
            Test.startTest(); 
            
            BatchMCcontractTermination obj = new BatchMCcontractTermination();
            DataBase.executeBatch(obj); 
            SchedulableContext sc = null;
            obj.execute(sc);
            Test.stopTest();
        }
    }

}