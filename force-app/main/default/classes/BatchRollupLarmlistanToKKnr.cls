// Note: This batch job might hit the "Apex heap size"-limit if there are too many records in each batch. If so, rerun the batch with a smaller number of records in each batch.
// Id batchInstanceId = Database.executeBatch(new BatchRollupLarmlistanToKKnr(), 100); // Batchsize 100

global class BatchRollupLarmlistanToKKnr implements Database.Batchable<sObject>  {

    String query;
    Set<Id> kknrIdsWithLargeOrgChildAccs = new Set<Id>();
    Set<Id> largeAccRecTypeIds;
    Set<Id> kknrRecTypeIds;
    
    global BatchRollupLarmlistanToKKnr() {
        
        //Adding SME record type to query
        largeAccRecTypeIds = new Set<Id>{SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE), SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC1), SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC2),SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME )};
        kknrRecTypeIds = new Set<Id>{SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK), SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC1), SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK_SEC2)};
     

        // Approx 1800 unique kknrs
       // System.debug('Number of KKnrs : ' + kknrRecTypeIds .size());
        query = 'SELECT Id FROM Account WHERE RecordTypeId in :kknrRecTypeIds ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> kknrListInput) {
           // Is it possible to query the ChildAccounts directly in the kknrListInput???
            List<Account> kknrList = [SELECT Id, Name, KKnr_Centrex_Mobile_Subscriptions__c, KKnr_Jobb_Mobil_VXL_Subscriptions__c,
            KKnr_Mobile_bindings_exp_within_4_6_mont__c, KKnr_Total_Unbound_Mobile_Subscriptions__c, KKnr_Centrex_Fixed_Connections__c, KKnr_Mobile_Churn_Last_12_months__c,
            KKnr_Europatential_Subscriptions__c, KKnr_Mobile_Broadband__c, KKnr_Total_Unbound_Mobile_Broadband__c, KKnr_Office_Extension_Subscriptions__c,
            KKnr_ISDN_Subscriptions__c, KKnr_Dirigent_Subscriptions__c, KKnr_Mobile_bindings_exp_within_1_3_mont__c, KKnr_Total_Number_Of_Bought_Toppups__c,
            KKnr_Mobile_Surf_Connections__c, KKnr_Subs_With_Other_Default_Operator__c, KKnr_Total_Connections_Touchpoint_Plus__c, KKnr_Number_of_Peak_Mobile_Data__c,
            KKnr_Total_Mobile_Subscriptions__c, KKnr_Telematik__c, KKnr_Total_Unbound_Mobile_Postpaid__c, KKnr_Total_Connections_Touchpoint__c,
            KKnr_Total_Unbound_Surf_Connections__c, KKnr_Mobile_Postpaid__c,KKNr_Bredband_Plus_Subscriptions__c,KKNr_Bredband_Start_Subscriptions_Org_Nr__c,KKNr_Prolane_Access_Subscriptions__c,
            (SELECT Id, Name, Centrex_Mobile_Subscriptions__c, Jobb_Mobil_VXL_Subscriptions__c, Mobile_bindings_exp_within_4_6_months__c,
            Total_Unbound_Mobile_Subscriptions__c, Centrex_Fixed_Connections__c, Mobile_Churn_Last_12_months__c, Europatential_Subscriptions__c,
            Mobile_Broadband_Org__c, Total_Unbound_Mobile_Broadband__c, Office_Extension_Subscriptions__c, ISDN_Subscriptions__c, Dirigent_Subscriptions__c,
            Mobile_bindings_exp_within_1_3_months__c, Total_Number_Of_Bought_Toppups_Org__c, Mobile_Surf_Connections__c, Subs_With_Other_Default_Operator__c,
            Total_Connections_Touchpoint_Plus__c, Number_of_Peak_Mobile_Data_Org__c, Total_Mobile_Subscriptions_Org__c, Telematik_Org__c,
            Total_Unbound_Mobile_Postpaid__c, Total_Connections_Touchpoint__c, Total_Unbound_Surf_Connections__c, Mobile_Postpaid_Org__c, Bredband_Plus_Subscriptions__c, Bredband_Start_Subscriptions_Org__c, Prolane_Access_Subscriptions__c
            FROM ChildAccounts WHERE RecordTypeId IN :largeAccRecTypeIds)
            FROM Account WHERE Id IN :kknrListInput AND Has_Child_Account__c = TRUE];
             
        for(Account kknr : kknrList){
            Decimal noOfCentrexMobileSubscriptions = 0;
            Decimal noOfJobbMobilVXLSubscriptions = 0;
            Decimal noOfMobilebindingsexpwithin46months = 0;
            Decimal noOfTotalUnboundMobileSubscriptions = 0;
            Decimal noOfCentrexFixedConnections = 0;
            Decimal noOfMobileChurnLast12months = 0;
            Decimal noOfEuropatentialSubscriptions = 0;
            Decimal noOfMobileBroadband = 0;
            Decimal noOfTotalUnboundMobileBroadband = 0;
            Decimal noOfOfficeExtensionSubscriptions = 0;
            Decimal noOfISDNSubscriptions = 0;
            Decimal noOfDirigentSubscriptions = 0;
            Decimal noOfMobilebindingsexpwithin13months = 0;
            Decimal noOfTotalNumberOfBoughtToppups = 0;
            Decimal noOfMobileSurfConnections = 0;
            Decimal noOfSubsWithOtherDefaultOperator = 0;
            Decimal noOfTotalConnectionsTouchpointPlus = 0;
            Decimal noOfNumberofPeakMobileData = 0; 
            Decimal noOfTotalMobileSubscriptions = 0;
            Decimal noOfTelematik = 0;
            Decimal noOfTotalUnboundMobilePostpaid = 0;
            Decimal noOfTotalConnectionsTouchpoint = 0;
            Decimal noOfTotalUnboundSurfConnections = 0;
            Decimal noOfMobilePostpaid = 0;
            Decimal noOfBredbandPlusSubscriptions = 0;
            Decimal noOfBredbandStartSubscriptionsOrNr = 0;
            Decimal noOfProlaneAccessSubscriptions = 0;
            
                           
            for(Account org : kknr.ChildAccounts){
                // System.debug('Adding values for account: ' + org.Name);
                noOfCentrexMobileSubscriptions += (org.Centrex_Mobile_Subscriptions__c == null ? 0 : org.Centrex_Mobile_Subscriptions__c);
                noOfJobbMobilVXLSubscriptions += (org.Jobb_Mobil_VXL_Subscriptions__c == null ? 0 : org.Jobb_Mobil_VXL_Subscriptions__c);
                noOfMobilebindingsexpwithin46months += (org.Mobile_bindings_exp_within_4_6_months__c == null ? 0 : org.Mobile_bindings_exp_within_4_6_months__c);
                noOfTotalUnboundMobileSubscriptions += (org.Total_Unbound_Mobile_Subscriptions__c == null ? 0 : org.Total_Unbound_Mobile_Subscriptions__c);
                noOfCentrexFixedConnections += (org.Centrex_Fixed_Connections__c == null ? 0 : org.Centrex_Fixed_Connections__c);
                noOfMobileChurnLast12months += (org.Mobile_Churn_Last_12_months__c == null ? 0 : org.Mobile_Churn_Last_12_months__c);
                noOfEuropatentialSubscriptions += (org.Europatential_Subscriptions__c == null ? 0 : org.Europatential_Subscriptions__c);
                noOfMobileBroadband += (org.Mobile_Broadband_Org__c == null ? 0 : org.Mobile_Broadband_Org__c);
                noOfTotalUnboundMobileBroadband += (org.Total_Unbound_Mobile_Broadband__c == null ? 0 : org.Total_Unbound_Mobile_Broadband__c);
                noOfOfficeExtensionSubscriptions += (org.Office_Extension_Subscriptions__c == null ? 0 : org.Office_Extension_Subscriptions__c);
                noOfISDNSubscriptions += (org.ISDN_Subscriptions__c == null ? 0 : org.ISDN_Subscriptions__c);
                noOfDirigentSubscriptions += (org.Dirigent_Subscriptions__c == null ? 0 : org.Dirigent_Subscriptions__c);
                noOfMobilebindingsexpwithin13months += (org.Mobile_bindings_exp_within_1_3_months__c == null ? 0 : org.Mobile_bindings_exp_within_1_3_months__c);
                noOfTotalNumberOfBoughtToppups += (org.Total_Number_Of_Bought_Toppups_Org__c == null ? 0 : org.Total_Number_Of_Bought_Toppups_Org__c);
                noOfMobileSurfConnections += (org.Mobile_Surf_Connections__c == null ? 0 : org.Mobile_Surf_Connections__c);
                noOfSubsWithOtherDefaultOperator += (org.Subs_With_Other_Default_Operator__c == null ? 0 : org.Subs_With_Other_Default_Operator__c);
                noOfTotalConnectionsTouchpointPlus += (org.Total_Connections_Touchpoint_Plus__c == null ? 0 : org.Total_Connections_Touchpoint_Plus__c);
                noOfNumberofPeakMobileData += (org.Number_of_Peak_Mobile_Data_Org__c == null ? 0 : org.Number_of_Peak_Mobile_Data_Org__c);
                noOfTotalMobileSubscriptions += (org.Total_Mobile_Subscriptions_Org__c == null ? 0 : org.Total_Mobile_Subscriptions_Org__c);
                noOfTelematik += (org.Telematik_Org__c == null ? 0 : org.Telematik_Org__c);
                noOfTotalUnboundMobilePostpaid += (org.Total_Unbound_Mobile_Postpaid__c == null ? 0 : org.Total_Unbound_Mobile_Postpaid__c);
                noOfTotalConnectionsTouchpoint += (org.Total_Connections_Touchpoint__c == null ? 0 : org.Total_Connections_Touchpoint__c);
                noOfTotalUnboundSurfConnections += (org.Total_Unbound_Surf_Connections__c == null ? 0 : org.Total_Unbound_Surf_Connections__c);
                noOfMobilePostpaid += (org.Mobile_Postpaid_Org__c == null ? 0 : org.Mobile_Postpaid_Org__c);
                noOfBredbandPlusSubscriptions += (org.Bredband_Plus_Subscriptions__c== null ? 0 : org.Bredband_Plus_Subscriptions__c);
                noOfBredbandStartSubscriptionsOrNr += (org.Bredband_Start_Subscriptions_Org__c== null ? 0 : org.Bredband_Start_Subscriptions_Org__c);
                noOfProlaneAccessSubscriptions += (org.Prolane_Access_Subscriptions__c== null ? 0 : org.Prolane_Access_Subscriptions__c);
                           
            }
            kknr.KKnr_Centrex_Mobile_Subscriptions__c = noOfCentrexMobileSubscriptions;
            kknr.KKnr_Jobb_Mobil_VXL_Subscriptions__c = noOfJobbMobilVXLSubscriptions;
            kknr.KKnr_Mobile_bindings_exp_within_4_6_mont__c = noOfMobilebindingsexpwithin46months;
            kknr.KKnr_Total_Unbound_Mobile_Subscriptions__c = noOfTotalUnboundMobileSubscriptions;
            kknr.KKnr_Centrex_Fixed_Connections__c = noOfCentrexFixedConnections;
            kknr.KKnr_Mobile_Churn_Last_12_months__c = noOfMobileChurnLast12months;
            kknr.KKnr_Europatential_Subscriptions__c = noOfEuropatentialSubscriptions;
            kknr.KKnr_Mobile_Broadband__c = noOfMobileBroadband;
            kknr.KKnr_Total_Unbound_Mobile_Broadband__c = noOfTotalUnboundMobileBroadband;
            kknr.KKnr_Office_Extension_Subscriptions__c = noOfOfficeExtensionSubscriptions;
            kknr.KKnr_ISDN_Subscriptions__c = noOfISDNSubscriptions;
            kknr.KKnr_Dirigent_Subscriptions__c = noOfDirigentSubscriptions;
            kknr.KKnr_Mobile_bindings_exp_within_1_3_mont__c = noOfMobilebindingsexpwithin13months;
            kknr.KKnr_Total_Number_Of_Bought_Toppups__c = noOfTotalNumberOfBoughtToppups;
            kknr.KKnr_Mobile_Surf_Connections__c = noOfMobileSurfConnections;
            kknr.KKnr_Subs_With_Other_Default_Operator__c = noOfSubsWithOtherDefaultOperator;
            kknr.KKnr_Total_Connections_Touchpoint_Plus__c = noOfTotalConnectionsTouchpointPlus;
            kknr.KKnr_Number_of_Peak_Mobile_Data__c = noOfNumberofPeakMobileData;
            kknr.KKnr_Total_Mobile_Subscriptions__c = noOfTotalMobileSubscriptions;
            kknr.KKnr_Telematik__c = noOfTelematik;
            kknr.KKnr_Total_Unbound_Mobile_Postpaid__c = noOfTotalUnboundMobilePostpaid;
            kknr.KKnr_Total_Connections_Touchpoint__c = noOfTotalConnectionsTouchpoint;
            kknr.KKnr_Total_Unbound_Surf_Connections__c = noOfTotalUnboundSurfConnections;
            kknr.KKnr_Mobile_Postpaid__c = noOfMobilePostpaid;
            kknr.KKNr_Bredband_Plus_Subscriptions__c = noOfBredbandPlusSubscriptions;
            kknr.KKNr_Bredband_Start_Subscriptions_Org_Nr__c = noOfBredbandStartSubscriptionsOrNr;
            kknr.KKNr_Prolane_Access_Subscriptions__c = noOfProlaneAccessSubscriptions;
            
            
        }
        update kknrList;
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch job BatchRollupLarmlistanToKKnr finished');
    }
}