@isTest
public with sharing class Test_UserTriggerHandler {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }

    static testMethod void createNewSMEUserNoCygateContactCreated() {
        UserTriggerHandler.testCreateContacts = true;
        User smeUser;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Test.startTest();
            smeUser = Test_DataFactory.createSMEUser();
            insert smeUser;
            Test.stopTest();
        }

        List<Contact> conList = [SELECT Id, Cygate_User__c FROM Contact WHERE Is_Cygate_User_Contact__c = true];
        List<Account> accList = [SELECT Id FROM Account WHERE Org_Nr__c = :label.Account_Org_N LIMIT 1];

        System.assertEquals(conList.size(), 0, 'No Cygate Contact should have been created for a SME User');
    }
    
    static testMethod void createNewCygateUserCygateContactCreated() {
        UserTriggerHandler.testCreateContacts = true;
        User cygateUser;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Test.startTest();
            cygateUser = Test_DataFactory.createCygateUser();
            insert cygateUser;
            Test.stopTest();
        }

        List<Contact> conList = [SELECT Id, Cygate_User__c, Email, Telia_Id__c FROM Contact WHERE Is_Cygate_User_Contact__c = true];
        List<Account> accList = [SELECT Id FROM Account WHERE Org_Nr__c = :label.Account_Org_N LIMIT 1];
        
        //List<User_Performance__c > usrPerList = [SELECT Id, Name FROM User_Performance__c WHERE User.UserRoleId LIKE 'CG%'  AND User__r.Cygate_Performance_User__c = true];
        
        
        System.assertEquals(conList.size(), 1, 'A Cygate Contact should have been created for a Cygate User');
        System.assertEquals(conList[0].Cygate_User__c, cygateUser.Id, 'A Cygate Contact should have been created for the specific Cygate User');
        System.assertEquals(conList[0].Email, cygateUser.Email, 'The email address for the user should have been copied to the contact');
        System.assertEquals(conList[0].Telia_Id__c, cygateUser.Telia_Id__c.toLowercase(), 'The telia id for the user should have been copied to the contact');
    }

    static testMethod void createNewTeliaUserTeliaContactCreated() {
        UserTriggerHandler.testCreateContacts = true;
        User teliaUser;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Test.startTest();
            Telia_SF_User_Contact_Roles__c cs= new Telia_SF_User_Contact_Roles__c();
            cs.Name = 'SME Sales Manager';
            insert cs;
            
            teliaUser = Test_DataFactory.createSMEUser();
            insert teliaUser;
            Test.stopTest();
        }

        List<Contact> conList = [SELECT Id, Telia_User__c, Email, Telia_Id__c, AccountId FROM Contact WHERE Is_Telia_User_Contact__c = true];
        Account acc = [SELECT Id FROM Account WHERE Org_Nr__c = :label.Account_Org_Nr_Telia LIMIT 1];

        System.assertEquals(conList.size(), 1, 'A Telia Contact should have been created for a Telia User');
        System.assertEquals(conList[0].Telia_User__c, teliaUser.Id, 'A Telia Contact should have been created for the specific Telia User');
        System.assertEquals(conList[0].Telia_Id__c, teliaUser.Telia_Id__c.toLowercase(), 'The telia id for the user should have been copied to the contact');
        System.assertEquals(conList[0].AccountId, acc.Id, 'The Contacts account should be the Telia Account');
    }

    /* Because of recursion handling, it is not possible to get contacts created when the user is inserted and updated in the same setting.
    // This Test case is no longer valid and will therefore be deleted.
    static testMethod void changeLargeUserToCygateUserCygateContactCreated() {
        User largeUser;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            largeUser = Test_DataFactory.createLargeUser();
            insert largeUser;
        }

        List<Account> accList = [SELECT Id FROM Account WHERE Org_Nr__c = :label.Account_Org_N LIMIT 1];
        // Note: Account should always exist in production
        if(accList.size() == 0){
            Account acc = new Account();
            acc.Name = 'Cygate Internal AB';
            acc.Org_Nr__c = label.Account_Org_N;
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
            insert acc;
        }

        List<Contact> conListBefore = [SELECT Id, Cygate_User__c FROM Contact WHERE Is_Cygate_User_Contact__c = true];
        System.assertEquals(conListBefore.size(), 0, 'No Cygate Contact should have been created for a Large User');

        Test.startTest();
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            User cygateUser = Test_DataFactory.createCygateUser();
            largeUser.UserRoleId = cygateUser.UserRoleId;
            update largeUser;
        }
        Test.stopTest();

        List<Contact> conList = [SELECT Id, Cygate_User__c FROM Contact WHERE Is_Cygate_User_Contact__c = true];
        List<Account> accListAfter = [SELECT Id FROM Account WHERE Org_Nr__c = :label.Account_Org_N LIMIT 1];

        System.assertEquals(conList.size(), 1, 'A Cygate Contact should have been created for a Cygate User');
        System.assertEquals(conList[0].Cygate_User__c, largeUser.Id, 'A Cygate Contact should have been created for the specific Cygate User');
        System.assertEquals(accList.size(), 1, 'An Account should have been created when inserting a Cygate User');
    }*/
    
    static testMethod void Test_cygatePerformanceUsers()
    {
         UserTriggerHandler.testCreateContacts = true;
        User teliaUser;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Test.startTest();
            User cygateUser = Test_DataFactory.createCygateUser();
            insert cygateUser;
            
            List<User> u = new List<User>();
            u.add(cygateUser);
            List<Yearly_Performance_Score__c> yps = [SELECT Id, User_Performance__c FROM Yearly_Performance_Score__c WHERE User_Performance__r.user__c in :u AND User_Performance__r.User__r.Cygate_Performance_User__c = true];
            List<User_Performance__c > up = [SELECT Id, Name FROM User_Performance__c WHERE User__c in :u AND User__r.Cygate_Performance_User__c = true];
            
            String jsonStr ='[{"Name":"Test"}]';
            String transformedText = jsonStr.replaceAll('""','"\"');
            UserTriggerHandler.loadExistingCygateYearlyPerformanceScore(u);
            UserTriggerHandler.createUserPerformance(u);
            UserTriggerHandler.insertNewUserPerformance(transformedText);
            UserTriggerHandler.loadExistingCygateUserPerformance(u);
            Test.stopTest();
        }
    }
    
     static testMethod void createNewFiberUser(){
         System.runAs(new User(Id = Userinfo.getUserId())){
            Test.startTest();
             User fiberuser = Test_DataFactory.createFiberUser();
            insert fiberuser;
            Test.stopTest();
         }
     }
     
     
     static testMethod void Test_UserDeactivationValidation()
    {
         //UserTriggerHandler.testCreateContacts = true;
        User teliaUser;

        System.runAs(Test_DataFactory.getByPassUser()){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            
            User cygateUser = Test_DataFactory.createCygateUser();
            insert cygateUser;
            
            User salesRep =Test_DataFactory.createLargeUser();
            insert salesRep;
            
            Task t = new Task();
            t.OwnerId= cygateUser.Id;
            t.Subject='test';
            t.ActivityDate= System.Today() +4;
            t.Status='Öppen';
            t.RecordtypeId='01224000000gHAJ';
            insert t;       
            
            Event event = new Event();            
            datetime datestart = Datetime.newInstance(2050, 20 , 12, 00, 00, 00);
            datetime dateend = Datetime.newInstance(2050, 20 , 12, 01, 00, 00);
            event.EndDateTime = dateend;
            event.StartDateTime = datestart ; 
            event.ActivityDateTime = datestart ; 
            event.DurationInMinutes = 60;
            event.RecordtypeId='01224000000gGCg';
            event.OwnerId= cygateUser.Id;
            event.Subject='test event';

            insert event;     
            
            Seller__c s= new Seller__c();
            s.Type__c='Business Area Director';
            s.User__c=cygateUser.Id;
            s.Start_Date__c = System.Today();
            s.End_Date__c = System.Today()+5;
            insert s;
            
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
            acc.Cygate_Account_Manager__c = cygateUser.Id;
            acc.OwnerId= salesRep.Id;
            insert acc;
                 
            Test.startTest();
            cygateUser.IsActive=false;
            salesRep.IsActive=false;
            try{            
            update cygateUser;
           // throw new MyException('An exception should have been thrown by the trigger but was not.');
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Please transfer all open records owned by user') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
                } 
            try{            
            update salesRep;
           // throw new MyException('An exception should have been thrown by the trigger but was not.');
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Please transfer all open records owned by user') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
                } 
            
            Test.stopTest();
        }
    }
    
    
}