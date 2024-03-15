@isTest
public class MCOnline_QueueableAddtobasketV5Test {
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
    }
    @isTest
    static void batchName() {
        Map<String, String> inputMap = new Map<String, String>();
        Map<String,Object> inputMap1 = new Map<String, Object>(); 
        Map<String, Object> orderDetails = new Map<String, Object>();
        string OrderTSCID;
        string OrderAgreementId;
        string OrderUser;
        String parentId;
        Test.startTest();
        Map<String, Object> productConfigMap = new Map<String, Object>();        
        productConfigMap.put('{"offerDetails":{"offer":{"priceResult":[{"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"effectiveuntildatespec":null,"effectivefromdatespec":null,"RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring"}],"addtocart":{"rest":{"params":{"context":"{}","basketAction":"AddWithNoConfig","offer":null},"link":"v3/catalogs/PROCESS/basket","method":"POST"}},"Name":"Portering","ProductCode":"PORTIN_PROCESS","Product2Id":"01t9E00000BLYOMQA5","PricebookEntryId":"01u9E000017jmKwQAI","Quantity":1.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":1,"productHierarchyPath":"01t9E00000BLYOMQA5","lineNumber":"0001","AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":1,"messages":[],"records":[{"messages":[],"code":"Relation_Id","dataType":"text","inputType":"text","label":"Relation_Id","values":[{}],"userValues":null}]}}]},"Id":"01t9E00000BLYOMQA5","Description":null,"vlocity_cmt__SellingStartDate__c":"2021-10-01T08:30:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":true,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"offerbundle","C2BC_Subcategory__c":"mobilevoicesubscription","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":"Porting","childProducts":[{"priceResult":[{"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"effectiveuntildatespec":null,"effectivefromdatespec":null,"RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring"}],"Name":"Nummerflytt","ProductCode":"PORTIN_PROCESS_DATA","Product2Id":"01t9E00000BLYO6QAP","PricebookEntryId":"01u9E000017jmKgQAI","Quantity":1.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t9E00000BLYOMQA5<01t9E00000BLYO6QAP","lineNumber":"0001.0001","AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":11,"messages":[],"records":[{"messages":[],"code":"Contact_telephone_number","dataType":"text","inputType":"text","label":"Contact_telephone_number","values":[{}],"userValues":null},{"messages":[],"code":"Current_MSISDN","dataType":"text","inputType":"text","label":"Current_MSISDN","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_Organization","dataType":"text","inputType":"text","label":"Current_owner_Organization","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_SSN","dataType":"text","inputType":"text","label":"Current_owner_SSN","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_email","dataType":"text","inputType":"text","label":"Current_owner_email","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_first_name","dataType":"text","inputType":"text","label":"Current_owner_first_name","values":[{}],"userValues":null},{"messages":[],"code":"Current_owner_last_name","dataType":"text","inputType":"text","label":"Current_owner_last_name","values":[{}],"userValues":null},{"messages":[],"code":"External_reference","dataType":"text","inputType":"text","label":"External_reference","values":[{}],"userValues":null},{"messages":[],"code":"Temporary_MSISDN","dataType":"text","inputType":"text","label":"Temporary_MSISDN","values":[{}],"userValues":null},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","label":"User_name","values":[{}],"userValues":null},{"messages":[],"code":"ownerPhoneNumber","dataType":"text","inputType":"text","label":"ownerPhoneNumber","values":[{}],"userValues":null}]}}]},"Id":"01t9E00000BLYO6QAP","Description":null,"vlocity_cmt__SellingStartDate__c":"2021-10-01T08:30:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"mobilevoicesubscription","C2BC_Subcategory__c":"portin","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null}],"offerType":"Product","vlocity_cmt__InCartQuantityMap__c":{"01t9E00000BLYO6QAP":1}}}}','test');
        inputMap.put('test',JSON.serialize(productConfigMap));
        inputMap1.put('test',JSON.serialize(productConfigMap));
        try{
            MCOnline_QueueableAddtobasketV5 basket = new MCOnline_QueueableAddtobasketV5(inputMap,inputMap1,orderDetails,OrderTSCID,OrderAgreementId,OrderUser,parentId);
            MCOnline_QueueableAddtobasketV5 basket1 = new MCOnline_QueueableAddtobasketV5(inputMap,inputMap1,orderDetails,OrderTSCID,OrderAgreementId,OrderUser,false,parentId);
            System.enqueueJob(new MCOnline_QueueableAddtobasketV5(inputMap,inputMap1,orderDetails,OrderTSCID,OrderAgreementId,OrderUser,false,parentId));
            //Id batchId = Database.executeBatch(basket);
        }catch(exception ex){
            system.debug('catchexception==='+ex.getMessage());
        }
        Test.stopTest();
    }    
}