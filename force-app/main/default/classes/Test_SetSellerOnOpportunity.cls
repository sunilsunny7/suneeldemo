/**
    About
    -----
    Description: Test Class to test the functionality that relates an opportunity to a seller
    Create date: August 2015
   
    Update History
    --------------
    Created Aug 2015 - V.I no01-no10
    Updated Nov 2016 - A.N Added test methods no11-no17 for Cygate, PR opp record types (Seller not required), 
                        tests for Prospects (Seller required if Large user, but not for Cygate, PR, TAM users) and
                        tests for SME Record Type if TAM user (Seller not required)
    
    Issues / TODOs
    --------------  
*/

@isTest
public class Test_SetSellerOnOpportunity {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }

    // Author V.I
    static testMethod void no01_testInsertOpportunitySellerExists(){
        //Arrange
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }

        User salesRep = smeUserTeam[2];
        Seller__c seller = smeSellerTeam[2];

        System.runAs(salesRep) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            //Act
            Test.startTest();            
            insert opp;
            Test.stopTest();
        }
        
        //Assert
        Opportunity insertedOpp = [SELECT Seller__c FROM Opportunity]; 
        System.assertEquals(seller.Id, insertedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');
    }
 
    // Author V.I   
    static testMethod void no02_testInsertLargeOpportunitySellerExists(){
        //Arrange

        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;

        User salesRepAccount;
        Seller__c sellerAccount;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            // Create another salesRep that is the account owner
            salesRepAccount = Test_DataFactory.createLargeUser();
            insert salesRepAccount;
            sellerAccount = Test_DataFactory.createSeller(salesRepAccount.Id, largeSellerTeam[1].Id); //largeSellerTeam[1].Id is the id for the team manager 
            insert sellerAccount;
        }

        User salesRep = largeUserTeam[2];
        
        Account acc = Test_DataFactory.createOneLargeStandardAccount();
        acc.OwnerId = salesRepAccount.Id;
        insert acc; 

        System.runAs(salesRepAccount) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.OwnerId = salesRep.Id; 
            opp.AccountId = acc.Id; 
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            //Act
            Test.startTest();            
            insert opp;
            Test.stopTest();
        }
        
        //Assert
        Opportunity insertedOpp = [SELECT Seller__c FROM Opportunity]; 
        System.assertEquals(sellerAccount.Id, insertedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');
    }
  
    // Author V.I  
    static testMethod void no03_testUpdateOpportunityOwnerSellerExists(){
        //Arrange
        List<User> smeUserTeam1;
        List<Seller__c> smeSellerTeam1;
        List<User> smeUserTeam2;
        List<Seller__c> smeSellerTeam2;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of sme users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam1 = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam1 = Test_DataFactory.createSmeSellerTeam(smeUserTeam1);

            // returns list of sme users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam2 = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam2 = Test_DataFactory.createSmeSellerTeam(smeUserTeam2);
        }

        User salesRep1 = smeUserTeam1[2];
        User salesRep2 = smeUserTeam2[2];
        Seller__c seller2 = smeSellerTeam2[2];
        Test.startTest();
        System.runAs(salesRep1) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            insert opp;
            //Act
                        
            opp.OwnerId = salesRep2.Id;
            update opp;
            Test.stopTest();
        }
        
        //Assert
        Opportunity insertedOpp = [SELECT Seller__c FROM Opportunity]; 
        System.assertEquals(seller2.Id, insertedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');
    }
 
    // Author V.I   
    static testMethod void no04_testInsertSMEOpportunityOwnerSellerDoesNotExists(){
        //Arrange
        User salesRep;

        System.runAs(new User(Id = Userinfo.getUserId())){
            salesRep = Test_DataFactory.createSMEUser();
            insert salesRep;
        }

        Boolean oppInsertFailed = false;

        System.runAs(salesRep) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);            
            //Act
            Test.startTest();
            try{            
                insert opp;
            }
            catch(Exception e){
                //Assert
                oppInsertFailed = true;
                System.assert(e.getMessage().contains('Säljaren måste vara inlagd i säljarlistan för att kunna vara ägare av en affärsmöjlighet'),e.getMessage());
            }
            Test.stopTest();
        }
        System.assert(oppInsertFailed, 'The opp insert should have failed as there is no seller');     
    }

    // Author V.I    
    static testMethod void no05_testInsertLargeOpportunityOwnerSellerDoesNotExists(){
        //Arrange
        List<User> salesReps;
        User salesRep;
        User salesRepAccount;

        System.runAs(new User(Id = Userinfo.getUserId())){
            salesReps = Test_DataFactory.createSalesRepUsers(2);
            salesRep = Test_DataFactory.createLargeUser();
            salesReps.add(salesRep);
            salesRepAccount = Test_DataFactory.createLargeUser();
            salesReps.add(salesRepAccount);
            insert salesReps;
        }
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        Account acc = Test_DataFactory.createOneAccount();
        acc.OwnerId = salesRepAccount.Id;
        insert acc;

        Boolean oppInsertFailed = false;
        
        System.runAs(salesRep) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id; 
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            //Act
            Test.startTest();
            try{            
                insert opp;
            }
            catch(Exception e){
                //Assert
                oppInsertFailed = true;
                System.assert(e.getMessage().contains('Kontoägaren måste vara inlagd i säljarlistan'),e.getMessage());
            }
            Test.stopTest();
        }
        System.assert(oppInsertFailed, 'The opp insert should have failed as there is no seller');
    }
    }
    // Author V.I    
    static testMethod void no06_testUpdateOpportunityOwnerSellerDoesNotExists(){
        //Arrange

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Seller__c seller;
        User salesRep2;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of sme users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);

            salesRep = smeUserTeam[2];
            seller = smeSellerTeam[2];

            // Create another salesRep without seller record
            salesRep2 = Test_DataFactory.createsmeUser();
            insert salesRep2;
        }

        System.runAs(salesRep) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            insert opp;
            //Act
            Test.startTest();            
            opp.OwnerId = salesRep2.Id;
            try{            
                update opp;
            }
            catch(Exception e){
                //Assert
                System.assert(e.getMessage().contains('Säljaren måste vara inlagd i säljarlistan för att kunna vara ägare av en affärsmöjlighet'));
            }
            Test.stopTest();
        }
        
        //Assert
        Opportunity insertedOpp = [SELECT Seller__c FROM Opportunity]; 
        System.assertEquals(seller.Id, insertedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');        
    }

    // Author V.I    
    static testMethod void no07_testCloseOpportunityOwner(){
        //Arrange
        List<User> smeUserTeam;
        Seller__c unitLeader;
        Seller__c teamLeader;
        Seller__c seller;
        User salesRep;
        User salesTeamManager2;
        Seller__c salesTeamManagerSeller2;
        Account acc;
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI). 
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            unitLeader = Test_DataFactory.createSalesUnitManagerSeller(smeUserTeam[0].Id, null);
            Test.startTest();
            insert unitLeader;
            teamLeader = Test_DataFactory.createSalesTeamManagerSeller(smeUserTeam[1].Id, unitLeader.Id);
            insert teamLeader;
            seller = Test_DataFactory.createSeller(smeUserTeam[2].Id, teamLeader.Id);
           // seller.Start_Date__c = Date.parse('2015-01-05'); 
             seller.Start_Date__c = system.today(); 
            insert seller;

            salesRep = smeUserTeam[2];

            // Create a Sales Team Manager for another team
            salesTeamManager2 = Test_DataFactory.createSmeUser();
            insert salesTeamManager2;
            // Sales_Team_Name__c = 'Test Team Name', Sales_Team_Number__c = '123456',
            salesTeamManagerSeller2 = Test_DataFactory.createSalesTeamManagerSeller(salesTeamManager2.Id, unitLeader.Id);
            salesTeamManagerSeller2.Sales_Team_Name__c = 'Test Team Name 2';
            salesTeamManagerSeller2.Sales_Team_Number__c = '654321';
            insert salesTeamManagerSeller2;

            acc = Test_DataFactory.createOneSMEAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
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
        
        System.runAs(salesRep) {
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            insert opp;
            
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe2.Id);
            insert oli;
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = acc.Id;
           // Test.startTest();
            insert c;
            OpportunityContactRole ocr = Test_DataFactory.createOpportunityContactRole();
            ocr.ContactId = c.Id;
            ocr.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr.OpportunityId = opp.Id;
            Test.stopTest();
            insert ocr;
            
            opp.Agreement_Signed__c = true;
            opp.Main_Product_Area__c = 'Services';
             //Test.stopTest();
            //Act
            //Test.startTest();
           // seller.End_Date__c = Date.parse('2015-05-31'); 
            seller.End_Date__c = system.today()+1; 
            update seller;
            Seller__c seller2 = Test_DataFactory.createSeller(salesRep.Id, salesTeamManagerSeller2.Id);
           // seller2.Start_Date__c = Date.parse('2015-06-01');
            seller2.Start_Date__c = system.today();
          
            insert seller2;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            
            update opp;
            
           
            //Assert
            //Opportunity insertedOpp = [SELECT Seller__c FROM Opportunity limit 1]; 
            //System.assertEquals(seller2.Id, insertedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');    
        }               
    }

    // Author V.I    
    static testMethod void no08_testUpdateOpportunityOwnerNOTAttackTeam(){
        //Arrange
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Seller__c seller;
        User attackSalesTeamManager;
        Seller__c salesTeamManagerSeller;
        Seller__c attackTeamSeller;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);

            salesRep = smeUserTeam[2];
            seller = smeSellerTeam[2];

            // Create a Sales Team Manager for Attack
            attackSalesTeamManager = Test_DataFactory.createSmeUser();
            insert attackSalesTeamManager;

            // Create a Sales Team Manager Seller for Attack
            salesTeamManagerSeller = Test_DataFactory.createSalesTeamManagerSeller(attackSalesTeamManager.Id, smeSellerTeam[0].Id); // smeSellerTeam[0].Id is the Sales Unit Manager id
            salesTeamManagerSeller.Sales_Team_Name__c = 'SME Attack';
            salesTeamManagerSeller.Sales_Team_Number__c = '654321';
            insert salesTeamManagerSeller;

            // Create a Seller for Attack Team for the salesRep
            attackTeamSeller = Test_DataFactory.createSeller(salesRep.Id, salesTeamManagerSeller.Id);
            insert attackTeamSeller; 
            System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.Processed_By__c = 'Account Owner';
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

        System.runAs(salesRep) {
            //Act
            Test.startTest();            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            opp.AccountId = acc.Id;
            insert opp;
            Test.stopTest();
        }
        
        //Assert
        Opportunity insertedOpp = [SELECT Seller__c FROM Opportunity]; 
        System.assertEquals(seller.Id, insertedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');
    }
    }
    // Author V.I
    static testMethod void no09_testTwoSellerRecordsSameYear(){
        //Arrange
        List<User> smeUserTeam;
        Seller__c unitLeader;
        Seller__c teamLeader;
        Seller__c seller;
        User salesRep;
        Account acc;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI). 
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            unitLeader = Test_DataFactory.createSalesUnitManagerSeller(smeUserTeam[0].Id, null);
            insert unitLeader;
            teamLeader = Test_DataFactory.createSalesTeamManagerSeller(smeUserTeam[1].Id, unitLeader.Id);
            insert teamLeader;
            seller = Test_DataFactory.createSeller(smeUserTeam[2].Id, teamLeader.Id);
            seller.Start_Date__c = Date.parse('2015-01-05'); 
            insert seller;

            salesRep = smeUserTeam[2];
            System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            acc = Test_DataFactory.createOneSMEAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
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
        
        System.runAs(salesRep) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            insert opp;
            test.starttest();
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
            
            opp.Agreement_Signed__c = true;
            opp.Main_Product_Area__c = 'Services';
            
            //Act
            
            seller.End_Date__c = System.today().addDays(1); 
            update seller;
            Seller__c seller2 = Test_DataFactory.createSeller(salesRep.Id, teamLeader.Id);
            seller2.Start_Date__c = System.today().addDays(2);
            insert seller2;
            opp.CloseDate = System.today().addDays(3);
            update opp;
            Test.stopTest();
            
            //Assert
            Opportunity insertedOpp = [SELECT Seller__c FROM Opportunity]; 
            System.assertEquals(seller2.Id, insertedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');    
        }                  
    }
    }
        
    // Author V.I
    static testMethod void no10_changeAccountOnOpportunity(){
        //Arrange
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;

        User salesRep2;
        Seller__c seller2;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            // Create another salesRep that is the account owner
            salesRep2 = Test_DataFactory.createLargeUser();
            insert salesRep2;
            seller2 = Test_DataFactory.createSeller(salesRep2.Id, largeSellerTeam[1].Id); //largeSellerTeam[1].Id is the id for the team manager 
            insert seller2;
        }

        User salesRep = largeUserTeam[2];
        Seller__c seller = largeSellerTeam[2];
        
        Account acc = Test_DataFactory.createOneLargeStandardAccount();
        acc.OwnerId = salesRep.Id;
        insert acc;

        Account acc2 = Test_DataFactory.createOneLargeStandardAccount();
        acc2.OwnerId = salesRep2.Id;
        insert acc2; 

        Opportunity opp;
        // Create an opp on salesRep's own account
        System.runAs(salesRep) {
            opp = Test_DataFactory.createOpportunity();
            opp.OwnerId = salesRep.Id; 
            opp.AccountId = acc.Id; 
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            
            test.starttest();
            
            insert opp;
        }
        
        Opportunity insertedOpp = [SELECT Seller__c FROM Opportunity]; 
        System.assertEquals(seller.Id, insertedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');

        // Change Account to salesRep2's account
        System.runAs(new User(Id = Userinfo.getUserId())) {
            opp.AccountId = acc2.Id; 
            update opp;
        }

        Opportunity updatedOpp = [SELECT Seller__c FROM Opportunity]; 
        test.stoptest();
        System.assertEquals(seller2.Id, updatedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');
    }

    // Author A.N
    static testMethod void no11_testInsertCygateOpportunitySellerNotRequired(){
        User cygateUser;

        System.runAs(new User(Id = Userinfo.getUserId())){
            cygateUser = Test_DataFactory.createCygateUser();
            insert cygateUser;
        }
        
        Account acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
        acc.OwnerId = cygateUser.Id;
        insert acc; 
        
        Boolean oppInsertSuccess = true;

        System.runAs(cygateUser) {
            Opportunity opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Ej Kammarkollegiet';
            Test.startTest();
            try{            
                insert opp;
            }
            catch(Exception e){
                oppInsertSuccess = false;
            }
            Test.stopTest();
        }
        System.assert(oppInsertSuccess, 'The opp insert should have been successful as no seller is required for Cygate');
        List<Opportunity> newOpps = [SELECT Id FROM Opportunity WHERE AccountId = : acc.Id];
        System.assertEquals(newOpps.size(), 1, 'An opportunity should have been succesfully created as no seller is required for Cygate Opps');
    }

    // Author A.N
    // no need of this method now that PR Opportunities should have Sellers
    /*
    static testMethod void no12_testInsertPROpportunitySellerNotRequired(){
        User prUser;

        System.runAs(new User(Id = Userinfo.getUserId())){
            prUser = Test_DataFactory.createPRUser();
            insert prUser;
        }
        
        Boolean oppInsertSuccess = true;

        System.runAs(prUser) {
            Opportunity opp = Test_DataFactory.createPROpportunity();
            //Act
            Test.startTest();
            try{            
                insert opp;
            }
            catch(Exception e){
                oppInsertSuccess = false;
            }
            Test.stopTest();
        }
        System.assert(oppInsertSuccess, 'The opp insert should have been successful as no seller is required for PR');
        List<Opportunity> newOpps = [SELECT Id FROM Opportunity WHERE OwnerId = : prUser.Id];
        System.assertEquals(newOpps.size(), 1, 'An opportunity should have been succesfully created as no seller is required for PR Opps');
    }
    */

    // Author V.I    
    static testMethod void no13_testProspectLargeUserSellerRequired(){
        User largeUser;

        System.runAs(new User(Id = Userinfo.getUserId())){
            largeUser = Test_DataFactory.createLargeUser();
            insert largeUser;
        }
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        Account acc = Test_DataFactory.createOneAccount();
        acc.OwnerId = largeUser.Id;
        insert acc;

        Boolean oppInsertFailed = false;
        
        System.runAs(largeUser) {
            Opportunity opp = Test_DataFactory.createProspect();
            opp.AccountId = acc.Id;
            Test.startTest();
            try{            
                insert opp;
            }
            catch(Exception e){
                oppInsertFailed = true;
                System.assert(e.getMessage().contains('Kontoägaren måste vara inlagd i säljarlistan'),e.getMessage());
            }
            Test.stopTest();
        }
        System.assert(oppInsertFailed, 'The opp insert should have failed as there is no seller');
    }
    }
        
    // Author A.N
    static testMethod void no14_testProspectCygateUserSellerNotRequired(){
        User cygateUser;

        System.runAs(new User(Id = Userinfo.getUserId())){
            cygateUser = Test_DataFactory.createCygateUser();
            insert cygateUser;
        }
        
        Account acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
        acc.OwnerId = cygateUser.Id;
        insert acc; 
        
        Boolean oppInsertSuccess = true;

        System.runAs(cygateUser) {
            Opportunity opp = Test_DataFactory.createProspect();
            opp.AccountId = acc.Id;
            opp.New_Sales__c = 100;
            opp.Kammarkollegiet__c = 'Ej Kammarkollegiet';
            //Act
            Test.startTest();
            try{            
                insert opp;
            }
            catch(Exception e){
                System.debug(e.getMessage());
                oppInsertSuccess = false;
            }
            Test.stopTest();
        }
        System.assert(oppInsertSuccess, 'The prospect-opp insert should have been successful as no seller is required for Prospects created by Cygate Users');
        List<Opportunity> newOpps = [SELECT Id FROM Opportunity WHERE AccountId = : acc.Id];
        System.assertEquals(newOpps.size(), 1, 'A prospect should have been succesfully created as no seller is required for Prospects created by Cygate Users');
    }

    // Author A.N
    //no need of this method since Prospects created by SOHO PR User will need Seller on Prospects
    /*
    static testMethod void no15_testProspectPRUserSellerNotRequired(){
        User prUser;

        System.runAs(new User(Id = Userinfo.getUserId())){
            prUser = Test_DataFactory.createPRUser();
            insert prUser;
        }

        Account acc = Test_DataFactory.createOneAccount();
        acc.OwnerId = prUser.Id;
        insert acc; 
       
        Boolean oppInsertSuccess = true;

        System.runAs(prUser) {
            Opportunity opp = Test_DataFactory.createProspect();
            opp.AccountId = acc.Id;
            Test.startTest();
            try{            
                insert opp;
            }
            catch(Exception e){
                oppInsertSuccess = false;
            }
            Test.stopTest();
        }
        System.assert(oppInsertSuccess, 'The prospect-opp insert should have been successful as no seller is required for Prospects created by PR Users');
        List<Opportunity> newOpps = [SELECT Id FROM Opportunity WHERE OwnerId = : prUser.Id];
        System.assertEquals(newOpps.size(), 1, 'A prospect should have been succesfully created as no seller is required for Prospects created by PR Users');
    }
    */

    // Author A.N
    static testMethod void no16_testInsertSMEOpportunityTAMUserSellerNotRequired(){
        User tamUser;

        System.runAs(new User(Id = Userinfo.getUserId())){
            tamUser = Test_DataFactory.createTAMUser();
            insert tamUser;
        }

        Boolean oppInsertSuccess = true;

        System.runAs(tamUser) {
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD); 

            Test.startTest();
            try{            
                insert opp;
            }
            catch(Exception e){
                System.debug(e.getMessage());
                oppInsertSuccess = false;
            }
            Test.stopTest();
        }
       System.assert(oppInsertSuccess, 'The opp insert should have been successful as no seller is required for TAM users');
        List<Opportunity> newOpps = [SELECT Id FROM Opportunity WHERE OwnerId = : tamUser.Id];
       System.assertEquals(newOpps.size(), 1, 'An opportunity should have been succesfully created as no seller is required for SME Opps if the user is a TAM user');    
    }

    // Author A.N
    static testMethod void no17_testProspectTAMUserSellerNotRequired(){
        User tamUser;

        System.runAs(new User(Id = Userinfo.getUserId())){
            tamUser = Test_DataFactory.createTAMUser();
            insert tamUser;
        }
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        Account acc = Test_DataFactory.createOneAccount();
        acc.OwnerId = tamUser.Id;
        insert acc; 

        Boolean oppInsertSuccess = true;

        System.runAs(tamUser) {
            Opportunity opp = Test_DataFactory.createProspect();
            opp.AccountId = acc.Id;
            Test.startTest();
            try{            
                insert opp;
            }
            catch(Exception e){
                System.debug(e.getMessage());
                oppInsertSuccess = false;
            }
            Test.stopTest();
        }
        System.assert(oppInsertSuccess, 'The prospect-opp insert should have been successful as no seller is required for Prospects created by TAM Users');
        List<Opportunity> newOpps = [SELECT Id FROM Opportunity WHERE OwnerId = : tamUser.Id];
        System.assertEquals(newOpps.size(), 1, 'A prospect should have been succesfully created as no seller is required for Prospects created by TAM Users');
    }
    }
    // Author V.I    
    static testMethod void no18_testInsertOpportunityOwnerAttackTeam(){
         //Arrange
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        User salesRep;
        Seller__c seller;
        User attackSalesTeamManager;
        Seller__c salesTeamManagerSeller;
        Seller__c attackTeamSeller;
        Seller__c attackTeamSellerAfterInsert;
        Account acc;

        System.runAs(new User(Id = Userinfo.getUserId())){
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);

            salesRep = smeUserTeam[2];
            seller = smeSellerTeam[2];

            // Create a Sales Team Manager for Attack
            attackSalesTeamManager = Test_DataFactory.createSmeUser();
            insert attackSalesTeamManager;

            // Create a Sales Team Manager Seller for Attack
            salesTeamManagerSeller = Test_DataFactory.createSalesTeamManagerSeller(attackSalesTeamManager.Id, smeSellerTeam[0].Id); // smeSellerTeam[0].Id is the Sales Unit Manager id
            salesTeamManagerSeller.Sales_Team_Name__c = 'SME Attack';
            salesTeamManagerSeller.Sales_Team_Number__c = '654321';
            insert salesTeamManagerSeller;

            // Create a Seller for Attack Team for the salesRep
            attackTeamSeller = Test_DataFactory.createSeller(salesRep.Id, salesTeamManagerSeller.Id);
            insert attackTeamSeller;
            attackTeamSellerAfterInsert = [SELECT Sales_Team_Name__c, Sales_Team_Number__c FROM Seller__c WHERE Id = :attackTeamSeller.Id];
            System.assertEquals(attackTeamSellerAfterInsert.Sales_Team_Name__c, salesTeamManagerSeller.Sales_Team_Name__c, 'The Sellers Sales Team was not updated correctly based on the sales team manager');
            System.assertEquals(attackTeamSellerAfterInsert.Sales_Team_Number__c, salesTeamManagerSeller.Sales_Team_Number__c, 'The Sellers Sales Team was not updated correctly based on the sales team manager');
        
            System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            acc.Processed_By__c = 'Attack Team';
            acc.Attack_Team_Sales_Rep__c = salesRep.Id;
            acc.OwnerId = salesRep.Id;
            insert acc;
        }

        System.runAs(salesRep) {
            //Act
            Test.startTest();            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            insert opp;
            Test.stopTest();
        }
        
        //Assert
        Opportunity insertedOpp = [SELECT Seller__c FROM Opportunity]; 
        System.assertEquals(attackTeamSeller.Id, insertedOpp.Seller__c, 'The Seller was not updated correctly on the opportunity');
    }
}
}