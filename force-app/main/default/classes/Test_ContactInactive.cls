/**
    About
    -----
    Description: Test Class to test that insert of a task or an event will fail if the user is inactive
	Create date: September 2015
   
    Update History
    --------------
    Created September 2015 - A.N.
    
    Issues / TODOs
    --------------  
*/

@isTest
public with sharing class Test_ContactInactive {
    
    @isTest static void createNewActivityOnInactiveContact(){
        System.debug('@@Test createNewActivityOnInactiveContact Starts');
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            List<User> smeUserTeam;
            User salesRep;
            Account acc;
            
            System.runAs(new User(Id = Userinfo.getUserId())){
                // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
                smeUserTeam = Test_DataFactory.createSmeUserTeam();
                salesRep = smeUserTeam[2];
                acc = Test_DataFactory.createOneAccount();
                acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
                acc.OwnerId = salesRep.Id;
                insert acc;
            }
            
            System.runAs(salesRep){
                
                List<Contact> conList = Test_DataFactory.createContacts(2);
                conList[0].AccountId = acc.Id;
                conList[1].AccountId = acc.Id;
                conList[1].Deactivation_Date__c = System.today();
                insert conList;
                
                List<Task> tasks = Test_DataFactory.createTasks(2);
                List<Event> events = Test_DataFactory.createEvents(2);
                
                Task t1 = tasks[0];
                t1.WhoId = conList[0].id;
                t1.OwnerId = salesRep.Id;
                Database.SaveResult sr1 = Database.insert(t1);
                system.assertEquals(sr1.isSuccess(), true);
                
                Task t2 = tasks[1];
                t2.WhoId = conList[1].id;
                t2.OwnerId = salesRep.Id;
                try{
                    Database.SaveResult sr2 = Database.insert(t2);
                } catch (Exception e){
                    system.assertEquals(e.getTypeName(), 'System.DmlException');
                }
                
                Event e1 = events[0];
                e1.Subject = 'Test';
                e1.StartDateTime = Datetime.newInstance(2015, 1, 1);   
                e1.ActivityDateTime = e1.StartDateTime;
                e1.EndDateTime = e1.StartDateTime.addHours(1);
                e1.WhoId = conList[0].id;
                e1.OwnerId = salesRep.Id;
                Database.SaveResult sr3 = Database.insert(e1);
                system.assertEquals(sr3.isSuccess(), true);
                
                Event e2 = events[1];
                e2.Subject = 'Test';
                e2.StartDateTime = Datetime.newInstance(2015, 1, 1);
                e2.ActivityDateTime = e2.StartDateTime;
                e2.EndDateTime = e1.StartDateTime.addHours(1);
                e2.WhoId = conList[1].id;
                e2.OwnerId = salesRep.Id;
                try{
                    Database.SaveResult sr4 = Database.insert(e2);
                } catch (Exception e){
                    system.assertEquals(e.getTypeName(), 'System.DmlException');
                }
            }
        }
    }
}