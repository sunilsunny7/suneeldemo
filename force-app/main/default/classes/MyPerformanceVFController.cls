/**
 * About
 * -----
 * Description: MyPerformanceVFController contains methods for the MyPerformance Visualforce Page
 * Create date: 23.02.2016
 * Update History
 * --------------
 * 12.12.2022 [Tomass Brazovskis] SALEF-7206 - Deleted getYearlyCompetenceScore() method, which was using Almond package Custom Object records to 
 *              calculate 'monthlyCompetenceScoreContact' property (also removed). Required to enable removal of the Almond package.
 * Created Feb 2016 - V.M Created the initial methods and logic of the MyPerformanceVFController class
 **/

public class MyPerformanceVFController {
    public String chartId { get; set;}
    public String selectedTab { get; set;}
    public String monthlyContributionScore { get; set;}
    public String monthlyTargetAttended { get; set; }
    public Yearly_Performance_Score__c yps { get; set;}
    public User currentUser { get; set; }
    public Boolean hasYps { get; set; }
    
    
    //We form the data for 
    class Dataset{   
        public List<Integer> data { get; set;}
        public String label { get; set; }
        public String type { get; set; }
        public String backgroundColor { get; set;}
        
        public Dataset(List<Integer> data, String label, String type){
            this.data = data;
            this.label = label;
            this.type = type;      
        }
    }
    
