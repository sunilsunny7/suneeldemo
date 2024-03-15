public Class RecursionHandler{
    //These variables can be used to control (Allow/Disallow) recursion
    @Testvisible private static boolean firstBeforeRun = true;
    @Testvisible private static boolean firstAfterRun = false;
    @Testvisible private static boolean secondBeforeRun = false;   
    ///  
    @Testvisible private static boolean firstRun = true;
    public static boolean afterUpdateFlag = true; // added to handle recursion in Contract Trigger Handler
    public static boolean isFirstRun(){
        if(firstRun){
            firstRun = false;
            return true;
        }else{
            return firstRun;
        }
    }
    
    public static boolean firstBeforeRun(){
        
        return firstBeforeRun;
    }
    
    public static void finishFirstBeforeRun(){
        
        firstBeforeRun = false;
        firstAfterRun = true;
    }
    
    
    public static boolean firstAfterRun(){
        
        return firstAfterRun;
    }
    
    public static void finishFirstAfterRun(){
        
        firstAfterRun = false;
        secondBeforeRun = true;
    }


    public static boolean secondBeforeRun(){
        
        return secondBeforeRun;
    }

    public static void finishSecondBeforeRun(){
        
        secondBeforeRun=false;
    }    
}