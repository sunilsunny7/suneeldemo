/**
About
-----
Description: Orange_WebService
Create date: February 2017

Update History
--------------
Created Oct 2016 - V.M - Created. 


Issues / TODOs
--------------     
*/

global class Orange_WebService {
    
    @testvisible private static final String ERR_INVALID_ID = 'No or invalid orgnumber provided.';
    
    webservice static ActivityResponse getActivities(String orgNumber){
        System.debug('GESB_WebService.getActivities running. orgnumber: ' + orgNumber);
        
        ActivityResponse response = new ActivityResponse();
        List<Event> eventList = new List<Event>();
        if(String.isEmpty(orgNumber)){
            response.success = false;
            response.errorMsg = ERR_INVALID_ID;
        }else{
            try{
            for(Event e :[SELECT Type, Event_Type__c, Subject, StartDateTime, EndDateTime, 
                          Description, Location, Purpose__c, Objectives__c, Event_Complete__c,
                          Who.Name, Who.RecordTypeId, WhoId, OwnerId, Owner.Name, RecordTypeId, 
                          WhatId, What.Name, What.RecordTypeId, RecordTypeName__c, WhatRecordName__c, WhoRecordName__c 
                          FROM Event WHERE Account.Org_Nr__c = :orgNumber]){
                              e.RecordTypeName__c = SEUtility.getRecordTypeDevName(e.RecordTypeId);
                              e.WhatRecordName__c = SEUtility.getRecordTypeDevName(e.What.RecordTypeId);
                              e.WhoRecordName__c = SEUtility.getRecordTypeDevName(e.Who.RecordTypeId);
                              eventList.add(e);
                          }
            
            List<Task> taskList = new List<Task>();
            
            for(Task t :[SELECT Type, Task_Type__c, Subject, Comment_on_Task__c, ActivityDate,
                         Priority, Status, Event_Complete__c,
                         Who.Name, Who.RecordTypeId, WhoId, OwnerId, Owner.Name, RecordTypeId, 
                         WhatId, What.Name, What.RecordTypeId, RecordTypeName__c, WhatRecordName__c, WhoRecordName__c 
                         FROM Task WHERE Account.Org_Nr__c = :orgNumber]){
                             t.RecordTypeName__c = SEUtility.getRecordTypeDevName(t.RecordTypeId);
                             t.WhatRecordName__c = SEUtility.getRecordTypeDevName(t.What.RecordTypeId);
                             t.WhoRecordName__c = SEUtility.getRecordTypeDevName(t.Who.RecordTypeId);
                             taskList.add(t);
                         }
            
            response.success = true;
            response.events = eventList;
            response.tasks = taskList;
            }catch (Exception ex){
            	response.success = false;
                response.errorMsg = ex.getMessage();
            	return response;
            } 
        }
        return response;
    }
    
    global class ActivityResponse{
        webservice List<Event> events;
        webservice List<Task> tasks;
        webservice Boolean success;
        webservice String errorMsg;
    }
    
    
    global class ActivityRequest{
        webservice String orgNumber; // Org number
        webservice DateTime startDate; // Search for leads created >= this date. System default is 180 days back in time. 
        webservice DateTime endDate; // Search for leads created <= this date.
        webservice Integer maxRows; // Max number of rows in the replay. System default is to be 500 rows.
    }
    
}