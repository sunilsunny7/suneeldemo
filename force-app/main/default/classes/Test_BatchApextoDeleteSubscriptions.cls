@isTest 
public class Test_BatchApextoDeleteSubscriptions {
    static testMethod void testMethod1(){
       
        Mobilabonnemang__c mobil = new Mobilabonnemang__c();
        mobil.Name = 'm123456';
        insert mobil;
        Test.startTest();
            BatchApextoDeleteSubscription obj = new BatchApextoDeleteSubscription();
            DataBase.executeBatch(obj);    
        	SchedulableContext sc = null;
            obj.execute(sc);
        Test.stopTest();
    }
}