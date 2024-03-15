@isTest
public class MCOnline_PdfSizeBatch_Test {

    @testSetup
    public static void setup()
    {
    		User user=Test_DataFactory.createAdminUser();
        	user.LastName='deadpool';
      		insert user;
        System.runAs(user){
        	Account acc = Test_DataFactory.createOneLargeStandardAccount();
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
            insert conObj;

        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;
        
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=conObj.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        insert contentlink;
        }
    }
    
    @isTest
    public static void testPdfSize()
    {
        Test.startTest();
        Database.executeBatch(new MCOnline_PdfSizeBatch(),5);
        Test.stopTest();
    }
    
    @isTest
    public static void testPdf()
    {
        User user =[select id from User where LastName ='deadpool'];
        System.runAs(user)
        {
            List<ContentVersion> testContents = [SELECT id, ContentDocumentId FROM ContentVersion  where title='test content trigger'];
            MCOnline_PdfSizeBatch mCOnline_PdfSizeBatch=new MCOnline_PdfSizeBatch();
            mCOnline_PdfSizeBatch.getContentDocumentLinks(testContents);
        }
    }
    
}