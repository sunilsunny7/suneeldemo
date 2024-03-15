@isTest
public class MCOnline_GetOrder_V2Test {

    @testSetup
    static void initTestData() {
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID_1234';
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
        pbasket.TSCID__c = 'TSCID_1234';
        pbasket.BasketStatus__c = 'Success';
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
        basket.TSCID__c = 'TSCID_1234';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        basket.Basket_Line_Relation_Id__c = 'Id1';
        basket.basket_Line_Relation_Count__c = 1;
        insert basket;
    }
    @istest
    static  void test() {
        Test.startTest();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<MCOnline_ParentBasket__c> lis = [SELECT OrderNumber__c FROM MCOnline_ParentBasket__c WHERE TSCID__c = 'TSCID_1234' LIMIT 1];
        inputMap.put('orderNumber',lis[0].OrderNumber__c);
        new MCOnline_GetOrder_V2().invokeMethod('getOrderSummary',inputMap,outMap,options);
        Test.stopTest();
    }
        @istest
    static  void test1() {
        Test.startTest();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<MCOnline_ParentBasket__c> lis = [SELECT OrderNumber__c FROM MCOnline_ParentBasket__c WHERE TSCID__c = 'TSCID_1234' LIMIT 1];
        inputMap.put('orderNumber','123456');
        new MCOnline_GetOrder_V2().invokeMethod('getOrderSummary',inputMap,outMap,options);
        Test.stopTest();
    }
    @istest
    static  void test2() {
        Test.startTest();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<MCOnline_ParentBasket__c> lis = [SELECT OrderNumber__c FROM MCOnline_ParentBasket__c WHERE TSCID__c = 'TSCID_1234' LIMIT 1];
        inputMap.put('orderNumber',null);
        new MCOnline_GetOrder_V2().invokeMethod('getOrderSummary',inputMap,outMap,options);
        Test.stopTest();
    }
   @istest
    static  void test3() {
        Test.startTest();
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        new MCOnline_GetOrder_V2().invokeMethod('getOrderSummary',inputMap,outMap,options);
        Test.stopTest();
    }
}