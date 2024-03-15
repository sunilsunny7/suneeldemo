@isTest
public class MC_UpdateMobileClusterCodeTest {
    
    //function test: testOffer
    @isTest
    public static void FunctionEval8(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            Map<String,Object> inputs=new Map<String,Object>();
            Map<String,Object> output=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            
            
            vlocity_cmt__ObjectClass__c newObj=new vlocity_cmt__ObjectClass__c();
            newObj.Name = 'Mobile Offer Specification';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            List<Product2> prodList = new List<product2>();
            
           
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Kluster BAS';
            prod1.productCode = 'MOB_MULTI_BAS_V3';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prod1.TeliaSE_OfferTemplateFlag__c=true;
            
            //prod1.MC_Product_Name_Eng__c='Telia Bredband Pro';
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'Kluster Large';
            prod2.productCode = 'MOB_MULTI_LARGE_V3';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.Name = 'Kluster Medium';
            prod3.productCode = 'MOB_MULTI_MEDIUM_V3';
            prod3.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.Name = 'Kluster XLARGE';
            prod4.productCode = 'MOB_MULTI_XLARGE_V3';
            prod4.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod4);
            
            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.Name = 'Kluster PLUS';
            prod5.productCode = 'MOB_MULTI_PLUS_V3';
            prod5.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod5);
            
            Product2 prod6 = Test_DataFactory.createProducts(1)[0];
            prod6.Name = 'Kluster SMALL';
            prod6.productCode = 'MOB_MULTI_SMLL_V3';
            prod6.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod6);
            
            
            insert prodList;
            
            pricebookId = stdPriceBookRecId ;
            List<PricebookEntry> pbelist = new List<PricebookEntry>();
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod1.id;            
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            pbeList.add(objpricebookentry);
            
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod2.id;
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            pbeList.add(objpricebookentry1);
            
            PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prod3.id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            pbeList.add(objpricebookentry2);
          
            insert pbeList;
            
            //Creating account
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced RA';
            acc.Org_Nr__c  = '5564110665';
            acc.Name = 'R21.4_Test_CO_Acc_Grouping';
            insert acc;
            
            //Creating opportunity below
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            //Creating contract below
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            insert contract;
            contract.Status='Active';
            update contract;
            
            list<recordtype> offerQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Offer' AND SobjectType = 'Quote' limit 1];
            list<recordtype> faQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Contract' AND SobjectType = 'Quote' limit 1];
            
            //Create FA quote
            Quote faQuote = new Quote();
            faQuote.Name='Test Quote';
            faQuote.status = 'Draft';
            faQuote.TeliaSE_Type__c='Renegotiation';
            faQuote.opportunityId = opp.id;
            faQuote.Pricebook2ID = stdPriceBookRecId;
            faQuote.TeliaSE_Approval_Flag__c = true; 
            faQuote.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            faQuote.TeliaSE_MC_Sales_Flow_Identifier__c = 'Omforhandling';
            insert faQuote;
            contract.vlocity_cmt__QuoteId__c = faQuote.id;
            update contract;
            
            //Create Offer Quote
            Quote offerQuote = new Quote();
            offerQuote.Name='Test Quote';
            offerQuote.status = 'Draft';
            offerQuote.opportunityId = opp.id;
            offerQuote.Pricebook2ID = stdPriceBookRecId;
            offerQuote.TeliaSE_Approval_Flag__c = false; 
            
            offerQuote.vlocity_cmt__ParentQuoteId__c  = faQuote.id;
            offerQuote.RecordTypeId = id.valueof((string)offerQuoteRecId[0].get('id'));
            insert offerQuote;         
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.quoteid=faQuote.id;           
            oli2.PricebookEntryId = objpricebookentry1.Id;           
            oli2.vlocity_cmt__Product2Id__c = prod1.Id;
            oli2.Product2Id = prod2.id;            
            oli2.vlocity_cmt__ParentItemId__c='';           
            oli2.TeliaSE_MC_Binding_Time__c ='';
            oli2.TeliaSE_ParentClusterCode__c ='';
            oli2.vlocity_cmt__AttributeSelectedValues__c='';
            oli2.UnitPrice = 0;
            oli2.Quantity = 1;
            oli2.Product2Id=prod2.Id;
            insert oli2;
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.quoteid=offerQuote.id;           
            oli3.PricebookEntryId = objpricebookentry2.Id;           
            oli3.vlocity_cmt__Product2Id__c = prod3.Id;
            oli3.Product2Id = prod3.id;            
            //oli2.vlocity_cmt__ParentItemId__c='';           
            oli3.TeliaSE_MC_Binding_Time__c ='24';
            oli3.UnitPrice = 23.4;
            oli3.TeliaSE_ParentClusterCode__c ='';
            oli3.vlocity_cmt__AttributeSelectedValues__c='';
            oli3.Quantity = 1;
            oli3.Product2Id=prod3.Id;
            insert oli3;
            
			QuoteLineItem oli4 = new QuoteLineItem();
            oli4.quoteid=offerQuote.id;           
            oli4.PricebookEntryId = objpricebookentry2.Id;           
            oli4.vlocity_cmt__Product2Id__c = prod4.Id;
            oli4.Product2Id = prod4.id;            
            //oli2.vlocity_cmt__ParentItemId__c='';           
            oli4.TeliaSE_MC_Binding_Time__c ='24';
            oli4.UnitPrice = 23.4;
            oli4.TeliaSE_ParentClusterCode__c ='';
            oli4.vlocity_cmt__AttributeSelectedValues__c='';
            oli4.Quantity = 1;
            oli4.Product2Id=prod4.Id;
            insert oli4;
            
            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.quoteid=offerQuote.id;           
            oli5.PricebookEntryId = objpricebookentry2.Id;           
            oli5.vlocity_cmt__Product2Id__c = prod5.Id;
            oli5.Product2Id = prod5.id;            
            //oli2.vlocity_cmt__ParentItemId__c='';           
            oli5.TeliaSE_MC_Binding_Time__c ='24';
            oli5.UnitPrice = 23.4;
            oli5.TeliaSE_ParentClusterCode__c ='';
            oli5.vlocity_cmt__AttributeSelectedValues__c='';
            oli5.Quantity = 1;
            oli5.Product2Id=prod5.Id;
            insert oli5;
            
            QuoteLineItem oli6 = new QuoteLineItem();
            oli6.quoteid=offerQuote.id;           
            oli6.PricebookEntryId = objpricebookentry2.Id;           
            oli6.vlocity_cmt__Product2Id__c = prod6.Id;
            oli6.Product2Id = prod6.id;            
            //oli2.vlocity_cmt__ParentItemId__c='';           
            oli6.TeliaSE_MC_Binding_Time__c ='24';
            oli6.UnitPrice = 23.4;
            oli6.TeliaSE_ParentClusterCode__c ='';
            oli6.vlocity_cmt__AttributeSelectedValues__c='';
            oli6.Quantity = 1;
            oli6.Product2Id=prod6.Id;
            insert oli6;
            
            Test.startTest();
            MC_UpdateMobileClusterCode jobInst = new MC_UpdateMobileClusterCode();
            Id batchId= Database.executeBatch(jobInst,6);
            //System.abortJob(batchId);
            Test.stopTest();
            
        }
        
    }
    
}