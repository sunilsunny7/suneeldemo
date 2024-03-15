@isTest public class loadClass_Test {
    @isTest static  void test() {
        WarmupDetail__c det = new WarmupDetail__c();
        det.ProductCode__c = 'MOB_TOTAL_BAS_NEW';
        det.CatalogCode__c = 'SUBSCRIPTIONS';
        det.FileContent__c = '0697a000001BmD9AAK';
        det.BatchNumber__c = 1;
        insert det; 
        
    	String sequence = [select Sequence__c from WarmupDetail__c where Id =: det.Id]?.Sequence__c;
        loadClass lc = new loadClass(sequence);
        lc.execute(null);
    }
}