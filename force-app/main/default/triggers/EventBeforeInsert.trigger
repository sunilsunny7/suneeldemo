/**
    About
    -----
    Description: Before update trigger on Event object
    Create date: September 2015
            
    Update History
    --------------
    Created Sep 2016 - A.N. if event is created with an inactive contact, do not save the record but add error message
    Updated Feb 2016 - A.N. Functionality merged into EventTriggerHandler
    
*/

trigger EventBeforeInsert on Event (before insert) {

}