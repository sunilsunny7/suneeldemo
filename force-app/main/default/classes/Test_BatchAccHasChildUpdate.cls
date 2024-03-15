@isTest
public class Test_BatchAccHasChildUpdate {

    @isTest static void testAccounts() {

        System.runAs(Test_DataFactory.getByPassUser()) {
        
            ExcludedRecords__c exclRecords = new ExcludedRecords__c();
            exclRecords.Name = 'AcntRollUpExcludedRecords';
            exclRecords.Description__c = 'Test';
            exclRecords.Excluded_records_list__c = '00124000008eEEE';
            insert exclRecords;
           

            List < Account > AccountPList = new List < Account > ();
            List < Account > AccountList = new List < Account > ();
            Account acc1 = Test_DataFactory.SegmentedKKnrAccount();
            acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);

            Account acc2 = Test_DataFactory.SegmentedKKnrAccount();
            acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);


            AccountPList.add(acc1);
            AccountPList.add(acc2);

            insert AccountPList;

            Account accCh1 = Test_DataFactory.createOneAccount();
            accCh1.Org_Nr__c = '5565656565';
            AccountList.add(accCh1);


            insert AccountList;

            test.starttest();
            List < Account > updateAccount = new List < Account > ();
            accCh1.Suggested_Parent__c = acc2.Id;
            accCh1.Approved__c = true;
            updateAccount.add(accCh1);

            update updateAccount;
            Database.executeBatch(new BatchAccountSegmention('reparent'), 10);
            Database.executeBatch(new BatchAccHasChildUpdate(), 10);
            test.stoptest();


        }

    }

}