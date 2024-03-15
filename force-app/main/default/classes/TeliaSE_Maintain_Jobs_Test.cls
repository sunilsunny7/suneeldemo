@isTest
public class TeliaSE_Maintain_Jobs_Test {
 
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
    
    @isTest()
    public static void testScheduledJobsRefreshCache()
    {
        Test.startTest();
        System.schedule('test', '0 0 * * * ?', new TeliaSE_Maintain_Jobs('RefreshCache'));
        Test.stopTest();
    }
    @isTest()
    public static void testScheduledJobsLoadAttributes()
    {
        Test.startTest();
        System.schedule('test3', '0 0 * * * ?', new TeliaSE_Maintain_Jobs('LoadAttributes'));
        Test.stopTest();
    }
    @isTest()
    public static void testScheduledJobsRegenerateCache()
    {
        try{
            Test.startTest();
            System.schedule('test34', '0 0 * * * ?', new TeliaSE_Maintain_Jobs('RegenerateCache'));
            Test.stopTest();
        }catch(Exception e)
        {}
    }
    
    @isTest()
    public static void testScheduledJobsCacheWarmup()
    {
        try{
            Test.startTest();
            System.schedule('test34', '0 0 1 * * ?', new TeliaSE_Maintain_Jobs('cacheWarmup'));
            Test.stopTest();
        }catch(Exception e)
        {}
    }
    
    @isTest()
    public static void testScheduledJobsLoadBatch()
    {
        try{
            Test.startTest();
            System.schedule('test35', '0 0 1 * * ?', new TeliaSE_Maintain_Jobs('LoadBatch'));
            Test.stopTest();
        }catch(Exception e)
        {}
    }
    @isTest()
    public static void testScheduledJobsCheckAttributes()
    {
        try{
            Test.startTest();
            System.schedule('test36', '0 0 2 * * ?', new TeliaSE_Maintain_Jobs('checkAttributes'));
            Test.stopTest();
        }catch(Exception e)
        {}
    }
}