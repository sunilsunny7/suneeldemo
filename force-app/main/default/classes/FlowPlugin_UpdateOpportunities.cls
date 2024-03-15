public class FlowPlugin_UpdateOpportunities implements Process.Plugin{

    public Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{ 
               new Process.PluginDescribeResult.InputParameter('oldSeller_Id', 
               Process.PluginDescribeResult.ParameterType.STRING, true), 
               new Process.PluginDescribeResult.InputParameter('Seller_EndDate', 
               Process.PluginDescribeResult.ParameterType.DATETIME, false)   
        };

        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{ 
            new Process.PluginDescribeResult.OutputParameter('Status', 'Status',
            Process.PluginDescribeResult.ParameterType.STRING)
        };

        return result;
    }
    
    public Process.PluginResult invoke(Process.PluginRequest request){
        Map<String, Object> resultMap = new Map<String, Object>();
        
        String oldSellerId = (String)request.inputParameters.get('oldSeller_Id');
        DateTime oldSellerEndDateTime = (DateTime)request.inputParameters.get('Seller_EndDate');
        Date oldSellerEndDate = oldSellerEndDateTime.date();
        
        String queryFilter = ' WHERE Id IN (SELECT Opportunity__c FROM Forecast_Opportunity_Link__c WHERE Weekly_Forecast_Item__r.Seller__c = \'' + oldSellerId + '\' AND Opportunity__r.CloseDate > ' + String.valueOf(oldSellerEndDate) + ')';
        
        System.debug('UpdateOpportunitiesFlowPlugin calling batch method CreateFolsForExistingOppsBatch. Input queryFilter is: ' + queryFilter);
        Id batchInstanceId = Database.executeBatch(new CreateFolsForExistingOppsBatch(queryFilter, false), 50);
        System.debug('batchInstanceId: ' + batchInstanceId);

        resultMap.put('status', 'OK');
       
        return new Process.PluginResult(resultMap);
    }
}