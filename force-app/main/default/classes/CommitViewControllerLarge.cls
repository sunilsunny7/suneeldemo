public class CommitViewControllerLarge {
    
    //User variables
    public String typeOfUser{get;set;}
    public Id currentUser = UserInfo.getUserId(); 
        
    //Picklist variables
    public String selectedYear{get;set;}
    public String selectedQuarter{get; set{selectedQuarter = value;}}
    public List<SelectOption> yearOptions{get;set;}
    public List<SelectOption> quarterOptions{get;set;}
    
    public String targets{set;}
    public transient String weekInstances{set;}
    public String judgeValueString{get;set;}
    public String status{get;set;}

    public CommitViewControllerLarge(){
        this.typeOfUser = getTypeOfUser();
        this.selectedYear = String.valueof(System.Today().year());
        this.selectedQuarter = getCurrentQuarter();
        this.yearOptions = createYearOptions();
        this.quarterOptions = createQuarterOptions();
        this.targets = getTargets();
        this.weekInstances = getWeekInstances();
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }
    
    public String getTypeOfUser(){
        List<Seller__c> sellers = [Select Type__c, Start_Date__c from Seller__c where User__c = : currentUser and Start_Date__c <= : Date.today() and (End_Date__c >= : Date.today() or End_Date__c = null)];
        String t;
        if(!sellers.isEmpty()){
            t = sellers[0].Type__c;
        }
    return t;
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
    
    public String getTargets(){
        List<Weekly_Forecast_Item__c> targets = [Select New_Sales_Target__c,
                                                 Continuation_Sales_Target__c,
                                                 Quarterly_Forecast_Item__r.Goal_Achievement_New_Sales__c,
                                                 Quarterly_Forecast_Item__r.Yearly_Target__r.Goal_Achievement_New_Sales__c,
                                                 Quarterly_Forecast_Item__r.Goal_Achievement_Continuation_Sales__c,
                                                 Quarterly_Forecast_Item__r.Yearly_Target__r.Goal_Achievement_Continuation_Sales__c from Weekly_Forecast_Item__c where User__c = : currentUser and Start_Date__c <= : Date.today() and End_Date__c >= : Date.today() and Active_Week__c = TRUE];
        String jsonString;
        List<Target> t = new List<Target>();
        if(targets.size()>0){
            Target targetNS = new Target(Label.New_Sales, targets[0].New_Sales_Target__c, targets[0].Quarterly_Forecast_Item__r.Goal_Achievement_New_Sales__c, targets[0].Quarterly_Forecast_Item__r.Yearly_Target__r.Goal_Achievement_New_Sales__c);
            Target targetCS = new Target(Label.Continuation_Sales, targets[0].Continuation_Sales_Target__c, targets[0].Quarterly_Forecast_Item__r.Goal_Achievement_Continuation_Sales__c, targets[0].Quarterly_Forecast_Item__r.Yearly_Target__r.Goal_Achievement_Continuation_Sales__c);
            t.add(targetNS);
            t.add(TargetCS);
            jsonString = JSON.serialize(t);
        }
        return jsonString;
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
        
        List<Seller__c> sellers = [Select Id, User__c from Seller__c where Manager__r.User__c = :currentUser];
        //If user is a manager and has a team: add the team to teamIds
        if(!sellers.isEmpty()){
            for(Seller__c s: sellers){
                teamIds.add(s.User__c);
                sellerIds.add(s.Id);
            }
        }
        System.debug('SellerIds: ' + sellerIds);

		//If User has Enterprise Role, ignore the opportunitys to bypass Heap Size Limit.
		if (UserInfo.getUserRoleId() == '00E24000000QPMAEA4'){
		fcItems = [SELECT Id, Name, User__c, Start_Date__c, End_Date__c, Active_Week__c,
                   Seller__c, Sales_Team__c, Sales_Unit__c, Seller__r.Type__c, 
                   Seller__r.Business_Unit_Name__c, Seller__r.Business_Area_Name__c,
                   Accumulated_New_Sales_Outcome_X__c, Accumulated_Continuation_Sales_Outcome_X__c,
                   Judge_CS__c, Judge_NS__c, isWeekInPast__c,
                   CommitNS_plus_Judges__c, CommitCS_plus_Judges__c,
                   Commit_New_Sales_Large__c, Commit_Continuation_Sales_Large__c,
                   Outcome_Commit_NS__c, Outcome_Commit_CS__c,
                   Risk_New_Sales__c, Risk_Continuation_Sales__c,
                   Upside_New_Sales__c, Upside_Continuation_Sales__c,
                   Revenue_Impact_This_Year__c                  
				   FROM Weekly_Forecast_Item__c WHERE (User__c = : currentUser OR Seller__c IN : sellerIds) AND Quarterly_Forecast_Item__r.Name = :q AND Quarterly_Forecast_Item__r.Yearly_Target__r.Name = :selectedYear ORDER BY Name];
		}else{        
        //Query Weekly Forecast Items with related Opportunities
        fcItems = [SELECT Id, Name, User__c, Start_Date__c, End_Date__c, Active_Week__c,
                   Seller__c, Sales_Team__c, Sales_Unit__c, Seller__r.Type__c, 
                   Seller__r.Business_Unit_Name__c, Seller__r.Business_Area_Name__c,
                   Accumulated_New_Sales_Outcome_X__c, Accumulated_Continuation_Sales_Outcome_X__c,
                   Judge_CS__c, Judge_NS__c, isWeekInPast__c,
                   CommitNS_plus_Judges__c, CommitCS_plus_Judges__c,
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
                    Weighted_Continuation_Sales_Amount__c, Weighted_New_Sales_Amount__c,
                    Include_in_Outcome_Commit__c, Revenue_Impact_This_Year__c FROM Forecast_Opportunity_Links__r) 
                   FROM Weekly_Forecast_Item__c WHERE (User__c = : currentUser OR Seller__c IN : sellerIds) AND Quarterly_Forecast_Item__r.Name = :q AND Quarterly_Forecast_Item__r.Yearly_Target__r.Name = :selectedYear ORDER BY Name];
        }
        //Create User Id to User Name Map & User ID
        Map<Id,String> ownerMap = createOwnerMap(teamIds);
        
        if(!fcItems.isEmpty()){
            //Loop through the weekly forecasting items and create a week instance.  
            for(Weekly_Forecast_Item__c wfi : fcItems){

                Week w = new Week(wfi, ownerMap.get(wfi.User__c)); 
                
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
                
                if(wfi.Seller__r.Type__c == 'Seller'){
                    w.title = ownerMap.get(wfi.User__c);
                }
                else if(wfi.Seller__r.Type__c == 'Sales Team Manager'){
                    w.title = wfi.Sales_Team__c;
                }
                else if(wfi.Seller__r.Type__c == 'Sales Unit Director'){
                    w.title = wfi.Sales_Unit__c;
                }
                else if(wfi.Seller__r.Type__c == 'Business Unit Manager'){
                    w.title = wfi.Seller__r.Business_Unit_Name__c;
                }
                else if(wfi.Seller__r.Type__c == 'Business Area Manager'){
                    w.title = wfi.Seller__r.Business_Area_Name__c;
                }
            } 
        }
        
        if(!(weekInstancesList.isEmpty() || weekMap.isEmpty())){
            //Loop through weekInstanceList
            for(Week wInstance : weekInstancesList){
                List<Week> subWeeks = weekMap.get(wInstance.item.Name); //Get all subweeks from weekMap that has the same name as wInstance
                if(!subWeeks.isEmpty()){
                    
                    for(Week subWeek : subWeeks){
                        
                        if(wInstance.item.Sales_Team__c == subWeek.item.Sales_Team__c || (typeOfUser == 'Sales Unit Director' && wInstance.item.Sales_Unit__c == subWeek.item.Sales_Unit__c) || (typeOfUser == 'Business Unit Manager' && wInstance.item.Seller__r.Business_Unit_Name__c == subWeek.item.Seller__r.Business_Unit_Name__c) || (typeOfUser == 'Business Area Manager' && wInstance.item.Seller__r.Business_Area_Name__c == subWeek.item.Seller__r.Business_Area_Name__c)){
                            wInstance.subWeeks.add(subWeek); //Add the subweeks to the parent week instance
                            
                        }
                    }
                }    
            }
            
        }
        weekInstancesList.sort();
        String JSONstring = JSON.serialize(weekInstancesList);
        return JSONstring;
    } 
    
    public PageReference saveJudge(){
        judgeValueString = Apexpages.currentPage().getParameters().get('judgeValueString');
        System.debug('JUDGEVALUESTRING ' + judgeValueString);
        String selectedY = selectedYear;
        String q = selectedQuarter.removeStart('Q');
        
        List<List<String>> judgeValue = (List<List<String>>)System.JSON.deserialize(judgeValueString, List<List<String>>.class);
        for(List<String> l : judgeValue){
            for(String s : l){
                System.debug(s);
            }
        }
        System.debug('Test0');
        List<Weekly_Forecast_Item__c> updateWeeks = new List<Weekly_Forecast_Item__c>();
        List<Forecast_Opportunity_Link__c> updateFOLs = new List<Forecast_Opportunity_Link__c>();
        Map<String,Weekly_Forecast_Item__c> weekMap = new Map<String,Weekly_Forecast_Item__c>();
        List<Weekly_Forecast_Item__c> weekList = [SELECT Id,
                                                  Seller__c,
                                                  Name,
                                                  Judge_CS__c, Judge_NS__c,
                                                  Comitted_on__c,
                                                  Start_Date__c, End_Date__c,
                                                  (SELECT Committed_Week__c, Committed_On__c FROM Forecast_Opportunity_Links__r) 
                                                  FROM Weekly_Forecast_Item__c WHERE User__c = : Userinfo.getUserId() AND Quarterly_Forecast_Item__r.Name = :q AND Quarterly_Forecast_Item__r.Yearly_Target__r.Name = :selectedY];
               
        //Loop through the commit values and update the weekinstances
        String weekName;
        String seller;
        if(!judgeValue.isEmpty()){
            System.debug('Test1');
            for(Integer i = 0; i < judgeValue.size(); i++){
                System.debug('Test2');
                weekName = judgeValue[i][0];
                seller = judgeValue[i][1];
                for(Weekly_Forecast_Item__c w : weekList){
                    System.debug('Weeeeek: ' + w);
                    System.debug('Sellerr: ' + seller);
                    if(w != null && w.Name == weekName && w.Seller__c == seller){
                        
                        //Check that the judge values are integers
                        try{
                            Integer valueNS = Integer.valueOf(judgeValue[i][2]);
                            Integer valueCS = Integer.valueOf(judgeValue[i][3]);
                        }
                        Catch (exception e) {
                            status = ' Din commit sparades inte. Du måste ange ett giltigt heltal';
                            return null;
                        }
                        
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

                        w.Judge_NS__c = Integer.valueOf(judgeValue[i][2]);
                        w.Judge_CS__c = Integer.valueOf(judgeValue[i][3]);
                        
                        updateWeeks.add(w);
                    } 
                }
            }
        }
        System.debug('@@@updateWeeks: ' + updateWeeks);
        if(!updateWeeks.isEmpty()){
            try{
                update updateWeeks;
                update updateFOLs;
            }
            catch(DmlException e) {
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
        public Integer weeklyTarget;
        public Integer quarterlyGF;
        public Integer yearlyGF;
        
        public Target(String salesType, Decimal weeklyTarget, Decimal quarterlyGF, Decimal yearlyGF){
            this.salesType = salesType;
            this.weeklyTarget = Integer.valueOf(weeklyTarget);
            this.quarterlyGF = Integer.valueOf(quarterlyGF);
            this.yearlyGF = Integer.valueOf(yearlyGF);
        }
    }
    
    public class Week implements Comparable{
        public Weekly_Forecast_Item__c item {get;set;}
        public Boolean isChild {get;set;}
        public Boolean isCurrentWeek {get;set;}
        public Boolean isPrevWeek {get;set;}
        public String ownerName {get;set;}
        public List<Week> subWeeks {get;set;}
        public String title {get;set;}
        
        public Week(){}
        public Week(Weekly_Forecast_Item__c item, String ownerName){
            this.item = item;
            this.isChild = false;
            this.isCurrentWeek = false;
            this.isPrevWeek = false;
            this.ownerName = ownerName;
            this.subWeeks = new List<Week>();
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