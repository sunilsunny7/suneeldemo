/**
    About
    -----
    Description: Before update trigger on Task object
    Create date: September 2015

    Filters:
    -------
    None
            
    Update History
    --------------
    Created September - A.N. if task is created with an inactive contact, do not save the record but add error message
    Update October - P.P. If task belongs to an Org Account which is a child of 'Other Terminated Account', do not save record, add error message
    Updated Sep 2016 - A.N Merged functionality into TaskTriggerHandler
    
    Issues / TODOs

    DELETE THIS CLASS
    -------------- 
    
*/

trigger TaskBeforeInsert on Task (before insert) {

    /* Merged into TaskTriggerHandler methods validateContactIsActive and validateAccountNotTerminated    
    // Create a set to hold all the whoIds
    Set<Id> whoIds = new Set<Id>();
    //changes by PP
    Set<Id> whatIds = new Set<Id>();
    for (Task t : Trigger.new){
        whoIds.add(t.WhoId);
        /*changes by PP
        whatIds.add(t.WhatId);
        }

    // Create a map over all contacts related to the new Tasks by querying the whoId's
    Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Inaktiv__c from Contact where Id in :whoIds]);
    
    //changes by PP
    // Query for Parent Account which needs to be blocked for Task Creation
    Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Parent.Kundkonto_Nr__c from Account WHERE Id IN: whatIds]);
    String accRef = Label.Account_to_Bypass_for_Tasks;
    
    // If inactive contact, the Task should not be saved. An error message will be presented to the user.
    for (Task t : Trigger.new){
        Contact con = contactMap.get(t.WhoId);
        if(con != null){
            if(con.Inaktiv__c){
                t.addError('Det är inte möjligt att skapa en uppgift på en inaktiv kontakt');
            }
        }
        //changes by PP
        Account acc = accountMap.get(t.WhatId);
        if(acc != Null){
            if(acc.parent.Kundkonto_Nr__c == accRef){
                t.addError('Terminerat konto! Registrering av aktivitet ej tillåtet');
            }
        }
    }
    */
}