@isTest
private class Test_UpdateContOwnerOnLargeAccountsBatch{
    
    @isTest static void testUpdateContactOwnerOnLargeAccountsBatch(){
        User salesRep = new User();
        User testUser = new User();
        Account acc = new Account();
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            salesRep = Test_DataFactory.createAdminUser();
            insert salesRep;
        }
        System.runAs(salesRep) // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
        {
            testUser = Test_DataFactory.createLargeUser();
            testUser.Bypass_VR__c = true;
            insert testUser; 
        }     
        acc = Test_DataFactory.createOneLargeStandardAccount();
        acc.OwnerId = salesRep.Id;
        insert acc;
        List<Contact> listofcontact = new List<Contact>();
        Contact con = new Contact(LastName='TestLastName');
        con.Pardot_Sync__c = 1;
        con.AccountId = acc.Id;
        con.Product_Area__c = LeadTriggerHandler.LEAD_PRODAREA_BB;
        con.FirstName = 'TestFirstName';
        con.Phone = '+460345698';
        con.Email = 'test56@dummy.com';
        con.Role__c = 'IT-chef/CTO';
        listofcontact.add(con);
        Contact con2 = Test_DataFactory.createOneContact();
        con2.AccountId = acc.Id;
        listofcontact.add(con2);
        insert listofcontact;
        Test.StartTest();
        UpdateContactOwnerOnLargeAccountsBatch instancevar = new UpdateContactOwnerOnLargeAccountsBatch();
        ID batchprocessid = Database.executeBatch(instancevar,200);            
        Test.stopTest(); 
        
    } 
}