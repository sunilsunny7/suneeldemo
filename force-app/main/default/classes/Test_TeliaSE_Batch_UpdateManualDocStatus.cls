@IsTest
public class Test_TeliaSE_Batch_UpdateManualDocStatus {
    public static testmethod void testMethod1(){
        User salesManager;
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        system.runAs(salesManager){
            scrive__ScriveDocument__c scriveDoc = new scrive__ScriveDocument__c();
            scriveDoc.scrive__status__c = 'Draft';
            scriveDoc.Name = 'Offerdocument_Manual';
            insert scriveDoc;
        }
        Test.startTest();
            TeliaSE_Batch_UpdateManualDocumentStatus obj = new TeliaSE_Batch_UpdateManualDocumentStatus();
            DataBase.executeBatch(obj); 
            SchedulableContext sc = null;
            obj.execute(sc);
        Test.stopTest();
    }
}