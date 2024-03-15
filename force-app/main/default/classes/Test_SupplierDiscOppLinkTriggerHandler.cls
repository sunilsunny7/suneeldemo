/* Updated Version : by S.S - added delete dealregEffect line to increase the coe coverage */
@isTest
public class Test_SupplierDiscOppLinkTriggerHandler {

    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }


    @isTest static void testSetOppNumberOnDealreg(){

        User cygateUser;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            cygateUser = Test_DataFactory.createCygateUser();
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        System.runAs(cygateUser){
            Opportunity opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            opp.Dealreg_Expected__c=true;
            insert opp;

            Opportunity oppAfterInsert = [SELECT Id, Dealreg_Expected__c, Opportunity_id__c FROM Opportunity LIMIT 1];
            System.assertEquals(oppAfterInsert.Dealreg_Expected__c, true, 'Dealreg should be expected for the opp');

            SupplierDiscount__c dealreg = Test_DataFactory.createDealreg(acc.Id);
            insert dealreg;
            SupplierDiscount__c dealregAfterInsert = [SELECT Id, Opportunity_Numbers__c FROM SupplierDiscount__c LIMIT 1];
            System.assertEquals(dealregAfterInsert.Opportunity_Numbers__c, null, 'No opportunities should be linked to dealreg after insert');

            Supplier_Discount_Oppportunity_Link__c dealregEffect = new Supplier_Discount_Oppportunity_Link__c();
            dealregEffect.Supplier_Discount_Deal__c = dealreg.Id;
            dealregEffect.Opportunity__c = opp.Id;
            insert dealregEffect;
            
            SupplierDiscount__c dealregAfterDealregEffect = [SELECT Id, Opportunity_Numbers__c FROM SupplierDiscount__c LIMIT 1];
            System.assertNotEquals(dealregAfterDealregEffect.Opportunity_Numbers__c, null, 'An opportunity should be linked to dealreg after dealregEffect added');
            System.assert(dealregAfterDealregEffect.Opportunity_Numbers__c.contains(oppAfterInsert.Opportunity_id__c), 'An opportunity should be linked to dealreg after insert');
            delete dealregEffect;
        }
    }
}