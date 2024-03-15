public with sharing class ApprovalInformationController {
    public class wrapper {
        @AuraEnabled
        public String opportunityName { get; set; }
        @AuraEnabled
        public String opportunityOwnerName { get; set; }
        @AuraEnabled
        public Decimal cygateAmountForApproval { get; set; }
        @AuraEnabled
        public Decimal cygateMarginForApproval { get; set; }
        @AuraEnabled
        public String opportunityLink { get; set; }
        @AuraEnabled
        public String opportunityOwnerLink { get; set; }
        //LTAT-9851: Added accountName & Accountlink to display on approval page
        @AuraEnabled
        public String accountName { get; set; }
        @AuraEnabled
        public String accountLink { get; set; }
    }
    @AuraEnabled(cacheable=true)
    public static ApprovalInformationController.wrapper getRecordData(Id recordId, String objectApiName) {
        Approval_History__c approvedData = new Approval_History__c();
        Opportunity opportunityData = new Opportunity();
        Id opportunityId;
        try {
            approvedData = [
                SELECT
                    Id,
                    Cygate_Amount_for_Approval__c,
                    Cygate_Margin_for_Approval__c,
                    Opportunity__r.Name,
                    Opportunity__r.Owner.name,
                    Opportunity__r.Id,
                    Opportunity__r.OwnerId,
                //LTAT-9851 Added Account name to display on approval page
                    Opportunity__r.Account.Name
                FROM Approval_History__c
                WHERE Process_Instance_Step_ID__c = :recordId
                LIMIT 1
            ];
        } catch (Exception ex) {
        }

        if (approvedData != null && approvedData.Cygate_Amount_for_Approval__c != null && approvedData.Cygate_Margin_for_Approval__c != null) {
            ApprovalInformationController.wrapper newWrapper = new ApprovalInformationController.wrapper();
            newWrapper.opportunityName = approvedData.Opportunity__r.Name;
            newWrapper.opportunityOwnerName = approvedData.Opportunity__r.Owner.name;
            newWrapper.cygateAmountForApproval = approvedData.Cygate_Amount_for_Approval__c;
            newWrapper.cygateMarginForApproval = approvedData.Cygate_Margin_for_Approval__c;
            newWrapper.opportunityLink = '/lightning/r/' + approvedData.Opportunity__r.Id + '/view';
            newWrapper.opportunityOwnerLink = '/lightning/r/' + approvedData.Opportunity__r.OwnerId + '/view';
            ////LTAT-9851: Added accountName & Accountlink to display on approval page
            newWrapper.accountName = approvedData.Opportunity__r.Account.Name;
            newWrapper.accountLink = '/lightning/r/' + approvedData.Opportunity__r.AccountId + '/view';
            return newWrapper;
        } else {
            if (objectApiName == 'ProcessInstanceStep') {
                opportunityId = [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE Id = :recordId LIMIT 1].ProcessInstance.TargetObjectId;
            } else if (objectApiName == 'ProcessInstanceWorkitem') {
                opportunityId = [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE Id = :recordId LIMIT 1]
                .ProcessInstance.TargetObjectId;
            }
            //LTAT-9851: Added accountName display on approval page
            opportunityData = [
                SELECT Id, Cygate_Amount_for_Approval__c, Cygate_Margin_for_Approval__c, Name, Owner.name, OwnerId, Account.Name
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
            ];
            ApprovalInformationController.wrapper newWrapper = new ApprovalInformationController.wrapper();
            newWrapper.opportunityName = opportunityData.Name;
            newWrapper.opportunityOwnerName = opportunityData.Owner.name;
            newWrapper.cygateAmountForApproval = opportunityData.Cygate_Amount_for_Approval__c;
            newWrapper.cygateMarginForApproval = opportunityData.Cygate_Margin_for_Approval__c;
            newWrapper.opportunityLink = '/lightning/r/' + opportunityData.Id + '/view';
            newWrapper.opportunityOwnerLink = '/lightning/r/' + opportunityData.OwnerId + '/view';
            ////LTAT-9851: Added accountName & Accountlink to display on approval page
            newWrapper.accountName = opportunityData.Account.Name;
            newWrapper.accountLink = '/lightning/r/' + approvedData.Opportunity__r.AccountId + '/view';
            return newWrapper;
        }
    }
}