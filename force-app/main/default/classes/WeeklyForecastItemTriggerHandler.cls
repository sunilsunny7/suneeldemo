/**
    About
    -----
    Description: Trigger Handler Class for Weekly Forecast Item
    Create date: October 2015

    Update History
    --------------
    Created Oct 2015 - N.W Created
    Updated Sep 2016 - A.N Restructured trigger handler to same standard form used in the other trigger handler classes, merged in functionality previously in the WeeklyForecastItem.trigger
    Updated Sep 2016 - A.N Refactored method updateManagerWeeklyForecastItems: Added filter so that logic only runs when commit/judge values have been updated. Otherwise no functional changes.
                           Created the method addValueToMap as to avoid repeating the same lines of code and increase readability. Removed some debug statements and cleaned up in comments.

**/

public class WeeklyForecastItemTriggerHandler {

    /* * * * * * * * * * * * * * * * * * * * * * * * * * * */
    /* * WeeklyForecastItemTriggerHandler Trigger Calls  * */
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * */

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public WeeklyForecastItemTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(List<Weekly_Forecast_Item__c> newList, Map<ID, Weekly_Forecast_Item__c> newMap){
        System.debug('WeeklyForecastItemTriggerHandler.OnBeforeInsert start. Number of SOQLs used so far'+Limits.getQueries());
    }

    public void OnAfterInsert(List<Weekly_Forecast_Item__c> newList, Map<ID, Weekly_Forecast_Item__c> newMap){
        System.debug('WeeklyForecastItemTriggerHandler.OnAfterInsert start. Number of SOQLs used so far'+Limits.getQueries());
        // In Test mode, the updateManagerWeeklyForecastItems logic is only run on updates, not on inserts (due to limit issues)
        if(!Test.isRunningTest()){
            updateManagerWeeklyForecastItems(newList, null);
        }
    }

    public void OnAfterUpdate(List<Weekly_Forecast_Item__c> newList, Map<ID, Weekly_Forecast_Item__c> newMap, List<Weekly_Forecast_Item__c> oldList, Map<ID, Weekly_Forecast_Item__c> oldMap){
        System.debug('WeeklyForecastItemTriggerHandler.OnAfterUpdate start. Number of SOQLs used so far'+Limits.getQueries());
        updateManagerWeeklyForecastItems(newList, oldMap);
    }

    // Created by A.N - If Weekly forecast item with End Date in the past is inserted, set the isWeekInPast checkbox to true
    // The field isWeekInPast__c is also updated by the scheduled job 'Update Weekly Forecast Week In Past'
    private static void setIsWeekInPast(List<Weekly_Forecast_Item__c> newList){        
        Date thisWeekStartDate = system.today().toStartOfWeek();
        for(Weekly_Forecast_Item__c wfi : newList){
            if(wfi.End_Date__c < thisWeekStartDate && !wfi.isWeekInPast__c){
                wfi.isWeekInPast__c = true;
            }
        }
    }

