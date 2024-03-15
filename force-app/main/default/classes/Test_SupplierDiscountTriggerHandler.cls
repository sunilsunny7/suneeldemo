@isTest
public class Test_SupplierDiscountTriggerHandler {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }

    @isTest static void testCanDeleteDealregWithoutDealregEffects(){

        User enterpriseAdminUser;
        User cygateUser;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            enterpriseAdminUser = Test_DataFactory.createCygateEnterpriseBusinessAdminUser();
            cygateUser = Test_DataFactory.createCygateUser();
            List<User> users = new List<User>();
            users.add(enterpriseAdminUser);
            users.add(cygateUser);
            insert users;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        System.runAs(enterpriseAdminUser){

            SupplierDiscount__c dealreg = Test_DataFactory.createDealreg(acc.Id);
            insert dealreg;
            List<SupplierDiscount__c> dealregsAfterInsert = [SELECT Id FROM SupplierDiscount__c];
            System.assertEquals(dealregsAfterInsert.size(), 1, 'A dealreg record should have been successfully created');
            
            delete dealreg;
            List<SupplierDiscount__c> dealregsAfterDelete = [SELECT Id FROM SupplierDiscount__c];
            System.assertEquals(dealregsAfterDelete.size(), 0, 'The dealreg record should have been successfully deleted');
        }
    }

    @isTest static void testCannotDeleteDealregWithDealregEffects(){

        User enterpriseAdminUser;
        User cygateUser;
        Account acc;
        SupplierDiscount__c dealreg;
        Supplier_Discount_Oppportunity_Link__c dealregEffect;
       Test.startTest();
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            enterpriseAdminUser = Test_DataFactory.createCygateEnterpriseBusinessAdminUser();
            cygateUser = Test_DataFactory.createCygateUser();
            List<User> users = new List<User>();
            users.add(enterpriseAdminUser);
            users.add(cygateUser);
            insert users;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }
        
        System.runAs(cygateUser){
            Opportunity opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            insert opp;
      
            dealreg = Test_DataFactory.createDealreg(acc.Id);
            insert dealreg;

            dealregEffect = new Supplier_Discount_Oppportunity_Link__c();
            dealregEffect.Supplier_Discount_Deal__c = dealreg.Id;
            dealregEffect.Opportunity__c = opp.Id;
            insert dealregEffect;
        }
       Test.stopTest();
        List<SupplierDiscount__c> dealregsAfterInsert = [SELECT Id FROM SupplierDiscount__c];
        System.assertEquals(dealregsAfterInsert.size(), 1, 'A dealreg record should have been successfully created');

        System.runAs(enterpriseAdminUser){

            Boolean deleteSuccessful = true;
            try{ delete dealreg; }
            catch(Exception e){
                deleteSuccessful = false;
            }

            System.assertEquals(deleteSuccessful, false, 'The dealreg should not have been deleted');

            deleteSuccessful = true;
            try {
                delete dealregEffect;
                delete dealreg;
            } catch(Exception e){
                deleteSuccessful = false;
            }
            System.assertEquals(deleteSuccessful, true, 'The dealreg should have been deleted');
        }
    }
}