@isTest
public class Test_BatchAccountOptOut {
       private static testMethod void accountOptOut() {
       
        //Create KKNR Account
        Account KKNRacc = Test_DataFactory.createOneKundkontoAccount();
        KKNRacc.Marketing_Mails_Opt_Out__c = 'According to agreement';
        KKNRacc.Process_Opt_Out__c = true;
        KKNRacc.Marketing_Mails_Opt_Out_Cygate__c = 'According to agreement';
        insert KKNRacc;
       
        //createOneLargeStandardAccount
        Account largeacc = Test_DataFactory.createOneLargeStandardAccount();
        largeacc.ParentId = KKNRacc.id;
        insert largeacc;
        
        //Create KKNR Account
        Account KKNRacc1 = Test_DataFactory.createOneKundkontoAccount();
        KKNRacc1.Marketing_Mails_Opt_Out__c = 'According to agreement';
        KKNRacc1.Process_Opt_Out_Cygate__c  = true;
        KKNRacc1.Marketing_Mails_Opt_Out_Cygate__c = 'According to agreement';
        insert KKNRacc1;
       
        //createOneLargeStandardAccount
        Account largeacc1 = Test_DataFactory.createOneLargeStandardAccount();
        largeacc1.ParentId = KKNRacc1.id;
        insert largeacc1;
        
        //Create KKNR Account
        Account KKNRacc2 = Test_DataFactory.createOneKundkontoAccount();
        KKNRacc.Marketing_Mails_Opt_Out__c = 'According to agreement';
        KKNRacc2.Process_Opt_Out__c = true;
        KKNRacc2.Process_Opt_Out_Cygate__c  = true;
        KKNRacc2.Marketing_Mails_Opt_Out_Cygate__c = 'According to agreement';
        insert KKNRacc2;
       
        //createOneLargeStandardAccount
        Account largeacc2 = Test_DataFactory.createOneLargeStandardAccount();
        largeacc2.ParentId = KKNRacc2.id;        
        insert largeacc2;
        
        Test.startTest();
            BatchAccountOptOut accountOptbatch = new BatchAccountOptOut();
            DataBase.executeBatch(accountOptbatch);            
 
       Test.stopTest();
      
      }
}