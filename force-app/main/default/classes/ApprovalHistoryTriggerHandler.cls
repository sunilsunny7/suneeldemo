/**
 * Created by kwn687 on 2023-01-30.
   LTAT-9851: Added account Name in all email templates sent out on Approval.
 */

public with sharing class ApprovalHistoryTriggerHandler extends TriggerHandler {
    private List<Approval_History__c> newApprovalHistories;
    public ApprovalHistoryTriggerHandler() {
        this.newApprovalHistories = (List<Approval_History__c>) Trigger.new;
    }
    public override void afterInsert() {
        emailNotification(newApprovalHistories);
    }
    public static void emailNotification(List<Approval_History__c> newList) {
        List<Id> opportunityIds = new List<Id>();
        List<Id> processIds = new List<Id>();
        for (Approval_History__c oneApporvalHistory : newList) {
            if (oneApporvalHistory.Status__c == 'Rejected' || oneApporvalHistory.Status__c == 'Approved') {
                opportunityIds.add(oneApporvalHistory.Opportunity__c);
                processIds.add(oneApporvalHistory.Process_Instance_Id__c);
            }
        }
        if (!opportunityIds.isEmpty()) {
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
                //LTAT-9851: Added Account.Name in SOQL Query
                [
                    SELECT id, Owner.email, Owner.name,  Account.Name,Cygate_Amount_for_Approval__c, Cygate_Margin_for_Approval__c, Approval_Type__c, name
                    FROM Opportunity
                    WHERE Id IN :opportunityIds
                ]
            );
            List<ProcessInstance> processes = [
                SELECT
                    Id,
                    TargetObjectId,
                    Status,
                    CreatedBy.Email,
                    (SELECT Id, Actor.email, Actor.name, OriginalActor.email FROM Steps WHERE StepStatus != 'Started')
                FROM ProcessInstance
                WHERE Id IN :processIds
                ORDER BY createdDate DESC
            ];
            Map<Id, Id> stepIdMap = new Map<Id, Id>();
            Map<Id, String> approverNameMap = new Map<Id, String>();
            Map<Id, String> stepStatusMap = new Map<Id, String>();
            Map<Id, Set<String>> emailSetMap = new Map<Id, Set<String>>();
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            for (ProcessInstance oneProcessInstance : processes) {
                if (emailSetMap.containsKey(oneProcessInstance.TargetObjectId) && opportunityMap.get(oneProcessInstance.TargetObjectId).owner.email != null) {
                    emailSetMap.get(oneProcessInstance.TargetObjectId).add(opportunityMap.get(oneProcessInstance.TargetObjectId).owner.email);
                } else if (opportunityMap.get(oneProcessInstance.TargetObjectId).owner.email != null) {
                    emailSetMap.put(oneProcessInstance.TargetObjectId, new Set<String>{ opportunityMap.get(oneProcessInstance.TargetObjectId).owner.email });
                }
                if (emailSetMap.containsKey(oneProcessInstance.TargetObjectId) && oneProcessInstance.CreatedBy.email != null) {
                    emailSetMap.get(oneProcessInstance.TargetObjectId).add(oneProcessInstance.CreatedBy.email);
                } else if (oneProcessInstance.CreatedBy.email != null) {
                    emailSetMap.put(oneProcessInstance.TargetObjectId, new Set<String>{ oneProcessInstance.CreatedBy.email });
                }
                for (ProcessInstanceStep oneStep : oneProcessInstance.Steps) {
                    if (emailSetMap.containsKey(oneProcessInstance.TargetObjectId) && oneStep.Actor.email != null) {
                        emailSetMap.get(oneProcessInstance.TargetObjectId).add(oneStep.Actor.email);
                    } else if (oneStep.Actor.email != null) {
                        emailSetMap.put(oneProcessInstance.TargetObjectId, new Set<String>{ oneStep.Actor.email });
                    }
                    if (emailSetMap.containsKey(oneProcessInstance.TargetObjectId) && oneStep.OriginalActor.email != null) {
                        emailSetMap.get(oneProcessInstance.TargetObjectId).add(oneStep.OriginalActor.email);
                    } else if (oneStep.OriginalActor.email != null) {
                        emailSetMap.put(oneProcessInstance.TargetObjectId, new Set<String>{ oneStep.OriginalActor.email });
                    }
                    if (
                        !stepIdMap.containsKey(oneProcessInstance.TargetObjectId) &&
                        !approverNameMap.containsKey(oneProcessInstance.TargetObjectId) &&
                        !stepStatusMap.containsKey(oneProcessInstance.TargetObjectId)
                    ) {
                        stepIdMap.put(oneProcessInstance.TargetObjectId, oneStep.Id);
                        approverNameMap.put(oneProcessInstance.TargetObjectId, oneStep.Actor.name);
                        stepStatusMap.put(oneProcessInstance.TargetObjectId, oneProcessInstance.status);
                    }
                }
            }
            for (Id opportunityId : opportunityMap.keySet()) {
                List<String> emails = new List<String>();
                emails.addAll(emailSetMap.get(opportunityId));
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emails);
                mail.setSenderDisplayName('Salesforce Support');
                mail.setSubject('Avslutad Godkännandebegäran för ' + opportunityMap.get(opportunityId).name);
                mail.setHtmlBody(
                    'Hej, ' +
                        '</br>' +
                        '<a href="' +
                        URL.getSalesforceBaseUrl().toExternalForm() +
                        '/' +
                        stepIdMap.get(opportunityId) +
                        '">' +
                        'Godkännandebegäran </a> för Affärsmöjligheten ' +
                        '<a href="' +
                        URL.getSalesforceBaseUrl().toExternalForm() +
                        '/' +
                        opportunityId +
                        '">' +
                        opportunityMap.get(opportunityId).name +
                    //LTAT-9851: Added logic to send Account Name in Email
                        '</a> på '                  		 
                          +
                    	'<a href="'+URL.getSalesforceBaseUrl().toExternalForm() + '/'+opportunityMap.get(opportunityId).Account.Id+'">'+
                          opportunityMap.get(opportunityId).Account.Name
                         +'</a> '+' har besvarats \'' +
                        stepStatusMap.get(opportunityId) +
                        '\' av ' +
                        approverNameMap.get(opportunityId) +
                        ' </br></br> Typ av Godkännande: : ' +
                        opportunityMap.get(opportunityId).Approval_Type__c +
                        ' </br> Cygate Avtalsvärde för Godkännande: ' +
                        opportunityMap.get(opportunityId).Cygate_Amount_for_Approval__c +
                        ' SEK' +
                        '</br> Cygate Margin för Godkännande: ' +
                        opportunityMap.get(opportunityId).Cygate_Margin_for_Approval__c +
                        ' %' +
                        '</br></br> Vänligen,' +
                        '</br> Salesforce Team'
                );
                
                allMails.add(mail);
            }
            for (Messaging.SingleEmailMessage oneEmail : allMails) {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ oneEmail });
            }
        }
    }
}