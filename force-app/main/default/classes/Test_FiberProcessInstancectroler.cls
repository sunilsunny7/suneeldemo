@isTest
/*
Created by P.S on Sep-2020
----
Covers Class - FiberProcessInstanceCustomController
*/
private class Test_FiberProcessInstancectroler {
    @isTest
    public static void getqliisTest() {
        User salesManager;
        User salesManager2;
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();


        System.runAs(new User(Id = Userinfo.getUserId())) {
            salesManager2 = Test_DataFactory.createFiberUser();
            salesManager2.Bypass_VR__c = true;
            SalesManager2.Telia_Id__c = '32312231';

            insert salesManager2;
            salesManager = Test_DataFactory.createFiberUser();
            salesManager.Bypass_VR__c = true;
            salesManager.managerID = salesManager2.id;
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
            Approval.ProcessResult result = Approval.process(app);

            ProcessInstance ps = [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate, createdby.TeliaSE_Role_based_Approver__c,
                (SELECT ID FROM WorkItems),
                (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance limit 1
            ];

            ProcessInstanceWorkitem workitemid = ps.WorkItems[0];
            FiberProcessInstanceCustomController.getQuoteLineItem(workitemid.id);
            FiberProcessInstanceCustomController.getQuoteEbit(workitemid.id);


        }
    }
}