@isTest
public class MCOnline_AgreementController_V0_2_Test {
    @testSetup
    static void initTestData() {
        
    }
    @istest
    static  void test1() {
          Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
         new MCOnline_AgreementController_V0_2().invokeMethod('',inputMap,outMap,options);     
    }
    
     @istest
    static  void test() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
         new MCOnline_AgreementController_V0_2().invokeMethod('GetEnvironmentVariables',inputMap,outMap,options);   
       
    }
    
}