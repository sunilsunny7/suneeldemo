/**
    About
    -----
    Description: Before insert and after insert trigger on Yearly_Target__c object
    Create date: March 2015

    Filters:
    -------
    1. None

    Update History
    --------------
    Created March 2015 - C.G.
    Updated Aug 2015 - C.G
    Updated Aug 2015 - V.I Repointing of Opportunities on insert of Yearly Target
    Updated Sep 2015 - V.I Changed validation for yearly target so that more than one yearly target can be created per user (but only one per seller)
    Updated Sep 2015 - V.I Added validation rule - Yearly target must be created for the superior users before the subordinates yearly target is created
    Updated Sep 2015 - V.I When repointing the opportunities set the Apex Updated field to bypass the opportunity validation rules
    Updated Sep 2015 - V.I Exchanged all the Business Area Manager to use the new picklist Hierarchy_Level__c
    Updated Oct 2015 - A.N Moved functionality to YearlyTargetTriggerHandler
    Updated Feb 2016 - A.N Added before/after update support to trigger. Deleted old outcommented code.
    
    Issues / TODOs
    --------------  
    
*/
trigger YearlyTargetBeforeAfterInsert on Yearly_Target__c (before insert, after insert, before update, after update) {
    
    YearlyTargetTriggerHandler handler = new YearlyTargetTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
    }

    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }

    if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
      
    if(Trigger.isUpdate && Trigger.isAfter){       
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}