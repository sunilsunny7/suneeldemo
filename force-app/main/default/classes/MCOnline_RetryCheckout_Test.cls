@istest
public class MCOnline_RetryCheckout_Test {
	@testSetup
	static void initTestData() { 
        
        
        List <Checkout_Offer__c> CheckoutOffer = new List <Checkout_Offer__c> ();

        Checkout_Offer__c offer1 = new Checkout_Offer__c(Name = 'PORTIN_PROCESS',
                                        OfferCode__c = 'PORTIN_PROCESS');
        CheckoutOffer.add(offer1);
        Checkout_Offer__c offer2 = new Checkout_Offer__c(Name = 'PORTIN_PROCESS_DATA',
                                        OfferCode__c = 'PORTIN_PROCESS_DATA');
        CheckoutOffer.add(offer2);
        
        Checkout_Offer__c offer3 = new Checkout_Offer__c(Name = 'TRANSFER_PROCESS',
                                        OfferCode__c = 'TRANSFER_PROCESS');
        CheckoutOffer.add(offer3);
        
        Checkout_Offer__c offer4 = new Checkout_Offer__c(Name = 'TRANSFER_PROCESS_DATA',
                                        OfferCode__c = 'TRANSFER_PROCESS_DATA');
        CheckoutOffer.add(offer4);
        
        
        insert CheckoutOffer;
        
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Active';
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
        pbasket.TSCID__c = 'TSCID9808';
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = UserInfo.getUserId();
        pbasket.Account__c = acc.Id;
        pbasket.UpdateOrderRequest__c = '{"contactDetails":{"contactMethod":"email","emailAddress":"testem@test.com","firstName":"confirstnm","lastName":"conlstname","phoneNumber":"08447040"},"orderDescription":"description testing","orderComment":"orderComment testing","salesTracking":{"resellerId":"res2090","retailerId":"29080","salesChannel":"portal channel","salesChannelId":"mconline channel id","userId":"user2389"},"shippingAddress":{"city":"Solna","pointId":"988978","postalcode":"17169","streetNumber":"11","name":"","entrance":"","apartmentNumber":"","attention":"","street":""},"billingAccountDetails":{"accountId":"billing accountId001"}}';
        pbasket.CheckoutResponse__c = '';
		pbasket.BasketStatus__c = 'Failed';        
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
        
        vlocity_cmt__OmniScript__c  procedure = new vlocity_cmt__OmniScript__c();
        procedure.Name = 'MCONLINE_CheckoutComposite_V3';
        procedure.vlocity_cmt__Type__c = 'MCONLINE';
        procedure.vlocity_cmt__SubType__c = 'CheckoutComposite_V3';
        procedure.vlocity_cmt__IsProcedure__c = true;
        insert procedure;
    }
	static void getBasketDetailsResponse_Callout() {
        Test.setMock(HttpCalloutMock.class, new BasketDetailsResponse_CalloutGenerator());
        String actualValue = MCOnline_ProcessBasket_V3.getBasketDetailsResponse('SUBSCRIPTIONS', '71eae6023da0f609203e26294f168e48', 0002);
        String expectedValue = BasketDetailsResponse_CalloutGenerator.body;
        System.assertEquals(actualValue, expectedValue);
        
    }
    @istest
    static  void retry_checkOut() { 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,String> newMap = new Map<String,String>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<List<String>> response = new List<List<String>>();
        Test.startTest();
        List<id> pBasId = new List<id>();
        List<MCOnline_ParentBasket__c> lis = [SELECT id,AgreementId__c FROM MCOnline_ParentBasket__c WHERE TSCID__c = 'TSCID9808' LIMIT 1];
        pBasId.add(lis[0].id);
        response = MCOnline_RetryCheckout.retryCheckout(pBasId);
        Test.stopTest();
        Map<String,Object> ipResponse = (Map<String, Object>) JSON.deserializeUntyped(response.get(0).get(0));
        Boolean actual;
        if(ipResponse.containsKey('success')){
            actual = (Boolean)ipResponse.get('success');
        }
        system.debug('response--->'+ipResponse);
        System.assertEquals(true, actual);
    }
}