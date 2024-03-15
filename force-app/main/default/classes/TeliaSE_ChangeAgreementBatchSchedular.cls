/**
 * @Author:      Surajit Pramanik
 * @Company:     Capgemini
 * @Date:        23rd April, 2019
 * @Description: This Class will schedule TeliaSE_ChangeAgreementRetriggerBatch class.
 *
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------
*/

global class TeliaSE_ChangeAgreementBatchSchedular implements Schedulable {
    global void execute(SchedulableContext sc) {
        TeliaSE_ChangeAgreementRetriggerBatch chngRrtiggBatch =new TeliaSE_ChangeAgreementRetriggerBatch();
        Database.executeBatch(chngRrtiggBatch, 1);
    }
}