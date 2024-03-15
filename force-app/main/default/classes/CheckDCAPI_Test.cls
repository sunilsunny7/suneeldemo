@isTest
public class CheckDCAPI_Test{
    
    @testSetup
    static void initTestData(){
        Product2 pro1 = new Product2();
        pro1.ProductCode = 'HW_MOBILEDEVICES2';
        pro1.Name = 'offer1';
        pro1.vlocity_cmt__SpecificationType__c='offer';
        pro1.C2BC_Category__c ='offerbundle';
        insert pro1;
        
       	vlocity_cmt__Catalog__c ct = new vlocity_cmt__Catalog__c();
        ct.Name = 'MOBILEDEVICE';
        ct.vlocity_cmt__CatalogCode__c='MOBILEDEVICE';
        insert ct;
        
        vlocity_cmt__CatalogProductRelationship__c cpr=new vlocity_cmt__CatalogProductRelationship__c();
        cpr.vlocity_cmt__IsActive__c=true;
        cpr.vlocity_cmt__CatalogId__c = ct.Id;
        cpr.vlocity_cmt__Product2Id__c=pro1.id;
        cpr.Name = 'NameInCPR';
        insert cpr;
    }
    
    @isTest
    public static void test1()
    {

        Test.startTest();
        Database.executeBatch(new CheckDCAPI(new Set<String>{'MOBILEDEVICE'}),1);
        Test.stopTest();
    }

}