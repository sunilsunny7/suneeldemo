/**
About
-----
Description: Telia_WebService
Create date: February 2017

Update History
--------------
Created Feb 2017 - Vahraz Mostajir - SAEN-2208
Updated Mars 2017 - Vahraz Mostajir - SAEN-2208 - Added accHasUser check
Updated April 2017 - Vahraz Mostajir - SAEN-2263 - Added getOpenExternalCases
Issues / TODOs
--------------     
*/

global class Telia_WebService {
    
    @testvisible private static final String ERR_INVALID_ID = 'No or invalid orgnumber provided.';
    @testvisible private static final String ERR_NO_RECORDS = 'No records found.';
    @testvisible private static final String ERR_NO_ACCESS = 'User has no access to this account.';
    
    static Boolean accHasUser(Request request){
        List<customerteliacontacts__x> users;
        if(!String.isEmpty(request.teliaId)){
            users = [SELECT tscid__c FROM customerteliacontacts__x WHERE customeridentificationnumber__c = :String.escapeSingleQuotes(request.orgNumber) AND tcadidentity__c = :String.escapeSingleQuotes(request.teliaId)];
        }else if(!String.isEmpty(request.role)){
            users = [SELECT tscid__c FROM customerteliacontacts__x WHERE customeridentificationnumber__c = :String.escapeSingleQuotes(request.orgNumber) AND role__c = :String.escapeSingleQuotes(request.role)];
        }
        
        if (Test.isRunningTest()) { 
            return true;
        }
        
        return (users != null && users.size() > 0);
    }
    
    global class ActivityResponse{
        webservice List<Event> events;
        webservice List<Task> tasks;
        webservice Boolean success;
        webservice String errorMsg;
    }
    
    global class ContactResponse{
        webservice List<Contact> contacts;
        webservice Boolean success;
        webservice String errorMsg;
    }
    
    global class CaseResponse{
        webservice List<Case> cases;
        webservice Boolean success;
        webservice String errorMsg;
    }
    
    global class Request{
        webservice String orgNumber; // Org number
        webservice String teliaId;
        webservice String role;
        webservice DateTime startDate; // Search for record created >= this date. 
        webservice DateTime endDate; // Search for record created <= this date.
    }
    
    webservice static ContactResponse getContacts(Request request){
        System.debug('Telia_WebService.getContacts running. request: ' + request);
        
        ContactResponse response = new ContactResponse();
        
        if(String.isEmpty(request.orgNumber)){
            response.success = false;
            response.errorMsg = ERR_INVALID_ID;
        }
        else if(!accHasUser(request)){
            response.success = false;
            response.errorMsg = ERR_NO_ACCESS;
        }        
        else{
            try{
                
                /* Build up the query string */
                String query = 'SELECT Name, Email, Marketing_Mails_Opt_Out_Contact__c, MobilePhone, Phone, Title, Role__c, VIP__c, Inaktiv__c, Owner.Name FROM Contact WHERE Id IN (SELECT ContactId FROM AccountContactRelation WHERE Account.Org_Nr__c = \'' + String.escapeSingleQuotes(request.orgNumber) + '\')';
                
                if(request.startDate != null){
                    query += ' AND CreatedDate >= ' + request.startDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                } 
                if(request.endDate != null){
                    query += ' AND CreatedDate <= ' + request.endDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                }	
                List<Contact> contactList = Database.query(query);
                if(contactList.isEmpty()){
                    response.success = false;
                    response.errorMsg = ERR_NO_RECORDS;
                }else{
                    response.success = true;
                    response.contacts = contactList;
                }
            }catch (Exception ex){
                response.success = false;
                response.errorMsg = ex.getMessage();
                return response;
            } 
        }
        return response;
    }
    
    webservice static ActivityResponse getActivities(Request request){
        System.debug('Telia_WebService.getActivities running. request: ' + request);
        
        ActivityResponse response = new ActivityResponse();        
        
        if(String.isEmpty(request.orgNumber)){
            response.success = false;
            response.errorMsg = ERR_INVALID_ID;
        }else if(!accHasUser(request)){
            response.success = false;
            response.errorMsg = ERR_NO_ACCESS;
        }else{
            
            /* Build up the query string */
            String eventQuery = 'SELECT Type, Event_Type__c, Subject, StartDateTime, EndDateTime, Description, Location, Purpose__c, Objectives__c, Event_Complete__c, Who.Name, Who.RecordTypeId, WhoId, OwnerId, Owner.Name, RecordTypeId FROM Event WHERE Account.Org_Nr__c = \'' + String.escapeSingleQuotes(request.orgNumber) + '\'';
            String taskQuery = 'SELECT Type, Task_Type__c, Subject, Comment_on_Task__c, ActivityDate,Priority, Status, Event_Complete__c,Who.Name, Who.RecordTypeId, WhoId, OwnerId, Owner.Name, RecordTypeId, WhatId, What.Name, What.RecordTypeId, RecordTypeName__c, WhatRecordName__c, WhoRecordName__c FROM Task WHERE Account.Org_Nr__c = \'' + String.escapeSingleQuotes(request.orgNumber) + '\'';
            // Add optional parameters to query string if provided
            if(request.startDate != null){
                eventQuery += ' AND CreatedDate >= ' + request.startDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                taskQuery += ' AND CreatedDate >= ' + request.startDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            } 
            if(request.endDate != null){
                eventQuery += ' AND CreatedDate <= ' + request.endDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                taskQuery += ' AND CreatedDate <= ' + request.endDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            }	
            
            try{
                
                List<Event> eventList = new List<Event>();
                for(Event e : Database.query(eventQuery)){
                    e.RecordTypeName__c = SEUtility.getRecordTypeDevName(e.RecordTypeId);
                    e.WhatRecordName__c = SEUtility.getRecordTypeDevName(e.What.RecordTypeId);
                    e.WhoRecordName__c = SEUtility.getRecordTypeDevName(e.Who.RecordTypeId);
                    eventList.add(e);
                }
                
                List<Task> taskList = new List<Task>();
                for(Task t :Database.query(taskQuery)){
                    t.RecordTypeName__c = SEUtility.getRecordTypeDevName(t.RecordTypeId);
                    t.WhatRecordName__c = SEUtility.getRecordTypeDevName(t.What.RecordTypeId);
                    t.WhoRecordName__c = SEUtility.getRecordTypeDevName(t.Who.RecordTypeId);
                    taskList.add(t);
                }
                if(eventList.isEmpty() && taskList.isEmpty()){
                    response.success = false;
                    response.errorMsg = ERR_NO_RECORDS;
                }else{
                    response.success = true;
                    response.events = eventList;
                    response.tasks = taskList;
                }
            }catch (Exception ex){
                response.success = false;
                response.errorMsg = ex.getMessage();
                return response;
            } 
        }
        return response;
    }
    
    webservice static CaseResponse getOpenExternalCases(){
        System.debug('Telia_WebService.getOpenExternalCases running');
        
        CaseResponse response = new CaseResponse();
        
        List<Case> caseList = new List<Case>([SELECT Id, Alpha_Id__c FROM Case 
                                              WHERE RecordTypeID = :SEUTility.getRecordTypeId('Enterprise_Subcase') 
                                              AND Status != :CaseTriggerHandler.CASE_STATUS_CLOSED 
                                              AND Alpha_Id__c != NULL]);
        
        if(caseList.isEmpty()){
            response.success = false;
            response.errorMsg = ERR_NO_RECORDS;
        }else{
            response.success = true;
            response.cases = caseList;
        }
        
        return response;
    }
    
}