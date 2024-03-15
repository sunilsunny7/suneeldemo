@isTest
public class MCONLINE_GetMobileDevPriceMatrix_V3_Test {
    @testSetup
    static void initTestData() { 
        User salesManager;
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        
        Account acc1 = new Account();
        acc1.RecordTypeId = '012240000008l9YAAQ';
        acc1.Name='TestAccount1';
        acc1.TSCID__c = 'TSCID98081';
        Insert acc1;
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.recordtypeId = rt1.id;
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        contr.Status='Active';
        System.runAs(salesManager){update contr;}
        Contract contr1=new Contract();
        contr1.Name='Test1';
        contr1.AccountId=acc1.id;
        contr1.Status='Draft';
        contr1.recordtypeId = rt1.id;
        contr1.Solution_Area__c='Vxl';
        contr1.StartDate=Date.today();
        contr1.ContractTerm=24;
        insert contr1;
        contr1.Status='Active';
        System.runAs(salesManager){update contr1;}
        List<Map<String,String>> attrList1 = new List<Map<String,String>>();
        Map<String,String> attr1 = new Map<String,String>();
        List<Map<String,String>> attrList2 = new List<Map<String,String>>();
        Map<String,String> attr2 = new Map<String,String>();
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        Product2 prod2 = new Product2();
        Product2 prod3 = new Product2();
        Product2 prod4 = new Product2();
        Product2 prod5 = new Product2();
        Product2 prod6 = new Product2();
        
        prod1.ProductCode = 'HW_IPHONE_12_64_WHITE';
        prod1.Name = 'Apple iPhone 12 128GB Vit';
        prod1.C2BC_Category__c = 'Goods';
        prod1.TeliaSE_MatrixPriceFlag__c = true;
        prod1.C2BC_Subcategory__c = 'mobiledevice';
        attr1.put('attributeuniquecode__c','ATT_HW_SAP_ID');
        attr1.put('value__c','9095103');
        attrList1.add(attr1);
        Map<String,List<Map<String,String>>> attrMap1 = new Map<String,List<Map<String,String>>>();
        attrMap1.put('ATT_CODE_TELIAMOBAGGR',attrList1);
        prod1.vlocity_cmt__JSONAttribute__c = JSON.serialize(attrMap1);
        prodList.add(prod1);
        
        prod2.ProductCode = 'HW_IPHONE_12_256_BLUE';
        prod2.Name = 'Apple iPhone 12 128GB Blå';
        prod2.C2BC_Category__c = 'Goods';
        prod2.C2BC_Subcategory__c = 'mobiledevice';
        prod1.TeliaSE_MatrixPriceFlag__c = true;
        attr2.put('attributeuniquecode__c','ATT_HW_SAP_ID');
        attr2.put('value__c','9095104');
        Map<String,List<Map<String,String>>> attrMap2 = new Map<String,List<Map<String,String>>>();
        attrList2.add(attr2);
        attrMap2.put('ATT_CODE_TELIAMOBAGGR',attrList2);
        prod2.vlocity_cmt__JSONAttribute__c = JSON.serialize(attrMap2);
        prodList.add(prod2);
        
        prod3.ProductCode = 'HW_IPHONE_12';
        prod3.Name = 'Apple iPhone 12';
        prod3.C2BC_Category__c = 'HW bundle';
        prod3.C2BC_Subcategory__c = 'mobiledevice';
        prodList.add(prod3);
        
        prod4.ProductCode = 'MOB_SURF_1_V2';
        prod4.Name = 'Jobbsurf 1 GB';
        prod4.C2BC_Category__c = 'mobilevoicesubscription';
        prod4.C2BC_Subcategory__c = 'voice';
        prodList.add(prod4);
        
        prod5.ProductCode = 'HW_MOBILEDEVICES';
        prod5.Name = 'MOBILEDEVICES';
        prod5.C2BC_Category__c = 'offerbundle';
        prodList.add(prod5);
        
        prod6.ProductCode = 'testProd';
        prod6.Name = 'testProd';
        prodList.add(prod6);
        
        insert prodList;
        
        List<vlocity_cmt__ProductChildItem__c> childProdList = new List<vlocity_cmt__ProductChildItem__c>();
        vlocity_cmt__ProductChildItem__c child1 = new vlocity_cmt__ProductChildItem__c();
        child1.vlocity_cmt__ChildProductId__c = prodList.get(0).id;
        child1.vlocity_cmt__ParentProductId__c = prodList.get(2).id;
        child1.vlocity_cmt__ChildLineNumber__c ='1';
        childProdList.add(child1);
        vlocity_cmt__ProductChildItem__c child2 = new vlocity_cmt__ProductChildItem__c();
        child2.vlocity_cmt__ChildProductId__c = prodList.get(1).id;
        child2.vlocity_cmt__ParentProductId__c = prodList.get(2).id;
        child2.vlocity_cmt__ChildLineNumber__c ='2';
        childProdList.add(child2);
        vlocity_cmt__ProductChildItem__c child3 = new vlocity_cmt__ProductChildItem__c();
        child3.vlocity_cmt__ChildProductId__c = prodList.get(2).id;
        child3.vlocity_cmt__ParentProductId__c = prodList.get(4).id;
        child3.vlocity_cmt__ChildLineNumber__c ='3';
        childProdList.add(child3);
        insert childProdList;
        
        
        vlocity_cmt__PriceListEntry__c price1 = new vlocity_cmt__PriceListEntry__c();
        vlocity_cmt__PricingVariable__c prVar = new vlocity_cmt__PricingVariable__c();
        prVar.Name = 'One Time Std Price';
        prVar.vlocity_cmt__ChargeType__c = 'One-time';
        prVar.vlocity_cmt__Code__c = 'OT_STD_PRC';
        prVar.vlocity_cmt__ValueType__c = 'Pricing Element';
        insert prVar;
        vlocity_cmt__PriceList__c prList = new vlocity_cmt__PriceList__c();
        prList.Name = 'Online Pricelist';
        prList.vlocity_cmt__Code__c = 'ONL_PRICELIST';
        prList.vlocity_cmt__IsActive__c = true;
        insert prList;
        
        
        vlocity_cmt__PricingElement__c priceElement1 = new vlocity_cmt__PricingElement__c();
        priceElement1.vlocity_cmt__Amount__c = 8550.40000;
        priceElement1.vlocity_cmt__PricingVariableId__c = prVar.id;
        priceElement1.vlocity_cmt__PriceListId__c = prList.id;
        insert priceElement1;
        
        price1.vlocity_cmt__PricingElementId__c = priceElement1.id;
        price1.vlocity_cmt__ProductId__c = prod1.id;
        price1.vlocity_cmt__PriceListId__c = prList.id;
        
        vlocity_cmt__PriceListEntry__c price2 = new vlocity_cmt__PriceListEntry__c();
        
        price2.vlocity_cmt__PricingElementId__c = priceElement1.id;
        price2.vlocity_cmt__ProductId__c = prod2.id;
        price2.vlocity_cmt__PriceListId__c = prList.id;

        insert price1;
        insert price2;
        vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
        cli.vlocity_cmt__ContractId__c = contr.id;
        cli.vlocity_cmt__Product2Id__c = prod4.id;
        cli.Name = prod4.Name;
        cli.TeliaSE_MC_Customer_Requested_Price__c = 99;
        insert cli;
        
        vlocity_cmt__ContractLineItem__c cli1= new vlocity_cmt__ContractLineItem__c();
        cli1.vlocity_cmt__ContractId__c = contr1.id;
        cli1.vlocity_cmt__Product2Id__c = prod6.id;
        cli1.Name = prod6.Name;
        cli1.TeliaSE_MC_Customer_Requested_Price__c = 99;
        insert cli1;
        
        PricematrixRanges__c priceRange = new PricematrixRanges__c();
        priceRange.Name = '75-99';
        priceRange.Low__c = 75;
        priceRange.High__c = 99;
        insert priceRange;
        List<HW_Cal_Procedure__c> calList = new List<HW_Cal_Procedure__c>();
    HW_Cal_Procedure__c cal1 = new HW_Cal_Procedure__c(configurationName__c = 'Hardware_24M_RangeAttributePricingProcedure',CommitmentDuration__c='24',Name='Hardware_24M');
        HW_Cal_Procedure__c cal2 = new HW_Cal_Procedure__c(configurationName__c = 'Hardware_36M_RangeAttributePricingProcedure',CommitmentDuration__c='36',Name='Hardware_36M');
        calList.add(cal1);
        calList.add(cal2);
        insert calList;
    }
    
