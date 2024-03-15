global class MCOnline_NumberReservation_V2 {
    
    public static ReservationResponseWrapper reserveMsisdn(Set<String> msisdnSet, string tscid, string productCategory){
        
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
        header.sendingsystem = 'AMANDA';
        header.sendingname = 'SALESFORCE';
        
        Srp srp = new Srp();

        if(productCategory=='Mobilebroadbandsubscription')
        {
            srp.msisdntype = 'MBB';
        }
        else if(productCategory=='mobilevoicesubscription')
        {
            srp.msisdntype = 'VOICE';
        }
        else
        {
            srp.msisdntype = 'ANY';
        }

        srp.trafficSystem = 'GSM';

        ListOfMSISDN listOfMSISDN1 = new ListOfMSISDN();        
        listOfMSISDN1.retNoOfIntMSISDN = String.valueOf(msisdnSet.size());
        listOfMSISDN1.msisdn = msisdnSet;
        
        srp.listOfMSISDN = listOfMSISDN1;
        srp.reservedTo = futureTimeStr;

        srp.reservationTSCID = tscid;

        srp.reservationType = 'C';
        srp.reservationLogNo = '1';
        srp.reservationUserId = '';
        srp.returnCode = '';
        
        Message message = new Message();
        message.srp = srp;
        message.header = header;
        
        wrap.message = message;

        string endpointName,endpoint;
        
        //Data Masking- Mock URL setup by validation the lowerOrgs
        If(Label.MCONL_IsLowerOrg.equalsIgnoreCase('YES')){
            endpointName='MCONL_NumberReservation_Mock';
        }
        else{
            if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
                endpointName = 'MCONLINE_ReserveNumberUAT';
            }else{
                endpointName = 'MCONLINE_ReserveNumber';
            } 
        }  
        
        endpoint = String.valueOf(WebService__c.getAll().get(endpointName).EndpointURL__c);

        Map<String, Object> accessMap;
        if(!Test.isRunningTest()){
            if(Label.OrderProcessorEnvironment.equalsIgnoreCase('UAT')) {
                accessMap = (Map<String, Object>) JSON.deserializeUntyped(TeliaSE_MadamAuthenticationWS_UAT.makePostCallout());
            }else{
                accessMap = (Map<String, Object>) JSON.deserializeUntyped(TeliaSE_MadamAuthentication.makePostCallout());
            }
        }

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
    }

    public class ListOfMSISDN{
        public String retNoOfIntMSISDN;
        public Set<String> msisdn;
    }

    public class Srp{

        public String msisdntype;

        public String trafficSystem;
        public ListOfMSISDN listOfMSISDN;
        public String reservedTo;

        public String reservationTSCID;

        public String reservationType;
        public String reservationLogNo;
        public String reservationUserId;
        public String returnCode;
    }

    public class Message{
        public Header header;
        public Srp srp;
    }

    public class NumberReservationWrapper {
        public Message message;
    }
}