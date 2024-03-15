/*-----
Description: Test Class Test_DisplayRichContext on DisplayRichContext
Create date: 16-05-2022
Created May 2022 - L.S - New test method for createTaskInBuyIntUnitTest() SALEF-6798
-------*/
@isTest
public class Test_DisplayRichContext {
    Public static final Id rrdRamavtalTypeId = Schema.SObjectType.contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();  
    
    @TestSetup
    static void CreateTestData() {
        System.runAs(new User(Id = Userinfo.getUserId())) {
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;   
            List<Contract> lstContract = new list<contract>();
            Contract contrObj=new Contract();
            contrObj.AccountId=acc.id;
            contrObj.RecordtypeId = rrdRamavtalTypeId;
            contrObj.Name='Test1';
            contrObj.Status='Draft';
            contrObj.Solution_Area__c='Vxl';
            contrObj.StartDate=Date.today();
            contrObj.Customer_unique_terms__c= 'TestValue0';
            contrObj.Customer_unique_terms_Approved__c = false;
            lstContract.add(contrObj);
            
            Contract contrObj1=new Contract();
            contrObj1.AccountId=acc.id;
            contrObj1.RecordtypeId = rrdRamavtalTypeId;
            
            contrObj1.Name='Test2';
            contrObj1.Status='Draft';
            contrObj1.Solution_Area__c='Vxl2';
            contrObj1.StartDate=Date.today();
            contrObj1.Customer_unique_terms_Approved__c = false;
            lstContract.add(contrObj1);
            insert lstContract;
        }
    }
    testMethod static void DisplayRichContextUnitTest() {       
        System.runAs(new User(Id = Userinfo.getUserId())) {
            Test.starttest();  
            Contract contObj =[select id,name, StartDate,AccountId,Status, Solution_Area__c,Customer_unique_terms__c,Customer_unique_terms_Approved__c from  contract where  name ='test1' and Solution_Area__c='Vxl' and recordtypeid =:rrdRamavtalTypeId ]; 
            contObj.Customer_unique_terms__c = 'testValue';
            contObj.Customer_unique_terms_Approved__c = false;
            update contObj;           
            System.assertEquals(contObj.Customer_unique_terms__c,'testValue','Customer unique terms should be  Provided by user');
            System.assertEquals(contObj.Customer_unique_terms_Approved__c,false, 'unique term should be false');
            DisplayRichContext.getRichContext(contObj.id);
            Test.stoptest();
        }   
    }
    testmethod static void DisplayRichContextUnitTest2() {                 
        System.runAs(new User(Id = Userinfo.getUserId())) {
            Test.starttest(); 
            Contract contObj1 =[select id, name, StartDate,AccountId,Status, Solution_Area__c,Customer_unique_terms__c,Customer_unique_terms_Approved__c from  contract where  name ='test2' and Solution_Area__c='Vxl2' and recordtypeid =:rrdRamavtalTypeId]; 
            System.assertEquals(contObj1.Customer_unique_terms__c,null,'Customer unique terms should be  Provided by user');
            System.assertEquals(contObj1.Customer_unique_terms_Approved__c,false, 'unique term should be false');
            DisplayRichContext.getRichContext(contObj1.id);
            Test.stoptest();
        }         
    }        
}