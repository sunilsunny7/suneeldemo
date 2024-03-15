/**
 * Created by kwn687 on 2021-11-08.
 */

public with sharing class AutoDirectListViewController {
    public List<Lead> leadList;
    public String leadIds;


    public AutoDirectListViewController(ApexPages.StandardSetController cntlr){
        leadList = cntlr.getSelected();
        leadIds = '';
        for(Lead oneLead : leadList){
            leadIds += oneLead.Id + ',';
        }
        leadIds = leadIds.removeEnd(',');
    }

    public PageReference redirectToLC(){
        String returnUrl = '/lightning/cmp/c__AutoDirectAction?c__listOfLeads='+leadIds;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }

}