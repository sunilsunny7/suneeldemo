@isTest
private class Test_AccountTeamHandlerManual {

    @testSetup
    static void initTestData() { 
        Test_DataFactory.setUpOrg(); 
    }
	
	@isTest static void insertjob() {
		System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
			Test_AccountTeamHandlerManual.createTestData();
		}

		List<Account> childAccounts = [SELECT ID,ParentId FROM Account WHERE Name like '%Child%'];
		Id parentAccountId = childAccounts[0].parentId;

		User adminUser = Test_DataFactory.createAdminUser();
		System.runAs(adminUser) {
			ExcludedRecords__c exclRecords = new ExcludedRecords__c();
			exclRecords.Name = 'actExcludedAccounts';
			exclRecords.Excluded_records_list__c = parentAccountId;
			insert exclRecords;
		}

		Test.startTest();
		AccountTeamHandlerManual athm = new AccountTeamHandlerManual('delete');
		Database.executeBatch(athm,200);
		Test.stopTest();

	}

	@isTest static void insertjob2() {
		System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
			Test_AccountTeamHandlerManual.createTestData();
		}

		List<Account> childAccounts = [SELECT ID,ParentId FROM Account WHERE Name like '%Child%'];

		User adminUser = Test_DataFactory.createAdminUser();
		System.runAs(adminUser) {
			ExcludedRecords__c exclRecords = new ExcludedRecords__c();
			exclRecords.Name = 'actExcludedAccounts';
			insert exclRecords;
		}

		Test.startTest();
		AccountTeamHandlerManual athm = new AccountTeamHandlerManual('delete');
		Database.executeBatch(athm,200);
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

		System.runAs(adminUser) {
			insert childAccounts;
		}

		List<AccountTeamMember> atms = new List<AccountTeamMember>();
		AccountTeamMember atm_a1 = new AccountTeamMember(AccountId = a.Id,TeamMemberRole = 'Specialist Sales', UserId = u3.Id);
		atms.add(atm_a1);
		AccountTeamMember atm_a2 = new AccountTeamMember(AccountId = a.Id,TeamMemberRole = 'CE/TE', UserId = u4.Id);		
		atms.add(atm_a2);
		AccountTeamMember atm_a3 = new AccountTeamMember(AccountId = a.Id,TeamMemberRole = 'Bid Manager', UserId = u5.Id);		
		atms.add(atm_a3);

		System.runAs(adminUser) {
			insert atms;
		}
	}
}