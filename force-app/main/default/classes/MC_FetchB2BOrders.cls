/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_FetchB2BOrders 
**Created By  :        Aditi Goyal
**Date      :          27 July 2023
**User Story  :        23.10 LTAART-227: See ongoing orders and deliveries in SF
**Description :        Apex class to fetch and return B2B order information from UOR to display in LWC component on Account level
-----------------------------------------------------------------------------------------------------------*/

global class MC_FetchB2BOrders {
    private static final String CLASS_NAME = 'MC_FetchB2BOrders';
    private static String authToken = '';
    private static WebService__c addonsWS;
    
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
            List<MC_B2B_Order__c> b2bOrderList = queryRecords(accId,null,true);
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
            MC_Utility.generateLog('Error','getRecordsForB2BOrders',CLASS_NAME,accId,null,null,null,null,exp);
            rs.numberOfRecords = 0;
            rs.error = 'Exception -'+exp.getMessage()+' '+exp.getLineNumber();
        }
        return rs;
    }
    
    /**
* @description responsible for making the HTTP callout to UOR and logging the transaction
* @param orgNr : orgNr of the Account
* @return  List<MC_B2B_Order__c> returns the list of orders processed
**/
    public static ResponseWrapper fetchOrdersCallout(String accId , String orgNr){
        
        String authToken = MC_Utility.getMadamAuthToken();
        WebService__c data = MC_Utility.getEndpointInfo('MC_UOR_CustomerOrders');
        Http http = new Http();
        HttpRequest request = MC_Utility.buildHttpRequest('POST',data.EndpointURL__c,data.Content_Type__c,authToken,createRequest(orgNr));
        HttpResponse response = http.send(request);
        
        if(response.getstatusCode() == 200 && response.getbody() != null){
            if(Boolean.valueOf(System.Label.MC_API_Success_Logging)){//logging success request/response only if success logging is enabled
                MC_Utility.generateLog('Info','fetchOrdersCallout',CLASS_NAME,accId,response.getstatusCode(),request.getBody(),response.getBody(),request.getEndpoint(),null);
            }
            return processResponse(response.getBody(),accId); 
        }else{
            MC_Utility.generateLog('Error','fetchOrdersCallout',CLASS_NAME,accId,response.getstatusCode(),request.getBody(),response.getBody(),request.getEndpoint(),null); //log request/response
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
        reqBody.searchColumns = searchColList;
        
        sortOrder.sortColumn = 'customerorderrequestedcompletiondate'; //sorting based on order completion date/delivery date
        sortOrder.sortDirection = 'desc';
        reqBody.order = sortOrder;
        reqBody.customeridentificationnumber = orgNr;
        
        String req = JSON.serialize(reqBody);
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
        if(responseMap.totalCount != null && Integer.valueOf(responseMap.totalCount) >0){
            List<CustomerOrder> customerOrders = (List<CustomerOrder>)responseMap.customerOrders;
            List<MC_B2B_Order__c> orderList = new List<MC_B2B_Order__c>();
            Map<String, String> mcs = new Map<String, String>();
            for(MC_Order_Channel_Mapping__mdt mcm : MC_Order_Channel_Mapping__mdt.getall().values()){
                mcs.put(mcm.Channel_Code__c,mcm.Label);
            }
            List<String> changeOrders = new List<String>();
            for(CustomerOrder order:customerOrders){
                MC_B2B_Order__c b2bOrder = new MC_B2B_Order__c();
                Date last3Months = System.Today().addMonths(-3);
                Datetime enteredDate = order.customerorderentereddate;
                Datetime registeredDate= order.customerorderregistereddate;
                if(order.customerorderstatus != 'Closed' || (order.customerorderstatus=='Closed' && (enteredDate > last3Months || registeredDate > last3Months)))
                {
                    b2bOrder.MC_Account__c = accId;
                    b2bOrder.MC_Source__c = String.valueOf(order.sourcesystem)?.capitalize();
                    b2bOrder.MC_Channel__c=mcs.containsKey(order.channelid) ? mcs.get(order.channelid) : order.channelid;
                    b2bOrder.MC_Order_Number__c = order.customerorderid;
                    b2bOrder.MC_UOR_OrderId__c = order.uororderid;
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
                    if(order.customerordertype == 'Change'){
                        changeOrders.add(order.uororderid);
                    }
                    orderList.add(b2bOrder);
                }
            }
            if(orderList.size()>0){
                Database.insert(orderList,false);
            }
            //querying inserted records to fetch in correct sequence and with swedish picklist labels
            List<MC_B2B_Order__c> b2bOrderList =  queryRecords(accId,null,true);
            rs.uorOrders = b2bOrderList;
            rs.changeOrderIds = changeOrders;
            rs.numberOfRecords = b2bOrderList.size();
            
        }else{
            rs.uorOrders = null;
            rs.changeOrderIds = null;
            rs.numberOfRecords = 0;
        }   
        return rs;
    }
        
  /**
* @description method called from LWC on first load to fetch addons for multiple orders in a loop from UOR (5 orders at a time)
* @param changeOrders list of uorOrderIds of Change orders
* @param accId Id of the Account
* @return true/false
**/
    @AuraEnabled
    public static Boolean fetchAddonsApiCall(List<String> changeOrders,String accId){
        List<MC_B2B_Order__c> insertOrders = new List<MC_B2B_Order__c>();
        ResponseWrapper rs = new ResponseWrapper();
        try{
            if(changeOrders.size() >0){
                for(String ordNr : changeOrders){
                    rs = fetchAddonsCallout(accId,ordNr);
                    if(rs.addons != null && rs.addons.size()>0){
                        insertOrders.addAll(rs.addons);
                    }
                }
                if(insertOrders.size()>0){
                    Database.insert(insertOrders,false);
                    return true;
                }else{
                    return false;
                }
            }
        }
        catch(Exception exp){         
            System.debug(exp.getStackTraceString());
            System.debug(exp.getLineNumber());
            System.debug(exp.getMessage());
            MC_Utility.generateLog('Error','fetchAddonsApiCall',CLASS_NAME,accId,null,JSON.serialize(changeOrders),null,null,exp);
            rs.error = 'Exception -'+exp.getMessage()+' '+exp.getLineNumber();
        }
        return false;
    }
    
  /**
* @description method called from LWC when popup window is invoked for any order
* @param accId Id of the Account
* @param orderNr uorOrderId of the order in popup
* @return ResponseWrapper returns the list of addon order records
**/
    @AuraEnabled
    public static ResponseWrapper getAddonsForB2BOrders(String accId,String orderNr){
        ResponseWrapper rs = new ResponseWrapper();
        try{
            List<MC_B2B_Order__c> addonsList =  queryRecords(accId,orderNr,false);
            if(addonsList.size() >0 ){
                rs.addons = addonsList;
                rs.numberOfRecords = addonsList.size();
            }else{
                rs = fetchAddonsCallout(accId,orderNr);
                if(rs.addons != null && rs.addons.size()>0){
                    Database.insert(rs.addons,false);
                }
                rs.addons = queryRecords(accId,orderNr,false);
            }
        }catch(Exception exp){         
            System.debug(exp.getStackTraceString());
            System.debug(exp.getLineNumber());
            System.debug(exp.getMessage());
            MC_Utility.generateLog('Error','getAddonsForB2BOrders',CLASS_NAME,accId+'-'+orderNr,null,null,null,null,exp);
            rs.numberOfRecords = 0;
            rs.error = 'Exception';
        }
        return rs;
    }
    
     /**
* @description responsible for making the HTTP callout to UOR to fetch addons of a particalur order
* @param accId : Id of the Account
* @param ordNr : UorOrderId of the Order
* @return ResponseWrapper returns the list of addons processed
**/
    public static ResponseWrapper fetchAddonsCallout(String accId , String ordNr){
        Map<String,Object> outMap = new Map<String,Object>();
        String req = Json.serialize(new Map<String,String>{'uorOrderId'=>ordNr});
        if(String.isBlank(authToken)){
            authToken = MC_Utility.getMadamAuthToken();
        }
        if(addonsWS == null){
            addonsWS = MC_Utility.getEndpointInfo('MC_UOR_CustomerOrderDetails');
        }
        Http http = new Http();
        HttpRequest request = MC_Utility.buildHttpRequest('POST',addonsWS.EndpointURL__c,addonsWS.Content_Type__c,authToken,req);
        HttpResponse response = http.send(request);
        if(response.getstatusCode() != 200 && response.getStatus() == 'Unauthorized'){ //expired authToken
             authToken = MC_Utility.getMadamAuthToken();
             response = http.send(request);
        }
        if(response.getstatusCode() == 200 && response.getbody() != null){
            return processAddons(response.getBody(),accId); 
        }
        else{
            MC_Utility.generateLog('Error','fetchOrdersCallout',CLASS_NAME,accId,response.getstatusCode(),request.getBody(),response.getBody(),request.getEndpoint(),null); //log request/response
            ResponseWrapper rs = new ResponseWrapper();
            rs.uorOrders = null;
            rs.numberOfRecords = 0;
            rs.error = 'HTTP failure';
            return rs;
        }
    }
    
    /**
* @description processes the response and insert order records for addons in MC_B2B_Order__c object
* @param responseBody : response body from callout
* @param accId : record Id of the account to be associated with the order records
* @return ResponseWrapper returns the list of addon order records
**/
    public static ResponseWrapper processAddons(String responseBody,String accId){
        ResponseWrapper rs = new ResponseWrapper();
        List<MC_B2B_Order__c> orderList = new List<MC_B2B_Order__c>();
        Response responseMap = (Response)Json.deserialize(responseBody, Response.class);
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
                                b2bOrder.MC_Source__c = String.valueOf(order.sourcesystem)?.capitalize();
                                b2bOrder.MC_Channel__c=mcs.containsKey(responseMap.level2data.channelid) ? mcs.get(responseMap.level2data.channelid) : responseMap.level2data.channelid;
                                b2bOrder.MC_Order_Number__c = ordItem.customerOrderId;
                                b2bOrder.MC_UOR_OrderId__c = order.uorOrderId;
                                b2bOrder.MC_Ordered_By__c = level2data.ordererfirstname+' '+level2data.ordererlastname;
                                b2bOrder.MC_Orderer_Email__c = level2data.ordereremailaddress;
                                b2bOrder.MC_Product_Info__c = ordItem.offeringname;
                                b2bOrder.MC_Order_Status__c = level2data.customerorderstatus;
                                b2bOrder.MC_Order_Type__c = level2data.customerordertype;
                                b2bOrder.MC_Main_Order_Item__c = false;
                                b2bOrder.MC_Item_Quantity__c = String.isNotBlank(ordItem.customerOrderItemQuantity) ? Integer.valueOf(ordItem.customerOrderItemQuantity):null;
                                b2bOrder.MC_Item_Status__c = ordItem.customerOrderItemStatus;
                                b2bOrder.MC_Item_Promised_Date__c = ordItem.customerOrderItemPromisedDeliveryDate;
                                b2bOrder.MC_Item_Req_Del_Date__c = ordItem.customerOrderItemRequestedDeliveryDate;
                                orderList.add(b2bOrder);
                            }
                        }
                    }
                }                
            }
            rs.addons = orderList;
            rs.numberOfRecords = orderList.size();
        }else{
            rs.addons = orderList;
            rs.numberOfRecords = 0;
        }
        return rs;
    }
    
    public static List<MC_B2B_Order__c> queryRecords(String accId,String uorOrdId,Boolean flag){
        String orderFields = 'Id,MC_Source__c,MC_Channel__c,MC_Order_Number__c,MC_UOR_OrderId__c,MC_Delivery_Date__c,MC_Requested_Delivery_Date__c,MC_Promised_Date__c,MC_Ordered_By__c,toLabel(MC_Order_Type__c),MC_Orderer_Email__c,MC_Product_Info__c,toLabel(MC_Order_Status__c),MC_Retailer_ID__c';
        String addonFields = 'Id,MC_Order_Number__c,MC_Item_Req_Del_Date__c,MC_Item_Promised_Date__c,MC_Product_Info__c,toLabel(MC_Item_Status__c),MC_Item_Quantity__c';
        String extractQuery = 'SELECT '+ (flag ?orderFields:addonFields) + ' FROM MC_B2B_Order__c WHERE MC_Account__c =:accId AND MC_Main_Order_Item__c =:flag'+(flag ?'':' AND MC_UOR_OrderId__c =:uorOrdId') + ' WITH SECURITY_ENFORCED ORDER BY MC_Order_Status__c,MC_Delivery_Date__c DESC';
        return Database.query(extractQuery);
    }
    
    public class ResponseWrapper{
        @AuraEnabled public List<MC_B2B_Order__c> uorOrders {get; set;}
        @AuraEnabled public List<MC_B2B_Order__c> addons {get; set;}
        @AuraEnabled public List<String> changeOrderIds {get; set;}
        @AuraEnabled public Integer numberOfRecords {get; set;}
        @AuraEnabled public String error {get; set;}
    }
    public class CustomerOrder{
        public String customerorderid,channelid,sourcesystem,retailerid,customerordertype,offeringname,orderername,ordereremailaddress,customerorderstatus,mainorderitem;
        public String uorOrderId;
        public List<OrderItems> orderItems;
        public DateTime customerorderregistereddate,customerordercompletiondate,customerorderpromisedcompletiondate,customerorderentereddate,customerorderrequestedcompletiondate;
    }
    public class OrderItems{
        public String customerOrderItemQuantity;
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
        public Integer start = 0,length = Integer.valueOf(System.Label.MC_UOR_OrderLength);
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