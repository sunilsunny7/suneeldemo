@isTest
public class Test_AccountRollUp {

    @isTest static void testInsertAccounts(){
        System.debug('RollupTestStarts');
    
        ExcludedRecords__c exclRecords = new ExcludedRecords__c();
        exclRecords.Name = 'AcntRollUpExcludedRecords';
        exclRecords.Description__c = 'Test';
        insert exclRecords;
        
        exclRecords.Excluded_records_list__c = '0987';
        List<Account> AccountList = new List<Account>();
        List<Account> AccountPList = new List<Account>();
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        Account acc1 = Test_DataFactory.createOneAccount();
        acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        AccountPList.add(acc1);
            
        Account acc2 = Test_DataFactory.createOneAccount();
        acc2.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2);
        AccountPList.add(acc2);    
            
        insert AccountPList;
        
        Account accCh1 = Test_DataFactory.createOneAccount();
        accCh1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        accCh1.ParentId = acc1.Id;
        AccountList.add(accCh1);
        
        Account accCh2 = Test_DataFactory.createOneAccount();
        accCh2.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
        accCh2.ParentId = acc2.Id;
        AccountList.add(accCh2);
        
        Account accCh3 = Test_DataFactory.createOneAccount();
        accCh3.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
        accCh3.ParentId = acc1.Id;
        AccountList.add(accCh3);
        
        insert AccountList;
        
        
        test.startTest();
        
        List<Account> updateAccount = new List<Account>();
        accCh1.ParentId = acc2.Id;
        updateAccount.add(accCh1);
                
        accCh3.ParentId = acc2.Id;
        updateAccount.add(accCh3);
              
        update updateAccount;
        
        updateAccount.clear();
        
        updateAccount.add(accCh2);
        updateAccount.add(accCh1);        
        delete updateAccount;
        
        
        undelete accCh2;
        
        test.stopTest();
        }
    }
    @isTest static void testInsertAccounts1(){
        System.debug('RollupTestStarts1');
    
        Skip_Trigger__c skiptrigger = new Skip_Trigger__c();
        skiptrigger.Name = 'AccountRollupTrigger';
        skiptrigger.PassMethod__c = true;
        insert skiptrigger;
        
        ExcludedRecords__c exclRecords = new ExcludedRecords__c();
        exclRecords.Name = 'AcntRollUpExcludedRecords';
        exclRecords.Description__c = 'Test';
        insert exclRecords;
        
        exclRecords.Excluded_records_list__c = '0987';
        List<Account> AccountList = new List<Account>();
        List<Account> AccountPList = new List<Account>();
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        Account acc1 = Test_DataFactory.createOneAccount();
        acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        AccountPList.add(acc1);
            
        Account acc2 = Test_DataFactory.createOneAccount();
        acc2.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2);
        AccountPList.add(acc2);    
            
        insert AccountPList;
        
        Account accCh1 = Test_DataFactory.createOneAccount();
        accCh1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        accCh1.ParentId = acc1.Id;
        AccountList.add(accCh1);
        
        Account accCh2 = Test_DataFactory.createOneAccount();
        accCh2.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
        accCh2.ParentId = acc2.Id;
        AccountList.add(accCh2);
        
        Account accCh3 = Test_DataFactory.createOneAccount();
        accCh3.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
        accCh3.ParentId = acc1.Id;
        AccountList.add(accCh3);
        
        insert AccountList;
    }
}
}