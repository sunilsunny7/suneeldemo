/**
About
-----
Description: Telia_WebService
Create date: February 2017

Update History
--------------
Created Jan 2017 - Vahraz Mostajir - Created. 


Issues / TODOs
--------------     
*/

@isTest
public class Test_Telia_WebService {
    public static testmethod void no01_testGetActivitiesNoOrg(){	
        System.debug('@@Test no01_testGetActivitiesNoOrg Starts');
        Test_DataFactory.setUpOrg();
        
        // Submitting a blank string as retailer Id, should return error
        Telia_WebService.Request request = new Telia_WebService.Request();
        request.orgNumber = '';
        
        Telia_WebService.ActivityResponse response = Telia_WebService.getActivities(request);
        System.assertEquals(response.success, false, 'The call should not be successful');
        System.assertEquals(response.errorMsg, Telia_WebService.ERR_INVALID_ID, 'Incorrect error message');
        System.assertEquals(response.events, null, 'The response events list should be null');
        System.assertEquals(response.tasks, null, 'The response tasks list should be null');
    }
    
    public static testmethod void no02_testGetContactsNoOrg(){	
        System.debug('@@Test no02_testGetContactsNoOrg Starts');
        Test_DataFactory.setUpOrg();
        
        // Submitting a blank string as retailer Id, should return error
        Telia_WebService.Request request = new  Telia_WebService.Request();
        request.orgNumber = '';
        
        Telia_WebService.ContactResponse response = Telia_WebService.getContacts(request);
        System.assertEquals(response.success, false, 'The call should not be successful');
        System.assertEquals(response.errorMsg, Telia_WebService.ERR_INVALID_ID, 'Incorrect error message');
        System.assertEquals(response.contacts, null, 'The response contacts list should be null');
    }
    
    public static testmethod void no03_testSOQLinjection(){	
        System.debug('@@Test no03_testSOQLinjection Starts');
        Test_DataFactory.setUpOrg();
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        // Create Test Data
        List<Contact> contacts = Test_DataFactory.createContacts(20);
        List<Task> tasks = Test_DataFactory.createTasks(20);
        Account acc = new Account();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            acc.Name = 'test1';
            insert acc;
            for(Contact c : contacts){
                c.AccountId = acc.Id;
            }
            for(Task t : tasks){
                t.WhatId = acc.Id;
            }
            
            insert contacts;
            insert tasks;
        }
        
        // Submitting a blank string as retailer Id, should return error
        Telia_WebService.Request request = new Telia_WebService.Request();
        // If not handled, this query will return all leads in the system!
        request.orgNumber = 'ABC \' OR Id != \'ABC';
        system.debug('request.orgNumber: ' + request.orgNumber);
        
        // The Web Service should handle the attempted SOQL injection and return no records.
        Telia_WebService.ActivityResponse activityResponse = Telia_WebService.getActivities(request);
        System.assertEquals(activityResponse.success, false, 'The call should not be successful');
        System.assertEquals(activityResponse.errorMsg, Telia_WebService.ERR_NO_RECORDS, 'Incorrect error message');
        System.assertEquals(activityResponse.tasks, null, 'The response tasks should be null');
        System.assertEquals(activityResponse.events, null, 'The response events should be null');
        
        // The Web Service should handle the attempted SOQL injection and return no records.
        Telia_WebService.ContactResponse contactResponse = Telia_WebService.getContacts(request);
        System.assertEquals(contactResponse.success, false, 'The call should not be successful');
        System.assertEquals(contactResponse.errorMsg, Telia_WebService.ERR_NO_RECORDS, 'Incorrect error message');
        System.assertEquals(contactResponse.contacts, null, 'The response contacts should be null');
    }
}    
    public static testmethod void no04_testGetActivities(){	
        System.debug('@@Test no04_testGetActivities Starts');
        Test_DataFactory.setUpOrg();
        
        // Create Test Data
        List<Event> events = Test_DataFactory.createEvents(13);
        List<Task> tasks = Test_DataFactory.createTasks(13);
        Account acc = new Account();
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            acc.Name = 'test1';
            acc.Org_Nr__c = '123';
            insert acc;
            Integer day = 0;
            for(Event e : events){
                e.WhatId = acc.Id;
                e.CreatedDate = datetime.newInstance(1986, 05, day);  
                day++;
            }
            
            day = 0;
            for(Task t : tasks){
                t.WhatId = acc.Id;
                t.CreatedDate = datetime.newInstance(1986, 05, day);  
                day++;
            }
            
            insert events;
            insert tasks;
        }
        
        
        Telia_WebService.Request request = new Telia_WebService.Request();
        request.orgNumber = '123';
        request.startDate = datetime.newInstance(1986, 05, 10);
        request.endDate = datetime.newInstance(1986, 05, 13); //Greatness was born
        system.debug('request.orgNumber: ' + request.orgNumber);
        
        Telia_WebService.ActivityResponse activityResponse = Telia_WebService.getActivities(request);
        System.assertEquals(activityResponse.success, true, 'The call should be successful');
        System.assertEquals(activityResponse.tasks.size(), 3, 'The response tasks should have the size of 3');
        System.assertEquals(activityResponse.events.size(), 3, 'The response events should have the size of 3');
    }
    
    public static testmethod void no05_testGetContacts(){	
        System.debug('@@Test no05_testGetContacts Starts');
        Test_DataFactory.setUpOrg();
        
        // Create Test Data
        List<Event> events = Test_DataFactory.createEvents(13);
        List<Task> tasks = Test_DataFactory.createTasks(13);
        Account acc = new Account();
        Account acc2 = new Account();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            acc.Name = 'acc1';
            acc.Org_Nr__c = '123';
            insert acc;
            
            acc2.Name = 'acc2';
            acc2.Org_Nr__c = '321';
            insert acc2;
            
            //10 Contacts
            List<Contact> contacts = Test_DataFactory.createContacts(10);
            
            Boolean firstAcc = true;
            Integer day = 1;
            
            
            //50 % of contacts goes to different acc, in our case 5 of our contacts
            for(Contact con : contacts){
                if(firstAcc){
                    con.AccountId = acc.Id;
                }else{
                    con.AccountId = acc2.Id;
                }
                con.CreatedDate = datetime.newInstance(1986, 05, day);
                day++;
                firstAcc = !firstAcc;
            }

            insert contacts;
        }
        
        
        Telia_WebService.Request request = new Telia_WebService.Request();
        request.orgNumber = '123';
        request.startDate = datetime.newInstance(1986, 05, 1);
        request.endDate = datetime.newInstance(1986, 05, 5);
        system.debug('request.orgNumber: ' + request.orgNumber);
        
        Telia_WebService.ContactResponse contactResponse = Telia_WebService.getContacts(request);
        System.assertEquals(contactResponse.success, true, 'The call should be successful');
     //   System.assertEquals(contactResponse.contacts.size(), 3, 'The response tasks should have the size of 3');
        System.assertEquals(contactResponse.contacts.size(), 2, 'The response tasks should have the size of 2');
    }
}