@isTest
public class MCOnline_DeleteBasket_V2_Test {
 @testSetup
    static void initTestData() {
          Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'demo_tscid';
        Insert acc;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Active';
        //contr.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
        contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        insert order;
        
        MCOnline_ParentBasket__c pbasket = new MCOnline_ParentBasket__c();
        pbasket.TSCID__c = 'demo_tscid';
        //pbasket.BasketStatus__c = 'Success';
        pbasket.Order__c = order.Id;
        pbasket.CreatedDate = Date.today();
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = UserInfo.getUserId();
        pbasket.Account__c = acc.Id; 
        
        pbasket.UpdateOrderRequest__c = '';
        pbasket.CheckoutResponse__c = '';
        //pbasket.Order__c = order.Id;
        insert pbasket;
        
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
        
        MCONL_MSISDN__c msisdn = new MCONL_MSISDN__c();
        msisdn.Status__c='Reserve';
        msisdn.LineItemKey__c='LineItemKey';
        msisdn.CartContextKey__c='CartContextKey'  ;
        msisdn.Number__c='123456';
        insert  msisdn;
        
        
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
    static  void test() {
        Test.startTest();
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
       MCOnline_Basket__c basket = new MCOnline_Basket__c();
       List<MCOnline_ParentBasket__c> BsktName = [Select Name,TSCID__c,Admin__c,AgreementId__c from MCOnline_ParentBasket__c  LIMIT 1];
       inputMap.put(BsktName.get(0).Name,basket);
       new MCOnline_DeleteBasket_V2().invokeMethod('DeleteBasketGroup',inputMap, outMap, options);
       new MCOnline_DeleteBasket_V2().invokeMethod('DeleteBasket',inputMap, outMap, options);
        Test.stopTest();
               
    }
    
    @istest
    static  void test1() {
       
   //  List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper> list = new List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>();   
     Map<String, List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>> msisdnsToUpdate = new Map<String, List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>>();   
        List<MCONL_MSISDN__c> MSISDNList1 = new List<MCONL_MSISDN__c>();
        
        MCOnline_DeleteBasket_V2.msisdnUpdate( msisdnsToUpdate, MSISDNList1);
        List<MCOnline_Basket__c> BsktId = [Select Basket_Line_Relation_Id__c from MCOnline_Basket__c LIMIT 1];
        
    }
    
	@istest
    static  void test2() {
        Test.startTest();
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
       MCOnline_Basket__c basket = new MCOnline_Basket__c();
       List<MCOnline_Basket__c> BsktName = [Select Name from MCOnline_Basket__c  LIMIT 1];
       inputMap.put(BsktName.get(0).Name,basket);
       new MCOnline_DeleteBasket_V2().invokeMethod('DeleteBasketGroup',inputMap, outMap, options);
       new MCOnline_DeleteBasket_V2().invokeMethod('DeleteBasket',inputMap, outMap, options);
        Test.stopTest();
               
    }
    
    @istest
    static  void test3() {        
        Test.startTest();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<MCOnline_Basket__c> lis = [Select Basket_Line_Relation_Id__c,Name from MCOnline_Basket__c WHERE TSCID__c = 'demo_tscid' LIMIT 1];
        inputMap.put('basketName',lis[0].Basket_Line_Relation_Id__c);
        new MCOnline_DeleteBasket_V2().invokeMethod('DeleteBasketGroup',inputMap,outMap,options);
        Test.stopTest();
               
    }
    
    @istest
    static  void test4() {
        
        Test.startTest();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<MCOnline_Basket__c> lis = [Select Basket_Line_Relation_Id__c,Name from MCOnline_Basket__c WHERE TSCID__c = 'demo_tscid' LIMIT 1];
        //List<MCONL_MSISDN__c> MSISDNList= [select id, Status__c, LineItemKey__c, CartContextKey__c, Number__c from MCONL_MSISDN__c WHERE Status__c=:'Reserve'];
        inputMap.put('basketName',lis[0].Name);
        new MCOnline_DeleteBasket_V2().invokeMethod('DeleteBasketGroup',inputMap,outMap,options);
        Test.stopTest();
               
    }
    
    @istest
    static  void test5() {
        Test.startTest();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper> responseList = new List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>();
        Map<String,List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>> msisdnsToUpdate=new Map<String,List<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper>>();
        list<MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper> response1=msisdnsToUpdate.put('dummy',responseList);
    	inputMap.put('basketName',responseList);
        new MCOnline_DeleteBasket_V2().invokeMethod('DeleteBasketGroup',inputMap,outMap,options);
    }
    
}