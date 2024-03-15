@istest
public class MCOnline_NumberReservationStatus_V2_Test {

  @testSetup
static void initTestData() { 
    
        MCONL_MSISDN__c msi = new MCONL_MSISDN__c();
        msi.CartContextKey__c = '12321';
        msi.Number__c = '212122';
        msi.LineItemKey__c = '22222';
        insert msi;
    
}
     @istest
    static  void test() {
                List < WebService__c > endpointURLs = new List < WebService__c > ();
        WebService__c wbTest = new WebService__c(Name = 'MCONLINE_ReserveStatusUAT',  
                                                 EndpointURL__c = 'https://apimarket-at.eam.telia.se/managemobilenumbersassignment/v1.3.0/reservenumber',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
       
        WebService__c wbTest1 = new WebService__c(Name = 'MCONLINE_ReserveStatus',  
                                                 EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest1);
        endpointURLs.add(wbTest);
        insert endpointURLs; 
        
       MCOnline_NumberReservationStatus_V2.Grs grs = new MCOnline_NumberReservationStatus_V2.Grs();
        String msisdn;
        msisdn = 'sd';
        Set<String> msisdnSet = new Set<String>();
        List<String> msisdnListstr = new List<String>(msisdnSet);
        msisdnListstr.add('Sn');
        grs.msisdn=msisdnListstr.get(0);
       
      //  msisdnListstr.get(0);
      Set<String> msisdnSetone = new Set<String>();
        msisdnSetone.add('msisdnListstr');
 MCOnline_NumberReservationStatus_V2.ReservationResponseWrapper rw =  MCOnline_NumberReservationStatus_V2.checkMSISDN_Availability(msisdnSetone,'1242657');
      
        
    }

}