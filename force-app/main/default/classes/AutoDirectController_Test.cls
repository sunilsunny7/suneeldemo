/**
 * Created by gah4215 on 10/18/2021.
 */
@IsTest

public with sharing class AutoDirectController_Test {
@TestSetup
public static void testSetup (){

    System.runAs(Test_DataFactory.getByPassUser()) { //P.P
        user cygateUser = Test_DataFactory.createCygateUser();
        insert cygateUser;
        Account cygateManagerAcc = new Account(Name = 'Cygate Manager Acc', Cygate_Account_Manager__c = cygateUser.Id, RecordTypeID = SEUtility.getRecordTypeId('Sales_Organisation_Account'));
        insert cygateManagerAcc;
        Id queueId = [SELECT Id FROM Group WHERE  Type = 'Queue' AND NAME = 'Cygate Auto Rules'].Id;
        lead lead1 = new Lead(LastName = 'Lead 1', Status = 'Nytt', Company = 'Cygate Manager Acc', LeadSource = 'Externt Event', RecordTypeId = SEUtility.getRecordTypeId('Cygate_Lead'), ownerID = queueId);
        insert lead1;
        lead lead3 = new Lead(LastName = 'Lead 3', Status = 'Nytt', Company = 'Cygate Manager Acc', LeadSource = 'Externt Event', RecordTypeId = SEUtility.getRecordTypeId('Standard_Telia_Lead'), Account__c = cygateManagerAcc.Id);
        insert lead3;
    }
    User us = [SELECT id FROM User WHERE id = '00524000000TKHT'];
    System.runAs(us) {
        Account integrationUserAcc = new Account(Name = 'Integration User');
        insert integrationUserAcc;
        lead lead2 = new Lead(LastName = 'Lead 2', Status = 'Nytt', Company = 'Cygate Manager Acc', LeadSource = 'Externt Event', RecordTypeId = SEUtility.getRecordTypeId('Cygate_Lead'), Account__c = integrationUserAcc.Id);
        insert lead2;
    }
        General_Lead_Settings__c generalLeadSettings = new General_Lead_Settings__c();
        generalLeadSettings.Name = 'General Settings';
        generalLeadSettings.AD_Integration_User_ID__c = '00524000000TKHT';
        generalLeadSettings.AD_Volume_Sales_BU__c = 'Corporate Clients;Enterprise Clients;Public Sector;';
        generalLeadSettings.AD_TAM_BU__c = 'SOHO;';
        generalLeadSettings.AD_TAM_ID__c = '00G24000000gTrN';
        insert generalLeadSettings;

}
    @IsTest
    public static void getResultTest ()
    {
        lead newLead = [SELECT id, Account__r.Cygate_Account_Manager__c, OwnerId,RecordType.name FROM Lead WHERE LastName = 'Lead 1' LIMIT 1];
        Test.StartTest();
        AutoDirectController.getResult(newLead.Id);
        AutoDirectController.webProcess(newLead.Id);
        System.assertEquals(newLead.Account__r.Cygate_Account_Manager__c, newLead.OwnerId, 'Lead owner doesn\'t change!');
        Test.StopTest();
    }
    @IsTest
    public static void validationTest ()
    {
        lead newLead = [SELECT id, Account__c, LeadSource FROM Lead WHERE LastName = 'Lead 2' LIMIT 1];
        Test.StartTest();
        AutoDirectController.getResult(newLead.Id);
        Test.StopTest();
    }
    @IsTest
    public static void standartTeliaLeadTest ()
    {
        lead newLead = [SELECT id, Account__r.OwnerId, OwnerId FROM Lead WHERE LastName = 'Lead 3' LIMIT 1];
        Test.StartTest();
        AutoDirectController.getResult(newLead.Id);
        System.assertEquals(newLead.Account__r.OwnerId, newLead.OwnerId, 'Lead owner doesn\'t change!');
        Test.StopTest();
    }
}