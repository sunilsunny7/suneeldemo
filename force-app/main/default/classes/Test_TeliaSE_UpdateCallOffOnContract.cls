@isTest
public class Test_TeliaSE_UpdateCallOffOnContract {
    testMethod public static void buttonMethods(){
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();              
                
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            Account acc = Test_DataFactory.createOneAccount();
            insert acc; 
            
            vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
            objClass.Name = 'Touch Point Offer Spec';    
            objClass.vlocity_cmt__IsActive__c = True;                
            objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass;
                
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            prod.TeliaSE_Subscription_Type__c = '99';
            prod.TeliaSE_Product_Service_Code__c = 'abcd';
            insert prod;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Kvalificera';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            SObject sObj = [SELECT Id, SobjectType,IsActive,  DeveloperName FROM RecordType where SobjectType = 'Quote' and DeveloperName = 'Offer'];
            System.debug('sobj'+sObj);
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.RecordTypeId = sObj.Id;
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Product2Id = prod.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.UnitPrice = 0;
            oli1.Quantity = 1;
            insert oli1;   
            
            Contract contract = new Contract();
            contract.AccountId = acc.Id;
            contract.Agreement_Nr__c = '123456';
            contract.TeliaSE_is_combi__c = true;
            contract.vlocity_cmt__OpportunityId__c = opp.Id;
            insert contract;
            
            Contract contract1 = new Contract();
            contract1.AccountId = acc.Id;
            contract1.Agreement_Nr__c = '123456';
            contract1.TeliaSE_is_combi__c = true;
            insert contract1;
            
            vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
            cli.vlocity_cmt__ContractId__c = contract.Id;
            cli.TeliaSE_Product_Object_Type__c = 'Touch Point Offer Spec';
            cli.vlocity_cmt__Product2Id__c = prod.Id;
            cli.TeliaSE_MC_Customer_Requested_Price__c = 213.00;
            insert cli;
            
            Map<String,Object> inputMap = new  Map<String,Object>();
            inputMap.put('ContextId',contract.Id);
            Map<String,Object> inputMap1 = new  Map<String,Object>();
            inputMap1.put('ContextId',contract1.Id);
            Map<String,Object> outMap = new  Map<String,Object>();
            Map<String,Object> options = new  Map<String,Object>(); 
            
            TeliaSE_UpdateCallOffOnContract obj = new TeliaSE_UpdateCallOffOnContract();
            obj.invokeMethod('updateCallOffDetails',inputMap,outMap,options);
            obj.invokeMethod('updateCallOffDetails',inputMap1,outMap,options);
            obj.invokeMethod('',inputMap,outMap,options);
        }
    }    
}