global class Fiber_Automatic_Extension_Contracts implements 
Database.Batchable<sObject>, Database.Stateful {
    
    global Integer recordsProcessed = 0;
    global Integer recordsFetched = 0;
    global String Active = 'Active';
    global String Signed = 'Signed';
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator(
            
            'Select Id,StartDate,EndDate,Status,TeliaSE_Fiber_Previous_ContractId__c,Contract_Termination_Date__c,Reason_for_Cancellation__c,TeliaSE_Fiber_Installation_Date__c, ContractTerm from Contract where (Status = \'Active\' OR Status = \'Signed\')And RecordType.Name = \'Real Estate Fiber\' AND (EndDate = today OR Contract_Termination_Date__c<=today OR TeliaSE_Fiber_Installation_Date__c <= today)');
        
    }
    global void execute(Database.BatchableContext bc, List<Contract> scope){
        
        List<Contract> contracts = new List<Contract>();
        Set<ID> Oldids = new SET<ID>();
        for(Contract con: scope){
            Oldids.add(con.TeliaSE_Fiber_Previous_ContractId__c);
        }
        Map<ID,Contract> getOldContract = new Map<ID,Contract>([SELECT Id,status from Contract where ID IN:Oldids]);
        System.debug('@@@'+getOldContract);
        for (Contract contract : scope) { 
            //19/05/2023 :Below if condition is commented as part of LTAT-8666 
            /* if(contract.Contract_Termination_Date__c == null && contract.Status == Active && contract.EndDate == System.today())
            {
                contract.EndDate = contract.EndDate.addMonths(12);
                contracts.add(contract);
                recordsProcessed = recordsProcessed + 1;
            }*/
            if(contract.Contract_Termination_Date__c <= System.today() && contract.Status == Active)
            {
                contract.Reason_for_Cancellation__c='Termination – Batch Job';
                contract.Status = 'Cancelled';
                contracts.add(contract);
                recordsProcessed = recordsProcessed + 1;
            }
            
            else if(contract.TeliaSE_Fiber_Installation_Date__c != null && contract.Status == Signed)
            {  
                contract.StartDate = contract.TeliaSE_Fiber_Installation_Date__c;
                if(contract.ContractTerm !=null){
                    contract.EndDate= contract.StartDate.addMonths(contract.ContractTerm);
                }
                Contract.Reminder_Days_Before__c= '90';
                contract.Status = Active;
                contracts.add(contract);
                recordsProcessed = recordsProcessed + 1;
                if(contract.TeliaSE_Fiber_Installation_Date__c != null && contract.TeliaSE_Fiber_Previous_ContractId__c !=null ){
                   System.debug('@@@'+getOldContract.get(contract.TeliaSE_Fiber_Previous_ContractId__c));
                    if(getOldContract.get(contract.TeliaSE_Fiber_Previous_ContractId__c) !=null){
                        Contract OldRecord = new Contract();
                        if(getOldContract.get(contract.TeliaSE_Fiber_Previous_ContractId__c).status!='Cancelled'){
                            OldRecord.Status ='Cancelled';
                            OldRecord.Id =getOldContract.get(contract.TeliaSE_Fiber_Previous_ContractId__c).ID;
                            OldRecord.Reason_for_Cancellation__c = 'Omforhandling';
                            contracts.add(OldRecord);
                            recordsProcessed = recordsProcessed + 1;
                        }
                    }
                }
            }
            recordsFetched = recordsFetched + 1;
        }
        
        update contracts;
    }    
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        System.debug(recordsFetched + ' records Fetched. Shazam!');
        
    }    
}