@isTest 
public class Broadband_PPC_Test {
    static testMethod void validate() {
       
       string Id = [select Id from RecordType where Name = 'Product' AND SobjectType ='Broadband_PPC__c'].Id;

        Financial_material__c c = new Financial_material__c (Name = '12345678',
                                                   Network_product__c ='Test2', 
                                                   UoM__c = 'MB',
                                                   NP_group__c = 'Mobile',
                                                   NP_L1__c = 'Mobile Other',
                                                   NP_L2__c = 'Satellite Services',
                                                   NP_L3__c = 'Mobile other - satellite services',
                                                   NP_L4__c = 'Mobile domestic IC Non-Voice Other',
                                                   NP_L5__c = '',
                                                   NP_L6__c = 'Test4');
        
        insert c;
        string fmid = c.Name;
        System.debug(':::::::::::::::: fmid: ' + fmid);
        
        Broadband_Cost_Magin__c d = new Broadband_Cost_Magin__c();
        d.Name = fmid;
        
        insert d;
        
        string bcmid = d.Id;
        
        Broadband_PPC__c b = new Broadband_PPC__c (RecordTypeId = Id,
                                                   Main_Portfolio__c ='Application', 
                                                   Main_offering__c = 'Office 365',
                                                   Offering__c = 'Tillval',
                                                   Specific_Offering_Service__c = 'Test',
                                                   ID__c = bcmid,
                                                   One_time_fee__c = 1);

       // Insert record
       insert b;
    }
}