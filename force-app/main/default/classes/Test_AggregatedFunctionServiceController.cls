@isTest

public class Test_AggregatedFunctionServiceController{
    
    @isTest
    static void testAggregatedFunctionServiceController(){
        User Byuser = Test_DataFactory.getByPassUser();
      // System.runAs(Byuser){
        Account acc= Test_DataFactory.CreateOneAccount();
        acc.C2B_Org_nr__c='164404807986';
        insert acc;
        
        Test.startTest();        
        Apexpages.StandardController stdController = new Apexpages.StandardController(acc);
        AggregatedFunctionServiceController controller = new AggregatedFunctionServiceController(stdController);
        Map<String, AggregatedFunctionServiceController.AggregatedWrapper> testMap = new Map<String, AggregatedFunctionServiceController.AggregatedWrapper>();
        String cat='testString';
        Integer count=10;
        Boolean b1=false; 
        Map<String, AggregatedFunctionServiceController.AggregatedWrapper> getAggregatedData = new Map<String, AggregatedFunctionServiceController.AggregatedWrapper>();
        
        AggregatedFunctionServiceController.AggregatedWrapper agg = new AggregatedFunctionServiceController.AggregatedWrapper(cat,count,testMap,b1);
        String selectedLevelOneCategory;
        controller.selectedLevelOneCategory='testtstring';
        Boolean ShowComponent;
        controller.ShowComponent=false;
        String levelOneHash='Levelone';
        String levelTwoHash='Leveltwo';
        controller.loadData();
        controller.getAggregatedData();
        Test.stopTest();
        }
    
        
}