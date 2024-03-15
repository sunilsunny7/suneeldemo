@isTest
/*
Created by P.S on Sep-2020
----
Covers Class - FiberProcessInstanceCustomController
*/
private class MC_QuoteApprovalTable_Test {
    @isTest
    public static void getqliisTest() {
        User salesManager;
        User salesManager2;
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();


        System.runAs(new User(Id = Userinfo.getUserId())) {
            salesManager2 = Test_DataFactory.createFiberUser();
            salesManager2.Bypass_VR__c = true;
            salesManager2.Telia_Id__c = '32312231';
			salesManager2.MassCustomized_Roles__c  = 'SalesManager';			
            insert salesManager2;
            salesManager = Test_DataFactory.createFiberUser();
            salesManager.Bypass_VR__c = true;
            salesManager.managerID = salesManager2.id;
            salesManager2.MassCustomized_Roles__c  = 'SalesRep';
            insert salesManager;
        }
        FiberDiscountMandate__c fb = new FiberDiscountMandate__c();
        fb.Role__c = 'Manager';
        fb.Name = 'Manager';
        fb.EBIT_Max_Mandate__c = 12;
        fb.EBIT_Min_Mandate__c = 1;
        fb.ProductDiscountMaxMandate__c = 12;
        fb.ProductDiscountMinMandate__c = 12;
        insert fb;

        FiberDiscountMandate__c fb1 = new FiberDiscountMandate__c();
        fb1.Role__c = 'Director';
        fb1.Name = 'Director';
        fb1.EBIT_Max_Mandate__c = 12;
        fb1.EBIT_Min_Mandate__c = 1;
        fb1.ProductDiscountMaxMandate__c = 12;
        fb1.ProductDiscountMinMandate__c = 12;
        insert fb1;
        System.runAs(salesManager) {

            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode = 'Fiber Sales (Lägenhet)';
            insert prod;
            pricebookId = stdPriceBookRecId;

            Opportunity opp = new Opportunity();
            opp.Name = 'opp1';
            opp.CloseDate = System.today();
            opp.StageName = 'Needs Analysis';
            opp.Pricebook2Id = Test.getStandardPricebookId();
            insert opp;

            Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();

            Account testAccount = new Account();
            testAccount.recordtypeid = AccRtid;
            testAccount.Name = 'Fiber test12';
            insert testAccount;

            PricebookEntry objpricebookentry = new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice = 23.50;
            objpricebookentry.UseStandardPrice = false;
            objpricebookentry.isActive = true; //Add this line
            insert objpricebookentry;

            Test.startTest();
            RecordType rt = [Select id, name, DeveloperName from RecordType where Name = 'FA Quote'];
            RecordType CA_Quote_of_FA = [Select id, name, DeveloperName from RecordType where DeveloperName = 'TeliaSE_Fiber_CA_Quote_of_FA'];

            Quote parentQuote = new Quote();
            parentQuote.Name = 'Test Quote';
            parentQuote.status = 'Draft';
            parentQuote.RecordTypeId = rt.Id;
            parentQuote.opportunityId = opp.id;
            parentQuote.Pricebook2ID = stdPriceBookRecId;
            parentQuote.TeliaSE_Approval_Flag__c = False;
            insert parentQuote;


            QuoteLineItem parentQli = new QuoteLineItem();
            parentQli.PricebookEntryId = objpricebookentry.Id;
            parentQli.QuoteId = parentQuote.id;
            parentQli.UnitPrice = 200;

            parentQli.TeliaSE_Root_Product__c = prod.id;

            parentQli.Quantity = 4;
            parentQli.Product2Id = prod.id;
            parentQli.TeliaSE_Flag__c = '/resource/1549546732000/TeliaSE_Sad_Face';
            parentQli.TeliaSE_Approved__c = null;
            parentQli.vlocity_cmt__RecurringCharge__c = 200;
            parentQli.TeliaSE_Ceiling_Price__c = 400;

            parentQli.vlocity_cmt__RecurringCharge__c = 50;
            parentQli.vlocity_cmt__OneTimeCharge__c = 45;
            parentQli.TeliaSE_Fiber_Frame_Agreement__c = 10;
            parentQli.Fiber_Customer_Requested_Price__c = 50;
            insert parentQli;

            Contract contr = new Contract();
            contr.AccountId = testAccount.Id;
            contr.StartDate = date.today();
            contr.Actionneeded__c = false;
            contr.Large_dataload__c = false;
            contr.vlocity_cmt__IsAutoRenew__c = false;
            contr.vlocity_cmt__IsFrameContract__c = false;
            contr.vlocity_cmt__QuoteId__c = parentQuote.Id;
            insert contr;

            Quote qut = new Quote();
            qut.Name = 'Test Quote';
            qut.status = 'Draft';
            qut.RecordTypeId = CA_Quote_of_FA.Id;
            qut.vlocity_cmt__FrameContractId__c = contr.Id;
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;

            qut.Product_Details__c = '{"text1":"text1"}';

            insert qut;

            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.Product2Id = prod.id;
            oli1.TeliaSE_Flag__c = '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_Approved__c = null;
            oli1.vlocity_cmt__RecurringCharge__c = 200;
            oli1.TeliaSE_Ceiling_Price__c = 400;
            oli1.vlocity_cmt__RecurringCharge__c = 50;
            oli1.vlocity_cmt__OneTimeCharge__c = 45;
            oli1.TeliaSE_Fiber_Frame_Agreement__c = 10;
            oli1.Fiber_Customer_Requested_Price__c = 30;
            oli1.TeliaSE_fiber_Rabatt__c = 12;
            insert oli1;

            Test.stopTest();

            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(qut.id);
            //app.setNextApproverIds(new Id[] {UserInfo.getUserId(),m.id});
            app.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            Approval.ProcessResult result = Approval.process(app);

            ProcessInstance ps = [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate, createdby.TeliaSE_Role_based_Approver__c,
                (SELECT ID FROM WorkItems),
                (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance limit 1
            ];

            ProcessInstanceWorkitem workitemid = ps.WorkItems[0];

            //FiberProcessInstanceCustomController.getQuoteLineItem(workitemid.id);
            //FiberProcessInstanceCustomController.getQuoteEbit(workitemid.id);

			MC_QuoteApprovalTable.approvalInfo(String.valueOf(workitemid.id)); 

        }
    }


     @isTest
    public static void resposewrapper_Test(){
        String JsonResponse = '{"DR_QuoteInfoCampign":{"QLI":[{"Child":[{"Code":"MOB_MULTI_15_V2","Name":"Jobbmobil 15 GB","OTC":0,"SubsidisedVoice":"Yes","RCSalesManagerMandate":319,"RCSalesDirectorMandate":269,"RCCommercialManagerMandate":269,"Campaign":"2 fria månader","RCSalesRepMandate":379,"RCFloorPrice":379,"CommitmentPeriod":"24 months","BaseQuantity":21,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTCommercialManagerMandate":0,"OTSalesRepMandate":0,"OTDefault":0,"Approver":"Säljare"}],"Code":"MOB_MULTI_ALL_IN_PLUS_V2","Name":"Mobilupplägg All-IN+","OTC":0,"SubsidisedVoice":"Yes","Minideb":"50","RCFloorPrice":0,"CommitmentPeriod":"24 months","BaseQuantity":21,"QuarantineTime":"3","OTFloorPrice":0,"OTDefault":0,"Approver":"Säljchef"}]},"DR_QuoteInfoCampignStatus":true,"DR_QuoteInfo":{"QLI":[{"Child":[{"SubsidisedVoice":"Yes","RequestedPrice":428,"RCSalesRepMandate":429,"RCSalesManagerMandate":379,"RCSalesDirectorMandate":339,"RCFloorPrice":429,"RCCommercialManagerMandate":339,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Jobbmobil 40 GB","CommitmentPeriod":"24 months","Code":"MOB_MULTI_40_V2","BaseQuantity":21,"Approver":"Säljchef"},{"SubsidisedVoice":"Yes","RequestedPrice":598,"RCSalesRepMandate":599,"RCSalesManagerMandate":549,"RCSalesDirectorMandate":529,"RCFloorPrice":599,"RCCommercialManagerMandate":529,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Jobbmobil Obegränsad","CommitmentPeriod":"24 months","Code":"MOB_MULTI_OBEGRANSAD_V2","BaseQuantity":21,"Approver":"Säljchef"},{"SubsidisedVoice":"Yes","RequestedPrice":38,"RCSalesRepMandate":39,"RCSalesManagerMandate":10,"RCSalesDirectorMandate":0,"RCFloorPrice":39,"RCCommercialManagerMandate":0,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Jobbmobil Datasim","CommitmentPeriod":"24 months","Code":"MOB_MULTI_DATASIM_OFFER","BaseQuantity":21,"Approver":"Säljchef"},{"SubsidisedVoice":"Yes","RequestedPrice":58,"RCSalesRepMandate":59,"RCSalesManagerMandate":49,"RCSalesDirectorMandate":45,"RCFloorPrice":59,"RCCommercialManagerMandate":45,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"E-sim Klocka","CommitmentPeriod":"24 months","Code":"MOB_MULTI_E-SIM","BaseQuantity":21,"Approver":"Säljchef"}],"SubsidisedVoice":"Yes","RCFloorPrice":0,"QuarantineTime":"3","OTFloorPrice":0,"OTDefault":0,"OTC":0,"Name":"Mobilupplägg All-IN+","Minideb":"50","CommitmentPeriod":"24 months","Code":"MOB_MULTI_ALL_IN_PLUS_V2","BaseQuantity":21,"Approver":"Säljchef"},{"Child":[{"RequestedPercentage":6,"RCSalesRepMandate":86,"RCSalesManagerMandate":82,"RCSalesDirectorMandate":77,"RCFloorPrice":86,"RCCommercialManagerMandate":77,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Microsoft 365-applikationer","CommitmentPeriod":"12 months","Code":"C-BUS-OFFER","BaseQuantity":121,"Approver":"Säljchef"},{"RequestedPercentage":6,"RCSalesRepMandate":42,"RCSalesManagerMandate":40,"RCSalesDirectorMandate":37,"RCFloorPrice":42,"RCCommercialManagerMandate":37,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"365 Business Basic","CommitmentPeriod":"12 months","Code":"C-BUS-ESSEN-OFFER","BaseQuantity":121,"Approver":"Säljchef"}],"RCFloorPrice":0,"OTFloorPrice":0,"OTDefault":0,"OTC":0,"Name":"Office 365","CommitmentPeriod":"12 months","Code":"C-OFFICE-365","BaseQuantity":121},{"Child":[{"RCSalesRepMandate":29,"RCSalesManagerMandate":19,"RCSalesDirectorMandate":19,"RCFloorPrice":29,"RCCommercialManagerMandate":0,"OTSalesRepMandate":150,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":150,"OTDefault":299,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Softphone","CommitmentPeriod":"12 months","Code":"TP-SOFT-PHN","BaseQuantity":121,"Approver":"Säljchef"}],"RCFloorPrice":0,"QuarantineTime":"3","OTFloorPrice":0,"OTDefault":0,"OTC":0,"Name":"Touchpoint","Minideb":"75","CommitmentPeriod":"12 months","Code":"TP_OFFER","BaseQuantity":121}]}}';
    	Map<String,Object> inMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> optionsMap = new Map<String,Object>();
        MC_QuoteApprovalTable qat = new MC_QuoteApprovalTable();
        qat.invokeMethod('responseWrapper',inMap,outMap,optionsMap);
    }
    
    @isTest
    public static void resposewrapper_Test1(){
        String JsonResponse = '{"DR_QuoteInfoCampign":{"QLI":[{"Child":[{"Code":"MOB_MULTI_15_V2","Name":"Jobbmobil 15 GB","OTC":0,"SubsidisedVoice":"Yes","RCSalesManagerMandate":319,"RCSalesDirectorMandate":269,"RCCommercialManagerMandate":269,"Campaign":"2 fria månader","RCSalesRepMandate":379,"RCFloorPrice":379,"CommitmentPeriod":"24 months","BaseQuantity":21,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTCommercialManagerMandate":0,"OTSalesRepMandate":0,"OTDefault":0,"Approver":"Säljare"}],"Code":"MOB_MULTI_ALL_IN_PLUS_V2","Name":"Mobilupplägg All-IN+","OTC":0,"SubsidisedVoice":"Yes","Minideb":"50","RCFloorPrice":0,"CommitmentPeriod":"24 months","BaseQuantity":21,"QuarantineTime":"3","OTFloorPrice":0,"OTDefault":0,"Id":"101","Approver":"Säljchef"}]},"DR_QuoteInfoCampignStatus":true,"RA_QuoteInfo":{"QLI":[{"Child":[{"SubsidisedVoice":"Yes","RequestedPrice":428,"RCSalesRepMandate":429,"RCSalesManagerMandate":379,"RCSalesDirectorMandate":339,"RCFloorPrice":429,"RCCommercialManagerMandate":339,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Jobbmobil 40 GB","CommitmentPeriod":"24 months","Code":"MOB_MULTI_40_V2","BaseQuantity":21,"Approver":"Säljchef"},{"SubsidisedVoice":"Yes","RequestedPrice":598,"RCSalesRepMandate":599,"RCSalesManagerMandate":549,"RCSalesDirectorMandate":529,"RCFloorPrice":599,"RCCommercialManagerMandate":529,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Jobbmobil Obegränsad","CommitmentPeriod":"24 months","Code":"MOB_MULTI_OBEGRANSAD_V2","BaseQuantity":21,"Approver":"Säljchef"},{"SubsidisedVoice":"Yes","RequestedPrice":38,"RCSalesRepMandate":39,"RCSalesManagerMandate":10,"RCSalesDirectorMandate":0,"RCFloorPrice":39,"RCCommercialManagerMandate":0,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Jobbmobil Datasim","CommitmentPeriod":"24 months","Code":"MOB_MULTI_DATASIM_OFFER","BaseQuantity":21,"Approver":"Säljchef"},{"SubsidisedVoice":"Yes","RequestedPrice":58,"RCSalesRepMandate":59,"RCSalesManagerMandate":49,"RCSalesDirectorMandate":45,"RCFloorPrice":59,"RCCommercialManagerMandate":45,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"E-sim Klocka","CommitmentPeriod":"24 months","Code":"MOB_MULTI_E-SIM","BaseQuantity":21,"Approver":"Säljchef"}],"SubsidisedVoice":"Yes","RCFloorPrice":0,"QuarantineTime":"3","OTFloorPrice":0,"OTDefault":0,"OTC":0,"Name":"Mobilupplägg All-IN+","Minideb":"50","CommitmentPeriod":"24 months","Code":"MOB_MULTI_ALL_IN_PLUS_V2","BaseQuantity":21,"Id":"101","Approver":"Säljchef"},{"Child":[{"RequestedPercentage":6,"RCSalesRepMandate":86,"RCSalesManagerMandate":82,"RCSalesDirectorMandate":77,"RCFloorPrice":86,"RCCommercialManagerMandate":77,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Microsoft 365-applikationer","CommitmentPeriod":"12 months","Code":"C-BUS-OFFER","BaseQuantity":121,"Approver":"Säljchef"},{"RequestedPercentage":6,"RCSalesRepMandate":42,"RCSalesManagerMandate":40,"RCSalesDirectorMandate":37,"RCFloorPrice":42,"RCCommercialManagerMandate":37,"OTSalesRepMandate":0,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":0,"OTDefault":0,"OTCommercialManagerMandate":0,"OTC":0,"Name":"365 Business Basic","CommitmentPeriod":"12 months","Code":"C-BUS-ESSEN-OFFER","BaseQuantity":121,"Approver":"Säljchef"}],"RCFloorPrice":0,"OTFloorPrice":0,"OTDefault":0,"OTC":0,"Name":"Office 365","CommitmentPeriod":"12 months","Code":"C-OFFICE-365","Id":"102","BaseQuantity":121},{"Child":[{"RCSalesRepMandate":29,"RCSalesManagerMandate":19,"RCSalesDirectorMandate":19,"RCFloorPrice":29,"RCCommercialManagerMandate":0,"OTSalesRepMandate":150,"OTSalesManagerMandate":0,"OTSalesDirectorMandate":0,"OTFloorPrice":150,"OTDefault":299,"OTCommercialManagerMandate":0,"OTC":0,"Name":"Softphone","CommitmentPeriod":"12 months","Code":"TP-SOFT-PHN","BaseQuantity":121,"Approver":"Säljchef"}],"RCFloorPrice":0,"QuarantineTime":"3","OTFloorPrice":0,"OTDefault":0,"OTC":0,"Name":"Touchpoint","Minideb":"75","CommitmentPeriod":"12 months","Code":"TP_OFFER","Id":"103","BaseQuantity":121}]}}';
    	Map<String,Object> inMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> optionsMap = new Map<String,Object>();
        MC_QuoteApprovalTable qat = new MC_QuoteApprovalTable();
        qat.invokeMethod('responseWrapper',inMap,outMap,optionsMap);
        qat.invokeMethod('abcDummy',inMap,outMap,optionsMap);
    }


}