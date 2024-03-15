/**
    About
    -----
    Description: Test Class to test that the Sales Outcome is correctly calculated for Solutions
    Create date: October 2015
   
    Update History
    --------------
    Created Oct 2015 - V.I
    
    Issues / TODOs
    --------------  
*/

@isTest
public class Test_SolutionsSalesOutcome {

    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }
    
    @isTest static void opportunityOwner(){
        System.debug('@@Test opportunityOwner Starts');
        
        User solutionUser;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            solutionUser = Test_DataFactory.createSolutionUser();
            solutionUser.Bypass_VR__c = true;
            insert solutionUser;
        }
        
        System.runAs(solutionUser){
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId('Large_Sales_Organisation_Account');
            insert acc; 
            
            Seller__c seller = new Seller__c(User__c = solutionUser.Id, Start_Date__c = Date.today(), Sales_Unit_Name__c = 'Solutions', Sales_Team_Number__c = '12345', Type__c = 'Sales Unit Director');
            insert seller;
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.Revenue_Start__c = Date.today();
            opp.Customer_ratings_pointing_to_Telia__c = 'öojfsaoijdf';
            opp.CloseDate = Date.today();
            insert opp;
            
            Id pbId;
            List<Product2> newProducts = new List<Product2>();
            List<PriceBookEntry> newEntries = new List<PriceBookEntry>();
            List<PriceBookEntry> newEntries1 = new List<PriceBookEntry>();
            List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
            
            test.starttest();
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Cloud Networking';
            p.IsActive = true;
            newProducts.add(p);
            
            Product2 p2 = Test_DataFactory.createProduct('Test2');
            p2.Family = 'Unified Communications';
            p2.IsActive = true;
            newProducts.add(p2);
            
            Product2 p3 = Test_DataFactory.createProduct('Test3');
            p3.Family = 'Service';
            p3.IsActive = true;
            newProducts.add(p3);  
            insert newProducts;
            
            pbId = Test.getStandardPricebookId();
            
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, prod);
                newEntries.add(pbe);
            }
            insert newEntries; 
            
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
                newEntries1.add(pbe);
            }
            insert newEntries1; 
            
            for(PriceBookEntry pbe : newEntries1){
                OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe.Id);
                oli.Quantity = 1;
                oli.Start_Fee__c = 500;
                oli.Contact_Duration__c = 24;
                oli.Sales_purpose__c = 'New Sales - Nya tjänster';
                lineItems.add(oli);
            }
            insert lineItems;
            //test.stopTest();
            
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            update opp;
            
            //Assert
            Decimal expectedValue = 0; 
            lineItems = [Select Sales_Outcome_Solution__c, Product2.Family from OpportunityLineItem where OpportunityId = : opp.Id];
            for(OpportunityLineItem oli : lineItems){
                System.debug('oli.Sales_Outcome_Solution__c: ' + oli.Sales_Outcome_Solution__c);
                if(oli.Product2.Family == 'Service' || oli.Product2.Family == 'Cloud Networking'){
                    expectedValue += oli.Sales_Outcome_Solution__c;
                }
            }
            
            AggregateResult[] salesOutcome = [Select Sum(Sales_Outcome__c)s from Sales_Outcome_Solutions__c where Opportunity__c = : opp.Id];
            System.assertEquals(expectedValue , salesOutcome[0].get('s'), 'The correct outcome is ' + expectedValue + ', not ' + salesOutcome[0].get('s'));
            test.stopTest();
        }
    }
    
    @isTest static void opportunityTeamMember(){
        System.debug('@@Test opportunityTeamMember Starts');

        List<User> solutionUsers;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            solutionUsers = Test_DataFactory.createSolutionUsers(2);
            for(User u : solutionUsers){
                u.Bypass_VR__c = true;
            }
            insert solutionUsers;
        }
        
        System.runAs(solutionUsers[0]){
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId('Large_Sales_Organisation_Account');
            insert acc; 
            
            List<Seller__c> sellers = new List<Seller__c>();
            for(User u : solutionUsers){
                sellers.add(new Seller__c(User__c = u.Id, Start_Date__c = Date.today(), Sales_Unit_Name__c = 'Solutions', Sales_Team_Number__c = '12345', Type__c = 'Sales Unit Director'));
            }
            insert sellers;
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.Revenue_Start__c = Date.today();
            opp.Customer_ratings_pointing_to_Telia__c = 'öojfsaoijdf';
            insert opp;
            
            OpportunityTeamMember otm = new OpportunityTeamMember();
            List<Product2> newProducts = new List<Product2>();
            Id pbId;
            List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
            
            test.starttest();
            otm.OpportunityId = opp.Id;
            otm.UserId = solutionUsers[1].Id;
            insert otm;
            List<PriceBookEntry> newEntries = new List<PriceBookEntry>();
            List<PriceBookEntry> newEntries1 = new List<PriceBookEntry>();
                        
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Cloud Networking';
            p.IsActive = true;
            newProducts.add(p);
            
            Product2 p2 = Test_DataFactory.createProduct('Test2');
            p2.Family = 'Unified Communications';
            p2.IsActive = true;
            newProducts.add(p2);
            
            Product2 p3 = Test_DataFactory.createProduct('Test3');
            p3.Family = 'Service';
            p3.IsActive = true;
            newProducts.add(p3);  
            insert newProducts;
            
            pbId = Test.getStandardPricebookId();
            
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, prod);
                newEntries.add(pbe);
            }
            insert newEntries; 
            
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
                newEntries1.add(pbe);
            }
            insert newEntries1; 
            
            for(PriceBookEntry pbe : newEntries1){
                OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe.Id);
                oli.Quantity = 1;
                oli.Start_Fee__c = 500;
                oli.Contact_Duration__c = 24;
                oli.Sales_purpose__c = 'New Sales - Nya tjänster';
                lineItems.add(oli);
            }
            insert lineItems;
            //test.stoptest();
            
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            update opp;
            
            //Assert
            Decimal expectedValue = 0; 
            lineItems = [Select Sales_Outcome_Solution__c, Product2.Family from OpportunityLineItem where OpportunityId = : opp.Id];
            for(OpportunityLineItem oli : lineItems){
                System.debug('oli.Sales_Outcome_Solution__c: ' + oli.Sales_Outcome_Solution__c);
                if(oli.Product2.Family == 'Cloud Networking'){
                    expectedValue += oli.Sales_Outcome_Solution__c;
                }
            }
            
            AggregateResult[] salesOutcome = [Select Sum(Sales_Outcome__c)s from Sales_Outcome_Solutions__c where Opportunity__c = : opp.Id and User__c = : solutionUsers[1].Id];
            System.assertEquals(expectedValue , salesOutcome[0].get('s'), 'The correct outcome is ' + expectedValue + ', not ' + salesOutcome[0].get('s'));
            test.stoptest();
        }
    }
    
    @isTest static void accountTeamMember(){
        System.debug('@@Test accountTeamMember Starts');
        
        List<User> solutionUsers;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            solutionUsers = Test_DataFactory.createSolutionUsers(3);
            for(User u : solutionUsers){
                u.Bypass_VR__c = true;
            }
            insert solutionUsers;
        }
        
        System.runAs(solutionUsers[0]){
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId('Large_Sales_Organisation_Account');
            insert acc; 
            
            AccountTeamMember atm = new AccountTeamMember();
            atm.UserId = solutionUsers[2].Id;
            atm.AccountId = acc.Id;
            insert atm;
            
            List<Seller__c> sellers = new List<Seller__c>();
            for(User u : solutionUsers){
                sellers.add(new Seller__c(User__c = u.Id, Start_Date__c = Date.today(), Sales_Unit_Name__c = 'Solutions', Sales_Team_Number__c = '12345', Type__c = 'Sales Unit Director'));
            }
            insert sellers;
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.Revenue_Start__c = Date.today();
            opp.Customer_ratings_pointing_to_Telia__c = 'öojfsaoijdf';
            insert opp;
            List<Product2> newProducts = new List<Product2>();
            OpportunityTeamMember otm = new OpportunityTeamMember();
            List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
            Id pbId;                 
                                                    
            test.starttest();
            otm.OpportunityId = opp.Id;
            otm.UserId = solutionUsers[1].Id;
            insert otm;
            
            
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Cloud Networking';
            p.IsActive = true;
            newProducts.add(p);
            
            Product2 p2 = Test_DataFactory.createProduct('Test2');
            p2.Family = 'Unified Communications';
            p2.IsActive = true;
            newProducts.add(p2);
            
            Product2 p3 = Test_DataFactory.createProduct('Test3');
            p3.Family = 'Service';
            p3.IsActive = true;
            newProducts.add(p3);  
            insert newProducts;
            
            pbId = Test.getStandardPricebookId();
            
            List<PriceBookEntry> newEntries = new List<PriceBookEntry>();
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, prod);
                newEntries.add(pbe);
            }
            insert newEntries; 
            
            List<PriceBookEntry> newEntries1 = new List<PriceBookEntry>();
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
                newEntries1.add(pbe);
            }
            insert newEntries1; 

            for(PriceBookEntry pbe : newEntries1){
                OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe.Id);
                oli.Quantity = 1;
                oli.Start_Fee__c = 500;
                oli.Contact_Duration__c = 24;
                oli.Sales_purpose__c = 'New Sales - Nya tjänster';
                lineItems.add(oli);
            }
            insert lineItems;
            //test.stoptest();            
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            update opp;

            //Assert
            Decimal expectedValue = 0; 
            lineItems = [Select Sales_Outcome_Solution__c, Product2.Family from OpportunityLineItem where OpportunityId = : opp.Id];
            for(OpportunityLineItem oli : lineItems){
                System.debug('oli.Sales_Outcome_Solution__c: ' + oli.Sales_Outcome_Solution__c);
                if(oli.Product2.Family == 'Cloud Networking'){
                    expectedValue += oli.Sales_Outcome_Solution__c;
                }
            }
            
            AggregateResult[] salesOutcome = [Select Sum(Sales_Outcome__c)s from Sales_Outcome_Solutions__c where Opportunity__c = : opp.Id and User__c = : solutionUsers[2].Id];
            System.assertEquals(expectedValue , salesOutcome[0].get('s'), 'The correct outcome is ' + expectedValue + ', not ' + salesOutcome[0].get('s'));
            test.stoptest(); 
        }
    } 
    
    @isTest static void accountTeamMemberOtherSolutionArea(){
        System.debug('@@Test accountTeamMemberOtherSolutionArea Starts');
        
        UserRole r = [select id from userRole where developername='IBS_Team'];
        List<User> solutionUsers;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            solutionUsers = Test_DataFactory.createSolutionUsers(3);
            for(User u : solutionUsers){
                u.Bypass_VR__c = true;
                u.UserRoleId = r.Id;
            }
            insert solutionUsers;
        }
        
        System.runAs(solutionUsers[0]){
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId('Large_Sales_Organisation_Account');
            insert acc; 
            
            AccountTeamMember atm = new AccountTeamMember();
            atm.UserId = solutionUsers[2].Id;
            atm.AccountId = acc.Id;
            insert atm;
            
            List<Seller__c> sellers = new List<Seller__c>();
            for(User u : solutionUsers){
                sellers.add(new Seller__c(User__c = u.Id, Start_Date__c = Date.today(), Sales_Unit_Name__c = 'Solutions', Sales_Team_Number__c = '12345', Type__c = 'Sales Unit Director'));
            }
            insert sellers;
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.Revenue_Start__c = Date.today();
            opp.Customer_ratings_pointing_to_Telia__c = 'öojfsaoijdf';
            insert opp;
            
            OpportunityTeamMember otm = new OpportunityTeamMember();
            Id pbId;
            List<PriceBookEntry> newEntries = new List<PriceBookEntry>();
            List<PriceBookEntry> newEntries1 = new List<PriceBookEntry>();
            List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
            
            test.starttest();
            otm.OpportunityId = opp.Id;
            otm.UserId = solutionUsers[1].Id;
            insert otm;
            
            List<Product2> newProducts = new List<Product2>();
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'IBS';
            p.IsActive = true;
            newProducts.add(p);
            
            Product2 p2 = Test_DataFactory.createProduct('Test2');
            p2.Family = 'Unified Communications';
            p2.IsActive = true;
            newProducts.add(p2);
            
            Product2 p3 = Test_DataFactory.createProduct('Test3');
            p3.Family = 'Service';
            p3.IsActive = true;
            newProducts.add(p3);  
            insert newProducts;
            
            pbId = Test.getStandardPricebookId();
            
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, prod);
                newEntries.add(pbe);
            }
            insert newEntries; 
            
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
                newEntries.add(pbe);
            }
            insert newEntries1;
            for(PriceBookEntry pbe : newEntries1){
                OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe.Id);
                oli.Quantity = 1;
                oli.Start_Fee__c = 500;
                oli.Contact_Duration__c = 24;
                oli.Sales_purpose__c = 'New Sales - Nya tjänster';
                lineItems.add(oli);
            }
            insert lineItems;
            //test.StopTest();
            
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            update opp;
            
            AggregateResult[] salesOutcome = [Select Sum(Sales_Outcome__c)s from Sales_Outcome_Solutions__c where Opportunity__c = : opp.Id and User__c = : solutionUsers[2].Id];
            System.assertEquals(null , salesOutcome[0].get('s'), 'The correct outcome is ' + null + ', not ' + salesOutcome[0].get('s'));
            test.StopTest();
        }
    }

    @isTest static void deleteOpportunityTeamMember(){
        System.debug('@@Test opportunityTeamMember Starts');
        
        List<User> solutionUsers;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            solutionUsers = Test_DataFactory.createSolutionUsers(2);
            for(User u : solutionUsers){
                u.Bypass_VR__c = true;
            }
            insert solutionUsers;
        }
        
        System.runAs(solutionUsers[0]){
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId('Large_Sales_Organisation_Account');
            insert acc; 
            
            List<Seller__c> sellers = new List<Seller__c>();
            for(User u : solutionUsers){
                sellers.add(new Seller__c(User__c = u.Id, Start_Date__c = Date.today(), Sales_Unit_Name__c = 'Solutions', Sales_Team_Number__c = '12345', Type__c = 'Sales Unit Director'));
            }
            insert sellers;
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.Revenue_Start__c = Date.today();
            opp.Customer_ratings_pointing_to_Telia__c = 'öojfsaoijdf';
            insert opp;
            test.starttest();
            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.OpportunityId = opp.Id;
            otm.UserId = solutionUsers[1].Id;
            insert otm;
            
            List<Product2> newProducts = new List<Product2>();
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Cloud Networking';
            p.IsActive = true;
            newProducts.add(p);
            
            Product2 p2 = Test_DataFactory.createProduct('Test2');
            p2.Family = 'Unified Communications';
            p2.IsActive = true;
            newProducts.add(p2);
            
            Product2 p3 = Test_DataFactory.createProduct('Test3');
            p3.Family = 'Service';
            p3.IsActive = true;
            newProducts.add(p3);  
            insert newProducts;
            
            Id pbId = Test.getStandardPricebookId();
            
            List<PriceBookEntry> newEntries = new List<PriceBookEntry>();
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, prod);
                newEntries.add(pbe);
            }
            insert newEntries; 
            List<PriceBookEntry> newEntries1 = new List<PriceBookEntry>();
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
                newEntries1.add(pbe);
            }
            insert newEntries1; 
            
            List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
            for(PriceBookEntry pbe : newEntries1){
                OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe.Id);
                oli.Quantity = 1;
                oli.Start_Fee__c = 500;
                oli.Contact_Duration__c = 24;
                oli.Sales_purpose__c = 'New Sales - Nya tjänster';
                lineItems.add(oli);
            }
            insert lineItems;
            
            
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            //update opp;
             test.stoptest();
            delete otm;
           
            AggregateResult[] salesOutcome = [Select Sum(Sales_Outcome__c)s from Sales_Outcome_Solutions__c where Opportunity__c = : opp.Id and User__c = : solutionUsers[1].Id];
            System.assertEquals(null , salesOutcome[0].get('s'), 'The correct outcome is ' + null + ', not ' + salesOutcome[0].get('s'));
        }
    }
    
    @isTest static void addOpportunityTeamMemberonWonOpp(){
        System.debug('@@Test opportunityTeamMember Starts');
        
        List<User> solutionUsers;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            solutionUsers = Test_DataFactory.createSolutionUsers(3);
            for(User u : solutionUsers){
                u.Bypass_VR__c = true;
            }
            insert solutionUsers;
        }
        
        System.runAs(solutionUsers[0]){
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId('Large_Sales_Organisation_Account');
            insert acc; 
            
            List<Seller__c> sellers = new List<Seller__c>();
            for(User u : solutionUsers){
                sellers.add(new Seller__c(User__c = u.Id, Start_Date__c = Date.today(), Sales_Unit_Name__c = 'Solutions', Sales_Team_Number__c = '12345', Type__c = 'Sales Unit Director'));
            }
            insert sellers;
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.Revenue_Start__c = Date.today();
            opp.Customer_ratings_pointing_to_Telia__c = 'Test Customer rating points text';
            insert opp;
            
            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.OpportunityId = opp.Id;
            otm.UserId = solutionUsers[1].Id;
            insert otm;
            
            List<Product2> newProducts = new List<Product2>();
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Cloud Networking';
            p.IsActive = true;
            newProducts.add(p);
            
            Product2 p2 = Test_DataFactory.createProduct('Test2');
            p2.Family = 'Unified Communications';
            p2.IsActive = true;
            newProducts.add(p2);
            Test.startTest();
            Product2 p3 = Test_DataFactory.createProduct('Test3');
            p3.Family = 'Service';
            p3.IsActive = true;
            newProducts.add(p3);  
            insert newProducts;
            
            Id pbId = Test.getStandardPricebookId();
            
            List<PriceBookEntry> newEntries = new List<PriceBookEntry>();
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, prod);
                newEntries.add(pbe);
            }
            insert newEntries; 
            List<PriceBookEntry> newEntries1 = new List<PriceBookEntry>();
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
                newEntries1.add(pbe);
            }
            insert newEntries1; 
            
            List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
            for(PriceBookEntry pbe : newEntries1){
                OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe.Id);
                oli.Quantity = 1;
                oli.Start_Fee__c = 500;
                oli.Contact_Duration__c = 24;
                oli.Sales_purpose__c = 'New Sales - Nya tjänster';
                lineItems.add(oli);
            }
            insert lineItems;

            
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            update opp;
            
            OpportunityTeamMember otm2 = new OpportunityTeamMember();
            otm2.OpportunityId = opp.Id;
            otm2.UserId = solutionUsers[2].Id;
            insert otm2;
