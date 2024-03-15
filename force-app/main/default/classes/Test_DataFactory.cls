/**
    About
    -----
    Description: Data Factory for test classes
    Create date: March 2015
     
    Update History
    --------------
    Created Mar 2015 - V.I
    Updated Apr 2016 - P.P Changes for Sales Value 
    
    Updated May 2016 - S.S changes in user role
    Updated Sep 2016 - A.N New method createCygateCampaign. Changed method createCygateEvent so that a Campaign is added, since otherwise we will get validation error.
    Updated Feb 2017 - SAEN-2196 createAdmin method updated with bypass_validation = true, so we can bypass the new account validation "Validation when users in Salesforce create SoHo accounts".
    Updated May 2017 - P.P Case 3081 - new methods created - createLargeRenewalUser() & createLargeRenewalUserTeam()
    Updates Jun 2017 - Case # 3410 - Email field is mandatory, thus when a Contact is created we need to add email Also, Role will be mandatory for all Customer Contact.
                     - Case # 3094 - First Name is mandatory for all Customer Contact.
    Updated Apr 2018 - Y.K SALEF-919 Change phasing of New Sales targets for SOHO Sales
    Updated Apr 2018 - Y.K SALEF-971,977 Update Mobile subscription
    Issues / TODOs
    --------------  

*/

@isTest
public class Test_DataFactory {
    public static String OLI_SALES_PURPOSE_NEW_SALES = 'New Sales - Nya tjänster';
    public static String OLI_SALES_PURPOSE_CONT_SALES = 'Continuation Sales - Migrering av tjänst';
    public static String OLI_SALES_TYPE_NEW_SALES = 'Cygate New Sales';
    public static String OLI_SALES_TYPE_CONT_SALES = 'Cygate Continuation Sales';
    public static final String ROLE_DEV_NAME_VALID_SME = System.Label.ROLE_DEV_NAME_VALID_SME_SALES;

    static boolean setUpOrg_done = false;
    static final String localesidkeyStr = 'sv';
    static final String languagelocalekeyStr = 'sv';
    static final String emailencodingkeyStr = 'UTF-8';
    static final String emailStr = 'chgustaf@gmail.com';
    static final String timezonesidkeyStr = 'Europe/Berlin';
    private static Integer autoNumber = 0;
    static Integer salesUnitCounter = 0;
    static Integer salesTeamCounter = 0;

    public static void setUpOrg() {
        if (!setUpOrg_done) {
            // Put in to this method all those standard items that would normally be loaded by default, ex custom settings
            createSalesTargetDistribution();
            createCampaignTypevsMemberStatuses();
            createCampaignMemberStatuses();
            createDisabledTriggers();
            createCommitViewRoles();
            createExcludedRecords();
            createTeliaSFUserContactRoles();
            createTeliaCygateAccounts();
        }
        setUpOrg_done = true;
    }

    //Create custom setting Roles for SME Commit View
    public static void createCommitViewRoles() {
        SMECommit__c smec = new SMECommit__c();
        List<UserRole> lstUserRoles = [SELECT Id, Name FROM UserRole WHERE DeveloperName = :ROLE_DEV_NAME_VALID_SME];
        if (!lstUserRoles.isEmpty()) {
            smec.Name = lstUserRoles[0].Name;
            smec.RoleID__c = lstUserRoles[0].Id;
            insert smec;
        }
    }

    //Create custom setting Sales Target Distribution
    public static void createSalesTargetDistribution() {
        Sales_Target_Distribution__c std = new Sales_Target_Distribution__c();
        std.Name = 'Main';
        std.X1st_Quarter_Sales_Weight__c = 20;
        std.X2nd_Quarter_Sales_Weight__c = 30;
        std.X3rd_Quarter_Sales_Weight__c = 15;
        std.X4th_Quarter_Sales_Weight__c = 35;
        insert std;

        Sales_Target_Distribution__c std1 = new Sales_Target_Distribution__c(); //Added by YK for salef-919
        std1.Name = 'SOHO_NewSalesTarget';
        std1.X1st_Quarter_Sales_Weight__c = 25;
        std1.X2nd_Quarter_Sales_Weight__c = 25;
        std1.X3rd_Quarter_Sales_Weight__c = 25;
        std1.X4th_Quarter_Sales_Weight__c = 25;
        insert std1;
    }

    //Create custom setting Campaign Type vs Member Statuses Detail
    public static void createCampaignTypevsMemberStatuses() {
        List<Campaign_Type_vs_Member_Statuses__c> ctMsList = new List<Campaign_Type_vs_Member_Statuses__c>();

        Campaign_Type_vs_Member_Statuses__c event = new Campaign_Type_vs_Member_Statuses__c(Record_Type__c = SEUtility.CAMPAIGN_RECTYPE_TELIA);
        event.Name = 'Evenemang';
        event.Campaign_Type__c = 'Evenemang';
        event.Member_Status_Set__c = 'Mejlkampanj';
        ctMsList.add(event);

        Campaign_Type_vs_Member_Statuses__c interest = new Campaign_Type_vs_Member_Statuses__c(Record_Type__c = SEUtility.CAMPAIGN_RECTYPE_TELIA);
        interest.Name = 'Intresse';
        interest.Campaign_Type__c = 'Intresse';
        interest.Member_Status_Set__c = 'Intressekampanj';
        ctMsList.add(interest);

        Campaign_Type_vs_Member_Statuses__c mail = new Campaign_Type_vs_Member_Statuses__c(Record_Type__c = SEUtility.CAMPAIGN_RECTYPE_TELIA);
        mail.Name = 'Mejl';
        mail.Campaign_Type__c = 'Mejl';
        mail.Member_Status_Set__c = 'Mejlkampanj';
        ctMsList.add(mail);

        Campaign_Type_vs_Member_Statuses__c phone = new Campaign_Type_vs_Member_Statuses__c(Record_Type__c = SEUtility.CAMPAIGN_RECTYPE_TELIA);
        phone.Name = 'Telefon';
        phone.Campaign_Type__c = 'Telefon';
        phone.Member_Status_Set__c = 'Telefonkampanj';
        ctMsList.add(phone);

        Campaign_Type_vs_Member_Statuses__c apsis = new Campaign_Type_vs_Member_Statuses__c(Record_Type__c = SEUtility.CAMPAIGN_RECTYPE_TELIA);
        apsis.Name = 'Apsis';
        apsis.Campaign_Type__c = 'Apsis';
        apsis.Member_Status_Set__c = 'Apsiskampanj';
        ctMsList.add(apsis);

        Campaign_Type_vs_Member_Statuses__c other = new Campaign_Type_vs_Member_Statuses__c(Record_Type__c = SEUtility.CAMPAIGN_RECTYPE_TELIA);
        other.Name = 'Annan';
        other.Campaign_Type__c = 'Annan';
        other.Member_Status_Set__c = 'Annan Kampanj';
        ctMsList.add(other);

        insert ctMsList;
    }

