@isTest
private class Test_CAContactListController {
    @TestSetup
    private static void setup(){
     User Byuser;
     System.runAs(new User(Id = Userinfo.getUserId())){
     Byuser = Test_DataFactory.getByPassUser();
            }
     System.runAs(Byuser){    
        //Creating the Test Data
        List<Account> accList = Test_DataFactory.createAccounts(1);
        insert accList;
        List<Contact> conList = Test_DataFactory.createContacts(2);
        List<Contact> cList;
        for(Contact c : conList){
            c.AccountId = accList[0].Id;
           // cList.add(c);
        }
        insert conList;
        
        Campaign cam = new Campaign();
        cam.name = 'Testing';
        cam.type = 'SMS';
        insert cam;
        
        Call_Activity__c callAct = Test_DataFactory.createCallActivity(cam.Id,accList[0].Id);
        insert callAct;
       }
    }
    @isTest
    private static void getCallActivityisTest(){
        Id CallAct = [SELECT id from Call_Activity__c LIMIT 1].Id;
        CAContactListController.getCallActivity(callAct);
        System.assertNotEquals(null, CallAct);
    }
    @isTest
    private static void getAccountContactsisTest(){
        Id CallAct = [SELECT id from Call_Activity__c LIMIT 1].Id;
        CAContactListController.getAccountContacts(callAct);
    }
    @isTest
    private static void addToCampaginisTest(){
        Id conId = [SELECT id from contact WHERE lastname = 'TestContact' LIMIT 1].Id;
        Id camId = [SELECT id from campaign WHERE name = 'Testing' AND type = 'SMS' LIMIT 1].Id;
        CAContactListController.addToCampagin(conId,camId);
        CAContactListController.removeFromCampagin(conId,camId);
    }

}