public class ReportToolController {  
    public Transient List<ActivityWrapper> getActivityList { get; set; }
    public Transient List<String> columnHeaders { get; set; }
    public Transient Integer columnCount { get; set; }
    
    public Report_Tool_Setting__c rts {get; set;}
    public static Boolean IsLoaded {get; set;}
    
    public class ActivityWrapper{
        public Transient  Event event { get; set; }
        public Transient  Task task { get; set; }
        public Transient  List<Contact> contacts { get; set; }
        public Transient  Opportunity opportunity { get; set; }
        public Transient  Account account { get; set; }
        public Transient  Campaign campaign { get; set; }
    }
    
    public ReportToolController(){  
        IsLoaded = false;
        System.debug(rts);
        if(rts == null){
       		 rts = new Report_Tool_Setting__c();
        }    
    }  
    
    public PageReference LoadReport(){
        IsLoaded = true;
        getActivityList = new List<ActivityWrapper>();
        columnCount = 0;
        
        if(rts.EventRecordType_Id__c != null){
            loadEventData(20);
        }
        if(rts.TaskRecordType_Id__c != null){
            loadTaskData(20);
        }
        
        setColumnHeaders(columnCount);
        
        return null;
    }
    
    public PageReference ExportReport(){
             getActivityList = new List<ActivityWrapper>();
         columnCount = 0;
            if(rts.EventRecordType_Id__c != null){
                loadEventData(9999);
            }
            if(rts.TaskRecordType_Id__c != null){
                loadTaskData(9999);
            }
            setColumnHeaders(columnCount);
        	PageReference exportPage = new PageReference('/apex/ExportPage');
            exportPage.setRedirect(false);
            return exportPage;
    }
    
    private void loadEventData(Integer rowLimit){
        //EventId, whoId/whatId
        Map<Id, Id> whatIds = new Map<Id, Id>();
        Map<Id, Id> whoIds = new Map<Id, Id>();
        
        Map<Id, Event> events = new Map<Id, Event>();
        
        //Picklist values as list
        List<String> picklistValues = new List<String>();
        
        String queryString = generateQuery('Event', rowLimit, picklistValues);
        System.debug(queryString);
        
        List<Event> eventList = Database.query(queryString);
        for(Event e : eventList){
            events.put(e.Id, e);
            whatIds.put(e.Id, e.WhatId);
            whoIds.put(e.Id, e.WhoId);
        }
        
        Map<Id, List<Contact>> eventContactMap = getEventContactMap(events.keySet());
        Map<Id, Account> accounts = getAccounts(whoIds.values());
        Map<Id, Campaign> campaigns = getCampaigns(whatIds.values());
        Map<Id, Opportunity> opportunities = getOpportunities(whatIds.values());
        
        //Wrap everything up
        for(Id eId :whatIds.keySet()){
            if(rts.Opportunity_Campaign__c == null || (opportunities.get(whatIds.get(eId)) != null && opportunities.get(whatIds.get(eId)).Campaign.Id == rts.Opportunity_Campaign__c)){
                ActivityWrapper aw = new ActivityWrapper();
                aw.event = events.get(eId);
                aw.opportunity = opportunities.get(whatIds.get(eId));
                aw.account = accounts.get(whatIds.get(eId));
                aw.campaign = campaigns.get(whatIds.get(eId));
                aw.contacts = eventContactMap.get(eId);
                getActivityList.add(aw);
                
                if(aw.contacts == null){
                    
                }
                else if(columnCount < aw.contacts.size()){
                    columnCount = aw.contacts.size();
                }
            }
        }
    }
    
