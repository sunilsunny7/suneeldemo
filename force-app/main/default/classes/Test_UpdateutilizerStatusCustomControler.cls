@isTest
public with sharing class Test_UpdateutilizerStatusCustomControler 
{
    @isTest
    public static void Test1(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            //salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager = Test_DataFactory.createAdminUser();
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode='C-OFFICE-365';
            prod.TeliaSE_MC_isCallOff_Flag__c = false;
            insert prod;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            insert prod1;
            pricebookId = stdPriceBookRecId ;
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            Account acc2= test_DataFactory.createOneSMEAccount();
            acc2.Org_Nr__c = '1234567671';
            insert acc2;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.recordtypeId = rt1.id;
            insert contract;
            contract.Status = 'active';
            update contract;
            
            Test.startTest();
            Utilizer_Contract_Relationship__c utilizer = new Utilizer_Contract_Relationship__c();
            utilizer.Org_Number__c = acc2.Org_Nr__c;
            utilizer.AccountId__c =acc2.id;
            utilizer.ContractNumber__c =contract.Id;
            utilizer.Utilizer_Role__c ='utilizer';
            utilizer.Status__c ='Aktiv';
            insert utilizer;            
            
            vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
            cli.name='Office';
            cli.vlocity_cmt__product2id__c=prod.id;
            cli.vlocity_cmt__ContractId__c=contract.id;
            cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
            insert cli;
            
            Account acc1=Test_DataFactory.createOneSMEAccount();
            acc1.FA_Contract__c=contract.id;
            insert acc1;
            
            acc.FA_Contract__c=contract.id;
            update acc;
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.TeliaSE_RenegotiatedAgreement__c=contract.id;
            qut.TeliaSE_Type__c='Renegotiation';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            qut.TeliaSE_RevisedAgreement__c=contract.id;
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            insert qut;
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli3.QuoteId = qut.id;
            oli3.UnitPrice = 200;
            oli3.Quantity = 4;
            oli3.vlocity_cmt__Product2Id__c = prod.id;
            oli3.Product2Id = prod.id;
            oli3.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli3.TeliaSE_Approved__c = null;
            oli3.vlocity_cmt__RecurringCharge__c  = 200;
            oli3.TeliaSE_Ceiling_Price__c = 400;
            oli3.TeliaSE_Root_Product__c=prod.id;
            insert oli3; 
            
            oli3.vlocity_cmt__RootItemId__c = oli3.id;
            update oli3;              
            
            
            List<Utilizer_Contract_Relationship__c> utilList = new List<Utilizer_Contract_Relationship__c>();
            utilList.add(utilizer);
            //Test.setCurrentPage(Page.YOUR_PAGE);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(utilList);
            stdSetController.setSelected(utilList);
            UpdateUtiliserStatusCustomController ext = new UpdateUtiliserStatusCustomController(stdSetController);
            PageReference pg = ext.updateSelectedRecords();
            Test.stopTest();
        }
    }
    
    @isTest
    public static void Test3(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            //salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager = Test_DataFactory.createAdminUser();
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode='C-OFFICE-365';
            prod.TeliaSE_MC_isCallOff_Flag__c = false;
            insert prod;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            insert prod1;
            pricebookId = stdPriceBookRecId ;
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            Account acc2= test_DataFactory.createOneSMEAccount();
            acc2.Org_Nr__c = '1234567671';
            insert acc2;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.recordtypeId = rt1.id;
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;            
            insert contract;
            contract.Status = 'Active';
            update contract;
            
            
            Test.startTest();
            Utilizer_Contract_Relationship__c utilizer = new Utilizer_Contract_Relationship__c();
            utilizer.Org_Number__c = acc2.Org_Nr__c;
            utilizer.AccountId__c =acc2.id;
            utilizer.ContractNumber__c =contract.Id;
            utilizer.Utilizer_Role__c ='utilizer';
            utilizer.Status__c ='PendingInactive';
            insert utilizer;            
            
            vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
            cli.name='Office';
            cli.vlocity_cmt__product2id__c=prod.id;
            cli.vlocity_cmt__ContractId__c=contract.id;
            cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
            insert cli;
            
            Account acc1=Test_DataFactory.createOneSMEAccount();
            acc1.FA_Contract__c=contract.id;
            insert acc1;
            
            acc.FA_Contract__c=contract.id;
            update acc;
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.TeliaSE_RenegotiatedAgreement__c=contract.id;
            qut.TeliaSE_Type__c='Renegotiation';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            qut.TeliaSE_RevisedAgreement__c=contract.id;
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            insert qut;
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli3.QuoteId = qut.id;
            oli3.UnitPrice = 200;
            oli3.Quantity = 4;
            oli3.vlocity_cmt__Product2Id__c = prod.id;
            oli3.Product2Id = prod.id;
            oli3.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli3.TeliaSE_Approved__c = null;
            oli3.vlocity_cmt__RecurringCharge__c  = 200;
            oli3.TeliaSE_Ceiling_Price__c = 400;
            oli3.TeliaSE_Root_Product__c=prod.id;
            insert oli3; 
            
            oli3.vlocity_cmt__RootItemId__c = oli3.id;
            update oli3;              
            
            
            List<Utilizer_Contract_Relationship__c> utilList = new List<Utilizer_Contract_Relationship__c>();
            utilList.add(utilizer);
            //Test.setCurrentPage(Page.YOUR_PAGE);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(utilList);
            stdSetController.setSelected(utilList);
            UpdateUtiliserStatusCustomController ext = new UpdateUtiliserStatusCustomController(stdSetController);
            PageReference pg = ext.updateSelectedRecords();
            Test.stopTest();
        }
    }
    
      @isTest
    public static void Test2(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            //salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager = Test_DataFactory.createAdminUser();
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode='C-OFFICE-365';
            prod.TeliaSE_MC_isCallOff_Flag__c = false;
            insert prod;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            insert prod1;
            pricebookId = stdPriceBookRecId ;
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            Account acc2= test_DataFactory.createOneSMEAccount();
            acc2.Org_Nr__c = '1234567671';
            insert acc2;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.recordtypeId = rt1.id;
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;            
            insert contract;
            contract.Status = 'Active';
            update contract;
            
            Test.startTest();
            Utilizer_Contract_Relationship__c utilizer = new Utilizer_Contract_Relationship__c();
            utilizer.Org_Number__c = acc2.Org_Nr__c;
            utilizer.AccountId__c =acc2.id;
            utilizer.ContractNumber__c =contract.Id;
            utilizer.Utilizer_Role__c ='utilizer';
            utilizer.Status__c ='PendingInactive';
            insert utilizer;            
            
            vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
            cli.name='Office';
            cli.vlocity_cmt__product2id__c=prod.id;
            cli.vlocity_cmt__ContractId__c=contract.id;
            cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
            insert cli;
            
            Account acc1=Test_DataFactory.createOneSMEAccount();
            acc1.FA_Contract__c=contract.id;
            insert acc1;
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.TeliaSE_RenegotiatedAgreement__c=contract.id;
            qut.TeliaSE_Type__c='Renegotiation';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            qut.TeliaSE_RevisedAgreement__c=contract.id;
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            insert qut;
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli3.QuoteId = qut.id;
            oli3.UnitPrice = 200;
            oli3.Quantity = 4;
            oli3.vlocity_cmt__Product2Id__c = prod.id;
            oli3.Product2Id = prod.id;
            oli3.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli3.TeliaSE_Approved__c = null;
            oli3.vlocity_cmt__RecurringCharge__c  = 200;
            oli3.TeliaSE_Ceiling_Price__c = 400;
            oli3.TeliaSE_Root_Product__c=prod.id;
            insert oli3; 
            
            oli3.vlocity_cmt__RootItemId__c = oli3.id;
            update oli3;              
            
            
            List<Utilizer_Contract_Relationship__c> utilList = new List<Utilizer_Contract_Relationship__c>();
            utilList.add(utilizer);
            //Test.setCurrentPage(Page.YOUR_PAGE);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(utilList);
            stdSetController.setSelected(utilList);
            UpdateUtiliserStatusCustomController ext = new UpdateUtiliserStatusCustomController(stdSetController);
            PageReference pg = ext.updateSelectedRecords();
            Test.stopTest();
        }
    }

}