global class ATMDeleteScheduler implements Schedulable{
    global void execute(SchedulableContext Sc){
        try{
            AccountTeamDelete atmDel=new AccountTeamDelete();
            Database.executeBatch(atmDel,100);
        }
        catch(exception e){
            system.debug('error' +e.getmessage());            
        }
    }

}