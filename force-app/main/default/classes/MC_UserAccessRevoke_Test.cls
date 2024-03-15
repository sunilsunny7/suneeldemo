/**
 * @description       : This is a test class for MC_UserAccessRevoke.
 * @author            : Mihir Joshi
 * @Company           : Capgemini
 * @Created on        : 11-12-2023
 * @last modified on  : 02-28-2024
 * @last modified by  : Mihir Joshi
**/
@isTest
public class MC_UserAccessRevoke_Test {
    
    @isTest static void testUserAccessRevoke() {
        
        String firstName = 'Test';
        String lastName = 'User ';
        String email = 'testuser@test.com';
        String tcadId ='tcad';
        String mobileNumber ='+91 1234567890';
        String languageLocaleKey = 'en_US';
        ID userRoleId = [SELECT UserRoleId FROM User WHERE UserRole.Name = 'Enterprise' LIMIT 1].UserRoleId;
        ID profileId = [SELECT ProfileId FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1].ProfileId;
        
        List<User> userListToInsert = new List<User>();
        
        //Creating test users
        for(Integer i=0; i<200; i++){
            
            User newUser = new User();
            newUser.FirstName = firstName;
            newUser.LastName = lastName;
            newUser.Email = email;
            newUser.Username = 'testpoc'+i+'@test.com';
            newUser.Alias = tcadId;
            newUser.UserRoleId = userRoleId;
            newUser.ProfileId = profileId;
            newUser.UserPermissionsMarketingUser = true;
            newUser.UserPermissionsSFContentUser = true;
            newUser.MobilePhone = mobileNumber;
            newUser.Telia_Id__c = tcadId+i;
            newUser.scrive__IsAdministrator__c = true;
            newUser.LanguageLocaleKey = languageLocaleKey;
            newUser.TimeZoneSidKey = 'Europe/Paris';
            newUser.LocaleSidKey = 'sv_SE';
            newUser.EmailEncodingKey = 'ISO-8859-1';
            
            userListToInsert.add(newUser);
        }

        if(!userListToInsert.isEmpty()){
            try{
                insert userListToInsert;
            }catch(DMLException e){
                System.debug('Exception Occurred => '+ e.getMessage());
            }
        }
        
        //Adding Test Users to Public Groups
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Id groupIdTemporaryAdmins = [SELECT Id FROM Group WHERE Name ='TemporaryAdmins'].id;
        Id groupIdTemporaryAdmins_Fiber = [SELECT Id FROM Group WHERE Name ='TemporaryAdmins_Fiber'].id;

        for(User userRecord : userListToInsert){
            
            GroupMember groupMember = new GroupMember();
            groupMember.GroupId = groupIdTemporaryAdmins;
            groupMember.UserOrGroupId = userRecord.Id;
            groupMemberList.add(groupMember);
        }

        for(Integer i=0; i<100; i++){

            GroupMember groupMember = new GroupMember();
            groupMember.GroupId = groupIdTemporaryAdmins_Fiber;
            groupMember.UserOrGroupId = userListToInsert[i].id;
            groupMemberList.add(groupMember);
        }

        if(!groupMemberList.isEmpty()){
            try{
                insert groupMemberList;
            }catch(DMLException e){
                System.debug('Exception Occurred => '+ e.getMessage());
            }
        }
        
        //Test Execution
        Test.startTest();
        MC_UserAccessRevoke schedule = new MC_UserAccessRevoke();
        schedule.execute(NULL);
        Test.stopTest();
        
        List<User> updatedUsers = [ SELECT Id, Name, ProfileId, Profile.Name
                                    FROM User
                                    WHERE Id IN
                                  ( SELECT UserOrGroupId
                                    FROM GroupMember
                                    WHERE Group.Name
                                    IN ('TemporaryAdmins','TemporaryAdmins_Fiber')
                                    AND UserOrGroupId IN : userListToInsert)];
        //Assertions
        for(User isUpdated : updatedUsers){
            System.assertEquals(FALSE, isUpdated.Profile.Name.contains('System Administrator'), 'Profile not updated');
        }
    }
}