/**
 * Description:
 * ContractWholesalesTriggerHandler test class.
 * 
 * Modifications:
 * 11.08.2023 [Tomass Brazovskis] LTAT-7521 - Introduced.
 **/
@isTest
public with sharing class ContractWholesalesTriggerHandler_Test {

    public static final Id CONTRACT_RECORDTYPEID_WHOLESALES_CONTRACT = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(SEConstantsContract.CONTRACT_RECORDTYPE_WHOLESALES_CONTRACT)?.getRecordTypeId();
    public static final Id CONTRACT_RECORDTYPEID_REAL_ESTATE_FIBER = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(SEConstantsContract.CONTRACT_RECORDTYPE_REAL_ESTATE_FIBER)?.getRecordTypeId();
    public static final String NAME_TEST_ACCOUNT = 'largeTestAccount';
    public static final String NAME_TEST_CONTRACT_WHOLESALES = 'TestContract_Wholesales';
    public static final String NAME_TEST_CONTRACT_REAL_ESTATE_FIBER = 'TestContract_RealEstateFiber';
    public static final String USERNAME_BYPASS_USER = 'bypassUser' + Datetime.now().format('yyyyMMdd') + '@telia.com';

    /**
     * @Description:
     * Set up a Bypass User and a Test Account.
     * Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/ 
    @TestSetup
    static void makeData(){
        User userBypass = Test_DataFactory.getByPassUser();
        userBypass.Username = USERNAME_BYPASS_USER;
        userBypass.CommunityNickname = 'bypassUser' + Datetime.now().format('yyyyMMdd');
        update userBypass;
        System.runAs(userBypass){
            Account largeAccount = Test_DataFactory.createOneLargeStandardAccount();
            largeAccount.Name = NAME_TEST_ACCOUNT;
            insert largeAccount;
        }
    }
    
    /**
     * @Description:
     * Verify DML operations with batches containing only Wholesales Contracts
     * can be performed successfully.
     * Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/ 
    @isTest
    public static void testDMLOperationsWithWholesalesContractsOnly(){
        List<User> lstBypassUsers = [SELECT Id FROM User WHERE Username = :USERNAME_BYPASS_USER];
        List<Account> lstParentAccounts = [SELECT Id FROM Account WHERE Name = :NAME_TEST_ACCOUNT LIMIT 1];
        System.runAs(lstBypassUsers[0]){
            List<Contract> lstWholesaleContractsToInsert = new List<Contract>();
            for(Integer Idx = 0; idx < 5; idx++){
                Contract curWholesalesContract = createWholesalesContract(lstParentAccounts[0]);
                curWholesalesContract.Name += String.valueOf(Idx);
                lstWholesaleContractsToInsert.add(curWholesalesContract);
            }
            Test.startTest();
            List<Database.SaveResult> lstSaveResults = Database.insert(lstWholesaleContractsToInsert, false);
            for(Database.SaveResult curContractSaveResult : lstSaveResults){
                System.assert(  curContractSaveResult.isSuccess(),
                    'A batch containing only Wholesales Contracts should have been inserted successfully');
            }
            // Prepare records for update
            for(Integer idx = 0; idx < lstWholesaleContractsToInsert.size(); idx++){
                lstWholesaleContractsToInsert[idx].Name += String.valueOf(idx);
            }
            List<Database.SaveResult> lstUpdateResults = Database.update(lstWholesaleContractsToInsert, false);
            for(Database.SaveResult curContractUpdateResult : lstUpdateResults){
                System.assert(  curContractUpdateResult.isSuccess(),
                    'A batch containing only Wholesales Contracts should have been updated successfully');
            }
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Verify that only the Wholesales Contracts are being inserted successfully when 
     * a batch contains both Wholesales and non-Wholesales Contracts.
     * Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/ 
    @isTest
    public static void testInsertionsWithWholesalesAndNonWholesalesContracts(){
        List<User> lstBypassUsers = [SELECT Id FROM User WHERE Username = :USERNAME_BYPASS_USER];
        List<Account> lstTestAccounts = [SELECT Id FROM Account WHERE Name = :NAME_TEST_ACCOUNT LIMIT 1];
        System.runAs(lstBypassUsers[0]){
            List<Contract> lstContractsToInsert = new List<Contract>();
            for(Integer Idx = 0; idx < 5; idx++){
                Contract curWholesalesContract = createWholesalesContract(lstTestAccounts[0]);
                curWholesalesContract.Name += String.valueOf(Idx);
                lstContractsToInsert.add(curWholesalesContract);
            }
            List<Contract> lstWholesalesContractsToInsert = lstContractsToInsert.clone();
            // Add any non-Wholesales Contracts to the list of records to modify
            for(Integer Idx = 0; idx < 2; idx++){
                Contract curContract = createContractRealEstateFiber(lstTestAccounts[0]);
                lstContractsToInsert.add(curContract);
            }
            Test.startTest();
            List<Database.SaveResult> lstSaveResults = Database.insert(lstContractsToInsert, false);
            Set<Id> setIdsOfSuccessfulInsertions = new Set<Id>(); 
            for(Database.SaveResult curContractSaveResult : lstSaveResults){
                if(curContractSaveResult.isSuccess()){
                    setIdsOfSuccessfulInsertions.add(curContractSaveResult.getId());
                }
            }
            for(Contract curWholesaleContract : lstWholesalesContractsToInsert){
                System.assert(  
                    String.isNotBlank(curWholesaleContract.Id)
                    && setIdsOfSuccessfulInsertions.contains(curWholesaleContract.Id),
                    'A Wholesale Contract failed to be inserted.');
                setIdsOfSuccessfulInsertions.remove(curWholesaleContract.Id);
            }
            System.assert(  setIdsOfSuccessfulInsertions.isEmpty(),
                'A non-Wholesale Contract was inserted together with Wholesale Contracts.');
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Verify that only the Wholesales Contracts are being updated successfully when 
     * a batch contains both Wholesales and non-Wholesales Contracts.
     * Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/ 
    @isTest
    public static void testUpdatesWithWholesalesAndNonWholesalesContracts(){
        List<User> lstBypassUsers = [SELECT Id FROM User WHERE Username = :USERNAME_BYPASS_USER];
        List<Account> lstTestAccounts = [SELECT Id FROM Account WHERE Name = :NAME_TEST_ACCOUNT LIMIT 1];
        System.runAs(lstBypassUsers[0]){
            List<Contract> lstWholesaleContractsToInsert = new List<Contract>();
            for(Integer Idx = 0; idx < 5; idx++){
                Contract curWholesalesContract = createWholesalesContract(lstTestAccounts[0]);
                curWholesalesContract.Name += String.valueOf(Idx);
                lstWholesaleContractsToInsert.add(curWholesalesContract);
            }
            insert lstWholesaleContractsToInsert;
            
            // Insert any non-Wholesales Contracts in a separate transaction
            List<Contract> lstREFContractsToInsert = new List<Contract>();
            for(Integer Idx = 0; idx < 2; idx++){
                Contract curContract = createContractRealEstateFiber(lstTestAccounts[0]);
                lstREFContractsToInsert.add(curContract);
            }
            insert lstREFContractsToInsert;

            List<Contract> lstMixedContractsToUpdate = lstWholesaleContractsToInsert.clone();
            lstMixedContractsToUpdate.addAll(lstREFContractsToInsert);
            
            // Attempt an update with a batch containing both Wholesales and non-Wholesales Contracts
            Test.startTest();
            List<Database.SaveResult> lstSaveResults = Database.update(lstMixedContractsToUpdate, false);
            Set<Id> setIdsOfSuccessfulUpdates = new Set<Id>();
            for(Database.SaveResult curContractSaveResult : lstSaveResults){
                if(curContractSaveResult.isSuccess()){
                    setIdsOfSuccessfulUpdates.add(curContractSaveResult.getId());
                }
            }
            for(Contract curWholesaleContract : lstWholesaleContractsToInsert){
                System.assert(  
                    setIdsOfSuccessfulUpdates.contains(curWholesaleContract.Id),
                    'A Wholesale Contract failed to be updated.');
                    setIdsOfSuccessfulUpdates.remove(curWholesaleContract.Id);
            }
            System.assert(  setIdsOfSuccessfulUpdates.isEmpty(),
                'A non-Wholesale Contract was updated together with Wholesale Contracts.');
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Verify that only the Wholesales Contracts are being deleted successfully when 
     * a batch contains both Wholesales and non-Wholesales Contracts.
     * Modifications:
     * 30.08.2023 [TB] LTAT-7521 - Introduced.
     **/ 
    @isTest
    public static void testDeletionsWithWholesalesAndNonWholesalesContracts(){
        List<User> lstBypassUsers = [SELECT Id FROM User WHERE Username = :USERNAME_BYPASS_USER];
        List<Account> lstTestAccounts = [SELECT Id FROM Account WHERE Name = :NAME_TEST_ACCOUNT LIMIT 1];
        System.runAs(lstBypassUsers[0]){
            List<Contract> lstWholesaleContractsToInsert = new List<Contract>();
            for(Integer Idx = 0; idx < 5; idx++){
                Contract curWholesalesContract = createWholesalesContract(lstTestAccounts[0]);
                curWholesalesContract.Name += String.valueOf(Idx);
                lstWholesaleContractsToInsert.add(curWholesalesContract);
            }
            insert lstWholesaleContractsToInsert;
            
            // Insert any non-Wholesales Contracts in a separate transaction
            List<Contract> lstREFContractsToInsert = new List<Contract>();
            for(Integer Idx = 0; idx < 2; idx++){
                Contract curContract = createContractRealEstateFiber(lstTestAccounts[0]);
                lstREFContractsToInsert.add(curContract);
            }
            insert lstREFContractsToInsert;

            List<Contract> lstMixedContractsToDelete = lstWholesaleContractsToInsert.clone();
            lstMixedContractsToDelete.addAll(lstREFContractsToInsert);
            
            // Attempt a deletion with a batch containing both Wholesales and non-Wholesales Contracts
            Test.startTest();
            List<Database.DeleteResult> lstDeleteResults = Database.delete(lstMixedContractsToDelete, false);
            Set<Id> setIdsOfSuccessfulDeletions = new Set<Id>();
            for(Database.DeleteResult curContractDeleteResult : lstDeleteResults){
                if(curContractDeleteResult.isSuccess()){
                    setIdsOfSuccessfulDeletions.add(curContractDeleteResult.getId());
                }
            }
            for(Contract curWholesaleContract : lstWholesaleContractsToInsert){
                System.assert(  
                    setIdsOfSuccessfulDeletions.contains(curWholesaleContract.Id),
                    'A Wholesale Contract failed to be deleted.');
                    setIdsOfSuccessfulDeletions.remove(curWholesaleContract.Id);
            }
            System.assert(  setIdsOfSuccessfulDeletions.isEmpty(),
                'A non-Wholesale Contract was deleted together with Wholesale Contracts.');
            Test.stopTest();
        }
    }

    /**
     * @Description:
     * Helper method returning a Wholesales Contract.
     * @return Wholesales Contract test record.
     * Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/
    public static Contract createWholesalesContract(Account parentAccount){
        if( parentAccount == null || parentAccount.Id == null){
            return null;
        }
        return new Contract(AccountId = parentAccount.Id,
                            Name = NAME_TEST_CONTRACT_WHOLESALES,
                            RecordTypeId = CONTRACT_RECORDTYPEID_WHOLESALES_CONTRACT,
                            StartDate = System.today() - 1,
                            ContractTerm = 36,
                            Status = SEConstantsContract.CONTRACT_STATUS_API_NAME_DRAFT);
    }
    
    /**
     * @Description:
     * Helper method returning a Real_Estate_Fiber Contract.
     * @return Real_Estate_Fiber Contract test record.
     * Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/
    public static Contract createContractRealEstateFiber(Account parentAccount){
        if( parentAccount == null || parentAccount.Id == null){
            return null;
        }
        return new Contract(AccountId = parentAccount.Id,
                            Name = NAME_TEST_CONTRACT_REAL_ESTATE_FIBER,
                            Agreement_KO_nr__c = '01234567',
                            RecordTypeId = CONTRACT_RECORDTYPEID_REAL_ESTATE_FIBER,
                            StartDate = System.today() - 1,
                            ContractTerm = 36,
                            Status = SEConstantsContract.CONTRACT_STATUS_API_NAME_DRAFT);
    }

}