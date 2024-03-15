/**
    About
    -----
    Description: After trigger on Opportunity Team Member
    Create date: October 2015
    
    Filters:
    -------
    1. Filters out all the team members that belongs to a closed/won opportunity
    
    Update History
    --------------
    Created Oct 2015 - V.I
    Updated Aug 2016 - N.G Added calls to OppTeamMemberHandler trigger handler class
    Updated Sep 2016 - Merged existing functionality in trigger into the new method createSolutionSalesOutcomeRecords in OppTeamMemberHandler
    Updated Feb 2017 - S.M Added Before trigger and merged existing before trigger into the new method SetUserRoleOnOpportunityTeam in OppTeamMemberHandler
    Updated Feb 2017 - S.M changed the name of the trigger from OpportunityTeamMemberAfter to OpportunityTeamMemberBeforeAfter
    Issues / TODOs
    --------------  

*/

trigger OpportunityTeamMemberBeforeAfter on OpportunityTeamMember (before insert,before update,after insert, after update, after delete) {
    
    OppTeamMemberHandler handler = new OppTeamMemberHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new);
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }

    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new);
    }

    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old);
    }
    
}