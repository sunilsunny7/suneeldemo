@isTest
public class ConExcelDownloadctr_isTest {
    @isTest private static void getContacts()
    {
        //Creating the Test Data
        List<contact> lcon = new List<Contact>();
        Account acc;
        Contact con1 = new Contact();
        acc = Test_DataFactory.createOneLargeStandardAccount();
        insert acc;
        con1.FirstName='TestName';
        con1.LastName = 'TestingLastName';
        con1.email = 'Name.Testing@test.com';
        con1.AccountId = acc.Id;
        lcon.add(con1);
        insert lcon;
        
        
        Test.startTest();
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(lcon);
        standardController.setSelected(lcon);
        //Calling the controller
        ConExcelDownloadctr ext = new ConExcelDownloadctr(standardController);
        Test.stopTest();
    }

}