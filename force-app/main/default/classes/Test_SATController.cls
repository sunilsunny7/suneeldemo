@isTest
public class Test_SATController {
    
        @isTest static void testSAT() {
        System.runAs(Test_DataFactory.getByPassUser())
        {  
            List<account> listofaccount = new List<account>();
            List<account> listofexcludedaccount = new List<account>();

            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
            listofaccount.add(acc); 
                                
            Account acc2 = Test_DataFactory.createOneAccount();
            acc2.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
            listofaccount.add(acc2); 
            
            
            insert listofaccount;
            
            Account acc1 = new Account();
            acc1.Name = 'acc1';
            acc1.ParentId = acc.Id;
            insert acc1; 
            
            Contact con = Test_DataFactory.createOneContactWithAccount();
            con.AccountId = acc.id;
            insert con;
            Test.startTest();
            Account acc3 = new Account();
            acc3.Name = 'acc1';
            acc3.ParentId = acc.Id;
            insert acc3; 
            
            Account acc4 = new Account();
            acc4.Name = 'acc1';
            acc4.ParentId = acc2.Id;
            insert acc4; 
            listofexcludedaccount.add(acc3);
                    
            Opportunity opp = Test_DataFactory.createOpportunity();   
            opp.RecordTypeId = SEUtility.getRecordTypeId('Merforsaljningsmojlighet');
            opp.AccountId = acc.id;
            opp.Name = 'MF Opp';
            opp.Send_to_Volume_Sales__c = true;
            insert opp;
           
            Opportunity opp1 = Test_DataFactory.createOpportunity();   
            opp1.RecordTypeId = SEUtility.getRecordTypeId('Merforsaljningsmojlighet');
            opp1.AccountId = acc2.id;
            opp1.Name = 'MF Opp';
            opp1.Send_to_Volume_Sales__c = true;
            insert opp1;
            
            Upsell_Target_Account__c upselacc = new Upsell_Target_Account__c();
            upselacc.Account__c = acc.id;
            upselacc.Opportunity__c = opp.id;
            upselacc.Main_Contact__c = con.id;
            insert upselacc;
            Set<Id> includeaccids = new Set<Id>();
            Set<Id> exaccids = new Set<Id>();
            for(Account ac1 : listofaccount){ includeaccids.add(ac1.id);}
            for(Account ac : listofexcludedaccount){ exaccids.add(ac.id);}

            String accIds  = JSON.serialize(includeaccids);
            String excludedAccIds = JSON.serialize(exaccids);
            SATController.getSelectedAccounts(acc4.id);
            SATController.createCallActivityCampaign(opp.id, 'testC1');
            SATController.createTargetAccounts(accIds ,excludedAccIds ,opp.id);
            SATController.getViewData(opp.Id);
            Test.stopTest();

        }
    }
    @isTest static void testSATController() {
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
            
            Test.startTest();
            insert acc; 
            
            Account acc1 = new Account();
            acc1.Name = 'acc1';
            acc1.ParentId = acc.Id;
            insert acc1; 
            SATController.getSelectedAccounts(acc.id);
            Test.stopTest();


    }
    
}