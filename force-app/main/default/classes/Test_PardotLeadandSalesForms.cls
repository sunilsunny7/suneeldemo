@isTest(seealldata=true)
private class Test_PardotLeadandSalesForms {
    @isTest
    public static void testCallout() {
        Test.StartTest();
        pageReference pager = page.AF_Lead_form;
        Test.setCurrentPage(pager);
        LeadAgentFormHandlerController l = new LeadAgentFormHandlerController();
        List<selectOption> productarea_picklist_options = l.getproductAreaOptions();
        l.firstName='first';
        l.lastName='last';
        l.email='test@gmail.com';
        l.phone='012912';
        l.company='company';
        l.orgnr='12345';
        l.description='test';
        l.AFnum='test';
        l.tholboxid='test';
        l.senderfname='senderfname';
        l.senderlname='senderlname';
        l.senderphone='senderphone';
        l.selectedproductarea='selectedproductarea';
        l.Submitlead();
        l.cancel();
        l.pardotLeadAgentSuccessPageBack();
        l.pardotLeadAgentErrorPageBack();
        l.doneHomePage();
        Test.StopTest();
    }
    @isTest
    public static void testCallout2() {
        Test.StartTest();
        pageReference pager = page.PardotSalesRepForm;
        Test.setCurrentPage(pager);
        LeadAgentFormHandlerController l = new LeadAgentFormHandlerController();
        List<selectOption> productarea_picklist_options = l.getproductAreaOptions();
        l.firstName='first';
        l.lastName='last';
        l.email='test1@gmail.com';
        l.phone='+4671234';
        l.company='company';
        l.orgnr='12345';
        l.description='test';
        l.senderfname='senderfname';
        l.senderlname='senderlname';
        l.senderphone='+4671234';
        l.selectedproductarea='selectedproductarea';
        l.cancel();
        l.SubmitSalesRepForm();       
        l.doneHomePage();
        l.Submitlead();
        l.pardotSalesRepErrorPageBack();
        l.pardotSalesRepSuccessPageBack();

        Test.StopTest();
    }
    @isTest
    public static void testCallout3() {
        Test.StartTest();
        pageReference pager = page.PardotSalesRepForm;
        Test.setCurrentPage(pager);
        LeadAgentFormHandlerController l = new LeadAgentFormHandlerController();
        List<selectOption> productarea_picklist_options = l.getproductAreaOptions();
        l.firstName='first';
        l.lastName='last';
        l.email='test1@gmail.com';
        l.phone='+4671234';
        l.company='company';
        l.orgnr='12345';
        l.description='test';
        l.senderfname='senderfname';
        l.senderlname='senderlname';
        l.senderphone='+4671234';
        l.selectedproductarea='selectedproductarea';
        l.isLightning = True;
        l.cancel();
        l.SubmitSalesRepForm();
        l.doneHomePage();
        l.pardotSalesRepErrorPageBack();
        l.pardotSalesRepSuccessPageBack();
        l.pardotLeadAgentSuccessPageBack();
        l.pardotLeadAgentErrorPageBack();
        Test.StopTest();
    }
}