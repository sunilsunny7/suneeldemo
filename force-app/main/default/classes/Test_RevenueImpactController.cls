@isTest
/*
Created by P.S on Nov-2020
----
Covers Class - RevenueImpactController
*/
public class Test_RevenueImpactController{

 public static testmethod void RevenueImpactControllertest(){

   System.runAs(Test_DataFactory.getByPassUser()){ 
     Opportunity opp = Test_DataFactory.createOpportunity();
     insert opp;
     List<Revenue_Effect__c> riList = new List<Revenue_Effect__c>();
     Revenue_Effect__c ri = new Revenue_Effect__c();
     ri.Category__c = 'MOBILT';
     ri.Sub_Category__c = 'MOBIL ABG';
     ri.New_Antal__c = 100;
     ri.New_Monthly_Cost__c = 110;
     ri.Old_Antal__c = 100;
     ri.Old_Monthly_Cost__c = 120;
     ri.Opportunity__c = opp.id;
     
     insert ri;
     
     Revenue_Effect__c ri2 = new Revenue_Effect__c();
     ri2.Category__c = 'MOBILT';
     ri2.Sub_Category__c = 'MOBIL ABG';
     ri2.New_Antal__c = 100;
     ri2.New_Monthly_Cost__c = 110;
     ri2.Old_Antal__c = 100;
     ri2.Old_Monthly_Cost__c = 120;
     ri2.Opportunity__c = opp.id;
     
     riList.add(ri2);
     
     RevenueImpactController.saveRevenueImpact(riList);
     RevenueImpactController.getAllRecords(opp.id);
     RevenueImpactController.deleteRecord(ri.id);
     RevenueImpactController.getCalculatedAmt(opp.id);
     RevenueImpactController.updateRi(riList);
     RevenueImpactController.getDependentMap(ri,'Category__c','Sub_Category__c');
      
   }
 }
}