/**
About
-----
Description: Before delete, insert, update and after insert, update and undelete trigger on Opportunity
Create date: ?

Update History 
--------------
Created ? - C.G.
... update history missing...
Updated Aug 2015 - V.I. Added functionality that points opportunity towards a Seller on insert and when Opportunity Owner is updated. 
Updated Sep 2015 - V.I. Fixed bug by using oldUserIds instead of userIds when moving opportunity from one owner to another
Updated Sep 2015 - A.N. Created a new class OpportunityValidationHandler that handles all validation trigger logic.
                        Moved some existing functionality for SME from the trigger to the new class.
Updated Oct 2015 - V.I Added functionality to update the solution area
Updated Oct 2015 - A.N Much of the Opportunity logic rewritten due to changes in the data model. Moved all logic from the trigger to a new
                        Trigger handler class called OpportunityTriggerHandler.
Updated Oct 2015 - A.N Moved functionality to update the solution area to OpportunityTriggerHandler and deleted old trigger logic.
Issues / TODOs
-------------- 

(VI and AN) The new methods for update/delete Solution Sales Outcome should be moved to the trigger handler when completed

*/

trigger Opportunity on Opportunity(before delete, before insert, before update, after delete, after insert, after update, after undelete) {
    new OpportunityTriggerHandler().run();
}