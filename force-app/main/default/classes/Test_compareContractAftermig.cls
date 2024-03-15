@isTest
public class Test_compareContractAftermig {
    testMethod public static void subscriptionMethodMadam(){
        User salesManager;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
                
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Offer Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        vlocity_cmt__ObjectClass__c objClass1 = new vlocity_cmt__ObjectClass__c();
        objClass1.Name = 'Touch Offer Specification';    
        objClass1.vlocity_cmt__IsActive__c = True;
        objClass1.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass1;
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod.TeliaSE_Subscription_Type__c = '99';
        insert prod;
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass1.Id;
        prod1.TeliaSE_Subscription_Type__c = '98';
        insert prod1;
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass1.Id;
        prod2.TeliaSE_Subscription_Type__c = '97';
        insert prod2;
        Product2 prod3 = Test_DataFactory.createProducts(1)[0];
        prod3.vlocity_cmt__ObjectTypeId__c = objClass1.Id;
        prod3.TeliaSE_Subscription_Type__c = '96';
        insert prod3;
        Product2 prod4 = Test_DataFactory.createProducts(1)[0];
        prod4.vlocity_cmt__ObjectTypeId__c = objClass1.Id;
        prod4.TeliaSE_Subscription_Type__c = '95';
        insert prod4;

        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Kvalificera';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            insert opp;            
                        
            Account acc = Test_DataFactory.createOneAccount();
            insert acc; 
            
            MC_CommercialNegotiation__c minCommit = new MC_CommercialNegotiation__c();
            minCommit.Approved_By__c = 'SalesManager';
            minCommit.Default_Value__c = '75';
            minCommit.Name = 'MinimumCommitment';
            minCommit.Approval_Required__c = false;
            insert minCommit;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod1.id;
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            insert objpricebookentry1;
// 1 scenario            //Contract Quote

            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
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
            oli1.vlocity_cmt__RecurringCharge__c = 214.00;
            oli1.vlocity_cmt__RecurringTotal__c = 214.00;
            oli1.vlocity_cmt__OneTimeCharge__c = 0;
            oli1.vlocity_cmt__OneTimeTotal__c = 0;
            oli1.TeliaSE_MC_Customer_Requested_Price__c = 213.00;
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 8;
            //oli1.TeliaSE_Base_Quantity__c = 100;
            oli1.TeliaSE_CommitmentPeriod__c = '12 months';
            oli1.TeliaSE_Minimum_Value_Commit__c = '50';
            oli1.TeliaSE_SubsidisedVoice__c = 'Yes';
            insert oli1;
            
            QuoteLineItem oli11 = new QuoteLineItem();
            oli11.QuoteId = qut.Id;
            oli11.Product2Id = prod.Id;
            oli11.PricebookEntryId = objpricebookentry.Id;
            oli11.UnitPrice = 0;
            oli11.Quantity = 1;
            oli11.vlocity_cmt__RecurringCharge__c = 214.00;
            oli11.vlocity_cmt__RecurringTotal__c = 214.00;
            oli11.vlocity_cmt__OneTimeCharge__c = 0;
            oli11.vlocity_cmt__OneTimeTotal__c = 0;
            oli11.TeliaSE_MC_Customer_Requested_Price__c = 213.00;
            oli11.TeliaSE_MC_Customer_Requested_Percentage__c = 8;
            //oli11.TeliaSE_Base_Quantity__c = 100;
            oli11.TeliaSE_CommitmentPeriod__c = '12 months';
            oli11.TeliaSE_Minimum_Value_Commit__c = '50';
            oli11.TeliaSE_SubsidisedVoice__c = 'Yes';
            insert oli11;
            
            QuoteLineItem oli12 = new QuoteLineItem();
            oli12.QuoteId = qut.Id;
            oli12.Product2Id = prod.Id;
            oli12.PricebookEntryId = objpricebookentry.Id;
            oli12.UnitPrice = 0;
            oli12.Quantity = 1;
            oli12.vlocity_cmt__RecurringCharge__c = 214.00;
            oli12.vlocity_cmt__RecurringTotal__c = 214.00;
            oli12.vlocity_cmt__OneTimeCharge__c = 0;
            oli12.vlocity_cmt__OneTimeTotal__c = 0;
            oli12.TeliaSE_MC_Customer_Requested_Price__c = 213.00;
            //oli12.TeliaSE_Base_Quantity__c = 100;
            oli12.TeliaSE_CommitmentPeriod__c = '12 months';
            oli12.TeliaSE_Minimum_Value_Commit__c = '50';
            oli12.TeliaSE_SubsidisedVoice__c = 'Yes';
            insert oli12;

            Id RecordTypeIdContract = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();

            Contract contract = new Contract();
            contract.AccountId = acc.Id;
            contract.Agreement_Nr__c = '123456';
            contract.vlocity_cmt__QuoteId__c = qut.Id;
            contract.Status = 'Draft';
            contract.RecordTypeId = RecordTypeIdContract;
            insert contract;
            
            vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
            cli1.vlocity_cmt__ContractId__c = contract.Id;
            cli1.TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification';
            cli1.vlocity_cmt__Product2Id__c = prod.Id;
            cli1.vlocity_cmt__RecurringCharge__c = 218.00;
            cli1.vlocity_cmt__RecurringTotal__c = 218.00;
            cli1.vlocity_cmt__OneTimeCharge__c = 20;
            cli1.vlocity_cmt__OneTimeTotal__c = 20;
            cli1.TeliaSE_MC_Customer_Requested_Price__c = 216.00;
            cli1.TeliaSE_Minimum_Value_Commit__c = '75';
            cli1.TeliaSE_CommitmentPeriod__c = '24 months';
           //cli1.TeliaSE_Base_Quantity__c = 400;
            cli1.TeliaSE_SubsidisedVoice__c = 'No';
            cli1.TeliaSE_QuoteItemId__c = oli1.id;
            cli1.TeliaSE_MasterQuote__c = false;
            cli1.TeliaSE_ParentItemId__c = '';
            insert cli1;
            
            vlocity_cmt__ContractLineItem__c cli11 = new vlocity_cmt__ContractLineItem__c();
            cli11.vlocity_cmt__ContractId__c = contract.Id;
            cli11.TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification';
            cli11.vlocity_cmt__Product2Id__c = prod.Id;
            cli11.vlocity_cmt__RecurringCharge__c = 215.00;
            cli11.vlocity_cmt__RecurringTotal__c = 215.00;
            cli11.vlocity_cmt__OneTimeCharge__c = 10;
            cli11.vlocity_cmt__OneTimeTotal__c = 10;
            cli11.TeliaSE_MC_Customer_Requested_Price__c = 214.00;
            cli11.TeliaSE_Minimum_Value_Commit__c = '75';
            cli11.TeliaSE_CommitmentPeriod__c = '24 months';
           // cli11.TeliaSE_Base_Quantity__c = 110;
            cli11.TeliaSE_SubsidisedVoice__c = 'No';
            cli11.TeliaSE_QuoteItemId__c = oli11.id;
            cli11.TeliaSE_ParentItemId__c = oli1.id;
            cli11.TeliaSE_MasterQuote__c = false;
            insert cli11;
            
            
// 2nd scenario
            Quote qut1 = new Quote();
            qut1.Name='Test Quote1';
            qut1.status = 'Draft';  
            qut1.opportunityId = opp.id;
            qut1.Pricebook2ID = stdPriceBookRecId;
            qut1.TeliaSE_Approval_Flag__c = False;        
            insert qut1; 
            
            QuoteLineItem oli21 = new QuoteLineItem();
            oli21.QuoteId = qut1.Id;
            oli21.Product2Id = prod.Id;
            oli21.PricebookEntryId = objpricebookentry.Id;
            oli21.UnitPrice = 0;
            oli21.Quantity = 1;
            oli21.vlocity_cmt__RecurringCharge__c = 214.00;
            oli21.vlocity_cmt__RecurringTotal__c = 214.00;
            oli21.vlocity_cmt__OneTimeCharge__c = 0;
            oli21.vlocity_cmt__OneTimeTotal__c = 0;
            oli21.TeliaSE_MC_Customer_Requested_Price__c = 213.00;
           // oli21.TeliaSE_Base_Quantity__c = 100;
            oli21.TeliaSE_CommitmentPeriod__c = '12 months';
            oli21.TeliaSE_Minimum_Value_Commit__c = '50';
            oli21.TeliaSE_SubsidisedVoice__c = 'Yes';
            insert oli21;
            
            vlocity_cmt__ContractLineItem__c cli12 = new vlocity_cmt__ContractLineItem__c();
            cli12.vlocity_cmt__ContractId__c = contract.Id;
            cli12.TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification';
            cli12.vlocity_cmt__Product2Id__c = prod.Id;
            cli12.vlocity_cmt__RecurringCharge__c = 215.00;
            cli12.vlocity_cmt__RecurringTotal__c = 215.00;
            cli12.vlocity_cmt__OneTimeCharge__c = 10;
            cli12.vlocity_cmt__OneTimeTotal__c = 10;
            cli12.TeliaSE_MC_Customer_Requested_Price__c = 214.00;
            cli12.TeliaSE_Minimum_Value_Commit__c = '75';
            cli12.TeliaSE_CommitmentPeriod__c = '24 months';
           // cli12.TeliaSE_Base_Quantity__c = 110;
            cli12.TeliaSE_SubsidisedVoice__c = 'No';
            cli12.TeliaSE_ParentItemId__c = '';
            cli12.TeliaSE_MasterQuote__c = false;
            insert cli12;
            
            vlocity_cmt__ContractLineItem__c cli13 = new vlocity_cmt__ContractLineItem__c();
            cli13.vlocity_cmt__ContractId__c = contract.Id;
            cli13.TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification';
            cli13.vlocity_cmt__Product2Id__c = prod.Id;
            cli13.vlocity_cmt__RecurringCharge__c = 215.00;
            cli13.vlocity_cmt__RecurringTotal__c = 215.00;
            cli13.vlocity_cmt__OneTimeCharge__c = 10;
            cli13.vlocity_cmt__OneTimeTotal__c = 10;
            cli13.TeliaSE_MC_Customer_Requested_Price__c = 214.00;
            cli13.TeliaSE_Minimum_Value_Commit__c = '75';
            cli13.TeliaSE_CommitmentPeriod__c = '24 months';
           // cli13.TeliaSE_Base_Quantity__c = 110;
            cli13.TeliaSE_SubsidisedVoice__c = 'No';
            cli13.TeliaSE_ParentItemId__c = oli21.id;
            cli13.TeliaSE_MasterQuote__c = false;
            insert cli13;
//3rd scenario
            Quote qut2 = new Quote();
            qut2.Name='Test Quote2';
            qut2.status = 'Draft';  
            qut2.opportunityId = opp.id;
            qut2.Pricebook2ID = stdPriceBookRecId;
            qut2.TeliaSE_Approval_Flag__c = False;        
            insert qut2;
            
            QuoteLineItem oli22 = new QuoteLineItem();
            oli22.QuoteId = qut2.Id;
            oli22.Product2Id = prod.Id;
            oli22.PricebookEntryId = objpricebookentry.Id;
            oli22.UnitPrice = 0;
            oli22.Quantity = 1;
            oli22.vlocity_cmt__RecurringCharge__c = 214.00;
            oli22.vlocity_cmt__RecurringTotal__c = 214.00;
            oli22.vlocity_cmt__OneTimeCharge__c = 0;
            oli22.vlocity_cmt__OneTimeTotal__c = 0;
            oli22.TeliaSE_MC_Customer_Requested_Price__c = 213.00;
            oli22.TeliaSE_MC_Customer_Requested_Percentage__c = 8;
           // oli22.TeliaSE_Base_Quantity__c = 100;
            oli22.TeliaSE_CommitmentPeriod__c = '12 months';
            oli22.TeliaSE_Minimum_Value_Commit__c = '50';
            oli22.TeliaSE_SubsidisedVoice__c = 'Yes';
            insert oli22;
            
            QuoteLineItem oli23 = new QuoteLineItem();
            oli23.QuoteId = qut2.Id;
            oli23.Product2Id = prod.Id;
            oli23.PricebookEntryId = objpricebookentry.Id;
            oli23.UnitPrice = 0;
            oli23.Quantity = 1;
            oli23.vlocity_cmt__RecurringCharge__c = 214.00;
            oli23.vlocity_cmt__RecurringTotal__c = 214.00;
            oli23.vlocity_cmt__OneTimeCharge__c = 0;
            oli23.vlocity_cmt__OneTimeTotal__c = 0;
            oli23.TeliaSE_MC_Customer_Requested_Price__c = 213.00;
            oli23.TeliaSE_MC_Customer_Requested_Percentage__c = 8;
           // oli23.TeliaSE_Base_Quantity__c = 100;
            oli23.TeliaSE_CommitmentPeriod__c = '12 months';
            oli23.TeliaSE_Minimum_Value_Commit__c = '50';
            oli23.TeliaSE_SubsidisedVoice__c = 'Yes';
            insert oli23;
            
            QuoteLineItem oli24 = new QuoteLineItem();
            oli24.QuoteId = qut2.Id;
            oli24.Product2Id = prod.Id;
            oli24.PricebookEntryId = objpricebookentry.Id;
            oli24.UnitPrice = 0;
            oli24.Quantity = 1;
            oli24.vlocity_cmt__RecurringCharge__c = 214.00;
            oli24.vlocity_cmt__RecurringTotal__c = 214.00;
            oli24.vlocity_cmt__OneTimeCharge__c = 0;
            oli24.vlocity_cmt__OneTimeTotal__c = 0;
            oli24.TeliaSE_MC_Customer_Requested_Price__c = 213.00;
           // oli24.TeliaSE_Base_Quantity__c = 100;
            oli24.TeliaSE_CommitmentPeriod__c = '12 months';
            oli24.TeliaSE_Minimum_Value_Commit__c = '50';
            oli24.TeliaSE_SubsidisedVoice__c = 'Yes';
            insert oli24;
            
            Contract contract21 = new Contract();
            contract21.AccountId = acc.Id;
            contract21.Agreement_Nr__c = '123456';
            contract21.vlocity_cmt__QuoteId__c = qut2.Id;
            contract21.Status = 'Draft';
            contract21.RecordTypeId = RecordTypeIdContract;
            insert contract21;
            
            vlocity_cmt__ContractLineItem__c cli21 = new vlocity_cmt__ContractLineItem__c();
            cli21.vlocity_cmt__ContractId__c = contract21.Id;
            cli21.TeliaSE_Product_Object_Type__c = 'tp Offer Specification';
            cli21.vlocity_cmt__Product2Id__c = prod3.Id;
            cli21.vlocity_cmt__RecurringCharge__c = 218.00;
            cli21.vlocity_cmt__RecurringTotal__c = 218.00;
            cli21.vlocity_cmt__OneTimeCharge__c = 20;
            cli21.vlocity_cmt__OneTimeTotal__c = 20;
            cli21.TeliaSE_MC_Customer_Requested_Price__c = 216.00;
            cli21.TeliaSE_Minimum_Value_Commit__c = '75';
            cli21.TeliaSE_CommitmentPeriod__c = '24 months';
          //  cli21.TeliaSE_Base_Quantity__c = 400;
            cli21.TeliaSE_SubsidisedVoice__c = 'No';
            cli21.TeliaSE_QuoteItemId__c = oli22.id;
            cli21.TeliaSE_MasterQuote__c = false;
            cli21.TeliaSE_ParentItemId__c = '';
            insert cli21;
            
            vlocity_cmt__ContractLineItem__c cli112 = new vlocity_cmt__ContractLineItem__c();
            cli112.vlocity_cmt__ContractId__c = contract21.Id;
            cli112.TeliaSE_Product_Object_Type__c = 'Touchpoint Offer Specification';
            cli112.vlocity_cmt__Product2Id__c = prod1.Id;
            cli112.vlocity_cmt__RecurringCharge__c = 215.00;
            cli112.vlocity_cmt__RecurringTotal__c = 215.00;
            cli112.vlocity_cmt__OneTimeCharge__c = 10;
            cli112.vlocity_cmt__OneTimeTotal__c = 10;
            cli112.TeliaSE_MC_Customer_Requested_Price__c = 214.00;
            cli112.TeliaSE_Minimum_Value_Commit__c = '75';
            cli112.TeliaSE_CommitmentPeriod__c = '24 months';
           // cli112.TeliaSE_Base_Quantity__c = 110;
            cli112.TeliaSE_SubsidisedVoice__c = 'No';
            cli112.TeliaSE_QuoteItemId__c = oli24.id;
            cli112.TeliaSE_ParentItemId__c = oli1.id;
            cli112.TeliaSE_MasterQuote__c = false;
            insert cli112;

            
            Contract contract22 = new Contract();
            contract22.Name = 'null_Backup1';
            contract22.AccountId = acc.Id;
            contract22.Agreement_Nr__c = '123456';
            contract22.vlocity_cmt__QuoteId__c = qut2.Id;
            contract22.Status = 'Draft';
            contract22.RecordTypeId = RecordTypeIdContract;
            contract22.vlocity_cmt__ParentContractId__c = contract21.id;
            insert contract22;
            
            vlocity_cmt__ContractLineItem__c cli212 = new vlocity_cmt__ContractLineItem__c();
            cli212.vlocity_cmt__ContractId__c = contract22.Id;
            cli212.TeliaSE_Product_Object_Type__c = 'tp Offer Specification';
            cli212.vlocity_cmt__Product2Id__c = prod1.Id;
            cli212.vlocity_cmt__RecurringCharge__c = 218.00;
            cli212.vlocity_cmt__RecurringTotal__c = 218.00;
            cli212.vlocity_cmt__OneTimeCharge__c = 20;
            cli212.vlocity_cmt__OneTimeTotal__c = 20;
            cli212.TeliaSE_MC_Customer_Requested_Price__c = 216.00;
            cli212.TeliaSE_Minimum_Value_Commit__c = '75';
            cli212.TeliaSE_CommitmentPeriod__c = '24 months';
           // cli212.TeliaSE_Base_Quantity__c = 400;
            cli212.TeliaSE_SubsidisedVoice__c = 'No';
            cli212.TeliaSE_QuoteItemId__c = oli1.id;
            cli212.TeliaSE_MasterQuote__c = false;
            cli212.TeliaSE_ParentItemId__c = '';
            insert cli212;
            
            vlocity_cmt__ContractLineItem__c cli222 = new vlocity_cmt__ContractLineItem__c();
            cli222.vlocity_cmt__ContractId__c = contract22.Id;
            cli222.TeliaSE_Product_Object_Type__c = 'Touch Offer Specification';
            cli222.vlocity_cmt__Product2Id__c = prod4.Id;
            cli222.vlocity_cmt__RecurringCharge__c = 215.00;
            cli222.vlocity_cmt__RecurringTotal__c = 215.00;
            cli222.vlocity_cmt__OneTimeCharge__c = 10;
            cli222.vlocity_cmt__OneTimeTotal__c = 10;
            cli222.TeliaSE_MC_Customer_Requested_Price__c = 214.00;
            cli222.TeliaSE_Minimum_Value_Commit__c = '75';
            cli222.TeliaSE_CommitmentPeriod__c = '24 months';
          //  cli222.TeliaSE_Base_Quantity__c = 110;
            cli222.TeliaSE_SubsidisedVoice__c = 'No';
            cli222.TeliaSE_QuoteItemId__c = oli11.id;
            cli222.TeliaSE_ParentItemId__c = oli1.id;
            cli222.TeliaSE_MasterQuote__c = false;
            insert cli222;

            
            Quote qut3 = new Quote();
            qut3.Name='Test Quote3';
            qut3.status = 'Draft';  
            qut3.opportunityId = opp.id;
            qut3.Pricebook2ID = stdPriceBookRecId;
            qut3.TeliaSE_Approval_Flag__c = False;        
            insert qut3;
            
            Contract contract31 = new Contract();
            contract31.AccountId = acc.Id;
            contract31.Agreement_Nr__c = '123456';
            contract31.vlocity_cmt__QuoteId__c = qut3.Id;
            contract31.Status = 'Draft';
            contract31.RecordTypeId = RecordTypeIdContract;
            insert contract31;
            
            vlocity_cmt__ContractLineItem__c cli31 = new vlocity_cmt__ContractLineItem__c();
            cli31.vlocity_cmt__ContractId__c = contract31.Id;
            cli31.TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification';
            cli31.vlocity_cmt__Product2Id__c = prod.Id;
            cli31.vlocity_cmt__RecurringCharge__c = 215.00;
            cli31.vlocity_cmt__RecurringTotal__c = 215.00;
            cli31.vlocity_cmt__OneTimeCharge__c = 10;
            cli31.vlocity_cmt__OneTimeTotal__c = 10;
            cli31.TeliaSE_MC_Customer_Requested_Price__c = 214.00;
            cli31.TeliaSE_Minimum_Value_Commit__c = '75';
            cli31.TeliaSE_CommitmentPeriod__c = '24 months';
           // cli31.TeliaSE_Base_Quantity__c = 110;
            cli31.TeliaSE_SubsidisedVoice__c = 'No';
            cli31.TeliaSE_QuoteItemId__c = oli21.id;
            cli31.TeliaSE_ParentItemId__c = oli11.id;
            cli31.TeliaSE_MasterQuote__c = false;
            insert cli31;

            Contract contract32 = new Contract();
            contract32.AccountId = acc.Id;
            contract32.Agreement_Nr__c = '123456';
            contract32.vlocity_cmt__QuoteId__c = qut3.Id;
            contract32.Status = 'Draft';
            contract32.RecordTypeId = RecordTypeIdContract;
            insert contract32;
            
            vlocity_cmt__ContractLineItem__c cli32 = new vlocity_cmt__ContractLineItem__c();
            cli32.vlocity_cmt__ContractId__c = contract32.Id;
            cli32.TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification';
            cli32.vlocity_cmt__Product2Id__c = prod.Id;
            cli32.vlocity_cmt__RecurringCharge__c = 215.00;
            cli32.vlocity_cmt__RecurringTotal__c = 215.00;
            cli32.vlocity_cmt__OneTimeCharge__c = 10;
            cli32.vlocity_cmt__OneTimeTotal__c = 10;
            cli32.TeliaSE_MC_Customer_Requested_Price__c = 214.00;
            cli32.TeliaSE_Minimum_Value_Commit__c = '75';
            cli32.TeliaSE_CommitmentPeriod__c = '24 months';
          //  cli32.TeliaSE_Base_Quantity__c = 110;
            cli32.TeliaSE_SubsidisedVoice__c = 'No';
            cli32.TeliaSE_QuoteItemId__c = oli21.id;
            cli32.TeliaSE_ParentItemId__c = oli11.id;
            cli32.TeliaSE_MasterQuote__c = false;
            insert cli32;

            List<Quote> quote = new List<Quote>();
            quote = [Select id from Quote];
            set<String> quoteid = new set<String>();
            List<String> quoteList = new List<String>();
            for(Quote q:quote){
                quoteid.add(q.Id);
                quoteList.add(q.Id);
            }
            compareContractAftermig.compareQuotetoContract(quoteid);
            compareContractAftermig.compare(quoteList);
        }
    }
}