/**
    About
    -----
    Description: Utility class for handling operations related to creation and updates of Yearly Target records.

    Created August 2015 - C.G
   
    Update History
    --------------
    History for this class missing before february 2016
    Updated Feb 2016 - A.N - Adjusted methods for updating values so that they reference the Full_Year_New_Sales_Target__c/Full_Year_Continuation_Sales_Target__c
    Updated Apr 2016 - P.P - Addition of Sales Value Target Division in Quarterly and Weekly Forecasts
    Updated Sep 2016 - A.N - Refactored: Minor code changes only, no functional changes made. Cleaned up in comments/debug statements

    Issues / TODOs
    --------------  
*/


public class YearlyTargetUtil {
    
    // These constants are used as keys in the map that is returned by the method calculateQuartersAndWeeks(Yearly_Target__c)
    public static final String NEWSALES = 'NEW_SALES_TARGET';
    public static final String CONSALES = 'CONTINUATION_SALES_TARGET';
    public static final String SALESVALUE = 'SALES_VALUE_TARGET';
    
    // Method that for a year (the argument) will return the new yearly targets based on the start week
    public static Map<String, Decimal> calculateQuartersAndWeeks(Yearly_Target__c year){
        
        //Fetch the Sales Target Distribution
        Map<Integer,Double> salesTargetDistMap = SEUtility.getSalesTargetDistributionMap();
        
        //*** CREATE QUARTERS ***
        //Figure out the quarter start date and end dates
        Map<Integer,Map<Date,Date>> quarterMap = SEUtility.getTeliaQuarterStartAndEndDates(Integer.valueOf(year.Name));
            
        List<Quarterly_Forecast_Item__c> qfiList = new List<Quarterly_Forecast_Item__c>();
        // Create quarters for the year
        for(Integer i : quarterMap.keySet()){
            for(Date d : quarterMap.get(i).keySet()){
                qfiList.add(new Quarterly_Forecast_Item__c(
                    Name=String.valueOf(i),
                    User__c = year.User__c, 
                    Start_Date__c = d, 
                    End_Date__c = quarterMap.get(i).get(d),
                    New_Sales_Target__c = year.Full_Year_New_Sales_Target__c*salesTargetDistMap.get(i),
                    Continuation_Sales_Target__c = year.Full_Year_Continuation_Sales_Target__c*salesTargetDistMap.get(i),
                    Sales_Value_Target__c = year.Full_Year_Sales_Value_Target__c*0.25,
                    Yearly_Target__c=year.Id,
                    Belongs_To_Year__c=Integer.valueOf(year.Name))
                );
            }
        }        
        
        // Map with the quarter name as the key and the weeks of the quarter as values
        Map<String,Set<Weekly_Forecast_Item__c>> quarterNameToWFIMap = new Map<String,Set<Weekly_Forecast_Item__c>>();
        
        // *** CREATE WEEKS ***         
        for(Quarterly_Forecast_Item__c qfi : qfiList){ 
            Set<Weekly_Forecast_Item__c> tempWfiSet = new Set<Weekly_Forecast_Item__c>();
            tempWfiSet.addAll(YearlyTargetUtil.getWeeks(Integer.valueOf(qfi.Belongs_To_Year__c),
                                            qfi.Name,
                                            qfi.New_Sales_Target__c,
                                            qfi.Continuation_Sales_Target__c,
                                            qfi.Sales_Value_Target__c,                                          
                                            qfi.Start_Date__c,  
                                            qfi.End_Date__c));
            quarterNameToWFIMap.put(qfi.Name, tempWfiSet);
        }

        // Accumulator variables to sum the new sales targer and continutation sales target used when start week != 1 
        Decimal newSalesYearAcc = 0.0;
        Decimal conSalesYearAcc = 0.0;
        Decimal salesValueYearAcc = 0.0;    
        
        // If the start week is not 1 - the weeks before the start week must be zeroed
        if(Integer.valueOf(year.Startweek__c) != 1){
            for(Quarterly_Forecast_Item__c qfi : qfiList){
                Decimal newSalesQuarterAcc = 0.0;
                Decimal conSalesQuarterAcc = 0.0;
                Decimal salesValueQuarterAcc = 0.0;
                for(Weekly_Forecast_Item__c wfi : quarterNameToWFIMap.get(qfi.Name)){
                    if(Integer.valueOf(wfi.Name) >= Integer.valueOf(year.Startweek__c)){
                        newSalesQuarterAcc += wfi.New_Sales_Target__c;
                        conSalesQuarterAcc += wfi.Continuation_Sales_Target__c;
                        salesValueQuarterAcc += wfi.Sales_Value_Target__c;
                    }
                }
                newSalesYearAcc += newSalesQuarterAcc;
                conSalesYearAcc += conSalesQuarterAcc;
                salesValueYearAcc += salesValueQuarterAcc;
            }
        }

        // Create a map and set the new targets with the help of the constants in this class. Then return
        Map<String, Decimal> returnMap = new Map<String,Decimal>();
        returnMap.put(NEWSALES, newSalesYearAcc);
        returnMap.put(CONSALES, conSalesYearAcc);
        returnMap.put(SALESVALUE,salesValueYearAcc);
        return returnMap;  
    }
    
