/***
Author: Varma Alluri
Create Date: 24.03.03.2017

Description: JIRA Ticket SAEN-2201
Created this extension controller for the Template_MassEditRequirements VF page to navigate the page.
***/

public class MassEditControllerNew {
    
    public Apexpages.StandardsetController controller;
    public String ListViewURL{get; set;}
    public MassEditControllerNew(ApexPages.StandardsetController stdController) {
        controller = stdController;
        checkReturnURL();
    }
    
    public void checkReturnURL()
    {
        String urlVal = Apexpages.currentPage().getUrl();
        Map<String,String> PrefixList = new Map<String,String>{};
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        for(String sObj : gd.keySet()){
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            PrefixList.put(r.getName(), r.getKeyPrefix());
        }
 
        Database.QueryLocator ql = Database.getQueryLocator('select id from Requirement__c limit 1');
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(ql);
        System.SelectOption[] listViews = setController.getListViewOptions();
        String listViewID = null;

        ListViewURL='/'+PrefixList.get('Requirement__c');
        
    }
    public PageReference saveCustom(){      
        controller.save(); 
        return null;
    }
}