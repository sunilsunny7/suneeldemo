/**
 * Created by uly8476 on 2022-05-05.
 * 
 * Modifications:
 * 09.01.2023 [Tomass Brazovskis] SALEF-7949 - Updated Added the setAccountCSBContactedDate_Test() test method to make
 *              the assertion outcome independent of the test-running User's Time Zone.
 */
@IsTest
public with sharing class EventTriggerHandler_Test {
    @TestSetup
    static void testSetup() {
        Test_DataFactory.setUpOrg();
        User byPassUser = Test_DataFactory.getByPassUser();
        System.runAs(byPassUser) {
            List<Account> accounts = Test_DataFactory.createAccounts(1);
            insert accounts;

            User fiberUser = Test_DataFactory.createFiberUser();
            fiberUser.IsActive = true;
            fiberUser.Username = 'fiber.user@test.com';
            insert fiberUser;
        }
    }


    /**@Description:
	 * Test setAccountCSBContactedDate() method.
     * Modifications:
     *  09.01.2023 [TB] SALEF-7949 - Moved assertion to the test User's context.
     **/ 
    @IsTest
    static void setAccountCSBContactedDate_Test() {
        Account account = [SELECT Id, C_SB_Contacted__c FROM Account LIMIT 1];
        User fiberUser = [SELECT Id FROM User WHERE Profile.Name = 'Fiber Base Profile' AND IsActive = TRUE LIMIT 1];

        // date() returns the Date component of a Datetime in the local time zone of the 
        // context User. Therefore, both assertion and Event insertion/date assignments 
        // must be performed within the same User context.
        System.runAs(fiberUser){
            Test.startTest();
            List<Event> events = Test_DataFactory.createEvents(1);
            events[0].WhatId = account.Id;
            events[0].Subject = 'Test Event';
            events[0].OwnerId = fiberUser.Id;
            insert events;
            Test.stopTest();
            Account updatedAccount = [SELECT Id, C_SB_Contacted__c FROM Account LIMIT 1];
            System.assertEquals(System.now().date(), updatedAccount.C_SB_Contacted__c);
        }
    }
}