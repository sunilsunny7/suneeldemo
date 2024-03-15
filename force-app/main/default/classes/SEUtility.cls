/**
    About
    -----
    Description: Before insert and after insert trigger on Yearly_Target__c object
    Create date: ? 

    Update History
    --------------
    Created ? - C.G.
    Updated Aug 2015 - V.I. Bug fix. Changed how the start and end week in each quarter is calculated in the getTeliaWeeks method. Also changed the getWeekNubmer method
    Updated Aug 2015 - V.I Added an if-statement in the repointOpportunity method that make sure that if the close date on the opportunity doesn't match any existing weekly
                        forecast item then the Weekly_Target__c field should be set to null
    Updated Sep 2015 - V.I In repointOpportunity added check so that the opportunity seller matches the weekly forecast seller
    Updated Sep 2015 - V.I In repointOpportunity added a filter so that prospect opportunities are not pointed to a weekly forecast item
    Updated Sep 2015 - A.N Created new methods to fetch record type id's/names
    Updated Oct 2015 - V.I Created new method to map solution area with product

     & getSolutionAreaCode method
    Updated Oct 2015 - V.I Updated the setSeller method to add the Account Owner seller record for Large opportunities
    Updated Dec 2015 - A.N Deleted outcommented code and debug statements
    Updated Jan 2016 - A.N Commented out method repointOpportunities. Set opp close date logic reimplemented in opp trigger handler
    Updated Jan 2016 - A.N New method isLargeOpp. Added new methods to get opp Split record type ids based on developer name
    Updated Feb 2016 - A.N Moved method setMemberStatuses from SEUtility to CampaignTriggerHandler as it is not used anywhere else than in the trigger
    Updated Feb 2016 - A.N Created new method getCampaignMemberStatus. This is used by both the Campaign trigger and the Task trigger
    Updated Feb 2016 - A.N Moved method sendExceptionMail from other classes into the SEUtility to have it defined in one place only
    Updated Feb 2016 - A.N Created method getExceptionEmailRecepients
    Updated Apr 2016 - A.N Added new cygate opportunity record types
    Updated Apr 2016 - A.N Changed setSellerOnOpportunity method so that for cygate opps no Seller is set
    Updated May 2016 - P.P Added logic for Sales Value Target
    Updated May 2016 - S.S changed getSolutionAreaFromRole method because of change in role so that it returns correct Solution Area
    Updated May 2016 - A.N Added filter criteria on setSellerOnOpportunity: If lead is converted (currently only done by Cygate), do not throw error if no Seller
    Updated May 2016 - A.N getSolutionAreaName modified functionality for Cygate Products
    Updated Sep 2016 - A.N Refactored. Removed unused method: getYear. Smaller code clean up changes in some methods, no functional changes
                        Removed hardcoded id definition for Large rec type ids, replaced with new method getLargeOppRectypeIds
    Updated Sep 2016 - N.G Changed setSellerOnOpportunity method so that for SOHO_PR opps no Seller is set,
                        Added new PR opportunity record types and removed SOHO opp record types (Basically replaced SOHO with PR because PR don't need seller registry as SME/SOHO-DS does),
                        Added new PR User, Added PR Opp types under 'Opportunity Helper Methods'
    Updated Sep 2016 - A.N Restructured and categorized methods according to functional area/related sObject
    Updated Oct 2016 - P.P Case 1990 Created new method 'deleteOppSplits' under 'Forecasting/Opportunity Split Methods' to delete splits for Large Forenklad Opportunity
    Updated Nov 2016 - A.N SAEN-2022/1799. Bug fix in setSellerOpportunity: For prospects, seller is not required if user is Soho-PR. This was previously
                        implemented (in september) but has at some point been overwritten, so put this code back.
    Updated Nov 2016 - A.N SAEN-2012 created new method isTAMUserRole. Replaced method loadCygateUserRoleIds with loadUserRoleIds that 
                        loads both Cygate and TAM user roles and then assigns them to cygateRoleIds/tamRoleIds accordingly
    Updated Apr 2017 - P.P Case 2685 : Changes to include SOHO PR in FOL functionality so that Commit View works for SOHO PR Records Types
    Updated May 2017 - P.P Case 3081 Created new method 'getRenewalRoles' to understand if a renewal role is referenced.
    Updated March 2018 - P.S : Case 799 - Updated If-else in method-getSolutionAreaName(String family) for Product family -'HomeCare'
    Issues / TODOs
    Updated Feb 2018 - Y.K : Case 842- Targets (Sales) automatic update
    Updated Apr 2018 - Y.K : Case 919 - Change phasing of New Sales targets for SOHO Sales
    Updated Sept 2018 - P.S : SALEF-1499 - Updated If-else in method-getSolutionAreaName(String family) for Product family -'Data Insights'
    Updated Feb 2019 - S.K : Updated the section Opportunity Helper Methods to include a new property to return Real Estate Fiber record type to the OpportunityTriggerHandler
    Updated Oct 2019 - Y.K : New Roles Business Consultant Manager and Business Consultant
    Updated Jan 2020 - R.K : getRecordTypes(String project, string developerName)
    Updated Jan 2020 - R.K : isRecordTypeAvailable(String project, string developerName, string recordType)
    Updated Apr 2020 - Y.K : SALEF-3106 - Updated If-else in method-getSolutionAreaName(String family) for Product family -'Services - Professional Services'
    29.12.2022 [Tomass Brazovskis] SALEF-7949 - Replaced setAccountContactedDate() with getAccountsWithContactedDatesToUpdate().
    --------------  
    
*/

public class SEUtility {
    /* * * * * * * * * * * * * * * * * * * * */
    /* * User/Profile/Role Helper Methods  * */
    /* * * * * * * * * * * * * * * * * * * * */

