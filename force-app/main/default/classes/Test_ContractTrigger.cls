@IsTest(seeallData=false)
public class Test_ContractTrigger {
    @TestSetup
    static void testDataSetup() {
        User byPassUser = Test_DataFactory.getByPassUser();
        System.runAs(byPassUser) {
            User user = Test_DataFactory.createFiberUser();
            insert user;
            Account acc = Test_DataFactory.createOneSMEAccount();
            acc.Org_Nr__c = '1234567890';
            acc.OwnerId = user.Id;
            insert acc;
            
            Test.startTest();
            Contract contract = new Contract();
            contract.Name = 'Test Contract';
            contract.Agreement_KO_nr__c = '01234567';
            contract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
            contract.AccountId = acc.Id;
            contract.Status = 'Draft';
            contract.OwnerId = user.Id;
            insert contract;
            Test.stopTest();
        }
    }
    
    // This test verifies the basic functionality of the Contract Trigger
    static testmethod void batchContractTest() {
        
        Expire_Notification__c exp = new Expire_Notification__c(name = 'Large_Sales_Organisation_Account', Days__c = 2, RecordTypeDeveloper__c = SEUtility.ACC_RECTYPE_LARGE, Months__c = 8);
        insert exp;
        
        Account acc = Test_DataFactory.createOneAccount();
        acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        insert acc;
        
        List<Contract> listofcontracts = new List<Contract>();
        
        Contract cont = new Contract();
        cont.Type_of_Agreement__c = 'Cygate leveransavtal';
        cont.Status = 'Draft';
        cont.AccountId = acc.Id;
        cont.ContractTerm = 36;
        cont.StartDate = system.today() - 1;
        cont.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.Contract_TELIA);
        cont.Reminder_Days_Before__c = '90';
        listofcontracts.add(cont);
        insert listofcontracts;
        cont.Status = 'Active';
        update cont;
        
        List<vlocity_cmt__ContractLineItem__c> contractLI = new List<vlocity_cmt__ContractLineItem__c>{
        };
            vlocity_cmt__ContractLineItem__c conLI = new vlocity_cmt__ContractLineItem__c(Name = 'Test', TeliaSE_End_Date__c = system.today().addDays(2),
                                                                                          vlocity_cmt__ContractId__c = listofcontracts[0].Id, TeliaSE_CommitmentPeriod__c = '123213',
                                                                                          TeliaSE_SubsidisedVoice__c = 'NA');
        contractLI.add(conLI);
        insert contractLI;
        
