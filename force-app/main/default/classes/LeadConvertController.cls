/**
About
-----
Description: LeadConvertController

Update History
--------------
Created 2017-08-22 12:38 Vahraz Mostajir - Used for LeadConvertComponent
Updated by S.K : FIBE -794 : Included a new methods 'convertFiberLead' and 'transferLeadValues' to map new fields related to Fiber when converting a Fiber lead.
Issues / TODOs
--------------     
*/


public class LeadConvertController {
    public class ActionStatus {
        public String ErrorMessage { get; set; }
        public Database.LeadConvertResult ReturnData { get; set; }
        public Boolean IsSuccess { get; set; }
    }

    public static final String FIBER_BASE_PROFILE = 'Fiber Base Profile';

    @AuraEnabled
    public static String convertLead(Id leadId, String accId, String oppName, String buyInterestId, String recordType, String contactId, Boolean overwrite) {

        ActionStatus actionStatus = new ActionStatus();
        Lead lead = [SELECT Id,Description, FirstName, LastName, Email, Title, Phone, MobilePhone FROM Lead WHERE Id = :leadId];
        lead.Lead_Convert__c = True;
        lead.Lead_Conversion_Time__c = DateTime.now();

        if (!String.isEmpty(buyInterestId)) {
            lead.CA_Buy_Interest__c = buyInterestId;
        }
        try {
            update lead;
        } catch (Dmlexception dex) {
            actionStatus.IsSuccess = false;
            actionStatus.ErrorMessage = dex.getMessage();
        }

        Database.LeadConvert lc = new Database.LeadConvert();

        lc.setConvertedStatus('Konverterat');
        lc.setLeadId(leadId);


        //If duplicate contact has been selected
        if (!String.isEmpty(contactId)) {
            Contact con = [SELECT Id, AccountId, FirstName, LastName, Email, Title, Phone, MobilePhone FROM Contact WHERE Id = :contactId LIMIT 1];
            List<AccountContactRelation> acrList = [SELECT AccountId, ContactId FROM AccountContactRelation WHERE ContactId = :contactId AND AccountId = :accId LIMIT 1];
            if (acrList.size() == 0) {
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = accId;
                acr.ContactId = con.Id;
                acrList.add(acr);
                try {
                    insert acrList[0];
                    System.Debug('inserted acr succesfully');
                } catch (Dmlexception dex) {
                    actionStatus.IsSuccess = false;
                    actionStatus.ErrorMessage = dex.getMessage();
                    return JSON.serialize(actionStatus);
                }
            }

            //If overwrite option was checked
            if (overwrite) {
                con.FirstName = lead.FirstName;
                con.LastName = lead.LastName;
                con.Title = lead.Title;
                con.Phone = lead.Phone;
                con.MobilePhone = lead.MobilePhone;
            }

            try {
                //Update the contact
                update con;
            } catch (Dmlexception dex) {
                actionStatus.IsSuccess = false;
                actionStatus.ErrorMessage = dex.getMessage();
                return JSON.serialize(actionStatus);
            }

            lc.setContactId(con.Id);
            lc.setAccountId(con.AccountId);
        } else {
            //If there was no duplicate contact, we just set the accId and a new contact will be created
            lc.setAccountId(accId);
        }

        if (!String.isEmpty(oppName)) {
            lc.setOpportunityName(oppName);
        } else {
            lc.setDoNotCreateOpportunity(true);
        }
        lc.setOwnerId(UserInfo.getUserId());

        try {
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            if (lcr.getOpportunityId() != null) {
                Opportunity Opp = new Opportunity (Id = lcr.getOpportunityId());
                Opp.Description = lead.Description;
                opp.Contact__c = lcr.getContactId();
                Update opp;
            }
            actionStatus.IsSuccess = lcr.isSuccess();
            actionStatus.ReturnData = lcr;
        } catch (exception dex) {
            actionStatus.IsSuccess = false;
            actionStatus.ErrorMessage = dex.getMessage();
            return JSON.serialize(actionStatus);
        }

        return JSON.serialize(actionStatus);
    }

    @AuraEnabled
    public static Lead getLead(String leadId) {
        Lead lead = [SELECT Id, Name, Account__c, Account__r.Name, Email FROM Lead WHERE Id = :leadId LIMIT 1];
        return lead;
    }

    @AuraEnabled
    public static List<Contact> getDuplicateContacts(String email) {
        List<Contact> contacts = [SELECT Id, Name, Email, Account.Name FROM Contact WHERE Email = :email];
        return contacts;
    }

    @AuraEnabled
    public static List<Buy_Interest__c> getBuyInterests(String leadId) {
        List<Buy_Interest__c> biList = [SELECT Id, Name, Lead_Source__c, CreatedDate, Buy_Interest_Submitter_Name__c FROM Buy_Interest__c WHERE Lead__c = :leadId AND Lead_Source__c = :LeadTriggerHandler.LEAD_SOURCE_RESELLER ORDER BY CreatedDate];
        return biList;
    }

    @AuraEnabled
    public static List<String> getOpportunityRecordTypes() {
        List<String> availableRecordTypes =
                SEUtility.GetAvailableRecordTypeNamesForSObject(Opportunity.SObjectType);
        return availableRecordTypes;
    }


