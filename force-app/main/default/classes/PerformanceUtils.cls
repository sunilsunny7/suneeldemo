/**
About
-----
Description: PerformanceUtils contains methods for the UserPerformance object
Create date: 23.02.2016

PerformanceUtils Update History
--------------
Created Feb 2016 - V.M
Updated Apr 2016 - N.G Created method updateYearlyTaskScore to update Task scores and registered Tasks. 
                    Also, Updated method updateYearlyContributionScore to check Tasks on the same Date, same Account and for same User.
Updated Sep 2016 - A.N Refactored. Cleaned up comments/debug statements, fixed code syntax errors.
Updated Nov 2017 - D.S SALEF - 409 : Updated code for points division and quarter point collection
Updated Jan 2018 - P.P SALEF - 764 : Updated code for previous year data on Leaderboard 
Updated Oct 2018 - Y.K SALEF-1564 : Updated code for Cygate sambesök points logic
Updated Nov 2018 - S.S SALEF 1227 : Commented updateYearlyCompetenceScore method as competencescore is not needed anymore but can be used in future
Updated Jan 2019 - Y.K. SALEF - 1445 : Updated the code to remove option "Telefonmöte" from leaderboard point logic
Updated Feb 2019 - Y.K SALEF-1897 : Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
*/

public class PerformanceUtils { 
    //Change for testing purposes, then the user performance and everything related to user performance will behave as if the CURRENT_YEAR is whatever the value is.
    public final static Integer CURRENT_YEAR = Datetime.now().year();
    public final static Integer PREVIOUS_YEAR = Datetime.now().year() - 1;
    public final static Integer PROCESS_YEAR = Integer.valueof(label.Year_for_Performance_Score);
    public static boolean runTrigger = true;
    
    
    public class AggregatedScore{
        public Integer TotalScore { get; private set; }
        public Integer TotalActions { get; private set; }
        
        public AggregatedScore(Integer totalAction, Integer totalActions){
            this.TotalScore = totalAction;
            this.TotalActions = totalActions;
        }
    }
    
    // Author: V.M
    // Updates Contribution Score and Client Meeting Registered for the Yearly Performance 
    // with on all the Event/Tasks the user has completed within the current year.
    // Event/Task gets Completed/Stängd by a Workflow based on if the Event/Task is in the past.
    // Y.K. SALEF - 1445 : Updated the code to remove option "Telefonmöte" from leaderboard point logic
    public static void updateYearlyContributionScore(List<Event> newList){
        Set<Id> userIds = getCygateClientMeetingsUserIds(newList);      
        
        if (userIds.size() > 0){        
            Map<Id, User_Performance__c> userPerformances = getCreateUserPerformances(userIds);
            List<Yearly_Performance_Score__c> yearlyPerformances = getCreateYearlyPerformances(userPerformances.keySet());
            Map<Id, AggregatedScore> mappedScores = new Map<Id, AggregatedScore>();
            
            AggregateResult[] aggregatedEventScores = [SELECT OwnerId, COUNT(Owner.Name) total, SUM(Points__c) sum 
                                                       FROM Event 
                                                       WHERE OwnerId IN :userIds 
                                                       AND Event_Complete__c = true 
                                                       AND Legacy_Activity__c = false                                      
                                                       AND EndDateTime >= :Datetime.newInstance(PROCESS_YEAR, 1, 1)
                                                       AND EndDateTime <= :Datetime.newInstance(PROCESS_YEAR, 12, 31)
                                                       AND Event_Type__c != 'Telefonmöte'
                                                       GROUP BY OwnerId];
            
            for (AggregateResult aes : aggregatedEventScores){
                Id ownerId = (Id)aes.get('OwnerId');            
                mappedScores.put(ownerId, 
                                 new AggregatedScore(
                                     Integer.valueOf(aes.get('sum')), 
                                     Integer.valueOf(aes.get('total'))
                                 ));
            }
            
            for (Yearly_Performance_Score__c yps : yearlyPerformances){
                if (mappedScores.get(yps.User_Performance__r.User__c) != null){
                    yps.Contribution_Score__c = mappedScores.get(yps.User_Performance__r.User__c).TotalScore;
                    yps.Client_Meetings_Registered__c = mappedScores.get(yps.User_Performance__r.User__c).TotalActions;
                }
            }
            update yearlyPerformances;
            
            //Check if Task Exist for the same Event type           
            Set<String> eventOwnerlist   = new Set<String>();
            for(Event e : newList){
                eventOwnerlist.add(e.OwnerId);
            }
            List<Task> taskList = [SELECT Id, ActivityDate, RecordTypeID, Points__c, WhoID, WhatID, OwnerId 
                                   FROM Task 
                                   WHERE OwnerId IN :userIds
                                   AND Status = 'Stängd' 
                                   AND ActivityDate >= :Date.newInstance(PROCESS_YEAR, 1, 1)
                                   AND ActivityDate <= :Date.newInstance(PROCESS_YEAR, 12, 31)
                                   AND Event_Type__c != 'Telefonmöte'
                                   AND OwnerId in : eventOwnerlist];
            if(!taskList.isEmpty()){
                updateYearlyTaskScore(taskList);
            }
        }
    }
    
    
    // Author: V.M
    // Updates Contribution Score and Client Meeting Registered for the Quarterly Performance 
    // with on all the Event/Tasks the user has completed within the current quarter year.
    // Event/Task gets Completed/Stängd by a Workflow based on if the Event/Task is in the past.
  /*  public static void updateQuarterlyContributionScore(List<Event> newList){
        Set<Id> userIds = getCygateClientMeetingsUserIds(newList);      
        
        if (userIds.size() > 0){        
            Map<Id, User_Performance__c> userPerformances = getCreateUserPerformances(userIds);
           
            
           
            datetime Q11 = datetime.newInstance(CURRENT_YEAR, 1, 1);
            datetime Q12 = datetime.newInstance(CURRENT_YEAR, 3, 31);
            datetime Q21 = datetime.newInstance(CURRENT_YEAR, 4, 1);
            datetime Q22 = datetime.newInstance(CURRENT_YEAR, 6, 30);
            datetime Q31 = datetime.newInstance(CURRENT_YEAR, 7, 1);
            datetime Q32 = datetime.newInstance(CURRENT_YEAR, 9, 30);
            datetime Q41 = datetime.newInstance(CURRENT_YEAR, 10, 1);
            datetime Q42 = datetime.newInstance(CURRENT_YEAR, 12, 31);
            datetime startquarter ;
            datetime endquarter ;
             
             date d  ;
             
             
             Map<String,List<Quarterly_Performance_Score__c>> quarterlyPerformancesAll = new Map<String,List<Quarterly_Performance_Score__c>>();
             quarterlyPerformancesAll = getCreateAllQuarterlyPerformances(userPerformances.keySet());
             List<Quarterly_Performance_Score__c> quarterlyPerformances = quarterlyPerformancesAll.get('Q1');
             List<Quarterly_Performance_Score__c> quarterlyPerformances2 = quarterlyPerformancesAll.get('Q2');
             List<Quarterly_Performance_Score__c> quarterlyPerformances3 = quarterlyPerformancesAll.get('Q3');
             List<Quarterly_Performance_Score__c> quarterlyPerformances4 = quarterlyPerformancesAll.get('Q4');
             List <Event> aggregatedEventScores1 = [SELECT Id,OwnerId,  Points__c,EndDateTime 
                                                       FROM Event 
                                                       WHERE OwnerId IN :userIds 
                                                       AND Event_Complete__c = true 
                                                       AND Legacy_Activity__c = false                                      
                                                       AND EndDateTime >=:Date.newInstance(CURRENT_YEAR, 1, 1)
                                                       AND EndDateTime <=:Date.newInstance(CURRENT_YEAR, 12, 31)];
                                                       
             Map<Id,decimal> mappedScoresSum1 = new Map<Id, decimal>();
             Map<Id,decimal> mappedScoresSum2 = new Map<Id, decimal>();
             Map<Id,decimal> mappedScoresSum3 = new Map<Id, decimal>();
             Map<Id,decimal> mappedScoresSum4 = new Map<Id, decimal>();
            for(Event e:aggregatedEventScores1){
                if(e.endDateTime >= Q11 && e.EndDateTime <= Q12){
                    if(mappedScoresSum1.containskey(e.OwnerId)){
                        decimal scoreSum = mappedscoresSum1.get(e.OwnerId);
                        scoreSum += e.Points__c;
                        mappedScoresSum1.put(e.OwnerId,scoreSum);
                    }
                    else{
                        mappedScoresSum1.put(e.OwnerId,e.Points__c);
                    }
                }
                else if(e.endDateTime >= Q21 && e.EndDateTime <= Q22){
                    if(mappedScoresSum2.containskey(e.OwnerId)){
                        decimal scoreSum = mappedscoresSum2.get(e.OwnerId);
                        scoreSum += e.Points__c;
                        mappedScoresSum2.put(e.OwnerId,scoreSum);
                    }
                    else{
                        mappedScoresSum2.put(e.OwnerId,e.Points__c);
                    }
                }
                else if(e.endDateTime >= Q31 && e.EndDateTime <= Q32){
                    if(mappedScoresSum3.containskey(e.OwnerId)){
                        decimal scoreSum = mappedscoresSum3.get(e.OwnerId);
                        scoreSum += e.Points__c;
                        mappedScoresSum3.put(e.OwnerId,scoreSum);
                    }
                    else{
                        mappedScoresSum3.put(e.OwnerId,e.Points__c);
                    }
                }
                else if(e.endDateTime >= Q41 && e.EndDateTime <= Q42){
                    if(mappedScoresSum4.containskey(e.OwnerId)){
                        decimal scoreSum = mappedscoresSum4.get(e.OwnerId);
                        scoreSum += e.Points__c;
                        mappedScoresSum4.put(e.OwnerId,scoreSum);
                    }
                    else{
                        mappedScoresSum4.put(e.OwnerId,e.Points__c);
                    }
                }
            }
            List<quarterly_performance_score__c> updateListQPS = new List<Quarterly_Performance_score__c>();
            for (Quarterly_Performance_Score__c qps : quarterlyPerformances){
                if (mappedScoresSum1.get(qps.User_Performance__r.User__c) != null & qps.Name == 'Q1'){
                    qps.Contribution_Score__c = mappedScoresSum1.get(qps.User_Performance__r.User__c);
                    updateListQPS.add(qps);
                }
            }
            for (Quarterly_Performance_Score__c qps : quarterlyPerformances2){
                if (mappedScoresSum2.get(qps.User_Performance__r.User__c) != null & qps.Name == 'Q2'){
                    qps.Contribution_Score__c = mappedScoresSum2.get(qps.User_Performance__r.User__c);
                    updateListQPS.add(qps);
                }
            }
            for (Quarterly_Performance_Score__c qps : quarterlyPerformances3){
                if (mappedScoresSum3.get(qps.User_Performance__r.User__c) != null & qps.Name == 'Q3'){
                    qps.Contribution_Score__c = mappedScoresSum3.get(qps.User_Performance__r.User__c);
                    updateListQPS.add(qps);
                }
            }
            for (Quarterly_Performance_Score__c qps : quarterlyPerformances4){
                if (mappedScoresSum4.get(qps.User_Performance__r.User__c) != null & qps.Name == 'Q4'){
                    qps.Contribution_Score__c = mappedScoresSum4.get(qps.User_Performance__r.User__c);
                    updateListQPS.add(qps);
                }
            }
            
            update updateListQPS;
             
             
            
        }
    }
   */
    
