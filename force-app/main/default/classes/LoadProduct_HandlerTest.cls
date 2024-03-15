@isTest
public class LoadProduct_HandlerTest {
    
    @testSetup
    static void initTestData(){
        // creating test products ----------------
        vlocity_cmt__Catalog__c catalog = new vlocity_cmt__Catalog__c();
        catalog.vlocity_cmt__CatalogCode__c = 'MOBILEDEVICE';
        catalog.Name = 'MOBILEDEVICE';
        Insert catalog;
        
         vlocity_cmt__Catalog__c catalog1 = new vlocity_cmt__Catalog__c();
        catalog1.vlocity_cmt__CatalogCode__c = 'MOBILEDEVICE_NEW';
        catalog1.Name = 'MOBILEDEVICE_NEW';
        Insert catalog1;
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c();
        pl1.Name ='Online Pricelist'; 
        pl1.vlocity_cmt__IsActive__c = true; 
        pl1.vlocity_cmt__Code__c = 'ONL_PRICELIST';
        insert pl1;
        List<sObject> types=new List<sObject>();
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
        vlocity_cmt__ObjectClass__c FiberType = new vlocity_cmt__ObjectClass__c(Name = 'Bundle', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        
        types.add(FiberType);
        vlocity_cmt__ObjectClass__c FiberType2 = new vlocity_cmt__ObjectClass__c(Name = 'Mobile Handset Product Specification', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        
        types.add(FiberType2);
        vlocity_cmt__ObjectClass__c FiberType3 = new vlocity_cmt__ObjectClass__c(Name = 'Offer', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        types.add(FiberType3);
        insert types;



        List<vlocity_cmt__PricingVariable__c> vars=new List<vlocity_cmt__PricingVariable__c>();
        vlocity_cmt__PricingVariable__c oneTimeStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
                vars.add(oneTimeStdPriceVar);
        vlocity_cmt__PricingVariable__c oneTimeStdPriceVar2 = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC_N1',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
                vars.add(oneTimeStdPriceVar2);
        vlocity_cmt__PricingVariable__c oneTimeStdPriceVar3 = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC_N2',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
                vars.add(oneTimeStdPriceVar3);

        vlocity_cmt__PricingVariable__c mrcPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='Recurring', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
                vars.add(mrcPriceVar);

        insert vars;
        List<SObject> sObjList = new List<sObject>();
        
        Product2 TestProd1 = new Product2(); 
        TestProd1.Name='testProduct1'; 
        TestProd1.ProductCode = '9419981';
//        TestProd1.SAPID__c='94981';
        TestProd1.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Offer' LIMIT 1]?.Id;
        sObjList.add(TestProd1);
        
        Product2 TestProd2 = new Product2(); 
        TestProd2.Name='testProduct2'; 
        TestProd2.ProductCode = '9419982';
       // TestProd2.SAPID__c='94982';
        TestProd2.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Offer' LIMIT 1]?.Id;
        sObjList.add(TestProd2);
        
        Product2 TestProd3 = new Product2(); 
        TestProd3.Name='testProduct3'; 
        TestProd3.ProductCode = '9419983';
        //TestProd3.SAPID__c='94983';
        TestProd3.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Offer' LIMIT 1]?.Id;
        sObjList.add(TestProd3);
        
        Product2 TestProd4 = new Product2(); 
        TestProd4.Name='testProduct4'; 
        TestProd4.ProductCode = '9419984';
        //TestProd4.SAPID__c='94984';
        TestProd4.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Offer' LIMIT 1]?.Id;
        sObjList.add(TestProd4);    
        
        Product2 TestProd5 = new Product2(); 
        TestProd5.Name='testProduct5'; 
        TestProd5.ProductCode = '9419985';
        //TestProd5.SAPID__c='94985';
        TestProd5.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Offer' LIMIT 1]?.Id;
        sObjList.add(TestProd5);
        
        Product2 TestProd6 = new Product2(); 
        TestProd6.Name='testProduct6'; 
        TestProd6.ProductCode = '9419986';
        //TestProd6.SAPID__c='94986';
        TestProd6.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Offer' LIMIT 1]?.Id;
        sObjList.add(TestProd6);   
        
        Product2 TestProd7 = new Product2(); 
        TestProd7.Name='HW_MOBILEDEVICES1'; 
        TestProd7.ProductCode = 'HW_MOBILEDEVICES1';
        //TestProd7.SAPID__c='94987';
        TestProd7.TeliaSE_ItemsCount__c=17;
        TestProd7.vlocity_cmt__JSONAttribute__c='{}';
        TestProd7.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Offer' LIMIT 1]?.Id;
        sObjList.add(TestProd7);
        
        insert sObjList;
        
        list<Load_Product__c> prodlist = new list<Load_Product__c>();
        
        Load_Product__c loadproduct1 = new Load_Product__c();
        loadproduct1.Active__c = true;
        loadproduct1.C2BC_Category__c='goods';
        loadproduct1.C2BC_Subcategory__c='mobiledevice';
        loadproduct1.HWItemCategory__c = 'Mobiltelefoner';
        loadproduct1.Name__c = 'test';
        loadproduct1.PhimId__c = '12341';
        //loadproduct.ProductCode__c = '9419981';
        loadproduct1.ProductNameEng__c = 'testProduct1';
        loadproduct1.ProductNameSwe__c = 'testProduct1';
        loadproduct1.SalesStart__c = '27-10-2027';
        loadproduct1.SAPID__c = '94981';
        loadproduct1.Status__c = 'Aktuell';
        loadproduct1.Type__c = 'Bundle';
        loadproduct1.LinesCount__c= 6 ;
        prodlist.add(loadproduct1);
        
        Load_Product__c loadproduct2 = new Load_Product__c();
        loadproduct2.Active__c = true;
        loadproduct2.C2BC_Category__c='goods';
        loadproduct2.C2BC_Subcategory__c='mobiledevice';
        loadproduct2.HWItemCategory__c = 'Mobiltelefoner';
        loadproduct2.Name__c = 'test';
        loadproduct2.PhimId__c = '12342';
        //loadproduct.ProductCode__c = '9419982';
        loadproduct2.ProductNameEng__c = 'testProduct2';
        loadproduct2.ProductNameSwe__c = 'testProduct2';
        loadproduct2.SalesStart__c = '27-10-2027';
        loadproduct2.SAPID__c = '94982';
        loadproduct2.Status__c = 'Aktuell';
        loadproduct2.Type__c = 'Bundle';
        loadproduct2.LinesCount__c= 4 ;
        prodlist.add(loadproduct2);    
        
        Load_Product__c loadproduct3 = new Load_Product__c();
        loadproduct3.Active__c = true;
        loadproduct3.C2BC_Category__c='goods';
        loadproduct3.C2BC_Subcategory__c='mobiledevice';
        loadproduct3.HWItemCategory__c = 'Mobiltelefoner';
        loadproduct3.Name__c = 'test';
        loadproduct3.PhimId__c = '12343';    
        //loadproduct.ProductCode__c = '9419982';
        loadproduct3.ProductNameEng__c = 'testProduct3';
        loadproduct3.ProductNameSwe__c = 'testProduct3';
        loadproduct3.SalesStart__c = '27-10-2027';
        loadproduct3.SAPID__c = '94983';
        loadproduct3.Status__c = 'Aktuell';
        loadproduct3.Type__c = 'Bundle';
        loadproduct3.LinesCount__c= 7 ;
        prodlist.add(loadproduct3);        
        
        Load_Product__c loadproduct4 = new Load_Product__c();
        loadproduct4.Active__c = true;
        loadproduct4.C2BC_Category__c='goods';
        loadproduct4.C2BC_Subcategory__c='mobiledevice';
        loadproduct4.HWItemCategory__c = 'Mobiltelefoner';
        loadproduct4.Name__c = 'test';
        loadproduct4.PhimId__c = '12344';
        //loadproduct.ProductCode__c = '9419982';
        loadproduct4.ProductNameEng__c = 'testProduct4';
        loadproduct4.ProductNameSwe__c = 'testProduct4';
        loadproduct4.SalesStart__c = '27-10-2027';
        loadproduct4.SAPID__c = '94983';
        loadproduct4.Status__c = 'Aktuell';
        loadproduct4.Type__c = 'Bundle';
        loadproduct4.LinesCount__c= 2 ;
        prodlist.add(loadproduct4);        
        
        Load_Product__c loadproduct5 = new Load_Product__c();
        loadproduct5.Active__c = true;
        loadproduct5.C2BC_Category__c='goods';
        loadproduct5.C2BC_Subcategory__c='mobiledevice';
        loadproduct5.HWItemCategory__c = 'Mobiltelefoner';
        loadproduct5.Name__c = 'test';
        loadproduct5.PhimId__c = '12345';
        //loadproduct.ProductCode__c = '9419982';
        loadproduct5.ProductNameEng__c = 'testProduct5';
        loadproduct5.ProductNameSwe__c = 'testProduct5';
        loadproduct5.SalesStart__c = '27-10-2027';
        loadproduct5.SAPID__c = '94985';
        loadproduct5.Status__c = 'Aktuell';
        loadproduct5.Type__c = 'Bundle';
        loadproduct5.LinesCount__c= 9 ;    
        prodlist.add(loadproduct5);
        
        Load_Product__c loadproduct6 = new Load_Product__c();
        loadproduct6.Active__c = true;
        loadproduct6.C2BC_Category__c='goods';
        loadproduct6.C2BC_Subcategory__c='mobiledevice';
        loadproduct6.HWItemCategory__c = 'Mobiltelefoner';
        loadproduct6.Name__c = 'test';
        loadproduct6.PhimId__c = '12346';
        //loadproduct.ProductCode__c = '9419982';
        loadproduct6.ProductNameEng__c = 'testProduct6';
        loadproduct6.ProductNameSwe__c = 'testProduct6';
        loadproduct6.SalesStart__c = '27-10-2027';
        loadproduct6.SAPID__c = '94986';
        loadproduct6.Status__c = 'Aktuell';
        loadproduct6.Type__c = 'Bundle';
        loadproduct6.LinesCount__c= 3 ;    
        prodlist.add(loadproduct6);
        


        Load_Product__c loadproduct8 = new Load_Product__c();
        loadproduct8.Active__c = true;
        loadproduct8.C2BC_Category__c='goods';
        loadproduct8.C2BC_Subcategory__c='mobiledevice';
        loadproduct8.HWItemCategory__c = 'Mobiltelefoner';
        loadproduct8.Name__c = 'test';
        loadproduct8.PhimId__c = '12312321';
        loadproduct8.ProductNameEng__c = 'testPro99';
        loadproduct8.ProductNameSwe__c = 'testProd99';
        loadproduct8.SalesStart__c = '27-10-2027';
        loadproduct8.SAPID__c = '94986';
        loadproduct8.Status__c = 'Aktuell';
        loadproduct8.Type__c = 'Bundle';
        loadproduct8.Success__c=false;
        loadproduct8.LinesCount__c= 3 ; 
        loadproduct8.action__c='import';  
        loadproduct8.recomendedAccessories__c = '{"compatible": [1231,123], "recommended": [123123,123123]}';
        prodlist.add(loadproduct8);
        

        Load_Product__c loadproduct7 = new Load_Product__c();
        loadproduct7.Active__c = true;
        loadproduct7.Brand__c = 'Apple';
        loadproduct7.memory__c='64GB';
        loadproduct7.C2BC_Category__c='goods';
        loadproduct7.C2BC_Subcategory__c='mobiledevice';
        loadproduct7.HWItemCategory__c = 'Mobiltelefoner';
        loadproduct7.Name__c = 'test';
        loadproduct7.PhimId__c = '12348';
        loadproduct7.Success__c=false;
        loadproduct7.parentPHimId__c = '12312321';
        loadproduct7.ProductNameEng__c = 'product7';
        loadproduct7.ProductNameSwe__c = 'product7';
        loadproduct7.SalesStart__c = '2027-01-01';
        loadproduct7.SAPID__c = '9498123';
        loadproduct7.Status__c = 'Aktuell';
        loadproduct7.Type__c = 'Product';
        loadproduct7.action__c='import';
        loadproduct7.nrc__c=10;
        loadproduct7.mrc__c=10;
        loadproduct7.NRCN1__c=10;
        loadproduct7.NRCN2__c=10;
        loadproduct7.PhimProductGroup__c='Mobiltelefoner';
        prodlist.add(loadproduct7);
        



        
        insert prodlist;
        
        List<vlocity_cmt__ProductChildItem__c> pCitem = new list<vlocity_cmt__ProductChildItem__c>();
        vlocity_cmt__ProductChildItem__c ProdChildItem1 = new vlocity_cmt__ProductChildItem__c();
        ProdChildItem1.Name = 'ProdChildItem11';
        ProdChildItem1.vlocity_cmt__ChildProductId__c = [Select id from Product2 Where ProductCode = '9419981' LIMIT 1]?.Id;
        ProdChildItem1.vlocity_cmt__ParentProductId__c = [Select id from Product2 Where ProductCode = 'HW_MOBILEDEVICES1' LIMIT 1]?.Id;
        ProdChildItem1.vlocity_cmt__ChildLineNumber__c = '1';
        pCitem.add(ProdChildItem1);
        
        vlocity_cmt__ProductChildItem__c ProdChildItem2 = new vlocity_cmt__ProductChildItem__c();
        ProdChildItem2.Name = 'ProdChildItem12';
        ProdChildItem2.vlocity_cmt__ChildProductId__c = [Select id from Product2 Where ProductCode = '9419982' LIMIT 1]?.Id;
        ProdChildItem2.vlocity_cmt__ParentProductId__c = [Select id from Product2 Where ProductCode = '9419981' LIMIT 1]?.Id;
        ProdChildItem2.vlocity_cmt__ChildLineNumber__c = '2';
        pCitem.add(ProdChildItem2);
        
        vlocity_cmt__ProductChildItem__c ProdChildItem3 = new vlocity_cmt__ProductChildItem__c();
        ProdChildItem3.Name = 'ProdChildItem13';
        ProdChildItem3.vlocity_cmt__ChildProductId__c = [Select id from Product2 Where ProductCode = '9419983' LIMIT 1]?.Id;
        ProdChildItem3.vlocity_cmt__ParentProductId__c = [Select id from Product2 Where ProductCode = 'HW_MOBILEDEVICES1' LIMIT 1]?.Id;
        ProdChildItem3.vlocity_cmt__ChildLineNumber__c = '3';
        pCitem.add(ProdChildItem3);
        
        insert pCitem;


        
       
        vlocity_cmt__Catalog__c cat=new vlocity_cmt__Catalog__c(vlocity_cmt__CatalogCode__c='MOBILEDEVICE',vlocity_cmt__DefaultPriceListId__c=pl1.id);
        insert cat;
        
        vlocity_cmt__ObjectClass__c objectType = new vlocity_cmt__ObjectClass__c(Name = 'Offer', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        insert objectType;        
        List<Product2> prods=new List<Product2>();
        //Product2 prod1 = new Product2 (Name='HW_MOBILEDEVICES1', ProductCode = 'HW_MOBILEDEVICES1',TeliaSE_ItemsCount__c=17,vlocity_cmt__ObjectTypeId__c=objectType.id);
        //prods.add(prod1);
        Product2 prod2 = new Product2 (Name='HW_MOBILEDEVICES2',vlocity_cmt__JSONAttribute__c='{}', ProductCode = 'HW_MOBILEDEVICES2',TeliaSE_ItemsCount__c=16,vlocity_cmt__ObjectTypeId__c=objectType.id);
        prods.add(prod2);
        Product2 prod3 = new Product2 (Name='HW_MOBILEDEVICES3', ProductCode = 'HW_MOBILEDEVICES3',TeliaSE_ItemsCount__c=18,vlocity_cmt__ObjectTypeId__c=objectType.id);
        prods.add(prod3);
        insert prods;
        

    }
    
    
    @isTest
    static void upsertBundleTest() {
        list<Load_Product__c> newProds = [SELECT Id,LinesCount__c,Active__c,PhimId__c,C2BC_Category__c,C2BC_Subcategory__c,HWItemCategory__c,Name__c,ProductNameEng__c,ProductNameSwe__c,SalesStart__c,SAPID__c,Status__c,Type__c from Load_Product__c LIMIT 100];  
        try
        { 
            Test.startTest();
            LoadProduct_Handler.upsertBundle(newProds);
            Test.stopTest();
        }catch(exception ex){}
        
        
    }
    @isTest
    static void removeunusedbundleTest() {
        try
        {
            Test.startTest();
            LoadProduct_Handler.removeunusedBundles();
            list<vlocity_cmt__ProductChildItem__c> deleteBundleExample = [select id from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ProductChildItem__c.name='ProdChildItem13'];
            system.assertEquals(0,deleteBundleExample.size());
            Test.stopTest();
        }
        catch(exception ex){} 
    }


    @isTest
    static void processBundlesBatchTest()
    {
        try
        {
                Test.startTest();
                Database.executeBatch(new LoadProductBatch('Bundle',new Set<String>()),1);     
                Test.stopTest();  
        }catch(Exception e)
        {
            System.debug(e.getLineNumber()+e.getMessage()+e.getStackTraceString());
        }
    }

    @isTest
    static void processBundlesBatch_removeProductsTest()
    {
        try
        {
                Load_Product__c prod=[select id from Load_Product__c where phimId__c='12348'];
                prod.status__c ='Utgått';
                update prod;

                Test.startTest();
                Database.executeBatch(new LoadProductBatch('Bundle',new Set<String>()),1);     
                Test.stopTest();  
        }catch(Exception e)
        {
            System.debug(e.getLineNumber()+e.getMessage()+e.getStackTraceString());
        }
    }

    @isTest
    static void dynamicOffercodegeneratorTest()
    {
    try{
        String offercode=LoadProduct_Handler.getOfferCode('1234',6,'mobiledevice');
        System.assertEquals('HW_MOBILEDEVICES4', offercode);
        String productcode=[select id,vlocity_cmt__Product2Id__r.productcode from vlocity_cmt__CatalogProductRelationship__c limit 1]?.vlocity_cmt__Product2Id__r.productcode;
        System.assertEquals('HW_MOBILEDEVICES4', productcode);    
        }catch(Exception e){}
    }

    @isTest
    static void processNumberOfChildItemsAtOfferLevelTest()
    {
        Product2 prod=[select id from Product2 where productcode='HW_MOBILEDEVICES3'];
        prod.TeliaSE_ItemsCount__c=0;
        update prod;
        
        LoadProduct_Handler.processNumberOfChildItemsAtOfferLevel();
        
        String productcode1=[select id,vlocity_cmt__Product2Id__r.productcode from vlocity_cmt__CatalogProductRelationship__c where vlocity_cmt__Product2Id__r.productcode='HW_MOBILEDEVICES3' limit 1]?.vlocity_cmt__Product2Id__r.productcode;
        System.assertEquals(null, productcode1);
    }

    @isTest
    static void checkAttributesTest(){
        delete [select id from Product2 where productcode !='HW_MOBILEDEVICES1'  ];

        Test.startTest();
        TeliaSE_CheckAttributes.checkAttributes();
        Test.stopTest();
    }
    @isTest
    static void toggleCheck()
    {
        String offercode=LoadProduct_Handler.getOfferCode('1234',6,'mobiledevice');

        String productcode=[select id,vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c from vlocity_cmt__CatalogProductRelationship__c limit 1]?.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c;


    }
}