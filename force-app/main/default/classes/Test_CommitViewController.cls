/**
About
-----
Description: Test Class to test "CommitView" controller
Create date: Springtime 2015

Update History
--------------
Created Springtime 2015 - C.G.
Updated August 2015 - Added Sales_Unit__c,Sales_Team__c and Seller record creation for every time users are created. 
Updated September 2015 - Made some small changes to the "manager assertions" and added method testCommitViewControllerasSalesUnitManager.

Issues / TODOs
--------------  
*/

@isTest
public class Test_CommitViewController {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }   
    @isTest
    static void testCommitViewControllerasTeamManager(){
        
        User smeManager;
        User salesManager;
        User salesRep;

        System.runAs(new User(Id = Userinfo.getUserId())){
            // Create SME Manager and Sales Unit
            smeManager = Test_DataFactory.createSMEUser();
            insert smeManager;
            
            // Create Sales Manager and Sales Team
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
            
            // Create Sales Rep and create Seller records for both Sales Rep + Sales Manager
            salesRep = Test_DataFactory.createSalesRepUsers(1)[0];
            insert salesRep;
        }
         
        Map<Id, Seller__c> sellerMap = new Map<Id,Seller__c>();
        Seller__c salesUnitSeller = Test_DataFactory.createBusinessAreaManagerSeller(smeManager.Id);
        salesUnitSeller.Type__c = SellerTriggerHandler.SELLER_TYPE_SALES_UNIT_MGR;
        salesUnitSeller.Sales_Team_Name__c = 'Test Unit Name';
        insert salesUnitSeller;
        
        Seller__c teamSeller = Test_DataFactory.createSalesTeamManagerSeller(salesManager.Id, salesUnitSeller.Id);
        sellerMap.put(salesRep.Id, Test_DataFactory.createSeller(salesRep.Id, teamSeller.Id));
        sellerMap.put(salesManager.Id, teamSeller);
        insert sellerMap.values();
       
        //Create yearly targets
        Yearly_Target__c suManagerYT = Test_DataFactory.createOneYearlyTarget(salesUnitSeller);
        suManagerYT.User__c = salesManager.Id;
        suManagerYT.Seller__c = salesUnitSeller.Id;
        insert suManagerYT;
        
        Yearly_Target__c stManagerYT = Test_DataFactory.createOneYearlyTarget(sellerMap.get(salesManager.Id));
        stManagerYT.User__c = salesManager.Id;
        stManagerYT.Seller__c = sellerMap.get(salesManager.Id).Id;
        insert stManagerYT;
        
        Yearly_Target__c yt = Test_DataFactory.createOneYearlyTarget(sellerMap.get(salesRep.Id));
        yt.User__c = salesRep.Id;
        yt.Seller__c = sellerMap.get(salesRep.Id).Id;
        insert yt;
        Opportunity opp,opp2;
        Account act;
        Product2 prod;
        Id pricebookId;
        // RUN AS SM user
        System.runAs(salesManager){
             
            act = Test_DataFactory.createOneAccount();
            act.Owner = salesManager;
            insert act;
            prod = Test_DataFactory.createProducts(1)[0];
            insert prod;
            pricebookId = Test.getStandardPricebookId();
            opp = Test_DataFactory.createOwnedOpportunities(1, salesManager)[0];
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.Agreement_Signed__c = true;
            opp.Large_Continuation_Sales__c = 2;
            opp.CloseDate = System.today();
            insert opp;
            }          
            //Add Opportunity Contact Role, Products and set Opportunity Stage to Won
            Contact c = Test_DataFactory.createOneContact();
            c.AccountId = act.Id;
           // Test.startTest();
            insert c;
            System.runAs(salesManager){
            
            //Test.startTest();
            
            OpportunityContactRole ocr = Test_DataFactory.createOpportunityContactRole();
            ocr.ContactId = c.Id;
            ocr.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr.OpportunityId = opp.Id;
            insert ocr;
            //Test.startTest();
            PricebookEntry pbe = Test_DataFactory.createPricebookEntry(pricebookId, prod);
            insert pbe;
            
            PricebookEntry pbe1 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, prod);
            insert pbe1;
            
            Test.startTest();
            
            OpportunityLineItem oppLi = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe1.Id);
            insert oppLi;
            OpportunityLineItem oppL2 = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe1.Id);
            oppL2.Sales_purpose__c = 'Continuation Sales - Migrering av tjänst';
            insert oppL2;

            //Test.startTest();
            
            opp.Main_Product_Area__c = 'Other';
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;          
            update opp;
             
            //Test.startTest();
             //Test.stopTest();         
            CommitViewController controller = new CommitViewController();
            System.assertEquals(true, controller.UserIsManager,  'The user should be a manager');
            System.assertEquals(false, controller.UserIsSalesUnitManager,  'The user should not be a sales unit manager');
            System.assertEquals(String.valueOf(Date.today().year()), controller.selectedYear, 'The initial year should be this year');
            System.assertEquals('NewSales', controller.selectedSalesType,'The sales type should initially be set to Nya Pengar');
            System.assertEquals(5,controller.yearOptions.size(),  'There should only be as many yearoptions as there are yearlyTargets');
            System.assertEquals(4,controller.quarterOptions.size(),  'There should always be four quarters');
            System.assertEquals(2,controller.salesTypes.size(), 'There should only be 2 sales types');
            
            List<List<String>> commitViewList = new List<List<String>>();
            commitViewList.add(new List<String>{'1','Test Team Name','Test Unit Name','2000'}); // [[1,2000]]
            
            PageReference reference = Page.CommitView;
            reference.getParameters().put('commitValueString', JSON.serialize(commitViewList));
            Test.setCurrentPage(reference);
            
            controller.selectedSalesType = 'NewSales';
            controller.selectedQuarter = 'Q2';
            controller.selectedYear = yt.Name;
            
            PageReference commitSaved = controller.saveCommit();
            System.assertEquals('Commit Saved', controller.status, 'The commit of a Q1 and 2015 should work');
            Test.stopTest();
            controller.selectedSalesType = 'ContinuousSales';
            controller.selectedQuarter = 'Q2';
            controller.selectedYear = yt.Name;
            controller.saveCommit();
            
           // Test.stopTest();
        }
    }
    
    @isTest
    static void testCommitViewControllerasSalesUnitManager(){
        List<User> users = new List<User>(); 
        User smeManager;
        User salesManager;
        User salesRep;
        User BUmanager;
        List<Id> listofuserIds = new List<Id>();        


        System.runAs(new User(Id = Userinfo.getUserId())){
            BUmanager = Test_DataFactory.createSMEUser();
            users.add(BUmanager);

            // Create SME Manager and Sales Unit
            smeManager = Test_DataFactory.createSMEUser();
            users.add(smeManager);
            
            // Create Sales Manager and Sales Team
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            users.add(salesManager);
            
            // Create Sales Rep and create Seller records for both Sales Rep + Sales Manager
            salesRep = Test_DataFactory.createSalesRepUsers(1)[0];
            users.add(salesRep);

            insert users; 
        }
        
        Map<Id, Seller__c> sellerMap = new Map<Id,Seller__c>();
        Seller__c salesUnitSeller = Test_DataFactory.createBusinessAreaManagerSeller(smeManager.Id);
        salesUnitSeller.Type__c = SellerTriggerHandler.SELLER_TYPE_SALES_UNIT_MGR;
        salesUnitSeller.Sales_Team_Name__c = 'Test Unit Name';
        insert salesUnitSeller;
        
        Seller__c teamSeller = Test_DataFactory.createSalesTeamManagerSeller(salesManager.Id, salesUnitSeller.Id);
        sellerMap.put(salesRep.Id, Test_DataFactory.createSeller(salesRep.Id, teamSeller.Id));
        sellerMap.put(salesManager.Id, teamSeller);
        insert sellerMap.values();
        
        Test.startTest();
        for(User u :users)
        {
            listofuserIds.add(u.id);
        }
        System.runAs(smeManager){ // RUN AS SU USER
            Yearly_Target__c yt = Test_Datafactory.createOneYearlyTarget(salesUnitSeller);
            insert yt;
            PageReference pageRef = Page.CommitView;
            Test.setCurrentPage(pageRef);
            CommitViewController controller = new CommitViewController();
            System.assertEquals(false, controller.UserIsManager,  'The user should not be a team manager');
            System.assertEquals(true, controller.UserIsSalesUnitManager,  'The user should be a sales unit manager');
            System.assertEquals(String.valueOf(Date.today().year()), controller.selectedYear, 'The initial year should be this year');
            System.assertEquals('NewSales', controller.selectedSalesType,'The sales type should initially be set to Nya Pengar');
            System.assertEquals(5,controller.yearOptions.size(),  'There should only be as many yearoptions as there are yearlyTargets');
            System.assertEquals(4,controller.quarterOptions.size(),  'There should always be four quarters');
            System.assertEquals(2,controller.salesTypes.size(), 'There should only be 2 sales types');
            controller.createOwnerMap(listofuserIds);
            controller.getWeekInstances();
            
        }
        Test.stopTest();
    }
}