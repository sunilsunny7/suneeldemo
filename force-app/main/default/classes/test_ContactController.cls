@istest
public class test_ContactController {
    
    @isTest static void testcontrollermethod() {
        
        Contact con = Test_DataFactory.createOneContactWithAccount();
        con.MobilePhone = '+46734321123';
        insert con;
        ApexPages.StandardController con11 = new ApexPages.StandardController(con);
        ContactController con1 = new ContactController(con11);
        PageReference pageRef = Page.MyBusinessVF;
        pageRef.getParameters().put('Id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef);
        ContactController.logrecord(con.Id);
    }
    @isTest static void testcontrollermethodException() {
        
        Contact con = Test_DataFactory.createOneContactWithAccount();
        con.MobilePhone = '+46734321123';
        insert con;
        ApexPages.StandardController con11 = new ApexPages.StandardController(con);
        ContactController con1 = new ContactController(con11);
        PageReference pageRef = Page.MyBusinessVF;
       // pageRef.getParameters().put('Id', String.valueOf(con.Id));
        Test.setCurrentPage(pageRef);
        ContactController.logrecord(con.Id);
    }
}