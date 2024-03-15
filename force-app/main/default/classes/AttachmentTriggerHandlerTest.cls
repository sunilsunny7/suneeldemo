/* Author: Varma Alluri on 10.04.2017
Description: Jira Ticket: SAEN-2252; This is the Test class for AttachmentTrigger and AttachmentTriggerHandler */

@isTest
public class AttachmentTriggerHandlerTest 
{
    @isTest
    public static void ToCheckHasAttachment()
    {
        Test.startTest();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        Insert acc;
        
        list<case> caselist = new list<case>();
        Case cse1 = new Case();
        cse1.Recordtypeid = SEUTility.getRecordTypeId('Enterprise_Subcase');
        cse1.Account=acc;
        cse1.Subject='TestCase1';
        cse1.Origin='Salesforce';
        cse1.Status='New';
        caselist.add(cse1);
        
        Case cse2 = new Case();
        cse2.Recordtypeid = SEUTility.getRecordTypeId('Enterprise_Subcase');
        cse2.Account=acc;
        cse2.Subject='TestCase2';
        cse2.Origin='Salesforce';
        cse2.Status='New';
        caselist.add(cse2);
        
        Insert caselist;
        
        Attachment attach1 = new Attachment();
        
        attach1.Name='Unit Test Attachment';
        Blob bodyBlob1 = Blob.valueOf('Unit Test Attachment Body1');
        attach1.body = bodyBlob1;
        attach1.parentId = caselist[0].id;
        insert attach1;
        
        Attachment attach2 = new Attachment();
        attach2.Name='Unit Test Attachment';
        Blob bodyBlob2 = Blob.valueOf('Unit Test Attachment Body1');
        attach2.body = bodyBlob2;
        attach2.parentId = caselist[1].id;
        insert attach2;
        
        list<Case> c = [Select Id,Account.Name,Subject,Origin,Status,HasAttachment__c from Case WHERE Id=:caselist];
        System.assertEquals(c[0].HasAttachment__c, true);
        System.assertEquals(c[1].HasAttachment__c, true);
        
        attachment att1 = [select id from attachment where id=:attach1.id];
        Delete att1;
        
        attachment att2 = [select id from attachment where id=:attach2.id];
        Delete att2;
        
        list<Case> c1 = [Select Id,Account.Name,Subject,Origin,Status,HasAttachment__c from Case WHERE Id=:caselist];
        System.assertEquals(c1[0].HasAttachment__c,false);
        System.assertEquals(c1[1].HasAttachment__c,false);
        Test.stopTest();
        }  //
    }
    @isTest
    public static void ToCheckEmailHasAttachment()
    {
        Test.startTest();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        Insert acc;
        
        list<case> caselist = new list<case>();
        Case cse1 = new Case();
        cse1.Recordtypeid = SEUTility.getRecordTypeId('Enterprise_Subcase');
        cse1.Account=acc;
        cse1.Subject='TestCase1';
        cse1.Origin='Salesforce';
        cse1.Status='New';
        caselist.add(cse1);
        
        Case cse2 = new Case();
        cse2.Recordtypeid = SEUTility.getRecordTypeId('Enterprise_Subcase');
        cse2.Account=acc;
        cse2.Subject='TestCase2';
        cse2.Origin='Salesforce';
        cse2.Status='New';
        caselist.add(cse2);
        
        Insert caselist;
        
        emailmessage em1 = new emailmessage();
        em1.fromaddress = 'Test1@test.com';
        em1.toaddress = 'test1@test.com';
        em1.subject = 'Test Email1';
        em1.textbody = 'testing';
        em1.parentid = caselist[0].id;
        insert em1;
        
        emailmessage em2 = new emailmessage();
        em2.fromaddress = 'Test12@test.com';
        em2.toaddress = 'test2@test.com';
        em2.subject = 'Test Email2';
        em2.textbody = 'testing';
        em2.parentid = caselist[1].id;
        insert em2;
        
        Attachment attach1 = new Attachment();
        attach1.Name='Unit Test Attachment1';
        Blob bodyBlob1 = Blob.valueOf('Unit Test Attachment Body');
        attach1.body = bodyBlob1;
        attach1.parentId = em1.id;
        insert attach1;
        
        Attachment attach2 = new Attachment();
        attach2.Name='Unit Test Attachment';
        Blob bodyBlob2 = Blob.valueOf('Unit Test Attachment Body');
        attach2.body = bodyBlob2;
        attach2.parentId = em2.id;
        insert attach2;
        
        list<Case> c = [Select Id,Account.Name,Subject,Origin,Status,HasAttachment__c from Case WHERE Id=:caselist];
        System.assertEquals(c[0].HasAttachment__c, true);
        System.assertEquals(c[1].HasAttachment__c, true);
        
        attachment att1 = [select id from attachment where id=:attach1.id];
        Delete att1;
        
        attachment att2 = [select id from attachment where id=:attach2.id];
        Delete att2;
        
        list<Case> c1 = [Select Id,Account.Name,Subject,Origin,Status,HasAttachment__c from Case WHERE Id=:caselist];
        System.assertEquals(c1[0].HasAttachment__c,false);
        System.assertEquals(c1[1].HasAttachment__c,false);
        Test.stopTest();
        }
    }
}