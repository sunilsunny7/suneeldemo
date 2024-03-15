/*To delete files attached on Case if Account consent is denied and if the file has customer data*/

@isTest
public class Test_OnloadController {
    
    @isTest
    public static void deleteFilesTest()
    {
        Test.startTest();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method
        Account acc = Test_DataFactory.createOneLargeStandardAccount();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        
        acc.CM_Final_Traffic_Marketing__c='Denied';
        
        Insert acc;
        
        
            Case cse = new Case();
            cse.Recordtypeid = SEUTility.getRecordTypeId('Enterprise');
            cse.Account=acc;
            cse.Subject='TestCase';
            cse.Origin='Salesforce';
            cse.Status='New';

        Insert cse;
      
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='test', 
                PathOnClient ='test',
                VersionData = bodyBlob, 
                origin = 'H',
                Traffic_Personal_Data__c=true                                
            );
           
        insert contentVersion_1 ;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id];
        
        list<ContentDocumentLink> ContentDocumentLinklist = new list<ContentDocumentLink>();
        
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = cse.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            ContentDocumentLinklist.add(contentlink);
        
        insert ContentDocumentLinklist; 

        OnLoadController.deleteFiles(cse.id);                                                     
        Test.stopTest();
        }
    }
   
}