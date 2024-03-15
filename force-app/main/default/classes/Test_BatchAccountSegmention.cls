@isTest
public class Test_BatchAccountSegmention  {

    @testSetup static void testAccounts(){
        System.debug('RollupTestStarts');
  
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        
        List<Account> AccountPList = new List<Account>();
        List<Account> AccountList = new List<Account>();
        Account acc1 = Test_DataFactory.SegmentedKKnrAccount();
        acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
              
        Account acc2 = Test_DataFactory.SegmentedKKnrAccount();
        acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        
        Account acc3 = Test_DataFactory.SegmentedKKnrAccount();
        acc3.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        
        Account acc4 = Test_DataFactory.SegmentedKKnrAccount();
        acc4.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        acc4.Suggested_Delsegment__c='A11';
        acc4.Approved__c=true;
        AccountPList.add(acc1);
        AccountPList.add(acc2);
        AccountPList.add(acc3);
        AccountPList.add(acc4);
        insert AccountPList;
        
        Account accCh1 = Test_DataFactory.createOneAccount();
        accCh1.Org_Nr__c='5565656565';
        AccountList.add(accCh1);
        
        Account accCh2 = Test_DataFactory.createOneAccount();
        accCh2.Org_Nr__c='5554656565';
        AccountList.add(accCh2);
        
        Account accCh3 = Test_DataFactory.createOneAccount();
        accCh3.Org_Nr__c='5565667665';
        AccountList.add(accCh3);
        
        Account accCh4 = Test_DataFactory.createOneAccount();
        accCh4.Org_Nr__c='5565007665';
        AccountList.add(accCh4);
        
        Account accCh5 = Test_DataFactory.createOneAccount();
        accCh5.Org_Nr__c='5565037665';
        AccountList.add(accCh5);
        
         Account accCh6 = Test_DataFactory.createOneAccount();
        accCh6.Org_Nr__c='556555665';
        accCh6.ParentId= acc4.Id;
        accCh6.Suggested_Parent__c= acc4.Id;
        AccountList.add(accCh6);
        
        insert AccountList;
        
        
        test.startTest();
        
        List<Account> updateAccount = new List<Account>();
        accCh1.Suggested_Parent__c= acc2.Id;
        accCh1.Approved__c=true;
        updateAccount.add(accCh1);
        
        acc2.Approved__c=true;
        updateAccount.add(acc2);
                
        accCh3.Suggested_Parent__c= acc2.Id;
        accCh3.Approved__c= true;
        updateAccount.add(accCh3);
        
        acc1.Suggested_Sales_Team__c='P&K Key Key';
        acc1.Approved__c=true;
        updateAccount.add(acc1);
        
        accCh4.Suggested_Parent__c= acc2.Id;
        accCh4.Approved__c=true;
        updateAccount.add(accCh4);
        
        accCh5.Suggested_Parent__c= acc3.Id;
        accCh5.Approved__c=true;
        updateAccount.add(accCh5);
        
        accCh2.Suggested_Parent__c= acc2.Id;
        accCh2.Approved__c=true;
        updateAccount.add(accCh2);
        BatchAccountSegmention accountseg = new BatchAccountSegmention('reparent');
        DataBase.executeBatch(accountseg,10);
               
        update updateAccount;
        
        
        
               test.stopTest();
               }
               }
       @istest static void testAccountsRun(){
       test.startTest();        
       
       
       Database.executeBatch(new BatchAccountSegmention('update'), 10);
       Database.executeBatch(new BatchAccountSegmention('reset'), 10);
                 
       test.stopTest();
        }
    }