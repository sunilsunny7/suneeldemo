@isTest 
public class Test_BatchAnonymizeMobileSubscriptions 
{
    static testMethod void testMethod1() 
    {
        User adminUser = Test_DataFactory.createAdminUser();
        List<Account> lstAccount= new List<Account>();
        List<Mobile_Subscription__c> lstMs= new List<Mobile_Subscription__c>();
        for(Integer i=0 ;i <20;i++)
        {
            Account acc = new Account();
            acc.Name ='Name'+i;
            acc.CM_Final_Traffic_Marketing__c='denied';
            lstAccount.add(acc);
        }
        System.runAs(adminUser) {
        insert lstAccount;
        }
        for(Account a: lstAccount)
        {
        for(Integer i=0 ;i <5;i++)
        {
            Mobile_Subscription__c ms = new Mobile_Subscription__c();
            ms.Name ='9999999'+i;
            ms.Account__c=a.Id;
            lstMs.add(ms);
        }
        }
        System.runAs(adminUser) {
        insert lstMs;
        }
        
        Test.startTest();

            BatchAnonymizeMobileSubscriptions obj = new BatchAnonymizeMobileSubscriptions();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}