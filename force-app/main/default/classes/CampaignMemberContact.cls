/**
About
-----
Description: Remove selected Campaign Members from the selected Campaign.
Create date: January 2017

Update History
--------------
Created January 2017 - D.C


Issues / TODOs
-------------- 

*/

public with sharing class CampaignMemberContact {

    private ApexPages.StandardSetController stdController;
    public List<Contact> selectedContacts;
    public List<selectOption> options = new List<selectOption>();
    public String Campqueue {get;set;}
    public List<CampaignMember> delCampaignMember = new List<CampaignMember>();
    
    public campaignMemberContact(ApexPages.StandardSetController stdController)
    {
        this.stdController = stdController;
        listOfContactSelected();
    }
    
    //Fetch the list of selected Contacts.
    public PageReference listOfContactSelected(){
        selectedContacts = (List<Contact>) stdController.getSelected();
        return NULL;
    }
    
    //Fetch the List of Campaigns for the selected Contacts.
    public List<selectOption> getCampaignName(){
        for(Campaign cam: [Select Id, Name from Campaign where Id IN (Select CampaignId from CampaignMember where ContactId IN :selectedContacts)]){
            options.add(new selectOption(cam.Id,cam.Name));
        }
        return options; 
    }
    
    //Delete Campaign member from Campaign..
    public PageReference Delnow(){
        
        delCampaignMember = [Select id from CampaignMember where ContactId IN :selectedContacts and CampaignId = :Campqueue];
        if (delCampaignMember.size() > 0){
            delete delCampaignMember;
            return stdController.cancel();  
        } else {
             return stdController.cancel();
        } 
    }
    
    public PageReference Cancel(){
        return stdController.cancel();
    }
    
}