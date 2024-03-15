/**
About
-----
Description: LeaderboardVFController contains methods for the Leaderboard Visualforce Page
Create date: 23.02.2016

Update History
--------------
Created Feb 2016 - V.M Created the initial methods and logic of the LeaderboardVFController class
Updated Sep 2018 - Y.K SALEF-1478 Add a date stamp on Leaderboard - Resultat tab
Updated Oct 2018 - Y.K SALEF-1520 Checkbox on user level - Split Cygate preformance uer checkbox
Updated Jan 2019 - Y.K SALEF-1852 Leaderboard - Resultat tab- added method for prev. year resultat
Updated Feb 2019 - Y.K SALEF-1886 Leaderboard data in alphabetic order, first name level


*/

public class LeaderboardVFController {
    public String selectedTab { get; set;}
    
    public List<Yearly_Performance_Score__c> scores { get; set; }
    public List<Yearly_Performance_Score__c> results { get; set; }
    public List<Quarterly_Performance_Score__c> q1 { get; set; }
    public List<Quarterly_Performance_Score__c> q2 { get; set; }
    public List<Quarterly_Performance_Score__c> q3 { get; set; }
    public List<Quarterly_Performance_Score__c> q4 { get; set; }
    public List<Quarterly_Performance_Score__c> allQ {get; set;}   
    public List<Yearly_Performance_Score__c> PYscores { get; set; }
    public List<Yearly_Performance_Score__c> PYresults { get; set; }
    //For SALEF-1880
    public List<Quarterly_Performance_Score__c> PYallQ {get; set;}
     public List<Quarterly_Performance_Score__c> PYq1 { get; set; }
    public List<Quarterly_Performance_Score__c> PYq2 { get; set; }
    public List<Quarterly_Performance_Score__c> PYq3 { get; set; }
    public List<Quarterly_Performance_Score__c> PYq4 { get; set; }
    
    public List<Yearly_Performance_Score__c> getScores(){
        return [SELECT Total_Score__c, Cygate_Sales_Team__c, User_Performance__r.User__r.Name, User_Performance__r.User__r.SmallPhotoUrl,Befintlig_kund__c,Ny_Kund__c,Befintlig_Kund_Ny_Kontakt__c,Bredda_Aff_ren__c,V_xa_Befintlig_Aff_r__c,ka_Avtalad_Aff_r__c,Sambes_k__c,Esambes_k__c,Total_Points__c      
                FROM Yearly_Performance_Score__c 
                WHERE Name =:String.valueOf(PerformanceUtils.CURRENT_YEAR) AND Total_Score__c != null AND User_Performance__r.User__r.Cygate_Performance_User__c = true AND User_Performance__r.User__r.Show_Score_on_Leaderboard__c = true
                ORDER BY Total_Score__c DESC , User_Performance__r.User__r.Name ];
    }
    
    public List<Quarterly_Performance_Score__c> getallQ(){
        return [SELECT Id,Yearly_Performance_Score__c,Name,Yearly_Performance_Score__r.Cygate_Sales_Team__c, User_Performance__r.User__r.Name,User_Performance__r.User__r.SmallPhotoUrl,Total_Score__c,Befintlig_Kund__c ,Befintlig_Kund_Ny_Kontakt__c,Ny_Kund__c,Bredda_Aff_ren__c,V_xa_Befintlig_Aff_r__c,ka_Avtalad_Aff_r__c,Sambes_k__c,Esambes_k__c,Total_Points__c    
                FROM Quarterly_Performance_Score__c 
                WHERE Yearly_Performance_Score__r.Name =:String.valueOf(PerformanceUtils.CURRENT_YEAR) AND User_Performance__r.User__r.Cygate_Performance_User__c = true AND User_Performance__r.User__r.Show_Score_on_Leaderboard__c = true ORDER BY Total_Points__c DESC , User_Performance__r.User__r.Name];
    }
    public List<Yearly_Performance_Score__c> getResults(){
        return [SELECT Result__c,  Cygate_Sales_Team__c, User_Performance__r.User__r.Name, User_Performance__r.User__r.SmallPhotoUrl, Resultat_Update_Date__c
                FROM Yearly_Performance_Score__c 
                WHERE Name =:String.valueOf(PerformanceUtils.CURRENT_YEAR) AND Result__c != null AND User_Performance__r.User__r.Cygate_Performance_User__c = true AND User_Performance__r.User__r.Show_Result_on_Leaderboard__c = true
                ORDER BY Result__c DESC , User_Performance__r.User__r.Name];
    }
       
