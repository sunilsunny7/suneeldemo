/*Description: Test coverage for BatchToCloseSignOfTask
Create date: 14th July 2022*/     
@IsTest
public class Test_BatchToCloseSignOfTask {     
    @TestSetup static void createTestDataOpp(){       
        Test_DataFactory.setUpOrg();        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;        
        System.runAs(new User(Id = Userinfo.getUserId())){ 
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam);
        }        
        User salesRep = smeUserTeam[2];        
        System.runAs(salesRep){
            Test.startTest();
            Opportunity opp = Test_DataFactory.createOpportunity();             
            insert opp;
            opp.StageName ='Förlorad';
            update opp; 
            Task tsk = Test_DataFactory.createOneTask();
            tsk.whatid = opp.id;
            tsk.type ='Signoff';
            tsk.status='Öppen';          
            insert tsk;            
            Test.stopTest();
        }               
    }
    @Istest static void callBatchMethod(){
        BatchToCloseSignOfTask batchToTsk= new BatchToCloseSignOfTask();
        Test.startTest();
        database.Executebatch(batchToTsk);       
        Test.stopTest();
        list<Task> lstTsk = [select type, status from Task];      
        System.assertEquals(lsttsk[0].status,system.label.SignUpTaskToClosed,'Task status should be closed');
    }
    
}