/**
About
-----
Description: AutoDirectController for the Auto Direct Action for both Lightning and Classic.
Create date: 31.10.2016

Update History
--------------
Created Dev 2016 - V.M

Issues / TODOs
--------------
*/
global class AutoDirectController {
    private static Boolean HasError { get; set; }
    private static List<String> ErrorMsgs { get; set; }

    public class ActionStatus {
        public List<String> ErrorMessages { get; set; }
        public Boolean IsSuccess { get; set; }
    }
    webservice static String webProcess(String leadId) {
        return processRecord(leadId);
    }
    @AuraEnabled
    public static String getResult(String leadId) {
        return processRecord(leadId);
    }
    private static String processRecord(String leadIds) {
        List<String> lstLeadIds = (leadIds.replaceAll('"', '')).split(',');
        List<Lead> leads = [SELECT Id, LeadSource, Account__c, Account__r.Owner.Name, Account__r.OwnerId, Account__r.Cygate_Account_Manager__c, Account__r.Business_Unit__c, RecordTypeId FROM Lead WHERE Id IN :lstLeadIds];
        ErrorMsgs = new List<String>();
        General_Lead_Settings__c settings = General_Lead_Settings__c.getValues('General Settings');
        validateLead(leads, settings);
        assignLead(leads, settings);
        if (!HasError) {
            try {
                update leads;
            } catch (System.DmlException e) {
                HasError = True;
                ErrorMsgs.add(e.getDmlMessage(0));
            }
        }
        ActionStatus actionStatus = new ActionStatus();
        If (HasError) {
            actionStatus.IsSuccess = False;
            actionStatus.ErrorMessages = ErrorMsgs;
        } else {
            actionStatus.IsSuccess = True;
        }
        return JSON.serialize(actionStatus);
    }
    private static Boolean validateLead(List<Lead> leads, General_Lead_Settings__c settings) {
        HasError = False;
        For(Lead oneLead : leads) {
            if (oneLead.Account__c == null) {
                HasError = true;
                ErrorMsgs.add(Label.AD_Account_Missing);
            }
            if (oneLead.Account__r.OwnerId == settings.AD_Integration_User_ID__c && oneLead.LeadSource != LeadTriggerHandler.LEAD_SOURCE_RESELLER) {
                HasError = true;
                ErrorMsgs.add(Label.AD_Account_Owner_Missing);
            }
        }
        return HasError;
    }
    private static void assignLead(List<Lead> leads, General_Lead_Settings__c settings) {
        String directedTo;
        For(Lead oneLead : leads) {
            Set<String> tamBU = new Set<String>(settings.AD_TAM_BU__c.trim().split(';'));
            if (oneLead.Account__r.OwnerId == settings.AD_Integration_User_ID__c && tamBU.contains(oneLead.Account__r.Business_Unit__c) && oneLead.LeadSource == LeadTriggerHandler.LEAD_SOURCE_RESELLER) {
                //Assign to TAM Queue
                oneLead.Status = LeadTriggerHandler.LEAD_STATUS_QUALIFY;
                oneLead.OwnerId = settings.AD_TAM_ID__c;
            } else if (oneLead.Account__r.OwnerId != settings.AD_Integration_User_ID__c && oneLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Telia Lead').getRecordTypeId()) {
                //Assign to Account Owner
                oneLead.OwnerId = oneLead.Account__r.OwnerId;
                directedTo = oneLead.Account__r.Owner.Name;
                oneLead.Status = LeadTriggerHandler.LEAD_STATUS_QUALIFY;
            } else if (oneLead.Account__r.OwnerId != settings.AD_Integration_User_ID__c && oneLead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Cygate Lead').getRecordTypeId()) {
                //Assign to Account Owner
                oneLead.OwnerId = oneLead.Account__r.Cygate_Account_Manager__c;
                directedTo = oneLead.Account__r.Cygate_Account_Manager__c;
                oneLead.Status = LeadTriggerHandler.LEAD_STATUS_QUALIFY;
            } else {
                HasError = true;
                ErrorMsgs.add(Label.AD_Cant_Route);
            }
        }
    }
}