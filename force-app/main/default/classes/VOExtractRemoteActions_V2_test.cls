@isTest
public class VOExtractRemoteActions_V2_test {
    testMethod public static void subscriptionMethodMadam(){
        
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
                
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.TeliaSE_Subscription_Type__c = '99';
        insert prod;
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.TeliaSE_Subscription_Type__c = '98';
        insert prod1;
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod2.TeliaSE_Subscription_Type__c = '97';
        insert prod2;
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod3.TeliaSE_Subscription_Type__c = '96';
        insert prod3;
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod4.TeliaSE_Subscription_Type__c = '95';
        insert prod4;
        
        System.runAs(salesManager){
            
            
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
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            qut.TeliaSE_MC_Sales_Flow_Identifier__c = 'Omforhandling';
            insert qut;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut.Id;
            oli1.Product2Id = prod.Id;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.UnitPrice = 0;
            oli1.Quantity = 1;
            oli1.MC_RootPriceFlag__c = true;
            oli1.vlocity_cmt__ParentItemId__c = null;
            insert oli1;          
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.QuoteId = qut.Id;
            oli2.Product2Id = prod2.Id;
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.UnitPrice = 0;
            oli2.Quantity = 1;
            oli2.MC_RootPriceFlag__c = false;
            oli2.vlocity_cmt__ParentItemId__c = null;
            insert oli2;
            
            QuoteLineItem oli12 = new QuoteLineItem();
            oli12.QuoteId = qut.Id;
            oli12.Product2Id = prod1.Id;
            oli12.PricebookEntryId = objpricebookentry.Id;
            oli12.vlocity_cmt__ParentItemId__c = oli1.Id;
            oli12.vlocity_cmt__RootItemId__c = oli1.Id;
            oli12.UnitPrice = 245;
            oli12.Quantity = 1;
            oli12.vlocity_cmt__JSONAttribute__c = '{"someaction"}';
            insert oli12;
            
            Map<String, Object> input = new Map<String,Object>();
            Map<String, Object> output = new Map<String,Object>();
            Map<String, Object> options = new Map<String,Object>();
            
            input.put('cartId',qut.Id);
            VOExtractRemoteActions_V2 v2 = new VOExtractRemoteActions_V2();
            v2.invokeMethod('getAllBundles',input,output,options);
        }
    }
}