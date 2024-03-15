/**
 * Created by kwn687 on 2023-04-18.
 */
public with sharing class RelatedDocumentsTriggerHandler extends TriggerHandler {
    private List<Related_Documents__c> newRelatedDocuments;
    private Map<Id, Related_Documents__c> oldRelatedDocumentsMap;
    public RelatedDocumentsTriggerHandler() {
        this.newRelatedDocuments = (List<Related_Documents__c>) Trigger.new;
        this.oldRelatedDocumentsMap = (Map<Id, Related_Documents__c>) Trigger.oldMap;
    }
    public override void beforeInsert() {
        copyDataFromOpportunity(newRelatedDocuments, null);
        validateSentToCustomer(newRelatedDocuments);
    }
    public override void beforeUpdate() {
        copyDataFromOpportunity(newRelatedDocuments, oldRelatedDocumentsMap);
        validateSentToCustomer(newRelatedDocuments);
    }
    public static void validateSentToCustomer(List<Related_Documents__c> newList) {
        Set<Id> opportunityIds = new Set<Id>();

        for (Related_Documents__c oneRelatedDocument : newList) {
            if (opportunityIds.contains(oneRelatedDocument.Opportunity__c) && oneRelatedDocument.Sent_to_Customer__c == true) {
                oneRelatedDocument.Sent_to_Customer__c.addError(System.Label.Relaterat_dokument_Sent_to_Customer_error);
            } else if (oneRelatedDocument.Sent_to_Customer__c == true) {
                opportunityIds.add(oneRelatedDocument.Opportunity__c);
            }
        }
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
            [
                SELECT id
                FROM Opportunity
                WHERE Id IN (SELECT Opportunity__c FROM Related_Documents__c WHERE Sent_to_Customer__c = TRUE) AND Id IN :opportunityIds
            ]
        );
        for (Related_Documents__c oneRelatedDocument : newList) {
            if (opportunityMap.containskey(oneRelatedDocument.Opportunity__c) && oneRelatedDocument.Sent_to_Customer__c == true) {
                oneRelatedDocument.Sent_to_Customer__c.addError(System.Label.Relaterat_dokument_Sent_to_Customer_error);
            }
        }
    }
    public static void copyDataFromOpportunity(List<Related_Documents__c> newList, Map<Id, Related_Documents__c> oldMap) {
        Set<Id> opportunityIDs = new Set<Id>();
        for (Related_Documents__c oneRelatedDocument : newList) {
            if (
                (oldMap == null || (oldMap != null && oldMap.get(oneRelatedDocument.Id).Opportunity__c != oneRelatedDocument.Opportunity__c)) &&
                oneRelatedDocument.Opportunity__c != null
            ) {
                opportunityIDs.add(oneRelatedDocument.Opportunity__c);
            }
        }
        if (!opportunityIDs.isEmpty()) {
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
                [
                    SELECT
                        id,
                        Cygate_Account_Manager__c,
                        Account.Cygate_Account_Manager__r.Email,
                        Account.Cygate_Account_Manager__r.MobilePhone,
                        Account.Cygate_Account_Manager__r.Phone,
                        Owner.FirstName,
                        Owner.LastName,
                        OrganisationalUnit__r.Order_Account_Id__c,
                        Name,
                        Opportunity_id__c
                    FROM Opportunity
                    WHERE Id IN :opportunityIDs
                ]
            );
            for (Related_Documents__c oneRelatedDocument : newList) {
                if (oneRelatedDocument.Opportunity__c != null) {
                    oneRelatedDocument.Conga_Cygate_Account_Manager_Name__c = opportunityMap.get(oneRelatedDocument.Opportunity__c).Cygate_Account_Manager__c;
                    oneRelatedDocument.Conga_Cygate_Account_Manager_Email__c = opportunityMap.get(oneRelatedDocument.Opportunity__c)
                        .Account.Cygate_Account_Manager__r.Email;
                    oneRelatedDocument.Conga_Cygate_Account_Manager_Mobile__c = opportunityMap.get(oneRelatedDocument.Opportunity__c)
                        .Account.Cygate_Account_Manager__r.MobilePhone;
                    oneRelatedDocument.Conga_Cygate_Account_Manager_Phone__c = opportunityMap.get(oneRelatedDocument.Opportunity__c)
                        .Account.Cygate_Account_Manager__r.Phone;
                    oneRelatedDocument.Conga_Opportunity_Owner_Name__c =
                        opportunityMap.get(oneRelatedDocument.Opportunity__c).Owner.FirstName +
                        ' ' +
                        opportunityMap.get(oneRelatedDocument.Opportunity__c).Owner.LastName;
                    oneRelatedDocument.Conga_Opp_Account__c = opportunityMap.get(oneRelatedDocument.Opportunity__c).OrganisationalUnit__r.Order_Account_Id__c;
                    oneRelatedDocument.Opportunity_Name__c = opportunityMap.get(oneRelatedDocument.Opportunity__c).Name;
                    oneRelatedDocument.Opportunity_no__c = opportunityMap.get(oneRelatedDocument.Opportunity__c).Opportunity_id__c;
                }
            }
        }
    }
}