/**
    About
    -----
    Description: Handle creation and updates of Yearly Target records.

    Created October 2015 - A.N Functionality from old Yearly Target Trigger merged into this trigger Handler Class
   
    Update History
    --------------   
    Updated Feb 2016 - A.N - Added methods for updating Yearly Target target values
    Updated Apr 2016 - P.P - Added method to include Sales Value Target's functionality to divided over weeks
    Updated Sep 2016 - A.N - Refactored: no functional changes made, cleaned up in comments/debug statements
    Updates Apr 2018 - Y.K - Changes for SALEF-919 Change phasing of New Sales targets for SOHO Sales
    Issues / TODOs
    --------------  
*/


public class YearlyTargetTriggerHandler {

    /* * * * * * * * * * * * * * * * * * * * * * * * */
    /* * YearlyTargetTriggerHandler Trigger Calls  * */
    /* * * * * * * * * * * * * * * * * * * * * * * * */

    // Unless testyearlyTargetValidation is set to true in the test class, testing of the validation of new insert on YT will not run.
    // This is done to reduce # of SOQL queries in tests, by allowing targets for managers and sellers to be inserted at the same time.
    @TestVisible private static Boolean testyearlyTargetValidation = false;

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public YearlyTargetTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(List<Yearly_Target__c> newList, Map<ID, Yearly_Target__c> newMap){
        System.debug('YearlyTargetTriggerHandler.OnBeforeInsert start. Number of SOQLs used so far'+Limits.getQueries());
        validateAndInitialize(newList);
    }

    public void OnAfterInsert(List<Yearly_Target__c> newList, Map<ID, Yearly_Target__c> newMap){
        System.debug('YearlyTargetTriggerHandler.OnAfterInsert start. Number of SOQLs used so far'+Limits.getQueries());
        createQFIandWFI(newList);
        repointForecastOpportunityLinks(newList);
    }

    public void OnBeforeUpdate(List<Yearly_Target__c> newList, Map<ID, Yearly_Target__c> newMap, List<Yearly_Target__c> oldList, Map<ID, Yearly_Target__c> oldMap){
        System.debug('YearlyTargetTriggerHandler.OnBeforeUpdate start. Number of SOQLs used so far'+Limits.getQueries());
        updateYtTargets(newMap, oldMap);
    }

    public void OnAfterUpdate(List<Yearly_Target__c> newList, Map<ID, Yearly_Target__c> newMap, List<Yearly_Target__c> oldList, Map<ID, Yearly_Target__c> oldMap){
        System.debug('YearlyTargetTriggerHandler.OnAfterUpdate start. Number of SOQLs used so far'+Limits.getQueries());
        updateQfiAndWfiTargets(newMap, oldMap);
    }

    /* * * * * * * * * * * * * * * * * * * * * * * * * */
    /* * YearlyTargetTriggerHandler Trigger Methods  * */
    /* * * * * * * * * * * * * * * * * * * * * * * * * */


