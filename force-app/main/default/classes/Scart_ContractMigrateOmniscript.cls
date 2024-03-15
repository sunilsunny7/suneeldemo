global class Scart_ContractMigrateOmniscript implements vlocity_cmt.VlocityOpenInterface2{   
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('backupContract')) 
            {
                Map<String,Object> contractInfo = new Map<String,Object>();
                contractInfo = (Map<String,Object>)inputMap.get('OriginialContract');
                String contractId = String.valueOf(contractInfo.get('contractid'));
                Contract backupContract =  new Contract();
                if(contractId != null)
                {
                    backupContract = Scart_ContractMigarteApex.createBackupContract(contractId);
                }
                outMap.put('BackupContract',backupContract);
                outMap.put('backupContractId',backupContract.id);
            }
            else if(methodName.equalsIgnoreCase('contractLinesMigrate'))
            {
                Map<String,Object> contractInfo = new Map<String,Object>();
                contractInfo = (Map<String,Object>)inputMap.get('OriginialContract');
                
                Contract originalContract = new Contract();
                originalContract.id = String.valueOf(contractInfo.get('contractid'));
                originalContract.vlocity_cmt__QuoteId__c = String.valueOf(contractInfo.get('FAQuote'));
                
                Scart_ContractMigarteApex.contractLinesMigrate(originalContract);
            }
            else if(methodName.equalsIgnoreCase('mergeStatusContractLines'))
            {
                string contractIdOld = string.valueOf(options.get('OriginalContract'));
                string backupContractId = string.valueOf(options.get('BackupContract'));
                
                Contract originalContract = new Contract();
                originalContract.id = contractIdOld;
                
                Contract backupContract = new Contract();
                backupContract.id = backupContractId;               
                Scart_ContractMigarteApex.mergeStatusContractLines(backupContract,originalContract);
            }
            else if(methodName.equalsIgnoreCase('revertChanges'))
            {
                string contractIdOld = string.valueOf(options.get('OriginalContract'));
                string backupContractId = string.valueOf(options.get('BackupContract'));
                Contract originalContract = new Contract();
                originalContract.id = contractIdOld;
                
                Contract backupContract = new Contract();
                backupContract.id = backupContractId;
                try{
                    Scart_ContractMigarteApex.revertChange(backupContract,originalContract);  
                    OutMap.put('RevertResult',(String)'Successful');
                }
                catch(Exception e)
                {
                    OutMap.put('RevertResult',(String)'Failed');
                    system.debug('Error in Reversion');
                }
                
                //delete backupContract;  
            }
            else 
            {
                result = false;
            }            
        } catch(Exception e) 
        {
            OutMap.put('ErrorFromApex',e.getStackTraceString());
            result = false;
        }        
        return result;
    }
}