global class UserExtension {
    
    
    public UserExtension(ApexPages.StandardController stdController) {
    }
    
    @RemoteAction
    global static String updateusr(String pageId) {

        UserLogin usrLogin = [SELECT Id, IsFrozen, UserId From UserLogin Where UserId =: pageId];
        User usr = new User();
        usr.id=pageId;
        usr.Frozen_User__c = usrLogin.IsFrozen;
        update usr;
        return 'Job complete';
    }
}