    // First validation is run on the new Yearly target records. If no errors, 
    private static void validateAndInitialize(List<Yearly_Target__c> newList){
        if(Test.isRunningTest() && !testyearlyTargetValidation) return;

        loadYearlyTargetsMap(newList);
        
        for(Yearly_Target__c ytToBe : newList){
            if(!ytToBe.name.isNumeric()){
                ytToBe.addError('A year must be a number and in the format of YYYY e.g. 2015');
            } else if(Integer.valueOf(ytToBe.name)-Date.today().year() < 0){
                ytToBe.addError('A target can only be created for the current year or for future years' );
            } else if(Integer.valueOf(ytToBe.name) > 4000){
                ytToBe.addError('The system only supports creating yearly targets up to and including year 4000');
            }

            if(sellerYTMap == null || sellerYTMap.get(ytToBe.Seller__c) == null){
                ytToBe.addError('A Seller must be set for the Yearly Target');
            } else {
                Seller__c seller = sellerYTMap.get(ytToBe.Seller__c);
                // has seller existing yearly target
                for(Yearly_Target__c ytExisting : seller.Arsmal__r){
                    //if(ytToBe.Name == ytExisting.Name && ((ytToBe.Seller__c != null && ytToBe.Seller__c == ytExisting.Seller__c) || (ytToBe.Hierarchy_Level__c != 'Seller' && ytToBe.Hierarchy_Level__c != 'Sales Team' && ytToBe.Seller__c == null && ytExisting.Hierarchy_Level__c != 'Seller' && ytExisting.Hierarchy_Level__c != 'Sales Team' && ytExisting.Seller__c == null && ytToBe.User__c == ytExisting.User__c))){
                    if(ytToBe.Name == ytExisting.Name){
                        ytToBe.addError('The year already exist for this seller');
                    }
                }

                if(!hasManagerYearlyTarget(seller.Manager__c, ytToBe.Name)){
                    ytToBe.addError('Yearly targets must first be created for the managers');
                }                   
            }

            //Assign the Full_Year fields the target values that the user have entered.
            ytToBe.New_Sales_Target__c = ytToBe.Full_Year_New_Sales_Target__c;
            ytToBe.Continuation_Sales_Target__c = ytToBe.Full_Year_Continuation_Sales_Target__c;
            ytToBe.Sales_Value_Target__c = ytToBe.Full_Year_Sales_Value_Target__c;
            
            // If start week not 1, adjust the targets
            if(Integer.valueOf(ytToBe.Startweek__c) != 1){
                if(Integer.valueOf(ytToBe.Startweek__c) == 53 && !SEUtility.isFiftyThreeWeekYear(Integer.valueOf(ytToBe.Name))){
                    ytToBe.addError('The specified year does not have 53 weeks');
                } else {
                    Map<String,Decimal> recalcReturnMap = YearlyTargetUtil.calculateQuartersAndWeeks(ytToBe);
                    ytToBe.New_Sales_Target__c = recalcReturnMap.get(YearlyTargetUtil.NEWSALES);
                    ytToBe.Continuation_Sales_Target__c = recalcReturnMap.get(YearlyTargetUtil.CONSALES);
                    ytToBe.Sales_Value_Target__c = recalcReturnMap.get(YearlyTargetUtil.SALESVALUE);
                }
            }
        }
        sellerYTMap = null; // reset map to null after run
    }

    // Checks whether all managers above the user in the hierarchy has yearly targets created for the specified year.
    private static Boolean hasManagerYearlyTarget(Id managerId, String yearName){
        if(managerId != null){
            //Fetch Manager Seller record
            Seller__c manager = sellerYTMap.get(managerId);
            Boolean managerHasYT = false;

            // has manager existing yearly target
            for(Yearly_Target__c ytExisting : manager.Arsmal__r){
                if(ytExisting.Name == yearName){
                    managerHasYT = true;
                    break;
                }
            }

            if(managerHasYT){
                return hasManagerYearlyTarget(manager.Manager__c, yearName); // has managers manager existing yearly target
            }
            return false; // No YT found for the manager
        }
        return true;
    }

    private static Map<Id, Seller__c> sellerYTMap;
    private static void loadYearlyTargetsMap(List<Yearly_Target__c> newList){
        if(sellerYTMap == null){
            Set<String> yearNames = new Set<String>();
            for(Yearly_Target__c yt : newList){
                yearNames.add(yt.Name);
            }
            sellerYTMap = new Map<Id, Seller__c>([Select Id, User__c, Manager__c,
                (SELECT Id, Name FROM Arsmal__r WHERE Name IN :yearNames)
                from Seller__c]);
        }
    }

