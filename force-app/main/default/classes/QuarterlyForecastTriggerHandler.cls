/**
About
-----
Description: QuarterlyForecastTriggerHandler
Create date: Jan 2016

Update History
--------------
Created Jan 2016 - A.N Added methods that will create Forecasting Quotas based on Quarterly Forecast Items
Updated Sep 2016 - A.N - Refactored: no functional changes made, cleaned up in debug statements
Updated Feb 2018 - Yogini - Targets (Sales) automatic update(SALEF-842)             
*/

public class QuarterlyForecastTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    private static Map<Id, List<ForecastingQuota>> userFQMap;

    public QuarterlyForecastTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(List<Quarterly_Forecast_Item__c> newList, Map<ID, Quarterly_Forecast_Item__c> newMap){
        System.debug('QuarterlyForecastTriggerHandler.OnAfterInsert start. Number of SOQLs used so far'+Limits.getQueries());
        updateForecastQuotas(newList);
    }

    public void OnAfterUpdate(List<Quarterly_Forecast_Item__c> newList, Map<ID, Quarterly_Forecast_Item__c> newMap, List<Quarterly_Forecast_Item__c> oldList, Map<ID, Quarterly_Forecast_Item__c> oldMap){
        updateForecastQuotas(newList, oldMap);
    }

    // Author AN:
    // For each Quarterly Forecast item, check if New_Sales_Target__c/Continuation_Sales_Target__c is changed
    // Added the Check for Sales_Value_Target__c(SALEF-842)                
    // If yes, update forecast quotas
    private static void updateForecastQuotas(List<Quarterly_Forecast_Item__c> newList, Map<ID, Quarterly_Forecast_Item__c> oldMap){
        List<Quarterly_Forecast_Item__c> qfisForForecastUpdate = new List<Quarterly_Forecast_Item__c>();
        for(Quarterly_Forecast_Item__c newQfi : newList){
            Quarterly_Forecast_Item__c oldQfi = oldMap.get(newQfi.Id);
            if(oldQfi != null && (newQfi.New_Sales_Target__c != oldQfi.New_Sales_Target__c || newQfi.Continuation_Sales_Target__c != oldQfi.Continuation_Sales_Target__c || newQfi.Sales_Value_Target__c != oldQfi.Sales_Value_Target__c)){
                qfisForForecastUpdate.add(newQfi);
            }
        }
        if(!qfisForForecastUpdate.isEmpty()){
            updateForecastQuotas(qfisForForecastUpdate);
        }
    }

    // Author AN:
    // For each Quarterly Forecast item:
    // Check if the user already has a forecasting quota created for the year/quarter for the forecast types.
    // If yes, update the quota
    // If no, create a new quota
    // Added the Check for Sales_Value_Target__c(SALEF-842)
    private static void updateForecastQuotas(List<Quarterly_Forecast_Item__c> newList){
        // Need to filter out all qfi's belonging to inactive sellers.
        // Also the User who owns the QFI's must have ForecastingEnabled (Allow Forecasting checkbox on user object)
        List<Quarterly_Forecast_Item__c> qfisWithActiveSellers = getQfisWithActiveSellers(newList);
        if(qfisWithActiveSellers == null || qfisWithActiveSellers.size() == 0) return;

        loadExistingForecastQuotas(newList);

        List<ForecastingQuota> forecastingQuotasList = new List<ForecastingQuota>();
        Id fqTypeNSid = SEUtility.getForecastingTypeId(SEUtility.OPP_SPLIT_TYPE_NS_DEVNAME);
        Id fqTypeCSid = SEUtility.getForecastingTypeId(SEUtility.OPP_SPLIT_TYPE_CS_DEVNAME);
        Id fqTypeSid = SEUtility.getForecastingTypeId (SEUtility.OPP_SPLIT_TYPE_S_DEVNAME);    
        
        for(Quarterly_Forecast_Item__c qfi : qfisWithActiveSellers){
            Date startDate = getStartDate(Integer.valueOf(qfi.Belongs_To_Year__c), qfi.Name);

            ForecastingQuota existingFQ_NS = getExistingForecastQuota(qfi.User__c, startDate, fqTypeNSid);
            if(existingFQ_NS != null){
                existingFQ_NS.QuotaAmount = qfi.New_Sales_Target__c;
                forecastingQuotasList.add(existingFQ_NS);
            } else {
                forecastingQuotasList.add(new ForecastingQuota(ForecastingTypeId = fqTypeNSid, QuotaAmount = qfi.New_Sales_Target__c,QuotaOwnerId = qfi.User__c, StartDate = startDate));
            }

            ForecastingQuota existingFQ_CS = getExistingForecastQuota(qfi.User__c, startDate, fqTypeCSid);
            if(existingFQ_CS != null){
                existingFQ_CS.QuotaAmount = qfi.Continuation_Sales_Target__c;
                forecastingQuotasList.add(existingFQ_CS);
            } else {
                forecastingQuotasList.add(new ForecastingQuota(ForecastingTypeId = fqTypeCSid, QuotaAmount = qfi.Continuation_Sales_Target__c, QuotaOwnerId = qfi.User__c, StartDate = startDate));
            }
            
            // Author: Yogini
            // Added the Check for Sales_Value_Target__c(SALEF-842)
            
            ForecastingQuota existingFQ_S = getExistingForecastQuota(qfi.User__c, startDate, fqTypeSid); 
            if (existingFQ_S != null) { 
                existingFQ_S.QuotaAmount = qfi.Sales_Value_Target__c; 
                forecastingQuotasList.add (existingFQ_S); 
            } else {
                forecastingQuotasList.add (new ForecastingQuota (ForecastingTypeId = fqTypeSid, QuotaAmount = qfi.Sales_Value_Target__c, QuotaOwnerId = qfi.User__c, StartDate = startDate)); 
            } 
        }

        if(!forecastingQuotasList.isEmpty()){
            System.debug('upserting forecastingQuotasList.size(): ' + forecastingQuotasList.size());
            upsert(forecastingQuotasList);
        }
    }

    // Author AN:
    // For each QFI check if the seller related to the QFI is active. Return a list of the QFIs with active sellers.
    // Also the User who owns the QFI's must have ForecastEnabled=true (Allow Forecasting checkbox on user object)
    private static List<Quarterly_Forecast_Item__c> getQfisWithActiveSellers(List<Quarterly_Forecast_Item__c> newList){
        List<Quarterly_Forecast_Item__c> qfiActiveSellers = new List<Quarterly_Forecast_Item__c>();
        // Load a Map where User.ForecastEnabled + Seller start and end date is queried for each QFI
        Map<Id, Quarterly_Forecast_Item__c> qfiWithSellersMap = new Map<Id, Quarterly_Forecast_Item__c>(
            [SELECT Id, User__c, User__r.ForecastEnabled, Seller__c, Seller__r.Start_Date__c, Seller__r.End_Date__c 
            FROM Quarterly_Forecast_Item__c WHERE Id in :newList]);
        
        for(Quarterly_Forecast_Item__c qfi : newList){
            Quarterly_Forecast_Item__c qfiSeller = qfiWithSellersMap.get(qfi.Id);
            if(qfiSeller != null && qfiSeller.User__c != null && qfiSeller.User__r.ForecastEnabled){
                if(qfiSeller.Seller__c != null && qfiSeller.Seller__r.Start_Date__c <= System.today() && qfiSeller.Seller__r.End_Date__c >= System.today()){
                    qfiActiveSellers.add(qfi);
                }
            }
        }
        return qfiActiveSellers;
    }

    // Author AN:
    // Search the userFQmap for any existing ForecastingQuota for the specified userId with the correct start date and forecast type
    private static ForecastingQuota getExistingForecastQuota(Id userId, Date startDate, Id forecastTypeId){
        if(userFQMap != null){
            if(userFQMap.containsKey(userId)){
                for(ForecastingQuota fq : userFQMap.get(userId)){
                    if(fq.ForecastingTypeId == forecastTypeId && fq.StartDate == startDate){
                        return fq;
                    }
                }
            }
        }
        return null;
    }

    // Author AN:800
    // Returns the Date of the first day of the quarter for a year
    // F.ex. getStartDate(2016,3) => 2016-07-01
    @TestVisible private static Date getStartDate(Integer year, String quarter){
        Integer startMonth = Integer.valueOf(quarter)*3-2;
        return Date.newInstance(year, startMonth, 1);
    }

    // Author AN:
    // Loads all ForecastingQuota for users connected to the quarterly forcasts.
    // Creates a map with the user id as key and a list of forecasting quotas as value
    private static void loadExistingForecastQuotas(List<Quarterly_Forecast_Item__c> newList){
        userFQMap = new Map<Id, List<ForecastingQuota>>();
        List<Id> userIds = new List<Id>();

        for(Quarterly_Forecast_Item__c qfi : newList){
            userIds.add(qfi.User__c);
        }
        for(ForecastingQuota fq : [SELECT ForecastingTypeId, QuotaAmount, QuotaOwnerId, StartDate FROM ForecastingQuota WHERE QuotaOwnerId in :userIds]){
            if(!userFQMap.containsKey(fq.QuotaOwnerId)){
                userFQMap.put(fq.QuotaOwnerId, new List<ForecastingQuota>());
            }
            userFQMap.get(fq.QuotaOwnerId).add(fq);
        }
    }

}