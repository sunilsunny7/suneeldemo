/**
 * Description:
 * Class implements Schedulable and Database.Batchable interfaces.
 *  - Used to periodically check for Users that have not logged in for more than 60 days.
 *  - Retrieved Users are deactivated unless they have subordinates in any Hierarchical Relationship.
 *  - An email summarizing the transaction results is sent to the responsible parties.
 * 
 * Created by kwn687 on 2022-10-12.
 * 
 * Modifications:
 * 12.10.2022 [Rimgaudas Urbonas] SALEF-7611 - Introduced.
 * 14.02.2023 [Rimgaudas Urbonas] SALEF-8176 - Update Custom Label used to determine the Profiles available for deactivation.
 * 14.03.2023 [Rimgaudas Urbonas] SALEF-8460 - Combine the success and failure messages into a single email.
 * 30.04.2023 [Tomass Brazovskis] LTAT-7669 - Minor refactoring. Skip Users with a Hierarchical Relationship subordinates.  
 **/
public with sharing class UserToBeDeactivatedBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    public String successResult = 'User Deactivation Batch Success: \n';
    public String pendingReviewResult = 'User Deactivation Pending Review: \n';
    public String failedResult = 'User Deactivation Batch Failed: \n';
    public String results = '';
    // Used to ensure predictable test run scope
    @TestVisible
    private static final String EMAIL_ADDRESS_TEST_USERS = 'chgustaf@gmail.com';
    // Map should contain all User Hierarchical Relationships
    @TestVisible
    private static Map<String, String> mapHierarchyRelationshipsToFieldLabels = new Map<String, String>{
        'ManagedUsers'      => User.ManagerId.getDescribe().getRelationshipName(),
        'Subordinates__r'   => User.TeliaSE_Role_based_Approver__c.getDescribe().getLabel()
    };
    
    public Database.QueryLocator start(Database.BatchableContext cntx) {
        List<String> touchableProfiles = Label.Touchable_profiles.split(',');
        // LTAT-7669 - Construct subqueries for each Hierarchical Relationship's subordinate records
        String subordinateSubqueries = '';
        for(String curChildRelationshipName : mapHierarchyRelationshipsToFieldLabels.keyset()){
            subordinateSubqueries += (', (SELECT Id FROM ' + curChildRelationshipName + ')');
        }
        if (Test.isRunningTest()) {
            return Database.getQueryLocator(
                'SELECT Id, Name, Profile.Name, IsActive, LastLoginDate, CreatedDate'
                + subordinateSubqueries
                + ' FROM User'
                + ' WHERE IsActive = TRUE'
                + ' AND email = \'' + EMAIL_ADDRESS_TEST_USERS + '\''
            );
        } else {
            return Database.getQueryLocator(
                'SELECT Id, Name, Profile.Name, IsActive, LastLoginDate, CreatedDate'
                + subordinateSubqueries
                + ' FROM User'
                + ' WHERE IsActive = TRUE'
                + ' AND (LastLoginDate < LAST_N_DAYS:60 OR (LastLoginDate = null AND CreatedDate < LAST_N_DAYS:60))'
                + ' AND Profile.Name IN :touchableProfiles'
                + ' AND Profile.Name != null'
            );
        }
    }

    public void execute(Database.BatchableContext cntx, List<User> scope) {
        List<User> usersToDeactivate = new List<User>();
        List<UserPackageLicense> vlocityLicenseHolders = [SELECT UserId, Id FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix = 'vlocity_cmt'];

        Map<Id, UserPackageLicense> vlocityMap = new Map<Id, UserPackageLicense>();

        Boolean postponeAnyUserDeactivation = false;

        //Create a map of userId's and vlocity Licenses
        for (UserPackageLicense u : vlocityLicenseHolders) {
            vlocityMap.put(u.UserId, u);
        }
        for (User singleUser : scope) {
            // LTAT-7669 - Check if the current User has any subordinates, and its
            // deactivation should, therefore, be postponed
            Boolean postponeCurUserDeactivation = postponeUserDeactivation(singleUser);
            postponeAnyUserDeactivation |= postponeCurUserDeactivation;
            // LTAT-7669 - Include User's Hierarchical Relationship summary in the results email message
            if(postponeCurUserDeactivation){
                pendingReviewResult += constructPostponeUserDeactivationString(singleUser);
            } else {
                // Attempt to update and deactivate a User without any subordinates
                Boolean isUserVLocityLicenseHolder = vlocityMap.get(singleUser.id) != null ? true : false;
                singleUser.IsActive = false;
                singleUser.Temporary_Deactivation_Status__c = isUserVLocityLicenseHolder 
                    ? SEConstants.USER_TD_STATUS_AUTO_DEACTIVATED_SALESFORCE_AND_VLOCITY
                    : SEConstants.USER_TD_STATUS_AUTO_DEACTIVATED_SALESFORCE;
                successResult += constructSuccessfulUserDeactivationString(singleUser, isUserVLocityLicenseHolder);
                usersToDeactivate.add(singleUser);
            }
        }
        // LTAT-7669 - Do not include the 'Pending Review' section in the results email,
        // if the batch does not contain any Users with subordinates 
        if(postponeAnyUserDeactivation){
            results = pendingReviewResult;
        }
        if (!usersToDeactivate.isEmpty()) {
            results = ( successResult 
                + (String.isNotBlank(results) ? '\n' : '')
                + results);
            Database.SaveResult[] srList = Database.update(usersToDeactivate, false);
            results = returnFullResult(srList, results);
        }
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UserToBeDeactivatedBatch(), 10);
    }

    public void finish(Database.BatchableContext cntx) {
        // Send User deactivation batch job results summary
        emailSend(results);
    }

    /**@Description:
     * Helper method constructing a String summarizing the User deactivation
     * batch job results.
     * @param srList - List of Save Results of each User the job attempted to deactivate
     * @param successResult - String containing 'Success' AND, if relevant, 'Pending' sections
     * Modifications:
     * 14.03.2023 [RU] SALEF-8460 - Combine the success and failure messages.
     * 12.10.2022 [RU] SALEF-7611 - Introduced.
     **/ 
    private String returnFullResult(Database.SaveResult[] srList, String successResult) {
        String fullResult = successResult + '\n';
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    failedResult += err.getStatusCode() + ': ' + err.getMessage() + '; Failed fields: ' + err.getFields() + '\n';
                }
            }
        }
        return fullResult + failedResult;
    }

    /**@Description:
     * Helper method sending an email with User deactivation batch job
     * results summary to the responsible parties.
     * @param emailBody - String summarizing the User deactivation batch job results
     * Modifications:
     * 12.10.2022 [RU] SALEF-7611 - Introduced.
     **/ 
    @TestVisible
    private static void emailSend(String emailBody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<User> users = [
            SELECT Email
            FROM User
            WHERE
                Id IN (
                    SELECT UserOrGroupId
                    FROM GroupMember
                    WHERE Group.Name = '2nd Line Support Group'
                )
        ];
        List<String> mailToAddresses = new List<String>();
        for (User u : users) {
            mailToAddresses.add(u.Email);
        }
        mail.setToAddresses(mailToAddresses);
        mail.setReplyTo('noreply-salesforce@teliacompany.com');
        mail.setSenderDisplayName('Amanda Support');
        mail.setSubject('User deactivation batch result');
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }

    /**@Description:
     * Helper method constructing a String of basic User info
     * '|Id: <UserId> |Name: <User's Name> |Profile: <User's Profile>' 
     * @param curUser - User with info to convert into a String
     * @return - String with basic User details.
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced to remove redundancy. 
     **/ 
    @TestVisible
    private static String createUserInfoString(User curUser) {
        return (curUser != null 
                    ? ( '|Id: ' + curUser.Id 
                        + ' |Name: ' + curUser.Name
                        + ' |Profile: ' + curUser.Profile?.Name)
                    : '');
    }

    /**@Description:
     * Helper method constructing a String of basic User info and a list of
     * Hierarchical Relationships with User as the parent, followed by # of subordinates 
     * the User has in the respective hierarchy.
     * @param curUser - User with info to convert into a String
     * @return - String with basic User details and a list of hierarchies with User as the parent
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced.
     **/
    @TestVisible
    private static String constructPostponeUserDeactivationString(User curUser){
        if(curUser == null){
            return '';
        }
        Boolean hasSubordinatesCurUser = false;
        String hierarchicalRelationshipsStr = '';
        for(String curChildRelationshipName : mapHierarchyRelationshipsToFieldLabels.keyset()){
            if( (List<User>) curUser.getSObjects(curChildRelationshipName) != null){
                hierarchicalRelationshipsStr += (
                    (hasSubordinatesCurUser ? '; ' : '')
                    + '\'' + mapHierarchyRelationshipsToFieldLabels.get(curChildRelationshipName) + '\''
                    + ' of '
                    + String.valueOf(((List<User>)curUser.getSObjects(curChildRelationshipName)).size())
                );
                hasSubordinatesCurUser = true;
            }
        }
        // The returned String should be of the form
        // '|Id: <UserId> |Name: <User's Name> |Profile: <User's Profile>
        // |Hierarchical Relationships: 'Manager' of <N>; 'Role Based Approver' of <M>'
        return (createUserInfoString(curUser)
            + ' |Hierarchical Relationships: ' + hierarchicalRelationshipsStr
            + '\n');
    }

    /**@Description:
     * Helper method constructing a String of basic User info, License type and 
     * LastLoginDate of a User to be deactivated.
     * @param curUser - User with info to convert into a String
     * @param isUserVLocityLicenseHolder - Boolean indicating whether curUser has been assigned a VLocity License
     * @return - String with basic User details, License type and LastLoginDate
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced.
     **/
    @TestVisible
    private static String constructSuccessfulUserDeactivationString(User curUser, Boolean isUserVLocityLicenseHolder){
        String curUserSuccessStr = '';
        if(curUser == null){
            return curUserSuccessStr;
        }
        // The returned String should be of the form
        // '|Id: <UserId> |Name: <User's Name> |Profile: <User's Profile>
        // |License type: <Type> |LastLoginDate: <Datetime>'
        curUserSuccessStr += createUserInfoString(curUser);
        if(isUserVLocityLicenseHolder != null){
            curUserSuccessStr += (' |License type: ' 
                + ( isUserVLocityLicenseHolder 
                    ? SEConstants.USER_TD_STATUS_AUTO_DEACTIVATED_SALESFORCE_AND_VLOCITY
                    : SEConstants.USER_TD_STATUS_AUTO_DEACTIVATED_SALESFORCE)
            );
        }
        curUserSuccessStr += (' |LastLoginDate: ' + curUser.LastLoginDate);
        curUserSuccessStr += '\n';
        return curUserSuccessStr;
    }

    /**@Description:
     * Helper method determining whether a User has any Hierarchical Relationship subordinates.
     * @param curUser - User with Hierarchical Relationship to check.
     * @return - Boolean. TRUE, if a User has any subordinates, FALSE otherwise.
     * Modifications:
     * 30.04.2023 [TB] LTAT-7669 - Introduced.
     **/
    @TestVisible
    private static Boolean postponeUserDeactivation(User curUser){
        if(curUser == null){
            return false;
        }
        for(String curChildRelationshipName : mapHierarchyRelationshipsToFieldLabels.keyset()){
            if( (List<User>) curUser.getSObjects(curChildRelationshipName) != null){
                return true;
            }
        }
        return false;
    }

}