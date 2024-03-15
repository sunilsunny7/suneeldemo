/***
Author: Varma Alluri
Create Date: 27.03.2017

Description: JIRA Ticket SAEN-2201
This Test Class is for MassEditControllerNew Class
***/

@isTest
private class MassEditControllerNewTest {
    @istest
    static list<requirement__c> setup()  {
        list<Requirement__c> reqlist = new List<Requirement__c>();
        Solution_Verification__c solver1 = new Solution_Verification__c();   // Test data
        Insert solver1;
        
        Requirement__c req1 = new Requirement__c();       
        req1.Related_Solution__c = solver1.id;
        req1.Reference_Solution__c = true;
        req1.Area__c = 'Växel';  //
        req1.Category__c = 'Category 1';
        req1.Estimated_Points_Req__c = 10;
        req1.Other_Partially_Responsibles__c = 'test area';
        req1.Partially_Responsible__c = userinfo.getuserid();
        //req1.Requirement_Evaluation__c = 'Ej aktuellt'; // commented by P.P
        req1.Requirement_Evaluation__c = 'Nej';
        req1.Risk_Categorisation__c = 'Funktionsrisker';
        req1.Type_of_Requirement__c = 'Bör';
        req1.Value_of_Requirement__c =20;
        req1.Platform__c = 'Centrex';
        req1.Article_Version_Number__c = 10;
        req1.Article_Title__c = 'Test Article';
        req1.Approval_Decision_Date_Time__c = system.now();
        req1.Approval_Decision_Made_By__c = Userinfo.getUserId();
        req1.Status__c = 'Ej aktuellt';
        req1.Requirement_fullfiled__c = 'Nej';
        reqlist.add(req1);
        insert reqlist;
        return reqlist;
    }
   
    @isTest
    static void testOpportunityInRelatedList2(){
        list<Requirement__c> reqlist1 = new List<Requirement__c>();
        list<Requirement__c> reqlist =   setup();    
        reqlist1 = [select id,name from requirement__c where id IN:reqlist];
        system.debug(reqlist1);
        
        Test.startTest();
        PageReference vfPage = Page.Template_MassEditRequirements; // Referencing Template_MassEditRequirements VF page
        Test.setCurrentPageReference(vfPage); // use setCurrentPageReference,               
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(reqlist1);
        setCtr.setSelected(reqlist1);
        MassEditControllerNew controller = new MassEditControllerNew(setCtr);
        controller.saveCustom();
        System.assert(controller.saveCustom()==null);
        test.stoptest();
    }
}