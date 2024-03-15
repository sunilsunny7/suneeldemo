/* Author: Varma Alluri on 04.04.2017
   Description: Jira Ticket: SAEN-2252; Trigger populating a custom checkbox field (HasAttachment__c) on the subcase                                  
   to TRUE or FALSE depending on if an attachment or attachment on Email exists on the subcase or not. */

trigger AttachmentTrigger on Attachment (after insert,after delete){
    if(trigger.isInsert){
        AttachmentTriggerHandler.OnafterInsert(Trigger.new);
    }
    if(trigger.isDelete){
        AttachmentTriggerHandler.OnafterDelete(Trigger.old);
    }
}