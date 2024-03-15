@isTest
public class Test_AgreementStatusUpdate {

    @testsetup
    public static void setup()
    {
        
		Id typeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Large Organisation').getRecordTypeId();

        Account account=new Account(name='Test',RecordTypeId=typeId);
        insert account;
       	Contract contract=new Contract(Status='Draft',name='Test',AccountId=account.Id);
        insert contract;
   }
   testMethod static void testStatusUpdate()
   {
       Contract con=[select id from contract where name='Test'][0];
       scrive__ScriveDocument__c document=new scrive__ScriveDocument__c();
       document.Name='Test';
       document.scrive__Contract__c=con.id;
       document.scrive__status__c='Sent';
       
       Test.startTest();
       insert document;
       document.scrive__status__c='Signed';
       update document;
       document.scrive__status__c='Rejected';
       update document;
       document.scrive__status__c='Sent';
       update document;
       Test.stopTest();
       
   }
}