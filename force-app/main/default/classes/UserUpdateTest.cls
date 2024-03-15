/*-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
ApexClass: UserUpdateTest
@Author: Arbaaz Khot/ Mihir Joshi
@Description: This is a Test Class created for UserUpdate
-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+*/
@isTest
public class UserUpdateTest {
    
    @isTest
    private static void testUserProfileUpdate(){
        
        String sch ='0 0 0 ? * * *';
        
        Id userRoleId = [SELECT Id FROM UserRole WHERE Name ='Enterprise'].id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].id;
        String fName = 'Test';
        String lName = 'User ';
        String email = 'testuser@test.com';
        String tcadId ='tcad';
        String mob ='+91 1234567890';
        String lang = 'en_US';
        
        List<User> devsExceptSpecialUsers = new List<User>();
        
        //Creating test users
        for(Integer i=0; i<2; i++){
            
            User newUser = new User();
            newUser.FirstName = fname;
            newUser.LastName = lName;
            newUser.Email = email;
            newUser.Username = 'testpoc'+i+'@test.com';
            newUser.Alias = tcadId;
            newUser.UserRoleId = userRoleId;
            newUser.ProfileId = profileId;
            newUser.UserPermissionsMarketingUser = true;
            newUser.UserPermissionsSFContentUser = true;
            newUser.MobilePhone = mob;
            newUser.Telia_Id__c = tcadId+i;
            newUser.scrive__IsAdministrator__c = true;
            newUser.LanguageLocaleKey = lang;
            newUser.TimeZoneSidKey = 'Europe/Paris';
            newUser.LocaleSidKey = 'sv_SE';
            newUser.EmailEncodingKey = 'ISO-8859-1';
            
            devsExceptSpecialUsers.add(newUser);
        }
                
        if(!devsExceptSpecialUsers.isEmpty()){
            insert devsExceptSpecialUsers;
        }
        
        //Test Execution
        Test.startTest();
        String jobId = System.schedule('User Update', sch, new UserUpdate());
        Test.stopTest();
    }
}