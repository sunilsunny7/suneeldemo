@isTest
public class Test_TeliaSE_Renegotiation {
    
    @testSetup static void setup(){
   User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Id ContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('TeliaSE_Framework_Agreement').getRecordTypeId();
       
        System.runAs(new User(Id = Userinfo.getUserId())){
        //salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        }
        System.runAs(salesManager){
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.name='mobile bredband';
        insert prod;
            
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        insert prod1;
        pricebookId = stdPriceBookRecId ;
       
             
        Account acc=Test_DataFactory.createOneSMEAccount();
        acc.TeliaSE_Utilzer_Role__c = 'Utilizer';
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
         
            Date today=Date.today();
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.EndDate=today.addMonths(13);
            contract.ContractTerm=24;
            contract.RecordTypeId = ContractRecordTypeId ;
            contract.Agreement_Nr__c='70000200';
                
            insert contract;
            contract.Status = 'Active';
            update contract;
            
        vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
            cli.name='Office';
            cli.TeliaSE_ParentItemId__c=null;
            cli.vlocity_cmt__product2id__c=prod.id;
            cli.vlocity_cmt__ContractId__c=contract.id;
            cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
        insert cli;       
        vlocity_cmt__ContractLineItem__c cli1=new vlocity_cmt__ContractLineItem__c();
            cli1.name='mobile';
            cli1.TeliaSE_ParentItemId__c=null;
            cli1.vlocity_cmt__product2id__c=prod.id;
            cli1.vlocity_cmt__ContractId__c=contract.id;
            cli1.TeliaSE_MC_Customer_Requested_Percentage__c=5;
        insert cli1;  
        }
    }
    
    testMethod public static void test()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> summary=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Map<String,Object> frameAgreement=new Map<String,Object>();
        
        Map<String,Object> frameAgreement1=new Map<String,Object>();
        Map<String,Object> frameAgreement2=new Map<String,Object>();
        Map<String,Object> frameAgreement3=new Map<String,Object>();
       
        
        List<Map<String,Object>> inOffers=new List<Map<String,Object>>();
        Map<String,Object> inOffer=new Map<String,Object>();
                inOffer.put('code','blah');
        inOffers.add(inOffer);
        
        List<Map<String,Object>> minimiDebitFunctions=new List<Map<String,Object>>();
        Map<String,Object> minimiDebitFunction=new Map<String,Object>();
            minimiDebitFunction.put('productId','MOBILE');
        	minimiDebitFunction.put('agreedAmount','100');
        	minimiDebitFunction.put('agreedPercentage','50');
        	minimiDebitFunction.put('functionStartDate','2020-06-22');
        	minimiDebitFunction.put('functionActive','Y');
        	minimiDebitFunction.put('commitmentPeriod','24');
        	minimiDebitFunction.put('commitmentStartDate','2020-03-22');
        	minimiDebitFunction.put('commitmentStopDate','2022-03-22');
        	minimiDebitFunction.put('minimiDebitLastExecution','');
        	minimiDebitFunction.put('minimiDebitTriggered','N');
        	minimiDebitFunction.put('minimiDebitLastCountAmount','');
        	minimiDebitFunction.put('warningPercentage','90');
        	minimiDebitFunction.put('warningActive','Y');
        	minimiDebitFunction.put('warningLastExecution','');
        	minimiDebitFunction.put('warningTriggered','N');
        	minimiDebitFunction.put('warningLastCountAmount','');
        minimiDebitFunctions.add(minimiDebitFunction);
        Map<String,Object> minimiDebitFunction1 = new Map<String,Object>();
            minimiDebitFunction1.put('productId','TOUCHPOINT');
        	minimiDebitFunction1.put('agreedAmount','100');
        	minimiDebitFunction1.put('agreedPercentage','50');
        	minimiDebitFunction1.put('functionStartDate','2020-06-22');
        	minimiDebitFunction1.put('functionActive','Y');
        	minimiDebitFunction1.put('commitmentPeriod','24');
        	minimiDebitFunction1.put('commitmentStartDate','2020-03-22');
        	minimiDebitFunction1.put('commitmentStopDate','2022-03-22');
        	minimiDebitFunction1.put('minimiDebitLastExecution','');
        	minimiDebitFunction1.put('minimiDebitTriggered','N');
        	minimiDebitFunction1.put('minimiDebitLastCountAmount','');
        	minimiDebitFunction1.put('warningPercentage','90');
        	minimiDebitFunction1.put('warningActive','Y');
        	minimiDebitFunction1.put('warningLastExecution','');
        	minimiDebitFunction1.put('warningTriggered','N');
        	minimiDebitFunction1.put('warningLastCountAmount','');
        minimiDebitFunctions.add(minimiDebitFunction1);
        
        List<Map<String,Object>> frameAgreements=new List<Map<String,Object>>();
        frameAgreement.put('customerRole','Blah');
        frameAgreement.put('customerRoleStatus','Blah');
        frameAgreement.put('frameAgreementId','70000200');
        frameAgreement.put('frameAgreementLevel','Blah');
        frameAgreement.put('frameAgreementType','Blah');    
        frameAgreement.put('frameAgreementStatus','Blah');
        frameAgreement.put('zeroPriceExist',true);
        frameAgreement.put('frameAgreementStartDate','2019-08-01');
        frameAgreement.put('frameAgreementEndDate','2020-12-22');
        frameAgreement.put('numberOfUtilizers',47);
        frameAgreement.put('inOffers',inOffers);
		frameAgreement.put('minimiDebitFunctions',minimiDebitFunctions);
        
        frameAgreement1.put('customerRole','O');
        frameAgreement1.put('customerRoleStatus','V');
        frameAgreement1.put('frameAgreementId','70000201');
        frameAgreement1.put('frameAgreementLevel','RAM');
        frameAgreement1.put('frameAgreementType','STO');    
        frameAgreement1.put('frameAgreementStatus','V');
        frameAgreement1.put('zeroPriceExist',false);
        frameAgreement1.put('frameAgreementStartDate','2019-08-01');
        frameAgreement1.put('frameAgreementEndDate','2021-03-22');
        frameAgreement1.put('numberOfUtilizers',0);

        frameAgreement2.put('customerRole','O');
        frameAgreement2.put('customerRoleStatus','V');
        frameAgreement2.put('frameAgreementId','70000202');
        frameAgreement2.put('frameAgreementLevel','UNDER');
        frameAgreement2.put('frameAgreementType','STO');    
        frameAgreement2.put('frameAgreementStatus','V');
        frameAgreement2.put('zeroPriceExist',false);
        frameAgreement2.put('frameAgreementStartDate','2019-08-01');
        frameAgreement2.put('frameAgreementEndDate','2022-09-22');
        frameAgreement2.put('numberOfUtilizers',0);

        frameAgreement3.put('customerRole','O');
        frameAgreement3.put('customerRoleStatus','V');
        frameAgreement3.put('frameAgreementId','70000210');
        frameAgreement3.put('frameAgreementLevel','RAM');
        frameAgreement3.put('frameAgreementType','STO');    
        frameAgreement3.put('frameAgreementStatus','V');
        frameAgreement3.put('zeroPriceExist',false);
        frameAgreement3.put('frameAgreementStartDate','2019-08-01');
        frameAgreement3.put('frameAgreementEndDate','2024-03-22');
        frameAgreement3.put('numberOfUtilizers',0);
        frameAgreement3.put('inOffers',new List<Object>());


        
        frameAgreements.add(frameAgreement);
        frameAgreements.add(frameAgreement1);
        frameAgreements.add(frameAgreement2);
       // frameAgreements.add(frameAgreement3);

        


        summary.put('result','OK');
        summary.put('frameAgreements',frameAgreements);
        
        TeliaSE_Renegotiation obj=new TeliaSE_Renegotiation();
        inputMap.put('CustomerAgreementSummary',summary);
        obj.invokeMethod('renegotiateValidation', inputMap, outMap, options);
        obj.invokeMethod('hardwareRenegotiateValidation', inputMap, outMap, options);
        
        frameAgreements.clear();
        frameAgreements.add(frameAgreement3);
        obj.invokeMethod('renegotiateValidation', inputMap, outMap, options);
        obj.invokeMethod('hardwareRenegotiateValidation', inputMap, outMap, options);
        
        frameAgreements.clear();
        frameAgreement3.put('frameAgreementStartDate','2022-08-01');
        frameAgreement3.put('frameAgreementEndDate','2023-09-22');
        frameAgreements.add(frameAgreement3);
        obj.invokeMethod('renegotiateValidation', inputMap, outMap, options);
        
        frameAgreements.clear();
        frameAgreement3.put('frameAgreementStartDate','2022-08-01');
        frameAgreement3.put('frameAgreementEndDate','2024-09-22');
        frameAgreements.add(frameAgreement3);
        obj.invokeMethod('renegotiateValidation', inputMap, outMap, options);
        
        
        summary.put('result','NOTOK');
        inputMap.put('CustomerAgreementSummary',summary);
        obj.invokeMethod('renegotiateValidation', inputMap, outMap, options);
        obj.invokeMethod('hardwareRenegotiateValidation', inputMap, outMap, options);
        
    }