    private static void createQFIandWFI(List<Yearly_Target__c> newList){
        
        List<Quarterly_Forecast_Item__c> qfiList = new List<Quarterly_Forecast_Item__c>();
        
        //Fetch the Sales Target Distribution
        Map<Integer,Double> salesTargetDistMap = SEUtility.getSalesTargetDistributionMap();
        
        //Added by Y.K For SALEF-919
        Map<Integer,Double> SOHONewSalesTargetDistMap= SEUtility.getSOHONewSalesTargetDistributionMap();
        
        for(Yearly_Target__c yt : newList){          
            //Figure out the quarter start date and end dates
            Map<Integer,Map<Date,Date>> quarterMap = SEUtility.getTeliaQuarterStartAndEndDates(Integer.valueOf(yt.Name));
            // Add quarters to year
            
            for(Integer i : quarterMap.keySet()){
                for(Date d : quarterMap.get(i).keySet()){
               
                if(SEUtility.isSOHOUser(yt.User__c) == true && SOHONewSalesTargetDistMap != null)    //Changes for SALEF-919
                    {
                    
                    qfiList.add(new Quarterly_Forecast_Item__c(
                        Name=String.valueOf(i),
                        User__c = yt.User__c, 
                        Start_Date__c = d,
                        Seller__c = yt.Seller__c,
                        End_Date__c = quarterMap.get(i).get(d),
                        New_Sales_Target__c = yt.Full_Year_New_Sales_Target__c*SOHONewSalesTargetDistMap.get(Integer.valueOf(i)),
                        Continuation_Sales_Target__c = yt.Full_Year_Continuation_Sales_Target__c*salesTargetDistMap.get(i),
                        Sales_Value_Target__c = yt.Full_Year_Sales_Value_Target__c*0.25,
                        Yearly_Target__c=yt.Id,
                        Belongs_To_Year__c=Integer.valueOf(yt.Name))
                        
                        );
                    }
                    
                    else{ 
                    qfiList.add(new Quarterly_Forecast_Item__c(
                        Name=String.valueOf(i),
                        User__c = yt.User__c, 
                        Start_Date__c = d,
                        Seller__c = yt.Seller__c,
                        End_Date__c = quarterMap.get(i).get(d),
                        New_Sales_Target__c = yt.Full_Year_New_Sales_Target__c*salesTargetDistMap.get(i),
                        Continuation_Sales_Target__c = yt.Full_Year_Continuation_Sales_Target__c*salesTargetDistMap.get(i),
                        Sales_Value_Target__c = yt.Full_Year_Sales_Value_Target__c*0.25,
                        Yearly_Target__c=yt.Id,
                        Belongs_To_Year__c=Integer.valueOf(yt.Name))
                    );
                    }
                }
            }        
        }
        insert qfiList;
        
        // The full list of weeks that shall be inserted
        List<Weekly_Forecast_Item__c> wfiList = new List<Weekly_Forecast_Item__c>();
               
        // *** ORGANIZE THE QUARTERS INTO YEARS ****
        //Create a Map Year=>Set(All quarters of that year).
        Map<Integer,Set<Quarterly_Forecast_Item__c>> yearQuarterMap = new Map<Integer, Set<Quarterly_Forecast_Item__c>>();
        for(Quarterly_Forecast_Item__c qfi : qfiList){
            if(!yearQuarterMap.containsKey(Integer.valueOf(qfi.Belongs_To_Year__c))){
                Set<Quarterly_Forecast_Item__c> tempQfiSet = new Set<Quarterly_Forecast_Item__c>();
                tempQfiSet.add(qfi);
                yearQuarterMap.put(Integer.valueOf(qfi.Belongs_To_Year__c), tempQfiSet);
            } else {
                yearQuarterMap.get(Integer.valueOf(qfi.Belongs_To_Year__c)).add(qfi);
            }
        }
        
        Map<Id,List<Quarterly_Forecast_Item__c>> yearIdToQuarterMap = new Map<Id, List<Quarterly_Forecast_Item__c>>();
        for(Quarterly_Forecast_Item__c qfi : qfiList){
            if(!yearIdToQuarterMap.containsKey(qfi.Yearly_Target__c)){
                yearIdToQuarterMap.put(qfi.Yearly_Target__c, new List<Quarterly_Forecast_Item__c>{qfi});
            } else {
                yearIdToQuarterMap.get(qfi.Yearly_Target__c).add(qfi);
            }
        }
        
        // A temporary list of weeks
        List<Weekly_Forecast_Item__c> tempWfiList = new List<Weekly_Forecast_Item__c>();
        Set<Weekly_Forecast_Item__c> tempWfiSet = new Set<Weekly_Forecast_Item__c>();
        
        // Accumulator variables to sum the new sales target and continutation sales target used when start week != 1 
        Decimal newSalesQuarterAcc;
        Decimal conSalesQuarterAcc;
        Decimal salesValueQuarterAcc;
        
        Map<Id,Set<Weekly_Forecast_Item__c>> quarterIdToWFIMap = new Map<Id,Set<Weekly_Forecast_Item__c>>();
        
        // *** CREATE WEEKS ***
        for(Yearly_Target__c yt : newList){
            tempWfiList = new List<Weekly_Forecast_Item__c>();            
            for(Quarterly_Forecast_Item__c qfi : yearIdToQuarterMap.get(yt.Id)){ 
                tempWfiSet = new Set<Weekly_Forecast_Item__c>();
                tempWfiSet.addAll(SEUtility.getWeeks(qfi.Id,
                                                  Integer.valueOf(qfi.Belongs_To_Year__c),
                                                  qfi.Name,
                                                  qfi.New_Sales_Target__c,
                                                  qfi.Continuation_Sales_Target__c, 
                                                  qfi.Sales_Value_Target__c,
                                                  qfi.user__c,
                                                  qfi.Start_Date__c,  
                                                  qfi.End_Date__c,
                                                  yt.Seller__c));
                tempWfiList.addAll(tempWfiSet);
                quarterIdToWFIMap.put(qfi.Id, tempWfiSet);
            }
            
            // If the start week is not 1 - the weeks before the start week must be zeroed
            if(Integer.valueOf(yt.Startweek__c) != 1){
                newSalesQuarterAcc = 0.0;
                conSalesQuarterAcc = 0.0;
                salesValueQuarterAcc = 0.0;
                for(Quarterly_Forecast_Item__c qfi : qfiList){
                    for(Weekly_Forecast_Item__c wfi : quarterIdToWFIMap.get(qfi.Id)){
                        if(Integer.valueOf(wfi.Name) < Integer.valueOf(yt.Startweek__c)){
                            wfi.New_Sales_Target__c = 0;
                            wfi.Continuation_Sales_Target__c = 0;
                            wfi.Sales_Value_Target__c = 0;
                        } else {
                            newSalesQuarterAcc += wfi.New_Sales_Target__c;
                            conSalesQuarterAcc += wfi.Continuation_Sales_Target__c;
                            salesValueQuarterAcc += wfi.Sales_Value_Target__c;
                        }
                    }
                    qfi.New_Sales_Target__c = newSalesQuarterAcc;
                    qfi.Continuation_Sales_Target__c = conSalesQuarterAcc;
                    qfi.Sales_Value_Target__c = salesValueQuarterAcc;
                    newSalesQuarterAcc = 0.0;
                    conSalesQuarterAcc = 0.0;
                    salesValueQuarterAcc = 0.0;
                }
            }
            wfiList.addAll(tempWfiList);            
        }
        
        insert wfiList;
        update qfiList;
    }

