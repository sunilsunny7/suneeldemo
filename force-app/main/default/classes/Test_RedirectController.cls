/**
 * @Description:
 * RedirectController test class.
 * 
 * Modifications:
 * 20.01.2022 [Tomass Brazovskis] SALEF-8006 - Replaced hardcoded 'SME' Role and Id Name with a Test_DataFactory String const
 *          storing an existing 'SME Sales...' Role's Name. Test SME User will be assigned to this Role.
 */
@isTest
public class Test_RedirectController {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }

    @isTest
    static void testSMEUser(){
        User u;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            u = Test_DataFactory.createSMEUser();
            insert u;
            SMECommit__c cs= new SMECommit__c ();
            cs.Name = Test_DataFactory.ROLE_DEV_NAME_VALID_SME;
            cs.RoleID__c= u.UserRoleId;
            insert cs;
        }

        System.runAs(u){
            RedirectController controller = new RedirectController();  
            PageReference pr = controller.redirect();
            System.assertEquals('/apex/CommitView', pr.getUrl());
        }
    }
    
    
    @isTest
    static void testLargeUser(){
        User u;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            u = Test_DataFactory.createLargeUser();
            insert u;
        }
        
        System.runAs(u){
            RedirectController controller = new RedirectController();  
            PageReference pr = controller.redirect();
            System.assertEquals('/apex/NewCommitViewLarge', pr.getUrl());
        }
    }
    
}