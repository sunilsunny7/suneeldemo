@isTest

public class TestAggregatedBroadbandServiceController{
    
    @isTest
    static void testAggregatedBroadbandServiceController(){
        User Byuser = Test_DataFactory.getByPassUser();
        Account acc= Test_DataFactory.CreateOneAccount();
        acc.C2B_Org_nr__c='164404807986';
        
        Test.startTest();
        insert acc;
        
                
        Apexpages.StandardController stdController = new Apexpages.StandardController(acc);
        AggregatedBroadbandServiceController controller = new AggregatedBroadbandServiceController(stdController);
        Map<String, AggregatedBroadbandServiceController.AggregatedWrapper> testMap = new Map<String, AggregatedBroadbandServiceController.AggregatedWrapper>();
        String cat='testString';
        Integer count=10;
        Boolean b1=false; 
        Map<String, AggregatedBroadbandServiceController.AggregatedWrapper> getAggregatedData = new Map<String, AggregatedBroadbandServiceController.AggregatedWrapper>();
        
        AggregatedBroadbandServiceController.AggregatedWrapper agg = new AggregatedBroadbandServiceController.AggregatedWrapper(cat,count,testMap,b1);
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