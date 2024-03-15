@isTest

public class Test_AggregatedMobileServiceController {
    
    @isTest
    static void testAggregatedMobileServiceController(){
        User Byuser = Test_DataFactory.getByPassUser();
        Test.startTest(); 
        Account acc= Test_DataFactory.CreateOneAccount();
        acc.C2B_Org_nr__c='164404807986';
        insert acc;
        
            
        Apexpages.StandardController stdController = new Apexpages.StandardController(acc);
        AggregatedMobileServiceController controller = new AggregatedMobileServiceController(stdController);
        Map<String, AggregatedMobileServiceController.AggregatedWrapper> testMap = new Map<String, AggregatedMobileServiceController.AggregatedWrapper>();
        String cat='testString';
        Integer count=10;
        Boolean b1=false; 
        Map<String, AggregatedMobileServiceController.AggregatedWrapper> getAggregatedData = new Map<String, AggregatedMobileServiceController.AggregatedWrapper>();
        
        AggregatedMobileServiceController.AggregatedWrapper agg = new AggregatedMobileServiceController.AggregatedWrapper(cat,count,testMap,b1);
        String selectedLevelOneCategory;
        controller.selectedLevelOneCategory='testtstring';
        Boolean loaded;
        controller.loaded=false;
        String levelOneHash='Levelone';
        String levelTwoHash='Leveltwo';
        controller.loadData();
        controller.getAggregatedData();
        Test.stopTest();
    }
        
}