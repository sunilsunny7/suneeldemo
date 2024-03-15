@isTest
public with sharing class Test_MC_Migrate_CO_BindingPeriod_Batch 
{

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
            newObj.Name = 'Connected Office Offer Spec';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            vlocity_cmt__ObjectClass__c newObj1=new vlocity_cmt__ObjectClass__c();
            newObj1.Name = 'Broadband Datanet Offering Spec';
            newObj1.vlocity_cmt__IsActive__c = true;
            newObj1.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj1;
           
                        
            List<Product2> prodList = new List<product2>();
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.name = 'Access Multi 10 Mbit/s';
            prod.productCode = 'CO-DATANET-ACCESS-MULTI-10MB';
            prod.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod.TeliaSE_OfferTemplateFlag__c=true;
            prod.TeliaSE_TemplateCategory__c='CO_alone';
            prod.MC_Product_Name_Eng__c='Access Multi 10 Mbit/s';
            prodList.add(prod); 
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Access Multi 100 Mbit/s';
            prod1.productCode = 'CO-DATANET-ACCESS-MULTI-100MB';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod1.TeliaSE_OfferTemplateFlag__c=true;
            prod1.TeliaSE_TemplateCategory__c='CO_secondary';
            prod1.MC_Product_Name_Eng__c='Telia Bredband Pro';
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'Tillval Backup';
            prod2.productCode = 'CO-DATANET-TILLVAL-BACKUP';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.Name = 'Access Basic Wireless 4G Backup';
            prod3.productCode = 'CO-DATANET-ACCESS-BASIC-4G';
            prod3.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.Name = 'Access Basic Wireless 4G Backup Combo CPE';
            prod4.productCode = 'CO-DATANET-ACCESS-BASIC-4G-COMBO';
            prod4.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod4);
            
            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.Name = 'HERA XYZ';
            prod5.productCode = 'CO-HERA-ALL';
            prod5.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod5);
            
            
             Product2 prod7 = Test_DataFactory.createProducts(1)[0];
            prod7.Name = 'Telia Datanet';
            prod7.productCode = 'CO-DATANET';
            prod7.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod7);

            /*
Product2 prod6 = Test_DataFactory.createProducts(1)[0];
prod6.name = 'Bredband Pro 100 Mbit/s';
prod6.productCode = 'CO-BBPRO-100MB';
prodList.add(prod6);

*/
            insert prodList;
            
            pricebookId = stdPriceBookRecId ;
            List<PricebookEntry> pbelist = new List<PricebookEntry>();
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;            
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            pbeList.add(objpricebookentry);
            
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod1.id;
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            pbeList.add(objpricebookentry1);
            
            PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prod2.id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            pbeList.add(objpricebookentry2);
            
            PricebookEntry objpricebookentry3 =new PricebookEntry();
            objpricebookentry3.Product2ID = prod3.id;
            objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry3.UnitPrice=23.50;
            objpricebookentry3.UseStandardPrice=false;
            objpricebookentry3.isActive=true;//Add this line
            pbeList.add(objpricebookentry3); 
            
            PricebookEntry objpricebookentry4 =new PricebookEntry();
            objpricebookentry4.Product2ID = prod4.id;
            objpricebookentry4.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry4.UnitPrice=23.50;
            objpricebookentry4.UseStandardPrice=false;
            objpricebookentry4.isActive=true;//Add this line
            pbeList.add(objpricebookentry4);
            
            PricebookEntry objpricebookentry5 =new PricebookEntry();
            objpricebookentry5.Product2ID = prod5.id;
            objpricebookentry5.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry5.UnitPrice=23.50;
            objpricebookentry5.UseStandardPrice=false;
            objpricebookentry5.isActive=true;//Add this line
            pbeList.add(objpricebookentry5);
            PricebookEntry objpricebookentry6 =new PricebookEntry();
            objpricebookentry6.Product2ID = prod7.id;
            objpricebookentry6.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry6.UnitPrice=0.0;
            objpricebookentry6.UseStandardPrice=false;
            objpricebookentry6.isActive=true;//Add this line
            pbeList.add(objpricebookentry6);
            /*
PricebookEntry objpricebookentry6 =new PricebookEntry();
objpricebookentry6.Product2ID = prod6.id;
objpricebookentry6.Pricebook2ID = stdPriceBookRecId;
objpricebookentry6.UnitPrice=23.50;
objpricebookentry6.UseStandardPrice=false;
objpricebookentry6.isActive=true;//Add this line
pbeList.add(objpricebookentry6); 
*/
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
            faQuote.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
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
            oli2.PricebookEntryId = objpricebookentry6.Id;           
            oli2.vlocity_cmt__Product2Id__c = prod7.Id;
            oli2.Product2Id = prod7.id;            
            oli2.vlocity_cmt__ParentItemId__c='';           
            oli2.TeliaSE_MC_Binding_Time__c ='';
            oli2.UnitPrice = 0;
            oli2.Quantity = 1;
            oli2.Product2Id=prod7.Id;
            insert oli2;
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.quoteid=offerQuote.id;           
            oli3.PricebookEntryId = objpricebookentry3.Id;           
            oli3.vlocity_cmt__Product2Id__c = prod3.Id;
            oli3.Product2Id = prod3.id;            
            //oli2.vlocity_cmt__ParentItemId__c='';           
            oli3.TeliaSE_MC_Binding_Time__c ='24';
            oli3.UnitPrice = 23.4;
            oli3.Quantity = 1;
            oli3.Product2Id=prod3.Id;
            insert oli3;
            
            
           
            MC_Migrate_CO_BindingPeriod_Batch jobInst = new MC_Migrate_CO_BindingPeriod_Batch();
       Database.executeBatch(jobInst,1);
            
        }
        
    }
    
}