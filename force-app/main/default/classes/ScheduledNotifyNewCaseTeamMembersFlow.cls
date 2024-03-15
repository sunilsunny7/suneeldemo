/**
 * Description:
 * Schedulable class periodically calling Send_Notifications_to_New_Enterprise_Case_Team_Members 
 * Autolaunched Flow, via the Flow handler.
 * 
 * Introduced for SALEF-7667
 * 
 * Modifications:
 * 13.03.2023 [Tomass Brazovskis] SALEF-7667 - Introduced.
*/
global class ScheduledNotifyNewCaseTeamMembersFlow implements Schedulable{

    @TestVisible
    private static Integer FLOW_INTERVIEW_EXECUTION_PERIOD_DEFAULT = Integer.valueOf(System.Label.Send_Notifications_to_New_Enterprise_Case_Team_Members_Job_Execution_Period);
    @TestVisible
    private Integer flowInterviewExecutionPeriod;

    /**@Description:
     * Constructor without parameters, uses the period dafault value.
     * Modifications:
     *  13.03.2023 [TB] SALEF-7667 - Introduced.
     **/
    public ScheduledNotifyNewCaseTeamMembersFlow() {
        this(FLOW_INTERVIEW_EXECUTION_PERIOD_DEFAULT);
    }

    /**@Description:
     * Constructor without accepting a single parameters.
     * @param flowInterviewExecutionPeriod - Time intervals at which the Flow is expected to be run.
     * Modifications:
     *  13.03.2023 [TB] SALEF-7667 - Introduced.
     **/
    public ScheduledNotifyNewCaseTeamMembersFlow(Integer flowInterviewExecutionPeriod) {
        if( flowInterviewExecutionPeriod != null
            && flowInterviewExecutionPeriod >= 0
        ){
            this.flowInterviewExecutionPeriod = flowInterviewExecutionPeriod;
        } else{
            this.flowInterviewExecutionPeriod = FLOW_INTERVIEW_EXECUTION_PERIOD_DEFAULT;
        }
    }

    global void execute(SchedulableContext sc) {
        NotifyNewCaseTeamMembersFlowHandler curNotifyNewCaseTeamMembersFlowHandler = new NotifyNewCaseTeamMembersFlowHandler(flowInterviewExecutionPeriod);
        curNotifyNewCaseTeamMembersFlowHandler.launchFlowInterview();
    }
}