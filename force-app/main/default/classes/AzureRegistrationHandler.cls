/**
 * Created by kwn687 on 2022-10-03.
 */

global class AzureRegistrationHandler implements Auth.RegistrationHandler {

    global User createUser(Id portalId, Auth.UserData userData) {
        //Check for empty metadata
        if (userData == null || String.isBlank(userData.email)) {
            return null;
        }
        //Locate user
        List<User> users = [
                SELECT Id, Username, Email, FirstName, IsActive, Profile.Name, Temporary_Deactivation_Status__c
                FROM User
                WHERE Email = :userData.email.toLowerCase()
        ];
        if(users.size() == 1){
            evaluateReactivation(users.get(0));
            return users.get(0);
        }
        else{
            for(User oneUser : users){
                if(!oneUser.profile.name.contains('API') && !oneUser.profile.name.contains('Integration')){
                        return oneUser;
                }
            }
        }
        return null;
    }

    @TestVisible
    private void evaluateReactivation(User user) {
        UserPackageLicense vlocityLicense = new UserPackageLicense();
        String emailBody = '';
        PackageLicense vlocityPackage = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'vlocity_cmt' LIMIT 1];
        if (user != null && !user.IsActive && user.Temporary_Deactivation_Status__c == 'Automatically Deactivated Salesforce') {
            user.IsActive = true;
            user.Temporary_Deactivation_Status__c = 'None';
            try {
                update user;
            } catch (Exception e) {
                emailBody += 'Reactivation of user ' + user.Name + ', ID: ' + user.Id + ', Error: ' + e + ' failed.';
            }
        } else if (user != null && !user.IsActive && user.Temporary_Deactivation_Status__c == 'Automatically Deactivated Salesforce and Vlocity') {
            user.IsActive = true;
            user.Temporary_Deactivation_Status__c = 'None';
            vlocityLicense.PackageLicenseId = vlocityPackage.Id;
            vlocityLicense.UserId = user.Id;
            try {
                update user;
                insert vlocityLicense;
            } catch (Exception e) {
                emailBody += 'Reactivation of user ' + user.Name + ', ID: ' + user.Id + ', Error: ' + e + ' failed.';
            }
        }
        if (String.isNotBlank(emailBody)) {
            errorEmail(emailBody);
        }
    }
    @TestVisible
    private static void errorEmail(String emailBody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<User> users = [
                SELECT Email
                FROM User
                WHERE Id IN (
                        SELECT UserOrGroupId
                        FROM GroupMember
                        WHERE Group.Name = '2nd Line Support Group'
                )
        ];
        List<String> mailToAddresses = new List<String>();
        for (User u : users) {
            mailToAddresses.add(u.email);
        }
        mail.setToAddresses(mailToAddresses);
        mail.setReplyTo('noreply-salesforce@teliacompany.com');
        mail.setSenderDisplayName('Amanda Support');
        mail.setSubject('User reactivation failed for ' + user.Name);
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                mail
        });
    }
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        List<User> users = [
                SELECT Id, Username, Email, FirstName, IsActive, Profile.Name, Temporary_Deactivation_Status__c
                FROM User
                WHERE Email = :data.email.toLowerCase()
        ];
        if(users.size() == 1){
            evaluateReactivation(users.get(0));
        }
        else{
            for(User oneUser : users){
                if(!oneUser.profile.name.contains('API') && !oneUser.profile.name.contains('Integration')){
                    evaluateReactivation(oneUser);
                }
            }
        }
    }
}