@isTest
public class MCOnline_BatchApextoDeleteBasket_V1_Test {
public static DateTime lastNthDays;
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
             pbasket.Order__c = order.Id;
        pbasket.BasketStatus__c = null;
        //pbasket.Name = 'PBasket1';
        //pbasket.OrderNumber__c = '';
        pbasket.Account__c = acc.Id;
        pbasket.UpdateOrderRequest__c = '';
        pbasket.CheckoutResponse__c = '';
      //  pbasket.Is_Processed__c = false;
        insert pbasket;
        
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.TSCID__c = 'TSCID9808';
        //basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        // basket.Name =
        insert basket;
        
        
   }
    @istest
    static  void test() {
        new MCOnline_BatchApextoDeleteBasket_V1().finish(null);
    }
     @istest
    static  void test1() {
        Integer numberOfDays;
        DateTime lastNthDays;
         numberOfDays = Integer.valueOf(Label.BasketDeletion_NumberOfDays);
            lastNthDays = DateTime.Now().addDays(numberOfDays);
        
        List<MCOnline_Basket__c> basketList = new List<MCOnline_Basket__c>();
        basketList = [SELECT id, Name from MCOnline_Basket__c WHERE MCOnline_ParentBasket__r.Is_Processed__c = false AND MCOnline_ParentBasket__r.CreatedDate <= :lastNthDays ];
        insert basketList;
       //    Test.startTest();
       // MCOnline_BatchApextoDeleteBasket_V1 deletebasket = new MCOnline_BatchApextoDeleteBasket_V1();
      //  Database.executeBatch(deletebasket);
      //  Test.stopTest();
      
    }
     @istest
    static  void test2() {
        new MCOnline_BatchApextoDeleteBasket_V1().start(null);
        
         new MCOnline_BatchApextoDeleteBasket_V1().execute(null); 
      
    }
      @istest
    static  void test3() {
        new MCOnline_BatchApextoDeleteBasket_V1().execute(null,null); 
    }
          @istest
    static  void test4() {
        
        Integer numberOfDays;
        DateTime lastNthDays;
         numberOfDays = Integer.valueOf(Label.BasketDeletion_NumberOfDays);
         lastNthDays = DateTime.Now().addDays(numberOfDays);
        
        List<MCOnline_Basket__c> basketList = new List<MCOnline_Basket__c>();
        basketList = [SELECT id, Name from MCOnline_Basket__c ];
 
        basketList.get(0);
      List<String> successList = new List<String>();
        successList.add('element');
        successList.add(basketList.get(0).Name);
         //successList.add(String.valueOf(basketList[0].Name));
        
    }
    @istest static void test_execute(){
        Integer numberOfDays;
         numberOfDays = Integer.valueOf(Label.ProcessedBasketDeletion_NumberOfDays);
        lastNthDays = DateTime.Now().addDays(numberOfDays);
        List<MCOnline_Basket__c> pbasketlist = new List<MCOnline_Basket__c>();
        pbasketlist = [SELECT id, Name from MCOnline_Basket__c WHERE TSCID__c = 'TSCID9808' ];
        MCOnline_BatchApextoDeleteBasket_V1 ba= new MCOnline_BatchApextoDeleteBasket_V1();
        //Database.QueryLocator ql = cb.start(null);
        ba.execute(null,pbasketlist);
        ba.finish(null);
    }
   /* @istest static void test_all(){
        MCOnline_BatchApexDelParentBskt_V1 ba= new MCOnline_BatchApexDelParentBskt_V1();
        new MCOnline_BatchApextoDeleteBasket_V1().start(null);
        ba.execute(null,null);
        ba.finish(null);
        
    }*/
}