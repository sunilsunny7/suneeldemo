@isTest
public class MCOnline_copyOrder_V4_Test {
    @testSetup
    static void initTestData() { 
        
        //create account
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID_1234';
        Insert acc;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        contr.Status='Active';
        update contr;
        
        
        //create product
        Product2 prod1 = new Product2();
        Product2 prod2 = new Product2();
        Product2 prod3 = new Product2();
        Product2 prod4 = new Product2();
        Product2 hwprod5 = new Product2();
        Product2 addonprod6 = new Product2();
        Product2 addonprod7 = new Product2();
        Product2 hwprod8 = new Product2();
        List<Product2> prodList = new List<Product2>();
        prod1.ProductCode = 'agrProd1';
        prod1.Name = 'agrProd1';
        prod1.C2BC_Category__c = 'mobilevoicesubscription';
        prod1.C2BC_Subcategory__c = 'voice';
        prod1.IsActive =true;
        prod1.Family = 'Online Order';
        prodList.add(prod1);
        
        prod2.ProductCode = 'agrProd2';
        prod2.Name = 'agrProd2';
        prod2.C2BC_Category__c = 'mobilevoicesubscription';
        prod2.C2BC_Subcategory__c = 'voice';
        prod2.IsActive =true;
        prod2.Family = 'Online Order';
        prodList.add(prod2);
        
        prod3.ProductCode = 'offer1';
        prod3.Name = 'offer1';
        prod3.C2BC_Category__c = 'mobilevoicesubscription';
        prod3.C2BC_Subcategory__c = 'voice';
        prod3.IsActive =true;
        prod3.Family = 'Online Order';
        prodList.add(prod3);
        
        prod4.ProductCode = 'offer2';
        prod4.Name = 'offer2';
        prod4.C2BC_Category__c = 'mobilevoicesubscription';
        prod4.C2BC_Subcategory__c = 'voice';
        prod4.IsActive =true;
        prod4.Family = 'Online Order';
        prodList.add(prod4);
    
        hwprod5.ProductCode = 'HWOffer';
        hwprod5.Name = 'HWOffer';
        hwprod5.C2BC_Category__c = 'goods';
        hwprod5.C2BC_Subcategory__c = 'mobiledevice';
        hwprod5.IsActive =true;
        hwprod5.Family = 'Online Order';
        prodList.add(hwprod5);
    
        addonprod6.ProductCode = 'AddonOffer';
        addonprod6.Name = 'AddonOffer';
        addonprod6.C2BC_Category__c = 'mobilevoicesubscription';
        addonprod6.C2BC_Subcategory__c = null;
        addonprod6.IsActive =true;
        addonprod6.Family = 'Online Order';
        prodList.add(addonprod6);
        
        addonprod7.ProductCode = 'MOB_BB_FAST_IP';
        addonprod7.Name = 'Fast IP Address';
        addonprod7.C2BC_Category__c = 'mobilevoicesubscription';
        addonprod7.C2BC_Subcategory__c = null;
        addonprod7.IsActive =true;
        addonprod7.Family = 'Online Order';
        prodList.add(addonprod7);
        
        hwprod8.ProductCode='HWProduct';
        hwprod8.Name='HWProduct';
        hwprod8.C2BC_Category__c='goods';
        hwprod8.C2BC_Subcategory__c='mobiledevice';
        hwprod8.IsActive=true;
        hwprod8.Family=null;
        prodList.add(hwprod8);
        
        insert prodList;
        
        List<vlocity_cmt__ProductChildItem__c> childProdList = new List<vlocity_cmt__ProductChildItem__c>();
        vlocity_cmt__ProductChildItem__c child1 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child2 = new vlocity_cmt__ProductChildItem__c();
        vlocity_cmt__ProductChildItem__c child3 = new vlocity_cmt__ProductChildItem__c();
        child1.vlocity_cmt__ChildProductId__c = prodList.get(0).id;
        child1.vlocity_cmt__ParentProductId__c = prodList.get(2).id;
        child1.vlocity_cmt__ChildLineNumber__c ='1';
        childProdList.add(child1);
        
        child2.vlocity_cmt__ChildProductId__c = prodList.get(6).id;
        child2.vlocity_cmt__ParentProductId__c = prodList.get(5).id;
        child2.vlocity_cmt__ChildLineNumber__c ='1';
        childProdList.add(child2);
        
        child3.vlocity_cmt__ChildProductId__c = prodList.get(7).id;
        child3.vlocity_cmt__ParentProductId__c = prodList.get(4).id;
        child3.vlocity_cmt__ChildLineNumber__c='1';
        
        Insert childProdList;
        
        vlocity_cmt__Catalog__c cat = new vlocity_cmt__Catalog__c();
        cat.Name = 'SUBSCRIPTIONS';
        insert cat;
        
        vlocity_cmt__Catalog__c catl= new vlocity_cmt__Catalog__c();
        catl.Name = 'MOBILEDEVICE';
        insert catl;
        
        List<vlocity_cmt__CatalogProductRelationship__c> catalogProductList = new List<vlocity_cmt__CatalogProductRelationship__c>();
        vlocity_cmt__CatalogProductRelationship__c catalogProduct1 = new vlocity_cmt__CatalogProductRelationship__c();
        catalogProduct1.Name = 'Offer1' ;
        catalogProduct1.vlocity_cmt__CatalogId__c = cat.id;
        catalogProduct1.vlocity_cmt__Product2Id__c = prodList.get(2).id;
        catalogProductList.add(catalogProduct1);
        
        vlocity_cmt__CatalogProductRelationship__c catalogProduct2 = new vlocity_cmt__CatalogProductRelationship__c();
        catalogProduct2.Name = 'Offer2' ;
        catalogProduct2.vlocity_cmt__CatalogId__c = cat.id;
        catalogProduct2.vlocity_cmt__Product2Id__c = prodList.get(3).id;
        catalogProductList.add(catalogProduct2);
        
   
        vlocity_cmt__CatalogProductRelationship__c catalogProduct3= new vlocity_cmt__CatalogProductRelationship__c();
        catalogProduct3.Name= 'HWOffer' ;
        catalogProduct3.vlocity_cmt__CatalogId__c = catl.id;
        catalogProduct3.vlocity_cmt__Product2Id__c=prodList.get(4).id;
        catalogProductList.add(catalogProduct3);
        
        vlocity_cmt__CatalogProductRelationship__c catalogProduct4=new vlocity_cmt__CatalogProductRelationship__c();
        catalogProduct4.Name = 'AddonOffer' ;
        catalogProduct4.vlocity_cmt__CatalogId__c = cat.id;
        catalogProduct4.vlocity_cmt__Product2Id__c = prodList.get(5).id;
        catalogProductList.add(catalogProduct4);
        
        insert catalogProductList;

        
        // add contract line items
        vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
        vlocity_cmt__ContractLineItem__c cli2 = new vlocity_cmt__ContractLineItem__c();
        List<vlocity_cmt__ContractLineItem__c>  cliList = new List<vlocity_cmt__ContractLineItem__c>();
        cli1.vlocity_cmt__ContractId__c = contr.id;
        cli1.vlocity_cmt__Product2Id__c = prod1.id;
        cli1.Name = prod1.Name;
        cli1.TeliaSE_MC_Customer_Requested_Price__c = 99;
        
        cli2.vlocity_cmt__ContractId__c = contr.id;
        cli2.vlocity_cmt__Product2Id__c = prod2.id;
        cli2.Name = prod2.Name;
        cli2.TeliaSE_MC_Customer_Requested_Price__c = 99;
        cliList.add(cli1);
        cliList.add(cli2);
        insert cliList;
        
        //create Order
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        insert order;
        
        //parent create basket
        MCOnline_ParentBasket__c pbasket = new MCOnline_ParentBasket__c();
        pbasket.TSCID__c = 'TSCID_1234';
        pbasket.CreatedDate = Date.today();
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = 'testUser1';
        pbasket.Account__c = acc.Id;        
        pbasket.BasketStatus__c =  'Success';
        //pbasket.Order__r.Id=order.Id;
        insert pbasket;
        
        
        //create child basket
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Admin__c = 'testUser1';
        basket.CreatedDate = Date.today();
        basket.MCOnline_Orders__c = order.Id;
        basket.MCOnline_Basket_Key__c = 'c949525b7f60a2d109c75305a525867c';
        basket.MCOnline_OfferCode__c = 'offer1';
        basket.TSCID__c = 'TSCID_1234';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"e-SIM_Method":"email","User_name":"check1","Commitment_period":"0","SIM_Format":"esim","MSISDN":"460987654321","ICC_number":"0904199810","Email":null,"External_reference":"ero","NumberReservationRequired":"Yes","subAgreementId":null},"price":[{"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"425.00","baseAmount":"579.00000","chargeAmount":"579.00000"}],"actionCode":"Delete","featureId":null,"lineNumber":"0001.0001.0006","name":"Jobbmobil 40 GB","englishName":null,"downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"96","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"agrProd1"},{"price":[{"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0.00000","baseAmount":"0.00000","chargeAmount":"0.00000"}],"actionCode":"Add","featureId":null,"lineNumber":"0001.0002.0001","name":"Mobilsvar","englishName":"Voicemail","downstream_CategoryData":"0","TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":"0","CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow_ReadOnly","TeliaSE_Product_Service_Code":"VMIS","AO":"Yes","productCode":"agrProd2"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        basket.Basket_Line_Relation_Id__c = 'Id1';
        basket.basket_Line_Relation_Count__c = 1;
        basket.MCOnline_Billing_Account__c = 'Test_BillingAccount';
        insert basket;
        
        MCOnline_Basket__c basket2 = new MCOnline_Basket__c();
        basket2.MCOnline_Admin__c = 'testUser1';
        basket2.CreatedDate = Date.today();
        basket2.MCOnline_Order__c = order.Id;
        basket2.MCOnline_Basket_Key__c = 'c949525b7f60a2d109c75305a525867c';
        basket2.MCOnline_OfferCode__c = 'offer2';
        basket2.TSCID__c = 'TSCID_1234';
        basket2.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket2.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"e-SIM_Method":"email","User_name":"check2","Commitment_period":"0","SIM_Format":"keep","MSISDN":"469876543210","ICC_number":"0904199811","Email":null,"External_reference":"ero","NumberReservationRequired":"Yes","subAgreementId":null},"price":[{"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"425.00","baseAmount":"579.00000","chargeAmount":"579.00000"}],"actionCode":"Add","featureId":null,"lineNumber":"0001.0001.0006","name":"Jobbmobil 40 GB","englishName":null,"downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"96","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"agrProd2"},{"price":[{"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0.00000","baseAmount":"0.00000","chargeAmount":"0.00000"}],"actionCode":"Add","featureId":null,"lineNumber":"0001.0002.0004","name":"Visa Missade Samtal","englishName":"Missed Call Alerts","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MCA","AO":"No","productCode":"MOB_MISSED_CALL_ALERTS"}]}';
        basket2.MCOnline_Contract__c = contr.Id;
        basket2.Account__c = acc.Id;
        basket2.MCOnline_ParentBasket__c = pbasket.Id;
        basket2.Basket_Line_Relation_Id__c = 'Id1';
        basket2.basket_Line_Relation_Count__c = 2;
        basket2.MCOnline_Billing_Account__c = 'Test_BillingAccount';
        insert basket2;
        
        MCOnline_Basket__c basket3 = new MCOnline_Basket__c();
        basket3.MCOnline_Admin__c = 'testUser1';
        basket3.CreatedDate = Date.today();
        basket3.MCOnline_Orders__c = order.Id;
        basket3.MCOnline_Basket_Key__c = 'c949525b7f60a2d109c75305a525867c';
        basket3.MCOnline_OfferCode__c = 'HWOffer';
        basket3.TSCID__c = 'TSCID_1234';
        basket3.MCOnline_Catalog__c = 'MOBILEDEVICE';
        basket3.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"HWSAPID":"9102935","HWItemCnetBrandColor":"Graphite","HWItemCategory_SV":"Mobiltelefoner","HWItemCategory":null,"HWProductBrand":"Apple","User_name":"test","HWUpfrontPayment":"false","External_reference":"ero","HWItemCnetMemory":"128GB"},"price":[{"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0.00000","baseAmount":"0.00000","chargeAmount":"0.00000"},{"displayText":null,"chargeType":"One-time","recurringFrequency":null,"nrc_amount":"9639.23000","baseAmount":"9639.23000","chargeAmount":"9639.23000"}],"actionCode":"Add","name":"Apple iPhone 13 Pro 128GB Grafit","englishName":"Apple iPhone 13 Pro 128GB Graphite","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory__c":"mobiledevice","C2BC_Category":"goods","ordering_System":null,"ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"9102935"}]}';
        basket3.MCOnline_Contract__c = contr.Id;
        basket3.Account__c = acc.Id;
        basket3.MCOnline_ParentBasket__c = pbasket.Id;
        basket3.Basket_Line_Relation_Id__c = 'Id1';
        basket3.basket_Line_Relation_Count__c = 3;
        basket3.MCOnline_Billing_Account__c = 'Test_BillingAccount';
        insert basket3;
        
        MCOnline_Basket__c basket4 = new MCOnline_Basket__c();
        basket4.MCOnline_Admin__c = 'testUser1';
        basket4.CreatedDate = Date.today();
        basket4.MCOnline_Orders__c = order.Id;
        basket4.MCOnline_Basket_Key__c = 'c949525b7f60a2d109c75305a525867c';
        basket4.MCOnline_OfferCode__c = 'AddonOffer';
        basket4.TSCID__c = 'TSCID_1234';
        basket4.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket4.MCOnline_AttributeJSON__c = '{"products":[{"price":[{"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"99.00","baseAmount":"99.00000","chargeAmount":"99.00000"}],"actionCode":"Add","name":"Fast IP adress","englishName":null,"downstream_CategoryData":"0","TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":"0","CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"GPRSIP-1","AO":null,"productCode":"MOB_BB_FAST_IP"}]}';
        basket4.MCOnline_Contract__c = contr.Id;
        basket4.Account__c = acc.Id;
        basket4.MCOnline_ParentBasket__c = pbasket.Id;
        basket4.Basket_Line_Relation_Id__c = 'Id1';
        basket4.basket_Line_Relation_Count__c = 4;
        basket4.MCOnline_Billing_Account__c = 'Test_BillingAccount';
        insert basket4;   
    }
    
    @istest
    static  void successScenario() {
        
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Map<String,Object> basketResponse = new Map<String,Object>();
        Map<String,Object> miniBasket = new Map<String,Object>();
        List<Object> baskets = new List<Object>();
        List<Order> lis = [select id,OrderNumber,Account.TSCID__c from Order where Account.Name ='TestAccount'];
        inputMap.put('TSCID',lis[0].Account.TSCID__c);
        inputMap.put('fromOrder',lis[0].OrderNumber);
        inputMap.put('users','testUser1');
        String fromOrder = lis[0].OrderNumber;
        String tscid = lis[0].Account.TSCID__c;
       // MCOnline_Basket__c itemBasList = [SELECT Id,Name,Account__r.id,AgreementId__r.id,AgreementId__r.Status,
          //                                          (SELECT Id,Name,Order__c,MCOnline_Order__c,MCOnline_Contract__c,MCOnline_Catalog__c,TSCID__c,MCOnline_ParentBasket__c,MCOnline_OfferCode__c,MCOnline_AttributeJSON__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c
           //                                          FROM MCOnline_Basket__r WHERE MCOnline_Orders__r.OrderNumber=:fromOrder Order by createddate desc) 
             //                                       FROM MCOnline_ParentBasket__c WHERE Is_Processed__c=true AND TSCID__c=:tscid AND Admin__c='testUser1' Order by createddate desc limit 1];
             
            List<MCOnline_Basket__c> itemBasList = [SELECT Id,MCOnline_ParentBasket__r.Name,Name,Order__c,MCOnline_Order__c,MCOnline_Contract__c,MCOnline_Catalog__c,TSCID__c,MCOnline_ParentBasket__c,MCOnline_OfferCode__c,MCOnline_AttributeJSON__c,basket_Line_Relation_Count__c,Basket_Line_Relation_Id__c
                                                     FROM MCOnline_Basket__c WHERE MCOnline_ParentBasket__r.Is_Processed__c=true AND MCOnline_Orders__r.OrderNumber=:fromOrder AND MCOnline_ParentBasket__r.TSCID__c=:tscId  Order by createddate desc];
        system.debug(itemBasList );
       // List<vlocity_cmt__ProductChildItem__c> parentChild =[SELECT vlocity_cmt__ParentProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.ProductCode FROM vlocity_cmt__ProductChildItem__c WHERE 
       //                                                          vlocity_cmt__ParentProductId__c IN (SELECT vlocity_cmt__Product2Id__c FROM vlocity_cmt__CatalogProductRelationship__c where vlocity_cmt__Product2Id__c!=null AND vlocity_cmt__IsActive__c =  true AND vlocity_cmt__Product2Id__r.ProductCode IN ('offer1','offer2') ) AND vlocity_cmt__ParentProductId__r.IsActive =true AND vlocity_cmt__ChildProductId__c !=null];
       List<vlocity_cmt__ProductChildItem__c> parentChild = [select id,vlocity_cmt__ParentProductId__r.ProductCode, vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__c,vlocity_cmt__ParentProductId__r.Family from vlocity_cmt__ProductChildItem__c];
        system.debug('parentChild-->'+parentChild);
        List<Map<String,Object>> addToBasketRequest = new List<Map<String,Object>>();
        Map<String,Object> basketDetail = new Map<String,Object>();
        basketDetail.put('basketLineRelationCount', '2');
        basketDetail.put('basketLineRelationId', '2342432424');
        Test.startTest();
        new MCOnline_copyOrder_V4().invokeMethod('copyFromOrder',inputMap,outMap,options);
        
        
        MCOnline_copyOrder_V4.validateProductCatalog(itemBasList);
        MCOnline_copyOrder_V4.multiAddToBasketStructure(addToBasketRequest, basketDetail, outMap, 'copyFromOrder');
        Test.stopTest();
        
    }
}