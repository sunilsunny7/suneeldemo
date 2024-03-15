/**
 * @Author:      Shubham Kundu
 * @Company:     Capgemini
 * @Date:        4rd April 2019
 * @Description: Test Class for TeliaSE_ReviseContract
 *
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------
*/

@isTest
public with sharing class TeliaSE_ReviseContract_Test {
    @testSetup
    static void testData() {
       Test_DataFactory.setUpOrg();
        
        System.runAs(Test_DataFactory.getByPassUser()){
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced BA';
            insert acc;
            
            Opportunity opp = new Opportunity();
        	opp.Name='opp1';
        	opp.AccountId=acc.Id;
        	opp.CloseDate = System.today();
        	opp.StageName='Needs Analysis';
        	opp.Pricebook2Id=Test.getStandardPricebookId();
        	insert opp;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];

            
        
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
            insert conObj;
            
            conObj.Status = 'Signed';
            update conObj;
            conObj.Status='Active';
            update conObj;
        }
    }

    @isTest
    static void reviseContract_Scenario() {
        
        Contract con = [Select Id,AccountId,ContractNumber from Contract Limit 1];
        TeliaSE_ReviseContract rc = new TeliaSE_ReviseContract();
        String methodName = 'reviseContract';
        Map<String,Object> inputMap = new  Map<String,Object>();
        inputMap.put('ContextId',con.Id);
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();

        Test.startTest();
        rc.invokeMethod(methodName,inputMap,outMap,options);
        Test.stopTest();
    }   
}