/**
 * Description:
 * Class to manage Case-related constants.
 * 
 * Modifications:
 * 03.11.2023 [Tomass Brazovskis] LTAT-11634 - Introduced.
 **/
public with sharing class SEConstantsCase {

    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_EFFORT_ESTIMATION = 'Effort Estimation';
    public static final String CASE_STATUS_IN_PROGRESS = 'In Progress';
    public static final String CASE_STATUS_APPROVAL_FOR_DEPLOYMENT = 'Approval for Deployment';
    public static final String CASE_STATUS_RESOLVED_IN_TEST = 'Resolved in Test';
    public static final String CASE_STATUS_RESOLVED = 'Resolved';
    public static final String CASE_STATUS_WAITING = 'Waiting';
    public static final String CASE_STATUS_ON_HOLD = 'On Hold';
    public static final String CASE_STATUS_REJECTED = 'Rejected';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_ON_HOLD_1ST_LINE = 'On Hold - 1st Line';
    public static final String CASE_STATUS_ON_HOLD_2ND_LINE = 'On Hold - 2nd Line';
    public static final String CASE_STATUS_ESCALATED = 'Escalated';
    public static final String CASE_STATUS_PENDING = 'Pending';
    public static final String CASE_STATUS_APPROVED = 'Approved';
    public static final String CASE_STATUS_APPLIED = 'Applied';

    public static final String CASE_RECTYPE_ENTERPRISE = System.Label.CASE_RT_API_NAME_ENTERPRISE;
    public static final String CASE_RECTYPE_ENTERPRISE_SUBCASE = System.Label.CASE_RT_API_NAME_ENTERPRISE_SUBCASE;
    public static final String CASE_RECTYPE_SUPPORT = 'Telia_Company_Support';
    public static final String CASE_RECTYPE_BILLING = 'Billing';
    public static final String CASE_RECTYPE_CYGATE_PRESALES = 'Cygate_Presales';
    public static final String CASE_RECTYPE_MOBILE_PHONE_CASE = 'MobilePhoneCase';
    public static final String CASE_RECTYPE_REAL_ESTATE_FIBER = System.Label.Real_Estate_Fiber_Case_RT;
    public static final String CASE_RECTYPE_SERVICE = 'Service';

    public static final String CASE_ORIGIN_SALESFORCE = 'Salesforce';

    public static final String CASE_GROUP_SAT = 'SAT';  
    public static final String CASE_GROUP_VOLUME_DESIGN = 'Volume Design';
    public static final String CASE_GROUP_PRESALE_DATACOM = 'Presale Datacom';  
    public static final String CASE_GROUP_PRESALE_VOICE = 'Presale Voice';

    public static final String CASE_CATEGORY_MISCELLANEOUS = 'Övrigt';
    public static final String CASE_CATEGORY_INQUIRY = 'Utredning';
    public static final String CASE_CATEGORY_KAP = 'KAP';
    public static final String CASE_CATEGORY_3PL = '3PL_Faktura';
    public static final String CASE_CATEGORY_OCC = 'OCC';

    public static final String CASE_PRODUCT_AREA_DATAKOM = 'Datakom';
    public static final String CASE_PRODUCT_AREA_EMN = 'EMN';
    public static final String CASE_PRODUCT_AREA_MFN = 'MFN';

    public static final String QUEUE_VOLUME_DESIGN = 'Volume Design';
    public static final String QUEUE_SAT = 'SAT';
    public static final String QUEUE_API_NAME_VOLUME_DESIGN = 'Volume_Design';
    public static final String QUEUE_API_NAME_SAT = 'SAT';
}