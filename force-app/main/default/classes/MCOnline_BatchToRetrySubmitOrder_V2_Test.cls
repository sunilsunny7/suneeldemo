@isTest
public class MCOnline_BatchToRetrySubmitOrder_V2_Test {
  @testSetup
    static void initTestData() {
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        
        Account acc1 = new Account();
        acc1.RecordTypeId = '012240000008l9YAAQ';
        acc1.Name='TestAccount1';
        acc1.TSCID__c = 'TSCID9888';
        Insert acc1;
        
        Account acc2 = new Account();
        acc2.RecordTypeId = '012240000008l9YAAQ';
        acc2.Name='TestAccount2';
        acc2.TSCID__c = 'TSCID9555';
        Insert acc2;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        
        Contract contr1=new Contract();
        contr1.Name='Test1';
        contr1.AccountId=acc1.id;
        contr1.Status='Draft';
        contr1.Contract_Record_Type__c='Teliaavtal';
        contr1.Solution_Area__c='Vxl';
        contr1.StartDate=Date.today();
        contr1.ContractTerm=24;
        insert contr1;
        
        Contract contr2=new Contract();
        contr2.Name='Test2';
        contr2.AccountId=acc2.id;
        contr2.Status='Draft';
        contr2.Contract_Record_Type__c='Teliaavtal';
        contr2.Solution_Area__c='Vxl';
        contr2.StartDate=Date.today();
        contr2.ContractTerm=24;
        insert contr2;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        order.vlocity_cmt__OrderStatus__c ='Ready To Submit' ;
        order.MCOnline_OrderNumber__c = 'DEV1-00000252';
        order.MCONL_Order_Activation_Status_Code__c = '400';
        order.OrderProcessor_ResponseStatusCode__c = '400';
        order.OrderProcessor_Response_Message__c = 'Error while order submission.';
        order.OrderProcessor_Response__c = 'Error while order submission.';
        order.Type = 'New';
        insert order;
        
        Order order1 = new Order();
        order1.EffectiveDate = Date.today();
        order1.Status = 'Draft';
        order1.AccountId = acc1.Id;  
        order1.ContractId = contr1.Id;
        order1.vlocity_cmt__OrderStatus__c ='Activated' ;
        order1.MCOnline_OrderNumber__c = 'DEV1-00000250';
        insert order1;
        
        Order order2 = new Order();
        order2.EffectiveDate = Date.today();
        order2.Status = 'Draft';
        order2.AccountId = acc2.Id;  
        order2.ContractId = contr2.Id;
        order2.vlocity_cmt__OrderStatus__c ='Ready To Submit' ;
        order2.MCOnline_OrderNumber__c = 'DEV1-00000255';
        insert order2;
        
        
       
        MCOnline_ParentBasket__c pbasket = new MCOnline_ParentBasket__c();
        pbasket.TSCID__c = 'TSCID9808';
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = UserInfo.getUserId();
        pbasket.Account__c = acc.Id;
        pbasket.UpdateOrderRequest__c = '{"contactDetails":{"contactMethod":"email","emailAddress":"testem@test.com","firstName":"confirstnm","lastName":"conlstname","phoneNumber":"08447040"},"orderDescription":"description testing","orderComment":"orderComment testing","salesTracking":{"resellerId":"res2090","retailerId":"29080","salesChannel":"portal channel","salesChannelId":"mconline channel id","userId":"user2389"},"shippingAddress":{"city":"Solna","pointId":"988978","postalcode":"17169","streetNumber":"11","name":"","entrance":"","apartmentNumber":"","attention":"","street":""},"billingAccountDetails":{"accountId":"billing accountId001"}}';
        pbasket.CheckoutResponse__c = '';
        pbasket.Order__c = order.id;
        insert pbasket;
        
        MCOnline_ParentBasket__c pbasket1 = new MCOnline_ParentBasket__c();
        pbasket1.TSCID__c = 'TSCID9888';
        pbasket1.AgreementId__c = contr1.Id;
        pbasket1.Admin__c = UserInfo.getUserId();
        pbasket1.Account__c = acc1.Id;
        pbasket1.UpdateOrderRequest__c = '{"contactDetails":{"contactMethod":"email","emailAddress":"testem@test.com","firstName":"confirstnm","lastName":"conlstname","phoneNumber":"08447040"},"orderDescription":"description testing","orderComment":"orderComment testing","salesTracking":{"resellerId":"res2090","retailerId":"29080","salesChannel":"portal channel","salesChannelId":"mconline channel id","userId":"user2389"},"shippingAddress":{"city":"Solna","pointId":"988978","postalcode":"17169","streetNumber":"11","name":"","entrance":"","apartmentNumber":"","attention":"","street":""},"billingAccountDetails":{"accountId":"billing accountId001"}}';
        pbasket1.CheckoutResponse__c = '';
        pbasket1.Order__c = order1.id;
        insert pbasket1;
        
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket.TSCID__c = 'TSCID9808';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        insert basket;
        
        MCOnline_Basket__c basket1 = new MCOnline_Basket__c();
        basket1.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket1.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket1.TSCID__c = 'TSCID9888';
        basket1.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket1.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket1.MCOnline_Contract__c = contr1.Id;
        basket1.Account__c = acc1.Id;
        basket1.MCOnline_ParentBasket__c = pbasket1.Id;
        insert basket1;
    }
  @istest
    static void resubmitOrderTest() { 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,String> newMap = new Map<String,String>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<String> idList = new List<String>();
        List<String> result = new List<String>();
        Test.startTest();
        MCOnline_BatchToRetrySubmitOrder_V2 M = new MCOnline_BatchToRetrySubmitOrder_V2();
    Database.executeBatch(M);
        Test.stopTest();
        Order ord = [SELECT id,vlocity_cmt__OrderStatus__c FROM Order WHERE MCOnline_OrderNumber__c =:'DEV1-00000250'];
        System.assertEquals('Activated', ord.vlocity_cmt__OrderStatus__c);
    }
}