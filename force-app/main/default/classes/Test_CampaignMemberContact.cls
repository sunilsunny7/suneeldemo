@isTest
public with sharing class Test_CampaignMemberContact{
    static testMethod void verifyRemove_from_campaign(){
        Account testAcc = new Account();
        Contact testCon = new Contact();
        List<Contact> listOfContacts = new List<Contact>();
        Campaign testCamp = new Campaign();
        CampaignMember testCampMem = new CampaignMember();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        //Create Test Account..
        testAcc.Name = 'TestNewAccount';
        testAcc.Org_Nr__c = label.Account_Org_Nr_Telia;
        testAcc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        insert testAcc;
        
        //Create Test Contact..
        testCon.LastName = 'Chavan';
        testCon.AccountId = testAcc.Id;
        listOfContacts.add(testCon);
        insert listOfContacts ;
        
        //Create Test Campaign..
        testCamp.Name = 'Testcamp11';
        testCamp.Type = 'Telefone';
        insert testCamp;
        
        //Create Test Campaign Member..
        testCampMem.CampaignId = testCamp.Id;
        testCampMem.ContactId  = testCon.Id;
        insert testCampMem;

        Test.startTest();
        PageReference pageRef = Page.Remove_Contact_From_Campaign;
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listOfContacts);
        CampaignMemberContact  controller = new CampaignMemberContact(sc);
        controller.Delnow();
        controller.getCampaignName();
        controller.cancel();
        
        delete testCampMem;
        System.assertEquals(testCampMem.IsDeleted, false);
        Test.stopTest();            
        
    }    
}
}