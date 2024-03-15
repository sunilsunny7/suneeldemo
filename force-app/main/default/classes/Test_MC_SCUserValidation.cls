@isTest
public class Test_MC_SCUserValidation {
    @isTest
    public static void getPilotContext() {
        User salesManager;
        User salesManager2;
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
            salesManager2 = Test_DataFactory.createFiberUser();
            salesManager2.Bypass_VR__c = true;
            salesManager2.Telia_Id__c = '32312231';
            salesManager2.MassCustomized_Roles__c  = 'SalesManager';			
            insert salesManager2;
            salesManager = Test_DataFactory.createFiberUser();
            salesManager.Bypass_VR__c = true;
            salesManager.managerID = salesManager2.id;
            salesManager2.MassCustomized_Roles__c  = 'SalesRep';
            insert salesManager;
        }
        System.runAs(salesManager) {
             Test.startTest();
             Map<String,Object> inputMap=new Map<String,Object>();
            MC_SCUserValidation qat = new MC_SCUserValidation();
            qat.invokeMethod('SCUserValidationFunc',inputMap,inputMap,inputMap);
            Test.stopTest();
        }
        
    }
}