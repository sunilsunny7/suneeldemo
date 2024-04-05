/**
 * Created by wgj897 on 2023-10-23.
 */

public with sharing class TimeEntryTriggerHandler extends TriggerHandler {
    private List<Time_Entry__c> newList;
    private List<Time_Entry__c> oldList;
    private Map<Id , Time_Entry__c> oldMap;
    public TimeEntryTriggerHandler() {
        this.newList = (List<Time_Entry__c>) Trigger.new;
        this.oldList = (List<Time_Entry__c>) Trigger.old;
        this.oldMap = (Map<Id , Time_Entry__c>) Trigger.oldMap;
    }
    public override void beforeInsert() {
        assignBBToTimeEntry(newList);
    }
    public override void afterInsert() {
        updateBBTotalActualHours(newList , null);
        updateBBTotalHoursByAssignmentPhase(newList , null);
    }
    public override void afterUpdate() {
        updateBBTotalActualHours(newList , oldMap);
        updateBBTotalHoursByAssignmentPhase(newList , oldMap);
    }
    public override void afterDelete() {
        updateBBTotalActualHours(oldList , oldMap);
        updateBBTotalHoursByAssignmentPhase(oldList , oldMap);
    }
    public static void assignBBToTimeEntry(List<Time_Entry__c> newList) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id , Id> mapOppsIdsWithBBsIds = new Map<Id , Id>();

        for (Time_Entry__c timeEntry : newList) {
            oppIds.add(timeEntry.Opportunity__c);
        }
        List<Opportunity> opps = [SELECT Id , (SELECT Id FROM Business_Boards__r ORDER BY CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Id IN :oppIds];

        for (Opportunity opp : opps) {
            if (opp.Business_Boards__r.size() > 0) {
                mapOppsIdsWithBBsIds.put(opp.Id , opp.Business_Boards__r.get(0).Id);
            }
        }
        if (!mapOppsIdsWithBBsIds.keySet().isEmpty()) {
            for (Time_Entry__c timeEntry : newList) {
                if (mapOppsIdsWithBBsIds.containsKey(timeEntry.Opportunity__c) && timeEntry.Business_Board__c == null) {
                    timeEntry.Business_Board__c = mapOppsIdsWithBBsIds.get(timeEntry.Opportunity__c);
                }
            }
        }
    }
    public static void updateBBTotalActualHours(List<Time_Entry__c> newList , Map<Id , Time_Entry__c> oldMap) {

        Set<Id> businessBoardIds = new Set<Id>();
        if (newList != null) {
            for (Time_Entry__c timeEntry : newList) {
                if (timeEntry.Business_Board__c != null && (oldMap == null ||
                        timeEntry.Actual_hours__c != oldMap.get(timeEntry.Id).Actual_hours__c ||
                        timeEntry.Business_Board__c != oldMap.get(timeEntry.Id).Business_Board__c || Trigger.isDelete)) {
                    businessBoardIds.add(timeEntry.Business_Board__c);
                }
            }
        }

        List<Business_Board__c> bbUpdateTotalActualHours = [SELECT Id , Total_Actual_Hours__c, (SELECT Id , Actual_Hours__c FROM Time_Entries__r) FROM Business_Board__c WHERE Id IN :businessBoardIds];

        if (!bbUpdateTotalActualHours.isEmpty()) {
            for (Business_Board__c businessBoard : bbUpdateTotalActualHours) {
                businessBoard.Total_Actual_Hours__c = 0;
                for (Time_Entry__c timeEntry : businessBoard.Time_Entries__r) {
                    businessBoard.Total_Actual_Hours__c = businessBoard.Total_Actual_Hours__c + timeEntry.Actual_hours__c;
                }
            }
        }
        try {
            update bbUpdateTotalActualHours;
        } catch (Exception ex) {
            SEUtility.errorLogging('Error' , 'TimeEntryTriggerHandler' , 'updateBBTotalActualHours' , ex);
        }
    }
    public static void updateBBTotalHoursByAssignmentPhase(List<Time_Entry__c> newList , Map<Id , Time_Entry__c> oldMap) {

        Set<Id> bbWithTimeEntries = new Set<Id>();
        if (newList != null) {
            for (Time_Entry__c timeEntry : newList) {
                if (timeEntry.Business_Board__c != null &&
                        (oldMap == null || timeEntry.Assignment_Phase__c != oldMap.get(timeEntry.Id).Assignment_Phase__c ||
                        timeEntry.Actual_hours__c != oldMap.get(timeEntry.Id).Actual_hours__c) || Trigger.isDelete) {
                    bbWithTimeEntries.add(timeEntry.Business_Board__c);
                }
            }
        }
        List<Business_Board__c> bbUpdateTotalHours = [SELECT Id , Total_Hours_before_BB1__c , Total_Hours_after_BB2__c , Total_Hours_between_BB1_BB2__c , Total_Hours_after_the_deal__c , (SELECT Id , Actual_Hours__c, Assignment_Phase__c FROM Time_Entries__r) FROM Business_Board__c WHERE Id IN :bbWithTimeEntries];
        if (!bbUpdateTotalHours.isEmpty()) {
            for (Business_Board__c businessBoard : bbUpdateTotalHours) {
                businessBoard.Total_Hours_before_BB1__c = 0;
                businessBoard.Total_Hours_after_BB2__c = 0;
                businessBoard.Total_Hours_between_BB1_BB2__c = 0;
                businessBoard.Total_Hours_after_the_deal__c = 0;

                for (Time_Entry__c timeEntry : businessBoard.Time_Entries__r) {
                    switch on timeEntry.Assignment_Phase__c {
                        when 'Before BB1' {
                            businessBoard.Total_Hours_before_BB1__c = businessBoard.Total_Hours_before_BB1__c + timeEntry.Actual_hours__c;
                        }
                        when 'After BB2' {
                            businessBoard.Total_Hours_after_BB2__c = businessBoard.Total_Hours_after_BB2__c + timeEntry.Actual_hours__c;
                        }
                        when 'Between BB1 & BB2' {
                            businessBoard.Total_Hours_between_BB1_BB2__c = businessBoard.Total_Hours_between_BB1_BB2__c + timeEntry.Actual_hours__c;
                        }
                        when 'After the deal' {
                            businessBoard.Total_Hours_after_the_deal__c = businessBoard.Total_Hours_after_the_deal__c + timeEntry.Actual_hours__c;
                        }
                        when else {
                        }
                    }
                }
            }
        }
        try {
            update bbUpdateTotalHours;
        } catch (Exception ex) {
            SEUtility.errorLogging('Error' , 'TimeEntryTriggerHandler' , 'updateBBTotalHoursByAssignmentPhase' , ex);
        }
    }
}