    //Create custom setting Campaign Member Statuses
    public static void createCampaignMemberStatuses() {
        List<Campaign_Member_Statuses__c> cmsList = new List<Campaign_Member_Statuses__c>();

        Campaign_Member_Statuses__c interest = new Campaign_Member_Statuses__c();
        interest.Name = 'Intressekampanj';
        interest.Status_1_Name__c = 'Visat intresse';
        interest.Status_2_Name__c = 'Beställt';
        interest.Status_1_Default__c = true;
        interest.Status_2_Responded__c = true;
        cmsList.add(interest);

        Campaign_Member_Statuses__c mail = new Campaign_Member_Statuses__c();
        mail.Name = 'Mejlkampanj';
        mail.Status_1_Name__c = 'Ej skickat555';
        mail.Status_2_Name__c = 'Skickat';
        mail.Status_1_Default__c = true;
        mail.Status_2_Responded__c = true;
        cmsList.add(mail);

        Campaign_Member_Statuses__c phone = new Campaign_Member_Statuses__c();
        phone.Name = 'Telefonkampanj';
        phone.Status_1_Name__c = 'Ej Ringt';
        phone.Status_2_Name__c = 'Ringt - Ospecifierat';
        phone.Status_1_Default__c = true;
        phone.Status_2_Responded__c = true;
        cmsList.add(phone);

        Campaign_Member_Statuses__c apsis = new Campaign_Member_Statuses__c();
        apsis.Name = 'Apsiskampanj';
        apsis.Status_1_Name__c = 'Ej Skickat';
        apsis.Status_2_Name__c = 'Ringt';
        apsis.Status_1_Default__c = true;
        apsis.Status_2_Responded__c = true;
        cmsList.add(apsis);

        Campaign_Member_Statuses__c other = new Campaign_Member_Statuses__c();
        other.Name = 'Annan Kampanj';
        other.Status_1_Name__c = 'Testing1';
        other.Status_2_Name__c = 'Testing2';
        other.Status_1_Default__c = true;
        other.Status_2_Responded__c = true;
        cmsList.add(other);

        insert cmsList;
    }

    //Create Disabled Triggers
    public static void createDisabledTriggers() {
        Disabled_Triggers__c disabledTriggers = new Disabled_Triggers__c();
        insert disabledTriggers;
    }

    //Create custom setting Excluded Records
    public static void createExcludedRecords() {
        List<ExcludedRecords__c> exclList = new List<ExcludedRecords__c>();

        ExcludedRecords__c exclRecords1 = new ExcludedRecords__c();
        exclRecords1.Name = 'AcntRollUpExcludedRecords';
        exclRecords1.Excluded_records_list__c = '00124000008eLMb';
        exclRecords1.Description__c = 'Test';
        exclList.add(exclRecords1);

        ExcludedRecords__c exclRecords2 = new ExcludedRecords__c();
        exclRecords2.Name = 'actExcludedAccounts';
        exclRecords2.Excluded_records_list__c = '00124000008eLPR';
        exclRecords2.Description__c = 'Test';
        exclList.add(exclRecords2);

        ExcludedRecords__c exclRecords3 = new ExcludedRecords__c();
        exclRecords3.Name = 'excludedAccsATMhandler';
        exclRecords3.Description__c = 'Test';
        exclRecords3.Excluded_records_list__c = '00124000008eLMY';
        exclList.add(exclRecords3);
        insert exclList;
    }

    //Create custom setting Telia_SF_User_Contact_Roles
    public static void createTeliaSFUserContactRoles() {
        List<Telia_SF_User_Contact_Roles__c> userRoleList = new List<Telia_SF_User_Contact_Roles__c>();
        userRoleList.add(new Telia_SF_User_Contact_Roles__c(Name = 'SOHO:Chef'));
        userRoleList.add(new Telia_SF_User_Contact_Roles__c(Name = 'Large Director'));
        userRoleList.add(new Telia_SF_User_Contact_Roles__c(Name = 'Solutions Director'));
        userRoleList.add(new Telia_SF_User_Contact_Roles__c(Name = 'SME Säljdirektör'));
        userRoleList.add(new Telia_SF_User_Contact_Roles__c(Name = 'Finance'));
		insert userRoleList;
    }

    public static void createTeliaCygateAccounts() {
        List<Account> accList = new List<Account>();

        Account acc1 = new Account();
        acc1.Name = 'Cygate Internal AB';
        acc1.Org_Nr__c = label.Account_Org_N;
        acc1.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        acc1.Telia_Service_Manager__c = userInfo.getUserId();
        accList.add(acc1);

        Account acc2 = new Account();
        acc2.Name = 'Telia Internal AB';
        acc2.Org_Nr__c = label.Account_Org_Nr_Telia;
        acc2.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
        acc2.Telia_Service_Manager__c = userInfo.getUserId();
        accList.add(acc2);

        insert accList;
    }

    public static void createPriceBooks() {
        List<Pricebook2> pbList = new List<Pricebook2>();

        pbList.add(new Pricebook2(Name = 'Standard Price Book', Developer_Name__c = SEUtility.PRICEBOOK_TELIA, isActive = true));
        pbList.add(new Pricebook2(Name = 'Telia Price Book', Developer_Name__c = SEUtility.PRICEBOOK_TELIA_NEW, isActive = true));

        pbList.add(new Pricebook2(Name = 'Cygate Price Book', Developer_Name__c = SEUtility.PRICEBOOK_CYGATE, isActive = true));
        pbList.add(new Pricebook2(Name = 'SOHO PR Price Book', Developer_Name__c = SEUtility.PRICEBOOK_SOHO_PR, isActive = true));
        pbList.add(new Pricebook2(Name = 'Telia-Cygate Joint Price Book', Developer_Name__c = SEUtility.PRICEBOOK_JOINT, isActive = true));

        insert pbList;
    }

    //Create one Account
    public static Account createOneAccount() {
        Account a = new Account(Name = 'TestAccount');

        return a;
    }

