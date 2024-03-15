/**
About
-----
Description: TriggerHandler on Events
- On creation the old EventBeforeInsert and EventBeforeUpdate triggers where merged into the new trigger handler
Create date: 23.02.2016

    CampaignAfterInsert Update History
    --------------
    Created Apr 2015 - C.G No description
    Updated Jun 2015 - V.I No description
    Updated Feb 2016 - A.N - Merged functionality from old trigger to the new method deleteInsertCampaignMemberStatuses. Simplified the original code and removed unnecessary SOQL queries 
    Updated Feb 2016 - A.N - Introduced redord types to Campaigns, therefore needed to update method to get the correct Campaign_Member_Statuses__c (now calling a method in SEUtility to get this from the custom settings)
    Updated Feb 2016 - A.N - In the deleteInsertCampaignMemberStatuses, replaced standard insert/delete with Database.insert, as the code threw exceptions when cloning 
    Updated Feb 2016 - A.N - In the deleteInsertCampaignMemberStatuses, replaced standard insert/delete with Database.insert, as the code threw exceptions when cloning 
    Updated Mar 2019 - D.C. - In the setMemberStatuses, added capacity to fill up campaign Member status values till 17 from 12.
    Updated APR 2019 - D.C. - In the setMemberStatuses, added capacity to fill up campaign Member status values for 18 and 19.
    
Update History
--------------
Created Feb 2016 - A.N.



*/

public class CampaignTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public CampaignTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(List<Campaign> newList, Map<ID, Campaign> newMap){
        System.debug('CampaignTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' +Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        deleteInsertCampaignMemberStatuses(newList);
    }

    /* Author C.G/V.I - Updated by A.N when merged into trigger handler
    *  A.N Simplified the original code and removed unnecessary SOQL queries 
    *  This code will delete all the standard CampaignMemberStatuses added by Salesforce and replace with Telias custom member statuses. */
    private static void deleteInsertCampaignMemberStatuses(List<Campaign> newList){

        List<CampaignMemberStatus> cms2Delete = new List<CampaignMemberStatus>(); // The standard cms that shall be deleted
        // Delete the standard campaign member statues
        Integer sortOrder = 0;
        for (CampaignMemberStatus cm: [Select Id, Label, CampaignID, SortOrder FROM CampaignMemberStatus WHERE CampaignId IN :newList]){
            if(cm.sortOrder> sortOrder){
                sortOrder = cm.SortOrder;
            }
            cms2Delete.add(cm);
        }

        List<CampaignMemberStatus> cms2Insert = setMemberStatuses(newList,sortOrder);

        //If the original campaign member status has the same label as one of the new ones it should not be deleted
        for(Integer i = 0; i < cms2Delete.size(); i++){
            for(CampaignMemberStatus cmsIns: cms2Insert){
                if(cms2Delete[i].Label == cmsIns.Label){
                    cms2Delete.remove(i);
                }
            }
        }

        Database.insert(cms2Insert, false);
        Database.delete(cms2Delete, false);
    }

    
    private static List<CampaignMemberStatus> setMemberStatuses(List<Campaign> campList, Integer sortOrderStart){
        List<CampaignMemberStatus> cms2Insert = new List<CampaignMemberStatus>(); 

        for(Campaign cm : campList){            
            // Retrieve a specific custom setting instance mapped to the selected type of Campaign
            Campaign_Member_Statuses__c cms = SEUtility.getCampaignMemberStatus(cm);
            if(cms == null) continue; // No custom setting found, skipping to the next itereation of the for loop

            //Create a CampaignMemberStatus if the custom setting contains a value for the Campaign type
            if(cms.Status_1_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_1_Name__c, HasResponded=cms.Status_1_Responded__c, IsDefault = cms.Status_1_Default__c, SortOrder=3)); //SortOrder=sortOrderStart+1
            if(cms.Status_2_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_2_Name__c, HasResponded=cms.Status_2_Responded__c, IsDefault = cms.Status_2_Default__c, SortOrder=4)); //SortOrder=sortOrderStart+2   
            if(cms.Status_3_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_3_Name__c, HasResponded=cms.Status_3_Responded__c, IsDefault = cms.Status_3_Default__c, SortOrder=5)); //SortOrder=sortOrderStart+3
            if(cms.Status_4_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_4_Name__c, HasResponded=cms.Status_4_Responded__c, IsDefault = cms.Status_4_Default__c, SortOrder=6)); //SortOrder=sortOrderStart+4
            if(cms.Status_5_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_5_Name__c, HasResponded=cms.Status_5_Responded__c, IsDefault = cms.Status_5_Default__c, SortOrder=7)); //SortOrder=sortOrderStart+5   
            if(cms.Status_6_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_6_Name__c, HasResponded=cms.Status_6_Responded__c, IsDefault = cms.Status_6_Default__c, SortOrder=8)); //SortOrder=sortOrderStart+6
            if(cms.Status_7_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_7_Name__c, HasResponded=cms.Status_7_Responded__c, IsDefault = cms.Status_7_Default__c, SortOrder=9)); //SortOrder=sortOrderStart+7           
            if(cms.Status_8_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_8_Name__c, HasResponded=cms.Status_8_Responded__c, IsDefault = cms.Status_8_Default__c, SortOrder=sortOrderStart+8));
            if(cms.Status_9_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_9_Name__c, HasResponded=cms.Status_9_Responded__c, IsDefault = cms.Status_9_Default__c, SortOrder=sortOrderStart+9));
            if(cms.Status_10_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_10_Name__c, HasResponded=cms.Status_10_Responded__c, IsDefault = cms.Status_10_Default__c, SortOrder=sortOrderStart+10));
            if(cms.Status_11_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_11_Name__c, HasResponded=cms.Status_11_Responded__c, IsDefault = cms.Status_11_Default__c, SortOrder=sortOrderStart+11));
            if(cms.Status_12_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_12_Name__c, HasResponded=cms.Status_12_Responded__c, IsDefault = cms.Status_12_Default__c, SortOrder=sortOrderStart+12));
            if(cms.Status_13_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_13_Name__c, HasResponded=cms.Status_13_Responded__c, IsDefault = cms.Status_13_Default__c, SortOrder=sortOrderStart+13));
            if(cms.Status_14_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_14_Name__c, HasResponded=cms.Status_14_Responded__c, IsDefault = cms.Status_14_Default__c, SortOrder=sortOrderStart+14));
            if(cms.Status_15_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_15_Name__c, HasResponded=cms.Status_15_Responded__c, IsDefault = cms.Status_15_Default__c, SortOrder=sortOrderStart+15));
            if(cms.Status_16_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_16_Name__c, HasResponded=cms.Status_16_Responded__c, IsDefault = cms.Status_16_Default__c, SortOrder=sortOrderStart+16));
            if(cms.Status_17_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_17_Name__c, HasResponded=cms.Status_17_Responded__c, IsDefault = cms.Status_17_Default__c, SortOrder=sortOrderStart+17));
            if(cms.Status_18_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_18_Name__c, HasResponded=cms.Status_18_Responded__c, IsDefault = cms.Status_18_Default__c, SortOrder=sortOrderStart+18));
            if(cms.Status_19_Name__c != null) cms2Insert.add(new CampaignMemberStatus(CampaignId=cm.Id, Label=cms.Status_19_Name__c, HasResponded=cms.Status_19_Responded__c, IsDefault = cms.Status_19_Default__c, SortOrder=sortOrderStart+19));
        }

        return cms2Insert;
    }
}