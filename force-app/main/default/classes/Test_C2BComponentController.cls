@isTest
private class Test_C2BComponentController {

     @isTest
    private static void testc2bCmp(){
     User Byuser;
     System.runAs(new User(Id = Userinfo.getUserId())){
     Byuser = Test_DataFactory.getByPassUser();
            }
     System.runAs(Byuser){    
        //Creating the Test Data
        List<Account> accList = Test_DataFactory.createAccounts(1);
        accList[0].Org_nr__c = '12345';
        insert accList;
        
        C2BComponentController c2b = new C2BComponentController();
        String accid = accList[0].Id;
        String Orgnb = C2BComponentController.getOrgNumber(accid);
        
        //Calling the controller methods
          List<C2BComponentController.C2BGenericWrapper> Mobsub = C2BComponentController.getMobSubCategory(Orgnb);
          
          C2BComponentController.getBroadbandCategory(Orgnb);
           C2BComponentController.getFunctionOffering(Orgnb,'test');
           C2BComponentController.getBroadbandOffering(Orgnb,'test');
           C2BComponentController.getMobSubOffering(Orgnb,'test');
           C2BComponentController.getFunctionCategory('test');
           
          
          
      }
    }
        

}