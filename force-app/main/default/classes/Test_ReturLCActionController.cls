@isTest
public class Test_ReturLCActionController {
    
    @isTest static void testwrapperbethod(){
        ReturLCActionController.pSelectOption lc = new ReturLCActionController.pSelectOption();
        lc.Label = 'Test Label Log';
        lc.IsDefault = true;
        lc.Value = 'Test Value';
        Lead LeadRec = Test_DataFactory.createLead();
        insert LeadRec;
        General_Lead_Settings__c leadsettings = new General_Lead_Settings__c();
        leadsettings.Name = 'General Settings';
        leadsettings.Retur_LC_OwnerId__c = userinfo.getUserId();
        leadsettings.Retur_LC_Status__c = 'Returnerad';
        leadsettings.Retur_LC_Picklist_Values__c = 'Inte till rätt person;Supportfråga;Beställning – till Kundtjänst;Fakturafråga;Fastighetsaffärer/NEXT;Annat;';
        insert leadsettings;
        PageReference pageRef = Page.ReturnLCActionPage;
        pageRef.getParameters().put('leadId', String.valueOf(LeadRec.Id));
        Test.setCurrentPage(pageRef);
        ReturLCActionController rctrl = new ReturLCActionController();
        String result = ReturLCActionController.sendLeadToLC(LeadRec.Id,'Annat','Other Reason');
        PageReference Ref = rctrl.sendLeadToLCVF();
        List<ReturLCActionController.pSelectOption> resultList = ReturLCActionController.getPickListValues();
        ReturLCActionController.getLeadRecord(LeadRec.Id);
    }
}