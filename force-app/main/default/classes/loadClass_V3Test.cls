@isTest public class loadClass_V3Test {
    @isTest static  void test() {
        WarmupDetail__c det = new WarmupDetail__c();
        det.ProductCode__c = 'MOB_TOTAL_BAS_NEW';
        det.CatalogCode__c = 'SUBSCRIPTIONS';
        det.FileContent__c = '0697a000001BmD9AAK';
        det.BatchNumber__c = 1;
        insert det; 
        
        String sequence = [select Sequence__c from WarmupDetail__c where Id =: det.Id]?.Sequence__c;
        loadClass_V3 lc = new loadClass_V3(sequence);
        lc.execute(null);
    }
}