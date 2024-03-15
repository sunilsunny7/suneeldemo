/**
    About
    -----
    Description: TriggerHandler for the Revenue object
    Create date: September 2015
            
    Update History
    --------------
    Created Dec 2015 - A.N
    Updated Sep 2016 - A.N Refactored. Cleaned up debug statements
    
    Issues / TODOs
    --------------  
    
*/

public class RevenueTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

	public RevenueTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(List<Revenue__c> newList, Map<ID, Revenue__c> newMap){
    	System.debug('RevenueTriggerHandler.OnAfterInsert start. Number of SOQLs used so far'+Limits.getQueries());
    	updateAccountRevenuePreviousYearYTD(newList);
    }

    public void OnAfterUpdate(List<Revenue__c> newList, Map<ID, Revenue__c> newMap, List<Revenue__c> oldList, Map<ID, Revenue__c> oldMap){
    	System.debug('RevenueTriggerHandler.OnAfterUpdate start. Number of SOQLs used so far'+Limits.getQueries());
    	updateAccountRevenuePreviousYearYTD(newList);
    }

    public void OnAfterDelete(List<Revenue__c> oldList, Map<ID, Revenue__c> oldMap){
    	System.debug('RevenueTriggerHandler.OnAfterDelete start. Number of SOQLs used so far'+Limits.getQueries());
    	updateAccountRevenuePreviousYearYTD(oldList);
    }

    // Author AN:    
    //**Recalculate the field Revenue_YTD_Previous_Year__c on all accounts for which new revenue records have been created/updated/deleted**//
    public static void updateAccountRevenuePreviousYearYTD(List<Revenue__c> revList){    
        Set<Id> accIds = new Set<Id>();
        for(Revenue__c rev : revList){
        	accIds.add(rev.Account__c);
        }

        Integer currentYearInt = System.today().year();
        String currentYear = String.valueOf(currentYearInt);
        String lastYear = String.valueOf(currentYearInt-1);
        List<Account> accList = [SELECT Id, Revenue_YTD_Previous_Year__c, 
        						(SELECT Date__c, RevenueAmount__c, Year__c FROM Intakter__r 
        							WHERE (Year__c = :currentYear OR Year__c = :lastYear) ORDER BY Date__c DESC)
        						FROM Account WHERE Id in : accIds];
        for(Account acc : accList){
        	List<Revenue__c> accRevList = acc.Intakter__r;
        	if(accRevList == null || accRevList.size() == 0){
        		acc.Revenue_YTD_Previous_Year__c = 0;
        	} else {
        		Revenue__c mostRecentRevenue = accRevList[0]; // first element in the list is the newest record this year.
        		if(mostRecentRevenue.Year__c != currentYear){
        			acc.Revenue_YTD_Previous_Year__c = 0;
        		} else {
        			Integer newestMonthThisYear = mostRecentRevenue.Date__c.month();
        			Decimal revenuePreviousYearYTD = 0.0;
        			for(Revenue__c rev : accRevList){
        				if(rev.Year__c == lastYear && rev.Date__c.month() <= newestMonthThisYear){
        					revenuePreviousYearYTD += rev.RevenueAmount__c;
        				}
        			}
        			acc.Revenue_YTD_Previous_Year__c = revenuePreviousYearYTD;
        		}
        	}
        }
        update accList;
    }

}