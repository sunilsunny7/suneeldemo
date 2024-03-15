@isTest
public class createAsynchBasketsBatchTest {
    
    @isTest
    static void batchName1() {
        // Map<String, String> inputMap = new Map<String, String>();
        // Map<String,Object> inputMap1 = new Map<String, Object>(); 
        Map<String, Object> orderDetails = new Map<String, Object>();
        string OrderTSCID;
        string OrderAgreementId;
        string OrderUser;
        Test.startTest();
        Map<String, Object> productConfigMap = new Map<String, Object>();  
        
        //   productConfigMap.put('{"offerDetails":{"offer":{"priceResult":[{"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"effectiveuntildatespec":null,"effectivefromdatespec":null,"RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring"}],"addtocart":{"rest":{"params":{"context":"{}","basketAction":"AddWithNoConfig","offer":null},"link":"v3/catalogs/PROCESS/basket","method":"POST"}},"Name":"Portering","ProductCode":"PORTIN_PROCESS","Product2Id":"01t9E00000BLYOMQA5","PricebookEntryId":"01u9E000017jmKwQAI","Quantity":1.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":1,"productHierarchyPath":"01t9E00000BLYOMQA5","lineNumber":"0001","AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":1,"messages":[],"records":[{"messages":[],"code":"Relation_Id","dataType":"text","inputType":"text","label":"Relation_Id","values":[{}],"userValues":null}]}}]},"Id":"01t9E00000BLYOMQA5","Description":null,"vlocity_cmt__SellingStartDate__c":"2021-10-01T08:30:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":true,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"offerbundle","C2BC_Subcategory__c":"mobilevoicesubscription","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":"Porting","childProducts":[{"priceResult":[{"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"effectiveuntildatespec":null,"effectivefromdatespec":null,"RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring"}],"Name":"Nummerflytt","ProductCode":"PORTIN_PROCESS_DATA","Product2Id":"01t9E00000BLYO6QAP","PricebookEntryId":"01u9E000017jmKgQAI","Quantity":1.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t9E00000BLYOMQA5<01t9E00000BLYO6QAP","lineNumber":"0001.0001","AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":11,"messages":[],"records":[{"messages":[],"code":"Contact_telephone_number","dataType":"text","inputType":"text","label":"Contact_telephone_number","values":[{}],"userValues":null},{"messages":[],"code":"Current_MSISDN","dataType":"text","inputType":"text","label":"Current_MSISDN","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_Organization","dataType":"text","inputType":"text","label":"Current_owner_Organization","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_SSN","dataType":"text","inputType":"text","label":"Current_owner_SSN","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_email","dataType":"text","inputType":"text","label":"Current_owner_email","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_first_name","dataType":"text","inputType":"text","label":"Current_owner_first_name","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_last_name","dataType":"text","inputType":"text","label":"Current_owner_last_name","values":[{}],"userValues":null},{"messages":[],"code":"External_reference","dataType":"text","inputType":"text","label":"External_reference","values":[{}],"userValues":null},{"messages":[],"code":"Temporary_MSISDN","dataType":"text","inputType":"text","label":"Temporary_MSISDN","values":[{}],"userValues":null},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","label":"User_name","values":[{}],"userValues":null},{"messages":[],"code":"ownerPhoneNumber","dataType":"text","inputType":"text","label":"ownerPhoneNumber","values":[{}],"userValues":null}]}}]},"Id":"01t9E00000BLYO6QAP","Description":null,"vlocity_cmt__SellingStartDate__c":"2021-10-01T08:30:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"mobilevoicesubscription","C2BC_Subcategory__c":"portin","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null}],"offerType":"Product","vlocity_cmt__InCartQuantityMap__c":{"01t9E00000BLYO6QAP":1}}}}','test');
        // inputMap.put('test',JSON.serialize(productConfigMap));
        //  inputMap1.put('test',JSON.serialize(productConfigMap));
        
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        list<WebService__c> weblist = new list<WebService__c>();
        WebService__c web = new WebService__c();
        web.Name = 'MCONLINE_ReserveStatus';
        web.EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/getreservedstatus';
        weblist.add(web);
        
        WebService__c web2 = new WebService__c();
        web2.Name = 'MCONLINE_ReserveStatusUAT';
        web2.EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/reservenumber';
        weblist.add(web2);
        insert weblist;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        //contr.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
        contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        contr.Status='Active';
      	update contr;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        insert order;
        list<MCOnline_ParentBasket__c> parlist = new list<MCOnline_ParentBasket__c>();
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
        parlist.add(pbasket);
        
        
        /*MCOnline_ParentBasket__c pbasket2 = new MCOnline_ParentBasket__c();
pbasket2.TSCID__c = 'TSCID9808';
pbasket2.AgreementId__c = contr.Id;
pbasket2.Admin__c = UserInfo.getUserId();
//pbasket.Name = 'PBasket1';
//pbasket.OrderNumber__c = '';
pbasket2.Account__c = acc.Id;
pbasket2.UpdateOrderRequest__c = '';
pbasket2.CheckoutResponse__c = '';
//pbasket.Order__c = order.Id;
parlist.add(pbasket2);*/
        insert parlist;
        
        list<MCOnline_Basket__c> basketlist = new list<MCOnline_Basket__c>(); 
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket.TSCID__c = 'TSCID9808';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        basketlist.add(basket);
        MCOnline_Basket__c basket2 = new MCOnline_Basket__c();
        basket2.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket2.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket2.TSCID__c = 'TSCID9808';
        basket2.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket2.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket2.MCOnline_Contract__c = contr.Id;
        basket2.Account__c = acc.Id;
        basket2.MCOnline_ParentBasket__c = pbasket.Id;
        basketlist.add(basket2);      
        insert basketlist;
        
        String AccountId;
        String TSCID;
        String users;
        String Catalog;
        String Agreementid;
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<MCOnline_Basket__c> Parameters = new List<MCOnline_Basket__c>();
        users = 'testuser'; 
        acc = [select id,TSCID__c from Account where Name ='TestAccount'];
        AccountId = acc.id;
        TSCID = acc.TSCID__c;
        OrderTSCID = TSCID;  
        contr = [select id from Contract where AccountId =:AccountId];
        Agreementid = contr.id;
        options.put('Accountid',AccountId);
        options.put('TSCID',TSCID);
        options.put('users',users);
        options.put('Agreementid',Agreementid);
        options.put('Catalog',Catalog);
        List<Object> childProductslist = new list<Object>();
        List<Object> childProductslist1 = new list<Object>();
        Map<String,Object> Quantity = new Map<String,Object>();
        Quantity.put('Quantity','0');
        childProductslist1.add(Quantity);
        Map<String,Object> childProducts1 = new Map<String,Object>();
        childProducts1.put('childProducts',childProductslist1);
        Map<String,Object> link = new Map<String,Object>();
        /*set<string> Catalogset = new set<string>();
Catalogset.add('SUBSCRIPTIONS');
Catalogset.add('PROCESS');
Catalogset.add('MOBILEDEVICE');*/
        link.put('link','/v3/catalogs/SUBSCRIPTIONS/basket');
        childProducts1.put('rest',link);
        childProductslist.add(childProducts1);
        Map<String,Object> childProducts = new Map<String,Object>();
        childProducts.put('childProducts',childProductslist);
        childProducts.put('addtocart',childProducts1);
        Map<String,Object> offer = new Map<String,Object>();
        offer.put('offer',childProducts);
        inputMap.put('offerDetails',offer);
        list<Object> opplist = new list<object>();
        opplist.add(options);
        inputMap.put('productConfig', opplist );
        inputMap.put('basketLineRelationCount',opplist );
        inputMap.put('options',options );
        
        inputMap.put('contextKey','contextKey');
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> option = new Map<String,Object>();
        Map<String,Object> inputMap1 = new Map<String,Object>();
        inputMap1.put('options',options);
        inputMap1.put('contextKey','contextKey');
        output.put('cartContextKey',options);
        output.put('OrderId',order);
        output.put('records',basketlist);
        output.put('result',basketlist); 
        
        Map<String, String> inputMap2 = new Map<String, String>();
        inputMap2.put(basketlist[0].Id,JSON.serialize(inputMap));
        boolean isManagedFlow = true;
        
        try{
            createAsynchBasketsBatch basket32 = new createAsynchBasketsBatch(inputMap2,inputMap1,orderDetails,OrderTSCID,OrderAgreementId,OrderUser);
            //createAsynchBasketsBatch basket33 = new createAsynchBasketsBatch(inputMap2,inputMap1,orderDetails,OrderTSCID,OrderAgreementId,OrderUser,isManagedFlow);
            //createAsynchBasketsBatch basket34 = new createAsynchBasketsBatch(inputMap2,inputMap1,OrderTSCID,OrderAgreementId,OrderUser);
            Id batchId = Database.executeBatch(basket32);
            //Id batchId1 = Database.executeBatch(basket33);
            //Id batchId2 = Database.executeBatch(basket34);
        }catch(exception ex){
            
        }
        Test.stopTest();
    }
  @isTest
  static void batchName2() {
        // Map<String, String> inputMap = new Map<String, String>();
        // Map<String,Object> inputMap1 = new Map<String, Object>(); 
        Map<String, Object> orderDetails = new Map<String, Object>();
        string OrderTSCID;
        string OrderAgreementId;
        string OrderUser;
        Test.startTest();
        Map<String, Object> productConfigMap = new Map<String, Object>();  
        
        //   productConfigMap.put('{"offerDetails":{"offer":{"priceResult":[{"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"effectiveuntildatespec":null,"effectivefromdatespec":null,"RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring"}],"addtocart":{"rest":{"params":{"context":"{}","basketAction":"AddWithNoConfig","offer":null},"link":"v3/catalogs/PROCESS/basket","method":"POST"}},"Name":"Portering","ProductCode":"PORTIN_PROCESS","Product2Id":"01t9E00000BLYOMQA5","PricebookEntryId":"01u9E000017jmKwQAI","Quantity":1.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":1,"productHierarchyPath":"01t9E00000BLYOMQA5","lineNumber":"0001","AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":1,"messages":[],"records":[{"messages":[],"code":"Relation_Id","dataType":"text","inputType":"text","label":"Relation_Id","values":[{}],"userValues":null}]}}]},"Id":"01t9E00000BLYOMQA5","Description":null,"vlocity_cmt__SellingStartDate__c":"2021-10-01T08:30:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":true,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"offerbundle","C2BC_Subcategory__c":"mobilevoicesubscription","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":"Porting","childProducts":[{"priceResult":[{"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"effectiveuntildatespec":null,"effectivefromdatespec":null,"RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring"}],"Name":"Nummerflytt","ProductCode":"PORTIN_PROCESS_DATA","Product2Id":"01t9E00000BLYO6QAP","PricebookEntryId":"01u9E000017jmKgQAI","Quantity":1.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t9E00000BLYOMQA5<01t9E00000BLYO6QAP","lineNumber":"0001.0001","AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":11,"messages":[],"records":[{"messages":[],"code":"Contact_telephone_number","dataType":"text","inputType":"text","label":"Contact_telephone_number","values":[{}],"userValues":null},{"messages":[],"code":"Current_MSISDN","dataType":"text","inputType":"text","label":"Current_MSISDN","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_Organization","dataType":"text","inputType":"text","label":"Current_owner_Organization","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_SSN","dataType":"text","inputType":"text","label":"Current_owner_SSN","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_email","dataType":"text","inputType":"text","label":"Current_owner_email","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_first_name","dataType":"text","inputType":"text","label":"Current_owner_first_name","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_last_name","dataType":"text","inputType":"text","label":"Current_owner_last_name","values":[{}],"userValues":null},{"messages":[],"code":"External_reference","dataType":"text","inputType":"text","label":"External_reference","values":[{}],"userValues":null},{"messages":[],"code":"Temporary_MSISDN","dataType":"text","inputType":"text","label":"Temporary_MSISDN","values":[{}],"userValues":null},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","label":"User_name","values":[{}],"userValues":null},{"messages":[],"code":"ownerPhoneNumber","dataType":"text","inputType":"text","label":"ownerPhoneNumber","values":[{}],"userValues":null}]}}]},"Id":"01t9E00000BLYO6QAP","Description":null,"vlocity_cmt__SellingStartDate__c":"2021-10-01T08:30:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"mobilevoicesubscription","C2BC_Subcategory__c":"portin","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null}],"offerType":"Product","vlocity_cmt__InCartQuantityMap__c":{"01t9E00000BLYO6QAP":1}}}}','test');
        // inputMap.put('test',JSON.serialize(productConfigMap));
        //  inputMap1.put('test',JSON.serialize(productConfigMap));
        
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        list<WebService__c> weblist = new list<WebService__c>();
        WebService__c web = new WebService__c();
        web.Name = 'MCONLINE_ReserveStatus';
        web.EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/getreservedstatus';
        weblist.add(web);
        
        WebService__c web2 = new WebService__c();
        web2.Name = 'MCONLINE_ReserveStatusUAT';
        web2.EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/reservenumber';
        weblist.add(web2);
        insert weblist;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        //contr.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
        contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
      	contr.Status='Active';
      	update contr;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        insert order;
        list<MCOnline_ParentBasket__c> parlist = new list<MCOnline_ParentBasket__c>();
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
        parlist.add(pbasket);
        
        
        /*MCOnline_ParentBasket__c pbasket2 = new MCOnline_ParentBasket__c();
pbasket2.TSCID__c = 'TSCID9808';
pbasket2.AgreementId__c = contr.Id;
pbasket2.Admin__c = UserInfo.getUserId();
//pbasket.Name = 'PBasket1';
//pbasket.OrderNumber__c = '';
pbasket2.Account__c = acc.Id;
pbasket2.UpdateOrderRequest__c = '';
pbasket2.CheckoutResponse__c = '';
//pbasket.Order__c = order.Id;
parlist.add(pbasket2);*/
        insert parlist;
        
        list<MCOnline_Basket__c> basketlist = new list<MCOnline_Basket__c>(); 
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket.TSCID__c = 'TSCID9808';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        basketlist.add(basket);
        MCOnline_Basket__c basket2 = new MCOnline_Basket__c();
        basket2.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket2.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket2.TSCID__c = 'TSCID9808';
        basket2.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket2.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket2.MCOnline_Contract__c = contr.Id;
        basket2.Account__c = acc.Id;
        basket2.MCOnline_ParentBasket__c = pbasket.Id;
        basketlist.add(basket2);      
        insert basketlist;
        
        String AccountId;
        String TSCID;
        String users;
        String Catalog;
        String Agreementid;
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<MCOnline_Basket__c> Parameters = new List<MCOnline_Basket__c>();
        users = 'testuser'; 
        acc = [select id,TSCID__c from Account where Name ='TestAccount'];
        AccountId = acc.id;
        TSCID = acc.TSCID__c;
        OrderTSCID = TSCID;  
        contr = [select id from Contract where AccountId =:AccountId];
        Agreementid = contr.id;
        options.put('Accountid',AccountId);
        options.put('TSCID',TSCID);
        options.put('users',users);
        options.put('Agreementid',Agreementid);
        options.put('Catalog',Catalog);
        List<Object> childProductslist = new list<Object>();
        List<Object> childProductslist1 = new list<Object>();
        Map<String,Object> Quantity = new Map<String,Object>();
        Quantity.put('Quantity','0');
        childProductslist1.add(Quantity);
        Map<String,Object> childProducts1 = new Map<String,Object>();
        childProducts1.put('childProducts',childProductslist1);
        Map<String,Object> link = new Map<String,Object>();
        /*set<string> Catalogset = new set<string>();
Catalogset.add('SUBSCRIPTIONS');
Catalogset.add('PROCESS');
Catalogset.add('MOBILEDEVICE');*/
        link.put('link','/v3/catalogs/SUBSCRIPTIONS/basket');
        childProducts1.put('rest',link);
        childProductslist.add(childProducts1);
        Map<String,Object> childProducts = new Map<String,Object>();
        childProducts.put('childProducts',childProductslist);
        childProducts.put('addtocart',childProducts1);
        Map<String,Object> offer = new Map<String,Object>();
        offer.put('offer',childProducts);
        inputMap.put('offerDetails',offer);
        list<Object> opplist = new list<object>();
        opplist.add(options);
        inputMap.put('productConfig', opplist );
        inputMap.put('basketLineRelationCount',opplist );
        inputMap.put('options',options );
        
        inputMap.put('contextKey','contextKey');
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> option = new Map<String,Object>();
        Map<String,Object> inputMap1 = new Map<String,Object>();
        inputMap1.put('options',options);
        inputMap1.put('contextKey','contextKey');
        output.put('cartContextKey',options);
        output.put('OrderId',order);
        output.put('records',basketlist);
        output.put('result',basketlist); 
        
        Map<String, String> inputMap2 = new Map<String, String>();
        inputMap2.put(basketlist[0].Id,JSON.serialize(inputMap));
        boolean isManagedFlow = true;
        
        try{
            //createAsynchBasketsBatch basket32 = new createAsynchBasketsBatch(inputMap2,inputMap1,orderDetails,OrderTSCID,OrderAgreementId,OrderUser);
            createAsynchBasketsBatch basket33 = new createAsynchBasketsBatch(inputMap2,inputMap1,orderDetails,OrderTSCID,OrderAgreementId,OrderUser,isManagedFlow);
            //createAsynchBasketsBatch basket34 = new createAsynchBasketsBatch(inputMap2,inputMap1,OrderTSCID,OrderAgreementId,OrderUser);
            //Id batchId = Database.executeBatch(basket32);
            Id batchId1 = Database.executeBatch(basket33);
            //Id batchId2 = Database.executeBatch(basket34);
        }catch(exception ex){
            
        }
        Test.stopTest();
    }
  @isTest
  static void batchName3() {
        // Map<String, String> inputMap = new Map<String, String>();
        // Map<String,Object> inputMap1 = new Map<String, Object>(); 
        Map<String, Object> orderDetails = new Map<String, Object>();
        string OrderTSCID;
        string OrderAgreementId;
        string OrderUser;
        Test.startTest();
        Map<String, Object> productConfigMap = new Map<String, Object>();  
        
        //   productConfigMap.put('{"offerDetails":{"offer":{"priceResult":[{"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"effectiveuntildatespec":null,"effectivefromdatespec":null,"RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring"}],"addtocart":{"rest":{"params":{"context":"{}","basketAction":"AddWithNoConfig","offer":null},"link":"v3/catalogs/PROCESS/basket","method":"POST"}},"Name":"Portering","ProductCode":"PORTIN_PROCESS","Product2Id":"01t9E00000BLYOMQA5","PricebookEntryId":"01u9E000017jmKwQAI","Quantity":1.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":1,"productHierarchyPath":"01t9E00000BLYOMQA5","lineNumber":"0001","AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":1,"messages":[],"records":[{"messages":[],"code":"Relation_Id","dataType":"text","inputType":"text","label":"Relation_Id","values":[{}],"userValues":null}]}}]},"Id":"01t9E00000BLYOMQA5","Description":null,"vlocity_cmt__SellingStartDate__c":"2021-10-01T08:30:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":true,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"offerbundle","C2BC_Subcategory__c":"mobilevoicesubscription","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":"Porting","childProducts":[{"priceResult":[{"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"effectiveuntildatespec":null,"effectivefromdatespec":null,"RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring"}],"Name":"Nummerflytt","ProductCode":"PORTIN_PROCESS_DATA","Product2Id":"01t9E00000BLYO6QAP","PricebookEntryId":"01u9E000017jmKgQAI","Quantity":1.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t9E00000BLYOMQA5<01t9E00000BLYO6QAP","lineNumber":"0001.0001","AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":11,"messages":[],"records":[{"messages":[],"code":"Contact_telephone_number","dataType":"text","inputType":"text","label":"Contact_telephone_number","values":[{}],"userValues":null},{"messages":[],"code":"Current_MSISDN","dataType":"text","inputType":"text","label":"Current_MSISDN","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_Organization","dataType":"text","inputType":"text","label":"Current_owner_Organization","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_SSN","dataType":"text","inputType":"text","label":"Current_owner_SSN","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_email","dataType":"text","inputType":"text","label":"Current_owner_email","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_first_name","dataType":"text","inputType":"text","label":"Current_owner_first_name","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_last_name","dataType":"text","inputType":"text","label":"Current_owner_last_name","values":[{}],"userValues":null},{"messages":[],"code":"External_reference","dataType":"text","inputType":"text","label":"External_reference","values":[{}],"userValues":null},{"messages":[],"code":"Temporary_MSISDN","dataType":"text","inputType":"text","label":"Temporary_MSISDN","values":[{}],"userValues":null},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","label":"User_name","values":[{}],"userValues":null},{"messages":[],"code":"ownerPhoneNumber","dataType":"text","inputType":"text","label":"ownerPhoneNumber","values":[{}],"userValues":null}]}}]},"Id":"01t9E00000BLYO6QAP","Description":null,"vlocity_cmt__SellingStartDate__c":"2021-10-01T08:30:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"mobilevoicesubscription","C2BC_Subcategory__c":"portin","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null}],"offerType":"Product","vlocity_cmt__InCartQuantityMap__c":{"01t9E00000BLYO6QAP":1}}}}','test');
        // inputMap.put('test',JSON.serialize(productConfigMap));
        //  inputMap1.put('test',JSON.serialize(productConfigMap));
        
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID9808';
        Insert acc;
        list<WebService__c> weblist = new list<WebService__c>();
        WebService__c web = new WebService__c();
        web.Name = 'MCONLINE_ReserveStatus';
        web.EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/getreservedstatus';
        weblist.add(web);
        
        WebService__c web2 = new WebService__c();
        web2.Name = 'MCONLINE_ReserveStatusUAT';
        web2.EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/reservenumber';
        weblist.add(web2);
        insert weblist;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        //contr.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
        contr.Contract_Record_Type__c='Teliaavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
      	contr.Status='Active';
      	update contr;  
      
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        insert order;
        list<MCOnline_ParentBasket__c> parlist = new list<MCOnline_ParentBasket__c>();
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
        parlist.add(pbasket);
        
        
        /*MCOnline_ParentBasket__c pbasket2 = new MCOnline_ParentBasket__c();
pbasket2.TSCID__c = 'TSCID9808';
pbasket2.AgreementId__c = contr.Id;
pbasket2.Admin__c = UserInfo.getUserId();
//pbasket.Name = 'PBasket1';
//pbasket.OrderNumber__c = '';
pbasket2.Account__c = acc.Id;
pbasket2.UpdateOrderRequest__c = '';
pbasket2.CheckoutResponse__c = '';
//pbasket.Order__c = order.Id;
parlist.add(pbasket2);*/
        insert parlist;
        
        list<MCOnline_Basket__c> basketlist = new list<MCOnline_Basket__c>(); 
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket.TSCID__c = 'TSCID9808';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        basketlist.add(basket);
        MCOnline_Basket__c basket2 = new MCOnline_Basket__c();
        basket2.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket2.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket2.TSCID__c = 'TSCID9808';
        basket2.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket2.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket2.MCOnline_Contract__c = contr.Id;
        basket2.Account__c = acc.Id;
        basket2.MCOnline_ParentBasket__c = pbasket.Id;
        basketlist.add(basket2);      
        insert basketlist;
        
        String AccountId;
        String TSCID;
        String users;
        String Catalog;
        String Agreementid;
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<MCOnline_Basket__c> Parameters = new List<MCOnline_Basket__c>();
        users = 'testuser'; 
        acc = [select id,TSCID__c from Account where Name ='TestAccount'];
        AccountId = acc.id;
        TSCID = acc.TSCID__c;
        OrderTSCID = TSCID;  
        contr = [select id from Contract where AccountId =:AccountId];
        Agreementid = contr.id;
        options.put('Accountid',AccountId);
        options.put('TSCID',TSCID);
        options.put('users',users);
        options.put('Agreementid',Agreementid);
        options.put('Catalog',Catalog);
        List<Object> childProductslist = new list<Object>();
        List<Object> childProductslist1 = new list<Object>();
        Map<String,Object> Quantity = new Map<String,Object>();
        Quantity.put('Quantity','0');
        childProductslist1.add(Quantity);
        Map<String,Object> childProducts1 = new Map<String,Object>();
        childProducts1.put('childProducts',childProductslist1);
        Map<String,Object> link = new Map<String,Object>();
        /*set<string> Catalogset = new set<string>();
Catalogset.add('SUBSCRIPTIONS');
Catalogset.add('PROCESS');
Catalogset.add('MOBILEDEVICE');*/
        link.put('link','/v3/catalogs/SUBSCRIPTIONS/basket');
        childProducts1.put('rest',link);
        childProductslist.add(childProducts1);
        Map<String,Object> childProducts = new Map<String,Object>();
        childProducts.put('childProducts',childProductslist);
        childProducts.put('addtocart',childProducts1);
        Map<String,Object> offer = new Map<String,Object>();
        offer.put('offer',childProducts);
        inputMap.put('offerDetails',offer);
        list<Object> opplist = new list<object>();
        opplist.add(options);
        inputMap.put('productConfig', opplist );
        inputMap.put('basketLineRelationCount',opplist );
        inputMap.put('options',options );
        
        inputMap.put('contextKey','contextKey');
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> option = new Map<String,Object>();
        Map<String,Object> inputMap1 = new Map<String,Object>();
        inputMap1.put('options',options);
        inputMap1.put('contextKey','contextKey');
        output.put('cartContextKey',options);
        output.put('OrderId',order);
        output.put('records',basketlist);
        output.put('result',basketlist); 
        
        Map<String, String> inputMap2 = new Map<String, String>();
        inputMap2.put(basketlist[0].Id,JSON.serialize(inputMap));
        boolean isManagedFlow = true;
        
        try{
            //createAsynchBasketsBatch basket32 = new createAsynchBasketsBatch(inputMap2,inputMap1,orderDetails,OrderTSCID,OrderAgreementId,OrderUser);
            //createAsynchBasketsBatch basket33 = new createAsynchBasketsBatch(inputMap2,inputMap1,orderDetails,OrderTSCID,OrderAgreementId,OrderUser,isManagedFlow);
            createAsynchBasketsBatch basket34 = new createAsynchBasketsBatch(inputMap2,inputMap1,OrderTSCID,OrderAgreementId,OrderUser);
            //Id batchId = Database.executeBatch(basket32);
            //Id batchId1 = Database.executeBatch(basket33);
            Id batchId2 = Database.executeBatch(basket34);
        }catch(exception ex){
            
        }
        Test.stopTest();
    }
}