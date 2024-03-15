@isTest(SeeAllData=false)
public class TeliaSE_BatchHWProdUpdate_Test {   
    @testSetup
    static void initTestData(){
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name = 'Hardware offer';
        prod1.ProductCode = 'MOB_HARDWARE_OFFER';
        prodList.add(prod1);
        Product2 prod11 = new Product2();
        prod11.Name = 'prod1';
        prod11.ProductCode = '9106170';
        prod11.TeliaSE_MatrixPriceFlag__c = false;
        


        vlocity_cmt__CalculationMatrix__c  matrix=new vlocity_cmt__CalculationMatrix__c();
        matrix.name='PriceMatrix_24M_Hardware';
        insert matrix;

        
        vlocity_cmt__CalculationMatrixVersion__c version = new vlocity_cmt__CalculationMatrixVersion__c();
        version.vlocity_cmt__CalculationMatrixId__c=matrix.id;
        insert version;


        vlocity_cmt__CalculationMatrixRow__c row =new vlocity_cmt__CalculationMatrixRow__c();
        row.vlocity_cmt__InputData__c='{"Quantity":"225-249","Characteristic Value":"9100262","Characteristic Name":"HWSAPID","Source Product Code":"9106171"}';
        row.vlocity_cmt__CalculationMatrixVersionId__c=version.id;
        row.vlocity_cmt__OutputData__c='{"Quantity":"225-249","Characteristic Value":"9100262","Characteristic Name":"HWSAPID","Source Product Code":"9106171"}';
        insert row;

        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   

        vlocity_cmt__ObjectClass__c objectType = new vlocity_cmt__ObjectClass__c(Name = 'Mobile Handset Product Specification', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        insert objectType; 
        
        prodList.add(prod11);
        
        Product2 prod12 = new Product2();
        prod12.Name = 'prod2';
        prod12.ProductCode = '9106171';
        prod12.TeliaSE_MatrixPriceFlag__c = false;
        prod12.IsActive=true;
        prod12.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Mobile Handset Product Specification' LIMIT 1]?.Id;
        prodList.add(prod12);        
        
        Product2 prod14 = new Product2();
        prod14.Name = 'Samsung Galaxy S22 5G';
        prod14.ProductCode = '78285';
        prod14.IsActive = true;
        prod14.TeliaSE_MatrixPriceFlag__c = false;
        prodList.add(prod14);
        
        Product2 prod13 = new Product2();
        prod13.ProductCode = 'HW_MOBILEDEVICES1';
        prod13.Name = 'MOBILEDEVICES1';
        prod13.IsActive = true;
        prodList.add(prod13);
        
        
        Product2 prod16 = new Product2();
        prod16.Name = 'prod2';
        prod16.ProductCode = '9106007';
        prod16.TeliaSE_MatrixPriceFlag__c = false;
        prod16.IsActive=true;
        prod16.vlocity_cmt__ObjectTypeId__c=[Select id from vlocity_cmt__ObjectClass__c Where Name = 'Mobile Handset Product Specification' LIMIT 1]?.Id;
        prodList.add(prod16);
        
        insert prodList;        
        
        List<vlocity_cmt__ProductChildItem__c> items=new List<vlocity_cmt__ProductChildItem__c>();
        vlocity_cmt__ProductChildItem__c child = new vlocity_cmt__ProductChildItem__c();
        child.vlocity_cmt__ChildProductId__c = prod14.Id;
        child.vlocity_cmt__ParentProductId__c = prod13.Id;
        child.vlocity_cmt__ChildLineNumber__c = '1';
        items.add(child);


        vlocity_cmt__ProductChildItem__c child1 = new vlocity_cmt__ProductChildItem__c();
        child1.vlocity_cmt__ChildProductId__c = prod16.Id;
        child1.vlocity_cmt__ParentProductId__c = prod14.Id;
        child1.vlocity_cmt__ChildLineNumber__c = '1';        
        items.add(child1);

        insert items;
    }
    @istest
    public static void test1(){
        test.startTest();
        Database.executeBatch(new TeliaSE_BatchHWProdUpdate());
        test.stopTest();
    }
    
}