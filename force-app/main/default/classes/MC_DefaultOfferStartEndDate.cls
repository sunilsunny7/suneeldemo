/***************************************************************************************************************************************************************************
 * Author: Vamsi D
 * Date Created: 25/4/2023
 * Functionality: This class uses data from QuotelineItem agreement offerings and MC_Agreement_Offerings_Min_Max_Date__mdt to give Start and End Dates for products. 
 * Invoked from: Integration Procedure MassCustomized_CreateSA.
***************************************************************************************************************************************************************************/
global class MC_DefaultOfferStartEndDate implements vlocity_cmt.VlocityOpenInterface{
    // BusinessHours is a Standard object which stores default working hours in a week
    global static BusinessHours bh = [SELECT Id, Name, IsDefault, IsActive From BusinessHours WHERE IsDefault = true ];
    // Holidays is a standard object which we can define custom holidays in org. Task done by maintanance team as a onetime yealy activity.
    global static List<Holiday> holidays = new List<Holiday>([Select Id,ActivityDate,Name from Holiday order by ActivityDate]);
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('SelectProducts')) {                
                selectProducts(inputMap, outMap);
            }else {
                result = false;
            } 
        }catch(Exception e) {          
            result = false;
            System.debug('Exception-->'+e.getStackTraceString());
            System.debug('Exception-->'+e);
        }        
        return result;
    }
    public static void selectProducts(Map<String,Object> inputMap, Map<String,Object> outMap){
        Boolean isMobile = false;
        Integer mobileDiffDate;
        String holidayString = '';
        List<Object> quoteLines = (List<Object>)inputMap.get('Quote');
        List<Object> quoteLinesoutput = new List<Object>();
        List<Object> finalList = new List<Object>();
        for(Holiday h : holidays){
            Date temp = h.ActivityDate;
            Date tempDate = Date.newInstance(temp.year(), temp.month(), temp.day());
            // converting holidays in format yyyy-mm-dd
            if(holidayString == '' || holidayString == null){
                holidayString = String.valueof(tempDate);
            }
            else{
                holidayString = holidayString+','+String.valueof(tempDate);
            }
        }
        // getting default Dates that were stored in metadata and making it as map for convience of usage
        Map<String, MC_Agreement_Offerings_Min_Max_Date__mdt> defaultStartDatesMap = MC_Agreement_Offerings_Min_Max_Date__mdt.getAll();
        for(object obj : quoteLines){
            Date maxStartTime,minEndTime,maxEndTime,minStartTime = Date.today();
            integer minStart,maxStart,addmonths;
            String cmtPeriod;
            Map<String,Object> eachLineItem = (Map<String,Object>)obj;
            // fetch either commitment period or binding period based on product configuration as priority given to commitment period.
            if(eachLineItem.get('CommitmentPeriod') != null){
                cmtPeriod = String.valueOf(eachLineItem.get('CommitmentPeriod'));
            }
            else if (eachLineItem.get('BindingPeriod') != null){
                cmtPeriod = String.valueOf(eachLineItem.get('BindingPeriod'));
            }
            // match objecttypes from Qli and get minStart and max Start in no. of days
            String objectType = String.valueOf(eachLineItem.get('Product_ObjectType')).replaceAll('[-,/," "]', '_');
            if(defaultStartDatesMap.keySet().contains(objectType)){
                MC_Agreement_Offerings_Min_Max_Date__mdt offerStartDates = new MC_Agreement_Offerings_Min_Max_Date__mdt();
                offerStartDates = defaultStartDatesMap.get(objectType);
                minStart = (Integer)offerStartDates.Minimum_StartDate__c+1;
                maxStart = (Integer)offerStartDates.Maximum_StartDate__c+1;
            }else{
                minStart = 6;
                maxStart = 91;
            }
            
            if(String.valueOf(eachLineItem.get('Product_ObjectType')) == 'ITDaaS Offer Spec'){                
                String productCode = String.valueOf(eachLineItem.get('Product_ObjectType')) +' '+String.valueOf(eachLineItem.get('ProductCode'));  
                if(defaultStartDatesMap.keySet().contains(productCode.replaceAll(' ', '_'))){                    
                    MC_Agreement_Offerings_Min_Max_Date__mdt offerStartDates = new MC_Agreement_Offerings_Min_Max_Date__mdt();
                    
                    offerStartDates = defaultStartDatesMap.get(productCode.replaceAll(' ', '_'));
                    minStart = (Integer)offerStartDates.Minimum_StartDate__c;
                    maxStart = (Integer)offerStartDates.Maximum_StartDate__c;
                    
                }
                
            }
            // for smart connect get the ramaining days for mobile to select minimum start date for smart connect
            // if mobile negotaited and if we do andra and add smart connect. then minimum start date will be selected according to mobile start date
            if(String.valueOf(eachLineItem.get('Product_ObjectType')) == 'Mobile Offer Specification'){
                isMobile = true;                
                if(eachLineItem.get('StartDate') != null){
                    Date startdate = Date.valueOf(eachLineItem.get('StartDate'));       
                    if(startdate > Date.today() ){
                        mobileDiffDate = (system.today()).daysBetween(startdate);
                        mobileDiffDate -= ((integer)Math.floor((mobileDiffDate / 7)) * 2);
                        Integer d = startdate.day();
                        Integer mo = startdate.month();
                        Integer yr = startdate.year();
                        DateTime tempDateTime = DateTime.newInstance(yr, mo, d, 0, 0, 0);
                        if (tempDateTime.format('E') != 'Sat') {
                            mobileDiffDate -= 1;
                        } else if (tempDateTime.format('E') != 'Sun') {
                         mobileDiffDate -= 2;
                        }
                    } 
                }else{mobileDiffDate = minStart;}
            }
            // calulate minStartDate exclute all week ends and holidays in between. 
            // Calulate minEndDate based on minStartdate and commitmentperiod. And Enddate cannot be a holiday or weekend.            
            if(minStart != null){
				if(String.valueOf(eachLineItem.get('Product_ObjectType')) == 'ITDaaS Offer Spec')
                {
					minStartTime = Date.today()+ minStart;
					minStartTime = removeHolidaysandWeekends(minStartTime);
                }else{
					minStartTime = calculateMinimumStartDate(minStart);
				}
                eachLineItem.put('minStartTime',Date.newInstance(minStartTime.year(), minStartTime.month(), minStartTime.day()));
                minEndTime = getEndDate(cmtPeriod,minStartTime);
				eachLineItem.put('minEndTime',Date.newInstance(minEndTime.year(), minEndTime.month(), minEndTime.day()));
            }
            // Calulate maxStarttime and maxEndDate based on minStartdate and commitmentperiod. And finaldate cannot be a holiday or weekend.
            if(maxStart != null && minStart != null){
                maxStartTime = removeHolidaysandWeekends(minStartTime.addDays(maxStart));
                eachLineItem.put('maxStartTime',Date.newInstance(maxStartTime.year(), maxStartTime.month(), maxStartTime.day()));
                maxEndTime = getEndDate(cmtPeriod,maxStartTime);
                if(cmtPeriod.contains('Uncommitted')){
                   // maxEndTime = maxEndTime.addYears(100);
                   eachLineItem.put('maxEndTime',Date.newInstance(maxEndTime.year(), maxEndTime.month(), maxEndTime.day()).addYears(100));
				}else{
                    eachLineItem.put('maxEndTime',Date.newInstance(maxEndTime.year(), maxEndTime.month(), maxEndTime.day()));
                }
            }                      
            eachLineItem.put('minStart',minStart);
            eachLineItem.put('maxStart',maxStart);
            quoteLinesoutput.add(eachLineItem);
        }
        // iterating once more for products that depend on mobile
        for(object obj : quoteLinesoutput){
            Date maxStartTime,minEndTime,maxEndTime,minStartTime = Date.today();
            integer minStart,maxStart,addmonths;
            String cmtPeriod;
            Map<String,Object> eachLineItem = (Map<String,Object>)obj;
            if(eachLineItem.get('maxStart') != null){
                maxStart = (Integer)eachLineItem.get('maxStart');
            }
            if(eachLineItem.get('CommitmentPeriod') != null){
                cmtPeriod = String.valueOf(eachLineItem.get('CommitmentPeriod'));
            }else if (eachLineItem.get('BindingPeriod') != null){
                cmtPeriod = String.valueOf(eachLineItem.get('BindingPeriod'));
            } else {
                cmtPeriod = '0';
            }
            // for smart connect calculate start date and enddate based on result from code line: 75 to 90
            if(isMobile && eachLineItem.get('Product_ObjectType') == 'Smart Connect Offer Spec') {
                if(mobileDiffDate > 5){
                    minStart = mobileDiffDate;
                }else{
                    minStart = 6;
                }
                minStartTime = calculateMinimumStartDate(minStart);
                eachLineItem.put('minStartTime',Date.newInstance(minStartTime.year(), minStartTime.month(), minStartTime.day()));
                minEndTime = getEndDate(cmtPeriod,minStartTime);
                eachLineItem.put('minEndTime',Date.newInstance(minEndTime.year(), minEndTime.month(), minEndTime.day()));           
            }
            if(maxStart != null && minStartTime != null){
				
                maxStartTime = minStartTime.addDays(maxStart);
				eachLineItem.put('maxStartTime',Date.newInstance(maxStartTime.year(), maxStartTime.month(), maxStartTime.day()));
                maxEndTime = getEndDate(cmtPeriod,maxStartTime);
                 if(cmtPeriod.contains('Uncommitted')){
                   // maxEndTime = maxEndTime.addYears(100);
                    eachLineItem.put('maxEndTime',Date.newInstance(maxEndTime.year(), maxEndTime.month(), maxEndTime.day()).addYears(100));
				}else{
                    eachLineItem.put('maxEndTime',Date.newInstance(maxEndTime.year(), maxEndTime.month(), maxEndTime.day()));
                }
            }
            eachLineItem.put('holidayString',holidayString);
            finalList.add(eachLineItem);            
        }        
        outMap.put('QuoteLines',finalList);  
        outMap.put('holidayString',holidayString);
    }
    // calulates minimum Start Date and removes any holidays or weekends in between
    public static Date calculateMinimumStartDate(Integer minStart){
        integer var= 10; 
        integer div = minStart/var;
        integer rem = Math.Mod(minStart, var);
        DateTime minStartTime = System.now();
        // working days is calulated and added in intervalinMillseconds using BusinessHours.
        // To get it in intervalinMillseconds, diving minStart days by 10 and repeating the days until variable div
        while(div != 0){  
            Long intervalinMillseconds = var*8*60*60*1000;
            minStartTime = BusinessHours.add(bh.Id, minStartTime, intervalinMillseconds); 
            div = div-1;
        }
        // add remaining days
        if(rem != 0){
            Long intervalinMillseconds = rem*8*60*60*1000;
            minStartTime = BusinessHours.add(bh.Id, minStartTime, intervalinMillseconds);
        }
        // remove holidays and if new date is in weekend take next day
        for(Holiday h : holidays){
            Date temp = h.ActivityDate;
            Integer d = temp.day();
            Integer mo = temp.month();
            Integer yr = temp.year();
            DateTime holidayDateTime = DateTime.newInstance(yr, mo, d, 0, 0, 0);
            if(System.now() >= holidayDateTime && holidayDateTime <= minStartTime){
                Boolean holidayHoursDt = BusinessHours.isWithin(bh.Id, holidayDateTime);
                while(holidayHoursDt || minStartTime.format('E') == 'SAT' || minStartTime.format('E') == 'SUN'){
                    minStartTime.addDays(1);
                }
            }
        }
        Date d = Date.newInstance(minStartTime.year(), minStartTime.month(), minStartTime.day());
        return d;
    }
    // Calulated enddate based on commitment period and start date
    public static Date getEndDate(String cmtPeriod, Date startDate){ 
        Integer addmonths;
        Date EndTime;
        DateTime tempDateTime;
        if(cmtPeriod.contains('12')){
            addmonths = 12;
        }else if(cmtPeriod.contains('24')){
            addmonths = 24;
        }else if(cmtPeriod.contains('36')){
            addmonths = 36;                
        }else if(cmtPeriod.contains('1')){
            addmonths = 1;
        }else {
            addmonths = 0;
        }
        return removeHolidaysandWeekends(startDate.addMonths(addmonths));
    }
    //Checks if date is a holiday or weekend and gives calculated next working day
    public static Date removeHolidaysandWeekends(Date startDate){
        DateTime tempDateTime;
        tempDateTime = (DateTime)startDate;
		
        List<Date> holidayDateTimeList = new List<Date>();
        for(Holiday h : holidays){
            Date temp = h.ActivityDate;
            Integer d = temp.day();
            Integer mo = temp.month();
            Integer yr = temp.year();
            Date holidayDate = Date.newInstance(yr, mo, d);
            holidayDateTimeList.add(holidayDate);
        }
        while(holidayDateTimeList.contains(startDate) || tempDateTime.format('E') == 'Sat' || tempDateTime.format('E') == 'Sun'){
            startDate += 1;
            tempDateTime = (DateTime)startDate;
        }
        return startDate;
    }
}