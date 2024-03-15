public class FlowPlugin_isLargeUser  implements Process.Plugin{
     
    public Process.PluginDescribeResult describe(){

        Process.PluginDescribeResult result = new Process.PluginDescribeResult();

        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{     
               new Process.PluginDescribeResult.InputParameter('UserId', 
               Process.PluginDescribeResult.ParameterType.STRING, true)   
        };

        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{ 
            new Process.PluginDescribeResult.OutputParameter('isLargeUser', 'Is Large User',
            Process.PluginDescribeResult.ParameterType.BOOLEAN)
        };

        return result;   
    }

    public Process.PluginResult invoke(Process.PluginRequest request){ 
        Map<String, Object> resultMap = new Map<String, Object>();

        String userId = (string) request.inputParameters.get('UserId');
        User u = [SELECT Id, ProfileId FROM User WHERE ID = :userId];
        Boolean isLargeUser = SEUtility.isLargeUser(u);
        
        resultMap.put('isLargeUser', isLargeUser);      
        
        return new Process.PluginResult(resultMap);
    }
}