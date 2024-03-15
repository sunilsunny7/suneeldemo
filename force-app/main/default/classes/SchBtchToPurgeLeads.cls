global class SchBtchToPurgeLeads implements Schedulable{
    global void execute(SchedulableContext Sc){
        try{
            BatchToPurgeLeads purgeL=new BatchToPurgeLeads();
            Database.executeBatch(purgeL,200);
        }
        catch(exception e){
            system.debug('error' +e.getmessage());            
        }
    }

}