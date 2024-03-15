@isTest
private class Test_ConvertToForenkladProcess {

    public static testMethod void testConvertToForenkladProcess(){
        Account acc = Test_DataFactory.createOneAccount();
         insert acc;
         Opportunity opp = Test_DataFactory.createLargeOpportunity();
         opp.AccountId = acc.Id;
         insert opp;
         ApexPages.currentPage().getParameters().put('id',opp.id);
         ApexPages.StandardController stdOppor = new ApexPages.StandardController(opp); 
         ConvertToForenkladProcess classObj = new ConvertToForenkladProcess(stdOppor);
         classObj.processRecord();
    }

}