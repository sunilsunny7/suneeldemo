global class MCOnline_NumberReservationStatus_V2 {
    
    public static ReservationResponseWrapper checkMSISDN_Availability(Set<String> msisdnSet, string tscid){
        
        String currentTimeStr =String.valueOf(DateTime.now());
        currentTimeStr = currentTimeStr.replace('-', '');
        currentTimeStr = currentTimeStr.replace(' ', '');
        currentTimeStr = currentTimeStr.replace(':', '');
        
        String futureTimeStr =String.valueOf(DateTime.now().addDays(30));
        futureTimeStr = futureTimeStr.replace('-', '');
        futureTimeStr = futureTimeStr.replace(' ', '');
        futureTimeStr = futureTimeStr.replace(':', '');
        
        NumberReservationWrapper wrap = new NumberReservationWrapper();
        Header header = new Header();
        
        header.msgid = String.valueOf(DateTime.now().getTime());
        header.msgcreationdatetime = currentTimeStr;
        header.sendingsystem = 'AMANDA'; // GSM
        header.sendingname = 'SALESFORCE'; //mybusiness
        header.msganswercode ='';
        header.msgcode='GRS';
        header.msgextension='';
        header.msgparadigm='S';
        header.msgversion='001';
        header.password='';
        
        List<String> msisdnListstr = new List<String>(msisdnSet);          
        Grs grs = new Grs();
        grs.msisdn=msisdnListstr[0];
        grs.returnCode='';
        grs.status='';

        grs.trafficSystem='GSM'; //   GSM / BIL  ?
        
        Message message = new Message();
        message.grs = grs;
        message.header = header;
        wrap.message = message;
        
        string endpointName;
        if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
            endpointName = 'MCONLINE_ReserveStatusUAT';
        }else{
            endpointName = 'MCONLINE_ReserveStatus';
        }
        system.debug('endpointName'+endpointName);
        string endpoint = String.valueOf(WebService__c.getAll().get(endpointName).EndpointURL__c);

        Map<String, Object> accessMap;
        if(!Test.isRunningTest()){
            if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
                accessMap = (Map<String, Object>) JSON.deserializeUntyped(TeliaSE_MadamAuthenticationWS_UAT.makePostCallout());
            }else{
                accessMap = (Map<String, Object>) JSON.deserializeUntyped(TeliaSE_MadamAuthentication.makePostCallout());
            }
        }
        system.debug('Number Reservation Request : '+JSON.serialize(wrap));
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'application/json');

        if(accessMap != null && accessMap.get('access_token') != null){
            request.setHeader('Authorization', 'Bearer '+accessMap.get('access_token'));
        }
        
        request.setBody(JSON.serialize(wrap));
        Http p = new Http();
        HttpResponse response;
        if(!Test.isRunningTest()){
            response = p.send(request);
            system.debug('=====response=====>'+response);
        }
        ReservationResponseWrapper responseWrap = new  ReservationResponseWrapper();
        if(response !=  null){
            responseWrap.response = response.getBody();
        }
        
        responseWrap.endpoint = endpoint;
        responseWrap.requestBody = JSON.serialize(wrap);
        responseWrap.msisdnSet = msisdnSet;
        
        return responseWrap;
    }
    
    public class ReservationResponseWrapper {
        public string response;
        public String endpoint;
        public String requestBody;
        public Set<String> msisdnSet;
    }
    
    public class Header{
        public String msgid;
        public String msgcreationdatetime;
        public String sendingsystem;
        public String sendingname;
        public String msganswercode;
        public String msgcode;
        public String msgextension;
        public String msgparadigm;
        public String msgversion;
        public String password;
        
    }

    public class Grs{
        public String msisdn;
        public String returnCode;
        public String status;
        public String trafficSystem;
    }

    public class Message{
        public Header header;
        public Grs grs;
    }

    public class NumberReservationWrapper {
        public Message message;
    }
}