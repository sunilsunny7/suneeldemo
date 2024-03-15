@isTest public class JsonPayloadUpdate_Test{
    @istest
    static  void test() {
        Test.startTest();
        List<String> offers = new List<String>();
        String catalog = 'SUBSCRIPTIONS';
        offers.add('MOB_TOTAL_JOBBMOBIL_V2');
        JsonPayloadUpdate jp = new JsonPayloadUpdate(offers,catalog);
        jp.start(null);
		jp.execute(null, offers);
		jp.finish(null);        
        Test.stopTest();
    }
    @istest
    static  void PhimTest() {
        Test.startTest();
        Map<String,string> phimProd = new Map<string,string>();
        List<String> offers = new List<String>();
        offers.add('HW_MOBILEDEVICES1');
        phimProd.put('HW_MOBILEDEVICES1','MOBILEDEVICE');
        Boolean Phim=true;
        JsonPayloadUpdate jp = new JsonPayloadUpdate(phimProd,Phim);
        jp.start(null);
		jp.execute(null, offers);
		jp.finish(null);        
        Test.stopTest();
    }
    
}