    // Author: V.M
    // Updates Customer Statuses based points for the Quarterly Performance 
    // with on all the Events the user has completed within the current quarter year.
    // Event gets Completed/Stängd by a Workflow based on if the Event  is in the past.
    // Y.K. SALEF - 1445 : Updated the code to remove option "Telefonmöte" from leaderboard point logic
    public static void updateQuarterlyPointScore(List<Event> newList){
        Set<Id> userIds = getCygateClientMeetingsUserIds(newList);      
        system.debug('inside quarterly point score update - Num1');
        if (userIds.size() > 0){        
            system.debug('inside user size update - Num2');
            Map<Id, User_Performance__c> userPerformances = getCreateUserPerformances(userIds);
            Map<Id,Yearly_Performance_Score__c> yearlyPerformances = getCreateYearlyPerformancesMap(userIds);
            datetime Q11 = datetime.newInstance(PROCESS_YEAR, 1, 1);
            datetime Q12 = datetime.newInstance(PROCESS_YEAR, 3, 31);
            datetime Q21 = datetime.newInstance(PROCESS_YEAR, 4, 1);
            datetime Q22 = datetime.newInstance(PROCESS_YEAR, 6, 30);
            datetime Q31 = datetime.newInstance(PROCESS_YEAR, 7, 1);
            datetime Q32 = datetime.newInstance(PROCESS_YEAR, 9, 30);
            datetime Q41 = datetime.newInstance(PROCESS_YEAR, 10, 1);
            datetime Q42 = datetime.newInstance(PROCESS_YEAR, 12, 31);
            datetime startquarter ;
            datetime endquarter ;             
            date d  ;                          
            Map<String,List<Quarterly_Performance_Score__c>> quarterlyPerformancesAll = new Map<String,List<Quarterly_Performance_Score__c>>();
            quarterlyPerformancesAll = getCreateAllQuarterlyPerformances(userPerformances.keySet(),yearlyPerformances.keySet());
            List<Quarterly_Performance_Score__c> quarterlyPerformances = quarterlyPerformancesAll.get('Q1');
            List<Quarterly_Performance_Score__c> quarterlyPerformances2 = quarterlyPerformancesAll.get('Q2');
            List<Quarterly_Performance_Score__c> quarterlyPerformances3 = quarterlyPerformancesAll.get('Q3');
            List<Quarterly_Performance_Score__c> quarterlyPerformances4 = quarterlyPerformancesAll.get('Q4');
            
            List <Event> aggregatedEventScores1 = [SELECT Id,OwnerId,  Customer_status__c,Sambes_k__c ,Sambes_k_Cygate_kontakt__c ,Bredda_aff_ren__c ,V_xa_befintlig_aff_r__c,ka_avtalad_aff_r__c , Points__c,EndDateTime 
                                                       FROM Event 
                                                       WHERE OwnerId IN :userIds 
                                                       AND Event_Complete__c = true 
                                                       AND Legacy_Activity__c = false                                      
                                                       AND EndDateTime >=:Date.newInstance(PROCESS_YEAR, 1, 1)
                                                       AND EndDateTime <=:Date.newInstance(PROCESS_YEAR, 12, 31)
                                                       AND Event_Type__c != 'Telefonmöte'];
            system.debug('size of aggregatedeventscores1 - Num3' + aggregatedEventScores1.size());
                                                       
            Map<Id,Map<String,decimal>> mappedScoresSumStatus1 = new Map<Id,Map<String,decimal>>();
            Map<Id,Map<String,decimal>> mappedScoresSumStatus2 = new Map<Id, Map<String,decimal>>();
            Map<Id,Map<String,decimal>> mappedScoresSumStatus3 = new Map<Id, Map<String,decimal>>();
            Map<Id,Map<String,decimal>> mappedScoresSumCheckbox1 = new Map<Id, Map<String,decimal>>();
            Map<Id,Map<String,decimal>> mappedScoresSumCheckbox2 = new Map<Id, Map<String,decimal>>();
            Map<Id,Map<String,decimal>> mappedScoresSumCheckbox3 = new Map<Id, Map<String,decimal>>();
            Map<Id,Map<String,decimal>> mappedScoresSumSambesokChecked = new Map<Id, Map<String,decimal>>();
            Map<Id,Map<String,decimal>> mappedScoresSumSambesokUnChecked = new Map<Id, Map<String,decimal>>();
            
            //Y.K 1897
            Map<Id,Map<String,decimal>> mappedScoresSumSambesokCygateKontaktChecked = new Map<Id, Map<String,decimal>>();
            
            if(aggregatedEventScores1 != null)
            {
                system.debug('inside aggregatedEventScores1 - Num4');
                for(Event e:aggregatedEventScores1)
                {
                    if(e.EndDateTime >= Q11 && e.EndDateTime <= Q12)
                    {
                        if(e.Customer_status__c == 'Befintlig kund')
                        {
                            if(mappedScoresSumStatus1.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus1.get(e.OwnerId);
                                    if(mapsum.containskey('Q1'))
                                    {
                                        decimal scoresum = mapsum.get('Q1');
                                        scoresum = scoresum+1;                   
                                        mapsum.put('Q1',scoresum);
                                        mappedScoresSumStatus1.put(e.OwnerId,mapsum);
                                    }
                                    else
                                    {
                                        mapsum.put('Q1',1.0);
                                        mappedScoresSumStatus1.put(e.OwnerId,mapsum);
                                    }
                            }
                            else
                            {
                                mappedScoresSumStatus1.put(e.OwnerId,new Map<String,decimal>{'Q1' => 1.0});
                            }
                        }
                        if (e.Customer_status__c == 'Ny Kund')
                        {
                            if(mappedScoresSumStatus2.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus2.get(e.OwnerId);
                                if(mapsum.containskey('Q1'))
                                {
                                    decimal scoresum = mapsum.get('Q1');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q1',scoresum);
                                    mappedScoresSumStatus2.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q1',1.0);
                                    mappedScoresSumStatus2.put(e.OwnerId,mapsum);
                                }                                
                            }
                            else
                            {
                                mappedScoresSumStatus2.put(e.OwnerId,new Map<String,decimal>{'Q1' => 1.0});
                            }                       
                        }   
                        if (e.Customer_status__c == 'Befintlig kund, ny kontakt')
                        {
                            if(mappedScoresSumStatus3.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus3.get(e.OwnerId);
                                if(mapsum.containskey('Q1'))
                                {
                                    decimal scoresum = mapsum.get('Q1');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q1',scoresum);
                                    mappedScoresSumStatus3.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q1',1.0);
                                    mappedScoresSumStatus3.put(e.OwnerId,mapsum);
                                }                    
                            }
                            else
                            {
                                mappedScoresSumStatus3.put(e.OwnerId,new Map<String,decimal>{'Q1' => 1.0});
                            }  
                        }
                    
                        if (e.Bredda_aff_ren__c == true)
                        {
                            if(mappedScoresSumCheckbox1.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox1.get(e.OwnerId);
                                if(mapsum.containskey('Q1'))
                                {
                                    decimal scoresum = mapsum.get('Q1');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q1',scoresum);
                                    mappedScoresSumCheckbox1.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q1',1.0);
                                    mappedScoresSumCheckbox1.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumCheckbox1.put(e.OwnerId,new Map<String,decimal>{'Q1' => 1.0});
                            }  
                        }                    
                        if (e.V_xa_befintlig_aff_r__c == true)
                        {
                            if(mappedScoresSumCheckbox2.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox2.get(e.OwnerId);
                                if(mapsum.containskey('Q1'))
                                {
                                    decimal scoresum = mapsum.get('Q1');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q1',scoresum);
                                    mappedScoresSumCheckbox2.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q1',1.0);
                                    mappedScoresSumCheckbox2.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumCheckbox2.put(e.OwnerId,new Map<String,decimal>{'Q1' => 1.0});
                            }  
                        }                   
                        if (e.ka_avtalad_aff_r__c == true)
                        {
                            if(mappedScoresSumCheckbox3.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox3.get(e.OwnerId);
                                if(mapsum.containskey('Q1'))
                                {
                                    decimal scoresum = mapsum.get('Q1');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q1',scoresum);
                                    mappedScoresSumCheckbox3.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q1',1.0);
                                    mappedScoresSumCheckbox3.put(e.OwnerId,mapsum);
                                }                    
                            }
                            else
                            {
                                mappedScoresSumCheckbox3.put(e.OwnerId,new Map<String,decimal>{'Q1' => 1.0});
                            }  
                        }                    
                        if (e.Sambes_k__c == true)
                        {
                            if(mappedScoresSumSambesokChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q1'))
                                {
                                    decimal scoresum = mapsum.get('Q1');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q1',scoresum);
                                    mappedScoresSumSambesokChecked.put(e.OwnerId,mapsum);
                                    }
                                    else
                                    {
                                        mapsum.put('Q1',1.0);
                                        mappedScoresSumSambesokChecked.put(e.OwnerId,mapsum);
                                    }
                            }
                            else
                            {
                                mappedScoresSumSambesokChecked.put(e.OwnerId,new Map<String,decimal>{'Q1' => 1.0});
                            }  

                        } 
                        
                        //Y.K SALEF-1897 : Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
                        if (e.Sambes_k_Cygate_kontakt__c == true)
                        {
                            if(mappedScoresSumSambesokCygateKontaktChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokCygateKontaktChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q1'))
                                {
                                    decimal scoresum = mapsum.get('Q1');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q1',scoresum);
                                    mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,mapsum);
                                    }
                                    else
                                    {
                                        mapsum.put('Q1',1.0);
                                        mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,mapsum);
                                    }
                            }
                            else
                            {
                                mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,new Map<String,decimal>{'Q1' => 1.0});
                            }  

                        }
                                           
                        if (e.Sambes_k__c == false && e.Sambes_k_Cygate_kontakt__c == false)
                        {
                            if(mappedScoresSumSambesokUnChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokUnChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q1'))
                                {
                                    decimal scoresum = mapsum.get('Q1');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q1',scoresum);
                                    mappedScoresSumSambesokUnChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q1',1.0);
                                    mappedScoresSumSambesokUnChecked.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumSambesokUnChecked.put(e.OwnerId,new Map<String,decimal>{'Q1' => 1.0});
                            }  
                        }
                    }                        
                    if(e.EndDateTime >= Q21 && e.EndDateTime <= Q22)
                    {
                        if(e.Customer_status__c == 'Befintlig kund')
                        {
                            if(mappedScoresSumStatus1.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus1.get(e.OwnerId);
                                if(mapsum.containskey('Q2'))
                                {
                                    decimal scoresum = mapsum.get('Q2');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q2',scoresum);
                                    mappedScoresSumStatus1.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q2',1.0);
                                    mappedScoresSumStatus1.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumStatus1.put(e.OwnerId,new Map<String,decimal>{'Q2' => 1.0});
                            }
                        }
                        if (e.Customer_status__c == 'Ny Kund')
                        {
                            if(mappedScoresSumStatus2.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus2.get(e.OwnerId);
                                    if(mapsum.containskey('Q2'))
                                    {
                                        decimal scoresum = mapsum.get('Q2');
                                        scoresum = scoresum+1;                   
                                        mapsum.put('Q2',scoresum);
                                        mappedScoresSumStatus2.put(e.OwnerId,mapsum);
                                    }
                                    else
                                    {
                                        mapsum.put('Q2',1.0);
                                        mappedScoresSumStatus2.put(e.OwnerId,mapsum);
                                    }
                            }
                            else{
                            mappedScoresSumStatus2.put(e.OwnerId,new Map<String,decimal>{'Q2' => 1.0});
                            }
                        }   
                        if (e.Customer_status__c == 'Befintlig kund, ny kontakt')
                        {
                            if(mappedScoresSumStatus3.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus3.get(e.OwnerId);
                                if(mapsum.containskey('Q2'))
                                {
                                    decimal scoresum = mapsum.get('Q2');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q2',scoresum);
                                    mappedScoresSumStatus3.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q2',1.0);
                                    mappedScoresSumStatus3.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumStatus3.put(e.OwnerId,new Map<String,decimal>{'Q2' => 1.0});
                            }  
                        }
                        if (e.Bredda_aff_ren__c == true)
                        {
                            if(mappedScoresSumCheckbox1.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox1.get(e.OwnerId);
                                if(mapsum.containskey('Q2'))
                                {
                                    decimal scoresum = mapsum.get('Q2');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q2',scoresum);
                                    mappedScoresSumCheckbox1.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q2',1.0);
                                    mappedScoresSumCheckbox1.put(e.OwnerId,mapsum);
                                }                    
                            }
                            else
                            {
                                mappedScoresSumCheckbox1.put(e.OwnerId,new Map<String,decimal>{'Q2' => 1.0});
                            }  
                        }
                        if (e.V_xa_befintlig_aff_r__c == true)
                        {
                            if(mappedScoresSumCheckbox2.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox2.get(e.OwnerId);
                                if(mapsum.containskey('Q2'))
                                {
                                    decimal scoresum = mapsum.get('Q2');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q2',scoresum);
                                    mappedScoresSumCheckbox2.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q2',1.0);
                                    mappedScoresSumCheckbox2.put(e.OwnerId,mapsum);
                                }
                            }
                            
                            else{
                                mappedScoresSumCheckbox2.put(e.OwnerId,new Map<String,decimal>{'Q2' => 1.0});
                            }  

                        }                   
                        if (e.ka_avtalad_aff_r__c == true)
                        {
                            if(mappedScoresSumCheckbox3.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox3.get(e.OwnerId);
                                if(mapsum.containskey('Q2'))
                                {
                                    decimal scoresum = mapsum.get('Q2');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q2',scoresum);
                                    mappedScoresSumCheckbox3.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q2',1.0);
                                    mappedScoresSumCheckbox3.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumCheckbox3.put(e.OwnerId,new Map<String,decimal>{'Q2' => 1.0});
                            }  
                        }                    
                        if (e.Sambes_k__c == true)
                        {
                            if(mappedScoresSumSambesokChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q2'))
                                {
                                    decimal scoresum = mapsum.get('Q2');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q2',scoresum);
                                    mappedScoresSumSambesokChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q2',1.0);
                                    mappedScoresSumSambesokChecked.put(e.OwnerId,mapsum);
                                }                   
                            }
                            else
                            {
                                mappedScoresSumSambesokChecked.put(e.OwnerId,new Map<String,decimal>{'Q2' => 1.0});
                            }  
                        } 
                        
                        //Y.K SALEF-1897 : Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
                        if (e.Sambes_k_Cygate_kontakt__c == true)
                        {
                            if(mappedScoresSumSambesokCygateKontaktChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokCygateKontaktChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q2'))
                                {
                                    decimal scoresum = mapsum.get('Q2');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q2',scoresum);
                                    mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q2',1.0);
                                    mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,mapsum);
                                }                   
                            }
                            else
                            {
                                mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,new Map<String,decimal>{'Q2' => 1.0});
                            }  
                        }
                                          
                        if (e.Sambes_k__c == false && e.Sambes_k_Cygate_kontakt__c == false)
                        {
                            if(mappedScoresSumSambesokUnChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokUnChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q2'))
                                {
                                    decimal scoresum = mapsum.get('Q2');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q2',scoresum);
                                    mappedScoresSumSambesokUnChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q2',1.0);
                                    mappedScoresSumSambesokUnChecked.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumSambesokUnChecked.put(e.OwnerId,new Map<String,decimal>{'Q2' => 1.0});
                            }  
                        }

                    }    
                    if(e.EndDateTime >= Q31 && e.EndDateTime <= Q32)
                    {
                        if(e.Customer_status__c == 'Befintlig kund')
                        {
                            if(mappedScoresSumStatus1.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus1.get(e.OwnerId);
                                if(mapsum.containskey('Q3'))
                                {
                                    decimal scoresum = mapsum.get('Q3');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q3',scoresum);
                                    mappedScoresSumStatus1.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q3',1.0);
                                    mappedScoresSumStatus1.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumStatus1.put(e.OwnerId,new Map<String,decimal>{'Q3' => 1.0});
                            }
                        }
                        if (e.Customer_status__c == 'Ny Kund')
                        {
                            if(mappedScoresSumStatus2.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus2.get(e.OwnerId);
                                if(mapsum.containskey('Q3'))
                                {
                                    decimal scoresum = mapsum.get('Q3');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q3',scoresum);
                                    mappedScoresSumStatus2.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q3',1.0);
                                    mappedScoresSumStatus2.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumStatus2.put(e.OwnerId,new Map<String,decimal>{'Q3' => 1.0});
                            }                        
                        }   
                        if (e.Customer_status__c == 'Befintlig kund, ny kontakt')
                        {
                            if(mappedScoresSumStatus3.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus3.get(e.OwnerId);
                                if(mapsum.containskey('Q3'))
                                {
                                    decimal scoresum = mapsum.get('Q3');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q3',scoresum);
                                    mappedScoresSumStatus3.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q3',1.0);
                                    mappedScoresSumStatus3.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumStatus3.put(e.OwnerId,new Map<String,decimal>{'Q3' => 1.0});
                            }  
                        }                    
                        if (e.Bredda_aff_ren__c == true)
                        {
                            if(mappedScoresSumCheckbox1.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox1.get(e.OwnerId);
                                if(mapsum.containskey('Q3'))
                                {
                                    decimal scoresum = mapsum.get('Q3');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q3',scoresum);
                                    mappedScoresSumCheckbox1.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q3',1.0);
                                    mappedScoresSumCheckbox1.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumCheckbox1.put(e.OwnerId,new Map<String,decimal>{'Q3' => 1.0});
                            }  
                        }                    
                        if (e.V_xa_befintlig_aff_r__c == true)
                        {
                            if(mappedScoresSumCheckbox2.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox2.get(e.OwnerId);
                                if(mapsum.containskey('Q3'))
                                {
                                    decimal scoresum = mapsum.get('Q3');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q3',scoresum);
                                    mappedScoresSumCheckbox2.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q3',1.0);
                                    mappedScoresSumCheckbox2.put(e.OwnerId,mapsum);
                                }                    
                            }
                            else
                            {
                                mappedScoresSumCheckbox2.put(e.OwnerId,new Map<String,decimal>{'Q3' => 1.0});
                            }  
                        }                    
                        if (e.ka_avtalad_aff_r__c == true)
                        {
                            if(mappedScoresSumCheckbox3.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox3.get(e.OwnerId);
                                if(mapsum.containskey('Q3'))
                                {
                                    decimal scoresum = mapsum.get('Q3');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q3',scoresum);
                                    mappedScoresSumCheckbox3.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q3',1.0);
                                    mappedScoresSumCheckbox3.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumCheckbox3.put(e.OwnerId,new Map<String,decimal>{'Q3' => 1.0});
                            }  
                        }                    
                        if (e.Sambes_k__c == true)
                        {
                            if(mappedScoresSumSambesokChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q3'))
                                {
                                    decimal scoresum = mapsum.get('Q3');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q3',scoresum);
                                    mappedScoresSumSambesokChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q3',1.0);
                                    mappedScoresSumSambesokChecked.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumSambesokChecked.put(e.OwnerId,new Map<String,decimal>{'Q3' => 1.0});
                            }  
                        } 
                        
                        //Y.K SALEF-1897 : Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
                        if (e.Sambes_k_Cygate_kontakt__c == true)
                        {
                            if(mappedScoresSumSambesokCygateKontaktChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokCygateKontaktChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q3'))
                                {
                                    decimal scoresum = mapsum.get('Q3');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q3',scoresum);
                                    mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q3',1.0);
                                    mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,mapsum);
                                
                            }
                            }
                            else
                            {
                                mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,new Map<String,decimal>{'Q3' => 1.0});
                            }  
                        
                        }                  
                        if (e.Sambes_k__c == false && e.Sambes_k_Cygate_kontakt__c == false)
                        {
                            if(mappedScoresSumSambesokUnChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokUnChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q3'))
                                {
                                    decimal scoresum = mapsum.get('Q3');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q3',scoresum);
                                    mappedScoresSumSambesokUnChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q3',1.0);
                                    mappedScoresSumSambesokUnChecked.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumSambesokUnChecked.put(e.OwnerId,new Map<String,decimal>{'Q3' => 1.0});
                            }  
                        }
                    }    
                    if(e.EndDateTime >= Q41 && e.EndDateTime <= Q42)
                    {
                        if(e.Customer_status__c == 'Befintlig kund')
                        {
                            if(mappedScoresSumStatus1.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus1.get(e.OwnerId);
                                if(mapsum.containskey('Q4'))
                                {
                                    decimal scoresum = mapsum.get('Q4');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q4',scoresum);
                                    mappedScoresSumStatus1.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q4',1.0);
                                    mappedScoresSumStatus1.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumStatus1.put(e.OwnerId,new Map<String,decimal>{'Q4' => 1.0});
                            }
                        }
                        if (e.Customer_status__c == 'Ny Kund')
                        {
                            if(mappedScoresSumStatus2.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus2.get(e.OwnerId);
                                if(mapsum.containskey('Q4'))
                                {
                                    decimal scoresum = mapsum.get('Q4');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q4',scoresum);
                                    mappedScoresSumStatus2.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q4',1.0);
                                    mappedScoresSumStatus2.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumStatus2.put(e.OwnerId,new Map<String,decimal>{'Q4' => 1.0});
                            }                        
                        }   
                        if (e.Customer_status__c == 'Befintlig kund, ny kontakt')
                        {
                            if(mappedScoresSumStatus3.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumStatus3.get(e.OwnerId);
                                if(mapsum.containskey('Q4'))
                                {
                                    decimal scoresum = mapsum.get('Q4');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q4',scoresum);
                                    mappedScoresSumStatus3.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q4',1.0);
                                    mappedScoresSumStatus3.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumStatus3.put(e.OwnerId,new Map<String,decimal>{'Q4' => 1.0});
                            }  
                        }                    
                        if (e.Bredda_aff_ren__c == true)
                        {
                            if(mappedScoresSumCheckbox1.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox1.get(e.OwnerId);
                                if(mapsum.containskey('Q4'))
                                {
                                    decimal scoresum = mapsum.get('Q4');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q4',scoresum);
                                    mappedScoresSumCheckbox1.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q4',1.0);
                                    mappedScoresSumCheckbox1.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumCheckbox1.put(e.OwnerId,new Map<String,decimal>{'Q4' => 1.0});
                            }  
                        }                    
                        if (e.V_xa_befintlig_aff_r__c == true)
                        {
                            if(mappedScoresSumCheckbox2.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox2.get(e.OwnerId);
                                if(mapsum.containskey('Q4'))
                                {
                                    decimal scoresum = mapsum.get('Q4');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q4',scoresum);
                                    mappedScoresSumCheckbox2.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q4',1.0);
                                    mappedScoresSumCheckbox2.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumCheckbox2.put(e.OwnerId,new Map<String,decimal>{'Q4' => 1.0});
                            }  
                        }                    
                        if (e.ka_avtalad_aff_r__c == true)
                        {
                            if(mappedScoresSumCheckbox3.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumCheckbox3.get(e.OwnerId);
                                if(mapsum.containskey('Q4'))
                                {
                                    decimal scoresum = mapsum.get('Q4');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q4',scoresum);
                                    mappedScoresSumCheckbox3.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q4',1.0);
                                    mappedScoresSumCheckbox3.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumCheckbox3.put(e.OwnerId,new Map<String,decimal>{'Q4' => 1.0});
                            }  
                        }                    
                        if (e.Sambes_k__c == true)
                        {
                            if(mappedScoresSumSambesokChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q4'))
                                {
                                    decimal scoresum = mapsum.get('Q4');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q4',scoresum);
                                    mappedScoresSumSambesokChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q4',1.0);
                                    mappedScoresSumSambesokChecked.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumSambesokChecked.put(e.OwnerId,new Map<String,decimal>{'Q4' => 1.0});
                            }  
                        } 
                        
                        //Y.K SALEF-1897 : Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
                        if (e.Sambes_k_Cygate_kontakt__c == true)
                        {
                            if(mappedScoresSumSambesokCygateKontaktChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokCygateKontaktChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q4'))
                                {
                                    decimal scoresum = mapsum.get('Q4');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q4',scoresum);
                                    mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q4',1.0);
                                    mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumSambesokCygateKontaktChecked.put(e.OwnerId,new Map<String,decimal>{'Q4' => 1.0});
                            }  
                        } 
                                          
                        if (e.Sambes_k__c == false && e.Sambes_k_Cygate_kontakt__c == false)
                        {
                            if(mappedScoresSumSambesokUnChecked.containskey(e.OwnerId))
                            {
                                Map<string,decimal> mapsum = mappedScoresSumSambesokUnChecked.get(e.OwnerId);
                                if(mapsum.containskey('Q4'))
                                {
                                    decimal scoresum = mapsum.get('Q4');
                                    scoresum = scoresum+1;                   
                                    mapsum.put('Q4',scoresum);
                                    mappedScoresSumSambesokUnChecked.put(e.OwnerId,mapsum);
                                }
                                else
                                {
                                    mapsum.put('Q4',1.0);
                                    mappedScoresSumSambesokUnChecked.put(e.OwnerId,mapsum);
                                }
                            }
                            else
                            {
                                mappedScoresSumSambesokUnChecked.put(e.OwnerId,new Map<String,decimal>{'Q4' => 1.0});
                            }  

                        }

                    }    
                }
            }  
            Map<Id,Quarterly_Performance_score__c> updateListQPS = new Map<Id,Quarterly_Performance_score__c>();
            if(quarterlyPerformances != null)
            {
                system.debug('inside quarterlyPerformances1 - num5');
                for (Quarterly_Performance_Score__c qps : quarterlyPerformances)
                {
                    if (qps.Name == 'Q1')
                    {
                        if(mappedScoresSumStatus1!=null)
                        {
                            if(mappedScoresSumStatus1.get(qps.User_Performance__r.User__c) != null)
                            {                      
                                qps.Befintlig_Kund__c = mappedScoresSumStatus1.get(qps.User_Performance__r.User__c).get('Q1');
                            }
                            else
                            {
                                qps.Befintlig_Kund__c = 0;
                            }
                        }
                        else
                        {
                            qps.Befintlig_Kund__c = 0;
                        }
                        if(mappedScoresSumStatus2!=null)
                        {                       
                            if(mappedScoresSumStatus2.get(qps.User_Performance__r.User__c)!=null)
                            {
                                qps.Ny_Kund__c = mappedScoresSumStatus2.get(qps.User_Performance__r.User__c).get('Q1');                         
                            }
                            else
                            {
                                qps.Ny_Kund__c = 0;
                            }    
                        }
                        else
                        {
                            qps.Ny_Kund__c = 0;                 
                        }
                        if(mappedScoresSumStatus3!=null)
                        {                   
                           if(mappedScoresSumStatus3.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Befintlig_Kund_Ny_Kontakt__c = mappedScoresSumStatus3.get(qps.User_Performance__r.User__c).get('Q1');
                            }
                            else
                            {
                                qps.Befintlig_Kund_Ny_Kontakt__c = 0;
                            }
                        }
                        else
                        {
                            qps.Befintlig_Kund_Ny_Kontakt__c = 0;
                        }
                        if(mappedScoresSumCheckbox1 != null)
                        {
                            if(mappedScoresSumCheckbox1.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Bredda_Aff_ren__c = mappedScoresSumCheckbox1.get(qps.User_Performance__r.User__c).get('Q1');
                            }
                            else
                            {
                                qps.Bredda_Aff_ren__c = 0;
                            }
                        }
                        else
                        {
                            qps.Bredda_Aff_ren__c = 0;
                        }
                        if(mappedScoresSumCheckbox2 != null)
                        {
                            if(mappedScoresSumCheckbox2.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.V_xa_Befintlig_Aff_r__c = mappedScoresSumCheckbox2.get(qps.User_Performance__r.User__c).get('Q1');
                            }
                            else
                            {
                                qps.V_xa_Befintlig_Aff_r__c = 0;
                            }
                        }
                        else
                        {
                            qps.V_xa_Befintlig_Aff_r__c = 0;
                        }
                        if(mappedScoresSumCheckbox3 != null)
                        {
                            if(mappedScoresSumCheckbox3.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.ka_Avtalad_Aff_r__c = mappedScoresSumCheckbox3.get(qps.User_Performance__r.User__c).get('Q1');
                            }
                            else
                            {
                                qps.ka_Avtalad_Aff_r__c = 0;
                            }
                            if(mappedScoresSumSambesokChecked != null)
                            {      
                                if(mappedScoresSumSambesokChecked.get(qps.User_Performance__r.User__c) != null)
                                {
                                    qps.Sambes_k__c = mappedScoresSumSambesokChecked.get(qps.User_Performance__r.User__c).get('Q1');
                                }
                                else
                                {
                                    qps.Sambes_k__c = 0;
                                }
                            }
                        }
                        else
                        {
                            qps.Sambes_k__c = 0;
                        }
                        
                        //Y.K SALEF-1897 : Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
                        if(mappedScoresSumSambesokCygateKontaktChecked != null)
                            {      
                                if(mappedScoresSumSambesokCygateKontaktChecked.get(qps.User_Performance__r.User__c) != null)
                                {
                                    qps.Sambes_k_Cygate_kontakt__c = mappedScoresSumSambesokCygateKontaktChecked.get(qps.User_Performance__r.User__c).get('Q1');
                                }
                                else
                                {
                                    qps.Sambes_k_Cygate_kontakt__c = 0;
                                }
                            
                        }
                        else
                        {
                            qps.Sambes_k_Cygate_kontakt__c = 0;
                        }
                        
                        if(mappedScoresSumSambesokUnChecked != null)
                        {
                            if(mappedScoresSumSambesokUnChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Esambes_k__c = mappedScoresSumSambesokUnChecked.get(qps.User_Performance__r.User__c).get('Q1');
                            }
                            else
                            {
                                qps.Esambes_k__c = 0;
                            }
                        }
                        else
                        {
                            qps.Esambes_k__c = 0;
                        }
                        updateListQPS.put(qps.Id,qps);                      
                    }
                }
            }
            if(quarterlyPerformances2 != null)
            {
                system.debug('inside quarterlyPerformances2 - num6');
                for (Quarterly_Performance_Score__c qps : quarterlyPerformances2)
                {
                    if ( qps.Name == 'Q2')
                    {
                        if(mappedScoresSumStatus1 != null)
                        {
                            if(mappedScoresSumStatus1.get(qps.User_Performance__r.User__c) != null)
                            {                      
                                qps.Befintlig_Kund__c = mappedScoresSumStatus1.get(qps.User_Performance__r.User__c).get('Q2');
                            }
                            else
                            {
                                qps.Befintlig_Kund__c = 0;
                            }
                        }
                        else
                        {
                            qps.Befintlig_Kund__c = 0;
                        }
                        if(mappedScoresSumStatus2 != null)
                        {  
                            if(mappedScoresSumStatus2.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Ny_Kund__c = mappedScoresSumStatus2.get(qps.User_Performance__r.User__c).get('Q2');
                            }
                            else
                            {
                                qps.Ny_Kund__c = 0;
                            }
                        }
                        else
                        {
                            qps.Ny_Kund__c = 0;
                        }
                        if(mappedScoresSumStatus3 != null)
                        {
                            if(mappedScoresSumStatus3.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Befintlig_Kund_Ny_Kontakt__c = mappedScoresSumStatus3.get(qps.User_Performance__r.User__c).get('Q2');
                            }
                            else
                            {
                                qps.Befintlig_Kund_Ny_Kontakt__c = 0;
                            }
                        }
                        else
                        {
                            qps.Befintlig_Kund_Ny_Kontakt__c = 0;
                        }
                        if(mappedScoresSumCheckbox1 != null)
                        { 
                            if(mappedScoresSumCheckbox1.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Bredda_Aff_ren__c = mappedScoresSumCheckbox1.get(qps.User_Performance__r.User__c).get('Q2');
                            }
                            else
                            {
                                qps.Bredda_Aff_ren__c = 0;
                            }
                        }
                        else
                        {
                            qps.Bredda_Aff_ren__c = 0;
                        }
                        if(mappedScoresSumCheckbox2 != null)
                        { 
                            if(mappedScoresSumCheckbox2.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.V_xa_Befintlig_Aff_r__c = mappedScoresSumCheckbox2.get(qps.User_Performance__r.User__c).get('Q2');
                            }
                            else
                            {
                                qps.V_xa_Befintlig_Aff_r__c = 0;
                            }
                        }
                        else
                        {
                            qps.V_xa_Befintlig_Aff_r__c = 0;
                        }
                        if(mappedScoresSumCheckbox3 != null)
                        {
                            if(mappedScoresSumCheckbox3.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.ka_Avtalad_Aff_r__c = mappedScoresSumCheckbox3.get(qps.User_Performance__r.User__c).get('Q2');
                            }
                            else
                            {
                                qps.ka_Avtalad_Aff_r__c = 0;
                            }
                        }
                        else
                        {
                            qps.ka_Avtalad_Aff_r__c = 0;
                        }
                        if(mappedScoresSumSambesokChecked != null)
                        {
                            if(mappedScoresSumSambesokChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Sambes_k__c = mappedScoresSumSambesokChecked.get(qps.User_Performance__r.User__c).get('Q2');
                            }
                            else
                            {
                                qps.Sambes_k__c = 0;
                            }
                        }
                        else
                        {
                            qps.Sambes_k__c = 0;
                        }
                        
                        //Y.K SALEF-1897 : Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
                        if(mappedScoresSumSambesokCygateKontaktChecked != null)
                        {
                            if(mappedScoresSumSambesokCygateKontaktChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Sambes_k_Cygate_kontakt__c = mappedScoresSumSambesokCygateKontaktChecked.get(qps.User_Performance__r.User__c).get('Q2');
                            }
                            else
                            {
                                qps.Sambes_k_Cygate_kontakt__c = 0;
                            }
                        }
                        else
                        {
                            qps.Sambes_k_Cygate_kontakt__c = 0;
                        }
                        
                        if(mappedScoresSumSambesokUnChecked != null)
                        {
                            if(mappedScoresSumSambesokUnChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Esambes_k__c = mappedScoresSumSambesokUnChecked.get(qps.User_Performance__r.User__c).get('Q2');
                            }
                            else
                            {
                                qps.Esambes_k__c = 0;
                            }
                        }
                        else
                        {
                            qps.Esambes_k__c = 0;
                        }
                        updateListQPS.put(qps.Id,qps);                      
                    }
                }
            }
            if(quarterlyPerformances3 != null)
            {
                system.debug('inside quarterlyPerformances3 - num7');
                for (Quarterly_Performance_Score__c qps : quarterlyPerformances3)
                {
                    if (qps.Name == 'Q3')
                    {
                        if(mappedScoresSumStatus1 != null)
                        { 
                            if(mappedScoresSumStatus1.get(qps.User_Performance__r.User__c) != null)
                            {                      
                                qps.Befintlig_Kund__c = mappedScoresSumStatus1.get(qps.User_Performance__r.User__c).get('Q3');
                            }
                            else
                            {
                                qps.Befintlig_Kund__c = 0;
                            }
                        }
                        else
                        {
                            qps.Befintlig_Kund__c = 0;
                        }
                        if(mappedScoresSumStatus2 != null)
                        {
                            if(mappedScoresSumStatus2.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Ny_Kund__c = mappedScoresSumStatus2.get(qps.User_Performance__r.User__c).get('Q3');
                            }
                            else{
                                qps.Ny_Kund__c = 0;
                            }
                        }
                        else
                        {
                            qps.Ny_Kund__c = 0;
                        }
                        if(mappedScoresSumStatus3 != null)
                        {
                            if(mappedScoresSumStatus3.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Befintlig_Kund_Ny_Kontakt__c = mappedScoresSumStatus3.get(qps.User_Performance__r.User__c).get('Q3');
                            }
                            else
                            {
                                qps.Befintlig_Kund_Ny_Kontakt__c = 0;
                            }
                        }
                        else
                        {
                            qps.Befintlig_Kund_Ny_Kontakt__c = 0;
                        }
                        if(mappedScoresSumCheckbox1 != null)
                        {
                            if(mappedScoresSumCheckbox1.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Bredda_Aff_ren__c = mappedScoresSumCheckbox1.get(qps.User_Performance__r.User__c).get('Q3');
                            }
                            else
                            {
                                qps.Bredda_Aff_ren__c = 0;
                            }
                        }
                        else
                        {
                            qps.Bredda_Aff_ren__c = 0;
                        }
                        if(mappedScoresSumCheckbox2 != null)
                        {
                            if(mappedScoresSumCheckbox2.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.V_xa_Befintlig_Aff_r__c = mappedScoresSumCheckbox2.get(qps.User_Performance__r.User__c).get('Q3');
                            }
                            else
                            {
                                qps.V_xa_Befintlig_Aff_r__c = 0;
                            }
                        }
                        else
                        {
                            qps.V_xa_Befintlig_Aff_r__c = 0;
                        }
                        if(mappedScoresSumCheckbox3 != null)
                        {
                            if(mappedScoresSumCheckbox3.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.ka_Avtalad_Aff_r__c = mappedScoresSumCheckbox3.get(qps.User_Performance__r.User__c).get('Q3');
                            }
                            else
                            {
                                qps.ka_Avtalad_Aff_r__c = 0;
                            }
                        }
                        else
                        {
                            qps.ka_Avtalad_Aff_r__c = 0;
                        }
                        if(mappedScoresSumSambesokChecked != null)
                        {
                            if(mappedScoresSumSambesokChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Sambes_k__c = mappedScoresSumSambesokChecked.get(qps.User_Performance__r.User__c).get('Q3');
                            }
                            else
                            {
                                qps.Sambes_k__c = 0;
                            }
                        }
                        else
                        {
                            qps.Sambes_k__c = 0;
                        }
                        
                        //Y.K SALEF-1897 : Leaderboard - Sambesök logic - edit the code for Sambesök logic and points 
                        if(mappedScoresSumSambesokCygateKontaktChecked != null)
                        {
                            if(mappedScoresSumSambesokCygateKontaktChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Sambes_k_Cygate_kontakt__c = mappedScoresSumSambesokCygateKontaktChecked.get(qps.User_Performance__r.User__c).get('Q3');
                            }
                            else
                            {
                                qps.Sambes_k_Cygate_kontakt__c = 0;
                            }
                        }
                        else
                        {
                            qps.Sambes_k_Cygate_kontakt__c = 0;
                        }
                        
                        if(mappedScoresSumSambesokUnChecked != null)
                        {
                            if(mappedScoresSumSambesokUnChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Esambes_k__c = mappedScoresSumSambesokUnChecked.get(qps.User_Performance__r.User__c).get('Q3');
                            }
                            else
                            {
                                qps.Esambes_k__c = 0;
                            }
                        }
                        else
                        {
                            qps.Esambes_k__c = 0;
                        }
                        updateListQPS.put(qps.Id,qps);
                            
                    }
                }
            }
            if(quarterlyPerformances4 != null)
            {
                system.debug('inside quarterlyPerformances4 - num8');
                for (Quarterly_Performance_Score__c qps : quarterlyPerformances4)
                {
                    if (qps.Name == 'Q4')
                    {
                        if(mappedScoresSumStatus1 != null)
                        {
                            if(mappedScoresSumStatus1.get(qps.User_Performance__r.User__c) != null)
                            {                      
                                qps.Befintlig_Kund__c = mappedScoresSumStatus1.get(qps.User_Performance__r.User__c).get('Q4');
                            }
                            else
                            {
                                qps.Befintlig_Kund__c = 0;
                            }
                        }
                        else
                        {
                            qps.Befintlig_Kund__c = 0;
                        }
                        if(mappedScoresSumStatus2.get(qps.User_Performance__r.User__c) != null)
                        {
                            if(mappedScoresSumStatus2.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Ny_Kund__c = mappedScoresSumStatus2.get(qps.User_Performance__r.User__c).get('Q4');
                            }
                            else
                            {
                                qps.Ny_Kund__c = 0;
                            }
                        }
                        else
                        {
                            qps.Ny_Kund__c = 0;
                        }
                        if(mappedScoresSumStatus3 != null)
                        {
                            if(mappedScoresSumStatus3.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Befintlig_Kund_Ny_Kontakt__c = mappedScoresSumStatus3.get(qps.User_Performance__r.User__c).get('Q4');
                            }
                            else
                            {
                                qps.Befintlig_Kund_Ny_Kontakt__c = 0;
                            }
                        }
                        else
                        {
                            qps.Befintlig_Kund_Ny_Kontakt__c = 0;
                        }
                        if(mappedScoresSumCheckbox1 != null)
                        {
                            if(mappedScoresSumCheckbox1.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Bredda_Aff_ren__c = mappedScoresSumCheckbox1.get(qps.User_Performance__r.User__c).get('Q4');
                            }
                            else
                            {
                                qps.Bredda_Aff_ren__c = 0;
                            }
                        }
                        else
                        {
                            qps.Bredda_Aff_ren__c = 0;
                        }
                        if(mappedScoresSumCheckbox2 != null)
                        {
                            if(mappedScoresSumCheckbox2.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.V_xa_Befintlig_Aff_r__c = mappedScoresSumCheckbox2.get(qps.User_Performance__r.User__c).get('Q4');
                            }
                            else
                            {
                                qps.V_xa_Befintlig_Aff_r__c = 0;
                            }
                        }
                        else
                        {
                            qps.V_xa_Befintlig_Aff_r__c = 0;
                        }
                       if(mappedScoresSumCheckbox3 != null){
                            if(mappedScoresSumCheckbox3.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.ka_Avtalad_Aff_r__c = mappedScoresSumCheckbox3.get(qps.User_Performance__r.User__c).get('Q4');
                            }
                            else
                            {
                                qps.ka_Avtalad_Aff_r__c = 0;
                            }
                        }
                        else
                        {
                            qps.ka_Avtalad_Aff_r__c = 0;
                        }
                        if(mappedScoresSumSambesokChecked != null)
                        {
                            if(mappedScoresSumSambesokChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Sambes_k__c = mappedScoresSumSambesokChecked.get(qps.User_Performance__r.User__c).get('Q4');
                            }
                            else
                            {
                                qps.Sambes_k__c = 0;
                            }
                        }
                        else
                        {
                            qps.Sambes_k__c = 0;
                        }
                        
                        // Y.K SALEF-1897 : Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
                        if(mappedScoresSumSambesokCygateKontaktChecked != null)
                        {
                            if(mappedScoresSumSambesokCygateKontaktChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Sambes_k_Cygate_kontakt__c = mappedScoresSumSambesokCygateKontaktChecked.get(qps.User_Performance__r.User__c).get('Q4');
                            }
                            else
                            {
                                qps.Sambes_k_Cygate_kontakt__c = 0;
                            }
                        }
                        else
                        {
                            qps.Sambes_k_Cygate_kontakt__c = 0;
                        }
                        
                        if(mappedScoresSumSambesokUnChecked != null)
                        {
                            if(mappedScoresSumSambesokUnChecked.get(qps.User_Performance__r.User__c) != null)
                            {
                                qps.Esambes_k__c = mappedScoresSumSambesokUnChecked.get(qps.User_Performance__r.User__c).get('Q4');
                            }
                            else
                            {
                                qps.Esambes_k__c = 0;
                            }
                        }
                        else
                        {
                            qps.Esambes_k__c = 0;
                        }
                        updateListQPS.put(qps.Id,qps);                      
                    }
                }
            }
                       
            update updateListQPS.values();      
        }
    
    }
    
    
    //Author: V.M
    //Updates Competence Score and Competence Events Attended for the Yearly Performance 
    //based on all the Learning Assignments that has it's Training Plan Assignment Completed on current year.    
    /*public static void updateYearlyCompetenceScore(Map<Id,Training_Plan_Assignment__c> newMap){
        Set<Id> userIds = new Set<Id>(); 
        for (Training_Plan_Assignment__c la : newMap.values()){
            userIds.add(la.User__c);
        }

        if (userIds.size() > 0){
            //Get UserPerformances & YearlyPerformances
            Map<Id, User_Performance__c> userPerformances = getCreateUserPerformances(userIds);
            List<Yearly_Performance_Score__c> yearlyPerformances = getCreateYearlyPerformances(userPerformances.keySet());
            
            AggregateResult[] aggregatedEventScores = [SELECT User__c, SUM(Competence_Points__c) sum,
                                                       COUNT_DISTINCT(Training_Plan_Section_Assignment__r.Training_Plan_Assignment__r.Training_Plan__c) total
                                                       FROM Learning_Assignment__c 
                                                       WHERE User__c IN :userIds
                                                       AND Training_Plan_Section_Assignment__r.Training_Plan_Assignment__r.Status__c = 'Completed' 
                                                       AND Completed_On__c >= :Date.newInstance(PROCESS_YEAR, 1, 1)
                                                       AND Completed_On__c <= :Date.newInstance(PROCESS_YEAR, 12, 31)
                                                       GROUP BY User__c];
            
            Map<Id, AggregatedScore> mappedScores = new Map<Id, AggregatedScore>();
            for (AggregateResult aes : aggregatedEventScores){
                Id userId = (Id)aes.get('User__c');         
                mappedScores.put(userId, 
                                 new AggregatedScore(
                                     Integer.valueOf(aes.get('sum')),
                                     Integer.valueOf(aes.get('total'))
                                 ));
            }
            for (Yearly_Performance_Score__c yps : yearlyPerformances){
                if (mappedScores.get(yps.User_Performance__r.User__c) != null){
                    yps.Competence_Score__c = mappedScores.get(yps.User_Performance__r.User__c).TotalScore;
                    yps.Competence_Events_Attended__c = mappedScores.get(yps.User_Performance__r.User__c).TotalActions;
                }   
            }
            update yearlyPerformances;
        }
    }*/
    
    //Author: 
    //Updates Competence Score and Competence Events Attended for the Quarterly Performance 
    //based on all the Learning Assignments that has it's Training Plan Assignment Completed on current quarter.    
/*    public static void updateQuarterlyCompetenceScore(Map<Id,Training_Plan_Assignment__c> newMap){
        Set<Id> userIds = new Set<Id>(); 
        for (Training_Plan_Assignment__c la : newMap.values()){
            userIds.add(la.User__c);
        }

        if (userIds.size() > 0){
            
            Map<Id, User_Performance__c> userPerformances = getCreateUserPerformances(userIds);
            datetime Q11 = datetime.newInstance(CURRENT_YEAR, 1, 1);
            datetime Q12 = datetime.newInstance(CURRENT_YEAR, 3, 31);
            datetime Q21 = datetime.newInstance(CURRENT_YEAR, 4, 1);
            datetime Q22 = datetime.newInstance(CURRENT_YEAR, 6, 30);
            datetime Q31 = datetime.newInstance(CURRENT_YEAR, 7, 1);
            datetime Q32 = datetime.newInstance(CURRENT_YEAR, 9, 30);
            datetime Q41 = datetime.newInstance(CURRENT_YEAR, 10, 1);
            datetime Q42 = datetime.newInstance(CURRENT_YEAR, 12, 31);
            Map<String,List<Quarterly_Performance_Score__c>> quarterlyPerformancesAll = getCreateAllQuarterlyPerformances(userPerformances.keySet());
             List<Quarterly_Performance_Score__c> quarterlyPerformances = quarterlyPerformancesAll.get('Q1');
             List<Quarterly_Performance_Score__c> quarterlyPerformances2 = quarterlyPerformancesAll.get('Q2');
             List<Quarterly_Performance_Score__c> quarterlyPerformances3 = quarterlyPerformancesAll.get('Q3');
             List<Quarterly_Performance_Score__c> quarterlyPerformances4 = quarterlyPerformancesAll.get('Q4');
            List<Learning_Assignment__c> aggregatedEventScores1 = [SELECT User__c,Competence_Points__c,Completed_On__c,
                                                       Training_Plan_Section_Assignment__r.Training_Plan_Assignment__r.Training_Plan__c
                                                       FROM Learning_Assignment__c 
                                                       WHERE User__c IN :userIds
                                                       AND Training_Plan_Section_Assignment__r.Training_Plan_Assignment__r.Status__c = 'Completed' 
                                                       AND Completed_On__c >= :Date.newInstance(CURRENT_YEAR, 1, 1)
                                                       AND Completed_On__c <= :Date.newInstance(CURRENT_YEAR, 12, 31)];
             Map<Id,decimal> mappedScoresSum1 = new Map<Id, decimal>();
             Map<Id,decimal> mappedScoresSum2 = new Map<Id, decimal>();
             Map<Id,decimal> mappedScoresSum3 = new Map<Id, decimal>();
             Map<Id,decimal> mappedScoresSum4 = new Map<Id, decimal>();
            for(Learning_Assignment__c e:aggregatedEventScores1){
                //Id userId = (Id)e.get('User__c');
                if(e.Completed_On__c >= Q11 && e.Completed_On__c <= Q12){
                    if(mappedScoresSum1.containskey(e.User__c)){
                        decimal scoreSum = mappedscoresSum1.get(e.User__c);
                        scoreSum += e.Competence_Points__c;
                        mappedScoresSum1.put(e.User__c,scoreSum);
                    }
                    else{
                        mappedScoresSum1.put(e.User__c,e.Competence_Points__c);
                    }
                }
                else if(e.Completed_On__c >= Q21 && e.Completed_On__c <= Q22){
                    if(mappedScoresSum2.containskey(e.User__c)){
                        decimal scoreSum = mappedscoresSum2.get(e.User__c);
                        scoreSum += e.Competence_Points__c;
                        mappedScoresSum2.put(e.User__c,scoreSum);
                    }
                    else{
                        mappedScoresSum2.put(e.User__c,e.Competence_Points__c);
                    }
                }
                else if(e.Completed_On__c >= Q31 && e.Completed_On__c <= Q32){
                    if(mappedScoresSum3.containskey(e.User__c)){
                        decimal scoreSum = mappedscoresSum3.get(e.User__c);
                        scoreSum += e.Competence_Points__c;
                        mappedScoresSum3.put(e.User__c,scoreSum);
                    }
                    else{
                        mappedScoresSum3.put(e.User__c,e.Competence_Points__c);
                    }
                }
                else if(e.Completed_On__c >= Q41 && e.Completed_On__c <= Q42){
                    if(mappedScoresSum4.containskey(e.User__c)){
                        decimal scoreSum = mappedscoresSum4.get(e.User__c);
                        scoreSum += e.Competence_Points__c;
                        mappedScoresSum4.put(e.User__c,scoreSum);
                    }
                    else{
                        mappedScoresSum4.put(e.User__c,e.Competence_Points__c);
                    }
                }
            }
           List<quarterly_performance_score__c> updateListQPS = new List<Quarterly_Performance_score__c>();
            for (Quarterly_Performance_Score__c qps : quarterlyPerformances){
                if (mappedScoresSum1.get(qps.User_Performance__r.User__c) != null & qps.Name == 'Q1'){
                    qps.Competence_Score__c = mappedScoresSum1.get(qps.User_Performance__r.User__c);
                    updateListQPS.add(qps);
                }
            }
            for (Quarterly_Performance_Score__c qps : quarterlyPerformances2){
                if (mappedScoresSum2.get(qps.User_Performance__r.User__c) != null & qps.Name == 'Q2'){
                    qps.Competence_Score__c = mappedScoresSum2.get(qps.User_Performance__r.User__c);
                    updateListQPS.add(qps);
                }
            }
            for (Quarterly_Performance_Score__c qps : quarterlyPerformances3){
                if (mappedScoresSum3.get(qps.User_Performance__r.User__c) != null & qps.Name == 'Q3'){
                    qps.Competence_Score__c = mappedScoresSum3.get(qps.User_Performance__r.User__c);
                    updateListQPS.add(qps);
                }
            }
            for (Quarterly_Performance_Score__c qps : quarterlyPerformances4){
                if (mappedScoresSum4.get(qps.User_Performance__r.User__c) != null & qps.Name == 'Q4'){
                    qps.Competence_Score__c = mappedScoresSum4.get(qps.User_Performance__r.User__c);
                    updateListQPS.add(qps);
                }
            }
            
            update updateListQPS;
        }
    }
    */
    //Returns the Yearly Performance Scores, if the User_Performance__c does not have a Yearly_Performance__c for the Current Year, it creates one and then returns it.
    private static List<Yearly_Performance_Score__c> getCreateYearlyPerformances(Set<Id> userPerformanceIds){
        List<Yearly_Performance_Score__c> yearlyPerformances = new List<Yearly_Performance_Score__c>([SELECT Id, User_Performance__r.User__c
                                                                                                      FROM Yearly_Performance_Score__c 
                                                                                                      WHERE Name = :String.valueOf(PROCESS_YEAR) 
                                                                                                      AND User_Performance__c IN :userPerformanceIds]);
        
        //If User Performance dont have a Yearly Performance
        if (userPerformanceIds.size() > yearlyPerformances.size()){
            createYearlyPerformances(userPerformanceIds);       
            
            yearlyPerformances = new List<Yearly_Performance_Score__c>([SELECT Id, User_Performance__r.User__c
                                                                        FROM Yearly_Performance_Score__c 
                                                                        WHERE Name = :String.valueOf(PROCESS_YEAR) 
                                                                        AND User_Performance__c IN :userPerformanceIds]);       
        }
        
        return yearlyPerformances;
    }
        
    //Returns the Quarterly Performance Scores, if the User_Performance__c does not have a Quarterly_Performance__c for the Current Year, it creates one and then returns it.
    private static Map<String,List<Quarterly_Performance_Score__c>> getCreateAllQuarterlyPerformances(Set<Id> userPerformanceIds , Set<Id> yearlyPerformanceIds){
         
         //for 1st quarter
        List<Quarterly_Performance_Score__c> quarterlyPerformances = new List<Quarterly_Performance_Score__c>([SELECT Id,Name , User_Performance__r.User__c
                                                                                                      FROM Quarterly_Performance_Score__c 
                                                                                                      WHERE User_Performance__c IN :userPerformanceIds AND Yearly_Performance_Score__c IN : yearlyPerformanceIds]);
                                                                                                      
         List<User_Performance__c> uPerformances = new List<User_Performance__c>([SELECT Id,User__c
                                                                                                      FROM User_Performance__c 
                                                                                                      WHERE Id IN :userPerformanceIds]);
                                                                                                      
         List<Yearly_Performance_Score__c> yPerformances = new List<Yearly_Performance_Score__c>([SELECT Id,Name , User_Performance__r.User__c
                                                                                                      FROM Yearly_Performance_Score__c 
                                                                                                      WHERE Id IN :yearlyPerformanceIds]);  
                                                                                                  
                //If User Performance dont have a Quaterly Performance
        if (userPerformanceIds.size() > quarterlyPerformances.size())
        {            
            system.debug('inside userperformances size - num9');
            createFirstQuarterlyPerformances(userPerformanceIds,yearlyPerformanceIds);       
            createSecondQuarterlyPerformances(userPerformanceIds,yearlyPerformanceIds);      
            createThirdQuarterlyPerformances(userPerformanceIds,yearlyPerformanceIds);       
            createFourthQuarterlyPerformances(userPerformanceIds,yearlyPerformanceIds);      
            
            quarterlyPerformances = new List<Quarterly_Performance_Score__c>([SELECT Id,Name , User_Performance__r.User__c
                                                                                                      FROM Quarterly_Performance_Score__c 
                                                                                                      WHERE User_Performance__c IN :userPerformanceIds AND Yearly_Performance_Score__c IN : yearlyPerformanceIds]);     
        }  
        map<string,List<Quarterly_Performance_Score__c>> nameQuarterMap= new Map<string,List<Quarterly_Performance_Score__c>>();
        String quar1 = 'Q1';
        string quar2 = 'Q2';
        string quar3 = 'Q3';
        string quar4 = 'Q4';
        
        for(Quarterly_performance_Score__c qpc: quarterlyPerformances)
        {
            for(Yearly_performance_Score__c y: yPerformances)
            {
                for(User_performance__c u: uPerformances)
                {
                    if(y.user_performance__r.user__c == u.user__c)
                    {
                        if(qpc.name == quar1)
                        {
                            if(nameQuarterMap.containskey(quar1))
                            {
                                List<Quarterly_Performance_Score__c> listPFS = nameQuarterMap.get(quar1);
                                listPFS.add(qpc);
                                nameQuarterMap.put(quar1,listPFS);
                            }
                            else
                            {
                                List<Quarterly_Performance_Score__c> listPFSNew = new List<Quarterly_Performance_Score__c>();
                                listPFSNew.add(qpc);
                                nameQuarterMap.put(quar1,listPFSNew);
                            }
            
                        }
                        else if(qpc.name == quar2)
                        {
                            if(nameQuarterMap.containskey(quar2))
                            {
                                List<Quarterly_Performance_Score__c> listPFS = nameQuarterMap.get(quar2);
                                listPFS.add(qpc);
                                nameQuarterMap.put(quar2,listPFS);
                            }
                            else
                            {
                                List<Quarterly_Performance_Score__c> listPFSNew = new List<Quarterly_Performance_Score__c>();
                                listPFSNew.add(qpc);
                                nameQuarterMap.put(quar2,listPFSNew);
                            }            
                        }
                        else if(qpc.name == quar3)
                        {
                            if(nameQuarterMap.containskey(quar3))
                            {
                                List<Quarterly_Performance_Score__c> listPFS = nameQuarterMap.get(quar3);
                                listPFS.add(qpc);
                                nameQuarterMap.put(quar3,listPFS);
                            }
                            else
                            {
                                List<Quarterly_Performance_Score__c> listPFSNew = new List<Quarterly_Performance_Score__c>();
                                listPFSNew.add(qpc);
                                nameQuarterMap.put(quar3,listPFSNew);
                            }
                        }
                        else if(qpc.name == quar4)
                        {
                            if(nameQuarterMap.containskey(quar4))
                            {
                                List<Quarterly_Performance_Score__c> listPFS = nameQuarterMap.get(quar4);
                                listPFS.add(qpc);
                                nameQuarterMap.put(quar4,listPFS);
                            }
                            else
                            {
                                List<Quarterly_Performance_Score__c> listPFSNew = new List<Quarterly_Performance_Score__c>();
                                listPFSNew.add(qpc);
                                nameQuarterMap.put(quar4,listPFSNew);
                            }
                        }
                    }
                }
            }
        }

        //return quarterlyPerformances;
        return nameQuarterMap;
    }


    //Creates a Yearly_Performance__c for the current year for User_Performance__c ids inputed and returns it
    private static List<Yearly_Performance_Score__c> createYearlyPerformances(Set<Id> userPerformanceIds){
        //Get all the users without UserPerformance
        List<User_Performance__c> upWithoutYearlyPerformance = [SELECT Id, Name, User__c
                                                                FROM User_Performance__c
                                                                WHERE Id NOT IN (SELECT User_Performance__c FROM Yearly_Performance_Score__c WHERE Name = :String.valueOf(PROCESS_YEAR)) 
                                                                AND Id IN :userPerformanceIds];
                                                                
        List<Yearly_Performance_Score__c> newYearlyPerformances = new List<Yearly_Performance_Score__c>();
        if(upWithoutYearlyPerformance.size() > 0)
        {
            for (User_Performance__c up : upWithoutYearlyPerformance)
            {
                Yearly_Performance_Score__c yps = new Yearly_Performance_Score__c();
                yps.Name = String.valueOf(Date.today().year());
                yps.User_Performance__c = up.Id;
                newYearlyPerformances.add(yps);
            }
            if(newYearlyPerformances != null)
            {
                insert newYearlyPerformances;
            }
        }
        return newYearlyPerformances;
    }
    
    
    
// Creates first quarterly performance for the user for current year    
    private static void createFirstQuarterlyPerformances(Set<Id> userPerformanceIds, Set<Id> yearlyPerformanceIds){
        //Get all the users without UserPerformance
        List<Yearly_Performance_Score__c> upWithoutQuarterlyPerformance1 = [SELECT Id,User_Performance__r.Id
                                                                            FROM Yearly_Performance_Score__c 
                                                                            WHERE Id NOT IN (SELECT Yearly_Performance_Score__c FROM Quarterly_Performance_Score__c WHERE Name = 'Q1' ) 
                                                                            AND Id IN :yearlyPerformanceIds];
        
        
        List<Quarterly_Performance_Score__c> newQuarterlyPerformances = new List<Quarterly_Performance_Score__c>();
        
        if(upWithoutQuarterlyPerformance1 != null)
        {
            for(Yearly_Performance_Score__c yp :upWithoutQuarterlyPerformance1)
            {
                system.debug('inside upWithoutQuarterlyPeformance1- num10');
                Quarterly_Performance_Score__c yps = new Quarterly_Performance_Score__c();          
                yps.Name = 'Q1';
                yps.User_Performance__c = yp.User_Performance__r.Id;
                yps.Yearly_Performance_Score__c = yp.Id;
                newQuarterlyPerformances.add(yps);  
                
            }
            if(newQuarterlyPerformances != null)
            {
                system.debug('inside quarter 1 insert- num11');
            insert newQuarterlyPerformances;
            }
        }
    }
    
    // Creates second quarterly performance for the user for current year   
    private static void  createSecondQuarterlyPerformances(Set<Id> userPerformanceIds , Set<Id> yearlyPerformanceIds){
        //Get all the users without UserPerformance
        
                                
        List<Yearly_Performance_Score__c> upWithoutQuarterlyPerformance1 = [SELECT Id, Name, User_Performance__r.Id
                                                                FROM Yearly_Performance_Score__c
                                                                WHERE Id NOT IN (SELECT Yearly_Performance_Score__c FROM Quarterly_Performance_Score__c WHERE Name = 'Q2' ) 
                                                                AND Id IN :yearlyPerformanceIds];
        List<Quarterly_Performance_Score__c> newQuarterlyPerformances = new List<Quarterly_Performance_Score__c>();
        
        if(upWithoutQuarterlyPerformance1 != null)
        {
            for(Yearly_Performance_Score__c yp :upWithoutQuarterlyPerformance1)
            {
                system.debug('inside upWithoutQuarterlyPeformance2- num12');
                Quarterly_Performance_Score__c yps = new Quarterly_Performance_Score__c();          
                yps.Name = 'Q2';
                yps.User_Performance__c = yp.User_Performance__r.Id;
                yps.Yearly_Performance_Score__c = yp.Id;
                newQuarterlyPerformances.add(yps);  
                
            }
            if(newQuarterlyPerformances != null)
            {
                system.debug('inside quarter 2 insert- num13');
                insert newQuarterlyPerformances;
            }
        }       
    }    
    
    // Creates third quarterly performance for the user for current year    
    private static void createThirdQuarterlyPerformances(Set<Id> userPerformanceIds , Set<Id> yearlyPerformanceIds){
        //Get all the users without UserPerformance
         List<Yearly_Performance_Score__c> upWithoutQuarterlyPerformance1 = [SELECT Id, Name, User_Performance__r.Id
                                                                FROM Yearly_Performance_Score__c
                                                                WHERE Id NOT IN (SELECT Yearly_Performance_Score__c FROM Quarterly_Performance_Score__c WHERE Name = 'Q3' ) 
                                                                AND Id IN :yearlyPerformanceIds];
        List<Quarterly_Performance_Score__c> newQuarterlyPerformances = new List<Quarterly_Performance_Score__c>();
       
        if(upWithoutQuarterlyPerformance1 != null)
        {
            for(Yearly_Performance_Score__c yp :upWithoutQuarterlyPerformance1)
            {
                system.debug('inside upWithoutQuarterlyPeformance3- num14');
                Quarterly_Performance_Score__c yps = new Quarterly_Performance_Score__c();          
                yps.Name = 'Q3';
                yps.User_Performance__c = yp.User_Performance__r.Id;
                yps.Yearly_Performance_Score__c = yp.Id;
                newQuarterlyPerformances.add(yps);  
                
            }
            if(newQuarterlyPerformances != null)
            {
                system.debug('inside quarter 3 insert- num15');
                insert newQuarterlyPerformances;
            }
        }
    }
    //cretes fourth quarterly performances for the current year
    private static void  createFourthQuarterlyPerformances(Set<Id> userPerformanceIds , Set<Id> yearlyPerformanceIds){
        //Get all the users without UserPerformance
        
                                
        List<Yearly_Performance_Score__c> upWithoutQuarterlyPerformance1 = [SELECT Id, Name, User_Performance__r.Id
                                                                FROM Yearly_Performance_Score__c
                                                                WHERE Id NOT IN (SELECT Yearly_Performance_Score__c FROM Quarterly_Performance_Score__c WHERE Name = 'Q4' ) 
                                                                AND Id IN :yearlyPerformanceIds];
        List<Quarterly_Performance_Score__c> newQuarterlyPerformances = new List<Quarterly_Performance_Score__c>();
        
        if(upWithoutQuarterlyPerformance1 != null)
        {
            for(Yearly_Performance_Score__c yp :upWithoutQuarterlyPerformance1)
            {
                system.debug('inside upWithoutQuarterlyPeformance4- num16');
                Quarterly_Performance_Score__c yps = new Quarterly_Performance_Score__c();          
                yps.Name = 'Q4';
                yps.User_Performance__c = yp.User_Performance__r.Id;
                yps.Yearly_Performance_Score__c = yp.Id;
                newQuarterlyPerformances.add(yps);  
                
            }
            if(newQuarterlyPerformances != null)
            {
                system.debug('inside quarter 4 insert- num17');
                insert newQuarterlyPerformances;
            }
        }       
    }
    
    //Returns User Performances of Users, if the User does not have a User Performance, it creates one and then returns it.
    private static Map<Id, User_Performance__c> getCreateUserPerformances(Set<Id> userIds){
        Map<Id, User_Performance__c> userPerformances = new Map<Id, User_Performance__c>([SELECT Id FROM User_Performance__c WHERE User__c IN :userIds]);
        
        //If user dont have a user performance
        if (userIds.size() > userPerformances.size())
        {
            userPerformances.putAll(createUserPerformances(userIds));       
        }
        return userPerformances;
    }
    
    private static Map<Id, Yearly_Performance_Score__c> getCreateYearlyPerformancesMap(Set<Id> userIds){
        Map<Id,Yearly_Performance_Score__c> yearlyPerformances = new Map<Id, Yearly_Performance_Score__c>([SELECT Id, User_Performance__r.User__c
                                                                                                      FROM Yearly_Performance_Score__c 
                                                                                                      WHERE Name = :String.valueOf(PROCESS_YEAR) 
                                                                                                      AND User_Performance__r.User__c IN :userIds]);
        
        //If user dont have a yearly performance
        if (userIds.size() > yearlyPerformances.size())
        {
            yearlyPerformances.putAll(createYearlyPerformances(userIds));       
        }
        return yearlyPerformances;
    }
    
    //Author: V.M
    //Creates User Performances for the Users
    private static Map<Id, User_Performance__c> createUserPerformances(Set<Id> userIds){
        //Get all the users without UserPerformance
        List<User> usersWithoutPerformance = [SELECT Id, Name FROM User WHERE Id NOT IN (SELECT User__c FROM User_Performance__c) AND Id IN :UserIds];
        List<User_Performance__c> newUserPerformances = new List<User_Performance__c>();
        
        for (User uwp : usersWithoutPerformance){
            User_Performance__c up = new User_Performance__c();
            up.Name = uwp.Name;
            up.User__c = uwp.Id;
            newUserPerformances.add(up);
        }
        
        insert newUserPerformances;
        
        return new Map<Id, User_Performance__c>(newUserPerformances);
    }
    
    private static Set<Id> getCygateClientMeetingsUserIds(List<Event> newList){
        Set<Id> userIds = new Set<Id>();        
        for(Event e : newList){
            if(isCygateClientMeeting(e)){
                userIds.add(e.OwnerId);
            }           
        }
        
        //Only include Cygate Performance Users
        List<User> filteredUsers = [SELECT Id FROM User WHERE Cygate_Performance_User__c = true AND ID IN :userIds];
        Set<Id> setIds = (new Map<Id,User>(filteredUsers)).keySet();
        
        return setIds;
    }
    
    // Author A.N
    // This method is used to define if the Event should be considered as a Cygate Client Meeting
    // Currently the definition for this is:
    // 1) Event has Cygate record type
    // 2) Event has points > 0
    public static Boolean isCygateClientMeeting(Event e){
        if(e.RecordtypeId != null && SEUtility.getRecordTypeDevName(e.RecordtypeId) == SEUtility.EVENT_REC_TYPE_CYGATE){
            return (e.Points__c != null && e.Points__c > 0);
        }
        return false;
    }
    
    //Author N.G 
    //Y.K. SALEF - 1445 : Updated the code to remove option "Telefonmöte" from leaderboard point logic  
    public static void updateYearlyTaskScore(List<Task> newList){        
        Set<Id> userIds = getCygateTasksUserIds(newList);

        if (userIds.size() > 0){        
            Map<Id, User_Performance__c> userPerformances = getCreateUserPerformances(userIds);
            List<Yearly_Performance_Score__c> yearlyPerformances = getCreateYearlyPerformances(userPerformances.keySet());
                        
            Set<String> taskOwnerlist   = new Set<String>();
            Set<String> eventGroup =  new Set<String>();
            Map<String, Integer> ownerscoreTotalMap = new Map<String, Integer>();
            Map<String, List<Integer>> ownerScoreListMap = new Map<String, List<Integer>>();
            Map<String, Integer> ownerRegisteredTaskTotalMap = new Map<String, Integer>();
            Map<String, List<Integer>> ownerRegisteredTaskListMap = new Map<String, List<Integer>>();
            
            for(Task t : newList){
                taskOwnerlist.add(t.OwnerId);
            }
            List<Event> eventList = [SELECT id,EndDateTime,WhoId,WhatID,OwnerId 
                                     FROM Event 
                                     WHERE Event_Complete__c = true 
                                     AND Legacy_Activity__c = false
                                     AND EndDateTime >= :Datetime.newInstance(PROCESS_YEAR, 1, 1)
                                     AND EndDateTime <= :Datetime.newInstance(PROCESS_YEAR, 12, 31)
                                     AND Event_Type__c != 'Telefonmöte'
                                     AND OwnerId in : taskOwnerlist];
            
            for(Event e: eventList){
                eventGroup.add(String.valueOf(e.EndDateTime.date())+'/'+e.OwnerId+'/'+e.WhatID +'/'+e.WhoId);                
            }

            AggregateResult[] aggregatedTaskScores = [SELECT OwnerId,ActivityDate,WhatID,WhoId,COUNT(Owner.Name) total, SUM(Points__c) sum 
                                                      FROM Task 
                                                      WHERE OwnerId IN :userIds 
                                                      AND Status = 'Stängd' 
                                                      AND Legacy_Activity__c = false                                     
                                                      AND ActivityDate >= :Date.newInstance(PROCESS_YEAR, 1, 1)
                                                      AND ActivityDate <= :Date.newInstance(PROCESS_YEAR, 12, 31) 
                                                      AND Event_Type__c != 'Telefonmöte'           
                                                      GROUP BY OwnerId,ActivityDate,WhatID,WhoId];
            
            for(AggregateResult ats : aggregatedTaskScores){                
                Integer sum = Integer.valueOf(ats.get('sum'));
                Integer total = Integer.valueOf(ats.get('total'));
                Id userId = (Id)ats.get('OwnerId');
                Date d = (Date)ats.get('ActivityDate');
                String accId = (String)ats.get('WhatID');
                String conId = (String)ats.get('WhoId');
                String taskgroup = String.valueOf(d)+'/'+userId +'/'+accId +'/'+ conId;
                if(!eventGroup.contains(taskgroup)){
                    if(ownerScoreListMap.containskey(userId))
                        ownerScoreListMap.get(userId).add(sum);
                    else 
                        ownerScoreListMap.put(userId, new List<Integer>{sum});
                    
                    //Populate Task Registered
                    if(ownerRegisteredTaskListMap.containskey(userId))
                        ownerRegisteredTaskListMap.get(userId).add(total);
                    else 
                        ownerRegisteredTaskListMap.put(userId, new List<Integer>{total});
                }            
            }

            for(String str : ownerScoreListMap.keySet()){
                List<Integer> scoreList = ownerScoreListMap.get(str);
                Integer count = 0;
                for(Integer i : scoreList){                 
                    count = count + i;                    
                }
                ownerscoreTotalMap.put(str,count);
            }

            for(String str : ownerRegisteredTaskListMap.keySet()){
                List<Integer> taskRegisteredList = ownerRegisteredTaskListMap.get(str);
                Integer count = 0;
                for(Integer i : taskRegisteredList){                
                    count = count + i;                    
                }
                ownerRegisteredTaskTotalMap.put(str,count);
            }

            Map<Id, AggregatedScore> mappedScores = new Map<Id, AggregatedScore>();
            for (AggregateResult ats : aggregatedTaskScores){
                Id userId = (Id)ats.get('OwnerId');
                date d = (date)ats.get('ActivityDate');
                String accId = (String)ats.get('WhatID');
                String conId = (String)ats.get('WhoId');            
                mappedScores.put(userId,
                                 new AggregatedScore(ownerscoreTotalMap.get(userId),ownerRegisteredTaskTotalMap.get(userId))
                                );                  
            }
            
            for (Yearly_Performance_Score__c yps : yearlyPerformances){
                if (mappedScores.get(yps.User_Performance__r.User__c) != null){
                    yps.Tasks_Score__c = mappedScores.get(yps.User_Performance__r.User__c).TotalScore;
                    yps.Tasks_Registered__c = mappedScores.get(yps.User_Performance__r.User__c).TotalActions;
                }
            }
            update yearlyPerformances;
        }
    }
    
    private static Set<Id> getCygateTasksUserIds(List<Task> newList){
        Set<Id> userIds = new Set<Id>();        
        for(Task t : newList){
            if(isCygateTask(t)){
                userIds.add(t.OwnerId);
            }           
        }
        return userIds;
    }  
    
    // This method is used to define if the Event should be considered as a Cygate Task
    // Currently the definition for this is:
    // 1) Task has 'Cygate Task' record type
    // 2) Task has points > 0
    
    public static Boolean isCygateTask(Task t){
        if(t.RecordtypeId != null && SEUtility.getRecordTypeDevName(t.RecordtypeId) == SEUtility.TASK_REC_TYPE_CYGATE){
            return (t.Points__c != null && t.Points__c > 0);
        }
        return false;
    }
    
    //This method will check the Sambesök on Event when Cytgate User in added as a Related To 'Contact'
    public static void checkSambesokForEvent(List<Event> newList){
        
        Set<Id> eventWhoIds = new Set<Id>();
        List<Event> eventList = new List<Event>();
        List<Event> finalUpdateEventList = new List<Event>();
        //Set<String> cygateRoleSet = new Set<String>();
        
        //custom metadata to get all the roles for which sambesok checkbox will get checked
       //  for(Roles_for_Sambesok_checkbox_c__mdt roles: Roles_for_Sambesok_checkbox_c__mdt.getAll().values()){
       //     cygateRoleSet.add(roles.Role_Name__c);
       // } 
        
        //SALEF-1897
        List <Roles_for_Sambesok_checkbox_c__mdt> custMeta =[select id,Role_Name__c from Roles_for_Sambesok_checkbox_c__mdt];
        List<String> cygateRoleSet = new List<String>();
       
        for (Roles_for_Sambesok_checkbox_c__mdt roles : custMeta )
        {
            cygateRoleSet.add(roles.Role_Name__c);
        }
        
        //SALEF-1897
        List <Titles_for_Sambesok_Cygate_kontakt__mdt> titleCustMeta =[select id,Title__c from Titles_for_Sambesok_Cygate_kontakt__mdt];
        List<String> cygateTitleSet = new List<String>();
       
        for (Titles_for_Sambesok_Cygate_kontakt__mdt titles : titleCustMeta )
        {
            cygateTitleSet.add(titles.Title__c);
        }
        
        

        
        if(runTrigger == true){ // to prevent recursion
            runTrigger = false;
            eventList = [SELECT Id, Subject, Who.Type, Execute_trigger__c, (SELECT RelationId,Relation.Type,Relation.Name FROM EventRelations WHERE Relation.Type = 'contact') FROM Event WHERE Execute_trigger__c =true AND Id in : newList];

            for(Event e : eventList){
                for(EventRelation ewr : e.EventRelations){ 
                    eventWhoIds.add(ewr.RelationId);                  
                }
            }

           /* Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Id, Name FROM Contact WHERE Id in : eventWhoIds 
                AND (
                        (Contact.Account.Org_Nr__c = :label.Account_Org_N AND 
                            (Contact.Cygate_User__r.UserRole.Name = 'CG:Partner Account Manager' OR  
                             Contact.Cygate_User__r.UserRole.Name = 'CG:Hybrid IT & Cloud Solution Sales' OR 
                             Contact.Cygate_User__r.UserRole.Name = 'CG:Infrastruktur Specialistsälj' OR 
                             Contact.Cygate_User__r.UserRole.Name = 'CG:Service Presale & Business Support Chef' OR
                             Contact.Cygate_User__r.UserRole.Name = 'CG:Service Presale')AND Contact.Title != 'TestTitle') 
                        OR
                            Contact.Account.Org_Nr__c = :label.Account_Org_Nr_Telia 
                        OR
                           (Contact.Account.Is_Cygate_Supplier__c = true AND contact.Account.Supplier_Specification__c =: 'Strategisk partner'))]);                       
             */
              
              
              Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Id, Name FROM Contact WHERE Id in : eventWhoIds 
                AND (
                        (Contact.Account.Org_Nr__c = :label.Account_Org_N AND 
                        Contact.Cygate_User__r.UserRole.Name IN :cygateRoleSet AND Contact.Title NOT IN :cygateTitleSet)
                        OR
                             Contact.Account.Org_Nr__c = :label.Account_Org_Nr_Telia 
                        OR
                           (Contact.Account.Is_Cygate_Supplier__c = true AND contact.Account.Supplier_Specification__c =: 'Strategisk partner'))]); 
            
            //SALEF-1897
            Map<Id,Contact> conMapForTitle = new Map<Id,Contact>([SELECT Id, Name FROM Contact WHERE Id in : eventWhoIds 
                AND (
                        (Contact.Account.Org_Nr__c = :label.Account_Org_N AND Contact.Title IN :cygateTitleSet ) 
                        OR
                            Contact.Account.Org_Nr__c = :label.Account_Org_Nr_Telia 
                        OR
                           (Contact.Account.Is_Cygate_Supplier__c = true AND contact.Account.Supplier_Specification__c =: 'Strategisk partner'))]); 
            
                
            for(Event e : eventList){
                Event eventRec = new Event(Id = e.Id);
                for(EventRelation ewr : e.EventRelations){
                    if(ewr.relation.type == 'contact' && conMap.containsKey(ewr.RelationId)){   
                        eventRec.Sambes_k__c = true;
                        eventRec.Execute_trigger__c = false;
                        finalUpdateEventList.add(eventRec);
                        break; // break out of the inner for loop to ensure each Event is added only once to the update list
                    }
                    else if(ewr.relation.type == 'contact' && conMapForTitle.containsKey(ewr.RelationId)){   
                        eventRec.Sambes_k_Cygate_kontakt__c = true;
                        eventRec.Execute_trigger__c = false;
                        finalUpdateEventList.add(eventRec);
                        break; // break out of the inner for loop to ensure each Event is added only once to the update list
                    }
                }
            }
            
            update finalUpdateEventList;
        }
    }
    
    //This method will check the Sambesök on Task when Cytgate User in added as a Related To 'Contact'  
    public static void checkSambesokForTask(List<Task> newList){
        
        Set<Id> taskWhoIds = new Set<Id>();
        List<Task> taskList = new List<Task>();
        List<Task> finalUpdateTaskList = new List<Task>();
        
        //SALEF-1897 Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
        List <Roles_for_Sambesok_checkbox_c__mdt> custMeta =[select id,Role_Name__c from Roles_for_Sambesok_checkbox_c__mdt];
        List<String> cygateRoleSet = new List<String>();
       
        for (Roles_for_Sambesok_checkbox_c__mdt roles : custMeta )
        {
            cygateRoleSet.add(roles.Role_Name__c);
        }
        
        //SALEF-1897 Leaderboard - Sambesök logic - edit the code for Sambesök logic and points
        List <Titles_for_Sambesok_Cygate_kontakt__mdt> titleCustMeta =[select id,Title__c from Titles_for_Sambesok_Cygate_kontakt__mdt];
        List<String> cygateTitleSet = new List<String>();
       
        for (Titles_for_Sambesok_Cygate_kontakt__mdt titles : titleCustMeta )
        {
            cygateTitleSet.add(titles.Title__c);
        }
        
        
        if(runTrigger == true){ // to prevent recursion
            runTrigger = false;
            taskList = [SELECT Id, Subject, Who.Type, Execute_trigger__c, (SELECT RelationId,Relation.Type,Relation.Name FROM TaskRelations WHERE Relation.Type = 'contact') FROM Task WHERE Execute_trigger__c =true AND Id in : newList];

            for(Task t : taskList){
                for(TaskRelation twr : t.TaskRelations){ 
                    taskWhoIds.add(twr.RelationId);                  
                }
            }

            Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Id, Name FROM Contact WHERE Id in : taskWhoIds 
                AND (
                        (Contact.Account.Org_Nr__c = :label.Account_Org_N AND 
                        Contact.Cygate_User__r.UserRole.Name IN :cygateRoleSet AND Contact.Title NOT IN :cygateTitleSet) 
                        OR
                            Contact.Account.Org_Nr__c = :label.Account_Org_Nr_Telia 
                        OR
                            (Contact.Account.Is_Cygate_Supplier__c = true AND contact.Account.Supplier_Specification__c =: 'Strategisk partner'))]);                       
                
            
            //SALEF-1897
            Map<Id,Contact> conMapForTitle = new Map<Id,Contact>([SELECT Id, Name FROM Contact WHERE Id in : taskWhoIds 
                AND (
                        (Contact.Account.Org_Nr__c = :label.Account_Org_N AND Contact.Title IN :cygateTitleSet) 
                        OR
                            Contact.Account.Org_Nr__c = :label.Account_Org_Nr_Telia 
                        OR
                           (Contact.Account.Is_Cygate_Supplier__c = true AND contact.Account.Supplier_Specification__c =: 'Strategisk partner'))]); 
                       
            
            
            for(Task t : taskList){
                Task taskRec = new Task(Id = t.Id);
                for(TaskRelation twr : t.TaskRelations){
                    if(twr.relation.type == 'contact' && conMap.containsKey(twr.RelationId)){   
                        taskRec.Sambes_k__c = true;
                        taskRec.Execute_trigger__c = false;
                        finalUpdateTaskList.add(taskRec);
                        break; // break out of the inner for loop to ensure each Task is added only once to the update list
                    }
                    else if(twr.relation.type == 'contact' && conMapForTitle.containsKey(twr.RelationId)){   
                        taskRec.Sambes_k_Cygate_kontakt__c = true;
                        taskRec.Execute_trigger__c = false;
                        finalUpdateTaskList.add(taskRec);
                        break; // break out of the inner for loop to ensure each Event is added only once to the update list
                    }
                }
            }
            
            update finalUpdateTaskList;
        }
    }
    
}