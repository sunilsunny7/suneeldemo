@isTest
public with sharing class Test_AccountConRelationTriggerHandler {

    public static testmethod void no01_testSetRoleFromContact(){
        System.debug('@@Test no01_testSetContactTeliaId Starts');
        Test_DataFactory.setUpOrg();

        User largeUser;
        Contact con;
        Account accPrimary;
        Account accSecondary;

        System.runAs(new User(Id = Userinfo.getUserId())){
            largeUser = Test_DataFactory.createLargeUser();
            insert largeUser;

            accPrimary = Test_DataFactory.createOneLargeStandardAccount();
            accPrimary.OwnerId = largeUser.Id;
            insert accPrimary;

			accSecondary = Test_DataFactory.createOneLargeStandardAccount();
            accSecondary.OwnerId = largeUser.Id;
            insert accSecondary;
        }

        System.runAs(largeUser){    
            con = Test_DataFactory.createOneContact();
            con.AccountId = accPrimary.Id;
            con.Role__c = 'IT-chef/CTO';
            insert con;
        }
		
		List<AccountContactRelation> acrPrimary = [SELECT Id, IsDirect, Role__c FROM AccountContactRelation];
		System.assertEquals(acrPrimary.size(), 1, 'One Primary Account Contact relationship should have been created');
		System.assertEquals(acrPrimary[0].IsDirect, true, 'The AccountContactRelation should be primary/direct');
		System.assertEquals(acrPrimary[0].Role__c, con.Role__c, 'The AccountContactRelation should have the same Role as the Contact after insert');

        System.runAs(largeUser){
            test.startTest();
            con.Role__c = 'Driftchef';
            update con;

            AccountContactRelation acr = new AccountContactRelation();
            acr.AccountId = accSecondary.Id;
            acr.ContactId = con.Id;
            insert acr;
            test.stopTest();
        }

        // The Role will only be copied from Contact to AccountContactRelation for the primary relationship (isDirect = true)
        List<AccountContactRelation> acrSecondary = [SELECT Id, IsDirect, Role__c FROM AccountContactRelation WHERE IsDirect = false];
		System.assertEquals(acrSecondary.size(), 1, 'One Secondary Account Contact relationship should have been created');
		System.assertEquals(acrSecondary[0].IsDirect, false, 'The AccountContactRelation should not be primary/direct');
		System.assertNotEquals(acrSecondary[0].Role__c, con.Role__c, 'The AccountContactRelation should Role should not be copied and therefore different from the contact');        
        System.assertEquals(acrSecondary[0].Role__c, null, 'The AccountContactRelation should Role should not be copied and should be null');  
        System.assertNotEquals(acrSecondary[0].Role__c, acrPrimary[0].Role__c, 'The Primary and Secondary AccountContactRelation should have different Roles');
    }

}