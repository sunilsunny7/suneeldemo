@isTest
public class MCOnline_NumberUnReservationBatch_V1Test {

@testSetup
    static void initTestData() {
        
         Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        
        Contract contr = new Contract();
        contr.Name = 'SnehaD';
        contr.AccountId = acc.id;
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
           //  pbasket.Order__c = order.Id;
        //pbasket.Name = 'PBasket1';
        //pbasket.OrderNumber__c = '';
        pbasket.Account__c = acc.Id;
        pbasket.UpdateOrderRequest__c = '';
        pbasket.CheckoutResponse__c = '';
       // pbasket.Is_Processed__c = false; //not writeable
        insert pbasket;
        
        MCONL_MSISDN__c mconl =new MCONL_MSISDN__c();
        mconl.Number__c = '1017635812';
        mconl.Status__c = 'Reserve';
        insert mconl;
        
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.TSCID__c = 'TSCID9808';
        //basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        insert basket;
        
        
    }
      @istest
    static  void test() {
        Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport();
        
           List < WebService__c > endpointURLs = new List < WebService__c > ();
        WebService__c wbTest = new WebService__c(Name = 'MCONLINE_UnReserveNumber',  
                                                 EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest);
        insert endpointURLs; 
        
        String basketName;
         List<MCOnline_Basket__c> basketList = new List<MCOnline_Basket__c>();
        basketList = [SELECT id,Name,TSCID__c, MCOnline_ParentBasket__c from MCOnline_Basket__c ]; 
       
        MCOnline_NumberUnReservationFromBatch_V1.deleteBasket(basketList.get(0).Name); 
         MCOnline_NumberUnReservationFromBatch_V1.unreserveMSISDN(basketList.get(0).Name); 
        
        List<MCONL_MSISDN__c> msisdnlist = new List<MCONL_MSISDN__c>();
        msisdnlist = [SELECT id,Number__c from MCONL_MSISDN__c];
        Set<String> setstr = new Set<String>();
        setstr.add('onstr');
        setstr.add('twostr');
       
       // System.debug('check values'+setstr+'some basket value:'+basketList.get(0).Name); 
        MCOnline_NumberUnReservationFromBatch_V1.unreserveMSISDN(setstr,basketList.get(0).Name,basketList.get(0).TSCID__c); 
        
  
        }
       @istest
      static void test1(){
        Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport();
        
           List < WebService__c > endpointURLs = new List < WebService__c > ();
        WebService__c wbTest = new WebService__c(Name = 'MCONLINE_UnReserveNumber',  
                                                 EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest);
        insert endpointURLs; 
           String basketName;
         List<MCOnline_Basket__c> basketList = new List<MCOnline_Basket__c>();
   basketList = [SELECT id,Name, MCOnline_AttributeJSON__c from MCOnline_Basket__c ]; 
        MCOnline_NumberUnReservationFromBatch_V1.unreserveMSISDN(basketList.get(0).Name); 
        
       }
  
    
  
}