    private static void repointForecastOpportunityLinks(List<Yearly_Target__c> newList){       
        //Get all users that the yearly targets have been created for
        List<Id> userIds = new List<Id>();
        for(Yearly_Target__c yt : newList){
            userIds.add(yt.User__c);
        }
        List<User> userList = [Select Id, profileid From User Where Id in :userIds];

        // Note: For this setting, anyone with Sys-admin or Telia Sales - General user profiles are both Large and SME Users
        List<Id> largeUserIds = new List<Id>();
        List<Id> smeUserIds = new List<Id>();
        for(User u : userList){
            if(SEUtility.isLargeUser(u)){
                largeUserIds.add(u.Id);
                // Make sure we only add users to one of the lists if user is both SME and Large.
                // Otherwise Opp might be added twice to oppWithNewFOLsList, which will cause an exception in the recreateFOL-method
            } else if(SEUtility.isSmeUser(u)){
                smeUserIds.add(u.Id);
            }
        }

        // Want to filter out opps not in the years we are looking at.
        String earliestYearName;
        String latestYearName;
        for(Yearly_Target__c yt : newList){
            if(earliestYearName == null){
                earliestYearName = yt.Name;
                latestYearName = yt.Name;
            } else if(yt.Name < earliestYearName){
                earliestYearName = yt.Name;
            } else if(yt.Name > latestYearName){
                latestYearName = yt.Name; 
            }
        }
        Date firstDate = SEUtility.getFirstDayOfTeliaYear(Integer.valueOf(earliestYearName));
        Date lastDate = SEUtility.getLastDayOfTeliaYear(Integer.valueOf(latestYearName));

        //Filter opportunities: Create a list of the opportunities that is needed for the recreateFOL method
        List<Opportunity> oppWithNewFOLsList = new List<Opportunity>();
        Id prospectRTId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
        Id forenkladLargeRecordTypeId = SEUtility.getRecordTypeid(SEUTILITY.OPP_RECTYPE_LARGE_ENLARGEMENT);

        if(smeUserIds.size() > 0){
            //For SME: Fetch all opportunities that has an Owner that is in the sme user list
            List<Opportunity> smeOppList = [Select Id, Seller__c, Account.OwnerId, CloseDate, IsClosed, StageName, OwnerId, RecordTypeId, Large_New_Sales__c, Large_Continuation_Sales__c,Sales_Outcome__c, Sales_Outcome_Large__c, Probability, IsWon, Risk__c, Revenue_Impact_This_Year__c
                                            from Opportunity where OwnerId in : smeUserIds AND CloseDate >= :firstDate AND CloseDate <= :lastDate];            
            system.debug('smeOppList: ' + smeOppList);
            for(Opportunity opp : smeOppList){
                if(opp.StageName != null && opp.RecordTypeId != prospectRTId && opp.RecordTypeId != forenkladLargeRecordTypeId){
                    oppWithNewFOLsList.add(opp);
                }
            }
        }

        if(largeUserIds.size() > 0){
            // For Large: Needs to fetch all opportunities belonging to any account where the large user is the account owner
            //Sales_Outcome__c added to Query here since system admin user is first included in large user list
            List<Opportunity> largeOppList = [Select Id, Seller__c, Account.OwnerId, CloseDate, IsClosed, StageName, OwnerId, RecordTypeId, Large_New_Sales__c, Large_Continuation_Sales__c,Sales_Outcome_Large__c, Sales_Outcome__c, Probability, IsWon, Risk__c, Revenue_Impact_This_Year__c 
                                            from Opportunity where Account.OwnerId in : largeUserIds AND CloseDate >= :firstDate AND CloseDate <= :lastDate];
            system.debug('largeOppList: ' + largeOppList);
            for(Opportunity opp : largeOppList){
                if(opp.StageName != null && opp.RecordTypeId != prospectRTId && opp.RecordTypeId != forenkladLargeRecordTypeId){
                    oppWithNewFOLsList.add(opp);
                }
            }
        }
        
        //Recreate fol for all the opportunities in the list
        if(!oppWithNewFOLsList.isEmpty()){
            OpportunityTriggerHandler.recreateFOL(oppWithNewFOLsList);
        }
    }

