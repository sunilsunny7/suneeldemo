@isTest
private class Test_ATMDelete {
  
  @isTest static void deleteAndUpsertjob() {
    Test_ATMDelete.createTestData();

    List<Account> accounts = [SELECT Id,Name from Account];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.Id);
    }

    List<Id> childAccountIds = new List<Id>();
    for (Account a : accounts) {
      if (a.Name.IndexOf('Child') != -1) childAccountIds.add(a.Id);
    }

    System.assertEquals(5,childAccountIds.size());

    List<AccountTeamMember> athChildAccounts = 
      [SELECT Id,TeamMemberRole,UserId,AccountId 
      FROM AccountTeamMember
      WHERE Account.Name LIKE '%Child%'];

    List<AccountTeamMember> athChildAccounts2 = 
      [SELECT Id,TeamMemberRole,UserId,AccountId 
      FROM AccountTeamMember];      

    User adminUser = Test_DataFactory.createAdminUser();
    
    System.assertEquals(5,athChildAccounts.size());
    System.assertEquals(10,athChildAccounts2.size());    

    Test.startTest();
    AccountTeamDelete ath = new AccountTeamDelete();
    Database.executeBatch(ath,20);
    Test.stopTest();

    List<AccountTeamMember> athChildAccountsUpdate = 
      [SELECT Id,TeamMemberRole,UserId,AccountId 
      FROM AccountTeamMember
      WHERE Account.Name LIKE '%Child%'];      

    System.assertEquals(5, athChildAccountsUpdate.size());

    List<AccountTeamMember> athAccountsUpdateAll = 
      [SELECT Id,TeamMemberRole,UserId,AccountId 
      FROM AccountTeamMember];

    // Parent account team member records are still in the system
    System.assertEquals(10, athAccountsUpdateAll.size());

   
  }

  @isTest static void deleteAndUpsertJobWithCustomSetting() {
    Test_ATMDelete.createTestData();

    List<Account> accounts = [SELECT Id,Name from Account];

    List<Id> childAccountIds = new List<Id>();
    for (Account a : accounts) {
      if (a.Name.IndexOf('Child') != -1) childAccountIds.add(a.Id);
    }

    List<AccountTeamMember> athChildAccounts = 
      [SELECT Id,TeamMemberRole,UserId,AccountId 
      FROM AccountTeamMember
      WHERE Account.Name LIKE '%Child%'];

    System.assertEquals(5,childAccountIds.size());

    Account cAcc = [SELECT Id from Account WHERE Name = 'Account A - Parent' LIMIT 1][0];
    Id parentAccountId = cAcc.Id;

    User adminUser = Test_DataFactory.createAdminUser();


    Test.startTest();
    AccountTeamDelete ath = new AccountTeamDelete();
    Database.executeBatch(ath,20);
    Test.stopTest();

    List<AccountTeamMember> athChildAccountsUpdate = 
      [SELECT Id,TeamMemberRole,UserId,AccountId 
      FROM AccountTeamMember
      WHERE Account.Name LIKE '%Child%'];

    System.assertEquals(5,athChildAccountsUpdate.size());

    List<AccountTeamMember> athAccountsUpdateAll = 
      [SELECT Id,TeamMemberRole,UserId,AccountId 
      FROM AccountTeamMember];

    // 9 because 2 (parent) + 2 + 2 (new child atms) + 3 (atms on excluded account)
    System.assertEquals(10, athAccountsUpdateAll.size());

       
  }

    
  private static void createTestData() {

    List<User> users = new List<User>();

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
    
    //Condition added by P.P to remove MIXED_DML Error
    System.runAs(new User(Id = Userinfo.getUserId())){
        insert users;
    }
    List<Account> parentAccounts = new List<Account>();
    Account a = new Account(Name='Account A - Parent',OwnerId=u1.Id,RecordTypeId = SEUtility.getRecordTypeId('Sales_Aggregation_Account'));
    parentAccounts.add(a);
    Account b = new Account(Name='Account B - Parent',OwnerId=u6.Id,RecordTypeId = SEUtility.getRecordTypeId('Sales_Aggregation_Account'));
    parentAccounts.add(b);    
    
    System.runAs(adminUser) {
      insert parentAccounts;
    }

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

    System.runAs(adminUser) {
      insert childAccounts;
    }

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

    System.runAs(adminUser) {
      insert atms;
    }

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

    System.runAs(adminUser) {
      insert atms_child;
    }

 
  }
}