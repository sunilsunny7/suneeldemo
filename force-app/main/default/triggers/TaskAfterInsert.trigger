/**
    About
    -----
    Description: After insert trigger on Task object
    Create date: March 2015
    
    Filters:
    -------
    1. Filters out all the related accounts to tasks of type Telefonmöte, Fysiskt möte or Webmöte with status Stängd
    
    Update History
    --------------
    Created Mar 2015 - V.I
    Updated May 2015 - V.I removed purpose field on Task changed status name to Stängd
    Updated May 2015 - V.I changed type of tasks to Telefonmöte, Fysiskt möte and Webmöte
    Updated Oct 2015 - V.I changed type of tasks to Telefon, Fysiskt and Web
    Updated Feb 2016 - A.N Introduced redord types to Campaigns, therefore needed to update method to get the correct Campaign_Member_Statuses__c (now calling a method in SEUtility)
    Updated Sep 2016 - A.N Merged functionality into TaskTriggerHandler
    
    Issues / TODOs

    DELETE THIS CLASS
    -------------- 

*/

trigger TaskAfterInsert on Task (after insert) {
    
    /* Merged into TaskTriggerHandler method updateAccountContactedDate
    //Creating Lists and Maps based on filter criteria
    Map<Id,DateTime> targetedAccounts = new Map<Id,DateTime>();

    //Filter 1
    for (Task t : Trigger.new){     
        if(t.Status != null && t.Type != null){
            if(t.Status == 'Stängd' && (t.Type == 'Telefon' || t.Type == 'Fysiskt' || t.Type == 'Web')){
                if(t.AccountId != null){        
                    if(t.ActivityDate != null){
                        targetedAccounts.put(t.AccountId,t.ActivityDate);
                    }
                    else{
                        targetedAccounts.put(t.AccountId,System.now());
                    }
                }
            }
        }
    }
    
    
    //Execute logic in a service class 
    //Filter 1          
    System.debug('Size of filter 1 result in TaskAfterInsert trigger: ' + targetedAccounts.size());
    if(!targetedAccounts.isEmpty()){
        AccountServiceClass.accountTargeted(targetedAccounts);
    }
    */

    /* Merged into TaskTriggerHandler method updateCampaignMemberStatuses
    //Retrieve the object prefix for Campaign
    Schema.DescribeSObjectResult r = Campaign.sObjectType.getDescribe();
    String campObjPrefix = r.getKeyPrefix();

    // For all contacts in trigger new 
    Set<Id> cIds = new Set<Id>(); // Contact Ids
    Set<Id> campIds = new Set<Id>(); // Campaign Ids
    for(Task t: Trigger.new){
        // If the task is connected to a contact AND of type Call AND it relates to a Campaign-> Add the id of the task to a set
        if(t.whoId != null && t.whatId != null && t.Subject != null){
            if(t.Subject == 'Call' && String.valueOf(t.whatId).substring(0,3)==campObjPrefix){
                // If the campaign is a Phone Campaign
                cIds.add(t.whoId);
                campIds.add(t.whatId);    
            }
        }
    }
    List<CampaignMember> cmList = new List<CampaignMember>();
    
    System.debug('cIds.size(): '+ cIds.size());
    // If there are more than zero related contacts to the tasks of type call 
    if(cIds.size() != 0){
        // UGLY CODE
        // TODO - Change this to dynamic code
        // List all the CampaignMembers
        cmList = [SELECT Id, Campaign.Type, Campaign.RecordTypeId FROM CampaignMember WHERE campaign.isActive = true AND (Campaign.Type='Telefon' OR Campaign.Type='Apsis') AND ContactId IN :cIds AND CampaignId IN :campIds];
        for(CampaignMember cm : cmList){

            //Get the first 
            Campaign_Member_Statuses__c cms = SEUtility.getCampaignMemberStatus(cm.Campaign.Type, cm.Campaign.RecordTypeId);
            if(cms == null) continue; // No custom setting found, skipping to the next itereation of the for loop

            if(cms.Status_1_Responded__c){
                cm.Status = cms.Status_1_Name__c;
            }
            if(cms.Status_2_Responded__c){
                cm.Status = cms.Status_2_Name__c;
            }
            if(cms.Status_3_Responded__c){
                cm.Status = cms.Status_3_Name__c;
            }
            if(cms.Status_4_Responded__c){
                cm.Status = cms.Status_4_Name__c;
            }
            if(cms.Status_5_Responded__c){
                cm.Status = cms.Status_5_Name__c;
            }
            if(cms.Status_6_Responded__c){
                cm.Status = cms.Status_6_Name__c;
            }
            if(cms.Status_7_Responded__c){
                cm.Status = cms.Status_7_Name__c;
            }
            if(cms.Status_8_Responded__c){
                cm.Status = cms.Status_8_Name__c;
            }    
        }
    }



    update cmList;
    */
}