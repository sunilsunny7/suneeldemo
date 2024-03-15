@isTest
public class MCOnline_RetryNumberReservation_Test {
    @testSetup
    static void initTestData() { 
        System.runAs(Test_DataFactory.getByPassUser()){
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        
        WebService__c web = new WebService__c();
        web.Name = 'MCONLINE_ReserveStatus';
        web.EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/getreservedstatus';
        insert web;
        
        WebService__c web3 = new WebService__c();
        web3.Name = 'MCONL_NumberReservation_Mock';
        web3.EndpointURL__c = 'https://run.mocky.io/v3/4bac1eb6-0e09-442e-818e-c886ea579fda';
        insert web3;
            
        WebService__c web2 = new WebService__c();
        web2.Name = 'MCONLINE_ReserveStatusUAT';
        web2.EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/reservenumber';
        insert web2;
        
        List < WebService__c > endpointURLs = new List < WebService__c > ();

        WebService__c wbTest = new WebService__c(Name = 'MCONLINE_ReserveNumberUAT',  
                                                 EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/reservenumber',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        WebService__c wbTest2 = new WebService__c(Name = 'MCONLINE_ReserveNumber',  

                                                 EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');    
        
        endpointURLs.add(wbTest);

        endpointURLs.add(wbTest2);
        insert endpointURLs;
            
       	RecordType rt2 = [Select id,name, DeveloperName from RecordType where Name='Teliaavtal'];
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.RecordTypeId = rt2.id;
        contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        contr.Status = 'Active';
        update contr;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        insert order;
        
        Id parentbasket;
        MCOnline_ParentBasket__c pbasket = new MCOnline_ParentBasket__c();
        pbasket.TSCID__c = 'TSCID9808';
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = UserInfo.getUserId();
        pbasket.Account__c = acc.Id;
        pbasket.UpdateOrderRequest__c = '';
        pbasket.CheckoutResponse__c = '';
        insert pbasket;
        parentbasket=pbasket.id;
        
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket.TSCID__c = 'TSCID9808';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":"retryTest","SIM_Format":"simcard","MSISDN":"4673090091055","ICCNumber":null,"externalReference":null,"email":null,"eSIM_Method":"email","commitmentPeriod":"0"},"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"599.00","baseAmount":"699.00000","chargeAmount":"699.00000","name":"Jobbmobil Obegränsad","actionCode":"Add","lineNumber":"0001.0001.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"98","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_OBEGRANSAD_V2"},{"displayText":null,"chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0.00000","baseAmount":"0.00000","chargeAmount":"0.00000","name":"MMS","actionCode":"Add","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = parentbasket;
        insert basket;
        
        MCONL_MSISDN__c  msisdn = new MCONL_MSISDN__c ();
        msisdn.Number__c='4673090091055';
        msisdn.TSCID__c='TSCID9808';
        msisdn.Status__c='Failed to Reserve';
        msisdn.CartContextKey__c ='0c33e332c0f698416833c0f15ed3a872';
        msisdn.HttpResponse__c = '{"message":{"header":{"msganswercode":" ","msgcode":"SRP","msgcreationdatetime":"20210823122709","msgid":"1629714429328","msgparadigm":"S","msgversion":"001","sendingsystem":"NHF"},"srp":{"listOfMSISDN":{"msisdn":["4673090091055"],"retNoOfIntMSISDN":"1"},"msisdntype":"VOICE","reservationLogNo":"1","reservationNumber":"7624524524","reservationType":"C","reservedTo":"20210922122709","returnCode":"1","trafficSystem":"GSM"}}}';
        insert msisdn;
        
        }}
    @istest
    static  void retryReservatio_SRPTest() {
        List<Id> baskets = new List<Id>();
        baskets.add([SELECT id from MCOnline_Basket__c]?.id);
        List<List<String>> response = MCOnline_RetryNumberReservation.retryReservation(baskets);
        system.assertEquals(false,(response.get(0)).isEmpty());
        
    }
}