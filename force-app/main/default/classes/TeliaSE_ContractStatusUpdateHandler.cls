/**
* @author: Suneel G Shivanna
* @date:  10.12.2018
* @description:  Handler Class which is called by AgreementStatusUpdate Trigger
* @name : TeliaSE_ContractStatusUpdateHandler
*/
global class TeliaSE_ContractStatusUpdateHandler {
    
    /*-----------------------------------------------------------------------------------------------------------
**Name            :         TeliaSE_ContractStatusUpdateHandler
**Created By      :         Suneel G Shivanna
**Method Name     :         updateContractStatusforInsert
**Description     :         Handler method update the contract status
-----------------------------------------------------------------------------------------------------------*/ 
    public static final String Contr_STAGE_Draft = 'Draft';
    public static final String Scr_STAGE_Withdrawn = 'Withdrawn';
    global static void updateContractStatusforInsert(List<scrive__ScriveDocument__c> documents)
    {
        List<Contract> contracts=new List<Contract>(); 
        Set<Id> contractsSet=new Set<Id>();
        for(scrive__ScriveDocument__c doc :documents)
        {
            contractsSet.add(doc.scrive__Contract__c);
        }
        Map<Id,Contract> contractsForUpdate=new Map<Id,Contract>([select id,status,Manual_check__c,customerSignedDate,TeliaSE_Agreement_Received_Date__c from Contract where id in :contractsSet]);
        for(scrive__ScriveDocument__c document :documents)
        {
            if(document.scrive__Contract__c != null)
            {
                Contract contractForUpdate=contractsForUpdate.get(document.scrive__Contract__c);
                if(document.scrive__status__c == System.label.SENT)
                {
                    contractForUpdate.Status=System.label.SENTFORSIGNING;
                    contracts.add(contractForUpdate);
                }
            }
        }
        if(contracts.size()>0)
        {
            try
            {
                update contracts;
            }Catch(Exception e)
            {
                System.debug('Error occured'+e.getMessage());
            }
        }
    }
    
    /*-----------------------------------------------------------------------------------------------------------
**Name            :         TeliaSE_ContractStatusUpdateHandler
**Created By      :         Suneel G Shivanna
**Method Name     :         updateContractStatusforUpdate
**Description     :         Handler method update the contract status
-----------------------------------------------------------------------------------------------------------*/ 
    public static void updateContractStatusforUpdate(List<scrive__ScriveDocument__c> documents,Map<Id,scrive__ScriveDocument__c> oldMap,Map<Id,scrive__ScriveDocument__c> newMap)
    {
        List<Contract> contracts=new List<Contract>(); 
        Set<Id> contractsSet=new Set<Id>();
        for(scrive__ScriveDocument__c doc :documents)
        {
            contractsSet.add(doc.scrive__Contract__c);
        }
        Map<Id,Contract> contractsForUpdate=new Map<Id,Contract>([select id,status,Manual_check__c, customerSignedDate,TeliaSE_Agreement_Received_Date__c,RecordType.developername from Contract where id in :contractsSet FOR UPDATE]);
        for(scrive__ScriveDocument__c document :documents)
        {
            if(document.scrive__Contract__c != null && oldMap.get(document.id).scrive__status__c != newMap.get(document.id).scrive__status__c)
            {
                Contract contractForUpdate=contractsForUpdate.get(document.scrive__Contract__c);
                if(document.scrive__status__c == System.label.SENT)
                {
                    contractForUpdate.Status=System.label.SENTFORSIGNING;
                    contracts.add(contractForUpdate);
                }
                else if(document.scrive__status__c == System.label.SIGNED)
                {
                    contractForUpdate.Status=System.label.SIGNED;
                    if(!contractForUpdate.Manual_Check__c){
                        contractForUpdate.customerSignedDate=Date.today();
                        contractForUpdate.TeliaSE_Agreement_Received_Date__c = Date.Today();
                    }
                    contracts.add(contractForUpdate);
                }
                else if(document.scrive__status__c == Scr_STAGE_Withdrawn )
                {
                    if(contractForUpdate.RecordType.developername == 'Real_Estate_Fiber'){
                        contractForUpdate.Status = Contr_STAGE_Draft ;
                    }
                    else{
                        contractForUpdate.Status = 'Approved' ;  
                    }
                    contracts.add(contractForUpdate);
                }
                else if(document.scrive__status__c == System.label.REJECTED)
                {
                    contractForUpdate.Status=System.label.REJECTED;
                    contracts.add(contractForUpdate);
                }
            }  
        }
        if(contracts.size()>0)
        {
            try
            {
                update contracts;
            }Catch(Exception e)
            {
                System.debug('Error occured'+e.getMessage());
            }
        }
        
    }
}