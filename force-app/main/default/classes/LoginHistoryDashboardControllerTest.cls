@isTest
public class LoginHistoryDashboardControllerTest {
    @isTest(SeeAllData=false)
    static void testLoginHistory(){
        User sysAdm = Test_DataFactory.createAdminUser();
        User srUser = Test_DataFactory.createSalesRepUsers(1).get(0);
   	
        System.runAs(sysAdm){
            LoginHistoryDashboardController lhdc = new LoginHistoryDashboardController();
            List<LoginHistoryDashboardController.AppDataWrapper> adwList = lhdc.getAppList();
            for(Integer i=0; i<adwList.size(); i++){
                System.debug('ApplicationName: '+adwList.get(i).applicationName);
                System.debug('NrOfUsers: '+adwList.get(i).nrOfUsers);
            }
        	
        }
        
    }
}