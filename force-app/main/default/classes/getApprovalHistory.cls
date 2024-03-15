/**
 * Created by kwn687 on 11/28/2022.
 * LTAT-7618: Cygate - Change Approval report
 */

public with sharing class getApprovalHistory {
    @InvocableMethod(Label='Get Approval History' Description='Returns the list of Approval Histories that need to be saved')
    public static void execute(List<Opportunity> inputCollection) {
        Map<Id, Opportunity> allOpportunityMap = new Map<Id, Opportunity>();
        for (Opportunity oneOpp : inputCollection) {
            allOpportunityMap.put(oneOpp.Id, oneOpp);
        }
        Map<String, Approval_History__c> approvalHistoriesMap = new Map<String, Approval_History__c>();
        List<Approval_History__c> approvalHistories = [
            SELECT
                Id,
                Comment__c,
                Elapsed_Time_in_Days__c,
                Elapsed_Time_in_Hours__c,
                Elapsed_Time_in_Minutes__c,
                Opportunity__c,
                Process_Instance_Id__c,
                Process_Instance_Step_ID__c,
                Status__c
            FROM Approval_History__c
            WHERE Opportunity__c IN :allOpportunityMap.keySet()
        ];
        for (Approval_History__c approvalHistory : approvalHistories) {
            approvalHistoriesMap.put(approvalHistory.Process_Instance_Step_ID__c, approvalHistory);
        }
        //LTAT-7618 Added ActorId, OriginalActorId, SystemModstamp in query and ordered them in order to get the First Submitter.
        List<ProcessInstance> processes = [
            SELECT Id, TargetObjectId, (SELECT Id, StepStatus, Comments, ElapsedTimeInDays, ElapsedTimeInHours, ElapsedTimeInMinutes, ActorId, OriginalActorId, SystemModstamp  FROM Steps order by Createddate asc)
            FROM ProcessInstance
            WHERE TargetObjectId IN :allOpportunityMap.keySet() order by Completeddate asc
        ];
        List<Approval_History__c> approvalHistoryUpsertList = new List<Approval_History__c>();
        for (ProcessInstance oneProcessInstance : processes) {
            	Id currentProcessInstance = null;
           		Id submitterId=null;
                
            for (ProcessInstanceStep oneProcessInstanceStep : oneProcessInstance.Steps) {
                
                if (!approvalHistoriesMap.containsKey(oneProcessInstanceStep.Id)) {
                    //LTAT-7618: Changed/Added the logic to populate Date_of_approval__c & Submitter__c 
                    Date approvedDate=null ;
                    if(oneProcessInstanceStep.StepStatus =='Started' && currentProcessInstance!= oneProcessInstanceStep.Id )
                    {
                        currentProcessInstance = oneProcessInstance.Id;
                        submitterId =  oneProcessInstanceStep.ActorId;
                    }
                        
                    if(oneProcessInstanceStep.StepStatus == 'Approved')
                    {
                        Datetime originalModStamp = oneProcessInstanceStep.SystemModstamp;
                      	 approvedDate = Date.newInstance(originalModStamp.year(), originalModStamp.month(), originalModStamp.day());
                    }
							                    
                    Approval_History__c newApprovalHistory = new Approval_History__c(
                        Comment__c = oneProcessInstanceStep.Comments,
                        Elapsed_Time_in_Days__c = oneProcessInstanceStep.ElapsedTimeInDays,
                        Elapsed_Time_in_Hours__c = oneProcessInstanceStep.ElapsedTimeInHours,
                        Elapsed_Time_in_Minutes__c = oneProcessInstanceStep.ElapsedTimeInMinutes,
                        Opportunity__c = oneProcessInstance.TargetObjectId,
                        Process_Instance_Id__c = oneProcessInstance.Id,
                        Process_Instance_Step_ID__c = oneProcessInstanceStep.Id,
                        Status__c = oneProcessInstanceStep.StepStatus,
                        Cygate_Amount_for_Approval__c = allOpportunityMap.get(oneProcessInstance.TargetObjectId).Cygate_Amount_for_Approval__c,
                        Cygate_Margin_for_Approval__c = allOpportunityMap.get(oneProcessInstance.TargetObjectId).Cygate_Margin_for_Approval__c,
                        Approval_Type__c = allOpportunityMap.get(oneProcessInstance.TargetObjectId).Approval_Type__c,
                        //LTAT-7618: Populating Actual_approver__c, Original_approver__c, Submitter__c, Date_of_approval__c in approval history
                        Actual_approver__c = oneProcessInstanceStep.ActorId,
                        Original_approver__c = 	oneProcessInstanceStep.OriginalActorId,                        
                        Submitter__c =submitterId,
                        Date_of_approval__c	=approvedDate
                        
                        
                    );
                    approvalHistoryUpsertList.add(newApprovalHistory);
                } else if (
                    approvalHistoriesMap.containsKey(oneProcessInstanceStep.Id) &&
                    approvalHistoriesMap.get(oneProcessInstanceStep.Id).Status__c != oneProcessInstanceStep.StepStatus
                ) {
                    Approval_History__c newApprovalHistory = new Approval_History__c(
                        Id = approvalHistoriesMap.get(oneProcessInstanceStep.Id).Id,
                        Status__c = oneProcessInstanceStep.StepStatus
                    );
                    approvalHistoryUpsertList.add(newApprovalHistory);
                }
            }
        }
        if (!approvalHistoryUpsertList.isEmpty()) {
            upsert approvalHistoryUpsertList;
        }
    }
    public class Requests {
        @InvocableVariable(Label='Opportunity list' Description='List of opportunities that need Approval History Tracking' Required=true)
        public List<Opportunity> inputCollection;
    }
}