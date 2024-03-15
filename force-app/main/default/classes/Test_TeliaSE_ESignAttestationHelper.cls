@isTest
public class Test_TeliaSE_ESignAttestationHelper {
  
    @isTest static void testApprovalMatrixWrongMethod(){
        
        String methodName = 'getAttestationContactWrong';
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        
        TeliaSE_ESignAttestationHelper helperClass = new TeliaSE_ESignAttestationHelper();
        Boolean returnValue = helperClass.invokeMethod(methodName,inputMap,outMap, options);
    }

    @isTest static void testApprovalMatrix(){
        
        String methodName = 'getAttestationContact';
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        
        Map <String, Object> contractMap = new Map<String, Object>();
        contractMap.put('OpportunityTotalValue', 500000);
        contractMap.put('MCCommercialSetup', 'SME/SOHO Organisation');
         Map <String, Object> contractRoleMap = new Map<String, Object>();
        user u = [SELECT ID from user where Profile.Name like 'Telia Sales - SOHO DS' limit 1];
        contractRoleMap.put('Id','8005E000000wdDlQAI' );
        contractRoleMap.put('ContactRole', 'Avtalsgranskare');
        
        inputMap.put('Contract',contractMap);
        inputMap.put('ContactRole',contractRoleMap);
        inputMap.put('userId',u.id);
        inputMap.put('ContextId','8005E000000wdDlQAI');
        
        TeliaSE_ESignAttestationHelper helperClass = new TeliaSE_ESignAttestationHelper();
        Boolean returnValue = helperClass.invokeMethod(methodName,inputMap,outMap, options);
    }

    @isTest static void testApprovalMatrixMoreThan5K(){
        
        String methodName = 'getAttestationContact';
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        
        Map <String, Object> contractMap = new Map<String, Object>();
        contractMap.put('OpportunityTotalValue', 5000009);
        contractMap.put('MCCommercialSetup', 'SME/SOHO Organisation');
        Map <String, Object> contractRoleMap = new Map<String, Object>();
        user u = [SELECT ID from user where Profile.Name like 'Telia Sales - SOHO DS' limit 1];
             
        inputMap.put('ContactRole',contractRoleMap);
        inputMap.put('Contract',contractMap);
        inputMap.put('userId',u.id);
        inputMap.put('ContextId','8005E000000wdDlQAI');
        
        TeliaSE_ESignAttestationHelper helperClass = new TeliaSE_ESignAttestationHelper();
        Boolean returnValue = helperClass.invokeMethod(methodName,inputMap,outMap, options);
    }

}