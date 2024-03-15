@isTest
public class Test_userdeactiveJob {
    
    static testmethod void no01_calluserjob(){
        
        Test.startTest();  
        EmailTemplate e1= [SELECT DeveloperName,Folder.Name,HtmlValue,Id,Name,Subject FROM EmailTemplate where folder.Name = 'UserDeactivation' LIMIT 1];
        system.debug('%%%%'+e1.DeveloperName);
        Database.executeBatch(new UserUnsubscribeBatchProcess ()); 
       // UserUnsubscribeBatchProcess usrcls = new UserUnsubscribeBatchProcess();
       // usrcls.generateAESEncryptedKey('testusername');
       // usrcls.createSingleEmail(Test_DataFactory.createAdminUser(), e1, 'DEFAULT');
        Test.stopTest();
    }
}