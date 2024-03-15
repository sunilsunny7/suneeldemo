/**
 * Description:
 * Trigger Handler to be used alongside ContractTriggerHandler.
 * Should be used to implement functionalities exclusive to the Wholesales Contracts.
 * If the batch being processed contains Wholesales Contracts, all the 
 * ContractTriggerHandler-implemented methods are going to be bypassed for records contained in the batch.
 * 
 * Modifications:
 * 11.08.2023 [Tomass Brazovskis] LTAT-7521 - Introduced. Prevent Wholesales and non-Wholesales Contracts
 *            from being modified at the same time.
 **/
public with sharing class ContractWholesalesTriggerHandler extends TriggerHandler {
    
    private List<Contract> newListWholesales{ 
        get{    return newListWholesales;} 
        set{    newListWholesales = setListWholesalesContracts(value);}
    }
    private List<Contract> oldListWholesales{
        get{    return oldListWholesales;}
        set{    oldListWholesales = setListWholesalesContracts(value);}
    }
    private Map<Id, Contract> oldMapWholesales{
        get{    return oldMapWholesales;}
        set{    oldMapWholesales = setMapWholesalesContracts(value);}}
    private Map<Id, Contract> newMapWholesales{
        get{    return newMapWholesales;}
        set{    newMapWholesales = setMapWholesalesContracts(value);}
    }
    private List<Contract> newList;
    private List<Contract> oldList;
    private Boolean containsBatchAnyWholesalesContracts;
    
    // Set of all Wholesales Contract RecordTypes
    private static Set<Id> setWholesalesRecordTypeIds = new Set<Id>{
        Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(SEConstantsContract.CONTRACT_RECORDTYPE_WHOLESALES_CONTRACT)?.getRecordTypeId()
    };
    
    public ContractWholesalesTriggerHandler(){
        // Later invoke the automations on Wholesales records only
        this.newListWholesales = (List<Contract>) Trigger.new;
        this.oldListWholesales = (List<Contract>) Trigger.old;
        this.oldMapWholesales = (Map<Id, Contract>) Trigger.oldMap;
        this.newMapWholesales = (Map<Id, Contract>) Trigger.newMap;
        this.newList = (List<Contract>) Trigger.new;
        this.oldList = (List<Contract>) Trigger.old;
    }

    public override void beforeInsert() {
        this.checkForWholesalesContracts(newListWholesales, newList);
    }

    public override void beforeUpdate() {
        this.checkForWholesalesContracts(newListWholesales, newList);
    }
    public override void beforeDelete() {
        this.checkForWholesalesContracts(oldListWholesales, oldList);
    }

    /**
     * @Description:
     * Check whether the batch contains any Wholesales Contracts.
     * If the batch contains both Wholesales and non-Wholesales
     * Contracts, add errors to the non-Wholesales records. 
     * @param lstContractsWholesales - List of the relevant context versions of the 
     *        Wholesales Contract records.
     * @param lstContracts - List of the relevant context versions of the Contract records.
     * @Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/
    @TestVisible
    private void checkForWholesalesContracts(
        List<Contract> lstContractsWholesales,
        List<Contract> lstContracts
    ){
        if(!lstContractsWholesales.isEmpty()){
            this.containsBatchAnyWholesalesContracts = true;
            // Prevent non-Wholesales records contained in the batch from being modified
            if( lstContractsWholesales.size() != lstContracts.size()){
                for(Contract curContract : lstContracts){
                    if(!isWholesalesContract(curContract)){
                        curContract.addError(
                            SEConstantsContract.ERROR_MSG_NON_WHOLESALE_CONTRACTS_IN_WHOLESALE_BATCH);
                    }
                }
            }
        }
    }

    /**
     * @Description:
     * Set new/old Wholesales list by retaining the Wholesales Contracts only.
     * @param lstContracts - List returned by the Trigger.new/Trigger.old variables.
     * @return List of old/new Wholesales Contracts (or null, if passed as an argument).
     * @Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/
    private static List<Contract> setListWholesalesContracts(List<Contract> lstContracts){
        if(lstContracts == null){
            return lstContracts;
        }
        List<Contract> lstWholesalesContracts = new List<Contract>();
        for(Contract curContract : lstContracts){
            if(isWholesalesContract(curContract)){
                lstWholesalesContracts.add(curContract);
            }
        }
        return lstWholesalesContracts;
    }

    /**
     * @Description:
     * Set new/old Wholesales map by retaining the Wholesales Opps only.
     * @param mapContractIdsToContracts - Map returned by the Trigger.newMap/Trigger.oldMap variables.
     * @return Map of old/new Wholesales Contracts (or null, if passed as an argument).
     * @Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/
    private static Map<Id,Contract> setMapWholesalesContracts(Map<Id,Contract> mapContractIdsToContracts){
        if(mapContractIdsToContracts == null){
            return mapContractIdsToContracts;
        }
        Map<Id,Contract> mapContractIdsToContractsWholesales = new Map<Id,Contract>();
        for(Contract curContract : mapContractIdsToContracts.values()){
            if(isWholesalesContract(curContract)){
                mapContractIdsToContractsWholesales.put(curContract.Id, curContract);
            }
        }
        return mapContractIdsToContractsWholesales;
    }

    /**
     * @Description:
     * Check whether the passed Contract is a Wholesales Contract.
     * @param contractToCheck - A Contract record.
     * @return TRUE, if Contract is Wholesales, FALSE otherwise.
     * @Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/
    private static Boolean isWholesalesContract(Contract contractToCheck){
        if( contractToCheck != null 
            && setWholesalesRecordTypeIds.contains(contractToCheck.RecordTypeId)
        ){
            return true;
        }
        return false;
    }

    /**
     * @Description:
     * Returns whether this handler instance has processed any
     * Wholesales Contracts. 
     * @return  TRUE, if any Wholesales Contracts have been processed,
     *          FALSE otherwise.
     * @Modifications:
     * 11.08.2023 [TB] LTAT-7521 - Introduced.
     **/
    public Boolean getContainsBatchAnyWholesalesContracts(){ 
        if( this.containsBatchAnyWholesalesContracts == null 
            || !this.containsBatchAnyWholesalesContracts
        ){
            return false;
        }
        return this.containsBatchAnyWholesalesContracts;
    }
}