    private static void updateYtTargets(Map<ID, Yearly_Target__c> newMap, Map<ID, Yearly_Target__c> oldMap){
        List<Yearly_Target__c> ytsForTargetUpdateIdList = new List<Yearly_Target__c>();
        
        for(Yearly_Target__c newYt : newMap.values()){
            Yearly_Target__c oldYt = oldMap.get(newYt.Id);
            if(newYt.Startweek__c != oldYt.Startweek__c || newYt.Full_Year_Continuation_Sales_Target__c != oldYt.Full_Year_Continuation_Sales_Target__c || newYt.Full_Year_New_Sales_Target__c != oldYt.Full_Year_New_Sales_Target__c || newYt.Full_Year_Sales_Value_Target__c != oldYt.Full_Year_Sales_Value_Target__c){
                ytsForTargetUpdateIdList.add(newYt);
            }
        }

        for(Yearly_Target__c yt : ytsForTargetUpdateIdList){           
            yt.New_Sales_Target__c = yt.Full_Year_New_Sales_Target__c;
            yt.Continuation_Sales_Target__c = yt.Full_Year_Continuation_Sales_Target__c;
            /*added by PP*/
            yt.Sales_Value_Target__c = yt.Full_Year_Sales_Value_Target__c;
            
            if(yt.Startweek__c != '1'){ // If start week is different from 1, we must adjust the targets accordingly
                Map<Integer,Double> salesTargetDistMap = SEUtility.getSalesTargetDistributionMap();
            
                //Added by Y.K For SALEF-919
                Map<Integer,Double> SOHONewSalesTargetDistMap= SEUtility.getSOHONewSalesTargetDistributionMap();
                
                Decimal newSalesTargetYearAdjusted = 0.0;
                Decimal contSalesTargetYearAdjusted = 0.0;
                Decimal salesValueTargetYearAdjusted = 0.0;
                Integer ytStartWeek = Integer.valueOf(yt.Startweek__c);
                
                Decimal newSalesTargetFullQuarter = 0.0;
                Decimal contSalesTargetFullQuarter = 0.0;
                Decimal salesValueTargetFullQuarter =0.0;

                for(Integer i = 1; i < 5; i++){ // For each quarter number 1,2,3,4
                     if(SEUtility.isSOHOUser(yt.User__c) == true)    //Changes for SALEF-919
                    {
                        newSalesTargetFullQuarter = yt.Full_Year_New_Sales_Target__c*SOHONewSalesTargetDistMap.get(Integer.valueOf(i));
                        contSalesTargetFullQuarter = yt.Full_Year_Continuation_Sales_Target__c*salesTargetDistMap.get(i);
                        salesValueTargetFullQuarter = yt.Full_Year_Sales_Value_Target__c*0.25;
                      }
                    else{
            
                        newSalesTargetFullQuarter = yt.Full_Year_New_Sales_Target__c*salesTargetDistMap.get(i);
                        contSalesTargetFullQuarter = yt.Full_Year_Continuation_Sales_Target__c*salesTargetDistMap.get(i);
                        salesValueTargetFullQuarter = yt.Full_Year_Sales_Value_Target__c*0.25;
                        }
                    
                    
                    Integer qNoOfWeeks = SEUtility.getWeeksInQuarter(i, Integer.valueOf(yt.Name));
                    Integer qStartWeek = i*13-12; // Q1 -> 1, Q2 -> 14, Q3 -> 27, Q4 -> 40, 
                    Integer qEndWeek = qStartWeek - 1 + qNoOfWeeks; // Q1 -> 13, Q2 -> 26, Q3 -> 39, Q4 -> 52 OR 53,
                    
                    if(ytStartWeek <= qStartWeek){ // Add entire sum
                        newSalesTargetYearAdjusted += newSalesTargetFullQuarter;
                        contSalesTargetYearAdjusted += contSalesTargetFullQuarter;
                        salesValueTargetYearAdjusted += salesValueTargetFullQuarter;
                    } else if(ytStartWeek <= qEndWeek){ // The start week is sometime within this quarter. Only add the part of the sum for which the Yt was active
                        newSalesTargetYearAdjusted += newSalesTargetFullQuarter*(qEndWeek - ytStartWeek + 1)/qNoOfWeeks;
                        contSalesTargetYearAdjusted += contSalesTargetFullQuarter*(qEndWeek - ytStartWeek + 1)/qNoOfWeeks;
                        salesValueTargetYearAdjusted += salesValueTargetFullQuarter*(qEndWeek- ytStartWeek+1)/qNoOfWeeks;
                        } // else the yt start week is after the qEndWeek and we should add nothing for this quarter
                }
                yt.New_Sales_Target__c = newSalesTargetYearAdjusted;
                yt.Continuation_Sales_Target__c = contSalesTargetYearAdjusted;
                yt.Sales_Value_Target__c = salesValueTargetYearAdjusted;
                
            }
        }
    }

