/* Author: Varma Alluri on 10.04.2017
Description: Jira Ticket: SAEN-2252; This is the Test class for ContentDocumentLinkTrigger and ContentDocumentLinkTriggerHandler */

@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    
    /*@isTest(SeeAllData=true)
    public static void updateDocumentNameTest()
    {
        
       
        list<ContentDocument> cIdList= [select Id from ContentDocument];
        List<Id> cId = new List<Id>();
        for(ContentDocument cListId:cIdList)
        {
            cId.add(cListId.Id); 
        }
        //list<Case> c = [Select Id,Account.Name,Subject,Origin,Status,HasAttachment__c from Case WHERE Id=:caselist];
        list<ContentDocumentLink> cList = [Select Id,ContentDocumentId,LinkedEntityId,ShareType from ContentDocumentLink WHERE ContentDocumentId IN :cId];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.updateDocumentName(cList);
        Test.stopTest();
    }
    */
    @isTest
    public static void ToCheckFilesHasAttachment()
    {
        Test.startTest();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method
            Account acc = new Account();
            acc.Name='TestAccount';
            acc.Org_Nr__c =  '1234567890';
            Insert acc;
            
            list<case> caselist = new list<case>();
            for(integer cs=1;cs<=2;cs++) {
                Case cse = new Case();
                cse.Recordtypeid = SEUTility.getRecordTypeId('Enterprise_Subcase');
                cse.Account=acc;
                cse.Subject='TestCase'+cs;
                cse.Origin='Salesforce';
                cse.Status='New';
                caselist.add(cse);
            }
            Insert caselist;
            
            list<ContentVersion> ContentVersionlist = new list<ContentVersion>();
            for(integer i=1;i<=2;i++){
                Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
                ContentVersion contentVersion_1 = new ContentVersion(
                    Title='test', 
                    PathOnClient ='test',
                    VersionData = bodyBlob, 
                    origin = 'H'
                );
                ContentVersionlist.add(contentVersion_1);            
            }
            insert ContentVersionlist;
            
            list<ContentVersion> contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :ContentVersionlist];
            
            list<ContentDocumentLink> ContentDocumentLinklist = new list<ContentDocumentLink>();
            for(case c : caselist){
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = c.id;
                contentlink.contentdocumentid = contentVersion_2[0].contentdocumentid;
                contentlink.ShareType = 'V';
                ContentDocumentLinklist.add(contentlink);
            }
            insert ContentDocumentLinklist; 
            
            list<Case> c = [Select Id,Account.Name,Subject,Origin,Status,HasAttachment__c from Case WHERE Id=:caselist];
            System.assertEquals(c[0].HasAttachment__c, true);
            System.assertEquals(c[1].HasAttachment__c, true);
            Test.stopTest();
        }
    }
    @isTest
    public static void ToCheckFilesHasAttachmentdelete()
    {
        Test.startTest();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method
            Account acc = new Account();
            acc.Name='TestAccount';
            acc.Org_Nr__c =  '1234567890';
            Insert acc;
            
            list<case> caselist = new list<case>();
            for(integer cs=1;cs<=2;cs++) {
                Case cse = new Case();
                cse.Recordtypeid = SEUTility.getRecordTypeId('Enterprise_Subcase');
                cse.Account=acc;
                cse.Subject='TestCase'+cs;
                cse.Origin='Salesforce';
                cse.Status='New';
                caselist.add(cse);
            }
            Insert caselist;
            
            list<ContentVersion> ContentVersionlist = new list<ContentVersion>();
            for(integer i=1;i<=2;i++){
                Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
                ContentVersion contentVersion_1 = new ContentVersion(
                    Title='test', 
                    PathOnClient ='test',
                    VersionData = bodyBlob, 
                    origin = 'H'
                );
                ContentVersionlist.add(contentVersion_1);            
            }
            insert ContentVersionlist;
            
            list<ContentVersion> contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :ContentVersionlist];
            
            list<ContentDocumentLink> ContentDocumentLinklist = new list<ContentDocumentLink>();
            for(case c : caselist){
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = c.id;
                contentlink.contentdocumentid = contentVersion_2[0].contentdocumentid;
                contentlink.ShareType = 'V';
                ContentDocumentLinklist.add(contentlink);
            }
            insert ContentDocumentLinklist; 
            
            
            
            list<Case> c = [Select Id,Account.Name,Subject,Origin,Status,HasAttachment__c from Case WHERE Id=:caselist];
            System.assertEquals(c[0].HasAttachment__c, true);
            System.assertEquals(c[1].HasAttachment__c, true);
            
            delete ContentDocumentLinklist; 
            list<Case> c1 = [Select Id,Account.Name,Subject,Origin,Status,HasAttachment__c from Case WHERE Id=:caselist];
            System.assertEquals(c1[0].HasAttachment__c, false);
            System.assertEquals(c1[1].HasAttachment__c, false);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void ToAddDocumentToOpportunityFromQuote_Test()
    {
        System.runAs(Test_DataFactory.getByPassUser()){
            
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
            list<ContentDocumentLink> cList = new list<ContentDocumentLink>();
            cList.add(contentlink);
            ContentDocumentLinkTriggerHandler.updateDocumentName(cList);   
        }
    }
}