    // Returns a list of week records based on year and quarter (with no references to any parent quarterly_forecast_item record(records)
    public static List<Weekly_Forecast_Item__c> getTeliaWeeks(Integer year, String quarterName, Date startDate, Date endDate){
        Boolean fiftyThreeWeekYear = SEUtility.isFiftyThreeWeekYear(year);
        
        Integer startWeekNumber;
        if(Integer.valueOf(quarterName) == 1){ 
            startWeekNumber = 1; 
        } else { 
            startWeekNumber = SEUtility.getWeekNumber(startDate); 
        }
        
        Integer endWeekNumber;
        if(fiftyThreeWeekYear && Integer.valueOf(quarterName)==4){ 
            endWeekNumber = 53; 
        } else { 
            endWeekNumber = SEUtility.getWeekNumber(endDate); 
        }

        // Create the list that shall be returned
        List<Weekly_Forecast_Item__c> wfiList = new List<Weekly_Forecast_Item__c>();
        
        Date dynamicStartDate = startDate;
        Date dynamicEndDate = startDate.addDays(6); 
        for(Integer i = startWeekNumber; i<=endWeekNumber; i++){
            System.debug('Adding week for startdate: '+dynamicStartDate+'->'+dynamicEndDate);
            
            // If the week number is 1 -> 9 then add a zero before the weeknumber (string). This gives a proper sorting of weeks in reports
            if(i > 0 && i < 10){
                wfiList.add(new Weekly_Forecast_Item__c(Name='0'+String.valueOf(i), Start_Date__c = dynamicStartDate, End_Date__c=dynamicEndDate));    
            } else {
                wfiList.add(new Weekly_Forecast_Item__c(Name=String.valueOf(i), Start_Date__c = dynamicStartDate, End_Date__c=dynamicEndDate));    
            }
            dynamicStartDate = dynamicStartDate.addDays(7);
            dynamicEndDate = dynamicEndDate.addDays(7);
        }
        return wfiList;
    }
    
    // Returns a list of all weekly_forecast_item records for a quarterly_forecast_item    
    public static List<Weekly_Forecast_Item__c> getWeeks(Integer year, String quarterName, Decimal quarterNewSalesTarget, Decimal quarterContinuationSalesTarget, Decimal quarterSalesValueTarget, Date startDate, Date endDate){
        List<Weekly_Forecast_Item__c> wfiList = getTeliaWeeks(year, quarterName, startDate,endDate);
        Decimal qnsSplit = quarterNewSalesTarget/wfiList.size();
        Decimal qcsSplit = quarterContinuationSalesTarget/wfiList.size();
        Decimal qsvSplit = quarterSalesValueTarget/wfiList.size();

        for(Weekly_Forecast_Item__c wfi : wfiList){
            wfi.New_Sales_Target__c = qnsSplit;
            wfi.Continuation_Sales_Target__c = qcsSplit;
            wfi.Sales_Value_Target__c = qsvSplit;
        }
        return wfiList;
    }
}