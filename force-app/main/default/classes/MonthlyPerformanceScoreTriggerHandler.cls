/**
    About
    -----
    Description: MonthlyPerformanceScoreTriggerHandler on Account
    Create date: 14.10-2016

    Update History
    --------------
    Created Sep 2015 - A.N - Created
    Updated Aug 2018 - P.P - Added method setQFSonMPS for SAEF 1196, to add performance fields on Quarterly object with details coming from related Opportunity through Monthly Performance Object

    Issues / TODOs
    --------------     
*/
public class MonthlyPerformanceScoreTriggerHandler {
    
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    /* * MonthlyPerformanceScoreTriggerHandler Trigger Calls * */
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    private Boolean m_isExecuting = false;
    private Integer batchSize = 0;

    private static Map<Id, List<ForecastingQuota>> userFQMap;

    public MonthlyPerformanceScoreTriggerHandler(Boolean isExecuting, Integer size){
        m_isExecuting = isExecuting;
        batchSize = size;       
    }

    public void OnAfterInsert(List<Monthly_Performance_Score__c> newList, Map<ID, Monthly_Performance_Score__c> newMap){
        System.debug('MonthlyPerformanceScoreTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        updateForecastQuotas(newList, null);
    }

    public void OnAfterUpdate(List<Monthly_Performance_Score__c> newList, Map<ID, Monthly_Performance_Score__c> newMap, List<Monthly_Performance_Score__c> oldList, Map<ID, Monthly_Performance_Score__c> oldMap){
        System.debug('MonthlyPerformanceScoreTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        updateForecastQuotas(newList, oldMap);
        updateQPS(newList,oldMap);
    }
    public void onBeforeInsert(List<Monthly_Performance_Score__c> newList){
        System.debug('MonthlyPerformanceScoreTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);    
        setQFSonMPS(newList);
    }
    public void onBeforeUpdate(List<Monthly_Performance_Score__c> newList,Map<Id,Monthly_Performance_Score__c> newMap,  List<Monthly_Performance_Score__c> oldList, Map<ID, Monthly_Performance_Score__c> oldMap ){
        System.debug('MonthlyPerformanceScoreTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);    
        setQFSonMPS(newList);
    }


    // Author AN:
    // For each Monthly_Performance_Score__c, check if Sales_Revenue_Target__c is changed
    // If yes, update forecast quotas
    private static void updateForecastQuotas(List<Monthly_Performance_Score__c> newList, Map<Id, Monthly_Performance_Score__c> oldMap){
        // Filter: Check if Monthly_Performance_Score__c is new or if Sales_Revenue_Target__c on Monthly_Performance_Score__c is changed
        Set<Id> ypsIds = new Set<Id>();
        
        for(Monthly_Performance_Score__c mps : newList){
            if(oldMap == null || mps.Sales_Revenue_Target__c != oldMap.get(mps.Id).Sales_Revenue_Target__c){
                ypsIds.add(mps.Yearly_Performance_Score__c);
            }
        }

        if(ypsIds.isEmpty()) return;

        // Update: Set Forecast Quotas for all years in list
        List<Yearly_Performance_Score__c> ypsList = [SELECT Id, Name, User_Performance__r.User__c, User_Performance__r.User__r.ForecastEnabled,
                                                    (SELECT Id, Sales_Revenue_Target__c FROM Monthly_Performance_Scores__r ORDER BY Name ASC LIMIT 12)
                                                    FROM Yearly_Performance_Score__c WHERE Id in :ypsIds];
        loadExistingForecastQuotas(ypsList);

        List<ForecastingQuota> forecastingQuotasList = new List<ForecastingQuota>();
        Id fqTypeWSid = SEUtility.getForecastingTypeId(SEUtility.OPP_SPLIT_TYPE_WS_DEVNAME);

        //Map<Id, List<Integer>> ypsQuarterSalesRevenueMap() = new Map<Id, List<Integer>>;      
        for(Yearly_Performance_Score__c yps : ypsList){
            if(yps.User_Performance__r.User__r.ForecastEnabled == false) continue; // Adding quotas for users without ForecastEnabled will cause exception

            //Calculate the quarterly amounts for each yearly performance score
            List<Decimal> salesRevenueList = new List<Decimal>{0,0,0,0};
            Integer i = 0;
            for(Monthly_Performance_Score__c mps : yps.Monthly_Performance_Scores__r){ // Note: This list is sorted on Name (01, 02 03 etc) when the list is loaded in the query above
                Integer index = (Integer) i/3; // Adds 
                salesRevenueList[index] += mps.Sales_Revenue_Target__c;
                i++;
            }
            
            for(Integer j = 0; j < 4; j++){
                Integer year = Integer.valueOf(yps.Name);
                Date startDate = Date.newInstance(year, (j+1)*3-2, 1);
                Decimal salesRevenue = salesRevenueList[j];

                ForecastingQuota existingFQ_WS = getExistingForecastQuota(yps.User_Performance__r.User__c, startDate, fqTypeWSid );
                if(existingFQ_WS != null){
                    existingFQ_WS.QuotaAmount = salesRevenue;
                    forecastingQuotasList.add(existingFQ_WS);
                } else {
                    forecastingQuotasList.add(new ForecastingQuota(ForecastingTypeId = fqTypeWSid, QuotaAmount = salesRevenue, QuotaOwnerId = yps.User_Performance__r.User__c, StartDate = startDate));
                }
            }
        }

        System.debug('upserting forecastingQuotasList.size(): ' + forecastingQuotasList.size());
        if(!forecastingQuotasList.isEmpty()){
            upsert(forecastingQuotasList);
        }
    }



    // Author AN:
    // Loads all ForecastingQuota for users connected to the quarterly forcasts.
    // Creates a map with the user id as key and a list of forecasting quotas as value
    private static void loadExistingForecastQuotas(List<Yearly_Performance_Score__c> ypsList){
        userFQMap = new Map<Id, List<ForecastingQuota>>();
        List<Id> userIds = new List<Id>();
        
        for(Yearly_Performance_Score__c yps : ypsList) userIds.add(yps.User_Performance__r.User__c);

        Id fqTypeWSid = SEUtility.getForecastingTypeId(SEUtility.OPP_SPLIT_TYPE_WS_DEVNAME);
        for(ForecastingQuota fq : [SELECT ForecastingTypeId, QuotaAmount, QuotaOwnerId, StartDate FROM ForecastingQuota WHERE QuotaOwnerId in :userIds]){
            if(!userFQMap.containsKey(fq.QuotaOwnerId)){
                userFQMap.put(fq.QuotaOwnerId, new List<ForecastingQuota>());
            }
            userFQMap.get(fq.QuotaOwnerId).add(fq);
        }
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
    //check if this is needed
    private static void setQuarterlyForecastTargetsPoints(List<Monthly_Performance_Score__c> newlist, Map<Id,Monthly_Performance_Score__c> oldMap){
        
    }
    //Author - PP 1196 case number
    private static void setQFSonMPS(List<Monthly_Performance_Score__c> newlist){
        List<Quarterly_Performance_Score__c> qpsScoreList = new List<Quarterly_Performance_Score__c>();
        Map<Id,Id> Q1Map = new Map<Id,Id>();
        Map<Id,Id> Q2Map = new Map<Id,Id>();
        Map<Id,Id> Q3Map = new Map<Id,Id>();
        Map<Id,Id> Q4Map = new Map<Id,Id>();
        List<Id> ypsIdList = new List<Id>();
        List<Monthly_Performance_SCore__C> mpsList = new List<Monthly_Performance_SCore__C>();
       for(Monthly_Performance_SCore__c mps:newList){
           if(mps.Quarterly_Performance_Score__c == Null){
               system.debug('-----here i am----- no qps');
               ypsIdList.add(mps.Yearly_Performance_SCore__c);
               mpsList.add(mps);
           }
       }
        string yearToday= string.Valueof(system.today().Year());
        if(ypsIdList.size()>0){
            system.debug('-----here i am----- inside yps list loop');
            for(Quarterly_Performance_Score__c qps:[Select Id,Name,yearly_Performance_Score__c,yearly_Performance_Score__r.Name FROM Quarterly_Performance_Score__c WHERE Yearly_Performance_Score__r.name =: yearToday AND Yearly_Performance_SCore__c IN: ypsIdList]){
                system.debug('-----here i am----- Inside qps for loop');
                if(qps.Name == 'Q1'){
                    system.debug('-----here i am----- inside Q1');
                    Q1Map.put(qps.Yearly_Performance_Score__c,qps.id);
                }
                else if(qps.Name == 'Q2'){
                    system.debug('-----here i am----- inside Q2');
                    Q2Map.put(qps.Yearly_Performance_Score__c,qps.id);
                }
                else if(qps.Name == 'Q3'){
                    system.debug('-----here i am----- inside Q3');
                    Q3Map.put(qps.Yearly_Performance_Score__c,qps.id);
                }
                else if(qps.Name == 'Q4'){
                    system.debug('-----here i am----- inside Q4');
                    Q4Map.put(qps.Yearly_Performance_Score__c,qps.id);
                }
            }
        
            for(Monthly_Performance_Score__c mps:newList){
                if(mpsList.contains(mps)){
                    if(mps.Name == '01' || mps.name == '02' || mps.Name == '03'){
                        system.debug('-----here i am----- inside M1 M2 M3');
                        mps.Quarterly_Performance_Score__c = Q1Map.get(mps.Yearly_Performance_Score__c);            
                    }
                    if(mps.Name == '04' || mps.name == '05' || mps.Name == '06'){
                        system.debug('-----here i am----- inside M4 M5 M6');
                        mps.Quarterly_Performance_Score__c = Q2Map.get(mps.Yearly_Performance_Score__c);            
                    }
                    if(mps.Name == '07' || mps.name == '08' || mps.Name =='09'){
                        system.debug('-----here i am----- inside M7 M8 M9');
                        mps.Quarterly_Performance_Score__c = Q3Map.get(mps.Yearly_Performance_Score__c);            
                    }
                    if(mps.Name == '10' || mps.name == '11' || mps.Name == '12'){
                        system.debug('-----here i am----- inside M10 M11 M12');
                        mps.Quarterly_Performance_Score__c = Q4Map.get(mps.Yearly_Performance_Score__c);            
                    }
                }
            }
        }
    }
    /*private static void updateQPS(List<Monthly_Performance_SCore__c> newList, Map<Id,Monthly_Performance_SCore__c> oldMap){
        List<Quarterly_Performance_Score__c> qpsupdateList = new List<Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsMap = new Map<Id,Quarterly_Performance_Score__c>();
        List<Monthly_Performance_SCore__c> mpsAllList = new List<Monthly_Performance_Score__C>();
        List<Monthly_Performance_SCore__c> mpsList = new List<Monthly_Performance_SCore__c>();
        List<Id> qpsidList = new List<Id>();
        Set<Monthly_Performance_SCore__c> Q1Set = new Set<Monthly_Performance_SCore__c>();
        Set<Monthly_Performance_SCore__c> Q2Set = new Set<Monthly_Performance_SCore__c>();
        Set<Monthly_Performance_SCore__c> Q3Set = new Set<Monthly_Performance_SCore__c>();
        Set<Monthly_Performance_SCore__c> Q4Set = new Set<Monthly_Performance_SCore__c>();
        Map<string,Set<Monthly_Performance_SCore__c>> QnMap = new Map<string,Set<Monthly_Performance_SCore__c>>();
        //Map<string,Set<Monthly_Performance_SCore__c>> Q2Map = new Map<string,Set<Monthly_Performance_SCore__c>>();
        //Map<string,Set<Monthly_Performance_SCore__c>> Q3Map = new Map<string,Set<Monthly_Performance_SCore__c>>();
        //Map<string,Set<Monthly_Performance_SCore__c>> Q4Map = new Map<string,Set<Monthly_Performance_SCore__c>>();
        for(monthly_Performance_Score__c mps:newlist){
            if((mps.Closed_Opportunities_Product_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Product_Revenue__c) ||(mps.Product_Sales_Revenue_Target__c != oldMap.get(mps.Id).Product_Sales_Revenue_Target__c) ||
               (mps.Closed_Opportunities_Services_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Services_Revenue__c) || (mps.Closed_Opportunities_Total_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Total_Revenue__c) || 
               (mps.Open_Opportunities_Product_Revenue__c  != oldMap.get(mps.id).Open_Opportunities_Product_Revenue__c) || (mps.Open_Opportunities_Services_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Services_Revenue__c) ||
               (mps.Open_Opportunities_Total_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Total_Revenue__c) || (mps.Sales_Revenue_Target__c != oldMap.get(mps.id).Sales_Revenue_Target__c) ||
               (mps.Services_Sales_Revenue_Target__c != oldMap.get(mps.id).Services_Sales_Revenue_Target__c)){
                mpsList.add(mps);    
                qpsIdList.add(mps.Quarterly_Performance_Score__c);
            }
        }
        if(mpsList.size()>0 && qpsidList.size()>0){
            qpsMap = New Map<Id,Quarterly_Performance_Score__c>([SELECT Id, Name, Yearly_Performance_Score__c, 
                                                                Product_Sales_Revenue_Target__c, Sales_Revenue_Target__c, Services_Sales_Revenue_Target__c,
                                                                Closed_Opportunities_Product_Revenue__c, Closed_Opportunities_Services_Revenue__c, Closed_Opportunities_Total_Revenue__c,
                                                                Open_Opportunities_Product_Revenue__c, Open_Opportunities_Services_Revenue__c, Open_Opportunities_Total_Revenue__c
                                                                FROM Quarterly_Performance_Score__c WHERE Id IN: qpsidList]);
            //mpsAllList = [SELECT Id,Name FROM Monthly_Performance_Score__c WHERE Quarterly_Performance_Score__c IN: qpsIdList];                                                    
            for(Monthly_Performance_Score__c mps:[SELECT Id,Name,Product_Sales_Revenue_Target__c, Sales_Revenue_Target__c, Services_Sales_Revenue_Target__c,
                                                                Closed_Opportunities_Product_Revenue__c, Closed_Opportunities_Services_Revenue__c, Closed_Opportunities_Total_Revenue__c,
                                                                Open_Opportunities_Product_Revenue__c, Open_Opportunities_Services_Revenue__c, Open_Opportunities_Total_Revenue__c 
                                                                FROM Monthly_Performance_Score__c WHERE Quarterly_Performance_Score__c IN: qpsIdList]){
                Q1Set.clear(); 
                Q2Set.clear();
                Q3Set.clear();
                Q4Set.clear();
                if(mps.Name == '01' || mps.name == '02' || mps.Name == '03'){
                     Quarterly_Performance_Score__c Qn = new Quarterly_Performance_Score__c(Id = mps.Quarterly_performance_Score__c);
                     //Qn. = 
                    if(QnMap.get('Q1') == Null){
                       
                        Q1Set.add(mps);
                        QnMap.put('Q1',Q1Set);
                    }
                    else {
                        Q1Set = QnMap.get('Q1');
                        Q1Set.add(mps);
                        QnMap.put('Q1',Q1Set);
                    }
                }
                else if(mps.Name == '04' || mps.name == '05' || mps.Name == '06'){
                    if(QnMap.get('Q2') == Null){
                        Q2Set.add(mps);
                        QnMap.put('Q2',Q2Set);
                    }
                    else {
                        Q2Set = QnMap.get('Q2');
                        Q2Set.add(mps);
                        QnMap.put('Q2',Q2Set);
                    }
                }
                else if(mps.Name == '07' || mps.name == '08' || mps.Name == '09'){
                    if(QnMap.get('Q3') == Null){
                        Q3Set.add(mps);
                        QnMap.put('Q3',Q3Set);
                    }
                    else {
                        Q3Set = QnMap.get('Q3');
                        Q3Set.add(mps);
                        QnMap.put('Q3',Q3Set);
                    }
                }
                else if(mps.Name == '10' || mps.name == '11' || mps.Name == '12'){
                    if(QnMap.get('Q4') == Null){
                        Q4Set.add(mps);
                        QnMap.put('Q4',Q1Set);
                    }
                    else {
                        Q4Set = QnMap.get('Q4');
                        Q4Set.add(mps);
                        QnMap.put('Q4',Q4Set);
                    }
                }

            }
            //need mpsAllList query here
            if(qpsMap.size()>0){
            
                
                /*for(Monthly_Performance_SCore__c mps:mpsList){
                    quarterly_performance_Score__c qps = qpsMap.get(mps.Quarterly_performance_score__c);
                    if(mps.Closed_Opportunities_Product_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Product_Revenue__c){
                        qps.Closed_Opportunities_Product_Revenue__c = mps.Closed_Opportunities_Product_Revenue__c;
                    }
                    if(mps.Closed_Opportunities_Services_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Services_Revenue__c){
                        qps.Closed_Opportunities_Services_Revenue__c = mps.Closed_Opportunities_Services_Revenue__c;
                    }
                    if(mps.Closed_Opportunities_Total_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Total_Revenue__c){
                        qps.Closed_Opportunities_Total_Revenue__c = mps.Closed_Opportunities_Total_Revenue__c;
                    }
                    if(mps.Open_Opportunities_Product_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Product_Revenue__c){
                        qps.Open_Opportunities_Product_Revenue__c = mps.Open_Opportunities_Product_Revenue__c;
                    }
                    if(mps.Open_Opportunities_Services_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Services_Revenue__c){
                        qps.Open_Opportunities_Services_Revenue__c = mps.Open_Opportunities_Services_Revenue__c;
                    }
                    if(mps.Open_Opportunities_Total_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Total_Revenue__c){
                        qps.Open_Opportunities_Total_Revenue__c = mps.Open_Opportunities_Total_Revenue__c;
                    }
                    if(mps.Product_Sales_Revenue_Target__c != oldMap.get(mps.Id).Product_Sales_Revenue_Target__c){
                        qps.Product_Sales_Revenue_Target__c = mps.Product_Sales_Revenue_Target__c;
                    }
                    if(mps.Sales_Revenue_Target__c != oldMap.get(mps.id).Sales_Revenue_Target__c){
                        qps.Sales_Revenue_Target__c = mps.Sales_Revenue_Target__c;
                    }
                    if(mps.Services_Sales_Revenue_Target__c != oldMap.get(mps.id).Services_Sales_Revenue_Target__c ){
                        qps.Services_Sales_Revenue_Target__c = mps.Services_Sales_Revenue_Target__c;
                    }
                    qpsupdateList.add(qps);
                }*/
      /*      }          
        }
        if(qpsupdateList.size()>0){
            update qpsUpdateList;
        }
    }
    */
    private static void updateQPS(List<Monthly_Performance_SCore__c> newList, Map<Id,Monthly_Performance_SCore__c> oldMap){
        List<Quarterly_Performance_Score__c> qpsupdateList = new List<Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsMap = new Map<Id,Quarterly_Performance_Score__c>();
        List<Monthly_Performance_SCore__c> mpsAllList = new List<Monthly_Performance_Score__C>();
        List<Monthly_Performance_SCore__c> mpsList = new List<Monthly_Performance_SCore__c>();
        List<Id> qpsidList = new List<Id>();
        Set<Monthly_Performance_SCore__c> Q1Set = new Set<Monthly_Performance_SCore__c>();
        Set<Monthly_Performance_SCore__c> Q2Set = new Set<Monthly_Performance_SCore__c>();
        Set<Monthly_Performance_SCore__c> Q3Set = new Set<Monthly_Performance_SCore__c>();
        Set<Monthly_Performance_SCore__c> Q4Set = new Set<Monthly_Performance_SCore__c>();
        //Map<string,Set<Monthly_Performance_SCore__c>> QnMap = new Map<string,Set<Monthly_Performance_SCore__c>>();
        Map<Id,Quarterly_Performance_Score__c> QnMap = new Map<Id,Quarterly_Performance_Score__c>();
        List<Quarterly_Performance_Score__c> updateQnList = new List<Quarterly_Performance_Score__c>();
        Set<id> qpsCP= new SET<id>();
        Set<id> qpsCS= new SET<id>();
        Set<id> qpsCT= new SET<id>();
        Set<id> qpsOP= new SET<id>();
        Set<id> qpsOS= new SET<id>();
        Set<id> qpsOT= new SET<id>();
        Set<id> qpsTP= new SET<id>();
        Set<id> qpsTS= new SET<id>();
        Set<id> qpsTT= new SET<id>();
        Map<Id,Quarterly_Performance_Score__c> qpsCPMap = new Map<Id,Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsCSMap = new Map<Id,Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsCTMap = new Map<Id,Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsOPMap = new Map<Id,Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsOSMap = new Map<Id,Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsOTMap = new Map<Id,Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsTPMap = new Map<Id,Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsTSMap = new Map<Id,Quarterly_Performance_Score__c>();
        Map<Id,Quarterly_Performance_Score__c> qpsTTMap = new Map<Id,Quarterly_Performance_Score__c>();
        //Map<string,Set<Monthly_Performance_SCore__c>> Q2Map = new Map<string,Set<Monthly_Performance_SCore__c>>();
        //Map<string,Set<Monthly_Performance_SCore__c>> Q3Map = new Map<string,Set<Monthly_Performance_SCore__c>>();
        //Map<string,Set<Monthly_Performance_SCore__c>> Q4Map = new Map<string,Set<Monthly_Performance_SCore__c>>();
        for(monthly_Performance_Score__c mps:newlist){
            if((mps.Closed_Opportunities_Product_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Product_Revenue__c) ||(mps.Product_Sales_Revenue_Target__c != oldMap.get(mps.Id).Product_Sales_Revenue_Target__c) ||
               (mps.Closed_Opportunities_Services_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Services_Revenue__c) || (mps.Closed_Opportunities_Total_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Total_Revenue__c) || 
               (mps.Open_Opportunities_Product_Revenue__c  != oldMap.get(mps.id).Open_Opportunities_Product_Revenue__c) || (mps.Open_Opportunities_Services_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Services_Revenue__c) ||
               (mps.Open_Opportunities_Total_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Total_Revenue__c) || (mps.Sales_Revenue_Target__c != oldMap.get(mps.id).Sales_Revenue_Target__c) ||
               (mps.Services_Sales_Revenue_Target__c != oldMap.get(mps.id).Services_Sales_Revenue_Target__c)){
                mpsList.add(mps);    
                qpsIdList.add(mps.Quarterly_Performance_Score__c);
            }
            if(mps.Closed_Opportunities_Product_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Product_Revenue__c){
                 qpsCP.add(mps.Quarterly_Performance_Score__c);
            }
            if(mps.Closed_Opportunities_Services_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Services_Revenue__c){
                 qpsCS.add(mps.Quarterly_Performance_Score__c);
            }
            if(mps.Closed_Opportunities_Total_Revenue__c != oldMap.get(mps.id).Closed_Opportunities_Total_Revenue__c){
                qpsCT.add(mps.Quarterly_Performance_Score__c);
            }
            if(mps.Open_Opportunities_Product_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Product_Revenue__c){
            system.debug('here i am in open product revenue mps');
                qpsOP.add(mps.Quarterly_Performance_Score__c);
            }
            if(mps.Open_Opportunities_Services_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Services_Revenue__c){
                qpsOS.add(mps.Quarterly_Performance_Score__c);
            }
            if(mps.Open_Opportunities_Total_Revenue__c != oldMap.get(mps.id).Open_Opportunities_Total_Revenue__c){
                system.debug('here i am in open total revenue mps');
                qpsOT.add(mps.Quarterly_Performance_Score__c);
            }
            if(mps.Product_Sales_Revenue_Target__c != oldMap.get(mps.Id).Product_Sales_Revenue_Target__c){
                qpsTP.add(mps.Quarterly_Performance_Score__c);
            }
            if(mps.Services_Sales_Revenue_Target__c!= oldMap.get(mps.id).Services_Sales_Revenue_Target__c){
                qpsTS.add(mps.Quarterly_Performance_Score__c);
            }
            if(mps.Sales_Revenue_Target__c != oldMap.get(mps.id).Sales_Revenue_Target__c ){
                qpsTT.add(mps.Quarterly_Performance_Score__c);
            }
        }
        if(mpsList.size()>0 && qpsidList.size()>0){
            
            //mpsAllList = [SELECT Id,Name FROM Monthly_Performance_Score__c WHERE Quarterly_Performance_Score__c IN: qpsIdList];                                                    
            for(Monthly_Performance_Score__c mps:[SELECT Id,Name,Product_Sales_Revenue_Target__c, Sales_Revenue_Target__c, Services_Sales_Revenue_Target__c,
                                                                Closed_Opportunities_Product_Revenue__c, Closed_Opportunities_Services_Revenue__c, Closed_Opportunities_Total_Revenue__c,
                                                                Open_Opportunities_Product_Revenue__c, Open_Opportunities_Services_Revenue__c, Open_Opportunities_Total_Revenue__c,Quarterly_Performance_Score__c 
                                                                FROM Monthly_Performance_Score__c WHERE Quarterly_Performance_Score__c IN: qpsIdList]){
                /*Q1Set.clear(); 
                Q2Set.clear();
                Q3Set.clear();
                Q4Set.clear();*/
                if(qpsIdList.contains(mps.Quarterly_Performance_Score__c )){
                    Quarterly_Performance_Score__c Qn = new Quarterly_Performance_Score__c(Id = mps.Quarterly_performance_Score__c);
                    if(qpsCP.contains(Qn.id)){
                        if(!qpsCPMAP.containsKey(Qn.Id)){
                            qn.Closed_Opportunities_Product_Revenue__c = mps.Closed_Opportunities_Product_Revenue__c;
                            qpsCPMAP.put(qn.Id,qn);
                        }
                        else{
                            quarterly_Performance_score__c q = qpsCPMAP.get(Qn.Id);
                            q.Closed_Opportunities_Product_Revenue__c += mps.Closed_Opportunities_Product_Revenue__c;
                            qpsCPMAP.put(q.id,q);
                        }
                    }
                    if(qpsCS.contains(Qn.id)){
                        if(!qpsCSMap.containsKey(Qn.Id)){
                            qn.Closed_Opportunities_Services_Revenue__c = mps.Closed_Opportunities_Services_Revenue__c;
                            qpsCSMap.put(qn.Id,qn);
                        }
                        else{
                            quarterly_Performance_score__c q = qpsCSMap.get(Qn.Id);
                            q.Closed_Opportunities_Services_Revenue__c += mps.Closed_Opportunities_Services_Revenue__c;
                            qpsCSMap.put(q.id,q);
                        }
                    }
                    if(qpsCT.contains(Qn.id)){
                        if(!qpsCTMap.containsKey(Qn.Id)){
                            qn.Closed_Opportunities_Total_Revenue__c= mps.Closed_Opportunities_Total_Revenue__c;
                            qpsCTMap.put(qn.Id,qn);
                        }
                        else{
                            quarterly_Performance_score__c q = qpsCTMap.get(Qn.Id);
                            q.Closed_Opportunities_Total_Revenue__c+= mps.Closed_Opportunities_Total_Revenue__c;
                            qpsCTMap.put(q.id,q);
                        }
                    }
                    if(qpsOP.contains(Qn.id)){
                        if(!qpsOPMap.containsKey(Qn.Id)){
                            qn.Open_Opportunities_Product_Revenue__c = mps.Open_Opportunities_Product_Revenue__c ;
                            qpsOPMap.put(qn.Id,qn);
                        }
                        else{
                            quarterly_Performance_score__c q = qpsOPMap.get(Qn.Id);
                            q.Open_Opportunities_Product_Revenue__c += mps.Open_Opportunities_Product_Revenue__c ;
                            qpsOPMap.put(q.id,q);
                        }
                    }
                    if(qpsOS.contains(Qn.id)){
                        if(!qpsOSMap.containsKey(Qn.Id)){
                            qn.Open_Opportunities_Services_Revenue__c= mps.Open_Opportunities_Services_Revenue__c;
                            qpsOSMap.put(qn.Id,qn);
                        }
                        else{
                            quarterly_Performance_score__c q = qpsOSMap.get(Qn.Id);
                            q.Open_Opportunities_Services_Revenue__c+= mps.Open_Opportunities_Services_Revenue__c;
                            qpsOSMap.put(q.id,q);
                        }
                    }
                    if(qpsOT.contains(Qn.id)){
                        if(!qpsOTMap.containsKey(Qn.Id)){
                            qn.Open_Opportunities_Total_Revenue__c = mps.Open_Opportunities_Total_Revenue__c ;
                            qpsOTMap.put(qn.Id,qn);
                        }
                        else{
                            quarterly_Performance_score__c q = qpsOTMap.get(Qn.Id);
                            q.Open_Opportunities_Total_Revenue__c += mps.Open_Opportunities_Total_Revenue__c ;
                            qpsOTMap.put(q.id,q);
                        }
                    }
                    if(qpsTP.contains(Qn.id)){
                        if(!qpsTPMap.containsKey(Qn.Id)){
                            qn.Product_Sales_Revenue_Target__c = mps.Product_Sales_Revenue_Target__c ;
                            qpsTPMap.put(qn.Id,qn);
                        }
                        else{
                            quarterly_Performance_score__c q = qpsTPMap.get(Qn.Id);
                            q.Product_Sales_Revenue_Target__c += mps.Product_Sales_Revenue_Target__c ;
                            qpsTPMap.put(q.id,q);
                        }
                    }
                    if(qpsTS.contains(Qn.id)){
                        if(!qpsTSMap.containsKey(Qn.Id)){
                            qn.Services_Sales_Revenue_Target__c= mps.Services_Sales_Revenue_Target__c;
                            qpsTSMap.put(qn.Id,qn);
                        }
                        else{
                            quarterly_Performance_score__c q = qpsTSMap.get(Qn.Id);
                            q.Services_Sales_Revenue_Target__c+= mps.Services_Sales_Revenue_Target__c;
                            qpsTSMap.put(q.id,q);
                        }
                    }
                    if(qpsTT.contains(Qn.id)){
                        if(!qpsTTMap.containsKey(Qn.Id)){
                            qn.Sales_Revenue_Target__c = mps.Sales_Revenue_Target__c ;
                            qpsTTMap.put(qn.Id,qn);
                        }
                        else{
                            quarterly_Performance_score__c q = qpsTTMap.get(Qn.Id);
                            q.Sales_Revenue_Target__c += mps.Sales_Revenue_Target__c ;
                            qpsTTMap.put(q.id,q);
                        }
                    }
                    
                }
           
            }       
            for(Quarterly_Performance_Score__c qps : [SELECT Id, Name, Yearly_Performance_Score__c, 
                                                                Product_Sales_Revenue_Target__c, Sales_Revenue_Target__c, Services_Sales_Revenue_Target__c,
                                                                Closed_Opportunities_Product_Revenue__c, Closed_Opportunities_Services_Revenue__c, Closed_Opportunities_Total_Revenue__c,
                                                                Open_Opportunities_Product_Revenue__c, Open_Opportunities_Services_Revenue__c, Open_Opportunities_Total_Revenue__c
                                                                FROM Quarterly_Performance_Score__c WHERE Id IN: qpsidList]){
                system.debug('here i am in open total revenue qps 2 for');
                if(qpsCPMap.containskey(qps.Id)){
                qps.Closed_Opportunities_Product_Revenue__c = qpsCPMap.get(qps.id).Closed_Opportunities_Product_Revenue__c ;
                }
                if(qpsCSMap.containskey(qps.Id)){
                qps.Closed_Opportunities_Services_Revenue__c = qpsCSMap.get(qps.Id).Closed_Opportunities_Services_Revenue__c ;
                }
                if(qpsCTMap.containskey(qps.Id)){
                qps.Closed_Opportunities_Total_Revenue__c = qpsCTMap.get(qps.Id).Closed_Opportunities_Total_Revenue__c;
                }
                if(qpsOPMap.containskey(qps.Id)){
                qps.Open_Opportunities_Product_Revenue__c = qpsOPMap.get(qps.Id).Open_Opportunities_Product_Revenue__c;
                }
                if(qpsOSMap.containskey(qps.Id)){
                qps.Open_Opportunities_Services_Revenue__c = qpsOSMap.get(qps.Id).Open_Opportunities_Services_Revenue__c ;
                }
                if(qpsOTMap.containskey(qps.Id)){
                qps.Open_Opportunities_Total_Revenue__c = qpsOTMap.get(qps.Id).Open_Opportunities_Total_Revenue__c ;
                }
                if(qpsTPMap.containskey(qps.Id)){
                qps.Product_Sales_Revenue_Target__c = qpsTPMap.get(qps.Id).Product_Sales_Revenue_Target__c ;
                }
                if( qpsTSMap.containskey(qps.Id)){
                qps.Services_Sales_Revenue_Target__c = qpsTSMap.get(qps.Id).Services_Sales_Revenue_Target__c ;
                }
                if(qpsTTMap.containskey(qps.Id)){
                qps.Sales_Revenue_Target__c = qpsTTMap.get(qps.Id).Sales_Revenue_Target__c ;
                }
                QnMap.put(qps.Id,qps);
            }
            if(QnMap.size()>0){
                update QnMap.values();
            }
        
        }
    }
}