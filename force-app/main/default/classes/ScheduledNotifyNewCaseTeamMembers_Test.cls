/**
 * Description:
 * ScheduledNotifyNewCaseTeamMembersFlow test class.
 * Introduced for SALEF-7667
 * 
 * Modifications:
 * 13.03.2023 [Tomass Brazovskis] SALEF-7667 - Introduced. 
*/
@isTest
public class ScheduledNotifyNewCaseTeamMembers_Test {

    @isTest
    public static void scheduledNotifyNewCaseTeamMembersFlow_testScheduling(){

        String CRON_EXP = '0 0 * * * ?';
        ScheduledNotifyNewCaseTeamMembersFlow curScheduledInstance = new ScheduledNotifyNewCaseTeamMembersFlow();
        System.assertEquals(    ScheduledNotifyNewCaseTeamMembersFlow.FLOW_INTERVIEW_EXECUTION_PERIOD_DEFAULT,
                                curScheduledInstance.flowInterviewExecutionPeriod,
                                'Default input values not set correctly when optional arguments are not being passed.');

        Test.startTest();
        String jobId = System.schedule( 'testScheduledNotifyNewCaseTeamMembersFlow',
                                        CRON_EXP,
                                        curScheduledInstance);
        Test.stopTest();
    }
}