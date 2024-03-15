/**
 * Description:
 * Send_Notifications_to_New_Enterprise_Case_Team_Members Auto-launched Flow handler,
 * used to set up and start a Flow Interview from ScheduledNotifyNewCaseTeamMembersFlow.
 * 
 * Introduced for SALEF-7667
 * 
 * Modifications:
 * 13.03.2023 [Tomass Brazovskis] SALEF-7667 - Introduced. 
*/
public with sharing class NotifyNewCaseTeamMembersFlowHandler{

    @TestVisible
    private static final Integer FLOW_INTERVIEW_EXECUTION_PERIOD_DEFAULT = 2;
    @TestVisible
    private Integer flowInterviewExecutionPeriod;

    private static final String FLOW_INPUT_VARIABLE_NAME_JOB_EXECUTION_PERIOD = 'jobExecutionPeriod';

    private Map<String, Object> mapFlowInputVarNamesToValues = new Map<String, Object>();

    /**@Description:
     * Constructor without parameters, uses the period dafault value.
     * Modifications:
     *  13.03.2023 [TB] SALEF-7667 - Introduced.
     **/ 
    public NotifyNewCaseTeamMembersFlowHandler() {
        this(FLOW_INTERVIEW_EXECUTION_PERIOD_DEFAULT);
    }

    /**@Description:
     * Constructor without accepting a single parameters.
     * @param flowInterviewExecutionPeriod - Time intervals at which the Flow is expected to be run.
     * Modifications:
     *  13.03.2023 [TB] SALEF-7667 - Introduced.
     **/ 
    public NotifyNewCaseTeamMembersFlowHandler(Integer flowInterviewExecutionPeriod) {
        if( flowInterviewExecutionPeriod != null
            && flowInterviewExecutionPeriod >= 0
        ){
            this.flowInterviewExecutionPeriod = flowInterviewExecutionPeriod;
        } else{
            this.flowInterviewExecutionPeriod = FLOW_INTERVIEW_EXECUTION_PERIOD_DEFAULT;
        }
    }

    /**@Description:
     * Method starts a Send_Notifications_to_New_Enterprise_Case_Team_Members Flow interview
     * with its input variables set according to the arguments passed to the constructor.
     * Modifications:
     *  13.03.2023 [TB] SALEF-7667 - Introduced.
     **/ 
    public void launchFlowInterview(){
        mapFlowInputVarNamesToValues.put(FLOW_INPUT_VARIABLE_NAME_JOB_EXECUTION_PERIOD, this.flowInterviewExecutionPeriod);
        Flow.Interview.Send_Notifications_to_New_Enterprise_Case_Team_Members myFlow = 
            new Flow.Interview.Send_Notifications_to_New_Enterprise_Case_Team_Members(mapFlowInputVarNamesToValues);
        myFlow.start();
    }
}