        Test.startTest();
        Id jobId = System.schedule('Test - Contract Batch -TEST', '00 40 * * * ?', new TeliaSE_ContractSchedulable());
        system.assert(jobId != null);
        Test.stopTest();
        
        
    }
    
    public static testmethod void no02_fiberContractExtension() {
        Test_DataFactory.setUpOrg();
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE AND Email='test1@email.com' LIMIT 1];
        
        Account acc;
            System.runAs(byPassUser) {
                acc = Test_DataFactory.createOneLargeStandardAccount();
                insert acc;
                
                Opportunity opp = new Opportunity();
                //opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_REALESTATEFIBER);
                // opp.RecordTypeId = '0121p000000wsYc';
                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
                opp.Name = 'fibopp1';
                opp.AccountId = acc.Id;
                opp.CloseDate = System.today();
                opp.StageName = '02 Offert skickad';
                insert Opp;
                
                Quote qut1 = new Quote();
                qut1.Name = 'Test fiber Quote';
                qut1.status = 'Draft';
                qut1.opportunityId = opp.id;
                insert qut1;
                
                Test.startTest();
                Contract conObj = new Contract();
                //conObj.recordtypeId = '0121p000000wsYb';
                conObj.recordtypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
                conObj.vlocity_cmt__QuoteId__c = qut1.id;
                conObj.StartDate = system.today();
                conObj.enddate = system.today() + 50;
                conObj.TeliaSE_Fiber_Installation_Date__c = system.today() + 5;
                conObj.status = 'Draft';
                conObj.accountId = acc.Id;
                insert conObj;
                
                conObj.Status = 'Signed';
                update conObj;
                conObj.Status = 'Active';
                update conObj;
                
                conObj.Fiber_Contract_Extension_Period__c = 2;
                update conObj;
                Test.stopTest();
            }
    }
    
    @isTest
    public static void no02_createandUpdateContract() {
        Test_DataFactory.setUpOrg();
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE AND Email='test1@email.com' LIMIT 1];
        
        Account acc;
        System.runAs(byPassUser) {
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'opp1';
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today();
            opp.StageName = 'Needs Analysis';
            opp.Pricebook2Id = Test.getStandardPricebookId();
            insert opp;
            
            
            Quote qut1 = new Quote();
            qut1.Name = 'Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False;
            qut1.TeliaSE_Type__c = 'Renegotiation';
            insert qut1;
            
            Test.startTest();
            Contract conObj = new Contract();
            conObj.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj.Contract_Record_Type__c = 'Ramavtal';
            conObj.TeliaSE_Parent_Agreement__c = '1234567';
            conObj.vlocity_cmt__QuoteId__c = qut1.id;
            conObj.TeliaSE_Type__c = 'Y';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.Agreement_Nr__c = '4752';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            conObj.TeliaSE_TUPP_Interface_Name__c = 'createAgreementCase';
            insert conObj;
            
            Utilizer_Contract_Relationship__c uc = new Utilizer_Contract_Relationship__c();
            uc.ContractNumber__c = conObj.id;
            uc.AccountId__c = acc.id;
            uc.Status__c = 'Draft';
            insert uc;
            
            conObj.Status = 'Signed';
            update conObj;
            conObj.TeliaSE_Type__c = 'Y';
            conObj.Status = 'Active';
            update conObj;
            
            conObj.Status = 'Cancelled';
            conObj.TeliaSE_Reason_for_Cancellation__c = 'Ok';
            update conObj;
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testCheckActiveContract() {
        Test_DataFactory.setUpOrg();
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE AND Email='test1@email.com' LIMIT 1];
        Account acc;
        
        System.runAs(byPassUser) {
            
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'opp1';
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today();
            opp.StageName = 'Needs Analysis';
            opp.Pricebook2Id = Test.getStandardPricebookId();
            insert opp;
            
            
            Quote qut1 = new Quote();
            qut1.Name = 'Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False;
            qut1.TeliaSE_Type__c = 'Renegotiation';
            insert qut1;
            
            Test.startTest();
            Contract conObj = new Contract();
            conObj.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj.Contract_Record_Type__c = 'Ramavtal';
            conObj.TeliaSE_Parent_Agreement__c = '1234567';
            conObj.vlocity_cmt__QuoteId__c = qut1.id;
            conObj.TeliaSE_Type__c = 'Y';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            conObj.TeliaSE_TUPP_Interface_Name__c = 'createAgreementCase';
            insert conObj;
            
            conObj.status = 'Active';
            update conObj;
            
            Contract conObj1 = new Contract();
            conObj1.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj1.Contract_Record_Type__c = 'Ramavtal';
            conObj1.TeliaSE_Parent_Agreement__c = '1234567';
            conObj1.vlocity_cmt__QuoteId__c = qut1.id;
            conObj1.TeliaSE_Type__c = 'Y';
            conObj1.StartDate = system.today();
            conObj1.status = 'Draft';
            conObj1.accountId = acc.Id;
            conObj1.TeliaSE_Case_Id__c = '12345';
            conObj1.TeliaSE_TUPP_Interface_Name__c = 'createAgreementCase';
            insert conObj1;
            
            conObj1.Status = 'Cancelled';
            conObj1.TeliaSE_Reason_for_Cancellation__c = 'Ok';
            update conObj1;
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void testUtilizerAccountUpdate() {
        Test_DataFactory.setUpOrg();
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE AND Email='test1@email.com' LIMIT 1];
        Account acc;
        
        System.runAs(byPassUser) {
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
            Account acc1 = Test_DataFactory.createOneLargeStandardAccount();
            acc1.Org_Nr__c = '1243576768';
            insert acc1;
            
            Account acc2 = Test_DataFactory.createOneLargeStandardAccount();
            acc2.Org_Nr__c = '1243576769';
            insert acc2;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'opp1';
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today();
            opp.StageName = 'Needs Analysis';
            opp.Pricebook2Id = Test.getStandardPricebookId();
            insert opp;
            
            
            Quote qut1 = new Quote();
            qut1.Name = 'Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False;
            qut1.TeliaSE_Type__c = 'Renegotiation';
            insert qut1;
            
            Test.startTest();
            
            Contract conObj = new Contract();
            conObj.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj.Contract_Record_Type__c = 'Ramavtal';
            conObj.TeliaSE_Parent_Agreement__c = '1234567';
            conObj.vlocity_cmt__QuoteId__c = qut1.id;
            conObj.TeliaSE_Type__c = 'Y';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            conObj.TeliaSE_TUPP_Interface_Name__c = 'createAgreementCase';
            insert conObj;
            
            Utilizer_Contract_Relationship__c uc = new Utilizer_Contract_Relationship__c();
            uc.ContractNumber__c = conObj.id;
            uc.AccountId__c = acc1.id;
            uc.Status__c = 'Aktiv';
            insert uc;
            
            
            conObj.status = 'Active';
            update conObj;
            
            Utilizer_Contract_Relationship__c uc1 = new Utilizer_Contract_Relationship__c();
            uc1.ContractNumber__c = conObj.id;
            uc1.AccountId__c = acc2.id;
            uc1.Status__c = 'PendingActive';
            insert uc1;
            
            conObj.TeliaSE_TUPP_Interface_Name__c = 'TUPPUpdateService';
            update conObj;
            test.stopTest();
        }
    }
    @isTest
    public static void cloneFunctionalityTest() {
        Test_DataFactory.setUpOrg();
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE AND Email='test1@email.com' LIMIT 1];
        Account acc;
        System.runAs(byPassUser) {
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            Opportunity opp = new Opportunity(
                Name = 'opp1',
                AccountId = acc.Id,
                CloseDate = System.today(),
                StageName = 'Needs Analysis',
                Pricebook2Id = Test.getStandardPricebookId());
            insert opp;
            
            Quote qut1 = new Quote(
                Name = 'Test Quote',
                status = 'Draft',
                opportunityId = opp.id,
                TeliaSE_Approval_Flag__c = False,
                TeliaSE_Type__c = 'Renegotiation');
            insert qut1;
            
            Contract conObj = new Contract(
                recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT),
                Contract_Record_Type__c = 'Ramavtal',
                TeliaSE_Parent_Agreement__c = '1234567',
                vlocity_cmt__QuoteId__c = qut1.id,
                TeliaSE_Type__c = 'Y',
                StartDate = system.today(),
                status = 'Draft',
                accountId = acc.Id,
                TeliaSE_Case_Id__c = '12345',
                TeliaSE_TUPP_Interface_Name__c = 'createAgreementCase');
            insert conObj;
            conObj.Status = 'Active';
            update conObj;
            
            vlocity_cmt__ContractLineItem__c conLineItem = new vlocity_cmt__ContractLineItem__c(
                name = 'TEST',
                vlocity_cmt__ContractId__c = conObj.id
            );
            insert conLineItem;
            Test.StartTest();
            Contract clonedConObj = conObj.Clone(false, true, false, false);
            insert clonedConObj;
            Test.StopTest();
            String clonedDraft = [SELECT Status FROM Contract WHERE id = :clonedConObj.id].Status;
            System.assertEquals('Draft', String.valueOf(clonedDraft), 'Status do not change to Draft!');
            List<vlocity_cmt__ContractLineItem__c> clonedContractLineItems = [SELECT id FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ContractId__c = :clonedConObj.id];
            //System.assertEquals(1, clonedContractLineItems.size(), 'Contract Line Items wasn\'t cloned!');
            
        }
    }
    @IsTest
    public static void testTypeOfAddressInsert() {
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE AND Email='test1@email.com' LIMIT 1];
        
        System.runAs(byPassUser) {
            Account acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'opp1';
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today();
            opp.StageName = 'Needs Analysis';
            opp.Pricebook2Id = Test.getStandardPricebookId();
            opp.RecordTypeId = '0121p000000wsYcAAI';
            insert opp;
            
            Quote qut1 = new Quote();
            qut1.Name = 'Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False;
            qut1.TeliaSE_Type__c = 'Renegotiation';
            insert qut1;
            qut1.TeliaSE_Type__c = null;
            update qut1;
            
            Test.startTest();
            
            Contract conObj = new Contract();
            conObj.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj.Contract_Record_Type__c = 'Ramavtal';
            conObj.TeliaSE_Parent_Agreement__c = '1234567';
            conObj.vlocity_cmt__QuoteId__c = qut1.id;
            conObj.TeliaSE_Type__c = 'Renegotiation';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            conObj.vlocity_cmt__OpportunityId__c = opp.Id;
            insert conObj;
            
            Test.stopTest();
            system.assertEquals(opp.Type_of_Address__c, conObj.Type_of_Address__c, 'Contract\'s Type Of Address doesn\'t match Opportunity');
            
        }
    }
    @IsTest
    public static void testTypeOfAddressUpdate() {
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE AND Email='test1@email.com' LIMIT 1];
        
        System.runAs(byPassUser) {
            Account acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'opp1';
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today();
            opp.StageName = 'Needs Analysis';
            opp.Pricebook2Id = Test.getStandardPricebookId();
            opp.RecordTypeId = '0121p000000wsYcAAI';
            insert opp;
            
            
            Quote qut1 = new Quote();
            qut1.Name = 'Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False;
            qut1.TeliaSE_Type__c = 'Renegotiation';
            insert qut1;
            qut1.TeliaSE_Type__c = null;
            update qut1;
            
            Test.startTest();
            
            Contract conObj = new Contract();
            conObj.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj.Contract_Record_Type__c = 'Ramavtal';
            conObj.TeliaSE_Parent_Agreement__c = '1234567';
            conObj.vlocity_cmt__QuoteId__c = qut1.id;
            conObj.TeliaSE_Type__c = 'Renegotiation';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_Case_Id__c = '12345';
            
            insert conObj;
            conObj.vlocity_cmt__OpportunityId__c = opp.Id;
            
            update conObj;
            
            Test.stopTest();
            system.assertEquals(opp.Type_of_Address__c, conObj.Type_of_Address__c, 'Contract\'s Type Of Address doesn\'t match Opportunity');
            
        }
    }
    
    @IsTest
    public static void testDataFlowToOppAndQuote() {
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE AND Email='test1@email.com' LIMIT 1];
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
        Test_DataFactory.setUpOrg();
        Account acc;
        List<Opportunity> opps;
        User salesRep;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        System.runAs(byPassUser) {
            
            Test.startTest();
            salesRep = Test_DataFactory.createFiberUser();
            salesRep.Bypass_VR__c = true;
            insert salesRep;
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
            Opportunity opp= new Opportunity();
            opp = Test_DataFactory.createOpportunity();
            opp.RecordtypeId='0121p000000wsYc';
            opp.OwnerId=salesRep.Id;
            opp.StageName='01 Prospect';
            opp.Revenue_NS__c=0;
            opp.Revenue_CS__c=0;
            opp.Number_of_Households__c = 1;
            opp.Number_of_other_Ports__c = 1;
            opp.Number_of_Ports__c = 1;
            opp.Number_of_Premises__c = 1;
            opp.Number_of_Households__c=2; 
            opp.Number_of_other_Ports__c=2;
            opp.Number_of_Ports__c=2;
            opp.Number_of_Premises__c=2;
            opp.Wished_delivery_date_not_guaranteed__c=Date.Today();
            opp.Number_of_Facilities__c=2;
            insert opp;
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.Recordtypeid   = SEUTility.getRecordTypeId('Individual_Quote');
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.TeliaSE_Fiber_EBIT_Percentage__c = 26;
            qut.TeliaSE_Fiber_Number_of_Households__c=2; 
            qut.TeliaSE_Fiber_Number_of_Ports__c=2;
            qut.TeliaSE_Fiber_Number_of_Premises__c=2;
            qut.Wished_delivery_date_not_guaranteed__c=Date.Today(); 
            qut.TeliaSE_Fiber_Number_of_Facilities__c=2;
            insert qut;
            
            Contract conObj = new Contract();
            conObj.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
            conObj.vlocity_cmt__QuoteId__c=qut.id;
            conobj.vlocity_cmt__OpportunityId__c=opp.Id;
            conObj.StartDate = system.today();
            conObj.enddate = system.today()+50;
            conObj.TeliaSE_Fiber_Installation_Date__c = system.today()+5;
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            insert conObj;
            
            conObj.Number_of_Households__c = 2;
            //conObj.Number_of_other_Ports__c = 2;
            conObj.Number_of_Ports__c = 2;
            conObj.Number_of_Premises__c = 2;
            conObj.Number_of_Facilities__c = 2;
            conObj.Wished_delivery_date_not_guaranteed__c = Date.Today();
            
            update conObj;
            Test.stopTest();
            
            Opportunity updatedOpportunity = [SELECT Number_of_Households__c, Number_of_other_Ports__c,Number_of_Ports__c, Number_of_Premises__c,Wished_delivery_date_not_guaranteed__c,Number_of_Facilities__c FROM Opportunity];
            Quote updatedQuote = [SELECT TeliaSE_Fiber_Number_of_Households__c, Number_of_other_Ports__c, TeliaSE_Fiber_Number_of_Ports__c, TeliaSE_Fiber_Number_of_Premises__c,Wished_delivery_date_not_guaranteed__c, TeliaSE_Fiber_Number_of_Facilities__c FROM Quote];
            
            System.assertEquals(2, updatedQuote.TeliaSE_Fiber_Number_of_Households__c, 'Quote wasn\'t updated number of households');
            //System.assertEquals(2, updatedQuote.Number_of_other_Ports__c, 'Quote wasn\'t updated number of other ports');
            System.assertEquals(2, updatedQuote.TeliaSE_Fiber_Number_of_Ports__c, 'Quote wasn\'t updated number of ports');
            System.assertEquals(2, updatedQuote.TeliaSE_Fiber_Number_of_Premises__c, 'Quote wasn\'t updated number of premises');
            System.assertEquals(2, updatedQuote.TeliaSE_Fiber_Number_of_Facilities__c, 'Quote wasn\'t updated number of Facilities');
            System.assertEquals(Date.Today(), updatedQuote.Wished_delivery_date_not_guaranteed__c, 'Quote wasn\'t updated Wished delivery date not guarenateeed');
            System.assertEquals(2, updatedOpportunity.Number_of_Households__c, 'Opportunity wasn\'t updated number of households');
            //System.assertEquals(2, updatedOpportunity.Number_of_other_Ports__c, 'Opportunity wasn\'t updated number of other ports');
            System.assertEquals(2, updatedOpportunity.Number_of_Ports__c, 'Opportunity wasn\'t updated number of ports');
            System.assertEquals(2, updatedOpportunity.Number_of_Premises__c, 'Opportunity wasn\'t updated number of premises');
            System.assertEquals(2, updatedOpportunity.Number_of_Facilities__c, 'Opportunity wasn\'t updated number of facilites');
            System.assertEquals(Date.Today(), updatedOpportunity.Wished_delivery_date_not_guaranteed__c, 'Opportunity wasn\'t updated Wished delivery date not guarenateeed');
        }
    }
    
    @IsTest
    public static void updateCSMExistingCustomerValue_UpdateToActive_Test() {
        Contract testContract = [SELECT Id, Status FROM Contract LIMIT 1];
        
        Test.startTest();
        testContract.Status = 'Active';
        update testContract;
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, C_SM_Existing_Customer__c FROM Account LIMIT 1];
        
        //System.assertEquals(true, updatedAccount.C_SM_Existing_Customer__c, 'C&SM Existing Customer value was not updated on Account');
    }
   /* @IsTest
    public static void updateCSMExistingCustomerValue_UpdateToInactive_Test() {
        Contract testContract = [SELECT Id, Status FROM Contract LIMIT 1];
        testContract.Status = 'Active';
        update testContract;
        
        Test.startTest();
        testContract.Status = 'Draft';
        update testContract;
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, C_SM_Existing_Customer__c FROM Account LIMIT 1];
        
        System.assertEquals(false, updatedAccount.C_SM_Existing_Customer__c, 'C&SM Existing Customer value was not updated on Account');
    }*/
    @IsTest
    public static void updateCSMExistingCustomerValue_Delete_Test() {
        Contract testContract = [SELECT Id, Status FROM Contract LIMIT 1];
        testContract.Status = 'Active';
        update testContract;
        
        Test.startTest();
        delete testContract;
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, C_SM_Existing_Customer__c FROM Account LIMIT 1];
        
        System.assertEquals(false, updatedAccount.C_SM_Existing_Customer__c, 'C&SM Existing Customer value was not updated on Account');
    }
    @isTest
    public static void Email_Trigger() {
        Test_DataFactory.setUpOrg();
        User byPassUser = [SELECT Id FROM User WHERE Bypass_VR__c = TRUE AND Email='test1@email.com' LIMIT 1];
        Account acc1;
        System.runAs(byPassUser) {
            acc1 = Test_DataFactory.createOneLargeStandardAccount();
            insert acc1;
            Opportunity opp1 = new Opportunity(
                Name = 'opp1',
                AccountId = acc1.Id,
                CloseDate = System.today(),
                StageName = 'Needs Analysis',
                Pricebook2Id = Test.getStandardPricebookId());
            insert opp1;
            
            Product2 prod = new Product2();
            prod.Name = 'Smart Connect';
            prod.ProductCode ='SC_TRAINING_GUIDED';
            insert prod;
            
            Quote quote = new Quote(
                Name = 'Test Quote',
                status = 'Draft',
                opportunityId = opp1.id,
                TeliaSE_Approval_Flag__c = False,
                TeliaSE_Type__c = 'Renegotiation',
                Pricebook2Id = Test.getStandardPricebookId());
            insert quote;
            
            Id stdPriceBookRecId = Test.getStandardPricebookId();
            
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod.id;
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            insert objpricebookentry1;
            
            QuoteLineItem oli = new QuoteLineItem();
            oli.quoteid=quote.id;
            oli.TeliaSE_MC_FACallOffQuantity__c=2;
            oli.PricebookEntryId = objpricebookentry1.Id;
            oli.UnitPrice = 200;
            oli.Quantity = 4;
            oli.Product2Id = prod.id;
            insert oli;
            
            Contract contract = new Contract(
                recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT),
                Contract_Record_Type__c = 'Ramavtal',
                TeliaSE_Parent_Agreement__c = '1234567',
                vlocity_cmt__QuoteId__c = quote.id,
                TeliaSE_Type__c = 'Y',
                StartDate = system.today(),
                status = 'Draft',
                accountId = acc1.Id,
                TeliaSE_Case_Id__c = '12345');
            insert contract;
            
            vlocity_cmt__ContractLineItem__c conLineItem = new vlocity_cmt__ContractLineItem__c(
                Name = 'TEST',
                vlocity_cmt__QuoteLineItem__c=oli.id,
                vlocity_cmt__Product2Id__c=prod.id,
                TeliaSE_Product_Object_Type__c='Smart Connect Offer Spec',
                vlocity_cmt__ContractId__c = contract.id);
            insert conLineItem;
            
            Test.StartTest();
            contract.status = 'Signed';
            contract.Agreement_Nr__c = '123456';
            update contract;
            Test.StopTest();
        }
    }
}