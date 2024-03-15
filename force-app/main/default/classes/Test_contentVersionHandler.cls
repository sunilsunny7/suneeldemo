@isTest
public class Test_contentVersionHandler {
    static testMethod void validateContentVersion()
    {
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;  
        
        Related_Documents__c testdoc = new Related_Documents__c();
        testdoc.name = 'testdoc';
        insert testdoc;

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=testdoc.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        insert contentlink;
    }
}