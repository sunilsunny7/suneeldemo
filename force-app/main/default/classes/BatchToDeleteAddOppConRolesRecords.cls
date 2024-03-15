/**
    About
    -----
    Description: BatchToDeleteAddOppConRolesRecords
    Create date: 24.05.2016

    Update History
    --------------
    Created May 2016 - N.G - Created
        - This batch will fetch and delete all records of object 'Add_Opportunity_Contact_Role__c' created in a day.
        - The batch runs everyday to remove extra data created by this object.
        - The SchBatchToDelOppConRole can be used to set up a new schedule of the batch job.
*/

// To run batch manually:
// Id batchInstanceId = Database.executeBatch(new BatchToDeleteAddOppConRolesRecords('SELECT Id FROM Add_Opportunity_Contact_Role__c'), [batchSize]); // If not using default batch size of 200
global class BatchToDeleteAddOppConRolesRecords implements Database.Batchable<sObject>{
        global final String query;// Variable to hold Query string
        //Constructor          
        global BatchToDeleteAddOppConRolesRecords(string q){            
                system.debug('***inside constructor**');
                this.query = q;
                system.debug('query*****'+query);                       
        }
        global Database.QueryLocator start(Database.BatchableContext BC){           
                system.debug('batch started*******');
                return Database.getQueryLocator(query);     
        }
        global void execute(Database.BatchableContext BC, List<Add_Opportunity_Contact_Role__c> scope){
            try{
                system.debug('from batch*****'+scope);
                delete scope;
            }
            catch(exception e){
                system.debug('exception: *****'+e.getMessage());
            }
        }
        global void finish(Database.BatchableContext BC){

        }
    }