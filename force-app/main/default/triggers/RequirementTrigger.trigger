/*
About
-----
Author: Varma Alluri
Create Date: 15.03.2017
Description: JIRA Ticket No: SAEN-2229
RequirementTrigger will fire before updating the Requirement record, 
this trigger will call RequirementTriggerHandler class.

*/

trigger RequirementTrigger on Requirement__c (before update) { 
    if(Trigger.isupdate && Trigger.isBefore){
        RequirementTriggerHandler.OnBeforeupdate(Trigger.new,trigger.oldmap);
    } 
}