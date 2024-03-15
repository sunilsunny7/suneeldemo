/* 
 * ******************************************************************************************************
 * @author         Binamra Guha
 * @modifiedBy     
 * @maintainedBy   
 * @version        1.0
 * @created        2022-11-29
 * @modified
 *
 * ******************************************************************************************************
*/
/*
 * ******************************************************************************************************
 * This Batch class is responsible for eliminating duplicate agreement.
 * ******************************************************************************************************
*/
public class MC_HandleAgreementJob implements Database.Batchable<AggregateResult>, Database.Stateful, Database.AllowsCallouts, Schedulable
{
    List<String> errorList = new List<String>();
    Integer numberOfRecordAvailable=0;
    List<String> successList = new List<String>();
/*
 * ************************************************************************************************************
 * Overview:-
 * This method returns either a List<AggregateResult> object or an iterable that contains the 
   records or objects passed to the job. In this case contract object.
 * ************************************************************************************************************
 * @param BC                                       Database.BatchableContext object.
 * ************************************************************************************************************
*/
    public List<AggregateResult> start(Database.BatchableContext BC)
    {
        List<AggregateResult> aggregate = [Select Agreement_Nr__c from Contract Where (Contract_Record_Type__c IN ('Ramavtal')  AND status != 'Cancelled' AND Mconline_Status__c = null) OR (Contract_Record_Type__c IN ('RAM ReadOnly', 'MFA ReadOnly')) GROUP BY Agreement_Nr__c HAVING COUNT(Agreement_Nr__c) > 1 LIMIT 2000];
        return aggregate;
    }
/*
 * ************************************************************************************************************
 * Overview:-
 * This method is called for each batch of records that you pass to it.
 * ************************************************************************************************************
 * @param BC                                       Database.BatchableContext object.
 * @param contractList                             A list of sObjects(AggregateResult List)
 * ************************************************************************************************************
*/  
    public void execute(Database.BatchableContext BC,List<AggregateResult> aggList)
    {
        try{
            Set<String> contractList = new Set<String>();
            for(AggregateResult agg: aggList){
                if(agg.get('Agreement_Nr__c') != null){
                    contractList.add(String.valueOf(agg.get('Agreement_Nr__c')));
                }
            }
            Map<String, Contract> contractMap = new Map<String, Contract>();
            for(Contract con :[Select id,name,ContractNumber,Agreement_Nr__c, AccountId,Status,Type_of_Agreement__c, Contract_Record_Type__c from Contract Where Agreement_Nr__c IN:contractList AND Contract_Record_Type__c IN ('Ramavtal')  AND status != 'Cancelled' AND Mconline_Status__c = null]){
                if(con.Agreement_Nr__c != null){
                    contractMap.put(con.Agreement_Nr__c, con);
                }
            }
            Set<String> activecon = new Set<String>();
            List<Contract> DupicateCons = new List<Contract>();
            for(Contract con :[Select id,name,ContractNumber,Agreement_Nr__c, AccountId,Status,Type_of_Agreement__c, Contract_Record_Type__c from Contract Where Agreement_Nr__c IN:contractList AND Contract_Record_Type__c IN ('RAM ReadOnly', 'MFA ReadOnly') Order by CreatedDate DESC]){
                if(contractMap != null && contractMap.containsKey(con.Agreement_Nr__c)){
                    DupicateCons.add(con);
                }
                if(activecon.contains(con.Agreement_Nr__c)){
                    DupicateCons.add(con);
                }else{
                    activecon.add(con.Agreement_Nr__c);
                }
            }
            if(DupicateCons != null && DupicateCons.size()>0){
                numberOfRecordAvailable += DupicateCons.size();
                Database.delete(DupicateCons, false);
            }
        }catch(Exception e)
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
        Database.executeBatch(new MC_HandleAgreementJob(), 1);
    }
}