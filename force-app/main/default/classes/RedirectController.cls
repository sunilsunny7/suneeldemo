public class RedirectController {

    public PageReference redirect(){
        User currentUser = [Select Id, UserRoleId from User where Id = :Userinfo.getUserId()];
        system.debug('currentUser.UserRoleId: ' + currentUser.UserRoleId);

        Set<String> roleIds = new Set<String>();        
        for(SMECommit__c s : SMECommit__c.getAll().values()){
            roleIds.add(s.RoleID__c);
        }
            
        if (roleIds.contains(currentUser.UserRoleId)){
            return new PageReference('/apex/CommitView');
        } else {
            return new PageReference('/apex/NewCommitViewLarge');
        }
    }
}