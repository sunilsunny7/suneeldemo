global class MCOnline_NumberUnReservationFromBatch_V2 {
    public static void deleteBasket(string basketName){
        List<MCOnline_Basket__c> basketList = [SELECT id, MCOnline_ParentBasket__c from MCOnline_Basket__c WHERE (Name = : basketName AND MCOnline_ParentBasket__r.Is_Processed__c = false) OR (Name = : basketName AND MCOnline_Is_Processed__c = false AND MCOnline_Message__c != null)];
        
        if(basketList !=  null && basketList.size() > 0){
            List<MCOnline_Basket__c> basketList1 = [SELECT id, MCOnline_ParentBasket__c from MCOnline_Basket__c WHERE MCOnline_ParentBasket__c = :basketList[0].MCOnline_ParentBasket__c];
        
            if(basketList1 != null && basketList1.size() == 1){
                
                List<MCOnline_ParentBasket__c> parentBasketList = [SELECT id from MCOnline_ParentBasket__c where id =:basketList[0].MCOnline_ParentBasket__c];
                system.debug('parentBasketList'+parentBasketList);
                system.debug('basketList1'+basketList1);
                delete basketList1;
                delete parentBasketList;
            }else{
                system.debug('basketList'+basketList);
                delete basketList;
            }
        }
    }
    
    public static void unreserveMSISDN(String basketName){
        system.debug('basketName'+basketName);
       List<MCOnline_Basket__c> basketList1 = [SELECT id, TSCID__C, MCOnline_AttributeJSON__c from MCOnline_Basket__c WHERE (Name = : basketName AND MCOnline_ParentBasket__r.Is_Processed__c = false) OR (Name = : basketName AND MCOnline_Is_Processed__c = false AND MCOnline_Message__c != null) limit 1];
        system.debug('basketList1'+basketList1);
       if( basketList1 != null && basketList1.size() > 0){
           Map<String,Object> productsMap = (Map<String,Object>)JSON.deserializeUntyped(basketList1[0].MCOnline_AttributeJSON__c);
           string tscid = basketList1[0].TSCID__C;
           system.debug('tscid-->'+tscid);
           system.debug('productsMap'+productsMap);
           Set<String> msisdnSet = new Set<String>();
           List<Object> prodList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(productsMap.get('products')));
           system.debug('prodList'+prodList);
           if(prodList != null && prodList.size() > 0){
               for(Object productObj : prodList){
                   Map<String,Object> productMap = (Map<String,Object>)productObj;
                   Map<String,Object> attributeMap = (Map<String,Object>)productMap.get('attributes');
                   if( attributeMap != null && attributeMap.get('MSISDN') != null){
                       string msisdn = String.valueOf(attributeMap.get('MSISDN'));
                       msisdnSet.add(msisdn);
                       system.debug('msisdn'+msisdn);
                   }
               }
           }
           
           system.debug('msisdnSet'+msisdnSet);
           List<MCONL_MSISDN__c> MSISDNToBeUpdatedList = new List<MCONL_MSISDN__c>();
           system.debug('msisdnSet == '+msisdnSet);
           if(msisdnSet != null && msisdnSet.size() > 0){
               if(msisdnSet != null && msisdnSet.size() > 0){
                   for(String str : msisdnSet){
                       Set<String> msisdnSet1 = new Set<String>();
                       if(str != null){
                           msisdnSet1.add(str);
                               List<MCONL_MSISDN__c> msisdnList = unreserveMSISDN(msisdnSet1, basketName, tscid);
                               if(msisdnList != null && msisdnList.size() > 0){
                                   MSISDNToBeUpdatedList.addAll(msisdnList);
                               }
                       }
                   }
               }
           }
           system.debug('MSISDNToBeUpdatedList'+MSISDNToBeUpdatedList);
           if(MSISDNToBeUpdatedList != null && MSISDNToBeUpdatedList.size() > 0){
               update MSISDNToBeUpdatedList;
           }
           system.debug('MSISDNToBeUpdatedList'+MSISDNToBeUpdatedList);
           deleteBasket(basketName);
       }
        
    }
    public static string token;
    public static List<MCONL_MSISDN__c> unreserveMSISDN(Set<String> msisdnSet, string basketName, string tscid){
        system.debug('msisdnSet'+msisdnSet);
        system.debug('basketName'+basketName);
        if(msisdnSet != null && msisdnSet.size() > 0){
            List<String> msisdnList = new List<String>(msisdnSet);
            List<MCONL_MSISDN__c> MSISDNList1 = [select id, Status__c, LineItemKey__c, CartContextKey__c, Number__c from MCONL_MSISDN__c WHERE Number__c =:MSISDNList[0] AND Status__c=:'Reserve' order by createddate desc];
            if(MSISDNList1 != null && MSISDNList1.size() > 0){       
                String currentTimeStr =String.valueOf(DateTime.now());
                currentTimeStr = currentTimeStr.replace('-', '');
                currentTimeStr = currentTimeStr.replace(' ', '');
                currentTimeStr = currentTimeStr.replace(':', '');
                
                NumberUnReservationWrapper wrap = new NumberUnReservationWrapper();
                Header header = new Header();
                
                header.msgid = String.valueOf(DateTime.now().getTime());
                header.msgcreationdatetime = currentTimeStr;
                header.sendingsystem = 'AMANDA';
                header.sendingname = 'SALESFORCE';
                
                Rrm rrm = new Rrm();
                rrm.trafficSystem = 'GSM';
                rrm.startMSISDN = msisdnList[0];
                rrm.endMSISDN = msisdnList[0];
                rrm.reservationNumber = '0';
                rrm.reservationTSCID = tscid;
                rrm.returnCode = '';
                
                Message message = new Message();
                message.rrm = rrm;
                message.header = header;
                
                wrap.message = message;
                string accessToken = null;
                Map<String, Object> accessMap;
                 if(String.isBlank(token) && !Test.isRunningTest()){
                    accessMap = (Map<String, Object>) JSON.deserializeUntyped(TeliaSE_MadamAuthentication.makePostCallout());
                    token = String.valueOf(accessMap.get('access_token'));
                }
                string endpoint = String.valueOf(WebService__c.getAll().get('MCONLINE_UnReserveNumber').EndpointURL__c);
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setTimeout(120000);
                request.setHeader('Content-Type', 'application/json');
                if(token!= null){
                    
                }
                request.setHeader('Authorization', 'Bearer '+token);
                request.setBody(JSON.serialize(wrap));
                Http p = new Http();
                HttpResponse response;
                if(!Test.isRunningTest()){
                    response = p.send(request);
                }
                
                
                
                
                system.debug('response : '+response);
                if(response != null && response.getStatusCode() != null && response.getStatusCode() == 202){
                    List<MCONL_MSISDN__c> MSISDNToBeUpdatedList = new List<MCONL_MSISDN__c>();
                    if(MSISDNList1 != null && MSISDNList1.size() > 0){
                        for(MCONL_MSISDN__c msisdnObj : MSISDNList1){
                            msisdnObj.Status__c = 'Un Reserve';
                            msisdnObj.Unreservation_Endpoint__c = endpoint;
                            msisdnObj.Unreservation_Request__c = JSON.serialize(wrap);
                            msisdnObj.Unreservation_Response__c = response.getBody();
                            MSISDNToBeUpdatedList.add(msisdnObj);
                            //return msisdnObj;
                        }
                        return MSISDNToBeUpdatedList;
                    }
                }else{
                    return null;
                }
            }
        }
        //system.debug('Working');
        //deleteBasket(basketName);
        return null;
    }
    
    public class Header{
        public String msgid;
        public String msgcreationdatetime;
        public String sendingsystem;
        public String sendingname;
    }

    public class Rrm{
        public String trafficSystem;
        public String startMSISDN;
        public String endMSISDN;
        public String reservationNumber;
        public String reservationTSCID;
        public String returnCode;
    }

    public class Message{
        public Header header;
        public Rrm rrm;
    }

    public class NumberUnReservationWrapper{
        public Message message;
    }

}