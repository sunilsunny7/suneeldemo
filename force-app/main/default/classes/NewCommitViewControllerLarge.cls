/**
    About
    -----
    Description: NewCommitViewControllerLarge on Account
    Create date: 02.08-2016

    Update History
    --------------
    Feb 2016 - N-G Created
    --- Update history Missing ---
    Jun 2016 - A.N Smaller changes and general improvments to the class
    Jun 2016 - A.N Changed the method getQuarter: Instead of returning querter for todays date, returns the quarter for next week (Bug fix for Case-1715)
    Dec 2016 - S.S : Added the condition to display commit view of temporary sales manager & manage two team manager (Case 1364 & 1466)
    Feb 2017 - A.N Case-2306 Added Temp Manager functionality. Refactored and deleted unneccessary code/methods.
    11.04.2023 [Tomass Brazovskis] SALEF-7649 - Added the filters, already introduced for CommitViewController by SAEN-1124 
                in 02.2016 by A.N, to only save commits for WFIs related to the current User's active Seller.
*/

public class NewCommitViewControllerLarge {

    //User variables
    public String typeOfUser{get;set;}  
    private Id currentUserId;
    private Id runningUserId;
    private Id secondaryUserId;
        
    private String selectedYear;
    private String selectedQuarter;
    private String selectedWeek;
    
    public String status{get;set;}
    public String targets{set;}
    public transient String weekInstances{set;}

    //Temporary Manager parameters
    public List<SelectOption> pageLoadOptions{get;set;}
    public String radioValue{get;set;}

    public NewCommitViewControllerLarge(){
        System.debug('Running constructor NewCommitViewControllerLarge');
        runningUserId = UserInfo.getUserId();
        currentUserId = runningUserId;

        Seller__c seller = [SELECT Id, User__c, Is_Temporary_Manager__c, Replaced_Manager_Lookup__r.User__c, Replaced_Manager_Lookup__r.Seller_Name__c, Replaced_Manager_Lookup__c, Manage_Other_Team__c FROM Seller__c WHERE User__c =: runningUserId AND Start_Date__c <= : Date.today() AND (End_Date__c >= : Date.today() OR End_Date__c = null) limit 1];      
        // If the Seller is the Temporary Manager of a Sales Team, the User can switch his view between "Self view" and "Team View"
        if(seller.Is_Temporary_Manager__c){
            secondaryUserId = seller.Replaced_Manager_Lookup__r.User__c;
            currentUserId = seller.Replaced_Manager_Lookup__r.User__c;
            radioValue = 'SecondaryUserView';
            pageLoadOptions = createPageOptions(seller.Replaced_Manager_Lookup__r.Seller_Name__c + ' ' + Label.Commit_Replaced_Manager_View);
        // If the Seller is the Manager of a Secondary Sales Team, the User can switch his view between "My Team View" and "Secondary Team View"
        } else if(!String.isBlank(seller.Manage_Other_Team__c)){
            List<Seller__c> otherManager = [SELECT Id, User__c FROM Seller__c WHERE Sales_Team_Name__c = :seller.Manage_Other_Team__c AND Type__c = :SellerTriggerHandler.SELLER_TYPE_SALES_TEAM_MGR AND Start_Date__c <= : Date.today() AND (End_Date__c >= : Date.today() OR End_Date__c = null) limit 1];
            if(!otherManager.isEmpty()){
                secondaryUserId = otherManager[0].User__c;
                radioValue = 'RunningUserView';
                pageLoadOptions = createPageOptions(seller.Manage_Other_Team__c + ' ' + Label.Commit_Replaced_Manager_View);
            }
        }

        typeOfUser = getTypeOfUser();
        selectedYear = String.valueof(System.Today().year());
        selectedQuarter = String.valueOf(SEUtility.getQuarterNrFromWeek(SEUtility.getWeekNumber(System.today()) + 1));
        selectedWeek = getNextWeek();

        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }
    
    public String getTypeOfUser(){
        List<Seller__c> sellers = [ SELECT Type__c, Start_Date__c 
                                    FROM Seller__c
                                    WHERE User__c = :currentUserId
                                    AND Start_Date__c <= :Date.today()
                                    AND (   End_Date__c >= :Date.today()
                                            OR End_Date__c = null)
        ];
        return (sellers.isEmpty() ? null : sellers[0].Type__c);
    }

    // Get weekNo (for next week) as String
    private String getNextWeek(){          
        String weekNo = String.valueof(SEUtility.getWeekNumber(System.today()) + 1);
        return (weekNo.length() == 1 ? '0'+weekNo : weekNo);
    }

    private List<SelectOption> createPageOptions(String optionString){
         List<SelectOption> selectOpt = new List<SelectOption>();
            selectOpt.add(new SelectOption('SecondaryUserView', optionString));
            selectOpt.add(new SelectOption('RunningUserView', Label.Commit_Self_View));
        return selectOpt;
    }
    
