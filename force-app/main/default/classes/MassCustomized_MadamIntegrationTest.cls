@isTest
public class MassCustomized_MadamIntegrationTest 
{
    @testSetup
    static void initTestData() 
    {
        System.runAs(Test_DataFactory.getByPassUser()){
        List <MC_RAMMFA_Settings__c> RAMMFAList = new List <MC_RAMMFA_Settings__c> ();

        MC_RAMMFA_Settings__c offer1 = new MC_RAMMFA_Settings__c(Name = 'PricePlanCategory', Type_Name__c = 'F1GRUNDAVG', Type__c = 'Price Plan Category');
        RAMMFAList.add(offer1);
        
        MC_RAMMFA_Settings__c offer2 = new MC_RAMMFA_Settings__c(Name = 'SME', Type_Name__c = 'MFA ReadOnly', Type__c = 'Record Type');
        RAMMFAList.add(offer2);
        
        MC_RAMMFA_Settings__c offer3 = new MC_RAMMFA_Settings__c(Name = 'STO', Type_Name__c = 'RAM ReadOnly', Type__c = 'Record Type');
        RAMMFAList.add(offer3);
        
        MC_RAMMFA_Settings__c offer4 = new MC_RAMMFA_Settings__c(Name = 'SubscriptionCode', Type_Name__c = 'TJ', Type__c = 'Subscription Code');
        RAMMFAList.add(offer4);
        
        MC_RAMMFA_Settings__c offer5 = new MC_RAMMFA_Settings__c(Name = 'DefaultOffers', Type_Name__c = 'AGR_994_OFFER', Type__c = 'DefaultOffers');
        RAMMFAList.add(offer5);
            
        insert RAMMFAList;
        
        Account acc=Test_DataFactory.createOneSMEAccount();
        acc.Org_Nr__c = '5566765813';
        acc.C2B_Org_nr__c = '165566765813';
        insert acc;
        
        Account acc1=Test_DataFactory.createOneSMEAccount();
        acc1.Org_Nr__c = '5566765814';
        acc1.C2B_Org_nr__c = '165566765814';
        insert acc1;
        
        Account acc2=Test_DataFactory.createOneSMEAccount();
        acc2.Org_Nr__c = '5566765815';
        acc2.C2B_Org_nr__c = '165566765815';
        insert acc2;
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();    
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
        RecordType rt2 = [Select id,name, DeveloperName from RecordType where Name='RAM ReadOnly'];
        
        Quote testQuote = new Quote();
        Id userId = Userinfo.getUserId();
        Seller__c sellerInfo = Test_DataFactory.createBusinessAreaManagerSeller(userId);
        insert sellerInfo;
        Opportunity testOpportunity = Test_DataFactory.createSmeOpportunity();
        testOpportunity.AccountId = acc.id;
        insert testOpportunity;
        RecordType rt3 = [Select id,name, DeveloperName from RecordType where Name='Contract Quote'];     
            
        Contract contract=new Contract();
        contract.Name='Test';
        contract.AccountId=acc.id;
        contract.Status='Draft';
        contract.Solution_Area__c='Vxl';
        contract.StartDate=Date.today();
        contract.ContractTerm=24;
        contract.recordtypeId = rt1.id;
        contract.Agreement_Nr__c = '1000478';        
        insert contract;
        contract.Status='Active';
        update contract;
        
        testQuote.Name= 'Test Quote';
        testQuote.OpportunityId = testOpportunity.Id;
        testQuote.Status = 'Draft';
        testQuote.Pricebook2Id = stdPriceBookRecId;
        testQuote.RecordTypeId = rt3.Id; //RecordTypeIdQuote; //rt.Id;
        testQuote.vlocity_cmt__frameContractId__c=contract.id;
        insert testQuote;     
        testQuote.Status = 'Approved';
        update testQuote;   
            
        Contract contract1=new Contract();
        contract1.Name='Test1';
        contract1.AccountId=acc1.id;
        contract1.Status='Draft';
        //contract1.Mconline_Status__c='Valid';
        contract1.Solution_Area__c='Vxl';
        contract1.StartDate=Date.today();
        contract1.ContractTerm=24;
        contract1.recordtypeId = rt1.id;
        contract1.Agreement_Nr__c = '1000479';        
        insert contract1;
        contract1.Status='Active';
        update contract1;
        
        Contract contract3=new Contract();
        contract3.Name='Test3';
        contract3.AccountId=acc1.id;
        contract3.Status='Draft';
        //contract3.Mconline_Status__c='Valid';
        contract3.Solution_Area__c='Vxl';
        contract3.StartDate=Date.today();
        contract3.ContractTerm=24;
        contract3.recordtypeId = rt2.id;
        contract3.Agreement_Nr__c = '6243772';        
        insert contract3;
        contract3.Status='Active';
        update contract3;
        
        Contract contract2=new Contract();
        contract2.Name='Test2';
        contract2.AccountId=acc2.id;
        contract2.Mconline_Status__c='Freezed';
        contract2.Solution_Area__c='Vxl';
        contract2.StartDate=Date.today();
        contract2.ContractTerm=24;
        contract2.recordtypeId = rt1.id;
        contract2.Agreement_Nr__c = '1000480';        
        insert contract2;

        Contract contract4=new Contract();
        contract4.Name='Test2';
        contract4.AccountId=acc2.id;
        contract4.Mconline_Status__c='Cancelled';
        contract4.Solution_Area__c='Vxl';
        contract4.StartDate=Date.today();
        contract4.ContractTerm=24;
        contract4.recordtypeId = rt1.id;
        contract4.Agreement_Nr__c = '1000499';        
        insert contract4;   
            
        Utilizer_Contract_Relationship__c uti = new Utilizer_Contract_Relationship__c();
        uti.Org_Number__c = '165566765813';
        uti.Name = 'Test_Utilizer';
        uti.ContractNumber__c = contract.Id;
        uti.AccountId__c = acc.Id;
        insert uti;
        
        Utilizer_Contract_Relationship__c uti1 = new Utilizer_Contract_Relationship__c();
        uti1.Org_Number__c = '165566765813';
        uti1.Name = 'Test_Utilizer1';
        uti1.ContractNumber__c = contract2.Id;
        uti1.AccountId__c = acc2.Id;
        uti1.Status__c='Aktiv';
        insert uti1;
         
        MCOnline_Agreement_Services_Temp_data__c arg = new MCOnline_Agreement_Services_Temp_data__c ();
        arg.MCOnline_Agreement_number__c = '1000478';
        insert arg;
        
        Product2 prod1 = new Product2();
        prod1.ProductCode = 'AGR_108';
        prod1.Name = 'AGROffer';
        prod1.C2BC_Category__c = 'offerbundle';
        prod1.C2BC_Subcategory__c = '';
        prod1.Family = 'Mobility Management';
        prod1.IsActive =true;
        prod1.vlocity_cmt__Status__c = 'Active';
        insert prod1;
        
        Product2 prod2 = new Product2();
        prod2.ProductCode = 'AGR_50';
        prod2.Name = '50 GB';
        prod2.C2BC_Category__c = 'mobilevoicesubscription';
        prod2.C2BC_Subcategory__c = 'voice';
        prod2.Family = 'Online Order';
        prod2.IsActive =true;
        prod2.TeliaSE_Subscription_Type__c = 'XÖ';
        prod2.vlocity_cmt__Status__c = 'Active';
        insert prod2;
        
        Product2 prod3 = new Product2();
        prod3.ProductCode = 'AGR_XY';
        prod3.Name = 'XY';
        prod3.C2BC_Category__c = 'mobilevoicesubscription';
        prod3.C2BC_Subcategory__c = '';
        prod3.Family = 'Online Order';
        prod3.IsActive =true;
        prod3.TeliaSE_Product_Service_Code__c = 'XY';
        prod3.vlocity_cmt__Status__c = 'Active';
        insert prod3;
        
        Product2 prod4 = new Product2();
        prod4.ProductCode = 'AGR_CD';
        prod4.Name = 'CD';
        prod4.C2BC_Category__c = 'mobilevoicesubscription';
        prod4.C2BC_Subcategory__c = '';
        prod4.Family = 'Online Order';
        prod4.IsActive =true;
        prod4.TeliaSE_Product_Service_Code__c = 'CD';
        prod4.vlocity_cmt__Status__c = 'Active';
        insert prod4;
        
        Product2 prod5 = new Product2();
        prod5.ProductCode = 'AGR_994_OFFER';
        prod5.Name = 'AGROffer';
        prod5.C2BC_Category__c = 'offerbundle';
        prod5.C2BC_Subcategory__c = '';
        prod5.Family = 'Mobility Management';
        prod5.IsActive =true;
        prod5.vlocity_cmt__Status__c = 'Active';
        insert prod5;
        
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod2.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
        QuoteLineItem testQLI = new QuoteLineItem();     
        testQLI.PricebookEntryId=objpricebookentry.Id;
        testQLI.Product2Id= prod2.Id;
        testQLI.UnitPrice=0;
        testQLI.Quantity=1;
        testQLI.vlocity_cmt__ProductHierarchyPath__c='01t08000009Rd4qAAC<01t08000009Rd4HAAS<01t1p0000095vXRAAY';
        testQLI.QuoteId=testQuote.Id;    
        Insert testQLI;
            
        vlocity_cmt__ContractLineItem__c cli1=new vlocity_cmt__ContractLineItem__c();
        cli1.vlocity_cmt__ContractId__c=contract.Id;
        cli1.vlocity_cmt__Product2Id__c= prod2.Id;
        cli1.vlocity_cmt__RecurringCharge__c=230.99; 
        cli1.vlocity_cmt__QuoteLineItem__c=testQLI.Id;    
        insert cli1;    
        
        vlocity_cmt__ContractLineItem__c cli2=new vlocity_cmt__ContractLineItem__c();
        cli2.vlocity_cmt__ContractId__c=contract.Id;
        cli2.vlocity_cmt__Product2Id__c= prod4.Id;
        cli2.TeliaSE_MC_Customer_Requested_Price__c=230.99;
        cli2.vlocity_cmt__QuoteLineItem__c=testQLI.Id;
        insert cli2;     
        
            
        MC_AgreementPlanChange__c agr = new MC_AgreementPlanChange__c();
        agr.MC_AgreementNumber__c = '113868';
        agr.MC_PricePlan__c = 'F10000';
        agr.MC_PricePlanCategory__c = 'F1GRUNDAVG';
        agr.MC_PricePlanType__c = 'MOBILL';
        agr.MC_DateFrom__c = '2022-03-12 00:00:00';
        agr.MC_SubscriptionType__c = 'XÖ';
        insert agr;
        
        MC_AgreementPlanChange__c agr1 = new MC_AgreementPlanChange__c();
        agr1.MC_AgreementNumber__c = '113868';
        agr1.MC_PricePlan__c = 'F10000';
        agr1.MC_PricePlanCategory__c = 'F2GRUNDAVG';
        agr1.MC_PricePlanType__c = 'MOBILL';
        agr1.MC_DateFrom__c = '2022-03-12 00:00:00';
        agr1.MC_DateTo__c = '2030-12-12 00:00:00';
        agr1.MC_SubscriptionType__c = 'XÖ';
        insert agr1;
        
        MC_AgreementPlanChange__c agr2 = new MC_AgreementPlanChange__c();
        agr2.MC_AgreementNumber__c = '113868';
        agr2.MC_PricePlan__c = 'F10001';
        agr2.MC_PricePlanCategory__c = 'F2GRUNDAVG';
        agr2.MC_PricePlanType__c = 'MOBILL';
        agr2.MC_DateFrom__c = '2022-03-12 00:00:00';
        agr2.MC_SubscriptionType__c = 'XÖ';
        insert agr2;
        
        MC_AgreementPlanChange__c agr3 = new MC_AgreementPlanChange__c();
        agr3.MC_AgreementNumber__c = '1000478';
        agr3.MC_PricePlan__c = 'F10001';
        agr3.MC_PricePlanCategory__c = 'F1GRUNDAVG';
        agr3.MC_PricePlanType__c = 'MOBILL';
        agr3.MC_DateFrom__c = '2022-03-12 00:00:00';
        agr3.MC_SubscriptionType__c = '98';
        insert agr3;
        
        MC_AgreementPlanChange__c agr4 = new MC_AgreementPlanChange__c();
        agr4.MC_AgreementNumber__c = '1000478';
        agr4.MC_PricePlan__c = 'F10001';
        agr4.MC_PricePlanCategory__c = 'F1GRUNDAVG';
        agr4.MC_PricePlanType__c = 'MOBILL';
        agr4.MC_DateFrom__c = '2022-03-12 00:00:00';
        agr4.MC_SubscriptionType__c = 'CD';
        insert agr4;
        
        MC_AgreementPlanChange__c agr5 = new MC_AgreementPlanChange__c();
        agr5.MC_AgreementNumber__c = '1000478';
        agr5.MC_PricePlan__c = 'F10001';
        agr5.MC_PricePlanCategory__c = 'F1GRUNDAVG';
        agr5.MC_PricePlanType__c = 'MOBILL';
        agr5.MC_DateFrom__c = '2022-03-12 00:00:00';
        agr5.MC_SubscriptionType__c = 'XÖ';
        insert agr5;    
            
        MC_PrismaPlan__c pri = new MC_PrismaPlan__c();
        pri.MC_Price_Plan__c = 'F10000';
        pri.MC_Price_Plan_Category__c = 'F1GRUNDAVG';
        pri.MC_Agreement_MRC_Price__c = '264.00';
        pri.MC_Agreement_NRC_Price__c = '0.00';
        pri.MC_ServiceCode__c = 'TJ';
        pri.MC_ServiceValue__c = '';
        insert pri;
        
        MC_PrismaPlan__c pri1 = new MC_PrismaPlan__c();
        pri1.MC_Price_Plan__c = 'F10001';
        pri1.MC_Price_Plan_Category__c = 'F2GRUNDAVG';
        pri1.MC_Agreement_MRC_Price__c = '89.00';
        pri1.MC_Agreement_NRC_Price__c = '0.00';
        pri1.MC_ServiceCode__c = 'XY';
        pri1.MC_ServiceValue__c = '';
        insert pri1;
            
        MC_PrismaPlan__c pri2 = new MC_PrismaPlan__c();
        pri2.MC_Price_Plan__c = 'F10001';
        pri2.MC_Price_Plan_Category__c = 'F1GRUNDAVG';
        pri2.MC_Agreement_MRC_Price__c = '89.00';
        pri2.MC_Agreement_NRC_Price__c = '0.00';
        pri2.MC_ServiceCode__c = 'XY';
        pri2.MC_ServiceValue__c = '';
        insert pri2;    
        }
    }
    @istest
    static void madamAgreementIntegrationTest1()
    {
        List<Contract> contractlist=[Select id from Contract Where Agreement_Nr__c='1000478' LIMIT 1];
        String data = '{"SetParameter":{"agreementNumber":"1000478","serviceContractNumber":"02053337","contractId":null},"operation":"Update","agreement":{"agreementNumber":"11100383","agreementVersion":null,"agreementType":"STO","agreementStartDate":"2022-02-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"STO","agreementStatus":"V","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":"02053928","accountId":"5566765813","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"165566765813","status":"V","name":"Test_Utilizer"},{"organizationNumber":"1655667654","status":"V","name":"Test_Utilizer1"},{"organizationNumber":"165566765814","status":"V","name":"Test_Utilizer2"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        inputMap2.put('agreementTypeChange','');
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('generateCustomError',inputMap2,outputMap,options);
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest2()
    {
        List<Contract> contractlist=[Select id, Account.Org_Nr__c from Contract Where Agreement_Nr__c='1000479' LIMIT 1];
        String data = '{"SetParameter":{"agreementNumber":"1000479","serviceContractNumber":"02053337","contractId":null},"operation":"Update","agreement":{"agreementNumber":"1000479","agreementVersion":null,"agreementType":"STO","agreementStartDate":"2022-02-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"STO","agreementStatus":"N","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":"02053928","accountId":"165566765814","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"5566765813","status":"V","name":"Test_Utilizer"},{"organizationNumber":"55667654","status":"V","name":"Test_Utilizer1"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        inputMap2.put('agreementTypeChange','');
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        MassCustomized_MadamIntegration.signalMadam('02053337', '1000479', String.valueOf(contractlist[0].id), String.valueOf(contractlist[0].Account.Org_Nr__c));
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest3()
    {
        //List<Contract> contractlist=[Select id from Contract Where Agreement_Nr__c='1000479' LIMIT 1];
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"113868","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"SME","agreementStatus":"V","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":null,"accountId":"165563750230","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"165563750230","status":"V","name":"Test_Utilizer"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"},"":""}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        //options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        inputMap2.put('agreementTypeChange','');
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        Test.stopTest();
    }
    
   

    @istest
    static void madamAgreementIntegrationTest4()
    {
        //List<Contract> contractlist=[Select id from Contract Where Agreement_Nr__c='1000479' LIMIT 1];
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"113868","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"SME","agreementStatus":"V","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":null,"accountId":"165566765814","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"165563750230","status":"V","name":"Test_Utilizer"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"},{"subscriptionTypeStatus":"Not Valid","subscriptionType":"YY"},{"subscriptionTypeStatus":"Exists","subscriptionType":"ZZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"CD"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"},"":""}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        //options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        inputMap2.put('agreementTypeChange','');
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        Test.stopTest();
    }
    
    @istest
    static void madamAgreementIntegrationTest5()
    {
        List<Contract> contractlist=[Select id from Contract Where Agreement_Nr__c='1000480' LIMIT 1];
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"1000480","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"SME","agreementStatus":"V","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":"165566765813","accountId":"165566765815","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"165566765815","status":"V","name":"Test_Utilizer"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"},"":""}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        inputMap2.put('agreementTypeChange','');
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        Test.stopTest();
    }
    
    @istest
    static void madamAgreementIntegrationTest6()
    {
        List<Contract> contractlist=[Select id from Contract Where Agreement_Nr__c='1000480' LIMIT 1];
        String data = '{"operation":"Delete","agreement":{"agreementNumber":"1000480","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"SME","agreementStatus":"N","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":"165566765813","accountId":"165566765815","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"165566765815","status":"V","name":"Test_Utilizer"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"},"":""}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest7()
    {
        List<Contract> contractlist=[Select id from Contract Where Agreement_Nr__c='6243772' LIMIT 1];
        String data = '{"operation":"upsert","agreement":{"agreementNumber":"6243772","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"STO","agreementStatus":"N","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":"165566765813","accountId":"165566765814","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"165566765815","status":"V","name":"Test_Utilizer"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"},"":""}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest8()
    {
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"1828473","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"UNDER","superiorAgreementNumber":"1000478","agreementType":"SME","agreementStatus":"V","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","accountId":"165566765813","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Exists","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"},{"subscriptionTypeStatus":"Not Valid","subscriptionType":"YZ"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('underavtalAgreementRequest',inputMap,outputMap,options);
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest9()
    {
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"1828473","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"UNDER","superiorAgreementNumber":"1000478","agreementType":"SME","agreementStatus":"V","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","accountId":"165566765815","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('underavtalAgreementRequest',inputMap,outputMap,options);
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest10()
    {
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"1828473","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"UNDER","superiorAgreementNumber":"2865345","agreementType":"SME","agreementStatus":"V","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","accountId":"165566765815","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('underavtalAgreementRequest',inputMap,outputMap,options);
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest11()
    {
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"1828473","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"UNDER","superiorAgreementNumber":"2865345","agreementType":"SME","agreementStatus":"V","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","accountId":"238573445","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('underavtalAgreementRequest',inputMap,outputMap,options);
        Test.stopTest();
    }
    
    @istest
    static void madamAgreementIntegrationTest12()
    {
        List<Contract> contractlist=[Select id from Contract Where Agreement_Nr__c='1000499' LIMIT 1];
        String data = '{"operation":"Delete","agreement":{"agreementNumber":"1000499","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"SME","agreementStatus":"E","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":"165566765813","accountId":"165566765815","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"165566765815","status":"V","name":"Test_Utilizer"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"},"":""}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest13()
    {
        List<Contract> contractlist=[Select id from Contract Where Agreement_Nr__c='1000499' LIMIT 1];
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"1000499","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"SME","agreementStatus":"E","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":"165566765813","accountId":"165566765815","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"165566765815","status":"V","name":"Test_Utilizer"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"},"":""}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest14()
    {
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"1828473","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"UNDER","superiorAgreementNumber":"1000478","agreementType":"SME","agreementStatus":"E","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","accountId":"165566765813","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        String data1 = '{"operation":"Insert","agreement":{"agreementNumber":"1828473","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"UNDER","superiorAgreementNumber":"1000478","agreementType":"SME","agreementStatus":"N","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","accountId":"165566765813","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        inputMap1 = (Map<String, Object>)JSON.deserializeUntyped(data1);
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('underavtalAgreementRequest',inputMap,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('underavtalAgreementRequest',inputMap1,outputMap,options);
        Test.stopTest();
    }
    @istest
    static void madamAgreementIntegrationTest15()
    {
        String data = '{"operation":"Insert","agreement":{"agreementNumber":"1828473","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"UNDER","superiorAgreementNumber":"1000478","agreementType":"SME","agreementStatus":"E","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","accountId":"165566765815","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        String data1 = '{"operation":"Insert","agreement":{"agreementNumber":"1828473","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"UNDER","superiorAgreementNumber":"1000478","agreementType":"SME","agreementStatus":"N","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","accountId":"165566765815","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"}}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data1);
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('underavtalAgreementRequest',inputMap,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('underavtalAgreementRequest',inputMap1,outputMap,options);
        Test.stopTest();
    }
    
     @istest
    static void madamAgreementIntegrationTest33()
    {
        String data = '{"operation":"Update","agreement":{"agreementNumber":"1000478","agreementVersion":null,"agreementStartDate":"2022-05-28 00:00:00","agreementEndDate":"2024-02-28 00:00:00","minimumNumberSubscription":"76","agreementLevel":"RAM","agreementType":"SME","agreementStatus":"V","agreementCategory":"108","agreementContactName":"BINAMRA GUHA","agreementSignedDate":"2022-01-14 00:00:00","serviceContractNumber":null,"accountId":"165563750230","ownerId":"BGA998","services":[{"subscriptionType":"98","serviceCode":"RLHT","serviceStatus":"V","serviceAvailable":"DEF"}],"utilizer":[{"organizationNumber":"165563750230","status":"V","name":"Test_Utilizer"}],"agreementItem":[{"subscriptionTypeStatus":"Valid","subscriptionType":"XÖ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÄ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XÅ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XZ"},{"subscriptionTypeStatus":"Valid","subscriptionType":"XY"}],"agreedAmountMobile":"230","agreedAmountTP":"345","miniDebAlertType":"Active","mobileMiniDebWarningPercentage":"34","mobileMiniWarningActiveFlag":"Y","numberOfSubscriptionsMobile":"6","numberOfSubscriptionsTP":"8","tpMiniDebWarningPercentage":"23","tpMiniWarningActiveFlag":"N"},"":""}';
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        //options.put('contractId', String.valueOf(contractlist[0].id));
        Map<String, Object> inputMap2 = (Map<String,Object>)inputMap;
        inputMap2.put('agreementTypeChange','');
        Test.startTest();
        new MassCustomized_MadamIntegration().invokeMethod('manageMadamRequest',inputMap2,outputMap,options);
        new MassCustomized_MadamIntegration().invokeMethod('logError',inputMap2,outputMap,options);
        Test.stopTest();
    }
    
    @istest
    static void madamAgreementIntegrationTest34()
    {
        String agrCode='1000478';
        Set<String> subSet =new Set<String>{'98','99','XÖ','CD'};
        List<Contract> contractlist=[Select id from Contract Where Agreement_Nr__c='1000478' LIMIT 1];
        Test.startTest();
        MassCustomized_MadamIntegration.updateIndexedPrice(agrCode,subSet,contractlist[0].id);
        Test.stopTest();
    }
}