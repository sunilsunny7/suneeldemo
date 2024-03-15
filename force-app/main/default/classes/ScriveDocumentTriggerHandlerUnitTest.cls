/**
About
-----
Description: Test class for ScriveDocumentTriggerHandler
Create by: Srikanya
Created date : June 2022
*/
@isTest
public class ScriveDocumentTriggerHandlerUnitTest { 
   public static testmethod void nr01_testSellerHierarchyOppRollUp1(){
        Test_DataFactory.setUpOrg();        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);           
            Test_DataFactory.createPriceBooks();
        }        
        User salesManager = smeUserTeam[1];
        User salesRep = smeUserTeam[2];        
        Seller__c smeManagerSeller = smeSellerTeam[0];
        Seller__c salesManagerSeller = smeSellerTeam[1];
        Seller__c salesRepSeller = smeSellerTeam[2];
        test.starttest();
        System.runAs(salesRep){            
            System.assertEquals(salesRepSeller.Manager__c, salesManagerSeller.Id);
            Opportunity opp = Test_DataFactory.createOpportunity();
            insert opp;
            scrive__ScriveDocument__c sc = new scrive__ScriveDocument__c();
            sc.name='abc';
            sc.scrive__opportunity__c = opp.Id;//Associated opportunity
            sc.scrive__externalId__c ='12345';
            sc.scrive__status__c ='Signed';
            insert sc;
            sc.scrive__externalId__c ='123456';        
            update sc;
        }
        System.runAs(salesManager){
            Opportunity opp2 = Test_DataFactory.createOpportunity();
            insert opp2;
        }
    }
}