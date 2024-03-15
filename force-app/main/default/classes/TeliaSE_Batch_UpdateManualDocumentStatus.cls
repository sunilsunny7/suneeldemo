/**
 * @Author:      Rahul Kadam
 * @Company:     Capgemini
 * @Date:        16th Aug 2021
 * @Description: TeliaSE_Batch_UpdateManualDocumentStatus class is invoked a as schelduled job that will update status of documents which or signed manually.
 * @Epic:        
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------------
*/
Global class TeliaSE_Batch_UpdateManualDocumentStatus Implements Database.batchable<sobject>,Schedulable{
    String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, scrive__status__c FROM scrive__ScriveDocument__c  WHERE (Name LIKE \'%Manual\' AND scrive__status__c = \'Draft\') order by CreatedDate DESC';
        return Database.getQueryLocator(query);
    }
    global  void execute(Database.BatchableContext BC,List<scrive__ScriveDocument__c> scope){
            List<scrive__ScriveDocument__c> scriveRecordsToUpdate = new List<scrive__ScriveDocument__c>();
            if(scope.size() >0){
                for(scrive__ScriveDocument__c scriveDoc:scope){
                    scriveDoc.scrive__status__c = 'Signed';
                    scriveRecordsToUpdate.add(scriveDoc);
                    }
                }//End of if block
            if( scriveRecordsToUpdate.size() > 0){
                update scriveRecordsToUpdate;
            }//End of if block
        }//End of function
    global void finish(Database.BatchableContext BC){}
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new TeliaSE_Batch_UpdateManualDocumentStatus(), 1);
    }
}