/**
 * Description:
 * Class to manage constants.
 *
 * Modifications:
 * 12.04.2023 [Tomass Brazovskis] SALEF-8573 - Introduced. Store Task Status values.
 * 26.04.2023 [Tomass Brazovskis] LTAT-7669 - Store User 'Temporary_Deactivation_Status' values.
 * 26.06.2023 [Tomass Brazovskis] LTAT-10218 - Store Opportunity StageName values.
 * LTAT-15627: OpportunityLineItem/OpportunityTeamMember Trigger Refactor
 */
public with sharing class SEConstants {
    // Cygate UserRole Name Prefix
    public static final String USERROLE_PREFIX_CYGATE = 'CG';

    // Opportunity 'Stage' API Names
    public static final String OPPORTUNITY_STAGE_KVALIFICERA = 'Kvalificera';
    public static final String OPPORTUNITY_STAGE_VUNNEN = 'Vunnen';
    public static final String OPPORTUNITY_STAGE_FORLORAD = 'Förlorad';
    public static final String OPPORTUNITY_STAGE_AVBRUTEN = 'Avbruten';
    public static final String OPPORTUNITY_STAGE_AVFARDAT_PROSPECT = 'Avfärdat prospect';
    public static final String OPPORTUNITY_STAGE_CLOSED_MF = 'Closed MF';
    public static final String OPPORTUNITY_STAGE_CLOSED_STANGD = 'stängd';

    // Task 'Status' Picklist value API Names
    public static final String TASK_STATUS_OPEN = 'Öppen';
    public static final String TASK_STATUS_IN_PROGRESS = 'Pågående';
    public static final String TASK_STATUS_CLOSED = 'Stängd';
    public static final String TASK_STATUS_CLOSED_NOT_APPROVED = 'Closed Not Approved';
    public static final String TASK_STATUS_CLOSED_APPROVED = 'Closed Approved';

    // Task 'Type' Picklist value API Names
    public static final String TASK_TYPE_MAIL = 'Mail';
    public static final String TASK_TYPE_OTHER = 'Annat';
    public static final String TASK_TYPE_PHYSICAL = 'Fysiskt';
    public static final String TASK_TYPE_SIGNOFF = 'Signoff';
    public static final String TASK_TYPE_TELEPHONE = 'Telefon';
    public static final String TASK_TYPE_WEB = 'Web';

    // Task 'Task Subtype' Picklist value API Names
    public static final String TASK_SUBTYPE_CALL = 'Call';
    public static final String TASK_SUBTYPE_EMAIL = 'Email';
    public static final String TASK_SUBTYPE_LINKEDIN = 'LinkedIn';
    public static final String TASK_SUBTYPE_LIST_EMAIL = 'List Email';
    public static final String TASK_SUBTYPE_LIST_TASK = 'Task';

    // User 'Temporary_Deactivation_Status' Picklist value API Names
    public static final String USER_TD_STATUS_NONE = 'None';
    public static final String USER_TD_STATUS_AUTO_DEACTIVATED_SALESFORCE = 'Automatically Deactivated Salesforce';
    public static final String USER_TD_STATUS_AUTO_DEACTIVATED_SALESFORCE_AND_VLOCITY = 'Automatically Deactivated Salesforce and Vlocity';
    public static final String USER_TD_STATUS_MANUALLY_DEACTIVATED_SALESFORCE = 'Manually Deactivated Salesforce';
    //Lead Source Values  :Added by Rimgaudas
    public static final String LEAD_SOURCE_RESELLER = 'ÅF';
    public static final String LEAD_SOURCE_TELIA_SE = 'Telia.se';
    public static final String LEAD_SOURCE_TELIA_INTRANET = 'Telia Intranet';
    public static final String LEAD_SOURCE_OTHER = 'Övrig Telia';
    public static final String LEAD_SOURCE_LEADAGENT = 'Lead Agent';
    public static final String LEAD_SOURCE_SALESREP = 'Sales Rep';
    public static final String LEAD_SOURCE_PERSONAL_TECHNICIAN = 'Personlig Tekniker';
    public static final String LEAD_SOURCE_TELIA_ADMIN = 'Telia Admin';
    public static final String LEAD_SOURCE_TELIA_PIX = 'Telia PIX';
    //Lead Status Values  :Added by Rimgaudas
    public static final String LEAD_STATUS_NEW = 'Nytt';
    public static final String LEAD_STATUS_PREQUALIFY = 'Förkvalificera';
    public static final String LEAD_STATUS_QUALIFY = 'Kvalificera';
    public static final String LEAD_STATUS_RETURNED = 'Returnerad';
    public static final String LEAD_STATUS_CONVERTED = 'Konverterat';
    public static final String LEAD_STATUS_DISMISSED = 'Avfärdat';
    public static final String LEAD_STATUS_ROUTE = 'Routing';
    // Lead Close Reason Picklist Definitions :Added by Rimgaudas
    public static final String LEAD_CLOSE_REASON_DUPLICATE = 'Dubblett';
    // Lead Converts to Cygate opportunity type Picklist Definitions :Added by Rimgaudas
    public static final String CYGATE_BUSINESS_OPPORTUNITY = 'Cygate affär';
    // Lead Product Area Picklist Definitions :Added by Rimgaudas
    public static final String LEAD_PRODAREA_BB = 'Broadband';
    public static final String LEAD_PRODAREA_CS = 'Molntjänster';
    public static final String LEAD_PRODAREA_CN = 'Företagsnätverk';
    public static final String LEAD_PRODAREA_CC = 'Kontaktcenter';
    public static final String LEAD_PRODAREA_ESD = 'Expert och servicetjänster';
    public static final String LEAD_PRODAREA_IOT = 'IOT';
    public static final String LEAD_PRODAREA_MS = 'Mötestjänster';
    public static final String LEAD_PRODAREA_OTHER = 'Other';
    public static final String LEAD_PRODAREA_SS = 'Supporttjänster';
    public static final String LEAD_PRODAREA_SWITCH = 'PBX';
    public static final String LEAD_PRODAREA_TELEPHONY = 'Telefoni';
    public static final String LEAD_PRODAREA_PS = 'Servicetjänster';
    public static final String LEAD_PRODAREA_SECURITY = 'Security';
    public static final String LEAD_PRODAREA_CLOUD = 'Cloud';
    public static final String LEAD_PRODAREA_SER_STO = 'Server/Storage';
    public static final String LEAD_PRODAREA_CITYNET = 'Citynet';
    public static final String LEAD_PRODAREA_NETWORK = 'Network';
    public static final String LEAD_PRODAREA_DMD = 'DMD';
    public static final String LEAD_PRODAREA_UC = 'UC';
    public static final String LEAD_PRODAREA_CES = 'Cygate Event Signup';
    public static final String LEAD_PRODAREA_MI = 'Mobil Integration';
    public static final String LEAD_PRODAREA_HC = 'Healthcare';
    public static final String LEAD_PRODAREA_CG = 'Konfiguratorn'; //D.C.
    public static final String LEAD_PRODAREA_WORKPLACE = 'Cygate Digital Arbetsplats'; //D.C.
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
    //ACCOUNT TEAM MEMBER ROLE
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_CYGATE_MANAGER = 'Cygate - Kontoansvarig';
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_SERVICE_MANAGER = 'Cygate - Service Manager';
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_TELIA_SERVICE_MANAGER = 'Service Manager';
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_TELIA_LifeCycle_MANAGER = 'LifeCycle Manager';
    public static final String ACCOUNT_TEAM_MEMBER_ROLE_TELIA_CHANGE_MANAGER = 'Customer Change Manager';

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

    // EVENT
    public static final String EVENT_REC_TYPE_TELIA = 'Telia_Events';
    public static final String EVENT_REC_TYPE_CYGATE = 'Cygate_Events';
    public static final String CYGATE_CHATTER_POST_FOLDER_NAME = 'Cygate_Chatter_Posts'; // Folder developer name
    public static final String COMPLETED_EVENT_WITH_INVITEES = 'Cygate_Completed_Customer_Visits_with_invitees_SE'; // Template developer name
    public static final String COMPLETED_EVENT_WITHOUT_INVITEES = 'Cygate_Completed_Customer_Visits_without_invitees_SE'; // Template developer name
    public static final String TEMPLATE_USER_REF = '[SALESPERSON]'; // The event assigned to user
    public static final String TEMPLATE_ACCOUNT_REF = '[CLIENT]'; // The name of the account relaetd to
    public static final String TEMPLATE_INVITEES_REF = '[INVITEES]';
    public static final String TEMPLATE_POINTS_REF = '[VISIT_POINTS]';
    public static final String TEMPLATE_DATE_REF = '[VISIT_DATE]';

    // TASK
    public static final String TASK_REC_TYPE_SME = 'SME_Soho_Tasks';
    public static final String TASK_REC_TYPE_LARGE = 'Large_Task';
    public static final String TASK_REC_TYPE_CYGATE = 'Cygate_Tasks';
        //CampaignMember Status
    public static final String PR_CAMPAIGN_STATUS = 'Ringt';

        //Call Activity Call Status values
    public static final String STATUS_CONTACTED = 'Kontaktad';
    public static final String STATUS_WILL_CONTACT = 'Ska kontaktas';

        // TASK PICKLIST STRING DEFINITIONS
        // Status Picklist
    public static final String STATUS_CLOSED = 'Stängd';
    public static final String STATUS_OPEN = 'Öppen';

        // Type Picklist
    public static final String TYPE_PHONE = 'Telefon';
    public static final String TYPE_PHYSICAL = 'Fysiskt';
    public static final String TYPE_WEB = 'Web';
    public static final String TYPE_APSIS = 'Apsis';

        // Subject Picklist
    public static final String SUBJECT_CALL = 'Call';

        //SME Task Type Picklist values
    public static final String TYPE_SALES = 'Säljuppföljning';
    public static final String TYPE_NEXT = 'Nästa steg';
    public static final String TYPE_MYBUSINESS = 'Genomgång MyBusiness';

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

    //Contract Record Type
    public static final String Contract_TELIA = 'Competitor_Agreements';
    public static final String Contract_TELIA_Avtal = 'Telia_Agreements';
    public static final String Contract_CYGATE = 'Cygate_Competitor_Agreements';
    public static final String Contract_CYGATE_Avtal = 'Cygate_Agreement';
    public static final String Contract_FRAMEWORK_AGREEMENT = 'TeliaSE_Framework_Agreement';
    public static final String Contract_SERVICE_AGREEMENT = 'TeliaSE_Service_Agreement';
    public static final String Contract_REAL_ESTATE_FIBER = 'Real_Estate_Fiber';

    //Contract 'Status' picklist values API names
    public static final String Contract_STATUS_IN_APPROVAL_PROCESS = 'In Approval Process';
    public static final String Contract_STATUS_DRAFT = 'Draft';
    public static final String Contract_STATUS_ACTIVATED = 'Activated';
    public static final String Contract_STATUS_SENT_FOR_APPROVAL = 'Sent for Approval';
    public static final String Contract_STATUS_APPROVED = 'Approved';
    public static final String Contract_STATUS_SENT_FOR_SIGNING = 'Sent for Signing';
    public static final String Contract_STATUS_NEGOTIATING = 'Negotiating';
    public static final String Contract_STATUS_REJECTED = 'Rejected';
    public static final String Contract_STATUS_SIGNED = 'Signed';
    public static final String Contract_STATUS_ACTIVE = 'Active';
    public static final String Contract_STATUS_ACTIVE_EXTENDED = 'Active Extended';
    public static final String Contract_STATUS_TERMINATED = 'Terminated';
    public static final String Contract_STATUS_EXPIRED = 'Expired';
    public static final String Contract_STATUS_CANCELLED = 'Cancelled';
    public static final String Contract_STATUS_INACTIVE = 'Inactive';

    //Scrive Document 'Status' picklist values API names
    public static final String ScriveDocument_STATUS_NEW = 'New';
    public static final String ScriveDocument_STATUS_PREPARATION = 'Preparation';
    public static final String ScriveDocument_STATUS_PENDING = 'Pending';
    public static final String ScriveDocument_STATUS_DELIVERED = 'Delivered';
    public static final String ScriveDocument_STATUS_OPENED = 'Opened';
    public static final String ScriveDocument_STATUS_READ = 'Read';
    public static final String ScriveDocument_STATUS_WITHDRAWN = 'Withdrawn';
    public static final String ScriveDocument_STATUS_SIGNED = 'Signed';
    public static final String ScriveDocument_STATUS_TIMEDOUT = 'Timedout';
    
    //OppTeamMemberHandler
    public static final String CHATTER_MSG_TEXT = 'lades till i affärsmöjlighetsteamet för: ';
    
    //OpportunityLineItemTriggerHandler
    public static final Integer INITIAL_COUNT_VALUE = 0;
    public static final String PRODUCT_FAMILY_CYGATE = 'Cygate';

    //Utilizer Contract Relationship 'Status' picklist values API names
    public static final String UtilizerContractRelationship_STATUS_DRAFT = 'Draft';
    public static final String UtilizerContractRelationship_STATUS_PENDINGACTIVE = 'PendingActive';
    public static final String UtilizerContractRelationship_STATUS_PENDINGINACTIVE = 'PendingInactive';
    public static final String UtilizerContractRelationship_STATUS_AKTIV = 'Aktiv';
    public static final String UtilizerContractRelationship_STATUS_INAKTIV = 'Inaktiv';
    public static final String UtilizerContractRelationship_STATUS_MANUAL = 'Manual';
    public static final String UtilizerContractRelationship_STATUS_FREEZED = 'Freezed';


}