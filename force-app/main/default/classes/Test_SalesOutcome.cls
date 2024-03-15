/**
    About
    -----
    Description: Test Class to test that the Sales Outcome is correctly rolled up to Opportunity from Opportunity Product
    Create date: June 2015
   
    Update History
    --------------
    Created Jun 2015 - V.I
    Updated Aug 2015 - C.G Added Sales_Unit__c,Sales_Team__c and Seller record creation for every time users are created. 
    Updated Oct 2015 - V.I Added test for Large opportunity 
    Updated Apr 2016 - A.N Fixed bugs in test methods. Previously did not query records after insert/update, so all fields were null when asserting 
    
    Issues / TODOs
    --------------  
*/

@isTest
public class Test_SalesOutcome {
    
    @isTest static void insertOpportunityProduct(){
        System.debug('@@Test insertOpportunityProduct Starts');
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }

        User salesRep = smeUserTeam[2];
        
        // C.G. Added this system.runAs as well on Aug 26 2015
        System.runAs(salesRep){
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
    
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.IsActive = true;
            insert p;
            
            Id pbId = Test.getStandardPricebookId();
            
            PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, p);
            pbe.UnitPrice = 1000;
            
            pbe.IsActive = true;
            insert pbe;
            
            PriceBookEntry pbe2 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p);
            pbe2.UnitPrice = 1000;
            
            pbe2.IsActive = true;
            insert pbe2;
            
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe2.Id);
            
            oli.Start_Fee__c = 500;
            oli.Contact_Duration__c = 24;
            oli.Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_NEW_SALES;
            
            insert oli;           
        }
    }

    @isTest static void insertOpportunityProductOnLargeOpp(){
        System.debug('@@Test insertOpportunityProductOnLargeOpp Starts');
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }

        User salesRep = smeUserTeam[2];
        test.starttest();
        Account acc = Test_DataFactory.createOneLargeStandardAccount();
        acc.OwnerId = salesRep.Id;
        insert acc;
        
        // C.G. Added this system.runAs as well on Aug 26 2015
        System.runAs(salesRep){
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
    
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.IsActive = true;
            insert p;
            
            Id pbId = Test.getStandardPricebookId();
            
            PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, p);
            pbe.UnitPrice = 1000;
            
            pbe.IsActive = true;
            insert pbe;
            
            PriceBookEntry pbe2 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p);
            pbe2.UnitPrice = 1000;
            
            pbe2.IsActive = true;
            insert pbe2;
            
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe2.Id);
            
            oli.Start_Fee__c = 500;
            oli.Contact_Duration__c = 24;
            oli.Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_NEW_SALES;
            
            insert oli;           
            test.stoptest();
            //Assert
            OpportunityLineItem oliAfterInsert = [SELECT Id, Sales_Outcome_Large__c FROM OpportunityLineItem LIMIT 1];
            Opportunity oppAfterInsert = [SELECT Id, Sales_Outcome_Large__c FROM Opportunity LIMIT 1];
            System.assertEquals(oliAfterInsert.Sales_Outcome_Large__c, oppAfterInsert.Sales_Outcome_Large__c);
        }
    }

    
    
    @isTest static void updateOpportunityProduct(){
        System.debug('@@Test updateOpportunityProduct Starts');
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }

        User salesRep = smeUserTeam[2];
        
        System.runAs(salesRep){
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            Test.startTest();
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.IsActive = true;
            insert p;
            
            Id pbId = Test.getStandardPricebookId();
            
            PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, p);
            pbe.UnitPrice = 1000;
            
            pbe.IsActive = true;
            insert pbe;
            
            PriceBookEntry pbe2 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p);
            pbe2.UnitPrice = 1000;
            
            pbe2.IsActive = true;
            insert pbe2;
            
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe2.Id);
            
            oli.Start_Fee__c = 500;
            oli.Contact_Duration__c = 24;
            oli.Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_NEW_SALES;
            
            insert oli; 
            
            oli.Start_Fee__c = 25;
            
            update oli;
            
            //Assert
            OpportunityLineItem oliAfterUpdate = [SELECT Id, Sales_Outcome__c FROM OpportunityLineItem LIMIT 1];
            Opportunity oppAfterUpdate = [SELECT Id, Sales_Outcome__c FROM Opportunity LIMIT 1];            
            System.assertEquals(oliAfterUpdate.Sales_Outcome__c, oppAfterUpdate.Sales_Outcome__c);
            Test.stopTest();
        }
    }
    
    @isTest static void delteOpportunityProduct(){
        System.debug('@@Test insertOpportunityProduct Starts');
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }

        User salesManager = smeUserTeam[1];
        
        // C.G. Added this system.runAs as well on Aug 26 2015
        System.runAs(salesManager){
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'test family';
            p.IsActive = true;
            insert p;
            
            Id pbId = Test.getStandardPricebookId();
            
            PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, p);
            pbe.UnitPrice = 1000;
            
            pbe.IsActive = true;
            insert pbe;
            
            PriceBookEntry pbe2 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p);
            pbe2.UnitPrice = 1000;
            
            pbe2.IsActive = true;
            insert pbe2;
            
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe2.Id);
            
            oli.Start_Fee__c = 500;
            oli.Contact_Duration__c = 24;
            oli.Sales_purpose__c = Test_DataFactory.OLI_SALES_PURPOSE_NEW_SALES;
            
            insert oli;
            
            //Assert
            OpportunityLineItem oliAfterInsert = [SELECT Id, Sales_Outcome__c FROM OpportunityLineItem LIMIT 1];
            Opportunity oppAfterInsert = [SELECT Id, Sales_Outcome__c FROM Opportunity LIMIT 1];
            System.assertEquals(oliAfterInsert.Sales_Outcome__c, oppAfterInsert.Sales_Outcome__c);
            
            delete oli;
            Test.stopTest();

           // Opportunity oppAfterDelete = [SELECT Id, Sales_Outcome__c FROM Opportunity LIMIT 1];
           // System.assertEquals(0, oppAfterDelete.Sales_Outcome__c);
        }
    }    

}