    /**@Description:
	 * MyPerformance VF Page custom controller constructor.
     * Modifications:
     *  12.12.2022 [TB] SALEF-7206 - Modified. Removed the 'monthlyCompetenceScoreContact' property 
     *              and the method used to calculate it.
     **/
    public MyPerformanceVFController(){        
        //get ypsId from URL Parameter
        String ypsId = ApexPages.currentPage().getParameters().get('ypsId');        
        yps = getYps(ypsId);
        selectedTab = 'year';
        
        //If it's null we use the logged in user yps, and if that is null we use the logged users info for the header
        if(yps != null){
            hasYps = true;
            currentUser = yps.User_Performance__r.User__r;
            monthlyContributionScore = getYearlyContributionScore(yps.User_Performance__r.User__r.Id, 'line');
            monthlyTargetAttended = getContributionMonthlyTargets(yps.User_Performance__r.User__r.Id,  yps.Id);
        }else{
             hasYps = false;
            currentUser = [SELECT SmallPhotoUrl, Email, Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
        }     
    }
    
    
    public  Yearly_Performance_Score__c getYps(String ypsId){
        List<Yearly_Performance_Score__c> currentYps;
        String currentYear = String.valueOf(Datetime.now().year());
        System.debug(ypsId);
        if(!String.isBlank(ypsId) || ypsId != null){            
            currentYps = [SELECT Id, Competence_Milestone__c, Contribution_Milestone__c, Result__c, User_Performance__r.User__r.Id, Competence_Score__c,
                          Client_Meetings_Target__c, Client_Meetings_Registered__c, Competence_Events_Attended__c, Competence_Events_Target__c, 
                          Total_Contribution_Score__c, Total_Client_Meetings_Registered__c,
                          User_Performance__r.User__r.SmallPhotoUrl,  User_Performance__r.User__r.Email, User_Performance__r.User__r.Name
                          FROM Yearly_Performance_Score__c 
                          WHERE Id = :ypsId];
            
            if(currentYps.size() > 0){
                return currentYps[0];
            }                        
        }
        
        currentYps = [SELECT Id, Competence_Milestone__c, Contribution_Milestone__c, 
                      Result__c, User_Performance__r.User__r.Id, User_Performance__r.User__r.SmallPhotoUrl, Competence_Score__c,
                      Client_Meetings_Target__c, Client_Meetings_Registered__c, Competence_Events_Attended__c, Competence_Events_Target__c, 
                      Total_Contribution_Score__c, Total_Client_Meetings_Registered__c,
                      User_Performance__r.User__r.Email, User_Performance__r.User__r.Name
                      FROM Yearly_Performance_Score__c 
                      WHERE User_Performance__r.User__r.Id = :UserInfo.getUserId() 
                      AND Name = :currentYear LIMIT 1];
        if(currentYps.size() > 0){
            return currentYps[0];
        }
        
        return null;
    }
    
    private  static String getYearlyContributionScore(String userId, String type){
        AggregateResult[] contributionEventScores = [SELECT SUM(Points__c) points, calendar_year(EndDateTime) year, calendar_month(EndDateTime) month
                                                     FROM Event
                                                     WHERE Event_Complete__c = true
                                                     AND Legacy_Activity__c = false
                                                     AND Owner.Id = :userId
                                                     GROUP BY calendar_year(EndDateTime), calendar_month(EndDateTime) 
                                                     ORDER BY calendar_year(EndDateTime)];
        
        
        System.debug(contributionEventScores);
        AggregateResult[] contributionTaskScores = [SELECT SUM(Points__c) points, calendar_year(TaskEndDate__c) year, calendar_month(TaskEndDate__c) month
                                                    FROM Task
                                                    WHERE Status = 'Stängd'
                                                    AND Legacy_Activity__c = false
                                                    AND Owner.Id = :userId
                                                    GROUP BY calendar_year(TaskEndDate__c), calendar_month(TaskEndDate__c) 
                                                    ORDER BY calendar_year(TaskEndDate__c)];
        System.debug(contributionTaskScores);
        Map<Integer, Map<Integer, Integer>> contributionMap = mapYearlyScore(contributionEventScores);
        Map<Integer, Map<Integer, Integer>> taskMap = mapYearlyScore(contributionTaskScores);
        
        //Merge task and event points
        for(Integer taskYear : taskMap.keySet()){
            if(contributionMap.containsKey(taskYear)){
                for(Integer taskMonth : taskMap.get(taskYear).keySet()){
                    Integer totalSum = contributionMap.get(taskYear).get(taskMonth) + taskMap.get(taskYear).get(taskMonth);
                    contributionMap.get(taskYear).put(taskMonth, totalSum);
                }
            }else{
                contributionMap.put(taskYear, taskMap.get(taskYear));
            }
        }
        
        List<Dataset> dsList = new List<Dataset>();
        for(Integer year : contributionMap.keySet()){
            Dataset ds = new Dataset(contributionMap.get(year).values(), String.valueOf(year), type);
                  ds.backgroundColor = 'rgba(107,35,131,0.7)';
            dsList.add(ds);
        }
        
        System.debug(dsList);
        return Json.serialize(dsList);    
    }
    
    private  static String getContributionMonthlyTargets(String userId, String ypsId){
        AggregateResult[] eventsCompleted = [SELECT COUNT(Id) points, calendar_month(EndDateTime) month
                                             FROM Event
                                             WHERE Event_Complete__c = true
                                             AND Legacy_Activity__c = false
                                             AND Owner.Id = :userId
                                             AND calendar_year(EndDateTime) = :System.Today().year()
                                             GROUP BY calendar_month(EndDateTime) 
                                             ORDER BY calendar_month(EndDateTime)];
        
        AggregateResult[] tasksCompleted = [SELECT COUNT(Id) points, calendar_month(TaskEndDate__c) month
                                            FROM Task
                                            WHERE Status = 'Stängd'
                                            AND Legacy_Activity__c = false
                                            AND Owner.Id = :userId
                                            AND calendar_year(TaskEndDate__c) = :System.Today().year()
                                            GROUP BY calendar_month(TaskEndDate__c) 
                                            ORDER BY calendar_month(TaskEndDate__c)];
        
        Map<Integer, Integer> contributionMap = mapMonthlyTarget(eventsCompleted);
        Map<Integer, Integer> taskMap = mapMonthlyTarget(tasksCompleted);
        
        //Merge task and event points
        for(Integer taskMonth : taskMap.keySet()){
            if(contributionMap.containsKey(taskMonth)){
                Integer totalSum = contributionMap.get(taskMonth) + taskMap.get(taskMonth);
                contributionMap.put(taskMonth, totalSum);
                
            }else{
                contributionMap.put(taskMonth, taskMap.get(taskMonth));
            }
        } 
        List<Monthly_Performance_Score__c> contributionTargets = [SELECT Client_Meetings_Target__c
                                                                  FROM Monthly_Performance_Score__c
                                                                  WHERE Yearly_Performance_Score__c = :ypsId 
                                                                  ORDER BY Name];
        List<Integer> targets = new List<Integer>();
        for(Monthly_Performance_Score__c cmt : contributionTargets){
            targets.add(Integer.valueOf(cmt.Client_Meetings_Target__c));
        }
        List<Dataset> dsList = new List<Dataset>();
        
        Dataset ds1 = new Dataset(contributionMap.values(), 'Attended', 'bar');
        dsList.add(ds1);
        Dataset ds2 = new Dataset(targets, 'Target', 'line');
        ds2.backgroundColor = 'rgba(107,35,131,0)';
        dsList.add(ds2);            
        return Json.serialize(dsList); 
    }
    
    
    //Map for contributionMonthlyTarget logic
    private static Map<Integer, Map<Integer, Integer>> mapYearlyScore(AggregateResult[] score){   
        // Year,         Month,   Score
        Map<Integer, Map<Integer, Integer>>  yearMap = new Map<Integer, Map<Integer, Integer>> ();
        
        //Map year, month and scores. 
        for (AggregateResult s : score){
            Integer year = Integer.valueOf(s.get('year'));
            Integer month = Integer.valueOf(s.get('month'));
            Integer points = Integer.valueOf(s.get('points'));
            if(year != Null || month != Null){
                month = month - 1;
                if (yearMap.containsKey(year)){
                    yearMap.get(year).put(month, points);
                } 
                else{
                    Map<Integer, Integer> monthMap = new Map<Integer, Integer>();
                    for(Integer i = 0; i <= 11; i++){
                        monthMap.put(i, 0);
                    }
                    monthMap.put(month, points);
                    yearMap.put(year, monthMap);
                }
            }
        }
        
        return yearMap;       
    } 
    
    private static Map<Integer, Integer> mapMonthlyTarget(AggregateResult[] score){   
        //  Month,   Score    
        Map<Integer, Integer>  monthlyMap = new Map<Integer, Integer> ();
        
        for (AggregateResult s : score){
            Integer month = Integer.valueOf(s.get('month'));
            Integer points = Integer.valueOf(s.get('points'));
            if(month != Null){
                month = month - 1;
                monthlyMap.put(month, points);                
            }
        }
        
        return monthlyMap;       
    }
}