/* 
* ******************************************************************************************************
* @author         Binamra Guha
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        2022-06-15
* @modified
*
* ******************************************************************************************************
*/
/*
* ******************************************************************************************************
* This Batch class is responsible for updating the price in contract line items.
* It will fetch the prices from MC_AgreementPlanChange__c and MC_PrismaPlan__c and update it in CLI.
* ******************************************************************************************************
*/
public class MC_UpdateCliPrice implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable
{
    Map<String, MC_RAMMFA_Settings__c> RAMMFAMap = MC_RAMMFA_Settings__c.getAll();
    List<String> errorList = new List<String>();
    Integer numberOfRecordAvailable;
    List<String> successList = new List<String>();
    /*
* ************************************************************************************************************
* Overview:-
* This method returns either a Database.QueryLocator object or an iterable that contains the 
records or objects passed to the job. In this case contract object.
* ************************************************************************************************************
* @param BC                                       Database.BatchableContext object.
* ************************************************************************************************************
*/  
    public List<Contract> start(Database.BatchableContext BC)
    {
        Set<String> recordType = new Set<String>();
        Set<String> agreementNumbers = new Set<String>();
        List<Contract> contractList=new List<Contract>();
        for(String rr: RAMMFAMap.keySet())
        {
            if(RAMMFAMap != null && RAMMFAMap.containsKey(rr))
            {
                if(String.valueOf(RAMMFAMap.get(rr).Type__c).equalsIgnoreCase('Record Type'))
                {
                    recordType.add(String.valueOf(RAMMFAMap.get(rr).Type_Name__c));
                }
            }
        }
        if(Label.MC_IsIndexing=='Yes')
        {
            recordType.add('Ramavtal');
        }
        for(AggregateResult  planChange:[select MC_AgreementNumber__c from MC_AgreementPlanChange__c where LastModifiedDate=today  WITH SECURITY_ENFORCED group by MC_AgreementNumber__c having count(id)>=1 ])
        {
            agreementNumbers.add(planChange.get('MC_AgreementNumber__c')+'');
        }
        if(agreementNumbers.size()>0){
            contractList = [Select id, ContractNumber, Agreement_Nr__c from Contract Where Agreement_Nr__c =:agreementNumbers and (Status IN ('Negotiating', 'Draft', 'Freezed', 'Active','Signed') OR (Mconline_Status__c = 'Freezed')) AND Contract_Record_Type__c IN:recordType WITH SECURITY_ENFORCED Order by EndDate DESC];
            if(contractList.size() > 0){
                numberOfRecordAvailable = contractList.size();
            }
        }
        return contractList;
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is called for each batch of records that you pass to it.
* ************************************************************************************************************
* @param BC                                       Database.BatchableContext object.
* @param contractList                             A list of sObjects(Contract List)
* ************************************************************************************************************
*/  
    public void execute(Database.BatchableContext BC,List<Contract> contractList)
    {
        try{
            Set<String> subscriptionTypeList = new Set<String>();
            Set<String> cliItem= new Set<String>();
            if(contractList != null && contractList.size() > 0)
            {
                if(contractList[0] != null && contractList[0].Id != null)
                {
                    for(vlocity_cmt__ContractLineItem__c cli :[Select id, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c,vlocity_cmt__ContractId__r.Contract_Record_Type__c,vlocity_cmt__ContractId__r.Status  from vlocity_cmt__ContractLineItem__c Where vlocity_cmt__ContractId__c =: contractList[0].Id and vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c !=null and (vlocity_cmt__ContractId__r.Contract_Record_Type__c !='Ramavtal' or (vlocity_cmt__ContractId__r.Contract_Record_Type__c ='Ramavtal' and vlocity_cmt__ContractId__r.Status in('Signed','Active'))) WITH SECURITY_ENFORCED])
                    {
                        if(cli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c!=null && cli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c.contains('-KÖ'))
                        {
                            String subType=cli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c.split('-KÖ')[0];
                            subscriptionTypeList.add(subType);
                        }
                        subscriptionTypeList.add(cli.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c);
                    }
                    If(subscriptionTypeList.size()>0){
                        MassCustomized_MadamIntegration.updateCliPrice(contractList[0].Agreement_Nr__c, subscriptionTypeList, Id.valueOf(contractList[0].Id));
                    }
                }
            }
            successList.add(contractList[0].ContractNumber);
        }
        catch(Exception e)
        {
            errorList.add(e.getStackTraceString());
        }
    }
    /*
* ************************************************************************************************************
* Overview:-
* This method is called after all batches are processed.
* ************************************************************************************************************
* @param BC                                       Database.BatchableContext object.
* ************************************************************************************************************
*/  
    public void finish(Database.BatchableContext BC)
    {
        String message = '';
        String details = '';
        if(errorList != null)
        {
            message = 'Records processed with error = '+errorList.size();
            details = 'Records processed with error = '+JSON.serialize(errorList);
        }
        string inputData = '{"NumberOfReords":"'+numberOfRecordAvailable+'"}';
        MCOnline_Utility.logErrorWithoutFuture('Error summary = '+message+', In Details = '+details,'ERR-501','MC_UpdateCliPrice','Apex Batch Class', 'Log',inputData,'','');
    }
    /*
* ************************************************************************************************************
* Overview:-
* Use this method to instantiate the class you want to schedule.
* ************************************************************************************************************
* @param BC                                       SchedulableContext object.
* ************************************************************************************************************
*/  
    public void execute(SchedulableContext sc) 
    {
        Database.executeBatch(new MC_UpdateCliPrice(), 1);
    }
}