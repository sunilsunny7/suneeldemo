/**
 * Description:
 * Class to manage Contract-related constants.
 * 
 * Modifications:
 * 11.08.2023 [Tomass Brazovskis] LTAT-7521 - Introduced.
 **/
public with sharing class SEConstantsContract {
        // Contract RecordType DeveloperNames 
        public static final String CONTRACT_RECORDTYPE_WHOLESALES_CONTRACT = System.Label.RT_DEVNAME_CONTRACT_WHOLESALES_CONTRACT;
        public static final String CONTRACT_RECORDTYPE_REAL_ESTATE_FIBER = 'Real_Estate_Fiber';

        // Contract Status API Names
        public static final String CONTRACT_STATUS_API_NAME_ACTIVE = 'Active';
        public static final String CONTRACT_STATUS_API_NAME_DRAFT = 'Draft';
    
        // Contract-related Error Messages
        public static final String ERROR_MSG_NON_WHOLESALE_CONTRACTS_IN_WHOLESALE_BATCH = System.Label.Error_Batch_With_Non_Wholesale_Contracts;
}