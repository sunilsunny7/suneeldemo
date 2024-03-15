/**
About
-----
Description: Test Class to test 'Targeted not targeted Account'
Create date: March 2015

Update History
--------------
Created Mar 2015 - V.I
Updated May 2015 - V.I removed purpose field on Task changed status name to Stängd
Updated May 2015 - V.I changed type of tasks to Telefonmöte, Fysiskt möte and Webmöte
Updated Sep 2015 - V.I added SME organisation record types to Account
Updated Oct 2016 - A.N All tests previously ran as the logged in user (and on the logged in users profile).
All tests failed when validation rule was added to Cygate tasks, as Cygate tasks was the default record type for Sys Admin.
Therefore updated tests so that they run as SME-users, as these tests were originally created for SME.
Updates Jun 2017 - D.C - Case # 3410 - Email field is mandatory, thus when a Contact is created we need to add email Also, 
Role will be mandatory for all Customer Contact.

Issues / TODOs
--------------  
*/

@isTest
private class Test_AccountTargeted {
    
    @isTest static void testAccountTargetedWithTaskOnInsertNoDueDate() {
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        User salesRep;
        Account acc;
        Task t;
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            List<User> smeUserTeam = Test_DataFactory.createSmeUserTeam();
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        System.runAs(salesRep){
            //Test Data Setup
            
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            //Task of type Telefonmöte with no Due date        
            t = Test_DataFactory.createOneTask();
            t.WhoId = c.Id;
            t.Type = 'Telefon';
            t.Status = 'Stängd';
            
            
            //Perform Test
            Test.startTest();
            insert t;
            Test.stopTest();
        }
        
        t = [SELECT AccountId FROM Task WHERE Id =: t.Id];
        acc = [SELECT Id, Contacted__c FROM Account WHERE Id =: t.AccountId];
        
        //Assert
        System.assertEquals(acc.Id, t.AccountId, 'The AccountId on Task was not updated correctly');
        System.assertEquals(System.now().date(), acc.Contacted__c, 'Contacted field did not get updated correctly');
    }
    
    /*
@isTest static void TestAccountTargetedWithTaskOnInsertNoDueDate_OLD() {
Id organisationRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Sales_Organisation_Account' LIMIT 1][0].Id;

//Test Data Setup
Account acc = Test_DataFactory.createOneAccount();
acc.RecordTypeId = organisationRTId;
insert acc;

Contact c = Test_DataFactory.createOneContact();
c.AccountId = acc.Id;
insert c;

//Task of type Telefonmöte with no Due date        
Task t = Test_DataFactory.createOneTask();
t.WhoId = c.Id;
t.Type = 'Telefon';
t.Status = 'Stängd';


//Perform Test
Test.startTest();
insert t;
Test.stopTest();

t = [SELECT AccountId FROM Task WHERE Id =: t.Id];
acc = [SELECT Id, Contacted__c FROM Account WHERE Id =: t.AccountId];

//Assert
System.assertEquals(acc.Id, t.AccountId, 'The AccountId on Task was not updated correctly');
System.assertEquals(System.now().date(), acc.Contacted__c, 'Contacted field did not get updated correctly');
}
*/
    
    @isTest static void TestAccountTargetedWithTaskOnInsertWithDueDate() {
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        User salesRep;
        Account acc;
        Task t;
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            List<User> smeUserTeam = Test_DataFactory.createSmeUserTeam();
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        System.runAs(salesRep){
            //Test Data Setup
            
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            //Task of type Fysiskt möte with Due date        
            t = Test_DataFactory.createOneTask();
            t.WhoId = c.Id;
            t.Type = 'Fysiskt';
            t.Status = 'Stängd';
            t.ActivityDate = date.parse('2014-02-03');
            
            
            //Perform Test
            Test.startTest();
            insert t;
            Test.stopTest();
        }
        
        t = [SELECT AccountId FROM Task WHERE Id =: t.Id];
        acc = [SELECT Id, Contacted__c FROM Account WHERE Id =: t.AccountId];
        
        //Assert
        System.assertEquals(acc.Id, t.AccountId, 'The AccountId on Task was not updated correctly');
        System.assertEquals(date.parse('2014-02-03'), acc.Contacted__c, 'Contacted field did not get updated correctly');
    }    
    
    @isTest static void TestAccountTargetedWithTaskOnUpdateNoDueDate() {
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        User salesRep;
        Account acc;
        Task t;
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            List<User> smeUserTeam = Test_DataFactory.createSmeUserTeam();
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = salesRep.id;
            insert acc;
        }
        
