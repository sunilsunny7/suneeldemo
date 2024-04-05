/**
 * Created by wgj897 on 2023-10-25.
 */
@IsTest
public with sharing class TimeEntryTriggerHandler_Test {
    @TestSetup
    public static  void initialTestData() {
        User byPassUser = Test_DataFactory.getByPassUser();
        System.runAs(byPassUser) {
            Account newAccount = Test_DataFactory.createOneAccount();
            insert newAccount;
            Opportunity opportunityWithBB = Test_DataFactory.createOpportunity();
            opportunityWithBB.Name = 'Opportunity with BB';
            insert opportunityWithBB;
            Opportunity opportunityNoBB = Test_DataFactory.createOpportunity();
            opportunityNoBB.Name = 'Opportunity without BB';
            insert opportunityNoBB;
            Business_Board__c businessBoard = new Business_Board__c(Opportunity__c = opportunityWithBB.Id);
            insert businessBoard;
            Time_Entry__c timeEntry = new Time_Entry__c(Resource__c = UserInfo.getUserId() , Resource_Team__c = 'Business Design' , Actual_hours__c = 5 , Opportunity__c = opportunityWithBB.Id);
            insert timeEntry;
        }
    }
    @IsTest
    public static void timeEntryForOppWithBB() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity with BB'];
        Time_Entry__c timeEntry = new Time_Entry__c(Resource__c = UserInfo.getUserId() , Resource_Team__c = 'Business Design' , Actual_hours__c = 5 , Opportunity__c = opportunity.Id);
        Test.startTest();
        insert timeEntry;
        Test.stopTest();
        Assert.areEqual([SELECT Id FROM Business_Board__c LIMIT 1].Id, [SELECT Id, Business_Board__c FROM Time_Entry__c LIMIT 1].Business_Board__c, 'Business Board is not assigned');
    }
    @IsTest
    public static void timeEntryForOppWithoutBB() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity without BB'];
        Time_Entry__c timeEntry = new Time_Entry__c(Resource__c = UserInfo.getUserId() , Resource_Team__c = 'Business Design' , Actual_hours__c = 5 , Opportunity__c = opportunity.Id);
        Test.startTest();
        insert timeEntry;
        Test.stopTest();
        Assert.areEqual(null, [SELECT Id, Business_Board__c FROM Time_Entry__c WHERE Id =: timeEntry.Id ].Business_Board__c, 'Business Board Assigned');
    }
    @IsTest
    public static void businessBoardUpdatedAfterTimeEntryInsert() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity with BB'];
        Business_Board__c businessBoard = [SELECT Id, Total_Hours_before_BB1__c FROM Business_Board__c WHERE Opportunity__c =: opportunity.Id LIMIT 1];
        Time_Entry__c timeEntry = new Time_Entry__c(Resource__c = UserInfo.getUserId() , Resource_Team__c = 'Business Design' , Actual_hours__c = 6 , Opportunity__c = opportunity.Id);
        Test.startTest();
        insert timeEntry;
        Test.stopTest();
        Assert.areEqual(11, [SELECT Id, Total_Actual_Hours__c FROM Business_Board__c LIMIT 1].Total_Actual_Hours__c, 'Total Actual Hours Updated');
        Assert.areEqual(11, [SELECT Id, Total_Hours_before_BB1__c FROM Business_Board__c LIMIT 1].Total_Hours_before_BB1__c, 'Total Hours Before BB1 Updated');
    }
    @IsTest
    public static void businessBoardUpdatedAfterTimeEntryUpdate() {
        Time_Entry__c timeEntry = [SELECT Id, Actual_hours__c FROM Time_Entry__c WHERE Opportunity__r.Name = 'Opportunity with BB' LIMIT 1];
        Test.startTest();
        timeEntry.Actual_hours__c = 10;
        update timeEntry;
        Test.stopTest();
        Assert.areEqual(10, [SELECT Id, Total_Actual_Hours__c FROM Business_Board__c LIMIT 1].Total_Actual_Hours__c, 'Total Actual Hours Updated');
    }
    @IsTest
    public static void businessBoardUpdatedAfterTimeEntryDelete() {
        Time_Entry__c timeEntry = [SELECT Id, Actual_hours__c FROM Time_Entry__c WHERE Opportunity__r.Name = 'Opportunity with BB' LIMIT 1];
        Test.startTest();
        delete timeEntry;
        Test.stopTest();
        Assert.areEqual(0, [SELECT Id, Total_Actual_Hours__c FROM Business_Board__c LIMIT 1].Total_Actual_Hours__c, 'Total Actual Hours Updated');
    }
    @IsTest
    public static void businessBoardUpdateTotalHoursAfterBB2() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity with BB'];
        Business_Board__c businessBoard = [SELECT Id, Total_Hours_after_BB2__c, BB1_date__c, BB2_date__c FROM Business_Board__c WHERE Opportunity__c =: opportunity.Id LIMIT 1];
        Time_Entry__c timeEntry = new Time_Entry__c(Resource__c = UserInfo.getUserId() , Date__c = Date.newInstance(2024,2,8), Resource_Team__c = 'Business Design' , Actual_hours__c = 6 , Opportunity__c = opportunity.Id);
        Test.startTest();
        businessBoard.BB1_date__c = Date.newInstance(2023, 12, 31);
        businessBoard.BB2_date__c = Date.newInstance(2024,2,1);
        update businessBoard;
        insert timeEntry;
        Test.stopTest();
        Assert.areEqual(6, [SELECT Id, Total_Hours_after_BB2__c FROM Business_Board__c LIMIT 1].Total_Hours_after_BB2__c, 'Total Hours After BB2 Updated');
    }
    @IsTest
    public static void businessBoardUpdateTotalHoursBetweenBB1AndBB2() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity with BB'];
        Business_Board__c businessBoard = [SELECT Id, Total_Hours_between_BB1_BB2__c, BB1_date__c, BB2_date__c FROM Business_Board__c WHERE Opportunity__c =: opportunity.Id LIMIT 1];
        Time_Entry__c timeEntry = new Time_Entry__c(Resource__c = UserInfo.getUserId() , Date__c = Date.newInstance(2024,1,8), Resource_Team__c = 'Business Design' , Actual_hours__c = 8 , Opportunity__c = opportunity.Id);
        Test.startTest();
        businessBoard.BB1_date__c = Date.newInstance(2023, 12, 31);
        businessBoard.BB2_date__c = Date.newInstance(2024,2,1);
        update businessBoard;
        insert timeEntry;
        Test.stopTest();
        Assert.areEqual(8, [SELECT Id, Total_Hours_between_BB1_BB2__c FROM Business_Board__c LIMIT 1].Total_Hours_between_BB1_BB2__c, 'Total Hours Between BB1 and BB2 Updated');
    }
    @IsTest
    public static void businessBoardUpdateTotalHoursAfterTheDeal() {
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE LIMIT 1];
        Opportunity opportunity = [SELECT Id, StageName, CloseDate FROM Opportunity WHERE Name = 'Opportunity with BB' LIMIT 1];
        Business_Board__c businessBoard = [SELECT Id, Total_Hours_after_the_deal__c, BB1_date__c, BB2_date__c FROM Business_Board__c WHERE Opportunity__c =: opportunity.Id LIMIT 1];
        Time_Entry__c timeEntry = new Time_Entry__c(Resource__c = UserInfo.getUserId() , Business_Board__c = businessBoard.Id, Date__c = Date.today(), Resource_Team__c = 'Business Design' , Actual_hours__c = 11 , Opportunity__c = opportunity.Id);
        Test.startTest();
        System.runAs(byPassUser) {
            opportunity.StageName = 'Vunnen';
            opportunity.CloseDate = Date.today();
            update opportunity;
            insert timeEntry;
        }
        Test.stopTest();
        Assert.areEqual(11, [SELECT Id, Total_Hours_after_the_deal__c FROM Business_Board__c LIMIT 1].Total_Hours_after_the_deal__c, 'Total Hours After The Deal Updated');
    }
}