    /*  Created by N.W
        Method updates values on weeklyforecastitems for sellers on different manager levels 
        and then roll-up to weeklyforecastitems for managers above them in the following order
        Seller -> Sales Team Manager -> Sales Unit Director -> Business Unit Director -> Busines Area Manager
        It can handle weeklyforecastitem updates for managers on any level 
        Note, this is not a recursive function although it mimics the behaviour a bit 
    */
    public static void updateManagerWeeklyForecastItems(List<Weekly_Forecast_Item__c> newList, Map<ID, Weekly_Forecast_Item__c> oldMap) {

        // HANDLE RECURSION - Make sure this runs only once in a transaction
        if (RecursionHandler.firstBeforeRun()) {
            RecursionHandler.finishFirstBeforeRun();
        } else return;

        System.debug('Running updateManagerWeeklyForecastItems');

        // Filter all weeklyforecastitems for which any judge/commit values have been updated (or not null if insert)
        Set<Id> wfisForUpdate = new Set<Id>();
        for(Weekly_Forecast_Item__c wfi : newList) {
            if(oldMap == null && (wfi.Judge_NS__c != null || wfi.Judge_CS__c != null || wfi.New_Sales_Commit__c != null || wfi.Continuation_Sales_Commit__c != null)){
                wfisForUpdate.add(wfi.Id);
            } else if(oldMap != null && (wfi.Judge_NS__c != oldMap.get(wfi.Id).Judge_NS__c || wfi.Judge_CS__c != oldMap.get(wfi.Id).Judge_CS__c || 
                    wfi.New_Sales_Commit__c != oldMap.get(wfi.Id).New_Sales_Commit__c || wfi.Continuation_Sales_Commit__c != oldMap.get(wfi.Id).Continuation_Sales_Commit__c)){
                wfisForUpdate.add(wfi.Id);
            }
        }

        if(wfisForUpdate.isEmpty()) return;
       
        // Get the weekly forecast items in scope
        List<Weekly_Forecast_Item__c> weeklyForecastItems = [SELECT Name,Seller__r.Manager__c,Seller__r.Type__c, Belongs_To_Year__c FROM Weekly_Forecast_Item__c WHERE Id IN :wfisForUpdate];
        System.debug('___ weeklyForecastItems size: ' + weeklyForecastItems.size());

        // Create sets of sales managers ids for the weekly forecast items in the current transaction        
        Set<Id> SELSalesManagerIds = new Set<Id>();
        Set<Id> STMSalesManagerIds = new Set<Id>();
        Set<Id> SUDSalesManagerIds = new Set<Id>();
        Set<Id> BUMSalesManagerIds = new Set<Id>();

        for (Weekly_Forecast_Item__c wfi : weeklyForecastItems) {
            if (wfi.Seller__r.Type__c == SellerTriggerHandler.SELLER_TYPE_SELLER)
                SELSalesManagerIds.add(wfi.Seller__r.Manager__c);
            else if (wfi.Seller__r.Type__c == SellerTriggerHandler.SELLER_TYPE_SALES_TEAM_MGR) 
                STMSalesManagerIds.add(wfi.Seller__r.Manager__c);
            else if (wfi.Seller__r.Type__c == SellerTriggerHandler.SELLER_TYPE_SALES_UNIT_MGR)
                SUDSalesManagerIds.add(wfi.Seller__r.Manager__c);
            else if (wfi.Seller__r.Type__c == SellerTriggerHandler.SELLER_TYPE_BUS_UNIT_MGR) 
                BUMSalesManagerIds.add(wfi.Seller__r.Manager__c);
        }              

        // Create a list of the different weeks used in weeklyForecastItems in the current transaction 
        Set<String> weeks = new Set<String>();
		Integer year;
        for (Weekly_Forecast_Item__c wfi : weeklyForecastItems) {
            if (!weeks.contains(wfi.Name)) {
                weeks.add(wfi.Name);
				if (year == null){
					year = wfi.Belongs_To_Year__c.intValue();
				}			
            }
        }

        // Create maps which contains a pair of manager + week and value (JudgeCS,JudgeNS,Continuation_Sales_Commit__c,New_Sales_Commit__c) 
        Map<String,Decimal> salesManagerWeekAndJudgeNS = new Map<String,Decimal>();
        Map<String,Decimal> salesManagerWeekAndJudgeCS = new Map<String,Decimal>();
        Map<String,Decimal> salesManagerWeekAndCommitNS = new Map<String,Decimal>();
        Map<String,Decimal> salesManagerWeekAndCommitCS = new Map<String,Decimal>();

        List<Weekly_Forecast_Item__c> weeksToUpdate = new List<Weekly_Forecast_Item__c>();
        List<Id> allWeeklyForecastItemsSTMManagerIds = new List<Id>();
        List<Id> allWeeklyForecastItemsSUDManagerIds = new List<Id>();
        List<Id> allWeeklyForecastItemsBUMManagerIds = new List<Id>();

        Decimal judgeValNS;
        Decimal judgeValCS;
        Decimal judgeRollupValNS;
        Decimal judgeRollupValCS;
        Decimal commitValNS;
        Decimal commitValCS;
        Decimal commitRollupValNS;
        Decimal commitRollupValCS;

        try {

            /* 
                * * * * * * * *  SELLERS * * * * * * * * * 
            */
            
            System.debug('___ SELSalesManagerIds size: ' + SELSalesManagerIds.size());

            if (!SELSalesManagerIds.isEmpty()) {
                
                // All weekly forecast items
                List<Weekly_Forecast_Item__c> allWeeklyForecastItemsSELs = 
                    [SELECT Seller__c,Seller__r.Name,Seller__r.Manager__c,Name,Judge_CS__c,Judge_NS__c,Seller__r.Type__c,
                    Continuation_Sales_Commit__c,New_Sales_Commit__c, Belongs_To_Year__c
                    FROM Weekly_Forecast_Item__c 
                    WHERE Seller__r.Manager__c IN :SELSalesManagerIds AND Name IN :weeks AND Belongs_To_Year__c = :year ];

                // Summarize seller NS/CS commit values for the sellers managers
                for (Weekly_Forecast_Item__c wfi : allWeeklyForecastItemsSELs) {
                    commitValNS = (wfi.New_Sales_Commit__c != null ? wfi.New_Sales_Commit__c : 0.0);
                    commitValCS = (wfi.Continuation_Sales_Commit__c != null ? wfi.Continuation_Sales_Commit__c : 0.0);                

                    addValueToMap(salesManagerWeekAndCommitNS, wfi.Seller__r.Manager__c + wfi.Name, commitValNS, 0.0); // NEW SALES - Commit
                    addValueToMap(salesManagerWeekAndCommitCS, wfi.Seller__r.Manager__c + wfi.Name, commitValCS, 0.0); // CONTINUATION SALES - Commit
                }

                System.debug('___ salesManagerWeekAndCommitNS: ' + salesManagerWeekAndCommitNS);
                System.debug('___ salesManagerWeekAndCommitCS: ' + salesManagerWeekAndCommitCS);

                // Get the weekly forecast items for sales managers for the sellers owning the weekly forecast items in the current transaction 
                List<Weekly_Forecast_Item__c> weeklyForecastItemsSELManagers = 
                    [SELECT Seller__c,Seller__r.Manager__c,Name,Judge_NS__c,Judge_CS__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c 
                    FROM Weekly_Forecast_Item__c 
                    WHERE Seller__c IN :SELSalesManagerIds AND Name IN :weeks];

                // Loop over the weeklyForecastItems for the managers, update the roll up judge fields using the map created earlier but looking up the value.
                for (Weekly_Forecast_Item__c wfiSalesManager : weeklyForecastItemsSELManagers) {

                    // Managers of STMS, SUDS
                    allWeeklyForecastItemsSTMManagerIds.add(wfiSalesManager.Seller__r.Manager__c);

                    // It's enough to check one of the maps since both the same key items
                    if (salesManagerWeekAndCommitCS.containsKey(wfiSalesManager.Seller__c + wfiSalesManager.Name)) {
                        wfiSalesManager.Subordinates_Commit_New_Sales__c = salesManagerWeekAndCommitNS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // Set the roll-up field value for New Sales
                        wfiSalesManager.Subordinates_Commit_Continuation_Sales__c = salesManagerWeekAndCommitCS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // Set the roll-up field value for Continuation Sales
                        weeksToUpdate.add(wfiSalesManager);
                    }
                }

                update weeksToUpdate;
                weeksToUpdate.clear();
                salesManagerWeekAndCommitNS.clear();
                salesManagerWeekAndCommitCS.clear();

            }

            /* 
                * * * * * * * *  SALES TEAM MANAGERS * * * * * * * * * 
            */

            // Add the managers of Sales Team Managers to the set of STM sales managers (i.e. SUDs)
            STMSalesManagerIds.addAll(allWeeklyForecastItemsSTMManagerIds);

            System.debug('___ STMSalesManagerIds size: ' + STMSalesManagerIds.size());

            if (STMSalesManagerIds.size() > 0) {

                // All weekly forecast items
                List<Weekly_Forecast_Item__c> allWeeklyForecastItemsSTMs = 
                    [SELECT Seller__c,Seller__r.Name,Seller__r.Manager__c,Name,Judge_CS__c,Judge_NS__c,Seller__r.Type__c,
                    New_Sales_Commit__c,Continuation_Sales_Commit__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c, Belongs_To_Year__c
                    FROM Weekly_Forecast_Item__c 
                    WHERE Seller__r.Manager__c IN :STMSalesManagerIds AND Name IN :weeks AND Belongs_To_Year__c = :year];

                // Summarize sales managers NS/CS judge values for the sales unit managers
                // Summarize sales managers NS/CS commit values + rollup commit for the sales unit managers
                for (Weekly_Forecast_Item__c wfi : allWeeklyForecastItemsSTMs) {
                    judgeValNS = (wfi.Judge_NS__c != null ? wfi.Judge_NS__c : 0.0);
                    judgeValCS = (wfi.Judge_CS__c != null ? wfi.Judge_CS__c : 0.0);

                    commitValNS = (wfi.New_Sales_Commit__c != null ? wfi.New_Sales_Commit__c : 0.0);
                    commitValCS = (wfi.Continuation_Sales_Commit__c != null ? wfi.Continuation_Sales_Commit__c : 0.0);                      

                    commitRollupValNS = (wfi.Subordinates_Commit_New_Sales__c != null ? wfi.Subordinates_Commit_New_Sales__c : 0.0);
                    commitRollupValCS = (wfi.Subordinates_Commit_Continuation_Sales__c != null ? wfi.Subordinates_Commit_Continuation_Sales__c : 0.0); 

                    addValueToMap(salesManagerWeekAndJudgeNS, wfi.Seller__r.Manager__c + wfi.Name, judgeValNS, 0.0); // NEW SALES - Judge
                    addValueToMap(salesManagerWeekAndJudgeCS, wfi.Seller__r.Manager__c + wfi.Name, judgeValCS, 0.0); // CONTINUATION SALES - Judge

                    addValueToMap(salesManagerWeekAndCommitNS, wfi.Seller__r.Manager__c + wfi.Name, commitValNS, commitRollupValNS); // NEW SALES - Commit
                    addValueToMap(salesManagerWeekAndCommitCS, wfi.Seller__r.Manager__c + wfi.Name, commitValCS, commitRollupValCS); // CONTINUATION SALES - Commit
                }

                System.debug('___ salesManagerWeekAndJudgeNS: ' + salesManagerWeekAndJudgeNS);
                System.debug('___ salesManagerWeekAndJudgeCS: ' + salesManagerWeekAndJudgeCS);
                System.debug('___ salesManagerWeekAndCommitNS: ' + salesManagerWeekAndCommitNS);
                System.debug('___ salesManagerWeekAndCommitCS: ' + salesManagerWeekAndCommitCS);

                // Get the weekly forecast items for sales managers for the sellers owning the weekly forecast items in the current transaction 
                List<Weekly_Forecast_Item__c> weeklyForecastItemsSTMManagers = 
                    [SELECT Seller__c,Seller__r.Manager__c,Name,Judge_NS__c,Judge_CS__c,Roll_up_Judge_NS__c,Roll_up_Judge_CS__c,
                    Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c, Belongs_To_Year__c
                    FROM Weekly_Forecast_Item__c 
                    WHERE Seller__c IN :STMSalesManagerIds AND Name IN :weeks AND Belongs_To_Year__c = :year];

                // Loop over the weeklyForecastItems for the managers, update the roll up judge fields using the map created earlier but looking up the value.
                for (Weekly_Forecast_Item__c wfiSalesManager : weeklyForecastItemsSTMManagers) {
                    // Managers of SUDS, BUMS
                    allWeeklyForecastItemsSUDManagerIds.add(wfiSalesManager.Seller__r.Manager__c);

                    // Set the roll-up field values- it's enough to check one of the maps
                    if (salesManagerWeekAndJudgeCS.containsKey(wfiSalesManager.Seller__c + wfiSalesManager.Name)) {
                        wfiSalesManager.Roll_up_Judge_NS__c = salesManagerWeekAndJudgeNS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // NEW SALES - Judge
                        wfiSalesManager.Subordinates_Commit_New_Sales__c = salesManagerWeekAndCommitNS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // NEW SALES - Commit
                        wfiSalesManager.Roll_up_Judge_CS__c = salesManagerWeekAndJudgeCS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // CONTINUATION SALES - Judge
                        wfiSalesManager.Subordinates_Commit_Continuation_Sales__c = salesManagerWeekAndCommitCS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // CONTINUATION SALES - Commit
                        weeksToUpdate.add(wfiSalesManager);
                    }
                }

                update weeksToUpdate;
                weeksToUpdate.clear();
                salesManagerWeekAndJudgeNS.clear();
                salesManagerWeekAndJudgeCS.clear();
                salesManagerWeekAndCommitNS.clear();
                salesManagerWeekAndCommitCS.clear();                
            }

            /* 
                * * * * * * * * *  SALES UNIT DIRECTORS * * * * * * * * * 
            */

            // Add the managers of Sales Unit Directors to the set of SUD sales managers (i.e. BUMs)
            SUDSalesManagerIds.addAll(allWeeklyForecastItemsSUDManagerIds);

            if (SUDSalesManagerIds.size() > 0) {

                // All weekly forecast items for SUDs
                List<Weekly_Forecast_Item__c> allWeeklyForecastItemsSUDs = 
                    [SELECT Seller__c,Seller__r.Name,Seller__r.Manager__c,Name,Judge_CS__c,Judge_NS__c,Seller__r.Type__c,Roll_up_Judge_NS__c,Roll_up_Judge_CS__c,
                    New_Sales_Commit__c,Continuation_Sales_Commit__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c, Belongs_To_Year__c
                    FROM Weekly_Forecast_Item__c 
                    WHERE Seller__r.Manager__c IN :SUDSalesManagerIds AND Name IN :weeks AND Belongs_To_Year__c = :year];

                // Summarize sales unit managers NS/CS judge values + rollup judge for the sales unit directors
                // Summarize sales unit managers NS/CS commit values + rollup commit for the sales unit directors
                for (Weekly_Forecast_Item__c wfi : allWeeklyForecastItemsSUDs) {
                    judgeValNS = (wfi.Judge_NS__c != null ? wfi.Judge_NS__c : 0.0);
                    judgeValCS = (wfi.Judge_CS__c != null ? wfi.Judge_CS__c : 0.0);

                    judgeRollupValNS = (wfi.Roll_up_Judge_NS__c != null ? wfi.Roll_up_Judge_NS__c : 0.0);
                    judgeRollupValCS = (wfi.Roll_up_Judge_CS__c != null ? wfi.Roll_up_Judge_CS__c : 0.0);

                    commitValNS = (wfi.New_Sales_Commit__c != null ? wfi.New_Sales_Commit__c : 0.0);
                    commitValCS = (wfi.Continuation_Sales_Commit__c != null ? wfi.Continuation_Sales_Commit__c : 0.0);                      

                    commitRollupValNS = (wfi.Subordinates_Commit_New_Sales__c != null ? wfi.Subordinates_Commit_New_Sales__c : 0.0);
                    commitRollupValCS = (wfi.Subordinates_Commit_Continuation_Sales__c != null ? wfi.Subordinates_Commit_Continuation_Sales__c : 0.0); 

                    addValueToMap(salesManagerWeekAndJudgeNS, wfi.Seller__r.Manager__c + wfi.Name, judgeValNS, judgeRollupValNS); // NEW SALES - Judge
                    addValueToMap(salesManagerWeekAndJudgeCS, wfi.Seller__r.Manager__c + wfi.Name, judgeValCS, judgeRollupValCS); // CONTINUATION SALES - Judge

                    addValueToMap(salesManagerWeekAndCommitNS, wfi.Seller__r.Manager__c + wfi.Name, commitValNS, commitRollupValNS); // NEW SALES - Commit
                    addValueToMap(salesManagerWeekAndCommitCS, wfi.Seller__r.Manager__c + wfi.Name, commitValCS, commitRollupValCS); // CONTINUATION SALES - Commit                   
                }

                System.debug('___ salesManagerWeekAndJudgeNS: ' + salesManagerWeekAndJudgeNS);
                System.debug('___ salesManagerWeekAndJudgeCS: ' + salesManagerWeekAndJudgeCS);
                System.debug('___ salesManagerWeekAndCommitNS: ' + salesManagerWeekAndCommitNS);
                System.debug('___ salesManagerWeekAndCommitCS: ' + salesManagerWeekAndCommitCS);

                // Get the weekly forecast items for sales managers of Sales Unit Directors
                List<Weekly_Forecast_Item__c> weeklyForecastItemsSUDManagers = 
                    [SELECT Seller__c,Seller__r.Manager__c,Name,Roll_up_Judge_NS__c,Roll_up_Judge_CS__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c, Belongs_To_Year__c
                    FROM Weekly_Forecast_Item__c 
                    WHERE Seller__c IN :SUDSalesManagerIds AND Name IN :weeks AND Belongs_To_Year__c = :year];

                // Loop over the weeklyForecastItems for the managers, update the roll up judge fields using the map created earlier but looking up the value.
                for (Weekly_Forecast_Item__c wfiSalesManager : weeklyForecastItemsSUDManagers) {
					System.debug('v Iterating weeklyForecastItemsSUDManagers: ' + wfiSalesManager.Name);
                    // Managers of BUMS, BAMS
                    allWeeklyForecastItemsBUMManagerIds.add(wfiSalesManager.Seller__r.Manager__c);

                    // Set the roll-up field values- it's enough to check one of the maps
                    if (salesManagerWeekAndJudgeCS.containsKey(wfiSalesManager.Seller__c + wfiSalesManager.Name)) {
                        wfiSalesManager.Roll_up_Judge_NS__c = salesManagerWeekAndJudgeNS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // NEW SALES - Judge
                        wfiSalesManager.Subordinates_Commit_New_Sales__c = salesManagerWeekAndCommitNS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // NEW SALES - Commit
                        wfiSalesManager.Roll_up_Judge_CS__c = salesManagerWeekAndJudgeCS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // CONTINUATION SALES - Judge
                        wfiSalesManager.Subordinates_Commit_Continuation_Sales__c = salesManagerWeekAndCommitCS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // CONTINUATION SALES - Commit
                        weeksToUpdate.add(wfiSalesManager);
                    }
                }

                update weeksToUpdate;
                weeksToUpdate.clear();
                salesManagerWeekAndJudgeNS.clear();
                salesManagerWeekAndJudgeCS.clear();
                salesManagerWeekAndCommitNS.clear();
                salesManagerWeekAndCommitCS.clear();
            }

            /* 
                * * * * * * * * *  BUSINESS UNIT DIRECTORS * * * * * * * * * 
            */

            // Add the managers of Business Unit Directors to the set of BUM sales managers (i.e. BAMs)
            BUMSalesManagerIds.addAll(allWeeklyForecastItemsBUMManagerIds);

            if (BUMSalesManagerIds.size() > 0) {

                // All weekly forecast items
                List<Weekly_Forecast_Item__c> allWeeklyForecastItemsBUMs = 
                    [SELECT Seller__c,Seller__r.Name,Seller__r.Manager__c,Name,Judge_CS__c,Judge_NS__c,Seller__r.Type__c,Roll_up_Judge_NS__c,Roll_up_Judge_CS__c,
                    New_Sales_Commit__c,Continuation_Sales_Commit__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c, Belongs_To_Year__c 
                    FROM Weekly_Forecast_Item__c 
                    WHERE Seller__r.Manager__c IN :BUMSalesManagerIds AND Name IN :weeks AND Belongs_To_Year__c = :year];

                // Summarize sales unit directors NS/CS judge values + rollup judge for the Business Unit Director
                // Summarize sales unit directors NS/CS commit values + rollup commit for the Business Unit Director
                for (Weekly_Forecast_Item__c wfi : allWeeklyForecastItemsBUMs) {
                    judgeValNS = (wfi.Judge_NS__c != null ? wfi.Judge_NS__c : 0.0);
                    judgeValCS = (wfi.Judge_CS__c != null ? wfi.Judge_CS__c : 0.0);

                    judgeRollupValNS = (wfi.Roll_up_Judge_NS__c != null ? wfi.Roll_up_Judge_NS__c : 0.0);
                    judgeRollupValCS = (wfi.Roll_up_Judge_CS__c != null ? wfi.Roll_up_Judge_CS__c : 0.0);

                    commitValNS = (wfi.New_Sales_Commit__c != null ? wfi.New_Sales_Commit__c : 0.0);
                    commitValCS = (wfi.Continuation_Sales_Commit__c != null ? wfi.Continuation_Sales_Commit__c : 0.0);                      

                    commitRollupValNS = (wfi.Subordinates_Commit_New_Sales__c != null ? wfi.Subordinates_Commit_New_Sales__c : 0.0);
                    commitRollupValCS = (wfi.Subordinates_Commit_Continuation_Sales__c != null ? wfi.Subordinates_Commit_Continuation_Sales__c : 0.0); 

                    addValueToMap(salesManagerWeekAndJudgeNS, wfi.Seller__r.Manager__c + wfi.Name, judgeValNS, judgeRollupValNS); // NEW SALES - Judge
                    addValueToMap(salesManagerWeekAndJudgeCS, wfi.Seller__r.Manager__c + wfi.Name, judgeValCS, judgeRollupValCS); // CONTINUATION SALES - Judge

                    addValueToMap(salesManagerWeekAndCommitNS, wfi.Seller__r.Manager__c + wfi.Name, commitValNS, commitRollupValNS); // NEW SALES - Commit
                    addValueToMap(salesManagerWeekAndCommitCS, wfi.Seller__r.Manager__c + wfi.Name, commitValCS, commitRollupValCS); // CONTINUATION SALES - Commit  
                }

                System.debug('___ salesManagerWeekAndJudgeNS: ' + salesManagerWeekAndJudgeNS);
                System.debug('___ salesManagerWeekAndJudgeCS: ' + salesManagerWeekAndJudgeCS);
                System.debug('___ salesManagerWeekAndCommitNS: ' + salesManagerWeekAndCommitNS);
                System.debug('___ salesManagerWeekAndCommitCS: ' + salesManagerWeekAndCommitCS);

                // Get the weekly forecast items for sales managers for the Sales Team Managers owning the weekly forecast items in the current transaction 
                List<Weekly_Forecast_Item__c> weeklyForecastItemsBUMManagers = 
                    [SELECT Seller__c,Name,Roll_up_Judge_NS__c,Roll_up_Judge_CS__c,Subordinates_Commit_New_Sales__c,Subordinates_Commit_Continuation_Sales__c, Belongs_To_Year__c
                    FROM Weekly_Forecast_Item__c 
                    WHERE Seller__c IN :BUMSalesManagerIds AND Name IN :weeks AND Belongs_To_Year__c = :year];

                // Loop over the weeklyForecastItems for the managers, update the roll up judge fields using the map created earlier but looking up the value.
                for (Weekly_Forecast_Item__c wfiSalesManager : weeklyForecastItemsBUMManagers) {
					System.debug('v Iterating weeklyForecastItemsBUMManagers: ' + wfiSalesManager.Name);

                    // Set the roll-up field values- it's enough to check one of the maps
                    if (salesManagerWeekAndJudgeCS.containsKey(wfiSalesManager.Seller__c + wfiSalesManager.Name)) {            
                        wfiSalesManager.Roll_up_Judge_NS__c = salesManagerWeekAndJudgeNS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // NEW SALES - Judge
                        wfiSalesManager.Subordinates_Commit_New_Sales__c = salesManagerWeekAndCommitNS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // NEW SALES - Commit
                        wfiSalesManager.Roll_up_Judge_CS__c = salesManagerWeekAndJudgeCS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // CONTINUATION SALES - Judge
                        wfiSalesManager.Subordinates_Commit_Continuation_Sales__c = salesManagerWeekAndCommitCS.get(wfiSalesManager.Seller__c + wfiSalesManager.Name); // CONTINUATION SALES - Commit
                        weeksToUpdate.add(wfiSalesManager);
                    }
                }

                update weeksToUpdate;
                weeksToUpdate.clear();
                salesManagerWeekAndJudgeNS.clear();
                salesManagerWeekAndJudgeCS.clear();
                salesManagerWeekAndCommitNS.clear();
                salesManagerWeekAndCommitCS.clear();

            }
        } catch (Exception e) {
            System.debug('___ Exception in WeeklyForecastItemTriggerHandler ' + 
                '\n\n Exception: ' + e);
        }

    }

    private static void addValueToMap(Map<String,Decimal> stringValueMap, String mapKey, Decimal valueToAdd, Decimal rollupValueToAdd) {
        if (stringValueMap.containsKey(mapKey)) {
            stringValueMap.put(mapKey, stringValueMap.get(mapKey) + valueToAdd + rollupValueToAdd);
        } else {
            stringValueMap.put(mapKey, valueToAdd + rollupValueToAdd);
        }
    }
}