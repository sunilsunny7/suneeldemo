global class MCONL_OrderProcessor_V2 implements vlocity_cmt.VlocityOpenInterface2 {
    
    private static final String EXCEPTIONVAR = 'Exception';
    private static final String ACTIVATEORDER_ENDPOINT_NAME = 'MCONLINE_ActivateOrder';
    private static final String ACTIVATEORDER_ENDPOINT_NAME_UAT = 'MCONLINE_ActivateOrder_UAT';
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
    
    public class OrderWrapper{
        public Map<String,Object> messages {get; set;}
        public Order order {get; set;}
    }
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    Boolean result = true;
        try { 
            if(methodName.equalsIgnoreCase(SUBMITORDER)) {


                MCONL_OrderProcessor_V2.processOrderRouter(inputMap, outMap);
            }else if(methodName.equalsIgnoreCase(GETORDERDETAILS)) {
                MCONL_OrderProcessor_V2.getOrderDetails(inputMap, outMap);


            }
            else {
                result = false;
            }
            }catch(Exception e) {
                result = false;
                system.debug(EXCEPTIONVAR+' : '+e.getStackTraceString());
                if(System.isBatch()){
                     MCOnline_Utility.logErrorWithoutFuture(e.getStackTraceString(),'INVOKE-400','OrderProcessor','Integration Procedure','','','','');
                }else{
                     MCOnline_Utility.logError(e.getStackTraceString(),'INVOKE-400','OrderProcessor','Integration Procedure','','','','');
                }
            }        
        return result;
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
        Map<String,Object> outMap = (Map<String, Object>) JSON.deserializeUntyped(output);
        processOrderRouter(inputMap, outMap);
        invokeUpdateOrder_IntegrationProcedure(inputMap, outMap);
    }
    public static void invokeUpdateOrder_IntegrationProcedure(Map<String,Object> dataInputMap, Map<String,Object> inputMap){
        Map<String,Object> inputMap1 = new Map<String,Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        string procedureName = 'MCONLINE_UpdateOrderDR_V2';
        inputMap1 = dataInputMap;
        inputMap1.put('RA_Order_Processor', inputMap);
        MCOnline_Utility.invokeIntegrationProcedure(procedureName, inputMap1, outMap, options);
    }
    public static void getOrderDetails(Map<String,Object> inputMap, Map<String,Object> outMap){
        String orderId = String.valueOf(inputMap.get('orderId'));
        Order order = new Order();
        if(orderId != null || orderId != ''){
            order = [SELECT Id, ContractId,MCOnline_OrderNumber__c,MCOnline_CreditCheckResult__c, AccountId, EffectiveDate, EndDate, IsReductionOrder, Description, CustomerAuthorizedById, CompanyAuthorizedById, Type, BillingAddress, ShippingAddress, ActivatedDate, ActivatedById, StatusCode, OrderNumber, TotalAmount, vlocity_cmt__AccountId__c, vlocity_cmt__AccountRecordType__c, vlocity_cmt__AccountSLA__c, vlocity_cmt__BillingName__c, vlocity_cmt__CampaignId__c, vlocity_cmt__CreatedByAPI__c, vlocity_cmt__DefaultCurrencyPaymentMode__c, vlocity_cmt__Delivery_Installation_Status__c, vlocity_cmt__Discount__c, vlocity_cmt__DueDate__c, vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c, vlocity_cmt__EffectiveOrderTotal__c, vlocity_cmt__Email__c, vlocity_cmt__ExpirationDate__c, vlocity_cmt__Fax__c, vlocity_cmt__FrameContractId__c, vlocity_cmt__FulfilmentStatus__c, vlocity_cmt__IsChangesAccepted__c, vlocity_cmt__IsChangesAllowed__c, vlocity_cmt__IsContractRequired__c, vlocity_cmt__IsSyncing__c, vlocity_cmt__JeopardySafetyIntervalUnit__c, vlocity_cmt__JeopardySafetyInterval__c, vlocity_cmt__JeopardyStatus__c, vlocity_cmt__LeadSource__c, vlocity_cmt__MasterOrderName__c, vlocity_cmt__NumberOfContractedMonths__c, vlocity_cmt__OneTimeLoyaltyTotal__c, vlocity_cmt__OpportunityId__c, vlocity_cmt__OrchestrationPlanId__c, vlocity_cmt__OrchestrationPlanReferenceId__c, vlocity_cmt__OrderGroup__c, vlocity_cmt__OrderStatus__c, vlocity_cmt__OrderTotal__c, vlocity_cmt__OriginatingChannel__c, vlocity_cmt__OriginatingContractId__c, vlocity_cmt__Phone__c, vlocity_cmt__PriceListId__c, vlocity_cmt__Pricebook__c, vlocity_cmt__QuoteId__c, vlocity_cmt__QuoteToCity__c, vlocity_cmt__QuoteToCountry__c, vlocity_cmt__QuoteToName__c, vlocity_cmt__QuoteToPostalCode__c, vlocity_cmt__QuoteToState__c, vlocity_cmt__QuoteToStreet__c, vlocity_cmt__RequestDate__c, vlocity_cmt__RequestedCompletionDate__c, vlocity_cmt__ShippingName__c, vlocity_cmt__ShippingPostalCode__c, vlocity_cmt__ShippingState__c, vlocity_cmt__StatusImageName__c, vlocity_cmt__SupersededOrderId__c, vlocity_cmt__Tax__c, vlocity_cmt__ThorJeopardyStatus__c, vlocity_cmt__TrackingNumber__c, vlocity_cmt__ValidationDate__c, vlocity_cmt__ValidationMessage__c, vlocity_cmt__ValidationStatus__c, vlocity_cmt__EffectiveOneTimeTotal__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__TotalMonthlyDiscount__c, vlocity_cmt__TotalOneTimeDiscount__c, vlocity_cmt__RequestedStartDate__c, vlocity_cmt__EffectiveOneTimeCostTotal__c, vlocity_cmt__EffectiveRecurringCostTotal__c, vlocity_cmt__OneTimeMarginTotal__c, vlocity_cmt__OrderMarginTotal__c, vlocity_cmt__RecurringMarginTotal__c, vlocity_cmt__DefaultBillingAccountId__c, vlocity_cmt__DefaultServiceAccountId__c, vlocity_cmt__DefaultServicePointId__c, vlocity_cmt__IsPriced__c, vlocity_cmt__IsValidated__c, vlocity_cmt__LastPricedAt__c, vlocity_cmt__OrderGroupId__c, vlocity_cmt__SubmittedToOmDate__c, vlocity_cmt__EffectiveUsageCostTotal__c, vlocity_cmt__EffectiveUsagePriceTotal__c, vlocity_cmt__MaxCatalogueDeltaObjectIndex__c, vlocity_cmt__ProcessingLog__c, vlocity_cmt__UsageMarginTotal__c, vlocity_cmt__FirstVersionOrderIdentifier__c, vlocity_cmt__IsActiveOrderVersion__c, vlocity_cmt__SupplementalAction__c, TeliaSE_Shipping_Point_Id__c, MCOnline_ContractNumber__c, MCOnline_ContactMethod__c, McOnline_EmailAddress__c, MCOnline_FirstName__c, MCOnline_LastName__c, MCOnline_PhoneNumber__c, MCOnline_ResellerId__c, MCOnline_RetailerId__c, MCOnline_SalesChannel__c, MCOnline_SalesChannelId__c, MCOnline_UserId__c, OrderProcessor_ResponseStatusCode__c, OrderProcessor_Response_Message__c, MCONL_Order_Activation_Status_Code__c, MCONL_Order_Activation_Response__c FROM Order where id=:orderId limit 1];
            
            Map<String, Object> errorMessageMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inputMap.get('RA_Order_Processor')));
            Map<String, Object> errorMessageMap1 = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(errorMessageMap.get('messageMap')));
            OrderWrapper ordWrap = new OrderWrapper();
            ordWrap.order = order;
            ordWrap.messages = errorMessageMap1;
            outMap.put('Response', JSON.deserializeUntyped(JSON.serialize(ordWrap)));
        }
    }
    public static void processOrderRouter(Map<String,Object> inputMap, Map<String,Object> outMap){
        
        String orderId = String.valueOf(inputMap.get('orderId'));
        
     

        InputWrapper inputWrapper = new InputWrapper();
        inputWrapper.contractId = String.valueOf(inputMap.get('contractId'));
        inputWrapper.orderDescription = String.valueOf(inputMap.get('orderDescription'));
        
        
        
        //MCONL-5635 Config Order_comment mapping OP
        //inputWrapper.orderComment = String.valueOf(inputMap.get('orderComment'));
        inputWrapper.creditCheckResult= String.valueOf(inputMap.get('creditCheckResult'));
        
        inputWrapper.languageCode= String.valueOf(inputMap.get('languageCode'));
        
        
        inputWrapper.orderId = String.valueOf(inputMap.get('orderId'));
        inputWrapper.orderType = String.valueOf(inputMap.get('orderType'));
        
        Map<String, Object> contactDetailsMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inputMap.get('contactDetails')));
        Map<String, Object> salesTrackingMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inputMap.get('salesTracking')));
        Map<String, Object> shippingAddressMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inputMap.get('shippingAddress')));
        Map<String, Object> billingAccountMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inputMap.get('billingAccountDetails')));
        if(contactDetailsMap != null){
            inputWrapper.contactMethod = String.valueOf(contactDetailsMap.get('contactMethod'));
            inputWrapper.emailAddress = String.valueOf(contactDetailsMap.get('emailAddress'));
            inputWrapper.firstName = String.valueOf(contactDetailsMap.get('firstName'));
            inputWrapper.lastName = String.valueOf(contactDetailsMap.get('lastName'));
            inputWrapper.phoneNumber = String.valueOf(contactDetailsMap.get('phoneNumber'));
        }
        if(salesTrackingMap != null){
            inputWrapper.resellerId = String.valueOf(salesTrackingMap.get('resellerId'));
            inputWrapper.retailerId = String.valueOf(salesTrackingMap.get('retailerId'));
            inputWrapper.salesChannel = String.valueOf(salesTrackingMap.get('salesChannel'));
            inputWrapper.salesChannelId = String.valueOf(salesTrackingMap.get('salesChannelId'));
            inputWrapper.userId = String.valueOf(salesTrackingMap.get('userId'));
        }
        
        if(shippingAddressMap != null){
            inputWrapper.shippingcity = String.valueOf(shippingAddressMap.get('city'));
            inputWrapper.shippingpointId = String.valueOf(shippingAddressMap.get('pointId'));
            inputWrapper.shippingpostalcode = String.valueOf(shippingAddressMap.get('postalcode'));
            inputWrapper.shippingstreet = String.valueOf(shippingAddressMap.get('street'));
            
            inputWrapper.shippingStreetNumber    =  String.valueOf(shippingAddressMap.get('streetNumber'));
            inputWrapper.shippingName            =  String.valueOf(shippingAddressMap.get('name'));
            inputWrapper.shippingAttention       =  String.valueOf(shippingAddressMap.get('attention'));
            inputWrapper.shippingEntrance        =  String.valueOf(shippingAddressMap.get('entrance'));
            inputWrapper.shippingcountry         =  String.valueOf(shippingAddressMap.get('country'));
            inputWrapper.shippingcareOf          =  String.valueOf(shippingAddressMap.get('careOf'));
            inputWrapper.shippingApartmentNumber =  String.valueOf(shippingAddressMap.get('apartmentNumber'));
        }
        
        //BillingAccountDetails
        if(billingAccountMap != null){
            inputWrapper.billingAccountId       = String.valueOf(billingAccountMap.get('accountId'));
            //inputWrapper.creditCheckResult      = String.valueOf(billingAccountMap.get('creditCheckResult'));
        }
        system.debug('inputWrapper : '+inputWrapper);
        submitOrder(orderId, inputMap, outMap, inputWrapper);
    }
    
    public class InputWrapper {

        public string contractId{get; set;}
        public string orderDescription{get; set;}
        
        //MCONL-5635 Config Order_comment mapping OP
        //public string orderComment{get; set;}
        public string orderId{get; set;}
        public string orderType{get; set;}
        public string languageCode{get; set;}
        
        //contactDetails
        public string contactMethod{get; set;}
        public string emailAddress{get; set;}
        public string firstName{get; set;}
        public string lastName{get; set;}
        public string phoneNumber{get; set;}
        
        //salesTracking
        public string resellerId{get; set;}
        public string retailerId{get; set;}
        public string salesChannel{get; set;}
        public string salesChannelId{get; set;}
        public string userId{get; set;}
        
        //shippingAddress
        public string shippingcity      {get; set;}
        public string shippingpointId   {get; set;}
        public string shippingAttention   {get; set;}
        public string shippingpostalcode{get; set;}
        public string shippingstreet    {get; set;}
        public string shippingStreetNumber    {get; set;}
        public string shippingName            {get; set;}
        public string shippingEntrance        {get; set;}
        public string shippingApartmentNumber {get; set;}
        public string shippingcountry {get; set;}
        public string shippingcareOf {get; set;}
        
        //BillingAccountDetails
        /*
    public string billingApartmentNumber{get; set;}
        public string billingCareOf         {get; set;}
        public string billingCity           {get; set;}
        public string billingCountry        {get; set;}
        public string billingEntrance       {get; set;}
        public string billingName           {get; set;}
        public string billingPointId        {get; set;}
        public string billingPostalCode     {get; set;}
        public string billingStreet         {get; set;}
        public string billingStreetNumber   {get; set;}
        public string billingAttention      {get; set;}
    */
        public string billingAccountId      {get; set;}
        public string creditCheckResult     {get; set;}
    }
    
    
    
    public static void activateOrder(string orderNumber, Order order, Map<String,Object> outMap, Map<String, Object> accessMap){
        string endpoint;
        if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
            endpoint = WebService__c.getAll().get(ACTIVATEORDER_ENDPOINT_NAME_UAT).EndpointURL__c+orderNumber;
        }else{
            endpoint = WebService__c.getAll().get(ACTIVATEORDER_ENDPOINT_NAME).EndpointURL__c+orderNumber;
        }
    
    HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(HTTP_METHOD);
        request.setTimeout(TIMEOUT);
        request.setHeader(CONTENT, APPLICATION_JSON);
        if(!Test.isRunningTest()){
            request.setHeader(AUTHORIZATION, BEARER+accessMap.get(ACCESSTOKEN));
        }
        Http http = new Http();
        if(order.MCONL_Order_Activation_Status_Code__c == null || order.MCONL_Order_Activation_Status_Code__c != string.valueOf('200')){
            HttpResponse response = null;
            if(!Test.isRunningTest()){
                response = http.send(request);
                system.debug('response body : '+response.getBody());
            }else{
                HttpResponse hr = new HttpResponse();
                hr.setStatusCode(200);
                hr.setBody('{"abc":"abc"}');
                response = hr;
            }
            
            outMap.put('opa_ResponseStatusCode', response.getStatusCode());
            if(response != null && response.getStatusCode() != null && response.getStatusCode() == STATUSCODE_200){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                outMap.put('opa_Response', JSON.deserializeUntyped(response.getBody()));
                outMap.put('op_status', ACTIVATED);
                if(System.isBatch()){
                    updateMSISDNStatusWithoutFuture(String.valueOf(order.Id));
                }else{
                    //updateMSISDNStatus(String.valueOf(order.Id));
                }
                
            }else{
                outMap.put('opa_Response', JSON.deserializeUntyped(response.getBody()));
            }
        }
    }
    /*
    @future
    public static void updateMSISDNStatus(string orderId){
        List<OrderItem> oItemList = [select id, MCOnline_MSISDN__c from OrderItem where OrderId =:orderId];
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
  */
    //@future
    public static void updateMSISDNStatusWithoutFuture(string orderId){
        List<OrderItem> oItemList = [select id, MCOnline_MSISDN__c from OrderItem where OrderId =:orderId];
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
    
    public static string getValue(object value1, object value2){
        if(value1 != null){
            return String.ValueOf(value1);
        }else if(value2 != null){
            return String.ValueOf(value2);
        }else{
            return null;
        }
    }
    
    public static void submitOrder(string orderId, Map<String,Object> inputMap, Map<String,Object> outMap, InputWrapper inputWrapper){
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> resultMap = new Map<String, Object>();
        try{
        List<Order> orderList  = new List<Order>();
        if((orderId != null || orderId != '') && (orderId.length() == 15 || orderId.length() == 18)){
            orderList = [SELECT Id, MCOnline_OrderNumber__c,vlocity_cmt__OrderStatus__c, MCONL_Order_Activation_Response__c, MCONL_Order_Activation_Status_Code__c, MCOnline_CreditCheckResult__c,AccountId, status, OrderProcessor_Response__c, OrderProcessor_Request__c, OrderProcessor_ResponseStatusCode__c, MCOnline_ContractNumber__c, MCOnline_ContactMethod__c, McOnline_EmailAddress__c, MCOnline_FirstName__c, MCOnline_LastName__c, MCOnline_PhoneNumber__c, MCOnline_ResellerId__c, MCOnline_RetailerId__c, MCOnline_SalesChannel__c, MCOnline_SalesChannelId__c, MCOnline_UserId__c, Description, OrderNumber, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, TeliaSE_Shipping_Point_Id__c, Type, vlocity_cmt__DueDate__c, vlocity_cmt__ShippingName__c, Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingStateCode, Account.BillingCountryCode, Account.BillingLatitude, Account.BillingLongitude, Account.BillingGeocodeAccuracy, Account.BillingAddress, Account.Name, Account.Org_Nr__c, Account.TSCID__c FROM Order WHERE Id = :orderId limit 1];
            if(orderList != null && orderList.size() > 0){
                outMap.put('status', true);
                submitOrder1(orderList[0].Id, inputMap, outMap, inputWrapper);
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
            system.debug('Exception : '+e.getStackTraceString());
            outMap.put('status', false);
        }
        
    }
    public static void submitOrder1(string orderId, Map<String,Object> inputMap, Map<String,Object> outMap, InputWrapper inputWrapper){
        messageMap = new Map<String, String>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> resultMap = new Map<String, Object>();

        if(orderId == null || orderId==''){
            messageMap.put('OrderIdNotFound', 'orderId is required field.');
        }else{
            List<AuthSession> AuthSessionList = [SELECT Id, SourceIp FROM AuthSession WHERE UsersId = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];

            string ipaddress = (AuthSessionList != null || AuthSessionList.size() > 0) ? AuthSessionList[0].SourceIp : null;
            
            Order order = [SELECT Id, MCOnline_StreetNumber__c,Total_VAT_amount__c,Total_recurring_charge_amount__c,Total_one_time_fee_amount__c, MCOnline_CreditCheckResult__c, MCOnline_OrderComment__c, MCOnline_Billing_Account__c, MCOnline_OrderNumber__c, vlocity_cmt__OrderStatus__c, MCONL_Order_Activation_Response__c, MCONL_Order_Activation_Status_Code__c, AccountId, status, OrderProcessor_Response__c, OrderProcessor_Request__c, OrderProcessor_ResponseStatusCode__c, MCOnline_ContractNumber__c, MCOnline_ContactMethod__c, McOnline_EmailAddress__c, MCOnline_FirstName__c, MCOnline_LastName__c, MCOnline_PhoneNumber__c, MCOnline_ResellerId__c, MCOnline_RetailerId__c, MCOnline_SalesChannel__c, MCOnline_SalesChannelId__c, MCOnline_UserId__c, Description, OrderNumber, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, TeliaSE_Shipping_Point_Id__c, Type, vlocity_cmt__DueDate__c, vlocity_cmt__ShippingName__c, Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingStateCode, Account.BillingCountryCode, Account.BillingLatitude, Account.BillingLongitude, Account.BillingGeocodeAccuracy, Account.BillingAddress, Account.Name, Account.Org_Nr__c, Account.TSCID__c, MCOnline_ShippingAttention__c FROM Order WHERE Id = :orderId limit 1];

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
            if(order.vlocity_cmt__OrderStatus__c != null && !order.vlocity_cmt__OrderStatus__c.equalsIgnoreCase('Activated')){
                contractList = [SELECT id, ContractNumber, Agreement_Nr__c, Org_Nr__c FROM Contract WHERE status = 'Active' AND ( AccountId = :order.AccountId OR Id = :inputWrapper.contractId ) AND RecordType.Name = 'Ramavtal' limit 1];
                
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
                

                List<OrderItem> items = [SELECT Id, MCONL_Additional_Charge__c,MCOnline_Basket_Relation_Id__c,MCOnline_ExternalRef__c, MCONL_Action_Code__c,vlocity_cmt__RootItemId__c, MCOnline_UserName__c,MCONL_multiSubscriptionAssetIdentifier__c,vlocity_cmt__OneTimeCharge__c,MConline_List_Price__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__RecurringCharge__c, MCOnline_ServiceValue__c, MCOnline_ServiceCode__c, MCOnline_ContractId__c, MCOnline_ContractNumber__c, MCOnline_MSISDN__c, MCOnline_CommitmentPeriod__c, MCOnline_CommitmentUnit__c, Quantity, vlocity_cmt__Action__c, vlocity_cmt__OneTimeCost__c, vlocity_cmt__ParentItemId__c, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.C2BC_Category__c, vlocity_cmt__Product2Id__r.C2BC_Subcategory__c, vlocity_cmt__Product2Id__r.MCOnline_ShowInSummary__c, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.Ordering_System__c, vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c,vlocity_cmt__Product2Id__r.Downstream_CategoryData__c, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c FROM OrderItem where OrderId = :order.Id AND vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c not in ('Bundle') order by id ];
                

                List<OrderItem> itemList = [select id, vlocity_cmt__Product2Id__r.ProductCode from OrderItem where Order.Id = :order.Id  AND vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c not in ('Bundle') order by id];
                //MCONL-8762: Subscription Usernamre value on Data SIM to OP
                Map<String, String> datasimMap = new Map<String, String>();
                Map<String, String> datasimMap1 = new Map<String, String>();

                Integer i = 1;
                Map<String, Integer> orderMap = new Map<String, Integer>();
                for(OrderItem item : itemList){
                    orderMap.put(String.valueOf(item.id), i);
                    i = i+1;
                }
                

                for(OrderItem itm: items)
                {
                    if(itm.MCOnline_Basket_Relation_Id__c != null && getAttribute('User_name', itm.vlocity_cmt__JSONAttribute__c) != null && itm.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'voice')
                    {
                        datasimMap.put(itm.MCOnline_Basket_Relation_Id__c, getAttribute('User_name', itm.vlocity_cmt__JSONAttribute__c));
                    }
                    if(itm.MCOnline_Basket_Relation_Id__c != null && getAttribute('EXT_REF_ONLINE', itm.vlocity_cmt__JSONAttribute__c) != null && itm.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'voice')
                    {
                        datasimMap1.put(itm.MCOnline_Basket_Relation_Id__c, getAttribute('EXT_REF_ONLINE', itm.vlocity_cmt__JSONAttribute__c));
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
                oRequestWrapper.requestedDueDate = isNull(String.valueOf(Date.Today()));
                oRequestWrapper.orderType = isNull(getValue(order.Type, inputWrapper.orderType));
                oRequestWrapper.orderNumber = isNull(order.MCOnline_OrderNumber__c);
                
                OrderData orderData = new OrderData();
                orderData.creditCheck = false;
                //orderData.creditCheck = true;
                
                //MCONL-5635 Config Order_comment mapping OP
                OrderDataAttributes attObj = new OrderDataAttributes();
                //Removing as part of enhancement
                //attObj.additionalInfo = isNull(getValue(order.MCOnline_OrderComment__c, inputWrapper.orderComment));
                //attObj.languageCode = inputWrapper.languageCode;
                attObj.communicationLanguage = inputWrapper.languageCode;
                orderData.attributes = attObj;
                
                //MCONL-7857
                TotalPrice totalPrice = new TotalPrice();
                totalPrice.oneTimeFeeAmount = (order.Total_one_time_fee_amount__c).setScale(2);
                totalPrice.recurringChargeAmount = order.Total_recurring_charge_amount__c;
                totalPrice.vatAmount = order.Total_VAT_amount__c;
                orderData.totalPrice = totalPrice;
                
                List<Agreement> agreements = new List<Agreement>();
                Agreement agreement = new Agreement();
                agreement.id = 1;
                if(contractList != null && contractList.size() > 0){
                    agreement.idString = isNull(contractList[0].ContractNumber);
                }
                agreement.additionalInfo = 'SALESFORCE';
                
                Agreement agreement1 = new Agreement();
                agreement1.id = 2;
                if(contractList != null && contractList.size() > 0){
                    agreement1.idString = isNull(contractList[0].Agreement_Nr__c);
                }
                agreement1.additionalInfo = 'MADAM';
                
                agreements.add(agreement);
                agreements.add(agreement1);
                
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
                shipping.pointId            = isNull(getValue(order.TeliaSE_Shipping_Point_Id__c, inputWrapper.shippingpointId));
                shipping.street             = isNull(getValue(order.ShippingStreet, inputWrapper.shippingstreet));
                shipping.postalCode         = isNull(getValue(order.ShippingPostalCode, inputWrapper.shippingpostalcode));
                shipping.city               = isNull(getValue(order.ShippingCity, inputWrapper.shippingcity));
                shipping.attention          = isNull(getValue(order.MCOnline_ShippingAttention__c, inputWrapper.shippingAttention));
                shipping.country            = isNull(getValue(order.ShippingCountry, inputWrapper.shippingcountry));
                shipping.streetNumber       = isNull(getValue(order.MCOnline_StreetNumber__c, inputWrapper.shippingStreetNumber));
                shipping.name               = isNull(getValue(order.vlocity_cmt__ShippingName__c, inputWrapper.shippingName));
                shipping.entrance           = isNull(inputWrapper.shippingEntrance);
                shipping.apartmentNumber    = isNull(inputWrapper.shippingApartmentNumber);
                shipping.careOf             = isNull(inputWrapper.shippingcareOf);
                orderData.shippingAddress   = shipping;
                
                SalesTracking salesTracking = new SalesTracking();
                TracingDetails tracingDetails = new TracingDetails();
                salesTracking.retailerId = isNull(getValue(order.MCOnline_RetailerId__c, inputWrapper.retailerId));
                salesTracking.resellerId = isNull(getValue(order.MCOnline_ResellerId__c, inputWrapper.resellerId));
                salesTracking.userId = isNull(getValue(order.MCOnline_UserId__c, inputWrapper.userId));
                salesTracking.salesChannelId = isNull(getValue(order.MCOnline_SalesChannelId__c, inputWrapper.salesChannelId));
                salesTracking.salesChannel = isNull(getValue(order.MCOnline_SalesChannel__c, inputWrapper.salesChannel));
                
                tracingDetails.originClientIP = isNull(ipaddress);
                orderData.tracingDetails = tracingDetails;
                orderData.salesTracking = salesTracking;
                
                ContactDetails contactDetails           = new ContactDetails();
                contactDetails.acceptUnencryptedEmail   = 'true';
                contactDetails.contactMethod            = 'POST';
                contactDetails.phoneNumber              = isNull(getValue(order.MCOnline_PhoneNumber__c, inputWrapper.phoneNumber));
                contactDetails.lastName                 = isNull(getValue(order.MCOnline_LastName__c, inputWrapper.lastName));
                contactDetails.firstName                = isNull(getValue(order.MCOnline_FirstName__c, inputWrapper.firstName));
                contactDetails.emailAddress             = isNull(getValue(order.McOnline_EmailAddress__c, inputWrapper.emailAddress));
                orderData.contactDetails                = contactDetails;
                
                
                BillingAccountDetails billingAccountDetails = new BillingAccountDetails();
                billingAccountDetails.accountId = isNull(getValue(order.MCOnline_Billing_Account__c, inputWrapper.billingAccountId ));
                //billingAccountDetails.creditCheckResult = isNull(getValue(order.MCOnline_CreditCheckResult__c, inputWrapper.creditCheckResult ));
                orderData.billingAccountDetails = billingAccountDetails;
                //orderData.orderDescription = order.Description;
                orderData.orderDescription = isNull(getValue(order.Description, inputWrapper.orderDescription ));
                orderData.creditCheckResult = isNull(getValue(order.MCOnline_CreditCheckResult__c, inputWrapper.creditCheckResult ));
                
                List<OrderLine> orderLines = new List<OrderLine>();
                for(OrderItem oitem : items){
                    OrderLine orderLine = new OrderLine();
                    orderLine.dueDate = String.valueOf(Date.Today());
                    
                    GsmAhsService gsmAhsService = new  GsmAhsService();
                    GsmAhsSubscription gsmAhsSubscription = new  GsmAhsSubscription();
                    
                    //gsmAhsService
                    list<String> ProductServiceCodes = (oitem.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c != null) ? oitem.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c.split('-') : null;
                    string serviceCode =  (ProductServiceCodes != null && ProductServiceCodes.size() > 0) ? ProductServiceCodes[0] : null;
                    string serviceValue = (ProductServiceCodes != null && ProductServiceCodes.size() > 1) ? ProductServiceCodes[1] : null;
                    
                    gsmAhsService.serviceValue = isNull(serviceValue);
                    gsmAhsService.serviceCode = isNull(serviceCode);
                    
                    //gsmAhsSubscription
                    list<String> ProductSubscriptionType = (oitem.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c != null) ? oitem.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c.split('-') : null;
                    string subscriptionCode =  (ProductSubscriptionType != null && ProductSubscriptionType.size() > 0) ? ProductSubscriptionType[0] : null;
                    string multiSubscriptionCode = (ProductSubscriptionType != null && ProductSubscriptionType.size() > 1) ? ProductSubscriptionType[1] : null;
                    
                    gsmAhsSubscription.subscriptionCode = isNull(subscriptionCode);
                    gsmAhsSubscription.multiSubscriptionCode = isNull(multiSubscriptionCode);

                    //multiSubscriptionAssetIdentifier we will not map

                    //gsmAhsSubscription.multiSubscriptionAssetIdentifier = oitem.MCONL_multiSubscriptionAssetIdentifier__c;
                    if(String.isNotBlank(oitem.MCONL_Additional_Charge__c))
                    {
                        gsmAhsSubscription.additionalCharge=oitem.MCONL_Additional_Charge__c;
                    }
                    
                    ProductSpecification productSpecification = new  productSpecification();
                    productSpecification.gsmAhsService = gsmAhsService;
                    productSpecification.gsmAhsSubscription = gsmAhsSubscription;
                    
                    Attributes attribute = new Attributes();
                    if(oitem.vlocity_cmt__JSONAttribute__c != null){
                        attribute.simFormat = isNull(getAttribute('SIM_Format', oitem.vlocity_cmt__JSONAttribute__c));
                        attribute.iccNumber = isNull(getAttribute('ICC_number', oitem.vlocity_cmt__JSONAttribute__c));
                        attribute.esimMethod = isNull(getAttribute('e-SIM_Method', oitem.vlocity_cmt__JSONAttribute__c));
                        attribute.esimEmail = isNull(getAttribute('Email', oitem.vlocity_cmt__JSONAttribute__c));
                       // orderLine.actionCode = isNull(getAttribute('MConline_Action_Code__c', oitem.vlocity_cmt__JSONAttribute__c));
                        if(getAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c) == null){
                            attribute.user = oitem.MCOnline_UserName__c;
                        }else{
                            attribute.user = isNull(getAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c));



                            //datasimMap.put('datasimuser',isNull(getAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c)));
                        }
                        if(getAttribute('User_name', oitem.vlocity_cmt__JSONAttribute__c) == null && oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'datasim' && datasimMap != null && oitem.MCOnline_Basket_Relation_Id__c != null){
                            attribute.user = datasimMap.get(oitem.MCOnline_Basket_Relation_Id__c);

                        }
                        if(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__JSONAttribute__c) == null){
                            attribute.externalRef = oitem.MCOnline_ExternalRef__c;
                        }else{
                            attribute.externalRef = isNull(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__JSONAttribute__c));



                            //datasimMap1.put('datasimexr',isNull(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__JSONAttribute__c)));
                        }
                        if(getAttribute('EXT_REF_ONLINE', oitem.vlocity_cmt__JSONAttribute__c) == null && oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c == 'datasim' && datasimMap1 != null && oitem.MCOnline_Basket_Relation_Id__c != null){
                            attribute.externalRef = datasimMap1.get(oitem.MCOnline_Basket_Relation_Id__c);
                        }
                    }
                    
                    orderLine.productSpecification  = productSpecification;
                    orderLine.Attributes = attribute;
                    orderLine.productSubcategory  = isNull(oitem.vlocity_cmt__Product2Id__r.C2BC_Subcategory__c);
                    orderLine.id  = orderMap.get(oitem.Id);
                    orderLine.productCategory  = isNull(oitem.vlocity_cmt__Product2Id__r.C2BC_Category__c);
                    orderLine.name  = isNull(oitem.vlocity_cmt__Product2Id__r.Name);
                    orderLine.recurringChargeAmount = oitem.vlocity_cmt__RecurringCharge__c; 
                    


                    /*---Added by Binamra Guha on 07/07/2021---*/
                    /*---------------------OP Mapping List price------------------------*/
                    if(oitem.vlocity_cmt__Product2Id__r.C2BC_Category__c == 'goods'){
                        orderLine.listPrice = (hardwarePriceList.get(oitem.vlocity_cmt__Product2Id__r.ProductCode) != null) ? hardwarePriceList.get(oitem.vlocity_cmt__Product2Id__r.ProductCode) : 0;
                    }else{
                        orderLine.listPrice = (subscriptionPriceList.get(oitem.vlocity_cmt__Product2Id__r.ProductCode) != null) ? subscriptionPriceList.get(oitem.vlocity_cmt__Product2Id__r.ProductCode) : 0;
                    }
                    /*-------------------------------------------------------------------*/




                    /*----- Mapping the ListPrice,VatPercentage and OneTimeFeeAmount towards OP(MCONL-8353) -----*/
                    orderLine.vatRate = vatRate;
                    //orderLine.listPrice = (oitem.MConline_List_Price__c!=null) ? oitem.MConline_List_Price__c:0;
                    orderLine.oneTimeFeeAmount = oitem.vlocity_cmt__OneTimeCharge__c;
                    /*--------------------------------------------------------------------------*/
                    



                    



                    orderLine.parentAssetIdentifier = isNull(oitem.MCONL_multiSubscriptionAssetIdentifier__c); 

                    //orderLine.showInSummary  = (oitem.vlocity_cmt__Product2Id__r.MCOnline_ShowInSummary__c == null || oitem.vlocity_cmt__Product2Id__r.MCOnline_ShowInSummary__c.equalsIgnoreCase('No')) ? false : true;
                    //MCONL-8338

                    if(oitem.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c != null || oitem.vlocity_cmt__Product2Id__r.C2BC_Category__c == 'goods'){


                        orderLine.showInSummary = true;
                    }
                    else{
                        orderLine.showInSummary = false;

                    }

                    //orderLine.parentId  = orderMap.get(oitem.vlocity_cmt__ParentItemId__c);
                    if(oitem.vlocity_cmt__ParentItemId__c!= null){
                    orderLine.parentId  = orderMap.get(oitem.vlocity_cmt__RootItemId__c);
                    }
                    //MCONL-7868
                    //orderLine.productId =  isNull(getAttribute('ATT_HW_SAP_ID', oitem.vlocity_cmt__JSONAttribute__c));
                    if(getAttribute('ATT_HW_SAP_ID', oitem.vlocity_cmt__JSONAttribute__c) != null){
                    orderLine.productId =  isNull(getAttribute('ATT_HW_SAP_ID', oitem.vlocity_cmt__JSONAttribute__c));
                    }
                    else{
                        orderLine.productId = isNull(oitem.vlocity_cmt__Product2Id__r.ProductCode);
                    }
                    //orderLine.productId = 8937823;
                    if(oitem.MCONL_Action_Code__c != null){
                        orderLine.actionCode  = isNull(oitem.MCONL_Action_Code__c);
                    }else{
                    orderLine.actionCode  = 'Add';
                    }
                    orderLine.commitmentTimeUnit  = isNull(oitem.MCOnline_CommitmentUnit__c);
                    orderLine.commitmentTime  = isNull(oitem.MCOnline_CommitmentPeriod__c);
                    orderLine.assetIdentifier  = isNull(oitem.MCOnline_MSISDN__c);
                    if(oitem.vlocity_cmt__JSONAttribute__c != null){
                        orderLine.billingAccountId = isNull(getValue(order.MCOnline_Billing_Account__c, inputWrapper.billingAccountId));
                    }
                    orderLines.add(orderLine);
                }
                orderData.orderLines = orderLines;
                oRequestWrapper.orderData = orderData;
                
                string extractOrder = JSON.serialize(oRequestWrapper);
                string endpointName;
        
         if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
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
                    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonAttribute);
                    List<object> TELIAMOBAGGRList = (List<object>) jsonMap.get('ATT_CODE_TELIAMOBAGGR');
                    for(Object TELIAMOBAGGR : TELIAMOBAGGRList){
                        Map<String, Object> m1= (Map<String, Object>)TELIAMOBAGGR;
                        string attributeName = String.valueOf(m1.get('attributeuniquecode__c'));
                        
                        //BILLING_ACCOUNT
                        if(attributeName != null && attributeName.equalsIgnoreCase('BILLING_ACCOUNT') != null && attributeName.equalsIgnoreCase('BILLING_ACCOUNT') == true  && attributeNameFromParam.equalsIgnoreCase('BILLING_ACCOUNT')){
                            Map<String, Object> attributeRunTimeInfoMap = (Map<String, Object>)m1.get('attributeRunTimeInfo');
                            if(attributeRunTimeInfoMap != null){
                                return String.valueOf(attributeRunTimeInfoMap.get('value'));
                            }
                        }
                        
                        //MSISDN
                        if(attributeName != null && attributeName.equalsIgnoreCase('MSISDN') != null && attributeName.equalsIgnoreCase('MSISDN') == true  && attributeNameFromParam.equalsIgnoreCase('MSISDN')){
                            Map<String, Object> attributeRunTimeInfoMap = (Map<String, Object>)m1.get('attributeRunTimeInfo');
                            if(attributeRunTimeInfoMap != null){
                                return String.valueOf(attributeRunTimeInfoMap.get('value'));
                            }
                        }
                        
                        //HWSAPID
                        if(attributeName != null && attributeName.equalsIgnoreCase('ATT_HW_SAP_ID') != null && attributeName.equalsIgnoreCase('ATT_HW_SAP_ID') == true  && attributeNameFromParam.equalsIgnoreCase('ATT_HW_SAP_ID')){
                            Map<String, Object> attributeRunTimeInfoMap = (Map<String, Object>)m1.get('attributeRunTimeInfo');
                            if(attributeRunTimeInfoMap != null){
                                return String.valueOf(attributeRunTimeInfoMap.get('default'));
                            }
                            //return String.valueOf(m1.get('value__c'));
                        }

                        //TELIA_COMM_PERIOD
                        if(attributeName != null && attributeName.equalsIgnoreCase('TELIA_COMM_PERIOD') != null && attributeName.equalsIgnoreCase('TELIA_COMM_PERIOD') == true  && attributeNameFromParam.equalsIgnoreCase('TELIA_COMM_PERIOD')){
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
                        
                        //TELIA_COMM_UNIT
                        if(attributeName != null && attributeName.equalsIgnoreCase('TELIA_COMM_UNIT') != null && attributeName.equalsIgnoreCase('TELIA_COMM_UNIT') == true  && attributeNameFromParam.equalsIgnoreCase('TELIA_COMM_UNIT')){
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
                        
                        //e-SIM_Method
                        if(attributeName != null && attributeName.equalsIgnoreCase('e-SIM_Method') != null && attributeName.equalsIgnoreCase('e-SIM_Method') == true  && attributeNameFromParam.equalsIgnoreCase('e-SIM_Method')){
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



                        //Email
                        if(attributeName != null && attributeName.equalsIgnoreCase('Email') != null && attributeName.equalsIgnoreCase('Email') == true  && attributeNameFromParam.equalsIgnoreCase('Email')){
                            Map<String, Object> attributeRunTimeInfoMap = (Map<String, Object>)m1.get('attributeRunTimeInfo');
                            if(attributeRunTimeInfoMap != null){
                                return String.valueOf(attributeRunTimeInfoMap.get('value'));
                            }
                        }
                        //EXT_REF_ONLINE
                        if(attributeName != null && attributeName.equalsIgnoreCase('EXT_REF_ONLINE') != null && attributeName.equalsIgnoreCase('EXT_REF_ONLINE') == true  && attributeNameFromParam.equalsIgnoreCase('EXT_REF_ONLINE')){
                            Map<String, Object> attributeRunTimeInfoMap = (Map<String, Object>)m1.get('attributeRunTimeInfo');
                            if(attributeRunTimeInfoMap != null){
                                return String.valueOf(attributeRunTimeInfoMap.get('value'));
                            }
                        }
                        //ICC_number
                        if(attributeName != null && attributeName.equalsIgnoreCase('ICC_number') != null && attributeName.equalsIgnoreCase('ICC_number') == true  && attributeNameFromParam.equalsIgnoreCase('ICC_number')){
                            Map<String, Object> attributeRunTimeInfoMap = (Map<String, Object>)m1.get('attributeRunTimeInfo');
                            if(attributeRunTimeInfoMap != null){
                                return String.valueOf(attributeRunTimeInfoMap.get('value'));
                            }
                        }
                        //Relation_Id
                        if(attributeName != null && attributeName.equalsIgnoreCase('Relation_Id') != null && attributeName.equalsIgnoreCase('Relation_Id') == true  && attributeNameFromParam.equalsIgnoreCase('Relation_Id')){
                            Map<String, Object> attributeRunTimeInfoMap = (Map<String, Object>)m1.get('attributeRunTimeInfo');
                            if(attributeRunTimeInfoMap != null){
                                return String.valueOf(attributeRunTimeInfoMap.get('value'));
                            }
                        }
                        //SIM_Format
                        if(attributeName != null && attributeName.equalsIgnoreCase('SIM_Format') != null && attributeName.equalsIgnoreCase('SIM_Format') == true  && attributeNameFromParam.equalsIgnoreCase('SIM_Format')){
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
                        
                        //User_name
                        if(attributeName != null && attributeName.equalsIgnoreCase('User_name') != null && attributeName.equalsIgnoreCase('User_name') == true  && attributeNameFromParam.equalsIgnoreCase('User_name')){
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

    public class BilliantSubscription    {
        public string subscriptionType { get; set; } 
        public string serviceCode { get; set; } 
    }

    public class ProductSpecification    {
        public GsmAhsService gsmAhsService { get; set; } 
        public GsmAhsSubscription gsmAhsSubscription { get; set; } 
    }

    public class Attributes{
        public string simFormat { get; set; } 
        public string iccNumber { get; set; } 
        public string esimMethod { get; set; } 
        public string esimEmail {get; set;}
        public string user { get; set; } 
        public string externalRef { get; set; } 
    }
    
    //MCONL-5635 Config Order_comment mapping OP
    public class OrderDataAttributes{
        //public string additionalInfo { get; set; } 
        //public string languageCode { get; set; } 
        public string communicationLanguage {get; set;}
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
        
        public string creditCheckResult {get; set;}
        public TotalPrice totalPrice {get; set;}
        public boolean creditCheck { get; set; } 
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
    }
}