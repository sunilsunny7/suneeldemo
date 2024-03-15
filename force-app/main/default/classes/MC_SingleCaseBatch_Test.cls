/**
* @Author:      Aditi Goyal
* @Company:     Capgemini
* @Date:        14-11-2022
* @Description: Test Class for MC_SingleCaseBatch
* -------------------------------------------------------------
*/
@isTest
private class MC_SingleCaseBatch_Test {
    
    @testSetup
    private static void testDataSetup(){
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
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_TUPP_Status__c = 'Active';
            conObj.TeliaSE_Case_Id__c = '3432'; 
            conObj.MC_SmartConnectSingleCase__c ='Yes';
            conObj.TeliaSE_MC_sales_flow_identifier__c ='New Sales';
            insert conObj;
            
            vlocity_cmt__ObjectClass__c newObj=new vlocity_cmt__ObjectClass__c();
            newObj.Name = 'Smart Connect Offer Spec';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.name = 'Smart Connect Standard';
            prod.productCode = 'SC_STANDARD';
            prod.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prod.TeliaSE_OfferTemplateFlag__c=false;
            prod.TeliaSE_TemplateCategory__c='';
            prod.MC_Product_Name_Eng__c='Smart Connect Standard';
            prod.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            insert prod;
            
            vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
            cli.vlocity_cmt__ContractId__c = conObj.id;
            cli.vlocity_cmt__Product2Id__c = prod.Id;
            cli.Name ='Smart Connect Standard';
            cli.vlocity_cmt__LineStatus__c = 'Updated';
            cli.TeliaSE_Product_Object_Type__c=newObj.Name;
            cli.TeliaSE_Base_Quantity__c =5;
            cli.TeliaSE_ParentClusterCode__c = 'SC_KLU_PLUS';
            cli.vlocity_cmt__RecurringCharge__c = 35;
            cli.TeliaSE_ParentItemId__c = null;
            insert cli;
        }
    }
    
    @isTest
    private static void testSingleCaseBatch(){
        Test.startTest();
        MC_SingleCaseBatch obj = new MC_SingleCaseBatch();
        DataBase.executeBatch(obj,1); 
        Test.stopTest();
        
        Contract con = [SELECT TeliaSE_TUPP_Interface_Name__c FROM Contract LIMIT 1];

      	System.assertEquals(con.TeliaSE_TUPP_Interface_Name__c, 'CreateSingleCase');

    }
}