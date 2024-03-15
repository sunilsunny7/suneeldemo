@isTest
public class Test_AccountServiceClass {

    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }
    
    @isTest static void testSolutionSalesOutcomeChangeRecordTypeLargeToSmall(){
        System.debug('@@Test ChangeRecordTypeLargeToSmall Starts');

        List<User> solutionUsers;
        System.runAs(new User(Id = Userinfo.getUserId())){
            solutionUsers = Test_DataFactory.createSolutionUsers(2);
            for(User u : solutionUsers){
                u.Bypass_VR__c = true;
            }
            insert solutionUsers;
        }

        System.runAs(solutionUsers[0]){
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
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
            
            Test.startTest();
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
                PriceBookEntry pbe1 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
                newEntries1.add(pbe1);
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
            
            //Assert
            Decimal expectedValue = 0; 
            lineItems = [Select Sales_Outcome_Solution__c, Product2.Family from OpportunityLineItem where OpportunityId = : opp.Id];
            for(OpportunityLineItem oli : lineItems){
                System.debug('oli.Sales_Outcome_Solution__c: ' + oli.Sales_Outcome_Solution__c);
                if(oli.Product2.Family == 'Cloud Networking'){
                    expectedValue += oli.Sales_Outcome_Solution__c;
                }
            }

            List<Sales_Outcome_Solutions__c> sosListBefore = [SELECT id, Opportunity__c FROM Sales_Outcome_Solutions__c Sales_Outcome_Solutions__c WHERE Opportunity__c = : opp.Id and User__c = : solutionUsers[1].Id];
            System.debug('sosListBefore: ' + sosListBefore);
            System.assertEquals(sosListBefore.size(),1);

            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            update acc;
            Test.stopTest();

            List<Sales_Outcome_Solutions__c> sosListAfter = [SELECT id, Opportunity__c FROM Sales_Outcome_Solutions__c Sales_Outcome_Solutions__c WHERE Opportunity__c = : opp.Id and User__c = : solutionUsers[1].Id];
            System.debug('sosListAfter: ' + sosListAfter);
            System.assertEquals(sosListAfter.size(),0);

        }
    }

    @isTest static void testSolutionSalesOutcomeChangeRecordTypeSmallToLarge(){
        System.debug('@@Test ChangeRecordTypeLargeToSmall Starts');
        
        List<User> solutionUsers;
        System.runAs(new User(Id = Userinfo.getUserId())){
            solutionUsers = Test_DataFactory.createSolutionUsers(2);
            for(User u : solutionUsers){
                u.Bypass_VR__c = true;
            }
            insert solutionUsers;
        }
        
        System.runAs(solutionUsers[0]){
            Account acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
            insert acc; 
            
            List<Seller__c> sellers = new List<Seller__c>();
            for(User u : solutionUsers){
                sellers.add(new Seller__c(User__c = u.Id, Start_Date__c = Date.today(), Sales_Unit_Name__c = 'Solutions', Sales_Team_Number__c = '12345', Type__c = 'Sales Unit Director'));
            }
            insert sellers;
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            opp.Revenue_Start__c = Date.today();
            opp.Customer_ratings_pointing_to_Telia__c = 'öojfsaoijdf';
            insert opp;
            
            Test.startTest();
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
            update opp;

            List<Sales_Outcome_Solutions__c> sosListBefore = [SELECT id, Opportunity__c FROM Sales_Outcome_Solutions__c Sales_Outcome_Solutions__c WHERE Opportunity__c = : opp.Id and User__c = : solutionUsers[1].Id];
            System.debug('sosListBefore: ' + sosListBefore);
            System.assertEquals(sosListBefore.size(),0);

            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
            update acc;
            Test.stopTest(); 

            List<Sales_Outcome_Solutions__c> sosListAfter = [SELECT id, Opportunity__c FROM Sales_Outcome_Solutions__c Sales_Outcome_Solutions__c WHERE Opportunity__c = : opp.Id and User__c = : solutionUsers[1].Id];
            System.debug('sosListAfter: ' + sosListAfter);
            System.assertEquals(sosListAfter.size(),1);
        }
    }
}