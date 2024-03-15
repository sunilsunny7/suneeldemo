/*-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
@Author: Arbaaz Khot & Mihir Joshi
@Company: Capgemini
@Created Date: 6th Sept. 2023
@Description: This class updates the profiles for all the users to read-only @03:00 AM CET Daily
-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/
global class UserUpdate implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        List<String> sUsers = new List<String>{'Sunita Tudu','Ananya ShashiKumar'}; //Profile to be upadted as 'Fiber Base Profile'
            
        List<User> userProfileToUpdate = new List<User>();
        
        List<User> specialUsers = [SELECT Id, Name, ProfileId
                                   FROM User
                                   WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'TemporaryAdmins')
                                   AND Name IN : sUsers];
        
        List<User> devsExceptSpecialUsers = [SELECT Id, Name, ProfileId
                                             FROM User
                                             WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'TemporaryAdmins')
                                             AND Id NOT IN : specialUsers];
        
        List<Profile> newProfileId = [SELECT Id, Name FROM Profile WHERE Name in ('Telia Sales - SOHO DS','Fiber Base Profile')]; 
        
        if(specialUsers.size() > 0 && devsExceptSpecialUsers.size() > 0 && newProfileId.size() > 0){
            
            for(User devs : devsExceptSpecialUsers ){
                devs.ProfileId = newProfileId[0].id;
                userProfileToUpdate.add(devs);
            }
            for(User sU : specialUsers){
                sU.ProfileId = newProfileId[1].id;
                userProfileToUpdate.add(sU);
            }
        }
        
        if(!userProfileToUpdate.isEmpty()){
            update userProfileToUpdate;
        }
    }
}