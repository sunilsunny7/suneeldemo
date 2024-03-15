/**
 * @description       : Calls dispatcher class before data insertion or deletion.
 * @author            : Mihir Joshi
 * @Company           : Capgemini
 * @last modified on  : 02-26-2024
 * @last modified by  : Mihir Joshi
**/
trigger MC_AccessRequestTrigger on MC_Access_Request__c (before insert, before delete) {
    MC_AccessRequestTriggerDispatcher.dispatch(Trigger.OperationType);
}