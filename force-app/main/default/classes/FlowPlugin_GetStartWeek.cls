public class FlowPlugin_GetStartWeek  implements Process.Plugin{

    public Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{     
               new Process.PluginDescribeResult.InputParameter('Seller_EndDate', 
               Process.PluginDescribeResult.ParameterType.DATETIME, false)   
        };

        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{ 
            new Process.PluginDescribeResult.OutputParameter('NewSeller_StartDate', 'New Seller Start Date',
            Process.PluginDescribeResult.ParameterType.DATETIME),
            new Process.PluginDescribeResult.OutputParameter('YT_startWeek', 'Yearly Target Start Week',
            Process.PluginDescribeResult.ParameterType.INTEGER)
        };

        return result;
    }
    
    public Process.PluginResult invoke(Process.PluginRequest request){
        Map<String, Object> resultMap = new Map<String, Object>();

        DateTime oldSellerEndDateTime = (DateTime) request.inputParameters.get('Seller_EndDate');
        system.debug('FlowPlugin_GetStartWeek oldSellerEndDateTime: ' + oldSellerEndDateTime);

        DateTime newSellerStartDate = oldSellerEndDateTime.addDays(1);
        Integer ytStartWeek = SEUtility.getWeekNumber(oldSellerEndDateTime.date());

        resultMap.put('NewSeller_StartDate', newSellerStartDate);
        resultMap.put('YT_startWeek', ytStartWeek);
       
        return new Process.PluginResult(resultMap);
    }
}