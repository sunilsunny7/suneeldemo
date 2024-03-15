/**
 * Created by kwn687 on 2022-10-05.
 */
@IsTest
public class AzureRegistrationHandler_Test {
    public static final String email = 'rimgaudas.urbonas@example.com', tcad = 'ABC1234';
    public static final Auth.UserData sampleData = new Auth.UserData(
            '17936179', 'Rimgaudas', 'Urbonas', 'Urbonas Rimgaudas',
            email,null, 'RimgaudasUrbonas','en_US','Open ID Connect', null,
            new Map<String, String>{
                    'email' => email,
                    'family_name' => 'Urbonas',
                    'given_name' => 'Urbonas, Rimgaudas',
                    'sub' => '944b5804-7da9-11eb-9439-0242ac130002:'+tcad,
                    'tcad_id' => tcad
            }
    );


    @TestSetup
    public static void setup(){
        User u = Test_DataFactory.createAdminUser();
        u.Email = email;
        Database.upsert(u);
    }

    /**
     * Test a simple email match
     */
    @IsTest
    public static void test_createUser() {
        Test.startTest();
        User u = new AzureRegistrationHandler().createUser(null, sampleData);
        Test.stopTest();

        System.assertEquals(email, u.Email, 'The user was not found');
    }

    /**
     * Test a simple email match
    */
    @IsTest
    public static void test_createUser_blank() {
        Test.startTest();
        User u = new AzureRegistrationHandler().createUser(null, null);
        Test.stopTest();

        System.assertEquals(null, u, 'No user should be returned');
    }

    /**
     * Negative test, the email should not match
     */
    @IsTest
    public static void test_userMatch_negative() {
        String email_negative = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 32)+'testemail@example.com';
        Auth.UserData sampleData_negative = new Auth.UserData('7129385', 'Tom', 'Riddle', 'Tom Riddle', email_negative,
                null, 'tomRiddle', 'en_US', 'Open ID Connect', null, null);
        Test.startTest();
        User u = new AzureRegistrationHandler().createUser(null, sampleData_negative);
        Test.stopTest();

        System.assertEquals(null, u, 'No users should have been found');
    }


    /**
     * Just calling the method for code coverage, the update user method is not in use.
     */
    @IsTest
    static void test_updateUser_reactivation_withoutVlocity() {
        User u = [SELECT Id FROM User WHERE Email =: email LIMIT 1];
        u.IsActive = false;
        u.Temporary_Deactivation_Status__c = 'Automatically Deactivated Salesforce';
        update u;

        Test.startTest();
        new AzureRegistrationHandler().updateUser(u.Id,null, sampleData);
        Test.stopTest();

        User result = [SELECT Id,IsActive, Temporary_Deactivation_Status__c FROM User WHERE Id =: u.Id];
        System.assert(result.IsActive, 'The user should have been reactivated');
        System.assert(result.Temporary_Deactivation_Status__c == 'None', 'The reactivation flag should have been removed');
    }
    @IsTest
    static void test_updateUser_reactivation_withVlocity() {
        User u = [SELECT Id FROM User WHERE Email =: email LIMIT 1];
        u.IsActive = false;
        u.Temporary_Deactivation_Status__c = 'Automatically Deactivated Salesforce and Vlocity';
        update u;

        Test.startTest();
        new AzureRegistrationHandler().updateUser(u.Id,null, sampleData);
        Test.stopTest();

        User result = [SELECT Id,IsActive, Temporary_Deactivation_Status__c FROM User WHERE Id =: u.Id];
        System.assert(result.IsActive, 'The user should have been reactivated');
        System.assert(result.Temporary_Deactivation_Status__c == 'None', 'The reactivation flag should have been removed');
    }
    @IsTest
    static void test_errorEmail() {
        Test.startTest();
        AzureRegistrationHandler.errorEmail('TestEmail');
        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
        Test.stopTest();
    }
}