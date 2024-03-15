@isTest
public class AttendeeScannerControllerTest {
    @TestSetup
    private static void setup() {
        Integer randomNumber = Integer.valueof((Math.random() * 100));
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        System.runAs(new User(Bypass_VR__c = true,
                Alias = 'standt', Email='standarduser@testorg.com', Telia_Id__c = '12312421',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+System.now().getTime()+randomNumber, MobilePhone='+46 853684000')) {
            insert new Account(Name = 'Gimbal Logic');
            insert new Contact(Email = 'manager@gimballogic.com', LastName = 'Petrovych', AccountId = [SELECT ID FROM Account WHERE Name = 'Gimbal Logic'].Id);
            insert new Contact(Email = 'developer@gimballogic.com', LastName = 'Petrovych', AccountId = [SELECT ID FROM Account WHERE Name = 'Gimbal Logic'].Id);
            insert new Campaign(Name = 'Test Campaign');
            insert new CampaignMember(Status = 'Sent', ContactId = [SELECT Id FROM Contact WHERE Email = 'developer@gimballogic.com' LIMIT 1].Id, CampaignId = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1].Id);
        }

    }


    @IsTest
    private static void validAddContactById() {
        Id campaignId = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1].Id;
        String barcodeId = [SELECT Id,Barcode_ID__c FROM Contact WHERE Email = 'manager@gimballogic.com' LIMIT 1].Barcode_ID__c;

        AttendeeScannerController.ScannerResponse response = AttendeeScannerController.processContact(barcodeId, campaignId);
    }

    @IsTest
    private static void notFoundById() {
        Id campaignId = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1].Id;
        String barcodeId = '801W0000000jyxmIAA';

        AttendeeScannerController.ScannerResponse response = AttendeeScannerController.processContact(barcodeId, campaignId);

        System.assertEquals('notfound', response.Status);
    }

    @IsTest
    private static void updatedById() {
        Id campaignId = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1].Id;
        String barcodeId = [SELECT Id, Barcode_ID__c FROM Contact WHERE Email = 'developer@gimballogic.com' LIMIT 1].Barcode_ID__c;

        AttendeeScannerController.ScannerResponse response = AttendeeScannerController.processContact(barcodeId, campaignId);
    }
}