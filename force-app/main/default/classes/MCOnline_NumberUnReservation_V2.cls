global class MCOnline_NumberUnReservation_V2 
{
  public static UnReservationResponseWrapper unreserveMsisdn(Set<String> msisdnSet, string tscid)
  {
    
            List<String> msisdnList = new List<String>(msisdnSet);
                
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
                rrm.reservationTSCID = tscid;
                rrm.reservationNumber = '0';
                rrm.returnCode = '';
    
                
                Message message = new Message();
                message.rrm = rrm;
                message.header = header;
                
                wrap.message = message;
    
                Map<String, Object> accessMap = null;
                if(!Test.isRunningTest()){
        
                    if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
                        accessMap = (Map<String, Object>) JSON.deserializeUntyped(TeliaSE_MadamAuthenticationWS_UAT.makePostCallout());
                    }else{
                        accessMap = (Map<String, Object>) JSON.deserializeUntyped(TeliaSE_MadamAuthentication.makePostCallout());
                    }
    
                }
                string endpointName;
                if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
                    endpointName = 'MCONLINE_UnReserveNumberUAT';
                }else{
                    endpointName = 'MCONLINE_UnReserveNumber';
                }
                
                HttpRequest request = new HttpRequest();
    
                string endpoint = String.valueOf(WebService__c.getAll().get(endpointName).EndpointURL__c);
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setTimeout(120000);
                request.setHeader('Content-Type', 'application/json');
                if(accessMap != null){
                    request.setHeader('Authorization', 'Bearer '+accessMap.get('access_token'));
                }
                request.setBody(JSON.serialize(wrap));
                Http p = new Http();
                HttpResponse response = null;
                if(!Test.isRunningTest()){
                    response = p.send(request);
                }           
                UnReservationResponseWrapper responseWrap = new  UnReservationResponseWrapper();
                if(response !=  null)
                {
                  responseWrap.response = response.getBody();
                  responseWrap.status= response.getStatusCode();
                }
                responseWrap.endpoint = endpoint;
                responseWrap.requestBody = JSON.serialize(wrap);
           
                return responseWrap;
  }
  public class UnReservationResponseWrapper {
    public string response;
    public String endpoint;
    public String requestBody;
    public integer status;
    
   }
  
  public class Header{

        public String msgid {get; set;}
        public String msgcreationdatetime{get; set;}
        public String sendingsystem{get; set;}
        public String sendingname{get; set;}
    }

    public class Rrm{
        public String trafficSystem{get; set;}
        public String startMSISDN{get; set;}
        public String endMSISDN{get; set;}
        public String reservationNumber{get; set;}
        public String reservationTSCID{get; set;}
        public String returnCode{get; set;}
    }

    public class Message{
        public Header header{get; set;}
        public Rrm rrm{get; set;}
    }

    public class NumberUnReservationWrapper{
        public Message message{get; set;}

    }
}