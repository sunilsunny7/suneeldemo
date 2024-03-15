@isTest
public class MCOnline_RetryNumberUnReservation_Test {
    @testSetup
    static void initTestData() { 
        
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        acc.TSCID__c =  'TSCID9808';
        System.runAs(Test_DataFactory.getByPassUser()){
            Insert acc;
            
            MCONL_MSISDN__c msi = new MCONL_MSISDN__c();
            msi.CartContextKey__c = '7a53ba64006152c12a1e0cc6682030c5';
            msi.Number__c = '46730996215';
            msi.TSCID__c = 'TSCID9808';
            msi.Status__c = 'Reserve';
            insert msi;
            
            MCONL_MSISDN__c msin = new MCONL_MSISDN__c();
            msin.CartContextKey__c = '7a53ba64006152c12a1e0cc6682030c5';
            msin.Number__c = '467100999000949';
            msin.TSCID__c = 'TSCID9808';
            msin.Status__c = 'Reserve';
            insert msin;
        }
        
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.RecordTypeId = rt1.id;
        contr.ContractTerm=24;
        insert contr;
        contr.Status='Active';
        update contr;
        MCOnline_ParentBasket__c pbasket = new MCOnline_ParentBasket__c();
        pbasket.TSCID__c = 'TSCID9808';
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = UserInfo.getUserId();
        pbasket.Account__c = acc.Id;
        pbasket.UpdateOrderRequest__c = '';
        pbasket.CheckoutResponse__c = '';
        insert pbasket;
        
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket.TSCID__c = 'TSCID9808';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"simcard","MSISDN":"46730996215","ICCNumber":null,"externalReference":null,"email":null,"eSIM_Method":"email","commitmentPeriod":"0"},"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"479","baseAmount":"649.00000","chargeAmount":"649.00000","name":"Jobbmobil 120 GB","actionCode":"Add","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0.00000","baseAmount":"0.00000","chargeAmount":"0.00000","name":"MMS","actionCode":"Add","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"simcard","MSISDN":"467100999000949","ICCNumber":null,"email":null,"eSIM_Method":"email","commitmentPeriod":"0"},"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29.00","baseAmount":"49.00000","chargeAmount":"49.00000","name":"Jobbmobil datasim","actionCode":"Add","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        insert basket;
        
        
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
    static  void retryUnReservation_Test() {
        List<Id> baskets = new List<Id>();
        baskets.add([SELECT id from MCOnline_Basket__c]?.id);
        Test.startTest();
        List<List<String>> response = MCOnline_RetryNumberUnReservation.retryUnReservation(baskets);
        Test.stopTest();
        system.assertEquals(true, response.get(0)?.size()>0);
        
    }
}