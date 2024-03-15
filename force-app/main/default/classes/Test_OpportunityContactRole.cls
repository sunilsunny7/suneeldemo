/**
    About
    -----
    Description: Test Class to test that an Opportunity Contact Role with role 'Avtalstecknare' needs to be added before moving from opportunity stage Kvalificera
    Create date: May 2015
   
    Update History
    --------------
    Created May 2015 - V.I
    Updated May 2015 - Changed name on contact role from Ekonomisk köpare to Avtalstecknare
    Updated September 2015 - V.I/C.G Added Seller Register
    Updated September 2015 - AN New validation rules for record types related to Large - added three new test methods
    Updated May 2016 - A.N Updated Contact role reference from Avropare to Bestellare
    
    Issues / TODOs
    --------------
*/

@isTest
public class Test_OpportunityContactRole {

    @isTest static void no01_insertOpportunityIllegalStage(){
        System.debug('@@Test insertOpportunityIllegalStage Starts');
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
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_OFFER_NEGOTIATION;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            Test.StartTest();
            //Perform Test           
            try{
                insert opp;
                //System.assert(false, 'This update should not succeed due to opportunity validation rules');
            }
            catch(Exception e){
                System.debug('@@ message: ' + e.getMessage());
                //System.assert(e.getMessage().contains('Lägg till en avtalstecknare i fas Kvalificera'));
            }
            test.stoptest();
        }
    }

    @isTest static void no02_noOpportunityContactRoleSME(){
        System.debug('@@Test noOpportunityContactRole Starts');
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
            
            //Perform Test
            insert opp;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_DEVELOP;
            opp.Main_Product_Area__c = 'Test Procudt Area';
            try{
                update opp;
                //System.assert(false, 'This update should not succeed due to opportunity validation rules');
            }
            catch(Exception e){
                System.debug('@@ message: ' + e.getMessage());
                System.assert(e.getMessage().contains('Lägg till en'));
            }
            test.stoptest();
        }
    }

    @isTest static void no03_withOpportunityContactRoleSME_stageSolution(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);

            salesRep = smeUserTeam[2];
            System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            acc = Test_DataFactory.createOneSMEAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        System.runAs(salesRep){
            test.starttest();
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
            
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe.Id);
            insert oli;
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            OpportunityContactRole ocr = Test_DataFactory.createOpportunityContactRole();
            ocr.ContactId = c.Id;
            ocr.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr.OpportunityId = opp.Id;
            insert ocr;
            
            //Perform Test, set to next stage
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_SOLUTION;
            opp.Main_Product_Area__c = 'Services';
            update opp;            
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_SOLUTION);
            test.stoptest();
        }
    }
}
        
    @isTest static void no04_withOpportunityContactRoleSME_stageOfferNegotiation(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Account acc;

        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);

            salesRep = smeUserTeam[2];

            acc = Test_DataFactory.createOneSMEAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        System.runAs(salesRep){
            test.starttest();
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
            insert oli;
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            OpportunityContactRole ocr = Test_DataFactory.createOpportunityContactRole();
            ocr.ContactId = c.Id;
            ocr.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr.OpportunityId = opp.Id;
            insert ocr;
            
            //Perform Test, set to next stage
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_OFFER_NEGOTIATION;
            opp.Main_Product_Area__c = 'Services';
            update opp;            
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_OFFER_NEGOTIATION);
            test.stoptest();
        }
    }

    @isTest static void no05_withOpportunityContactRoleSME_stageCloseDeal(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);

            salesRep = smeUserTeam[2];
            System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            acc = Test_DataFactory.createOneSMEAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        System.runAs(salesRep){
            //test.starttest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.IsActive = true;
            insert p;
            
            Id pbId = Test.getStandardPricebookId();
            test.starttest();
            PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, p);
            pbe.UnitPrice = 1000;
            pbe.IsActive = true;
            insert pbe;
            
            PriceBookEntry pbe2 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p);
            pbe2.UnitPrice = 1000;
            pbe2.IsActive = true;
            insert pbe2;
            
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe2.Id);
            insert oli;
            
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            OpportunityContactRole ocr = Test_DataFactory.createOpportunityContactRole();
            ocr.ContactId = c.Id;
            ocr.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr.OpportunityId = opp.Id;
            insert ocr;
            
            //Perform Test, set to next stage
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL;
            opp.Main_Product_Area__c = 'Services';
            update opp;            
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL);
            test.stoptest();
        }
    }
}
        
    /**@isTest static void noOpportunityContactRoleLarge(){
        System.debug('@@Test noOpportunityContactRole Starts');
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
            Account acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id;
            
            //Perform Test
            insert opp;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_DEVELOP;
            opp.Category__c = 'Kategori 1';
            try{
                update opp;
                System.assert(false, 'This update should not succeed due to opportunity validation rules');
            }
            catch(Exception e){
                System.debug('@@ message: ' + e.getMessage());
                System.assert(e.getMessage().contains('Du måsta lägga till'));
            }
        }
    }

    @isTest static void withOpportunityContactRoleLarge_stageDevelop(){
        System.debug('@@Test withOpportunityContactRole Starts');
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
            Account acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc; 
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id; 
            
            insert opp;
            
            List<Contact> conList = Test_DataFactory.createContacts(2);
            insert conList;
            
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            OpportunityContactRole ocr1 = Test_DataFactory.createOpportunityContactRole();
            ocr1.ContactId = conList[0].Id;
            ocr1.Role = OpportunityValidationHandler.OPP_CR_DECISION_MAKER;
            ocr1.OpportunityId = opp.Id;
            ocrList.add(ocr1);
            OpportunityContactRole ocr2 = Test_DataFactory.createOpportunityContactRole();
            ocr2.ContactId = conList[1].Id;
            ocr2.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr2.OpportunityId = opp.Id;
            ocrList.add(ocr2);
            insert ocrList;
            
            //Perform Test, set to next stage
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_DEVELOP;
            opp.Category__c = 'Kategori 1';
            opp.Why_Change__c = 'Test';
            opp.Why_Now__c = 'Test';
            opp.Why_Telia__c = 'Test';
            opp.Current_Supplier__c = 'Test';
            update opp;            
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_DEVELOP);

            //Perform Test, set to won without closed activities
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            opp.Agreement_Signed__c = true;
            try{
                update opp;
                System.assert(false, 'This update should not succeed due to opportunity validation rules');
            }
            catch(Exception e){
                System.debug('@@ message: ' + e.getMessage());
                System.assert(e.getMessage().contains('Du måste ha genomfört minst en aktivitet'));
            }
        }
    }
    **/

    @isTest static void no06_withOpportunityContactRoleLarge_stageSolution(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

        System.runAs(salesRep){
            test.starttest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id;
            insert opp;
            
            List<Contact> conList = Test_DataFactory.createContacts(2);
            conList[0].AccountId = acc.Id;
            conList[1].AccountId = acc.Id;
            insert conList;
            
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            OpportunityContactRole ocr1 = Test_DataFactory.createOpportunityContactRole();
            ocr1.ContactId = conList[0].Id;
            ocr1.Role = OpportunityValidationHandler.OPP_CR_DECISION_MAKER;
            ocr1.OpportunityId = opp.Id;
            ocrList.add(ocr1);
            OpportunityContactRole ocr2 = Test_DataFactory.createOpportunityContactRole();
            ocr2.ContactId = conList[1].Id;
            ocr2.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr2.OpportunityId = opp.Id;
            ocrList.add(ocr2);
            insert ocrList;
            
            //Perform Test, set to next stage
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_SOLUTION;
            opp.Category__c = 'Kategori 1';
            opp.Why_Change__c = 'Test';
            opp.Why_Now__c = 'Test';
            opp.Why_Telia__c = 'Test';
            opp.Current_Supplier__c = 'Test';
            //opp.Customer_ratings_pointing_to_Telia__c = 'Test';
            opp.Competitors__c = 'Test';
            update opp;            
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_SOLUTION);
            test.stoptest();
        }
    }

    @isTest static void no07_withOpportunityContactRoleLarge_stageOfferNegotiation(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        Account acc;
        User salesRep;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

        System.runAs(salesRep){
            test.starttest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id; 
            
            insert opp;
            
            List<Contact> conList = Test_DataFactory.createContacts(2);
            conList[0].AccountId = acc.Id;
            conList[1].AccountId = acc.Id;
            insert conList;

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
            insert oli;
            
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            OpportunityContactRole ocr1 = Test_DataFactory.createOpportunityContactRole();
            ocr1.ContactId = conList[0].Id;
            ocr1.Role = OpportunityValidationHandler.OPP_CR_DECISION_MAKER;
            ocr1.OpportunityId = opp.Id;
            ocrList.add(ocr1);
            OpportunityContactRole ocr2 = Test_DataFactory.createOpportunityContactRole();
            ocr2.ContactId = conList[1].Id;
            ocr2.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr2.OpportunityId = opp.Id;
            ocrList.add(ocr2);
            insert ocrList;
            
            //Perform Test, set to next stage
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_OFFER_NEGOTIATION;
            opp.Category__c = 'Kategori 1';
            opp.Why_Change__c = 'Test';
            opp.Why_Now__c = 'Test';
            opp.Why_Telia__c = 'Test';
            opp.Current_Supplier__c = 'Test';
            //opp.Customer_ratings_pointing_to_Telia__c = 'Test';
            opp.Competitors__c = 'Test';
            opp.Risk_Analysis_Done_and_Uploaded__c = 'Ja';
            update opp;            
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_OFFER_NEGOTIATION);
            test.stoptest();
        }
    } 

    @isTest static void no08_withOpportunityContactRoleLarge_stageCloseDeal(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;

        }


        
        System.runAs(salesRep){
            //test.starttest();          
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id; 
            insert opp;

            Product2 p = Test_DataFactory.createProduct('Test');
            p.IsActive = true;
            insert p;
            test.starttest();
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
            insert oli;
            
            List<Contact> conList = Test_DataFactory.createContacts(2);
            conList[0].AccountId = acc.Id;
            conList[1].AccountId = acc.Id;
            insert conList;
            
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            OpportunityContactRole ocr1 = Test_DataFactory.createOpportunityContactRole();
            ocr1.ContactId = conList[0].Id;
            ocr1.Role = OpportunityValidationHandler.OPP_CR_DECISION_MAKER;
            ocr1.OpportunityId = opp.Id;
            ocrList.add(ocr1);
            OpportunityContactRole ocr2 = Test_DataFactory.createOpportunityContactRole();
            ocr2.ContactId = conList[1].Id;
            ocr2.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr2.OpportunityId = opp.Id;
            ocrList.add(ocr2);
            insert ocrList;

            // Create a closed task
            Task t = Test_DataFactory.createTaskWithWhatWhoId(opp.Id, conList[0].Id);
            t.Status = 'Stängd';
            insert t;

            //Perform Test, set to next stage
            opp.Deviations_from_General_Terms_Conditions__c = 'Nej';
            opp.Contract_start_date__c=System.today();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL;
            opp.Category__c = 'Kategori 1';
            opp.Why_Change__c = 'Test';
            opp.Why_Now__c = 'Test';
            opp.Why_Telia__c = 'Test';
            opp.Current_Supplier__c = 'Test';
            opp.Revenue_Start__c = System.today();
            //opp.Customer_ratings_pointing_to_Telia__c = 'Test';
            opp.Competitors__c = 'Test';
            opp.Risk_Analysis_Done_and_Uploaded__c = 'Ja';
            update opp;
            
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL);
            test.stoptest();
        }
    }

    @isTest static void no09_withOpportunityContactRoleAndActivitiesLarge(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

        System.runAs(salesRep){  
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id;
            
            insert opp;
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.IsActive = true;
            insert p;
            
            Id pbId = Test.getStandardPricebookId();
            
            PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, p);
            pbe.UnitPrice = 1000;
            pbe.IsActive = true;
            insert pbe;
            test.starttest();
            PriceBookEntry pbe2 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p);
            pbe2.UnitPrice = 1000;
            pbe2.IsActive = true;
            insert pbe2;
            
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe2.Id);
            insert oli;
            List<Contact> conList = Test_DataFactory.createContacts(2);
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            Event e = Test_DataFactory.createOneCompletedEvent();    
            
            
            conList[0].AccountId = acc.Id;
            conList[1].AccountId = acc.Id;
            insert conList;
            
            
            OpportunityContactRole ocr1 = Test_DataFactory.createOpportunityContactRole();
            ocr1.ContactId = conList[0].Id;
            ocr1.Role = OpportunityValidationHandler.OPP_CR_DECISION_MAKER;
            ocr1.OpportunityId = opp.Id;
            ocrList.add(ocr1);
            OpportunityContactRole ocr2 = Test_DataFactory.createOpportunityContactRole();
            ocr2.ContactId = conList[1].Id;
            ocr2.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr2.OpportunityId = opp.Id;
            ocrList.add(ocr2);
            insert ocrList;
            
            e.WhoId = conList[0].Id;
            e.WhatId = opp.Id;
            insert e;
           
            //Perform Test, set to won without closed activities
            opp.Deviations_from_General_Terms_Conditions__c = 'Nej';
            opp.Contract_start_date__c=System.today();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            opp.Agreement_Signed__c = true;
            opp.Category__c = 'Kategori 1';
            opp.Why_Change__c = 'Test';
            opp.Why_Now__c = 'Test';
            opp.Why_Telia__c = 'Test';
            opp.Current_Supplier__c = 'Test';
            opp.Revenue_Start__c = System.today();
            //opp.Customer_ratings_pointing_to_Telia__c = 'Test';
            opp.Competitors__c = 'Test';
            opp.Risk_Analysis_Done_and_Uploaded__c = 'Ja';
            opp.CCLM_Reference_Number__c = '87';
            opp.Competitor__c = 'Ingen huvudkonkurrent';
            opp.Comment_to_Reason__c = 'testcomment';
            opp.Reason__c = 'Pris';
            update opp;
 test.stoptest();
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_WON);
            
        }
    }

    @isTest static void no10_withOpportunityContactRoleAndSharedActivitiesLarge(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Account acc;
        
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            salesRep = smeUserTeam[2];
            test.starttest();
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

        System.runAs(salesRep){  
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id;
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
            insert oli;            
            
            List<Contact> conList = Test_DataFactory.createContacts(3);
            conList[0].AccountId = acc.Id;
            conList[1].AccountId = acc.Id;
            conList[2].AccountId = acc.Id;
            insert conList;
            
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
            OpportunityContactRole ocr1 = Test_DataFactory.createOpportunityContactRole();
            ocr1.ContactId = conList[0].Id;
            ocr1.Role = OpportunityValidationHandler.OPP_CR_DECISION_MAKER;
            ocr1.OpportunityId = opp.Id;
            ocrList.add(ocr1);
            OpportunityContactRole ocr2 = Test_DataFactory.createOpportunityContactRole();
            ocr2.ContactId = conList[1].Id;
            ocr2.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr2.OpportunityId = opp.Id;
            ocrList.add(ocr2);
            insert ocrList;
            
            /*
            //NOTE: It should be possible to add the Beslutsfattare as the non primary contact, but due to SF (Sync issue?) the related whoIds list is empty when running test. This works in the actual user interface!
            // Suspect that this issue is related to api version (TaskWhoIds / junctionIdList functionality only works for api 34 and higher)
            List<Id> eventWhoIds = new List<Id>();
            eventWhoIds.add(conList[2].Id); // This will set a contact without a oppContactRole as primary contact (WhoId)
            eventWhoIds.add(conList[0].Id); // Adding Beslutsfattare as a non primary contact to activity. No is primary actually here.
            Event e = Test_DataFactory.createEventWithWhatWhoIds(opp.Id, eventWhoIds);
            insert e;    (not)
            */   
            Event e = Test_DataFactory.createOneCompletedEvent();
            e.WhoId = conList[0].Id;
            e.WhatId = opp.Id;
            insert e;
            test.stoptest();
            //Perform Test, set to won without closed activities
            opp.Deviations_from_General_Terms_Conditions__c = 'Nej';
            opp.Contract_start_date__c=System.today();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            opp.Agreement_Signed__c = true;
            opp.Category__c = 'Kategori 1';
            opp.Why_Change__c = 'Test';
            opp.Why_Now__c = 'Test';
            opp.Why_Telia__c = 'Test';
            opp.Current_Supplier__c = 'Test';
            //opp.Customer_ratings_pointing_to_Telia__c = 'Test';
            opp.Competitors__c = 'Test';
            opp.Revenue_Start__c = System.today();
            opp.Risk_Analysis_Done_and_Uploaded__c = 'Ja';
            opp.CCLM_Reference_Number__c = '87';
            opp.Competitor__c = 'Ingen huvudkonkurrent';
            opp.Comment_to_Reason__c = 'testcomment';
            opp.Reason__c = 'Pris';
            update opp;

            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_WON);
            
        }
    }

    
    @isTest static void no11_noOpportunityContactRoleLargeUtokning(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

        System.runAs(salesRep){
            test.starttest();
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_ENLARGEMENT);
            opp.AccountId = acc.Id; 
            
            insert opp;

            //Perform Test, set to won without bestellare
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            opp.Agreement_Signed__c = true;
            try{
                update opp;
                System.assert(false, 'This update should not succeed due to opportunity validation rules');
            }
            catch(Exception e){
                System.debug('@@ message: ' + e.getMessage());
                System.assert(e.getMessage().contains('Du måsta lägga till'));
            }
            test.stoptest();
        }
    }

    @isTest static void no12_withOpportunityContactRoleLargeUtokning(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        Account acc;
         User salesRep;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
            salesRep = smeUserTeam[2];
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

    
        
        System.runAs(salesRep){
           
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_ENLARGEMENT);
            opp.AccountId = acc.Id;
            
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
            insert oli;
             test.starttest();
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
            insert c;
            
            OpportunityContactRole ocr = Test_DataFactory.createOpportunityContactRole();
            ocr.ContactId = c.Id;
            ocr.Role = OpportunityValidationHandler.OPP_CR_BESTELLARE;
            ocr.OpportunityId = opp.Id;
            insert ocr;
            

            //Perform Test, set to won without closed activities
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            opp.Agreement_Signed__c = true;
            opp.Revenue_Start__c = System.today();
            opp.Competitors__c = 'Test';
            update opp;
            //Assert
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_WON);
            test.stoptest();
        }
    }

    /*
    @isTest static void validateCygateStandardOpportunity(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();

        User cygateUser;
        Seller__c cygateSeller;

        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            cygateUser = Test_DataFactory.createCygateUser();
            insert cygateUser;
            cygateSeller = Test_DataFactory.createSeller(cygateUser.Id, null);
            insert cygateSeller;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        System.runAs(cygateUser){
            List<Contact> conList = Test_DataFactory.createContacts(2);
            insert conList;

            Opportunity opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            insert opp;
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_QUALIFY);

            // Move to stage OPP_STAGE_DEVELOP
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_DEVELOP;
            opp.Current_Supplier__c = 'Telia';

            OpportunityLineItem oli = Test_DataFactory.createProductAndOpportunityLineItem(opp.Id);
            oli.Solution_Area__c = 'Cygate Video';
            oli.Supplier__c = 'Cycast';
            oli.Sales_Type_Cygate__c = 'Cygate New Sales';
            oli.Start_Fee__c = 100;
            oli.Quantity = 1;
            insert oli;

            OpportunityContactRole ocr1 = Test_DataFactory.createOpportunityContactRole();
            ocr1.ContactId = conList[0].Id;
            ocr1.Role = OpportunityValidationHandler.OPP_CR_DECISION_MAKER;
            ocr1.OpportunityId = opp.Id;
            insert ocr1;

            Event e = Test_DataFactory.createCygateEvent();
            e.ActivityDateTime = System.now().addDays(1);
            e.WhatId = opp.Id;
            e.WhoId = conList[0].Id;
            insert e;

            update opp;
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_DEVELOP);

            // Move to stage OPP_STAGE_SOLUTION
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_SOLUTION;
            opp.Why_Cygate__c = 'Test';
            update opp;
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_SOLUTION);

            // Move to stage OPP_STAGE_OFFER_NEGOTIATION
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_OFFER_NEGOTIATION;
            update opp;
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_OFFER_NEGOTIATION);

            // Move to stage OPP_STAGE_CLOSE_DEAL
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL;

            OpportunityContactRole ocr2 = Test_DataFactory.createOpportunityContactRole();
            ocr2.ContactId = conList[1].Id;
            ocr2.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr2.OpportunityId = opp.Id;
            insert ocr2;

            update opp;
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL);

            // Move to stage OPP_STAGE_WON
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            opp.Agreement_Signed__c = true;
            update opp;
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_WON);
        }
    }

    @isTest static void validateCygateUtokningOpportunity(){
        System.debug('@@Test withOpportunityContactRole Starts');
        //Test Data Setup
        Test_DataFactory.setUpOrg();

        User cygateUser;
        Seller__c cygateSeller;

        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            cygateUser = Test_DataFactory.createCygateUser();
            insert cygateUser;
            cygateSeller = Test_DataFactory.createSeller(cygateUser.Id, null);
            insert cygateSeller;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;
        }

        System.runAs(cygateUser){
            List<Contact> conList = Test_DataFactory.createContacts(2);
            insert conList;

            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT);
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_OFFER_NEGOTIATION;
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            insert opp;
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_OFFER_NEGOTIATION);

            // Move to stage OPP_STAGE_CLOSE_DEAL
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL;

            OpportunityLineItem oli = Test_DataFactory.createProductAndOpportunityLineItem(opp.Id);
            oli.Solution_Area__c = 'Cygate Video';
            oli.Supplier__c = 'Cycast';
            oli.Sales_Type_Cygate__c = 'Cygate New Sales';
            oli.Start_Fee__c = 100;
            oli.Quantity = 1;
            insert oli;

            OpportunityContactRole ocr1 = Test_DataFactory.createOpportunityContactRole();
            ocr1.ContactId = conList[0].Id;
            ocr1.Role = OpportunityValidationHandler.OPP_CR_BESTELLARE;
            ocr1.OpportunityId = opp.Id;           
            insert ocr1;

            update opp;
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL);

            // Move to stage OPP_STAGE_WON
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            opp.Agreement_Signed__c = true;
            update opp;
            System.assertEquals(opp.StageName, OpportunityValidationHandler.OPP_STAGE_WON);
        }
    }*/
}