    // Updated by S.K - For Real Estate Fiber : To include new fields rlatede to Fiber to be mapped to opportunity
    @AuraEnabled
    public static Boolean isFiberProfile() {

        // Get current user profile Name and return true if its Fiber profile
        String profileName = [Select Id,Name from Profile where Id = :Userinfo.getProfileId()].Name;
        if (profileName == FIBER_BASE_PROFILE) {
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static String convertFiberLead(Id leadId, String accId, String oppName, String buyInterestId, String recordType, String contactId, Boolean overwrite) {
        ActionStatus actionStatus = new ActionStatus();
        Lead lead = [SELECT Id,Description, FirstName, LastName, Email, Title, Phone, MobilePhone FROM Lead WHERE Id = :leadId];
        lead.Lead_Convert__c = True;
        lead.Lead_Conversion_Time__c = DateTime.now();

        if (!String.isEmpty(buyInterestId)) {
            lead.CA_Buy_Interest__c = buyInterestId;
        }
        try {
            update lead;
        } catch (Dmlexception dex) {
            actionStatus.IsSuccess = false;
            actionStatus.ErrorMessage = dex.getMessage();
        }

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setConvertedStatus('Konverterat');
        lc.setLeadId(leadId);


        //If duplicate contact has been selected
        if (!String.isEmpty(contactId)) {
            Contact con = [SELECT Id, AccountId, FirstName, LastName, Email, Title, Phone, MobilePhone FROM Contact WHERE Id = :contactId LIMIT 1];
            List<AccountContactRelation> acrList = [SELECT AccountId, ContactId FROM AccountContactRelation WHERE ContactId = :contactId AND AccountId = :accId LIMIT 1];
            if (acrList.size() == 0) {
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = accId;
                acr.ContactId = con.Id;
                acrList.add(acr);
                try {
                    insert acrList[0];
                } catch (Dmlexception dex) {
                    actionStatus.IsSuccess = false;
                    actionStatus.ErrorMessage = dex.getMessage();
                    return JSON.serialize(actionStatus);
                }
            }

            //If overwrite option was checked
            if (overwrite) {
                con.FirstName = lead.FirstName;
                con.LastName = lead.LastName;
                con.Title = lead.Title;
                con.Phone = lead.Phone;
                con.MobilePhone = lead.MobilePhone;
            }

            try {
                //Update the contact
                update con;
            } catch (Dmlexception dex) {
                actionStatus.IsSuccess = false;
                actionStatus.ErrorMessage = dex.getMessage();
                return JSON.serialize(actionStatus);
            }

            lc.setContactId(con.Id);
            lc.setAccountId(con.AccountId);
        } else {
            //If there was no duplicate contact, we just set the accId and a new contact will be created
            lc.setAccountId(accId);
        }

        if (!String.isEmpty(oppName)) {

            lc.setOpportunityName(oppName);
        } else {
            lc.setDoNotCreateOpportunity(true);
        }
        lc.setOwnerId(UserInfo.getUserId());

        try {
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            Opportunity opp = new Opportunity (Id = lcr.getOpportunityId());
            opp.Description = lead.description;
            opp.Contact__c = lcr.getContactId();
            database.update (opp);
            // Map new field for Fiber leads

            List<ID> leadIds = New List<Id>();
            leadIds.add(+lcr.getLeadId());

            transferLeadValues(leadIds);

            actionStatus.IsSuccess = lcr.isSuccess();
            actionStatus.ReturnData = lcr;
        } catch (exception dex) {
            actionStatus.IsSuccess = false;
            actionStatus.ErrorMessage = dex.getMessage();
            return JSON.serialize(actionStatus);
        }

        return JSON.serialize(actionStatus);

    }


    @AuraEnabled
    public static void transferLeadValues(List<ID> convertedLeadIds) {
        List<Lead> convertedLeadsList = [Select id,ConvertedOpportunityId,IsConverted,Fastighetsbeteckning__c,Installationsort__c,Installation_address__c,Zip_Code__c, Municipality__c from lead where Id IN :convertedLeadIds];
        List<Buy_Interest__c> relatedBuyInterests = [Select id,Number_of_Facilities__c,Number_of_Ports__c,Lead__c,Lead__r.id,Number_of_Premises__c,Number_of_Households__c from Buy_Interest__c where Lead__c IN :convertedLeadsList];
        List<Opportunity> opptyTobeUpdated = new List<Opportunity> ();
        Decimal Number_of_Ports = 0;
        Decimal Number_of_Facilities = 0;
        Decimal Number_of_Premises = 0;
        Decimal Number_of_Households = 0;

        for (Buy_Interest__c interestRec : relatedBuyInterests) {
            if (convertedLeadIds.contains(interestRec.Lead__c)) {
                Number_of_Ports += interestRec.Number_of_Ports__c != null ? interestRec.Number_of_Ports__c : 0;
                Number_of_Facilities += interestRec.Number_of_Facilities__c != null ? interestRec.Number_of_Facilities__c : 0;
                Number_of_Premises += interestRec.Number_of_Premises__c != null ? interestRec.Number_of_Premises__c : 0;
                Number_of_Households += interestRec.Number_of_Households__c != null ? interestRec.Number_of_Households__c : 0;
            }
        }

        for (Lead leadRec : convertedLeadsList) {
            if (leadRec.Isconverted && leadRec.ConvertedOpportunityId != null) {
                opptyTobeUpdated.add(New Opportunity(id = leadRec.ConvertedOpportunityId, Property__c = leadRec.Fastighetsbeteckning__c, Installation_City__c = leadRec.Installationsort__c, Installation_address__c = leadRec.Installation_address__c, Zip_Code__c = leadRec.Zip_Code__c, Number_of_Facilities__c = Number_of_Facilities, Number_of_Ports__c = Number_of_Ports, Number_of_Premises__c = Number_of_Premises, Number_of_Households__c = Number_of_Households, Municipality__c = leadRec.Municipality__c));
            }
        }
        Update opptyTobeUpdated;


    }
}