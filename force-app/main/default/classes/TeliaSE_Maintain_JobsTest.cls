@isTest
public class TeliaSE_Maintain_JobsTest {

    @isTest
    static void batchName() {
        try{
            test.startTest();
        TeliaSE_Maintain_Jobs.runMaintenanceJobs();
            test.stopTest();
        }
        catch(exception ex){
            
        }
       
    }
     @isTest
    static void batchName2() {
        
        try{
        test.startTest(); 
        TeliaSE_Maintain_Jobs.runRegenerateCacheJob();
            test.stopTest();
             }
        catch(exception ex){
            
        }
    }
}