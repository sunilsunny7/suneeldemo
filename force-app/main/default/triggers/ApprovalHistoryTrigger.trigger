/**
 * Created by kwn687 on 2023-01-30.
 */

trigger ApprovalHistoryTrigger on Approval_History__c(before update, before insert, after insert, after update) {
    new ApprovalHistoryTriggerHandler().run();
}