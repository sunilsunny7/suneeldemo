/**
 * Description:
 * SEUtility test class.
 *
 * Modifications:
 * 04.01.2022 [Tomass Brazovskis] SALEF-7949 - Added the 'getAccountsWithContactedDatesToUpdateTest' methods to test the correctness of the
 *              logic determining whether the Account 'Contacted...' dates should be updated with the values passed for consideration.
 **/
@isTest
public class Test_SEUtility {
    // SALEF-7949 - Constants to query test records
    public static final String BYPASS_USER_USERNAME = 'test.telia11@telia.com';
    public static final String SME_ACCOUNT_NAME = 'SME_Test_Account';

    /**@Description:
     * Test data setup method.
     * Modifications:
     *  04.01.2022 [TB] SALEF-7949 - Introduced.
     **/
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
        User byPassUser = Test_DataFactory.getByPassUser();
        // SALEF-7949 - ensure ByPass User Username value
        byPassUser.Username = BYPASS_USER_USERNAME;
        update byPassUser;

        System.runAs(byPassUser) {
            Account oneKundkontoAccount = Test_DataFactory.createOneKundkontoAccount();
            insert oneKundkontoAccount;
            oneKundkontoAccount.Kundkonto_Nr__c = 'Z101';
            update oneKundkontoAccount;
            List<Account> accounts = Test_DataFactory.createAccounts(2);
            accounts[0].ParentId = oneKundkontoAccount.Id;
            Account smeAccountTest = Test_DataFactory.createOneSMEAccount();
            smeAccountTest.ParentId = oneKundkontoAccount.Id;
            smeAccountTest.Name = SME_ACCOUNT_NAME;
            accounts.add(smeAccountTest);
            insert accounts;
            Opportunity opp = Test_DataFactory.createCygateOpportunity();
            opp.AccountId = smeAccountTest.Id;
            insert opp;
        }
    }

    @isTest
    static void getFirstDayOfYear() {
        for (Integer i = 3500; i < 5000; i++) {
            // System.debug('First day of the year '+i+' is '+SEUtility.getFirstDayOfTeliaYear(i).format());
            // System.debug('Last day of the year '+i+' is '+SEUtility.getLastDayOfTeliaYear(i).format());
        }
    }

    @isTest
    static void testLastAndFirstDayOfYearForNext15years() {
        Map<Integer, Date> startDayMap = new Map<Integer, Date>();
        Map<Integer, Date> endDayMap = new Map<Integer, Date>();

        startDayMap.put(2015, Date.newInstance(2014, 12, 29));
        endDayMap.put(2015, Date.newInstance(2016, 1, 3));

        startDayMap.put(2016, Date.newInstance(2016, 1, 4));
        endDayMap.put(2016, Date.newInstance(2017, 1, 1));

        startDayMap.put(2017, Date.newInstance(2017, 1, 2));
        endDayMap.put(2017, Date.newInstance(2017, 12, 31));

        startDayMap.put(2018, Date.newInstance(2018, 1, 1));
        endDayMap.put(2018, Date.newInstance(2018, 12, 30));

        startDayMap.put(2019, Date.newInstance(2018, 12, 31));
        endDayMap.put(2019, Date.newInstance(2019, 12, 29));

        startDayMap.put(2020, Date.newInstance(2019, 12, 30));
        endDayMap.put(2020, Date.newInstance(2021, 1, 3));

        startDayMap.put(2021, Date.newInstance(2021, 1, 4));
        endDayMap.put(2021, Date.newInstance(2022, 1, 2));

        startDayMap.put(2022, Date.newInstance(2022, 1, 3));
        endDayMap.put(2022, Date.newInstance(2023, 1, 1));

        startDayMap.put(2023, Date.newInstance(2023, 1, 2));
        endDayMap.put(2023, Date.newInstance(2023, 12, 31));

        startDayMap.put(2024, Date.newInstance(2024, 1, 1));
        endDayMap.put(2024, Date.newInstance(2024, 12, 29));

        startDayMap.put(2025, Date.newInstance(2024, 12, 30));
        endDayMap.put(2025, Date.newInstance(2025, 12, 28));

        startDayMap.put(2026, Date.newInstance(2025, 12, 29));
        endDayMap.put(2026, Date.newInstance(2027, 1, 3));

        startDayMap.put(2027, Date.newInstance(2027, 1, 4));
        endDayMap.put(2027, Date.newInstance(2028, 1, 2));

        startDayMap.put(2028, Date.newInstance(2028, 1, 3));
        endDayMap.put(2028, Date.newInstance(2028, 12, 31));

        startDayMap.put(2029, Date.newInstance(2029, 1, 1));
        endDayMap.put(2029, Date.newInstance(2029, 12, 30));

        startDayMap.put(2030, Date.newInstance(2029, 12, 31));
        endDayMap.put(2030, Date.newInstance(2030, 12, 29));

        startDayMap.put(2031, Date.newInstance(2030, 12, 30));
        endDayMap.put(2031, Date.newInstance(2031, 12, 28));

        startDayMap.put(2032, Date.newInstance(2031, 12, 29));
        endDayMap.put(2032, Date.newInstance(2033, 1, 2));

        startDayMap.put(2033, Date.newInstance(2033, 1, 3));
        endDayMap.put(2033, Date.newInstance(2034, 1, 1));

        startDayMap.put(2034, Date.newInstance(2034, 1, 2));
        endDayMap.put(2034, Date.newInstance(2034, 12, 31));

        startDayMap.put(2035, Date.newInstance(2035, 1, 1));
        endDayMap.put(2035, Date.newInstance(2035, 12, 30));

        startDayMap.put(2036, Date.newInstance(2035, 12, 31));
        endDayMap.put(2036, Date.newInstance(2036, 12, 28));

        for (Integer i = 2016; i <= 2036; i++) {
            System.debug(SEUtility.getFirstDayOfTeliaYear(i) + ' is the first day of the year ' + i);
            System.debug(SEUtility.getLastDayOfTeliaYear(i) + ' is the last day of the year ' + i);
            System.assertEquals(
                startDayMap.get(i),
                SEUtility.getFirstDayOfTeliaYear(i),
                'The first day of year ' +
                    i +
                    ' should be ' +
                    startDayMap.get(i) +
                    ' but is ' +
                    ((DateTime) SEUtility.getFirstDayOfTeliaYear(i)).format('E') +
                    ' ' +
                    SEUtility.getFirstDayOfTeliaYear(i).format()
            );
            System.assertEquals(
                endDayMap.get(i),
                SEUtility.getLastDayOfTeliaYear(i),
                'The last day of year ' + i + ' should be ' + endDayMap.get(i) + ' but is ' + SEUtility.getLastDayOfTeliaYear(i).format()
            );
            if (i == 2015 || i == 2020 || i == 2026 || i == 2032) {
                System.assertEquals(
                    371,
                    SEUtility.getFirstDayOfTeliaYear(i).daysBetween(SEUtility.getLastDayOfTeliaYear(i)) + 1,
                    'Number of days for year ' + i + ' doesn\'t match'
                );
            } else {
                System.assertEquals(
                    364,
                    SEUtility.getFirstDayOfTeliaYear(i).daysBetween(SEUtility.getLastDayOfTeliaYear(i)) + 1,
                    'Number of days for year ' + i + ' doesn\'t match'
                );
            }
        }
    }

    @isTest
    static void testTeliaQuarterCreationForNext15years() {
        Map<Integer, Map<Date, Date>> tempReturnMap = new Map<Integer, Map<Date, Date>>();
        for (Integer i = 2016; i <= 2036; i++) {
            tempReturnMap = SEUtility.getTeliaQuarterStartAndEndDates(i);
            //For every quarter
            for (Integer j : tempReturnMap.KeySet()) {
                //For every enddate in every quarter
                for (Date d : tempReturnMap.get(j).keySet()) {
                    //If the year has 53 weeks
                    if (j == 4 && (i == 2015 || i == 2020 || i == 2026 || i == 2032)) {
                        System.assertEquals(
                            98,
                            d.daysBetween(tempReturnMap.get(j).get(d)) + 1,
                            'Number of days for year ' + i + ' Q' + j + ' doesn\'t match up'
                        );
                    } else {
                        System.assertEquals(
                            91,
                            d.daysBetween(tempReturnMap.get(j).get(d)) + 1,
                            'Number of days between ' +
                                d.format() +
                                ' and ' +
                                tempReturnMap.get(j).get(d).format() +
                                ' for year ' +
                                i +
                                ' Q' +
                                j +
                                ' doesn\'t match up'
                        );
                    }
                }
            }
        }
    }

    @isTest
    static void testRecordTypes() {
        List<User> lstByPassUsers = [SELECT Id FROM User WHERE Username = :BYPASS_USER_USERNAME];
        System.runAs(lstByPassUsers[0]) {
            // V.A  Bypassing User
            Account acc = Test_DataFactory.createOneAccount();
            insert acc;

            Account accAfterInsert = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Account WHERE id = :acc.Id LIMIT 1];
            String recTypeName = SEUtility.getRecordTypeDevName(accAfterInsert.RecordTypeId);
            System.assertEquals(recTypeName, accAfterInsert.RecordType.DeveloperName);
            Id recTypeId = SEUtility.getRecordTypeId(accAfterInsert.RecordType.DeveloperName);
            System.assertEquals(recTypeId, accAfterInsert.RecordTypeId);
        }
    }
    @isTest
    static void testSolutionAreaName() {
        System.assertEquals('Unified and Mobile Communications', SEUtility.getSolutionAreaName('Unified Communications'));
        System.assertEquals('Services', SEUtility.getSolutionAreaName('Service'));
        System.assertEquals('Cloud Networking', SEUtility.getSolutionAreaName('Cloud Networking'));
        System.assertEquals('Mobility Management and Business Apps', SEUtility.getSolutionAreaName('Mobility Management'));
        System.assertEquals('IBS', SEUtility.getSolutionAreaName('IBS'));
        System.assertEquals('Other', SEUtility.getSolutionAreaName('Other'));
        System.assertEquals('Cygate Nätverk', SEUtility.getSolutionAreaName('Cygate Nätverk'));
        System.assertEquals('Cygate Säkerhet', SEUtility.getSolutionAreaName('Cygate Säkerhet'));
        System.assertEquals('Cygate Server/Lagring/Applikation', SEUtility.getSolutionAreaName('Cygate Server/Lagring/Applikation'));
        System.assertEquals('Cygate UC', SEUtility.getSolutionAreaName('Cygate UC'));
        System.assertEquals('Cygate DMD', SEUtility.getSolutionAreaName('Cygate DMD'));
        System.assertEquals('Cygate Infrastruktur', SEUtility.getSolutionAreaName('Cygate Infrastruktur'));
        System.assertEquals('Cygate Övrigt', SEUtility.getSolutionAreaName('Cygate Övrigt'));
    }

    @isTest
    static void testSolutionAreaCode() {
        System.assertEquals('UC ', SEUtility.getSolutionAreaCode('Unified and Mobile Communications'));
        System.assertEquals('Services ', SEUtility.getSolutionAreaCode('Services'));
        System.assertEquals('CN ', SEUtility.getSolutionAreaCode('Cloud Networking'));
        System.assertEquals('MM ', SEUtility.getSolutionAreaCode('Mobility Management and Business Apps'));
        System.assertEquals('IBS ', SEUtility.getSolutionAreaCode('IBS'));
        System.assertEquals('', SEUtility.getSolutionAreaCode('Other'));
    }

    @isTest
    static void testWriteMultiPicklistString() {
        System.assertEquals('Test1;Test2;Test3', SEUtility.writeMultiSelectPicklist(new Set<String>{ 'Test1', 'Test2', 'Test3' }));
    }

    @isTest
    static void testValidProfileNameDefinitions() {
        Set<String> profileIdNameSet = new Set<String>();
        for (Profile p : [SELECT Id, Name FROM Profile]) {
            profileIdNameSet.add(p.Name);
        }
        System.assert(profileIdNameSet.contains(SEUtility.PROFILE_SYS_ADMIN), 'Could not find a profile labelled ' + SEUtility.PROFILE_SYS_ADMIN);
        System.assert(profileIdNameSet.contains(SEUtility.PROFILE_TELIA_ADMIN), 'Could not find a profile labelled ' + SEUtility.PROFILE_TELIA_ADMIN);
        System.assert(profileIdNameSet.contains(SEUtility.PROFILE_LARGE), 'Could not find a profile labelled ' + SEUtility.PROFILE_LARGE);
        System.assert(profileIdNameSet.contains(SEUtility.PROFILE_SME), 'Could not find a profile labelled ' + SEUtility.PROFILE_SME);
        System.assert(profileIdNameSet.contains(SEUtility.PROFILE_CYGATE_SALES), 'Could not find a profile labelled ' + SEUtility.PROFILE_CYGATE_SALES);
        System.assert(profileIdNameSet.contains(SEUtility.PROFILE_GENERAL), 'Could not find a profile labelled ' + SEUtility.PROFILE_GENERAL);
    }
    ////
    @isTest
    static void testIsSystemAdmin() {
        Id SysAdminProfileId = [SELECT id FROM profile WHERE Name = :SEUtility.PROFILE_SYS_ADMIN LIMIT 1].id;
        SEUtility.isSystemAdmin(SysAdminProfileId);
        User SysAdminUser = [SELECT id, ProfileId FROM user WHERE ProfileId = :SysAdminProfileId LIMIT 1];
        SEUtility.isSystemAdmin(SysAdminUser);
        SEUtility.isEnterpriseBusinessAdminUser(SysAdminUser);
        Id LeadAgentProfileId = [SELECT id FROM profile WHERE Name = :SEUtility.PROFILE_LEADS_AGENT LIMIT 1].id;
        SEUtility.isLeadsAgent(LeadAgentProfileId);
        User LeadAgentUser = [SELECT id, ProfileId FROM user WHERE ProfileId = :LeadAgentProfileId LIMIT 1];
        SEUtility.isLeadsAgent(LeadAgentUser);
        Id CygateProfileId = [SELECT id FROM profile WHERE Name = :SEUtility.PROFILE_CYGATE_SALES LIMIT 1].id;
        User CygateUserUser = [SELECT id, ProfileId FROM user WHERE ProfileId = :CygateProfileId LIMIT 1];
        SEUtility.isCygateUser(CygateUserUser);
        Id TeliaProfileId = [SELECT id FROM profile WHERE Name = :SEUtility.PROFILE_TELIA_ADMIN LIMIT 1].id;
        User TeliaProfileIdUser = [SELECT id, ProfileId, UserRoleId FROM user WHERE ProfileId = :TeliaProfileId LIMIT 1];
        Opportunity oneOpportunity = [SELECT id FROM Opportunity LIMIT 1];
        SEUtility.isCygateUser(TeliaProfileIdUser);
        SEUtility.isTAMUserRole(TeliaProfileIdUser.UserRoleId);
        SEUtility.updateUserRoleFuture(TeliaProfileIdUser.id, TeliaProfileIdUser.UserRoleId);
        SEUtility.deactivateUserFuture(TeliaProfileIdUser.id);
        SEUtility.getLargeOppRectypeIds();
        SEUtility.getSolutionAreaFromRole('Services');
        SEUtility.GetAvailableRecordTypeNamesForSObject(oneOpportunity.getSObjectType());
        String subject = 'test mail';
        Exception e;
        List<Id> ids = new List<Id>{ CygateUserUser.id };
        SEUtility.sendExceptionMail(subject, e, ids);
    }

    /**@Description:
     * Ensure Account 'Contacted...' dates are updated with dates that are more recent
     * than the ones the fields are already storing.
     * Modifications:
     *  04.01.2022 [TB] SALEF-7949 - Introduced.
     **/
    @isTest
    static void getAccountsWithContactedDatesToUpdateTest_UpdateRequired() {
        List<User> lstByPassUsers = [SELECT Id FROM User WHERE Username = :BYPASS_USER_USERNAME];
        List<Account> lstSMEAccounts = [SELECT Id FROM Account WHERE Name = :SME_ACCOUNT_NAME];

        Map<Id, Map<String, Date>> mapAccIdsToMapContactedFieldNamesToDates = new Map<Id, Map<String, Date>>();

        // System.today() returns the date according to the User's time zone. Therefore, both
        // assertion and Date-type field value assignments must be performed within the same
        // User context.
        System.runAs(lstByPassUsers[0]) {
            // Set a 'Contacted' date that should be updated by a more recent one
            lstSMEAccounts[0].Contacted__c = System.today().addDays(-1);
            update lstSMEAccounts;
            // Construct a map with 'Contacted' mapped to a more recent date than the fields
            // current value
            mapAccIdsToMapContactedFieldNamesToDates.put(
                lstSMEAccounts[0].Id,
                new Map<String, Date>{
                    SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED => System.today(),
                    SEUtility.ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB => System.today(),
                    SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING => System.today()
                }
            );
            Test.startTest();
            List<Account> lstAccountsToUpdate = SEUtility.getAccountsWithContactedDatesToUpdate(mapAccIdsToMapContactedFieldNamesToDates);
            Test.stopTest();
            System.assertEquals(1, lstAccountsToUpdate.size(), 'Account not recognized as requiring \'Contacted\' field update');
            System.assertEquals(
                System.today(),
                lstAccountsToUpdate[0].get(SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED),
                'Account \'Contacted\' field value has not been updated to the most recent date.'
            );
        }
    }

    /**@Description:
     * Ensure Account 'Contacted...' dates are not updated with dates earlier than
     * the ones the fields are already storing.
     * Modifications:
     *  04.01.2022 [TB] SALEF-7949 - Introduced.
     **/
    @isTest
    static void getAccountsWithContactedDatesToUpdateTest_UpdateNotRequired() {
        List<User> lstByPassUsers = [SELECT Id FROM User WHERE Username = :BYPASS_USER_USERNAME];
        List<Account> lstSMEAccounts = [SELECT Id FROM Account WHERE Name = :SME_ACCOUNT_NAME];

        Map<Id, Map<String, Date>> mapAccIdsToMapContactedFieldNamesToDates = new Map<Id, Map<String, Date>>();

        // System.today() returns the date according to the User's time zone. Therefore, both
        // assertion and Date-type field value assignments must be performed within the same
        // User context.
        System.runAs(lstByPassUsers[0]) {
            // Set a 'Contacted...' dates that is more recent than the dates to be evaluated
            lstSMEAccounts[0].put(SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED, System.today());
            lstSMEAccounts[0].put(SEUtility.ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB, System.today());
            lstSMEAccounts[0].put(SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING, System.today());
            update lstSMEAccounts;
            // Construct a map with 'Contacted...' field names mapped
            // to dates earlier than the fields' current values
            mapAccIdsToMapContactedFieldNamesToDates.put(
                lstSMEAccounts[0].Id,
                new Map<String, Date>{
                    SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED => System.today().addDays(-1),
                    SEUtility.ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB => System.today().addDays(-1),
                    SEUtility.ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING => System.today().addDays(-1)
                }
            );
            Test.startTest();
            List<Account> lstAccountsToUpdate = SEUtility.getAccountsWithContactedDatesToUpdate(mapAccIdsToMapContactedFieldNamesToDates);
            Test.stopTest();
            System.assert(lstAccountsToUpdate.isEmpty(), 'Account mistakenly recognized as requiring \'Contacted\' field value update.');
        }
    }
    @isTest
    static void isHealthTeamTest() {
        Test.startTest();
        Id healthcareRoleId = [SELECT Id FROM userRole WHERE DeveloperName = 'Healthcare_Team'].Id;
        Test.stopTest();
        Assert.isTrue(SEUtility.isHealthTeam(healthcareRoleId));
    }
    @isTest
    static void isIBSTeamTest() {
        Test.startTest();
        Id ibsRoleId = [SELECT Id FROM userRole WHERE DeveloperName = 'IBS_Team'].Id;
        Test.stopTest();
        Assert.isTrue(SEUtility.isIBSTeam(ibsRoleId));
    }
    @isTest
    static void isBusinessConsultantTest() {
        Test.startTest();
        Id isBusinessConsultantId = [SELECT Id FROM userRole WHERE DeveloperName = 'Business_Consultant'].Id;
        Test.stopTest();
        Assert.isTrue(SEUtility.isBusinessConsultant(isBusinessConsultantId));
    }
    @isTest
    static void isLargeUserTest() {
        Test.startTest();
        User largeUser = Test_DataFactory.createLargeUser();
        Test.stopTest();
        Assert.isTrue(SEUtility.isLargeUser(largeUser));
    }
    @isTest
    static void isPRUserTest() {
        Test.startTest();
        User prUser = Test_DataFactory.createPRUser();
        Test.stopTest();
        Assert.isTrue(SEUtility.isPRUser(prUser));
    }
    @isTest
    static void getCampaignMemberStatusTest() {
        Test.startTest();
        Campaign teliaCampaign = Test_DataFactory.createTeliaCampaign();
        teliaCampaign.Type = 'Mejl';
        Test.stopTest();
        Assert.isTrue(SEUtility.getCampaignMemberStatus(teliaCampaign) != null);
    }
    @isTest
    static void getForecastingTypeIdTest() {
        Test.startTest();
        String forcastName = [SELECT Id, MasterLabel, DeveloperName, IsActive FROM ForecastingType WHERE isActive = TRUE LIMIT 1].DeveloperName;
        Test.stopTest();
        Assert.isTrue(SEUtility.getForecastingTypeId(forcastName) != null);
    }
    @isTest
    static void getWeekNumberAsStringTest() {
        Assert.isTrue(SEUtility.getWeekNumberAsString(date.today()) != null);
    }
    @isTest
    static void getQuarterNrFromWeekTest() {
        Assert.isTrue(SEUtility.getQuarterNrFromWeek(1) != null);
    }
    @isTest
    static void getWeeksInQuarterTest() {
        Assert.isTrue(SEUtility.getWeeksInQuarter(1, 2023) != null);
    }
    @isTest
    static void getPeriodNumberTest() {
        Assert.isTrue(SEUtility.getPeriodNumber(date.today()) != null);
    }
    @isTest
    static void getSalesTargetDistributionMapTest() {
        Assert.isTrue(SEUtility.getSalesTargetDistributionMap() != null);
    }
    @isTest
    static void getWeeksTest() {
        Assert.isTrue(SEUtility.getSalesTargetDistributionMap() != null);
        Test.startTest();
        User largeUser = Test_DataFactory.createLargeUser();
        Seller__c oneSeller = Test_DataFactory.createSeller(largeUser.Id, null);
        Yearly_Target__c year = Test_DataFactory.createOneYearlyTarget(oneSeller);
        Quarterly_Forecast_Item__c quarterlyForecastItem = new Quarterly_Forecast_Item__c(
            Name = '1',
            User__c = largeUser.Id,
            Start_Date__c = date.today(),
            End_Date__c = date.today() + 10,
            New_Sales_Target__c = 2000,
            Continuation_Sales_Target__c = 2000,
            Sales_Value_Target__c = 2000,
            Yearly_Target__c = year.Id,
            Belongs_To_Year__c = 2023
        );
        Test.stopTest();
        Assert.isTrue(
            SEUtility.getWeeks(
                quarterlyForecastItem.Id,
                2023,
                '04',
                10000.00,
                10000.00,
                10000.00,
                largeUser.Id,
                date.today(),
                date.today().addDays(10),
                oneSeller.Id
            ) != null
        );
    }
    @isTest
    static void getSolutionAreaNameTest() {
        Assert.isTrue(SEUtility.getSolutionAreaName('Solution') == 'Business Management');
        Assert.isTrue(SEUtility.getSolutionAreaName('ProCare') == 'Health Care');
        Assert.isTrue(SEUtility.getSolutionAreaName('HomeCare') == 'HomeCare');
        Assert.isTrue(SEUtility.getSolutionAreaName('IoT') == 'Division X');
        Assert.isTrue(SEUtility.getSolutionAreaName('Collaboration & UC - Cloud Communicaton Solutions') == 'Collaboration & UC');
        Assert.isTrue(SEUtility.getSolutionAreaName('Customer Meeting - Customer Meeting') == 'Customer Meeting');
        Assert.isTrue(SEUtility.getSolutionAreaName('eID & Security - Business Network') == 'eID & Security');
        Assert.isTrue(SEUtility.getSolutionAreaName('Equipment - EMM') == 'Equipment');
        Assert.isTrue(SEUtility.getSolutionAreaName('IoT - Connectivity') == 'IoT');
        Assert.isTrue(SEUtility.getSolutionAreaName('Networks - Broadband') == 'Networks');
        Assert.isTrue(SEUtility.getSolutionAreaName('Cygate') == 'Cygate');
        Assert.isTrue(SEUtility.getSolutionAreaName('TEST') == '');
    }
    @isTest
    static void getSolutionAreaCodeTest() {
        Assert.isTrue(SEUtility.getSolutionAreaCode('Business Management') == 'BM ');
        Assert.isTrue(SEUtility.getSolutionAreaCode('Health Care') == 'HC ');
        Assert.isTrue(SEUtility.getSolutionAreaCode('Collaboration & UC') == 'CU');
        Assert.isTrue(SEUtility.getSolutionAreaCode('eID & Security') == 'eIdSec');
        Assert.isTrue(SEUtility.getSolutionAreaCode('Equipment') == 'EQ');
        Assert.isTrue(SEUtility.getSolutionAreaCode('Customer Meeting') == 'CM');
        Assert.isTrue(SEUtility.getSolutionAreaCode('IoT') == 'IoT');
        Assert.isTrue(SEUtility.getSolutionAreaCode('Networks') == 'NW');
    }
    @isTest
    static void getSolutionAreaFromRoleTest() {
        Assert.isTrue(SEUtility.getSolutionAreaFromRole(null) == '');
        Assert.isTrue(SEUtility.getSolutionAreaFromRole('Unified') == 'Unified and Mobile Communications');
        Assert.isTrue(SEUtility.getSolutionAreaFromRole('Bus Design Netw') == 'Cloud Networking');
        Assert.isTrue(SEUtility.getSolutionAreaFromRole('Applications') == 'Mobility Management and Business Apps');
        Assert.isTrue(SEUtility.getSolutionAreaFromRole('IBS') == 'IBS');
        Assert.isTrue(SEUtility.getSolutionAreaFromRole('TEST') == '');
    }
    @isTest
    static void getRenewalRolesTest() {
        Test.startTest();
        User renewalUser = Test_DataFactory.createLargeRenewalUser();
        Test.stopTest();
        Assert.isFalse(SEUtility.getRenewalRoles(renewalUser.Id));
    }
    @isTest
    static void getSOHONewSalesTargetDistributionMapTest() {
        Assert.isTrue(SEUtility.getSOHONewSalesTargetDistributionMap() != null);
    }
    @isTest
    static void getRecordTypesMassTest() {
        Assert.isTrue(SEUtility.getRecordTypes('MassCustomized', 'Quote') != null);
    }
    @isTest
    static void getRecordTypesCRMTest() {
        Assert.isTrue(SEUtility.getRecordTypes('CRMFiber', 'Quote') != null);
    }
    @isTest
    static void errorLoggingTest() {
        try {
            Integer value = 1 / 0;
        } catch (Exception ex) {
            SEUtility.errorLogging('Error', 'TEST_SEUtility', 'errorLoggingTest', ex);
            Integer errorCount = [SELECT id FROM Application_Logs__c].size();
            Assert.isTrue(errorCount == 1, 'Failed to create Error Record');
        }
    }
}