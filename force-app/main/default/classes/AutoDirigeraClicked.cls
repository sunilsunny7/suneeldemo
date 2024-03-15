/**
    About
    -----
    Description: AutoDirigeraClicked controller class for VF page 'AutoDirigeraClicked'
    Create date: 31.10.2016

    Update History
    --------------
    Created Oct 2016 - N.G - Created. SAEN-1896 To autoroute Leads
    Issues / TODOs
    --------------     
*/



public class AutoDirigeraClicked{

     public String leadID {get;set;}
     public String sfdcURL{get;set;}
     public Boolean ldsAccError{get;set;}
     public Boolean ldsAccOwError{get;set;}
    
    public AutoDirigeraClicked(ApexPages.StandardController stdController) {        
        Lead leadRec = (Lead)stdController.getRecord();
        leadID = leadRec.Id;
        ldsAccError = false;
        ldsAccOwError = false;

        sfdcURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        //system.debug('******sfdcURL****'+sfdcURL);
    }

    public PageReference processRecord(){  

        list<Lead> leadRec = [SELECT Id, LeadSource, Account__c, Account__r.OwnerId FROM Lead WHERE id =: leadID  LIMIT 1];

            if(!leadRec.isEmpty() && leadRec[0].Account__c == null ){ 
            ldsAccError = true;
            } else if(!leadRec.isEmpty() && leadRec[0].Account__r.OwnerId == label.Integration_User_Id && leadRec[0].LeadSource != 'ÅF' ){ 
                ldsAccOwError = true;
            } 
             else {

                //Fetching the assignment rules on Lead
                AssignmentRule AR = new AssignmentRule();
                // This statement will fetch the active assignment rule on Lead with name lead rule 
                AR = [select id, name from assignmentrule where active=true and name = 'lead rule' limit 1];        
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                
                //Setting up the lead to update with Assignment rule operation
                lead newLead = new Lead(id = leadID);
                newLead.Auto_Dirigera_clicked__c = true; //setting this checkbox true to fire process builder
                //Setting the DMLOption on Case instance
                newLead.setOptions(dmlOpts);
                update newLead;
                
                                 
                } 
       return null;
    }     
}