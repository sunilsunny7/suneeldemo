@isTest(SeeAllData = false)
public class Test_BatchToAnonymiseInactiveUsers {

    private static testMethod void toAnonymiseInactiveUsers() {
        
        User salesRep = new User();
        User u = Test_DataFactory.createLargeUser();
        insert u;
        User u1 = Test_DataFactory.createLargeUser();
        insert u1;
        User u2 = Test_DataFactory.createAdminUser();
        insert u2;
        User u3 = Test_DataFactory.createLargeUser();
        insert u3;

        System.runAs(new User(Id = Userinfo.getUserId())) { // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Test_DataFactory.setUpOrg();
            salesRep = Test_DataFactory.createAdminUser();
            insert salesRep;
        }

        System.runAs(salesRep) {
           
            Account largeacc = Test_DataFactory.createOneLargeStandardAccount();
            insert largeacc;
            
            Contact c1= new Contact();
            c1.AccountId=largeacc.Id;
            c1.LastName='test1';            
            insert c1;
            c1.OwnerId=u.id;
            update c1;
            
            Account largeacc1 = Test_DataFactory.createOneLargeStandardAccount();
            insert largeacc1;

            Contact c2= new Contact();
            c2.AccountId=largeacc1.Id;
            c2.LastName='test2';            
            insert c2;
            c2.OwnerId=u3.id;
            update c2;
        } 
        Test.startTest();
        u.IsActive = false;
        update u;
        u.Deactivated_On__c = System.Today() - 2555;
        update u;

        u1.IsActive = false;
        update u1;
        u1.Deactivated_On__c = System.Today() - 800;
        update u1;
        
        u2.IsActive = false;
        update u2;
        u2.Deactivated_On__c = System.Today() - 100;
        update u2;
        
        u3.IsActive = false;
        update u3;
        u3.Deactivated_On__c = System.Today() - 100;
        update u3;
        
        
        

        BatchToAnonymiseInactiveUsers toAnonymizeUser = new BatchToAnonymiseInactiveUsers();
        DataBase.executeBatch(toAnonymizeUser);
        System.debug(u);
        System.debug(u1);
        Test.stopTest();


        /*User usr=[select Firstname from User where Id =:u.Id];
        User usr1=[select Firstname from User where Id =:u1.Id];
        User usr2=[select Firstname from User where Id =:u2.Id];
        User usr3=[select Firstname from User where Id =:u3.Id];
        
        System.assertEquals(usr.FirstName, 'XXXXXXX', 'not anonymized');
        System.assertEquals(usr1.FirstName, 'XXXXXXX', 'not anonymized');
        System.assertEquals(usr2.FirstName, 'Cygate', 'not anonymized');
        System.assertEquals(usr3.FirstName, 'Cygate', 'not anonymized');*/
        

    }
}