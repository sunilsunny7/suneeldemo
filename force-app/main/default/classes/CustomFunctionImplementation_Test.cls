@isTest
public with sharing class CustomFunctionImplementation_Test 
{
    
    //function test: MultiPicklistChoose    
    @isTest
    public static void FunctionEval1()
    {
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        List<Object> arguments = new List<Object>();
        
        List<String> multipicklist = new List<String>();
        multipicklist.add('MOB_MULTI_ALL_IN_PLUS');
        multipicklist.add('MOB_MULTI_TOTAL');
        multipicklist.add('TP_OFFER');
        String offerproductCodes = String.join(multipicklist,';');      
        String productCode = 'MOB_MULTI_ALL_IN_PLUS';
        
        arguments.add(offerproductCodes);
        arguments.add(ProductCode);
        inputs.put('arguments',arguments);
        CustomFunctionImplementation obj=new CustomFunctionImplementation();
        Boolean flag = obj.invokeMethod('MultiPicklistChoose', inputs, output, options);
        System.assertEquals(true, flag);
    }
    @isTest
    static void testGroupSorting() {
        // Test data set
        List<Object> ListGroupMap = new List<Object>{
            new Map<String,Object>{'GroupIndex' => 3},
                new Map<String,Object>{'GroupIndex' => 2},
                    new Map<String,Object>{'GroupIndex' => 1}
        };
            
            // Instantiate class containing method to test
            MassCustomized_Agreement_Generation myClassInstance = new MassCustomized_Agreement_Generation();
        
        // Call the method to test
        List<Object> sortedList = myClassInstance.groupSorting(ListGroupMap);
    }
    
    //function test: MultiPicklistChoose
    @isTest
    public static void FunctionEval2()
    {
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        List<Object> arguments = new List<Object>();
        
        List<String> multipicklist = new List<String>();
        multipicklist.add('MOB_MULTI_ALL_IN_PLUS');
        multipicklist.add('MOB_MULTI_TOTAL');
        multipicklist.add('TP_OFFER');
        String offerproductCodes = String.join(multipicklist,';');  
        
        //Keeping product Code empty so that it goes in catch block
        arguments.add(offerproductCodes);
        //arguments.add(ProductCode);
        inputs.put('arguments',arguments);
        CustomFunctionImplementation obj=new CustomFunctionImplementation();
        Boolean flag = obj.invokeMethod('MultiPicklistChoose', inputs, output, options);
    }
    
    //function test: DeleteCaseId    
    @isTest
    public static void FunctionEval3()
    {
        User salesManager; 
        Test_DataFactory.setUpOrg();        
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            
            
            Account acc;
            acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            Quote qut1 = new Quote();
            qut1.Name='Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False; 
            qut1.TeliaSE_Type__c='Y';
            insert qut1;
            
            Quote qut2 = new Quote();
            qut2.Name='CallOff';
            qut2.status = 'Draft';
            qut2.opportunityId = opp.id;
            qut2.TeliaSE_Approval_Flag__c = False; 
            qut2.TeliaSE_Type__c='Y';
            insert qut2;
            
            Contract conObj = new Contract();
            conObj.vlocity_cmt__QuoteId__c=qut1.id;
            conObj.TeliaSE_Type__c = 'Y';
            conObj.StartDate = system.today();
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            conObj.TeliaSE_is_combi__c = true;
            conObj.Status = 'Draft';
            insert conObj;
            
            conObj.TeliaSE_Case_Id__c = '123';
            conObj.TeliaSE_TUPP_Interface_Name__c = 'createAgreementCase';
            
            Update conObj;
            String contractId = (String)conObj.id;
            
            Map<String,Object> inputs=new Map<String,Object>();
            Map<String,Object> output=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            List<Object> arguments = new List<Object>();
            
            arguments.add(contractId);
            //arguments.add(ProductCode);
            inputs.put('arguments',arguments);
            CustomFunctionImplementation obj=new CustomFunctionImplementation();
            Boolean flag = obj.invokeMethod('DeleteCaseId', inputs, output, options);
        }
    }
    
    //function test: ESDAgreementItem
    @isTest
    public static void FunctionEval4(){
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        String input ='{"agreementItem":[{"@agreementCharacteristics":"TeliaAgreementItemCharacteristics","@type":"ProductOffering","@referredType":"ProductOffering","family":"Mobile Offer Specification","Level":0,"warningActive":"N","subsidizedVoice":"Yes","startDate":"2020-07-30T00:00:00 +0000","recurringFee":0,"quarantineTime":"3","productName":"Mobilupplägg All-IN+","productCode":"MOB_MULTI_ALL_IN_PLUS_V2","oneTimeFee":0,"minimumCommit":"75","id":"MOB_MULTI_ALL_IN_PLUS_V2","functionActive":"N","endDate":"2022-07-30T00:00:00 +0000","commitmentPeriod":"24 months","baseQuantity":22},{"@agreementCharacteristics":"TeliaAgreementItemCharacteristics","@type":"ProductOffering","@referredType":"ProductOffering","family":"Mobile Offer Specification","Level":1,"startDate":"2020-07-30T00:00:00 +0000","recurringFee":529,"quarantineTime":"3","productName":"Jobbmobil 15 GB","productCode":"MOB_MULTI_15_V2","oneTimeFee":0,"offeringCode":"94","id":"MOB_MULTI_15_V2","endDate":"2022-07-30T00:00:00 +0000"}]}';
        Map<String,Object> contractLineItem = (Map<String,Object>)json.deserializeUntyped(input);
        List<Object> contractLineItems =(List<Object>) contractLineItem.get('agreementItem');        
        List<Map<String,Object>> inputLineItems = new List<Map<String,Object>>();
        for(Object obj1 : contractLineItems)
        {
            Map<String,Object> cli = (Map<String,Object>) obj1;
            inputLineItems.add(cli);
        }
        
        List<Object> arguments = new List<Object>();
        arguments.addAll(inputLineItems);
        inputs.put('arguments',arguments);
        CustomFunctionImplementation obj=new CustomFunctionImplementation();
        Boolean flag = obj.invokeMethod('ESDAgreementItem', inputs, output, options);
        
    }
    
    //function test: countMatchesString
    @isTest
    public static void FunctionEval5(){
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        List<Object> arguments = new List<Object>();
        String hierarchy = 'abcebcb>nincin>4';
        string separator = '>';
        arguments.add(hierarchy);
        arguments.add(separator);
        inputs.put('arguments',arguments);
        CustomFunctionImplementation obj=new CustomFunctionImplementation();
        Boolean flag = obj.invokeMethod('countMatchesString', inputs, output, options);
        system.assertEquals(2, output.get('result'));
    }
    
    //function test: split
    @isTest
    public static void FunctionEval6(){
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        List<Object> arguments = new List<Object>();
        String hierarchy = '12345;abcdef;wedfun';
        arguments.add(hierarchy);
        inputs.put('arguments',arguments);
        CustomFunctionImplementation obj=new CustomFunctionImplementation();
        Boolean flag = obj.invokeMethod('split', inputs, output, options);
    }
    //function test: ImParent
    @isTest
    public static void FunctionEval7(){
        Map<String,Object> inputs=new Map<String,Object>();
        Map<String,Object> output=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        List<Object> arguments = new List<Object>();
        String hierarchy = '123443243242342342342342342345<4324234abcd324324234324324ef<wedfu234234234234234n';
        String query = 'wedfu234234234234234n';
        arguments.add(hierarchy);
        arguments.add(query);
        inputs.put('arguments',arguments);
        CustomFunctionImplementation obj=new CustomFunctionImplementation();
        Boolean flag = obj.invokeMethod('ImmediateParent', inputs, output, options);
    }
    //function test: testOffer
    
   
    
    @isTest
    Public static void FunctionEval11(){
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
            newObj.Name = 'Smart Connect Specification';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            List<Product2> prodList = new List<Product2>();
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.Name = 'SURF AddOn';
            prod4.productCode = 'SC_OFFER';
            prod4.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prod4.MC_Product_Name_Eng__c = 'SURF AddOn';
            prodList.add(prod4);            
            insert prodList;
            
            List<PricebookEntry> pbelist = new List<PricebookEntry>();
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod4.id;            
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            pbeList.add(objpricebookentry);
            insert pbelist;
            
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
            
      Quote faQuote = new Quote();
            faQuote.Name='Test Quote';
            faQuote.status = 'Draft';
            faQuote.TeliaSE_Type__c='Renegotiation';
            faQuote.opportunityId = opp.id;
            faQuote.Pricebook2ID = stdPriceBookRecId;
            faQuote.TeliaSE_Approval_Flag__c = true; 
            //faQuote.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            faQuote.TeliaSE_MC_Sales_Flow_Identifier__c = 'Omforhandling';
            insert faQuote;
            
            list<QuoteLineItem> offerQLI = new list<QuoteLineItem>();
            QuoteLineItem qli1 = new QuoteLineItem();
            qli1.PricebookEntryId = objpricebookentry.Id;
            qli1.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            qli1.QuoteId = faQuote.id;
            qli1.UnitPrice = 200;
            qli1.Quantity = 4;
            qli1.vlocity_cmt__Product2Id__c = prod4.id;
            qli1.Product2Id = prod4.id;
            qli1.vlocity_cmt__ParentItemId__c = null;
            qli1.vlocity_cmt__RecurringCharge__c = 100;
            //oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            qli1.TeliaSE_ParentClusterCode__c = 'bas';
            offerQLI.add(qli1);
            
            insert offerQLI;
            List<Object> arguments = new List<Object>();
            
            arguments.add(faQuote.id);
            //arguments.add(ProductCode);
            inputs.put('arguments',arguments);
            CustomFunctionImplementation obj=new CustomFunctionImplementation();
            Boolean flag = obj.invokeMethod('SCRenegotiation', inputs, output, options);
        }
    }
    
    @isTest
    public static void testCallOffBundled(){
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Integer i = Integer.valueOf(system.label.MC_CallOffPricingBundleSize);
        i = i*2 + 10; 
        List<Object> argumentList = new List<Object>();
        for(Integer j = 0 ; j<i;j++){
            Map<String,Object> mapTemp = new Map<String,Object>();
            String value = string.valueOf(j);
            mapTemp.put('Id',stdPriceBookRecId);
            argumentList.add((Object)mapTemp);
        }
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> optionsMap = new Map<String,Object>();
        inputMap.put('arguments',argumentList);
        CustomFunctionImplementation obj=new CustomFunctionImplementation();
        Boolean flag = obj.invokeMethod('BundleItemsCallOff', inputMap, outputMap, optionsMap);        
    }
            
}