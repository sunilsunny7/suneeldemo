@isTest
public class Test_MC_Batch_AutoTask_QuoteSync {
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
                      
        Opportunity opp = new Opportunity();
            opp.Name='opp123654';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.MC_Sync_AutoTask__c = true;
            insert opp;
            Quote qut = new Quote();
            qut.Name='Test Quote123';
            qut.status = 'Draft';
            qut.opportunityId = opp.id;
            insert qut;
            
            
        }        
        Test.startTest();
              MC_Batch_AutoTask_QuoteSync obj = new MC_Batch_AutoTask_QuoteSync();
            DataBase.executeBatch(obj); 
            SchedulableContext sc = null;
            obj.execute(sc);
        Test.stopTest();
    }
    
    
}