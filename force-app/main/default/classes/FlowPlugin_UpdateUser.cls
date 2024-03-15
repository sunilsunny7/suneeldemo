public class FlowPlugin_UpdateUser implements Process.Plugin{
    
    // Mode is passed in as input from the flow, and should be one of the following two strings
    @TestVisible private static final String MODE_DEACTIVATE = 'DEACTIVATE';
    @TestVisible private static final String MODE_USER_ROLE = 'UPDATE_ROLE';

    public Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{     
               new Process.PluginDescribeResult.InputParameter('Mode', 
               Process.PluginDescribeResult.ParameterType.STRING, true),
               new Process.PluginDescribeResult.InputParameter('User_Id', 
               Process.PluginDescribeResult.ParameterType.STRING, true),
               new Process.PluginDescribeResult.InputParameter('User_Role_Id', 
               Process.PluginDescribeResult.ParameterType.STRING, false)
        };

        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{ 
            new Process.PluginDescribeResult.OutputParameter('Status', 'Status',
            Process.PluginDescribeResult.ParameterType.STRING)
        };

        return result;
    }
    
    public Process.PluginResult invoke(Process.PluginRequest request){
        Map<String, Object> resultMap = new Map<String, Object>();

        String updateMode = (String) request.inputParameters.get('Mode');
        String userId = (String) request.inputParameters.get('User_Id');
        String userRoleId = (String) request.inputParameters.get('User_Role_Id');

        System.debug('updateMode is ' + updateMode);
        
        if(updateMode == MODE_DEACTIVATE){
            resultMap.put('status', 'User Deactivated');
            SEUtility.deactivateUserFuture(userId);
        } else if(updateMode == MODE_USER_ROLE){
            if(userRoleId != null){
                // Returning the User Role Name of the userRoleId.
                String userRoleName = [SELECT Id, Name FROM UserRole WHERE Id = :userRoleId LIMIT 1].Name;
                resultMap.put('Status', userRoleName);
                System.debug('Updating user role to: ' + userRoleName);
                SEUtility.updateUserRoleFuture(userId, userRoleId);
            } else {
                resultMap.put('status', 'User Role Id not provided');
            }
        } else {
            resultMap.put('status', 'ERROR: Invalid Mode');
        }
        
        System.debug(resultMap);
        return new Process.PluginResult(resultMap);
    }
}