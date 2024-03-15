@isTest
private class Test_ATMDeleteScheduler {
  
  // CRON expression: midnight on March 15, 2022.
    // Because this is a test, job executes
    // immediately after Test.stopTest()
  public static String CRON_EXP = '0 0 0 15 3 ? 2032';


  @isTest static void Test_ATMDeleteSchedulerExecute() {
  
    System.runAs(new User(Id = Userinfo.getUserId())){   
    Test_ATMDeleteScheduler.createTestData();    
    User adminUser = Test_DataFactory.createAdminUser();
    }
    
    Test.startTest();
        String jobId = System.schedule('Test - Schedule AccountTeamHandler batch job', CRON_EXP, new ATMDeleteScheduler());

      // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
          NextFireTime
          FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
          ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2032-03-15 00:00:00', 
          String.valueOf(ct.NextFireTime));

      // Verify the scheduled job hasn't run yet.


    Test.stopTest();

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

    insert users;

    List<Account> parentAccounts = new List<Account>();
    Account a = new Account(Name='Account A - Parent',OwnerId=u1.Id);
    parentAccounts.add(a);
    Account b = new Account(Name='Account B - Parent',OwnerId=u6.Id);
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

    Account b_1 = new Account(Name = 'Account B1 - Child',ParentId = a.Id,OwnerId = u4.Id);
    childAccounts.add(b_1);
    Account b_2 = new Account(Name = 'Account B1 - Child',ParentId = a.Id,OwnerId = u5.Id);   
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
    
    
  }

}