    //Method that creates week instances for the selected quarter. 
    //The weekinstances are returned as a JSON string
    public String getWeekInstances(){
        System.debug('Get weekInstances method starts');
        if(radioValue != null){
          if(radioValue == 'SecondaryUserView') currentUserId = secondaryUserId;
          else if(radioValue == 'RunningUserView') currentUserId = runningUserId;
          System.debug('Get weekInstances for user id: ' + currentUserId);      
        }
        
        List<Week> weekInstancesList = new List<Week>();
        Map<String,List<Week>> weekMap = new Map<String,List<Week>>();
        List<Weekly_Forecast_Item__c> fcItems = new List<Weekly_Forecast_Item__c>();

        // SALEF-7649 - Retrieve current User's current Seller to 
        // later apply SAEN-1124 introduced Filter 2
        Map<Id, Seller__c> mapSellerIdsToSellers = new Map<Id, Seller__c>([ SELECT Id, User__c, Start_Date__c
                                                                            FROM Seller__c
                                                                            WHERE Do_Not_Include_in_Commit_View__c = false
                                                                            AND (   Manager__r.User__c = :currentUserId
                                                                                    OR User__c = :currentUserId)
                                                                            AND Start_Date__c <= :Date.today() 
                                                                            AND (   End_Date__c >= :Date.today() 
                                                                                    OR End_Date__c = null)
        ]);
        Seller__c currentUserSeller;
        for(Seller__c curSeller : mapSellerIdsToSellers.values()){
            if(curSeller.User__c == currentUserId){
                currentUserSeller = curSeller;
                break;
            }
        }
        if(currentUserSeller != null){
            mapSellerIdsToSellers.remove(currentUserSeller.Id);
        }
        Set<Id> sellerIds = mapSellerIdsToSellers.keySet();
     
        //Query Weekly Forecast Items with related Opportunities
        fcItems = [SELECT Id, Name, User__c, Start_Date__c, End_Date__c, Active_Week__c,
                   Seller__c, Sales_Team__c, Sales_Unit__c, Seller__r.Type__c, Seller__r.Seller_Name__c,
                   Seller__r.Business_Unit_Name__c, Seller__r.Business_Area_Name__c,
                   Seller__r.Start_Date__c, Seller__r.End_Date__c,
                   Accumulated_New_Sales_Outcome_X__c, Accumulated_Continuation_Sales_Outcome_X__c,
                   Judge_CS__c, Judge_NS__c, IsWeekInPast__c, New_Sales_Amount_Open_Opps__c, Continuation_Sales_Amount_Open_Opps__c,
                   Commit_New_Sales_Large__c, Commit_Continuation_Sales_Large__c,
                   Outcome_Commit_NS__c, Outcome_Commit_CS__c,
                   Risk_New_Sales__c, Risk_Continuation_Sales__c,
                   Upside_New_Sales__c, Upside_Continuation_Sales__c,
                   Revenue_Impact_This_Year__c,
                   (SELECT Opportunity__c, 
                    Opportunity__r.Name, Opportunity__r.Owner.Name, 
                    Probability__c, Opportunity__r.StageName, 
                    Opportunity__r.CloseDate, Is_Won__c, Is_Closed__c, Risk__c, 
                    Opportunity__r.Account.Name, Opportunity__r.AccountId, 
                    Continuation_Sales_Amount__c, New_Sales_Amount__c,
                    Include_in_Outcome_Commit__c, Revenue_Impact_This_Year__c FROM Forecast_Opportunity_Links__r) 
                FROM Weekly_Forecast_Item__c WHERE (User__c = : currentUserId OR Seller__c IN : sellerIds) AND Quarterly_Forecast_Item__r.Name = :selectedQuarter AND Quarterly_Forecast_Item__r.Yearly_Target__r.Name = :selectedYear AND Name = :selectedWeek ORDER BY Name];
        
        if(!fcItems.isEmpty()){
            //Loop through the weekly forecasting items and create a week instance.  
            for(Weekly_Forecast_Item__c wfi : fcItems){

                // SALEF-7649 - Apply SAEN-1124 introduced filters 
                // Filter 1: Check if the Weekly Forecasting Item parent
                // Seller was active in the week of the forecast
                if( wfi.Seller__r.Start_Date__c > wfi.End_Date__c 
                    || wfi.Seller__r.End_Date__c < wfi.Start_Date__c
                ){
                    continue;
                }
                // Filter 2: If the WFI is related to a current User's subordinate,
                // check if the current User was the subordinate's manager in the forecast week 
                if(wfi.User__c != currentUserId){
                    if(currentUserSeller != null && wfi.End_Date__c < currentUserSeller.Start_Date__c){
                        // Current User's current Seller was not active in the forecast week, 
                        // therfore, the User might not have been the current subordinate's manager in that week.
                        continue;
                    }
                }

                Week w = new Week(wfi, wfi.Seller__r.Seller_Name__c);              
                
                //If the owner is the current user add the item to weekinstancesList, otherwise add item to weekMap.
                if(wfi.User__c == currentUserId){
                    weekInstancesList.add(w);
                } else {
                    w.isChild = true;
                    
                    if(!weekMap.containsKey(wfi.Name)){
                        weekMap.put(wfi.Name,new List<Week>());
                    }
                    weekMap.get(wfi.Name).add(w);
                }
                
                w.title = wfi.Seller__r.Seller_Name__c;
            } 
        }
        
        if(!(weekInstancesList.isEmpty() || weekMap.isEmpty())){
            //Loop through weekInstanceList
            for(Week wInstance : weekInstancesList){
                List<Week> subWeeks = weekMap.get(wInstance.item.Name); //Get all subweeks from weekMap that has the same name as wInstance
                if(!subWeeks.isEmpty()){
                    
                    for(Week subWeek : subWeeks){
                        
                        if( wInstance.item.Sales_Team__c == subWeek.item.Sales_Team__c
                            || (typeOfUser == 'Sales Unit Director' 
                                && wInstance.item.Sales_Unit__c == subWeek.item.Sales_Unit__c)
                            || (typeOfUser == 'Business Unit Manager'
                                && wInstance.item.Seller__r.Business_Unit_Name__c == subWeek.item.Seller__r.Business_Unit_Name__c)
                            || (typeOfUser == 'Business Area Manager'
                                && wInstance.item.Seller__r.Business_Area_Name__c == subWeek.item.Seller__r.Business_Area_Name__c)
                        ){
                            wInstance.subWeeks.add(subWeek); //Add the subweeks to the parent week instance
                        }
                    }
                }    
            }
            
        }
        String JSONstring = JSON.serialize(weekInstancesList);
        return JSONstring;
    }

