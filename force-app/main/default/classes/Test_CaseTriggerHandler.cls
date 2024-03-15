/**
About
-----
Description: Test Class Test_CaseTriggerHandler on Case for Test_CaseTriggerHandler
Create date: 29.03-2017

Update History
--------------
Created Mars 2017 - Vahraz Mostajir
Updated March 2018 - Dnyanesh Chavan

Issues / TODOs
--------------    
*/ 

@isTest
public class Test_CaseTriggerHandler {
    
    public static testmethod void no01_setAccountFromSubject(){
        
        System.debug('@@Test no01_setAccountFromSubject Starts');
        Test_DataFactory.setUpOrg();
        List<User> largeUserTeam;
        user u = Test_DataFactory.getByPassUser();
        System.runAs(u){
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
        }
            user largeUser = largeUserteam[0];
            user largeuser1 = largeuserteam[1];
            user largeuser2 = largeUserteam[2];  
        Case case1;
        Case case2;
        Case case3;
        Case case4;
        Case case5;
        Account acc;
        Account acc1;
        
      // System.runAs(new User(Id = Userinfo.getUserId(),Bypass_VR__c = True)){
     //  System.runAs(new User(Id = Userinfo.getUserId(),Bypass_VR__c = SEUtility.isBypassValidation())){

        System.runAs(u){  // V.A  Bypassing User by calling getByPassUser method
            acc = new Account();
            acc.Telia_Service_Manager__c = largeuser1.id;
            acc.Org_Nr__c = '1234567890';
            acc.Name = 'acc1'; 
            acc.named_Sales_coordinator__c = largeuser2.Id;
            insert acc;
            
            Opportunity oppn = Test_DataFactory.createLargeOpportunity();
            oppn.AccountId = acc.Id;
            insert oppn;
            Test.startTest();
            case1 = new Case();            
            case1.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case1.Subject = 'this should 1234567890 work';
            insert case1;
            update case1;
            
            case2 = new Case();            
            case2.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case2.Subject = '123456-7890';
            insert case2;
            
            case3 = new Case();            
            case3.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case3.Subject = '123456-7890 this should also work';
            insert case3;
            
            case4 = new Case();            
            case4.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case4.Subject = 'this should also work 123456-7890';
            insert case4;
            
            //Changes by dnyanesh
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
            
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger';      
            cv.PathOnClient ='test';           
            cv.VersionData =beforeblob;          
            insert cv;  
            
            Related_Documents__c testdoc = new Related_Documents__c();
            testdoc.name = 'testdoc';
            insert testdoc;
            
          
            acc1 = Test_DataFactory.createOneLargeStandardAccount();
            acc1.Telia_Service_manager__c = largeUser.Id;
            acc1.Named_Sales_coordinator__c = largeUser1.id;
            insert acc1;
            Opportunity opp = Test_DataFactory.createLargeOpportunity();
            opp.AccountId = acc1.Id;
            insert opp;
            case5 = new Case();            
            case5.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case5.Subject = 'this should also work 123456-7890';
            case5.Opportunity__c = opp.id;
            insert case5;
            
            case4.Accountid = acc.id;
            update case4;
            case4.Accountid = acc1.id;
            update case4;
            case5.OwnerId = '00524000007CzT2';
            case5.opportunity__c = oppn.id;
            update case5;
            //Test.stopTest();              
        }
        
        Case case1test = [SELECT Id, AccountId FROM Case WHERE Id = :case1.Id LIMIT 1];
        Case case2test = [SELECT Id, AccountId FROM Case WHERE Id = :case2.Id LIMIT 1];
        Case case3test = [SELECT Id, AccountId FROM Case WHERE Id = :case3.Id LIMIT 1];
        Case case4test = [SELECT Id, AccountId FROM Case WHERE Id = :case4.Id LIMIT 1];
        
        System.assertEquals(case1test.AccountId, acc.Id, 'Account should be set, because subject had a orgnumber');
        System.assertEquals(case2test.AccountId, acc.Id, 'Account should be set, because subject had a orgnumber');
        System.assertEquals(case3test.AccountId, acc.Id, 'Account should be set, because subject had a orgnumber');
        System.assertEquals(case4test.AccountId, acc1.Id, 'Account should be set, because subject had a orgnumber');
     Test.stopTest();    
    } 
    public static testmethod void no02_updateParentStatus(){
           System.runAs(Test_DataFactory.getByPassUser()){  
        Group testGroup1 = new Group(Type = 'Queue',name = 'VolumeDesign');
        Group testGroup2 = new Group(Type = 'Queue',name = 'SAT');
        List<Group> testGroupList = new List<Group>();
        testGroupList.add(testGroup1);
        testGroupList.add(testGroup2); 
        insert testGroupList;
        List<QueueSobject> testQueueCase = new List<QueueSobject>();
        testQueueCase.add(new QueueSObject(QueueId = testGroup1.Id, SobjectType = 'Case'));
        testQueueCase.add(new QueueSObject(QueueId = testGroup2.Id, SobjectType = 'Case'));
        insert testQueueCase;
        Case_Settings__c cst1 = new Case_Settings__c(name = 'General Case Settings',SAT_Queue_Id__c = testGroupList[1].id, Volume_Design_Queue_Id__c =  testGrouplist[0].id);
            insert cst1;
        }
        Case case1 = new Case();            
            case1.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case1.Subject = 'parent case';
            Case1.Origin = 'Salesforce';
            case1.Case_Group__c = 'SAT';
            Case1.Category__c = 'Utredning';
            Case1.product_Area__c = 'Datakom';
            case1.Status = 'New';
            case1.notify_Queue__c = True;
            List<Case> caseList = new List<Case>();
            caseList.add(case1);
            Case case2 = new Case();
            case2.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case2.Subject = 'parent case';
            case2.Origin = 'Salesforce';
            case2.Case_Group__c = 'Volume Design';
            Case2.Category__c = 'Övrigt';
            Case2.product_Area__c = 'Datakom';
            case2.Status = 'New';
            case2.notify_Queue__c = False;
            caseList.add(case2);
            Case case3 = new Case();            
            case3.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case3.Subject = 'parent case';
            Case3.Origin = 'Salesforce';
            case3.Case_Group__c = 'SAT';
            Case3.Category__c = 'Utredning';
            Case3.product_Area__c = 'Datakom';
            case3.Status = 'New';
            case3.notify_Queue__c = False;
            
            caseList.add(case3);
            Case case4 = new Case();
            case4.RecordTypeId = SEUtility.getRecordTypeId('Enterprise');
            case4.Subject = 'parent case';
            case4.Origin = 'Salesforce';
            case4.Case_Group__c = 'Volume Design';
            Case4.Category__c = 'Övrigt';
            Case4.product_Area__c = 'Datakom';
            case4.Status = 'New';
            case4.notify_Queue__c = True;
            caseList.add(case4);
            insert caseList;
            test.starttest();
            
        Case caseSub1 = new Case();
        caseSub1.RecordTypeId = SEUtility.getrecordtypeid('Enterprise_Subcase');
        caseSub1.Parentid = caselist[0].id;
        CaseSub1.Status = 'New';
        caseSub1.Subject = 'Test sub case';
        
        List<Case> subCaseList =  new List<case>();
        subCaseList.add(caseSub1);
        
        Case caseSub2 = new Case();
        caseSub2.RecordTypeId = SEUtility.getrecordtypeid('Enterprise_Subcase');
        caseSub2.Parentid = caseList[1].id;
        CaseSub2.Status = 'New';
        caseSub2.Subject = 'Test sub case';
        subCaseList.add(caseSub2);
        
        Case caseSub3 = new Case();
        caseSub3.RecordTypeId = SEUtility.getrecordtypeid('Enterprise_Subcase');
        caseSub3.Parentid = caselist[2].id;
        CaseSub3.Status = 'New';
        caseSub3.Subject = 'Test sub case3';
        subCaseList.add(caseSub3);
        Case caseSub4 = new Case();
        caseSub4.RecordTypeId = SEUtility.getrecordtypeid('Enterprise_Subcase');
        caseSub4.Parentid = caseList[3].id;
        CaseSub4.Status = 'New';
        caseSub4.Subject = 'Test sub case';
        subCaseList.add(caseSub4);
        
        insert subCaseList;
        
        
        subCaseList[0].status = 'In Progress';
        subCaseList[1].status = 'In Progress';
        subCaseList[2].status = 'In Progress';
        subCaseList[3].status = 'In Progress';
        update subCaseList;
        subCaseList[0].status = 'Closed';
        subCaseList[1].Status = 'Closed';
        update subCaseList;
        
        test.stoptest();
    }
}