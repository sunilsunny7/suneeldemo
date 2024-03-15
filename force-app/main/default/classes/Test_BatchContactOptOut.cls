@isTest
public class Test_BatchContactOptOut {
       private static testMethod void contactOptOut() {
        //Create KKNR Account
        Account KKNRacc = Test_DataFactory.createOneKundkontoAccount();
        KKNRacc.Marketing_Mails_Opt_Out__c = 'According to agreement';
        KKNRacc.Process_Opt_Out__c = true;
        KKNRacc.Marketing_Mails_Opt_Out_Cygate__c = 'According to agreement';
        insert KKNRacc;
       
        //createOneLargeStandardAccount
        Account largeacc = Test_DataFactory.createOneLargeStandardAccount();
        largeacc.ParentId = KKNRacc.id;
        largeacc.Process_Opt_Out__c = true;
        insert largeacc;
        
        //Create One Contact
        Contact con = Test_DataFactory.createOneContact();
        con.AccountId = largeacc.Id;
        insert con;
        
        //Create KKNR Account
        Account KKNRacc1 = Test_DataFactory.createOneKundkontoAccount();
        KKNRacc1.Marketing_Mails_Opt_Out__c = 'According to agreement';
        KKNRacc1.Process_Opt_Out_Cygate__c  = true;
        KKNRacc1.Marketing_Mails_Opt_Out_Cygate__c = 'According to agreement';
        insert KKNRacc1;
       
        //createOneLargeStandardAccount
        Account largeacc1 = Test_DataFactory.createOneLargeStandardAccount();
        largeacc1.ParentId = KKNRacc1.id;
        largeacc1.Process_Opt_Out_Cygate__c  = true;
        insert largeacc1;
        
        //Create One Contact
        Contact con1 = Test_DataFactory.createOneContact();
        con1.AccountId = largeacc1.Id;
        con1.Email = 'test1@dummy.com';
        insert con1;
        
        //Create KKNR Account
        Account KKNRacc2 = Test_DataFactory.createOneKundkontoAccount();
        KKNRacc.Marketing_Mails_Opt_Out__c = 'According to agreement';
        KKNRacc2.Process_Opt_Out__c = true;
        KKNRacc2.Process_Opt_Out_Cygate__c  = true;
        KKNRacc2.Marketing_Mails_Opt_Out_Cygate__c = 'According to agreement';
         Test.startTest();
        insert KKNRacc2;
       
        //createOneLargeStandardAccount
        Account largeacc2 = Test_DataFactory.createOneLargeStandardAccount();
        largeacc2.ParentId = KKNRacc2.id;
        largeacc2.Process_Opt_Out__c = true;
        largeacc2.Process_Opt_Out_Cygate__c  = true;
        insert largeacc2;
        
        //Create One Contact
        Contact con2 = Test_DataFactory.createOneContact();
        con2.AccountId = largeacc2.Id;
        con2.Email = 'test2@dummy.com';
        insert con2;
        
       
            BatchContactOptOut BatchContactOptOut = new BatchContactOptOut();
            DataBase.executeBatch(BatchContactOptOut);         
 
       Test.stopTest();
        
       }
}