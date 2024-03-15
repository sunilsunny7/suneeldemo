/**
* @Author:      Aditi Goyal
* @Company:     Capgemini
* @Date:        14-11-2022
* @Description: Schedulable class to schedule MC_SingleCaseBatch class.
* -------------------------------------------------------------
*/
global class MC_SingleCaseBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        MC_SingleCaseBatch obj = new MC_SingleCaseBatch();
        Database.executeBatch(obj,1);
    }
}