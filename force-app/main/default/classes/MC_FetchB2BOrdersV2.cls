/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_FetchB2BOrders 
**Created By  :        Aditi Goyal
**Date      :          27 July 2023
**User Story  :        23.10 LTAART-227: See ongoing orders and deliveries in SF
**Description :        Apex class to fetch and return B2B order information from UOR to display in LWC component on Account level
-----------------------------------------------------------------------------------------------------------*/

global class MC_FetchB2BOrdersV2 {
    private static final String CLASS_NAME = 'MC_FetchB2BOrders';
    
    /**
* @description method called from LWC to fetch orders for each account from MC_B2B_Order__c or from external system
* @param accId recordId of the Account
* @param orgNr C2B OrgNr of the Account
* @return ResponseWrapper returns the list of orders
**/
    @AuraEnabled
    public static ResponseWrapper getRecordsForB2BOrders(String accId,String orgNr){
        ResponseWrapper rs = new ResponseWrapper();
        try{
            List<MC_B2B_Order__c> b2bOrderList = [SELECT Id,MC_Source__c,MC_Order_Number__c,MC_Delivery_Date__c,MC_Requested_Delivery_Date__c,MC_Promised_Date__c,MC_Ordered_By__c,MC_Orderer_Email__c,MC_Product_Info__c,toLabel(MC_Order_Type__c),toLabel(MC_Order_Status__c),MC_Retailer_ID__c 
                                                  FROM MC_B2B_Order__c 
                                                  WHERE MC_Account__c =:accId  AND MC_Main_Order_Item__c = true
                                                  WITH SECURITY_ENFORCED 
                                                  ORDER BY MC_Order_Status__c,MC_Delivery_Date__c DESC]; 
            if(b2bOrderList.size() >0 ){
                rs.uorOrders = b2bOrderList;
                rs.numberOfRecords = b2bOrderList.size();
            }else{
                rs = fetchOrdersCallout(accId,orgNr);
            }
        }catch(Exception exp){         
            System.debug(exp.getStackTraceString());
            System.debug(exp.getLineNumber());
            System.debug(exp.getMessage());
            generateLog('Error','getRecordsForB2BOrders',accId,null,null,null,null,exp);
            rs.numberOfRecords = 0;
            rs.error = 'Exception';
        }
        System.debug(rs);
        return rs;
    }
    
    @AuraEnabled
    public static ResponseWrapper getAddonsForB2BOrders(String accId,String orderNr){
        ResponseWrapper rs = new ResponseWrapper();
        try{
            List<MC_B2B_Order__c> addonsList = [SELECT Id,MC_Order_Number__c,MC_Item_Req_Del_Date__c,MC_Item_Promised_Date__c,MC_Product_Info__c,toLabel(MC_Item_Status__c),MC_Item_Quantity__c 
                                                  FROM MC_B2B_Order__c 
                                                  WHERE MC_Account__c =:accId AND MC_Order_Number__c =:orderNr AND MC_Main_Order_Item__c = false
                                                  WITH SECURITY_ENFORCED 
                                                  ORDER BY MC_Order_Status__c DESC,MC_Delivery_Date__c DESC]; 
            if(addonsList.size() >0 ){
                rs.addons = addonsList;
                rs.numberOfRecords = addonsList.size();
            }else{
                rs.numberOfRecords = 0;
                rs.error = 'No addons found';
            }
        }catch(Exception exp){         
            System.debug(exp.getStackTraceString());
            System.debug(exp.getLineNumber());
            System.debug(exp.getMessage());
            generateLog('Error','getAddonsForB2BOrders',accId,null,null,null,null,exp);
            rs.numberOfRecords = 0;
            rs.error = 'Exception';
        }
        System.debug(rs);
        return rs;
    }
    
    /**
* @description responsible for making the HTTP callout to UOR and logging the transaction
* @param orgNr : orgNr of the Account
* @return  List<MC_B2B_Order__c> returns the list of orders processed
**/
    public static ResponseWrapper fetchOrdersCallout(String accId , String orgNr){
        
        //get the authentication token
        String authToken='';
        Map<String,Object> outMap = new Map<String,Object>();
        TeliaSE_MadamRemoteAction madamAuth = new TeliaSE_MadamRemoteAction();
        
        if(!Test.isRunningTest()){
            madamAuth.invokeMethod('authMethod', new Map<String,Object>(), outMap, new Map<String,Object>());
        }       
        if(outMap.containsKey('AuthResponse') && outMap.get('AuthResponse') != null ){
            Map<String,Object> authMap = (Map<String,Object>)JSON.deserializeUntyped(String.valueOf(outMap.get('AuthResponse')));
            authToken = 'Bearer '+String.valueOf(authMap.get('access_token'));
        }
        
        //get the endpoint from custom settings
        WebService__c data = [SELECT Content_Type__c,EndpointURL__c FROM WebService__c WHERE Name='MC_UOR_CustomerOrders' LIMIT 1];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(data.EndpointURL__c);
        request.setHeader('Content-Type', data.Content_Type__c);
        request.setHeader('Authorization', authToken);
        request.setBody(createRequest(orgNr));
        
        HttpResponse response = http.send(request);
        if(response.getstatusCode() == 200 && response.getbody() != null){
            if(Boolean.valueOf(System.Label.MC_API_Success_Logging)){//logging success request/response only if success logging is enabled
                generateLog('Info','fetchOrdersCallout',accId,response.getstatusCode(),request.getBody(),response.getBody(),request.getEndpoint(),null);
            }
            return processResponse(response.getBody(),accId); 
        }else{
            generateLog('Error','fetchOrdersCallout',accId,response.getstatusCode(),request.getBody(),response.getBody(),request.getEndpoint(),null); //log request/response
            ResponseWrapper rs = new ResponseWrapper();
            rs.uorOrders = null;
            rs.numberOfRecords = 0;
            rs.error = 'HTTP failure';
        }
        return null;
    }
    
     /**
* @description responsible for making the HTTP callout to UOR and logging the transaction
* @param orgNr : orgNr of the Account
* @return  List<MC_B2B_Order__c> returns the list of orders processed
**/
    public static List<MC_B2B_Order__c> fetchAddonsCallout(String accId , String orgNr){
        
        //get the authentication token
        String authToken='';
        Map<String,Object> outMap = new Map<String,Object>();
        TeliaSE_MadamRemoteAction madamAuth = new TeliaSE_MadamRemoteAction();
        
        if(!Test.isRunningTest()){
            madamAuth.invokeMethod('authMethod_AT', new Map<String,Object>(), outMap, new Map<String,Object>());
        }       
        if(outMap.containsKey('AuthResponse') && outMap.get('AuthResponse') != null ){
            Map<String,Object> authMap = (Map<String,Object>)JSON.deserializeUntyped(String.valueOf(outMap.get('AuthResponse')));
            authToken = 'Bearer '+String.valueOf(authMap.get('access_token'));
        }
        
        //get the endpoint from custom settings
        WebService__c data = [SELECT Content_Type__c,EndpointURL__c FROM WebService__c WHERE Name='MC_UOR_CustomerOrderDetails' LIMIT 1];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(data.EndpointURL__c);
        request.setHeader('Content-Type', data.Content_Type__c);
        request.setHeader('Authorization', authToken);
        request.setBody(Json.serialize(new Map<String,String>{'uorOrderId'=>'opt:UAT2-00016162'}));
        
        HttpResponse response = http.send(request);
        System.debug('response_'+response.getbody());
        if(response.getstatusCode() == 200 && response.getbody() != null){
            if(Boolean.valueOf(System.Label.MC_API_Success_Logging)){//logging success request/response only if success logging is enabled
                generateLog('Info','fetchOrdersCallout',accId,response.getstatusCode(),request.getBody(),response.getBody(),request.getEndpoint(),null);
            }
            return processAddons(response.getBody(),accId); 
        }else{
            generateLog('Error','fetchOrdersCallout',accId,response.getstatusCode(),request.getBody(),response.getBody(),request.getEndpoint(),null); //log request/response
            ResponseWrapper rs = new ResponseWrapper();
            rs.uorOrders = null;
            rs.numberOfRecords = 0;
            rs.error = 'HTTP failure';
        }
        return null;
    }
    
    /**
* @description creates the request body in required format with help of wrapper classes
* @param orgNr : orgNr of the Account
* @return requestBody returns the requestBody in string format
**/
    public static String createRequest(String orgNr){
        Request reqBody = new Request();
        SortOrder sortOrder = new SortOrder();
        List<SearchColumns> searchColList = new List<SearchColumns>();
        
        SearchColumns searchColumn = new SearchColumns();
        SearchMap searchMap = new SearchMap();
        searchColumn.name = 'mainorderitem'; //filtering only subscription items    
        searchMap.searchType = 'NOT_EQUALS';
        searchMap.value = 'No';
        searchColumn.search = searchMap;
        searchColList.add(searchColumn);
        
        searchColumn = new SearchColumns();
        searchMap = new SearchMap();
        searchColumn.name = 'customerorderstatus'; //filtering out orders that are cancelled
        searchMap.searchType = 'NOT_EQUALS';
        searchMap.value = 'Cancelled';
        searchColumn.search = searchMap;
        searchColList.add(searchColumn);
       
     /* searchColumn = new SearchColumns();
        searchMap = new SearchMap();
        searchColumn.name = 'customerorderentereddate'; //filtering orders placed within last 3 months
        searchMap.searchType = 'GTE'; //should be GTE
        searchMap.value = String.valueOf(System.Today().addMonths(-3));
        searchColumn.search = searchMap;
        searchColList.add(searchColumn); // Removed this filter as logic is moved to processResponse method */

        reqBody.searchColumns = searchColList;
        
        sortOrder.sortColumn = 'customerorderrequestedcompletiondate'; //sorting based on order completion date/delivery date
        sortOrder.sortDirection = 'desc';
        reqBody.order = sortOrder;
        reqBody.customeridentificationnumber = orgNr;
        
        String req = JSON.serialize(reqBody);
        System.debug('req__'+req);
        return req;
    }
    
    /**
* @description processes the response and insert order records in MC_B2B_Order__c object
* @param responseBody : response body from callout
* @param accId : record Id of the account to be associated with the order records
* @return List<MC_B2B_Order__c> returns the list of orders
**/
    public static ResponseWrapper processResponse(String responseBody,String accId){
        ResponseWrapper rs = new ResponseWrapper();
        Response responseMap = (Response)Json.deserialize(responseBody, Response.class);
        System.debug('responseMap'+responseMap);
        if(responseMap.totalCount != null && Integer.valueOf(responseMap.totalCount) >0){
            System.debug('totalCount_'+Integer.valueOf(responseMap.totalCount));
            List<CustomerOrder> customerOrders = (List<CustomerOrder>)responseMap.customerOrders;
            List<MC_B2B_Order__c> orderList = new List<MC_B2B_Order__c>();
            Map<String, String> mcs = new Map<String, String>();
            for(MC_Order_Channel_Mapping__mdt mcm : MC_Order_Channel_Mapping__mdt.getall().values()){
                mcs.put(mcm.Channel_Code__c,mcm.Label);
            }
            for(CustomerOrder order:customerOrders){
                MC_B2B_Order__c b2bOrder = new MC_B2B_Order__c();
                Date last3Months = System.Today().addMonths(-3);
                Datetime enteredDate = order.customerorderentereddate;
                if(order.customerorderstatus != 'Closed' || (order.customerorderstatus=='Closed' && enteredDate > last3Months))
                {
                    b2bOrder.MC_Account__c = accId;
                    b2bOrder.MC_Source__c = order.sourcesystem;
                    b2bOrder.MC_Channel__c=mcs.containsKey(order.channelid) ? mcs.get(order.channelid) : order.channelid;
                    b2bOrder.MC_Order_Number__c = order.customerorderid;
                    b2bOrder.MC_Ordered_By__c = order.orderername;
                    b2bOrder.MC_Orderer_Email__c = order.ordereremailaddress;
                    b2bOrder.MC_Product_Info__c = order.offeringname;
                    b2bOrder.MC_Order_Status__c = order.customerorderstatus;
                    b2bOrder.MC_Order_Type__c = order.customerordertype;
                    b2bOrder.MC_Retailer_ID__c = order.retailerid;
                    b2bOrder.MC_Main_Order_Item__c = order.mainorderitem == 'Yes'? true : false;
                    b2bOrder.MC_Delivery_Date__c = order.customerordercompletiondate;
                    b2bOrder.MC_Promised_Date__c = order.customerorderpromisedcompletiondate;
                    b2bOrder.MC_Requested_Delivery_Date__c = order.customerorderrequestedcompletiondate;
                    orderList.add(b2bOrder);
                }
            }
            if(orderList.size()>0){
                Database.insert(orderList,false);
            }
            rs.uorOrders = orderList;
            rs.numberOfRecords = orderList.size();
            
        }else{
            rs.uorOrders = null;
            rs.numberOfRecords = 0;
        }   
        return rs;
    }

     /**
* @description processes the response and insert order records in MC_B2B_Order__c object
* @param responseBody : response body from callout
* @param accId : record Id of the account to be associated with the order records
* @return List<MC_B2B_Order__c> returns the list of orders
**/
    public static List<MC_B2B_Order__c> processAddons(String responseBody,String accId){
        ResponseWrapper rs = new ResponseWrapper();
            List<MC_B2B_Order__c> orderList = new List<MC_B2B_Order__c>();
        Response responseMap = (Response)Json.deserialize(responseBody, Response.class);
        System.debug('responseMap'+responseMap);
        if(responseMap.statusMessage != null && String.valueOf(responseMap.statusMessage) == 'OK - order details found'){
            Level2data level2data = responseMap.level2data;
            String orderId = level2data.uororderid;
            List<CustomerOrder> sourceOrders = (List<CustomerOrder>)responseMap.sourcesystemorders;
            Map<String, String> mcs = new Map<String, String>();
            for(MC_Order_Channel_Mapping__mdt mcm : MC_Order_Channel_Mapping__mdt.getall().values()){
                mcs.put(mcm.Channel_Code__c,mcm.Label);
            }
            for(CustomerOrder order:sourceOrders){
                if(order.uorOrderId == orderId){
                    List<OrderItems> orderItems = order.orderItems;
                    if(orderItems.size() > 0){
                        for(OrderItems ordItem:orderItems){
                            if(!Boolean.valueOf(ordItem.mainorderitem)){
                                MC_B2B_Order__c b2bOrder = new MC_B2B_Order__c();
                                b2bOrder.MC_Account__c = accId;
                                b2bOrder.MC_Source__c = mcs.containsKey(responseMap.level2data.channelid) ? mcs.get(responseMap.level2data.channelid) : responseMap.level2data.channelid;
                                b2bOrder.MC_Order_Number__c = ordItem.customerOrderId;
                                b2bOrder.MC_Ordered_By__c = level2data.ordererfirstname+' '+level2data.ordererlastname;
                                b2bOrder.MC_Orderer_Email__c = level2data.ordereremailaddress;
                                b2bOrder.MC_Product_Info__c = ordItem.offeringname;
                                b2bOrder.MC_Order_Status__c = level2data.customerorderstatus;
                                b2bOrder.MC_Order_Type__c = level2data.customerordertype;
                                b2bOrder.MC_Main_Order_Item__c = false;
                                b2bOrder.MC_Item_Quantity__c = ordItem.customerOrderItemQuantity;
                                b2bOrder.MC_Item_Status__c = ordItem.customerOrderItemStatus;
                                b2bOrder.MC_Item_Promised_Date__c = ordItem.customerOrderItemPromisedDeliveryDate;
                                b2bOrder.MC_Item_Req_Del_Date__c = ordItem.customerOrderItemRequestedDeliveryDate;
                                orderList.add(b2bOrder);
                            }
                        }
                    }
                }                
            }
            if(orderList.size()>0){
               // Database.insert(orderList,false);
            }
            rs.uorOrders = orderList;
            rs.numberOfRecords = orderList.size();
            
        }else{
            rs.uorOrders = null;
            rs.numberOfRecords = 0;
        }   
        //return rs;
        return orderList;
    }

    /**
* @description Logs Integration Request Response or Exceptions in Application_Logs__c custom object
**/
    public static void generateLog(String level,String method,String refId,Integer code,String request,String response,String endpoint,Exception exp){
        Application_Logs__c newLog = new Application_Logs__c();
        newLog.Debug_Level__c = level;
        newLog.Source__c = CLASS_NAME;
        newLog.Source_Function__c = method;
        newLog.Reference_Id__c = refId;
        newLog.Log_Code__c = String.valueOf(code);
        newLog.Integration_Payload__c = request;
        if(response != null){
            Integer fieldLength = Schema.SObjectType.Application_Logs__c.fields.Integration_Response__c.getLength();
            newLog.Integration_Response__c = response.length() > fieldLength? response.substring(0,fieldLength):response;
        }
        newLog.Endpoint__c = endpoint;
        newLog.Message__c = exp != null? exp.getMessage():null;
        newLog.Stack_Trace__c = exp!= null? exp.getStackTraceString():null;
        //insert newLog;
    }
    
    public class ResponseWrapper{
        @AuraEnabled public List<MC_B2B_Order__c> uorOrders {get; set;}
        @AuraEnabled public List<MC_B2B_Order__c> addons {get; set;}
        @AuraEnabled public Integer numberOfRecords {get; set;}
        @AuraEnabled public String error {get; set;}
    }
    public class CustomerOrder{
        public String customerorderid,channelid,retailerid,customerordertype,offeringname,sourcesystem,orderername,ordereremailaddress,customerorderstatus,mainorderitem;
        public String uorOrderId;
        public List<OrderItems> orderItems;
        public DateTime customerordercompletiondate,customerorderpromisedcompletiondate,customerorderentereddate,customerorderrequestedcompletiondate;
    }
    public class OrderItems{
        public Integer customerOrderItemQuantity;
        public String customerOrderId,mainorderitem,offeringname,customerOrderItemStatus;
        public DateTime customerOrderItemRequestedDeliveryDate,customerOrderItemPromisedDeliveryDate;
    }
    public class Response{
        public Integer totalCount;
        public String statusMessage;
        public Level2Data level2data;
        public List<CustomerOrder> customerOrders;
        public List<CustomerOrder> sourcesystemorders;
    }
    public class Level2Data{
        public String uororderid,channelid,customerordertype,customerorderstatus,ordereremailaddress,ordererfirstname,ordererlastname;
    }
    public class Request{
        public Integer start = 0,length = 1000000;
        public String customeridentificationnumber;
        public SortOrder order;
        public List<SearchColumns> searchColumns;
    } 
    public class SortOrder{
        public String sortColumn,sortDirection;
    }
    public class SearchColumns{
        public String name;
        public SearchMap search;
    }
    public class SearchMap{
        public Boolean caseSensitive=false;
        public String searchType,value;
    }
}