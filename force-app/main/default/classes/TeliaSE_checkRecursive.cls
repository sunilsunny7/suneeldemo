public Class TeliaSE_checkRecursive{
    private static boolean run = true;
    private static boolean runInsert = true;
    public static boolean runOnce(){
    system.debug('Value of run'+run);
    if(run){
     run=false;
     return true;
    }else{
        return run;
 }
    
    }
    
    public static boolean runOnceInsert(){
    system.debug('Value of run'+runInsert);
    if(runInsert){
     runInsert=false;
     return true;
    }else{
        return runInsert;
 }
    
    }
   
}