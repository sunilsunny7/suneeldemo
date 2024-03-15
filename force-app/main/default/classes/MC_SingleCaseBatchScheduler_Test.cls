/**
* @Author:      Aditi Goyal
* @Company:     Capgemini
* @Date:        14-11-2022
* @Description: This class is test class of MC_SingleCaseBatchScheduler
* -------------------------------------------------------------
*/

@isTest
private class MC_SingleCaseBatchScheduler_Test {
    @isTest
    private static void main(){
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?';
        MC_SingleCaseBatchScheduler schedObj = new MC_SingleCaseBatchScheduler();
        System.schedule('MC_SingleCaseBatchScheduler test', CRON_EXP, schedObj); 
        Test.stopTest(); 
    }
}