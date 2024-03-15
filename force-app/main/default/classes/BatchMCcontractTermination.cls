global class BatchMCcontractTermination Implements Database.batchable<sobject>,Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id,Status,vlocity_cmt__TerminateDate__c,EndDate from Contract where RecordType.DeveloperName = 'TeliaSE_Framework_Agreement' and vlocity_cmt__TerminateDate__c != null and Status !='Cancelled']);
    }
    global  void execute(Database.BatchableContext BC,List<Contract> scope){
        List<Contract> contractToUpdate = new List<Contract>();
        DateTime dt = DateTime.now();
        String dateTimeStr = dt.format('yyyy-MM-dd');
        for(Contract con: scope){
            Contract c = new Contract();
            String terminationDate = String.valueOf(con.vlocity_cmt__TerminateDate__c);
            if(terminationDate <= dateTimeStr){
            	c.Id = con.Id;
            	c.Status = 'Cancelled';
            	contractToUpdate.add(c);
            }
        }
        List < vlocity_cmt__VlocityErrorLogEntry__c > exceptions = new List < vlocity_cmt__VlocityErrorLogEntry__c > ();
        if(contractToUpdate.size() > 0){
        	try {
                database.update(contractToUpdate);
            }catch (Exception e) {
                System.debug('Exception while executing the Termination batch job: ' + e);
                vlocity_cmt__VlocityErrorLogEntry__c v1 = new vlocity_cmt__VlocityErrorLogEntry__c();
                v1.vlocity_cmt__ErrorType__c = 'Exception';
                v1.vlocity_cmt__ErrorMessage__c = String.valueOf(e.getmessage());
                v1.vlocity_cmt__SourceName__c = 'BatchMCcontractTermination';
                v1.vlocity_cmt__ObjectName__c = 'Contract';
                exceptions.add(v1);
            }
        }
        if (exceptions.size() > 0) {
            try {
                insert exceptions;
            } catch (Exception e) {
                system.debug('Exception Caught:' + e.getmessage());
            }
        }
    }
    global void finish(Database.BatchableContext BC){
    }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchMCcontractTermination(), 500);
    }
}