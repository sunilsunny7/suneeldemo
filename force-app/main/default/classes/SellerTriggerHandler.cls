/**
    About
    -----
    Description: TriggerHandler for the Seller object
    Create date: September 2015
            
    Update History
    --------------
    Created Sep 2015 - A.N added recalculateTargetsForInactivatedSellers method - If seller end date is set or changed on any seller record,
    						the Yearly Targets, Quarterly FI's and Weekly FI's should be updated
    Updated Sep 2016 - A.N Refactored. Deleted method getSellersInactivatedIds, added filtering directly in recalculateTargetsForInactivatedSellers-method
    
    Issues / TODOs
    --------------  
    
*/

public class SellerTriggerHandler {
	
   	/* * * * * * * * * * * * * * * * * * * * * */
	/* * SellerTriggerHandler Trigger Calls  * */
	/* * * * * * * * * * * * * * * * * * * * * */ 

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public SellerTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeUpdate(List<Seller__c> newList, Map<ID, Seller__c> newMap, List<Seller__c> oldList, Map<ID, Seller__c> oldMap){
    	System.debug('SellerTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
  		SellerTemporaryManagerHandler.goBackToOriginalManager(newList, oldMap);
  		SellerTemporaryManagerHandler.updateManagerRole(newList, oldMap);
    }

    public void OnAfterUpdate(List<Seller__c> newList, Map<ID, Seller__c> newMap, List<Seller__c> oldList, Map<ID, Seller__c> oldMap){
    	System.debug('SellerTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
    	
    	recalculateTargetsForInactivatedSellers(newList, newMap, oldMap);

  		if(ytToUpdate.size() > 0){ update ytToUpdate;}
  		if(qfiToUpdate.size() > 0){ update qfiToUpdate;}
  		if(wfiToUpdate.size() > 0){ update wfiToUpdate;}

  		SellerTemporaryManagerHandler.updateTemporaryManageronSeller(newList, oldMap);
  		ManageTwoTeamHandler.manageTwoTeams(newList, oldMap);
    }

    /* * * * * * * * * * * * * * * * * * * * * * */
    /* * SellerTriggerHandler Trigger Methods  * */
    /* * * * * * * * * * * * * * * * * * * * * * */

	// Seller.Type__c Picklist values
	public static final String SELLER_TYPE_SELLER = 'Seller';
	public static final String SELLER_TYPE_SALES_TEAM_MGR = 'Sales Team Manager';
	public static final String SELLER_TYPE_SALES_UNIT_MGR = 'Sales Unit Director';
	public static final String SELLER_TYPE_BUS_UNIT_MGR = 'Business Unit Manager';
	public static final String SELLER_TYPE_BUS_AREA_MGR = 'Business Area Manager';

	private static List<Yearly_Target__c> ytToUpdate;
	private static List<Quarterly_Forecast_Item__c> qfiToUpdate;
	private static List<Weekly_Forecast_Item__c> wfiToUpdate;
	private static Map<Id, Yearly_Target__c> sellerIdYtMap;
	private static Map<Id, List<Quarterly_Forecast_Item__c>> ytIdQfiMap;

    // Author AN september 2015
    // 1. Filters out all Seller records where the end date has been set or changed.
    // 2. Loads the necessary data from the database
    // 3. Updates Yearly Targets, Quarterly FI's and Weekly FI's based on startweek (from the Yearly Target record) and endweek (from the seller record end date)
    private static void recalculateTargetsForInactivatedSellers(List<Seller__c> newList, Map<ID, Seller__c> newMap, Map<ID, Seller__c> oldMap){
		// Filters all Seller records where the end date has been set or changed.
		Set<Id> sellersInactivatedIds = new Set<Id>();
		for(Seller__c s : newList){
			if(s.End_Date__c != null && oldMap.get(s.Id) != null && s.End_Date__c != oldMap.get(s.Id).End_Date__c){
				sellersInactivatedIds.add(s.Id);
			}
		}

		// Update all related Yearly_Target__c, Quarterly_Forecast_Item__c and Weekly_Forecast_Item__c records
		if(sellersInactivatedIds.size() != null){
			loadData(sellersInactivatedIds); // load the necessary data

			// Update the records
			ytToUpdate = new List<Yearly_Target__c>();
			qfiToUpdate = new List<Quarterly_Forecast_Item__c>();
			wfiToUpdate = new List<Weekly_Forecast_Item__c>();

			for(Id sellerId : sellersInactivatedIds){
				Seller__c newSeller = newMap.get(sellerId);
				Yearly_Target__c yt = sellerIdYtMap.get(sellerId);
				if(yt == null) continue;

				Integer startWeek = Integer.valueOf(yt.Startweek__c);
				//if the new end date value is next year or later, set endweek to max value (53)
				Integer endWeek = ( Integer.valueOf(newMap.get(sellerId).End_Date__c.year()) > System.today().year() ? 53 : SEUtility.getWeekNumber(newMap.get(sellerId).End_Date__c));

				// If endweek is less than startweek, do nothing
				if(endWeek >= startWeek){
					List<Quarterly_Forecast_Item__c> qfis = ytIdQfiMap.get(yt.Id);
					// get the weekly target amounts for each quarter. Returns a Map<quarterNumber, List<weeklyTargetNew, WeeklyTargetContinuation>>
					Map<String,List<Double>> weeklyTargets = getWeeklyTargets(qfis, startWeek);
					Double yearlyTargetAmountNew = 0.0;
					Double yearlyTargetAmountContinuation = 0.0;
					
					for(Quarterly_Forecast_Item__c qfi : qfis){
						Double quarterlyTargetAmountNew = 0.0;
						Double quarterlyTargetAmountContinuation = 0.0;
						Double weeklyTargetNew = weeklyTargets.get(qfi.Name)[0];
						Double weeklyTargetContinuation = weeklyTargets.get(qfi.Name)[1];

						for(Weekly_Forecast_Item__c wfi : qfi.Weekly_Targets__r){
							if(Integer.valueOf(wfi.Name) < startweek || Integer.valueOf(wfi.Name) > endWeek){
								wfi.New_Sales_Target__c = 0;
								wfi.Continuation_Sales_Target__c = 0;
								wfi.New_Sales_Commit__c = 0;
								wfi.Continuation_Sales_Commit__c = 0;
							} else {
								wfi.New_Sales_Target__c = weeklyTargetNew;
								wfi.Continuation_Sales_Target__c = weeklyTargetContinuation;
								if(wfi.New_Sales_Commit__c == 0){ wfi.New_Sales_Commit__c = weeklyTargetNew; }
								if(wfi.Continuation_Sales_Commit__c == 0){ wfi.Continuation_Sales_Commit__c = weeklyTargetNew; }
								quarterlyTargetAmountNew += weeklyTargetNew;
								quarterlyTargetAmountContinuation += weeklyTargetContinuation;
							}
							wfiToUpdate.add(wfi);
						}
						qfi.New_Sales_Target__c = quarterlyTargetAmountNew;
						qfi.Continuation_Sales_Target__c = quarterlyTargetAmountContinuation;
						yearlyTargetAmountNew += quarterlyTargetAmountNew;
						yearlyTargetAmountContinuation += quarterlyTargetAmountContinuation;
						qfiToUpdate.add(qfi);
					}
					yt.New_Sales_Target__c = yearlyTargetAmountNew;
					yt.Continuation_Sales_Target__c = yearlyTargetAmountContinuation;
					ytToUpdate.add(yt);
				}
	  		}
		}
	}

	// Author AN september 2015
	// Load all related records. If the Seller has several Yearly Targets, need to find the YT belonging to this year.
	private static void loadData(Set<Id> sellersInactivatedIds){
		String thisYearString = String.valueOf(System.today().year());

		//Load Yearly Target records for this year.
		List<Yearly_Target__c> ytList = [Select Id, Name, Seller__c, Startweek__c, New_Sales_Target__c, Continuation_Sales_Target__c 
										From Yearly_Target__c Where Name = :thisYearString AND Seller__c in :sellersInactivatedIds]; // Get YT for all years for all sellers
		sellerIdYtMap = new Map<Id, Yearly_Target__c>();
		Set<Id> ytIds = new Set<Id>();		
		for(Yearly_Target__c yt : ytList){
			sellerIdYtMap.put(yt.Seller__c, yt);
			ytIds.add(yt.Id);
		}
		//Load quarterly forecst items with weeks and put them in a map with link to the yearly target.
		List<Quarterly_Forecast_Item__c> qfiList = [Select Id, Name, Yearly_Target__c, New_Sales_Target__c, Continuation_Sales_Target__c, 
					(Select Id, Name, New_Sales_Target__c, Continuation_Sales_Target__c, New_Sales_Commit__c, Continuation_Sales_Commit__c 
					From Weekly_Targets__r)
				From Quarterly_Forecast_Item__c Where Yearly_Target__c in :ytIds];
		ytIdQfiMap = new Map<Id, List<Quarterly_Forecast_Item__c>>();
		for(Quarterly_Forecast_Item__c qfi : qfiList){
			List<Quarterly_Forecast_Item__c> qfiTemp = ytIdQfiMap.get(qfi.Yearly_Target__c);
			if(qfiTemp == null){
				qfiTemp = new List<Quarterly_Forecast_Item__c>();
			}
			qfiTemp.add(qfi);
			ytIdQfiMap.put(qfi.Yearly_Target__c, qfiTemp);
		}
	}

	// Author AN september 2015
	// Use start week to calculate the yearly target amounts, then use this to recalculate the weekly target amounts
	// Returns a Map where the key is the quarter number, and the value is a List<weeklyTargetNew, WeeklyTargetContinuation>
	private static Map<String, List<Double>> getWeeklyTargets(List<Quarterly_Forecast_Item__c> qfiList, Integer startWeek){
		Integer quarterNumber = SEUtility.getQuarterNrFromWeek(startWeek);
		Integer year = System.today().year();
		Double yearlyTargetNew = 0.0;
		Double yearlyTargeContinuation = 0.0;
		for(Quarterly_Forecast_Item__c qfi : qfiList){
			if(Integer.valueOf(qfi.name) == quarterNumber){
				for(Weekly_Forecast_Item__c wfi : qfi.Weekly_Targets__r){
					if(Integer.valueOf(wfi.name) == startWeek){
						// We have found the wfi for the start week, use the wfi Sales Targets to recalculate the yearly Targets
						Integer noOfWeeksInQuarter = SEUtility.getWeeksInQuarter(startWeek, year);
						yearlyTargetNew = (wfi.New_Sales_Target__c*noOfWeeksInQuarter)/getSalesTargetDistribution(quarterNumber);
						yearlyTargeContinuation =(wfi.Continuation_Sales_Target__c*noOfWeeksInQuarter)/getSalesTargetDistribution(quarterNumber);
					}
				}
			}
		}

		Map<String, List<Double>> weeklyTargets = new Map<String, List<Double>>();
		for(Quarterly_Forecast_Item__c qfi : qfiList){
			Integer quarterNo = Integer.valueOf(qfi.Name);
			List<Double> tempList = new List<Double>();
			tempList.add((yearlyTargetNew*getSalesTargetDistribution(quarterNo))/SEUtility.getWeeksInQuarter(quarterNo, year));
			tempList.add((yearlyTargeContinuation*getSalesTargetDistribution(quarterNo))/SEUtility.getWeeksInQuarter(quarterNo, year));
			weeklyTargets.put(qfi.Name, tempList);
		}
		return weeklyTargets;
	}

	// Author AN september 2015	
	// If salesTargetDistMap in null, load the map.
	// Return the distribution for the quarter.
	private static Map<Integer,Double> salesTargetDistMap;
	private static Double getSalesTargetDistribution(Integer quarterNo){
	    if(salesTargetDistMap == null){
		    //Fetch the Sales Target Distribution
			salesTargetDistMap = SEUtility.getSalesTargetDistributionMap();
		}
		return salesTargetDistMap.get(quarterNo);
	}
}