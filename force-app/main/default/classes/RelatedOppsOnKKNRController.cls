/**
 * Created by wgm6247 on 2023-04-07.
 */

public with sharing class RelatedOppsOnKKNRController {
    public class wrapper {
        @AuraEnabled
        public String relatedOppReportID {get;set;}
        @AuraEnabled
        public String relatedOppBusinessReportID {get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static RelatedOppsOnKKNRController.wrapper getReportIds(){
        RelatedOppsOnKKNRController.wrapper newWrapper=new RelatedOppsOnKKNRController.wrapper ();
        newWrapper.relatedOppReportID = [SELECT Id FROM Report WHERE Name = : Label.Related_Opportunities].Id;
        newWrapper.relatedOppBusinessReportID = [SELECT Id FROM Report WHERE Name = : Label.Related_open_business_opportunities].Id;
        return newWrapper;
    }
}