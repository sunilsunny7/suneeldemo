/**
About
-----
Description: Service Class for Opportunity
Create date: June 2015

Update History
--------------
Created Jun 2015 - V.I Created new class with the updateSalesOutcome method
Updated Oct 2015 - V.I Created new method updateSolutionArea
Updated Oct 2015 - V.I Updated method updateSalesOutcome so that it adds the Sales_Outcome_Large__c for large opportunities
Updated Apr 2016 - A.N If last product on an opp is deleted, add it to the OpportunityTriggerHandler.oppsWithLastProductDeleted id-set
Updated Apr 2016 - A.N Refactored updateSalesOutcome method. Replaced for loops with nested queries.
Updated Sep 2016 - A.N The updateSalesOutcome method is only used by the OpportunityLineItem trigger functionality, so moved method to OpportunityLineItemTriggerHandler
Updated Sep 2016 - A.N Refactored updateSolutionArea method. Replaced for loop with nested queries.
Updated Sep 2016 - A.N The updateSalesOutcome method is only used by the Opportunity trigger functionality, so moved method to OpportunityTriggerHandler

Issues / TODOs
--------------  

THIS CLASS CAN BE DELETED, AS METHODS PREVIOUSLY IN THIS CLASS HAS BEEN MOVED TO TRIGGERS

*/

public class OpportunityServiceClass {
    
    // The solution area should be the opportunity line items product families + the values the user selects. 
    // When the opportunity is won the solution area should match the opportunity line items exactly. 
    /*
    public static void updateSolutionArea(List<Opportunity> oppList){
        
        for(Opportunity opp : [SELECT Id, (SELECT Product2.Family FROM OpportunityLineItems WHERE Product2.Family != null) FROM Opportunity WHERE Id in : oppList]){
            
            Set<String> solutionAreas = new Set<String>();            
            //Add the existing values
            if(opp.Main_Product_Area__c != null && !opp.IsWon){
                solutionAreas = new Set<String>(opp.Main_Product_Area__c.split(';'));
            }
            
            //Add the product families
            for(OpportunityLineItem oli : opp.OpportunityLineItems){
                String str = SEUtility.getSolutionAreaName(oli.Product2.Family);
                if(!str.contains('Cygate')){
                    solutionAreas.add(str);
                } else if(SEUtility.isCygateOpp(opp.RecordTypeId) || SEUtility.getRecordTypeDevName(opp.RecordTypeId) == SEUtility.OPP_RECTYPE_TELIA_CYGATE || SEUtility.getRecordTypeDevName(opp.RecordTypeId) == SEUtility.OPP_RECTYPE_PROSPECT){
                    solutionAreas.add(str);
                }
            }

            String newValue = SEUtility.writeMultiSelectPicklist(solutionAreas);
            if(!String.isBlank(newValue)){
                opp.Main_Product_Area__c = newValue;
            }
            
            //Update the sharing solution area field that controls the sharing rules
            String s = '';
            for(String solutionArea : solutionAreas){
                s += SEUtility.getSolutionAreaCode(solutionArea);
            }
            opp.Sharing_Solution_Area__c = s;
        }
    }
    */
}