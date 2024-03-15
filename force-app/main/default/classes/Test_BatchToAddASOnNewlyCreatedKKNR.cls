@isTest
public with sharing class Test_BatchToAddASOnNewlyCreatedKKNR {

    @isTest static void BatchToAddAgreSitnOnNewlyCreatedKKNR() {
        User largeUser = Test_DataFactory.createLargeUser();
        insert largeUser;

        User largeUser2 = Test_DataFactory.createLargeUser();
        insert largeUser2;

        User cygateUser = Test_DataFactory.createCygateUser();
        insert cygateUser;


        User adminUser = Test_DataFactory.createAdminUser();
        insert adminUser;

        System.runAs(adminUser) {

            Account_Business_Unit__c cs = new Account_Business_Unit__c();
            cs.Name = 'test1';
            insert cs;
            List < Account > listofaccount = new List < Account > ();

            Account acc1 = Test_DataFactory.createOneKundkontoAccount();
            acc1.Business_Unit__c = 'test1';
            acc1.Is_Owner_Changed__c = system.today();
            listofaccount.add(acc1);

            Account acc2 = new Account(Name = 'TestAccount 123');
            acc2.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
            acc2.Business_Unit__c = 'test1';
            acc2.Kundkonto_Nr__c = 'abc' + 00;
            listofaccount.add(acc2);

            insert listofaccount;

            List < Agreement_Situation__c > insertlistofagreementsituationOnkknr = new List < Agreement_Situation__c > ();
            Agreement_Situation__c agre1 = new Agreement_Situation__c();
            agre1.Agreement_Category__c = 'Networks - Mobile Telephony';
            agre1.Supplier__c = 'Telia';
            agre1.KKnr__c = acc1.id;
            agre1.End_Date__c = system.today();
            insertlistofagreementsituationOnkknr.add(agre1);
            insert insertlistofagreementsituationOnkknr;

            List < Agreement_Categories__c > ac = new List < Agreement_Categories__c > ();
            Agreement_Categories__c ac1 = new Agreement_Categories__c();
            Agreement_Categories__c ac2 = new Agreement_Categories__c();
            Agreement_Categories__c ac3 = new Agreement_Categories__c();
            ac1.Name = 'Equipment';
            ac2.Name = 'Services';
            ac3.Name = 'IoT';

            ac.add(ac1);
            ac.add(ac2);
            ac.add(ac3);

            insert ac;

            Account acc3 = Test_DataFactory.createOneKundkontoAccount();
            acc3.Business_Unit__c = 'abc';
            insert acc3;
            Test.setCreatedDate(acc3.Id, System.today());
            Account accCh1 = Test_DataFactory.createOneAccount();
            accCh1.Org_Nr__c = '5565656565';
            accCh1.ParentId = acc3.Id;

            insert accCh1;

            Test.startTest();
            
            Contact c1 = Test_DataFactory.createOneContactWithAccount();
            insert c1;
            
            Account accCh2 = Test_DataFactory.createOneAccount();
            accCh2.Org_Nr__c = '5565656566';
            accCh2.ParentId = acc3.Id;
            accCh2.Primary_Contact__c = c1.Id;

            insert accCh2;

            acc3.Name = 'Changed';
            acc3.OwnerId = largeUser.Id;
            update acc3;

            acc1.Name = 'test Name';
            update acc1;
            
            c1.Deactivation_Date__c = System.Today()- 1;
            update c1;
        }

        BatchToAddAgreSitnOnNewlyCreatedKKNR obj = new BatchToAddAgreSitnOnNewlyCreatedKKNR();
        DataBase.executeBatch(obj);

        Test.stopTest();

    }

}