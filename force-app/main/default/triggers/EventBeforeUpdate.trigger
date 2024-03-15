/**
    About
    -----
    Description: Before update trigger on Event object
    Create date: March 2015

    Filters:
    -------
    1. Filters out all the related accounts to event where completed date is not null
            
    Update History
    --------------
    Created March 2015 - V.I
	Updated May 2015 - V.I removed purpose field on Event
    Updated Feb 2016 - A.N. Functionality merged into EventTriggerHandler

    Issues / TODOs
    -------------- 

    DELETE THIS TRIGGER
    
*/

trigger EventBeforeUpdate on Event (before update) {

}