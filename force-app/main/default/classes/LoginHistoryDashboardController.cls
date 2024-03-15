/**
    About
    -----
    Description: LoginHistoryDashboardController
    Create date: 24-06-2015

    Update History
    --------------
    Created Jun 2015 - C.G - Created
    Updated Jan 2016 - A.N - Updated: Reduced SOQL LIMIT from 50000 to 49000 as the class returned a 'too many query rows' exception. Added an Order by LoginTime Statement
    Updated Jul 2016 - T.S - Updated: Reduced SOQL LIMIT from 49000 to 10000 as the class returned a 'too many query rows' exception. Added an Order by LoginTime Statement

    Issues / TODOs
    --------------  
    NONE
*/

public class LoginHistoryDashboardController {
    List<AppDataWrapper> appList; 
    public Integer nrOfActiveUsers {get;set;}
    
    public List<AppDataWrapper> getAppList(){
        appList = new List<AppDataWrapper>();
        nrOfActiveUsers = [SELECT COUNT() FROM User WHERE IsActive=true AND Profile.Name!='System Administrator'];   
        List<LoginHistory> lhList = [Select UserId,Application, LoginTime FROM LoginHistory WHERE LoginTime=LAST_90_DAYS ORDER BY LoginTime DESC LIMIT 10000];     
        
        //Adding soql to list first because set cannot accept User list as Id set
       
        Set<Id> sysAdmIds = new Map<Id,User>([Select Id FROM User WHERE Profile.Name='System Administrator']).keySet();
        Map<String,Set<Id>> apMap = new Map<String,Set<Id>>(); 
        
        for(LoginHistory lh : lhList){
            // Do not include admins
            if(!sysAdmIds.contains(lh.UserId)){
                if(apMap.containsKey(lh.Application)){
                    apMap.get(lh.Application).add(lh.UserId);
                }
                else{
                    apMap.put(lh.Application, new Set<Id>{lh.UserId});
                }
            }
        }
        
        for(String app : apMap.keySet()){  
            appList.add(new AppDataWrapper(app, apMap.get(app).size(), (Double) apMap.get(app).size()/nrOfActiveUsers*100));
        }
        appList.sort();
        return appList;
    }
    
    public class AppDataWrapper implements Comparable {
        public Integer nrOfUsers {get;set;}
        public String applicationName {get;set;}
        public Double applicationPercentage {get;set;}
        
        public AppDataWrapper(String applicationName, Integer nrOfUsers,Double applicationPercentage){
            this.applicationName = applicationName;
            this.nrOfUsers = nrOfUsers;
            this.applicationPercentage = applicationPercentage;
        }
        
        public Integer compareTo(Object compareTo) {
            AppDataWrapper compareToADW = (AppDataWrapper)compareTo;
            if (nrOfUsers > compareToADW.nrOfUsers) return -1;
            if (nrOfUsers == compareToADW.nrOfUsers) return 0;
            return 1;
        }        
    }
}