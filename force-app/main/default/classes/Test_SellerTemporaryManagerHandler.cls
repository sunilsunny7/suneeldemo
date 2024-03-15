//******************************************************************************************************************************
// Name             : Test_SellerTemporaryManagerHandler.cls         
// Created By       : S.S
// Description      : Covers the code coverage of 'SellerTemporaryManagerHandler' Class
// *****************************************************************************************************************************

@isTest
public class Test_SellerTemporaryManagerHandler {

    @testSetup
    static void initTestData() 
    {
        Test_DataFactory.setUpOrg();
    }

    @isTest static void testSetTemporaryManager(){
    
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);    
        
        List<Seller__c> largesellerteam;
        test.starttest();
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            List<User> largeuserTeam = Test_DataFactory.createLargeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largesellerteam = Test_DataFactory.createLargeSellerTeam(largeuserTeam,startdate);
        }

        // largesellerteam[3] should be team manager and largesellerteam[4] should be the seller
        System.assertEquals(largesellerteam[3].Type__c, SellerTriggerHandler.SELLER_TYPE_SALES_TEAM_MGR, 'The Seller should have type Sales Team Manager');
        System.assertEquals(largesellerteam[4].Type__c, SellerTriggerHandler.SELLER_TYPE_SELLER, 'The Seller should have type Seller');
        // Fetching the team manager/seller
        Seller__c teamManager = largesellerteam[3];
        Seller__c seller = largesellerteam[4];

        // Fetch the User Role Id's of the seller/team manager 
        Seller__c tempSeller = [SELECT Id, User__r.UserRoleId FROM Seller__c  WHERE Id = :seller.Id LIMIT 1];
        String originalSellerRoleId = tempSeller.User__r.UserRoleId;        
        Seller__c tempTeamMgr = [SELECT Id, User__r.UserRoleId FROM Seller__c  WHERE Id = :teamManager.Id LIMIT 1];
        String originalManagerRoleId = tempTeamMgr.User__r.UserRoleId;

        // Verfiy temp manager fields on seller is blank/null
        System.assertEquals(seller.Is_Temporary_Manager__c, false, 'Seller should not be temp manager');
        System.assertEquals(seller.Replaced_Manager_Lookup__c, null, 'Seller should not have temp manager assigned');
        System.assertEquals(seller.Temporary_Manager_Old_Role_Id__c, null, 'Temp manager role id should be blank');

        // Make the seller a temporary manager by updating Temporary Manager field on the Sales Team Manager seller record
        teamManager.Temporary_Manager__c = seller.Id;
        teamManager.Has_Been_Replaced__c = true;
        update teamManager;
        
        // Verify the seller (now a temporary manager) has been correctly updated
        Seller__c tempManagerSeller = [SELECT Id, Is_Temporary_Manager__c, Replaced_Manager_Lookup__c, User__r.UserRoleId, Temporary_Manager_Old_Role_Id__c FROM Seller__c WHERE Id = :seller.Id LIMIT 1];
        System.assertEquals(tempManagerSeller.Is_Temporary_Manager__c, true, 'Seller should be temp manager');
        System.assertEquals(tempManagerSeller.Replaced_Manager_Lookup__c, teamManager.Id, 'Seller should be temp manager for the specified manager');
        System.assertEquals(tempManagerSeller.Temporary_Manager_Old_Role_Id__c, originalSellerRoleId, 'Temp manager role id should not be blank');
        System.assertEquals(tempManagerSeller.User__r.UserRoleId, originalManagerRoleId, 'Temp managers User Role should be updated');
        test.stoptest();
        // Verify the replaced manager has been correctly updated
        Seller__c replacedManagerSeller = [SELECT Id, Has_Been_Replaced__c, Temporary_Manager__c, User__r.UserRoleId, Temporary_Manager_Old_Role_Id__c FROM Seller__c WHERE Id = :teamManager.Id LIMIT 1];
        System.assertEquals(replacedManagerSeller.Has_Been_Replaced__c, true, 'Manager Seller Has_Been_Replaced__c should be checked ');
        System.assertEquals(replacedManagerSeller.Temporary_Manager__c, tempManagerSeller.Id, 'Manager Seller should have temporary manager set');
        System.assertEquals(replacedManagerSeller.Temporary_Manager_Old_Role_Id__c, originalManagerRoleId, 'Replaced manager old role should be the original manager role');
        System.assertEquals(replacedManagerSeller.User__r.UserRoleId, originalSellerRoleId, 'Replaced managers User Role should now be that of a team member');        
    }

    @isTest static void testTemporaryManagerCommitOpportunities(){
    
     
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);
        Date nextWeekDate = System.today() + 7;
        String nextWeekString = SEUtility.getWeekNumberAsString(nextWeekDate);
        
        List<Seller__c> largesellerteam;
        User teamManageruser;
        User selleruser;
        Seller__c teamManager;
        Seller__c seller;
        Account accTeamManager;
        Account accSeller;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {BUM, BAM, SalesUnitManager, SalesTeamManager, Seller}
            List<User> largeuserTeam = Test_DataFactory.createLargeUserTeam();
            // returns list of sellers {BUM, BAM, SalesUnitManager, SalesTeamManager, Seller}
            largesellerteam = Test_DataFactory.createLargeSellerTeam(largeuserTeam,startdate);
            Test_DataFactory.createYearlyTargetsSellerTeam(largesellerteam);
            
            // Fetching the team manager/seller (largesellerteam[3] is the team manager and largesellerteam[4] is the seller)
            teamManageruser = largeuserTeam[3];
            selleruser = largeuserTeam[4];
            teamManager = largesellerteam[3];
            seller = largesellerteam[4];
            
            test.starttest();
            // Create accounts for team manager/seller
            List<Account> accs = new List<Account>();
            accTeamManager = Test_DataFactory.createOneLargeStandardAccount();
            accTeamManager.OwnerId = teamManageruser.Id;
            accs.add(accTeamManager);
            accSeller = Test_DataFactory.createOneLargeStandardAccount();
            accSeller.OwnerId = selleruser.Id;
            accs.add(accSeller);
            insert accs;
        }

        // create opp as Seller
        Opportunity oppSeller;
        System.runAs(selleruser){
            oppSeller = Test_DataFactory.createLargeOpportunity();
            oppSeller.AccountId = accSeller.Id;
            oppSeller.CloseDate = nextWeekDate; // make sure close date is next week!
            insert oppSeller;
        }

        // Go into Commit View as Seller. RadioValue should not be set. (The seller can only see his opportunities in commit view)
        System.runAs(selleruser){  
            NewCommitViewControllerLarge controller = new NewCommitViewControllerLarge();
            System.assertEquals(controller.radioValue, null, 'Only own view should be visible for the seller.');
        }

        // Make the seller a temporary manager by updating Temporary Manager field on the Sales Team Manager seller record
        teamManager.Temporary_Manager__c = largesellerteam[4].Id;
        teamManager.Has_Been_Replaced__c = true;
        update teamManager;

        // Go into Commit View as Seller which is now a Temp Manager. (The seller can see his opportunities in commit view or for the whole team)
        // Default view should be Team view. When doing commit it should be commited as the Team Manager.
        System.runAs(selleruser){
            NewCommitViewControllerLarge controller = new NewCommitViewControllerLarge();
            System.assertEquals(controller.radioValue, 'SecondaryUserView', 'Default view for temp manager should be team view.');
            PageReference commitSaved = controller.saveJudge();
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved as Team Manager');
        }

        // Verify that "Team Manager" WFI has been commited on.
        Weekly_Forecast_Item__c wfiTeamManager = [SELECT Id, Seller__c, Name, Comitted_on__c,
                  (SELECT Committed_Week__c, Committed_On__c FROM Forecast_Opportunity_Links__r) 
                  FROM Weekly_Forecast_Item__c WHERE User__c = :teamManager.User__c AND Name = :nextWeekString LIMIT 1];
        System.assertNotEquals(wfiTeamManager.Comitted_on__c, null, 'Commit should have been done for team manager WFI');
        System.assertEquals(wfiTeamManager.Forecast_Opportunity_Links__r[0].Committed_On__c, wfiTeamManager.Comitted_on__c, 'Commit should have been done for team manager FOL');
        // Verify that "Seller" WFI has not been commited on.
        Weekly_Forecast_Item__c wfiSeller = [SELECT Id, Seller__c, Name, Comitted_on__c,
                  (SELECT Committed_Week__c, Committed_On__c FROM Forecast_Opportunity_Links__r) 
                  FROM Weekly_Forecast_Item__c WHERE User__c = :seller.User__c AND Name = :nextWeekString LIMIT 1];
        System.assertEquals(wfiSeller.Comitted_on__c, null, 'Commit should not have been done for seller WFI');
        System.assertEquals(wfiSeller.Forecast_Opportunity_Links__r[0].Committed_On__c, null, 'Commit should not have been done for seller FOL');

        // Go into Commit View as Seller which is now a Temp Manager.
        // Default view should be Team view. When doing commit it should be commited as the Team Manager.
        System.runAs(selleruser){  
            NewCommitViewControllerLarge controller = new NewCommitViewControllerLarge();
            controller.radioValue = 'RunningUserView';
            controller.getWeekInstances(); //Need to reload week instances so currentUserId is updated in controller
            PageReference commitSaved = controller.saveJudge(); // Commit should now be done as "Seller"
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved as Seller');
        }

        // Verify that "Seller" WFI has not been commited on.
        Weekly_Forecast_Item__c wfiSeller2 = [SELECT Id, Seller__c, Name, Comitted_on__c,
                  (SELECT Committed_Week__c, Committed_On__c FROM Forecast_Opportunity_Links__r) 
                  FROM Weekly_Forecast_Item__c WHERE User__c = :seller.User__c AND Name = :nextWeekString LIMIT 1];
        System.assertNotEquals(wfiSeller2.Comitted_on__c, null, 'Commit should have been done for seller WFI');
        System.assertEquals(wfiSeller2.Forecast_Opportunity_Links__r[0].Committed_On__c, wfiSeller2.Comitted_on__c, 'Commit should have been done for seller FOL');
        test.stoptest();
    }
}