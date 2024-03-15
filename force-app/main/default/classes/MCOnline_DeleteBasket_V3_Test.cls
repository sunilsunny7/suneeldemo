@isTest
public class MCOnline_DeleteBasket_V3_Test {
    @testSetup
    static void initTestData() {
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'demo_tscid';
        Insert acc;
        
        Account acc1 = new Account();
        acc1.RecordTypeId = '012240000008l9YAAQ';
        acc1.Name='TestAccount1';
        acc1.TSCID__c = 'demo_tscid1';
        Insert acc1;
        
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
       
        Contract contr1=new Contract();
        contr1.Name='Test1';
        contr1.AccountId=acc1.id;
        contr1.Status='Draft';
        contr1.Contract_Record_Type__c='Teliaavtal';
        contr1.Solution_Area__c='Vxl';
        contr1.StartDate=Date.today();
        contr1.ContractTerm=24;
        insert contr1;
        contr1.Status='Active';
        update contr1;
       
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        insert order;
        
        Order order1 = new Order();
        order1.EffectiveDate = Date.today();
        order1.Status = 'Draft';
        order1.AccountId = acc1.Id;  
        order1.ContractId = contr1.Id;
        insert order1;

        
        MCOnline_ParentBasket__c pbasket = new MCOnline_ParentBasket__c();
        pbasket.TSCID__c = 'demo_tscid';
        pbasket.Order__c = order.Id;
        pbasket.CreatedDate = Date.today();
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = UserInfo.getUserId();
        pbasket.Account__c = acc.Id; 
        
        MCOnline_ParentBasket__c pbasket1 = new MCOnline_ParentBasket__c();
        pbasket1.TSCID__c = 'demo_tscid1';
        pbasket1.Order__c = order1.Id;
        pbasket1.CreatedDate = Date.today();
        pbasket1.AgreementId__c = contr1.Id;
        pbasket1.Admin__c = UserInfo.getUserId();
        pbasket1.Account__c = acc1.Id; 

        
        pbasket.UpdateOrderRequest__c = '';
        pbasket.CheckoutResponse__c = '';
        insert pbasket;
        
        pbasket1.UpdateOrderRequest__c = '';
        pbasket1.CheckoutResponse__c = '';
        insert pbasket1;
        
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Admin__c = UserInfo.getUserId();
        basket.CreatedDate = Date.today();
        basket.MCOnline_Order__c = order.Id;
        basket.MCOnline_Basket_Key__c = 'c949525b7f60a2d109c75305a525867c';
        basket.MCOnline_OfferCode__c = 'MOB_MULTI_BB_V2';
        basket.TSCID__c = 'demo_tscid';        
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"123456","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        basket.Basket_Line_Relation_Id__c = 'Id1';
        basket.basket_Line_Relation_Count__c = 1;
        insert basket;
        
        MCOnline_Basket__c basket1 = new MCOnline_Basket__c();
        basket1.MCOnline_Admin__c = UserInfo.getUserId();
        basket1.CreatedDate = Date.today();
        basket1.MCOnline_Order__c = order1.Id;
        basket1.MCOnline_Basket_Key__c = 'c949525b7f60a2d109c75305a525867c';
        basket1.MCOnline_OfferCode__c = 'MOB_MULTI_BB_V2';
        basket1.TSCID__c = 'demo_tscid1';        
        basket1.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket1.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"55555","ICCNumber":"59460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"}]}';
        basket1.MCOnline_Contract__c = contr1.Id;
        basket1.Account__c = acc1.Id;
        basket1.MCOnline_ParentBasket__c = pbasket1.Id;
        insert basket1;

        
        MCONL_MSISDN__c msisdn = new MCONL_MSISDN__c();
        msisdn.Status__c='Reserve';
        msisdn.LineItemKey__c='LineItemKey';
        msisdn.CartContextKey__c='CartContextKey'  ;
        msisdn.Number__c='123456';
        insert  msisdn;
        
        MCONL_MSISDN__c msisdn1 = new MCONL_MSISDN__c();
        msisdn1.Status__c='Reserve';
        msisdn1.LineItemKey__c='LineItemKey';
        msisdn1.CartContextKey__c='CartContextKey'  ;
        msisdn1.Number__c='55555';
        insert  msisdn1;
        
        
        List < WebService__c > endpointURLs = new List < WebService__c > ();
        WebService__c wbTest = new WebService__c(Name = 'MCONLINE_UnReserveNumber',  
                                                 EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest);
        
        WebService__c wbTest11 = new WebService__c(Name = 'MCONLINE_UnReserveNumberUAT',  
                                                   EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                   Content_Type__c = 'application/x-www-form-urlencoded', 
                                                   userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                   password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                   Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest11);
        
        WebService__c wbTest2 = new WebService__c(Name = 'TeliaSE_MadamAuthenticationWS',  
                                                  EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        
        WebService__c wbTest3 = new WebService__c(Name = 'TeliaSE_MadamAuthenticationWS_UAT',  
                                                  EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest3);
        endpointURLs.add(wbTest2);
        insert endpointURLs;
        
        FeaturesSetting__c festureSetting = new FeaturesSetting__c();
        festureSetting.Name = 'NumberReservation';
        festureSetting.flag__c = true;
        Insert festureSetting;
        
        FeaturesSetting__c festureSetting2 = new FeaturesSetting__c();
        festureSetting2.Name = 'NumberUnReservation';
        festureSetting2.flag__c = true;
        Insert festureSetting2;
        
    }
    
    @istest
    static  void deleteBasketTest() {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Map<String,Object> basName = new Map<String,Object>();
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        String BsktName = [SELECT id,Name FROM MCOnline_Basket__c LIMIT 1]?.Name;
        basName.put('basketName',BsktName);
        inputMap.put('options',basName);
        Test.startTest();
        new MCOnline_DeleteBasket_V3().invokeMethod('DeleteBasketGroup',inputMap, outMap, options);
        Test.stopTest();
        system.assertEquals(200,outMap.get('StatusCode'));
    }
    
    @istest
    static  void R1_BasketTest() {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Map<String,Object> basName = new Map<String,Object>();
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        String BsktName = [SELECT id,Name FROM MCOnline_Basket__c WHERE TSCID__c = 'demo_tscid1' LIMIT 1  ]?.Name;
        basName.put('basketName',BsktName);
        inputMap.put('options',basName);
        Test.startTest();
        new MCOnline_DeleteBasket_V3().invokeMethod('DeleteBasketGroup',inputMap, outMap, options);
        Test.stopTest();
        system.assertEquals(200,outMap.get('StatusCode'));
    }
    
    @istest
    static  void InvalidBasketTest() {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Map<String,Object> basName = new Map<String,Object>();
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basName.put('basketName','BAS-Test');
        inputMap.put('options',basName);
        Test.startTest();
        new MCOnline_DeleteBasket_V3().invokeMethod('DeleteBasketGroup',inputMap, outMap, options);
        Test.stopTest();
        system.assertEquals(400,outMap.get('StatusCode'));
    }
    
    @istest
    static  void BlankBasketTest() {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Map<String,Object> basName = new Map<String,Object>();
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basName.put('basketName',' ');
        inputMap.put('options',basName);
        Test.startTest();
        new MCOnline_DeleteBasket_V3().invokeMethod('DeleteBasketGroup',inputMap, outMap, options);
        Test.stopTest();
        system.assertEquals(400,outMap.get('StatusCode'));
    }
    
    @istest
    static  void incorrectMethodTest() {
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Test.startTest();
        MCOnline_DeleteBasket_V3 bas = new MCOnline_DeleteBasket_V3();
        Test.stopTest();
        system.assertEquals(false,bas.invokeMethod('BasketGroup',inputMap, outMap, options));
    }
}