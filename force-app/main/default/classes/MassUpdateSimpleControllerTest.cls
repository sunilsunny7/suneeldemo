/****
* Author & Date Update: Varma Alluri,  28.03.2017
* Description: Jira Ticket: SAEN-2201
* This is the Test Class for MassUpdateSimpleController
*****/

@isTest
public class MassUpdateSimpleControllerTest {
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
        //req1.Requirement_Evaluation__c = 'Ej aktuellt'; commented by P.P
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
    public static testmethod void method1(){
        
        list<Requirement__c> reqlist1 = new List<Requirement__c>();
        list<Requirement__c> reqlist =   setup();    
        reqlist1 = [select id,name from requirement__c where id IN:reqlist];
        system.debug(reqlist1);
        
        Test.startTest();
        Test.setCurrentPage(Page.Template_MassUpdateRequirements);
        ApexPages.currentPage().getParameters().put('id' , reqlist.get(0).Id); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(reqlist1);
        // stdSetController.setSelected(reqlist1);
        MassUpdateSimpleController ext = new MassUpdateSimpleController(stdSetController);
        Test.stopTest();
        
    }
    public static testmethod void method2(){
        
        list<Requirement__c> reqlist1 = new List<Requirement__c>();
        list<Requirement__c> reqlist =   setup();    
        reqlist1 = [select id,name from requirement__c where id IN:reqlist];
        system.debug(reqlist1);
        
        Test.startTest();
        Test.setCurrentPage(Page.Template_MassUpdateRequirements);
        ApexPages.currentPage().getParameters().put('id' , reqlist.get(0).Id); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(reqlist1);
        stdSetController.setSelected(reqlist1);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(stdSetController);
        string   pid = reqlist.get(0).Id;
        string query ;
        query = controller.generateQuery(Opportunity.sObjectType ,'REFERENCE',pid);
        System.assertEquals(query,'SELECT Name,Account.Name,CloseDate, Amount, Owner.Name FROM Opportunity where REFERENCE=\''+pid+'\'');
        query = controller.generateQuery(Contact.sObjectType ,'REFERENCE',pid);
        System.assertEquals(query,'SELECT Name,Email,Account.Name, Title, Owner.Name FROM Contact where REFERENCE=\''+pid+'\'');
        query = controller.generateQuery(Asset.sObjectType ,'REFERENCE',pid);
        System.assertEquals(query,'SELECT Name,Product2.Name,InstallDate, Status, Quantity FROM Asset where REFERENCE=\''+pid+'\'');
        query = controller.generateQuery(Case.sObjectType ,'REFERENCE',pid);
        System.assertEquals(query,'SELECT Subject,CaseNumber,Account.Name, Status, Owner.Name FROM Case where REFERENCE=\''+pid+'\'');
        query = controller.generateQuery(Campaign.sObjectType ,'REFERENCE',pid);
        System.assertEquals(query,'SELECT Name,StartDate,Type, Status, Owner.Name FROM Campaign where REFERENCE=\''+pid+'\'');
        query = controller.generateQuery(lead.sObjectType ,'REFERENCE',pid);
        System.assertEquals(query,'SELECT Name,Email,Company, LeadSource FROM Lead where REFERENCE=\''+pid+'\'');
        query = controller.generateQuery(product2.sObjectType ,'REFERENCE',pid);
        System.assertEquals(query,'SELECT Name,IsActive,Family, ProductCode FROM Product2 where REFERENCE=\''+pid+'\'');
        controller.getStep();
        controller.getsType();
        controller.filterId = 'test';
        controller.getFieldTypeOptions();
        controller.getFieldInfoToDisplay();
        controller.lexstep1();
        System.assertEquals(controller.getStep(),'1');
        controller.lexstep2();
        System.assertEquals(controller.getStep(),'2');
        controller.lexstep3();
         System.assertEquals(controller.getStep(),'3');
            
        System.assertEquals(controller.getsType(),'Requirement__c');
        String value = '123test';
        controller.fieldName='name';
        controller.valueToUpdate=value;     
        controller.lexstep4();
        controller.lexstep5();
        System.assert(controller.displayTexField);
        System.assertEquals(controller.getFieldInfoToDisplay()!=null,true);
        controller.cancel();
        controller.step1();
        System.assertEquals(controller.getStep(),'1');
        controller.step2();
        System.assertEquals(controller.getStep(),'2');
        controller.fieldName='Partially_Responsible__c';
        controller.valueToUpdate = 'varma alluri';
        controller.step3();
        controller.SearchKey = 'var';
         controller.Searchacc();   
        System.assertEquals(controller.getStep(),'3');
        controller.step4();
        controller.step5();
        System.assert(controller.getPicklistValues()==null);
        System.assert(controller.getNow(true)!=null);
        System.assert(controller.getNow(false)!=null);
        System.assert(!controller.displayCheckBox);
        System.assert(!controller.displayPicklist);
        System.assert(!controller.displayTextArea);
        Test.stopTest();
    }
}