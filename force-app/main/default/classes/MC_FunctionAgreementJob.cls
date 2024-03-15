/* 
 * ******************************************************************************************************
 * @author         Binamra Guha
 * @modifiedBy     
 * @maintainedBy   
 * @version        1.0
 * @created        2022-10-10
 * @modified
 *
 * ******************************************************************************************************
*/
/*
 * ******************************************************************************************************
 * This Batch class is responsible for updating the status field in contract object.
 * If the agreement is present in C2B cache which is imported in AMANDA custom Object
   MC_Function_Agreement__c, the agreement is status is moved to cancelled .
 * ******************************************************************************************************
*/
global class MC_FunctionAgreementJob Implements Database.batchable<sobject>,Schedulable, Database.Stateful
{
    private String query='';
    private List<String> errorList, successList;
    private integer numberOfRecordAvailable = 0;
/*
 * ************************************************************************************************************
 * Overview:-
 * Default Constructor of the class MC_FunctionAgreementJob
 * ************************************************************************************************************
*/
    public MC_FunctionAgreementJob()
    {
        errorList = new List<String>();
        successList = new List<String>();
    }
/*
 * ************************************************************************************************************
 * Overview:-
 * This method returns either a Database.QueryLocator object or an iterable that contains the 
   records or objects passed to the job. In this case MC_Function_Agreement__c object.
 * ************************************************************************************************************
 * @param BC                                       Database.BatchableContext object.
 * ************************************************************************************************************
*/
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String fields = 'Id, MC_Agreement_Id__c, MC_Agreement_Name__c, MC_Agreement_Number__c, MC_Agreement_technical_Name__c, MC_Agreement_technical_OrgNo__c, MC_Category_Id__c, MC_Customer_Identification_Name__c, MC_Customer_Identification_Number__c, MC_TSCID__c';
        query = 'select '+fields+' from MC_Function_Agreement__c';
        return Database.getQueryLocator(query);
    }
/*
 * ************************************************************************************************************
 * Overview:-
 * This method is called for each batch of records that you pass to it.
 * ************************************************************************************************************
 * @param context                                       Database.BatchableContext object.
 * @param scope                                         A list of sObjects(MC_Function_Agreement__c List)
 * ************************************************************************************************************
*/
    global void execute(Database.BatchableContext context, List<MC_Function_Agreement__c> scope)
    {
        String error_message = '';
        try{
            Set<String> tscidList = new Set<String>();
            List<Contract> contractUpdateList = new List<Contract>();
            for(MC_Function_Agreement__c fr: scope)
            {
                if(fr.MC_TSCID__c != null)
                {
                    tscidList.add(fr.MC_TSCID__c);
                }
            }
            for(Contract con: [Select id, ContractNumber, Agreement_Nr__c, Status,Mconline_Status__c from Contract Where Account.TSCID__c IN: tscidList AND (status != 'Cancelled' OR Mconline_Status__c != 'Cancelled') AND Contract_Record_Type__c IN ('MFA ReadOnly', 'RAM ReadOnly')])
            {
                con.Mconline_Status__c= 'Cancelled';
                contractUpdateList.add(con);
                successList.add(con.Agreement_Nr__c);
            }
            if(contractUpdateList != null && contractUpdateList.size() > 0)
            {
                numberOfRecordAvailable += contractUpdateList.size();
                Database.Update(contractUpdateList, false);
            }
        }
        catch(Exception e) 
        {
            error_message = String.valueOf(e.getMessage()+', Exception Trace:'+ e.getStackTraceString());
            errorList.add(error_message);
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
    global void finish(Database.BatchableContext BC)
    {
        String message = '', details = '';
        if(errorList != null)
        {
            message = 'Records processed with error = '+errorList.size();
            details = 'Records processed with error = '+JSON.serialize(errorList);
        }
        string inputData = '{"NumberOfReords":"'+numberOfRecordAvailable+'"}';
        MCOnline_Utility.logErrorWithoutFuture('Error summary = '+message+', In Details = '+details,'ERR-501','MC_FunctionAgreementJob','Apex Batch Class', 'Log',inputData,'','');
    }
/*
 * ************************************************************************************************************
 * Overview:-
 * Use this method to instantiate the class you want to schedule.
 * ************************************************************************************************************
 * @param BC                                       SchedulableContext object.
 * ************************************************************************************************************
*/
    global void execute(SchedulableContext sc) 
    {
        Database.executeBatch(new MC_FunctionAgreementJob(), 1);
    }
}