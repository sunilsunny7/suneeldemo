/**
 * Description:
 * Test class for UserToBeDeactivatedBatch.
 * 
 * Created by kwn687 on 2022-10-12.
 * 
 * Modifications:
 * 12.10.2022 [Rimgaudas Urbonas] SALEF-7611 - Introduced.
 * 30.04.2023 [Tomass Brazovskis] LTAT-7669 - Minor refactoring. Add additional test methods to ensure 
 *              that Users with Hierarchical Relationship subordinates are being skipped.  
 **/
@isTest
public with sharing class UserToBeDeactivatedBatch_Test {

    // Constants to ensure the relevant test data is being queried
    private static final String USERNAME_BASE_MGR_USER = 'testMgr@telia.com';
    private static final String USERNAME_BASE_SUBORDINATE_USER = 'subordinate@telia.com';
    private static final String USER_QUERY_STRING_BASE = 'SELECT Id, Name, Profile.Name, IsActive, LastLoginDate, CreatedDate,'
        + ' (SELECT Id FROM ManagedUsers),'
        + ' (SELECT Id FROM Subordinates__r)'
        + ' FROM User'
        + ' WHERE IsActive = TRUE';

    /**@Description:
     * Test setup method. Creates Test Users and establishes Hierarchical Relationships
     * among them.
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Establish Hierarchical Relationships among the Users.
     * 12.10.2022 [RU] SALEF-7611 - Introduced. Creates Test Users.
     **/ 
    @TestSetup
    public static void createTestData() {
        List<User> lstMgrUser = new List<User>();
        // Ensure User Profile is listed in the Touchable_profiles Custom Label
        User mgrUser = Test_DataFactory.createLargeUser();
        // Construct unique username
        mgrUser.Username = USERNAME_BASE_MGR_USER.substringBefore('@')
            + '_'
            + Datetime.now().format('yyyymmdd\'T\'HHmmss') 
            + '@'
            + USERNAME_BASE_MGR_USER.substringAfter('@');
        // Set email address used in the Test context batch query
        mgrUser.Email = UserToBeDeactivatedBatch.EMAIL_ADDRESS_TEST_USERS;
        lstMgrUser.add(mgrUser);
        insert lstMgrUser;
        
        List<User> lstSubordinateUsers = new List<User>();
        for(Integer i = 0; i < 4; i++) {
            // Ensure User Profile is listed in the Touchable_profiles Custom Label
            User curUser = Test_DataFactory.createLargeUser();
            // Establish the Hierarchical Relationships
            curUser.ManagerId = lstMgrUser[0].Id;
            curUser.TeliaSE_Role_based_Approver__c = lstMgrUser[0].Id;
            // Construct unique username
            curUser.Username = USERNAME_BASE_SUBORDINATE_USER.substringBefore('@')
                + String.valueOf(i)
                + '_'
                + Datetime.now().format('yyyymmdd\'T\'HHmmss') 
                + '@'
                + USERNAME_BASE_SUBORDINATE_USER.substringAfter('@');
            // Set email address used in the Test context batch query
            curUser.Email = UserToBeDeactivatedBatch.EMAIL_ADDRESS_TEST_USERS;
            lstSubordinateUsers.add(curUser);
        }
        insert lstSubordinateUsers;
    }

    /**@Description:
     * Test a User deactivation Batch Job run.
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Adapt method to accommodate for the Hierarchical Relationships.
     * 12.10.2022 [RU] SALEF-7611 - Introduced. Test a User deactivation Batch Job run.
     **/ 
    @isTest
    public static void testUserDeactivation() {
        Set<Id> setUsersToDeactivateIds = new Set<Id>();
        Set<Id> setUsersToPostponeDeactivationIds = new Set<Id>();
        Map<Id, User> mapUserIdsToUsers = new Map<Id, User>([   SELECT Id, Username, ManagerId, TeliaSE_Role_based_Approver__c
                                                                FROM User
                                                                WHERE Email = :UserToBeDeactivatedBatch.EMAIL_ADDRESS_TEST_USERS
                                                                AND IsActive = TRUE]);
        // LTAT-7669 - Users with subordinates should not be deactivated
        for(User curUser : mapUserIdsToUsers.values()){
            if(curUser.ManagerId != null){
                setUsersToPostponeDeactivationIds.add(curUser.ManagerId);
            }
            if(curUser.TeliaSE_Role_based_Approver__c != null){
                setUsersToPostponeDeactivationIds.add(curUser.TeliaSE_Role_based_Approver__c);
            }
        }
        setUsersToDeactivateIds = mapUserIdsToUsers.keySet().clone();
        setUsersToDeactivateIds.removeAll(setUsersToPostponeDeactivationIds);
        Integer scope = !mapUserIdsToUsers.isEmpty() ? mapUserIdsToUsers.size() : 10;
        // Execute a User deactivation Batch Job run
        Test.startTest();
        Database.executeBatch(new UserToBeDeactivatedBatch(), scope);
        Test.stopTest();
        // Retrieve Users that have been deactivated
        Map<Id, User> mapUserIdsToUsersDeactivated = new Map<Id, User>([SELECT Id 
                                                                        FROM User
                                                                        WHERE IsActive = FALSE 
                                                                        AND Id IN: mapUserIdsToUsers.keySet() 
                                                                        AND Temporary_Deactivation_Status__c = 'Automatically Deactivated Salesforce'
        ]);
        Set<Id> setUsersSuccessfullyDeactivatedIds = mapUserIdsToUsersDeactivated.keySet();
        // Verify that all Users without subordinates have been deactivated 
        for(Id curUserToDeactivateId : setUsersToDeactivateIds){
            System.assert(  setUsersSuccessfullyDeactivatedIds.contains(curUserToDeactivateId),
                            'User ' + mapUserIdsToUsers.get(curUserToDeactivateId).Username + ' should have been deactivated.');
        }
    }

    /**@Description:
     * Test constructPostponeUserDeactivationString().
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced.
     **/ 
    @isTest
    public static void testConstructPostponeUserDeactivationString(){
        // Retrieve a User with subordinates in all existing Hierarchical Relationships
        String curQuery = USER_QUERY_STRING_BASE
            + ' AND username LIKE '
            + '\'%' + USERNAME_BASE_MGR_USER.substringBefore('@') + '%\'';
        List<User> lstMgrUserToTest = Database.query(curQuery);
        // Attempt to construct a String listing the Hierarchical Relationships
        Test.startTest();
        String pendingReviewString = UserToBeDeactivatedBatch.constructPostponeUserDeactivationString(lstMgrUserToTest[0]);
        Test.stopTest();
        // Verify correctness of the content of the String generated 
        System.assert(String.isNotBlank(pendingReviewString),
            'A string listing all the subordinate relationships should have been generated for a User with subordinates.');
        for(String curFieldLabel : UserToBeDeactivatedBatch.mapHierarchyRelationshipsToFieldLabels.values()){
            System.assert(pendingReviewString.containsIgnoreCase(curFieldLabel),
                'String of Hierarchical Relationships does not contain the expected Relationship Name.');
        }
    }

    /**@Description:
     * Test postponeUserDeactivation() for a User with subordinates. 
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced.
     **/
    @isTest
    public static void testPostponeUserDeactivation_True(){
        // Retrieve a User with subordinates
        String curQuery = USER_QUERY_STRING_BASE
            + ' AND username LIKE '
            + '\'%' + USERNAME_BASE_MGR_USER.substringBefore('@') + '%\'';
        List<User> lstMgrUserToTest = Database.query(curQuery);
        // Determine whether the deactivation attempt should be postponed for the User 
        Test.startTest();
        Boolean postponeUserDeactivation = UserToBeDeactivatedBatch.postponeUserDeactivation(lstMgrUserToTest[0]);
        Test.stopTest();
        // Verify that the deactivation will be postponed for a User with subordinates 
        System.assert(postponeUserDeactivation,
            'Deactivation attempt should have been postponed for a User with subordinates.');
    }

    /**@Description:
     * Test postponeUserDeactivation() for a User without subordinates. 
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced.
     **/
    @isTest
    public static void testPostponeUserDeactivation_False(){
        // Retrieve a User without subordinates
        String curQuery = USER_QUERY_STRING_BASE
            + ' AND username LIKE '
            + '\'%' + USERNAME_BASE_SUBORDINATE_USER.substringBefore('@') + '%\'';
        List<User> lstSubordinateUserToTest = Database.query(curQuery);
        // Determine whether the deactivation attempt should be postponed for the User
        Test.startTest();
        Boolean postponeUserDeactivation = UserToBeDeactivatedBatch.postponeUserDeactivation(lstSubordinateUserToTest[0]);
        Test.stopTest();
        // Verify that the deactivation will be attempted for a User without subordinates
        System.assert(!postponeUserDeactivation,
            'Deactivation attempt should NOT have been postponed for a User without subordinates.');
    }

    /**@Description:
     * Test constructSuccessfulUserDeactivationString() for a User
     * assigned a VLocity License. 
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced.
     **/
    @isTest
    public static void testConstructSuccessfulUserDeactivationString_WithVLocityLicense(){
        testConstructSuccessfulUserDeactivationString(true);
    }

    /**@Description:
     * Test constructSuccessfulUserDeactivationString() for a User
     * NOT assigned any VLocity Licenses. 
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced.
     **/
    @isTest
    public static void testConstructSuccessfulUserDeactivationString_NoVLocityLicense(){
        testConstructSuccessfulUserDeactivationString(false);
    }

    /**@Description:
     * Helper method used to test correctness of the String generated by 
     * constructSuccessfulUserDeactivationString() under different circumstances.
     * @param isUserVLocityLicenseHolder - Boolean determining whether the User has a VLocity License.
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced.
     **/
    public static void testConstructSuccessfulUserDeactivationString(Boolean isUserVLocityLicenseHolder){
        // Retrieve a User without subordinates
        String curQuery = USER_QUERY_STRING_BASE
            + ' AND username LIKE '
            + '\'%' + USERNAME_BASE_SUBORDINATE_USER.substringBefore('@') + '%\''
            + ' LIMIT 1';
        List<User> lstSubordinateUserToTest = Database.query(curQuery);
        // Attempt to construct a String of basic User info, License type
        // and LastLoginDate of a User to be deactivated.
        Test.startTest();
        String userDeactivationSuccessString = UserToBeDeactivatedBatch.constructSuccessfulUserDeactivationString(
            lstSubordinateUserToTest[0], 
            isUserVLocityLicenseHolder);
        Test.stopTest();
        // Verify correctness of the content, dependent on whether a User is assigned 
        // a VLocity License, of the String generated
        System.assert(String.isNotBlank(userDeactivationSuccessString),
            'A User deactivation success string should have been generated for the User passed as an argument.');
        if(isUserVLocityLicenseHolder){
            System.assert(userDeactivationSuccessString.containsIgnoreCase(SEConstants.USER_TD_STATUS_AUTO_DEACTIVATED_SALESFORCE_AND_VLOCITY),
                'A deactivation success message for a User with a VLocity License does not inform about VLocity deactivation.');
        } else{
            System.assert(!userDeactivationSuccessString.containsIgnoreCase(SEConstants.USER_TD_STATUS_AUTO_DEACTIVATED_SALESFORCE_AND_VLOCITY),
                'A deactivation success message for a User without a VLocity License informs about VLocity deactivation.');
        }
    }
}