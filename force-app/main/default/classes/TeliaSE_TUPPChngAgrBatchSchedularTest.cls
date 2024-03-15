/**
 * @Author:      Surajit Pramanik
 * @Company:     Capgemini
 * @Date:        17th May, 2019
 * @Description: This Class is test class of TeliaSE_TUPPChngAgrBatchSchedular
 *
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------
*/

@isTest
public class TeliaSE_TUPPChngAgrBatchSchedularTest {
public static testmethod void main(){
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?';
        TeliaSE_TUPPChngAgrBatchSchedular cadbs = new TeliaSE_TUPPChngAgrBatchSchedular();
        system.schedule('Change Agreement Batch', CRON_EXP, cadbs); 
        Test.stopTest(); 
    }
}