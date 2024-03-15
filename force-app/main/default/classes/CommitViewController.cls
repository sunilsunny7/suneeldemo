/**
    About
    -----
    Description: CommitViewController
    Create date: 05.05-2015

    Update History
    --------------
    Created May 2015 - V.I/T.R/C.G - No previous history for this class until Jan 2016
    Updated Jan 2016 - A.N Added functionality to set the field Commited On in the saveCommit method
    Updated Feb 2016 - A.N Updates to CommitViewController to support if the user has more than one seller record. Following changes has been done:
    - A.N Replaced checkIfUserIsTeamManager/checkIfUserIsTeamManager method with SetUserRole due to bugs in old methods logic (no date filter when selecting active seller)
    - A.N Added two filters to the getWeekInstances method so that only relevant wfi's are displayed in the commit view
    - A.N In the saveCommit method, updated SOQl so it only saves the commit for weeks related to the active seller if more than one seller for the user
*/

public class CommitViewController {
    
    //User variables
    public Boolean userIsManager{get;set;}
    public Boolean userIsSalesUnitManager{get; private set;}
    public Id currentUser = UserInfo.getUserId(); 
    private Seller__c currentSeller;
        
    //Picklist variables
    public String selectedYear{get;set;}
    public String selectedQuarter{get; set{selectedQuarter = value;}}
    public String selectedSalesType{get;set;}
    public List<SelectOption> yearOptions{get;set;}
    public List<SelectOption> quarterOptions{get;set;}
    public List<SelectOption> salesTypes{get;set;}
    
    public String forecastCategories{get;set;}
    public List<String> fCategories = new List<String>();
    public transient String weekInstances{set;}
    public String commitValueString{get;set;}
    public String status{get;set;}

    public CommitViewController(){
        
        onloadofvfpage();
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }
    
    private void onloadofvfpage(){
        setUserRole();
        this.selectedYear = String.valueof(System.Today().year());
        this.selectedQuarter = getCurrentQuarter();
        this.yearOptions = createYearOptions();
        this.quarterOptions = createQuarterOptions();
        this.salesTypes = createSalesTypeOptions();
        this.selectedSalesType = 'NewSales';
        this.forecastCategories = getForecastCategories();
        //this.weekInstances = getWeekInstances();
    }
    
    private void setUserRole(){
        List<Seller__c> s = [Select Id, Type__c, Start_Date__c from Seller__c where User__c = :currentUser and Start_Date__c <= :Date.today() AND End_Date__c >= :Date.today()];
        userIsManager = ( s.isEmpty() ? false : (s[0].Type__c == SellerTriggerHandler.SELLER_TYPE_SALES_TEAM_MGR));
        userIsSalesUnitManager = ( s.isEmpty() ? false : (s[0].Type__c == SellerTriggerHandler.SELLER_TYPE_SALES_UNIT_MGR));
        currentSeller = ( s.isEmpty() ? null : s[0]);
        System.debug('userIsManager ' + userIsManager);
        System.debug('userIsSalesUnitManager ' + userIsSalesUnitManager);
    }

    //Method that returns the current quarter as a string, example 'Q1'
    private String getCurrentQuarter(){
        String quarter;
        List<Period> p = [Select p.Number From Period p Where p.type = 'Quarter' and p.StartDate = THIS_FISCAL_QUARTER Limit 1];
        if(!p.isEmpty()){
            if(p[0].Number != null){
                quarter = 'Q' + String.valueOf(p[0].Number);
            }
        }
        
        return quarter;
    }
    
    //Method that create year options 
    //The options will contain the current year, the two previous years and the two upcoming years. 
    private List<SelectOption> createYearOptions(){
        List<SelectOption> years = new List<SelectOption>();
        Integer currentYear = System.Today().year();
        for(Integer i = currentYear - 2; i <= (currentYear + 2); i++){
            years.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        } 
        return years;
    }
    
    //Method that creates the quarter options
    private List<SelectOption> createQuarterOptions(){
        List<SelectOption> quarters = new List<SelectOption>();
        quarters.add(new SelectOption('Q1','Q1'));
        quarters.add(new SelectOption('Q2','Q2'));
        quarters.add(new SelectOption('Q3','Q3'));
        quarters.add(new SelectOption('Q4','Q4'));
        
        return quarters;
    }

    //Method that creates the sales type options
    private List<SelectOption> createSalesTypeOptions(){
        List<SelectOption> st = new List<SelectOption>();
        st.add(new SelectOption('NewSales','New Sales'));
        st.add(new SelectOption('ContinuousSales','Continuation Sales'));
        
        return st;
    }
    
