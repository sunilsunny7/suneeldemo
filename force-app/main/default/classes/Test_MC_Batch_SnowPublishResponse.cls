@IsTest
public class Test_MC_Batch_SnowPublishResponse {
    public static testmethod void testMethod1(){
        User salesManager;
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            Account acc = Test_DataFactory.createOneAccount();
            insert acc; 
                      
            Contract conObj = new Contract();
            conObj.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj.Contract_Record_Type__c = 'Ramavtal';
            conObj.TeliaSE_Parent_Agreement__c = '1234567';
            conObj.TeliaSE_Type__c = 'Renegotiation';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_TUPP_Interface_Name__c = 'AgreementCreateEvent';
            conObj.TeliaSE_TUPP_Interface_Status__c = 'failure';
            insert conObj;
            
        }        
        Test.startTest();
            MC_Batch_SnowPublishResponse obj = new MC_Batch_SnowPublishResponse();
            DataBase.executeBatch(obj); 
            SchedulableContext sc = null;
            obj.execute(sc);
        Test.stopTest();
    }
    
    public static testmethod void testMethod2(){
        User salesManager;
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            Account acc = Test_DataFactory.createOneAccount();
            insert acc; 
                      
            Contract conObj = new Contract();
            conObj.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj.Contract_Record_Type__c = 'Ramavtal';
            conObj.TeliaSE_Parent_Agreement__c = '1234567';
            conObj.TeliaSE_Type__c = 'Renegotiation';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            insert conObj;
            conObj.status = 'Active';
            update conObj;
        }        
        /*Test.startTest();
            MC_Batch_SnowPublishActivatedContracts obj = new MC_Batch_SnowPublishActivatedContracts();
            DataBase.executeBatch(obj);
        Test.stopTest();*/
    }
    
    public static testmethod void testMethod3(){
        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('TestInput','abc');
        MC_RunIntegrationProcedure.runFutureIp('test_IP', inputMap, inputMap);            
    }
}