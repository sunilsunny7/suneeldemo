@istest
public class Test_UpdateOpportunityCommittedOn {
    // CRON expression: midnight on March 15, 2022.
    // Because this is a test, job executes
    // immediately after Test.stopTest()
    public static String CRON_EXP = '0 0 0 15 3 ? 2032';

    @isTest static void testUpdateOpportunityCommittedOnExecuteScheduledJob() {

        Test.startTest();
        String jobId = System.schedule('Test - Schedule UpdateOpportunityCommittedOnScheduler batch job', CRON_EXP, new UpdateOpportunityCommittedOnScheduler());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2032-03-15 00:00:00', 
        String.valueOf(ct.NextFireTime));

        // Verify the scheduled job hasn't run yet.
        Test.stopTest();
    }

    @isTest static void testUpdateOpportunityCommittedOnBatch() {

        Test_DataFactory.setUpOrg();
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        List<Yearly_Target__c> largeSellerteamYT;
        User salesRep;
        Account acc;


        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            largeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam);
            
            salesRep = largeUserTeam[2];

            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

        System.runAs(salesRep){
                        
            List<Opportunity> opps = new List<Opportunity>();

            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id;
            opp.Seller__c = largeSellerTeam[2].Id; // Should be set automatically, but setting manually as this is not the functionality to verify in this test            
            opps.add(opp);

            for(Integer i = 0; i < 20; i++){
                Opportunity newOpp = opp.clone(false, true);
                opps.add(newOpp);
            }            
   Test.startTest();
            insert opps;
        }

        List<Opportunity> oppList = [SELECT Id, Committed_On__c, Name, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c, Seller__c,
                (SELECT Id FROM Forecast_Opportunity_Links__r) FROM Opportunity];
        List<Committed_Opportunity_Snapshot__c> cosList = new List<Committed_Opportunity_Snapshot__c>();
        for(Opportunity o : oppList){
            System.assertEquals(null, o.Committed_On__c);
            cosList.add(createCommittedOpportunitySnapshot(o));
        }
        insert cosList;

        Map<Id, Committed_Opportunity_Snapshot__c> oppCosMap = new Map<Id, Committed_Opportunity_Snapshot__c>();
        for(Committed_Opportunity_Snapshot__c cos : [SELECT Id, Opportunity__c, CreatedDate FROM Committed_Opportunity_Snapshot__c WHERE ID in :cosList]){
            oppCosMap.put(cos.Opportunity__c, cos);
        }

        
        UpdateOpportunityCommittedOnBatch uocb = new UpdateOpportunityCommittedOnBatch();
        Id batchInstanceId = Database.executeBatch(uocb,100);
        Test.stopTest();

        for(Opportunity o : [SELECT Id, Committed_On__c FROM Opportunity where id in :oppList]){
            Datetime cosCreatedDate = oppCosMap.get(o.Id).CreatedDate;
            System.assertNotEquals(null, o.Committed_On__c);
            System.assertEquals(cosCreatedDate, o.Committed_On__c);
        }

        AsyncApexJob a = [
        SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob 
        WHERE Id = :batchInstanceId
        ];
        System.assertEquals(0, a.NumberOfErrors);
    }

    @isTest static void testUpdateOpportunityCommittedOnBatchFailingRecords() {

        Test_DataFactory.setUpOrg();
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        List<Yearly_Target__c> largeSellerteamYT;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            User bypassVrUser = largeUserTeam[2];
            bypassVrUser.Bypass_VR__c = true;
            update bypassVrUser;
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            largeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam);
        }

        User salesRep = largeUserTeam[2];

        System.runAs(salesRep){  
            Account acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
            
            List<Opportunity> opps = new List<Opportunity>();

            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id;
            opp.Seller__c = largeSellerTeam[2].Id; // Should be set automatically, but setting manually as this is not the functionality to verify in this test            
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL;
            opps.add(opp);

            for(Integer i = 0; i < 20; i++){
                Opportunity newOpp = opp.clone(false, true);
                opps.add(newOpp);
            }            
         Test.startTest();
            insert opps;
        }

        List<Opportunity> oppList = [SELECT Id, Committed_On__c, Name, CloseDate, Large_Continuation_Sales__c, Large_New_Sales__c, Seller__c,
                (SELECT Id FROM Forecast_Opportunity_Links__r) FROM Opportunity];
        List<Committed_Opportunity_Snapshot__c> cosList = new List<Committed_Opportunity_Snapshot__c>();
        for(Opportunity o : oppList){
            System.assertEquals(null, o.Committed_On__c);
            cosList.add(createCommittedOpportunitySnapshot(o));
        }
        insert cosList;

        Id batchInstanceId;
        System.runAs(largeUserTeam[1]){ // Does not have bypassVR set to true 
           // Test.startTest();
            UpdateOpportunityCommittedOnBatch uocb = new UpdateOpportunityCommittedOnBatch();
            batchInstanceId = Database.executeBatch(uocb,100);
            Test.stopTest();
        }

        for(Opportunity o : [SELECT Id, Committed_On__c FROM Opportunity where id in :oppList]){
            System.assertEquals(null, o.Committed_On__c);
        }

        AsyncApexJob a = [
        SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob 
        WHERE Id = :batchInstanceId
        ];
        System.assertEquals(0, a.NumberOfErrors); // The failing records should not throw an exception but update failures are caught by the Database.update
    }

    public static Committed_Opportunity_Snapshot__c createCommittedOpportunitySnapshot(Opportunity opp){
        Committed_Opportunity_Snapshot__c cos = new Committed_Opportunity_Snapshot__c();
        cos.Opportunity__c = opp.Id;
        cos.Name = opp.Name;
        cos.Close_Date__c = opp.CloseDate;
        cos.CS_12_months__c = opp.Large_Continuation_Sales__c;
        cos.NS_12_months__c = opp.Large_New_Sales__c;
        cos.Sales_Team_Manager__c = opp.Seller__c;
        if(opp.Forecast_Opportunity_Links__r != null && opp.Forecast_Opportunity_Links__r.size() > 0){
            cos.FOL__c = opp.Forecast_Opportunity_Links__r[0].Id;
        }
        return cos;
    }

}