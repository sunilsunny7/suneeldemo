/**
About
-----
Description: ActivateDeactivateContact
Associated VF page = 'ActivateDeactivateContact' , Contact Button = 'Aktivera/Inaktivera'
Create date: 16.03.2016

Update History
--------------
Created Mar 2016 - N.G
Updated Sep 2016 - A.N Refactored: restructured, cleaned up code, removed unused variables.

Issues / TODOs
--------------  
When clicking the button "Aktivera/Inaktivera" (which calls this controller) on a contact in test org, the user is redirected to Production org. This needs to be fixed in the VF-page.

*/
public class ActivateDeactivateContact{

    public String contactID {get;set;}
     public String sfdcURL{get;set;}
    
    public ActivateDeactivateContact(ApexPages.StandardController stdController) {        
        Contact conRec = (Contact)stdController.getRecord();
        contactID = conRec.Id;
        sfdcURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        //system.debug('******sfdcURL****'+sfdcURL);
    }

    public PageReference processRecord(){  
        Contact con = [SELECT Id, Deactivation_Date__c FROM Contact WHERE Id =: contactID LIMIT 1];
        con.Deactivation_Date__c = (con.Deactivation_Date__c == null ? System.today() : null);
        update con;         
        return null;       
    }     
}