@isTest
public class MCOnline_TrackMyBusinessLogin_V4_Test {
    @testSetup
    static void initTestData() { 
        Account acc1 = new Account();
        acc1.RecordTypeId = '012240000008l9YAAQ';
        acc1.Name='TestAccount1';
        acc1.TSCID__c = 'TSCID98085';
        Insert acc1;
        
        Account acc2 = new Account();
        acc2.RecordTypeId = '012240000008l9YAAQ';
        acc2.Name='TestAccount2';
        acc2.TSCID__c = 'TSCID980855';
        Insert acc2;
        
        Account acc3 = new Account();
        acc3.RecordTypeId = '012240000008l9YAAQ';
        acc3.Name='TestAccount3';
        acc3.TSCID__c = 'TSCID980856';
        acc3.MCOnline_User_Current_Month_Login_Count__c	= 1;
        Integer month = ((DateTime)DateTime.Now()).month();
        acc3.MCOnline_User_Last_log_in_Date__c	= DateTime.newInstance(2020,month,18,3,3,3);
        Insert acc3;
        
        Account acc4 = new Account();
        acc4.RecordTypeId = '012240000008l9YAAQ';
        acc4.Name='TestAccount4';
        acc4.TSCID__c = 'TSCID9808565';
        acc4.MCOnline_User_Current_Month_Login_Count__c	= 1;
        acc4.MCOnline_User_Last_log_in_Date__c	= DateTime.Now();
        Insert acc4;
    }
    
    // log in for first time
    @isTest static void login_validTSCID_firstTime(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<Map<String,Object>> organisations = new List<Map<String,Object>>(); 
        Map<String,Object> tscid1 = new Map<String,Object>();
        Map<String,Object> tscid2 = new Map<String,Object>();
        List<String> tscidList = new List<String>();
        tscidList.add('TSCID98085');
        tscidList.add('TSCID980855'); 
        tscid1.put('tscid','TSCID98085');
        tscid2.put('tscid','TSCID980855');
        organisations.add(tscid1);
        organisations.add(tscid2); 
        inputMap.put('organisations',organisations);
        MCOnline_TrackMyBusinessLogin_V4 login = new MCOnline_TrackMyBusinessLogin_V4();
        login.invokeMethod('saveUserLogin',inputMap,outMap,options);
        System.assertEquals('successfully added logging information',outMap.get('message'));
        List<Account> acc = [select id,Name, TSCID__c, MCOnline_User_Current_Month_Login_Count__c, MCOnline_User_Last_log_in_Date__c from Account where TSCID__c IN :tscidList]; 
        for(Account ac :acc){
            System.assertEquals(1,ac.MCOnline_User_Current_Month_Login_Count__c);
        }
    }
    
    // subsiquent login in different year
    @isTest static void login_validTSCID_subsequentLogin_DiffYear(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<Map<String,Object>> organisations = new List<Map<String,Object>>(); 
        Map<String,Object> tscid1 = new Map<String,Object>();
        Map<String,Object> tscid2 = new Map<String,Object>();
        tscid1.put('tscid','TSCID980856');
        organisations.add(tscid1);
        inputMap.put('organisations',organisations);
        MCOnline_TrackMyBusinessLogin_V4 login = new MCOnline_TrackMyBusinessLogin_V4();
        login.invokeMethod('saveUserLogin',inputMap,outMap,options);
        System.assertEquals('successfully added logging information',outMap.get('message'));
        Account acc = [select id,Name, TSCID__c, MCOnline_User_Current_Month_Login_Count__c, MCOnline_User_Last_log_in_Date__c from Account where TSCID__c =:'TSCID980856']; 
        System.assertEquals(1,acc.MCOnline_User_Current_Month_Login_Count__c);
    }
    
    // login same month
    @isTest static void login_validTSCID_subsequentLogin_SameMonth(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<Map<String,Object>> organisations = new List<Map<String,Object>>(); 
        Map<String,Object> tscid1 = new Map<String,Object>();
        Map<String,Object> tscid2 = new Map<String,Object>();
        tscid1.put('tscid','TSCID9808565');
        organisations.add(tscid1);
        inputMap.put('organisations',organisations);
        MCOnline_TrackMyBusinessLogin_V4 login = new MCOnline_TrackMyBusinessLogin_V4();
        login.invokeMethod('saveUserLogin',inputMap,outMap,options);
        System.assertEquals('successfully added logging information',outMap.get('message'));
    }
    
    // invalid TSCID in request body
    @isTest static void login_invalidTSCID(){
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        List<Map<String,Object>> organisations = new List<Map<String,Object>>(); 
        Map<String,Object> tscid1 = new Map<String,Object>();
        Map<String,Object> tscid2 = new Map<String,Object>();
        tscid1.put('tscid','TSCID980851');
        tscid2.put('tscid','TSCID980855');
        organisations.add(tscid1);
        organisations.add(tscid2); 
        inputMap.put('organisations',organisations);
        MCOnline_TrackMyBusinessLogin_V4 login = new MCOnline_TrackMyBusinessLogin_V4();
        login.invokeMethod('saveUserLogin',inputMap,outMap,options);
        System.assertEquals(true,outMap.containsKey('ErrorResponse'));
    }
}