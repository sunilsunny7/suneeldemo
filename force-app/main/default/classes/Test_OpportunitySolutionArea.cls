/**
About
-----
Description: Test Class to test that the Solution Area is synced with the opportunity product families 
Create date: October 2015

Update History
--------------
Created Oct 2015 - V.I 

Issues / TODOs
--------------  
*/

@isTest
public class Test_OpportunitySolutionArea {
    
    @isTest static void insertOpportunityProduct(){
        
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
        }

        User salesRep = smeUserTeam[2];
        User salesManager = smeUserTeam[1];

        System.runAs(salesManager){
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }
        
        System.runAs(salesRep){
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Networks - Broadband';
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
            
            Opportunity o = [Select Main_Product_Area__c from Opportunity where Id = : opp.Id];
            
            //Assert
            //System.assertEquals(p.Family, o.Main_Product_Area__c);
        }
    }
    
    @isTest static void deleteOpportunityProduct(){
        
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
            Test.StartTest();
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Networks - Broadband';
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
            
            Opportunity o = [Select Main_Product_Area__c from Opportunity where Id = : opp.Id];
            
            String solutionarea =  o.Main_Product_Area__c;
            
            delete oli;
            Test.StopTest();
            
            Opportunity o2 = [Select Main_Product_Area__c from Opportunity where Id = : opp.Id];
            List<OpportunityLineItem> olis = [Select Id from OpportunityLineItem where OpportunityId = : opp.Id];
            
            //Assert
            System.assertEquals(solutionarea, o2.Main_Product_Area__c);
            System.assertEquals(0, olis.size());
        }
    }
    
    @isTest static void addValueManually(){
        
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
            test.starttest();
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Networks - Broadband';
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
            
            Opportunity o = [Select Main_Product_Area__c from Opportunity where Id = : opp.Id];
            
            o.Main_Product_Area__c = o.Main_Product_Area__c + ';IBS';
            update o;
            test.stoptest();
            Opportunity o2 = [Select Main_Product_Area__c from Opportunity where Id = : opp.Id];
            
            //Assert
            System.assertEquals('IBS;Networks', o2.Main_Product_Area__c);
        }
    }

    @isTest static void deleteValueManuallyWhenProductExist(){
        
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
            test.starttest();
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Networks - Broadband';
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
            
            Opportunity o = [Select Main_Product_Area__c from Opportunity where Id = : opp.Id];
            
            o.Main_Product_Area__c = '';
            update o;
            
            Opportunity o2 = [Select Main_Product_Area__c from Opportunity where Id = : opp.Id];
            test.stoptest();
            
            //Assert
            System.assertEquals('Networks', o2.Main_Product_Area__c);
        }
    }

    @isTest static void deleteValueManuallyWhenProductDoesNOTExist(){
        
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
            test.starttest();
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Networks - Broadband';
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
            
            Opportunity o = [Select Main_Product_Area__c from Opportunity where Id = : opp.Id];
            
            o.Main_Product_Area__c = o.Main_Product_Area__c + 'IBS';
            update o;

            o.Main_Product_Area__c = 'Networks';  
            update o;
            test.stoptest();
            Opportunity o2 = [Select Main_Product_Area__c from Opportunity where Id = : opp.Id];
            
            //Assert
            System.assertEquals('Networks', o2.Main_Product_Area__c);
        }
    }
}