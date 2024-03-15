@isTest
public class Test_AutoDirigeraClicked{
@isTest
    static void testAutoDirigeraClicked(){
   
     User Byuser = Test_DataFactory.getByPassUser();
        
     System.runAs(Byuser){     
    
    Account  acc= Test_DataFactory.createoneAccount();
    acc.OwnerId=label.Integration_User_Id;
    
    insert acc;
    
   Lead leadObj=new Lead();
    leadObj.Account__c=acc.Id;
    leadObj.LeadSource='AF';
    leadObj.LastName='abc';
    leadObj.Company='pqr';
    
    insert leadObj;  
    
    Test.startTest();
    
        
    Apexpages.StandardController stdController = new Apexpages.StandardController(leadObj);
    AutoDirigeraClicked controller = new AutoDirigeraClicked(stdController);
    
    PageReference pageRef = Page.AutoDirigeraClicked;    
    pageRef.getParameters().put('id', String.valueOf(leadObj.Id));
    Test.setCurrentPage(pageRef); 
    controller.processRecord();
    Test.stopTest();
    }
    
    }   
    
   @isTest 
    static void testAutoDirigeraClicked2(){
   
     User Byuser = Test_DataFactory.getByPassUser();
        
     System.runAs(Byuser){     
    
    Account  acc2= Test_DataFactory.createoneAccount();
    acc2.OwnerId='00524000000URHs';
    insert acc2;
    
    
   Lead leadObj2=new Lead();
    leadObj2.Account__c=acc2.Id;
    leadObj2.LastName='abc2';
    leadObj2.Company='pqr2';
    
    insert leadObj2;  
    
    Test.startTest();
    Apexpages.StandardController stdController = new Apexpages.StandardController(leadObj2);
    AutoDirigeraClicked controller = new AutoDirigeraClicked(stdController);
    
    PageReference pageRef = Page.AutoDirigeraClicked;    
    pageRef.getParameters().put('id', String.valueOf(leadObj2.Id));
    Test.setCurrentPage(pageRef);
    controller.processRecord();
    Test.stopTest();
    }
    
    }

    }