global class MCOnline_ActiveAgreements implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts
{
    Map<String,String> failedContracts=new Map<String,String>();
    Set<String> agreementNumbers=new Set<String>();
    Set<String> recordTypes=new Set<String>{'MFA ReadOnly'};
    Boolean skipMadamCallout=false;
    String query='';
    global MCOnline_ActiveAgreements(Set<String> agreementNumbers,Set<String> recordTypes,Boolean skipMadamCallout){
        this.agreementNumbers=agreementNumbers;
        this.recordTypes=recordTypes!=null?recordTypes:this.recordTypes;
        this.skipMadamCallout=skipMadamCallout!=null?skipMadamCallout:this.skipMadamCallout;
        this.query='select id,ContractNumber,Agreement_Nr__c,account.Org_Nr__c from Contract where Agreement_Nr__c in :agreementNumbers and Contract_Record_Type__c in :recordTypes and status !=\'Cancelled\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc,List<Contract> agreements)
    {
        for(Contract con:agreements)
        {
            if(!skipMadamCallout)
            {
                signalMadam(con.ContractNumber, con.Agreement_Nr__c, con.id, con.account.Org_Nr__c);
            }
            con.status='Active';
        }
        Database.update(agreements,false);
    }

    global void finish(Database.BatchableContext bc)
    {
    
    }

    private static void signalMadam(String serviceContractNumber, String agreementNumber, String contractId, String accountId){
        String endpointName, ProcedureName = 'MassCustomized_SetServiceContractId';
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        inputMap.put('agreementNumber', agreementNumber);
        inputMap.put('contractNumber', serviceContractNumber);
        inputMap.put('companyCode', accountId);
        inputMap.put('Id', contractId);
        inputMap.put('endpoint', 'TeliaSE_CustomerFrameAgreement_AT');
        Map<String, Object> result = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(ProcedureName, inputMap, optionsMap);
    }
}