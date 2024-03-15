@isTest
public class MCOnline_futureSplitCheckoutV5Test 
{
    @testSetup
    static void initTestData() 
    {
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
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
        //contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        contr.Status='Active';
        System.runAs(salesManager){
            update contr;
        }
        
        MCOnline_ParentBasket__c pbasket = new MCOnline_ParentBasket__c();
        pbasket.TSCID__c = 'TSCID9808';
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = UserInfo.getUserId();
        //pbasket.Name = 'PBasket1';
        //pbasket.OrderNumber__c = '';
        pbasket.Account__c = acc.Id;
        pbasket.UpdateOrderRequest__c = '';
        pbasket.CheckoutResponse__c = '';
        //pbasket.Order__c = order.Id;
        insert pbasket;
        
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket.TSCID__c = 'TSCID9808';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;


        basket.Basket_Line_Relation_Id__c = '12345';
        basket.basket_Line_Relation_Count__c = 1;

        basket.MCOnline_ParentBasket__c = pbasket.Id;
        insert basket;
        
    }
    @isTest
    static void test()
    {
        String requestBody = '{"options":{"users":"test1234","agreementId":"8003E000002gMmdQAE","tscid":"7896578654","Content-Type":"application/json","X-Salesforce-Forwarded-To":"xyz","X-B3-TraceId":"d20c5ea0396d65f6","X-Salesforce-SNI":"PRESENT","Postman-Token":"b9963780-de26-47fc-943f-1204831ef04e","X-B3-Sampled":"0","X-B3-SpanId":"d20c5ea0396d65f6","X-Salesforce-SIP":"45.251.234.124","X-Salesforce-VIP":"FORCE","Accept-Encoding":"gzip, deflate, br","Host":"telia--dev2online.my.salesforce.com","Connection":"keep-alive","User-Agent":"PostmanRuntime/7.29.0","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 443","Accept":"*/*"},"creditCheckResult":"MANUAL","billingAccountDetails":{"accountId":"billingaccId1"},"shippingAddress":{"careOf":"abc","country":"Sweden","street":"street","attention":"attention","apartmentNumber":"26B","entrance":"entrance","name":"Binamra","streetNumber":"11","postalcode":"17169","pointId":"988978","city":"Solna"},"salesTracking":{"userId":"user2389","salesChannelId":"mconline channel id","salesChannel":"portal channel","retailerId":"29080","resellerId":"res2090"},"orderDescription":"description testing","contactDetails":{"phoneNumber":"08447040","lastName":"conlstname","firstName":"confirstnm","emailAddress":"testcase@autocancel.teliacompany.net","contactMethod":"email"},"orderComment":"Done","languageCode":"EN"}';
        List<MCOnline_Basket__c> pbasketlist = new List<MCOnline_Basket__c>();
        Map<Id,Map<String, Map<String, Object>>> basketMap = new Map<Id,Map<String, Map<String, Object>>>();
        MCOnline_ParentBasket__c parentBasketObj = [Select id,Account__c, TSCID__c, Admin__c, AgreementId__c  from MCOnline_ParentBasket__c Where TSCID__c = 'TSCID9808' LIMIT 1];
        pbasketlist = [SELECT id, Name, MCOnline_Catalog__c,MCOnline_OfferCode__c, MCOnline_AttributeJSON__c,Order__c, MCOnline_Basket_Key__c from MCOnline_Basket__c WHERE TSCID__c = 'TSCID9808' ];
        String data='{"DEV2-0000289":[{"basketName":"BAS-0005410","Id":"'+pbasketlist[0].Id+'"}]}';
        
        Id basketId = parentBasketObj.Id;
        String tscid = String.valueOf(parentBasketObj.TSCID__c);
        String users = String.valueOf(parentBasketObj.Admin__c);
        String agreementId = String.valueOf(parentBasketObj.AgreementId__c);
        Map<String,Object> basketToOrderMap = (Map<String,Object>)JSON.deserializeUntyped(data);
        Map<Id, MCOnline_Basket__c> basketIdMap = new Map<Id, MCOnline_Basket__c>();
        basketIdMap.put(pbasketlist[0].Id, pbasketlist[0]);
        Map<String, String> offerMapAttribute = new Map<String, String>();
        MCOnline_OfferAttribute__mdt prodJSON = new MCOnline_OfferAttribute__mdt();
        
        MCOnline_futureSplitCheckoutV5 cls= new MCOnline_futureSplitCheckoutV5(parentBasketObj.Account__c,basketToOrderMap, basketIdMap, basketMap, parentBasketObj, tscid, users, agreementId, basketId, requestBody, offerMapAttribute, prodJSON);
        Test.startTest();
        DataBase.executeBatch(cls);   
        Test.stopTest();
    }
}