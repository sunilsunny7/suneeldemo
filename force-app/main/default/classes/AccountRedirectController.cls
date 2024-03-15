/**
 * Created by kwn687 on 2021-09-27.
 */

public with sharing class AccountRedirectController {
    public String orgNr { get; set; }
    public accountRedirectController(ApexPages.StandardController sc) {
    }
    public PageReference redirect() {
        orgNr = ApexPages.currentPage().getParameters().get('orgNr');
        if (orgNr != null && orgNr.isNumeric()) {
            try {
                id accountID = [SELECT id FROM Account WHERE Org_Nr__c = :orgNr LIMIT 1].id;
                PageReference pgRef = new PageReference('/' + accountID);
                pgRef.setRedirect(true);
                return pgRef;
            } catch (Exception e) {
                PageReference pgRef = new PageReference('/c/SearchApp.app?search=' + orgNr);
                pgRef.setRedirect(true);
                return pgRef;
            }
        } else {
            PageReference pgRef = new PageReference('/lightning/app/06m1p0000011OTxAAM');
            pgRef.setRedirect(true);
            return pgRef;
        }
    }
}