    private void loadTaskData(Integer rowLimit){
        //TaskId, whoId/whatId
        Map<Id, Id> whatIds = new Map<Id, Id>();
        Map<Id, Id> whoIds = new Map<Id, Id>();
        
        Map<Id, Task> tasks = new Map<Id, Task>();
        
        //Picklist values as list
        List<String> picklistValues = new List<String>();
        
        String queryString = generateQuery('Task', rowLimit, picklistValues);
        System.debug(queryString);
        
        List<Task> taskList = Database.query(queryString);
        for(Task t : taskList){
            tasks.put(t.Id, t);
            whatIds.put(t.Id, t.WhatId);
            whoIds.put(t.Id, t.WhoId);
        }
        
        Map<Id, List<Contact>> taskContactMap = getTaskContactMap(tasks.keySet());
        Map<Id, Account> accounts = getAccounts(whoIds.values());
        Map<Id, Campaign> campaigns = getCampaigns(whatIds.values());
        Map<Id, Opportunity> opportunities = getOpportunities(whatIds.values());
        
        //Wrap everything up
        for(Id tId :whatIds.keySet()){      
            if(rts.Opportunity_Campaign__c == null || (opportunities.get(whatIds.get(tId)) != null &&  opportunities.get(whatIds.get(tId)).Campaign.Id == rts.Opportunity_Campaign__c)){
                ActivityWrapper aw = new ActivityWrapper();
                aw.task = tasks.get(tId);
                aw.opportunity = opportunities.get(whatIds.get(tId));
                aw.account = accounts.get(whatIds.get(tId));
                aw.campaign = campaigns.get(whatIds.get(tId));
                aw.contacts = taskContactMap.get(tId);
                getActivityList.add(aw);
                
                if(aw.contacts == null){
                    
                }
                else if(columnCount < aw.contacts.size()){
                    columnCount = aw.contacts.size();
                }
            }
        }
    }
    
    //Generate query string based on filters
    private String generateQuery(String ActivityType, Integer rows, List<String> picklistValues){
        String queryString = 'SELECT id, Owner.Name, Subject, WhatId, Who.Name, Customer_status__c, Points__c, Type, Cloud_Datacentre__c, Presented_Cloudanalysis__c, Sambes_k__c, ';
        
        //If it's Event we query Event related fields
        if(ActivityType == 'Event'){
            queryString += 'StartDateTime, EndDateTime FROM Event WHERE RecordTypeId = \'' + rts.EventRecordType_Id__c +'\'';
            if(rts.Start_Date_Time__c != Null){
                queryString += ' AND StartDateTime >= ' + rts.Start_Date_Time__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            }
            if(rts.End_Date_Time__c != Null){
                queryString += ' AND EndDateTime <= ' + rts.End_Date_Time__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            }
            
            if(rts.Event_Type__c != null){
                picklistValues.addAll(rts.Event_Type__c.split(';'));
                queryString += ' AND Type IN :picklistValues';
            }   
        }
        
        //If it's Task we query Task related fields
        if(ActivityType == 'Task'){
            queryString += 'ActivityDate FROM Task WHERE RecordTypeId = \'' + rts.TaskRecordType_Id__c +'\'';
            if(rts.Start_Date_Time__c != Null){
                queryString += ' AND ActivityDate >= ' + rts.Start_Date_Time__c.format('yyyy-MM-dd');
            }
            if(rts.End_Date_Time__c != Null){
                queryString += ' AND ActivityDate <= ' + rts.End_Date_Time__c.format('yyyy-MM-dd');
            }   
            
            if(rts.Task_Type__c != null){
                picklistValues.addAll(rts.Task_Type__c.split(';'));
                queryString += ' AND Type IN :picklistValues';
            }
        }
        
        //Shared Activity fields can be queryed without Type
        if(rts.Presented_Cloud_Datacenter__c != Null){
            queryString += ' AND Cloud_Datacentre__c = ' + rts.Presented_Cloud_Datacenter__c;
        }
        if(rts.Presented_Cloudananalys__c != Null){
            queryString += ' AND Presented_Cloudanalysis__c = ' + rts.Presented_Cloudananalys__c;
        }
        if(rts.Sambesok__c != Null){
            queryString += ' AND Sambes_k__c = ' + rts.Sambesok__c;
        }
        if(rts.Campaign__c != Null){
            queryString += ' AND WhatId = \'' + rts.Campaign__c + '\'';
        }
        if(rts.Opportunity_Campaign__c != Null){
              queryString += ' AND WhatId IN (SELECT Id FROM Opportunity WHERE Campaign.Id = \'' + rts.Opportunity_Campaign__c + '\')';
        }
         
        
        
        queryString += ' LIMIT ' + rows;
        
        System.debug(queryString);
        
        return queryString;
    }
    
    
    //Used to dynamically set the contact columns based on the number of them needed
    private void setColumnHeaders(Integer contactColumns){
        columnHeaders = new List<String>();
        for(Integer i = 1; i <= contactColumns; i++){
            columnHeaders.add('Contact Name ' + i);
            columnHeaders.add('Contact Role ' + i);
            columnHeaders.add('Contact Account ' + i);
        }
    }
    