    public static final String ROLE_RENEWAL = 'Renewal';
    private static Boolean bypassValidation;
    public static Boolean isBypassValidation() {
        List<User> ulist = new List<User>();
        if (bypassValidation == null) {
            ulist = [SELECT Bypass_VR__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        }
        if (ulist.size() > 0) {
            bypassValidation = ulist[0].Bypass_VR__c;
        }
        if (bypassValidation != null) {
            return bypassValidation;
        } else {
            return false;
        }
    }

    //Status Values  :Added by Rajni
    public static final String FIBER = 'CRMFiber';
    public static final String MC = 'MassCustomized';
    public static final String QUOTE = 'Quote';
    public static final String CONTRACT = 'Contract';
    public static final String OPPORTUNITY = 'Opportunity';

    // SALEF-8276: Procedures to only perform once in case of trigger recursions
    public static final String BUY_INTEREST_THOLBOX = 'BuyInterestTholbox';
    //Status Values  :Added by Suneel
    public static final String SENT = 'Sent';
    public static final String SENTFORSIGNING = 'Sent for Signing';
    public static final String SIGNED = 'Signed';
    public static final String REJECTED = 'Rejected';
    public static final String ST = 'Sent';

    //String values :Added by Suneel
    public static final String CREATESA = 'createSA';
    public static final String INCLUDED = 'includedOffers';
    public static final String SELECTED = 'putSelectedOffers';
    public static final String FRAMEAGREEMENT = 'Ramavtal';
    public static final String SERVICEAGREEMENT = 'Tjänsteavtal';

    //String values :Added by Praveena
    public static final String REALESTATEFIBER = 'Connected & Smart Building';

    // PROFILE NAME STRING VALUES
    public static final String PROFILE_SYS_ADMIN = 'System Administrator';
    public static final String PROFILE_Fiber_Base = 'Fiber Base Profile';
    public static final String PROFILE_TELIA_ADMIN = 'Enterprise Business Admin';
    public static final String PROFILE_LARGE = 'Telia Sales - Large';
    public static final String PROFILE_SME = 'Telia Sales - SME';
    public static final String PROFILE_CYGATE_SALES = 'Telia Cygate - Sales';
    public static final String PROFILE_GENERAL = 'Telia Sales - Business Support';
    public static final String PROFILE_SOHO_PR = 'Telia Sales - SOHO PR';
    public static final String PROFILE_LEADS_AGENT = 'Telia - Leads Agent';
    public static final String PROFILE_SERVICE_MANAGER = 'Telia Sales - Service';
    public static final String PROFILE_SOHO_DS = 'Telia Sales - SOHO DS';
    //Cygate role names
    public static final string ROLE_SALJ_SUPPORT = 'CG:Sales Support Norr';
    public static final string ROLE_SALJ_CHEF = 'CG:Säljsupport Chef';
    public static final string ROLE_HYBRID_IT_SALES_CHEF = 'CG:Erbjudande Hybrid IT chef';
    public static final string ROLE_HYBRID_IT_SALES = 'CG:Erbjudande Hybrid IT';

    //Roles
    public static final string ROLE_HEALTH_CARE = 'Healthcare Team';
    public static final string ROLE_IBS_TEAM = 'IBS Team';
    public static final string ROLE_BUSINESS_CONSULTANT = 'Business Consultant'; //Y.K SALEF-2529

    // SALEF-7949 - Account 'Contacted...' fields API Names
    public static final String ACCOUNT_FIELD_API_NAME_CONTACTED = Schema.SObjectType.Account.fields.Contacted__c.getName();
    public static final String ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB = Schema.SObjectType.Account.fields.SME_Contacted_MyBusiness__c.getName();
    public static final String ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING = Schema.SObjectType.Account.fields.Contacted_Quality_Meeting__c.getName();

    // Maps to hold the relationships between profile ids and name
    private static Map<Id, String> profileIdNameMap;
    public static Map<String, Id> profileIdMapName;
    private static Map<Id, String> roleIdNameMap;

    public static Boolean isHealthTeam(Id RoleId) {
        loadRoleIdMap();
        String roleName = roleIdNameMap.get(RoleId);
        if (roleName != null) {
            if (roleName == ROLE_HEALTH_CARE) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isIBSTeam(Id RoleId) {
        loadRoleIdMap();
        String roleName = roleIdNameMap.get(RoleId);
        if (roleName != null) {
            if (roleName == ROLE_IBS_TEAM) {
                return true;
            }
        }
        return false;
    }
    //Y.K SALEF-2529
    public static Boolean isBusinessConsultant(Id RoleId) {
        loadRoleIdMap();
        String roleName = roleIdNameMap.get(RoleId);
        if (roleName != null) {
            if (roleName == ROLE_BUSINESS_CONSULTANT) {
                return true;
            }
        }
        return false;
    }

    private static void loadRoleIdMap() {
        if (roleIdNameMap == null) {
            roleIdNameMap = new Map<Id, String>();
            for (UserRole p : [SELECT Id, Name FROM UserRole]) {
                roleIdNameMap.put(p.Id, p.Name);
            }
        }
    }

    // Method to select all profiles from the system and put them into a map
    // This method ensures that profiles are only loaded once from the database during any system operation (Only one SOQL-query)
    private static void loadProfileIdMap() {
        if (profileIdNameMap == null) {
            profileIdNameMap = new Map<Id, String>();
            for (Profile p : [SELECT Id, Name FROM Profile]) {
                profileIdNameMap.put(p.Id, p.Name);
            }
        }
    }

    public static void loadProfileMapId() {
        if (profileIdMapName == null) {
            profileIdMapName = new Map<String, Id>();
            for (Profile p : [SELECT Id, Name FROM Profile]) {
                profileIdMapName.put(p.Name, p.Id);
            }
        }
    }

    public static Boolean isSystemAdmin(Id profileId) {
        loadProfileIdMap();
        String profileName = profileIdNameMap.get(profileId);
        if (profileName != null) {
            if (profileName == PROFILE_SYS_ADMIN) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isSystemAdmin(User u) {
        loadProfileIdMap();
        String profileName = profileIdNameMap.get(u.ProfileId);
        if (profileName != null) {
            if (profileName == PROFILE_SYS_ADMIN) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isSmeUser(User u) {
        return isSmeUser(u.ProfileId);
    }

    public static Boolean isSmeUser(Id profileId) {
        loadProfileIdMap();
        String profileName = profileIdNameMap.get(ProfileId);
        if (profileName != null) {
            if (profileName == PROFILE_SME || profileName == PROFILE_GENERAL || profileName == PROFILE_SYS_ADMIN) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isLeadsAgent(User u) {
        return isSmeUser(u.ProfileId);
    }

    public static Boolean isLeadsAgent(Id profileId) {
        loadProfileIdMap();
        String profileName = profileIdNameMap.get(ProfileId);
        if (profileName != null) {
            if (profileName == PROFILE_LEADS_AGENT) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isLargeUser(User u) {
        loadProfileIdMap();
        String profileName = profileIdNameMap.get(u.ProfileId);
        if (profileName != null) {
            if (profileName == PROFILE_LARGE || profileName == PROFILE_GENERAL || profileName == PROFILE_SYS_ADMIN) {
                return true;
            }
        }
        return false;
    }

    public static ID getProfileId(String Profilename) {
        loadProfileMapId();
        system.debug('profileIdMapName:-' + profileIdMapName);
        return profileIdMapName.get(Profilename);
    }

    public static Boolean isPRUser(User u) {
        return isPRUser(u.ProfileId);
    }

    public static Boolean isPRUser(Id profileId) {
        loadProfileIdMap();
        String profileName = profileIdNameMap.get(profileId);
        if (profileName != null) {
            if (profileName == PROFILE_SOHO_PR) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isCygateUser(User u) {
        return isCygateUser(u.ProfileId);
    }

    public static Boolean isCygateUser(Id profileId) {
        loadProfileIdMap();
        String profileName = profileIdNameMap.get(profileId);
        if (profileName != null) {
            if (profileName == PROFILE_CYGATE_SALES) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isEnterpriseBusinessAdminUser(User u) {
        return isEnterpriseBusinessAdminUser(u.ProfileId);
    }

    public static Boolean isEnterpriseBusinessAdminUser(Id profileId) {
        loadProfileIdMap();
        String profileName = profileIdNameMap.get(profileId);
        if (profileName != null) {
            if (profileName == PROFILE_TELIA_ADMIN) {
                return true;
            }
        }
        return false;
    }

    public static Boolean isSOHODSUser(User u) {
        return isSOHODSUser(u.ProfileId);
    }
    public static Boolean isSOHODSUser(Id profileId) {
        loadProfileIdMap();
        String profileName = profileIdNameMap.get(ProfileId);
        if (profileName != null) {
            if (profileName == PROFILE_SOHO_DS) {
                return true;
            }
        }
        return false;
    }

    // All User Roles where user role name starts with CG is considered to be Cygate User Roles
    private static Set<Id> cygateRoleIds; // Name LIKE 'CG%'
    private static Set<Id> tamRoleIds; // DeveloperName LIKE 'SS_SME_Sales_Partners%'

    private static void loadUserRoleIds() {
        List<UserRole> userRoles = [SELECT Id, DeveloperName FROM UserRole WHERE Name LIKE 'CG%' OR DeveloperName LIKE 'SS_SME_Sales_Partners%'];
        cygateRoleIds = new Set<Id>();
        tamRoleIds = new Set<Id>();
        for (UserRole ur : userRoles) {
            if (ur.DeveloperName.startsWith('SS_SME_Sales_Partners'))
                tamRoleIds.add(ur.Id);
            else
                cygateRoleIds.add(ur.Id);
        }
    }

    // The criteria for identifying Cygate users must be revised when Cygate Chatter Plus users are added to the system.
    public static Boolean isCygateUserRole(Id userRoleId) {
        if (cygateRoleIds == null)
            loadUserRoleIds();
        if (cygateRoleIds.contains(userRoleId)) {
            return true;
        }
        return false;
    }

    // Checks whether user is TAM (Telephone Account Manager).
    // Criteria is User Role = "SME Sales Partners"
    public static Boolean isTAMUserRole(Id userRoleId) {
        if (tamRoleIds == null)
            loadUserRoleIds();
        if (tamRoleIds.contains(userRoleId)) {
            return true;
        }
        return false;
    }

    // Author A.N.
    // This method will deactivate the Salesforce user. The method is run @future as updating a user in the same context as a custom object causes a MIXED DML Exception
    @future
    public static void deactivateUserFuture(String userId) {
        try {
            User u = [SELECT Id, isActive FROM User WHERE id = :userId LIMIT 1];
            u.isActive = false;
            update u;
        } catch (Exception e) {
            system.debug('Exception thrown: deactivateUserFuture. Input userId = ' + userId + '. Exception: ' + e);
        }
    }

    // Author A.N.
    // This method will update the Salesforce users userRole.
    // The method is run @future as updating a user in the same context as a custom object causes a MIXED DML Exception
    // If the userRole has an associated manager, the userRole manager will be updated to be the new user
    @future
    public static void updateUserRoleFuture(String userId, String inputUserRoleId) {
        try {
            // Update the user role of the user
            User u = [SELECT Id, UserRoleId FROM User WHERE id = :userId LIMIT 1];
            u.UserRoleId = inputUserRoleId;
            u.ForecastEnabled = true;
            update u;
            // Set the user as the Forecast Manager for the user role (but only if this user role previously had a forecast manager user defined)
            UserRole userRole = [SELECT Id, ForecastUserId FROM UserRole WHERE Id = :u.UserRoleId LIMIT 1];
            if (userRole != null && userRole.ForecastUserId != null) {
                userRole.ForecastUserId = u.Id;
                update userRole;
            }
        } catch (Exception e) {
            system.debug('Exception thrown: updateUserRoleFuture. Input userId = ' + userId + ', userRoleId = ' + inputUserRoleId + '. Exception: ' + e);
        }
    }

    /* * * * * * * * * * * * * */
    /* * Record Type Methods * */
    /* * * * * * * * * * * * * */

    /*
     *  Methods to fetch record type names/ids.
     *  By calling these methods we ensure that record types are only loaded once from the database
     *  during any system operation (Only one SOQL-query)
     *
     *  Methods:
     *  loadRecordTypes()
     *  getRecordTypeDevName(Id recordTypeId)
     *  getRecordTypeId(String developerName)
     *
     *  Author: Anders Nesbakken
     *  Date: September 2015
     */

    // SOBJECT RECORD TYPE STRING VALUES FOR API DEVELOPER NAMES
    // ACCOUNT
    public static final String ACC_RECTYPE_KK = 'Sales_Aggregation_Account';
    public static final String ACC_RECTYPE_KK_SEC1 = 'Kundkonto_S_k_1';
    public static final String ACC_RECTYPE_KK_SEC2 = 'Kundkonto_S_k_2';
    public static final String ACC_RECTYPE_LARGE = 'Large_Sales_Organisation_Account';
    public static final String ACC_RECTYPE_LARGE_SEC1 = 'Large_Organisation_S_k_1';
    public static final String ACC_RECTYPE_LARGE_SEC2 = 'Large_Organisation_S_k_2';
    public static final String ACC_RECTYPE_SME = 'Sales_Organisation_Account';
    public static final String ACC_RECTYPE_CYGATE_SUB = 'Cygate_Sub_Account';
    public static final String ACC_RECTYPE_RESELLER = 'Reseller_Accounts';
    public static final String ACC_RECTYPE_OMB = 'One_Man_Business';

    // OPPORTUNITY
    public static final String OPP_RECTYPE_SME_STANDARD = 'SME_standard';
    public static final String OPP_RECTYPE_SME_QUICK = 'SME_Quick';
    public static final String OPP_RECTYPE_LARGE_STANDARD = 'Large_Standard_process';
    public static final String OPP_RECTYPE_LARGE_ENLARGEMENT = 'Ut_kning_process';
    public static final String OPP_RECTYPE_LARGE_AFTERREG = 'After_Registration';
    public static final String OPP_RECTYPE_LARGE_MERFORSALJNINGSMOJLIGHET = 'Merforsaljningsmojlighet';
    public static final String OPP_RECTYPE_PROSPECT = 'Prospect_process';
    public static final String OPP_RECTYPE_CYGATE_STANDARD = 'Cygate_Standard_Opportunity';
    public static final String OPP_RECTYPE_CYGATE_ENLARGEMENT = 'Cygate_Utokning';
    public static final String OPP_RECTYPE_CYGATE_AFTERREG = 'Cygate_Efterregistrering';
    public static final String OPP_RECTYPE_TELIA_CYGATE = 'Telia_Cygate_Opportunity';
    public static final String OPP_RECTYPE_PR_QUICK = 'Soho_Quick';
    public static final String OPP_RECTYPE_PR_STANDARD = 'Soho_Standard';
    public static final String OPP_RECTYPE_SME_Efterregistering = 'SME_Efterregistrering';
    public static final String OPP_RECTYPE_CYGATE_AFFAR = 'Cygate_Aff_r';
    public static final String OPP_RECTYPE_CYGATE_WEBORDER = 'Cygate_Web_Orders';
    public static final String OPP_RECTYPE_HW_LARGE_STANDARD = 'HW_Large_Standard_process';

    // Updated by SK : FIBE-226 - To Include Real Estate Fiber record type

    public static final String OPP_RECTYPE_REALESTATEFIBER = 'Real_Estate_Fiber';

    // Updated by Simona wgj897 : To Include Wholesale record type

    public static final String OPP_RECTYPE_WHOLESALE = 'Wholesales_Opportunity';

    // EVENT
    public static final String EVENT_REC_TYPE_TELIA = 'Telia_Events';
    public static final String EVENT_REC_TYPE_CYGATE = 'Cygate_Events';

    // TASK
    public static final String TASK_REC_TYPE_SME = 'SME_Soho_Tasks';
    public static final String TASK_REC_TYPE_LARGE = 'Large_Task';
    public static final String TASK_REC_TYPE_CYGATE = 'Cygate_Tasks';

    // CAMPAIGN
    public static final String CAMPAIGN_RECTYPE_TELIA = 'Telia_Campaign';
    public static final String CAMPAIGN_RECTYPE_CYGATE = 'Cygate_Campaign';
    public static final String CAMPAIGN_RECTYPE_M2M = 'M2M_Campaign';

    // CONTACT
    public static final String CONTACT_RECTYPE_TELIA_USER = 'Telia_SF_user';
    public static final String CONTACT_RECTYPE_TELIA_INTERNAL = 'Telia_Intranet_Contact';
    public static final String CONTACT_RECTYPE_CYGATE_USER = 'Cygate_SF_User';
    public static final String CONTACT_RECTYPE_RESELLER = 'Reseller_Contact';
    public static final String CONTACT_RECTYPE_CUSTOMER = 'Customer_Contact';
    public static final String CONTACT_RECTYPE_CYGATE_CONTACT = 'Cygate_Contact';

    //CONTACT MANAGEMENT SEGMENTS
    public static string CONTACT_SEGMENT_TELIA = 'Telia';
    public static string CONTACT_SEGMENT_C_SB = 'C&SB';
    public static string CONTACT_SEGMENT_CYGATE = 'Cygate';
    public static string CONTACT_SEGMENT_MARKETING = 'Marketing';
    public static string CONTACT_SEGMENT_SERVICE_MANAGEMENT = 'Service Management';
    public static string CONTACT_SEGMENT_OTHER = 'Other';

    //Lead
    public static final String LEAD_RECTYPE_TELIA = 'Standard_Telia_Lead';
    public static final String LEAD_RECTYPE_CYGATE = 'Cygate_Lead';

    //CASE
    public static final String CASE_RECTYPE_ENTERPRISE = 'Enterprise';
    public static final String CASE_RECTYPE_SUB_CASE = 'Enterprise_Subcase';
    public static final String CASE_RECTYPE_SUPPORT = 'Telia_Company_Support';

    // Buy Interest
    public static final String BUY_INTEREST_RECTYPE_TELIA = 'Telia_Buy_Interest';
    public static final String BUY_INTEREST_RECTYPE_CYGATE = 'Cygate_Buy_Interest';

    //Contract
    public static final String Contract_TELIA = 'Competitor_Agreements';
    public static final String Contract_TELIA_Avtal = 'Telia_Agreements';
    public static final String Contract_CYGATE = 'Cygate_Competitor_Agreements';
    public static final String Contract_CYGATE_Avtal = 'Cygate_Agreement';
    public static final String Contract_FRAMEWORK_AGREEMENT = 'TeliaSE_Framework_Agreement';
    public static final String Contract_SERVICE_AGREEMENT = 'TeliaSE_Service_Agreement';

    // Maps to hold the relationships between record type ids and record type names
    private static Map<Id, RecordType> recordTypeIdMap;
    private static Map<String, RecordType> recordTypesDevNameMap;

    // Method to get the ID of a record type based on the record type developer name. Returns null if it doesn't match.
    public static Id getRecordTypeId(String developerName) {
        //If the map doesn't exist create and populate it
        if (recordTypesDevNameMap == null) {
            SEUtility.loadRecordTypes();
        }
        return (recordTypesDevNameMap.containsKey(developerName)) ? recordTypesDevNameMap.get(developerName).id : null;
    }

    // Method to get the developer name of a record type based on the record type id. Returns null if it doesn't match.
    public static String getRecordTypeDevName(Id recordTypeId) {
        //If the map doesn't exist create and populate it
        if (recordTypeIdMap == null) {
            SEUtility.loadRecordTypes();
        }
        return (recordTypeIdMap.containsKey(recordTypeId)) ? recordTypeIdMap.get(recordTypeId).developerName : null;
    }

    // Method to select all active record types from the system and put them into two maps where developer name and id is the keys
    // This method ensures that record types are only loaded once from the database during any system operation (Only one SOQL-query)
    private static void loadRecordTypes() {
        recordTypesDevNameMap = new Map<String, RecordType>();
        recordTypeIdMap = new Map<ID, RecordType>();

        for (RecordType rt : [SELECT Id, Name, developerName, SobjectType FROM RecordType WHERE isActive = TRUE]) {
            recordTypesDevNameMap.put(rt.developerName, rt);
            recordTypeIdMap.put(rt.id, rt);
        }
    }

    /* * * * * * * * * * * * * */
    /* * Price Book Methods  * */
    /* * * * * * * * * * * * * */

    // Developer Name definitions
    public static final String PRICEBOOK_TELIA = 'Telia_Standard_Price_Book';
    public static final String PRICEBOOK_TELIA_NEW = 'Telia_Price_Book';
    public static final String PRICEBOOK_TELIA_NEWID = Label.Telia_Price_Book_ID;
    public static final String PRICEBOOK_CYGATE = 'Cygate_Price_Book';
    public static final String PRICEBOOK_SOHO_PR = 'SOHO_PR_Price_Book';
    public static final String PRICEBOOK_JOINT = 'Telia_Cygate_Joint_Price_Book';

    // Updated by SK : FIBE-226 - To Include Real Estate Fiber record type
    public static final String PRICEBOOK_REALESTATEFIBER = 'Real_Estate_Fiber_Pricebook';

    // Updated by Simona wgj897 : LTAT-17984 - To Include Wholesale record type
    public static final String PRICEBOOK_WHOLESALE = 'Wholesale';


    private static Map<String, Pricebook2> priceBookDevNameMap;
    private static void loadPriceBooks() {
        priceBookDevNameMap = new Map<String, Pricebook2>();

        for (Pricebook2 pb : [SELECT Id, Developer_Name__c FROM Pricebook2 WHERE isActive = TRUE]) {
            priceBookDevNameMap.put(pb.Developer_Name__c, pb);
        }
        System.debug('AN-TEST: loaded priceBookDevNameMap ' + priceBookDevNameMap);
    }

    // Method to get the ID of a record type based on the record type developer name. Returns null if it doesn't match.
    public static Id getPriceBookId(String developerName) {
        //If the map doesn't exist create and populate it
        if (priceBookDevNameMap == null) {
            System.debug('AN-TEST: priceBookDevNameMap == null, loading price books');
            SEUtility.loadPriceBooks();
        }
        return (priceBookDevNameMap.containsKey(developerName)) ? priceBookDevNameMap.get(developerName).Id : null;
    }

    /* * * * * * * * * * * * * * * * * */
    /* * Opportunity Helper Methods  * */
    /* * * * * * * * * * * * * * * * * */

    // returns true if the opportunity record type id is defined as a large opportunity type
    private static Set<String> largeRecTypes = new Set<String>{
        OPP_RECTYPE_LARGE_STANDARD,
        OPP_RECTYPE_LARGE_ENLARGEMENT,
        OPP_RECTYPE_LARGE_AFTERREG,
        OPP_RECTYPE_LARGE_MERFORSALJNINGSMOJLIGHET,
        OPP_RECTYPE_HW_LARGE_STANDARD
    };
    public static Boolean isLargeOpp(Id recordTypeId) {
        return largeRecTypes.contains(getRecordTypeDevName(recordTypeId));
    }

    // returns a set with record type ids for all opportunity record types defined as Large
    // Use this for SOQL queries which should only return Large Opps
    public static Set<Id> getLargeOppRectypeIds() {
        Set<Id> largeOppRectypeIds = new Set<Id>();
        for (String str : largeRecTypes) {
            largeOppRectypeIds.add(getRecordTypeId(str));
        }
        return largeOppRectypeIds;
    }

    // returns true if the opportunity record type id is defined as a SME/DS opportunity type
    private static Set<String> smeRecTypes = new Set<String>{ OPP_RECTYPE_SME_STANDARD, OPP_RECTYPE_SME_QUICK, OPP_RECTYPE_SME_Efterregistering };
    public static Boolean isSMEOpp(Id recordTypeId) {
        return smeRecTypes.contains(getRecordTypeDevName(recordTypeId));
    }

    // returns true if the opportunity record type id is defined as a Cygate opportunity type
    private static Set<String> cygateRecTypes = new Set<String>{
        OPP_RECTYPE_CYGATE_STANDARD,
        OPP_RECTYPE_CYGATE_ENLARGEMENT,
        OPP_RECTYPE_CYGATE_AFTERREG,
        OPP_RECTYPE_CYGATE_AFFAR
    };
    public static Boolean isCygateOpp(Id recordTypeId) {
        return cygateRecTypes.contains(getRecordTypeDevName(recordTypeId));
    }

    // returns true if the opportunity record type id is defined as a PR opportunity type
    /*private static Set<String> prRecTypes = new Set<String>{OPP_RECTYPE_PR_QUICK, OPP_RECTYPE_PR_STANDARD};
    public static Boolean isPROpp(Id recordTypeId){
        return prRecTypes.contains(getRecordTypeDevName(recordTypeId));
    }*/

    // Updated by SK : FIBE-226 - To Include Real Estate Fiber record type

    private static Set<String> fiberRecTypes = new Set<String>{ OPP_RECTYPE_REALESTATEFIBER };
    public static Boolean isRealEstateFibereOpp(Id recordTypeId) {
        return fiberRecTypes.contains(getRecordTypeDevName(recordTypeId));
    }

    // Updated by Simona wgj897 : LTAT-17984 - To Include Wholesale record type
    private static Set<String> wholesaleRecTypes = new Set<String>{ OPP_RECTYPE_WHOLESALE };
    public static Boolean isWholesaleOpp(Id recordTypeId) {
        return wholesaleRecTypes.contains(getRecordTypeDevName(recordTypeId));
    }

    // Checks if the OpportunityTeamMember list has a member for the specified user
    private static Boolean isUserInOppTeam(Id userId, List<OpportunityTeamMember> otmList) {
        if (otmList.isEmpty())
            return false;
        for (OpportunityTeamMember otm : otmList) {
            if (otm.UserId == userId)
                return true;
        }
        return false;
    }

    // Sets/updates the seller lookup on opportunity. If Seller is required (i.e. for SME/Large), add error if no seller is found.
    public static void setSellerOnOpportunity(List<Opportunity> opps) {
        System.debug(LoggingLevel.ERROR, 'setSellerOnOpportunity method starts');

        // Create lists of related Accounts. If opp Record Type is Cygate, don't add acc to related acc Id's as we don't set seller for Cygate opps
        List<Id> relatedAccountIds = new List<Id>();
        for (Opportunity opp : opps) {
            if (!isCygateOpp(opp.RecordTypeId) && !isRealEstateFibereOpp(opp.RecordTypeId) && !isWholesaleOpp(opp.RecordTypeId)) {
                relatedAccountIds.add(opp.AccountId);
            }
        }

        // If relatedAccountIds is empty (i.e. all opps in list is type Cygate), exit method
        if (relatedAccountIds.size() == 0)
            return;

        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>([SELECT Id, OwnerId, Processed_By__c FROM Account WHERE Id IN :relatedAccountIds]);

        //Create lists of opportunity owners and related Accounts
        List<Id> owners = new List<Id>();
        for (Opportunity opp : opps) {
            owners.add(opp.OwnerId);
            if (accountIdToAccountMap.get(opp.AccountId) != null) {
                owners.add(accountIdToAccountMap.get(opp.AccountId).OwnerId);
            }
        }

        // Create map UserId -> List<Seller>
        Map<Id, List<Seller__c>> ownerIdToSellerMap = new Map<Id, List<Seller__c>>();
        List<Seller__c> sellers = [SELECT Id, User__c, Start_Date__c, End_Date__c, Sales_Team_Name__c FROM Seller__c WHERE User__c IN :owners];
        if (!sellers.isEmpty()) {
            for (Seller__c sel : sellers) {
                if (!ownerIdToSellerMap.containsKey(sel.User__c)) {
                    ownerIdToSellerMap.put(sel.User__c, new List<Seller__c>{ sel });
                } else {
                    ownerIdToSellerMap.get(sel.User__c).add(sel);
                }
            }
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, UserRoleId, ProfileId FROM User WHERE Id IN :owners]);
        List<Seller__c> sellersFound = new List<Seller__c>();
        for (Opportunity opp : opps) {
            // If Cygate opp, do not set seller, skip to the next iteration
            if (SEUtility.isCygateOpp(opp.RecordTypeId))
                continue;

            // If prospect is created by cygate user then no seller needed
            if (opp.RecordTypeId == getRecordTypeId(OPP_RECTYPE_PROSPECT) && isCygateUser(userMap.get(opp.OwnerId)))
                continue;

            sellersFound.clear();

            // For SME, an opportunity should be linked to the opp owners seller record which was active at the opp close date
            // if(ownerIdToSellerMap.get(opp.OwnerId) != null && (isSmeOpp(opp.RecordTypeId) || isPROpp(opp.RecordTypeId) || opp.RecordTypeId == getRecordTypeId(OPP_RECTYPE_HW_LARGE_STANDARD))){
            if (
                ownerIdToSellerMap.get(opp.OwnerId) != null &&
                (isSmeOpp(opp.RecordTypeId) || opp.RecordTypeId == getRecordTypeId(OPP_RECTYPE_HW_LARGE_STANDARD))
            ) {
                for (Seller__c sel : ownerIdToSellerMap.get(opp.OwnerId)) {
                    if (sel.Start_Date__c <= opp.CloseDate && (sel.End_Date__c == null || sel.End_Date__c >= opp.CloseDate)) {
                        opp.Seller__c = sel.Id;
                        sellersFound.add(sel);
                    }
                }
            }
            // For Large and Prospects, an opportunity should be linked to the current account owners seller record
            else if (accountIdToAccountMap.get(opp.AccountId) != null && ownerIdToSellerMap.get(accountIdToAccountMap.get(opp.AccountId).OwnerId) != null) {
                for (Seller__c sel : ownerIdToSellerMap.get(accountIdToAccountMap.get(opp.AccountId).OwnerId)) {
                    if (sel.Start_Date__c <= Date.today() && (sel.End_Date__c == null || sel.End_Date__c >= Date.today())) {
                        opp.Seller__c = sel.Id;
                        sellersFound.add(sel);
                    }
                }
            }
            //Add error if a matching seller is not found
            if (sellersFound.isEmpty() && !isBypassValidation() && !isRealEstateFibereOpp(opp.RecordTypeId)) {
                //removed this soql from here to before the FOR starts( to avoid too many soql inside for loop)
                //Map<Id, User> userMap = new  Map<Id, User>([SELECT Id, UserRoleId, ProfileId FROM User WHERE Id in :owners]);
                // if(isSmeOpp(opp.RecordTypeId) || isPROpp(opp.RecordTypeId)){
                if (isSmeOpp(opp.RecordTypeId)) {
                    // Note: The opp.Expected_Opportunity_Type__c is set when a lead is converted. Currently this is only implemented for Cygate.
                    // This filter must be edited if other user groups than Cygate is to convert leads, to ensure correct handling.
                    // Also: if the opp owner
                    if (opp.Expected_Opportunity_Type__c == null && !isTAMUserRole(userMap.get(opp.OwnerId).UserRoleId)) {
                        opp.addError('Säljaren måste vara inlagd i säljarlistan för att kunna vara ägare av en affärsmöjlighet');
                    }
                } else {
                    // Not SME/Cygate record type
                    if (isLargeOpp(opp.RecordTypeId) && !isCygateUserRole(userMap.get(accountIdToAccountMap.get(opp.AccountId).OwnerId).UserRoleId)) {
                        opp.addError('Kontoägaren måste vara inlagd i säljarlistan');
                    } else {
                        // Not SME/Large/Cygate/PR record type, i.e. the record type is either Prospect or Telia-Cygate common process,
                        // in which case Seller is only required if non-cygate (account owner), or non-PR user/TAM User (opp owner)
                        if (
                            accountIdToAccountMap.get(opp.AccountId) != null &&
                            !isCygateUserRole(userMap.get(accountIdToAccountMap.get(opp.AccountId).OwnerId).UserRoleId) &&
                            !isTAMUserRole(userMap.get(opp.OwnerId).UserRoleId)
                        ) {
                            opp.addError('Kontoägaren måste vara inlagd i säljarlistan');
                        }
                    }
                }
            }
            //If two sellers are found check if one of them belongs to the SME attack team. If that is the case look if the Account on the opportunity is processed by attack team. If yes then assign the attack team seller.
            else if (sellersFound.size() > 1) {
                for (Seller__c sel : sellersFound) {
                    if (
                        accountIdToAccountMap.get(opp.AccountId) != null &&
                        accountIdToAccountMap.get(opp.AccountId).Processed_By__c == 'Attack Team' &&
                        sel.Sales_Team_Name__c == 'SME Attack' &&
                        !isRealEstateFibereOpp(opp.RecordTypeId)
                    ) {
                        opp.Seller__c = sel.Id;
                        break;
                    } else if (
                        accountIdToAccountMap.get(opp.AccountId) != null &&
                        accountIdToAccountMap.get(opp.AccountId).Processed_By__c != 'Attack Team' &&
                        sel.Sales_Team_Name__c != 'SME Attack' &&
                        !isRealEstateFibereOpp(opp.RecordTypeId)
                    ) {
                        opp.Seller__c = sel.Id;
                        break;
                    } else {
                        opp.Seller__c = sel.Id;
                    }
                }
            }
        }
    }

    /* * * * * * * * * * * * * * * */
    /* * Account Helper Methods  * */
    /* * * * * * * * * * * * * * * */

    // returns true if the accounts record type is defined as a Security 2 account
    public static Boolean isSecurityLevel2Account(Id accRecordTypeId) {
        Set<String> sec2RecTypes = new Set<String>{ ACC_RECTYPE_KK_SEC2, ACC_RECTYPE_LARGE_SEC2 };
        return sec2RecTypes.contains(getRecordTypeDevName(accRecordTypeId));
    }

    // Is the account record type a KundKonto account record type
    public static Boolean isKundKontoAccountRecordType(String developerName) {
        if (developerName == ACC_RECTYPE_KK || developerName == ACC_RECTYPE_KK_SEC1 || developerName == ACC_RECTYPE_KK_SEC2) {
            return true;
        }
        return false;
    }
    public static Boolean isKundKontoAccountRecordType(Id recordTypeId) {
        return isKundKontoAccountRecordType(getRecordTypeDevName(recordTypeId));
    }

    // Is the account record type a Large account record type
    private static Set<String> largeAccountRecordTypes = new Set<String>{ ACC_RECTYPE_LARGE, ACC_RECTYPE_LARGE_SEC1, ACC_RECTYPE_LARGE_SEC2 };
    public static Boolean isLargeAccountRecordType(String developerName) {
        return largeAccountRecordTypes.contains(developerName);
    }

    public static Boolean isLargeAccountRecordType(Id recordTypeId) {
        return isLargeAccountRecordType(getRecordTypeDevName(recordTypeId));
    }

    // Is the account record type a SME account record type
    public static Boolean isSmeAccountRecordType(String developerName) {
        return (developerName == ACC_RECTYPE_SME);
    }

    public static Boolean isSmeAccountRecordType(Id recordTypeId) {
        return isSmeAccountRecordType(getRecordTypeDevName(recordTypeId));
    }

    /**
     * @Description:
     * Method takes a map of Account Ids to key-value pairs, where the key-value pairs have
     * 'Contacted..' field API Names as keys and the dates to consider for the field updates as values.
     * Method checks whether the Account 'Contacted...' fields should be updated with the passed dates.
     * Method returns the list of Accounts requiring updates, with the new 'Contacted...' values to set.
     * @author V.I. - original method accountTargeted (AccountServiceClass)
     * @param mapAccIdsToMapContactedFieldNamesToDates - Map in the format
     *          { '<acc1_Id>' : {'<Field1_API_Name>' : '<xxxx-xx-xx>', '<Field2_API_Name>' : '<xxxx-xx-xx>'},
     *            '<acc2_Id>' : {'<Field1_API_Name>' : '<yyyy-yy-yy>', '<Field3_API_Name>' : '<xxxx-xx-xx>'}}
     * @return List (can be empty) of Accounts with 'Contacted...' field values to update.
     * @Modifications:
     * 29.12.2022 [TB] SALEF-7949 - Introduced by refactoring setAccountContactedDate(Map<Id, DateTime> accIdToDateMap, String taskType).
     *              The original setAccountContactedDate() method was introduced by [V.I] in 03.2015. It had, subsequently, been modified
     *              by [A.N] in 09.2016 and [Aurimas Nausutis] in 11.2021 for SALEF-5324.
     **/
    public static List<Account> getAccountsWithContactedDatesToUpdate(Map<Id, Map<String, Date>> mapAccIdsToMapContactedFieldNamesToDates) {
        List<Account> lstAccountsToUpdate = new List<Account>();

        if (mapAccIdsToMapContactedFieldNamesToDates != null && !mapAccIdsToMapContactedFieldNamesToDates.isEmpty()) {
            for (Account curAccount : [
                SELECT Contacted__c, SME_Contacted_MyBusiness__c, Contacted_Quality_Meeting__c
                FROM Account
                WHERE Id IN :mapAccIdsToMapContactedFieldNamesToDates.keySet()
            ]) {
                Boolean curAccountUpdateRequired = false;
                Account accUpdatedVersion = new Account(Id = curAccount.Id);
                Map<String, Date> mapContactedFieldNamesToDates = mapAccIdsToMapContactedFieldNamesToDates.get(curAccount.Id);
                // Check whether the completed 'Log a Call' Activity is the Account's most recent
                if (
                    mapContactedFieldNamesToDates.containsKey(ACCOUNT_FIELD_API_NAME_CONTACTED) &&
                    (curAccount.Contacted__c == null ||
                    curAccount.Contacted__c < mapContactedFieldNamesToDates.get(ACCOUNT_FIELD_API_NAME_CONTACTED))
                ) {
                    curAccountUpdateRequired = true;
                    accUpdatedVersion.Contacted__c = mapContactedFieldNamesToDates.get(ACCOUNT_FIELD_API_NAME_CONTACTED);
                }
                // SALEF-5324 - 'Review MyBusiness'-type 'Log a Call' Activity closure 'Due Date' should be used to
                // update both the 'Contacted' and 'SME: Contacted MyBusiness' of its parent Account
                if (
                    mapContactedFieldNamesToDates.containsKey(ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB) &&
                    (curAccount.SME_Contacted_MyBusiness__c == null ||
                    curAccount.SME_Contacted_MyBusiness__c < mapContactedFieldNamesToDates.get(ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB))
                ) {
                    curAccountUpdateRequired = true;
                    accUpdatedVersion.Contacted__c = mapContactedFieldNamesToDates.get(ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB);
                    accUpdatedVersion.SME_Contacted_MyBusiness__c = mapContactedFieldNamesToDates.get(ACCOUNT_FIELD_API_NAME_SME_CONTACTED_MB);
                }
                // SALEF-7949 - 'Quality Meeting'-type 'Log a Call' Activity 'Due Date' should be considered to update both
                // the 'Contacted' and 'Contacted Quality Meeting' of its parent Account
                if (
                    mapContactedFieldNamesToDates.containsKey(ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING) &&
                    (curAccount.Contacted_Quality_Meeting__c == null ||
                    curAccount.Contacted_Quality_Meeting__c < mapContactedFieldNamesToDates.get(ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING))
                ) {
                    curAccountUpdateRequired = true;
                    accUpdatedVersion.Contacted__c = mapContactedFieldNamesToDates.get(ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING);
                    accUpdatedVersion.Contacted_Quality_Meeting__c = mapContactedFieldNamesToDates.get(ACCOUNT_FIELD_API_NAME_CONTACTED_QUALITY_MEETING);
                }
                if (curAccountUpdateRequired) {
                    lstAccountsToUpdate.add(accUpdatedVersion);
                }
            }
        }
        return lstAccountsToUpdate;
    }

    /* * * * * * * * * * * * * * * */
    /* * Campaign Helper Methods * */
    /* * * * * * * * * * * * * * * */

    /* Author C.G/V.I - Methods to get the correct Campaign_Member_Statuses__c custom setting record for a Campaign, based on the Campaign Type and Campaign Record Type
     *  There are two methods: Input can be provided as either a Campaign record, or directly with the Campaign Type and Campaign Record Type Id*/
    public static Campaign_Member_Statuses__c getCampaignMemberStatus(Campaign cm) {
        return getCampaignMemberStatus(cm.Type, cm.RecordTypeId);
    }

    public static Campaign_Member_Statuses__c getCampaignMemberStatus(String campaignType, Id campaignRecTypeId) {
        List<Campaign_Type_vs_Member_Statuses__c> campTypeVsStatusList = Campaign_Type_vs_Member_Statuses__c.getAll().values();

        for (Campaign_Type_vs_Member_Statuses__c cmTMS : campTypeVsStatusList) {
            if (campaignType == cmTMS.Campaign_Type__c && SEUtility.getRecordTypeDevName(campaignRecTypeId) == cmTMS.Record_Type__c) {
                return Campaign_Member_Statuses__c.getValues(cmTMS.Member_Status_Set__c);
            }
        }
        return null;
    }

    /* * * * * * * * * * * * * * * * * * * * * * */
    /* * Forecasting/Opportunity Split Methods * */
    /* * * * * * * * * * * * * * * * * * * * * * */

    // The opp Split type dev names are generated by salesforce and reference the opportunity field id for the field used by the opp type
    // The Forecasting Type dev names are also generated by salesforce and reference the opportunity field id
    // Developer Names are the same for both OpportunitySplitType and ForecastingType (but not the record type id's!)
    private static Map<String, OpportunitySplitType> oppSplitTypeDevNameMap;
    private static Map<String, ForecastingType> forecastingTypeDevNameMap;
    public static String OPP_SPLIT_TYPE_NS_DEVNAME = 'Opportunity_00N2400000IJnX7_Overlay'; // New Sales
    public static String OPP_SPLIT_TYPE_CS_DEVNAME = 'Opportunity_00N2400000IJnX6_Overlay'; // Continuation Sales
    public static String OPP_SPLIT_TYPE_S_DEVNAME = 'Opportunity_00N2400000Iz5Pi_Overlay'; //Sales
    // Sandbox Test To Be Deleted
    //public static String OPP_SPLIT_TYPE_WS_DEVNAME = 'Opportunity_00N26000000rcsi_Overlay'; // Weighted Sales Value
    // Prod Id To Be Set Before Deploy
    public static String OPP_SPLIT_TYPE_WS_DEVNAME = 'Opportunity_00N2400000Iz5Pi_Overlay'; // Weighted Sales Value

    // Author AN:
    // Method to get the ID of a opp split type based on the opp split type developer name. Returns null if it doesn't match.
    public static Id getOppSplitTypeId(String devName) {
        //If the map doesn't exist create and populate it
        if (oppSplitTypeDevNameMap == null) {
            loadOppSplitTypes();
        }
        return (oppSplitTypeDevNameMap.containsKey(devName)) ? oppSplitTypeDevNameMap.get(devName).Id : null;
    }

    // Author AN:
    // Method to get the ID of a opp split type based on the opp split type developer name. Returns null if it doesn't match.
    public static List<Id> getActiveOppSplitIds() {
        List<Id> activeOppSplitIds = new List<Id>();
        activeOppSplitIds.add(getOppSplitTypeId(OPP_SPLIT_TYPE_NS_DEVNAME));
        activeOppSplitIds.add(getOppSplitTypeId(OPP_SPLIT_TYPE_CS_DEVNAME));
        activeOppSplitIds.add(getOppSplitTypeId(OPP_SPLIT_TYPE_WS_DEVNAME));
        return activeOppSplitIds;
    }

    // Author AN:
    // Method to select all active opp split types from the system and put them into a map with id as the key
    private static void loadOppSplitTypes() {
        oppSplitTypeDevNameMap = new Map<String, OpportunitySplitType>();

        for (OpportunitySplitType ost : [SELECT Id, MasterLabel, DeveloperName, IsActive FROM OpportunitySplitType WHERE isActive = TRUE]) {
            oppSplitTypeDevNameMap.put(ost.DeveloperName, ost);
        }
    }

    // Author AN:
    // Method to get the ID of a Forecasting Type based on the Forecasting Type developer name. Returns null if it doesn't match.
    public static Id getForecastingTypeId(String devName) {
        //If the map doesn't exist create and populate it
        if (forecastingTypeDevNameMap == null) {
            loadForecastingTypes();
        }
        return (forecastingTypeDevNameMap.containsKey(devName)) ? forecastingTypeDevNameMap.get(devName).Id : null;
    }

    // Author AN:
    // Method to select all Forecasting Types from the system and put them into a map with dev name as the key
    private static void loadForecastingTypes() {
        forecastingTypeDevNameMap = new Map<String, ForecastingType>();

        for (ForecastingType ft : [SELECT Id, MasterLabel, DeveloperName, IsActive FROM ForecastingType WHERE isActive = TRUE]) {
            forecastingTypeDevNameMap.put(ft.DeveloperName, ft);
        }
    }

    // Creates an oppsplit for NS and CS and returns the list
    // Currently this is done for Large, Cygate and Soho PR opportunities:
    // - Large : Split Owner is the Account Owner
    // - Soho PR/Cygate: Split Owner is the Opportunity Owner
    public static void createOppSplits(Set<Id> oppIdList) {
        List<Id> oppSplitIds = getActiveOppSplitIds(); // Activate this line after deployed to test
        List<OpportunitySplit> oppSplitsToDelete = [
            SELECT Id, OpportunityId, SplitTypeId
            FROM OpportunitySplit
            WHERE SplitTypeId IN :oppSplitIds AND OpportunityId IN :oppIdList
        ];
        system.debug('oppSplitsToDelete is: ' + oppSplitsToDelete);
        if (!oppSplitsToDelete.isEmpty()) {
            delete oppSplitsToDelete;
        }

        List<OpportunityTeamMember> oppTeamMembersNew = new List<OpportunityTeamMember>();
        List<OpportunitySplit> oppSplitsNew = new List<OpportunitySplit>();

        for (Opportunity opp : [
            SELECT Id, OwnerId, Account.OwnerId, RecordTypeId, (SELECT UserId FROM OpportunityTeamMembers)
            FROM Opportunity
            WHERE Id IN :oppIdList AND AccountId != NULL
        ]) {
            Id splitOwnerId = (isLargeOpp(opp.RecordTypeId) ? opp.Account.OwnerId : opp.OwnerId); // If Large opp set to Account.OwnerId, otherwise use opp.OwnerId

            // If the user (the account owner) is not in the opp team, the user must be added to the opp team. If not, we will get an error when trying to create the opp splits.
            if (!isUserInOppTeam(splitOwnerId, opp.OpportunityTeamMembers)) {
                oppTeamMembersNew.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId = splitOwnerId, TeamMemberRole = 'CE/TE'));
            }
            // Create opp split records for NS/CS
            oppSplitsNew.addAll(createOppSplitRecords(opp.Id, splitOwnerId));
        }

        if (!oppTeamMembersNew.isEmpty()) {
            Database.insert(oppTeamMembersNew, false);
        }

        if (!oppSplitsNew.isEmpty()) {
            Database.insert(oppSplitsNew, false);
        }
    }

    // Creates an oppsplit for NS and CS and WS and returns the list
    private static List<OpportunitySplit> createOppSplitRecords(Id oppId, Id userId) {
        List<OpportunitySplit> oppSplits = new List<OpportunitySplit>();
        // Create the opp splits for NS and CS and WS
        OpportunitySplit oppSplitNS = new OpportunitySplit(OpportunityId = oppId, SplitOwnerId = userId, SplitPercentage = 100);
        oppSplitNS.SplitTypeId = getOppSplitTypeId(OPP_SPLIT_TYPE_NS_DEVNAME);
        oppSplits.add(oppSplitNS);
        OpportunitySplit oppSplitCS = new OpportunitySplit(OpportunityId = oppId, SplitOwnerId = userId, SplitPercentage = 100);
        oppSplitCS.SplitTypeId = getOppSplitTypeId(OPP_SPLIT_TYPE_CS_DEVNAME);
        oppSplits.add(oppSplitCS);
        OpportunitySplit oppSplitWS = new OpportunitySplit(OpportunityId = oppId, SplitOwnerId = userId, SplitPercentage = 100);
        oppSplitWS.SplitTypeId = getOppSplitTypeId(OPP_SPLIT_TYPE_WS_DEVNAME);
        oppSplits.add(oppSplitWS);
        return oppSplits;
    }

    public static void deleteOppSplits(Set<Id> oppIdList) {
        List<Id> oppSplitIds = getActiveOppSplitIds();
        List<OpportunitySplit> oppSplitsToDelete = [
            SELECT Id, OpportunityId, SplitTypeId
            FROM OpportunitySplit
            WHERE SplitTypeId IN :oppSplitIds AND OpportunityId IN :oppIdList
        ];

        if (!oppSplitsToDelete.isEmpty()) {
            system.debug('inside delete method seutility');
            delete oppSplitsToDelete;
        }
    }

    /* * * * * * * * * * * * * * * * * * * * * * * * */
    /* * Telia Calendar/Commit View Helper Methods * */
    /* * * * * * * * * * * * * * * * * * * * * * * * */

    // Method that returns the first date of the first week (i.e. week number 1) of a year.
    public static Date getFirstDayOfTeliaYear(Integer year) {
        return Date.newInstance(year, 1, 4).toStartOfWeek();
    }

    //Method that returns the last day of the last week (i.e. week number 52 or 53) of a year
    public static Date getLastDayOfTeliaYear(Integer year) {
        return SEUtility.getFirstDayOfTeliaYear(year + 1).addDays(-1);
    }

    // Method that returns Map<Integer, Map<Date, Date>> (Map<The quarter number, Map<StartDate, EndDate>>)
    public static Map<Integer, Map<Date, Date>> getTeliaQuarterStartAndEndDates(Integer year) {
        Map<Integer, Map<Date, Date>> returnMap = new Map<Integer, Map<Date, Date>>();

        Date tempStartDate = getFirstDayOfTeliaYear(year);
        Date tempEndDate = tempStartDate.addDays(90);
        returnMap.put(1, new Map<Date, Date>{ tempStartDate => tempEndDate });

        for (Integer i = 2; i <= 4; i++) {
            if (i == 4 && SEUtility.isFiftyThreeWeekYear(year)) {
                tempStartDate = tempEndDate.addDays(1);
                tempEndDate = tempStartDate.addDays(97);
                returnMap.put(i, new Map<Date, Date>{ tempStartDate => tempEndDate });
            } else {
                tempStartDate = tempEndDate.addDays(1);
                tempEndDate = tempStartDate.addDays(90);
                returnMap.put(i, new Map<Date, Date>{ tempStartDate => tempEndDate });
            }
        }

        return returnMap;
    }

    public static Boolean isFiftyThreeWeekYear(Integer year) {
        if (SEUtility.getFirstDayOfTeliaYear(year).daysBetween(SEUtility.getLastDayOfTeliaYear(year)) + 1 == 371) {
            return true;
        } else {
            return false;
        }
    }

    // Method that takes a date and return a week number
    public static Integer getWeekNumber(Date theDate) {
        //Get the year of the date and get first and end date of that telia year
        Integer theYear = Integer.valueOf(theDate.year());
        Date startDate = SEUtility.getFirstDayOfTeliaYear(theYear);
        Date endDate = SEUtility.getLastDayOfTeliaYear(theYear);

        //If the date is less than the start date then the date belongs to the previous year
        if (theDate < startDate) {
            theYear = theYear - 1;
            startDate = SEUtility.getFirstDayOfTeliaYear(theYear);
            endDate = SEUtility.getLastDayOfTeliaYear(theYear);
        }
        //If the date is greater than the end date then the date belongs to the upcoming year
        else if (theDate > endDate) {
            theYear = theYear + 1;
            startDate = SEUtility.getFirstDayOfTeliaYear(theYear);
            endDate = SEUtility.getLastDayOfTeliaYear(theYear);
        }

        Integer daysBetween = startDate.daysBetween(theDate);

        return (daysBetween / 7 + 1);
    }

    public static String getWeekNumberAsString(Date theDate) {
        Integer weekInt = SEUtility.getWeekNumber(theDate);

        // Add the zero in front of the single digit weeks so that opps will be pointed towards the correct weekly_forecast_item__c records
        if (weekInt != null && weekInt >= 0 && weekInt < 10) {
            return '0' + String.valueOf(weekInt);
        }

        return String.valueOf(weekInt);
    }

    public static Integer getQuarterNrFromWeek(Integer weekNr) {
        if (weekNr <= 13)
            return 1;
        else if (weekNr <= 26)
            return 2;
        else if (weekNr <= 39)
            return 3;
        else
            return 4;
    }

    // Method that returns the nr of weeks in the quarter
    public static Integer getWeeksInQuarter(Integer quarterNr, Integer year) {
        if (isFiftyThreeWeekYear(year) && quarterNr == 4) {
            return 14;
        }
        return 13;
    }

    // Method that returns the current quarter
    public static Integer getPeriodNumber(Date theDate) {
        return SEUtility.getQuarterNrFromWeek(SEUtility.getWeekNumber(theDate));
    }

    // Method that creates Telia Weeks for a given quarter
    public static List<Weekly_Forecast_Item__c> getTeliaWeeks(Id quarterParentId, Integer year, String quarterName, Id userId, Date startDate, Date endDate) {
        Integer quarter = Integer.valueOf(quarterName);
        Integer startWeekNumber = 13 * (quarter - 1) + 1;
        Integer endWeekNumber = 13 * quarter;
        if (quarter == 4 && SEUtility.isFiftyThreeWeekYear(year))
            endWeekNumber++;

        // Create the list that shall be returned
        List<Weekly_Forecast_Item__c> wfiList = new List<Weekly_Forecast_Item__c>();

        Date dynamicStartDate = startDate;
        Date dynamicEndDate = startDate.addDays(6);

        for (Integer i = startWeekNumber; i <= endWeekNumber; i++) {
            // If the week number is 1 -> 9 then add a zero before the weeknumber (string). This gives a proper sorting of weeks in reports
            if (i > 0 && i < 10) {
                wfiList.add(
                    new Weekly_Forecast_Item__c(
                        Name = '0' + String.valueOf(i),
                        Quarterly_Forecast_Item__c = quarterParentId,
                        User__c = userId,
                        Start_Date__c = dynamicStartDate,
                        End_Date__c = dynamicEndDate
                    )
                );
            } else {
                wfiList.add(
                    new Weekly_Forecast_Item__c(
                        Name = String.valueOf(i),
                        Quarterly_Forecast_Item__c = quarterParentId,
                        User__c = userId,
                        Start_Date__c = dynamicStartDate,
                        End_Date__c = dynamicEndDate
                    )
                );
            }
            dynamicStartDate = dynamicStartDate.addDays(7);
            dynamicEndDate = dynamicEndDate.addDays(7);
        }
        return wfiList;
    }

    public static List<Weekly_Forecast_Item__c> getWeeks(
        Id quarterParentId,
        Integer year,
        String quarterName,
        Decimal quarterNewSalesTarget,
        Decimal quarterContinuationSalesTarget,
        Decimal quarterSalesValueTarget,
        Id userId,
        Date startDate,
        Date endDate,
        Id seller
    ) {
        List<Weekly_Forecast_Item__c> wfiList = SEUtility.getTeliaWeeks(quarterParentId, year, quarterName, userId, startDate, endDate);

        Decimal qnsSplit = quarterNewSalesTarget / wfiList.size();
        Decimal qcsSplit = quarterContinuationSalesTarget / wfiList.size();
        Decimal qsvtSplit = quarterSalesValueTarget / wfiList.size();

        for (Weekly_Forecast_Item__c wfi : wfiList) {
            wfi.New_Sales_Target__c = qnsSplit;
            wfi.Continuation_Sales_Target__c = qcsSplit;
            wfi.Sales_Value_Target__c = qsvtSplit;
            wfi.Seller__c = seller;
        }

        return wfiList;
    }

    // Fetches the Sales Target Distribution from the custom setting Sales_Target_Distribution__c and returns a map<quarterNo, quarterDistribution>
    public static Map<Integer, Double> getSalesTargetDistributionMap() {
        Sales_Target_Distribution__c mc = Sales_Target_Distribution__c.getValues('Main');
        Map<Integer, Double> salesTargetDistMap = new Map<Integer, Double>();
        salesTargetDistMap.put(1, mc.X1st_Quarter_Sales_Weight__c / 100);
        salesTargetDistMap.put(2, mc.X2nd_Quarter_Sales_Weight__c / 100);
        salesTargetDistMap.put(3, mc.X3rd_Quarter_Sales_Weight__c / 100);
        salesTargetDistMap.put(4, mc.X4th_Quarter_Sales_Weight__c / 100);
        return salesTargetDistMap;
    }

    /* * * * * * * * * * * * * * * * * * */
    /* * Miscellaneous System Methods  * */
    /* * * * * * * * * * * * * * * * * * */

    //Method to create a multiselectpickliststring
    public static String writeMultiSelectPicklist(Set<String> strings) {
        String newString = '';
        Boolean firstValue = true;
        for (String s : strings) {
            if (!String.isBlank(s)) {
                if (firstValue) {
                    firstValue = false;
                } else {
                    newString += ';';
                }
                newString += s;
            }
        }
        return newString;
    }

    //Method that gets a product family name and returns a solution area name
    public static String getSolutionAreaName(String family) {
        if (family == 'Unified Communications') {
            return 'Unified and Mobile Communications';
        } else if (
            family == 'Service' ||
            family == 'Services - Analytics' ||
            family == 'Services - Managed Services' ||
            family == 'Services - IT' ||
            family == 'Services - Supportservices' ||
            family == 'Services - Professional Services'
        ) {
            return 'Services';
        } else if (family == 'Cloud Networking') {
            return 'Cloud Networking';
        } else if (family == 'Mobility Management') {
            return 'Mobility Management and Business Apps';
        } else if (family == 'Solution') {
            return 'Business Management';
        } else if (family == 'IBS') {
            return 'IBS';
        } else if (family == 'ProCare') {
            return 'Health Care';
        } else if (family == 'HomeCare') {
            return 'HomeCare';
        } else if (family == 'Healthcare' || family == 'Other' || family == 'DivX - Other') {
            return 'Other';
        } else if (family == 'IoT' || family == 'Data Insights') {
            return 'Division X';
        } else if (
            family == 'Collaboration & UC - Cloud Communicaton Solutions' ||
            family == 'Collaboration & UC - Customer Unique Communication Solutions' ||
            family == 'Collaboration & UC - Healthcare' ||
            family == 'Collaboration & UC - Meeting Services' ||
            family == 'Collaboration & UC - Messaging' ||
            family == 'Collaboration & UC - Value Added Services' ||
            family == 'Collaboration & UC - Partner Based Communication Solutions' ||
            family == 'Collaboration & UC - Media & Entertainment' ||
            family == 'Collaboration & UC - Meeting Services'
        ) {
            return 'Collaboration & UC';
        } else if (family == 'Customer Meeting - Customer Meeting') {
            return 'Customer Meeting';
        } else if (family == 'eID & Security - Business Network') {
            return 'eID & Security';
        } else if (family == 'Equipment - EMM' || family == 'Equipment - Equipment') {
            return 'Equipment';
        } else if (family == 'IoT - Connectivity' || family == 'IoT - Professional Services' || family == 'IoT - VAS') {
            return 'IoT';
        } else if (
            family == 'Networks - Broadband' ||
            family == 'Networks - Business Network' ||
            family == 'Networks - Fixed Telephony' ||
            family == 'Networks - ISP' ||
            family == 'Networks - Mobile Other' ||
            family == 'Networks - Mobile Telephony' ||
            family == 'Networks - EMN'
        ) {
            return 'Networks';
        } else if (family != null && family.contains('Cygate')) {
            return family;
        } else {
            return '';
        }
    }

    //Method that gets a soluation are name and returns a solution area code
    public static String getSolutionAreaCode(String text) {
        if (text == 'Unified and Mobile Communications') {
            return 'UC ';
        } else if (text == 'Services') {
            return 'Services ';
        } else if (text == 'Cloud Networking') {
            return 'CN ';
        } else if (text == 'Mobility Management and Business Apps') {
            return 'MM ';
        } else if (text == 'Business Management') {
            return 'BM ';
        } else if (text == 'IBS') {
            return 'IBS ';
        } else if (text == 'Health Care') {
            return 'HC ';
        } else if (text == 'Collaboration & UC') {
            return 'CU';
        } else if (text == 'Customer Meeting') {
            return 'CM';
        } else if (text == 'eID & Security') {
            return 'eIdSec';
        } else if (text == 'Equipment') {
            return 'EQ';
        } else if (text == 'IoT') {
            return 'IoT';
        } else if (text == 'Networks') {
            return 'NW';
        } else {
            return '';
        }
    }

    //Method that gets a soluation are name and returns a solution area code
    public static String getSolutionAreaFromRole(String text) {
        if (text == null) {
            return '';
        } else if (text.contains('Unified') || (text.contains('Area Specialist Caas'))) {
            return 'Unified and Mobile Communications';
        } else if (text.contains('Services')) {
            return 'Services';
        } else if (text.contains('Area Specialist Network') || text.contains('Bus Design Netw')) {
            return 'Cloud Networking';
        } else if (text.contains('Applications')) {
            return 'Mobility Management and Business Apps';
        } else if (text.contains('IBS')) {
            return 'IBS';
        } else {
            return '';
        }
    }

    public class OwnerDate {
        public String theDate { get; set; }
        public Id theOwner { get; set; }
        public OwnerDate(String theDate, Id theOwner) {
            this.theDate = theDate;
            this.theOwner = theOwner;
        }
    }

    /* * * * * * * * * * * * * * * * * */
    /* * Exception Handling Methods  * */
    /* * * * * * * * * * * * * * * * * */

    // Author N.W
    // Method that sends an email to list of recepients defined in method getExceptionEmailRecepients
    public static void sendExceptionMail(String subject, Exception e, List<Id> ids) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = getExceptionEmailRecepients();
        if (!toAddresses.isEmpty()) {
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setPlainTextBody('Exception: ' + e + '\n\n' + 'ids: ' + ids);

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        }
    }

    /* Author A.N
     *  Returns a list of email adresses for whom to send exception email.
     *  The method fetches the email adresses of all users plus External Email Addresses defined
     *  in the Apex Exception Email settings (Setup -> Email Administration -> Apex Exception Email) */
    public static List<String> getExceptionEmailRecepients() {
        List<String> toAddresses = new List<String>();

        List<ApexEmailNotification> aenList = [SELECT UserId, User.Email, Email FROM ApexEmailNotification where user.IsActive = true];
        for (ApexEmailNotification aen : aenList) {
            toAddresses.add(aen.UserId == null ? aen.Email : aen.User.Email);
        }
        return toAddresses;
    }

    // Returns a List of the Names of all RecordTypes
    // available to the running user for a given SOBject type
    public static List<String> GetAvailableRecordTypeNamesForSObject(Schema.SObjectType objType) {
        List<String> names = new List<String>();
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        // If there are 2 or more RecordTypes...
        if (infos.size() > 1) {
            for (RecordTypeInfo i : infos) {
                if (
                    i.isAvailable() &&
                    // Ignore the Master Record Type, whose Id always ends with 'AAA'.
                    // We check the Id because Name can change depending on the user's language.
                    !String.valueOf(i.getRecordTypeId()).endsWith('AAA')
                )
                    names.add(i.getName());
            }
        }
        // Otherwise there's just the Master record type,
        // so add it in, since it MUST always be available
        else
            names.add(infos[0].getName());
        return names;
    }

    /*Author P.P
     *Returns Boolean if the User Role is Renewal Role
     */
    public static Boolean getRenewalRoles(Id userId) {
        boolean returnVar = false;
        Map<Id, User> userList = new Map<Id, User>([SELECT Id, UserRoleId, UserRole.Name FROM User WHERE ID = :userId AND UserRole.Name = :ROLE_RENEWAL]);

        if (userList.size() != null) {
            if (userList.get(userId) != null) {
                system.debug('the role is true');
                returnVar = true;
            } else {
                returnVar = false;
            }
        }
        return returnVar;
    }

    //Y.K - for SALEF-919

    public static Map<Id, Id> UserIdSellerIdMap;

    public static void loadUserIdSellerIdMap() {
        if (UserIdSellerIdMap == null) {
            UserIdSellerIdMap = new Map<Id, Id>();
            for (Seller__c s : [SELECT Id, User__c FROM Seller__c WHERE Sales_Team_Name__c LIKE '%SOHO%' AND End_Date__c > TODAY]) {
                UserIdSellerIdMap.put(s.User__c, s.id);
            }
        }
    }

    public static Boolean isSOHOUser(Id UserId) {
        loadUserIdSellerIdMap();
        String user_Id = UserIdSellerIdMap.get(UserId);
        if (user_Id != null) {
            return true;
        }
        return false;
    }

    //Y.K - for SALEF-919
    // Fetches the Sales Target Distribution from the custom setting Sales_Target_Distribution__c For SOHO New Sales and returns a map<quarterNo, quarterDistribution>
    public static Map<Integer, Double> getSOHONewSalesTargetDistributionMap() {
        Sales_Target_Distribution__c mc = Sales_Target_Distribution__c.getValues('SOHO_NewSalesTarget');
        Map<Integer, Double> SOHONewSalesTargetDistMap = new Map<Integer, Double>();
        SOHONewSalesTargetDistMap.put(1, mc.X1st_Quarter_Sales_Weight__c / 100);
        SOHONewSalesTargetDistMap.put(2, mc.X2nd_Quarter_Sales_Weight__c / 100);
        SOHONewSalesTargetDistMap.put(3, mc.X3rd_Quarter_Sales_Weight__c / 100);
        SOHONewSalesTargetDistMap.put(4, mc.X4th_Quarter_Sales_Weight__c / 100);
        return SOHONewSalesTargetDistMap;
    }

    //Added By Rajni
    //To get the list of record type
    //Parameter (Project - MC/Fiber), (developerName - Developer Name of Metadata TeliaSERecordTypeSetting__mdt. like quote, contract, Opportunity etc.)
    public static List<String> getRecordTypes(String project, string developerName) {
        TeliaSERecordTypeSetting__mdt TeliaSERecordTypeSettingObj = [
            SELECT Id, MassCustomized__c, CRMFiber__c, DeveloperName
            FROM TeliaSERecordTypeSetting__mdt
            WHERE DeveloperName = :developerName
        ];
        if (project.equalsIgnoreCase('MassCustomized')) {
            return TeliaSERecordTypeSettingObj.MassCustomized__c.split(',');
        } else if (project.equalsIgnoreCase('CRMFiber')) {
            return TeliaSERecordTypeSettingObj.CRMFiber__c.split(',');
        } else {
            return null;
        }
    }

    //Added By Rajni
    //To whether metadata list contains specific record type or not
    //Parameter (Project - MC/Fiber), (developerName - Developer Name of Metadata TeliaSERecordTypeSetting__mdt. like quote, contract, Opportunity etc.), recordType - contains current record type of data
    public static boolean isRecordTypeAvailable(String project, string developerName, string recordType) {
        List<String> recordTypesList = getRecordTypes(project, developerName);
        if (recordTypesList != null && recordTypesList.contains(recordType)) {
            return true;
        } else {
            return false;
        }
    }
    //Added By Rimgaudas
    //Common method to insert new error record
    public static void errorLogging(String debugLevel, String className, String methodName, Exception ex) {
        Application_Logs__c newError = new Application_Logs__c();
        newError.Debug_Level__c = debugLevel;
        newError.Source__c = className;
        newError.Source_Function__c = methodName;
        newError.Message__c = ex.getMessage();
        newError.Stack_Trace__c = ex.getStackTraceString();
        insert newError;
    }
}