        System.runAs(salesRep){
            //Test Data Setup
            
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            //Task of type Webmöte with Due date        
            t = Test_DataFactory.createOneTask();
            t.WhoId = c.Id;
            t.Status = 'Öppen';
            t.Type = 'Web';
            insert t;
            
            //Perform Test
            Test.startTest();
            t.Status = 'Stängd';
            update t;
            Test.stopTest();
        }
        
        t = [SELECT AccountId FROM Task WHERE Id =: t.Id];
        acc = [SELECT Id, Contacted__c FROM Account WHERE Id =: t.AccountId];
        
        //Assert
        System.assertEquals(acc.Id, t.AccountId, 'The AccountId on Task was not updated correctly');
        System.assertEquals(System.now().date(), acc.Contacted__c, 'Contacted field did not get updated correctly');
    }    
    
    @isTest static void TestAccountTargetedWithTaskOnUpdateWithDueDate() {
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        User salesRep;
        Account acc;
        Task t;
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            List<User> smeUserTeam = Test_DataFactory.createSmeUserTeam();
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        System.runAs(salesRep){
            //Test Data Setup
            
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            //Task of type Webmöte with Due date        
            t = Test_DataFactory.createOneTask();
            t.WhoId = c.Id;
            t.Status = 'Öppen';
            t.Type = 'Web';
            t.ActivityDate = date.parse('2015-03-11');
            insert t;
            
            //Perform Test
            Test.startTest();
            t.Status = 'Stängd';
            update t;
            Test.stopTest();
        }
        
        t = [SELECT AccountId FROM Task WHERE Id =: t.Id];
        acc = [SELECT Id, Contacted__c FROM Account WHERE Id =: t.AccountId];
        
        //Assert
        System.assertEquals(acc.Id, t.AccountId, 'The AccountId on Task was not updated correctly');
        System.assertEquals(date.parse('2015-03-11'), acc.Contacted__c, 'Contacted field did not get updated correctly');
    }
    
    @isTest static void TestAccountTargetedWithEventOnUpdate() {
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        User salesRep;
        Account acc;
        Event e;
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            List<User> smeUserTeam = Test_DataFactory.createSmeUserTeam();
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        System.runAs(salesRep){
            //Test Data Setup
            
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            e = Test_DataFactory.createOneEvent();
            e.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Telia Events').getRecordTypeId();
            e.WhoId = c.Id;
            e.WhatId = acc.Id;
            insert e;
            
            //Perform Test
            Test.startTest();
            e.Event_Complete__c = TRUE;
            update e;
            Test.stopTest();
        }
        
        e = [SELECT AccountId, EndDateTime FROM Event WHERE Id =: e.Id];
        acc = [SELECT Id, Contacted__c FROM Account WHERE Id =: e.AccountId];
        
        //Assert
        System.assertEquals(acc.Id, e.AccountId, 'The AccountId on Task was not updated correctly');
        System.assertEquals(e.EndDateTime.date(), acc.Contacted__c, 'Contacted field did not get updated correctly');
    }
    
    @isTest static void TestAccountTargetedWithEventDateLessThanLastContactedDate() {
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        User salesRep;
        Account acc;
        Event e;
        Date lastContacted = System.now().date() + 10; //Set a date in the future that is greater than the new events end date
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            List<User> smeUserTeam = Test_DataFactory.createSmeUserTeam();
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.Contacted__c = lastContacted;
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        System.runAs(salesRep){
            //Test Data Setup
            
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            e = Test_DataFactory.createOneEvent();
            e.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Telia Events').getRecordTypeId();
            e.WhoId = c.Id;
            e.WhatId = acc.Id;
            insert e;
            
            //Perform Test
            Test.startTest();
            e.Event_Complete__c = TRUE;
            update e;
            Test.stopTest();
        }
        
        e = [SELECT AccountId, EndDateTime FROM Event WHERE Id =: e.Id];
        acc = [SELECT Id, Contacted__c FROM Account WHERE Id =: e.AccountId];
        
        //Assert
        System.assertEquals(acc.Id, e.AccountId, 'The AccountId on Task was not updated correctly');
        System.assertNotEquals(e.EndDateTime, acc.Contacted__c, 'Event end date and Contacted should not be equal');
        System.assertEquals(lastContacted, acc.Contacted__c, 'Contacted field did not get updated correctly');
    }   
    
}