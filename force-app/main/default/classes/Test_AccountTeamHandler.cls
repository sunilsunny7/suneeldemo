@isTest
private class Test_AccountTeamHandler {

    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
                List<User> users = new List<User>();
          System.runAs(Test_DataFactory.getByPassUser()){  
        User adminUser = Test_DataFactory.createAdminUser();
        users.add(adminUser);
        User u1 = Test_DataFactory.createLargeUser();
        users.add(u1);
        User u2 = Test_DataFactory.createLargeUser();
        users.add(u2);      
        User u3 = Test_DataFactory.createLargeUser();
        users.add(u3);
        User u4 = Test_DataFactory.createLargeUser();
        users.add(u4);
        User u5 = Test_DataFactory.createLargeUser();
        users.add(u5);
        User u6 = Test_DataFactory.createLargeUser();
        users.add(u6);

        insert users;
       
     Test.startTest();
        List<Account> parentAccounts = new List<Account>();
        Account a = new Account(Name='Account A - Parent',OwnerId=u1.Id,RecordTypeId = SEUtility.getRecordTypeId('Sales_Aggregation_Account'));
        parentAccounts.add(a);
        Account b = new Account(Name='Account B - Parent',OwnerId=u6.Id,RecordTypeId = SEUtility.getRecordTypeId('Sales_Aggregation_Account'));
        parentAccounts.add(b);      
        
        
            insert parentAccounts;
        

        List<Id> parentAccountIds = new List<Id>();
        for (Account pacc : parentAccounts) parentAccountIds.add(pacc.Id);      

        List<Account> childAccounts = new List<Account>();      
        Account a_1 = new Account(Name = 'Account A1 - Child',ParentId = a.Id,OwnerId = u2.Id);
        childAccounts.add(a_1);
        Account a_2 = new Account(Name = 'Account A1 - Child',ParentId = a.Id,OwnerId = u3.Id);     
        childAccounts.add(a_2);
        Account a_3 = new Account(Name = 'Account A1 - Child',ParentId = a.Id,OwnerId = u4.Id);             
        childAccounts.add(a_3);

        Account b_1 = new Account(Name = 'Account B1 - Child',ParentId = b.Id,OwnerId = u4.Id);
        childAccounts.add(b_1);
        Account b_2 = new Account(Name = 'Account B1 - Child',ParentId = b.Id,OwnerId = u5.Id);     
        childAccounts.add(b_2);

      
            insert childAccounts;
     

        List<Id> childAccountIds = new List<Id>();
        for (Account acc : childAccounts) childAccountIds.add(acc.Id);

        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        AccountTeamMember atm_a1 = new AccountTeamMember(AccountId = a.Id,TeamMemberRole = 'Specialist Sales', UserId = u3.Id);
        atms.add(atm_a1);
        AccountTeamMember atm_a2 = new AccountTeamMember(AccountId = a.Id,TeamMemberRole = 'CE/TE', UserId = u4.Id);        
        atms.add(atm_a2);
        AccountTeamMember atm_a3 = new AccountTeamMember(AccountId = a.Id,TeamMemberRole = 'Bid Manager', UserId = u5.Id);      
        atms.add(atm_a3);

        AccountTeamMember atm_b1 = new AccountTeamMember(AccountId = b.Id,TeamMemberRole = 'Specialist Sales', UserId = u2.Id);
        atms.add(atm_b1);
        AccountTeamMember atm_b2 = new AccountTeamMember(AccountId = b.Id,TeamMemberRole = 'CE/TE', UserId = u3.Id);        
        atms.add(atm_b2);

        
            insert atms;
      

        List<AccountTeamMember> atms_child = new List<AccountTeamMember>();
        AccountTeamMember atm_a1c = new AccountTeamMember(AccountId = a_1.Id,TeamMemberRole = 'Specialist Sales', UserId = u3.Id);
        atms_child.add(atm_a1c);
        AccountTeamMember atm_a2c = new AccountTeamMember(AccountId = a_2.Id,TeamMemberRole = 'CE/TE', UserId = u4.Id);     
        atms_child.add(atm_a2c);
        AccountTeamMember atm_a3c = new AccountTeamMember(AccountId = a_3.Id,TeamMemberRole = 'Bid Manager', UserId = u5.Id);       
        atms_child.add(atm_a3c);

        AccountTeamMember atm_b1c = new AccountTeamMember(AccountId = b_1.Id,TeamMemberRole = 'Specialist Sales', UserId = u2.Id);
        atms_child.add(atm_b1c);
        AccountTeamMember atm_b2c = new AccountTeamMember(AccountId = b_2.Id,TeamMemberRole = 'CE/TE', UserId = u3.Id);     
        atms_child.add(atm_b2c);        

      
            insert atms_child;
      
        
        List<AccountShare> accountShares = [SELECT Id,UserOrGroupId,Account.Parent.Id,AccountAccessLevel,CaseAccessLevel,OpportunityAccessLevel FROM AccountShare WHERE RowCause = 'Team' and AccountId IN :parentAccountIds];
        for (AccountShare accountShare : accountShares) {
            accountShare.AccountAccessLevel = 'Read';
            accountShare.CaseAccessLevel = 'Read';
            accountShare.OpportunityAccessLevel = 'None';
        }

       
            update accountShares;
        
        Test.stopTest();
        }
    }
    
    @isTest static void deleteAndUpsertjob() {
       /* System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Test_AccountTeamHandler.createTestData();
        }*/
         Test.startTest();
        List<Account> accounts = [SELECT Id,Name from Account];
        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        List<Id> childAccountIds = new List<Id>();
        for (Account a : accounts) {
            if (a.Name.IndexOf('Child') != -1) childAccountIds.add(a.Id);
        }


        List<AccountTeamMember> athChildAccounts = 
            [SELECT Id,TeamMemberRole,UserId,AccountId 
            FROM AccountTeamMember
            WHERE Account.Name LIKE '%Child%'];

        List<AccountTeamMember> athChildAccounts2 = 
            [SELECT Id,TeamMemberRole,UserId,AccountId 
            FROM AccountTeamMember];            

        User adminUser = Test_DataFactory.createAdminUser();
        System.runAs(adminUser) {
            ExcludedRecords__c exclRecords = new ExcludedRecords__c();
            exclRecords.Name = 'actExcludedAccounts';
            insert exclRecords;
            
            ExcludedRecords__c exclRecords2 = new ExcludedRecords__c();
            exclRecords2.Name = 'excludedAccsATMhandler';
            insert exclRecords2;
        }
        
        
        
        AccountTeamHandler ath = new AccountTeamHandler('delete');
        Database.executeBatch(ath,20);
        Test.stopTest();

        List<AccountTeamMember> athChildAccountsUpdate = 
            [SELECT Id,TeamMemberRole,UserId,AccountId 
            FROM AccountTeamMember
            WHERE Account.Name LIKE '%Child%'];         


        List<AccountTeamMember> athAccountsUpdateAll = 
            [SELECT Id,TeamMemberRole,UserId,AccountId 
            FROM AccountTeamMember];


        List<AccountShare> accountShares = 
            [SELECT Id,AccountId,AccountAccessLevel,CaseAccessLevel,ContactAccessLevel,OpportunityAccessLevel,RowCause,UserOrGroupId 
            FROM AccountShare 
            WHERE AccountId IN :childAccountIds AND RowCause = 'Team'];
        
    }

    @isTest static void deleteAndUpsertJobWithCustomSetting() {
    test.startTest();
       /* System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            Test_AccountTeamHandler.createTestData();
        }*/

        List<Account> accounts = [SELECT Id,Name from Account];

        List<Id> childAccountIds = new List<Id>();
        for (Account a : accounts) {
            if (a.Name.IndexOf('Child') != -1) childAccountIds.add(a.Id);
        }

        List<AccountTeamMember> athChildAccounts = 
            [SELECT Id,TeamMemberRole,UserId,AccountId 
            FROM AccountTeamMember
            WHERE Account.Name LIKE '%Child%'];


        Account cAcc = [SELECT Id from Account WHERE Name = 'Account A - Parent' LIMIT 1][0];
        Id parentAccountId = cAcc.Id;
   
        User adminUser = Test_DataFactory.createAdminUser();
        System.runAs(adminUser) {
            ExcludedRecords__c exclRecords = new ExcludedRecords__c();
            exclRecords.Name = 'actExcludedAccounts';
            exclRecords.Excluded_records_list__c = parentAccountId;
            insert exclRecords;
            
            ExcludedRecords__c exclRecords2 = new ExcludedRecords__c();
            exclRecords2.Name = 'excludedAccsATMhandler';
            exclRecords2.Excluded_records_list__c = parentAccountId;
            insert exclRecords2;
        }
             

        
        AccountTeamHandler ath = new AccountTeamHandler('delete');
        Database.executeBatch(ath,20);
       // Test.stopTest();

        List<AccountTeamMember> athChildAccountsUpdate = 
            [SELECT Id,TeamMemberRole,UserId,AccountId 
            FROM AccountTeamMember
            WHERE Account.Name LIKE '%Child%'];

        List<AccountTeamMember> athAccountsUpdateAll = 
            [SELECT Id,TeamMemberRole,UserId,AccountId 
            FROM AccountTeamMember];

        List<AccountShare> accountShares = 
            [SELECT Id,AccountId,AccountAccessLevel,CaseAccessLevel,ContactAccessLevel,OpportunityAccessLevel,RowCause,UserOrGroupId 
            FROM AccountShare 
            WHERE AccountId IN :childAccountIds AND RowCause = 'Team'];
         test.stopTest();
    }

}