Test.stopTest();
            //Assert
            Decimal expectedValue = 0; 
            lineItems = [Select Sales_Outcome_Solution__c, Product2.Family from OpportunityLineItem where OpportunityId = : opp.Id];
            for(OpportunityLineItem oli : lineItems){
                System.debug('oli.Sales_Outcome_Solution__c: ' + oli.Sales_Outcome_Solution__c);
                if(oli.Product2.Family == 'Cloud Networking'){
                    expectedValue += oli.Sales_Outcome_Solution__c;
                }
            }
            

            AggregateResult[] salesOutcome = [Select Sum(Sales_Outcome__c)s from Sales_Outcome_Solutions__c where Opportunity__c = : opp.Id and User__c = : solutionUsers[2].Id];
            System.assertEquals(expectedValue , salesOutcome[0].get('s'), 'The correct outcome is ' + expectedValue + ', not ' + salesOutcome[0].get('s'));
        }
    }
    
    @isTest static void updateProductsOnWonOpp(){
        System.debug('@@Test opportunityOwner Starts');
        
        User solutionUser;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            solutionUser = Test_DataFactory.createSolutionUser();
            solutionUser.Bypass_VR__c = true;
            insert solutionUser;
        }
        
        System.runAs(solutionUser){
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId('Large_Sales_Organisation_Account');
            insert acc; 
            
            Seller__c seller = new Seller__c(User__c = solutionUser.Id, Start_Date__c = Date.today(), Sales_Unit_Name__c = 'Solutions', Sales_Team_Number__c = '12345', Type__c = 'Sales Unit Director');
            insert seller;
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.Revenue_Start__c = Date.today();
            opp.Customer_ratings_pointing_to_Telia__c = 'öojfsaoijdf';
            opp.CloseDate = Date.today();
            
            insert opp;
            
            List<Product2> newProducts = new List<Product2>();
            Product2 p = Test_DataFactory.createProduct('Test');
            p.Family = 'Cloud Networking';
            p.IsActive = true;
            newProducts.add(p);
            
            Product2 p2 = Test_DataFactory.createProduct('Test2');
            p2.Family = 'Unified Communications';
            p2.IsActive = true;
            newProducts.add(p2);
            
            Product2 p3 = Test_DataFactory.createProduct('Test3');
            p3.Family = 'Service';
            p3.IsActive = true;
            newProducts.add(p3);  
            insert newProducts;
            
            Id pbId = Test.getStandardPricebookId();
            
            List<PriceBookEntry> newEntries = new List<PriceBookEntry>();
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, prod);
                newEntries.add(pbe);
            }
            insert newEntries; 
            
            List<PriceBookEntry> newEntries1 = new List<PriceBookEntry>();
            for(Product2 prod : newProducts){
                PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
                newEntries1.add(pbe);
            }
            insert newEntries1;
            
            List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
            for(PriceBookEntry pbe : newEntries1){
                OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe.Id);
                oli.Quantity = 1;
                oli.Start_Fee__c = 500;
                oli.Contact_Duration__c = 24;
                oli.Sales_purpose__c = 'New Sales - Nya tjänster';
                lineItems.add(oli);
            }
             
            test.starttest();
            insert lineItems;
            
           
            
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            
           update opp;
            
            for(OpportunityLineItem oli : lineItems){
                oli.Quantity = 2;
            }
            //update lineItems;
            
            /*
            //Assert
            Decimal expectedValue = 0; 
            //lineItems = [Select Sales_Outcome_Solution__c, Product2.Family from OpportunityLineItem where OpportunityId = : opp.Id];
            for(OpportunityLineItem oli : lineItems){
                System.debug('oli.Sales_Outcome_Solution__c: ' + oli.Sales_Outcome_Solution__c);
                if(oli.Product2.Family == 'Service' || oli.Product2.Family == 'Cloud Networking'){
                    expectedValue += oli.Sales_Outcome_Solution__c;
                }
            }
            
            
            */
            //AggregateResult[] salesOutcome = [Select Sum(Sales_Outcome__c)s from Sales_Outcome_Solutions__c where Opportunity__c = : opp.Id];
            //System.assertEquals(expectedValue , salesOutcome[0].get('s'), 'The correct outcome is ' + expectedValue + ', not ' + salesOutcome[0].get('s'));
        }
    } 
}