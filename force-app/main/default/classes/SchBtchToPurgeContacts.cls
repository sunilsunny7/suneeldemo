global class SchBtchToPurgeContacts implements Schedulable{
    global void execute(SchedulableContext Sc){
        try{
            BatchToPurgeContacts purgeC=new BatchToPurgeContacts();
            Database.executeBatch(purgeC,500);
        }
        catch(exception e){
            system.debug('error' +e.getmessage());            
        }
    }

}