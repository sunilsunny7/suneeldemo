/**
* @description       : This is a dispatcher class for MC_AccessRequestTrigger
* @author            : Mihir Joshi
* @Company           : Capgemini
* @last modified on  : 02-26-2024
* @last modified by  : Mihir Joshi
**/
public with sharing class MC_AccessRequestTriggerDispatcher {
    public static void dispatch(System.TriggerOperation operationType) {
        switch on operationType {
            when BEFORE_INSERT {
                MC_AccessRequestTriggerHandler.handleBeforeInsert(Trigger.New);
            }
            when BEFORE_DELETE{
                MC_AccessRequestTriggerHandler.handleBeforeDelete(Trigger.Old);
            }
            when else {
                //Do nothing
            }
        }
        
    }
}