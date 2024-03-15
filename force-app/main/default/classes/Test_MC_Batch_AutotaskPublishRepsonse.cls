@IsTest
public class Test_MC_Batch_AutotaskPublishRepsonse {
    
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
            conObj.MC_Sync_AutoTask__c = false;
            insert conObj;
            
        }        
        Test.startTest();
            MC_Batch_AutotaskPublishContractResponse obj = new MC_Batch_AutotaskPublishContractResponse();
            DataBase.executeBatch(obj); 
            SchedulableContext sc = null;
            obj.execute(sc);
        Test.stopTest();
    }
    
     public static testmethod void testMethod2(){
        User salesManager;
        Contract conObj = new Contract();
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
         System.runAs(salesManager){
            Account acc = Test_DataFactory.createOneAccount();
            insert acc; 
             System.debug('AccountId' + acc.Id);
                      
           
            conObj.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj.TeliaSE_Parent_Agreement__c = '987654321';
            conObj.TeliaSE_Type__c = 'Renegotiation';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_TUPP_Interface_Name__c = 'AgreementCreateEvent';
            conObj.TeliaSE_TUPP_Interface_Status__c = 'failure';
            conObj.MC_Sync_AutoTask__c = false;
            insert conObj;
            conObj.status = 'Active';
            update conObj;
             
            System.debug('con t2' + conObj.Id);
            
            vlocity_cmt__ContractLineItem__c cliobj = new vlocity_cmt__ContractLineItem__c();
            cliobj.TeliaSE_Product_Object_Type__c = 'ITDaaS Offer Spec';
            cliobj.TeliaSE_Start_Date__c = system.today();
            //cliobj.vlocity_cmt__ProductName__c = 'IT-Avdelning som Tjänst Plus';
            cliobj.vlocity_cmt__Status__c = 'Active';
            cliobj.vlocity_cmt__ContractId__c = conobj.id;
             insert cliobj;
             System.debug('cLi id t2' + cliobj.Id);
            
         }   
       Test.startTest();
            MC_Batch_AutotaskPublishContractResponse obj = new MC_Batch_AutotaskPublishContractResponse();
            DataBase.executeBatch(obj); 
         	SchedulableContext sc = null;
            obj.execute(sc);
           
        Test.stopTest();
         //Contract c = [Select  MC_Sync_AutoTask__c from Contract where Id =: conobj.id];
         //System.assertEquals(True, c.MC_Sync_AutoTask__c);
         
    }
    
    
    public static testmethod void testMethod3(){
        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('TestInput','abc');
        MC_RunIntegrationProcedure.runFutureIp('test_IP', inputMap, inputMap);            
    }
    

}