@isTest
public class MCOnline_PHIM_CacheWarmup_Test {

    @testSetup
    static void initTestData(){
        Product2 pro1 = new Product2();
        pro1.ProductCode = 'HW_MOBILEDEVICES2';
        pro1.Name = 'offer1';
        pro1.vlocity_cmt__SpecificationType__c='offer';
        pro1.C2BC_Category__c ='offerbundle';
        insert pro1;
        
        Product2 pro2 = new Product2();
        pro2.ProductCode = 'HW_ACCESSORIES2';
        pro2.Name = 'offer2';
        pro2.vlocity_cmt__SpecificationType__c='offer';
        pro2.C2BC_Category__c ='offerbundle';
        insert pro2;
    
    }
    
    @isTest
    static void PhimTest(){
        MCOnline_PHIM_CacheWarmup s=new MCOnline_PHIM_CacheWarmup();
        s.execute(null) ;
    }
}