    @isTest static void hardWarePrice_success(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Contract con = [select id,ContractNumber from Contract where Name ='Test'];
        String conNumber = con.ContractNumber;
        
        List<vlocity_cmt__ProductChildItem__c> childProdList1 = [SELECT id,vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.Name FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode ='HW_IPHONE_12'];
        system.debug('children'+childProdList1.size());
        
        inputMap.put('Agreementid',conNumber);
        inputMap.put('CommitmentDuration','24');
        inputMap.put('offerBundleCode','HW_IPHONE_12');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
    }
    @isTest static void hardWarePrice_ZeroCommitment(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Contract con = [select id,ContractNumber from Contract where Name ='Test'];
        String conNumber = con.ContractNumber;
        
        List<vlocity_cmt__ProductChildItem__c> childProdList1 = [SELECT id,vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.Name FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode ='HW_IPHONE_12'];
        system.debug('children'+childProdList1.size());
        
        inputMap.put('Agreementid',conNumber);
        inputMap.put('CommitmentDuration','0');
        inputMap.put('offerBundleCode','HW_IPHONE_12');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
        System.debug('outMap==>'+outMap);
        System.assertEquals(true,outMap.containsKey('outputRespose'));
        
    }
    @isTest static void hardWarePriceTest_invalidCommitmentPeriod(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Contract con = [select id,ContractNumber from Contract where Name ='Test'];
        String conNumber = con.ContractNumber;
        inputMap.put('Agreementid',conNumber);
        inputMap.put('CommitmentDuration','20');
        inputMap.put('offerBundleCode','HW_IPHONE_12');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
        System.assertEquals(true,outMap.containsKey('ErrorResponse'));
    }
    @isTest static void hardWarePriceTest_blankCommitmentPeriod(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Contract con = [select id,ContractNumber from Contract where Name ='Test'];
        String conNumber = con.ContractNumber;
        inputMap.put('Agreementid',conNumber);
        inputMap.put('CommitmentDuration','');
        inputMap.put('offerBundleCode','HW_IPHONE_12');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
        System.assertEquals(true,outMap.containsKey('ErrorResponse'));
    }
  @isTest static void hardWarePriceTest_BlankCatalog(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Contract con = [select id,ContractNumber from Contract where Name ='Test'];
        String conNumber = con.ContractNumber;
        inputMap.put('Agreementid',conNumber);
        inputMap.put('CommitmentDuration','24');
        inputMap.put('offerBundleCode','HW_IPHONE_12');
        inputMap.put('Catalog','');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
        System.assertEquals(true,outMap.containsKey('ErrorResponse'));
    }
    @isTest static void hardWarePriceTest_BlankOfferCode(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Contract con = [select id,ContractNumber from Contract where Name ='Test'];
        String conNumber = con.ContractNumber;
        inputMap.put('Agreementid',conNumber);
        inputMap.put('CommitmentDuration','24');
        inputMap.put('offerBundleCode','HW_IPHONE_12');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
        System.assertEquals(true,outMap.containsKey('ErrorResponse'));
    }
    @isTest static void hardWarePriceTest_invalidAgreement(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('Agreementid','123');
        inputMap.put('CommitmentDuration','24');
        inputMap.put('offerBundleCode','HW_IPHONE_12');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
        System.assertEquals(true,outMap.containsKey('ErrorResponse'));
    }
    @isTest static void hardWarePriceTest_blankAgreement(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('Agreementid','');
        inputMap.put('CommitmentDuration','24');
        inputMap.put('offerBundleCode','HW_IPHONE_12');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
       System.assertEquals(true,outMap.containsKey('ErrorResponse'));
    }
    @isTest static void hardWarePriceTest_invalidOfferBundleCode(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('Agreementid','123');
        inputMap.put('CommitmentDuration','24');
        inputMap.put('offerBundleCode','123');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
       System.assertEquals(true,outMap.containsKey('ErrorResponse'));
    }
  @isTest static void hardWarePriceTest_blankOfferBundleCode(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('Agreementid','123');
        inputMap.put('CommitmentDuration','24');
        inputMap.put('offerBundleCode','');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
         System.assertEquals(true,outMap.containsKey('ErrorResponse'));
    }
  @isTest static void wrapperTest(){
      MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
    }
  @isTest static void hardWarePrice_NoItemToProcess(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Contract con = [select id,ContractNumber from Contract where Name ='Test1'];
        String conNumber = con.ContractNumber;
        
        List<vlocity_cmt__ProductChildItem__c> childProdList1 = [SELECT id,vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.Name FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode ='HW_IPHONE_12'];
        system.debug('conNumber'+conNumber);
        
        inputMap.put('Agreementid',conNumber);
        inputMap.put('CommitmentDuration','24');
        inputMap.put('offerBundleCode','HW_IPHONE_12');
        inputMap.put('Catalog','MOBILEDEVICE');
        inputMap.put('offerCode','HW_MOBILEDEVICES');
        MCONLINE_GetMobileDevPriceMatrix_V3 hw = new MCONLINE_GetMobileDevPriceMatrix_V3();
        hw.invokeMethod('getHardwarePrice',inputMap,outMap,options);
   }

}