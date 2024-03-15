/**
 * Description:
 * YearlyPerformanceChartController Test class.
 * 
 * Modifications:
 * 16.12.2022 [Tomass Brazovskis] SALEF-7206 - Deleted invocation of the YearlyPerformanceChartController 
 *              getYearlyCompetenceScore() method, as the method is removed to accommodate for the Almond package removal.
 */
@isTest
public with sharing class Test_YearlyPerformanceChartController  {

    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }

    /**
     * @Description:
     * Modifications:
     *  16.12.2022 [TB] SALEF-7206 - Deleted invocation of the YearlyPerformanceChartController getYearlyCompetenceScore() method.
     *              An Event and a Task inserted to increase the code coverage. 
     **/ 
    @isTest
    static void testYearlyPerformanceChartController(){
        // Start Initialize Test Data
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);

        User cygateUser;
        User businessAdmin;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            List<User> userList = new List<User>();
            cygateUser = Test_DataFactory.createCygateUser();
            businessAdmin = Test_DataFactory.createCygateEnterpriseBusinessAdminUser();
            userList.add(cygateUser);
            userList.add(businessAdmin);
            insert userList;
        }

        Yearly_Performance_Score__c yp;
         
        System.runAs(businessAdmin){
            User_Performance__c up = Test_DataFactory.createUserPerformance(cygateUser);
            insert up;

            yp = Test_DataFactory.createYearlyPerformanceScore(up.Id);
            yp.Client_Meetings_Target__c = 10000;
            yp.Client_Meetings_Registered__c = 200;
            yp.Competence_Events_Attended__c = 3;
            yp.Competence_Events_Target__c=15;          
            insert yp;

            // SALEF-7206 - Insert an Event and a Task to cover the getYearlyContributionScore()
            Event testEvent = Test_DataFactory.createOneCompletedEvent();
            testEvent.Legacy_Activity__c = false;
            testEvent.Event_Complete__c = true;
            testEvent.OwnerId = cygateUser.id;
            insert testEvent;

            Task testTask = Test_DataFactory.createOneTask();
            testTask.Status = 'Stängd';
            testTask.Legacy_Activity__c = false;
            testTask.OwnerId = cygateUser.id;
            // Ensure the Task 'TaskEndDate' and the Event 'End' are in the same year
            if(testEvent.EndDateTime != null){
                testTask.ActivityDate = testEvent.EndDateTime.date();
            }
            insert testTask;
                
            
            /*TestTrainingPlanData.createSampleData();
            List<Training_Plan__c> tplan = [select id from Training_Plan__c];
            Learning_Assignment__c learningAssignments = [select id from Learning_Assignment__c where Training_Plan_Section_Assignment__r.Training_Plan_Section__r.Training_Plan__c = :tplan];
            learningAssignments.User__r.id=cygateUser.id;
            */
            
            YearlyPerformanceChartController.getYps(yp.id);
            //YearlyPerformanceChartController.getYps();
            System.debug('Run Yearly');
            YearlyPerformanceChartController.getYearlyContributionScore(cygateUser.id);
        }
    }
}