    //Method that returns the forecast categories as a JSON string
    private String getForecastCategories(){
        List<OpportunityStage> oppStages = new List<OpportunityStage>();
        Set<String> helperSet = new Set<String>(); //Set variable that helps to check whether we already added the forecasting category
        
        oppStages = [SELECT ForecastCategoryName, IsClosed, IsWon, DefaultProbability FROM OpportunityStage where isActive = TRUE ORDER BY DefaultProbability];
        
        if(!oppStages.isEmpty()){
            for(Integer i = 0; i < oppStages.size(); i++){
                //Only add forecast categories which are not "closed or won"
                if(oppStages[i].ForecastCategoryName != null && oppStages[i].IsClosed == false && oppStages[i].IsWon == false){
                    //Check if we added the category before
                    if(!helperSet.contains(oppStages[i].ForecastCategoryName)){
                        helperSet.add(oppStages[i].ForecastCategoryName);
                        fCategories.add(oppStages[i].ForecastCategoryName);
                    }
                }
            }
        }
        String JSONstring = JSON.serialize(fCategories);
        return JSONstring;
    }
    
    //Method that takes a list of Weekly Forecast Items and returns a map between the users' Ids and Names
    public Map<Id,String> createOwnerMap(List<Id> userIds){
        Map<Id,String> idToName = new Map<Id,String>();
        
        //Map UserId's to User Names
        if(!userIds.isEmpty()){
            List<User> userList= [SELECT Id, Name FROM User WHERE Id IN :userIds];
            for (User u : userlist){
                idToName.put(u.Id, u.Name);
            }
        }
        return idToName;  
    }
    
    
    //Method that creates a map between Weekly Forecast Item Id and a list of Weekly Forecast Item History
    public Map<Id,List<Weekly_Forecast_Item__History>> createFieldHistoryMap(String salesType){
        
        Map<Id,List<Weekly_Forecast_Item__History>> wfihMap = new Map<Id,List<Weekly_Forecast_Item__History>>();
        List<Weekly_Forecast_Item__History> wfihs = new List<Weekly_Forecast_Item__History>();
        
        if(salesType == 'NewSales'){
            wfihs = [SELECT Id, ParentId, OldValue, NewValue, Field, CreatedById, CreatedDate FROM Weekly_Forecast_Item__History Where Field = 'New_Sales_Commit__c' ORDER BY CreatedDate DESC];
        }
        else{
            wfihs = [SELECT Id, ParentId, OldValue, NewValue, Field, CreatedById, CreatedDate FROM Weekly_Forecast_Item__History Where Field = 'Continuation_Sales_Commit__c' ORDER BY CreatedDate DESC];
            
        }
        
        if(!wfihs.isEmpty()){
            for(Weekly_Forecast_Item__History wfih:wfihs){
                if(!wfihMap.containsKey(wfih.ParentId)){
                    wfihMap.put(wfih.ParentId, new List<Weekly_Forecast_Item__History>());
                }
                wfihMap.get(wfih.ParentId).add(wfih);
            }
        }
        return wfihMap;
    }
    
