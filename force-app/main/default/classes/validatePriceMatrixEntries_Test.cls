@istest
public class validatePriceMatrixEntries_Test {
@testSetup
    static void initTestData() {
        Product2 pr1 = new Product2();
        pr1.C2BC_Category__c = 'HW Bundle';
        pr1.Family ='Online Order';
        pr1.ProductCode = '9084373';
        pr1.Name = 'Doro 8080 32GB Vit';
        insert pr1;
            
        Product2 pr2 = new Product2();
        pr2.C2BC_Subcategory__c = 'mobiledevice';
        pr2.IsActive = true;
        pr2.ProductCode = '9084373';
        pr2.vlocity_cmt__Status__c = 'Active';
        pr2.Name = 'Doro 8080 32GB Vit';
        insert pr2;
            
        vlocity_cmt__ProductChildItem__c pc = new vlocity_cmt__ProductChildItem__c();
        pc.vlocity_cmt__ParentProductId__c = pr1.Id;
        pc.vlocity_cmt__ChildProductId__c = pr2.Id;
        pc.vlocity_cmt__ChildLineNumber__c = '10';
        insert pc;
        
        vlocity_cmt__CalculationMatrix__c matrix1 = new vlocity_cmt__CalculationMatrix__c();
        matrix1.Name = 'PriceMatrix_24M_Hardware';
        insert matrix1;
        
        vlocity_cmt__CalculationMatrix__c matrix2 = new vlocity_cmt__CalculationMatrix__c();
        matrix2.Name = 'PriceMatrix_36M_Hardware';
        insert matrix2;
        
        vlocity_cmt__CalculationMatrixVersion__c mv1 = new vlocity_cmt__CalculationMatrixVersion__c();
        mv1.Name = 'PriceMatrix_24M_Hardware v56';
        mv1.vlocity_cmt__CalculationMatrixId__c = matrix1.Id; 
        insert mv1;
        
         vlocity_cmt__CalculationMatrixVersion__c mv2 = new vlocity_cmt__CalculationMatrixVersion__c();
        mv2.Name = 'PriceMatrix_36M_Hardware v46';
        mv2.vlocity_cmt__CalculationMatrixId__c = matrix2.Id;
        insert mv2;
        
        vlocity_cmt__CalculationMatrixRow__c row1 = new vlocity_cmt__CalculationMatrixRow__c();
        row1.vlocity_cmt__CalculationMatrixVersionId__c = mv1.Id;
        row1.vlocity_cmt__OutputData__c = '{"MRC":"30","NRC":"80","Target Product Name":"Doro 8080 32GB Vit"}';
        row1.vlocity_cmt__InputData__c = '{"Characteristic Name":"HWSAPID","Characteristic Value":"9084373","Quantity":"1075-9999","Source Product Code":"9084373","Source Product Name":"Doro 8080 32GB Vit"}';
    	insert row1;
        
        vlocity_cmt__CalculationMatrixRow__c row2 = new vlocity_cmt__CalculationMatrixRow__c();
        row2.vlocity_cmt__CalculationMatrixVersionId__c = mv2.Id;
        row2.vlocity_cmt__OutputData__c = '{"MRC":"110","NRC":"80","Target Product Name":"Doro 8080 32GB Vit"}';
        row2.vlocity_cmt__InputData__c = '{"Characteristic Name":"HWSAPID","Characteristic Value":"9084373","Quantity":"150-174","Source Product Code":"9084373","Source Product Name":"Doro 8080 32GB Vit"}';
        insert row2;
    }  
    @istest
    static  void test() {
        validatePriceMatrixEntries.validate();
    }
}