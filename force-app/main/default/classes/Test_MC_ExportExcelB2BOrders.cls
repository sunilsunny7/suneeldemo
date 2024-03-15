/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_ExportExcelB2BOrders
**Created By  :        Abhinav Gupta
**Release     :        23.9
**Description :        Apex Methods for generation for Excel document (LTAT-14200)
Modified to add some new field to Order extarct (LTAT-17284) by Lokesh, Release - 23.11
-----------------------------------------------------------------------------------------------------------*/
@isTest
private class Test_MC_ExportExcelB2BOrders 
{
    
    @isTest
    private static void test1(){
        User user; 
        System.runAs(new User(Id = Userinfo.getUserId())){
        	user = Test_DataFactory.createAdminUser();
        	user.Bypass_VR__c = true;
        	insert user;
        }
        System.runAs(user)
        {
            Account a1 = Test_DataFactory.createOneAccount();
          	insert a1;
            List<MC_B2B_Order__c> orderList = new list<MC_B2B_Order__c>();
            MC_B2B_Order__c mc1 = new MC_B2B_Order__c(name='test1',MC_Account__c=a1.id , MC_Delivery_Date__c= DateTime.Now() , MC_Order_Number__c='12345',MC_Order_Type__c='New',MC_Ordered_By__c='TestUser1',MC_Orderer_Email__c='abc@test.com',MC_Product_Info__c='testprod1',MC_Promised_Date__c=DateTime.Now(),MC_Requested_Delivery_Date__c=DateTime.Now(),MC_Source__c='testSource',MC_Order_Status__c='In progress');
        	MC_B2B_Order__c mc2 = new MC_B2B_Order__c(name='test2',MC_Account__c=a1.id , MC_Delivery_Date__c= DateTime.Now() , MC_Order_Number__c='12345',MC_Order_Type__c='New',MC_Ordered_By__c='TestUser1',MC_Orderer_Email__c='abc@test.com',MC_Product_Info__c='testprod1',MC_Promised_Date__c=DateTime.Now(),MC_Requested_Delivery_Date__c=DateTime.Now(),MC_Source__c='testSource2',MC_Order_Status__c='In progress');            
        	MC_B2B_Order__c mc3 = new MC_B2B_Order__c(name='test3',MC_Account__c=a1.id , MC_Delivery_Date__c= DateTime.Now() , MC_Order_Number__c='12345',MC_Order_Type__c='New',MC_Ordered_By__c='TestUser1',MC_Orderer_Email__c='abc@test.com',MC_Product_Info__c='testprod1',MC_Promised_Date__c=DateTime.Now(),MC_Requested_Delivery_Date__c=DateTime.Now(),MC_Source__c='testSource3',MC_Order_Status__c='In progress');
            MC_B2B_Order__c mc4 = new MC_B2B_Order__c(name='test3',MC_Account__c=a1.id , MC_Item_Promised_Date__c= DateTime.Now() , MC_Order_Number__c='12345',MC_Order_Type__c='New',MC_Ordered_By__c='TestUser1',MC_Orderer_Email__c='abc@test.com',MC_Product_Info__c='testprod1',MC_Promised_Date__c=DateTime.Now(),MC_Requested_Delivery_Date__c=DateTime.Now(),MC_Source__c='testSource3',MC_Order_Status__c='In progress');
            MC_B2B_Order__c mc5 = new MC_B2B_Order__c(name='test3',MC_Account__c=a1.id , MC_Item_Req_Del_Date__c= DateTime.Now() , MC_Order_Number__c='12345',MC_Order_Type__c='New',MC_Ordered_By__c='TestUser1',MC_Orderer_Email__c='abc@test.com',MC_Product_Info__c='testprod1',MC_Promised_Date__c=DateTime.Now(),MC_Requested_Delivery_Date__c=DateTime.Now(),MC_Source__c='testSource3',MC_Order_Status__c='In progress');

            orderList.add(mc1);
            orderList.add(mc2);
            orderList.add(mc3);
            orderList.add(mc4);
            orderList.add(mc5);
            insert orderList;
            MC_ExportExcelB2BOrders.excelConvert(a1.id);
        }
    }

}