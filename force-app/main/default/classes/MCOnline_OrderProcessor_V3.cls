/* * ******************************************************************************************************
* @author         Binamra Guha
* @modifiedBy     Itishree Dash
* @maintainedBy   Itishree Dash/Lokesh Singh
* @version        
* 1.0
* @created        2022-02-14
* @modified       2023-10-11 [ Added invoke method to call in Omniscript- LTAT- 17060 ]
* ******************************************************************************************************/
global with sharing class MCOnline_OrderProcessor_V3 implements vlocity_cmt.VlocityOpenInterface2 {
    
    private static final String EXCEPTIONVAR = 'Exception';
    private static final String ACTIVATEORDER_ENDPOINT_NAME = 'MCONLINE_ActivateOrder';
    private static final String ACTIVATEORDER_ENDPOINT_NAME_UAT = 'MCONLINE_ActivateOrder_UAT';
    private static final String MCONLINE_ACTIVATEORDER_MOCK = 'MCONLINE_ActivateOrder_Mock';
    private static final String CONTENT = 'Content-Type';
    private static final String AUTHORIZATION = 'Authorization';
    private static final String BEARER = 'Bearer ';
    private static final String APPLICATION_JSON = 'application/json';
    private static final String ACCESSTOKEN = 'access_token';
    private static final Integer TIMEOUT = 120000;
    private static final Integer STATUSCODE_200 = 200;
    private static final string HTTP_METHOD = 'POST';
    private static final string OPA_RESPONE_STATUS_CODE = 'opa_ResponseStatusCode';
    private static final string OPA_RESPONSE = 'opa_Response';
    private static final string SUBMITORDER = 'submitOrder';
    private static final string GETORDERDETAILS = 'getOrderDetails';
    private static final string ORDERID = 'orderId';
    private static final string OPSTATUS = 'op_status';
    private static final string ACTIVATED = 'Activated';
    private static final string SUBMITTED = 'Submitted';
    public static Map<String, String> messageMap {get; set;}
    public static Set<String> orderIdList1 = new Set<String>();
    public static Map<String, String> orderTypeMap = new Map<String, String>();
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {           
        Boolean result = true;
        String errorMessage = '';
        
        try{    
            if(methodName.equalsIgnoreCase('processOrderRouterFuture')){
                String orderId =string.valueOf(inputMap.get('orderId'));
                Order order = [SELECT Id,MCOnline_Billing_Account__c, accountid,MCOnline_UserId__c from Order where id =:orderId];
                Map<String, String> tempMap = new Map<String, String>();
                tempMap.put('accountId',order.MCOnline_Billing_Account__c);
                tempMap.put('userId',order.MCOnline_UserId__c);
                inputMap.put('billingAccountDetails',tempMap); 
                MCOnline_OrderProcessor_V3.populateBND(orderId);
                processOrderRouterFuture(JSON.SerializE(inputMap),JSON.SerializE(outMap));                
                return true;
            }else{
                result = false;
            }
        }catch(Exception e){
            errorMessage = e.getMessage()+' line:'+ e.getLineNumber();
            outMap.put('Error', e.getStackTraceString());
            outMap.put('StatusCode', 500);
            MCOnline_Utility.logError(errorMessage,'500','MCOnline_OrderProcessor_V3, MCOnline_OrderProcessor_V3.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }
        return result;
    }
    
    public class OrderWrapper{
        public Map<String,Object> messages {get; set;}
        public Order order {get; set;}
    }
    public static String isNull(object obj){
        if(obj == null){
            return '';
        }else{
            return String.valueOf(obj);
        }
    }
    @Future(callout=true)
    public static void processOrderRouterFuture(string input, string output){
        Map<String,Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(input);
        //Map<String,Object> outMap = (Map<String, Object>) JSON.deserializeUntyped(output);
        Map<String,Object> outMap;
        Map<String, Map<String,Object>> outMapUpdated = new Map<String, Map<String,Object>>();
        string orderIdStringList = String.valueof(inputMap.get('orderId'));
        List<String> OrderIdList = orderIdStringList.split(',');
        //Looping for each Order for Mapping towards OP
        for(String orderId: OrderIdList){
            outMap= new Map<String, Object>();
            inputMap.put('orderId', orderId);
            submitOrder(orderId, inputMap, outMap);
            outMapUpdated.put(orderId, outMap);
            //invokeUpdateOrder_IntegrationProcedure(inputMap, outMap);
        }
        //Calling the IP for each OrderId
        for(String orderId: OrderIdList){
            inputMap.put('orderId', orderId);
            invokeUpdateOrder_IntegrationProcedure(inputMap, outMapUpdated.get(orderId));
        }
        updateOrderType(orderTypeMap);
        priceMatrixUpdate(OrderIdList);
        updateMSISDNStatusWithoutFuture(orderIdList1);
        updateCancelledServices(OrderIdList);
    }
    public static void updateCancelledServices(List<String> OrderIdList){
        Services_cancelled_in_MyBusiness__c cp = null;
        string str = '';
        List<Services_cancelled_in_MyBusiness__c> cproducts = new List<Services_cancelled_in_MyBusiness__c>();
        List<OrderItem> oitem = new List<OrderItem>();
        set<String> accountIdSet = new set<String>();
        oitem = [select id,MCONL_Action_Code__c ,Order.OrderNumber,OrderId,  Product2.Name, CreatedDate,Quantity, Order.AccountId,Order.MCOnline_FirstName__c, order.MCOnline_LastName__c from OrderItem where MCONL_Action_Code__c = 'Delete' and Product2.vlocity_cmt__SpecificationType__c = 'Product' and Product2.vlocity_cmt__ObjectTypeName__c !='Bundle' and OrderId in: OrderIdList];
        
        if(!oitem.isEmpty()){
            for(OrderItem pr:oitem){
                cp = new Services_cancelled_in_MyBusiness__c();
                cp.Quantity__c = pr.Quantity;
                cp.Cancelled_Date__c = pr.CreatedDate;
                cp.Order__c = pr.OrderId;
                cp.Product__c = pr.Product2Id;
                cp.Account__c = pr.Order.AccountId;
                str = pr.Order.MCOnline_FirstName__c+' '+pr.order.MCOnline_LastName__c;
                cp.User__c = str;
                cproducts.add(cp);
                accountIdSet.add(pr.Order.AccountId);
            }
            insert cproducts;
        }
        List<Services_cancelled_in_MyBusiness__c> countSCM =  [Select id,Account__c, Order__c from Services_cancelled_in_MyBusiness__c where Account__c =: accountIdSet];
        Map<Id,Integer> deletedAction = new Map<Id,Integer>();
        for(Services_cancelled_in_MyBusiness__c sc : countSCM){
            if(deletedAction.get(sc.Account__c) == null){
                deletedAction.put(sc.Account__c, 1);
            }else{
                deletedAction.put(sc.Account__c, deletedAction.get(sc.Account__c)+1);
            }
        }
        List<Account> accountsToBeUpdated = new List<Account>();
        for(Id accId : deletedAction.keySet()){
            Account acc = new Account();
            acc.Id = accId;
            acc.Number_of_services_Cancelled_in_MyB__c = deletedAction.get(accId);
            accountsToBeUpdated.add(acc);
        }
        try{
            if(accountsToBeUpdated.size() > 0){
                update accountsToBeUpdated;
            }
        }catch(Exception e){
            System.debug('Exception-->'+e.getStackTraceString());
        } 
    }
    public static void invokeUpdateOrder_IntegrationProcedure(Map<String,Object> dataInputMap, Map<String,Object> inputMap){
        Map<String,Object> inputMap1 = new Map<String,Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        string procedureName = 'MCONLINE_UpdateOrderDR_V3';
        inputMap1 = dataInputMap;
        inputMap1.put('RA_Order_Processor', inputMap);
        MCOnline_Utility.invokeIntegrationProcedure(procedureName, inputMap1, outMap, options);
    }
    public static void activateOrder(string orderNumber, Order order, Map<String,Object> outMap, Map<String, Object> accessMap){
        string endpoint;
        //Data Masking- Mock URL setup
        If(Label.MCONL_IsLowerOrg.equalsIgnoreCase('YES')){
            endpoint = WebService__c.getAll().get(MCONLINE_ACTIVATEORDER_MOCK).EndpointURL__c;
        }
        else if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
            endpoint = WebService__c.getAll().get(ACTIVATEORDER_ENDPOINT_NAME_UAT).EndpointURL__c+orderNumber;
        }else{
            endpoint = WebService__c.getAll().get(ACTIVATEORDER_ENDPOINT_NAME).EndpointURL__c+orderNumber;
        }
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(HTTP_METHOD);
        request.setTimeout(TIMEOUT);
        request.setHeader(CONTENT, APPLICATION_JSON);
        //if(!Test.isRunningTest()){
        request.setHeader(AUTHORIZATION, BEARER+accessMap.get(ACCESSTOKEN));
        //}
        Http http = new Http();
        if(order.MCONL_Order_Activation_Status_Code__c == null || order.MCONL_Order_Activation_Status_Code__c != string.valueOf('200')){
            HttpResponse response = null;
            //if(!Test.isRunningTest()){
            response = http.send(request);
            system.debug('response body : '+response.getBody());
            //}else{
            HttpResponse hr = new HttpResponse();
            hr.setStatusCode(200);
            hr.setBody('{"abc":"abc"}');
            response = hr;
            //}
            
            outMap.put('opa_ResponseStatusCode', response.getStatusCode());
            if(response != null && response.getStatusCode() != null && response.getStatusCode() == STATUSCODE_200){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                outMap.put('opa_Response', JSON.deserializeUntyped(response.getBody()));
                outMap.put('op_status', ACTIVATED);
                if(System.isBatch()){
                    //updateMSISDNStatusWithoutFuture(String.valueOf(order.Id));
                    orderIdList1.add(String.valueOf(order.Id));
                }else{
                    //updateMSISDNStatus(String.valueOf(order.Id));
                }
                
            }else{
                outMap.put('opa_Response', JSON.deserializeUntyped(response.getBody()));
            }
        }
    }
    public static void updateMSISDNStatusWithoutFuture(Set<string> orderId){
        List<OrderItem> oItemList = [select id, MCOnline_MSISDN__c from OrderItem where OrderId IN:orderId];
        Set<String> msisdnSet = new Set<String>();
        for(OrderItem oItem : oItemList){
            if(oItem != null){
                if(oItem.MCOnline_MSISDN__c != null){
                    msisdnSet.add(oItem.MCOnline_MSISDN__c);
                }
            }
        }
        List<MCONL_MSISDN__c> msisdnList = [select id, Status__c from MCONL_MSISDN__c where Number__c in :msisdnSet order by createddate desc];
        List<MCONL_MSISDN__c> msisdnListToBeUpdated = new List<MCONL_MSISDN__c>();
        for(MCONL_MSISDN__c msisdnObj : msisdnList){
            msisdnObj.Status__c = 'Ordered';
            msisdnListToBeUpdated.add(msisdnObj);
        }
        if(msisdnListToBeUpdated != null && msisdnListToBeUpdated.size() > 0){
            update msisdnListToBeUpdated;
        }
    }
    //Added 18/08/2021------------
    public static void updateOrderType(Map<String, String> orderTypeMap){
        string msg = '';
        Set<String> orderIdSet = new Set<String>();
        Set<Id> IdOrderIDSet = new Set<Id>();
        List<Order> orderList = new List<Order>();
        for(String orderId: orderTypeMap.keySet()){
            orderIdSet.add(orderId);
            IdOrderIDSet.add(id.ValueOf(orderId));
        }
        List<Order> order = [Select id, PriceMatrixValidationMessage__c, Type From Order Where Id IN :orderIdSet];
        list<MCOnline_Basket__c> basketstoUpdate = [select Id, MCOnline_Orders__c, MCOnline_Price_Validation_Message__c from MCOnline_Basket__c where MCOnline_Orders__r.Id IN :IdOrderIDSet];
        for(MCOnline_Basket__c bskt: basketstoUpdate){
            if(bskt.MCOnline_Price_Validation_Message__c != null || !(string.isEmpty(bskt.MCOnline_Price_Validation_Message__c))){
                msg= msg + bskt.id + ':' + bskt.MCOnline_Price_Validation_Message__c + ',';
            }
            
        }
        for(Order ord:order){
            ord.Type = orderTypeMap.get(ord.Id);
            ord.PriceMatrixValidationMessage__c = msg;
            orderList.add(ord);
        }
        Database.update(orderList, false);
        
    }
    public static void priceMatrixUpdate(List<String> IdOrderIDSet)
    {
        string msg = '';
        List<Order> orderList = new List<Order>();
        List<Order> order = [Select id, PriceMatrixValidationMessage__c, Type From Order Where Id IN :IdOrderIDSet];
        list<MCOnline_Basket__c> basketstoUpdate = [select Id, MCOnline_Orders__c, MCOnline_Price_Validation_Message__c from MCOnline_Basket__c where MCOnline_Orders__r.Id IN :IdOrderIDSet];
        for(MCOnline_Basket__c bskt: basketstoUpdate){
            if(bskt.MCOnline_Price_Validation_Message__c != null || !(string.isEmpty(bskt.MCOnline_Price_Validation_Message__c))){
                msg= msg + bskt.id + ':' + bskt.MCOnline_Price_Validation_Message__c + ',';
            }
        }
        for(Order ord:order)
        {
            ord.PriceMatrixValidationMessage__c = msg;
            orderList.add(ord);
        }
        Database.update(orderList, false);
    }
    //------------------
    public static string getValue(object value1, object value2){
        if(value1 != null){
            return String.ValueOf(value1);
        }else if(value2 != null){
            return String.ValueOf(value2);
        }else{
            return null;
        }
    }
    
    public static void submitOrder(string orderId, Map<String, Object> inputMap, Map<String, Object> outMap){
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> resultMap = new Map<String, Object>();
        try{
            List<Order> orderList  = new List<Order>();
            if((orderId != null || orderId != '') && (orderId.length() == 15 || orderId.length() == 18)){
                orderList = [SELECT Id, MCOnline_OrderNumber__c,vlocity_cmt__OrderStatus__c, MCONL_Order_Activation_Response__c, MCONL_Order_Activation_Status_Code__c,AccountId, status, OrderProcessor_Response__c, OrderProcessor_Request__c, OrderProcessor_ResponseStatusCode__c, MCOnline_ContractNumber__c, MCOnline_ContactMethod__c, McOnline_EmailAddress__c, MCOnline_FirstName__c, MCOnline_LastName__c, MCOnline_PhoneNumber__c, MCOnline_ResellerId__c, MCOnline_RetailerId__c, MCOnline_SalesChannel__c, MCOnline_SalesChannelId__c, MCOnline_UserId__c, Description, OrderNumber, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, TeliaSE_Shipping_Point_Id__c, Type, vlocity_cmt__DueDate__c, vlocity_cmt__ShippingName__c, Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingStateCode, Account.BillingCountryCode, Account.BillingLatitude, Account.BillingLongitude, Account.BillingGeocodeAccuracy, Account.BillingAddress, Account.Name, Account.Org_Nr__c, Account.TSCID__c FROM Order WHERE Id = :orderId limit 1];
                if(orderList != null && orderList.size() > 0){
                    outMap.put('status', true);
                    submitOrder1(orderList[0].Id, inputMap, outMap);
                }else if(orderList == null || orderList.size() == 0){
                    outMap.put('status', false);
                    errorMap.put('message','OrderId is not available.');
                    errorMap.put('errorCode','INVOKE-400');
                    errorMap.put('success',false);
                    outMap.put('OrderProcessorErrorMessage', errorMap);
                }
            }
            else{
                outMap.put('status', false);
                errorMap.put('message','OrderId is not available.');
                errorMap.put('errorCode','INVOKE-400');
                errorMap.put('success',false);
                outMap.put('OrderProcessorErrorMessage', errorMap);
            }
        }catch(Exception e){
            system.debug(String.valueOf(e.getMessage()+', Exception Trace:'+ e.getStackTraceString()));
            outMap.put('status', false);
        }
        
    }
    public static void submitOrder1(string orderId, Map<String,Object> inputMap, Map<String,Object> outMap){
        messageMap = new Map<String, String>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> resultMap = new Map<String, Object>();
        
        if(orderId == null || orderId==''){
            messageMap.put('OrderIdNotFound', 'orderId is required field.');
        }else{
            List<AuthSession> AuthSessionList = [SELECT Id, SourceIp FROM AuthSession WHERE UsersId = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];
            
            string ipaddress = (AuthSessionList != null || AuthSessionList.size() > 0) ? AuthSessionList[0].SourceIp : null;
            
            Order order = [SELECT Id, MCOnline_StreetNumber__c,Total_VAT_amount__c,Total_recurring_charge_amount__c,Total_one_time_fee_amount__c,  MCOnline_OrderComment__c, MCOnline_Billing_Account__c, MCOnline_OrderNumber__c, vlocity_cmt__OrderStatus__c, MCONL_Order_Activation_Response__c, MCONL_Order_Activation_Status_Code__c, AccountId, status, OrderProcessor_Response__c, OrderProcessor_Request__c, OrderProcessor_ResponseStatusCode__c, MCOnline_ContractNumber__c, MCOnline_ContactMethod__c, McOnline_EmailAddress__c, MCOnline_FirstName__c, MCOnline_LastName__c, MCOnline_PhoneNumber__c, MCOnline_ResellerId__c, MCOnline_RetailerId__c, MCOnline_SalesChannel__c, MCOnline_SalesChannelId__c, MCOnline_UserId__c, Description, OrderNumber, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, TeliaSE_Shipping_Point_Id__c, Type, vlocity_cmt__DueDate__c,MCOnline_Order_Due_Date__c, vlocity_cmt__ShippingName__c, Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingStateCode, Account.BillingCountryCode, Account.BillingLatitude, Account.BillingLongitude, Account.BillingGeocodeAccuracy, Account.BillingAddress, Account.Name, Account.Org_Nr__c, Account.TSCID__c, MCOnline_ShippingAttention__c,contractId FROM Order WHERE Id = :orderId limit 1];
            
            if(order == null){
                errorMap = new Map<String, Object>();
                resultMap = new Map<String, Object>();
                
                errorMap.put('message','Order '+order.Id+' is not available.');
                errorMap.put('errorCode','INVOKE-400');
                //resultMap.put('result',errorMap);
                errorMap.put('success',false);
                outMap.put('status', false);
                outMap.put('OrderProcessorErrorMessage', errorMap);
            }
            if((order.vlocity_cmt__OrderStatus__c != null && order.vlocity_cmt__OrderStatus__c.equalsIgnoreCase(ACTIVATED)) || (order.MCONL_Order_Activation_Status_Code__c != null && order.MCONL_Order_Activation_Status_Code__c.equalsIgnoreCase('200'))){
                errorMap = new Map<String, Object>();
                resultMap = new Map<String, Object>();
                
                errorMap.put('message','OrderId '+order.Id+' is already activated.');
                errorMap.put('errorCode','INVOKE-400');
                //resultMap.put('result',errorMap);
                errorMap.put('success',false);
                outMap.put('status', false);
                outMap.put('OrderProcessorErrorMessage', errorMap);
            }
            List<Contract> contractList = new List<Contract>();
            if(order.vlocity_cmt__OrderStatus__c != 'Activated'){
                Set<Id> agreementIdList = new Set<Id>{order.ContractId};
                for(MCOnline_Basket__c bas : [Select id, MCOnline_ParentBasket__r.AgreementId__c, MCOnline_Orders__c, MCOnline_Contract__c  from MCOnline_Basket__c Where MCOnline_Orders__c =:order.Id]){
                    if(bas.MCOnline_ParentBasket__r.AgreementId__c != null){
                        agreementIdList.add(bas.MCOnline_ParentBasket__r.AgreementId__c);
                    }
                    else if(bas.MCOnline_Contract__c != null){
                        agreementIdList.add(bas.MCOnline_Contract__c);
                    }
                }
                contractList = [SELECT id, ContractNumber, Agreement_Nr__c, Org_Nr__c, Contract_Record_Type__c FROM Contract WHERE status = 'Active' AND Id IN:agreementIdList AND RecordType.Name IN ('Ramavtal', 'RAM ReadOnly','EMR ReadOnly','MFA ReadOnly')];
                
                if(contractList == null || contractList.size() == 0){
                    errorMap = new Map<String, Object>();
                    resultMap = new Map<String, Object>();
                    
                    if(order.AccountId == null){
                        errorMap.put('message','Contract is not active.');
                    }else{
                        errorMap.put('message','Contract is not active for account '+order.AccountId);
                    }
                    errorMap.put('errorCode','INVOKE-400');
                    //resultMap.put('result',errorMap);
                    errorMap.put('success',false);
                    outMap.put('OrderProcessorErrorMessage', errorMap);
                }
                Map<String, Object> billingAccountMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inputMap.get('billingAccountDetails')));
                //added 18/08/2021-------
                //Getting the configurable Offers from custom setting for Split basket Logic
                Map<String, Checkout_Offer__c> offerMap = Checkout_Offer__c.getAll();
                String portIn = (offerMap.get('PORTIN_PROCESS').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS').OfferCode__c: null;
                String portInData = (offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('PORTIN_PROCESS_DATA').OfferCode__c: null;
                String transferOffer = (offerMap.get('TRANSFER_PROCESS').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS').OfferCode__c: null;
                String transferOfferData = (offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c!=null) ? offerMap.get('TRANSFER_PROCESS_DATA').OfferCode__c: null;
                //--------------
                List<OrderItem> items = [SELECT Id, MCONL_Additional_Charge__c,MCOnline_ExternalRef__c,MCOnline_Basket_Relation_Id__c, MCONL_Action_Code__c,vlocity_cmt__RootItemId__c, MCOnline_UserName__c,MCONL_multiSubscriptionAssetIdentifier__c,vlocity_cmt__OneTimeCharge__c,MConline_List_Price__c,vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__RecurringCharge__c,MCOnline_Billing_Account__c , MCOnline_ServiceValue__c, MCOnline_ServiceCode__c, MCOnline_ContractId__c, MCOnline_ContractNumber__c, MCOnline_MSISDN__c, MCOnline_CommitmentPeriod__c, MCOnline_CommitmentUnit__c, Quantity, vlocity_cmt__Action__c, vlocity_cmt__OneTimeCost__c, vlocity_cmt__ParentItemId__c,vlocity_cmt__Product2Id__r.Feature_Id__c, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.C2BC_Category__c, vlocity_cmt__Product2Id__r.C2BC_Subcategory__c, vlocity_cmt__Product2Id__r.MCOnline_ShowInSummary__c, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.Ordering_System__c, vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c,vlocity_cmt__Product2Id__r.Downstream_CategoryData__c, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c FROM OrderItem where OrderId = :order.Id AND vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c not in ('Bundle', 'Bundle/offer', 'Offer') order by id ];
                
                List<OrderItem> itemList = [select id,vlocity_cmt__RootItemId__c, vlocity_cmt__Product2Id__r.ProductCode from OrderItem where Order.Id = :order.Id  AND vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c not in ('Bundle', 'Bundle/offer', 'Offer') order by id];
                //MCONL-8762: Subscription Usernamre value on Data SIM to OP
                Map<String, String> datasimMap = new Map<String, String>();
                Map<String, String> datasimMap1 = new Map<String, String>();
                Map<String, String> instanceIdMap = new Map<String, String>();
                Integer i = 1, j=1;
                Map<String, Integer> orderMap = new Map<String, Integer>();
                Map<String, Integer> parentIdMap = new Map<String, Integer>();
                for(OrderItem item : itemList){
                    if(parentIdMap!= null && parentIdMap.containsKey(item.vlocity_cmt__RootItemId__c)){
                        parentIdMap.put(item.vlocity_cmt__RootItemId__c, parentIdMap.get(item.vlocity_cmt__RootItemId__c));
                    }else{
                        parentIdMap.put(item.vlocity_cmt__RootItemId__c, j);
                        j= j+1;
                    }
                    orderMap.put(String.valueOf(item.id), i);
                    i = i+1;
                }
                Map<String, String> subRootIdMap = new Map<String, String>();
                for(OrderItem itm: items)
                {
                    if(itm.MCOnline_Basket_Relation_Id__c != null && getAttribute('User_name', itm.vlocity_cmt__AttributeSelectedValues__c) != null && itm.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'voice')
                    {
                        datasimMap.put(itm.MCOnline_Basket_Relation_Id__c, getAttribute('User_name', itm.vlocity_cmt__AttributeSelectedValues__c));
                    }
                    else if(itm.MCOnline_Basket_Relation_Id__c != null && getJsonAttribute('User_name', itm.vlocity_cmt__JSONAttribute__c) != null && itm.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'voice')
                    {
                        datasimMap.put(itm.MCOnline_Basket_Relation_Id__c, getJsonAttribute('User_name', itm.vlocity_cmt__JSONAttribute__c));
                    }
                    if(itm.MCOnline_Basket_Relation_Id__c != null && getAttribute('EXT_REF_ONLINE', itm.vlocity_cmt__AttributeSelectedValues__c) != null && itm.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'voice')
                    {
                        datasimMap1.put(itm.MCOnline_Basket_Relation_Id__c, getAttribute('EXT_REF_ONLINE', itm.vlocity_cmt__AttributeSelectedValues__c));
                    }
                    else if(itm.MCOnline_Basket_Relation_Id__c != null && getJsonAttribute('EXT_REF_ONLINE', itm.vlocity_cmt__JSONAttribute__c) != null && itm.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'voice')
                    {
                        datasimMap1.put(itm.MCOnline_Basket_Relation_Id__c, getJsonAttribute('EXT_REF_ONLINE', itm.vlocity_cmt__JSONAttribute__c));
                    }
                    if(itm.MCOnline_Basket_Relation_Id__c != null && getAttribute('instanceId', itm.vlocity_cmt__AttributeSelectedValues__c) != null && itm.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'ucuser')
                    {
                        instanceIdMap.put(itm.MCOnline_Basket_Relation_Id__c, getAttribute('instanceId', itm.vlocity_cmt__AttributeSelectedValues__c));
                    }
                    else if(itm.MCOnline_Basket_Relation_Id__c != null && getJsonAttribute('instanceId', itm.vlocity_cmt__JSONAttribute__c) != null && itm.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'ucuser')
                    {
                        instanceIdMap.put(itm.MCOnline_Basket_Relation_Id__c, getJsonAttribute('instanceId', itm.vlocity_cmt__JSONAttribute__c));
                    }
                    if(itm.vlocity_cmt__RootItemId__c != null && itm.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c != null && String.valueOf(itm.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c).equalsIgnoreCase('90')){
                        subRootIdMap.put(itm.vlocity_cmt__RootItemId__c, itm.vlocity_cmt__Product2Id__r.ProductCode + '-' +itm.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c);
                    }
                }
                
                Set<String> orderItems = new Set<String>();
                for(OrderItem item1 : itemList){
                    orderItems.add(item1.vlocity_cmt__Product2Id__r.ProductCode);
                }
                /*--------------New List price mapping logic(MCONL-8625)----------------*/
                List<vlocity_cmt__PriceListEntry__c> pricelist =[select id,vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c,vlocity_cmt__ProductId__r.C2BC_Category__c, vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.Name, vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c, vlocity_cmt__ProductId__r.ProductCode from vlocity_cmt__PriceListEntry__c where vlocity_cmt__IsActive__c = true AND vlocity_cmt__PriceListId__r.Name = 'Online Pricelist' AND vlocity_cmt__ProductId__r.ProductCode IN :orderItems ];
                Map<String, decimal> subscriptionPriceList = new Map<String, decimal>();
                Map<String, decimal> hardwarePriceList = new Map<String, decimal>();
                for(vlocity_cmt__PriceListEntry__c pList : pricelist){
                    if(pList.vlocity_cmt__ProductId__r.C2BC_Category__c == 'goods' && pList.vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c == 'One-time'){
                        hardwarePriceList.put(pList.vlocity_cmt__ProductId__r.ProductCode, pList.vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c);
                    }
                    if(pList.vlocity_cmt__ProductId__r.C2BC_Category__c != 'goods' && pList.vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c == 'Recurring'){
                        subscriptionPriceList.put(pList.vlocity_cmt__ProductId__r.ProductCode, pList.vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c);
                    }
                }
                /*------------------------------------------------------*/
                
                Map<String, HW_VAT__c> HWVATMap = HW_VAT__c.getAll();
                Decimal vatRate = (HWVATMap.get('VatRate').VAT_Rate_Percentage__c!=null) ? HWVATMap.get('VatRate').VAT_Rate_Percentage__c: null;
                
                OrderRequestWrapper oRequestWrapper = new OrderRequestWrapper();
                oRequestWrapper.brand = 'TELIA'; 
                oRequestWrapper.modelVersion = 'v1';
                // oRequestWrapper.requestedDueDate = isNull(String.valueOf(Date.Today()));
                // MCONL-14772 (12838BF) Checkout: Manage several due dates and order split for port-in orders
                //oRequestWrapper.requestedDueDate = String.valueOf(order.MCOnline_Order_Due_Date__c);
                oRequestWrapper.requestedDueDate = isNull(getValue(String.valueOf(inputMap.get('dueDate')), String.valueOf(order.MCOnline_Order_Due_Date__c)));
                //added 18/08/2021-------
                if(orderItems.contains(portIn) && orderItems.contains(portInData)){
                    oRequestWrapper.orderType = 'MODIFY';
                    orderTypeMap.put(String.valueOf(order.Id), oRequestWrapper.orderType);
                }
                else{
                    oRequestWrapper.orderType = (String.valueOf(inputMap.get('orderType')) != null) ? String.valueOf(inputMap.get('orderType')) : order.Type;
                }
                //-------------
                if(orderItems.contains(portIn) && orderItems.contains(portInData)){
                    oRequestWrapper.orderScenario = 'PORT_IN';
                }
                else if(orderItems.contains(transferOffer) && orderItems.contains(transferOfferData)){
                    oRequestWrapper.orderScenario = 'TRANSFER';
                }
                oRequestWrapper.orderNumber = order.MCOnline_OrderNumber__c !=null?order.MCOnline_OrderNumber__c:[Select IsSandbox from Organization].IsSandbox?'UAT-'+order.OrderNumber:'CO-'+order.OrderNumber;
                
                OrderData orderData = new OrderData();
                //MCONL-5635 Config Order_comment mapping OP
                OrderDataAttributes attObj = new OrderDataAttributes();
                attObj.communicationLanguage = String.valueOf(inputMap.get('languageCode'));
                orderData.attributes = attObj;
                
                //MCONL-7857
                TotalPrice totalPrice = new TotalPrice();
                totalPrice.oneTimeFeeAmount = (order.Total_one_time_fee_amount__c).setScale(2);
                totalPrice.recurringChargeAmount = (order.Total_recurring_charge_amount__c).setScale(2);
                totalPrice.vatAmount = (order.Total_VAT_amount__c).setScale(2);
                orderData.totalPrice = totalPrice;
                
                List<Agreement> agreements = new List<Agreement>();
                Integer count=2;
                //changes done as part of MCONL-15199
                Map<String, Contract> contractMap = new Map<String, Contract>();
                if(contractList != null && contractList.size() > 0){
                    for(Contract con: contractList){
                        if(String.valueOf(con.Contract_Record_Type__c) != null && String.valueOf(con.Contract_Record_Type__c).equalsIgnoreCase('Ramavtal'))
                            contractMap.put(String.valueOf(con.Contract_Record_Type__c)+'-'+String.valueOf(con.ContractNumber), con);
                    }
                }
                if(contractMap.isEmpty()){ 
                    count = count - 2;
                }
                List<Integer> orderAgreement = new List<Integer>();
                Map<Integer, Agreement> orderAgreementMap = new Map<Integer, Agreement>();
                for(Contract con: contractList){
                    Agreement agreement = new Agreement();
                    Agreement agreement1 = new Agreement();
                    
                    if(contractMap != null && contractMap.containsKey(String.valueOf(con.Contract_Record_Type__c)+'-'+String.valueOf(con.ContractNumber))){
                        agreement.id = 1;
                        agreement.idString = isNull(con.ContractNumber);
                        agreement.additionalInfo = 'SALESFORCE';
                        
                        agreement1.id = 2;
                        agreement1.idString = isNull(con.Agreement_Nr__c);
                        agreement1.additionalInfo = 'MADAM';
                    }else{
                        agreement.id = count+1;
                        agreement.idString = isNull(con.ContractNumber);
                        agreement.additionalInfo = 'SALESFORCE';
                        
                        agreement1.id = count+2;
                        agreement1.idString = isNull(con.Agreement_Nr__c);
                        agreement1.additionalInfo = 'MADAM';
                        count = count+2;
                    }
                    orderAgreement.add(agreement.id);
                    orderAgreement.add(agreement1.id);
                    orderAgreementMap.put(agreement.id, agreement);
                    orderAgreementMap.put(agreement1.id, agreement1);
                }
                if(orderAgreement != null && orderAgreement.size() > 0)
                {
                    orderAgreement.sort();
                }
                if(orderAgreement != null && orderAgreementMap != null){
                    for(Integer con : orderAgreement){
                        if(orderAgreementMap.get(con) != null){
                            agreements.add(orderAgreementMap.get(con));
                        }
                    }
                }
                orderData.agreements = agreements;
                
                BusinessCustomer businessCustomer = new BusinessCustomer();
                businessCustomer.tscId = isNull(order.Account.TSCID__c);
                businessCustomer.organisationNumber = isNull(order.Account.Org_Nr__c);
                businessCustomer.name = isNull(order.Account.Name);
                
                LegalAddress legalAddress = new LegalAddress();
                legalAddress.street = isNull(order.Account.BillingStreet);
                legalAddress.postalCode = isNull(order.Account.BillingPostalCode);
                legalAddress.country = isNull(order.Account.BillingCountry);
                legalAddress.city = isNull(order.Account.BillingCity);
                businessCustomer.legalAddress = legalAddress;
                
                orderData.businessCustomer = businessCustomer;
                
                ShippingAddress shipping    = new ShippingAddress();
                shipping.pointId            = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('pointId')) : null;
                shipping.street             = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('street')) : null;
                shipping.postalCode         = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('postalcode')) : null;
                shipping.city               = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('city')) : null;
                shipping.attention          = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('attention')) : null;
                shipping.country            = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('country')) : null;
                shipping.streetNumber       = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('streetNumber')) : null;
                shipping.name               = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('name')) : null;
                shipping.entrance           = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('entrance')) : null;
                shipping.apartmentNumber    = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('careOf')) : null;
                shipping.careOf             = (inputMap.get('shippingAddress') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('shippingAddress')).get('apartmentNumber')) : null;
                orderData.shippingAddress   = shipping;
                
                SalesTracking salesTracking = new SalesTracking();
                TracingDetails tracingDetails = new TracingDetails();
                salesTracking.retailerId = (inputMap.get('salesTracking') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('salesTracking')).get('retailerId')) : null;
                salesTracking.resellerId = (inputMap.get('salesTracking') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('salesTracking')).get('resellerId')) : null;
                salesTracking.userId = (inputMap.get('salesTracking') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('salesTracking')).get('userId')) : null;
                salesTracking.salesChannelId = (inputMap.get('salesTracking') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('salesTracking')).get('salesChannelId')) : null;
                salesTracking.salesChannel = (inputMap.get('salesTracking') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('salesTracking')).get('salesChannel')) : null;
                
                tracingDetails.originClientIP = isNull(ipaddress);
                orderData.tracingDetails = tracingDetails;
                orderData.salesTracking = salesTracking;
                
                ContactDetails contactDetails           = new ContactDetails();
                contactDetails.acceptUnencryptedEmail   = 'true';
                contactDetails.contactMethod            = 'POST';
                contactDetails.phoneNumber              = (inputMap.get('contactDetails') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('contactDetails')).get('phoneNumber')) : null;
                contactDetails.lastName                 = (inputMap.get('contactDetails') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('contactDetails')).get('lastName')) : null;
                contactDetails.firstName                = (inputMap.get('contactDetails') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('contactDetails')).get('firstName')) : null;
                contactDetails.emailAddress             = (inputMap.get('contactDetails') != null) ? String.valueOf(((Map<String, Object>)inputMap.get('contactDetails')).get('emailAddress')) : null;
                orderData.contactDetails                = contactDetails;
                
                
                BillingAccountDetails billingAccountDetails = new BillingAccountDetails();
                if(getValue(order.MCOnline_Billing_Account__c, String.valueOf(billingAccountMap.get('accountId'))) != null){
                    billingAccountDetails.accountId = isNull(getValue(order.MCOnline_Billing_Account__c, String.valueOf(billingAccountMap.get('accountId'))));
                    orderData.billingAccountDetails = billingAccountDetails;
                }
                //orderData.orderDescription = order.Description;
                orderData.orderDescription = String.valueOf(inputMap.get('orderDescription'));
                //As part of the story MCONL-9316 credit check not required
                if(orderItems.contains(portIn) && orderItems.contains(portInData)){
                    orderData.scenario = 'PORT_IN';
                }
                else if(orderItems.contains(transferOffer) && orderItems.contains(transferOfferData)){
                    orderData.scenario = 'TRANSFER';
                }
                List<OrderLine> orderLines = new List<OrderLine>();
                //Lists for Agent,UserGroup and directoryField attributes
                List<vlocity_cmt__Attribute__c> attr = [Select id, vlocity_cmt__Code__c from vlocity_cmt__Attribute__c Where vlocity_cmt__Code__c LIKE '%cdgIdentifyingNumber%'];
                List<vlocity_cmt__Attribute__c> UGAttr = [Select id, vlocity_cmt__Code__c from vlocity_cmt__Attribute__c Where vlocity_cmt__Code__c LIKE '%_action%'];
                List<vlocity_cmt__Attribute__c> DFAttr = [Select id, vlocity_cmt__Code__c from vlocity_cmt__Attribute__c Where vlocity_cmt__Code__c LIKE '%directoryField%'];
                for(OrderItem oitem : items){
                    OrderLine orderLine = new OrderLine();
                    orderLine.dueDate = String.valueOf(Date.Today());
                    
                    GsmAhsService gsmAhsService = new  GsmAhsService();
                    GsmAhsSubscription gsmAhsSubscription = new  GsmAhsSubscription();
                    
                    //gsmAhsService
                    list<String> ProductServiceCodes = (oitem.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c != null) ? oitem.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c.split('-') : null;
                    string serviceCode =  (ProductServiceCodes != null && ProductServiceCodes.size() > 0) ? ProductServiceCodes[0] : null;
                    //Convering the GPRS code into HOME //MCONL-11821
                    if(subRootIdMap != null && !subRootIdMap.containsKey(oitem.vlocity_cmt__RootItemId__c))
                    {
                        if(serviceCode == 'GPRS')
                        {
                            serviceCode='HOME';
                        }
                    }
                    string serviceValue = (ProductServiceCodes != null && ProductServiceCodes.size() > 1) ? ProductServiceCodes[1] : null;
                    if(oitem.vlocity_cmt__Product2Id__r.Ordering_System__c != 'madam')
                    {
                        gsmAhsService.serviceValue = isNull(serviceValue);
                        gsmAhsService.serviceCode = isNull(serviceCode);
                    }
                    
                    //gsmAhsSubscription
                    list<String> ProductSubscriptionType = (oitem.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c != null) ? oitem.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c.split('-') : null;
                    string subscriptionCode =  (ProductSubscriptionType != null && ProductSubscriptionType.size() > 0) ? ProductSubscriptionType[0] : null;
                    string multiSubscriptionCode = (ProductSubscriptionType != null && ProductSubscriptionType.size() > 1) ? ProductSubscriptionType[1] : null;
                    
                    gsmAhsSubscription.subscriptionCode = isNull(subscriptionCode);
                    gsmAhsSubscription.multiSubscriptionCode = isNull(multiSubscriptionCode);
                    if(String.isNotBlank(oitem.MCONL_Additional_Charge__c))
                    {
                        gsmAhsSubscription.additionalCharge=oitem.MCONL_Additional_Charge__c;
                    }
                    
                    
                    Integer z;
                    List<Agents> agentList = new List<Agents>();
                    for(z=1; z<=attr.size();z++)
                    {
                        if(String.isNotBlank(String.valueOf(getAttribute('agentList'+z+'_cdgIdentifyingNumber', oitem.vlocity_cmt__AttributeSelectedValues__c))) || String.valueOf(getAttribute('agentList'+z+'_cdgAgentLoggedIn', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null)
                        {
                            Agents agents1 = new Agents();
                            agents1.cdgIdentifyingNumber = (String.isNotBlank(String.valueOf(getAttribute('agentList'+z+'_cdgIdentifyingNumber', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('agentList'+z+'_cdgIdentifyingNumber', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                            agents1.cdgAgentLoggedIn = (String.valueOf(getAttribute('agentList'+z+'_cdgAgentLoggedIn', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null && String.valueOf(getAttribute('agentList'+z+'_cdgAgentLoggedIn', oitem.vlocity_cmt__AttributeSelectedValues__c)).equalsIgnoreCase('Y')) ? true : false;
                            agentList.add(agents1);
                        }
                        else if(String.isNotBlank(String.valueOf(getJsonAttribute('agentList'+z+'_cdgIdentifyingNumber', oitem.vlocity_cmt__JSONAttribute__c))) || String.valueOf(getJsonAttribute('agentList'+z+'_cdgAgentLoggedIn', oitem.vlocity_cmt__JSONAttribute__c)) != null)
                        {
                            Agents agents1 = new Agents();
                            agents1.cdgIdentifyingNumber = (String.isNotBlank(String.valueOf(getJsonAttribute('agentList'+z+'_cdgIdentifyingNumber', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('agentList'+z+'_cdgIdentifyingNumber', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                            agents1.cdgAgentLoggedIn = (String.valueOf(getJsonAttribute('agentList'+z+'_cdgAgentLoggedIn', oitem.vlocity_cmt__JSONAttribute__c)) != null && String.valueOf(getJsonAttribute('agentList'+z+'_cdgAgentLoggedIn', oitem.vlocity_cmt__JSONAttribute__c)).equalsIgnoreCase('Y')) ? true : false;
                            agentList.add(agents1);
                        }
                    }
                    //TPP UserGroup and DirectoryField attribute mapping     
                    Integer u;
                    List<Users> UserGroupList = new List<Users>();
                    for(u=1; u<=UGAttr.size();u++)
                    {
                        if(String.isNotBlank(String.valueOf(getAttribute('usergroup'+u+'_name', oitem.vlocity_cmt__AttributeSelectedValues__c))) || String.valueOf(getAttribute('usergroup'+u+'_action', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null)
                        {
                            Users users1 = new Users();
                            users1.name = (String.isNotBlank(String.valueOf(getAttribute('usergroup'+u+'_name', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('usergroup'+u+'_name', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                            users1.action = (String.valueOf(getAttribute('usergroup'+u+'_action', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null) ? isNull(getAttribute('usergroup'+u+'_action', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                            UserGroupList.add(users1);
                        }
                        else if(String.isNotBlank(String.valueOf(getJsonAttribute('usergroup'+u+'_name', oitem.vlocity_cmt__JSONAttribute__c))) || String.valueOf(getJsonAttribute('usergroup'+u+'_action', oitem.vlocity_cmt__JSONAttribute__c)) != null)
                        {
                            Users users1 = new Users();
                            users1.name = (String.isNotBlank(String.valueOf(getJsonAttribute('usergroup'+u+'_name', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('usergroup'+u+'_name', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                            users1.action = (String.valueOf(getJsonAttribute('usergroup'+u+'_action', oitem.vlocity_cmt__JSONAttribute__c)) != null ) ? isNull(getJsonAttribute('usergroup'+u+'_action', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                            UserGroupList.add(users1);
                        }
                    }
                    
                    integer DF;
                    List<DField> DFList = new List<DField>();
                    for(DF=1; DF<=DFAttr.size();DF++)
                    {
                        if(String.isNotBlank(String.valueOf(getAttribute('directoryField'+DF, oitem.vlocity_cmt__AttributeSelectedValues__c))) != null)
                        {
                            DField dfield1 = new DField();
                            dfield1.key = (String.isNotBlank(String.valueOf(getAttribute('directoryField'+DF, oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? DF : null;
                            dfield1.value = (String.valueOf(getAttribute('directoryField'+DF, oitem.vlocity_cmt__AttributeSelectedValues__c)) != null ? isNull(getJsonAttribute('directoryField'+DF,oitem.vlocity_cmt__AttributeSelectedValues__c)) : null);
                            DFList.add(dfield1);
                        }
                        else if(String.isNotBlank(String.valueOf(getJsonAttribute('directoryField'+DF, oitem.vlocity_cmt__JSONAttribute__c))) != null)
                        {
                            DField dfield1 = new DField();
                            dfield1.key = (String.isNotBlank(String.valueOf(getJsonAttribute('directoryField'+DF, oitem.vlocity_cmt__JSONAttribute__c)))) ? DF : null;
                            dfield1.value = (String.valueOf(getJsonAttribute('directoryField'+DF, oitem.vlocity_cmt__JSONAttribute__c)) != null ? isNull(getJsonAttribute('directoryField'+DF,oitem.vlocity_cmt__JSONAttribute__c)) : null);
                            DFList.add(dfield1);
                        }
                    }
                    
                    Roles roles = new Roles();
                    if(String.valueOf(getAttribute('roleUser', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null)
                    {
                        roles.user = (String.valueOf(getAttribute('roleUser', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null ) ? Boolean.valueOf(getAttribute('roleUser', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                    }
                    else if(String.valueOf(getJsonAttribute('roleUser', oitem.vlocity_cmt__JSONAttribute__c)) != null)
                    {
                        roles.user = (String.valueOf(getJsonAttribute('roleUser', oitem.vlocity_cmt__JSONAttribute__c)) != null ) ? Boolean.valueOf(getJsonAttribute('roleUser', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                    }
                    if(String.valueOf(getAttribute('roleTeamLead', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null)
                    {
                        roles.teamLead= (String.valueOf(getAttribute('roleTeamLead', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null ) ? Boolean.valueOf(getAttribute('roleTeamLead', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                    }
                    else if(String.valueOf(getJsonAttribute('roleTeamLead', oitem.vlocity_cmt__JSONAttribute__c)) != null)
                    {
                        roles.teamLead= (String.valueOf(getJsonAttribute('roleTeamLead', oitem.vlocity_cmt__JSONAttribute__c)) != null ) ? Boolean.valueOf(getJsonAttribute('roleTeamLead', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                    }
                    if(String.valueOf(getAttribute('roleCompanyAdmin', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null)
                    {
                        roles.admin= (String.valueOf(getAttribute('roleCompanyAdmin', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null ) ? Boolean.valueOf(getAttribute('roleCompanyAdmin', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                    }
                    else if(String.valueOf(getJsonAttribute('roleCompanyAdmin', oitem.vlocity_cmt__JSONAttribute__c)) != null)
                    {
                        roles.admin= (String.valueOf(getJsonAttribute('roleCompanyAdmin', oitem.vlocity_cmt__JSONAttribute__c)) != null ) ? Boolean.valueOf(getJsonAttribute('roleCompanyAdmin', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                    }
                    
                    //MadamService
                    MadamService madamService = new MadamService();
                    if(oitem.vlocity_cmt__Product2Id__r.Ordering_System__c == 'madam'){
                        if(String.valueOf(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null)
                        {
                            madamService.firstName = (String.isNotBlank(String.valueOf(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                        }
                        else if(String.valueOf(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)) != null)
                        {
                            madamService.firstName = (String.isNotBlank(String.valueOf(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                        }
                    }
                    if(String.valueOf(getAttribute('instanceId', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null)
                    {
                        madamService.instanceId = (String.isNotBlank(String.valueOf(getAttribute('instanceId', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('instanceId', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                    }
                    else if(String.valueOf(getJsonAttribute('instanceId', oitem.vlocity_cmt__JSONAttribute__c)) != null)
                    {
                        madamService.instanceId = (String.isNotBlank(String.valueOf(getJsonAttribute('instanceId', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('instanceId', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                    }
                    if(String.valueOf(getAttribute('callingLineType', oitem.vlocity_cmt__AttributeSelectedValues__c)) != null)
                    {
                        madamService.callingLineIdType = (String.isNotBlank(String.valueOf(getAttribute('callingLineType', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('callingLineType', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                    }
                    else if(String.valueOf(getJsonAttribute('callingLineType', oitem.vlocity_cmt__JSONAttribute__c)) != null)
                    {
                        madamService.callingLineIdType = (String.isNotBlank(String.valueOf(getJsonAttribute('callingLineType', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('callingLineType', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                    }
                    if(oitem.vlocity_cmt__Product2Id__r.Ordering_System__c == 'madam' && oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'scuser')
                    {
                        madamService.userPackage = (String.isNotBlank(String.valueOf(oitem.vlocity_cmt__Product2Id__r.Feature_Id__c))) ? isNull(oitem.vlocity_cmt__Product2Id__r.Feature_Id__c) : null;
                    }
                    if(oitem.vlocity_cmt__Product2Id__r.Ordering_System__c == 'madam' && oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c != 'ucuser' && oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c != 'scuser')
                    {
                        madamService.featureId  = (String.isNotBlank(String.valueOf(oitem.vlocity_cmt__Product2Id__r.Feature_Id__c))) ? isNull(oitem.vlocity_cmt__Product2Id__r.Feature_Id__c) : null;
                    }
                    
                    if(agentList.size() > 0)
                    {
                        madamService.agents = agentList;
                    }
                    madamService.roles = roles;
                    if(madamService.instanceId == null && oitem.vlocity_cmt__Product2Id__r.Ordering_System__c == 'madam' && instanceIdMap != null && oitem.MCOnline_Basket_Relation_Id__c != null)
                    {
                        madamService.instanceId = instanceIdMap.get(oitem.MCOnline_Basket_Relation_Id__c);
                    }
                    
                    //autoVoiceService
                    list<String> UserName = new list<String>();
                    if(String.valueOf(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c))!=null)
                    {
                        UserName = ((String.valueOf(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c)))!=null) ? (String.valueOf(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c))).split(',') : null;
                    }
                    else if(String.valueOf(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)) != null)
                    {
                        UserName = ((String.valueOf(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)))!=null) ? (String.valueOf(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c))).split(',') : null;
                    }
                    AutoVoiceadamService autoVoiceService = new AutoVoiceadamService();
                    System.debug('Ordering_System__c='+oitem.vlocity_cmt__Product2Id__r.Ordering_System__c);
                    if(oitem.vlocity_cmt__Product2Id__r.Ordering_System__c == 'autovoice'){
                        if(String.isNotBlank(String.valueOf(getAttribute('tppdomain', oitem.vlocity_cmt__AttributeSelectedValues__c))))
                        {
                            autoVoiceService.domain = (String.isNotBlank(String.valueOf(getAttribute('tppdomain', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('tppdomain', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                        }
                        else if(String.isNotBlank(String.valueOf(getJsonAttribute('tppdomain', oitem.vlocity_cmt__JSONAttribute__c))))
                        {
                            autoVoiceService.domain = (String.isNotBlank(String.valueOf(getJsonAttribute('tppdomain', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('tppdomain', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                        }
                        //autoVoiceService.lastName=(String.isNotBlank(String.valueOf(getAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)): null;
                        if(String.isNotBlank(String.valueOf(getAttribute('department', oitem.vlocity_cmt__AttributeSelectedValues__c))))
                        {
                            autoVoiceService.department=(String.isNotBlank(String.valueOf(getAttribute('department', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('department', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                        }
                        else if(String.isNotBlank(String.valueOf(getJsonAttribute('department', oitem.vlocity_cmt__JSONAttribute__c))))
                        {
                            autoVoiceService.department=(String.isNotBlank(String.valueOf(getJsonAttribute('department', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('department', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                        }
                        if(String.isNotBlank(String.valueOf(getAttribute('costCenter', oitem.vlocity_cmt__AttributeSelectedValues__c))))
                        {
                            autoVoiceService.costCenter=(String.isNotBlank(String.valueOf(getAttribute('costCenter', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('costCenter', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                        }
                        else if(String.isNotBlank(String.valueOf(getJsonAttribute('costCenter', oitem.vlocity_cmt__JSONAttribute__c))))
                        {
                            autoVoiceService.costCenter=(String.isNotBlank(String.valueOf(getJsonAttribute('costCenter', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('costCenter', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                        }
                        if(String.isNotBlank(String.valueOf(getAttribute('costCenter', oitem.vlocity_cmt__AttributeSelectedValues__c))))
                        {
                            autoVoiceService.costCenter=(String.isNotBlank(String.valueOf(getAttribute('costCenter', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('costCenter', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                        }
                        else if(String.isNotBlank(String.valueOf(getJsonAttribute('costCenter', oitem.vlocity_cmt__JSONAttribute__c))))
                        {
                            autoVoiceService.costCenter=(String.isNotBlank(String.valueOf(getJsonAttribute('costCenter', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('costCenter', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                        }
                        if(UserName.size() > 1){
                            autoVoiceService.firstName = (String.valueOf((UserName != null && UserName.size() > 0) ? UserName[0] : null));
                            autoVoiceService.lastName=(String.valueOf((UserName != null && UserName.size() > 1) ? UserName[1] : null));
                        }
                        else{
                            if(String.isNotBlank(String.valueOf(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c))))
                            {
                                autoVoiceService.lastName=(String.isNotBlank(String.valueOf(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c)))) ? isNull(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c)) : null;
                            }
                            else if(String.isNotBlank(String.valueOf(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c))))
                            {
                                autoVoiceService.lastName=(String.isNotBlank(String.valueOf(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)))) ? isNull(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)) : null;
                            }
                        }
                    }                      
                    if(oitem.vlocity_cmt__Product2Id__r.Ordering_System__c == 'autovoice' && oitem.vlocity_cmt__Product2Id__r.C2BC_Category__c == 'switchboardextension' )
                    {
                        autoVoiceService.featureId  = (String.isNotBlank(String.valueOf(oitem.vlocity_cmt__Product2Id__r.Feature_Id__c))) ? isNull(oitem.vlocity_cmt__Product2Id__r.Feature_Id__c) : null;
                    }
                    
                    if(UserGroupList.size() > 0)
                    {
                        autoVoiceService.userGroups = UserGroupList;
                    }   
                    if(DFList.size() > 0)
                    {
                        autoVoiceService.directoryFields = DFList;
                    }   
                    if(autoVoiceService.instanceId == null && oitem.vlocity_cmt__Product2Id__r.Ordering_System__c == 'autovoice' && instanceIdMap != null && oitem.MCOnline_Basket_Relation_Id__c != null)
                    {
                        autoVoiceService.instanceId = instanceIdMap.get(oitem.MCOnline_Basket_Relation_Id__c);
                    }
                    
                    ProductSpecification productSpecification = new  productSpecification();
                    if(oitem.vlocity_cmt__Product2Id__r.Ordering_System__c != 'madam')
                    {
                        productSpecification.gsmAhsService = gsmAhsService;
                    }
                    productSpecification.gsmAhsSubscription = gsmAhsSubscription;
                    productSpecification.madamService = madamService;
                    productSpecification.autoVoiceService = autoVoiceService;
                    
                    Attributes attribute = new Attributes();
                    if(oitem != null){
                        if(getAttribute('SIM_Format', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.simFormat = isNull(getAttribute('SIM_Format', oitem.vlocity_cmt__AttributeSelectedValues__c));
                            //MCONL-12293
                            if(attribute.simFormat.equalsIgnoreCase('keep')){
                                String updatedSimformat = 'simcard';
                                if(updatedSimformat != null && updatedSimformat != ''){
                                    attribute.simFormat = updatedSimformat;
                                }
                            }
                        }
                        else if(getJsonAttribute('SIM_Format', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.simFormat = isNull(getJsonAttribute('SIM_Format', oitem.vlocity_cmt__JSONAttribute__c));
                            //MCONL-12293
                            if(attribute.simFormat.equalsIgnoreCase('keep')){
                                String updatedSimformat = '';
                                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(oitem.vlocity_cmt__JSONAttribute__c);
                                List<object> TELIAMOBAGGRList = (List<object>) jsonMap.get('ATT_CODE_TELIAMOBAGGR');
                                for(Object TELIAMOBAGGR : TELIAMOBAGGRList){
                                    Map<String, Object> m1= (Map<String, Object>)TELIAMOBAGGR;
                                    string attributeName = String.valueOf(m1.get('attributeuniquecode__c'));
                                    if(attributeName != null && attributeName.equalsIgnoreCase('SIM_Format') != null && attributeName.equalsIgnoreCase('SIM_Format') == true){
                                        updatedSimformat = String.valueOf(m1.get('value__c'));
                                    }
                                }
                                if(updatedSimformat != null && updatedSimformat != ''){
                                    attribute.simFormat = updatedSimformat;
                                }
                            }
                        }
                        if(getAttribute('ICC_number', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.iccNumber = isNull(getAttribute('ICC_number', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('ICC_number', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.iccNumber = isNull(getJsonAttribute('ICC_number', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('e-SIM_Method', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.esimMethod = isNull(getAttribute('e-SIM_Method', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('e-SIM_Method', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.esimMethod = isNull(getJsonAttribute('e-SIM_Method', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('ipRangeStart', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.ipRangeStart = isNull(getAttribute('ipRangeStart', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('ipRangeStart', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.ipRangeStart = isNull(getJsonAttribute('ipRangeStart', oitem.vlocity_cmt__JSONAttribute__c));
                        }

                        if(getAttribute('siteAgreementId', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.siteId = isNull(getAttribute('siteAgreementId', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('siteAgreementId', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.siteId = isNull(getJsonAttribute('siteAgreementId', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('Email', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.esimEmail = isNull(getAttribute('Email', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('Email', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.esimEmail = isNull(getJsonAttribute('Email', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(oitem.Quantity != null){
                            attribute.quantity=string.Valueof(oitem.Quantity);
                        }
                        if(oitem.vlocity_cmt__Product2Id__r.Ordering_System__c != 'madam'){
                            if(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c) == null && getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c) == null){
                                attribute.user = oitem.MCOnline_UserName__c;
                            }else if(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                                attribute.user = isNull(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c));
                            }else{
                                attribute.user = isNull(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c));
                            }
                            if(oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'datasim'){
                                if(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c) == null && getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c) == null && datasimMap != null && oitem.MCOnline_Basket_Relation_Id__c != null){
                                    attribute.user = datasimMap.get(oitem.MCOnline_Basket_Relation_Id__c);
                                }else if(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                                    attribute.user = isNull(getAttribute('User_name', oitem.vlocity_cmt__AttributeSelectedValues__c));
                                }else{
                                    attribute.user = isNull(getJsonAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c));
                                }
                            }
                            if(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__AttributeSelectedValues__c) == null && getJsonAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__JSONAttribute__c) == null){
                                attribute.externalRef = oitem.MCOnline_ExternalRef__c;
                            }else if(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                                attribute.externalRef = isNull(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__AttributeSelectedValues__c));
                            }else{
                                attribute.externalRef = isNull(getJsonAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__JSONAttribute__c));
                            }
                            if(oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'datasim'){
                                if(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__AttributeSelectedValues__c) == null && getJsonAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__JSONAttribute__c) == null && datasimMap1 != null && oitem.MCOnline_Basket_Relation_Id__c != null){
                                    attribute.externalRef = datasimMap1.get(oitem.MCOnline_Basket_Relation_Id__c);
                                }else if(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                                    attribute.externalRef = isNull(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__AttributeSelectedValues__c));
                                }else{
                                    attribute.externalRef = isNull(getJsonAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__JSONAttribute__c));
                                }
                            }
                        }
                        if(getAttribute('Current_owner_SSN', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.ownerSSN = isNull(getAttribute('Current_owner_SSN', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('Current_owner_SSN', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.ownerSSN = isNull(getJsonAttribute('Current_owner_SSN', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('Current_owner_Organization', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.ownerOrgno = isNull(getAttribute('Current_owner_Organization', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('Current_owner_Organization', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.ownerOrgno = isNull(getJsonAttribute('Current_owner_Organization', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('Current_owner_last_name', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.ownerLastName = isNull(getAttribute('Current_owner_last_name', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('Current_owner_last_name', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.ownerLastName = isNull(getJsonAttribute('Current_owner_last_name', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('Current_owner_first_name', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.ownerFirstName = isNull(getAttribute('Current_owner_first_name', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('Current_owner_first_name', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.ownerFirstName = isNull(getJsonAttribute('Current_owner_first_name', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('fixedPhoneNumber', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.fixedPhoneNumber = isNull(getAttribute('fixedPhoneNumber', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('fixedPhoneNumber', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.fixedPhoneNumber = isNull(getJsonAttribute('fixedPhoneNumber', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        else if(getJsonAttribute('fixedPhoneNumber', oitem.vlocity_cmt__JSONAttribute__c) == null){
                            attribute.fixedPhoneNumber='';
                        }
                        if(getAttribute('costControlAmount', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.costControlAmount = isNull(getAttribute('costControlAmount', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('costControlAmount', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.costControlAmount = isNull(getJsonAttribute('costControlAmount', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('firstName', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.firstName = isNull(getAttribute('firstName', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('firstName', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.firstName = isNull(getJsonAttribute('firstName', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('lastName', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.lastName = isNull(getAttribute('lastName', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('lastName', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.lastName = isNull(getJsonAttribute('lastName', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('street', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.street = isNull(getAttribute('street', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('street', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.street = isNull(getJsonAttribute('street', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('streetNumber', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.streetNumber = isNull(getAttribute('streetNumber', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('streetNumber', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.streetNumber = isNull(getJsonAttribute('streetNumber', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('postalCode', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.postalCode = isNull(getAttribute('postalCode', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('postalCode', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.postalCode = isNull(getJsonAttribute('postalCode', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('city', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.city = isNull(getAttribute('city', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('city', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.city = isNull(getJsonAttribute('city', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('country', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.country = isNull(getAttribute('country', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('country', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.country = isNull(getJsonAttribute('country', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('pointid', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.pointId = isNull(getAttribute('pointid', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('pointid', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.pointId = isNull(getJsonAttribute('pointid', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('entrance', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.entrance = isNull(getAttribute('entrance', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('entrance', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.entrance = isNull(getJsonAttribute('entrance', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('appartmentNumber', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.apartmentNumber = isNull(getAttribute('appartmentNumber', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('appartmentNumber', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.apartmentNumber = isNull(getJsonAttribute('appartmentNumber', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('careOf', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.careOf = isNull(getAttribute('careOf', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('careOf', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.careOf = isNull(getJsonAttribute('careOf', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('ownerPhoneNumber', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.ownerPhoneNumber = isNull(getAttribute('ownerPhoneNumber', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('ownerPhoneNumber', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.ownerPhoneNumber = isNull(getJsonAttribute('ownerPhoneNumber', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('Current_owner_email', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.ownerEmailAddress = isNull(getAttribute('Current_owner_email', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('Current_owner_email', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.ownerEmailAddress = isNull(getJsonAttribute('Current_owner_email', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('Requested_port_in_date', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.requestedPortInDate= isNull(getAttribute('Requested_port_in_date', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('Requested_port_in_date', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.requestedPortInDate= isNull(getJsonAttribute('Requested_port_in_date', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('Current_owner_org_name', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.currentOwnerOrgName= isNull(getAttribute('Current_owner_org_name', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('Current_owner_org_name', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.currentOwnerOrgName= isNull(getJsonAttribute('Current_owner_org_name', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('Temporary_MSISDN', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.temporaryNumber = isNull(getAttribute('Temporary_MSISDN', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('Temporary_MSISDN', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.temporaryNumber = isNull(getJsonAttribute('Temporary_MSISDN', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                        if(getAttribute('subAgreementId', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                            attribute.subAgreementId = isNull(getAttribute('subAgreementId', oitem.vlocity_cmt__AttributeSelectedValues__c));
                        }
                        else if(getJsonAttribute('subAgreementId', oitem.vlocity_cmt__JSONAttribute__c) != null){
                            attribute.subAgreementId = isNull(getJsonAttribute('subAgreementId', oitem.vlocity_cmt__JSONAttribute__c));
                        }
                    }
                    if(oitem.vlocity_cmt__Product2Id__r.ProductCode == portInData || oitem.vlocity_cmt__Product2Id__r.ProductCode == portIn){
                        orderLine.productSpecification = null;
                    }else{ 
                        orderLine.productSpecification  = productSpecification;
                    }
                    orderLine.Attributes = attribute;
                    if(oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c != null){
                        orderLine.productSubcategory  = isNull(oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c);
                    }
                    orderLine.id  = orderMap.get(oitem.Id);
                    if(oitem.vlocity_cmt__Product2Id__r.C2BC_Category__c != null){
                        orderLine.productCategory  = isNull(oitem.vlocity_cmt__Product2Id__r.C2BC_Category__c);
                    }
                    orderLine.name  = isNull(oitem.vlocity_cmt__Product2Id__r.Name);
                    orderLine.recurringChargeAmount = (oitem.vlocity_cmt__RecurringCharge__c).setScale(2); 
                    
                    /*---Added by Binamra Guha on 07/07/2021---*/
                    /*---------------------OP Mapping List price------------------------*/
                    if(oitem.vlocity_cmt__Product2Id__r.C2BC_Category__c == 'goods'){
                        orderLine.listPrice = (hardwarePriceList.get(oitem.vlocity_cmt__Product2Id__r.ProductCode) != null) ? hardwarePriceList.get(oitem.vlocity_cmt__Product2Id__r.ProductCode) : 0;
                    }else{
                        orderLine.listPrice = (subscriptionPriceList.get(oitem.vlocity_cmt__Product2Id__r.ProductCode) != null) ? subscriptionPriceList.get(oitem.vlocity_cmt__Product2Id__r.ProductCode) : 0;
                    }
                    
                    /*----- Mapping the ListPrice,VatPercentage and OneTimeFeeAmount towards OP(MCONL-8353) -----*/
                    orderLine.vatRate = vatRate;
                    orderLine.oneTimeFeeAmount = (oitem.vlocity_cmt__OneTimeCharge__c).setScale(2);
                    /*--------------------------------------------------------------------------*/
                    orderLine.parentAssetIdentifier = isNull(oitem.MCONL_multiSubscriptionAssetIdentifier__c); 
                    //MCONL-8338
                    if(oitem.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c != null || oitem.vlocity_cmt__Product2Id__r.C2BC_Category__c == 'goods' || oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'portin' || oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'transferofownership' || oitem.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c != null){ //As a part of 11197EF and 1840BF, Added Rule for 7 is that ”if downstream_product_service_code not null then ShowInSummary = TRUE”
                        
                        orderLine.showInSummary = true;
                    }
                    else{
                        orderLine.showInSummary = false;
                        
                    }
                    orderLine.parentId  = parentIdMap.get(oitem.vlocity_cmt__RootItemId__c); // oitem.vlocity_cmt__RootItemId__c
                    //MCONL-7868
                    if(getAttribute('ATT_HW_SAP_ID', oitem.vlocity_cmt__AttributeSelectedValues__c) != null){
                        orderLine.productId =  isNull(getAttribute('ATT_HW_SAP_ID', oitem.vlocity_cmt__AttributeSelectedValues__c));
                    }
                    else if(getJsonAttribute('ATT_HW_SAP_ID', oitem.vlocity_cmt__JSONAttribute__c) != null){
                        orderLine.productId =  isNull(getJsonAttribute('ATT_HW_SAP_ID', oitem.vlocity_cmt__JSONAttribute__c));
                    }
                    else{
                        orderLine.productId = isNull(oitem.vlocity_cmt__Product2Id__r.ProductCode);
                    }
                    if(oitem.MCONL_Action_Code__c != null){
                        orderLine.actionCode  = isNull(oitem.MCONL_Action_Code__c);
                    }else{
                        orderLine.actionCode  = 'Add';
                    }
                    if(oitem.vlocity_cmt__Product2Id__r.ProductCode == portInData){
                        orderLine.scenario = 'PORT_IN';
                    }
                    if(oitem.vlocity_cmt__Product2Id__r.ProductCode == transferOfferData){
                        orderline.scenario = 'TRANSFER';
                    }
                    if(oitem.MCOnline_CommitmentUnit__c != null){
                        orderLine.commitmentTimeUnit  = isNull(oitem.MCOnline_CommitmentUnit__c);
                    }
                    if(oitem.MCOnline_CommitmentPeriod__c != null){
                        orderLine.commitmentTime  = isNull(oitem.MCOnline_CommitmentPeriod__c);
                    }
                    if(oitem.vlocity_cmt__Product2Id__r.Ordering_System__c != 'madam')
                    {
                        orderLine.assetIdentifier  = isNull(oitem.MCOnline_MSISDN__c);
                    }
                    if(oitem.vlocity_cmt__Product2Id__r.ProductCode == portInData || oitem.vlocity_cmt__Product2Id__r.ProductCode == portIn){
                        orderLine.billingAccountId = null;
                    }else{
                        orderLine.billingAccountId= (oitem.MCOnline_Billing_Account__c != null) ? oitem.MCOnline_Billing_Account__c : String.valueOf(billingAccountMap.get('accountId'));
                        
                    }
                    orderLines.add(orderLine);
                }
                orderData.orderLines = orderLines;
                oRequestWrapper.orderData = orderData;
                string extractOrder;
                Set<String> finalNodes= new Set<String>();
                string opString = JSON.serialize(oRequestWrapper);
                System.debug(opString);
                Map<String, Object> finaloRequestWrapper = (Map<String, Object>)JSON.deserializeUntyped(opString);
                //method called for removing the not used attributes
                removeNode(finaloRequestWrapper, finalNodes);
                Map<String, Object> oRequestWrapper1 = (Map<String, Object>)finaloRequestWrapper;
                extractOrder = JSON.serialize(oRequestWrapper1);
                
                string endpointName;
                //Data Masking- Mock URL setup
                If(Label.MCONL_IsLowerOrg.equalsIgnoreCase('YES')){
                    endpointName=String.valueOf('MCONL_OrderProcessor_Mock');
                }else if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')){
                    endpointName = String.valueOf('MCONL_OrderProcessor_UAT');
                }else{
                    endpointName = String.valueOf('MCONL_OrderProcessor');
                }
                
                Map<String, Object> accessMap = null;
                if(!Test.isRunningTest()){
                    if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
                        accessMap = (Map<String, Object>) JSON.deserializeUntyped(TeliaSE_MadamAuthenticationWS_UAT.makePostCallout());
                    }else{
                        accessMap = (Map<String, Object>) JSON.deserializeUntyped(TeliaSE_MadamAuthentication.makePostCallout());
                    }
                }
                outMap.put('op_request', extractOrder);
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint(WebService__c.getAll().get(endpointName).EndpointURL__c);
                request.setMethod(HTTP_METHOD);
                request.setTimeout(TIMEOUT);
                request.setHeader(CONTENT, APPLICATION_JSON);
                request.setBody(extractOrder);
                Http http = new Http();
                
                if(!Test.isRunningTest()){
                    request.setHeader(AUTHORIZATION, BEARER+accessMap.get(ACCESSTOKEN));
                }
                
                HttpResponse response = null;
                if(order.OrderProcessor_ResponseStatusCode__c  != null && order.OrderProcessor_ResponseStatusCode__c.equalsIgnoreCase('201')){
                    system.debug('This order is already processed.');
                    outMap.put('op_response_message', 'This order is already processed.');
                    if(order.MCONL_Order_Activation_Status_Code__c == null || (order.MCONL_Order_Activation_Status_Code__c != null && !order.MCONL_Order_Activation_Status_Code__c.equalsIgnoreCase('200'))){
                        activateOrder(order.MCOnline_OrderNumber__c, order, outMap, accessMap);
                    }
                }else{
                    if(!Test.isRunningTest()){
                        response = http.send(request);
                    }
                    system.debug('response body : '+response.getBody());
                    
                    if(response != null && response.getStatusCode() == 201){
                        outMap.put('op_status', SUBMITTED);
                        outMap.put('op_response', 'Order Created');
                        outMap.put('op_response_message', 'Order Created');
                        outMap.put('op_statuscode', string.valueOf(response.getStatusCode()));
                        
                        //Activate Order
                        if(order.MCONL_Order_Activation_Status_Code__c == null || (order.MCONL_Order_Activation_Status_Code__c!= null && !order.MCONL_Order_Activation_Status_Code__c.equalsIgnoreCase('200'))){
                            activateOrder(order.MCOnline_OrderNumber__c, order, outMap, accessMap);
                        }
                    }else{
                        string op_response = response.getBody();
                        outMap.put('op_response', JSON.deserializeUntyped(op_response));
                        outMap.put('op_statuscode', string.valueOf(response.getStatusCode()));
                        outMap.put('op_response_message', 'Error while order submission.');
                        
                        if(order.MCONL_Order_Activation_Status_Code__c == null || (order.MCONL_Order_Activation_Status_Code__c != null && !order.MCONL_Order_Activation_Status_Code__c.equalsIgnoreCase('200'))){
                            activateOrder(order.MCOnline_OrderNumber__c, order, outMap, accessMap);
                        }
                    }
                }
            }
        }
    }
    public static string getAttribute(string attributeNameFromParam, string jsonAttribute){
        if(jsonAttribute != null){
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonAttribute);
            if(jsonMap !=null && attributeNameFromParam != null && jsonMap.containsKey(attributeNameFromParam))
            {
                return String.valueOf(jsonMap.get(attributeNameFromParam));
            }
        }
        return null;
    }
    
    public static string getJsonAttribute(string attributeNameFromParam, string jsonAttribute){
        if(jsonAttribute != null){
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonAttribute);
            List<object> TELIAMOBAGGRList = (List<object>) jsonMap.get('ATT_CODE_TELIAMOBAGGR');
            for(Object TELIAMOBAGGR : TELIAMOBAGGRList){
                Map<String, Object> m1= (Map<String, Object>)TELIAMOBAGGR;
                string attributeName = String.valueOf(m1.get('attributeuniquecode__c'));
                if((String.valueOf(m1.get('valuedatatype__c'))).equalsIgnoreCase('Picklist') && attributeName != null && attributeName.equalsIgnoreCase(attributeNameFromParam) != null && attributeName.equalsIgnoreCase(attributeNameFromParam) == true ){
                    Map<String, Object> attributeRunTimeInfoMap = (Map<String, Object>)m1.get('attributeRunTimeInfo');
                    if(attributeRunTimeInfoMap.get('selectedItem') != null){
                        Map<String, Object> selectedItemMap = (Map<String, Object>)attributeRunTimeInfoMap.get('selectedItem');
                        if(selectedItemMap != null){
                            string value = String.valueOf(selectedItemMap.get('value'));
                            value = value != null ? value : '';
                            return value;
                        }
                    }
                }
                
                else if(attributeName != null && attributeName.equalsIgnoreCase(attributeNameFromParam) != null && attributeName.equalsIgnoreCase(attributeNameFromParam) == true ){
                    Map<String, Object> attributeRunTimeInfoMap = (Map<String, Object>)m1.get('attributeRunTimeInfo');
                    if(attributeRunTimeInfoMap != null){
                        return String.valueOf(attributeRunTimeInfoMap.get('value'));
                    }
                }
                
                
            }
        }
        
        return null;
    }
    /*
* Added by Suneel G Shivanna
* Populates BND Mandate on Subscription product if Hardware is present in Order 
*/
    public static void populateBND(String orderId)
    {
        DateTime time1=DateTime.now();
        Decimal mrc;
        OrderItem subscriptionItem;
        List<OrderItem> subscriptionItems=new List<OrderItem>();
        Map<Decimal,String> mrcMap=new Map<Decimal,String>();
        Map<String,List<Object>> genericMap=new Map<String,List<Object>>();
        try{
            for(OrderItem item:[select MCONL_multiSubscriptionAssetIdentifier__c,product2.C2BC_Category__c,product2.C2BC_Subcategory__c,vlocity_cmt__RecurringCharge__c from OrderItem where OrderId=:orderId and product2.C2BC_Category__c in ('mobilevoicesubscription','goods') and product2.C2BC_Subcategory__c in ('voice','mobiledevice')])
            {
                if(item.product2.C2BC_Category__c == 'goods' && item.product2.C2BC_Subcategory__c == 'mobiledevice' && item.vlocity_cmt__RecurringCharge__c != null)
                {
                    if(genericMap.get(item.MCONL_multiSubscriptionAssetIdentifier__c)!= null)
                    {
                        genericMap.get(item.MCONL_multiSubscriptionAssetIdentifier__c).add(item.vlocity_cmt__RecurringCharge__c);
                    }
                    else
                    {
                        genericMap.put(item.MCONL_multiSubscriptionAssetIdentifier__c,new List<Object>{item.vlocity_cmt__RecurringCharge__c});
                    }
                }
                else if(item.product2.C2BC_Category__c == 'mobilevoicesubscription' && item.product2.C2BC_Subcategory__c == 'voice')
                {
                    if(genericMap.get(item.MCONL_multiSubscriptionAssetIdentifier__c)!= null)
                    {
                        genericMap.get(item.MCONL_multiSubscriptionAssetIdentifier__c).add(item);
                    }
                    else
                    {
                        genericMap.put(item.MCONL_multiSubscriptionAssetIdentifier__c,new List<Object>{item});
                    }
                }
            }
            for(MCONL_BND__mdt bnd:[select MCONL_MRC__c,MCONL_BND__c from MCONL_BND__mdt])
            {
                mrcMap.put(bnd.MCONL_MRC__c,bnd.MCONL_BND__c);
            }
            
            for(List<Object> item:genericMap.values())
            {
                if(item.size()>1)
                {   
                    mrc=item[0] instanceof Decimal?(Decimal)item[0]:(Decimal)item[1];
                    subscriptionItem=item[0] instanceof Decimal?(OrderItem)item[1]:(OrderItem)item[0];
                    subscriptionItem.MCONL_Additional_Charge__c=mrcMap.get(mrc);
                    subscriptionItems.add(subscriptionItem);
                }
            }
            
            Database.update(subscriptionItems,false);
        }catch(Exception e)
        {
        }
    }
    
    public static void removeNode(Object obj1, Set<String> finalNodes)
    {
        Map<String,Object> tempMap=(Map<String,Object>)obj1;
        if(tempMap.containsKey('orderData'))
        {
            Map<String,Object> orderData=(Map<String,Object>)tempMap.get('orderData');
            removeNode(orderData, finalNodes);
        }
        if(tempMap.containsKey('billingAccountDetails'))
        {
            Map<String,Object> billingAccountDetails=(Map<String,Object>)tempMap.get('billingAccountDetails');
            if(billingAccountDetails == null){
                tempMap.remove('billingAccountDetails');
            }
        }
        if(tempMap.containsKey('orderLines')){
            List<Object> orderLines=(List<Object>)tempMap.get('orderLines');
            for(Object orderLines1:orderLines)
            {
                removeNode(orderLines1, finalNodes);
            }
        }
        if(tempMap.containsKey('attributes')){
            Map<String,Object> attributes1=(Map<String,Object>)tempMap.get('attributes');
            for(String key : attributes1.keyset())
            {
                if(key!='fixedPhoneNumber' && attributes1.get(key) == null)
                {
                    attributes1.remove(key);
                }
            }
        }
        if(tempMap.containsKey('productSpecification'))
        {
            Map<String,Object> productSpecification=(Map<String,Object>)tempMap.get('productSpecification');
            if(productSpecification != null)
            {
                if(productSpecification.containsKey('madamService'))
                {
                    Map<String,Object> madamService=(Map<String,Object>)productSpecification.get('madamService');
                    if(madamService != null)
                    {
                        if(madamService.containsKey('agents') && madamService.get('agents') != null)
                        {
                            List<Object> agents=(List<Object>)madamService.get('agents');
                            Integer size = agents.size();
                            for(Integer i = size - 1; i >= 0; i--)
                            {
                                Map<String,Object> obj=(Map<String,Object>)agents.get(i);
                                for(String key : obj.keyset())
                                {
                                    if(obj.get(key) == null)
                                    {
                                        obj.remove(key);
                                    }
                                }
                                if(obj.isEmpty())
                                {
                                    agents.remove(i);
                                }
                            }
                            if(agents.size() == 0)
                            {
                                madamService.remove('agents');
                            }
                            
                        }
                        if(madamService.containsKey('roles') && madamService.get('roles') != null)
                        {
                            Map<String,Object> roles=(Map<String,Object>)madamService.get('roles');
                            for(String key : roles.keyset())
                            {
                                if(roles.get(key) == null)
                                {
                                    roles.remove(key);
                                }
                            }
                            if(roles.isEmpty())
                            {
                                madamService.remove('roles');
                            }
                        }
                        for(String key : madamService.keyset())
                        {
                            if(madamService.get(key) == null)
                            {
                                madamService.remove(key);
                            }
                        }
                    }
                    if(madamService == null || madamService.isEmpty())
                    {
                        productSpecification.remove('madamService');
                    }
                }
                if(productSpecification.containsKey('autoVoiceService'))
                {
                    Map<String,Object> autoVoiceService=(Map<String,Object>)productSpecification.get('autoVoiceService');
                    if(autoVoiceService != null)
                    {
                        if(autoVoiceService.containsKey('userGroups') && autoVoiceService.get('userGroups') != null)
                        {
                            List<Object> userGroups=(List<Object>)autoVoiceService.get('userGroups');
                            Integer size = userGroups.size();
                            for(Integer i = size - 1; i >= 0; i--)
                            {
                                Map<String,Object> obj=(Map<String,Object>)userGroups.get(i);
                                for(String key : obj.keyset())
                                {
                                    if(obj.get(key) == null)
                                    {
                                        obj.remove(key);
                                    }
                                }
                                if(obj.isEmpty())
                                {
                                    userGroups.remove(i);
                                }
                            }
                            if(userGroups.size() == 0)
                            {
                                autoVoiceService.remove('userGroups');
                            }
                            
                        }
                        if(autoVoiceService.get('directoryFields') != null && autoVoiceService.containsKey('directoryFields'))
                        {
                            List<Object> directoryFields=(List<Object>)autoVoiceService.get('directoryFields');
                            Integer size = directoryFields.size();
                            for(Integer i = size - 1; i >= 0; i--)
                            {
                                Map<String,Object> obj=(Map<String,Object>)directoryFields.get(i);
                                for(String key : obj.keyset())
                                {
                                    if(obj.get(key) == null)
                                    {
                                        obj.remove(key);
                                    }
                                }
                                if(obj.isEmpty())
                                {
                                    directoryFields.remove(i);
                                }
                            }
                            if(directoryFields.size() == 0)
                            {
                                autoVoiceService.remove('directoryFields');
                            }
                        }
                        for(String key : autoVoiceService.keyset())
                        {
                            if(autoVoiceService.get(key) == null)
                            {
                                autoVoiceService.remove(key);
                            }
                        }
                    }
                    if(autoVoiceService == null || autoVoiceService.isEmpty())
                    {
                        productSpecification.remove('autoVoiceService');
                    }
                }               
                if(productSpecification.get('gsmAhsService') != null)
                {
                    Map<String,Object> gsmAhsService=(Map<String,Object>)productSpecification.get('gsmAhsService');
                    for(String key : gsmAhsService.keyset())
                    {
                        if(gsmAhsService.get(key) == null || String.IsBlank(String.valueOf(gsmAhsService.get(key))))
                        {
                            gsmAhsService.remove(key);
                        }
                    }
                    if(gsmAhsService == null || gsmAhsService.isEmpty())
                    {
                        productSpecification.remove('gsmAhsService');
                    }
                }
                if(productSpecification.get('gsmAhsSubscription') != null)
                {
                    Map<String,Object> gsmAhsSubscription=(Map<String,Object>)productSpecification.get('gsmAhsSubscription');
                    for(String key : gsmAhsSubscription.keyset())
                    {
                        if(gsmAhsSubscription.get(key) == null || String.IsBlank(String.valueOf(gsmAhsSubscription.get(key))))
                        {
                            gsmAhsSubscription.remove(key);
                        }
                    }
                    if(gsmAhsSubscription == null || gsmAhsSubscription.isEmpty())
                    {
                        productSpecification.remove('gsmAhsSubscription');
                    }
                }
            }
        }
    }
    
    public class Agreement    {
        public integer id { get; set; } 
        public string confirmationMethod = 'E_SIGN';
        public string additionalInfo { get; set; } 
        public string idString { get; set; } 
    }
    
    public class LegalAddress    {
        public string street { get; set; } 
        public string postalCode { get; set; } 
        public string country { get; set; } 
        public string city { get; set; } 
    }
    
    public class BusinessCustomer    {
        public LegalAddress legalAddress { get; set; } 
        public string tscId { get; set; } 
        public string organisationNumber { get; set; } 
        public string name { get; set; } 
    }
    
    public class GsmAhsService    {
        public string serviceValue { get; set; } 
        public string serviceCode { get; set; } 
    }
    
    public class GsmAhsSubscription    {
        public string multiSubscriptionCode { get; set; } 
        public string multiSubscriptionAssetIdentifier { get; set; } 
        public string subscriptionCode { get; set; } 
        public String additionalCharge {get; set;}
    }
    //For TouchPoint Mapping towards Op
    public class Agents    {
        public string cdgIdentifyingNumber { get; set; } 
        public boolean cdgAgentLoggedIn { get; set; }
    }
    
    public class Roles    {
        public boolean user { get; set; }
        public boolean Admin { get; set; }
        public boolean teamLead{ get; set; } 
    }
    
    public class MadamService    {
        public string firstName { get; set; } 
        //public string lastName { get; set; }
        //public string user { get; set; }    
        public string instanceId { get; set; } 
        public String callingLineIdType {get; set;}
        public String featureId {get; set;}
        public List<Agents> agents {get; set;}
        public Roles roles {get; set;}
        public String userPackage{get; set;}
    }
    //For TPP Mapping
    public class Users    {
        public string name { get; set; } 
        public string action { get; set; }
    }
    
    public class DField    {
        public integer key { get; set; } 
        public string value { get; set; }
    }
    
    public class AutoVoiceadamService    {
        public string firstName { get; set; } 
        public string lastName { get; set; }
        public string department{ get; set; }
        public string instanceId { get; set; } 
        public String domain {get; set;}
        public String featureId {get; set;}
        public List<Users> userGroups {get; set;}
        public List<DField> directoryFields {get; set;}
        public String costCenter {get; set;}
    }
    
    public class BilliantSubscription    {
        public string subscriptionType { get; set; } 
        public string serviceCode { get; set; } 
    }
    
    public class ProductSpecification    {
        public GsmAhsService gsmAhsService { get; set; } 
        public GsmAhsSubscription gsmAhsSubscription { get; set; } 
        public MadamService madamService { get; set; }
        public AutoVoiceadamService autoVoiceService { get; set; }  
    }
    
    public class Attributes{
        public string simFormat { get; set; } 
        public string iccNumber { get; set; } 
        public string esimMethod { get; set; } 
        public string esimEmail {get; set;}
        public string user { get; set; } 
        public string externalRef { get; set; }
        public string ipRangeStart { get; set; }
        public string siteId { get; set; }
        public string quantity { get; set; } 
        public string ownerSSN { get; set; }
        public string ownerOrgno { get; set; }
        public string ownerLastName { get; set; }
        public string ownerFirstName { get; set; }
        public string ownerPhoneNumber { get; set; }
        public string ownerEmailAddress { get; set; }
        public string requestedPortInDate{ get; set; }
        public string currentOwnerOrgName{ get; set; }
        public string portInDate { get; set; }
        public string temporaryNumber { get; set; }
        public String fixedPhoneNumber {get; set;}
        //for MOB_COSTCONTRL_ABROAD
        public string costControlAmount {get; set;}
        //attribute for MOB_INVOICE_SPLIT_A
        public string firstName {get; set;}
        public string lastName {get; set;}
        public string street {get; set;}
        public string subAgreementId { get; set; }
        public string streetNumber {get; set;}
        public string postalCode {get; set;}
        public string city {get; set;}
        public string country {get; set;}
        public string pointId {get; set;}
        public string entrance {get; set;}
        public string apartmentNumber {get; set;}
        public string careOf {get; set;}
    }
    
    //MCONL-5635 Config Order_comment mapping OP
    public class OrderDataAttributes{
        //public string additionalInfo { get; set; } 
        //public string languageCode { get; set; }
        public string communicationLanguage { get; set; }       
    }
    
    
    
    public class OrderLine    {
        public string dueDate { get; set; } 
        public ProductSpecification productSpecification { get; set; } 
        public Attributes attributes { get; set; } 
        public string productSubcategory { get; set; } 
        public Integer id { get; set; } 
        public string productCategory { get; set; } 
        public string name { get; set; } 
        public string parentAssetIdentifier { get; set; } 
        public Decimal recurringChargeAmount { get; set; } 
        
        public Decimal oneTimeFeeAmount { get; set; }
        public Decimal listPrice { get; set; }
        public Decimal vatRate { get; set; }
        
        //public string destinationSystem { get; set; }
        
        public boolean showInSummary { get; set; } 
        public Integer parentId { get; set; } 
        public string actionCode { get; set; } 
        public string scenario { get; set; }
        public string commitmentTimeUnit { get; set; } 
        public string commitmentTime { get; set; } 
        public string assetIdentifier { get; set; } 
        public string billingAccountId { get; set; } 
        //public string actionCode { get; set; }
        public string productId { get; set; }  
    }
    public class ShippingAddress    {
        public string apartmentNumber { get; set; } 
        public string country { get; set; } 
        public string careOf { get; set; } 
        public string pointId { get; set; } 
        public string streetNumber { get; set; } 
        public string name { get; set; } 
        public string entrance { get; set; } 
        public string street { get; set; } 
        public string postalCode { get; set; } 
        public string attention { get; set; } 
        public string city { get; set; } 
    }
    
    public class SalesTracking    {
        public string retailerId { get; set; } 
        public string resellerId { get; set; } 
        public string userId { get; set; } 
        public string salesChannelId { get; set; } 
        public string salesChannel { get; set; } 
    }
    //shippingAddress
    public class TracingDetails    {
        public string originApplication { get; set; } 
        public string originClientIP { get; set; } 
        public string originClientUserId { get; set; } 
        public string originServerIP { get; set; } 
        public string originTracingId { get; set; } 
    }
    
    public class ContactDetails    {
        public string acceptUnencryptedEmail { get; set; } 
        public string contactMethod { get; set; } 
        public string phoneNumber { get; set; } 
        public string lastName { get; set; } 
        public string firstName { get; set; } 
        public string emailAddress { get; set; } 
    }
    
    public class OrderData    {
        
        //MCONL-5635 Config Order_comment mapping OP
        public OrderDataAttributes attributes { get; set; } 
        
        // public string creditCheckResult {get; set;}
        public TotalPrice totalPrice {get; set;}
        //public boolean creditCheck { get; set; }
        public string scenario { get; set; } 
        public List<Agreement> agreements { get; set; } 
        public BusinessCustomer businessCustomer { get; set; } 
        public List<OrderLine> orderLines { get; set; } 
        public ShippingAddress shippingAddress { get; set; } 
        public SalesTracking salesTracking { get; set; } 
        public TracingDetails tracingDetails { get; set; } 
        public ContactDetails contactDetails { get; set; } 
        public string orderDescription { get; set; } 
        public BillingAccountDetails billingAccountDetails { get; set; } 
    }
    
    public class TotalPrice{
        public Decimal oneTimeFeeAmount { get; set; }
        public Decimal recurringChargeAmount { get; set; }
        public Decimal vatAmount { get; set; }
    }
    
    public class BillingAccountDetails {
        public string accountId {get; set;}
        //public string creditCheckResult {get; set;}
        //public BillingAddress address {get; set;}
    }
    
    public class OrderRequestWrapper    {
        public string brand { get; set; } 
        public string modelVersion { get; set; } 
        public OrderData orderData { get; set; } 
        public string requestedDueDate { get; set; } 
        public string orderType { get; set; } 
        public string orderStatus { get; set; } 
        public object orderRequest { get; set; } 
        public string orderNumber { get; set; } 
        public string orderScenario { get; set; }
    }
}