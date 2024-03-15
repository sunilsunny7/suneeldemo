@isTest 
public class TestBatchNotify 
{
    static testMethod void testMethod1() 
    {
        List<Seller__c> sellerList = new list<Seller__c>();
        Id selleruser ;
        Id mngrseller;
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        SMESalesTeam__c tokenCustomSetting = new SMESalesTeam__c();         
        tokenCustomSetting.Name = 'Test Team Name';        
        tokenCustomSetting.Email__c= 'placeholderemail';
        
        insert tokenCustomSetting;
        
        System.runAs(Test_DataFactory.getByPassUser()){
            List<User> largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            List<seller__c>insertList = new List<seller__c>();
            Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            for (Seller__c sellr: [select id,Type__c,User__c,Sales_Team_Name__c,Sales_Unit_Name__c,End_Date__c from seller__c]){
                if(sellr.Type__c == 'Seller'){
                    selleruser = sellr.User__c;
                }else if (sellr.Type__c == 'Sales Team Manager'){
                    mngrseller = sellr.User__c;
                }
                sellr.Sales_Unit_Name__c = 'SME';
                insertList.add(sellr);
            }
            database.update (insertList);
        }
        Test.stopTest();
        List<Account> accList = Test_DataFactory.createAccounts (2);
        accList[0].RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        accList[0].Kundkonto_Nr__c = 'Test' +'001' ;
        accList[0].OwnerId = selleruser;
        
        accList[1].RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        accList[1].Kundkonto_Nr__c = 'Test'+'002' ;
        accList[1].OwnerId = mngrseller;
        database.SaveResult[] Accinsert= database.insert(accList);
        Account LargeAcc1 = Test_DataFactory.createOneLargeStandardAccount();
        LargeAcc1.ParentId = Accinsert[0].getId();
        insert LargeAcc1;
        Account LargeAcc2 = Test_DataFactory.createOneLargeStandardAccount();
        LargeAcc2.ParentId = Accinsert[1].getId();
        insert LargeAcc2;
        List<Contact> ConList = Test_DataFactory.createContacts(4);        
        for(integer i=0;i< ConList.size();i++){
            if(i<2){
                ConList[i].AccountId = LargeAcc1.Id;
                ConList[i].email = 'test@gmail.com';
                ConList[i].recordtypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CUSTOMER) ;
            }else{
                ConList[i].AccountId = LargeAcc2.Id;
                ConList[i].email = 'test@gmail.com';
                ConList[i].recordtypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CUSTOMER) ;
            }
        }
        database.SaveResult[] rslt11= database.insert(ConList);
        Account acc = new Account();
        acc.Id = Accinsert[1].getId();
        acc.OwnerId = selleruser;
        database.SaveResult rslt1= database.update(acc); 
        Account accRec = new Account();
        accRec.Id = Accinsert[0].getId();
        accRec.OwnerId = mngrseller;
        database.SaveResult rsltAccount= database.update(accRec);
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new schduleBatchNotifyCustomer ());
        BatchEmailNotifyCustomer btchCls = new BatchEmailNotifyCustomer();
        database.executeBatch(btchCls);
    }
}