    private static void updateQfiAndWfiTargets(Map<ID, Yearly_Target__c> newMap, Map<ID, Yearly_Target__c> oldMap){
        List<Id> ytsForTargetUpdateIdList = new List<Id>();
        Decimal newSalesTargetFullQuarter = 0.0;
        Decimal contSalesTargetFullQuarter = 0.0;
        Decimal salesValueTargetFullQuarter =0.0;
        
        for(Yearly_Target__c newYt : newMap.values()){
            Yearly_Target__c oldYt = oldMap.get(newYt.Id);
            if(newYt.Startweek__c != oldYt.Startweek__c || newYt.Full_Year_Continuation_Sales_Target__c != oldYt.Full_Year_Continuation_Sales_Target__c || newYt.Full_Year_New_Sales_Target__c != oldYt.Full_Year_New_Sales_Target__c || newYt.Full_Year_Sales_Value_Target__c != oldYt.Full_Year_Sales_Value_Target__c ){
                ytsForTargetUpdateIdList.add(newYt.Id);
            }
        }

        if(!ytsForTargetUpdateIdList.isEmpty()){
            List<Quarterly_Forecast_Item__c> qfisToUpdate = new List<Quarterly_Forecast_Item__c>();
            List<Weekly_Forecast_Item__c> wfisToUpdate = new List<Weekly_Forecast_Item__c>();

            //Fetch the Sales Target Distribution
            Map<Integer,Double> salesTargetDistMap = SEUtility.getSalesTargetDistributionMap();
            
            //Added by Y.K. For SALEF-919
            Map<Integer,Double> SOHONewSalesTargetDistMap= SEUtility.getSOHONewSalesTargetDistributionMap();
            
            for(Quarterly_Forecast_Item__c qfi : [SELECT Name, Yearly_Target__c, New_Sales_Target__c, Continuation_Sales_Target__c, Sales_Value_Target__c,
                    (SELECT Name, Continuation_Sales_Target__c, New_Sales_Target__c,Sales_Value_Target__c FROM Weekly_Targets__r) 
                    FROM Quarterly_Forecast_Item__c WHERE Yearly_Target__c in :ytsForTargetUpdateIdList]){
                
                Yearly_Target__c yt = newMap.get(qfi.Yearly_Target__c);               
                // If start week is different from 1, we must adjust the quarterly/weekly targets accordingly
                
                 if(SEUtility.isSOHOUser(yt.User__c) == true && SOHONewSalesTargetDistMap != null)    //Changes for SALEF-919
                    {
                       newSalesTargetFullQuarter = yt.Full_Year_New_Sales_Target__c*SOHONewSalesTargetDistMap.get(Integer.valueOf(qfi.Name));
                       contSalesTargetFullQuarter = yt.Full_Year_Continuation_Sales_Target__c*salesTargetDistMap.get(Integer.valueOf(qfi.Name));
                       salesValueTargetFullQuarter = yt.Full_Year_Sales_Value_Target__c*0.25;
                     }
                  else{
                  
                       newSalesTargetFullQuarter = yt.Full_Year_New_Sales_Target__c*salesTargetDistMap.get(Integer.valueOf(qfi.Name));
                       contSalesTargetFullQuarter = yt.Full_Year_Continuation_Sales_Target__c*salesTargetDistMap.get(Integer.valueOf(qfi.Name));
                       salesValueTargetFullQuarter = yt.Full_Year_Sales_Value_Target__c*0.25;
                      }
                

                // These must also be adjusted
                Decimal newSalesWeeklyTarget = newSalesTargetFullQuarter/(qfi.Weekly_Targets__r.size());
                Decimal contSalesWeeklyTarget = contSalesTargetFullQuarter/(qfi.Weekly_Targets__r.size());
                Decimal salesValueWeeklyTarget = salesValueTargetFullQuarter/(qfi.Weekly_Targets__r.size());
                Decimal newSalesTargetQuarterAdjusted = 0.0;
                Decimal contSalesTargetQuarterAdjusted = 0.0;
                Decimal salesValueTargetQuarterAdjusted = 0.0;

                // Only update the weeks that are after the start week set on the årsmål.
                for(Weekly_Forecast_Item__c wfi : qfi.Weekly_Targets__r){
                    if(Integer.valueOf(wfi.Name) >= Integer.valueOf(yt.Startweek__c)){
                        wfi.New_Sales_Target__c = newSalesWeeklyTarget;
                        wfi.Continuation_Sales_Target__c = contSalesWeeklyTarget;
                        wfi.Sales_Value_Target__c = salesValueWeeklyTarget;
                        newSalesTargetQuarterAdjusted += newSalesWeeklyTarget;
                        contSalesTargetQuarterAdjusted += contSalesWeeklyTarget;
                        salesValueTargetQuarterAdjusted +=salesValueWeeklyTarget;
                    } else {
                        wfi.New_Sales_Target__c = 0.0;
                        wfi.Continuation_Sales_Target__c = 0.0;
                        wfi.Sales_Value_Target__c = 0.0;
                    }
                    wfisToUpdate.add(wfi);
                }
                qfi.New_Sales_Target__c = newSalesTargetQuarterAdjusted;
                qfi.Continuation_Sales_Target__c = contSalesTargetQuarterAdjusted;
                qfi.Sales_Value_Target__c = salesValueTargetQuarterAdjusted;
                qfisToUpdate.add(qfi);
            }
            if(!qfisToUpdate.isEmpty()){
                Database.update(qfisToUpdate, false);
            }
            if(!wfisToUpdate.isEmpty()){
                Database.update(wfisToUpdate, false);
            }
        }
    }
}