    //Get all related Accounts
    private Map<Id, Account> getAccounts(List<Id> whoIds){
        Map<Id, Account> accounts = new Map<Id, Account>();
        for (Account a : [SELECT id, Name FROM Account WHERE Id IN :whoIds]){  
            accounts.put(a.id, a);
        }
        return accounts;
    }
    
    //Get all related Campaigns
    private Map<Id, Campaign> getCampaigns(List<Id> whatIds){
        Map<Id, Campaign> campaigns = new Map<Id, Campaign>();
        for (Campaign c : [SELECT id, Name FROM Campaign WHERE Id IN :whatIds]){     
            campaigns.put(c.id, c);
        }
        return campaigns;
    }
    
    //Get all related Opportunities
    private Map<Id, Opportunity> getOpportunities(List<Id> whatIds){
        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>();
        for (Opportunity o : [SELECT id, Name, Campaign.Name, Campaign.Id FROM Opportunity WHERE Id IN :whatIds]){       
            opportunities.put(o.id, o);
        }
        return opportunities;
    }
    
    //Get all related Contacts so we can use the field information
    private Map<Id, Contact> getContacts(Set<Id> contactIds){
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        for (Contact c : [SELECT Name, Telia_User__r.UserRole.Name, Cygate_User__r.UserRole.Name, Account.Name FROM Contact WHERE Id IN :contactIds]){ 
            contacts.put(c.id, c);
        }
        return contacts;
    }
    
    //Map contacts to event as a list
    private Map<Id, List<Contact>> getEventContactMap(Set<Id> eventIds){
        
        Set<Id> contactIds = new set<Id>();
        List<EventRelation> eventRelations = new List<EventRelation>();
        //Get all related EventRelations so we can query all invited contacts
        for (EventRelation er : [SELECT RelationId, EventId FROM EventRelation WHERE EventId IN :eventIds AND IsWhat = False]){ 
            eventRelations.add(er);
            contactIds.add(er.RelationId);
        }
        
        Map<Id, Contact> contacts = getContacts(contactIds);
        
        Map<Id, List<Contact>> eventContactMap = new Map<Id, List<Contact>>();
        
        //Map Contacts to Events
        for(EventRelation er : eventRelations){
            if(eventContactMap.containsKey(er.EventId)){
                eventContactMap.get(er.EventId).add(contacts.get(er.RelationId));
            }else{
                List<Contact>  contactList = new List<Contact>();
                contactList.add(contacts.get(er.RelationId));
                eventContactMap.put(er.EventId, contactList);
            } 
        }
        
        return eventContactMap;
    }
    
    private Map<Id, List<Contact>> getTaskContactMap(Set<Id> taskIds){
        
        Set<Id> contactIds = new set<Id>();
        List<TaskRelation> taskRelations = new List<TaskRelation>();
        //Get all related EventRelations so we can query all invited contacts
        for (TaskRelation tr : [SELECT RelationId, TaskId FROM TaskRelation WHERE TaskId IN :taskIds AND IsWhat = False]){ 
            taskRelations.add(tr);
            contactIds.add(tr.RelationId);
        }
        
        Map<Id, Contact> contacts = getContacts(contactIds);
        
        Map<Id, List<Contact>> taskContactMap = new Map<Id, List<Contact>>();
        
        //Map Contacts to Events
        for(TaskRelation tr : taskRelations){
            if(taskContactMap.containsKey(tr.TaskId)){
                taskContactMap.get(tr.TaskId).add(contacts.get(tr.RelationId));
            }else{
                List<Contact>  contactList = new List<Contact>();
                contactList.add(contacts.get(tr.RelationId));
                taskContactMap.put(tr.TaskId, contactList);
            } 
        }
        
        return taskContactMap;
    }
}