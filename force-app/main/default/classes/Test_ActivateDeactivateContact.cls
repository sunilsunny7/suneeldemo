/**
About
-----
Description: Test class for ActivateDeactivateContact
Create date: March 2016

Update History
--------------
Created March 2016 - N.G

Issues / TODOs
--------------  

*/
@isTest
private class Test_ActivateDeactivateContact {

    public static testMethod void testActivateDeactivateContact() {
        //Creating SysAdmin User from Data Factory class
        user u = Test_DataFactory.createAdminUser();
        //Running code as System Admin user
        System.runAs(u){
            contact c = Test_DataFactory.createOneContactWithAccount();
            insert c;
            ApexPages.currentPage().getParameters().put('id',c.id);
            ApexPages.StandardController stdContact = new ApexPages.StandardController(c); 
            ActivateDeactivateContact classObj = new ActivateDeactivateContact(stdContact);
            classObj.processRecord();
        }
               
    }
    public static testMethod void testActivateDeactivateContact1() {
        //Creating SysAdmin User from Data Factory class
        user u = Test_DataFactory.createAdminUser();
         //Running code as System Admin user
        System.runAs(u){       
            contact c = Test_DataFactory.createOneContactWithAccount();
            c.Deactivation_Date__c = system.Today();
            insert c;
            ApexPages.currentPage().getParameters().put('id',c.id);
            ApexPages.StandardController stdContact = new ApexPages.StandardController(c); 
            ActivateDeactivateContact classObj = new ActivateDeactivateContact(stdContact);
            classObj.processRecord();
        }
               
    } 
     public static testMethod void testActivateDeactivateContact2() {
        //Creating SysAdmin User from Data Factory class
        user u = Test_DataFactory.createAdminUser();
        //Running code as System Admin user
        System.runAs(u){     
            contact c = Test_DataFactory.createOneContactWithAccount();
            c.Deactivation_Date__c = system.Today();
            insert c;
            ApexPages.currentPage().getParameters().put('id',Null);
            ApexPages.StandardController stdContact = new ApexPages.StandardController(c); 
            ActivateDeactivateContact classObj = new ActivateDeactivateContact(stdContact);
            classObj.processRecord();
        }
               
    } 
}