    //Method that creates week instances for the selected quarter. 
    //The weekinstances are returned as a JSON string
    public String getWeekInstances(){
        System.debug('Get weekInstances method starts');
        
        //Remove Q from selected quarter
        String q = selectedQuarter.removeStart('Q');
        
        List<Week> weekInstancesList = new List<Week>();
        Map<String,List<Week>> weekMap = new Map<String,List<Week>>();
        List<Weekly_Forecast_Item__c> fcItems = new List<Weekly_Forecast_Item__c>();
        
        //Add current user to teamIds
        List<Id> teamIds = new List<Id>();
        teamIds.add(currentUser);
        
        List<Id> sellerIds = new List<Id>();
        
        if(userIsManager || userIsSalesUnitManager){
            List<Seller__c> sellers = [Select Id, User__c from Seller__c where Manager__r.User__c = :currentUser];
            //If user is a manager and has a team: add the team to teamIds
            if(!sellers.isEmpty()){
                for(Seller__c s: sellers){
                    teamIds.add(s.User__c);
                    sellerIds.add(s.Id);
                }
            }
        }
        System.debug('SellerIds: ' + sellerIds);
     
        //Query Weekly Forecast Items with related Opportunities
        if(!fCategories.isEmpty()){
            fcItems = [SELECT Id, Name, User__c, Start_Date__c, End_Date__c, Active_Week__c,
                       Seller__c, Seller__r.Type__c, Seller__r.Start_Date__c, Seller__r.End_Date__c,
                       New_Sales_Target__c, Continuation_Sales_Target__c, Sales_Team__c, Sales_Unit__c,
                       Accumulated_New_Sales_Outcome_X__c, Accumulated_Continuation_Sales_Outcome_X__c,
                       Continuation_Sales_Commit__c, New_Sales_Commit__c,
                       Subordinates_Commit_New_Sales__c, Subordinates_Commit_Continuation_Sales__c,
                       Quarterly_Forecast_Item__r.Goal_Achievement_New_Sales__c,
                       Quarterly_Forecast_Item__r.Yearly_Target__r.Goal_Achievement_New_Sales__c,
                       Quarterly_Forecast_Item__r.Goal_Achievement_Continuation_Sales__c,
                       Quarterly_Forecast_Item__r.Yearly_Target__r.Goal_Achievement_Continuation_Sales__c,
                       Direct_Sales_Outcome__c,
                       (SELECT Opportunity__c, 
                        Opportunity__r.Name, Opportunity__r.Owner.Name, 
                        Probability__c, Opportunity__r.StageName, 
                        Opportunity__r.CloseDate, Is_Won__c, 
                        Opportunity__r.Account.Name, Opportunity__r.AccountId, 
                        New_Sales_Amount__c, Continuation_Sales_Amount__c, 
                        Opportunity__r.ForecastCategoryName FROM Forecast_Opportunity_Links__r WHERE Opportunity__r.ForecastCategoryName IN : fCategories OR Is_Won__c = true) 
                       FROM Weekly_Forecast_Item__c WHERE (User__c = : currentUser OR Seller__c IN : sellerIds) AND Quarterly_Forecast_Item__r.Name = :q AND Quarterly_Forecast_Item__r.Yearly_Target__r.Name = :selectedYear ORDER BY Name];
        }
        
        //Create User Id to User Name Map & User ID
        Map<Id,String> ownerMap = createOwnerMap(teamIds);

        //Create FieldHistory Maps
        Map<Id,List<Weekly_Forecast_Item__History>> historyMapNS = createFieldHistoryMap('NewSales');
        Map<Id,List<Weekly_Forecast_Item__History>> historyMapCS = createFieldHistoryMap('ContinuousSales');
        
        System.debug('Steg 1');
        if(!fcItems.isEmpty()){
            //Loop through the weekly forecasting items and create a week instance.  
            for(Weekly_Forecast_Item__c wfi : fcItems){
                // Check if the seller related to the weekly forecasting item was active in that week.
                if(wfi.Seller__r.Start_Date__c > wfi.End_Date__c || wfi.Seller__r.End_Date__c < wfi.Start_Date__c){
                    //System.debug('Skipping this wfi ' + wfi);
                    continue;
                }
                // Filter 2:
                // Check if wfi user is not the current user but a subordinate.
                if(wfi.User__c != currentUser){
                    // If subordinate, check if the current user was active as this subordinates manager at the time
                    if(currentSeller != null && wfi.End_Date__c < currentSeller.Start_Date__c){
                        // The users current seller was not active this week, and therfore the user was not the manager for this subordinate for this week.
                        System.debug('Skipping this subordinates wfi as the users current seller was not active this week: ' + wfi);
                        continue;
                    }
                }

                Week w = new Week(wfi, ownerMap.get(wfi.User__c));
                
                //Add forecast categories to forecastSummary maps
                if(!fCategories.isEmpty()){
                    for(String fc : fCategories){
                        if(!w.forecastSummaryNS.containsKey(fc)){
                            w.forecastSummaryNS.put(fc,0);
                            w.forecastSummaryCS.put(fc,0);
                        }    
                    }
                }
                
                //Add opportunity amount summary to forecastSummary maps
                if(wfi.Forecast_Opportunity_Links__r != null){
                    for(Forecast_Opportunity_Link__c fol : wfi.Forecast_Opportunity_Links__r){
                        Double tempNS = 0;
                        Double tempCS = 0;
                        
                        if(fol.New_Sales_Amount__c != null && fol.Is_Won__c == false){
                            tempNS = w.forecastSummaryNS.get(fol.Opportunity__r.ForecastCategoryName) + fol.New_Sales_Amount__c;
                            w.forecastSummaryNS.put(fol.Opportunity__r.ForecastCategoryName,tempNS);
                        }
                        if(fol.Continuation_Sales_Amount__c != null && fol.Is_Won__c == false){
                            tempCS = w.forecastSummaryCS.get(fol.Opportunity__r.ForecastCategoryName) + fol.Continuation_Sales_Amount__c;
                            w.forecastSummaryCS.put(fol.Opportunity__r.ForecastCategoryName,tempCS);
                        }
                        
                    }
                }
                
                //Add commit field history to weekinstance
                w.fieldHistoryNS = historyMapNS.get(wfi.Id);
                w.fieldHistoryCS = historyMapCS.get(wfi.Id);
                
                //Check if today's date is between the start and end date. If yes this is the current week. 
                Date today = System.today();
                if(today >= wfi.Start_Date__c && today <= wfi.End_Date__c){
                    w.isCurrentWeek = true;
                }
                
                //Check if today's date is greater than end date. If yes this is a week in the past. 
                if(today >= wfi.Start_Date__c){
                    w.isPrevWeek = true;
                }                
                
                //If the owner is the current user add the item to weekinstancesList, otherwise add item to weekMap.
                if(wfi.User__c == currentUser){
                     weekInstancesList.add(w);
                } 
                else{
                    w.isChild = true;
                    
                    if(!weekMap.containsKey(wfi.Name)){
                        weekMap.put(wfi.Name,new List<Week>());
                    }
                    weekMap.get(wfi.Name).add(w);
                }
            } 
        }
        //Add subweeks
        if(!(weekInstancesList.isEmpty() || weekMap.isEmpty())){
            //Loop through weekInstanceList
            for(Week wInstance : weekInstancesList){
                List<Week> subWeeks = weekMap.get(wInstance.item.Name); //Get all subweeks from weekMap that has the same name as wInstance
                if(wInstance.sellerType != SellerTriggerHandler.SELLER_TYPE_SELLER && subweeks != null && !subWeeks.isEmpty()){
                    for(Week subWeek : subWeeks){
                        if((wInstance.item.Sales_Team__c == subWeek.item.Sales_Team__c && userIsManager) || (wInstance.item.Sales_Unit__c == subWeek.item.Sales_Unit__c && userIsSalesUnitManager && subWeek.item.Seller__r.Type__c == 'Sales Team Manager')){
                            wInstance.subWeeks.add(subWeek); //Add the subweeks to the parent week instance
                        }
                    }
                }
            }
        }

        weekInstancesList.sort();
        String JSONstring = JSON.serialize(weekInstancesList);
        System.debug('Metoden gick igenoom');
        return JSONstring;
    } 
    
