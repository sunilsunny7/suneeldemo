global class BtchAnonymizeMobSubsScheduler implements Schedulable{
    global void execute(SchedulableContext Sc){
        try{
            BatchAnonymizeMobileSubscriptions anoMs=new BatchAnonymizeMobileSubscriptions();
            Database.executeBatch(anoMs,1000);
        }
        catch(exception e){
            system.debug('error' +e.getmessage());            
        }
    }

}