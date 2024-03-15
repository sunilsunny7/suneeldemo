/****************************************************************************************************************************
* @author                <shweta.a.hegde@capgemini.com> 
* @maintainedBy
* @version                
* @created                06/12/2021  To track MyB user login date and number of login 
* @modified               <Date>      <what modification>

******************************************************************************************************************************/
global class MCOnline_TrackMyBusinessLogin implements vlocity_cmt.VlocityOpenInterface2 {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        String error_message = ' ';
        try { 
            if(methodName.equalsIgnoreCase('saveUserLogin')) {
                saveUserLogin(inputMap, outMap);
            }
            else {
                result = false;
            }
        }catch(Exception e) {
            result = false;
            error_message = e.getMessage()+' line:'+ e.getLineNumber();
            outMap.put('statusCode', 500);
            outMap.put('Exception', e.getStackTraceString());
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR', inputMap,''));
        }        
        return result;
    }
    
    // Method to Generate Error 
    public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap,String additionalInfo){
        
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        ipInputMap.put('functionality', 'TrackMyBusinessLogin');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        System.debug('errorResponse'+errorResponse);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCOnline_TrackMyBusinessLogin,MCOnline_TrackMyBusinessLogin.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','','');
        if(errorCode == 'INAVALID_TSCID'){
            String message = String.valueOf(errorResponse.get('error'));
            errorResponse.put('error',message+':'+additionalInfo);
        }
        return errorResponse;
    }
    
    private static void saveUserLogin(Map<String,Object> inputMap, Map<String,Object> outMap){
        List<String> tscidList = new List<String>();
        List<Account> tscid_aclst = new List<Account>();
        List<Object> tscidMapList = new List<Object>();
        Map<String,Object> tscIdAccountMap = new Map<String,Object>();
        Boolean invalidTscid = false;
        String incorrectTSCID;
        Set<String> tscidAccount = new Set<String>();
        // get the current date/Time
        DateTime curDate = DateTime.Now();
        tscidMapList = (List<Object>)inputMap.get('organisations');
        // create list of TSCIDs passed in
        for( Object tscidMap : tscidMapList ){
            Map<String,Object> tscidInfo = new Map<String,Object>();
            tscidInfo = (Map<String,Object>)tscidMap;
            tscidList.add(String.valueOf(tscidInfo.get('tscid')));
        }
        // Fetch accounts associated with the TSCIDs passed in
        List<Account> tscidAccountList = [SELECT id,TSCID__c,MCOnline_User_Current_Month_Login_Count__c,MCOnline_User_Last_log_in_Date__c FROM Account Where tscid__c IN : tscidList ];
        for(Account acc: tscidAccountList){
            tscIdAccountMap.put(acc.TSCID__c,acc.id);
        }
        // check if any passed in TSCID does not have account associated with it
        tscidAccount = tscIdAccountMap.keySet();
        for(String tscid : tscidList){
            if(!tscidAccount.contains(tscid)){
                invalidTscid = true;
                incorrectTSCID = tscid;    
                break; 
            }
        }
        // if passed in TSCID does not have associated Account then throw error
        if(invalidTscid){
            String errorCode = 'INAVALID_TSCID';
            outMap.put('ErrorResponse', generateError(errorCode, inputMap,incorrectTSCID));
            outMap.put('statusCode', 400);
        }else{
            // iterate through all the account associated with the TSCIDs passed in
            for(Account acc : tscidAccountList){
                if(acc.MCOnline_User_Last_log_in_Date__c!= Null){
                    // check if Year of the last login is same and month of the last logged in date is less than or equal to month of current date.
                    // if yes then logged in count reset to 1
                    // else if last login year and month equal then count is increaed by 1
                    Boolean sameYearDiffMonth = (acc.MCOnline_User_Last_log_in_Date__c.year() == curDate.year() ) && (acc.MCOnline_User_Last_log_in_Date__c.month()< curDate.month());
                    Boolean diffYearSameOrDiffMonth = acc.MCOnline_User_Last_log_in_Date__c.year() < curDate.year();
                    Boolean sameYearSameMonth  = (acc.MCOnline_User_Last_log_in_Date__c.year()== curDate.year()) && (acc.MCOnline_User_Last_log_in_Date__c.month()== curDate.month());  
                    if(sameYearDiffMonth || diffYearSameOrDiffMonth){
                        acc.MCOnline_User_Current_Month_Login_Count__c = 1;
                    }else if(sameYearSameMonth){
                        acc.MCOnline_User_Current_Month_Login_Count__c = acc.MCOnline_User_Current_Month_Login_Count__c+1;
                    }
                }else{
                    // if last logged in date is null then set the count to 1
                    acc.MCOnline_User_Current_Month_Login_Count__c = 1;
                }
                // set the last logged in date to current date
                acc.MCOnline_User_Last_log_in_Date__c = curDate;            
                tscid_aclst.add(acc);
            }
            // update the record and send response
            update tscid_aclst;
            outMap.put('success',true);
            outMap.put('message','successfully added logging information');
        }
        
    }
}