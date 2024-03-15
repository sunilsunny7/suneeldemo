//Test Class for Convergence emails MC_Convergence_AddOn_Email  #MCSTO_7020
@isTest
public  class Test_MC_Convergence_AddOn_Email {
    @testSetup static void setup()
    {
        User salesManager; 
        System.runAs(new User(Id = Userinfo.getUserId()))
        {
            salesManager = Test_DataFactory.createAdminUser();
            salesManager.Bypass_VR__c = true;
            salesManager.FirstName = 'TestRunUser';
            salesManager.IsActive = true;
            insert salesManager;
        }
        System.runAs(salesManager)
        {
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            // Insert Contact records
            Contact con= New Contact(lastName='Business Account ', AccountId=acc.Id,Email='abhishek.a.agrawal@capgemini.com');
            insert con;
            MC_AddOn_Benefit_Tracking__c addOn=New MC_AddOn_Benefit_Tracking__c(Name='Introduktionskurs i MS365 eller säkerhet, 1 timme – 3 utbildningsplatser');
            insert addOn;
        }
    }
    
    public static testmethod void invokeEmail(){
        
        Contact con=[SELECT id FROM Contact LIMIT 1];
        MC_AddOn_Benefit_Tracking__c addOn=[SELECT id FROM MC_AddOn_Benefit_Tracking__c LIMIT 1];
        
        Map<String,Object> inputMap = new Map<String,Object>();
        // Id addOn='a9p5E0000006rx5QAA';
        inputMap.put('ContactId', con.id);
        inputMap.put('AddOnBenefitId',addOn.Id);
        
        MC_Convergence_AddOn_Email tq = new MC_Convergence_AddOn_Email();
        tq.invokeMethod('ConvergenceApprovalEmail', inputMap, inputMap, inputMap);
        
    }
}