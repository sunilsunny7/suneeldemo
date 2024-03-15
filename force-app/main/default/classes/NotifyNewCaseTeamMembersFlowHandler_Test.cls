/**
 * Description:
 * NotifyNewCaseTeamMembersFlowHandler test class.
 * Introduced for SALEF-7667
 * 
 * Modifications:
 * 13.03.2023 [Tomass Brazovskis] SALEF-7667 - Introduced. 
*/
@isTest
public class NotifyNewCaseTeamMembersFlowHandler_Test {

    /**@Description:
     * Test constructor taking no arguments.
     * Modifications:
     *  13.03.2023 [TB] SALEF-7667 - Introduced.
     **/ 
    @isTest
    public static void notifyNewCaseTeamMembersFlow_testDefaultVariableAssignment() {

        NotifyNewCaseTeamMembersFlowHandler newFlowHandler = new NotifyNewCaseTeamMembersFlowHandler();
        System.assertEquals(    NotifyNewCaseTeamMembersFlowHandler.FLOW_INTERVIEW_EXECUTION_PERIOD_DEFAULT,
                                newFlowHandler.flowInterviewExecutionPeriod,
                                'Default input values not set correctly when optional arguments are not being passed.');
    }

    /**@Description:
     * Test the Flow call.
     * Modifications:
     *  13.03.2023 [TB] SALEF-7667 - Introduced.
     **/
    @isTest
    public static void notifyNewCaseTeamMembersFlow_testLaunchFlowInterview() {
        Integer jobExecutionPeriod = 4;
        NotifyNewCaseTeamMembersFlowHandler newFlowHandler = new NotifyNewCaseTeamMembersFlowHandler(jobExecutionPeriod);
        Test.startTest();
        newFlowHandler.launchFlowInterview();
        Test.stopTest();
    }
}