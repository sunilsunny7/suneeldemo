/**
 * Created by wgm6247 on 2023-04-12.
 */

@isTest
public with sharing class RelatedOppsOnKKNRController_Test {

@isTest(seeAllData=true)
    static void testGetReportIds() {
        Report report1 = [SELECT Id FROM Report WHERE Name = 'Related Opportunities'];
        Report report2 = [SELECT Id FROM Report WHERE Name = 'Related open business opportunities'];
        RelatedOppsOnKKNRController.wrapper expectedWrapper = new RelatedOppsOnKKNRController.wrapper();
        expectedWrapper.relatedOppReportID = report1.Id;
        expectedWrapper.relatedOppBusinessReportID = report2.Id;

        RelatedOppsOnKKNRController.wrapper actualWrapper = RelatedOppsOnKKNRController.getReportIds();

        System.assertEquals(expectedWrapper.relatedOppReportID, actualWrapper.relatedOppReportID);
        System.assertEquals(expectedWrapper.relatedOppBusinessReportID, actualWrapper.relatedOppBusinessReportID);
    }
}