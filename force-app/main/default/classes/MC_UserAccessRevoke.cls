/**
* @description       : This class updates the profile for the users present in the public groups to read-only @03:00 AM CET Daily.
* @author            : Mihir Joshi
* @Company           : Capgemini
* @Created on        : 11-12-2023
* @last modified on  : 03-06-2024
* @last modified by  : Mihir Joshi
**/
public with sharing class MC_UserAccessRevoke implements System.Schedulable {
    
    public void execute(System.SchedulableContext sc) {
        
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, Name, ProfileId
                                                 FROM User
                                                 WHERE Id
                                                 IN (
                                                     SELECT UserOrGroupId
                                                     FROM GroupMember
                                                     WHERE Group.Name = 'TemporaryAdmins_Fiber')
                                                 WITH SECURITY_ENFORCED]);
        List<Profile> profileIdToBeAssigned = [SELECT Id, Name
                                               FROM Profile
                                               WHERE Name in ('Telia Sales - SOHO DS','Fiber Base Profile') 
                                               WITH SECURITY_ENFORCED
                                               ORDER BY Name DESC]; //Added ORDER BY clause to make sure SOHO DS is returned first.
        
        //Updating the User profile based on requirement
        List<User> userToBeUpdated = new List<User>();
        
        if(!userMap.isEmpty()){
            
            for(User userRecord : [SELECT Id, Name, ProfileId
                                   FROM User
                                   WHERE Id
                                   IN (
                                       SELECT UserOrGroupId
                                       FROM GroupMember
                                       WHERE Group.Name = 'TemporaryAdmins') 
                                   WITH SECURITY_ENFORCED]){
                                       if(userMap.containsKey(userRecord.Id)){
                                           userRecord.ProfileId = profileIdToBeAssigned[1].id;
                                           userToBeUpdated.add(userRecord);
                                       }else{
                                           userRecord.ProfileId = profileIdToBeAssigned[0].id;
                                           userToBeUpdated.add(userRecord);
                                       }
                                   }
        }
        
        if(!userToBeUpdated.isEmpty()){
            try{
                update userToBeUpdated;
            }catch(DmlException ex){
                System.debug('Exception Occured => '+ex.getMessage());
            }
        }
    }
}