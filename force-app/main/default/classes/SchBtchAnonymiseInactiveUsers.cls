global class SchBtchAnonymiseInactiveUsers implements Schedulable{
    global void execute(SchedulableContext Sc){
        try{
            BatchToAnonymiseInactiveUsers anonymUser=new BatchToAnonymiseInactiveUsers();
            Database.executeBatch(anonymUser,10);
        }
        catch(exception e){
            system.debug('error' +e.getmessage());            
        }
    }

}