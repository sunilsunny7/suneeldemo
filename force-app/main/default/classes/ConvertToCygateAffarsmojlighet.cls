/**
About
-----
Description: ConvertToCygateAffarsmojlighet used for conversion of Prospect to Cygate Affarsmojlighet/Opp
Associated VF page = 'ConvertToCygateAffarsmojlighet' , Opportunity Button = 'Convert_to_cygate_opportunity'
Create date: 10.08.2016

Update History
--------------
Created Aug 2016 - N.G
Updated Sep 2016 - A.N Refactored: restructured, cleaned up code, removed unused variables and hard coded values, fixed code syntax and indentation errors
Updated Feb 2017 - A.N Case-2419: Deleted all validations from processRecord()-method, except for NS/CS validation.

Issues / TODOs
--------------  

*/

public class ConvertToCygateAffarsmojlighet{
    public String opportunityId{get;set;}
    public Boolean nscsError{get;set;}
    public String sfdcURL{get;set;}

    public ConvertToCygateAffarsmojlighet(ApexPages.StandardController stdController) {        
        Opportunity opp = (Opportunity)stdController.getRecord();
        opportunityId = opp.Id;
        nscsError = false;
        sfdcURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    }

    public PageReference processRecord(){  
        Opportunity opp = [SELECT Id, New_Sales__c, Continuation_Sales__c, StageName, RecordTypeId, Needs_and_Challenges__c FROM Opportunity WHERE id =: opportunityId LIMIT 1];
        
        if((opp.New_Sales__c == null || opp.New_Sales__c == 0) && (opp.Continuation_Sales__c == null || opp.Continuation_Sales__c == 0)){ // Check for New_Sales__c OR Continuation_Sales__c values to be greater than 0.
            nscsError = true;
        } else {
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD);
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;           
            update opp;                  
        }
        
        return null;       
    }

    /* Old version with more validations
    public PageReference processRecord(){  
        Opportunity opp = [SELECT Id, New_Sales__c, Continuation_Sales__c, StageName, RecordTypeId, Needs_and_Challenges__c FROM Opportunity WHERE id =: opportunityId LIMIT 1];
        
        if((opp.New_Sales__c == null || opp.New_Sales__c == 0) && (opp.Continuation_Sales__c == null || opp.Continuation_Sales__c == 0)){ // Check for New_Sales__c OR Continuation_Sales__c values to be greater than 0.
            nscsError = true;
        } else if(opp.Needs_and_Challenges__c == null || opp.Needs_and_Challenges__c == ''){ // Check for Needs_and_Challenges__c to be filled.
            nacError = true;
        } else {            
            List<OpportunityContactRole> ocr = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId =: opportunityId AND Role = :OpportunityValidationHandler.OPP_CR_DECISION_MAKER LIMIT 1];
            if(ocr.isEmpty()){ // Check for at least one Opportunity contact role of role = 'Beslutsfattare'
                ocrError = true;
            } else{
                Contact con = [SELECT id,(SELECT id FROM ActivityHistories WHERE WhatID =:opportunityId) FROM contact WHERE id =:ocr[0].ContactId];
                if(con.ActivityHistories.isEmpty()){ // Check for at least one closed activity with contact who is added to Opportunity contact role of role = 'Beslutsfattare'
                    ahError = true;
                } else {
                    opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD);
                    opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;           
                    update opp;                  
                }
            }
        }             
        return null;       
    }
    */
}