    public List<Yearly_Performance_Score__c> getPYscores(){
        return [SELECT Total_Score__c, Cygate_Sales_Team__c, User_Performance__r.User__r.Name, User_Performance__r.User__r.SmallPhotoUrl,Befintlig_kund__c,Ny_Kund__c,Befintlig_Kund_Ny_Kontakt__c,Bredda_Aff_ren__c,V_xa_Befintlig_Aff_r__c,ka_Avtalad_Aff_r__c,Sambes_k__c,Esambes_k__c,Total_Points__c      
                FROM Yearly_Performance_Score__c 
                WHERE Name =:String.valueOf(PerformanceUtils.PREVIOUS_YEAR) AND Total_Score__c != null AND User_Performance__r.User__r.Cygate_Performance_User__c = true AND User_Performance__r.User__r.Show_Score_on_Leaderboard__c = true
                ORDER BY Total_Score__c DESC , User_Performance__r.User__r.Name];
    } 
    
    public List<Yearly_Performance_Score__c> getPYResult(){
        return [SELECT Result__c,  Cygate_Sales_Team__c, User_Performance__r.User__r.Name, User_Performance__r.User__r.SmallPhotoUrl, Resultat_Update_Date__c
                FROM Yearly_Performance_Score__c 
                WHERE Name =:String.valueOf(PerformanceUtils.PREVIOUS_YEAR) AND Result__c != null AND User_Performance__r.User__r.Cygate_Performance_User__c = true AND User_Performance__r.User__r.Show_Result_on_Leaderboard__c = true
                ORDER BY Result__c DESC , User_Performance__r.User__r.Name];
    }
    
     //SALEF-1880 
     public List<Quarterly_Performance_Score__c> getAllPYQ(){
        return [SELECT Id,Yearly_Performance_Score__c,Name,Yearly_Performance_Score__r.Cygate_Sales_Team__c, User_Performance__r.User__r.Name,User_Performance__r.User__r.SmallPhotoUrl,Total_Score__c,Befintlig_Kund__c ,Befintlig_Kund_Ny_Kontakt__c,Ny_Kund__c,Bredda_Aff_ren__c,V_xa_Befintlig_Aff_r__c,ka_Avtalad_Aff_r__c,Sambes_k__c,Esambes_k__c,Total_Points__c    
                FROM Quarterly_Performance_Score__c 
                WHERE Yearly_Performance_Score__r.Name =:String.valueOf(PerformanceUtils.PREVIOUS_YEAR) AND User_Performance__r.User__r.Cygate_Performance_User__c = true AND User_Performance__r.User__r.Show_Score_on_Leaderboard__c = true ORDER BY Total_Points__c DESC];
    }  
    public LeaderboardVFController(){
        scores = getScores();
        results = getResults();
        PYscores = getPYscores();
        PYresults = getPYResult();   
        
        q1 = new List<Quarterly_Performance_Score__c>();
        q2 = new List<Quarterly_Performance_Score__c>();
        q3 = new List<Quarterly_Performance_Score__c>();
        q4 = new List<Quarterly_Performance_Score__c>();
        allQ = getallQ();
        
        for(Quarterly_Performance_Score__c q:allQ){
            system.debug(q.Name + 'here i am' + q);
            if(q.Name == 'Q1'){
                q1.add(q);
            }
            else if(q.Name == 'Q2'){
                q2.add(q);
            }
            else if(q.Name == 'Q3'){
                q3.add(q);
            }
            else if(q.Name == 'Q4'){
                q4.add(q);
            }
        }
        
        //For SALEF-1880
        PYq1 = new List<Quarterly_Performance_Score__c>();
        PYq2 = new List<Quarterly_Performance_Score__c>();
        PYq3 = new List<Quarterly_Performance_Score__c>();
        PYq4 = new List<Quarterly_Performance_Score__c>();
        PYallQ = getAllPYQ();
        
        
        for(Quarterly_Performance_Score__c PYq:PYallQ){
            system.debug(PYq.Name + 'here i am' + PYq);
            if(PYq.Name == 'Q1'){
                PYq1.add(PYq);
            }
            else if(PYq.Name == 'Q2'){
                PYq2.add(PYq);
            }
            else if(PYq.Name == 'Q3'){
                PYq3.add(PYq);
            }
            else if(PYq.Name == 'Q4'){
                PYq4.add(PYq);
            }
        }
     
        selectedTab = 'result';
    }   
}