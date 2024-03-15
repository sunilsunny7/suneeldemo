@isTest
public class Test_BatchToPurgeLeads  {
       private static testMethod void purgeLeads() {
       
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
        Lead l1 = Test_DataFactory.createLead();
        insert l1;
        Test.setCreatedDate(l1.Id, DateTime.newInstance(2012,12,12));

        
         Lead l2 = Test_DataFactory.createLead();
         insert l2;   
         l2.Status='Avfärdat';         
         update l2;
         Test.setCreatedDate(l2.Id, DateTime.newInstance(2012,12,12));      
         
         Lead L3 = Test_DataFactory.createLead();
         insert L3; 
         Test.setCreatedDate(l3.Id, DateTime.newInstance(2012,12,12));        
         L3.Status='Konverterat';         
         update l3;
         
         Buy_Interest__c bi1 = new Buy_Interest__c(name='test bi', Lead__c=L1.Id, Submitted_Product_Area__c='Cloud');
         insert bi1;
 
        Test.startTest();
            BatchToPurgeLeads toPurgeLeads = new BatchToPurgeLeads();
            DataBase.executeBatch(toPurgeLeads);            
 
       Test.stopTest();
      
      }
}