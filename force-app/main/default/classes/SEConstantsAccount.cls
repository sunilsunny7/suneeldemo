/**
 * Description:
 * Class to manage Account-related constants.
 * 
 * Modifications:
 * 2024-03-18 [Tomass Brazovskis] LTAT-28778 - Added values of picklists used for Account segmentation.
 * 2023-12-04 [Tomass Brazovskis] LTAT-21098 - Introduced.
 **/
public with sharing class SEConstantsAccount {

    public static final String IS_MYBUSINESS_USER_VALUE_AFFIRMATIVE = 'Ja';
    public static final String IS_MYBUSINESS_USER_VALUE_NEGATIVE = 'Nej';

    // Account Suggested_Business_Area picklist API Names
    public static final String ACCOUNT_SUGGESTED_BUSINESS_AREA_API_NAME_ENTERPRISE = 'Enterprise';
    public static final String ACCOUNT_SUGGESTED_BUSINESS_AREA_API_NAME_EXCLUDED = 'Excluded';
    public static final String ACCOUNT_SUGGESTED_BUSINESS_AREA_API_NAME_KUNDEN_TELIA = 'Kunden Telia';

    // Account Suggested_Business_Unit picklist API Names
    public static final String ACCOUNT_SUGGESTED_BU_API_NAME_SMALL = 'Small';
    public static final String ACCOUNT_SUGGESTED_BU_API_NAME_MLE = 'MLE';
    public static final String ACCOUNT_SUGGESTED_BU_API_NAME_ES = 'ES';
    public static final String ACCOUNT_SUGGESTED_BU_API_NAME_ENTERPRISE_OTHER = 'Enterprise Other';
    // In Replacement
    public static final String ACCOUNT_SUGGESTED_BU_API_NAME_SME = 'SME';
    public static final String ACCOUNT_SUGGESTED_BU_API_NAME_LARGE_BUSINESS = 'Large Business';
    public static final String ACCOUNT_SUGGESTED_BU_API_NAME_PUBLIC_AND_KEY = 'Public & Key';

    // Account Suggested_SubBusinessUnitLvl1 picklist API Names (Controlled BY Suggested_Business_Unit)
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_SMALL = 'Small';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_MLE_AM = 'MLE AM';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_MLE_KAM = 'MLE KAM';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_PRIVATE_SECTOR = 'Private Sector';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_PUBLIC_SECTOR = 'Public Sector';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_ENTERPRISE_OTHER = 'Enterprise Other';
    // In Replacement
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_SME_MM = 'SME MassMarket';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_SME_AM = 'SME AM';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_REG_ACC = 'Regional Account';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL1_API_NAME_KEY_ACC = 'Key Account';

    // Account Suggested_SubBusinessUnitLvl2__c picklist API Names (Controlled BY Suggested_SubBusinessUnitLvl1)
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_SMALL_0_4 = 'Small 0-4';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_SMALL_5_9 = 'Small 5-9';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_SMALL_10_49 = 'Small 10-49';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_SMALL_OTHER = 'Small Other';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_MLE_AM_10_49 = 'MLE AM 10-49';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_MLE_AM_50_99 = 'MLE AM 50-99';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_MLE_AM_100_149 = 'MLE AM 100-149';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_MLE_AM_150_PLUS = 'MLE AM 150+';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_MLE_KAM_250_499 = 'MLE KAM 250-499';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_MLE_KAM_500_PLUS = 'MLE KAM 500+';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_MNC = 'MNC';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_KEY = 'Key';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_PUBLIC_NORTH = 'Public North';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_PUBLIC_SOUTH = 'Public South';
    public static final String ACCOUNT_SUGGESTED_SUB_BU_LVL2_API_NAME_ENTERPRISE_OTHER = 'Enterprise Other';

    // Account Suggested_Business_Sales_Unit picklist API Names
    public static final String ACCOUNT_SUGGESTED_SALES_BU_API_NAME_SMALL_ENTERPRISE = 'Small Enterprise';
    public static final String ACCOUNT_SUGGESTED_SALES_BU_API_NAME_MEDIUM_AND_LARGE = 'Medium&Large';
    public static final String ACCOUNT_SUGGESTED_SALES_BU_API_NAME_ENTERPRISE_SOLUTIONS = 'Solutions';
    public static final String ACCOUNT_SUGGESTED_SALES_BU_API_NAME_ENTERPRISE_OTHER = 'Enterprise other';
    public static final String ACCOUNT_SUGGESTED_SALES_BU_API_NAME_EXCLUDED = 'Excluded';
    public static final String ACCOUNT_SUGGESTED_SALES_BU_API_NAME_TELIA = 'Telia';
    // In Replacement
    public static final String ACCOUNT_SUGGESTED_SALES_BU_API_NAME_ENTERPRISE_SME = 'Enterprise SME';
    public static final String ACCOUNT_SUGGESTED_SALES_BU_API_NAME_ENTERPRISE_LARGE = 'Enterprise Large';
    public static final String ACCOUNT_SUGGESTED_SALES_BU_API_NAME_ENTERPRISE_P_AND_K = 'Enterprise P&K';

    // Account Suggested_Sales_Unit picklist API Names (Controlled BY Suggested_Business_Sales_Unit)
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_SMALL = 'Small';
    
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_MLE_AM = 'MLE AM';
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_MLE_KAM = 'MLE KAM';
    
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_ES_PRIVATE_SECTOR = 'ES Private Sector';
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_ES_PUBLIC_SECTOR = 'ES Public Sector';
    
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_ENTERPRISE_OTHER = 'Enterprise other';
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_EXCLUDED = 'Excluded';
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_TELIA = 'Telia';
    // In Replacement
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_SME_MASS_MARKET = 'SME Mass Market';
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_SME_SALES = 'SME Sales';
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_REGIONAL_ACCOUNT = 'Regional Account';
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_KEY_ACCOUNT = 'Key Account';
    public static final String ACCOUNT_SUGGESTED_SALES_UNIT_API_NAME_PUBLIC_SECTOR = 'Public Sector';

    // Account Suggested_Sales_Team picklist API Names (Controlled BY Suggested_Sales_Unit)
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_SMALL = 'Small';

    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_MLE_KAM_NORD = 'MLE KAM Nord';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_MLE_KAM_MITT = 'MLE KAM Mitt';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_MLE_KAM_SYDVAST = 'MLE KAM Sydväst';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_MLE_AM_GOTEBORG = 'MLE AM Göteborg';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_MLE_NYKUND = 'MLE Nykund';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_MLE_AM_SUNDSVALL = 'MLE AM Sundsvall';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_MLE_AM_LULEA = 'MLE AM Luleå';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_MLE_AM_STOCKHOLM = 'MLE AM Stockholm';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_MLE_SALES_MGMT = 'MLE Sales Mgmt';

    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_ES_KEY = 'ES Key';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_ES_PRIVATE_MGMT = 'ES Private Mgmt';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_ES_MNC = 'ES MNC';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_ES_PUBLIC_SOUTH = 'ES Public South';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_ES_PUBLIC_NORTH = 'ES Public North';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_ES_PUBLIC_MGMT = 'ES Public Mgmt';

    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_ENTERPRISE_OTHER = 'Enterprise Other';
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_EXCLUDED = 'Excluded';
    // In Replacement
    public static final String ACCOUNT_SUGGESTED_SALES_TEAM_API_NAME_P_AND_K_KEY_KEY = 'P&K Key Key';

    // Account Suggested_Delsegment
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_A11 = 'A11';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_A41 = 'A41';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_A51 = 'A51';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_A52 = 'A52';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_A53 = 'A53';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_B11 = 'B11';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_B41 = 'B41';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_B51 = 'B51';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_B52 = 'B52';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_B53 = 'B53';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_C11 = 'C11';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_C41 = 'C41';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_D11 = 'D11';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_D41 = 'D41';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_D51 = 'D51';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_D52 = 'D52';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_D53 = 'D53';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X11 = 'X11';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X41 = 'X41';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X51 = 'X51';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X52 = 'X52';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X53 = 'X53';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X57 = 'X57';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X58 = 'X58';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X59 = 'X59';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X91 = 'X91';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X92 = 'X92';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X93 = 'X93';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X94 = 'X94';
    public static final String ACCOUNT_SUGGESTED_DELSEGMENT_X95 = 'X95';

}