    //Create one SME/SOHO Account
    public static Account createOneSMEAccount() {
        Account a = new Account(Name = 'TestAccount');
        a.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME);
        return a;
    }

    //Create one Large Account
    public static Account createOneLargeStandardAccount() {
        Account a = createOneAccount();
        a.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);

        return a;
    }

    // Create one Cygate Account (currently this is the same as large account)
    public static Account createOneCygateAccount() {
        return createOneCygateAccount(null, null);
    }

    // Create one Cygate Account (currently this is the same as large account)
    public static Account createOneCygateAccount(Id cygateAccountOwnerId) {
        return createOneCygateAccount(cygateAccountOwnerId, null);
    }

    // Create one Cygate Account (currently this is the same as large account) with ParentId set
    public static Account createOneCygateAccount(Id cygateAccountOwnerId, Id parentKundKontoId) {
        Account a = createOneLargeStandardAccount();
        if (cygateAccountOwnerId != null) {
            a.OwnerId = cygateAccountOwnerId;
            a.ParentId = parentKundKontoId;
        }
        return a;
    }

    /*  // Create one Cygate Sub Account, account owner Id not specified
    public static Account createOneCygateSubAccount(Id parentOrgAccountId){
        return createOneCygateSubAccount(null, parentOrgAccountId);
    }

    // Create one Cygate Sub Account, account owner Id and parent org as input
    public static Account createOneCygateSubAccount(Id cygateAccountOwnerId, Id parentOrgAccountId){
        Account a = createOneAccount();
        a.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_CYGATE_SUB);
        if(cygateAccountOwnerId != null) a.OwnerId = cygateAccountOwnerId;
        a.ParentId = parentOrgAccountId;
        a.Cygate_Sub_Account_ID__c = '1234';
        return a;
    }*/

    //Create Accounts
    public static List<Account> createAccounts(Integer numAccts) {
        List<Account> accts = new List<Account>();

        for (Integer i = 0; i < numAccts; i++) {
            Account a = new Account(Name = 'TestAccount' + i);
            accts.add(a);
        }

        return accts;
    }

    public static List<Account> createOwnedAccounts(Integer numAccts, User usr) {
        List<Account> accts = new List<Account>();
        Account a;
        for (Integer i = 0; i < numAccts; i++) {
            a = new Account(Name = 'TestAccount' + i);
            a.owner = usr;
            accts.add(a);
        }
        return accts;
    }

    //Create one Large Account
    public static Account createOneKundkontoAccount() {
        Account a = new Account(Name = 'TestAccount');
        a.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        Test_DataFactory.autoNumber += 1;
        a.Kundkonto_Nr__c = 'abc' + Test_DataFactory.autoNumber;

        return a;
    }

    //Create one Reseller Account
    public static Account createResellerAccount() {
        Account a = createOneAccount();
        a.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_RESELLER);

        return a;
    }

    public static Opportunity createOpportunity() {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'TestOpportunity';
        opportunity.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
        //opportunity.Main_Product_Area__c = 'Cloud Networking';
        opportunity.CloseDate = Date.today();
        opportunity.Large_New_Sales__c = 1;
        opportunity.Competitor__c = 'Ingen huvudkonkurrent';
        opportunity.Comment_to_Reason__c = 'testcomment';
        opportunity.Reason__c = 'Pris';
        return opportunity;
    }

    public static Opportunity createSmeOpportunity() {
        Opportunity opportunity = createOpportunity();
        opportunity.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
        opportunity.Competitor__c = 'Ingen huvudkonkurrent';
        opportunity.Comment_to_Reason__c = 'testcomment';
        opportunity.Reason__c = 'Pris';
        return opportunity;
    }

    public static Opportunity createFiberOpportunity() {
        Opportunity opportunity = createOpportunity();
        opportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(SEUtility.REALESTATEFIBER).getRecordTypeId();
        opportunity.Competitor__c = 'Ingen huvudkonkurrent';
        opportunity.Comment_to_Reason__c = 'testcomment';
        opportunity.Reason__c = 'Pris';
        return opportunity;
    }
    public static Opportunity createLargeOpportunity() {
        Opportunity opportunity = createOpportunity();
        opportunity.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
        opportunity.Competitor__c = 'Ingen huvudkonkurrent';
        opportunity.Comment_to_Reason__c = 'testcomment';
        opportunity.Reason__c = 'Pris';
        return opportunity;
    }

    public static Opportunity createPROpportunity() {
        Opportunity opportunity = createOpportunity();
        opportunity.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PR_STANDARD);
        opportunity.Competitor__c = 'Ingen huvudkonkurrent';
        opportunity.Comment_to_Reason__c = 'testcomment';
        opportunity.Reason__c = 'Pris';
        return opportunity;
    }

    public static Opportunity createTeliaCygateOpportunity() {
        Opportunity opportunity = createOpportunity();
        opportunity.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_TELIA_CYGATE);
        opportunity.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
        opportunity.New_Sales__c = 1; //This is the Cygate New Sales (editable) field
        opportunity.Current_Supplier__c = 'Telia';
        opportunity.Category__c = 'Kategori 1';
        opportunity.Competitor__c = 'Ingen huvudkonkurrent';
        opportunity.Comment_to_Reason__c = 'testcomment';
        opportunity.Reason__c = 'Pris';
        return opportunity;
    }

    public static List<Opportunity> createOpportunities(Integer n) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < n; i++) {
            Opportunity opportunity = createOpportunity();
            opportunities.add(opportunity);
        }
        return opportunities;
    }

    public static List<Opportunity> createOpportunitiesFromAccount(Integer n, Id accountId) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < n; i++) {
            Opportunity opportunity = createOpportunity();
            opportunity.AccountId = accountId;
            opportunities.add(opportunity);
        }
        return opportunities;
    }

    public static List<Opportunity> createOwnedOpportunities(Integer numOpps, User usr) {
        List<Opportunity> oppList = new List<Opportunity>();
        Id standardRTId = SEUtility.getRecordTypeId('SME_standard');
        Opportunity opp;
        for (Integer i = 0; i < numOpps; i++) {
            opp = new Opportunity(Name = 'TestOpportunity' + i);
            //opp.Main_Product_Area__c = 'Cloud Networking';
            opp.owner = usr;
            opp.RecordTypeId = standardRTId;
            opp.Large_New_Sales__c = 1;
            opp.Competitor__c = 'Ingen huvudkonkurrent';
            opp.Comment_to_Reason__c = 'testcomment';
            opp.Reason__c = 'Pris';
            oppList.add(opp);
        }
        return oppList;
    }

    public static Opportunity createSmeWonOpportunityNewSales() {
        return createSmeWonOpportunitiesNewSales(1)[0];
    }

    public static Opportunity createSmeWonOpportunityNewSales(Account acc) {
        return createSmeWonOpportunitiesNewSales(1, acc)[0];
    }

    public static List<Opportunity> createSmeWonOpportunitiesNewSales(Integer numberOfOpps) {
        Account acc = Test_DataFactory.createOneAccount();
        insert acc;
        return createSmeWonOpportunitiesNewSales(numberOfOpps, acc);
    }

    public static List<Opportunity> createSmeWonOpportunitiesNewSales(Integer numberOfOpps, Account acc) {
        Contact c = Test_DataFactory.createOneContact();
        c.AccountId = acc.Id;
        insert c;

        Product2 p = Test_DataFactory.createProduct('Test');
        p.IsActive = true;
        insert p;

        Id pbId = Test.getStandardPricebookId();

        PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, p);
        pbe.UnitPrice = 1000;
        pbe.IsActive = true;
        insert pbe;

        PriceBookEntry pbe1 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p);
        pbe1.UnitPrice = 1000;
        pbe1.IsActive = true;
        insert pbe1;

        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < numberOfOpps; i++) {
            Opportunity opp = Test_DataFactory.createSmeOpportunity();
            opp.AccountId = acc.Id;
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD);
            opp.Kammarkollegiet__c = 'Kammarkollegiet';
            opportunities.add(opp);
        }
        insert opportunities;

        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        for (Opportunity opp : opportunities) {
            OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(opp.Id, pbe1.Id, Test_DataFactory.OLI_SALES_PURPOSE_NEW_SALES);
            oliList.add(oli);

            OpportunityContactRole ocr = Test_DataFactory.createOpportunityContactRole();
            ocr.ContactId = c.Id;
            ocr.Role = OpportunityValidationHandler.OPP_CR_AVTALSTECKNARE;
            ocr.OpportunityId = opp.Id;
            ocrList.add(ocr);
        }
        insert oliList;
        insert ocrList;

        for (Opportunity opp : opportunities) {
            //set to won
            opp.Main_Product_Area__c = 'Services';
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_WON;
            opp.Agreement_Signed__c = true;
            opp.Phase_Vunnen__c = true;
        }
        update opportunities;
        return opportunities;
    }

    public static Opportunity createCygateOpportunity() {
        Opportunity opportunity = createOpportunity();
        opportunity.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD);
        opportunity.Competitor__c = 'Ingen huvudkonkurrent';
        opportunity.Comment_to_Reason__c = 'testcomment';
        opportunity.Reason__c = 'Pris';
        opportunity.Kammarkollegiet__c = 'Ej Kammarkollegiet';
        return opportunity;
    }

    public static Opportunity createProspect() {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test Prospect';
        opportunity.StageName = 'Aktivt prospect';
        opportunity.CloseDate = Date.today();
        opportunity.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT);
        opportunity.Competitor__c = 'Ingen huvudkonkurrent';
        opportunity.Comment_to_Reason__c = 'testcomment';
        opportunity.Reason__c = 'Pris';
        return opportunity;
    }

    public static OpportunityLineItem createOpportunityLineItem() {
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Start_Fee__c = 0;
        oli.Quantity = 1;
        oli.Contact_Duration__c = 24;
        return oli;
    }

    public static List<OpportunityLineItem> createOpportunityLineItems(Integer n) {
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for (Integer i = 0; i < n; i++) {
            OpportunityLineItem oli = createOpportunityLineItem();
            olis.add(oli);
        }
        return olis;
    }

    public static OpportunityLineItem createProductAndOpportunityLineItem(Id oppId) {
        Product2 p = Test_DataFactory.createProduct('Test');
        p.IsActive = true;
        insert p;

        Id pbId = Test.getStandardPricebookId();
        PriceBookEntry pbe = Test_DataFactory.createPricebookEntry(pbId, p);
        pbe.UnitPrice = 1000;
        pbe.IsActive = true;
        insert pbe;

        PriceBookEntry pbe1 = Test_DataFactory.createPricebookEntry(SEUtility.PRICEBOOK_TELIA_NEWID, p);
        pbe1.UnitPrice = 1000;
        pbe1.IsActive = true;
        insert pbe1;

        OpportunityLineItem oli = createOpportunityLineItem(oppId, pbe1.Id);
        return oli;
    }

    public static OpportunityContactRole createOpportunityContactRole() {
        OpportunityContactRole ocr = new OpportunityContactRole();
        return ocr;
    }

    public static List<OpportunityContactRole> createOpportunityContactRoles(Integer numCR) {
        List<OpportunityContactRole> crList = new List<OpportunityContactRole>();
        if (numCR > 0) {
            for (Integer i = 0; i < numCR; i++) {
                crList.add(createOpportunityContactRole());
            }
        }
        return crList;
    }

    public static Product2 createProduct(String name) {
        Product2 prd2 = new Product2();
        prd2.Name = name;
        return prd2;
    }

    public static List<Product2> createProducts(Integer numProducts) {
        List<Product2> prod2List = new List<Product2>();
        if (numProducts > 0) {
            for (Integer i = 0; i < numProducts; i++) {
                prod2List.add(createProduct('Product ' + i));
            }
        }
        return prod2List;
    }

    public static PricebookEntry createPricebookEntry(Id pricebookId, Product2 product) {
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pricebookId;
        pbe.Product2Id = product.Id;
        pbe.UnitPrice = 10000;
        pbe.IsActive = true;
        return pbe;
    }

    public static OpportunityLineItem createOpportunityLineItem(Id oppId, Id pbeId) {
        OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem();
        oli.OpportunityId = oppId;
        oli.PricebookEntryId = pbeId;
        oli.Quantity = 1;
        oli.UnitPrice = 20;
        oli.SME_Sales_Outcome_Cal__c = 1;
        return oli;
    }

    public static OpportunityLineItem createOpportunityLineItem(Id oppId, Id pbeId, String salesPurpose) {
        OpportunityLineItem oli = Test_DataFactory.createOpportunityLineItem(oppId, pbeId);
        oli.Sales_purpose__c = salesPurpose;
        return oli;
    }

    //Create one Contact
    public static Contact createOneContact() {
        Contact c = new Contact(LastName = 'TestContact', FirstName = 'NewContact', Email = 'test@dummy.com', Role__c = 'Annan');
        return c;
    }

    //Create one Contact
    public static Contact createOneContactWithAccount() {
        Account a = Test_DataFactory.createOneAccount();
        insert a;
        Contact c = new Contact(LastName = 'TestContact', FirstName = 'NewContact', Email = 'test@dummy.com', Role__c = 'Annan');
        c.AccountId = a.Id;

        return c;
    }

    //Create Contacts
    public static List<Contact> createContacts(Integer numConts) {
        List<Contact> conts = new List<Contact>();

        for (Integer i = 0; i < numConts; i++) {
            Contact c = new Contact(LastName = 'TestContact', FirstName = 'NewContact', Email = 'test' + i + '@dummy.com', Role__c = 'Annan' + i);
            conts.add(c);
        }

        return conts;
    }

    //Create Campaigns
    public static Campaign createTeliaCampaign() {
        Campaign campaign = new Campaign();
        campaign.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CAMPAIGN_RECTYPE_TELIA);
        campaign.Name = 'Test Campaign';
        campaign.Type = 'Mail';
        campaign.status = 'In Progress';
        campaign.startdate = Date.today();
        campaign.enddate = Date.today() + 5;
        return campaign;
    }

    //Create Campaigns
    public static Campaign createCygateCampaign() {
        Campaign campaign = new Campaign();
        campaign.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CAMPAIGN_RECTYPE_CYGATE);
        campaign.Name = 'Test Campaign';
        campaign.Type = 'Mail';
        campaign.status = 'In Progress';
        campaign.startdate = Date.today();
        campaign.enddate = Date.today() + 5;
        campaign.IsActive = true;
        return campaign;
    }

    public static List<Campaign> createCampaigns(Integer numCampaigns) {
        List<Campaign> campaigns = new List<Campaign>();

        for (Integer i = 0; i < numCampaigns; i++) {
            Campaign campaign = createTeliaCampaign();
            campaign.Name = 'Test Campaign ' + i;
            campaign.Type = 'Mail';
            campaigns.add(campaign);
        }
        return campaigns;
    }

    //Create one Task
    public static Task createOneTask() {
        Task t = new Task();

        return t;
    }

    //Create Tasks
    public static List<Task> createTasks(Integer numTasks) {
        List<Task> tasks = new List<Task>();

        for (Integer i = 0; i < numTasks; i++) {
            Task t = new Task();
            tasks.add(t);
        }

        return tasks;
    }

    //Create Task with what and who
    public static Task createTaskWithWhatWhoId(Id whatId, Id whoId) {
        Task t = new Task();
        t.WhatId = whatId;
        t.WhoId = whoId;

        return t;
    }

    //Create one Event
    public static Event createOneEvent() {
        Event e = new Event(ActivityDateTime = System.now(), DurationInMinutes = 60);
        //e.StartDateTime = e.ActivityDateTime;

        return e;
    }

    //Create one Event that is completed, i.e it has an End Date in the past.
    public static Event createOneCompletedEvent() {
        Event e = new Event();
        e.ActivityDateTime = System.now().addDays(-1);
        //e.StartDateTime = e.ActivityDateTime;
        e.EndDateTime = e.ActivityDateTime.addHours(1);

        return e;
    }

    //Create Events
    public static List<Event> createEvents(Integer numEvents) {
        List<Event> events = new List<Event>();

        for (Integer i = 0; i < numEvents; i++) {
            Event e = createOneEvent();
            events.add(e);
        }

        return events;
    }

    //Create one event with WhatId and WhoId
    public static Event createEventWithWhatWhoId(Id whatId, Id whoId) {
        Event e = createOneCompletedEvent();
        e.WhatId = whatId;
        e.WhoId = whoId;

        return e;
    }

    //Create one shared event with WhatId and WhoId and other contacts related to the event
    public static Event createEventWithWhatWhoIds(Id whatId, List<Id> whoIds) {
        Event e = createOneCompletedEvent();
        e.WhatId = whatId;
        for (Id whoId : whoIds) {
            e.EventWhoIds.add(whoId);
        }

        return e;
    }

    // Create one event with cygate record type
    // Added A.N: Campaign is required for Cygate Events
    public static Event createCygateEvent() {
        Event e = createOneEvent();
        e.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE);
        Campaign camp = createCygateCampaign();
        insert camp;
        e.Campaign__c = camp.Id;
        return e;
    }

    // Create one event with cygate record type
    public static Event createCygateKundbesokEvent() {
        Event e = createCygateEvent();
        e.Type = 'Web/video';
        e.Presented_Cloudanalysis__c = true;
        return e;
    }

    // Adds a User, Contact, or Lead to the event initees list.
    public static EventRelation createEventRelation(Id eventId, Id userContactLeadId) {
        EventRelation er = new EventRelation();
        er.EventId = eventId;
        er.RelationId = userContactLeadId;
        return er;
    }

    /*** SELLER REGISTER ****/

    public static Seller__c createSeller(Id userId, Id opt_ManagerId) {
        Seller__c s = new Seller__c(
            User__c = userId,
            Manager__c = opt_ManagerId,
            Type__c = SellerTriggerHandler.SELLER_TYPE_SELLER,
            Start_Date__c = System.today()
        );
        return s;
    }

    public static Seller__c createSalesTeamManagerSeller(Id userId, Id opt_ManagerId) {
        Seller__c s = new Seller__c(
            User__c = userId,
            Sales_Team_Name__c = 'Test Team Name',
            Sales_Team_Number__c = '123456',
            Manager__c = opt_ManagerId,
            Type__c = SellerTriggerHandler.SELLER_TYPE_SALES_TEAM_MGR,
            Start_Date__c = System.today()
        );
        return s;
    }

    public static Seller__c createSalesUnitManagerSeller(Id userId, Id opt_ManagerId) {
        Seller__c s = new Seller__c(
            User__c = userId,
            Sales_Team_Name__c = 'Test Unit Name',
            Manager__c = opt_ManagerId,
            Type__c = SellerTriggerHandler.SELLER_TYPE_SALES_UNIT_MGR,
            Start_Date__c = System.today()
        );
        return s;
    }

    public static Seller__c createBusinessUnitManagerSeller(Id userId, Id opt_ManagerId) {
        Seller__c s = new Seller__c(
            User__c = userId,
            Sales_Team_Name__c = 'Test Business Unit Name',
            Manager__c = opt_ManagerId,
            Type__c = SellerTriggerHandler.SELLER_TYPE_BUS_UNIT_MGR,
            Start_Date__c = System.today()
        );
        return s;
    }

    public static Seller__c createBusinessAreaManagerSeller(Id userId) {
        Seller__c s = new Seller__c(
            User__c = userId,
            Sales_Team_Name__c = 'Test Business Area Name',
            Type__c = SellerTriggerHandler.SELLER_TYPE_BUS_AREA_MGR,
            Start_Date__c = System.today()
        );
        return s;
    }

    /*** YEARLY TARGETS ****/

    //Create one Yearly Target
    public static Yearly_Target__c createOneYearlyTarget(Seller__c s) {
        String currentYearString = System.today().year() + '';
        Yearly_Target__c yt = new Yearly_Target__c(Name = currentYearString, Seller__c = s.Id, User__c = s.User__c);

        return yt;
    }

    //Create one specific Yearly Target
    /*Changes by PP for Sales_Value Target*/
    public static Yearly_Target__c createOneSpecificYearlyTargetSeller(
        Integer year,
        Id userId,
        String startWeek,
        Integer newSalesTarget,
        Integer continuationSalesTarget,
        Integer salesValueTarget
    ) {
        Yearly_Target__c yt = new Yearly_Target__c(
            User__c = userId,
            Startweek__c = startWeek,
            Full_Year_New_Sales_Target__c = newSalesTarget,
            Full_Year_Continuation_Sales_Target__c = continuationSalesTarget,
            Full_Year_Sales_Value_Target__c = salesValueTarget,
            Name = String.valueof(year)
        );
        return yt;
    }

    //Create one specific Yearly Target
    /*Changes by PP for Sales_Value Target*/
    public static Yearly_Target__c createOneSpecificYearlyTargetSalesTeam(
        Integer year,
        Id userId,
        String startWeek,
        Integer newSalesTarget,
        Integer continuationSalesTarget,
        Integer salesValueTarget
    ) {
        Yearly_Target__c yt = new Yearly_Target__c(
            User__c = userId,
            Startweek__c = startWeek,
            Full_Year_New_Sales_Target__c = newSalesTarget,
            Full_Year_Continuation_Sales_Target__c = continuationSalesTarget,
            Full_Year_Sales_Value_Target__c = salesValueTarget,
            Name = String.valueof(year)
        );
        return yt;
    }

    //Create one specific Yearly Target
    /*Changes by PP for Sales_Value Target*/
    public static Yearly_Target__c createOneSpecificYearlyTargetSalesUnit(
        Integer year,
        Id userId,
        String startWeek,
        Integer newSalesTarget,
        Integer continuationSalesTarget,
        Integer salesValueTarget
    ) {
        Yearly_Target__c yt = new Yearly_Target__c(
            User__c = userId,
            Startweek__c = startWeek,
            Full_Year_New_Sales_Target__c = newSalesTarget,
            Full_Year_Continuation_Sales_Target__c = continuationSalesTarget,
            Full_Year_Sales_Value_Target__c = salesValueTarget,
            Name = String.valueof(year)
        );
        return yt;
    }

    //Create Yearly Targets
    public static List<Yearly_Target__c> createYearlyTargets(Integer numTargets) {
        List<Yearly_Target__c> yts = new List<Yearly_Target__c>();

        Integer startyear = Date.today().year();

        for (Integer i = 0; i < numTargets; i++) {
            Yearly_Target__c yt = new Yearly_Target__c(User__c = UserInfo.getUserId(), Name = String.valueOf(startyear));
            yts.add(yt);
            startyear++;
        }

        return yts;
    }

    //Create one specific Yearly Target
    /*Changes by PP for Sales_Value Target*/
    public static Yearly_Target__c createOneSpecificYearlyTarget(
        Id userId,
        Id sellerId,
        String startWeek,
        Integer newSalesTarget,
        Integer continuationSalesTarget,
        Integer salesValueTarget
    ) {
        String currentYearString = System.today().year() + '';
        Yearly_Target__c yt = new Yearly_Target__c(
            User__c = userId,
            Seller__c = sellerId,
            Startweek__c = startWeek,
            Full_Year_New_Sales_Target__c = newSalesTarget,
            Full_Year_Continuation_Sales_Target__c = continuationSalesTarget,
            Full_Year_Sales_Value_Target__c = salesValueTarget,
            Name = currentYearString
        );
        return yt;
    }

    /*** USERS ***/

    // Returns a list of Sales Rep users
    // @arg nrSalesReps - the number of sales rep users that shall be created
    public static List<User> createSalesRepUsers(Integer nrSalesReps) {
        Id prId = getProfileId(SEUtility.PROFILE_GENERAL);
        List<User> userList = new List<User>();
        for (integer i = 0; i < nrSalesReps; i++) {
            userList.add(
                new User(
                    alias = 'srep' + i,
                    email = emailStr,
                    emailencodingkey = emailencodingkeyStr,
                    firstname = 'Sales' + i,
                    lastname = 'Rep' + i,
                    languagelocalekey = languagelocalekeyStr,
                    localesidkey = localesidkeyStr,
                    profileid = prId,
                    Telia_Id__c = 'ABC1' + i,
                    timezonesidkey = timezonesidkeyStr,
                    username = 'salesRep' + i + '@salesenablerproject.com' + Math.random(),
                    mobilePhone = '+46 53684000'
                )
            );
        }
        return userList;
    }

    // Returns a list of Sales Manager users
    // @arg nrSalesManagers
    public static List<User> createSalesManagerUsers(Integer nrSalesManagers) {
        Id prId = getProfileId(SEUtility.PROFILE_GENERAL);
        List<User> userList = new List<User>();
        for (integer i = 0; i < nrSalesManagers; i++) {
            userList.add(
                new User(
                    alias = 'sm' + i,
                    email = emailStr,
                    emailencodingkey = emailencodingkeyStr,
                    firstname = 'Sales' + i,
                    lastname = 'Manager' + i,
                    languagelocalekey = languagelocalekeyStr,
                    localesidkey = localesidkeyStr,
                    profileid = prId,
                    Telia_Id__c = 'ABC2' + i,
                    timezonesidkey = timezonesidkeyStr,
                    username = 'salesManager' + i + '@salesenablerproject.com' + Math.random(),
                    mobilePhone = '+46 53684000'
                )
            );
        }
        for (User u : userList) {
            System.debug(u.Telia_Id__c);
            System.debug(u.Alias);
        }
        return userList;
    }

    // Returns a SME user
    public static User createSMEUser() {
        User u = createNewUser();
        u.Profileid = getProfileId(SEUtility.PROFILE_SME);
        u.UserRoleId = getUserRoleId('SS_SME_Sales_Manager');
        return u;
    }

    // Returns a Fiber USer
    public static User createFiberUser() {
        User u = createNewUser();
        u.Profileid = getProfileId('Fiber Base Profile');
        u.UserRoleId = getUserRoleId('Fiber_Sales_Manager_New_Sales');
        return u;
    }

    // Returns a TAM (Telephone Account Manager) user. This is a SME User with role "BSS Leadcenter Account Manager" or "BSS Leadcenter Sales Manager"
    public static User createTAMUser() {
        User u = createNewUser();
        u.Profileid = getProfileId(SEUtility.PROFILE_SME);
        u.UserRoleId = getUserRoleId('SS_SME_Sales_Partners_AM');
        return u;
    }

    // Returns an admin user
    public static User createAdminUser() {
        User u = createNewUser();
        u.Profileid = getProfileId(SEUtility.PROFILE_SYS_ADMIN);
        //u.UserRoleId = getUserRoleId('PB_P_K_Public_North');
        u.ForecastEnabled = true;
        u.Bypass_VR__c = true;
        return u;
    }

    // Returns a Large user
    public static User createLargeUser() {
        User u = createNewUser();
        u.Profileid = getProfileId(SEUtility.PROFILE_LARGE);
        u.UserRoleId = getUserRoleId('PB_P_K_Public_North');
        u.ForecastEnabled = true;
        return u;
    }

    // Returns a Large Renewal user
    public static User createLargeRenewalUser() {
        User u = createNewUser();
        u.Profileid = getProfileId(SEUtility.PROFILE_LARGE);
        u.UserRoleId = getUserRoleId('Renewal');
        u.ForecastEnabled = true;
        return u;
    }
    //Returns a Marketing User
    public static User createMarketingUser() {
        User u = createNewuser();
        u.ProfileId = getProfileId(SEUtility.PROFILE_LARGE);
        u.UserRoleId = getUserRoleId('Marketing');
        return u;
    }

    //Returns a Service Management User
    public static User createSMUser() {
        User u = createNewuser();
        u.ProfileId = getProfileId(SEUtility.PROFILE_SERVICE_MANAGER);
        u.UserRoleId = getUserRoleId('CSM1');
        return u;
    }

    // Returns a Solutions user
    public static User createSolutionUser() {
        User u = createNewUser();
        u.Profileid = getProfileId(SEUtility.PROFILE_GENERAL);
        u.UserRoleId = getUserRoleId('Bus_Design_Netw');
        u.ForecastEnabled = true;
        return u;
    }

    public static List<User> createSolutionUsers(Integer nrUsers) {
        List<User> userList = new List<User>();
        for (integer i = 0; i < nrUsers; i++) {
            User u = createNewUser();
            u.Profileid = getProfileId(SEUtility.PROFILE_GENERAL);
            u.UserRoleId = getUserRoleId('Bus_Design_Netw');
            u.ForecastEnabled = true;
            userList.add(u);
        }
        return userList;
    }

    // Returns a Cygate user
    public static User createCygateUser() {
        User u = createNewUser();
        Test_DataFactory.autoNumber += 1;
        u.Cygate_Employee_ID__c = '1' + Test_DataFactory.autoNumber;
        u.Profileid = getProfileId(SEUtility.PROFILE_CYGATE_SALES);
        u.UserRoleId = getUserRoleId('CG_S_ljare_Syd');
        u.ForecastEnabled = true;
        return u;
    }

    // Returns a Cygate user
    public static User createCygateChefUser() {
        User u = createNewUser();
        Test_DataFactory.autoNumber += 1;
        u.Cygate_Employee_ID__c = '2' + Test_DataFactory.autoNumber;
        u.Profileid = getProfileId(SEUtility.PROFILE_CYGATE_SALES);
        u.UserRoleId = getUserRoleId('CG_Strategisks_ljansvarig');
        u.ForecastEnabled = true;
        return u;
    }

    // Returns a Cygate user
    public static User createCygateSalesSupportUser() {
        User u = createNewUser();
        Test_DataFactory.autoNumber += 1;
        u.Cygate_Employee_ID__c = '3' + Test_DataFactory.autoNumber;
        u.Profileid = getProfileId(SEUtility.PROFILE_CYGATE_SALES);
        u.UserRoleId = getUserRoleId('CG_Sales_Support_Norr');
        u.ForecastEnabled = true;
        return u;
    }

    // Returns a Enterprise Business Admin User user with Cygate Manager role
    public static User createCygateEnterpriseBusinessAdminUser() {
        User u = createNewUser();
        Test_DataFactory.autoNumber += 1;
        u.Cygate_Employee_ID__c = '3' + Test_DataFactory.autoNumber;
        u.Profileid = getProfileId(SEUtility.PROFILE_TELIA_ADMIN);
        u.UserRoleId = getUserRoleId('CG_Strategisks_ljansvarig');
        u.ForecastEnabled = true;
        return u;
    }
    // Return a Cygate user with Role - CG:Säljsupport Chef
    public static User createCygateSalesSupportChef() {
        User u = createNewUser();
        Test_DataFactory.autoNumber += 1;
        u.Cygate_Employee_ID__c = '4' + Test_DataFactory.autoNumber;
        u.ProfileId = getProfileId(SEUtility.Profile_Telia_Admin);
        u.UserRoleId = getUserRoleId('CG_Sales_Support_Norr');
        u.ForecastEnabled = true;
        return u;
    }
    // Returns a SOGO PR User
    public static User createPRUser() {
        User u = createNewUser();
        Test_DataFactory.autoNumber += 1;
        u.Profileid = getProfileId(SEUtility.PROFILE_SOHO_PR);
        u.UserRoleId = getUserRoleId('SOHO_PR_Norrk_ping');
        u.ForecastEnabled = true;
        u.PR_Retailer_Shop__c = 'Falun';
        return u;
    }

    private static User createNewUser() {
        Test_DataFactory.autoNumber += 1;
        return new User(
            alias = 'cfo' + Test_DataFactory.autoNumber,
            email = emailStr,
            emailencodingkey = emailencodingkeyStr,
            firstname = 'Cygate',
            lastname = 'CFO Testing' + Test_DataFactory.autoNumber,
            languagelocalekey = languagelocalekeyStr,
            localesidkey = localesidkeyStr,
            Telia_Id__c = 'ABE' + Test_DataFactory.autoNumber,
            timezonesidkey = timezonesidkeyStr,
            username = 'cfo@salesenablerproject.com.' + Test_DataFactory.autoNumber,
            mobilePhone = '+46 53684000'
        );
    }

    private static Map<String, Id> userRoleMap;
    private static void loadUserRoleMap() {
        if (userRoleMap == null) {
            userRoleMap = new Map<String, Id>();
            for (UserRole ur : [SELECT id, DeveloperName FROM userRole]) {
                userRoleMap.put(ur.DeveloperName, ur.Id);
            }
        }
    }

    private static Id getUserRoleId(String developername) {
        loadUserRoleMap();
        return userRoleMap.get(developername);
    }

    private static Map<String, Id> profileMap;
    private static void loadProfileMap() {
        if (profileMap == null) {
            profileMap = new Map<String, Id>();
            for (Profile p : [SELECT id, name FROM profile]) {
                profileMap.put(p.Name, p.Id);
            }
        }
    }

    private static Id getProfileId(String s) {
        loadProfileMap();
        return profileMap.get(s);
    }

    // Returns a three level user hierarchy of SME users {SalesUnitManager, SalesTeamManager, Seller}
    public static List<User> createSmeUserTeam() {
        List<User> ul = new List<User>();
        for (integer i = 0; i < 3; i++) {
            ul.add(createSMEUser());
        }
        insert ul;
        return ul;
    }

    // Returns a n level user hierarchy of Large users. For n=5 this will be {BusinessAreaManager, BusinessUnitManager, SalesUnitManager, SalesTeamManager, Seller}
    public static List<User> createLargeUserTeam() {
        List<User> ul = new List<User>();
        for (integer i = 0; i < 5; i++) {
            ul.add(createLargeUser());
        }
        insert ul;
        return ul;
    }

    // For testing purposes, often we do not need the entire 5 level hierarchy, so can specify this in the call.
    public static List<User> createLargeUserTeam(Integer n) {
        List<User> ul = new List<User>();
        for (integer i = 0; i < n; i++) {
            ul.add(createLargeUser());
        }
        insert ul;
        return ul;
    }

    public static List<User> createLargeRenewalUserTeam(Integer n) {
        List<User> uList = new List<User>();
        for (integer i = 0; i < n; i++) {
            uList.add(createLargeRenewaluser());
        }
        insert uList;
        return uList;
    }
    public static List<User> createMarketingUserTeam(Integer n) {
        List<User> uList = new List<User>();
        for (integer i = 0; i < n; i++) {
            uList.add(createMarketinguser());
        }
        insert uList;
        return uList;
    }
    public static List<User> createSMUserTeam(Integer n) {
        List<User> uList = new List<User>();
        for (integer i = 0; i < n; i++) {
            uList.add(createSMuser());
        }
        insert uList;
        return uList;
    }

    // Returns a three level seller hierarchy for a list of SME users {SalesUnitManager, SalesTeamManager, Seller}.
    public static List<Seller__c> createSmeSellerTeam(List<User> ul) {
        List<Seller__c> sl = createSmeSellerTeam(ul, null);
        return sl;
    }

    public static List<Seller__c> createSmeSellerTeam(List<User> ul, Date startDate) {
        List<Seller__c> sl = new List<Seller__c>();
        Seller__c unitLeader = createSalesUnitManagerSeller(ul[0].Id, null);
        if (startDate != null) {
            unitLeader.Start_Date__c = startDate;
        }
        insert unitLeader;
        sl.add(unitLeader);
        Seller__c teamLeader = createSalesTeamManagerSeller(ul[1].Id, unitLeader.Id);
        if (startDate != null) {
            teamLeader.Start_Date__c = startDate;
        }
        insert teamLeader;
        sl.add(teamLeader);
        Seller__c seller = createSeller(ul[2].Id, teamLeader.Id);
        if (startDate != null) {
            seller.Start_Date__c = startDate;
        }
        insert seller;
        sl.add(seller);
        return sl;
    }

    // Returns a five level seller hierarchy for a list of of Large users. {BusinessAreaManager, BusinessUnitManager, SalesUnitManager, SalesTeamManager, Seller}
    public static List<Seller__c> createLargeSellerTeam(List<User> ul, Date startDate) {
        List<Seller__c> sl = new List<Seller__c>();
        Seller__c bam = createBusinessAreaManagerSeller(ul[0].Id);
        if (startDate != null) {
            bam.Start_Date__c = startDate;
        }
        insert bam;
        sl.add(bam);
        Seller__c bum = createBusinessUnitManagerSeller(ul[1].Id, bam.Id);
        if (startDate != null) {
            bum.Start_Date__c = startDate;
        }
        insert bum;
        sl.add(bum);
        Seller__c unitLeader = createSalesUnitManagerSeller(ul[2].Id, bum.Id);
        if (startDate != null) {
            unitLeader.Start_Date__c = startDate;
        }
        insert unitLeader;
        sl.add(unitLeader);
        Seller__c teamLeader = createSalesTeamManagerSeller(ul[3].Id, unitLeader.Id);
        if (startDate != null) {
            teamLeader.Start_Date__c = startDate;
        }
        insert teamLeader;
        sl.add(teamLeader);
        Seller__c seller = createSeller(ul[4].Id, teamLeader.Id);
        if (startDate != null) {
            seller.Start_Date__c = startDate;
        }
        insert seller;
        sl.add(seller);
        return sl;
    }

    public static List<Seller__c> returnLargeSellerTeam(List<User> ul, Date startDate) {
        List<Seller__c> sl = new List<Seller__c>();
        Seller__c bam = createBusinessAreaManagerSeller(ul[0].Id);
        if (startDate != null) {
            bam.Start_Date__c = startDate;
        }
        sl.add(bam);
        Seller__c bum = createBusinessUnitManagerSeller(ul[1].Id, bam.Id);
        if (startDate != null) {
            bum.Start_Date__c = startDate;
        }
        sl.add(bum);
        Seller__c unitLeader = createSalesUnitManagerSeller(ul[2].Id, bum.Id);
        if (startDate != null) {
            unitLeader.Start_Date__c = startDate;
        }
        sl.add(unitLeader);
        Seller__c teamLeader = createSalesTeamManagerSeller(ul[3].Id, unitLeader.Id);
        if (startDate != null) {
            teamLeader.Start_Date__c = startDate;
        }
        sl.add(teamLeader);
        Seller__c seller = createSeller(ul[4].Id, teamLeader.Id);
        if (startDate != null) {
            seller.Start_Date__c = startDate;
        }
        sl.add(seller);
        return sl;
    }

    // Returns a yearly target for each seller in the input list (for SME: {SalesUnitManager, SalesTeamManager, Seller})
    public static List<Yearly_Target__c> createYearlyTargetsSellerTeam(List<Seller__c> sl) {
        String year = String.valueOf(System.today().year());
        return createYearlyTargetsSellerTeam(sl, year);
    }

    // Returns a yearly target for each seller in the input list (for SME: {SalesUnitManager, SalesTeamManager, Seller})
    public static List<Yearly_Target__c> createYearlyTargetsSellerTeam(List<Seller__c> sl, String year) {
        List<Yearly_Target__c> ytl = new List<Yearly_Target__c>();
        for (Seller__c s : sl) {
            Yearly_Target__c yt = createOneYearlyTarget(s);
            yt.Name = year;
            //insert yt;
            ytl.add(yt);
        }
        insert ytl;
        return ytl;
    }

    public static List<Yearly_Target__c> returnYearlyTargetsSellerTeam(List<Seller__c> sl) {
        List<Yearly_Target__c> ytl = new List<Yearly_Target__c>();
        for (Seller__c s : sl) {
            Yearly_Target__c yt = createOneYearlyTarget(s);
            ytl.add(yt);
        }
        return ytl;
    }

    public static List<Revenue__c> createRevenues(Id accId, Integer year, Integer startMonth, Integer endMonth, Decimal amount) {
        List<Revenue__c> revList = new List<Revenue__c>();
        for (Integer month = startMonth; month < endMonth + 1; month++) {
            revList.add(createRevenue(accId, year, month, amount));
        }
        return revList;
    }

    public static Revenue__c createRevenue(Id accId, Integer year, Integer month, Decimal amount) {
        Revenue__c rev = new Revenue__c();
        rev.Account__c = accId;
        rev.RevenueAmount__c = (amount == null ? 100.0 : amount);
        Integer y = (year == null ? System.today().year() : year);
        Integer m = (month == null ? System.today().month() : month);
        rev.Name = String.valueOf(y) + '-' + String.valueOf(m);
        rev.Date__c = date.newInstance(y, m, 1);
        return rev;
    }

    public static Revenue__c createRevenue(Id accId) {
        return createRevenue(accId, null, null, null);
    }

    public static SupplierDiscount__c createDealreg(Id accId) {
        SupplierDiscount__c dealreg = new SupplierDiscount__c();
        Test_DataFactory.autoNumber += 1;
        dealreg.Dealreg_id__c = 'dealregid' + Test_DataFactory.autoNumber;
        dealreg.Supplier__c = accId;
        dealreg.Valid_for_Account__c = accId;
        return dealreg;
    }

    public static Call_Activity__c createCallActivity(Id campaignId, Id accountId) {
        Call_Activity__c callActivity = new Call_Activity__c();
        callActivity.Campaign__c = campaignId;
        callActivity.Account__c = accountId;
        return callActivity;
    }

    public static User_Performance__c createUserPerformance(User u) {
        User_Performance__c up = new User_Performance__c();
        up.Name = u.Name;
        up.User__c = u.Id;
        return up;
    }

    public static Yearly_Performance_Score__c createYearlyPerformanceScore(Id userPerformanceId) {
        Decimal monthlyAmount = 10000;
        Yearly_Performance_Score__c yp = new Yearly_Performance_Score__c();
        yp.Name = String.valueof(System.today().year());
        yp.Client_Meetings_Target__c = 12;
        yp.Competence_Events_Target__c = 12;
        //yp.Sales_Revenue_Target__c = 12*monthlyAmount;
        yp.Product_Sales_Revenue_Target__c = 6 * monthlyAmount;
        yp.Services_Sales_Revenue_Target__c = 6 * monthlyAmount;
        yp.User_Performance__c = userPerformanceId;
        return yp;
    }

    public static Lead createLead() {
        Lead lead = new Lead();
        lead.Firstname = 'test';
        lead.LastName = 'Test Lead';
        lead.Company = 'Test Company';
        lead.Status = 'Nytt';
        return lead;
    }

    public static Lead createPardotLead() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test Lead';
        lead.Company = 'Test Company';
        lead.Status = 'Nytt';
        lead.Pardot_Sync__c = 1;
        lead.Description_Pardot__c = 'Test Description';
        //lead.Form_Source__c = ; Restricted Picklist: values to be decided
        lead.Form_Source_URL__c = 'www.test.salesenabler.sfpardot.com';
        lead.LeadSource = SEConstants.LEAD_SOURCE_OTHER;
        lead.Product_Area__c = SEConstants.LEAD_PRODAREA_BB;
        return lead;
    }
    public static Lead createCygateLead() {
        Lead cygatelead = new Lead();
        cygatelead.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_CYGATE);
        cygatelead.FirstName = 'Test';
        cygatelead.LastName = 'Test Lead';
        cygatelead.Company = 'Test Company';
        cygatelead.Status = 'Nytt';
        cygatelead.Cygate_Sync__c = 1;
        cygatelead.Description_Pardot__c = 'Test Description';
        cygatelead.Form_Source_URL__c = 'www.test.salesenabler.sfpardot.com';
        cygatelead.LeadSource = SEConstants.LEAD_SOURCE_OTHER;
        cygatelead.Product_Area__c = SEConstants.LEAD_PRODAREA_CLOUD;
        return cygatelead;
    }

    public static Group getTestQueue() {
        Group testGroup = new Group(Type = 'Queue', Name = 'SalesEnabler Test Queue');
        insert testGroup;

        List<QueueSobject> testQueueConnections = new List<QueueSobject>();
        testQueueConnections.add(new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Lead'));
        testQueueConnections.add(new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Buy_Interest__c'));
        insert testQueueConnections;

        return testGroup;
    }

    // Author: Varma Alluri on 19.06.2017; SAEN-2360, To Bypass the User
    public static user getByPassUser() {
        Id profID = [SELECT id FROM Profile WHERE Name = 'System Administrator'].id;
        Test_DataFactory.autoNumber += 1;
        User u = new User(
            ProfileID = profID,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            FirstName = 'Sample',
            LastName = 'User',
            Username = 'test.telia11@telia.com',
            CommunityNickname = 'testUserBypass',
            Alias = 't1',
            Email = 'test1@email.com',
            MobilePhone = '+46 777777777',
            IsActive = true,
            Bypass_VR__c = true
        );
        u.Telia_Id__c = 'ABD' + Test_DataFactory.autoNumber; // added by P.P
        insert u;
        return u;
    }

    //Y.K SALEF-971,977
    //Create Mobile subscriptions
    public static List<Mobile_Subscription__c> createMobileSubscriptions(Integer numMobileSub) {
        List<Mobile_Subscription__c> mobileSub = new List<Mobile_Subscription__c>();

        for (Integer i = 0; i < numMobileSub; i++) {
            Mobile_Subscription__c m = new Mobile_Subscription__c(Name = 'TestMobilSubscription' + i);
            mobileSub.add(m);
        }

        return mobileSub;
    }

    //Y.K SALEF- 919
    // Returns a SOHO user
    public static User createSOHOUser() {
        User u = createNewUser();
        u.Profileid = getProfileId(SEUtility.PROFILE_SOHO_PR);
        u.UserRoleId = getUserRoleId('SS_SME_Sales_Luleå2_AM');
        return u;
    }

    // Returns a three level user hierarchy of SME users {SalesUnitManager, SalesTeamManager, Seller}
    public static List<User> createSOHOUserTeam() {
        List<User> ul = new List<User>();
        for (integer i = 0; i < 3; i++) {
            ul.add(createSOHOUser());
        }
        insert ul;
        return ul;
    }

    // Returns a three level seller hierarchy for a list of SME users {SalesUnitManager, SalesTeamManager, Seller}.
    public static List<Seller__c> createSOHOSellerTeam(List<User> ul) {
        List<Seller__c> sl = createSOHOSellerTeam(ul, null);
        return sl;
    }

    public static List<Seller__c> createSOHOSellerTeam(List<User> ul, Date startDate) {
        List<Seller__c> sl = new List<Seller__c>();
        Seller__c unitLeader = createSalesUnitManagerSeller(ul[0].Id, null);
        if (startDate != null) {
            unitLeader.Start_Date__c = startDate;
        }
        insert unitLeader;
        sl.add(unitLeader);
        Seller__c teamLeader = createSalesTeamManagerSeller(ul[1].Id, unitLeader.Id);
        if (startDate != null) {
            teamLeader.Start_Date__c = startDate;
        }
        insert teamLeader;
        sl.add(teamLeader);
        Seller__c seller = createSeller(ul[2].Id, teamLeader.Id);
        if (startDate != null) {
            seller.Start_Date__c = startDate;
        }
        insert seller;
        sl.add(seller);
        return sl;
    }

    public static functionsubscriptions__x MockRequestDataCreationFS() {
        functionsubscriptions__x subsObj = new functionsubscriptions__x();
        //subsObj.Account_c2b_org_nr__c='5876698089';
        subsObj.category__c = 'testtest';
        subsObj.offeringname__c = 'testoffering';
        return subsObj;
    }

    public static mobilesubscriptions__x MockRequestDataCreationMS() {
        mobilesubscriptions__x subsObj = new mobilesubscriptions__x();
        subsObj.Account_c2b_org_nr__c = '5876698089';
        subsObj.category__c = 'testtest';
        subsObj.offeringname__c = 'testoffering';
        return subsObj;
    }

    public static broadbandsubscriptions__x MockRequestDataCreationBS() {
        broadbandsubscriptions__x subsObj = new broadbandsubscriptions__x();
        subsObj.Account_c2b_org_nr__c = '5876698089';
        subsObj.category__c = 'testtest';
        subsObj.offeringname__c = 'testoffering';
        return subsObj;
    }
    public static Account SegmentedKKnrAccount() {
        Account a = new Account(Name = 'TestAccount');
        a.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_KK);
        a.Name = 'Test';
        a.Suggested_Business_Area__c = 'Enterprise';
        a.Suggested_Business_Unit__c = 'Enterprise Other';
        a.Suggested_SubBusinessUnitLvl1__c = 'Enterprise Other';
        a.Suggested_SubBusinessUnitLvl2__c = 'Enterprise Other';
        a.Suggested_Business_Sales_Unit__c = 'Enterprise P&K';
        a.Suggested_Sales_Unit__c = 'Key Account';
        a.Suggested_Sales_Team__c = 'P&K Key Key';
        a.Suggested_Delsegment__c = 'A11';
        return a;
    }
}