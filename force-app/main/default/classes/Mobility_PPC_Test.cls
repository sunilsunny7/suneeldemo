@isTest 
public class Mobility_PPC_Test {
    static testMethod void validate() {
       
       string Id = [select Id from RecordType where Name = 'Product' LIMIT 1].Id;

        Financial_material__c FM = new Financial_material__c (Name = '12345678',
                                                   Network_product__c ='Test2', 
                                                   UoM__c = 'MB',
                                                   NP_group__c = 'Mobile',
                                                   NP_L1__c = 'Mobile Other',
                                                   NP_L2__c = 'Satellite Services',
                                                   NP_L3__c = 'Mobile other - satellite services',
                                                   NP_L4__c = 'Mobile domestic IC Non-Voice Other',
                                                   NP_L5__c = '',
                                                   NP_L6__c = 'Test4');
        
        insert FM ;
        string fmid = FM.Name;
        System.debug(':::::::::::::::: fmid: ' + fmid);
        
        Mobility_Cost_margin__c MCM = new Mobility_Cost_margin__c();
        MCM.Name = fmid;
        
        insert MCM ;

        Mobility_Cost_price__c MCP = new Mobility_Cost_price__c();
        MCP.Name = fmid;
        
        insert MCP ;
        
 
        Broadband_Cost_Magin__c BCM = new Broadband_Cost_Magin__c();
        BCM.Name = fmid;
        
        insert BCM ;
        
    }
}