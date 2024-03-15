/**
    About
    -----
    Description: After insert trigger on the Campaign object
    Create date: April 2015
    
    
    Update History
    --------------
    Created Apr 2015 - C.G
	Updated Jun 2015 - V.I
    Updated Feb 2016 - A.N Functionality merged into CampaignTriggerHandler
    
    Issues / TODOs
    --------------  

*/
trigger CampaignAfterInsert on Campaign (after insert) {
    
    CampaignTriggerHandler handler = new CampaignTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }
}