    public String getTargets(){
        List<Target> t = new List<Target>();
        t.add(new Target(Label.New_Sales));
        t.add(new Target(Label.Continuation_Sales));

        return JSON.serialize(t);
    }

    public PageReference saveJudge(){
      System.debug('Saving Judge/Commit for user ' + currentUserId);

        List<Forecast_Opportunity_Link__c> updateFOLs = new List<Forecast_Opportunity_Link__c>();
        List<Weekly_Forecast_Item__c> weekList = [  SELECT  Id, 
                                                            Seller__c,
                                                            Name, 
                                                            Comitted_on__c,
                                                            (   SELECT Committed_Week__c, Committed_On__c
                                                                FROM Forecast_Opportunity_Links__r) 
                                                    FROM Weekly_Forecast_Item__c
                                                    WHERE User__c = :currentUserId
                                                    AND Quarterly_Forecast_Item__r.Name = :selectedQuarter
                                                    AND Quarterly_Forecast_Item__r.Yearly_Target__r.Name = :selectedYear 
                                                    AND Name = :selectedWeek
                                                    // SALEF-7649 - Ensure the commit is saved only for WFIs related to 
                                                    // the current User's active Seller
                                                    AND Seller__r.End_Date__c >= :Date.today()
                                                    LIMIT 1
        ];

        if(!weekList.isEmpty()){
            Weekly_Forecast_Item__c week = weekList[0];

            week.Comitted_on__c = System.now();
            if(week.Forecast_Opportunity_Links__r != null){
                for(Forecast_Opportunity_Link__c fol : week.Forecast_Opportunity_Links__r){
                    fol.Committed_Week__c = week.Name;
                    fol.Committed_On__c = week.Comitted_on__c;
                    updateFOLs.add(fol);
                }
            }

            try{
                update week;
                update updateFOLs;
            } catch(DmlException e) {
                System.debug('getStackTraceString: ' + e.getStackTraceString());
                System.debug('The following exception has occurred: ' + e.getMessage());
                status = ' Din commit sparades inte. Kontakta din administratör om felet kvartstår';
                return null;
            }
        }

        status = 'Commit Saved';
        return null;
    }

    public class Target{
        public String salesType;
        public Target(String salesType){
            this.salesType = salesType;
        }
    }
    
    public class Week{
        public Weekly_Forecast_Item__c item {get;set;}
        public Boolean isChild {get;set;}
        public String ownerName {get;set;}
        public List<Week> subWeeks {get;set;}
        public String title {get;set;}
        
        public Week(){}
        public Week(Weekly_Forecast_Item__c item, String ownerName){
            this.item = item;
            this.isChild = false;
            this.ownerName = ownerName;
            this.subWeeks = new List<Week>();
        } 
    }      
}