@IsTest
public class Test_LWCController {

    @IsTest
    static void testSMEUser(){
        User byPassUser = Test_DataFactory.getByPassUser();
        System.runAs(byPassUser){
            Opportunity oppRec=Test_DataFactory.createOpportunity();
            Test.startTest();
            insert oppRec;
            Test.stopTest();
            LWCController.getJSONValue(oppRec.Id);
        }
    }
    @IsTest
    static void checkIfSandbox(){
        Test.startTest();
        Boolean isSandbox = LWCController.checkIfSandbox();
        Test.stopTest();

        Organization org = [SELECT Id,IsSandbox FROM Organization];
        System.assertEquals(org.IsSandbox,isSandbox);
    }
}