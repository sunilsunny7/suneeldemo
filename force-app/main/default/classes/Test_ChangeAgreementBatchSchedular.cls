/**
 * @Author:      Surajit Pramanik
 * @Company:     Capgemini
 * @Date:        17th May, 2019
 * @Description: This Class is test class of TeliaSE_ChangeAgreementBatchSchedular
 *
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------
*/

@isTest
public class Test_ChangeAgreementBatchSchedular {
    public static testmethod void main(){
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?';
        TeliaSE_ChangeAgreementBatchSchedular cadbs = new TeliaSE_ChangeAgreementBatchSchedular();
        system.schedule('Change Agreement Date Batch Scheduler test', CRON_EXP, cadbs); 
        Test.stopTest(); 
    }
}