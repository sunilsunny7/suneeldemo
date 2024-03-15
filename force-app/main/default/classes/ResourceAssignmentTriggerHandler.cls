/**
About
-----
Description: ResourceAssignmentTriggerHandler on ResourceAssignment
Create date: 15.09-2017

Update History
--------------
Created Oct 2016 - V.M - SAEN-2446 Created RP: add/update opportunity team from assignment role

**/

public class ResourceAssignmentTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public ResourceAssignmentTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    private static boolean acc_isExecuting = false;
    
    
    public void OnBeforeInsert(List<ResourceHeroApp__Resource_Assignment__c> newList){  
        System.debug('ResourceAssignmentTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);       
    }
    
    public void OnBeforeUpdate(
        List<ResourceHeroApp__Resource_Assignment__c> newList, 
        Map<ID, ResourceHeroApp__Resource_Assignment__c> newMap, 
        List<ResourceHeroApp__Resource_Assignment__c> oldList, 
        Map<ID, ResourceHeroApp__Resource_Assignment__c> oldMap){
            System.debug('ResourceAssignmentTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        }
    
    public void OnAfterInsert(List<ResourceHeroApp__Resource_Assignment__c> newList, Map<ID, ResourceHeroApp__Resource_Assignment__c> newMap){
        System.debug('ResourceAssignmentTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        AddOpportunityTeamMember(newMap);
    }
    
    public void OnAfterUpdate(
        List<ResourceHeroApp__Resource_Assignment__c> newList, 
        Map<ID, ResourceHeroApp__Resource_Assignment__c> newMap, 
        List<ResourceHeroApp__Resource_Assignment__c> oldList, Map<ID, 
        ResourceHeroApp__Resource_Assignment__c> oldMap){
            System.debug('ResourceAssignmentTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
            UpdateOpportunityTeamMember(newMap, oldMap);
        }
    
    public void OnAfterDelete(List<ResourceHeroApp__Resource_Assignment__c> oldList, Map<ID, ResourceHeroApp__Resource_Assignment__c> oldMap){
        System.debug('ResourceAssignmentTriggerHandler.OnAfterDelete starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
    }
    
    public void OnBeforeDelete(List<ResourceHeroApp__Resource_Assignment__c> oldList, Map<ID, ResourceHeroApp__Resource_Assignment__c> oldMap){
        System.debug('ResourceAssignmentTriggerHandler.OnBeforeDelete starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        DeleteOpportunityTeamMember(oldMap);
    }
    
    public void OnAfterUndelete(List<ResourceHeroApp__Resource_Assignment__c> newList, Map<ID, ResourceHeroApp__Resource_Assignment__c> newMap){
        System.debug('ResourceAssignmentTriggerHandler.OnAfterUndelete starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
    }
    
    public static final String STATUS_BOOKED = 'Booked';
    public static final String STATUS_PLANNED = 'Planned';
    
    public void AddOpportunityTeamMember(Map<Id, ResourceHeroApp__Resource_Assignment__c> newMap){
        if(newMap != null){
            Set<Id> bookedRaIds = new Set<Id>();
            
            for(ResourceHeroApp__Resource_Assignment__c ra : newMap.values()){
                if(ra.ResourceHeroApp_Status__c == STATUS_BOOKED 
                   && ra.ResourceHeroApp__Resource__c != null 
                   && ra.ResourceHeroApp__Opportunity__c != null ){
                       bookedRaIds.add(ra.Id);
                   }
            }
            
            if(!bookedRaIds.isEmpty()){
                //OpprotunityId, List<ResourceAssignment> to map all Resource Assignment to it's Opportunity
                Map<Id, List<ResourceHeroApp__Resource_Assignment__c>> oppRaMap = new Map<Id, List<ResourceHeroApp__Resource_Assignment__c>>();
                for(ResourceHeroApp__Resource_Assignment__c ra : [SELECT Id, ResourceHeroApp__Resource__r.ResourceHeroApp__User__c, ResourceHeroApp__Opportunity__c, ResourceHeroApp__Role__c 
                                                                  FROM ResourceHeroApp__Resource_Assignment__c 
                                                                  WHERE Id IN :bookedRaIds]){
                                                                      if(oppRaMap.get(ra.ResourceHeroApp__Opportunity__c) == null){
                                                                          List<ResourceHeroApp__Resource_Assignment__c> raList = new List<ResourceHeroApp__Resource_Assignment__c>();
                                                                          raList.add(ra);
                                                                          oppRaMap.put(ra.ResourceHeroApp__Opportunity__c, raList);
                                                                          
                                                                      }else{
                                                                          oppRaMap.get(ra.ResourceHeroApp__Opportunity__c).add(ra);
                                                                      }
                                                                  }
                
                
                if(!oppRaMap.isEmpty()){
                    //Resource Assignment, OpportunityTeamMember 
                    Map<Id, OpportunityTeamMember> raTeamMap = new Map<Id, OpportunityTeamMember>();
                    
                    for(OpportunityTeamMember otm : [SELECT UserId, TeamMemberRole, OpportunityId, Resource_Assignment__c
                                                     FROM OpportunityTeamMember 
                                                     WHERE OpportunityId IN :oppRaMap.keySet() AND Resource_Assignment__c != null]){
                                                         raTeamMap.put(otm.Resource_Assignment__c, otm);
                                                     }                            
                    
                    
                    List<OpportunityTeamMember> otmToUpsert = new List<OpportunityTeamMember>();
                    
                    for(Id oppId :oppRaMap.keySet()){
                        for(ResourceHeroApp__Resource_Assignment__c ra :oppRaMap.get(oppId)){
                            
                            //If we already have created a OpportunityTeamMember from assignment, we need to update it.
                            if(raTeamMap.get(ra.Id) != null){
                                raTeamMap.get(ra.Id).TeamMemberRole = ra.ResourceHeroApp__Role__c;
                                raTeamMap.get(ra.Id).UserId = ra.ResourceHeroApp__Resource__r.ResourceHeroApp__User__c;
                                otmToUpsert.add(raTeamMap.get(ra.Id));
                            }else{
                                //Create a new OpportunityTeamMember on the Opportunity
                                OpportunityTeamMember otm = new OpportunityTeamMember();
                                otm.OpportunityId = ra.ResourceHeroApp__Opportunity__c;
                                otm.TeamMemberRole = ra.ResourceHeroApp__Role__c;
                                otm.UserId = ra.ResourceHeroApp__Resource__r.ResourceHeroApp__User__c;
                                otm.Resource_Assignment__c = ra.Id;
                                otmToUpsert.add(otm);
                            }
                        }
                    }
                    
                    if(!otmToUpsert.isEmpty()){
                        upsert otmToUpsert;
                    }
                }
            } 
        }
    }
    
    public void UpdateOpportunityTeamMember(Map<Id, ResourceHeroApp__Resource_Assignment__c> newMap, Map<Id, ResourceHeroApp__Resource_Assignment__c> oldMap){
        if(newMap != null){
            Set<Id> bookedRaIds = new Set<Id>();
            Set<Id> unBookedRaIds = new Set<Id>();
            
            List<OpportunityTeamMember> otmToUpsert = new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> otmToDelete = new List<OpportunityTeamMember>();
            
            for(ResourceHeroApp__Resource_Assignment__c ra : newMap.values()){
                if(ra.ResourceHeroApp_Status__c == STATUS_BOOKED && ra.ResourceHeroApp__Opportunity__c != null){
                    bookedRaIds.add(ra.Id);
                }
                
                if(ra.ResourceHeroApp_Status__c != STATUS_BOOKED && ra.ResourceHeroApp_Status__c != oldMap.get(ra.Id).ResourceHeroApp_Status__c && ra.ResourceHeroApp__Resource__c != null && ra.ResourceHeroApp__Opportunity__c != null){
                    unBookedRaIds.add(ra.Id);
                }
            }
            
            if(!bookedRaIds.isEmpty()){
                //OpprotunityId, List<ResourceAssignment> to map all Resource Assignment to it's Opportunity
                Map<Id, List<ResourceHeroApp__Resource_Assignment__c>> oppRaMap = new Map<Id, List<ResourceHeroApp__Resource_Assignment__c>>();
                for(ResourceHeroApp__Resource_Assignment__c ra : [SELECT Id, ResourceHeroApp__Resource__c, ResourceHeroApp__Resource__r.ResourceHeroApp__User__c, ResourceHeroApp__Opportunity__c, ResourceHeroApp__Role__c 
                                                                  FROM ResourceHeroApp__Resource_Assignment__c 
                                                                  WHERE Id IN :bookedRaIds]){
                                                                      if(oppRaMap.get(ra.ResourceHeroApp__Opportunity__c) == null){
                                                                          List<ResourceHeroApp__Resource_Assignment__c> raList = new List<ResourceHeroApp__Resource_Assignment__c>();
                                                                          raList.add(ra);
                                                                          oppRaMap.put(ra.ResourceHeroApp__Opportunity__c, raList);
                                                                          
                                                                      }else{
                                                                          oppRaMap.get(ra.ResourceHeroApp__Opportunity__c).add(ra);
                                                                      }
                                                                  }
                
                
                if(!oppRaMap.isEmpty()){
                    //Resource Assignment, OpportunityTeamMember 
                    Map<Id, OpportunityTeamMember> raTeamMap = new Map<Id, OpportunityTeamMember>();
                    
                    for(OpportunityTeamMember otm : [SELECT UserId, TeamMemberRole, OpportunityId, Resource_Assignment__c
                                                     FROM OpportunityTeamMember 
                                                     WHERE OpportunityId IN :oppRaMap.keySet() AND Resource_Assignment__c != null]){
                                                         raTeamMap.put(otm.Resource_Assignment__c, otm);
                                                     }                            
                    
                    
                    
                    
                    for(Id oppId :oppRaMap.keySet()){
                        for(ResourceHeroApp__Resource_Assignment__c ra :oppRaMap.get(oppId)){
                            
                            //If we already have created a OpportunityTeamMember from assignment, we need to update it.
                            //If we have changed the User, we need to delete the OpportunityTeamMember and create a new one since we cannot update UserId
                            if(raTeamMap.get(ra.Id) != null && raTeamMap.get(ra.Id).UserId == ra.ResourceHeroApp__Resource__r.ResourceHeroApp__User__c){
                                raTeamMap.get(ra.Id).TeamMemberRole = ra.ResourceHeroApp__Role__c; 
                                otmToUpsert.add(raTeamMap.get(ra.Id));
                                
                            }else{
                                //Create a new OpportunityTeamMember on the Opportunity, 
                                //If we have changed the User, we need to delete the OpportunityTeamMember and create a new one since we cannot update UserId
                                if(raTeamMap.get(ra.Id) != null && raTeamMap.get(ra.Id).UserId != ra.ResourceHeroApp__Resource__r.ResourceHeroApp__User__c){
                                    otmToDelete.add(raTeamMap.get(ra.Id));
                                }
                                OpportunityTeamMember otm = new OpportunityTeamMember();
                                otm.OpportunityId = ra.ResourceHeroApp__Opportunity__c;
                                otm.TeamMemberRole = ra.ResourceHeroApp__Role__c;
                                otm.UserId = ra.ResourceHeroApp__Resource__r.ResourceHeroApp__User__c;
                                otm.Resource_Assignment__c = ra.Id;
                                otmToUpsert.add(otm);
                            }
                        }
                    }
                }
            }
            
            if(!unBookedRaIds.isEmpty()){
                for(OpportunityTeamMember otm : [SELECT UserId, TeamMemberRole, OpportunityId, Resource_Assignment__c
                                                 FROM OpportunityTeamMember 
                                                 WHERE Resource_Assignment__c IN :unBookedRaIds]){
                                                     otmToDelete.add(otm);
                                                 }
                
            }
            
            if(!otmToUpsert.isEmpty()){
                upsert otmToUpsert;
            }
            
            if(!otmToDelete.isEmpty()){
                try{
                    delete otmToDelete;
                }catch(exception e){
                    System.debug('Could not delete OpportunityTeamMember: ' + e.getMessage());
                }
            }
        }
    }
    
    public void DeleteOpportunityTeamMember(Map<Id, ResourceHeroApp__Resource_Assignment__c> oldMap){
        List<OpportunityTeamMember> otmToDelete = new List<OpportunityTeamMember>();
        
        for(OpportunityTeamMember otm : [SELECT UserId, TeamMemberRole, OpportunityId, Resource_Assignment__c
                                         FROM OpportunityTeamMember 
                                         WHERE Resource_Assignment__c IN :oldMap.keySet()]){
                                             otmToDelete.add(otm);
                                         }
        
        
        
        if(!otmToDelete.isEmpty()){
            try{
                delete otmToDelete;
            }catch(exception e){
                System.debug('Could not delete OpportunityTeamMember: ' + e.getMessage());
            }
            
        }
    }
}