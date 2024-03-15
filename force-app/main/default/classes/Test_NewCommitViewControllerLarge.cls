/** ***********************Updated Version**************************************************************************************************************
 * Description: NewCommitViewControllerLarge test class (also covered by:
 *  - Test_ManageTwoTeamHandler;
 *  - Test_SellerTemporaryManagerHandler)
 * 
 * Modifications:
 * Updated by S.S - Added test method 'TemporarySalesManagerCommitView' to cover the code coverage for temporary sales manager commit view (Case 1364)
 * 11.04.2023 [Tomass Brazovskis] SALEF-7649 - Introduced testWFIRelatedToExpiredSellerNotCommitted() to test SALEF-7649, and 
 *              testRetrieveSubordinateSellerWFIs() to increase the code coverage.
 **/
@isTest
public class Test_NewCommitViewControllerLarge {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }
    
    @isTest
    static void testCommit(){
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        List<Yearly_Target__c> largeSellerteamYT;
            
        System.runAs(new User(Id = Userinfo.getUserId())){
            // returns list of large users 
            largeUserTeam = Test_DataFactory.createLargeUserTeam(5);
            // returns list of sellers 
            largeSellerTeam = Test_DataFactory.createLargeSellerTeam(largeUserTeam,Date.parse('2015-01-01'));
            // returns list of yearly targets 
            largeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam);
        }

        User salesRep = largeUserTeam[4];
        Id sellerId;
        for(Seller__c s : largeSellerTeam){
            if(s.User__c == salesRep.Id){
                sellerId = s.Id;
            }
        }
        System.runAs(salesRep){  
            NewCommitViewControllerLarge controller = new NewCommitViewControllerLarge();           
            controller.saveJudge();
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved');
       }
    }
    
    @isTest
    static void testCommitAsManager(){
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        List<Yearly_Target__c> largeSellerteamYT;
        List<SelectOption> pageLoadOptions;
        List<SelectOption> secMangerPageLoadOptions;

        System.runAs(new User(Id = Userinfo.getUserId())){
            // returns list of large users 
            largeUserTeam = Test_DataFactory.createLargeUserTeam(5);
            // returns list of sellers 
            largeSellerTeam = Test_DataFactory.createLargeSellerTeam(largeUserTeam,Date.parse('2015-01-01'));
            // returns list of yearly targets 
            largeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam);
            

        }

        User manager = largeUserTeam[3];
        Id sellerId;
        for(Seller__c s : largeSellerTeam){
            if(s.User__c == manager.Id){
                sellerId = s.Id;
            }
        }
        System.runAs(manager){  
            NewCommitViewControllerLarge controller = new NewCommitViewControllerLarge();
            controller.saveJudge();
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved');
       }
    }
    
    @isTest
    static void testTemporarySalesManagerCommitView(){
    
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);
        
        List<User> largeuserTeam;
        List<Seller__c> largesellerteam;
        Id DirectorId,ManagerId,SellerId,largeSellerId;
        Id manageruserid;
        List<Id> listofseller = new List<Id>();

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            largeuserTeam = Test_DataFactory.createLargeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largesellerteam = Test_DataFactory.createLargeSellerTeam(largeuserTeam,startdate);
        }
        
        for(Seller__c s: largesellerteam )
        {
            if(s.Type__c == 'Sales Unit Director')
            {
                DirectorId = s.Id;
            }
            else if(s.Type__c == 'Sales Team Manager')
            {
                ManagerId = s.Id;
                manageruserid = s.User__c;
            }
            else if(s.Type__c == 'Seller')
            {
                SellerId = s.Id;
            }
        }
        
        Seller__c updateManagerSalesTeam = new Seller__c();
        updateManagerSalesTeam.Manage_Other_Team__c = 'Large Enterprise North';
        updateManagerSalesTeam.id = DirectorId;
        Update updateManagerSalesTeam ;
        
        Seller__c temporaryManager = new Seller__c();
        temporaryManager.Manager__c = DirectorId;
        temporaryManager.Type__c = 'Sale Team Manager';
        temporaryManager.Start_Date__c = startDate;
        temporaryManager.User__c = manageruserid;
        insert temporaryManager;
        
        Seller__c sellerastemp = new Seller__c();
        sellerastemp.Manager__c = temporaryManager.id;
        sellerastemp.Type__c = 'Seller';
        sellerastemp.User__c = Userinfo.getUserId();
        sellerastemp.Start_Date__c = startDate;
        insert sellerastemp;
        
        Seller__c temporaryManager1 = new Seller__c();
        temporaryManager1.Temporary_Manager__c = sellerastemp.Id;
        temporaryManager1.Has_Been_Replaced__c = true;
        temporaryManager1.id = temporaryManager.id;
        update temporaryManager1;
        
       
        System.runAs(new User(Id = Userinfo.getUserId())){  
            NewCommitViewControllerLarge controller = new NewCommitViewControllerLarge();
            PageReference commitSaved = controller.saveJudge();
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved');
        }
    }

    /**@Description:
	 * Verify that only commits for WFIs related to the current User's 
     * active Seller are saved.   
     * Modifications:
     *  14.04.2023 [TB] SALEF-7649 - Introduced.
     **/ 
    @isTest
    static void testWFIRelatedToExpiredSellerNotCommitted(){

        Integer thisYear;
        Date startDate;
        Date nextWeekDate;
        String nextWeekString;

        Seller__c largeSellerToExpire;
        Seller__c largeSellerActive;

        User ctxtUser = Test_DataFactory.createAdminUser();
        User largeUser = Test_DataFactory.createLargeUser();
        // Ensures there are no issues due to Date methods
        // returning different values
        ctxtUser.timezonesidkey = largeUser.timezonesidkey;
        List<User> lstUsers = new List<User>{ctxtUser, largeUser};
        System.runAs(new User(Id = Userinfo.getUserId())){
            insert lstUsers;
        }

        Test.startTest();
        System.runAs(ctxtUser){
            thisYear = System.today().year();
            nextWeekDate = System.today() + 7;
            nextWeekString = SEUtility.getWeekNumberAsString(nextWeekDate);
            // Construct a Large Team Seller to be inactivated 
            largeSellerToExpire = Test_DataFactory.createBusinessAreaManagerSeller(largeUser.id);
            insert largeSellerToExpire;
            // Create a Yearly Target with the initial Seller still being active
            Yearly_Target__c ytToInsert = Test_DataFactory.createOneYearlyTarget(largeSellerToExpire);
            insert ytToInsert;
            // Deactivate the Seller
            largeSellerToExpire.Start_Date__c = System.today().addDays(-3);
            largeSellerToExpire.End_Date__c = System.today().addDays(-2);
            update largeSellerToExpire;
            // Create a new Seller and an associated Yearly Target
            largeSellerActive = Test_DataFactory.createBusinessAreaManagerSeller(largeUser.id);
            insert largeSellerActive;
            ytToInsert = Test_DataFactory.createOneYearlyTarget(largeSellerActive);
            insert ytToInsert;
        }
        Test.stopTest();

        // Switch to the Large User ctxt to interact with the VF page controller 
        System.runAs(largeUser){
            NewCommitViewControllerLarge controller = new NewCommitViewControllerLarge();
            PageReference commitSaved = controller.saveJudge();
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved');
        }

        // Each YT insertions should have triggered a creation of corresponding WFI records
        List<Weekly_Forecast_Item__c> lstCurrentUserWFIs = [SELECT Id, Seller__c, Name, Comitted_on__c 
                                                            FROM Weekly_Forecast_Item__c 
                                                            WHERE User__c = :largeUser.Id 
                                                            AND Name = :nextWeekString
        ];

        System.assertEquals(lstCurrentUserWFIs.size(), 2, 'Each User Seller should have had a WFI for the next week.');

        for(Weekly_Forecast_Item__c curWFI : lstCurrentUserWFIs){
            if(curWFI.Seller__c != largeSellerActive.id){
                System.assertEquals(null, curWFI.Comitted_on__c,
                                    'WFIs related to expired Seller records should not be commited');
            } else{
                System.assertNotEquals( null, curWFI.Comitted_on__c,
                                        'WFIs related to active Seller records should be commited');
            }
        }
    }


    /**@Description:
	 * Verify controller getWeekInstances() method returns subWeeks (WFIs)
     * of the Sellers managed by the context User.   
     * Modifications:
     *  14.04.2023 [TB] SALEF-7649 - Introduced.
     **/ 
    @isTest
    static void testRetrieveSubordinateSellerWFIs(){

        Integer thisYear;
        Date startDate;
        User ctxtUser = Test_DataFactory.createAdminUser();
        User teamBusinessAreaManagerUser;
        User teamManagerUser;

        // Ensures there are no issues caused by Date methods
        // returning different values.
        ctxtUser.timezonesidkey = Test_DataFactory.createLargeUser().timezonesidkey;
        List<User> lstUsers = new List<User>{ctxtUser};
        System.runAs(new User(Id = Userinfo.getUserId())){
            insert lstUsers;
        }

        Test.startTest();
        System.runAs(ctxtUser){
            thisYear = System.today().year();
            startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);
            // Construct a list of Large users {BUM, BAM, SalesUnitManager, SalesTeamManager, Seller}
            List<User> lstUsersOfLargeUserTeam = Test_DataFactory.createLargeUserTeam();
            // Construct a list of Large Team Sellers {BUM, BAM, SalesUnitManager, SalesTeamManager, Seller}
            List<Seller__c> lstSellersOfLargeSellerTeam = Test_DataFactory.createLargeSellerTeam(lstUsersOfLargeUserTeam, startDate);
            // Create Yearly Targets for each Large Team Seller
            Test_DataFactory.createYearlyTargetsSellerTeam(lstSellersOfLargeSellerTeam);
            // Use BAM for increased test class coverage, but switch to
            // Sales Team Manager in case of some organization hierarchy changes
            teamBusinessAreaManagerUser = lstUsersOfLargeUserTeam[0];
            teamManagerUser = lstUsersOfLargeUserTeam[3];
        }
        Test.stopTest();

        String weekInstancesListJSON;
        // Switch to Business Area Manager User ctxt to interact with the VF page controller 
        System.runAs(teamBusinessAreaManagerUser){
            NewCommitViewControllerLarge controller = new NewCommitViewControllerLarge();
            weekInstancesListJSON = controller.getWeekInstances();
        }
        List<NewCommitViewControllerLarge.Week> lstManagerWeeks = (List<NewCommitViewControllerLarge.Week>) JSON.deserialize(
            weekInstancesListJSON, 
            List<NewCommitViewControllerLarge.Week>.class);
        System.assert(  !lstManagerWeeks.isEmpty(),
                        'Sales Team Manager was expected to have a current Week instance');
        System.assert(  !lstManagerWeeks[0].subWeeks.isEmpty(),
                        'Sales Team Manager\'s current Week instance was expected to contain'
                        + ' subordinate\'s current Week in its "subweek" attribute');

    }
}