    public PageReference saveCommit(){
        System.debug('SAVE COMMIT');
        commitValueString = Apexpages.currentPage().getParameters().get('commitValueString');
        System.debug('COMMITVALUESTRING ' + commitValueString);
        String selectedY = selectedYear;
        String selectedSalesType = selectedSalesType;
        String q = selectedQuarter.removeStart('Q');
        
        List<List<String>> commitValue = (List<List<String>>)System.JSON.deserialize(commitValueString, List<List<String>>.class);
        for(List<String> l : commitValue){
            for(String s : l){
                System.debug(s);
            }
        }

        Set<Weekly_Forecast_Item__c> updateWeeks = new Set<Weekly_Forecast_Item__c>();
        Set<Forecast_Opportunity_Link__c> updateFOLs = new Set<Forecast_Opportunity_Link__c>();
        Map<String,Weekly_Forecast_Item__c> weekMap = new Map<String,Weekly_Forecast_Item__c>();
        List<Weekly_Forecast_Item__c> weekList = [SELECT Id, Seller__c, Seller__r.End_Date__c, Sales_Team__c, Sales_Unit__c, Name, New_Sales_Commit__c, Continuation_Sales_Commit__c,
                                                    Comitted_on__c, Start_Date__c, End_Date__c,
                                                    (SELECT Committed_Week__c, Committed_On__c FROM Forecast_Opportunity_Links__r) 
                                                    FROM Weekly_Forecast_Item__c WHERE User__c = : Userinfo.getUserId() AND Quarterly_Forecast_Item__r.Name = :q AND Quarterly_Forecast_Item__r.Yearly_Target__r.Name = :selectedY AND Seller__r.End_Date__c >= :Date.today()];
        
        //Loop through the commit values and update the weekinstances
        String weekName;
        String salesTeam;
        String salesUnit;
        if(!commitValue.isEmpty()){
            for(Integer i = 0; i < commitValue.size(); i++){
                weekName = commitValue[i][0];
                salesTeam = commitValue[i][1];
                salesUnit = commitValue[i][2];
                for(Weekly_Forecast_Item__c w : weekList){
                    if(w != null && w.Name == weekName && (w.Sales_Team__c == salesTeam || (userIsSalesUnitManager && w.Sales_Unit__c == salesUnit))){
                        
                        //Check that the commit value is an integer
                        try{
                            Integer value = Integer.valueOf(commitValue[i][3]);
                        }
                        Catch (exception e) {
                            status = ' Din commit sparades inte. Du måste ange ett giltigt heltal';
                            return null;
                        }
                        
                        //Check that the commit value is positive and what salestype has been selected
                        if(Integer.valueOf(commitValue[i][3]) < 0){
                            status = ' Din commit sparades inte. Du måste ange ett positivt värde';
                            return null;
                        }
                        else{
                            if(selectedSalesType == 'NewSales'){
                                w.New_Sales_Commit__c = Integer.valueOf(commitValue[i][3]);
                            } 
                            else if(selectedSalesType == 'ContinuousSales') {
                                w.Continuation_Sales_Commit__c = Integer.valueOf(commitValue[i][3]);
                            } 
                            else{
                                System.debug('The salestype doesnt exist: ' + selectedSalesType);
                                status = ' Din commit sparades inte. Säljtypen existerar inte.';
                                return null;
                            }
                            updateWeeks.add(w);
                        }

                        // Added AN 12.01-2016
                        //If weeks is next week set Committed On field 
                        Date now = Date.today();
                        Date twoWeeks = now.addDays(14);
                        if(w.Start_Date__c > now && w.End_Date__c < twoWeeks){
                            w.Comitted_on__c = System.now();
                            if(w.Forecast_Opportunity_Links__r != null){
                                for(Forecast_Opportunity_Link__c fol : w.Forecast_Opportunity_Links__r){
                                    fol.Committed_Week__c = w.Name;
                                    fol.Committed_On__c = w.Comitted_on__c;
                                    updateFOLs.add(fol);
                                }
                            }
                        }
                    }  
                }
            }
        }
        System.debug('@@@updateWeeks: ' + updateWeeks);
        if(!updateWeeks.isEmpty()){
            try{
                List<Weekly_Forecast_Item__c> updateWeeksList = new List<Weekly_Forecast_Item__c>(updateWeeks);
                List<Forecast_Opportunity_Link__c> updateFOLsList = new List<Forecast_Opportunity_Link__c>(updateFOLs);
                update updateWeeksList;
                update updateFOLsList;
            }
            catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                status = ' Din commit sparades inte. Kontakta din administratör om problemet kvarstår';
                return null;
            }
        }
        status = 'Commit Saved';
        return null;
    }
    
    public class Week implements Comparable{
        public Weekly_Forecast_Item__c item {get;set;}
        public List<Weekly_Forecast_Item__History> fieldHistoryNS {get;set;}
        public List<Weekly_Forecast_Item__History> fieldHistoryCS {get;set;}
        public Boolean isChild {get;set;}
        public Boolean isCurrentWeek {get;set;}
        public Boolean isPrevWeek {get;set;}
        public String ownerName {get;set;}
        public String sellerType {get;set;}
        public List<Week> subWeeks {get;set;}
        public Map<String,Double> forecastSummaryNS {get;set;}
        public Map<String,Double> forecastSummaryCS {get;set;}
        
        public Week(){}
        public Week(Weekly_Forecast_Item__c item, String ownerName){
            this.item = item;
            this.fieldHistoryNS = new List<Weekly_Forecast_Item__History>();
            this.fieldHistoryCS = new List<Weekly_Forecast_Item__History>();
            this.isChild = false;
            this.isCurrentWeek = false;
            this.isPrevWeek = false;
            this.ownerName = ownerName;
            this.sellerType = item.Seller__r.Type__c;
            this.subWeeks = new List<Week>();
            this.forecastSummaryNS = new Map<String,Double>();
            this.forecastSummaryCS = new Map<String,Double>();
        }
        
        public Integer compareTo(Object compareTo) 
        {
            Week week = (week) compareTo;
            if (Integer.valueOf(item.Name) == Integer.valueOf(week.item.Name)) return 0;
            if (Integer.valueOf(item.Name) > Integer.valueOf(week.item.Name)) return 1;
            return -1;        
        }  
    }      
}