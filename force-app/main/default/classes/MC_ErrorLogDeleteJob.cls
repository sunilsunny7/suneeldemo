/******************************************************************************************************
 * @author         Binamra Guha
 * @modifiedBy     
 * @maintainedBy   
 * @version        1.0
 * @created        2022-11-29
 * @modified      2023-07-24(code ptimization to improve performance) and changes value of label MC_ErrorExpireDays -1 to -7
 * This Batch class is responsible for eliminating Error Log entries.
 * ******************************************************************************************************/
public class MC_ErrorLogDeleteJob implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{
    List<String> errorList = new List<String>();
    Integer numberOfRecordAvailable=0;
    DateTime lastNthDays;
    List<String> successList = new List<String>();
/*
 * ************************************************************************************************************
 * Overview:-
 * This method returns either a List<vlocity_cmt__VlocityErrorLogEntry__c> object or an iterable that contains the 
   records or objects passed to the job. In this case contract object.
 * ************************************************************************************************************
 * @param BC                                       Database.BatchableContext object.
 * ************************************************************************************************************
*/
    public List<vlocity_cmt__VlocityErrorLogEntry__c> start(Database.BatchableContext BC)
    {
        Integer numberOfDays;
        if(Label.MC_ErrorExpireDays != null){
            numberOfDays = Integer.valueOf(Label.MC_ErrorExpireDays);           
            lastNthDays = DateTime.Now().addDays(numberOfDays);
            return [Select id, CreatedDate,vlocity_cmt__ContextId__c, vlocity_cmt__ErrorMessage__c, vlocity_cmt__InputData__c from vlocity_cmt__VlocityErrorLogEntry__c Where vlocity_cmt__SourceName__c LIKE '%MassCustomized_MadamIntegration%' AND CreatedDate <= :lastNthDays Order By CreatedDate DESC];
        }else{
            return null;
        }
    }
 /* ************************************************************************************************************
 * Overview:-
 * This method is called for each batch of records that you pass to it.
 * ************************************************************************************************************
 * @param BC                                       Database.BatchableContext object.
 * @param contractList                             A list of sObjects(vlocity_cmt__VlocityErrorLogEntry__c List)
 * ************************************************************************************************************/ 
    public void execute(Database.BatchableContext BC,List<vlocity_cmt__VlocityErrorLogEntry__c> arrList)
    {
        try{           
            numberOfRecordAvailable += arrList.size();
            Database.delete(arrList,false);
            
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
        MCOnline_Utility.logErrorWithoutFuture('Error summary = '+message+', In Details = '+details,'ERR-501','MC_ErrorLogDeleteJob','Apex Batch Class', 'Log',inputData,'','');
    }

 /* ************************************************************************************************************
 * Overview:-
 * Use this method to instantiate the class you want to schedule.
 * ************************************************************************************************************
 * @param BC                                       SchedulableContext object.
 * ************************************************************************************************************/

    public void execute(SchedulableContext sc) 
    {
        Database.executeBatch(new MC_ErrorLogDeleteJob(), 1000);
    }
}