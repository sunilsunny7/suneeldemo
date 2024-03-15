/**
* @Author:      Ananya Patra
* @Company:     Capgemini
* @Date:        13 October 2020
* @Description: Test Class for ComparePricesQuote_Contract
*/

@isTest
public class Test_ComparePricesQuote_Contract {

    @testSetup
    private static void testdatasetup(){
        User salesManager;         
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
        	salesManager = Test_DataFactory.createAdminUser();
        	salesManager.Bypass_VR__c = true;
            salesManager.IsActive = true;
        	insert salesManager;
        }        
        
        System.runAs(salesManager)
        {
        
            Account acc = new Account();
                acc.Name = 'testAccount1';
                acc.Org_Nr__c = '5564867793';
                insert acc;
            
            Opportunity opp = new Opportunity();
                opp.Name='opp1';
                opp.AccountId=acc.Id;
                opp.CloseDate = System.today();
                opp.StageName='Needs Analysis';
                opp.Pricebook2Id=Test.getStandardPricebookId();
                insert opp;
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
               insert prod;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
             objpricebookentry.Product2ID = prod.id;
             objpricebookentry.Pricebook2ID = Test.getStandardPricebookId();
             objpricebookentry.UnitPrice=23.50;
             objpricebookentry.UseStandardPrice=false;
             objpricebookentry.isActive=true;//Add this line
             insert objpricebookentry;
                
            
            
             Quote qut1 = new Quote();
                qut1.Name='Test Quote';
                //qut1.vlocity_cmt__FrameContractId__c=conObj.id;
                qut1.status = 'Draft';
                qut1.opportunityId = opp.id;
                qut1.TeliaSE_Approval_Flag__c = False; 
                qut1.TeliaSE_Type__c='Renegotiation';
                insert qut1;
                
           
           QuoteLineItem oli1 = new QuoteLineItem();
            oli1.QuoteId = qut1.id;
            oli1.UnitPrice = 200;
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.Quantity = 4;
            oli1.Product2Id = prod.id;        
            insert oli1;
            
        
        
        Contract conObj = new Contract();
                conObj.vlocity_cmt__QuoteId__c=qut1.id;
                conObj.TeliaSE_Type__c = 'Renegotiation';
                conObj.StartDate = system.today();
                conObj.status = 'Draft';
                conObj.accountId = acc.Id;
                conObj.TeliaSE_Case_Id__c = '12345';
                insert conObj;
            
            List<vlocity_cmt__ContractLineItem__c> contractLI = new List<vlocity_cmt__ContractLineItem__c>{};
                vlocity_cmt__ContractLineItem__c conLI = new vlocity_cmt__ContractLineItem__c(Name ='Test', TeliaSE_End_Date__c = system.today().addDays(2), vlocity_cmt__Product2Id__c=prod.id,
                                                                                              vlocity_cmt__ContractId__c = conObj.Id, TeliaSE_CommitmentPeriod__c ='123213',
                                                                                             TeliaSE_SubsidisedVoice__c = 'NA');
            contractLI.add(conLI);
            insert contractLI;
        }
    }
    
    @isTest
    private static void testMethod1(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when InvoiceFee does not match
    @isTest
    private static void testMethod2(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Nej", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when OneTimeCharge does not match
    @isTest
    private static void testMethod3(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 490, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
            
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }

    //when RecurringCharge does not match
    @isTest
    private static void testMethod4(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 10, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
            
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when QuarantineTime does not match
    @isTest
    private static void testMethod5(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "QuarantineTime":75, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "QuarantineTime":90, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
            
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    //when RequestedPrice does not match
    @isTest
    private static void testMethod6(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "RequestedPrice": 50, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "QuarantineTime":95, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "RequestedPrice": 55, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "QuarantineTime":90 }, "IsQuoteLocked": false }';
            
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when RequestedPercentage does not match
    @isTest
    private static void testMethod7(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "RequestedPercentage": 10, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "QuarantineTime":95, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "RequestedPercentage": 15, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "QuarantineTime":90 }, "IsQuoteLocked": false }';
            
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when MinValueCommit does not match
    @isTest
    private static void testMethod8(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "MinValueCommit": 1, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "MinValueCommit": 2, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when Campaign does not match
    @isTest
    private static void testMethod9(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "Campaign": "1 fri månad", "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Campaign": "3 fria månader", "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when contractList.size() !> 0 and Quote status <> 'Approved'
    @isTest
    private static void testMethod10(){
                
        Quote qut= [SELECT id FROM Quote];
        Contract cut= [SELECT id, status FROM Contract];
        cut.status = 'Cancelled';
        update cut; 
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when contractList.size() !> 0 and Quote status == 'Approved' and approvalCount <> 0
    @isTest
    private static void testMethod11(){
                
        Quote qut= [SELECT id, status FROM Quote];
        qut.status = 'Approved';
        update qut;
        Contract cut= [SELECT id, status FROM Contract];
        cut.status = 'Cancelled';
        update cut; 
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 2, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when contractList.size() !> 0 and Quote status == 'Approved' and approvalCount == 0
    @isTest
    private static void testMethod12(){
                
        Quote qut= [SELECT id, status FROM Quote];
        qut.status = 'Approved';
        update qut;
        Contract cut= [SELECT id, status FROM Contract];
        cut.status = 'Cancelled';
        update cut; 
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when quoteId is not passed
    @isTest
    private static void testMethod13(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        //inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        //System.assertEquals(true, var);
    }
    
    @isTest
    private static void testMethodLockQuote(){
        
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('getQuoteLocked',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    @isTest
    private static void testMethod21(){
                
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('comparePrices',inputMap,outMap, options);
        System.assertEquals(false, var);
    }
    
    //This method is not present in the class to cover line 33 of apex class
      @isTest
    private static void testMethod22(){        
        Quote qut= [SELECT id FROM Quote];
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('quoteId',qut.id);
       
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('updatePrices',inputMap,outMap, options);
        System.assertEquals(false, var);
    }
    
    
     @isTest
    private static void testMethodDeleteCase(){
                
        Quote qut= [SELECT id, status FROM Quote];
        qut.status = 'Approved';
        update qut;
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        //ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 0, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('UpdateContractStatusAndDeleteCase',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
    
    //when contractList.size() !> 0 and Quote status == 'Approved' and approvalCount <> 0
    @isTest
    private static void testMethod41(){
                
        Quote qut= [SELECT id, status FROM Quote];
        qut.status = 'Approved';
        update qut; 
        Map<String,Object> inputMap= new Map<String,Object>();
        Map<String,Object> outMap= new Map<String,Object>();
        Map<String,Object> options= new Map<String,Object>();
        inputMap.put('ContextId',qut.id);
        ComparePricesQuote_Contract.jsonString = '{ "CLI": [{ "Product": { "OneTimeCharge": 500, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }, "ContractId": "8004E000002EPIfQAO" }], "Contract": { "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30, "Id": "8004E000002EPIfQAO" }, "QLI": [{ "OneTimeCharge": 499, "RecurringCharge": 0, "Name": "Personlig Tekniker Plus" }], "FAQLI": { "Id": "0QL4E000000N7E2WAK" }, "Quote": { "ApprovalCount": 2, "CommercialBenchmark": "Nej", "InvoiceFee": "Ja", "PaymentTerm": 30 }, "IsQuoteLocked": false }';
          
        ComparePricesQuote_Contract obj= new ComparePricesQuote_Contract(); //instantiating the remote action class 
        Boolean var = obj.invokeMethod('validateFAQuote',inputMap,outMap, options);
        System.assertEquals(true, var);
    }
}