/**
About
-----
Description: ConvertToForenkladProcess used for conversion of Prospect to Forenklad Process
** Associated VF page = 'ConvertToForenkladProcess' , Opportunity Button = 'ConvertToForenkladProcess'
Create date: 21.11.2016

Update History
--------------
Created Nov 2016 - N.G

Issues / TODOs
--------------  

*/

public class ConvertToForenkladProcess{
    public String opportunityId{get;set;}
    public Boolean firstError{get;set;}
    //public Boolean secondError{get;set;}
    public String sfdcURL{get;set;}

    public ConvertToForenkladProcess(ApexPages.StandardController stdController) {        
        Opportunity opp = (Opportunity)stdController.getRecord();
        opportunityId = opp.Id;
        firstError = false;
        //secondError = false;
        sfdcURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    }

    public PageReference processRecord(){  
        Opportunity opp = [SELECT Id, New_Sales__c, Continuation_Sales__c, StageName, RecordTypeId , Winback_Revenue_12_month__c , Retain_Revenue_12_month__c FROM Opportunity WHERE id =: opportunityId LIMIT 1];
        
         if(opp.Winback_Revenue_12_month__c + opp.Retain_Revenue_12_month__c > 10000){ // Check for Needs_and_Challenges__c to be filled.
            firstError = true;
                } else {
                    opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_QUICK);
                    opp.StageName = OpportunityValidationHandler.OPP_STAGE_CLOSE_DEAL;           
                    update opp;                  
        }             
        return null;       
    }
}