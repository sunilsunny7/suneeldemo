@isTest
public with sharing class Test_TeliaSE_MC_QuoteDocumentLinkBatch 
{
    @isTest
    public static void ToAddDocumentToOpportunityFromQuote_Test()
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Org_Nr__c = label.Account_Org_N;
        //acc.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales_Organisation_Account').getRecordTypeId();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
        acc.Telia_Service_Manager__c = userInfo.getUserId();
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
        Recordtype rr = [Select id from recordType where recordType.Developername = 'Offer'];
        qut1.RecordTypeId = rr.id;
        qut1.opportunityId = opp.id;
        qut1.TeliaSE_Approval_Flag__c = False; 
        qut1.TeliaSE_Type__c='Renegotiation';
        insert qut1;
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='test', 
            PathOnClient ='test',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion_1.id];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = qut1.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        
        insert contentlink;
        
        
        
        test.startTest();
        ContentDocumentLink contentLinkOpp = [Select id from ContentDocumentLink where LinkedEntityId =:opp.id LIMIT 1];
        delete contentLinkOpp;
        Id batchJobId = Database.executeBatch(new TeliaSE_MC_QuoteDocumentLinkBatch(), 200);
 		test.stopTest();      
    }
    
     @isTest
    public static void ToAddDocumentToOpportunityFromQuote_Test2()
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Org_Nr__c = label.Account_Org_N;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
        acc.Telia_Service_Manager__c = userInfo.getUserId();
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
        Recordtype rr = [Select id from recordType where recordType.Developername = 'Offer'];
        qut1.RecordTypeId = rr.id;
        qut1.opportunityId = opp.id;
        qut1.TeliaSE_Approval_Flag__c = False; 
        qut1.TeliaSE_Type__c='Renegotiation';
        insert qut1;
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='test', 
            PathOnClient ='test',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion_1.id];        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = qut1.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
	    test.startTest();
        Id batchJobId = Database.executeBatch(new TeliaSE_MC_QuoteDocumentLinkBatch(), 200);
 		test.stopTest();
    }
}