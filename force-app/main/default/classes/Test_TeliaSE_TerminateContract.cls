@isTest
public with sharing class Test_TeliaSE_TerminateContract {   
    @isTest()
    public static void testTerminate(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;        
        System.runAs(salesManager){
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode='C-OFFICE-365';
            prod.TeliaSE_MC_isCallOff_Flag__c = false;
            insert prod;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.ProductCode = 'MOB_MULTI_ALL_IN_PLUS_V2';
            insert prod1;
            pricebookId = stdPriceBookRecId ;
            
            TeliaSE_PortfolioIdentifiers__c tc = new TeliaSE_PortfolioIdentifiers__c();
            tc.Name = 'Mobile';
            tc.NewProductCode__c = 'MOB_MULTI_ALL_IN_PLUS_V3';
            tc.OldProductCode__c = 'MOB_MULTI_ALL_IN_PLUS_V2';
            tc.ProductId__c = prod1.id;
            insert tc; 
           
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;

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
            contract.Status='Active';
            update contract;
            
            Contract contract1=new Contract();
            contract1.Name='Test1';
            contract1.AccountId=acc.id;
            contract1.Status='Draft';
            contract1.Solution_Area__c='Vxl';
            contract1.StartDate=Date.today();
            contract1.ContractTerm=24;
            contract1.recordtypeId = rt1.id;
            insert contract1;
            
            Contract contract2=new Contract();
            contract2.Name='Test2';
            contract2.AccountId=acc.id;
            contract2.Status='Draft';
            contract2.Solution_Area__c='Vxl';
            contract2.StartDate=Date.today();
            contract2.ContractTerm=24;
            contract2.recordtypeId = rt1.id;
            insert contract2;


            contract2.Status='Sent for Approval';
            update contract2;
            
            scrive__ScriveDocument__c sc = new scrive__ScriveDocument__c();
            sc.scrive__status__c = 'Signed';
            sc.scrive__Contract__c = contract2.id;
            insert sc;

            vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
            cli.name='Office';
            cli.vlocity_cmt__product2id__c=prod.id;
            cli.vlocity_cmt__ContractId__c=contract.id;
            cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
            insert cli;
            
            scrive__ScriveDocument__c scd = new scrive__ScriveDocument__c();
            scd.scrive__Contract__c = contract2.id;
            insert scd;
            
            Map<String,Object> inputMap=new Map<String,Object>();
            Map<String,Object> inputMap1=new Map<String,Object>();
            Map<String,Object> inputMap2=new Map<String,Object>();
            Map<String,Object> inputMap3=new Map<String,Object>();
            Map<String,Object> inputMap4=new Map<String,Object>();
            Map<String,Object> outMap=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            Map<String,Object> quoteMap=new Map<String,Object>();

            
            inputMap.put('ContextId', contract2.id);
            inputMap1.put('ContextId', contract1.id);
            inputMap2.put('ContextId', contract.id);
            test.startTest();
            TeliaSE_TerminateContract terminateClass = new TeliaSE_TerminateContract();
           // terminateClass.invokeMethod('validateRevisedContract', inputMap1, outMap, options);
           // terminateClass.invokeMethod('validateRevisedContract', inputMap, outMap, options);
            terminateClass.invokeMethod('getStatus', inputMap1, outMap, options);
            terminateClass.invokeMethod('viewScriveDocument', inputMap, outMap, options);
            terminateClass.invokeMethod('viewScriveDocument', inputMap1, outMap, options);
            terminateClass.invokeMethod('validateStatus', inputMap, outMap, options);
            terminateClass.invokeMethod('validateStatus', inputMap1, outMap, options);
            terminateClass.invokeMethod('confirmationReset', inputMap1, outMap, options);
            terminateClass.invokeMethod('resetCommercialTerms', inputMap, outMap, options);
            
            terminateClass.invokeMethod('cancelScriveDocument', inputMap, outMap, options);            

            terminateClass.invokeMethod(null, inputMap1, outMap, options);
            terminateClass.invokeMethod('', inputMap1, outMap, options);
            test.stopTest();
        }
    }
    
    @isTest()
    public static void testTerminate2(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();

            salesManager = Test_DataFactory.createAdminUser();
            salesManager.ForecastEnabled = true;
            salesManager.Bypass_VR__c = true;
            insert salesManager;        
        
        System.runAs(salesManager){

            //Add Prod
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode='C-OFFICE-365';
            prod.TeliaSE_MC_isCallOff_Flag__c = false;
            insert prod;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.productCode = 'MOB_MULTI_ALL_IN_PLUS_V2';            
            insert prod1;
            pricebookId = stdPriceBookRecId ;

            TeliaSE_PortfolioIdentifiers__c tc = new TeliaSE_PortfolioIdentifiers__c();
            tc.Name = 'Mobile';
            tc.NewProductCode__c = 'MOB_MULTI_ALL_IN_PLUS_V3';
            tc.OldProductCode__c = 'MOB_MULTI_ALL_IN_PLUS_V2';
            tc.ProductId__c = prod1.id;
            insert tc; 
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;

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
            Contract contract1=new Contract();
            contract1.Name='Test1';
            contract1.AccountId=acc.id;
            contract1.Status='Draft';
            contract1.Solution_Area__c='Vxl';
            contract1.StartDate=Date.today();
            contract1.ContractTerm=24;
            contract1.recordtypeId = rt1.id;
            insert contract1;
            
            Contract contract2=new Contract();
            contract2.Name='Test1';
            contract2.AccountId=acc.id;
            contract2.Status='Draft';
            contract2.Solution_Area__c='Vxl';
            contract2.StartDate=Date.today();
            contract2.ContractTerm=24;   
            contract2.recordtypeId = rt1.id;
            insert contract2;
            contract2.status = 'Signed';
            update contract2;
            
            vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
            cli.vlocity_cmt__ProductId__c = prod1.id;
            cli.vlocity_cmt__ContractId__c = contract1.id;
            insert cli;
            
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('ContextId',contract1.id);
            test.startTest();
            TeliaSE_TerminateContract terminateClass = new TeliaSE_TerminateContract();
            terminateClass.invokeMethod('validateEsign', inputMap, inputMap, inputMap);
            
            inputMap.put('ContextId',contract2.id);
          //  terminateClass.invokeMethod('validateRevisedContract', inputMap, inputMap, inputMap);  
            terminateClass.invokeMethod('unlockContract', inputMap, inputMap, inputMap);
            test.stopTest();                      
          }
    }
    @isTest()
    public static void validateRevisedContract(){
        User salesManager; 
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            
            TeliaSE_TerminateContract terminateClass = new TeliaSE_TerminateContract();
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contract Quote').getRecordTypeId();
            Quote qut = new Quote();
            qut.Name='Sample Quote';
            qut.status = 'Draft';
            qut.TeliaSE_Type__c='Renegotiation';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False; 
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            qut.RecordTypeId = recId;
            insert qut;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            
            Contract contract1=new Contract();
            contract1.Name='Test1';
            contract1.AccountId=acc.id;
            contract1.Status='Draft';
            contract1.Solution_Area__c='Vxl';
            contract1.StartDate=Date.today();
            contract1.ContractTerm=24;
            contract1.recordtypeId = rt1.id;
            contract1.vlocity_cmt__QuoteId__c = qut.Id;
            insert contract1;
            
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('contextId',contract1.id);
            Map<String,Object> inputMap1 = new Map<String,Object>();
            inputMap1.put('contextId',qut.Id);
            
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> optionsMap = new Map<String,Object>();
            
            test.startTest();
            terminateClass.invokeMethod('validateRevisedContract', inputMap, outMap, optionsMap);
            terminateClass.invokeMethod('validateRevisedContract', inputMap1, outMap, optionsMap);
            contract1.Status = 'Sent for Approval';
            update contract1;
            terminateClass.invokeMethod('validateRevisedContract', inputMap, outMap, optionsMap);
            terminateClass.invokeMethod('validateRevisedContract', inputMap1, outMap, optionsMap);
            contract1.Status = 'Approved';
            update contract1;
            contract1.Status = 'Sent for Signing';
            update contract1;
            contract1.Status = 'Signed';
            update contract1;
            terminateClass.invokeMethod('validateRevisedContract', inputMap, outMap, optionsMap);
            terminateClass.invokeMethod('validateRevisedContract', inputMap1, outMap, optionsMap);
            contract1.Status = 'Active';
            update contract1;
            terminateClass.invokeMethod('validateRevisedContract', inputMap1, outMap, optionsMap);
            contract1.Status = 'Cancelled';
            contract1.TeliaSE_Reason_for_Cancellation__c = 'cancelled';
            update contract1;
            terminateClass.invokeMethod('validateRevisedContract', inputMap1, outMap, optionsMap);
            test.stopTest();            
        }
    }
}