    testMethod public static void testMobile()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
       
        Contract con=[select id,startDate,endDate from Contract limit 1];
        inputMap.put('agreementId',con.id);
        
        TeliaSE_Renegotiation obj=new TeliaSE_Renegotiation();
        Test.startTest();
        obj.invokeMethod('nonMobileProductsCheck', inputMap, outMap, options);
        Test.stopTest();
    }
    
    testMethod public static void testMobile2()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
       
        //Contract con=[select id,startDate,endDate from Contract limit 1];
        Date startDate=Date.today();
        Date endDate=startDate.addMonths(25);
        Map<String,Object> contractmap = new Map<String,Object>();
        contractMap.put('ContractExist',true);
        contractMap.put('ContractStartDate',String.valueOf(startDate));
        contractMap.put('ContractEndDate',String.valueOf(endDate));
        inputMap.put('ContractDetails',contractmap);
        TeliaSE_Renegotiation obj=new TeliaSE_Renegotiation();

        obj.invokeMethod('nonMobileProductsCheck', inputMap, outMap, options);
        
    }
    
    testMethod public static void testMobile3()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
       
        //Contract con=[select id,startDate,endDate from Contract limit 1];
        Date startDate=Date.today();
        Date endDate=startDate.addMonths(15);
        Map<String,Object> contractmap = new Map<String,Object>();
        contractMap.put('ContractExist',true);
        contractMap.put('ContractStartDate',String.valueOf(startDate));
        contractMap.put('ContractEndDate',String.valueOf(endDate));
        inputMap.put('ContractDetails',contractmap);
        TeliaSE_Renegotiation obj=new TeliaSE_Renegotiation();

        obj.invokeMethod('nonMobileProductsCheck', inputMap, outMap, options);
        
    }
    
    testMethod public static void testMobile4()
    {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
       
        //Contract con=[select id,startDate,endDate from Contract limit 1];
        Date startDate=Date.today();
        Date endDate=startDate.addMonths(40);
        Map<String,Object> contractmap = new Map<String,Object>();
        contractMap.put('ContractExist',true);
        contractMap.put('ContractStartDate',String.valueOf(startDate));
        contractMap.put('ContractEndDate',String.valueOf(endDate));
        inputMap.put('ContractDetails',contractmap);
        TeliaSE_Renegotiation obj=new TeliaSE_Renegotiation();

        obj.invokeMethod('nonMobileProductsCheck', inputMap, outMap, options);
        
    }
}