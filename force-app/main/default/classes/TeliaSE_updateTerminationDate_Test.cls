@isTest
public with sharing class TeliaSE_updateTerminationDate_Test {
    @testSetup static void setup(){
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
        prod.name='Test';
        insert prod;
            
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        insert prod1;
        pricebookId = stdPriceBookRecId ;
       
             
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
            contract.RecordTypeId = rt1.Id;
            insert contract;
            contract.Status = 'Active';
            update contract;
            
            vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
            cli.name='Office';
            cli.vlocity_cmt__product2id__c=prod.id;
            cli.vlocity_cmt__ContractId__c=contract.id;
            cli.TeliaSE_Root_Product__c=prod.id;
            cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
            
            insert cli;
            }
    }
    
    testMethod public static void test()
    {
         Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> quoteMap=new Map<String,Object>();
        
        Map<String,Object> terminateMap=new Map<String,Object>();
       
        Product2 prod=[select id from Product2 where name='Test'];
        Contract con=[select id from Contract limit 1];
        List<Map<String,String>> lines=new List<Map<String,String>>();
        Map<String,String> line=new Map<String,String>();
        line.put('RootProduct', prod.id);
        line.put('CLIEndDate','2019-05-15T18:30:00.000Z');
        
        lines.add(line);
        
        quoteMap.put('Item',lines);
        quoteMap.put('Id',con.id);
        inputMap.put('Contract',quoteMap);
        terminateMap.put('TerminateReason','Blah');
        inputMap.put('TerminationDetails',terminateMap);
        TeliaSE_updateTerminationDate obj=new TeliaSE_updateTerminationDate();
        Test.startTest();
            obj.invokeMethod('updateTerminationDt',inputMap,outMap,options);
        Test.stopTest();
        
        inputMap.put('TerminationDetails',null);
        obj.invokeMethod('updateTerminationDt',inputMap,outMap,options);
        obj.invokeMethod('updateTermination',inputMap,outMap,options);
        
        
        

    }
}